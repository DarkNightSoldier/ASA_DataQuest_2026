# Resultados Q2 — *Can a single indicator tell the whole story?* (P8 + P5)

> Agente `notebook-Q2` · 2026-10-23 · Script: `R/03_q2_un_numero.R` (se ejecuta de principio a fin con `Rscript R/03_q2_un_numero.R` desde la raíz del repo; **113–192 s** según la carga de la máquina (última corrida de verificación: 191,8 s con otros agentes en paralelo), sin errores ni avisos; tres corridas seguidas dan el mismo `numbers_q2.json` y el mismo registro de consola byte a byte, ver §10).
> Cifras: `figures/numbers_q2.json` (96 claves, esquema v2, `verified: false` hasta QA-stats). Tablas: `data/processed/resultados_q2_*.parquet` (columnas documentadas al inicio del script) y `figures/lookalikes_todos.csv`. Figuras de revisión (no finales): `figures/review/q2/q2_01…q2_13.png` (1600×900), revisadas una a una.
> Universo: **161 países ≥ 1 M** (población 2023), **2023**, estimaciones de la ONU, salvo que se diga otra cosa. "IC" = intervalo 95 % por **bootstrap por bloques de las 20 subregiones ONU** (B = 2 000, semilla 2026; el que puede salir en pantalla). "iid" = bootstrap de países (BCa o percentil), solo para comparar. Los intervalos describen *sensibilidad a qué países (o regiones) entran*, no error muestral. Todo es descriptivo; ningún resultado es causal.

---

## 0. Resumen en 6 líneas

1. **La fecundidad sola cuenta la historia lenta, no la rápida (H6 ✔):** explica el 77 % de las diferencias de edad mediana [IC 67–84 %], el 59 % del crecimiento de 2023 [31–80 %] y nada de la migración (−0,001 [−0,01; 0,08]).
2. **Lo lento es estable y lo rápido no:** en cada año 1950–2023 el R² de la edad mediana va de 0,73 a 0,81; el del crecimiento salta de 0,01 (1990) a 0,69 (2020).
3. **Un número no encuentra a tus parecidos (H20 ✔):** con la TFR sola se recupera el **13 %** de los 5 vecinos reales [IC 9–18 %]; con dos ejes del PCA, el **43 %** [40–46 %]; azar, 3 %. En 90 de 161 países la TFR no acierta **ninguno**. Colombia: por TFR ≈ Francia, Australia, Türkiye, EE. UU., Nueva Zelanda; por 12 indicadores ≈ Irán, Perú, Ecuador, Panamá, Túnez (0 en común).
4. **Dos dimensiones reales (H7a ✔, H7 ✘):** PC1 = 56,7 % [51,4; 62,6], dos ejes = 74,6 %; exactamente 2 autovalores superan al ruido; r(TFR, PC1) = −0,94 y r(TFR, PC2) = 0,03. El % del PC1 va de 46 % a 77 % según las variables: no es cifra titular.
5. **La tasa bruta de mortalidad cambió de significado (H13 ✔):** ρ(CDR, LEx) = −0,97 en 1950 y 0,07 en 2023 [−0,31; 0,32]; Portugal y Chad tienen la misma CDR (11,1 y 11,0) y 27 años de diferencia en esperanza de vida.
6. **P5: los pesos deciden (H8a ✔, H8 ✘):** en 2 000 diseños razonables del índice, el **21,7 %** de los países (35 de 161) puede moverse más de 20 puestos; si solo cambian las fórmulas (normalización y agregación), el 2,5 %.

---

## 1. Datos y decisiones (sección 1 del script)

**Qué hicimos.** Corte 2023 de los 161 países ≥ 1 M con los 12 indicadores fijos del plan (`VARS_PCA`, densidad en log) y las 4 salidas de H6. La CNMR se winsoriza a ±3 DE **solo** para PCA y look-alikes.

| Decisión | Valor | Clave |
|---|---|---|
| Países con CNMR recortada (2023) | 7: ARE, ARM, OMN, SDN, SSD, SYR, TCD | `n_cnmr_winsorized_2023` |
| Residuo máximo de la identidad crecimiento ≈ (CBR − CDR + CNMR)/10 | 0,0019 puntos | (en `r2_all.sens_note`) |
| Sensibilidad a la winsorización | `asinh(CNMR/5)` | casos "asinh" en PCA y look-alikes |
| R² | **ajustado** (lo que dice H6); el no ajustado va en `sens_note` | — |

**Lectura.** La winsorización toca a los mismos 7 países que documentó el memo multivariado. Cambiarla por `asinh` casi no mueve nada (PC1 56,9 % vs 56,7 %; look-alikes por TFR 13,7 % vs 13,2 %).

---

## 2. S1 · Scorecard "qué explica la fecundidad sola" (H6, pre-specified)

**Qué hicimos.** Cuatro regresiones simples sobre la TFR de 2023, con las salidas fijadas antes del cálculo (H6). IC por bloques de subregión, BCa iid, validación cruzada 10-fold × 20 y por bloques (dejar fuera una subregión entera), más spline, 237 países, 1990 y sin Golfo.

