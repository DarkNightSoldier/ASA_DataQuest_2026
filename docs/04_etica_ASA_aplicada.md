# 04 — Ética ASA aplicada a nuestro proyecto (agente *ethics-advisor*)

> Fecha: 2026-10-22 · Entrega: viernes 30-oct-2026 · Documento en español; los textos para diapositivas, guion y pies de gráfica van **en inglés**.
> Objetivo: convertir los *ASA Ethical Guidelines for Statistical Practice* (2022) en acciones **concretas y visibles** en el notebook R, las 4 diapositivas, el vídeo de 5 min y el repositorio, para competir por **Best Consideration of Ethics** sin perder los otros dos premios.
> Fuentes leídas para este documento (copias de trabajo en el scratchpad de la sesión): texto oficial ASA (2022); UN DESA (2024) *WPP 2024 Methodology Report*; UN DESA (2024) *WPP 2024 Summary of Results*; nota de la ONU sobre diferencias 2022→2024 (11-jul-2024); *WPP 2024 Interim Update* (19-ene-2026, Togo); nota del Banco Mundial *FY27 Updated Country Income Classification*; y los documentos del equipo `00_plan_analitico.md`, `00_storyboard_diapositivas.md`, `01_analisis_ganadores_2025.md` y `data/raw/README.md`.
> **Cifras marcadas con ✔** las verificó este agente con pandas sobre `WPP2024_Demographic_Indicators_Medium_csv.gz` y `..._OtherVariants_csv.gz` (Anexo A). Igual que el resto, **deben regenerarse en R** y pasar por `figures/numbers.json` antes de salir en pantalla.

---

## 0. Resumen ejecutivo

**Las 5 acciones éticas más visibles y diferenciadoras.** Ningún ganador 2025 hizo la 1, la 3, la 4 ni la 5; la 2 mejora lo que QuantaQuartet hizo con los datos faltantes:

1. **Mostrar la incertidumbre oficial de la ONU, no solo la línea Medium.** El archivo OtherVariants trae intervalos de predicción del 80 % y 95 % por país. Ejemplo para pantalla y voz: Emiratos Árabes Unidos 2050 = 15,4 M (Medium) con un 95 % entre **8,9 y 33,3 M** ✔; mundo 2100 = 10,18 mil M con un 95 % entre 9,05 y 11,44 mil M ✔. Una banda en la Diapositiva 4 y una frase del guion.
2. **"Data fitness" de la migración dicha en voz alta.** Según la metodología de la ONU, la migración neta suele estimarse como **residuo entre censos**. Además, las poblaciones del Golfo se revisaron entre WPP2022 y WPP2024 en **+12 % (EAU, Kuwait), +9,7 % (Qatar), +8,7 % (Omán) y −10 % (Arabia Saudí)**, y su proyección hasta 2100 usa **tasas fijadas por expertos de la ONU** (0,5 por 1 000 desde 2030). Esto va en un pie de la gráfica del Golfo y en el panel de ética.
3. **Hipótesis H1–H14 publicadas con fecha (commit) antes del cálculo final**, más una sección "What we did not find". Hay que decir con honestidad que **no son confirmatorias**, porque salen de un EDA previo sobre los mismos datos (B.3, C.3).
4. **Una regla escrita y en código para elegir cada país que se nombra o resalta**: el más poblado de su tipo con ≥ 1 M, o el medoide del grupo. A eso se suman la lista completa de los 237 países y áreas en el repositorio y la sensibilidad de la definición (por ejemplo, 18 países crecen solo por migración con datos de 2023 frente a 24 con el promedio 2021–23 ✔). Es la defensa directa contra el *cherry-picking*.
5. **Declaración de uso de IA y verificación humana de cada número**: `numbers.json` como fuente única, una tabla de verificación firmada por personas del equipo y un registro de correcciones (`docs/correcciones.md`). Las dos primeras entradas ya existen: la etiqueta FY2026 → FY2027 y la actualización de Togo de enero de 2026.

**Riesgos principales del storyboard actual** (detalle y redacción alternativa en §6):
- Lenguaje causal o contrafactual: *"18 countries would shrink without immigration"*, *"the lever that unlocks the rest"*, *"which levers really move"*.
- Proyecciones contadas como hechos: *"will age faster than anyone before: median age forty-five by 2050"*, *"Everyone heads here"*.
- **Definiciones mezcladas** que cambian ejemplos y conteos: con la regla declarada del plan (promedio 2021–23), **Nepal no decrece y Uruguay tiene más muertes que nacimientos**, así que no son ejemplos de "shrinking by emigration" ✔.
- Etiqueta de ingreso equivocada: el archivo es **World Bank FY2027**, no FY2026.
- El R² de 0,99 presentado como hallazgo cuando es casi una **identidad contable**.
- Logos de la ONU y sus agencias, cuyo uso está restringido.
- Nombres y colores con carga de juicio: *Late movers*, rojo = decrece, verde = crece, *rich countries*, *fills the gap that low fertility leaves*.
- El cierre *"Everything follows the ASA ethical guidelines"*, que promete demasiado mientras el propio guion conserva frases causales.

---

## 1. Los 8 principios ASA (A–H): resumen fiel y puntos citados

**Cita bibliográfica (usar exactamente):**
American Statistical Association. (2022). *American Statistical Association Ethical Guidelines for Statistical Practice*. Zenodo. https://doi.org/10.5281/zenodo.7092386
- Aprobadas por el ASA Board en febrero de 2022, preparadas por el *Committee on Professional Ethics*. El registro de Zenodo tiene licencia **CC BY 4.0**, así que se pueden citar textualmente con atribución, también en diapositivas.
- Forma corta en diapositivas: `ASA (2022) Ethical Guidelines for Statistical Practice, doi:10.5281/zenodo.7092386`.
- Cuando citemos un punto concreto, usar la letra y el número del documento: "B.3", "D.6". Los puntos del Apéndice (organizaciones) se citan como "Appendix, item 8".

**Propósito.** Las guías se aplican a todo el que hace práctica estadística, sin importar su título o nivel; los estudiantes estamos incluidos. Frase clave: ante un dilema, el practicante ético *"seeks guidance, not exceptions, in the guidelines"*.

| Principio | Qué pide (resumen fiel) | Puntos más relevantes para nosotros (cita textual) |
|---|---|---|
| **A. Professional Integrity and Accountability** | Responsabilizarse del propio trabajo; usar métodos válidos; no sesgar los resultados; dar crédito; declarar conflictos; tratar a todos con dignidad. | **A.1** *"Does not solicit or deliver work for which they are not qualified or that they would not be willing to have peer reviewed."* · **A.2** usar métodos y datos *"valid, relevant, and appropriate, without favoritism or prejudice"*, con resultados *"valid, interpretable, and reproducible"* · **A.3** no realizar prácticas que *"create or perpetuate unfair outcomes"* · **A.4** *"Opposes efforts to predetermine or influence the results… and resists pressure to selectively interpret data."* · **A.5** *"does not take credit for the work of others, and gives credit to those who contribute"* · **A.7** declarar conflictos de interés *"financial and otherwise"* · **A.8** *"Promotes the dignity and fair treatment of all people."* · **A.10** mantener la competencia actualizada. |
| **B. Integrity of Data and Methods** | Entender y mitigar los límites, defectos y sesgos de datos y métodos, y comunicar cómo afectan a las conclusiones. | Intro: *"understand and mitigate known or suspected limitations, defects, or biases in the data or methods"* · **B.1** *"Communicates data sources and fitness for use, including data generation and collection processes and known biases"*, más el procesamiento y el manejo de faltantes · **B.2** *"Is transparent about assumptions… limitations, possible sources of error, and algorithmic biases"*, comunicando resultados de forma *"honest and meaningful"* · **B.3** *"transparent regarding a priori versus post hoc objectives and planned versus unplanned statistical practices. Discloses when multiple comparisons are conducted and any relevant adjustments."* · **B.4** compartir datos para replicación cuando se permita · **B.5** *"Strives to promptly correct substantive errors discovered after publication"* · **B.7** describir el efecto de la variación entre grupos. |
| **C. Responsibilities to Stakeholders** | Saber qué necesitan los usuarios (aquí: la ONU, el jurado, el público); no engañar; distinguir lo exploratorio de lo confirmatorio; explicar límites y precisión. | **C.1** obtener *"sufficient subject-matter knowledge"* · **C.2** *"does not use statistical practices to mislead any stakeholder"* · **C.3** *"Uses practices appropriate to exploratory and confirmatory phases… differentiating findings from each"* · **C.4** informar de los *"limitations on use and re-use"* y de las consideraciones de *"scope, cost, and precision"* · **C.6** hacer el conocimiento ampliamente disponible · **C.7** respetar las restricciones de uso del proveedor de datos · **C.8** priorizar la integridad científica cuando hay intereses en conflicto (por ejemplo, ganar un premio). |
| **D. Responsibilities to Research Subjects, Data Subjects, or Those Directly Affected** | Proteger la privacidad; usar los datos solo como se permite; pensar en el impacto sobre grupos y sobre cómo se les percibe. | **D.4** proteger la privacidad y la confidencialidad · **D.5** uso permitido de los datos, incluido el *"linking data with additional data sets"* (unimos WPP con el Banco Mundial) · **D.6** *"Recognizes that statistical practice could adversely affect groups or the public perception of groups, including marginalized groups"* y busca minimizarlo *"in framing results in reporting"* · **D.7** *"Refrains from collecting or using more data than is necessary."* · **D.10** *"Understands the provenance of the data—including origins, revisions, and any restrictions on usage—and fitness for use"* · **D.11** promover *"the just and impartial treatment of all individuals"*. |
| **E. Responsibilities to Members of Multidisciplinary Teams** | Trabajar con otras disciplinas (diseño, vídeo, narrativa) sin sacrificar la validez. | **E.3** *"Ensures all communications regarding statistical practices are consistent with these guidelines."* · **E.4** *"Avoids compromising validity for expediency."* Con 8 días de plazo y animaciones, este punto pesa. |
| **F. Responsibilities to Fellow Statistical Practitioners and the Profession** | Respeto, revisión constructiva y reproducibilidad. | **F.1–F.2** crítica *"impartial, constructive, and objective"*, que también aplica a cómo hablamos de otros equipos · **F.4** *"Promotes reproducibility and replication, whether results are 'significant' or not, by sharing data, methods, and documentation"* · **F.5** ser *"ambassador for statistical practice"* ante no especialistas. |
| **G. Responsibilities of Leaders, Supervisors, and Mentors** | Quien lidera (capitán del equipo, profesor, orquestador de agentes) crea una cultura ética y valida supuestos. | **G.1** asegurar una práctica coherente con las guías · **G.4** reconocer las contribuciones (autoría) · **G.5** *"Establish a culture that values validation of assumptions"*. |
| **H. Responsibilities Regarding Potential Misconduct** | Ante una sospecha de mala conducta: hechos, discreción y debido proceso. | **H.1** *"differences of opinion and honest error do not constitute unethical behavior"* · **H.3** no hacer acusaciones *"poorly founded"*. Aplica, por ejemplo, si notamos errores en repos de otros equipos 2026: no se comentan en público. |
| **Appendix (organizaciones/líderes)** | Responsabilidades institucionales. | **Item 8**: es contrario a las guías *"to report or follow only those results that conform to expectations without explicitly acknowledging competing findings"*. Es la base de nuestra sección "What we did not find". |

**Lectura práctica para nuestro proyecto.** Los principios que el jurado podrá *ver* en 5 minutos son **B** (fuentes, supuestos, incertidumbre, a priori/post hoc), **C** (no engañar, exploratorio, precisión) y **D.6/D.10** (impacto en grupos y procedencia o revisiones de los datos). **A** y **F** se demuestran en el repositorio: reproducibilidad, crédito, IA y correcciones. **E**, **G** y **H** se cubren con prácticas internas y una línea en el README.

---

## 2. Matriz principio → riesgo en NUESTRO proyecto → acción concreta → dónde se ve

Leyenda de "dónde se ve": **NB** = notebook R (español) · **SL0–SL5** = portada, diapositivas 1–4 y referencias · **VID** = narración/subtítulos · **REPO** = README, `docs/`, CSV públicos · **PIE** = "ethics badge" al pie de la gráfica (§3.3).

### 2.1 Datos, procedencia y calidad

