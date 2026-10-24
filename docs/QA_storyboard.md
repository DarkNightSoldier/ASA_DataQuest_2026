# QA del storyboard v2 → v2.1 (agente QA-storyboard, 2026-10-23)

Archivo revisado: `docs/00_storyboard_diapositivas.md`. Fuentes de la revisión: `00_plan_analitico.md` §1–2 y §12, `04_etica_ASA_aplicada.md` (§2.6, §4 y las 52 frases de §6), `01_analisis_ganadores_2025.md` §6–§7, `01b_otros_equipos_2025_2026.md` §3–§6, `07_integracion_asesorias.md` §3–§4 y la memoria de las ASA Ethical Guidelines (2022). Cada línea corregida del storyboard lleva `<!-- QA: motivo -->` al final; estos comentarios se eliminan antes de generar subtítulos.

## 1. Resumen

| Medida | v2 | v2.1 |
|---|---|---|
| Palabras de narración (`wc -w`, valores provisionales, cifra = 1) | 658 | **628** (+18 de la frase `[OPCIONAL]` de Colombia, fuera del recuento) |
| Palabras habladas (cifras leídas en voz alta) | 687 | **651** |
| Duración estimada (150 ppm de articulación + 1,5 s de aire por cifra hablada) | 5:05 | **4:52** (4:43 a 155 ppm); con referencias, 4:55 |
| Cifras habladas | 25 aprox. (9 solo en la Slide 2) | **21** (máximo 5 por diapositiva) |
| Frases de > 18 palabras | 8 (la más larga, 31) | **0** |
| Respuestas audibles "Question N, answered" | 0 | **3** (P7, P8, P6) |
| Frases de narración cambiadas, nuevas o eliminadas | — | **43 líneas marcadas** de 53 (+ 5 eliminadas o fusionadas) |
| Líneas de pantalla, tablas y notas corregidas | — | **≈ 56** |
| Cifras-resultado tecleadas sin `{clave}` | 14 | **0** (constantes de diseño declaradas en la cabecera) |

Puntuaciones del storyboard (§10 del storyboard): Insight **7 → 8,5**, Viz **8 → 8,5**, Ética **8 → 9**.

## 2. Cambios en la narración (antes → después → motivo)

