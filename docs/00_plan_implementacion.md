# 00 — Plan de implementación (división del trabajo, repositorio, convenciones y definición de "terminado")

> Complementa `00_plan_analitico.md` (qué se analiza) y `00_storyboard_diapositivas.md` (qué se muestra y se dice). Fecha: 2026-10-22. Entrega: **viernes 30-oct-2026**. El orquestador no edita archivos: **cada cambio lo hace el agente responsable** indicado aquí. Nadie ejecuta `git` salvo el agente `repo-ops` (commits al cierre de cada hito).

---

## 1. Hechos del entorno que condicionan el plan (verificados 2026-10-22)

| Recurso | Estado | Consecuencia |
|---|---|---|
| R 4.6.1, 14 núcleos, 30 GB RAM; CRAN accesible | OK | Todo el análisis y las figuras en R. |
| Paquetes R ya instalados (ver `docs/paquetes_estado.csv`) | tidyverse, data.table, ggplot2, patchwork, ggrepel, scales, viridis, ggthemes, ggridges, plotly, htmlwidgets, ggalluvial, treemapify, **maps, mapproj, countrycode, ggflags (GitHub)**, cluster, fda, fda.usc, forecast, plm, **fixest**, mgcv, broom, kableExtra, gt, knitr, rmarkdown, IRkernel, jsonlite, here, renv, arrow, rnaturalearthdata | Mapas con `maps` + `countrycode` desde el día 1; banderas en PNG con `ggflags`. |
| Paquetes pendientes (otro agente los instala; si fallan hay fallback) | gganimate, gifski, ggbump, ggstream, factoextra, FactoMineR, dtwclust, lme4, **sf / rnaturalearth / units / terra / transformr / geofacet / magick / ggimage / av** (necesitan libs de sistema: GDAL, GEOS, Rust, ImageMagick-dev, libav — **no están** y no hay sudo) | Diseñar todo para que funcione **sin** `sf`, `magick`, `av`, `transformr`. Si `sf` llega a instalarse, migrar los dos mapas a Robinson (`coord_sf(crs="+proj=robin")`) como mejora opcional. |
| ImageMagick CLI (`magick`/`convert` 7.1.2) y `gifsicle` | **instalados** | Fallback para GIF: fotogramas PNG → `magick -delay … -loop 0` → `gifsicle -O3`. |
| `ffmpeg` | **no** instalado | MP4 solo con el binario portable de `imageio-ffmpeg` dentro del venv del scratchpad (§5). |
| Python 3.14, `pip` bloqueado por PEP 668 fuera de venv; venv ya existente: `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/venv-jupyter` | OK | `pip install imageio-ffmpeg jupyter nbconvert playwright` **dentro de ese venv**. |
| Node 24 + npm; Chromium `/usr/bin/chromium` | OK | reveal.js por npm (vendorizado); PDF con Chromium headless; grabación con Playwright (venv) usando el Chromium del sistema. |
| Quarto, pandoc, OBS | **no** instalados | Diapositivas = **reveal.js HTML directo** (sin Quarto). Grabación con Playwright o con cualquier grabador que tenga el equipo. |
| Fuentes | **Lato** (Regular/Medium/Bold/Black) y Noto Sans instaladas; *Inter* no | Fuente única del proyecto: **Lato** (el `theme_wpp()` del catálogo usa "Inter": cambiar a "Lato"). |

---

## 2. Estructura del repositorio `RepoGithub/`

