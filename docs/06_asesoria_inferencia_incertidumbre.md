# 06 — Asesoría de INFERENCIA, INCERTIDUMBRE y SUPERVIVENCIA

> Asesor: inferencia estadística, cuantificación de incertidumbre y análisis de tiempo hasta el evento · Fecha: 2026-10-22 · Alcance: todas las cifras del guion, P2/P3 (OtherVariants) como nota de incertidumbre, P7 (rezago mortalidad → fecundidad).
> Datos: `WPP2024_Demographic_Indicators_Medium_csv.gz` y `..._OtherVariants_csv.gz` (países = `ISO3_code` no vacío; 237; **161 ≥ 1 M en 2023**; solo estimaciones ≤ 2023 salvo que se diga «proyección»), ingreso `data/raw/wb_api_income_2026-10-22.csv` (**FY2027**).
> Scripts (R 4.6.1, `set.seed(2026)` al inicio de cada uno): `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/incertidumbre/` (`00_datos.R` … `42_figura_cifras.R`). Todas las cifras son **prototipos**: `notebook-R` debe recalcularlas y pasarlas a `figures/numbers.json`.

---

## 0. Resumen (1 minuto)

1. **La premisa «la migración se proyecta de forma determinista» no es cierta en WPP2024.** Por primera vez la migración neta se proyecta con un modelo probabilístico (`bayesMig`, 2 000 trayectorias; *Methodology* §II.E.1), y los IP 80/95 % la incluyen. Lo que sí importa: (a) las variantes **High/Low/Constant fertility dejan la migración fija** en su camino Medium; (b) los IP **no incluyen la incertidumbre de la población base ni de la migración pasada** (*"do not consider the uncertainty in the baseline population or mortality and migration rates"*); (c) para el Golfo, la ONU recorta las trayectorias con topes fijados por expertos. Toda cifra migratoria ≤ 2023 (p. ej. el 71 %) **no tiene ningún intervalo de la ONU**.
2. **El intervalo más llamativo**: EAU 2050 = 15,4 M, con un IP 95 % de **8,9 a 33,3 M**; en 2100, de **2,3 a 77,4 M** (el límite superior es 33 veces el inferior). Mundo 2100: 10,18 mil M [9,05; 11,44].
3. **La dirección es incierta en casi la mitad de los países**: en **77 de 161** países ≥ 1 M, el IP 95 % de 2050 incluye a la vez crecer y decrecer respecto a 2023 (EE. UU., Brasil, Rusia, Alemania, Reino Unido, Francia, Colombia…). En 2100, en 110 de 161.
4. **Ni siquiera el signo de la migración futura se conoce**: el IP 80 % de la tasa neta de migración de 2050 contiene el 0 en **155 de 161** países.
5. **High/Low no son intervalos**: en los 161 países, el rango Low–High de 2050 es **más estrecho** que el IP 95 %; para el mundo es **más ancho** (2100: 7,0–14,4 mil M frente a 9,05–11,44). No llamarlos nunca «range of uncertainty».
6. **Columnas de OtherVariants que NO son intervalos válidos**: `MedianAgePop` (límites invertidos en el 90 % de las filas), `LE15/LE65/LE80`, `Q5` y `Q0040…Q1560` en las filas PI. Sí son válidos: población, TFR, LEx, CNMR, NetMigrations, CBR, CDR, IMR, nacimientos y defunciones. El memo de ética propone un IP de la edad mediana de China: **no se puede sacar de este archivo**.
7. **P7 con supervivencia**: en **92 de 109** países con fecundidad alta en 1950, la mortalidad infantil **ya caía cuando empiezan los datos**, así que el inicio de su caída está censurado por la izquierda y el rezago, por la derecha. Con la censura bien codificada, la **mediana del rezago no se puede identificar**; los «22 años» del memo de series de tiempo son una **cota inferior** (IC bootstrap 20–25). Lo que sí se identifica es el **orden** (mortalidad primero en 105 de 108 = 97 %, Wilson [92; 99]) y el **año de inicio de la caída de la fecundidad** por ingreso: **1970** (medio-alto), **1984** (medio-bajo), **2000** (bajo), log-rank χ² = 73,4 (3 gl).
8. **Nuestras decisiones mueven las cifras más que el remuestreo** en conteos, umbrales y PCA: «crecen solo por migración» va de **15 a 25** según el año (de 5 a 18 en ≥ 1 M); «mortalidad primero» con umbrales fijos va del 16 % al 100 % según el par de umbrales; el PC1 tiene un IC bootstrap de ±2 puntos pero varía entre 46 % y 77 % según las variables.
9. **Correcciones de cifras del storyboard §7**: `r2_tfr_cnmr` = **0,005** (no 0,06; en validación cruzada < 0); `rho_cdr_lex_2023` = 0,07 **[−0,08; 0,20]**, es decir, «about zero»; `share_mig_high_2000_2023` = 70,7 % con IC BCa **[56; 114]**, y solo quitar a EE. UU. lo sube al 82 %.

---

## 1. Evaluación del plan y del storyboard desde inferencia e incertidumbre

### 1.1 Lo que está bien (mantener)
- **Plan §3 «Estimaciones vs proyecciones»** y **§8-B/C** («sin valores p decorativos», «múltiples comparaciones declaradas»): es la base correcta. Falta el mecanismo (ver §4 y §7).
- **Plan §4-Q1 Rico 2 y Q2 Simple 3**: bootstrap **de países** (no de años) para las correlaciones transversales. Correcto: la unidad de remuestreo es el país.
- **Plan §4-Q2 Simple 1**: validación cruzada 10-fold con semilla y aviso de «partly by construction» para el cambio 2023 → 2050. Lo confirmo: el R² de 0,88 baja a 0,879 en VC (no hay sobreajuste; el problema es de construcción, no de varianza).
- **Plan §3 «Microestados»**: repetir con los 237 es la sensibilidad correcta; aquí cambia mucho (R² del crecimiento 0,59 → 0,36).
- **Memo de ética §2.2 #7**: pedir los IP 80/95 % de la ONU es el diferenciador correcto. Sus cifras ✔ coinciden con las mías (EAU, Nigeria, Japón, Mundo).