| Sección | Antes (v2) | Después (v2.1) | Motivo |
|---|---|---|---|
| Cover | In 2023, 130 of 237 countries and areas had fertility below replacement, about 2.1 children per woman. | In 2023, {130} of 237 countries and areas had below-replacement fertility: too few children to replace their parents. | Prueba del familiar: "replacement" sin glosa; 2.1 pasa a pantalla |
| Cover | You would expect them to shrink. | (eliminada) | El giro "Yet 84" llega a 0:12 (gancho ≤ 12 s) |
| Cover | Yet 84 are still growing: 66 because births still outnumber deaths, 18 only because more people arrive than leave. (19 palabras, 3 cifras) | Yet {84} are still growing. / {66} because births still outnumber deaths; {18} only because more people arrive than leave. | ≤ 18 palabras; cada cifra al final de cláusula, con aire |
| Slide 1 b0 | One: which lever moves each country's population, births, deaths or migration, and does that depend on region and income? | One: how do births, deaths and migration relate, and how does that differ by region, country and income? | P7 casi literal (faltaba "relate" y "country"); 19 → 18 palabras |
| Slide 1 b0 | Two: can one indicator tell the whole story? | Two: does one indicator tell the whole story, or only several together? | P8 casi literal: se oye la disyuntiva que luego se responde |
| Slide 1 b0 | Three: …travel the same road… watch on each? | Three: do countries share one road at different speeds, and what should the UN watch? | Tiempo (−3) |
| Slide 1 b0 | Grey always means the UN medium projection: a scenario, not a forecast. | After 2023, grey shows the UN medium projection: a scenario, not a forecast. | Falso: el gris también es fondo, estados < 1 M y la línea entre países |
| Slide 1 | Population change is bookkeeping: births minus deaths, plus net migration. | …plus net migration, arrivals minus departures. | Glosa en voz de net migration |
| Slide 1 | In today's high-income countries, net migration accounted for about seven in ten of the growth since 2000; elsewhere, growth came almost entirely from births exceeding deaths. (27) | Dos frases; "seven in ten" = `{share_mig_high_2000_2023.say}` | ≤ 18; cifra con clave |
| Slide 1 | Blue: growing from births, including 22 below replacement… | …including {22} countries below replacement… | Claridad |
| Slide 1 | Light blue: deaths exceed births, yet arrivals keep the population growing: … | Light blue: deaths exceed births, but arrivals keep it growing: … | Tiempo |
| Slide 1 | Purple: more people leave than arrive: … | Purple: more births than deaths, yet shrinking, as more people leave than arrive: … | El tipo E no se entendía (no decía que decrece ni que nacen más de los que mueren) |
| Slide 1 | Migration is also the least certain lever: the UN's own 95 percent range for the Emirates in 2050 runs from 8.9 to 33.3 million. (24) | Migration is also the least certain lever. / For the Emirates in 2050, the UN gives a 95 percent range of {8.9} to {33.3} million. | ≤ 18; redacción llana; glosa "95 % range" en pantalla |
| Slide 2 | Put each country on its own clock, years since its fertility fell below four, and the curves collapse onto one road. (21) | Set each country's clock to when its fertility fell below four children, and the curves line up. | ≤ 18; unidad; "own clock" se explica solo |
| Slide 2 | The road is shared; the speed is not: China went from five to three children in 5 years, Egypt in 33. (22) | The road is shared; the speed is not. / China went from five to three children in {5} years; Egypt took {33}. | ≤ 18; lema en frase propia |
| Slide 2 | …in 105 of 108 high-fertility countries, child mortality began a lasting fall at least 22 years before fertility. (22) | Child deaths moved first: in {105} of {108} high-fertility countries, typically at least {22} years before fertility. | **Error de lectura**: 22 es la cota inferior de la *mediana* del rezago, no de cada país |
| Slide 2 | Fertility began falling around 1970 in today's upper-middle-income countries, 1984 in lower-middle and 2000 in low-income ones. | (a pantalla; resumida en la respuesta: "latest in low-income countries") | Tres años seguidos sin aire; siguen en `fig05` y en el recuadro |
| Slide 2 | Within a country, halving child mortality goes with about 0.4 fewer children, less than half the gap across countries. | Within one country, this link is less than half what comparing countries suggests. | Prueba del familiar; la cifra queda en pantalla |
| Slide 2 | Migration has a short memory and almost no neighbourhood, except in the Gulf. | Migration moves on its own, alike among neighbours only in the Gulf, and weighs most in high-income countries. | Glosa llana del lema; añade ingreso; forma parte de la respuesta a P7 |
| Slide 2 | — | **Question one, answered: child deaths fell first and births followed, at each country's pace; latest in low-income countries.** | Respuesta explícita a P7 (relación + país + región + ingreso) |
| Slide 3 | Question two: can one number tell the story? / Take fertility. | Question two. | La pregunta ya se formuló literal en la build 0 (tiempo) |
| Slide 3 | Across countries, it captures the slow story, three quarters of the differences in age structure, but only 60 percent of today's growth and almost nothing of migration. (27) | Fertility alone captures the slow story: about {three quarters} of the differences in how old populations are. / But only {60} percent of today's growth, and almost none of migration. | ≤ 18; "age structure" → llano; claves `.say` |
| Slide 3 | Search each country's five closest look-alikes by fertility alone and you find only one in eight of its real look-alikes. (21) | It finds only {one in eight} of each country's closest look-alikes. | ≤ 18; "5" y "12 indicators" en pantalla |
| Slide 3 | By fertility, Colombia resembles…; by twelve indicators, … | `[OPCIONAL]` By fertility, our home country, Colombia, resembles…; by all twelve, … | Primera en recortarse; "our home country" = posicionalidad |
| Slide 3 | The data hold two real dimensions: fertility sits on the first, the transition, and is blind to the second, migration. (20) | Countries differ in two independent ways. / Fertility tracks the first, the transition to fewer births and deaths, but misses migration. | Glosa de "dimensions" y "transition"; ≤ 18 |
| Slide 3 | A composite index depends on its weights: one country in five can move twenty places. | Blend indicators into one score, and the weights can move {one in five} countries over twenty ranks. | Glosa de composite index; "more than 20" (el dato es > 20, no = 20) |
| Slide 3 | The Emirates and Belarus share the same fertility; … | (movida tras la respuesta, como su ejemplo) | P8 pide "no + dos dimensiones + ejemplo" |
| Slide 3 | — | **Question two, answered: no.** / **The story emerges only when indicators of both, transition and migration, are read together.** | Respuesta explícita a P8, eco literal de su redacción |
| Slide 4 | Grouping countries by seventy years of movement gives four roads. | Grouped by seventy-year paths, countries form three stretches of one road, plus a migration-led group, mostly Gulf states. | **Contradicción**: "four roads" vs "the road is shared" (Slide 2) y §12 (silueta 0,37: tres tramos + grupo migratorio); absorbe "A small migration-led group sits mostly in the Gulf" |
| Slide 4 | Early movers, such as … / Recent movers, such as … | Early movers, {…}, … / Recent movers, {…}, … | Tiempo |
| Slide 4 | Fast movers, …, changed within decades and are projected to age in about 24 years what Europe took 40 to 50. (24) | Fast movers, {…}, are projected to age in {24} years what took Early movers {40}. | "40 to 50" sin clave y "Europe" ≠ grupo (Italia 45, EE. UU. 49); ≤ 18 |
| Slide 4 | Neighbours tend to share a road, yet four in ten sit between two: a continuum, not boxes. | (a pantalla con `{join_same_road.say}` y `{share_between_groups.say}`) | Tiempo; "continuum" → "spectrum" en pantalla |
| Slide 4 | And countries grew closer in life expectancy but further apart in age. | Countries also grew closer in life expectancy, but further apart in age. | Ritmo (P1) |
| Slide 4 | — | **Question three, answered: mostly one road, at different speeds.** | Respuesta explícita a Q3 (P6) |
| Slide 4 | For the UN: watch child survival where it falls too slowly, ageing where populations still grow below replacement, and migration data where growth depends on arrivals. (26) | For the UN: watch child survival where child deaths fall too slowly. / Watch ageing where fertility is low but populations still grow. / Watch migration data where growth depends on arrivals. | "child survival … falls" era incorrecto (la supervivencia sube); ≤ 18; prueba del familiar |
| Cierre | How did we keep it honest? | (eliminada; lo dice el título de las tarjetas) | Tiempo |
| Cierre | Projections stay apart…; patterns, not causes; and every number, and our use of AI, is documented publicly. (31) | Projections stay apart from estimates; examples are chosen by rule; hypotheses were fixed before the final run. / These are patterns, not causes; every number and our use of AI are documented publicly. | ≤ 18; IA y reproducibilidad audibles |
| Cierre | One number can't tell eight billion stories, but three, read region by region, can tell the UN where to look next. (21) | One number can't tell eight billion stories. / But births, deaths and migration, read together region by region, can tell the UN where to look next. | "three" ambiguo para el público lego; eco de P8 ("read together") y P7 ("region") |

