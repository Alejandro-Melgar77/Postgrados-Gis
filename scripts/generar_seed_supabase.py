# -*- coding: utf-8 -*-
"""
================================================================================
SCRIPT: generar_seed_supabase.py
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
OBJETIVO: Leer el archivo GeoJSON validado desde ArcMap 10.8
          (output_postgrados/postgrados_uagrm_web.geojson) y generar el archivo
          SQL de insercion idempotente (database/seed_data.sql) con geometrias
          PostGIS en WGS 84 (EPSG:4326) para Supabase.
COMPATIBILIDAD: Python 2.7 (ArcGIS 10.8) y Python 3.x (sin dependencias externas).
================================================================================
"""

from __future__ import print_function, unicode_literals
import os
import io
import json
import sys

# Compatibilidad de tipos unicode entre Python 2 y Python 3
try:
    UNICODE_TYPE = unicode
except NameError:
    UNICODE_TYPE = str

def escape_sql_str(val):
    """
    Escapa cadenas de texto para insercion segura en PostgreSQL / Supabase.
    Reemplaza comillas simples ' por dos comillas simples ''.
    """
    if val is None:
        return "NULL"
    if isinstance(val, bool):
        return "TRUE" if val else "FALSE"
    if isinstance(val, (int, float)):
        return str(val)
    if not isinstance(val, UNICODE_TYPE):
        val = UNICODE_TYPE(val)
    val_clean = val.replace("'", "''")
    return "'" + val_clean + "'"

def format_number(val, decimals=None):
    """
    Formatea valores numericos (float/int) para SQL.
    """
    if val is None:
        return "0.0"
    try:
        f = float(val)
        if decimals is not None:
            return str(round(f, decimals))
        return str(f)
    except (ValueError, TypeError):
        return "0.0"