### 1.2 Lo que es incorrecto o débil

| Dónde | Qué dice | Problema | Evidencia (datos reales) |
|---|---|---|---|
| Plan §2: «P2/P3 no entran en el vídeo… apéndice con el intervalo 80/95 %» | La incertidumbre queda en un apéndice | Contradice al memo de ética y a la receta ganadora («incertidumbre visible al menos una vez») | Una banda + una frase caben en el build 4 de la Slide 4 (§5). |
| Encargo y memo de ética §2.2 #7 | «Migración sin intervalo probabilístico» / «Medium = media» | En WPP2024 la migración **sí** es probabilística; la Medium es la **media** para TFR y LEx, pero la **mediana** para la migración (*Methodology* §II.F) | `Mean` solo existe para TFR, LExMale, LExFemale. La fila `Median PI` de población coincide con la Medium en los 237 países (diferencia máxima < 0,2 %; solo difiere en agregados *ad hoc*). |
| Memo de ética §2.2 #7(a,b) y E39 | «95 % PI for China median age» | El archivo **no trae un IP válido para la edad mediana** | China 2050: «Lower 95» = 52,9 > «Median» = 52,1 > «Upper 95» = 51,2; orden invertido en el 90 % de las filas; LE65 en las filas PI vale 44–55 (la Medium es 21,1); `Q5` vale 569 (la Medium es 3,5). |
| Storyboard §1 y §7 (`n_grow_only_migration_2023` = 18) | «18 grow only because people move in» | Conteo frágil: depende del año | 237 países: 15 (2021), 25 (2022), 18 (2023), 24 (promedio 2021–23); ≥ 1 M: 5 / 18 / 11 / 14. **28 países** cambian de tipo entre «2023» y «2021–23». |
| Plan §4-Q1 Rico 1, H3; storyboard Slide 2 build 2 | «Mediana 11 años; mortalidad primero en 80 %» (o «≥ 22» según el memo de series) | La mediana del rezago **no está identificada**: 92 de 109 orígenes censurados por la izquierda | Turnbull con todas las censuras: 13 rezagos exactos, 84 censurados por la derecha, 3 por la izquierda y 9 sin información; el 64 % de la masa queda más allá del último tiempo observado. |
| Storyboard §7 `share_mig_high_2000_2023` | «71 %» como cifra exacta | Cociente de sumas dominado por un país | BCa [55,8; 114,0]; jackknife 64,5–81,6 (EE. UU.); ≥ 1 M 71,1; 2010–23 77,5; sin el Golfo 75,0. |
| Storyboard §7 `r2_tfr_cnmr` ≈ 0,06 | «almost nothing of migration» | El valor es 0,005 (y negativo fuera de muestra) | BCa [0; 0,041]; VC 10-fold × 20 = −0,023. La frase es correcta; la cifra no. |
| Storyboard §7 `rho_cdr_lex_2023` = +0,06 | Se narraría como un número | Su IC incluye el 0 | 0,07 [−0,08; 0,20]; en 1950 −0,97 [−0,98; −0,96]. Decir «no longer related». |
| Storyboard §5 (Slide 4) «median age 45 by 2050», «fast movers will age faster» | Proyección sin incertidumbre | No hay IP válido de la edad mediana; la de grupos no se puede construir sumando IP | Usar «projected (UN medium)» y dar el IP de la **población** de un país del grupo. |
| Plan §4-Q1 Rico 2 / Q2-Rico 1: «bootstrap B = 500» | Pocas réplicas para BCa | BCa necesita ≥ 1 000–2 000 réplicas para estabilizar los cuantiles extremos | Con B = 2 000 y 4 semillas, el límite inferior del IC del 71 % varía < 1 punto (55,8–56,4) y el superior ≈ 5 puntos (112–117): por eso se guarda la semilla. |
| Plan §5 (H1–H14) y §8-A | «Hipótesis declaradas antes» | Salieron de un EDA **con los mismos datos**: son *pre-specified*, no confirmatorias | Ver §4: etiquetado y familias de contraste. |

### 1.3 Lo que falta
- **Un campo de incertidumbre en cada clave de `numbers.json`**: hoy el esquema (plan de implementación §4) no tiene dónde guardar IC, método, B ni semilla.
- **Distinguir censo de muestra**: los 237 países son la población. Un bootstrap de países mide **sensibilidad a la composición del conjunto**, no error muestral. Los conteos no llevan IC, solo rango entre definiciones.
- **Un test automático de validez de los IP** al leer OtherVariants (monotonía L95 ≤ L80 ≤ Med ≤ U80 ≤ U95) que impida usar las columnas rotas.
- **Contar las comparaciones** y declarar qué es exploratorio (§4).

---

## 2. Métodos recomendados, por tipo de cifra