```
RepoGithub/
├── README.md                 # qué es, cómo reproducir en 1 comando, enlaces a vídeo y PDF
├── SETUP.md                  # todo lo instalado (R, venv, npm) con versiones; actualizado por quien instale algo
├── LICENSE                   # MIT (código); textos y figuras CC BY 4.0 (indicado en README)
├── Makefile                  # targets: data, notebook, figures, anim, slides, pdf, video, qa, all
├── renv.lock                 # generado al final por notebook-R
├── .gitignore                # data/raw/*, data/processed/*.parquet, tools/, slides/vendor/, *.mp4 > 10 MB (ver §2.1)
├── data/
│   ├── raw/                  # (ignorado) los CSV/GZ oficiales + WB_income_groups.csv + suplemento; README con URLs y sha256
│   ├── processed/            # (ignorado) paises.parquet, agregados.parquet, lookup_regiones.csv (este sí se versiona)
│   └── README.md             # fuente, licencia CC BY 3.0 IGO, cómo descargar, hashes
├── R/
│   ├── config.R              # rutas, semilla 2026, paletas, vars_pca, umbrales, reglas_nombres, theme_wpp()
│   ├── 01_preparar_datos.R   # carga Medium + suplemento + WB; país vs agregado; region_sdg; ingreso_bm; tipo_palanca; tests
│   ├── 02_q1_palancas.R      # descomposición, mapa de palancas, rezago, β, acoplamiento
│   ├── 03_q2_un_indicador.R  # scorecard R², gemelos, PCA, índice compuesto y sensibilidad
│   ├── 04_q3_trayectorias.R  # fan charts σ, clustering, nombres de grupos, tabla "qué palanca, dónde, cuándo"
│   ├── 05_numbers_json.R     # recoge todas las cifras narradas → figures/numbers.json
│   ├── fig_estaticas.R       # una función por figura: fig01_… → PNG 1920×1080 (+ versión 960×540 para revisión)
│   ├── fig_animadas.R        # una función por animación: fotogramas → MP4/GIF + póster PNG
│   └── utils_*.R             # helpers (etiquetas, anotaciones históricas, exportación)
├── notebook/
│   ├── analisis_wpp2024.ipynb        # kernel IRkernel; narrativa en español; llama a R/*.R (no duplica código)
│   └── analisis_wpp2024.html         # exportado con nbconvert (venv)
├── figures/
│   ├── numbers.json          # FUENTE ÚNICA de cifras (§4)
│   ├── static/               # fig01_….png … (inglés)
│   ├── animated/             # fig01_….mp4 / .gif + fig01_…_poster.png
│   ├── frames/               # (ignorado) fotogramas intermedios
│   ├── appendix/             # figuras que no van al vídeo (correlograma, bump chart, CDR–LEx, etc.)
│   └── review/               # capturas de revisión (cada figura "fotografiada" + checklist.md)
├── slides/
│   ├── index.html            # reveal.js: cover + 4 contenido + references
│   ├── css/theme_wpp.css     # Lato, colores, barra de subtítulos, @media print
│   ├── js/numbers.js         # carga figures/numbers.json e inyecta en <span data-num="clave">
│   ├── js/captions.js        # muestra el subtítulo del fragmento activo
│   ├── assets/               # banderas (flag-icons), iconos de agencias, logos
│   ├── vendor/               # (ignorado) reveal.js y flag-icons desde npm; package.json versionado
│   ├── script/narration_en.md   # guion final con tiempos y claves de subtítulo
│   ├── script/captions.srt      # mismo texto en SRT (por si se añade como pista)
│   └── export/               # slides.pdf (6 páginas), video_timings.json
├── video/
│   ├── record_slides.py      # Playwright: avanza fragmentos según video_timings.json y graba WebM 1920×1080
│   ├── assemble.sh           # ffmpeg: WebM + voz (wav) → final.mp4 (H.264, AAC, ≤ 5:00)
│   └── final/                # (ignorado si > 100 MB) DataQuest2026_<Team>.mp4
└── docs/                     # 00_* (planes), 01_* ganadores, 02_* historia, 05_* catálogo viz, 06_asesoria_*, QA_*.md
```

**2.1 `.gitignore` mínimo:** `data/raw/`, `data/processed/*.parquet`, `figures/frames/`, `slides/vendor/`, `tools/`, `video/final/`, `*.RData`, `.Rproj.user/`, `.ipynb_checkpoints/`. Los MP4/GIF de `figures/animated/` **sí** se versionan si pesan ≤ 10 MB (comprobar con `make sizes`).

---

## 3. Agentes, orden y dependencias

