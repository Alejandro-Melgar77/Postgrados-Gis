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
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-00', 'DGP', 'Escuela de Postgrado UAGRM (Dirección General de Posgrado)', 'Rectorado / Dirección General de Posgrado', 'Rectorado_DGP',
    'Urbano', 'Santa Cruz de la Sierra', 'Zona Central', 'Edif. Museo Noel Kempff 5to piso / Pab. 126 Aula 4', 'Av. Irala N° 565, 5to piso',
    -17.79277, -63.18183, -17.7928054, -63.181819, 4.09,
    '3-3342899', 'posgrado@uagrm.edu.bo', 'L-V 08:30-15:30', 'Verificado', 'UAGRM-PG-DGP',
    703.27, 'Doctorados, Maestrías Institucionales, Diplomados en Educación Superior', 'https://posgrado.uagrm.edu.bo', 'assets/fotos/PG-00.jpg',
    ST_SetSRID(ST_MakePoint(-63.18183, -17.79277), 4326), ST_SetSRID(ST_MakePoint(-63.181819, -17.7928054), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1818299,-17.7926344],[-63.1818053,-17.7926365],[-63.1817815,-17.7926426],[-63.1817591,-17.7926526],[-63.1817389,-17.7926662],[-63.1817215,-17.792683],[-63.1817074,-17.7927023],[-63.181697,-17.7927238],[-63.1816906,-17.7927466],[-63.1816885,-17.7927701],[-63.1816906,-17.7927937],[-63.1816971,-17.7928165],[-63.1817075,-17.7928379],[-63.1817217,-17.7928573],[-63.1817391,-17.7928739],[-63.1817594,-17.7928875],[-63.1817817,-17.7928975],[-63.1818056,-17.7929035],[-63.1818301,-17.7929056],[-63.1818547,-17.7929035],[-63.1818785,-17.7928974],[-63.1819009,-17.7928874],[-63.1819211,-17.7928738],[-63.1819385,-17.792857],[-63.1819526,-17.7928377],[-63.181963,-17.7928162],[-63.1819694,-17.7927934],[-63.1819715,-17.7927699],[-63.1819694,-17.7927463],[-63.1819629,-17.7927235],[-63.1819525,-17.7927021],[-63.1819383,-17.7926827],[-63.1819209,-17.7926661],[-63.1819006,-17.7926525],[-63.1818783,-17.7926425],[-63.1818544,-17.7926365],[-63.1818299,-17.7926344]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-01', 'FICH', 'Unidad de Postgrado FICH', 'Facultad Integral del Chaco', 'Sede_Provincial',
    'Provincial', 'Camiri', 'Sede Provincial', 'Sede FICH', 'Av. Humberto Suárez Roca',
    -20.03331, -63.52794, -20.03331, -63.52794, 0.0,
    '3-9522979', 'postgradofich@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FICH',
    703.27, 'Maestrías en Desarrollo Regional, Diplomados Petroleros y Ambientales', 'https://fich.uagrm.edu.bo', 'assets/fotos/PG-01.jpg',
    ST_SetSRID(ST_MakePoint(-63.52794, -20.03331), 4326), ST_SetSRID(ST_MakePoint(-63.52794, -20.03331), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.5279395,-20.0331745],[-63.5279146,-20.0331766],[-63.5278905,-20.0331828],[-63.5278679,-20.0331928],[-63.5278475,-20.0332064],[-63.5278298,-20.0332232],[-63.5278156,-20.0332426],[-63.5278051,-20.033264],[-63.5277987,-20.0332869],[-63.5277966,-20.0333104],[-63.5277988,-20.033334],[-63.5278054,-20.0333568],[-63.527816,-20.0333781],[-63.5278304,-20.0333975],[-63.5278482,-20.0334141],[-63.5278687,-20.0334276],[-63.5278914,-20.0334375],[-63.5279155,-20.0334436],[-63.5279405,-20.0334455],[-63.5279654,-20.0334434],[-63.5279895,-20.0334372],[-63.5280121,-20.0334272],[-63.5280325,-20.0334136],[-63.5280502,-20.0333968],[-63.5280644,-20.0333774],[-63.5280749,-20.033356],[-63.5280813,-20.0333331],[-63.5280834,-20.0333096],[-63.5280812,-20.033286],[-63.5280746,-20.0332632],[-63.528064,-20.0332419],[-63.5280496,-20.0332225],[-63.5280318,-20.0332059],[-63.5280113,-20.0331924],[-63.5279886,-20.0331825],[-63.5279645,-20.0331764],[-63.5279395,-20.0331745]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-02', 'FINOR', 'Unidad de Postgrado FINOR', 'Facultad Integral del Norte', 'Sede_Provincial',
    'Provincial', 'Montero', 'Sede Provincial', 'Sede FINOR', 'Barrio Urkupiña, Av. Circunvalación Noroeste',
    -17.33831, -63.26956, -17.33831, -63.26956, 0.0,
    '3-9227259', 'postgradofinor@uagrm.edu.bo', 'L-V 08:00-15:00', 'Verificado', 'UAGRM-PG-FINOR',
    703.27, 'Diplomados Agroindustriales, Maestrías en Gestión Productiva', 'https://finor.uagrm.edu.bo', 'assets/fotos/PG-02.jpg',
    ST_SetSRID(ST_MakePoint(-63.26956, -17.33831), 4326), ST_SetSRID(ST_MakePoint(-63.26956, -17.33831), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.2695598,-17.3381744],[-63.2695353,-17.3381765],[-63.2695115,-17.3381827],[-63.2694892,-17.3381927],[-63.2694691,-17.3382063],[-63.2694517,-17.338223],[-63.2694376,-17.3382424],[-63.2694273,-17.3382638],[-63.2694209,-17.3382866],[-63.2694188,-17.3383102],[-63.269421,-17.3383337],[-63.2694274,-17.3383566],[-63.2694378,-17.338378],[-63.269452,-17.3383973],[-63.2694694,-17.338414],[-63.2694896,-17.3384275],[-63.2695119,-17.3384375],[-63.2695357,-17.3384436],[-63.2695602,-17.3384456],[-63.2695847,-17.3384435],[-63.2696085,-17.3384373],[-63.2696308,-17.3384273],[-63.2696509,-17.3384137],[-63.2696683,-17.338397],[-63.2696824,-17.3383776],[-63.2696927,-17.3383562],[-63.2696991,-17.3383334],[-63.2697012,-17.3383098],[-63.269699,-17.3382863],[-63.2696926,-17.3382634],[-63.2696822,-17.338242],[-63.269668,-17.3382227],[-63.2696506,-17.338206],[-63.2696304,-17.3381925],[-63.2696081,-17.3381825],[-63.2695843,-17.3381764],[-63.2695598,-17.3381744]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-03', 'FCCASCGF', 'Unidad de Postgrado Ciencias Contables', 'Facultad de Ciencias Contables, Auditoría, Sistemas de Control de Gestión y Finanzas', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Campus Universitario', 'Av. Centenario entre 1er y 2do anillo',
    -17.7785, -63.1932, -17.7783086, -63.1929914, 30.61,
    'S/D', 'postgradocontaduria@uagrm.edu.bo', 'L 08:00-18:30 / Ma-V 08:30-18:30', 'Revisar_Campo', 'UAGRM-PG-FCCASCGF',
    703.27, 'Maestrías en Auditoría, Finanzas Corporativas y Gestión Tributaria', 'https://contaduria.uagrm.edu.bo', 'assets/fotos/PG-03.jpg',
    ST_SetSRID(ST_MakePoint(-63.1932, -17.7785), 4326), ST_SetSRID(ST_MakePoint(-63.1929914, -17.7783086), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1931999,-17.7783644],[-63.1931753,-17.7783665],[-63.1931515,-17.7783726],[-63.1931291,-17.7783827],[-63.1931089,-17.7783962],[-63.1930915,-17.778413],[-63.1930774,-17.7784323],[-63.193067,-17.7784538],[-63.1930606,-17.7784766],[-63.1930585,-17.7785001],[-63.1930607,-17.7785237],[-63.1930671,-17.7785465],[-63.1930775,-17.7785679],[-63.1930917,-17.7785873],[-63.1931091,-17.778604],[-63.1931294,-17.7786175],[-63.1931517,-17.7786275],[-63.1931756,-17.7786335],[-63.1932001,-17.7786356],[-63.1932247,-17.7786335],[-63.1932485,-17.7786274],[-63.1932709,-17.7786173],[-63.1932911,-17.7786038],[-63.1933085,-17.778587],[-63.1933226,-17.7785677],[-63.193333,-17.7785462],[-63.1933394,-17.7785234],[-63.1933415,-17.7784999],[-63.1933393,-17.7784763],[-63.1933329,-17.7784535],[-63.1933225,-17.7784321],[-63.1933083,-17.7784127],[-63.1932909,-17.778396],[-63.1932706,-17.7783825],[-63.1932483,-17.7783725],[-63.1932244,-17.7783665],[-63.1931999,-17.7783644]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-04', 'FCHDA', 'Unidad de Postgrado FCHDA', 'Facultad de Ciencias del Hábitat, Diseño y Arte', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Externo', 'Edificio FCHDA 1er Piso', 'Av. San Martín N° 146',
    -17.77006, -63.19206, -17.7700711, -63.1920237, 4.04,
    '3-3364664', 'postgradohabitat@uagrm.edu.bo', 'S/D', 'Revisar_Campo', 'UAGRM-PG-FCHDA',
    703.28, 'Maestrías en Arquitectura y Urbanismo, Diplomados en Diseño Sostenible', 'https://habitat.uagrm.edu.bo', 'assets/fotos/PG-04.jpg',
    ST_SetSRID(ST_MakePoint(-63.19206, -17.77006), 4326), ST_SetSRID(ST_MakePoint(-63.1920237, -17.7700711), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1920599,-17.7699244],[-63.1920353,-17.7699265],[-63.1920115,-17.7699326],[-63.1919891,-17.7699427],[-63.1919689,-17.7699562],[-63.1919515,-17.769973],[-63.1919374,-17.7699923],[-63.191927,-17.7700138],[-63.1919206,-17.7700366],[-63.1919185,-17.7700601],[-63.1919207,-17.7700837],[-63.1919271,-17.7701065],[-63.1919375,-17.7701279],[-63.1919517,-17.7701473],[-63.1919691,-17.770164],[-63.1919894,-17.7701775],[-63.1920117,-17.7701875],[-63.1920356,-17.7701935],[-63.1920601,-17.7701956],[-63.1920847,-17.7701935],[-63.1921085,-17.7701874],[-63.1921309,-17.7701773],[-63.1921511,-17.7701638],[-63.1921685,-17.770147],[-63.1921826,-17.7701277],[-63.192193,-17.7701062],[-63.1921994,-17.7700834],[-63.1922015,-17.7700599],[-63.1921993,-17.7700363],[-63.1921929,-17.7700135],[-63.1921825,-17.7699921],[-63.1921683,-17.7699727],[-63.1921508,-17.769956],[-63.1921306,-17.7699425],[-63.1921083,-17.7699325],[-63.1920844,-17.7699265],[-63.1920599,-17.7699244]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-05', 'FH', 'Unidad de Postgrado Humanidades', 'Facultad de Humanidades', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Campus Universitario', 'Calle México esq. Calle Venezuela',
    -17.7779, -63.1905, -17.7779048, -63.1905047, 0.73,
    '61538808', 'postgradohumanidades@uagrm.edu.bo', 'L-V 08:00-15:00', 'Revisar_Campo', 'UAGRM-PG-FH',
    703.28, 'Maestrías en Educación Superior, Diplomados en Lingüística y Psicología', 'https://humanidades.uagrm.edu.bo', 'assets/fotos/PG-05.jpg',
    ST_SetSRID(ST_MakePoint(-63.1905, -17.7779), 4326), ST_SetSRID(ST_MakePoint(-63.1905047, -17.7779048), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1904999,-17.7777644],[-63.1904753,-17.7777665],[-63.1904515,-17.7777726],[-63.1904291,-17.7777827],[-63.1904089,-17.7777962],[-63.1903915,-17.777813],[-63.1903774,-17.7778323],[-63.190367,-17.7778538],[-63.1903606,-17.7778766],[-63.1903585,-17.7779001],[-63.1903607,-17.7779237],[-63.1903671,-17.7779465],[-63.1903775,-17.7779679],[-63.1903917,-17.7779873],[-63.1904091,-17.778004],[-63.1904294,-17.7780175],[-63.1904517,-17.7780275],[-63.1904756,-17.7780335],[-63.1905001,-17.7780356],[-63.1905247,-17.7780335],[-63.1905485,-17.7780274],[-63.1905709,-17.7780173],[-63.1905911,-17.7780038],[-63.1906085,-17.777987],[-63.1906226,-17.7779677],[-63.190633,-17.7779462],[-63.1906394,-17.7779234],[-63.1906415,-17.7778999],[-63.1906393,-17.7778763],[-63.1906329,-17.7778535],[-63.1906225,-17.7778321],[-63.1906083,-17.7778127],[-63.1905909,-17.777796],[-63.1905706,-17.7777825],[-63.1905483,-17.7777725],[-63.1905244,-17.7777665],[-63.1904999,-17.7777644]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-06', 'FCSH', 'Unidad de Postgrado en Salud UAGRM', 'Facultad de Ciencias de la Salud Humana', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Zona Central', 'Edificio Salud', 'Calle Bolívar N° 228',
    -17.7834, -63.1782, -17.7834, -63.1782, 0.0,
    '3-3395008', 'postgradosalud@uagrm.edu.bo', 'L-V 08:30-15:30', 'Revisar_Campo', 'UAGRM-PG-FCSH',
    703.28, 'Especialidades Médicas, Maestrías en Salud Pública y Epidemiología', 'https://salud.uagrm.edu.bo', 'assets/fotos/PG-06.jpg',
    ST_SetSRID(ST_MakePoint(-63.1782, -17.7834), 4326), ST_SetSRID(ST_MakePoint(-63.1782, -17.7834), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1781999,-17.7832644],[-63.1781753,-17.7832665],[-63.1781515,-17.7832726],[-63.1781291,-17.7832826],[-63.1781089,-17.7832962],[-63.1780915,-17.7833129],[-63.1780774,-17.7833323],[-63.178067,-17.7833537],[-63.1780606,-17.7833766],[-63.1780585,-17.7834001],[-63.1780607,-17.7834237],[-63.1780671,-17.7834465],[-63.1780775,-17.7834679],[-63.1780917,-17.7834872],[-63.1781091,-17.7835039],[-63.1781294,-17.7835175],[-63.1781517,-17.7835274],[-63.1781756,-17.7835335],[-63.1782001,-17.7835356],[-63.1782247,-17.7835335],[-63.1782485,-17.7835274],[-63.1782709,-17.7835174],[-63.1782911,-17.7835038],[-63.1783085,-17.7834871],[-63.1783226,-17.7834677],[-63.178333,-17.7834463],[-63.1783394,-17.7834234],[-63.1783415,-17.7833999],[-63.1783393,-17.7833763],[-63.1783329,-17.7833535],[-63.1783225,-17.7833321],[-63.1783083,-17.7833128],[-63.1782909,-17.7832961],[-63.1782706,-17.7832825],[-63.1782483,-17.7832726],[-63.1782244,-17.7832665],[-63.1781999,-17.7832644]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-07', 'FCJPSRI', 'Unidad de Posgrado FCJPSRRII', 'Facultad de Ciencias Jurídicas, Políticas, Sociales y Relaciones Internacionales', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Campus Universitario', 'Av. Centenario / Av. Hernando Sanabria casi 2do anillo',
    -17.77919, -63.19294, -17.7787928, -63.1925072, 63.53,
    '76895500', 'postgradojuridicas@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FCJPSRI',
    703.27, 'Maestrías en Derecho Constitucional, Penal, Corporativo y RRII', 'https://juridicas.uagrm.edu.bo', 'assets/fotos/PG-07.jpg',
    ST_SetSRID(ST_MakePoint(-63.19294, -17.77919), 4326), ST_SetSRID(ST_MakePoint(-63.1925072, -17.7787928), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1929399,-17.7790544],[-63.1929153,-17.7790565],[-63.1928915,-17.7790626],[-63.1928691,-17.7790727],[-63.1928489,-17.7790862],[-63.1928315,-17.779103],[-63.1928174,-17.7791223],[-63.192807,-17.7791438],[-63.1928006,-17.7791666],[-63.1927985,-17.7791901],[-63.1928007,-17.7792137],[-63.1928071,-17.7792365],[-63.1928175,-17.7792579],[-63.1928317,-17.7792773],[-63.1928491,-17.779294],[-63.1928694,-17.7793075],[-63.1928917,-17.7793175],[-63.1929156,-17.7793235],[-63.1929401,-17.7793256],[-63.1929647,-17.7793235],[-63.1929885,-17.7793174],[-63.1930109,-17.7793073],[-63.1930311,-17.7792938],[-63.1930485,-17.779277],[-63.1930626,-17.7792577],[-63.193073,-17.7792362],[-63.1930794,-17.7792134],[-63.1930815,-17.7791899],[-63.1930793,-17.7791663],[-63.1930729,-17.7791435],[-63.1930625,-17.7791221],[-63.1930483,-17.7791027],[-63.1930309,-17.779086],[-63.1930106,-17.7790725],[-63.1929883,-17.7790625],[-63.1929644,-17.7790565],[-63.1929399,-17.7790544]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-08', 'FCEE', 'UAGRM Business School', 'Facultad de Ciencias Económicas y Empresariales', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Zona Central', 'Edificio Propio', 'Calle Gral. Agustín Saavedra N° 137 esq. Chuquisaca',
    -17.79031, -63.17894, -17.7903195, -63.1789341, 1.22,
    '3-3366814', 'contacto@uagrmbs.edu.bo', 'L-V 08:30-15:30', 'Verificado', 'UAGRM-PG-FCEE',
    703.28, 'Maestrías Ejecutivas, MBA Internacional, Diplomados en Marketing y Finanzas', 'https://www.uagrmbs.edu.bo', 'assets/fotos/PG-08.jpg',
    ST_SetSRID(ST_MakePoint(-63.17894, -17.79031), 4326), ST_SetSRID(ST_MakePoint(-63.1789341, -17.7903195), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1789399,-17.7901744],[-63.1789153,-17.7901765],[-63.1788915,-17.7901826],[-63.1788691,-17.7901926],[-63.1788489,-17.7902062],[-63.1788315,-17.7902229],[-63.1788174,-17.7902423],[-63.178807,-17.7902637],[-63.1788006,-17.7902866],[-63.1787985,-17.7903101],[-63.1788006,-17.7903337],[-63.1788071,-17.7903565],[-63.1788175,-17.7903779],[-63.1788317,-17.7903972],[-63.1788491,-17.7904139],[-63.1788694,-17.7904275],[-63.1788917,-17.7904374],[-63.1789156,-17.7904435],[-63.1789401,-17.7904456],[-63.1789647,-17.7904435],[-63.1789885,-17.7904374],[-63.1790109,-17.7904274],[-63.1790311,-17.7904138],[-63.1790485,-17.7903971],[-63.1790626,-17.7903777],[-63.179073,-17.7903562],[-63.1790794,-17.7903334],[-63.1790815,-17.7903099],[-63.1790794,-17.7902863],[-63.1790729,-17.7902635],[-63.1790625,-17.7902421],[-63.1790483,-17.7902228],[-63.1790309,-17.7902061],[-63.1790106,-17.7901925],[-63.1789883,-17.7901826],[-63.1789644,-17.7901765],[-63.1789399,-17.7901744]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-09', 'FCV', 'Unidad de Postgrado Veterinaria', 'Facultad de Ciencias Veterinarias', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 247', 'Av. 26 de Febrero entre Av. Busch y Centenario',
    -17.77706, -63.19581, -17.776763, -63.1953247, 61.04,
    '62217301', 'postgradofvc@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FCV',
    703.28, 'Especialidades en Cirugía Veterinaria, Maestrías en Sanidad Animal y Zootecnia', 'https://veterinaria.uagrm.edu.bo', 'assets/fotos/PG-09.jpg',
    ST_SetSRID(ST_MakePoint(-63.19581, -17.77706), 4326), ST_SetSRID(ST_MakePoint(-63.1953247, -17.776763), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1958099,-17.7769244],[-63.1957853,-17.7769265],[-63.1957615,-17.7769326],[-63.1957391,-17.7769427],[-63.1957189,-17.7769562],[-63.1957015,-17.776973],[-63.1956874,-17.7769923],[-63.195677,-17.7770138],[-63.1956706,-17.7770366],[-63.1956685,-17.7770601],[-63.1956707,-17.7770837],[-63.1956771,-17.7771065],[-63.1956875,-17.7771279],[-63.1957017,-17.7771473],[-63.1957191,-17.777164],[-63.1957394,-17.7771775],[-63.1957617,-17.7771875],[-63.1957856,-17.7771935],[-63.1958101,-17.7771956],[-63.1958347,-17.7771935],[-63.1958585,-17.7771874],[-63.1958809,-17.7771773],[-63.1959011,-17.7771638],[-63.1959185,-17.777147],[-63.1959326,-17.7771277],[-63.195943,-17.7771062],[-63.1959494,-17.7770834],[-63.1959515,-17.7770599],[-63.1959493,-17.7770363],[-63.1959429,-17.7770135],[-63.1959325,-17.7769921],[-63.1959183,-17.7769727],[-63.1959009,-17.776956],[-63.1958806,-17.7769425],[-63.1958583,-17.7769325],[-63.1958344,-17.7769265],[-63.1958099,-17.7769244]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-10', 'FCA', 'Unidad de Postgrado Ciencias Agrícolas (UPCA)', 'Facultad de Ciencias Agrícolas', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Externo', 'Edificio UPCA-FCA', 'Av. Cristóbal de Mendoza N° 900 (2do anillo)',
    -17.77356, -63.16669, -17.7736, -63.1667, 4.55,
    '63437106 / 77635020', 'postgradoagricolas@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FCA',
    703.28, 'Maestrías en Agricultura de Precisión, Gestión de Cuencas y Riego', 'https://agricolas.uagrm.edu.bo', 'assets/fotos/PG-10.jpg',
    ST_SetSRID(ST_MakePoint(-63.16669, -17.77356), 4326), ST_SetSRID(ST_MakePoint(-63.1667, -17.7736), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1666899,-17.7734244],[-63.1666653,-17.7734265],[-63.1666415,-17.7734326],[-63.1666191,-17.7734426],[-63.1665989,-17.7734562],[-63.1665815,-17.7734729],[-63.1665674,-17.7734923],[-63.166557,-17.7735137],[-63.1665506,-17.7735366],[-63.1665485,-17.7735601],[-63.1665507,-17.7735837],[-63.1665571,-17.7736065],[-63.1665675,-17.7736279],[-63.1665817,-17.7736472],[-63.1665991,-17.7736639],[-63.1666194,-17.7736775],[-63.1666417,-17.7736874],[-63.1666656,-17.7736935],[-63.1666901,-17.7736956],[-63.1667147,-17.7736935],[-63.1667385,-17.7736874],[-63.1667609,-17.7736774],[-63.1667811,-17.7736638],[-63.1667985,-17.7736471],[-63.1668126,-17.7736277],[-63.166823,-17.7736063],[-63.1668294,-17.7735834],[-63.1668315,-17.7735599],[-63.1668293,-17.7735363],[-63.1668229,-17.7735135],[-63.1668125,-17.7734921],[-63.1667983,-17.7734728],[-63.1667809,-17.7734561],[-63.1667606,-17.7734425],[-63.1667383,-17.7734326],[-63.1667144,-17.7734265],[-63.1666899,-17.7734244]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-11', 'FCET', 'UPCET / Escuela de Ingeniería', 'Facultad de Ciencias Exactas y Tecnología', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Campus Universitario', 'Sede 1 Campus / Sede 2 Módulo 290', 'Calle México esq. Venezuela (y Av. Busch Módulo 290)',
    -17.77794, -63.19044, -17.7779524, -63.1904523, 1.9,
    '60008313', 'info@ei-uagrm.edu.bo', 'L-V 08:00-18:30', 'Verificado', 'UAGRM-PG-FCET',
    703.28, 'Maestrías en Ingeniería de Procesos, Petróleo y Gas, Telecomunicaciones', 'https://ingenieria.uagrm.edu.bo', 'assets/fotos/PG-11.jpg',
    ST_SetSRID(ST_MakePoint(-63.19044, -17.77794), 4326), ST_SetSRID(ST_MakePoint(-63.1904523, -17.7779524), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1904399,-17.7778044],[-63.1904153,-17.7778065],[-63.1903915,-17.7778126],[-63.1903691,-17.7778227],[-63.1903489,-17.7778362],[-63.1903315,-17.777853],[-63.1903174,-17.7778723],[-63.190307,-17.7778938],[-63.1903006,-17.7779166],[-63.1902985,-17.7779401],[-63.1903007,-17.7779637],[-63.1903071,-17.7779865],[-63.1903175,-17.7780079],[-63.1903317,-17.7780273],[-63.1903491,-17.778044],[-63.1903694,-17.7780575],[-63.1903917,-17.7780675],[-63.1904156,-17.7780735],[-63.1904401,-17.7780756],[-63.1904647,-17.7780735],[-63.1904885,-17.7780674],[-63.1905109,-17.7780573],[-63.1905311,-17.7780438],[-63.1905485,-17.778027],[-63.1905626,-17.7780077],[-63.190573,-17.7779862],[-63.1905794,-17.7779634],[-63.1905815,-17.7779399],[-63.1905793,-17.7779163],[-63.1905729,-17.7778935],[-63.1905625,-17.7778721],[-63.1905483,-17.7778527],[-63.1905309,-17.777836],[-63.1905106,-17.7778225],[-63.1904883,-17.7778125],[-63.1904644,-17.7778065],[-63.1904399,-17.7778044]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-12', 'FP', 'Escuela Superior Politécnica (UPFP)', 'Facultad Politécnica', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 212, 4to piso', 'Av. Busch 2do anillo, Ciudad Universitaria',
    -17.7752, -63.1945, -17.7754035, -63.1947772, 37.02,
    '63339696', 'info@upfp.edu.bo', 'L-V 08:00-12:00 y 15:00-19:00', 'Revisar_Campo', 'UAGRM-PG-FP',
    703.28, 'Diplomados Técnicos en Automatización, Mantenimiento Industrial y Redes', 'https://politecnica.uagrm.edu.bo', 'assets/fotos/PG-12.jpg',
    ST_SetSRID(ST_MakePoint(-63.1945, -17.7752), 4326), ST_SetSRID(ST_MakePoint(-63.1947772, -17.7754035), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1944999,-17.7750644],[-63.1944753,-17.7750665],[-63.1944515,-17.7750726],[-63.1944291,-17.7750827],[-63.1944089,-17.7750962],[-63.1943915,-17.775113],[-63.1943774,-17.7751323],[-63.194367,-17.7751538],[-63.1943606,-17.7751766],[-63.1943585,-17.7752001],[-63.1943607,-17.7752237],[-63.1943671,-17.7752465],[-63.1943775,-17.7752679],[-63.1943917,-17.7752873],[-63.1944091,-17.775304],[-63.1944294,-17.7753175],[-63.1944517,-17.7753275],[-63.1944756,-17.7753335],[-63.1945001,-17.7753356],[-63.1945247,-17.7753335],[-63.1945485,-17.7753274],[-63.1945709,-17.7753173],[-63.1945911,-17.7753038],[-63.1946085,-17.775287],[-63.1946226,-17.7752677],[-63.194633,-17.7752462],[-63.1946394,-17.7752234],[-63.1946415,-17.7751999],[-63.1946393,-17.7751763],[-63.1946329,-17.7751535],[-63.1946225,-17.7751321],[-63.1946083,-17.7751127],[-63.1945909,-17.775096],[-63.1945706,-17.7750825],[-63.1945483,-17.7750725],[-63.1945244,-17.7750665],[-63.1944999,-17.7750644]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-13', 'FINI', 'Unidad de Postgrado FINI', 'Facultad Integral de Ichilo', 'Sede_Provincial',
    'Provincial', 'Yapacaní', 'Sede Provincial', 'Sede FINI', 'Barrio 12 de Octubre, Av. Santa Cruz s/n',
    -17.4025, -63.8849, -17.4025, -63.8849, 0.0,
    '69010491', 'postgradofini@uagrm.edu.bo', 'L-V 08:30-15:30', 'Revisar_Campo', 'UAGRM-PG-FINI',
    703.28, 'Diplomados en Desarrollo Agropecuario, Maestrías en Gestión Sostenible', 'https://fini.uagrm.edu.bo', 'assets/fotos/PG-13.jpg',
    ST_SetSRID(ST_MakePoint(-63.8849, -17.4025), 4326), ST_SetSRID(ST_MakePoint(-63.8849, -17.4025), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.8848993,-17.4023644],[-63.8848748,-17.4023666],[-63.8848511,-17.4023728],[-63.8848288,-17.4023829],[-63.8848087,-17.4023965],[-63.8847914,-17.4024133],[-63.8847774,-17.4024328],[-63.8847671,-17.4024542],[-63.8847608,-17.4024771],[-63.8847588,-17.4025006],[-63.884761,-17.4025242],[-63.8847675,-17.402547],[-63.884778,-17.4025683],[-63.8847922,-17.4025876],[-63.8848097,-17.4026043],[-63.88483,-17.4026177],[-63.8848523,-17.4026276],[-63.8848761,-17.4026336],[-63.8849007,-17.4026356],[-63.8849252,-17.4026334],[-63.8849489,-17.4026272],[-63.8849712,-17.4026171],[-63.8849913,-17.4026035],[-63.8850086,-17.4025867],[-63.8850226,-17.4025672],[-63.8850329,-17.4025458],[-63.8850392,-17.4025229],[-63.8850412,-17.4024994],[-63.8850389,-17.4024758],[-63.8850325,-17.402453],[-63.885022,-17.4024317],[-63.8850078,-17.4024124],[-63.8849903,-17.4023957],[-63.88497,-17.4023823],[-63.8849477,-17.4023724],[-63.8849239,-17.4023664],[-63.8848993,-17.4023644]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-14', 'FAICHI', 'Unidad de Postgrado FAICHI', 'Facultad Integral Chiquitana', 'Sede_Provincial',
    'Provincial', 'San Ignacio de Velasco', 'Sede Provincial', 'Sede FAICHI', 'Calle Junín Final y Viador Moreno s/n',
    -16.38444, -60.96744, -16.38444, -60.96744, 0.0,
    'S/D', 'f_integralchiquitana@uagrm.edu.bo', 'S/D', 'Verificado', 'UAGRM-PG-FAICHI',
    703.28, 'Diplomados en Recursos Naturales, Maestrías en Desarrollo Comunitario', 'https://faichi.uagrm.edu.bo', 'assets/fotos/PG-14.jpg',
    ST_SetSRID(ST_MakePoint(-60.96744, -16.38444), 4326), ST_SetSRID(ST_MakePoint(-60.96744, -16.38444), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-60.9674414,-16.3843045],[-60.967417,-16.3843063],[-60.9673933,-16.3843122],[-60.967371,-16.384322],[-60.9673508,-16.3843353],[-60.9673334,-16.3843519],[-60.9673191,-16.3843711],[-60.9673086,-16.3843924],[-60.967302,-16.3844151],[-60.9672996,-16.3844386],[-60.9673015,-16.3844622],[-60.9673076,-16.3844851],[-60.9673177,-16.3845066],[-60.9673316,-16.3845261],[-60.9673487,-16.3845429],[-60.9673686,-16.3845567],[-60.9673907,-16.3845669],[-60.9674142,-16.3845732],[-60.9674386,-16.3845755],[-60.967463,-16.3845737],[-60.9674867,-16.3845678],[-60.967509,-16.384558],[-60.9675292,-16.3845447],[-60.9675466,-16.3845281],[-60.9675609,-16.3845089],[-60.9675714,-16.3844876],[-60.967578,-16.3844649],[-60.9675804,-16.3844414],[-60.9675785,-16.3844178],[-60.9675724,-16.3843949],[-60.9675623,-16.3843734],[-60.9675484,-16.3843539],[-60.9675313,-16.3843371],[-60.9675114,-16.3843233],[-60.9674893,-16.3843131],[-60.9674658,-16.3843068],[-60.9674414,-16.3843045]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-15', 'FCFB', 'Unidad de Posgrado Farmacia y Bioquímica', 'Facultad de Ciencias Farmacéuticas y Bioquímicas', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 280', 'Av. Busch entre 2do y 3er anillo',
    -17.77669, -63.19094, -17.777121, -63.1913669, 65.74,
    '3-3366270', 'posgradobiofar@hotmail.com', 'S/D', 'Verificado', 'UAGRM-PG-FCFB',
    703.27, 'Diplomados en Análisis Clínicos, Maestrías en Toxicología y Bioquímica', 'https://biofar.uagrm.edu.bo', 'assets/fotos/PG-15.jpg',
    ST_SetSRID(ST_MakePoint(-63.19094, -17.77669), 4326), ST_SetSRID(ST_MakePoint(-63.1913669, -17.777121), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1909399,-17.7765544],[-63.1909153,-17.7765565],[-63.1908915,-17.7765626],[-63.1908691,-17.7765727],[-63.1908489,-17.7765862],[-63.1908315,-17.776603],[-63.1908174,-17.7766223],[-63.190807,-17.7766438],[-63.1908006,-17.7766666],[-63.1907985,-17.7766901],[-63.1908007,-17.7767137],[-63.1908071,-17.7767365],[-63.1908175,-17.7767579],[-63.1908317,-17.7767773],[-63.1908491,-17.776794],[-63.1908694,-17.7768075],[-63.1908917,-17.7768175],[-63.1909156,-17.7768235],[-63.1909401,-17.7768256],[-63.1909647,-17.7768235],[-63.1909885,-17.7768174],[-63.1910109,-17.7768073],[-63.1910311,-17.7767938],[-63.1910485,-17.776777],[-63.1910626,-17.7767577],[-63.191073,-17.7767362],[-63.1910794,-17.7767134],[-63.1910815,-17.7766899],[-63.1910793,-17.7766663],[-63.1910729,-17.7766435],[-63.1910625,-17.7766221],[-63.1910483,-17.7766027],[-63.1910309,-17.776586],[-63.1910106,-17.7765725],[-63.1909883,-17.7765625],[-63.1909644,-17.7765565],[-63.1909399,-17.7765544]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-16', 'FICCT', 'UAGRM School of Engineering (SOE)', 'Facultad de Ingeniería en Ciencias de la Computación y Telecomunicaciones', 'Unidad_Facultativa',
    'Urbano', 'Santa Cruz de la Sierra', 'Ciudad Universitaria', 'Módulo 232 / Módulo 236', 'Av. Busch, Ciudad Universitaria',
    -17.77631, -63.19506, -17.776252, -63.1949893, 9.87,
    '73600888 / 3-3553636', 'postgradoficct@uagrm.edu.bo', 'L-V 09:00-16:00', 'Verificado', 'UAGRM-PG-FICCT',
    703.27, 'Maestrías en Ciberseguridad, Ciencia de Datos, Software y Redes', 'https://ficct.uagrm.edu.bo', 'assets/fotos/PG-16.jpg',
    ST_SetSRID(ST_MakePoint(-63.19506, -17.77631), 4326), ST_SetSRID(ST_MakePoint(-63.1949893, -17.776252), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-63.1950599,-17.7761744],[-63.1950353,-17.7761765],[-63.1950115,-17.7761826],[-63.1949891,-17.7761927],[-63.1949689,-17.7762062],[-63.1949515,-17.776223],[-63.1949374,-17.7762423],[-63.194927,-17.7762638],[-63.1949206,-17.7762866],[-63.1949185,-17.7763101],[-63.1949207,-17.7763337],[-63.1949271,-17.7763565],[-63.1949375,-17.7763779],[-63.1949517,-17.7763973],[-63.1949691,-17.776414],[-63.1949894,-17.7764275],[-63.1950117,-17.7764375],[-63.1950356,-17.7764435],[-63.1950601,-17.7764456],[-63.1950847,-17.7764435],[-63.1951085,-17.7764374],[-63.1951309,-17.7764273],[-63.1951511,-17.7764138],[-63.1951685,-17.776397],[-63.1951826,-17.7763777],[-63.195193,-17.7763562],[-63.1951994,-17.7763334],[-63.1952015,-17.7763099],[-63.1951993,-17.7762863],[-63.1951929,-17.7762635],[-63.1951825,-17.7762421],[-63.1951683,-17.7762227],[-63.1951509,-17.776206],[-63.1951306,-17.7761925],[-63.1951083,-17.7761825],[-63.1950844,-17.7761765],[-63.1950599,-17.7761744]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-17', 'FIVC', 'Unidad de Postgrado FIVC', 'Facultad Integral de los Valles Cruceños', 'Sede_Provincial',
    'Provincial', 'Vallegrande', 'Sede Provincial', 'Sede FIVC', 'Av. Tecnológico y Av. Ejército',
    -18.48631, -64.10094, -18.48631, -64.10094, 0.0,
    '3-9422317', 'postgradofivc@uagrm.edu.bo', 'L-V 07:00-18:00', 'Verificado', 'UAGRM-PG-FIVC',
    703.27, 'Diplomados en Agroecología, Maestrías en Desarrollo Rural y Gestión Hídrica', 'https://fivc.uagrm.edu.bo', 'assets/fotos/PG-17.jpg',
    ST_SetSRID(ST_MakePoint(-64.10094, -18.48631), 4326), ST_SetSRID(ST_MakePoint(-64.10094, -18.48631), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-64.1009391,-18.4861745],[-64.1009145,-18.4861767],[-64.1008906,-18.4861829],[-64.1008682,-18.486193],[-64.100848,-18.4862067],[-64.1008306,-18.4862235],[-64.1008165,-18.4862429],[-64.1008062,-18.4862644],[-64.1007999,-18.4862873],[-64.1007979,-18.4863108],[-64.1008002,-18.4863344],[-64.1008068,-18.4863571],[-64.1008174,-18.4863785],[-64.1008317,-18.4863978],[-64.1008493,-18.4864144],[-64.1008697,-18.4864278],[-64.1008922,-18.4864377],[-64.1009162,-18.4864436],[-64.1009409,-18.4864455],[-64.1009655,-18.4864433],[-64.1009894,-18.4864371],[-64.1010118,-18.486427],[-64.101032,-18.4864133],[-64.1010494,-18.4863965],[-64.1010635,-18.4863771],[-64.1010738,-18.4863556],[-64.1010801,-18.4863327],[-64.1010821,-18.4863092],[-64.1010798,-18.4862856],[-64.1010732,-18.4862629],[-64.1010626,-18.4862415],[-64.1010483,-18.4862222],[-64.1010307,-18.4862056],[-64.1010103,-18.4861922],[-64.1009878,-18.4861823],[-64.1009638,-18.4861764],[-64.1009391,-18.4861745]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
    updated_at = NOW();

