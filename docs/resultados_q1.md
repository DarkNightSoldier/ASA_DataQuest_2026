# Resultados Q1 — *Which lever moves each country's population: births, deaths or migration?* (P7 + P4)

> Agente `notebook-Q1` · 2026-10-23 · Script: `R/02_q1_palancas.R` (se ejecuta de principio a fin con `Rscript R/02_q1_palancas.R` desde la raíz del repo; **8,9–11,6 min** según la carga de la máquina (corrida final: 8:54) con B = 2 000, sin errores ni avisos; tres corridas oficiales seguidas dan el mismo `numbers_q1.json` byte a byte, ver §14).
> Cifras: `figures/numbers_q1.json` (esquema v2 de 36 campos, `verified: false` hasta QA-stats). Tablas: `data/processed/resultados_q1*.parquet` (columnas documentadas al inicio del script) y `figures/miembros_tipo_palanca.csv`. Figuras de revisión (no finales): `figures/review/q1/q1_01…q1_18.png` (1600×900), revisadas una a una con la herramienta de lectura de imágenes.
> Universo: **237 países y áreas** para conteos, mapa y descomposición; **161 países ≥ 1 M** (población 2023) para modelos, supervivencia, registro, panel y Moran. Estimaciones 1950–2023; la proyección Medium (2024–2100) solo aparece rotulada "UN medium projection" y nunca entra en un estadístico junto con las estimaciones. Ingreso = **World Bank FY2027 aplicado a todos los años** ("today's income groups"): todo gradiente por ingreso es descriptivo.
> "IC" = intervalo 95 % por **bootstrap por bloques de las 20 subregiones ONU** (B = 2 000, semilla 2026), el único que puede salir en pantalla junto con Wilson, KM y los IP de la ONU. "iid" = bootstrap de países (BCa o percentil), solo para comparar. Los intervalos describen *sensibilidad a qué países (o regiones) entran*, no error muestral. Nada de lo que sigue es causal.

---

## 0. Resumen en 8 líneas

1. **Gancho (H12a ✔):** en 2023, **130** de 237 países y áreas están bajo reemplazo y **84** aún crecen: **66** porque nacen más de los que mueren y **18** solo porque llegan más de los que se van (rango 15–25 según el año).
2. **Ingreso (H1 ✔):** en los países hoy de ingreso alto, la migración neta aporta el **70,7 %** del crecimiento 2000–2023 [IC bloques 55,5; 133,3] [BCa 56,0; 111,9]; con los agregados de ingreso de la ONU (otra lista), 64,0 %. En los otros tres grupos la migración resta (−3,7 % a −8,6 %).
3. **Palancas 2023:** A 71 · B 94 · C 18 · D 35 · E 19. Ejemplos por regla: C = Germany, Spain, Belgium · D = China, Russian Federation, Japan · E = Nepal, Azerbaijan, Uruguay. **Inercia (H19 ✔):** 22 países bajo reemplazo crecen por nacimientos sin inmigración neta (**2,20 mil M** de personas; 18 con emigración neta estricta).
4. **Orden (H3a ✔):** la mortalidad infantil empezó su caída duradera antes que la fecundidad en **106 de 109** países de alta fecundidad (**97,2 %**, Wilson [92,2; 99,1]); la mediana del rezago no se puede identificar, pero es **al menos 22 años** [IC 16; 28]. La fecundidad empezó a caer hacia **1970 / 1984 / 2000** en los países hoy de ingreso medio-alto / medio-bajo / bajo (H3b ✔, log-rank χ² = 73,4).
5. **Mismo camino, distinto reloj (H17 ✔):** alinear a cada país en el año en que su TFR bajó de 4 elimina el **80 %** [IC 69; 85] de la varianza entre países; de 5 a 3 hijos China tardó **5,1 años** y Egipto **32,7**. Empezar tarde no fue ir más rápido (H18 ✔: 24,1 vs 18,8 años).
6. **Dentro vs entre (H15 ✔ con matiz):** dentro del mismo país, la mitad de Q5 va con **−0,41** hijos en 20 años, frente a **−1,05** entre países (2,5×); supera al placebo, pero **el IC por bloques de subregión incluye el 0** [−0,77; 0,05]. Claro en África subsahariana (−1,20) e ingreso bajo (−0,95); **invertido** en Europa y Norteamérica (+0,39).
7. **La migración va por su cuenta:** memoria corta (0,32–0,69 entre décadas frente a ≥ 0,95 de TFR y LEx; H4a ✔), casi sin vecindario (Moran 0,11; −0,03 sin el Golfo; H24 ✔), sin "compensación" dentro del país (+0,01 [−0,20; 0,17]; H16 ✔) y con una paradoja tipo Simpson con la mortalidad infantil (−0,45 en el mundo, ≈ 0 dentro de cada grupo de ingreso; H21 ✔).
8. **Incertidumbre visible una vez:** EAU 2050 = **15,4 M**, IP 95 % de la ONU **8,9–33,3 M**; en **77 de 161** países el IP 95 % de 2050 incluye crecer y decrecer (H22 ✔).

---

## 1. Universo y gancho de portada (sección 1 del script)

**Qué hicimos.** Contamos los países bajo reemplazo en 2023 y, entre ellos, cuántos crecen y por qué término del balance. Repetimos con TFR < 2,0, < 2,2 y NRR < 1.

| Definición de "bajo reemplazo" | Países | Crecen | Por saldo natural | Solo por migración |
|---|---|---|---|---|
| **TFR < 2,1 (principal)** | **130** | **84 (65 %)** | **66** | **18** |
| TFR < 2,0 | 124 | 82 (66 %) | 64 | 18 |
| TFR < 2,2 | 138 | 91 (66 %) | 73 | 18 |
| NRR < 1 | 130 | 86 (66 %) | 68 | 18 |

| Cifra de universo | Valor | Clave |
|---|---|---|
| Población mundial 2023 (agregado ONU = suma de los 237; dif. 1,2 × 10⁻⁸ %) | 8,09 mil M ("eight billion") | `world_pop_2023_bn` |
| Población mundial 1950 | 2,5 mil M | `world_pop_1950_bn` |
| Estados soberanos + territorios | 195 + 42 = 237 (territorios ≥ 1 M: HKG, TWN, XKX, PRI) | `n_states`, `n_sovereign`, `n_territories` |
| Países ≥ 1 M | 161 | `n_countries_1m`, `n_ge1m` |