| # | Tema | Principios | Riesgo concreto (con evidencia) | Acción concreta | Dónde se ve |
|---|---|---|---|---|---|
| 1 | **Países vs agregados (doble conteo)** | B.1, C.2 | El archivo Medium mezcla 237 países y áreas (`ISO3_code` no vacío) con cientos de agregados: regiones, grupos de ingreso, bloques como "G20" o "UNICEF regions". Sumar filas sin filtrar infla los totales (un repo turco 2026 lo cuantifica en ≈ 44,8×). Además, **los agregados de ingreso de la ONU usan la clasificación del Banco Mundial de mayo de 2024**, distinta de nuestro archivo FY2027, así que nuestras sumas por ingreso no coincidirán con las filas "High-income countries" de la ONU. | (a) Filtro único `es_pais <- ISO3_code != ""` en `R/01_preparar_datos.R`. (b) Test automático `stopifnot()`: suma de países por región SDG = agregado ONU (tolerancia 0,1 %) y suma de los 237 = "World". (c) Nunca mezclar en una gráfica sumas de países y agregados ONU sin decirlo en el pie. (d) No comparar nuestras sumas por ingreso con los agregados de ingreso de la ONU. | NB §Datos (test visible) · PIE "countries only" / "UN regional aggregates" · REPO `decisiones_de_datos.md` D-02 |
| 2 | **Procedencia y revisiones de la fuente** | D.10, B.1, B.5 | Las estimaciones 1950–2023 son **modelizadas** y se revisan en cada edición. WPP2024 usó 1 910 censos, pero solo 114 de 237 países o áreas tienen un censo o registro de 2019 o posterior; 100 lo tienen de 2009–2018 y **23 de antes de 2009** (Líbano 1932, Afganistán 1979, R. D. del Congo 1984, Nigeria 2006, Emiratos 2005…). Entre WPP2022 y WPP2024, 34 países o áreas (con ≥ 90 000 habitantes) cambiaron más de 5 % su población de 2023, y 30 más de un millón de personas. En enero de 2026 la ONU publicó un **Interim Update**: Togo había sido ajustado dos veces por subregistro (WPP2024 estimaba 9,1 M en 2022 frente a 8,2 M del censo oficial, un 12 %); sus tasas no cambian y los agregados no se revisaron. Nuestro archivo Medium es el **original** (Togo 2023 = 9,30 M ✔). | (a) Ficha "Fitness for use" en el notebook con esas cifras y la lista de los 23 países con censos de antes de 2009, marcados en la tabla de miembros de cada grupo. (b) Mantener el archivo original por coherencia con los agregados y con el concurso, pero **declararlo** y correr una sensibilidad sustituyendo Togo por el *Update* (¿cambia algún conteo o cifra del guion?). (c) Entrada en `docs/correcciones.md`. (d) No presentar ninguna cifra de 2023 con más de 3 cifras significativas. | NB §Datos y §Limitaciones · SL5 (referencia al Interim Update) · REPO |
| 3 | **Migración: el componente peor medido** | B.1, B.2, D.10, C.4 | Lo que dice la metodología de la ONU: (i) los datos de flujos *"exist for only a small number of countries"*, por eso WPP solo trae **migración neta**, y un saldo de 0 puede ocultar flujos grandes en ambos sentidos; (ii) en muchos casos se estima **como residuo** entre censos sucesivos, después de descontar fecundidad y mortalidad, así que absorbe los errores de cobertura de esos componentes; (iii) el balance mundial se fuerza a cero ajustando a los países *"where such estimates were highly uncertain"*; (iv) los datos de ACNUR llegan a mediados de 2023 y los de *stock* de migrantes a 2020. En proyección es *"the component of population change that is the most difficult to project"*, y la ONU añade que cualquier supuesto de largo plazo *"is virtually guaranteed to prove incorrect"*. Además se aplicó **juicio experto** a muchos países: 42 con periodo de referencia fijado a mano (incluida **Colombia, 1985–2023**), 28 con año de retorno a la línea base, muchos suponiendo que **2/3 de los refugiados regresan** (Ucrania, Alemania, Polonia, Jordania, Rep. de Moldova hacia 2026), 32 con tasas de largo plazo fijadas (EAU, Qatar, Omán, Kuwait, Arabia Saudí y Bahréin = 0,5 por 1 000 desde 2030) y topes de migración acumulada para seis países del Golfo. Las revisiones 2022→2024 del Golfo se debieron a un *"faster rebound in labour migration"*. | (a) Recuadro "Net migration: what it is and how good it is" en el notebook, con las 4 ideas anteriores. (b) Pie de toda gráfica de migración (PIE-6). (c) En la gráfica del Golfo, nota: `UN revised the UAE's 2023 population by +12 % between the 2022 and 2024 editions`. (d) En el panel β: decir que β ≈ −1 también es lo que produce el error de medida, no solo la volatilidad real. (e) Reconocer en el guion que el grupo *Migration-led* es el más inestable entre revisiones y que su futuro proyectado es un supuesto de la ONU. (f) Winsorizar la tasa neta de migración (CNMR) solo para PCA y clustering, documentado. | NB · SL1 (Golfo) · SL2 (β) · SL4 (panel ética) · VID |
| 4 | **Microestados y valores extremos** | A.2, B.2, B.7 | 76 de los 237 tienen < 1 M habitantes y 37 < 100 mil ✔. Con denominadores pequeños, las tasas por 1 000 se disparan y dominan rankings y correlaciones (Saint Martin pasa del puesto 4 al 136 según el diseño del índice). De los 18 países "crecen solo por migración" (2023), 7 tienen < 1 M; de los 19 "decrecen por emigración", 13 tienen < 1 M ✔. | (a) Umbral ≥ 1 M (161 países) **declarado antes** para correlaciones, modelos, PCA, índice y clustering. (b) Mapas y conteos con los 237, pero los pequeños en una franja aparte, sin ocultarlos. (c) Todo conteo en pantalla con los dos números: `18 (11 with ≥ 1 M people)`. (d) Ningún microestado como titular. (e) Sensibilidad de las correlaciones clave con los 237 en el notebook. | NB · SL1 · PIE-1/PIE-3 |
| 5 | **Unión WPP + Banco Mundial (linkage)** | D.5, B.1 | 21 ubicaciones WPP no tienen grupo del Banco Mundial; la única ≥ 1 M es *China, Taiwan Province of China* (23,3 M) ✔. El Banco Mundial cuenta *Channel Islands* (CHI) como una economía, mientras WPP separa Guernsey y Jersey. | Tabla de cruce en el notebook: 237 → 216 con grupo + 21 "No WB income group", listados por nombre. Excluir estos últimos de las comparaciones por ingreso y decirlo en el pie. | NB · REPO · PIE-4 |

### 2.2 Proyecciones e incertidumbre

| # | Tema | Principios | Riesgo concreto | Acción concreta | Dónde se ve |
|---|---|---|---|---|---|
| 6 | **Estimaciones (≤ 2023) vs proyecciones (≥ 2024)** | B.2, C.2, C.4 | El storyboard narra proyecciones en futuro indicativo (*"will age faster than anyone before"*, *"median age forty-five by 2050"*) y dibuja una flecha *"Everyone heads here"*. Pero la proyección de fecundidad de la ONU *"is based in the demographic transition theory"*: la convergencia futura es un **supuesto del modelo**, no evidencia. Las proyecciones tampoco contienen crisis: en los 161 países ≥ 1 M, la desviación estándar del cambio anual es **25× menor en proyección que en estimación para la tasa neta de migración, 24× para la esperanza de vida y 5× para la fecundidad** ✔. Ojo: el plan dice "14–34×"; para la fecundidad no se replica con esta medida, así que hay que verificarlo antes de citarlo. | (a) Columna `es_proyeccion` en todos los datos. (b) Toda serie que cruce 2023/24: línea vertical punteada, tramo futuro en gris discontinuo y etiqueta `UN medium projection`. (c) Verbos: *is projected to (UN medium)*, nunca *will*. (d) En la trayectoria regional, la flecha pasa a decir `Observed to 2023 · dashed = UN projection, which assumes the transition continues`. (e) Ninguna conclusión "de hallazgo" basada solo en el tramo proyectado. | Todas las gráficas · VID · NB |
| 7 | **Incertidumbre de la variante Medium e intervalos probabilísticos** | B.2, C.4, C.2 | Mostrar solo la línea Medium da una falsa precisión. La ONU pide a los usuarios *"to focus not only on the medium scenario… but also on the associated prediction intervals"*. Desde WPP2024, la Medium es la **media** (no la mediana) de miles de trayectorias para fecundidad y esperanza de vida, y por primera vez la migración también es probabilística. El archivo OtherVariants trae `Lower/Upper 80 PI` y `95 PI` para población, TFR, LEx, edad mediana, CNMR, etc. Ejemplos ✔: **EAU 2050**: 15,4 M (Medium), 95 % 8,9–33,3 M, CNMR 80 % de −19,4 a +42,6 por 1 000 · **Nigeria 2100**: 477 M, 95 % 256–1 142 M · **Japón 2100**: 76,8 M, 95 % 47,8–112,8 M · **Mundo 2100**: 10,18 mil M, 95 % 9,05–11,44. **Cuidado:** los PI son marginales por indicador y país; **no se pueden sumar** entre países ni usar para construir PI de grupos (*fast movers*, ingreso). | (a) Una gráfica de abanico 80/95 % en la Diapositiva 4 (build 2) para **un país representativo por grupo**, elegido con la regla del #9; mínimo: edad mediana de China 2050 y población de EAU 2050. (b) En la tabla de recomendaciones: `median age ≈ {x} by 2050 (UN medium; 95 % PI for China {a–b})`. (c) Mencionar en el guion el rango de EAU (§3.2). (d) Nota en el notebook: "PI marginales; no sumables". Así P2/P3 (OtherVariants) entran solo como nota de incertidumbre, que es lo que pide el plan. | SL4 · VID · NB apéndice · PIE-5 |
| 8 | **La identidad contable presentada como hallazgo** | C.2, B.2 | El R² de 0,99 (fecundidad + mortalidad + migración → crecimiento) es casi una identidad (crecimiento ≈ CBR − CDR + CNMR, y TFR ≈ CBR). Las participaciones "migración / crecimiento" explotan cuando el cambio poblacional es casi 0 (Europa 207 %). | (a) Decirlo **en la narración**, no solo en un pie: *"almost by definition, because growth is births minus deaths plus migration"*. (b) El hallazgo que se vende es que *ningún componente sobra* y *qué componente domina en cada tipo de país*. (c) Cuando el cambio total sea pequeño, mostrar componentes absolutos y explicar los porcentajes > 100 %. | SL3 · VID · NB |

### 2.3 Métodos, selección e inferencia

| # | Tema | Principios | Riesgo concreto | Acción concreta | Dónde se ve |
|---|---|---|---|---|---|
| 9 | **Selección de países emblemáticos (anti-cherry-picking)** | A.4, B.3, C.2, Appendix 8 | Las banderas y ejemplos del storyboard (DE/ES/FI; KEN/BGD/MEX; FR/JP/US · CN/BR/TR · NG/PK/ET · AE/QA/JO) están elegidos a mano. Además, **los ejemplos dependen de la definición** ✔: con el promedio 2021–23 (la regla del plan), Nepal está en "growing on births" y Uruguay en "deaths > births", así que **no** son "shrinking by emigration"; Hungría solo es "growing only by migration" en 2023. Los tres mayores del tipo C son DEU, ESP y BEL (2023) o DEU, ESP y POL (2021–23); Finlandia no entra en ninguno. Entre las dos definiciones, 16 países cambian de tipo. | **Regla escrita antes de hacer las figuras** y aplicada por código (`R/seleccion_ejemplos.R`): (1) ejemplos de cada tipo = los *k* más poblados con ≥ 1 M bajo la definición declarada; (2) país resaltado por región o grupo = **medoide** (el más cercano a la trayectoria mediana del grupo); (3) "gemelos" = búsqueda exhaustiva de pares con ≥ 1 M (\|ΔTFR\| < 0,05, máxima diferencia de crecimiento), con el top-5 publicado en el notebook. En pantalla, una vez: `Examples chosen by rule: largest country of each type (≥ 1 M)`. Lista completa de miembros de cada tipo y grupo en `figures/miembros_*.csv`. | NB · SL1–SL4 (nota pequeña) · REPO |
| 10 | **Una sola definición por concepto** | B.2, C.2 | La portada dice "18 grow only because people move in" (año 2023), mientras el mapa usa el promedio 2021–23 (24) ✔. El jurado puede ver dos cifras distintas para la misma idea. | Elegir **una** definición (recomendado: el promedio 2021–23, más estable ante el COVID-19 y la guerra en Ucrania) y usarla en portada, mapa, guion y `numbers.json`. La otra va como sensibilidad: `24 with 2021–23 average (18 with 2023 alone)`. | SL0 · SL1 · NB |
| 11 | **Correlación ≠ causalidad y vocabulario** | C.2, B.2, A.4 | El guion contiene frases causales o contrafactuales: *"would shrink without immigration"* (además, sin inmigrantes también cambiarían los nacimientos; el contrafactual no se identifica con componentes netos), *"the lever that unlocks the rest"*, *"which levers really move"*, *"fills the gap"*. *"Mortality falls first, fertility follows"* es precedencia temporal, no causa. La metáfora *lever* sugiere que alguien "tira de la palanca" de la fecundidad, lo que choca con el enfoque de derechos de la CIPD (ICPD). | (a) Lista de verbos permitidos y prohibidos (§4.5) con un *grep* automático del agente QA sobre el guion, las diapositivas y el notebook. (b) Definir una vez en pantalla: `Lever = a component of the population balance (births, deaths, net migration), not a policy switch.` (c) En recomendaciones, *what to watch*, nunca *lever to pull*. (d) Frase de protección en la voz: *"These are patterns, not causes."* | VID · SL1–SL4 · NB |
| 12 | **Exploratorio vs confirmatorio; comparaciones múltiples** | B.3, C.3 | H1–H14 salieron de un EDA previo **sobre los mismos datos**, así que no son confirmaciones independientes. Hay muchas pruebas: Spearman año a año × pares × 4 grupos de ingreso × 151 años, 7 versiones del índice, umbrales alternativos, varios *k*, ANOVAs de interacción. Además, los 237 países son **la población completa, no una muestra**: los valores p no tienen la interpretación muestral habitual. | (a) Commit con fecha de `docs/hipotesis_H1_H14.md` **antes** de la corrida final, con una columna "resultado" (✔ / ✘ / parcial) rellenada después. (b) Sección "What we did not find" / "Lo que no encontramos" (Appendix 8). (c) Contar las pruebas: `n_tests` en `numbers.json`, corrección de Holm en las ANOVAs y Benjamini–Hochberg en la rejilla de correlaciones si se reporta "significancia". (d) Los *bootstrap* se describen como "sensitivity to which countries are included", no como "sampling error". (e) Ni la palabra *significant* ni valores p en el vídeo. (f) Etiqueta "Exploratory" en el título de cada sección del notebook. | NB · REPO · SL (nada de p-values) |
| 13 | **Censura y selección en el rezago mortalidad → fecundidad** | B.2, C.4 | El rezago mediano de 11 años usa solo los 89 de 161 países con ambos cruces observados después de 1950. Excluye a quien ya estaba por debajo en 1950 (Europa) y a quien aún no cruzó TFR < 4. Con otros umbrales (Q5 < 50, TFR < 3) el rezago es de 2 años y la mortalidad va primero en el 58 %. | Mostrar siempre `n = 89 of 161 (both crossings observed after 1950)` y los censurados por región; la sensibilidad con los umbrales alternativos en el notebook, y una línea en el pie de la gráfica. | SL2 · NB |
| 14 | **Clustering: circularidad y cosificación** | B.2, C.3, D.6 | Silueta ≈ 0,23: no hay "grupos naturales". El error de QuantaQuartet fue hacer ANOVA sobre los clústeres con las mismas variables que los formaron. | Mantener *"a continuum, not boxes"*; no testar diferencias con las variables usadas para agrupar; validar con estabilidad *bootstrap* (Jaccard) y con variables **externas** (ingreso, región); publicar la tabla de miembros y la probabilidad de pertenencia o estabilidad de cada país. | SL4 · NB · REPO |
| 15 | **Índice compuesto (P5)** | D.6, C.2, B.2 | Un índice puede leerse como "ranking de desarrollo o bienestar" de países, con el consiguiente estigma. | Presentarlo **como prueba de fragilidad** (24 % se mueve más de 20 puestos), nunca publicar un "top/bottom 10"; pie: `Not a ranking of well-being or development`. | SL3 · NB |
| 16 | **Ponderación (país = 1 vs población)** | B.2, B.7 | La mediana de países y el agregado ponderado cuentan historias distintas (China dentro de ingreso medio-alto). | Mostrar ambos cuando difieran; el pie dice cuál es cuál (PIE-1 vs PIE-2). | NB · PIE |

