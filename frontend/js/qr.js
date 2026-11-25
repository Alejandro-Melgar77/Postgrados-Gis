import { fetchPostgradoByQr } from "./api.js";

/**
 * Módulo de Consulta Móvil por Código QR (Requisito #21):
 * - Lectura de parámetro URL ?qr=CODIGO al cargar la app
 * - Generador dinámico de QR imprimible (QRCode.js) con descarga PNG
 * - Escáner de cámara móvil (html5-qrcode) + lectura de archivo e ingreso manual
 */

let html5QrScanner = null;
let isScanning = false;
let onPostgradoResolvedCallback = null;

/**
 * Extrae el código UAGRM-PG-XXX tanto de una URL completa (?qr=...)
 * como de un código directo escaneado.
 */
export function extractQrCode(rawText) {
  if (!rawText) return "";
  const trimmed = String(rawText).trim();
  if (!trimmed) return "";

  try {
    const parsedUrl = new URL(trimmed);
    const paramQr = parsedUrl.searchParams.get("qr");
    if (paramQr) return paramQr.trim();
  } catch {
    // No es URL completa; revisar si contiene ?qr=
    const match = trimmed.match(/[?&]qr=([^&#]+)/i);
    if (match && match[1]) {
      return decodeURIComponent(match[1]).trim();
    }
  }

  return trimmed;
}

export function buildQrTargetUrl(codQr) {
  return `${window.location.origin}${window.location.pathname}?qr=${encodeURIComponent(codQr)}`;
}

/**
 * Genera el código QR dentro del modal nativo <dialog id="qr-dialog">.
 */
export function openQrGeneratorModal(feature) {
  if (!feature) return;
  const props = feature.properties || {};
  const codQr = props.cod_qr || "";

  const dialog = document.getElementById("qr-dialog");
  const titleEl = document.getElementById("qr-dialog-unit");
  const codeEl = document.getElementById("qr-dialog-code");
  const urlEl = document.getElementById("qr-dialog-url");
  const container = document.getElementById("qr-canvas-container");
  const downloadBtn = document.getElementById("qr-download-btn");
  if (!dialog || !container) return;

  const targetUrl = buildQrTargetUrl(codQr);
  if (titleEl) titleEl.textContent = `${props.cod_fac || ""} — ${props.nom_unidad || ""}`;
  if (codeEl) codeEl.textContent = codQr;
  if (urlEl) urlEl.textContent = targetUrl;

  container.replaceChildren();

  if (typeof window.QRCode === "function") {
    new window.QRCode(container, {
      text: targetUrl,
      width: 220,
      height: 220,
      colorDark: "#0f2b5b",
      colorLight: "#ffffff",
      correctLevel: window.QRCode.CorrectLevel.H,
    });
  } else {
    const fallbackNote = document.createElement("p");
    fallbackNote.textContent =
      "La librería QRCode.js no pudo cargarse. Verificá tu conexión a internet.";
    container.appendChild(fallbackNote);
  }

  if (downloadBtn) {
    downloadBtn.onclick = () => downloadQrPng(container, props);
  }

  dialog.showModal();
}

function downloadQrPng(container, props) {
  const sourceCanvas = container.querySelector("canvas");
  const sourceImg = container.querySelector("img");

  const exportCanvas = document.createElement("canvas");
  const width = 420;
  const height = 500;
  exportCanvas.width = width;
  exportCanvas.height = height;

  const ctx = exportCanvas.getContext("2d");
  ctx.fillStyle = "#ffffff";
  ctx.fillRect(0, 0, width, height);

  // Marco institucional
  ctx.strokeStyle = "#0f2b5b";
  ctx.lineWidth = 6;
  ctx.strokeRect(14, 14, width - 28, height - 28);

  ctx.fillStyle = "#0f2b5b";
  ctx.font = "bold 18px system-ui, sans-serif";
  ctx.textAlign = "center";
  ctx.fillText("POSTGRADOS UAGRM · WEBGIS", width / 2, 54);

  ctx.fillStyle = "#8b1538";
  ctx.font = "bold 20px system-ui, sans-serif";
  ctx.fillText(props.cod_fac || props.id_postg || "", width / 2, 84);

  const finalizeDownload = () => {
    ctx.fillStyle = "#0f172a";
    ctx.font = "bold 16px monospace";
    ctx.fillText(props.cod_qr || "", width / 2, 434);

    ctx.fillStyle = "#475569";
    ctx.font = "13px system-ui, sans-serif";
    const shortName = (props.nom_unidad || "").slice(0, 44);
    ctx.fillText(shortName, width / 2, 462);

    const link = document.createElement("a");
    link.download = `${props.cod_qr || "QR-UAGRM"}.png`;
    link.href = exportCanvas.toDataURL("image/png");
    link.click();
  };

  if (sourceCanvas) {
    ctx.drawImage(sourceCanvas, 65, 108, 290, 290);
    finalizeDownload();
  } else if (sourceImg && sourceImg.src) {
    const img = new Image();
    img.onload = () => {
      ctx.drawImage(img, 65, 108, 290, 290);
      finalizeDownload();
    };
    img.src = sourceImg.src;
  }
}

async function stopCameraScanner() {
  if (html5QrScanner && isScanning) {
    try {
      await html5QrScanner.stop();
    } catch {
      // Ignorar si ya estaba detenido
    }
    try {
      html5QrScanner.clear();
    } catch {
      // Ignorar
    }
  }
  isScanning = false;
}

async function resolveAndNotifyQr(rawText, statusEl, dialog) {
  const code = extractQrCode(rawText);
  if (!code) {
    if (statusEl) {
      statusEl.textContent = "El código escaneado no contiene un identificador válido.";
    }
    return;
  }

  if (statusEl) {
    statusEl.textContent = `Consultando unidad "${code}"...`;
  }

  try {
    const feature = await fetchPostgradoByQr(code);
    await stopCameraScanner();
    if (dialog?.open) dialog.close();
    if (typeof onPostgradoResolvedCallback === "function") {
      onPostgradoResolvedCallback(feature, { fromQr: true });
    }
  } catch (err) {
    if (statusEl) {
      statusEl.textContent =
        err.status === 404
          ? `No se encontró ninguna unidad con código QR "${code}".`
          : `Error al consultar el servidor para "${code}".`;
    }
  }
}

async function startCameraScanner(statusEl, dialog) {
  if (typeof window.Html5Qrcode !== "function") {
    if (statusEl) {
      statusEl.textContent =
        "El lector de cámara (html5-qrcode) no está disponible sin conexión. Usá el ingreso manual o imagen.";
    }
    return;
  }

  if (
    !window.isSecureContext &&
    window.location.hostname !== "localhost" &&
    window.location.hostname !== "127.0.0.1"
  ) {
    if (statusEl) {
      statusEl.textContent =
        "La cámara móvil requiere HTTPS. Podés subir una foto del QR o escribir el código manualmente.";
    }
    return;
  }

  await stopCameraScanner();
  html5QrScanner = new window.Html5Qrcode("qr-reader-region");

  if (statusEl) {
    statusEl.textContent = "Iniciando cámara trasera...";
  }

  try {
    isScanning = true;
    await html5QrScanner.start(
      { facingMode: "environment" },
      { fps: 10, qrbox: { width: 220, height: 220 } },
      async (decodedText) => {
        if (!isScanning) return;
        isScanning = false;
        await stopCameraScanner();
        await resolveAndNotifyQr(decodedText, statusEl, dialog);
      },
      () => {
        // Ignorar errores de frame individual sin QR
      }
    );
    if (statusEl) {
      statusEl.textContent = "Apuntá la cámara al código QR de la unidad de postgrado.";
    }
  } catch {
    isScanning = false;
    if (statusEl) {
      statusEl.textContent =
        "No se pudo acceder a la cámara (permiso denegado o PC sin cámara). Podés subir una imagen QR o escribir el código abajo.";
    }
  }
}

export function initQrModule(onPostgradoResolved) {
  onPostgradoResolvedCallback = onPostgradoResolved;

  const openScannerBtn = document.getElementById("open-qr-scanner-btn");
  const scannerDialog = document.getElementById("scanner-dialog");
  const scannerStatus = document.getElementById("qr-scanner-status");
  const qrFileInput = document.getElementById("qr-file-input");
  const manualForm = document.getElementById("qr-manual-form");
  const manualInput = document.getElementById("qr-manual-input");

  if (openScannerBtn && scannerDialog) {
    openScannerBtn.addEventListener("click", () => {
      scannerDialog.showModal();
      startCameraScanner(scannerStatus, scannerDialog);
    });

    scannerDialog.addEventListener("close", () => {
      stopCameraScanner();
    });
  }

  if (qrFileInput && scannerDialog) {
    qrFileInput.addEventListener("change", async (e) => {
      const file = e.target.files?.[0];
      if (!file) return;
      if (typeof window.Html5Qrcode !== "function") return;

      await stopCameraScanner();
      const fileScanner = new window.Html5Qrcode("qr-reader-region");
      try {
        const decoded = await fileScanner.scanFile(file, true);
        await resolveAndNotifyQr(decoded, scannerStatus, scannerDialog);
      } catch {
        if (scannerStatus) {
          scannerStatus.textContent =
            "No se detectó un código QR válido en la imagen seleccionada.";
        }
      } finally {
        qrFileInput.value = "";
      }
    });
  }

  if (manualForm && manualInput && scannerDialog) {
    manualForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      const val = manualInput.value.trim();
      if (!val) return;
      await resolveAndNotifyQr(val, scannerStatus, scannerDialog);
    });
  }
}

/**
 * Verifica ?qr=CODIGO al abrir la aplicación y consulta GET /api/postgrados/qr/{cod_qr}.
 */
export async function checkInitialQrParam(onResolved, onNotFound) {
  const params = new URLSearchParams(window.location.search);
  const qrCode = params.get("qr")?.trim();
  if (!qrCode) return false;

  try {
    const feature = await fetchPostgradoByQr(qrCode);
    if (typeof onResolved === "function") {
      onResolved(feature, { fromQr: true });
    }
    return true;
  } catch {
    if (typeof onNotFound === "function") {
      onNotFound(qrCode);
    }
    return false;
  }
}
