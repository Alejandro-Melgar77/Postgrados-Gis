# -*- coding: utf-8 -*-
"""
================================================================================
SCRIPT: exportar_desde_arcmap.py
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
OBJETIVO: Leer las capas editadas en ArcMap 10.8 (postgrados_uagrm_pts y
          postgrados_uagrm_poly desde .gdb o .shp), recalcular el area real
          en EPSG:32720 (UTM Zone 20S), sincronizar area_m2 y coordenadas, y
          exportar los GeoJSON en EPSG:4326 listos para PostGIS y Leaflet.
ENTORNO:  Python 2.7 (ArcGIS Desktop 10.8 - ArcPy)
USO:      C:\Python27\ArcGIS10.8\python.exe scripts\exportar_desde_arcmap.py
          Opcional: --source gdb | shp (por defecto prioriza .gdb si existe)
================================================================================
"""

import os
import sys
import json
import codecs
import arcpy

ESRI_WKT1_UTM20S = (
    'PROJCS["WGS_1984_UTM_Zone_20S",'
    'GEOGCS["GCS_WGS_1984",'
    'DATUM["D_WGS_1984",'
    'SPHEROID["WGS_1984",6378137.0,298.257223563]],'
    'PRIMEM["Greenwich",0.0],'
    'UNIT["Degree",0.0174532925199433]],'
    'PROJECTION["Transverse_Mercator"],'
    'PARAMETER["False_Easting",500000.0],'
    'PARAMETER["False_Northing",10000000.0],'
    'PARAMETER["Central_Meridian",-63.0],'
    'PARAMETER["Scale_Factor",0.9996],'
    'PARAMETER["Latitude_Of_Origin",0.0],'
    'UNIT["Meter",1.0]]'
)


def parse_source_arg(argv):
    """Lee el parametro opcional --source gdb|shp."""
    for idx, arg in enumerate(argv):
        if arg == "--source" and idx + 1 < len(argv):
            val = argv[idx + 1].lower()
            if val in ("gdb", "shp"):
                return val
    return "auto"


def is_utm20s(sr):
    """Determina si el SpatialReference corresponde a WGS 84 UTM Zone 20S."""
    if not sr:
        return False
    return sr.factoryCode == 32720 or sr.name == "WGS_1984_UTM_Zone_20S"


def polygon_to_geojson_geometry(geom_wgs):
    """Convierte una geometria poligonal ArcPy en EPSG:4326 a GeoJSON Polygon."""
    esri_json = json.loads(geom_wgs.JSON)
    raw_rings = esri_json.get("rings", [])
    clean_rings = []

    for ring in raw_rings:
        if len(ring) < 3:
            continue
        rounded = [[round(float(pt[0]), 7), round(float(pt[1]), 7)] for pt in ring]
        if rounded[0] != rounded[-1]:
            rounded.append(list(rounded[0]))
        if len(rounded) >= 4:
            clean_rings.append(rounded)

    return {
        "type": "Polygon",
        "coordinates": clean_rings,
    }


def csv_escape(val):
    """Formatea un valor para CSV UTF-8 con escape seguro de comillas."""
    if val is None:
        return u""
    if isinstance(val, (int, float)):
        return unicode(val)
    if not isinstance(val, unicode):
        val = unicode(val)
    if u"," in val or u'"' in val or u"\n" in val or u"\r" in val:
        return u'"' + val.replace(u'"', u'""') + u'"'
    return val