| # | Agente | Entrega (ruta) | Depende de | Día objetivo |
|---|---|---|---|---|
| 0 | **env-setup** | `SETUP.md`; venv con `imageio-ffmpeg jupyter nbconvert playwright`; `npm i` en `slides/` (reveal.js 5, flag-icons); intento de instalar gganimate/gifski/ggbump/factoextra; registra qué quedó instalado en `docs/paquetes_estado.csv` | — | D1 (22–23 oct) |
| 1 | **prepare-data** | `R/config.R`, `R/01_preparar_datos.R`, `data/processed/*.parquet`, `data/processed/lookup_regiones.csv`, `data/README.md`, tests (§7.1) | 0 | D1 |
| 2 | **notebook-R** | `R/02–04_*.R`, `R/05_numbers_json.R`, `notebook/analisis_wpp2024.ipynb` ejecutado, `figures/numbers.json` v1 (todas las claves de §4, `verified:false`) | 1 | D2–D3 (24–25 oct) — **congelar cifras v1 el 25 oct** |
| 3 | **figures-static** | `R/fig_estaticas.R` → `figures/static/fig01…fig12.png` + `figures/review/` | 2 (datos + numbers) | D3–D4 |
| 4 | **figures-animated** | `R/fig_animadas.R` → `figures/animated/*.mp4|.gif` + pósters | 3 (cada animación parte de su figura estática aprobada) | D4–D5 (26–27 oct) |
| 5 | **script-narration** | `slides/script/narration_en.md` (marcadores `{clave}` resueltos), `captions.srt`, `video_timings.json`; elige `group4_sentence` y ejemplos desde `numbers.json` | 2 | D4 |
| 6 | **slides-revealjs** | `slides/index.html`, css/js, `slides/export/slides.pdf` | 3, 4, 5 | D5–D6 (27–28 oct) |
| 7 | **QA-stats** | `docs/QA_stats.md`; `numbers.json` con `verified:true` en cada clave usada | 2 (y re-ejecuta tras cualquier cambio de 2) | D3 y D6 |
| 8 | **QA-viz** | `docs/QA_viz.md` + `figures/review/checklist.md` | 3, 4 | D4 y D6 |
| 9 | **QA-ethics** | `docs/QA_ethics.md` (checklist ASA por entregable, §8 del plan analítico) | 2, 5, 6 | D6 |
| 10 | **QA-slides** | `docs/QA_slides.md` (6 páginas, legibilidad al 50 %, prueba del familiar, ≤ 5:00) | 6 | D6–D7 |
| 11 | **video-record** | `video/final/*.mp4` con subtítulos en pantalla; duración ≤ 5:00 | 6, 10 + voz grabada por el equipo | D7 (29 oct) |
| 12 | **integrate-advice** | Cambios de `docs/06_asesoria_*.md` aplicados a los tres planes (tabla §11 del plan analítico) | cuando existan memos; antes de congelar v1 si llegan a tiempo | D2–D3 |
| 13 | **repo-ops** | commits por hito, `README.md` final, tag `submission-2026-10-30` | todos | D8 (30 oct) |

Orden crítico (camino más largo): **0 → 1 → 2 → 3 → 4 → 6 → 10 → 11**. Paralelizable: 5 con 3–4; 7–9 en cuanto exista su insumo. Regla: ninguna animación empieza antes de que su figura estática pase QA-viz; ninguna diapositiva se graba antes de que QA-stats haya marcado ✔ todas las cifras que contiene.

---

## 4. `figures/numbers.json` — fuente única de cifras

Lo genera `R/05_numbers_json.R` al final del notebook. **Ninguna cifra, ejemplo de país, bandera ni nombre de grupo se escribe a mano en las diapositivas o en el guion**: `slides/js/numbers.js` rellena `<span data-num="clave">` y `script-narration` resuelve `{clave}` con un script (`slides/script/fill_numbers.py`).

