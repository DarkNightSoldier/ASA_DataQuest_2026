#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
exportar_html.py — exporta notebook/analisis_wpp2024.ipynb (ya ejecutado) a
notebook/analisis_wpp2024.html y pone texto alternativo a cada figura.

Uso (python del venv de Jupyter del proyecto, desde cualquier carpeta):
    <venv-jupyter>/bin/python -I notebook/exportar_html.py

Por qué existe (accesibilidad): `jupyter nbconvert --to html` deja las
imágenes sin texto alternativo ("No description has been provided for this
image"). Cada figura del notebook va precedida por su pie
"**`figures/review/qN/<nombre>.png`** (figura de revisión, no final)", que
escribe mostrar_figuras(); aquí se usa ese pie como texto alternativo, para
que un lector de pantalla diga qué figura es y dónde está el PNG original.
El contenido del notebook no se toca: solo cambia el atributo alt del HTML.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

import nbformat
from bs4 import BeautifulSoup
from nbconvert import HTMLExporter

REPO = Path(__file__).resolve().parents[1]
ENTRADA = REPO / "notebook" / "analisis_wpp2024.ipynb"
SALIDA = REPO / "notebook" / "analisis_wpp2024.html"
SIN_ALT = "No description has been provided for this image"
RE_PIE = re.compile(r"figures/review/(q[123])/([A-Za-z0-9_]+)\.png")


def main() -> int:
    nb = nbformat.read(str(ENTRADA), as_version=4)
    # Título de la pestaña del navegador (solo en memoria; el .ipynb no cambia).
    nb.metadata["title"] = "One Number Can't Tell 8 Billion Stories · analysis notebook (WPP 2024)"
    html, _ = HTMLExporter(template_name="lab").from_notebook_node(
        nb, resources={"metadata": {"name": ENTRADA.stem}})
    sopa = BeautifulSoup(html, features="html.parser")
    pie_actual = None
    con_alt = sin_pie = 0
    # Recorre, en orden de documento, los pies (salidas markdown) y las imágenes.
    for elem in sopa.find_all(["div", "img"]):
        if elem.name == "div" and "jp-RenderedMarkdown" in (elem.get("class") or []):
            m = RE_PIE.search(elem.get_text())
            if m:
                pie_actual = m
            continue
        if elem.name == "img" and elem.get("alt") in (None, SIN_ALT):
            if pie_actual is None:
                sin_pie += 1
                continue
            carpeta, nombre = pie_actual.group(1), pie_actual.group(2)
            elem["alt"] = (f"Review figure {nombre.replace('_', ' ')} "
                           f"(original PNG: figures/review/{carpeta}/{nombre}.png; not a final figure)")
            con_alt += 1
            pie_actual = None  # cada pie describe una sola imagen
    SALIDA.write_text(str(sopa), encoding="utf-8")
    print(f"Escrito {SALIDA}: {con_alt} imágenes con texto alternativo; {sin_pie} sin pie reconocible.")
    return 0 if sin_pie == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
