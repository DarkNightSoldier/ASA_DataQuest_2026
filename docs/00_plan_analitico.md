# 00 — Plan analítico · ASA DataQuest 2026 (UN WPP 2024)

> Documento maestro del agente **plan-design**. Fecha: 2026-10-22. Entrega del concurso: **viernes 30-oct-2026** (vídeo ≤ 5:00 + archivo de diapositivas con ≤ 4 de contenido + portada + referencias).
> Convención: notebook/código/comentarios en **español**; diapositivas, guion, títulos y etiquetas de gráficas en **inglés**.
> Todas las cifras de este plan son **provisionales** (pre-chequeo con pandas sobre el archivo Medium, o tomadas del EDA previo) y **deben re-verificarse en R** por el agente `notebook-R` antes de aparecer en cualquier diapositiva. La fuente única de verdad para las cifras será `figures/numbers.json`, generado por el notebook.

---

## 1. Tesis central y título

**Tesis (una frase):** ningún indicador cuenta por sí solo la historia de la población de un país; la historia útil para la ONU aparece cuando se leen juntas las tres "palancas" — nacimientos, defunciones y migración — y se mira *cómo se movieron durante 70 años*, porque la palanca que importa cambia con la etapa de la transición, la región y el nivel de ingreso.

**Gancho numérico (portada):** *"130 of 237 countries are below replacement fertility. 79 of them are still growing. 18 grow only because people move in. One number can't explain that."* (2023; verificar: 130 / 79 / 18 son del pre-chequeo).

**Título candidato (principal):**
> **One Number Can't Tell 8 Billion Stories**
> *Births, deaths and migration across 237 countries, 1950–2100 — and where the UN should look next*

Alternativas (por si el equipo prefiere otro tono):
- *Three Levers, Not One: What Births, Deaths and Migration Tell the UN About 237 Countries*
- *Same Road, Different Speed: Reading the Demographic Transition Lever by Lever*

**Callback de cierre:** repetir "One number can't tell 8 billion stories — but three, read region by region, can tell the UN where to look next."

---

## 2. Tres preguntas de investigación (en inglés, aparecen en pantalla como "Question 1/2/3")

| # | Pregunta (texto en pantalla) | Preguntas oficiales que cubre | Peso en vídeo |
|---|---|---|---|
| **Q1** | *Which lever is moving each country's population today — births, deaths or migration — and does the answer depend on region and income?* | **P7** (central) + **P4** (migración vs crecimiento) + parte de P1 (calendario regional) | ≈ 1:45 |
| **Q2** | *Can a single indicator tell the whole story, or does it only emerge when several are read together?* | **P8** (central) + **P5** (índice compuesto y decisiones a justificar) | ≈ 1:00 |
| **Q3** | *Do countries travel the same demographic road at different speeds — and which lever should the UN watch next in each group?* | **P6** (grupos por trayectorias) + **P1** (divergencia de la estructura por edades) + recomendaciones | ≈ 1:00 |

P2/P3 (OtherVariants) **no entran** en el vídeo; si sobra tiempo, el notebook añade un apéndice corto con el intervalo 80/95 % de la población 2100 para los países que aparecen en las recomendaciones (solo como nota de incertidumbre).

---

## 3. Datos y decisiones a justificar (todas quedan escritas en el notebook, sección "Decisiones de datos")

| Decisión | Elección | Justificación / cómo se documenta |
|---|---|---|
| Archivo base | `WPP2024_Demographic_Indicators_Medium_csv.gz` (leer comprimido, `fileEncoding="UTF-8-BOM"`, `na=""`) + suplemento `WPP2024_Supplement_Births_and_LE60.csv` (LE60) | La guía oficial dice que una buena entrega sale del Medium. El suplemento aporta LE60 (P1: longevidad en la vejez). Holy See no está en el suplemento. |
| Países vs agregados | **País ⇔ `ISO3_code` no vacío** (237, incluye Holy See y Taiwán). Todo lo demás (318 ubicaciones) es agregado y se usa **solo** para líneas regionales/por ingreso ya ponderadas por la ONU. | Evita doble conteo (guía §2). Control: la suma de `TPopulation1July` de los países por región SDG debe igualar la fila agregada (tolerancia 0,1 %) — test automático en el notebook. |
| Región | **8 regiones SDG** derivadas de `ParentID` (país → subregión → región SDG) con esta tabla: SSA = {910 Eastern, 911 Middle, 913 Southern, 914 Western Africa}; Northern Africa & Western Asia = {912, 922}; Central & Southern Asia = {5500, 5501}; Eastern & South-Eastern Asia = {906, 920}; LAC = {915, 916, 931}; Oceania (excl. AUS/NZ) = {928, 954, 957}; Australia/New Zealand = {927}; Europe & Northern America = {923, 924, 925, 926, **918**}. | Es la nomenclatura que usa la ONU (público objetivo). El `ParentID` 918 (Northern America) no existe como fila → se asigna a mano (hallazgo del profesor). Para gráficas muy densas se usa la versión de 6 "continentes" (región geográfica) como simplificación visual; se dice cuál se usa en cada figura. |
| Ingreso | `WB_income_groups.csv` (API Banco Mundial, descargado 2026-10-22 = clasificación **FY2026**, basada en GNI per cápita 2024), **aplicada a todos los años** (invariante en el tiempo). 21 territorios sin clasificar → grupo "Not classified", excluido de comparaciones por ingreso (único ≥ 1 M: Taiwán). | WPP trae los agregados de ingreso pero no la pertenencia. Limitación explícita: un país puede haber cambiado de grupo (p. ej. Corea, Chile) — se declara en limitaciones. Citar: World Bank Country and Lending Groups, FY2026. |
| Estimaciones vs proyecciones | **Estimaciones 1950–2023** = evidencia principal. **Proyecciones 2024–2100 (variante Medium)** solo para "qué viene", siempre en gris/punteado, con la línea vertical en 2023/2024 y la etiqueta "UN medium projection". | ASA B.2/C.2. La convergencia futura y la suavidad de la migración proyectada son supuestos de la ONU (EDA celda 122: la volatilidad proyectada es 14–34× menor). |
| Año 2101 | Se elimina (solo trae `TPopulation1Jan`). | Evita NA artificiales en correlaciones. |
| Microestados | Umbral **≥ 1 000 000 habitantes en 2023 (161 países)** para correlaciones, regresiones, PCA, índice y clustering. **Todos los 237** en mapas y conteos descriptivos, con los < 1 M marcados ("small states", puntos en una franja aparte del mapa). | Los microestados (37 con < 100 k) distorsionan correlaciones y rankings (EDA P5: Holy See/San Marino/Mónaco encabezan el índice). Sensibilidad: repetir correlaciones clave con los 237 y reportar ambos valores. |
| Ponderación | País = 1 unidad en distribuciones y modelos (las preguntas son "entre países"). Para niveles regionales se usan **los agregados de la ONU** (ponderados por población, sin doble conteo). Cuando mediana de países y agregado cuenten historias distintas (p. ej. China dentro de ingreso medio-alto) se muestran ambos. | ASA B.2 (describir cómo la variación entre grupos afecta resultados). |
| Migración volátil | `CNMR` se **winsoriza a ±3 DE** solo para PCA/clustering (documentado); en mapas y conteos va sin recortar. Para clasificar la "palanca" de 2023 se usa el **promedio 2021–2023** (suaviza COVID-19 y Ucrania 2022); sensibilidad con el año 2023 solo. | La migración es la serie más errática (ACF(1) de cambios = −0,11; EDA celda 122). |
| Identidad contable | `PopChange ≈ NatChange + NetMigrations` (comprobar residuo; es la ecuación de balance). Se usa como "modelo simple" de Q1 y como escalón intermedio en Q2. | Debe explicarse como **identidad**, no como hallazgo: el hallazgo es *qué parte domina en cada tipo de país*. |
| Semilla y versiones | `set.seed(2026)` global; `sessionInfo()` y `renv.lock` al final; `SETUP.md` con todo lo instalado. | Reproducibilidad (ASA B.4, F.4). |

