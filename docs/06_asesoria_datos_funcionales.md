# 06 — Asesoría de DATOS FUNCIONALES (FDA) y LONGITUDINALES · P6, P1, P7

> Asesor: análisis de datos funcionales y longitudinales. Fecha: 2026-10-22. Responde al pedido del profesor (`CodigoClase/Test.Rmd` §4: "datos longitudinales, datos funcionales & cluster").
> Datos: `WPP2024_Demographic_Indicators_Medium_csv.gz` (países = `ISO3_code` no vacío) + ingreso `data/raw/wb_api_income_2026-10-22.csv` (`ingreso_api`). Muestra: **161 países ≥ 1 M (2023)**, **solo estimaciones 1950–2023** (74 años). No existía `data/clean/paises_wpp2024.csv.gz`; se construyó el panel desde el archivo Medium.
> Todas las cifras son **prototipos exploratorios** (R 4.6.1, `fda` 6.3.0, `fda.usc` 2.2.0, `mgcv`, `fixest`, `survival`; `set.seed(2026)`). El agente `notebook-R` debe recalcularlas y pasarlas a `figures/numbers.json`.
> Scripts: `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/fda/` (`00_datos.R` … `09_sensibilidad.R`). Figuras: `docs/asesoria_figs/fda/`.
> Coincidencias con otros asesores (evidencia convergente, cálculos independientes): silueta k = 4 = 0,372 y grupo migratorio de 7 países (`06_asesoria_multivariado.md`); "mortalidad empieza a caer primero en 105 de 108 países (97 %)" (`06_asesoria_series_tiempo.md`).

---

## 0. Resumen en 1 minuto

1. **El FDA no cambia los grupos de P6, pero sí los explica.** k-means sobre scores de FPCA y k-means sobre medias por década (plan) dan la **misma partición (ARI = 0,96)** y la misma silueta medida en distancia L2 entre curvas (0,359 vs 0,357). Las medias por década *son* una base funcional (escalones). Mantener el método simple del plan y usar FPCA como validación e interpretación.
2. **Lo que el FDA aporta de verdad es el "reloj"**: alinear cada país en el año en que su TFR cruzó 4 (*landmark registration*) **elimina el 80 % de la varianza entre países** en la ventana ±20 años (57 países). Es la imagen literal de "same road, different speed" y es más fácil de contar que el *connected scatter*.
3. **La velocidad sí difiere**: de 5 a 3 hijos por mujer China tardó 5 años, Irán 5, Egipto 33, Filipinas 32. Quien empezó después de 1990 **no** va más rápido (Kaplan–Meier: mediana 24 años vs 18–20; *Late movers* 29,6).
4. **P7 "la mortalidad cae primero"**: el método de umbrales del plan da 11 años y es **robusto a la censura** (Turnbull con 42 censurados: mediana 11) **pero no al umbral** (−11,5 a +33 años). El método FDA de "año de caída más rápida" (derivada mínima) **no sirve para la mortalidad**: Q5 cae a un ritmo casi constante (2,6–4,0 %/año por década) y no tiene un "momento". Lo robusto: **en el reloj de la fecundidad, Q5 ya había caído a la mitad (47 %) 20 años antes del cruce, la TFR solo al 63 %**; y 97 % de los países con TFR ≥ 5 en 1950 empezaron a bajar la mortalidad antes.
5. **P1**: la DE entre países de la edad mediana pasó de 4,7 a 9,7 años (1950→2023) mientras la de LEx bajó de 12,2 a 7,4; la región explica cada vez más de la edad mediana (R² 0,62 → 0,75) y el ingreso aún más rápido (0,43 → 0,73). Las curvas **atípicas por profundidad funcional son crisis** (Camboya, Ruanda, Sudán del Sur, RCA), no países ricos o pobres; Botsuana **no** es atípica en nivel.
6. **Longitudinal**: un GAM con suavizador por ingreso aporta **una** idea nueva para P7: *a igual mortalidad infantil (Q5 = 100), la TFR esperada es 5,9 en ingreso bajo y 3,8 en ingreso alto*. El panel con efectos fijos **no** aporta: el coeficiente con Q5 *adelantado* 10 años es mayor que con Q5 rezagado (placebo falla) y los EE iid subestiman ~6×.

---

## 1. Evaluación del plan y del storyboard desde FDA / longitudinal

