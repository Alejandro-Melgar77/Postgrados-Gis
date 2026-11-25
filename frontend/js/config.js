/**
 * =============================================================================
 * CONFIGURACIÓN CENTRAL DEL FRONTEND WEBGIS (UAGRM — INF442-SA)
 * =============================================================================
 * INSTRUCCIÓN DE DESPLIEGUE:
 * Reemplazá ÚNICAMENTE la constante PRODUCTION_API_URL por la URL pública real
 * de tu Web Service en Render (sin barra inclinada "/" al final).
 * Ejemplo: "https://sig-postgrados-uagrm-api.onrender.com"
 * =============================================================================
 */
export const PRODUCTION_API_URL = "https://postgrados-gis.onrender.com";

const LOCAL_HOSTNAMES = new Set(["localhost", "127.0.0.1", "[::1]"]);

export const IS_LOCAL_ENV =
  LOCAL_HOSTNAMES.has(window.location.hostname) ||
  window.location.protocol === "file:";

export const API_BASE_URL = (
  IS_LOCAL_ENV ? "http://127.0.0.1:8000" : PRODUCTION_API_URL
).replace(/\/+$/, "");

/** Timeout generoso (60 s) para tolerar el Cold Start del plan Free de Render. */
export const API_TIMEOUT_MS = 60000;

/** Centro inicial del mapa: Zona Universitaria de Santa Cruz de la Sierra. */
export const INITIAL_MAP_CENTER = [-17.778, -63.188];
export const INITIAL_MAP_ZOOM = 14;

/** URL del servicio público de ruteo OSRM. */
export const OSRM_SERVICE_URL = "https://router.project-osrm.org/route/v1";

/** Radio predeterminado (en metros) para consulta PostGIS de servicios cercanos. */
export const DEFAULT_NEARBY_RADIUS_M = 600;

/** Puntos de inicio rápidos para cálculo de rutas (Requisito #22). */
export const QUICK_ORIGINS = [
  {
    id: "entrada-busch",
    label: "Entrada Ciudad Univ. Av. Busch",
    lat: -17.7749,
    lon: -63.19485,
  },
  {
    id: "entrada-centenario",
    label: "Entrada Campus Av. Centenario",
    lat: -17.7788,
    lon: -63.1926,
  },
  {
    id: "plaza-24",
    label: "Plaza 24 de Septiembre",
    lat: -17.78332,
    lon: -63.18214,
  },
];

/** Catálogo visual de tipos de entidad (Unidades de Postgrado). */
export const POSTGRADO_STYLES = {
  Rectorado_DGP: {
    label: "Rectorado / DGP",
    color: "#0f2b5b",
    accent: "#d4af37",
    badgeClass: "badge--dgp",
  },
  Unidad_Facultativa: {
    label: "Unidad Facultativa",
    color: "#8b1538",
    accent: "#ffffff",
    badgeClass: "badge--facultativa",
  },
  Sede_Provincial: {
    label: "Sede Provincial",
    color: "#0d7a6f",
    accent: "#ffffff",
    badgeClass: "badge--provincial",
  },
};

/** Catálogo visual de servicios de apoyo y seguridad (Requisito #22). */
export const SERVICIO_STYLES = {
  Centro_Medico: {
    label: "Centro Médico",
    color: "#dc2626",
    bg: "#fef2f2",
  },
  Extintor: {
    label: "Extintor",
    color: "#ea580c",
    bg: "#fff7ed",
  },
  Acceso_Campus: {
    label: "Acceso al Campus",
    color: "#2563eb",
    bg: "#eff6ff",
  },
  Punto_Encuentro: {
    label: "Punto de Encuentro",
    color: "#16a34a",
    bg: "#f0fdf4",
  },
};
