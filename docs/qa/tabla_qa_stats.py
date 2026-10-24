#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
docs/qa/tabla_qa_stats.py — tabla clave por clave de docs/QA_stats.md (agente QA-stats)

Uso (desde cualquier carpeta):
    python3 docs/qa/tabla_qa_stats.py            # reescribe la tabla dentro de docs/QA_stats.md
    python3 docs/qa/tabla_qa_stats.py --stdout   # solo la imprime

Lee docs/qa/verificacion_consolidada.csv (decisión de QA-stats por clave) y
figures/numbers.json (estado final: verified / verified_by / nota_qa) y escribe
la tabla entre los marcadores <!-- TABLA-QA-INICIO --> y <!-- TABLA-QA-FIN -->.
Así la tabla nunca se teclea a mano y siempre refleja el numbers.json vigente.
"""
from __future__ import annotations

import csv
import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
CSV = REPO / "docs" / "qa" / "verificacion_consolidada.csv"
NUMBERS = REPO / "figures" / "numbers.json"
DOC = REPO / "docs" / "QA_stats.md"
INI, FIN = "<!-- TABLA-QA-INICIO -->", "<!-- TABLA-QA-FIN -->"


def celda(txt: str, maximo: int = 140) -> str:
    t = " ".join(str(txt).split()).replace("|", "\\|")
    return t if len(t) <= maximo else t[: maximo - 1] + "…"


def tabla() -> str:
    num = json.loads(NUMBERS.read_text(encoding="utf-8"))
    filas = list(csv.DictReader(CSV.open(encoding="utf-8")))
    out = ["| # | clave | lote | valor (numbers.json) | valor independiente | coincide | verified | acción |",
           "|---|---|---|---|---|---|---|---|"]
    for i, f in enumerate(filas, 1):
        e = num.get(f["clave"], {})
        ver = e.get("verified") is True
        coincide = "sí" if f["coincide"] == "TRUE" else "**no**"
        if f["clave"] == "are_revision_pct":
            coincide = "sí (parcial)"
        if f["definicion_clara"] != "TRUE":
            coincide += " · def ambigua"
        out.append("| {} | `{}` | {} | {} | {} | {} | {} | {} |".format(
            i, f["clave"], f["lote"], celda(f["valor_notebook"]), celda(f["valor_independiente"]),
            coincide, "✔" if ver else "**✘**", celda(f["accion"], 220)))
    return "\n".join(out)


def main() -> None:
    t = tabla()
    if "--stdout" in sys.argv:
        print(t)
        return
    doc = DOC.read_text(encoding="utf-8")
    if INI not in doc or FIN not in doc:
        sys.exit(f"Faltan los marcadores {INI} / {FIN} en {DOC}")
    a, resto = doc.split(INI, 1)
    _, b = resto.split(FIN, 1)
    DOC.write_text(f"{a}{INI}\n{t}\n{FIN}{b}", encoding="utf-8")
    print(f"Tabla escrita en {DOC} ({t.count(chr(10)) - 1} filas)")


if __name__ == "__main__":
    main()