## 3. Cambios en pantalla, tablas y notas (principales)

| Dónde | Antes | Después | Motivo |
|---|---|---|---|
| Cabecera | — | Regla `.say` y lista de constantes de diseño | Ninguna cifra-resultado sin clave |
| Cover b1, b3 | `2.5 → 8.1`; `only through net arrivals` | `{world_pop_1950_bn} → {world_pop_2023_bn}`; `only because more arrive than leave` | Clave; llano y literal a la voz |
| Cover b2 | `replacement ≈ 2.1 … where almost every child survives` | `…: enough to replace the parents where almost every child survives` | Glosa |
| Slide 1 b0 | Tarjetas `Question 1 … 2 … 3 …`; `195 states + 42`, `161`; `grey: a scenario` | Texto literal de las tres preguntas con códigos P; `{n_states}`, `{n_territories}`, `{n_ge1m}`; `grey after 2023`; `{n_census_pre2009} … last census before 2009` | P7/P8 legibles; claves; calidad de datos (QuantaQuartet) |
| Slide 1 b2 | `64–78 % depending on classification vintage and period · a shared calendar, not country-by-country compensation` | `{share_mig_high_sens_range} % with other income lists and periods · a group total: it does not mean migration offsets low births country by country` | Clave; llano; evita el marco "fills the gap / replacement" |
| Slide 1 b3 | `growing only through net arrivals`; `15–25 depending on the year` | `growing only because more arrive than leave`; `{n_grow_only_migration_sens_range}` | Llano; clave |
| Slide 1 b5 | `2050: {pop} M · UN 95 % range…`; línea `if net migration were zero`; `77 of 161` | `UN medium projection, 2050: …`; `UN zero-migration scenario (a what-if, not a forecast)`; glosa `95 % range = the UN's band of likely values`; `{n_dir_uncertain_2050} of {n_ge1m}`; unidades | Proyección como escenario; contrafactual → variante ONU rotulada (§12); claves |
| Slide 1 mensaje | `about 7 in 10`; `In 18 countries` | `{share_mig_high_2000_2023.say}`; `countries and areas` | Clave; los 18 incluyen 7 áreas < 1 M |
| Slide 2 título | `…child mortality fell first` | `…child mortality fell first, fertility followed` | La relación de P7 en el título |
| Slide 2 mensaje | Orden y lema | Recuadro `Question 1 answered · …` (relación, país, región, ingreso con claves) | Respuesta legible sin buscar |
| Slide 2 b1 | Resaltes provisionales KOR, IND, KEN | Por regla: CHN (más rápido), mediano, EGY (más lento observado, ≥ 10 M); glosa de la banda P10–P90; unidades | La voz nombraba CHN/EGY y los resaltes otros países; KEN no llega a 3 |
| Slide 2 b2 | τ; `at least 22 years earlier`; `so the gap is a lower bound` | `years since fertility began to fall`; `typically at least…`; `so the true gap is probably longer`; glosas de child mortality, high-fertility y la banda | Exactitud (mediana) y lenguaje llano |
| Slide 2 b3 | Leyenda técnica | `dot = within one country (line: 95 % range) · dashed line = comparing countries · light grey band = what shuffled data give (no link)` + `simple view … richer view …` | Glosas de IC y placebo; comparación simple → rica rotulada (receta TRITICS) |
| Slide 2 b4 | Chip con r y Moran sin escala | `How alike? (0 = no link, 1 = identical)`; `same country, one decade to the next`; `neighbouring countries` | Prueba del familiar |
| Slide 3 título | `Can a single indicator tell the whole story?` | `Does one indicator tell the whole story — or only several together?` | P8 literal |
| Slide 3 b1 | `What fertility alone can explain`; `explained`; `10-fold cross-validation`; `an accounting identity`; `(UN projection)` | `What fertility alone captures`; `reproduces (0 = none, 1 = all)`; `same when tested on countries left out`; `true by definition (bookkeeping)`; `(UN medium projection)`; glosas de median age y death rate | E28 ("explain" suena causal); jerga |
| Slide 3 b2 | `two axes` antes de presentarlos; tarjeta A en b2 | Glosa de look-alike; `the two summary axes (right)`; tarjeta A pasa a b4 | Orden lógico y sincronía voz–resalte |
| Slide 3 b3 | `Axis 2 — migration & sex ratio vs ageing`; `axes beat noise`; `46–66 %` | `migration (and more men than women) vs ageing`; `axis = one summary of all 12 indicators`; `only {2} axes stand out from random noise`; `r = correlation, from −1 to 1`; `{pc1_var_sens_range}` (46–77) | Glosas; el rango 46–66 contradecía §12 (46–77) |
| Slide 3 b4 | `Composite index (5 indicators, 2,000 reasonable designs)`; `12,880 pairs` | `Composite index = one score blending 5 indicators (2,000 reasonable ways to build it)`; `{n_twin_pairs}` + regla de gemelos visible; recuadro `Question 2 answered` | Glosa; clave; respuesta |
| Slide 4 título | `Four roads through the transition — and what to watch on each` | `One road, four groups — and what to watch on each` | Coherencia con Slide 2 y §12 |
| Slide 4 method strip | `70 years × 4 indicators → k-means (k = 4) → checked with whole-curve analysis, 500 resamples and neighbours` | Indicadores nombrados; `k-means, which groups similar paths`; `500 random re-runs` | Glosas |
| Slide 4 mensaje | `Countries group by how they moved, not by where they stand today — …` | Recuadro `Question 3 answered · Mostly one road at different speeds: three stretches … plus a migration-led group …` | La v2 prometía quitar "not where they are" y seguía ahí; respuesta explícita |
| Slide 4 b1 | `Two in three … (chance: one in three)`; `Four in ten … continuum, not boxes`; rayado sin leyenda | Claves `.say`; `spectrum, not boxes`; `hatched = changes group in more than 1 in 5 re-runs…`; `{share_keep_ge_0.8} % … keep their group…`; línea de edad mediana 30 → 40 con claves | Claves; glosas; estabilidad en un número (ahzasasa) |
| Slide 4 b2 | `SD`; `the riskiest tenth … the safest` | `typical gap between countries, SD`; `the highest tenth of countries had …× the rate of the lowest tenth` | Glosa; lenguaje neutro |
| Slide 4 tabla | 6 columnas; `(UN projection)`; `30–40 more years`; `no pronatalist alarm`; `18 countries` | 5 columnas (mandato dentro de "For"); `(UN medium projection)`; `{momentum_years_range}`; `no alarm about birth rates`; `countries and areas` | Cabe en el PDF; escenarios; clave; llano |
| Slide 4 tarjetas | `it contains no shocks`; `census residual`; `hypotheses fixed …` | `no crises built in`; `inferred from census gaps`; `…, still exploratory` | Término ONU; llano; B.3/C.3 (las hipótesis salen de un EDA previo) |
| Slide 4 callback | `…but three, read region by region, can tell…` | `…but births, deaths and migration, read together region by region, can tell…` | Claridad |
| Referencias | `CC BY 3.0 IGO` sin más | Enlace a la licencia, cambios realizados y "the UN does not endorse this work"; Okabe & Ito (2008), Tol (2021) | Atribución exigida por la licencia; crédito (A.5) |
| §7 | Sin claves para rangos y conteos tecleados; `pc1_var` sens 46–66 | Claves nuevas (§5 de este archivo); 46–77 | Regla de cifras con clave |
| §8 | Glosas para 8 términos; PIE-1 sin aclarar | 22 términos con glosa; lista de términos que no salen en pantalla; regla de aire; PIE-1 = `estimates, 2023` | Prueba del familiar; coherencia con la decisión C1 |
| §9 | Sin prueba de altura; la tabla de la Slide 4 no cabía | Respuestas impresas; tarjetas en versión mínima; cálculo 1 024 px ≤ 1 080; recorte `.print-only` de las filas 1 y 3 | El PDF final cabe en portada + 4 + referencias (6 páginas) |

