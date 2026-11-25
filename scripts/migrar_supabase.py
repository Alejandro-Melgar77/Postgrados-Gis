# -*- coding: utf-8 -*-
"""
================================================================================
SCRIPT: migrar_supabase.py
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
OBJETIVO: Conectar directamente a Supabase PostgreSQL y ejecutar:
          1. database/schema.sql (DDL + PostGIS + Tablas + Indices + RLS)
          2. database/seed_data.sql (DML 19 postgrados + 12 servicios de apoyo)
          3. database/verify_postgis.sql (Verificacion espacial y conteo)
================================================================================
"""

from __future__ import print_function, unicode_literals
import os
import io
import ssl
import json
import pg8000.native

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    db_dir = os.path.join(project_root, "database")

    schema_path = os.path.join(db_dir, "schema.sql")
    seed_path = os.path.join(db_dir, "seed_data.sql")
    verify_path = os.path.join(db_dir, "verify_postgis.sql")

    # Leer variables de entorno o valores de conexion
    host = "db.woyjgoxglpsjrqpwhuzd.supabase.co"
    port = 5432
    user = "postgres"
    password = "4L1Bto2UxDKzTcLX"
    database = "postgres"

    print("======================================================================")
    print("MIGRACION DIRECTA A SUPABASE (POSTGRESQL 17 + POSTGIS)")
    print("Host: %s:%d | BD: %s" % (host, port, database))
    print("======================================================================")

    ssl_context = ssl.create_default_context()
    ssl_context.check_hostname = False
    ssl_context.verify_mode = ssl.CERT_NONE

    print("[1/4] Estableciendo conexion segura SSL con Supabase...")
    conn = pg8000.native.Connection(
        user=user,
        host=host,
        port=port,
        database=database,
        password=password,
        ssl_context=ssl_context
    )
    print("      -> Conexion establecida con exito.")

    # 1. Ejecutar schema.sql
    print("\n[2/4] Ejecutando database/schema.sql (PostGIS, DDL, Indices, RLS)...")
    with io.open(schema_path, "r", encoding="utf-8") as f:
        schema_sql = f.read()

    conn.run(schema_sql)
    print("      -> Esquema creado exitosamente.")

    # 2. Ejecutar seed_data.sql
    print("\n[3/4] Ejecutando database/seed_data.sql (19 postgrados + 12 servicios)...")
    with io.open(seed_path, "r", encoding="utf-8") as f:
        seed_sql = f.read()

    conn.run(seed_sql)
    print("      -> Datos semilla insertados/actualizados exitosamente.")

    # 3. Verificaciones espaciales
    print("\n[4/4] Ejecutando verificacion espacial en Supabase...")

    # Prueba 1: PostGIS version
    v_res = conn.run("SELECT PostGIS_Full_Version();")
    print("\n>>> PRUEBA 1: Extension PostGIS Activa:")
    print("   ", v_res[0][0][:100] + "...")

    # Prueba 2: Conteo de registros
    count_res = conn.run("""
        SELECT 'postgrados_uagrm' AS tabla, COUNT(*) AS total FROM public.postgrados_uagrm
        UNION ALL
        SELECT 'servicios_apoyo' AS tabla, COUNT(*) AS total FROM public.servicios_apoyo;
    """)
    print("\n>>> PRUEBA 2: Conteo de Registros:")
    for row in count_res:
        print("    - Tabla %s: %d registros" % (row[0], row[1]))

    # Prueba 2.1: Muestra con caracteres especiales
    sample_res = conn.run("""
        SELECT id_postg, cod_fac, nom_unidad, direccion, municipio
        FROM public.postgrados_uagrm
        WHERE id_postg IN ('PG-00', 'PG-03', 'PG-04', 'PG-12', 'PG-18')
        ORDER BY id_postg;
    """)
    print("\n>>> PRUEBA 2.1: Integridad UTF-8 (Tildes y Enes):")
    for row in sample_res:
        print("    [%s] %s | %s | %s" % (row[0], row[1], row[2], row[3]))

    # Prueba 3: Salida GeoJSON para FICCT
    geojson_res = conn.run("""
        SELECT id_postg, cod_qr, nom_unidad,
               ST_AsGeoJSON(geom) AS geom_json,
               ST_AsGeoJSON(geom_acceso) AS acceso_json
        FROM public.postgrados_uagrm
        WHERE cod_qr = 'UAGRM-PG-FICCT';
    """)
    print("\n>>> PRUEBA 3: Salida GeoJSON Nativa para FICCT (UAGRM-PG-FICCT):")
    for row in geojson_res:
        print("    ID: %s | QR: %s" % (row[0], row[1]))
        print("    Nombre: %s" % row[2])
        print("    Geom Edificio: %s" % row[3])
        print("    Geom Acceso:   %s" % row[4])

    # Prueba 4: ST_DWithin 600m
    dwithin_res = conn.run("""
        SELECT s.id_serv, s.nombre, s.tipo,
               ROUND(ST_Distance(s.geom::geography, p.geom::geography)::numeric, 2) AS dist_m
        FROM public.servicios_apoyo s
        CROSS JOIN (
            SELECT geom FROM public.postgrados_uagrm WHERE id_postg = 'PG-16'
        ) p
        WHERE ST_DWithin(s.geom::geography, p.geom::geography, 600)
        ORDER BY dist_m ASC;
    """)
    print("\n>>> PRUEBA 4: Analisis Espacial ST_DWithin (Radio <= 600m de FICCT):")
    for row in dwithin_res:
        print("    - [%s] %s (%s) -> %s metros" % (row[0], row[1], row[2], str(row[3])))

    conn.close()
    print("\n======================================================================")
    print("MIGRACION Y VERIFICACION COMPLETADAS AL 100% EN SUPABASE")
    print("======================================================================")

if __name__ == "__main__":
    main()
