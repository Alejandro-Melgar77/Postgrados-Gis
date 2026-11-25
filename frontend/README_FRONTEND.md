# Frontend WebGIS — Unidades de Postgrado UAGRM (INF442-SA)

Aplicación web espacial **zero-build** (HTML5, CSS3, JavaScript ES Modules y librerías por CDN), optimizada para despliegue directo en **Cloudflare Pages** y conectada al backend FastAPI + Supabase PostGIS en **Render**.

---

## 1. Estructura de la Carpeta `frontend/`

```text
frontend/
├── index.html              # Interfaz WebGIS principal (Leaflet + Modales + Drawer)
├── css/
│   └── styles.css          # Estilos responsive (PC + móvil), leyenda, ficha y tabla
├── js/
│   ├── config.js           # ÚNICO archivo donde configurar PRODUCTION_API_URL
│   ├── api.js              # Cliente HTTP con tolerancia a Cold Start de Render (60s)
│   ├── map.js              # Mapa Leaflet, capas base, marcadores SVG, leyenda y servicios
│   ├── routing.js          # Ruteo OSRM + consulta PostGIS de servicios cercanos
│   ├── qr.js               # Lectura ?qr=, generador PNG imprimible y escáner móvil
│   └── app.js              # Controlador principal (filtros, ficha y tabla exportable)
├── assets/
│   └── placeholder.svg     # Imagen vectorial de respaldo cuando falte PG-XX.jpg
└── README_FRONTEND.md      # Esta guía de pruebas y despliegue
```

---

## 2. Prueba en Entorno Local

Necesitás dos terminales abiertas en la raíz del repositorio:

### Terminal 1 — Levantar Backend FastAPI
```powershell
cd backend
uvicorn main:app --port 8000
```

### Terminal 2 — Levantar Servidor Estático para `frontend/`
```powershell
python -m http.server 5500 --directory frontend
```

Abrí en el navegador:
- Visor principal: `http://127.0.0.1:5500/`
- Prueba directa de QR (Requisito #21): `http://127.0.0.1:5500/?qr=UAGRM-PG-FICCT`

*(Nota: Al detectar `localhost` o `127.0.0.1`, `js/config.js` apunta automáticamente a `http://127.0.0.1:8000`.)*

---

## 3. Despliegue en Cloudflare Pages (Sin Build Command)

1. Editá `frontend/js/config.js` y reemplazá la línea:
   ```js
   export const PRODUCTION_API_URL = "https://TU-SERVICIO.onrender.com";
   ```
   por la URL real de tu servicio en Render (sin `/` al final).
2. Subí los cambios a tu repositorio de GitHub (`main`).
3. En **Cloudflare Dashboard** → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**:
   - **Repository:** `Alejandro-Melgar77/Postgrados-Gis`
   - **Production branch:** `main`
   - **Framework preset:** `None`
   - **Build command:** *(dejar vacío)*
   - **Build output directory:** `frontend`
4. Hacé clic en **Save and Deploy**.

---

## 4. Verificación Post-Despliegue (Móvil + PC)

- Ingresá a `https://<tu-proyecto>.pages.dev/?qr=UAGRM-PG-FICCT` desde tu celular: debe abrir automáticamente la ficha de la FICCT y centrar el mapa.
- Probá **Escanear QR** con la cámara trasera (HTTPS habilitado automáticamente por Cloudflare Pages).
- Probá **Cómo llegar** -> **Mi ubicación GPS** y verificá que OSRM trace la ruta y PostGIS liste los servicios de seguridad cercanos con su distancia exacta en metros.
- Si querés restringir CORS en Render después de publicar, configurá `CORS_ORIGINS=https://<tu-proyecto>.pages.dev` en Render (por defecto `*` ya permite las peticiones).