# 12 Servicios de apoyo y seguridad referenciales (Requisito #22)
SERVICIOS_APOYO = [
    {
        "id_serv": "SERV-01",
        "nombre": "Seguro Social Universitario (SSU) - Sede Central",
        "tipo": "Centro_Medico",
        "campus": "Zona Central",
        "referencia": "Calle Campero esq. Av. Irala (próximo a Rectorado UAGRM)",
        "horario": "L-D 24 Horas (Emergencias) / L-V 07:30-19:00",
        "es_referencial": True,
        "lon": -63.18120,
        "lat": -17.79230
    },
    {
        "id_serv": "SERV-02",
        "nombre": "Gabinete Médico y Enfermería Ciudad Universitaria",
        "tipo": "Centro_Medico",
        "campus": "Ciudad Universitaria",
        "referencia": "Planta Baja Módulo 212 (Frente a Politécnica), atención primaria",
        "horario": "L-V 08:00-18:00",
        "es_referencial": True,
        "lon": -63.19435,
        "lat": -17.77535
    },
    {
        "id_serv": "SERV-03",
        "nombre": "Enfermería de Urgencias Médicas - Módulo 280 (FCFB)",
        "tipo": "Centro_Medico",
        "campus": "Ciudad Universitaria",
        "referencia": "Módulo 280 Planta Baja, pasillo central Bioquímica",
        "horario": "L-V 08:00-16:00",
        "es_referencial": True,
        "lon": -63.19110,
        "lat": -17.77675
    },
    {
        "id_serv": "SERV-04",
        "nombre": "Acceso Principal 1: Entrada Vehicular y Peatonal Av. Busch",
        "tipo": "Acceso_Campus",
        "campus": "Ciudad Universitaria",
        "referencia": "Av. Busch y 2do Anillo (Control y caseta de seguridad)",
        "horario": "L-S 06:00-22:30",
        "es_referencial": True,
        "lon": -63.19485,
        "lat": -17.77490
    },
    {
        "id_serv": "SERV-05",
        "nombre": "Acceso Principal 2: Entrada Peatonal y Vehicular Av. Centenario",
        "tipo": "Acceso_Campus",
        "campus": "Campus Universitario",
        "referencia": "Av. Centenario casi 2do Anillo (Acceso a Ciencias Contables y Jurídicas)",
        "horario": "L-S 06:30-22:00",
        "es_referencial": True,
        "lon": -63.19260,
        "lat": -17.77880
    },
    {
        "id_serv": "SERV-06",
        "nombre": "Acceso Secundario 3: Entrada Peatonal Calle México",
        "tipo": "Acceso_Campus",
        "campus": "Campus Universitario",
        "referencia": "Calle México esq. Calle Venezuela (próximo a Humanidades y FCET)",
        "horario": "L-V 07:00-21:00",
        "es_referencial": True,
        "lon": -63.19040,
        "lat": -17.77780
    },
    {
        "id_serv": "SERV-07",
        "nombre": "Extintor Central y Gabinete de Manguera - Módulo 232 (FICCT)",
        "tipo": "Extintor",
        "campus": "Ciudad Universitaria",
        "referencia": "Módulo 232, Hall Principal junto a Laboratorios de Redes y Ciberseguridad",
        "horario": "Permanente (Acceso continuo)",
        "es_referencial": True,
        "lon": -63.19502,
        "lat": -17.77638
    },
    {
        "id_serv": "SERV-08",
        "nombre": "Extintor PQS y Gabinete de Emergencia - Módulo 212 (Politécnica)",
        "tipo": "Extintor",
        "campus": "Ciudad Universitaria",
        "referencia": "Módulo 212, descanso escalera 2do piso (Talleres de Automatización)",
        "horario": "Permanente (Acceso continuo)",
        "es_referencial": True,
        "lon": -63.19455,
        "lat": -17.77525
    },
    {
        "id_serv": "SERV-09",
        "nombre": "Extintor Químico Seco y Alarma - Módulo 247 (Veterinaria)",
        "tipo": "Extintor",
        "campus": "Ciudad Universitaria",
        "referencia": "Módulo 247, pasillo de Quirófanos y Aulas de Postgrado",
        "horario": "Permanente (Acceso continuo)",
        "es_referencial": True,
        "lon": -63.19575,
        "lat": -17.77700
    },
    {
        "id_serv": "SERV-10",
        "nombre": "Extintor CO2 / PQS Industrial - Módulo 280 (Farmacia y Bioquímica)",
        "tipo": "Extintor",
        "campus": "Ciudad Universitaria",
        "referencia": "Módulo 280, sector laboratorios de microbiología y toxicología",
        "horario": "Permanente (Acceso continuo)",
        "es_referencial": True,
        "lon": -63.19088,
        "lat": -17.77662
    },
    {
        "id_serv": "SERV-11",
        "nombre": "Punto de Encuentro 1: Plaza Cívica y Canchas Ciudad Universitaria",
        "tipo": "Punto_Encuentro",
        "campus": "Ciudad Universitaria",
        "referencia": "Área abierta frente a Módulos 232 (FICCT) y 236, zona libre de tendido eléctrico",
        "horario": "Permanente (Área abierta 24/7)",
        "es_referencial": True,
        "lon": -63.19470,
        "lat": -17.77610
    },
    {
        "id_serv": "SERV-12",
        "nombre": "Punto de Encuentro 2: Explanada Central Campus Universitario",
        "tipo": "Punto_Encuentro",
        "campus": "Campus Universitario",
        "referencia": "Patio central entre Facultad de Humanidades y Ciencias Contables",
        "horario": "Permanente (Área abierta 24/7)",
        "es_referencial": True,
        "lon": -63.19150,
        "lat": -17.77820
    }
]

