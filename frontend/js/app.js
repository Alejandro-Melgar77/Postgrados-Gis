import {
  DEFAULT_NEARBY_RADIUS_M,
  POSTGRADO_STYLES,
  SERVICIO_STYLES,
} from "./config.js";
import {
  fetchPostgrados,
  fetchResumen,
  fetchServicios,
  initApiBannerControls,
} from "./api.js";
import {
  fitBoundsToFeatures,
  highlightAndFocusPostgrado,
  initMap,
  invalidateMapSize,
  renderPostgrados,
  renderServicios,
  resetMapView,
  setServiciosVisible,
} from "./map.js";
import {
  clearRoute,
  initRouting,
  setRoutingDestination,
} from "./routing.js";
import {
  checkInitialQrParam,
  initQrModule,
  openQrGeneratorModal,
} from "./qr.js";

/**
 * Controlador Principal WebGIS — Postgrados UAGRM (INF442-SA)
 */

const state = {
  features: [],
  allServicios: null,
  selectedFeature: null,
  serviciosVisible: true,
  filters: {
    ambito: "Urbano",
    campus: "Todos",
    q: "",
  },
  activeDetailTab: "ficha", // "ficha" | "ruta"
};

let searchDebounceTimer = null;

function formatPhoneLinks(rawPhone) {
  if (!rawPhone || rawPhone.trim().toUpperCase() === "S/D") {
    return { telHref: null, waHref: null };
  }
  const firstSegment = rawPhone.split("/")[0].trim();
  const digits = firstSegment.replace(/\D/g, "");
  if (!digits) return { telHref: null, waHref: null };

  // Teléfono fijo SCZ (7 dígitos) o celular (8 dígitos) -> prefijo país +591
  const normalized = digits.startsWith("591")
    ? digits
    : digits.length === 7
    ? `5913${digits}`
    : `591${digits}`;

  // Buscar algún número móvil boliviano (8 dígitos empezando en 6 o 7) para WhatsApp
  const mobileMatch = rawPhone.match(/\b([67]\d{7})\b/);
  const waHref = mobileMatch
    ? `https://wa.me/591${mobileMatch[1]}?text=${encodeURIComponent(
        "Hola, solicito información sobre programas de postgrado UAGRM."
      )}`
    : null;

  return {
    telHref: `tel:+${normalized}`,
    waHref,
  };
}

function showToast(message, durationMs = 4500) {
  const toast = document.getElementById("app-toast");
  if (!toast) return;
  toast.textContent = message;
  toast.hidden = false;
  window.clearTimeout(showToast._timer);
  showToast._timer = window.setTimeout(() => {
    toast.hidden = true;
  }, durationMs);
}

/**
 * Fallback light-dismiss para navegadores sin HTMLDialogElement.prototype.closedBy (Safari).
 */
function setupDialogLightDismissFallback() {
  if ("closedBy" in HTMLDialogElement.prototype) return;

  const isOutside = (e, dialog) => {
    const r = dialog.getBoundingClientRect();
    return (
      e.clientX < r.left ||
      e.clientX > r.right ||
      e.clientY < r.top ||
      e.clientY > r.bottom
    );
  };

  for (const dialog of document.querySelectorAll('dialog[closedby="any"]')) {
    let pressedOutside = false;
    dialog.addEventListener("pointerdown", (e) => {
      pressedOutside = isOutside(e, dialog);
    });
    dialog.addEventListener("pointerup", (e) => {
      if (pressedOutside && isOutside(e, dialog)) {
        dialog.close();
      }
    });
  }
}

/**
 * Cajón lateral adaptable (Sidebar persistente en >=960px, Popover Drawer deslizable en móvil).
 */
