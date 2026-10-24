# Resultados Q3 — *Same road, different speed: four roads and what the UN should watch* (P6 + P1 + recomendaciones)

> Agente `notebook-Q3` · 2026-10-23 · Script: `R/04_q3_caminos.R`. Se ejecuta de principio a fin con `Rscript R/04_q3_caminos.R` desde la raíz del repo. Tarda **179–190 s** según la carga de la máquina (última corrida: 186,4 s, con otros agentes en paralelo). Termina sin errores ni avisos. Dos corridas seguidas dan la misma salida de consola, salvo los tiempos.
> Cifras: `figures/numbers_q3.json` (**109 claves**, esquema v2 de 36 campos; `verified: false` hasta que pase QA-stats). No hay ninguna clave repetida con `numbers_q1.json` ni con `numbers_q2.json`. Tablas: `data/processed/resultados_q3_*.parquet` (12 tablas, con las columnas documentadas al inicio del script) y `figures/miembros_grupos.csv`. Figuras de revisión (no son las finales): `figures/review/q3/q3_01…q3_18.png` (1600×900). Revisamos cada una a mano.
> Universo: **161 países ≥ 1 M** (población 2023), estimaciones de la ONU 1950–2023, salvo que se diga otra cosa. Los conteos de países usan los **237 países y áreas**. La proyección Medium 2024–2100 va siempre aparte y etiquetada (*UN medium projection*). "IC" = intervalo 95 % por **bootstrap por bloques de las 20 subregiones ONU** (B = 2 000, semilla 2026); es el único que puede salir en pantalla. "iid" = bootstrap BCa por país, solo para comparar. Todo es descriptivo: nada de lo que sigue es causal.

---

## 0. Resumen en 7 líneas

1. **Tres tramos de un mismo camino y un grupo migratorio (H9a ✔).** El k-means con k = 4 sobre 70 años de trayectoria da una silueta de **0,37** (con k = 2 sería 0,44; el estadístico gap elige k = 3). Los tamaños son 50 / 51 / 53 / 7 y las poblaciones 1,44 / 4,90 / 1,67 / 0,07 mil M. **India está en Fast movers.** Los grupos son estables (Jaccard 0,78–0,95; FPCA ARI 0,96). Aun así, el **42 %** de los países está entre dos grupos: es un continuo, no cajas.
2. **"Mostly Gulf states" se cumple.** Migration-led = Arabia Saudí, Jordania, EAU, Kuwait, Catar, Baréin y Yibuti: **5 de 7** son del Consejo de Cooperación del Golfo. Omán queda en Fast movers.
3. **Los vecinos comparten camino (H25 ✔).** El **66,7 %** de los enlaces entre vecinos une países del mismo grupo; al azar sería el 30,3 % (banda 26,5–34,5 %), 2,2 veces más. Pero la región ODS sola acierta el 77,5 %, más que el voto de los 5 vecinos (73,9 %). La geografía que importa es la regional.
4. **P1: depende del indicador (H10 ✔, H11a ✔).** Entre países, la DE de la esperanza de vida bajó de **12,2 a 7,4** años y la de la edad mediana subió de **4,7 a 9,7**. La DE de la esperanza de vida a los 65 subió de **1,47 a 2,85**. Para la mortalidad infantil, la razón P90/P10 pasó de **6× a 20×**, aunque la brecha absoluta se cerró de 311 a 64 por mil.
5. **Misma ruta, distinto ritmo.** De 5 a 3 hijos por mujer, China tardó **5,1 años** y Egipto **32,7**. Son el más rápido y el más lento de los 36 países ≥ 10 M que completaron el tramo: la regla se confirma. La mediana de Kaplan-Meier es de 19,2 años en Fast movers y 29,6 en Recent movers.
6. **Envejecer de 30 a 40 años de edad mediana, por camino:** Fast movers **32 años** [27; 37] frente a Early movers **36,5** [29; 42,5]. Esta diferencia es pequeña. La que sí es grande es la de **fecha de inicio**: quienes llegaron a 30 en 1990–2023 tardan 24 años, y quienes llegaron antes de 1990 tardaron 40,5. Los Fast movers que ya están en 30 tardan 23,5.
7. **Qué vigilar.** 58 de 70 países con mortalidad infantil > 25 ‰ seguirán por encima en 2030 incluso en la proyección; solo 8 bajan al ritmo necesario (H23 ✔). Hay 22 países bajo reemplazo que aún crecen por nacimientos (2,2 mil M), con **34–38 años más** de crecimiento proyectado. Los países con más muertes que nacimientos pasaron de **8 a 53** (H14a ✔) y en ellos vive el 28 % de la humanidad; serían 106 en 2050 (proyección). El mundo llegaría a su máximo en **2084**, con **10,29 mil M** (proyección).

---

## 1. Datos y rasgos de trayectoria (sección 1)

**Qué hicimos.** Armamos un panel de los 161 países ≥ 1 M para 1950–2023 con TFR, LEx, edad mediana y CNMR. Cada variable se estandariza (z) con la media y la DE de **todo el panel**. Luego se promedia por década (1950s…2010s, 2020–23): son 32 rasgos por país. La CNMR se winsoriza a ±3 DE del panel, solo para el clustering.

| Decisión | Resultado | Clave |
|---|---|---|
| Límites de la winsorización de CNMR | [−46,7; 47,5] por mil | `n_cnmr_winsor_cells` |
| País-años recortados | **144**, en 32 países (QAT 25, ARE 22, KWT 17, DJI 9, HKG 8, JOR 8, AFG 5, BHR 5) | `n_cnmr_winsor_cells` |
| Sensibilidad asinh(CNMR/5) | ARI 0,934 con la partición principal | `ari_asinh` |
| Sin winsorizar | ARI 0,925 (el grupo pequeño queda en ARE, KWT, QAT) | `ari_asinh.sens_note` |

