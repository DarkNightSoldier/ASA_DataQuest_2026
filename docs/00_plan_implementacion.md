# 00 — Plan de implementación (división del trabajo, repositorio, convenciones y definición de "terminado")

> **Versión 2 — integración de asesorías (2026-10-22/23) — cambios principales**
> 1. **Entorno:** los 56 paquetes de `docs/paquetes_estado.csv` están instalados (incl. `sf`, `rnaturalearth`, `gganimate`, `gifski`, `av`, `transformr`, `magick`, `ggbump`); `av` codifica MP4 sin ffmpeg del sistema y `sf` + Robinson funcionan (probado por el integrador). No están `fpc`, `gghighlight`, `colorblindr` (→ `jacc_boot()`, resaltado manual, `colorspace::simulate_cvd`).
> 2. **Mapas:** `sf` + `rnaturalearth` + `coord_sf(crs = "+proj=robin")` como ruta principal, con los ajustes ONU del memo espacial; plantilla `s2` + Robinson propio como respaldo; `maps` solo como último recurso.
> 3. **Animación:** `gganimate` + `av_renderer()` (MP4) / `gifski` (GIF); fotogramas manuales + `av::av_encode_video()` para zoom de mapa y registro por hitos; `imageio-ffmpeg` del venv solo como respaldo.
> 4. **Notebook (§3.1):** se añaden supervivencia (inicio de la caída, Wilson, Kaplan–Meier, Turnbull, log-rank), registro por hitos FDA, panel en cambios quinquenales con FE, look-alikes, PCA con análisis paralelo, Monte Carlo del índice, estabilidad por país, Moran/join count, bootstrap BCa y **por bloques de subregión**, OtherVariants con lista blanca y fan chart de EAU; se quitan DTW, `fpc::clusterboot`, el panel en niveles y las correlaciones temporales de niveles.
> 5. **`numbers.json` (§4):** cada clave lleva `method`, `ci_low`, `ci_high`, `B`, `seed`, `sens_low`, `sens_high`, `status`, `hypothesis_id`, `say` y, en proyecciones, `pi80/pi95`; los intervalos en pantalla usan `method: "block bootstrap by subregion"`; lista de claves obligatorias revisada.
> 6. **Pre-registro:** `docs/hipotesis_preinscritas.md` (creado el 2026-10-22) se congela antes de la corrida final; su sha256 se calcula al commit y se publica (README, `numbers.json`, tarjeta de ética).
> 7. Figuras del vídeo renumeradas (fig00–fig11, 6 animaciones); paletas sin semáforo; nombres *Recent movers* / *Migration-led*; ingreso FY2027.
> Registro de decisiones: `docs/07_integracion_asesorias.md`.

> Complementa `00_plan_analitico.md` (qué se analiza) y `00_storyboard_diapositivas.md` (qué se muestra y se dice). Entrega: **viernes 30-oct-2026**. El orquestador no edita archivos: **cada cambio lo hace el agente responsable**. Solo `repo-ops` (o el agente al que el orquestador se lo encargue explícitamente) ejecuta `git`.

---

## 1. Hechos del entorno que condicionan el plan (verificados 2026-10-22)

| Recurso | Estado | Consecuencia |
|---|---|---|
| R 4.6.1, 14 núcleos, 30 GB RAM; CRAN accesible | OK | Todo el análisis y las figuras en R. |
| Paquetes R (`docs/paquetes_estado.csv`: **56/56 instalados**) | tidyverse, data.table, arrow, patchwork, ggrepel, scales, viridis, ggridges, ggalluvial, plotly, **sf 1.1.3, rnaturalearth, rnaturalearthdata, units, terra, s2**, maps, mapproj, countrycode, **ggflags, ggbump, ggstream, ggimage, geofacet**, **gganimate, transformr, gifski, av, magick**, factoextra, FactoMineR, cluster, dtwclust (no se usa), fda, fda.usc, forecast, tseries, plm, lme4, **fixest**, mgcv, broom, gt, kableExtra, IRkernel, jsonlite, here, renv. Además disponibles (comprobado): **survival, boot, mclust, sandwich, lmtest, clue, tweenr, ragg, colorspace** | Todo el plan es ejecutable sin fallbacks. `units`/`magick` cargan gracias al rpath con `patchelf` (ver `R/config.R` §1b y `SETUP.md`). |
| No instalados | `fpc`, `gghighlight`, `colorblindr` | Estabilidad de clústeres con `jacc_boot()` (código en `06_asesoria_multivariado.md` §3.4 / `06_asesoria_datos_funcionales.md` §4); resaltado con la receta manual del catálogo §3.2; CVD con `colorspace::simulate_cvd()`. Se pueden instalar si hace falta (autorizado). |
| `ffmpeg` del sistema | **no** (el paquete `av` trae libav 8.1.2) | MP4 con `av::av_encode_video()` o `gganimate::av_renderer()` — **probado** el 2026-10-22 (MP4 de fotogramas `ragg` y de `transition_time`). Respaldo: binario portable de `imageio-ffmpeg` en el venv. |
| `sf` + Robinson | **probado** (`ne_countries(scale = "medium")` → `st_transform("+proj=robin")`, 242 polígonos) | Ruta principal de mapas (§5). |
| ImageMagick CLI 7.1.2, `gifsicle` | instalados | GIF de respaldo. |
| Python 3.14 + venv `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/venv-jupyter` (jupyter, nbconvert, imageio-ffmpeg, playwright) | OK | Ejecutar el notebook (`nbconvert --execute`) y grabar con Playwright. |
| Node 24 + npm; Chromium `/usr/bin/chromium` | OK | reveal.js vendorizado; PDF headless. |
| Quarto, pandoc, OBS | no | reveal.js HTML directo. |
| Fuentes | Lato y Noto Sans | Fuente única: **Lato**. |
| Scripts de prototipo de los asesores | en el scratchpad (`series_tiempo/`, `multivariado/`, `fda/`, `demografia/`, `panel/`, `incertidumbre/`, `espacial/`) — **temporal** | `notebook-R` copia los bloques necesarios a `R/` (§3.1); nada del vídeo puede depender del scratchpad. |

---

## 2. Estructura del repositorio `RepoGithub/`

