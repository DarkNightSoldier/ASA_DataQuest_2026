# QA-ethics · Revisión como jurado de *Best Consideration of Ethics*

Agente **QA-ethics** (IA, Claude Code) · 2026-10-25 · checklist de `docs/04_etica_ASA_aplicada.md` §4 (G1–G18, S1–S14, N1–N18, R1–R10) y verbos prohibidos de §4.5.
Archivos revisados: `slides/script/narration_en.md` (v3, 32 pasos, 55 frases), todos los textos en pantalla de `slides/index.html` (pasos de vídeo y versión `print-only`, tarjeta de ética y referencias), las **6 páginas** de `slides/export/slides.pdf` (renderizadas a PNG y vistas una por una), las capturas de vídeo `slides/dev/screenshots/steps/{cover.b3,s1.b0,s1.b5a,s4.b4}.png`, `figures/static/fig04_same_road_registration.png` y `fig10_trajectory_groups.png`, el `README.md` y el notebook `notebook/analisis_wpp2024.ipynb` (celdas 0–2, 33 y 307–313, y búsqueda de terminología en todas las celdas markdown).
Archivos creados: este informe, `docs/correcciones.md` (lo cita el notebook y no existía) y `docs/qa_etica.csv` (respuestas Sí/No/Parcial/N.A. por ítem, como pide §4). No se editó `index.html` ni la narración: lo hará el corrector.

## 1. Veredicto

**Puntuación: 7,5 / 10** (justificación en §5). Con las 4 correcciones altas, la estimo en **9–9,5**.

**No grabar ni enviar** hasta resolver los hallazgos **altos**. Tres de ellos tocan ítems bloqueantes de la checklist: S2 (en el PDF), R1 y R2. El cuarto (H1) es el más delicado para un jurado de ética: la declaración de uso de IA hoy **resta** el papel de la IA y presenta como revisión del equipo una verificación que hizo un agente de IA.

Comprobaciones automáticas:

| Comprobación | Resultado |
|---|---|
| Claves `data-num`/`data-flags`/`data-list` del HTML contra `figures/numbers.json` | 105 claves: 103 directas y 2 alias, todas `verified: true`. Los 2 alias son (`n_twin_pairs` → `n_pairs_twins`; `pc1_var_sens_range` → `sens_low`–`sens_high` de `pc1_var`, verificada) y ninguna clave inexistente ni sin verificar |
| Cifras habladas (`narration_en.md`, tabla final) | 25 claves, **todas verificadas**. No se oye `are_revision_pct`, `n_census_pre2009`, `repo` ni `yrs_medage30_40_fast_started` |
| Cambios obligatorios del análisis verificado | Aplicados en voz, pantalla y PDF: "106 of 109" (97 %), "typically at least 22 years", "smaller than what comparing countries suggests" sin intervalo de la razón, "reversed in Europe & N. America (+0.39)", frase de Fast movers en s4.b1, Early = 37, afiliación exacta de `equipo.json`, sin logos y atribución CC BY 3.0 IGO |
| Subtítulos = voz (S14) | 32 de 32 `data-caption` idénticos a `narration_en.md` (script de comparación) |
| *Grep* §4.5 (voz y pantalla) | Solo coincidencias contables o negadas ("because", "keep it growing", "make it shrink", "not proof of cause", "patterns, not causes"). Dos casos a corregir: "richer view" dentro de fig06 (M5) y "too slowly"/"still" (L1, L2). No aparece "will", "drive", "rich/poor" (salvo M5), "significant", "shock", "illegal", "wave" ni "burden" |
| PDF | 6 páginas (portada + 4 + referencias), 1440 × 810 pt; sin logos de la ONU; pie PIE-0 en las 4 de contenido |

## 2. Tabla de hallazgos

Severidad: **alta** = bloquea grabar o enviar (ítem bloqueante o afirmación falsa sobre nuestra propia práctica); **media** = un jurado de ética lo puede notar o es engañoso en una lectura razonable; **baja** = pulido. Las cifras de las correcciones son **solo claves verificadas** (se escriben como `{clave}` cuando van en el HTML).