Esquema por clave:
```json
"share_mig_high_2000_2023": {"value": 71, "unit": "%", "fmt": "0",
   "def": "Σ NetMigrations / Σ PopChange, países WB High income, 2000–2023",
   "filter": "237 países; ingreso WB FY2026", "source_cell": "notebook §Q1.1",
   "used_in": ["slide1.build2", "narration.s1"], "verified": false, "verified_by": null, "verified_on": null}
```
Claves obligatorias (mínimo): `world_pop_2023_bn`, `n_countries`, `n_countries_1m`, `n_below_replacement_2023`, `n_below_repl_growing_2023`, `n_grow_only_migration_2023`, `n_grow_only_migration_2023_1m`, `n_shrink_emigration_2023`, `n_type_A`…`n_type_E`, `examples_type_C`, `examples_type_D`, `examples_type_E`, `cover_flags`, `share_mig_high_2000_2023`, `share_mig_high_2010_2023`, `share_mig_europe_2000_2023`, `share_mig_nam_2000_2023`, `cnmr_are_2023`, `yrs_eu`, `yrs_asia`, `yrs_lac`, `lag_median`, `share_mort_first`, `n_lag`, `beta_tfr`, `beta_imr`, `beta_cnmr`, `r2_tfr_medage`, `r2_tfr_chg2050`, `r2_tfr_growth`, `r2_tfr_cnmr`, `r2_tfr_cdr`, `r2_all`, `twins` (lista de pares con valores), `rho_cdr_lex_1950`, `rho_cdr_lex_2023`, `pc1_var`, `pc2_var`, `n_pcs_70`, `pc1_var_8vars` (sensibilidad), `alpha`, `share_rank_shift_20`, `k_clusters`, `silhouette`, `cluster_names`, `cluster_sizes`, `cluster_pop_bn`, `cluster_examples`, `group4_name`, `group4_sentence_variant` ("i"|"ii"), `tfr_fast_1950`, `tfr_fast_2023`, `medage_fast_2050`, `sd_medage_1950`, `sd_medage_2023`, `sd_medage_peak_year`, `sd_lex_1950`, `sd_lex_2023`, `sd_le60_1950`, `sd_le60_2023`, `year_europe_natneg`, `world_peak_year`, `world_peak_bn`, `n_peaked_2023`.

Reglas de ejemplos (implementadas en `R/05_numbers_json.R`, no a mano): `examples_type_X` = 3 países más poblados del tipo X entre los ≥ 1 M (nombres cortos en inglés vía `countrycode(…, "country.name.en")`, con alias "South Korea", "Türkiye"); `cover_flags` = ISO2 de `examples_type_C`; `cluster_examples[k]` = 3 más poblados del grupo k; `twins` = pares con |ΔTFR| ≤ 0.05 y máxima |Δ PopGrowthRate| (y |ΔLEx| ≤ 0.2 con máxima |Δ MedianAgePop|), ambos ≥ 1 M; `cluster_names` por `reglas_nombres` (CNMR mediana 2000–23 > 10 ‰ → "Migration-boosted"; si no, el grupo con mayor velocidad de caída de TFR → "Sprinters"; el que cruzó TFR < 4 antes de 1960 (mediana) → "Early movers"; el que cruzó después de 1995 o no cruzó → "Late movers"; el restante → "Fast movers").

---

## 5. Ruta de animación y de diapositivas (decisión)

**Figuras y animaciones: R/ggplot2.** Cada animación tiene una función `anim_figXX()` en `R/fig_animadas.R` que (1) construye los datos por fotograma (interpolación con `tweenr` cuando haga falta; `gganimate` con `transition_time()/transition_reveal()` solo para puntos y líneas, porque `transformr` no está), (2) escribe fotogramas PNG con `ragg::agg_png(1920, 1080, res = 144)` en `figures/frames/figXX/` (30 fps; 6–12 s ⇒ 180–360 fotogramas), (3) exporta:
- **MP4 (preferido para reveal.js):** `ffmpeg -framerate 30 -i frame_%04d.png -c:v libx264 -pix_fmt yuv420p -crf 20 -movflags +faststart figXX.mp4`, usando el binario portable: en la sesión R, `Sys.setenv(PATH = paste("<venv>/bin", Sys.getenv("PATH"), sep=":"))` y `ffmpeg <- system("python -c 'import imageio_ffmpeg,sys;sys.stdout.write(imageio_ffmpeg.get_ffmpeg_exe())'", intern=TRUE)`; se llama con `system2(ffmpeg, …)`. (`gganimate::av_renderer()`/paquete `av` solo si llega a compilarse; no contar con ello.)
- **GIF (respaldo y para el notebook):** `gganimate::animate(…, renderer = gifski_renderer())` si `gifski` quedó instalado; si no, `magick -delay 4 -loop 0 frames/*.png figXX.gif && gifsicle -O3 --colors 128 -o figXX.gif figXX.gif`.
- **Póster:** último fotograma → `figXX_poster.png` (se usa en impresión/PDF y como `poster=` del `<video>`).
Venv de referencia: `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/venv-jupyter` (añadir al PATH antes de cualquier llamada a ffmpeg; documentar en `SETUP.md` cómo recrearlo: `python3 -m venv venv-jupyter && venv-jupyter/bin/pip install imageio-ffmpeg jupyter nbconvert playwright`).

