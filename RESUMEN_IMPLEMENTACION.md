# RESUMEN EJECUTIVO DE IMPLEMENTACIÓN: CAPA 8 — UNIDADES DE POSTGRADO UAGRM
## Proyecto SIG: Mapa de Infraestructura Universitaria — UAGRM 2026
**Asignatura:** INF442-SA — Sistemas de Información Geográfica (Gestión 2026-2)  
**Entorno SIG Destino:** **ArcGIS Desktop / ArcMap 10.8**  
**Fecha de Implementación y Pulido:** Noviembre 2026  
**Especialista:** Ingeniero de SIG y Arquitectura WebGIS  

---

## 1. OBJETIVO DEL TRABAJO REALIZADO

Construir, estructurar, georreferenciar, pulir y documentar de manera integral la **Capa 8: Escuelas y Unidades de Postgrado** (compuesta por la Dirección General de Posgrado y las 18 facultades de la UAGRM), garantizando compatibilidad nativa al 100% con **ArcMap 10.8**, capacidad de navegación/ruteo (*Network Analyst*) y exportación para visualización web y móvil por código QR (*WebGIS*).

---

## 2. DESGLOSE DE FASES EJECUTADAS

### FASE 1: Auditoría Técnica del Repositorio y Diagnóstico SIG
1. **Inspección de Archivos Existentes:**
   - Se inventariaron los mapas (`PROYECTO BOLIVIA.mxd`), Geodatabases (`Geodatabase datos wgs84_geograficas.mdb`), shapefiles departamentales de Santa Cruz, capas nacionales de Bolivia y datos de prueba (`QSTART`).
   - Se detectó que las capas vinculadas al `.mxd` presentaban enlaces rotos por haber sido configuradas originalmente con una ruta absoluta fija (`C:\SIG\...`).
2. **Definición del Sistema de Referencia de Coordenadas (CRS):**
   - **Cartografía de Ingeniería / Santa Cruz:** Se verificó el uso de **`EPSG:32720` (`WGS 1984 UTM Zone 20S`)**, presente en `Mapa_Hidrografico_SCZ_100000.prj` y `CENTRO_POBLADOS_ARC.prj`.
   - Se extrajo el texto literal **ESRI WKT1** para replicarlo exactamente en todas las nuevas capas y suprimir cualquier advertencia de transformación espacial en ArcMap.
3. **Diagnóstico de Conectividad Vial:**
   - Se constató que la capa `CAMINOS_Y_VIA_FERREA.shp` existente corresponde a la red vial interprovincial y nacional, pero no incluye la trama urbana detallada ni senderos peatonales de los campus UAGRM.
4. **Verificación de Entornos Python:**
   - Se validó la disponibilidad operativa de **Python 2.7.16 (32 bits) de ArcGIS 10.8** con la librería nativa **`arcpy` 10.8** (`C:\Python27\ArcGIS10.8\python.exe`).
   - Se descartó el uso de Python 3 para la generación de binarios ESRI para evitar incompatibilidades de drivers o corrupción de índices DBF/SHP.

---

### FASE 2: Generación y Pulido de Capas para ArcMap 10.8
Se desarrolló y ejecutó el script reproducible [generar_capa_postgrados.py](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/scripts/generar_capa_postgrados.py), generando los siguientes activos en la carpeta [output_postgrados/](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados):

1. **Capa Principal de Puntos ([postgrados_uagrm_pts.shp](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados/postgrados_uagrm_pts.shp)):**
   - 19 entidades puntuales georreferenciadas y proyectadas a **`EPSG:32720` (UTM 20S)**.
   - Tabla de atributos ampliada a 24 campos estructurados conforme a los límites de DBF (máximo 10 caracteres por nombre, sin espacios ni caracteres especiales), incorporando:
     - `programas` (Text, 120): Oferta académica resumida de cada unidad.
     - `sitio_web` (Text, 120): Enlace oficial al portal de postgrado.
     - `url_foto` (Text, 150): Ruta estandarizada a la imagen (`assets/fotos/PG-XX.jpg`).
   - Archivo de página de códigos **`.cpg` con valor `UTF-8`** y archivo de proyección **`.prj` en ESRI WKT1** idéntico al del proyecto.
