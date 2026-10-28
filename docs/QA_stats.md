# QA-stats · Verificación independiente de `figures/numbers.json`

Agente **cierre-qa-stats** · informe del 2026-10-24 · cifras v1 congeladas el 2026-10-23 · verificación de los lotes 1–4 del 2026-10-23.
Archivos: `docs/qa/verificacion_lote_{1..4}.R` (verificadores), `docs/qa/verificacion_lote_{1..4}_resultados.csv`,
`docs/qa/consolidar_verificacion.R` → `docs/qa/verificacion_consolidada.csv`, `R/qa_verificacion.R`,
`R/05_numbers_json.R` §4.5, `docs/qa/tabla_qa_stats.py` (tabla de la sección 5).

## 1. Resultado en cinco líneas

- Se recalcularon con código independiente **210 cifras**: todas las claves que salen en pantalla, en la voz, en las referencias o en las figuras del vídeo. **Discrepancias: 0.**
- **209 de 210** quedan con `verified: true` (`verified_by` = "verificación independiente lote N", `verified_on` = 2026-10-23). **1 queda en `false`**: `are_revision_pct` (cifra externa; la comprobación fue solo parcial, sección 3.4).
- **12 definiciones eran ambiguas** (el valor se reproduce, pero solo con una de varias lecturas razonables). En 11 se reescribió `def` en el script que la calcula para que diga exactamente qué se hizo; la número 12 (`yrs_medage30_40_recent`) tiene un nombre de clave engañoso, pero su `def` ya era explícita. Por coherencia se aclararon otras 4 `def` que comparten el mismo cálculo (`silhouette`, `borderline_countries`, `q5_ratio_p90p10_peak` y `growth_2000_2023_by_group`), así que en total cambiaron 15 `def` y un `n` (`region_vote_accuracy`: 161 → 160). **Ningún valor cambió**: las 209 huellas coinciden después de volver a correr todo.
- En `numbers.json` hay 383 claves: 209 verificadas, 1 de pantalla sin verificar y 173 que solo usa el notebook. Esas 173 no se recalcularon y quedan en `false`. Cada clave sin verificar lleva el motivo en el campo nuevo `nota_qa`.
- *(2026-10-26: §10 registra la verificación humana de las cifras habladas y en pantalla; `numbers.json` pasa a 385 claves con 2 de metadatos, `repo` y `meta_human_check`, sin cambiar ningún valor ni `verified`.)*
- **Faltan 8 claves** que ningún análisis produjo (sección 6). Dos de ellas (`n_census_pre2009` y `repo`) están en el storyboard y en las diapositivas: **no pueden decirse ni teclearse hasta que existan** (sección 7).

## 2. Cómo se verificó

1. **Cuatro verificadores independientes**, uno por lote de unas 53 claves (`docs/qa/verificacion_lote_N.R`). Cada uno recalcula las cifras desde los CSV crudos de la ONU (`../WPP2024_Demographic_Indicators_Medium_csv.gz`, `OtherVariants`). Ninguno hace `source()` de `R/0*.R` ni lee `data/processed/*.parquet`. Solo pueden usar como insumos auxiliares la región SDG de `data/processed/lookup_regiones.csv`, el ingreso FY2027 de `data/raw/wb_api_income_2026-10-22.csv` y los puntos de Natural Earth para la matriz de vecinos. Todos fijan `set.seed(2026)` antes de cada bloque aleatorio.
2. **Consolidación** (`docs/qa/consolidar_verificacion.R`). Junta los cuatro resultados y fija, para cada clave, la **huella** de la cifra que se verificó: SHA-256 corto de `value`, `ci_*`, `sens_*`, `pi80_*`, `pi95_*` y `method`. La huella se toma de `figures/numbers.json` v1 (SHA-256 `d8631bf8…`, commit `87d0608`), que es el archivo que vieron los verificadores. Además anota la decisión de QA-stats para cada clave. Resultado: `docs/qa/verificacion_consolidada.csv`.
3. **Marcado reproducible** (`R/05_numbers_json.R` §4.5 → `R/qa_verificacion.R`). Cada vez que se ensambla `numbers.json`, una clave recibe `verified: true` solo si su cifra actual tiene **la misma huella** que la cifra verificada. Si una corrida futura cambia un número, la clave vuelve sola a `false` y `nota_qa` lo explica: un ✔ viejo nunca pasa a un número nuevo (ASA B.4 y C.2). Si solo se aclaran `def`, `filter`, `n` o `say`, la huella no cambia, porque el número verificado es el mismo.
4. **Esquema.** Se añadió el campo `nota_qa` al final de cada clave (`CAMPOS_NUMBERS` en `R/incertidumbre.R`; vale `null` si no hay nada que advertir). Lo rellena solo QA-stats. `registrar_cifra()` no lo acepta como argumento, así que los análisis no pueden escribirlo. *Pendiente para el dueño del plan:* añadir `nota_qa` a la tabla de campos de `docs/00_plan_implementacion.md` §4.
5. **Corrida en limpio después de las aclaraciones.** Se volvieron a correr `Rscript R/02_q1_palancas.R`, `R/03_q2_un_numero.R`, `R/04_q3_caminos.R` y `R/05_numbers_json.R`. Después se reconstruyó el notebook (`notebook/construir_notebook.py`), se ejecutó entero (`jupyter nbconvert --execute`) y se exportó el HTML (`notebook/exportar_html.py`). Los resultados están en la sección 8.

## 3. Decisiones caso por caso

### 3.1 Discrepancias

Ninguna. Las 210 cifras coinciden al redondeo de pantalla. Las únicas diferencias están en los decimales de cifras aleatorias, dentro de su tolerancia de Monte Carlo (`jaccard_max` 0,949 frente a 0,942; `share_rank_mc20` 21,7 % frente a 21,7–23,6 % según la semilla), o en los bordes de algunos IC por bloques (`recov_pc1`, `pc1_var`, `panel_ratio_between_within`). En todos los casos el valor puntual está dentro del intervalo publicado.

### 3.2 Definiciones ambiguas → `def` aclarada en el script (el valor no cambia)

| Clave | Qué no decía la definición | Qué dice ahora (`def`) | Script |
|---|---|---|---|
| `cluster_sizes` (y `silhouette`, vía `NOTA_RASGOS`) | Cómo se estandarizan los 32 rasgos. Con z sobre las medias por década salen 51/52/51/7 y con z por columna, 48/55/51/7 | z con la media y la DE de las 161 × 74 celdas país-año **y después** medias por década; k-means nstart 50, semilla 2026 | `R/04_q3_caminos.R` §16.1 |
| `medage_2050_by_group` | Depende de esa misma partición (con otra estandarización: Fast 37,1, Recent 24,4) | Grupos = partición principal; remite a `cluster_sizes` | `R/04` §16.5 |
| `fig04_highlight_iso3` | n = 36 es par, así que la mediana (18,66) cae entre COL (18,58) y ZAF (18,75) | "Mediano" = país más cercano a la mediana; la `def` da n y la mediana | `R/02_q1_palancas.R` §6.4 |
| `q5_ratio_p90p10_peak_year` (y `_peak`) | Qué estimador de cuantil se usa: con type 6 el pico pasa de 2006 a 1999 | P90 y P10 con el cuantil por defecto de R (type 7) | `R/04` §16.3 |
| `growth_2024_2050_by_group` (y `growth_2000_2023_by_group`) | Qué población es la base: con la del 1 de enero de 2024, Recent 70,9 / 68,1 y Migration-led 37,5 / 41,2 | Base = población al 1 de julio de 2024; total = Σ PopChange de los 27 valores anuales | `R/04` §16.5 |
| `momentum_years_range` | El peso y el método del cuantil ponderado (interpolado: 34,0–38,5) | Peso = población al 1 de julio de 2023; primer valor con peso acumulado ≥ p, sin interpolar | `R/04` §16.7 |
| `share_rank_mc20` | Probabilidad de incluir el crecimiento y cómo trata la media geométrica las z y los ceros | Crecimiento con probabilidad 0,5; normalización y agregación equiprobables; media geométrica sobre min–max (también si sale z) o rangos, con piso 0,01; P5–P95 (type 7); semilla | `R/03_q2_un_numero.R` §8.2 |
| `lisa_cnmr_hh_fdr` | La convención del p-valor: con p bilateral 2·min salen 6 (KWT cae) | p de permutación condicional de un lado (*folded*, como GeoDa), 999 permutaciones, BH al 5 % sobre 161 pruebas | `R/02` §4.2 |
| `r2_tfr_chg27_observed` | Qué población entra en el cambio: con la del 1 de enero, mediana 0,37 y máximo 0,51 | Poblaciones al 1 de julio, la misma convención del comparador 2023→2050 (0,88) | `R/03` §2.8 |
| `region_vote_accuracy` | El denominador: 160, no 161 (sobre 161 daría 0,770) | Papúa Nueva Guinea es el único país ≥ 1 M de su región SDG y no tiene voto; `n` = 160 | `R/04` §16.2 |
| `yrs_medage30_40_cohort_1990_2023` | 39 países cruzan los 30 en 1990–2023, pero la mediana usa 35 | Solo entran los que llegan a 40 antes de 2100 (ARE, BHR, KWT y QAT no llegan); KM con censura: 25 | `R/04` §16.4 |
| `borderline_countries` | Era aleatorio y no documentaba el `nstart` de las réplicas | 500 submuestras del 80 % sin reemplazo, nstart 20, emparejamiento húngaro, semilla 2026 | `R/04` §16.1 |
| `yrs_medage30_40_recent` | **El nombre de la clave** dice *recent*, pero el valor es de **Fast movers** | Sin cambio: la `def` ya dice "Fast movers" y el storyboard y las diapositivas la usan así. Se renombrará solo si lo pide el dueño del storyboard | — (`nota_qa`) |

