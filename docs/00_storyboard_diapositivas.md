# 00 — Storyboard de diapositivas y guion del vídeo (5:00)

> **Versión 2 — integración de asesorías (2026-10-22/23) — cambios principales**
> 1. Gancho: **130 → 84 crecen = 66 por saldo natural + 18 solo por inmigración neta** (2023, una sola definición en todo el vídeo; rango 15–25 según el año).
> 2. Slide 1: paleta sin semáforo, mapa `sf` + Robinson, anotación de **inercia** (22 países bajo reemplazo, 2,2 mil M), ejemplos por regla (C = Germany, Spain, Belgium · D = China, Russia, Japan · E = Nepal, Azerbaijan, Uruguay) e **incertidumbre visible una vez**: fan chart de EAU 2050 (8,9–33,3 M).
> 3. Slide 2: el connected scatter y el dumbbell salen; entran **registro por hitos** ("same road, different speed" literal), **mortalidad primero en 105/108, al menos 22 años**, año de inicio de la caída de la TFR por ingreso y **mini-forest dentro vs entre países** (−0,41 vs −1,05). Migración: *"a short memory and almost no neighbourhood, except in the Gulf"*.
> 4. Slide 3: la **prueba de parecidos** (look-alikes, Colombia) es la demostración central de P8; PCA narrado como "two real dimensions"; P5 = Monte Carlo ("one country in five can move twenty places"); α fuera de pantalla.
> 5. Slide 4: India en *Fast movers*; nombres **Early · Fast · Recent movers · Migration-led**; "two in three neighbouring countries share the same road (chance: one in three)"; mensaje sin "not where they are"; P1 con razón P90/P10 de Q5; tabla por estado de la palanca; tarjetas de ética.
> 6. Sin logos de la ONU; sin lenguaje causal; proyecciones = escenarios; ≤ 3 visuales por diapositiva; narración **654 palabras** (contadas con `wc -w`, cifras como una palabra; ≈ 700 habladas, ≈ 4:52 a 142 ppm).
> Registro de decisiones: `docs/07_integracion_asesorias.md`. Hipótesis: `docs/hipotesis_preinscritas.md`.

> **Revisión QA-storyboard (2026-10-23) — v2.1** (detalle antes → después → motivo en `docs/QA_storyboard.md`; juicio de jurado en §10)
> 1. **Respuestas explícitas** en voz y pantalla: `Question 1 answered` (Slide 2, build 4), `Question 2 answered` (Slide 3, build 4) y `Question 3 answered` (Slide 4, build 3); las preguntas de la build 0 repiten casi literalmente P7 y P8.
> 2. **Lenguaje llano**: glosa ≤ 7 palabras para replacement, net migration, 95 % range, median age, R², r, SD, look-alike, axis, composite index, k-means, re-runs (bootstrap), placebo, P10–P90; frases ≤ 18 palabras; menos cifras habladas (21) para dejar aire.
> 3. **Coherencia**: "four roads" → *one road, four groups* (§12: tres tramos de un camino + grupo migratorio); "at least 22 years" leído como cota de la mediana (*typically*); "Europe took 40 to 50" → claves por grupo; "Grey always means…" era falso; mensaje de la Slide 4 sin "not by where they stand"; resaltes de `fig04` por la misma regla que la voz (CHN/EGY).
> 4. **Cifras con clave**: rangos y conteos tecleados (64–78, 15–25, 46–66 → 46–77, 77 of 161, 12,880, 30–40, two in three, four in ten…) pasan a `{clave}` (§7).
> 5. Narración **628 palabras** con valores provisionales (`wc -w`, cifras = 1 palabra; ≈ 651 habladas), **≈ 4:52** a 150 ppm de articulación + 1,5 s de aire por cada una de las 21 cifras habladas (4:43 a 155 ppm); ≈ 135 ppm hablados medios por sección, todas las frases ≤ 18 palabras. Una frase por línea `>` (= bloque de subtítulo); los comentarios `<!-- QA: … -->` se eliminan antes de generar subtítulos.

> **Guion final v4 (2026-10-26, agente corrector-final: 60 hallazgos de QA-ethics, QA-slides y QA-viz)** — **596 palabras** (606 habladas), 17 cifras habladas, **4:52.2** (150 ppm + 1,5 s por cifra + 0,6 s por fragmento; MP4 cubiertos). Cambios de voz: "66 have more births than deaths; 18 grow only because…"; "including 22 below replacement that grow with no net arrivals"; sin "After 2023, grey…" ni listas habladas de países en s1.b4a–c; "Only part of today's growth"; "Early movers are projected to…"; "Recent movers have the highest child mortality today"; "off pace for the 2030 goal"; "Projections are labelled as scenarios… fixed before the final run"; "documented in our notebook". Detalle (antes → después → motivo) en `docs/correcciones.md` §H.

> **Guion final v3 (2026-10-25, agente script-narration)** — narración palabra por palabra en `slides/script/narration_en.md` (generada; plantilla `narration_en_template.md`) y en los bloques **Narración** de este archivo; cambios antes → después → motivo en `docs/QA_storyboard.md` §8. **603 palabras**, 18 cifras habladas, **4:54.1** (modelo de §0). Cambios obligatorios del análisis verificado: 106 of 109 (no 105/108) y "typically at least 22 years"; dentro del país "smaller than what comparing countries suggests" (su intervalo por bloques incluye el 0; la razón 2,5 nunca con intervalo; en Europa y Norteamérica la asociación se invierte, +0,39); *Fast movers* "age from 30 to 40 in about 32 years, about as fast as Early movers did, or faster" (Early = 37 en pantalla); sin cifras de `are_revision_pct`, `n_census_pre2009` ni `repo` (no verificadas o inexistentes). Las líneas `[OPCIONAL]` y los comentarios QA de las líneas de narración de la v2.1 se retiran de los bloques de narración.

> Texto de diapositivas, subtítulos y narración **en inglés**; notas de producción **en español**.
> Formato final: **portada + 4 diapositivas de contenido + referencias**. Cada diapositiva de contenido tiene *builds* (fragmentos reveal.js) que se graban como animación pero se imprimen como **una sola página** (`pdfSeparateFragments: false`).
> Toda cifra entre llaves `{clave}` se resuelve desde `figures/numbers.json`. Los valores provisionales (§7) llevan su origen: **[03]** hechos verificados en R, **[ST] [MV] [FDA] [DEM] [PN] [INF] [SP] [ET]** memos de asesoría, **[INT]** comprobado en R por el integrador (2026-10-22). Se sustituyen por los finales antes de grabar. Sufijo `.say` = forma hablada redondeada de la misma clave (p. ej. `share_mig_high_2000_2023.say` = "seven in ten"). Constantes de diseño que no son resultados (237 países y áreas, umbral ≥ 1 M, 12 indicadores, 5 parecidos, umbral de 20 puestos, 2,1 / 4 / 5 → 3 hijos, 25 por 1 000 del ODS 3.2, 500 re-runs, k = 4, años) se escriben tal cual. <!-- QA: regla .say y constantes, para que ninguna cifra-resultado quede sin clave -->

---

## 0. Línea de tiempo del vídeo (v3, 2026-10-25: **4:54.1** con referencias; límite 4:55)

Fuente única de la voz y de los tiempos: `slides/script/narration_en_template.md` → `python slides/script/build_narration.py` → `slides/script/narration_en.md`, `captions.json`, `video_timings.json` (lo lee `video/record_slides.py`), `captions.srt` y `data_captions.json`. Modelo: palabras habladas a 150 ppm + 1,5 s de aire por cifra hablada (una proporción "106 of 109" o un rango "nine to thirty-three" = una cifra) + 0,6 s de transición por paso (salvo el primero); cada paso con MP4 dura al menos el MP4 + 0,3 s (fig01 12,6 · fig02b 4,0 · fig04 16,4 · fig07 14,9 · fig09 7,7 · fig10 26,4 s, medidos con ffmpeg). Los tiempos de la columna "Tiempo" de las tablas de builds (§1–§5) son los de la v2.1 y quedan **sustituidos** por `video_timings.json`. Si la lectura real cronometrada pasa de 4:55, `script-narration` recorta en este orden: (1) `Three questions.` (−0,8 s); (2) las listas de países de los tipos C, D y E en la voz (las banderas siguen en pantalla, −4,8 s); (3) la frase China–Egipto (solo −1,7 s: el MP4 de fig04 manda); **nunca** las respuestas a Q1–Q3, la frase de incertidumbre de EAU ni la frase obligatoria de *Fast movers*. Si queda ≤ 4:45, puede volver `home to {pop_momentum_bn.say} billion people` (+3,9 s) o la frase de Colombia (Slide 3).

| Tiempo | Diapositiva | Sección | Palabras | Cifras habladas | ppm |
|---|---|---|---|---|---|
| 0:00.0–0:28.7 | Cover | Gancho 130 → 84 (66 + 18) + equipo; el giro "Yet 84" empieza a 0:11.6 | 44 | 5 | 92 |
| 0:28.7–0:52.5 | Slide 1 (build 0) | Tres preguntas (P7 y P8 casi literales) + escenario, no pronóstico | 57 | 0 | 144 |
| 0:52.5–1:47.7 | Slide 1 (builds 1–5) | **Question 1** — balance, descomposición por ingreso, mapa 2023, inercia, EAU | 109 | 3 | 118 |
| 1:47.7–2:43.5 | Slide 2 | **Question 1 (cont.)** — reloj propio, mortalidad primero, dentro vs entre → **"Question one, answered"** | 113 | 4 | 122 |
| 2:43.5–3:39.6 | Slide 3 | **Question 2** — scorecard, parecidos, dos dimensiones, índice → **"Question two, answered"** | 114 | 5 | 122 |
| 3:39.6–4:28.3 | Slide 4 (builds 1–3) | **Question 3** — un camino y cuatro grupos, P1 → **"Question three, answered"** + qué vigilar | 112 | 1 | 138 |
| 4:28.3–4:54.1 | Slide 4 (builds 4–5) → References | Ética + callback; referencias 3 s | 54 | 0 | 126 |
| | | **Total** | **603** (613 habladas) | **18** | **123** |

