# 00 — Storyboard de diapositivas y guion del vídeo (5:00)

> Texto de diapositivas, subtítulos y narración **en inglés**; notas de producción **en español**.
> Formato final: **portada + 4 diapositivas de contenido + referencias** (FAQ oficial). Cada diapositiva de contenido tiene varios *builds* (fragmentos reveal.js) que se graban como animación pero se imprimen como **una sola página** en el PDF (`pdfSeparateFragments: false`).
> Toda cifra entre llaves `{clave}` se resuelve desde `figures/numbers.json` (generado por el notebook). Los valores mostrados aquí son provisionales (ver `00_plan_analitico.md` §5–6) y **se sustituyen** por los finales antes de grabar.

---

## 0. Línea de tiempo del vídeo (objetivo 4:50 ± 5 s; ritmo 140–145 palabras/min ⇒ ≤ 700 palabras; guion actual: 685 palabras ≈ 289 s a 142 ppm; si al grabar el ritmo real baja a 120–130 ppm, `script-narration` recorta a ≈ 600 palabras quitando anécdotas, nunca las respuestas a Q1–Q3)

| Tiempo | Diapositiva | Sección | Palabras |
|---|---|---|---|
| 0:00–0:30 | Cover | Gancho numérico + equipo | 69 |
| 0:30–0:58 | Slide 1 (build 0) | Tres preguntas + tarjeta de datos | 81 |
| 0:58–1:50 | Slide 1 (builds 1–4) | **Question 1** — las tres palancas: descomposición por ingreso + mapa 2023 | 98 |
| 1:50–2:45 | Slide 2 | **Question 1 (cont.)** — mismo camino, distinta velocidad; la mortalidad va primero; la migración no tiene memoria | 132 |
| 2:45–3:45 | Slide 3 | **Question 2** — ¿un solo número? scorecard de R², gemelos, PCA (+ línea P5) | 128 |
| 3:45–4:40 | Slide 4 | **Question 3** — cuatro caminos + lista de vigilancia para la ONU + ética | 127 |
| 4:40–5:00 | Slide 4 (último build) → References | Cierre / callback | 50 |

Respuesta explícita a las preguntas del profesor: **P7 = Question 1** (Slides 1–2, en pantalla "Question 1 · P7 & P4"), **P8 = Question 2** (Slide 3, "Question 2 · P8 & P5"). En la esquina superior izquierda de cada diapositiva se muestra el rótulo "Question N" y, en gris pequeño, los códigos oficiales (P7, P8, …) para que el jurado los encuentre sin buscar.

---

## 1. Cover (0:00–0:30)

**Título en pantalla:** `One Number Can't Tell 8 Billion Stories`
**Subtítulo:** `Births, deaths and migration across 237 countries, 1950–2100 — and where the UN should look next`
**Línea inferior:** `Team {name} · ASA International DataQuest 2026 · Data: UN World Population Prospects 2024`

**Builds (auto, sin clic):**
1. (0:00) Fondo: mapa mundial muy tenue en gris (`fig00_world_dots.png`, un punto por país escalado por población). Aparece el número grande **`8.1 billion`** (contador animado de 2.5 → 8.1, `numbers.json: world_pop_2023_bn`).
2. (0:06) Aparece **`130 / 237 countries below replacement fertility`** con un icono de familia; los puntos de esos países se tiñen de azul claro.
3. (0:12) **`79 still growing`** (puntos se iluminan) y **`18 grow only because people move in`** (puntos con flecha de entrada; **tres banderas = `numbers.json: cover_flags`**, regla: los 3 países más poblados del tipo C "growing only by migration"; provisional DE, ES, FI).
4. (0:20) Texto final: **`One number can't explain that.`** → fundido al título.

**Narración (69 palabras):**
> Eight billion people. In 2023, one hundred and thirty of 237 countries had fertility below replacement — fewer than 2.1 children per woman. You would expect them to shrink. Yet seventy-nine still grow, and eighteen grow only because people move in. One number can't explain that. We are Team {name}, and we used the UN World Population Prospects 2024 to find out which levers really move a country's population.