### 3.3 Verificadas, pero con una regla de uso para el guion

| Clave | Regla |
|---|---|
| `jaccard_min` | El segundo decimal es ruido de Monte Carlo (0,77–0,83 con las semillas 2027–2045). En pantalla, **"≈ 0.8" o "above 0.75"**, nunca "0.78" como cifra exacta |
| `panel_ratio_between_within` | El valor puntual (2,54) es correcto, pero su IC por bloques es inestable (el del verificador es [−7,6; 14,3]; el publicado, [−9,2; 18,4]). **Nunca se muestra el intervalo**; se usa la `say` |
| `share_rank_mc20` | Es aleatoria: según la implementación y la semilla da 21,7–23,6 %. "One in five" es robusto; el porcentaje exacto, no |
| `q5_ratio_p90p10_peak_year` | El año del pico depende del estimador de cuantil (2006 con type 7, 1999 con type 6): mejor "in the 2000s" que un año exacto |
| `yrs_medage30_40_recent` | Es de **Fast movers**. Nunca se presenta como Recent movers (su mediana KM sería 47 años) |
| `r_tfr_decades_min` | El mínimo (0,948) es de la esperanza de vida, no de la TFR (0,951), aunque la clave diga *tfr* |
| `rec_rows` | Los números están verificados. Los textos de las celdas (mandatos, agencias, verbos) no son cifras y los revisa QA-ethics |

### 3.4 No verificada

- **`are_revision_pct`** (+12 %, revisión de la población de los EAU entre WPP2022 y WPP2024). Aparece en la diapositiva 1 (build 5) y en la tarjeta de ética 2. Con los archivos de WPP2024 del repositorio no se puede calcular. El verificador solo pudo comprobarla en parte: usó el valor de WPP2022 para 2022 que cita una fuente secundaria (9 441 129) y un valor **recordado y no verificado** para 2023 (≈ 9 516 871), y obtuvo un +11,8 %. Marcarla como verificada exageraría la certeza (ASA C.2). **Acción:** una persona del equipo debe cotejarla con el archivo oficial de WPP2022 (EAU, 2023) o citar la cifra de la metodología de WPP2024 con su referencia. Después se vuelve a correr `docs/qa/consolidar_verificacion.R` (con `verificada = TRUE` en su fila) y `R/05`.

## 4. Otras observaciones de los verificadores (no cambian ninguna cifra)

- **Plan §7.7**: el texto dice "105/108" para mortalidad primero. La cifra vigente y verificada es **106/109** (`n_mort_first_onset`, `share_mort_first`, n = 109). El dueño del plan debe actualizar el texto.
- **`hyp_file_date`**: verificada (commit `2a0ab7b`, archivo sin cambios desde entonces), pero **no existe `docs/hipotesis_preinscritas.sha256`**: el `make prereg` que exige el propio archivo sigue pendiente (repo-ops / notebook-R).
- **`share_mig_high_2000_2023`**: GGY y JEY quedan como *Not classified*, porque el Banco Mundial clasifica a las Islas del Canal como CHI. Ya está documentado en el notebook; no cambia la cifra.
- **`meta_income_classification`** y **`meta_wpp_version`**: los datos coinciden. La etiqueta FY2027 y la fecha de publicación de julio de 2024 salen del nombre de los archivos y de `data/raw/README.md`; no se pueden comprobar desde el CSV.
- **`cluster_medoids`**: el medoide es el país más cercano a la mediana del grupo, coordenada a coordenada (así lo dice la `def`). Un medoide tipo PAM daría MDG en vez de CMR para Recent movers.
- **`twins`**: detalle cosmético en la cadena de texto del lote (la TFR de Esuatini salía con 4 decimales). Los valores coinciden.

## 5. Tabla clave por clave (210 cifras)

"Coincide" compara el valor de `numbers.json` con el recalculado; "def ambigua" quiere decir que el valor solo se reproduce con una de varias lecturas de la definición (sección 3.2). La columna `verified` sale del `numbers.json` vigente. La tabla la escribe `docs/qa/tabla_qa_stats.py`; no se teclea a mano.