**Lectura de resultados.** El gancho del plan se reproduce exacto: 130 → 84 = 66 + 18. Los "79" de la v1 son los países bajo reemplazo con más nacimientos que defunciones (79), no los que crecen (84): H12 cae como cifra, H12a se confirma con las cuatro definiciones (65–66 % crecen). Los 18 que crecen solo por migración no cambian con el umbral de fecundidad.

---

## 2. Identidad de balance y descomposición por ingreso y región (sección 2)

**Qué hicimos.** Comprobamos `PopChange = NatChange + NetMigrations` y repartimos el crecimiento 2000–2023 de cada grupo de ingreso FY2027 (sumas de personas de sus países) entre saldo natural y migración. IC: bloques de subregión (pantalla), BCa iid y jackknife por país.

| Grupo FY2027 (n) | Migración / crecimiento 2000–23 | IC bloques | BCa iid | Jackknife (país que más mueve) | Agregado ONU (mayo-2024) |
|---|---|---|---|---|---|
| Bajo (25) | −3,7 % | [−9,3; −1,6] | [−7,7; −1,1] | −4,7 (sin ETH) a −2,9 (sin SDN) | — |
| Medio-bajo (47) | −8,6 % | [−12,1; −2,8] | [−21,2; −3,7] | −12,8 (sin IND) a −6,5 (sin BGD) | — |
| Medio-alto (59) | −4,6 % | [−14,9; 0,5] | [−11,3; 1,1] | −5,6 (sin MYS) a −3,4 (sin UKR) | — |
| **Alto (85)** | **70,7 %** | **[55,5; 133,3]** | **[56,0; 111,9]** | **64,5 (sin RUS) a 81,6 (sin USA)** | **64,0 %** |

Sensibilidades de ingreso alto: 2010–2023 77,5 % [57,5; 162,5]; ≥ 1 M 71,1 %; sin EE. UU. 81,6 %; sin Golfo 75,0 %; sin Rusia 64,5 %; agregados ONU 2010–23 72,8 %. Rango en pantalla (`share_mig_high_sens_range`, 2 listas × 2 periodos): **64–78 %**. China aporta el 29,6 % del saldo natural de medio-alto (46,3 % de su población); India el 40,2 % del de medio-bajo (50,1 %). Por región SDG: Europa y Norteamérica 84,4 %, Australia/NZ 55,3 %, Norte de África y Asia occidental 5,8 %, resto negativo (LAC −13,9 %). Identidad: residuo máximo 4,9 mil personas (Ucrania 1989); suma de grupos + "Not classified" = World (dif. 0).

Figura: `q1_01_descomposicion_ingreso.png`. Claves: `share_mig_*_2000_2023`, `share_mig_high_2010_2023`, `share_mig_high_un_agg`, `share_mig_high_sens_range`, `china_share_natchange_upmid`, `india_share_natchange_lowmid`, `share_mig_region_2000_2023`, `share_countries_mig_dominant_by_region`.

**Lectura de resultados.**
- H1 se confirma con su regla (estimación 70,7 > 50 y límite inferior BCa 56,0 > 50); también con bloques (55,5). El IC por bloques es muy asimétrico hacia arriba (133 %) porque al remuestrear subregiones hay réplicas con poco crecimiento total en el denominador.
- Reportamos los dos números que pide el encargo: **70,7 % (sumas de países FY2027)** y **64,0 % (agregados ONU, clasificación de mayo de 2024)**. No son contradictorios: son dos listas de países distintas (alto 1 393 M vs 1 261 M); el agregado ONU nunca se usa para validar.
- Fuera del ingreso alto, el crecimiento viene casi todo del saldo natural; la migración neta resta entre 4 y 9 de cada 100.
- Es contabilidad de un total de grupo: **no** dice que la migración compense, país a país, la caída de nacimientos (ver §6.5, H16).

---

## 3. Tipología de palancas, ventanas, ejemplos e inercia (sección 3)

**Qué hicimos.** Clasificamos cada país con la regla A–E (año base 2023, sumas de personas) y repetimos con 2017–19, 2021, 2022 y 2021–23. Elegimos ejemplos por regla (3 más poblados ≥ 1 M de cada tipo) y contamos la inercia (tipo B con TFR < 2,1).

| Tipo (2023) | 237 | ≥ 1 M | 2017–19 | 2021 | 2022 | 2021–23 | Ejemplos por regla (≥ 1 M) |
|---|---|---|---|---|---|---|---|
| A · crece por nacimientos + llegadas | 71 | 48 | 88 | 72 | 73 | 73 | United States of America, Egypt, Iran |
| B · crece por nacimientos, sin llegadas netas | 94 | 72 | 87 | 90 | 91 | 92 | India, Indonesia, Pakistan |
| **C · crece solo por llegadas netas** | **18** | **11** | 14 | 15 | 25 | 24 | **Germany, Spain, Belgium** (`cover_flags` = DE, ES, BE) |
| D · decrece: defunciones > nacimientos | 35 | 24 | 22 | 43 | 32 | 31 | China, Russian Federation, Japan |
| E · decrece: se van más de los que llegan | 19 | 6 | 26 | 17 | 16 | 17 | Nepal, Azerbaijan, Uruguay |