def exportar(source_mode="auto"):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    out_dir = os.path.join(project_root, "output_postgrados")

    gdb_path = os.path.join(out_dir, "postgrados_uagrm.gdb")
    gdb_pts = os.path.join(gdb_path, "postgrados_uagrm_pts")
    gdb_poly = os.path.join(gdb_path, "postgrados_uagrm_poly")

    shp_pts = os.path.join(out_dir, "postgrados_uagrm_pts.shp")
    shp_poly = os.path.join(out_dir, "postgrados_uagrm_poly.shp")

    use_gdb = False
    if source_mode == "gdb":
        use_gdb = arcpy.Exists(gdb_pts) and arcpy.Exists(gdb_poly)
    elif source_mode == "shp":
        use_gdb = False
    else:
        use_gdb = arcpy.Exists(gdb_pts) and arcpy.Exists(gdb_poly)

    pts_src = gdb_pts if use_gdb else shp_pts
    poly_src = gdb_poly if use_gdb else shp_poly

    if not arcpy.Exists(pts_src) or not arcpy.Exists(poly_src):
        print "ERROR: No se encontraron las capas de puntos o poligonos en output_postgrados."
        return False

    sr_wgs84 = arcpy.SpatialReference(4326)
    sr_utm20s = arcpy.SpatialReference()
    sr_utm20s.loadFromString(ESRI_WKT1_UTM20S)

    print "======================================================================"
    print "SINCRONIZACION Y EXPORTACION DESDE ARCMAP 10.8 (PUNTOS + POLIGONOS)"
    print "Fuente puntos:    %s" % pts_src
    print "Fuente poligonos: %s" % poly_src
    print "======================================================================"

    # 1. Recalcular area real en EPSG:32720 para cada poligono y generar GeoJSON
    desc_poly = arcpy.Describe(poly_src)
    sr_poly = desc_poly.spatialReference

    areas_by_id = {}
    poly_features = []

    poly_fields = ["id_postg", "cod_fac", "nom_unidad", "tipo_geom", "area_m2", "SHAPE@"]
    with arcpy.da.UpdateCursor(poly_src, poly_fields) as cur:
        for row in cur:
            pid, cod_fac, nom_unidad, tipo_geom, _, geom = row
            if not geom:
                continue

            geom_utm = geom if is_utm20s(sr_poly) else geom.projectAs(sr_utm20s)
            area_m2 = round(float(geom_utm.area), 2)
            areas_by_id[pid] = area_m2

            row[4] = area_m2
            cur.updateRow(row)

            geom_wgs = geom_utm.projectAs(sr_wgs84)
            geojson_geom = polygon_to_geojson_geometry(geom_wgs)

            poly_features.append({
                "type": "Feature",
                "geometry": geojson_geom,
                "properties": {
                    "id_postg": pid,
                    "cod_fac": cod_fac,
                    "nom_unidad": nom_unidad,
                    "tipo_geom": tipo_geom if tipo_geom else u"Referencial",
                    "area_m2": area_m2,
                },
            })

    poly_features.sort(key=lambda f: f["properties"]["id_postg"])
    print "[OK] Areas recalculadas en EPSG:32720 para %d poligonos." % len(poly_features)

    # Sincronizar area_m2 en capa poligonal secundaria (.shp o .gdb)
    poly_companion = shp_poly if use_gdb else gdb_poly
    if arcpy.Exists(poly_companion):
        with arcpy.da.UpdateCursor(poly_companion, ["id_postg", "area_m2"]) as cur:
            for row in cur:
                if row[0] in areas_by_id:
                    row[1] = areas_by_id[row[0]]
                    cur.updateRow(row)

    # 2. Leer capa de puntos, sincronizar area_m2 y coordenadas desde geometria real
    desc_pts = arcpy.Describe(pts_src)
    sr_pts = desc_pts.spatialReference

    pts_fields = [
        "id_postg", "cod_fac", "nom_unidad", "nom_facult", "tipo_ent", "ambito",
        "municipio", "campus", "modulo_pab", "direccion", "lat_wgs84", "lon_wgs84",
        "lat_ruta", "lon_ruta", "dist_via_m", "telefono", "correo", "horario",
        "estado_geo", "cod_qr", "programas", "sitio_web", "url_foto", "area_m2",
        "SHAPE@",
    ]

    pts_features = []
    csv_rows = []
    coords_by_id = {}

    with arcpy.da.UpdateCursor(pts_src, pts_fields) as cur:
        for row in cur:
            geom = row[24]
            if not geom:
                continue

            pid = row[0]
            geom_utm = geom if is_utm20s(sr_pts) else geom.projectAs(sr_utm20s)
            geom_wgs = geom_utm.projectAs(sr_wgs84)

            lon_wgs = round(float(geom_wgs.firstPoint.X), 7)
            lat_wgs = round(float(geom_wgs.firstPoint.Y), 7)
            utm_x = round(float(geom_utm.firstPoint.X), 3)
            utm_y = round(float(geom_utm.firstPoint.Y), 3)
            area_val = areas_by_id.get(pid, round(float(row[23] or 0.0), 2))

            row[10] = lat_wgs
            row[11] = lon_wgs
            row[23] = area_val
            cur.updateRow(row)

            lat_ruta = row[12] if row[12] not in (None, 0.0) else lat_wgs
            lon_ruta = row[13] if row[13] not in (None, 0.0) else lon_wgs
            dist_via = round(float(row[14] or 0.0), 2)

            coords_by_id[pid] = (lat_wgs, lon_wgs, area_val)

            props = {
                "id_postg": pid,
                "cod_fac": row[1],
                "nom_unidad": row[2],
                "nom_facult": row[3],
                "tipo_ent": row[4],
                "ambito": row[5],
                "municipio": row[6],
                "campus": row[7],
                "modulo_pab": row[8],
                "direccion": row[9],
                "lat_wgs84": lat_wgs,
                "lon_wgs84": lon_wgs,
                "utm_x_20s": utm_x,
                "utm_y_20s": utm_y,
                "lat_ruta": lat_ruta,
                "lon_ruta": lon_ruta,
                "dist_via_m": dist_via,
                "telefono": row[15],
                "correo": row[16],
                "horario": row[17],
                "estado_geo": row[18],
                "cod_qr": row[19],
                "programas": row[20],
                "sitio_web": row[21],
                "url_foto": row[22],
                "area_m2": area_val,
            }

            pts_features.append({
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [lon_wgs, lat_wgs],
                },
                "properties": props,
            })
            csv_rows.append(props)

    pts_features.sort(key=lambda f: f["properties"]["id_postg"])
    csv_rows.sort(key=lambda r: r["id_postg"])

    # Sincronizar capa de puntos secundaria (.shp o .gdb)
    pts_companion = shp_pts if use_gdb else gdb_pts
    if arcpy.Exists(pts_companion):
        with arcpy.da.UpdateCursor(pts_companion, ["id_postg", "lat_wgs84", "lon_wgs84", "area_m2"]) as cur:
            for row in cur:
                if row[0] in coords_by_id:
                    lat_w, lon_w, area_w = coords_by_id[row[0]]
                    row[1] = lat_w
                    row[2] = lon_w
                    row[3] = area_w
                    cur.updateRow(row)

    # 3. Exportar GeoJSON de puntos actualizado
    pts_geojson_path = os.path.join(out_dir, "postgrados_uagrm_web.geojson")
    pts_fc_json = {
        "type": "FeatureCollection",
        "name": "postgrados_uagrm_web",
        "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:OGC:1.3:CRS84"}},
        "features": pts_features,
    }
    with codecs.open(pts_geojson_path, "w", encoding="utf-8") as f:
        f.write(json.dumps(pts_fc_json, ensure_ascii=False, indent=2))
    print "[OK] GeoJSON de puntos exportado: %s (%d features)" % (pts_geojson_path, len(pts_features))

    # 4. Exportar GeoJSON de poligonos actualizado
    poly_geojson_path = os.path.join(out_dir, "postgrados_uagrm_poly_web.geojson")
    poly_fc_json = {
        "type": "FeatureCollection",
        "name": "postgrados_uagrm_poly_web",
        "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:OGC:1.3:CRS84"}},
        "features": poly_features,
    }
    with codecs.open(poly_geojson_path, "w", encoding="utf-8") as f:
        f.write(json.dumps(poly_fc_json, ensure_ascii=False, indent=2))
    print "[OK] GeoJSON de poligonos exportado: %s (%d features)" % (poly_geojson_path, len(poly_features))

    # 5. Actualizar CSV de respaldo con area_m2 y coordenadas vigentes
    csv_path = os.path.join(out_dir, "postgrados_uagrm.csv")
    csv_header = [
        "id_postg", "cod_fac", "nom_unidad", "nom_facult", "tipo_ent", "ambito",
        "municipio", "campus", "modulo_pab", "direccion", "lat_wgs84", "lon_wgs84",
        "utm_x_20s", "utm_y_20s", "lat_ruta", "lon_ruta", "dist_via_m", "telefono",
        "correo", "horario", "estado_geo", "cod_qr", "programas", "sitio_web",
        "url_foto", "area_m2",
    ]
    with codecs.open(csv_path, "w", encoding="utf-8-sig") as f:
        f.write(u",".join(csv_header) + u"\r\n")
        for r in csv_rows:
            line = [csv_escape(r.get(col)) for col in csv_header]
            f.write(u",".join(line) + u"\r\n")
    print "[OK] CSV sincronizado: %s (%d registros)" % (csv_path, len(csv_rows))
    print "======================================================================"
    return True


if __name__ == "__main__":
    mode = parse_source_arg(sys.argv[1:])
    ok = exportar(mode)
    if not ok:
        sys.exit(1)