```
RepoGithub/
├── README.md · SETUP.md · LICENSE · Makefile · renv.lock · CITATION.cff · .gitignore
├── data/{raw, processed, README.md}        # processed/lookup_regiones.csv versionado (añadir columna `soberano`)
├── R/
│   ├── config.R              # rutas, semilla, constantes (§6), paletas v2, VARS_PCA, GOLFO, nombrar_grupo() v2, theme_wpp(), badge()
│   ├── 01_preparar_datos.R   # + lectura de OtherVariants con lista blanca y test de monotonía (§3.1 T0)
│   ├── 02_q1_palancas.R      # descomposición, mapa, inercia, supervivencia, registro FDA, panel, migración, Moran
│   ├── 03_q2_un_indicador.R  # scorecard, gemelos, look-alikes, PCA + análisis paralelo, índice Monte Carlo
│   ├── 04_q3_trayectorias.R  # clustering + validación (FPCA, Jaccard, keep_share, join count), divergencia P1, recomendaciones
│   ├── 04b_incertidumbre.R   # OtherVariants (fan EAU, dirección 2050), bootstrap BCa y por bloques, "What we tested"
│   ├── 05_numbers_json.R     # función entrada() → figures/numbers.json (§4)
│   ├── fig_estaticas.R · fig_animadas.R
│   └── utils_mapas.R · utils_supervivencia.R · utils_fda.R · utils_bootstrap.R · utils_espacial.R
├── notebook/analisis_wpp2024.ipynb (+ .html)
├── figures/{numbers.json, static/, animated/, frames/, appendix/, review/, miembros_*.csv, lookalikes_todos.csv}
├── slides/{index.html, css/, js/, assets/, vendor/, script/, export/}
├── video/{record_slides.py, assemble.sh, final/}
└── docs/   # 00_* planes, 01–07, hipotesis_preinscritas.md (+ .sha256), addendum_plan.md, decisiones_de_datos.md,
            # correcciones.md, verificacion_numeros.csv, registro_ia.md, QA_*.md, guia_notebook.md, preguntas_defensa.md
```

`.gitignore`: `data/raw/`, `data/processed/*.parquet`, `figures/frames/`, `slides/vendor/`, `tools/`, `video/final/`, `*.RData`, `.Rhistory`, `.Rproj.user/`, `.ipynb_checkpoints/`. MP4/GIF ≤ 10 MB sí se versionan.

---

## 3. Agentes, orden y dependencias

| # | Agente | Entrega (ruta) | Depende de | Día objetivo |
|---|---|---|---|---|
| 0 | env-setup | **Hecho** (56/56; `SETUP.md`) | — | D1 ✔ |
| 1 | prepare-data | **Hecho** (`R/01_preparar_datos.R`, parquet, tests). **Pendiente v2:** lectura de OtherVariants con lista blanca + `stopifnot()` de monotonía; columna `soberano` en `lookup_regiones.csv`; constantes v2 en `R/config.R` (§6) | 0 | D2 (23 oct) |
| 1b | **pre-register** (`repo-ops` + `notebook-R`) | `docs/hipotesis_preinscritas.md` **congelado antes de la corrida final**: (1) cualquier ajuste de filtros/umbrales se hace **antes** de ejecutar el notebook final y se registra con fecha en `docs/addendum_plan.md`; (2) al commit que lo congela: `make prereg` → `sha256sum docs/hipotesis_preinscritas.md > docs/hipotesis_preinscritas.sha256`; (3) el hash (completo y 12 primeros caracteres), la fecha y el commit se escriben en README, en `numbers.json` (`hyp_file_sha256`, `hyp_file_sha256_short`, `hyp_file_date`, `hyp_file_commit`) y en la tarjeta 5 de ética; (4) todo lo añadido después se etiqueta *post hoc* en notebook y diapositivas. Etiqueta pública: **"pre-specified"**, nunca "pre-registered" ni "confirmatory" | 12 | **D2–D3, antes del 25-oct** |
| 2 | notebook-R | `R/02–05_*.R`, `R/utils_*.R`, `notebook/analisis_wpp2024.ipynb` ejecutado, `figures/numbers.json` v1 con **todas** las claves de §4 (`verified:false`) — tareas detalladas en §3.1 | 1, 1b | D2–D3 — **congelar cifras v1 el 25-oct** |
| 3 | figures-static | `R/fig_estaticas.R` → `figures/static/fig00…fig11.png` + `figures/appendix/app_*.png` + `figures/review/` | 2 | D3–D4 |
| 4 | figures-animated | `R/fig_animadas.R` → 6 MP4 + GIF + pósters (§7.4) | 3 | D4–D5 |
| 5 | script-narration | `slides/script/narration_en.md` (654 palabras v2; claves resueltas con `.say`), `captions.srt`, `video_timings.json` | 2 | D4 |
| 6 | slides-revealjs | `slides/index.html`, css/js, `slides/export/slides.pdf` | 3, 4, 5 | D5–D6 |
| 7 | QA-stats | `docs/QA_stats.md`; `verified:true`; checklist de `07_integracion_asesorias.md` §4 | 2 | D3 y D6 |
| 8 | QA-viz | `docs/QA_viz.md` + `figures/review/checklist.md` | 3, 4 | D4 y D6 |
| 9 | QA-ethics | `docs/QA_ethics.md`, `docs/qa_etica.csv` | 2, 5, 6 | D6 |
| 10 | QA-slides | `docs/QA_slides.md` | 6 | D6–D7 |
| 11 | video-record | `video/final/*.mp4` ≤ 5:00 | 6, 10 + voz | D7 |
| 12 | integrate-advice | **Hecho 2026-10-22/23**: tres planes v2, `hipotesis_preinscritas.md`, `07_integracion_asesorias.md` | memos 06 | D1–D2 ✔ |
| 13 | repo-ops | commits por hito, README final, tag `v1.0-submission`, repo público antes de enviar | todos | D8 |

Orden crítico: **1 → 1b → 2 → 3 → 4 → 6 → 10 → 11**. Ninguna animación antes de su figura estática aprobada; nada se graba sin ✔ de QA-stats.

### 3.1 Tareas del notebook (v2) — `notebook-R`

Convenciones: ≥ 1 M (`pob_1m`) para modelos; estimaciones ≤ 2023 salvo indicación; `set.seed(2026)` antes de cada bloque aleatorio; cada bloque termina con "Lectura de resultados" citando cifras reales; cada sección de análisis lleva la etiqueta *Exploratory* o *Pre-specified (H…)*; los valores esperados son los de `00_plan_analitico.md` §4–§6 y la hipótesis de `docs/hipotesis_preinscritas.md`.