### 2.4 Personas, grupos y lenguaje

| # | Tema | Principios | Riesgo concreto | Acción concreta | Dónde se ve |
|---|---|---|---|---|---|
| 17 | **Grupos de ingreso: fuente, año, no clasificados, anacronismo** | B.1, B.7, D.6, D.10 | **El archivo del repo es World Bank FY2027** (vigente desde el 1-jul-2026, INB per cápita 2025, método Atlas). Umbrales: bajo ≤ 1 175 US$; medio-bajo 1 176–4 635; medio-alto 4 636–14 375; alto > 14 375. Hay 217 economías en la copia del API (25 / 47 / 59 / 86) ✔; el blog del Banco Mundial menciona 218, así que el notebook debe comprobar si falta alguna. Cambios FY27: Jordania, Micronesia (Est. Fed.), Filipinas, Sri Lanka y Viet Nam pasan a medio-alto; Togo a medio-bajo. **Venezuela estuvo sin clasificar en FY26 y desde FY27 es "lower-middle income"**. El plan y el storyboard dicen "FY2026": es un error de etiqueta. Aplicar el grupo de 2026 a 1950–2023 es anacrónico: la cifra "71 % del crecimiento de los países de ingreso alto desde 2000" usa la membresía **de hoy**. | (a) Corregir la etiqueta a **FY2027** en el plan, el storyboard, las referencias y el notebook (primera entrada de `correcciones.md`). (b) Rótulo en pantalla: `grouped by today's income level (World Bank FY2027), applied to all years`. (c) Sensibilidad: recalcular la cifra del 71 % con la clasificación histórica del Banco Mundial (archivo de clasificaciones históricas, desde FY1989) para 2000–2023 y reportar ambas. (d) Listar los 21 sin grupo. (e) Vocabulario: *low-income countries*, nunca *poor countries*; *high-income*, nunca *rich*. | NB · SL1 · SL4 · SL5 · PIE-4 |
| 18 | **Sin juicios de valor sobre fecundidad o migración; nombres neutrales** | A.8, D.6, A.3 | *Late movers* puede leerse como "atrasados"; el "camino" con destino único (*"Everyone heads here"*, *"still on the road"*) supone una trayectoria normativa de tipo europeo; *Migration-boosted* suena a instrumento. Rojo = decrece y verde = crece sugieren malo/bueno. La alta fecundidad no es un "problema" ni su descenso un "éxito". | (a) Nombres: **Early movers · Fast movers · Recent movers · Migration-led** (por comportamiento y momento, sin jerarquía). (b) Paleta sin semáforo: Okabe-Ito **azul #0072B2** (crece por nacimientos), **celeste #56B4E9** (crece solo por migración), **naranja #E69F00** (decrece: más muertes que nacimientos), **púrpura rojizo #CC79A7** (decrece por emigración), gris #999999 (pequeños Estados). (c) Enfoque de derechos de la CIPD (ICPD), que la propia ONU cita: servicios *"without any form of coercion"*; nunca proponer metas de fecundidad. (d) Pie del mapa y de los clústeres: `Groups describe demographic paths, not development or worth.` | SL1 · SL4 · VID · NB |
| 19 | **Dignidad y neutralidad con migrantes, refugiados, conflictos, genocidio, VIH (terminología ONU)** | A.8, D.6, D.11 | Frases como *"reacts to shocks"* o *"fills the gap that low fertility leaves"* convierten a las personas en piezas de un balance. Juntar *replacement fertility* con migrantes que "llenan el hueco" puede evocar la teoría conspirativa del "gran reemplazo". Las tasas de migración positivas tras un conflicto (Sudán del Sur, Siria) son **retornos**, no "atracción". | Seguir la **guía de terminología del §2.6**: nombres oficiales de la ONU (columna `Location`), crisis con la denominación ONU, nunca "illegal", "wave", "flood", "burden". *Replacement fertility* se define ("2.1 children per woman, the level at which a generation replaces itself") y **nunca** se usa "replace/fill" referido a migrantes. Añadir el descargo de designaciones de la ONU en mapas. | VID · SL · NB · REPO |
| 20 | **Privacidad y datos mínimos** | D.4, D.7, D.1, C.7 | Riesgo bajo: los datos son agregados nacionales sin personas identificables, así que no hace falta revisión ética institucional (D.1: saber *cuándo* hace falta). Riesgos residuales: datos personales del equipo (correos, caras y voces en el vídeo) y uso de más datos de los necesarios. | (a) README: `No personal data are used; all data are national aggregates published by the UN.` (b) Consentimiento escrito de cada miembro para aparecer en el vídeo y el repo. (c) Sin correos personales en el repo salvo consentimiento. (d) Usar solo los indicadores necesarios (lista en `decisiones_de_datos.md`). | REPO · VID (créditos) |
| 21 | **Licencias, emblemas y restricciones del proveedor** | C.7, D.5, A.11 | WPP es **CC BY 3.0 IGO**: exige atribución e indicar cambios. **El emblema y los logos de la ONU y sus agencias (UN DESA, UNFPA, UNICEF, WHO, IOM, ILO) no pueden usarse sin autorización** (Asamblea General, resolución 92 (I), 1946), y su uso sugeriría respaldo institucional (A.6: el *acknowledgment* puede implicar respaldo). El storyboard pone el "logo UN DESA" en la tarjeta de datos e iconos de agencia en la tabla. | (a) Sustituir los logos por **texto**: `Source: UN DESA, Population Division (2024), WPP 2024 · CC BY 3.0 IGO · adapted by Team {name}`. (b) Agencias nombradas en texto, sin iconos parecidos a sus emblemas. (c) Logo ASA solo si lo entregan los organizadores. (d) Descargo de la ONU en el README y en el pie del mapa: `Boundaries and names shown do not imply official endorsement or acceptance by the United Nations.` (e) Licencias de terceros listadas: datos del Banco Mundial CC BY 4.0, guías ASA CC BY 4.0, `flag-icons` MIT, Lato OFL, polígonos del paquete `maps`. | SL0 · SL1 · SL4 · SL5 · REPO |

### 2.5 Transparencia, reproducibilidad, IA, crédito y competencia

| # | Tema | Principios | Riesgo concreto | Acción concreta | Dónde se ve |
|---|---|---|---|---|---|
| 22 | **Uso de IA (declarar y verificar)** | A.1, A.5, B.2, E.3, F.4, C.2 | El equipo trabaja con asistentes de IA (Claude Code, de Anthropic) para planificar, programar en R y redactar documentos, guion y storyboard, y los agentes hacen los cambios del repo. Riesgos: cifras o citas inventadas, código no revisado, autoría confusa. El FAQ del concurso no menciona la IA, así que declararla es lo honesto. | (a) **AI-use statement** en el README, en las referencias y en el notebook (§5). (b) Toda cifra en pantalla sale de `numbers.json` generado por el notebook; ninguna se teclea a mano. (c) `docs/verificacion_numeros.csv` con *clave, valor, comprobado_por (persona), fecha, cómo*. (d) Toda referencia se abre y se comprueba por una persona antes de entrar en SL5. (e) `docs/registro_ia.md` breve: qué tareas se hicieron con IA y quién las revisó. (f) Una línea en el vídeo (§3.2). | REPO · SL5 · VID · NB |
| 23 | **Reproducibilidad** | B.4, F.4, A.2 | Sin semillas, versiones ni *hashes* nadie puede reproducir las cifras. QuantaQuartet publicó su repo **después** del plazo. | `set.seed(2026)` con `RNGkind()` declarado; `renv.lock`; `sessionInfo()` al final; SHA-256 de los archivos WPP crudos (no versionados) en `data/raw/README.md`; un solo comando (`make notebook`) que regenera `numbers.json` y las figuras; repo **público antes de enviar**, con etiqueta `v1.0-submission`; `CITATION.cff`; licencias MIT (código) y CC BY 4.0 (textos). | REPO · SL5 (URL) · NB final |
| 24 | **Corrección de errores** | B.5 | Errores ya detectados: FY2026 → FY2027; Nepal/Uruguay; 18 frente a 24; el "14–34×" sin replicar. | `docs/correcciones.md` (fecha, error, impacto, dónde se corrigió). Si tras la entrega aparece un error, corregirlo en el repo y anotarlo, aunque el vídeo ya no pueda cambiarse. | REPO |
| 25 | **Crédito a fuentes y a trabajo previo** | A.5, G.4, C.6 | Ideas ajenas sin crédito: la clasificación de Webb (1963), la convergencia β/σ (Barro & Sala-i-Martin, 1992), la teoría de la transición demográfica, los modelos probabilísticos de la ONU (Alkema et al., 2011; Raftery et al., 2014; Azose & Raftery, 2015), la base de crisis de mortalidad de la ONU, el código del profesor (fan chart, β/σ) y el EDA previo. | Referencias en SL5 y en el notebook; anotaciones históricas con su fuente en el notebook (p. ej., la hambruna en China: Kane, 1988, citado por la ONU; refugiados: ACNUR); `citation()` de cada paquete R; agradecimientos al profesor o asesor y a los organizadores (suplemento LE60). | SL5 · NB · REPO |
| 26 | **Conflicto de interés y posicionalidad** | A.7, B.1, C.8 | No hay financiación ni afiliación con la ONU o el Banco Mundial. El único incentivo es el premio, lo que empuja a exagerar el "impacto" (C.8). Si el equipo estudia en Colombia, país de destino de muchos migrantes venezolanos y con ajustes expertos de la ONU en su proyección migratoria, conviene declararlo si Colombia o Venezuela aparecen como ejemplo. | README: `Conflicts of interest: none. Funding: none. The team is not affiliated with the UN or the World Bank.` Más una línea de posicionalidad si se resalta Colombia o Venezuela; los ejemplos siguen siempre la regla del #9. | REPO · NB |
| 27 | **Límites de competencia del equipo** | A.1, A.10, C.1 | Somos estudiantes, no demógrafos: no re-estimamos WPP, no hacemos inferencia causal, no producimos proyecciones propias. Las recomendaciones a la ONU podrían sonar a prescripciones de política. | Sección "What this project is not" en el README; recomendaciones formuladas como *where to look / what to watch* y derivadas visiblemente de una gráfica; pedir revisión del profesor o asesor (registrada en `registro_ia.md` o en el README); citar la metodología oficial en lugar de reinterpretarla. | REPO · SL4 · VID |
| 28 | **Coherencia del equipo y de la producción** | E.3, E.4 | Quien edita el vídeo o diseña las diapositivas puede redondear cifras o cambiar escalas "por estética"; con el plazo encima, se pueden saltar pruebas. | Las cifras del HTML se resuelven desde `numbers.json` (marcadores `{clave}`); el agente QA aplica el checklist del §4 a cada build; nada se graba sin el "✔" de QA-stats. | SL · VID |
| 29 | **Cómo hablamos de otros equipos** | F.1, F.2, H.1, H.3 | `01_analisis_ganadores_2025.md` critica a TRITICS y QuantaQuartet, y hemos visto repos de competidores 2026. | Ese análisis es interno y constructivo; en el vídeo y las diapositivas **no se compara** con otros equipos ni se señalan errores ajenos. | REPO (interno) |
| 30 | **Accesibilidad** | B.2 ("honest and meaningful"), F.5, D.11 | Gráficas ilegibles o con colores no distinguibles excluyen a parte del jurado y del público. | Paleta para daltonismo (Okabe-Ito), subtítulos quemados, texto ≥ 18 px, *alt text* de cada figura en el README y lectura en voz de cada número clave. | SL · VID · REPO |

