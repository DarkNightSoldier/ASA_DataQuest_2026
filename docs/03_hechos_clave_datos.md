# 03 — Hechos clave verificados (UN WPP2024)

> Números exactos, calculados directamente sobre `data/processed/paises.parquet`
> y `data/processed/agregados.parquet` (generados por `R/01_preparar_datos.R`,
> que ya pasó los 7 tests de `R/tests_datos.R`). Cualquier agente puede citar
> estas cifras tal cual; si necesita una cifra que no está aquí, debe
> calcularla desde esos mismos parquet, no desde el EDA previo ni desde este
> documento sin volver a verificar. Fuente: UN DESA WPP2024, CC BY 3.0 IGO.
> **Estimación** = observado (Time <= 2023). **Proyección** = variante Medium
> de la ONU (Time >= 2024); se marca explícitamente en cada cifra.
> Calculado el 2026-10-22 con `R/config.R` + `dplyr`/`arrow`.

---

## 1. Población mundial

| Año | Población | Tipo |
|---|---|---|
| 1950 | 2.493 mil millones | Estimación |
| 2023 | 8.092 mil millones | Estimación |
| 2100 | 10.180 mil millones | **Proyección** (Medium) |

**Pico de población mundial: 2084, con 10.289 mil millones** (Proyección Medium).

## 2. Indicadores mundiales 1950 / 2023 / 2100

| Año | TFR | LEx | IMR | Q5 | MedianAgePop | Tipo |
|---|---|---|---|---|---|---|
| 1950 | 4.85 | 46.4 | 138.4 | 227.0 | 22.2 | Estimación |
| 2023 | 2.25 | 73.2 | 27.3 | 36.3 | 30.4 | Estimación |
| 2100 | 1.84 | 81.7 | 9.6 | 13.1 | 42.1 | **Proyección** |

(TFR = hijos por mujer; LEx = esperanza de vida al nacer en años; IMR = mortalidad
infantil por 1,000 nacidos vivos; Q5 = mortalidad en menores de 5 por 1,000; MedianAgePop = edad mediana en años.)

## 3. Por región SDG (agregados oficiales de la ONU, ponderados)

| Región SDG | Año | TFR | LEx | IMR | Q5 | MedianAgePop | Población (miles) |
|---|---|---|---|---|---|---|---|
| Sub-Saharan Africa | 1950 | 6.42 | 37.2 | 165.7 | 318.95 | 18.0 | 177,731 |
| Sub-Saharan Africa | 2023 | 4.32 | 62.1 | 47.5 | 68.82 | 18.1 | 1,212,229 |
| Sub-Saharan Africa | 2100 | 2.03 | 73.8 | 17.2 | 24.13 | 34.3 | 3,351,459 (Proy.) |
| Northern Africa and Western Asia | 1950 | 6.52 | 40.6 | 194.1 | 332.66 | 19.1 | 100,007 |
| Northern Africa and Western Asia | 2023 | 2.73 | 73.8 | 19.0 | 24.46 | 25.9 | 572,507 |
| Northern Africa and Western Asia | 2100 | 1.85 | 84.1 | 4.2 | 5.09 | 40.5 | 987,038 (Proy.) |
| Central and Southern Asia | 1950 | 5.89 | 40.3 | 184.2 | 305.91 | 19.7 | 481,649 |
| Central and Southern Asia | 2023 | 2.26 | 71.7 | 27.2 | 33.02 | 26.8 | 2,123,893 |
| Central and Southern Asia | 2100 | 1.78 | 84.0 | 4.9 | 5.88 | 44.6 | 2,639,257 (Proy.) |
| Eastern and South-Eastern Asia | 1950 | 5.54 | 43.1 | 128.5 | 213.04 | 21.1 | 836,464 |
| Eastern and South-Eastern Asia | 2023 | 1.34 | 76.8 | 11.4 | 14.56 | 37.0 | 2,350,146 |
| Eastern and South-Eastern Asia | 2100 | 1.55 | 86.7 | 3.7 | 4.68 | 53.4 | 1,448,797 (Proy.) |
| Latin America and the Caribbean | 1950 | 5.79 | 48.7 | 141.4 | 210.80 | 18.3 | 167,782 |
| Latin America and the Caribbean | 2023 | 1.81 | 75.7 | 13.1 | 15.78 | 30.9 | 658,892 |
| Latin America and the Caribbean | 2100 | 1.65 | 86.4 | 3.1 | 3.76 | 49.1 | 613,447 (Proy.) |
| Oceania (excl. Australia/NZ) | 1950 | 5.96 | 42.6 | 143.6 | 226.37 | 17.5 | 2,494 |
| Oceania (excl. Australia/NZ) | 2023 | 3.02 | 67.7 | 28.7 | 35.47 | 23.0 | 13,939 |
| Oceania (excl. Australia/NZ) | 2100 | 1.89 | 76.2 | 9.6 | 11.58 | 37.7 | 23,990 (Proy.) |
| Australia/New Zealand | 1950 | 3.15 | 69.0 | 25.5 | 31.77 | 29.2 | 10,088 |
| Australia/New Zealand | 2023 | 1.64 | 83.6 | 3.4 | 4.07 | 37.7 | 31,624 |
| Australia/New Zealand | 2100 | 1.63 | 92.4 | 0.5 | 0.65 | 45.1 | 48,956 (Proy.) |
| Europe and Northern America | 1950 | 2.78 | 63.4 | 67.6 | 88.71 | 27.9 | 716,877 |
| Europe and Northern America | 2023 | 1.47 | 79.2 | 4.1 | 4.84 | 40.9 | 1,128,506 |
| Europe and Northern America | 2100 | 1.60 | 89.4 | 0.8 | 1.03 | 47.2 | 1,067,217 (Proy.) |

