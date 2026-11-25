# -*- coding: utf-8 -*-
"""
================================================================================
SCRIPT: vincular_red_vial.py
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
OBJETIVO: Snapping geometrico de unidades de postgrado a ejes de vias/calles
          Compatible con licencia ArcMap 10.8 Basic / Standard (sin Near_analysis)
USO:
    python vincular_red_vial.py [ruta_capa_vias.shp]
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

def vincular(vias_input=None):
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    out_dir = os.path.join(project_root, "output_postgrados")

    if not vias_input:
        # Buscar vias por defecto
        candidatos = [
            os.path.join(out_dir, "red_vial_uagrm_referencial.shp"),
            os.path.join(out_dir, "red_vial_uagrm_osm.shp"),
            os.path.join(project_root, "SIG", "DATOS DE SIG", "DATOS GEOGRAFICOS BOLIVIA", "SHAPES WGS84", "CAMINOS_Y_VIA_FERREA.shp")
        ]
        for c in candidatos:
            if arcpy.Exists(c):
                vias_input = c
                break

    if not vias_input or not arcpy.Exists(vias_input):
        print "ERROR: No se especifico una capa de vias valida o no existe."
        print "Uso: python vincular_red_vial.py <ruta_a_capa_vias.shp>"
        return False

    print "======================================================================"
    print "VINCULACION A RED VIAL / SNAPPING GEOMETRICO (ARCMAP 10.8 BASIC)"
    print "Capa de vias de entrada: %s" % vias_input
    print "======================================================================"

    sr_wgs84 = arcpy.SpatialReference(4326)
    sr_utm20s = arcpy.SpatialReference()
    sr_utm20s.loadFromString(ESRI_WKT1_UTM20S)

    # 1. Cargar geometrias de vias (proyectadas a UTM 20S si es necesario)
    desc_vias = arcpy.Describe(vias_input)
    sr_vias = desc_vias.spatialReference
    print "CRS de la capa de vias: %s" % (sr_vias.name if sr_vias else "Desconocido")

    line_geometries = []
    # Cargamos solo lineas en el area metropolitana de Santa Cruz para maxima velocidad
    # Bounding box Santa Cruz de la Sierra en UTM 20S
    scz_xmin, scz_ymin = 460000.0, 8010000.0
    scz_xmax, scz_ymax = 510000.0, 8055000.0

    with arcpy.da.SearchCursor(vias_input, ["SHAPE@"]) as cur:
        for row in cur:
            geom = row[0]
            if geom:
                if sr_vias and sr_vias.factoryCode != 32720 and sr_vias.name != "WGS_1984_UTM_Zone_20S":
                    geom = geom.projectAs(sr_utm20s)
                ext = geom.extent
                # Filtro espacial simple
                if ext.XMax >= scz_xmin and ext.XMin <= scz_xmax and ext.YMax >= scz_ymin and ext.YMin <= scz_ymax:
                    line_geometries.append(geom)

    print "Lineas viales cargadas en el ambito urbano: %d" % len(line_geometries)
    if len(line_geometries) == 0:
        print "Aviso: No se encontraron lineas en el bounding box urbano. Cargando todas las lineas..."
        with arcpy.da.SearchCursor(vias_input, ["SHAPE@"]) as cur:
            for row in cur:
                geom = row[0]
                if geom:
                    if sr_vias and sr_vias.factoryCode != 32720 and sr_vias.name != "WGS_1984_UTM_Zone_20S":
                        geom = geom.projectAs(sr_utm20s)
                    line_geometries.append(geom)
        print "Total lineas cargadas: %d" % len(line_geometries)

    shp_pts = os.path.join(out_dir, "postgrados_uagrm_pts.shp")
    shp_nodos = os.path.join(out_dir, "postgrados_nodos_acceso.shp")
    gdb_path = os.path.join(out_dir, "postgrados_uagrm.gdb")
    gdb_pts = os.path.join(gdb_path, "postgrados_uagrm_pts")
    gdb_nodos = os.path.join(gdb_path, "postgrados_nodos_acceso")

    # 2. Calcular Snapping para cada punto urbano usando queryPointAndDistance
    snapped_data = {}  # id_postg -> (dist_m, snap_pt_utm, lat_ruta, lon_ruta)

    with arcpy.da.SearchCursor(shp_pts, ["id_postg", "ambito", "SHAPE@"]) as cur:
        for row in cur:
            pid = row[0]
            ambito = row[1]
            pt_geom = row[2]

            if ambito == "Urbano" and line_geometries:
                min_dist = float("inf")
                best_snap_pt = None

                for line in line_geometries:
                    # queryPointAndDistance es compatible con licencia Basic/Standard
                    res = line.queryPointAndDistance(pt_geom)
                    snap_pt, dist_along, dist_from, is_right = res
                    if dist_from < min_dist:
                        min_dist = dist_from
                        best_snap_pt = snap_pt

                min_dist_m = round(min_dist, 2)
                snap_wgs = best_snap_pt.projectAs(sr_wgs84)
                lon_r = round(snap_wgs.firstPoint.X, 7)
                lat_r = round(snap_wgs.firstPoint.Y, 7)

                snapped_data[pid] = (min_dist_m, best_snap_pt, lat_r, lon_r)
                print "  %s [Urbano] -> Snapped a %.2f m | Nodo: (%.5f, %.5f)" % (pid, min_dist_m, lat_r, lon_r)
            else:
                # Provincial o sin lineas
                orig_wgs = pt_geom.projectAs(sr_wgs84)
                lon_r = round(orig_wgs.firstPoint.X, 7)
                lat_r = round(orig_wgs.firstPoint.Y, 7)
                snapped_data[pid] = (0.0, pt_geom, lat_r, lon_r)

    # 3. Actualizar postgrados_uagrm_pts.shp
    with arcpy.da.UpdateCursor(shp_pts, ["id_postg", "lat_ruta", "lon_ruta", "dist_via_m"]) as cur:
        for row in cur:
            pid = row[0]
            if pid in snapped_data:
                dist_m, snap_pt, lat_r, lon_r = snapped_data[pid]
                row[1] = lat_r
                row[2] = lon_r
                row[3] = dist_m
                cur.updateRow(row)

    # 4. Actualizar postgrados_nodos_acceso.shp (geometria y atributos)
    with arcpy.da.UpdateCursor(shp_nodos, ["id_postg", "SHAPE@", "lat_ruta", "lon_ruta", "dist_via_m"]) as cur:
        for row in cur:
            pid = row[0]
            if pid in snapped_data:
                dist_m, snap_pt, lat_r, lon_r = snapped_data[pid]
                row[1] = snap_pt
                row[2] = lat_r
                row[3] = lon_r
                row[4] = dist_m
                cur.updateRow(row)

    # 5. Actualizar en postgrados_uagrm.gdb si existe
    if arcpy.Exists(gdb_pts):
        with arcpy.da.UpdateCursor(gdb_pts, ["id_postg", "lat_ruta", "lon_ruta", "dist_via_m"]) as cur:
            for row in cur:
                pid = row[0]
                if pid in snapped_data:
                    dist_m, snap_pt, lat_r, lon_r = snapped_data[pid]
                    row[1] = lat_r
                    row[2] = lon_r
                    row[3] = dist_m
                    cur.updateRow(row)

    if arcpy.Exists(gdb_nodos):
        with arcpy.da.UpdateCursor(gdb_nodos, ["id_postg", "SHAPE@", "lat_ruta", "lon_ruta", "dist_via_m"]) as cur:
            for row in cur:
                pid = row[0]
                if pid in snapped_data:
                    dist_m, snap_pt, lat_r, lon_r = snapped_data[pid]
                    row[1] = snap_pt
                    row[2] = lat_r
                    row[3] = lon_r
                    row[4] = dist_m
                    cur.updateRow(row)

    # 6. Regenerar GeoJSON
    geojson_path = os.path.join(out_dir, "postgrados_uagrm_web.geojson")
    with open(geojson_path, "r") as f:
        gj = json.load(f)

    for feat in gj["features"]:
        pid = feat["properties"]["id_postg"]
        if pid in snapped_data:
            dist_m, snap_pt, lat_r, lon_r = snapped_data[pid]
            feat["properties"]["dist_via_m"] = dist_m
            feat["properties"]["lat_ruta"] = lat_r
            feat["properties"]["lon_ruta"] = lon_r

    with codecs.open(geojson_path, "w", encoding="utf-8") as f:
        json.dump(gj, f, ensure_ascii=False, indent=2)

    # 7. Regenerar CSV
    csv_path = os.path.join(out_dir, "postgrados_uagrm.csv")
    csv_lines = []
    with codecs.open(csv_path, "r", encoding="utf-8-sig") as f:
        csv_lines = f.readlines()

    if csv_lines:
        header = csv_lines[0].strip().split(",")
        idx_pid = header.index("id_postg")
        idx_lat_r = header.index("lat_ruta")
        idx_lon_r = header.index("lon_ruta")
        idx_dist = header.index("dist_via_m")

        new_csv_lines = [csv_lines[0]]
        for line in csv_lines[1:]:
            parts = line.strip().split(",")
            pid = parts[idx_pid]
            if pid in snapped_data:
                dist_m, snap_pt, lat_r, lon_r = snapped_data[pid]
                parts[idx_lat_r] = str(lat_r)
                parts[idx_lon_r] = str(lon_r)
                parts[idx_dist] = str(dist_m)
            new_csv_lines.append(u",".join(parts) + u"\r\n")

        with codecs.open(csv_path, "w", encoding="utf-8-sig") as f:
            f.writelines(new_csv_lines)

    print "\nVinculacion completada con exito. Capas de puntos, nodos, CSV y GeoJSON actualizadas."
    return True

if __name__ == "__main__":
    vias_arg = sys.argv[1] if len(sys.argv) > 1 else None
    vincular(vias_arg)