| Tipo de cifra (clave) | Método | Supuestos y cuidados | `method` en `numbers.json` | Frase en inglés |
|---|---|---|---|---|
| Conteos de países por tipo de palanca, bajo reemplazo (`n_type_*`, `n_below_replacement_2023`) | **Sin IC** (es un censo). **Rango entre definiciones**: 2021, 2022, 2023 y promedio 2021–23; umbral TFR 2,0 / 2,1 / 2,2; países a < 0,5 ‰ de la frontera | Fijar una definición principal (promedio 2021–23) y reportar el rango | `none_census` + `sens_low/high` | *"About two dozen countries — 15 to 25, depending on the year we look at."* |
| Proporciones sobre países (`share_mort_first`, `share_rank_shift_20`) | **Wilson 95 %** (`prop.test(x, n, correct = FALSE)`) | Interpretación de superpoblación («transiciones posibles»); no usar con n < 10 | `wilson` | *"In 105 of 108 countries — about 97 in every 100."* |
| Participación de la migración en el crecimiento por ingreso (`share_mig_*`) | **Bootstrap de países dentro del grupo** (cociente de sumas), **BCa**, B = 2 000, semilla 2026 + **jackknife** (influencia de cada país) | El cociente explota si ΣPopChange ≈ 0; con un país dominante (EE. UU.), el IC es asimétrico → BCa, no percentil ni normal | `bootstrap_bca` | *"About seven in ten — and one country, the US, moves that share by ten points."* |
| R² y correlaciones transversales (`r2_tfr_*`, `rho_*`) | **Bootstrap de países, BCa** (B = 2 000) + **VC 10-fold repetida** para R² | R² está sesgado hacia arriba en n pequeño; reportar también el R² fuera de muestra | `bootstrap_bca` (+ `cv_r2`) | *"Fertility alone explains about three quarters of the differences in age — between 73 and 81 percent in 95 of 100 resamples of countries."* |
| Rezagos y «años hasta» (`lag_*`, `yr_fert_onset_*`) | **Kaplan–Meier** con censura derecha; censura izquierda del origen → censura derecha del rezago; **Turnbull** (`Surv(type = "interval2")`) cuando hay ambas; IC de la mediana de Brookmeyer–Crowley (por defecto en `survfit`); **log-rank** para grupos | Censura no informativa (falla en parte: los que aún no cruzan son los de ingreso bajo, pero eso es justo lo que KM corrige frente a eliminarlos) | `km` / `turnbull` | *"Countries that had not yet started are counted, not dropped."* |
| Varianza explicada del PCA (`pc1_var`) | **Bootstrap percentil** (B = 1 000) **y** rango entre conjuntos de variables | El autovalor bootstrap está algo sesgado hacia arriba; el rango por decisiones domina | `bootstrap_perc` + `sens_*` | *"About half — more or less depending on which indicators we include."* |
| Tamaños de clúster (`cluster_sizes`) | Bootstrap con re-ajuste y emparejamiento por Jaccard (ya hecho en el memo multivariado: 0,80–0,95); reportar el **rango de tamaños** entre réplicas | Sin p-valores sobre las variables que formaron los grupos | `bootstrap_perc` | *"Groups are stable in 8 of 10 resamples; sizes vary by a few countries."* |
| Proyecciones (`pop_2050_*`, `pop_2100_*`) | **IP 80/95 % de la ONU** tal cual (no recalcularlos); variantes deterministas como **escenarios**, no intervalos | Marginales por país e indicador: **no se suman**; no incluyen incertidumbre de la base | `un_pi` | *"The UN's own 95% range runs from A to B."* |

**Reglas comunes**: (i) unidad de remuestreo = país (nunca país-año); (ii) `set.seed(2026)` justo antes de cada `boot()` y B en el JSON; (iii) si BCa falla (aceleración no estimable), usar percentil y decirlo en `method`; (iv) en el notebook, cada IC va con su frase de interpretación: *"if the set of countries had been slightly different"*; (v) los análisis con años proyectados no llevan IC bootstrap (son un escenario).

---

## 3. Resultados preliminares (datos reales)

### 3.1 Conteos por tipo de palanca: rango entre definiciones (censo, sin IC)

| Definición | A (nat. +, mig. +) | B (nat. +, mig. −, crece) | **C (crece solo por migración)** | D (decrece, muertes > nacim.) | E (decrece por emigración) |
|---|---|---|---|---|---|
| 2021 · 237 / ≥ 1 M | 76 / 54 | 86 / 68 | **15 / 5** | 43 / 29 | 17 / 5 |
| 2022 | 79 / 50 | 85 / 69 | **25 / 18** | 32 / 21 | 16 / 3 |
| 2023 | 77 / 49 | 88 / 71 | **18 / 11** | 35 / 24 | 19 / 6 |
| **Promedio 2021–23 (recomendado)** | 77 / 52 | 88 / 70 | **24 / 14** | 31 / 22 | 17 / 3 |

173 de 237 países tienen el mismo tipo en los cuatro cortes. TFR < 2,1 = 130; hay 14 países con TFR entre 2,0 y 2,2, así que el conteo va de 124 (umbral 2,0) a 138 (umbral 2,2). TFR < 2,1 con saldo natural positivo = 79.

### 3.2 Participación de la migración en el crecimiento 2000–2023 por ingreso (bootstrap de países, B = 2 000)

| Grupo (FY2027) | n | Estimación | IC 95 % BCa | Jackknife (mín.–máx.) | País más influyente |
|---|---|---|---|---|---|
| Ingreso bajo | 25 | −3,7 % | [−7,7; −1,1] | −4,7 … −2,9 | Etiopía |
| Medio-bajo | 47 | −8,6 % | [−20,3; −3,6] | −12,8 … −6,5 | India |
| Medio-alto | 59 | −4,6 % | **[−11,1; +1,0]** | −5,6 … −3,4 | Ucrania |
| **Alto** | 85 | **70,7 %** | **[55,8; 114,0]** | 64,5 … 81,6 | **EE. UU.** |

Sensibilidad del grupo alto: ≥ 1 M 71,1 %; 2010–23 77,5 %; sin EE. UU. 81,6 %; sin los seis del Golfo 75,0 %. Lectura: el mensaje «en ingreso alto el crecimiento viene sobre todo de la migración» es robusto; la cifra exacta no (un límite superior > 100 % significa que, sin EE. UU., el saldo natural del grupo es negativo). En ingreso medio-alto el signo es incierto.