## 4. Cómo se contó (reproducible)

Extracción: líneas `>` bajo cada `**Narración (…)**`, sin comentarios QA ni la línea `[OPCIONAL]`; sustitución de cada `{clave}` por su valor provisional de §7 (listas de países con "and"; `.say` con su forma hablada); `len(texto.split())` = `wc -w`. Palabras habladas: cada número se cuenta como se lee ("2023" = 3, "130" = 3, "33.3" = 4…). Duración = habladas / 150 × 60 + 1,5 s por cifra hablada. Script usado (scratchpad de la sesión, no versionado): `count.py` + `extract.py`; se reproduce en 20 líneas de Python con esas reglas.

| Tramo | Palabras | Habladas | Cifras | Duración estimada | Frase más larga |
|---|---|---|---|---|---|
| Cover | 49 | 56 | 4 | 28 s | 18 |
| Slide 1 b0 | 60 | 62 | 0 | 25 s | 18 |
| Slide 1 b1–5 | 120 | 130 | 5 | 60 s | 17 |
| Slide 2 | 112 | 116 | 5 | 54 s | 18 |
| Slide 3 | 115 | 115 | 5 | 54 s | 18 |
| Slide 4 b1–3 | 115 | 115 | 2 | 49 s | 18 |
| Cierre | 57 | 57 | 0 | 23 s | 18 |
| **Total** | **628** | **651** | **21** | **4:52** | — |