**Subtítulos (caption bar):** dividir en 4 líneas de ≤ 90 caracteres, una por build.

*Notas de producción:* portada sin gráficas "de verdad" (cuenta como cover). Contador numérico con JS (`countUp`), fuente Lato Black 180 px. Cifras provisionales: 130/79/18 (`n_below_replacement_2023`, `n_below_repl_growing_2023`, `n_grow_only_migration_2023`).

---

## 2. Slide 1 — Question 1: *Which lever is moving each country's population?* (0:30–1:50) · P7 · P4

**Título:** `Question 1 · Which lever moves each country: births, deaths or migration?`
**Mensaje de una línea (aparece al final, build 4):** `Rich countries grow by migration; the rest grow by births — 18 countries would shrink without immigration.`

**Layout:** izquierda 45 % (descomposición animada), derecha 55 % (mapa). Build 0 ocupa toda la diapositiva y se desvanece.

| Build | Qué aparece / qué se anima / qué se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **0** | Tres tarjetas con las preguntas (iconos: balanza, lupa, carretera). Debajo, **tarjeta de datos**: `237 countries · 54 indicators · 1950–2023 UN estimates · 2024–2100 UN medium projection (shown in grey)` + logo UN DESA + "CC BY 3.0 IGO". | `Question 1 … Question 2 … Question 3 …` | 0:30–0:58 |
| **1** | Las tarjetas se encogen a la barra superior ("Q1" resaltado). Aparece la **ecuación animada** `Population change = Births − Deaths + Net migration` (cada término cae en su sitio). | ecuación | 0:58–1:05 |
| **2** | **`fig01_growth_components_by_income.mp4`**: barras apiladas por grupo de ingreso (Low, Lower-middle, Upper-middle, High), una década por fotograma 1950s → 2010–23; componente natural (verde) vs migración (azul; negativo hacia abajo). Al llegar a 2010–23 se congela y aparece la anotación con flecha: **`High income, 2000–2023: {share_mig_high_2000_2023}% of growth = migration`**. Eje y: millones de personas por década. Línea cero marcada. | anotación con flecha | 1:05–1:20 |
| **3** | **`fig02_lever_map_2023.png`** se dibuja (fade por tipo): verde = *Growing on births*, azul = *Growing only by migration*, rojo = *Shrinking: deaths > births*, naranja = *Shrinking by emigration*, gris = *small states (< 1 M)* en franja inferior con puntos. Leyenda con conteos `{n_type_A+B} · {n_type_C} · {n_type_D} · {n_type_E}`. | leyenda con conteos | 1:20–1:32 |
| **4** | **Zoom animado a Europa** (`fig02_lever_map_zoom_europe.mp4`, 4 s) con banderas sobre los países de `numbers.json: examples_type_C` (regla: top-5 por población del tipo C, ≥ 1 M; provisional DE, ES, BE, FI, HU); luego **zoom al Golfo** con ARE/QAT/OMN y la cifra `UAE: +{cnmr_are_2023} per 1,000 — population grows 3.7 %/yr with fertility 1.2`. Aparece el mensaje de una línea. | mensaje de una línea | 1:32–1:50 |

**Narración (build 0, 81 palabras):**
> We asked three questions. Question one: which lever is moving each country's population today — births, deaths or migration — and does the answer depend on region and income? Question two: can a single indicator tell the whole story? Question three: do countries travel the same road at different speeds, and what should the UN watch next in each group? Our data: 237 countries, UN estimates from 1950 to 2023, and the UN medium projection from 2024, always shown in grey.

**Narración (builds 1–4, 98 palabras):**
> Population change is simple arithmetic: births minus deaths, plus net migration. Watch the pieces shift. In low- and lower-middle-income countries, growth is almost entirely births over deaths; migration is a small outflow. In high-income countries the picture flipped: since 2000, seventy-one percent of their growth came from migration. Now, every country's lever in 2023. Green: growing from births. Blue: growing only because people move in — eighteen countries, including {examples_type_C}, where deaths already exceed births. Red: shrinking because deaths exceed births — {examples_type_D}. Orange: shrinking because people leave, although births exceed deaths — {examples_type_E}. One planet, four engines.