| Sección | Qué está bien | Qué cambiar (con evidencia de §3) |
|---|---|---|
| Plan §4 Q3 **Rico 1** (clustering de trayectorias, medias por década; FDA "como apéndice") | Resumen por décadas de 4 variables z-estandarizadas, k-means `nstart = 50`, silueta, bootstrap, ARI vs niveles 2023, repetir sin CNMR. Todo eso se sostiene. | (a) Cifras esperadas desactualizadas: silueta **0,37** (no ≤ 0,23); tamaños **49 / 51 / 54 / 7** (no 43 / 46 / 62 / 10); **India cae en Fast movers**, no en Late movers. (b) `fpc` y `dtwclust` **no están instalados**: Jaccard bootstrap a mano (código §4) y **eliminar DTW** (el registro por hitos es un *time-warping* interpretable que lo sustituye). (c) El grupo *Migration-boosted* existe solo por la CNMR: sin ella se disuelve (ARI 0,58) y es el más débil (silueta 0,16; BHR y JOR con silueta negativa). |
| Plan §4 Q3 **Simple 1** (connected scatter + "años de 5 a 2,5") | Buena idea visual de "camino". | La "velocidad" se debe medir con **censura** (Kaplan–Meier, §3.3): 39 de 102 países aún no llegan a 3. El dato no apoya "los que llegan tarde van más rápido". |
| Plan §4 Q1 **Rico 1** (rezago Q5 < 100 → TFR < 4; "event time") | El gráfico de *event time* (alinear en el cruce de TFR) es exactamente un registro por hitos: mantenerlo y subirlo a la diapositiva. | El "11 años" es un artefacto del par de umbrales (rejilla −11,5…+33). No narrar "a median of eleven years" como hallazgo; narrar el **orden** (97 %) y la **magnitud previa** (Q5 a la mitad). |
| Plan §3 variables `anio_q5_100`, `anio_tfr_4`, `rezago` | Censura declarada. | Usar **intervalos de censura** (Turnbull) en vez de descartar 72 países; definir el cruce de TFR sobre la curva **suavizada** y como *último* cruce (evita falsos cruces por choques de un año). |
| Plan §4 Q3 **Simple 2** (fan chart, σ-convergencia, P1) | Correcto y claro. | Añadir R²(región) y R²(ingreso) por año (ANOVA funcional puntual) y la lista de curvas atípicas por profundidad (notebook). |
| Plan §4 Q1 **Opcional panel FE** | Se declara descriptivo. | Degradar a apéndice o quitar: placebo de adelanto falla (§3.6). |
| Storyboard **Slide 2** ("Same road, different speed") | Título excelente. | Build 1: usar la **animación de registro** (curvas que se deslizan a un reloj común) en vez de, o antes de, el connected scatter. Build 2: sustituir el dumbbell por la figura de *event time* (`fda_04`). |
| Storyboard **Slide 4** ("Four roads") | Pequeños múltiplos + "a continuum, not boxes". | Usar `fda_03` (mediana + banda P10–P90 por grupo). Cambiar "Fast movers — … from six children to under two in fifty years": la mediana del grupo va de 6,2 (1950) a 2,0 (2023). |

---

## 2. Método recomendado por pregunta

### 2.1 P6 — ¿grupos por cómo se movieron? (clustering funcional)
- **Método principal (sin cambios):** k-means k = 4 sobre medias por década (32 rasgos). **Validación FDA:** suavizado B-spline → FPCA multivariada → k-means sobre los 6 primeros scores (90 % de varianza) → ARI con el principal; silueta en distancia L2 común; Jaccard bootstrap por grupo.
- **Por qué:** ambos métodos aproximan la distancia L2 entre curvas; el FDA da (i) curvas medias suaves con bandas para la figura, (ii) componentes interpretables, (iii) invariancia al suavizado (ARI = 1,00 con λ = 1 y λ = 100).
- **Supuestos:** z-estandarización global del panel (pesa igual cada variable); CNMR winsorizada ±3 DE (144 de 11 914 celdas); k fijado por interpretabilidad (k = 2 tiene la mayor silueta).
- **No recomendado:** clustering sobre velocidades (derivadas): responde literalmente "cómo se movieron, no dónde están", pero es inestable (silueta L2 0,20; un grupo de 2 países con Jaccard 0,47). Mencionarlo en el notebook como intento.
- **Frase (EN):** *"We compared whole 70-year paths, not one year: four roads emerge, and they don't depend on how we summarise the curves."*

### 2.2 "Same road, different speed" — registro por hitos (landmark registration)
- **Método:** para cada país, año continuo en que la TFR suavizada cruza 4 por última vez (`c4`); eje nuevo τ = año − `c4`. Mostrar calendario (A) vs reloj propio (B). Cuantificar: varianza media entre países en la ventana ±20 (calendario vs alineado) y descomposición amplitud/fase de Kneip–Ramsay (`fda::landmarkreg` + `AmpPhaseDecomp`). Velocidad: duración 5 → 3 con Kaplan–Meier.
- **Supuestos y límites:** solo entran los 90 países con cruce observado (45 ya < 4 en 1950; 26 aún ≥ 4 en 2023, sobre todo África subsahariana). **No** se puede afirmar que esos 26 "seguirán el mismo camino" (sería usar el supuesto de la proyección ONU como evidencia). El hito (4) es una elección: repetir con 5 y 3.
- **Validación:** sensibilidad al hito; ventana balanceada; R² de fase global (0,56) además del 80 % local.
- **Frase (EN):** *"Put every country on its own clock — years since fertility fell below four — and the curves collapse onto one road: most of the difference between countries is timing, not shape."* + *"The road is shared; the speed is not: China went from five to three children in five years, Egypt took thirty-three."*