| Salida (2023, 161) | R² ajustado | IC bloques 95 % | iid BCa | VC 10-fold × 20 | VC por subregión | Spline 3 gl | 237 países | 1990 (observado) | Sin Golfo |
|---|---|---|---|---|---|---|---|---|---|
| Edad mediana | **0,771** | [0,675; 0,835] | [0,728; 0,806] | 0,766 | 0,738 | 0,864 | 0,714 | 0,772 | 0,775 |
| Cambio % 2023→2050 (proyección) | **0,881** | [0,752; 0,941] | [0,824; 0,911] | 0,878 | 0,868 | 0,890 | 0,760 | 0,397 (cambio 1990→2017) | 0,915 |
| Crecimiento | **0,590** | [0,309; 0,805] | [0,439; 0,703] | 0,581 | 0,551 | 0,596 | 0,357 | 0,012 | 0,689 |
| CNMR | **−0,001** | [−0,007; 0,084] | [−0,006; 0,038] | −0,027 | −0,061 | −0,001 | 0,013 | −0,006 | −0,005 |

Claves: `r2_tfr_medage`, `r2_tfr_chg2050`, `r2_tfr_growth`, `r2_tfr_cnmr` (+ `_cv`, `_cv_loso`). Figura: `q2_01_scorecard.png`.

**Estabilidad en el tiempo (exploratorio).** El mismo R² calculado en cada año 1950–2023 y el análogo **observado** del cambio a 27 años:

| Serie (161 países, estimaciones) | Mínimo | Mediana | Máximo | Clave |
|---|---|---|---|---|
| Edad mediana ~ TFR, cada año | 0,726 (2006) | 0,763 | 0,815 (1965) | `r2_tfr_medage_by_year` |
| Crecimiento ~ TFR, cada año | 0,012 (1990) | 0,327 | 0,694 (2020) | `r2_tfr_growth_by_year` |
| CNMR ~ TFR, cada año | −0,006 | −0,004 | 0,014 | `r2_tfr_cnmr_by_year` |
| Cambio % observado a 27 años ~ TFR del año de origen (1950–1996) | 0,134 (1954) | 0,396 | 0,500 (1979) | `r2_tfr_chg27_observed` |

Figura: `q2_13_r2_by_year.png`.

**Lectura de resultados.**
- H6 se cumple con la estimación puntual (0,771 ≥ 0,7; 0,881 ≥ 0,7; 0,590 ≤ 0,6; −0,001 ≤ 0,1) **y** con la VC (0,766 / 0,878 / 0,581 / −0,027). No hay sobreajuste: la VC baja menos de 0,01.
- El IC por bloques es entre 1,5 y 2,5 veces más ancho que el iid (crecimiento: 0,31–0,80 frente a 0,44–0,70). Esto es lo esperado cuando los vecinos se parecen. Con bloques, el límite inferior de la edad mediana (0,675) queda bajo el umbral de 0,7; el puntual y la VC no.
- **Lento vs rápido, con datos de 74 años:** la edad mediana se explica entre el 73 % y el 81 % en **todos** los años; el crecimiento, entre el 1 % y el 69 % según el año. Hubo años de choque: 1990 (Kuwait −71 %, Liberia −30 %), 1991 (0,04) y 2022 (0,16, el año de la guerra en Ucrania). El 0,59 de 2023 es una foto, no una constante.
- **El 0,88 del cambio a 2050 es en buena parte por construcción.** En la historia observada, la TFR explicó como mucho el 50 % del cambio de los 27 años siguientes (mediana 40 %). La proyección Medium hace que el futuro dependa de la fecundidad mucho más que el pasado. Va al pie de la figura: *"partly by construction"*.
- Con los 237 países, el crecimiento baja a 0,36: los microestados con migración extrema rompen la relación.

### 2.1 La escalera: identidad (nota al pie) vs prueba fuera de tiempo

**Qué hicimos.** Mismo año: crecimiento ~ TFR → +CDR → +CNMR. Fuera de tiempo: el mismo modelo, entrenado con indicadores de 2003 → crecimiento 2011–13, se prueba con 2013 → crecimiento 2021–23 (orígenes 1980 y 1990 como sensibilidad).

| Modelo | Mismo año 2023 (identidad) | 10 años después (2003→2013) | Rango de orígenes 1980 / 1990 / 2003 |
|---|---|---|---|
| TFR | 0,590 | 0,478 | 0,344–0,478 |
| TFR + CDR | 0,697 (`r2_ladder_tfr_cdr`) | **0,567** | 0,372–0,567 |
| TFR + CDR + CNMR | **0,986** (`r2_all`; con CBR 1,000) | 0,471 | 0,368–0,471 |
| Edad mediana sola | — | 0,473 | 0,283–0,473 |
| Crecimiento de hoy | — | −0,158 | −1,735–0,004 |

Figura: `q2_02_identity_vs_out_of_time.png`. Claves `r2_oot_*`.

**Lectura.** El 0,99 es la identidad contable (crecimiento = natalidad − mortalidad + migración); con la CBR en vez de la TFR da 1,000. Para el crecimiento de 10 años después, añadir la migración de hoy **empeora** la predicción (0,567 → 0,471) y el crecimiento de hoy predice peor que la media (−0,16). Se reproduce el memo de series de tiempo (0,48 / 0,57 / 0,47).

