"""Exporta slides/index.html?print-pdf a slides/export/slides.pdf (Chromium headless).

Ruta principal: Playwright → page.pdf() tras el evento 'pdf-ready' de reveal.js
(más fiable que --print-to-pdf porque espera a numbers.json y a la maquetación).
Respaldo (--cli): chromium --headless --print-to-pdf con --virtual-time-budget.

Comprueba que el PDF tiene exactamente 6 páginas (portada + 4 + referencias) con pypdf
y sale con código 1 si no. Opcional: --png renderiza cada página a PNG (pdftoppm)
en slides/export/pages/ para revisarlas.
"""
from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from deck_browser import REPO, SYSTEM_CHROMIUM, H, W, deck_url, launch, serve, wait_ready  # noqa: E402

EXPECTED_PAGES = 6
OUT = REPO / "slides" / "export" / "slides.pdf"


def export_playwright(out: Path, query: str) -> None:
    from playwright.sync_api import sync_playwright
    with serve() as base, sync_playwright() as pw:
        b = launch(pw)
        pg = b.new_page(viewport={"width": W, "height": H})
        pg.goto(deck_url(base, "print-pdf" + ("&" + query if query else "")))
        wait_ready(pg, print_mode=True)
        # todas las imágenes (figuras, pósters, banderas SVG) cargadas o fallidas
        pg.wait_for_function("Array.from(document.images).every(i => i.complete)", timeout=30000)
        pg.wait_for_timeout(1200)
        pg.emulate_media(media="print")
        pg.pdf(path=str(out), width=f"{W}px", height=f"{H}px", print_background=True,
               prefer_css_page_size=True, margin={"top": "0", "right": "0", "bottom": "0", "left": "0"})
        b.close()


def export_cli(out: Path, query: str) -> None:
    with serve() as base:
        url = deck_url(base, "print-pdf" + ("&" + query if query else ""))
        cmd = [SYSTEM_CHROMIUM, "--headless=new", "--no-sandbox", "--disable-gpu", "--hide-scrollbars",
               "--run-all-compositor-stages-before-draw", "--virtual-time-budget=25000",
               "--no-pdf-header-footer", f"--print-to-pdf={out}", url]
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=180)


def count_pages(pdf: Path) -> int:
    from pypdf import PdfReader
    return len(PdfReader(str(pdf)).pages)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", default=str(OUT))
    ap.add_argument("--cli", action="store_true", help="usar chromium --print-to-pdf en vez de Playwright")
    ap.add_argument("--png", action="store_true", help="renderizar páginas a PNG (pdftoppm, 48 dpi)")
    ap.add_argument("--query", default="", help="parámetros extra (p. ej. qa=off)")
    a = ap.parse_args()
    out = Path(a.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    try:
        (export_cli if a.cli else export_playwright)(out, a.query)
    except Exception as e:  # respaldo automático
        if a.cli:
            raise
        print(f"[export_pdf] Playwright falló ({e}); uso chromium --print-to-pdf", file=sys.stderr)
        export_cli(out, a.query)
    n = count_pages(out)
    print(f"[export_pdf] {out} · {n} páginas · {out.stat().st_size / 1e6:.2f} MB")
    if a.png and shutil.which("pdftoppm"):
        pages = out.parent / "pages"
        pages.mkdir(exist_ok=True)
        subprocess.run(["pdftoppm", "-png", "-r", "48", str(out), str(pages / "page")], check=True)
        print(f"[export_pdf] PNG por página en {pages}")
    if n != EXPECTED_PAGES:
        print(f"[export_pdf] ERROR: se esperaban {EXPECTED_PAGES} páginas", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