function setupResponsiveDrawer() {
  const drawer = document.getElementById("sidebar-drawer");
  const scroller = drawer?.querySelector(".Drawer-scroller");
  const sheet = drawer?.querySelector(".Drawer-sheet");
  const openBtn = document.getElementById("drawer-open-btn");
  const closeBtn = document.getElementById("drawer-close-btn");
  const mainEl = document.getElementById("main-content");
  const headerEl = document.getElementById("app-header");
  if (!drawer || !scroller || !sheet || !openBtn || !closeBtn) return null;

  const mq = window.matchMedia("(width < 960px)");
  let observer = null;
  let isOpening = false;

  const setBackgroundInert = (isInert) => {
    if (mainEl) mainEl.inert = isInert;
    if (headerEl) headerEl.inert = isInert;
  };

  function onDrawerOpened() {
    isOpening = false;
    openBtn.setAttribute("aria-expanded", "true");
  }

  function onDrawerClosed() {
    if (isOpening || !drawer.hasAttribute("aria-modal")) return;
    if (drawer.matches(":popover-open")) {
      drawer.hidePopover();
    }
    setBackgroundInert(false);
    drawer.removeAttribute("aria-modal");
    openBtn.setAttribute("aria-expanded", "false");
    openBtn.focus();
  }

  async function openDrawer() {
    if (!mq.matches) return;
    isOpening = true;
    drawer.showPopover();
    setBackgroundInert(true);
    drawer.setAttribute("aria-modal", "true");

    if (!CSS.supports("scroll-initial-target", "nearest")) {
      scroller.scrollTo({ left: scroller.offsetWidth, behavior: "instant" });
      await new Promise((r) =>
        window.requestAnimationFrame(() => window.requestAnimationFrame(r))
      );
    }
    scroller.scrollTo({ left: 0, behavior: "auto" });
    onDrawerOpened();
    closeBtn.focus({ preventScroll: true });
  }

  function closeDrawer() {
    if (!mq.matches || !drawer.hasAttribute("aria-modal")) return;
    if (
      window.matchMedia("(prefers-reduced-motion: reduce)").matches ||
      scroller.scrollWidth <= scroller.clientWidth
    ) {
      onDrawerClosed();
      return;
    }
    scroller.scrollTo({ left: scroller.offsetWidth, behavior: "auto" });
    window.setTimeout(() => {
      if (drawer.hasAttribute("aria-modal") && scroller.scrollLeft >= sheet.offsetWidth - 4) {
        onDrawerClosed();
      }
    }, 450);
  }

  // Fallback para backdrop opacity si no hay animation-timeline: scroll()
  if (!CSS.supports("animation-timeline: scroll()")) {
    scroller.addEventListener("scroll", () => {
      if (!mq.matches || !sheet.offsetWidth) return;
      const ratio = Math.max(
        0,
        Math.min(1, 1 - scroller.scrollLeft / sheet.offsetWidth)
      );
      drawer.style.setProperty("--drawer-backdrop", String(ratio));
    });
  }

  function syncMode() {
    if (mq.matches) {
      drawer.setAttribute("popover", "manual");
      drawer.setAttribute("role", "dialog");
      drawer.classList.add("Drawer--mobile");

      if (!observer) {
        const visibleThreshold = 1 / Math.max(320, window.innerWidth);
        observer = new IntersectionObserver(
          (entries) => {
            if (!mq.matches) return;
            const entry = entries.at(-1);
            if (!entry) return;
            if (entry.intersectionRatio < visibleThreshold) {
              onDrawerClosed();
            } else if (entry.intersectionRatio >= 0.99) {
              onDrawerOpened();
            }
          },
          { root: drawer, threshold: [visibleThreshold, 0.99] }
        );
        observer.observe(sheet);
      }
    } else {
      if (drawer.matches(":popover-open")) {
        drawer.hidePopover();
      }
      drawer.removeAttribute("popover");
      drawer.removeAttribute("role");
      drawer.removeAttribute("aria-modal");
      drawer.classList.remove("Drawer--mobile");
      setBackgroundInert(false);
      openBtn.setAttribute("aria-expanded", "false");
    }
    invalidateMapSize();
  }

  openBtn.addEventListener("click", openDrawer);
  closeBtn.addEventListener("click", closeDrawer);

  drawer.addEventListener("click", (e) => {
    if (mq.matches && !sheet.contains(e.target)) {
      closeDrawer();
    }
  });

  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && mq.matches && drawer.hasAttribute("aria-modal")) {
      closeDrawer();
    }
  });

  mq.addEventListener("change", syncMode);
  syncMode();

  return { closeIfMobile: closeDrawer };
}

/**
 * Renderiza los contadores rápidos desde GET /api/resumen.
 */
