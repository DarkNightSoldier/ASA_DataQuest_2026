#!/usr/bin/env python3
"""Exporta el guion de la narración (narration_en.md) a un PDF A4 legible en voz alta.

Qué hace
  1. Convierte `slides/script/narration_en.md` a HTML con la librería `markdown`
     (extensiones `tables` y `extra`).
  2. Le aplica un CSS de impresión A4: Lato (respaldo Noto Sans), cuerpo de 11 pt, frases de
     narración (blockquotes `>`) a 14 pt con interlineado 1,5, tablas compactas a 9 pt con bordes
     finos, encabezados que no quedan huérfanos al final de página, márgenes de 18 mm y pie con
     "página N de M".
  3. Lo imprime a PDF con Chromium headless -> `slides/script/narration_en.pdf`.

Uso (desde cualquier carpeta)
  python slides/script/export_guion_pdf.py                   # narration_en.md -> narration_en.pdf
  python slides/script/export_guion_pdf.py --keep-html       # además deja narration_en.html (depuración)
  python slides/script/export_guion_pdf.py --chromium /ruta  # otro Chromium/Chrome
  python slides/script/export_guion_pdf.py -i otro.md -o otro.pdf

Requisitos: `pip install markdown` y Chromium (o Chrome) instalado. No toca el guion: el PDF se
regenera después de cada `build_narration.py` (el guion es un archivo generado; no se edita a mano).
"""
from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
import tempfile
from html import escape
from pathlib import Path

try:
    import markdown
except ImportError:  # pragma: no cover
    sys.exit("Falta la librería 'markdown': pip install markdown")

HERE = Path(__file__).resolve().parent
DEFAULT_MD = HERE / "narration_en.md"
DEFAULT_PDF = HERE / "narration_en.pdf"

CHROMIUM_CANDIDATES = (
    "/usr/bin/chromium",
    "chromium",
    "chromium-browser",
    "google-chrome",
    "google-chrome-stable",
)

CSS = r"""
@page {
  size: A4;
  margin: 18mm;
  @bottom-center {
    content: "UNALSta-R · guion de narración · página " counter(page) " de " counter(pages);
    font-family: "Lato", "Noto Sans", sans-serif;
    font-size: 8.5pt;
    color: #6b7280;
  }
}
* { box-sizing: border-box; }
html { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
body {
  font-family: "Lato", "Noto Sans", "DejaVu Sans", sans-serif;
  font-size: 11pt;
  line-height: 1.4;
  color: #1f2937;
  margin: 0;
}
h1, h2, h3 {
  font-family: "Lato", "Noto Sans", "DejaVu Sans", sans-serif;
  color: #0f2f57;
  break-after: avoid;
  page-break-after: avoid;
  break-inside: avoid;
}
h1 { font-size: 20pt; line-height: 1.2; margin: 0 0 6mm; padding-bottom: 3mm; border-bottom: 2px solid #0f2f57; }
h2 { font-size: 15pt; line-height: 1.25; margin: 9mm 0 3mm; padding-bottom: 1.5mm; border-bottom: 1px solid #c7d2e0; }
h3 { font-size: 12pt; margin: 6mm 0 2mm; }
p { margin: 0 0 3mm; orphans: 3; widows: 3; }
strong { font-weight: 700; }
code {
  font-family: "DejaVu Sans Mono", "Noto Sans Mono", monospace;
  font-size: 0.88em;
  background: #eef2f7;
  border-radius: 2px;
  padding: 0 1.2mm;
}

/* Notas de cabecera (generado por..., recuento de palabras...): pequeñas, no se leen en voz alta */
.meta { font-size: 9.5pt; line-height: 1.35; color: #4b5563; }
.meta blockquote {
  margin: 0 0 2.5mm; padding: 1.5mm 3mm;
  border-left: 3px solid #cbd5e1; background: #f8fafc;
  font-size: 9.5pt; line-height: 1.35; color: #4b5563;
}
.meta blockquote p { margin: 0; white-space: normal; }

/* Etiqueta de cada paso (`s1.b2` · fragmento 2 · tiempos): gris, pegada a su narración */
p:has(> strong:first-child > code) {
  font-size: 9.5pt; color: #64748b; margin: 5mm 0 1.2mm;
  break-after: avoid; page-break-after: avoid;
}
p:has(> strong:first-child > code) code { background: #e2e8f0; color: #0f2f57; font-weight: 700; }

/* Frases de narración: lo que se lee en voz alta */
blockquote {
  margin: 0 0 2mm;
  padding: 2.5mm 5mm;
  border-left: 5px solid #1d5fa8;
  background: #eef5fc;
  color: #0b1b2e;
  font-size: 14pt;
  line-height: 1.5;
  font-weight: 700;
  break-inside: avoid;
  page-break-inside: avoid;
}
blockquote p { margin: 0; white-space: pre-line; orphans: 4; widows: 4; }
blockquote code { font-size: 0.8em; }

/* Pasos sin voz: "(sin voz: transición)" */
p > em:only-child { color: #6b7280; font-size: 10pt; }

/* Tablas compactas */
table {
  width: 100%;
  border-collapse: collapse;
  font-size: 9pt;
  line-height: 1.25;
  margin: 2mm 0 5mm;
  table-layout: auto;
}
thead { display: table-header-group; }
tr { break-inside: avoid; page-break-inside: avoid; }
th, td {
  border: 0.5pt solid #b6c2d1;
  padding: 0.9mm 1.6mm;
  vertical-align: top;
  text-align: left;
}
th { background: #e6edf6; color: #0f2f57; font-weight: 700; }
tbody tr:nth-child(even) td { background: #f8fafc; }
td code, th code { font-size: 0.85em; white-space: nowrap; }
td:first-child, th:first-child, th:nth-child(4), td:nth-child(4) { white-space: nowrap; }
"""

