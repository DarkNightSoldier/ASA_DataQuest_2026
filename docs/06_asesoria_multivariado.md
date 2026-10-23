# 06 — Asesoría de análisis multivariado (P8, P5, P6, P7)

> Asesor: análisis multivariado. Fecha: 2026-10-22. Datos: `WPP2024_Demographic_Indicators_Medium_csv.gz` (países = `ISO3_code` no vacío, 237), ingreso `wb_api_income_2026-10-22.csv` (`ingreso_api`), LE60 del suplemento. Muestra de modelos: **161 países ≥ 1 M en 2023** (160 en comparaciones por ingreso: se excluye Taiwán, "Not classified").
> Todas las cifras son **prototipos exploratorios** ejecutados en R 4.6.1 (`set.seed(2026)`). Scripts: `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/multivariado/00_prep.R … 12_mc_sens.R` (el scratchpad es temporal: el agente `notebook-R` debe pasar los bloques de §3 al notebook). Figuras: `docs/asesoria_figs/multivariado/`. Las cifras finales salen de `figures/numbers.json`, no de este memo.

---

## 0. Resumen en 8 líneas

1. **El PCA del plan no da 46 %.** Con el conjunto fijo de 12 indicadores (`vars_pca`) y los 161 países, PC1 = **56,7 %** (bootstrap 95 %: 54,7–59,1 %), PC2 = 17,9 %, y **2 componentes ya superan el 70 % (74,6 %)**, no 3. El 46 % del EDA venía de otro conjunto (13 variables con MAC y SRB, y los 237 países: 45,6 %). El % de PC1 va de **46 % a 66 %** según qué variables entren → no debe ser la cifra titular de P8.
2. Lo robusto para P8 es la estructura: **dos dimensiones por encima del ruido** (análisis paralelo de Horn, con 12 y con 8 variables, en 1950, 1990, 2023 y 2050). La TFR es casi idéntica al eje 1 (r = −0,945) y **ciega al eje 2** (r = 0,03).
3. La demostración de P8 más convincente y honesta: **"look-alikes"**. Si se buscan los 5 países más parecidos a cada país usando solo la TFR, se recupera el **13 %** de sus 5 vecinos reales en los 12 indicadores (azar: 3 %; dos ejes: 43 %). Colombia, según la TFR, se parece a FRA, AUS, TUR, USA y NZL; según los 12 indicadores, a IRN, PER, ECU, PAN y TUN. Esto convierte los "gemelos" anecdóticos en una métrica sistemática.
4. El scorecard nuevo de la Slide 3 se replica (0,771 / 0,881 / 0,590 / −0,001), pero la escalera de crecimiento es una **identidad exacta** (`PopGrowthRate = (CBR − CDR + CNMR)/10`, residuo máximo 0,002; R² = 1,000 con CBR). Su uso legítimo es otro: la **descomposición de Shapley** por grupo de ingreso (P7/P4).
5. **P5:** α = 0,95 y ω = 0,95, pero el % de países que cambia > 20 puestos va de **2,5 % a 47 %** según qué incertidumbre se admita. Lo que más mueve el ranking son los **pesos**, no la normalización. El "24 %" del plan depende de qué variantes se elijan (con mis 11 variantes sale 19,9 %).
6. **P6:** k-means k = 4 da 3 "rebanadas" de un continuo más un grupo migratorio de 7 países (Golfo, Jordania, Yibuti). Es estable (Jaccard bootstrap 0,80–0,95), pero **los grupos explican el 90 % del eje 1 de las trayectorias**: son tramos de un mismo camino, no cajas. Sin CNMR, el grupo migratorio desaparece (ARI 0,54).
7. **P7:** hay un patrón tipo Simpson. En el mundo, ρ(Q5, CNMR) = −0,46, pero **dentro de cada grupo de ingreso es ≈ 0**. ρ(TFR, CNMR) = −0,31 en el mundo, pero **es positiva** en ingreso medio-bajo (+0,50) y medio-alto (+0,34).
8. **H5 no se replica en la muestra ≥ 1 M:** en ingreso alto, ρ(TFR, CNMR) vale −0,36 solo con los 237 países (los microestados la arrastran). Con ≥ 1 M es +0,23 (Pearson) o +0,10 (Spearman). Hay que corregir el plan antes de narrarlo.

---

## 1. Evaluación del plan y del storyboard desde el análisis multivariado