Respuesta explícita a las preguntas del profesor: **P7 = Question 1** (Slides 1–2; rótulo "Question 1 · P7 · P4" en las dos); se **oye y se lee** `Question one, answered` en la Slide 2, build 4 (2:28.5). **P8 = Question 2** (Slide 3, "Question 2 · P8 · P5"); se oye y se lee `Question two, answered: no` en la Slide 3, build 4 (3:24.9). P6 + P1 en Slide 4 (`Question three, answered`, build 3, 4:12.5); P2/P3 como banda de incertidumbre de EAU en la Slide 1. Rótulo "Question N" arriba a la izquierda; códigos P en gris 18 px.

---

## 1. Cover (0:00–0:27)

**Título:** `One Number Can't Tell 8 Billion Stories`
**Subtítulo:** `Births, deaths and migration in 237 countries and areas — UN estimates 1950–2023, projections to 2100 — and where the UN should look next`
**Línea inferior:** `Team {team_name} · ASA International DataQuest 2026 · Data: UN DESA, World Population Prospects 2024 (CC BY 3.0 IGO)` — **sin logos** de la ONU ni de agencias.

**Builds (auto):**
1. (0:00) Fondo: puntos tenues, un punto por país (`fig00_world_dots.png`); contador `{world_pop_2023_bn} billion` ({world_pop_1950_bn} → {world_pop_2023_bn}). <!-- QA: 2.5 → 8.1 tecleado pasa a claves -->
2. (0:04) `{n_below_replacement_2023} of 237 countries and areas: fertility below replacement` + nota 18 px `replacement ≈ 2.1 children per woman: enough to replace the parents where almost every child survives`; esos puntos se tiñen. <!-- QA: glosa llana de replacement -->
3. (0:12) `{n_below_repl_growing_2023} still growing` → se divide en `{n_below_repl_natural_growth_2023} births > deaths` (azul #0072B2) y `{n_grow_only_migration_2023} only because more arrive than leave` (celeste #56B4E9) con **tres banderas = `cover_flags`** (regla: los 3 más poblados ≥ 1 M del tipo C en 2023 → DE, ES, BE) y su ISO3. <!-- QA: "net arrivals" → lenguaje llano, igual que la voz -->
4. (0:21) `One number can't explain that.` → fundido al título.

**Narración (46 palabras · 0:00.0–0:29.5) — copia literal de `slides/script/narration_en.md` v4 (2026-10-26; fuente única: `narration_en_template.md`):**
> Eight billion people. <!-- cover.b1 -->
> In 2023, 130 countries and areas had too few children to replace their parents. <!-- cover.b2 -->
> Yet 84 are still growing. <!-- cover.b3 -->
> 66 have more births than deaths; 18 grow only because more people arrive than leave.
> One number can't explain that. <!-- cover.b4 -->
> We are Team UNALSta-R. <!-- cover.b5 -->

*Notas:* 130 / 84 / 66 / 18 verificados en R [DEM][INT]. "because" se usa en sentido **contable** (marcar en `qa_etica.csv`); "explain" en "One number can't explain that" es narrativo, no causal. No usar "converge" ni "pathways" en portada (01b §6). Gancho: la paradoja queda planteada antes de 0:12 ("too few children to replace their parents") y el giro "Yet 84" llega a 0:12 con el build 3; dejar 1,5 s de aire tras 130, 84, 66 y 18. QA-slides: la portada no puede quedar con `{team_name}` ni "[Team]" sin resolver (lección `ahzasasa`). Propuesta (pendiente del equipo, requiere consentimiento R9): rótulo de nombre y rol de quien narra en la esquina inferior izquierda durante "We are Team…", como TRITICS. <!-- QA: notas de gancho, aire y presentador -->

---

## 2. Slide 1 — Question 1: *Which lever moves each country's population?* (0:27–1:51) · P7 · P4

**Título:** `Question 1 · Which lever moves each country's population: births, deaths or migration?`
**Mensaje de una línea (build 5):** `Today's high-income countries: about {share_mig_high_2000_2023.say} of growth since 2000 came from net migration; elsewhere, from births. In {n_grow_only_migration_2023} countries and areas, deaths already outnumber births and net arrivals keep them growing.` <!-- QA: "7 in 10" tecleado → clave; "countries" → "countries and areas" (los 18 incluyen 7 áreas < 1 M) -->

**Visuales (3):** (1) `fig01` descomposición por ingreso; (2) `fig02` mapa de palancas con zoom; (3) `fig03` fan chart de EAU (inset en el zoom al Golfo).
**Layout:** izquierda 42 % (barras), derecha 58 % (mapa); en el build 5 el mapa hace zoom al Golfo y el inset de EAU ocupa la esquina inferior derecha.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **0** | Tres tarjetas con las preguntas (iconos neutros: balanza, lupa, carretera) con el texto literal de la voz: **Q1** `How do births, deaths and migration relate — and how does that differ by region, country and income?` (P7 · P4) · **Q2** `Does one indicator tell the whole story — or only several together?` (P8 · P5) · **Q3** `Do countries share one road at different speeds — and what should the UN watch?` (P6 · P1). Debajo, **tarjeta de datos sin logo**: `237 countries and areas ({n_states} UN Member and observer States + {n_territories} other areas) · our models use the {n_ge1m} with ≥ 1 M people · UN estimates 1950–2023 · UN medium projection 2024–2100 (grey after 2023: a scenario, with uncertainty) · Net migration = arrivals − departures, the least-measured component · Some countries and areas have had no census since before 2009: their figures rest more on UN modelling (see UN DESA, WPP 2024 data sources) · Source: UN DESA Population Division (2024), CC BY 3.0 IGO` | `Question 1 … Question 2 … Question 3 …` (texto completo en las tarjetas) | 0:27–0:52 | <!-- QA: tarjetas con P7/P8 casi literales; "grey" acotado a después de 2023; 195/42/161 → claves; línea de calidad de datos (QuantaQuartet/ahzasasa) -->
| **1** | Las tarjetas se encogen a la barra superior ("Q1" resaltado). **Ecuación animada**: `Population change = births − deaths + net migration` + `Lever = a component of the population balance, not a policy switch.` | ecuación + definición | 0:52–0:58 |
| **2** | **`fig01_growth_components_by_income.mp4`** (8 s): barras apiladas por grupo de ingreso (`Low`, `Lower-middle`, `Upper-middle`, `High` — World Bank FY2027), una década por fotograma 1950s → 2010–23; **natural change = azul #0072B2**, **net migration = celeste #56B4E9** (negativa hacia abajo); China (en Upper-middle) e India (en Lower-middle) como segmento con borde blanco y etiqueta. Se congela en 2000–23 y aparece la flecha: `Today's high-income countries (World Bank FY2027), 2000–2023: net migration ≈ {share_mig_high_2000_2023} % of population change` + gris 16 px `{share_mig_high_sens_range} % with other income lists and periods · a group total: it does not mean migration offsets low births country by country`. Eje y = millones de personas, cero marcado. | anotación con flecha | 0:58–1:12 | <!-- QA: 64–78 tecleado → clave; "classification vintage" y "shared calendar, not compensation" → llano (y sin marco de "reemplazo") -->
| **3** | **`fig02_lever_map_2023.png`** (`sf` + Robinson, marco 58° S–85° N) se dibuja por tipo: **azul #0072B2** *growing: births > deaths* (v4; antes "growing from births") · **celeste #56B4E9** *growing only because more arrive than leave* · **naranja #E69F00** *shrinking: deaths > births* · **púrpura rojizo #CC79A7** *shrinking: more leave than arrive* · gris #999999 *small states (< 1 M)* en franja inferior con ISO3. Leyenda en fila con conteos `{n_type_AB} · {n_type_C} · {n_type_D} · {n_type_E}` y nota gris `light blue: {n_grow_only_migration_2023} in 2023 ({n_grow_only_migration_sens_range} depending on the year)`. Mientras la voz dice "including {n_momentum_countries} below replacement that grow with no net arrivals", se resaltan (contorno grueso) los países de inercia con la etiqueta `Below replacement, growing from births with no net arrivals: {n_momentum_countries} countries, {pop_momentum_bn} bn people — largest:` y banderas de `examples_momentum` (IN, BR, MX). | leyenda con conteos; etiqueta de inercia | 1:12–1:21 | <!-- QA: leyenda llana igual que la voz; 15–25 tecleado → clave -->
| **4** | Los ejemplos narrados se iluminan con bandera + ISO3 en el instante en que se nombran: `examples_type_C` (DEU, ESP, BEL), `examples_type_D` (CHN, RUS, JPN), `examples_type_E` (NPL, AZE, URY). Nota 16 px: `Examples chosen by rule: the three largest countries of each type (≥ 1 M)`. | banderas | 1:21–1:38 |
| **5** | **Zoom animado** (`fig02b_lever_map_zoom.mp4`, 4 s: Europa → Golfo, interpolando `xlim/ylim` de `coord_sf` en metros Robinson con `tweenr`). En el Golfo: `UAE 2023: net migration +{cnmr_are_2023} per 1,000 people · growth {growth_are_2023} % a year · fertility {tfr_are_2023} children per woman` + nota `UAE = the twin picked by rule in Question 2 · net migration is often inferred from census gaps` · bajo el rango: `95 % range = the UN's band of likely values · for {n_dir_uncertain_2050} of {n_ge1m} countries it spans both growth and decline by 2050` (v4: textos más cortos, la tarjeta desbordaba) (v4: sin `are_revision_pct`, no verificada). Aparece el inset **`fig03_uae_fan_2050.png`**: población de EAU 1950–2100, estimación en negro hasta 2023, línea 2023/24, UN medium projection con bandas 80/95 %, línea **gris oscuro #4D4D4D punteada** `UN zero-migration scenario (no migration: a what-if, not a forecast)` (v4, QA-viz V7: el naranja es "deaths > births"); mediana proyectada gris discontinua; texto `UN medium projection, 2050: {pop_are_2050} M · 95 % range {pop_are_2050_pi95_low}–{pop_are_2050_pi95_high} M` + glosa 16 px `95 % range = the UN's band of likely values` y gris `{n_dir_uncertain_2050} of {n_ge1m} countries: the UN 95 % range for 2050 includes both growth and decline`. Mensaje de una línea + sello `Question 1 · part 1`. | zoom, inset, mensaje | 1:38–1:51 | <!-- QA: proyección rotulada "UN medium projection"; línea "if net migration were zero" = contrafactual → variante ONU Zero migration rotulada como escenario; glosa de 95 % range; 77/161 tecleados → claves; unidades -->

**Narración (build 0 · 44 palabras · 0:29.5–0:47.7) — copia literal de `slides/script/narration_en.md` v4 (2026-10-26; fuente única: `narration_en_template.md`):**
> Three questions. <!-- s1.b0 -->
> One: how do births, deaths and migration relate, and differ by region, country and income?
> Two: does one indicator tell the whole story, or only several together?
> Three: do countries share one road at different speeds, and what should the UN watch?

**Narración (builds 1–5 · 105 palabras · 0:47.7–1:41.3) — copia literal de `slides/script/narration_en.md` v4 (2026-10-26; fuente única: `narration_en_template.md`):**
> Population change is bookkeeping: births minus deaths, plus net migration, arrivals minus departures. <!-- s1.b1 -->
> In today's high-income countries, net migration accounted for about seven in ten of the growth since 2000. <!-- s1.b2 -->
> Elsewhere, growth came almost entirely from births exceeding deaths.
> Blue: more births than deaths, and growing, <!-- s1.b3 -->
> including 22 below replacement that grow with no net arrivals. <!-- s1.b3b -->
> Light blue: deaths exceed births, but arrivals keep it growing. <!-- s1.b4a -->
> Orange: deaths exceed births, and it shrinks. <!-- s1.b4b -->
> Purple: births exceed deaths, but net departures make it shrink. <!-- s1.b4c -->
> Migration is also the least certain lever. <!-- s1.b5a -->
> For the Emirates in 2050, the UN's 95 percent range is nine to thirty-three million. <!-- s1.b5b -->

*Notas de producción:* la descomposición usa **sumas de países** por grupo FY2027 (coinciden con el mapa); test: suma de grupos + "Not classified" = World. **No** comparar con los agregados de ingreso de la ONU (otra clasificación) salvo en la nota de sensibilidad (`share_mig_high_sens_range`). Ejemplos e inercia salen de `R/05_numbers_json.R` (regla en código); QA-stats comprueba que cada país nombrado tiene ese tipo en 2023. Las listas `examples_type_*` se leen con "and" antes del último nombre. Inercia: 22 = tipo B (NetMigrations ≤ 0) con TFR < 2,1; 18 tienen emigración neta estricta y 4 (BRN, ATG, KNA, LCA) migración neta 0 → por eso la voz dice "growing from births", no "despite emigration" [INT]. EAU = el país del par gemelo elegido por regla (Slide 3) que crece por llegadas; se muestra una sola vez con su rango ONU (regla escrita, no elección a mano). Línea naranja del inset = variante **Zero migration** del archivo OtherVariants, rotulada como escenario de la ONU (no "if net migration were zero", que es un contrafactual, §12). Mapa: `rnaturalearth::ne_countries(scale = "medium")` + `st_transform("+proj=robin")` + ajustes ONU del memo espacial (Crimea → UKR, departamentos franceses de ultramar separados, Somalilandia → SOM, Chipre del Norte → CYP, Siachen neutro) + nota `Boundaries and names shown do not imply official endorsement or acceptance by the United Nations.` + `Map: Natural Earth`. Badges: PIE-0 + PIE-1 (mapa), PIE-4 (barras), PIE-5 + PIE-6 (inset EAU). El chip espacial "the Gulf is the only clear migration neighbourhood" **no** entra aquí (va al notebook). Aire (v3): 1,5 s tras "seven in ten", "22" y el rango de EAU ("2.2 billion" ya no se dice: queda en pantalla; el zoom de 4 s cubre la pausa). <!-- QA: regla de selección de EAU, variante Zero migration, lectura de listas y aire -->

---

## 3. Slide 2 — Question 1 (cont.): *Same road, different speed — child mortality fell first, fertility followed* (1:51–2:45) · P7 · P4

**Título:** `Question 1 · Same road, different speed: child mortality fell first, fertility followed` <!-- QA: la relación (P7) queda en el título, no solo el orden -->
**Mensaje de una línea → recuadro de respuesta (build 4, 2 líneas, 28 px):** `Question 1 answered · Child mortality fell first and fertility followed, at each country's pace — latest in low-income countries (fertility began to fall ≈ {yr_fert_onset_upmid} upper-middle · {yr_fert_onset_lowmid} lower-middle · {yr_fert_onset_low} low income). Migration moves on its own — alike among neighbours only in the Gulf — and weighs most in today's high-income countries (≈ {share_mig_high_2000_2023.say} of their growth since 2000).` <!-- QA: respuesta explícita a P7: relación + país + región + ingreso, literal a la voz -->

**Visuales (3):** (1) `fig04` registro por hitos (animación); (2) `fig05` mortalidad primero (event time); (3) `fig06` mini-forest dentro vs entre. **Chip de texto** (no es visual) para la migración.
**Layout:** izquierda 55 % (fig04, luego se reduce a 40 % cuando entra fig05 a su derecha); franja inferior 100 % para fig06 + chip; el recuadro de respuesta sustituye a la línea de mensaje.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig04_same_road_registration.mp4`** (8 s): panel A = TFR suavizada de los {n_cruce_tfr4_obs} países que cruzaron 4 entre 1950 y 2023, en año calendario (gris; resaltados con etiqueta ISO3 los de la regla: el más rápido, el mediano y el más lento en 5 → 3 entre los ≥ 10 M que completaron el tramo — provisional **CHN**, mediano, **EGY**); las curvas **se deslizan horizontalmente** hasta alinearse en el año del cruce de 4 (panel B): mediana gruesa + banda P10–P90 que se estrecha (rótulo `band = middle 80 % of countries`). Contador `calendar year → years since fertility fell below 4 children per woman`. Al final, línea de velocidad: `5 → 3 children per woman: China {dur53_chn} years · Egypt {dur53_egy} years (fastest and slowest of countries ≥ 10 M that made the trip)` | `Same road, different clock: lining countries up on the year fertility fell below 4 children per woman removes {pct_var_fase} % of the gaps between them` · gris `{n_cens_der} countries, mostly in sub-Saharan Africa, have not crossed 4 yet and are not shown; {n_cens_izq} were already below 4 in 1950` | 1:51–2:08 | <!-- QA: resaltes por la misma regla que la voz (v2 decía KOR, IND, KEN; KEN no llega a 3); glosa de P10–P90; unidades; regla visible -->
| **2** | **`fig05_mortality_first_event_time.png`**: mismo reloj (eje `years since fertility began to fall`; sin la letra τ en pantalla), medianas + RIC de mortalidad infantil (naranja #E69F00 = defunciones; rótulo `child mortality = deaths before age 5 per 1,000 births`) y TFR (azul #0072B2 = nacimientos) como % de su propio máximo (`line = typical country · band = middle half`); la mortalidad infantil ya baja 25 años antes. Flecha en 0: `child mortality had already fallen by about half ({q5_drop_at_tfr_onset} %)`. | `Child mortality began a lasting fall first in {n_mort_first_onset} of {n_onset} high-fertility countries (5+ children per woman in 1950; {share_mort_first} %) — typically at least {lag_onset_lower_bound} years earlier` · `Fertility began to fall: ≈ {yr_fert_onset_upmid} in today's upper-middle-income countries · {yr_fert_onset_lowmid} lower-middle · {yr_fert_onset_low} low-income` · gris `child mortality was already falling in 1950 in {n_q5_falling_1950}, so the true gap is probably longer · income groups = World Bank FY2027 (today's groups applied to all years)` | 2:08–2:18 | <!-- QA: 22 = cota de la MEDIANA ("typically"), no de cada país; glosas de child mortality, high-fertility, RIC; "lower bound" → llano -->
| **3** | **`fig06_within_vs_across_forest.png`** (mini-forest, 5 filas: All + 4 grupos de ingreso): punto negro = asociación **dentro del mismo país** (cambios de 5 años, efectos fijos de país y periodo, IC 95 % por país); línea gris discontinua vertical = **entre países** ({panel_between_halfq5}); banda gris clara = placebo. Leyenda llana: `dot = within one country (line: 95 % range) · dashed line = comparing countries · light grey band = what shuffled data give (no link)`. Leyenda de la figura (v4, QA-ethics M · QA-slides B3): `dot = within the same country, over time` · `dashed = comparing countries' averages, {panel_between_halfq5}` (sin "richer/simple view"). Se resalta la fila `All countries` (la que narra la voz; QA-viz V15). | `Within the same country, the link is smaller than what comparing countries suggests: halving child mortality goes with {panel_within_halfq5} children per woman over the next 20 years, vs {panel_between_halfq5} comparing countries` · gris `clearest in sub-Saharan Africa ({panel_ssa_halfq5}); in Europe & N. America it goes the other way ({panel_eurna_halfq5}, signo +) · association, not cause` | 2:18–2:27 | <!-- QA: glosas de placebo, IC y "efectos fijos" (no aparecen en pantalla); comparación simple → rico rotulada (receta ganadora) -->
| **4** | **Chip de migración** (texto, dos columnas): `Migration: a short memory and almost no neighbourhood` · `How alike? (0 = no link, 1 = identical)` · `same country, decade to decade: births & deaths ≥ {r_tfr_decades_min} · migration {r_cnmr_decades_min}–{r_cnmr_decades_recent} (latest {r_cnmr_decades_recent})` (v4, QA-slides: se muestra también la correlación más baja, 0.32) · `neighbouring countries: fertility {moran_tfr_2023} · migration {moran_cnmr_2023} ({moran_cnmr_2023_nogulf} without the Gulf)`. **Recuadro de respuesta** (arriba) + sello `Question 1 answered (P7 · P4)`. | chip, recuadro de respuesta, sello | 2:27–2:45 | <!-- QA: r y Moran sin glosa eran ilegibles para no estadísticos; respuesta legible en pantalla -->