def generar_seed():
    # 1. Definir rutas relativas dinámicas
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    geojson_path = os.path.join(project_root, "output_postgrados", "postgrados_uagrm_web.geojson")
    db_dir = os.path.join(project_root, "database")
    out_sql_path = os.path.join(db_dir, "seed_data.sql")

    if not os.path.exists(geojson_path):
        print("ERROR: No se encontro el archivo GeoJSON en: " + geojson_path)
        sys.exit(1)

    if not os.path.exists(db_dir):
        os.makedirs(db_dir)

    print("======================================================================")
    print("GENERADOR DE SEED DATA SUPABASE (POSTGRESQL + POSTGIS)")
    print("Leyendo GeoJSON: " + geojson_path)
    print("======================================================================")

    # 2. Cargar GeoJSON en UTF-8
    with io.open(geojson_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    features = data.get("features", [])
    print("Features encontrados: %d" % len(features))

    sql_lines = []
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)")
    sql_lines.append("-- CAPA: Fase 1 - Capa de Base de Datos Espacial (Supabase / PostGIS)")
    sql_lines.append("-- ARCHIVO: database/seed_data.sql")
    sql_lines.append("-- DESCRIPCION: Seed data idempotente generado desde postgrados_uagrm_web.geojson")
    sql_lines.append("--              Incluye 19 Unidades de Postgrado y 12 Servicios de Apoyo.")
    sql_lines.append("-- ============================================================================")
    sql_lines.append("")
    sql_lines.append("-- Desactivar temporalmente ecos innecesarios en consolas interactivas")
    sql_lines.append("SET client_encoding = 'UTF8';")
    sql_lines.append("")

    # 3. Bloque INSERT para public.postgrados_uagrm
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 1. INSERT IDEMPOTENTE: public.postgrados_uagrm (19 registros)")
    sql_lines.append("-- ============================================================================")

    for feat in features:
        props = feat.get("properties", {})
        geom = feat.get("geometry", {})
        coords = geom.get("coordinates", [0.0, 0.0])

        lon_edif = coords[0] if len(coords) > 0 else props.get("lon_wgs84", 0.0)
        lat_edif = coords[1] if len(coords) > 1 else props.get("lat_wgs84", 0.0)
        lon_ruta = props.get("lon_ruta", lon_edif)
        lat_ruta = props.get("lat_ruta", lat_edif)

        id_postg = escape_sql_str(props.get("id_postg"))
        cod_fac = escape_sql_str(props.get("cod_fac"))
        nom_unidad = escape_sql_str(props.get("nom_unidad"))
        nom_facult = escape_sql_str(props.get("nom_facult"))
        tipo_ent = escape_sql_str(props.get("tipo_ent"))
        ambito = escape_sql_str(props.get("ambito"))
        municipio = escape_sql_str(props.get("municipio"))
        campus = escape_sql_str(props.get("campus"))
        modulo_pab = escape_sql_str(props.get("modulo_pab"))
        direccion = escape_sql_str(props.get("direccion"))
        lat_wgs84 = format_number(lat_edif)
        lon_wgs84 = format_number(lon_edif)
        lat_ruta_str = format_number(lat_ruta)
        lon_ruta_str = format_number(lon_ruta)
        dist_via_m = format_number(props.get("dist_via_m", 0.0), 2)
        telefono = escape_sql_str(props.get("telefono"))
        correo = escape_sql_str(props.get("correo"))
        horario = escape_sql_str(props.get("horario"))
        estado_geo = escape_sql_str(props.get("estado_geo", "Verificado"))
        cod_qr = escape_sql_str(props.get("cod_qr"))
        area_m2 = format_number(props.get("area_m2", 0.0), 2)
        programas = escape_sql_str(props.get("programas"))
        sitio_web = escape_sql_str(props.get("sitio_web"))
        url_foto = escape_sql_str(props.get("url_foto"))

        geom_sql = "ST_SetSRID(ST_MakePoint(%s, %s), 4326)" % (lon_wgs84, lat_wgs84)
        geom_acceso_sql = "ST_SetSRID(ST_MakePoint(%s, %s), 4326)" % (lon_ruta_str, lat_ruta_str)

        stmt = (
            "INSERT INTO public.postgrados_uagrm (\n"
            "    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,\n"
            "    ambito, municipio, campus, modulo_pab, direccion,\n"
            "    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,\n"
            "    telefono, correo, horario, estado_geo, cod_qr,\n"
            "    area_m2, programas, sitio_web, url_foto, geom, geom_acceso\n"
            ") VALUES (\n"
            "    %(id_postg)s, %(cod_fac)s, %(nom_unidad)s, %(nom_facult)s, %(tipo_ent)s,\n"
            "    %(ambito)s, %(municipio)s, %(campus)s, %(modulo_pab)s, %(direccion)s,\n"
            "    %(lat_wgs84)s, %(lon_wgs84)s, %(lat_ruta)s, %(lon_ruta)s, %(dist_via_m)s,\n"
            "    %(telefono)s, %(correo)s, %(horario)s, %(estado_geo)s, %(cod_qr)s,\n"
            "    %(area_m2)s, %(programas)s, %(sitio_web)s, %(url_foto)s,\n"
            "    %(geom)s, %(geom_acceso)s\n"
            ")\n"
            "ON CONFLICT (id_postg) DO UPDATE SET\n"
            "    cod_fac = EXCLUDED.cod_fac,\n"
            "    nom_unidad = EXCLUDED.nom_unidad,\n"
            "    nom_facult = EXCLUDED.nom_facult,\n"
            "    tipo_ent = EXCLUDED.tipo_ent,\n"
            "    ambito = EXCLUDED.ambito,\n"
            "    municipio = EXCLUDED.municipio,\n"
            "    campus = EXCLUDED.campus,\n"
            "    modulo_pab = EXCLUDED.modulo_pab,\n"
            "    direccion = EXCLUDED.direccion,\n"
            "    lat_wgs84 = EXCLUDED.lat_wgs84,\n"
            "    lon_wgs84 = EXCLUDED.lon_wgs84,\n"
            "    lat_ruta = EXCLUDED.lat_ruta,\n"
            "    lon_ruta = EXCLUDED.lon_ruta,\n"
            "    dist_via_m = EXCLUDED.dist_via_m,\n"
            "    telefono = EXCLUDED.telefono,\n"
            "    correo = EXCLUDED.correo,\n"
            "    horario = EXCLUDED.horario,\n"
            "    estado_geo = EXCLUDED.estado_geo,\n"
            "    cod_qr = EXCLUDED.cod_qr,\n"
            "    area_m2 = EXCLUDED.area_m2,\n"
            "    programas = EXCLUDED.programas,\n"
            "    sitio_web = EXCLUDED.sitio_web,\n"
            "    url_foto = EXCLUDED.url_foto,\n"
            "    geom = EXCLUDED.geom,\n"
            "    geom_acceso = EXCLUDED.geom_acceso,\n"
            "    updated_at = NOW();\n"
        ) % {
            "id_postg": id_postg,
            "cod_fac": cod_fac,
            "nom_unidad": nom_unidad,
            "nom_facult": nom_facult,
            "tipo_ent": tipo_ent,
            "ambito": ambito,
            "municipio": municipio,
            "campus": campus,
            "modulo_pab": modulo_pab,
            "direccion": direccion,
            "lat_wgs84": lat_wgs84,
            "lon_wgs84": lon_wgs84,
            "lat_ruta": lat_ruta_str,
            "lon_ruta": lon_ruta_str,
            "dist_via_m": dist_via_m,
            "telefono": telefono,
            "correo": correo,
            "horario": horario,
            "estado_geo": estado_geo,
            "cod_qr": cod_qr,
            "area_m2": area_m2,
            "programas": programas,
            "sitio_web": sitio_web,
            "url_foto": url_foto,
            "geom": geom_sql,
            "geom_acceso": geom_acceso_sql
        }
        sql_lines.append(stmt)

    # 4. Bloque INSERT para public.servicios_apoyo
    sql_lines.append("-- ============================================================================")
    sql_lines.append("-- 2. INSERT IDEMPOTENTE: public.servicios_apoyo (12 registros referenciales)")
    sql_lines.append("-- ============================================================================")

    for serv in SERVICIOS_APOYO:
        id_serv = escape_sql_str(serv["id_serv"])
        nombre = escape_sql_str(serv["nombre"])
        tipo = escape_sql_str(serv["tipo"])
        campus = escape_sql_str(serv["campus"])
        referencia = escape_sql_str(serv["referencia"])
        horario = escape_sql_str(serv["horario"])
        es_referencial = "TRUE" if serv["es_referencial"] else "FALSE"
        lon_s = format_number(serv["lon"])
        lat_s = format_number(serv["lat"])
        geom_s = "ST_SetSRID(ST_MakePoint(%s, %s), 4326)" % (lon_s, lat_s)

        stmt_serv = (
            "INSERT INTO public.servicios_apoyo (\n"
            "    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom\n"
            ") VALUES (\n"
            "    %(id_serv)s, %(nombre)s, %(tipo)s, %(campus)s, %(referencia)s, %(horario)s, %(es_ref)s, %(geom)s\n"
            ")\n"
            "ON CONFLICT (id_serv) DO UPDATE SET\n"
            "    nombre = EXCLUDED.nombre,\n"
            "    tipo = EXCLUDED.tipo,\n"
            "    campus = EXCLUDED.campus,\n"
            "    referencia = EXCLUDED.referencia,\n"
            "    horario = EXCLUDED.horario,\n"
            "    es_referencial = EXCLUDED.es_referencial,\n"
            "    geom = EXCLUDED.geom,\n"
            "    updated_at = NOW();\n"
        ) % {
            "id_serv": id_serv,
            "nombre": nombre,
            "tipo": tipo,
            "campus": campus,
            "referencia": referencia,
            "horario": horario,
            "es_ref": es_referencial,
            "geom": geom_s
        }
        sql_lines.append(stmt_serv)

    # 5. Escribir archivo de salida en UTF-8 limpio
    content = "\n".join(sql_lines)
    with io.open(out_sql_path, "w", encoding="utf-8") as f:
        f.write(content)

    print("Archivo SQL generado con exito: " + out_sql_path)
    print("Registros de postgrado procesados: %d" % len(features))
    print("Registros de servicios de apoyo procesados: %d" % len(SERVICIOS_APOYO))
    print("Seed SQL listo para ejecutar en Supabase.")

if __name__ == "__main__":
    generar_seed()