Variables derivadas obligatorias (nombres de columna en español en el notebook, ej. `region_sdg`, `ingreso_bm`, `tipo_palanca`, `es_proyeccion`):
- `tipo_palanca` (clasificación de Webb simplificada, promedio 2021–2023):
  - **A "Growing: births > deaths, net inflow"** (NatChange > 0, NetMig > 0)
  - **B "Growing on births alone (net outflow)"** (NatChange > 0, NetMig < 0, PopChange > 0)
  - **C "Growing only thanks to migration"** (NatChange < 0, PopChange > 0)
  - **D "Shrinking: deaths > births"** (NatChange < 0, PopChange < 0)
  - **E "Shrinking by emigration (births > deaths)"** (NatChange > 0, PopChange < 0)
- `anio_q5_100`, `anio_tfr_4` (primer año con Q5 < 100 ‰ y TFR < 4; NA si ya estaba por debajo en 1950 → "censurado"), y `rezago = anio_tfr_4 − anio_q5_100`.
- `part_migracion` = NetMigrations / PopChange por periodo (solo cuando |PopChange| supera un mínimo; si no, se muestran componentes absolutos).

---

## 4. Diseño analítico por pregunta

Regla de oro: **cada método debe explicarse en una frase** en la narración. El "modelo rico" nunca sustituye al simple en pantalla: el simple se muestra, el rico se resume en una cifra y vive en el notebook.

### Q1 — ¿Qué palanca mueve a cada país y cómo cambia por región e ingreso? (P7 + P4)

| Capa | Datos / filtro | Método | Salida esperada | Frase de interpretación | Validación |
|---|---|---|---|---|---|
| **Simple 1: descomposición del crecimiento** | 237 países, sumas por grupo de ingreso (y por región SDG) en periodos 1950–59 … 2010–23 y acumulado 2000–2023; variables `NatChange`, `NetMigrations`, `PopChange` | Aritmética de la identidad de balance; participación de la migración = NetMig/PopChange | Barras apiladas (natural vs migración) por ingreso y década, **animadas**; tabla de participaciones | "In high-income countries, since 2000, 71 % of growth came from migration; in the rest, migration is a small outflow." | Residuo de la identidad < 0,5 %; comparar suma de países vs agregado ONU por ingreso. |
| **Simple 2: mapa de palancas 2023** | 237 países, `tipo_palanca` (promedio 2021–2023) | Clasificación de Webb simplificada (5 tipos, 4 colores + gris) | Mapa mundial coloreado + franja de pequeños Estados + zoom a Europa y al Golfo; conteos por tipo | "18 countries grow only because people move in; 19 shrink although births exceed deaths." | Sensibilidad 2023 solo vs 2021–23 (reportar ambos conteos); listar países de cada tipo en el notebook. |
| **Rico 1: calendario de la transición (rezago mortalidad → fecundidad)** | ≥ 1 M, estimaciones 1950–2023; `Q5`, `TFR`; solo países con ambos cruces observados después de 1950 (≈ 89); reportar censurados | Primer año con Q5 < 100 ‰ vs primer año con TFR < 4; rezago mediano por región; gráfico de "event time" (alinear cada país en el año del cruce de TFR y mostrar Q5 y CNMR en años relativos −30…+30) | Dumbbell ordenado por región + curvas alineadas; mediana del rezago (pre-chequeo: **11 años**, mortalidad primero en **80 %**; África 12, Asia 11, LAC 8) | "Child mortality falls first; fertility follows about a decade later — a descriptive pattern, not a causal proof." | Repetir con umbrales Q5 < 50 / TFR < 3 (pre-chequeo: rezago 2 años, 58 %) y reportar la sensibilidad; declarar censura. |
| **Rico 2: acoplamiento en el tiempo por ingreso** | ≥ 1 M, 1950–2100 (marcando 2023); `TFR`, `IMR`, `CNMR`, `LEx`, `CDR` | Correlación de Spearman entre países año a año, global y por grupo de ingreso (idea del profesor, presentada como cinta/heatmap) | Heatmap "coupling" (filas: par de indicadores × grupo; columnas: año) | "Fertility and mortality move together everywhere; migration couples with fertility only in high-income countries, and the link is projected to strengthen." | Bootstrap de países (B = 500, semilla) para bandas del 95 % en años clave 1950/2000/2023. |
| **Rico 3: β-convergencia 1950–2023 con interacción por ingreso** | ≥ 1 M; ΔX = X₂₀₂₃ − X₁₉₅₀ vs X₁₉₅₀ para TFR, IMR, CNMR, MedianAgePop, LE60 | `lm(delta ~ x0 * ingreso)`; ANOVA de la interacción (profesor) | Tabla β₁ por variable y grupo; nube de puntos con rectas por ingreso | "Countries that started with the highest fertility reduced it the most (β ≈ −0.6); migration shows no persistence at all (β ≈ −1)." | Avisar de regresión a la media (Galton); robustez con regresión robusta (`MASS::rlm`) y sin Golfo. |
| **Opcional (si hay tiempo): panel con efectos fijos** | ≥ 1 M, 1960–2023 | `fixest::feols(TFR ~ l(Q5,10) + CNMR | pais + anio, split = ingreso)` | Coeficientes por ingreso con EE agrupados por país | "Within a country, a fall in child mortality ten years earlier goes with lower fertility today." | Solo descriptivo; no se reclama causalidad. |

