#!/usr/bin/env Rscript
# =============================================================================
# 04_q3_caminos.R
# Question 3 — "Same road, different speed: four roads and what the UN should
# watch" (P6 + P1 + recomendaciones). Agente notebook-Q3.
#
# Qué hace (plan analítico v2 §4-Q3, plan de implementación T11, T12, T15, T16):
#   1. Agrupa los 161 países >= 1 M por su TRAYECTORIA 1950-2023 (medias por
#      década de TFR, LEx, edad mediana y CNMR winsorizada) con k-means k = 4.
#   2. Valida los grupos: FPCA, Ward, PAM, Mclust, Jaccard bootstrap,
#      estabilidad por país (keep_share), fanny, sin CNMR, asinh, niveles 2023,
#      rejilla de sensibilidad, y contigüidad espacial (join count).
#   3. P1: divergencia entre países (DE, CV, P10-P90) de edad mediana, LEx,
#      LE65, LE60 (suplemento) y mortalidad infantil (razón P90/P10).
#   4. Proyección Medium 2024-2050 por grupo (escenario, siempre etiquetado).
#   5. Cifras del mundo, complementos demográficos y la tabla
#      "What to watch, where, when" (recomendaciones revisadas por demografía).
#
# Ejecución (desde la raíz del repo):  Rscript R/04_q3_caminos.R
#
# Decisiones (ASA 2022 B.2, B.4, C.2; plan §3):
#   * Muestra de modelos = 161 países >= 1 M (2023); conteos con los 237.
#   * Estimaciones (<= 2023) y proyección Medium (>= 2024) SIEMPRE separadas;
#     ningún estadístico usa una ventana que cruce 2023/24.
#   * CNMR winsorizada a +-3 DE del panel 161 x 1950-2023 solo para clustering.
#   * z-estandarización con media y DE de TODO el panel (no por año).
#   * k = 4 fijado a priori (H9a); la CNMR entra a priori.
#   * Semilla 2026 (Mersenne-Twister / Inversion / Rejection) justo antes de
#     cada k-means, bootstrap o permutación.
#   * Lenguaje descriptivo: grupos = caminos demográficos, no desarrollo.
#
# SALIDAS
#   figures/numbers_q3.json                — claves de Q3 (esquema v2, registrar_cifra)
#   figures/miembros_grupos.csv            — país -> grupo (lista pública)
#   figures/review/q3/q3_*.png             — gráficas rápidas de revisión (1600x900)
#   data/processed/resultados_q3_*.parquet — tablas intermedias (columnas abajo)
#
# COLUMNAS DE LAS TABLAS INTERMEDIAS
#   resultados_q3_paises.parquet (una fila por país, 161 >= 1 M):
#     ISO3_code, Location, subregion, region_sdg, ingreso, pob_2023_miles
#     grupo            camino (Early movers / Fast movers / Recent movers / Migration-led)
#     cluster_kmeans   etiqueta bruta 1-4 del k-means principal
#     silueta          silueta individual (distancia euclídea en los 32 rasgos)
#     keep_share       % de submuestras al 80 % en que el país queda en su grupo
#     fanny_max        pertenencia difusa máxima (fanny, memb.exp = 1.5)
#     grupo_fpca, grupo_ward, grupo_pam, grupo_sin_cnmr, grupo_asinh,
#     grupo_niveles_2023  particiones alternativas (etiquetas 1-4, no nombres)
#     pc1_rasgos, pc2_rasgos  coordenadas en el PCA de los 32 rasgos
#     es_medoide, es_ejemplo  país medoide / entre los 3 más poblados del grupo
#     vecinos_mismo_grupo     fracción de sus 5 vecinos más cercanos en su grupo
#     voto_vecinos            grupo mayoritario entre sus 5 vecinos
#     tfr_1950, anio_tfr4, cnmr_media_2000_23  insumos de la regla de nombres
#     q5_2023, le65_2023, le60_2023, medage_2023, medage_2050, le60_2050,
#     le65_2050, cambio_pob_2023_2050_pct  descripción externa (2050 = proyección)
#     anio_pico_pob, tipo_pico  año del máximo de población 1950-2100 y si cae
#                               en estimación, proyección o "sin pico antes de 2100"
#     y_medage30, y_medage40, anios_30_40, censura_30_40, y40_proyectado
#     c5, c4, c3, dur53, evento53  cruces (año continuo, TFR suavizada lambda = 10)
#     tipo_palanca_2023, inercia, natneg_2023, sdg32_above, sdg32_on_pace,
#     sdg32_above_2030       estado de la palanca (Q1) y ODS 3.2
#   resultados_q3_rasgos.parquet: ISO3_code + 32 rasgos z (VAR_decada)
#   resultados_q3_bandas.parquet: grupo, variable, Time, n, mediana, p10, p90, periodo_en
#   resultados_q3_dispersion.parquet: universo, variable, Time, n, media, de, cv (%),
#     p10, p25, p50, p75, p90, de_log (Q5), razon_p90p10, brecha_p90p10,
#     r2_region, r2_ingreso, periodo_en
#   resultados_q3_curvas.parquet: ISO3_code, grupo, Time, TFR, TFR_suav, tau4 (= Time - c4), periodo_en
#   resultados_q3_sensibilidad.parquet: metodo, muestra, cnmr, periodo, ari, silueta, tamanos
#   resultados_q3_vecinos.parquet: matriz W, grupo, observado, azar, banda_lo, banda_hi
#   resultados_q3_proyeccion.parquet: grupo, ventana, periodo_en, pob_inicio_bn, nat_bn, mig_bn,
#     cambio_bn, nat_pct_pob, mig_pct_pob, cambio_pct_pob, share_nat, share_mig
#   resultados_q3_recomendaciones.parquet: filas de la tabla "What to watch, where, when"
#   resultados_q3_hipotesis.parquet: id, regla, resultado, estado
#   resultados_q3_envejecimiento.parquet: grupo, n, n_censura_2100, n_inicio_proy, n_fin_proy,
#     n_izq_1950, km_mediana (años 30 -> 40, Kaplan-Meier), mediana_completos, ci_low, ci_high (bloques)
#   resultados_q3_inercia_pico.parquet: ISO3_code, anio_pico (máximo 2023-2100, UN medium), pob23,
#     pob_1m, anios_crec (= anio_pico - 2023), anio_bajo_21 (primer año TFR < 2,1), anios_desde_21
#
# Convención: código y comentarios en español; textos de figuras en inglés.
# =============================================================================

t_inicio <- Sys.time()
options(warn = 1, dplyr.summarise.inform = FALSE, width = 140)

# =============================================================================
# 0. Preparación: infraestructura común, paquetes y rutas
# =============================================================================
# Qué: carga la API compartida (datos, constantes, incertidumbre). Por qué: una
# sola fuente de verdad para muestras, paletas y registro de cifras.
suppressPackageStartupMessages(library(here))
source(here::here("R", "config.R"))
source(here::here("R", "utilidades.R"))
source(here::here("R", "comun_analisis.R"))
source(here::here("R", "incertidumbre.R"))

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(patchwork)
  library(cluster)
  library(sf)
  library(mclust)   # Mclust() busca mclustBIC() en el entorno: hay que adjuntarlo
})
# fda, fda.usc, clue, survival, sandwich, data.table, ggrepel se usan con
# `paquete::` para no enmascarar dplyr::select (fda adjunta MASS).
for (.p in c("fda", "fda.usc", "clue", "survival", "sandwich", "data.table",
             "ggrepel", "rnaturalearth", "countrycode", "scales")) {
  if (!requireNamespace(.p, quietly = TRUE)) stop("Falta el paquete ", .p, call. = FALSE)
}
suppressPackageStartupMessages(invisible(loadNamespace("fda.usc")))
rm(.p)

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(SEMILLA)

RUTA_Q3_REVIEW <- file.path(RUTA_FIG_REVIEW, "q3")
RUTA_NUMBERS_Q3 <- file.path(RUTA_FIGURAS, "numbers_q3.json")
dir.create(RUTA_Q3_REVIEW, recursive = TRUE, showWarnings = FALSE)

ANIOS_EST <- ANIO_INICIO_DATOS:ANIO_FIN_ESTIMACION          # 1950-2023
VARS_TRAY <- c("TFR", "LEx", "MedianAgePop", "CNMR")          # rasgos del clustering
NIVELES_GRUPO <- names(PALETA_GRUPOS_V2)                      # Early, Fast, Recent, Migration-led
K_GRUPOS <- 4L
B_JACCARD <- 200L                                             # plan T11
B_KEEP <- 500L                                                # plan T11 (500 x 80 %)
B_GAP <- 100L

ari <- function(a, b) mclust::adjustedRandIndex(a, b)
cat_sec <- function(...) cat("\n====", ..., "====\n")

# Frase hablada para una proporción ("two in three", "four in ten", ...).
say_fraccion <- function(p) {
  fr <- c("one in ten" = 0.1, "one in five" = 0.2, "one in four" = 0.25, "one in three" = 1 / 3,
          "four in ten" = 0.4, "half" = 0.5, "six in ten" = 0.6, "two in three" = 2 / 3,
          "three in four" = 0.75, "four in five" = 0.8, "nine in ten" = 0.9)
  names(fr)[which.min(abs(fr - p))]
}
# Nombre hablado corto de un país (para `say`; el texto en pantalla usa WPP).
ALIAS_VOZ <- c(USA = "the United States", RUS = "Russia", GBR = "the United Kingdom",
               KOR = "the Republic of Korea", PRK = "North Korea", IRN = "Iran", TUR = "Türkiye",
               VNM = "Viet Nam", COD = "DR Congo", TZA = "Tanzania", SYR = "Syria",
               ARE = "the UAE", BOL = "Bolivia", VEN = "Venezuela", LAO = "Lao PDR",
               MDA = "Moldova", PSE = "the State of Palestine", XKX = "Kosovo",
               HKG = "Hong Kong SAR", TWN = "Taiwan Province of China", SAU = "Saudi Arabia")
nombre_voz <- function(iso3) {
  out <- nombre_pais(iso3)
  out[iso3 %in% names(ALIAS_VOZ)] <- ALIAS_VOZ[iso3[iso3 %in% names(ALIAS_VOZ)]]
  out
}
unir_voz <- function(x) if (length(x) <= 1) x else paste0(paste(x[-length(x)], collapse = ", "), " and ", x[length(x)])

# =============================================================================
# 1. Datos y rasgos de trayectoria (simple: medias por década)
# =============================================================================
# Qué: panel 161 x 1950-2023 de 4 indicadores, CNMR winsorizada, z sobre el
# panel y medias por década (8 décadas x 4 = 32 rasgos). Por qué: resume 70
# años de movimiento en números comparables entre países (plan §4-Q3 R1).
cat_sec("1. Datos y rasgos")
COLS_ID_Q3 <- c("ISO3_code", "Location", "Time", "subregion", "region_sdg", "ingreso",
                "TPopulation1July")
pan161 <- paises_1m(periodo = "estimacion") |>
  dplyr::select(dplyr::all_of(COLS_ID_Q3), dplyr::all_of(VARS_TRAY)) |>
  dplyr::arrange(ISO3_code, Time)
stopifnot(nrow(pan161) == N_PAISES_1M * length(ANIOS_EST), !anyNA(pan161[VARS_TRAY]))
pan237 <- paises_todos(periodo = "estimacion") |>
  dplyr::select(dplyr::all_of(COLS_ID_Q3), dplyr::all_of(VARS_TRAY)) |>
  dplyr::arrange(ISO3_code, Time)
stopifnot(!anyNA(pan237[VARS_TRAY]))

# Transformación de la CNMR (winsor +-3 DE del panel / asinh / cruda).
transformar_cnmr <- function(x, modo = c("winsor", "asinh", "crudo")) {
  modo <- match.arg(modo)
  switch(modo,
         winsor = { m <- mean(x); s <- sd(x); pmin(pmax(x, m - 3 * s), m + 3 * s) },
         asinh = asinh(x / 5),
         crudo = x)
}
# Panel estandarizado (z con media y DE de todo el panel).
panel_z <- function(pan, vars = VARS_TRAY, modo_cnmr = "winsor") {
  p <- pan
  if ("CNMR" %in% vars) p$CNMR <- transformar_cnmr(p$CNMR, modo_cnmr)
  p |> dplyr::mutate(dplyr::across(dplyr::all_of(vars), ~ (.x - mean(.x)) / sd(.x)))
}
# Medias por periodo (décadas: 1950s ... 2010s + 2020-23; quinquenios: 15).
rasgos_desde_z <- function(pz, vars = VARS_TRAY, periodo = c("decadas", "quinquenios")) {
  periodo <- match.arg(periodo)
  pz$per <- if (periodo == "decadas") {
    ifelse(pz$Time >= 2020, "2020s", paste0(floor(pz$Time / 10) * 10, "s"))
  } else {
    q <- floor((pz$Time - 1950) / 5) * 5 + 1950
    ifelse(q >= 2020, "2020-23", paste0(q, "-", substr(q + 4, 3, 4)))
  }
  f <- pz |>
    dplyr::group_by(ISO3_code, per) |>
    dplyr::summarise(dplyr::across(dplyr::all_of(vars), mean), .groups = "drop") |>
    tidyr::pivot_wider(names_from = per, values_from = dplyr::all_of(vars), names_sep = "_") |>
    dplyr::arrange(ISO3_code)
  X <- as.matrix(f[, -1])
  rownames(X) <- f$ISO3_code
  X
}
rasgos_trayectoria <- function(pan, vars = VARS_TRAY, modo_cnmr = "winsor", periodo = "decadas") {
  rasgos_desde_z(panel_z(pan, vars, modo_cnmr), vars, periodo)
}

# Documentar a quién afecta la winsorización (plan §3 "Migración extrema").
lim_cnmr <- mean(pan161$CNMR) + c(-3, 3) * sd(pan161$CNMR)
recortes_cnmr <- pan161 |>
  dplyr::filter(CNMR < lim_cnmr[1] | CNMR > lim_cnmr[2]) |>
  dplyr::count(ISO3_code, sort = TRUE)
n_celdas_winsor <- sum(recortes_cnmr$n)
cat(sprintf("CNMR winsorizada a [%.1f; %.1f] por mil: %d país-años recortados en %d países (%s)\n",
            lim_cnmr[1], lim_cnmr[2], n_celdas_winsor, nrow(recortes_cnmr),
            paste(sprintf("%s %d", recortes_cnmr$ISO3_code, recortes_cnmr$n)[1:min(8, nrow(recortes_cnmr))],
                  collapse = ", ")))

pz161 <- panel_z(pan161)
X <- rasgos_desde_z(pz161)
stopifnot(nrow(X) == N_PAISES_1M, ncol(X) == 32, identical(rownames(X), iso_muestra_1m))
cat("Rasgos:", ncol(X), "| países:", nrow(X), "\n")
D <- dist(X)

# =============================================================================
# 2. Elección de k (simple: silueta; rico: gap, Mclust)
# =============================================================================
# Qué: compara k = 2..8 con silueta (k-means, Ward, PAM) y el estadístico gap.
# Por qué: k = 4 está fijado a priori (H9a), pero hay que declarar qué k
# "prefieren" los datos para no vender cajas donde hay un continuo.
cat_sec("2. Elección de k")
km_fit <- function(X, k, nstart = NSTART_KMEANS) {
  set.seed(SEMILLA)
  stats::kmeans(X, k, nstart = nstart, iter.max = 100)
}
sil_media <- function(cl, Dm) mean(cluster::silhouette(as.integer(cl), Dm)[, 3])
arbol_ward <- stats::hclust(D, method = "ward.D2")
tabla_k <- purrr::map_dfr(2:8, function(k) {
  km <- km_fit(X, k)
  wd <- stats::cutree(arbol_ward, k)
  pm <- cluster::pam(D, k, diss = TRUE)
  tibble::tibble(k = k, sil_kmeans = sil_media(km$cluster, D), sil_ward = sil_media(wd, D),
                 sil_pam = pm$silinfo$avg.width, ari_km_ward = ari(km$cluster, wd),
                 ari_km_pam = ari(km$cluster, pm$clustering), tam_min = min(table(km$cluster)))
})
print(tabla_k |> dplyr::mutate(dplyr::across(-c(k, tam_min), ~ round(.x, 3))))
set.seed(SEMILLA)
gap <- cluster::clusGap(X, FUNcluster = function(x, k) list(cluster = stats::kmeans(x, k, nstart = 20, iter.max = 100)$cluster),
                        K.max = 8, B = B_GAP, verbose = FALSE)
k_gap <- cluster::maxSE(gap$Tab[, "gap"], gap$Tab[, "SE.sim"], method = "Tibs2001SEmax")
k_sil <- tabla_k$k[which.max(tabla_k$sil_kmeans)]
pX <- stats::prcomp(X)
var_pcs_rasgos <- pX$sdev^2 / sum(pX$sdev^2)
mc <- mclust::Mclust(pX$x[, 1:4], G = 1:8, verbose = FALSE)
cat(sprintf("Silueta máxima en k = %d (%.3f); gap (1-SE de Tibshirani) elige k = %d; Mclust (BIC, 4 PCs) G = %d\n",
            k_sil, max(tabla_k$sil_kmeans), k_gap, mc$G))

# =============================================================================
# 3. Partición principal (k-means, k = 4) y nombres por regla
# =============================================================================
# Qué: k-means k = 4, nstart = 50, semilla 2026; nombres con nombrar_grupo_v2()
# (CNMR mediana 2000-23, año mediano de TFR < 4, mayoría < 4 en 1950). Por
# qué: los nombres salen de una regla escrita, no de mirar el resultado.
cat_sec("3. Partición k = 4 y nombres")
km4 <- km_fit(X, K_GRUPOS)
cl_num <- stats::setNames(as.integer(km4$cluster), rownames(X))
sil_k4 <- sil_media(cl_num, D)

insumos_regla <- pan161 |>
  dplyr::group_by(ISO3_code) |>
  dplyr::arrange(Time, .by_group = TRUE) |>
  dplyr::summarise(tfr_1950 = TFR[1],
                   anio_tfr4 = { t <- Time[TFR < 4]; if (length(t)) min(t) else Inf },
                   cnmr_media_2000_23 = mean(CNMR[Time >= 2000]), .groups = "drop") |>
  dplyr::mutate(cluster_kmeans = cl_num[ISO3_code])
regla_grupos <- insumos_regla |>
  dplyr::group_by(cluster_kmeans) |>
  dplyr::summarise(n = dplyr::n(), cnmr_mediana_2000_23 = median(cnmr_media_2000_23),
                   anio_mediano_tfr4 = median(anio_tfr4),
                   mayoria_bajo4_1950 = mean(tfr_1950 < 4) > 0.5, .groups = "drop") |>
  dplyr::mutate(anio_mediano_tfr4 = ifelse(is.finite(anio_mediano_tfr4), anio_mediano_tfr4, NA_real_))
regla_grupos$nombre <- purrr::pmap_chr(
  list(regla_grupos$cnmr_mediana_2000_23, regla_grupos$anio_mediano_tfr4, regla_grupos$mayoria_bajo4_1950),
  function(a, b, c) nombrar_grupo_v2(a, b, c))
print(regla_grupos)
if (anyDuplicated(regla_grupos$nombre) || !all(regla_grupos$nombre %in% NIVELES_GRUPO)) {
  stop("La regla v2 de nombres no da 4 nombres distintos: revisar (no se inventan nombres a mano).", call. = FALSE)
}
mapa_nombres <- stats::setNames(regla_grupos$nombre, regla_grupos$cluster_kmeans)
grupo <- factor(unname(mapa_nombres[as.character(cl_num)]), levels = NIVELES_GRUPO)
names(grupo) <- names(cl_num)
tam_grupos <- table(grupo)
print(tam_grupos)
cat(sprintf("Silueta media k = 4: %.3f | India en: %s\n", sil_k4, as.character(grupo["IND"])))

# =============================================================================
# 4. Descripción de los grupos con variables externas (sin p-valores)
# =============================================================================
# Qué: tamaños, población, 3 más poblados, medoide y medianas de variables que
# NO definieron los grupos (Q5, LE65, LE60, cambio 2023-2050, edad mediana
# 2050). Por qué: evitar el ANOVA circular (ganadores §7.3) y describir con
# lo que el clustering no vio.
cat_sec("4. Descripción de los grupos")
le60_sup <- readr::read_csv(RUTA_WPP_SUPLEMENTO, show_col_types = FALSE) |>
  dplyr::filter(!is.na(ISO3_code)) |>
  dplyr::select(ISO3_code, Time, LE60)
pan_todo161 <- paises_1m() |>
  dplyr::select(ISO3_code, Location, Time, subregion, region_sdg, ingreso, TPopulation1July,
                TFR, LEx, LE65, MedianAgePop, CNMR, Q5, NatChange, NetMigrations, PopChange,
                periodo_en) |>
  dplyr::left_join(le60_sup, by = c("ISO3_code", "Time")) |>
  dplyr::mutate(grupo = grupo[ISO3_code])
stopifnot(!anyNA(pan_todo161$LE60), !anyNA(pan_todo161$grupo))

valor_anio <- function(df, var, anio) {
  out <- df |> dplyr::filter(Time == anio) |> dplyr::select(ISO3_code, v = dplyr::all_of(var))
  stats::setNames(out$v, out$ISO3_code)
}
paises_q3 <- corte_anio(ANIO_BASE, "1m") |>
  dplyr::select(ISO3_code, Location, subregion, region_sdg, ingreso, pob_2023_miles,
                pop2023 = TPopulation1July, q5_2023 = Q5, le65_2023 = LE65, medage_2023 = MedianAgePop,
                tfr_2023 = TFR, lex_2023 = LEx) |>
  dplyr::arrange(ISO3_code) |>
  dplyr::mutate(grupo = grupo[ISO3_code], cluster_kmeans = cl_num[ISO3_code])
paises_q3 <- paises_q3 |>
  dplyr::mutate(le60_2023 = valor_anio(pan_todo161, "LE60", 2023)[ISO3_code],
                medage_2050 = valor_anio(pan_todo161, "MedianAgePop", 2050)[ISO3_code],
                le60_2050 = valor_anio(pan_todo161, "LE60", 2050)[ISO3_code],
                le65_2050 = valor_anio(pan_todo161, "LE65", 2050)[ISO3_code],
                pop2050 = valor_anio(pan_todo161, "TPopulation1July", 2050)[ISO3_code],
                cambio_pob_2023_2050_pct = 100 * (pop2050 / pop2023 - 1)) |>
  dplyr::left_join(insumos_regla |> dplyr::select(-cluster_kmeans), by = "ISO3_code")

pob_mundo_2023 <- sum(corte_anio(ANIO_BASE, "completa")$TPopulation1July)   # miles, 237
# 3 más poblados (regla del plan §4) y medoide (más cercano a la mediana del grupo).
ejemplos_iso <- lapply(stats::setNames(NIVELES_GRUPO, NIVELES_GRUPO), function(g) {
  paises_q3 |> dplyr::filter(grupo == g) |> dplyr::arrange(dplyr::desc(pop2023)) |>
    dplyr::slice_head(n = 3) |> dplyr::pull(ISO3_code)
})
medoides_iso <- vapply(NIVELES_GRUPO, function(g) {
  Xi <- X[names(grupo)[grupo == g], , drop = FALSE]
  c0 <- apply(Xi, 2, median)
  rownames(Xi)[which.min(rowSums(sweep(Xi, 2, c0)^2))]
}, character(1))
desc_grupos <- paises_q3 |>
  dplyr::group_by(grupo) |>
  dplyr::summarise(n = dplyr::n(), pop_bn = sum(pop2023) / 1e6,
                   pct_pob_mundo = 100 * sum(pop2023) / pob_mundo_2023,
                   q5_2023 = median(q5_2023), le65_2023 = median(le65_2023), le60_2023 = median(le60_2023),
                   cambio_pob_2023_2050_pct = median(cambio_pob_2023_2050_pct),
                   medage_2023 = median(medage_2023), medage_2050 = median(medage_2050),
                   le60_2050 = median(le60_2050), tfr_1950 = median(tfr_1950), tfr_2023 = median(tfr_2023),
                   cnmr_2000_23 = median(cnmr_media_2000_23), .groups = "drop") |>
  dplyr::mutate(ejemplos = vapply(as.character(grupo), function(g) paste(ejemplos_iso[[g]], collapse = ", "), ""),
                medoide = medoides_iso[as.character(grupo)])
print(desc_grupos |> dplyr::mutate(dplyr::across(where(is.double), ~ round(.x, 2))), width = 200)
cat("\nComposición por región SDG:\n"); print(table(paises_q3$region_sdg, paises_q3$grupo))
cat("\nComposición por ingreso (FY2027):\n"); print(table(paises_q3$ingreso, paises_q3$grupo))
v_cramer <- function(a, b) {
  t <- table(a, b)
  chi <- suppressWarnings(stats::chisq.test(t, correct = FALSE)$statistic)
  as.numeric(sqrt(chi / (sum(t) * (min(dim(t)) - 1))))
}
ok_ing <- paises_q3$ingreso != "Not classified"
cramer_ingreso <- v_cramer(paises_q3$grupo[ok_ing], droplevels(paises_q3$ingreso[ok_ing]))
cramer_region <- v_cramer(paises_q3$grupo, paises_q3$region_sdg)
cat(sprintf("V de Cramér (descriptiva) grupo~ingreso %.2f, grupo~región %.2f\n", cramer_ingreso, cramer_region))

# Bandas por grupo (mediana y P10-P90 por año) para las figuras (1950-2100).
bandas_grupo <- pan_todo161 |>
  tidyr::pivot_longer(c(TFR, LEx, MedianAgePop, CNMR, Q5, LE65, LE60), names_to = "variable", values_to = "valor") |>
  dplyr::group_by(grupo, variable, Time) |>
  dplyr::summarise(n = dplyr::n(), mediana = median(valor), p10 = stats::quantile(valor, 0.1),
                   p90 = stats::quantile(valor, 0.9), .groups = "drop") |>
  dplyr::mutate(periodo_en = etiqueta_periodo(Time))

# =============================================================================
# 5. Validación de los grupos (simple -> rico)
# =============================================================================
cat_sec("5. Validación")

