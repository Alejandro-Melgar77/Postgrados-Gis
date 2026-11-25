# GUÍA RÁPIDA DE DEFENSA — INF442-SA (UAGRM 2026)
## Proyecto: Mapa de Infraestructura Universitaria — Capa 8: Escuelas y Unidades de Postgrado

Documento operativo para exponer y demostrar el ciclo SIG completo (escritorio + base espacial + API + WebGIS móvil) en **5 minutos**.

---

## 1. Arquitectura General del Sistema

```text
+-----------------------------------+      exportar_desde_arcmap.py
|  ArcMap 10.8 / ArcPy (Python 2.7) |      (recalcula area_m2 en UTM 20S
|  CRS: EPSG:32720 (UTM Zone 20S)   |       y reproyecta a EPSG:4326)
|  - postgrados_uagrm_pts   (19)    |-----------------+
|  - postgrados_uagrm_poly  (19)    |                 v
|  - postgrados_nodos_acceso (19)   |      generar_seed_supabase.py
|  - red_vial_uagrm_referencial     |      + migrar_supabase.py
+-----------------------------------+                 |
                                                      v
+-----------------------------------+      +------------------------------------+
|  Supabase PostgreSQL 17 + PostGIS |<-----|  FastAPI + psycopg v3 (Render)     |
|  CRS: EPSG:4326 (WGS 84)          | SSL  |  https://postgrados-gis.onrender.com|
|  - postgrados_uagrm (Point+Poly)  | IPv4 |  - GET /api/postgrados             |
|  - servicios_apoyo (12 puntos)    |Pooler|  - GET /api/postgrados/poligonos   |
|  - Indices GiST + RLS             |      |  - GET /api/postgrados/qr/{cod_qr} |
+-----------------------------------+      |  - GET /api/servicios/cercanos     |
                                           +------------------+-----------------+
                                                              | HTTPS / GeoJSON
                                                              v
                                           +------------------------------------+
                                           |  Frontend WebGIS (Cloudflare Pages)|
                                           |  https://postgrados-gis.pages.dev/ |
                                           |  - Leaflet.js + OSRM Routing       |
                                           |  - Escáner QR + Hoja Imprimible    |
                                           +------------------------------------+
```

---

## 2. Guion de Demostración en Vivo (5 Minutos)

1. **Minuto 1 — Escritorio ArcMap 10.8 (Tríada Vectorial y CRS):**
   - Mostrar en ArcMap las 4 capas en `postgrados_uagrm.gdb` proyectadas en `EPSG:32720 (WGS 1984 UTM Zone 20S)`: puntos (`postgrados_uagrm_pts`), polígonos de huellas (`postgrados_uagrm_poly`), nodos viales (`postgrados_nodos_acceso`) y ejes viales (`red_vial_uagrm_referencial`).
   - Destacar los **Field Aliases** y el algoritmo de snapping `queryPointAndDistance()` compatible con licencia Basic.
2. **Minuto 2 — Backend Espacial en Render (`/docs`):**
   - Abrir `https://postgrados-gis.onrender.com/docs` (Swagger UI).
   - Ejecutar `GET /api/health` (`status: ok`, `postgrados: 19`, `servicios: 12`) y `GET /api/postgrados/poligonos` mostrando que PostGIS serializa GeoJSON `Polygon` y áreas reales en `m²` directamente con `ST_AsGeoJSON(geom_poly)::json`.
3. **Minuto 3 — Visor WebGIS en Cloudflare Pages (`https://postgrados-gis.pages.dev/`):**
   - Mostrar contadores en vivo, filtros por ámbito (*Urbano* / *Provincial* / *Todos*), mapa base satelital Esri, toggle de **Huellas (Polígonos)**, **Servicios** y la **Tabla de Infraestructura** exportable a CSV.