### 2.3 P7 — rezago mortalidad → fecundidad
- **Método recomendado (vídeo):** *event time* sobre el reloj de la fecundidad (índice común = 100 veinte años antes del cruce; mediana + RIC), `fda_04`. Cifra de apoyo: inicio de la caída (−10 % del máximo previo) → Q5 primero en 105/108 (97 %); al iniciar la caída de la TFR, Q5 ya había caído 48 % desde 1950 (59 % en ingreso bajo).
- **Método de umbrales (notebook):** mantener el dumbbell con Turnbull y la rejilla de umbrales como sensibilidad.
- **Método derivada (descartado, reportarlo):** año de derivada mínima de TFR y de log Q5. Falla por identificación, no por censura.
- **¿Cuál es más robusto a la censura?** El de umbrales, tratado con Turnbull, conserva la mediana (11) al incluir 42 censurados; la derivada de Q5 en escala absoluta cae en el borde en 58 de 161 países (máxima caída antes o en 1950) y en log está mal identificada. El inicio de la caída es censurado a la izquierda para Q5 (ya caía en 1950 en 81 % de los países de alta fecundidad), lo que **refuerza** "mortalidad primero".
- **Frase (EN):** *"In the twenty years before fertility fell below four, child mortality had already halved — deaths fall first, births follow. A descriptive order, not proof of cause."*

### 2.4 P1 — divergencia y curvas atípicas
- **Método:** DE y P10–P90 por año (ya en el plan) + R² puntual de región e ingreso; profundidad funcional: boxplot funcional MBD (`fda::fbplot`), `fda.usc::depth.FM/mode/RP`, `outliers.depth.trim` (bootstrap, nb = 200) sobre **datos anuales sin suavizar**; profundidad de **forma** = MBD de las diferencias anuales.
- **Lectura clave:** la profundidad de nivel (FM, MBD, RP; ρ ≥ 0,98 entre ellas) solo ordena extremos (CHE, SWE, NER); para "trayectorias raras" hace falta el boxplot funcional (atípicas de nivel persistente) y la profundidad de forma (giros y choques). MBD es insensible a choques de 2–3 años (Corea del Norte 1950–53, LEx 14→40, queda dentro del 50 % central).
- **Anotar sin causalidad:** "Cambodia 1975–79", "Rwanda 1994" (hechos fechados y documentados); RCA: los colapsos de un año (2009: 14,7; 2019: 31,5; 2022: 18,8) son ajustes de crisis de WPP a verificar antes de anotarlos.
- **Frase (EN):** *"The most unusual paths are crisis paths — Cambodia, Rwanda, South Sudan — and since 1950 the gap between countries moved from how long people live to how old populations are."*

### 2.5 Longitudinal (GAM / panel)
- **Recomendado (opcional, 1 frase para P7 por ingreso):** `bam(TFR ~ ingreso + s(log Q5, by = ingreso) + s(pais, bs = "re"), rho = AR1)` → "la carretera se dobla más tarde en ingreso bajo" (`fda_06`).
- **No recomendado:** `s(Time, by = ingreso)` (reproduce las medias por grupo, R² 0,90, sin información nueva) y panel FE en niveles con rezago (placebo falla). Si el profesor pide panel, usar cambios quinquenales y rezagos en ambas direcciones (ver `06_asesoria_series_tiempo.md`).
- **Frase (EN):** *"At the same level of child mortality, poorer countries keep higher fertility — the road bends later."* (con la advertencia de que compara épocas distintas).

---

## 3. Prototipos ejecutados (resultados preliminares)

### 3.1 Suavizado y FPCA (`01_suavizado_fpca.R`)
- Base B-spline cúbica con nodos anuales (76 funciones), penalización de la 2.ª derivada. **GCV casi interpola** (λ = 0,01–1; 27–66 gl efectivos) porque las series WPP ya son salidas de modelo suaves con errores autocorrelacionados. Decisión: **λ = 10 (≈ 16 gl, ~1 gl cada 4–5 años)** para todo; los grupos no cambian con λ = 1 o 100.

| FPCA univariada (% varianza) | FPC1 | FPC2 | FPC3 | Interpretación (Spearman con rasgos simples) |
|---|---|---|---|---|
| TFR | 86,2 | 11,0 | 1,5 | FPC1 = nivel/tardanza (ρ = 0,96 con el año de cruce de 4); FPC2 = tamaño y precocidad de la caída (ρ = −0,88 con la caída 1950–2023) |
| LEx | 88,7 | 7,2 | 2,2 | — |
| Edad mediana | 92,2 | 6,5 | 0,8 | — |
| CNMR (winsorizada) | 51,8 | 14,8 | 7,9 | ruido repartido: la migración no tiene "forma" común |
| **Multivariada (4 vars z)** | **64,7** | **12,3** | **6,4** | FPC1 = avance en la transición (ρ −0,98 TFR media, +0,96 LEx media, −0,93 año TFR<4); FPC2 = migración (ρ 0,84 CNMR media); FPC3 = profundidad de la caída de TFR (ρ −0,81). 6 componentes = 90 % |

**Mensaje:** en el calendario, *nivel* y *tardanza* son lo mismo (FPC1). Por eso hace falta el registro (§3.3) para separar "cuándo" de "cómo".

### 3.2 Clustering: plan vs FDA (`02_cluster.R`, `03_perfil_cluster.R`, `09_sensibilidad.R`)

| Silueta (k = 4) | Décadas (plan) | Curvas L2 | Scores FPCA | Velocidades | Niveles 2023 |
|---|---|---|---|---|---|
| En su propio espacio | 0,372 | 0,360 | 0,428 | 0,146 | 0,461 |
| En el mismo espacio (L2 entre curvas) | 0,357 | 0,360 | 0,359 | 0,201 | 0,281 |
| k con silueta máxima | 2 (0,44) | 2 | 2 (0,49) | — | 3 |

