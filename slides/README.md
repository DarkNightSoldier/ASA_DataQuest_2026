# Diapositivas (`slides/`)

Deck **reveal.js 6.0.2** en HTML directo (sin Quarto) para el ASA International DataQuest 2026:
**portada + 4 diapositivas de contenido + referencias = 6 páginas en el PDF**. Sigue el storyboard
**v2.1** (`docs/00_storyboard_diapositivas.md`): builds como fragmentos, rótulo `Question N · P…`,
pie fijo PIE-0, barra de subtítulos, recuadros `Question N answered`, sin logos de la ONU.
Texto en pantalla en inglés; este README y los comentarios en español.

## 1. Archivos

| Ruta | Qué es |
|---|---|
| `index.html` | 6 `<section>` (cover, s1–s4, refs). Cada build = `fragment` con `data-fragment-index`, `data-build`, `data-step` (id del estado) y `data-caption` (subtítulo literal) |
| `css/theme.css` | Tema propio 1920×1080: Lato local (respaldo Noto Sans), variables de color (`--c-type-*`, `--c-births/…`, `--c-early/…`, `--c-high/upper/lower/low`, `--c-region-*`), márgenes 64 px, modo PDF |
| `js/numbers.js` | Carga cifras y rellena `[data-num]`, `[data-flags]`, `[data-list]`, `[data-iso]`; marca *unverified/missing* (solo fuera del PDF); tabla de alias |
| `js/figs.js` | Figuras con marcador gris si faltan (nombre, ruta esperada y tamaño de ranura); póster si falta el MP4 |
| `js/captions.js` | Subtítulos por fragmento, reproducción de `<video>` al mostrarse el fragmento, `window.slideTimings`, `window.deckSteps()` |
| `js/init.js` | Configuración de reveal (1920×1080, margin 0, `hash`, `fade`, `pdfSeparateFragments:false`, `pdfMaxPagesPerSlide:1`, sin controles ni progreso), pie/navegador comunes, clases `.ge-N` por build, contador de la portada |
| `js/numbers_data.js` | Copia de `figures/numbers.json` (`window.NUMBERS`) para abrir el deck con doble clic; **se versiona** y la regeneran `build_narration.py` y `video/export_pdf.sh` |
| `abrir.sh` | Abre el deck con un servidor local (`python3 -m http.server` en un puerto libre + `xdg-open`) |
| `js/iso_codes.js` | ISO3 → ISO2 (flag-icons) y nombres WPP; se regenera con `Rscript slides/dev/gen_iso_codes.R` |
| `script/fill_numbers.py` | Sustituye `{clave}` / `{clave.say}` / `{clave.campo}` en un markdown (guion); `--check-html`, `--emit-js` |
| `script/export_guion_pdf.py` | Guion de la voz en PDF A4 para leerlo al grabar (`script/narration_en.pdf`, 6 páginas; frases a 14 pt). Regenerar tras cada `build_narration.py`: `python slides/script/export_guion_pdf.py` (requiere `pip install markdown` y Chromium) |
| `dev/numbers_demo.json` (+ `.js`) | **10 claves inventadas, `"demo": true`**, solo para probar el render (muestra la cinta *Demo numbers · not real*) |
| `dev/screenshots.py` | Prueba visual: capturas de los 6 finales y de los 32 estados + `dev/figure_slots.json` + `dev/deck_report.json` |
| `dev/video_timings.template.json` | Plantilla de tiempos con las duraciones del storyboard v2.1 (4:50 + 3 s) |
| `export/slides.pdf` | PDF de entrega (6 páginas: portada, 4 diapositivas, Referencias), cifras reales verificadas; lo genera `video/export_pdf.sh` |
| `../video/record_slides.py`, `../video/export_pdf.sh` (`export_pdf.py`), `../video/deck_browser.py` | Grabación WebM, PDF, utilidades comunes |

## 2. Abrir el deck: dos modos

Antes, una vez: `cd slides && npm install` (reveal.js y flag-icons viven en `slides/node_modules/`, que no se versiona).

**a) Servidor local (recomendado):**

```bash
bash slides/abrir.sh            # puerto libre; PORT=8000 bash slides/abrir.sh para fijarlo
```

Sirve la **raíz del repositorio** con `python3 -m http.server` (para que `../figures/` y `../docs/equipo.json`
resuelvan desde `/slides/`), espera a que responda, abre `http://127.0.0.1:<puerto>/slides/index.html` con
`xdg-open` y deja el servidor encendido hasta Ctrl+C. En este modo se cargan `../figures/numbers.json`,
`script/video_timings.json` (subtítulos con los tiempos del vídeo) y `../docs/equipo.json`. A mano es lo mismo:
`cd RepoGithub && python3 -m http.server 8000` → `http://127.0.0.1:8000/slides/index.html`.