**Lectura de resultados.** La winsorización toca sobre todo al Golfo y a Hong Kong (8 país-años; incluye los ajustes censales de 1961–69, ver `02_contexto_historico.md`). Cambiar la transformación casi no mueve los grupos (ARI 0,93).

---

## 2. Elección de k (sección 2)

**Qué hicimos.** Comparamos k = 2…8 con la silueta (k-means, Ward, PAM), el estadístico gap (B = 100, regla 1-SE de Tibshirani) y Mclust (BIC sobre 4 componentes principales). k = 4 estaba fijado a priori (H9a).

| k | Silueta k-means | Silueta Ward | Silueta PAM | Tamaño mínimo |
|---|---|---|---|---|
| 2 | **0,442** | 0,447 | 0,450 | 74 |
| 3 | 0,362 | 0,340 | 0,357 | 49 |
| **4** | **0,372** | 0,354 | 0,294 | 7 |
| 5 | 0,304 | 0,302 | 0,304 | 7 |
| 8 | 0,236 | 0,225 | 0,173 | 3 |

Gap → **k = 3** (`gap_k`). Mclust → G = 5. Figura: `q3_01_k_choice.png`.

**Lectura.** Los datos prefieren dos o tres tramos. k = 4 deja los mismos tres tramos y separa un grupo de 7 países, sobre todo del Golfo. Por eso la frase correcta es *"three stretches of one road, plus a migration-led group"* (plan §12). La silueta es moderada (0,37): hay estructura, pero no fronteras nítidas.

---

## 3. Partición principal y nombres por regla (secciones 3–4)

**Qué hicimos.** Corrimos k-means con k = 4, `nstart = 50` y semilla 2026. Los nombres salen de `nombrar_grupo_v2()`, que usa la mediana del grupo de la CNMR media 2000–23, el año mediano en que la TFR baja de 4 y si la mayoría ya estaba por debajo de 4 en 1950. Los ejemplos son los 3 países más poblados de cada grupo. El medoide es el país más cercano a la mediana del grupo.

| Grupo | n | Población 2023 (mil M; % del mundo) | CNMR mediana 2000–23 (‰) | Año mediano TFR < 4 | Ejemplos (regla) | Medoide |
|---|---|---|---|---|---|---|
| Early movers | 50 | 1,44 (17,8 %) | 1,8 | 1950 (mayoría < 4 en 1950) | United States, Russia, Japan | Slovenia |
| Fast movers | 51 | 4,90 (60,6 %) | −0,9 | 1987 | India, China, Indonesia | Ecuador |
| Recent movers | 53 | 1,67 (20,6 %) | −0,9 | no cruzado / 2023 | Pakistan, Nigeria, Ethiopia | Cameroon |
| Migration-led | 7 | 0,07 (0,8 %) | 22,6 | 1993 | Saudi Arabia, Jordan, UAE | Saudi Arabia |

Claves: `cluster_names`, `cluster_sizes`, `cluster_pop_bn`, `cluster_examples_*`, `cluster_examples_iso3`, `cluster_medoids`, `india_group` (= Fast movers), `migration_led_members`, `n_gulf_migration_led` (= 5 de 7).

**Descripción con variables que el clustering NO usó** (medianas entre países; sin pruebas de significación, porque serían circulares):

| Grupo | Q5 2023 (‰) | LE65 2023 | LE60 2023 | Δ % población 2023→2050 (proy.) | Edad mediana 2050 (proy.) | LE60 2050 (proy.) |
|---|---|---|---|---|---|---|
| Early movers | 3,8 | 19,9 | 23,9 | −6,9 | 47,8 | 27,0 |
| Fast movers | 16,0 | 16,4 | 20,3 | +15,2 | 38,2 | 22,8 |
| Recent movers | 50,3 | 13,5 | 17,0 | +64,4 | 24,6 | 17,7 |
| Migration-led | 6,3 | 18,4 | 23,0 | +39,8 | 32,3 | 26,2 |

Clave: `cluster_profile`. Figuras: `q3_02_groups_small_multiples.png` y `q3_03_groups_map.png`.

**Lectura.**
- Europa y Norteamérica: 36 de 38 países son Early movers. África subsahariana: 40 de 44 son Recent movers, 3 Fast movers (Botsuana, Mauricio y Sudáfrica) y 1 Migration-led (Yibuti). América Latina: 17 de 23 son Fast movers. La V de Cramér con el ingreso FY2027 es 0,58 y con la región 0,66 (solo descriptiva). Los caminos se parecen a la región y al ingreso, pero no son lo mismo.
- Según el tipo de palanca de Q1 en 2023, **ningún Early mover es de tipo B**. 22 de los 50 decrecen con saldo natural negativo (tipo D) y 11 crecen solo por inmigración (tipo C). En cambio, 30 de los 51 Fast movers son de tipo B (crecen por nacimientos sin inmigración neta).
- Si sale la bandera de Nigeria (ejemplo de Recent movers), va con el pie `Nigeria: last census 2006` (V4). Si sale el Golfo, va la nota de revisión de WPP2024 (V11). Las dos notas ya están en `sens_note`.

---

## 4. Validación de los grupos (sección 5)

**Qué hicimos.** Repetimos el agrupamiento con otro resumen de las curvas (FPCA multivariada), con otros algoritmos, con remuestreo de países, con pertenencia difusa, sin la migración, con los niveles de 2023 y con una rejilla de 32 combinaciones. También probamos agrupar por velocidades (intento descartado).

