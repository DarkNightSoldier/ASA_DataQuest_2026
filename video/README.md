# Vídeo del equipo UNALSta-R (ASA DataQuest 2026)

**▶ Vídeo publicado (5 min): <https://www.youtube.com/watch?v=Mh-TSMhnjDs>** (YouTube, «UNALSta-R Group 1 UNAL Bogota ASA DataQuest»; publicado el 2026-10-30).

Vídeo de entrega: **≤ 5:00**, 1920×1080, en inglés, con la voz del equipo sobre el deck de
`slides/index.html`. Se produce en tres pasos:

1. **Vídeo mudo** del deck (`video/deck_silent.mp4`): lo graba un navegador automático con los tiempos
   de `slides/script/video_timings.json` (292,2 s = 4:52,2; 32 pasos; subtítulos ya incrustados).
2. **Voz**: una persona del equipo lee `slides/script/narration_en.md` con el vídeo mudo delante y graba
   un WAV a 48 kHz.
3. **Ensamblaje**: `video/assemble.sh` une vídeo y voz y exporta `video/final/UNALSta-R_DataQuest2026.mp4`,
   comprobando que dura ≤ 300 s.

Si la grabación automática no funciona en un equipo, hay una **alternativa manual** (OBS) al final.

## Archivos

| Archivo | Qué es |
|---|---|
| `record_slides.py` | Graba el deck con Playwright + Chromium → `video/raw/slides_<fecha>.webm` (+ `_steps.json` con el instante real de cada paso) y, con `--mp4`, `video/deck_silent.mp4` |
| `deck_browser.py` | Utilidades comunes: servidor local de la raíz del repo, Chromium, espera a `window.deckReady` |
| `assemble.sh` | Une `deck_silent.mp4` + voz → MP4 final; normaliza la voz (−16 LUFS) y comprueba la duración |
| `export_pdf.sh`, `export_pdf.py` | PDF de 6 páginas (`slides/export/slides.pdf`); no forman parte del vídeo |
| `raw/` | Grabaciones WebM sin recortar (no se versionan) |
| `deck_silent.mp4` | Vídeo mudo H.264 1920×1080 30 fps (≈ 70 MB; no se versiona: se regenera con el paso 1) |
| `final/` | MP4 de entrega (no se versiona) |

Fuentes de verdad: `slides/script/narration_en.md` (guion, generado; no se edita a mano),
`slides/script/video_timings.json` (duración y bloques de subtítulo de cada paso),
`slides/script/captions.srt` (los mismos subtítulos, en SRT). Las tres se regeneran juntas con
`slides/script/build_narration.py` a partir de `slides/script/narration_en_template.md`.

Guion para leer al grabar, en PDF A4 (`slides/script/narration_en.pdf`): se regenera con
`python slides/script/export_guion_pdf.py` (requiere `pip install markdown` y Chromium) cada vez que cambie `narration_en.md`.

## 0. Requisitos (una vez)

- Python ≥ 3.10 y Chromium (`/usr/bin/chromium`; Playwright usa el suyo si está instalado).
- Un entorno virtual con Playwright e imageio-ffmpeg (trae su propio `ffmpeg`; no hace falta `ffprobe`):

```bash
cd RepoGithub
python3 -m venv .venv
.venv/bin/pip install playwright imageio-ffmpeg pypdf
.venv/bin/playwright install ffmpeg        # códec con el que Playwright graba el WebM
export VENV=$PWD/.venv                      # assemble.sh y export_pdf.sh leen esta variable
```

Si no se define `VENV`, `export_pdf.sh` y `assemble.sh` usan `.venv` en la raíz del repositorio (en la máquina donde se
preparó el deck se usó otro venv, fuera del repositorio: basta con `export VENV=...`). Las figuras R buscan el ffmpeg de
`imageio-ffmpeg` dentro de `$VENV`, o el de la variable `FFMPEG`, o el del sistema.

## 1. Vídeo mudo (`deck_silent.mp4`)

```bash
$VENV/bin/python video/record_slides.py --mp4      # ≈ 5 min de grabación + ≈ 2 min de conversión
```

Qué hace (detalles en la cabecera del script):

- Sirve la raíz del repo en `127.0.0.1:<puerto libre>` y abre `slides/index.html?record=1` (sin cursor)
  en Chromium headless a 1920×1080.
- **Se niega a grabar** si `figures/numbers.json` tiene claves sin verificar o sin valor (regla de
  QA-stats: solo se dice o se muestra lo que tiene `"verified": true`).
- Recorre los 32 pasos con las duraciones de `video_timings.json` (reloj absoluto, sin deriva), y la
  página reparte los bloques de subtítulo con los mismos tiempos.
- Antes del primer paso pinta un **destello magenta de sincronía** (queda en el tramo que se recorta).
  El vídeo de Playwright empieza ≈ 0,34 s después de lo que marca el reloj de Python; el destello
  permite medir ese retraso en el propio WebM y recortar exacto (error ≤ 1 fotograma).