### Q2 — ¿Un solo indicador cuenta toda la historia? (P8 + P5)

| Capa | Datos / filtro | Método | Salida esperada | Frase de interpretación | Validación |
|---|---|---|---|---|---|
| **Simple 1: scorecard "qué explica un solo indicador"** | 2023, ≥ 1 M (161); regresiones simples de 4 resultados sobre `TFR` sola: (a) `MedianAgePop` 2023, (b) cambio % de población 2023→2050 (proyección Medium), (c) `PopGrowthRate` 2023, (d) `CNMR` 2023 | Cuatro regresiones lineales (R² ajustado); como apoyo, la escalera anidada `PopGrowthRate ~ TFR → +CDR → +CNMR` | Cuatro barras que crecen (animación): pre-chequeo **0.77 / 0.88 / 0.59 / ≈ 0.06**; escalera de apoyo 0.59 → 0.70 → 0.99 **solo en nota al pie** (es la identidad contable, un jurado la vería como trivial) | "One number tells the slow story — age structure and the 2050 outlook — but not today's growth and not migration: the levers that move fastest." | Repetir con 237 países; validación cruzada 10-fold (semilla); advertir que (b) es sobre una proyección construida con supuestos de fecundidad ("partly by construction"); reportar también `LEx` y `MedianAgePop` como "single indicator" alternativos (tabla en el notebook). |
| **Simple 2: gemelos demográficos** | 2023, pares de países con el mismo valor de un indicador y destinos opuestos | Búsqueda automática de pares con |ΔTFR| < 0,05 y máxima diferencia en crecimiento (y |ΔLEx| < 0,2 con máxima diferencia en edad mediana) | Tarjetas con bandera: **UAE vs Belarus** (TFR 1.20/1.21; +3.70 % vs −0.65 %); **Jordan vs Bosnia** (LEx 77.8/77.9; median age 24.3 vs 44.9); **Israel vs Portugal** (LEx 82.4; 29.1 vs 46.2) | "Same number, opposite stories." | Confirmar valores en R; elegir pares con ≥ 1 M. |
| **Simple 3: el mismo indicador cambia de significado** | 1950–2100, ≥ 1 M; `CDR` vs `LEx` | Correlación anual | Línea: ρ(CDR, LEx) de **−0.96 (1950) → +0.06 (2023) → +0.46 (2060)** | "By 2023 the crude death rate no longer measures mortality — it measures ageing." | Bootstrap de bandas; mostrar también CBR–CDR (+0.69 → −0.80). |
| **Rico 1: PCA** | 2023, ≥ 1 M; **conjunto fijo de 12 indicadores** (`R/config.R: vars_pca`), elegido para cubrir los 4 bloques del diccionario y las dimensiones de composición: fecundidad = TFR, CBR; mortalidad = LEx, LE65, Q5, Q1560, CDR; estructura/crecimiento = MedianAgePop, PopGrowthRate; migración = CNMR (winsorizada); composición = PopSexRatio; densidad = log(PopDensity). Justificación: P8 pregunta si *un* eje resume *todo*; si solo se meten indicadores del núcleo de la transición (p. ej. los 8 del catálogo de visualización, PC1 = 64 %) el PC1 queda inflado por construcción. | PCA sobre variables estandarizadas (`prcomp`, `scale.=TRUE`) | Biplot animado (aparece PC1, luego PC2 con Golfo e islas); scree. Esperado con los 12: **PC1 ≈ 46 %** (EDA), **3 PCs para > 70 %**, PC2 = migración/razón de sexos. **La cifra narrada sale de `numbers.json` (`pc1_var`), nunca de este plan.** Sensibilidad obligatoria: repetir con el conjunto de 8 del catálogo y reportar ambos PC1 (es en sí un argumento de P8: "el peso del eje único depende de qué se mete"). | "One axis orders countries along the transition — but it captures less than half; migration is a dimension of its own." | Kaiser (autovalores > 1), bootstrap de cargas (B = 500), repetir sin Golfo y con 237 países; `cor` entre PC1 y TFR. |
| **Rico 2: índice compuesto y su fragilidad (P5)** | 2023, ≥ 1 M; 5 indicadores orientados (TFR−, Q5−, LEx+, MedianAge+, [PopGrowthRate−]) | 7 variantes: pesos iguales z-score (base), PC1, min–max, media geométrica, sin crecimiento, con migración (signo + y −), referencia temporal 1950–2100 | Bump chart de rangos; cifras: ρ entre versiones ≥ 0.957 pero **24 % de países se mueve > 20 puestos**; caso extremo Saint Martin 4.º → 136.º (microestado: usar un caso ≥ 1 M como principal) | "A composite index is coherent (α = 0.93) but its design moves one in four countries by more than twenty ranks — the choices must be declared." | α de Cronbach; tabla de decisiones (selección, dirección, normalización, agregación, referencia temporal). Nota ética: no es un índice de bienestar. |
| **Rico 3: información perdida por un solo indicador** | 2023, ≥ 1 M | Para cada indicador candidato (TFR, LEx, MedianAge, PC1): ρ² media de Spearman con los otros 11 | Barra: PC1 0.48, TFR ≈ 0.4x, … ; con migración ρ² ≤ 0.14, razón de sexos ≤ 0.11 | "The best single summary still leaves out more than half of what the other indicators know." | Repetir en 1990 y 2050 (proyección) para mostrar inestabilidad. |

