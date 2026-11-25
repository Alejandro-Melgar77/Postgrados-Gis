# -*- coding: utf-8 -*-
import arcpy, os

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

def build_referential_network():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    out_dir = os.path.join(project_root, "output_postgrados")
    shp_name = "red_vial_uagrm_referencial.shp"
    shp_path = os.path.join(out_dir, shp_name)

    sr_wgs84 = arcpy.SpatialReference(4326)
    sr_utm20s = arcpy.SpatialReference()
    sr_utm20s.loadFromString(ESRI_WKT1_UTM20S)

    if arcpy.Exists(shp_path):
        arcpy.Delete_management(shp_path)

    arcpy.CreateFeatureclass_management(out_dir, shp_name, "POLYLINE", spatial_reference=sr_utm20s)
    arcpy.AddField_management(shp_path, "nom_via", "TEXT", field_length=100)
    arcpy.AddField_management(shp_path, "tipo_via", "TEXT", field_length=30)
    arcpy.AddField_management(shp_path, "jerarquia", "TEXT", field_length=30)

    with open(os.path.join(out_dir, "red_vial_uagrm_referencial.cpg"), "w") as f:
        f.write("UTF-8")
    with open(os.path.join(out_dir, "red_vial_uagrm_referencial.prj"), "w") as f:
        f.write(ESRI_WKT1_UTM20S)

    # Ejes viales estructurantes de la zona universitaria y centros de postgrado UAGRM (WGS 84 coords)
    VIAS = [
        {
            "nom_via": u"Av. Busch (Eje Ciudad Universitaria)",
            "tipo_via": "Avenida",
            "jerarquia": "Principal",
            "puntos": [(-63.19000, -17.78100), (-63.19350, -17.77700), (-63.19550, -17.77450), (-63.19750, -17.77150)]
        },
        {
            "nom_via": u"Av. Centenario (Eje Campus Universitario)",
            "tipo_via": "Avenida",
            "jerarquia": "Principal",
            "puntos": [(-63.19050, -17.78050), (-63.19250, -17.77880), (-63.19450, -17.77680), (-63.19700, -17.77400)]
        },
        {
            "nom_via": u"Av. 26 de Febrero (Segundo Anillo Oeste)",
            "tipo_via": "Avenida",
            "jerarquia": "Anillo_Troncal",
            "puntos": [(-63.19700, -17.77350), (-63.19550, -17.77650), (-63.19350, -17.77950)]
        },
        {
            "nom_via": u"Av. Irala (Primer Anillo Sur)",
            "tipo_via": "Avenida",
            "jerarquia": "Anillo_Troncal",
            "puntos": [(-63.18600, -17.79400), (-63.18180, -17.79280), (-63.17800, -17.79150)]
        },
        {
            "nom_via": u"Calle México (Campus Universitario)",
            "tipo_via": "Calle_Interna",
            "jerarquia": "Secundaria",
            "puntos": [(-63.19150, -17.77700), (-63.19040, -17.77800), (-63.18950, -17.77900)]
        },
        {
            "nom_via": u"Calle Venezuela (Campus Universitario)",
            "tipo_via": "Calle_Interna",
            "jerarquia": "Secundaria",
            "puntos": [(-63.19200, -17.77820), (-63.19040, -17.77790), (-63.18900, -17.77750)]
        },
        {
            "nom_via": u"Av. Cristóbal de Mendoza (Segundo Anillo Norte)",
            "tipo_via": "Avenida",
            "jerarquia": "Anillo_Troncal",
            "puntos": [(-63.17200, -17.77250), (-63.16670, -17.77360), (-63.16100, -17.77500)]
        },
        {
            "nom_via": u"Av. San Martín (Equipetrol)",
            "tipo_via": "Avenida",
            "jerarquia": "Principal",
            "puntos": [(-63.19300, -17.77300), (-63.19200, -17.77000), (-63.19100, -17.76700)]
        },
        {
            "nom_via": u"Calle Bolívar (Centro Histórico)",
            "tipo_via": "Calle",
            "jerarquia": "Secundaria",
            "puntos": [(-63.18200, -17.78450), (-63.17820, -17.78340), (-63.17500, -17.78250)]
        },
        {
            "nom_via": u"Calle Gral. Agustín Saavedra / Chuquisaca",
            "tipo_via": "Calle",
            "jerarquia": "Secundaria",
            "puntos": [(-63.18100, -17.79150), (-63.17890, -17.79030), (-63.17650, -17.78950)]
        }
    ]

    with arcpy.da.InsertCursor(shp_path, ["SHAPE@", "nom_via", "tipo_via", "jerarquia"]) as cur:
        for v in VIAS:
            pt_array = arcpy.Array()
            for lon, lat in v["puntos"]:
                pt_w = arcpy.Point(lon, lat)
                geom_w = arcpy.PointGeometry(pt_w, sr_wgs84)
                geom_u = geom_w.projectAs(sr_utm20s)
                pt_array.add(geom_u.firstPoint)
            polyline = arcpy.Polyline(pt_array, sr_utm20s)
            cur.insertRow([polyline, v["nom_via"], v["tipo_via"], v["jerarquia"]])

    # Copiar a Geodatabase
    gdb_path = os.path.join(out_dir, "postgrados_uagrm.gdb")
    gdb_vias = os.path.join(gdb_path, "red_vial_uagrm_referencial")
    if arcpy.Exists(gdb_vias): arcpy.Delete_management(gdb_vias)
    arcpy.CopyFeatures_management(shp_path, gdb_vias)
    arcpy.AlterField_management(gdb_vias, "nom_via", new_field_alias=u"Nombre de la Vía")
    arcpy.AlterField_management(gdb_vias, "tipo_via", new_field_alias=u"Tipo de Calzada")
    arcpy.AlterField_management(gdb_vias, "jerarquia", new_field_alias=u"Jerarquía Vial")

    print "Capa de red vial referencial creada exitosamente: %s" % shp_path

if __name__ == "__main__":
    build_referential_network()