### 3.3 «Qué explica la fecundidad sola» (2023, 161 países ≥ 1 M)

| Resultado ~ TFR | R² | IC 95 % BCa | R² fuera de muestra (VC 10 × 20) | Con los 237 |
|---|---|---|---|---|
| Edad mediana | 0,773 | [0,733; 0,809] | 0,766 | 0,715 |
| Cambio 2023 → 2050 (proyección) | 0,882 | [0,826; 0,911] | 0,879 | — |
| Crecimiento actual | 0,592 | [0,436; 0,710] | 0,582 | **0,360** |
| Migración neta (CNMR) | **0,005** | [0; 0,041] | **−0,023** | 0,017 |

Spearman ρ(CDR, LEx): 1950 = −0,97 [−0,98; −0,96]; 2023 = **0,07 [−0,08; 0,20]**. PCA de 12 variables: PC1 = **56,7 %** (bootstrap percentil, B = 1 000: [54,9; 59,1]); con los 237 países 53,7 %; con 8 indicadores del núcleo de la transición 76,6 %; el memo multivariado da 46–66 % con otros conjuntos. El IC de remuestreo (±2 puntos) es diez veces más estrecho que el rango por decisiones (46–77 %).

### 3.4 Proyecciones ONU: población (millones; mundo en miles de millones)

| País | 2023 | 2050 Medium [IP 80] [IP 95] | 2050 Low / High · Zero mig. · Const. fert. | 2100 Medium [IP 95] | 2100 Zero mig. · Const. fert. |
|---|---|---|---|---|---|
| Mundo | 8,09 | 9,66 [9,49–9,82] [9,42–9,90] | 8,94 / 10,40 · 9,66 · 10,17 | 10,18 [9,05–11,44] | 10,10 · 18,19 |
| **EAU** | 10,6 | **15,4 [10,1–26,1] [8,9–33,3]** | 14,0 / 16,8 · 12,4 · 15,0 | **26,1 [2,3–77,4]** | 6,9 · 23,2 |
| Nigeria | 228 | 359 [313–419] [294–452] | 332 / 386 · 354 · 427 | 477 [256–1 142] | 442 · 1 400 |
| Níger | 26,2 | 52,5 [45,3–60,0] [41,6–64,2] | 49,0 / 56,1 · 53,3 · 67,1 | 90,8 [46,1–202] | 94,9 · 415 |
| China | 1 423 | 1 260 [1 194–1 323] [1 159–1 354] | 1 173 / 1 348 · 1 268 · 1 235 | 633 [404–890] | 659 · 526 |
| Alemania | 84,5 | 78,3 [71,4–85,6] [68,1–90,1] | 73,2 / 83,4 · 73,4 · 77,6 | 70,9 [43,3–111] | 50,1 · 66,1 |
| Colombia | 52,3 | 59,4 [53,5–66,4] [50,1–71,4] | 54,9 / 64,0 · 57,8 · 60,0 | 47,1 [20,1–103] | 45,5 · 48,7 |
| Corea del Sur | 51,7 | 45,1 [40,1–50,9] [37,5–54,9] | 42,1 / 48,2 · 43,9 · 44,0 | 21,8 [9,3–52,0] | 18,4 · 17,0 |
| Japón | 124 | 105 [99,5–111] [96,4–115] | 98,3 / 112 · 100 · 104 | 76,8 [47,8–113] | 59,4 · 68,6 |

Otros hechos (161 países ≥ 1 M): razón U95/L95 de 2050 mediana 1,52, máxima en Kuwait (4,35), Qatar (4,07) y EAU (3,74); dirección 2050 vs 2023 con IP 95 %: 17 decrecen seguro, **77 inciertos**, 67 crecen seguro (con IP 80 %: 26 / 47 / 88); CNMR 2050: IP 80 % contiene el 0 en **155**, IP 95 % en los 161. TFR 2050 de Nigeria: Medium 2,66 (media), IP 95 % [1,54; 4,36].

**Migración, en una frase (corregida)**: *la ONU ya proyecta la migración con trayectorias aleatorias, pero sus variantes alternativas la dejan fija, sus intervalos no cubren el error de las estimaciones pasadas y en el Golfo están acotados por topes de expertos; por eso nuestras conclusiones sobre migración describen el pasado estimado y nunca deben leerse como pronóstico.* Consecuencia para el guion: «18/24 países crecen solo por migración» y «71 %» son cifras **sin intervalo oficial** y con el componente peor medido; el lenguaje debe ser «UN estimates show…», y la frase de ética debe nombrar la migración como «the least certain lever».

### 3.5 P7 como tiempo hasta el evento

**Formalización.** Para cada país *i*: T_q = año de inicio de la caída sostenida de Q5 (regla de Princeton: 10 % bajo su máximo, sin volver); T_f = ídem para la TFR; rezago D = T_f − T_q. Elegibles: ≥ 1 M, TFR₁₉₅₀ ≥ 5, ingreso clasificado (n = 109).
- **Censura izquierda del evento**: si la serie ya cae en 1950 (máximo en 1950), el inicio real es ≤ al observado. Para Q5 pasa en **92 de 109** países; para la TFR en 12.
- **Censura derecha**: la TFR no ha iniciado en 2023 (Rep. Centroafricana y R. D. del Congo).
- **Traducción al rezago**: origen censurado por la izquierda ⇒ D ≥ observado (censura **derecha** del rezago); fin censurado por la izquierda ⇒ D ≤ observado (censura izquierda); ambos ⇒ sin información. Con todo codificado: 13 exactos, 84 «≥», 3 «≤», 9 sin información.