HTML = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<style>{css}</style>
</head>
<body>
{body}
</body>
</html>
"""


def md_to_html(text: str) -> tuple[str, str]:
    """Devuelve (título, cuerpo HTML). Las notas anteriores al primer '## ' van en <div class="meta">."""
    parts = re.split(r"(?m)^(?=## )", text, maxsplit=1)
    head, rest = (parts[0], parts[1]) if len(parts) == 2 else (text, "")
    exts = ["tables", "extra"]
    head_html = markdown.markdown(head, extensions=exts)
    rest_html = markdown.markdown(rest, extensions=exts) if rest else ""
    # El título (h1) queda fuera del recuadro de notas; el resto de la cabecera va en .meta
    m = re.match(r"\s*(<h1>.*?</h1>)(.*)", head_html, flags=re.S)
    if m:
        h1, notes = m.group(1), m.group(2)
        title = re.sub(r"<[^>]+>", "", h1)
        body = f'{h1}\n<div class="meta">{notes}</div>\n{rest_html}'
    else:
        title = "Narración"
        body = head_html + rest_html
    return title, body


def find_chromium(explicit: str | None) -> str:
    for cand in ([explicit] if explicit else []) + list(CHROMIUM_CANDIDATES):
        path = cand if Path(cand).is_file() else shutil.which(cand)
        if path:
            return path
    sys.exit("No encuentro Chromium/Chrome; pásalo con --chromium /ruta/al/binario")


def count_pages(pdf: Path) -> str:
    try:
        out = subprocess.run(["pdfinfo", str(pdf)], capture_output=True, text=True, check=True).stdout
        return re.search(r"Pages:\s+(\d+)", out).group(1)  # type: ignore[union-attr]
    except Exception:
        return str(len(re.findall(rb"/Type\s*/Page[^s]", pdf.read_bytes())))


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-i", "--input", type=Path, default=DEFAULT_MD, help="markdown de entrada")
    ap.add_argument("-o", "--output", type=Path, default=DEFAULT_PDF, help="PDF de salida")
    ap.add_argument("--chromium", help="ruta de Chromium/Chrome")
    ap.add_argument("--keep-html", action="store_true", help="deja el HTML intermedio junto al PDF")
    ap.add_argument("--no-sandbox", action="store_true", help="pasa --no-sandbox a Chromium (contenedores/root)")
    args = ap.parse_args()

    text = args.input.read_text(encoding="utf-8")
    title, body = md_to_html(text)
    html = HTML.format(title=escape(title), css=CSS, body=body)

    out = args.output.resolve()
    out.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="guion_pdf_") as tmp:
        html_path = Path(tmp) / "guion.html"
        html_path.write_text(html, encoding="utf-8")
        if args.keep_html:
            keep = out.with_suffix(".html")
            keep.write_text(html, encoding="utf-8")
            print(f"HTML: {keep}")
        cmd = [
            find_chromium(args.chromium),
            "--headless",
            "--disable-gpu",
            "--no-pdf-header-footer",
            f"--user-data-dir={Path(tmp) / 'profile'}",
            f"--print-to-pdf={out}",
        ]
        if args.no_sandbox:
            cmd.append("--no-sandbox")
        cmd.append(html_path.as_uri())
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        if res.returncode != 0 or not out.is_file():
            sys.exit(f"Chromium falló ({res.returncode}):\n{res.stderr[-1500:]}")
    print(f"PDF: {out} ({count_pages(out)} páginas, {out.stat().st_size / 1024:.0f} kB)")


if __name__ == "__main__":
    main()