### Q3 — ¿Mismo camino, distinta velocidad? ¿Qué palanca vigilar en cada grupo? (P6 + P1 + recomendaciones)

| Capa | Datos / filtro | Método | Salida esperada | Frase de interpretación | Validación |
|---|---|---|---|---|---|
| **Simple 1: trayectorias conjuntas** | Agregados ONU por región SDG (8) 1950–2023 (+ 2024–2100 en gris); `TFR` vs `Q5` (o `LEx`) | Dispersión conectada (connected scatter) animada por año | "Camino" de cada región con años marcados cada 10; velocidad: años en bajar TFR de 5 a 2,5 (Europa > 100 años, Asia/LAC ≈ 50, SSA en curso) | "Everyone travels the same road, towards the bottom-left corner — Europe took a century, Asia fifty years, Africa is on the road now." | Marcar hambruna china 1959–62 y VIH en África austral como choques (anotaciones históricas). |
| **Simple 2: fan chart de divergencia (P1)** | 237 → ≥ 1 M; `MedianAgePop`, `LEx`, `LE60` (suplemento) 1950–2100 | Percentiles P10/P25/P50/P75/P90 entre países por año (versión clara del "fan chart" del profesor) + DE anual (σ-convergencia) con regresión σₜ ~ t en 1950–2023 | Banda animada que se abre (edad mediana: DE **5.0 → 9.8** años, máx. proyectado 10.2 en 2037) y otra que se cierra (LEx: DE 11.7 → 7.0) mientras LE60 se abre (DE 1.8 → 3.2 → 4.6) | "Countries converged in life expectancy at birth but diverged in age structure and in old-age longevity: the new inequality is in old age." | Repetir con todos los países; mostrar que la convergencia post-2037 es supuesto de la ONU. |
| **Rico 1: clustering de trayectorias (P6)** | ≥ 1 M (161), estimaciones 1950–2023; 4 variables: TFR, LEx, MedianAgePop, CNMR (winsorizada); cada una z-estandarizada en el panel; resumen por **medias de década (8 décadas × 4 = 32 rasgos)** | k-means (`nstart = 50`, semilla 2026), k por silueta (esperado k = 4); alternativa de robustez: Ward jerárquico y DTW (`dtwclust`) sobre las curvas anuales; **funcional** (`fda`, B-splines + FPCA) como apéndice | Mapa de 4 tipos + pequeños múltiplos de trayectorias por tipo + tabla de miembros. Esperado (EDA, **provisional — la composición y los nombres son salida del análisis, no se predefinen**): **Early movers** (≈ 43; Europa, Japón, EE. UU.), **Fast movers** (≈ 46; China, Brasil, Irán, Türkiye), **Late movers** (≈ 62; 42 africanos, India, Pakistán) y un cuarto grupo pequeño (≈ 10) que en el EDA mezclaba el Golfo con las dos Coreas, Jordania y Yibuti: lo definía la **velocidad** del cambio (TFR 7 → 1.8, LEx 40 → 80), no la migración (Corea del Norte no recibe inmigrantes). Regla de nombres: el notebook calcula por grupo el año mediano en que TFR < 4, la velocidad (años de TFR 5 → 2.5) y la CNMR mediana 2000–23, y asigna el nombre por una tabla de reglas (`R/config.R: reglas_nombres`): si CNMR mediana > 10 ‰ → "Migration-boosted"; si no y la velocidad es la mayor → "Sprinters"; etc. Ejemplos por grupo = los 3 más poblados (`numbers.json: cluster_examples`). | "Looking at seventy years of movement, countries fall into four roads — and the road matters more than today's position." | Silueta (esperada ≤ 0.25 → decir "continuo, no cajas"); estabilidad bootstrap (`fpc::clusterboot`, Jaccard ≥ 0.6 por grupo); ARI entre k-means y Ward; ARI vs clustering por niveles de 2023 (EDA: 0.42); repetir sin CNMR para ver si el Golfo se separa solo por migración. |
| **Rico 2: "qué palanca, dónde, cuándo"** | Para cada tipo de trayectoria: proyección Medium 2024–2050: participación natural vs migratoria del `PopChange`, edad mediana 2050, año de pico de población (`TPopulation1July` máx.), LE60 2050 | Tablas por grupo (sumas de países; ponderado y no ponderado) | Tabla de recomendaciones con icono por agencia (UNFPA, UN DESA, IOM, WHO) y horizonte (2030/2040/2050) | "This gives the UN a watch-list: child survival in late movers before 2040; pension and health systems in fast movers within twenty years; migration governance and healthy longevity in early movers." | Todo marcado "UN medium projection"; indicar que las recomendaciones son *dónde mirar*, no causalidad; citar mandatos existentes (ICPD, SDG 3) sin proponer metas de fecundidad. |

---

## 5. Hipótesis concretas a verificar (con filtro exacto y valor ancla provisional)