*Notas de producción:* **los ejemplos narrados de cada tipo (`{examples_type_C}`, `{examples_type_D}`, `{examples_type_E}`) se leen de `numbers.json`** (regla: los 3 países más poblados de cada tipo entre los ≥ 1 M; provisionales: C = Germany, Spain, Finland; D = Japan, Italy, South Korea; E = Nepal, Uruguay, Albania) — `script-narration` sustituye los marcadores y QA-stats comprueba que cada país nombrado tiene ese `tipo_palanca` en el notebook. La descomposición usa **sumas de países** por grupo del Banco Mundial (no los agregados de la ONU, para que coincidan con el mapa); el notebook comprueba que la suma de los cuatro grupos + "not classified" iguala al agregado World. Mapa: `maps::map_data("world")` + `countrycode` para unir por ISO3; proyección Robinson aproximada con `coord_map("moll")` o, si falla, `coord_quickmap`. Banderas en HTML con `flag-icons` (SVG). Colores de tipo (Okabe-Ito): verde #009E73, azul #0072B2, bermellón #D55E00, naranja #E69F00, gris #999999. El zoom es un vídeo renderizado desde R (secuencia de `coord_*` con límites interpolados por `tweenr`).

---

## 3. Slide 2 — Question 1 (cont.): *Same road, different speed — and mortality moves first* (1:50–2:45) · P7 · P1

**Título:** `Question 1 · Same road, different speed: mortality falls first, fertility follows, migration has no memory`
**Mensaje de una línea (build 4):** `Child mortality falls ~11 years before fertility; migration only matters where births and deaths already cancel out.`

**Layout:** izquierda 60 % (trayectorias animadas), derecha 40 % (dos paneles pequeños apilados: rezago y "memoria").

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig03_transition_path_regions.mp4`** (12 s): dispersión conectada, eje x = under-five mortality (log, per 1,000), eje y = children per woman; una línea por **región SDG** (8 colores accesibles) que avanza 1950 → 2023 con el año en grande en la esquina; etiquetas de década cada 10 años; tramo 2024–2100 en gris punteado al final. Anotaciones que aparecen en su año: `1959–62 China famine` (Eastern & SE Asia), `HIV/AIDS 1990s` (SSA), `COVID-19` (todas, 2020). Al final, flecha hacia la esquina inferior izquierda: `Everyone heads here`. Panel de velocidad: `Years from 5 to 2.5 children: Europe {yrs_eu} · Asia {yrs_asia} · LAC {yrs_lac} · SSA still on the road`. | año animado; anotaciones | 1:50–2:12 |
| **2** | Panel derecho superior **`fig04_mortality_first_lag.png`**: dumbbell por país (≥ 1 M, n = {n_lag}): punto hueco = año en que Q5 < 100 ‰; punto lleno = año en que TFR < 4; ordenados por región; la mediana del rezago (**{lag_median} years**) marcada con una llave. Se resalta (gghighlight) un país por región: KEN, BGD, MEX. | `Mortality first in {share_mort_first}% of countries · median lag {lag_median} yrs` | 2:12–2:27 |
| **3** | Panel derecho inferior **`fig05_memory_beta.png`**: tres mini-dispersiones "where you were in 1950 vs how much you changed": fertility (β = {beta_tfr}), child mortality (β = {beta_imr}), migration (β = {beta_cnmr} ≈ −1, nube sin pendiente). Pulsa (highlight) la de migración. Anotación: `Migration: no memory — reacts to shocks (Syria 2012–16, Ukraine 2022)`. | β-labels con explicación de una frase: `β ≈ −1 means today doesn't depend on 1950` | 2:27–2:40 |
| **4** | Mensaje de una línea + sello `Question 1 answered (P7, P4)`. | sello | 2:40–2:45 |