| ARI (k = 4) | Décadas | Curvas L2 | FPCA | Velocidades | Niveles 2023 |
|---|---|---|---|---|---|
| Décadas | 1 | 0,98 | **0,96** | 0,75 | **0,64** |
| FPCA | 0,96 | 0,98 | 1 | 0,76 | 0,61 |

- Otros: PAM sobre scores 0,69; Ward 0,58; FPCA con K = 3, 4 u 8 componentes 1,00 / 1,00 / 0,98; sin CNMR 0,58 (el grupo del Golfo se reparte entre Fast y Late).
- **Jaccard bootstrap (B = 200)** — décadas: 0,77 / 0,94 / 0,85 / 0,92; FPCA: 0,81 / 0,96 / 0,88 / 0,93 (Migración / Early / Fast / Late). Silueta por grupo (FPCA): 0,16 / 0,54 / 0,36 / 0,43.
- **"Cómo se movieron" ≠ "dónde están hoy":** ARI 0,61–0,64 entre trayectorias y niveles 2023 → ~1/3 de la partición cambia al mirar 70 años.

| Grupo (FPCA k-means) | n | Pob. 2023 (mil M) | Ejemplos | TFR 1950 → 1990 → 2023 | LEx 1950 → 2023 | Edad med. 2023 | CNMR media 2000–23 |
|---|---|---|---|---|---|---|---|
| Early movers | 49 | 1,4 | USA, RUS, JPN, DEU, GBR, FRA | 3,0 → 1,8 → 1,4 | 62,1 → 81,4 | 41,8 | +1,8 |
| Fast movers | 51 | 4,9 | IND, CHN, IDN, BRA, BGD, MEX | 6,2 → 3,5 → 2,0 | 46,0 → 74,7 | 29,5 | −0,8 |
| Late movers | 54 | 1,7 | PAK, NGA, ETH, COD, TZA, KEN | 6,4 → 6,4 → 4,0 | 37,5 → 65,1 | 18,3 | −1,0 |
| Migration-boosted | 7 | 0,1 | SAU, JOR, ARE, KWT, QAT, BHR (+DJI) | 7,1 → 4,5 → 1,8 | 40,9 → 80,4 | 31,2 | +22,6 |

(medianas de países; composición: 40 de 54 Late movers son de África subsahariana; 39 de 49 Early movers son de ingreso alto). Descripción con variables que también definieron los grupos: es descriptiva, sin valores p.

### 3.3 Registro por hitos y velocidad (`04_registro.R`, `04b_amp_fase.R`)
- Cruce de TFR = 4 observado en **90** países (rango 1957–2023, DE 16,9 años); 45 censurados a la izquierda, 26 a la derecha.
- Ventana ±20 años (57 países): varianza media entre países **0,920 → 0,186 (−80 %; −79 % sin τ = 0)**. Ancho P10–P90 a τ = −10: **1,33 vs 3,12** hijos; a τ = +10: **0,93 vs 1,91**.
- Kneip–Ramsay en todo 1950–2023 (57 países, `landmarkreg` con dominio reescalado): **R² de fase = 0,56**, C = 1,01 (más conservador porque el alabeo fija los extremos).
- En el reloj de la fecundidad la mortalidad también "se alinea": al cruzar TFR = 4, LEx P10–P90 = 57,7–70,5 años vs 52,5–73,3 en el año calendario mediano (1992); Q5 mediana 65 ‰.

| Velocidad TFR 5 → 3 (Kaplan–Meier, censura en 2023) | n | llegan a 3 | mediana (años) [IC95] |
|---|---|---|---|
| Cruzaron 5 hasta 1975 | 20 | 20 | 19,5 [17,7–21,0] |
| 1975–1990 | 32 | 30 | 18,3 [16,3–23,6] |
| Después de 1990 | 50 | 13 | 24,1 [19,1–NA] |
| Fast movers / Late movers | 44 / 46 | 42 / 9 | 18,8 / 29,6 |

Más rápidos: CHN 5,1 · IRN 5,3 · SGP 7,5 · MNG 7,5 · THA 9,3 · LBY 9,3. Más lentos (observados): EGY 32,7 · PHL 32,0 · DZA 30,4 · LSO 29,6 · MYS 28,9 · BWA 28,1. Spearman(año de cruce de 5, duración) = −0,06 (solo eventos).

### 3.4 Rezago mortalidad → fecundidad (`05_rezago.R`, `05b_rezago_censura.R`, `05c_inicio.R`)

| Método | n usable | Mediana (años) | RIC | % mortalidad primero |
|---|---|---|---|---|
| Umbrales Q5 < 100 / TFR < 4 (plan), solo observados | 89 | 11 | 2–19 | 80 % |
| Ídem con censura por intervalos (Turnbull, +42 censurados) | 131 | 11 | −1–21 | 74 % |
| Umbrales Q5 < 50 / TFR < 3 | 81 | 2 | −6–13 | 58 % |
| Rejilla Q5 ∈ {200…50} × TFR ∈ {5…3} | 49–100 | **−11,5 a +33** | — | — |
| Derivada mínima log Q5 → TFR | 139 | −2,5 | −17–11 | 47 % |
| Derivada mínima log IMR → TFR | 135 | −6,8 | −18–7 | 42 % |
| **Inicio de caída (−10 % del máximo), TFR₁₉₅₀ ≥ 5** | 108 | TFR inicia ~1980 | — | **97 % (105/108)** |