| Resultado | Valor | Método |
|---|---|---|
| Mortalidad cae primero | 105 de 108 (97 %), Wilson [92; 99] | proporción |
| Mediana del rezago con todas las censuras | **no identificable** (64 % de la masa más allá del último tiempo observado) | Turnbull |
| Cota inferior de la mediana del rezago | **≥ 22 años** (bootstrap de esa cota [20; 25]) | KM ingenuo = cota inferior |
| Año mediano de inicio de la caída de la fecundidad, por ingreso (FY2027) | bajo **2000** [1995; 2007] · medio-bajo **1984** [1982; 1987] · medio-alto **1970** [1968; 1975] · alto **1970** [1965; —] | KM (censura derecha en 2023) |
| ¿Difieren los grupos? | log-rank χ² = 73,4, 3 gl (p ≈ 8 × 10⁻¹⁶); Cox con ingreso como escalón: HR 2,37 [1,93; 2,92] por escalón | log-rank / Cox |
| Por región (año mediano de inicio TFR) | Europa y N. América 1959 · LAC 1970 · E/SE Asia 1974 · C/S Asia 1977 · N. África y Asia Occ. 1980 · África subsahariana 1995 | KM |
| **Umbrales fijos** (Q5 < 100, TFR < 4), rezago con censura (n = 131; 105 eventos) | mediana **11 años [8; 15]**; bajo 21 [13; —], medio-bajo 14 [9; 21], medio-alto 4 [0; 10], alto 13,5 [0; 22] | KM |
| Umbrales fijos, solo «ambos cruces después de 1950» (definición del plan) | mortalidad primero 71/89 = 80 %, Wilson [70; 87]; en la rejilla de 20 pares de umbrales, del **16 % al 100 %** | proporción |

**Comparación y recomendación.** El enfoque de umbrales fijos responde a «¿cuándo se cruza un nivel?», que es otra pregunta (los países que empiezan con Q5 más baja cruzan antes) y cambia de signo según el par elegido; además, la definición del plan descarta en silencio a quien ya estaba por debajo en 1950 (sesgo de supervivencia). El enfoque de inicios responde a la pregunta de P7, pero los datos **solo identifican el orden y una cota inferior**. **Reportar**: (1) el orden con su intervalo de Wilson; (2) el **año de inicio de la caída de la fecundidad por ingreso** con KM y log-rank en el notebook (es el gradiente de P7 bien identificado); (3) el rezago solo como «at least 22 years»; (4) los umbrales fijos como sensibilidad en el notebook (fig. inc04, fila B). Lenguaje: «countries that are low-income today»; el ingreso actual es en parte consecuencia de la transición (causalidad inversa), así que el gradiente es descriptivo.

### 3.6 Figuras guardadas (revisadas una a una) — `docs/asesoria_figs/incertidumbre/`
1. **`inc01_fan_uae.png`** — **candidata para la Slide 4 (build 4, franja de ética) o la Slide 1 (zoom al Golfo)**. Población de EAU 1950–2100: estimación en negro hasta 2023, línea vertical 2023/24, Medium en azul con bandas 80/95 %, línea naranja punteada «if net migration were zero». Anotación 2050: 15,4 M (8,9–33,3). El IP crece de forma muy asimétrica hacia arriba; el escenario sin migración cae a 6,9 M en 2100.
2. **`inc02_fan_small_multiples.png`** — notebook/apéndice. Nueve paneles (Mundo + 8 países), índice 2023 = 100 en escala log común: la banda del mundo es casi una línea; EAU, Nigeria, Níger, Corea y Colombia tienen las bandas más anchas; China y Japón, estrechas pero claramente descendentes.
3. **`inc03_direction_2050.png`** — candidata para Q3/recomendaciones o el notebook. 161 barras de IP 95 % del cambio 2023 → 2050, ordenadas: 17 naranjas (decrecen seguro: Japón, China…), 77 grises (dirección incierta: EE. UU., Brasil, Rusia, Alemania…), 67 azules (crecen seguro: Nigeria, Níger…).
4. **`inc04_km_two_definitions.png`** — notebook (P7); la fila A puede sustituir al dumbbell de la Slide 2. Curvas KM «proporción de países que ya empezaron» de mortalidad (naranja) y fecundidad (azul) por ingreso; flechas en el 50 % con «gap ≥ 41 / 27 / 15 / 16 años» (A, inicios) y «6 / 10 años» (B, umbrales; ingreso bajo: la fecundidad no llega al 50 % en 2023; ingreso alto: ambos antes de 1950, no identificable).
5. **`inc05_resampling_vs_choices.png`** — notebook (sección de métodos/ética) y QA-stats. Para 10 cifras del guion: punto = estimación; barra azul = IC de remuestreo; barra naranja ancha = rango entre decisiones razonables. Las barras naranjas dominan en conteos, umbrales y PCA; la azul domina en el 71 %.

---

## 4. Comparaciones múltiples: exploratorio vs *pre-specified*

**Inventario de contrastes implícitos** (storyboard actual + plan):

| Bloque | Contrastes implícitos | Comentario |
|---|---|---|
| Slide 1: participación migratoria por 4 grupos de ingreso; 5 tipos de palanca; 2 ejemplos por zoom | ≈ 6 (alto vs resto, 3 pares) | Descriptivo; IC en el notebook |
| Slide 2: velocidad por 3–4 regiones; rezago global + 4 ingresos + 5 regiones; 3 β | ≈ 25 (6 pares de ingreso + 10 de región + 3 β + velocidades) | Un log-rank por factor sustituye a los pares |
| Slide 3: 4 R² («lento» vs «rápido»); gemelos; PC1/PC2/n PCs; índice (α, % > 20 puestos) | ≈ 10 + **selección de gemelos entre 12 880 pares** | Los gemelos son extremos por construcción: ilustración, nunca inferencia |
| Slide 4: k entre 2–8; 4 tamaños; 3 cambios de DE; silueta | ≈ 12 | k elegido con los datos: decirlo |
| Plan (notebook): H1–H14; rejilla de umbrales (20); heatmap de acoplamiento (≈ 5 pares × 5 grupos × 151 años ≈ 3 800 correlaciones); sensibilidades (2–5 por hipótesis) | **14 hipótesis**, ≈ 60 sensibilidades, ≈ 3 800 celdas | El heatmap ya está fuera del vídeo |

