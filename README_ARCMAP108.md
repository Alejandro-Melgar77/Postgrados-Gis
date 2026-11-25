# PROYECTO SIG UAGRM: CAPA DE ESCUELAS Y UNIDADES DE POSTGRADO
## Asignatura: INF442-SA — Sistemas de Información Geográfica (Gestión 2026-2)
**Proyecto General:** *"Mapa de Infraestructura de la Universidad Autónoma Gabriel René Moreno (UAGRM) de la ciudad de Santa Cruz de la Sierra"*  
**Subgrupo / Responsabilidad:** Capa 8 — Escuelas y Unidades de Postgrado (18 Facultades + Dirección General de Posgrado)  
**Software SIG Base:** **ArcGIS Desktop / ArcMap 10.8** (100% compatible sin ArcGIS Pro)

---

## 1. SISTEMA DE REFERENCIA DE COORDENADAS (CRS / METADATOS)

Para garantizar la total compatibilidad con el entorno de ArcMap 10.8, evitar advertencias de transformación en vuelo (*Data Frame Transformation Warning*) y permitir cálculos métricos exactos de área y distancia, se configuraron dos sistemas oficiales:

1. **CRS de las Capas de ArcMap 10.8 (Shapefiles y Geodatabase):**
   - **Nombre oficial:** WGS 1984 UTM Zone 20S
   - **Código EPSG:** `EPSG:32720`
   - **Tipo:** Proyectado métrico (Unidades: Metros)
   - **Meridiano Central:** -63.0°
   - **Factor de Escala:** 0.9996
   - **Falso Este / Falso Norte:** 500,000.0 m / 10,000,000.0 m
   - **Definición ESRI WKT1 idéntica incorporada en cada `.prj`:**
     ```text
     PROJCS["WGS_1984_UTM_Zone_20S",GEOGCS["GCS_WGS_1984",DATUM["D_WGS_1984",SPHEROID["WGS_1984",6378137.0,298.257223563]],PRIMEM["Greenwich",0.0],UNIT["Degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["False_Easting",500000.0],PARAMETER["False_Northing",10000000.0],PARAMETER["Central_Meridian",-63.0],PARAMETER["Scale_Factor",0.9996],PARAMETER["Latitude_Of_Origin",0.0],UNIT["Meter",1.0]]
     ```
   - **Codificación de texto de la tabla DBF:** `UTF-8` garantizada mediante el archivo complementario `.cpg` en cada shapefile para lectura transparente de tildes y eñes en ArcMap.

2. **CRS para WebGIS y Dispositivos Móviles (GeoJSON):**
   - **Nombre:** WGS 84 (Geográficas)
   - **Código EPSG:** `EPSG:4326` (CRS84)
   - **Unidades:** Grados decimales

---

## 2. ESTRUCTURA DE ARCHIVOS GENERADOS

