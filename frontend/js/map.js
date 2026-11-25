import {
  INITIAL_MAP_CENTER,
  INITIAL_MAP_ZOOM,
  POSTGRADO_STYLES,
  SERVICIO_STYLES,
} from "./config.js";

/**
 * Módulo de mapa Leaflet:
 * - Mapas base gratuitos (OSM Estándar y Esri World Imagery)
 * - Capa de Unidades de Postgrado con íconos SVG según tipo_ent
 * - Capa de Servicios de Apoyo con simbología clara y toggle
 * - Capa de análisis espacial de servicios cercanos y ruta
 * - Leyenda interactiva plegable
 */

let mapInstance = null;
let postgradosLayer = null;
let serviciosLayer = null;
let nearbyLayer = null;
let routeLayer = null;
let selectedRingLayer = null;

let osmLayer = null;
let esriSatLayer = null;

let markerByPostgId = new Map();
let currentSelectedId = null;
let pickClickHandler = null;
let pickModeBannerEl = null;

function createSvgElement(tag, attrs = {}) {
  const el = document.createElementNS("http://www.w3.org/2000/svg", tag);
  for (const [k, v] of Object.entries(attrs)) {
    el.setAttribute(k, String(v));
  }
  return el;
}

/**
 * Construye un divIcon SVG limpio para Unidades de Postgrado según tipo_ent.
 */
function buildPostgradoIcon(tipoEnt, isSelected = false) {
  const style =
    POSTGRADO_STYLES[tipoEnt] || POSTGRADO_STYLES.Unidad_Facultativa;

  const size = isSelected ? 40 : 34;
  const strokeColor = style.accent || "#ffffff";
  const ringClass = isSelected ? "marker-pin--selected" : "";

  // Símbolo interior diferenciado por tipo_ent
  let innerSymbol = "";
  if (tipoEnt === "Rectorado_DGP") {
    // Estrella / insignia rectoral
    innerSymbol = `<polygon points="16,7 18.6,12.2 24.4,13 20.2,17 21.2,22.8 16,20 10.8,22.8 11.8,17 7.6,13 13.4,12.2" fill="#d4af37"/>`;
  } else if (tipoEnt === "Sede_Provincial") {
    // Brújula / sede regional
    innerSymbol = `<circle cx="16" cy="15" r="5" fill="none" stroke="#ffffff" stroke-width="2"/><circle cx="16" cy="15" r="2" fill="#ffffff"/>`;
  } else {
    // Birrete académico estilizado
    innerSymbol = `<polygon points="16,9 24,13 16,17 8,13" fill="#ffffff"/><path d="M11 16v4c0 1.4 2.2 2.5 5 2.5s5-1.1 5-2.5v-4" fill="none" stroke="#ffffff" stroke-width="1.6"/>`;
  }

  const html = `
    <div class="marker-pin ${ringClass}" style="--pin-color:${style.color};--pin-accent:${strokeColor}">
      <svg viewBox="0 0 32 40" width="${size}" height="${Math.round(size * 1.25)}" aria-hidden="true">
        <path d="M16 2C8.8 2 3 7.8 3 15c0 9.6 13 23 13 23s13-13.4 13-23C29 7.8 23.2 2 16 2z"
              fill="${style.color}" stroke="${strokeColor}" stroke-width="2.2"/>
        ${innerSymbol}
      </svg>
    </div>
  `;

  return L.divIcon({
    className: "uagrm-marker-wrapper",
    html,
    iconSize: [size, Math.round(size * 1.25)],
    iconAnchor: [size / 2, Math.round(size * 1.25) - 2],
    tooltipAnchor: [0, -Math.round(size * 1.1)],
  });
}

/**
 * Construye un divIcon SVG claramente distinguible para Servicios de Apoyo.
 */