| Inercia y detalle | Valor | Clave |
|---|---|---|
| Bajo reemplazo y crecen por nacimientos sin inmigración neta (B & TFR < 2,1) | **22 países, 2,20 mil M** | `n_momentum_countries`, `pop_momentum_bn` |
| … con emigración neta estricta (NetMigrations < 0) | 18 (2,20 mil M); los otros 4 (BRN, LCA, ATG, KNA) tienen migración neta 0 | `n_momentum_emig` |
| … con NRR < 1 en vez de TFR < 2,1 | 24 (2,54 mil M) | `sens_note` |
| Ejemplos de inercia (3 más poblados ≥ 1 M) | India, Brazil, Mexico | `examples_momentum` |
| "Reloj" de la inercia (13 países ≥ 1 M): años desde bajar de 2,1 hasta el pico proyectado | RIC **32–40** (mediana 36); desde 2023: RIC 24–34 (mediana 28) | `momentum_clock_years_range`, `momentum_years_to_peak_range` |
| China (observado): bajó de 2,1 en 1991, pico de población en 2021 | 30 años | `momentum_clock_chn_years` |
| Bajo reemplazo por tipo | A 44 · B 22 · C 18 · D 33 · E 13 | `n_below_repl_by_type` |
| Concordancia de tipo 2023 vs 2021–23 | 88,6 % (93,2 % con A y B juntos) | `type_concordance_2023_2021_23` |
| Tipo E con TFR ≥ 2,1 | 6, todas islas pequeñas (ASM, MAF, MHL, MNP, TON, TUV; la mayor, 105 mil hab.) | `n_type_E_tfr_ge21` |

Figuras: `q1_02_mapa_palancas_2023.png`, `q1_03_ventanas_sensibilidad.png`, `q1_04_gancho_inercia.png`. Lista completa por país: `figures/miembros_tipo_palanca.csv`.

**Lectura de resultados.**
- Los conteos A–E de 2023 reproducen los del plan (71/94/18/35/19; ≥ 1 M 48/72/11/24/6). En pantalla, el tipo C va como `18 (15–25 depending on the year)`; antes del COVID-19 (2017–19) eran 14. La ventana 2021–23 no suaviza: lleva dentro el exceso de muertes por COVID-19 (D sube a 43 en 2021) y el desplazamiento desde Ucrania (C sube a 25 en 2022).
- La inercia reúne a 22 países con 2 200 millones de personas: crecen por nacimientos aunque cada mujer tenga menos de 2,1 hijos, porque todavía hay muchas personas en edad de tener hijos. La voz debe decir "growing from births" (no "despite emigration"): 4 de los 22 tienen migración neta exactamente 0.
- "Nadie se va de los países de ingreso bajo" no se sostiene: los 6 casos de tipo E con fecundidad alta son microislas; entre los ≥ 1 M, 31 países tuvieron algún año de tipo E con TFR ≥ 3 en 1950–2023 (Irlanda 1952–60, TFR 3,5; Portugal 1963–70, TFR 3,1).
- **Ojo con la clave `momentum_years_range`**: la registra Q3 (años desde 2023 hasta el pico, ponderado por población: 34–38). Q1 la renombró a `momentum_clock_years_range` (32–40, desde el cruce de 2,1) para no chocar al combinar.

---

## 4. ¿Se parecen los vecinos? Moran's I y LISA (sección 4)

**Qué hicimos.** Moran global con 5 vecinos más cercanos (haversine entre los puntos de Natural Earth), permutación (999) y jackknife; sensibilidad a 4 matrices W, a los 229 países con punto en el mapa y a los residuos tras región + ingreso. LISA de la CNMR media 2010–2023 con corrección de Benjamini–Hochberg.

| Indicador (2023, 161) | Moran I | Jackknife 95 % | Rango con 5 matrices W | Por rangos | 229 países |
|---|---|---|---|---|---|
| TFR | **0,74** (0,735) | [0,64; 0,83] | 0,70–0,74 | 0,70 | 0,72 |
| Esperanza de vida | 0,69 | [0,59; 0,79] | 0,65–0,70 | 0,68 | 0,68 |
| Edad mediana | 0,77 | [0,68; 0,86] | 0,75–0,77 | 0,78 | 0,75 |
| Crecimiento | 0,59 | [0,45; 0,74] | 0,58–0,62 | 0,69 | 0,47 |
| **Migración neta (CNMR)** | **0,11** | [−0,21; 0,44] | 0,10–0,13 | 0,26 | 0,14 |
| CNMR sin los 6 del Golfo (155) | **−0,03** | [−0,33; 0,27] | — | — | — |

Residuos tras región + ingreso: TFR 0,15 (p = 0,002), CNMR −0,10. Crecimiento por rangos: 0,34 (1950) → 0,69 (2023). **LISA 2010–23:** 25 países con p < 0,05 sin corregir; tras FDR quedan **9**: un conglomerado alto-alto de **7** (ARE, BHR, IRN, KWT, OMN, QAT, SAU) y 2 bajo-bajo (ALB, SRB). Con el año 2023 solo, ninguno sobrevive.

Figuras: `q1_05_moran_vecinos.png`, `q1_05b_lisa_migracion.png`. Claves: `moran_*_2023`, `moran_cnmr_2023_nogulf`, `moran_growth_rank_*`, `lisa_cnmr_hh_fdr`.

**Lectura de resultados.** Los vecinos se parecen mucho en fecundidad, supervivencia y edad (0,69–0,77) y casi nada en migración (0,11); sin el Golfo, nada (−0,03). H24 se confirma. El único "vecindario migratorio" robusto es el Golfo (con Irán, que queda dentro por sus vecinos). Es una descripción de parecido, no difusión ni contagio. Nota: el plan decía 0,12 para la CNMR; sale 0,114 → "0.11".

---

## 5. Supervivencia: ¿qué empieza a caer primero? (sección 5)

**Qué hicimos.** Fechamos el inicio de la caída duradera de Q5 y TFR (regla de Princeton: primer año ≤ 90 % del máximo previo que no se vuelve a superar) en los 109 países ≥ 1 M con TFR₁₉₅₀ ≥ 5 y grupo de ingreso (Taiwán fuera por no tener grupo). Orden con Wilson; rezago como intervalo (Turnbull); año de inicio de la caída de la fecundidad por ingreso con Kaplan–Meier (censura en 2023), log-rank y Cox.