**Narración (113 palabras · 1:41.3–2:37.1) — copia literal de `slides/script/narration_en.md` v4 (2026-10-26; fuente única: `narration_en_template.md`):**
> Set each country's clock to when its fertility fell below four children, and the curves line up. <!-- s2.b1 -->
> The road is shared; the speed is not.
> China went from five to three children in 5 years; Egypt took 33.
> Child deaths started falling first in 106 of 109 high-fertility countries. <!-- s2.b2 -->
> The gap was typically at least 22 years.
> Within one country, this link is smaller than what comparing countries suggests. <!-- s2.b3 -->
> A sequence in time, not proof of cause.
> Question one, answered: child deaths fell first and births followed, at each country's pace; latest in low-income countries. <!-- s2.b4 -->
> Migration moves on its own, alike among neighbours only in the Gulf, and weighs most in high-income countries.

*Notas de producción:* fig04 es la única animación "de datos" larga del vídeo (receta: animar datos, no solo interfaz); ejes fijos entre fotogramas; país resaltado por regla, no a mano: **el más rápido, el mediano y el más lento de 5 → 3 entre los ≥ 10 M que completaron el tramo** (FDA: CHN 5,1 es el más rápido; EGY 32,7 el más lento observado; KEN no ha llegado a 3 y queda censurado, por eso sale de los resaltes provisionales). QA-stats comprueba que `dur53_chn` y `dur53_egy` corresponden a ese más rápido y más lento; si la corrida final cambia los países, cambian la voz y la línea de velocidad (las claves no se renombran). fig05 combina el *event time* de `st01` y `fda_04`; el dumbbell y la rejilla de umbrales quedan en el notebook (`app_threshold_grid_lag.png`, `app_km_onset_income.png` = `inc04`). fig06 se deriva de `pn03` con 5 filas; SSA se dice en pantalla, no como fila. Colores: azul = nacimientos, naranja = defunciones (mismos significados que la Slide 1); forest en negro/gris (sin semántica). "Region and income" de P7: el ingreso está en fig05/fig06 y en la respuesta ("latest in low-income countries", "high-income"); la región en la fila SSA, en el chip y en la respuesta ("only in the Gulf"); el país en la velocidad (China/Egipto) y en "at each country's pace". "Births" en voz = fecundidad (hijos por mujer), igual que en pantalla. "Migration moves on its own" se apoya en: dentro del país, 1 punto menos de saldo natural va con +0,01 ‰ de migración [PN]; ρ(Q5, CNMR) ≈ 0 dentro de cada grupo de ingreso [MV]; R² TFR→CNMR = 0,005 [MV]. Frase espacial: el memo espacial proponía *"almost no memory and almost no neighbourhood"*; se fusiona con *"short memory"* de demografía (ver `07` §3); en pantalla se mantiene el lema, en voz va la glosa. El connected scatter Q5–TFR por región pasa a `figures/appendix/app_connected_scatter_regions.png` (4 regiones resaltadas, flecha en 2023, contador gris tras 2023). Badges: PIE-0 + PIE-3; PIE-6 en el chip. La clave `{panel_within_halfq5.say}` ya no se lee en voz (la cifra queda en pantalla con `{panel_within_halfq5}`); se conserva en `numbers.json` por si la frase vuelve. Aire (v3): 1,5 s tras 5, tras 33, tras "106 of 109" y tras 22; la respuesta se lee sin prisa con el recuadro ya visible. <!-- QA: regla de resaltes, apoyo empírico de "on its own", mapeo P7 → país/región/ingreso -->

