#!/usr/bin/env bash
# abrir.sh — abre el deck en el navegador con un servidor local (modo recomendado).
#
#   bash slides/abrir.sh            # puerto libre elegido al azar
#   PORT=8000 bash slides/abrir.sh  # puerto fijo
#
# Qué hace: sirve la RAÍZ del repositorio con `python3 -m http.server` (así
# ../figures/ y ../docs/equipo.json resuelven desde /slides/), espera a que
# responda, abre http://127.0.0.1:<puerto>/slides/index.html con xdg-open y
# deja el servidor encendido hasta Ctrl+C.
#
# El otro modo (doble clic en slides/index.html, file://) también muestra todas
# las cifras gracias a slides/js/numbers_data.js; este modo, además, carga
# slides/script/video_timings.json (subtítulos con los tiempos del vídeo) y
# docs/equipo.json. Requisitos: python3 y `npm install` hecho en slides/
# (reveal.js vive en slides/node_modules/, que no se versiona).
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -f "$REPO/slides/node_modules/reveal.js/dist/reveal.js" ]; then
  echo "[abrir] falta slides/node_modules/reveal.js: ejecute primero (cd slides && npm install)" >&2
  exit 1
fi

PORT="${PORT:-$(python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()')}"
URL="http://127.0.0.1:${PORT}/slides/index.html"

python3 -m http.server "$PORT" --bind 127.0.0.1 --directory "$REPO" >/dev/null 2>&1 &
SRV=$!
trap 'kill "$SRV" 2>/dev/null || true' EXIT INT TERM

# espera (≤ 5 s) a que el servidor responda
for _ in $(seq 1 50); do
  if python3 -c "import sys, urllib.request; urllib.request.urlopen(sys.argv[1], timeout=0.5)" "$URL" 2>/dev/null; then
    break
  fi
  if ! kill -0 "$SRV" 2>/dev/null; then
    echo "[abrir] el servidor no arrancó (¿puerto $PORT ocupado?)" >&2
    exit 1
  fi
  sleep 0.1
done

echo "[abrir] deck en $URL  (Ctrl+C para cerrar el servidor)"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$URL" >/dev/null 2>&1 || echo "[abrir] xdg-open falló: abra la URL a mano"
else
  echo "[abrir] sin xdg-open: abra la URL a mano"
fi
wait "$SRV"