| ID | Sev. | Dónde | Problema | Corrección exacta propuesta (inglés en pantalla y voz) |
|---|---|---|---|---|
| **H1** | **alta** | `index.html` · Referencias, "AI assistance & reproducibility" (1.ª viñeta); tarjeta de ética 5 "Open & checkable"; voz s4.b4; notebook §9.6, §11 y celda 33 ("prototipos de siete asesores"); README (no hay declaración) | La declaración dice *"Claude Code … was used as an assistant to draft code and text. The team reviewed it"*. En este proyecto, agentes de IA escribieron el código R, corrieron los análisis, redactaron los 7 memos de "asesoría" (`docs/06_*`, agentes de IA, no personas), produjeron las figuras, las diapositivas y el guion, e hicieron la verificación "independiente" (QA-stats también es un agente). El notebook dice *"el equipo revisa cada número (`verified` … que marca QA-stats)"*: confunde una verificación hecha por IA con una revisión humana. No hay registro de revisión humana (`docs/registro_ia.md` y `docs/verificacion_numeros.csv` no existen). Subdeclarar la IA o sobredeclarar la revisión humana va contra A.5, B.2, C.2 y E.3, y es lo primero que comprobaría este jurado | **Referencias:** "AI assistance: Claude Code (Anthropic) AI agents, directed by the team, wrote most of the R code, the analysis memos, the figures and drafts of the slides and script. A separate AI-written script re-computed every number shown or said from the raw UN files. Team members [write only what you really did, e.g. chose the questions, reviewed every slide and checked key numbers by hand]. Log: docs/registro_ia.md." · **Tarjeta 5:** "hypotheses fixed {hyp_file_date} (sha256 {hyp_file_sha256_short}), still exploratory · examples by rule · AI agents wrote code and text; a second script re-computed every number · public repository" · **Notebook §9.6 (ES):** "Uso de IA: agentes de IA (Claude Code, de Anthropic), dirigidos por el equipo, escribieron la mayor parte del código, los memos de asesoría, las figuras y los borradores del guion. `verified: true` lo marca un agente de IA (QA-stats) que recalcula cada cifra con código independiente; la revisión humana queda en `docs/registro_ia.md`." · **Celda 33:** "prototipos de siete agentes asesores de IA". · Crear `docs/registro_ia.md` (fecha · tarea · agente · quién revisó · qué cambió) y `docs/verificacion_numeros.csv` firmados **por personas** antes de enviar |
| **H2** | **alta** | Voz s4.b4 (*"documented publicly"*); `.eth-lead` (*"our public notebook"*, solo vídeo); tarjeta 5 (*"public repository"*); Referencias, 2.ª viñeta (*"are in our public repository (code MIT; texts CC BY 4.0)"*) | **Hoy es falso:** `git remote` está vacío, `docs/equipo.json` tiene `repo: null` y no hay `LICENSE` ni `CITATION.cff`, así que "code MIT; texts CC BY 4.0" no está declarado en ningún archivo de licencia. Es el ítem bloqueante R1 (F.4, C.6) y además una afirmación falsa sobre nuestra propia práctica (C.2) | **Opción A (preferida; publicar requiere permiso explícito del equipo):** publicar el repositorio en GitHub **antes de grabar**; añadir `LICENSE` (MIT), `LICENSE-texts` (CC BY 4.0) y `CITATION.cff`; etiquetar `v1.0-submission`; rellenar `repo`/`repo_url` en `docs/equipo.json`, pasar `repo` por QA-stats (`verified: true`) y usar en Referencias: "Code, notebook, figures and pre-specified hypotheses: github.com/{repo} (tag v1.0-submission; code MIT, texts CC BY 4.0)." · **Opción B (si no se publica a tiempo):** voz s4.b4 → "These are patterns, not causes; every number and our AI use are documented in our notebook."; `.eth-lead` → "Every number is regenerated by our notebook."; tarjeta 5 → quitar "· public repository"; Referencias → "Code, notebook, figures and pre-specified hypotheses are available from the team (code MIT; texts CC BY 4.0)." |
| **H3** | **alta** | Slide 4, tabla "What to watch": filas 1 y 3 (`span.print-only`) y fila 2 (vídeo y PDF). PDF pág. 5 | En el **PDF**, tres afirmaciones de futuro aparecen como hechos, sin "UN medium projection": *"58 of 70 stay above 25 per 1,000 in 2030"*, *"106 by 2050"* y *"34–38 more years of growth"* (en la fila 2 la etiqueta falta también en el vídeo, aunque `rec_rows` la trae: "UN medium"). Es el ítem bloqueante S2/G3 (B.2, C.2). Además, en el PDF *"53 countries (28 %)"* pierde "of humanity" y se lee como % de países (53 de 237 es 22 %) | **Fila 1 (`print-only`):** "child deaths fall too slowly: {n_sdg32_above_2030} of {n_sdg32_above} above 25 per 1,000 projected to stay above it in 2030 (UN medium)" · **Fila 2 (ambas versiones):** "{momentum_years_range} more years of projected growth (UN medium) in working and older ages: pensions and long-term care now; no alarm about birth rates" · **Fila 3 (`print-only`):** "deaths outnumber births: {n_natneg_2023} countries ({share_pop_natneg_2023} % of humanity); {n_natneg_2050} projected by 2050 (UN medium)". Comprobar después la altura de la tabla en el PDF (QA-slides) |
| **H4** | **alta** | `README.md` | Ítem bloqueante R2. El README está solo en español y no tiene limitaciones, declaración de IA, conflictos de interés, privacidad, licencias de terceros, descargo de mapas, "what we did not find" ni cómo citar. Dice "237 países" (no "y áreas"), enlaza la página web de la ASA en vez del DOI y promete demasiado: *"Todo el trabajo estadístico de este proyecto sigue los ASA Ethical Guidelines"* (S12; el propio memo de ética pidió quitar esa frase del vídeo) | Sustituir "## Ética" por una sección bilingüe (EN + ES de `04_etica` §5.2–5.3) con estas cifras verificadas: "## Limitations & ethical considerations — We follow the ASA Ethical Guidelines for Statistical Practice (2022), https://doi.org/10.5281/zenodo.7092386. **Data [B.1, D.10]:** UN DESA, Population Division (2024), World Population Prospects 2024 (CC BY 3.0 IGO), original July 2024 file; 1950–2023 = UN model-based estimates; 2024–2100 = UN medium projection, a scenario, always in grey; the UN's January 2026 interim update for Togo is not applied (docs/correcciones.md, C-46). **Weakest component [B.2, C.4]:** net migration (arrivals − departures) is often inferred by the UN from census gaps; its projections rest on expert assumptions. **Uncertainty [B.2]:** UAE 2050: 15.4 M on the UN medium line, UN 95 % range 8.9–33.3 M; for 77 of 161 countries the 2050 range includes both growth and decline. **Countries, not aggregates [B.1]:** each of the 237 countries and areas is counted once; models use the 161 with ≥ 1 M people. **Choices that matter [A.2, B.7]:** income groups = World Bank FY2027, applied to all years; lever types use 2023 (15–25 'grow only through migration', depending on the year). **Exploratory, not causal [B.3, C.3]:** hypotheses were fixed on 2026-10-23 (commit 2a0ab7b, sha256 83f98f6e1a3d) before the final run, but written after exploring the same data; what we did not find: notebook §8. **Fair framing [A.8, D.6]:** groups describe demographic paths, not development or worth; UN names and terminology. **Examples chosen by rule [A.4]:** the three most populous countries (≥ 1 M) of each type or group; full lists in figures/miembros_*.csv; Colombia appears as our home country. **Privacy [D.4]:** no personal data; national aggregates only. **AI use [A.5, B.2]:** (same text as H1). **Conflicts of interest [A.7]:** none; no funding; not affiliated with the UN or the World Bank. **What this project is not [A.1]:** not a UN product, not our own forecast, not a causal study, not a ranking of countries. **Corrections [B.5]:** docs/correcciones.md. *Boundaries and names shown on maps do not imply official endorsement or acceptance by the United Nations.*" + "How to cite" + licencias de terceros (World Bank CC BY 4.0, Natural Earth dominio público, reveal.js y flag-icons MIT, Lato OFL). En la parte ES: "237 países y áreas" y quitar "Todo el trabajo … sigue" |
| **M1** | media | `.eth-lead` (vídeo): *"UN estimates (≤ 2023) and UN projections (≥ 2024) are never mixed"*; voz s4.b4: *"Projections stay apart from estimates"*; notebook celda 0: *"ningún estadístico usa una ventana que cruce 2023/2024"* | Promete de más (S12, C.2). La misma diapositiva enseña cifras que **combinan** las dos cosas: `yrs_medage30_40_recent` (32; "mostly a projected speed"), `yrs_medage30_40_early` (estimaciones + proyección), `momentum_years_range` (de 2023 al pico proyectado) y las curvas de fig10 de 1950 a 2050. Están bien rotuladas, pero "never mixed" es falso | **`.eth-lead`:** "UN estimates (≤ 2023) and UN projections (≥ 2024) are always told apart: grey after 2023." · **Voz s4.b4 (16 palabras, +1):** "Projections are labelled as scenarios; examples follow a rule; hypotheses were fixed before the final run." · **Notebook celda 0 (ES):** "…ningún estadístico usa una ventana que cruce 2023/2024, salvo las velocidades de envejecimiento (`yrs_medage30_40_*`) y los años hasta el pico (`momentum_years_range`), que combinan estimaciones y proyección Medium y se rotulan así." |
| **M2** | media | Voz s4.b4 (*"hypotheses were fixed in advance"*); Referencias, 2.ª viñeta (*"pre-specified hypotheses (fixed 2026-10-23 …)"*) | Sin la salvedad, "in advance" se oye como un prerregistro confirmatorio. Las hipótesis se escribieron **después** de explorar los mismos datos (notebook celda 33; `hyp_file_date.sens_note`) (B.3, C.3). La tarjeta 5 del vídeo sí dice "still exploratory"; la voz y las referencias, no | **Voz:** "…hypotheses were fixed before the final run." (ya incluido en M1; era el texto de la v2.1) · **Referencias:** "Code, notebook, figures and pre-specified hypotheses (fixed {hyp_file_date} before the final run, after exploring the same data — not confirmatory; sha256 {hyp_file_sha256_short}) …" |
| **M3** | media | Voz cover.b3 (*"66 because births outnumber deaths"*); voz s1.b3–b3b (*"Blue: growing from births, including 22 countries below replacement"*); leyenda del mapa (*"Below replacement, still growing from births: 22"*; *"Growing from births 165"*); fila 2 de la tabla | El oyente oye **66** países bajo reemplazo que crecen por nacimientos y, un minuto después, **22** para lo que parece el mismo grupo. Los 66 son TFR < 2,1 con nacimientos > muertes; los 22 son el subconjunto **sin llegadas netas** (tipo B). En los otros 44, que también reciben inmigración, decir "because births outnumber deaths" atribuye a los nacimientos un crecimiento que puede venir sobre todo de las llegadas, y eso contradice el mensaje de la propia Slide 1 ("about seven in ten" en ingreso alto). Afecta a S4 y S5 (C.2) | **Voz cover.b3:** "66 have more births than deaths; 18 grow only because more people arrive than leave." · **Voz s1.b3b:** "including 22 below replacement that grow with no net arrivals." · **Leyenda (`lg-ex`):** "Below replacement, growing from births with no net arrivals: {n_momentum_countries} countries, {pop_momentum_bn} bn people" · **`lg-lab` azul:** "Growing, with more births than deaths" · **Tabla, fila 2:** "fertility is below replacement, yet the population grows with no net arrivals: {n_momentum_countries} countries, {pop_momentum_bn} bn". Regenerar subtítulos y tiempos con `build_narration.py` |
| **M4** | media | Slide 1, tarjeta de datos (vídeo, s1.b0): *"237 countries and areas (195 states + 42 territories)"*; `def`/unidad de `n_territories` | Los 42 incluyen *China, Taiwan Province of China*, *Kosovo (under UNSC res. 1244)*, el Sáhara Occidental y Hong Kong RAE. Llamarlos "territories" es un juicio sobre su estatus que la ONU evita: usa "countries or areas" (D.6, G11) | "237 countries and areas (195 UN Member and observer States + 42 other areas)". En `numbers.json` (dueño: notebook-R), unidad "other areas" en vez de "territories and areas" |
| **M5** | media | fig06 (Slide 2; PDF pág. 3), leyenda: *"dot = the same country over time (richer view)"* y *"dashed = comparing countries, −1.05 (simple view)"*; `R/fig_q1_slide2.R` l. 1120 | Junto a filas "Low income … High income", "richer view" se lee como "rich" (coincidencia del *grep* S1/G10). Además, "richer" y "simple" juzgan el método en vez de describirlo | "dot = the same country over time (within-country view)" · "dashed = comparing countries, {panel_between_halfq5} (between-country view)". Regenerar `fig06_within_vs_across_forest{,_print}.png` |
| **M6** | media | `docs/equipo.md`: *"Daniela C. Kwan"*; `docs/equipo.json`, portada, README y memoria: *"Daniel"* sin la "a" final (resuelto el 2026-10-25: el nombre correcto es "Daniela C. Kwan"; `docs/correcciones.md` §G) | Nombre de un integrante distinto según el archivo. El crédito y la autoría deben ser exactos (A.5, G.4) | Un miembro del equipo confirma la grafía correcta; se corrige el archivo equivocado. La portada lee `equipo.json` |
| **M7** | media | Notebook, celda 0 (ítem bloqueante N1) | La primera celda cita WPP 2024 y CC BY 3.0 IGO, pero no la ASA (2022) ni la **fecha de descarga** de los archivos WPP (§0 solo da la fecha del API del Banco Mundial) | Añadir a la celda 0 (ES): "Ética: American Statistical Association (2022), *Ethical Guidelines for Statistical Practice*, https://doi.org/10.5281/zenodo.7092386 · archivos WPP 2024 descargados el {fecha, la confirma el equipo}; SHA-256 en §9.1 y en `data/README.md`." Añadir a `data/README.md` el SHA-256 de `OtherVariants` (hoy solo está en el notebook) |
| **M8** | media | Tabla, fila 2: *"34–38 more years of growth"* para "22 countries, 2.2 bn" | `momentum_years_range` es el P25–P75 **ponderado por población**: lo domina India (mediana ponderada 38; sin India 19–34; mediana sin ponderar 25). Escrito así, parece que los 22 países tienen 34–38 años más de crecimiento (generalización, S5, C.2) | Con H3: "{momentum_years_range} more years of projected growth (UN medium) for most of their {pop_momentum_bn} bn people, in working and older ages: …" |
| **M9** | media | Repositorio (R3, R6, N2, N11) | Faltan `docs/decisiones_de_datos.md` (§4.6; el notebook resume las decisiones en la sección 1, pero no existe el registro vivo), `CITATION.cff` con los autores y el rol de cada uno, y `renv.lock` o una declaración de que no se usa (`sessionInfo()` sí está) | Crear `CITATION.cff` (4 autores, título, versión `v1.0-submission`, licencia) y `docs/decisiones_de_datos.md` con D-01…D-21 rellenadas desde el notebook. Si no hay `renv`, en el README: "Package versions: sessionInfo() in notebook §10 (no renv lockfile)." |
| **L1** | baja | Voz s4.b3 (*"watch child survival where it improves too slowly"*); tabla, fila 1 (*"child deaths fall too slowly"*) | En la voz no se dice con respecto a qué, así que suena a juicio; en pantalla el criterio es el ODS 3.2 (25 por 1 000 en 2030). Además, la misma celda mezcla dos bases sin decirlo: 58 sale de la proyección Medium y "8 on pace" del ritmo observado en 2015–23 | **Voz:** "For the UN: watch child survival where it is off pace for the 2030 goal." · **Tabla (vídeo):** "… · {n_sdg32_on_pace} on pace at their 2015–23 rate" |
| **L2** | baja | Voz s4.b1: *"Recent movers still have high child mortality."* | "still" sugiere un retraso respecto de un camino normativo (§2.6: evitar "still behind") | "Recent movers have the highest child mortality today." (respaldo verificado en `cluster_profile`: mediana de Q5 de 2023 = 50,3 frente a 16,0, 6,3 y 3,8 en los otros grupos) |
| **L3** | baja | Título de la Slide 1: *"Which lever moves each country's population: births, deaths or migration?"* | "moves" da agencia a la palanca. Ya está definida como "a component of the population balance, not a policy switch", y la tarjeta de la pregunta usa la redacción de P7 | Opcional: "Which component accounts for each country's population change: births, deaths or migration?" |
| **L4** | baja | Slide 1, tarjeta de EAU; Slide 3, Portugal y Chad | En pantalla no se dice por qué se eligieron los EAU ni Portugal–Chad. Los eligió una regla (`twin_*` y `cdr_prt`, "top pair of rule \|ΔCDR\| ≤ 0.1 with largest \|Δ life expectancy\|"), pero la voz afirma "examples are chosen by rule" y aquí no se ve (G7) | **EAU, `fn`:** "… · UAE: the twin picked by rule in Question 2" · **Slide 3, `fn`:** "Portugal and Chad: the pair picked by rule (same death rate ± 0.1, largest life-expectancy gap)" |
| **L5** | baja | Referencias, viñeta del Banco Mundial | No dice la licencia de los datos del Banco Mundial (C.7, A.5) | "World Bank (2026). Country and Lending Groups, FY2027 (effective 1 July 2026; 2025 GNI per capita, Atlas method). API download 2026-10-22. CC BY 4.0." |
| **L6** | baja | Notebook, celda 165 (*"se parece a países ricos de baja fecundidad"*), celda 63 (*"Nadie se va de los países pobres"*), celda 307 (columna "Qué lo sustituye": *"Projected to age in about 25 years what Europe took 40 to 50"*) | "ricos" y "pobres" (N17, §2.6). La fila de la celda 307 quedó desactualizada respecto del guion v3 | "países de ingreso alto con baja fecundidad"; "'Nadie se va de los países de ingreso bajo' no se sostiene"; fila → "Projected to age from 30 to 40 in about 32 years, about as fast as Early movers did, or faster" |
| **L7** | baja | `docs/equipo.json` y `docs/equipo.md` (correo personal de contacto); metadatos de los commits; vídeo (rótulo de presentador) | Cuando el repositorio sea público, el correo personal quedará expuesto (R10, D.4). No hay constancia del consentimiento de cada miembro para su nombre, voz o imagen (R9) | Confirmar el consentimiento por escrito o usar un correo institucional o *noreply* de GitHub antes de publicar. Si alguna voz del vídeo es sintética, declararlo en Referencias |
| **L8** | baja | Tarjeta de datos (vídeo): *"Some countries and areas have had no census since before 2009: their figures rest more on UN modelling"* | Bien reformulada sin cifra (la clave no existe), pero sin fuente: es la única afirmación de la tarjeta que el repositorio no respalda | Añadir "(UN DESA 2024, Summary of Results)" o bajarla a las notas del notebook |
| **L9** | baja | fig10 (Slide 4): *"grey = UN medium projection after 2023"*; respuesta Q3 *"Mostly one road at different speeds"* | Los grupos salen de 1950–2023 (bien), pero las curvas siguen hasta 2050 y la convergencia proyectada es un **supuesto** del modelo de la ONU (teoría de la transición, E20). Sin decirlo, el tramo gris parece confirmar el "one road" | Pie de fig10: "grey = UN medium projection after 2023, which assumes the transition continues" |