| Sección | Qué está bien | Qué hay que cambiar |
|---|---|---|
| Plan §3 "Migración volátil" | Winsorizar la CNMR solo para PCA y clustering es razonable. | Hay que documentar a quién afecta. En el corte 2023 se recortan 7 países (SSD, TCD, SDN, ARM, OMN, SYR, ARE). En el panel 1950–2023 (límites [−46,7; 47,5] ‰) se recortan 144 país-años: QAT 25, ARE 22, KWT 17, DJI 9, HKG 8, JOR 8. Como sensibilidad, usar `asinh(CNMR/5)` (ARI 0,93 frente a winsorizar). |
| Plan §4-Q2 "Simple 1" (scorecard) | Es buena idea sustituir la escalera, y lo verifiqué: R² ajustado sobre TFR = 0,771 (edad mediana), 0,881 (Δ% población 2023→2050), 0,590 (crecimiento), −0,001 (CNMR; el plan dice "≈ 0,06"). | (a) **Declarar a priori** las 4 salidas, para que no parezcan elegidas a la carta. (b) No penalizar a la TFR por linealidad: con un spline natural de 3 g.l., la edad mediana sube a 0,864. (c) La salida (b) es una proyección construida a partir de la TFR ("partly by construction"), como ya dice la nota. |
| Plan §4-Q2 "Rico 1" (PCA) | El conjunto fijo de 12 indicadores y la sensibilidad con 8 están bien pensados. | **Corregir lo esperado: PC1 56,7 %, PC2 17,9 %, 2 PCs > 70 %.** Usar el análisis paralelo en lugar de Kaiser (Kaiser retiene 3, pero el autovalor de PC3, 1,15, queda por debajo del p95 nulo, 1,31). Sin el Golfo, PC2 baja a 13,3 %: **el eje 2 depende en parte de 6 países**, y eso debe decirse. |
| Plan §4-Q2 "Rico 2" (índice, P5) | La tabla de decisiones y la advertencia ética están bien. | Sustituir "7 variantes elegidas a mano" por un **Monte Carlo con distribuciones declaradas** (§2.2). El α no demuestra robustez (§2.2). Si se usa la versión con migración, decir que su signo no está definido: incluirla con + o con − mueve el 8 % o el 5 % de los países más de 20 puestos. |
| Plan §4-Q2 "Rico 3" (información perdida) | La idea es la correcta. | Cambiar la "ρ² media de Spearman" por dos métricas que se explican en una frase: **fracción del perfil recuperada** (R² medio sobre los 12 indicadores) y **solapamiento de vecinos** (§2.1). La primera es la versión honesta de "cuánto cuenta un número". |
| Plan §4-Q3 "Rico 1" (clustering) | Las medias por década, k-means y Ward/PAM como robustez, y "continuo, no cajas" están bien. | Mi silueta es **0,37** con k = 4 (no ≤ 0,23); la del EDA usaba otros rasgos. El gap de Tibshirani elige k = 3. `fpc::clusterboot` no está instalado; uso un bootstrap manual (código en §3). **India cae en "Fast movers"** con estos rasgos, lo que lleva a ese grupo a 4,90 mil M de personas; revisar el guion ("Late movers… Pakistan") y `cluster_examples`. |
| Plan §4-Q1 "Rico 2" (acoplamiento) y **H5** | La idea de correlaciones año a año por grupo es buena. | **H5 cambia de signo** según la muestra (§3.5). Además, comparar correlaciones entre grupos con varianzas distintas confunde "relación más débil" con "rango restringido" (DE de la TFR: 1,11 en ingreso bajo frente a 0,37 en alto). Mostrar pendientes junto a las correlaciones. |
| Storyboard Slide 3, build 3 | La estructura de 3 visuales está bien. | La narración "the transition axis captures only 46 percent" **es falsa** con el conjunto del plan. Propuesta en §5. "{n_pcs_70} axes" = 2. |
| Storyboard Slide 4, build 2 | "A continuum, not boxes" es correcto. | Respaldarlo con una cifra que se entiende: "groups explain 90 % of one single path axis" o "4 in 10 countries sit between two groups" (fanny: 42 % con pertenencia máxima < 0,6). |
| Ganadores §3.6 / §7.3 (ANOVA circular de QuantaQuartet) | El plan ya lo evita en el texto. | Hacerlo explícito: describir los grupos **solo con variables que no los definieron** (§2.3) y sin valores p. |

---

## 2. Método recomendado por pregunta

### 2.1 P8 — ¿un indicador cuenta toda la historia?

**Recomendación:** responder con tres piezas, de menor a mayor abstracción. (1) El **scorecard** (ya en el storyboard) da la respuesta corta. (2) La **prueba de look-alikes** es la evidencia sistemática y sustituye a los gemelos como protagonistas; los gemelos quedan como ejemplos. (3) El **PCA con análisis paralelo** da la estructura: "two real dimensions; fertility is one of them". La escalera de crecimiento solo va en una nota al pie, como identidad.

**¿Escalera de R², PCA u otra salida?**
- La escalera `PopGrowthRate ~ TFR → +CDR → +CNMR` (0,592 → 0,700 → 0,986; CV 0,582 → 0,682 → 0,985) **es trivial como prueba de P8**. El crecimiento es, por definición, natalidad − mortalidad + migración (con CBR el R² es 1,000). El 0,986 solo refleja que TFR ≈ CBR (r = 0,983). Solo dice algo sobre la varianza relativa de cada componente, y eso se responde mejor con Shapley (§2.4).
- Con salidas fuera de la identidad, la respuesta se matiza, y conviene decirlo porque es honesto:
  - Edad mediana 2023: TFR 0,773 → +LEx 0,816 → +CNMR 0,817.
  - LE60 2023: TFR 0,591 → +LEx 0,891.
  - Edad mediana 2023 sobre la TFR de 1990: 0,898.
  - Cambio de edad mediana 2023→2050: TFR 0,072 → +LEx 0,159 → +CNMR 0,216 (CV 0,05 / 0,13 / 0,17).

  **Para la estructura por edades, un número (la fecundidad pasada) casi basta. Para el crecimiento hace falta la migración. Y el ritmo de envejecimiento futuro no lo explica ningún resumen simple.** Esto coincide con el mensaje nuevo del storyboard ("slow story vs fast levers") y lo refuerza.