**Narración (132 palabras):**
> Region and income don't just change the lever — they change the timing. Each line is a region travelling the demographic transition: child deaths on the horizontal axis, children per woman on the vertical. Everyone heads to the bottom-left corner, but Europe took a century, Asia and Latin America about fifty years, and sub-Saharan Africa is on the road right now. Mortality moves first: among countries that crossed both thresholds since 1950, child mortality fell below one hundred per thousand a median of eleven years before fertility fell below four. Migration is different: it has no memory — where a country stood in 1950 says nothing about today. It reacts to shocks, like Syria or Ukraine, and in rich countries it fills the gap that low fertility leaves. That answers Question one.

*Notas de producción:* las trayectorias de regiones usan los **agregados ONU por región SDG** (ya ponderados, sin doble conteo); se dice en el pie "UN regional aggregates". Escala log en x con etiquetas 10/30/100/300. La anotación de VIH se coloca en el "retroceso" de LEx de África austral (si se usa LEx en vez de Q5 en el eje; decidir en figures-static: preferir **Q5** para que el eje sea "child deaths"). Las correlaciones por ingreso (heatmap de acoplamiento) **no entran** en el vídeo; se citan en el notebook y en el apéndice del repositorio.

---

## 4. Slide 3 — Question 2: *Can one number tell the whole story?* (2:45–3:45) · P8 · P5

**Título:** `Question 2 · Can a single indicator tell the whole story?`
**Mensaje de una línea (build 3):** `One number tells the slow story (age structure, 2050 outlook) — not today's growth, and not migration.`

**Layout (3 elementos visuales, nunca más):** izquierda 38 % = scorecard; centro 24 % = tarjetas gemelas; derecha 38 % = PCA. Una franja de texto de una línea para P5 bajo el PCA. Nada más en la página PDF.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig06_single_indicator_scorecard.mp4`** (6 s): "What fertility alone can explain" — cuatro barras horizontales (R² ajustado, 161 países ≥ 1 M, 2023) que crecen una a una: `Age structure today (median age) → {r2_tfr_medage}` ; `Population change 2023→2050 (UN projection) → {r2_tfr_chg2050}` ; `Growth rate today → {r2_tfr_growth}` ; `Net migration today → {r2_tfr_cnmr}`. Las dos primeras en azul ("slow story"), las dos últimas en bermellón ("fast levers"). Nota al pie: `R² = share of country-to-country differences explained · adding deaths + migration lifts today's growth to {r2_all} — an accounting identity (births − deaths + migration), shown for completeness`. | barras con % | 2:45–3:02 |
| **2** | **`fig07_twin_countries.png`** / tarjetas HTML con banderas (`flag-icons`): pares elegidos por regla desde `numbers.json: twins` (misma TFR ± 0.05 y máxima diferencia de crecimiento; misma LEx ± 0.2 y máxima diferencia de edad mediana; ≥ 1 M). Provisional: `UAE · Belarus — same fertility 1.20 vs 1.21 → growth +3.7 % vs −0.65 %`; `Jordan · Bosnia — same life expectancy 77.8 vs 77.9 → median age 24 vs 45`. Flechas opuestas (↑ ↓). | tarjetas | 3:02–3:16 |
| **3** | **`fig09_pca_biplot.mp4`** (8 s): puntos = países (≥ 1 M, 2023) coloreados por región SDG; aparece primero el eje PC1 `Axis 1 — the transition ({pc1_var}%)` con las flechas TFR/LEx/median age; después el eje PC2 `Axis 2 — migration & sex ratio ({pc2_var}%)` y se iluminan los Estados del Golfo (arriba) y las islas con emigración (abajo). Texto: `{n_pcs_70} axes needed for 70 %`. Debajo, **una línea para P5**: `Composite index (5 indicators, 7 designs): coherent (α = {alpha}) but {share_rank_shift_20} % of countries move > 20 ranks — design choices must be declared`. Mensaje de una línea + sello `Question 2 answered (P8, P5)`. | ejes con %, línea P5, sello | 3:16–3:45 |