| Validación | Resultado | Clave |
|---|---|---|
| FPCA multivariada (B-splines, λ = 10) + k-means con 6 componentes (90,7 % de la varianza) | **ARI 0,963** (0,963 con λ = 1 y con λ = 100) | `ari_fpca_decadas` |
| Ward / PAM / Mclust (G = 5) | ARI 0,63 / 0,73 / 0,45 | `ari_ward`, `ari_pam` |
| Jaccard bootstrap (B = 200) | Early 0,95 · Fast 0,85 · Recent 0,92 · **Migration-led 0,78** | `jaccard_min`, `jaccard_max`, `jaccard_by_group` |
| Jaccard con Ward | 0,79 / 0,77 / 0,62 / 0,66 | (consola) |
| `keep_share` ≥ 0,8 (500 submuestras al 80 %, emparejamiento húngaro) | **95,7 %** de los países (70 %: 94,4 %; 90 %: 96,3 %) | `share_keep_ge_0.8` |
| Países frontera (`keep_share` < 0,8) | KOR, NPL, CHL, BWA, GTM, BOL, ARM | `borderline_countries` |
| Silueta en submuestras al 80 % | P2,5–P97,5: 0,31–0,40 | `silhouette.sens_*` |
| Pertenencia difusa (fanny) máxima < 0,6 | **42,2 %** (umbral 0,5: 23,6 %; 0,7: 59,6 %) | `share_between_groups` |
| Silueta individual < 0,1 / negativa | 11,2 % / 7 países (BHR, DJI, GTM, JOR, KOR, NPL, SAU) | `share_sil_lt_0.1` |
| R² del eje 1 de los rasgos (67 % de la varianza) sobre el grupo | **0,90** | `r2_groups_axis1` |
| Sin CNMR (24 rasgos) | ARI **0,54**; silueta 0,40; Migration-led se disuelve (Jaccard máx. 0,10) | `ari_sin_cnmr` |
| Trayectorias frente a niveles de 2023 | ARI **0,59** (z del panel: 0,64) | `ari_tray_niveles` |
| Rejilla {k-means, Ward, PAM, FPCA} × {161, 237} × {con, sin CNMR} × {décadas, quinquenios} | ARI 0,49–1,00. Con CNMR y 161 países: k-means 0,98–1,00, FPCA 0,96, PAM 0,72–0,73, Ward 0,52–0,63. Sin CNMR: 0,49–0,73 | `resultados_q3_sensibilidad.parquet` |
| Velocidades (derivadas de las curvas suavizadas) | Silueta 0,46, pero los tamaños son **139 / 9 / 7 / 6**, el ARI es 0,07 y el Jaccard 0,37–0,91 | `silhouette_speed_clusters` |

Figuras: `q3_04_continuum.png`, `q3_05_stability.png` y `q3_06_sensitivity_grid.png`.

**Lectura.**
- Los grupos no dependen de resumir por décadas (FPCA 0,96) ni de la semilla, y vuelven al remuestrear: los 4 tienen Jaccard ≥ 0,75. Lo que más los mueve es **quitar la migración** (ARI 0,54). En ese caso desaparece Migration-led: EAU, Baréin, Kuwait y Catar se juntan con los de caída rápida de la TFR (ese grupo se llamaría "Sprinters", pero solo en esta sensibilidad).
- "Un continuo, no cajas" queda cuantificado: el 90 % del eje principal se explica por el grupo, pero 4 de cada 10 países tienen pertenencia máxima < 0,6. Corea es el caso frontera más claro (`keep_share` 0,49, silueta −0,01).
- **Agrupar por velocidades encuentra choques, no caminos.** Salen un grupo grande de 139 países y tres pequeños: [AFG HKG JOR KHM MOZ RWA SGP], [ARE ARM KWT LBN OMN QAT SAU SSD VEN] y [BHR BWA DJI GNB LBY PSE]. La silueta alta (0,46) la producen los atípicos. Por eso se descarta, como anticipaba el memo FDA.
- Con los 237 países el k-means da ARI 0,81: los microestados (sobre todo islas con migración extrema) mueven las fronteras.

---

## 5. Contigüidad espacial de los caminos (sección 6; H25, exploratoria)

**Qué hicimos.** Para cada país tomamos sus 5 vecinos más cercanos (distancia de gran círculo entre puntos de etiqueta de Natural Earth). Calculamos la proporción de enlaces vecino→vecino con el mismo grupo y la comparamos con 999 permutaciones de las etiquetas. Como referencia "para no exagerar", calculamos también el voto de los vecinos frente a la región y el ingreso.

| Medida | Observado | Azar (permutación) | Clave |
|---|---|---|---|
| Enlaces kNN5 del mismo camino | **0,667** | 0,303 (banda 95 %: 0,265–0,345; p = 0,001) | `join_same_road`, `join_same_road_null` |
| Razón observado / azar | **2,20** | — | `join_same_road_ratio` |
| Sensibilidad de W | kNN8 0,657 · contigüidad 0,701 · distancia inversa ≤ 2 000 km 0,680 · grupos sin CNMR 0,570 (azar 0,249) | — | `join_same_road.sens_note` |
| Por grupo | Early 0,72 (azar 0,31) · Fast 0,55 (0,31) · Recent 0,75 (0,33) · Migration-led 0,54 (0,04) | — | `join_same_road_by_group` |
| Voto de los 5 vecinos | 0,739 | 0,309 (P97,5 0,392); clase mayoritaria 0,329 | `knn_vote_accuracy` |
| Mayoría de la región ODS (dejando fuera al país) | **0,775** | — | `region_vote_accuracy` |
| Ingreso / región × ingreso | 0,744 / 0,847 | — | `knn_vote_accuracy.sens_note` |

Figuras: `q3_03_groups_map.png` y `q3_07_neighbours.png`.