---

## 3. La tasa bruta de mortalidad cambió de significado (H13, pre-specified)

**Qué hicimos.** ρ de Spearman entre países de CDR y LEx en cada año 1950–2023, con banda por bloques; 2024–2100 solo como línea gris (escenario, sin banda). Par "misma CDR, máxima diferencia de LEx" elegido por regla entre 12 880 pares.

| Cifra | Valor | IC bloques | iid BCa | Clave |
|---|---|---|---|---|
| ρ(CDR, LEx) 1950 | **−0,974** | [−0,981; −0,939] | [−0,983; −0,963] | `rho_cdr_lex_1950` |
| ρ(CDR, LEx) 2023 | **0,067** | [−0,306; 0,321] | [−0,087; 0,222] | `rho_cdr_lex_2023` (Pearson 0,032) |
| ρ(CDR, edad mediana) 2023 | 0,457 | [0,053; 0,726] | — | `rho_cdr_medage_2023` |
| Primer año con ρ ≥ 0 | 2022 | — | — | `yr_rho_cdr_lex_cross0` |
| ρ(CDR, LEx) 2050 (proyección Medium) | 0,441 (2060: 0,48) | sin IC (escenario) | — | `rho_cdr_lex_2050` |
| Portugal / Chad: CDR | 11,1 / 11,0 por 1 000 | — | — | `cdr_prt`, `cdr_tcd` |
| Brecha de LEx Portugal − Chad | 27,3 años (82,4 vs 55,1) | — | — | `lex_gap_prt_tcd` |

Figura: `q2_03_rho_cdr_lex_by_year.png`.

**Lectura.** H13 se confirma: −0,97 en 1950 (< −0,9) y un IC de 2023 que contiene el 0 con los dos métodos. La correlación se acerca a cero de forma continua y cruza el 0 en 2022. El IC por bloques de 2023 es muy ancho (−0,31 a 0,32): según qué regiones entren, la relación puede salir algo negativa o algo positiva. Lo robusto es que **ya no es −0,97**. La CDR sube con la edad mediana (0,46): en 2023 mide envejecimiento, no salud. El par Portugal–Chad sale por regla (|ΔCDR| ≤ 0,1, máxima |ΔLEx|), no a mano.

---

## 4. S2 · Gemelos demográficos por regla (ilustración, familia F3)

**Qué hicimos.** Búsqueda exhaustiva entre los **12 880** pares de países ≥ 1 M (`n_pairs_twins`). Se publica el top-5 de cada regla en `resultados_q2_gemelos.parquet`. Son ejemplos sin inferencia.

| Regla | Top 1 | Valores | Top 2–5 |
|---|---|---|---|
| R1 · \|ΔTFR\| ≤ 0,05, máxima \|Δ crecimiento\| (`twins`) | **EAU – Bielorrusia** | TFR 1,20 / 1,21 · crecimiento +3,70 % / −0,65 % | EAU–Japón, Esuatini–Siria, EAU–Italia, EAU–Mauricio |
| R2 · \|ΔLEx\| ≤ 0,2, máxima \|Δ edad mediana\| (`twins_lex_medage`) | Bosnia y Herzegovina – Jordania | LEx 77,9 / 77,8 · edad mediana 44,9 / 24,3 | Israel–Portugal (29,1 vs 46,2), Bosnia–Líbano, Croacia–Arabia Saudí, Bosnia–Perú |
| R3 · \|ΔCDR\| ≤ 0,1, máxima \|ΔLEx\| | **Portugal – Chad** | CDR 11,1 / 11,0 · LEx 82,4 / 55,1 | RCA–España, Finlandia–Lesoto, Dinamarca–Sudán del Sur, Lesoto–Puerto Rico |
| R4 · \|ΔTFR\| ≤ 0,03, saldo natural de signo opuesto y el que crece con emigración neta | Bulgaria – El Salvador | TFR 1,75 / 1,78 · saldo natural −5,9 / +8,2 ‰ | Jamaica–Letonia, Ecuador–Georgia… |
| R5 · \|Δ edad mediana\| ≤ 0,3, máxima \|ΔTFR\| | El Salvador – Uzbekistán | edad mediana 27,0 / 26,9 · TFR 1,78 / 3,50 | Guinea Ecuatorial–Timor-Leste… |
| R6 · \|Δ crecimiento\| ≤ 0,02 pp, saldo natural de signo opuesto | Estonia – Sudán | crecimiento 0,00 / 0,02 % · saldo natural −4,1 / +27,2 ‰ | España–Sudán, Georgia–Sudán, Lituania–México, India–Lituania |

Figura: `q2_04_twins_by_rule.png`. Claves: `twin_tfr_are` (1,20), `twin_tfr_blr` (1,21), `twin_growth_are` (+3,70), `twin_growth_blr` (−0,65), `twins_other_rules`.

**Lectura.** La regla principal reproduce EAU–Bielorrusia. La regla 2 da **Bosnia–Jordania**, el par que el storyboard sacó del vídeo; queda en el notebook. El segundo par (Israel–Portugal) sirve si se busca un ejemplo sin el Golfo. R4 y R5 reproducen los pares de El Salvador del memo de demografía. En R6, Sudán aparece tres veces: su crecimiento cercano a cero en 2023 combina un saldo natural de +27 ‰ con la emigración forzada del conflicto (dato de crisis, no "patrón"). El par India–Lituania del memo queda 5.º.

