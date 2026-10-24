"""Utilidades comunes para abrir slides/index.html con Playwright + Chromium.

Las usan video/record_slides.py, video/export_pdf.py y slides/dev/screenshots.py.

- Sirve la RAÍZ del repositorio con http.server en un puerto libre (así
  ../figures/numbers.json y ../figures/static/*.png resuelven desde /slides/).
- Lanza Chromium: el de Playwright si está instalado; si no, /usr/bin/chromium.
- Espera a window.deckReady (lo pone slides/js/init.js).
"""
from __future__ import annotations

import contextlib
import functools
import http.server
import os
import shutil
import socket
import threading
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
SYSTEM_CHROMIUM = shutil.which("chromium") or shutil.which("chromium-browser") or "/usr/bin/chromium"
W, H = 1920, 1080


def free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("127.0.0.1", 0))
        return s.getsockname()[1]


class _QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):  # silencio
        pass

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


@contextlib.contextmanager
def serve(root: Path = REPO, port: int | None = None):
    """Sirve `root` en 127.0.0.1:<puerto libre>; devuelve la URL base."""
    port = port or free_port()
    handler = functools.partial(_QuietHandler, directory=str(root))
    httpd = http.server.ThreadingHTTPServer(("127.0.0.1", port), handler)
    t = threading.Thread(target=httpd.serve_forever, daemon=True)
    t.start()
    try:
        yield f"http://127.0.0.1:{port}"
    finally:
        httpd.shutdown()
        httpd.server_close()


def launch(pw, headless: bool = True):
    """Chromium de Playwright si existe; si no, el del sistema."""
    args = ["--no-sandbox", "--autoplay-policy=no-user-gesture-required",
            "--force-color-profile=srgb", "--hide-scrollbars", "--font-render-hinting=none"]
    try:
        return pw.chromium.launch(headless=headless, args=args)
    except Exception:
        return pw.chromium.launch(headless=headless, executable_path=SYSTEM_CHROMIUM, args=args)


def wait_ready(page, timeout_ms: int = 30000, print_mode: bool = False):
    page.wait_for_function("window.deckReady === true || !!window.deckError", timeout=timeout_ms)
    err = page.evaluate("window.deckError || null")
    if err:
        raise RuntimeError(f"El deck no arrancó: {err}")
    if print_mode:
        page.wait_for_function("window.pdfReady === true", timeout=timeout_ms)
    # deja cargar imágenes / pósters y que los marcadores calculen su tamaño
    page.wait_for_timeout(800)


def deck_url(base: str, query: str = "") -> str:
    q = ("?" + query.lstrip("?")) if query else ""
    return f"{base}/slides/index.html{q}"


def env_report(page) -> dict:
    return page.evaluate(
        """() => ({numbers: window.NUMBERS_REPORT || null,
                   figs: window.FIG_REPORT || null,
                   steps: (window.deckSteps ? window.deckSteps() : []),
                   source: window.DeckNumbers ? window.DeckNumbers.source : null})"""
    )


if __name__ == "__main__":  # prueba rápida
    print("REPO =", REPO, "| chromium =", SYSTEM_CHROMIUM, "| exists:", os.path.exists(SYSTEM_CHROMIUM))