Verificación: la suma de población de países por región SDG reproduce el
agregado publicado en 2023 con una **diferencia máxima de 7×10⁻⁶ %** (ver
`R/tests_datos.R`, test T1).

## 4. Por grupo de ingreso del Banco Mundial (agregados oficiales de la ONU)

**Aviso de discrepancia (importante, documentado):** la ONU incluye en WPP2024
sus propios agregados "Income group" ya calculados, pero con una clasificación
de ingreso de **otro momento** (no necesariamente la FY2027 que usamos para
clasificar cada país — ver sección 9 abajo, donde esto se cuantifica con una
cifra concreta). La tabla de abajo usa los agregados **propios de la ONU**
(coherente internamente, pesos ya correctos), no nuestra unión con el API del
Banco Mundial.

| Grupo de ingreso (agregado ONU) | Año | TFR | LEx | IMR | Q5 | MedianAgePop | Población (miles) |
|---|---|---|---|---|---|---|---|
| High-income countries | 1950 | 3.04 | 61.8 | 61.7 | 88.15 | 27.4 | 692,711 |
| High-income countries | 2023 | 1.47 | 81.4 | 4.0 | 4.81 | 40.9 | 1,261,156 |
| High-income countries | 2100 | 1.60 | 90.8 | 0.9 | 1.03 | 46.1 | 1,252,364 (Proy.) |
| Upper-middle-income countries | 1950 | 5.32 | 45.4 | 134.4 | 213.28 | 21.2 | 971,460 |
| Upper-middle-income countries | 2023 | 1.48 | 75.9 | 11.0 | 13.83 | 35.5 | 2,811,309 |
| Upper-middle-income countries | 2100 | 1.61 | 86.3 | 3.1 | 3.83 | 51.0 | 2,026,151 (Proy.) |
| Lower-middle-income countries | 1950 | 5.80 | 40.8 | 173.7 | 299.68 | 19.8 | 710,725 |
| Lower-middle-income countries | 2023 | 2.55 | 69.6 | 32.3 | 42.41 | 25.5 | 3,253,459 |
| Lower-middle-income countries | 2100 | 1.87 | 80.1 | 11.0 | 14.98 | 41.2 | 4,720,292 (Proy.) |
| Low-income countries | 1950 | 6.48 | 31.2 | 194.2 | 350.34 | 17.6 | 112,417 |
| Low-income countries | 2023 | 4.53 | 64.9 | 43.3 | 62.18 | 17.9 | 736,466 |
| Low-income countries | 2100 | 2.03 | 75.7 | 14.0 | 19.11 | 35.0 | 2,151,930 (Proy.) |