function renderResumenCounters(resumen) {
  const postg = resumen?.postgrados || {};
  const serv = resumen?.servicios || {};

  const mapIds = {
    "stat-total": postg.total ?? "—",
    "stat-urbanos": postg.urbanos ?? "—",
    "stat-provinciales": postg.provinciales ?? "—",
    "stat-servicios": serv.total ?? "—",
  };

  for (const [id, val] of Object.entries(mapIds)) {
    const el = document.getElementById(id);
    if (el) el.textContent = String(val);
  }
}

/**
 * Renderiza la lista compacta de resultados en el panel lateral.
 */
function renderResultsList(features, drawerApi) {
  const listEl = document.getElementById("results-list");
  const countEl = document.getElementById("results-count");
  if (!listEl) return;

  listEl.replaceChildren();
  if (countEl) {
    countEl.textContent = `${features.length} ${
      features.length === 1 ? "unidad" : "unidades"
    }`;
  }

  if (features.length === 0) {
    const li = document.createElement("li");
    li.className = "results-empty";
    li.textContent =
      "No se encontraron unidades con los filtros seleccionados.";
    listEl.appendChild(li);
    return;
  }

  for (const feature of features) {
    const props = feature.properties || {};
    const style =
      POSTGRADO_STYLES[props.tipo_ent] || POSTGRADO_STYLES.Unidad_Facultativa;
    const isActive = state.selectedFeature?.properties?.id_postg === props.id_postg;

    const li = document.createElement("li");
    li.className = "result-item";

    const btn = document.createElement("button");
    btn.type = "button";
    btn.className = `result-card ${isActive ? "result-card--active" : ""}`;
    btn.dataset.idPostg = props.id_postg;

    const header = document.createElement("div");
    header.className = "result-card__top";

    const sigla = document.createElement("span");
    sigla.className = `unit-badge ${style.badgeClass}`;
    sigla.textContent = props.cod_fac || props.id_postg;

    const idSpan = document.createElement("span");
    idSpan.className = "result-card__id";
    idSpan.textContent = props.id_postg;

    const geoBadge = document.createElement("span");
    geoBadge.className = `geo-pill ${
      props.estado_geo === "Verificado" ? "geo-pill--ok" : "geo-pill--warn"
    }`;
    geoBadge.textContent =
      props.estado_geo === "Verificado" ? "Verificado" : "Revisar campo";

    header.append(sigla, idSpan, geoBadge);

    const title = document.createElement("strong");
    title.className = "result-card__title";
    title.textContent = props.nom_unidad || "";

    const meta = document.createElement("span");
    meta.className = "result-card__meta";
    meta.textContent = `${props.campus || ""} · ${props.municipio || ""}`;

    btn.append(header, title, meta);
    btn.addEventListener("click", () => {
      selectPostgrado(feature);
      drawerApi?.closeIfMobile();
    });

    li.appendChild(btn);
    listEl.appendChild(li);
  }
}

/**
 * Actualiza el resaltado en la lista lateral sin re-renderizar todo.
 */
function syncSelectedCardInList(idPostg) {
  for (const btn of document.querySelectorAll(".result-card")) {
    btn.classList.toggle("result-card--active", btn.dataset.idPostg === idPostg);
  }
}

/**
 * Cambia entre la pestaña de Ficha Alfanumérica y la pestaña de Ruteo.
 */
function switchDetailTab(tabName) {
  state.activeDetailTab = tabName;
  const fichaTab = document.getElementById("tab-btn-ficha");
  const rutaTab = document.getElementById("tab-btn-ruta");
  const fichaPanel = document.getElementById("panel-ficha");
  const rutaPanel = document.getElementById("panel-ruta");

  const isFicha = tabName === "ficha";
  if (fichaTab) {
    fichaTab.setAttribute("aria-selected", String(isFicha));
    fichaTab.classList.toggle("detail-tab--active", isFicha);
  }
  if (rutaTab) {
    rutaTab.setAttribute("aria-selected", String(!isFicha));
    rutaTab.classList.toggle("detail-tab--active", !isFicha);
  }
  if (fichaPanel) fichaPanel.hidden = !isFicha;
  if (rutaPanel) rutaPanel.hidden = isFicha;
}

/**
 * Abre y rellena la Ficha Alfanumérica completa de una unidad (Requisito #21).
 */