**Diapositivas: reveal.js 5 (HTML directo, sin Quarto).** Justificación frente a alternativas: Quarto no está instalado y añade una capa; `plotly` frames son buenos para interactividad pero no para vídeo (estilo distinto a ggplot, difícil sincronizar con la voz); D3 cuesta demasiado para 8 días; PowerPoint no permite automatizar builds desde R ni garantizar fuentes. reveal.js da: `fragment` con `data-fragment-index` (builds), `data-auto-animate` (números y títulos que se desplazan), `<video autoplay muted playsinline>` disparado por fragmento (`js/captions.js` llama a `play()` al activarse), barra de subtítulos sincronizada (el texto de cada fragmento está en `data-caption`), `?print-pdf` con `pdfSeparateFragments:false` ⇒ 6 páginas, y se graba en vídeo con Playwright.

**Vídeo:** `video/record_slides.py` (Playwright + Chromium del sistema, `--window-size=1920,1080`, `record_video_dir`) avanza por `video_timings.json` (segundos por fragmento tomados del guion) → WebM; la voz la graba el equipo (wav/m4a, 48 kHz) leyendo `narration_en.md` con el vídeo delante; `video/assemble.sh` mezcla con ffmpeg (venv) y comprueba `duration ≤ 300 s`. Los subtítulos ya están **en pantalla** (barra de la diapositiva), por eso no hace falta `libass`. Plan B: cualquier grabador de pantalla del equipo sobre `slides/index.html` a pantalla completa.

---

## 6. Convenciones

- **Idiomas:** código R, comentarios, nombres de funciones y variables en **español** (`preparar_paises()`, `tipo_palanca`); nombres de archivos de figuras, textos de gráficas, diapositivas y guion en **inglés**. Nombres de figuras: `figNN_tema_filtro.ext` (p. ej. `fig02_lever_map_2023.png`, `fig03_transition_path_regions.mp4`). Un número de figura = una idea; apéndice con prefijo `app_`.
- **Semilla:** `set.seed(2026)` en `config.R` y al inicio de cada bloque aleatorio (k-means, bootstrap); `nstart = 50`.
- **Tema gráfico común:** `theme_wpp(base_size = 22, base_family = "Lato")` (adaptado del catálogo §2; título = mensaje en frase, subtítulo = filtro, caption = `Source: UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey)`), `proj_shade` + `proj_line` en 2023.5 en toda serie que cruce. Exportar siempre con `ragg::agg_png(1920, 1080, res = 144)` y una copia 960×540 para revisión rápida.
- **Paletas (accesibles, Okabe-Ito; se definen una sola vez en `config.R` y se reutilizan en CSS):**
  - *Regiones SDG (8):* Sub-Saharan Africa #E69F00 · Northern Africa & Western Asia #D55E00 · Central & Southern Asia #CC79A7 · Eastern & South-Eastern Asia #0072B2 · Latin America & Caribbean #009E73 · Oceania (excl. AUS/NZ) #F0E442 · Australia/New Zealand #56B4E9 · Europe & Northern America #000000 (gris #4D4D4D en fondos oscuros).
  - *Tipos de palanca (Slide 1):* A/B growing on births #009E73 · C growing only by migration #0072B2 · D shrinking, deaths > births #D55E00 · E shrinking by emigration #E69F00 · small states / no data #BBBBBB.
  - *Grupos de trayectoria (Slide 4), distintos de los anteriores:* Early movers #332288 · Fast movers #117733 · Late movers #DDCC77 · Grupo 4 #AA4499 (paleta Tol). Prohibido rojo/verde puro como único contraste; comprobar con `colorblindr::cvd_grid()` o `colorspace::simulate_cvd()`.
  - *Estimación vs proyección:* proyección siempre gris #B0B0B0 / sombreado #F0F0F0.
