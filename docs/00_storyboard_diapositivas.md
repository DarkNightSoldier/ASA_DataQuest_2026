# 00 — Storyboard de diapositivas y guion del vídeo (5:00)

> **Versión 2 — integración de asesorías (2026-10-22/23) — cambios principales**
> 1. Gancho: **130 → 84 crecen = 66 por saldo natural + 18 solo por inmigración neta** (2023, una sola definición en todo el vídeo; rango 15–25 según el año).
> 2. Slide 1: paleta sin semáforo, mapa `sf` + Robinson, anotación de **inercia** (22 países bajo reemplazo, 2,2 mil M), ejemplos por regla (C = Germany, Spain, Belgium · D = China, Russia, Japan · E = Nepal, Azerbaijan, Uruguay) e **incertidumbre visible una vez**: fan chart de EAU 2050 (8,9–33,3 M).
> 3. Slide 2: el connected scatter y el dumbbell salen; entran **registro por hitos** ("same road, different speed" literal), **mortalidad primero en 105/108, al menos 22 años**, año de inicio de la caída de la TFR por ingreso y **mini-forest dentro vs entre países** (−0,41 vs −1,05). Migración: *"a short memory and almost no neighbourhood, except in the Gulf"*.
> 4. Slide 3: la **prueba de parecidos** (look-alikes, Colombia) es la demostración central de P8; PCA narrado como "two real dimensions"; P5 = Monte Carlo ("one country in five can move twenty places"); α fuera de pantalla.
> 5. Slide 4: India en *Fast movers*; nombres **Early · Fast · Recent movers · Migration-led**; "two in three neighbouring countries share the same road (chance: one in three)"; mensaje sin "not where they are"; P1 con razón P90/P10 de Q5; tabla por estado de la palanca; tarjetas de ética.
> 6. Sin logos de la ONU; sin lenguaje causal; proyecciones = escenarios; ≤ 3 visuales por diapositiva; narración **654 palabras** (contadas con `wc -w`, cifras como una palabra; ≈ 700 habladas, ≈ 4:52 a 142 ppm).
> Registro de decisiones: `docs/07_integracion_asesorias.md`. Hipótesis: `docs/hipotesis_preinscritas.md`.

> Texto de diapositivas, subtítulos y narración **en inglés**; notas de producción **en español**.
> Formato final: **portada + 4 diapositivas de contenido + referencias**. Cada diapositiva de contenido tiene *builds* (fragmentos reveal.js) que se graban como animación pero se imprimen como **una sola página** (`pdfSeparateFragments: false`).
> Toda cifra entre llaves `{clave}` se resuelve desde `figures/numbers.json`. Los valores provisionales (§7) llevan su origen: **[03]** hechos verificados en R, **[ST] [MV] [FDA] [DEM] [PN] [INF] [SP] [ET]** memos de asesoría, **[INT]** comprobado en R por el integrador (2026-10-22). Se sustituyen por los finales antes de grabar.

---

## 0. Línea de tiempo del vídeo (objetivo 4:50 ± 5 s)

Recuento con `wc -w` sobre el texto con los valores provisionales sustituidos (cada cifra = 1 palabra). Las cifras se leen con más palabras ("one hundred thirty"): estimación ≈ 700 palabras habladas. Si la lectura real cronometrada pasa de 4:50, `script-narration` recorta en este orden: (1) la frase de Colombia, (2) la de EAU–Bielorrusia, (3) "Neighbours tend to share a road…"; **nunca** las respuestas a Q1–Q3.

| Tiempo | Diapositiva | Sección | Palabras |
|---|---|---|---|
| 0:00–0:24 | Cover | Gancho 130 → 84 (66 + 18) + equipo | 54 |
| 0:24–0:49 | Slide 1 (build 0) | Tres preguntas + tarjeta de datos | 59 |
| 0:49–1:38 | Slide 1 (builds 1–5) | **Question 1** — balance, descomposición por ingreso, mapa 2023, inercia, EAU | 107 |
| 1:38–2:35 | Slide 2 | **Question 1 (cont.)** — reloj propio, mortalidad primero, dentro vs entre, migración | 121 |
| 2:35–3:31 | Slide 3 | **Question 2** — scorecard, gemelos + look-alikes, dos dimensiones, índice | 126 |
| 3:31–4:28 | Slide 4 (builds 1–3) | **Question 3** — cuatro caminos, vecinos, P1, watch-list | 129 |
| 4:28–4:52 | Slide 4 (builds 4–5) → References | Ética + callback | 58 |
| | | **Total** | **654** |

Respuesta explícita a las preguntas del profesor: **P7 = Question 1** (Slides 1–2; rótulo "Question 1 · P7 · P4" y "Question 1 · P7 · P1"); **P8 = Question 2** (Slide 3, "Question 2 · P8 · P5"); P6 + P1 en Slide 4; P2/P3 como banda de incertidumbre de EAU en la Slide 1. Rótulo "Question N" arriba a la izquierda; códigos P en gris 18 px.

---

## 1. Cover (0:00–0:24)

**Título:** `One Number Can't Tell 8 Billion Stories`
**Subtítulo:** `Births, deaths and migration in 237 countries and areas — UN estimates 1950–2023, projections to 2100 — and where the UN should look next`
**Línea inferior:** `Team {team_name} · ASA International DataQuest 2026 · Data: UN DESA, World Population Prospects 2024 (CC BY 3.0 IGO)` — **sin logos** de la ONU ni de agencias.