2. **Capa de Polígonos para Edición de Huellas ([postgrados_uagrm_poly.shp](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados/postgrados_uagrm_poly.shp)):**
   - 19 polígonos precargados con buffers circulares referenciales de 15 metros ($706.86\text{ m}^2$) etiquetados con `tipo_geom = 'Referencial'`.
   - Campo numérico `area_m2` (*Double*), preparado para que el usuario digitalice la huella exacta con la barra **Editor** de ArcMap 10.8 y calcule el área con **Calculate Geometry**.
3. **File Geodatabase Nativa con Field Aliases ([postgrados_uagrm.gdb](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados/postgrados_uagrm.gdb)):**
   - Geodatabase de archivos que agrupa las capas y aplica **Field Aliases** profesionales mediante `arcpy.AlterField_management` (ej. `nom_unidad` -> `"Nombre de la Unidad de Postgrado"`, `modulo_pab` -> `"Módulo o Pabellón"`, `area_m2` -> `"Superficie Estimada (m²)"`).
4. **Archivos de Intercambio y Respaldo:**
   - **[postgrados_uagrm.csv](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados/postgrados_uagrm.csv):** Tabla delimitada por comas en `UTF-8 con BOM`, con coordenadas en WGS 84 (`lon_wgs84`, `lat_wgs84`) y métricas (`utm_x_20s`, `utm_y_20s`) para carga mediante *Add XY Data*.
   - **[postgrados_uagrm_web.geojson](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados/postgrados_uagrm_web.geojson):** Estándar GeoJSON en `EPSG:4326` con codificación UTF-8 pura sin caracteres de escape innecesarios, listo para visores web (Leaflet, MapLibre, OpenLayers).

---

### FASE 3: Preparación para Navegabilidad, Ruteo y Consulta Móvil
1. **Unificación y Estandarización de Nombres:**
   - Se estandarizó el nombre a **`postgrados_nodos_acceso`** de forma unánime en Shapefile, Geodatabase, scripts y documentación.
2. **Snapping a Red Vial con Licencia ArcMap Basic / Standard:**
   - Se creó el script independiente [vincular_red_vial.py](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/scripts/vincular_red_vial.py) que no depende de licencias *Advanced* (`Near_analysis`).
   - Utiliza métodos geométricos nativos (`polyline.queryPointAndDistance()`), proyectando el punto sobre el eje de la calle más cercana.
   - Actualiza automáticamente `dist_via_m`, `lat_ruta`, `lon_ruta`, traslada las entidades de [postgrados_nodos_acceso.shp](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados/postgrados_nodos_acceso.shp) exactamente sobre la calzada y sincroniza el CSV y GeoJSON.
3. **Red Vial Estructurante de Santa Cruz / Campus UAGRM:**
   - Se construyó la capa [red_vial_uagrm_referencial.shp](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados/red_vial_uagrm_referencial.shp) con las avenidas y calles clave (Av. Busch, Av. Centenario, 2do Anillo, Av. Irala, Calle México, Calle Venezuela, etc.), ejecutando el snapping real sobre los 13 centros urbanos.
4. **Identificadores para Consulta Móvil y Código QR:**
   - Generación del campo `cod_qr` normalizado bajo el estándar `UAGRM-PG-[SIGLA]` (ej. `UAGRM-PG-FICCT`, `UAGRM-PG-DGP`).
   - Campo de auditoría `estado_geo` con valores `Verificado` y `Revisar_Campo` para control de calidad cartográfica.

---

### FASE 4: Documentación Operativa para ArcMap 10.8
Se actualizó el manual técnico completo en [README_ARCMAP108.md](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/README_ARCMAP108.md), que detalla:
- Instrucción sobre activación de **Store relative pathnames to data sources** en ArcMap 10.8 para evitar enlaces rotos.
- Diccionario de datos actualizado con 24 campos físicos y sus respectivos **Field Aliases**.
- Guía de 6 pasos para operar en ArcMap 10.8 (Carga, Definition Query, Simbología, Digitalización, Ruteo y QR).