- **Tamaños:** figuras 1920×1080 (16:9); diapositivas 1920×1080; fuente mínima en figura 18 px (a 1080p), en diapositiva 20 px; márgenes seguros 64 px; subtítulos 34 px Lato Bold con fondo #000 al 55 %, ≤ 2 líneas, ≤ 90 caracteres.
- **Mapas:** `maps::map_data("world")` → `countrycode(region, "country.name", "iso3c")` con tabla de excepciones en `config.R` (Kosovo = XKX, Micronesia, Eswatini, etc.); proyección `coord_map("mollweide")`; pequeños Estados en una franja de puntos bajo el mapa, nunca omitidos.
- **Lenguaje:** sin verbos causales (*drives, causes, leads to*) en ningún texto en inglés; lista permitida: *goes with, is associated with, follows, coincides with, comes from (contabilidad)*. Cada término técnico lleva su "= …" la primera vez.
- **Reproducibilidad:** `make all` ejecuta datos → notebook → figuras → animaciones → slides → pdf; `renv::snapshot()` al cerrar; `sessionInfo()` en la última celda; `SETUP.md` lista todo lo instalado con versión.

---

## 7. Definición de "terminado" por entregable

**7.1 prepare-data** — `make data` corre sin error en < 3 min; `data/processed/paises.parquet` tiene 237 países × 151 años (1950–2100), columnas derivadas (`region_sdg`, `continente`, `ingreso_bm`, `es_proyeccion`, `tipo_palanca`, `pob_1m`); tests automáticos que **fallan** si: suma de países por región SDG ≠ agregado ONU (tolerancia 0.1 % en `TPopulation1July`, 2023); residuo `PopChange − NatChange − NetMigrations` > 0.5 % del `PopChange` en > 1 % de filas-país; algún país ≥ 1 M sin `region_sdg`; `ingreso_bm` con más de 21 "Not classified"; alguna fila de 2101 presente. `data/README.md` con URLs oficiales, licencia y sha256 de cada archivo crudo.

**7.2 notebook-R** — ejecuta de principio a fin con `make notebook` (IRkernel vía `jupyter nbconvert --execute`, venv) en < 15 min; estructura: 0 Fuentes/licencia/ética · 1 Decisiones de datos (tabla §3 del plan analítico) · 2 Hipótesis H1–H14 **antes** de los cálculos · 3 Q1 · 4 Q2 · 5 Q3 · 6 Recomendaciones (tabla) · 7 Lo que no encontramos / limitaciones · 8 Reproducibilidad (`sessionInfo`). Cada bloque termina con "Lectura de resultados" citando cifras reales (memoria `review-every-output`). Genera `numbers.json` con **todas** las claves de §4 y las figuras de apéndice. Comentarios y markdown en español; etiquetas de gráficas en inglés. PCA con el conjunto fijo `vars_pca` (12) y la sensibilidad de 8 variables reportada.

**7.3 figures-static** — 12 figuras `figures/static/figNN_*.png` a 1920×1080 + copia 960×540; cada una: título-mensaje, subtítulo-filtro, caption de fuente, marca estimación/proyección si cruza 2023, etiquetas directas, paleta de §6, sin leyenda cuando ≤ 8 series, texto ≥ 18 px, pequeños Estados tratados. **"Fotografiar y revisar":** el agente abre cada PNG (herramienta Read) y anota en `figures/review/checklist.md` por figura: ¿se lee el mensaje en 5 s? ¿algún texto solapado o cortado? ¿colores distinguibles en simulación de daltonismo (`colorspace::simulate_cvd`, guardar `figNN_cvd.png`)? ¿cifras en la figura = `numbers.json`? Solo con las 4 respuestas correctas pasa a QA-viz.