---

## 4. Slide 3 — Question 2: *Does one indicator tell the whole story?* (2:45–3:38) · P8 · P5

**Título:** `Question 2 · Does one indicator tell the whole story — or only several together?` <!-- QA: P8 literal, igual que la tarjeta y la voz de la build 0 -->
**Mensaje de una línea → recuadro de respuesta (build 4):** `Question 2 answered · No. One indicator tells the slow story (how old a population is), not the fast one (growth, migration). The story emerges when two dimensions, the transition and migration, are read together: same fertility, UAE +{twin_growth_are} % a year vs Belarus {twin_growth_blr} %.` <!-- QA: respuesta explícita a P8 (no; dos dimensiones; ejemplo), literal a la voz -->

**Visuales (3):** (1) `fig07` scorecard; (2) `fig08` tarjetas look-alikes + gemelos; (3) `fig09` dos dimensiones (biplot). Una franja de texto para P5.
**Layout:** izquierda 36 % scorecard; centro 28 % tarjetas; derecha 36 % biplot; franja P5 inferior; recuadro de respuesta encima de la franja.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig07_single_indicator_scorecard.mp4`** (6 s): `What fertility alone captures` — 4 barras horizontales (R² ajustado, {n_ge1m} países ≥ 1 M, 2023), declaradas a priori: `How old the population is (median age: half the people are older) {r2_tfr_medage}` · `Population change 2023→2050 (UN medium projection) {r2_tfr_chg2050}` · `Growth rate today {r2_tfr_growth}` · `Net migration today {r2_tfr_cnmr}`. Las dos primeras en azul ("slow story"), las dos últimas en gris oscuro ("fast levers"); intervalo por bloques de subregión como bigote fino (rótulo `thin line = plausible range`). Pie 16 px: `R² = share of the differences between countries that fertility alone reproduces (0 = none, 1 = all) · same when tested on countries left out · 2050 change is partly built in (UN projections start from fertility) · births − deaths + migration together reach {r2_all}: true by definition (bookkeeping)` y segunda línea `Even the death rate (deaths per 1,000 people) changed meaning: Portugal and Chad share it ({cdr_prt} vs {cdr_tcd}) but are {lex_gap_prt_tcd} years apart in life expectancy` | barras con valores | 2:45–3:01 | <!-- QA: "explain/explained" → "captures/reproduces" (E28); glosas de R², median age, death rate; "10-fold cross-validation" y "accounting identity" → llano; "UN medium projection" -->
| **2** | **`fig08_lookalikes_twins`** (tarjetas HTML con `flag-icons` + ISO3; póster PNG para el PDF). Arriba la **métrica**: `Look-alikes = the 5 countries most similar on 12 indicators. Fertility alone finds {knn_tfr} % of them · the two summary axes (right): {knn_pc12} % · picking at random: {knn_chance} %`. Tarjeta B: `Colombia — by fertility it looks like {lookalikes_col_tfr}; by 12 indicators, like {lookalikes_col_12}` + nota 14 px `Colombia: our home country, shown as an illustration; all countries in the repository`. (La tarjeta A de gemelos entra en el build 4, cuando la voz la nombra.) | métrica + tarjeta B | 3:01–3:09 | <!-- QA: glosa de look-alike; "two axes" se nombraba antes de presentarlos; tarjeta A movida al build 4 para que se resalte al nombrarla -->
| **3** | **`fig09_pca_two_dimensions.mp4`** (8 s): puntos grises ({n_ge1m} países), con resaltes solo para los Estados del Golfo (color Migration-led) y para Colombia y sus look-alikes; aparece el eje 1 con las flechas TFR/LEx/median age: `Axis 1 — the transition (fewer births and deaths)`; luego el eje 2: `Axis 2 — migration (and more men than women) vs ageing`; inset pequeño del análisis paralelo (autovalores vs ruido). Texto: `axis = one summary of all 12 indicators · only {n_dims_parallel} axes stand out from random noise · fertility ≈ axis 1 (r = {r_tfr_pc1}) · blind to axis 2 (r = {r_tfr_pc2}) · r = correlation, from −1 to 1` y gris `axis 1 = {pc1_var} % of the variation ({pc1_var_sens_range} % depending on which indicators enter)`. | ejes, texto | 3:09–3:16 | <!-- QA: glosas de axis, r, "transition", sex ratio; rango 46–66 tecleado era erróneo (§12: 46–77) → clave -->
| **4** | **Franja P5**: `Composite index = one score blending 5 indicators (2,000 reasonable ways to build it): weights, not formulas, decide — {share_rank_mc20} % of countries can move more than 20 places · a transition-stage index, not a ranking of development or well-being`. Entra la **tarjeta A** (gemelos por regla): `UAE · Belarus — same fertility {twin_tfr_are} vs {twin_tfr_blr} children per woman → growth +{twin_growth_are} % vs {twin_growth_blr} % a year` (flechas ↑ ↓) + nota 14 px `twins chosen by rule from {n_twin_pairs} pairs (≥ 1 M): same fertility (± 0.05), most different growth`. **Recuadro de respuesta** + sello `Question 2 answered (P8 · P5)`. | franja, tarjeta A, recuadro, sello | 3:16–3:38 | <!-- QA: glosa de composite index; 12,880 tecleado → clave; regla de gemelos visible; gemelos como ejemplo de la respuesta -->

**Narración (112 palabras · 2:37.1–3:33.3) — copia literal de `slides/script/narration_en.md` v4 (2026-10-26; fuente única: `narration_en_template.md`):**
> Question two. <!-- s3.b1 -->
> Fertility alone captures the slow story: about three quarters of the differences in how old populations are.
> Only part of today's growth, and almost none of migration.
> Fertility alone finds only one in eight of each country's closest look-alikes. <!-- s3.b2 -->
> Countries differ in two separate ways. <!-- s3.b3 -->
> Fertility tracks the first, the transition to fewer births and deaths, but misses migration.
> Blend indicators into one score: the weights can shift one country in five by more than twenty places. <!-- s3.b4 -->
> Question two, answered: no.
> The Emirates and Belarus share the same fertility; one grows almost four percent a year, the other shrinks.
> The story emerges only when transition and migration are read together.

*Notas de producción:* "three quarters" = `r2_tfr_medage.say`; "one in eight" = `knn_tfr.say`; "one in five" = `share_rank_mc20.say`; "60" = `r2_tfr_growth.say`; "4" = `twin_growth_are.say`. Valores provisionales de la voz opcional: "France or the United States", "Iran, Peru and Ecuador". La escalera 0,59 → 0,70 → 0,99 solo en el pie (identidad). El biplot **no** usa la paleta de regiones (para no reutilizar el azul de la Slide 1). Orden de la voz y de las builds: scorecard (b1) → parecidos (b2) → dos dimensiones (b3) → índice + respuesta con gemelos (b4); la tarjeta A pulsa al decir "The Emirates and Belarus". Gemelos por regla (`twins`: |ΔTFR| ≤ 0,05 con máxima |Δ crecimiento|, ≥ 1 M); Portugal–Chad por la regla análoga de la CDR (|ΔCDR| ≤ 0,1 con máxima |ΔLEx|, ≥ 1 M), top-5 de cada regla publicado. El bump chart del índice (UKR, rango 3–68) y la matriz de correlación van al apéndice. Badges: PIE-0 + PIE-3. Aire: 1,5 s tras "three quarters", "60", "one in eight", "one in five" y "4". <!-- QA: claves .say, orden de builds, reglas de gemelos -->

---

## 5. Slide 4 — Question 3: *One road, four groups — and what the UN should watch on each* (3:38–4:50) · P6 · P1 · recomendaciones · ética

**Título:** `Question 3 · One road, four groups — and what to watch on each` <!-- QA: "Four roads" contradecía la Slide 2 ("the road is shared") y §12 (silueta 0,37: tres tramos de un camino + grupo migratorio) -->
**Method strip (18 px, bajo el título):** `How we grouped: each country's 70-year path in fertility, life expectancy, median age and net migration (decade averages) → k-means, which groups similar paths (k = 4) → re-checked with whole-curve methods, 500 random re-runs and neighbours` <!-- QA: glosas de k-means y bootstrap; indicadores nombrados -->
**Mensaje de una línea → recuadro de respuesta (build 3):** `Question 3 answered · Mostly one road at different speeds: three stretches (Early · Fast · Recent movers) plus a migration-led group — and each has something different to watch.` <!-- QA: respuesta explícita a P6; elimina "not by where they stand today" (v2 prometía quitarlo) -->

