import {
  DEFAULT_NEARBY_RADIUS_M,
  OSRM_SERVICE_URL,
  QUICK_ORIGINS,
  SERVICIO_STYLES,
} from "./config.js";
import { fetchServiciosCercanos } from "./api.js";
import {
  clearNearbyServicios,
  disableOriginPickMode,
  enableOriginPickMode,
  focusCoordinate,
  getMap,
  getRouteLayerGroup,
  renderNearbyServicios,
} from "./map.js";

/**
 * Módulo de Ruteo (OSRM) y Análisis de Proximidad PostGIS (Requisito #22).
 * Soporta:
 * - Destino automático desde lat_ruta / lon_ruta (fallback a lat_wgs84 / lon_wgs84)
 * - 3 métodos de origen: GPS, clic en el mapa, y puntos rápidos del campus
 * - Modo A pie (default) o En vehículo
 * - Consulta real a /api/servicios/cercanos
 */

let currentDestination = null; // { feature, lat, lon, label }
let currentOrigin = null; // { lat, lon, label }
let currentMode = "foot"; // "foot" | "driving"
let routePolyline = null;
let originMarker = null;
let destMarker = null;

function getEls() {
  return {
    destLabel: document.getElementById("route-dest-label"),
    destCoords: document.getElementById("route-dest-coords"),
    originStatus: document.getElementById("route-origin-status"),
    gpsBtn: document.getElementById("route-gps-btn"),
    pickBtn: document.getElementById("route-pick-btn"),
    quickSelect: document.getElementById("route-quick-origin"),
    modeRadios: document.querySelectorAll('input[name="route-mode"]'),
    calcBtn: document.getElementById("route-calc-btn"),
    clearBtn: document.getElementById("route-clear-btn"),
    feedback: document.getElementById("route-feedback"),
    summaryBox: document.getElementById("route-summary"),
    distanceVal: document.getElementById("route-distance-val"),
    durationVal: document.getElementById("route-duration-val"),
    modeTag: document.getElementById("route-mode-tag"),
    nearbyBox: document.getElementById("route-nearby-box"),
    nearbyList: document.getElementById("route-nearby-list"),
    nearbyCount: document.getElementById("route-nearby-count"),
  };
}

