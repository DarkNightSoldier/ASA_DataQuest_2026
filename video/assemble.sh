#!/usr/bin/env bash
# =============================================================================
# assemble.sh — une el vídeo mudo del deck con la voz grabada y exporta el MP4 final.
#
#   bash video/assemble.sh                         # video/deck_silent.mp4 + video/voz.wav
#   bash video/assemble.sh ruta/voz.wav            # otra pista de voz
#   bash video/assemble.sh voz.wav --offset 0.25   # retrasa la voz 0,25 s (negativo = la adelanta)
#   bash video/assemble.sh voz.wav --srt           # añade además subtítulos "soft" (captions.srt)
#   bash video/assemble.sh voz.wav --no-norm       # sin normalizar el volumen (loudnorm)
#
# Entrada : video/deck_silent.mp4 (H.264 1920×1080 30 fps, sin audio; lo crea el paso de
#           grabación, ver video/README.md) y una voz WAV (ideal 48 kHz, mono o estéreo).
# Salida  : video/final/UNALSta-R_DataQuest2026.mp4 (H.264 copiado sin recomprimir + AAC 48 kHz
#           192 kb/s, normalizado a −16 LUFS, pico ≤ −1,5 dBTP).
# Comprueba: que la voz no dure más que el vídeo (si no, se cortaría el final), que el resultado
#           dura ≤ 300 s (regla del concurso: vídeo ≤ 5:00) y que tiene una pista de vídeo y otra
#           de audio. Sale con código ≠ 0 si algo falla.
# ffmpeg  : el de imageio-ffmpeg del venv (no hace falta ffmpeg del sistema). Si hay ffprobe en
#           el PATH se usa para medir; si no, se lee la duración de la cabecera con ffmpeg -i.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${VENV:-$REPO/.venv}"   # venv del proyecto (README, paso 0); se puede cambiar con export VENV=...
PY="${PYTHON:-$VENV/bin/python}"
[ -x "$PY" ] || PY="$(command -v python3)"

LIMIT_S=300
DECK="${DECK:-$REPO/video/deck_silent.mp4}"
OUT="${OUT:-$REPO/video/final/UNALSta-R_DataQuest2026.mp4}"
SRT="$REPO/slides/script/captions.srt"

VOICE=""
OFFSET="0"
ADD_SRT=0
NORM=1
while [ $# -gt 0 ]; do
  case "$1" in
    --offset) OFFSET="$2"; shift 2 ;;
    --srt) ADD_SRT=1; shift ;;
    --no-norm) NORM=0; shift ;;
    -h|--help) sed -n '2,22p' "$0"; exit 0 ;;
    -*) echo "[assemble] opción desconocida: $1" >&2; exit 2 ;;
    *) VOICE="$1"; shift ;;
  esac
done
VOICE="${VOICE:-$REPO/video/voz.wav}"

# ---- ffmpeg del venv (imageio-ffmpeg) o, si no, el del sistema ----
FF="$("$PY" -c 'import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())' 2>/dev/null || true)"
[ -n "$FF" ] && [ -x "$FF" ] || FF="$(command -v ffmpeg || true)"
if [ -z "$FF" ]; then
  echo "[assemble] no encuentro ffmpeg: instale imageio-ffmpeg en el venv ($PY -m pip install imageio-ffmpeg)" >&2
  exit 2
fi

# ---- duración en segundos (ffprobe si existe; si no, cabecera de ffmpeg -i) ----
duration() {
  if command -v ffprobe >/dev/null 2>&1; then
    ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$1"
  else
    # ffmpeg -i sin salida termina con código 1 aunque imprime la cabecera: no debe parar el script
    { "$FF" -hide_banner -i "$1" 2>&1 || true; } | sed -n 's/.*Duration: \([0-9:.]*\).*/\1/p' | head -1 |
      awk -F: '{ printf "%.3f\n", $1*3600 + $2*60 + $3 }'
  fi
}
info() { { "$FF" -hide_banner -i "$1" 2>&1 || true; } | grep -E 'Stream #' || true; }

[ -f "$DECK" ]  || { echo "[assemble] falta el vídeo mudo: $DECK (ver video/README.md, paso 1)" >&2; exit 2; }
[ -f "$VOICE" ] || { echo "[assemble] falta la voz: $VOICE (ver video/README.md, paso 2)" >&2; exit 2; }