# --- 5.1 FPCA multivariada + k-means (rico) ----------------------------------
# Qué: curvas B-spline (lambda = 10) de las 4 variables z, FPCA multivariada y
# k-means sobre los scores con >= 90 % de varianza. Por qué: comprobar que los
# grupos no dependen de resumir por décadas (memo FDA: ARI 0,96).
matrices_panel_z <- function(pz, vars = VARS_TRAY) {
  anios <- sort(unique(pz$Time)); isos <- sort(unique(pz$ISO3_code))
  Y <- array(NA_real_, c(length(anios), length(isos), length(vars)), dimnames = list(anios, isos, vars))
  for (v in vars) {
    w <- pz |> dplyr::select(ISO3_code, Time, dplyr::all_of(v)) |>
      tidyr::pivot_wider(names_from = ISO3_code, values_from = dplyr::all_of(v)) |> dplyr::arrange(Time)
    Y[, , v] <- as.matrix(w[, isos])
  }
  Y
}
cluster_fpca <- function(Y, lambda = LAMBDA_FDA, k = K_GRUPOS, umbral = 0.9, nharm = 8) {
  anios <- as.numeric(dimnames(Y)[[1]])
  base <- fda::create.bspline.basis(range(anios), nbasis = length(anios) + 2, norder = 4)
  fdobj <- fda::smooth.basis(anios, Y, fda::fdPar(base, 2, lambda))$fd
  pc <- fda::pca.fd(fdobj, nharm = nharm, centerfns = TRUE)
  SC <- if (length(dim(pc$scores)) == 3) apply(pc$scores, c(1, 2), sum) else pc$scores
  rownames(SC) <- dimnames(Y)[[2]]
  K <- which(cumsum(pc$varprop) >= umbral)[1]
  list(cl = stats::setNames(as.integer(km_fit(SC[, 1:K, drop = FALSE], k)$cluster), rownames(SC)),
       K = K, varprop = pc$varprop, SC = SC)
}
Y161 <- matrices_panel_z(pz161)
fpca <- cluster_fpca(Y161)
ari_fpca <- ari(fpca$cl, cl_num)
ari_fpca_lambda <- c(`1` = ari(cluster_fpca(Y161, lambda = 1)$cl, cl_num),
                     `100` = ari(cluster_fpca(Y161, lambda = 100)$cl, cl_num))
sil_fpca_l2 <- sil_media(fpca$cl, D)
cat(sprintf("FPCA: K = %d componentes (%.1f %% acumulado; FPC1 %.1f %%), ARI con décadas %.3f (lambda 1: %.3f; 100: %.3f)\n",
            fpca$K, 100 * sum(fpca$varprop[1:fpca$K]), 100 * fpca$varprop[1], ari_fpca,
            ari_fpca_lambda[1], ari_fpca_lambda[2]))
print(table(decadas = grupo, fpca = fpca$cl))

# --- 5.2 Otros algoritmos (Ward, PAM, Mclust) --------------------------------
# Qué: misma k con otros algoritmos. Por qué: si el resultado fuera artefacto
# de k-means, cambiaría mucho de método.
cl_ward <- stats::setNames(as.integer(stats::cutree(arbol_ward, K_GRUPOS)), rownames(X))
cl_pam <- stats::setNames(as.integer(cluster::pam(D, K_GRUPOS, diss = TRUE)$clustering), rownames(X))
ari_ward <- ari(cl_ward, cl_num); ari_pam <- ari(cl_pam, cl_num)
ari_mclust <- ari(mc$classification, cl_num)
cat(sprintf("ARI k-means vs Ward %.3f | vs PAM %.3f | vs Mclust (G = %d) %.3f\n", ari_ward, ari_pam, mc$G, ari_mclust))

# --- 5.3 Estabilidad bootstrap por grupo (Jaccard, Hennig 2007) --------------
# Qué: remuestrear países con reemplazo (B = 200), re-agrupar y medir el
# Jaccard máximo de cada grupo original. Por qué: > 0,75 = grupo estable.
jacc_boot <- function(X, ref, k = K_GRUPOS, B = B_JACCARD, metodo = c("kmeans", "ward"), nstart = 20) {
  metodo <- match.arg(metodo)
  set.seed(SEMILLA)
  n <- nrow(X); J <- matrix(NA_real_, B, k)
  for (b in seq_len(B)) {
    idx <- sample.int(n, n, replace = TRUE); u <- unique(idx)
    clb <- if (metodo == "kmeans") stats::kmeans(X[idx, , drop = FALSE], k, nstart = nstart, iter.max = 100)$cluster
           else stats::cutree(stats::hclust(stats::dist(X[idx, , drop = FALSE]), "ward.D2"), k)
    clb_u <- clb[match(u, idx)]
    for (g in seq_len(k)) {
      A <- u[ref[u] == g]
      if (!length(A)) next
      J[b, g] <- max(vapply(seq_len(k), function(h) {
        Bh <- u[clb_u == h]; length(intersect(A, Bh)) / length(union(A, Bh))
      }, numeric(1)))
    }
  }
  colMeans(J, na.rm = TRUE)
}
jacc_km <- jacc_boot(X, cl_num)
jaccard_grupo <- stats::setNames(jacc_km[as.integer(names(mapa_nombres))], mapa_nombres)[NIVELES_GRUPO]
jacc_ward <- jacc_boot(X, cl_ward, metodo = "ward")
cat("Jaccard bootstrap (k-means, B = 200):", paste(sprintf("%s %.2f", names(jaccard_grupo), jaccard_grupo), collapse = " | "), "\n")
cat("Jaccard bootstrap Ward:", paste(round(jacc_ward, 2), collapse = " / "), "\n")

# --- 5.4 Estabilidad por país (keep_share, submuestras al 80 %) --------------
# Qué: 500 submuestras sin reemplazo del 80 %, k-means, emparejar etiquetas con
# el algoritmo húngaro (clue::solve_LSAP) y contar cuántas veces cada país
# queda en su grupo. Por qué: marcar en el mapa los países frontera.
keep_share_sub <- function(X, ref, k = K_GRUPOS, B = B_KEEP, frac = 0.8, nstart = 20) {
  set.seed(SEMILLA)
  n <- nrow(X); m <- round(frac * n)
  incl <- keep <- numeric(n); sil <- numeric(B); tam_mig <- integer(B)
  g_mig <- as.integer(names(mapa_nombres)[mapa_nombres == "Migration-led"])
  for (b in seq_len(B)) {
    s <- sort(sample.int(n, m))
    kb <- stats::kmeans(X[s, , drop = FALSE], k, nstart = nstart, iter.max = 100)$cluster
    tab <- unclass(table(factor(ref[s], levels = seq_len(k)), factor(kb, levels = seq_len(k))))
    asig <- as.integer(clue::solve_LSAP(tab, maximum = TRUE))      # fila (ref) -> columna (nuevo)
    nuevo_a_ref <- integer(k); nuevo_a_ref[asig] <- seq_len(k)
    kb_ref <- nuevo_a_ref[kb]
    incl[s] <- incl[s] + 1
    keep[s] <- keep[s] + (kb_ref == ref[s])
    sil[b] <- mean(cluster::silhouette(kb, stats::dist(X[s, , drop = FALSE]))[, 3])
    tam_mig[b] <- sum(kb_ref == g_mig)
  }
  list(keep_share = stats::setNames(keep / incl, rownames(X)), sil = sil, tam_mig = tam_mig, n_incl = incl)
}
ks <- keep_share_sub(X, cl_num)
ks70 <- keep_share_sub(X, cl_num, B = 200, frac = 0.7)
ks90 <- keep_share_sub(X, cl_num, B = 200, frac = 0.9)
share_keep <- mean(ks$keep_share >= 0.8)
share_keep_sens <- c(`70%` = mean(ks70$keep_share >= 0.8), `90%` = mean(ks90$keep_share >= 0.8))
sil_sub_ic <- stats::quantile(ks$sil, c(0.025, 0.975))
iso_frontera <- names(sort(ks$keep_share[ks$keep_share < 0.8]))
cat(sprintf("keep_share >= 0,8: %.1f %% de los países (70 %%: %.1f; 90 %%: %.1f). Países frontera (%d): %s\n",
            100 * share_keep, 100 * share_keep_sens[1], 100 * share_keep_sens[2], length(iso_frontera),
            paste(iso_frontera, collapse = ", ")))
cat(sprintf("Silueta en submuestras al 80 %%: P2.5-P97.5 = %.3f-%.3f\n", sil_sub_ic[1], sil_sub_ic[2]))

# --- 5.5 Pertenencia difusa (fanny) y silueta individual ----------------------
# Qué: grado de pertenencia de cada país a los 4 grupos. Por qué: cuantificar
# "un continuo, no cajas" (países que se reparten entre dos caminos).
fz <- cluster::fanny(X, K_GRUPOS, memb.exp = 1.5, maxit = 1000)
fanny_max <- stats::setNames(apply(fz$membership, 1, max), rownames(X))
share_entre <- mean(fanny_max < 0.6)
share_entre_sens <- c(`0.5` = mean(fanny_max < 0.5), `0.7` = mean(fanny_max < 0.7))
sil_ind <- stats::setNames(cluster::silhouette(cl_num, D)[, 3], rownames(X))
r2_eje1 <- summary(stats::lm(pX$x[, 1] ~ grupo))$r.squared
cat(sprintf("fanny: %.1f %% con pertenencia máx. < 0,6 (umbral 0,5: %.1f; 0,7: %.1f) | ARI fanny vs k-means %.3f\n",
            100 * share_entre, 100 * share_entre_sens[1], 100 * share_entre_sens[2], ari(fz$clustering, cl_num)))
cat(sprintf("Silueta < 0,1: %.1f %% | negativas: %d (%s) | PC1 de rasgos = %.1f %% de la varianza; grupos explican %.1f %% de PC1\n",
            100 * mean(sil_ind < 0.1), sum(sil_ind < 0), paste(names(sil_ind)[sil_ind < 0], collapse = ", "),
            100 * var_pcs_rasgos[1], 100 * r2_eje1))

# --- 5.6 Sin CNMR, asinh, sin winsorizar (decisión sobre la migración) -------
# Qué: repetir sin la migración y con otras transformaciones. Por qué: H9a
# prevé que el grupo migratorio se disuelva sin CNMR (ARI < 0,7).
X_sin <- X[, !grepl("^CNMR_", colnames(X))]
km_sin <- km_fit(X_sin, K_GRUPOS)
cl_sin <- stats::setNames(as.integer(km_sin$cluster), rownames(X))
ari_sin <- ari(cl_sin, cl_num)
sil_sin <- sil_media(cl_sin, stats::dist(X_sin))
mig_iso <- names(grupo)[grupo == "Migration-led"]
jacc_mig_sin <- max(vapply(1:K_GRUPOS, function(h) {
  B0 <- names(cl_sin)[cl_sin == h]; length(intersect(mig_iso, B0)) / length(union(mig_iso, B0))
}, numeric(1)))
caida_tfr <- X_sin[, "TFR_1960s"] - X_sin[, "TFR_2000s"]     # caída de la TFR (z) 1960s -> 2000s
g_sprint <- names(which.max(tapply(caida_tfr, cl_sin, median)))
cat(sprintf("Sin CNMR: ARI %.3f, silueta %.3f, tamaños %s; Jaccard máx. del grupo Migration-led %.2f\n",
            ari_sin, sil_sin, paste(table(cl_sin), collapse = "/"), jacc_mig_sin))
cat("  ¿A dónde van los Migration-led sin CNMR? ->", paste(sprintf("%s:%d", mig_iso, cl_sin[mig_iso]), collapse = " "), "\n")
cat("  Grupo 'Sprinters' (mayor caída de TFR 1960s->2000s, solo esta sensibilidad):", g_sprint,
    "-", paste(names(cl_sin)[cl_sin == as.integer(g_sprint)], collapse = " "), "\n")
print(table(con_cnmr = grupo, sin_cnmr = cl_sin))

X_as <- rasgos_trayectoria(pan161, modo_cnmr = "asinh")
cl_as <- stats::setNames(as.integer(km_fit(X_as, K_GRUPOS)$cluster), rownames(X))
X_crudo <- rasgos_trayectoria(pan161, modo_cnmr = "crudo")
cl_crudo <- stats::setNames(as.integer(km_fit(X_crudo, K_GRUPOS)$cluster), rownames(X))
ari_as <- ari(cl_as, cl_num); ari_crudo <- ari(cl_crudo, cl_num)
peq <- function(cl) { g <- as.integer(names(which.min(table(cl)))); names(cl)[cl == g] }
cat(sprintf("asinh(CNMR/5): ARI %.3f (grupo menor: %s) | sin winsorizar: ARI %.3f (grupo menor: %s)\n",
            ari_as, paste(peq(cl_as), collapse = " "), ari_crudo, paste(peq(cl_crudo), collapse = " ")))

# --- 5.7 Trayectorias vs niveles de 2023 -------------------------------------
# Qué: agrupar solo con los niveles de 2023. Por qué: mostrar cuánto cambia la
# clasificación al mirar 70 años en vez de una foto (plan: ARI 0,59-0,64).
c23 <- corte_anio(ANIO_BASE, "1m", vars = VARS_TRAY) |> dplyr::arrange(ISO3_code)
c23$CNMR <- transformar_cnmr(c23$CNMR, "winsor")
X23 <- scale(as.matrix(c23[, VARS_TRAY])); rownames(X23) <- c23$ISO3_code
cl_niv <- stats::setNames(as.integer(km_fit(X23, K_GRUPOS)$cluster), rownames(X23))
X23p <- pz161 |> dplyr::filter(Time == ANIO_BASE) |> dplyr::arrange(ISO3_code)
X23p <- as.matrix(X23p[, VARS_TRAY]); rownames(X23p) <- iso_muestra_1m
cl_niv_p <- stats::setNames(as.integer(km_fit(X23p, K_GRUPOS)$cluster), rownames(X23p))
ari_niv <- ari(cl_niv[names(cl_num)], cl_num)
ari_niv_p <- ari(cl_niv_p[names(cl_num)], cl_num)
cat(sprintf("ARI trayectorias vs niveles 2023: %.3f (z transversal) / %.3f (z del panel)\n", ari_niv, ari_niv_p))

# --- 5.8 Rejilla de sensibilidad {método} x {161, 237} x {con/sin CNMR} x {décadas, quinquenios}
# Qué: 32 combinaciones; ARI con la partición principal sobre los 161. Por
# qué: una sola figura que muestre qué decisiones mueven los grupos.
cache_X <- list(); cache_fpca <- list()
for (mu in c("161", "237")) for (cn in c("with", "without")) {
  pan_mu <- if (mu == "161") pan161 else pan237
  vars_mu <- if (cn == "with") VARS_TRAY else setdiff(VARS_TRAY, "CNMR")
  pz_mu <- panel_z(pan_mu, vars_mu)
  for (pe in c("decades", "5-year")) {
    cache_X[[paste(mu, cn, pe)]] <- rasgos_desde_z(pz_mu, vars_mu, if (pe == "decades") "decadas" else "quinquenios")
  }
  cache_fpca[[paste(mu, cn)]] <- cluster_fpca(matrices_panel_z(pz_mu, vars_mu))$cl
}
rejilla <- expand.grid(metodo = c("k-means", "Ward", "PAM", "FPCA"), muestra = c("161", "237"),
                       cnmr = c("with", "without"), periodo = c("decades", "5-year"), stringsAsFactors = FALSE)
rejilla$ari <- NA_real_; rejilla$silueta <- NA_real_; rejilla$tamanos <- NA_character_
for (i in seq_len(nrow(rejilla))) {
  r <- rejilla[i, ]
  Xi <- cache_X[[paste(r$muestra, r$cnmr, r$periodo)]]
  Di <- stats::dist(Xi)
  cl <- switch(r$metodo,
               `k-means` = km_fit(Xi, K_GRUPOS)$cluster,
               Ward = stats::cutree(stats::hclust(Di, "ward.D2"), K_GRUPOS),
               PAM = cluster::pam(Di, K_GRUPOS, diss = TRUE)$clustering,
               FPCA = cache_fpca[[paste(r$muestra, r$cnmr)]][rownames(Xi)])
  names(cl) <- rownames(Xi)
  rejilla$ari[i] <- ari(cl[names(cl_num)], cl_num)
  rejilla$silueta[i] <- sil_media(cl, Di)
  rejilla$tamanos[i] <- paste(sort(as.integer(table(cl[names(cl_num)])), decreasing = TRUE), collapse = "/")
}
rejilla$periodo[rejilla$metodo == "FPCA"] <- paste(rejilla$periodo[rejilla$metodo == "FPCA"], "(FPCA uses annual curves)")
print(rejilla |> dplyr::mutate(dplyr::across(c(ari, silueta), ~ round(.x, 2))))

# --- 5.9 Clustering por velocidades (intento descartado; solo notebook) -----
# Qué: k-means k = 4 sobre las DERIVADAS anuales de las curvas suavizadas
# (lambda = 10) de las 4 variables z: cuánto se movió cada país cada año, no
# dónde estaba. Por qué: responde literalmente "cómo se movieron"; el plan lo
# deja en el notebook porque el memo FDA lo halló inestable (silueta 0,20).
anios_v <- as.numeric(dimnames(Y161)[[1]])
base_v <- fda::create.bspline.basis(range(anios_v), nbasis = length(anios_v) + 2, norder = 4)
fd_v <- fda::smooth.basis(anios_v, Y161, fda::fdPar(base_v, 2, LAMBDA_FDA))$fd
dV <- fda::eval.fd(anios_v, fd_v, Lfdobj = 1)                      # años x países x variables
Xv <- do.call(cbind, lapply(seq_len(dim(dV)[3]), function(j) t(dV[, , j])))
rownames(Xv) <- dimnames(Y161)[[2]]
stopifnot(identical(rownames(Xv), names(cl_num)))
km_v <- km_fit(Xv, K_GRUPOS)
cl_v <- stats::setNames(as.integer(km_v$cluster), rownames(Xv))
sil_v <- sil_media(cl_v, stats::dist(Xv))
ari_v <- ari(cl_v, cl_num)
jacc_v <- jacc_boot(Xv, cl_v)
tam_v <- sort(as.integer(table(cl_v)), decreasing = TRUE)
grupos_v_peq <- names(which(table(cl_v) < 20))
miembros_v_peq <- vapply(grupos_v_peq, function(h) paste(names(cl_v)[cl_v == as.integer(h)], collapse = " "), "")
cat(sprintf("Velocidades (derivadas, %d columnas): silueta %.3f, ARI con la partición principal %.3f, tamaños %s, Jaccard bootstrap %s\n",
            ncol(Xv), sil_v, ari_v, paste(tam_v, collapse = "/"), paste(sprintf("%.2f", jacc_v), collapse = " / ")))
cat("  Grupos pequeños de velocidad (< 20 países):", paste(sprintf("[%s]", miembros_v_peq), collapse = " "), "\n")

# =============================================================================
# 6. Contigüidad espacial de los caminos (join count y voto de vecinos)
# =============================================================================
# Qué: ¿los vecinos comparten camino más que al azar? W = 5 vecinos más
# cercanos (haversine entre puntos de etiqueta de Natural Earth); 999
# permutaciones de etiquetas. Por qué: validación externa NO circular (la
# geografía no entró en el clustering), H25.
cat_sec("6. Contigüidad espacial")
mundo_ne <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
mundo_ne$iso3 <- ifelse(mundo_ne$iso_a3_eh != "-99", mundo_ne$iso_a3_eh, mundo_ne$adm0_a3)
RECOD_NE <- c(KOS = "XKX", SOL = "SOM", CYN = "CYP", ALA = "FIN")   # códigos WPP (memo espacial)
mundo_ne$iso3 <- ifelse(mundo_ne$iso3 %in% names(RECOD_NE), unname(RECOD_NE[mundo_ne$iso3]), mundo_ne$iso3)
mundo_ne$area_km2 <- as.numeric(sf::st_area(mundo_ne)) / 1e6
# Punto representativo: "label point" de la pieza de mayor área de cada ISO3.
puntos <- mundo_ne |> sf::st_drop_geometry() |>
  dplyr::filter(iso3 %in% iso_muestra_1m) |>
  dplyr::group_by(iso3) |> dplyr::slice_max(area_km2, n = 1, with_ties = FALSE) |> dplyr::ungroup() |>
  dplyr::select(iso3, lon = label_x, lat = label_y) |> dplyr::arrange(iso3)
stopifnot(identical(puntos$iso3, iso_muestra_1m))
haversine <- function(lon, lat) {
  rad <- pi / 180; la <- lat * rad; lo <- lon * rad
  a <- sin(outer(la, la, "-") / 2)^2 + outer(cos(la), cos(la)) * sin(outer(lo, lo, "-") / 2)^2
  2 * 6371.0088 * asin(pmin(sqrt(a), 1))
}
Dkm <- haversine(puntos$lon, puntos$lat); dimnames(Dkm) <- list(puntos$iso3, puntos$iso3)
W_knn <- function(Dm, k = K_VECINOS) {
  diag(Dm) <- Inf
  W <- t(apply(Dm, 1, function(r) { w <- numeric(length(r)); w[order(r)[1:k]] <- 1 / k; w }))
  dimnames(W) <- dimnames(Dm); W
}
W_idw <- function(Dm, corte = 2000) {
  W <- ifelse(Dm > 0 & Dm <= corte, 1 / Dm, 0)
  Dd <- Dm; diag(Dd) <- Inf
  for (i in which(rowSums(W) == 0)) W[i, which.min(Dd[i, ])] <- 1
  W / rowSums(W)
}
# Contigüidad (fronteras a < 10 km, geodesia s2); islas: sus 2 vecinos más cercanos.
poli161 <- mundo_ne |> dplyr::filter(iso3 %in% iso_muestra_1m) |> sf::st_make_valid() |>
  dplyr::group_by(iso3) |> dplyr::summarise(geometry = sf::st_union(geometry), .groups = "drop") |>
  dplyr::arrange(iso3)
vec_cont <- sf::st_is_within_distance(poli161, poli161, dist = 10000)
W_cont <- matrix(0, N_PAISES_1M, N_PAISES_1M, dimnames = dimnames(Dkm))
for (i in seq_along(vec_cont)) W_cont[i, setdiff(vec_cont[[i]], i)] <- 1
islas <- which(rowSums(W_cont) == 0)
for (i in islas) { d <- Dkm[i, ]; d[i] <- Inf; W_cont[i, order(d)[1:2]] <- 1 }
W_cont <- W_cont / rowSums(W_cont)
cat("Países sin vecino terrestre (relleno con 2 vecinos):", paste(rownames(W_cont)[islas], collapse = ", "), "\n")

W5 <- W_knn(Dkm, K_VECINOS)
g_chr <- as.character(grupo[rownames(W5)])
join_mismo <- function(g, W, B = B_PERM, semilla = SEMILLA) {
  A <- W > 0
  obs <- sum(A & outer(g, g, "==")) / sum(A)
  set.seed(semilla)
  nulo <- replicate(B, { gg <- sample(g); sum(A & outer(gg, gg, "==")) / sum(A) })
  por_grupo <- vapply(sort(unique(g)), function(h) {
    i <- g == h; sum(A[i, ] & outer(g[i], g, "==")) / sum(A[i, ])
  }, numeric(1))
  esperado <- vapply(sort(unique(g)), function(h) (sum(g == h) - 1) / (length(g) - 1), numeric(1))
  list(obs = obs, nulo_media = mean(nulo), lo = unname(stats::quantile(nulo, 0.025)),
       hi = unname(stats::quantile(nulo, 0.975)), p = (1 + sum(nulo >= obs)) / (B + 1),
       por_grupo = por_grupo, esperado = esperado)
}
jc <- join_mismo(g_chr, W5)
jc_sens <- list(knn8 = join_mismo(g_chr, W_knn(Dkm, 8)), cont = join_mismo(g_chr, W_cont),
                idw2000 = join_mismo(g_chr, W_idw(Dkm, 2000)))
jc_sin <- join_mismo(as.character(cl_sin[rownames(W5)]), W5)
cat(sprintf("Join count kNN5: %.1f %% de enlaces vecino->vecino en el mismo camino vs %.1f %% al azar (banda %.1f-%.1f; p = %.3f); razón %.2f\n",
            100 * jc$obs, 100 * jc$nulo_media, 100 * jc$lo, 100 * jc$hi, jc$p, jc$obs / jc$nulo_media))
cat("  Sensibilidad W:", paste(sprintf("%s %.1f %% (azar %.1f)", names(jc_sens),
                                       100 * sapply(jc_sens, `[[`, "obs"), 100 * sapply(jc_sens, `[[`, "nulo_media")), collapse = " | "),
    sprintf("| sin CNMR (kNN5) %.1f %% (azar %.1f)\n", 100 * jc_sin$obs, 100 * jc_sin$nulo_media))
print(round(rbind(observado = jc$por_grupo, azar = jc$esperado), 3))