---

## 3. INVENTARIO COMPLETO DE ARCHIVOS ENTREGADOS

| Archivo / Directorio | Formato | Sistema de Coordenadas | Función Principal |
|---|---|---|---|
| `output_postgrados/postgrados_uagrm_pts.*` | Shapefile (`.shp`, `.dbf`, `.shx`, `.prj`, `.cpg`) | `EPSG:32720` (UTM 20S) | Capa principal de 19 puntos con atributos completos (24 campos). |
| `output_postgrados/postgrados_uagrm_poly.*` | Shapefile (`.shp`, `.dbf`, `.shx`, `.prj`, `.cpg`) | `EPSG:32720` (UTM 20S) | Capa de polígonos (buffers de 15 m) para digitalizar huellas. |
| `output_postgrados/postgrados_nodos_acceso.*` | Shapefile (`.shp`, `.dbf`, `.shx`, `.prj`, `.cpg`) | `EPSG:32720` (UTM 20S) | Puntos de acceso sobre el eje vial para Network Analyst y ruteo. |
| `output_postgrados/red_vial_uagrm_referencial.*` | Shapefile (`.shp`, `.dbf`, `.shx`, `.prj`, `.cpg`) | `EPSG:32720` (UTM 20S) | Ejes de avenidas y calles estructurantes de la zona universitaria. |
| `output_postgrados/postgrados_uagrm.gdb` | ESRI File Geodatabase | `EPSG:32720` (UTM 20S) | Geodatabase que agrupa las 4 feature classes con Field Aliases. |
| `output_postgrados/postgrados_uagrm.csv` | CSV (UTF-8 con BOM) | WGS 84 y UTM 20S | Archivo alfanumérico para *Add XY Data* en ArcMap o Excel. |
| `output_postgrados/postgrados_uagrm_web.geojson` | GeoJSON (RFC 7946) | `EPSG:4326` (WGS 84) | Dataset para la aplicación web interactiva y móviles. |
| `scripts/generar_capa_postgrados.py` | Python 2.7 (ArcPy) | N/A | Script reproducible de generación cartográfica con rutas relativas. |
| `scripts/vincular_red_vial.py` | Python 2.7 (ArcPy) | N/A | Algoritmo de snapping compatible con licencias ArcMap Basic. |
| `scripts/crear_red_vial_referencial.py` | Python 2.7 (ArcPy) | N/A | Generador de red vial referencial de avenidas universitarias. |
| `scripts/verificar_calidad_sig.py` | Python 2.7 (ArcPy) | N/A | Script de auditoría y certificación de calidad de capas. |
| `README_ARCMAP108.md` | Markdown | N/A | Manual técnico y guía de usuario paso a paso para ArcMap 10.8. |

---

## 4. CUADRO CONSOLIDADO DE LAS 19 UNIDADES DE POSTGRADO