### 2.6 Guía de terminología (pantalla, voz y notebook)

| Evitar | Usar (inglés) | Motivo / fuente |
|---|---|---|
| *rich / poor countries*, *developed vs developing* (como juicio) | *high-income / low-income countries (World Bank FY2027)* | Clasificación explícita con fuente y año (B.1, D.6) |
| *237 countries* | *237 countries and areas* | Nota de la ONU: "country" incluye territorios o áreas |
| Korea · Bosnia · Iran · Taiwan · Kosovo · Palestine · Vietnam · Turkey | *Republic of Korea* · *Bosnia and Herzegovina* · *Iran (Islamic Republic of)* (en voz basta "Iran") · *China, Taiwan Province of China* · *Kosovo (under UNSC res. 1244)* · *State of Palestine* · *Viet Nam* · *Türkiye* | Nombres de la columna `Location` del WPP ✔. En gráficas densas, códigos ISO3 |
| *illegal migrants*, *wave / flood / influx*, *burden* | *migrants*, *net migration*, *refugees*, *people displaced by conflict*, *arrivals and departures* | Dignidad (A.8); la ONU habla de *"safe and orderly migration"* que *"protects the human rights of migrants"* |
| *migration fills the gap*, *replaces* | *net migration accounted for most of the growth* | Evitar el marco del "gran reemplazo" (D.6) |
| *shocks* (para guerras o epidemias) | *crises* / *crisis-related deaths* (término de la metodología ONU) | Terminología ONU |
| *Syria 2012–16* | *the conflict in the Syrian Arab Republic (2012–16)* | Nombre oficial |
| *Ukraine 2022* | *the war in Ukraine (2022)* | Neutral y factual |
| *China famine 1959–62* | *the 1959–61 famine in China* | En el WPP la esperanza de vida de China cae de 48,8 (1958) a 33,4 (1960) y se recupera en 1962 (50,96) ✔ |
| *Rwanda 1994* | *the 1994 genocide against the Tutsi in Rwanda* | Denominación oficial de la ONU (Asamblea General, decisión 72/550, 2018) |
| *AIDS victims*, *AIDS countries* | *the HIV/AIDS epidemic*, *people living with HIV* | Terminología ONUSIDA/ONU |
| *high fertility problem*, *overpopulation*, *population bomb*, *demographic winter* | *fertility of {x} children per woman*; *population is projected to grow / decline* | Sin juicio de valor (A.8, D.6) |
| *failed / laggard / backward / still behind* | *recent movers*, *transition under way* | Sin jerarquía |
| *success* (para el descenso de la fecundidad) | *decline* | Neutral; enfoque de derechos de la CIPD |
| *ageing burden / grey tsunami* | *older age structure*, *median age of {x}* | Neutral |
| *Emirates attract migrants* | *net migration rate of +{x} per 1,000* | Describir, no atribuir motivos |
| *returns after conflict = attraction* | *return movements after conflict* | Sudán del Sur o Siria con CNMR > 0 son retornos (hallazgo S3 del plan) |

---

## 3. Texto exacto para la diapositiva y el segmento de ética

### 3.1 Panel de ética (Diapositiva 4, build 4; en el PDF es la franja inferior de la Diapositiva 4)

**Ubicación:** sustituye la "franja de ética y límites" actual del build 4. En el vídeo se amplía al 40 % inferior durante el segmento de voz (§3.2); en el PDF queda como franja inferior legible (≥ 20 px). No crea una diapositiva nueva: se respeta el límite de 4.

**Título del panel:** `How we kept it honest · ASA Ethical Guidelines (2022)`

**Texto (44 palabras, máx. 60):**
> We describe patterns; we do not claim causes. UN estimates (≤ 2023) and UN projections (≥ 2024) are never mixed, and projections carry the UN's own 80/95 % intervals. Each country is counted once — no aggregates added on top. Every number is regenerated by our public notebook.

**4 viñetas (icono + código ASA en gris):**
1. **Weakest data, said aloud** *(B.1 · D.10)* — Net migration is often a census residual; the UN revised the UAE's 2023 population by +12 % between editions.
2. **Uncertainty shown** *(B.2 · C.4)* — UAE 2050: 15.4 M on the medium line, 8.9–33.3 M in the UN 95 % interval.
3. **Fair framing** *(A.8 · D.6)* — Groups describe demographic paths, not development or worth. No judgement on fertility or migration.
4. **Open & checkable** *(B.3 · F.4)* — Hypotheses posted before analysis · examples chosen by rule · AI use declared, every number human-checked · github.com/{repo}

Pie del panel (14 px, gris): `ASA (2022), doi:10.5281/zenodo.7092386 · UN DESA (2024) WPP 2024 Methodology · World Bank FY2027 income groups applied to all years`

> Versión mínima si falta espacio en el PDF: el título, la primera frase del texto y las 4 viñetas reducidas a sus títulos en negrita con los códigos ASA.

### 3.2 Guion de voz (≈ 25 s, 61 palabras a 142 ppm)

**Versión A (bloque único, recomendada, entre 4:30 y 4:55):**
> How do we know this is honest? We keep estimates and projections apart and show the UN's own uncertainty: its 95 percent range for the Emirates in 2050 runs from nine to thirty-three million. Migration is the least-measured lever, so we say so. These are patterns, not causes. Every number — and our use of AI — is documented in our public repository.

Subtítulos (5 bloques ≤ 90 caracteres, literales a la voz):
1. `How do we know this is honest? We keep estimates and projections apart`
2. `and show the UN's own uncertainty: its 95 percent range for the Emirates in 2050`
3. `runs from nine to thirty-three million. Migration is the least-measured lever,`
4. `so we say so. These are patterns, not causes.`
5. `Every number — and our use of AI — is documented in our public repository.`

**Versión B (repartida, complemento de A).** La ética "aparece donde está el riesgo", que es justo lo que no hizo ningún ganador:
- **Recomendada.** Slide 1, zoom al Golfo: *"Net migration is the hardest number to measure: the UN revised the Emirates by twelve percent in 2024."* (18 palabras)
- **Opcional.** Slide 1, build 0 (tarjeta de datos): *"Grey means projection — a UN scenario with uncertainty we show."* (11 palabras)
- **Ya incluida en E41 (§6).** Slide 4, *fast movers*: *"in the UN's medium projection"*.

**Cómo pagar los segundos.** El guion actual tiene 713 palabras (≈ 301 s), ya por encima del objetivo de ≤ 700. La versión A sustituye la frase de cierre *"Everything follows the ASA ethical guidelines… public repository."* (25 palabras): **+36 netas**. La cláusula de identidad (E29) suma **+10** y la frase del Golfo **+18**, en total **+64**. Recortes propuestos (**−73**):
- Portada: *"and we used the UN World Population Prospects 2024 to find out which levers really move a country's population"* → *"We are Team {name}."* (−17; los datos se presentan en la Slide 1).
- Slide 1, build 0: *"…and what should the UN watch next in each group?"* → *"…and what should the UN watch on each?"* (−5).
- Slide 1: borrar *"Watch the pieces shift."* y *"One planet, four engines."* (−8).
- Slide 2: borrar *"That answers Question one."* (el sello ya lo dice; −4).
- Slide 3: *"Take fertility, the most quoted indicator."* → *"Take fertility."* (−5); borrar *"Each lever carries information the others cannot."* (el mensaje en pantalla ya lo dice; −7); PCA → *"A principal component analysis agrees: one axis captures only 46 percent."* (−9).
- Slide 4: *"Early movers … changed slowly and now depend on migration"* → versión E44 (−3); acortar la lista de la ONU a dos ejemplos (−15).

Balance: 713 + 64 − 73 ≈ **704 palabras** antes de aplicar las reescrituras del §6, que en conjunto tienen una longitud parecida a las frases que sustituyen. La frase opcional de la versión B (+11) solo entra si el cronometraje lo permite. El dueño del storyboard re-cronometra; si pasa de 4:55, se recorta primero la narración del build 0 de la Slide 1.

### 3.3 "Ethics badge": una línea al pie de cada gráfica (18 px, gris, inglés)

| Código | Usar en | Texto exacto |
|---|---|---|
| **PIE-1** | Mapas y conteos por país | `UN WPP 2024 (CC BY 3.0 IGO) · estimates, 2021–23 average · all 237 countries & areas, each counted once · descriptive, not causal` |
| **PIE-2** | Líneas por región SDG | `UN WPP 2024 · UN SDG-region aggregates (population-weighted) · estimates ≤ 2023, UN medium projection ≥ 2024 dashed` |
| **PIE-3** | Modelos (R², PCA, clústeres, índice, rezago) | `UN WPP 2024 · 161 countries ≥ 1 M people, 2023 · exploratory, not causal · net migration winsorized ±3 SD` |
| **PIE-4** | Cualquier gráfica por ingreso | `UN WPP 2024 + World Bank FY2027 income groups (2025 GNI), applied to all years · sums of countries · 21 areas without a group excluded` |
| **PIE-5** | Proyección con banda | `UN WPP 2024 · medium = mean of UN probabilistic trajectories · bands: UN 80 % / 95 % prediction intervals (not additive across countries)` |
| **PIE-6** | Toda gráfica con migración | `Net migration = arrivals − departures, often estimated as a census residual — the least-measured component (UN WPP 2024 Methodology)` |
| **PIE-0** | Pie fijo de cada diapositiva (ya en el storyboard; se mantiene) | `UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey)` |

Regla: cada gráfica lleva **PIE-0** más **uno** de PIE-1 a PIE-5 (más PIE-6 si muestra migración), sin pasar de dos líneas. En el notebook, el mismo texto en inglés va en `labs(caption = ...)`, generado por una función `badge("PIE-3")` para que nunca se escriba a mano.

---

## 4. Checklist de revisión ética (para el agente QA)

Instrucción para QA: responder **Sí / No / N.A.** a cada ítem y guardar el resultado en `docs/qa_etica.csv` (columnas `elemento, item, respuesta, nota, revisor, fecha`). Un solo "No" en un ítem marcado **[bloqueante]** impide grabar o enviar.

### 4.1 Cada gráfica (estática o animada)