**Se omite en la diapositiva (vive en el notebook y en `figures/appendix/`):** la línea ρ(CDR, LEx) que cambia de signo (su mensaje pasa a la recomendación de "fast movers" en la Slide 4: *measure mortality with life expectancy, not crude death rate*), el bump chart de rangos del índice (P5 queda como línea de texto) y la matriz de correlación.

**Narración (128 palabras):**
> Question two: can one number tell the story? Take fertility, the most quoted indicator. Across countries over a million people it tells the slow story well: seventy-seven percent of today's age structure, nearly ninety percent of the 2050 outlook. But it explains only fifty-nine percent of today's growth, and almost nothing of migration — the levers that move fastest. The United Arab Emirates and Belarus have the same fertility, 1.2 children per woman; one grows 3.7 percent a year, the other shrinks. Jordan and Bosnia share a life expectancy of 78, with median ages of 24 and 45. A principal component analysis agrees: the transition axis captures only 46 percent; migration is an axis of its own. One number tells the slow story — not the whole one.

*Notas de producción:* el scorecard sustituye a la "escalera" 0.59 → 0.70 → 0.99 porque esa escalera es la identidad contable y un jurado puede verla como trivial; la identidad se cita solo en la nota al pie. El R² del cambio 2023→2050 es **sobre la proyección Medium**, que la propia ONU construye a partir de supuestos de fecundidad: decirlo en la nota ("partly by construction") y en el notebook. Fijar **un único conjunto de variables para el PCA** antes de narrar el porcentaje (el catálogo de visualización obtuvo 64 % con 8 variables y el EDA 46 % con 13: el guion usa el valor que salga del conjunto definitivo de 12 variables del plan, §4-Q2). Banderas con `flag-icons` (SVG en el HTML); en el PNG de respaldo, `ggflags` (ya instalado) o códigos ISO3.

---

## 5. Slide 4 — Question 3: *Four roads — and what the UN should watch on each* (3:45–5:00) · P6 · P1 · Recomendaciones · Ética

**Título:** `Question 3 · Four roads through the transition — and the lever to watch on each`
**Mensaje de una línea (build 3):** `Countries cluster by how they moved, not where they are: each road needs a different lever, now.`

**Layout:** builds 1–2 a pantalla completa (mapa + trayectorias); build 3 la tabla de recomendaciones se superpone a la derecha (el mapa se encoge a la izquierda); build 4 franja de ética abajo.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig11_trajectory_clusters.mp4`** (10 s): izquierda, mapa de 161 países ≥ 1 M coloreado por tipo de trayectoria (4 colores Okabe-Ito distintos a los de la Slide 1); derecha, 4 pequeños múltiplos (`children per woman` y `median age` 1950 → 2023) donde las líneas de cada tipo se dibujan progresivamente; la mediana del tipo en grueso. Nombres por comportamiento **asignados después de ver los centroides** (`numbers.json: cluster_names`, provisionales: **Early movers** · **Fast movers** · **Late movers** · **{group4_name}**). Cada panel lleva 3 banderas de ejemplo tomadas de `numbers.json: cluster_examples` (regla: los 3 más poblados del grupo; provisionales FR/JP/US · CN/BR/TR · NG/PK/ET · AE/SA/JO) y el número de países/población. | 4 nombres + n | 3:45–4:05 |
| **2** | Anotación de **P1** en el panel de edad mediana: banda P10–P90 entre países que se abre (`fig12_ageing_fan.png`): `Median age gap between countries doubled (SD {sd_medage_1950} → {sd_medage_2023} years)`; y `Life expectancy at 60: countries are pulling apart (SD {sd_le60_1950} → {sd_le60_2023})`. Nota: `Weak separation (silhouette {silhouette}) — a continuum, not boxes`. | anotaciones | 4:05–4:15 |
| **3** | **Tabla "Which lever, where, when"** (HTML, aparece fila a fila con icono de agencia): <br>• **Late movers** (~{n_late} countries, {pop_late} bn) → *child survival & rights-based reproductive health; plan school/job cohorts 2035–2050* → UNFPA · UNICEF · **by 2040** <br>• **Fast movers** (~{n_fast}, {pop_fast} bn) → *pension & health systems for a median age of 45 by 2050; measure mortality with life expectancy, not crude death rate* → UN DESA · WHO · **within 20 years** <br>• **Early movers** (~{n_early}) → *migration governance & integration; healthy longevity (old-age gap widening)* → IOM · WHO · **now** <br>• **{group4_name}** (~{n_group4}) → variante (i): *migrant rights & data; contingency for flow reversals* → IOM · ILO · **ongoing** / variante (ii): *fastest ageing on record: pension & health systems first* → UN DESA · WHO · **by 2035** | tabla | 4:15–4:40 |
| **4** | Franja de **ética y límites** (iconos): `Estimates ≤ 2023 vs UN medium projection ≥ 2024 · descriptive, not causal · income groups = World Bank FY2026 applied to all years · countries ≥ 1 M for models · groups describe behaviour, not development · ASA Ethical Guidelines 2022 · code & data: github.com/{repo}`. Sello `Question 3 answered (P6, P1)`. | franja | 4:40–4:50 |
| **5** | Callback: el fondo se oscurece y aparece grande **`One number can't tell 8 billion stories — three levers, read region by region, can.`** | callback | 4:50–5:00 |