function populateDetailPanel(feature) {
  const panel = document.getElementById("detail-panel");
  if (!panel || !feature) return;

  const props = feature.properties || {};
  const style =
    POSTGRADO_STYLES[props.tipo_ent] || POSTGRADO_STYLES.Unidad_Facultativa;

  panel.hidden = false;

  // Imagen con fallback limpio a assets/placeholder.svg
  const img = document.getElementById("detail-photo");
  if (img) {
    img.dataset.fallbackApplied = "";
    img.alt = `Fachada de ${props.nom_unidad || "Unidad de Postgrado"}`;
    img.onerror = () => {
      if (img.dataset.fallbackApplied === "1") return;
      img.dataset.fallbackApplied = "1";
      img.src = "assets/placeholder.svg";
    };
    const rawUrl = props.url_foto && props.url_foto !== "S/D" ? props.url_foto : "";
    img.src = rawUrl || "assets/placeholder.svg";
  }

  const badgeId = document.getElementById("detail-id");
  const badgeSigla = document.getElementById("detail-sigla");
  const badgeTipo = document.getElementById("detail-tipo");
  const badgeGeo = document.getElementById("detail-geo");

  if (badgeId) badgeId.textContent = props.id_postg || "";
  if (badgeSigla) {
    badgeSigla.textContent = props.cod_fac || "";
    badgeSigla.className = `unit-badge ${style.badgeClass}`;
  }
  if (badgeTipo) badgeTipo.textContent = style.label;
  if (badgeGeo) {
    badgeGeo.textContent =
      props.estado_geo === "Verificado" ? "Verificado" : "Revisar campo";
    badgeGeo.className = `geo-pill ${
      props.estado_geo === "Verificado" ? "geo-pill--ok" : "geo-pill--warn"
    }`;
  }

  const titleEl = document.getElementById("detail-title");
  const facultyEl = document.getElementById("detail-faculty");
  if (titleEl) titleEl.textContent = props.nom_unidad || "";
  if (facultyEl) facultyEl.textContent = props.nom_facult || "";

  // Botones de acción rápida
  const { telHref, waHref } = formatPhoneLinks(props.telefono);
  const callBtn = document.getElementById("action-call");
  const waBtn = document.getElementById("action-whatsapp");
  const mailBtn = document.getElementById("action-email");
  const webBtn = document.getElementById("action-web");

  if (callBtn) {
    callBtn.hidden = !telHref;
    if (telHref) {
      callBtn.href = telHref;
      callBtn.title = `Llamar al ${props.telefono}`;
    }
  }
  if (waBtn) {
    waBtn.hidden = !waHref;
    if (waHref) waBtn.href = waHref;
  }
  if (mailBtn) {
    const hasEmail = props.correo && props.correo !== "S/D";
    mailBtn.hidden = !hasEmail;
    if (hasEmail) mailBtn.href = `mailto:${props.correo}`;
  }
  if (webBtn) {
    const hasWeb =
      props.sitio_web &&
      props.sitio_web !== "S/D" &&
      /^https?:\/\//i.test(props.sitio_web);
    webBtn.hidden = !hasWeb;
    if (hasWeb) webBtn.href = props.sitio_web;
  }

  // Campos alfanuméricos detallados
  const areaVal = Number(props.area_m2);
  const distVal = Number(props.dist_via_m);
  const latNum = Number(props.lat_wgs84);
  const lonNum = Number(props.lon_wgs84);

  const fields = {
    "meta-campus": `${props.campus || "—"} (${props.ambito || "—"} · ${props.municipio || "—"})`,
    "meta-modulo": props.modulo_pab || "S/D",
    "meta-direccion": props.direccion || "S/D",
    "meta-programas": props.programas || "S/D",
    "meta-horario": props.horario || "S/D",
    "meta-telefono": props.telefono || "S/D",
    "meta-correo": props.correo || "S/D",
    "meta-area": Number.isFinite(areaVal) ? `${areaVal.toFixed(2)} m²` : "0.00 m²",
    "meta-dist-via": Number.isFinite(distVal) ? `${distVal.toFixed(2)} m` : "—",
    "meta-coords":
      Number.isFinite(latNum) && Number.isFinite(lonNum)
        ? `${latNum.toFixed(5)}, ${lonNum.toFixed(5)}`
        : "—",
    "meta-qr": props.cod_qr || "—",
  };

  for (const [elId, value] of Object.entries(fields)) {
    const el = document.getElementById(elId);
    if (el) el.textContent = value;
  }

  setRoutingDestination(feature);
}