## 3. Checklist §4 (resumen; detalle en `docs/qa_etica.csv`)

### 3.1 Gráficas (G1–G18)

| ID | Resp. | Nota |
|---|---|---|
| G1 título sin verbos causales [B] | Sí | Títulos descriptivos. "Which lever moves…" es leve (L3) |
| G2 PIE-0 + badge [B] | Sí | PIE-0 en las 4 diapositivas, más "countries only, no aggregates"; el filtro va en cada figura |
| G3 2023/24 con línea, gris y etiqueta [B] | Sí en figuras; **No en la tabla del PDF** | fig03, fig07 (2050 discontinuo, "UN medium projection") y fig10 (punteado en 2023, gris) bien. Tabla del PDF: H3 |
| G4 países vs agregados [B] | Sí | 8,1 mil M = suma de los 237 (QA-stats) |
| G5 cifras = `numbers.json` [B] | Sí | 103 claves verificadas + 2 alias verificados; constantes de diseño declaradas |
| G6 filtro visible | Sí | "161 countries ≥ 1 M, 2023", "237 countries and areas", "estimates 1950–2023" |
| G7 resaltes por regla [B] | Parcial | CHN/COL/EGY, banderas y medoides por regla y en código; Colombia con posicionalidad declarada. EAU y PRT–TCD sin la regla en pantalla (L4) |
| G8 ejes honestos | Sí | Barras desde 0; R² de 0 a 1 |
| G9 paleta sin semáforo | Sí | Okabe-Ito; naranja y púrpura sin carga |
| G10 nombres neutrales | Parcial | Early/Fast/Recent movers y Migration-led bien; "richer view" (M5) |
| G11 nombres ONU + descargo de mapas | Parcial | Descargo en fig02 y fig10 y en Referencias; "42 territories" (M4) |
| G12 sin logos de la ONU [B] | Sí | Solo texto; el pie de Referencias lo declara |
| G13 proyección clave con PI | Sí | EAU 2050 80/95 %; 77 de 161 con rango que incluye crecer y decrecer |
| G14 migración con PIE-6 | Parcial | Slides 1 y 2 sí; fig09 y fig10 usan la migración sin la nota (aceptable por espacio) |
| G15 microestados visibles sin dominar | Sí | Franja "Under 1 M people · 76"; modelos con ≥ 1 M |
| G16 identidad explicada | Sí | "true by definition (bookkeeping)" |
| G17 legibilidad | N.A. | Lo cubre QA-slides (al 50 %) |
| G18 PNG con *alt text* en el README | Parcial | El HTML del notebook tiene 50 imágenes con texto alternativo; el README no |