Mismo modelo sobre la v2: 658 / 687 / 5:05, con 8 frases de 19–31 palabras.

## 5. Checklist ética (04 §4.2) aplicada a la narración v2.1

| ID | Resultado | Nota |
|---|---|---|
| S1 grep de verbos | Sí | Solo coincidencias permitidas: "because" contable (cover, mapa), "explain" narrativo ("One number can't explain that"), "replace their parents" (fecundidad de reemplazo definida), negaciones "not proof of cause", "patterns, not causes", "not a forecast", "not 'success'" |
| S2 futuro como proyección | Sí | "are projected to age"; "UN medium projection" en toda cifra ≥ 2024 en pantalla; sin "will" |
| S3 cifras con clave | Sí (pendiente de valores finales) | Ver §6 |
| S4 universo claro | Sí | "countries and areas" (237 y los 18); "high-fertility countries" con glosa (5+ hijos en 1950); "≥ 1 M" en pantalla |
| S5 sin generalizaciones contradichas | Sí | "Europe took 40 to 50" sustituida por claves de grupo; "Early movers … grow mainly through migration, or shrink" |
| S6 sin juicio de valor | Sí | "no alarm about birth rates"; "highest/lowest tenth" en vez de "riskiest/safest" |
| S7 terminología ONU | Sí | "crises"; nombres cortos admitidos en voz |
| S8 ejemplos según la definición | Sí (QA-stats) | Tipos 2023; CHN/EGY por la regla de velocidad; EAU por la regla de gemelos |
| S9 sin contrafactuales | Sí | "if net migration were zero" → "UN zero-migration scenario (a what-if, not a forecast)" |
| S10 incertidumbre y debilidad de la migración | Sí | "least certain lever" + rango 95 % de EAU en voz |
| S11 "patterns, not causes" | Sí | Slide 2 y cierre |
| S12 sin prometer de más | Sí | "still exploratory"; "mostly one road" |
| S13 recomendaciones con *watch* | Sí | Tres "watch" que remiten a la tabla y a las Slides 1–2 |
| S14 subtítulo = voz | Sí por diseño | Una línea `>` = un bloque |