| Resultado | Valor | Intervalo / sensibilidad | Clave |
|---|---|---|---|
| Mortalidad infantil primero (regla preinscrita H3a) | **106 de 109 = 97,2 %** | Wilson [92,2; 99,1]; 9 reglas: 94,5–97,4 % | `n_mort_first_onset`, `n_onset`, `share_mort_first` |
| Solo con ambos inicios observados | 104 de 107 (97,2 %) | Wilson [92,1; 99,0]; con Taiwán 105 de 108 | `share_mort_first_both_observed` |
| Fecundidad primero | LBN, RWA, XKX | — | log |
| TFR aún sin iniciar su caída en 2023 | CAF, COD | cuentan como "mortalidad primero" | log |
| Q5 ya caía en 1950 (censura izquierda) | 92 de 109 | — | `n_q5_falling_1950` |
| Mediana del rezago (Turnbull) | **no identificable** (64 % de la masa más allá del último tiempo) | 13 exactos, 3 izq., 84 der., 9 sin información | `lag_onset_turnbull_mass_beyond` |
| Cota inferior de la mediana del rezago | **22 años** | IC bloques [16; 28]; iid [20; 25]; 9 reglas 19–24 | `lag_onset_lower_bound` |
| Caída de Q5 (desde su máximo) al iniciar la caída de la TFR | **mediana 50 %** | IC [43,8; 60,7]; RIC 41–64 | `q5_drop_at_tfr_onset` |

| Inicio de la caída de la TFR (KM) | n (eventos) | Año mediano | IC 95 % (Brookmeyer–Crowley) | Clave |
|---|---|---|---|---|
| Bajo | 24 (22) | **2000** | [1995; 2007] | `yr_fert_onset_low` |
| Medio-bajo | 40 (40) | **1984** | [1982; 1987] | `yr_fert_onset_lowmid` |
| Medio-alto | 33 (33) | **1970** | [1968; 1975] | `yr_fert_onset_upmid` |
| Alto | 12 (12) | 1970 | [1965; —] | `yr_fert_onset_high` |

Log-rank (4 grupos) χ² = **73,4** (3 gl; Holm p ≈ 6 × 10⁻¹⁵, solo notebook); Cox con el ingreso como escalón: HR = 2,37 [1,93; 2,92]. Por región SDG: Europa y Norteamérica 1956 (n = 4), LAC 1970, Asia central y meridional 1974, Asia oriental y sudoriental 1974, Norte de África y Asia occidental 1980, África subsahariana 1995. **Rejilla de umbrales fijos (H3 de v1):** medianas del rezago de −11,5 a +39,5 años y "mortalidad primero" del 16 % al 100 % según el par; con 100/4 y KM, 14 años [11; 18].

Figuras: `q1_06_km_inicio_ingreso.png`, `q1_07_event_time_inicio.png`, `q1_08_rejilla_umbrales.png`.

**Lectura de resultados.**
- La mortalidad infantil empezó a caer primero en casi todos los países de alta fecundidad (97 %), con cualquiera de las 9 reglas (94–97 %). H3a se confirma (límite inferior de Wilson 92,2 > 50).
- No se puede decir "el rezago mediano es X años": Q5 ya caía en 1950 en 92 de 109 países. Lo honesto es "**at least 22 years**" como cota de la **mediana** (no de cada país). El IC por bloques [16; 28] es más ancho que el iid del plan [20; 25].
- Cuando la fecundidad empieza a caer, la mortalidad infantil ya ha bajado a la mitad de su máximo (mediana 50 %, en el gráfico de tiempo de evento Q5 está al 47 % y TFR al 89 % de su máximo en el año 0).
- El calendario por ingreso de hoy es monótono (2000 > 1984 > 1970): H3b se confirma. El ingreso de hoy es en parte resultado de la transición: es un calendario, no una causa.
- H3 (11 años con umbrales 100/4) se rechaza: la respuesta cambia de signo dentro de la rejilla. Va a "What we did not find".

---

## 6. Registro por hitos: mismo camino, distinta velocidad (sección 6)

**Qué hicimos.** Suavizamos la TFR de cada país (B-splines cúbicos, λ = 10), fechamos el **último** cruce de 4 y alineamos a todos en ese reloj propio. Medimos cuánta varianza entre países desaparece en ±20 años (calendario centrado en la mediana vs reloj propio), descomposición amplitud/fase de Kneip–Ramsay y la velocidad de 5 a 3 hijos con KM.

| Resultado | Valor | IC / detalle | Clave |
|---|---|---|---|
| Cruce de 4 observado 1950–2023 | 90 países | ya < 4 en 1950: 45; aún ≥ 4 en 2023: **26** (23 en África subsahariana) | `n_cruce_tfr4_obs`, `n_cens_izq`, `n_cens_der`, `n_cens_der_ssa` |
| Reducción de varianza (hito 4; 57 con ventana completa) | **−80 %** (0,920 → 0,186) | IC bloques [69,4; 85,1]; sin τ = 0: −79 % | `pct_var_fase` |
| Hito 5 (60 países) / hito 3 (52 países) | −77 % / −71 % | [68; 83] / [65; 78] | `pct_var_fase_c5`, `pct_var_fase_c3` |
| R² de fase (Kneip–Ramsay) | 0,56 | C = 1,01 | `r2_fase_kr` |
| 5 → 3 hijos: China / Egipto | **5,1 / 32,7 años** | el más rápido y el más lento de los 36 países ≥ 10 M que llegaron a 3; mediano: Colombia | `dur53_chn`, `dur53_egy`, `dur53_fastest_ge10m`, `dur53_slowest_ge10m`, `fig04_highlight_iso3` |
| KM 5 → 3: cruzaron 5 hasta 1975 (20) / 1975–90 (32) / después de 1990 (50, solo 13 llegaron a 3) | 19,5 / 18,3 / **24,1 años** | [17,7; 21,0] / [16,3; 23,6] / [19,1; —]; hasta 1990: 18,8 [17,7; 19,9] | `km_dur53_*` |

Figuras: `q1_09_registro_tfr4.png`, `q1_10_velocidad_5a3.png`.

**Lectura de resultados.** Al poner a cada país en su propio reloj, las curvas casi se superponen: el 80 % de las diferencias entre países era de calendario ("cuándo"), no de forma ("cómo"). H17 se confirma (≥ 50 % con el hito 4 y ≥ 30 % con 5 y 3). Quienes cruzaron 5 después de 1990 no van más rápido (24,1 años de mediana frente a 18,8; H18 ✔). La regla de resaltes del storyboard se mantiene: China es el más rápido (5,1) y Egipto el más lento (32,7). Advertencia de supervivencia: los 26 países que no han cruzado 4 (casi todos en África subsahariana) no están en la alineación.