/**
 * Selecciona una unidad de postgrado, la enfoca en el mapa y abre su ficha.
 */
async function selectPostgrado(feature, options = {}) {
  if (!feature) return;
  const props = feature.properties || {};

  // Si llegó por ?qr= y corresponde a un ámbito distinto al filtro actual, ajustar filtro
  if (
    options.fromQr &&
    state.filters.ambito !== "Todos" &&
    props.ambito &&
    props.ambito.toLowerCase() !== state.filters.ambito.toLowerCase()
  ) {
    state.filters.ambito = "Todos";
    const ambitoSelect = document.getElementById("filter-ambito");
    if (ambitoSelect) ambitoSelect.value = "Todos";
    await loadPostgradosLayer({ skipFitBounds: true });
  }

  state.selectedFeature = feature;
  syncSelectedCardInList(props.id_postg);
  highlightAndFocusPostgrado(feature, 17);
  populateDetailPanel(feature);
  switchDetailTab("ficha");
}

/**
 * Carga /api/postgrados aplicando los filtros activos.
 */
async function loadPostgradosLayer(options = {}) {
  const { skipFitBounds = false, drawerApi = null } = options;
  try {
    const fc = await fetchPostgrados(state.filters, () =>
      loadPostgradosLayer(options)
    );
    const features = fc?.features || [];
    state.features = features;

    renderPostgrados(fc, (feature) => {
      selectPostgrado(feature);
    });
    renderResultsList(features, drawerApi);

    if (!skipFitBounds && (state.filters.ambito !== "Urbano" || state.filters.q || state.filters.campus !== "Todos")) {
      fitBoundsToFeatures(features);
    }
  } catch {
    // El banner no bloqueante de api.js muestra el error y botón de reintento
  }
}

/**
 * Construye y gestiona la Tabla de Infraestructura (Producto Final).
 */