| ID | Tarea | Método / código de partida | Salidas (figuras · claves) |
|---|---|---|---|
| **T0** | Fuentes, licencias, *fitness for use*, decisiones de datos | Ficha de censos (114/237 ≥ 2019; 23 antes de 2009), revisiones 2022→2024, Togo *Interim Update* (sensibilidad), recuadro de migración; **OtherVariants** con lista blanca (`TPopulation1July, TFR, LEx, LExMale, LExFemale, CNMR, NetMigrations, CBR, CDR, IMR, Births, Deaths, NatChange, PopGrowthRate`) y test L95 ≤ L80 ≤ Median ≤ U80 ≤ U95; el resto a `NA` | `n_census_pre2009`, `n_census_2019plus`, `are_revision_pct` |
| **T1** | Descomposición contable por ingreso (FY2027) y región | Sumas de personas; China e India separadas; **BCa** (B = 2 000) + **jackknife** por país; sensibilidades (agregados ONU, sin Rusia, sin EE. UU., sin Golfo, ≥ 1 M, 2010–23) | `fig01`; `share_mig_*`, `china_share_natchange_upmid`, `india_share_natchange_lowmid` |
| **T2** | Tipos de palanca 2023 (A–E con A y B separados), inercia, ejemplos por regla, sensibilidad de ventanas | `tipo_palanca_2023`; ventanas 2017–19 / 2021 / 2022 / 2021–23; umbral TFR 2,0/2,1/2,2 y NRR < 1; inercia = B & TFR < 2,1 (y variante estricta NetMigrations < 0) | `fig02`, `fig02b`; `n_type_*`, `examples_type_*`, `cover_flags`, `n_momentum_countries`, `n_momentum_emig`, `pop_momentum_bn`, `figures/miembros_tipo_palanca.csv` |
| **T3** | **Supervivencia / Kaplan–Meier** (P7: quién se mueve primero) | `inicio()` (regla de Princeton, `06_asesoria_series_tiempo.md` Anexo); elegibles TFR₁₉₅₀ ≥ 5; Wilson (`prop.test(correct = FALSE)`); `survfit(Surv(t, e) ~ ingreso)` para el año de inicio de la TFR, `survdiff` (log-rank), `coxph`; Turnbull `Surv(L, R, type = "interval2")` del rezago → si la mediana no se identifica, solo cota inferior; rejilla de reglas y de umbrales absolutos como sensibilidad | `fig05`, `app_km_onset_income.png`, `app_threshold_grid_lag.png`; `n_onset`, `n_mort_first_onset`, `share_mort_first` (Wilson), `lag_onset_lower_bound`, `q5_drop_at_tfr_onset`, `n_q5_falling_1950`, `yr_fert_onset_*`, `logrank_income_chisq` |
| **T4** | **Alineación FDA** (registro por hitos) y velocidad | B-splines λ = 10; `c4` = último cruce de 4; varianza ±20 (calendario vs reloj propio); Kneip–Ramsay (`landmarkreg` con dominio 0–73 y base de alabeo de 5 funciones, ver `06_asesoria_datos_funcionales.md` §4); hitos 5 y 3; KM de `dur_5a3` por cohorte y por grupo | `fig04` (animación A → B); `n_cruce_tfr4_obs`, `n_cens_izq`, `n_cens_der`, `pct_var_fase`, `r2_fase_kr`, `dur53_chn`, `dur53_egy`, `km_dur53_*` |
| **T5** | **Panel en cambios de 5 años con efectos fijos** (sustituye al panel en niveles) | Medias quinquenales; `feols(dTFR ~ L0+L1+L2+L3+L4 | ISO3_code + periodo, cluster = ~ISO3_code)`; suma de rezagos × ln 0,5; `split` por ingreso y región, Cochran Q / I², Wald; placebo de permutación (300), adelanto, sentido inverso, LOO, Mundlak, diferencia larga; migración CNMR ~ nat(t−1) con FE país + periodo (alto sin Golfo); descomposición de varianza entre/dentro; **comparación honesta M0–M4** (mismo denominador, países fuera) | `fig06`, `app_honest_model_comparison.png` (pn06), `app_within_between.png`; `panel_*`, `mig_hi_within_slope`, `mig_share_within/between(_excl_gulf)`, `r2_oos_m0…m4`, `n_tests` |
| **T6** | Migración: memoria y Simpson | Correlación entre décadas consecutivas (CNMR, TFR, LEx); ρ 1950–2023; β con σ₀/σ₁ y placebo; forest de Spearman por ingreso (B = 2 000) + parcial dado el ingreso + permutación de matrices; pendientes por ingreso | `app_migration_memory.png` (dem06), `app_simpson_income.png` (fig_mv06); `r_cnmr_decades_*`, `r_tfr_decades_min`, `r_cnmr_1950_2023`, `rho_q5_cnmr_world`, `rho_q5_cnmr_within_*` |
| **T7** | Dependencia espacial (solo notebook + 3 cifras) | W kNN5 haversine; Moran I con permutación (999) y jackknife, versión por rangos; correlograma; **LISA con FDR (solo notebook)**; join count de los clústeres; **modelo espacial y panel SLX solo notebook** (sin SAR ni GWR); bootstrap por bloques de 20 subregiones como función común `boot_bloques()` | `app_spatial_moran.png` (esp01), `app_lisa_migration.png`, `app_spatial_model.png`; `moran_*`, `join_same_road`, `join_same_road_null`, `knn_vote_accuracy`, `region_vote_accuracy` |
| **T8** | Scorecard (4 salidas a priori) y gemelos | R² ajustado; BCa + bloques; VC 10-fold × 20; spline; 237; escalera fuera de tiempo (ST §3.5, apéndice); búsqueda exhaustiva de gemelos (12 880 pares) con top-5 por regla; CDR Portugal–Chad | `fig07`, `fig08` (tarjeta A); `r2_tfr_*`, `r2_*_cv`, `r2_all`, `twins`, `cdr_prt`, `cdr_tcd`, `rho_cdr_lex_*`, `rho_cdr_medage_2023` |
| **T9** | **PCA con 12 variables fijas + look-alikes** | `VARS_PCA` (12; `PopDensity` en log; CNMR winsorizada); análisis paralelo (1 000 permutaciones); bootstrap B = 1 000; conjuntos alternativos (8 catálogo, 8 no redundantes, 13 EDA); sin Golfo; 1950/1990/2050; `knn_overlap()` y `recupera()` (MV §3.2) con k = 5 y 10, 1990/2050, 8 variables; tabla completa por país; Colombia y EAU | `fig09`, `fig08` (métrica y tarjeta B), `figures/lookalikes_todos.csv`; `pc1_var`, `pc2_var`, `pc2_var_no_gulf`, `n_pcs_70`, `n_dims_parallel`, `r_tfr_pc1`, `r_tfr_pc2`, `knn_*`, `recov_*`, `lookalikes_col_*` |
| **T10** | Índice compuesto (P5) | Monte Carlo de 2 000 diseños (Dirichlet(5) + normalización + agregación + inclusión del crecimiento) y variantes (solo normalización; Dirichlet(1)); intervalo 90 % de rango; pesos efectivos; α y ω solo notebook; validez con LE60; bump de UKR/BLR | `app_index_mc_ranks.png`; `share_rank_mc20`, `share_rank_mc20_sens`, `rank_range_ukr`, `alpha`, `omega` |
| **T11** | Clustering de trayectorias + validación | k-means k = 4 (32 rasgos, `nstart = 50`); silueta por k, gap, Ward, PAM, Mclust; **FPCA multivariada + k-means** (ARI); `jacc_boot()` (B = 200); **`keep_share` por país** (500 remuestras al 80 %, emparejamiento húngaro `clue::solve_LSAP`); `cluster::fanny`; sin CNMR y asinh; join count (T7); descripción con variables externas sin p-valores; nombres con `nombrar_grupo()` v2; medoide y 3 más poblados por grupo; rejilla de sensibilidad {k-means, Ward, PAM, FPCA} × {161, 237} × {con/sin CNMR} × {décadas, quinquenios} en una figura | `fig10`, `app_sensitivity_grid_clusters.png`, `app_cluster_stability_by_country.png`, `figures/miembros_grupos.csv`; `k_clusters`, `silhouette`, `cluster_names`, `cluster_sizes`, `cluster_pop_bn`, `cluster_examples_*`, `cluster_medoids`, `jaccard_*`, `ari_fpca_decadas`, `ari_tray_niveles`, `ari_sin_cnmr`, `share_between_groups`, `share_keep_ge_0.8`, `borderline_countries` |
| **T12** | Divergencia P1 y curvas atípicas | DE, CV, P10–P90 por año; log Q5 y razón P90/P10; LE65 (LE60 robustez); IC bootstrap del cambio; σₜ ~ t solo 1950–2023 con Newey–West; R² región/ingreso por año; profundidad funcional (`fbplot`, `outliers.depth.trim`) sobre datos crudos; RCA marcada | `fig11`, `app_atypical_curves.png`; `sd_*`, `cv_*`, `q5_ratio_p90p10_*`, `r2_region_medage_*` |
| **T13** | **Fan chart desde OtherVariants** (P2/P3) | IP 80/95 de `TPopulation1July` para EAU (+ escenario *Zero migration*) y pequeños múltiplos (Mundo, EAU, Nigeria, Níger, China, Alemania, Colombia, Rep. de Corea, Japón); dirección 2050 (IP 95 contiene 2023); signo CNMR 2050 (IP 80 contiene 0); China población 2050; Low/High como escenarios | `fig03`, `app_fan_small_multiples.png`, `app_direction_2050.png`; `pop_are_2050`, `pop_are_2050_pi80/95_*`, `n_dir_uncertain_2050`, `n_cnmr_sign_uncertain_2050`, `pop_chn_2050_pi95_*`, `world_pop_2100_pi95_*` |
| **T14** | Choques y suavidad de las proyecciones | Detector (mediana móvil 9 años, MAD solo 1950–2023); calendario de choques; % de trayectorias monótonas; una medida de volatilidad declarada (mediana entre países de la DE de cambios anuales, 1951–2023 vs 2025–2100) | `app_shock_calendar.png`; `n_shock_years_est`, `n_shock_years_proj`, `n_lex_drop_proj`, `share_monotone_proj_lex`, `ratio_vol_*` |
| **T15** | Complementos de demografía | `dem01` (misma TFR), países con NatChange < 0 (8 → 53 → 106) y % de población, ODS 3.2 (ritmo observado 2015–23 vs necesario), Irlanda/Portugal, Nigeria–Mauricio, años de edad mediana 30 → 40, S11 con y sin China | `app_same_fertility.png`, `app_deaths_exceed_births.png`, `app_sdg32_pace.png`; `n_natneg_*`, `share_pop_natneg_2023`, `n_sdg32_*`, `yrs_medage30_40_*`, `medage_chn_2050` |
| **T16** | Recomendaciones | Tabla por estado de la palanca con la columna "Road" (grupo mayoritario) calculada | `rec_rows` |
| **T17** | Honestidad | "What we tested" (`n_tests` por familia; Holm / BH en el notebook), "How uncertain are our numbers?" (`inc05`: remuestreo vs decisiones), **"What we did not find"** (plan §12), sección de limitaciones (`04_etica` §5.1) | `app_resampling_vs_choices.png` |
| **T18** | `numbers.json` | `R/05_numbers_json.R` con `entrada()` (§4) | `figures/numbers.json` |
| **Quitar** | — | DTW (`dtwclust`), `fpc::clusterboot`, `feols(TFR ~ l(Q5,10) + CNMR | pais + anio)` en niveles, toda correlación temporal de niveles (incl. "Europa 0,94"), β 1950–2100 como evidencia, heatmap de acoplamiento en el vídeo (queda en el apéndice rotulado *across countries in year t*), "rezago mediano" como cifra principal | — |