- **El PCA demuestra la estructura, no un porcentaje.** El PC1 es el mejor resumen lineal posible de un solo número: la media de los R² de los 12 indicadores sobre PC1 es su proporción de varianza, 0,567. Aun así deja fuera el eje migración/razón de sexos. TFR, LEx y edad mediana recuperan cada una entre el 51 % y el 53 % del perfil (entre el 55 % y el 59 % con splines). Lo que se pierde no es ruido: el eje 2 supera al ruido.

**Supuestos y validación:** PCA sobre correlaciones (variables estandarizadas). Linealidad: la contrasto con splines. Sensibilidad a casos atípicos: repetido sin el Golfo y con winsorización. Se valida con bootstrap de países (B = 500), análisis paralelo (1 000 permutaciones por columna), cortes 1950/1990/2050/2100 y 4 conjuntos de variables. El solapamiento de vecinos es estable: con k = 5 o 10, en 1990, 2023 o 2050, y con 12 u 8 variables, la TFR recupera entre el 13 % y el 15 % (k = 5) y el PC1 entre el 17 % y el 25 %.

**Alternativas evaluadas y descartadas para el vídeo:**
- **Análisis factorial ML** (`factanal`, 3 factores, 8 variables). Da casos Heywood (unicidad 0 en CDR y edad mediana), ajuste malo (p = 6·10⁻¹²) y la CNMR con unicidad 0,95, que es otra forma de decir que la migración "va por su cuenta". Solo para el apéndice.
- **Correlaciones parciales.** Son reveladoras pero difíciles de narrar. TFR–LEx pasa de −0,85 a +0,10 dados los demás indicadores; edad mediana–CDR pasa de 0,50 a 0,93 (la CDR mide envejecimiento). Al notebook.
- **VIF.** Con 12 variables: LEx 335, CBR 200, PGR 131, TFR 81. Prueba la redundancia mecánica y justifica no regresar unas variables sobre otras como si fueran independientes. Al notebook.

**Frases en inglés para el vídeo:**
- PCA: *"We let the data find the few directions along which countries differ most; the first one is the demographic transition."*
- Análisis paralelo: *"We compared each direction with what pure noise would give: only two beat noise."*
- Perfil recuperado: *"Knowing only a country's fertility, you can rebuild about half of its twelve-indicator profile."*
- Look-alikes: *"Find a country's look-alikes by fertility alone and you get only one in eight of its real look-alikes."*
- Bootstrap: *"We re-ran everything on 500 resampled sets of countries to see how much the answer moves."*

### 2.2 P5 — índice compuesto

**Construcción recomendada** (marco del *Handbook on Constructing Composite Indicators*, OCDE/JRC 2008):
1. **Constructo:** "avance en la transición demográfica" (no desarrollo ni bienestar).
2. **Selección:** TFR, Q5, LEx, edad mediana y crecimiento. La CNMR queda fuera porque su dirección no está definida.
3. **Dirección:** + = más avanzado.
4. **Normalización:** z-score (base); min–max, rangos y *goalposts* fijos 1950–2100 como alternativas.
5. **Pesos:** iguales (base). Los pesos del PC1 salen casi iguales (≈ 0,20 cada uno), así que "PCA weights" no aporta nada. Los pesos por dimensión (fecundidad 1/3, mortalidad 1/3 repartido entre Q5 y LEx, estructura 1/3) corrigen el doble conteo de mortalidad (r(Q5, LEx) = 0,91).
6. **Agregación:** aritmética (compensatoria) frente a geométrica.

**Sensibilidad e incertidumbre:**
- Entre 11 variantes: ρ de Spearman ≥ 0,907 (≥ 0,981 sin las de migración). Amplitud de rango mediana: 9 puestos (7 sin migración). Países que se mueven > 20 puestos: 19,9 % (7,5 %).
- Monte Carlo (2 000 índices), % de países con un intervalo 90 % de rango de más de 20 puestos según la incertidumbre que se admita:
  - solo normalización y agregación: 2,5 %;
  - pesos Dirichlet(5) con los 5 indicadores fijos: 14,9 %;
  - Dirichlet(5) variando también la inclusión del crecimiento: 21,1 %;
  - Dirichlet(1): 47,2 %.

  **El resultado de P5 es que el peso de cada ingrediente decide el ranking mucho más que la normalización.** La cifra narrada debe ir junto a la distribución declarada (recomiendo Dirichlet(5) + inclusión: "about one in five countries").
- Países más inciertos: ARE (rango 15–113), OMN (54–130), UKR (3–68), ISR, QAT, BHR, BLR y MDA. Extremos robustos: HKG, JPN, KOR e ITA arriba; MLI, CAF, SOM, NER y TCD abajo. Para el bump chart, usar **UKR o BLR** (≥ 1 M, saltos de 34 y 27 puestos entre variantes sin migración) en lugar de Saint Martin.

**Fiabilidad: por qué α es discutible aquí.**
- α = 0,952 (5 ítems), 0,962 (4) y 0,956 (3); ω = 0,954.
- α supone un modelo **reflectivo**: los ítems serían mediciones paralelas de un rasgo latente, con errores independientes. Aquí no se cumple:
  - Q5 y LEx salen de la **misma tabla de vida**, y crecimiento y TFR comparten nacimientos. Los errores están correlacionados por construcción y eso **infla** α.
  - α crece mecánicamente con el número de ítems.
  - Un α alto **no** dice nada sobre la robustez del ranking: con α = 0,95, la mitad de los países puede moverse más de 20 puestos con pesos Dirichlet(1).