- Relanza el **contador de la portada** (2.5 → 8.1 billion, 1950 → 2023) justo en el segundo 0, como pide
  el storyboard (sin esto el vídeo empezaba a mitad de cuenta).
- Convierte a `video/deck_silent.mp4`: H.264 (High, CRF 16), 1920×1080, 30 fps constantes, sin audio,
  recortado al primer paso y a la duración del deck.

Para convertir otra vez una grabación ya hecha (sin volver a grabar):
`$VENV/bin/python video/record_slides.py --convert video/raw/slides_<fecha>.webm`.

**Comprobaciones** (ya hechas el 2026-10-26 con la grabación `video/raw/slides_20261026_113220.webm`;
repítalas si se regenera el guion o el deck):

```bash
FF=$($VENV/bin/python -c 'import imageio_ffmpeg; print(imageio_ffmpeg.get_ffmpeg_exe())')
$FF -hide_banner -i video/deck_silent.mp4 2>&1 | grep -E 'Duration|Video:'   # 00:04:52.20 · h264 · 1920x1080 · 30 fps
python3 -c "import json; print(sum(s['duration'] for s in json.load(open('slides/script/video_timings.json'))['steps']))"   # 292.2
```

La duración del MP4 debe coincidir con la suma de `video_timings.json` (± 2 s) y no pasar de 300 s.
Mire además unos fotogramas (portada, el arranque de cada MP4 embebido —fig01, fig02b, fig04, fig07,
fig09, fig10— y Referencias): los gráficos animados deben moverse, no quedarse en el póster, y el
subtítulo debe cambiar dentro de cada paso.

## 2. Grabar la voz

**Antes de grabar**

- Pendientes de `docs/correcciones.md` que afectan a la voz: **P-01** ✅ (hecho el 2026-10-26 a las 11:23:
  los cuatro integrantes comprobaron a mano las cifras habladas y en pantalla; si una cifra cambia después,
  hay que volver a comprobarla), **P-03** (lectura cronometrada: el guion cabe en 4:52 a 150 palabras por
  minuto; a 140 ppm se pasaría de 5:00 → recortes en el orden que da P-03) y **P-05** ✅ (hecho, informado
  el 2026-10-26 a las 12:10: consentimiento escrito de los cuatro integrantes para publicar sus nombres; las
  voces son de integrantes del equipo, **ninguna sintética**, y así lo dicen las Referencias: "not the voices
  (team members narrate; no synthetic voice)". Si al final se usara una voz sintética, habría que cambiar
  esa frase, decirlo en el vídeo y volver a exportar el PDF).
- La voz debe decir **exactamente** el guion: los subtítulos incrustados son ese texto. Cualquier cambio
  se hace en `slides/script/narration_en_template.md` → `build_narration.py` → paso 1 otra vez.
  No improvise cifras: solo las del guion (todas verificadas).
- Pronunciación: "UNALSta-R" = *u-nal-sta-ar*. Deje ≈ 1,5 s de aire después de cada cifra (la tabla de
  `narration_en.md` marca cuántas hay en cada paso).

**Formato**: WAV PCM **48 kHz**, 24 bits (o 16), mono. Habitación callada, micrófono a un palmo, picos
por debajo de −3 dBFS (sin saturar). Sin música. `assemble.sh` normaliza el volumen; no hace falta
compresor ni ecualizador.

**Cómo leer con el vídeo delante** (una sola toma continua es lo más fácil de sincronizar):

1. Abra `video/deck_silent.mp4` en un reproductor (VLC, mpv) a pantalla completa, **sin sonido**.
2. Abra el grabador (Audacity: *Proyecto a 48000 Hz*, entrada mono) y pulse **Grabar**.
3. Pulse **Play** en el vídeo. Lea cada frase **cuando aparezca su subtítulo**: el subtítulo es la
   señal de entrada (cada bloque aparece en el instante en que debe empezar esa frase). Si una frase
   termina antes de que cambie el subtítulo, espere; si va tarde, no corra: siga y anote el paso.
4. Al terminar el vídeo, detenga la grabación.
5. En Audacity, **recorte el silencio inicial** para que la primera palabra ("Eight billion people.")
   empiece a ≈ 0,2 s del inicio del archivo, y recorte el silencio del final. Exporte
   `Archivo → Exportar → WAV (Microsoft) 48 kHz` como `video/voz.wav`.

Si una parte sale mal, regrabe **la diapositiva entera** (los inicios de cada paso están en la tabla
"Tiempos por paso" de `narration_en.md`, p. ej. Slide 2 = 1:41.3) y péguela en Audacity en ese mismo
instante; no estire ni comprima la voz.

Con `arecord` (Linux), en lugar de Audacity: `arecord -f S24_LE -r 48000 -c 1 video/voz.wav`
(Ctrl+C para parar) y recorte después con Audacity.

## 3. Ensamblar el MP4 final

```bash
bash video/assemble.sh video/voz.wav                  # → video/final/UNALSta-R_DataQuest2026.mp4
bash video/assemble.sh video/voz.wav --offset 0.25    # la voz entra 0,25 s más tarde (negativo = antes)
bash video/assemble.sh video/voz.wav --srt            # además, subtítulos "soft" en inglés (captions.srt)
```