---

## 4. `figures/numbers.json` — fuente única de cifras (esquema v2)

Lo genera `R/05_numbers_json.R`. **Ninguna cifra, país, bandera ni nombre de grupo se escribe a mano**: `slides/js/numbers.js` rellena `<span data-num="clave">` y `fill_numbers.py` resuelve `{clave}` (valor formateado) y `{clave.say}` (frase redondeada para la voz).

**Campos por clave** (planos; `NA` → `null`):

| Campo | Contenido |
|---|---|
| `value`, `unit`, `fmt` | valor, unidad, formato de pantalla |
| `say` | versión hablada redondeada ("about seven in ten") |
| `def`, `filter`, `n`, `universe` | definición, filtro, n de unidades, universo (`"237 countries and areas"` / `"161 countries ≥ 1 M"`) |
| `method` | uno de: `"none_census"` · `"wilson"` · `"bootstrap_bca"` · `"bootstrap_perc"` · **`"block bootstrap by subregion"`** · `"jackknife"` · `"km"` · `"turnbull"` · `"logrank"` · `"permutation"` · `"cv_r2"` · `"un_pi"` · `"sensitivity"` · `"descriptive"` |
| `ci_low`, `ci_high`, `ci_level` | intervalo **del método declarado** (0,95 por defecto). **Regla espacial:** cualquier intervalo que se muestre en pantalla usa `method: "block bootstrap by subregion"` (20 subregiones ONU, percentil, B = 2 000), porque los países vecinos no son independientes y esos intervalos salen **1,4–2,2 veces más anchos** que los iid [SP] |
| `ci_iid_low`, `ci_iid_high`, `ci_iid_method` | intervalo iid de países (BCa) para comparación en el notebook [INF] |
| `B`, `seed`, `resample_unit` | réplicas, semilla (2026), unidad (`"country"` o `"UN subregion"`) |
| `sens_low`, `sens_high`, `sens_note` | rango entre decisiones razonables (ventanas, umbrales, conjuntos de variables, con/sin un país) |
| `pi80_low`, `pi80_high`, `pi95_low`, `pi95_high`, `variant_source` | solo proyecciones (IP de la ONU tal cual; marginales, no sumables) |
| `status`, `hypothesis_id` | `"pre-specified"` · `"exploratory"` · `"descriptive"`; ID de `hipotesis_preinscritas.md` |
| `p_value`, `p_adj`, `p_adj_method` | solo notebook; nunca en pantalla |
| `source_cell`, `used_in` | celda del notebook; builds y frases que la usan |
| `verified`, `verified_by`, `verified_on` | QA-stats |