**Visuales (3):** (1) `fig10` mapa de grupos + pequeños múltiplos; (2) `fig11` divergencia (P1); (3) tabla HTML "What to watch, where, when". Tarjetas de ética (texto) en el build 4.

| Build | Qué aparece / se anima / se señala | Texto en pantalla | Tiempo |
|---|---|---|---|
| **1** | **`fig10_trajectory_groups.mp4`** (10 s): izquierda, mapa `sf` Robinson de {n_ge1m} países ≥ 1 M por grupo — **Early movers #332288 · Fast movers #117733 · Recent movers #DDCC77 · Migration-led #88CCEE** — con **rayado** en los países con estabilidad bootstrap < 0,8 y en los < 1 M (no clasificados), leyenda `hatched = changes group in more than 1 in 5 re-runs, or < 1 M people (not grouped)`; derecha, 4 pequeños múltiplos (`children per woman` y `median age (half the people are older)`, 1950 → 2023, UN medium projection en gris después de 2023): mediana del grupo + banda P10–P90 (`band = middle 80 % of the group`) que se dibujan progresivamente; línea fina = país medoide. Etiqueta por panel: nombre, `{n}` países, `{pop} bn` (= `cluster_sizes`, `cluster_pop_bn`), 3 banderas + ISO3 de `cluster_examples` (3 más poblados). Línea de envejecimiento bajo los múltiplos: `median age 30 → 40: Fast movers {yrs_medage30_40_recent} years · Early movers {yrs_medage30_40_early} years (UN medium projection after 2023)`. | `{join_same_road.say} pairs of neighbouring countries share a group (by chance: {join_same_road_null.say})` · `{share_between_groups.say} countries sit between two groups — a spectrum, not boxes` · `{share_keep_ge_0.8} % of countries keep their group in at least 80 % of 500 re-runs` · `median age 30 → 40: … (grey = UN medium projection after 2023, which assumes the transition continues)` (v4) | 3:38–4:05 | <!-- QA: "two in three / one in three / four in ten" tecleados → claves; glosas de rayado, P10–P90, median age; estabilidad en un número (ahzasasa); envejecimiento con claves -->
| **2** | **`fig11_divergence_fan.png`** (dos paneles compactos, {n_ge1m} países ≥ 1 M, estimaciones 1950–2023): banda P10–P90 entre países de **life expectancy** (se estrecha) y de **median age** (se abre); debajo, una línea: razón P90/P10 de la mortalidad < 5. | `Closer in life expectancy (typical gap between countries, SD: {sd_lex_1950} → {sd_lex_2023} years), further apart in age (SD {sd_medage_1950} → {sd_medage_2023} years) — and, in relative terms only, in child deaths: the highest tenth had {q5_ratio_p90p10_1950}× the rate of the lowest tenth in 1950 and {q5_ratio_p90p10_2023}× in 2023 (peak ≈ {q5_ratio_p90p10_peak}× in the 2000s), while the absolute gap shrank` (v4; el PDF lleva una versión más corta con las mismas claves) · gris `but at 65 countries drifted apart: years left to live at 65, SD {sd_le65_1950} → {sd_le65_2023} · estimates 1950–2023`. Dentro de fig11 ya no va "gap: 311 → 64" (`q5_gap_p90p10_*` sin verificar): solo `the ratio grew, but the gap in deaths shrank`; desde el build 3 el vídeo usa `fig11_divergence_fan_small.png` (741×150). | 4:05–4:10 | <!-- QA: glosa de SD; "riskiest/safest" → neutro; unidades -->
| **3** | **Tabla "What to watch, where, when"** (HTML nativo, fila a fila, agencias en texto, sin iconos): ver tabla abajo. **Recuadro de respuesta** + sello `Question 3 answered (P6 · P1)`. | tabla, recuadro, sello | 4:10–4:27 | <!-- QA: la respuesta a Q3 se oye en este build; el sello se adelanta del build 4 -->
| **4** | **Tarjetas de ética** `How we kept it honest · ASA Ethical Guidelines (2022)` (5 tarjetas, ver abajo); se amplían al 40 % inferior durante la voz. | 5 tarjetas | 4:27–4:40 |
| **5** | Callback: fondo oscuro y grande **`One number can't tell 8 billion stories — but births, deaths and migration, read together region by region, can tell the UN where to look next.`** | callback | 4:40–4:50 | <!-- QA: "three" era ambiguo para el público lego; se nombran los tres componentes; eco de P8 ("read together") -->

**Tabla (build 3; texto en pantalla, ≥ 20 px en el PDF; 5 columnas para que quepa en una página):** <!-- QA: Mandate se funde en "For" (cabe en el PDF, ver §9) -->

v4 (corrector-final): cabecera `Road (of the row's countries ≥ 1 M)` (= `rec_rows[].road`; "mostly X (n of n)" se muestra "all X (n of n)"); en s4.b3 se resalta la fila que nombra la voz (filas 1, 2 y 4) y las demás bajan al 40 %.