### 3.2 Guion y textos en pantalla (S1–S14)

| ID | Resp. | Nota |
|---|---|---|
| S1 *grep* [B] | Sí, con 3 arreglos | Solo usos contables o negados; M5, L1, L2 |
| S2 futuro = "projected" [B] | **No (PDF)** | La voz y el vídeo sí ("are projected", "in the UN medium projection"); el PDF no (H3) |
| S3 cifra hablada con clave [B] | Sí | 25 claves verificadas |
| S4 universo claro | Parcial | 66 frente a 22 (M3) |
| S5 sin generalizaciones contradichas | Parcial | "66 because births…" (M3); "34–38 more years" (M8) |
| S6 sin juicio de valor | Sí | "no alarm about birth rates", "voluntary family planning", "migrant inclusion"; L1 y L2 son matices |
| S7 terminología ONU | Parcial | En voz, nombres cortos admitidos; "territories" (M4). No hay crisis, VIH ni refugiados en pantalla; en el notebook están bien nombrados ("genocidio contra los tutsis en Ruanda (1994)", "epidemia de VIH/sida") |
| S8 ejemplos según la definición [B] | Sí | Tipos de 2023, "in 2023" en voz y pantalla, rango 15–25 |
| S9 sin contrafactuales | Sí | "UN zero-migration scenario (a what-if, not a forecast)" |
| S10 incertidumbre + debilidad de la migración | Sí | "least certain lever" + 95 % de EAU en voz |
| S11 "patterns, not causes" | Sí | s2.b3 y s4.b4 |
| S12 no prometer de más | **No** | "never mixed" (M1), "fixed in advance" (M2), "public" (H2), "The team reviewed it" (H1) |
| S13 recomendaciones con *watch* | Sí | Tres "watch" en voz y "Watch / prepare" en la tabla |
| S14 subtítulo = voz | Sí | 32/32 |