**Reglas**
1. **Vídeo y diapositivas: cero p-valores y cero «significant».** Cada cifra se narra como descripción; la incertidumbre se comunica con rangos (§5).
2. **Etiquetas** en cada sección del notebook y en `numbers.json` (`status`): **`exploratory`** (por defecto: gemelos, clústeres, PCA, índice, heatmap) o **`pre-specified`** (H1–H14). Texto: *"Pre-specified on 25 Oct 2026 in docs/hipotesis_H1_H14.md (commit {hash}); formulated after an exploratory analysis of the same data, so these are not independent confirmations."* No usar «pre-registered» ni «confirmatory»: no hay registro externo y el EDA previo usó los mismos datos (ASA B.3, C.3).
3. **Familia 1 = H1–H14** (14 contrastes): estimación + IC 95 % siempre; si se da p-valor, **Holm** (controla la probabilidad de un falso positivo en la familia) y se reporta `p_adj`. **Familia 2 = rejillas** (umbrales, correlaciones región × ingreso, años del heatmap): **Benjamini–Hochberg** al 10 % si alguien quiere marcar celdas; mejor, mostrar la distribución completa sin marcar nada. **Familia 3 = exploratorio**: sin inferencia; «chosen by rule from N candidates» (gemelos: N = 12 880 pares).
4. **Un contraste global por factor** en lugar de pares (log-rank de 4 grupos, no 6 comparaciones), y un **IC de la diferencia** solo para el par que se narra.
5. **Clave nueva `n_tests`** en `numbers.json` (número de contrastes por familia) y una tabla «What we tested» en el notebook con todos, incluidos los que fallan (H5 ya cambió de signo con ≥ 1 M: memo de series de tiempo).

---

## 5. Comunicar la incertidumbre en 5 minutos

**Tres reglas prácticas**
1. **Una banda, una frase.** La incertidumbre se *ve* una vez (fan chart de EAU, dos bandas y la línea Medium, 2023 marcado) y se *dice* una vez. Nunca una tabla de intervalos en pantalla; los IC viven en el notebook.
2. **«About X — between A and B», con la fuente de la incertidumbre nombrada**: *"in the UN's 95% range"* (proyecciones), *"in 95 of 100 resamples of countries"* (bootstrap), *"depending on the year we pick"* (definiciones), *"at least"* (censura). Redondear siempre (sin decimales en la voz).
3. **Si la incertidumbre cambia la conclusión, se dice la conclusión débil.** «Direction uncertain» (77 de 161), «about zero» (CDR–LEx), «at least 22 years» (rezago) son hallazgos, no fallos.

**Párrafo para el guion (inglés, ≈ 75 palabras; sustituye o amplía la línea de ética de la Slide 4):**
> Every number here carries its uncertainty. The UN's own range for the Emirates in 2050 runs from nine to thirty-three million people, because migration is the least certain lever: for 155 of 161 countries, the UN's likely range for 2050 includes both more arrivals and more departures. Our own choices matter too, so we say so: about two dozen countries grow only through migration — fifteen to twenty-five, depending on the year.

**Versión corta (≈ 35 palabras, si falta tiempo):** *"The grey future is a UN scenario, not a forecast: for the Emirates, its 95% range for 2050 runs from nine to thirty-three million. Migration is the least certain lever, and we say so."*

**Texto en pantalla (build 4 de la Slide 4):** `Uncertainty shown: UAE 2050 = 15 M (UN 95% range 9–33 M) · 77 of 161 countries: UN range includes both growth and decline by 2050 · counts vary with the year chosen (24 = 2021–23 average; 15–25 by year)`.

---

## 6. Riesgos estadísticos y éticos (ASA 2022)

| Riesgo | Dónde | Mitigación |
|---|---|---|
| Presentar un bootstrap de un censo como «error muestral» (B.2, C.4) | Todos los IC | Frase fija: *"sensitivity to which countries are included"*; los conteos llevan rango, no IC. |
| IC simétrico o percentil en un cociente dominado por un país (A.2) | 71 % | BCa + jackknife; nombrar a EE. UU. en el notebook. |
| Usar columnas rotas de OtherVariants (B.1, D.10) | Edad mediana, LE65, Q5 «con IP» | Test de monotonía en `R/01_preparar_datos.R`; lista blanca de columnas. |
| Sumar IP de países para grupos (B.2) | «Fast movers», ingreso | Prohibido; usar las filas de agregados de la ONU (calculadas por trayectoria) o un país representativo. |
| Llamar «rango de incertidumbre» a High/Low (C.2) | Cualquier banda Low–High | Etiqueta: *"UN scenario: ±0.5 children per woman"*; nunca junto a la palabra *uncertainty*. |
| Creer que el IP lo cubre todo (B.2, C.4) | Frases sobre proyecciones | Decir que no incluye la incertidumbre de la base ni de la migración pasada, y que en el Golfo hay topes de expertos. |
| Ignorar la censura izquierda; descartar a quien no cruza (A.2, B.2) | Rezago (H3) | KM/Turnbull; decir «at least»; mostrar n censurados en pantalla (`n = 109; 92 already falling in 1950`). |
| Jardín de senderos que se bifurcan: umbrales y definiciones elegidos al ver los datos (A.4, B.3) | Conteos, rezago, PCA | Definición principal fijada en `hipotesis_H1_H14.md` antes del 25-oct; rango completo en el notebook (fig. inc05). |
| Selección de extremos presentada como hallazgo (A.4) | Gemelos | *"Chosen by rule from 12,880 pairs"*; no calcular nada inferencial sobre ellos. |
| Sobreprecisión (C.4) | Decimales en voz y pantalla | Redondeo en `fmt`; máximo 2 cifras significativas en la voz. |
| Ingreso actual aplicado al pasado y causalidad inversa (B.7, D.6) | KM por ingreso | *"countries that are low-income today"*; sin verbos causales. |
| La incertidumbre migratoria usada para alimentar discursos alarmistas (A.8, D.6) | Golfo, Europa | Lenguaje neutro (*arrive / leave*), sin *wave/flood*; la incertidumbre se presenta como límite de la medición, no como amenaza. |