| ID | Sigla | Unidad de Postgrado | Ámbito | Campus / Zona | Estado Geo | Distancia a Vía | Código QR |
|---|---|---|---|---|---|---|---|
| **PG-00** | DGP | Escuela de Postgrado UAGRM (DGP) | Urbano | Zona Central | Verificado | 4.09 m | `UAGRM-PG-DGP` |
| **PG-01** | FICH | Unidad de Postgrado FICH | Provincial | Camiri | Verificado | 0.00 m | `UAGRM-PG-FICH` |
| **PG-02** | FINOR | Unidad de Postgrado FINOR | Provincial | Montero | Verificado | 0.00 m | `UAGRM-PG-FINOR` |
| **PG-03** | FCCASCGF | Unidad de Postgrado Ciencias Contables | Urbano | Campus Universitario | Revisar_Campo | 30.61 m | `UAGRM-PG-FCCASCGF` |
| **PG-04** | FCHDA | Unidad de Postgrado FCHDA | Urbano | Externo | Revisar_Campo | 4.04 m | `UAGRM-PG-FCHDA` |
| **PG-05** | FH | Unidad de Postgrado Humanidades | Urbano | Campus Universitario | Revisar_Campo | 0.73 m | `UAGRM-PG-FH` |
| **PG-06** | FCSH | Unidad de Postgrado en Salud UAGRM | Urbano | Zona Central | Revisar_Campo | 0.00 m | `UAGRM-PG-FCSH` |
| **PG-07** | FCJPSRI | Unidad de Posgrado FCJPSRRII | Urbano | Campus Universitario | Verificado | 63.53 m | `UAGRM-PG-FCJPSRI` |
| **PG-08** | FCEE | UAGRM Business School | Urbano | Zona Central | Verificado | 1.22 m | `UAGRM-PG-FCEE` |
| **PG-09** | FCV | Unidad de Postgrado Veterinaria | Urbano | Ciudad Universitaria | Verificado | 61.04 m | `UAGRM-PG-FCV` |
| **PG-10** | FCA | Unidad de Postgrado Ciencias Agrícolas | Urbano | Externo | Verificado | 4.55 m | `UAGRM-PG-FCA` |
| **PG-11** | FCET | UPCET / Escuela de Ingeniería | Urbano | Campus Universitario | Verificado | 1.90 m | `UAGRM-PG-FCET` |
| **PG-12** | FP | Escuela Superior Politécnica (UPFP) | Urbano | Ciudad Universitaria | Revisar_Campo | 37.02 m | `UAGRM-PG-FP` |
| **PG-13** | FINI | Unidad de Postgrado FINI | Provincial | Yapacaní | Revisar_Campo | 0.00 m | `UAGRM-PG-FINI` |
| **PG-14** | FAICHI | Unidad de Postgrado FAICHI | Provincial | San Ignacio de Velasco | Verificado | 0.00 m | `UAGRM-PG-FAICHI` |
| **PG-15** | FCFB | Unidad de Posgrado Farmacia y Bioquímica | Urbano | Ciudad Universitaria | Verificado | 65.74 m | `UAGRM-PG-FCFB` |
| **PG-16** | FICCT | UAGRM School of Engineering (SOE) | Urbano | Ciudad Universitaria | Verificado | 9.87 m | `UAGRM-PG-FICCT` |
| **PG-17** | FIVC | Unidad de Postgrado FIVC | Provincial | Vallegrande | Verificado | 0.00 m | `UAGRM-PG-FIVC` |
| **PG-18** | FINE | Unidad de Postgrado FINE | Provincial | San Julián | Revisar_Campo | 0.00 m | `UAGRM-PG-FINE` |

---

## 5. RESULTADO DE LA VERIFICACIÓN AUTOMÁTICA DE CALIDAD

Ejecutado con `C:\Python27\ArcGIS10.8\python.exe scripts\verificar_calidad_sig.py`:

```
======================================================================
INFORME DE CONTROL DE CALIDAD - ARCGIS DESKTOP / ARCMAP 10.8
======================================================================
1. INSPECCION DE SHAPEFILES Y CRS:
   - postgrados_uagrm_pts.shp         | Tipo: Point    | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 19
   - postgrados_uagrm_poly.shp        | Tipo: Polygon  | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 19
   - postgrados_nodos_acceso.shp      | Tipo: Point    | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 19
   - red_vial_uagrm_referencial.shp   | Tipo: Polyline | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 10

2. INSPECCION DE FILE GEODATABASE (postgrados_uagrm.gdb):
   - postgrados_uagrm_pts             | Tipo: Point    | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 19
   - postgrados_uagrm_poly            | Tipo: Polygon  | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 19
   - postgrados_nodos_acceso          | Tipo: Point    | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 19
   - red_vial_uagrm_referencial       | Tipo: Polyline | CRS: WGS_1984_UTM_Zone_20S    | Entidades: 10

3. INSPECCION DE FORMATOS DE INTERCAMBIO:
   - postgrados_uagrm.csv            | Lineas totales: 20 | Registros de datos: 19
   - postgrados_uagrm_web.geojson    | Features GeoJSON: 19 | CRS: urn:ogc:def:crs:OGC:1.3:CRS84

4. INTEGRIDAD DE CARACTERES ESPECIALES:
   - [PG-00] Escuela de Postgrado UAGRM (Dirección General de Posgrado) | Av. Irala N° 565, 5to piso
   - [PG-03] Unidad de Postgrado Ciencias Contables | Maestrías en Auditoría, Finanzas Corporativas
   - [PG-04] Unidad de Postgrado FCHDA | Maestrías en Arquitectura y Urbanismo, Diplomados en Diseño Sostenible
   -> 100% Sin caracteres corruptos (mojibake).
======================================================================
```