Ejemplos:
```json
"share_mig_high_2000_2023": {"value": 70.7, "unit": "%", "fmt": "0", "say": "about seven in ten",
  "def": "Σ NetMigrations / Σ PopChange, today's World Bank FY2027 High income, 2000–2023", "filter": "237 countries and areas",
  "n": 85, "universe": "237 countries and areas", "method": "bootstrap_bca", "ci_low": 55.8, "ci_high": 114.0, "ci_level": 0.95,
  "B": 2000, "seed": 2026, "resample_unit": "country", "sens_low": 64.0, "sens_high": 81.6,
  "sens_note": "UN income aggregates 64.0; 2010–23 77.5; ≥1M 71.1; without USA 81.6; without Gulf 75.0; without Russia 64.5",
  "status": "pre-specified", "hypothesis_id": "H1", "used_in": ["slide1.build2", "narration.s1b"], "verified": false},
"r2_tfr_medage": {"value": 0.773, "unit": "R2", "say": "three quarters", "method": "block bootstrap by subregion",
  "ci_low": 0.67, "ci_high": 0.84, "ci_iid_low": 0.733, "ci_iid_high": 0.809, "ci_iid_method": "bootstrap_bca",
  "B": 2000, "seed": 2026, "resample_unit": "UN subregion", "status": "pre-specified", "hypothesis_id": "H6"},
"share_mort_first": {"value": 97, "unit": "%", "n": 108, "method": "wilson", "ci_low": 92, "ci_high": 99,
  "sens_low": 94, "sens_high": 97, "sens_note": "9 onset rules (−5/−10/−15 % × TFR1950 ≥ 5/5.5/6)", "status": "pre-specified", "hypothesis_id": "H3a"},
"n_grow_only_migration_2023": {"value": 18, "method": "none_census", "sens_low": 15, "sens_high": 25,
  "sens_note": "2021: 15 · 2022: 25 · 2021–23 avg: 24 · 2017–19: 14", "status": "descriptive"},
"pop_are_2050": {"value": 15.4, "unit": "million", "method": "un_pi", "pi80_low": 10.1, "pi80_high": 26.1,
  "pi95_low": 8.9, "pi95_high": 33.3, "variant_source": "WPP2024 OtherVariants (Median/Lower/Upper PI)", "status": "descriptive"}
```

**Claves obligatorias (v2)** — QA-stats falla si una clave narrada no existe o no tiene `method`:
- *Universo y gancho:* `world_pop_2023_bn`, `n_countries`, `n_countries_1m`, `n_sovereign`, `n_territories`, `n_below_replacement_2023`, `n_below_repl_growing_2023`, `n_below_repl_natural_growth_2023`, `n_grow_only_migration_2023`, `n_grow_only_migration_2023_1m`, `cover_flags`.
- *Slide 1:* `n_type_AB`, `n_type_A`, `n_type_B`, `n_type_C`, `n_type_D`, `n_type_E` (+ `_1m`), `examples_type_C/D/E`, `n_momentum_countries`, `n_momentum_emig`, `pop_momentum_bn`, `examples_momentum`, `share_mig_high_2000_2023`, `share_mig_high_2010_2023`, `share_mig_low_2000_2023`, `share_mig_lowmid_2000_2023`, `share_mig_upmid_2000_2023`, `share_mig_high_un_agg`, `china_share_natchange_upmid`, `india_share_natchange_lowmid`, `cnmr_are_2023`, `growth_are_2023`, `tfr_are_2023`, `are_revision_pct`, `pop_are_2050`, `pop_are_2050_pi95_low`, `pop_are_2050_pi95_high`, `n_dir_uncertain_2050`, `n_cnmr_sign_uncertain_2050`.
- *Slide 2:* `n_cruce_tfr4_obs`, `n_cens_izq`, `n_cens_der`, `pct_var_fase`, `dur53_chn`, `dur53_egy`, `n_onset`, `n_mort_first_onset`, `share_mort_first`, `lag_onset_lower_bound`, `q5_drop_at_tfr_onset`, `n_q5_falling_1950`, `yr_fert_onset_low`, `yr_fert_onset_lowmid`, `yr_fert_onset_upmid`, `yr_fert_onset_high`, `logrank_income_chisq`, `panel_within_halfq5`, `panel_between_halfq5`, `panel_ratio_between_within`, `panel_low_income_halfq5`, `panel_ssa_halfq5`, `panel_eurna_halfq5`, `panel_placebo_lo`, `panel_placebo_hi`, `panel_lead`, `panel_reverse_sd`, `panel_forward_sd`, `r_tfr_decades_min`, `r_cnmr_decades_recent`, `r_cnmr_decades_min`, `r_cnmr_decades_max`, `r_cnmr_1950_2023`, `moran_tfr_2023`, `moran_lex_2023`, `moran_medage_2023`, `moran_cnmr_2023`, `moran_cnmr_2023_nogulf`, `mig_hi_within_slope`.
- *Slide 3:* `r2_tfr_medage`, `r2_tfr_chg2050`, `r2_tfr_growth`, `r2_tfr_cnmr` (+ `_cv`), `r2_all`, `cdr_prt`, `cdr_tcd`, `lex_gap_prt_tcd`, `rho_cdr_lex_1950`, `rho_cdr_lex_2023`, `rho_cdr_medage_2023`, `twins`, `twin_tfr_are`, `twin_tfr_blr`, `twin_growth_are`, `twin_growth_blr`, `knn_tfr`, `knn_pc1`, `knn_pc12`, `knn_chance`, `recov_tfr`, `recov_pc1`, `lookalikes_col_tfr`, `lookalikes_col_12`, `n_dims_parallel`, `r_tfr_pc1`, `r_tfr_pc2`, `pc1_var`, `pc2_var`, `pc2_var_no_gulf`, `n_pcs_70`, `share_rank_mc20`, `rank_range_ukr`, `alpha`.
- *Slide 4:* `k_clusters`, `silhouette`, `cluster_names`, `cluster_sizes`, `cluster_pop_bn`, `cluster_examples_early`, `cluster_examples_fast`, `cluster_examples_recent`, `cluster_examples_migration`, `cluster_medoids`, `jaccard_min`, `jaccard_max`, `ari_fpca_decadas`, `ari_tray_niveles`, `ari_sin_cnmr`, `share_between_groups`, `share_keep_ge_0.8`, `borderline_countries`, `join_same_road`, `join_same_road_null`, `sd_lex_1950`, `sd_lex_2023`, `sd_medage_1950`, `sd_medage_2023`, `sd_le65_1950`, `sd_le65_2023`, `cv_lex_1950`, `cv_lex_2023`, `cv_le65_1950`, `cv_le65_2023`, `q5_ratio_p90p10_1950`, `q5_ratio_p90p10_2023`, `yrs_medage30_40_recent`, `yrs_medage30_40_early`, `n_sdg32_above`, `n_sdg32_on_pace`, `n_sdg32_above_2030`, `n_natneg_1990`, `n_natneg_2023`, `n_natneg_2050`, `share_pop_natneg_2023`, `pop_chn_2050`, `pop_chn_2050_pi95_low`, `pop_chn_2050_pi95_high`, `rec_rows`, `n_ssa`.
- *Ética y reproducibilidad:* `n_census_pre2009`, `n_census_2019plus`, `n_shock_years_est`, `n_shock_years_proj`, `n_lex_drop_proj`, `share_monotone_proj_lex`, `n_tests`, `hyp_file_date`, `hyp_file_sha256`, `hyp_file_sha256_short`, `hyp_file_commit`, `world_peak_year`, `world_peak_bn`.
- **Retiradas** (no deben aparecer en el guion): `lag_median`, `beta_cnmr` (solo notebook con placebo), `share_rank_shift_20`, `yrs_eu/asia/lac`, `rho_tfr_cnmr_high` (H5).