Nota: en 2050, ingreso medio-alto (que incluye a China) tendría una edad
mediana numéricamente muy cercana a la de ingreso alto, un hallazgo que el
plan analítico anticipa (S11); confirmar la cifra exacta de 2050 queda para el
notebook de análisis.

## 5. Top / bottom 10 países en 2023 (población >= 1,000,000; n = 161)

Microestados excluidos del ranking (n = 76, todos con población 2023 < 1 millón):
COM, MYT, REU, SYC, STP, ESH, CPV, SHN, MAC, BTN, MDV, BRN, FRO, GGY, ISL, IMN,
JEY, AND, GIB, VAT, MLT, MNE, SMR, LIE, LUX, MCO, AIA, ATG, ABW, BHS, BRB, BES,
VGB, CYM, CUW, DMA, GRD, GLP, MTQ, MSR, BLM, KNA, LCA, MAF, VCT, SXM, TCA, VIR,
BLZ, FLK, GUF, GUY, SUR, BMU, GRL, SPM, FJI, NCL, SLB, VUT, GUM, KIR, MHL, FSM,
NRU, MNP, PLW, ASM, COK, PYF, NIU, WSM, TKL, TON, TUV, WLF.

### TFR (hijos por mujer)
- **Top 10 (más alta):** Somalia 6.13, Chad 6.12, Niger 6.06, DR Congo 6.05,
  Central African Rep. 6.01, Mali 5.61, Angola 5.12, Burundi 4.88,
  Afghanistan 4.84, Mozambique 4.76.
- **Bottom 10 (más baja):** Hong Kong SAR 0.72, South Korea 0.72, Taiwan 0.87,
  Puerto Rico 0.94, Singapore 0.94, Ukraine 0.98, China 1.00, Chile 1.17,
  Italy 1.20, United Arab Emirates 1.20.

### LEx (esperanza de vida al nacer, años)
- **Top 10:** Hong Kong SAR 85.5, Japan 84.7, South Korea 84.3, Switzerland
  84.0, Australia 83.9, Singapore 83.7, Italy 83.7, Spain 83.7, France 83.3,
  Norway 83.3.
- **Bottom 10:** Nigeria 54.5, Chad 55.1, Lesotho 57.4, Central African Rep.
  57.4, South Sudan 57.6, Somalia 58.8, Mali 60.4, Guinea 60.7, Benin 60.8,
  Burkina Faso 61.1.

### MedianAgePop (edad mediana, años)
- **Top 10 (más vieja):** Japan 49.0, Italy 47.5, Portugal 46.2, Hong Kong SAR
  46.2, Greece 45.7, Puerto Rico 45.3, Germany 45.1, Bosnia and Herzegovina
  44.9, Spain 44.9, Croatia 44.8.
- **Bottom 10 (más joven):** Central African Rep. 14.3, Niger 15.2, Chad 15.4,
  Somalia 15.4, Mali 15.5, DR Congo 15.8, Burundi 15.9, Mozambique 16.3,
  Angola 16.5, Uganda 16.5.

### CNMR (tasa de migración neta, por 1,000 habitantes)
- **Top 10 (más inmigración neta):** South Sudan 39.6, Syria 32.1, Oman 31.0,
  United Arab Emirates 28.2, Chad 25.7, Armenia 25.5, Lithuania 15.7, Qatar
  13.4, Bahrain 12.7, Canada 11.0.
- **Bottom 10 (más emigración neta):** Sudan −27.0, Kosovo −16.9, Greece
  −15.6, Nepal −13.8, Albania −9.0, Azerbaijan −8.2, Ukraine −8.0, Eswatini
  −7.0, Pakistan −6.5, Moldova −6.1.

  **Nota ética (ver también `docs/00_plan_analitico.md` §8):** la migración
  neta positiva más alta de 2023 ocurre en países que reciben retornos tras
  conflicto (South Sudan, Syria) y migración laboral del Golfo (Oman, UAE,
  Qatar, Bahrain), no "atracción" en el sentido convencional. No se presenta
  como un ranking de éxito.