---

## 5. R1 · Prueba de parecidos (look-alikes) — demostración central de P8 (H20)

**Qué hicimos.** Para cada país, sus 5 vecinos más cercanos en los 12 indicadores estandarizados son sus "look-alikes reales". Contamos qué fracción recupera cada resumen (TFR sola, LEx, edad mediana, PC1, PC1+PC2…). Azar = 5/160 = 3,1 %. Empates por orden alfabético de ISO3. Tabla de todos los países en `figures/lookalikes_todos.csv`.

**Decisión documentada sobre el intervalo.** En la primera corrida, el bootstrap por bloques rehacía los vecinos dentro de cada réplica, y quedó **sesgado hacia arriba**: [14; 26] para la TFR, sin contener el 13,2. La causa es que cada réplica conserva ~63 % de países distintos, lo que sube el azar de 3 % a ~5 %. Por eso el IC final remuestrea (por bloques) el solapamiento de cada país con vecinos calculados una sola vez con los 161. La sensibilidad a qué países forman el conjunto se mide aparte, rehaciendo todo sin una subregión cada vez (20 corridas; `resultados_q2_knn_loso.parquet`).

| Resumen | Look-alikes recuperados | IC bloques | iid | Sin una subregión (rango) | Clave |
|---|---|---|---|---|---|
| **TFR sola** | **13,2 %** | [8,6; 17,7] | [10,2; 16,0] | 12,9–15,5 | `knn_tfr` (*say* "one in eight") |
| Esperanza de vida sola | 17,4 % | — | — | — | `knn_lex` |
| Edad mediana sola | 15,0 % | — | — | — | `knn_medage` |
| PC1 (el mejor número posible) | 20,4 % | [17,0; 24,5] | [17,5; 23,2] | 19,9–22,8 | `knn_pc1` |
| TFR + CNMR | 22,0 % | — | — | — | `knn_tfr_cnmr` |
| TFR + CDR | 31,1 % | — | — | — | `knn_tfr_cdr` |
| **PC1 + PC2** | **43,2 %** | [40,1; 46,2] | [39,6; 46,8] | 42,0–46,4 | `knn_pc12` |
| PC1 + PC2 + PC3 | 64,7 % | — | — | — | `knn_pc123` |
| Azar | 3,1 % | — | — | — | `knn_chance` |
| Diferencia PC1+PC2 − TFR | +30,1 puntos | [25,6; 34,9] | [26,0; 34,0] | — | `knn_pc12_minus_tfr` |

Sensibilidades de la TFR (`knn_tfr.sens_note`): k = 10 → 22,4 % (azar 6,2 %) · 1990 → 15,0 % · 2050 (proyección) → 15,3 % · 8 indicadores → 16,8 % · 237 países → 7,8 % (azar 2,1 %) · sin Golfo → 12,6 % · asinh → 13,7 %. La TFR nunca pasa del 17 % con k = 5. PC1+PC2: de 34,4 % (1990) a 57,0 % (8 indicadores).

**Perfil recuperado** (R² medio de los 12 indicadores sobre el resumen; la propia variable cuenta como 1): TFR **0,509** [0,434; 0,572] (spline 0,550) · LEx 0,525 · edad mediana 0,519 · PC1 **0,567** [0,515; 0,626] (coincide con su % de varianza) · PC1+PC2 0,746 [0,717; 0,771]. Claves `recov_tfr`, `recov_pc1`, `recov_pc12`.

**Distribución por país** (`n_knn_tfr_zero`): con la TFR sola, **90 de 161 países (56 %) no recuperan ninguno** de sus 5 look-alikes reales (Wilson: 78–102 países); 48 recuperan 1, 15 recuperan 2 y 8 recuperan 3 o 4. Con PC1+PC2, solo 10 países no recuperan ninguno.

**Ejemplos (ilustración):**

| País | Por TFR sola | Por 12 indicadores | Por PC1+PC2 | En común (TFR vs 12) |
|---|---|---|---|---|
| **Colombia** | Francia, Australia, Türkiye, EE. UU., Nueva Zelanda | Irán, Perú, Ecuador, Panamá, Túnez | Irán, Ecuador, Perú, Panamá, Israel | **0** |
| EAU | Lituania, Italia, Bielorrusia, Japón, Tailandia | Omán, Kuwait, Baréin, Arabia Saudí, Qatar | — | 0 |

Figuras: `q2_05_lookalikes_overlap.png`, `q2_06_colombia_lookalikes.png`.

**Lectura.** H20 se confirma: TFR 13,2 % < 25 % (su IC llega a 17,7 %) y PC1+PC2 43,2 % > 40 %. Pero el límite inferior por bloques de PC1+PC2 es 40,1 %, y quedan por debajo de 40 % el caso 1990 (34,4 %), los 237 países (38,2 %) y el caso sin Golfo (39,4 %). La parte "> 40 %" es frágil; la parte "un número no basta" es muy robusta. Ni el mejor número posible (PC1) pasa del 20 %. Colombia reproduce exactamente el ejemplo del memo: por fecundidad se parece a países ricos de baja fecundidad, y por el perfil completo a sus vecinos de ingreso medio con edad y mortalidad parecidas. **Posicionalidad:** el equipo es de Colombia; se muestra como ilustración y la tabla completa de los 161 países está publicada.