D_DECK="$(duration "$DECK")"
D_VOICE="$(duration "$VOICE")"
echo "[assemble] vídeo mudo: $DECK · ${D_DECK} s"
echo "[assemble] voz       : $VOICE · ${D_VOICE} s · desfase ${OFFSET} s"
if ! info "$VOICE" | grep -q '48000 Hz'; then
  echo "[assemble] AVISO: la voz no está a 48 kHz; se remuestrea a 48 kHz (mejor grabar a 48 kHz)." >&2
fi

# La voz (más el desfase) no puede pasar del final del vídeo: se perdería la última frase.
if awk -v v="$D_VOICE" -v o="$OFFSET" -v d="$D_DECK" 'BEGIN { exit !(v + o > d + 0.05) }'; then
  echo "[assemble] ERROR: la voz (${D_VOICE} s + ${OFFSET} s) dura más que el vídeo (${D_DECK} s)." >&2
  echo "           Recorte silencios al final de la voz o vuelva a leer el paso que se alarga (README §2)." >&2
  exit 4
fi
if awk -v d="$D_DECK" -v l="$LIMIT_S" 'BEGIN { exit !(d > l) }'; then
  echo "[assemble] ERROR: el vídeo mudo ya dura ${D_DECK} s > ${LIMIT_S} s." >&2
  exit 4
fi

# ---- filtro de audio: desfase → 48 kHz estéreo → loudnorm → relleno de silencio hasta el final ----
AF=""
if awk -v o="$OFFSET" 'BEGIN { exit !(o > 0) }'; then
  MS="$(awk -v o="$OFFSET" 'BEGIN { printf "%d", o * 1000 }')"
  AF="adelay=${MS}:all=1,"
elif awk -v o="$OFFSET" 'BEGIN { exit !(o < 0) }'; then
  AF="atrim=start=$(awk -v o="$OFFSET" 'BEGIN { printf "%.3f", -o }'),asetpts=PTS-STARTPTS,"
fi
AF="${AF}aresample=48000,aformat=sample_fmts=fltp:channel_layouts=stereo"
[ "$NORM" = 1 ] && AF="${AF},loudnorm=I=-16:TP=-1.5:LRA=11"
AF="${AF},apad"

mkdir -p "$(dirname "$OUT")"
ARGS=(-hide_banner -loglevel error -y -i "$DECK" -i "$VOICE")
MAPS=(-map 0:v:0 -map 1:a:0)
CODECS=(-c:v copy -af "$AF" -c:a aac -b:a 192k -ar 48000)
if [ "$ADD_SRT" = 1 ] && [ -f "$SRT" ]; then
  ARGS+=(-i "$SRT")
  MAPS+=(-map 2:s:0)
  CODECS+=(-c:s mov_text -metadata:s:s:0 language=eng)
fi
# -t = duración exacta del vídeo mudo (apad rellena la voz con silencio hasta ahí)
"$FF" "${ARGS[@]}" "${MAPS[@]}" "${CODECS[@]}" -t "$D_DECK" \
  -metadata title="UNALSta-R · ASA DataQuest 2026" -movflags +faststart "$OUT"

D_OUT="$(duration "$OUT")"
echo "[assemble] final     : $OUT · ${D_OUT} s"
info "$OUT" | sed 's/^/             /'
STREAMS="$(info "$OUT")"
echo "$STREAMS" | grep -q 'Video: h264' || { echo "[assemble] ERROR: el final no tiene vídeo H.264" >&2; exit 5; }
echo "$STREAMS" | grep -q 'Audio: aac'  || { echo "[assemble] ERROR: el final no tiene audio AAC" >&2; exit 5; }
if awk -v d="$D_OUT" -v l="$LIMIT_S" 'BEGIN { exit !(d > l) }'; then
  echo "[assemble] ERROR: el final dura ${D_OUT} s > ${LIMIT_S} s (máximo 5:00)." >&2
  exit 4
fi
echo "[assemble] OK: ${D_OUT} s ≤ ${LIMIT_S} s. Revise el resultado de principio a fin antes de subirlo."