### PopGrowthRate (tasa de crecimiento poblacional, %)
- **Top 10:** South Sudan 5.86, Chad 5.71, Syria 4.92, Oman 4.59, UAE 3.70,
  Somalia 3.56, Central African Rep. 3.41, Niger 3.31, DR Congo 3.26, Angola
  3.06.
- **Bottom 10:** Greece −2.08, Ukraine −1.55, Kosovo −1.07, Moldova −0.89,
  Albania −0.71, Belarus −0.65, Bosnia and Herzegovina −0.59, Romania −0.53,
  Bulgaria −0.52, Japan −0.48.

## 6. Migración acumulada 2000–2023 vs. crecimiento natural acumulado

**54 países** tienen migración neta acumulada 2000–2023 positiva Y mayor que
su cambio natural acumulado (es decir, su crecimiento de población en el
periodo depende más de la migración que del saldo nacimientos−muertes, o la
migración amortigua un saldo natural negativo). Los 10 mayores en volumen
absoluto de migración acumulada (miles de personas):

| País | Migración neta acum. (miles) | Cambio natural acum. (miles) |
|---|---|---|
| United States | 34,283 | 30,103 |
| Russia | 9,141 | −10,887 |
| Germany | 7,134 | −4,186 |
| United Kingdom | 6,636 | 3,340 |
| Spain | 6,577 | 429 |
| Canada | 6,328 | 2,474 |
| United Arab Emirates | 5,714 | 1,746 |
| Italy | 4,811 | −2,629 |
| Australia | 4,251 | 3,314 |
| Japan | 3,161 | −6,005 |

Nota: Rusia, Alemania, Italia y Japón tienen cambio natural **negativo**
(más muertes que nacimientos) y aun así la migración los mantiene en
crecimiento acumulado positivo en el periodo (o amortigua la caída). Lista
completa de los 54 países en el script `hechos_clave.R` (scratchpad de esta
sesión; reproducible con el bloque de la sección 5 del script, disponible a
quien lo pida).

## 7. "Tipo de palanca" en 2023 (fila a fila, ver `tipo_palanca` en `01_preparar_datos.R`)

- **Crecen pese a que mueren más de los que nacen (NatChange<0 & PopChange>0),
  entre los 237 países: 18.** Entre los que tienen >= 1 millón de habitantes: 11
  — Germany, Spain, Belgium, Hungary, Finland, Slovakia, Georgia, Puerto Rico,
  Lithuania, Slovenia, Estonia. (Los otros 7, todos microestados: Montenegro,
  Curaçao, Aruba, Jersey, Isle of Man, Guernsey, Saint Barthélemy.)
- **Decrecen pese a que nacen más de los que mueren (NatChange>0 & PopChange<0),
  entre los 237 países: 19.** Entre los que tienen >= 1 millón: 6 — Nepal,
  Azerbaijan, Uruguay, Albania, Kosovo, Mauritius. (Los otros 13 son
  territorios/microestados: Guadeloupe, Martinique, Tonga, Saint Vincent and
  the Grenadines, Greenland, American Samoa, Northern Mariana Islands,
  Marshall Islands, Saint Martin (French), Cook Islands, Wallis and Futuna,
  Tuvalu, Falkland Islands.)

## 8. Las 20 mayores caídas anuales de LEx, 1951–2023 (año a año, mundo)

| # | País | Año | Caída de LEx (años) | LEx tras la caída |
|---|---|---|---|---|
| 1 | Central African Rep. | 2009 | −35.21 | 14.7 |
| 2 | Rwanda | 1994 | −30.78 | 12.2 |
| 3 | Cambodia | 1975 | −26.51 | 12.8 |
| 4 | Somalia | 1991 | −21.48 | 25.4 |
| 5 | Central African Rep. | 2022 | −21.46 | 18.8 |
| 6 | Lebanon | 1976 | −21.31 | 36.4 |
| 7 | Central African Rep. | 2019 | −20.77 | 31.5 |
| 8 | Bosnia and Herzegovina | 1992 | −19.85 | 52.0 |
| 9 | Burundi | 1972 | −17.40 | 25.8 |
| 10 | Somalia | 2011 | −16.45 | 32.5 |
| 11 | Bangladesh | 1971 | −16.15 | 26.5 |
| 12 | Haiti | 2010 | −16.12 | 45.6 |
| 13 | Armenia | 1988 | −14.86 | 52.7 |
| 14 | Cyprus | 1974 | −14.45 | 54.6 |
| 15 | South Sudan | 1998 | −14.02 | 19.1 |
| 16 | Equatorial Guinea | 1969 | −13.85 | 31.0 |
| 17 | South Sudan | 1995 | −13.35 | 31.5 |
| 18 | Lebanon | 1982 | −13.09 | 47.2 |
| 19 | South Sudan | 2014 | −12.66 | 45.6 |
| 20 | Timor-Leste | 1975 | −12.14 | 24.3 |