**Lectura.** Dos de cada tres enlaces entre vecinos comparten camino; al azar sería uno de cada tres. Es una validación externa que no es circular, porque la geografía no entró en el clustering. Pero no hay que leer en esto un "efecto vecindario": la región ODS sola adivina el camino mejor que los vecinos (77,5 % frente a 73,9 %). 42 países no siguen el camino de la mayoría de sus vecinos. Doce países sin vecino terrestre (AUS, BHR, CUB, CYP, JAM, LKA, MDG, MUS, NZL, PHL, PRI, TTO) reciben sus 2 vecinos más cercanos en la versión por contigüidad.

---

## 6. Divergencia entre países (P1) (sección 7; H10, H11, H11a pre-specified)

**Qué hicimos.** Calculamos para cada año, entre los 161 países, la DE, el CV y P10–P90 de la edad mediana, LEx, LE65, LE60 (suplemento) y Q5 (con log y razón P90/P10). El cambio 1950→2023 lleva IC por bloques de subregión y BCa iid. La proyección se analiza aparte. Las tendencias llevan EE de Newey-West (solo en el notebook).

| Indicador (161 países) | 1950 | 2023 | Cambio 1950→2023 [IC bloques] | iid BCa del cambio | 237 países (1950 → 2023) |
|---|---|---|---|---|---|
| DE de la edad mediana (años) | **4,67** [3,12; 5,73] | **9,74** [7,79; 10,91] | **+5,07** [3,05; 6,51] | [4,34; 5,88] | 5,01 → 9,77 |
| DE de LEx (años) | **12,24** [10,06; 13,85] | **7,42** [5,61; 8,29] | **−4,82** [−6,81; −2,97] | [−5,99; −3,79] | 11,69 → 7,01 |
| CV de LEx (%) | 25,6 [21,3; 28,8] | 10,2 [7,5; 11,6] | −15,4 [−18,2; −12,2] | [−18,2; −13,5] | — |
| DE de LE65 (años) | **1,47** [1,15; 1,76] | **2,85** [2,41; 3,15] | **+1,38** [1,00; 1,62] | [1,06; 1,64] | 1,46 → 2,88 |
| CV de LE65 (%) | 12,8 [10,1; 15,6] | 17,2 [14,2; 19,2] | +4,3 [1,1; 6,7] | [1,4; 6,1] | — |
| DE de LE60 (años, suplemento) | 1,80 [1,41; 2,18] | 3,19 [2,70; 3,52] | +1,38 [0,95; 1,67] | [0,99; 1,67] | 1,79 → 3,22 |
| Q5: razón P90/P10 | **6,2×** [3,3; 9,9] | **19,9×** [11,2; 28,4] | — | — | — |
| Q5: brecha P90 − P10 (‰) | 311 [251; 341] | 64 [36; 89] | — | — | — |
| Q5: DE del log | 0,70 [0,52; 0,84] | 1,14 [0,92; 1,28] | +0,44 [0,23; 0,59] | — | — |
| DE de la TFR | 1,68 | 1,30 (máximo **2,10 en 1981**) | −0,39 [−0,90; 0,08] | — | 1,64 → 1,18 |

| Detalle | Valor | Clave |
|---|---|---|
| R² región ODS (edad mediana) 1950 → 2023 | 0,62 → 0,75 (ingreso: 0,43 → 0,73) | `r2_region_medage_*` |
| R² región ODS (LEx) 1950 → 2023 | 0,57 → 0,67 (ingreso: 0,57 → 0,71) | `r2_region_lex_*` |
| Año del máximo de la DE de la edad mediana, en la proyección | **2040** (10,5 años); en estimaciones, el máximo es 2023 | `sd_medage_peak_year_proj` |
| DE de LE65 / LE60 | máximo de las estimaciones en 2021 (COVID-19); en la proyección sigue subiendo hasta 2100 (4,4 / 4,8) | `sd_medage_peak_year_proj.sens_note` |
| Razón P90/P10 de Q5: máximo de las estimaciones | **26,9× en 2006** (237: 21,6× en 1998); 2050 (proy.) 23,9× | `q5_ratio_p90p10_peak`, `_peak_year` |
| Tendencia de la DE, t de Newey-West | edad mediana 36,5 · LEx −9,0 · LE65 10,9 · TFR −1,7 | (notebook) |
| Sin RCA (posible artefacto, V1) | DE de LEx 12,24 → 7,34 | `resultados_q3_dispersion.parquet` |

Figuras: `q3_08_divergence_bands.png` y `q3_09_dispersion_sd.png`.

**Lectura.**
- **Los países convergen al nacer y divergen en la vejez y en la estructura por edad.** La DE de LEx bajó 4,8 años [2,97; 6,81] y la de la edad mediana subió 5,1 [3,05; 6,51]. La de LE65 casi se duplicó (1,47 → 2,85). Ninguno de estos intervalos cruza 0, y el resultado se mantiene con el CV y con los 237 países.
- **"6× → 20×" esconde un máximo.** La desigualdad relativa de la mortalidad infantil subió hasta 26,9× en 2006 y desde entonces baja. La proyección Medium la vuelve a abrir (23,9× en 2050). Lo absoluto y lo relativo se mueven en sentidos opuestos: la brecha P90–P10 se cerró de 311 a 64 por mil.
- En la proyección, la divergencia de la edad mediana tiene un máximo en **2040**. Después los países vuelven a acercarse porque los Recent movers también envejecen. La brecha en la vejez (LE65, LE60) no tiene máximo antes de 2100.
- La DE de la fecundidad subió hasta **1981** (2,10) y luego bajó (1,30). En términos relativos, en cambio, sigue divergiendo (CV 31 % → 52 %).
- Con IC por bloques, el intervalo es 1,4–2,2 veces más ancho que el iid. Es lo esperado cuando los vecinos se parecen.

---