function setupInfrastructureTable(drawerApi) {
  const dialog = document.getElementById("table-dialog");
  const openBtn = document.getElementById("open-table-btn");
  const table = document.getElementById("infra-table");
  const tbody = document.getElementById("infra-tbody");
  const filterInput = document.getElementById("table-search-input");
  const exportBtn = document.getElementById("export-csv-btn");
  const visibleBadge = document.getElementById("table-visible-count");
  const sortStatus = document.getElementById("table-sort-status");

  if (!dialog || !openBtn || !table || !tbody) return;

  const collator = new Intl.Collator("es", {
    numeric: true,
    sensitivity: "base",
  });

  function renderTableRows(features) {
    tbody.replaceChildren();

    for (const feature of features) {
      const p = feature.properties || {};
      const tr = document.createElement("tr");
      tr.className = "infra-row";
      tr.dataset.searchText = [
        p.id_postg,
        p.cod_fac,
        p.nom_unidad,
        p.nom_facult,
        p.campus,
        p.modulo_pab,
        p.direccion,
        p.municipio,
        p.cod_qr,
      ]
        .join(" ")
        .toLowerCase();

      // Al hacer clic en cualquier fila: cierra la tabla, hace zoom al mapa y abre ficha
      tr.addEventListener("click", (e) => {
        if (e.target.closest("a")) return;
        dialog.close();
        drawerApi?.closeIfMobile();
        selectPostgrado(feature);
      });

      const thId = document.createElement("th");
      thId.scope = "row";
      const idBtn = document.createElement("button");
      idBtn.type = "button";
      idBtn.className = "table-row-btn";
      idBtn.textContent = p.id_postg || "";
      idBtn.setAttribute("aria-label", `Ubicar ${p.id_postg} ${p.cod_fac} en el mapa`);
      thId.appendChild(idBtn);

      const cells = [
        { text: p.cod_fac || "" },
        { text: p.nom_unidad || "" },
        { text: p.campus || "" },
        { text: p.modulo_pab || "S/D" },
        { text: p.direccion || "S/D" },
        { text: p.telefono || "S/D" },
        {
          text: Number.isFinite(Number(p.area_m2))
            ? `${Number(p.area_m2).toFixed(2)}`
            : "0.00",
          raw: Number(p.area_m2) || 0,
        },
        { text: p.estado_geo === "Verificado" ? "Verificado" : "Revisar campo" },
        { text: p.cod_qr || "" },
      ];

      tr.appendChild(thId);
      for (const c of cells) {
        const td = document.createElement("td");
        td.textContent = c.text;
        if (c.raw !== undefined) {
          td.dataset.value = String(c.raw);
        }
        tr.appendChild(td);
      }

      tbody.appendChild(tr);
    }

    applyTableLocalFilter();
  }

  function applyTableLocalFilter() {
    const query = (filterInput?.value || "").trim().toLowerCase();
    let count = 0;
    for (const row of tbody.rows) {
      const match = !query || (row.dataset.searchText || "").includes(query);
      row.hidden = !match;
      if (match) count += 1;
    }
    if (visibleBadge) {
      visibleBadge.textContent = `${count} registros`;
    }
  }

  function sortByButton(button) {
    const th = button.closest("th");
    if (!th) return;
    const direction =
      th.getAttribute("aria-sort") === "ascending" ? "descending" : "ascending";

    for (const header of table.tHead.rows[0].cells) {
      header.removeAttribute("aria-sort");
    }
    th.setAttribute("aria-sort", direction);

    const colIndex = th.cellIndex;
    const colType = th.dataset.type || "text";
    const factor = direction === "ascending" ? 1 : -1;

    const rows = [...tbody.rows];
    const getVal = (row) =>
      row.cells[colIndex].dataset.value ?? row.cells[colIndex].textContent.trim();

    rows.sort((a, b) => {
      const va = getVal(a);
      const vb = getVal(b);
      return (
        factor *
        (colType === "number"
          ? Number(va) - Number(vb)
          : collator.compare(va, vb))
      );
    });

    const reorderRows = () => {
      for (const row of rows) {
        if (typeof tbody.moveBefore === "function") {
          tbody.moveBefore(row, null);
        } else {
          tbody.appendChild(row);
        }
      }
    };

    if (typeof table.startViewTransition === "function") {
      table.startViewTransition(reorderRows);
    } else {
      reorderRows();
    }

    if (sortStatus) {
      sortStatus.textContent = `Tabla ordenada por ${button.textContent.trim()}, ${
        direction === "ascending" ? "ascendente" : "descendente"
      }, ${rows.length} filas.`;
    }
  }

  // Invoker command (--sort) con fallback para navegadores sin commandForElement
  table.addEventListener("command", (event) => {
    if (event.command === "--sort") {
      sortByButton(event.source);
    }
  });

  if (!("commandForElement" in HTMLButtonElement.prototype)) {
    for (const button of table.tHead.querySelectorAll('button[command="--sort"]')) {
      button.addEventListener("click", () => sortByButton(button));
    }
  }

  openBtn.addEventListener("click", () => {
    if (filterInput) filterInput.value = "";
    renderTableRows(state.features);
    dialog.showModal();
  });

  if (filterInput) {
    filterInput.addEventListener("input", applyTableLocalFilter);
  }

  if (exportBtn) {
    exportBtn.addEventListener("click", () => {
      const headers = [
        "ID",
        "Sigla",
        "Unidad",
        "Campus",
        "Modulo",
        "Direccion",
        "Telefono",
        "Superficie_m2",
        "Estado_Geo",
        "Codigo_QR",
      ];
      const csvRows = [headers.join(",")];

      for (const row of tbody.rows) {
        if (row.hidden) continue;
        const cols = [...row.cells].map((cell) => {
          const val = cell.textContent.trim().replace(/"/g, '""');
          return `"${val}"`;
        });
        csvRows.push(cols.join(","));
      }

      const blob = new Blob(["\uFEFF" + csvRows.join("\r\n")], {
        type: "text/csv;charset=utf-8;",
      });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = `postgrados_uagrm_${state.filters.ambito.toLowerCase()}.csv`;
      a.click();
      URL.revokeObjectURL(url);
    });
  }
}

/**
 * Inicializa todos los listeners y carga los datos iniciales desde FastAPI.
 */
async function bootstrap() {
  initApiBannerControls();
  setupDialogLightDismissFallback();
  initMap("map");
  initRouting();

  const drawerApi = setupResponsiveDrawer();
  setupInfrastructureTable(drawerApi);

  initQrModule((feature, meta) => {
    selectPostgrado(feature, meta);
  });

  // Toggle rápido de Servicios de Apoyo en barra superior
  const toggleServBtn = document.getElementById("toggle-services-btn");
  if (toggleServBtn) {
    toggleServBtn.addEventListener("click", () => {
      state.serviciosVisible = !state.serviciosVisible;
      toggleServBtn.setAttribute("aria-pressed", String(state.serviciosVisible));
      setServiciosVisible(state.serviciosVisible);
    });
  }

  // Botón centrar mapa en zona universitaria
  const centerBtn = document.getElementById("center-map-btn");
  if (centerBtn) {
    centerBtn.addEventListener("click", () => {
      resetMapView();
    });
  }

  // Controles de filtros y búsqueda en tiempo real
  const searchInput = document.getElementById("filter-search");
  const ambitoSelect = document.getElementById("filter-ambito");
  const campusSelect = document.getElementById("filter-campus");
  const clearFiltersBtn = document.getElementById("clear-filters-btn");

  if (searchInput) {
    searchInput.addEventListener("input", () => {
      window.clearTimeout(searchDebounceTimer);
      searchDebounceTimer = window.setTimeout(() => {
        state.filters.q = searchInput.value;
        loadPostgradosLayer({ drawerApi });
      }, 240);
    });
  }

  if (ambitoSelect) {
    ambitoSelect.value = state.filters.ambito;
    ambitoSelect.addEventListener("change", () => {
      state.filters.ambito = ambitoSelect.value;
      loadPostgradosLayer({ drawerApi });
    });
  }

  if (campusSelect) {
    campusSelect.addEventListener("change", () => {
      state.filters.campus = campusSelect.value;
      loadPostgradosLayer({ drawerApi });
    });
  }

  if (clearFiltersBtn) {
    clearFiltersBtn.addEventListener("click", () => {
      state.filters = { ambito: "Urbano", campus: "Todos", q: "" };
      if (searchInput) searchInput.value = "";
      if (ambitoSelect) ambitoSelect.value = "Urbano";
      if (campusSelect) campusSelect.value = "Todos";
      clearRoute();
      resetMapView();
      loadPostgradosLayer({ skipFitBounds: true, drawerApi });
    });
  }

  // Panel de detalle: cerrar, tabs, "Cómo llegar", "Ver / Descargar QR"
  const closeDetailBtn = document.getElementById("detail-close-btn");
  const detailPanel = document.getElementById("detail-panel");
  if (closeDetailBtn && detailPanel) {
    closeDetailBtn.addEventListener("click", () => {
      detailPanel.hidden = true;
    });
  }

  const fichaTab = document.getElementById("tab-btn-ficha");
  const rutaTab = document.getElementById("tab-btn-ruta");
  if (fichaTab) fichaTab.addEventListener("click", () => switchDetailTab("ficha"));
  if (rutaTab) rutaTab.addEventListener("click", () => switchDetailTab("ruta"));

  const howToGetBtn = document.getElementById("action-route");
  if (howToGetBtn) {
    howToGetBtn.addEventListener("click", () => {
      if (state.selectedFeature) {
        setRoutingDestination(state.selectedFeature);
      }
      switchDetailTab("ruta");
    });
  }

  const openQrBtn = document.getElementById("action-qr");
  if (openQrBtn) {
    openQrBtn.addEventListener("click", () => {
      if (state.selectedFeature) {
        openQrGeneratorModal(state.selectedFeature);
      }
    });
  }

  // Carga inicial paralela desde FastAPI + PostGIS
  const loadInitialData = async () => {
    const [resumenRes, serviciosRes] = await Promise.allSettled([
      fetchResumen(loadInitialData),
      fetchServicios("", loadInitialData),
      loadPostgradosLayer({ skipFitBounds: true, drawerApi }),
    ]);

    if (resumenRes.status === "fulfilled") {
      renderResumenCounters(resumenRes.value);
    }
    if (serviciosRes.status === "fulfilled") {
      state.allServicios = serviciosRes.value;
      renderServicios(serviciosRes.value);
      setServiciosVisible(state.serviciosVisible);
    }
  };

  await loadInitialData();

  // Requisito #21: detectar ?qr=CODIGO al abrir la aplicación
  await checkInitialQrParam(
    (feature, meta) => selectPostgrado(feature, meta),
    (badCode) => {
      showToast(
        `No se encontró ninguna unidad de postgrado con código QR "${badCode}".`
      );
    }
  );
}

document.addEventListener("DOMContentLoaded", bootstrap);