---

### FASE 5: Capa de Base de Datos Espacial en Supabase (PostgreSQL + PostGIS)

En esta fase se construyó e implementó la persistencia espacial de la plataforma WebGIS en la nube (**Supabase**), sincronizada con las capas validadas en ArcMap 10.8:

1. **Esquema DDL Idempotente ([database/schema.sql](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/database/schema.sql)):**
   - Activación de extensión `postgis`.
   - Creación de tabla `public.postgrados_uagrm` con los 24 campos exactos del diccionario cartográfico más 3 columnas espaciales PostGIS en `EPSG:4326`:
     - `geom`: Edificio principal (Point).
     - `geom_acceso`: Nodo de acceso vial para ruteo (Point, snapped a calzada).
     - `geom_poly`: Huella digitalizada de edificación (Polygon, nullable).
   - Creación de tabla `public.servicios_apoyo` para cumplimiento del **Requisito #22** (Centros Médicos, Extintores, Accesos al Campus y Puntos de Encuentro) con restricción `CHECK` y columna `es_referencial BOOLEAN`.
   - Índices espaciales `GiST` aceleradores y de búsqueda `B-Tree`.
   - Seguridad mediante **Row Level Security (RLS)** con políticas de lectura pública (`anon`, `authenticated`) y escritura protegida para backend.

2. **Generador Reproducible de Seeds ([scripts/generar_seed_supabase.py](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/scripts/generar_seed_supabase.py)):**
   - Desarrollado utilizando exclusivamente la librería estándar de Python (`os`, `io`, `json`).
   - Probado y certificado al 100% en **Python 3.14** y **Python 2.7.16 (ArcGIS 10.8)**.
   - Lee dinámicamente `output_postgrados/postgrados_uagrm_web.geojson` y construye `database/seed_data.sql` en UTF-8 limpio con geometrías `ST_SetSRID(ST_MakePoint(lon, lat), 4326)`.
   - Estructura de inserción idempotente mediante cláusulas `ON CONFLICT (id_postg) DO UPDATE SET ...`.

3. **Datos Semilla ([database/seed_data.sql](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/database/seed_data.sql)):**
   - 19 Unidades de Postgrado con coordenadas y atributos completos.
   - 12 Servicios de apoyo y seguridad referenciales geolocalizados en el Campus Universitario, Ciudad Universitaria (Av. Busch, Centenario, 2do Anillo) y Zona Central.

4. **Suite de Verificación, Migración y Certificación en la Nube:**
   - [database/verify_postgis.sql](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/database/verify_postgis.sql): 4 pruebas SQL de versión PostGIS, conteo (19 y 12), extracción GeoJSON nativa y análisis espacial `ST_DWithin` a 600 m de la FICCT (`PG-16`).
   - [scripts/migrar_supabase.py](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/scripts/migrar_supabase.py): Script de automatización que conecta por SSL a PostgreSQL 17 en Supabase y ejecuta el DDL, el seed y las pruebas espaciales.
   - [database/README_SUPABASE.md](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/database/README_SUPABASE.md): Manual técnico de despliegue y sincronización continua desde ArcMap 10.8.
   - **Configuración de Entorno ([.env](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/.env)):** Variables de conexión protegidas (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `DATABASE_URL`).
   - **Certificación Operativa:**
     - Conexión SSL exitosa a `db.woyjgoxglpsjrqpwhuzd.supabase.co`.
     - Motor activo: **PostgreSQL 17.12** con **PostGIS 3.3.7** (`GEOS 3.14.1`, `PROJ 9.7.1`).
     - Tablas verificadas: `postgrados_uagrm` (**19 registros**) y `servicios_apoyo` (**12 registros**).
     - Validación de caracteres especiales: 100% íntegros (`Dirección`, `Auditoría`, `Hábitat`, `Politécnica`).
     - Consulta espacial `ST_DWithin`: 11 servicios detectados a menos de 600 m de la FICCT (ej. Extintor Módulo 232 a 8.83 m).
     - Endpoint PostgREST API validado con **HTTP 200** utilizando la Publishable Key (`sb_publishable_...`).

