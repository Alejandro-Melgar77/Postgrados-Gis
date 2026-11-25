-- ============================================================================
-- PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
-- CAPA: Fase 1 - Capa de Base de Datos Espacial (Supabase / PostGIS)
-- ARCHIVO: database/verify_postgis.sql
-- DESCRIPCION: Script de verificacion espacial para el SQL Editor de Supabase.
--              Contiene 4 consultas clave de validacion PostGIS y atributos.
-- ============================================================================

-- ============================================================================
-- PRUEBA 1: Verificar instalacion y version completa de la extension PostGIS
-- ============================================================================
SELECT PostGIS_Full_Version();

-- ============================================================================
-- PRUEBA 2: Conteo de registros y verificacion de integridad UTF-8 (tildes y eñes)
--           Deben ser exactamente 19 postgrados y 12 servicios de apoyo.
-- ============================================================================
-- 2.1 Conteo general de tablas
SELECT 'postgrados_uagrm' AS tabla, COUNT(*) AS total_registros 
FROM public.postgrados_uagrm
UNION ALL
SELECT 'servicios_apoyo' AS tabla, COUNT(*) AS total_registros 
FROM public.servicios_apoyo;

-- 2.2 Verificacion visual de caracteres especiales (Dirección, Auditoría, Hábitat, etc.)
SELECT 
    id_postg,
    cod_fac,
    nom_unidad,
    nom_facult,
    direccion,
    municipio,
    estado_geo
FROM public.postgrados_uagrm
WHERE id_postg IN ('PG-00', 'PG-03', 'PG-04', 'PG-12', 'PG-18')
ORDER BY id_postg;

-- ============================================================================
-- PRUEBA 3: Salida GeoJSON nativa (EPSG:4326) para integracion con visores web
--           Filtro por codigo QR unico: 'UAGRM-PG-FICCT'
-- ============================================================================
SELECT 
    id_postg,
    cod_qr,
    nom_unidad,
    lat_wgs84,
    lon_wgs84,
    dist_via_m,
    ST_AsGeoJSON(geom)::json AS geojson_edificio,
    ST_AsGeoJSON(geom_acceso)::json AS geojson_nodo_acceso
FROM public.postgrados_uagrm
WHERE cod_qr = 'UAGRM-PG-FICCT';

-- ============================================================================
-- PRUEBA 4: Analisis espacial real con ST_DWithin y ST_Distance (Geography)
--           Servicios de apoyo ubicados a un radio <= 600 metros de la FICCT (PG-16)
--           ordenados por proximidad metrica.
-- ============================================================================
SELECT 
    s.id_serv,
    s.nombre,
    s.tipo,
    s.campus,
    s.referencia,
    s.es_referencial,
    ROUND(ST_Distance(s.geom::geography, p.geom::geography)::numeric, 2) AS dist_a_ficct_metros
FROM public.servicios_apoyo s
CROSS JOIN (
    SELECT geom 
    FROM public.postgrados_uagrm 
    WHERE id_postg = 'PG-16' -- UAGRM School of Engineering (FICCT)
) p
WHERE ST_DWithin(s.geom::geography, p.geom::geography, 600)
ORDER BY dist_a_ficct_metros ASC;