## 7. Curvas atípicas (sección 8)

**Qué hicimos.** Aplicamos un boxplot funcional (MBD) a la LEx anual sin suavizar, calculamos la profundidad de forma sobre los cambios anuales y usamos `outliers.depth.trim` (profundidad modal, nb = 200).

| Tipo | Países |
|---|---|
| Atípicos de nivel (MBD) | CAF, KHM, RWA, SSD |
| Forma (8 menos profundos) | RUS, RWA, SSD, BDI, LTU, SWZ, XKX, MKD |
| Modal (recorte) | CAF, KHM, SSD, TLS |

Figura: `q3_14_atypical_lex.png`.

**Lectura.** Las trayectorias raras son crisis: Camboya 1975–79, el genocidio contra los tutsis en Ruanda (1994), Sudán del Sur, la epidemia de VIH/sida en África austral (Esuatini), y la transición postsoviética en Rusia y Lituania. No son países "ricos" o "pobres". RCA se marca como **posible artefacto** (caídas de un año en 2009, 2019 y 2022) y no se anota en el vídeo.

---

## 8. Velocidad en el camino: de 5 a 3 hijos (sección 9)

**Qué hicimos.** Suavizamos la TFR con B-splines (λ = 10) y tomamos el año continuo del último cruce de 5 y de 3. Medimos los años de 5 a 3 con Kaplan-Meier y censura en 2023, por camino. Además aplicamos la regla de resaltes de fig04: el más rápido, el mediano y el más lento entre los países ≥ 10 M que completaron el tramo.

| Camino | n | Llegan a 3 | Mediana KM (años) [IC 95 %] |
|---|---|---|---|
| Early movers | 6 | 6 | 14,9 [10,2; —] |
| Fast movers | 44 | 42 | **19,2** [17,7; 20,1] |
| Recent movers | 45 | 8 | **29,6** [22,7; —] |
| Migration-led | 7 | 7 | 18,0 [13,1; —] |

Regla ≥ 10 M (36 países): **más rápido China 5,1 años, mediano Colombia 18,6, más lento Egipto 32,7** → coincide con `dur53_chn` / `dur53_egy` de Q1 (`speed53_rule_10m.china_egypt_ok = true`). Los más rápidos de los 161 son CHN 5,1, IRN 5,3, SGP 7,5, MNG 7,5, THA 9,3 y LBY 9,3; los más lentos, LSO 29,6, DZA 30,4, PHL 32,0 y EGY 32,7. Claves: `speed53_median_by_group`, `speed53_rule_10m`. Figura: `q3_15_speed_53_km.png`.

**Lectura.** *Same road, different speed*: dentro de un mismo camino la duración va de 5 a 33 años. Los Recent movers son los más lentos y la mayoría aún no llega a 3 (37 de 45 censurados), así que su mediana es una cota. El intervalo superior queda abierto en tres grupos (pocos eventos).

---

## 9. Proyección Medium 2024–2050 por camino (sección 10; escenario, no pronóstico)

**Qué hicimos.** Sumamos personas por camino: saldo natural (Σ NatChange) frente a migración neta (Σ NetMigrations), como % de la población inicial. Calculamos también la edad mediana 2050, los años de edad mediana de 30 a 40, el año del máximo de población por país y la LE60 en 2050.

| Camino | 2000–2023 (estimación): natural / migración / total (%) | 2024–2050 (proy.): natural / migración / total (%) | Sin el más poblado (2024–50): natural / migración |
|---|---|---|---|
| Early movers | +2,2 / **+6,6** / +8,7 (75 % del crecimiento por migración) | **−7,0** / **+5,6** / −1,4 | sin USA: −9,6 / +4,3 |
| Fast movers | +29,0 / −1,6 / +27,4 | +8,9 / −0,7 / +8,1 | sin IND: +5,4 / −0,7 |
| Recent movers | +89,2 / −4,8 / +84,4 | **+70,1** / −2,7 / +67,3 | sin PAK: +72,3 / −1,8 |
| Migration-led | +65,0 / **+66,6** / +131,6 | +37,2 / +3,6 / +40,8 | sin SAU: +35,6 / +3,9 |

| Edad mediana (mediana entre países) | 2023 | 2050 (proy.) | Ponderada por población 2050 |
|---|---|---|---|
| Early movers | 41,9 | **47,8** | 45,8 |
| Fast movers | 29,3 | **38,2** | 41,4 |
| Recent movers | 18,3 | **24,6** | 24,1 |
| Migration-led | 31,2 | **32,3** | 32,4 |

China 2050 (proy.): edad mediana **52,1**. La media ponderada del ingreso alto FY2027 es 44,8, y el agregado ONU de ingreso alto 44,5 (`medage_chn_2050`; no existe IP de la ONU para la edad mediana).

**Envejecimiento: años de edad mediana 30 → 40 (estimaciones + proyección).**

| Grupo / cohorte | Mediana [IC bloques] | n | Nota | Clave |
|---|---|---|---|---|
| **Fast movers** (KM, censura en 2100) | **32** [27; 37] | 51 | 31 llegan a 30 solo después de 2023; 48 llegan a 40 en la proyección | `yrs_medage30_40_recent` |
| **Early movers** (KM) | **36,5** [29,0; 42,5] | 40 | quedan fuera los 10 con ≥ 30 ya en 1950; si se incluyen con su cota inferior, 42,0 | `yrs_medage30_40_early` |
| Fast movers que ya llegaron a 30 en ≤ 2023 | **23,5** [21; 26] | 20 | China 23, Tailandia 21, Brasil 24, Chile 26 | `yrs_medage30_40_fast_started` |
| Cohorte: llegaron a 30 en 1990–2023 (cualquier camino) | **24,0** [21; 30] (KM 25) | 35 | 28 de 35 llegan a 40 solo en la proyección | `yrs_medage30_40_cohort_1990_2023` |
| Cohorte: llegaron a 30 antes de 1990 | **40,5** [35; 46] | 24 | Europa y Norteamérica: 40,5 | `yrs_medage30_40_cohort_pre1990` |
| Corea / Japón / China | **17 / 21 / 23** | — | 1999→2016 · 1977→1998 · 2002→2025 (Italia 45, EE. UU. 49) | `yrs_medage30_40_kor/jpn/chn` |

