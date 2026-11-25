-- ============================================================================
-- PROYECTO: INF442-SA - Sistemas de Informacion Geografica (UAGRM 2026)
-- CAPA: Fase 1 - Capa de Base de Datos Espacial (Supabase / PostGIS)
-- ARCHIVO: database/seed_data.sql
-- DESCRIPCION: Seed data idempotente generado desde postgrados_uagrm_web.geojson
--              Incluye 19 Unidades de Postgrado y 12 Servicios de Apoyo.
-- ============================================================================

-- Desactivar temporalmente ecos innecesarios en consolas interactivas
SET client_encoding = 'UTF8';

-- ============================================================================
-- 1. INSERT IDEMPOTENTE: public.postgrados_uagrm (19 registros)
-- ============================================================================
INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-00', 'DGP', 'Escuela de Postgrado UAGRM (Dirección General de Posgrado)', 'Rectorado / Dirección General de Posgrado', 'Rectorado_DGP',
    'Urbano', 'Santa Cruz de la Sierra', 'Zona Central', 'Edif. Museo Noel Kempff 5to piso / Pab. 126 Aula 4', 'Av. Irala N° 565, 5to piso',
    -17.79277, -63.18183, -17.7928054, -63.181819, 4.09,
    '3-3342899', 'posgrado@uagrm.edu.bo', 'L-V 08:30-15:30', 'Verificado', 'UAGRM-PG-DGP',
    0.0, 'Doctorados, Maestrías Institucionales, Diplomados en Educación Superior', 'https://posgrado.uagrm.edu.bo', 'assets/fotos/PG-00.jpg',
    ST_SetSRID(ST_MakePoint(-63.18183, -17.79277), 4326), ST_SetSRID(ST_MakePoint(-63.181819, -17.7928054), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-01', 'FICH', 'Unidad de Postgrado FICH', 'Facultad Integral del Chaco', 'Sede_Provincial',
    'Provincial', 'Camiri', 'Sede Provincial', 'Sede FICH', 'Av. Humberto Suárez Roca',
    -20.03331, -63.52794, -20.03331, -63.52794, 0.0,
    '3-9522979', 'postgradofich@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FICH',
    0.0, 'Maestrías en Desarrollo Regional, Diplomados Petroleros y Ambientales', 'https://fich.uagrm.edu.bo', 'assets/fotos/PG-01.jpg',
    ST_SetSRID(ST_MakePoint(-63.52794, -20.03331), 4326), ST_SetSRID(ST_MakePoint(-63.52794, -20.03331), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-02', 'FINOR', 'Unidad de Postgrado FINOR', 'Facultad Integral del Norte', 'Sede_Provincial',
    'Provincial', 'Montero', 'Sede Provincial', 'Sede FINOR', 'Barrio Urkupiña, Av. Circunvalación Noroeste',
    -17.33831, -63.26956, -17.33831, -63.26956, 0.0,
    '3-9227259', 'postgradofinor@uagrm.edu.bo', 'L-V 08:00-15:00', 'Verificado', 'UAGRM-PG-FINOR',
    0.0, 'Diplomados Agroindustriales, Maestrías en Gestión Productiva', 'https://finor.uagrm.edu.bo', 'assets/fotos/PG-02.jpg',
    ST_SetSRID(ST_MakePoint(-63.26956, -17.33831), 4326), ST_SetSRID(ST_MakePoint(-63.26956, -17.33831), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-03', 'FCCASCGF', 'Unidad de Postgrado Ciencias Contables', 'Facultad de Ciencias Contables, Auditoría, Sistemas de Control de Gestión y Finanzas', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Campus Universitario', 'Av. Centenario entre 1er y 2do anillo',
    -17.7785, -63.1932, -17.7783086, -63.1929914, 30.61,
    'S/D', 'postgradocontaduria@uagrm.edu.bo', 'L 08:00-18:30 / Ma-V 08:30-18:30', 'Revisar_Campo', 'UAGRM-PG-FCCASCGF',
    0.0, 'Maestrías en Auditoría, Finanzas Corporativas y Gestión Tributaria', 'https://contaduria.uagrm.edu.bo', 'assets/fotos/PG-03.jpg',
    ST_SetSRID(ST_MakePoint(-63.1932, -17.7785), 4326), ST_SetSRID(ST_MakePoint(-63.1929914, -17.7783086), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-04', 'FCHDA', 'Unidad de Postgrado FCHDA', 'Facultad de Ciencias del Hábitat, Diseño y Arte', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Externo', 'Edificio FCHDA 1er Piso', 'Av. San Martín N° 146',
    -17.77006, -63.19206, -17.7700711, -63.1920237, 4.04,
    '3-3364664', 'postgradohabitat@uagrm.edu.bo', 'S/D', 'Revisar_Campo', 'UAGRM-PG-FCHDA',
    0.0, 'Maestrías en Arquitectura y Urbanismo, Diplomados en Diseño Sostenible', 'https://habitat.uagrm.edu.bo', 'assets/fotos/PG-04.jpg',
    ST_SetSRID(ST_MakePoint(-63.19206, -17.77006), 4326), ST_SetSRID(ST_MakePoint(-63.1920237, -17.7700711), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-05', 'FH', 'Unidad de Postgrado Humanidades', 'Facultad de Humanidades', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Campus Universitario', 'Calle México esq. Calle Venezuela',
    -17.7779, -63.1905, -17.7779048, -63.1905047, 0.73,
    '61538808', 'postgradohumanidades@uagrm.edu.bo', 'L-V 08:00-15:00', 'Revisar_Campo', 'UAGRM-PG-FH',
    0.0, 'Maestrías en Educación Superior, Diplomados en Lingüística y Psicología', 'https://humanidades.uagrm.edu.bo', 'assets/fotos/PG-05.jpg',
    ST_SetSRID(ST_MakePoint(-63.1905, -17.7779), 4326), ST_SetSRID(ST_MakePoint(-63.1905047, -17.7779048), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-06', 'FCSH', 'Unidad de Postgrado en Salud UAGRM', 'Facultad de Ciencias de la Salud Humana', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Zona Central', 'Edificio Salud', 'Calle Bolívar N° 228',
    -17.7834, -63.1782, -17.7834, -63.1782, 0.0,
    '3-3395008', 'postgradosalud@uagrm.edu.bo', 'L-V 08:30-15:30', 'Revisar_Campo', 'UAGRM-PG-FCSH',
    0.0, 'Especialidades Médicas, Maestrías en Salud Pública y Epidemiología', 'https://salud.uagrm.edu.bo', 'assets/fotos/PG-06.jpg',
    ST_SetSRID(ST_MakePoint(-63.1782, -17.7834), 4326), ST_SetSRID(ST_MakePoint(-63.1782, -17.7834), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-07', 'FCJPSRI', 'Unidad de Posgrado FCJPSRRII', 'Facultad de Ciencias Jurídicas, Políticas, Sociales y Relaciones Internacionales', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Campus Universitario', 'Av. Centenario / Av. Hernando Sanabria casi 2do anillo',
    -17.77919, -63.19294, -17.7787928, -63.1925072, 63.53,
    '76895500', 'postgradojuridicas@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FCJPSRI',
    0.0, 'Maestrías en Derecho Constitucional, Penal, Corporativo y RRII', 'https://juridicas.uagrm.edu.bo', 'assets/fotos/PG-07.jpg',
    ST_SetSRID(ST_MakePoint(-63.19294, -17.77919), 4326), ST_SetSRID(ST_MakePoint(-63.1925072, -17.7787928), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-08', 'FCEE', 'UAGRM Business School', 'Facultad de Ciencias Económicas y Empresariales', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Zona Central', 'Edificio Propio', 'Calle Gral. Agustín Saavedra N° 137 esq. Chuquisaca',
    -17.79031, -63.17894, -17.7903195, -63.1789341, 1.22,
    '3-3366814', 'contacto@uagrmbs.edu.bo', 'L-V 08:30-15:30', 'Verificado', 'UAGRM-PG-FCEE',
    0.0, 'Maestrías Ejecutivas, MBA Internacional, Diplomados en Marketing y Finanzas', 'https://www.uagrmbs.edu.bo', 'assets/fotos/PG-08.jpg',
    ST_SetSRID(ST_MakePoint(-63.17894, -17.79031), 4326), ST_SetSRID(ST_MakePoint(-63.1789341, -17.7903195), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-09', 'FCV', 'Unidad de Postgrado Veterinaria', 'Facultad de Ciencias Veterinarias', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 247', 'Av. 26 de Febrero entre Av. Busch y Centenario',
    -17.77706, -63.19581, -17.776763, -63.1953247, 61.04,
    '62217301', 'postgradofvc@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FCV',
    0.0, 'Especialidades en Cirugía Veterinaria, Maestrías en Sanidad Animal y Zootecnia', 'https://veterinaria.uagrm.edu.bo', 'assets/fotos/PG-09.jpg',
    ST_SetSRID(ST_MakePoint(-63.19581, -17.77706), 4326), ST_SetSRID(ST_MakePoint(-63.1953247, -17.776763), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-10', 'FCA', 'Unidad de Postgrado Ciencias Agrícolas (UPCA)', 'Facultad de Ciencias Agrícolas', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Externo', 'Edificio UPCA-FCA', 'Av. Cristóbal de Mendoza N° 900 (2do anillo)',
    -17.77356, -63.16669, -17.7736, -63.1667, 4.55,
    '63437106 / 77635020', 'postgradoagricolas@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FCA',
    0.0, 'Maestrías en Agricultura de Precisión, Gestión de Cuencas y Riego', 'https://agricolas.uagrm.edu.bo', 'assets/fotos/PG-10.jpg',
    ST_SetSRID(ST_MakePoint(-63.16669, -17.77356), 4326), ST_SetSRID(ST_MakePoint(-63.1667, -17.7736), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-11', 'FCET', 'UPCET / Escuela de Ingeniería', 'Facultad de Ciencias Exactas y Tecnología', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Sede 1 Campus / Sede 2 Módulo 290', 'Calle México esq. Venezuela (y Av. Busch Módulo 290)',
    -17.77794, -63.19044, -17.7779524, -63.1904523, 1.9,
    '60008313', 'info@ei-uagrm.edu.bo', 'L-V 08:00-18:30', 'Verificado', 'UAGRM-PG-FCET',
    0.0, 'Maestrías en Ingeniería de Procesos, Petróleo y Gas, Telecomunicaciones', 'https://ingenieria.uagrm.edu.bo', 'assets/fotos/PG-11.jpg',
    ST_SetSRID(ST_MakePoint(-63.19044, -17.77794), 4326), ST_SetSRID(ST_MakePoint(-63.1904523, -17.7779524), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-12', 'FP', 'Escuela Superior Politécnica (UPFP)', 'Facultad Politécnica', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 212, 4to piso', 'Av. Busch 2do anillo, Ciudad Universitaria',
    -17.7752, -63.1945, -17.7754035, -63.1947772, 37.02,
    '63339696', 'info@upfp.edu.bo', 'L-V 08:00-12:00 y 15:00-19:00', 'Revisar_Campo', 'UAGRM-PG-FP',
    0.0, 'Diplomados Técnicos en Automatización, Mantenimiento Industrial y Redes', 'https://politecnica.uagrm.edu.bo', 'assets/fotos/PG-12.jpg',
    ST_SetSRID(ST_MakePoint(-63.1945, -17.7752), 4326), ST_SetSRID(ST_MakePoint(-63.1947772, -17.7754035), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-13', 'FINI', 'Unidad de Postgrado FINI', 'Facultad Integral de Ichilo', 'Sede_Provincial',
    'Provincial', 'Yapacaní', 'Sede Provincial', 'Sede FINI', 'Barrio 12 de Octubre, Av. Santa Cruz s/n',
    -17.4025, -63.8849, -17.4025, -63.8849, 0.0,
    '69010491', 'postgradofini@uagrm.edu.bo', 'L-V 08:30-15:30', 'Revisar_Campo', 'UAGRM-PG-FINI',
    0.0, 'Diplomados en Desarrollo Agropecuario, Maestrías en Gestión Sostenible', 'https://fini.uagrm.edu.bo', 'assets/fotos/PG-13.jpg',
    ST_SetSRID(ST_MakePoint(-63.8849, -17.4025), 4326), ST_SetSRID(ST_MakePoint(-63.8849, -17.4025), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-14', 'FAICHI', 'Unidad de Postgrado FAICHI', 'Facultad Integral Chiquitana', 'Sede_Provincial',
    'Provincial', 'San Ignacio de Velasco', 'Sede Provincial', 'Sede FAICHI', 'Calle Junín Final y Viador Moreno s/n',
    -16.38444, -60.96744, -16.38444, -60.96744, 0.0,
    'S/D', 'f_integralchiquitana@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FAICHI',
    0.0, 'Diplomados en Recursos Naturales, Maestrías en Desarrollo Comunitario', 'https://faichi.uagrm.edu.bo', 'assets/fotos/PG-14.jpg',
    ST_SetSRID(ST_MakePoint(-60.96744, -16.38444), 4326), ST_SetSRID(ST_MakePoint(-60.96744, -16.38444), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-15', 'FCFB', 'Unidad de Posgrado Farmacia y Bioquímica', 'Facultad de Ciencias Farmacéuticas y Bioquímicas', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 280', 'Av. Busch entre 2do y 3er anillo',
    -17.77669, -63.19094, -17.777121, -63.1913669, 65.74,
    '3-3366270', 'posgradobiofar@hotmail.com', 'S/D', 'Verificado', 'UAGRM-PG-FCFB',
    0.0, 'Diplomados en Análisis Clínicos, Maestrías en Toxicología y Bioquímica', 'https://biofar.uagrm.edu.bo', 'assets/fotos/PG-15.jpg',
    ST_SetSRID(ST_MakePoint(-63.19094, -17.77669), 4326), ST_SetSRID(ST_MakePoint(-63.1913669, -17.777121), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-16', 'FICCT', 'UAGRM School of Engineering (SOE)', 'Facultad de Ingeniería en Ciencias de la Computación y Telecomunicaciones', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 232 / Módulo 236', 'Av. Busch, Ciudad Universitaria',
    -17.77631, -63.19506, -17.776252, -63.1949893, 9.87,
    '73600888 / 3-3553636', 'postgradoficct@uagrm.edu.bo', 'L-V 09:00-16:00', 'Verificado', 'UAGRM-PG-FICCT',
    0.0, 'Maestrías en Ciberseguridad, Ciencia de Datos, Software y Redes', 'https://ficct.uagrm.edu.bo', 'assets/fotos/PG-16.jpg',
    ST_SetSRID(ST_MakePoint(-63.19506, -17.77631), 4326), ST_SetSRID(ST_MakePoint(-63.1949893, -17.776252), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-17', 'FIVC', 'Unidad de Postgrado FIVC', 'Facultad Integral de los Valles Cruceños', 'Sede_Provincial',
    'Provincial', 'Vallegrande', 'Sede Provincial', 'Sede FIVC', 'Av. Tecnológico y Av. Ejército',
    -18.48631, -64.10094, -18.48631, -64.10094, 0.0,
    '3-9422317', 'postgradofivc@uagrm.edu.bo', 'L-V 07:00-18:00', 'Verificado', 'UAGRM-PG-FIVC',
    0.0, 'Diplomados en Agroecología, Maestrías en Desarrollo Rural y Gestión Hídrica', 'https://fivc.uagrm.edu.bo', 'assets/fotos/PG-17.jpg',
    ST_SetSRID(ST_MakePoint(-64.10094, -18.48631), 4326), ST_SetSRID(ST_MakePoint(-64.10094, -18.48631), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso
) VALUES (
    'PG-18', 'FINE', 'Unidad de Postgrado FINE', 'Facultad Integral del Nor-Este', 'Sede_Provincial',
    'Provincial', 'San Julián', 'Sede Provincial', 'Sede FINE', 'Barrio 6 de Agosto, Av. Marcelo Quiroga',
    -16.9065, -62.6168, -16.9065, -62.6168, 0.0,
    '3-9658002', 'postgradofine@uagrm.edu.bo', 'S/D', 'Revisar_Campo', 'UAGRM-PG-FINE',
    0.0, 'Diplomados en Producción Agrícola Sostenible y Gestión Educativa', 'https://fine.uagrm.edu.bo', 'assets/fotos/PG-18.jpg',
    ST_SetSRID(ST_MakePoint(-62.6168, -16.9065), 4326), ST_SetSRID(ST_MakePoint(-62.6168, -16.9065), 4326)
)
ON CONFLICT (id_postg) DO UPDATE SET
    cod_fac = EXCLUDED.cod_fac,
    nom_unidad = EXCLUDED.nom_unidad,
    nom_facult = EXCLUDED.nom_facult,
    tipo_ent = EXCLUDED.tipo_ent,
    ambito = EXCLUDED.ambito,
    municipio = EXCLUDED.municipio,
    campus = EXCLUDED.campus,
    modulo_pab = EXCLUDED.modulo_pab,
    direccion = EXCLUDED.direccion,
    lat_wgs84 = EXCLUDED.lat_wgs84,
    lon_wgs84 = EXCLUDED.lon_wgs84,
    lat_ruta = EXCLUDED.lat_ruta,
    lon_ruta = EXCLUDED.lon_ruta,
    dist_via_m = EXCLUDED.dist_via_m,
    telefono = EXCLUDED.telefono,
    correo = EXCLUDED.correo,
    horario = EXCLUDED.horario,
    estado_geo = EXCLUDED.estado_geo,
    cod_qr = EXCLUDED.cod_qr,
    area_m2 = EXCLUDED.area_m2,
    programas = EXCLUDED.programas,
    sitio_web = EXCLUDED.sitio_web,
    url_foto = EXCLUDED.url_foto,
    geom = EXCLUDED.geom,
    geom_acceso = EXCLUDED.geom_acceso,
    updated_at = NOW();

-- ============================================================================
-- 2. INSERT IDEMPOTENTE: public.servicios_apoyo (12 registros referenciales)
-- ============================================================================
INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-01', 'Seguro Social Universitario (SSU) - Sede Central', 'Centro_Medico', 'Zona Central', 'Calle Campero esq. Av. Irala (próximo a Rectorado UAGRM)', 'L-D 24 Horas (Emergencias) / L-V 07:30-19:00', TRUE, ST_SetSRID(ST_MakePoint(-63.1812, -17.7923), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-02', 'Gabinete Médico y Enfermería Ciudad Universitaria', 'Centro_Medico', 'Ciudad Universitaria', 'Planta Baja Módulo 212 (Frente a Politécnica), atención primaria', 'L-V 08:00-18:00', TRUE, ST_SetSRID(ST_MakePoint(-63.19435, -17.77535), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-03', 'Enfermería de Urgencias Médicas - Módulo 280 (FCFB)', 'Centro_Medico', 'Ciudad Universitaria', 'Módulo 280 Planta Baja, pasillo central Bioquímica', 'L-V 08:00-16:00', TRUE, ST_SetSRID(ST_MakePoint(-63.1911, -17.77675), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-04', 'Acceso Principal 1: Entrada Vehicular y Peatonal Av. Busch', 'Acceso_Campus', 'Ciudad Universitaria', 'Av. Busch y 2do Anillo (Control y caseta de seguridad)', 'L-S 06:00-22:30', TRUE, ST_SetSRID(ST_MakePoint(-63.19485, -17.7749), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-05', 'Acceso Principal 2: Entrada Peatonal y Vehicular Av. Centenario', 'Acceso_Campus', 'Campus Universitario', 'Av. Centenario casi 2do Anillo (Acceso a Ciencias Contables y Jurídicas)', 'L-S 06:30-22:00', TRUE, ST_SetSRID(ST_MakePoint(-63.1926, -17.7788), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-06', 'Acceso Secundario 3: Entrada Peatonal Calle México', 'Acceso_Campus', 'Campus Universitario', 'Calle México esq. Calle Venezuela (próximo a Humanidades y FCET)', 'L-V 07:00-21:00', TRUE, ST_SetSRID(ST_MakePoint(-63.1904, -17.7778), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-07', 'Extintor Central y Gabinete de Manguera - Módulo 232 (FICCT)', 'Extintor', 'Ciudad Universitaria', 'Módulo 232, Hall Principal junto a Laboratorios de Redes y Ciberseguridad', 'Permanente (Acceso continuo)', TRUE, ST_SetSRID(ST_MakePoint(-63.19502, -17.77638), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-08', 'Extintor PQS y Gabinete de Emergencia - Módulo 212 (Politécnica)', 'Extintor', 'Ciudad Universitaria', 'Módulo 212, descanso escalera 2do piso (Talleres de Automatización)', 'Permanente (Acceso continuo)', TRUE, ST_SetSRID(ST_MakePoint(-63.19455, -17.77525), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-09', 'Extintor Químico Seco y Alarma - Módulo 247 (Veterinaria)', 'Extintor', 'Ciudad Universitaria', 'Módulo 247, pasillo de Quirófanos y Aulas de Postgrado', 'Permanente (Acceso continuo)', TRUE, ST_SetSRID(ST_MakePoint(-63.19575, -17.777), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-10', 'Extintor CO2 / PQS Industrial - Módulo 280 (Farmacia y Bioquímica)', 'Extintor', 'Ciudad Universitaria', 'Módulo 280, sector laboratorios de microbiología y toxicología', 'Permanente (Acceso continuo)', TRUE, ST_SetSRID(ST_MakePoint(-63.19088, -17.77662), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-11', 'Punto de Encuentro 1: Plaza Cívica y Canchas Ciudad Universitaria', 'Punto_Encuentro', 'Ciudad Universitaria', 'Área abierta frente a Módulos 232 (FICCT) y 236, zona libre de tendido eléctrico', 'Permanente (Área abierta 24/7)', TRUE, ST_SetSRID(ST_MakePoint(-63.1947, -17.7761), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();

INSERT INTO public.servicios_apoyo (
    id_serv, nombre, tipo, campus, referencia, horario, es_referencial, geom
) VALUES (
    'SERV-12', 'Punto de Encuentro 2: Explanada Central Campus Universitario', 'Punto_Encuentro', 'Campus Universitario', 'Patio central entre Facultad de Humanidades y Ciencias Contables', 'Permanente (Área abierta 24/7)', TRUE, ST_SetSRID(ST_MakePoint(-63.1915, -17.7782), 4326)
)
ON CONFLICT (id_serv) DO UPDATE SET
    nombre = EXCLUDED.nombre,
    tipo = EXCLUDED.tipo,
    campus = EXCLUDED.campus,
    referencia = EXCLUDED.referencia,
    horario = EXCLUDED.horario,
    es_referencial = EXCLUDED.es_referencial,
    geom = EXCLUDED.geom,
    updated_at = NOW();