- **Alternativas:**
  - (i) Dimensionalidad: el primer autovalor explica el 84 % y el segundo vale 0,46 < 1, así que el índice es unidimensional.
  - (ii) **Pesos efectivos** (importancia = r² del índice con cada componente; Paruolo, Saisana y Saltelli 2013): TFR 0,216, Q5 0,207, LEx 0,201, edad mediana 0,211, crecimiento 0,165. El crecimiento pesa menos de lo nominal.
  - (iii) **Intervalos de rango Monte Carlo** como resultado principal.
  - (iv) Validez convergente con una variable que no entra en el índice: ρ(índice, LE60) = 0,867.

**Advertencia ética:**
- Un rango "alto" no significa "mejor". Una edad mediana alta o un crecimiento bajo no son metas.
- Prohibido colorear en rojo/verde o titular "best/worst". Escribir siempre *"transition-advancement index — not a development or well-being index"*.
- Nunca presentar una tabla tipo liga de países en el vídeo.

**Frases en inglés:**
- *"We built the same index two thousand reasonable ways; about one country in five moves more than twenty places."*
- *"The ingredients agree with each other — but agreement doesn't make a ranking robust; the weights decide."*

### 2.3 P6 — grupos por trayectorias

**Recomendación:**
- Mantener **k-means sobre 32 rasgos** (medias por década 1950s…2020s de TFR, LEx, edad mediana y CNMR winsorizada, z en el panel), con `nstart = 50` y k = 4.
- Presentarlo como **"three stretches of one road plus a migration group"**. Fijar a priori si la CNMR entra (yo la dejaría, porque es el eje 2 de P8) y mostrar la sensibilidad.

**Elección de k:**
- Silueta (k-means): 0,442 (k = 2), 0,362 (3), **0,372 (4)**, 0,304 (5), 0,251 (6).
- Gap (Tibshirani, 1-SE): k = 3. Mclust (BIC, 4 PCs): G = 5.
- Bootstrap manual (B = 200, Jaccard por grupo): k-means k = 4 da **0,80 / 0,95 / 0,85 / 0,91** (el 0,80 es el grupo migratorio de 7). Ward k = 4 es menos estable (0,64–0,78).
- Conclusión: **k = 3 es la partición "natural" del continuo y k = 4 añade un grupo pequeño, estable y con otro mecanismo.** Al quitar esos 7 países y rehacer k = 3, el resto se reparte exactamente igual (ARI = 1).

**Acuerdo entre métodos** (ARI, k = 4):
- k-means frente a Ward: 0,63; frente a PAM: 0,73; frente a Mclust: 0,45.
- Trayectorias frente a niveles de 2023: **0,59** (la trayectoria cambia el 40 % de la clasificación, aproximadamente).
- Con frente a sin CNMR: 0,54.

**Riesgo del Golfo:**
- El grupo 4 lo define la migración (centroide CNMR de los 2000 = +2,6 DE). Su tamaño depende del tratamiento de la CNMR: 3 países sin winsorizar (KWT, QAT, ARE), 7 con ±3 DE y 8 con asinh (+ISR).
- Sin CNMR, ese grupo se disuelve. ARE, QAT, KWT y BHR se unen a KOR, PRK, CHN, SGP, ISR y LBN en un tramo "rápido", y los cuatro grupos pasan a ser cuatro rebanadas (45/44/36/36; silueta 0,40).
- **Por eso el nombre "Sprinters" (variante ii del storyboard) solo es válido en la versión sin CNMR.** Con CNMR, el nombre correcto es *Migration-boosted* (variante i).

**Describir sin ANOVA circular:**
- Ninguna prueba sobre TFR, LEx, edad mediana o CNMR entre grupos: siempre saldría "significativa".
- Describir con **variables externas** (medianas, sin valores p):

| Grupo (n; población 2023) | Q5 2023 | LE60 2023 | Δ% pobl. 2023→50 (proy.) | Edad mediana 2050 (proy.) |
|---|---|---|---|---|
| Late movers (53; 1,67 mil M; PAK, NGA, ETH, COD) | 50,3 | 17,0 | +64,4 | 24,6 |
| Fast movers (51; 4,90 mil M; IND, CHN, IDN, BRA) | 16,0 | 20,3 | +15,2 | 38,2 |
| Early movers (50; 1,44 mil M; USA, RUS, JPN, DEU) | 3,8 | 23,9 | −6,9 | 47,8 |
| Migration-boosted (7; 0,07 mil M; SAU, JOR, ARE, KWT) | 6,3 | 23,0 | +39,8 | 32,3 |

- Validación externa: V de Cramér grupo ~ ingreso = 0,58 y grupo ~ región = 0,66. Hay coherencia sin que sean idénticos.
- Si el jurado pide una prueba: dividir la muestra, agrupar con una mitad, asignar la otra al centroide más cercano y comparar en ella variables externas.

**"Un continuo, no cajas"** (figura `fig_mv05`):
- El eje 1 de los rasgos de trayectoria concentra el 67 % de su varianza, y **los grupos explican el 90 % de ese eje**.
- Pertenencia difusa (`cluster::fanny`): el 42 % de los países tiene una pertenencia máxima < 0,6.
- El 11 % tiene silueta < 0,1, y 7 la tienen negativa.

**Frases en inglés:**
- *"We grouped countries whose seventy-year paths look alike."*
- *"Re-sampling countries, the same groups come back 80 to 95 percent of the time."*
- *"The groups are stretches of one road: four in ten countries sit between two of them."*

### 2.4 P7 — relaciones fecundidad–mortalidad–migración por grupo

