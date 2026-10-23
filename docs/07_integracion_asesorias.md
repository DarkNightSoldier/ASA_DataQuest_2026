# 07 — Integración de asesorías en el plan (registro de decisiones, v2)

> Agente `integrate-advice` · 2026-10-22/23. Memos integrados: `06_asesoria_series_tiempo.md` **[ST]**, `06_asesoria_multivariado.md` **[MV]**, `06_asesoria_datos_funcionales.md` **[FDA]**, `06_asesoria_demografia_social.md` **[DEM]**, `06_asesoria_panel_econometria.md` **[PN]**, `06_asesoria_inferencia_incertidumbre.md` **[INF]**, `06_asesoria_espacial.md` **[SP]** (llegó durante la integración; integrado completo), `04_etica_ASA_aplicada.md` **[ET]**, `05_catalogo_visualizacion.md` **[VIZ]**; contexto `01b_otros_equipos_2025_2026.md` **[01b]**, `02_contexto_historico.md` **[HIS]**, `03_hechos_clave_datos.md` **[03]**.
> Documentos modificados: `00_plan_analitico.md` (**PA**), `00_storyboard_diapositivas.md` (**SB**), `00_plan_implementacion.md` (**PI**); creados: `hipotesis_preinscritas.md` (**HP**) y este archivo.
> Regla de prioridad: evidencia empírica de los memos > plan v1; si dos memos discrepan, se elige con argumento (§3). Decisión: **A** = aceptada · **M** = modificada · **R** = rechazada.

---

## 1. Resumen: las decisiones que más cambian el proyecto

1. **P7 se responde con supervivencia, no con un "rezago mediano"**: orden (97 %, Wilson 92–99), cota inferior ("at least 22 years") y año de inicio de la caída de la TFR por ingreso (1970 / 1984 / 2000). Cuatro memos coinciden [ST][FDA][INF][PN]; la mediana no está identificada por censura izquierda [INF].
2. **"Same road, different speed" literal** con el registro por hitos (−80 % de varianza) en lugar del connected scatter [FDA].
3. **Modelo rico de P7 = panel en cambios quinquenales con FE** y comparación honesta dentro/entre países (−0,41 vs −1,05) en un mini-forest por ingreso [PN][ST].
4. **P8 = prueba de parecidos** (look-alikes 13 % vs 43 %, ejemplo Colombia) + "two real dimensions" (análisis paralelo); el % de PC1 deja de ser titular [MV][INF].
5. **Gancho, año base y ética**: 130 → 84 (66 + 18) con 2023 como única definición; FY2027; sin logos; nombres neutrales; incertidumbre visible una vez (EAU); IC en pantalla por bloques de subregión [DEM][ET][INF][SP].

---

## 2. Tabla maestra: recomendación → decisión → por qué → dónde

### 2.1 Series de tiempo [ST]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| ST1 | Sustituir H3 / `rezago = anio_tfr_4 − anio_q5_100` por inicio de la caída sostenida (−10 %, TFR₁₉₅₀ ≥ 5) con KM por ingreso/región; umbrales solo como sensibilidad | **M** | Aceptado el método; la magnitud "22" se reporta como **cota inferior** (INF: mediana no identificable) | PA §3 (variables), §4-Q1 R1, §5 H3/H3a; HP H3, H3a; PI §3.1 T3 |
| ST2 | Slide 2 build 2: event time (st01) en lugar del dumbbell; narración "105 of 108 … at least 22 years … halved" | **A** | Coincide con FDA (fda_04); se fusionan en fig05 | SB §3 build 2; PI §7.3 |
| ST3 | Gradiente del rezago por ingreso (KM 36 / 25 / 14 / 16) en Slide 2 | **M** | Rezagos censurados por la izquierda → solo cotas; se narra el **año de inicio de la TFR** por ingreso (identificado, INF) | SB §3; PA §4-Q1 R1; notebook (st02) |
| ST4 | Quitar H5 del guion y del heatmap | **A** | Cambia de signo con ≥ 1 M (+0,10) | PA §5, §12; HP H5 |
| ST5 | Slide 2 build 3: β → correlación 1950–2023 (0,14 vs 0,52) | **M** | "No memory" choca con la persistencia entre décadas (DEM); 0,14 queda en el notebook; en pantalla la correlación década a década (0,67 vs ≥ 0,95) | SB §3 build 4 (chip); PA §4-Q1 R4; HP H4/H4a |
| ST6 | P1: razón P90/P10 de Q5 6× → 20× | **A** | Hallazgo robusto y llano | SB §5 build 2; PA §4-Q3 S2, S12 |
| ST7 | β con medias 1950–54 / 2019–23, σ₀ y σ₁ al lado, log Q5, placebo; sin 1950–2100 | **A** | Falacia de Galton | PA §4-Q3 S2, §8 limitación 5; PI T6/T12 |
| ST8 | σₜ ~ t solo 1950–2023 con Newey–West o banda; TFR "rose until 1990, then fell" | **A** | Residuos autocorrelacionados 0,75–0,99 | PA §4-Q3 S2; PI T12 |
| ST9 | Corregir velocidades (E/SE Asia 32, LAC 30; Europa censurada) | **M** | El connected scatter sale del vídeo; la velocidad se cuenta con 5 → 3 (FDA); las cifras regionales van al notebook; "Europe took a century" eliminado | PA §12; SB §3 notas |
| ST10 | Barra "10 years later" en el scorecard | **M** | Límite de 3 visuales; la comparación honesta fuera de muestra se hace con PN (M0–M4) y con la VC del scorecard; la escalera fuera de tiempo va al notebook | PA §4-Q2 (solo notebook); PI T8 |
| ST11 | Prohibir correlaciones temporales de niveles; figura placebo st03 | **A** | Placebo −0,84 = −0,84 | PA §3; PI §3.1 "Quitar" |
| ST12 | Panel opcional en cambios quinquenales, rezagos 0–20 en ambos sentidos | **A** | Fusionado con PN (medias quinquenales) | PA §4-Q1 R3; PI T5 |
| ST13 | Calendario de choques (st05) en la franja de ética | **M** | En el notebook; la tarjeta "Scenarios, not forecasts" lo resume en texto ("contains no shocks") | SB §5 tarjeta 1; PI T14 |
| ST14 | Connected scatter con 4 regiones resaltadas y contador gris tras 2023 | **M** | Sale del vídeo (sustituido por registro FDA) → apéndice; la regla del contador gris se aplica a toda animación | PI §5; SB §3 notas |
| ST15 | Unificar FY2027; declarar siempre el universo | **A** | Coincide con 5 memos | PA §3; SB §6; PI §6 |
| ST16 | Advertencia de RCA, datos suavizados, "countries that are low-income today" | **A** | — | PA §6, §8; §4 de este archivo |
| ST17 | Descomposición de varianza cov(g, m)/var(g) | **A** | Coincide con PN y Shapley (MV) | PA §4-Q1 R4; PI T5 |
| ST18 | Volatilidad proyectada 33× / 13,5× / 20× | **M** | Otras medidas dan otros números (ET, DEM): se declara una medida en el notebook y en pantalla se usa "0 countries lose life expectancy in any projected year" | PA §6 S13, §12; PI T14 |