---

## 7. Panel en cambios quinquenales: dentro del país vs entre países (sección 7)

**Qué hicimos.** Medias quinquenales 1950–54 … 2020–23; ΔTFR sobre Δlog Q5 con rezagos 0–20 años, efectos fijos de país (tendencia propia) y de periodo (calendario común), EE agrupados por país (N = 1 610, 161 países, cambios 1975–2023). La suma de rezagos × ln 0,5 = hijos asociados a la mitad de Q5. Comparamos con la pendiente entre países (medias 1950–2023), placebos y heterogeneidad.

| Estimación (hijos por mujer por mitad de Q5) | Valor | IC bloques | EE por país (cluster) | iid | Clave |
|---|---|---|---|---|---|
| **Dentro del mismo país** | **−0,41** | **[−0,77; 0,05]** | [−0,71; −0,12] | [−0,70; −0,14] | `panel_within_halfq5` |
| **Entre países** | **−1,05** | [−1,17; −0,92] | — | [−1,12; −0,99] | `panel_between_halfq5` |
| Razón entre / dentro | 2,5 | inestable ([−9; 18]; iid [1,5; 7,2]) | — | — | `panel_ratio_between_within` |
| Dentro / entre ("less than half") | 0,39 | **[−0,05; 0,73]** | — | [0,13; 0,66] | `panel_within_over_between` |
| Ingreso bajo (25) | **−0,95** | [−2,14; −0,07] | [−1,46; −0,43] | — | `panel_low_income_halfq5` |
| Medio-bajo (41) / medio-alto (44) / alto (50) | +0,07 / +0,11 / −0,28 | [−0,56; 0,65] / [−0,53; 0,63] / [−1,26; 0,41] | — | — | `panel_lowmid/upmid/high_halfq5` |
| África subsahariana (44) | **−1,20** | (bootstrap de países [−1,61; −0,68]) | [−1,65; −0,74] | — | `panel_ssa_halfq5` |
| **Europa y Norteamérica (38)** | **+0,39** | (bootstrap de países [0,23; 0,56]) | [0,23; 0,55] | — | `panel_eurna_halfq5` |
| Otras regiones: N. África y Asia occ. / Asia c. y merid. / Asia or. y sudor. / LAC | −0,51 / +0,02 / +0,03 / −0,31 | — | [−1,00; −0,03] / [−2,18; 2,21] / [−0,93; 0,99] / [−0,79; 0,16] | — | parquet |

| Validación | Resultado | Clave |
|---|---|---|
| Placebo (Q5 de otro país, 300 permutaciones) | 95 % en [−0,25; 0,26] (unidades de hijos) vs real −0,41; p = 0,003 | `panel_placebo_lo/hi` |
| Adelanto (Δlog Q5 del quinquenio siguiente) | 0,28 (EE 0,16; p = 0,08) | `panel_lead` |
| Sentido directo vs inverso (DE estandarizadas, rezagos 5–20) | 0,28 vs 0,22 → co-movimiento en ambos sentidos | `panel_forward_sd`, `panel_reverse_sd` |
| Sensibilidades | dejar un país fuera −0,47 a −0,37; 237 países −0,37; sin 2020–23 −0,45; diferencia larga −0,46; con ΔCNMR −0,42; **ponderado por población +0,08** | `sens_note` |
| Heterogeneidad | Cochran Q ingreso I² = 0,69; región I² = 0,91; Wald χ²(3) = 21,1 | `panel_i2_income`, `panel_i2_region` |
| Comparación honesta (157 países, mismo denominador, países fuera de muestra) | R² dentro: M0 calendario 8,5 % → 7,2 % fuera; M2 rezagos 12,3 % → 8,4 %; M3 × ingreso 20,8 % → **11,0 %**; M4 × región 21,8 % → **6,6 %** | `r2_in_m*`, `r2_oos_m*` |
| Migración en la varianza del crecimiento | entre países 0,33 [−0,02; 0,58] (sin Golfo 0,07); dentro 0,85 [0,74; 0,92] (sin Golfo 0,79) | `mig_share_*` |
| **"Compensación" migratoria (ingreso alto sin Golfo, 44 países; H16)** | CNMR sobre saldo natural del quinquenio anterior, FE país + periodo: **+0,01** [IC bloques −0,20; 0,17]; con solo FE de país (calendario dentro): −0,16 [−0,25; −0,06] | `mig_hi_within_slope`, `mig_hi_countryfe_slope` |

Figuras: `q1_11_panel_forest.png`, `q1_12_comparacion_modelos.png`, `q1_13_placebo_compensacion.png`.

**Lectura de resultados.**
- Comparando cada país consigo mismo, la asociación fecundidad–mortalidad infantil es 2,5 veces más pequeña que la que se ve entre países (−0,41 vs −1,05) y queda fuera de la banda del placebo. H15 se confirma **con la regla preinscrita** (IC con EE por país excluye 0; < 2/3 de la pendiente entre países; fuera del placebo). **Matiz importante:** con el IC por bloques de subregión, el que exige el plan para pantalla, el intervalo dentro del país llega a +0,05. En el vídeo: la cifra sin intervalo o con el IC por bloques rotulado; nunca decir que "excluye el cero".
- "Less than half" (voz) se apoya en la estimación puntual: dentro / entre = 0,39; con bloques de subregión el intervalo de esa fracción es [−0,05; 0,73], así que la frase es frágil a qué regiones entran (iid [0,13; 0,66]). Alternativa más segura: *"smaller than what comparing countries suggests"*.
- Es co-movimiento, no efecto: el adelanto casi iguala a los rezagos (0,28, p = 0,08) y el sentido inverso es casi igual de fuerte (0,22 vs 0,28 DE).
- La relación es clara en África subsahariana (−1,20) y en ingreso bajo (−0,95). En **Europa y Norteamérica va al revés (+0,39)**: allí, en 1975–2023, la mortalidad infantil siguió bajando mientras la fecundidad se recuperaba en algunos periodos. La frase del storyboard *"not detected in Europe & N. America"* es inexacta: debe decir *"reversed in Europe & N. America"*.
- Ponderar por población cambia el signo (+0,08): China e India dominan. "Cada país cuenta una vez" es una decisión que hay que declarar.
- El modelo más flexible (pendientes por región) es el que mejor ajusta dentro de la muestra (21,8 %) y el peor para países nuevos (6,6 %): receta de la "comparación honesta".
- H16: dentro del mismo país de ingreso alto, un saldo natural menor **no** va con más migración (+0,01, IC que contiene 0). La "compensación" (−0,16) aparece solo si se deja dentro el calendario común: es contabilidad del grupo, no relación país a país.