| Máximo de población (1950–2100) | Ya pasó (≤ 2023) | En 2024–2099 (proy.) | Sin máximo antes de 2100 | Año mediano |
|---|---|---|---|---|
| Early movers | 30 | 16 | 4 | 2022 |
| Fast movers | 7 | 36 | 8 | 2058 |
| Recent movers | 0 | 10 | 43 | 2100 |
| Migration-led | 0 | 0 | 7 | 2100 |

China 2021, India 2061, Brasil 2042, Japón 2009, Alemania 2024, Rusia 1991; EE. UU. y Nigeria no tienen máximo antes de 2100 (`peak_year_by_group`). LE60 2050 (proy.): 27,0 / 22,8 / 17,7 / 26,2 (`le60_2050_by_group`). Figuras: `q3_10_projection_groups.png`, `q3_11_ageing_speed.png`, `q3_18_ageing_by_road.png` y `q3_12_peak_year.png`.

**Lectura.**
- En la proyección, cada camino cambia por una razón distinta. Los Early movers pierden población por saldo natural (−7 %) y la migración lo compensa casi entero (+5,6 %). Los Recent movers crecen 70 % por nacimientos. En Migration-led, la migración pasa de ser la mitad del crecimiento (2000–23) a ser poca (+3,6 %): es el supuesto de la ONU para el Golfo (tasas fijadas desde 2030), no un hallazgo.
- **El envejecimiento es rápido, pero no sin precedente.** Corea pasó de 30 a 40 en 17 años, Japón en 21 y China en 23. Por camino, la diferencia es menor de lo que sugería el prototipo: Fast movers 32 años frente a Early movers 36,5, con IC que se solapan. Esto pasa porque 31 de los 51 Fast movers empiezan a envejecer solo en la proyección, y la ONU les asigna un ritmo intermedio. El contraste fuerte aparece por **fecha de inicio**: 24 años para quienes llegaron a 30 después de 1990 y 40,5 para quienes llegaron antes. Ver §15 (frases) y el apartado de problemas.
- Hay 37 países que ya pasaron su máximo de población y 62 que no lo alcanzan antes de 2100 (proyección).

---

## 10. Cifras del mundo (sección 11)

| Cifra | Valor | Clave |
|---|---|---|
| Población mundial 2023 (estimación) | 8,09 mil M | `world_pop_2023_bn` (clave de Q1) |
| 2050 / 2100 (proy.) | 9,66 / 10,18 mil M | `world_pop_2050_bn`, `world_pop_2100_bn` |
| Máximo (proy.) | **2084, 10,29 mil M** | `world_peak_year`, `world_peak_bn` |
| Países y áreas que decrecen | 54 (2023; 30 ≥ 1 M) → 98 (2050, proy.) → 162 (2100, proy.) | `n_shrinking_2023/2050/2100` |
| China 2050 (proy.) | 1,26 mil M [IP 80 1,19–1,32; **IP 95 1,16–1,35**] | `pop_chn_2050`, `pop_chn_2050_pi95_*` |

La monotonía L95 ≤ L80 ≤ Median ≤ U80 ≤ U95 se comprobó en los 237 países para 2050 (OtherVariants). Figura: `q3_13_world.png`.

---

## 11. Complementos demográficos (sección 12)

| Cifra | Valor | Clave |
|---|---|---|
| Países y áreas con Q5 > 25 ‰ (2023) | **70** (62 ≥ 1 M) | `n_sdg32_above` |
| Al ritmo necesario para 2030 | **8** (ventanas 2010–23 y 2018–23: 8 y 8) = 11,4 % [Wilson 5,9; 21,0] | `n_sdg32_on_pace`, `share_sdg32_on_pace` |
| Ritmo mediano observado frente al necesario | 3,2 %/año frente a 8,2 %/año | `n_sdg32_on_pace.sens_note` |
| Seguirían > 25 en 2030 en la proyección | **58** (44 en África subsahariana) | `n_sdg32_above_2030` |
| Más defunciones que nacimientos | **8 (1990) → 53 (2023)** → 106 (2050, proy.) → 164 (2100, proy.); 2021: 58, 2022: 57 | `n_natneg_*` |
| Población que vive donde hay más muertes que nacimientos (2023) | **28 %** | `share_pop_natneg_2023` |
| África subsahariana | 51 países y áreas (44 ≥ 1 M): 40 Recent, 3 Fast, 1 Migration-led, 0 Early | `n_ssa` |

Figura: `q3_17_sdg32_pace.png`.

---

## 12. Tabla "What to watch, where, when" (sección 13; plan §7)

Las filas van por **estado de la palanca 2023** (Q1). La columna "Road" se calcula con el grupo mayoritario de los países ≥ 1 M de cada fila. Los verbos son solo *watch, plan, measure, prepare, monitor*.