**b) Doble clic en `slides/index.html` (`file://`):** el navegador no deja leer JSON por `file://`, así que las
cifras salen de **`js/numbers_data.js`** (`window.NUMBERS`, copia exacta de `figures/numbers.json`). Ese archivo
**se versiona** (desde el 2026-10-26) y lo regeneran siempre `slides/script/build_narration.py` y
`video/export_pdf.sh` (función `emit_js` de `script/fill_numbers.py`; solo se reescribe si cambia). A mano:
`python slides/script/fill_numbers.py --emit-js slides/js/numbers_data.js`. Diferencias con a): los bloques de
subtítulo cambian cada 3,2 s (no se leen los tiempos del vídeo) y la línea del equipo de la portada y la URL de
Referencias usan el texto por defecto del HTML (idéntico a `docs/equipo.json`).

Comprobado el 2026-10-26 con Playwright (Chromium): en los dos modos **ningún `[data-num]` queda vacío** (138 de 138
con valor), `NUMBERS_REPORT.unfilledKeys` está vacío y no aparece la cinta DEMO (fuente: `../figures/numbers.json` por
http, `js/numbers_data.js` por `file://`). `abrir.sh` probado con un `xdg-open` de prueba: `/slides/index.html` y
`/figures/numbers.json` responden 200 y el servidor se apaga al salir.

Teclas: → / espacio (siguiente build), ← (anterior), `c` subtítulos on/off, `q` marcadores QA on/off,
`f` pantalla completa, `o`/`esc` vista general. Parámetros de URL: `?print-pdf` (versión PDF),
`?qa=off` (oculta marcadores), `?captions=off`, `?record=1` (sin cursor),
`?numbers=../figures/numbers_q1.json,../figures/numbers_q2.json` (vista previa con salidas parciales).

Orden de carga de cifras: `../figures/numbers.json` → `window.NUMBERS` (`js/numbers_data.js`) →
`dev/numbers_demo.json` (solo si fallan los anteriores; cinta DEMO visible también en el PDF).

## 3. Figuras: dónde van y qué tamaño tienen

- Estáticas: `figures/static/<nombre>.png`. Animadas: `figures/animated/<nombre>.mp4` (H.264, muted);
  su **póster = `figures/static/<nombre>.png` (último fotograma)**, que es lo que se imprime.
- Opcional para el PDF: `figures/static/<nombre>_print.png` (otra proporción); si existe, el PDF la usa.
- Superposiciones opcionales (se ocultan si faltan): `fig00_world_dots_below_replacement.png`,
  `fig00_world_dots_growing.png` (portada b2/b3, "los puntos se tiñen"),
  `fig02_lever_map_2023_momentum.png` (contorno de los países de inercia, S1 b3; PNG transparente del mismo encuadre que fig02).
- **Contrato con figures-static:** las figuras van **sin título ni subtítulo** (el titular-mensaje y
  todas las cifras están en HTML, desde `numbers.json`); sí llevan ejes, etiquetas directas, leyendas
  propias, línea 2023/24 y su badge PIE-x. Fondo blanco. Texto ≥ 18 px **a la ranura final**;
  exportar a 2× esa ranura para que los estados ampliados sigan nítidos. Colores: azul/celeste/naranja/púrpura
  de los tipos de palanca y Tol para los grupos (ver `css/theme.css`). Leyendas en HTML (no repetir en la figura):
  conteos y banderas de fig02 (S1), grupos de fig10 en el vídeo (en el PDF esa leyenda se oculta: la
  versión `fig10_…png`/`_print.png` debe llevar la etiqueta por panel del storyboard §5). `fig08` es HTML (no hace falta PNG).
- Ranuras medidas (px de diapositiva; `dev/figure_slots.json`, regenerar con `dev/screenshots.py`):