**Recomendación:**
- Usar un **forest plot** de correlaciones de Spearman por grupo de ingreso, con IC bootstrap al 95 % (B = 2 000; `fig_mv06`), en lugar de heatmaps lado a lado: con n = 25–50, un heatmap no muestra que los IC miden ±0,3–0,4.
- Con un solo indicador por familia: TFR (fecundidad), Q5 (mortalidad infantil), CNMR (migración), y LEx–CDR como control del "cambio de significado".
- Variables: promedio 2021–2023.

**Resultados:**

| Par (Spearman 2021–23) | Mundo | Bajo | Medio-bajo | Medio-alto | Alto |
|---|---|---|---|---|---|
| TFR–Q5 | +0,87 [0,82; 0,91] | +0,66 | +0,60 | +0,70 | +0,40 [0,13; 0,65] |
| TFR–CNMR | **−0,31** [−0,44; −0,15] | −0,10 | **+0,50** [0,26; 0,68] | **+0,34** [0,05; 0,57] | +0,11 [−0,23; 0,42] |
| Q5–CNMR | **−0,46** [−0,59; −0,32] | +0,08 | +0,16 | +0,17 | −0,07 |
| LEx–CDR | +0,04 | −0,81 | −0,74 | +0,02 | −0,38 |

- **Mensaje:** la asociación mundial entre mortalidad infantil y migración (−0,46) es un **gradiente de ingreso disfrazado**. Dentro de cada grupo desaparece; la correlación parcial dado el ingreso es +0,08. La de fecundidad con migración incluso se invierte dentro de los grupos (parcial dado el ingreso = +0,24).
- **Igualdad de matrices de correlación:** prueba de permutación (se permutan las etiquetas de ingreso; estadístico = Σ_g n_g‖R_g − R‖² en el triángulo superior), p < 0,0005 (0 de 2 000), tanto con 6 como con 3 variables. Prefiero la permutación a Box's M o Jennrich, que asumen normalidad. Al notebook; en el vídeo basta el forest plot.
- **Rango restringido:** la DE de la TFR cae de 1,11 (ingreso bajo) a 0,37 (alto), lo que atenúa las correlaciones en ingreso alto. Hay que acompañarlas de **pendientes**:
  - TFR ~ log(Q5): 1,55 [0,95; 2,03] en ingreso bajo, 1,03 en medio-bajo, 0,74 en medio-alto y 0,33 [0,10; 0,55] en alto. El acoplamiento fecundidad–mortalidad se debilita de verdad, no solo por el rango.
  - CNMR ~ TFR (robusta): 2,2 ‰ por hijo en ingreso alto, con IC [−2,4; 13,4]. Es inestable y no debe narrarse.
- **Shapley** (qué parte de las diferencias de crecimiento entre países atribuir a natalidad, mortalidad y migración; no depende del orden):

| Grupo (2023) | CBR | CDR | CNMR |
|---|---|---|---|
| Mundo | 0,57 | 0,14 | 0,29 |
| Medio-bajo | 0,71 | 0,02 | 0,27 |
| Medio-alto | 0,43 | 0,22 | 0,35 |
| Alto | 0,18 | 0,31 | 0,50 |
| Bajo | 0,18 | 0,04 | 0,78 |

  El 0,78 de ingreso bajo es frágil: lo arrastran SSD (+39,6), SYR (+32,1) y SDN (−27,0). Sin ellos, CBR 0,59 y CNMR 0,37; con el promedio 2021–23, CNMR 0,50. En ingreso alto es estable (0,54 en 2021–23). Es una alternativa honesta a la escalera para la Slide 1–2: *"In high-income countries, half of the differences in growth come from migration."*
- **Correlaciones casi definicionales** (no presentarlas como hallazgos): r(TFR, CBR) = 0,983; r(IMR, Q5) = 0,991; r(LEx, Q5) = −0,913; `NatChangeRT = CBR − CDR` (r = 1); `PopGrowthRate = (CBR − CDR + CNMR)/10`. No poner CBR, IMR, NatChangeRT ni PGR en la misma matriz que TFR, Q5 y CNMR.

**Frases en inglés:**
- *"A worldwide correlation can be an income gap in disguise: inside each income group, it disappears."*
- *"We split the differences in growth between births, deaths and migration fairly, whatever the order."*

---

## 3. Prototipos ejecutados (código clave y salidas)

### 3.1 PCA + análisis paralelo + bootstrap (`01_pca.R`)

```r
# Conjunto fijo del plan (12); CNMR winsorizada ±3 DE en el corte; 161 países >= 1 M
vars <- c("TFR","CBR","LEx","LE65","Q5","Q1560","CDR","MedianAgePop","PopGrowthRate","CNMR","PopSexRatio","logDens")
X  <- scale(d23[, vars]); pc <- prcomp(X); ve <- pc$sdev^2 / sum(pc$sdev^2)
# Análisis paralelo de Horn: autovalores de datos con columnas permutadas (sin estructura)
nulo <- replicate(1000, eigen(cor(apply(X, 2, sample)), only.values = TRUE)$values)
umbral95 <- apply(nulo, 1, quantile, 0.95); n_dim <- sum(cumprod(pc$sdev^2 > umbral95))
# Bootstrap de países: % de PC1 y cargas (alineando el signo con LEx)
bt <- replicate(500, { i <- sample(nrow(X), replace = TRUE); p <- prcomp(scale(d23[i, vars]))
  r1 <- p$rotation[, 1]; if (r1["LEx"] < 0) r1 <- -r1; c(pc1 = p$sdev[1]^2 / sum(p$sdev^2), r1) })
```