| Countries where… (data) | Road (Q3) | What to watch / prepare | UN mandate | Agency | Horizon |
|---|---|---|---|---|---|
| child deaths still fall too slowly — 58 of 70 above 25 per 1,000 stay above it in 2030 even in the UN projection; 8 on pace | mostly Recent movers (50 of 62) | child survival and newborn care; voluntary family planning; births to adolescent girls | SDG 3.2, 3.7 · ICPD PoA | UNICEF · WHO · UNFPA | by 2030 |
| fertility is below replacement but the population still grows — 22 countries, 2.2 bn (India, Brazil, Mexico…) | mostly Fast movers (13 of 13) | plan 34–38 more years of growth (UN medium; India 38) in working and older ages; pensions and long-term care now; no pronatalist alarm | Decade of Healthy Ageing · MIPAA · SDG 1.3 | UN DESA · WHO · ILO | 2030–2060 |
| deaths already outnumber births — 53 countries, 28 % of humanity; 106 by 2050 (UN projection); e.g. China 2050: 1.26 bn, UN 95 % range 1.16–1.35 bn | mostly Early movers (33 of 35) | healthy longevity (old-age gap widening: SD of LE65 1.5 → 2.8 years); measure mortality with life expectancy and adult mortality, not the crude death rate | Decade of Healthy Ageing · SDG 3.4 | WHO · UN DESA | now–2040 |
| net arrivals are the only source of growth — 18 countries (Germany, Spain, Belgium…) | mostly Early movers (11 of 11) | migrant inclusion and better arrival/departure data; read UN migration projections as scenarios (monitor, do not plan for a number) | Global Compact for Migration obj. 1 & 16 · SDG 10.7 | IOM · UN DESA | now |
| emigration outweighs births — shrinking although births exceed deaths: Nepal, Azerbaijan, Uruguay (19 countries and areas) · and everywhere: census and civil registration | mostly Fast movers (4 of 6) | decent work, safe return and diaspora links; publish lever types with sensitivity windows | GCM obj. 2 & 19 · SDG 8.8, 17.18–17.19 | IOM · ILO · UNSD | now / 2030 census round |

Claves: `rec_rows` y `momentum_years_range` ("34–38"; es el P25–P75 de los años desde 2023 hasta el máximo de población proyectado, ponderado por población). Sin India daría 19–34. La mediana simple es 25 (22 países) o 28 (≥ 1 M). Desde el primer año con TFR < 2,1 hasta el máximo, la mediana es 37 años. Figura: `q3_16_watchlist_roads.png`.

**Lectura.** Cada fila apunta a una cifra calculada. El "30–40 años más de crecimiento" del plan se confirma como 34–38 para la población típica de estos países, pero India pesa el 65 %: el rango se declara ponderado. Corregimos la fila 5: decía *"more people leave than arrive"*, que también describe a países que crecen (como India). El tipo E es *"emigration outweighs births"*.

---

## 13. Estado de las hipótesis preinscritas de Q3

| ID | Regla (`hipotesis_preinscritas.md`) | Resultado obtenido | Estado |
|---|---|---|---|
| H9 (v1) | silueta ≤ 0,23 | 0,372 | **rechazada** (sustituida por H9a, como estaba previsto) |
| H9a | silueta < 0,5, todo Jaccard ≥ 0,75 y ARI con/sin CNMR < 0,7 | 0,372; Jaccard 0,78–0,95; ARI sin CNMR 0,54 | **confirmada** (Migration-led queda justo por encima del umbral: 0,78) |
| H10 | Δ DE de la edad mediana > 0, con IC > 0 | 4,67 → 9,74; Δ 5,07 [bloques 3,05; 6,51] | **confirmada** |
| H11 (v1) | LEx converge y LE60 diverge | Δ DE LEx −4,82 [−6,81; −2,97]; Δ DE LE60 +1,38 [0,95; 1,67] | **confirmada** (robustez) |
| H11a | DE y CV de LEx bajan; DE y CV de LE65 suben (IC sin cruzar 0) | DE LEx −4,82 [−6,81; −2,97]; DE LE65 +1,38 [1,00; 1,62]; CV LEx −15,4 [−18,2; −12,2]; CV LE65 +4,3 [1,1; 6,7] | **confirmada** (las cuatro; el CV de LE60 roza el 0: [0,0; 5,4]) |
| H14a | NatChange < 0 en ≤ 10 países en 1990 y ≥ 40 en 2023 | 8 → 53 | **confirmada** |
| H23 | < 25 % de los países con Q5 > 25 ‰ van al ritmo necesario | 8 / 70 = 11,4 % [Wilson 5,9; 21,0] | **confirmada** |
| H25 | enlaces del mismo camino ≥ 1,5 × el azar y por encima del P97,5 nulo | 0,667 frente a 0,303 (×2,20; P97,5 0,345; p = 0,001) | **confirmada, matizada**: la región sola acierta más (77,5 %) que el voto de los vecinos (73,9 %) |

Tabla: `data/processed/resultados_q3_hipotesis.parquet`.

---

## 14. Hallazgos sorprendentes (nuevos respecto a los memos)

1. **El ritmo de envejecimiento depende más de cuándo empieza que del camino.** Por camino: 32 frente a 36,5 años (los IC se solapan). Por fecha de inicio: 24 frente a 40,5. La ONU proyecta que quienes empiezan tarde envejecen a un ritmo intermedio: los Fast movers que ya llegaron a 30 tardan 23,5 años, y el grupo entero, 32.
2. **Agrupar por velocidades encuentra choques, no caminos.** Los tamaños son 139 / 9 / 7 / 6, con guerras, el Golfo y Hong Kong/Singapur en los grupos pequeños. Una silueta alta (0,46) no es garantía de una partición útil.
3. **La desigualdad relativa de la mortalidad infantil tuvo un máximo de 26,9× en 2006** y desde entonces baja, aunque la proyección la vuelve a subir (23,9× en 2050).
4. **La divergencia de la edad mediana tiene un máximo proyectado en 2040**, pero la brecha en la vejez (LE65, LE60) sigue abriéndose hasta 2100. La DE de LEx casi no cambia después de 2024 (7,4 → 7,2 en 2050).
5. **La fecundidad divergió hasta 1981, no hasta 1990.** Desde entonces su DE baja, pero su CV sigue subiendo (31 % → 52 %).
6. **Omán no es Migration-led**: es Fast mover. En cambio, Yibuti y Jordania sí lo son. "Mostly Gulf" = 5 de 7.
7. **Ningún Early mover crece por nacimientos sin inmigración** (0 de tipo B). 22 de 50 ya decrecen con más muertes que nacimientos. Entre los Fast movers, 30 de 51 son tipo B: la inercia es un rasgo del camino rápido.
8. **El voto de los vecinos no supera a la región.** La "geografía" de los caminos es regional (77,5 %); el vecino inmediato no añade información (73,9 %).
9. **China en 2050**: edad mediana proyectada de 52,1, unos 7 años por encima de la media del ingreso alto (44,8).