| Figura | Tipo | Paso | Ranura final vídeo | Ranura de entrada | PDF |
|---|---|---|---|---|---|
| fig00_world_dots | PNG fondo | cover | 1920×1080 | = | = |
| fig01_growth_components_by_income | MP4 (12.1 s) + PNG | s1.b2 | **721×390** | = | 721×225 |
| fig02_lever_map_2023 | PNG | s1.b3 | **1037×365** | = | 1037×290 |
| fig02b_lever_map_zoom | MP4 | s1.b5a | **1037×365** (el Golfo en la mitad superior: abajo entra la tarjeta EAU de 226 px) | = | — |
| fig03_uae_fan_2050 | PNG | s1.b5b | **441×204** | = | 560×150 |
| fig04_same_road_registration | MP4 (18.5 s) + PNG | s2.b1 | **774×183** = `_small.png` (fundido desde b2) | **1760×416** (héroe, = MP4 3520×832 / 2) | 774×243 (`_print.png`) |
| fig05_mortality_first_event_time | PNG | s2.b2 | **986×211** | = | 986×271 |
| fig06_within_vs_across_forest | PNG | s2.b3 | **1021×135** | = | 1021×183 |
| fig07_single_indicator_scorecard | MP4 (14.9 s) + PNG | s3.b1 | **572×282** (figura 572×263) | = | 572×487 (figura 572×395) |
| fig09_pca_two_dimensions | MP4 (9.2 s) + PNG | s3.b3 | **624×402** | = | 624×510 |
| fig10_trajectory_groups | MP4 (28.2 s) + PNG | s4.b1 | b2 1092×348; desde b3 **1021×220** = `_small.png` | **1792×571** (héroe, = MP4 2184×696) | 969×164 (`_print.png`) |
| fig11_divergence_fan | PNG | s4.b2 | **670×389** (b2); desde b3 **741×150** = `_small.png` | = | 793×160 (`_print.png`) |

## 4. Cifras (`figures/numbers.json`)

**Regla QA-stats (slides-fill, 2026-10-25):** `numbers.js` solo rellena claves con `"verified": true`; una clave
inexistente o no verificada deja el elemento **vacío** y va a `window.NUMBERS_REPORT.unfilledKeys` + consola
(`?unverified=show` solo para depurar). Redondeo **ROUND_HALF_UP** decimal (36.5 → 37), igual que `fill_numbers.py`.
Capas de fig02 (`_momentum`, `_ex_c/_d/_e`): `fade-in-then-out` en s1.b3b/b4a/b4b/b4c; en el PDF queda `_momentum_print`.
Vídeos: solo se reproduce el del build más reciente; con http.server (sin Range) "rebobinar" = `load()` (póster).

Cada clave: `{"value", "unit", "fmt", "say", "def", "verified", "sens_low", "sens_high", …}` (plan §4).
Formato (igual en `numbers.js` y `fill_numbers.py`): `fmt` "0"/"0.0"/"0.00" = decimales, "+0.00" = signo,
"#,##0" = miles; sin `fmt`: entero → 0, |x| < 1 → 2, si no 1; negativos con "−" (U+2212); listas →
"A, B and C" (ISO3 → nombre WPP). La unidad no se añade (el texto la lleva). `title` = `def` + método/IC.
Marcadores: `data-say` (frase hablada), `data-field` (otro campo), `data-item` (objeto/lista, p. ej.
`cluster_sizes["Early movers"]`, `rec_rows[0].road`), `data-sign="always"`, `data-cap`, `data-fmt`.
Banderas: `data-flags="clave"` usa `clave_iso3` o `clave_iso` si existen (salida del notebook).

**Alias** (HTML con nombres del storyboard v2.1; tabla única en `numbers.js`, la lee `fill_numbers.py`):
`n_ge1m`→`n_countries_1m`, `n_states`→`n_sovereign`, `n_twin_pairs`→`n_pairs_twins`;
`share_mig_high_sens_range`, `n_grow_only_migration_sens_range`, `pc1_var_sens_range` se derivan de
`sens_low–sens_high` de su clave base si no vienen como texto.

Claves que espera el HTML (107; lista exacta: `python slides/script/fill_numbers.py --check-html slides/index.html`).
Con las salidas parciales del notebook (`numbers_q1/q2/q3.json`) solo faltan: `are_revision_pct`,
`hyp_file_date`, `hyp_file_sha256_short`, `momentum_years_range`, `n_census_pre2009`, `n_states`,
`n_territories`, `repo`, `team_name` (estas dos últimas: texto, p. ej. desde `R/config.R`), además de
`world_pop_1950_bn` (contador de la portada; sin ella el contador no se anima) y `rec_rows[i].road`.

## 5. Subtítulos y tiempos

`data-caption` de cada fragmento (o de la `<section>` para el estado sin fragmentos) = texto literal de
la voz final (guion v3, 2026-10-25), copiado de `slides/script/data_captions.json`; `" | "` separa bloques
(≤ 90 caracteres). Las cifras van ya escritas (sin `{clave}`): el guion solo dice claves con
`verified: true` y `build_narration.py` las redondea con ROUND_HALF_UP. Si cambia el guion, se regenera con
`slides/script/build_narration.py` y se vuelve a copiar al HTML (nunca se edita el subtítulo a mano en el HTML).
`slides/script/video_timings.json` (lo genera `build_narration.py`; manda sobre el `data-caption` al grabar):