| ID | Hipótesis (se enuncia en el notebook antes de calcular; resultado se reporta aunque falle) | Indicador y filtro | Ancla provisional | Fuente ancla |
|---|---|---|---|---|
| H1 | En países de ingreso alto, el crecimiento 2000–2023 lo explica la migración, no el saldo natural. | Σ(NetMigrations)/Σ(PopChange), países WB "High income", 2000–2023 (y 2010–2023) | **71 %** (78 % en 2010–23); ingreso bajo −4 %, medio-bajo −9 %, medio-alto −5 % | pandas 2026-10-22 |
| H2 | Europa crece solo por migración desde los 90; el saldo natural es negativo. | Σ por región geográfica Europa 2000–2023; NatChange del agregado "Europe" negativo desde 1993 | migración = **207 %** del crecimiento 2000–23; Norteamérica 55 %; Oceanía 35 % | pandas; EDA c.68/76 |
| H3 | La mortalidad infantil cruza su umbral ~una década antes que la fecundidad. | Año(Q5 < 100) vs año(TFR < 4), ≥ 1 M, ambos cruces > 1950 | n = 89, mediana **11 años**, mortalidad primero en **80 %** | pandas |
| H4 | La migración no es persistente; la fecundidad y la mortalidad sí. | β₁ de ΔX₁₉₅₀₋₂₀₂₃ ~ X₁₉₅₀ | CNMR β ≈ **−0.96**; TFR −0.64 (R² 0.51); IMR −0.84 (R² 0.93); MedianAge +0.09 n.s. | Test.Rmd (profesor), todos los países |
| H5 | Fecundidad y migración solo se acoplan en ingreso alto. | ρ(TFR, CNMR) 2023 por grupo de ingreso | alto **−0.36**; global −0.13 (−0.39 en 2100 proyectado) | Test.Rmd |
| H6 | La TFR sola explica bien la "historia lenta" (edad mediana, cambio 2023→2050) pero mal la rápida (crecimiento actual) y nada de la migración. | R² ajustado de MedianAgePop / Δ% pob. 2023→2050 / PopGrowthRate / CNMR sobre TFR, 2023, ≥ 1 M; apoyo: PopGrowthRate ~ TFR → +CDR → +CNMR | **0.77 / 0.88 / 0.59 / ≈ 0.06**; apoyo 0.59 / 0.70 / 0.99 (identidad) | pandas 2026-10-22 |
| H7 | PC1 captura < 50 % y hacen falta 3 componentes para 70 %. | PCA 12–13 indicadores, 2023, ≥ 1 M | PC1 **46 %**, 3 PCs > 70 %, PC2 16 % = migración/razón de sexos | EDA c.85 |
| H8 | El diseño del índice mueve a 1 de cada 4 países más de 20 puestos. | 7 variantes del índice, 2023 | ρ ≥ 0.957; **24 %** > 20 puestos; mediana 11 puestos | EDA c.92 |
| H9 | Existen 4 tipos de trayectoria pero con separación débil. | k-means sobre 32 rasgos, ≥ 1 M | silueta ≤ **0.23**; ARI vs niveles 0.42 | EDA c.100 |
| H10 | La edad mediana divergió 1950–2023 (DE se duplica) y solo converge por supuesto de proyección. | DE entre países de MedianAgePop por año | **5.0 → 9.8** (máx. 10.2 en 2037 → 7.6 en 2100) | EDA c.59 |
| H11 | LEx converge pero LE60 diverge. | DE de LEx y LE60 (suplemento) por año | LEx 11.7 → 7.0; LE60 **1.8 → 3.2** (4.6 en 2100) | EDA c.59 |
| H12 | La inercia demográfica mantiene creciendo a la mayoría de los países bajo reemplazo. | TFR < 2.1 & NatChange > 0, 2023 | **79 de 130** | pandas |
| H13 | La CDR dejó de medir mortalidad. | ρ(CDR, LEx) por año | −0.96 (1950) → **+0.06** (2023) → +0.46 (2060) | EDA c.85 |
| H14 | Europa ya tiene más muertes que nacimientos desde 1993; Norteamérica cruzaría en 2040 y Asia/LAC en 2055. | NatChange del agregado por región, primer año < 0 | 1993 / 2040 / 2055 | EDA c.76 |

---

## 6. Hallazgos sorprendentes candidatos (la implementación debe comprobarlos; si alguno no se sostiene, se elimina del guion)

| # | Hallazgo candidato | Indicador y filtro exacto | Uso previsto |
|---|---|---|---|
| S1 | 18 países crecen **solo** por inmigración (saldo natural negativo): DEU, ESP, BEL, FIN, HUN, SVK, SVN, EST, LTU, GEO, PRI + microestados. 11 de ellos ≥ 1 M. | NatChange < 0 & PopChange > 0, 2023 (y promedio 2021–23) | Mapa Q1, narración gancho |
| S2 | 19 países **decrecen aunque nacen más de los que mueren** (emigración): ALB, AZE, MUS, NPL, URY, XKX (≥ 1 M) + islas del Pacífico. | NatChange > 0 & PopChange < 0 | Mapa Q1 |
| S3 | South Sudan (+39.6 ‰), Syria (+32.1 ‰) y Armenia (+25.5 ‰) tienen las tasas de inmigración neta más altas de 2023 — retornos tras conflicto, no "atracción". | CNMR 2023, top 8 | Anotación ética: la migración positiva no es "éxito" |
| S4 | Qatar y EAU recibieron migrantes equivalentes al 76–77 % de su población actual (1950–2023); Bangladés es el mayor emisor neto acumulado (≈ −31 M). | Σ NetMigrations 1950–2023 / TPopulation 2023 | Zoom Golfo (Q1) |
| S5 | La relación CDR–LEx cambia de signo (−0.96 → +0.06): hoy una tasa bruta de mortalidad alta señala un país **viejo**, no uno con mala salud. | ρ anual, ≥ 1 M | Q2 "el mismo número cambia de significado" |
| S6 | EAU y Bielorrusia: misma fecundidad (1.20 vs 1.21), uno crece +3.70 %/año y el otro decrece −0.65 %. | TFR, PopGrowthRate, CNMR 2023 | Q2 gemelos |
| S7 | Jordania y Bosnia: misma esperanza de vida (77.8/77.9) y edades medianas de 24 y 45 años. | LEx, MedianAgePop 2023 | Q2 gemelos |
| S8 | Asia Oriental pasa de edad mediana 22 (1950) a 38 (2020) y **60 en 2100**; LAC superaría a Europa como región más vieja (≈ 49) en 2100. | MedianAgePop agregados subregión/región, proyección | Q3 "fast movers" |
| S9 | 44 de 58 países africanos no alcanzarían edad mediana 40 antes de 2100; la mitad de Europa ya tenía ≥ 30 antes de 1967. | Primer año con MedianAgePop ≥ 30/40 | Q3 "late movers" |
| S10 | El mundo alcanza su pico de población en **2084 (10.29 mil millones)**; 60 países ya pasaron su pico antes de 2024, 51 lo harán 2024–2054 y 126 después de 2055. | TPopulation1July máx por país | Portada/cierre o Q3 |
| S11 | El grupo de ingreso medio-alto (China) tendría en 2050 una edad mediana **mayor** que el de ingreso alto (44.8 vs 44.5). | Agregados ONU por ingreso, 2050 | Q3 recomendación "fast movers" |
| S12 | La mortalidad infantil y la fecundidad convergen, la edad mediana no (en datos observados). | β-convergencia 1950–2023 | Q3 / P1 |
| S13 | Las proyecciones no contienen choques: DE de cambios anuales 14–34× menor que en estimaciones. | DE de ΔLEx, ΔCNMR, ΔTFR, 1950–2023 vs 2024–2100 | Ética / limitaciones |
| S14 | COVID-19: 161 países perdieron esperanza de vida en 2020 y 168 en 2021 (vs ≈ 15–35 en un año típico). | ΔLEx < 0 por año | Anotación histórica en trayectorias |