---

## 7. Cambios concretos propuestos (numerados, por prioridad)

1. **Esquema de `numbers.json`** (plan de implementación §4): añadir a **cada** clave los campos planos `ci_low`, `ci_high`, `ci_level` (0,95), `method` (`none_census` | `wilson` | `bootstrap_bca` | `bootstrap_perc` | `km` | `turnbull` | `un_pi` | `sensitivity`), `B`, `seed`, `n`, `resample_unit` («country»), `sens_low`, `sens_high`, `sens_note`, `status` (`exploratory` | `pre-specified` | `descriptive`), `hypothesis_id`, `p_value`, `p_adj`, `p_adj_method` (solo notebook) y `say` (frase redondeada para la voz). Para proyecciones: `pi80_low`, `pi80_high`, `pi95_low`, `pi95_high`, `variant_source`. QA-stats falla si una clave narrada no tiene `method`. Generar con la función `entrada()` del anexo.
2. **Slide 4, build 4 (y/o Slide 1, zoom al Golfo)**: incluir `inc01_fan_uae.png` (reducido) + la frase de §5. Claves: `pop_are_2050`, `pop_are_2050_pi95_low/high`, `n_dir_uncertain_2050` (= 77), `n_cnmr_sign_uncertain_2050` (= 155). Esto cumple el «incertidumbre visible al menos una vez» y P2/P3 sin gastar una diapositiva.
3. **Memo de ética §2.2 #7, E39 y plan §2**: sustituir el «IP de la edad mediana de China» por el IP de la **población** de China 2050 (1 159–1 354 M) o de su TFR (Medium 1,18; IP 95 % 0,64–1,69); la edad mediana se cita sin IP: `median age ≈ 52 by 2050 (UN medium projection)`. Añadir la corrección «Medium = media para TFR/LEx, **mediana** para migración» y «la migración es probabilística por primera vez en WPP2024».
4. **`R/01_preparar_datos.R`**: test `stopifnot()` de monotonía de los IP y **lista blanca** de columnas válidas en las filas PI (`TPopulation1July`, `TFR`, `LEx`, `LExMale`, `LExFemale`, `CNMR`, `NetMigrations`, `CBR`, `CDR`, `IMR`, `Births`, `Deaths`, `NatChange`, `PopGrowthRate`); el resto se pone a `NA`.
5. **P7 (plan §4-Q1 Rico 1, H3, storyboard Slide 2 build 2)**: reemplazar «median lag 11 years» por: *"Child mortality was already falling when UN data begin in 92 of 109 high-fertility countries. Fertility began to fall around 1970 in today's upper-middle-income countries, 1985 in lower-middle and 2000 in low-income ones — a wait of at least two decades."* Claves: `n_q5_falling_1950` (92), `n_onset` (109), `yr_fert_onset_low/lowmid/upmid/high` (2000/1984/1970/1970), `lag_onset_lower_bound` (22), `share_mort_first` (97, Wilson 92–99), `logrank_income_chisq`. La fila A de `inc04` sustituye al dumbbell `fig04` (o va al notebook si no cabe).
6. **Cover y Slide 1**: una sola definición (promedio 2021–23) en portada, mapa y voz: *"about two dozen (24) grow only because people move in"*, con `sens_low = 15`, `sens_high = 25`; en pantalla, nota gris `(15–25 depending on the year)`. Igual para `n_type_D/E` y `n_below_replacement` (124–138 con umbral ± 0,1).
7. **Storyboard §7, valores**: `r2_tfr_cnmr` → 0,005 («under 1 %»); `rho_cdr_lex_2023` → «about zero (−0.08 to 0.20)»; `share_mig_high_2000_2023` → narrar «about seven in ten» y guardar BCa [56; 114] y jackknife; `pc1_var` con IC bootstrap **y** rango por conjunto de variables (frase de §2).
8. **Plan §4-Q1 Rico 2 y Q2 Rico 1**: subir B de 500 a **2 000** para BCa (1 000 para PCA) y fijar `set.seed(2026)` justo antes de cada `boot()`.
9. **Plan §5 y §8-A**: crear `docs/hipotesis_H1_H14.md` **antes de congelar `numbers.json` v1 (25-oct)**, con columnas «ID · enunciado · cifra y definición principal · sensibilidades previstas · familia · resultado (✔/✘/parcial)»; actualizar H3 (orden + año de inicio por ingreso, no «11 años») y H1 (con IC). Etiqueta *pre-specified*, no *pre-registered*.
10. **Notebook**: sección «How uncertain are our numbers?» con `inc05` y una tabla «What we tested» (familias, n, Holm/BH); sección P2/P3 con `inc02` y `inc03`, y la nota «IP marginales; no sumables; sin incertidumbre de la base».
11. **Recomendaciones (plan §7, Slide 4 build 3)**: toda cifra proyectada lleva «projected (UN medium)»; para *fast movers*, añadir el IP de la población de China 2050; para *early movers* (migración), decir que la ONU no sabe el signo de la migración neta de 2050 en 155 de 161 países, así que la recomendación es *monitor*, no *plan for X migrants*.
12. **QA-stats** (plan de implementación §3, agente 7): checklist extra — cada IC se reproduce con su `seed` y `B`; cada «between A and B» narrado coincide con `ci_low/ci_high` o `pi95_*`; ninguna diapositiva contiene «p =», «significant» ni «range of uncertainty» junto a High/Low.