---

## 6. R2 · PCA con el conjunto fijo de 12 variables + análisis paralelo (H7, H7a)

**Qué hicimos.** `prcomp` sobre las 12 variables estandarizadas (161 países, 2023). PC1 se orienta con LEx > 0 y PC2 con CNMR > 0. Análisis paralelo de Horn con 1 000 permutaciones por columna. Los IC por bloques rehacen winsorización, z y PCA, y emparejan los ejes con los originales. Sensibilidades: 6 conjuntos de variables, sin Golfo, 237, asinh, 1950, 1990 y 2050.

| Cifra | Valor | IC bloques | iid (percentil, B = 1 000) | Sensibilidad | Clave |
|---|---|---|---|---|---|
| % varianza PC1 | **56,7 %** | [51,4; 62,6] | [54,9; 59,2] | 46,1–76,6 según el conjunto de variables | `pc1_var` |
| % varianza PC2 | 17,9 % | [11,8; 23,6] | [14,5; 21,5] | 13,3 (sin Golfo)–24,7 | `pc2_var` |
| PC1 + PC2 | 74,6 % | [71,7; 77,1] | [72,2; 77,9] | — | `pc12_var` |
| Componentes para 70 % | **2** | 2 en 1 997 de 2 000 réplicas (3 en 3) | — | 2–3 | `n_pcs_70` |
| Dimensiones sobre el ruido (paralelo) | **2** | — | — | 1–3 | `n_dims_parallel` |
| Autovalores observados vs p95 nulo | 6,80 / 2,15 / 1,15 / 0,83 vs 1,58 / 1,43 / 1,31 / 1,22 | — | — | — | `eigen_pca_12`, `eigen_null_p95_12` |
| r(TFR, PC1) | **−0,945** | [−0,961; −0,901] | [−0,957; −0,930] | −0,96 a −0,90 | `r_tfr_pc1` |
| r(TFR, PC2) | **0,033** | [−0,079; 0,169] | [−0,025; 0,102] | −0,14 a 0,29 (1950) | `r_tfr_pc2` |
| PC2 sin los 6 del Golfo | 13,3 % | — | — | — | `pc2_var_no_gulf` |

**Sensibilidad** (`resultados_q2_pca_sensibilidad.parquet`; figura `q2_09_pca_sensitivity.png`):

| Caso | PC1 | PC2 | Dimensiones | r(TFR, PC1) | r(TFR, PC2) |
|---|---|---|---|---|---|
| 12 fijas (base) | 56,7 | 17,9 | 2 | −0,94 | 0,03 |
| 8 de `config.R` | 53,9 | 24,7 | 2 | −0,94 | −0,14 |
| 8 catálogo (MV) | 65,9 | 18,3 | 2 | −0,96 | −0,08 |
| 8 no redundantes (MV) | 46,1 | 22,7 | 2 | −0,92 | 0,10 |
| 13 del EDA (MV) | 49,1 | 17,3 | 2 | −0,92 | 0,07 |
| 8 núcleo de la transición (INF, sin CNMR) | 76,6 | 15,5 | **1** | −0,96 | — |
| Sin Golfo (155) | 59,1 | 13,3 | **3** | −0,94 | −0,02 |
| 237 países | 53,7 | 17,1 | 2 | −0,92 | 0,01 |
| asinh(CNMR/5) | 56,9 | 17,7 | 2 | −0,94 | 0,05 |
| 1950 | 56,3 | 18,0 | 2 | −0,90 | 0,29 |
| 1990 | 56,3 | 16,0 | **3** | −0,94 | 0,11 |
| 2050 (proyección) | 61,6 | 15,9 | 2 | −0,95 | 0,04 |

Cargas (PC1): CBR −0,37, LEx +0,37, TFR −0,36, edad mediana +0,36, Q5 −0,35. PC2: razón de sexos +0,56, CDR −0,49, CNMR +0,45, crecimiento +0,38. Figuras: `q2_07_parallel_analysis.png`, `q2_08_pca_biplot.png`.

**Lectura.** H7 (formulación v1: PC1 < 50 % y 3 componentes para 70 %) **se rechaza**: PC1 = 56,7 % y bastan 2 componentes (74,6 %). H7a **se confirma** en el caso base: exactamente 2 autovalores superan al ruido (6,80 y 2,15 frente a 1,58 y 1,43; el tercero, 1,15, queda bajo 1,31), la TFR es casi el eje 1 (−0,945) y es ciega al eje 2 (0,03). Matices: (i) el % del PC1 va de 46 % a 77 % según qué variables entren, así que la cifra titular es la estructura ("dos dimensiones reales"), no el porcentaje; (ii) el número de dimensiones va de 1 (sin migración entre las variables) a 3 (sin el Golfo y en 1990); (iii) el eje 2 depende en parte de 6 países: sin el Golfo baja de 17,9 % a 13,3 %. Con bloques, el IC del PC1 (51–63) es unas 2,8 veces más ancho que el iid.