4. **Minuto 4 — Requisito #21 (Ficha Móvil + Escaneo QR en Vivo):**
   - Abrir la hoja `qr-imprimible.html` (en papel o pantalla) y escanear con el celular el QR de la FICCT (`UAGRM-PG-FICCT`) o usar el botón **Escanear QR** del visor.
   - Mostrar que abre `https://postgrados-gis.pages.dev/?qr=UAGRM-PG-FICCT`, hace zoom automático y carga la ficha completa.
5. **Minuto 5 — Requisito #22 (Ruteo OSRM + Proximidad PostGIS `ST_DWithin`):**
   - En la ficha de FICCT, tocar **Cómo llegar**, elegir origen (*Entrada Ciudad Univ. Av. Busch* o *Mi ubicación GPS*) en modo **A pie**.
   - Mostrar la ruta trazada sobre calles reales con OSRM y la lista ordenada en metros de los **11 servicios de seguridad y apoyo** dentro de `600 m` calculados por PostGIS (`SERV-07 Extintor` a `8.83 m`, `SERV-11 Punto de Encuentro` a `44.69 m`, etc.).

---

## 3. Resincronización Rápida Tras Editar en ArcMap 10.8 (3 Comandos)

Cada vez que digitalices la huella real de un edificio en `postgrados_uagrm_poly` o muevas un punto `Revisar_Campo` en ArcMap 10.8, ejecutá estas **3 líneas** desde la raíz del proyecto:

```powershell
C:\Python27\ArcGIS10.8\python.exe scripts\exportar_desde_arcmap.py
python scripts\generar_seed_supabase.py
python scripts\migrar_supabase.py
```

*(Si además moviste edificios urbanos respecto a las calles y querés recalcular `lat_ruta`/`lon_ruta`/`dist_via_m`, ejecutá primero `C:\Python27\ArcGIS10.8\python.exe scripts\vincular_red_vial.py` antes de los 3 comandos).*

---

## 4. Respuestas Cortas a 5 Preguntas Técnicas Frecuentes

1. **¿Por qué usar UTM Zone 20S (`EPSG:32720`) en ArcMap y WGS 84 (`EPSG:4326`) en la web?**
   - `EPSG:32720` es un sistema proyectado en **metros**, indispensable en Santa Cruz de la Sierra para medir distancias a la vía (`dist_via_m`) y áreas reales (`shape.area` en `m²`) sin deformación angular. `EPSG:4326` es el estándar obligatorio para GeoJSON RFC 7946, GPS móvil, OSRM y Leaflet.

2. **¿Cuál es la diferencia entre `geometry` y `geography` en `ST_DWithin`?**
   - Sobre `geometry(Point, 4326)`, `ST_DWithin` calcula distancias en **grados** (incorrecto para radios en metros). Al hacer cast `geom::geography`, PostGIS calcula distancias **geodésicas exactas en metros** sobre el esferoide WGS 84.

3. **¿Por qué el backend en Render usa el Session Pooler IPv4 de Supabase en lugar del host directo `db.xxx.supabase.co`?**
   - El host directo de Supabase resuelve por **IPv6**, mientras que la red saliente de los planes gratuitos de Render opera sobre **IPv4**. El *Session Pooler* (`aws-1-us-east-1.pooler.supabase.com:5432`) expone conectividad IPv4 estable con `sslmode=require`.

4. **¿Cómo se logró el snapping a la red vial sin licencia ArcGIS Advanced (`Near_analysis`)?**
   - Usando el método nativo `polyline.queryPointAndDistance(point)` de ArcPy, disponible desde la licencia **ArcMap Basic**, que proyecta ortogonalmente cada edificio sobre el eje vial más próximo y guarda `lat_ruta`, `lon_ruta` y `dist_via_m`.

5. **¿Por qué existen dos geometrías puntuales (`geom` y `geom_acceso`) además de `geom_poly`?**
   - `geom` ubica el centro del edificio para cartografía temática; `geom_acceso` ubica el nodo sobre la calzada vial para que el router OSRM / Network Analyst trace recorridos reales hasta la entrada vehicular/peatonal; y `geom_poly` almacena la huella poligonal para análisis y cálculo de superficie edificada.