function buildServicioIcon(tipo, isHighlighted = false) {
  const style = SERVICIO_STYLES[tipo] || {
    label: tipo,
    color: "#475569",
    bg: "#f8fafc",
  };

  let iconSvg = "";
  if (tipo === "Centro_Medico") {
    iconSvg = `<path d="M13 7h4v6h6v4h-6v6h-4v-6H7v-4h6z" fill="${style.color}"/>`;
  } else if (tipo === "Extintor") {
    iconSvg = `
      <rect x="11" y="10" width="8" height="13" rx="2.5" fill="${style.color}"/>
      <path d="M13 10V7h4v1M17 7l3 2" stroke="${style.color}" stroke-width="2" fill="none" stroke-linecap="round"/>
      <rect x="12.5" y="14" width="5" height="2.2" fill="#ffffff"/>
    `;
  } else if (tipo === "Acceso_Campus") {
    iconSvg = `
      <path d="M8 23V9h10v14" fill="none" stroke="${style.color}" stroke-width="2.2"/>
      <rect x="10.5" y="11.5" width="5" height="11.5" fill="${style.color}" opacity="0.25"/>
      <path d="M19 16h6m-2.5-2.5L25 16l-2.5 2.5" stroke="${style.color}" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
    `;
  } else {
    // Punto_Encuentro
    iconSvg = `
      <circle cx="15" cy="15" r="4" fill="${style.color}"/>
      <path d="M15 4v4M15 22v4M4 15h4M22 15h4M7.5 7.5l2.8 2.8M19.7 19.7l2.8 2.8M22.5 7.5l-2.8 2.8M10.3 19.7l-2.8 2.8"
            stroke="${style.color}" stroke-width="2" stroke-linecap="round"/>
    `;
  }

  const size = isHighlighted ? 32 : 28;
  const highlightClass = isHighlighted ? "service-badge--nearby" : "";

  const html = `
    <div class="service-badge ${highlightClass}" style="--serv-color:${style.color};--serv-bg:${style.bg}">
      <svg viewBox="0 0 30 30" width="${size}" height="${size}" aria-hidden="true">
        <circle cx="15" cy="15" r="13.5" fill="${style.bg}" stroke="${style.color}" stroke-width="${isHighlighted ? 2.5 : 1.8}"/>
        ${iconSvg}
      </svg>
    </div>
  `;

  return L.divIcon({
    className: "uagrm-service-wrapper",
    html,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
    popupAnchor: [0, -size / 2],
  });
}

function createServicePopupContent(props) {
  const container = document.createElement("div");
  container.className = "service-popup";

  const style = SERVICIO_STYLES[props.tipo] || {
    label: props.tipo || "Servicio",
    color: "#334155",
  };

  const badgeRow = document.createElement("div");
  badgeRow.className = "service-popup__badges";

  const typeBadge = document.createElement("span");
  typeBadge.className = "service-popup__type";
  typeBadge.style.backgroundColor = style.color;
  typeBadge.textContent = style.label;
  badgeRow.appendChild(typeBadge);

  if (props.distancia_m !== undefined && props.distancia_m !== null) {
    const distBadge = document.createElement("span");
    distBadge.className = "service-popup__dist";
    distBadge.textContent = `${Number(props.distancia_m).toFixed(1)} m`;
    badgeRow.appendChild(distBadge);
  }

  if (props.es_referencial) {
    const refBadge = document.createElement("span");
    refBadge.className = "service-popup__ref";
    refBadge.textContent = "Referencial";
    badgeRow.appendChild(refBadge);
  }

  container.appendChild(badgeRow);

  const title = document.createElement("h3");
  title.className = "service-popup__title";
  title.textContent = props.nombre || "Servicio de Apoyo";
  container.appendChild(title);

  const meta = document.createElement("dl");
  meta.className = "service-popup__meta";

  const rows = [
    ["Campus", props.campus],
    ["Referencia", props.referencia],
    ["Horario", props.horario],
  ];

  for (const [label, value] of rows) {
    if (!value) continue;
    const dt = document.createElement("dt");
    dt.textContent = label;
    const dd = document.createElement("dd");
    dd.textContent = value;
    meta.append(dt, dd);
  }

  container.appendChild(meta);
  return container;
}

export function initMap(containerId = "map") {
  if (mapInstance) return mapInstance;

  mapInstance = L.map(containerId, {
    center: INITIAL_MAP_CENTER,
    zoom: INITIAL_MAP_ZOOM,
    zoomControl: false,
  });

  L.control.zoom({ position: "bottomright" }).addTo(mapInstance);
  L.control.scale({ imperial: false, position: "bottomleft" }).addTo(mapInstance);

  osmLayer = L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
    maxZoom: 19,
    attribution:
      '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  });

  esriSatLayer = L.tileLayer(
    "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
    {
      maxZoom: 19,
      attribution: "Tiles &copy; Esri &mdash; Source: Esri, Maxar, Earthstar Geographics",
    }
  );

  osmLayer.addTo(mapInstance);

  postgradosLayer = L.layerGroup().addTo(mapInstance);
  serviciosLayer = L.layerGroup().addTo(mapInstance);
  nearbyLayer = L.layerGroup().addTo(mapInstance);
  routeLayer = L.layerGroup().addTo(mapInstance);
  selectedRingLayer = L.layerGroup().addTo(mapInstance);

  const baseMaps = {
    "OpenStreetMap Estándar": osmLayer,
    "Vista Satelital (Esri)": esriSatLayer,
  };

  const overlayMaps = {
    "Unidades de Postgrado": postgradosLayer,
    "Servicios de Apoyo": serviciosLayer,
  };

  L.control
    .layers(baseMaps, overlayMaps, {
      position: "topright",
      collapsed: window.innerWidth < 768,
    })
    .addTo(mapInstance);

  initLegendControl();
  return mapInstance;
}