---

### FASE 6: Backend API con FastAPI y PostGIS (Listo para Render)

En esta fase se diseñó, construyó y certificó el **Backend API REST / WebGIS** en Python 3 utilizando **FastAPI** y el driver de alto desempeño **psycopg v3** (`psycopg[binary]`), conectado a **PostgreSQL 17 + PostGIS** en **Supabase** y configurado con especificación Infrastructure-as-Code para despliegue en **Render** (`render.yaml`).

#### 1. Principios Arquitectónicos
- **Cero Sobreingeniería (Sin ORM pesados):** Se prescindió de capas lentas como SQLAlchemy. Las operaciones espaciales se delegan al motor nativo de PostGIS mediante SQL directo parametrizado, aprovechando `ST_AsGeoJSON(geom)::json` para serialización instantánea en GeoJSON RFC 7946, `ST_DWithin` para filtrado geodésico y `ST_Distance` para cálculo métrico en el esferoide WGS 84.
- **Gestión de Recursos y Conexiones:** Módulo [backend/db.py](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/backend/db.py) con context manager (`get_db_cursor`) y fábrica de filas `dict_row`, asegurando liberación inmediata de conexiones y compatibilidad SSL forzada (`sslmode=require`).
- **CORS Configurable:** Habilitado mediante `CORS_ORIGINS` (por defecto `*`) para consumo transparente desde `localhost` y despliegues frontend en Cloudflare Pages o Vercel.
- **Documentación Interactiva:** OpenAPI 3.1 disponible de forma nativa en `/docs` (Swagger UI) y `/redoc`.

#### 2. Catálogo de Endpoints Implementados en [backend/main.py](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/backend/main.py)
1. **`GET /`**: Diagnóstico general, estado del servicio y enlace a documentación interactiva.
2. **`GET /api/health`**: Verificación en tiempo real de conexión a Supabase, reporte de versión de PostGIS (`3.3 USE_GEOS=1...`) y conteos de filas (`postgrados = 19`, `servicios = 12`).
3. **`GET /api/postgrados`**: Generación directa de GeoJSON `FeatureCollection` con las 19 unidades de postgrado, atributos completos (incluyendo `lat_ruta`, `lon_ruta`, `dist_via_m`, `cod_qr`, `programas`, `url_foto`, etc.) y filtros por `ambito`, `campus`, `tipo_ent` y búsqueda general `q`.
4. **`GET /api/postgrados/{id_postg}`**: Retorna una unidad específica como GeoJSON `Feature` (ej. `PG-16`) o HTTP `404` si no existe.
5. **`GET /api/postgrados/qr/{cod_qr}`**: **Requisito #21 (Consulta móvil por QR)**. Búsqueda directa por código unificado (`UAGRM-PG-FICCT`), entregando el `Feature` completo para la vista móvil.
6. **`GET /api/servicios`**: Retorna `FeatureCollection` con los 12 servicios de apoyo y seguridad, con filtro opcional por `tipo` (`Centro_Medico`, `Extintor`, `Acceso_Campus`, `Punto_Encuentro`).
7. **`GET /api/servicios/cercanos`**: **Requisito #22 (Seguridad y apoyo en ruta/destino)**. Consulta espacial geodésica mediante `ST_DWithin(geom::geography, ...)` y ordenamiento por `ROUND(ST_Distance(...)::numeric, 2) AS distancia_m`.
8. **`GET /api/resumen`**: Métricas cuantitativas y contadores agregados (urbanos, provinciales, verificados, desglose de servicios) para alimentar el panel de control web.