**Narración (build 1–3, 127 palabras):**
> Question three. Looking at seventy years of movement, not a single year, countries fall into four roads. Early movers — Europe, Japan, North America — changed slowly and now depend on migration. Fast movers — China, Brazil, Iran, Türkiye — went from six children per woman to under two in fifty years, and will age faster than anyone before: median age forty-five by 2050. Late movers — most of sub-Saharan Africa, Pakistan, Afghanistan — are where child survival is still the lever that unlocks the rest. {group4_sentence} The groups overlap — a continuum, not boxes. For the UN, a watch-list: child survival and schooling in late movers before 2040; pension and health systems in fast movers within twenty years; migration governance and healthy longevity in early movers.

**Narración (builds 4–5, cierre, 50 palabras):**
> Everything follows the ASA ethical guidelines: estimates and projections are kept apart, no causal claims, and every number is reproducible from our public repository. So — one number can't tell eight billion stories. But three levers, read region by region, can tell the UN where to look next. Thank you.

*Notas de producción:* **`{group4_sentence}` se elige tras el clustering** (obs. del orquestador: en el EDA el cuarto grupo mezclaba el Golfo con las dos Coreas, Jordania y Yibuti porque lo define la *velocidad* del cambio, no la migración; Corea del Norte no recibe inmigrantes). Dos variantes pre-escritas: (i) si el grupo se define por migración: *"Migration-boosted states — the Gulf — depend on flows that can reverse."*; (ii) si se define por velocidad: *"Sprinters — the Gulf, South Korea, Jordan — made the fastest change on record, in under forty years."* La fila correspondiente de la tabla de recomendaciones cambia igual (variante ii: *prepare pension/health systems earlier than anyone; monitor migrant flows where they dominate*). La tabla de recomendaciones es HTML nativo (no imagen) para que sea legible en el PDF. Las cifras de "median age 45 by 2050" y los tamaños de grupo salen de `numbers.json` (`medage_fast_2050`, `n_fast`, …). Si la silueta final es < 0.2, mantener la frase "a continuum, not boxes" (es un hallazgo honesto, no un fallo). Verbos permitidos en recomendaciones: *watch, plan, invest, measure, prepare*; prohibidos: *reduce fertility, control, drive, cause*.

---

## 6. References (sin narración; se muestra 2–3 s al final o como última página del PDF)