---

## 8. Migración: memoria corta y paradoja tipo Simpson (sección 8)

**Qué hicimos.** Correlación entre medias de décadas consecutivas (1950s … 2010s = 2010–23) de CNMR, TFR y LEx; ρ de la CNMR 1950 vs 2023 y β de "convergencia" con placebo (H4); Spearman Q5–CNMR y TFR–CNMR (promedios 2021–23) en el mundo y dentro de cada grupo de ingreso.

| Década → década | 1950s→60s | 60s→70s | 70s→80s | 80s→90s | 90s→2000s | 2000s→2010s |
|---|---|---|---|---|---|---|
| CNMR | 0,68 | 0,66 | 0,60 | **0,32** | 0,47 | **0,69** [IC 0,52; 0,73] |
| TFR | 0,97 | 0,95 | 0,96 | 0,96 | 0,98 | 0,97 |
| LEx | 0,97 | 0,96 | 0,96 | 0,96 | 0,95 | 0,98 |

| Resultado | Valor | Clave |
|---|---|---|
| Mantienen el signo de la CNMR 2000s → 2010s | 76,4 % (Wilson [69,3; 82,3]) | `share_cnmr_sign_kept` |
| CNMR 1950 vs 2023 (años sueltos) | 0,14 [−0,07; 0,21] (TFR 0,52) | `r_cnmr_1950_2023` |
| β CNMR 1950–54 → 2019–23 (H4) | −0,90; placebo −1,00 [−1,12; −0,88] | `sens_note` |
| ρ(Q5, CNMR) mundo | **−0,45** [−0,63; −0,22] | `rho_q5_cnmr_world` |
| … dentro de bajo / medio-bajo / medio-alto / alto | +0,08 / +0,16 / +0,17 / −0,07 (todos los IC cruzan 0); parcial dado el ingreso +0,08 | `rho_q5_cnmr_within_*` |
| ρ(TFR, CNMR) mundo / medio-bajo | −0,29 [−0,48; −0,12] / **+0,50** [0,14; 0,67] | parquet |
| H5 (TFR–CNMR en ingreso alto, 2023) | ≥ 1 M (50): +0,10 [BCa −0,18; 0,43]; con los 85: Pearson −0,36 | log |

Figuras: `q1_14_memoria_migracion.png`, `q1_15_simpson_ingreso.png`.

**Lectura de resultados.** La migración de un país se parece a la de la década anterior bastante menos que su fecundidad o su esperanza de vida (0,32–0,69 frente a ≥ 0,95): memoria corta, no "sin memoria" (H4a ✔). El β ≈ −1 de la v1 es lo que da el ruido puro (placebo −1,00): H4 se rechaza como evidencia. La correlación mundial entre mortalidad infantil y migración (−0,45) desaparece dentro de cada grupo de ingreso (H21 ✔): es una diferencia de ingreso disfrazada de vínculo. H5 se rechaza: el −0,36 lo generan los microestados.

---

## 9. Incertidumbre de la ONU (OtherVariants): EAU y dirección 2050 (sección 9)

**Qué hicimos.** Leímos solo columnas de la lista blanca (`TPopulation1July`, `CNMR`) y pasamos el test de monotonía L95 ≤ L80 ≤ Mediana ≤ U80 ≤ U95 (18 249 / 18 249 filas). Fan chart de EAU y conteos de dirección 2050 en los 161 países.

| Cifra | Valor | Clave |
|---|---|---|
| EAU 2050, UN medium | **15,4 M** (IP 80 10,1–26,1; **IP 95 8,9–33,3**) | `pop_are_2050`, `pop_are_2050_pi95_low/high` |
| EAU 2050, variante *Zero migration* (escenario, no intervalo) | 12,4 M | `pop_are_2050_zero_mig` |
| EAU 2100 | 26,1 M (IP 95 2,3–77,4) | `pop_are_2100` |
| EAU 2023: CNMR / crecimiento / TFR | +28,2 ‰ / 3,70 % / 1,20 | `cnmr_are_2023`, `growth_are_2023`, `tfr_are_2023` |
| Países cuyo IP 95 % de 2050 incluye crecer y decrecer | **77 de 161** (IP 80: 47); seguro decrecen 17, seguro crecen 67 | `n_dir_uncertain_2050` |
| Países cuyo IP 80 % de la CNMR 2050 incluye 0 | 155 de 161 (IP 95: 161) | `n_cnmr_sign_uncertain_2050` |
| Revisión WPP2022 → 2024 de EAU | +12 % (**cifra externa**, pendiente de verificación humana) | `are_revision_pct` |

Figura: `q1_16_fan_eau.png`.

**Lectura de resultados.** La mediana probabilística coincide con la Medium (dif. 6 × 10⁻⁸). En EAU el IP 95 % de 2050 va de 9 a 33 millones: la migración es la palanca menos cierta. H22 se confirma (77 ≥ 54). La línea de migración cero se rotula *UN zero-migration scenario (a what-if, not a forecast)*.

---

## 10. Europa y decrecimiento natural (H2, H14, H14a) y apéndice (secciones 10 y 10b)