function initLegendControl() {
  const legendCard = document.getElementById("map-legend");
  const toggleBtn = document.getElementById("legend-toggle-btn");
  const body = document.getElementById("legend-body");
  if (!legendCard || !toggleBtn || !body) return;

  // En móvil inicia colapsada para dar máxima visibilidad al mapa
  if (window.innerWidth < 768) {
    body.hidden = true;
    toggleBtn.setAttribute("aria-expanded", "false");
    legendCard.classList.add("map-legend--collapsed");
  }

  toggleBtn.addEventListener("click", () => {
    const isExpanded = toggleBtn.getAttribute("aria-expanded") === "true";
    const nextExpanded = !isExpanded;
    toggleBtn.setAttribute("aria-expanded", String(nextExpanded));
    body.hidden = !nextExpanded;
    legendCard.classList.toggle("map-legend--collapsed", !nextExpanded);
  });
}

export function getMap() {
  return mapInstance;
}

export function getRouteLayerGroup() {
  return routeLayer;
}

export function invalidateMapSize() {
  if (mapInstance) {
    window.requestAnimationFrame(() => mapInstance.invalidateSize());
  }
}

export function resetMapView() {
  if (mapInstance) {
    mapInstance.flyTo(INITIAL_MAP_CENTER, INITIAL_MAP_ZOOM, { duration: 0.6 });
  }
}

/**
 * Renderiza la capa de Unidades de Postgrado desde un FeatureCollection GeoJSON.
 */
export function renderPostgrados(featureCollection, onSelect) {
  if (!mapInstance || !postgradosLayer) return;

  postgradosLayer.clearLayers();
  markerByPostgId.clear();

  const features = featureCollection?.features || [];

  for (const feature of features) {
    const coords = feature?.geometry?.coordinates;
    const props = feature?.properties || {};
    if (!Array.isArray(coords) || coords.length < 2) continue;

    const [lon, lat] = coords;
    const isSelected = props.id_postg === currentSelectedId;
    const marker = L.marker([lat, lon], {
      icon: buildPostgradoIcon(props.tipo_ent, isSelected),
      zIndexOffset: isSelected ? 600 : props.tipo_ent === "Rectorado_DGP" ? 300 : 100,
    });

    const tooltipLabel = `${props.cod_fac || props.id_postg} — ${props.nom_unidad || ""}`;
    marker.bindTooltip(props.cod_fac || props.id_postg, {
      direction: "top",
      offset: [0, -30],
      className: "uagrm-tooltip",
    });

    // Etiqueta accesible en el elemento DOM del marcador tras añadirlo
    marker.on("add", () => {
      const el = marker.getElement();
      if (el) {
        el.setAttribute("aria-label", tooltipLabel);
      }
    });

    marker.on("click", () => {
      if (typeof onSelect === "function") {
        onSelect(feature);
      }
    });

    marker.addTo(postgradosLayer);
    markerByPostgId.set(props.id_postg, { marker, feature });
  }
}

/**
 * Ajusta el encuadre del mapa a las features visibles si conviene (ej. al filtrar Provincial).
 */
export function fitBoundsToFeatures(features) {
  if (!mapInstance || !Array.isArray(features) || features.length === 0) return;

  const latLngs = features
    .map((f) => f?.geometry?.coordinates)
    .filter((c) => Array.isArray(c) && c.length >= 2)
    .map(([lon, lat]) => [lat, lon]);

  if (latLngs.length === 0) return;
  if (latLngs.length === 1) {
    mapInstance.flyTo(latLngs[0], 16, { duration: 0.6 });
    return;
  }

  const bounds = L.latLngBounds(latLngs);
  mapInstance.fitBounds(bounds, { padding: [48, 48], maxZoom: 16 });
}

/**
 * Marca visualmente la unidad seleccionada y hace zoom sobre ella.
 */
export function highlightAndFocusPostgrado(feature, zoomLevel = 17) {
  if (!mapInstance || !feature) return;

  const props = feature.properties || {};
  const coords = feature.geometry?.coordinates;
  const lat = Number(props.lat_wgs84 ?? coords?.[1]);
  const lon = Number(props.lon_wgs84 ?? coords?.[0]);

  const prevId = currentSelectedId;
  currentSelectedId = props.id_postg || null;

  if (prevId && markerByPostgId.has(prevId)) {
    const prevEntry = markerByPostgId.get(prevId);
    prevEntry.marker.setIcon(buildPostgradoIcon(prevEntry.feature.properties?.tipo_ent, false));
    prevEntry.marker.setZIndexOffset(100);
  }

  if (currentSelectedId && markerByPostgId.has(currentSelectedId)) {
    const curEntry = markerByPostgId.get(currentSelectedId);
    curEntry.marker.setIcon(buildPostgradoIcon(curEntry.feature.properties?.tipo_ent, true));
    curEntry.marker.setZIndexOffset(700);
  }

  selectedRingLayer.clearLayers();
  if (!Number.isNaN(lat) && !Number.isNaN(lon)) {
    L.circleMarker([lat, lon], {
      radius: 20,
      color: "#d4af37",
      weight: 3,
      opacity: 0.9,
      fillColor: "#d4af37",
      fillOpacity: 0.14,
      interactive: false,
    }).addTo(selectedRingLayer);

    mapInstance.flyTo([lat, lon], zoomLevel, { duration: 0.65 });
  }
}

