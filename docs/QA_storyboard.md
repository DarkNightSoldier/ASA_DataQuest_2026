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

## 8. Cambios finales de guion (2026-10-25)

Agente **script-narration**. Fuente única de la voz: `slides/script/narration_en_template.md` (frases con `{claves}`) → `python slides/script/build_narration.py` → `slides/script/narration_en.md` (palabra por palabra), `captions.json`, `video_timings.json`, `captions.srt` y `data_captions.json`. Los bloques **Narración** de `docs/00_storyboard_diapositivas.md` y su §0 se regeneran desde el mismo cálculo (comprobado: las 55 frases del storyboard, de `narration_en.md`, de `video_timings.json` y del SRT son idénticas).

### 8.1 Resumen

| Medida | v2.1 (2026-10-23) | v3 final (2026-10-25) |
|---|---|---|
| Palabras (`wc -w`, cifra = 1) | 628 (+18 opcionales) | **603** (613 habladas); la frase opcional de Colombia se retira |
| Cifras habladas (un aire de 1,5 s cada una; "106 of 109" y "nine to thirty-three" = una) | 21 | **18** |
| Duración con el modelo del encargo (150 ppm + 1,5 s por cifra + 0,6 s por transición; paso con MP4 ≥ MP4 + 0,3 s) | 4:52 sin transiciones (≈ 5:14 con 31 transiciones y las referencias) | **4:54.1** con referencias (límite 4:55) |
| Gancho | "Yet 84" ≈ 0:12 | paradoja planteada antes de 0:11.6; "Yet 84" empieza a **0:11.6** |
| Respuestas audibles | 3 | 3: `Question one, answered` 2:28.5 · `Question two, answered: no` 3:24.9 · `Question three, answered` 4:12.5 |
| Frase más larga | 18 | **18** (55 frases) |
| Bloques de subtítulo | 1 línea `>` = 1 bloque | **70** bloques ≤ 90 caracteres y ≤ 2 líneas (≤ 52 caracteres por línea en el SRT); una frase se parte en sus marcas ` | ` solo si pasa de 90 |
| Cifras sin verificar o inexistentes en la voz | 3 en pantalla (`are_revision_pct`, `n_census_pre2009`, `repo`), 0 en la voz | **0**: `fill_numbers.py` y `build_narration.py` se niegan a escribir si aparece alguna |

Duraciones de los MP4 medidas con el ffmpeg 7.0.2 del venv (`imageio-ffmpeg`): fig01 12,6 s · fig02b 4,0 s · fig04 16,4 s · **fig07 14,9 s** (el encargo decía ≈ 6 s) · fig09 7,7 s · fig10 26,4 s. Todos sus pasos las cubren: s1.b2 12,9 · s1.b5a 4,3 · s2.b1 18,8 · s3.b1 16,0 · s3.b3 8,6 · s4.b1 27,3 s.

### 8.2 Cambios en la narración (antes v2.1 → después v3 → motivo)