# Voto de los 5 vecinos (desempate: el grupo del vecino más cercano entre los empatados).
voto_vecinos <- function(g, W, Dm) {
  vapply(seq_len(nrow(W)), function(i) {
    vec <- which(W[i, ] > 0); t <- table(g[vec]); top <- names(t)[t == max(t)]
    if (length(top) == 1) return(top)
    vec_top <- vec[g[vec] %in% top]; g[vec_top[which.min(Dm[i, vec_top])]]
  }, character(1))
}
mayoria_loo <- function(g, por) {
  vapply(seq_along(g), function(i) {
    o <- which(por == por[i] & seq_along(g) != i)
    if (!length(o)) return(NA_character_)
    t <- table(factor(g[o], levels = NIVELES_GRUPO)); names(t)[which.max(t)]
  }, character(1))
}
pred_vec <- voto_vecinos(g_chr, W5, Dkm)
info_w <- paises_q3[match(rownames(W5), paises_q3$ISO3_code), ]
acc_vecinos <- mean(pred_vec == g_chr)
acc_region <- mean(mayoria_loo(g_chr, info_w$region_sdg) == g_chr, na.rm = TRUE)
acc_ingreso <- mean(mayoria_loo(g_chr, as.character(info_w$ingreso)) == g_chr, na.rm = TRUE)
acc_reg_ing <- mean(mayoria_loo(g_chr, paste(info_w$region_sdg, info_w$ingreso)) == g_chr, na.rm = TRUE)
set.seed(SEMILLA)
acc_nulo <- replicate(B_PERM, { gg <- sample(g_chr); mean(voto_vecinos(gg, W5, Dkm) == gg) })
base_mayor <- max(table(g_chr)) / length(g_chr)
excepciones <- rownames(W5)[pred_vec != g_chr]
vecinos_mismo <- stats::setNames(rowSums((W5 > 0) * outer(g_chr, g_chr, "==")) / K_VECINOS, rownames(W5))
cat(sprintf("Voto de 5 vecinos acierta %.1f %% (azar por permutación %.1f %%, P97,5 %.1f %%; clase mayor %.1f %%) | región %.1f %% | ingreso %.1f %% | región x ingreso %.1f %%\n",
            100 * acc_vecinos, 100 * mean(acc_nulo), 100 * stats::quantile(acc_nulo, 0.975), 100 * base_mayor,
            100 * acc_region, 100 * acc_ingreso, 100 * acc_reg_ing))
cat(sprintf("Excepciones (camino distinto al de la mayoría de sus vecinos): %d\n", length(excepciones)))

# =============================================================================
# 7. Divergencia entre países (P1)
# =============================================================================
# Qué: por año, DE, CV y P10-P90 entre los 161 países de edad mediana, LEx,
# LE65, LE60 y Q5 (log y razón P90/P10); cambio 1950 -> 2023 con IC por
# bootstrap de bloques de subregión. Por qué: P1 pregunta si los países se
# acercan o se alejan; la respuesta depende del indicador y de la escala.
cat_sec("7. Divergencia P1")
pan_p1 <- paises_todos() |>
  dplyr::select(ISO3_code, Time, subregion, region_sdg, ingreso, pob_1m, MedianAgePop, LEx, LE65, TFR, Q5, CNMR) |>
  dplyr::left_join(le60_sup, by = c("ISO3_code", "Time"))
VARS_P1 <- c("MedianAgePop", "LEx", "LE65", "LE60", "TFR", "Q5")
dispersion_anual <- function(df, var, universo) {
  df |> dplyr::filter(!is.na(.data[[var]])) |>
    dplyr::group_by(Time) |>
    dplyr::summarise(
      n = dplyr::n(), media = mean(.data[[var]]), de = stats::sd(.data[[var]]), cv = 100 * de / media,
      p10 = stats::quantile(.data[[var]], 0.10), p25 = stats::quantile(.data[[var]], 0.25),
      p50 = stats::median(.data[[var]]), p75 = stats::quantile(.data[[var]], 0.75),
      p90 = stats::quantile(.data[[var]], 0.90),
      de_log = if (var == "Q5") stats::sd(log(.data[[var]])) else NA_real_,
      razon_p90p10 = p90 / p10, brecha_p90p10 = p90 - p10,
      r2_region = summary(stats::lm(.data[[var]] ~ factor(region_sdg)))$r.squared,
      r2_ingreso = { ok <- ingreso != "Not classified"
                     summary(stats::lm(.data[[var]][ok] ~ droplevels(factor(ingreso[ok]))))$r.squared },
      .groups = "drop") |>
    dplyr::mutate(variable = var, universo = universo, periodo_en = etiqueta_periodo(Time), .before = 1)
}
dispersion <- dplyr::bind_rows(
  lapply(VARS_P1, function(v) dispersion_anual(pan_p1 |> dplyr::filter(pob_1m %in% TRUE), v, UNIVERSO_1M)),
  lapply(VARS_P1, function(v) dispersion_anual(pan_p1, v, UNIVERSO_237)),
  lapply(c("LEx", "MedianAgePop"), function(v) dispersion_anual(pan_p1 |> dplyr::filter(pob_1m %in% TRUE, ISO3_code != "CAF"), v,
                                                                 "160 countries ≥ 1 M (without Central African Republic)")))
d1 <- function(var, anio, col = "de", uni = UNIVERSO_1M) {
  dispersion[[col]][dispersion$variable == var & dispersion$Time == anio & dispersion$universo == uni]
}
for (v in VARS_P1) {
  cat(sprintf("%-13s DE 1950 %.2f -> 2023 %.2f -> 2050 %.2f (proy.) | CV %.1f -> %.1f %% | 237: DE %.2f -> %.2f\n",
              v, d1(v, 1950), d1(v, 2023), d1(v, 2050), d1(v, 1950, "cv"), d1(v, 2023, "cv"),
              d1(v, 1950, uni = UNIVERSO_237), d1(v, 2023, uni = UNIVERSO_237)))
}
cat(sprintf("Q5: razón P90/P10 %.1f -> %.1f (2050 proy. %.1f); brecha P90-P10 %.0f -> %.0f por mil; DE(log) %.2f -> %.2f\n",
            d1("Q5", 1950, "razon_p90p10"), d1("Q5", 2023, "razon_p90p10"), d1("Q5", 2050, "razon_p90p10"),
            d1("Q5", 1950, "brecha_p90p10"), d1("Q5", 2023, "brecha_p90p10"), d1("Q5", 1950, "de_log"), d1("Q5", 2023, "de_log")))
# Año del máximo de la DE: en estimaciones y (por separado) en la proyección.
anio_max_de <- dispersion |>
  dplyr::filter(universo == UNIVERSO_1M) |>
  dplyr::mutate(estad = ifelse(variable == "Q5", de_log, de)) |>
  dplyr::group_by(variable, periodo_en) |>
  dplyr::summarise(anio_max = Time[which.max(estad)], valor_max = max(estad), .groups = "drop")
print(anio_max_de)
q5_pico <- dispersion |> dplyr::filter(universo == UNIVERSO_1M, variable == "Q5", Time <= ANIO_FIN_ESTIMACION) |>
  dplyr::slice_max(razon_p90p10, n = 1, with_ties = FALSE)
q5_pico_237 <- dispersion |> dplyr::filter(universo == UNIVERSO_237, variable == "Q5", Time <= ANIO_FIN_ESTIMACION) |>
  dplyr::slice_max(razon_p90p10, n = 1, with_ties = FALSE)
cat(sprintf("Razón P90/P10 de Q5: máximo %.1f en %d (estimaciones; 237: %.1f en %d) y %.1f en 2023 -> la brecha relativa se abrió hasta ~2000 y se estrecha desde entonces\n",
            q5_pico$razon_p90p10, q5_pico$Time, q5_pico_237$razon_p90p10, q5_pico_237$Time, d1("Q5", 2023, "razon_p90p10")))
# Tendencia de la DE 1950-2023 con EE de Newey-West (solo notebook; sin p-valores en pantalla).
tendencia_de <- purrr::map_dfr(c("MedianAgePop", "LEx", "LE65", "TFR"), function(v) {
  dd <- dispersion |> dplyr::filter(universo == UNIVERSO_1M, variable == v, Time <= ANIO_FIN_ESTIMACION)
  m <- stats::lm(de ~ Time, dd)
  se_iid <- sqrt(diag(stats::vcov(m)))[2]
  se_nw <- sqrt(diag(sandwich::NeweyWest(m, lag = 10, prewhite = FALSE)))[2]
  tibble::tibble(variable = v, pendiente_decada = 10 * stats::coef(m)[2], t_iid = stats::coef(m)[2] / se_iid,
                 t_nw = stats::coef(m)[2] / se_nw)
})
print(tendencia_de)

# --- 7.1 IC por bloques de subregión (pantalla) e iid BCa (notebook) ---------
ancho_p1 <- function(var) {
  pan_p1 |> dplyr::filter(pob_1m %in% TRUE, Time %in% c(1950, 2023)) |>
    dplyr::select(ISO3_code, subregion, Time, x = dplyr::all_of(var)) |>
    tidyr::pivot_wider(names_from = Time, values_from = x, names_prefix = "x")
}
estad_disp <- function(d) {
  s1 <- stats::sd(d$x1950); s2 <- stats::sd(d$x2023); m1 <- mean(d$x1950); m2 <- mean(d$x2023)
  c(sd1950 = s1, sd2023 = s2, dsd = s2 - s1, cv1950 = 100 * s1 / m1, cv2023 = 100 * s2 / m2,
    dcv = 100 * (s2 / m2 - s1 / m1))
}
estad_q5 <- function(d) {
  q1 <- stats::quantile(d$x1950, c(0.1, 0.9)); q2 <- stats::quantile(d$x2023, c(0.1, 0.9))
  c(r1950 = unname(q1[2] / q1[1]), r2023 = unname(q2[2] / q2[1]), dr = unname(q2[2] / q2[1] - q1[2] / q1[1]),
    gap1950 = unname(q1[2] - q1[1]), gap2023 = unname(q2[2] - q2[1]),
    sdlog1950 = stats::sd(log(d$x1950)), sdlog2023 = stats::sd(log(d$x2023)),
    dsdlog = stats::sd(log(d$x2023)) - stats::sd(log(d$x1950)))
}
ic_p1 <- list(); ic_p1_iid <- list()
for (v in c("MedianAgePop", "LEx", "LE65", "LE60", "TFR")) {
  w <- ancho_p1(v)
  ic_p1[[v]] <- bootstrap_bloques(w, estad_disp, B = B_BOOT_BLOQUES)
  ic_p1_iid[[v]] <- lapply(c("sd1950", "sd2023", "dsd", "cv1950", "cv2023", "dcv"), function(s)
    bootstrap_bca(w, function(d) estad_disp(d)[[s]], B = B_BOOT))
  names(ic_p1_iid[[v]]) <- c("sd1950", "sd2023", "dsd", "cv1950", "cv2023", "dcv")
}
w_q5 <- ancho_p1("Q5")
ic_q5 <- bootstrap_bloques(w_q5, estad_q5, B = B_BOOT_BLOQUES)
ic_q5_iid <- lapply(stats::setNames(names(ic_q5$valor), names(ic_q5$valor)), function(s)
  bootstrap_bca(w_q5, function(d) estad_q5(d)[[s]], B = B_BOOT))
tabla_ic_p1 <- dplyr::bind_rows(
  purrr::imap_dfr(ic_p1, function(r, v) tibble::tibble(variable = v, estad = names(r$valor), valor = r$valor,
                                                        lo = r$ci_low, hi = r$ci_high,
                                                        lo_iid = sapply(ic_p1_iid[[v]], `[[`, "ci_low"),
                                                        hi_iid = sapply(ic_p1_iid[[v]], `[[`, "ci_high"))),
  tibble::tibble(variable = "Q5", estad = names(ic_q5$valor), valor = ic_q5$valor, lo = ic_q5$ci_low,
                 hi = ic_q5$ci_high, lo_iid = sapply(ic_q5_iid, `[[`, "ci_low"), hi_iid = sapply(ic_q5_iid, `[[`, "ci_high")))
print(tabla_ic_p1 |> dplyr::mutate(dplyr::across(where(is.double), ~ round(.x, 2))), n = 50)
r2_reg_ing <- dispersion |> dplyr::filter(universo == UNIVERSO_1M, Time %in% c(1950, 2023), variable %in% c("MedianAgePop", "LEx")) |>
  dplyr::select(variable, Time, r2_region, r2_ingreso)
print(r2_reg_ing)

# =============================================================================
# 8. Curvas atípicas (profundidad funcional, datos SIN suavizar)
# =============================================================================
# Qué: boxplot funcional (MBD) de la LEx y profundidad de forma (cambios
# anuales). Por qué: las trayectorias raras son crisis, no países "ricos" o
# "pobres"; RCA se marca como posible artefacto (V1).
cat_sec("8. Curvas atípicas")
mat_anual <- function(var, isos = iso_muestra_1m, anios = ANIOS_EST) {
  w <- pan_p1 |> dplyr::filter(ISO3_code %in% isos, Time %in% anios) |>
    dplyr::select(ISO3_code, Time, x = dplyr::all_of(var)) |>
    tidyr::pivot_wider(names_from = ISO3_code, values_from = x) |> dplyr::arrange(Time)
  m <- as.matrix(w[, isos]); rownames(m) <- w$Time; m
}
Y_lex <- mat_anual("LEx")
fb_nivel <- fda::fbplot(Y_lex, x = ANIOS_EST, method = "MBD", plot = FALSE)
atip_nivel <- colnames(Y_lex)[fb_nivel$outpoint]
fb_forma <- fda::fbplot(apply(Y_lex, 2, diff), x = ANIOS_EST[-1], method = "MBD", plot = FALSE)
atip_forma <- colnames(Y_lex)[order(fb_forma$depth)[1:8]]
if (requireNamespace("foreach", quietly = TRUE)) foreach::registerDoSEQ()   # fda.usc usa %dopar%: secuencial declarado
set.seed(SEMILLA)
t_od <- Sys.time()
od <- fda.usc::outliers.depth.trim(fda.usc::fdata(unname(t(Y_lex)), argvals = as.numeric(ANIOS_EST)),
                                   dfunc = fda.usc::depth.mode, nb = 200, smo = 0.05, trim = 0.06)
atip_modal <- colnames(Y_lex)[as.integer(gsub("[^0-9]", "", od$outliers))]
cat(sprintf("LEx atípicas de nivel (MBD): %s | forma (8 menos profundas): %s | modal (nb = 200, %.0f s): %s\n",
            paste(atip_nivel, collapse = ", "), paste(atip_forma, collapse = ", "),
            as.numeric(difftime(Sys.time(), t_od, units = "secs")), paste(atip_modal, collapse = ", ")))

# =============================================================================
# 9. Velocidad en el camino: de 5 a 3 hijos por grupo (Kaplan-Meier) y reloj propio
# =============================================================================
# Qué: TFR suavizada (B-splines, lambda = 10), año continuo del último cruce
# de 5, 4 y 3; años de 5 a 3 con censura en 2023, por camino. Por qué: "same
# road, different speed" — la velocidad se mide con censura, no descartando a
# quien aún no llega.
cat_sec("9. Velocidad 5 -> 3")
Y_tfr <- mat_anual("TFR")
base_tfr <- fda::create.bspline.basis(range(ANIOS_EST), nbasis = length(ANIOS_EST) + 2, norder = 4)
fd_tfr <- fda::smooth.basis(ANIOS_EST, Y_tfr, fda::fdPar(base_tfr, 2, LAMBDA_FDA))$fd
malla <- seq(min(ANIOS_EST), max(ANIOS_EST), by = 0.1)
Tf <- fda::eval.fd(malla, fd_tfr)
cruce <- function(y, u) {
  if (y[1] < u) return(-Inf)                # ya estaba por debajo en 1950 (censura izquierda)
  if (utils::tail(y, 1) >= u) return(Inf)   # aún no cruza en 2023 (censura derecha)
  i <- max(which(y >= u)); malla[i] + (y[i] - u) / (y[i] - y[i + 1]) * 0.1
}
cruces <- tibble::tibble(ISO3_code = colnames(Y_tfr), c5 = apply(Tf, 2, cruce, 5),
                         c4 = apply(Tf, 2, cruce, 4), c3 = apply(Tf, 2, cruce, 3)) |>
  dplyr::mutate(grupo = grupo[ISO3_code],
                dur53 = dplyr::case_when(is.finite(c5) & is.finite(c3) ~ c3 - c5,
                                         is.finite(c5) & c3 == Inf ~ ANIO_FIN_ESTIMACION - c5,
                                         TRUE ~ NA_real_),
                evento53 = is.finite(c5) & is.finite(c3))
km53 <- survival::survfit(survival::Surv(dur53, evento53) ~ grupo, data = cruces |> dplyr::filter(!is.na(dur53)))
km53_tab <- summary(km53)$table
km53_med <- tibble::tibble(grupo = sub("grupo=", "", rownames(km53_tab)), n = km53_tab[, "records"],
                           eventos = km53_tab[, "events"], mediana = km53_tab[, "median"],
                           lo = km53_tab[, "0.95LCL"], hi = km53_tab[, "0.95UCL"])
print(km53_med)
dur53_pais <- cruces |> dplyr::filter(evento53) |> dplyr::arrange(dur53)
cat("Más rápidos 5->3:", paste(sprintf("%s %.1f", dur53_pais$ISO3_code[1:6], dur53_pais$dur53[1:6]), collapse = ", "),
    "| más lentos:", paste(sprintf("%s %.1f", utils::tail(dur53_pais$ISO3_code, 4), utils::tail(dur53_pais$dur53, 4)), collapse = ", "), "\n")
# Regla de resaltes de fig04 (QA_storyboard §6.4): el más rápido, el mediano y el
# más lento de 5 -> 3 entre los países >= 10 M (2023) que completaron el tramo.
# Por qué: los ejemplos del guion (China / Egipto) deben salir de una regla.
pob23_q3 <- stats::setNames(paises_q3$pop2023, paises_q3$ISO3_code)        # miles
regla53 <- dur53_pais |> dplyr::filter(pob23_q3[ISO3_code] >= 1e4) |> dplyr::arrange(dur53)
regla53_iso <- c(fastest = regla53$ISO3_code[1],
                 median = regla53$ISO3_code[which.min(abs(regla53$dur53 - stats::median(regla53$dur53)))],
                 slowest = utils::tail(regla53$ISO3_code, 1))
regla53_anios <- stats::setNames(regla53$dur53[match(regla53_iso, regla53$ISO3_code)], names(regla53_iso))
regla53_ok <- identical(unname(regla53_iso[c("fastest", "slowest")]), c("CHN", "EGY"))
cat(sprintf("Regla >= 10 M (%d países completaron 5 -> 3): más rápido %s %.1f | mediano %s %.1f | más lento %s %.1f -> China/Egipto %s\n",
            nrow(regla53), regla53_iso["fastest"], regla53_anios["fastest"], regla53_iso["median"], regla53_anios["median"],
            regla53_iso["slowest"], regla53_anios["slowest"], ifelse(regla53_ok, "CONFIRMADO", "NO se cumple: cambiar voz y resaltes")))
# Curvas en el reloj propio (tau = año - c4) para las figuras finales.
curvas_q3 <- tibble::tibble(ISO3_code = rep(colnames(Y_tfr), each = length(ANIOS_EST)),
                            Time = rep(ANIOS_EST, times = ncol(Y_tfr)),
                            TFR = as.vector(Y_tfr),
                            TFR_suav = as.vector(fda::eval.fd(ANIOS_EST, fd_tfr))) |>
  dplyr::left_join(cruces |> dplyr::select(ISO3_code, c4), by = "ISO3_code") |>
  dplyr::mutate(grupo = grupo[ISO3_code], tau4 = ifelse(is.finite(c4), Time - c4, NA_real_),
                periodo_en = etiqueta_periodo(Time)) |>
  dplyr::select(ISO3_code, grupo, Time, TFR, TFR_suav, tau4, periodo_en)

# =============================================================================
# 10. Proyección Medium 2024-2050 por grupo (escenario, no pronóstico)
# =============================================================================
# Qué: componentes del cambio (saldo natural vs migración neta, sumas de
# personas), edad mediana 2050, velocidad del envejecimiento (30 -> 40 años),
# año del pico de población y LE60 2050. Por qué: qué espera la ONU en cada
# camino, etiquetado siempre como "UN medium projection".
cat_sec("10. Proyección por grupo")
componentes_grupo <- function(anios, excluir = character(0)) {
  verificar_ventana(anios)
  base <- pan_todo161 |> dplyr::filter(!(ISO3_code %in% excluir))
  pob0 <- base |> dplyr::filter(Time == min(anios)) |> dplyr::group_by(grupo) |>
    dplyr::summarise(pob_inicio = sum(TPopulation1July), .groups = "drop")
  base |> dplyr::filter(Time %in% anios) |> dplyr::group_by(grupo) |>
    dplyr::summarise(nat = sum(NatChange), mig = sum(NetMigrations), cambio = sum(PopChange), .groups = "drop") |>
    dplyr::left_join(pob0, by = "grupo") |>
    dplyr::mutate(ventana = paste0(min(anios), "-", max(anios)), periodo_en = etiqueta_periodo(min(anios)),
                  pob_inicio_bn = pob_inicio / 1e6, nat_bn = nat / 1e6, mig_bn = mig / 1e6, cambio_bn = cambio / 1e6,
                  nat_pct_pob = 100 * nat / pob_inicio, mig_pct_pob = 100 * mig / pob_inicio,
                  cambio_pct_pob = 100 * cambio / pob_inicio,
                  share_nat = 100 * nat / cambio, share_mig = 100 * mig / cambio) |>
    dplyr::select(grupo, ventana, periodo_en, pob_inicio_bn, nat_bn, mig_bn, cambio_bn, nat_pct_pob,
                  mig_pct_pob, cambio_pct_pob, share_nat, share_mig)
}
comp_proy <- componentes_grupo(2024:2050)
comp_est <- componentes_grupo(2000:2023)
mas_poblado <- vapply(ejemplos_iso, `[`, "", 1)
comp_proy_sin_mayor <- purrr::map_dfr(NIVELES_GRUPO, function(g)
  componentes_grupo(2024:2050, excluir = mas_poblado[[g]]) |> dplyr::filter(grupo == g) |>
    dplyr::mutate(excluido = mas_poblado[[g]]))
proyeccion_grupos <- dplyr::bind_rows(comp_est, comp_proy)
print(proyeccion_grupos |> dplyr::mutate(dplyr::across(where(is.double), ~ round(.x, 2))), width = 200)
print(comp_proy_sin_mayor |> dplyr::select(grupo, excluido, nat_pct_pob, mig_pct_pob, cambio_pct_pob) |>
        dplyr::mutate(dplyr::across(where(is.double), ~ round(.x, 1))))

# Edad mediana 2023 y 2050 por grupo (mediana de países y media ponderada por población).
edad_grupo <- pan_todo161 |> dplyr::filter(Time %in% c(2023, 2050)) |>
  dplyr::group_by(grupo, Time) |>
  dplyr::summarise(mediana = median(MedianAgePop), ponderada = stats::weighted.mean(MedianAgePop, TPopulation1July),
                   le60 = median(LE60), le65 = median(LE65), .groups = "drop")
print(edad_grupo)
# China frente al promedio de ingreso alto (FY2027, media ponderada; S11 corregido).
c2050 <- corte_anio(2050, "completa")
medage_chn_2050 <- c2050$MedianAgePop[c2050$ISO3_code == "CHN"]
medage_alto_2050 <- with(c2050[c2050$ingreso == "High income", ], stats::weighted.mean(MedianAgePop, TPopulation1July))
medage_alto_2050_onu <- datos_agregados$MedianAgePop[datos_agregados$Location == "High-income countries" & datos_agregados$Time == 2050]
cat(sprintf("Edad mediana 2050 (proy.): China %.1f vs ingreso alto FY2027 ponderado %.1f (agregado ONU may-2024: %.1f)\n",
            medage_chn_2050, medage_alto_2050, medage_alto_2050_onu))

# Velocidad del envejecimiento: años de edad mediana 30 -> 40 (1950-2100).
envejec <- pan_todo161 |> dplyr::group_by(ISO3_code) |> dplyr::arrange(Time, .by_group = TRUE) |>
  dplyr::summarise(y_medage30 = { t <- Time[MedianAgePop >= 30]; if (length(t)) min(t) else NA_real_ },
                   y_medage40 = { t <- Time[MedianAgePop >= 40]; if (length(t)) min(t) else NA_real_ },
                   .groups = "drop") |>
  dplyr::mutate(grupo = grupo[ISO3_code],
                censura_30_40 = !is.na(y_medage30) & is.na(y_medage40),          # no llega a 40 antes de 2100
                anios_30_40 = dplyr::case_when(!is.na(y_medage40) ~ y_medage40 - y_medage30,
                                               censura_30_40 ~ ANIO_MAX_VALIDO - y_medage30, TRUE ~ NA_real_),
                y40_proyectado = !is.na(y_medage40) & y_medage40 >= ANIO_INICIO_PROYECCION,
                cohorte_30 = dplyr::case_when(is.na(y_medage30) ~ "never reaches 30 by 2100",
                                              y_medage30 == 1950 ~ "already >= 30 in 1950",
                                              y_medage30 < 1990 ~ "reached 30 before 1990",
                                              y_medage30 <= 2023 ~ "reached 30 in 1990-2023",
                                              TRUE ~ "reaches 30 after 2023 (projection)"))
print(table(envejec$cohorte_30, envejec$grupo))
env_obs <- envejec |> dplyr::filter(!is.na(y_medage40), y_medage30 > 1950) |>
  dplyr::left_join(paises_q3 |> dplyr::select(ISO3_code, subregion), by = "ISO3_code")
med_temprano <- median(env_obs$anios_30_40[env_obs$cohorte_30 == "reached 30 before 1990"])
med_reciente <- median(env_obs$anios_30_40[env_obs$cohorte_30 == "reached 30 in 1990-2023"])
ic_temprano <- bootstrap_bloques(env_obs |> dplyr::filter(cohorte_30 == "reached 30 before 1990"),
                                 function(d) median(d$anios_30_40), B = B_BOOT_BLOQUES)
ic_reciente <- bootstrap_bloques(env_obs |> dplyr::filter(cohorte_30 == "reached 30 in 1990-2023"),
                                 function(d) median(d$anios_30_40), B = B_BOOT_BLOQUES)
km_env <- survival::survfit(survival::Surv(anios_30_40, !censura_30_40) ~ cohorte_30,
                            data = envejec |> dplyr::filter(cohorte_30 %in% c("reached 30 before 1990", "reached 30 in 1990-2023")))
km_env_med <- summary(km_env)$table[, "median"]
n_y40_proy_reciente <- sum(env_obs$y40_proyectado[env_obs$cohorte_30 == "reached 30 in 1990-2023"])
n_reciente <- sum(env_obs$cohorte_30 == "reached 30 in 1990-2023")
env_grupo <- env_obs |> dplyr::group_by(grupo) |> dplyr::summarise(n = dplyr::n(), mediana = median(anios_30_40), .groups = "drop")
yrs30_40 <- stats::setNames(envejec$anios_30_40, envejec$ISO3_code)
y30_pais <- stats::setNames(envejec$y_medage30, envejec$ISO3_code)
y40_pais <- stats::setNames(envejec$y_medage40, envejec$ISO3_code)
eur_temprano <- median(env_obs$anios_30_40[env_obs$cohorte_30 == "reached 30 before 1990" &
                                             paises_q3$region_sdg[match(env_obs$ISO3_code, paises_q3$ISO3_code)] == "Europe and Northern America"])