| Countries where… | Road (of the row's countries ≥ 1 M) | Watch / prepare | For (mandate) | When |
|---|---|---|---|---|
| child deaths fall too slowly: {n_sdg32_above_2030} of {n_sdg32_above} above 25 per 1,000 projected to stay above it in 2030 (UN medium); {n_sdg32_on_pace} on pace at their 2015–23 rate | mostly Recent movers | child survival, newborn care; voluntary family planning; births to adolescent girls | UNICEF · WHO · UNFPA (SDG 3.2, 3.7 · ICPD) | by 2030 | <!-- QA: "UN projection" → "UN medium projection" -->
| below replacement, growing from births with no net arrivals: {n_momentum_countries} countries, {pop_momentum_bn} bn | all Fast movers | {momentum_years_range} more years of projected growth (UN medium) for most of their {pop_momentum_bn} bn people, in working and older ages: pensions and long-term care now; no alarm about birth rates | UN DESA · WHO · ILO (Decade of Healthy Ageing · SDG 1.3) | 2030–2060 | <!-- QA: "30–40" tecleado → clave; "pronatalist" → llano -->
| deaths outnumber births: {n_natneg_2023} countries ({share_pop_natneg_2023} % of humanity); {n_natneg_2050} projected by 2050 (UN medium) | Early & Fast movers | healthy longevity; measure mortality with life expectancy, not the crude death rate | WHO · UN DESA (SDG 3.4) | now–2040 | <!-- QA: "UN projection" → "UN medium projection" -->
| growth comes only from arrivals: {n_grow_only_migration_2023} countries and areas | Early movers | migrant inclusion; better arrival and departure data; read UN migration projections as scenarios | IOM · UN DESA (GCM obj. 1 & 16 · SDG 10.7) | now | <!-- QA: "countries" → "countries and areas"; redacción llana -->
| more people leave than arrive: {examples_type_E} … · and everywhere: censuses and civil registration | mixed | decent work, safe return, diaspora links; publish lever types with their sensitivity ranges | IOM · ILO · UNSD (GCM obj. 2 & 19 · SDG 8.8, 17.19) | now / 2030 census round |

**Tarjetas de ética (build 4; título + ≤ 12 palabras cada una + código ASA en gris):**
Frase de cabecera (v4): `We describe patterns; we do not claim causes. UN estimates (≤ 2023) and UN projections (≥ 2024) are always told apart: grey after 2023; the UAE example carries the UN's own 80/95 % ranges. Each country is counted once — no aggregates added on top. Every number is regenerated by our notebook.`

1. **Scenarios, not forecasts** *(B.2 · C.4)* — grey = UN medium projection, a scenario; UAE 2050: {pop_are_2050} M, UN 95 % range {pop_are_2050_pi95_low}–{pop_are_2050_pi95_high} M. <!-- QA: "contains no shocks" → término ONU ("crises") y llano -->
2. **Weakest data, said aloud** *(B.1 · D.10)* — net migration is often inferred from census gaps: the least-measured lever, so we say so (sin `are_revision_pct`, no verificada). <!-- QA: "census residual" → llano -->
3. **Patterns, not causes** *(C.2 · C.3)* — orders in time and links within countries, not effects.
4. **Levers, not verdicts** *(A.8 · D.6)* — groups describe paths, not development or worth; positive migration is not "success".
5. **Open & checkable** *(B.3 · F.4)* — hypotheses fixed {hyp_file_date}, before the final run · examples by rule · AI agents wrote code and text · every number recomputed by separate code, team-reviewed (v4, 2026-10-26: verificación = código independiente, no una persona; la revisión humana de las cifras habladas queda pendiente, `docs/correcciones.md` §H; el sha256 queda en Referencias) <!-- QA: "still exploratory": las hipótesis salen de un EDA previo (B.3, C.3) -->

Pie 14 px: `ASA (2022), doi:10.5281/zenodo.7092386 · UN DESA (2024) WPP 2024 Methodology · World Bank FY2027 income groups applied to all years · countries ≥ 1 M for models · Map: Natural Earth; boundaries imply no UN endorsement`.

**Narración (builds 1–3 · 119 palabras · 3:33.3–4:25.2) — copia literal de `slides/script/narration_en.md` v4 (2026-10-26; fuente única: `narration_en_template.md`):**
> Question three. <!-- s4.b1 -->
> Grouped by seventy-year paths, countries form three stretches of one road, plus a migration-led group, mostly Gulf states.
> Early movers are projected to grow only through migration, or shrink.
> Fast movers, India, China and Indonesia, are projected to age from 30 to 40 in about 32 years.
> About as fast as Early movers did, or faster.
> Recent movers have the highest child mortality today.
> Countries grew closer in life expectancy, but further apart in age. <!-- s4.b2 -->
> Question three, answered: mostly one road, at different speeds. <!-- s4.b3 -->
> For the UN: watch child survival where it is off pace for the 2030 goal.
> Watch ageing where fertility is low but populations still grow.
> Watch migration data where growth depends on arrivals.

**Narración (builds 4–5, cierre · 57 palabras · 4:25.2–4:49.2) — copia literal de `slides/script/narration_en.md` v4 (2026-10-26; fuente única: `narration_en_template.md`):**
> Projections are labelled as scenarios; examples follow a rule; hypotheses were fixed before the final run. <!-- s4.b4 -->
> These are patterns, not causes; every number and our AI use are documented in our notebook.
> One number can't tell eight billion stories. <!-- s4.b5 -->
> But births, deaths and migration, read together region by region, can tell the UN where to look next.

*Notas de producción:* los nombres de grupo salen de `cluster_names` (regla en `R/config.R`, §4 del plan de implementación); provisionales: Early = United States, Russia, Japan · Fast = India, China, Indonesia · Recent = Pakistan, Nigeria, Ethiopia · Migration-led = Saudi Arabia, Jordan, UAE [FDA][MV]. Si el notebook cambia la composición, la voz cambia con `numbers.json`. "Mostly Gulf states" se comprueba con `cluster_examples_migration` / miembros del grupo (Jordania no es del Golfo: por eso "mostly"). "three stretches of one road plus a migration-led group" = §12 (silueta 0,37; k = 3 es la partición natural y k = 4 añade el grupo migratorio) [MV][FDA]. "four in ten" = `share_between_groups.say` (fanny, pertenencia máx. < 0,6) [MV]; "two in three … one in three" = `join_same_road.say` / `join_same_road_null.say` (0,67 / 0,30) [SP]. **Envejecimiento:** `yrs_medage30_40_recent` / `yrs_medage30_40_early` deben calcularse **por grupo** (mediana de años de edad mediana 30 → 40 en Fast y en Early movers, estimaciones + UN medium); el prototipo [DEM] los da por cohorte de cruce (24 si cruzan 30 en 1990–2023; 40,5 si antes de 1990): si el notebook no los calcula por grupo, la voz dice `…what took countries that aged earlier {yrs_medage30_40_early}` y la línea de pantalla igual. Si Nigeria aparece como bandera, pie de calidad `Nigeria: last census 2006`. Describir los grupos solo con variables externas (Q5, LE65, cambio 2023→2050, edad mediana 2050) y sin p-valores. La tabla es HTML nativo (legible en el PDF). Verbos permitidos: *watch, plan, measure, prepare, monitor*; prohibidos: *reduce fertility, control, drive, cause, unlock*. Las palabras "not proof of cause" y "patterns, not causes" son negaciones: se registran como excepción del grep en `qa_etica.csv`. Aire (v3): 1,5 s tras "about 32"; el build 1 dura 27,3 s porque el MP4 de fig10 dura 26,4 s. Envejecimiento (v3): resuelto por grupo en el notebook (Fast 32 [27–37], Early 36,5 [29–42,5] años); la voz usa la frase obligatoria "…in about 32 years. About as fast as Early movers did, or faster." y nunca `yrs_medage30_40_fast_started`. <!-- QA: comprobación "mostly Gulf", envejecimiento por grupo y fallback de redacción -->

---

## 6. References (sin narración; 2–3 s al final y última página del PDF)

```
Data
• United Nations, DESA, Population Division (2024). World Population Prospects 2024, Online Edition. https://population.un.org/wpp/ — licensed under CC BY 3.0 IGO (https://creativecommons.org/licenses/by/3.0/igo/). Changes: we aggregated, modelled and charted the data; the UN does not endorse this work.
• UN DESA (2024). WPP 2024: Methodology of the UN population estimates and projections. UN DESA/POP/2024/DC/NO.10 · WPP 2024: Summary of Results. UN DESA/POP/2024/TR/NO.9 · Release note on 2022 vs 2024 revisions (11 Jul 2024) · WPP 2024 Interim Update (Togo), 19 Jan 2026.
• WPP2024 Supplement (births by sex, LE60) — prepared by the DataQuest organisers from the UN Data Portal.
• World Bank (2026). Country and Lending Groups, FY2027 (effective 1 July 2026; 2025 GNI per capita, Atlas method). API download 2026-10-22. CC BY 4.0.
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
• Okabe, M. & Ito, K. (2008). Color Universal Design · Tol, P. (2021). Colour schemes, SRON (colour palettes).
Software
• R 4.6.1; tidyverse, sf, rnaturalearth, fixest, survival, fda, cluster, clue, boot, gganimate, av, gifski, tweenr, ggflags, patchwork; reveal.js 5; flag-icons (MIT); Lato (OFL).
AI assistance & reproducibility
• AI assistance: Claude Code (Anthropic) AI agents, directed by the team, wrote most of the R code, the analysis memos, the figures and drafts of the slides and script. Every number shown or said was independently recomputed from the raw UN files with separate code (also AI-written); the team reviewed the results and is responsible for the work. Log: docs/registro_ia.md.
• Code, notebook, figures and hypotheses (fixed {hyp_file_date} before the final run, after exploring the same data — not confirmatory; sha256 {hyp_file_sha256_short}) are in our public repository (code MIT; texts CC BY 4.0). (v4: se mantiene "public repository" por decisión del orquestador; el repositorio DEBE hacerse público, con LICENSE y CITATION.cff, antes de entregar — `docs/correcciones.md` §H)
• Acronyms (columna izquierda, bajo Software, para no desbordar): SDG = UN Sustainable Development Goal target · ICPD = Cairo Programme of Action (1994) · GCM = Global Compact for Migration · UNSD = UN Statistics Division.
```
<!-- QA: atribución CC BY 3.0 IGO completa (enlace a la licencia, cambios realizados y sin aval de la ONU, como exige la licencia); crédito de las paletas Okabe-Ito y Tol -->

---

## 7. Cifras usadas en pantalla y voz → clave en `numbers.json` (QA-stats marca ✔ cuando el valor final coincide)

| Cifra | Clave | Valor provisional | Origen |
|---|---|---|---|
| 8.1 billion (cover counter from 2.5) | `world_pop_2023_bn`, `world_pop_1950_bn` | 8.09 / 2.5 | [03] |
| 130 below replacement (range 124–138 with 2.0/2.2) | `n_below_replacement_2023` | 130 (sens 124–138) | [DEM][INF][INT] |
| 84 still growing | `n_below_repl_growing_2023` | 84 | [DEM][INT] |
| 66 births > deaths | `n_below_repl_natural_growth_2023` | 66 | [DEM][INT] |
| 18 only via net arrivals (11 ≥ 1 M; 15–25 by year; 14 in 2017–19; 24 in 2021–23) | `n_grow_only_migration_2023`, `_1m`, `n_grow_only_migration_sens_range` | 18 / 11 / "15–25" | [03][INF][DEM] |
| cover flags / examples type C | `cover_flags`, `examples_type_C` | DE, ES, BE / Germany, Spain, Belgium | [DEM][INT] |
| examples type D / E | `examples_type_D`, `examples_type_E` | China, Russia, Japan / Nepal, Azerbaijan, Uruguay | [DEM][INT] |
| map counts A/B · C · D · E | `n_type_AB`, `n_type_C`, `n_type_D`, `n_type_E` | 165 · 18 · 35 · 19 | [03][INT] |
| universe: states, territories, ≥ 1 M | `n_states`, `n_territories`, `n_ge1m` | 195 / 42 / 161 | [01b A9][INT] |
| last census before 2009 | `n_census_pre2009` | 23 | [ET] |
| ~7 in 10 of high-income growth 2000–23 | `share_mig_high_2000_2023` (+ `.say`), `share_mig_high_sens_range` | 70.7 % (BCa 55.8–114.0; jackknife 64.5–81.6) / "64–78" | [03][INF] |
| 22 below replacement still growing from births, 2.2 bn | `n_momentum_countries`, `pop_momentum_bn`, `examples_momentum` | 22 / 2.20 / India, Brazil, Mexico (18 with strict net emigration) | [DEM][INT] |
| years of momentum growth (table row 2) | `momentum_years_range` | "30–40" | [DEM] |
| UAE net migration, growth, fertility 2023 | `cnmr_are_2023`, `growth_are_2023`, `tfr_are_2023` | +28.2 ‰ / 3.70 % / 1.20 | [03][ET] |
| UAE revision 2022→2024 | `are_revision_pct` | +12 | [ET] |
| UAE 2050 and UN 95 % range | `pop_are_2050`, `pop_are_2050_pi95_low/high` | 15.4 M / 8.9–33.3 M | [INF][ET] |
| 77 of 161 direction uncertain 2050 | `n_dir_uncertain_2050` | 77 | [INF] |
| countries that crossed TFR 4; censored | `n_cruce_tfr4_obs`, `n_cens_izq`, `n_cens_der` | 90 / 45 / 26 | [FDA] |
| % of gaps removed by own clock | `pct_var_fase` | 80 | [FDA] |
| China / Egypt, 5 → 3 children (= fastest / slowest ≥ 10 M by rule) | `dur53_chn`, `dur53_egy` | 5.1 / 32.7 years | [FDA] |
| mortality first 106 of 109 (97 %) | `n_mort_first_onset`, `n_onset`, `share_mort_first` | **final v1: 106 / 109 / 97 (Wilson 92–99)** (v2: 105 / 108) | [ST][INF][FDA] |
| typically at least 22 years (lower bound of the median lag; en voz nunca "median") | `lag_onset_lower_bound` | **final v1: 22 (bloques 16–28)** | [ST][INF] |
| child mortality already halved at fertility onset | `q5_drop_at_tfr_onset` | 50 (IQR 41–64) | [ST][FDA] |
| child mortality already falling in 1950 | `n_q5_falling_1950` | 92 of 109 | [INF] |
| fertility onset year by income | `yr_fert_onset_upmid`, `_lowmid`, `_low`, `_high` | 1970 / 1984 / 2000 / 1970 | [INF] |
| within vs across countries | `panel_within_halfq5`, `panel_between_halfq5` | **final v1: −0.41 [bloques −0.77; 0.05: incluye 0] / −1.05**; voz "smaller than comparing countries suggests"; razón 2.5 sin intervalo; Europa y N. América +0.39 (se invierte) | [PN] |
| SSA within-country | `panel_ssa_halfq5` | −1.20 | [PN] |
| decade-to-decade similarity | `r_tfr_decades_min`, `r_cnmr_decades_recent` | 0.95 / 0.67 (range 0.32–0.68) | [DEM] |
| Moran I fertility / migration | `moran_tfr_2023`, `moran_cnmr_2023`, `moran_cnmr_2023_nogulf` | 0.74 / 0.12 / −0.03 | [SP] |
| R² fertility alone | `r2_tfr_medage` (+ `.say`), `r2_tfr_chg2050`, `r2_tfr_growth` (+ `.say`), `r2_tfr_cnmr` | 0.773 ("three quarters") / 0.882 / 0.592 ("60") / 0.005 | [INF][MV] |
| identity (footnote) | `r2_all` | 0.986 | [MV] |
| Portugal–Chad death rate | `cdr_prt`, `cdr_tcd`, `lex_gap_prt_tcd` | 11.1 / 11.0 / 27 | [DEM] |
| UAE–Belarus twins | `twin_tfr_are`, `twin_tfr_blr`, `twin_growth_are` (+ `.say`), `twin_growth_blr`, `n_twin_pairs` | 1.20 / 1.21 / 3.70 ("4") / −0.65 / 12,880 | [03][ET] |
| look-alikes found by fertility / two axes / chance | `knn_tfr` (+ `.say`), `knn_pc12`, `knn_chance` | 13 ("one in eight") / 43 / 3 | [MV] |
| Colombia look-alikes | `lookalikes_col_tfr`, `lookalikes_col_12` (+ `.say`) | FRA, AUS, TUR, USA, NZL / IRN, PER, ECU, PAN, TUN | [MV] |
| dimensions beyond noise; r(TFR, axes) | `n_dims_parallel`, `r_tfr_pc1`, `r_tfr_pc2` | 2 / −0.945 / 0.03 | [MV] |
| axis 1 share (sens by set) | `pc1_var`, `pc1_var_sens_range` | 56.7 % (boot 54.7–59.1) / "46–77" (v2 decía 46–66: el núcleo de 13 variables da 76,6) | [MV][INF] |
| composite index MC | `share_rank_mc20` (+ `.say`) | 21 % ("one in five"; sens 2.5–47) | [MV] |
| cluster names, sizes, populations, examples | `cluster_names`, `cluster_sizes`, `cluster_pop_bn`, `cluster_examples_*` | Early 49–50 · Fast 51 · Recent 53–54 · Migration-led 7; 1.4 / 4.9 / 1.7 / 0.07–0.1 bn | [FDA][MV] |
| silhouette; between groups; stability | `silhouette`, `share_between_groups` (+ `.say`), `share_keep_ge_0.8` | 0.37 / 42 % ("four in ten") / (notebook) | [MV][FDA][01b A2] |
| neighbours share a group | `join_same_road` (+ `.say`), `join_same_road_null` (+ `.say`) | 0.67 ("two in three") / 0.30 ("one in three") | [SP] |
| P1: SD LEx, median age, LE65; Q5 ratio | `sd_lex_*`, `sd_medage_*`, `sd_le65_*`, `q5_ratio_p90p10_*` | 12.2 → 7.4 · 4.7 → 9.7 · 1.47 → 2.85 · 6.2× → 19.9× | [ST][FDA][DEM] |
| ageing 30 → 40 median age (by group: Fast vs Early) | `yrs_medage30_40_recent` (= Fast movers), `_early` | **final v1: 32 [27–37] / 36.5 [29–42.5] → en pantalla 37 (fmt 0, ROUND_HALF_UP)**; voz "in about 32 years, about as fast as Early movers did, or faster" | [DEM] |
| SDG 3.2 pace | `n_sdg32_above`, `n_sdg32_on_pace`, `n_sdg32_above_2030` | 70 / 8 / 58 | [DEM] |
| deaths > births | `n_natneg_2023`, `share_pop_natneg_2023`, `n_natneg_2050` | 53 / 28 % / 106 | [DEM] |
| hypotheses file | `hyp_file_date`, `hyp_file_sha256_short` | 2026-10-22 / (al commit) | — |
<!-- QA: claves nuevas (world_pop_1950_bn, *_sens_range, n_states, n_territories, n_ge1m, n_census_pre2009, momentum_years_range, n_twin_pairs, share_keep_ge_0.8 y variantes .say) para que ninguna cifra-resultado quede tecleada -->

---

## 8. Reglas de estilo para pantalla y subtítulos

- 1920×1080; márgenes seguros 64 px; **Lato** (títulos Black 44–56 px, cuerpo 28–32 px, pie 18 px); subtítulos en barra inferior semitransparente, 34 px, ≤ 2 líneas, ≤ 90 caracteres, literales a la voz (una línea `>` del guion = un bloque; las de > 90 caracteres se parten en la coma o el punto y coma). <!-- QA: regla de bloque de subtítulo -->
- Rótulo fijo `Question N` (+ códigos P en gris); pie fijo **PIE-0**: `UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey)`.
- Cada gráfica: título = mensaje en frase, sin verbos causales; etiquetas directas; unidades; línea 2023/24 punteada en toda serie que cruce; badge PIE-1…PIE-6 generado por `badge()`. **PIE-1 en v2 dice `estimates, 2023`**, no el "2021–23 average" del memo `04` §3.3 (decisión C1 de `07` §3). <!-- QA: el texto de PIE-1 del memo de ética contradice la definición 2023 -->
- **Colores con significado único en todo el vídeo:** azul #0072B2 = nacimientos / crece por saldo natural; celeste #56B4E9 = migración neta / crece solo por llegadas; naranja #E69F00 = defunciones / decrece por saldo natural; púrpura rojizo #CC79A7 = decrece por emigración; grupos de trayectoria (Tol) #332288 / #117733 / #DDCC77 / #88CCEE; gris = fondo y proyección (la voz dice "after 2023, grey shows the UN medium projection"). La paleta de regiones SDG **no** se usa en el vídeo. Sin rojo/verde como contraste; simulación CVD obligatoria.
- Jerga con glosa de ≤ 7 palabras la primera vez (en pantalla o en voz): replacement, net migration, UN medium projection, 95 % range, median age, child mortality, high-fertility, own clock, P10–P90 / RIC (band), within the same country, placebo, R², r, look-alike, axis, transition, composite index, k-means, re-runs (bootstrap), hatched (stability), SD, continuum → *spectrum*. Términos que **no** aparecen en pantalla ni en voz (solo notebook y referencias): PCA, fixed effects, Kaplan–Meier, Turnbull, Moran, silhouette, cross-validation, identity. <!-- QA: lista de glosas ampliada (prueba del familiar) -->
- Lo que se nombra en la voz se **resalta** en el mismo instante; las banderas siempre con ISO3.
- Ritmo: frases ≤ 18 palabras; cifra hablada al final de frase o de cláusula y 1,5–2,5 s de aire (la cifra sigue en pantalla ≥ 3 s); como máximo dos cifras habladas por frase. <!-- QA: regla de aire -->
- Nombres ONU: *countries and areas*, *Türkiye*, *Viet Nam*, *Republic of Korea* (nunca "Korea" a secas), *State of Palestine*, *Kosovo (under UNSC res. 1244)*, *China, Taiwan Province of China*; en voz bastan "Iran", "Russia", "the United States", "the Emirates"; en gráficas densas, ISO3.

---

## 9. Versión PDF estática (todos los builds en una página)

Regla: la página muestra el **estado final** con **≤ 3 visuales + 1 recuadro de respuesta o mensaje + rótulo "Question N"**; lo transitorio lleva `.print-hide`. Cada MP4 tiene póster PNG (último fotograma) para impresión. Fuente mínima 20 px (pies 18 px).

| Página | Qué se imprime | Qué se oculta |
|---|---|---|
| Cover | Título, subtítulo, equipo, línea `{n_below_replacement_2023} below replacement · {n_below_repl_growing_2023} still growing ({n_below_repl_natural_growth_2023} births > deaths · {n_grow_only_migration_2023} only because more arrive than leave)` + **las tres preguntas en una línea de 20 px con sus códigos P** | contador, puntos animados | <!-- QA: cifras tecleadas → claves; preguntas visibles en el PDF -->
| Slide 1 | Ecuación + definición de lever · póster de barras 2000–23 con la anotación · mapa con leyenda, conteos y etiqueta de inercia · inset EAU con su rango y la glosa de 95 % range · mensaje | tarjetas de preguntas (pasan a la Cover), zoom intermedio |
| Slide 2 | Panel B de fig04 (curvas alineadas + línea de velocidad) · fig05 con sus dos líneas de texto · fig06 · chip de migración · **recuadro `Question 1 answered`** | panel A en calendario, animación | <!-- QA: la respuesta a P7 se imprime -->
| Slide 3 | Scorecard con pie · métrica + tarjetas A (gemelos) y B (Colombia) · biplot con ambos ejes · franja P5 · **recuadro `Question 2 answered`** | nada más | <!-- QA: la respuesta a P8 se imprime -->
| Slide 4 | fig10 (mapa + múltiplos, estado 2023) con las tres líneas de texto · fig11 · tabla de 5 columnas · tarjetas de ética en una franja de 20 px **en versión mínima** (5 títulos en negrita + códigos ASA) · **recuadro `Question 3 answered`** | callback, animación progresiva, texto largo de las tarjetas | <!-- QA: versión mínima de las tarjetas (memo 04 §3.1) para que quepa -->
| References | §6 | — |

**Prueba de que cabe (Slide 4, la más densa; alturas a 1080 px):** título 56 + method strip 26 + fila superior fig10 / fig11 (60 % / 40 % del ancho) 420 + tabla 5 × 2 líneas a 20 px + cabecera ≈ 290 + recuadro de respuesta 34 + franja de ética 30 + PIE-0 y pie 14 px 40 + márgenes 2 × 64 = **1 024 px ≤ 1 080**. Condición: cada celda de la tabla ≤ 2 líneas a 20 px en su columna (columna "Countries where…" 34 % del ancho ≈ 610 px ≈ 2 × 55 caracteres → la fila 1 y la 3 se recortan en la versión impresa a `child deaths fall too slowly: {n_sdg32_above_2030} of {n_sdg32_above} stay above 25 per 1,000 in 2030` y `deaths outnumber births: {n_natneg_2023} countries ({share_pop_natneg_2023} %), {n_natneg_2050} by 2050`, con `.print-only`). Slide 2: fig04 B + fig05 arriba (420 px), fig06 + chip abajo (300 px), recuadro de respuesta 2 × 28 px → cabe con el mismo cálculo. Total del PDF: **6 páginas** (portada + 4 + referencias). <!-- QA: comprobación explícita de que el diseño final cabe en portada + 4 + referencias -->

Generación: `slides/index.html?print-pdf` en Chromium headless con `pdfSeparateFragments: false`, `pdfMaxPagesPerSlide: 1`. QA-slides cuenta 6 páginas y lee cada una al 50 %.

---

## 10. Revisión QA-storyboard (2026-10-23)

Revisión como jurado (Insight / Viz / Ética) de la v2, con la lista completa de cambios en `docs/QA_storyboard.md`. Escala de `01b`: 7–8 = nivel ganador nacional, 9–10 = ganador internacional. Las notas valoran el storyboard (guion + diseño), no el vídeo terminado.

### 10.1 Qué hacen todavía mejor los ganadores y competidores, y qué hacemos

| Equipo | Qué hacen mejor que nuestro storyboard (v2) | Corrección | Estado |
|---|---|---|---|
| **TRITICS** (Viz 2025) | Tesis corta repetida (título, 0:12, cierre) y **voz llana con glosa de 5–7 palabras por variable**; nuestra v2 hablaba de "age structure", "two real dimensions", "composite index" y mostraba r, Moran y SD sin glosa | Glosa ≤ 7 palabras para cada término (§8); voz reescrita; callback con los tres componentes nombrados | **Aplicada** |
| TRITICS | **Comparación modelo simple → rico rotulada** (medallas por R² ajustado): se entiende sin saber estadística | fig06 rotulada `simple view: comparing countries · richer view: the same country over time` y voz "smaller than what comparing countries suggests" (v3: el intervalo dentro del país incluye 0; "less than half" se retiró) | **Aplicada** |
| TRITICS | Presentadores en cámara con rótulo de nombre y rol; ritmo de 123 ppm | Rótulo de quien narra en portada y cierre (propuesta, requiere consentimiento R9); ritmo bajado a ≈ 131 ppm medios con aire tras cada cifra | Ritmo **aplicado**; presentador **propuesto** |
| TRITICS | Matriz de política con banderas por fila (lectura instantánea) | Tabla sin iconos (ética: sin emblemas); opcional en el vídeo: 3 ISO3 por fila elegidos por regla (los 3 más poblados del estado de la palanca), nunca en el PDF | **Propuesta** (no entra si rompe la prueba de que cabe) |
| **QuantaQuartet** (Insight 2025) | **Calidad de los datos al principio** (cobertura, faltantes) en su propia diapositiva | Línea `{n_census_pre2009} countries and areas: last census before 2009` en la tarjeta de datos + tarjeta de ética 2 | **Aplicada** |
| QuantaQuartet | Validación honesta visible (CV R²) | Pie del scorecard: `same when tested on countries left out` | **Aplicada** |
| QuantaQuartet | Nombres de grupo memorables ("Fading Echoes") | Mantenemos Early · Fast · Recent movers · Migration-led (neutrales, ética D.6); la memorabilidad la da "one road, four groups" | Decisión: no cambiar |
| **ahzasasa** (2026, el más fuerte) | **Estabilidad por país en un número** y rayado en el mapa | `{share_keep_ge_0.8} % of countries keep their group in at least 4 of 5 re-runs` + leyenda llana del rayado | **Aplicada** |
| ahzasasa | Etiqueta *post hoc* / exploratorio explícita | Tarjeta 5: `hypotheses fixed … still exploratory` | **Aplicada** |
| ahzasasa | Coherencia interna (un solo relato: "one transition, different timings") | Nuestra v2 decía "the road is shared" (Slide 2) y "four roads" (Slide 4): ahora "one road, four groups" y "three stretches of one road plus a migration-led group" | **Aplicada** |
| ahzasasa | Incertidumbre en 3 países ("ranges, not points") | Mantenemos una sola banda (EAU) + `{n_dir_uncertain_2050} of {n_ge1m}` en gris: es la regla "incertidumbre visible una vez" y no cabe un cuarto visual | Decisión: no cambiar |
| ahzasasa | Deck exacto de 6 páginas | Prueba de que cabe (§9) con alturas | **Aplicada** |
| Todos | Ninguno respondió P7 y P8 con una frase literal | `Question one/two/three, answered` en voz y recuadro | **Aplicada** (nuestra ventaja) |

### 10.2 Puntuaciones del storyboard (1–10)

| Premio | v2 (antes) | v2.1 (después) | Justificación |
|---|---|---|---|
| **Best Statistical Insight** | **7** | **8,5** | Antes: métodos fuertes (supervivencia con censura, dentro vs entre, parecidos, Monte Carlo del índice, estabilidad), pero sin respuesta audible a P7/P8, una cifra mal leída ("at least 22 years" atribuido a cada país), "four roads" contra "the road is shared" y "Europe took 40 to 50" sin clave. Después: tres respuestas explícitas que citan la evidencia, comparación simple → rica rotulada, cifras con clave y coherencia con §12. Falta para 9: cifras finales del notebook (pendientes) y que la respuesta a P7 resista la sensibilidad de los años de inicio. |
| **Best Data Visualization** | **8** | **8,5** | Antes: buen catálogo (registro animado, zoom al Golfo, fan chart, colores con un solo significado), pero texto en pantalla técnico (r, Moran, SD, R², τ, P10–P90 sin glosa), "Grey always means…" falso y riesgo de que la Slide 4 no cupiera en el PDF. Después: glosas, unidades, tarjeta de gemelos sincronizada con la voz, recuadros de respuesta y prueba de altura de la Slide 4. Falta para 9: verlo renderizado (QA-viz al 50 %) y la propuesta de presentador. |
| **Best Consideration of Ethics** | **8** | **9** | Antes: tarjetas ASA, ejemplos por regla, incertidumbre una vez, IA declarada; pero quedaba un contrafactual ("if net migration were zero"), cifras tecleadas sin clave, "Europe" como sustituto de un grupo, atribución CC BY incompleta y PIE-1 con otra ventana. Después: escenario ONU rotulado, todas las cifras-resultado con clave, atribución con cambios y sin aval, "still exploratory", "countries and areas" en los 18, "no alarm about birth rates", términos ONU para crisis. Al nivel de `ahzasasa` (9) y por encima en migración, ingreso y posicionalidad (Colombia). |
<!-- QA: bloque nuevo pedido en la tarea (comparación y puntuaciones) -->