---

## Anexo — Código R clave (comentarios en español)

```r
# --- Entrada de numbers.json con su incertidumbre (campos planos) ---
entrada <- function(value, unit, def, method, ci = c(NA, NA), B = NA, seed = NA, n = NA,
                    sens = c(NA, NA), sens_note = NA, status = "exploratory", say = NA, ...) {
  list(value = value, unit = unit, def = def, method = method, ci_low = ci[1], ci_high = ci[2], ci_level = 0.95,
       B = B, seed = seed, n = n, resample_unit = "country", sens_low = sens[1], sens_high = sens[2],
       sens_note = sens_note, status = status, say = say, verified = FALSE, ...)
}
# --- Bootstrap BCa de países (cociente de sumas) con respaldo percentil ---
ic_boot <- function(d, estad, B = 2000, seed = 2026) {
  set.seed(seed); bt <- boot::boot(d, estad, R = B)
  ci <- tryCatch(boot::boot.ci(bt, type = "bca")$bca[4:5], error = function(e) boot::boot.ci(bt, type = "perc")$percent[4:5])
  list(est = bt$t0, ci = ci, B = B, seed = seed)
}
razon <- function(d, i) sum(d$mig[i]) / sum(d$pop[i])          # Σ NetMigrations / Σ PopChange
r <- ic_boot(filter(acc, ingreso == "High income"), razon)     # acc: un renglón por país (sumas 2000–2023)
entrada(100 * r$est, "%", "Σ NetMig / Σ PopChange, WB High income, 2000–2023", "bootstrap_bca",
        100 * r$ci, r$B, r$seed, n = 85, sens = c(70.7, 81.6), sens_note = "2010–23; ≥1M; sin USA; sin Golfo",
        status = "pre-specified", hypothesis_id = "H1", say = "about seven in ten")
# --- Wilson para proporciones de países ---
w <- prop.test(105, 108, correct = FALSE)$conf.int              # Wilson (sin corrección de continuidad)
```

```r
# --- IP de la ONU: lectura, lista blanca y test de monotonía ---
ov <- data.table::fread("WPP2024_Demographic_Indicators_OtherVariants_csv.gz", encoding = "UTF-8", na.strings = "")
validas <- c("TPopulation1July","TFR","LEx","LExMale","LExFemale","CNMR","NetMigrations","CBR","CDR","IMR","Births","Deaths")
pi <- ov[VarID %in% c(202, 203, 204, 206, 207), c("LocID", "Time", "Variant", validas), with = FALSE]
w <- data.table::dcast(pi, LocID + Time ~ Variant, value.var = "TPopulation1July")
stopifnot(with(w, all(`Lower 95 PI` <= `Lower 80 PI` & `Lower 80 PI` <= `Median PI` &
                      `Median PI` <= `Upper 80 PI` & `Upper 80 PI` <= `Upper 95 PI`, na.rm = TRUE)))
# OJO: MedianAgePop, LE15/65/80 y Q5 en filas PI NO son intervalos (orden invertido) -> no usar
# Dirección incierta: el IP 95 % de 2050 contiene la población de 2023
# w50: una fila por país con l95/u95 de 2050 (TPopulation1July) y pop2023 de la Medium
dir <- w50 %>% mutate(dir95 = case_when(l95 > pop2023 ~ "up", u95 < pop2023 ~ "down", TRUE ~ "uncertain"))
```

```r
# --- P7: inicios con censura izquierda (serie ya cae en 1950) y KM / Turnbull ---
inicio <- function(t, x, frac = 0.9) { rm <- cummax(x)                 # regla de Princeton: 10 % bajo el máximo previo, sin volver
  for (i in seq_along(x)) { lim <- frac * rm[i]; if (x[i] <= lim && all(x[i:length(x)] <= lim)) return(t[i]) }; NA_real_ }
el <- est %>% group_by(ISO3_code, ingreso) %>%                          # est: >= 1 M, Time <= 2023, ingreso clasificado
  summarise(tfr_1950 = TFR[Time == 1950], ini_tfr = inicio(Time, TFR), ini_q5 = inicio(Time, Q5),
            izq_q5 = which.max(Q5) == 1, izq_tfr = which.max(TFR) == 1, .groups = "drop") %>% filter(tfr_1950 >= 5)
# (a) Año de inicio de la caída de la fecundidad (desde 1950), censura derecha en 2023, por ingreso + log-rank
cal <- el %>% mutate(t = ifelse(is.na(ini_tfr), 2023 - 1950, ini_tfr - 1950), e = as.integer(!is.na(ini_tfr)))
survfit(Surv(t, e) ~ ingreso, cal); survdiff(Surv(t, e) ~ ingreso, cal); coxph(Surv(t, e) ~ as.numeric(ingreso), cal)
# (b) Rezago como intervalo (L, R]: origen censurado por la izquierda => rezago >= observado (R = Inf)
r <- el %>% mutate(d = ini_tfr - ini_q5,
  L = case_when(is.na(ini_tfr) ~ 2023 - ini_q5, izq_tfr ~ NA_real_, TRUE ~ d),
  R = case_when(is.na(ini_tfr) | izq_q5 ~ NA_real_, TRUE ~ d)) %>% filter(!(izq_q5 & izq_tfr))
survfit(Surv(L + 100, R + 100, type = "interval2") ~ 1, r)               # Turnbull (+100 para tiempos positivos)
# Si la masa queda más allá del último tiempo, la mediana NO está identificada: reportar solo la cota inferior
median(pmax(el$ini_tfr - el$ini_q5, 0), na.rm = TRUE)                    # = 22: cota inferior de la mediana
```