```
Data
• United Nations, DESA, Population Division (2024). World Population Prospects 2024, Online Edition. CC BY 3.0 IGO. https://population.un.org/wpp/
• WPP2024 Supplement (Births by sex, LE60) — prepared by the DataQuest organisers from the UN Data Portal.
• World Bank (2025). World Bank Country and Lending Groups, FY2026 (API download 2026-10-22).
Methods & ethics
• American Statistical Association (2022). Ethical Guidelines for Statistical Practice. https://doi.org/10.5281/zenodo.7092386
• Webb, J. W. (1963). The natural and migrational components of population changes in England and Wales. Economic Geography 39(2).
• Barro, R. & Sala-i-Martin, X. (1992). Convergence. Journal of Political Economy 100(2).  [β/σ-convergence]
Software
• R 4.6.1; ggplot2, dplyr, tidyr, tweenr, gghighlight, ggrepel, patchwork, maps, countrycode, cluster, fpc, FactoMineR/prcomp, fixest (optional); reveal.js 5; flag-icons; ffmpeg (static).
Reproducibility
• Code, notebook and figures: github.com/{repo} (MIT); every number on these slides is generated by notebook/analisis_wpp2024.ipynb → figures/numbers.json.
```

---

## 7. Tabla de cifras usadas en el guion → clave en `numbers.json` (QA-stats marca cada una como ✔ cuando el valor final coincide con lo narrado)

| Cifra narrada | Clave | Valor provisional | Origen provisional |
|---|---|---|---|
| 8 billion / 8.1 | `world_pop_2023_bn` | 8.09 | Medium, LocID 900, 2023 |
| 130 countries below replacement | `n_below_replacement_2023` | 130 | TFR < 2.1, 237 países |
| 79 still growing (natural change > 0) | `n_below_repl_growing_2023` | 79 | TFR < 2.1 & NatChange > 0 |
| 18 grow only via migration | `n_grow_only_migration_2023` | 18 (11 ≥ 1 M) | NatChange < 0 & PopChange > 0 |
| 71 % of high-income growth = migration (2000–23) | `share_mig_high_2000_2023` | 71 | Σ países WB High income |
| Europe took a century / Asia & LAC ≈ 50 years | `yrs_eu`, `yrs_asia`, `yrs_lac` | pendiente (TFR 5 → 2.5 en agregados; Europa censurado en 1950 → usar "more than a century" solo si el agregado 1950 ya < 5, en cuyo caso reformular a "started before 1950") | agregados SDG |
| median lag 11 years, 80 % mortality first | `lag_median`, `share_mort_first`, `n_lag` | 11 / 80 / 89 | ≥ 1 M, cruces > 1950 |
| β migration ≈ −1 | `beta_cnmr`, `beta_tfr`, `beta_imr` | −0.96 / −0.64 / −0.84 | 1950–2023 |
| 77 % age structure / ~90 % 2050 outlook / 59 % growth today / ~0 migration (fertility alone) | `r2_tfr_medage`, `r2_tfr_chg2050`, `r2_tfr_growth`, `r2_tfr_cnmr` | 0.771 / 0.881 / 0.592 / ≈ 0.06 (verificar) | ≥ 1 M, 2023; 2050 = proyección Medium |
| 99 % with the three levers (footnote only) | `r2_all` | 0.986 | identidad contable |
| examples per lever type (narrated) | `examples_type_C/D/E`, `cover_flags` | DE, ES, FI / JP, IT, KR / NP, UY, AL | top-3 por población, ≥ 1 M |
| cluster names, examples, sentence for group 4 | `cluster_names`, `cluster_examples`, `group4_name`, `group4_sentence` | decididos tras el clustering | notebook §Q3 |
| UAE vs Belarus 1.20/1.21; +3.7 % / −0.65 % | `twin_tfr_*` | ver EDA c.85 | 2023 |
| Jordan vs Bosnia 77.8/77.9; 24 vs 45 | `twin_lex_*` | ver EDA c.85 | 2023 |
| ρ(CDR, LEx) −0.96 → +0.06 | `rho_cdr_lex_1950`, `rho_cdr_lex_2023` | −0.96 / +0.06 | ≥ 1 M |
| PC1 46 %; 3 axes for 70 % | `pc1_var`, `pc2_var`, `n_pcs_70` | 46 / 16 / 3 | PCA 2023 |
| α 0.93; 24 % move > 20 ranks | `alpha`, `share_rank_shift_20` | 0.93 / 24 | 7 versiones |
| six children → under two in fifty years (fast movers) | `tfr_fast_1950`, `tfr_fast_2023` | 6.4 → 1.8 | cluster |
| median age 45 by 2050 (fast movers) | `medage_fast_2050` | ≈ 45 (verificar; el EDA da 44.8 para el agregado ingreso medio-alto) | proyección Medium |
| SD median age 5.0 → 9.8; SD LE60 1.8 → 3.2 | `sd_medage_*`, `sd_le60_*` | EDA c.59 | 237 → repetir con ≥ 1 M |
| silhouette | `silhouette` | ≈ 0.23 | k = 4 |

