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
| `js/iso_codes.js` | ISO3 → ISO2 (flag-icons) y nombres WPP; se regenera con `Rscript slides/dev/gen_iso_codes.R` |
| `script/fill_numbers.py` | Sustituye `{clave}` / `{clave.say}` / `{clave.campo}` en un markdown (guion); `--check-html`, `--emit-js` |
| `dev/numbers_demo.json` (+ `.js`) | **10 claves inventadas, `"demo": true`**, solo para probar el render (muestra la cinta *Demo numbers · not real*) |
| `dev/screenshots.py` | Prueba visual: capturas de los 6 finales y de los 32 estados + `dev/figure_slots.json` + `dev/deck_report.json` |
| `dev/video_timings.template.json` | Plantilla de tiempos con las duraciones del storyboard v2.1 (4:50 + 3 s) |
| `export/slides.pdf` | PDF generado (ahora: versión de prueba con marcadores y cifras DEMO) |
| `../video/record_slides.py`, `../video/export_pdf.sh` (`export_pdf.py`), `../video/deck_browser.py` | Grabación WebM, PDF, utilidades comunes |

## 2. Servir y navegar

Siempre desde la **raíz del repositorio** (para que `../figures/` resuelva desde `/slides/`):

```bash
cd RepoGithub && python3 -m http.server 8000
# http://127.0.0.1:8000/slides/index.html
```

Teclas: → / espacio (siguiente build), ← (anterior), `c` subtítulos on/off, `q` marcadores QA on/off,
`f` pantalla completa, `o`/`esc` vista general. Parámetros de URL: `?print-pdf` (versión PDF),
`?qa=off` (oculta marcadores), `?captions=off`, `?record=1` (sin cursor),
`?numbers=../figures/numbers_q1.json,../figures/numbers_q2.json` (vista previa con salidas parciales).
Por `file://` funciona si existe `js/numbers_data.js`:
`python slides/script/fill_numbers.py --emit-js slides/js/numbers_data.js` (archivo ignorado por git).

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
| fig01_growth_components_by_income | MP4 + PNG | s1.b2 | **721×390** | = | 721×225 |
| fig02_lever_map_2023 | PNG | s1.b3 | **1037×365** | = | 1037×290 |
| fig02b_lever_map_zoom | MP4 | s1.b5a | **1037×365** (el Golfo en la mitad superior: abajo entra la tarjeta EAU de 226 px) | = | — |
| fig03_uae_fan_2050 | PNG | s1.b5b | **441×204** | = | 560×150 |
| fig04_same_road_registration | MP4 + PNG | s2.b1 | **774×183** | 1760×496 (héroe, misma proporción) | 774×243 |
| fig05_mortality_first_event_time | PNG | s2.b2 | **986×211** | = | 986×271 |
| fig06_within_vs_across_forest | PNG | s2.b3 | **1021×135** | = | 1021×183 |
| fig07_single_indicator_scorecard | MP4 + PNG | s3.b1 | **572×286** | = | 572×394 |
| fig09_pca_two_dimensions | MP4 + PNG | s3.b3 | **624×405** | = | 624×513 |
| fig10_trajectory_groups | MP4 + PNG | s4.b1 | **1092×348** (foco b1–b2; desde b3 se reduce a 1092×235) | = | 969×164 → conviene `_print.png` |
| fig11_divergence_fan | PNG | s4.b2 | **670×389** (foco b2; desde b3 670×235) | = | 793×160 → conviene `_print.png` |

## 4. Cifras (`figures/numbers.json`)

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
la voz v2.1; `" | "` separa bloques (≤ 90 caracteres). `slides/script/video_timings.json` (lo escribe el
agente de guion; partir de `dev/video_timings.template.json`):

```json
{"steps": [{"id": "s1.b2", "duration": 14.0,
            "captions": [{"t": 0, "text": "In today's high-income countries, …"}, {"t": 5.2, "text": "…"}]}]}
```

Sin `captions`, los bloques se reparten por igual en `duration`; sin archivo, 3,2 s por bloque.
Los `id` son los `data-step` (32 estados: `cover.b1…b5`, `s1.b0…b5b`, `s2.b0…b4`, `s3.b0…b4`, `s4.b0…b5`, `refs`).

## 6. Grabar, exportar, probar

Venv con Playwright + pypdf: `VENV=/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/venv-jupyter`
(Chromium del sistema `/usr/bin/chromium`; Playwright necesitó `playwright install ffmpeg` para grabar).

```bash
$VENV/bin/python video/record_slides.py            # WebM 1920×1080 en video/raw/ (+ _steps.json con tiempos reales)
$VENV/bin/python video/record_slides.py --timings slides/dev/video_timings.template.json --mp4
bash video/export_pdf.sh --png                     # slides/export/slides.pdf; falla si no son 6 páginas
$VENV/bin/python slides/dev/screenshots.py         # capturas + ranuras + informe
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