---

## 7. R3 · Índice compuesto (P5) y su fragilidad (H8, H8a)

**Qué hicimos.** Un índice de **avance de la transición** (no de desarrollo ni de bienestar) con TFR (−), Q5 (−), LEx (+), edad mediana (+) y crecimiento (−). (a) Las 7 variantes a mano del EDA v1: z, min–max, rangos, pesos por dimensión, pesos del PC1, + migración neta y media geométrica. (b) Un Monte Carlo de 2 000 diseños (OCDE/JRC).

**(a) Siete variantes** (`share_rank_7var`, `rho_rank_7var_min`; figura `q2_10_index_seven_variants.png`):

| Medida | Valor |
|---|---|
| ρ de Spearman mínima entre rankings | 0,970 (0,989 sin la variante con migración) |
| % de países que se mueve > 20 puestos entre las 7 | **9,3 %** (15 de 161; Wilson [5,7; 14,8]) |
| … solo normalización/agregación (V1, V2, V3, V7) | 1,2 % |
| … solo pesos (V1, V4, V5) | 3,1 % |
| … añadir la migración neta (V6 vs V1) | 8,1 % |
| Caso destacado por regla (mayor salto sin la variante de migración) | **EAU**: puestos 51–81 (30 puestos) (`index_highlight`) |

**(b) Monte Carlo de 2 000 diseños** (`share_rank_mc20`, `share_rank_mc20_sens`; figura `q2_11_index_monte_carlo.png`):

| Especificación | Ancho mediano del intervalo 90 % de rango | % con ancho > 20 puestos |
|---|---|---|
| **Declarada (H8a):** pesos Dirichlet(5) + normalización + agregación + inclusión aleatoria del crecimiento | 12 | **21,7 %** (35 de 161; Wilson [16,1; 28,7]) |
| Pesos iguales; solo normalización y agregación | 4 | 2,5 % |
| Dirichlet(5) con los 5 indicadores fijos | 10 | 17,4 % |
| Dirichlet(1) (pesos muy dispersos) + inclusión | 19 | 47,2 % |

Más inciertos (declarada): EAU 28–98, Omán 67–116, **Ucrania 8–54** (`rank_range_ukr`; con Dirichlet(1), 4–68), Bielorrusia 14–52, Singapur 6–43, Qatar 37–73, Armenia 57–92, Moldova 48–80. Robustos arriba: Hong Kong, Japón, Italia, Rep. de Corea, España. Robustos abajo: R. D. del Congo, Malí, Nigeria, RCA, Níger, Somalia, Chad.

**Fiabilidad y validez (solo notebook):** α estandarizado = 0,952 (4 ítems 0,962; 3 ítems 0,956); ω = 0,954; pesos efectivos TFR 0,217 · edad mediana 0,211 · Q5 0,207 · LEx 0,201 · crecimiento 0,165 (nominal 0,20); validez convergente ρ(índice, LE60) = **0,867** [0,734; 0,913]. Claves `alpha`, `omega`, `index_eff_weights`, `rho_index_le60`.

**Lectura.** H8 (v1: "1 de cada 4 países se mueve > 20 puestos con 7 variantes") **se rechaza como cifra**: con los 161 países ≥ 1 M sale el 9,3 %. El 24 % del EDA venía de los 237 países, donde los microestados (San Martín, etc.) saltan decenas de puestos. H8a **se confirma**: 21,7 % ≥ 10 % y muy por encima del 2,5 % de "solo fórmulas". Lo que mueve el ranking son los **pesos** (17,4 % con Dirichlet(5) y 47,2 % con Dirichlet(1)) y la inclusión de la migración, no la normalización. Un α de 0,95 convive con esa fragilidad: un α alto no hace robusto un ranking. Ucrania (caso del plan) sigue siendo de los más inciertos (3.º). La regla escrita en código elige EAU como caso destacado; Ucrania sirve para el bump chart si se prefiere un país fuera del Golfo.

---

## 8. Hallazgo de demografía: misma fecundidad, saldo natural opuesto (dem01)

**Qué hicimos.** Entre los países ≥ 1 M con TFR de 1,5 a 1,99 (2023), medimos el rango del saldo natural y su relación con la edad mediana. Entre los que están bajo reemplazo (TFR < 2,1), comparamos qué explica la TFR sola y qué explican la TFR y la edad mediana juntas.

| Cifra | Valor | IC bloques | Clave |
|---|---|---|---|
| Países con TFR 1,5–1,99 | 39 | censo | `n_band_tfr` |
| Saldo natural mínimo / máximo | **−5,9 ‰ (Bulgaria) / +12,4 ‰ (Nepal)** | — | `nat_min_band`, `nat_max_band` |
| r(saldo natural, edad mediana) en esa banda | −0,91 | [−0,96; −0,80] | `r_nat_medage_band` |
| Bajo reemplazo: R² ajustado del saldo natural ~ TFR | **0,36** (sin ajustar 0,37) | [0,19; 0,60] | `r2_nat_tfr_belowrepl` |
| ~ TFR + edad mediana | **0,83** | [0,73; 0,90] | `r2_nat_tfr_medage_belowrepl` |

Figura: `q2_12_same_fertility_natural_change.png`.