cat(sprintf("Edad mediana 30 -> 40: cruzaron 30 antes de 1990 mediana %.1f años [bloques %.1f-%.1f; KM %.1f]; cruzan 30 en 1990-2023: %.1f [%.1f-%.1f; KM %.1f] (%d de %d con el cruce de 40 en la proyección)\n",
            med_temprano, ic_temprano$ci_low, ic_temprano$ci_high, km_env_med[1], med_reciente,
            ic_reciente$ci_low, ic_reciente$ci_high, km_env_med[2], n_y40_proy_reciente, n_reciente))
cat(sprintf("Europa y N. América (cruce de 30 antes de 1990): %.1f años | KOR %d (%d->%d), JPN %d (%d->%d), CHN %d (%d->%d), ITA %d, USA %d\n",
            eur_temprano, yrs30_40["KOR"], y30_pais["KOR"], y40_pais["KOR"], yrs30_40["JPN"], y30_pais["JPN"], y40_pais["JPN"],
            yrs30_40["CHN"], y30_pais["CHN"], y40_pais["CHN"], yrs30_40["ITA"], yrs30_40["USA"]))
print(env_grupo)

# --- Envejecimiento POR CAMINO (QA_storyboard §6.3): Fast vs Early movers -----
# Qué: mediana de Kaplan-Meier de los años de edad mediana 30 -> 40 en cada
# camino (censura derecha si no llega a 40 antes de 2100; fuera los que ya
# tenían >= 30 en 1950, cuyo inicio no se observa). Por qué: la frase del vídeo
# compara caminos, no cohortes; la versión por cohorte queda como sensibilidad.
km_mediana_env <- function(d) {
  f <- survival::survfit(survival::Surv(anios_30_40, !censura_30_40) ~ 1, data = d)
  unname(summary(f)$table["median"])
}
env_base_grupo <- envejec |> dplyr::filter(!is.na(y_medage30), y_medage30 > 1950) |>
  dplyr::left_join(paises_q3 |> dplyr::select(ISO3_code, subregion), by = "ISO3_code")
env_km_grupo <- purrr::map_dfr(NIVELES_GRUPO, function(g) {
  d <- env_base_grupo |> dplyr::filter(grupo == g)
  tibble::tibble(grupo = g, n = nrow(d), n_censura_2100 = sum(d$censura_30_40),
                 n_inicio_proy = sum(d$y_medage30 >= ANIO_INICIO_PROYECCION),
                 n_fin_proy = sum(d$y_medage40 >= ANIO_INICIO_PROYECCION, na.rm = TRUE),
                 n_izq_1950 = sum(envejec$grupo == g & envejec$y_medage30 %in% 1950),
                 km_mediana = km_mediana_env(d),
                 mediana_completos = stats::median(d$anios_30_40[!d$censura_30_40]))
})
print(env_km_grupo)
ic_env_fast <- bootstrap_bloques(env_base_grupo |> dplyr::filter(grupo == "Fast movers"), km_mediana_env, B = B_BOOT_BLOQUES)
ic_env_early <- bootstrap_bloques(env_base_grupo |> dplyr::filter(grupo == "Early movers"), km_mediana_env, B = B_BOOT_BLOQUES)
# Sensibilidades: Fast movers que ya cruzaron 30 en <= 2023; Early movers
# incluyendo a los 10 con >= 30 en 1950 con su cota inferior (y40 - 1950).
env_fast_iniciados <- env_base_grupo |> dplyr::filter(grupo == "Fast movers", y_medage30 <= ANIO_FIN_ESTIMACION)
med_fast_iniciados <- km_mediana_env(env_fast_iniciados)
ic_env_fast_ini <- bootstrap_bloques(env_fast_iniciados, km_mediana_env, B = B_BOOT_BLOQUES)
early_con_izq <- envejec |> dplyr::filter(grupo == "Early movers", !is.na(y_medage30)) |>
  dplyr::mutate(anios_30_40 = ifelse(y_medage30 == 1950 & !is.na(y_medage40), y_medage40 - 1950, anios_30_40))
med_early_con_izq <- km_mediana_env(early_con_izq)
med_g <- function(g) env_km_grupo$km_mediana[env_km_grupo$grupo == g]
cat(sprintf("Edad mediana 30 -> 40 POR CAMINO (KM): Fast movers %.1f años [bloques %.1f-%.1f] (n %d; %d empiezan en la proyección) | Early movers %.1f [%.1f-%.1f] (n %d; %d con >= 30 en 1950 fuera; con cota inferior: %.1f)\n",
            med_g("Fast movers"), ic_env_fast$ci_low, ic_env_fast$ci_high, env_km_grupo$n[2], env_km_grupo$n_inicio_proy[2],
            med_g("Early movers"), ic_env_early$ci_low, ic_env_early$ci_high, env_km_grupo$n[1], env_km_grupo$n_izq_1950[1], med_early_con_izq))
cat(sprintf("  Fast movers que ya cruzaron 30 en <= 2023: %.1f años [%.1f-%.1f] (n %d) — por cohorte de cruce: %.1f (1990-2023) vs %.1f (antes de 1990)\n",
            med_fast_iniciados, ic_env_fast_ini$ci_low, ic_env_fast_ini$ci_high, nrow(env_fast_iniciados), med_reciente, med_temprano))

# Año del pico de población por país (1950-2100; > 2023 = proyección).
picos <- pan_todo161 |> dplyr::group_by(ISO3_code) |>
  dplyr::summarise(anio_pico_pob = Time[which.max(TPopulation1July)], .groups = "drop") |>
  dplyr::mutate(grupo = grupo[ISO3_code],
                tipo_pico = dplyr::case_when(anio_pico_pob <= ANIO_FIN_ESTIMACION ~ "peaked by 2023 (estimate)",
                                             anio_pico_pob < ANIO_MAX_VALIDO ~ "peak projected 2024-2099",
                                             TRUE ~ "no peak before 2100 (projection)"))
picos_grupo <- picos |> dplyr::group_by(grupo) |>
  dplyr::summarise(n = dplyr::n(), n_pico_2023 = sum(tipo_pico == "peaked by 2023 (estimate)"),
                   n_pico_proy = sum(tipo_pico == "peak projected 2024-2099"),
                   n_sin_pico = sum(tipo_pico == "no peak before 2100 (projection)"),
                   mediana_pico = median(anio_pico_pob), .groups = "drop")
print(picos_grupo)
cat("Picos de algunos países:", paste(sprintf("%s %d", c("CHN", "IND", "USA", "JPN", "BRA", "NGA", "DEU", "RUS"),
                                              picos$anio_pico_pob[match(c("CHN", "IND", "USA", "JPN", "BRA", "NGA", "DEU", "RUS"), picos$ISO3_code)]),
                                      collapse = ", "), "\n")

# =============================================================================
# 11. Cifras del mundo (agregado ONU; proyección Medium >= 2024)
# =============================================================================
# Qué: población mundial 2023 / 2050 / 2100, año y nivel del pico, países que
# ya decrecen y los proyectados en 2050 y 2100. Por qué: contexto de la
# tabla de recomendaciones (cuántos caminos llevan ya a decrecer).
cat_sec("11. Mundo")
mundo <- agregado_mundo()
pico_mundo <- mundo |> dplyr::slice_max(TPopulation1July, n = 1, with_ties = FALSE)
pob_mundo <- stats::setNames(mundo$TPopulation1July / 1e6, mundo$Time)
decrecen <- paises_todos() |> dplyr::group_by(Time) |>
  dplyr::summarise(n_decrecen = sum(PopChange < 0), n_decrecen_1m = sum(PopChange < 0 & pob_1m %in% TRUE),
                   n_natneg = sum(NatChange < 0), pob_natneg = sum(TPopulation1July[NatChange < 0]),
                   pob_total = sum(TPopulation1July), .groups = "drop") |>
  dplyr::mutate(pct_pob_natneg = 100 * pob_natneg / pob_total, periodo_en = etiqueta_periodo(Time))
dec <- function(anio, col) decrecen[[col]][decrecen$Time == anio]
cat(sprintf("Mundo: %.3f mil M (2023), %.3f (2050, proy.), %.3f (2100, proy.); pico %d con %.3f mil M (proy.)\n",
            pob_mundo["2023"], pob_mundo["2050"], pob_mundo["2100"], pico_mundo$Time, pico_mundo$TPopulation1July / 1e6))
cat(sprintf("Países y áreas que decrecen (PopChange < 0): 2023 %d (%d >= 1 M) | 2050 %d (%d) | 2100 %d (%d) — 2050/2100 = proyección\n",
            dec(2023, "n_decrecen"), dec(2023, "n_decrecen_1m"), dec(2050, "n_decrecen"), dec(2050, "n_decrecen_1m"),
            dec(2100, "n_decrecen"), dec(2100, "n_decrecen_1m")))

# OtherVariants: IP de la ONU para la población de China 2050 (lista blanca + monotonía).
ov <- data.table::fread(RUTA_WPP_OTHERVARIANTS, encoding = "UTF-8", na.strings = "",
                        select = c("ISO3_code", "LocID", "Location", "Variant", "Time", "TPopulation1July"))
ov_pi <- ov[ov$Variant %in% c("Median PI", "Lower 80 PI", "Upper 80 PI", "Lower 95 PI", "Upper 95 PI") &
              !is.na(ov$ISO3_code) & ov$ISO3_code != "" & ov$Time == 2050, ]
ov_pi_w <- data.table::dcast(ov_pi, ISO3_code ~ Variant, value.var = "TPopulation1July")
stopifnot(with(ov_pi_w, all(`Lower 95 PI` <= `Lower 80 PI` & `Lower 80 PI` <= `Median PI` &
                              `Median PI` <= `Upper 80 PI` & `Upper 80 PI` <= `Upper 95 PI`)))
pi_chn <- ov_pi_w[ov_pi_w$ISO3_code == "CHN", ]
pop_chn_2050_med <- c2050$TPopulation1July[c2050$ISO3_code == "CHN"] / 1e6
cat(sprintf("China 2050 (proy.): %.3f mil M [IP 80 %.3f-%.3f; IP 95 %.3f-%.3f] (Median PI %.3f); test de monotonía OK en %d países\n",
            pop_chn_2050_med, pi_chn$`Lower 80 PI` / 1e6, pi_chn$`Upper 80 PI` / 1e6, pi_chn$`Lower 95 PI` / 1e6,
            pi_chn$`Upper 95 PI` / 1e6, pi_chn$`Median PI` / 1e6, nrow(ov_pi_w)))
rm(ov, ov_pi)

# =============================================================================
# 12. Complementos demográficos (ODS 3.2, decrecimiento natural, África subsahariana)
# =============================================================================
# Qué: ritmo de la mortalidad infantil frente a la meta 2030, países con más
# defunciones que nacimientos (1990 / 2023 / 2050), caminos dentro de SSA.
# Por qué: son las cifras de las filas de la tabla de recomendaciones.
cat_sec("12. Complementos demográficos")
q5w <- paises_todos(anios = c(2010, 2015, 2018, 2023, 2030)) |>
  dplyr::select(ISO3_code, Location, region_sdg, ingreso, pob_1m, Time, Q5) |>
  tidyr::pivot_wider(names_from = Time, values_from = Q5, names_prefix = "q5_")
sdg <- q5w |> dplyr::filter(q5_2023 > 25) |>
  dplyr::mutate(ritmo_obs = 100 * log(q5_2015 / q5_2023) / 8, ritmo_necesario = 100 * log(q5_2023 / 25) / 7,
                ritmo_obs_2010 = 100 * log(q5_2010 / q5_2023) / 13, ritmo_obs_2018 = 100 * log(q5_2018 / q5_2023) / 5,
                on_pace = ritmo_obs >= ritmo_necesario, above_2030 = q5_2030 > 25, grupo = grupo[ISO3_code])
n_sdg_above <- nrow(sdg); n_sdg_pace <- sum(sdg$on_pace); n_sdg_2030 <- sum(sdg$above_2030)
n_sdg_pace_sens <- c(sum(sdg$ritmo_obs_2010 >= sdg$ritmo_necesario), sum(sdg$ritmo_obs_2018 >= sdg$ritmo_necesario))
cat(sprintf("ODS 3.2: %d países y áreas con Q5 > 25 (2023); al ritmo necesario %d (ventanas 2010-23 / 2018-23: %s); seguirían > 25 en 2030 (proy.) %d (%d en SSA)\n",
            n_sdg_above, n_sdg_pace, paste(n_sdg_pace_sens, collapse = " / "), n_sdg_2030,
            sum(sdg$above_2030 & sdg$region_sdg == "Sub-Saharan Africa")))
cat(sprintf("  Mediana del ritmo observado 2015-23 %.1f %%/año vs necesario %.1f %%/año\n",
            median(sdg$ritmo_obs), median(sdg$ritmo_necesario)))
natneg_sens <- c(`2021` = dec(2021, "n_natneg"), `2022` = dec(2022, "n_natneg"))
cat(sprintf("NatChange < 0: 1990 %d | 2023 %d (%.1f %% de la población; 2021: %d, 2022: %d) | 2050 %d (proy.) | 2100 %d (proy.)\n",
            dec(1990, "n_natneg"), dec(2023, "n_natneg"), dec(2023, "pct_pob_natneg"), natneg_sens[1], natneg_sens[2],
            dec(2050, "n_natneg"), dec(2100, "n_natneg")))
ssa_237 <- sum(corte_anio(ANIO_BASE, "completa")$region_sdg == "Sub-Saharan Africa")
ssa_caminos <- table(paises_q3$grupo[paises_q3$region_sdg == "Sub-Saharan Africa"])
cat(sprintf("África subsahariana: %d países y áreas (%d >= 1 M) repartidos en: %s\n", ssa_237, sum(ssa_caminos),
            paste(sprintf("%s %d", names(ssa_caminos), ssa_caminos), collapse = ", ")))

# =============================================================================
# 13. Tabla "What to watch, where, when" (plan §7, revisada por demografía)
# =============================================================================
# Qué: filas por ESTADO DE LA PALANCA 2023 (Q1) con cifra, camino mayoritario
# (Q3), qué vigilar, mandato, agencia y horizonte. Por qué: recomendaciones
# descriptivas ("watch, plan, measure, prepare"), nunca causales.
cat_sec("13. Recomendaciones")
palanca <- tipo_palanca_ventana(ANIO_BASE, "completa") |>
  dplyr::left_join(corte_anio(ANIO_BASE, "completa", vars = c("TFR", "TPopulation1July")) |>
                     dplyr::select(ISO3_code, TFR, TPopulation1July), by = "ISO3_code") |>
  dplyr::mutate(inercia = tipo == "B" & TFR < TFR_REEMPLAZO, natneg = NatChange < 0, grupo = grupo[ISO3_code])
print(table(palanca$tipo, useNA = "ifany"))
camino_de <- function(iso) {
  g <- stats::na.omit(as.character(grupo[iso[iso %in% names(grupo)]]))
  if (!length(g)) return(list(texto = "—", n_1m = 0L, top = NA_character_, comp = ""))
  t <- sort(table(factor(g, levels = NIVELES_GRUPO)), decreasing = TRUE); t <- t[t > 0]
  p <- t / sum(t)
  texto <- if (p[1] >= 0.6) sprintf("mostly %s (%d of %d)", names(t)[1], t[1], sum(t))
           else if (length(t) > 1 && sum(p[1:2]) >= 0.75) sprintf("%s & %s (%d and %d of %d)", names(t)[1], names(t)[2], t[1], t[2], sum(t))
           else sprintf("mixed (%s)", paste(sprintf("%s %d", names(t), t), collapse = ", "))
  list(texto = texto, n_1m = as.integer(sum(t)), top = names(t)[1],
       comp = paste(sprintf("%s %d", names(t), t), collapse = "; "))
}
iso_fila <- list(
  sdg32 = sdg$ISO3_code,
  inercia = palanca$ISO3_code[palanca$inercia %in% TRUE],
  natneg = palanca$ISO3_code[palanca$natneg %in% TRUE],
  tipoC = palanca$ISO3_code[palanca$tipo %in% "C"],
  tipoE = palanca$ISO3_code[palanca$tipo %in% "E"])
caminos_fila <- lapply(iso_fila, camino_de)
ej3 <- function(iso, n = 3) {
  d <- palanca |> dplyr::filter(ISO3_code %in% iso, pob_1m %in% TRUE) |> dplyr::arrange(dplyr::desc(TPopulation1July))
  nombre_pais(utils::head(d$ISO3_code, n))
}
pop_inercia_bn <- sum(palanca$TPopulation1July[palanca$inercia %in% TRUE]) / 1e6
# Años de crecimiento que le quedan a la inercia (QA_storyboard §6.1,
# `momentum_years_range`): años de 2023 al máximo de población proyectado
# (UN medium, máximo en 2023-2100) en los 22 países de la fila 2. Por qué: la
# fila dice "plan 30-40 more years of growth"; el rango sale del dato.
wq <- function(x, w, p) { o <- order(x); x <- x[o]; cw <- cumsum(w[o]) / sum(w); x[which(cw >= p)[1]] }
inercia_pico <- paises_todos(anios = ANIO_BASE:ANIO_MAX_VALIDO) |>
  dplyr::filter(ISO3_code %in% iso_fila$inercia) |>
  dplyr::group_by(ISO3_code) |> dplyr::arrange(Time, .by_group = TRUE) |>
  dplyr::summarise(anio_pico = Time[which.max(TPopulation1July)], pob23 = TPopulation1July[Time == ANIO_BASE],
                   pob_1m = dplyr::first(pob_1m), .groups = "drop") |>
  dplyr::mutate(anios_crec = anio_pico - ANIO_BASE) |>
  dplyr::left_join(paises_todos(periodo = "estimacion") |> dplyr::filter(TFR < TFR_REEMPLAZO) |>
                     dplyr::group_by(ISO3_code) |> dplyr::summarise(anio_bajo_21 = min(Time), .groups = "drop"), by = "ISO3_code") |>
  dplyr::mutate(anios_desde_21 = anio_pico - anio_bajo_21) |>
  dplyr::arrange(dplyr::desc(pob23))
mom_p25 <- wq(inercia_pico$anios_crec, inercia_pico$pob23, 0.25)
mom_p50 <- wq(inercia_pico$anios_crec, inercia_pico$pob23, 0.50)
mom_p75 <- wq(inercia_pico$anios_crec, inercia_pico$pob23, 0.75)
mom_sin_ind <- inercia_pico |> dplyr::filter(ISO3_code != "IND")
mom_rango_sin_ind <- c(wq(mom_sin_ind$anios_crec, mom_sin_ind$pob23, 0.25), wq(mom_sin_ind$anios_crec, mom_sin_ind$pob23, 0.75))
mom_mediana_simple <- stats::median(inercia_pico$anios_crec)
mom_mediana_1m <- stats::median(inercia_pico$anios_crec[inercia_pico$pob_1m %in% TRUE])
mom_desde21 <- stats::median(inercia_pico$anios_desde_21[inercia_pico$pob_1m %in% TRUE])
cat(sprintf("Inercia (22): años de 2023 al pico proyectado — P25-P75 ponderado por población %d-%d (mediana %d); sin India %d-%d; mediana simple %.1f (22) / %.1f (>= 1 M); años desde TFR < 2,1 hasta el pico (>= 1 M) %.1f\n",
            mom_p25, mom_p75, mom_p50, mom_rango_sin_ind[1], mom_rango_sin_ind[2], mom_mediana_simple, mom_mediana_1m, mom_desde21))
print(inercia_pico |> dplyr::filter(pob_1m %in% TRUE) |> dplyr::select(ISO3_code, anio_bajo_21, anio_pico, anios_crec, anios_desde_21), n = 25)
le65_sd_txt <- sprintf("SD of LE65 %s → %s years", formatear_cifra(d1("LE65", 1950), "0.0"), formatear_cifra(d1("LE65", 2023), "0.0"))
rec_rows <- tibble::tibble(
  row = 1:5,
  countries_where = c(
    sprintf("child deaths still fall too slowly — %d of %d above 25 per 1,000 stay above it in 2030 even in the UN projection; %d on pace",
            n_sdg_2030, n_sdg_above, n_sdg_pace),
    sprintf("fertility is below replacement but the population still grows — %d countries, %.1f bn (%s…)",
            length(iso_fila$inercia), pop_inercia_bn, paste(ej3(iso_fila$inercia), collapse = ", ")),
    sprintf("deaths already outnumber births — %d countries, %.0f %% of humanity; %d by 2050 (UN projection); e.g. China 2050: %.2f bn, UN 95 %% range %.2f–%.2f bn",
            length(iso_fila$natneg), dec(2023, "pct_pob_natneg"), dec(2050, "n_natneg"), pop_chn_2050_med,
            pi_chn$`Lower 95 PI` / 1e6, pi_chn$`Upper 95 PI` / 1e6),
    sprintf("net arrivals are the only source of growth — %d countries (%s…)", length(iso_fila$tipoC),
            paste(ej3(iso_fila$tipoC), collapse = ", ")),
    sprintf("emigration outweighs births — shrinking although births exceed deaths: %s (%d countries and areas) · and everywhere: census and civil registration",
            paste(ej3(iso_fila$tipoE), collapse = ", "), length(iso_fila$tipoE))),
  n_countries = vapply(iso_fila, length, integer(1)),
  n_countries_1m = vapply(caminos_fila, `[[`, integer(1), "n_1m"),
  road = vapply(caminos_fila, `[[`, "", "texto"),
  road_composition_1m = vapply(caminos_fila, `[[`, "", "comp"),
  watch = c("child survival and newborn care; voluntary family planning; births to adolescent girls",
            sprintf("plan %d–%d more years of growth (UN medium; India %d) in working and older ages; pensions and long-term care now; no pronatalist alarm",
                    mom_p25, mom_p75, inercia_pico$anios_crec[inercia_pico$ISO3_code == "IND"]),
            sprintf("healthy longevity (old-age gap widening: %s); measure mortality with life expectancy and adult mortality, not the crude death rate",
                    le65_sd_txt),
            "migrant inclusion and better arrival/departure data; read UN migration projections as scenarios (monitor, do not plan for a number)",
            "decent work, safe return and diaspora links; publish lever types with sensitivity windows"),
  mandate = c("SDG 3.2, 3.7 · ICPD PoA", "Decade of Healthy Ageing · MIPAA · SDG 1.3", "Decade of Healthy Ageing · SDG 3.4",
              "Global Compact for Migration obj. 1 & 16 · SDG 10.7", "GCM obj. 2 & 19 · SDG 8.8, 17.18–17.19"),
  agency = c("UNICEF · WHO · UNFPA", "UN DESA · WHO · ILO", "WHO · UN DESA", "IOM · UN DESA", "IOM · ILO · UNSD"),
  horizon = c("by 2030", "2030–2060", "now–2040", "now", "now / 2030 census round"),
  keys = c("n_sdg32_above, n_sdg32_on_pace, n_sdg32_above_2030", "n_momentum_countries, pop_momentum_bn (Q1), momentum_years_range",
           "n_natneg_2023, share_pop_natneg_2023, n_natneg_2050, pop_chn_2050_pi95_*, sd_le65_1950, sd_le65_2023", "n_grow_only_migration_2023 (Q1)",
           "examples_type_E (Q1)"))
print(rec_rows |> dplyr::select(row, n_countries, n_countries_1m, road, horizon), width = 200)

# =============================================================================
# 14. Tablas intermedias (parquet / csv)
# =============================================================================
# Qué: guarda todo lo que necesitan las figuras finales. Por qué: las figuras
# no recalculan nada (una sola fuente de verdad).
cat_sec("14. Tablas intermedias")
pc_rasgos <- pX$x[, 1:2]
paises_out <- paises_q3 |>
  dplyr::mutate(silueta = sil_ind[ISO3_code], keep_share = ks$keep_share[ISO3_code], fanny_max = fanny_max[ISO3_code],
                grupo_fpca = fpca$cl[ISO3_code], grupo_ward = cl_ward[ISO3_code], grupo_pam = cl_pam[ISO3_code],
                grupo_sin_cnmr = cl_sin[ISO3_code], grupo_asinh = cl_as[ISO3_code], grupo_niveles_2023 = cl_niv[ISO3_code],
                pc1_rasgos = pc_rasgos[ISO3_code, 1], pc2_rasgos = pc_rasgos[ISO3_code, 2],
                es_medoide = ISO3_code %in% medoides_iso, es_ejemplo = ISO3_code %in% unlist(ejemplos_iso),
                vecinos_mismo_grupo = vecinos_mismo[ISO3_code],
                voto_vecinos = stats::setNames(pred_vec, rownames(W5))[ISO3_code]) |>
  dplyr::left_join(picos |> dplyr::select(ISO3_code, anio_pico_pob, tipo_pico), by = "ISO3_code") |>
  dplyr::left_join(envejec |> dplyr::select(ISO3_code, y_medage30, y_medage40, anios_30_40, censura_30_40, y40_proyectado),
                   by = "ISO3_code") |>
  dplyr::left_join(cruces |> dplyr::select(ISO3_code, c5, c4, c3, dur53, evento53), by = "ISO3_code") |>
  dplyr::left_join(palanca |> dplyr::select(ISO3_code, tipo_palanca_2023 = tipo, inercia, natneg_2023 = natneg), by = "ISO3_code") |>
  dplyr::mutate(sdg32_above = ISO3_code %in% sdg$ISO3_code,
                sdg32_on_pace = ISO3_code %in% sdg$ISO3_code[sdg$on_pace],
                sdg32_above_2030 = ISO3_code %in% sdg$ISO3_code[sdg$above_2030],
                grupo = as.character(grupo), ingreso = as.character(ingreso)) |>
  dplyr::select(-pop2050)