#### 3. Resultados de la Suite de Pruebas Automatizadas ([backend/test_api.py](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/backend/test_api.py))
Ejecución certificada contra la base de datos real en Supabase mediante `TestClient`:
```
===========================================================================
INICIANDO SUITE DE PRUEBAS: FASTAPI + SUPABASE POSTGIS
===========================================================================
  [OK] GET / -> 200 (API Online)
  [OK] GET /api/health -> 200 | PostGIS: 3.3 USE_GEOS=1 ... | Postgrados: 19 | Servicios: 12
  [OK] GET /api/postgrados -> 200 | 19 Features GeoJSON | UTF-8 íntegro (tildes confirmadas)
  [OK] GET /api/postgrados?ambito=Urbano -> 200 | 13 Features Urbanas
  [OK] GET /api/postgrados?q=FICCT -> 200 | Incluye PG-16 (FICCT)
  [OK] GET /api/postgrados/PG-16 -> 200 | PG-999 -> 404
  [OK] GET /api/postgrados/qr/UAGRM-PG-FICCT -> 200 (PG-16) | /qr/INEXISTENTE -> 404
  [OK] GET /api/servicios -> 200 (12 servicios) | tipo=Centro_Medico -> 200 (3)
  [OK] GET /api/servicios/cercanos -> 200 | 11 servicios a <=600m | Mas cercano: SERV-07 (8.83m)
  [OK] GET /api/resumen -> 200 | Contadores validados con éxito

----------------------------------------------------------------------
Ran 10 tests in 16.851s
OK (100% de pruebas en verde)
```

---

## 6. INVENTARIO COMPLETO DE ARCHIVOS DEL PROYECTO (ACTUALIZADO)

| Archivo / Directorio | Formato | Función Principal |
|---|---|---|
| `output_postgrados/postgrados_uagrm_pts.*` | Shapefile (UTM 20S) | Capa principal de 19 puntos con atributos completos (24 campos). |
| `output_postgrados/postgrados_uagrm_poly.*` | Shapefile (UTM 20S) | Capa de polígonos (buffers de 15 m) para digitalizar huellas. |
| `output_postgrados/postgrados_nodos_acceso.*` | Shapefile (UTM 20S) | Puntos de acceso sobre el eje vial para Network Analyst y ruteo. |
| `output_postgrados/red_vial_uagrm_referencial.*` | Shapefile (UTM 20S) | Ejes de avenidas y calles estructurantes de la zona universitaria. |
| `output_postgrados/postgrados_uagrm.gdb` | ESRI File Geodatabase | Geodatabase que agrupa las 4 feature classes con Field Aliases. |
| `output_postgrados/postgrados_uagrm.csv` | CSV (UTF-8 con BOM) | Archivo alfanumérico para *Add XY Data* en ArcMap o Excel. |
| `output_postgrados/postgrados_uagrm_web.geojson` | GeoJSON (EPSG:4326) | Dataset fuente para la aplicación web interactiva y móviles. |
| `scripts/generar_capa_postgrados.py` | Python 2.7 (ArcPy) | Script reproducible de generación cartográfica. |
| `scripts/vincular_red_vial.py` | Python 2.7 (ArcPy) | Snapping geométrico a red vial compatible con ArcMap Basic. |
| `scripts/crear_red_vial_referencial.py` | Python 2.7 (ArcPy) | Generador de red vial de avenidas universitarias. |
| `scripts/verificar_calidad_sig.py` | Python 2.7 (ArcPy) | Script de auditoría de capas ArcMap. |
| `scripts/generar_seed_supabase.py` | Python 2.7 y 3.x | Generador de SQL seed para Supabase desde el GeoJSON. |
| `scripts/migrar_supabase.py` | Python 3.x | Script de migración y ejecución directa contra Supabase vía SSL. |
| `database/schema.sql` | SQL PostGIS | Esquema DDL de tablas, extensiones, índices GiST y RLS en Supabase. |
| `database/seed_data.sql` | SQL UTF-8 | Inserciones idempotentes (19 postgrados + 12 servicios de apoyo). |
| `database/verify_postgis.sql` | SQL | Consultas de verificación espacial en Supabase SQL Editor. |
| `database/README_SUPABASE.md` | Markdown | Manual de despliegue y sincronización Supabase. |
| `backend/main.py` | Python 3 (FastAPI) | Aplicación API WebGIS con endpoints espaciales GeoJSON, QR y proximidad. |
| `backend/db.py` | Python 3 (Psycopg v3) | Capa de conexión y cursores PostGIS con dict_row y SSL forzado. |
| `backend/requirements.txt` | Texto | Dependencias mínimas del backend (FastAPI, uvicorn, psycopg, dotenv, httpx). |
| `backend/test_api.py` | Python 3 (TestClient) | Suite de 10 pruebas automatizadas contra Supabase en producción. |
| `backend/.env.example` | Configuración | Plantilla de variables para backend con advertencia de red IPv4/IPv6. |
| `backend/README_BACKEND.md` | Markdown | Manual operativo del backend y guía paso a paso para Render. |
| `render.yaml` | YAML IaC | Manifiesto de infraestructura para despliegue automatizado en Render. |
| `.env` / `.env.example` | Configuración | Credenciales y cadenas de conexión a Supabase y PostgreSQL. |
| `.gitignore` | Git | Protección de archivos sensibles y temporales. |
| `README_ARCMAP108.md` | Markdown | Manual técnico y guía de usuario para ArcMap 10.8. |
| `RESUMEN_IMPLEMENTACION.md` | Markdown | Bitácora ejecutiva consolidada de todo el proyecto. |

