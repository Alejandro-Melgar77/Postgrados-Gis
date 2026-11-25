-- ============================================================================
-- PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
-- CAPA: Fase 1 - Capa de Base de Datos Espacial (Supabase / PostGIS)
-- ARCHIVO: database/schema.sql
-- DESCRIPCION: Esquema DDL idempotente para PostgreSQL 15+ con PostGIS en Supabase.
-- AUTOR: Ingeniero de Bases de Datos Espaciales
-- ============================================================================

-- 1. Habilitar la extension PostGIS para tipos geometricos y analisis espacial
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================================
-- 2. TABLA PRINCIPAL: public.postgrados_uagrm
--    Almacena las 19 unidades de postgrado UAGRM validadas cartograficamente.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.postgrados_uagrm (
    -- Clave primaria alfanumerica estandarizada (PG-00 a PG-18)
    id_postg        VARCHAR(10) PRIMARY KEY,

    -- Atributos facultativos e institucionales
    cod_fac         VARCHAR(12) NOT NULL,
    nom_unidad      VARCHAR(120) NOT NULL,
    nom_facult      VARCHAR(120) NOT NULL,
    tipo_ent        VARCHAR(25) NOT NULL,
    ambito          VARCHAR(15) NOT NULL,
    municipio       VARCHAR(40) NOT NULL,
    campus          VARCHAR(40) NOT NULL,
    modulo_pab      VARCHAR(50),
    direccion       VARCHAR(150),

    -- Coordenadas geograficas de origen (WGS 84 - EPSG:4326)
    lat_wgs84       DOUBLE PRECISION NOT NULL,
    lon_wgs84       DOUBLE PRECISION NOT NULL,

    -- Coordenadas del nodo de acceso vial (Snapping en calzada para ruteo)
    lat_ruta        DOUBLE PRECISION NOT NULL,
    lon_ruta        DOUBLE PRECISION NOT NULL,
    dist_via_m      NUMERIC(8, 2) DEFAULT 0.0,

    -- Informacion de contacto y atencion
    telefono        VARCHAR(40),
    correo          VARCHAR(80),
    horario         VARCHAR(60),

    -- Control de calidad cartografica y acceso web/movil
    estado_geo      VARCHAR(20) DEFAULT 'Verificado',
    cod_qr          VARCHAR(30) UNIQUE NOT NULL,
    area_m2         NUMERIC(10, 2) DEFAULT 0.0,
    programas       TEXT,
    sitio_web       VARCHAR(150),
    url_foto        VARCHAR(150),

    -- Columnas Geometricas PostGIS en WGS 84 (EPSG:4326)
    geom            geometry(Point, 4326) NOT NULL,
    geom_acceso     geometry(Point, 4326) NOT NULL,
    geom_poly       geometry(Polygon, 4326),

    -- Auditoria
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 3. TABLA COMPLEMENTARIA: public.servicios_apoyo
--    Cumple Requisito #22: Extintores, centros medicos, accesos y puntos de encuentro.
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.servicios_apoyo (
    id_serv         VARCHAR(15) PRIMARY KEY,
    nombre          VARCHAR(120) NOT NULL,
    tipo            VARCHAR(30) NOT NULL CHECK (tipo IN ('Centro_Medico', 'Extintor', 'Acceso_Campus', 'Punto_Encuentro')),
    campus          VARCHAR(60),
    referencia      VARCHAR(150),
    horario         VARCHAR(60),
    es_referencial  BOOLEAN DEFAULT TRUE,
    geom            geometry(Point, 4326) NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 4. INDICES ESPACIALES (GIST) Y ALFANUMERICOS (B-TREE)
-- ============================================================================
-- Indices espaciales GiST para consultas geometricas aceleradas (ST_DWithin, ST_Intersects, ST_Distance)
CREATE INDEX IF NOT EXISTS idx_postgrados_geom 
    ON public.postgrados_uagrm USING GIST (geom);

CREATE INDEX IF NOT EXISTS idx_postgrados_geom_acceso 
    ON public.postgrados_uagrm USING GIST (geom_acceso);

CREATE INDEX IF NOT EXISTS idx_postgrados_geom_poly 
    ON public.postgrados_uagrm USING GIST (geom_poly);

CREATE INDEX IF NOT EXISTS idx_servicios_apoyo_geom 
    ON public.servicios_apoyo USING GIST (geom);

-- Indices B-Tree para filtros frecuentes en API y WebGIS
CREATE INDEX IF NOT EXISTS idx_postgrados_ambito 
    ON public.postgrados_uagrm (ambito);

CREATE INDEX IF NOT EXISTS idx_postgrados_cod_fac 
    ON public.postgrados_uagrm (cod_fac);

CREATE INDEX IF NOT EXISTS idx_servicios_apoyo_tipo 
    ON public.servicios_apoyo (tipo);

-- ============================================================================
-- 5. SEGURIDAD: ROW LEVEL SECURITY (RLS) EN SUPABASE
--    Lectura publica para clientes web/moviles anonimos y autenticados.
--    Escritura restringida a conexiones de servicio / backend (FastAPI pooler).
-- ============================================================================
-- Conceder privilegios de esquema y lectura a los roles anon y authenticated
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO anon, authenticated;

ALTER TABLE public.postgrados_uagrm ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.servicios_apoyo ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Permitir lectura publica a postgrados" ON public.postgrados_uagrm;
CREATE POLICY "Permitir lectura publica a postgrados"
    ON public.postgrados_uagrm
    FOR SELECT
    TO anon, authenticated
    USING (true);

DROP POLICY IF EXISTS "Permitir lectura publica a servicios" ON public.servicios_apoyo;
CREATE POLICY "Permitir lectura publica a servicios"
    ON public.servicios_apoyo
    FOR SELECT
    TO anon, authenticated
    USING (true);

-- ============================================================================
-- 6. COMENTARIOS METADATA POSTGIS / SUPABASE
-- ============================================================================
COMMENT ON TABLE public.postgrados_uagrm IS 'Capa 8: Unidades y Escuelas de Postgrado UAGRM (19 centros) con nodos de acceso y huellas espaciales.';
COMMENT ON COLUMN public.postgrados_uagrm.geom IS 'Geometria del edificio en EPSG:4326 (WGS 84).';
COMMENT ON COLUMN public.postgrados_uagrm.geom_acceso IS 'Nodo de acceso a la red vial para ruteo (snapped al eje de calzada).';
COMMENT ON COLUMN public.postgrados_uagrm.geom_poly IS 'Poligono con la huella digitalizada de la unidad de postgrado.';
COMMENT ON TABLE public.servicios_apoyo IS 'Servicios de apoyo y seguridad universitaria: Centros medicos, extintores, accesos y puntos de encuentro.';