arrow::write_parquet(paises_out, file.path(RUTA_PROCESSED, "resultados_q3_paises.parquet"))
arrow::write_parquet(tibble::as_tibble(X, rownames = "ISO3_code"), file.path(RUTA_PROCESSED, "resultados_q3_rasgos.parquet"))
arrow::write_parquet(bandas_grupo |> dplyr::mutate(grupo = as.character(grupo), periodo_en = as.character(periodo_en)),
                     file.path(RUTA_PROCESSED, "resultados_q3_bandas.parquet"))
arrow::write_parquet(dispersion |> dplyr::mutate(periodo_en = as.character(periodo_en)),
                     file.path(RUTA_PROCESSED, "resultados_q3_dispersion.parquet"))
arrow::write_parquet(curvas_q3 |> dplyr::mutate(grupo = as.character(grupo), periodo_en = as.character(periodo_en)),
                     file.path(RUTA_PROCESSED, "resultados_q3_curvas.parquet"))
arrow::write_parquet(rejilla, file.path(RUTA_PROCESSED, "resultados_q3_sensibilidad.parquet"))
vecinos_tab <- dplyr::bind_rows(
  tibble::tibble(W = "kNN5", grupo = names(jc$por_grupo), observado = jc$por_grupo, azar = jc$esperado,
                 banda_lo = NA_real_, banda_hi = NA_real_),
  purrr::imap_dfr(c(list(kNN5 = jc), jc_sens), function(r, w)
    tibble::tibble(W = w, grupo = "All", observado = r$obs, azar = r$nulo_media, banda_lo = r$lo, banda_hi = r$hi)))
arrow::write_parquet(vecinos_tab, file.path(RUTA_PROCESSED, "resultados_q3_vecinos.parquet"))
arrow::write_parquet(proyeccion_grupos |> dplyr::mutate(grupo = as.character(grupo), periodo_en = as.character(periodo_en)),
                     file.path(RUTA_PROCESSED, "resultados_q3_proyeccion.parquet"))
arrow::write_parquet(rec_rows, file.path(RUTA_PROCESSED, "resultados_q3_recomendaciones.parquet"))
envejec_grupo_out <- env_km_grupo |>
  dplyr::left_join(tibble::tibble(grupo = c("Fast movers", "Early movers"),
                                  ci_low = c(ic_env_fast$ci_low, ic_env_early$ci_low),
                                  ci_high = c(ic_env_fast$ci_high, ic_env_early$ci_high)), by = "grupo")
arrow::write_parquet(envejec_grupo_out, file.path(RUTA_PROCESSED, "resultados_q3_envejecimiento.parquet"))
arrow::write_parquet(inercia_pico, file.path(RUTA_PROCESSED, "resultados_q3_inercia_pico.parquet"))
readr::write_csv(paises_out |> dplyr::select(ISO3_code, Location, region_sdg, ingreso, grupo, keep_share, fanny_max, silueta) |>
                   dplyr::mutate(dplyr::across(c(keep_share, fanny_max, silueta), ~ round(.x, 3))),
                 file.path(RUTA_FIGURAS, "miembros_grupos.csv"))
cat("Tablas guardadas en data/processed/resultados_q3_*.parquet y figures/miembros_grupos.csv\n")

# =============================================================================
# 15. Figuras rápidas de revisión (figures/review/q3/, 1600 x 900)
# =============================================================================
# Qué: una gráfica por resultado principal, con títulos en inglés. Por qué:
# revisar que lo que se ve coincide con los números (NO son las finales).
cat_sec("15. Figuras de revisión")
tema_q3 <- theme_wpp(base_size = 15)
guardar_q3 <- function(p, nombre) guardar_png(p, nombre, carpeta = RUTA_Q3_REVIEW, ancho = 1600, alto = 900, res = 120)
etiq_var <- c(TFR = "Children per woman (TFR)", LEx = "Life expectancy at birth", MedianAgePop = "Median age",
              CNMR = "Net migration per 1,000", LE65 = "Life expectancy at 65", LE60 = "Life expectancy at 60",
              Q5 = "Under-5 deaths per 1,000 births")

# 15.1 Elección de k
fig_k <- tabla_k |> tidyr::pivot_longer(c(sil_kmeans, sil_ward, sil_pam), names_to = "metodo", values_to = "sil") |>
  dplyr::mutate(metodo = c(sil_kmeans = "k-means", sil_ward = "Ward", sil_pam = "PAM")[metodo])
g_k1 <- ggplot(fig_k, aes(k, sil, colour = metodo)) + geom_line(linewidth = 1) + geom_point(size = 2.5) +
  geom_vline(xintercept = K_GRUPOS, linetype = "dashed", colour = "grey40") +
  scale_colour_manual(values = c("k-means" = "#332288", Ward = "#999999", PAM = "#E69F00")) +
  labs(x = "Number of groups k", y = "Mean silhouette", colour = NULL,
       subtitle = sprintf("k-means silhouette: k = 2 %.2f · k = 4 %.2f (fixed a priori)", tabla_k$sil_kmeans[1], sil_k4)) + tema_q3
gap_df <- data.frame(k = seq_len(nrow(gap$Tab)), gap = unname(gap$Tab[, "gap"]), se = unname(gap$Tab[, "SE.sim"]))
g_k2 <- ggplot(gap_df, aes(k, gap)) + geom_errorbar(aes(ymin = gap - se, ymax = gap + se), width = 0.15, colour = "grey50") +
  geom_line(colour = "#332288") + geom_point(size = 2.5, colour = "#332288") +
  geom_vline(xintercept = k_gap, linetype = "dotted") +
  labs(x = "Number of groups k", y = "Gap statistic", subtitle = sprintf("Tibshirani 1-SE rule picks k = %d", k_gap)) + tema_q3
guardar_q3((g_k1 | g_k2) + plot_annotation(
  title = "Three stretches of one road, plus a small migration group: the data prefer k = 2-3, k = 4 adds a mostly-Gulf group",
  caption = paste(badge("PIE-3"), "· gap bars = ±1 simulation SE (B = 100) · 32 features = decade means 1950s-2020s of TFR, LEx, median age, winsorized net migration"),
  theme = tema_q3), "q3_01_k_choice")

# 15.2 Pequeños múltiplos por grupo (mediana + P10-P90), estimación 1950-2023 y proyección gris 2024-2050
etiq_corta <- c(TFR = "Children per woman", MedianAgePop = "Median age", LEx = "Life expectancy",
                CNMR = "Net migration ‰\n(clipped)")
recorta <- function(x, v) ifelse(v == "CNMR", pmin(pmax(x, -30), 50), x)
b2 <- bandas_grupo |> dplyr::filter(variable %in% names(etiq_corta), Time <= 2050) |>
  dplyr::mutate(dplyr::across(c(mediana, p10, p90), ~ recorta(.x, variable)),
                variable = factor(etiq_corta[variable], levels = etiq_corta))
med_lin <- pan_todo161 |> dplyr::filter(ISO3_code %in% medoides_iso, Time <= 2050) |>
  tidyr::pivot_longer(c(TFR, MedianAgePop, LEx, CNMR), names_to = "variable", values_to = "valor") |>
  dplyr::mutate(valor = recorta(valor, variable), variable = factor(etiq_corta[variable], levels = etiq_corta))
etq_grupo <- desc_grupos |> dplyr::mutate(etq = sprintf("%s\n%d countries · %.2f bn\n%s · medoid %s", grupo, n, pop_bn, ejemplos, medoide))
b2$grupo_etq <- factor(etq_grupo$etq[match(b2$grupo, etq_grupo$grupo)], levels = etq_grupo$etq)
med_lin$grupo_etq <- factor(etq_grupo$etq[match(med_lin$grupo, etq_grupo$grupo)], levels = etq_grupo$etq)
b2_est <- b2 |> dplyr::filter(periodo_en == ETIQUETA_ESTIMACION); b2_proy <- b2 |> dplyr::filter(periodo_en == ETIQUETA_PROYECCION)
g2 <- ggplot(mapping = aes(Time)) +
  geom_ribbon(data = b2_est, aes(ymin = p10, ymax = p90, fill = grupo), alpha = 0.35) +
  geom_ribbon(data = b2_proy, aes(ymin = p10, ymax = p90), fill = COLOR_PROYECCION, alpha = 0.45) +
  geom_line(data = b2_est, aes(y = mediana, colour = grupo), linewidth = 1) +
  geom_line(data = b2_proy, aes(y = mediana), colour = "grey40", linewidth = 0.8, linetype = "dashed") +
  geom_line(data = med_lin |> dplyr::filter(Time <= ANIO_FIN_ESTIMACION), aes(y = valor), colour = "black", linewidth = 0.35) +
  geom_line(data = med_lin |> dplyr::filter(Time >= ANIO_INICIO_PROYECCION), aes(y = valor), colour = "grey30", linewidth = 0.3, linetype = "dotted") +
  geom_vline(xintercept = 2023.5, colour = "grey50", linewidth = 0.3) +
  facet_grid(variable ~ grupo_etq, scales = "free_y", switch = "y") +
  scale_fill_manual(values = PALETA_GRUPOS_V2, guide = "none") + scale_colour_manual(values = PALETA_GRUPOS_V2, guide = "none") +
  scale_x_continuous(breaks = c(1960, 2000, 2040)) +
  labs(x = NULL, y = NULL, title = "Four roads: median and P10-P90 band of each group, estimates 1950-2023 (colour) and UN medium projection 2024-2050 (grey)",
       caption = paste(badge("PIE-3"), "· thin black line = medoid country · net migration not winsorized, clipped at -30/+50 for display")) +
  tema_q3 + theme(strip.text.y = element_text(size = 11), strip.text.x = element_text(size = 9.5), strip.placement = "outside",
                  plot.title = element_text(size = 14))
guardar_q3(g2, "q3_02_groups_small_multiples")

# 15.3 Mapa de caminos (Robinson; claros = keep_share < 0,8; gris = < 1 M)
mapa <- mundo_ne |> dplyr::select(iso3, geometry)
suppressMessages(sf::sf_use_s2(FALSE))
partes_rus <- sf::st_cast(sf::st_geometry(mapa[mapa$iso3 == "RUS", ]), "POLYGON")
cen_rus <- suppressWarnings(sf::st_coordinates(sf::st_centroid(partes_rus)))
es_crimea <- cen_rus[, 1] > 32 & cen_rus[, 1] < 37 & cen_rus[, 2] > 44 & cen_rus[, 2] < 46.5
if (any(es_crimea)) {   # Crimea -> Ucrania (A/RES/68/262), como en los mapas de la ONU
  geom_ukr <- suppressMessages(sf::st_union(c(sf::st_geometry(mapa[mapa$iso3 == "UKR", ]), partes_rus[es_crimea])))
  geom_rus <- suppressMessages(sf::st_union(partes_rus[!es_crimea]))
  sf::st_geometry(mapa)[mapa$iso3 == "UKR"] <- geom_ukr
  sf::st_geometry(mapa)[mapa$iso3 == "RUS"] <- geom_rus
}
# Departamentos de ultramar (Guayana Francesa, Reunión, ...) y el Caribe neerlandés son áreas propias
# en WPP (< 1 M): se separan de FRA / NLD para no pintarlas con el camino de Europa.
for (.iso in c("FRA", "NLD")) {
  .partes <- sf::st_cast(sf::st_geometry(mapa[mapa$iso3 == .iso, ]), "POLYGON")
  .cen <- suppressWarnings(sf::st_coordinates(sf::st_centroid(.partes)))
  .eur <- .cen[, 1] > -30 & .cen[, 2] > 30
  if (any(!.eur)) {
    sf::st_geometry(mapa)[mapa$iso3 == .iso] <- suppressMessages(sf::st_union(.partes[.eur]))
    mapa <- rbind(mapa, sf::st_sf(iso3 = paste0(.iso, "_ultramar"), geometry = suppressMessages(sf::st_union(.partes[!.eur]))))
  }
}
suppressMessages(sf::sf_use_s2(TRUE))
mapa <- mapa |> dplyr::filter(iso3 != "ATA") |>
  dplyr::mutate(grupo = factor(as.character(grupo[iso3]), levels = NIVELES_GRUPO),
                estable = ks$keep_share[iso3] >= 0.8) |>
  sf::st_transform("+proj=robin")
g3 <- ggplot(mapa) +
  geom_sf(aes(fill = grupo, alpha = ifelse(is.na(estable) | estable, "stable", "borderline")), colour = "white", linewidth = 0.1) +
  scale_fill_manual(values = PALETA_GRUPOS_V2, na.value = "#DDDDDD", na.translate = TRUE,
                    labels = c(NIVELES_GRUPO, "< 1 M people (not grouped)"), name = NULL) +
  scale_alpha_manual(values = c(stable = 1, borderline = 0.45), name = NULL,
                     labels = c(borderline = "lighter: stays in its group in < 80 % of resamples", stable = "stable"),
                     guide = guide_legend(override.aes = list(fill = "#117733"))) +
  coord_sf(crs = "+proj=robin", expand = FALSE) +
  labs(title = sprintf("Neighbours tend to share a road: %.0f %% of neighbour links are on the same road (chance %.0f %%)",
                       100 * jc$obs, 100 * jc$nulo_media),
       subtitle = sprintf("%d countries ≥ 1 M grouped by 70 years of movement (k-means, k = 4) · %d borderline countries shown lighter",
                          N_PAISES_1M, length(iso_frontera)),
       caption = paste(badge("PIE-3"), "\nBoundaries and names shown do not imply official endorsement or acceptance by the United Nations. Map: Natural Earth.")) +
  tema_q3 + theme(panel.grid.major = element_line(colour = "#EEEEEE"), legend.box = "vertical")
guardar_q3(g3, "q3_03_groups_map")

# 15.4 Continuo: plano de los rasgos (PC1-PC2), transparencia = pertenencia difusa
df4 <- paises_out |> dplyr::mutate(etq = ifelse(es_ejemplo | es_medoide | ISO3_code %in% c(GOLFO, "KOR"), ISO3_code, NA))
g4 <- ggplot(df4, aes(pc1_rasgos, pc2_rasgos, colour = grupo)) +
  geom_point(aes(alpha = fanny_max), size = 3) +
  ggrepel::geom_text_repel(aes(label = etq), size = 3.3, show.legend = FALSE, max.overlaps = 30, na.rm = TRUE) +
  scale_colour_manual(values = PALETA_GRUPOS_V2, name = NULL) +
  scale_alpha_continuous(range = c(0.25, 1), name = "Fuzzy membership (max)") +
  labs(x = sprintf("Axis 1 of the 32 trajectory features (%.0f %% of variance)", 100 * var_pcs_rasgos[1]),
       y = sprintf("Axis 2 (%.0f %%)", 100 * var_pcs_rasgos[2]),
       title = sprintf("A continuum, not boxes: groups explain %.0f %% of axis 1; %.0f %% of countries sit between two groups",
                       100 * r2_eje1, 100 * share_entre),
       subtitle = "Faded points: maximum fuzzy membership < 0.6 (fanny, membership exponent 1.5)",
       caption = badge("PIE-3")) + tema_q3
guardar_q3(g4, "q3_04_continuum")

# 15.5 Estabilidad: Jaccard por grupo y keep_share por país
df5a <- tibble::tibble(grupo = factor(names(jaccard_grupo), levels = NIVELES_GRUPO), j = jaccard_grupo)
g5a <- ggplot(df5a, aes(grupo, j, fill = grupo)) + geom_col(width = 0.6) +
  geom_hline(yintercept = c(0.6, 0.75), linetype = c("dotted", "dashed"), colour = "grey30") +
  geom_text(aes(label = sprintf("%.2f", j)), vjust = -0.4, size = 4.5) +
  scale_fill_manual(values = PALETA_GRUPOS_V2, guide = "none") + scale_y_continuous(limits = c(0, 1.05)) +
  labs(x = NULL, y = "Mean bootstrap Jaccard", subtitle = "200 resamples of countries; dashed = stable (0.75)") + tema_q3
g5b <- ggplot(paises_out, aes(keep_share, fill = factor(grupo, levels = NIVELES_GRUPO))) + geom_histogram(binwidth = 0.05, boundary = 1, colour = "white") +
  geom_vline(xintercept = 0.8, linetype = "dashed") +
  scale_fill_manual(values = PALETA_GRUPOS_V2, name = NULL) +
  labs(x = "Share of 80 % subsamples in which the country stays in its group", y = "Countries",
       subtitle = sprintf("%.0f %% of countries keep their group in ≥ 80 %% of 500 subsamples", 100 * share_keep)) + tema_q3
guardar_q3((g5a | g5b) + plot_annotation(title = "The four roads come back when countries are resampled",
                                         caption = badge("PIE-3"), theme = tema_q3), "q3_05_stability")

# 15.6 Rejilla de sensibilidad
df6 <- rejilla |> dplyr::mutate(fila = paste0(muestra, " countries · migration ", cnmr, " · ", sub(" \\(FPCA.*", "", periodo)),
                                metodo = factor(metodo, levels = c("k-means", "Ward", "PAM", "FPCA")))
g6 <- ggplot(df6, aes(metodo, fila, fill = ari)) + geom_tile(colour = "white") +
  geom_text(aes(label = sprintf("%.2f", ari)), size = 4.2, colour = ifelse(df6$ari > 0.6, "white", "black")) +
  scale_fill_gradient(low = "#F0F0F0", high = "#332288", limits = c(0, 1), name = "ARI vs main",
                      guide = guide_colourbar(barwidth = grid::unit(14, "lines"))) +
  labs(x = NULL, y = NULL, title = "Which decisions move the groups? Agreement (ARI) with the main partition",
       subtitle = "Dropping net migration changes the groups most; method and period length change them less (FPCA uses annual curves)",
       caption = badge("PIE-3")) + tema_q3
guardar_q3(g6, "q3_06_sensitivity_grid")

# 15.7 Vecinos en el mismo camino, por grupo
df7 <- tibble::tibble(grupo = factor(names(jc$por_grupo), levels = NIVELES_GRUPO), obs = jc$por_grupo, azar = jc$esperado)
g7 <- ggplot(df7, aes(grupo, obs, fill = grupo)) + geom_col(width = 0.6) +
  geom_point(aes(y = azar), shape = 23, size = 4, fill = "white") +
  geom_text(aes(label = sprintf("%.0f %%", 100 * obs)), vjust = -0.5, size = 4.5) +
  scale_fill_manual(values = PALETA_GRUPOS_V2, guide = "none") + scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(x = NULL, y = "Neighbour links on the same road",
       title = sprintf("Two in three neighbour links share a road (%.0f %%; chance %.0f %%, 95 %% band %.0f-%.0f %%)",
                       100 * jc$obs, 100 * jc$nulo_media, 100 * jc$lo, 100 * jc$hi),
       subtitle = sprintf("White diamond = chance. Neighbour vote guesses the road of %.0f %% of countries; the SDG region alone %.0f %%",
                          100 * acc_vecinos, 100 * acc_region),
       caption = paste(badge("PIE-3"), "· W = 5 nearest countries (great-circle distance between Natural Earth label points)")) + tema_q3
guardar_q3(g7, "q3_07_neighbours")


# 15.8 Bandas de divergencia P10-P90 (161), estimación y proyección
banda_p1 <- function(var, log_y = FALSE) {
  d <- dispersion |> dplyr::filter(universo == UNIVERSO_1M, variable == var)
  g <- ggplot(d, aes(Time)) +
    geom_ribbon(aes(ymin = p10, ymax = p90, fill = periodo_en), alpha = 0.5) +
    geom_line(aes(y = p50, colour = periodo_en), linewidth = 0.9) +
    geom_vline(xintercept = 2023.5, colour = "grey40", linewidth = 0.3) +
    scale_fill_manual(values = c(Estimate = "#56B4E9", `UN medium projection` = COLOR_PROYECCION), name = NULL) +
    scale_colour_manual(values = c(Estimate = "#0072B2", `UN medium projection` = "grey45"), name = NULL) +
    labs(x = NULL, y = NULL, subtitle = etiq_var[[var]]) + tema_q3
  if (log_y) g <- g + scale_y_log10()
  g
}
g8 <- (banda_p1("LEx") | banda_p1("MedianAgePop")) / (banda_p1("LE65") | banda_p1("Q5", log_y = TRUE)) +
  plot_layout(guides = "collect") +
  plot_annotation(
    title = sprintf("Closer in life expectancy (SD %.1f → %.1f), further apart in age (SD %.1f → %.1f) and in relative child survival (P90/P10 %.0f× → %.0f×)",
                    d1("LEx", 1950), d1("LEx", 2023), d1("MedianAgePop", 1950), d1("MedianAgePop", 2023),
                    d1("Q5", 1950, "razon_p90p10"), d1("Q5", 2023, "razon_p90p10")),
    subtitle = "Band = P10-P90 across 161 countries ≥ 1 M; line = median · under-5 mortality on a log scale",
    caption = badge("PIE-0", "PIE-3"), theme = tema_q3 + theme(plot.title = element_text(size = 14))) &
  theme(legend.position = "bottom")
guardar_q3(g8, "q3_08_divergence_bands")

# 15.9 DE (y razón P90/P10 de Q5) por año
d9 <- dispersion |> dplyr::filter(universo %in% c(UNIVERSO_1M, UNIVERSO_237)) |>
  dplyr::mutate(estad = dplyr::case_when(variable == "Q5" ~ razon_p90p10, TRUE ~ de),
                panel = ifelse(variable == "Q5", "Under-5 mortality: P90 / P10 ratio",
                               paste("SD of", c(TFR = "children per woman (TFR)", LEx = "life expectancy at birth",
                                                MedianAgePop = "median age", LE65 = "life expectancy at 65",
                                                LE60 = "life expectancy at 60")[variable])))
g9 <- ggplot(d9, aes(Time, estad, colour = universo, linetype = periodo_en)) + geom_line(linewidth = 0.8) +
  geom_vline(xintercept = 2023.5, colour = "grey50", linewidth = 0.3) +
  facet_wrap(~ panel, scales = "free_y") +
  scale_colour_manual(values = stats::setNames(c("#332288", "#E69F00"), c(UNIVERSO_1M, UNIVERSO_237)), name = NULL) +
  scale_linetype_manual(values = c(Estimate = "solid", `UN medium projection` = "dashed"), name = NULL) +
  labs(x = NULL, y = NULL, title = "Dispersion across countries by year: estimates 1950-2023 (solid) and UN medium projection (dashed)",
       subtitle = sprintf("SD of median age peaks in %d (projection); SD of fertility peaked in %d; the Q5 P90/P10 ratio peaked at %.1f× in %d (estimates)",
                          anio_max_de$anio_max[anio_max_de$variable == "MedianAgePop" & anio_max_de$periodo_en == ETIQUETA_PROYECCION],
                          anio_max_de$anio_max[anio_max_de$variable == "TFR" & anio_max_de$periodo_en == ETIQUETA_ESTIMACION],
                          q5_pico$razon_p90p10, q5_pico$Time),
       caption = badge("PIE-0")) + tema_q3
guardar_q3(g9, "q3_09_dispersion_sd")

# 15.10 Proyección por grupo: componentes 2024-2050 y edad mediana 2023 -> 2050
d10 <- comp_proy |> dplyr::select(grupo, `Natural change` = nat_pct_pob, `Net migration` = mig_pct_pob) |>
  tidyr::pivot_longer(-grupo, names_to = "componente", values_to = "pct")
g10a <- ggplot(d10, aes(grupo, pct, fill = componente)) + geom_col(width = 0.6) +
  geom_point(data = comp_proy, aes(grupo, cambio_pct_pob), inherit.aes = FALSE, shape = 21, size = 4, fill = "white") +
  geom_hline(yintercept = 0, colour = "grey30") +
  scale_fill_manual(values = c(`Natural change` = COLOR_NACIMIENTOS, `Net migration` = COLOR_MIGRACION), name = NULL) +
  labs(x = NULL, y = "% of the 2024 population", subtitle = "Change 2024-2050 by component (white dot = total)") + tema_q3 +
  theme(axis.text.x = element_text(size = 11))
d10b <- edad_grupo |> dplyr::select(grupo, Time, mediana) |> tidyr::pivot_wider(names_from = Time, values_from = mediana, names_prefix = "y")
g10b <- ggplot(d10b) + geom_segment(aes(x = y2023, xend = y2050, y = grupo, yend = grupo), colour = "grey60", linewidth = 1.2,
                                    arrow = grid::arrow(length = grid::unit(0.18, "cm"))) +
  geom_point(aes(y2023, grupo, colour = grupo), size = 4) + geom_point(aes(y2050, grupo), colour = "grey45", size = 4) +
  geom_text(aes(y2050, grupo, label = sprintf("%.1f", y2050)), nudge_x = 0.7, hjust = 0, size = 3.8) +
  geom_text(aes(y2023, grupo, label = sprintf("%.1f", y2023)), nudge_x = -0.7, hjust = 1, size = 3.8) +
  scale_x_continuous(expand = expansion(mult = 0.12)) +
  scale_colour_manual(values = PALETA_GRUPOS_V2, guide = "none") +
  labs(x = "Median age (median across countries)", y = NULL, subtitle = "Median age 2023 (colour) → 2050 (grey, UN medium)") + tema_q3
guardar_q3((g10a | g10b) + plot_annotation(
  title = "UN medium projection 2024-2050: each road has a different engine of change",
  caption = paste(badge("PIE-5"), "· sums of persons, 161 countries ≥ 1 M; a scenario, not a forecast"), theme = tema_q3),
  "q3_10_projection_groups")

