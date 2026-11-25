# -*- coding: utf-8 -*-
"""
================================================================================
MODULO: backend/main.py
PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
DESCRIPCION: API Backend REST / WebGIS desarrollada con FastAPI y PostGIS.
             Provee endpoints espaciales optimizados con ST_AsGeoJSON,
             ST_DWithin y ST_Distance para visores web y consultas moviles.
================================================================================
"""

import os
from typing import Optional, List, Dict, Any
from fastapi import FastAPI, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from db import get_db_cursor, query_all, query_one

# ------------------------------------------------------------------------------
# 1. INICIALIZACION DE LA APLICACION FASTAPI
# ------------------------------------------------------------------------------
app = FastAPI(
    title="API SIG Postgrados UAGRM",
    version="1.0.0",
    description=(
        "Servicio de API WebGIS para la visualización, ruteo y consulta espacial "
        "de las 19 Unidades de Postgrado de la UAGRM y sus servicios de apoyo. "
        "Conectado a PostgreSQL 17 + PostGIS en Supabase y desplegado en Render."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
)

# ------------------------------------------------------------------------------
# 2. CONFIGURACION DE CORS
# ------------------------------------------------------------------------------
cors_env = os.getenv("CORS_ORIGINS", "*").strip()
if cors_env == "*" or not cors_env:
    allow_origins = ["*"]
else:
    allow_origins = [orig.strip() for orig in cors_env.split(",") if orig.strip()]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ------------------------------------------------------------------------------
# 3. FUNCIONES AUXILIARES PARA FORMATO GEOJSON
# ------------------------------------------------------------------------------
def build_feature(feature_id: str, geometry: Any, properties: Dict[str, Any]) -> Dict[str, Any]:
    """Construye un objeto GeoJSON Feature estándar."""
    return {
        "type": "Feature",
        "id": feature_id,
        "geometry": geometry,
        "properties": properties,
    }


def build_feature_collection(features: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Construye un objeto GeoJSON FeatureCollection estándar."""
    return {
        "type": "FeatureCollection",
        "features": features,
    }


# ------------------------------------------------------------------------------
# 4. ENDPOINTS GENERALES Y DE DIAGNOSTICO
# ------------------------------------------------------------------------------
@app.get("/", tags=["General"])
def root():
    """Ruta raíz que confirma el estado de la API y ofrece enlace a la documentación."""
    return {
        "name": "API SIG Postgrados UAGRM",
        "version": "1.0.0",
        "status": "ok",
        "docs": "/docs",
    }


@app.get("/api/health", tags=["Diagnóstico"])
def health_check():
    """
    Verifica la conexión activa con Supabase, obtiene la versión de PostGIS
    y el conteo actual de registros en las tablas espaciales.
    """
    try:
        with get_db_cursor() as cur:
            cur.execute("SELECT PostGIS_Version();")
            pg_ver_row = cur.fetchone()
            postgis_ver = pg_ver_row["postgis_version"] if pg_ver_row else "Desconocida"

            cur.execute("""
                SELECT 'postgrados' AS tabla, COUNT(*) AS total FROM public.postgrados_uagrm
                UNION ALL
                SELECT 'servicios' AS tabla, COUNT(*) AS total FROM public.servicios_apoyo;
            """)
            counts_rows = cur.fetchall()
            counts = {row["tabla"]: row["total"] for row in counts_rows}

        return {
            "status": "ok",
            "database": "connected",
            "postgis_version": postgis_ver,
            "counts": {
                "postgrados": counts.get("postgrados", 0),
                "servicios": counts.get("servicios", 0),
            },
        }
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Fallo en conexión a base de datos espacial: {str(exc)}",
        )


# ------------------------------------------------------------------------------
# 5. ENDPOINTS DE POSTGRADOS (CAPA 8)
# ------------------------------------------------------------------------------
@app.get("/api/postgrados", tags=["Postgrados"])
def listar_postgrados(
    ambito: Optional[str] = Query(None, description="Filtro exacto por ámbito (ej. Urbano, Provincial)"),
    campus: Optional[str] = Query(None, description="Filtro parcial por campus (case-insensitive)"),
    tipo_ent: Optional[str] = Query(None, description="Filtro por tipo de entidad (ej. Rectorado_DGP, Unidad_Facultativa)"),
    q: Optional[str] = Query(None, description="Búsqueda libre por nombre de unidad, facultad, sigla, módulo o dirección"),
):
    """
    Retorna un GeoJSON FeatureCollection con las unidades de postgrado UAGRM.
    Incluye todos los atributos alfanuméricos y la geometría en EPSG:4326 generada por PostGIS.
    """
    conditions = []
    params = []

    if ambito:
        conditions.append("LOWER(ambito) = LOWER(%s)")
        params.append(ambito)

    if campus:
        conditions.append("campus ILIKE %s")
        params.append(f"%{campus}%")

    if tipo_ent:
        conditions.append("LOWER(tipo_ent) = LOWER(%s)")
        params.append(tipo_ent)

    if q:
        q_term = f"%{q}%"
        conditions.append("""(
            nom_unidad ILIKE %s OR 
            nom_facult ILIKE %s OR 
            cod_fac ILIKE %s OR 
            modulo_pab ILIKE %s OR 
            direccion ILIKE %s OR 
            municipio ILIKE %s
        )""")
        params.extend([q_term] * 6)

    where_clause = f" WHERE {' AND '.join(conditions)}" if conditions else ""
    sql = f"""
        SELECT 
            id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent, ambito, municipio,
            campus, modulo_pab, direccion, lat_wgs84, lon_wgs84, lat_ruta, lon_ruta,
            dist_via_m, telefono, correo, horario, estado_geo, cod_qr, area_m2,
            programas, sitio_web, url_foto, updated_at,
            ST_AsGeoJSON(geom)::json AS geometry
        FROM public.postgrados_uagrm
        {where_clause}
        ORDER BY id_postg ASC;
    """

    rows = query_all(sql, tuple(params))
    features = []
    for row in rows:
        geom = row.pop("geometry")
        feat_id = row.get("id_postg")
        features.append(build_feature(feat_id, geom, row))

    return build_feature_collection(features)


@app.get("/api/postgrados/{id_postg}", tags=["Postgrados"])
def obtener_postgrado_por_id(id_postg: str):
    """
    Retorna una única unidad de postgrado como GeoJSON Feature buscando por su id_postg (ej. PG-16).
    """
    sql = """
        SELECT 
            id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent, ambito, municipio,
            campus, modulo_pab, direccion, lat_wgs84, lon_wgs84, lat_ruta, lon_ruta,
            dist_via_m, telefono, correo, horario, estado_geo, cod_qr, area_m2,
            programas, sitio_web, url_foto, updated_at,
            ST_AsGeoJSON(geom)::json AS geometry
        FROM public.postgrados_uagrm
        WHERE LOWER(id_postg) = LOWER(%s)
        LIMIT 1;
    """
    row = query_one(sql, (id_postg,))
    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Postgrado con ID '{id_postg}' no encontrado",
        )

    geom = row.pop("geometry")
    return build_feature(row.get("id_postg"), geom, row)


@app.get("/api/postgrados/qr/{cod_qr}", tags=["Postgrados - QR Móvil"])
def obtener_postgrado_por_qr(cod_qr: str):
    """
    Cumple el Requisito #21: Consulta móvil mediante código QR.
    Busca por cod_qr (ej. UAGRM-PG-FICCT) y retorna el GeoJSON Feature completo.
    """
    sql = """
        SELECT 
            id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent, ambito, municipio,
            campus, modulo_pab, direccion, lat_wgs84, lon_wgs84, lat_ruta, lon_ruta,
            dist_via_m, telefono, correo, horario, estado_geo, cod_qr, area_m2,
            programas, sitio_web, url_foto, updated_at,
            ST_AsGeoJSON(geom)::json AS geometry
        FROM public.postgrados_uagrm
        WHERE LOWER(cod_qr) = LOWER(%s)
        LIMIT 1;
    """
    row = query_one(sql, (cod_qr,))
    if not row:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Postgrado con código QR '{cod_qr}' no encontrado",
        )

    geom = row.pop("geometry")
    return build_feature(row.get("id_postg"), geom, row)


# ------------------------------------------------------------------------------
# 6. ENDPOINTS DE SERVICIOS DE APOYO (REQUISITO #22)
# ------------------------------------------------------------------------------
@app.get("/api/servicios", tags=["Servicios de Apoyo"])
def listar_servicios(
    tipo: Optional[str] = Query(None, description="Filtro opcional: Centro_Medico, Extintor, Acceso_Campus, Punto_Encuentro"),
):
    """
    Retorna un GeoJSON FeatureCollection con los servicios de apoyo y seguridad del campus.
    """
    conditions = []
    params = []

    if tipo:
        conditions.append("LOWER(tipo) = LOWER(%s)")
        params.append(tipo)

    where_clause = f" WHERE {' AND '.join(conditions)}" if conditions else ""
    sql = f"""
        SELECT 
            id_serv, nombre, tipo, campus, referencia, horario, es_referencial, updated_at,
            ST_AsGeoJSON(geom)::json AS geometry
        FROM public.servicios_apoyo
        {where_clause}
        ORDER BY id_serv ASC;
    """

    rows = query_all(sql, tuple(params))
    features = []
    for row in rows:
        geom = row.pop("geometry")
        feat_id = row.get("id_serv")
        features.append(build_feature(feat_id, geom, row))

    return build_feature_collection(features)


@app.get("/api/servicios/cercanos", tags=["Servicios de Apoyo - Análisis Espacial"])
def servicios_cercanos(
    lat: float = Query(..., description="Latitud WGS84 del punto de interés (ej. -17.77631)"),
    lon: float = Query(..., description="Longitud WGS84 del punto de interés (ej. -63.19506)"),
    radio_m: float = Query(500.0, gt=0, le=5000.0, description="Radio de búsqueda métrico (default 500m, máx 5000m)"),
    tipo: Optional[str] = Query(None, description="Filtro opcional por tipo de servicio"),
):
    """
    Cumple el Requisito #22: Análisis de proximidad espacial en PostGIS (ST_DWithin y ST_Distance)
    calculando distancias métricas geodésicas en el esferoide WGS 84.
    Retorna un GeoJSON FeatureCollection ordenado ascendentemente por distancia_m.
    """
    conditions = [
        "ST_DWithin(geom::geography, ST_SetSRID(ST_MakePoint(%s, %s), 4326)::geography, %s)"
    ]
    params = [lon, lat, radio_m]

    if tipo:
        conditions.append("LOWER(tipo) = LOWER(%s)")
        params.append(tipo)

    where_clause = f"WHERE {' AND '.join(conditions)}"
    sql = f"""
        SELECT 
            id_serv, nombre, tipo, campus, referencia, horario, es_referencial, updated_at,
            ST_AsGeoJSON(geom)::json AS geometry,
            ROUND(ST_Distance(geom::geography, ST_SetSRID(ST_MakePoint(%s, %s), 4326)::geography)::numeric, 2) AS distancia_m
        FROM public.servicios_apoyo
        {where_clause}
        ORDER BY distancia_m ASC;
    """
    # Se pasan (lon, lat) para ST_Distance y luego params para WHERE ST_DWithin
    full_params = tuple([lon, lat] + params)

    rows = query_all(sql, full_params)
    features = []
    for row in rows:
        geom = row.pop("geometry")
        feat_id = row.get("id_serv")
        features.append(build_feature(feat_id, geom, row))

    return build_feature_collection(features)


# ------------------------------------------------------------------------------
# 7. ENDPOINT DE RESUMEN Y ESTADISTICAS
# ------------------------------------------------------------------------------
@app.get("/api/resumen", tags=["Estadísticas"])
def obtener_resumen():
    """
    Retorna métricas consolidadas del proyecto para alimentar tarjetas de control y contadores:
    - Total de postgrados, urbanos vs provinciales, estado cartográfico (verificado vs revisar_campo).
    - Total de servicios de apoyo y desglose por tipo.
    """
    sql_postg = """
        SELECT 
            COUNT(*) AS total,
            COUNT(*) FILTER (WHERE LOWER(ambito) = 'urbano') AS urbanos,
            COUNT(*) FILTER (WHERE LOWER(ambito) = 'provincial') AS provinciales,
            COUNT(*) FILTER (WHERE LOWER(estado_geo) = 'verificado') AS verificados,
            COUNT(*) FILTER (WHERE LOWER(estado_geo) = 'revisar_campo') AS revisar_campo
        FROM public.postgrados_uagrm;
    """
    resumen_postg = query_one(sql_postg) or {}

    sql_serv = """
        SELECT tipo, COUNT(*) AS total
        FROM public.servicios_apoyo
        GROUP BY tipo
        ORDER BY tipo;
    """
    servicios_filas = query_all(sql_serv)
    servicios_por_tipo = {row["tipo"]: row["total"] for row in servicios_filas}
    total_servicios = sum(servicios_por_tipo.values())

    return {
        "postgrados": {
            "total": resumen_postg.get("total", 0),
            "urbanos": resumen_postg.get("urbanos", 0),
            "provinciales": resumen_postg.get("provinciales", 0),
            "verificados": resumen_postg.get("verificados", 0),
            "revisar_campo": resumen_postg.get("revisar_campo", 0),
        },
        "servicios": {
            "total": total_servicios,
            "por_tipo": servicios_por_tipo,
        },
    }