Todas corresponden a episodios documentados de conflicto armado, genocidio o
crisis humanitaria aguda (guerra civil en CAR 2009/2019/2022, genocidio de
Ruanda 1994, Jemer Rojo en Camboya 1975, guerra civil de Somalia 1991/2011,
guerra civil libanesa 1975-76/1982, guerra de independencia de Bangladesh
1971, terremoto de Haití 2010, guerra de Nagorno-Karabaj/Armenia 1988,
invasión turca de Chipre 1974, guerra civil de Sudán del Sur, guerra civil de
Guinea Ecuatorial 1969, invasión de Indonesia a Timor Oriental 1975). Se citan
con el mismo respeto con el que la ONU las documenta (ver lineamiento ético
ASA, principio D).

## 9. Población decreciente

- **2023: 54 países** con `PopGrowthRate < 0` (lista completa en el script;
  los 10 con mayor caída: Saint Martin −5.40%, Cook Islands −3.59%, Marshall
  Islands −3.32%, Northern Mariana Islands −2.10%, **Greece −2.08%**, Holy See
  −1.82%, Tuvalu −1.80%, American Samoa −1.60%, Saint Helena −1.12%,
  **Ukraine −1.55%**).
- **2050 (Proyección Medium): 98 países.**
- **2100 (Proyección Medium): 162 países** (más de dos tercios de los 237).

## 10. Correlaciones de Spearman entre países, 2023 (población >= 1 millón, n = 161)

|  | TFR | LEx | IMR | MedianAgePop | CNMR | PopGrowthRate |
|---|---|---|---|---|---|---|
| **TFR** | 1.000 | −0.840 | 0.874 | −0.932 | −0.248 | 0.812 |
| **LEx** | −0.840 | 1.000 | −0.930 | 0.861 | 0.397 | −0.605 |
| **IMR** | 0.874 | −0.930 | 1.000 | −0.913 | −0.387 | 0.692 |
| **MedianAgePop** | −0.932 | 0.861 | −0.913 | 1.000 | 0.312 | −0.833 |
| **CNMR** | −0.248 | 0.397 | −0.387 | 0.312 | 1.000 | 0.155 |
| **PopGrowthRate** | 0.812 | −0.605 | 0.692 | −0.833 | 0.155 | 1.000 |

Lectura: TFR, LEx, IMR y MedianAgePop están fuertemente correlacionados entre
sí (|ρ| > 0.84, como es de esperar del mismo proceso de transición
demográfica); la migración (CNMR) es casi independiente de todo lo demás
(|ρ| <= 0.40), lo que respalda tratarla como una "palanca" separada en Q1/Q2
del plan analítico.

## 11. Participación de la migración en el crecimiento 2000–2023, por grupo de ingreso

**Dos formas de calcularlo, con resultados distintos — discrepancia
documentada:**

**(a) Sumando países con la clasificación de ingreso FY2027 actual (recomendado
para H1 del plan analítico, porque aplica un criterio homogéneo y verificable
a todos los países):**

| Grupo de ingreso | Migración acum. (miles) | Cambio natural acum. (miles) | Cambio total (miles) | % del cambio por migración |
|---|---|---|---|---|
| High income | 118,184 | 49,018 | 167,202 | **70.7%** |
| Upper middle income | −24,723 | 560,766 | 536,043 | −4.6% |
| Lower middle income | −80,234 | 1,015,225 | 934,992 | −8.6% |
| Low income | −13,132 | 370,265 | 357,134 | −3.7% |