### 3.3 Notebook (N1–N18)

| ID | Resp. | Nota |
|---|---|---|
| N1 [B] | Parcial | Falta la ASA y la fecha de descarga en la celda 0 (M7) |
| N2 | Parcial | Sección 1 "Decisiones de datos" sí; `docs/decisiones_de_datos.md` no (M9) |
| N3 [B] | Sí | `R/tests_datos.R` 7/7; identidad contable |
| N4 | Sí | Ficha *fitness for use* honesta: dice lo que **no** se calculó (censos, Togo, T14) |
| N5 [B] | Sí | Commit `2a0ab7b`, SHA-256 coincide (lo comprobé); fallos reportados (H2, H7, H8, H9) |
| N6 | Sí | Etiquetas *Pre-specified / Exploratory / Descriptive*; "nada es causal" |
| N7 | Sí | Familias F1 (Holm) y F2 (BH); ningún p-valor en el vídeo |
| N8 | Parcial | Muchas sensibilidades (año, ≥ 1 M, winsorización, umbrales, ingreso con agregados ONU); Togo no se corrió (declarado) |
| N9 | Sí | EAU y China, "no pueden sumarse" |
| N10 [B] | Sí | `figures/miembros_*.csv`, `lookalikes_todos.csv` |
| N11 [B] | Parcial | Semilla, `RNGkind`, `sessionInfo()` y SHA-256 sí; sin `renv.lock` (M9) |
| N12 [B] | Sí | `numbers.json` desde `R/05`; `fill_numbers.py` rechaza claves sin verificar |
| N13 | Sí | Lecturas con cifras reales |
| N14 [B] | Parcial | §9 completa, pero con la declaración de IA errónea (H1) y la convención de la celda 0 contradicha (M1) |
| N15 | Sí | §8 "Lo que no encontramos", con 18 filas y los cambios de la corrida final |
| N16 | **No** | Hay declaración de IA, pero no tabla de verificación **humana** (H1) |
| N17 | Parcial | Nombres ONU sí; "ricos" y "pobres" en 2 celdas (L6) |
| N18 | Sí | 188 de 188 celdas sin errores, 13,2 min (QA-stats §8) |