Anotaciones históricas para las animaciones (verificar fechas en `docs/02_contexto_historico.md` cuando exista): hambruna china 1959–62 (TFR/LEx de China/Asia); baby boom 1946–64 (EE. UU./Europa); VIH/sida 1987–2005 (Esuatini, Lesoto, Zimbabue, Botsuana: −10 a −16 años de LEx); éxodo de Kuwait 1990–91; Ruanda 1994; colapso de la URSS 1990–94 (sobremortalidad masculina); Siria 2012–16, Venezuela 2015–19, Ucrania 2022 (−5.7 M); COVID-19 2020–21; política del hijo único 1980–2015; Golfo: boom petrolero 1970s y 2000s.

---

## 7. Recomendaciones candidatas para la ONU (se redactan como "dónde mirar / qué vigilar", nunca como relaciones causales ni metas de fecundidad)

| Tipo de país (resultado de Q3) | Evidencia que lo sostiene (Q1–Q3) | Palanca a vigilar | Agencia / horizonte |
|---|---|---|---|
| **Late movers** (≈ 60; SSA, Pakistán, Afganistán…; ≈ 3.3 mil M) | Q5 mediana alta; TFR 3.8 (2023); crecimiento 100 % natural; rezago mortalidad→fecundidad ≈ 11 años; 44/58 africanos no llegan a edad mediana 40 en 2100 | Supervivencia infantil y acceso a salud reproductiva basado en derechos (ICPD); planificar cohortes escolares y laborales 2035–2050 (ventana de dividendo demográfico) | UNFPA, UNICEF, UN DESA · 2030–2050 |
| **Fast movers** (≈ 46; China, Brasil, Irán, Türkiye, Viet Nam…; ≈ 3.3 mil M) | TFR 6.4 → 1.8 en 70 años; edad mediana 18 → 30 → ≈ 45 (2050); ingreso medio-alto más viejo que el alto en 2050; CDR sube por envejecimiento | Sistemas de pensiones y salud para mayores en ~20 años (lo que Europa hizo en 80); medir mortalidad con LEx/Q, no con CDR | UN DESA, WHO (healthy ageing), ILO · 2030–2045 |
| **Early movers** (≈ 43; Europa, Japón, Norteamérica, Australia) | Saldo natural negativo (Europa desde 1993); crecimiento 2000–23 = 207 % migración; 18 países crecen solo por inmigración; LE60 diverge (DE 1.8 → 3.2) | Gobernanza e integración migratoria como palanca demográfica; longevidad saludable y desigualdad en la vejez | IOM, UN DESA, WHO · ahora–2040 |
| **Grupo 4 — nombre según el análisis** (≈ 10; provisional Golfo + Corea del Sur + Jordania…) | Variante (i) *Migration-boosted* si lo define la migración: CNMR ≈ +28 ‰ (EAU); migración acumulada = 76 % de la población; β ≈ −1 (sin persistencia); PC2 = eje migración/razón de sexos. Variante (ii) *Sprinters* si lo define la velocidad: el cambio más rápido del panel (TFR 7 → 1.8 en < 40 años) | (i) Derechos y datos de migrantes; planes contingentes ante reversión de flujos. (ii) Envejecimiento más rápido registrado: sistemas de pensiones/salud antes que nadie; vigilar la migración solo donde domina (Golfo) | (i) IOM, ILO · permanente · (ii) UN DESA, WHO · 2035 |
| **Transversal (UN DESA, datos)** | CDR cambia de significado; proyecciones sin choques; índices sensibles al diseño (24 % > 20 puestos) | Publicar intervalos y análisis de sensibilidad con cualquier ranking; no usar CDR para comparar salud; comunicar que la convergencia post-2037 es supuesto | UN DESA Population Division |

---

## 8. Checklist ético ASA (2022) aplicado a cada entregable