| Paso | Antes (v2.1) | Después (v3) | Motivo |
|---|---|---|---|
| cover.b2 | In 2023, {130} of 237 countries and areas had below-replacement fertility: too few children to replace their parents. | In 2023, 130 countries and areas had too few children to replace their parents. | Gancho: con el modelo con transiciones el giro llegaba a 0:13; "of 237" y "fertility below replacement" + glosa siguen en pantalla |
| cover.b3 | {66} because births still outnumber deaths; … | 66 because births outnumber deaths; … | Tiempo ("still" ya está en "still growing") |
| s1.b0 | One: how do births, deaths and migration relate, and how does that differ by region, country and income? | One: how do births, deaths and migration relate, and differ by region, country and income? | Tiempo (−1,2 s); la tarjeta conserva la redacción completa de P7 |
| s1.b3b | including {22} countries below replacement, home to {2.2} billion people. | including 22 countries below replacement. | Recorte n.º 2 del orden de la v2.1 (−3,9 s); 2,2 mil M sigue en la etiqueta del mapa y en la tabla |
| s1.b4b | Orange: deaths exceed births, and the population shrinks: {examples_type_D} | Orange: deaths exceed births, and it shrinks: China, Russia and Japan. | Tiempo; nombre corto en voz (storyboard §8): la plantilla usa `{examples_type_D.voice}` y no lee "Russian Federation" |
| s1.b4c | Purple: more births than deaths, yet shrinking, as more people leave than arrive: … | Purple: births exceed deaths, but net departures make it shrink: Nepal, Azerbaijan and Uruguay. | Tiempo (−1,2 s) y paralelo con "arrivals keep it growing"; tipo E = NatChange > 0 y PopChange < 0 (`R/comun_analisis.R`), así que la migración neta negativa supera al saldo natural; "make" es contable, como "because" |
| s1.b5b | …the UN gives a 95 percent range of {8.9} to {33.3} million. | …the UN's 95 percent range is nine to thirty-three million. | Se usa el `say` de las claves ("nine", "thirty-three"), que se oye mejor; 8,9–33,3 en pantalla; tiempo |
| s2.b2 | Child deaths moved first: in {105} of {108} high-fertility countries, typically at least {22} years before fertility. | Child deaths started falling first in 106 of 109 high-fertility countries. / The gap was typically at least 22 years. | **Cambio obligatorio**: cifra verificada 106/109 (97 %; QA-stats §4); tres cifras en una frase → dos frases con la cifra al final; "typically at least" (cota inferior de la mediana, nunca "median"); "gap" en vez de "lead" para que no suene a *lead to* |
| s2.b3 | Within one country, this link is less than half what comparing countries suggests. | Within one country, this link is smaller than what comparing countries suggests. | **Cambio obligatorio**: el intervalo por bloques de −0,41 es [−0,77; 0,05] e incluye el 0, y la razón 2,5 no tiene intervalo estable (QA-stats §3.3); "less than half" afirmaba la razón. "Smaller" sí se sostiene: el intervalo dentro del país no llega al de entre países [−1,17; −0,92] |
| s3.b2 | It finds only {one in eight} of each country's closest look-alikes. | Fertility alone finds only one in eight of each country's closest look-alikes. | "It" seguía a "migration": antecedente ambiguo |
| s3.b3 | Countries differ in two independent ways. | Countries differ in two separate ways. | Los ejes del ACP son incorrelados, no independientes (precisión para el jurado de estadística) |
| s3.b4 | Blend indicators into one score, and the weights can move {share_rank_mc20.say} countries over twenty ranks. | Blend indicators into one score: the weights can shift one country in five by more than twenty places. | **Error de plantilla**: el `say` es "one country in five", así que salía "one country in five countries"; el dato es un intervalo de rangos de más de 20 puestos |
| s3.b4 | The story emerges only when indicators of both, transition and migration, are read together. | The story emerges only when transition and migration are read together. | Tiempo (−1,2 s); se mantiene el eco de P8 |
| s4.b1 | Early movers, {cluster_examples_early}, now grow mainly through migration, or shrink. | Early movers now grow mainly through migration, or shrink. | Tiempo (−2,4 s); las banderas USA, RUS y JPN están en la leyenda |
| s4.b1 | Fast movers, {…}, are projected to age in {yrs_medage30_40_recent} years what took Early movers {yrs_medage30_40_early}. | Fast movers, India, China and Indonesia, are projected to age from 30 to 40 in about 32 years. / About as fast as Early movers did, or faster. | **Cambio obligatorio**: Fast 32 [27–37] y Early 36,5 [29–42,5] se solapan, así que no se puede decir "en 32 lo que a otros les llevó 37". Nunca `yrs_medage30_40_fast_started`. Se parte en dos frases (la versión única tenía 27 palabras). Early = 37 solo en pantalla (fmt 0, ROUND_HALF_UP) |
| s4.b1 | Recent movers, {cluster_examples_recent}, still have high child mortality. | Recent movers still have high child mortality. | Tiempo; banderas en pantalla |
| s4.b2 | Countries also grew closer… | Countries grew closer in life expectancy, but further apart in age. | Tiempo |
| s4.b3 | For the UN: watch child survival where child deaths fall too slowly. | For the UN: watch child survival where it improves too slowly. | Tiempo; mismo sentido (la supervivencia sube) |
| s4.b4 | …hypotheses were fixed before the final run. / …every number and our use of AI are documented publicly. | …hypotheses were fixed in advance. / …every number and our AI use are documented publicly. | Tiempo |
| s3 (opcional) | [OPCIONAL] By fertility, our home country, Colombia, resembles … | (retirada) | No cabe en 4:55; la tarjeta B de Colombia sigue en pantalla con la nota "our home country" |

Sin cambios: el resto de frases de la v2.1, incluidas las tres respuestas, la frase de incertidumbre de EAU, "A sequence in time, not proof of cause", la ética y el callback.

### 8.3 Claves

**Usadas en la voz (25, todas `verified: true`):** `world_pop_2023_bn` (say), `n_below_replacement_2023`, `n_below_repl_growing_2023`, `n_below_repl_natural_growth_2023`, `n_grow_only_migration_2023`, `team_name`, `share_mig_high_2000_2023` (say), `n_momentum_countries`, `examples_type_C`, `examples_type_D`, `examples_type_E` (voice), `pop_are_2050_pi95_low`, `pop_are_2050_pi95_high` (say), `dur53_chn`, `dur53_egy`, `n_mort_first_onset`, `n_onset`, `lag_onset_lower_bound`, `r2_tfr_medage`, `r2_tfr_growth`, `knn_tfr`, `share_rank_mc20`, `twin_growth_are` (say), `cluster_examples_fast` (say), `yrs_medage30_40_recent` (say).

**Omitidas en la voz, con su motivo:**