- Por qué falla la derivada: "agudeza" (velocidad mínima / mediana) **3,7 para TFR vs 2,0 para log Q5**; la caída anual mediana de Q5 por década es 2,6 · 2,8 · 3,2 · 3,4 · 3,5 · 4,0 · 3,3 · 3,0 %, la de TFR 0 · 0,3 · 1,0 · 1,1 · 1,9 · 0,8 · 1,3 · 1,5 %. **La fecundidad cae como un acantilado; la mortalidad, como una pendiente larga.** Además es inestable con λ (−7,2 con λ = 1; −3,6 con λ = 100).
- 1950–55, países con TFR ≥ 5 (110): Q5 ya caía > 1 %/año en **81 %**; TFR > 0,5 %/año en **6 %**.
- Al iniciar la caída de la TFR, Q5 ya había caído desde 1950: **48 %** (P25–P75 40–63 %); ingreso bajo 59 % (inicio TFR ~2000), medio-bajo 47 % (1984), medio-alto 44 % (1970), alto 72 % (1970, n = 12).
- Turnbull por región (mediana, umbrales 100/4): SSA 17 (14 solo observados), N. África y Asia Occ. 21, LAC 8, Asia C. y S. 8, Asia E. y SE 7.

### 3.5 Divergencia y profundidad (`06_divergencia.R`)

| 161 países, 1950 / 1975 / 2000 / 2023 | DE | P90–P10 | R² región SDG | R² ingreso |
|---|---|---|---|---|
| Edad mediana | 4,7 / 6,0 / 8,1 / **9,7** | 11,6 → 25,3 | 0,62 → 0,75 | 0,43 → 0,73 |
| LEx | **12,2** / 11,8 / 10,2 / 7,4 | 32,1 → 19,6 | 0,57 → 0,67 | 0,57 → 0,71 |
| TFR | 1,7 / 2,0 / 1,9 / 1,3 (máx. 2,1 en 1981) | 4,6 → 3,0 | 0,64 → 0,67 | 0,45 → 0,66 |

| Criterio de atipicidad | Países |
|---|---|
| Boxplot funcional MBD, LEx (nivel) | RWA, SSD, CAF, KHM |
| `outliers.depth.trim` (modal, nb = 200), LEx | SSD, CAF, KHM, TLS, LSO, ZWE |
| Forma: menor MBD de cambios anuales de LEx | RUS, RWA, SSD, BDI, LTU, SWZ, XKX, MKD |
| Forma: edad mediana (boxplot de cambios) | HKG, KWT, QAT, GRC, XKX |
| Forma: TFR (boxplot de cambios) | TJK, CHN, PRK, KHM, VNM, ISR, ROU, XKX |
| Nivel: CNMR (boxplot, 21 países) | Golfo (ARE, QAT, KWT, BHR, OMN), JOR, DJI, LBY, PSE, BIH, XKX, PRI, RWA, BDI, SOM, KHM… |

Casos pedidos: **RWA** peor caída anual de LEx −30,8 (1994), forma rango 2/161; **KHM** −26,5 (1975); **BWA** no es atípica (nivel: rango 121,5/161 = central; forma: 21; su peor caída anual es −4,3 en 2021, la del VIH fue gradual) → usar **Eswatini** (forma rango 6) para ilustrar el VIH; **ARE** no es atípica en LEx (rango 91) sino en CNMR y en la velocidad de su edad mediana (+0,77 años/año en 1967).

### 3.6 Modelos longitudinales (`07_longitudinal.R`)
- 160 países × 74 años (sin "Not classified"). Autocorrelación AR(1) de residuos = **0,956**.
- GAM TFR ~ f(log Q5) **por ingreso** vs común: AIC −18 469 vs −18 088 (curvas distintas por ingreso). TFR esperada (país típico):

| Ingreso | Q5 = 200 | Q5 = 100 | Q5 = 50 | Q5 = 25 |
|---|---|---|---|---|
| Bajo | 6,30 | **5,91** | 5,24 | (5,04)* |
| Medio-bajo | 5,80 | 5,20 | 4,51 | 3,62 |
| Medio-alto | 5,15 | 4,47 | 3,47 | 2,80 |
| Alto | (4,34)* | **3,80** | 3,22 | 2,58 |

\* fuera del rango observado del grupo (extrapolación; no mostrar).
- Panel FE país + año, log Q5 rezagado 10 años, EE agrupados: 1,37 (0,33) bajo · 0,99 (0,21) medio-bajo · 0,44 (0,31) medio-alto · 1,19 (0,28) alto; CNMR rezagada ≈ 0 en todos. EE iid 0,023 vs agrupado 0,135 (**≈ 6×**). **Placebo:** log Q5 *adelantado* 10 años → 1,04 (R² within 0,16) > rezagado 0,74 (0,10): la asociación es de tendencia común, no de orden temporal.

### 3.7 Figuras (revisadas una a una; títulos = mensaje, en inglés)