| Corte | n | PC1 | PC2 | PC1–3 | PC2 dominado por |
|---|---|---|---|---|---|
| 2023 ≥ 1 M | 161 | 0,567 [0,547; 0,591] | 0,179 | 0,842 | razón de sexos (0,56), CDR (−0,49), CNMR (0,45) |
| 2023 sin Golfo | 155 | 0,590 | 0,133 | 0,835 | CDR, razón de sexos, Q1560 |
| 2023 todos | 237 | 0,537 | 0,171 | 0,803 | CNMR, crecimiento, razón de sexos |
| 1950 / 1990 | 161 | 0,563 / 0,563 | 0,180 / 0,160 | 0,824 / 0,832 | crecimiento y CNMR |
| 2050 / 2100 (proy.) | 161 | 0,616 / 0,571 | 0,159 / 0,209 | 0,868 / 0,870 | razón de sexos y CDR |

- Autovalores 6,80 / 2,15 / 1,15 / 0,83, frente a un p95 nulo de 1,60 / 1,42 / 1,31 / 1,22 → **2 dimensiones**.
- Cargas de PC1: CBR −0,37, LEx 0,37, TFR −0,36, edad mediana 0,36, Q5 −0,35. Correlación con PC1: TFR −0,945, LEx 0,953, edad mediana 0,948.
- **PC1 por conjunto de variables (misma muestra, 161 países):** 8 del catálogo 65,9 %; 12 del plan 56,7 %; 8 no redundantes 46,1 %; 13 del EDA 49,1 % (45,6 % con los 237).
- Entre 1950 y 2023 el % de PC1 es estable (55–57 %). Solo crece en la proyección (62 % en 2050), lo que encaja con los supuestos de convergencia de la ONU.

### 3.2 Información recuperada y look-alikes (`02_p8_alternativas.R`, `03_p8_robustez.R`)

```r
# Fracción del perfil 12-D que recupera un conjunto de predictores (R² medio; la propia variable cuenta como 1)
recupera <- function(pred) mean(sapply(vars, function(v) if (v %in% pred) 1 else summary(lm(reformulate(pred, v), Z))$r.squared))
# Solapamiento de los k vecinos más cercanos: perfil completo vs resumen
knn_overlap <- function(cols, k = 5) { Df <- as.matrix(dist(Z[, vars])); Ds <- as.matrix(dist(Z[, cols, drop = FALSE]))
  diag(Df) <- diag(Ds) <- Inf
  mean(sapply(seq_len(nrow(Z)), function(i) length(intersect(order(Df[i, ])[1:k], order(Ds[i, ])[1:k])) / k)) }  # azar = k/(n-1)
```

| Resumen | Perfil recuperado (lineal / spline) | Vecinos recuperados (k = 5) |
|---|---|---|
| TFR | 0,509 / 0,550 | 0,132 |
| LEx | 0,525 / 0,570 | 0,174 |
| Edad mediana | 0,519 / 0,592 | 0,150 |
| PC1 (mejor número posible) | 0,567 / 0,613 | 0,204 |
| TFR + CNMR / + CDR | 0,637 / 0,761 | 0,220 / 0,389 |
| PC1+PC2 / PC1–3 | 0,746 / 0,842 | 0,432 / 0,647 |
| Azar | — | 0,031 |

- Selección *greedy* de indicadores reales: CBR 0,536 → +PGR 0,683 → +CDR 0,786 → +logDens 0,863, frente al óptimo PCA de 0,567 / 0,746 / 0,842 / 0,911.
- La TFR no explica la CDR (R² 0,04), la CNMR (0,01), la razón de sexos (0,00) ni la densidad (0,06).
- Ejemplo de UAE: sus vecinos reales son OMN, KWT, BHR, SAU y QAT; según la TFR, LTU, ITA, BLR, JPN y THA.

### 3.3 Índice: variantes, Monte Carlo y α (`04_indice.R`, `12_mc_sens.R`)

```r
# Monte Carlo de diseño (OCDE/JRC): pesos Dirichlet(a), normalización, agregación e inclusión aleatorios
sims <- replicate(2000, { usa <- if (runif(1) < .5) ind else ind[1:4]
  w <- rgamma(length(usa), a); w <- w / sum(w)                        # a = 5: pesos "razonables"; a = 1: muy dispersos
  norm <- sample(c("z","mm","rk"), 1); agg <- sample(c("arit","geom"), 1)
  M <- switch(norm, z = scale(O[, usa]), mm = mm(O[, usa]), rk = rk(O[, usa]))
  s <- if (agg == "geom") geo(if (norm == "z") mm(O[, usa]) else M, w) else as.vector(M %*% w); rank(-s) })
ancho90 <- apply(sims, 1, function(r) diff(quantile(r, c(.05, .95))))   # incertidumbre de rango por país
```

Resultados en §2.2. α estandarizado: `k/(k-1) * (1 - sum(apply(scale(O),2,var)) / var(rowSums(scale(O))))`; ω a partir de `factanal(O, 1)`.

### 3.4 Clustering, k y estabilidad (`05_cluster.R`, `06_cluster_sens.R`)