| Clave | Motivo |
|---|---|
| `are_revision_pct` | `verified: false`: cifra externa (QA-stats §3.4). No se dice; la revisión del Golfo entre ediciones no se menciona en la voz |
| `n_census_pre2009`, `repo` | No existen en `numbers.json`. La voz dice "documented publicly", sin URL ni número |
| `yrs_medage30_40_fast_started` | Prohibida por el análisis verificado (no es la velocidad del grupo) |
| `yrs_medage30_40_early` | Solo en pantalla (37); la voz compara sin cifra ("about as fast … or faster") porque los intervalos se solapan |
| `panel_within_halfq5`, `panel_between_halfq5`, `panel_ratio_between_within`, `panel_eurna_halfq5` | Solo en pantalla. Dentro del país el intervalo incluye 0; la razón 2,5 nunca va con intervalo; Europa y N. América **se invierte** (+0,39). Lo debe decir el texto de fig06, no "not detected" |
| `pop_momentum_bn` | Recortada por tiempo (recorte n.º 2 de la v2.1); queda en pantalla |
| `cluster_examples_early`, `cluster_examples_recent`, `cluster_examples_migration` | Recortadas por tiempo; banderas en la leyenda de fig10 |
| `lookalikes_col_tfr`, `lookalikes_col_12` | Frase opcional de Colombia retirada (tiempo) |
| `share_mort_first` (say "97 in every 100") | La voz usa "106 of 109", el conteo verificado; 97 % queda en pantalla |
| `world_pop_1950_bn`, `pop_are_2050`, `join_same_road`, `share_between_groups`, `share_keep_ge_0.8`, `pct_var_fase` y el resto de cifras de pantalla | Solo en pantalla, igual que en la v2.1 |

### 8.4 Comprobaciones hechas

- `slides/script/fill_numbers.py`: redondeo **ROUND_HALF_UP** sobre `Decimal(repr(v))`, por ejemplo 36,5 → 37 y 0,735 → 0,74. Antes, el f-string de Python daba 36 y 0,73; en `numbers.json` solo cambian `moran_tfr_2023` (0,74) y `share_mort_first.sens_low` (95). Coincide con el `roundHalfUp` nuevo de `slides/js/numbers.js`. Ahora **rechaza con código 2** toda clave inexistente o con `verified` ≠ `true`, y explica el motivo (`nota_qa`), salvo con `--allow-unverified`. Se añadieron `{clave.voice}` (nombre corto de país en voz) y `{^clave}` (mayúscula inicial). `--check-html slides/index.html` (HTML vigente, 2026-10-25): 106 claves, 0 sin valor y 0 sin verificar.
- Deck real (Playwright + Chromium): los 32 `data-step` de `slides/index.html` están en el mismo orden que `video_timings.json`. Los `data-fragment-index` del HTML (p. ej. cover 2–5, s1 1–9) se renumeran en reveal a 0…n−1, y los dos números están en `captions.json` (`fragment_index`, `reveal_fragment`). La página carga los tiempos y muestra los subtítulos v3: el bloque más largo (90 caracteres) cabe en una línea de la barra. Capturas en el *scratchpad* de la sesión, no versionadas.
- Ética (04 §4.2, S1 *grep*): solo aparecen "because" (contable), "keep it growing" y "make it shrink" (contables, identidad del balance), "explain" (narrativo), "migration-led" (nombre) y las negaciones "not a forecast", "not proof of cause" y "patterns, not causes". No hay "will": el futuro es "are projected" y "the UN's 95 percent range".
- Glosas en voz: replacement ("too few children to replace their parents"), net migration ("arrivals minus departures"), UN medium projection ("a scenario, not a forecast"), transition ("to fewer births and deaths"), composite index ("blend indicators into one score"), groups ("three stretches of one road"). En pantalla: 95 % range, high-fertility, look-alikes, median age y R².

### 8.5 Pendientes para otros agentes y para el equipo

1. **slides (dueño de `index.html`)**: 16 `data-caption` siguen con el texto de la v2.1. Al grabar no importa, porque `video_timings.json` impone los subtítulos v3, pero sí cuentan como respaldo y para QA. Copiar `slides/script/data_captions.json`. En la fila de fig06: "reverses in Europe & N. America (+0.39)" en lugar de "not detected". Opcional: la tarjeta Q1 puede seguir con la redacción completa de P7.
2. **Equipo / repo-ops**: "every number and our AI use are documented publicly" exige que el **repositorio público exista antes de grabar**. Si no existe, cambiar a "documented in our notebook" y regenerar.
3. **Grabación de la voz**: cronometrar la lectura real. Si pasa de 4:55, aplicar el orden de recorte del storyboard §0; nunca recortar las respuestas, el rango de EAU ni la frase de *Fast movers*. Pronunciación: "UNALSta-R" = *u-nal-sta-ar*.
4. **figures-static**: fig07 dura 14,9 s, no ≈ 6 s. Ya está cubierto, pero si se acorta se puede ganar ≈ 0,8 s en s3.b1.