Sin logos de la ONU (G12) y países nombrados solo por regla (G7): verificado en el texto; QA-viz lo confirma en las figuras.

## 6. Pendientes que dependen de cifras del notebook (`notebook-R` / QA-stats)

1. **Claves nuevas** que `R/05_numbers_json.R` debe producir: `world_pop_1950_bn` (2.5), `n_states` (195), `n_territories` (42), `n_ge1m` (161), `share_mig_high_sens_range` ("64–78"), `n_grow_only_migration_sens_range` ("15–25"), `pc1_var_sens_range` ("46–77"), `n_twin_pairs` (12 880), `momentum_years_range` ("30–40", [DEM]: confirmar método), y ya previstas en el plan de implementación: `n_census_pre2009` (23), `share_keep_ge_0.8`, `n_dir_uncertain_2050`.
2. **Variantes `.say`**: `share_mig_high_2000_2023.say` ("seven in ten"), `r2_tfr_medage.say` ("three quarters"), `r2_tfr_growth.say` ("60"), `knn_tfr.say` ("one in eight"), `share_rank_mc20.say` ("one in five"), `twin_growth_are.say` ("4"), `share_between_groups.say` ("four in ten"), `join_same_road.say` / `join_same_road_null.say` ("two in three" / "one in three"), `lookalikes_col_tfr.say` / `lookalikes_col_12.say`. `panel_within_halfq5.say` ya no se lee pero se conserva. Regla: si el valor final cambia de fracción redonda (p. ej. `knn_tfr` 0,16 → "one in six"), cambia el texto hablado, nunca se fuerza la fracción antigua.
3. **Envejecimiento por grupo**: `yrs_medage30_40_recent` y `yrs_medage30_40_early` deben ser medianas de **Fast movers** y **Early movers** (prototipo por cohorte de cruce: 24 / 40,5). Si no se calculan por grupo, aplicar la redacción alternativa de las notas de la Slide 4 ("countries that aged earlier").
4. **Regla de velocidad**: comprobar que China y Egipto son el más rápido y el más lento de 5 → 3 entre los ≥ 10 M que completaron el tramo; si no, cambian voz, línea de velocidad y resaltes de `fig04` (sin renombrar `dur53_chn` / `dur53_egy`).
5. **"Mostly Gulf states"**: comprobar con los miembros del grupo Migration-led (prototipo: Arabia Saudí, Jordania, EAU).
6. **"Latest in low-income countries"** y "weighs most in high-income countries": se apoyan en `yr_fert_onset_*` (1970 / 1984 / 2000) y `share_mig_high_2000_2023`; si el orden por ingreso no es monótono en la corrida final, se reescribe la respuesta a P7.
7. **"Migration moves on its own"**: confirmar en el notebook la compensación dentro del país (+0,01 ‰ [PN]), la paradoja tipo Simpson (≈ 0 dentro de cada ingreso [MV]) y R² TFR→CNMR (0,005).
8. **Variante Zero migration** de OtherVariants para el inset de EAU (existe en el archivo: 12,39 M en 2050 en `TPopulation1Jan`; usar `TPopulation1July` como el resto).
9. **Cronometraje real**: leer el guion con los valores finales; si pasa de 4:50, aplicar el orden de recorte de §0; si queda ≤ 4:42, puede entrar la frase de Colombia.
10. **Prueba de altura de la Slide 4** en el PDF real (QA-slides al 50 %): si una celda de la tabla pasa de 2 líneas, usar la versión `.print-only` indicada en §9.

## 7. Pendientes fuera del storyboard (no editados por este agente)

- `00_plan_analitico.md` §1–2 y §4: alinear el texto de Q1/Q2/Q3, el callback ("births, deaths and migration, read together region by region") y la frase de Q3 ("one road, four groups"; "three stretches of one road plus a migration-led group") con el storyboard v2.1; actualizar la frase de envejecimiento de §12 a las claves por grupo.
- `04_etica_ASA_aplicada.md` §3.3 y `badge()` en `R/config.R`: PIE-1 debe decir `estimates, 2023` (no "2021–23 average").
- `05_catalogo_visualizacion.md` / `figures-static`: leyendas llanas de §8 en `fig04`–`fig11` (bandas, placebo, rayado, r, SD).
- Equipo: decidir el rótulo de presentador en portada y cierre (consentimiento R9).