# 15.11 Velocidad del envejecimiento (edad mediana 30 -> 40)
d11 <- env_obs |> dplyr::mutate(etq = ifelse(ISO3_code %in% c("KOR", "JPN", "CHN", "ITA", "USA", "FRA", "BRA", "IRN", "THA", "DEU", "GBR", "SWE"), ISO3_code, NA))
g11 <- ggplot(d11, aes(y_medage30, anios_30_40, colour = grupo)) +
  annotate("rect", xmin = 2023.5, xmax = Inf, ymin = -Inf, ymax = Inf, fill = COLOR_PROYECCION_SOMBRA) +
  geom_point(aes(shape = y40_proyectado), size = 3, stroke = 1) +
  ggrepel::geom_text_repel(aes(label = etq), size = 3.6, show.legend = FALSE, na.rm = TRUE) +
  scale_shape_manual(values = c(`FALSE` = 16, `TRUE` = 1), labels = c("reached 40 by 2023 (estimate)", "reaches 40 after 2023 (UN medium)"), name = NULL) +
  scale_colour_manual(values = PALETA_GRUPOS_V2, name = NULL) +
  labs(x = "Year median age first reached 30", y = "Years from median age 30 to 40",
       title = sprintf("Ageing is speeding up, but it is not unprecedented: Korea took %d years, Japan %d, China %d (30 → 40)",
                       yrs30_40["KOR"], yrs30_40["JPN"], yrs30_40["CHN"]),
       subtitle = sprintf("Median: %.1f years for countries reaching 30 before 1990 vs %.1f for those reaching it in 1990-2023 (%d of %d reach 40 only in the projection)",
                          med_temprano, med_reciente, n_y40_proy_reciente, n_reciente),
       caption = paste(badge("PIE-0"), "· countries already ≥ 30 in 1950 excluded; not reaching 40 by 2100 not shown")) + tema_q3
guardar_q3(g11, "q3_11_ageing_speed")

# 15.11b Envejecimiento POR CAMINO: curvas de Kaplan-Meier (30 -> 40) de Fast y Early movers
km_fe <- survival::survfit(survival::Surv(anios_30_40, !censura_30_40) ~ grupo,
                           data = env_base_grupo |> dplyr::filter(grupo %in% c("Early movers", "Fast movers")) |>
                             dplyr::mutate(grupo = droplevels(factor(grupo, levels = NIVELES_GRUPO))))
d11b <- tibble::tibble(t = km_fe$time, s = km_fe$surv,
                       grupo = rep(sub("grupo=", "", names(km_fe$strata)), km_fe$strata)) |>
  dplyr::group_by(grupo) |>
  dplyr::group_modify(~ dplyr::bind_rows(tibble::tibble(t = 0, s = 1), .x)) |> dplyr::ungroup()
d11b_med <- tibble::tibble(grupo = c("Fast movers", "Early movers"), med = c(med_g("Fast movers"), med_g("Early movers")),
                           lo = c(ic_env_fast$ci_low, ic_env_early$ci_low), hi = c(ic_env_fast$ci_high, ic_env_early$ci_high))
g11b <- ggplot(d11b, aes(t, 1 - s, colour = grupo)) + geom_step(linewidth = 1.3) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey50") +
  geom_segment(data = d11b_med |> dplyr::mutate(yy = c(0.47, 0.53)), aes(x = lo, xend = hi, y = yy, yend = yy, colour = grupo),
               inherit.aes = FALSE, linewidth = 0.9) +
  geom_point(data = d11b_med, aes(x = med, y = 0.5, colour = grupo), inherit.aes = FALSE, size = 3.5) +
  scale_colour_manual(values = PALETA_GRUPOS_V2, name = NULL) +
  scale_y_continuous(labels = scales::percent) +
  labs(x = "Years since median age first reached 30", y = "Share of the group that has reached median age 40",
       title = sprintf("Median age 30 → 40 by road: Fast movers %.0f years [%.0f-%.0f] vs Early movers %.1f [%.0f-%.1f]",
                       med_g("Fast movers"), ic_env_fast$ci_low, ic_env_fast$ci_high, med_g("Early movers"), ic_env_early$ci_low, ic_env_early$ci_high),
       subtitle = sprintf("Roads differ less than start dates. Kaplan-Meier, censored at 2100. %d of %d Fast movers reach 30 only after 2023 (UN medium projection).\nFast movers already at 30 by 2023: %.1f years. %d Early movers already ≥ 30 in 1950 are left out (start not observed).",
                          env_km_grupo$n_inicio_proy[env_km_grupo$grupo == "Fast movers"], env_km_grupo$n[env_km_grupo$grupo == "Fast movers"],
                          med_fast_iniciados, env_km_grupo$n_izq_1950[env_km_grupo$grupo == "Early movers"]),
       caption = paste(badge("PIE-0", "PIE-5"), "· bars = 95 % block bootstrap by UN subregion (B = 2,000)")) + tema_q3
guardar_q3(g11b, "q3_18_ageing_by_road")

# 15.12 Año del pico de población por país, por grupo
d12 <- picos |> dplyr::left_join(paises_q3 |> dplyr::select(ISO3_code, pop2023), by = "ISO3_code")
g12 <- ggplot(d12, aes(anio_pico_pob, grupo, colour = grupo)) +
  annotate("rect", xmin = 2023.5, xmax = 2101, ymin = -Inf, ymax = Inf, fill = COLOR_PROYECCION_SOMBRA) +
  geom_point(aes(size = pop2023 / 1e3), alpha = 0.7, position = position_jitter(height = 0.22, width = 0, seed = SEMILLA)) +
  ggrepel::geom_text_repel(data = d12 |> dplyr::filter(ISO3_code %in% c("CHN", "IND", "USA", "JPN", "RUS", "BRA", "NGA", "DEU", "IDN", "PAK")),
                           aes(label = ISO3_code), size = 3.4, colour = "black", seed = SEMILLA) +
  scale_colour_manual(values = PALETA_GRUPOS_V2, guide = "none") + scale_size_area(max_size = 12, name = "Population 2023 (M)") +
  labs(x = "Year of maximum population, 1950-2100 (2100 = no peak before 2100)", y = NULL,
       title = sprintf("Peak population year by road: %d countries already peaked by 2023; %d have no peak before 2100 (UN medium)",
                       sum(picos$tipo_pico == "peaked by 2023 (estimate)"), sum(picos$tipo_pico == "no peak before 2100 (projection)")),
       caption = paste(badge("PIE-5"), "· shaded = UN medium projection")) + tema_q3
guardar_q3(g12, "q3_12_peak_year")

# 15.13 Mundo: población y número de países que decrecen
d13 <- mundo |> dplyr::select(Time, pob = TPopulation1July, periodo_en)
g13a <- ggplot(d13, aes(Time, pob / 1e6, linetype = periodo_en)) + geom_line(linewidth = 1, colour = "#332288") +
  geom_point(data = pico_mundo, aes(Time, TPopulation1July / 1e6), inherit.aes = FALSE, size = 3) +
  annotate("text", x = pico_mundo$Time, y = pico_mundo$TPopulation1July / 1e6 + 0.45,
           label = sprintf("peak %d: %.2f bn", pico_mundo$Time, pico_mundo$TPopulation1July / 1e6), size = 4) +
  scale_linetype_manual(values = c(Estimate = "solid", `UN medium projection` = "dashed"), name = NULL) +
  labs(x = NULL, y = "World population (billions)") + tema_q3
d13b <- decrecen |> dplyr::filter(Time > 1950) |> dplyr::select(Time, periodo_en, `Shrinking (population change < 0)` = n_decrecen,
                                                               `Deaths outnumber births` = n_natneg) |>
  tidyr::pivot_longer(-c(Time, periodo_en), names_to = "serie", values_to = "n")
g13b <- ggplot(d13b, aes(Time, n, colour = serie, linetype = periodo_en)) + geom_line(linewidth = 0.9) +
  scale_colour_manual(values = c(`Shrinking (population change < 0)` = COLOR_EMIGRACION, `Deaths outnumber births` = COLOR_DEFUNCIONES), name = NULL) +
  scale_linetype_manual(values = c(Estimate = "solid", `UN medium projection` = "dashed"), guide = "none") +
  labs(x = NULL, y = "Countries and areas (of 237)",
       subtitle = sprintf("Shrinking: %d (2023) → %d (2050) → %d (2100)\nDeaths > births: %d (1990) → %d (2023) → %d (2050)",
                          dec(2023, "n_decrecen"), dec(2050, "n_decrecen"), dec(2100, "n_decrecen"),
                          dec(1990, "n_natneg"), dec(2023, "n_natneg"), dec(2050, "n_natneg"))) +
  tema_q3 + theme(legend.box = "vertical")
guardar_q3((g13a | g13b) + plot_annotation(title = "The world keeps growing to a peak while more countries shrink",
                                           caption = badge("PIE-1", "PIE-5"), theme = tema_q3), "q3_13_world")

# 15.14 Curvas atípicas de LEx
d14 <- pan_p1 |> dplyr::filter(pob_1m %in% TRUE, Time <= ANIO_FIN_ESTIMACION) |>
  dplyr::mutate(tipo = dplyr::case_when(ISO3_code == "CAF" ~ "CAF (possible artefact)",
                                        ISO3_code %in% atip_nivel ~ "atypical level (MBD)",
                                        ISO3_code %in% atip_forma ~ "atypical shape (yearly changes)",
                                        TRUE ~ "other"))
etq14 <- d14 |> dplyr::filter(tipo != "other") |> dplyr::group_by(ISO3_code) |> dplyr::slice_min(LEx, n = 1, with_ties = FALSE)
g14 <- ggplot(d14, aes(Time, LEx, group = ISO3_code)) +
  geom_line(data = d14 |> dplyr::filter(tipo == "other"), colour = "grey80", linewidth = 0.3) +
  geom_line(data = d14 |> dplyr::filter(tipo != "other"), aes(colour = tipo), linewidth = 0.8) +
  ggrepel::geom_text_repel(data = etq14, aes(label = ISO3_code, colour = tipo), size = 3.5, show.legend = FALSE, seed = SEMILLA) +
  scale_colour_manual(values = c("atypical level (MBD)" = "#332288", "atypical shape (yearly changes)" = "#E69F00",
                                 "CAF (possible artefact)" = "#CC79A7"), name = NULL) +
  labs(x = NULL, y = "Life expectancy at birth (years)",
       title = "The most unusual life-expectancy paths are crisis paths",
       subtitle = sprintf("Functional boxplot (MBD) outliers: %s · least deep in shape: %s",
                          paste(atip_nivel, collapse = ", "), paste(atip_forma, collapse = ", ")),
       caption = paste(badge("PIE-0"), "· raw annual estimates 1950-2023 · CAF one-year collapses flagged as possible WPP crisis adjustments")) + tema_q3
guardar_q3(g14, "q3_14_atypical_lex")

# 15.15 Kaplan-Meier de 5 a 3 hijos por camino
km_df <- purrr::map_dfr(seq_along(km53$strata), function(i) {
  s <- km53[i]
  tibble::tibble(grupo = sub("grupo=", "", names(km53$strata)[i]), t = c(0, s$time), surv = c(1, s$surv))
})
g15 <- ggplot(km_df, aes(t, 1 - surv, colour = grupo)) + geom_step(linewidth = 1) +
  scale_colour_manual(values = PALETA_GRUPOS_V2, name = NULL) + scale_y_continuous(labels = scales::percent) +
  labs(x = "Years since fertility (smoothed) last fell below 5", y = "Share already below 3",
       title = "Same road, different speed: years from 5 to 3 children per woman, by road (Kaplan-Meier)",
       subtitle = paste(sprintf("%s: median %s (n = %d)", km53_med$grupo,
                                ifelse(is.na(km53_med$mediana), "not reached", sprintf("%.1f y", km53_med$mediana)), km53_med$n), collapse = " · "),
       caption = paste(badge("PIE-3"), "· censored at 2023; countries already below 5 in 1950 not included")) + tema_q3
guardar_q3(g15, "q3_15_speed_53_km")

# 15.16 Tabla de recomendaciones: composición por camino de cada fila
d16 <- purrr::map_dfr(seq_along(iso_fila), function(i) {
  g <- stats::na.omit(as.character(grupo[iso_fila[[i]][iso_fila[[i]] %in% names(grupo)]]))
  tibble::tibble(fila = i, grupo = g)
}) |> dplyr::count(fila, grupo) |>
  dplyr::mutate(fila_etq = factor(c("1 Child deaths fall too slowly (Q5 > 25)", "2 Below replacement, still growing",
                                    "3 Deaths outnumber births", "4 Growing only through net arrivals",
                                    "5 Emigration outweighs births")[fila],
                                  levels = rev(c("1 Child deaths fall too slowly (Q5 > 25)", "2 Below replacement, still growing",
                                                 "3 Deaths outnumber births", "4 Growing only through net arrivals",
                                                 "5 Emigration outweighs births"))),
                grupo = factor(grupo, levels = NIVELES_GRUPO))
g16 <- ggplot(d16, aes(n, fila_etq, fill = grupo)) + geom_col(width = 0.65) +
  geom_text(aes(label = n), position = position_stack(vjust = 0.5), colour = "white", size = 4) +
  scale_fill_manual(values = PALETA_GRUPOS_V2, name = NULL) +
  labs(x = "Countries ≥ 1 M in the row", y = NULL,
       title = "Which road do the countries of each watch-list row travel?",
       subtitle = paste(sprintf("Row %d: %s", rec_rows$row, rec_rows$road), collapse = "\n"),
       caption = paste(badge("PIE-1"), "· lever state 2023 (237 countries and areas); roads only for countries ≥ 1 M")) +
  tema_q3 + theme(plot.subtitle = element_text(size = 10.5))
guardar_q3(g16, "q3_16_watchlist_roads")

# 15.17 ODS 3.2: ritmo observado vs necesario
d17 <- sdg |> dplyr::mutate(grupo = as.character(grupo), grupo = ifelse(is.na(grupo), "< 1 M (not grouped)", grupo),
                            etq = ifelse(pob_1m & (on_pace | ISO3_code %in% c("NGA", "PAK", "COD", "ETH", "IND")), ISO3_code, NA))