| Archivo (`docs/asesoria_figs/fda/`) | Qué muestra | Uso |
|---|---|---|
| `fda_01_registro_tfr.png` | A: TFR suavizada de 90 países en calendario (KOR, IND, KEN resaltados); B: mismas curvas alineadas en el año del cruce de 4, mediana + banda P10–P90. La forma común aparece en B; Corea baja más rápido, Kenia más lento | **Slide 2 build 1** (animar A → B) |
| `fda_02_fpca_tfr.png` | Curva media ± 1 DE de FPC1 (86 %: nivel/tardanza) y FPC2 (11 %: caída temprana y fuerte vs curva plana) | Notebook (explicar FPCA) |
| `fda_03_grupos_curvas.png` | 4 grupos × 4 variables: mediana + banda P10–P90; CNMR winsorizada | **Slide 4 build 1** |
| `fda_04_mortalidad_primero.png` | *Event time*: Q5 y TFR indexadas (= 100 a τ = −20) en 57 países; al cruce Q5 = 47 %, TFR = 63 % | **Slide 2 build 2** (sustituye dumbbell) |
| `fda_05_divergencia_atipicos.png` | A: LEx de todos los países con atípicas de nivel (sólidas) y forma (punteadas) anotadas; B: DE entre países de LEx (12,2 → 7,4) y edad mediana (4,7 → 9,7) | Slide 4 build 2 (panel B) / notebook (A) |
| `fda_06_gam_ingreso.png` | GAM: TFR esperada vs Q5 (log, invertido) por ingreso, ±2 EE, solo en el rango observado de cada grupo | Notebook; opcional 1 frase en Slide 1–2 |

---

## 4. Código R clave (comentarios en español)

```r
library(fda); library(fda.usc); library(cluster); library(mclust); library(survival); library(mgcv)
anios <- 1950:2023                                   # solo estimaciones
# Y: matriz años × países (161 países ≥ 1 M); una por variable
base <- create.bspline.basis(c(1950, 2023), nbasis = length(anios) + 2, norder = 4)
fdTFR <- smooth.basis(anios, Y_TFR, fdPar(base, Lfdobj = 2, lambda = 10))$fd   # λ fijo: GCV interpola
# --- FPCA multivariada (4 variables z-estandarizadas en todo el panel) ---
zs  <- function(Y) (Y - mean(Y)) / sd(Y)            # z con media y DE de TODO el panel (no por año)
Ymv <- array(NA, c(74, ncol(Y_TFR), 4)); Ymv[,,1] <- zs(Y_TFR)  # [,,2:4] = LEx, MedianAge, CNMR winsorizada ±3 DE
fdmv <- smooth.basis(anios, Ymv, fdPar(base, 2, 10))$fd
pc   <- pca.fd(fdmv, nharm = 8)
SC   <- apply(pc$scores, c(1, 2), sum)               # ¡en multivariada fda guarda la contribución por variable!
K    <- which(cumsum(pc$varprop) >= 0.90)[1]          # 6 componentes
set.seed(2026); cl_fpca <- kmeans(SC[, 1:K], 4, nstart = 50)$cluster
adjustedRandIndex(cl_fpca, cl_decadas)                # 0,96 con el método del plan
# --- Jaccard bootstrap por grupo (sustituye fpc::clusterboot, no instalado) ---
jacc <- function(X, k, B = 200) { set.seed(2026); cl0 <- kmeans(X, k, nstart = 50)$cluster; J <- matrix(NA, B, k)
  for (b in 1:B) { idx <- sample(nrow(X), replace = TRUE); u <- unique(idx)
    clb <- kmeans(X[idx, ], k, nstart = 20)$cluster[match(u, idx)]
    for (g in 1:k) { A <- u[cl0[u] == g]; J[b, g] <- max(sapply(1:k, function(h) { Bh <- u[clb == h]; length(intersect(A, Bh)) / length(union(A, Bh)) })) } }
  colMeans(J, na.rm = TRUE) }
# --- Registro por hito: año (continuo) del ÚLTIMO cruce de TFR = 4 en la curva suavizada ---
tf <- seq(1950, 2023, 0.1); Tf <- eval.fd(tf, fdTFR)
cruce <- function(y, u) { if (y[1] < u) return(-Inf); if (tail(y, 1) >= u) return(Inf)    # censura izq./der.
  i <- max(which(y >= u)); tf[i] + (y[i] - u) / (y[i] - y[i + 1]) * 0.1 }
c4 <- apply(Tf, 2, cruce, 4)
# Varianza entre países: calendario vs reloj propio (ventana ±20, países con ventana completa)
ok <- is.finite(c4) & c4 - 20 >= 1950 & c4 + 20 <= 2023; tau <- -20:20
Al <- sapply(which(ok), function(i) eval.fd(c4[i] + tau, fdTFR[i]))
Ca <- sapply(which(ok), function(i) eval.fd(median(c4[ok]) + tau, fdTFR[i]))
1 - mean(apply(Al, 1, var)) / mean(apply(Ca, 1, var))  # ≈ 0,80
# Kneip–Ramsay: fda 6.3 falla con la base de alabeo por defecto → dominio 0–73 y base de 5 funciones
wb <- create.bspline.basis(c(0, 73), 5, 4); wp <- fdPar(fd(matrix(0, 5, 1), wb), 2, 1e-4)
reg <- landmarkreg(fd_0a73, ximarks = matrix(c4[ok] - 1950), x0marks = mean(c4[ok] - 1950), WfdPar = wp, WfdPar0 = wp, ylambda = 1e-2)
AmpPhaseDecomp(fd_0a73, reg$regfd, reg$warpfd)$RSQR    # ≈ 0,56 (fd_0a73: base de 25 funciones en 0–73)
# --- Velocidad 5 → 3 con censura a la derecha ---
d$dur <- ifelse(is.finite(d$c3), d$c3, 2023) - d$c5; d$evento <- is.finite(d$c3)
survfit(Surv(dur, evento) ~ cohorte, data = d)
# --- Rezago por umbrales con censura por intervalos (Turnbull); +100 para tiempos positivos ---
S <- Surv(lo + 100, hi + 100, type = "interval2")    # lo/hi = cotas del rezago (NA = −Inf / +Inf)
quantile(survfit(S ~ 1), c(.25, .5, .75))$quantile - 100
# --- Profundidad funcional sobre datos SIN suavizar ---
fb <- fbplot(Y_LEx, x = anios, method = "MBD", plot = FALSE); colnames(Y_LEx)[fb$outpoint]
fdat <- fdata(unname(t(Y_LEx)), argvals = as.numeric(anios))      # fda.usc exige argvals numéricos sin nombres
outliers.depth.trim(fdat, dfunc = depth.mode, nb = 200, smo = 0.05, trim = 0.06)$outliers
fbplot(apply(Y_LEx, 2, diff), method = "MBD", plot = FALSE)$depth  # profundidad de FORMA (cambios anuales)
# --- GAM con suavizador por ingreso, efecto aleatorio de país y errores AR(1) ---
m <- bam(TFR ~ ingreso + s(log(Q5), by = ingreso, k = 10) + s(pais, bs = "re"), data = panel,
         discrete = TRUE, rho = 0.956, AR.start = panel$inicio)   # rho = ACF(1) de residuos del modelo sin AR
```