**Reglas de selección (en código, no a mano):** `examples_type_X` = 3 más poblados ≥ 1 M del tipo X en 2023 (nombres cortos ONU vía `countrycode`, alias "Türkiye", "Viet Nam", "Republic of Korea"); `cover_flags` = ISO2 de `examples_type_C`; `examples_momentum` = 3 más poblados con inercia; `cluster_examples_*` = 3 más poblados del grupo; `cluster_medoids` = país más cercano a la trayectoria mediana; país resaltado en `fig04` = el más rápido, el mediano y el más lento de 5 → 3 entre los ≥ 10 M; `twins` = |ΔTFR| ≤ 0,05 con máxima |Δ PopGrowthRate| (≥ 1 M), top-5 publicado; `cluster_names` con `nombrar_grupo()` v2 (§6).

---

## 5. Ruta de animación, mapas y diapositivas (decisión v2)

**Mapas — principal `sf` + Robinson:** `w <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")` (o `type = "map_units"` para separar los departamentos franceses de ultramar) → unión por ISO3 (`iso_a3_eh`/`adm0_a3` con tabla de excepciones en `R/utils_mapas.R`: Kosovo = XKX, Somalilandia → SOM, Chipre del Norte → CYP, Åland → FIN, BES, Tokelau) → **Crimea reasignada a Ucrania** (A/RES/68/262), Siachen neutro → `st_transform("+proj=robin")` → `geom_sf()` + `coord_sf(crs = "+proj=robin", xlim, ylim)` con marco 58° S–85° N. Pequeños Estados: franja inferior de puntos con ISO3 agrupada por región; los ≥ 1 M diminutos (< 15 000 km²) con un punto. Nota obligatoria: `Boundaries and names shown do not imply official endorsement or acceptance by the United Nations. Map: Natural Earth.` **Zoom animado:** fotogramas manuales interpolando `xlim/ylim` (metros Robinson) con `tweenr`, renderizados con `ragg` y codificados con `av::av_encode_video(framerate = 30)`. **Respaldo 1:** plantilla del memo espacial (`rnaturalearthdata::countries50` + `s2` + Robinson propio + `coord_fixed`; scripts `scratchpad/espacial/01_geo.R`, `07_plantilla_mapa.R` → copiar a `R/utils_mapas.R`). **Respaldo 2:** `maps::map_data("world")` + `coord_quickmap()`.

**Animaciones de datos (6):** `gganimate` con `transition_reveal()` / `transition_time()` / `transition_states()` (con `transformr` para polígonos) y `animate(..., renderer = av_renderer("figXX.mp4"), width = 1920, height = 1080, res = 144, fps = 30)`; GIF con `gifski_renderer()`. Cuando el movimiento es de cámara o de alineación (zoom de mapa, registro por hitos) → fotogramas manuales + `av::av_encode_video()`. Reglas: ejes fijos entre fotogramas; contador de año gris "UN projection" tras 2023 con pausa de 1 s; nunca interpolar 2023 → 2024 como la misma serie; el último fotograma = figura estática aprobada (póster). **Respaldo:** binario de `imageio-ffmpeg` del venv (`ffmpeg -framerate 30 -i frame_%04d.png -c:v libx264 -pix_fmt yuv420p -crf 20 -movflags +faststart`).

**Diapositivas:** reveal.js 5 HTML directo (sin Quarto): `fragment` + `data-fragment-index`, `data-caption`, `<video autoplay muted playsinline poster=…>` disparado por fragmento, `?print-pdf` con `pdfSeparateFragments:false` ⇒ 6 páginas. **Vídeo:** Playwright + Chromium del sistema avanza por `video_timings.json`; la voz la graba el equipo; `video/assemble.sh` mezcla (ffmpeg del venv o `av`) y comprueba ≤ 300 s.

---

## 6. Convenciones

