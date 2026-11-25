import { API_BASE_URL, API_TIMEOUT_MS, IS_LOCAL_ENV } from "./config.js";

/**
 * Cliente HTTP hacia el backend FastAPI con manejo amigable de Cold Start
 * de Render (banner no bloqueante, timeout de 60s y botón de reintento).
 */

let activeRequests = 0;
let slowNoticeTimer = null;
let lastRetryCallback = null;

function getBannerEls() {
  return {
    banner: document.getElementById("connection-banner"),
    text: document.getElementById("connection-banner-text"),
    subtext: document.getElementById("connection-banner-subtext"),
    spinner: document.getElementById("connection-spinner"),
    retryBtn: document.getElementById("connection-retry-btn"),
    dismissBtn: document.getElementById("connection-dismiss-btn"),
  };
}

function showConnectingBanner() {
  const { banner, text, subtext, spinner, retryBtn, dismissBtn } = getBannerEls();
  if (!banner) return;

  banner.hidden = false;
  banner.classList.remove("connection-banner--error");
  banner.classList.add("connection-banner--loading");

  if (text) {
    text.textContent = IS_LOCAL_ENV
      ? "Conectando con el servidor SIG en Render / API local..."
      : "Conectando con el servidor SIG en Render...";
  }
  if (subtext) {
    subtext.textContent = "Cargando capas geográficas desde Supabase PostGIS...";
  }
  if (spinner) spinner.hidden = false;
  if (retryBtn) retryBtn.hidden = true;
  if (dismissBtn) dismissBtn.hidden = true;

  if (!slowNoticeTimer) {
    slowNoticeTimer = window.setTimeout(() => {
      if (activeRequests > 0 && subtext) {
        subtext.textContent =
          "El servidor gratuito en Render está despertando (puede tardar 30–50 s en la primera petición)...";
      }
    }, 3000);
  }
}

function hideConnectingBanner() {
  const { banner } = getBannerEls();
  if (slowNoticeTimer) {
    window.clearTimeout(slowNoticeTimer);
    slowNoticeTimer = null;
  }
  if (banner && !banner.classList.contains("connection-banner--error")) {
    banner.hidden = true;
  }
}

function showErrorBanner(message, retryFn) {
  const { banner, text, subtext, spinner, retryBtn, dismissBtn } = getBannerEls();
  if (slowNoticeTimer) {
    window.clearTimeout(slowNoticeTimer);
    slowNoticeTimer = null;
  }
  if (!banner) return;

  lastRetryCallback = typeof retryFn === "function" ? retryFn : null;

  banner.hidden = false;
  banner.classList.remove("connection-banner--loading");
  banner.classList.add("connection-banner--error");

  if (text) {
    text.textContent = "No se pudo conectar con la API WebGIS";
  }
  if (subtext) {
    subtext.textContent = message;
  }
  if (spinner) spinner.hidden = true;
  if (retryBtn) retryBtn.hidden = !lastRetryCallback;
  if (dismissBtn) dismissBtn.hidden = false;
}

export function initApiBannerControls() {
  const { retryBtn, dismissBtn, banner } = getBannerEls();
  if (retryBtn) {
    retryBtn.addEventListener("click", () => {
      if (lastRetryCallback) {
        lastRetryCallback();
      }
    });
  }
  if (dismissBtn && banner) {
    dismissBtn.addEventListener("click", () => {
      banner.hidden = true;
      banner.classList.remove("connection-banner--error");
    });
  }
}

/**
 * Ejecuta una petición GET JSON/GeoJSON con AbortController (60s).
 * @param {string} endpoint Ruta relativa (ej. "/api/postgrados")
 * @param {Object} options Opciones: { showBanner = true, onRetry = null }
 */
export async function apiFetch(endpoint, options = {}) {
  const { showBanner = true, onRetry = null } = options;
  const url = `${API_BASE_URL}${endpoint}`;

  const controller = new AbortController();
  const timeoutId = window.setTimeout(() => controller.abort(), API_TIMEOUT_MS);

  activeRequests += 1;
  if (showBanner) {
    showConnectingBanner();
  }

  try {
    const response = await fetch(url, {
      method: "GET",
      headers: {
        Accept: "application/json",
      },
      signal: controller.signal,
    });

    if (!response.ok) {
      let detail = `HTTP ${response.status}`;
      try {
        const errBody = await response.json();
        if (errBody?.detail) {
          detail = errBody.detail;
        }
      } catch {
        // Ignorar si no es JSON
      }
      const err = new Error(detail);
      err.status = response.status;
      throw err;
    }

    const data = await response.json();
    activeRequests = Math.max(0, activeRequests - 1);
    if (activeRequests === 0) {
      hideConnectingBanner();
    }
    return data;
  } catch (error) {
    activeRequests = Math.max(0, activeRequests - 1);

    const isTimeout = error.name === "AbortError";
    const isNetwork =
      error instanceof TypeError ||
      /Failed to fetch|NetworkError|Load failed/i.test(error.message || "");

    if (isTimeout || isNetwork || (error.status && error.status >= 500)) {
      const friendlyMsg = isTimeout
        ? "Tiempo de espera agotado (60 s). Si Render está despertando, presioná Reintentar."
        : `Error de red al consultar ${API_BASE_URL}. Verificá que el backend esté activo.`;
      if (showBanner) {
        showErrorBanner(friendlyMsg, onRetry);
      }
    } else if (activeRequests === 0) {
      hideConnectingBanner();
    }

    throw error;
  } finally {
    window.clearTimeout(timeoutId);
  }
}

export function fetchResumen(onRetry = null) {
  return apiFetch("/api/resumen", { showBanner: true, onRetry });
}

export function fetchPostgrados(filters = {}, onRetry = null) {
  const params = new URLSearchParams();
  if (filters.ambito && filters.ambito !== "Todos") {
    params.set("ambito", filters.ambito);
  }
  if (filters.campus && filters.campus !== "Todos") {
    params.set("campus", filters.campus);
  }
  if (filters.tipo_ent && filters.tipo_ent !== "Todos") {
    params.set("tipo_ent", filters.tipo_ent);
  }
  if (filters.q && filters.q.trim()) {
    params.set("q", filters.q.trim());
  }

  const queryString = params.toString();
  const path = queryString ? `/api/postgrados?${queryString}` : "/api/postgrados";
  return apiFetch(path, { showBanner: true, onRetry });
}

export function fetchPostgradoById(idPostg) {
  return apiFetch(`/api/postgrados/${encodeURIComponent(idPostg)}`, {
    showBanner: false,
  });
}

export function fetchPostgradoByQr(codQr) {
  return apiFetch(`/api/postgrados/qr/${encodeURIComponent(codQr)}`, {
    showBanner: true,
  });
}

export function fetchServicios(tipo = "", onRetry = null) {
  const path = tipo
    ? `/api/servicios?tipo=${encodeURIComponent(tipo)}`
    : "/api/servicios";
  return apiFetch(path, { showBanner: true, onRetry });
}

export function fetchServiciosCercanos(lat, lon, radioM = 600, tipo = "") {
  const params = new URLSearchParams({
    lat: String(lat),
    lon: String(lon),
    radio_m: String(radioM),
  });
  if (tipo) {
    params.set("tipo", tipo);
  }
  return apiFetch(`/api/servicios/cercanos?${params.toString()}`, {
    showBanner: false,
  });
}