---

## 5. Riesgos estadísticos y éticos (ASA 2022)

1. **Sesgo de supervivencia en el registro (A, C).** La figura "one shared shape" solo incluye los 90 países que cruzaron 4. Decir en pantalla: *"26 countries, mostly in sub-Saharan Africa, have not crossed 4 yet and are not shown."* No usar la proyección Medium para "completar" su curva: la ONU proyecta con un modelo de doble logística, así que "seguirán el camino" sería circular.
2. **El hito es una elección (B).** Repetir con TFR = 5 y 3; reportar el % de varianza eliminada para cada uno.
3. **Datos modelizados y suavizados (B).** Antes de ~1990 muchas series sin registro civil son interpolaciones de la ONU; las derivadas y la "forma" reflejan en parte el modelo WPP. Declararlo junto a cada derivada o velocidad.
4. **El suavizado es una decisión (B).** λ = 10 fijo (GCV interpola); los choques se estudian sobre datos crudos. Grupos invariantes a λ; reportarlo.
5. **Selección de especificación (A, C).** Se probaron 6 métodos de rezago; el de derivadas falla y **se reporta** como resultado negativo. No elegir el umbral que da el número más bonito.
6. **Ingreso FY2026 aplicado a 1950–2023 (B, C).** Ser de ingreso alto hoy es en parte consecuencia de haber hecho la transición antes; el GAM por ingreso es descriptivo. Además mezcla épocas (alto ingreso en Q5 = 100 en los 1950; bajo ingreso en los 2010).
7. **Autocorrelación (A).** ρ = 0,956: los EE ingenuos de paneles anuales son ~6× demasiado pequeños; sin valores p en el vídeo.
8. **Grupos débiles (C).** Silueta 0,36–0,43; k = 2 es la "mejor" partición. Mantener "a continuum, not boxes". El grupo de migración (silueta 0,16) se define por construcción por la CNMR.
9. **Lenguaje (C, D).** "Clock / timing / speed", nunca "behind", "backward" o "lagging" como juicio. "Late movers" describe el calendario, no el desarrollo. Las curvas atípicas son crisis humanas: anotar con fecha y fuente (ONU), sin cifras de víctimas no verificadas; RCA marcada como posible artefacto.
10. **Migración (D).** CNMR alta en 2023 en SSD/SYR son retornos tras conflicto (plan S3), no "atracción"; no calificar la migración de buena o mala.

---

## 6. Cambios concretos al plan y al storyboard