INSERT INTO public.postgrados_uagrm (
    id_postg, cod_fac, nom_unidad, nom_facult, tipo_ent,
    ambito, municipio, campus, modulo_pab, direccion,
    lat_wgs84, lon_wgs84, lat_ruta, lon_ruta, dist_via_m,
    telefono, correo, horario, estado_geo, cod_qr,
    area_m2, programas, sitio_web, url_foto, geom, geom_acceso, geom_poly
) VALUES (
    'PG-18', 'FINE', 'Unidad de Postgrado FINE', 'Facultad Integral del Nor-Este', 'Sede_Provincial',
    'Provincial', 'San Julián', 'Sede Provincial', 'Sede FINE', 'Barrio 6 de Agosto, Av. Marcelo Quiroga',
    -16.9065, -62.6168, -16.9065, -62.6168, 0.0,
    '3-9658002', 'postgradofine@uagrm.edu.bo', 'S/D', 'Revisar_Campo', 'UAGRM-PG-FINE',
    703.28, 'Diplomados en Producción Agrícola Sostenible y Gestión Educativa', 'https://fine.uagrm.edu.bo', 'assets/fotos/PG-18.jpg',
    ST_SetSRID(ST_MakePoint(-62.6168, -16.9065), 4326), ST_SetSRID(ST_MakePoint(-62.6168, -16.9065), 4326), ST_SetSRID(ST_GeomFromGeoJSON('{"type":"Polygon","coordinates":[[[-62.6168003,-16.9063644],[-62.6167758,-16.9063664],[-62.6167521,-16.9063725],[-62.6167298,-16.9063824],[-62.6167097,-16.906396],[-62.6166923,-16.9064126],[-62.6166782,-16.906432],[-62.6166677,-16.9064534],[-62.6166613,-16.9064762],[-62.6166592,-16.9064997],[-62.6166612,-16.9065233],[-62.6166676,-16.9065461],[-62.6166779,-16.9065676],[-62.6166919,-16.906587],[-62.6167093,-16.9066037],[-62.6167293,-16.9066173],[-62.6167516,-16.9066273],[-62.6167753,-16.9066335],[-62.6167997,-16.9066356],[-62.6168242,-16.9066336],[-62.6168479,-16.9066275],[-62.6168702,-16.9066176],[-62.6168903,-16.906604],[-62.6169077,-16.9065874],[-62.6169218,-16.906568],[-62.6169323,-16.9065466],[-62.6169387,-16.9065238],[-62.6169408,-16.9065003],[-62.6169388,-16.9064767],[-62.6169324,-16.9064539],[-62.6169221,-16.9064324],[-62.6169081,-16.906413],[-62.6168907,-16.9063963],[-62.6168707,-16.9063827],[-62.6168484,-16.9063727],[-62.6168247,-16.9063665],[-62.6168003,-16.9063644]]]}'), 4326)
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
    geom_poly = EXCLUDED.geom_poly,
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