**Builds (auto):**
1. (0:00) Fondo: puntos tenues, un punto por país (`fig00_world_dots.png`); contador `{world_pop_2023_bn} billion` (2.5 → 8.1).
2. (0:05) `{n_below_replacement_2023} of 237 countries and areas: fertility below replacement` + nota 18 px `replacement ≈ 2.1 children per woman where almost every child survives`; esos puntos se tiñen.
3. (0:11) `{n_below_repl_growing_2023} still growing` → se divide en `{n_below_repl_natural_growth_2023} births > deaths` (azul #0072B2) y `{n_grow_only_migration_2023} only through net arrivals` (celeste #56B4E9) con **tres banderas = `cover_flags`** (regla: los 3 más poblados ≥ 1 M del tipo C en 2023 → DE, ES, BE) y su ISO3.
4. (0:19) `One number can't explain that.` → fundido al título.

**Narración (54):**
> Eight billion people. In 2023, {n_below_replacement_2023} of 237 countries and areas had fertility below replacement, about 2.1 children per woman. You would expect them to shrink. Yet {n_below_repl_growing_2023} are still growing: {n_below_repl_natural_growth_2023} because births still outnumber deaths, {n_grow_only_migration_2023} only because more people arrive than leave. One number can't explain that. We are Team {team_name}.

*Notas:* 130 / 84 / 66 / 18 verificados en R [DEM][INT]. "because" se usa en sentido **contable** (marcar en `qa_etica.csv`). No usar "converge" ni "pathways" en portada (01b §6).

---

## 2. Slide 1 — Question 1: *Which lever moves each country's population?* (0:24–1:38) · P7 · P4

**Título:** `Question 1 · Which lever moves each country's population: births, deaths or migration?`
**Mensaje de una línea (build 5):** `Today's high-income countries: about 7 in 10 of growth since 2000 came from net migration; elsewhere, from births. In {n_grow_only_migration_2023} countries, deaths already outnumber births and net arrivals keep them growing.`

**Visuales (3):** (1) `fig01` descomposición por ingreso; (2) `fig02` mapa de palancas con zoom; (3) `fig03` fan chart de EAU (inset en el zoom al Golfo).
**Layout:** izquierda 42 % (barras), derecha 58 % (mapa); en el build 5 el mapa hace zoom al Golfo y el inset de EAU ocupa la esquina inferior derecha.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **0** | Tres tarjetas con las preguntas (iconos neutros: balanza, lupa, carretera). Debajo, **tarjeta de datos sin logo**: `237 countries and areas (195 states + 42 territories) · models use the 161 with ≥ 1 M people · UN estimates 1950–2023 · UN medium projection 2024–2100 (grey: a scenario, with uncertainty) · Net migration = arrivals − departures, the least-measured component · Source: UN DESA Population Division (2024), CC BY 3.0 IGO` | `Question 1 … Question 2 … Question 3 …` | 0:24–0:49 |
| **1** | Las tarjetas se encogen a la barra superior ("Q1" resaltado). **Ecuación animada**: `Population change = births − deaths + net migration` + `Lever = a component of the population balance, not a policy switch.` | ecuación + definición | 0:49–0:55 |
| **2** | **`fig01_growth_components_by_income.mp4`** (8 s): barras apiladas por grupo de ingreso (`Low`, `Lower-middle`, `Upper-middle`, `High` — World Bank FY2027), una década por fotograma 1950s → 2010–23; **natural change = azul #0072B2**, **net migration = celeste #56B4E9** (negativa hacia abajo); China (en Upper-middle) e India (en Lower-middle) como segmento con borde blanco y etiqueta. Se congela en 2000–23 y aparece la flecha: `Today's high-income countries (World Bank FY2027), 2000–2023: net migration ≈ {share_mig_high_2000_2023} % of population change` + gris 16 px `64–78 % depending on classification vintage and period · a shared calendar, not country-by-country compensation`. Eje y = millones de personas, cero marcado. | anotación con flecha | 0:55–1:06 |
| **3** | **`fig02_lever_map_2023.png`** (`sf` + Robinson, marco 58° S–85° N) se dibuja por tipo: **azul #0072B2** *growing from births* · **celeste #56B4E9** *growing only through net arrivals* · **naranja #E69F00** *shrinking: deaths > births* · **púrpura rojizo #CC79A7** *shrinking: more leave than arrive* · gris #999999 *small states (< 1 M)* en franja inferior con ISO3. Leyenda en fila con conteos `{n_type_AB} · {n_type_C} · {n_type_D} · {n_type_E}` y nota gris `light blue: {n_grow_only_migration_2023} in 2023 (15–25 depending on the year)`. Mientras la voz dice "including 22 below replacement", se resaltan (contorno grueso) los países de inercia con la etiqueta `Below replacement, still growing from births: {n_momentum_countries} countries, {pop_momentum_bn} bn people` y banderas de `examples_momentum` (IN, BR, MX). | leyenda con conteos; etiqueta de inercia | 1:06–1:21 |
| **4** | Los ejemplos narrados se iluminan con bandera + ISO3 en el instante en que se nombran: `examples_type_C` (DEU, ESP, BEL), `examples_type_D` (CHN, RUS, JPN), `examples_type_E` (NPL, AZE, URY). Nota 16 px: `Examples chosen by rule: the three largest countries of each type (≥ 1 M)`. | banderas | 1:21–1:29 |
| **5** | **Zoom animado** (`fig02b_lever_map_zoom.mp4`, 4 s: Europa → Golfo, interpolando `xlim/ylim` de `coord_sf` en metros Robinson con `tweenr`). En el Golfo: `UAE 2023: net migration +{cnmr_are_2023} per 1,000 · growth {growth_are_2023} %/yr · fertility {tfr_are_2023}` + nota `The UN revised the UAE's 2023 population by +{are_revision_pct} % between its 2022 and 2024 editions`. Aparece el inset **`fig03_uae_fan_2050.png`**: población de EAU 1950–2100, estimación en negro hasta 2023, línea 2023/24, Medium con bandas 80/95 %, línea punteada naranja "if net migration were zero"; texto `2050: {pop_are_2050} M · UN 95 % range {pop_are_2050_pi95_low}–{pop_are_2050_pi95_high} M` y gris `77 of 161 countries: the UN 95 % range for 2050 includes both growth and decline`. Mensaje de una línea + sello `Question 1 · part 1`. | zoom, inset, mensaje | 1:29–1:38 |

**Narración (build 0, 59):**
> Three questions. One: which lever moves each country's population, births, deaths or migration, and does that depend on region and income? Two: can one indicator tell the whole story? Three: do countries travel the same road at different speeds, and what should the UN watch on each? Grey always means the UN medium projection: a scenario, not a forecast.

**Narración (builds 1–5, 107):**
> Population change is bookkeeping: births minus deaths, plus net migration. In today's high-income countries, net migration accounted for about seven in ten of the growth since 2000; elsewhere, growth came almost entirely from births exceeding deaths. Blue: growing from births, including {n_momentum_countries} below replacement, home to {pop_momentum_bn} billion people. Light blue: deaths exceed births, yet arrivals keep the population growing: {examples_type_C}. Orange: deaths exceed births and the population shrinks: {examples_type_D}. Purple: more people leave than arrive: {examples_type_E}. Migration is also the least certain lever: the UN's own 95 percent range for the Emirates in 2050 runs from {pop_are_2050_pi95_low} to {pop_are_2050_pi95_high} million.

*Notas de producción:* la descomposición usa **sumas de países** por grupo FY2027 (coinciden con el mapa); test: suma de grupos + "Not classified" = World. **No** comparar con los agregados de ingreso de la ONU (otra clasificación) salvo en la nota "64–78 %". Ejemplos e inercia salen de `R/05_numbers_json.R` (regla en código); QA-stats comprueba que cada país nombrado tiene ese tipo en 2023. "seven in ten" = `share_mig_high_2000_2023.say`. Inercia: 22 = tipo B (NetMigrations ≤ 0) con TFR < 2,1; 18 tienen emigración neta estricta y 4 (BRN, ATG, KNA, LCA) migración neta 0 → por eso la voz dice "growing from births", no "despite emigration" [INT]. Mapa: `rnaturalearth::ne_countries(scale = "medium")` + `st_transform("+proj=robin")` + ajustes ONU del memo espacial (Crimea → UKR, departamentos franceses de ultramar separados, Somalilandia → SOM, Chipre del Norte → CYP, Siachen neutro) + nota `Boundaries and names shown do not imply official endorsement or acceptance by the United Nations.` + `Map: Natural Earth`. Badges: PIE-0 + PIE-1 (mapa), PIE-4 (barras), PIE-5 + PIE-6 (inset EAU). El chip espacial "the Gulf is the only clear migration neighbourhood" **no** entra aquí (va al notebook).

---

## 3. Slide 2 — Question 1 (cont.): *Same road, different speed — child mortality fell first* (1:38–2:35) · P7 · P1

**Título:** `Question 1 · Same road, different speed: child mortality fell first`
**Mensaje de una línea (build 4):** `Child mortality began to fall first in {n_mort_first_onset} of {n_onset} high-fertility countries; afterwards fertility and child mortality moved together. The road is shared; the speed is not.`

**Visuales (3):** (1) `fig04` registro por hitos (animación); (2) `fig05` mortalidad primero (event time); (3) `fig06` mini-forest dentro vs entre. **Chip de texto** (no es visual) para la migración.
**Layout:** izquierda 55 % (fig04, luego se reduce a 40 % cuando entra fig05 a su derecha); franja inferior 100 % para fig06 + chip.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig04_same_road_registration.mp4`** (8 s): panel A = TFR suavizada de los {n_cruce_tfr4_obs} países que cruzaron 4 entre 1950 y 2023, en año calendario (gris; resaltados con etiqueta ISO3 los de la regla: el más rápido, el mediano y el más lento en 5 → 3 entre los ≥ 10 M — provisional KOR, IND, KEN); las curvas **se deslizan horizontalmente** hasta alinearse en τ = 0 = año del cruce de 4 (panel B): mediana gruesa + banda P10–P90 que se estrecha. Contador `calendar year → years since fertility fell below 4`. Al final, línea de velocidad: `5 → 3 children: China {dur53_chn} years · Egypt {dur53_egy} years` | `Same road, different clock: aligning on the year fertility fell below 4 removes {pct_var_fase} % of the gaps between countries` · gris `{n_cens_der} countries, mostly in sub-Saharan Africa, have not crossed 4 yet and are not shown; {n_cens_izq} were already below 4 in 1950` | 1:38–1:58 |
| **2** | **`fig05_mortality_first_event_time.png`**: mismo reloj (τ = años desde que la TFR **empezó** a caer), medianas + RIC de Q5 (naranja #E69F00 = defunciones) y TFR (azul #0072B2 = nacimientos) como % de su propio máximo; Q5 ya baja desde τ = −25. Flecha en τ = 0: `child mortality had already fallen by about half ({q5_drop_at_tfr_onset} %)`. | `Child mortality began a lasting fall first in {n_mort_first_onset} of {n_onset} high-fertility countries ({share_mort_first} %) — at least {lag_onset_lower_bound} years earlier` · `Fertility began to fall: ~{yr_fert_onset_upmid} in today's upper-middle-income countries · {yr_fert_onset_lowmid} lower-middle · {yr_fert_onset_low} low-income` · gris `n = {n_onset}; child mortality was already falling in 1950 in {n_q5_falling_1950}, so the gap is a lower bound · income groups = World Bank FY2027 (today)` | 1:58–2:16 |
| **3** | **`fig06_within_vs_across_forest.png`** (mini-forest, 5 filas: All + 4 grupos de ingreso): punto negro = asociación **dentro del mismo país** (cambios de 5 años, efectos fijos de país y periodo, IC 95 % por país); línea gris discontinua vertical = **entre países** ({panel_between_halfq5}); banda gris clara = placebo. Se resalta la fila `Low income`. | `Within the same country, halving child mortality goes with {panel_within_halfq5} children per woman over the next 20 years — across countries, {panel_between_halfq5}` · gris `clearest in sub-Saharan Africa ({panel_ssa_halfq5}); not detected in Europe & N. America · each country counts once · association, not cause` | 2:16–2:29 |
| **4** | **Chip de migración** (texto, dos columnas): `Migration: a short memory and almost no neighbourhood` · `decade to decade: births & deaths ≥ {r_tfr_decades_min} · migration {r_cnmr_decades_recent}` · `between neighbours: fertility {moran_tfr_2023} · migration {moran_cnmr_2023} ({moran_cnmr_2023_nogulf} without the Gulf)`. Mensaje de una línea + sello `Question 1 answered (P7, P4)`. | chip, mensaje, sello | 2:29–2:35 |

**Narración (121):**
> Put each country on its own clock, years since its fertility fell below four, and the curves collapse onto one road. The road is shared; the speed is not: China went from five to three children in {dur53_chn} years, Egypt in {dur53_egy}. Child deaths moved first: in {n_mort_first_onset} of {n_onset} high-fertility countries, child mortality began a lasting fall at least {lag_onset_lower_bound} years before fertility. Fertility began falling around {yr_fert_onset_upmid} in today's upper-middle-income countries, {yr_fert_onset_lowmid} in lower-middle and {yr_fert_onset_low} in low-income ones. Within a country, halving child mortality goes with about {panel_within_halfq5.say} fewer children, less than half the gap across countries. A sequence in time, not proof of cause. Migration has a short memory and almost no neighbourhood, except in the Gulf.

*Notas de producción:* fig04 es la única animación "de datos" larga del vídeo (receta: animar datos, no solo interfaz); ejes fijos entre fotogramas; país resaltado por regla, no a mano. fig05 combina el *event time* de `st01` y `fda_04`; el dumbbell y la rejilla de umbrales quedan en el notebook (`app_threshold_grid_lag.png`, `app_km_onset_income.png` = `inc04`). fig06 se deriva de `pn03` con 5 filas; SSA se dice en pantalla, no como fila. Colores: azul = nacimientos, naranja = defunciones (mismos significados que la Slide 1); forest en negro/gris (sin semántica). "Region and income" de P7: el ingreso está en fig05/fig06; la región en la fila SSA y en el chip. Frase espacial: el memo espacial proponía *"almost no memory and almost no neighbourhood"*; se fusiona con *"short memory"* de demografía (ver `07` §3). El connected scatter Q5–TFR por región pasa a `figures/appendix/app_connected_scatter_regions.png` (4 regiones resaltadas, flecha en 2023, contador gris tras 2023). Badges: PIE-0 + PIE-3; PIE-6 en el chip.

---

## 4. Slide 3 — Question 2: *Can one number tell the whole story?* (2:35–3:31) · P8 · P5

**Título:** `Question 2 · Can a single indicator tell the whole story?`
**Mensaje de una línea (build 4):** `One number tells the slow story (age structure), not the fast one (growth, migration): the data hold two real dimensions.`

**Visuales (3):** (1) `fig07` scorecard; (2) `fig08` tarjetas gemelo + look-alikes; (3) `fig09` dos dimensiones (biplot). Una franja de texto para P5.
**Layout:** izquierda 36 % scorecard; centro 28 % tarjetas; derecha 36 % biplot; franja P5 inferior.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig07_single_indicator_scorecard.mp4`** (6 s): *"What fertility alone can explain"* — 4 barras horizontales (R² ajustado, 161 países ≥ 1 M, 2023), declaradas a priori: `Age structure today (median age) {r2_tfr_medage}` · `Population change 2023→2050 (UN projection) {r2_tfr_chg2050}` · `Growth rate today {r2_tfr_growth}` · `Net migration today {r2_tfr_cnmr}`. Las dos primeras en azul ("slow story"), las dos últimas en gris oscuro ("fast levers"); intervalo por bloques de subregión como bigote fino. Pie 16 px: `R² = share of country-to-country differences explained · same in 10-fold cross-validation · 2050 change is partly by construction (UN projections build on fertility) · births − deaths + migration together reach {r2_all}: an accounting identity` y segunda línea `Even the death rate changed meaning: Portugal and Chad share it ({cdr_prt} vs {cdr_tcd}) but are {lex_gap_prt_tcd} years apart in life expectancy` | barras con valores | 2:35–2:51 |
| **2** | **`fig08_lookalikes_twins`** (tarjetas HTML con `flag-icons` + ISO3; póster PNG para el PDF). Arriba la **métrica**: `For the average country, fertility alone finds {knn_tfr} % of its 5 real look-alikes (12 indicators) · two axes: {knn_pc12} % · chance: {knn_chance} %`. Tarjeta A (gemelos por regla): `UAE · Belarus — same fertility {twin_tfr_are} vs {twin_tfr_blr} → growth +{twin_growth_are} % vs {twin_growth_blr} %` (flechas ↑ ↓). Tarjeta B: `Colombia — by fertility it looks like {lookalikes_col_tfr}; by 12 indicators, like {lookalikes_col_12}`. Notas 14 px: `twins chosen by rule from 12,880 pairs (≥ 1 M)` · `Colombia: our home country, shown as an illustration; all countries in the repository`. | métrica + 2 tarjetas | 2:51–3:11 |
| **3** | **`fig09_pca_two_dimensions.mp4`** (8 s): puntos grises (161 países), con resaltes solo para los Estados del Golfo (color Migration-led) y para Colombia y sus look-alikes; aparece el eje 1 con las flechas TFR/LEx/median age: `Axis 1 — the transition`; luego el eje 2: `Axis 2 — migration & sex ratio vs ageing`; inset pequeño del análisis paralelo (autovalores vs ruido). Texto: `{n_dims_parallel} axes beat noise · fertility ≈ axis 1 (r = {r_tfr_pc1}) · blind to axis 2 (r = {r_tfr_pc2})` y gris `axis 1 = {pc1_var} % of the variation (46–66 % depending on which indicators enter)`. | ejes, texto | 3:11–3:26 |
| **4** | **Franja P5**: `Composite index (5 indicators, 2,000 reasonable designs): weights, not formulas, decide — {share_rank_mc20} % of countries can move more than 20 places · a transition-stage index, not a ranking of development or well-being`. Mensaje + sello `Question 2 answered (P8, P5)`. | franja, mensaje, sello | 3:26–3:31 |

**Narración (126):**
> Question two: can one number tell the story? Take fertility. Across countries, it captures the slow story, three quarters of the differences in age structure, but only {r2_tfr_growth.say} percent of today's growth and almost nothing of migration. The Emirates and Belarus share the same fertility; one grows almost {twin_growth_are.say} percent a year, the other shrinks. Search each country's five closest look-alikes by fertility alone and you find only one in eight of its real look-alikes. By fertility, Colombia resembles {lookalikes_col_tfr.say}; by twelve indicators, {lookalikes_col_12.say}. The data hold two real dimensions: fertility sits on the first, the transition, and is blind to the second, migration. A composite index depends on its weights: one country in five can move twenty places.

*Notas de producción:* "three quarters" = `r2_tfr_medage.say`; "one in eight" = `knn_tfr.say`; "one country in five" = `share_rank_mc20.say`. Valores provisionales de la voz: "60", "4", "France or the United States", "Iran, Peru and Ecuador". La escalera 0,59 → 0,70 → 0,99 solo en el pie (identidad). El biplot **no** usa la paleta de regiones (para no reutilizar el azul de la Slide 1). Si falta tiempo, se recorta primero la frase de Colombia (−16 palabras) y la tarjeta B pasa a nota. El bump chart del índice (UKR, rango 3–68) y la matriz de correlación van al apéndice. Badges: PIE-0 + PIE-3.

---

## 5. Slide 4 — Question 3: *Four roads — and what the UN should watch on each* (3:31–5:00) · P6 · P1 · recomendaciones · ética

**Título:** `Question 3 · Four roads through the transition — and what to watch on each`
**Method strip (18 px, bajo el título):** `70 years × 4 indicators (decade averages) → k-means (k = 4) → checked with whole-curve analysis, 500 resamples and neighbours`
**Mensaje de una línea (build 3):** `Countries group by how they moved, not by where they stand today — neighbours tend to share a road, and each road has something different to watch.`

**Visuales (3):** (1) `fig10` mapa de caminos + pequeños múltiplos; (2) `fig11` divergencia (P1); (3) tabla HTML "What to watch, where, when". Tarjetas de ética (texto) en el build 4.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig10_trajectory_groups.mp4`** (10 s): izquierda, mapa `sf` Robinson de 161 países ≥ 1 M por grupo — **Early movers #332288 · Fast movers #117733 · Recent movers #DDCC77 · Migration-led #88CCEE** — con **rayado** en los países con estabilidad bootstrap < 0,8 y en los < 1 M (no clasificados); derecha, 4 pequeños múltiplos (`children per woman` y `median age`, 1950 → 2023, proyección gris): mediana del grupo + banda P10–P90 que se dibujan progresivamente; línea fina = país medoide. Etiqueta por panel: nombre, `{n}` países, `{pop} bn`, 3 banderas + ISO3 de `cluster_examples` (3 más poblados). | `Two in three neighbouring countries share the same road (chance: one in three)` · `Four in ten countries sit between two groups — a continuum, not boxes` | 3:31–3:54 |
| **2** | **`fig11_divergence_fan.png`** (dos paneles compactos, 161 países ≥ 1 M, estimaciones 1950–2023): banda P10–P90 entre países de **life expectancy** (se estrecha) y de **median age** (se abre); debajo, una línea: razón P90/P10 de la mortalidad < 5. | `Closer in life expectancy (SD {sd_lex_1950} → {sd_lex_2023} years), further apart in age (SD {sd_medage_1950} → {sd_medage_2023}) — and in relative child survival: the riskiest tenth of countries {q5_ratio_p90p10_1950}× → {q5_ratio_p90p10_2023}× the safest` · gris `life expectancy at 65: SD {sd_le65_1950} → {sd_le65_2023} years` | 3:54–4:05 |
| **3** | **Tabla "What to watch, where, when"** (HTML nativo, fila a fila, agencias en texto, sin iconos): ver tabla abajo. Mensaje de una línea. | tabla | 4:05–4:28 |
| **4** | **Tarjetas de ética** `How we kept it honest · ASA Ethical Guidelines (2022)` (5 tarjetas, ver abajo); se amplían al 40 % inferior durante la voz. Sello `Question 3 answered (P6, P1)`. | 5 tarjetas | 4:28–4:44 |
| **5** | Callback: fondo oscuro y grande **`One number can't tell 8 billion stories — but three, read region by region, can tell the UN where to look next.`** | callback | 4:44–4:52 |

**Tabla (build 3; texto en pantalla, ≥ 20 px en el PDF):**

| Countries where… | Road | Watch / prepare | Mandate | For | When |
|---|---|---|---|---|---|
| child deaths still fall too slowly — {n_sdg32_above_2030} of {n_sdg32_above} above 25 per 1,000 stay above it in 2030 even in the UN projection; {n_sdg32_on_pace} on pace | mostly Recent movers | child survival, newborn care; voluntary family planning; births to adolescent girls | SDG 3.2, 3.7 · ICPD | UNICEF · WHO · UNFPA | by 2030 |
| fertility is below replacement but the population still grows — {n_momentum_countries} countries, {pop_momentum_bn} bn | mostly Fast movers | 30–40 more years of growth in working and older ages; pensions and long-term care now; no pronatalist alarm | Decade of Healthy Ageing · SDG 1.3 | UN DESA · WHO · ILO | 2030–2060 |
| deaths already outnumber births — {n_natneg_2023} countries, {share_pop_natneg_2023} % of humanity; {n_natneg_2050} by 2050 (UN projection) | Early & Fast movers | healthy longevity; measure mortality with life expectancy, not the crude death rate | SDG 3.4 | WHO · UN DESA | now–2040 |
| net arrivals are the only source of growth — {n_grow_only_migration_2023} countries | Early movers | migrant inclusion; better arrival/departure data; read UN migration projections as scenarios | GCM obj. 1 & 16 · SDG 10.7 | IOM · UN DESA | now |
| more people leave than arrive — {examples_type_E} · and everywhere: census and civil registration | mixed | decent work, safe return, diaspora links; publish lever types with sensitivity windows | GCM obj. 2 & 19 · SDG 8.8, 17.19 | IOM · ILO · UNSD | now / 2030 census round |

**Tarjetas de ética (build 4; título + ≤ 12 palabras cada una + código ASA en gris):**
1. **Scenarios, not forecasts** *(B.2 · C.4)* — grey = UN medium projection; it contains no shocks; uncertainty shown for the UAE.
2. **Weakest data, said aloud** *(B.1 · D.10)* — net migration is often a census residual; UAE revised +{are_revision_pct} %.
3. **Patterns, not causes** *(C.2 · C.3)* — orders in time and associations within countries, not effects.
4. **Levers, not verdicts** *(A.8 · D.6)* — groups describe paths, not development or worth; positive migration is not "success".
5. **Open & checkable** *(B.3 · F.4)* — hypotheses fixed {hyp_file_date} (sha256 {hyp_file_sha256_short}) · examples by rule · AI use declared · github.com/{repo}

Pie 14 px: `ASA (2022), doi:10.5281/zenodo.7092386 · UN DESA (2024) WPP 2024 Methodology · World Bank FY2027 income groups applied to all years · countries ≥ 1 M for models · Map: Natural Earth; boundaries imply no UN endorsement`.

**Narración (builds 1–3, 129):**
> Question three. Grouping countries by seventy years of movement gives four roads. Early movers, such as {cluster_examples_early}, now grow mainly through migration, or shrink. Fast movers, {cluster_examples_fast}, changed within decades and are projected to age in about {yrs_medage30_40_recent} years what Europe took 40 to 50. Recent movers, such as {cluster_examples_recent}, still have high child mortality. A small migration-led group sits mostly in the Gulf. Neighbours tend to share a road, yet four in ten sit between two: a continuum, not boxes. And countries grew closer in life expectancy but further apart in age. For the UN: watch child survival where it falls too slowly, ageing where populations still grow below replacement, and migration data where growth depends on arrivals.

**Narración (builds 4–5, cierre, 58):**
> How did we keep it honest? Projections stay apart from estimates; examples are chosen by rule; hypotheses were fixed before the final run; patterns, not causes; and every number, and our use of AI, is documented publicly. One number can't tell eight billion stories, but three, read region by region, can tell the UN where to look next.

*Notas de producción:* los nombres de grupo salen de `cluster_names` (regla en `R/config.R`, §4 del plan de implementación); provisionales: Early = United States, Russia, Japan · Fast = India, China, Indonesia · Recent = Pakistan, Nigeria, Ethiopia · Migration-led = Saudi Arabia, Jordan, UAE [FDA][MV]. Si el notebook cambia la composición, la voz cambia con `numbers.json`. "four in ten" = `share_between_groups.say` (fanny, pertenencia máx. < 0,6) [MV]; "two in three … one in three" = `join_same_road` / `join_same_road_null` (0,67 / 0,30) [SP]. "about 25 years" = `yrs_medage30_40_recent` (24, países que cruzan edad mediana 30 en 1990–2023) frente a `yrs_medage30_40_early` (40,5) [DEM] — si el notebook lo calcula por grupo y difiere, se usa el del grupo. Si Nigeria aparece como bandera, pie de calidad `Nigeria: last census 2006`. Describir los grupos solo con variables externas (Q5, LE65, cambio 2023→2050, edad mediana 2050) y sin p-valores. La tabla es HTML nativo (legible en el PDF). Verbos permitidos: *watch, plan, measure, prepare, monitor*; prohibidos: *reduce fertility, control, drive, cause, unlock*. Las palabras "not proof of cause" y "patterns, not causes" son negaciones: se registran como excepción del grep en `qa_etica.csv`.

---

## 6. References (sin narración; 2–3 s al final y última página del PDF)

```
Data
• United Nations, DESA, Population Division (2024). World Population Prospects 2024, Online Edition. CC BY 3.0 IGO. https://population.un.org/wpp/
• UN DESA (2024). WPP 2024: Methodology of the UN population estimates and projections. UN DESA/POP/2024/DC/NO.10 · WPP 2024: Summary of Results. UN DESA/POP/2024/TR/NO.9 · Release note on 2022 vs 2024 revisions (11 Jul 2024) · WPP 2024 Interim Update (Togo), 19 Jan 2026.
• WPP2024 Supplement (births by sex, LE60) — prepared by the DataQuest organisers from the UN Data Portal.
• World Bank (2026). Country and Lending Groups, FY2027 (effective 1 July 2026; 2025 GNI per capita, Atlas method). API download 2026-10-22.
• Natural Earth (public domain) map data.
Methods & ethics
• American Statistical Association (2022). Ethical Guidelines for Statistical Practice. https://doi.org/10.5281/zenodo.7092386
• Webb, J. W. (1963). The natural and migrational components of population changes in England and Wales. Economic Geography 39(2).
• Coale, A. J. & Watkins, S. C. (eds.) (1986). The Decline of Fertility in Europe (Princeton European Fertility Project: onset of decline).
• Kaplan, E. L. & Meier, P. (1958). JASA 53 · Turnbull, B. W. (1976). JRSS-B 38.
• Ramsay, J. O. & Silverman, B. W. (2005). Functional Data Analysis, 2nd ed. Springer · Kneip, A. & Ramsay, J. O. (2008). JASA 103.
• Mundlak, Y. (1978). Econometrica 46 · Horn, J. L. (1965). Psychometrika 30 (parallel analysis) · Hennig, C. (2007). CSDA 52 (cluster stability).
• Moran, P. A. P. (1950). Biometrika 37 · Efron, B. & Tibshirani, R. (1993). An Introduction to the Bootstrap.
• OECD/JRC (2008). Handbook on Constructing Composite Indicators.
Software
• R 4.6.1; tidyverse, sf, rnaturalearth, fixest, survival, fda, cluster, clue, boot, gganimate, av, gifski, tweenr, ggflags, patchwork; reveal.js 5; flag-icons (MIT); Lato (OFL).
AI assistance & reproducibility
• AI assistance: Claude Code (Anthropic) helped draft code and text; every number was regenerated by the notebook and checked by the team.
• Code, notebook, figures and pre-specified hypotheses (sha256 {hyp_file_sha256_short}): github.com/{repo} (MIT; texts CC BY 4.0).
```

---

## 7. Cifras usadas en pantalla y voz → clave en `numbers.json` (QA-stats marca ✔ cuando el valor final coincide)

| Cifra | Clave | Valor provisional | Origen |
|---|---|---|---|
| 8.1 billion | `world_pop_2023_bn` | 8.09 | [03] |
| 130 below replacement (range 124–138 with 2.0/2.2) | `n_below_replacement_2023` | 130 (sens 124–138) | [DEM][INF][INT] |
| 84 still growing | `n_below_repl_growing_2023` | 84 | [DEM][INT] |
| 66 births > deaths | `n_below_repl_natural_growth_2023` | 66 | [DEM][INT] |
| 18 only via net arrivals (11 ≥ 1 M; 15–25 by year; 14 in 2017–19; 24 in 2021–23) | `n_grow_only_migration_2023`, `_1m` | 18 / 11 (sens 15–25) | [03][INF][DEM] |
| cover flags / examples type C | `cover_flags`, `examples_type_C` | DE, ES, BE / Germany, Spain, Belgium | [DEM][INT] |
| examples type D / E | `examples_type_D`, `examples_type_E` | China, Russia, Japan / Nepal, Azerbaijan, Uruguay | [DEM][INT] |
| map counts A/B · C · D · E | `n_type_AB`, `n_type_C`, `n_type_D`, `n_type_E` | 165 · 18 · 35 · 19 | [03][INT] |
| ~7 in 10 of high-income growth 2000–23 | `share_mig_high_2000_2023` | 70.7 % (BCa 55.8–114.0; jackknife 64.5–81.6; sens 64–78) | [03][INF] |
| 22 below replacement still growing from births, 2.2 bn | `n_momentum_countries`, `pop_momentum_bn`, `examples_momentum` | 22 / 2.20 / India, Brazil, Mexico (18 with strict net emigration) | [DEM][INT] |
| UAE net migration, growth, fertility 2023 | `cnmr_are_2023`, `growth_are_2023`, `tfr_are_2023` | +28.2 ‰ / 3.70 % / 1.20 | [03][ET] |
| UAE revision 2022→2024 | `are_revision_pct` | +12 | [ET] |
| UAE 2050 and UN 95 % range | `pop_are_2050`, `pop_are_2050_pi95_low/high` | 15.4 M / 8.9–33.3 M | [INF][ET] |
| 77 of 161 direction uncertain 2050 | `n_dir_uncertain_2050` | 77 | [INF] |
| countries that crossed TFR 4; censored | `n_cruce_tfr4_obs`, `n_cens_izq`, `n_cens_der` | 90 / 45 / 26 | [FDA] |
| % of gaps removed by own clock | `pct_var_fase` | 80 | [FDA] |
| China / Egypt, 5 → 3 children | `dur53_chn`, `dur53_egy` | 5.1 / 32.7 years | [FDA] |
| mortality first 105 of 108 (97 %) | `n_mort_first_onset`, `n_onset`, `share_mort_first` | 105 / 108 / 97 (Wilson 92–99) | [ST][INF][FDA] |
| at least 22 years | `lag_onset_lower_bound` | 22 (bootstrap 20–25) | [ST][INF] |
| child mortality already halved at fertility onset | `q5_drop_at_tfr_onset` | 50 (IQR 41–64) | [ST][FDA] |
| child mortality already falling in 1950 | `n_q5_falling_1950` | 92 of 109 | [INF] |
| fertility onset year by income | `yr_fert_onset_upmid`, `_lowmid`, `_low`, `_high` | 1970 / 1984 / 2000 / 1970 | [INF] |
| within vs across countries | `panel_within_halfq5`, `panel_between_halfq5` | −0.41 [−0.71; −0.12] / −1.05 | [PN] |
| SSA within-country | `panel_ssa_halfq5` | −1.20 | [PN] |
| decade-to-decade similarity | `r_tfr_decades_min`, `r_cnmr_decades_recent` | 0.95 / 0.67 (range 0.32–0.68) | [DEM] |
| Moran I fertility / migration | `moran_tfr_2023`, `moran_cnmr_2023`, `moran_cnmr_2023_nogulf` | 0.74 / 0.12 / −0.03 | [SP] |
| R² fertility alone | `r2_tfr_medage`, `r2_tfr_chg2050`, `r2_tfr_growth`, `r2_tfr_cnmr` | 0.773 / 0.882 / 0.592 / 0.005 | [INF][MV] |
| identity (footnote) | `r2_all` | 0.986 | [MV] |
| Portugal–Chad death rate | `cdr_prt`, `cdr_tcd`, `lex_gap_prt_tcd` | 11.1 / 11.0 / 27 | [DEM] |
| UAE–Belarus twins | `twin_tfr_are`, `twin_tfr_blr`, `twin_growth_are`, `twin_growth_blr` | 1.20 / 1.21 / 3.70 / −0.65 | [03][ET] |
| look-alikes found by fertility / two axes / chance | `knn_tfr`, `knn_pc12`, `knn_chance` | 13 / 43 / 3 | [MV] |
| Colombia look-alikes | `lookalikes_col_tfr`, `lookalikes_col_12` | FRA, AUS, TUR, USA, NZL / IRN, PER, ECU, PAN, TUN | [MV] |
| dimensions beyond noise; r(TFR, axes) | `n_dims_parallel`, `r_tfr_pc1`, `r_tfr_pc2` | 2 / −0.945 / 0.03 | [MV] |
| axis 1 share (sens by set) | `pc1_var` | 56.7 % (boot 54.7–59.1; sens 46–66) | [MV][INF] |
| composite index MC | `share_rank_mc20` | 21 % (sens 2.5–47) | [MV] |
| cluster names, sizes, populations, examples | `cluster_names`, `cluster_sizes`, `cluster_pop_bn`, `cluster_examples_*` | Early 49–50 · Fast 51 · Recent 53–54 · Migration-led 7; 1.4 / 4.9 / 1.7 / 0.07–0.1 bn | [FDA][MV] |
| silhouette; between groups | `silhouette`, `share_between_groups` | 0.37 / 42 % | [MV][FDA] |
| neighbours share a road | `join_same_road`, `join_same_road_null` | 0.67 / 0.30 | [SP] |
| P1: SD LEx, median age, LE65; Q5 ratio | `sd_lex_*`, `sd_medage_*`, `sd_le65_*`, `q5_ratio_p90p10_*` | 12.2 → 7.4 · 4.7 → 9.7 · 1.47 → 2.85 · 6.2× → 19.9× | [ST][FDA][DEM] |
| ageing 30 → 40 median age | `yrs_medage30_40_recent`, `_early` | 24 / 40.5 years | [DEM] |
| SDG 3.2 pace | `n_sdg32_above`, `n_sdg32_on_pace`, `n_sdg32_above_2030` | 70 / 8 / 58 | [DEM] |
| deaths > births | `n_natneg_2023`, `share_pop_natneg_2023`, `n_natneg_2050` | 53 / 28 % / 106 | [DEM] |
| hypotheses file | `hyp_file_date`, `hyp_file_sha256_short` | 2026-10-22 / (al commit) | — |

---

## 8. Reglas de estilo para pantalla y subtítulos

- 1920×1080; márgenes seguros 64 px; **Lato** (títulos Black 44–56 px, cuerpo 28–32 px, pie 18 px); subtítulos en barra inferior semitransparente, 34 px, ≤ 2 líneas, ≤ 90 caracteres, literales a la voz.
- Rótulo fijo `Question N` (+ códigos P en gris); pie fijo **PIE-0**: `UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey)`.
- Cada gráfica: título = mensaje en frase, sin verbos causales; etiquetas directas; unidades; línea 2023/24 punteada en toda serie que cruce; badge PIE-1…PIE-6 generado por `badge()`.
- **Colores con significado único en todo el vídeo:** azul #0072B2 = nacimientos / crece por saldo natural; celeste #56B4E9 = migración neta / crece solo por llegadas; naranja #E69F00 = defunciones / decrece por saldo natural; púrpura rojizo #CC79A7 = decrece por emigración; grupos de trayectoria (Tol) #332288 / #117733 / #DDCC77 / #88CCEE; gris = fondo y proyección. La paleta de regiones SDG **no** se usa en el vídeo. Sin rojo/verde como contraste; simulación CVD obligatoria.
- Jerga con "= …" la primera vez: replacement, net migration, R², look-alike, axis/principal component, own clock, within the same country, continuum.
- Lo que se nombra en la voz se **resalta** en el mismo instante; las banderas siempre con ISO3.
- Nombres ONU: *countries and areas*, *Türkiye*, *Viet Nam*, *Republic of Korea* (nunca "Korea" a secas), *State of Palestine*, *Kosovo (under UNSC res. 1244)*, *China, Taiwan Province of China*; en gráficas densas, ISO3.

---

## 9. Versión PDF estática (todos los builds en una página)

Regla: la página muestra el **estado final** con **≤ 3 visuales + 1 mensaje + rótulo "Question N"**; lo transitorio lleva `.print-hide`. Cada MP4 tiene póster PNG (último fotograma) para impresión. Fuente mínima 20 px.

| Página | Qué se imprime | Qué se oculta |
|---|---|---|
| Cover | Título, subtítulo, equipo, línea `130 below replacement · 84 still growing (66 births > deaths · 18 only via net arrivals)` | contador, puntos animados |
| Slide 1 | Ecuación + definición de lever · póster de barras 2000–23 con la anotación · mapa con leyenda, conteos y etiqueta de inercia · inset EAU con su rango · mensaje | tarjetas de preguntas (pasan a una línea pequeña en la Cover), zoom intermedio |
| Slide 2 | Panel B de fig04 (curvas alineadas + línea de velocidad) · fig05 con sus dos líneas de texto · fig06 · chip de migración · mensaje | panel A en calendario, animación |
| Slide 3 | Scorecard con pie · métrica + dos tarjetas (póster) · biplot con ambos ejes · franja P5 · mensaje | nada más |
| Slide 4 | fig10 (mapa + múltiplos, estado 2023) con la línea de vecinos · fig11 · tabla · tarjetas de ética en una franja (20 px) | callback, animación progresiva |
| References | §6 | — |

Generación: `slides/index.html?print-pdf` en Chromium headless con `pdfSeparateFragments: false`, `pdfMaxPagesPerSlide: 1`. QA-slides cuenta 6 páginas y lee cada una al 50 %.
