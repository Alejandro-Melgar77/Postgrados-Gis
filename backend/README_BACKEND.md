# BACKEND API REST & WEBGIS — ESCUELAS Y UNIDADES DE POSTGRADO UAGRM 2026
## INF442-SA: Sistemas de Información Geográfica (UAGRM)

Backend espacial de alto rendimiento desarrollado con **Python 3**, **FastAPI** y el driver nativo **psycopg v3**, conectado a una base de datos **PostgreSQL 17 con extensión PostGIS** en **Supabase** y preparado para despliegue en **Render**.

---

## 1. CARACTERÍSTICAS PRINCIPALES

- **Arquitectura Liviana y Directa:** Sin ORMs pesados (sin SQLAlchemy). Consultas directas a PostGIS aprovechando `ST_AsGeoJSON(geom)::json`, `ST_DWithin` y `ST_Distance`.
- **Formato Estándar GeoJSON:** Todos los endpoints espaciales entregan objetos `FeatureCollection` o `Feature` conformes al estándar RFC 7946 en `EPSG:4326` (WGS 84), listos para consumir desde visores web (MapLibre GL, Leaflet, OpenLayers) o apps móviles.
- **Análisis Espacial en Tiempo Real (Requisito #22):** Endpoint `/api/servicios/cercanos` con cálculo métrico geodésico exacto sobre el esferoide WGS 84.
- **Consulta Móvil por Código QR (Requisito #21):** Endpoint `/api/postgrados/qr/{cod_qr}` para acceso inmediato mediante escaneo de etiquetas físicas.
- **Documentación Interactiva:** Generada automáticamente por FastAPI en `/docs` (Swagger UI) y `/redoc` (ReDoc).
- **CORS Configurable:** Variable `CORS_ORIGINS` para admitir solicitudes desde localhost, Cloudflare Pages o dominios universitarios.

---

## 2. ESTRUCTURA DE ARCHIVOS

```
backend/
├── db.py                 # Conexión resiliente a Supabase PostGIS con psycopg v3 (dict_row)
├── main.py               # Aplicación FastAPI, configuración CORS y endpoints espaciales
├── requirements.txt      # Dependencias mínimas y estables
├── test_api.py           # Suite de pruebas unitarias y de integración con TestClient
├── .env.example          # Plantilla de variables de entorno con advertencias de red
└── README_BACKEND.md     # Documentación técnica y manual operativo
```

---

## 3. INSTALACIÓN Y EJECUCIÓN LOCAL

### Paso 1: Configurar el Entorno Virtual (Python 3.10+)
```bash
cd backend
python -m venv venv
# En Windows (PowerShell):
.\venv\Scripts\Activate.ps1
# En Linux/macOS:
source venv/bin/activate
```

### Paso 2: Instalar Dependencias
```bash
pip install -r requirements.txt
```

### Paso 3: Configurar Variables de Entorno
Crea un archivo `.env` en `backend/` o en la raíz del proyecto basándote en `.env.example`:
```ini
DATABASE_URL=postgresql://postgres:TU_PASSWORD@db.TU_PROJECT_REF.supabase.co:5432/postgres?sslmode=require
CORS_ORIGINS=*
PORT=8000
```

### Paso 4: Iniciar el Servidor de Desarrollo
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
La API estará disponible en:
- API Root: `http://localhost:8000/`
- Documentación Swagger: `http://localhost:8000/docs`
- Documentación ReDoc: `http://localhost:8000/redoc`

---

## 4. CATÁLOGO DE ENDPOINTS

| Método | Endpoint | Descripción | Parámetros Clave |
|---|---|---|---|
| `GET` | `/` | Estado general de la API | Ninguno |
| `GET` | `/api/health` | Diagnóstico de conexión a Supabase y versión PostGIS | Ninguno |
| `GET` | `/api/postgrados` | GeoJSON `FeatureCollection` con las 19 unidades | `ambito`, `campus`, `tipo_ent`, `q` |
| `GET` | `/api/postgrados/{id_postg}` | GeoJSON `Feature` de una unidad específica | `id_postg` (ej. `PG-16`) |
| `GET` | `/api/postgrados/qr/{cod_qr}` | Consulta por código QR (**Requisito #21**) | `cod_qr` (ej. `UAGRM-PG-FICCT`) |
| `GET` | `/api/servicios` | GeoJSON `FeatureCollection` de servicios de apoyo | `tipo` (`Centro_Medico`, `Extintor`, etc.) |
| `GET` | `/api/servicios/cercanos` | Análisis de proximidad espacial (**Requisito #22**) | `lat`, `lon` (obligatorios), `radio_m`, `tipo` |
| `GET` | `/api/resumen` | Estadísticas consolidadas para el dashboard web | Ninguno |

---

## 5. GUÍA DE DESPLIEGUE EN RENDER

Render es una plataforma cloud ideal para desplegar el backend FastAPI en su capa gratuita (*Free Web Service*).

### [!] ADVERTENCIA CRÍTICA: IPv4 vs IPv6 (Supabase Session Pooler)
Los servicios web gratuitos de Render realizan peticiones de salida a través de **IPv4**.
Las URLs directas de Supabase (`db.xxx.supabase.co`) resuelven únicamente mediante **IPv6**, por lo que **fallarán con timeout de conexión en Render**.

**Solución Obligatoria:**
Obtén la URL del **Session Pooler (IPv4)** desde tu panel de Supabase:
1. Dirígete a **Project Settings** -> **Database**.
2. En la sección **Connection String**, selecciona el modo **URI** y marca la pestaña **Connection pooling**.
3. Selecciona el modo **Session** (puerto `5432`).
4. La URL tendrá la siguiente estructura:
   ```
   postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres?sslmode=require
   ```

### Pasos para Desplegar en Render:

1. **Subir el código a GitHub:**
   Asegúrate de que la carpeta `backend/` y el archivo `render.yaml` estén subidos a tu repositorio Git (recuerda que `.env` está en `.gitignore`).

2. **Crear el Web Service en Render:**
   - Inicia sesión en [render.com](https://render.com).
   - Haz clic en **New +** -> **Web Service**.
   - Conecta tu repositorio de GitHub.

3. **Configurar el Servicio:**
   - **Name:** `sig-postgrados-uagrm-api`
   - **Root Directory:** `backend`
   - **Runtime:** `Python 3`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Instance Type:** `Free`

4. **Configurar Variables de Entorno en Render:**
   En la pestaña **Environment**:
   - `PYTHON_VERSION`: `3.12.8`
   - `CORS_ORIGINS`: `*` (o la URL de tu frontend en Cloudflare Pages)
   - `DATABASE_URL`: Tu cadena de conexión IPv4 del **Session Pooler** de Supabase con `sslmode=require`.

5. **Verificación:**
   Una vez completado el despliegue (*Live*), ingresa a la URL proporcionada por Render (ej. `https://sig-postgrados-uagrm-api.onrender.com/docs`) y prueba el endpoint `/api/health`.