```r
# Bootstrap de estabilidad (sustituto de fpc::clusterboot): Jaccard máx. de cada grupo original en cada réplica
jacc_boot <- function(X, k, B = 200) { ref <- kmeans(X, k, nstart = 50)$cluster; J <- matrix(NA, B, k)
  for (b in 1:B) { i <- sample(nrow(X), replace = TRUE); iu <- unique(i)
    cb <- kmeans(X[i, ], k, nstart = 10)$cluster; cb_u <- tapply(cb, i, `[`, 1)[as.character(iu)]
    for (g in 1:k) { A <- iu[ref[iu] == g]; if (!length(A)) next
      J[b, g] <- max(sapply(unique(cb_u), function(h) { Bh <- iu[cb_u == h]; length(intersect(A, Bh)) / length(union(A, Bh)) })) } }
  colMeans(J, na.rm = TRUE) }   # > 0,75 estable; < 0,6 disuelto (Hennig 2007)
gap <- cluster::clusGap(X, function(x, k) list(cluster = kmeans(x, k, nstart = 20)$cluster), K.max = 8, B = 100)
mclust::adjustedRandIndex(km4$cluster, cutree(hclust(dist(X), "ward.D2"), 4))
```

### 3.5 Correlaciones por grupo y comprobación de H5 (`07_cor_grupos.R`, `08_h5_check.R`)

```r
# Permutación: ¿difieren las matrices de correlación entre grupos de ingreso?
stat <- function(df, g) { R0 <- cor(df[, vs], method = "spearman")
  sum(sapply(levels(g), function(l) sum(g == l) * sum((cor(df[g == l, vs], method = "spearman") - R0)[upper.tri(R0)]^2))) }
p <- mean(replicate(2000, stat(d, sample(d$ingreso))) >= stat(d, d$ingreso))
```

| ρ(TFR, CNMR) en ingreso alto | 2023 Pearson | 2023 Spearman | 2021–23 Spearman | 2100 Spearman |
|---|---|---|---|---|
| 237 países | **−0,36** (= H5) | −0,24 | −0,20 | −0,20 |
| ≥ 1 M | **+0,23** | +0,10 | +0,11 | +0,17 |

→ La H5 del plan es un efecto de los microestados de ingreso alto. Con la regla del plan (≥ 1 M para correlaciones) no se sostiene.

### 3.6 Figuras guardadas (`docs/asesoria_figs/multivariado/`)

| Archivo | Qué muestra | Uso sugerido |
|---|---|---|
| `fig_mv01_scree_paralelo.png` | Autovalores con la línea del ruido (2 dimensiones reales) y el % de PC1 en 4 conjuntos de variables (46–66 %) | Notebook / respaldo de P8. El panel izquierdo puede sustituir al scree del biplot. |
| `fig_mv02_biplot_2023.png` | Biplot: eje 1 = transición, eje 2 = razón de sexos y migración frente a CDR (envejecimiento); el Golfo resaltado | Base del `fig09_pca_biplot` de la Slide 3 |
| `fig_mv03_un_numero_recupera.png` | Perfil recuperado por 1–3 números y look-alikes recuperados (TFR 13 % frente a dos ejes 43 %), con el ejemplo de Colombia | **Candidata a Slide 3** (sustituye a los gemelos o los acompaña) |
| `fig_mv04_indice_incertidumbre.png` | Intervalos 90 % de rango del índice (Monte Carlo Dirichlet(1)); naranja = ancho > 20 | P5. Rehacer con Dirichlet(5) para el vídeo. |
| `fig_mv05_clusters_continuo.png` | Países en el plano de los rasgos de trayectoria por grupo (rebanadas + grupo migratorio) y silueta por k para 3 métodos | Notebook y respaldo de "continuum, not boxes" (Slide 4) |
| `fig_mv06_correlaciones_ingreso.png` | Forest plot de ρ por grupo de ingreso con IC bootstrap: patrón tipo Simpson | P7 en el notebook; un build opcional de la Slide 2 |

---

## 4. Riesgos estadísticos y éticos

1. **Cifra titular frágil (A, C):** el % de PC1 depende del conjunto de variables (46–66 %) y el "% que cambia > 20 puestos" depende de la distribución de pesos (2,5–47 %). Hay que narrar el hallazgo estructural y dar cada cifra con su definición.
2. **Selección post hoc (A.2, C.3):** el scorecard y los gemelos pueden parecer elegidos para ganar el argumento. Mitigación: declarar en el notebook, antes de calcular, las salidas y la regla de selección de gemelos, y acompañarlo de la métrica sistemática de look-alikes.
3. **Identidades presentadas como hallazgos (B):** la escalera de crecimiento, TFR–CBR, LEx–Q5, IMR–Q5 y NatChangeRT.
4. **ANOVA circular / inferencia post-selección (ganadores §7.3):** nada de pruebas sobre las variables que definen los grupos.
5. **Golfo y migración (D):** la CNMR winsorizada define un grupo de 7 países que suman 0,07 mil M de personas, y el eje 2 del PCA pierde fuerza sin ellos (17,9 % → 13,3 %). Conviene decirlo y no estigmatizar: la migración positiva de SSD o SYR es retorno tras un conflicto, no "atracción". La CNMR es el dato más incierto de WPP.
6. **Microestados (B.2):** cambian el signo de H5. Mantener ≥ 1 M para todas las correlaciones y reportar los 237 países solo como sensibilidad.
7. **Simpson y rango restringido (C):** una correlación mundial no describe a ningún grupo. Dentro de los grupos, las correlaciones se atenúan porque la varianza es menor.
8. **Ingreso fijo en el tiempo:** el README de `data/raw` dice **FY2027** (GNI 2025), mientras el plan y el storyboard dicen **FY2026**. Hay que unificarlo antes de la franja de ética.
9. **Índice como ranking de valor (D):** nada de rojo/verde ni "best/worst". Rotular que es un índice de "transition advancement".
10. **Proyecciones (B, C):** el PCA de 2050/2100 y el Δ% 2023→2050 reflejan supuestos de la ONU (convergencia), no datos. Marcarlos siempre como "UN medium projection".

---

## 5. Cambios concretos al plan y al storyboard (para `integrate-advice`)

1. **Plan §4-Q2 "Rico 1" y H7:** cambiar el valor esperado a "PC1 ≈ 57 % [55–59], PC2 ≈ 18 %, **2** PCs > 70 % (75 %)". Usar el análisis paralelo como criterio (Kaiser solo como referencia) y añadir que, sin el Golfo, PC2 = 13 %. En la tabla de sensibilidad: 8 del catálogo = 66 %, 8 no redundantes = 46 %, 13 del EDA = 49 %.
2. **Storyboard Slide 3, narración:** sustituir "the transition axis captures only 46 percent; migration is an axis of its own" por: *"A principal component analysis finds two real dimensions, not one: fertility sits almost exactly on the first — the transition — and is blind to the second, migration."* Texto en pantalla: `2 axes beat noise · fertility ≈ axis 1 (r = {r_tfr_pc1}) · blind to axis 2`. Si se quiere un porcentaje: `{pc1_var} %` con el conjunto final.
3. **Storyboard Slide 3, build 2:** convertir los gemelos en ejemplos de una métrica. Añadir sobre las tarjetas: `For the average country, fertility finds only {knn_tfr} % of its 5 real look-alikes (2 axes: {knn_pc12} %)`. Opcional: tarjeta de Colombia (FRA/AUS/USA frente a IRN/PER/ECU), que conecta con el jurado colombiano de la ronda nacional.
4. **Plan §4-Q2 "Rico 3":** sustituir la "ρ² media de Spearman" por "perfil recuperado (R² medio)" y "look-alikes (k = 5)", con sensibilidad k = 10, 1990/2050 y 8 variables. Nuevas claves en `numbers.json`: `recov_tfr`, `recov_pc1`, `knn_tfr`, `knn_pc1`, `knn_pc12`, `knn_chance`, `n_dims_parallel`, `r_tfr_pc1`.
5. **Plan §4-Q2 "Simple 1" (scorecard):** declarar las 4 salidas a priori, reportar también el R² con spline (edad mediana 0,864) y corregir "CNMR ≈ 0,06" a "≈ 0" (−0,001).
6. **Plan §4-Q2 "Rico 2" y H8 (P5):** sustituir las "7 variantes" por un Monte Carlo declarado (Dirichlet(5) + normalización + agregación + inclusión del crecimiento; 2 000 réplicas). Cifra provisional: **21 %** de países con un intervalo 90 % > 20 puestos; solo normalización: 2,5 %. Línea de la Slide 3: `Composite index: weights, not formulas, decide — {share_rank_mc20} % of countries can move > 20 ranks`. Quitar "α" de la pantalla; dejarlo en el notebook con la explicación de §2.2. País destacado ≥ 1 M: **UKR**.
7. **Plan §4-Q3 "Rico 1":**
   - Esperados: silueta 0,37 (k = 4) y 0,44 (k = 2); gap → k = 3; Jaccard 0,80–0,95; ARI trayectorias frente a niveles 0,59; con frente a sin CNMR 0,54.
   - **Decidir a priori que la CNMR entra** y el grupo 4 se llama *Migration-boosted* (variante i del storyboard). La variante "Sprinters" solo aparece si se quita la CNMR; dejarla en el notebook como sensibilidad.
   - Sustituir `fpc::clusterboot` por `jacc_boot()` (§3.4) si `fpc` no se instala.
8. **Storyboard Slide 4:**
   - Revisar los ejemplos y tamaños de grupo: con estos rasgos, **India es Fast mover** (Fast = 51 países, 4,90 mil M; Late = 53, 1,67 mil M; Early = 50, 1,44 mil M; Migration-boosted = 7).
   - Respaldar "continuum, not boxes" con `{share_between_groups}` = 42 % (fanny, pertenencia < 0,6).
   - Describir los grupos solo con Q5, LE60, Δ% 2050 y edad mediana 2050 (tabla de §2.3).
9. **Plan H5 y "Rico 2" de Q1 (acoplamiento):** reescribir H5. Con ≥ 1 M, ρ(TFR, CNMR) en ingreso alto vale +0,10 (IC −0,23; 0,42). El −0,36 solo aparece con los 237 países. Añadir al heatmap de acoplamiento las pendientes TFR ~ log(Q5) por ingreso (1,55 → 0,33) y la advertencia de rango restringido.
10. **Nuevo hallazgo P7 (candidato S15):** *"Worldwide, countries with higher child mortality lose migrants (ρ = −0.46); inside every income group the link vanishes (−0.07 to +0.17)."* Figura `fig_mv06`. Alternativa a la escalera para la Slide 1–2: Shapley por ingreso (*"In high-income countries half of the differences in growth come from migration"*), etiquetando como frágil el valor de ingreso bajo.
11. **Plan §3:** documentar la winsorización (7 países en 2023; 144 país-años en el panel; lista de la §1) y usar asinh como sensibilidad.
12. **Plan §3 "Ingreso":** unificar FY2026 frente a FY2027 (README de `data/raw`).