/**
 * Renderiza la capa de Servicios de Apoyo desde GET /api/servicios.
 */
export function renderServicios(featureCollection) {
  if (!mapInstance || !serviciosLayer) return;
  serviciosLayer.clearLayers();

  const features = featureCollection?.features || [];
  for (const feature of features) {
    const coords = feature?.geometry?.coordinates;
    const props = feature?.properties || {};
    if (!Array.isArray(coords) || coords.length < 2) continue;

    const [lon, lat] = coords;
    const marker = L.marker([lat, lon], {
      icon: buildServicioIcon(props.tipo, false),
      zIndexOffset: 50,
    });

    marker.bindTooltip(props.nombre || props.tipo, {
      direction: "top",
      offset: [0, -14],
    });
    marker.bindPopup(() => createServicePopupContent(props), {
      maxWidth: 280,
    });
    marker.addTo(serviciosLayer);
  }
}

export function setServiciosVisible(visible) {
  if (!mapInstance || !serviciosLayer) return;
  if (visible) {
    if (!mapInstance.hasLayer(serviciosLayer)) {
      mapInstance.addLayer(serviciosLayer);
    }
  } else if (mapInstance.hasLayer(serviciosLayer)) {
    mapInstance.removeLayer(serviciosLayer);
  }
}

/**
 * Resalta en el mapa los servicios cercanos devueltos por PostGIS (/api/servicios/cercanos).
 */
export function renderNearbyServicios(destLat, destLon, radioM, featureCollection) {
  if (!mapInstance || !nearbyLayer) return;
  nearbyLayer.clearLayers();

  if (Number.isFinite(destLat) && Number.isFinite(destLon)) {
    L.circle([destLat, destLon], {
      radius: radioM,
      color: "#0f2b5b",
      weight: 1.5,
      dashArray: "6 6",
      fillColor: "#2563eb",
      fillOpacity: 0.06,
      interactive: false,
    }).addTo(nearbyLayer);
  }

  const features = featureCollection?.features || [];
  for (const feature of features) {
    const coords = feature?.geometry?.coordinates;
    const props = feature?.properties || {};
    if (!Array.isArray(coords) || coords.length < 2) continue;

    const [lon, lat] = coords;
    const marker = L.marker([lat, lon], {
      icon: buildServicioIcon(props.tipo, true),
      zIndexOffset: 450,
    });

    marker.bindTooltip(
      `${props.nombre} (${Number(props.distancia_m).toFixed(0)} m)`,
      { direction: "top", offset: [0, -16] }
    );
    marker.bindPopup(() => createServicePopupContent(props), {
      maxWidth: 280,
    });
    marker.addTo(nearbyLayer);
  }
}

export function clearNearbyServicios() {
  if (nearbyLayer) {
    nearbyLayer.clearLayers();
  }
}

export function focusCoordinate(lat, lon, zoom = 18) {
  if (mapInstance && Number.isFinite(lat) && Number.isFinite(lon)) {
    mapInstance.flyTo([lat, lon], zoom, { duration: 0.55 });
  }
}

/**
 * Activa el modo de selección de punto de origen haciendo clic sobre el mapa.
 */
export function enableOriginPickMode(onPicked) {
  if (!mapInstance) return;
  disableOriginPickMode();

  const container = mapInstance.getContainer();
  container.classList.add("map--picking-origin");

  pickModeBannerEl = document.getElementById("map-pick-hint");
  if (pickModeBannerEl) {
    pickModeBannerEl.hidden = false;
  }

  pickClickHandler = (e) => {
    const { lat, lng } = e.latlng;
    disableOriginPickMode();
    if (typeof onPicked === "function") {
      onPicked(lat, lng);
    }
  };

  mapInstance.once("click", pickClickHandler);
}

export function disableOriginPickMode() {
  if (!mapInstance) return;
  const container = mapInstance.getContainer();
  container.classList.remove("map--picking-origin");

  if (pickClickHandler) {
    mapInstance.off("click", pickClickHandler);
    pickClickHandler = null;
  }

  if (pickModeBannerEl) {
    pickModeBannerEl.hidden = true;
  }
}