**7.4 figures-animated** — 7 animaciones (`fig01`, `fig02_zoom`, `fig03`, `fig06`, `fig09`, `fig11`, `fig12` opcional) en MP4 ≤ 8 MB (CRF 20, 30 fps, 6–12 s) + GIF de respaldo + póster PNG; cada una parte de su figura estática aprobada y sólo añade movimiento que **señala** (aparece lo que se nombra; el resto se atenúa); el último fotograma = figura estática con todas las anotaciones. Revisión: el agente extrae 6 fotogramas equiespaciados (`ffmpeg -vf fps=1/2` o `magick`), los mira y confirma que no hay saltos, etiquetas que bailan ni ejes que cambian de escala sin aviso; anota en `checklist.md`.

**7.5 script-narration** — `narration_en.md` ≤ 700 palabras (cronometrado: lectura en voz alta ≤ 4:50 incluyendo pausas de 2 s tras cada cifra); todos los `{clave}` resueltos desde `numbers.json` por `fill_numbers.py` (falla si queda alguno); frases ≤ 20 palabras; cada cifra narrada aparece también en pantalla; `captions.srt` con bloques de 4–12 palabras; `video_timings.json` con segundos por fragmento (suma ≤ 295 s). Elegido `group4_sentence` y ejemplos conforme a `numbers.json`.

**7.6 slides-revealjs** — `slides/index.html` con exactamente 6 `<section>` (cover, 4 contenido, references); cada contenido muestra el rótulo "Question N" + códigos P; builds según el storyboard, con `data-caption`; vídeos con `poster`; `js/numbers.js` rellena todos los `data-num` (consola sin errores); fuentes locales (Lato) — sin dependencias de red durante la grabación; `npm run pdf` genera `slides/export/slides.pdf` de **6 páginas** con el layout de impresión del storyboard §9 (≤ 3 visuales + mensaje por página, fuente ≥ 20 px, nada cortado). Captura de cada página a 50 % revisada por el agente antes de pasar a QA-slides.

**7.7 QA-stats** — tarea explícita: **reproducir cada cifra del guion y de las diapositivas desde el notebook** (ejecutar `make notebook` en limpio, comparar `numbers.json` regenerado con el usado; recalcular a mano en R ≥ 5 cifras clave con código independiente: 71 %, 11 años, 0.59/0.77, PC1, silueta) y marcar `verified:true` + `verified_by` + fecha en cada clave usada en `used_in`; comprobar que cada país nombrado tiene el `tipo_palanca`/grupo que se le atribuye; revisar que las hipótesis que fallaron se reportan; informe `docs/QA_stats.md` con tabla clave → valor plan → valor notebook → ✔/✘. **Bloquea la grabación** si queda alguna clave sin ✔.

**7.8 QA-viz** — recorre `figures/review/checklist.md` y cada PNG/MP4: mensaje legible en 5 s, ejes con unidades, sin truncar ejes de barras, estimación/proyección marcada, paleta correcta y simulación CVD aprobada, pequeños Estados tratados, caption de fuente; comprueba coherencia visual entre figuras (misma fuente, mismos colores por región/tipo en todas); `docs/QA_viz.md`.

**7.9 QA-ethics** — aplica la tabla §8 del plan analítico a notebook, figuras, guion, slides y repo: licencia y cita presentes; estimación vs proyección en cada serie; sin verbos causales (grep automático de *drive|cause|lead to|impact* en `narration_en.md` e `index.html`); grupos descritos por comportamiento; recomendaciones con verbos permitidos y referidas a la gráfica que las sustenta; limitaciones visibles (franja Slide 4 + notebook §7); migración no calificada; crisis citadas con respeto; `docs/QA_ethics.md`.

**7.10 QA-slides — checklist "prueba del familiar no estadístico"** (se hace con una persona ajena al equipo o, en su defecto, el agente simula la lectura sin contexto): (1) ¿puede decir en una frase qué responde cada diapositiva tras 20 s? (2) ¿entiende "replacement fertility", "net migration", "R²", "principal component", "cluster" solo con lo que hay en pantalla? (3) ¿sabe qué es estimación y qué es proyección? (4) ¿identifica la respuesta a "Question 1/2/3"? (5) ¿algún color/etiqueta le confunde? (6) ¿el subtítulo cabe y se lee a 50 %? (7) ¿la tabla de recomendaciones se entiende sin la voz? Además: PDF = 6 páginas; vídeo ≤ 5:00; "Question" visible; P7/P8 respondidos literalmente; informe `docs/QA_slides.md` con las 7 respuestas por diapositiva y lo que se cambió.