- Copia el vídeo sin recomprimir; la voz pasa a AAC 48 kHz 192 kb/s estéreo, normalizada a −16 LUFS
  (pico ≤ −1,5 dBTP), y se rellena con silencio hasta el final del vídeo.
- **Falla** (código ≠ 0) si la voz dura más que el vídeo (se perdería la última frase), si el resultado
  pasa de **300 s** o si le falta la pista de vídeo o de audio.
- `--srt` no hace falta para el concurso (los subtítulos ya están incrustados); sirve si una plataforma
  pide pista de subtítulos aparte.
- Usa el `ffmpeg` de imageio-ffmpeg del venv (o el del sistema); mide con `ffprobe` si existe y, si no,
  con la cabecera de `ffmpeg -i`.

**Revise el final de principio a fin** con sonido: la voz debe ir con su subtítulo (si todo va igual de
adelantado o atrasado, corrija con `--offset`), sin cortes al final, volumen parejo entre diapositivas.

## 4. Alternativa: grabación manual de pantalla (OBS)

Si Playwright no funciona, o si el equipo prefiere grabar voz e imagen a la vez:

1. Sirva la **raíz del repositorio** (no `slides/`, para que `../figures` resuelva):
   `cd RepoGithub && python3 -m http.server 8000`
2. Abra `http://127.0.0.1:8000/slides/index.html?record=1` en Chromium/Chrome a pantalla completa (F11)
   en una pantalla de 1920×1080 (o con zoom que deje el deck a 1920×1080). Compruebe que no salen
   marcadores rojos de QA (si salen, hay cifras sin verificar: no grabe).
3. OBS Studio: *Ajustes → Vídeo* 1920×1080 base y salida, 30 fps; *Audio* 48 kHz; *Salida* MP4
   (o MKV y luego *Remux a MP4*), H.264, CRF/calidad ≈ 18–20, AAC 192 kb/s. Fuente "Captura de ventana"
   del navegador + micrófono.
4. Grabe leyendo el guion y avanzando con **→** o **espacio** al terminar cada paso (los subtítulos de cada
   paso se reparten con los tiempos de `video_timings.json`; los MP4 embebidos arrancan solos al
   mostrarse su paso). Teclas: `c` subtítulos sí/no, `q` marcadores QA.
5. Recorte el principio y el final en OBS/Shotcut, compruebe la duración (≤ 5:00) y, si el volumen sale
   bajo, normalícelo:
   `$FF -i grabacion.mp4 -c:v copy -af loudnorm=I=-16:TP=-1.5:LRA=11 -c:a aac -b:a 192k -ar 48000 video/final/UNALSta-R_DataQuest2026.mp4`

La grabación manual depende de la mano de quien avanza: respete las duraciones de la tabla de
`narration_en.md` para no pasar de 5:00.

## 5. Antes de subir

- [ ] `video/final/UNALSta-R_DataQuest2026.mp4` dura ≤ 5:00 (lo comprueba `assemble.sh`), 1920×1080.
- [ ] Voz y subtítulos dicen lo mismo; ninguna cifra fuera del guion.
- [x] P-01 firmado (cifras habladas y en pantalla, 2026-10-26 11:23; `docs/QA_stats.md` §10).
- [x] P-02: https://github.com/DarkNightSoldier/ASA_DataQuest_2026 público (2026-10-30 17:05, UTC−5; Referencias da esa URL),
      con `LICENSE` y `LICENSE-texts`; vídeo en https://www.youtube.com/watch?v=Mh-TSMhnjDs.
- [x] P-05: consentimiento escrito de los cuatro (nombres); voces de los integrantes, ninguna sintética (2026-10-26).
- [ ] El PDF (`slides/export/slides.pdf`, 6 páginas) es del mismo estado del deck que el vídeo.

## Notas técnicas

- Playwright captura a 25 fps; la conversión a 30 fps repite un fotograma de cada cinco (no se nota en
  diapositivas; las animaciones conservan su duración).
- El servidor de `deck_browser.py` (http.server) no admite peticiones *Range*: Chromium no puede saltar
  dentro de los MP4 embebidos y `js/captions.js` los rebobina con `load()`. Cada MP4 se reproduce
  desde el principio al mostrarse su paso; los pasos duran al menos lo que su MP4 + 0,3 s.
- Comprobación hecha el 2026-10-26 sobre `deck_silent.mp4` (292,20 s = 8 766 fotogramas a 30 fps, igual
  a la suma de `video_timings.json`): los cambios de paso caen a ≤ 0,07 s de lo previsto; los seis MP4
  embebidos (fig01, fig02b, fig04, fig07, fig09, fig10) se mueven durante su paso y arrancan desde su
  primer fotograma, no desde el póster; los subtítulos cambian dentro de cada paso y caben en una línea;
  nada queda cortado en los fotogramas revisados. `assemble.sh` se probó con una voz de prueba
  (desfase +0,25 s → la voz entra a 0,250 s; −16,0 LUFS integrados; voz más larga que el vídeo → error 4).