<!-- TABLA-QA-INICIO -->
| # | clave | lote | valor (numbers.json) | valor independiente | coincide | verified | acción |
|---|---|---|---|---|---|---|---|
| 1 | `n_countries` | 1 | 237 countries and areas | 237 | sí | ✔ | Ninguna |
| 2 | `n_territories` | 1 | 42 territories and areas | 42 | sí | ✔ | Ninguna |
| 3 | `n_natneg_1990` | 1 | 8 countries and areas | 8 | sí | ✔ | Ninguna |
| 4 | `share_pop_natneg_2023` | 1 | 28 % | 28.05 | sí | ✔ | Ninguna |
| 5 | `n_shrinking_2100` | 1 | 162 countries and areas | 162 | sí | ✔ | Ninguna |
| 6 | `world_peak_year` | 1 | 2084 year | 2084 | sí | ✔ | Ninguna |
| 7 | `n_sdg32_above_2030` | 1 | 58 countries and areas | 58 | sí | ✔ | Ninguna |
| 8 | `n_type_C` | 1 | 18 countries and areas | 18 | sí | ✔ | Ninguna |
| 9 | `n_grow_only_migration_sens_range` | 1 | 15–25 | 15–25 | sí | ✔ | Ninguna |
| 10 | `examples_type_A_iso3` | 1 | USA, EGY, IRN | USA, EGY, IRN | sí | ✔ | Ninguna |
| 11 | `examples_type_D` | 1 | China, Russian Federation, Japan | China, Russian Federation, Japan | sí | ✔ | Ninguna |
| 12 | `share_mig_high_2000_2023` | 1 | 70.7 % · CI [55.5; 133.3] | 70.7% · IC [55.5; 133.3] | sí | ✔ | Ninguna |
| 13 | `share_mig_low_2000_2023` | 1 | -3.7 % · CI [-9.3; -1.6] | -3.7% · IC [-9.3; -1.6] | sí | ✔ | Ninguna |
| 14 | `pop_are_2050` | 1 | 15.4 million | 15.4 million · UN PI95 8.9–33.3 | sí | ✔ | Ninguna |
| 15 | `pop_chn_2050` | 1 | 1.26 billion | 1.26 billion · UN PI95 1.16–1.35 | sí | ✔ | Ninguna |
| 16 | `n_dir_uncertain_2050` | 1 | 77 countries | 77 | sí | ✔ | Ninguna |
| 17 | `are_revision_pct` | 1 | 12 % | ~11.8% (externo, no calculable con WPP2024) | sí (parcial) | **✘** | NO se marca: cifra externa; la comprobación usó un valor de WPP2022 recordado (no verificado). Pendiente: cotejar con el archivo oficial WPP2022 (EAU, 2023) |
| 18 | `n_pairs_twins` | 1 | 12,880 pairs | 12880 | sí | ✔ | Ninguna |
| 19 | `twin_tfr_are` | 1 | 1.20 children per woman | 1.20 | sí | ✔ | Ninguna |
| 20 | `cdr_prt` | 1 | 11.1 per 1,000 | 11.1 per 1,000 | sí | ✔ | Ninguna |
| 21 | `sd_le65_2023` | 1 | 2.85 years · CI [2.41; 3.15] | 2.846 years · IC [2.41; 3.15] | sí | ✔ | Ninguna |
| 22 | `cv_le65_2023` | 1 | 17.2 % · CI [14.2; 19.2] | 17.19% · IC [14.2; 19.2] | sí | ✔ | Ninguna |
| 23 | `sd_medage_2023` | 1 | 9.7 years · CI [7.8; 10.9] | 9.738 years · IC [7.8; 10.9] | sí | ✔ | Ninguna |
| 24 | `rho_cdr_lex_1950` | 1 | -0.97 rho · CI [-0.98; -0.94] | -0.974 · IC [-0.981; -0.939] | sí | ✔ | Ninguna |
| 25 | `r2_tfr_chg2050` | 1 | 0.88 R2 · CI [0.75; 0.94] | 0.881 · IC [0.75; 0.94] | sí | ✔ | Ninguna |
| 26 | `r2_tfr_medage_cv` | 1 | 0.77 R2 | 0.7656 | sí | ✔ | Ninguna |
| 27 | `r2_tfr_cnmr_cv` | 1 | -0.03 R2 | -0.0268 | sí | ✔ | Ninguna |
| 28 | `pc2_var` | 1 | 17.9 % · CI [11.8; 23.6] | 17.88% · IC [11.8; 23.6] | sí | ✔ | Ninguna |
| 29 | `recov_pc1` | 1 | 0.57 share · CI [0.51; 0.63] | 0.567 · IC [0.52; 0.63] | sí | ✔ | Ninguna (diferencia solo en el límite inferior del IC por detalles del remuestreo) |
| 30 | `lookalikes_col_12` | 1 | Iran (Islamic Republic of), Peru, Ecuador, Panama, Tunisia | Iran (Islamic Republic of), Peru, Ecuador, Panama, Tunisia | sí | ✔ | Ninguna |
| 31 | `knn_chance` | 1 | 3 % | 3.125 | sí | ✔ | Ninguna |
| 32 | `q5_ratio_p90p10_peak_year` | 1 | 2006 year | 2006 | sí · def ambigua | ✔ | def aclarada en R/04 (cuantil type 7). Recomendación al guion: no presentar el año exacto como preciso |
| 33 | `r_tfr_decades_min` | 1 | 0.95 Pearson r | 0.9481 | sí | ✔ | Ninguna; nota_qa sobre el nombre de la clave |
| 34 | `q5_drop_at_tfr_onset` | 1 | 50 % · CI [44; 61] | 49.89% · IC [43.8; 60.7] | sí | ✔ | Ninguna |
| 35 | `yr_fert_onset_lowmid` | 1 | 1984 year · CI [1982; 1987] | 1984 · IC [1982; 1987] | sí | ✔ | Ninguna |
| 36 | `n_cens_der` | 1 | 26 countries | 26 | sí | ✔ | Ninguna |
| 37 | `dur53_egy` | 1 | 33 years | 32.748 years | sí | ✔ | Ninguna |
| 38 | `fig04_highlight_iso3` | 1 | CHN, COL, EGY | CHN, COL, EGY | sí · def ambigua | ✔ | def aclarada en R/02: 'mediano' = país con la duración más cercana a la mediana (n = 36 es par) |
| 39 | `panel_eurna_halfq5` | 1 | 0.39 children per woman | 0.3910 | sí | ✔ | Ninguna |
| 40 | `panel_upmid_halfq5` | 1 | 0.11 children per woman · CI [-0.53; 0.63] | 0.1103 · IC [-0.53; 0.63] | sí | ✔ | Ninguna |
| 41 | `panel_placebo_hi` | 1 | 0.26 children per woman | 0.2554 | sí | ✔ | Ninguna |
| 42 | `cluster_sizes` | 1 | Early movers: 50; Fast movers: 51; Recent movers: 53; Migration-led: 7 | Early movers: 50; Fast movers: 51; Recent movers: 53; Migration-led: 7 | sí · def ambigua | ✔ | def aclarada en R/04: z sobre todas las celdas país-año 1950-2023 y después medias por década; k-means nstart 50, semilla 2026 |
| 43 | `cluster_examples_fast` | 1 | India, China, Indonesia | India, China, Indonesia | sí | ✔ | Ninguna |
| 44 | `cluster_medoids` | 1 | Early movers: Slovenia; Fast movers: Ecuador; Recent movers: Cameroon; Migration-led: Saudi Arabia | Early movers: Slovenia; Fast movers: Ecuador; Recent movers: Cameroon; Migration-led: Saudi Arabia | sí | ✔ | Ninguna (la def ya dice 'mediana coordenada a coordenada') |
| 45 | `migration_led_members` | 1 | Saudi Arabia, Jordan, United Arab Emirates, Kuwait, Qatar, Bahrain, Djibouti | Saudi Arabia, Jordan, United Arab Emirates, Kuwait, Qatar, Bahrain, Djibouti | sí | ✔ | Ninguna |
| 46 | `medage_2050_by_group` | 1 | Early movers: 47.8; Fast movers: 38.2; Recent movers: 24.6; Migration-led: 32.3 | Early movers: 47.8; Fast movers: 38.2; Recent movers: 24.6; Migration-led: 32.3 | sí · def ambigua | ✔ | def aclarada en R/04: grupos = partición principal (misma estandarización que cluster_sizes) |
| 47 | `jaccard_min` | 1 | 0.78 Jaccard | 0.7827 | sí | ✔ | Recomendación al guion y a las diapositivas: '≈ 0.8' o 'above 0.75'; el segundo decimal es ruido de Monte Carlo |
| 48 | `moran_tfr_2023` | 1 | 0.74 Moran's I | 0.7350 | sí | ✔ | Ninguna |
| 49 | `knn_vote_accuracy` | 1 | 0.74 share | 0.7391 | sí | ✔ | Ninguna |
| 50 | `yrs_medage30_40_kor` | 1 | 17 years | 17 years | sí | ✔ | Ninguna |
| 51 | `yrs_medage30_40_cohort_pre1990` | 1 | 40.5 years · CI [35.0; 46.0] | 40.5 years · IC [35.0; 46.0] | sí | ✔ | Ninguna |
| 52 | `hyp_file_sha256_short` | 1 | 83f98f6e1a3d | 83f98f6e1a3d | sí | ✔ | Ninguna |
| 53 | `team_name` | 1 | UNALSta-R | UNALSta-R | sí | ✔ | Ninguna |
| 54 | `n_countries_1m` | 2 | 161 countries | 161 | sí | ✔ | Ninguna |
| 55 | `n_ge1m` | 2 | 161 countries | 161 | sí | ✔ | Ninguna |
| 56 | `n_sovereign` | 2 | 195 states | 195 | sí | ✔ | Ninguna |
| 57 | `cdr_tcd` | 2 | 11.0 per 1,000 | 11.032 | sí | ✔ | Ninguna |
| 58 | `cnmr_are_2023` | 2 | 28.2 per 1,000 | 28.19 | sí | ✔ | Ninguna |
| 59 | `tfr_are_2023` | 2 | 1.20 children per woman | 1.2 | sí | ✔ | Ninguna |
| 60 | `twin_tfr_blr` | 2 | 1.21 children per woman | 1.2076 | sí | ✔ | Ninguna |
| 61 | `medage_chn_2050` | 2 | 52.1 years | 52.1406 | sí | ✔ | Ninguna |
| 62 | `world_pop_1950_bn` | 2 | 2.5 billion | 2.4931 | sí | ✔ | Ninguna |
| 63 | `n_type_A` | 2 | 71 countries and areas | 71 | sí | ✔ | Ninguna |
| 64 | `n_type_D` | 2 | 35 countries and areas | 35 | sí | ✔ | Ninguna |
| 65 | `examples_type_B_iso3` | 2 | IND, IDN, PAK | IND, IDN, PAK | sí | ✔ | Ninguna |
| 66 | `examples_type_D_iso3` | 2 | CHN, RUS, JPN | CHN, RUS, JPN | sí | ✔ | Ninguna |
| 67 | `n_below_repl_growing_2023` | 2 | 84 countries and areas | 84 | sí | ✔ | Ninguna |
| 68 | `n_natneg_2023` | 2 | 53 countries and areas | 53 | sí | ✔ | Ninguna |
| 69 | `n_sdg32_on_pace` | 2 | 8 countries and areas | 8 | sí | ✔ | Ninguna |
| 70 | `share_mig_high_2010_2023` | 2 | 77.5 % · CI [57.5; 162.5] | 77.54 | sí | ✔ | Ninguna |
| 71 | `share_mig_lowmid_2000_2023` | 2 | -8.6 % · CI [-12.1; -2.8] | -8.58 | sí | ✔ | Ninguna |
| 72 | `pop_are_2050_pi95_high` | 2 | 33.3 million | 33.264 | sí | ✔ | Ninguna |
| 73 | `pop_chn_2050_pi95_high` | 2 | 1.35 billion | 1.3536 | sí | ✔ | Ninguna |
| 74 | `sd_lex_1950` | 2 | 12.2 years · CI [10.1; 13.8] | 12.244 | sí | ✔ | Ninguna |
| 75 | `cv_lex_1950` | 2 | 25.6 % · CI [21.3; 28.8] | 25.594 | sí | ✔ | Ninguna |
| 76 | `q5_ratio_p90p10_1950` | 2 | 6 ratio · CI [3; 10] | 6.19 | sí | ✔ | Ninguna |
| 77 | `sd_medage_peak_year_proj` | 2 | 2040 year | 2040 | sí | ✔ | Ninguna |
| 78 | `rho_cdr_lex_2023` | 2 | 0.07 rho · CI [-0.31; 0.32] | 0.0672 | sí | ✔ | Ninguna |
| 79 | `r2_tfr_growth` | 2 | 0.59 R2 · CI [0.31; 0.80] | 0.5899 | sí | ✔ | Ninguna |
| 80 | `r2_all` | 2 | 0.99 R2 | 0.9859 | sí | ✔ | Ninguna |
| 81 | `r2_tfr_chg2050_cv` | 2 | 0.88 R2 | 0.8784 | sí | ✔ | Ninguna |
| 82 | `r_cnmr_decades_max` | 2 | 0.69 Pearson r | 0.6916 | sí | ✔ | Ninguna |
| 83 | `n_pcs_70` | 2 | 2 components | 2 | sí | ✔ | Ninguna |
| 84 | `r_tfr_pc1` | 2 | -0.94 r · CI [-0.96; -0.90] | -0.9448 | sí | ✔ | Ninguna |
| 85 | `recov_pc12` | 2 | 0.75 share · CI [0.72; 0.77] | 0.7456 | sí | ✔ | Ninguna |
| 86 | `knn_pc1` | 2 | 20 % · CI [17; 24] | 20.373 | sí | ✔ | Ninguna |
| 87 | `lookalikes_col_12_iso` | 2 | IRN, PER, ECU, PAN, TUN | IRN, PER, ECU, PAN, TUN | sí | ✔ | Ninguna |
| 88 | `pc2_var_no_gulf` | 2 | 13.3 % | 13.304 | sí | ✔ | Ninguna |
| 89 | `share_rank_mc20` | 2 | 22 % · CI [16; 29] | 23.6 | sí · def ambigua | ✔ | def aclarada en R/03: crecimiento incluido con probabilidad 0,5; media geométrica sobre min-max (o rangos) con piso 0,01; con z se pasa a min-max; intervalo P5-P95 |
| 90 | `cluster_names` | 2 | Early movers, Fast movers, Recent movers, Migration-led | Early movers, Fast movers, Recent movers, Migration-led | sí | ✔ | Ninguna |
| 91 | `cluster_examples_iso3` | 2 | Early movers: USA, RUS, JPN; Fast movers: IND, CHN, IDN; Recent movers: PAK, NGA, ETH; Migration-led: SAU, JOR, ARE | Early movers: USA, RUS, JPN; Fast movers: IND, CHN, IDN; Recent movers: PAK, NGA, ETH; Migration-led: SAU, JOR, ARE | sí | ✔ | Ninguna |
| 92 | `india_group` | 2 | Fast movers | Fast movers | sí | ✔ | Ninguna |
| 93 | `n_gulf_migration_led` | 2 | 5 countries | 5 | sí | ✔ | Ninguna |
| 94 | `ari_fpca_decadas` | 2 | 0.96 ARI | 0.9629 | sí | ✔ | Ninguna |
| 95 | `join_same_road` | 2 | 0.67 share | 0.6671 | sí | ✔ | Ninguna |
| 96 | `growth_2024_2050_by_group` | 2 | <table, 4 rows> | Early movers: natural_pct=-7.0, migration_pct=5.6, total_pct=-1.4, natural_bn=-0.102, migration_bn=0.081 \|\| Fast movers: natural_pct=8.9,… | sí · def ambigua | ✔ | def aclarada en R/04: base = población al 1 de julio de 2024; total = Σ PopChange 2024-2050 (27 valores anuales) |
| 97 | `yrs_medage30_40_early` | 2 | 36.5 years · CI [29.0; 42.5] | 36.5 | sí | ✔ | Ninguna |
| 98 | `yrs_medage30_40_recent` | 2 | 32 years · CI [27; 37] | 32 | sí · def ambigua | ✔ | Sin cambio de valor ni de nombre (lo usan storyboard y diapositivas, siempre como Fast movers); nota_qa advierte del nombre |
| 99 | `dur53_fastest_ge10m` | 2 | CHN | CHN | sí | ✔ | Ninguna |
| 100 | `n_cens_der_ssa` | 2 | 23 countries | 23 | sí | ✔ | Ninguna |
| 101 | `lag_onset_lower_bound` | 2 | 22 years · CI [16; 28] | 22 | sí | ✔ | Ninguna; aviso al dueño del plan: §7.7 dice 105/108 y la cifra vigente es 106/109 |
| 102 | `yr_fert_onset_upmid` | 2 | 1970 year · CI [1968; 1975] | 1970 | sí | ✔ | Ninguna |
| 103 | `momentum_years_range` | 2 | 34–38 | 34–38 | sí · def ambigua | ✔ | def aclarada en R/04: peso = población al 1 de julio de 2023; cuantil ponderado = primer valor con peso acumulado ≥ p (sin interpolar) |
| 104 | `panel_within_halfq5` | 2 | -0.41 children per woman · CI [-0.77; 0.05] | -0.414 | sí | ✔ | Ninguna |
| 105 | `panel_high_halfq5` | 2 | -0.28 children per woman · CI [-1.26; 0.41] | -0.2768 | sí | ✔ | Ninguna |
| 106 | `panel_placebo_lo` | 2 | -0.25 children per woman | -0.2488 | sí | ✔ | Ninguna |
| 107 | `n_type_AB` | 3 | 165 countries and areas | 165 | sí | ✔ | Ninguna |
| 108 | `n_type_E` | 3 | 19 countries and areas | 19 | sí | ✔ | Ninguna |
| 109 | `n_grow_only_migration_2023` | 3 | 18 countries and areas | 18 | sí | ✔ | Ninguna |
| 110 | `n_shrinking_2023` | 3 | 54 countries and areas | 54 | sí | ✔ | Ninguna |
| 111 | `n_below_repl_natural_growth_2023` | 3 | 66 countries and areas | 66 | sí | ✔ | Ninguna |
| 112 | `n_momentum_countries` | 3 | 22 countries and areas | 22 | sí | ✔ | Ninguna |
| 113 | `n_natneg_2050` | 3 | 106 countries and areas | 106 | sí | ✔ | Ninguna |
| 114 | `n_ssa` | 3 | 51 countries and areas | 51 | sí | ✔ | Ninguna |
| 115 | `examples_type_C` | 3 | Germany, Spain, Belgium | Germany, Spain, Belgium | sí | ✔ | Ninguna |
| 116 | `cover_flags` | 3 | DE, ES, BE | DE, ES, BE | sí | ✔ | Ninguna |
| 117 | `examples_type_E` | 3 | Nepal, Azerbaijan, Uruguay | Nepal, Azerbaijan, Uruguay | sí | ✔ | Ninguna |
| 118 | `world_pop_2023_bn` | 3 | 8.1 billion | 8.0917 (suma 237: 8.0917) | sí | ✔ | Ninguna |
| 119 | `growth_are_2023` | 3 | 3.70 % per year | 3.704 | sí | ✔ | Ninguna |
| 120 | `twin_growth_are` | 3 | +3.70 % | 3.704 | sí | ✔ | Ninguna |
| 121 | `lex_gap_prt_tcd` | 3 | 27 years | 27.2907 | sí | ✔ | Ninguna |
| 122 | `yrs_medage30_40_chn` | 3 | 23 years | 23 (2002 -> 2025) | sí | ✔ | Ninguna |
| 123 | `china_share_natchange_upmid` | 3 | 30 % | 29.55 | sí | ✔ | Ninguna |
| 124 | `india_share_natchange_lowmid` | 3 | 40 % | 40.17 | sí | ✔ | Ninguna |
| 125 | `share_mig_upmid_2000_2023` | 3 | -4.6 % · CI [-14.9; 0.5] | -4.61% · IC [-14.2; 0.6] (B=2000, 18 subregiones) | sí | ✔ | Ninguna |
| 126 | `share_mig_high_sens_range` | 3 | 64–78 | 64–78% (FY2027 00-23 70.7; FY2027 10-23 77.5; ONU 00-23 64.0; ONU 10-23 72.8) | sí | ✔ | Ninguna |
| 127 | `pop_are_2050_pi95_low` | 3 | 8.9 million | 8.8863 M (U95 33.3 M) | sí | ✔ | Ninguna |
| 128 | `pop_chn_2050_pi95_low` | 3 | 1.16 billion | 1.1586 bn (U95 1.35 bn) | sí | ✔ | Ninguna |
| 129 | `sd_lex_2023` | 3 | 7.4 years · CI [5.6; 8.3] | 7.422 · IC [5.60; 8.31] | sí | ✔ | Ninguna |
| 130 | `cv_lex_2023` | 3 | 10.2 % · CI [7.4; 11.6] | 10.153% · IC [7.44; 11.63] | sí | ✔ | Ninguna |
| 131 | `q5_ratio_p90p10_2023` | 3 | 20 ratio · CI [11; 28] | 19.877 · IC [11.1; 28.6] | sí | ✔ | Ninguna |
| 132 | `rho_cdr_medage_2023` | 3 | 0.46 rho · CI [0.05; 0.73] | 0.4575 · IC [0.02; 0.71] | sí | ✔ | Ninguna |
| 133 | `r2_tfr_growth_cv` | 3 | 0.58 R2 | 0.5813 (rango 20 rep. 0.576-0.589) | sí | ✔ | Ninguna |
| 134 | `twins` | 3 | <table, 5 rows> | 1. United Arab Emirates–Belarus (TFR 1.2 vs 1.208; growth 3.704 vs -0.653 %) \|\| 2. United Arab Emirates–Japan (TFR 1.2 vs 1.208; growth 3… | sí | ✔ | Ninguna (solo cosmético: en la cadena del lote la TFR de Esuatini salía con 4 decimales) |
| 135 | `lookalikes_col_tfr` | 3 | France, Australia, Türkiye, United States of America, New Zealand | France, Australia, Türkiye, United States of America, New Zealand | sí | ✔ | Ninguna |
| 136 | `r_cnmr_decades_min` | 3 | 0.32 Pearson r | 0.3169 (1950->1960 0.68; 1960->1970 0.66; 1970->1980 0.60; 1980->1990 0.32; 1990->2000 0.47; 2000->2010 0.69) | sí | ✔ | Ninguna |
| 137 | `r2_tfr_chg27_observed` | 3 | min: 0.1342; median: 0.3959; max: 0.4996 | min 0.134 (1954); mediana 0.396; max 0.500 (1979) [1 enero: 0.134 / 0.373 / 0.506] | sí · def ambigua | ✔ | def aclarada en R/03: poblaciones al 1 de julio (la misma convención del comparador 2023→2050) |
| 138 | `knn_pc12` | 3 | 43 % · CI [40; 46] | 43.230% · IC [40.0; 46.1] | sí | ✔ | Ninguna |
| 139 | `recov_tfr` | 3 | 0.51 share · CI [0.43; 0.57] | 0.5086 · IC [0.44; 0.57] | sí | ✔ | Ninguna |
| 140 | `r_tfr_pc2` | 3 | 0.03 r · CI [-0.08; 0.17] | 0.0335 · IC [-0.06; 0.17] | sí | ✔ | Ninguna |
| 141 | `silhouette` | 3 | 0.37 silhouette | 0.3720 | sí | ✔ | Ninguna |
| 142 | `cluster_pop_bn` | 3 | Early movers: 1.443; Fast movers: 4.899; Recent movers: 1.666; Migration-led: 0.066 | Early movers 1.443; Fast movers 4.899; Migration-led 0.066; Recent movers 1.666 | sí | ✔ | Ninguna |
| 143 | `cluster_examples_migration` | 3 | Saudi Arabia, Jordan, United Arab Emirates | Saudi Arabia, Jordan, United Arab Emirates | sí | ✔ | Ninguna |
| 144 | `ari_tray_niveles` | 3 | 0.59 ARI | 0.5936 | sí | ✔ | Ninguna |
| 145 | `share_between_groups` | 3 | 42 % | 42.24% (68 de 161) | sí | ✔ | Ninguna |
| 146 | `r2_groups_axis1` | 3 | 0.90 R2 | 0.8981 (eje 1 = 67.2% de la varianza) | sí | ✔ | Ninguna |
| 147 | `moran_cnmr_2023` | 3 | 0.11 Moran's I | 0.1143 (p perm = 0.008; nulo 95% [-0.09; 0.09]) | sí | ✔ | Ninguna |
| 148 | `join_same_road_null` | 3 | 0.30 share | 0.3029 (observado 0.6671; banda 95% 0.265-0.345) | sí | ✔ | Ninguna |
| 149 | `yrs_medage30_40_fast_started` | 3 | 24 years · CI [21; 26] | 23.5 · IC [21.0; 26.0] (n = 20, eventos = 20) | sí | ✔ | Ninguna |
| 150 | `n_cens_izq` | 3 | 45 countries | 45 | sí | ✔ | Ninguna |
| 151 | `n_cruce_tfr4_obs` | 3 | 90 countries | 90 | sí | ✔ | Ninguna |
| 152 | `pct_var_fase` | 3 | 80 % · CI [69; 85] | 79.826% (varianza 0.920 -> 0.186; n = 57) · IC [69.8; 85.4] | sí | ✔ | Ninguna |
| 153 | `dur53_slowest_ge10m` | 3 | EGY | EGY | sí | ✔ | Ninguna |
| 154 | `n_q5_falling_1950` | 3 | 92 countries | 92 de 109 | sí | ✔ | Ninguna |
| 155 | `panel_ratio_between_within` | 3 | 2.5 ratio · CI [-9.2; 18.4] | 2.5416 · IC [-7.6; 14.3] (dentro -0.414 IC [-0.78; 0.04]; entre -1.052 IC [-1.18; -0.92]) | sí | ✔ | Recomendación: nunca mostrar el IC del cociente (inestable); usar la frase 'say' |
| 156 | `panel_within_over_between` | 3 | 0.39 share · CI [-0.05; 0.73] | 0.3935 · IC [-0.04; 0.72] | sí | ✔ | Ninguna |
| 157 | `panel_low_income_halfq5` | 3 | -0.95 children per woman · CI [-2.14; -0.07] | -0.9476 · IC [-2.15; -0.09] (n países 25, N = 250, 7 subregiones) | sí | ✔ | Ninguna |
| 158 | `meta_income_classification` | 3 | World Bank FY2027 country income groups (effective 1 July 2026; 2025 GNI per capita, Atlas method), API download 2026-10-22, applied to all… | archivo wb_api_income_2026-10-22.csv: 217 economías clasificadas (High income 86, Low income 25, Lower middle income 47, Upper middle incom… | sí | ✔ | Ninguna (la etiqueta FY2027 no se puede comprobar desde el CSV) |
| 159 | `n_below_replacement_2023` | 4 | 130 countries and areas | 130 | sí | ✔ | Ninguna |
| 160 | `n_type_B` | 4 | 94 countries and areas | 94 | sí | ✔ | Ninguna |
| 161 | `n_grow_only_migration_2023_1m` | 4 | 11 countries and areas | 11 | sí | ✔ | Ninguna |
| 162 | `examples_type_C_iso3` | 4 | DEU, ESP, BEL | DEU, ESP, BEL | sí | ✔ | Ninguna |
| 163 | `examples_type_E_iso3` | 4 | NPL, AZE, URY | NPL, AZE, URY | sí | ✔ | Ninguna |
| 164 | `examples_momentum` | 4 | India, Brazil, Mexico | India, Brazil, Mexico | sí | ✔ | Ninguna |
| 165 | `pop_momentum_bn` | 4 | 2.2 billion people | 2.2010 | sí | ✔ | Ninguna |
| 166 | `n_sdg32_above` | 4 | 70 countries and areas | 70 | sí | ✔ | Ninguna |
| 167 | `n_shrinking_2050` | 4 | 98 countries and areas | 98 | sí | ✔ | Ninguna |
| 168 | `n_states` | 4 | 195 states | 195 | sí | ✔ | Ninguna |
| 169 | `twin_growth_blr` | 4 | -0.65 % | -0.653 | sí | ✔ | Ninguna |
| 170 | `world_peak_bn` | 4 | 10.29 billion | 10.289315 (año 2084) | sí | ✔ | Ninguna |
| 171 | `share_mig_high_un_agg` | 4 | 64.0 % | 63.9873 | sí | ✔ | Ninguna |
| 172 | `pop_are_2050_zero_mig` | 4 | 12.4 million | 12.3933 | sí | ✔ | Ninguna |
| 173 | `n_cnmr_sign_uncertain_2050` | 4 | 155 countries | 155 | sí | ✔ | Ninguna |
| 174 | `meta_wpp_version` | 4 | UN DESA, World Population Prospects 2024 (July 2024 release): Demographic Indicators, Medium variant (estimates 1950-2023, medium projectio… | Medium: Time 1950-2101, Variant=Medium; OtherVariants: 18 variantes incl. 80/95 PI=TRUE, Zero migration=TRUE; suplemento cols LE60=TRUE, Bi… | sí | ✔ | Ninguna (descriptiva) |
| 175 | `n_onset` | 4 | 109 countries | 109 | sí | ✔ | Ninguna |
| 176 | `n_mort_first_onset` | 4 | 106 countries | 106 | sí | ✔ | Ninguna |
| 177 | `share_mort_first` | 4 | 97 % · CI [92; 99] | 97.2477 [92.22; 99.06] | sí | ✔ | Ninguna |
| 178 | `yr_fert_onset_low` | 4 | 2000 year · CI [1995; 2007] | 2000 [1995; 2007] (survfit median 2000.5); n=24, eventos=22 | sí | ✔ | Ninguna |
| 179 | `sd_le65_1950` | 4 | 1.47 years · CI [1.15; 1.76] | 1.4685 [1.15; 1.76] | sí | ✔ | Ninguna |
| 180 | `cv_le65_1950` | 4 | 12.9 % · CI [10.1; 15.6] | 12.8503 [10.1; 15.6] | sí | ✔ | Ninguna |
| 181 | `sd_medage_1950` | 4 | 4.7 years · CI [3.1; 5.7] | 4.6704 [3.1; 5.7] | sí | ✔ | Ninguna |
| 182 | `q5_ratio_p90p10_peak` | 4 | 27 ratio | 26.934 (2006) | sí | ✔ | def: se añade 'quantile type 7' por coherencia con q5_ratio_p90p10_peak_year |
| 183 | `r2_ladder_tfr_cdr` | 4 | 0.70 R2 | 0.6965 | sí | ✔ | Ninguna |
| 184 | `r2_tfr_cnmr` | 4 | 0.00 R2 · CI [-0.01; 0.08] | -0.00127 [-0.007; 0.084] | sí | ✔ | Ninguna |
| 185 | `r2_tfr_medage` | 4 | 0.77 R2 · CI [0.67; 0.84] | 0.7711 [0.675; 0.835] | sí | ✔ | Ninguna |
| 186 | `r_cnmr_decades_recent` | 4 | 0.69 Pearson r · CI [0.52; 0.73] | 0.6916 [0.523; 0.726] | sí | ✔ | Ninguna |
| 187 | `yrs_medage30_40_jpn` | 4 | 21 years | 21 (1977 -> 1998) | sí | ✔ | Ninguna |
| 188 | `yrs_medage30_40_cohort_1990_2023` | 4 | 24 years · CI [21; 30] | 24 [21; 30] (39 países; 28 cruzan 40 después de 2023; 4 no llegan a 40 antes de 2100) | sí · def ambigua | ✔ | def aclarada en R/04: 39 países cruzan 30 en 1990-2023; la mediana usa los 35 que llegan a 40 antes de 2100 |
| 189 | `cluster_examples_early` | 4 | United States of America, Russian Federation, Japan | United States of America, Russian Federation, Japan | sí | ✔ | Ninguna |
| 190 | `cluster_examples_recent` | 4 | Pakistan, Nigeria, Ethiopia | Pakistan, Nigeria, Ethiopia | sí | ✔ | Ninguna |
| 191 | `k_clusters` | 4 | 4 groups | 4 | sí | ✔ | Ninguna |
| 192 | `cluster_profile` | 4 | <table, 4 rows> | Early movers: n=50, pop_bn=1.44, pct_pob_mundo=17.83, q5_2023=3.84, le65_2023=19.89, le60_2023=23.94, cambio_pob_2023_2050_pct=-6.93, medag… | sí | ✔ | Ninguna |
| 193 | `share_keep_ge_0.8` | 4 | 96 % | 95.65 (154/161) | sí | ✔ | Ninguna |
| 194 | `borderline_countries` | 4 | Republic of Korea, Nepal, Chile, Botswana, Guatemala, Bolivia (Plurinational State of), Armenia | KOR, NPL, CHL, BWA, BOL, GTM, ARM | sí | ✔ | def aclarada en R/04: 500 submuestras del 80 % sin reemplazo, k-means nstart 20, etiquetas emparejadas (húngaro), semilla 2026 |
| 195 | `jaccard_max` | 4 | 0.95 Jaccard | 0.942 (Early movers) | sí | ✔ | Ninguna (dentro de la tolerancia de Monte Carlo) |
| 196 | `region_vote_accuracy` | 4 | 0.78 share | 0.7750 (124/160) | sí · def ambigua | ✔ | def y n aclarados en R/04: denominador 160 (Papúa Nueva Guinea es la única de su región SDG y no tiene voto) |
| 197 | `peak_year_by_group` | 4 | <table, 4 rows> | Early movers/50/30/16/ 4/2021.5 \|\| Fast movers/51/ 7/36/ 8/2058.0 \|\| Recent movers/53/ 0/10/43/2100.0 \|\| Migration-led/ 7/ 0/ 0/ 7/21… | sí | ✔ | Ninguna |
| 198 | `dur53_chn` | 4 | 5 years | 5.1026 (c5 1972.18 -> c3 1977.28) | sí | ✔ | Ninguna |
| 199 | `speed53_median_by_group` | 4 | Early movers: 14.9; Fast movers: 19.2; Recent movers: 29.6; Migration-led: 18 | Early movers 14.95 (n 6, ev 6); Fast movers 19.21 (n 44, ev 42); Recent movers 29.56 (n 45, ev 8); Migration-led 17.95 (n 7, ev 7) | sí | ✔ | Ninguna |
| 200 | `rec_rows` | 4 | <table, 5 rows> | above25=70; stay above 2030=58; on pace=8; road Recent movers (50 of 62) \| momentum=22, 2.20 bn, top3 India/Brazil/Mexico; road Fast mover… | sí | ✔ | Ninguna para los números; los textos (mandatos, agencias) los revisa QA-ethics |
| 201 | `pc1_var` | 4 | 56.7 % · CI [51.4; 62.6] | 56.6735 [51.6; 62.5] | sí | ✔ | Ninguna (diferencia mínima del IC por detalles del remuestreo) |
| 202 | `n_dims_parallel` | 4 | 2 dimensions | 2 | sí | ✔ | Ninguna |
| 203 | `knn_tfr` | 4 | 13 % · CI [9; 18] | 13.1677 [8.6; 17.7] | sí | ✔ | Ninguna |
| 204 | `lookalikes_col_tfr_iso` | 4 | FRA, AUS, TUR, USA, NZL | FRA, AUS, TUR, USA, NZL | sí | ✔ | Ninguna |
| 205 | `moran_cnmr_2023_nogulf` | 4 | -0.03 Moran's I | -0.0283 (n=155) | sí | ✔ | Ninguna |
| 206 | `lisa_cnmr_hh_fdr` | 4 | 7 countries | 7 (ARE, BHR, IRN, KWT, OMN, QAT, SAU) | sí · def ambigua | ✔ | def aclarada en R/02: p de permutación condicional de un lado ('folded', estilo GeoDa), 999 permutaciones; BH al 5 % sobre 161 pruebas |
| 207 | `panel_between_halfq5` | 4 | -1.05 children per woman · CI [-1.17; -0.92] | -1.0523 [-1.17; -0.92] | sí | ✔ | Ninguna |
| 208 | `panel_lowmid_halfq5` | 4 | 0.07 children per woman · CI [-0.56; 0.65] | 0.0695 [-0.56; 0.65] (n países 41, N 410) | sí | ✔ | Ninguna |
| 209 | `panel_ssa_halfq5` | 4 | -1.20 children per woman | -1.1974 (n países 44) | sí | ✔ | Ninguna |
| 210 | `hyp_file_date` | 4 | 2026-10-23 | 2026-10-23 | sí | ✔ | Pendiente (repo-ops / notebook-R): falta docs/hipotesis_preinscritas.sha256 ('make prereg') |
<!-- TABLA-QA-FIN -->

## 6. Claves faltantes y quién debe producirlas

`R/05` las reporta y no las inventa. Siguen faltando las mismas 8 de `docs/QA_notebook_ejecucion.md` §6:

| Clave | Dónde se pide | Por qué falta | Quién debe producirla |
|---|---|---|---|
| `n_census_pre2009` | plan §4; storyboard y `slides/index.html` (tarjeta de datos de la portada: "… countries and areas: last census before 2009") | Hace falta la tabla de fechas de censo de la ONU (*WPP data sources*), que no está en el repositorio. El "23" del memo de ética es externo | **notebook-R** (tarea T0, *fitness for use*), con la tabla de fuentes de la ONU como insumo nuevo documentado |
| `n_census_2019plus` | plan §4 | La misma tabla de censos ("114") | **notebook-R** (T0) |
| `n_shock_years_est` | plan §4 (ética) | La tarea T14 (choques y suavidad de las proyecciones) no se corrió | **notebook-R** (T14; apéndice `app_shock_calendar`) |
| `n_shock_years_proj` | plan §4 | T14 | **notebook-R** (T14) |
| `n_lex_drop_proj` | plan §4 | T14 | **notebook-R** (T14) |
| `share_monotone_proj_lex` | plan §4; `01b_otros_equipos` A7 (frase "projections contain no shocks") | T14 | **notebook-R** (T14) |
| `n_tests` | plan §4; `04_etica` ítem 12 | Q1 registra `n_tests_q1` y Q2 `n_tests_q2`, con definiciones distintas, y Q3 no registra ninguna. Sumarlas sería inventar una definición | **notebook-R** (T17), con la definición por familia F1/F2/F3 acordada con **QA-ethics** |
| `repo` | storyboard (tarjeta de ética 5 y referencias: `github.com/{repo}`) | El repositorio público aún no existe; `docs/equipo.json` tiene `repo: null` | **repo-ops**: crear el repositorio, rellenar `docs/equipo.json` y volver a correr `R/05`. **Resuelto el 2026-10-26** (§10): `repo` existe como clave de **metadatos** (no es una cifra: no pasa por la verificación numérica) y la URL va como texto literal en Referencias |

Cuando aparezcan, cada una debe pasar por un lote de verificación independiente (nueva fila en `docs/qa/verificacion_consolidada.csv`) antes de grabar. Mientras tanto, `R/05` les pondrá `nota_qa` = "NOT VERIFIED … verify before recording".

## 7. Cifras que **NO** deben usarse en el guion ni en las diapositivas hasta resolverse

1. **`are_revision_pct`** ("UAE revised +12 %"): diapositiva 1, build 5 (nota del zoom) y tarjeta de ética 2. No está verificada (sección 3.4). Mientras no se coteje, o se quita el número o se dice sin cifra que la ONU revisó la población de los EAU entre ediciones.
2. **`n_census_pre2009`** (tarjeta de datos de la portada) y **`repo`** (tarjeta de ética 5 y referencias). No existen: `numbers.js` muestra "—". No se puede teclear "23" ni una URL. *(2026-10-26: `repo` ya existe como metadato y la URL del repositorio, que no es una cifra, va como texto literal en Referencias; ver §10.)*
3. **`n_census_2019plus`, `n_shock_years_est`, `n_shock_years_proj`, `n_lex_drop_proj`, `share_monotone_proj_lex`, `n_tests`**. No están en el storyboard, pero ninguna frase del guion o de la ética puede citar su contenido ("114 countries with a recent census", "projections contain no shocks", "we ran N tests") mientras no existan y estén verificadas.
4. **Toda clave con `verified` ≠ `true`**. `slides/script/fill_numbers.py` y `slides/js/numbers.js` ya las señalan como *UNVERIFIED*. Hoy, entre las claves de pantalla y voz, la única es `are_revision_pct`.

Se pueden usar, **pero solo con la regla de la sección 3.3**: `jaccard_min` (≈ 0.8), `panel_ratio_between_within` (sin intervalo), `share_rank_mc20` ("one in five"), `q5_ratio_p90p10_peak_year` (sin año exacto), `yrs_medage30_40_recent` (siempre Fast movers) y `r_tfr_decades_min`.

## 8. Corrida de comprobación y cobertura de `07_integracion_asesorias.md` §4.1

| Paso | Resultado |
|---|---|
| `Rscript R/02_q1_palancas.R`, `R/03_q2_un_numero.R` y `R/04_q3_caminos.R` (en paralelo) | Los tres terminan con código 0 y sin avisos (Q1 tarda 12,8 min) |
| `Rscript R/05_numbers_json.R` | 383 claves, 0 conflictos y `validar_registro()` sin observaciones. §4.5: 209 verificadas, 1 de pantalla sin verificar (`are_revision_pct`) y 173 solo del notebook. Ninguna clave en estado "cambió tras verificar". Siguen faltando 8 claves |
| Comparación campo a campo con `numbers.json` v1 (commit `87d0608`) | Las 383 claves siguen ahí. `value`, IC, `sens_*`, `pi*`, `method`, `say`, `sens_note`, `filter`, `B`, `seed`, `status` y `used_in` son idénticos. Solo cambian 15 `def` y un `n` (`region_vote_accuracy` 161 → 160), y se añade `nota_qa` |
| `notebook/construir_notebook.py` → `jupyter nbconvert --execute` → `notebook/exportar_html.py` | 314 celdas (188 de código): **188 de 188 ejecutadas sin errores ni avisos**, en 13,2 min (menos de los 15 del plan §7.2). El `numbers.json` que escribe el notebook es **idéntico byte a byte** al de la corrida con `Rscript` (SHA-256 `73fded24…`). El HTML tiene 50 imágenes con texto alternativo |
| `Rscript R/tests_incertidumbre.R` | 67 pruebas OK y 0 fallas, con el campo `nota_qa` ya en el esquema |
| `python3 slides/script/fill_numbers.py --check-html slides/index.html` | 107 claves: 2 sin valor (`n_census_pre2009`, `repo`) y 1 sin verificar (`are_revision_pct`), lo mismo que dice la sección 7 |
| Figuras de revisión (`figures/review/`) | Después del notebook, 47 de los 50 PNG son idénticos byte a byte a los del commit. En 3 (`q1_17_europa_decrecimiento_natural`, `q3_03_groups_map` y `q3_04_continuum`) solo cambia **el orden de las dos leyendas**; los datos, el mapa y los puntos son iguales (comprobado con una diferencia de píxeles y a la vista). Ggplot2 no fija el orden de las leyendas: **figures-static / QA-viz** deberían fijarlo con `guide_legend(order = …)`. Estos PNG quedan sin commit, porque están fuera del alcance de este encargo |

**Cobertura de `07_integracion_asesorias.md` §4.1**

- **Punto 1** (`method`, `n`, `universe` y `status`; intervalo en pantalla solo con bloques, Wilson, KM o IP de la ONU). Cubierto: `validar_registro()` no da ninguna observación en las 383 claves.
- **Punto 2** (se reproduce en limpio con la misma `seed` y `B`). Cubierto dos veces: la corrida completa del notebook da el mismo archivo, y el recálculo independiente da las mismas cifras. Las aleatorias quedan dentro de su tolerancia de Monte Carlo (sección 3.3).
- **Puntos 3 a 6** (ventana y universo dichos en voz, países coherentes con su grupo, rótulo "projected (UN medium)" y lenguaje sin p-valores). No los cubre este informe: corresponden a QA-ethics y QA-slides sobre el guion final. Las `nota_qa` de la sección 3.3 les dan las reglas de uso.

**Archivos que cambió este encargo:** `R/02_q1_palancas.R`, `R/03_q2_un_numero.R`, `R/04_q3_caminos.R` (solo textos de `def` y un `n`), `R/05_numbers_json.R` (§4.5), `R/incertidumbre.R` (campo `nota_qa`), `R/tests_incertidumbre.R` (etiqueta de una prueba), `R/qa_verificacion.R` (nuevo), `notebook/construir_notebook.py` (párrafo de verificación), `notebook/analisis_wpp2024.ipynb` y `.html` (corrida nueva), `figures/numbers.json`, `docs/qa/consolidar_verificacion.R`, `docs/qa/verificacion_consolidada.csv`, `docs/qa/tabla_qa_stats.py` y este archivo. También se regeneraron, sin cambios de cifras, `figures/numbers_q1.json`, `numbers_q2.json` y `numbers_q3.json` (las `def` nuevas y `nota_qa`), pero quedan fuera del commit autorizado. El próximo commit de notebook-R o de repo-ops debe incluirlos.

## 9. Qué no cubre este informe

- La redacción del guion (universo dicho en voz, "projected (UN medium)", ausencia de "p =" o "significant"): **QA-ethics** y **QA-slides** (07 §4.1, puntos 3, 5 y 6).
- La coherencia entre cada país nombrado y su tipo o grupo en la voz (07 §4.1, punto 4). Aquí se verificaron los ejemplos por regla (`examples_type_*`, `cluster_examples_*`, `twins`, `lookalikes_*`), no las frases que los usan.
- Las 173 claves que solo usa el notebook: se reproducen al correr el notebook, pero no se recalcularon con código independiente.

## 10. Verificación humana (2026-10-26)

Registro escrito por el agente de IA *seguimiento* (2026-10-26, después de las 11:23) a partir de lo que **el usuario informó en el chat**. Ningún agente hizo esta verificación ni la presenció; aquí solo se anota, con su alcance exacto, y se comprueba con `stat` que los archivos verificados son anteriores a la hora informada.

| Campo | Valor |
|---|---|
| Fecha y hora | **2026-10-26, 11:23** (America/Bogota, UTC−5) = `2026-10-26T11:23-05:00` |
| Quiénes | Los cuatro integrantes: **Daniela C. Kwan, David S. Merchán, Jhon A. Mora y Alejandro Higuera** |
| Alcance | Las cifras **habladas** del guion v4 (`slides/script/narration_en.md`: 17 cifras habladas; 21 claves con `en_voz = sí`) y las cifras **en pantalla** del deck rc1 (`slides/index.html`, que las toma de `figures/numbers.json`, y su PDF `slides/export/slides.pdf`): las 107 claves de `docs/verificacion_numeros.csv` |
| Fuera del alcance | Las cifras del README, del notebook y de los memos de `docs/` (son copias de las mismas claves o cifras de trabajo, pero no se informó que se revisaran) y las 173 claves de `numbers.json` que solo usa el notebook |
| Dónde queda | `docs/verificacion_numeros.csv` (columnas `verificado_por` = "4 integrantes" y `verificado_en` = `2026-10-26T11:23-05:00` en las 107 filas; antes se llamaban `revisado_por` y `fecha`; `valor_comprobado_a_mano` y `ok` quedan vacíos porque no se informaron fila por fila) · `docs/equipo.json` → `human_check` · `figures/numbers.json` → clave de metadatos `meta_human_check` (la copia `R/05_numbers_json.R` §4.4) |
| Método | Lo informó el usuario: los cuatro comprobaron **a mano** las cifras habladas y en pantalla. No se informó contra qué salida se cotejó cada fila ni el valor leído (lo previsto: `notebook/analisis_wpp2024.html` y `figures/numbers.json`); por eso `valor_comprobado_a_mano` sigue vacío y `ok` dice "sí (global, informado)" (rc2). 11:23 es la hora informada; todos los archivos comprobados son anteriores |
| Qué **no** cambia | `verified: true` sigue significando "recalculada con código independiente" (QA-stats, IA). La verificación humana va aparte, en `meta_human_check`; no cambia ningún `value` ni ningún `verified` |

**Archivos verificados: todos con fecha anterior a las 11:23** (`TZ=America/Bogota stat -c '%y'`, comprobado el 2026-10-26 a las 11:51, con el árbol limpio en el commit `c367937`; SHA-256 = primeros 16 caracteres del archivo en ese commit):

| Archivo | Fecha de modificación (UTC−5) | SHA-256 en `c367937` |
|---|---|---|
| `slides/script/narration_en.md` | 10:51:49 | `6d566d52b926fdbb` |
| `slides/script/captions.json`, `captions.srt`, `video_timings.json`, `data_captions.json` | 10:51:49 | — |
| `figures/numbers.json` (383 claves) | 10:50:49 | `c98bc30ea85c9d04` |
| `slides/index.html` | 10:56:56 | `2a5a279e3c7c9041` |
| `figures/static/` y `figures/animated/` (la más reciente: fig09) | fig09 MP4 11:00:23 · PNG 11:00:45 · `_print.png` 11:00:46 | `0aaf163b1a4fad27` (PNG) · `3e7e7a099d75ccc2` (MP4) |
| `slides/css/theme.css` (maquetación, sin cifras) | 11:13:07 | — |
| `slides/export/slides.pdf` | 11:13:30 | `5a824bf36feede85` |
| `slides/js/numbers_data.js` (copia de `numbers.json`; entonces sin versionar) | 11:21:42 | — |

Antes de este encargo, después de las 11:23 solo habían cambiado `.gitignore` (11:32), la grabación de prueba (`video/raw/slides_20261026_113220.webm` 11:37 y `video/deck_silent.mp4` 11:39, grabadas del mismo deck sin cambios), `video/assemble.sh`, `video/README.md`, `video/record_slides.py` (11:41–11:42), `README.md` (11:47) y `docs/INDICE.md` (11:47). Ninguno es fuente de cifras del guion o del deck.

**Cambios hechos después de las 11:23 por este encargo (ninguno cambia una cifra):**

- `figures/numbers.json`: `R/05_numbers_json.R` añade **2 claves de metadatos** (`repo` y `meta_human_check`); `git diff` = 86 líneas añadidas y **0 borradas**; las 383 claves anteriores son idénticas campo a campo (209 con `verified: true`, igual que antes). SHA-256 nuevo `7d0b3f46e5546330…` (385 claves).
- `slides/index.html`: solo texto sin cifras en la tarjeta de ética 5 y en Referencias (frase de verificación y URL del repositorio; después, con la información del usuario de las 12:10, la declaración de IA de Referencias dice "assisted the analysis, the code and the production …, not the voices (team members narrate; no synthetic voice)" y "The four of us share equal responsibility"). Las cifras de esas líneas (`hyp_file_date`, `hyp_file_sha256_short`) no cambian.
- `docs/equipo.json`: bloques `consent`, `authorship` y `voices` (12:10, P-04 y P-05). `R/05` no los lee: al volver a correrlo, `numbers.json` sale idéntico (comprobado con `git diff` y comparación campo a campo).
- `slides/export/slides.pdf`, capturas y `video/deck_silent.mp4`: regenerados desde los mismos valores.
- Guion y subtítulos: **sin cambios** (mismo contenido y misma fecha 10:51; `build_narration.py` ahora solo reescribe un archivo si su contenido cambia).

**Regla desde ahora:** si una cifra hablada o en pantalla cambia después del 2026-10-26T11:23-05:00, vuelve a verificarse a mano antes de grabar o entregar (`docs/correcciones.md`, P-01), y se actualizan `human_check` en `docs/equipo.json` y las filas de `docs/verificacion_numeros.csv`.

**Cambios de rc2 (2026-10-27, agente *cierre-rc2*).** Comparación de `slides/index.html` (claves `data-num`, `data-flags`, `data-list`) y de los subtítulos (`slides/script/data_captions.json`) con los del commit `c367937` (los verificados a las 11:23): **una sola cifra nueva en pantalla, `knn_pc1` = 20 %** (`verified: true`, lote 2; S3 y PDF p. 4) → fila nueva en `docs/verificacion_numeros.csv` con `ok` = PENDIENTE y pendiente P-07 en `docs/correcciones.md`. Salen de la pantalla `cdr_prt`, `cdr_tcd` y `lex_gap_prt_tcd` (párrafo Portugal–Chad, jurado viz I-3). Las cifras habladas no cambian (mismas cifras en los subtítulos). `r2_tfr_medage`, `r2_tfr_growth`, `knn_pc12`, `knn_tfr` y `share_rank_mc20` aparecen además en el recuadro de respuesta de la S3, con los mismos valores ya comprobados. Ningún `value` de `numbers.json` cambió.

**Verificación humana de `knn_pc1` (P-07, 2026-10-27 23:40 UTC−5).** Informada por el usuario: los cuatro integrantes comprobaron a mano la cifra nueva de rc2, `knn_pc1` = 20 % (S3 y PDF p. 4). Coherencia temporal: 23:40 queda entre `d449aac` (23:39) y `85f8e23` (2026-10-28 00:00); el segundo solo movió la marca `|` de corte de subtítulo en 2 `data-caption` de `slides/index.html` (`numbers.json` y el guion sin cambios), así que ninguna cifra visible o hablada cambió después de las 23:40 y la verificación cubre la versión rc2. Firmada en `docs/verificacion_numeros.csv` (`ok` = "sí (informado)"; valor leído y fuente no informados) y en `docs/correcciones.md` P-07. `human_check` / `meta_human_check` (global, rc1) no se tocan.

**Frase pública** (Referencias y tarjeta de ética 5): *"Every number was recomputed by independent code and checked by the four team members"* (rc1); desde rc2, con el alcance exacto: Referencias *"Every number in the text and narration was recomputed from the raw UN files by separate code (also AI-written) and checked by hand by the four team members; numbers inside figures were recomputed by that code"* y tarjeta 5 *"every number in text and voice: recomputed by independent code, checked by the four of us"*. La voz no menciona la verificación ("every number and our AI use are documented in our notebook"), así que no se tocó.