### 3.4 Repositorio y entrega (R1–R10)

| ID | Resp. | Nota |
|---|---|---|
| R1 repo público + etiqueta [B] | **No** | H2 |
| R2 README EN + ES con ética [B] | **No** | H4 |
| R3 docs de registro | Parcial | `correcciones.md` (creado hoy) y `hipotesis_preinscritas.md` sí; faltan `decisiones_de_datos.md`, `verificacion_numeros.csv` humana y `registro_ia.md` (H1, M9) |
| R4 licencias | **No** | No hay archivos `LICENSE` (H2) |
| R5 datos grandes fuera, con enlace y *hash* | Sí | `.gitignore` y `data/README.md` |
| R6 `CITATION.cff` | No | M9 |
| R7 PDF de 6 páginas | Sí | Comprobado con `pdfinfo` y a la vista |
| R8 referencias completas | Sí | ONU (datos, metodología, nota de revisiones, Interim Update), Banco Mundial FY2027, ASA, métodos y software; falta la licencia del Banco Mundial (L5) |
| R9 consentimiento | Pendiente | L7 |
| R10 sin datos personales innecesarios | Parcial | Correo personal (L7) |

## 4. Lo que ya está muy bien (y conviene defender ante el jurado)

- **Incertidumbre visible donde aparece el riesgo**: abanico 80/95 % de los EAU y "77 of 161 countries: the UN 95 % range for 2050 includes both growth and decline". El escenario "zero-migration" está rotulado como "a what-if, not a forecast".
- **"Spread, not uncertainty"** en las bandas de fig10, y "a spectrum, not boxes" con "four in ten sit between two groups". Es una distinción poco común y muy defendible.
- **Ejemplos por regla y en código** (los 3 más poblados ≥ 1 M; el país mediano por regla en fig04; gemelos elegidos entre 12 880 pares) y **posicionalidad declarada** con Colombia.
- **Contabilidad dicha como contabilidad** ("bookkeeping", "true by definition") y "a group total: it does not mean migration offsets low births country by country", que desactiva el marco del "gran reemplazo".
- **Resultados negativos publicados**: H2, H7, H8 y H9 rechazadas; "reversed in Europe & N. America (+0.39)"; intervalo que incluye 0 sin disimularlo.
- **Lenguaje justo**: Okabe-Ito sin semáforo, nombres de grupo sin jerarquía, "not a ranking of development or well-being", "no alarm about birth rates", "voluntary family planning", ICPD, "migrant inclusion"; sin logos de la ONU; descargo de fronteras.
- **Trazabilidad de cifras**: 210 recalculadas con código independiente, huellas que devuelven una clave a `false` si su valor cambia, y `fill_numbers.py` que se niega a escribir claves sin verificar. Es una práctica ejemplar, **siempre que se declare que la hizo un agente de IA** (H1).