| Principio ASA | Notebook R | Figuras/animaciones | Diapositivas + vídeo | Repositorio |
|---|---|---|---|---|
| **A.** Integridad profesional (métodos válidos, sin selección de resultados) | Hipótesis H1–H14 declaradas **antes** de calcular; se reportan las que fallan; sección "Lo que no encontramos" | No se recortan ejes para exagerar; y-axis desde 0 en barras; escalas log declaradas | Ninguna cifra sin su fuente en `numbers.json`; "we expected X; we found Y" si aplica | Historial de commits (no reescribir) |
| **B.** Integridad de datos y métodos (fuentes, supuestos, limitaciones, reproducibilidad) | Celda inicial con cita y licencia **CC BY 3.0 IGO**; tabla de decisiones (§3); `set.seed(2026)`, `sessionInfo()`, `renv.lock`; residuo de la identidad; tests de doble conteo | Cada figura: subtítulo con filtro (p. ej. "161 countries ≥ 1 M, 2023"), nota "Source: UN WPP 2024 (CC BY 3.0 IGO); estimates ≤ 2023, UN medium projection ≥ 2024"; línea vertical 2023/24 en toda serie que cruce | Pie de página permanente con fuente y la leyenda estimación/proyección; diapositiva de referencias con UN DESA, Banco Mundial, ASA, paquetes R, Natural Earth/maps | `README` con cómo reproducir en 1 comando; `SETUP.md`; datos grandes fuera del repo con enlace oficial y hash |
| **C.** Responsabilidad con partes interesadas (no inducir a error; separar exploratorio de confirmatorio) | Todo etiquetado **"descriptivo/exploratorio"**; sin valores p "decorativos"; múltiples comparaciones declaradas | Colores accesibles (paleta Okabe-Ito / viridis), sin rojo-verde puro; etiquetas directas en vez de leyendas cuando se pueda | Lenguaje: "is associated with", "goes with", "follows" — **nunca** "causes/drives"; la migración no se califica de buena/mala; los grupos se llaman por su comportamiento ("late movers"), no por juicio | Issues abiertos con limitaciones conocidas |
| **D.** Sujetos y poblaciones afectadas | Datos agregados nacionales (sin riesgo de reidentificación); crisis (Ruanda, Siria, Ucrania, RCA) reportadas con respeto y como publica la ONU | Sin iconografía estigmatizante; banderas solo como identificador | Explicitar que los tipos **no** son rankings de desarrollo ni bienestar; recomendaciones basadas en derechos (ICPD) | — |
| **E/F.** Equipo y profesión | Comentarios en español para todo el equipo; crédito al EDA previo y al código del profesor (fan chart, β/σ) | Crédito a paquetes (citas) | Nombres del equipo y roles; crédito a datos y a la ASA | Licencia del código (MIT) y de los textos (CC BY 4.0) |

Limitaciones que **siempre** se mencionan (en notebook §final, en la última construcción de la diapositiva 4 y en el guion): (1) estimaciones ≤ 2023 son modelizadas, de calidad desigual entre países; (2) proyecciones = un escenario (Medium) con supuestos de convergencia y migración suave; (3) ingreso del Banco Mundial actual aplicado a todo el periodo; (4) umbral de 1 M y winsorización de la migración; (5) la β-convergencia sufre regresión a la media; (6) clustering con silueta baja = tipología útil pero no "grupos naturales"; (7) relaciones descriptivas, sin causalidad.

---

## 9. Criterios de éxito y riesgos

**Criterios de éxito (definición global de "terminado"):**
1. En vídeo y diapositivas aparece literalmente "Question 1/2/3" y cada una recibe una respuesta de una frase con número; **P7 y P8 se responden explícitamente** (Q1 y Q2) y P1, P4, P5, P6 quedan cubiertas (tabla de trazabilidad en `docs/`).
2. Vídeo ≤ 5:00 con subtítulos legibles; PDF de diapositivas con exactamente 6 páginas (portada, 4 contenido, referencias).
3. Toda cifra en pantalla proviene de `figures/numbers.json` generado por el notebook (QA-stats verifica 100 %).
4. Cada figura tiene: pregunta a la que responde, mensaje de una línea, fuente/licencia, marca estimación/proyección, y fue "fotografiada" y revisada a 1920×1080 y al 50 %.
5. Al menos 4 hallazgos de §6 confirmados y al menos un hallazgo que **sorprenda** a un demógrafo no especialista (candidatos: S1/S2, S5, S6, S11).
6. Notebook se ejecuta de principio a fin (`make notebook`) en < 15 min en la máquina del equipo; `renv.lock` y `SETUP.md` actualizados.
7. Recomendaciones por tipo de país con agencia y horizonte, redactadas sin causalidad.

**Riesgos y mitigaciones:**

| Riesgo | Prob. | Mitigación |
|---|---|---|
| Tiempo: quedan 8 días (22 → 30 oct) | Alta | Orden estricto del plan de implementación; congelar cifras (numbers.json v1) el día 3; animaciones "nice-to-have" solo tras tener la versión estática de cada figura. |
| Paquetes R que requieren libs de sistema no disponibles (`sf`, `rnaturalearth`, `gifski`, `magick`, `av`, `transformr`) — no hay GDAL/GEOS/Rust/ImageMagick-dev/libav y no hay sudo | Alta | Mapas con `maps::map_data("world")` + `countrycode` (R puro); animación por **fotogramas PNG (ragg) → ffmpeg estático** (`imageio-ffmpeg` en un venv); `tweenr` para interpolar; `gganimate` solo con `transition_reveal/time` en puntos y líneas. |
| Animaciones pesadas en reveal.js | Media | MP4 H.264 1920×1080 ≤ 8 MB cada uno, ≤ 6 vídeos; `preload`; versión estática PNG de respaldo en cada diapositiva. |
| El límite de 4 diapositivas vs muchas "capas" | Media | Builds con `fragment`; `pdfSeparateFragments: false` para que el PDF tenga 6 páginas; QA-slides cuenta páginas. |
| Guion de > 5 min | Media | 130–145 palabras/min ⇒ ≤ 720 palabras; cronometrar cada sección en lectura en voz alta; recortar primero las anécdotas, nunca las respuestas a Q1–Q3. |
| Clustering inestable (silueta baja) | Alta (esperado) | Es un hallazgo, no un fallo: reportar silueta y bootstrap; usar nombres por comportamiento; mostrar también la versión jerárquica. |
| Cifras del EDA que no se repliquen | Media | Nada pasa al guion sin `numbers.json`; el storyboard usa marcadores `{clave}` resueltos por QA-stats. |
| Lenguaje técnico | Media | Regla: cada término técnico (PCA, cluster, R², convergence) tiene una frase de explicación en pantalla o en voz; QA-slides revisa con la "prueba del familiar no estadístico". |

---

## 10. Cantera de cifras reutilizables del EDA previo (`EDA_WPP2024_DataQuest_R.ipynb`), con celda de origen — **todas a re-verificar**