**7.11 video-record** — MP4 H.264 1920×1080, 30 fps, AAC, duración ≤ 5:00 (objetivo 4:50), subtítulos en pantalla legibles, audio normalizado (−16 LUFS), sin cortes bruscos; el agente extrae 10 fotogramas y los revisa (memoria `video-subtitles-from-frames`); nombre `DataQuest2026_<Team>_video.mp4`; `slides/export/slides.pdf` renombrado `DataQuest2026_<Team>_slides.pdf`.

**7.12 integrate-advice** — ver plan analítico §11; terminado cuando cada memo `06_asesoria_*.md` tiene fila en la tabla de integración y los tres planes están coherentes (no hay figura nueva sin figura retirada; `numbers.json` tiene las claves nuevas).

**7.13 repo-ops** — `README.md` con: título, equipo, enlaces a vídeo y PDF, las 3 preguntas y respuestas de una frase, cómo reproducir (`make all`), licencias (código MIT; textos/figuras CC BY 4.0; datos UN CC BY 3.0 IGO), cita ASA; commits por hito con mensajes en español; tag final.

---

## 8. Makefile (targets y comandos de referencia)

```make
VENV=/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/venv-jupyter
export PATH:=$(VENV)/bin:$(PATH)
data:      ; Rscript R/01_preparar_datos.R
notebook:  data ; jupyter nbconvert --to notebook --execute --inplace notebook/analisis_wpp2024.ipynb && jupyter nbconvert --to html notebook/analisis_wpp2024.ipynb
figures:   notebook ; Rscript R/fig_estaticas.R
anim:      figures ; Rscript R/fig_animadas.R
slides:    ; cd slides && npm ci && python script/fill_numbers.py
pdf:       slides ; chromium --headless --no-sandbox --print-to-pdf=slides/export/slides.pdf --no-pdf-header-footer "file://$(PWD)/slides/index.html?print-pdf"
video:     pdf ; python video/record_slides.py && bash video/assemble.sh
qa:        ; Rscript R/qa_numbers.R && python slides/script/check_placeholders.py && pdfinfo slides/export/slides.pdf | grep Pages
all:       anim slides pdf qa
```

---

## 9. Calendario (22 → 30 oct) y puntos de control

| Día | Hito | Control |
|---|---|---|
| D1 jue 23 | env-setup + prepare-data listos | tests de datos en verde |
| D2 vie 24 | notebook Q1–Q3 v0 + `numbers.json` v0 | QA-stats comprueba 5 cifras clave |
| D3 sáb 25 | **congelar `numbers.json` v1**; integrate-advice aplicado; figuras estáticas 1–6 | checklist de figuras |
| D4 dom 26 | figuras estáticas 7–12; animaciones 1–3; guion v1 cronometrado | QA-viz parcial |
| D5 lun 27 | animaciones 4–7; `index.html` v1 con numbers.js | PDF 6 páginas |
| D6 mar 28 | QA-stats final (✔ en todo), QA-viz, QA-ethics, QA-slides | lista de correcciones |
| D7 mié 29 | correcciones; voz grabada; vídeo ensamblado | duración ≤ 5:00 y 10 fotogramas revisados |
| D8 jue 30 | README, tag, subida de vídeo + PDF | entrega antes de la hora límite |

Riesgos principales y respuesta rápida: `gifski`/`gganimate` no instalan → ruta de fotogramas + ImageMagick (ya probada en el catálogo §2.10); ffmpeg del venv falla → GIF en las diapositivas (reveal acepta `<img>`), vídeo final grabado por el equipo; animaciones no listas a D6 → el póster PNG sustituye a la animación (la diapositiva sigue completa); guion > 5:00 → recortar anécdotas (gemelos a un solo par, zoom al Golfo), nunca las respuestas a Q1–Q3.
