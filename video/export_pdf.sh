#!/usr/bin/env bash
# Exporta las diapositivas a slides/export/slides.pdf y comprueba que tiene 6 páginas.
#   bash video/export_pdf.sh            # Playwright (espera a 'pdf-ready'); respaldo automático a chromium CLI
#   bash video/export_pdf.sh --cli      # forzar chromium --headless --print-to-pdf
#   bash video/export_pdf.sh --png      # además, PNG de cada página en slides/export/pages/
# Requisitos: venv con playwright + pypdf (ver SETUP.md); /usr/bin/chromium.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${VENV:-$REPO/.venv}"   # venv del proyecto (README, paso 0); se puede cambiar con export VENV=...
PY="${PYTHON:-$VENV/bin/python}"
[ -x "$PY" ] || PY="$(command -v python3)"

"$PY" -c "import pypdf" 2>/dev/null || "$PY" -m pip install -q pypdf
# Copia de figures/numbers.json para abrir el deck con doble clic (file://); se versiona y se
# regenera siempre aquí y en slides/script/build_narration.py (solo se reescribe si cambia).
"$PY" "$REPO/slides/script/fill_numbers.py" --emit-js "$REPO/slides/js/numbers_data.js"
"$PY" "$REPO/video/export_pdf.py" "$@"

# Comprobación independiente del número de páginas (pypdf del venv)
"$PY" -c "
import sys
from pypdf import PdfReader
n = len(PdfReader('$REPO/slides/export/slides.pdf').pages)
print('páginas:', n)
sys.exit(0 if n == 6 else 1)
"