### 2.2 Multivariado [MV]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| MV1 | PCA esperado 56,7 % / 17,9 % / 2 PCs; análisis paralelo en lugar de Kaiser; sin Golfo PC2 13 % | **A** | Cálculo con el conjunto fijo del plan | PA §4-Q2 R2; HP H7/H7a |
| MV2 | Narración "two real dimensions … blind to the second, migration" | **A** | El % depende de las variables (46–77 %) | SB §4 build 3 y voz |
| MV3 | Look-alikes como métrica sobre los gemelos + tarjeta Colombia | **A** | Demostración sistemática de P8; Colombia con línea de posicionalidad (ET #26) y tabla completa publicada | SB §4 build 2; PA §4-Q2 R1; HP H20 |
| MV4 | Sustituir "ρ² media" por perfil recuperado + look-alikes; claves nuevas | **A** | Más explicable | PA §4-Q2; PI §4 |
| MV5 | Scorecard: 4 salidas a priori, spline, CNMR ≈ 0 | **A** | — | HP H6; SB §4 build 1 |
| MV6 | P5 con Monte Carlo declarado; 21 %; α fuera de pantalla; UKR | **A** | α no prueba robustez; "weights, not formulas, decide" | PA §4-Q2 R3; SB §4 build 4; HP H8a |
| MV7 | Silueta 0,37, gap k = 3, Jaccard; CNMR entra a priori; grupo 4 = *Migration-boosted*; `jacc_boot()` | **M** | Todo aceptado salvo el nombre: **Migration-led** (ET E35) | PA §4-Q3 R1; PI §6 nombres; HP H9a |
| MV8 | India en Fast movers; tamaños; fanny 42 %; describir con variables externas | **A** | — | SB §5; PA §4-Q3 R1 |
| MV9 | Reescribir H5; pendientes TFR ~ log Q5 por ingreso; rango restringido | **A** | — | PA §4-Q1 R4; HP H5 |
| MV10 | S15 Simpson; Shapley como alternativa para Slides 1–2 | **M** | Simpson → notebook + HP H21; Shapley al notebook (la voz usa la participación contable 7 de 10) | PA §6 S15; PI T6 |
| MV11 | Documentar la winsorización (7 países; 144 país-años) + asinh | **A** | — | PA §3 |
| MV12 | Unificar FY2027 | **A** | — | PA §3 |
| MV13 | Sin ANOVA circular; factorial, parciales y VIF al apéndice | **A** | — | PA §4-Q2/Q3 (notebook) |

### 2.3 Datos funcionales [FDA]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| FDA1 | Mantener k-means por décadas; FPCA como validación (ARI 0,96); quitar DTW y `fpc` | **A** | Mismo resultado, explicación más simple | PA §4-Q3 R1; PI §3.1 "Quitar" |
| FDA2 | Silueta 0,37; tamaños 49/51/54/7; India Fast | **A** | Confirmado por MV (50/51/53/7): rango en el plan | SB §7; PA §4-Q3 |
| FDA3 | Reescribir H9 | **A** | — | HP H9/H9a |
| FDA4 | Slide 2 build 1 = animación de registro (−80 %) | **A** | "Same road, different speed" literal; sustituye al connected scatter | SB §3 build 1; PI T4 |
| FDA5 | Slide 2 build 2 = fda_04 | **A** | Fusionado con ST2 (fig05) | SB §3 |
| FDA6 | Último cruce en curva suavizada; Turnbull; `inicio_*`; `dur_5a3` | **A** | — | PA §3 variables |
| FDA7 | Velocidad 5 → 3 con KM; China 5 vs Egipto 33; sin "los tardíos van más rápido" | **A** | — | SB §3; HP H18 |
| FDA8 | R²(región) y R²(ingreso) por año | **A** | — | PA §4-Q3 S2 |
| FDA9 | Sección de curvas atípicas; Eswatini (no Botsuana); RCA como artefacto | **A** | — | PA §6; PI T12; §4 |
| FDA10 | Panel FE a apéndice (placebo de adelanto falla); GAM opcional | **M** | El fallo es del panel **en niveles** con un rezago de 10 años, que también rechazan ST y PN; el panel **en cambios** de PN pasa el placebo de permutación → se mantiene como modelo rico, reportando adelanto y sentido inverso ("co-movimiento"). GAM al notebook | PA §4-Q1 R3, §12; §3 conflicto C4 |
| FDA11 | Claves `numbers.json` | **A** | — | PI §4 |
| FDA12 | Referencias Ramsay & Silverman, Kneip & Ramsay, etc. | **A** | — | SB §6 |
| FDA13 | Clustering por velocidades y derivadas para fechar caídas | **R** (vídeo) | Inestables / no identificadas; se reportan como resultado negativo | PA §4-Q3 (notebook), §12 |

### 2.4 Demografía y estadística social [DEM]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| DEM1 | Gancho 84 = 66 + 18 | **A** | Verificado en R por el integrador | PA §1; SB §1; HP H12a |
| DEM2 | Base 2023; sensibilidad 2017–19 y 2021–23 | **A** | La ventana 2021–23 contiene COVID y Ucrania (conflicto C1) | PA §3; SB §2 |
| DEM3 | FY2027; no validar contra agregados ONU por ingreso; nota 64–71 % | **A** | — | PA §3, §4-Q1 S1 |
| DEM4 | Nueva figura dem01 en Slide 2 build 3 | **M** | La Slide 2 build 3 es el mini-forest de PN (conflicto C3); dem01 al apéndice; su mensaje de inercia va a la Slide 1 | PA §4-Q1 (notebook) |
| DEM5 | Hallazgo de inercia (22 países, 2,2 mil M) | **M** | Va a la Slide 1 (mapa + voz) y a la recomendación 2. **Precisión del integrador:** 22 = tipo B (NetMigrations ≤ 0); 18 con emigración neta estricta y 4 con migración 0 → la voz dice "growing from births", no "although more people leave" | SB §2; PA §6 S4; HP H19 |
| DEM6 | "Short memory" | **A** | — | SB §3; PA §12 |
| DEM7 | Ejemplos por regla con 2023 (DEU/ESP/BEL · CHN/RUS/JPN · NPL/AZE/URY) | **A** | Verificado en R | SB §2; PI §4 reglas |
| DEM8 | Tarjeta El Salvador + 2 gemelos; mantener EAU–Bielorrusia; quitar Jordania–Bosnia | **M** | La tarjeta B la ocupa Colombia (look-alikes, MV); El Salvador al notebook; Jordania–Bosnia fuera | SB §4 build 2 |
| DEM9 | Línea CDR (Portugal–Chad) en el pie del scorecard | **A** | — | SB §4 build 1 |
| DEM10 | S11 = China | **A** | — | PA §6 S11, §12 |
| DEM11 | "Faster than anyone before" → "about 25 years what Europe took 40 to 50" | **A** | Con "projected" | SB §5 voz; PA §12 |
| DEM12 | LE65 principal; LE60 robustez | **A** | — | PA §3; HP H11a |
| DEM13 | S2: 6 islas pequeñas; Irlanda/Portugal como contraejemplo | **A** | — | PA §6 S2; PI T15 |
| DEM14 | Personajes USA/India/Germany/China/Nepal (+ Nigeria–Mauricio) | **M** | Regla "3 más poblados por tipo y por grupo" en código; Nigeria–Mauricio al notebook y como etiqueta anti-estigma opcional | PI §4 reglas |
| DEM15 | Tabla de recomendaciones por estado de la palanca | **A** | Reducida a 5 filas en pantalla, con columna "Road" (Q3) | PA §7; SB §5 |
| DEM16 | NRR como sensibilidad de "reemplazo" | **A** | — | PA §3 |
| DEM17 | Medición: 1 de enero vs 1 de julio, crecimiento exponencial, ‰ vs %, CDR | **A** | — | PA §3 |
| DEM18 | China/India como segmento en las barras; prueba "sin el país más grande" | **A** | — | SB §2 build 2; PA §3 |
| DEM19 | ODS 3.2 (8 de 70) y países con más muertes que nacimientos (8 → 53 → 106) | **A** | — | PA §6–§7; HP H14a, H23 |
| DEM20 | Terminología ONU (§4 #8) y riesgos (determinismo, falacia ecológica, estigma) | **A** | — | PA §8 |

### 2.5 Econometría de panel [PN]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| PN1 | Rico 4: cambios quinquenales, rezagos 0–20 sumados, FE país + periodo, EE por país, `split`; placebo, adelanto, inverso, LOO | **A** | Pasa el placebo de permutación | PA §4-Q1 R3; PI T5 |
| PN2 | H15 y H16 | **A** | Como *exploratory* | HP H15, H16 |
| PN3 | Slide 2 build 3 = mini-forest (5 filas) | **A** | Responde "by income" literal (conflicto C3) | SB §3 build 3 |
| PN4 | Quitar "fills the gap"; frase de calendario compartido | **A** | Evidencia: +0,01 dentro del país | SB §2 nota gris; PA §12 |
| PN5 | Mensaje: "child mortality began to fall first (onset); afterwards both moved together" | **A** | Combina ST e INF | SB §3 mensaje |
| PN6 | Heatmap de acoplamiento rotulado "across countries in year t" + descomposición de varianza | **A** | Solo apéndice | PA §4-Q1 |
| PN7 | Nota al 71 %: "shared calendar, not compensation"; sin Golfo 7 % | **A** | — | SB §2 build 2 |
| PN8 | Limitaciones 8–10 | **A** | — | PA §8 |
| PN9 | Comparación honesta M0–M4 como métrica simple vs rico | **A** | Receta ganadora ★★★3, sin comparar con otros equipos en el vídeo | PA §4-Q1 R3; PI T5 |
| PN10 | Constantes en `config.R` | **A** | Las añade prepare-data | PI §6 |
| PN11 | "País" de P7 vía mapa/tipología; LOO | **A** | — | PA §4-Q1 |
| PN12 | FY2027 | **A** | — | PA §3 |

### 2.6 Inferencia, incertidumbre y supervivencia [INF]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| INF1 | Campos de incertidumbre en cada clave de `numbers.json` | **A** | + `method: "block bootstrap by subregion"` (SP) y `ci_iid_*` | PI §4 |
| INF2 | Fan chart de EAU en Slide 4 build 4 y/o Slide 1 | **M** | En la **Slide 1** (zoom al Golfo), donde aparece el riesgo; la Slide 4 ya tiene 3 visuales (conflicto C8) | SB §2 build 5 |
| INF3 | Sustituir el IP de edad mediana de China por el de población; Medium = media (TFR/LEx) o mediana (migración) | **A** | Columnas PI de edad mediana rotas | PA §3, §7; PI §6 PIE-5 |
| INF4 | Lista blanca + test de monotonía de OtherVariants | **A** | — | PI §3.1 T0 |
| INF5 | Narración P7 con años de inicio por ingreso; `n_q5_falling_1950` | **A** | — | SB §3 |
| INF6 | Una sola definición: promedio 2021–23 ("about two dozen, 24") | **M** | Se mantiene "una sola definición" y el rango 15–25, pero con **2023** como base (conflicto C1) | PA §3; SB §1–2 |
| INF7 | Corregir valores (`r2_tfr_cnmr` 0,005; `rho_cdr_lex_2023` ≈ 0; 70,7 % con BCa) | **A** | — | SB §7 |
| INF8 | B = 2 000 para BCa; 1 000 para PCA | **A** | — | PA §3; HP convenciones |
| INF9 | Archivo de hipótesis con fecha antes del 25-oct; *pre-specified*, no *pre-registered* | **A** | Nombre del archivo: `hipotesis_preinscritas.md` (encargo) | HP; PI §3 fila 1b |
| INF10 | Secciones "How uncertain are our numbers?" y "What we tested" | **A** | — | PI T17 |
| INF11 | Recomendaciones con "projected (UN medium)"; IP de China; migración = *monitor* | **A** | — | PA §7; SB §5 |
| INF12 | Checks extra de QA-stats | **A** | — | PI §7.7 |

### 2.7 Espacial [SP]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| SP1 | Slide 2: *"almost no memory and almost no neighbourhood … except in the Gulf"* + chip fertility 0,52 · 0,74 / migration 0,14 · 0,12 | **M** | Se adopta "almost no neighbourhood … except in the Gulf"; "almost no memory" se cambia por **"a short memory"** (DEM: persistencia entre décadas, conflicto C2); el chip usa la correlación década a década (0,67 vs ≥ 0,95) y Moran (0,12 vs 0,74) | SB §3 build 4 y voz |
| SP2 | Slide 4: "Two in three neighbouring countries share the same road (chance: one in three)"; mensaje sin "not where they are" | **A** | Validación externa no circular; evita la ambigüedad geográfica | SB §5 build 1 y mensaje; HP H25 |
| SP3 | Chip opcional del Golfo en Slide 1 ("only clear migration neighbourhood") | **R** (vídeo) | Espacio: el zoom ya lleva el inset de EAU y la nota de revisión; va al notebook | PA §4-Q1 S3 |
| SP4 | Fila "Simple 3: ¿se parecen los vecinos?" + hipótesis de Moran | **A** | Apoyo (chip) + notebook; renumerada H24 (el memo la llamaba H15, choque con PN) | PA §4-Q1 S3; HP H24 |
| SP5 | Join count y voto de vecinos como validación de los clústeres, con la referencia regional (78 %) | **A** | — | PA §4-Q3 R1 |
| SP6 | IC de las cifras en pantalla por **bootstrap por bloques de subregión** (1,4–2,2× más anchos) | **A** | `method: "block bootstrap by subregion"`; el notebook guarda también el iid BCa de INF | PA §3; PI §4; HP convenciones |
| SP7 | Mapas con `s2` + Robinson propio (sin `sf`) | **M** | `sf` ya está instalado y probado → `sf` + Robinson principal (encargo); la plantilla `s2` queda como respaldo y **se adoptan todos sus ajustes** (Crimea → UKR, DOM franceses, marco 58° S–85° N, franja de pequeños Estados, nota de no-aval) | PI §5; SB §2 notas |
| SP8 | Fijar la ventana del mapa (con 2021–23 serían 24) | **A** | Fijada en 2023 (18); la plantilla esp07 debe re-ejecutarse con 2023 | PA §3 |
| SP9 | Sección "Dependencia espacial" en el notebook: LISA con FDR, serie por rangos, modelo espacial y panel SLX **solo notebook** | **A** | — | PI T7; PA §4-Q1 S3 |
| SP10 | Prohibir *contagion, spread to, spillover*; permitir *neighbours look alike / share / cluster* | **A** | — | PI §6 lenguaje |
| SP11 | GWR / SAR descartados; no copiar el GWPR de TRITICS | **A** | Sobreajuste con 161 unidades | PA §12 |

### 2.8 Ética [ET]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| ET1 | Incertidumbre oficial visible (EAU 2050 8,9–33,3 M) | **A** | Slide 1 | SB §2 build 5 |
| ET2 | *Data fitness* de la migración en voz y pie (residuo censal; revisión del Golfo +12 %) | **A** | — | SB §2, tarjeta 2 |
| ET3 | Hipótesis con fecha + "What we did not find" | **A** | — | HP; PA §12 |
| ET4 | Regla escrita para ejemplos | **A** | — | PI §4 |
| ET5 | Declaración de IA y verificación humana | **A** | — | SB §6, tarjeta 5; PA §8 |
| ET6 | #10/E3: una sola definición = promedio 2021–23 | **M** | Una sola definición sí; año = 2023 (conflicto C1) | PA §3 |
| ET7 | #18/E35: *Recent movers*, *Migration-led*; paleta sin semáforo | **A** | — | PI §6; SB §8 |
| ET8 | #21/E7/E38: sin logos de la ONU; agencias en texto | **A** | — | SB §1, §2, §5 |
| ET9 | E1 subtítulo "countries and areas … estimates … projections" | **A** | — | SB §1 |
| ET10 | E2 "seventy-nine still have more births than deaths" | **M** | Sustituido por 84 = 66 + 18 (más informativo; DEM) | SB §1 |
| ET11 | E6/E10/E11 mensaje de ingreso alto ("today's high-income countries, FY2027") | **A** | — | SB §2 |
| ET12 | E12–E14 ejemplos por regla | **A** | Con 2023 son DEU/ESP/BEL, CHN/RUS/JPN, NPL/AZE/URY (la propia ética admite Nepal/Uruguay "if 2023") | SB §2 |
| ET13 | E16 nota de revisión del Golfo | **A** | — | SB §2 build 5 |
| ET14 | E18–E27 (Slide 2) | **A** | Superadas por el nuevo contenido; se aplican sus principios (sin "shocks", "Everyone heads here", "Europe took a century", "fills the gap") | SB §3 |
| ET15 | E28–E33 (Slide 3) | **A** | Identidad en el pie; CDR con ρ(CDR, edad mediana); "Bosnia and Herzegovina" ya no aparece; bump fuera | SB §4 |
| ET16 | E34–E46 (Slide 4) | **A** | — | SB §5 |
| ET17 | E47–E50 referencias (FY2027, documentos ONU, IA, Natural Earth) | **A** | — | SB §6 |
| ET18 | §3.1 panel de ética + §3.2 voz (versión A, 61 palabras) | **M** | 5 tarjetas tipo "Use with care" (01b A11) y voz de 25 palabras; las cifras de EAU ya se dijeron en la Slide 1 | SB §5 builds 4–5 |
| ET19 | §3.3 badges PIE-0…PIE-6 | **M** | PIE-5 corregido (media/mediana, INF); PIE-3 con "block bootstrap by UN subregion" | PI §6 |
| ET20 | §4 checklist y grep | **A** | Ampliado con PN y SP | PI §6, §7.9 |
| ET21 | #7: IP de la edad mediana de China | **R** | No existe un IP válido en el archivo (INF) → IP de la población | PA §7 |
| ET22 | #17: sensibilidad con la clasificación histórica del Banco Mundial | **M** | Si el archivo histórico (OGHIST) está disponible; si no, sensibilidad con los agregados ONU (otra vintage) y sin Rusia, y se declara | PA §3 |
| ET23 | Repositorio público antes de enviar | **A** | Coordinado con 01b (privado hasta la mañana del 30-oct) | PA §8; PI §7.13 |

### 2.9 Catálogo de visualización [VIZ]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| VIZ1 | Animar datos (una vez, en el momento memorable) | **A** | Registro por hitos (fig04) | SB §3 |
| VIZ2 | Mapa sin estigmatizar (categorías, no intensidad roja) | **A** | Paleta ET | PI §6 |
| VIZ3 | Banderas con ISO3 | **A** | — | SB §8 |
| VIZ4 | Divergencia como forma (ridgeline / fan) | **A** | fig11 (fan) | SB §5 |
| VIZ5 | Bump chart del índice en pantalla | **M** | Al apéndice; P5 como línea de texto | PA §4-Q2 R3 |
| VIZ6 | Ruta `sf` + Robinson "en cuanto esté" | **A** | Ya está | PI §5 |
| VIZ7 | Tema con "Inter" | **M** | Lato (instalada y fijada en `config.R`) | PI §6 |
| VIZ8 | Semántica verde = natural, bermellón = migración | **M** | Sustituida por azul / celeste / naranja / púrpura (ET; coherente con el mapa) | PI §6 |

### 2.10 Otros equipos [01b] (acciones a–d) e historia [HIS]

| ID | Recomendación | Dec. | Por qué | Dónde |
|---|---|---|---|---|
| 01b-A1 | Plan bloqueado con fecha y sha256; addendum; post hoc | **A** | `hipotesis_preinscritas.md` + `make prereg` | HP; PI §3 fila 1b |
| 01b-A2 | Estabilidad por país y rayado en el mapa | **A** | — | PI T11; SB §5 |
| 01b-A3 | Rejilla de sensibilidad en una figura | **M** | Sin DTW: {k-means, Ward, PAM, FPCA} × {161, 237} × {con/sin CNMR} × {décadas, quinquenios} | PI T11 |
| 01b-A4 | Fan charts en pantalla | **A** | EAU | SB §2 |
| 01b-A5 | Correlaciones pooled / between / within | **A** | Vía panel (Mundlak, descomposición de varianza) | PA §4-Q1 R3 |
| 01b-A6 | % de países donde \|mig\| > \|nat\| por región | **A** | Apéndice | PA §4-Q1 |
| 01b-A7 | Frontera 2023/24 cuantificada (monotonía) | **A** | — | PI T14 |
| 01b-A8 | Lista de usos indebidos | **A** | Tarjeta "Levers, not verdicts" | SB §5 |
| 01b-A9 | 195 + 42 | **A** | Tarjeta de datos; columna `soberano` | SB §2; PI §7.1 |
| 01b-A10 | CV además de DE | **A** | — | HP H11a |
| 01b-A11 | Tarjeta "Use with care" | **A** | 5 tarjetas | SB §5 |
| 01b-A12 | Method strip + guía del notebook + preguntas de defensa | **A** | — | SB §5; PI §2 |
| 01b-§5.5 | `feols(TFR ~ l(Q5,10) + CNMR | pais + anio)` obligatorio | **R** | Espurio en niveles (ST, PN, FDA) | PA §12 |
| 01b-§5.6 | Tres umbrales del rezago en pantalla | **R** (vídeo) | Los umbrales dan 16–100 %: van al notebook; en pantalla el orden | PA §4-Q1 R1 |
| 01b-§6 | No usar "converge", "corridor", "pathways", "timings" en títulos | **A** | Diferenciación | PA §1 |
| HIS-H1 | VIH con Eswatini (no Botsuana −20) | **A** | — | PA §6; §4 |
| HIS-H2/H8/H12 | Golfo, Ucrania (supuestos), límites de los datos | **A** | Notebook y tarjeta 2 | PA §8 |
| HIS-Anexo C | Checklist de verificación | **A** | §4 de este archivo | — |

---

## 3. Contradicciones entre memos y cómo se resolvieron

| # | Tema | Posiciones | Decisión y argumento |
|---|---|---|---|
| C1 | Año base de la palanca | ET (#10, E3) e INF (#6): promedio 2021–23 ("suaviza COVID/Ucrania"; "about two dozen, 24"). DEM (O3) y SP (#8): fijar la ventana; DEM propone **2023** con 2017–19 de sensibilidad | **2023.** La premisa de ET/INF (que 2021–23 suaviza los choques) la refuta DEM con datos: la ventana **contiene** el exceso de muertes de 2021 y las llegadas desde Ucrania de 2022 (Polonia entraría en "crece solo por migración", lo que trivializa un desplazamiento forzado, ASA D.6). Se cumple la exigencia central de ET (una sola definición en portada, mapa, voz y JSON) y la de INF (rango 15–25 visible). Nota: el encargo decía que ética y demografía "coinciden" en 2023; en realidad ética recomendaba 2021–23 — se deja constancia. |
| C2 | Memoria de la migración | ST: β ≈ −1 es ruido; ρ(1950, 2023) = 0,14 → "almost no memory". SP: "almost no memory and almost no neighbourhood". DEM: entre décadas 0,32–0,68 y 76 % mantiene el signo → **"short memory"** | **"A short memory and almost no neighbourhood, except in the Gulf."** El 0,14 compara dos años separados por 73 años; la correlación década a década es la medida de persistencia que un demógrafo aceptaría. Se toma de SP la parte espacial y de DEM la temporal; ambos números (0,14 y 0,67) quedan en el notebook. |
| C3 | Tercer visual de la Slide 2 | DEM: `dem01` (misma fecundidad, direcciones opuestas). PN: mini-forest dentro/entre. ST: línea de memoria. SP: chip memoria + vecindario | **Mini-forest (PN) + chip de texto (DEM/SP).** El forest responde literalmente la cláusula "by income" de P7 y es la comparación simple vs rico; `dem01` es apéndice y su mensaje (inercia) pasa a la Slide 1. |
| C4 | ¿Panel sí o no? | FDA: no aporta (el adelanto supera al rezago). ST y PN: sí, en cambios quinquenales (pasa placebo) | **Sí, en cambios quinquenales.** El fallo de FDA es del panel **en niveles anuales** con un único rezago, que ST y PN también rechazan. En cambios, PN reporta el adelanto (0,28, p = 0,08) y el sentido inverso: se narra como co-movimiento ("one transition with two faces"), nunca como efecto. |
| C5 | Magnitud del rezago | Plan v1 11 años; ST "≥ 22, KM 22 [20; 25]" y gradiente 36/25/14/16; FDA umbrales 11 robustos a censura pero no al umbral; INF: mediana no identificable | **Orden + cota inferior + año de inicio por ingreso.** Con la censura bien codificada (92 de 109 orígenes censurados por la izquierda), solo el orden y la cota están identificados; el año de inicio de la TFR sí lo está y responde "por ingreso". |
| C6 | Slide 2 build 1 | ST: connected scatter con 4 regiones. FDA: animación de registro | **Registro (FDA)**: es la frase del título hecha imagen, cuantifica (−80 %) y no se parece al "corredor TFR × LEx" de `ahzasasa`. El connected scatter va al apéndice. |
| C7 | Gemelos | Plan: EAU–Bielorrusia y Jordania–Bosnia. DEM: El Salvador con dos gemelos. MV: look-alikes como métrica | **Métrica de look-alikes + Colombia + EAU–Bielorrusia** (encargo: look-alikes como demostración central). El Salvador al notebook; Jordania–Bosnia fuera. |
| C8 | Dónde va la incertidumbre | ET: Slide 4 (build 2) con IP de la edad mediana de China. INF: Slide 4 build 4 y/o Slide 1 | **Slide 1, zoom al Golfo**, solo población (IP de edad mediana inválido): la ética se ve donde aparece el riesgo y la Slide 4 ya tiene 3 visuales. |
| C9 | Nombre del grupo 4 | MV: *Migration-boosted*. ET: *Migration-led*. Storyboard v1: variantes (i)/(ii) | **Migration-led** (neutral); variante (ii) "Sprinters" solo en la sensibilidad sin CNMR (MV). |
| C10 | "Late movers" | Plan v1 vs ET (*Recent movers*) | **Recent movers** (ET; el encargo pide la alternativa si existe). |
| C11 | Paleta del mapa de palancas | `config.R` v1 (verde / azul / bermellón / naranja) vs ET (azul / celeste / naranja / púrpura) vs VIZ (verde = natural, bermellón = migración) | **ET**, extendida a toda la Slide 1 y a fig05 para que cada color signifique una sola cosa en todo el vídeo. |
| C12 | Participación migratoria de ingreso alto | DEM: "about two-thirds" (64–71 %). INF: "about seven in ten" (70,7 %, BCa 56–114) | **"About seven in ten"** con FY2027 declarado (es nuestra clasificación) y la nota "64–78 % depending on classification vintage and period" en pantalla. |
| C13 | Tamaños de los grupos | MV 50/51/53/7 (k-means décadas) vs FDA 49/51/54/7 (FPCA) | Se reporta un rango (≈ 49–50 / 51 / 53–54 / 7); decide el notebook (k-means por décadas = método principal). |
| C14 | Volatilidad de las proyecciones | ST 33× / 13,5× / 20×; ET 24× / 5× / 25×; DEM 21×; plan "14–34×" | Una medida declarada en el notebook; en pantalla, la frase sin ratio ("contains no shocks"; 0 países pierden LEx en años proyectados). |
| C15 | % de PC1 | Plan 46; VIZ 64; MV 56,7; INF 46–77 según el conjunto | El % sale en gris con su rango; la cifra titular es estructural ("two real dimensions"). |
| C16 | P5: % que cambia > 20 puestos | Plan 24 (7 variantes); MV 19,9 (11 variantes) y MC 21,1 | MC declarado (Dirichlet(5) + inclusión): "one country in five". |
| C17 | Intervalos: iid vs bloques | INF: bootstrap de países BCa. SP: bloques de subregión (1,4–2,2× más anchos) | **Pantalla = bloques de subregión** (`"block bootstrap by subregion"`); notebook = ambos. Los valores puntuales no cambian. |
| C18 | Numeración de hipótesis | PN propone H15/H16; SP también llama H15 a la de Moran | IDs únicos en `hipotesis_preinscritas.md`: H15–H16 (PN), H24–H25 (SP). |
| C19 | Mapas | SP: `s2` + Robinson propio (sin `sf`). Encargo y VIZ: `sf` + Robinson | `sf` + Robinson (instalado y probado); la plantilla `s2` es el respaldo y aporta los ajustes de fronteras. |
| C20 | Inercia: 22 o 18 | DEM: "22 … pierden gente por emigración y aun así crecen" | Verificado por el integrador: 22 = NetMigrations ≤ 0 (18 < 0, 4 = 0). Se narra "growing from births" (válido para los 22) y se guarda la variante estricta. |

---

## 4. Verificaciones obligatorias antes de que una cifra pase al guion (QA-stats + notebook-R)

**4.1 Generales**
1. La cifra existe en `numbers.json`, con `method`, `n`, `universe`, `status` y (si es una estimación con incertidumbre) `ci_*` o `sens_*`; si hay intervalo en pantalla, `method` = `"block bootstrap by subregion"`, `wilson`, `km` o `un_pi`.
2. Se reproduce desde un `make notebook` en limpio con la misma `seed` y `B`.
3. Coincide con la ventana declarada (2023) y el universo dicho en voz (237 vs 161).
4. Ningún país nombrado contradice su tipo de palanca (2023) o su grupo.
5. Ninguna ventana de cálculo cruza 2023/24; las cifras proyectadas dicen "projected (UN medium)".
6. Ninguna aparece con "p =", "significant" o "range of uncertainty" junto a Low/High.

**4.2 Advertencias específicas de datos (de `02_contexto_historico.md` §0.3 y Anexo C, y de los memos)**

| # | Dato | Riesgo | Acción obligatoria |
|---|---|---|---|
| V1 | **República Centroafricana** LEx 14,7 (2009), 31,5 (2019), 40,3 (2021), 18,8 (2022) | Caídas de un año sin evento que las explique (ajuste de crisis de WPP) | No anotarla ni usarla como ejemplo; sensibilidad sin RCA en DE de LEx, curvas atípicas, calendario de choques y agregados de África Central / ingreso bajo; nota "possible artefact" en el notebook |
| V2 | **Hong Kong 1961–69** y **China 1964 / 1991** (`NetMigrations`) | Saltos espejo o aislados = ajustes censales | No anotarlos como migración real; comprobar su efecto en la winsorización (HKG: 8 país-años) y en las medias por década de HKG para el clustering |
| V3 | **Botsuana "−20 años"** vs **Esuatini** | WPP da −11,5 para Botsuana (63,7 → 52,2); la caída de ~18 años es de Esuatini (61,9 → 43,9) | Para el VIH usar Esuatini (o Lesoto/Zimbabue ≈ −16); Botsuana no es atípica en nivel (FDA) |
| V4 | **Nigeria** TFR 2023 = 4,48 (WPP) vs DHS 2018 = 5,3; último censo 2006 | Gran revisión; datos de calidad baja | Citar como "UN estimate"; si Nigeria aparece como bandera de *Recent movers* o en la recomendación ODS 3.2, pie `Nigeria: last census 2006` |
| V5 | **Cuba** población 2022–23: WPP 11,02 M vs ONEI 10,06 M | Discrepancia con la fuente nacional | Solo como ejemplo de incertidumbre en el notebook, citando ambas fuentes; no usar Cuba como ejemplo en el vídeo |
| V6 | Canadá 2023, EE. UU. 2023, Polonia 2004–07 | WPP difiere de StatCan, CBO, GUS | Idem: ejemplo de incertidumbre, no hallazgo |
| V7 | Ucrania y Siria 2023–2026 | Retornos proyectados (2/3 de refugiados) son supuestos de la ONU | Rotular "UN assumption"; nunca como evidencia |
| V8 | Líbano CNMR = 0 en 1975–78 | Ausencia de estimación en guerra | No interpretar como "sin emigración" |
| V9 | España TFR 2023 WPP 1,21 vs INE 1,12; Japón 1966 | WPP suaviza | Si se cita: "UN estimate" |
| V10 | India supera a China en 2022 (WPP2024) vs "abril 2023" (UNFPA, WPP2022) | Revisiones distintas | "around 2022–2023" |
| V11 | Golfo: revisión WPP2022 → 2024 (EAU +12 %, Kuwait +12 %, Qatar +9,7 %, Omán +8,7 %, Arabia Saudí −10 %); tasas fijadas por expertos desde 2030 | Componente más incierto | Nota en el zoom y tarjeta 2; la proyección del Golfo no se usa como hallazgo |
| V12 | Togo: *Interim Update* (19-ene-2026) | Nuestro archivo es el original (9,30 M en 2023) | Sensibilidad: ¿cambia algún conteo o cifra del guion? Registrar en `correcciones.md` |
| V13 | Inercia 22 vs 18 | 4 países con migración neta 0 (BRN, ATG, KNA, LCA) | La voz dice "growing from births"; `n_momentum_emig` = 18 guardado |
| V14 | Ingreso: FY2027 vs agregados ONU (mayo 2024) | Clasificaciones distintas (alto 1 393 vs 1 261 M) | Nunca validar contra los agregados de ingreso; etiqueta "today's income groups"; sensibilidad 64 % |
| V15 | Taiwán sin grupo de ingreso (21 áreas sin grupo; única ≥ 1 M) | Exclusión silenciosa | Listar los 21 en el notebook; n por ingreso = 160 |
| V16 | COVID: 161 / 168 (237) vs 118 / 119 (≥ 1 M) | Universo | Decir siempre el universo |
| V17 | Volatilidad proyectada | Distintas medidas dan 5×–34× | Una sola medida declarada; frase sin ratio en pantalla |
| V18 | Kosovo, Taiwán, Palestina, Hong Kong | Nombres oficiales | `Kosovo (under UNSC res. 1244)`, `China, Taiwan Province of China`, `State of Palestine`, `China, Hong Kong SAR` |
| V19 | Crimea y fronteras de Natural Earth | Vista "de facto" | Crimea → UKR; nota de no-aval de la ONU en todo mapa |
| V20 | Cifras de víctimas de eventos (Camboya, Ruanda, Haití…) | Rangos disputados | No dar cifras de víctimas en pantalla; solo fechas y nombre ONU del evento |
| V21 | Look-alikes de Colombia | Selección del país por el equipo | Tabla completa de todos los países publicada; línea de posicionalidad |
| V22 | Ejemplos de grupos (India en Fast; EE. UU., Rusia, Japón en Early) | Dependen de la corrida final | La voz se rellena desde `cluster_examples_*`; si cambia la composición, cambia la voz |

---

## 5. Comprobaciones hechas por el integrador (R, 2026-10-22, sobre `data/processed/paises.parquet`)

- 237 países y áreas; 161 ≥ 1 M. TFR < 2,1 en 2023: **130**; de ellos crecen **84**; con NatChange > 0 y crecen **66**; tipo C **18**; NatChange > 0 (crezcan o no) **79**.
- Tipos 2023 (B = NetMigrations ≤ 0): A 71 · B 94 · C 18 · D 35 · E 19 (≥ 1 M: 48 · 72 · 11 · 24 · 6). Bajo reemplazo: A 44 · B 22 · C 18 · D 33 · E 13.
- Inercia: 22 países, 2,20 mil M (IND, BRA, MEX, PHL, VNM, TUR, VEN, PRK…); estricta (NetMigrations < 0) 18, 2,2 mil M.
- Ejemplos por regla (3 más poblados ≥ 1 M): C = DEU, ESP, BEL · D = CHN, RUS, JPN · E = NPL, AZE, URY.
- Entorno: `av::av_encode_video()` y `gganimate::animate(renderer = av_renderer())` generan MP4; `rnaturalearth::ne_countries()` + `st_transform("+proj=robin")` funciona (242 polígonos); disponibles `survival`, `boot`, `mclust`, `sandwich`, `lmtest`, `clue`, `tweenr`, `ragg`, `colorspace`; **no** `fpc`, `gghighlight`, `colorblindr`; sin ffmpeg del sistema.
- Narración del storyboard v2: **654 palabras** (`wc -w` con los valores provisionales sustituidos; cada cifra = 1 palabra); grep de verbos prohibidos: solo las negaciones "not proof of cause" y "patterns, not causes" (excepción registrada).

---

## 6. Pendientes para otros agentes

- `prepare-data`: constantes, paletas y `nombrar_grupo()` v2 en `R/config.R` (PI §6); OtherVariants con lista blanca; `soberano` en `lookup_regiones.csv`.
- `repo-ops` / `notebook-R`: congelar `docs/hipotesis_preinscritas.md` antes de la corrida final, `make prereg`, publicar el hash; crear `docs/addendum_plan.md`, `docs/correcciones.md` (entradas: FY2026 → FY2027; 79 → 84; 11 años; H5; PC1 46 %; Nepal/Uruguay con 2021–23; "14–34×"; Togo; India Late → Fast).
- `notebook-R`: copiar del scratchpad (temporal) los bloques de los siete memos a `R/utils_*.R` antes de que se pierdan.
- Si llega un memo nuevo: añadir su tabla en §2, sus conflictos en §3 y no meter ninguna figura nueva en el vídeo sin retirar otra.