- **P1 (c.59):** DE de edad mediana 5.0 (1950) → 9.8 (2023) → máx 10.2 (2037) → 7.6 (2100); P90–P10 12.2 → 25.8; brecha África–Europa 10.7 → 23.2 → 14.0; Asia Oriental 22 → 38 → 60; DE LEx 11.7 → 7.0; DE LE60 1.8 → 3.2 → 4.6; LE60 mediana 14.3 → 20.4 → 28.2; 44/58 africanos < 40 años de edad mediana antes de 2100; ρ(edad mediana, LE65) 0.63 → 0.79.
- **P4 (c.68):** Europa 2010s: aporte migratorio 117 % del crecimiento; Norteamérica 5 % (1950s) → 60 % (2010s) → > 100 % hacia 2040; Spearman migración–crecimiento 2000–23: Europa 0.94, Norteamérica 0.90, Oceanía 0.84, África 0.57; Webb 2023: 183 crecen / 54 decrecen; 18 tipo D, 26 E/F, 28 G/H; 2100: 161 de 237 decrecerían (156 por saldo natural); EE. UU. ≈ +65 M acumulados; Qatar/EAU 76–77 %; Kosovo…Puerto Rico −46 a −64 %; Ucrania 2022 −5.7 M.
- **P7 (c.76):** Europa muertes > nacimientos desde 1993; Norteamérica 2040, Asia y LAC 2055; CDR Asia mín 6.7 ‰ (2014) → 13.6 ‰ (2100); mortalidad primero en 97 % África, 95 % LAC, 94 % Oceanía, 73 % Asia (135 países), rezagos medianos 11–13 años (26 Oceanía); TFR ingreso bajo 4.53 vs 1.47–1.48 alto/medio-alto; ingreso alto CNMR +3.97 ‰ (2023), 72 % del crecimiento 2010–23 migratorio; 2050 medio-alto edad mediana 44.8 vs alto 44.5; 79 de 130 países < 2.1 con saldo natural positivo; 18 crecen solo por inmigración; 8 con TFR ≥ 2.1 decrecen por emigración.
- **P8 (c.85):** PC1 46 % (cargas LEx 0.39, edad mediana 0.38, Q1560 −0.37, LE65 0.36, TFR −0.36, Q5 −0.36); 3 PCs > 70 %; PC2 16 % migración/crecimiento/razón de sexos; PC3 9.5 %; densidad PC4 (0.88); ρ² con migración ≤ 0.14, razón de sexos ≤ 0.11, densidad ≤ 0.10; PC1 ρ² media 0.48; CDR–LEx −0.96 → +0.06 → +0.46; CBR–CDR +0.69 → −0.80; gemelos EAU/Bielorrusia, Jordania/Bosnia, Israel/Portugal.
- **P5 (c.92):** α = 0.93; pesos PC1 ≈ 0.21; ρ entre versiones 0.957–0.999; amplitud mediana 11 puestos; 10 % > 34; 24 % > 20; Saint Martin 4.º → 136.º; África mediana del índice −1.93 → −0.58 → 0.43; extremos robustos Chad, Somalia, Níger, RCA, Mali.
- **P6 (c.100):** silueta ≤ 0.23; k = 4; T4 43 países/1 363 M; T3 46/3 306 M; T2 62/3 256 M; T1 10; ARI 0.42.
- **Series (c.122):** eco generacional 25–30 años; choques Japón 1966 (−19 % nacimientos), China 1961 (−29 %), Ruanda 1994 (−24 años LEx vs tendencia); COVID 161/168 países; VIH Esuatini −16.1 años; 60 países ya en pico antes de 2024, 102 entre 2024–2099, 75 crecen en 2100 (nota: el pre-chequeo pandas da 60 / 51 (2024–54) / 126 (≥ 2055) con otra partición).
- **Decisiones ya documentadas (c.142):** `na = ""` (Namibia), excluir 2101, `ParentID` 918, `DoublingTime` no imputado, `SRB` en vez de razón del suplemento, Holy See ausente del suplemento, recorte ±3 DE de migración.

---

## 11. Pendiente de integrar asesorías (`docs/06_asesoria_*.md`)

Al cerrar este plan (2026-10-22) **no existía ningún memo `06_asesoria_*.md`** (series de tiempo, multivariado, datos funcionales, estadística social); sí existen `01_analisis_ganadores_2025.md`, `02_contexto_historico.md` y `05_catalogo_visualizacion.md`, ya incorporados (anotaciones históricas con fuente, receta de ganadores, gráficas probadas y estado real de paquetes). Instrucciones para el agente que integre los memos cuando aparezcan (tarea `integrate-advice` del plan de implementación):

1. Leer cada `06_asesoria_*.md` completo y extraer **solo** cambios que (a) mejoren la respuesta a Q1–Q3 con un método explicable en una frase, o (b) corrijan un error de este plan. Lo demás va a un apéndice del notebook, no al vídeo.
2. Para cada cambio aceptado, editar **este archivo** (sección §4 fila correspondiente, §5 hipótesis, §3 decisiones) y, si afecta a una figura, `00_storyboard_diapositivas.md` y `00_plan_implementacion.md` (lista de figuras y `numbers.json`). Registrar el cambio en la tabla de abajo.
3. Candidatos previsibles y cómo encajan: *series de tiempo* → anotaciones de choques y "las proyecciones no contienen choques" (S13; va a ética/limitaciones, no a una figura nueva); *multivariado* → validación del PCA (bootstrap de cargas, conjunto de variables, rotación) y del clustering (k, distancia, estabilidad); *datos funcionales* → FPCA de las curvas TFR/LEx como alternativa a las medias por década en Q3 (aceptar solo si los grupos cambian poco y la explicación cabe en una frase: "we compared the whole 70-year curve, not just decade averages"); *estadística social* → redacción de recomendaciones, lenguaje no estigmatizante, grupos de ingreso variables en el tiempo (si propone usar la clasificación histórica del Banco Mundial, aceptarla solo como sensibilidad).
4. Nunca añadir una figura al vídeo sin quitar otra: el límite de 3 visuales por diapositiva es fijo.

| Memo | Fecha | Cambio aceptado | Dónde se aplicó | Rechazado (motivo) |
|---|---|---|---|---|
| — | — | — | — | — |