| ID | Pregunta | Principio |
|---|---|---|
| G1 | ¿El título es un mensaje en lenguaje llano **sin verbos causales** (§4.5)? **[bloqueante]** | C.2 |
| G2 | ¿Lleva PIE-0 y el badge correcto (PIE-1 a PIE-6)? **[bloqueante]** | B.1 |
| G3 | Si cruza 2023/24, ¿tiene línea vertical, tramo proyectado gris/discontinuo y la etiqueta "UN medium projection"? **[bloqueante]** | B.2, C.2 |
| G4 | ¿Mezcla países y agregados? Si sí, ¿lo dice el pie? **[bloqueante]** | B.1 |
| G5 | ¿Cada cifra visible coincide con `numbers.json` (clave anotada)? **[bloqueante]** | C.2, A.2 |
| G6 | ¿El filtro (n países, umbral ≥ 1 M, año o promedio) aparece en el subtítulo o pie? | B.2 |
| G7 | ¿Los países resaltados o con bandera salen de la regla escrita (§2.3 #9) y figuran en `figures/miembros_*.csv`? **[bloqueante]** | A.4, Appendix 8 |
| G8 | ¿Barras desde 0? ¿Escala log declarada? ¿Sin ejes truncados que exageren? | C.2 |
| G9 | ¿La paleta evita el semáforo (verde = bueno / rojo = malo) y es apta para daltonismo (Okabe-Ito/viridis)? | D.6, B.2 |
| G10 | ¿Los nombres de grupos y categorías son neutrales (sin "late", "poor", "failed")? | A.8, D.6 |
| G11 | ¿Nombres de país según la ONU (o ISO3) y descargo de designaciones en los mapas? | D.6, C.7 |
| G12 | ¿Sin logos ni emblemas de la ONU o de sus agencias? **[bloqueante]** | C.7 |
| G13 | Si muestra una proyección clave, ¿hay banda PI 80/95 % o, al menos, la mención "UN medium; see PI in notebook"? | B.2, C.4 |
| G14 | Si muestra migración, ¿lleva PIE-6? | B.1, D.10 |
| G15 | ¿Microestados visibles, pero sin dominar la escala o el mensaje? | B.2 |
| G16 | ¿El R² u otras métricas de identidad están explicadas como identidad? | C.2 |
| G17 | ¿Se lee a 1920×1080 y al 50 % de tamaño (texto ≥ 18 px)? | F.5 |
| G18 | ¿Existe la versión estática PNG con *alt text* en el README? | F.4 |

### 4.2 Cada frase del guion y cada texto en pantalla

| ID | Pregunta | Principio |
|---|---|---|
| S1 | ¿Pasa el *grep* de verbos prohibidos (§4.5)? Si no, ¿se reescribió o se justificó como contable? **[bloqueante]** | C.2 |
| S2 | ¿Las afirmaciones sobre el futuro usan *is projected to / in the UN medium projection* (nunca *will*)? **[bloqueante]** | B.2 |
| S3 | ¿Cada número dicho tiene clave en `numbers.json` y coincide al redondear? **[bloqueante]** | C.2 |
| S4 | ¿Está claro el universo: "countries and areas", "countries with over a million people", "among the 89 countries…"? | B.2 |
| S5 | ¿Sin generalizaciones que el dato contradice (p. ej., "rich countries grow by migration" cuando Japón, Italia o la Rep. de Corea decrecen)? | C.2, Appendix 8 |
| S6 | ¿Sin juicio de valor sobre fecundidad, envejecimiento o migración? | A.8, D.6 |
| S7 | ¿Personas y crisis nombradas con la terminología del §2.6? | A.8, D.11 |
| S8 | ¿Los ejemplos nombrados cumplen la definición declarada (p. ej., promedio 2021–23)? **[bloqueante]** | A.4 |
| S9 | ¿Sin contrafactuales no identificados ("would shrink without…")? | C.2 |
| S10 | ¿Se nombra al menos una vez la incertidumbre (PI) y la debilidad de la migración? | B.2, C.4 |
| S11 | ¿Se dice "patterns, not causes" o equivalente? | C.3 |
| S12 | ¿Se evita prometer de más ("everything follows", "proves", "the answer")? | C.2, A.1 |
| S13 | ¿Las recomendaciones se formulan como *watch / plan / measure / prepare* y se derivan de una gráfica mostrada? | C.4, A.1 |
| S14 | ¿El subtítulo coincide literalmente con la voz? | F.5 |

### 4.3 Notebook R

| ID | Pregunta | Principio |
|---|---|---|
| N1 | ¿La primera celda tiene la cita de WPP 2024, la licencia CC BY 3.0 IGO, la cita ASA (2022) y la fecha de descarga? **[bloqueante]** | B.1, A.5 |
| N2 | ¿Hay una sección "Decisiones de datos" enlazada a `docs/decisiones_de_datos.md`? | B.1, B.2 |
| N3 | ¿Están los tests de doble conteo y de la identidad contable (residuo < 0,5 %) y pasan? **[bloqueante]** | B.1 |
| N4 | ¿Hay ficha "Fitness for use" (censos, revisiones 2022→2024, Togo, migración residual)? | B.1, D.10 |
| N5 | ¿Las hipótesis H1–H14 están enlazadas al commit con fecha y se reportan las que fallan? **[bloqueante]** | B.3, A.4 |
| N6 | ¿Cada sección analítica está etiquetada "Exploratorio" y no hay lenguaje causal? | C.3 |
| N7 | ¿Se reporta el número de pruebas y la corrección (Holm/BH) cuando hay p-valores? | B.3 |
| N8 | ¿Hay sensibilidades: 2023 vs 2021–23; ≥ 1 M vs 237; winsorización sí/no; umbrales del rezago; Togo original vs *update*; ingreso FY2027 vs histórico? | B.2, A.2 |
| N9 | ¿Se usan las PI del archivo OtherVariants para al menos 2 países, con la nota "marginal, no sumable"? | B.2, C.4 |
| N10 | ¿La selección de ejemplos y gemelos se hace por código y se exportan las listas completas? **[bloqueante]** | A.4 |
| N11 | ¿`set.seed(2026)`, `RNGkind()`, `sessionInfo()`, `renv::snapshot()` y SHA-256 de los insumos? **[bloqueante]** | B.4, F.4 |
| N12 | ¿`numbers.json` se genera al final y nada se teclea a mano en las diapositivas? **[bloqueante]** | C.2 |
| N13 | ¿Cada interpretación cita cifras reales del output (regla "review every output")? | B.2 |
| N14 | ¿Está la sección "Limitaciones y consideraciones éticas" (§5.1) completa? **[bloqueante]** | B.2, C.4 |
| N15 | ¿La sección "Lo que no encontramos" es explícita? | Appendix 8 |
| N16 | ¿Está la declaración de uso de IA y la tabla de verificación humana? | A.5, B.2 |
| N17 | ¿Los nombres de país siguen la ONU y no hay juicios de valor en los comentarios? | A.8, D.6 |
| N18 | ¿Corre de principio a fin en limpio (`make notebook`) en el tiempo previsto? | F.4 |

### 4.4 Repositorio y entrega

| ID | Pregunta | Principio |
|---|---|---|
| R1 | ¿El repo es **público antes** de enviar el vídeo, con la etiqueta `v1.0-submission`? **[bloqueante]** | F.4, C.6 |
| R2 | ¿El README (EN + ES) tiene limitaciones, IA, conflicto de interés, privacidad, licencias, cómo citar y cómo reproducir? **[bloqueante]** | B.1, A.7 |
| R3 | ¿Hay `docs/decisiones_de_datos.md`, `docs/correcciones.md`, `docs/hipotesis_H1_H14.md`, `docs/verificacion_numeros.csv` y `docs/registro_ia.md`? | B.3, B.5 |
| R4 | ¿Las licencias están (MIT código, CC BY 4.0 textos) y se respetan las de terceros? | C.7, A.5 |
| R5 | ¿Los datos grandes quedan fuera, con enlace oficial y *hash*? | B.4, C.7 |
| R6 | ¿Hay `CITATION.cff` con los autores y el rol de cada uno? | A.6, G.4 |
| R7 | ¿Se verificó el PDF final: 6 páginas (portada + 4 + referencias)? | Reglas del concurso / A.11 |
| R8 | ¿Las referencias incluyen la ONU (datos, metodología, nota de revisiones, Interim Update), el Banco Mundial FY2027, la ASA, los métodos y el software? | A.5 |
| R9 | ¿Hay consentimiento de cada miembro para su imagen, voz y nombre? | D.4 |
| R10 | ¿No hay datos personales innecesarios (correos, rutas locales con nombres)? | D.7 |

### 4.5 Lista de verbos y patrones (para el *grep* automático)

**Permitidos:** *is associated with · goes with · co-moves with · tends to · coincides with · accounts for (identidad contable) · is projected to (UN medium) · precedes / followed (temporal) · we observe · we describe · watch · plan · measure · prepare · invest in*.

**Prohibidos o a revisar** (regex insensible a mayúsculas; cada coincidencia exige reescritura o una justificación en `qa_etica.csv`):

```
\b(cause[sd]?|causing|drive[sn]?|driven|driving|leads? to|results? in|impact of|effect of|unlocks?|thanks to|because of|would (shrink|grow|fall|rise)|without (immigration|migration)|will (be|reach|grow|shrink|age|fall|rise|have)|proves?|significant(ly)?|rich|poor|backward|laggards?|late movers|burden|wave|flood|influx|illegal|bomb|overpopulat\w*|success(ful)?|fail(ed|ure)?|fills? the gap|replace[sd]?)\b
```

Notas: *because* y *due to* se admiten **solo** en sentido contable ("grew because net migration exceeded natural decrease") y deben marcarse como tales. *replacement fertility* se admite si se define en pantalla y no se asocia a migrantes.

Comando sugerido: `grep -niE -f docs/qa_patrones.txt docs/00_storyboard_diapositivas.md slides/*.html notebook/*.ipynb`

---

### 4.6 Plantilla de `docs/decisiones_de_datos.md`

````markdown
# Decisiones de datos (registro vivo)

> Regla: toda decisión que cambie una cifra en pantalla se registra **antes** de producir la figura final.
> Campos: ID · Fecha · Autor (persona) · ¿Asistida por IA? · Decisión · Alternativas consideradas · Elección · Razón (principio ASA) · Sensibilidad (resultado con la alternativa) · Cifras o diapositivas afectadas · Commit.

| ID | Fecha | Autor | IA | Decisión | Alternativas | Elección | Razón (ASA) | Sensibilidad (resultado) | Afecta a | Commit |
|---|---|---|---|---|---|---|---|---|---|---|
| D-01 | 2026-10-22 | {persona} | sí/no | Archivo base | Medium · Medium + OtherVariants | Medium (original jul-2024) + PI de OtherVariants para incertidumbre | B.1, B.2 | — | todas | {hash} |
| D-02 | | | | Países vs agregados | sumar todo · solo ISO3 · agregados ONU | `ISO3_code != ""` (237); agregados ONU solo para líneas regionales | B.1 | test de suma OK/no | SL1–SL4 | |
| D-03 | | | | Región | 6 continentes · 8 regiones SDG | 8 SDG (ParentID 918 asignado a mano) | C.1 | — | SL2, SL4 | |
| D-04 | | | | Ingreso | FY2027 constante · clasificación histórica | FY2027 constante + sensibilidad histórica 2000–23 | B.1, B.7, D.10 | 71 % vs {x} % | SL1 | |
| D-05 | | | | Estimación vs proyección | — | ≤ 2023 evidencia; ≥ 2024 gris + PI | B.2, C.2 | — | todas | |
| D-06 | | | | Año 2101 | conservar · eliminar | eliminar | B.2 | — | — | |
| D-07 | | | | Umbral de tamaño | 237 · ≥ 1 M | ≥ 1 M para modelos; 237 en mapas | A.2, B.2 | ρ con 237 = {x} | SL2–SL4 | |
| D-08 | | | | Ponderación | país = 1 · por población | país = 1 en distribuciones; agregados ONU en niveles | B.7 | — | | |
| D-09 | | | | CNMR extrema | sin tocar · winsorizar ±3 DE | ±3 DE solo PCA/cluster | B.2 | ARI con/sin = {x} | SL3, SL4 | |
| D-10 | | | | Tipo de palanca | año 2023 · promedio 2021–23 | promedio 2021–23 | B.2 | tipo C: 24 vs 18; 16 países cambian ✔ | SL0, SL1 | |
| D-11 | | | | Identidad contable | — | se presenta como identidad | C.2 | residuo = {x} % | SL1, SL3 | |
| D-12 | | | | Semilla y RNG | — | `set.seed(2026)`; `RNGkind("Mersenne-Twister","Inversion","Rejection")` | B.4 | — | bootstrap, k-means | |
| D-13 | | | | Togo (Interim Update ene-2026) | original · update | original + sensibilidad | D.10, B.5 | cambia {nada / x} | — | |
| D-14 | | | | Regla de ejemplos | a mano · más poblado · medoide | más poblado ≥ 1 M (tipos); medoide (grupos) | A.4 | lista en `figures/miembros_*.csv` | SL0–SL4 | |
| D-15 | | | | Gemelos | a mano · búsqueda exhaustiva | exhaustiva, top-5 publicado | A.4 | — | SL3 | |
| D-16 | | | | Umbrales del rezago | Q5<100/TFR<4 · Q5<50/TFR<3 | principal 100/4; sensibilidad 50/3 | B.2 | 11 vs 2 años | SL2 | |
| D-17 | | | | Clustering | k-means · Ward · DTW | k-means k={k}; Ward/DTW como robustez | B.2, C.3 | silueta {x}; Jaccard {x}; ARI {x} | SL4 | |
| D-18 | | | | Incertidumbre | sin PI · PI 80/95 | PI 80/95 para países representativos | B.2, C.4 | — | SL4 | |
| D-19 | | | | Nombres de país | comunes · ONU · ISO3 | ONU en texto; ISO3 en gráficas densas | D.6 | — | todas | |
| D-20 | | | | Paleta | semáforo · Okabe-Ito neutral | Okabe-Ito sin semántica bueno/malo | D.6 | — | SL1, SL4 | |
| D-21 | | | | Pruebas múltiples | sin corrección · Holm · BH | Holm (ANOVA), BH (rejilla) | B.3 | n_tests = {x} | NB | |
````

Plantillas hermanas (mismo estilo, crear vacías):
- `docs/correcciones.md`: Fecha · Error · Cómo se detectó · Impacto (cifras o diapositivas) · Corrección · Commit. **Entradas iniciales:** (1) "FY2026" → "FY2027" en el plan, el storyboard y las referencias; (2) Nepal y Uruguay no cumplen el tipo E con el promedio 2021–23; (3) conteo del tipo C: 18 (2023) vs 24 (2021–23); (4) "14–34×" no replicado para la TFR (5×); (5) WPP2024 Interim Update de Togo (ONU, 19-ene-2026).
- `docs/verificacion_numeros.csv`: `clave,valor,unidad,filtro,fuente_celda,comprobado_por,fecha,coincide_guion(S/N)`.
- `docs/registro_ia.md`: Fecha · Tarea · Herramienta (Claude Code) · Qué produjo · Quién revisó · Qué se cambió tras la revisión.

---

## 5. Plantillas de "Limitaciones y consideraciones éticas"

Los marcadores `{clave}` se rellenan desde `numbers.json`; no se escriben a mano.

### 5.1 Notebook (español) — sección final

````markdown
## 9. Limitaciones y consideraciones éticas

Este análisis sigue los *Ethical Guidelines for Statistical Practice* de la American Statistical Association (ASA, 2022; https://doi.org/10.5281/zenodo.7092386). Entre paréntesis indicamos el punto de las guías que motiva cada decisión.

### 9.1 Procedencia y calidad de los datos (B.1, D.10)
- Fuente: United Nations, DESA, Population Division (2024). *World Population Prospects 2024*, archivo `WPP2024_Demographic_Indicators_Medium` (licencia CC BY 3.0 IGO), descargado el {fecha}; SHA-256 `{hash}`. Suplemento LE60 entregado por los organizadores del DataQuest 2026.
- Las cifras de 1950–2023 son **estimaciones modelizadas** por la ONU, no observaciones directas. Solo 114 de los 237 países y áreas tienen un censo o registro de 2019 o posterior; 23 tienen el último censo antes de 2009. Entre WPP2022 y WPP2024, la población de 2023 cambió más de un 5 % en 34 países o áreas con ≥ 90 000 habitantes.
- **La migración neta es el componente peor medido**: muchas veces se estima como residuo entre censos, no distingue entradas de salidas y la ONU la ajusta para que el total mundial sea cero. Las revisiones más grandes entre ediciones tocan a países del Golfo (EAU +12 %, Qatar +9,7 %, Omán +8,7 %, Arabia Saudí −10 %).
- El 19 de enero de 2026 la ONU publicó una actualización para Togo (doble ajuste por subregistro). Usamos el archivo original; la sensibilidad con la actualización {cambia / no cambia} nuestras cifras ({detalle}).

### 9.2 Estimaciones, proyecciones e incertidumbre (B.2, C.4)
- Desde 2024 todo es **proyección (variante Medium)**: la media de miles de trayectorias probabilísticas de la ONU, que incorpora supuestos (convergencia según la teoría de la transición demográfica, retorno de refugiados, tasas de migración fijadas por expertos para {n} países). No es un dato observado.
- Las proyecciones no contienen crisis: la variabilidad anual proyectada es {ratio_cnmr}× menor que la estimada para la migración y {ratio_lex}× para la esperanza de vida.
- Mostramos los intervalos de predicción del 80 % y 95 % de la ONU para {países}. Son marginales por país e indicador y **no pueden sumarse** para grupos.

### 9.3 Decisiones analíticas y su sensibilidad (A.2, B.2, B.7)
- Excluimos los agregados del análisis por país para evitar el doble conteo (test de suma superado: {ok}).
- Los modelos usan los {n_1M} países con ≥ 1 M de habitantes; los mapas y conteos usan los 237. Con todos los países, las correlaciones clave pasan de {x} a {y}.
- Grupos de ingreso: World Bank FY2027 (INB per cápita 2025), **aplicados a todos los años**. Con la clasificación histórica, la participación migratoria del crecimiento de los países de ingreso alto en 2000–2023 pasa de {71} % a {x} %. Hay 21 áreas sin grupo (entre ellas, China, Taiwan Province of China).
- Tipo de "palanca": promedio 2021–23 (con 2023 solo, el tipo "crece solo por migración" pasa de {24} a {18} países; {16} países cambian de tipo).
- La tasa de migración se recorta a ±3 DE solo en PCA y clustering.
- Los ejemplos y "gemelos" se eligen por una regla en código ({regla}); las listas completas están en `figures/miembros_*.csv`.

### 9.4 Lo que no afirmamos (C.2, C.3, B.3)
- Todos los resultados son **descriptivos y exploratorios**: no hay inferencia causal. "La mortalidad infantil cae antes que la fecundidad" describe un orden temporal en {n_lag} de {n_1M} países, no una causa.
- Las hipótesis H1–H14 se publicaron el {fecha} (commit `{hash}`) antes de la corrida final, pero se formularon tras un EDA previo **con los mismos datos**: no son confirmaciones independientes.
- Hicimos {n_tests} comparaciones; donde reportamos p-valores aplicamos {Holm/BH}. Como los datos cubren a todos los países (no son una muestra), los intervalos *bootstrap* describen la sensibilidad al conjunto de países, no un error muestral.
- El R² cercano a 1 al combinar nacimientos, muertes y migración refleja una **identidad contable**.
- Los grupos de trayectoria tienen una separación débil (silueta {silueta}): son un continuo, no categorías naturales.

### 9.5 Personas y grupos afectados (A.8, D.6, D.11)
- Los grupos describen trayectorias demográficas, **no** niveles de desarrollo ni de bienestar; el índice compuesto no es un ranking de países.
- No emitimos juicios de valor sobre la fecundidad, el envejecimiento ni la migración. Las recomendaciones indican **dónde mirar**, con enfoque de derechos (Programa de Acción de la CIPD), y nunca proponen metas de fecundidad.
- Usamos los nombres oficiales de la ONU y su terminología para crisis, conflictos y epidemias.

### 9.6 Privacidad, reproducibilidad, IA y correcciones (D.4, B.4, B.5, F.4, A.5)
- No se usan datos personales: todo son agregados nacionales publicados.
- Reproducibilidad: R {version}, `renv.lock`, `set.seed(2026)`, `sessionInfo()` abajo; `make notebook` regenera `figures/numbers.json` y todas las figuras.
- **Uso de IA:** usamos asistentes de IA (Claude Code, de Anthropic) para redactar código, documentación y el guion. Cada cifra procede de este notebook, y miembros del equipo revisaron cada número y cada figura (`docs/verificacion_numeros.csv`).
- Los errores detectados y corregidos se registran en `docs/correcciones.md`.

### 9.7 Conflictos de interés y límites de competencia (A.1, A.7)
- Sin financiación ni conflictos de interés; sin afiliación con la ONU ni con el Banco Mundial.
- Somos estudiantes de {nivel}; no re-estimamos las cifras de la ONU ni hacemos proyecciones propias. Revisión temática: {profesor/asesor}.
````

### 5.2 README — English

````markdown
## Limitations & ethical considerations

We follow the American Statistical Association's *Ethical Guidelines for Statistical Practice* (ASA, 2022, https://doi.org/10.5281/zenodo.7092386). Codes in brackets point to the guideline behind each choice.

- **Data provenance [B.1, D.10].** United Nations, DESA, Population Division (2024), *World Population Prospects 2024*, CC BY 3.0 IGO. Figures for 1950–2023 are UN model-based **estimates**; from 2024 on they are the UN **medium projection**, never mixed with estimates. We use the original July 2024 file. The UN's January 2026 interim update for Togo is documented in `docs/correcciones.md`.
- **Weakest component [B.2, C.4].** Net migration (arrivals minus departures) is often estimated by the UN as a residual between censuses, and its projections include expert assumptions. Gulf populations changed by up to 12 % between the 2022 and 2024 UN editions.
- **Uncertainty [B.2].** Key projections are shown with the UN's 80 % / 95 % prediction intervals (e.g., UAE 2050: {15.4} M, 95 % PI {8.9–33.3} M).
- **Countries, not aggregates [B.1].** Each of the 237 countries and areas is counted once; UN regional aggregates are used only for regional lines.
- **Choices that matter [A.2, B.7].** Models use the {161} countries with ≥ 1 million people. Income groups are World Bank FY2027 (2025 GNI per capita), applied to all years. Lever types use the 2021–23 average. Sensitivity results are in the notebook and `docs/decisiones_de_datos.md`.
- **Exploratory, not causal [C.3, B.3].** All findings are descriptive. Hypotheses H1–H14 were committed on {date} (`{hash}`) before the final run but were formed after an earlier exploration of the same data. We report what we did not find and the number of comparisons made.
- **Fair framing [A.8, D.6].** Groups describe demographic paths, not development or worth. No judgement on fertility, ageing or migration. UN country names and terminology.
- **Examples chosen by rule [A.4].** Highlighted countries are selected by code (largest of each type with ≥ 1 M people; group medoids). Full membership lists are in `figures/`.
- **Privacy [D.4].** No personal data; national aggregates only.
- **AI use [A.5, B.2].** We used AI assistants (Claude Code by Anthropic) to draft code, documentation and the video script. Every number comes from the notebook and was checked by a team member (`docs/verificacion_numeros.csv`).
- **Conflicts of interest [A.7].** None. No funding. Not affiliated with the UN or the World Bank.
- **What this project is not [A.1].** It is not a UN product, not a forecast of our own, not a causal study and not a ranking of countries.
- **Corrections [B.5].** See `docs/correcciones.md`.

*Boundaries and names shown on maps do not imply official endorsement or acceptance by the United Nations.*

### How to cite
Team {name} (2026). *One Number Can't Tell 8 Billion Stories* [code and notebook]. GitHub: {repo}. Data: United Nations, DESA, Population Division (2024), World Population Prospects 2024.
````

### 5.3 README — Español

````markdown
## Limitaciones y consideraciones éticas

Seguimos los *Ethical Guidelines for Statistical Practice* de la American Statistical Association (ASA, 2022, https://doi.org/10.5281/zenodo.7092386). Entre corchetes, el punto de las guías que motiva cada decisión.

- **Procedencia [B.1, D.10].** Naciones Unidas, DESA, División de Población (2024), *World Population Prospects 2024*, CC BY 3.0 IGO. 1950–2023 = **estimaciones** modelizadas por la ONU; desde 2024 = **proyección Medium**, nunca mezclada con estimaciones. Usamos el archivo original de julio de 2024; la actualización de Togo (ONU, enero de 2026) está documentada en `docs/correcciones.md`.
- **Componente más débil [B.2, C.4].** La migración neta (entradas menos salidas) suele estimarse como residuo entre censos y su proyección incluye supuestos de expertos. Las poblaciones del Golfo cambiaron hasta un 12 % entre las ediciones 2022 y 2024 de la ONU.
- **Incertidumbre [B.2].** Las proyecciones clave se muestran con los intervalos de predicción del 80 % y 95 % de la ONU (p. ej., EAU 2050: {15,4} M; IP 95 % {8,9–33,3} M).
- **Países, no agregados [B.1].** Cada uno de los 237 países y áreas se cuenta una vez; los agregados regionales de la ONU solo se usan en las líneas regionales.
- **Decisiones que importan [A.2, B.7].** Los modelos usan los {161} países con ≥ 1 millón de habitantes; los grupos de ingreso son los del Banco Mundial FY2027 (INB per cápita 2025), aplicados a todos los años; los tipos de "palanca" usan el promedio 2021–23. Las sensibilidades están en el notebook y en `docs/decisiones_de_datos.md`.
- **Exploratorio, no causal [C.3, B.3].** Todos los hallazgos son descriptivos. Las hipótesis H1–H14 se publicaron el {fecha} (`{hash}`) antes de la corrida final, pero se formularon tras explorar los mismos datos. Reportamos lo que no encontramos y el número de comparaciones.
- **Encuadre justo [A.8, D.6].** Los grupos describen trayectorias demográficas, no desarrollo ni valor. Sin juicios sobre fecundidad, envejecimiento o migración; nombres y terminología de la ONU.
- **Ejemplos por regla [A.4].** Los países resaltados se eligen por código; las listas completas están en `figures/`.
- **Privacidad [D.4].** Sin datos personales; solo agregados nacionales.
- **Uso de IA [A.5, B.2].** Usamos asistentes de IA (Claude Code, de Anthropic) para redactar código, documentación y el guion. Cada cifra sale del notebook y la verificó un miembro del equipo.
- **Conflictos de interés [A.7].** Ninguno; sin financiación; sin afiliación con la ONU ni con el Banco Mundial.
- **Qué no es este proyecto [A.1].** No es un producto de la ONU, ni una proyección propia, ni un estudio causal, ni un ranking de países.
- **Correcciones [B.5].** Ver `docs/correcciones.md`.

*Los límites y nombres de los mapas no implican aprobación ni aceptación oficial por parte de las Naciones Unidas.*
````

---

## 6. Revisión ética del storyboard actual (`00_storyboard_diapositivas.md`)

Prioridad: **P1** = corregir antes de grabar (engaña o es inexacto); **P2** = mejora fuerte de ética o encuadre; **P3** = pulido. ✔ = verificado con los datos por este agente.

### 6.1 Portada (0:00–0:30)

| ID | Texto actual | Problema (principio) | Propuesta | P |
|---|---|---|---|---|
| E1 | Subtítulo: `…across 237 countries, 1950–2100…` | La ONU habla de "countries and areas"; 1950–2100 mezcla estimación y proyección (C.2, D.6) | `Births, deaths and migration in 237 countries and areas — UN estimates 1950–2023, projections to 2100 — and where the UN should look next` | P2 |
| E2 | *"Yet seventy-nine still grow"* | Ambiguo: 79 es el número con **más nacimientos que muertes** ✔, no con crecimiento total (C.2) | *"Yet seventy-nine of them still have more births than deaths."* | P1 |
| E3 | *"and eighteen grow only because people move in"* y build 3 `18 grow only because people move in` | 18 usa el año 2023 solo; el mapa usa el promedio 2021–23 (= 24) ✔; incluye 7 áreas < 1 M ✔ (B.2) | Elegir una definición (recomendado: promedio 2021–23) en portada y mapa: *"and in {24}, deaths exceed births, yet the population grows because more people arrive than leave."* En pantalla: `{24} grow only through net migration ({14} with ≥ 1 M people)` | P1 |
| E4 | Banderas DE, ES, FI | Elegidas a mano: los 3 más poblados del tipo son DEU, ESP, BEL (2023) o DEU, ESP, POL (2021–23) ✔ (A.4) | Banderas = los 3 más poblados del tipo según la definición elegida, con nota `largest three` | P1 |
| E5 | *"…to find out which levers really move a country's population."* | *really move* es causal (C.2); además duplica la presentación de datos | *"We are Team {name}."* (los datos se presentan en la Slide 1; se ahorran 17 palabras) | P2 |

### 6.2 Slide 1 — Question 1 (0:30–1:50)

| ID | Texto actual | Problema (principio) | Propuesta | P |
|---|---|---|---|---|
| E6 | Mensaje: `Rich countries grow by migration; the rest grow by births — 18 countries would shrink without immigration.` | (i) *rich*; (ii) generalización contradicha por los datos: Japón, Italia y la Rep. de Corea son de ingreso alto y decrecen ✔; (iii) **contrafactual causal** no identificable con datos netos (sin inmigrantes cambiarían también los nacimientos) (C.2, A.4) | `High-income countries: net migration accounted for {71} % of population growth since 2000. Elsewhere, growth came almost entirely from births exceeding deaths.` | P1 |
| E7 | Tarjeta de datos: `237 countries · 54 indicators …` + **logo UN DESA** + "CC BY 3.0 IGO" | Uso restringido del emblema de la ONU; puede sugerir respaldo (C.7, A.6) | `237 countries and areas · UN estimates 1950–2023 · UN medium projection 2024–2100 (grey, with uncertainty) · Source: UN DESA Population Division (2024), CC BY 3.0 IGO` — **sin logo**. Añadir línea: `Net migration = arrivals − departures, the least-measured component` | P1 |
| E8 | Narración build 0: *"Our data: 237 countries…"* | "countries and areas"; añadir que la proyección tiene incertidumbre (B.2) | *"Our data: 237 countries and areas — UN estimates to 2023, and the UN medium projection from 2024, always in grey, with its uncertainty."* | P2 |
| E9 | Pregunta 1: `Which lever moves each country…` | La metáfora *lever* sugiere control de políticas sobre la fecundidad (D.6) | Mantener *lever* pero definirlo en build 1 bajo la ecuación: `Lever = a component of the population balance, not a policy switch.` | P2 |
| E10 | Anotación build 2: `High income, 2000–2023: {share}% of growth = migration` | Anacronismo: grupos de hoy aplicados al pasado; etiqueta FY (B.1, D.10) | `Today's high-income countries (World Bank FY2027), 2000–2023: net migration = {71} % of population change` (+ sensibilidad histórica en el notebook) | P1 |
| E11 | *"In high-income countries the picture flipped: since 2000, seventy-one percent of their growth came from migration."* | Bien en esencia; precisar el grupo y "net" (B.1) | *"In today's high-income countries, net migration accounted for seventy-one percent of population growth since 2000."* | P2 |
| E12 | *"Blue: growing only because people move in — eighteen countries, including Germany, Spain and Finland, where deaths already exceed births."* | Definición y ejemplos fuera de la regla (A.4, B.2) | *"Blue: deaths exceed births, yet the population grew because more people arrived than left — {24} countries and areas, the largest being Germany, Spain and Poland."* (ajustar a la regla elegida) | P1 |
| E13 | *"Red: shrinking because deaths exceed births — Japan, Italy, Korea."* | "Korea" ambiguo; color rojo = alarma (D.6) | *"Orange: shrinking as deaths exceed births — Japan, Italy, the Republic of Korea."* ✔ (tipo D con ambas definiciones) | P2 |
| E14 | *"Orange: shrinking because people leave, although births exceed deaths — Albania, Nepal, Uruguay."* | **Error con la regla declarada**: con el promedio 2021–23, Nepal crece y Uruguay tiene más muertes que nacimientos ✔. Los ≥ 1 M de este tipo son solo Albania, Kosovo (under UNSC res. 1244) y Mauricio (A.4, C.2) | *"Purple: births exceed deaths, but more people leave than arrive — Albania and Mauritius among them."* Si se elige el año 2023, la lista es Nepal, Azerbaiyán, Uruguay, Albania, Kosovo y Mauricio, y debe decirse "in 2023". | P1 |
| E15 | Paleta del mapa: verde = crece, rojo/bermellón = decrece | Semáforo bueno/malo (D.6) | Okabe-Ito sin semáforo: azul #0072B2 · celeste #56B4E9 · naranja #E69F00 · púrpura rojizo #CC79A7 · gris #999999. Pie: `Groups describe demographic mechanisms, not good or bad outcomes.` | P2 |
| E16 | Zoom al Golfo: `UAE: +{cnmr} per 1,000 — population grows 3.7 %/yr with fertility 1.2` | Cifras correctas ✔ (3,70 %; 1,20; +28,2 ‰), pero falta la calidad del dato (B.1, D.10) | Mantener y añadir nota: `UN revised the UAE's 2023 population by +12 % between its 2022 and 2024 editions (labour-migration rebound).` + PIE-6 | P1 |
| E17 | *"Watch the pieces shift."* · *"One planet, four engines."* | Neutrales; se recortan por tiempo | Eliminar (−8 palabras) | P3 |

### 6.3 Slide 2 — Question 1 cont. (1:50–2:45)

| ID | Texto actual | Problema (principio) | Propuesta | P |
|---|---|---|---|---|
| E18 | Título: `…mortality falls first, fertility follows, migration has no memory` | Secuencia leída como causa; "no memory" puede ser también error de medida (C.2, B.2) | `Question 1 · Same road, different speed: child mortality tended to fall first; migration shows little persistence` | P2 |
| E19 | Mensaje: `Child mortality falls ~11 years before fertility; migration only matters where births and deaths already cancel out.` | Subconjunto no declarado (89/161); "only matters" contradicho por el Golfo (B.2, C.2) | `Among the {89} countries that crossed both thresholds after 1950, child mortality fell below 100 per 1,000 a median of {11} years before fertility fell below 4. Migration weighs most where births and deaths nearly balance — and in the Gulf.` | P1 |
| E20 | Flecha: `Everyone heads here` | Teleología; la proyección de la ONU **supone** la transición (*"based in the demographic transition theory"*), así que mostrarla como evidencia es circular (B.2, C.2) | `Observed to 2023: every region moved toward low mortality and low fertility. Dashed: UN projection, which assumes this continues.` | P1 |
| E21 | Anotaciones `1959–62 China famine` · `HIV/AIDS 1990s` · `COVID-19` | Fechas y terminología (A.8) | `1959–61 famine in China` ✔ (esperanza de vida 33,4 en 1960) · `HIV/AIDS epidemic (Southern Africa)` · `COVID-19 pandemic (2020–21)` | P2 |
| E22 | Panel de velocidad: `Europe {yrs_eu} · … · SSA still on the road` | Europa censurada (ya < 5 hijos en 1950); "still on the road" suena a retraso (B.2, D.6) | `Europe: below 5 before 1950 · Asia {x} yrs · LAC {y} yrs · Sub-Saharan Africa: transition under way` | P2 |
| E23 | Dumbbell: `Mortality first in {share}% of countries` + resaltes KEN, BGD, MEX | Universo y selección a mano (B.2, A.4) | `Mortality first in {80} % of the {89} countries with both crossings after 1950` · resaltado = el país con el rezago mediano de cada región (por código) | P1 |
| E24 | `Migration: no memory — reacts to shocks (Syria 2012–16, Ukraine 2022)` | "shocks" deshumaniza; β ≈ −1 también es lo que produce el ruido de medida (A.8, B.2) | `Migration: 1950 levels say nothing about 2023 (β ≈ −1) — flows change fast and are hard to measure. Spikes: the conflict in the Syrian Arab Republic (2012–16), the war in Ukraine (2022).` | P1 |
| E25 | *"Europe took a century, Asia and Latin America about fifty years, and sub-Saharan Africa is on the road right now."* | Europa censurada en 1950 | *"Europe started before 1950; Asia and Latin America took about fifty years; in sub-Saharan Africa the transition is under way now."* | P2 |
| E26 | *"It reacts to shocks, like Syria or Ukraine, and in rich countries it fills the gap that low fertility leaves."* | "fills the gap" instrumentaliza y evoca el "reemplazo"; "rich" (A.8, D.6) | *"It spikes with crises, such as the conflict in Syria or the war in Ukraine. And in high-income countries, it now accounts for most of the growth, as births and deaths come close to balancing."* | P1 |
| E27 | *"That answers Question one."* | Redundante con el sello | Eliminar (−4) | P3 |

### 6.4 Slide 3 — Question 2 (2:45–3:45)

| ID | Texto actual | Problema (principio) | Propuesta | P |
|---|---|---|---|---|
| E28 | Mensaje: `…three levers explain 99 % — and the same number can mean opposite things.` | Identidad presentada como hallazgo; "explain" puede sonar causal (C.2) | `No. Fertility alone accounts for 59 % of the differences in growth; adding deaths and migration reaches 99 % — by construction, since growth = births − deaths + migration. No component is redundant.` | P1 |
| E29 | *"Add migration: ninety-nine."* | Igual que E28, pero en la voz (C.2) | *"Add migration: ninety-nine — almost by definition, because growth is births minus deaths plus migration."* (+10) | P1 |
| E30 | Gemelos: `Jordan · Bosnia` | Nombre oficial; la selección debe declararse (D.6, A.4) | `Jordan · Bosnia and Herzegovina` y nota pequeña `pairs found by searching all country pairs (≥ 1 M)` | P2 |
| E31 | `in 2023 high death rate = old population (ρ = +0.06)` | ρ(CDR, LEx) = +0,06 indica que la tasa ya no sigue a la esperanza de vida, **no** que mida la edad; el vínculo con la edad es ρ(CDR, edad mediana) = +0,50 (Pearson) / +0,46 (Spearman), 2023, ≥ 1 M ✔ (C.2) | `2023: the death rate no longer tracks life expectancy (ρ = +0.06); it rises with median age (ρ = +0.50)` | P1 |
| E32 | *"Take fertility, the most quoted indicator."* · frase del PCA | Por tiempo | *"Take fertility."* · *"A principal component analysis agrees: one axis captures only 46 percent."* (−14) | P3 |
| E33 | Bump chart del índice | Puede leerse como ranking de desarrollo (D.6) | Pie: `Not a ranking of well-being or development — a test of how design choices move ranks.` País resaltado = el de mayor amplitud de rango con ≥ 1 M (por código) | P2 |

### 6.5 Slide 4 — Question 3 (3:45–5:00)

| ID | Texto actual | Problema (principio) | Propuesta | P |
|---|---|---|---|---|
| E34 | Título: `…and the lever to watch on each` · mensaje: `…each road needs a different lever, now.` | "needs" prescriptivo; reifica clústeres débiles (C.2, C.3) | `Question 3 · Four roads through the transition — and what to watch on each` · `Grouping countries by 70 years of movement (a continuum, not boxes) points to a different thing to watch on each road.` | P2 |
| E35 | Nombres `Late movers` · `Migration-boosted` | Jerarquía o atraso; instrumentaliza (D.6, A.8) | `Recent movers` · `Migration-led` (mantener Early / Fast movers) | P2 |
| E36 | Banderas de ejemplo FR/JP/US · CN/BR/TR · NG/PK/ET · AE/QA/JO | Elegidas a mano (A.4) | 3 por grupo = medoide + 2 más poblados del grupo (por código) | P1 |
| E37 | `Median age gap… doubled (SD …)` · `Life expectancy at 60: countries are pulling apart` | Correcto si es ≤ 2023; si se extiende a 2100, marcarlo | Añadir `estimates 1950–2023` al panel y separar el tramo proyectado | P2 |
| E38 | Tabla "Which lever, where, when" con **icono de agencia** | Emblemas de la ONU (C.7); "lever" | Título `What to watch, where, when`; agencias en texto (`for: UNFPA, UNICEF`), sin iconos | P1 |
| E39 | Fila fast movers: `…for a median age of 45 by 2050` | Proyección como hecho (B.2) | `…for a projected median age of ≈ {45} by 2050 (UN medium; 95 % PI for China {a–b})` | P1 |
| E40 | Franja de ética: `income groups = World Bank FY2026 …` | **Etiqueta errónea**: el archivo es FY2027 (B.1, B.5) | Sustituir la franja por el panel del §3.1 | P1 |
| E41 | *"Fast movers … will age faster than anyone before: median age forty-five by 2050."* | Futuro indicativo + superlativo no verificado (B.2, C.2) | *"Fast movers … are projected to age faster: a median age of about forty-five by 2050, in the UN's medium projection."* | P1 |
| E42 | *"Late movers … are where child survival is still the lever that unlocks the rest."* | Causal ("unlocks"); paternalista (C.2, D.6) | *"Recent movers — most of sub-Saharan Africa, Pakistan, Afghanistan — still have high child mortality, and elsewhere its fall came before fertility declined. That is where to watch child survival."* | P1 |
| E43 | *"Migration-boosted states — the Gulf — depend on flows that can reverse."* | Bien en esencia; puede añadir la calidad del dato | *"Migration-led states, such as those in the Gulf, rest on flows that the UN itself finds hardest to project."* | P2 |
| E44 | *"Early movers … changed slowly and now depend on migration."* | "depend" aceptable; más neutro y más corto | *"Early movers — Europe, Japan, North America — now grow mainly through migration."* (Japón decrece ✔ → mejor *"Europe, North America — now grow mainly through migration; Japan is shrinking."* o quitar Japón de los ejemplos de crecimiento) | P1 |
| E45 | Cierre: *"Everything follows the ASA ethical guidelines: estimates and projections are kept apart, no causal claims, and every number is reproducible…"* | Promete de más (C.2) mientras el guion aún tiene frases causales | Sustituir por el guion del §3.2 (versión A) | P1 |
| E46 | Callback `…three levers, read region by region, can.` | Correcto | Mantener | — |

### 6.6 Referencias y notas de producción

| ID | Texto actual | Problema | Propuesta | P |
|---|---|---|---|---|
| E47 | `World Bank (2025). World Bank Country and Lending Groups, FY2026 (API download 2026-10-22).` | Año y versión errados (B.1) | `World Bank (2026). World Bank Country and Lending Groups, FY2027 (effective 1 July 2026; 2025 GNI per capita, Atlas method). API download 2026-10-22.` | P1 |
| E48 | Faltan referencias de la ONU | Crédito y procedencia (A.5, D.10) | Añadir: `UN DESA (2024). WPP 2024: Methodology of the UN population estimates and projections. UN DESA/POP/2024/DC/NO.10` · `United Nations (2024). WPP 2024: Summary of Results. UN DESA/POP/2024/TR/NO.9` · `UN DESA (2024). Release note: differences in total population 2022 vs 2024 revisions` · `UN DESA (2026). WPP 2024 Interim Update (Togo), 19 Jan 2026` | P2 |
| E49 | Falta la declaración de IA | Transparencia (A.5, B.2) | Línea en SL5: `AI assistance: Claude Code (Anthropic) helped draft code and text; every number was regenerated by the notebook and checked by the team.` | P1 |
| E50 | Mapa: `maps::map_data("world")` | Crédito y descargo | `Map polygons: R package maps (Natural Earth-derived). Boundaries do not imply UN endorsement.` | P2 |
| E51 | Notas: verbos permitidos y prohibidos | ✔ Buena práctica ya presente | Extender con la lista del §4.5 y automatizar el *grep* | — |
| E52 | Pie fijo `UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey)` | ✔ Buena práctica ya presente | Mantener como PIE-0 | — |

**Cosas del storyboard que ya están bien** (dar crédito al autor): la proyección en gris con línea 2023/24; *"a continuum, not boxes"* aunque la silueta sea baja; la tabla de verbos permitidos y prohibidos; las recomendaciones con enfoque de derechos (*rights-based reproductive health*, *migrant rights & data*); las sumas de países por ingreso comprobadas contra "World"; el umbral ≥ 1 M con microestados visibles; la correlación por ingreso relegada al notebook.

---

## 7. Comparativa ética con los ganadores 2025 y cómo superarlos

Base: `01_analisis_ganadores_2025.md`. Glorystician, ganador de Best Consideration of Ethics, no tiene material público: solo sabemos que su universidad (ULM) tuvo un enfoque sistemático de "ethics aspect per ASA standards".

| Dimensión ética | TRITICS (Best Data Viz) | QuantaQuartet (Best Statistical Insight; 3.º nacional en ética) | Nuestro plan con este documento |
|---|---|---|---|
| Cita explícita de las guías ASA | No | No | Sí: panel con códigos (B.1, B.2, C.4, A.8, D.6, B.3, F.4) y cita DOI |
| Diapositiva o segmento de límites | Ninguno | Implícito (cobertura y faltantes al inicio) | Panel en la SL4, 25 s de voz y 3 micro-momentos donde surge el riesgo |
| Calidad y procedencia de los datos | No | **Sí, fuerte**: faltantes por variable, disponibilidad por año, "invisible children" | Migración residual, censos antiguos (23 países antes de 2009), revisiones 2022→2024 (Golfo ±10–12 %), Interim Update de Togo |
| Incertidumbre | Ninguna | CV R² = 0,15 reportado, sin discutir | PI 80/95 % de la ONU en pantalla (EAU 2050: 8,9–33,3 M) |
| Lenguaje causal | Sí ("drives", "lever to pull") | Sí ("mainly driven by") | Lista de verbos con *grep* automático; contrafactuales eliminados |
| Exploratorio vs confirmatorio | No | No | Etiquetas; hipótesis con fecha más la honestidad de que salen de un EDA previo; "What we did not find" |
| Comparaciones múltiples / circularidad | "≥ 50 % de periodos significativos" sin corrección | ANOVA circular sobre K-means | Conteo de pruebas, Holm/BH, sin pruebas sobre variables de clustering, validación externa |
| Selección de casos | Sin criterio visible | Sin criterio visible | Regla en código (más poblado / medoide) y listas completas publicadas |
| Estigmatización de grupos | — | Mapa rojo sobre África sin contexto | Paleta sin semáforo, nombres por comportamiento, "not a ranking", terminología ONU |
| Reproducibilidad | No mencionada | Repo público **después** del plazo | Repo público **antes** de enviar, `renv`, semillas, hashes, `make notebook` |
| Uso de IA | No declarado | No declarado | Declaración y verificación humana por número |
| Corrección de errores | — | Inconsistencias de n (58 vs 78) sin explicar | `correcciones.md` con las primeras 5 entradas ya identificadas |
| Crédito y licencias | Logos institucionales | README cuidadoso | Licencias de datos, código y textos; sin emblemas de la ONU; métodos y fuentes históricas citados |

**Cómo superarlos (orden de impacto ante el jurado de ética):**
1. **Hacer la ética visible en el minuto en que aparece el riesgo**, no solo al final: la frase del Golfo, el gris de la proyección y la banda PI. Ningún ganador lo hizo.
2. **Cuantificar los límites con cifras de la propia ONU** (±12 % de revisión, 23 países con censo anterior a 2009, PI 8,9–33,3 M). La honestidad con números convence más que un descargo.
3. **Copiar lo mejor de QuantaQuartet** (la calidad de los datos al principio) y **superarlo**: una línea de "fitness for use" en la tarjeta de datos de la SL1, además de citar la ASA, que ellos no hicieron.
4. **Evitar sus dos fallos estadísticos con carga ética**: lenguaje causal y análisis circular. El checklist §4 lo bloquea.
5. **Repo público antes del envío**, con la declaración de IA y el registro de correcciones. Es un diferenciador barato y comprobable.
6. **Encuadre justo de grupos**: paleta y nombres neutrales, enfoque de derechos de la CIPD (ICPD), nunca metas de fecundidad. Es el punto D.6 que el mapa rojo de QuantaQuartet no cuidó.

---

## Anexo A. Cifras verificadas por este agente (pandas, 2026-10-22)

Archivos: `../WPP2024_Demographic_Indicators_Medium_csv.gz` y `../WPP2024_Demographic_Indicators_OtherVariants_csv.gz` (lectura con `encoding="utf-8-sig"` y `na=""`); `data/raw/WB_income_groups.csv` y `wb_api_income_2026-10-22.csv`. **Reproducir en R** en el notebook antes de usarlas.

| Cifra | Valor | Definición / filtro |
|---|---|---|
| Países y áreas (`ISO3_code` no vacío) | 237 | Medium, 2023 |
| TFR < 2,1 en 2023 / de ellos con NatChange > 0 | 130 / 79 | 237 países y áreas |
| Tipo C "crece solo por migración" | **18** (11 ≥ 1 M) con 2023 · **24** (14 ≥ 1 M) con promedio 2021–23 | NatChange < 0 y PopChange > 0 |
| Tipo C, los más poblados | 2023: DEU, ESP, BEL, HUN, FIN, SVK… · 2021–23: DEU, ESP, POL, BEL, CZE, PRT, AUT, FIN… | — |
| Tipo E "decrece por emigración" | **19** (6 ≥ 1 M: NPL, AZE, URY, ALB, XKX, MUS) con 2023 · **17** (3 ≥ 1 M: ALB, XKX, MUS) con 2021–23 | NatChange > 0 y PopChange < 0 |
| Tipo D "más muertes que nacimientos y decrece" | 35 (2023) · 31 (2021–23); JPN, ITA, KOR en ambos | NatChange < 0 y PopChange < 0 |
| Países que cambian de tipo entre definiciones | 16 | 2023 vs 2021–23 |
| Nepal / Uruguay / Hungría con 2021–23 | crece por nacimientos / más muertes que nacimientos / más muertes que nacimientos | — |
| EAU 2023 | crecimiento 3,70 %, TFR 1,20, CNMR +28,2 ‰ | — |
| Bielorrusia 2023 | TFR 1,21, crecimiento −0,65 % | — |
| ρ(CDR, LEx) 2023 | +0,03 (Pearson), +0,07 (Spearman) | 161 países ≥ 1 M |
| ρ(CDR, edad mediana) 2023 | +0,50 (Pearson), +0,46 (Spearman) | 161 países ≥ 1 M |
| Relación de DE del cambio anual, estimación (1951–2023) / proyección (2025–2100) | CNMR 25,5× · LEx 24,1× · TFR 5,1× | 161 países ≥ 1 M (el plan dice "14–34×": revisar la medida) |
| Países y áreas < 1 M / < 100 mil (2023) | 76 / 37 | — |
| PI mundo 2100 | Medium 10,18 mil M; 80 % 9,41–11,03; 95 % 9,05–11,44 | OtherVariants |
| PI EAU 2050 | Medium 15,37 M; 80 % 10,09–26,09; 95 % 8,89–33,26; CNMR 80 % −19,4 a +42,6 ‰ | OtherVariants |
| PI Nigeria 2100 | Medium 476,7 M; 95 % 255,5–1 142,5 M | OtherVariants |
| PI Japón 2100 | Medium 76,8 M; 95 % 47,8–112,8 M | OtherVariants |
| Togo 2023 en nuestro archivo | 9,30 M (archivo original; el Interim Update corrige el nivel) | Medium |
| China, esperanza de vida 1958 → 1960 → 1962 | 48,8 → 33,4 → 51,0 | Medium (hambruna 1959–61) |
| Banco Mundial (copia del API) | 217 economías: 25 bajo / 47 medio-bajo / 59 medio-alto / 86 alto; VEN = medio-bajo; JOR, FSM, PHL, LKA, VNM = medio-alto; TGO = medio-bajo | = FY2027 |
| WPP sin grupo del Banco Mundial | 21 (≥ 1 M: solo China, Taiwan Province of China, 23,3 M); el BM tiene CHI, que WPP separa en GGY y JEY | — |
| Variables con PI en OtherVariants | `Lower/Upper 80 PI`, `Lower/Upper 95 PI`, `Median PI`, `Mean` para TPopulation, TFR, LEx, MedianAgePop, CNMR, NetMigrations, Q5, CDR, etc. | — |

## Anexo B. Fuentes

- American Statistical Association (2022). *Ethical Guidelines for Statistical Practice*. Zenodo, CC BY 4.0. https://doi.org/10.5281/zenodo.7092386 · PDF: https://www.amstat.org/docs/default-source/amstat-documents/EthicalGuidelines.pdf
- United Nations, DESA, Population Division (2024). *World Population Prospects 2024: Methodology of the United Nations population estimates and projections*. UN DESA/POP/2024/DC/NO.10. Secciones citadas: I.E (estimación de la migración neta), II.A (fecundidad y transición demográfica), II.E (proyección de la migración, tabla II.3).
- United Nations (2024). *World Population Prospects 2024: Summary of Results*. UN DESA/POP/2024/TR/NO.9 (anexo sobre disponibilidad de datos; media vs mediana; clasificación de ingreso de mayo de 2024).
- UN DESA, Population Division (2024). *World Population Prospects 2024: Release note about major differences in total population estimates for mid-2023 between 2022 and 2024 revisions* (11-jul-2024).
- UN DESA, Population Division (2026). *World Population Prospects 2024: Interim Update* (19-ene-2026): Togo; la próxima revisión se aplaza al 11-jul-2027.
- World Bank (2026). *FY27 Updated Country Income Classification for Analytical Purposes* (umbrales y cambios; Venezuela clasificada como lower-middle income). https://documents1.worldbank.org/curated/en/099063026190549947/pdf/BOSIB-8ff63426-3c40-412d-bad2-cc20a4ebea81.pdf · Blog: https://blogs.worldbank.org/en/opendata/who-moves-up-and-why--a-closer-look-at-the-new-world-bank-group-
- ICPD Programme of Action (1994), principio 8, citado en el WPP 2024 Summary (servicios de salud reproductiva *"without any form of coercion"*).
- Asamblea General de la ONU, resolución 92 (I) (1946) sobre el uso del emblema; decisión 72/550 (2018) sobre la denominación *1994 Genocide against the Tutsi in Rwanda*.
- Documentos del equipo: `docs/00_plan_analitico.md`, `docs/00_storyboard_diapositivas.md`, `docs/01_analisis_ganadores_2025.md`, `data/raw/README.md`.