Para 2010–2023: High income = **77.5%** (migración 70,990 / cambio total
91,553 miles).

**(b) Usando los agregados "Income group" que ya trae el archivo de la ONU**
(coherentes entre sí, pero con una clasificación de ingreso de otra vintage,
ver abajo):

| Grupo de ingreso (agregado ONU) | % del cambio 2000-23 por migración |
|---|---|
| High-income countries | 64.0% |
| Upper-middle-income countries | −2.0% |
| Lower-middle-income countries | −8.0% |
| Low-income countries | −3.6% |

**Por qué difieren (70.7% vs 64.0%):** el agregado "Income group" que trae el
archivo de la ONU fue construido con una clasificación de ingreso de un año
distinto al de nuestra unión (API del Banco Mundial, FY2027, descargada
2026-10-22); algunos países cambiaron de grupo entre esa vintage y la
clasificación FY2027 (p. ej. países que subieron a "alto ingreso" en los
últimos años quedan en nuestra versión dentro de "High income" para **todo**
2000-2023, inflando algo su peso frente al agregado histórico de la ONU). Esta
es exactamente la limitación que ya anticipa `docs/00_plan_analitico.md` §3
("un país puede haber cambiado de grupo... se declara en limitaciones"); se
recomienda citar **70.7%** (coherente con la cifra pre-chequeo de 71% del plan
analítico) y mencionar el rango 64–78% según el método y el periodo.

## 12. Colombia

| Año | TFR | LEx | CNMR | Tipo |
|---|---|---|---|---|
| 1950 | 6.41 | 48.3 | −3.00 | Estimación |
| 2000 | 2.57 | 70.9 | −0.71 | Estimación |
| 2023 | 1.65 | 77.7 | **+2.95** | Estimación |

Colombia pasó de emisor neto de migrantes (CNMR negativo en 1950 y 2000) a
receptor neto en 2023, principalmente por la migración venezolana.

**Pico migratorio 2015–2023:**

| Año | NetMigrations (miles) | CNMR |
|---|---|---|
| 2015 | −41.1 | −0.88 |
| 2016 | 104.0 | 2.20 |
| **2017** | **431.3** | **8.96** |
| **2018** | **495.5** | **10.11** |
| 2019 | 397.1 | 7.95 |
| 2020 | 227.0 | 4.49 |
| 2021 | 198.8 | 3.89 |
| 2022 | 182.7 | 3.54 |
| 2023 | 155.3 | 2.95 |

**El pico migratorio de Colombia en el periodo 2015-2023 fue en 2018**
(495,524 personas netas, CNMR = 10.11 por 1,000), coincidiendo con el momento
más agudo del éxodo venezolano hacia Colombia; desde entonces la migración
neta se desacelera año a año pero sigue siendo positiva y alta en 2023.

---

## Notas metodológicas generales

- Todas las cifras de 2023 o anteriores son **estimaciones** (datos
  observados/modelados por la ONU con información demográfica real); las de
  2050/2084/2100 son **proyecciones** de la variante Medium (un escenario con
  supuestos de convergencia de fecundidad y migración suavizada — ver
  limitación S13 en `docs/00_plan_analitico.md`).
- Los rankings de la sección 5 excluyen microestados (< 1 millón de
  habitantes en 2023) porque un cambio pequeño en términos absolutos se
  vuelve una tasa extrema (ver también la nota sobre `PopGrowthRate` vs
  `(NatChangeRT+CNMR)/10` en `R/01_preparar_datos.R`, donde el mismo problema
  de denominador pequeño se cuantifica: error mediano ~0.0004 puntos
  porcentuales, máximo 0.32 pp, siempre en microestados).
- Todas las cifras se recalcularon en esta sesión contra los parquet
  generados por `R/01_preparar_datos.R` (que ya pasaron `R/tests_datos.R`);
  no se copiaron del EDA previo ni del plan analítico sin verificar — donde
  coinciden con las cifras "provisionales" del plan analítico (p. ej. el 71%
  de H1, o el pico mundial en 2084/10.29 mil millones) se indica como
  confirmación cruzada.