```json
{"steps": [{"id": "s1.b2", "duration": 14.0,
            "captions": [{"t": 0, "text": "In today's high-income countries, …"}, {"t": 5.2, "text": "…"}]}]}
```

Sin `captions`, los bloques se reparten por igual en `duration`; sin archivo, 3,2 s por bloque.
Comprobado el 2026-10-25 (agente captions-sync): 32 estados en el mismo orden en `window.deckSteps()`,
`video_timings.json` y `captions.json`; cada `data-caption` = unión de los bloques de `video_timings.json`;
cada paso con MP4 dura más que su vídeo (s1.b2 12.9 ≥ 12.6 s · s1.b5a 4.3 ≥ 4.0 · s2.b1 18.8 ≥ 16.4 ·
s3.b1 16.0 ≥ 14.9 · s3.b3 8.6 ≥ 7.7 · s4.b1 27.3 ≥ 26.4).
Guion v4 (corrector-final, 2026-10-26): s1.b2 12.9 ≥ 12.1 · s1.b5a 4.3 ≥ 4.0 · s2.b1 18.8 ≥ 18.5 · s3.b1 15.2 ≥ 14.9 ·
s3.b3 9.5 ≥ 9.2 · s4.b1 28.5 ≥ 28.2; total 292.2 s. Los MP4 de fig04 y fig10 se generan con la duración del paso − 0,3 s.
Los `id` son los `data-step` (32 estados: `cover.b1…b5`, `s1.b0…b5b`, `s2.b0…b4`, `s3.b0…b4`, `s4.b0…b5`, `refs`).

## 6. Grabar, exportar, probar

Venv con Playwright + pypdf: `export VENV=$PWD/.venv` (por defecto los scripts usan `.venv` en la raíz; en la máquina de desarrollo se usó otro venv, fuera del repositorio)
(Chromium del sistema `/usr/bin/chromium`; Playwright necesitó `playwright install ffmpeg` para grabar).

```bash
$VENV/bin/python video/record_slides.py            # WebM 1920×1080 en video/raw/ (+ _steps.json con tiempos reales)
$VENV/bin/python video/record_slides.py --timings slides/dev/video_timings.template.json --mp4
bash video/export_pdf.sh --png                     # slides/export/slides.pdf; falla si no son 6 páginas
$VENV/bin/python slides/dev/screenshots.py         # capturas + ranuras + informe
$VENV/bin/python slides/dev/check_sync.py          # subtítulos, orden de pasos y MP4 en tiempo real (~5 min)
```

`record_slides.py` se niega a grabar con cifras DEMO, sin valor o sin verificar (QA-stats bloquea la
grabación) salvo `--allow-demo --allow-unverified` (pruebas; oculta los marcadores). Sin timings: 4 s por estado.

## 7. Decisiones y desviaciones (documentadas)

- reveal.js instalado es **6.0.2** (el storyboard dice 5); referencias corregidas a "reveal.js 6".
- El *auto-animate* de reveal solo actúa entre diapositivas y el storyboard no pide ninguna pareja: las
  transformaciones dentro de una diapositiva (tarjetas que se encogen, figura héroe en S2 b1, tabla y ética
  en S4) son transiciones CSS por estado de build (`.ge-N`).
- PDF: las tarjetas de ética van en **versión mínima** (títulos + códigos ASA, permitida por
  `04_etica` §3.1 y storyboard §9); filas 1 y 3 de la tabla en versión corta (`.print-only`).
- Pie PIE-0 = texto del storyboard §8 + "countries only, no aggregates".
- Recuadros de respuesta de 3 líneas a 23 px (el storyboard pide 2 líneas a 28 px; el texto no cabe).
- Salvaguarda: si `say` ya empieza por "about" y el texto dice "about {x.say}", se elimina el duplicado
  (aviso en consola); lo correcto es `say = "seven in ten"` como define el storyboard.
- **Etiquetas de técnica (rc2, 2026-10-27; petición del usuario):** `<span class="mtag"><span class="mk">Methods</span><b>Nombre</b> · glosa</span>`.
  Nombre en negrita y tinta, glosa llana de 7 palabras como máximo, letra ≥ 18 px, sin alto extra: en la fila del chip
  "Question N" (S1, S4) o en línea al principio del titular de cada figura (S2, S3, fig11; `white-space: nowrap`).
  "Methods at a glance" (`.cover-methods`, `.glance`) en la portada y en s1.b0. Mismos nombres que la tabla del README
  y los títulos de sección del notebook (`TECNICAS` en `notebook/construir_notebook.py`). Detalle: `docs/correcciones.md` J-19.
- Contacto en Referencias: `data-team="contact_email"` (Team Leader, correo institucional; `docs/equipo.json`).