- **Idiomas:** código y comentarios en español; textos de figuras, diapositivas y guion en inglés. Figuras `figNN_tema.ext`; apéndice `app_*`.
- **Semilla:** `set.seed(2026)` en `config.R` y **justo antes** de cada remuestreo o k-means; `nstart = 50`; `RNGkind("Mersenne-Twister","Inversion","Rejection")` declarado.
- **Constantes nuevas en `R/config.R`** (las añade `prepare-data`/`notebook-R`): `GOLFO <- c("ARE","QAT","KWT","BHR","OMN","SAU")`; `PERIODO_PANEL <- 5`; `REZAGOS_PANEL <- 0:4`; `B_BOOT <- 2000`; `B_BOOT_PCA <- 1000`; `B_PERM <- 999`; `K_VECINOS <- 5`; `LAMBDA_FDA <- 10`; `UMBRAL_INICIO <- 0.9`; `TFR_ELEGIBLE_1950 <- 5`; `ANIO_BASE_PALANCA <- 2023`; `VENTANAS_SENS <- list(c(2017,2019), 2021, 2022, c(2021,2023))`; `VARS_PCA` con `PopDensity` transformada a log antes del PCA; `COLUMNAS_PI_VALIDAS` (lista blanca de §3.1 T0).
- **Regla de nombres de grupo v2** (`nombrar_grupo()`): si la CNMR mediana 2000–23 del grupo > 10 ‰ → **"Migration-led"**; si el año mediano de TFR < 4 es < 1960 o la mayoría ya estaba < 4 en 1950 → **"Early movers"**; si el año mediano > 1995 o no cruzó → **"Recent movers"**; el resto → **"Fast movers"**. "Sprinters" solo en la sensibilidad sin CNMR. Prohibidos "Late movers", "Migration-boosted" en pantalla.
- **Paletas v2 (sustituyen las de `config.R` v1):**
  - *Componentes y tipos de palanca (Slides 0–2):* natural change / A–B "growing from births" **#0072B2** · net migration / C "growing only through net arrivals" **#56B4E9** · D "shrinking: deaths > births" (y Q5 en fig05) **#E69F00** · E "shrinking: more leave than arrive" **#CC79A7** · small states / no data **#999999**. Sin verde/rojo.
  - *Grupos de trayectoria (Slide 4, Tol):* Early movers **#332288** · Fast movers **#117733** · Recent movers **#DDCC77** · Migration-led **#88CCEE**.
  - *Regiones SDG:* la paleta Okabe-Ito de `config.R` se mantiene **solo en el notebook y el apéndice** (en el vídeo se reutilizarían colores con otro significado).
  - *Ingreso:* viridis de `config.R` (notebook).
  - *Proyección:* gris #B0B0B0 / sombreado #F0F0F0. Forest y biplot en negro/gris con resaltes.
  - Toda figura pasa `colorspace::simulate_cvd()` (deutan, protan, tritan) y se guarda `figNN_cvd.png`.
- **Badges** (función `badge("PIE-x")`, `04_etica` §3.3; PIE-5 corregido): PIE-0 pie fijo; PIE-1 mapas/conteos (`estimates, 2023 · all 237 countries & areas, each counted once · descriptive, not causal`); PIE-2 regiones; PIE-3 modelos (`161 countries ≥ 1 M people, 2023 · exploratory, not causal · intervals: block bootstrap by UN subregion`); PIE-4 ingreso (`World Bank FY2027 income groups (2025 GNI), applied to all years`); PIE-5 proyección con banda (`medium = mean (fertility, life expectancy) or median (migration) of UN probabilistic trajectories · bands: UN 80 % / 95 % prediction intervals, not additive across countries`); PIE-6 migración (`net migration = arrivals − departures, often a census residual — the least-measured component`).
- **Tema:** `theme_wpp(base_size = 22, base_family = "Lato")`; exportar con `ragg::agg_png(1920, 1080, res = 144)` + copia 960×540.
- **Lenguaje (grep de QA-ethics):** prohibidos `cause*, drive*, leads to, results in, impact of, effect of, unlock*, thanks to, because of, would (shrink|grow…), without (immigration|migration), will (…), prove*, significant*, rich, poor, backward, laggard*, late movers, burden, wave, flood, influx, illegal, bomb, overpopulat*, success*, fail*, fills the gap, replace* (salvo "replacement fertility" definido), contagion, spread to, spillover, predicts (sin "out of sample"), Granger-causes, migration-boosted`; permitidos `is associated with, goes with, moves together with, precedes, follows, coincides with, within the same country, across countries, neighbours look alike / share / cluster, accounts for (contable), is projected to (UN medium), watch, plan, measure, prepare, monitor`. Excepciones registradas: "not proof of cause", "patterns, not causes", "because births still outnumber deaths" (contable).
- **Nombres:** *countries and areas*; nombres de la columna `Location` del WPP en texto (Türkiye, Viet Nam, Republic of Korea, State of Palestine, Kosovo (under UNSC res. 1244), China, Taiwan Province of China); banderas siempre con ISO3.
- **Reproducibilidad:** `make all`; `renv::snapshot()`; `sessionInfo()`; SHA-256 de crudos e hipótesis.

---

## 7. Definición de "terminado" por entregable

**7.1 prepare-data** — como v1 (tests verdes) **más**: OtherVariants leído con lista blanca y `stopifnot()` de monotonía; `lookup_regiones.csv` con `soberano` (195/42); constantes y paletas v2 en `config.R`; `nombrar_grupo()` v2.

**7.2 notebook-R** — `make notebook` < 15 min. Estructura: 0 Fuentes, licencia, ética y *fitness for use* · 1 Decisiones de datos · 2 Hipótesis (enlace a `docs/hipotesis_preinscritas.md` con sha256 y commit; tabla de estado) · 3 Q1 (T1–T7) · 4 Q2 (T8–T10) · 5 Q3 (T11–T12) · 6 Incertidumbre de proyecciones P2/P3 (T13–T14) · 7 Dependencia espacial (T7, *Exploratory*) · 8 Recomendaciones (T16) · 9 What we tested / How uncertain / **What we did not find** (T17) · 10 Limitaciones y consideraciones éticas · 11 Reproducibilidad. Todas las tareas de §3.1 hechas; cada IC con su método; ningún p-valor fuera de §9; cada bloque con "Lectura de resultados" con cifras reales; `numbers.json` con todas las claves de §4; listas `figures/miembros_*.csv` y `lookalikes_todos.csv`.

**7.3 figures-static** — Vídeo (12): `fig00_world_dots`, `fig01_growth_components_by_income`, `fig02_lever_map_2023`, `fig03_uae_fan_2050`, `fig04_same_road_registration`, `fig05_mortality_first_event_time`, `fig06_within_vs_across_forest`, `fig07_single_indicator_scorecard`, `fig08_lookalikes_twins` (póster), `fig09_pca_two_dimensions`, `fig10_trajectory_groups`, `fig11_divergence_fan`. Apéndice (mínimo): `app_connected_scatter_regions`, `app_coupling_across_countries`, `app_threshold_grid_lag`, `app_km_onset_income`, `app_honest_model_comparison`, `app_within_between`, `app_migration_memory`, `app_simpson_income`, `app_spatial_moran`, `app_lisa_migration`, `app_spatial_model`, `app_index_mc_ranks`, `app_sensitivity_grid_clusters`, `app_cluster_stability_by_country`, `app_atypical_curves`, `app_fan_small_multiples`, `app_direction_2050`, `app_shock_calendar`, `app_same_fertility`, `app_deaths_exceed_births`, `app_sdg32_pace`, `app_resampling_vs_choices`. Cada una: título-mensaje, subtítulo-filtro, badge, estimación/proyección, etiquetas directas, paleta v2, texto ≥ 18 px, CVD aprobado; "fotografiar y revisar" con las 4 preguntas de v1 en `figures/review/checklist.md`.