## 5. Puntuación 1–10 y justificación

**7,5 / 10.**

- **A favor (+):** cubre casi todo lo que el memo de ética proponía y lo que ningún ganador de 2025 hizo: incertidumbre oficial, *data fitness* de la migración en voz, hipótesis con *hash*, sección "lo que no encontramos", regla de ejemplos, terminología ONU, paleta neutral, sin logos y atribución CC BY 3.0 IGO con "Changes". La voz pasa el *grep* y no dice ninguna cifra sin verificar.
- **En contra (−1,5): honestidad sobre nuestra propia práctica.** La declaración de IA infravalora el papel de la IA y presenta como revisión del equipo una verificación hecha por IA (H1). Para el premio de ética es el punto más sensible: un jurado que abra el repositorio verá `Co-Authored-By: Claude …` en los 7 commits y memos de "asesores" que son agentes.
- **En contra (−0,5): afirmaciones sobre un repositorio público que todavía no existe** (H2), sin archivos de licencia.
- **En contra (−0,5): el PDF**, que es lo que el jurado lee con calma, pierde las etiquetas de proyección en la tabla (H3).
- **En contra (−0,5): "never mixed", "fixed in advance", 66 frente a 22 y "34–38 years"** (M1–M3, M8). Son pequeñas sobreafirmaciones en un deck que por lo demás es muy cuidadoso. El README sin sección ética (H4) pesa poco en el vídeo, pero es un ítem bloqueante.

**Con H1–H4 y M1–M3 resueltos: 9–9,5.** El resto (M4–M9, L1–L9) es pulido que suma credibilidad, pero no cambia el veredicto.

## 6. Para el corrector (orden sugerido)

1. H1 (texto de Referencias, tarjeta 5 y notebook §9.6) y H2 (decidir entre la opción A y la B **antes de grabar**, porque cambia la voz).
2. H3 y M8 (tabla de la Slide 4; volver a exportar el PDF y mirar la pág. 5).
3. M1, M2 y M3 (voz: `narration_en_template.md` → `build_narration.py`; recomprobar que el total queda ≤ 4:55. Netas: M1 +1 palabra, M3 +1 y +3, L1 +2, L2 0).
4. M4, M5 (regenerar fig06), L1–L5 y L9 en el HTML.
5. Repositorio: H4, M6, M7, M9, L6, L7 (sin tocar `index.html`).
6. Al aplicar cada corrección, pasarla de la sección G de `docs/correcciones.md` a su tabla, con fecha y commit.