| Resultado | Valor | Clave |
|---|---|---|
| Europa (agregado ONU): primer año con más defunciones que nacimientos | 1993 | `year_europe_natneg.sens_note` |
| … años posteriores con saldo natural ≥ 0 | **2008–2014** | idem |
| … decrecimiento natural **todos** los años hasta 2023 desde | **2015** | `year_europe_natneg` |
| … 2000–2023: saldo natural / cambio total | −18,5 M / +17,3 M (migración = 207 % del cambio) | idem |
| Primer año con NatChange < 0 por región (H14) | Europa 1993 (estimación); Norteamérica 2040, Asia 2055, LAC 2055 (UN medium projection); África y Oceanía no antes de 2100 | parquet |
| Países y áreas con NatChange < 0 (H14a) | 8 (1990; 2 % de la población) → 53 (2023; 28 %) → 106 (2050, proyección) | claves de Q3 (`n_natneg_*`) |
| Shapley: parte de las diferencias de crecimiento 2023 que va con la migración | alto **0,51** [IC 0,38; 0,68]; medio-alto 0,35; medio-bajo 0,27; bajo 0,78 (0,37 sin SSD, SYR, SDN); mundo 0,29 | `shapley_mig_high_2023`, `shapley_mig_by_income_2023` |
| Misma fecundidad (TFR 1,5–1,99, 39 países) | saldo natural de −5,9 ‰ (Bulgaria) a +12,4 ‰ (Nepal); r con edad mediana −0,91 [−0,96; −0,80] | claves de Q2 (`n_band_tfr`, `nat_*_band`, `r_nat_medage_band`) |
| GAM TFR ~ s(log Q5) por ingreso, a Q5 = 100 | bajo 5,9 vs alto 3,8 hijos (AIC −18 468 vs −18 096 con curva común) | `gam_tfr_q5_100_*` |

Figuras: `q1_17_europa_decrecimiento_natural.png`, `q1_18_misma_fecundidad_shapley.png`.

**Lectura de resultados.** H2 se **rechaza** con su regla: Europa tuvo su primer año de decrecimiento natural en 1993, pero volvió a tener más nacimientos que defunciones en 2008–2014; el decrecimiento es continuo solo desde 2015. La segunda parte de H2 sí se cumple (2000–23: saldo natural −18,5 M y crecimiento +17,3 M, solo por migración). H14 queda como descriptiva (sus años futuros son proyección). H14a se confirma. Con la misma fecundidad, el saldo natural va de −6 a +12 por mil y sigue a la edad: la estructura de edad es una palanca escondida que la TFR no ve.

---

## 11. Estado de las hipótesis preinscritas de Q1

Familias: F1 = 7 contrastes que deciden hipótesis (Holm); F2 = 7 comprobaciones auxiliares (BH) + 29 celdas de rejillas (sin marcar) + 322 pruebas locales LISA (BH en cada mapa); F3 = 7 ilustraciones por regla sin inferencia (`n_tests_q1`). Ningún p-valor va al vídeo.

| ID | Estado | Evidencia (corrida final) |
|---|---|---|
| H1 | **confirmada** | 70,7 % [BCa 56,0; 111,9] [bloques 55,5; 133,3]; jackknife 64,5–81,6; sensibilidades 64,0–81,6 |
| H2 | **rechazada** | primer decrecimiento natural 1993, pero saldo ≥ 0 en 2008–2014; continuo solo desde 2015 (crece 2000–23 solo por migración: sí) |
| H3 | **rechazada** | medianas −11,5 a +39,5 años; mortalidad primero 16–100 % según el par de umbrales |
| H3a | **confirmada** | 106/109 = 97,2 % [92,2; 99,1]; 9 reglas 94–97 %; cota del rezago 22 [16; 28]; mediana no identificable |
| H3b | **confirmada** | 2000 / 1984 / 1970 (alto 1970); log-rank 73,4 (3 gl), Holm p ≈ 6 × 10⁻¹⁵ |
| H4 | **rechazada** | β = −0,90, dentro del placebo [−1,12; −0,88] |
| H4a | **confirmada** | CNMR 0,32–0,69 < mínimo TFR/LEx 0,95; 76 % mantiene el signo |
| H5 | **rechazada** | ≥ 1 M: +0,10 [−0,18; 0,43]; el −0,36 solo con microestados |
| H12 | **rechazada como cifra** | crecen 84; 79 = nacimientos > defunciones |
| H12a | **confirmada** | 84/130 (65 %); 82/124; 91/138; 86/130 (NRR) |
| H14 | **matizada** (descriptiva) | Europa 1993 (estimación); N. América 2040, Asia y LAC 2055 (proyección) |
| H14a | **confirmada** | 8 (1990) → 53 (2023) |
| H15 | **matizada** (confirmada por la regla con EE por país) | −0,41 [cluster −0,71; −0,12] vs −1,05; placebo [−0,25; 0,26]; **IC por bloques [−0,77; 0,05] incluye 0**; adelanto 0,28 (p = 0,08) |
| H16 | **confirmada** | +0,01 [cluster −0,17; 0,18] [bloques −0,20; 0,17]; solo FE país −0,16 |
| H17 | **confirmada** | hito 4: −80 % [69; 85]; hito 5: −77 %; hito 3: −71 % |
| H18 | **confirmada** | KM después de 1990 24,1 vs hasta 1990 18,8 años |
| H19 | **confirmada** | 22 países, 2,20 mil M (estricta 18, 2,20 mil M) |
| H21 | **confirmada** | mundo −0,45; dentro de cada grupo +0,08 / +0,16 / +0,17 / −0,07 |
| H22 | **confirmada** | 77 de 161 (IP 80: 47) |
| H24 | **confirmada** | TFR 0,74, LEx 0,69, edad mediana 0,77, CNMR 0,11 (sin Golfo −0,03) |

Tabla completa con las reglas: `data/processed/resultados_q1_hipotesis.parquet`; contrastes y p ajustados: `resultados_q1_contrastes.parquet`.

---

## 12. Hallazgos sorprendentes y limitaciones