**Lectura.** Con la misma fecundidad, el saldo natural va de −5,9 a +12,4 por 1 000 y sigue a la edad mediana (r = −0,91). Entre los países bajo reemplazo, la TFR sola explica un tercio de las diferencias de saldo natural; con la edad mediana, más de cuatro quintos. Se reproducen las cifras del memo de demografía (37 % → 83 %).

---

## 9. Redundancia (solo notebook)

VIF de las 12 variables: LEx 335, CBR 200, crecimiento 131, TFR 81 (`vif_max_12`). Correlación parcial TFR–LEx dadas las otras 6 no redundantes: +0,10 (simple: −0,85) (`partial_r_tfr_lex`). Varias variables son casi duplicados mecánicos, y por eso el PCA se lee como estructura y no como "efectos" separados.

---

## 10. Estado de las hipótesis preinscritas de Q2

| ID | Estatus | Resultado | Evidencia (cifras reales) |
|---|---|---|---|
| **H6** | pre-specified | **Confirmada** (con matiz) | R² ajustado 0,771 / 0,881 / 0,590 / −0,001; VC 0,766 / 0,878 / 0,581 / −0,027. Matiz: el 0,88 de 2050 es en parte por construcción (observado a 27 años: ≤ 0,50) y el R² del crecimiento cambia mucho de un año a otro (0,01–0,69). |
| **H7** | pre-specified | **Rechazada** | PC1 56,7 % [51,4; 62,6] (no < 50 %); bastan 2 componentes para 70 % (74,6 %). |
| **H7a** | exploratory | **Confirmada** (con matiz) | 2 dimensiones (6,80 / 2,15 vs ruido 1,58 / 1,43); r(TFR, PC1) = −0,945; r(TFR, PC2) = 0,033. Sensibilidad: de 1 a 3 dimensiones según el caso. |
| **H8** | pre-specified | **Rechazada como cifra** | 7 variantes: 9,3 % (no ≈ 24 %); el 24 % era un efecto de los microestados. |
| **H8a** | pre-specified | **Confirmada** | Monte Carlo declarado 21,7 % ≥ 10 % y > 2,5 % (solo fórmulas). |
| **H13** | pre-specified | **Confirmada** | 1950 −0,974 [−0,981; −0,939]; 2023 0,067 [−0,306; 0,321] (iid [−0,087; 0,222]). |
| **H20** | exploratory | **Confirmada** (con matiz) | TFR 13,2 % [8,6; 17,7] < 25 %; PC1+PC2 43,2 % [40,1; 46,2] > 40 %; azar 3,1 %. La parte "> 40 %" no se cumple en 1990 (34 %), con 237 países (38 %) ni sin Golfo (39 %). |

Tabla en `resultados_q2_hipotesis.parquet` y clave `hyp_q2_status`; `n_tests_q2` = 7. No se calculan p-valores. Las ilustraciones (gemelos, Colombia, país destacado) son familia F3 y no se contrastan.

**Reproducibilidad.** `set.seed(2026)` justo antes de cada bloque aleatorio; generador Mersenne-Twister / Inversion / Rejection. Dos corridas seguidas producen el mismo `numbers_q2.json` (sha256 `1532abfe…d829`) y el mismo `lookalikes_todos.csv`. `sessionInfo()` en `figures/review/q2/sessionInfo_q2.txt`.

---

## 11. Hallazgos sorprendentes (nuevos respecto a los memos)

1. **La proyección "cree" en la fecundidad más que la historia.** La TFR de 2023 explica el 88 % del cambio de población proyectado a 2050, pero en 47 ventanas observadas de 27 años (1950→1977 … 1996→2023) nunca explicó más del 50 % (mediana 40 %). El "partly by construction" del pie ya tiene número.
2. **El R² del crecimiento sobre la TFR no es una constante:** va de 0,01 (1990: Kuwait −71 %, Liberia −30 %) a 0,69 (2020), con 0,16 en 2022 (año de la guerra en Ucrania). El de la edad mediana se queda entre 0,73 y 0,81 en los 74 años. Esto da la prueba empírica de "historia lenta vs palancas rápidas".
3. **En 90 de 161 países (56 %) la fecundidad sola no encuentra ni uno** de sus 5 look-alikes reales.
4. **El "1 de cada 4" del índice (EDA v1) era un efecto de los microestados:** con los 161 países ≥ 1 M, las 7 variantes mueven solo al 9 %. La fragilidad aparece cuando se admite incertidumbre en los **pesos** (Monte Carlo: 22 %).
5. **Los intervalos por bloques son mucho más anchos que los iid** en las correlaciones que cambian de significado: ρ(CDR, LEx) 2023 [−0,31; 0,32] frente a [−0,09; 0,22] (≈ 2×), y PC1 [51; 63] frente a [55; 59] (≈ 2,8×). Para el scorecard, la relación es de 1,5 a 2,5×.
6. **El bootstrap ingenuo de los vecinos más cercanos está sesgado:** rehacer los vecinos en réplicas con países repetidos da [14; 26] para un valor de 13. Se corrigió y se documentó (§5); los agentes que usen kNN en otras preguntas deberían saberlo.
7. La regla de gemelos con misma LEx devuelve **Bosnia–Jordania**, el par retirado del vídeo; la regla de "mismo crecimiento, motores opuestos" devuelve tres veces **Sudán** (crisis), no el India–Lituania del memo.