---

## 7. PASOS MANUALES PENDIENTES PARA DESPLIEGUE EN RENDER

Para desplegar la API en la nube pública de **Render** de manera gratuita y permanente:

1. **Obtener la URL IPv4 del Session Pooler de Supabase:**
   - En tu panel de Supabase: ir a **Project Settings** -> **Database** -> **Connection String** -> pestaña **Connection pooling** -> modo **Session** (puerto `5432`).
   - Copiar la URI resultante (tendrá el formato `postgresql://postgres.[REF]:[PASS]@aws-0-[REGION].pooler.supabase.com:5432/postgres?sslmode=require`).
   - *(Nota: No utilizar la URL directa `db.xxx.supabase.co` en Render porque solo resuelve por IPv6 en planes gratuitos).*

2. **Sincronizar el Repositorio en GitHub:**
   - Hacer commit de la nueva carpeta `backend/` y el archivo `render.yaml`.
   - Subir los cambios a tu rama principal de GitHub (`git push origin main`).

3. **Crear el Web Service en Render:**
   - En [dashboard.render.com](https://dashboard.render.com), seleccionar **New +** -> **Web Service**.
   - Conectar tu repositorio de GitHub.
   - Si Render detecta `render.yaml`, aplicará la configuración automáticamente. Si se configura manualmente:
     - **Root Directory:** `backend`
     - **Runtime:** `Python 3`
     - **Build Command:** `pip install -r requirements.txt`
     - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
     - **Instance Type:** `Free`

4. **Cargar Variables de Entorno en el Panel de Render:**
   - En la sección **Environment**:
     - `PYTHON_VERSION`: `3.12.8`
     - `CORS_ORIGINS`: `*`
     - `DATABASE_URL`: La URL del **Session Pooler** obtenida en el Paso 1.

5. **Validar Despliegue Exitoso:**
   - Una vez que el estado pase a **Live**, abrir `https://[TU-APP].onrender.com/docs` para visualizar Swagger UI.
   - Ejecutar una petición a `https://[TU-APP].onrender.com/api/health` para comprobar que responda `status: ok` y `database: connected`.

---
*Fin del resumen ejecutivo actualizado (Fases 1 a 4 ArcMap 10.8 + Fase 5 Supabase PostGIS + Fase 6 Backend API FastAPI).*