**Hallazgos nuevos (no estaban en el plan, o salen distintos).**
1. **Europa no lleva 30 años de decrecimiento natural:** volvió a tener más nacimientos que defunciones en 2008–2014; el decrecimiento continuo empieza en 2015 (H2 cae).
2. **La relación mortalidad–fecundidad dentro del país se invierte en Europa y Norteamérica** (+0,39 [0,23; 0,56]) y se anula en ingreso medio; ponderar por población la vuelve positiva (+0,08).
3. **El IC por bloques de la cifra "dentro del país" incluye el 0** [−0,77; 0,05], aunque el placebo y el IC por país la separan del 0: la dependencia entre vecinos pesa.
4. **Irán entra en el único vecindario migratorio robusto** (con los 6 del Golfo); con un solo año (2023) no sobrevive ninguno a la corrección por pruebas múltiples.
5. **El "reloj" de China** (bajar de 2,1 en 1991 → pico en 2021 = 30 años) cae dentro del rango proyectado para los 13 países de inercia ≥ 1 M (32–40), pero en el borde bajo.
6. **Shapley:** en ingreso bajo, la migración "explica" el 78 % de las diferencias de crecimiento de 2023 solo por tres países en conflicto o posconflicto (SSD, SYR, SDN); sin ellos, 37 %.

**Limitaciones.**
- Todo es descriptivo: ingreso de hoy aplicado a 1950–2023; la transición es en parte la causa del ingreso, no al revés.
- La migración neta es el componente peor medido (residuo censal en muchos países); 2023 es un solo año y los conteos de tipo cambian con la ventana (C: 14–25).
- Censura: la mediana del rezago mortalidad → fecundidad no se identifica; el registro excluye a los 26 países que no han cruzado 4 (sesgo de supervivencia).
- El LISA del Golfo depende de la resolución de la permutación (p mínimo 0,001 con 999): con menos permutaciones no sobrevive a la FDR.
- Los picos de población de la inercia y todo lo posterior a 2023 son escenarios de la ONU (Medium), no observaciones.
- `are_revision_pct` (+12 %) es una cifra **externa** que no se puede calcular con los archivos WPP2024: debe verificarla una persona contra WPP2022 antes de usarla.
- Mapa de revisión: Crimea aún sin reasignar a Ucrania (lo hará la figura final con `R/utils_mapas.R`).

---

## 13. Frases propuestas para el vídeo (inglés, cifras reales sustituidas)

**Cover.**
> In 2023, 130 of 237 countries and areas had below-replacement fertility: too few children to replace their parents. Yet 84 are still growing. 66 because births still outnumber deaths; 18 only because more people arrive than leave. One number can't explain that.

**Slide 1.**
> In today's high-income countries, net migration accounted for about seven in ten of the growth since 2000. Elsewhere, growth came almost entirely from births exceeding deaths.
> Blue: growing from births, including 22 countries below replacement, home to 2.2 billion people.
> Light blue: deaths exceed births, but arrivals keep it growing: Germany, Spain and Belgium.
> Orange: deaths exceed births, and the population shrinks: China, the Russian Federation and Japan.
> Purple: more births than deaths, yet shrinking, as more people leave than arrive: Nepal, Azerbaijan and Uruguay.
> For the Emirates in 2050, the UN gives a 95 percent range of 8.9 to 33.3 million.

En pantalla: `net migration ≈ 70.7 % of population change (64–78 % with other income lists and periods)` · `light blue: 18 in 2023 (15–25 depending on the year)` · `UN medium projection, 2050: 15.4 M · 95 % range 8.9–33.3 M` · `77 of 161 countries: the UN 95 % range for 2050 includes both growth and decline` · `UN zero-migration scenario: 12.4 M (a what-if, not a forecast)`.

**Slide 2.**
> Set each country's clock to when its fertility fell below four children, and the curves line up. The road is shared; the speed is not.
> China went from five to three children in 5 years; Egypt took 33.
> Child deaths moved first: in 106 of 109 high-fertility countries, typically at least 22 years before fertility.
> Within one country, this link is less than half what comparing countries suggests. A sequence in time, not proof of cause.
> Question one, answered: child deaths fell first and births followed, at each country's pace; latest in low-income countries. Migration moves on its own, alike among neighbours only in the Gulf, and weighs most in high-income countries.

En pantalla: `lining countries up on the year fertility fell below 4 removes 80 % of the gaps between them` · `26 countries, mostly in sub-Saharan Africa, have not crossed 4 yet; 45 were already below 4 in 1950` · `child mortality had already fallen by about half (50 %)` · `Fertility began to fall: ≈ 1970 upper-middle · 1984 lower-middle · 2000 low income` · `child mortality was already falling in 1950 in 92` · `Within the same country, halving child mortality goes with −0.41 children per woman over the next 20 years — comparing countries, −1.05` · `clearest in sub-Saharan Africa (−1.20); reversed in Europe & N. America (+0.39)` · chip: `births & deaths ≥ 0.95 · migration 0.69` · `neighbouring countries: fertility 0.74 · migration 0.11 (−0.03 without the Gulf)`.

**Cambios que esto obliga en el guion:** "105 of 108" → **106 of 109**; "not detected in Europe & N. America" → **"reversed in Europe & N. America"**; si fig06 muestra intervalos, deben ser los de bloques (el de "All" cruza el 0); la tabla de la Slide 4 usa `momentum_years_range` de Q3, no de Q1.

---

## 14. Reproducibilidad

- `Rscript R/02_q1_palancas.R` desde la raíz; semilla 2026 fijada justo antes de cada remuestreo (`bootstrap_bloques`, `bootstrap_bca`, permutaciones de Moran, LISA, placebo y validación cruzada); `RNGkind("Mersenne-Twister", "Inversion", "Rejection")`.
- Tres corridas oficiales seguidas (9:29, 11:35 y 8:54 min) producen `figures/numbers_q1.json` idéntico byte a byte (`cmp`); los cambios entre ellas fueron solo de texto de figuras de revisión.
- Réplicas: B = 2 000 (cifras de pantalla), 1 000 (solo notebook), 300 (placebo del panel), 999 (Moran y LISA). Modo de desarrollo `Q1_RAPIDO=1` (no oficial).
- `validar_registro()` sin problemas; `claves_faltantes()` de universo, slide1 y slide2: ninguna. Sin colisiones de claves con `numbers_q2.json` ni `numbers_q3.json` (Q1 dejó de registrar `momentum_years_range`, `n_band_tfr`, `nat_min_band`, `nat_max_band` y `r_nat_medage_band`, que pertenecen a Q3 y Q2).