Todos los archivos generados se encuentran en la carpeta [output_postgrados/](file:///c:/Users/Ale/Documents/sig/proyecto_postgrados_sig/output_postgrados):

```
proyecto_postgrados_sig/
├── output_postgrados/
│   ├── postgrados_uagrm_pts.shp         <- Capa principal de 19 puntos (EPSG:32720)
│   ├── postgrados_uagrm_pts.shx         <- Índice posicional de entidades
│   ├── postgrados_uagrm_pts.dbf         <- Tabla de atributos completa (UTF-8)
│   ├── postgrados_uagrm_pts.prj         <- Proyección ESRI WKT1 UTM 20S
│   ├── postgrados_uagrm_pts.cpg         <- Archivo de página de códigos UTF-8
│   ├── postgrados_uagrm_poly.shp        <- Capa de polígonos (huellas/buffers 15 m)
│   ├── postgrados_uagrm_poly.dbf
│   ├── postgrados_uagrm_poly.prj
│   ├── postgrados_uagrm_poly.cpg
│   ├── postgrados_nodos_acceso.shp      <- Puntos de acceso para ruteo/Network Analyst
│   ├── postgrados_nodos_acceso.dbf
│   ├── postgrados_nodos_acceso.prj
│   ├── postgrados_nodos_acceso.cpg
│   ├── red_vial_uagrm_referencial.shp   <- Red vial de avenidas y calles estructurantes
│   ├── red_vial_uagrm_referencial.dbf
│   ├── red_vial_uagrm_referencial.prj
│   ├── red_vial_uagrm_referencial.cpg
│   ├── postgrados_uagrm.gdb/            <- File Geodatabase nativa 10.x con Field Aliases
│   ├── postgrados_uagrm.csv             <- Respaldo plano UTF-8 con BOM y XY doble
│   └── postgrados_uagrm_web.geojson     <- GeoJSON en EPSG:4326 para Leaflet/MapLibre
├── scripts/
│   ├── generar_capa_postgrados.py       <- Generador de capas automatizado con ArcPy
│   ├── vincular_red_vial.py             <- Algoritmo de snapping compatible con ArcMap Basic
│   ├── crear_red_vial_referencial.py    <- Generador de red vial de ejes universitarios
│   └── verificar_calidad_sig.py         <- Script de auditoría de control de calidad
├── README_ARCMAP108.md                  <- Este manual técnico y operativo
└── RESUMEN_IMPLEMENTACION.md            <- Resumen ejecutivo del proyecto
```

---

## 3. DICCIONARIO DE DATOS (ESQUEMA DE TABLA DE ATRIBUTOS Y ALIAS)

El esquema cumple estrictamente con el estándar DBF de Shapefile para ArcMap 10.8 (nombres de campo de máximo 10 caracteres, sin espacios, sin tildes ni caracteres especiales), y cuenta con **Field Aliases** profesionales dentro de `postgrados_uagrm.gdb`:

| N° | Nombre Campo | Tipo ArcMap | Longitud | Alias en Geodatabase | Descripción y Dominios Permitidos |
|---|---|---|---|---|---|
| 1 | `id_postg` | String (Text) | 10 | Identificador de Postgrado | Identificador único primario (`PG-00` a `PG-18`). |
| 2 | `cod_fac` | String (Text) | 12 | Sigla de Facultad | Sigla oficial facultativa (`DGP`, `FICCT`, `FCEE`, `FINOR`, etc.). |
| 3 | `nom_unidad` | String (Text) | 120 | Nombre de la Unidad de Postgrado | Nombre completo oficial de la Unidad de Postgrado. |
| 4 | `nom_facult` | String (Text) | 120 | Facultad Académica | Nombre completo de la Facultad a la que pertenece. |
| 5 | `tipo_ent` | String (Text) | 25 | Tipo de Entidad | Jerarquía: `Rectorado_DGP` \| `Unidad_Facultativa` \| `Sede_Provincial`. |
| 6 | `ambito` | String (Text) | 15 | Ámbito Territorial | Entorno geográfico: `Urbano` \| `Provincial`. |
| 7 | `municipio` | String (Text) | 40 | Municipio de Radicatoria | Municipio de radicatoria (ej. *Santa Cruz de la Sierra*, *Montero*, *Camiri*). |
| 8 | `campus` | String (Text) | 40 | Campus o Predio | Localización del predio: `Campus Universitario`, `Ciudad Universitaria`, `Zona Central`, `Externo`, `Sede Provincial`. |
| 9 | `modulo_pab` | String (Text) | 50 | Módulo o Pabellón | Denominación del pabellón o módulo (ej. *Módulo 232*, *Módulo 280*). |
| 10 | `direccion` | String (Text) | 150 | Dirección Oficial | Dirección postal / vial exacta. |
| 11 | `lat_wgs84` | Double | 19, 8 | Latitud (WGS 84) | Latitud en coordenadas geográficas WGS 84 (Y). |
| 12 | `lon_wgs84` | Double | 19, 8 | Longitud (WGS 84) | Longitud en coordenadas geográficas WGS 84 (X). |
| 13 | `lat_ruta` | Double | 19, 8 | Latitud Nodo de Acceso | Latitud del nodo de acceso a la red vial (Y). |
| 14 | `lon_ruta` | Double | 19, 8 | Longitud Nodo de Acceso | Longitud del nodo de acceso a la red vial (X). |
| 15 | `dist_via_m` | Double | 19, 3 | Distancia a la Vía (m) | Distancia perpendicular en metros al eje vial más cercano. |
| 16 | `telefono` | String (Text) | 40 | Teléfono / WhatsApp | Teléfono fijo y/o número de WhatsApp de contacto. |
| 17 | `correo` | String (Text) | 80 | Correo Electrónico | Correo electrónico institucional. |
| 18 | `horario` | String (Text) | 60 | Horario de Atención | Días y turnos de atención al público. |
| 19 | `estado_geo` | String (Text) | 20 | Estado Geográfico | Control de calidad: `Verificado` \| `Revisar_Campo`. |
| 20 | `cod_qr` | String (Text) | 30 | Código QR | Código alfanumérico para el QR del ambiente (ej. `UAGRM-PG-FICCT`). |
| 21 | `programas` | String (Text) | 120 | Programas de Postgrado | Resumen de oferta académica (Doctorados, Maestrías, Diplomados). |
| 22 | `sitio_web` | String (Text) | 120 | Sitio Web Oficial | URL institucional o portal de la facultad. |
| 23 | `url_foto` | String (Text) | 150 | Ruta de Fotografía | Ruta relativa a la fotografía (`assets/fotos/PG-XX.jpg`). |
| 24 | `area_m2` | Double | 19, 2 | Superficie Estimada (m²) | Área superficial en m² de la edificación o buffer. |

---

## 4. GUÍA PASO A PASO PARA OPERAR EN ARCMAP 10.8

> [!IMPORTANT]
> **CONFIGURACIÓN CRÍTICA DE RUTAS RELATIVAS EN ARCMAP 10.8:**
> Para evitar el problema común de capas con signo de exclamación rojo (*Broken Data Sources*) al mover el proyecto de computadora o cambiar de carpeta:
> 1. En ArcMap 10.8, abrí el menú **File -> Map Document Properties...**
> 2. Activá la casilla de verificación: **☑ Store relative pathnames to data sources**.
> 3. Hacé clic en **OK** y guardá el mapa (`Ctrl + S`).

---

### PASO 1: Carga de las Capas en ArcMap 10.8
1. Abrí **ArcMap 10.8** con un proyecto en blanco o tu archivo `.mxd` existente.
2. Asegurate de que el **Data Frame** esté configurado en `WGS 1984 UTM Zone 20S`:
   - Clic derecho en *Layers* (Marco de Datos) -> **Properties** -> Pestaña **Coordinate System**.
   - Navegá a `Projected Coordinate Systems` -> `Utm` -> `WGS 1984` -> `Southern Hemisphere` -> **WGS 1984 UTM Zone 20S**.
3. Añadí las capas mediante **Add Data** (icono del signo `+` amarillo) o arrastrándolas desde la ventana **ArcCatalog**:
   - `output_postgrados/postgrados_uagrm_pts.shp`
   - `output_postgrados/postgrados_uagrm_poly.shp`
   - `output_postgrados/postgrados_nodos_acceso.shp`
   - `output_postgrados/red_vial_uagrm_referencial.shp`
   - *(Recomendado)* También podés cargar directamente desde la File Geodatabase `output_postgrados/postgrados_uagrm.gdb`, lo que desplegará de forma automática los **Field Aliases** al consultar con la herramienta *Identify*.

---

### PASO 2: Filtrar Solo la Ciudad de Santa Cruz (Definition Query)
Para los planos temáticos del campus o la mancha urbana central de Santa Cruz de la Sierra:
1. En la *Table of Contents* (TOC), hacé clic derecho sobre `postgrados_uagrm_pts` -> **Properties**.
2. Dirigite a la pestaña **Definition Query**.
3. En el cuadro de texto ingresá la siguiente expresión SQL:
   ```sql
   "ambito" = 'Urbano'
   ```
4. Presioná **Apply** y luego **OK**.  
   *Resultado:* Se filtrarán automáticamente las 13 unidades de postgrado urbanas de la capital, ocultando las 6 sedes provinciales (*Montero, Camiri, Yapacaní, Vallegrande, San Ignacio, San Julián*) sin eliminarlas de la base de datos.
5. Para volver a visualizar la totalidad de la UAGRM departamental, simplemente eliminá el texto del *Definition Query*.

---

### PASO 3: Simbología Temática y Control de Calidad
Diferenciá visualmente las sedes con coordenadas confirmadas de aquellas pendientes de validación en terreno:
1. Clic derecho sobre `postgrados_uagrm_pts` -> **Properties** -> pestaña **Symbology**.
2. En la lista de la izquierda, seleccioná **Categories** -> **Unique values**.
3. En el campo **Value Field**, elegí: `estado_geo`.
4. Hacé clic en el botón inferior **Add All Values**.
5. Asigná una simbología intuitiva:
   - **`Verificado`**: Círculo o icono institucional de color **Verde (#2E7D32)**, tamaño 10 pt.
   - **`Revisar_Campo`**: Triángulo o círculo de advertencia de color **Naranja o Rojo (#D32F2F)**, tamaño 12 pt.
6. **Activar Etiquetas (Labels):**
   - En la pestaña **Labels**, marcá la casilla *"Label features in this layer"*.
   - En **Label Field**, seleccioná `cod_fac` (o `nom_unidad`).
   - Podés ingresar a **Expression...** para armar una etiqueta compuesta:
     ```text
     [cod_fac] & vbCrLf & [modulo_pab]
     ```

---

### PASO 4: Digitalización de Huellas de Edificios y Cálculo de Geometría
La capa `postgrados_uagrm_poly.shp` viene precargada con buffers referenciales de 15 m etiquetados como `tipo_geom = 'Referencial'`. Para digitalizar la huella real de cada edificio:

1. **Iniciar Edición:**
   - En el menú principal, activá la barra de herramientas: *Customize -> Toolbars -> **Editor***.
   - En la barra *Editor*, hacé clic en **Editor -> Start Editing** y seleccioná la capa `postgrados_uagrm_poly`.
2. **Ajuste fino de vértices o dibujo:**
   - Abrí la ventana **Create Features** (*Editor -> Editing Windows -> Create Features*).
   - Podés redibujar la huella real del edificio con la herramienta **Polygon** o editar los vértices existentes con la herramienta **Edit Tool** (flecha negra del Editor).
3. **Actualizar el tipo de geometría:**
   - Abrí la tabla de atributos de `postgrados_uagrm_poly`.
   - Modificá el valor del campo `tipo_geom` de `'Referencial'` a `'Huella_Real'`.
4. **Cálculo automático de superficie en m² (`area_m2`):**
   - Hacé clic derecho sobre el encabezado del campo **`area_m2`** -> seleccioná **Calculate Geometry...**
   - En *Property*, seleccioná **Area**.
   - En *Coordinate System*, asegurate de que esté en *"Use coordinate system of the data source: PCS: WGS 1984 UTM Zone 20S"*.
   - En *Units*, seleccioná **Square Meters [sq m]**.
   - Hacé clic en **OK**. Todos los valores de superficie se actualizarán con precisión centimétrica.
5. Guardá y finalizá la edición: **Editor -> Save Edits** y luego **Editor -> Stop Editing**.

---

### PASO 5: Conectividad y Preparación para Ruteo (Network Analyst)
Para implementar el análisis de rutas óptimas (del punto A al punto B, cálculo de distancias y servicios cercanos):

1. **Capa de Nodos de Acceso:**
   - Utilizá la capa auxiliar `postgrados_nodos_acceso.shp`.
   - Esta capa representa el punto exterior exacto de ingreso peatonal o vehicular a cada unidad académica sobre el eje vial más cercano.
2. **Carga en Network Analyst:**
   - Activá la extensión: *Customize -> Extensions -> marcar **Network Analyst***.
   - Abrí la barra *Network Analyst* y desplegá la ventana flotante **Network Analyst Window**.
   - Si creaste un *New Route*, hacé clic derecho en la categoría **Stops** -> **Load Locations...**
   - Seleccioná como entrada `postgrados_nodos_acceso` (o `postgrados_uagrm_pts`).
   - En *Name Field*, vinculá el campo `cod_fac` o `nom_unidad`.
3. **Snapping Automático con Licencia ArcMap Basic / Standard:**
   - Para no depender de licencias *Advanced* (`arcpy.Near_analysis`), ejecutá el script independiente implementado:
     ```powershell
     & "C:\Python27\ArcGIS10.8\python.exe" "scripts\vincular_red_vial.py" "ruta\a\tu_capa_vias.shp"
     ```
   - Este script utiliza métodos geométricos nativos (`polyline.queryPointAndDistance()`), proyecta el punto perpendicular sobre el eje vial, actualiza `dist_via_m`, `lat_ruta`, `lon_ruta`, traslada las geometrías de `postgrados_nodos_acceso` y actualiza inmediatamente el CSV y el GeoJSON.

---

### PASO 6: Consulta Móvil y Códigos QR para la Aplicación Web
Cada unidad posee un código normalizado en el campo `cod_qr` con la estructura:
`UAGRM-PG-[SIGLA_FACULTAD]` (ejemplo: `UAGRM-PG-FICCT`, `UAGRM-PG-FCEE`, `UAGRM-PG-DGP`).

- **Uso en WebGIS:** La capa `postgrados_uagrm_web.geojson` se encuentra lista para consumirse directamente en librerías web (Leaflet, MapLibre GL, OpenLayers).
- **Atributos de Consulta Móvil Incorporados:**
  - `programas`: Oferta de postgrados vigente.
  - `sitio_web`: Portal institucional para inscripciones.
  - `url_foto`: Enlace relativo estandarizado para despliegue de imagen del edificio en pop-up.
- **Pop-up Informativo:** En el visor web o en los pop-ups de ArcMap (herramienta *HTML Pop-up*), el atributo `cod_qr` permite consultar la ficha académica de la unidad, enlazar a WhatsApp de informes o desplegar el QR escaneable por los visitantes en el campus.

---

## 5. CONTROL DE CALIDAD Y AUDITORÍA AUTOMATIZADA

Para certificar la integridad de los datos antes de la defensa del proyecto, se dispone del script de verificación:

```powershell
& "C:\Python27\ArcGIS10.8\python.exe" "scripts\verificar_calidad_sig.py"
```

El script comprueba:
1. Conteo de entidades (19 registros exactos en todas las capas).
2. Proyección cartográfica `WGS_1984_UTM_Zone_20S` en `.shp` y `.gdb`.
3. Existencia de Field Aliases profesionales en la Geodatabase.
4. Ausencia total de caracteres corruptos en palabras con tilde o eñe (*Dirección*, *Auditoría*, *Hábitat*, *Politécnica*, *N°*).
5. Sincronización entre Shapefile, Geodatabase, CSV (UTF-8 con BOM) y GeoJSON.

---
*Documentación técnica conforme a los estándares de cartografía digital y bases de datos espaciales para ArcGIS Desktop 10.8 — UAGRM 2026.*