---

## 12. Limitaciones

1. **Corte transversal de un año (2023):** el R² del crecimiento depende mucho del año (§2). Las cifras de edad mediana son estables; las de crecimiento, no.
2. **R² lineal:** con un spline natural la edad mediana sube a 0,864; la TFR "pierde" algo por la linealidad. Se reporta el ajustado lineal porque así se pre-especificó H6.
3. **Proyecciones como salida:** el cambio 2023→2050 y los casos de 2050 (PCA, look-alikes, ρ CDR–LEx) son un escenario Medium construido en parte con la fecundidad; nunca son evidencia.
4. **Migración:** la CNMR es el componente peor medido (a menudo un residuo censal). El eje 2 del PCA y los look-alikes del Golfo dependen de 6 países y de la winsorización (comprobado con asinh y sin Golfo).
5. **Bootstrap por bloques con 20 subregiones:** con pocos bloques, los percentiles son inestables y los intervalos, anchos. Describen sensibilidad a la composición regional, no error muestral (los 161 países no son una muestra).
6. **Look-alikes:** dependen de las 12 variables, de k y del desempate alfabético. El IC final no capta cómo cambia el conjunto de vecinos; eso lo cubre la sensibilidad sin una subregión (12,9–15,5 % para la TFR).
7. **Índice:** las distribuciones del Monte Carlo (Dirichlet(5), 50 % de inclusión del crecimiento) son decisiones; por eso se dan 2,5–47 %. Es un índice de etapa de la transición, no de desarrollo; nunca tabla de liga ni rojo/verde.
8. **Gemelos y Colombia:** son ilustraciones elegidas por regla (12 880 pares) o por posicionalidad declarada. No se hace inferencia sobre ellos.
9. **Calidad de datos:** Chad y Sudán (2023) reflejan desplazamiento forzado; la CDR de países en crisis puede venir de ajustes de la ONU. RCA aparece en R3 (2.º par) y no se usa como ejemplo (posible artefacto, `07` §4.2 V1).

---

## 13. Frases en inglés propuestas para el vídeo (cifras reales sustituidas)

**Narración Slide 3 (storyboard v2, con valores finales):**
> Question two: can one number tell the story? Take fertility. Across countries, it captures the slow story, **three quarters** of the differences in age structure, but only **60** percent of today's growth and **almost nothing** of migration. The Emirates and Belarus share the same fertility; one grows almost **four** percent a year, the other shrinks. Search each country's five closest look-alikes by fertility alone and you find only **one in eight** of its real look-alikes. By fertility, Colombia resembles **France, Australia and Türkiye**; by twelve indicators, **Iran, Peru and Ecuador**. The data hold **two** real dimensions: fertility sits on the first, the transition, and is blind to the second, migration. A composite index depends on its weights: **one country in five** can move twenty places.

**Alternativas más robustas (si hay tiempo o si QA-stats lo pide):**
- Crecimiento, sin depender de un solo año: *"…but between almost nothing and seventy percent of growth, depending on the year we look at."* (`r2_tfr_growth_by_year`: 0,01–0,69).
- Look-alikes, versión por país: *"For more than half of all countries, fertility alone finds none of their five real look-alikes."* (`n_knn_tfr_zero` = 90 de 161).
- Pie del scorecard (identidad + proyección): *"Births − deaths + migration together reach 0.99: an accounting identity. The 2050 change is partly built from fertility — in the past, fertility explained at most half of the next 27 years' change."*
- Línea CDR: *"Even the death rate changed meaning: Portugal and Chad share it (11.1 vs 11.0 per 1,000) but are 27 years apart in life expectancy."*
- Misma fecundidad: *"Same fertility, opposite directions: among countries with 1.5 to 2 children per woman, births minus deaths runs from −6 to +12 per 1,000 — set by age structure."*

**Textos en pantalla (valores finales):**
- Scorecard: `Age structure today 0.77 · Population change 2023→2050 (UN projection) 0.88 · Growth rate today 0.59 · Net migration today 0.00`; bigotes = bloques de subregión (0,67–0,84 / 0,75–0,94 / 0,31–0,80 / −0,01–0,08).
- Métrica: `For the average country, fertility alone finds 13 % of its 5 real look-alikes (12 indicators) · two axes: 43 % · chance: 3 %`.
- Gemelos: `UAE · Belarus — same fertility 1.20 vs 1.21 → growth +3.70 % vs −0.65 %` · `twins chosen by rule from 12,880 pairs (≥ 1 M)`.
- PCA: `2 axes beat noise · fertility ≈ axis 1 (r = −0.94) · blind to axis 2 (r = 0.03)`; gris: `axis 1 = 57 % of the variation (46–77 % depending on which indicators enter)`. **Ojo:** el storyboard decía 46–66 %; con el conjunto "núcleo de la transición" del memo de inferencia el máximo es 77 %.
- P5: `Composite index (5 indicators, 2,000 reasonable designs): weights, not formulas, decide — 22 % of countries can move more than 20 places · a transition-stage index, not a ranking of development or well-being`.