1. **Plan §4 Q3 Rico 1:** mantener k-means sobre medias por década como método principal; añadir "FPCA (B-splines, λ = 10) + k-means sobre 6 scores" como robustez con **ARI = 0,96** en `numbers.json` (`ari_fpca_decadas`). Quitar DTW (`dtwclust`) y `fpc::clusterboot`; usar la función `jacc()` de §4.
2. **Plan §4 Q3 y §6/§7:** actualizar cifras esperadas a silueta ≈ 0,37 (k = 4), tamaños 49/51/54/7, y mover **India a Fast movers** en la tabla de recomendaciones (§7) y en cualquier narración. Recalcular en el notebook.
3. **Plan H9:** reescribir como "4 tipos con separación moderada (silueta ≈ 0,37; k = 2 máximo), el grupo migratorio solo existe por la CNMR (ARI 0,58 sin ella)".
4. **Storyboard Slide 2 build 1:** animación de registro `fda_01` (≈ 8 s): las curvas en calendario se deslizan horizontalmente hasta alinearse en τ = 0. Texto: `Same road, different clock: aligning on the year fertility crossed 4 removes {pct_var_fase}% of the gaps` (80). Mantener el connected scatter de regiones solo si cabe en tiempo (o moverlo al notebook).
5. **Storyboard Slide 2 build 2:** sustituir el dumbbell por `fda_04` con texto `Before fertility crossed 4, child mortality had already halved · deaths fell first in {pct_mort_primero_inicio}% of high-fertility countries` (47 % / 97 %). Narración: reemplazar "a median of eleven years before" por *"in 97 percent of high-fertility countries, child deaths began falling first; by the time fertility crossed four, child mortality had already halved."*
6. **Plan §3 (variables derivadas):** `anio_tfr_4` = último cruce en la curva suavizada; `rezago` con censura por intervalos (Turnbull); añadir `inicio_tfr`, `inicio_q5` (−10 % del máximo) y `dur_5a3` + `evento_3`.
7. **Plan §4 Q3 Simple 1 (velocidad):** reportar duración 5 → 3 con Kaplan–Meier por cohorte y por grupo (18–20 vs 24 años; Late movers 29,6). Frase de velocidad con dos países: China 5 años, Egipto 33. Eliminar cualquier insinuación de "los que llegan tarde van más rápido".
8. **Plan §4 Q3 Simple 2 (P1):** añadir R²(región) y R²(ingreso) por año (edad mediana 0,62 → 0,75 y 0,43 → 0,73) y el panel B de `fda_05` como alternativa al fan chart si el tiempo aprieta.
9. **Notebook, sección nueva "Curvas atípicas":** boxplot funcional + profundidad de forma; tabla §3.5; usar Eswatini (no Botsuana) para VIH; RCA solo con nota de artefacto.
10. **Plan §4 Q1 Opcional (panel FE):** pasar a apéndice con el placebo de adelanto y EE agrupados; no citar en el vídeo. En su lugar, apéndice GAM `fda_06` (una frase opcional para P7 por ingreso).
11. **`numbers.json` (claves nuevas):** `n_cruce_tfr4_obs` 90, `n_cens_izq` 45, `n_cens_der` 26, `pct_var_fase` 80, `r2_fase_kr` 0,56, `dur53_chn` 5,1, `dur53_egy` 32,7, `km_dur53_late` 29,6, `q5_indice_cruce` 47, `tfr_indice_cruce` 63, `pct_mort_primero_inicio` 97, `q5_caida_al_inicio_tfr` 48, `ari_fpca_decadas` 0,96, `ari_tray_niveles` 0,64, `sil_k4` 0,37, `sd_medage_1950/2023` 4,7/9,7, `sd_lex_1950/2023` 12,2/7,4.
12. **Referencias (diapositiva final):** añadir Ramsay & Silverman (2005); Kneip & Ramsay (2008); Sun & Genton (2011); paquetes `fda`, `fda.usc`, `mgcv`, `survival`.

---

## 7. Cómo contarlo: vídeo vs notebook

| Método | Frase simple (EN) | Diapositiva | Notebook (apéndice técnico) |
|---|---|---|---|
| Registro por hitos | *"Put every country on its own clock and the curves collapse onto one road."* | Slide 2 build 1 (animación) + 80 % | Hito 4/5/3, Kneip–Ramsay, ventana, censura |
| Velocidad | *"The road is shared; the speed is not — five years in China, thirty-three in Egypt."* | Slide 2, una línea | Kaplan–Meier por cohorte y grupo |
| Mortalidad primero | *"Child mortality had already halved before fertility fell below four."* | Slide 2 build 2 (`fda_04`) | Umbrales + Turnbull + rejilla; derivadas (fallo) |
| FPCA | *"Two numbers — how late and how steep — capture 97% of how fertility curves differ."* | No (o media frase) | `fda_02`, tabla §3.1 |
| Clustering funcional | *"Four roads, the same whichever way we summarise the curves."* | Slide 4 (`fda_03`) + "a continuum, not boxes" | ARI, siluetas, Jaccard, sin CNMR, PAM/Ward |
| Profundidad funcional | *"The most unusual paths are crisis paths."* | Como mucho 2 anotaciones | Tabla §3.5, `fda_05` A |
| GAM por ingreso | *"At the same child mortality, poorer countries keep higher fertility."* | Opcional, 1 frase | `fda_06`, AIC, AR(1), advertencias |
| Panel FE | — | No | Placebo y EE agrupados |

**Referencias metodológicas:** Ramsay, J. O. & Silverman, B. W. (2005). *Functional Data Analysis*, 2.ª ed. Springer · Kneip, A. & Ramsay, J. O. (2008). Combining registration and fitting for functional models. *JASA* 103 · Sun, Y. & Genton, M. G. (2011). Functional boxplots. *JCGS* 20 · López-Pintado, S. & Romo, J. (2009). On the concept of depth for functional data. *JASA* 104 · Febrero-Bande, M., Galeano, P. & González-Manteiga, W. (2008). Outlier detection in functional data by depth measures. *Environmetrics* 19 · Hennig, C. (2007). Cluster-wise assessment of cluster stability. *CSDA* 52 · Turnbull, B. W. (1976). *JRSS-B* 38 · Wood, S. N. (2017). *Generalized Additive Models*, 2.ª ed. CRC.