---

## 8. Reglas de estilo para pantalla y subtítulos

- Resolución 1920×1080; márgenes seguros 64 px; tipografía **Lato** (títulos Black 44–56 px, cuerpo 28–32 px, pie 18 px); subtítulos en barra inferior semitransparente, 34 px, ≤ 2 líneas, sincronizados con cada build (`data-fragment-index`).
- Rótulo fijo arriba a la izquierda: `Question N` (+ `P7 · P4` en gris 18 px); pie fijo: `UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey)`.
- Cada gráfica: título = mensaje (frase), no el nombre de la variable; etiquetas directas en las líneas; sin leyendas separadas cuando haya ≤ 8 series; unidades en el eje; línea vertical punteada en 2023/24 en toda serie que cruce.
- Paleta regiones SDG (8, accesible): Okabe-Ito extendido; paleta de tipos de palanca y de clusters distintas entre sí (ver `00_plan_implementacion.md`).
- Nada de jerga sin frase explicativa: R², PCA, β, silhouette, replacement fertility, net migration — todas tienen su "= …" en pantalla la primera vez.
- Lo que se nombra en la voz se **resalta** en la gráfica en el mismo instante (gghighlight / fragmento / flecha), nunca después.

---

## 9. Versión PDF estática de cada diapositiva (todos los builds en una sola página)

Regla general: la página PDF muestra **el estado final** de la diapositiva (todos los fragmentos visibles) con **≤ 3 elementos visuales + 1 mensaje de una línea + rótulo "Question N"**; todo lo que sea transitorio (tarjetas de preguntas del build 0, zooms, callbacks) lleva la clase reveal `fade-out`/`current-visible` o `.print-hide` y **no se imprime**. Cada MP4 tiene un **póster PNG** (último fotograma, 1920×1080) que se muestra en impresión (`<video poster=…>` + CSS `@media print { video { display:none } .poster { display:block } }`). Fuente mínima en impresión: 20 px (equivalente ≥ 11 pt en A4 apaisado).

| Página | Qué se imprime | Qué se oculta |
|---|---|---|
| Cover | Título, subtítulo, equipo, fuente + las tres cifras del gancho en una línea (`130 · 79 · 18`) | contador animado, puntos de fondo animados |
| Slide 1 | Ecuación (una línea) + póster de las barras apiladas 2010–23 con la anotación 71 % + mapa de palancas con leyenda y conteos + mensaje | tarjetas de las 3 preguntas (pasan a la Cover como línea pequeña "Three questions: …"), zoom Europa/Golfo (queda solo una viñeta inset del Golfo, estática) |
| Slide 2 | Póster del connected scatter (2023, con rastro completo y anotaciones) + dumbbell del rezago + panel β de "memoria" (solo el de migración, reducido) + mensaje | animación del año, flechas de VIH/COVID intermedias |
| Slide 3 | Scorecard (4 barras) + tarjetas gemelas + biplot con ambos ejes y la línea P5 + mensaje | nada más (ya son 3 visuales) |
| Slide 4 | Mapa de grupos + 4 pequeños múltiplos (estado 2023) + tabla "which lever, where, when" + franja de ética (texto 20 px) | callback final, animación progresiva |
| References | lista completa (§6) | — |

Cómo se genera: `slides/index.html?print-pdf` en Chromium headless (`--print-to-pdf`, 1920×1080 → 16:9), con `pdfSeparateFragments: false` y `pdfMaxPagesPerSlide: 1` en la configuración de reveal. QA-slides cuenta páginas (= 6), comprueba que no se corta nada y lee cada página al 50 % de zoom.