g17 <- ggplot(d17, aes(ritmo_necesario, ritmo_obs, colour = grupo)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") + geom_point(size = 3, alpha = 0.85) +
  ggrepel::geom_text_repel(aes(label = etq), size = 3.4, show.legend = FALSE, na.rm = TRUE, seed = SEMILLA) +
  scale_colour_manual(values = c(PALETA_GRUPOS_V2, `< 1 M (not grouped)` = COLOR_SIN_DATOS), name = NULL) +
  labs(x = "Annual reduction needed 2023-2030 to reach 25 per 1,000 (%)", y = "Observed annual reduction 2015-2023 (%)",
       title = sprintf("Only %d of %d countries above 25 under-5 deaths per 1,000 are cutting them fast enough for 2030", n_sdg_pace, n_sdg_above),
       subtitle = sprintf("Above the dashed line = on pace · %d would still be above 25 in 2030 even in the UN medium projection", n_sdg_2030),
       caption = badge("PIE-1")) + tema_q3
guardar_q3(g17, "q3_17_sdg32_pace")
cat("Figuras guardadas en", RUTA_Q3_REVIEW, ":", length(list.files(RUTA_Q3_REVIEW, pattern = "\\.png$")), "PNG\n")

# =============================================================================
# 16. Registro de cifras: figures/numbers_q3.json (esquema v2, plan §4)
# =============================================================================
# Qué: cada cifra con def, filtro, método, IC o sensibilidad, estado e
# hipótesis. Por qué: ninguna cifra del vídeo se escribe a mano.
cat_sec("16. numbers_q3.json")
reg <- nuevo_registro()
U1 <- UNIVERSO_1M; U237 <- UNIVERSO_237
F161 <- "161 countries ≥ 1 M (2023), UN estimates 1950-2023"
NOTA_RASGOS <- "32 features = decade means (1950s ... 2010s, 2020-23) of TFR, LEx, median age and net migration rate (winsorized ±3 SD of the panel), z-scored over the whole 161 x 1950-2023 panel"
ub1 <- c("slide4.build1", "narration.s4")
fx <- function(x) formatear_cifra(x, "0.00")

# --- 16.1 Clustering (T11) ---------------------------------------------------
reg <- registrar_cifra(reg, "k_clusters", K_GRUPOS, "groups", "0",
  "Number of trajectory groups (k-means), fixed a priori in the pre-specified hypothesis H9a", F161, "T11.2", ub1,
  method = "sensitivity", sens_low = min(k_sil, k_gap), sens_high = K_GRUPOS,
  sens_note = sprintf("Silhouette is highest at k = %d (%.2f); gap statistic (Tibshirani 1-SE) picks k = %d; Mclust (BIC, 4 PCs) G = %d; k = 4 adds a small migration group to three stretches of one road",
                      k_sil, max(tabla_k$sil_kmeans), k_gap, mc$G),
  status = "pre-specified", hypothesis_id = "H9a", n = N_PAISES_1M, universe = U1, say = "four")
reg <- registrar_cifra(reg, "silhouette", sil_k4, "silhouette", "0.00",
  paste("Mean silhouette of the k-means k = 4 partition (Euclidean distance in the 32 trajectory features).", NOTA_RASGOS), F161, "T11.2", ub1,
  method = "sensitivity", sens_low = unname(sil_sub_ic[1]), sens_high = unname(sil_sub_ic[2]), B = B_KEEP, seed = SEMILLA,
  sens_note = sprintf("P2.5-P97.5 over %d random 80 %% subsamples of countries; k = 2: %.2f; FPCA partition in the same space: %.2f; H9 (≤ 0.23) rejected",
                      B_KEEP, tabla_k$sil_kmeans[1], sil_fpca_l2),
  status = "pre-specified", hypothesis_id = "H9a", n = N_PAISES_1M, universe = U1, say = sprintf("about %s", formatear_cifra(sil_k4, "0.00")))
reg <- registrar_cifra(reg, "silhouette_k2", tabla_k$sil_kmeans[tabla_k$k == 2], "silhouette", "0.00",
  "Mean silhouette of k-means with k = 2 (highest of k = 2..8)", F161, "T11.1", "notebook.Q3",
  method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "gap_k", k_gap, "groups", "0", "Number of groups chosen by the gap statistic (Tibshirani 1-SE rule, B = 100, K.max = 8)",
  F161, "T11.1", "notebook.Q3", method = "permutation", B = B_GAP, seed = SEMILLA, status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "cluster_names", I(NIVELES_GRUPO), "names", "text",
  "Group names given by the v2 rule (plan de implementación §6): Migration-led if median CNMR 2000-23 > 10 per 1,000; Early movers if median first year TFR < 4 is before 1960 or most were < 4 in 1950; Recent movers if after 1995 or not crossed; otherwise Fast movers",
  F161, "T11.3", c(ub1, "slide4.table"), method = "descriptive", status = "descriptive", n = 4L, universe = U1,
  sens_note = paste(sprintf("%s: median CNMR 2000-23 %.1f, median year TFR < 4 %s, majority < 4 in 1950 %s", regla_grupos$nombre,
                            regla_grupos$cnmr_mediana_2000_23, ifelse(is.na(regla_grupos$anio_mediano_tfr4), "not crossed", regla_grupos$anio_mediano_tfr4),
                            regla_grupos$mayoria_bajo4_1950), collapse = "; "))
reg <- registrar_cifra(reg, "cluster_sizes", stats::setNames(as.integer(tam_grupos), names(tam_grupos)), "countries", "0",
  "Number of countries in each trajectory group (k-means k = 4)", F161, "T11.3", ub1,
  method = "sensitivity", status = "descriptive", n = N_PAISES_1M, universe = U1,
  sens_note = sprintf("FPCA + k-means sizes: %s; Ward: %s; PAM: %s",
                      paste(sort(table(fpca$cl), decreasing = TRUE), collapse = "/"),
                      paste(sort(table(cl_ward), decreasing = TRUE), collapse = "/"),
                      paste(sort(table(cl_pam), decreasing = TRUE), collapse = "/")))
reg <- registrar_cifra(reg, "cluster_pop_bn", stats::setNames(round(desc_grupos$pop_bn, 3), as.character(desc_grupos$grupo)), "billion", "0.0",
  "Population 2023 (UN estimate) living in each trajectory group, sum of TPopulation1July", F161, "T11.4", ub1,
  method = "descriptive", status = "descriptive", n = N_PAISES_1M, universe = U1)
for (g in NIVELES_GRUPO) {
  clave <- c(`Early movers` = "cluster_examples_early", `Fast movers` = "cluster_examples_fast",
             `Recent movers` = "cluster_examples_recent", `Migration-led` = "cluster_examples_migration")[[g]]
  reg <- registrar_cifra(reg, clave, I(nombre_pais(ejemplos_iso[[g]])), "countries", "text",
    sprintf("Three most populous countries (2023) of the %s group, by rule; ISO3: %s", g, paste(ejemplos_iso[[g]], collapse = ", ")),
    F161, "T11.4", ub1, method = "descriptive", status = "descriptive", n = as.integer(tam_grupos[[g]]), universe = U1,
    say = unir_voz(nombre_voz(ejemplos_iso[[g]])),
    sens_note = paste(c(if ("NGA" %in% ejemplos_iso[[g]]) "Nigeria: last census 2006; cite as UN estimate (WPP TFR 2023 4.48 vs DHS 2018 5.3)",
                        if (any(ejemplos_iso[[g]] %in% GOLFO)) "Gulf populations were revised in WPP2024 (UAE +12 %, Saudi Arabia -10 %); net migration is the least-measured component",
                        sprintf("medoid: %s", nombre_pais(medoides_iso[[g]]))), collapse = "; "))
}
reg <- registrar_cifra(reg, "cluster_examples_iso3", lapply(ejemplos_iso, I), "ISO3", "text",
  "ISO3 codes of the three most populous countries (2023) of each group (for flags)", F161, "T11.4", ub1,
  method = "descriptive", status = "descriptive", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "cluster_medoids", as.list(stats::setNames(nombre_pais(medoides_iso), NIVELES_GRUPO)), "countries", "text",
  sprintf("Medoid = country closest (Euclidean) to the coordinate-wise median of its group's 32 features; ISO3: %s",
          paste(sprintf("%s %s", NIVELES_GRUPO, medoides_iso), collapse = ", ")),
  F161, "T11.4", ub1, method = "descriptive", status = "descriptive", n = 4L, universe = U1)
reg <- registrar_cifra(reg, "cluster_profile", desc_grupos |> dplyr::mutate(grupo = as.character(grupo)) |>
                         dplyr::mutate(dplyr::across(where(is.double), ~ round(.x, 2))), "table", "text",
  "Group description with medians across countries; external variables (not used to build the groups): Q5 2023, LE65 2023, LE60 2023, % population change 2023-2050 and median age 2050 (UN medium projection), LE60 2050 (projection); defining variables shown for reference only. No significance tests (circular).",
  F161, "T11.4", c("notebook.Q3", "slide4.build1"), method = "descriptive", status = "descriptive", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "jaccard_min", min(jaccard_grupo), "Jaccard", "0.00",
  sprintf("Lowest mean bootstrap Jaccard across the 4 groups (B = %d resamples of countries with replacement, k-means nstart 20); group: %s",
          B_JACCARD, names(which.min(jaccard_grupo))), F161, "T11.5", c("slide4.method_strip", "notebook.Q3"),
  method = "bootstrap_perc", B = B_JACCARD, seed = SEMILLA, status = "pre-specified", hypothesis_id = "H9a",
  n = N_PAISES_1M, universe = U1, sens_note = sprintf("Ward k = 4 Jaccard range %.2f-%.2f", min(jacc_ward), max(jacc_ward)))
reg <- registrar_cifra(reg, "jaccard_max", max(jaccard_grupo), "Jaccard", "0.00",
  sprintf("Highest mean bootstrap Jaccard across the 4 groups (B = %d); group: %s", B_JACCARD, names(which.max(jaccard_grupo))),
  F161, "T11.5", c("slide4.method_strip", "notebook.Q3"), method = "bootstrap_perc", B = B_JACCARD, seed = SEMILLA,
  status = "pre-specified", hypothesis_id = "H9a", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "jaccard_by_group", as.list(round(jaccard_grupo, 3)), "Jaccard", "0.00",
  "Mean bootstrap Jaccard of each group (Hennig 2007; > 0.75 stable, < 0.6 dissolved)", F161, "T11.5", "notebook.Q3",
  method = "bootstrap_perc", B = B_JACCARD, seed = SEMILLA, status = "pre-specified", hypothesis_id = "H9a", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "ari_fpca_decadas", ari_fpca, "ARI", "0.00",
  sprintf("Adjusted Rand index between the main partition and k-means on the first %d multivariate FPCA scores (%.0f %% of variance; cubic B-splines, lambda = 10)",
          fpca$K, 100 * sum(fpca$varprop[1:fpca$K])), F161, "T11.6", c("slide4.method_strip", "notebook.Q3"),
  method = "sensitivity", sens_low = min(ari_fpca_lambda), sens_high = max(ari_fpca_lambda),
  sens_note = sprintf("lambda = 1: %.2f; lambda = 100: %.2f", ari_fpca_lambda[1], ari_fpca_lambda[2]),
  status = "pre-specified", hypothesis_id = "H9a", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "ari_tray_niveles", ari_niv, "ARI", "0.00",
  "ARI between trajectory groups (70 years) and k-means k = 4 on 2023 levels of the same 4 indicators (cross-sectional z, CNMR winsorized)",
  F161, "T11.7", c("slide4.message", "notebook.Q3"), method = "sensitivity",
  sens_low = min(ari_niv, ari_niv_p), sens_high = max(ari_niv, ari_niv_p),
  sens_note = sprintf("2023 levels z-scored with the panel mean/SD: %.2f", ari_niv_p),
  status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "ari_sin_cnmr", ari_sin, "ARI", "0.00",
  "ARI between the main partition and k-means k = 4 without the 8 net-migration features (24 features)", F161, "T11.8",
  c("notebook.Q3"), method = "sensitivity", sens_low = min(ari_sin, rejilla$ari[rejilla$cnmr == "without" & rejilla$muestra == "161"]),
  sens_high = max(rejilla$ari[rejilla$cnmr == "without" & rejilla$muestra == "161"]),
  sens_note = sprintf("Range over k-means/Ward/PAM/FPCA x decades/5-year without CNMR (161); max Jaccard of the Migration-led set without CNMR %.2f (dissolves)", jacc_mig_sin),
  status = "pre-specified", hypothesis_id = "H9a", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "ari_ward", ari_ward, "ARI", "0.00", "ARI k-means vs Ward (ward.D2) with k = 4", F161, "T11.6", "notebook.Q3",
  method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "ari_pam", ari_pam, "ARI", "0.00", "ARI k-means vs PAM with k = 4", F161, "T11.6", "notebook.Q3",
  method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "ari_asinh", ari_as, "ARI", "0.00",
  "ARI main partition vs k-means with asinh(CNMR/5) instead of winsorizing", F161, "T11.8", "notebook.Q3",
  method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1,
  sens_note = sprintf("Unwinsorized CNMR: ARI %.2f (smallest group: %s)", ari_crudo, paste(peq(cl_crudo), collapse = ", ")))
reg <- registrar_cifra(reg, "silhouette_speed_clusters", sil_v, "silhouette", "0.00",
  "Mean silhouette of k-means k = 4 on yearly derivatives (speeds) of the smoothed z-curves of TFR, LEx, median age and net migration rate (B-splines, lambda = 10), 1950-2023 — attempt discarded",
  F161, "T11.11", "notebook.Q3", method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1,
  sens_note = sprintf("mean bootstrap Jaccard of the 4 speed groups (B = %d): %s; ARI with the main partition %.2f; sizes %s (one large group plus small groups of shocks: %s) — a high silhouette here reflects outliers, not roads",
                      B_JACCARD, paste(sprintf("%.2f", jacc_v), collapse = " / "), ari_v, paste(tam_v, collapse = "/"),
                      paste(sprintf("[%s]", miembros_v_peq), collapse = " ")))
reg <- registrar_cifra(reg, "r2_groups_axis1", r2_eje1, "R2", "0.00",
  sprintf("R2 of the first principal axis of the 32 trajectory features (%.0f %% of their variance) on group membership", 100 * var_pcs_rasgos[1]),
  F161, "T11.9", c("slide4.build1", "notebook.Q3"), method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1,
  say = sprintf("%s of the main axis", say_fraccion(r2_eje1)))
reg <- registrar_cifra(reg, "share_between_groups", 100 * share_entre, "%", "0",
  "Share of countries whose maximum fuzzy membership (cluster::fanny, k = 4, membership exponent 1.5) is below 0.6", F161, "T11.9", ub1,
  method = "sensitivity", sens_low = 100 * min(share_entre_sens), sens_high = 100 * max(share_entre_sens),
  sens_note = sprintf("threshold 0.5: %.0f %%; 0.7: %.0f %%", 100 * share_entre_sens[1], 100 * share_entre_sens[2]),
  status = "exploratory", n = N_PAISES_1M, universe = U1, say = say_fraccion(share_entre))
reg <- registrar_cifra(reg, "share_keep_ge_0.8", 100 * share_keep, "%", "0",
  sprintf("Share of countries that stay in their group in at least 80 %% of %d random 80 %% subsamples (k-means re-run, labels matched with the Hungarian algorithm, clue::solve_LSAP)", B_KEEP),
  F161, "T11.5", c("slide4.build1", "notebook.Q3"), method = "sensitivity", B = B_KEEP, seed = SEMILLA,
  sens_low = 100 * min(share_keep_sens), sens_high = 100 * max(share_keep_sens),
  sens_note = sprintf("70 %% subsamples (B = 200): %.0f %%; 90 %% subsamples (B = 200): %.0f %%", 100 * share_keep_sens[1], 100 * share_keep_sens[2]),
  status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "borderline_countries", I(nombre_pais(iso_frontera)), "countries", "text",
  sprintf("Countries that stay in their group in fewer than 80 %% of %d subsamples (hatched/lighter on the map); ISO3: %s", B_KEEP,
          paste(iso_frontera, collapse = ", ")), F161, "T11.5", c("slide4.build1", "notebook.Q3"),
  method = "sensitivity", B = B_KEEP, seed = SEMILLA, status = "descriptive", n = length(iso_frontera), universe = U1)
reg <- registrar_cifra(reg, "share_sil_lt_0.1", 100 * mean(sil_ind < 0.1), "%", "0",
  sprintf("Share of countries with individual silhouette < 0.1; %d negative (%s)", sum(sil_ind < 0), paste(names(sil_ind)[sil_ind < 0], collapse = ", ")),
  F161, "T11.9", "notebook.Q3", method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "n_cnmr_winsor_cells", n_celdas_winsor, "country-years", "0",
  sprintf("Country-years of CNMR winsorized to [%.1f; %.1f] per 1,000 (mean ± 3 SD of the 161 x 1950-2023 panel); countries: %s",
          lim_cnmr[1], lim_cnmr[2], paste(sprintf("%s %d", recortes_cnmr$ISO3_code, recortes_cnmr$n), collapse = ", ")),
  F161, "T11.0", "notebook.Q3", method = "none_census", status = "descriptive", n = nrow(recortes_cnmr), universe = U1)
reg <- registrar_cifra(reg, "india_group", as.character(grupo["IND"]), "group", "text",
  "Trajectory group of India (main partition)", F161, "T11.3", c("slide4.build1", "narration.s4"),
  method = "descriptive", status = "descriptive", n = 1L, universe = U1,
  sens_note = sprintf("FPCA: same group as %s; without CNMR: cluster %d", paste(names(fpca$cl)[fpca$cl == fpca$cl["IND"]][1:3], collapse = ", "), cl_sin["IND"]))
# "Mostly Gulf states" (QA_storyboard §6.5): miembros del grupo Migration-led y cuántos son del Golfo (GOLFO = GCC).
iso_mig <- names(grupo)[grupo == "Migration-led"]
iso_mig <- iso_mig[order(-pob23_q3[iso_mig])]
n_golfo_mig <- sum(iso_mig %in% GOLFO)
reg <- registrar_cifra(reg, "migration_led_members", I(nombre_pais(iso_mig)), "countries", "text",
  sprintf("Members of the Migration-led group, most populous first; ISO3: %s. Gulf Cooperation Council members among them: %d of %d (%s); others: %s",
          paste(iso_mig, collapse = ", "), n_golfo_mig, length(iso_mig), paste(iso_mig[iso_mig %in% GOLFO], collapse = ", "),
          paste(iso_mig[!iso_mig %in% GOLFO], collapse = ", ")),
  F161, "T11.3", c("narration.s4", "qa.mostly_gulf"), method = "descriptive", status = "descriptive",
  n = length(iso_mig), universe = U1,
  sens_note = "Gulf populations were revised in WPP2024 (UAE +12 %, Saudi Arabia -10 %); net migration is the least-measured component")
reg <- registrar_cifra(reg, "n_gulf_migration_led", n_golfo_mig, "countries", "0",
  sprintf("Gulf Cooperation Council countries (%s) inside the Migration-led group of %d countries ('mostly Gulf states' holds if > half)",
          paste(GOLFO, collapse = ", "), length(iso_mig)), F161, "T11.3", c("narration.s4", "qa.mostly_gulf"),
  method = "descriptive", status = "descriptive", n = length(iso_mig), universe = U1,
  sens_note = sprintf("Oman (GCC) is %s", ifelse("OMN" %in% iso_mig, "in the group", paste("in", as.character(grupo["OMN"])))))
reg <- registrar_cifra(reg, "cramer_v_group_income", cramer_ingreso, "Cramer V", "0.00",
  "Cramér's V between trajectory group and World Bank FY2027 income group (descriptive, no test; Taiwan excluded)", "160 countries ≥ 1 M with income group",
  "T11.4", "notebook.Q3", method = "descriptive", status = "descriptive", n = sum(ok_ing), universe = U1,
  sens_note = sprintf("group ~ SDG region: %.2f", cramer_region))

# --- 16.2 Contigüidad (T7 / T11) ---------------------------------------------
reg <- registrar_cifra(reg, "join_same_road", jc$obs, "share", "0.00",
  "Share of directed neighbour links (5 nearest countries, great-circle distance between Natural Earth label points, row-standardized) whose two countries are in the same trajectory group",
  F161, "T7.J", c("slide4.build1", "narration.s4"), method = "permutation", B = B_PERM, seed = SEMILLA,
  sens_low = min(sapply(c(list(jc), jc_sens), `[[`, "obs")), sens_high = max(sapply(c(list(jc), jc_sens), `[[`, "obs")),
  sens_note = sprintf("kNN8 %.2f; land contiguity (< 10 km, islands get 2 nearest) %.2f; inverse distance ≤ 2,000 km %.2f; without CNMR groups (kNN5) %.2f vs chance %.2f",
                      jc_sens$knn8$obs, jc_sens$cont$obs, jc_sens$idw2000$obs, jc_sin$obs, jc_sin$nulo_media),
  status = "exploratory", hypothesis_id = "H25", p_value = jc$p, n = N_PAISES_1M, universe = U1, say = say_fraccion(jc$obs))
reg <- registrar_cifra(reg, "join_same_road_null", jc$nulo_media, "share", "0.00",
  sprintf("Mean share of same-group neighbour links under %d random permutations of the group labels (chance)", B_PERM),
  F161, "T7.J", c("slide4.build1", "narration.s4"), method = "permutation", B = B_PERM, seed = SEMILLA,
  sens_low = jc$lo, sens_high = jc$hi, sens_note = "sens_low/sens_high = 2.5 % and 97.5 % of the permutation distribution",
  status = "exploratory", hypothesis_id = "H25", n = N_PAISES_1M, universe = U1, say = say_fraccion(jc$nulo_media))
reg <- registrar_cifra(reg, "join_same_road_ratio", jc$obs / jc$nulo_media, "ratio", "0.0",
  "Observed share of same-road neighbour links divided by its permutation mean", F161, "T7.J", "notebook.Q3",
  method = "permutation", B = B_PERM, seed = SEMILLA, status = "exploratory", hypothesis_id = "H25", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "join_same_road_by_group", as.list(round(jc$por_grupo, 3)), "share", "0.00",
  sprintf("Share of neighbour links of each group's countries that stay in the group (chance = (n_g - 1)/(n - 1): %s)",
          paste(sprintf("%s %.2f", names(jc$esperado), jc$esperado), collapse = ", ")), F161, "T7.J", "notebook.Q3",
  method = "permutation", B = B_PERM, seed = SEMILLA, status = "exploratory", hypothesis_id = "H25", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "knn_vote_accuracy", acc_vecinos, "share", "0.00",
  "Share of countries whose group equals the majority group of its 5 nearest neighbours (ties: nearest tied neighbour)",
  F161, "T7.J", c("slide4.build1", "notebook.Q3"), method = "permutation", B = B_PERM, seed = SEMILLA,
  sens_low = mean(acc_nulo), sens_high = unname(stats::quantile(acc_nulo, 0.975)),
  sens_note = sprintf("sens = permutation mean and 97.5 %%; majority class %.2f; leave-one-out majority of the SDG region %.2f, of the income group %.2f, of region x income %.2f",
                      base_mayor, acc_region, acc_ingreso, acc_reg_ing),
  status = "exploratory", hypothesis_id = "H25", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "region_vote_accuracy", acc_region, "share", "0.00",
  "Share of countries whose group equals the leave-one-out majority group of its SDG region (reference so as not to overstate geography)",
  F161, "T7.J", c("slide4.build1", "notebook.Q3"), method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1)

# --- 16.3 Divergencia P1 (T12) -----------------------------------------------
ic_sd <- function(v, s) extraer_ic(ic_p1[[v]], s)
ub2 <- c("slide4.build2", "narration.s4")
reg_sd <- function(reg, clave, v, s, unidad, def, hid, fmt = "0.0", used = ub2) {
  r <- ic_sd(v, s); ri <- ic_p1_iid[[v]][[s]]
  col <- ifelse(grepl("cv", s), "cv", "de")
  v237 <- if (s %in% c("dsd", "dcv")) d1(v, 2023, col, UNIVERSO_237) - d1(v, 1950, col, UNIVERSO_237)
          else d1(v, as.integer(sub("\\D+", "", s)), col, UNIVERSO_237)
  registrar_cifra(reg, clave, r$valor, unidad, fmt, def, F161, "T12.1", used, ic = r, ic_iid = ri,
                  status = "pre-specified", hypothesis_id = hid, n = N_PAISES_1M, universe = U1,
                  sens_note = sprintf("237 countries and areas: %.2f", v237))
}
reg <- reg_sd(reg, "sd_medage_1950", "MedianAgePop", "sd1950", "years", "Standard deviation of median age across countries, 1950 (UN estimate)", "H10")
reg <- reg_sd(reg, "sd_medage_2023", "MedianAgePop", "sd2023", "years", "Standard deviation of median age across countries, 2023 (UN estimate)", "H10")
reg <- reg_sd(reg, "sd_lex_1950", "LEx", "sd1950", "years", "Standard deviation of life expectancy at birth across countries, 1950", "H11a")
reg <- reg_sd(reg, "sd_lex_2023", "LEx", "sd2023", "years", "Standard deviation of life expectancy at birth across countries, 2023", "H11a")
reg <- reg_sd(reg, "sd_le65_1950", "LE65", "sd1950", "years", "Standard deviation of life expectancy at 65 across countries, 1950", "H11a", "0.00")
reg <- reg_sd(reg, "sd_le65_2023", "LE65", "sd2023", "years", "Standard deviation of life expectancy at 65 across countries, 2023", "H11a", "0.00")
reg <- reg_sd(reg, "cv_lex_1950", "LEx", "cv1950", "%", "Coefficient of variation (SD / mean, %) of life expectancy at birth across countries, 1950", "H11a")
reg <- reg_sd(reg, "cv_lex_2023", "LEx", "cv2023", "%", "Coefficient of variation (SD / mean, %) of life expectancy at birth across countries, 2023", "H11a")
reg <- reg_sd(reg, "cv_le65_1950", "LE65", "cv1950", "%", "Coefficient of variation (SD / mean, %) of life expectancy at 65 across countries, 1950", "H11a")
reg <- reg_sd(reg, "cv_le65_2023", "LE65", "cv2023", "%", "Coefficient of variation (SD / mean, %) of life expectancy at 65 across countries, 2023", "H11a")
reg <- reg_sd(reg, "delta_sd_medage", "MedianAgePop", "dsd", "years", "Change 1950 → 2023 in the cross-country SD of median age", "H10", used = "notebook.Q3")
reg <- reg_sd(reg, "delta_sd_lex", "LEx", "dsd", "years", "Change 1950 → 2023 in the cross-country SD of life expectancy at birth", "H11a", used = "notebook.Q3")
reg <- reg_sd(reg, "delta_sd_le65", "LE65", "dsd", "years", "Change 1950 → 2023 in the cross-country SD of life expectancy at 65", "H11a", "0.00", used = "notebook.Q3")
reg <- reg_sd(reg, "delta_cv_lex", "LEx", "dcv", "percentage points", "Change 1950 → 2023 in the cross-country CV (%) of life expectancy at birth", "H11a", used = "notebook.Q3")
reg <- reg_sd(reg, "delta_cv_le65", "LE65", "dcv", "percentage points", "Change 1950 → 2023 in the cross-country CV (%) of life expectancy at 65", "H11a", used = "notebook.Q3")
reg <- reg_sd(reg, "sd_le60_1950", "LE60", "sd1950", "years", "SD of life expectancy at 60 across countries, 1950 (WPP2024 supplement; robustness of LE65)", "H11", "0.00", used = "notebook.Q3")
reg <- reg_sd(reg, "sd_le60_2023", "LE60", "sd2023", "years", "SD of life expectancy at 60 across countries, 2023 (WPP2024 supplement; robustness of LE65)", "H11", "0.00", used = "notebook.Q3")
reg <- reg_sd(reg, "delta_sd_le60", "LE60", "dsd", "years", "Change 1950 → 2023 in the cross-country SD of life expectancy at 60 (supplement)", "H11", "0.00", used = "notebook.Q3")
q5r <- function(s) extraer_ic(ic_q5, s)
reg <- registrar_cifra(reg, "q5_ratio_p90p10_1950", q5r("r1950")$valor, "ratio", "0",
  "Ratio of the 90th to the 10th percentile of under-five mortality across countries, 1950 (riskiest tenth vs safest tenth)", F161, "T12.2", ub2,
  ic = q5r("r1950"), ic_iid = ic_q5_iid$r1950, status = "exploratory", n = N_PAISES_1M, universe = U1,
  sens_note = sprintf("237: %.1f", d1("Q5", 1950, "razon_p90p10", UNIVERSO_237)), say = sprintf("%s times", formatear_cifra(q5r("r1950")$valor, "0")))
reg <- registrar_cifra(reg, "q5_ratio_p90p10_2023", q5r("r2023")$valor, "ratio", "0",
  "Ratio of the 90th to the 10th percentile of under-five mortality across countries, 2023", F161, "T12.2", ub2,
  ic = q5r("r2023"), ic_iid = ic_q5_iid$r2023, status = "exploratory", n = N_PAISES_1M, universe = U1,
  sens_note = sprintf("237: %.1f; UN medium 2050: %.1f", d1("Q5", 2023, "razon_p90p10", UNIVERSO_237), d1("Q5", 2050, "razon_p90p10")),
  say = sprintf("%s times", formatear_cifra(q5r("r2023")$valor, "0")))
reg <- registrar_cifra(reg, "q5_ratio_p90p10_peak", q5_pico$razon_p90p10, "ratio", "0",
  sprintf("Maximum over 1950-2023 (UN estimates) of the P90/P10 ratio of under-five mortality across countries, reached in %d", q5_pico$Time),
  F161, "T12.2", c("slide4.build2", "notebook.Q3"), method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1,
  sens_note = sprintf("237 countries and areas: %.1f in %d; 2023: %.1f (161)", q5_pico_237$razon_p90p10, q5_pico_237$Time, d1("Q5", 2023, "razon_p90p10")))
reg <- registrar_cifra(reg, "q5_ratio_p90p10_peak_year", q5_pico$Time, "year", "0",
  "Year (1950-2023, UN estimates) in which the P90/P10 ratio of under-five mortality across countries peaked", F161, "T12.2",
  c("slide4.build2", "notebook.Q3"), method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "q5_gap_p90p10_1950", q5r("gap1950")$valor, "per 1,000", "0",
  "Absolute gap P90 - P10 of under-five mortality across countries, 1950", F161, "T12.2", "notebook.Q3",
  ic = q5r("gap1950"), ic_iid = ic_q5_iid$gap1950, status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "q5_gap_p90p10_2023", q5r("gap2023")$valor, "per 1,000", "0",
  "Absolute gap P90 - P10 of under-five mortality across countries, 2023", F161, "T12.2", "notebook.Q3",
  ic = q5r("gap2023"), ic_iid = ic_q5_iid$gap2023, status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "sd_logq5_1950", q5r("sdlog1950")$valor, "SD of log", "0.00",
  "SD of log under-five mortality across countries, 1950", F161, "T12.2", "notebook.Q3",
  ic = q5r("sdlog1950"), ic_iid = ic_q5_iid$sdlog1950, status = "exploratory", n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "sd_logq5_2023", q5r("sdlog2023")$valor, "SD of log", "0.00",
  "SD of log under-five mortality across countries, 2023", F161, "T12.2", "notebook.Q3",
  ic = q5r("sdlog2023"), ic_iid = ic_q5_iid$sdlog2023, status = "exploratory", n = N_PAISES_1M, universe = U1)
amx <- function(v, per) anio_max_de$anio_max[anio_max_de$variable == v & anio_max_de$periodo_en == per]
reg <- registrar_cifra(reg, "sd_medage_peak_year_proj", amx("MedianAgePop", ETIQUETA_PROYECCION), "year", "0",
  "Year in which the cross-country SD of median age reaches its maximum within the UN medium projection 2024-2100 (computed separately from estimates)",
  "161 countries ≥ 1 M, UN medium projection 2024-2100", "T12.3", c("slide4.build2", "notebook.Q3"), method = "descriptive",
  status = "descriptive", n = N_PAISES_1M, universe = U1, variant_source = "WPP2024 Medium",
  sens_note = sprintf("max SD in estimates (1950-2023) is reached in %d; LE65 SD max in projection %d; LEx SD max in estimates %d",
                      amx("MedianAgePop", ETIQUETA_ESTIMACION), amx("LE65", ETIQUETA_PROYECCION), amx("LEx", ETIQUETA_ESTIMACION)))
reg <- registrar_cifra(reg, "sd_tfr_peak_year", amx("TFR", ETIQUETA_ESTIMACION), "year", "0",
  "Year in which the cross-country SD of TFR peaked, UN estimates 1950-2023 (fertility first diverged, then converged)", F161, "T12.3", "notebook.Q3",
  method = "descriptive", status = "descriptive", n = N_PAISES_1M, universe = U1,
  sens_note = sprintf("SD of TFR 1950 %.2f, peak %.2f, 2023 %.2f", d1("TFR", 1950), anio_max_de$valor_max[anio_max_de$variable == "TFR" & anio_max_de$periodo_en == ETIQUETA_ESTIMACION], d1("TFR", 2023)))
for (v in c("MedianAgePop", "LEx")) for (a in c(1950, 2023)) {
  nm <- c(MedianAgePop = "medage", LEx = "lex")[[v]]
  reg <- registrar_cifra(reg, sprintf("r2_region_%s_%d", nm, a), d1(v, a, "r2_region"), "R2", "0.00",
    sprintf("R2 of %s on the 8 SDG regions across countries, %d (descriptive)", etiq_var[[v]], a), F161, "T12.4", "notebook.Q3",
    method = "descriptive", status = "descriptive", n = N_PAISES_1M, universe = U1,
    sens_note = sprintf("R2 on World Bank FY2027 income groups (160 countries): %.2f", d1(v, a, "r2_ingreso")))
}

# --- 16.4 Velocidad y envejecimiento ------------------------------------------
# Por camino (QA_storyboard §6.3): las claves del guion comparan Fast con Early movers.
efa <- env_km_grupo[env_km_grupo$grupo == "Fast movers", ]; eea <- env_km_grupo[env_km_grupo$grupo == "Early movers", ]
reg <- registrar_cifra(reg, "yrs_medage30_40_recent", med_g("Fast movers"), "years", "0",
  sprintf("Fast movers: Kaplan-Meier median years from median age 30 to 40 (right-censored if 40 is not reached by 2100). %d of %d countries reach 30 only after 2023 and %d reach 40 only in the UN medium projection, so this is mostly a projected speed",
          efa$n_inicio_proy, efa$n, efa$n_fin_proy),
  "Fast movers (161 countries ≥ 1 M); estimates ≤ 2023 + UN medium projection ≥ 2024 (mostly projected)", "T15.4",
  c("slide4.build1", "narration.s4"), ic = ic_env_fast, ic_iid = NULL, status = "exploratory", n = as.integer(efa$n), universe = U1,
  sens_low = min(med_fast_iniciados, efa$mediana_completos, med_reciente), sens_high = max(med_g("Fast movers"), efa$mediana_completos),
  sens_note = sprintf("Fast movers already at 30 by 2023 (n = %d): %.1f [block %.1f-%.1f]; simple median of the %d that reach 40 by 2100: %.1f; by crossing cohort (reached 30 in 1990-2023, any road): %.1f; censored at 2100: %d",
                      nrow(env_fast_iniciados), med_fast_iniciados, ic_env_fast_ini$ci_low, ic_env_fast_ini$ci_high,
                      efa$n - efa$n_censura_2100, efa$mediana_completos, med_reciente, efa$n_censura_2100),
  variant_source = "WPP2024 Medium (crossings after 2023)", say = sprintf("about %s", formatear_cifra(med_g("Fast movers"), "0")))
reg <- registrar_cifra(reg, "yrs_medage30_40_early", med_g("Early movers"), "years", "0.0",
  sprintf("Early movers: Kaplan-Meier median years from median age 30 to 40, among the %d whose crossing of 30 is observed after 1950 (%d already ≥ 30 in 1950 are left out: their start is not observed)",
          eea$n, eea$n_izq_1950),
  "Early movers (161 countries ≥ 1 M); estimates ≤ 2023 + UN medium projection ≥ 2024", "T15.4",
  c("slide4.build1", "narration.s4"), ic = ic_env_early, status = "exploratory", n = as.integer(eea$n), universe = U1,
  sens_low = min(med_g("Early movers"), eur_temprano, med_temprano), sens_high = max(med_early_con_izq, med_temprano),
  sens_note = sprintf("including the %d left-censored at their lower bound (40-year year - 1950): %.1f; by crossing cohort (reached 30 before 1990, any road): %.1f; Europe and Northern America cohort: %.1f; %d of %d reach 40 in the UN medium projection",
                      eea$n_izq_1950, med_early_con_izq, med_temprano, eur_temprano, eea$n_fin_proy, eea$n),
  say = sprintf("about %s", formatear_cifra(med_g("Early movers"), "0")))
reg <- registrar_cifra(reg, "yrs_medage30_40_fast_started", med_fast_iniciados, "years", "0",
  sprintf("Fast movers that already reached median age 30 by 2023 (%d countries): Kaplan-Meier median years from 30 to 40 (the 40 crossing is mostly in the UN medium projection)", nrow(env_fast_iniciados)),
  "Fast movers with median age ≥ 30 by 2023; estimates + UN medium projection", "T15.4", c("notebook.Q3", "slide4.alt"),
  ic = ic_env_fast_ini, status = "exploratory", n = nrow(env_fast_iniciados), universe = U1,
  variant_source = "WPP2024 Medium", say = sprintf("about %s", formatear_cifra(med_fast_iniciados, "0")))
reg <- registrar_cifra(reg, "yrs_medage30_40_cohort_1990_2023", med_reciente, "years", "0",
  sprintf("Median years from median age 30 to 40 among countries (any road) that first reached 30 in 1990-2023 (%d countries; %d reach 40 only in the UN medium projection)",
          n_reciente, n_y40_proy_reciente), "161 countries ≥ 1 M; estimates ≤ 2023 + UN medium projection ≥ 2024 (partly projected)", "T15.4",
  c("notebook.Q3", "slide4.alt"), ic = ic_reciente, status = "exploratory", n = n_reciente, universe = U1,
  sens_low = min(med_reciente, km_env_med[2]), sens_high = max(med_reciente, km_env_med[2]),
  sens_note = sprintf("Kaplan-Meier with censoring at 2100: %.1f", km_env_med[2]),
  variant_source = "WPP2024 Medium (for crossings after 2023)", say = sprintf("about %s", formatear_cifra(med_reciente, "0")))
reg <- registrar_cifra(reg, "yrs_medage30_40_cohort_pre1990", med_temprano, "years", "0.0",
  sprintf("Median years from median age 30 to 40 among countries (any road) that first reached 30 before 1990 (excluding those already ≥ 30 in 1950; %d countries)",
          sum(env_obs$cohorte_30 == "reached 30 before 1990")), "161 countries ≥ 1 M; estimates ≤ 2023 + UN medium projection ≥ 2024", "T15.4",
  c("notebook.Q3", "slide4.alt"), ic = ic_temprano, status = "exploratory",
  n = sum(env_obs$cohorte_30 == "reached 30 before 1990"), universe = U1,
  sens_low = min(med_temprano, km_env_med[1], eur_temprano), sens_high = max(med_temprano, km_env_med[1], eur_temprano),
  sens_note = sprintf("Kaplan-Meier: %.1f; Europe and Northern America only: %.1f", km_env_med[1], eur_temprano),
  say = sprintf("about %s", formatear_cifra(med_temprano, "0")))
# Regla de resaltes de fig04 (QA_storyboard §6.4); las claves dur53_chn / dur53_egy son de Q1.
reg <- registrar_cifra(reg, "speed53_rule_10m", list(fastest = unname(regla53_iso["fastest"]), median = unname(regla53_iso["median"]),
                                                     slowest = unname(regla53_iso["slowest"]),
                                                     years = as.list(round(regla53_anios, 1)), china_egypt_ok = regla53_ok), "ISO3", "text",
  sprintf("Rule check for fig04 highlights: fastest, median and slowest years from TFR 5 to 3 (smoothed TFR, lambda = 10) among the %d countries ≥ 10 M (2023) that completed the stretch by 2023",
          nrow(regla53)), "countries ≥ 10 M (2023) that crossed 5 and 3 between 1950 and 2023", "T11.10", c("notebook.Q3", "qa.fig04"),
  method = "descriptive", status = "descriptive", n = nrow(regla53), universe = U1,
  sens_note = sprintf("%s %.1f, %s %.1f, %s %.1f years; matches dur53_chn / dur53_egy of Q1: %s", regla53_iso["fastest"], regla53_anios["fastest"],
                      regla53_iso["median"], regla53_anios["median"], regla53_iso["slowest"], regla53_anios["slowest"], ifelse(regla53_ok, "yes", "NO")))
for (iso in c("KOR", "JPN", "CHN")) {
  reg <- registrar_cifra(reg, paste0("yrs_medage30_40_", tolower(iso)), unname(yrs30_40[iso]), "years", "0",
    sprintf("Years from median age 30 (%d) to 40 (%d) in %s%s", y30_pais[iso], y40_pais[iso], nombre_pais(iso),
            ifelse(y40_pais[iso] >= ANIO_INICIO_PROYECCION, " (40 reached in the UN medium projection)", " (UN estimates)")),
    nombre_pais(iso), "T15.4", c("slide4.build1", "notebook.Q3"), method = "descriptive", status = "descriptive",
    n = 1L, universe = U1)
}
reg <- registrar_cifra(reg, "speed53_median_by_group", as.list(stats::setNames(round(km53_med$mediana, 1), km53_med$grupo)), "years", "0.0",
  "Kaplan-Meier median years from the last crossing of TFR 5 to the last crossing of 3 (TFR smoothed with B-splines, lambda = 10), by trajectory group; censored at 2023; NA = median not reached",
  "161 countries ≥ 1 M that crossed 5 after 1950", "T11.10", c("notebook.Q3", "slide4.build1"), method = "km",
  status = "exploratory", n = sum(km53_med$n), universe = U1,
  sens_note = paste(sprintf("%s: n %d, events %d, 95%% CI %s-%s", km53_med$grupo, km53_med$n, km53_med$eventos,
                            formatear_cifra(km53_med$lo, "0.0"), ifelse(is.na(km53_med$hi), "NA", formatear_cifra(km53_med$hi, "0.0"))), collapse = "; "))

# --- 16.5 Proyección por grupo (escenario) ------------------------------------
cp <- function(g, col) comp_proy[[col]][comp_proy$grupo == g]
reg <- registrar_cifra(reg, "growth_2024_2050_by_group", comp_proy |> dplyr::transmute(grupo = as.character(grupo),
                         natural_pct = round(nat_pct_pob, 1), migration_pct = round(mig_pct_pob, 1), total_pct = round(cambio_pct_pob, 1),
                         natural_bn = round(nat_bn, 3), migration_bn = round(mig_bn, 3)), "table", "text",
  "Population change 2024-2050 by trajectory group, split into natural change (Σ NatChange) and net migration (Σ NetMigrations), as % of the 2024 population (sums of persons)",
  "161 countries ≥ 1 M, UN medium projection 2024-2050", "T15.1", c("slide4.table", "notebook.Q3"), method = "sensitivity",
  status = "descriptive", n = N_PAISES_1M, universe = U1, variant_source = "WPP2024 Medium",
  sens_note = paste(sprintf("without %s: natural %.1f %%, migration %.1f %%", comp_proy_sin_mayor$excluido,
                            comp_proy_sin_mayor$nat_pct_pob, comp_proy_sin_mayor$mig_pct_pob), collapse = "; "))
reg <- registrar_cifra(reg, "growth_2000_2023_by_group", comp_est |> dplyr::transmute(grupo = as.character(grupo),
                         natural_pct = round(nat_pct_pob, 1), migration_pct = round(mig_pct_pob, 1), total_pct = round(cambio_pct_pob, 1),
                         share_migration_pct = round(share_mig, 1)), "table", "text",
  "Population change 2000-2023 (UN estimates) by trajectory group, split into natural change and net migration, as % of the 2000 population",
  "161 countries ≥ 1 M, UN estimates 2000-2023", "T15.1", "notebook.Q3", method = "descriptive", status = "descriptive",
  n = N_PAISES_1M, universe = U1)
reg <- registrar_cifra(reg, "medage_2050_by_group", as.list(stats::setNames(round(edad_grupo$mediana[edad_grupo$Time == 2050], 1),
                                                                            as.character(edad_grupo$grupo[edad_grupo$Time == 2050]))), "years", "0",
  "Median across countries of median age in 2050 (UN medium projection), by trajectory group", "161 countries ≥ 1 M, UN medium projection 2050",
  "T15.2", c("slide4.build1", "notebook.Q3"), method = "sensitivity", status = "descriptive", n = N_PAISES_1M, universe = U1,
  variant_source = "WPP2024 Medium",
  sens_note = paste(sprintf("%s: 2023 median %.1f; population-weighted mean 2050 %.1f", edad_grupo$grupo[edad_grupo$Time == 2050],
                            edad_grupo$mediana[edad_grupo$Time == 2023], edad_grupo$ponderada[edad_grupo$Time == 2050]), collapse = "; "))
reg <- registrar_cifra(reg, "le60_2050_by_group", as.list(stats::setNames(round(edad_grupo$le60[edad_grupo$Time == 2050], 1),
                                                                          as.character(edad_grupo$grupo[edad_grupo$Time == 2050]))), "years", "0.0",
  "Median across countries of life expectancy at 60 in 2050 (WPP2024 supplement, UN medium projection), by trajectory group",
  "161 countries ≥ 1 M, UN medium projection 2050", "T15.2", "notebook.Q3", method = "descriptive", status = "descriptive",
  n = N_PAISES_1M, universe = U1, variant_source = "WPP2024 Medium (supplement LE60)",
  sens_note = paste(sprintf("%s: LE60 2023 %.1f", edad_grupo$grupo[edad_grupo$Time == 2023], edad_grupo$le60[edad_grupo$Time == 2023]), collapse = "; "))
reg <- registrar_cifra(reg, "medage_chn_2050", medage_chn_2050, "years", "0.0",
  "Median age of China in 2050 (UN medium projection; no valid UN prediction interval exists for median age)", "China",
  "T15.2", c("slide4.table", "notebook.Q3"), method = "descriptive", status = "descriptive", n = 1L, universe = U237,
  variant_source = "WPP2024 Medium",
  sens_note = sprintf("High-income (World Bank FY2027) population-weighted mean of median ages 2050: %.1f; UN high-income aggregate (May-2024 classification): %.1f",
                      medage_alto_2050, medage_alto_2050_onu))
reg <- registrar_cifra(reg, "peak_year_by_group", picos_grupo |> dplyr::transmute(grupo = as.character(grupo), n, peaked_by_2023 = n_pico_2023,
                         peak_2024_2099 = n_pico_proy, no_peak_before_2100 = n_sin_pico, median_peak_year = mediana_pico), "table", "text",
  "Year of maximum population per country over 1950-2100 (estimates ≤ 2023, UN medium projection ≥ 2024), summarised by trajectory group",
  "161 countries ≥ 1 M", "T15.3", c("notebook.Q3", "slide4.table"), method = "descriptive", status = "descriptive",
  n = N_PAISES_1M, universe = U1, variant_source = "WPP2024 Medium")

# --- 16.6 Mundo ---------------------------------------------------------------
reg <- registrar_cifra(reg, "world_peak_year", pico_mundo$Time, "year", "0",
  "Year of maximum world population in the UN medium projection (World aggregate, TPopulation1July)", "World (UN aggregate)", "T15.5",
  c("notebook.Q3", "references"), method = "descriptive", status = "descriptive", n = 1L, universe = "World",
  variant_source = "WPP2024 Medium")
reg <- registrar_cifra(reg, "world_peak_bn", pico_mundo$TPopulation1July / 1e6, "billion", "0.00",
  "World population at its projected peak (UN medium projection)", "World (UN aggregate)", "T15.5", c("notebook.Q3", "references"),
  method = "descriptive", status = "descriptive", n = 1L, universe = "World", variant_source = "WPP2024 Medium")
reg <- registrar_cifra(reg, "world_pop_2050_bn", unname(pob_mundo["2050"]), "billion", "0.00", "World population 2050 (UN medium projection)",
  "World (UN aggregate)", "T15.5", "notebook.Q3", method = "descriptive", status = "descriptive", n = 1L, universe = "World",
  variant_source = "WPP2024 Medium")
reg <- registrar_cifra(reg, "world_pop_2100_bn", unname(pob_mundo["2100"]), "billion", "0.00", "World population 2100 (UN medium projection)",
  "World (UN aggregate)", "T15.5", "notebook.Q3", method = "descriptive", status = "descriptive", n = 1L, universe = "World",
  variant_source = "WPP2024 Medium", sens_note = sprintf("World population 2023 (UN estimate, key world_pop_2023_bn of the universe section): %.2f bn", pob_mundo["2023"]))
for (a in c(2023, 2050, 2100)) {
  reg <- registrar_cifra(reg, sprintf("n_shrinking_%d", a), dec(a, "n_decrecen"), "countries and areas", "0",
    sprintf("Countries and areas with PopChange < 0 in %d%s", a, ifelse(a > ANIO_FIN_ESTIMACION, " (UN medium projection)", " (UN estimate)")),
    U237, "T15.5", c("slide4.table", "notebook.Q3"), method = "none_census", status = "descriptive", n = N_PAISES, universe = U237,
    sens_note = sprintf("countries ≥ 1 M: %d", dec(a, "n_decrecen_1m")), variant_source = if (a > ANIO_FIN_ESTIMACION) "WPP2024 Medium" else NA)
}

# --- 16.7 Complementos demográficos y recomendaciones (T15, T16) -------------
ub3 <- c("slide4.table", "narration.s4")
reg <- registrar_cifra(reg, "n_sdg32_above", n_sdg_above, "countries and areas", "0",
  "Countries and areas with under-five mortality (Q5) above 25 per 1,000 in 2023 (SDG 3.2 threshold)", U237, "T15.6", ub3,
  method = "none_census", status = "descriptive", n = N_PAISES, universe = U237,
  sens_note = sprintf("%d of them ≥ 1 M", sum(sdg$pob_1m)))
reg <- registrar_cifra(reg, "n_sdg32_on_pace", n_sdg_pace, "countries and areas", "0",
  "Of those above 25 per 1,000 in 2023, number whose observed annual rate of reduction of Q5 in 2015-2023 (100·ln(Q5_2015/Q5_2023)/8) is at least the rate needed to reach 25 by 2030 (100·ln(Q5_2023/25)/7)",
  U237, "T15.6", ub3, method = "sensitivity", sens_low = min(c(n_sdg_pace, n_sdg_pace_sens)), sens_high = max(c(n_sdg_pace, n_sdg_pace_sens)),
  sens_note = sprintf("observed pace over 2010-2023: %d; over 2018-2023: %d; median observed %.1f %%/yr vs needed %.1f %%/yr",
                      n_sdg_pace_sens[1], n_sdg_pace_sens[2], median(sdg$ritmo_obs), median(sdg$ritmo_necesario)),
  status = "exploratory", hypothesis_id = "H23", n = n_sdg_above, universe = U237)
w_sdg <- ic_wilson(n_sdg_pace, n_sdg_above, escala = 100)
reg <- registrar_cifra(reg, "share_sdg32_on_pace", w_sdg$valor, "%", "0",
  "Share of countries above 25 per 1,000 in 2023 that are on pace for SDG 3.2 by 2030", U237, "T15.6", "notebook.Q3",
  ic = w_sdg, status = "exploratory", hypothesis_id = "H23", universe = U237)
reg <- registrar_cifra(reg, "n_sdg32_above_2030", n_sdg_2030, "countries and areas", "0",
  "Of those above 25 per 1,000 in 2023, number still above 25 in 2030 in the UN medium projection", U237, "T15.6", ub3,
  method = "none_census", status = "descriptive", n = n_sdg_above, universe = U237, variant_source = "WPP2024 Medium",
  sens_note = sprintf("%d in sub-Saharan Africa", sum(sdg$above_2030 & sdg$region_sdg == "Sub-Saharan Africa")))
reg <- registrar_cifra(reg, "n_natneg_1990", dec(1990, "n_natneg"), "countries and areas", "0",
  "Countries and areas with more deaths than births (NatChange < 0), 1990 (UN estimate)", U237, "T15.7", ub3,
  method = "none_census", status = "pre-specified", hypothesis_id = "H14a", n = N_PAISES, universe = U237)
reg <- registrar_cifra(reg, "n_natneg_2023", dec(2023, "n_natneg"), "countries and areas", "0",
  "Countries and areas with more deaths than births (NatChange < 0), 2023 (UN estimate)", U237, "T15.7", ub3,
  method = "none_census", sens_low = min(natneg_sens, dec(2023, "n_natneg")), sens_high = max(natneg_sens, dec(2023, "n_natneg")),
  sens_note = sprintf("2021: %d; 2022: %d", natneg_sens[1], natneg_sens[2]),
  status = "pre-specified", hypothesis_id = "H14a", n = N_PAISES, universe = U237)
reg <- registrar_cifra(reg, "n_natneg_2050", dec(2050, "n_natneg"), "countries and areas", "0",
  "Countries and areas with more deaths than births in 2050 (UN medium projection; a scenario)", U237, "T15.7", ub3,
  method = "none_census", status = "descriptive", n = N_PAISES, universe = U237, variant_source = "WPP2024 Medium",
  sens_note = sprintf("2100 (UN medium): %d", dec(2100, "n_natneg")))
reg <- registrar_cifra(reg, "share_pop_natneg_2023", dec(2023, "pct_pob_natneg"), "%", "0",
  "Share of the population of the 237 countries and areas living where deaths outnumbered births in 2023", U237, "T15.7", ub3,
  method = "none_census", status = "descriptive", n = N_PAISES, universe = U237,
  sens_note = sprintf("1990: %.0f %%; 2050 (UN medium): %.0f %%", dec(1990, "pct_pob_natneg"), dec(2050, "pct_pob_natneg")))
reg <- registrar_cifra(reg, "pop_chn_2050", pop_chn_2050_med, "billion", "0.00", "Population of China in 2050 (UN medium projection)",
  "China", "T13.CHN", ub3, method = "un_pi", status = "descriptive", n = 1L, universe = U237,
  pi80_low = pi_chn$`Lower 80 PI` / 1e6, pi80_high = pi_chn$`Upper 80 PI` / 1e6,
  pi95_low = pi_chn$`Lower 95 PI` / 1e6, pi95_high = pi_chn$`Upper 95 PI` / 1e6,
  variant_source = "WPP2024 OtherVariants (Median/Lower/Upper PI); monotonicity L95 ≤ L80 ≤ Median ≤ U80 ≤ U95 checked for all countries in 2050")
reg <- registrar_cifra(reg, "pop_chn_2050_pi95_low", pi_chn$`Lower 95 PI` / 1e6, "billion", "0.00",
  "Lower bound of the UN 95 % prediction interval for China's population in 2050", "China", "T13.CHN", ub3, method = "un_pi",
  status = "descriptive", n = 1L, universe = U237, variant_source = "WPP2024 OtherVariants (Lower 95 PI)")
reg <- registrar_cifra(reg, "pop_chn_2050_pi95_high", pi_chn$`Upper 95 PI` / 1e6, "billion", "0.00",
  "Upper bound of the UN 95 % prediction interval for China's population in 2050", "China", "T13.CHN", ub3, method = "un_pi",
  status = "descriptive", n = 1L, universe = U237, variant_source = "WPP2024 OtherVariants (Upper 95 PI)")
reg <- registrar_cifra(reg, "n_ssa", ssa_237, "countries and areas", "0",
  "Countries and areas of sub-Saharan Africa (UN SDG region) — 'sub-Saharan Africa is n different paths'", U237, "T15.8",
  c("slide4.ethics_card", "notebook.Q3"), method = "none_census", status = "descriptive", n = N_PAISES, universe = U237,
  sens_note = sprintf("%d with ≥ 1 M people, spread over the roads: %s", sum(ssa_caminos), paste(sprintf("%s %d", names(ssa_caminos), ssa_caminos), collapse = ", ")))
reg <- registrar_cifra(reg, "momentum_years_range", sprintf("%d–%d", mom_p25, mom_p75), "years", "text",
  "Years from 2023 to the projected population peak (UN medium, maximum over 2023-2100) in the countries below replacement that still grow from births without net immigration (lever type B & TFR < 2.1): population-weighted 25th-75th percentile",
  "22 countries and areas (type B & TFR < 2.1, 2023)", "T16.2", c("slide4.table", "narration.s4"),
  method = "sensitivity", status = "descriptive", n = nrow(inercia_pico), universe = U237, variant_source = "WPP2024 Medium",
  sens_low = min(mom_rango_sin_ind[1], mom_mediana_simple), sens_high = max(mom_p75, mom_desde21),
  sens_note = sprintf("weighted median %d (India %d, Brazil %d, Mexico %d); without India %d–%d; unweighted median %.1f (22) / %.1f (≥ 1 M); years from first TFR < 2.1 to the peak (≥ 1 M, median) %.1f",
                      mom_p50, inercia_pico$anios_crec[inercia_pico$ISO3_code == "IND"], inercia_pico$anios_crec[inercia_pico$ISO3_code == "BRA"],
                      inercia_pico$anios_crec[inercia_pico$ISO3_code == "MEX"], mom_rango_sin_ind[1], mom_rango_sin_ind[2],
                      mom_mediana_simple, mom_mediana_1m, mom_desde21),
  say = sprintf("%d to %d", mom_p25, mom_p75))
reg <- registrar_cifra(reg, "rec_rows", rec_rows, "table", "text",
  "Watch-list table by lever state 2023 (Q1) with the majority trajectory road (Q3) of its countries ≥ 1 M, what to watch, UN mandate, agency (text, no logos) and horizon; verbs watch / plan / measure / prepare / monitor only",
  "237 countries and areas (lever state 2023); roads for 161 countries ≥ 1 M", "T16", c("slide4.build3", "narration.s4"),
  method = "descriptive", status = "descriptive", n = 5L, universe = U237)

# --- 16.8 Validación y escritura --------------------------------------------
faltan <- claves_faltantes(reg, "slide4")
probl <- validar_registro(reg)
cat("Claves registradas:", length(reg), "| obligatorias de slide4 que faltan:", ifelse(length(faltan), paste(faltan, collapse = ", "), "ninguna"), "\n")
if (nrow(probl)) { cat("validar_registro():\n"); print(probl) }
guardar_numbers(reg, RUTA_NUMBERS_Q3, ordenar = TRUE)
reg_leido <- leer_numbers(RUTA_NUMBERS_Q3)
stopifnot(length(reg_leido) == length(reg))
cat("Escrito", RUTA_NUMBERS_Q3, "\n")

# =============================================================================
# 17. Estado de las hipótesis preinscritas de Q3 (regla escrita, resultado real)
# =============================================================================
# Qué: aplica la regla de decisión de docs/hipotesis_preinscritas.md. Por qué:
# reportar cada hipótesis con su resultado, sea cual sea (ASA A.2, C.3).
cat_sec("17. Hipótesis")
dsd <- function(v) extraer_ic(ic_p1[[v]], "dsd"); dcv <- function(v) extraer_ic(ic_p1[[v]], "dcv")
h9a_ok <- sil_k4 < 0.5 && all(jaccard_grupo >= 0.75) && ari_sin < 0.7
h9a_rech <- sil_k4 >= 0.5 || any(jaccard_grupo < 0.6) || ari_sin >= 0.7
h11a_sd <- dsd("LEx")$ci_high < 0 && dsd("LE65")$ci_low > 0
h11a_cv <- dcv("LEx")$ci_high < 0 && dcv("LE65")$ci_low > 0
hipotesis <- tibble::tibble(
  id = c("H9", "H9a", "H10", "H11", "H11a", "H14a", "H23", "H25"),
  regla = c("silhouette ≤ 0.23 (v1)",
            "silhouette < 0.5, every Jaccard ≥ 0.75, ARI with/without CNMR < 0.7 (reject: sil ≥ 0.5, a Jaccard < 0.6 or ARI ≥ 0.7)",
            "ΔSD median age 1950→2023 > 0 with interval > 0",
            "LEx converges and LE60 diverges (v1; LE60 from the supplement)",
            "SD and CV of LEx fall, SD and CV of LE65 rise, intervals not crossing 0 (partial: SD only)",
            "NatChange < 0 in ≤ 10 countries in 1990 and ≥ 40 in 2023",
            "share of Q5 > 25 countries on pace for 2030 < 25 %",
            "same-road neighbour share ≥ 1.5 × chance and above the 97.5 % null"),
  resultado = c(sprintf("silhouette %.3f", sil_k4),
                sprintf("silhouette %.3f; Jaccard %.2f-%.2f; ARI without CNMR %.2f", sil_k4, min(jaccard_grupo), max(jaccard_grupo), ari_sin),
                sprintf("SD %.2f → %.2f; Δ %.2f [block %.2f; %.2f]", d1("MedianAgePop", 1950), d1("MedianAgePop", 2023),
                        dsd("MedianAgePop")$valor, dsd("MedianAgePop")$ci_low, dsd("MedianAgePop")$ci_high),
                sprintf("ΔSD LEx %.2f [%.2f; %.2f]; ΔSD LE60 %.2f [%.2f; %.2f]", dsd("LEx")$valor, dsd("LEx")$ci_low, dsd("LEx")$ci_high,
                        dsd("LE60")$valor, dsd("LE60")$ci_low, dsd("LE60")$ci_high),
                sprintf("ΔSD LEx %.2f [%.2f; %.2f], LE65 %.2f [%.2f; %.2f]; ΔCV LEx %.2f [%.2f; %.2f], LE65 %.2f [%.2f; %.2f]",
                        dsd("LEx")$valor, dsd("LEx")$ci_low, dsd("LEx")$ci_high, dsd("LE65")$valor, dsd("LE65")$ci_low, dsd("LE65")$ci_high,
                        dcv("LEx")$valor, dcv("LEx")$ci_low, dcv("LEx")$ci_high, dcv("LE65")$valor, dcv("LE65")$ci_low, dcv("LE65")$ci_high),
                sprintf("%d (1990) → %d (2023)", dec(1990, "n_natneg"), dec(2023, "n_natneg")),
                sprintf("%d / %d = %.1f %% [Wilson %.1f; %.1f]", n_sdg_pace, n_sdg_above, w_sdg$valor, w_sdg$ci_low, w_sdg$ci_high),
                sprintf("%.3f vs %.3f (×%.2f; 97.5 %% null %.3f; p = %.3f)", jc$obs, jc$nulo_media, jc$obs / jc$nulo_media, jc$hi, jc$p)),
  estado = c(ifelse(sil_k4 <= 0.23, "confirmada", "rechazada"),
             ifelse(h9a_ok, "confirmada", ifelse(h9a_rech, "rechazada", "matizada")),
             ifelse(dsd("MedianAgePop")$ci_low > 0, "confirmada", "rechazada"),
             ifelse(dsd("LEx")$ci_high < 0 && dsd("LE60")$ci_low > 0, "confirmada", "rechazada"),
             ifelse(h11a_sd && h11a_cv, "confirmada", ifelse(h11a_sd, "matizada (solo DE)", "rechazada"))
             , ifelse(dec(1990, "n_natneg") <= 10 && dec(2023, "n_natneg") >= 40, "confirmada", "rechazada"),
             ifelse(w_sdg$valor < 25, "confirmada", "rechazada"),
             ifelse(jc$obs / jc$nulo_media >= 1.5 && jc$obs > jc$hi, "confirmada", "rechazada")))
print(hipotesis, width = 220)
arrow::write_parquet(hipotesis, file.path(RUTA_PROCESSED, "resultados_q3_hipotesis.parquet"))

# =============================================================================
# 18. Cierre: tiempo de ejecución y sesión
# =============================================================================
t_total <- as.numeric(difftime(Sys.time(), t_inicio, units = "secs"))
cat_sec("18. Cierre")
cat(sprintf("04_q3_caminos.R terminó en %.1f s (%.1f min). Semilla %d; RNG %s.\n", t_total, t_total / 60, SEMILLA,
            paste(RNGkind(), collapse = " / ")))
cat("R", R.version.string, "| fda", as.character(utils::packageVersion("fda")), "| cluster", as.character(utils::packageVersion("cluster")),
    "| mclust", as.character(utils::packageVersion("mclust")), "| sf", as.character(utils::packageVersion("sf")), "\n")
invisible(TRUE)