function haversineMeters(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const toRad = (deg) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function formatDistance(meters) {
  if (!Number.isFinite(meters)) return "—";
  if (meters < 1000) {
    return `${Math.round(meters)} m`;
  }
  return `${(meters / 1000).toFixed(2)} km`;
}

function formatDuration(seconds, distanceMeters, mode) {
  // El servidor público OSRM a menudo calcula tiempos de automóvil;
  // para modo peatonal garantizamos una velocidad realista (~4.8 km/h = 80 m/min).
  let totalMinutes;
  if (mode === "foot" && Number.isFinite(distanceMeters)) {
    totalMinutes = Math.max(1, Math.round(distanceMeters / 80));
  } else {
    totalMinutes = Math.max(1, Math.round((seconds || 0) / 60));
  }

  if (totalMinutes < 60) {
    return `${totalMinutes} min`;
  }
  const h = Math.floor(totalMinutes / 60);
  const m = totalMinutes % 60;
  return `${h} h ${m} min`;
}

function setFeedback(message, isError = false) {
  const { feedback } = getEls();
  if (!feedback) return;
  if (!message) {
    feedback.hidden = true;
    feedback.textContent = "";
    feedback.classList.remove("route-feedback--error");
    return;
  }
  feedback.hidden = false;
  feedback.textContent = message;
  feedback.classList.toggle("route-feedback--error", isError);
}

function updateOriginDisplay() {
  const { originStatus, calcBtn } = getEls();
  if (originStatus) {
    if (currentOrigin) {
      originStatus.textContent = `${currentOrigin.label} (${currentOrigin.lat.toFixed(5)}, ${currentOrigin.lon.toFixed(5)})`;
      originStatus.classList.add("route-origin-status--set");
    } else {
      originStatus.textContent = "Sin origen seleccionado. Elegí GPS, mapa o un acceso rápido.";
      originStatus.classList.remove("route-origin-status--set");
    }
  }
  if (calcBtn) {
    calcBtn.disabled = !(currentOrigin && currentDestination);
  }
}

export function setRoutingDestination(feature) {
  if (!feature) return;
  const props = feature.properties || {};
  const coords = feature.geometry?.coordinates;

  const latRuta = Number(props.lat_ruta);
  const lonRuta = Number(props.lon_ruta);
  const latWgs = Number(props.lat_wgs84 ?? coords?.[1]);
  const lonWgs = Number(props.lon_wgs84 ?? coords?.[0]);

  const useRuta =
    Number.isFinite(latRuta) &&
    Number.isFinite(lonRuta) &&
    latRuta !== 0 &&
    lonRuta !== 0;

  const destLat = useRuta ? latRuta : latWgs;
  const destLon = useRuta ? lonRuta : lonWgs;

  currentDestination = {
    feature,
    lat: destLat,
    lon: destLon,
    label: `${props.cod_fac || props.id_postg} — ${props.nom_unidad || ""}`,
  };

  const { destLabel, destCoords } = getEls();
  if (destLabel) {
    destLabel.textContent = currentDestination.label;
  }
  if (destCoords) {
    const coordType = useRuta ? "Nodo vial (lat_ruta)" : "Edificio (WGS84)";
    destCoords.textContent = `${coordType}: ${destLat.toFixed(5)}, ${destLon.toFixed(5)}`;
  }

  updateOriginDisplay();
  // Cargar de inmediato los servicios cercanos al destino desde PostGIS
  loadNearbyServicesForDestination(destLat, destLon);
}

async function loadNearbyServicesForDestination(destLat, destLon, midPoint = null) {
  const { nearbyBox, nearbyList, nearbyCount } = getEls();
  if (!nearbyBox || !nearbyList) return;

  nearbyBox.hidden = false;
  nearbyList.replaceChildren();
  const loadingLi = document.createElement("li");
  loadingLi.className = "nearby-item nearby-item--loading";
  loadingLi.textContent = "Consultando proximidad espacial en PostGIS...";
  nearbyList.appendChild(loadingLi);

  try {
    const fcDest = await fetchServiciosCercanos(
      destLat,
      destLon,
      DEFAULT_NEARBY_RADIUS_M
    );

    const destFeatures = fcDest?.features || [];
    const mergedMap = new Map();

    for (const f of destFeatures) {
      mergedMap.set(f.properties.id_serv, {
        feature: f,
        contextLabel: "Cerca del destino",
      });
    }

    // Opcionalmente consultar alrededor del punto medio si el recorrido existe
    if (midPoint && Number.isFinite(midPoint.lat) && Number.isFinite(midPoint.lon)) {
      try {
        const fcMid = await fetchServiciosCercanos(
          midPoint.lat,
          midPoint.lon,
          400
        );
        for (const f of fcMid?.features || []) {
          if (!mergedMap.has(f.properties.id_serv)) {
            mergedMap.set(f.properties.id_serv, {
              feature: f,
              contextLabel: "En el recorrido",
            });
          }
        }
      } catch {
        // Si falla la consulta del punto medio, mantenemos la del destino
      }
    }

    const combinedFeatures = [...mergedMap.values()].map((item) => item.feature);
    renderNearbyServicios(destLat, destLon, DEFAULT_NEARBY_RADIUS_M, {
      type: "FeatureCollection",
      features: combinedFeatures,
    });

    nearbyList.replaceChildren();
    if (nearbyCount) {
      nearbyCount.textContent = String(combinedFeatures.length);
    }

    if (combinedFeatures.length === 0) {
      const emptyLi = document.createElement("li");
      emptyLi.className = "nearby-item nearby-item--empty";
      emptyLi.textContent = `No hay servicios registrados dentro de ${DEFAULT_NEARBY_RADIUS_M} m (puede tratarse de una sede provincial).`;
      nearbyList.appendChild(emptyLi);
      return;
    }

    for (const { feature, contextLabel } of mergedMap.values()) {
      const props = feature.properties || {};
      const coords = feature.geometry?.coordinates;
      const style = SERVICIO_STYLES[props.tipo] || {
        label: props.tipo,
        color: "#475569",
      };

      const li = document.createElement("li");
      li.className = "nearby-item";

      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "nearby-item__btn";
      btn.addEventListener("click", () => {
        if (Array.isArray(coords) && coords.length >= 2) {
          focusCoordinate(coords[1], coords[0], 18);
        }
      });

      const dot = document.createElement("span");
      dot.className = "nearby-item__dot";
      dot.style.backgroundColor = style.color;
      dot.setAttribute("aria-hidden", "true");

      const info = document.createElement("span");
      info.className = "nearby-item__info";

      const nameEl = document.createElement("strong");
      nameEl.className = "nearby-item__name";
      nameEl.textContent = props.nombre || "Servicio";

      const subEl = document.createElement("span");
      subEl.className = "nearby-item__sub";
      subEl.textContent = `${style.label} · ${contextLabel}`;

      info.append(nameEl, subEl);

      const distBadge = document.createElement("span");
      distBadge.className = "nearby-item__dist";
      distBadge.textContent = `${Number(props.distancia_m).toFixed(1)} m`;

      btn.append(dot, info, distBadge);
      li.appendChild(btn);
      nearbyList.appendChild(li);
    }
  } catch {
    nearbyList.replaceChildren();
    const errLi = document.createElement("li");
    errLi.className = "nearby-item nearby-item--empty";
    errLi.textContent = "No se pudieron consultar los servicios cercanos.";
    nearbyList.appendChild(errLi);
  }
}

/**
 * Consulta la ruta a OSRM usando L.Routing.osrmv1 (Leaflet Routing Machine)
 * con fallback directo a fetch OSRM API.
 */
async function requestOsrmRoute(origin, dest, mode) {
  const profile = mode === "foot" ? "foot" : "driving";

  // 1) Intentar primero con L.Routing.osrmv1 si Leaflet Routing Machine cargó
  if (window.L?.Routing?.osrmv1) {
    try {
      const result = await new Promise((resolve, reject) => {
        const router = L.Routing.osrmv1({
          serviceUrl: OSRM_SERVICE_URL,
          profile,
          timeout: 12000,
        });

        const waypoints = [
          L.Routing.waypoint(L.latLng(origin.lat, origin.lon)),
          L.Routing.waypoint(L.latLng(dest.lat, dest.lon)),
        ];

        router.route(waypoints, (err, routes) => {
          if (err || !routes || routes.length === 0) {
            reject(err || new Error("Sin rutas devueltas por OSRM"));
            return;
          }
          const best = routes[0];
          const latLngs = best.coordinates.map((c) => [c.lat, c.lng]);
          resolve({
            latLngs,
            distanceMeters: best.summary?.totalDistance ?? 0,
            durationSeconds: best.summary?.totalTime ?? 0,
            isFallback: false,
          });
        });
      });
      return result;
    } catch {
      // Continuar al fallback fetch directo
    }
  }

  // 2) Fallback a petición fetch directa contra OSRM
  const controller = new AbortController();
  const timer = window.setTimeout(() => controller.abort(), 12000);
  try {
    const url = `${OSRM_SERVICE_URL}/${profile}/${origin.lon},${origin.lat};${dest.lon},${dest.lat}?overview=full&geometries=geojson`;
    const res = await fetch(url, { signal: controller.signal });
    if (!res.ok) throw new Error(`OSRM HTTP ${res.status}`);
    const json = await res.json();
    const route = json?.routes?.[0];
    if (!route?.geometry?.coordinates) {
      throw new Error("Geometría OSRM inválida");
    }
    const latLngs = route.geometry.coordinates.map(([lng, lat]) => [lat, lng]);
    return {
      latLngs,
      distanceMeters: route.distance,
      durationSeconds: route.duration,
      isFallback: false,
    };
  } finally {
    window.clearTimeout(timer);
  }
}

function drawRouteOnMap(latLngs, isFallback = false) {
  const map = getMap();
  const group = getRouteLayerGroup();
  if (!map || !group) return;

  group.clearLayers();

  routePolyline = L.polyline(latLngs, {
    color: isFallback ? "#d97706" : currentMode === "foot" ? "#0d7a6f" : "#1d4ed8",
    weight: 5,
    opacity: 0.9,
    dashArray: isFallback ? "8 8" : currentMode === "foot" ? "10 6" : null,
  }).addTo(group);

  originMarker = L.circleMarker([currentOrigin.lat, currentOrigin.lon], {
    radius: 8,
    color: "#ffffff",
    weight: 2.5,
    fillColor: "#16a34a",
    fillOpacity: 1,
  })
    .bindTooltip(`Origen: ${currentOrigin.label}`, { direction: "top" })
    .addTo(group);

  destMarker = L.circleMarker([currentDestination.lat, currentDestination.lon], {
    radius: 8,
    color: "#ffffff",
    weight: 2.5,
    fillColor: "#8b1538",
    fillOpacity: 1,
  })
    .bindTooltip(`Destino: ${currentDestination.label}`, { direction: "top" })
    .addTo(group);

  map.fitBounds(routePolyline.getBounds(), { padding: [52, 52], maxZoom: 17 });
}

export async function calculateRoute() {
  if (!currentOrigin || !currentDestination) {
    setFeedback("Seleccioná un punto de inicio antes de calcular la ruta.", true);
    return;
  }

  const { summaryBox, distanceVal, durationVal, modeTag, calcBtn } = getEls();
  if (calcBtn) calcBtn.disabled = true;
  setFeedback("Calculando ruta óptima con OSRM...");

  let routeResult;
  try {
    routeResult = await requestOsrmRoute(
      currentOrigin,
      currentDestination,
      currentMode
    );
    setFeedback("");
  } catch {
    // Fallback geodésico si el servidor público OSRM está saturado/sin conexión
    const dist = haversineMeters(
      currentOrigin.lat,
      currentOrigin.lon,
      currentDestination.lat,
      currentDestination.lon
    );
    routeResult = {
      latLngs: [
        [currentOrigin.lat, currentOrigin.lon],
        [currentDestination.lat, currentDestination.lon],
      ],
      distanceMeters: dist,
      durationSeconds: currentMode === "foot" ? dist / 1.35 : dist / 8.3,
      isFallback: true,
    };
    setFeedback(
      "El servidor público OSRM no respondió; se muestra trayectoria directa referencial.",
      false
    );
  } finally {
    if (calcBtn) calcBtn.disabled = false;
  }

  drawRouteOnMap(routeResult.latLngs, routeResult.isFallback);

  if (summaryBox) summaryBox.hidden = false;
  if (distanceVal) {
    distanceVal.textContent = formatDistance(routeResult.distanceMeters);
  }
  if (durationVal) {
    durationVal.textContent = formatDuration(
      routeResult.durationSeconds,
      routeResult.distanceMeters,
      currentMode
    );
  }
  if (modeTag) {
    modeTag.textContent =
      currentMode === "foot" ? "A pie" : "En vehículo";
  }

  // Punto medio para enriquecer servicios cercanos en rutas largas
  const midIdx = Math.floor(routeResult.latLngs.length / 2);
  const midCoord = routeResult.latLngs[midIdx];
  const midPoint =
    midCoord && routeResult.distanceMeters > 700
      ? { lat: midCoord[0], lon: midCoord[1] }
      : null;

  await loadNearbyServicesForDestination(
    currentDestination.lat,
    currentDestination.lon,
    midPoint
  );
}

export function clearRoute() {
  disableOriginPickMode();
  const group = getRouteLayerGroup();
  if (group) group.clearLayers();
  clearNearbyServicios();

  routePolyline = null;
  originMarker = null;
  destMarker = null;
  currentOrigin = null;

  const { summaryBox, quickSelect } = getEls();
  if (summaryBox) summaryBox.hidden = true;
  if (quickSelect) quickSelect.value = "";
  setFeedback("");
  updateOriginDisplay();
}

export function initRouting() {
  const { gpsBtn, pickBtn, quickSelect, modeRadios, calcBtn, clearBtn } =
    getEls();

  // Poblar opciones rápidas
  if (quickSelect) {
    for (const item of QUICK_ORIGINS) {
      const opt = document.createElement("option");
      opt.value = item.id;
      opt.textContent = item.label;
      quickSelect.appendChild(opt);
    }

    quickSelect.addEventListener("change", () => {
      const selected = QUICK_ORIGINS.find((q) => q.id === quickSelect.value);
      if (!selected) return;
      currentOrigin = {
        lat: selected.lat,
        lon: selected.lon,
        label: selected.label,
      };
      updateOriginDisplay();
      if (currentDestination) {
        calculateRoute();
      }
    });
  }

  // Opción 1: GPS
  if (gpsBtn) {
    gpsBtn.addEventListener("click", () => {
      if (!navigator.geolocation) {
        setFeedback(
          "Tu navegador no soporta geolocalización GPS. Elegí un punto en el mapa o acceso rápido.",
          true
        );
        return;
      }

      if (
        !window.isSecureContext &&
        window.location.hostname !== "localhost" &&
        window.location.hostname !== "127.0.0.1"
      ) {
        setFeedback(
          "El GPS del navegador requiere conexión HTTPS segura. Podés elegir el origen en el mapa o usar un punto rápido.",
          true
        );
        return;
      }

      setFeedback("Obteniendo ubicación GPS actual...");
      navigator.geolocation.getCurrentPosition(
        (pos) => {
          currentOrigin = {
            lat: pos.coords.latitude,
            lon: pos.coords.longitude,
            label: "Mi ubicación GPS",
          };
          if (quickSelect) quickSelect.value = "";
          setFeedback("");
          updateOriginDisplay();
          if (currentDestination) {
            calculateRoute();
          }
        },
        (err) => {
          const msg =
            err.code === 1
              ? "Permiso de ubicación GPS denegado. Usá 'Elegir en el mapa' o un punto de inicio rápido."
              : "No se pudo obtener tu posición GPS. Verificá la señal o elegí un punto en el mapa.";
          setFeedback(msg, true);
        },
        { enableHighAccuracy: true, timeout: 10000, maximumAge: 30000 }
      );
    });
  }

  // Opción 2: Clic en el mapa
  if (pickBtn) {
    pickBtn.addEventListener("click", () => {
      setFeedback("Hacé clic en cualquier punto del mapa para fijar tu origen.");
      enableOriginPickMode((lat, lon) => {
        currentOrigin = {
          lat,
          lon,
          label: "Punto seleccionado en mapa",
        };
        if (quickSelect) quickSelect.value = "";
        setFeedback("");
        updateOriginDisplay();
        if (currentDestination) {
          calculateRoute();
        }
      });
    });
  }

  // Selector de modo (A pie / En vehículo)
  for (const radio of modeRadios) {
    radio.addEventListener("change", (e) => {
      if (e.target.checked) {
        currentMode = e.target.value;
        if (currentOrigin && currentDestination) {
          calculateRoute();
        }
      }
    });
  }

  if (calcBtn) {
    calcBtn.addEventListener("click", calculateRoute);
  }
  if (clearBtn) {
    clearBtn.addEventListener("click", clearRoute);
  }
}