**7.4 figures-animated** — 6 MP4 (`fig01`, `fig02b` zoom, `fig04` registro, `fig07` scorecard, `fig09` PCA, `fig10` grupos) ≤ 8 MB, 30 fps, 6–12 s, + GIF + póster; movimiento que **señala**; revisión de 6 fotogramas por animación (sin saltos ni ejes que cambien).

**7.5 script-narration** — `narration_en.md` = narración del storyboard v2 (654 palabras escritas; ≤ 700); lectura cronometrada ≤ 4:50; todos los `{clave}` y `{clave.say}` resueltos (`fill_numbers.py` falla si queda alguno); frases ≤ 20 palabras; subtítulos literales; orden de recorte del storyboard §0.

**7.6 slides-revealjs** — 6 `<section>`; rótulos "Question N" + códigos P; builds y layouts del storyboard v2; sin logos de la ONU; tabla y tarjetas en HTML nativo; `numbers.js` sin errores; PDF de 6 páginas (≤ 3 visuales por página, ≥ 20 px).

**7.7 QA-stats** — reproducir cada cifra del guion y las diapositivas (`make notebook` en limpio; recalcular a mano ≥ 8 cifras clave con código independiente: 84/66/18, 70,7 %, 105/108, 22, −0,41, 13 %, 0,37, 0,67); comprobar que **cada clave narrada tiene `method`** y, si muestra intervalo, que es `"block bootstrap by subregion"` o `un_pi`/`wilson`/`km`; que cada IC se reproduce con su `seed` y `B`; que cada "between A and B" coincide con `ci_*`/`pi95_*`/`sens_*`; que ningún país nombrado contradice su tipo o grupo; que no aparece "p =", "significant" ni "range of uncertainty" junto a Low/High; aplicar la lista de verificaciones de `07_integracion_asesorias.md` §4; informe clave → plan → notebook → ✔/✘. **Bloquea la grabación** si falta un ✔.

**7.8 QA-viz** — como v1 + coherencia de la semántica de colores entre diapositivas (azul = nacimientos, naranja = defunciones, celeste = migración) y ausencia de la paleta de regiones en el vídeo.

**7.9 QA-ethics** — checklist `04_etica` §4 (G1–G18, S1–S14, N1–N18, R1–R10) con el grep v2 (§6); terminología ONU; descargo en mapas; tarjetas de ética; declaración de IA; posicionalidad (Colombia); `docs/qa_etica.csv`.

**7.10 QA-slides** — prueba del familiar no estadístico (7 preguntas de v1) + comprobar que "look-alike", "own clock", "within the same country" y "continuum" se entienden solo con la pantalla; 6 páginas; ≤ 5:00.

**7.11 video-record** — como v1.

**7.12 integrate-advice** — **terminado**: cada memo tiene filas en `07_integracion_asesorias.md`; los tres planes son coherentes (ninguna figura nueva sin retirar otra; `numbers.json` con claves nuevas; hipótesis en `hipotesis_preinscritas.md`).

**7.13 repo-ops** — README (EN/ES) con 3 preguntas + respuestas, `make all`, licencias, cita ASA, **hash de las hipótesis**, declaración de IA, "What this project is not"; commits por hito; tag `v1.0-submission`; repo público antes de enviar.

---

## 8. Makefile (targets de referencia)

```make
VENV=/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/venv-jupyter
export PATH:=$(VENV)/bin:$(PATH)
data:      ; Rscript R/01_preparar_datos.R && Rscript R/tests_datos.R
prereg:    ; sha256sum docs/hipotesis_preinscritas.md | tee docs/hipotesis_preinscritas.sha256
notebook:  data ; jupyter nbconvert --to notebook --execute --inplace notebook/analisis_wpp2024.ipynb && jupyter nbconvert --to html notebook/analisis_wpp2024.ipynb
figures:   notebook ; Rscript R/fig_estaticas.R
anim:      figures ; Rscript R/fig_animadas.R
slides:    ; cd slides && npm ci && python script/fill_numbers.py
pdf:       slides ; chromium --headless --no-sandbox --print-to-pdf=slides/export/slides.pdf --no-pdf-header-footer "file://$(PWD)/slides/index.html?print-pdf"
video:     pdf ; python video/record_slides.py && bash video/assemble.sh
qa:        ; Rscript R/qa_numbers.R && python slides/script/check_placeholders.py && grep -niE -f docs/qa_patrones.txt slides/script/narration_en.md slides/index.html ; pdfinfo slides/export/slides.pdf | grep Pages
all:       anim slides pdf qa
```

---

## 9. Calendario (22 → 30 oct) y puntos de control

| Día | Hito | Control |
|---|---|---|
| D1 jue 22 | env-setup + prepare-data ✔; asesorías integradas ✔ (planes v2) | tests verdes; commit v2 |
| D2 vie 23 | prepare-data v2 (OtherVariants, config v2); `make prereg` y commit de las hipótesis congeladas; notebook T0–T7 | hash publicado; QA-stats comprueba 84/66/18, 70,7 %, 105/108 |
| D3 sáb 24–25 | notebook T8–T18; **congelar `numbers.json` v1 (25-oct)**; figuras estáticas 1–6 | checklist de figuras |
| D4 dom 26 | figuras 7–11 + apéndice; animaciones 1–3; guion v1 cronometrado | QA-viz parcial |
| D5 lun 27 | animaciones 4–6; `index.html` v1 | PDF 6 páginas |
| D6 mar 28 | QA-stats final, QA-viz, QA-ethics, QA-slides | lista de correcciones |
| D7 mié 29 | correcciones; voz; vídeo ensamblado | ≤ 5:00; 10 fotogramas revisados |
| D8 jue 30 | README, tag, repo público, envío | antes de la hora límite |

Respuesta rápida a riesgos: animación no lista → póster PNG; `av` falla → GIF (`gifski`) o ffmpeg del venv; `sf` falla en un ajuste de fronteras → plantilla `s2` del memo espacial; guion > 4:50 → recortes del storyboard §0; una cifra de prototipo no se reproduce → sale del guion y entra en §12 del plan analítico.
