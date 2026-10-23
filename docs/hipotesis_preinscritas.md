# Hipótesis preinscritas · Pre-specified hypotheses — ASA DataQuest 2026 (UN WPP 2024)

> **Fecha de redacción / Date written:** 2026-10-22 (versión 2 del plan; agente `integrate-advice`).
> **Congelación / Freeze:** este archivo se congela **antes de la corrida final del notebook** (objetivo: antes del 25-oct-2026). Al commit que lo congela se ejecuta `make prereg` (`sha256sum docs/hipotesis_preinscritas.md > docs/hipotesis_preinscritas.sha256`) y el hash, la fecha y el commit se publican en el README, en `figures/numbers.json` (`hyp_file_sha256`, `hyp_file_date`, `hyp_file_commit`) y en la tarjeta de ética de la Slide 4. Cualquier cambio posterior se registra con fecha en `docs/addendum_plan.md` y lo afectado se etiqueta **post hoc**.
> **Regla de reporte / Reporting rule:** cada hipótesis se reporta en el notebook (sección 2 y §9 "What we did not find") **con su resultado, sea cual sea**. *Each hypothesis is reported with its result, whatever it is.*

## Honestidad sobre el estatus / Honest status statement

- **ES:** Todas estas hipótesis se formularon **después** de análisis exploratorios de los mismos datos (EDA previo del equipo y prototipos de siete asesores, 22-oct-2026). "Pre-specified" significa que el enunciado, el filtro, el estadístico y la regla de decisión quedan fijados aquí **antes de la corrida final**; **no** son confirmaciones independientes ni un pre-registro externo. Usamos dos etiquetas: **pre-specified** = la afirmación (su dirección) ya estaba en el plan v1, aunque ahora se formalice; **exploratory** = la afirmación la sugirió por primera vez un prototipo v2 sobre estos datos.
- **EN:** *All hypotheses were formulated after exploratory analyses of the same data (the team's earlier EDA and seven adviser prototypes, 22 Oct 2026). "Pre-specified" means that the statement, filter, statistic and decision rule are fixed here before the final notebook run — not independent confirmation, and not an external pre-registration. Labels: **pre-specified** = the claim (its direction) was already in plan v1, even if formalised now; **exploratory** = the claim was first suggested by a v2 prototype on these data.*

## Convenciones comunes / Common conventions

| Elemento | Regla |
|---|---|
| Datos | `WPP2024_Demographic_Indicators_Medium_csv.gz` (archivo original jul-2024) vía `data/processed/paises.parquet`; OtherVariants solo con la lista blanca de columnas válidas; ingreso **World Bank FY2027** (`wb_api_income_2026-10-22.csv`) aplicado a todos los años ("today's income groups"). |
| Universo | "237" = países y áreas con `ISO3_code` no vacío; "≥ 1 M" = `pob_1m == TRUE` (161 países con ≥ 1 000 000 habitantes en 2023). Comparaciones por ingreso sin "Not classified". |
| Periodo | Estimaciones `Time <= 2023`. Ningún estadístico usa ventanas que crucen 2023/24; los años ≥ 2024 solo se describen como "UN medium projection". |
| Semilla y réplicas | `set.seed(2026)` justo antes de cada remuestreo; bootstrap de países BCa B = 2 000 (PCA: percentil B = 1 000); intervalos en pantalla por **bootstrap por bloques de las 20 subregiones ONU** (`method: "block bootstrap by subregion"`); permutaciones B = 999 (Moran) o 300 (placebo de panel). |
| Proporciones | Wilson 95 % (`prop.test(x, n, correct = FALSE)`). |
| Tiempos hasta el evento | Kaplan–Meier con censura derecha en 2023; Turnbull cuando hay censura izquierda y derecha; log-rank para grupos. |
| Inicio de la caída sostenida | Primer año con x ≤ 0,9 · máx(x hasta ese año) que no vuelve a superarse (regla de Princeton); `NA` = no iniciado (censura derecha); máximo en 1950 = censura izquierda. |
| Familias de contraste | **F1** = H1–H14a (si se calcula p-valor: Holm, `p_adj`); **F2** = rejillas de sensibilidad (Benjamini–Hochberg al 10 % o distribución completa sin marcar); **F3** = exploratorio sin inferencia (gemelos, ejemplos de look-alikes, nombres de grupos). Cero p-valores en vídeo y diapositivas. `n_tests` por familia en `numbers.json`. |
| Estado del prototipo | ✔ = un memo de asesoría (o el integrador) lo calculó con datos reales y cumple la regla; ✘ = no la cumple; ⏳ = sin cálculo independiente. El notebook **debe** recalcular todas. |

---

## Familia F1 — afirmaciones del plan v1 (pre-specified)

### H1 · P4/P7 — Migración y crecimiento en ingreso alto
- **ES:** En los países que hoy son de ingreso alto (FY2027), la migración neta aporta más de la mitad del cambio de población 2000–2023.
- **EN:** *In today's high-income countries (World Bank FY2027), net migration accounts for more than half of population change in 2000–2023.*
- **Filtro:** 237 países y áreas; `Ingreso == "High income"` (n = 85); 2000–2023.
- **Estadístico:** Σ NetMigrations / Σ PopChange (sumas de personas). IC: bootstrap BCa de países (B = 2 000) + jackknife por país.
- **Confirma si:** estimación > 50 % **y** límite inferior del IC 95 % > 50 %. **Rechaza si:** estimación ≤ 50 %. **Parcial:** estimación > 50 % con límite inferior ≤ 50 %.
- **Sensibilidades previstas:** 2010–2023; ≥ 1 M; agregados de ingreso de la ONU; sin EE. UU.; sin Golfo; sin Rusia.
- **Estado inferencial:** pre-specified · **Prototipo:** ✔ 70,7 % [BCa 55,8; 114,0]; jackknife 64,5–81,6 [INF][03] · **Clave:** `share_mig_high_2000_2023`.

### H2 · P4 — Europa: decrecimiento natural
- **ES:** El agregado ONU "Europe" registra más defunciones que nacimientos en todos los años desde 1993 (primer año con NatChange < 0 sin volver a positivo hasta 2023) y su cambio de población 2000–2023 es positivo solo por migración neta (Σ NatChange < 0 < Σ PopChange).
- **EN:** *The UN "Europe" aggregate has had more deaths than births every year since 1993, and its 2000–2023 population change is positive only through net migration.*
- **Filtro:** agregado geográfico ONU "Europe" (filas de `agregados.parquet`); 1950–2023.
- **Estadístico:** primer año t con NatChange(t) < 0 y NatChange(s) < 0 para todo s ∈ [t, 2023]; signos de Σ NatChange y Σ PopChange 2000–2023.
- **Confirma si:** t = 1993 ± 1 y Σ NatChange < 0 < Σ PopChange. **Rechaza si:** no existe tal t o Σ PopChange ≤ 0.
- **Estado:** pre-specified · **Prototipo:** ⏳ (EDA c.68/76: 1993; migración = 207 % del crecimiento) · **Clave:** `year_europe_natneg`.

### H3 · P7 — Rezago mediano de 11 años (formulación v1)
- **ES:** Entre los países ≥ 1 M con ambos cruces observados después de 1950, el año en que Q5 < 100 ‰ precede al año en que TFR < 4 en una mediana de ~11 años, con mortalidad primero en ~80 %.
- **EN:** *Among ≥ 1 M countries with both crossings observed after 1950, under-five mortality fell below 100 per 1,000 a median of ~11 years before fertility fell below 4 (mortality first in ~80 %).*
- **Filtro / estadístico:** umbrales fijos; mediana del rezago y proporción de rezagos > 0.
- **Confirma si:** la conclusión (mediana > 0 y > 50 % mortalidad primero) se mantiene en la rejilla de umbrales Q5 ∈ {200, 150, 100, 75, 50} × TFR ∈ {5, 4, 3, 2,5}. **Rechaza si:** el signo o la mayoría cambian dentro de la rejilla.
- **Estado:** pre-specified · **Prototipo:** ✘ — medianas de −11,5 a +39,5 años; "mortalidad primero" del 16 % al 100 % según el par; la definición descarta a 72 países censurados [ST][FDA][INF]. Va a "What we did not find"; los umbrales quedan solo como sensibilidad.

### H3a · P7 — Orden: la mortalidad infantil empieza a caer primero
- **ES:** En la mayoría de los países de alta fecundidad, el inicio de la caída sostenida de Q5 precede al inicio de la caída sostenida de la TFR.
- **EN:** *In most high-fertility countries, the onset of a lasting decline in under-five mortality precedes the onset of a lasting decline in fertility.*
- **Filtro:** ≥ 1 M; TFR₁₉₅₀ ≥ 5; ingreso clasificado; inicio de Q5 observado (n ≈ 108 de 109).
- **Estadístico:** proporción de países con inicio(Q5) < inicio(TFR) (los no iniciados de TFR cuentan como "mortalidad primero" si Q5 ya inició); IC de Wilson. Cota inferior del rezago = mediana de max(inicio TFR − inicio Q5, 0) con IC bootstrap; mediana del rezago con Turnbull (si > 50 % de la masa queda más allá del último tiempo observado → "no identificable").
- **Confirma si:** límite inferior de Wilson > 50 %. **Rechaza si:** estimación ≤ 50 %.
- **Sensibilidades:** reglas −5/−10/−15 % × TFR₁₉₅₀ ≥ 5/5,5/6.
- **Estado:** pre-specified (dirección v1; definición v2) · **Prototipo:** ✔ 105/108 = 97 % [92; 99]; cota inferior 22 años [20; 25]; mediana no identificable (Q5 ya caía en 1950 en 92 de 109) [ST][INF][FDA] · **Claves:** `share_mort_first`, `lag_onset_lower_bound`.

### H4 · P7 — La migración sin persistencia (formulación v1)
- **ES:** La β-convergencia de la CNMR 1950→2023 vale ≈ −1, es decir, la migración no tiene persistencia.
- **EN:** *Net migration shows no persistence: its β-convergence slope 1950→2023 is ≈ −1.*
- **Estadístico:** β de ΔX ~ X₀ con X₀ = media 1950–54, X₁ = media 2019–23; placebo (X₁ barajado entre países).
- **Confirma si:** β difiere del placebo **y** σ₁ < σ₀. **Rechaza si:** β ≈ placebo.
- **Estado:** pre-specified · **Prototipo:** ✘ como evidencia — β ≈ −1 es exactamente el valor del ruido puro (placebo −1,00); DE 7,3 → 7,6 [ST]. Sustituida por H4a.

### H4a · P7 — La migración tiene memoria corta
- **ES:** Entre décadas consecutivas, la CNMR media por país es menos persistente que la TFR y la LEx.
- **EN:** *Between consecutive decades, country-level net migration is less persistent than fertility and life expectancy.*
- **Filtro:** ≥ 1 M; medias por década 1950s…2010s (y 2020–23).
- **Estadístico:** correlación de Pearson entre medias de décadas consecutivas (6 pares) para CNMR, TFR y LEx; % de países que mantienen el signo de la CNMR de los 2000 a los 2010.
- **Confirma si:** las 6 correlaciones de la CNMR son menores que la mínima de TFR y LEx. **Rechaza si:** alguna CNMR ≥ ese mínimo.
- **Estado:** exploratory · **Prototipo:** ✔ CNMR 0,32–0,68 (2000s→2010s 0,67) vs TFR/LEx ≥ 0,95; 76 % mantiene el signo [DEM] · **Claves:** `r_cnmr_decades_*`, `r_tfr_decades_min`.

### H5 · P7 — Acoplamiento fecundidad–migración solo en ingreso alto
- **ES:** ρ(TFR, CNMR) en 2023 es negativa (≈ −0,36) en el grupo de ingreso alto y más débil en los demás.
- **EN:** *The fertility–net migration correlation is negative (≈ −0.36) only among high-income countries.*
- **Filtro:** ≥ 1 M (regla del plan para correlaciones); 2023.
- **Estadístico:** Spearman con IC BCa por grupo de ingreso.
- **Confirma si:** IC del grupo alto < 0 y |ρ| alto > |ρ| de cada otro grupo. **Rechaza si:** IC del grupo alto contiene 0.
- **Estado:** pre-specified · **Prototipo:** ✘ — con ≥ 1 M, Spearman +0,10 [−0,20; 0,41] (Pearson +0,23); el −0,36 solo aparece con los 237 (microestados) [ST][MV].

### H6 · P8 — La fecundidad sola cuenta la historia lenta, no la rápida
- **ES:** Con 2023 y ≥ 1 M, el R² ajustado de una regresión sobre la TFR sola es ≥ 0,7 para la edad mediana y para el cambio % de población 2023→2050 (proyección), ≤ 0,6 para la tasa de crecimiento y ≤ 0,1 para la CNMR. Las cuatro salidas se declaran aquí, antes del cálculo final.
- **EN:** *Fertility alone explains ≥ 70 % of cross-country differences in median age and in projected 2023→2050 change, but ≤ 60 % of current growth and ≤ 10 % of net migration.*
- **Estadístico:** R² ajustado; IC bootstrap por bloques de subregión (pantalla) y BCa iid (notebook); VC 10-fold × 20.
- **Confirma si:** se cumplen los cuatro umbrales con la estimación puntual y la VC. **Rechaza si:** falla alguno.
- **Sensibilidades:** spline natural de 3 gl; 237 países; 1990.
- **Estado:** pre-specified · **Prototipo:** ✔ 0,773 / 0,882 / 0,592 / 0,005 (VC 0,766 / 0,879 / 0,582 / −0,023) [INF][MV] · **Claves:** `r2_tfr_*`.

### H7 · P8 — PC1 < 50 % y 3 componentes (formulación v1)
- **ES / EN:** *El primer componente del PCA de 12 indicadores captura < 50 % y hacen falta 3 para 70 % · PC1 of the 12-indicator PCA captures < 50 % and three components are needed for 70 %.*
- **Estado:** pre-specified · **Prototipo:** ✘ — PC1 56,7 % [54,7; 59,1]; 2 componentes = 74,6 % [MV][INF]. Sustituida por H7a.

### H7a · P8 — Dos dimensiones reales; la fecundidad solo ve una
- **ES:** En el PCA de los 12 indicadores fijos (`VARS_PCA`, 2023, ≥ 1 M), exactamente 2 autovalores superan el percentil 95 del análisis paralelo; |r(TFR, PC1)| > 0,9 y |r(TFR, PC2)| < 0,2.
- **EN:** *Exactly two principal components beat noise (parallel analysis); fertility is almost identical to the first and blind to the second.*
- **Estadístico:** autovalores vs p95 de 1 000 permutaciones por columna; correlaciones de Pearson.
- **Confirma si:** se cumplen las tres condiciones. **Rechaza si:** falla alguna.
- **Sensibilidades:** 1950, 1990, 2050 (proyección, descriptivo); 8 variables; sin Golfo; 237.
- **Estado:** exploratory · **Prototipo:** ✔ 2 dimensiones (6,80 / 2,15 vs 1,60 / 1,42); r = −0,945 / 0,03 [MV] · **Claves:** `n_dims_parallel`, `r_tfr_pc1`, `r_tfr_pc2`.

### H8 · P5 — 24 % de países cambian > 20 puestos (formulación v1)
- **Estado:** pre-specified · **Prototipo:** ✘ como cifra — depende de qué variantes se elijan (19,9 % con 11 variantes; 2,5 %–47 % según la incertidumbre admitida) [MV]. Sustituida por H8a.

### H8a · P5 — Los pesos deciden el ranking
- **ES:** En un Monte Carlo de 2 000 diseños del índice (5 indicadores: TFR, Q5, LEx, edad mediana, crecimiento; pesos Dirichlet(5); normalización z / min–max / rangos; agregación aritmética / geométrica; inclusión aleatoria del crecimiento), al menos el 10 % de los países ≥ 1 M tiene un intervalo 90 % de rango de más de 20 puestos, y ese porcentaje es mayor que con solo normalización y agregación variables.
- **EN:** *Across 2,000 reasonable index designs, at least 10 % of countries have a 90 % rank interval wider than 20 places, more than when only normalisation and aggregation vary.*
- **Confirma si:** ambas condiciones. **Rechaza si:** < 10 %.
- **Estado:** pre-specified (dirección v1; diseño v2) · **Prototipo:** ✔ 21,1 % vs 2,5 % [MV] · **Clave:** `share_rank_mc20`.

### H9 · P6 — Silueta ≤ 0,23 (formulación v1)
- **Estado:** pre-specified · **Prototipo:** ✘ como cifra — silueta 0,37 con k = 4 [MV][FDA]. Sustituida por H9a.

### H9a · P6 — Cuatro caminos con separación moderada y un grupo migratorio
- **ES:** k-means (k = 4, `nstart = 50`) sobre 32 rasgos (medias por década de TFR, LEx, edad mediana y CNMR winsorizada, z sobre el panel; 161 ≥ 1 M; 1950–2023) da silueta media < 0,5, Jaccard bootstrap ≥ 0,75 en cada grupo, y el grupo con mayor CNMR desaparece al quitar la CNMR (ARI con/sin CNMR < 0,7).
- **EN:** *Four trajectory groups with moderate separation (silhouette < 0.5), each stable (bootstrap Jaccard ≥ 0.75), and a migration group that dissolves without net migration.*
- **Estadístico:** silueta (distancia euclídea en los rasgos), `jacc_boot()` B = 200, ARI.
- **Confirma si:** las tres condiciones. **Rechaza si:** silueta ≥ 0,5, algún Jaccard < 0,6 o ARI ≥ 0,7.
- **Validación adicional (no decide):** FPCA (ARI ≥ 0,8 esperado), Ward/PAM, `keep_share` por país, fanny, join count (H25).
- **Estado:** pre-specified (dirección v1; regla v2) · **Prototipo:** ✔ 0,37; Jaccard 0,77–0,95; ARI sin CNMR 0,54–0,58 [MV][FDA] · **Claves:** `silhouette`, `jaccard_min`, `ari_sin_cnmr`.

### H10 · P1 — Divergencia de la edad mediana
- **ES:** La DE entre países (≥ 1 M) de la edad mediana aumenta de 1950 a 2023 y el IC bootstrap del cambio excluye 0.
- **EN:** *The cross-country standard deviation of median age rises from 1950 to 2023 (bootstrap interval of the change excludes zero).*
- **Confirma si:** Δ > 0 con IC > 0. **Rechaza si:** IC contiene 0 o Δ < 0.
- **Estado:** pre-specified · **Prototipo:** ✔ 4,7 → 9,7; Δ [4,3; 5,8] [ST][FDA] · **Claves:** `sd_medage_1950`, `sd_medage_2023`.

### H11 · P1 — LEx converge y LE60 diverge (formulación v1)
- **Estado:** pre-specified · **Prototipo:** ⏳ — reformulada con LE65 del archivo oficial (H11a); LE60 queda como robustez.

### H11a · P1 — Convergencia al nacer, divergencia en la vejez
- **ES:** De 1950 a 2023 (≥ 1 M), la DE y el CV entre países de la LEx bajan y la DE y el CV de la LE65 suben (IC bootstrap de los cambios con el signo indicado).
- **EN:** *Countries grow closer in life expectancy at birth but further apart in life expectancy at 65 (both SD and coefficient of variation).*
- **Confirma si:** los cuatro cambios con el signo previsto y su IC sin cruzar 0. **Parcial:** solo la DE. **Rechaza si:** LE65 no sube.
- **Sensibilidad:** LE60 (suplemento).
- **Estado:** pre-specified · **Prototipo:** ✔ DE (LEx 12,2 → 7,4; LE65 1,47 → 2,85) / ⏳ CV [ST][DEM] · **Claves:** `sd_lex_*`, `sd_le65_*`, `cv_*`.

### H12 · P4/P7 — 79 de 130 crecen (formulación v1)
- **Estado:** pre-specified · **Prototipo:** ✘ como cifra — 79 es el número con más nacimientos que defunciones; los que crecen son 84 [DEM][ET][INT]. Sustituida por H12a.

### H12a · P4/P7 — La mayoría de los países bajo reemplazo aún crece
- **ES:** De los países y áreas con TFR < 2,1 en 2023, la mayoría tiene PopChange > 0; se reportan por separado los que crecen con NatChange > 0 y los que crecen solo por migración neta.
- **EN:** *Most countries and areas below replacement fertility in 2023 are still growing.*
- **Filtro:** 237; 2023. **Estadístico:** conteos (censo, sin IC) con rango por umbral (2,0 / 2,2) y por NRR < 1.
- **Confirma si:** crecen > 50 % de los países bajo reemplazo con los tres criterios. **Rechaza si:** ≤ 50 % con alguno.
- **Estado:** pre-specified · **Prototipo:** ✔ 130 → 84 crecen (66 + 18) [DEM][INT] · **Claves:** `n_below_replacement_2023`, `n_below_repl_growing_2023`, `n_below_repl_natural_growth_2023`, `n_grow_only_migration_2023`.

### H13 · P8 — La tasa bruta de mortalidad cambió de significado
- **ES:** El Spearman entre países (≥ 1 M) de CDR y LEx es < −0,9 en 1950 y su IC 95 % contiene 0 en 2023.
- **EN:** *The crude death rate tracked life expectancy in 1950 (ρ < −0.9) but no longer does in 2023 (interval includes zero).*
- **Confirma si:** ambas. **Rechaza si:** el IC de 2023 excluye 0 con signo negativo.
- **Estado:** pre-specified · **Prototipo:** ✔ −0,97 [−0,98; −0,96] → 0,07 [−0,08; 0,20] [INF] · **Claves:** `rho_cdr_lex_1950`, `rho_cdr_lex_2023`.

### H14 · P7 — Calendario regional del decrecimiento natural (formulación v1)
- **ES / EN:** *Primer año con NatChange < 0: Europa 1993, Norteamérica ≈ 2040, Asia y LAC ≈ 2055 · first year of natural decrease by region.*
- **Estado:** pre-specified · **Prototipo:** ⏳ — descriptivo; los años de Norteamérica, Asia y LAC son **proyección** (no se tratan como hallazgo) [EDA c.76].

### H14a · P7 — Cada vez más países con más defunciones que nacimientos
- **ES:** El número de países y áreas con NatChange < 0 pasa de ≤ 10 en 1990 a ≥ 40 en 2023.
- **EN:** *Countries and areas with more deaths than births rose from at most 10 in 1990 to at least 40 in 2023.*
- **Confirma si:** ambas cotas. **Rechaza si:** falla alguna. (2050 se reporta como escenario.)
- **Estado:** pre-specified · **Prototipo:** ✔ 8 → 53 (28 % de la humanidad); 106 en 2050 (proyección) [DEM] · **Claves:** `n_natneg_1990`, `n_natneg_2023`, `n_natneg_2050`.

---

## Familia F1 ampliada — afirmaciones nuevas de v2 (exploratory)

### H3b · P7 — Calendario de la caída de la fecundidad por ingreso
- **ES:** El año mediano (Kaplan–Meier) de inicio de la caída sostenida de la TFR es más tardío cuanto menor es el grupo de ingreso de hoy (bajo > medio-bajo > medio-alto), y los grupos difieren (log-rank).
- **EN:** *Fertility decline began later in countries that are low-income today (Kaplan–Meier medians ordered low > lower-middle > upper-middle; log-rank).*
- **Filtro:** igual que H3a (n = 109). **Estadístico:** medianas KM con IC Brookmeyer–Crowley; log-rank de 4 grupos; Cox con el ingreso como escalón.
- **Confirma si:** orden estricto de las tres medianas y log-rank con p < 0,05 (Holm en F1). **Rechaza si:** el orden no se cumple.
- **Advertencia:** el ingreso de hoy es en parte consecuencia de la transición (causalidad inversa): descriptivo.
- **Prototipo:** ✔ 2000 [1995; 2007] · 1984 [1982; 1987] · 1970 [1968; 1975] · alto 1970; χ² = 73,4 (3 gl) [INF] · **Claves:** `yr_fert_onset_*`, `logrank_income_chisq`.

### H15 · P7 — Dentro del país vs entre países
- **ES:** En cambios quinquenales (medias 1950–54…2020–23; cambios 1975–2023; ≥ 1 M) con efectos fijos de país y periodo y EE agrupados por país, la suma de los coeficientes de Δlog Q5 con rezagos 0–20 años, convertida a "hijos por mujer asociados a la mitad de Q5", es negativa, su IC 95 % excluye 0, su magnitud es < 2/3 de la pendiente entre países (medias 1950–2023) y la estimación real queda fuera del intervalo 95 % del placebo (Q5 de otro país, 300 permutaciones).
- **EN:** *Within the same country, halving child mortality goes with fewer children over the next 20 years, but by less than two thirds of the cross-country gradient, and more than in a placebo.*
- **Confirma si:** las cuatro condiciones. **Rechaza si:** IC contiene 0 o la estimación cae dentro del placebo.
- **Se reporta siempre (no decide):** coeficiente de adelanto, sentido inverso, LOO, `split` por ingreso y región (Cochran Q, I²), 237 países, sin 2020–23. Lectura obligatoria: co-movimiento, no efecto.
- **Prototipo:** ✔ −0,41 [−0,71; −0,12] vs −1,05; placebo [−0,37; 0,36] (suma real 0,60) [PN] · **Claves:** `panel_within_halfq5`, `panel_between_halfq5`, `panel_placebo_*`.

### H16 · P7 — La migración no "rellena" el déficit natural dentro del país
- **ES:** En los países de ingreso alto sin el Golfo (n = 44), la pendiente de CNMR sobre el saldo natural del quinquenio anterior, con FE de país y periodo y EE por país, tiene un IC 95 % que contiene 0.
- **EN:** *In high-income countries (Gulf excluded), a faster fall in natural increase does not go with more net migration within the same country.*
- **Confirma si:** IC contiene 0. **Rechaza si:** IC < 0 (compensación).
- **Prototipo:** ✔ +0,01 [−0,17; 0,18]; solo con FE de país (calendario incluido) −0,16 [PN] · **Clave:** `mig_hi_within_slope`.

### H17 · P7/P1 — Mismo camino, distinto reloj
- **ES:** Alinear cada país en el año continuo del último cruce de su TFR suavizada (λ = 10) por 4 reduce al menos un 50 % la varianza media entre países en la ventana ±20 años (países con ventana completa).
- **EN:** *Aligning countries on the year their fertility last fell below 4 removes at least half of the cross-country variance within ±20 years.*
- **Confirma si:** reducción ≥ 50 % con el hito 4 y ≥ 30 % con los hitos 5 y 3. **Rechaza si:** < 50 % con el hito 4.
- **Advertencia:** solo países que cruzaron (sesgo de supervivencia; 26 no cruzan aún).
- **Prototipo:** ✔ 0,920 → 0,186 (−80 %), 57 países [FDA] · **Clave:** `pct_var_fase`.

### H18 · P1 — Quien empezó tarde no va más rápido
- **ES:** La mediana KM de años para pasar de TFR 5 a 3 de los países que cruzaron 5 después de 1990 no es menor que la de los que cruzaron 5 hasta 1990.
- **EN:** *Countries that started their fertility decline after 1990 are not moving faster from five to three children.*
- **Confirma si:** mediana (post-1990) ≥ mediana (≤ 1990). **Rechaza si:** es menor y su IC no se solapa.
- **Prototipo:** ✔ 24,1 vs 18,3–19,5 años [FDA] · **Clave:** `km_dur53_*`.

### H19 · P7 — Inercia demográfica
- **ES:** Al menos 15 países y áreas con TFR < 2,1 en 2023 crecen con NatChange > 0 y NetMigrations ≤ 0 (tipo B), y suman al menos 2 000 millones de personas.
- **EN:** *At least 15 countries and areas below replacement still grow from births exceeding deaths without net immigration, home to at least 2 billion people.*
- **Confirma si:** ambas cotas. **Rechaza si:** falla alguna. Se reporta también la variante estricta (NetMigrations < 0).
- **Prototipo:** ✔ 22 países, 2,20 mil M (estricta: 18, 2,2 mil M) [DEM][INT] · **Claves:** `n_momentum_countries`, `n_momentum_emig`, `pop_momentum_bn`.

### H20 · P8 — Un número no encuentra a tus parecidos
- **ES:** Con 2023, ≥ 1 M y 12 indicadores z, la proporción media de los 5 vecinos más cercanos (perfil completo) que se recuperan usando solo la TFR es < 25 %, y usando PC1 + PC2 es > 40 % (azar = 5/160).
- **EN:** *Using fertility alone recovers fewer than a quarter of a country's five real look-alikes; two principal components recover more than 40 %.*
- **Confirma si:** ambas. **Rechaza si:** TFR ≥ 25 % o PC1+PC2 ≤ 40 %.
- **Sensibilidades:** k = 10; 1990 / 2050; 8 variables.
- **Prototipo:** ✔ 13,2 % / 43,2 % (azar 3,1 %) [MV] · **Claves:** `knn_tfr`, `knn_pc12`, `knn_chance`.

### H21 · P7 — Paradoja tipo Simpson migración–mortalidad
- **ES:** El Spearman entre países (≥ 1 M, promedios 2021–23) de Q5 y CNMR es < −0,3 en el mundo, pero |ρ| < 0,2 dentro de cada uno de los cuatro grupos de ingreso.
- **EN:** *Worldwide, countries with higher child mortality lose more migrants, but the link vanishes within each income group.*
- **Confirma si:** ambas condiciones. **Rechaza si:** alguna |ρ| intragrupo ≥ 0,2 o la mundial ≥ −0,3.
- **Prototipo:** ✔ −0,46 [−0,59; −0,32]; intragrupo −0,07…+0,17 [MV] · **Claves:** `rho_q5_cnmr_world`, `rho_q5_cnmr_within_*`.

### H22 · P2/P3 — La dirección futura es incierta en muchos países
- **ES:** En al menos un tercio de los países ≥ 1 M, el IP 95 % de la ONU para la población de 2050 contiene la población de 2023.
- **EN:** *For at least a third of countries, the UN's 95 % range for 2050 includes both growth and decline.*
- **Confirma si:** ≥ 54 de 161. **Rechaza si:** < 54.
- **Prototipo:** ✔ 77 / 161 [INF] · **Clave:** `n_dir_uncertain_2050`.

### H23 · P7/recomendaciones — Ritmo insuficiente para el ODS 3.2
- **ES:** De los países con Q5 > 25 ‰ en 2023, menos de 1 de cada 4 tiene una tasa observada de reducción anual 2015–2023 igual o mayor que la necesaria para llegar a 25 ‰ en 2030.
- **EN:** *Fewer than one in four countries above 25 under-five deaths per 1,000 are reducing them fast enough to reach the SDG target by 2030.*
- **Confirma si:** proporción < 25 %. **Rechaza si:** ≥ 25 %.
- **Prototipo:** ✔ 8 / 70 [DEM] · **Claves:** `n_sdg32_on_pace`, `n_sdg32_above`.

### H24 · P7 — Los vecinos comparten fecundidad, no migración
- **ES:** Con W = 5 vecinos más cercanos (haversine, fila-estandarizada), ≥ 1 M, 2023: Moran I de la CNMR < 0,2 mientras los de TFR, LEx y edad mediana son > 0,6 (permutación B = 999).
- **EN:** *Neighbouring countries look alike in fertility, survival and age (Moran's I > 0.6), but barely in net migration (< 0.2).*
- **Confirma si:** las cuatro condiciones. **Rechaza si:** falla alguna. **Sensibilidades:** 4 matrices W; 237; sin Golfo; por rangos.
- **Prototipo:** ✔ CNMR 0,12 (−0,03 sin Golfo) vs 0,74 / 0,69 / 0,77 [SP] · **Claves:** `moran_*`.

### H25 · P6 — Los vecinos comparten camino
- **ES:** La proporción de enlaces vecino→vecino (kNN5) cuyos dos países están en el mismo grupo de trayectoria (H9a) es al menos 1,5 veces la esperada al azar (999 permutaciones de etiquetas) y supera el percentil 97,5 nulo.
- **EN:** *Neighbouring countries share the same 70-year road at least 1.5 times as often as chance.*
- **Confirma si:** ambas. **Rechaza si:** ≤ 1,5× o dentro de la banda nula. **Se reporta también:** acierto del voto de 5 vecinos vs mayoría regional (para no exagerar).
- **Prototipo:** ✔ 66,8 % vs 30,3 % (banda 26,5–34,4 %); voto 75 % vs región 78 % [SP] · **Claves:** `join_same_road`, `join_same_road_null`.

---

## Resumen de estado (para la sección 2 del notebook)

| ID | Estado inferencial | Prototipo | ID | Estado inferencial | Prototipo |
|---|---|---|---|---|---|
| H1 | pre-specified | ✔ | H11 | pre-specified | ⏳ → H11a |
| H2 | pre-specified | ⏳ | H11a | pre-specified | ✔ / ⏳ (CV) |
| H3 | pre-specified | ✘ | H12 | pre-specified | ✘ → H12a |
| H3a | pre-specified | ✔ | H12a | pre-specified | ✔ |
| H3b | exploratory | ✔ | H13 | pre-specified | ✔ |
| H4 | pre-specified | ✘ | H14 | pre-specified | ⏳ |
| H4a | exploratory | ✔ | H14a | pre-specified | ✔ |
| H5 | pre-specified | ✘ | H15 | exploratory | ✔ |
| H6 | pre-specified | ✔ | H16 | exploratory | ✔ |
| H7 | pre-specified | ✘ | H17 | exploratory | ✔ |
| H7a | exploratory | ✔ | H18 | exploratory | ✔ |
| H8 | pre-specified | ✘ → H8a | H19 | exploratory | ✔ |
| H8a | pre-specified | ✔ | H20 | exploratory | ✔ |
| H9 | pre-specified | ✘ → H9a | H21 | exploratory | ✔ |
| H9a | pre-specified | ✔ | H22–H25 | exploratory | ✔ |
| H10 | pre-specified | ✔ | | | |

*Lo que no se contrasta (F3, ilustración):* gemelos EAU–Bielorrusia y demás pares ("chosen by rule from 12,880 pairs"), los look-alikes concretos de Colombia, los países resaltados en las figuras, los nombres de los grupos y los países frontera. *Not tested (illustration only): twin pairs, the specific look-alikes of Colombia, highlighted countries, group names, borderline countries.*