---

## 15. Limitaciones

1. Las estimaciones de 1950–2023 son modelizadas y de calidad desigual. La migración, muchas veces un residuo censal, es la peor medida, y el grupo Migration-led depende de ella (desaparece sin CNMR; revisión del Golfo de WPP2024).
2. Silueta 0,37: los grupos son tramos de un continuo. 42 % de los países tienen pertenencia difusa < 0,6 y 7 son países frontera.
3. Los nombres de los grupos salen de una regla escrita (v2), pero siguen siendo etiquetas. No describen desarrollo ni valor: *Groups describe demographic paths, not development or worth*.
4. El envejecimiento 30 → 40 y los años de máximo de población son en buena parte **proyección** (un escenario sin choques). Para los Early movers hay censura izquierda: 10 países ya tenían edad mediana ≥ 30 en 1950.
5. La muestra ≥ 1 M cambia los grupos frente a los 237 (ARI 0,81). Con los microestados las fronteras se mueven.
6. Los IC por bloques de subregión son anchos (p. ej., razón P90/P10 de Q5 2023: [11,2; 28,4]) porque solo hay 20 bloques. Describen la sensibilidad a qué regiones entran, no un error muestral.
7. Ingreso FY2027 aplicado a todo el periodo ("today's income groups"). V de Cramér solo descriptiva.
8. RCA es un posible artefacto (V1). Al quitarla, la DE de LEx 2023 pasa de 7,42 a 7,34: el resultado no cambia.
9. Ningún resultado es causal; los p-valores (permutación) solo van en el notebook.

---

## 16. Frases en inglés propuestas para el vídeo (con las cifras reales)

- *"Grouped by seventy-year paths, countries form three stretches of one road, plus a migration-led group, mostly Gulf states."* (`cluster_names`; `n_gulf_migration_led` = 5 de 7)
- *"Early movers — the United States, Russia and Japan — now grow mainly through migration, or shrink."* (2024–50: natural −7,0 %, migración +5,6 %; 22 de 50 son tipo D en 2023)
- Envejecimiento. **La frase del storyboard v2.1 con las claves por grupo daría** *"Fast movers … are projected to age in 32 years what took Early movers 37"*: el contraste es débil y los IC se solapan. Proponemos una de estas dos:
  - (a) *"Countries that started ageing after 1990 go from a median age of 30 to 40 in about 24 years; those that started earlier took about 41."* (`yrs_medage30_40_cohort_1990_2023` = 24, `_cohort_pre1990` = 40,5)
  - (b) *"Fast movers already ageing, like China, go from a median age of 30 to 40 in about 24 years — Early movers took about 37."* (`yrs_medage30_40_fast_started` = 23,5; `yrs_medage30_40_early` = 36,5)
- *"Recent movers — Pakistan, Nigeria and Ethiopia — still have high child mortality."* (Q5 mediana 50 ‰ frente a 16 y 4)
- *"Neighbours tend to share a road — two in three neighbouring pairs, against one in three by chance — yet four in ten countries sit between two: a spectrum, not boxes."* (`join_same_road` 0,67; `join_same_road_null` 0,30; `share_between_groups` 42 %)
- *"Countries grew closer in life expectancy — the spread fell from 12 to 7 years — but further apart in age, from 5 to 10 years, and in relative child survival: from 6 to 20 times."* (`sd_lex_*`, `sd_medage_*`, `q5_ratio_p90p10_*`)
- *"China went from five to three children in 5 years; Egypt took 33."* (regla confirmada: los más rápido y más lento de 36 países ≥ 10 M)
- *"For the UN: watch child survival where it falls too slowly — 58 of 70 countries stay above the 2030 target even in the UN projection — ageing where populations still grow below replacement — 22 countries, 2.2 billion people, 34 to 38 more years of growth — and migration data where growth depends on arrivals."*
- *"Deaths already outnumber births in 53 countries, home to 28 percent of humanity; in 1990 there were 8."*
- Pie del mundo: *"UN medium projection: world population peaks around 2084 at 10.3 billion — a scenario, not a forecast."*

---

## 17. Reproducibilidad

- `Rscript R/04_q3_caminos.R` → 179–190 s (última: 186,4 s) (R 4.6.1; fda 6.3.0; cluster 2.1.8.3; mclust 6.1.3; sf 1.1.3). RNG Mersenne-Twister / Inversion / Rejection; `set.seed(2026)` antes de cada k-means, bootstrap y permutación.
- Salidas: `figures/numbers_q3.json` (109 claves; `claves_faltantes(reg, "slide4")` = ninguna; `validar_registro()` sin problemas), `figures/miembros_grupos.csv`, `data/processed/resultados_q3_{paises, rasgos, bandas, dispersion, curvas, sensibilidad, vecinos, proyeccion, recomendaciones, hipotesis, envejecimiento, inercia_pico}.parquet` y `figures/review/q3/q3_01…q3_18.png`.
