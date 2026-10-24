#!/usr/bin/env Rscript
# =============================================================================
# 03_q2_un_numero.R
# Q2 — "Can a single indicator tell the whole story?" (P8 + P5)
#
# Ejecutar desde la raíz del repo:   Rscript R/03_q2_un_numero.R
#
# Qué hace (plan analítico v2 §4-Q2; tareas T8, T9, T10 y T15 del plan de
# implementación §3.1). Cada bloque va de lo simple a lo rico:
#   1. Datos: corte 2023 de los 161 países >= 1 M (+ 2050 proyectado, 237 y 1990
#      como sensibilidad). CNMR winsorizada ±3 DE solo para PCA y look-alikes.
#   2. S1 · Scorecard "qué explica la fecundidad sola" (H6): R² ajustado de 4
#      salidas declaradas a priori; IC por bloques de subregión (pantalla) y BCa
#      iid (notebook); validación cruzada 10-fold × 20 y por bloques
#      (dejar fuera una subregión); spline, 237, 1990, sin Golfo; el mismo R² en
#      cada año 1950–2023 y el cambio OBSERVADO a 27 años como contraste del
#      cambio proyectado 2023→2050.
#   3. Escalera 0,59 → 0,70 → 0,99 como IDENTIDAD contable (nota al pie) y
#      escalera honesta "fuera de tiempo" (crecimiento 10 años después).
#   4. La tasa bruta de mortalidad cambió de significado (H13): ρ(CDR, LEx) por
#      año 1950–2023 con banda por bloques; par Portugal–Chad por regla.
#   5. S2 · Gemelos por regla (búsqueda exhaustiva de 12 880 pares).
#   6. R1 · Prueba de look-alikes (H20): 5 vecinos con TFR sola vs 12
#      indicadores vs 2 ejes del PCA; perfil recuperado; tabla de todos los países.
#   7. R2 · PCA con el conjunto fijo de 12 variables + análisis paralelo (H7, H7a);
#      sensibilidades (conjuntos de variables, sin Golfo, 237, asinh, 1950/1990/2050).
#   8. R3 · Índice compuesto P5 (H8, H8a): 7 variantes a mano y Monte Carlo de
#      2 000 diseños; α y ω solo notebook; validez con LE60.
#   9. Hallazgo de demografía: misma fecundidad, saldo natural opuesto (dem01).
#  10. Redundancia (solo notebook): VIF y correlaciones parciales.
#  11. Hipótesis de Q2, registro de cifras (figures/numbers_q2.json) y tablas.
#
# Reglas (plan §3, ética ASA 2022): países = ISO3_code no vacío; estimaciones
# <= 2023 y proyección Medium >= 2024 siempre separadas y etiquetadas; ningún
# estadístico cruza 2023/24 salvo la salida "cambio 2023→2050", declarada a
# priori en H6 como proyección ("partly by construction"); lenguaje descriptivo,
# nunca causal; set.seed(2026) justo antes de cada bloque aleatorio.
#
# SALIDAS
#   figures/numbers_q2.json            (claves de Q2, esquema v2 de numbers.json)
#   figures/lookalikes_todos.csv       (tabla completa de look-alikes; plan T9)
#   figures/review/q2/q2_*.png         (gráficas rápidas de revisión, 1600×900)
#   data/processed/resultados_q2_*.parquet — columnas:
#   * resultados_q2_scorecard.parquet: salida (código), salida_en (etiqueta),
#       r2_adj (R² ajustado sobre TFR, 2023, 161), r2 (sin ajustar), ci_low/ci_high
#       (bootstrap por bloques de subregión, 95 %, B = 2000), ci_iid_low/ci_iid_high
#       (BCa iid de países), r2_cv10 (VC 10-fold × 20, media), r2_cv10_min/max
#       (rango de las 20 repeticiones), r2_cv_loso (VC dejando fuera una
#       subregión), r2_spline3 (spline natural 3 gl, ajustado), r2_237 (237 países),
#       r2_1990 (análogo observado 1990: salida 1990 o cambio 1990→2017),
#       r2_sin_golfo (155 países), periodo_salida ("Estimate"/"UN medium projection").
#   * resultados_q2_r2_por_anio.parquet: Time, salida ("medage" / "growth" /
#       "cnmr" = mismo año; "chg27_observed" = cambio observado a 27 años desde el
#       año de origen; "chg2050_projected" = referencia proyectada), r2_adj, periodo.
#   * resultados_q2_escalera.parquet: tipo ("same year (identity)" / "10 years
#       later (out of time)"), origen_entrenamiento, origen_prueba, modelo, r2.
#   * resultados_q2_rho_cdr_lex.parquet: Time, rho_cdr_lex (Spearman entre
#       países), ci_low/ci_high (bloques; NA en proyección), r_pearson_cdr_lex,
#       rho_cdr_medage, n, periodo_en.
#   * resultados_q2_gemelos.parquet: regla (id), regla_en, rank, iso_a, iso_b,
#       pais_a, pais_b, var_igual, igual_a, igual_b, var_dif, dif_a, dif_b, dif_abs.
#   * resultados_q2_lookalikes.parquet (= figures/lookalikes_todos.csv):
#       ISO3_code, Location, region_sdg, ingreso, vecinos_12 / vecinos_tfr /
#       vecinos_pc12 / vecinos_pc1 (5 ISO3 separados por coma, del más al menos
#       parecido), vecinos_12_nombres, vecinos_tfr_nombres, solap_tfr, solap_pc1,
#       solap_pc12 (cuántos de los 5 vecinos reales recupera cada resumen, 0–5).
#   * resultados_q2_knn_resumen.parquet: caso, anio, periodo, conjunto, k, n,
#       resumen, solapamiento_pct, azar_pct, ci_low, ci_high (solo caso base).
#   * resultados_q2_knn_loso.parquet: subregion_fuera (subregión excluida), n,
#       tfr, pc1, pc12 (% de look-alikes recuperados rehaciendo todo sin ella).
#   * resultados_q2_recupera.parquet: resumen, perfil_recuperado (R² medio de los
#       12 indicadores, lineal), perfil_recuperado_spline (spline 3 gl).
#   * resultados_q2_pca_scores.parquet: ISO3_code, Location, region_sdg,
#       subregion, ingreso, es_golfo, TFR, CNMR_raw, CNMR_w (winsorizada),
#       PC1..PC4 (PC1 orientado con LEx > 0; PC2 con CNMR > 0).
#   * resultados_q2_pca_cargas.parquet: variable, variable_en, carga_PC1..PC4,
#       r_PC1..r_PC4 (correlación variable–componente).
#   * resultados_q2_pca_autovalores.parquet: caso, componente, autovalor,
#       p50_nulo, p95_nulo (análisis paralelo, 1000 permutaciones), var_pct.
#   * resultados_q2_pca_sensibilidad.parquet: caso, tipo (conjunto / muestra /
#       año), periodo, n, n_vars, pc1_pct, pc2_pct, acum2_pct, n_dims_paralelo,
#       r_tfr_pc1, r_tfr_pc2.
#   * resultados_q2_indice_variantes.parquet: ISO3_code, Location, rank_V1..V7
#       (1 = transición más avanzada), amplitud_7, amplitud_norm, amplitud_pesos,
#       salto_mig, amplitud_sin_mig.
#   * resultados_q2_indice_mc.parquet: spec, ISO3_code, Location, rango_base
#       (V1), r05, r50, r95, ancho90, mas20.
#   * resultados_q2_mc_resumen.parquet: spec, descripcion_en, mediana_ancho,
#       p90_ancho, pct_mas20.
#   * resultados_q2_misma_fecundidad.parquet: ISO3_code, Location, region_sdg,
#       TFR, NatChangeRT, CNMR, PopGrowthRate, MedianAgePop.
#   * resultados_q2_redundancia.parquet: tipo ("VIF 12" / "partial r"), par, valor.
#   * resultados_q2_hipotesis.parquet: id, enunciado_en, estatus, resultado,
#       evidencia.
#
# Convención: código y comentarios en español; textos de gráficas en inglés.
# =============================================================================

t_inicio <- Sys.time()

suppressPackageStartupMessages({
  library(here)
})
source(here::here("R", "config.R"))
source(here::here("R", "utilidades.R"))
source(here::here("R", "comun_analisis.R"))
source(here::here("R", "incertidumbre.R"))

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(ggplot2)
  library(ggrepel)
  library(patchwork)
  library(scales)
  library(arrow)
  library(splines)
})

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(SEMILLA)

# =============================================================================
# 0. Constantes, rutas y ayudas de este script
# =============================================================================

RUTA_FIG_Q2 <- file.path(RUTA_FIG_REVIEW, "q2")
dir.create(RUTA_FIG_Q2, recursive = TRUE, showWarnings = FALSE)
RUTA_NUMBERS_Q2 <- file.path(RUTA_FIGURAS, "numbers_q2.json")
RUTA_LOOKALIKES_CSV <- file.path(RUTA_FIGURAS, "lookalikes_todos.csv")
ruta_parquet_q2 <- function(nombre) file.path(RUTA_PROCESSED, paste0("resultados_q2_", nombre, ".parquet"))

B_Q2 <- B_BOOT_BLOQUES          # 2000 réplicas para todo IC que pueda salir en pantalla
B_IID_PCA <- B_BOOT_PCA         # 1000 réplicas (percentil) para PCA iid, como pide el plan
B_PARALELO <- 1000              # permutaciones del análisis paralelo de Horn
M_INDICE <- 2000                # diseños del Monte Carlo del índice
K_LOOK <- K_VECINOS             # 5 vecinos más cercanos

# Las 12 variables fijas del plan (VARS_PCA de config.R) con la densidad en log.
VARS_12 <- sub("^PopDensity$", "logDens", VARS_PCA)
# Conjunto de 8 de config.R (sensibilidad principal del plan).
VARS_8 <- VARS_PCA_SENSIBILIDAD
# Otros conjuntos documentados por los memos (MV §3.1, INF §3.3), solo sensibilidad.
CONJUNTOS_PCA <- list(
  `12 fixed (plan)`            = VARS_12,
  `8 (config, sensitivity)`    = VARS_8,
  `8 catalogue (MV)`           = c("TFR", "LEx", "IMR", "MedianAgePop", "CNMR", "PopGrowthRate", "CBR", "CDR"),
  `8 non-redundant (MV)`       = c("TFR", "LEx", "Q1560", "CDR", "MedianAgePop", "CNMR", "PopSexRatio", "logDens"),
  `13 EDA (MV)`                = c("TFR", "MAC", "SRB", "LEx", "LE65", "Q5", "Q1560", "CDR", "MedianAgePop",
                                   "PopGrowthRate", "CNMR", "PopSexRatio", "logDens"),
  `8 transition core (INF)`    = c("TFR", "CBR", "LEx", "Q5", "IMR", "CDR", "MedianAgePop", "PopGrowthRate")
)

FILTRO_1M_2023 <- "161 countries ≥ 1 M people (2023); UN estimates for 2023"
USO_NB <- "notebook.q2"

# --- Registro de cifras (figures/numbers_q2.json) ---------------------------
reg <- nuevo_registro()
# Envoltorio: añade la cifra al registro global `reg` (mismos argumentos que registrar_cifra()).
anotar <- function(...) {
  reg <<- registrar_cifra(reg, ...)
  invisible(NULL)
}

# --- Tema y guardado de las gráficas de revisión (1600×900) ------------------
tema_q2 <- function() {
  theme_wpp(base_size = 15) +
    theme(plot.caption = element_text(size = rel(0.62), colour = "#666666", hjust = 0),
          plot.title.position = "plot", plot.caption.position = "plot")
}
pie_q2 <- function(...) paste(c(..., badge("PIE-3")), collapse = "\n")
guardar_q2 <- function(p, nombre) {
  guardar_png(p, nombre, carpeta = RUTA_FIG_Q2, ancho = 1600, alto = 900, res = 110)
}
COLOR_GRIS_OSCURO <- "#4D4D4D"
COLOR_GRIS_CLARO <- "#BBBBBB"

# --- Utilidades numéricas ---------------------------------------------------
# Winsorización ±k DE (solo PCA, look-alikes y clustering; plan §3 "Migración extrema").
wins3 <- function(x, k = 3) {
  m <- mean(x, na.rm = TRUE); s <- stats::sd(x, na.rm = TRUE)
  pmin(pmax(x, m - k * s), m + k * s)
}
# R² de una regresión lineal (ajustado por defecto, como dice H6).
r2_lm <- function(d, y, x = "TFR", ajustado = TRUE) {
  s <- summary(stats::lm(stats::reformulate(x, y), data = d))
  if (ajustado) s$adj.r.squared else s$r.squared
}
# R² fuera de muestra = 1 − SSE/SST (SST con la media de todo el conjunto evaluado).
r2_fuera <- function(y, pred) 1 - sum((y - pred)^2) / sum((y - mean(y))^2)

# Validación cruzada K-fold repetida (la semilla se fija fuera, justo antes).
cv_kfold <- function(d, y, x = "TFR", K = 10, reps = 20) {
  f <- stats::reformulate(x, y)
  vals <- replicate(reps, {
    folds <- sample(rep_len(seq_len(K), nrow(d)))
    pred <- numeric(nrow(d))
    for (k in seq_len(K)) {
      m <- stats::lm(f, data = d[folds != k, , drop = FALSE])
      pred[folds == k] <- stats::predict(m, newdata = d[folds == k, , drop = FALSE])
    }
    r2_fuera(d[[y]], pred)
  })
  c(media = mean(vals), min = min(vals), max = max(vals))
}
# Validación cruzada por BLOQUES: se deja fuera una subregión ONU completa cada vez.
cv_loso <- function(d, y, x = "TFR", bloque = "subregion") {
  f <- stats::reformulate(x, y)
  pred <- numeric(nrow(d))
  for (s in unique(d[[bloque]])) {
    i <- d[[bloque]] == s
    m <- stats::lm(f, data = d[!i, , drop = FALSE])
    pred[i] <- stats::predict(m, newdata = d[i, , drop = FALSE])
  }
  r2_fuera(d[[y]], pred)
}

# --- Nombres de países para texto y voz --------------------------------------
# En texto: nombre WPP (columna Location). En la voz: nombre corto (countrycode),
# con los alias del plan (Türkiye, Viet Nam, Republic of Korea) y las
# denominaciones ONU de Kosovo y Taiwán.
nombre_corto <- function(iso3) {
  especiales <- c(TUR = "Türkiye", VNM = "Viet Nam", KOR = "Republic of Korea", PRK = "DPR Korea",
                  IRN = "Iran", USA = "the United States", GBR = "the United Kingdom", RUS = "Russia",
                  ARE = "the United Arab Emirates", SYR = "Syria", BOL = "Bolivia", VEN = "Venezuela",
                  TZA = "Tanzania", COD = "DR Congo", LAO = "Lao PDR", MDA = "Moldova",
                  PSE = "State of Palestine", XKX = "Kosovo (under UNSC res. 1244)", HKG = "Hong Kong SAR",
                  TWN = "China, Taiwan Province of China", NLD = "the Netherlands", PHL = "the Philippines",
                  CZE = "Czechia", CIV = "Côte d'Ivoire", MKD = "North Macedonia")
  out <- suppressWarnings(countrycode::countrycode(iso3, "iso3c", "country.name.en", warn = FALSE))
  hay <- iso3 %in% names(especiales)
  out[hay] <- especiales[iso3[hay]]
  out[is.na(out)] <- nombre_pais(iso3[is.na(out)])
  unname(out)
}
unir_y <- function(x) {
  if (length(x) <= 1) return(paste(x, collapse = ""))
  paste(paste(x[-length(x)], collapse = ", "), "and", x[length(x)])
}
# Frases habladas redondeadas (campo `say`).
NUM_EN <- c("one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve")
decir_fraccion <- function(x) {
  if (is.na(x)) return(NA_character_)
  if (x < 0.05) return("almost nothing")
  fr <- c("one in ten" = 0.1, "one in five" = 0.2, "a quarter" = 0.25, "a third" = 1 / 3,
          "two in five" = 0.4, "half" = 0.5, "three in five" = 0.6, "two thirds" = 2 / 3,
          "seven in ten" = 0.7, "three quarters" = 0.75, "four in five" = 0.8,
          "nearly nine in ten" = 0.875, "nine in ten" = 0.9)
  names(fr)[which.min(abs(fr - x))]
}
decir_uno_de <- function(pct, sustantivo = NULL) {
  n <- round(100 / pct)
  if (n < 1 || n > length(NUM_EN)) return(sprintf("%.0f percent", pct))
  if (is.null(sustantivo)) paste("one in", NUM_EN[n]) else paste("one", sustantivo, "in", NUM_EN[n])
}
decir_entero <- function(x) {
  n <- round(abs(x))
  if (n >= 1 && n <= length(NUM_EN)) NUM_EN[n] else as.character(n)
}

message("== Q2: infraestructura lista; empieza el análisis ==")

# =============================================================================
# 1. Datos: corte 2023 de los 161 países >= 1 M
#    Qué: una fila por país con los 12 indicadores del PCA y las 4 salidas de H6.
#    Por qué: el plan fija 2023 y los países >= 1 M para modelos (los
#    microestados cambian signos de correlaciones, plan §3).
# =============================================================================

#' Corte de un año listo para Q2: CNMR cruda y tratada, densidad en log.
#' @param tratamiento_cnmr "wins" (±3 DE, principal), "asinh" (asinh(CNMR/5), sensibilidad) o "raw".
preparar_corte <- function(anio, muestra = "1m", tratamiento_cnmr = c("wins", "asinh", "raw")) {
  tratamiento_cnmr <- match.arg(tratamiento_cnmr)
  d <- corte_anio(anio, muestra) |> arrange(.data$ISO3_code)
  d$CNMR_raw <- d$CNMR
  d$CNMR <- switch(tratamiento_cnmr,
                   wins = wins3(d$CNMR_raw),
                   asinh = asinh(d$CNMR_raw / 5),
                   raw = d$CNMR_raw)
  d$logDens <- log(d$PopDensity)
  d
}

d23 <- preparar_corte(2023)
stopifnot(nrow(d23) == N_PAISES_1M, !anyNA(d23[, VARS_12]))

# Población 2050 (proyección Medium) para la salida "cambio 2023→2050" de H6.
pob_2050 <- corte_anio(2050, "1m", vars = "TPopulation1July") |>
  select(ISO3_code, pop2050 = TPopulation1July)
d23 <- d23 |>
  left_join(pob_2050, by = "ISO3_code") |>
  mutate(chg2050 = 100 * (pop2050 / TPopulation1July - 1))
stopifnot(!anyNA(d23$chg2050))

# Winsorización documentada (plan §3): a quién afecta en 2023.
iso_wins_2023 <- d23$ISO3_code[abs(d23$CNMR - d23$CNMR_raw) > 1e-12]
message("CNMR winsorizada ±3 DE en 2023 (", length(iso_wins_2023), " países): ",
        paste(iso_wins_2023, collapse = ", "))
anotar("n_cnmr_winsorized_2023", length(iso_wins_2023), "countries", "0",
       "Countries whose 2023 net migration rate is capped at mean ± 3 SD before PCA and look-alikes",
       FILTRO_1M_2023, "T9.0", USO_NB, method = "descriptive", status = "descriptive",
       n = N_PAISES_1M, universe = UNIVERSO_1M,
       sens_note = paste("Winsorized:", paste(iso_wins_2023, collapse = ", "),
                         "· sensitivity: asinh(CNMR/5) instead of winsorizing"))

# Identidad contable (plan §3): crecimiento ≈ (CBR − CDR + CNMR)/10.
resid_identidad <- max(abs(d23$PopGrowthRate - (d23$CBR - d23$CDR + d23$CNMR_raw) / 10))
message(sprintf("Residuo máximo de la identidad PopGrowthRate ≈ (CBR − CDR + CNMR)/10 en 2023: %.4f pp",
                resid_identidad))

# =============================================================================
# 2. S1 · Scorecard "qué explica la fecundidad sola" (H6, pre-specified)
#    Qué: R² ajustado de 4 regresiones simples sobre la TFR, salidas fijadas a
#    priori: edad mediana, cambio 2023→2050 (proyección), crecimiento y CNMR.
#    Por qué: es la respuesta corta a P8 ("historia lenta" vs "palancas
#    rápidas"); el IC por bloques de subregión reconoce que los vecinos se parecen.
# =============================================================================

SALIDAS_H6 <- c(medage = "MedianAgePop", chg2050 = "chg2050", growth = "PopGrowthRate", cnmr = "CNMR_raw")
SALIDAS_H6_EN <- c(medage = "Age structure today (median age)",
                   chg2050 = "Population change 2023→2050 (UN projection)",
                   growth = "Growth rate today", cnmr = "Net migration rate today")

sc <- d23 |> select(ISO3_code, Location, subregion, region_sdg, ingreso, TFR, all_of(unname(SALIDAS_H6)))

# 2.1 Versión simple: R² puntual (ajustado y sin ajustar).
r2_adj <- vapply(SALIDAS_H6, function(y) r2_lm(sc, y), numeric(1))
r2_raw <- vapply(SALIDAS_H6, function(y) r2_lm(sc, y, ajustado = FALSE), numeric(1))
print(round(rbind(r2_adj, r2_raw), 3))

# 2.2 IC por bloques de subregión (pantalla) y BCa iid (notebook).
stat_scorecard <- function(d) vapply(SALIDAS_H6, function(y) r2_lm(d, y), numeric(1))
set.seed(SEMILLA)
bs_score <- bootstrap_bloques(sc, stat_scorecard, B = B_Q2, semilla = SEMILLA)
bca_score <- lapply(SALIDAS_H6, function(y) {
  set.seed(SEMILLA)
  bootstrap_bca(sc, function(d) r2_lm(d, y), B = B_Q2, semilla = SEMILLA)
})

# 2.3 Validación: VC 10-fold × 20 (países) y VC por bloques (dejar fuera una subregión).
cv10 <- lapply(SALIDAS_H6, function(y) { set.seed(SEMILLA); cv_kfold(sc, y) })
cvloso <- vapply(SALIDAS_H6, function(y) cv_loso(sc, y), numeric(1))

# 2.4 Versión rica / sensibilidades: spline natural 3 gl, 237 países, 1990, sin Golfo.
r2_spline <- vapply(SALIDAS_H6, function(y) r2_lm(sc, y, x = "ns(TFR, df = 3)"), numeric(1))

sc237 <- corte_anio(2023, "completa") |>
  left_join(corte_anio(2050, "completa", vars = "TPopulation1July") |>
              select(ISO3_code, pop2050 = TPopulation1July), by = "ISO3_code") |>
  mutate(chg2050 = 100 * (pop2050 / TPopulation1July - 1), CNMR_raw = CNMR)
r2_237 <- vapply(SALIDAS_H6, function(y) r2_lm(sc237, y), numeric(1))

# Análogo OBSERVADO en 1990: las mismas salidas en 1990 y el cambio 1990→2017
# (27 años, como 2023→2050, pero con estimaciones).
sc1990 <- corte_anio(1990, "1m") |>
  left_join(corte_anio(2017, "1m", vars = "TPopulation1July") |>
              select(ISO3_code, pop2017 = TPopulation1July), by = "ISO3_code") |>
  mutate(chg2050 = 100 * (pop2017 / TPopulation1July - 1), CNMR_raw = CNMR)
r2_1990 <- vapply(SALIDAS_H6, function(y) r2_lm(sc1990, y), numeric(1))

sc_sin_golfo <- sc |> filter(!es_golfo(ISO3_code))
r2_sin_golfo <- vapply(SALIDAS_H6, function(y) r2_lm(sc_sin_golfo, y), numeric(1))

tabla_scorecard <- tibble(
  salida = names(SALIDAS_H6), salida_en = unname(SALIDAS_H6_EN[names(SALIDAS_H6)]),
  r2_adj = unname(r2_adj), r2 = unname(r2_raw),
  ci_low = unname(bs_score$ci_low), ci_high = unname(bs_score$ci_high),
  ci_iid_low = vapply(bca_score, `[[`, numeric(1), "ci_low"),
  ci_iid_high = vapply(bca_score, `[[`, numeric(1), "ci_high"),
  r2_cv10 = vapply(cv10, `[[`, numeric(1), "media"),
  r2_cv10_min = vapply(cv10, `[[`, numeric(1), "min"),
  r2_cv10_max = vapply(cv10, `[[`, numeric(1), "max"),
  r2_cv_loso = unname(cvloso), r2_spline3 = unname(r2_spline), r2_237 = unname(r2_237),
  r2_1990 = unname(r2_1990), r2_sin_golfo = unname(r2_sin_golfo),
  periodo_salida = ifelse(names(SALIDAS_H6) == "chg2050", ETIQUETA_PROYECCION, ETIQUETA_ESTIMACION)
)
print(tabla_scorecard |> mutate(across(where(is.numeric), \(x) round(x, 3))), width = 200)
write_parquet(tabla_scorecard, ruta_parquet_q2("scorecard"))

# 2.5 Decisión H6 (umbrales fijados en docs/hipotesis_preinscritas.md).
h6_ok_punto <- r2_adj["medage"] >= 0.7 && r2_adj["chg2050"] >= 0.7 && r2_adj["growth"] <= 0.6 && r2_adj["cnmr"] <= 0.1
cv_media <- vapply(cv10, `[[`, numeric(1), "media")
h6_ok_cv <- cv_media["medage"] >= 0.7 && cv_media["chg2050"] >= 0.7 && cv_media["growth"] <= 0.6 && cv_media["cnmr"] <= 0.1

# 2.6 Registro de las 4 cifras del scorecard (+ VC).
claves_r2 <- c(medage = "r2_tfr_medage", chg2050 = "r2_tfr_chg2050", growth = "r2_tfr_growth", cnmr = "r2_tfr_cnmr")
defs_r2 <- c(
  medage = "Adjusted R² of median age (2023) regressed on total fertility rate (2023), across countries",
  chg2050 = "Adjusted R² of % population change 2023→2050 (UN medium projection) regressed on TFR 2023; partly by construction (UN projections build on fertility)",
  growth = "Adjusted R² of population growth rate (2023) regressed on TFR 2023, across countries",
  cnmr = "Adjusted R² of net migration rate (2023, not winsorized) regressed on TFR 2023, across countries")
say_r2 <- c(medage = decir_fraccion(r2_adj["medage"]), chg2050 = decir_fraccion(r2_adj["chg2050"]),
            growth = as.character(round(100 * r2_adj["growth"] / 10) * 10), cnmr = "almost nothing")
for (s in names(SALIDAS_H6)) {
  sens_vals <- c(r2_raw[s], r2_spline[s], r2_237[s], r2_1990[s], r2_sin_golfo[s], cv_media[s], cvloso[s])
  anotar(claves_r2[[s]], unname(r2_adj[s]), "R2", "0.00", defs_r2[[s]], FILTRO_1M_2023, "T8.1",
         c("slide3.build1", "fig07", "narration.s3"),
         ic = extraer_ic(bs_score, s), ic_iid = bca_score[[s]],
         sens_low = min(sens_vals), sens_high = max(sens_vals),
         sens_note = sprintf(paste0("unadjusted %.3f · natural spline 3 df %.3f · 237 countries %.3f · ",
                                    "1990 analogue (estimates%s) %.3f · without Gulf %.3f · 10-fold CV %.3f · ",
                                    "leave-one-subregion-out CV %.3f"),
                             r2_raw[s], r2_spline[s], r2_237[s],
                             if (s == "chg2050") ", change 1990→2017" else "", r2_1990[s], r2_sin_golfo[s],
                             cv_media[s], cvloso[s]),
         status = "pre-specified", hypothesis_id = "H6", n = N_PAISES_1M, universe = UNIVERSO_1M,
         say = say_r2[[s]])
  anotar(paste0(claves_r2[[s]], "_cv"), unname(cv_media[s]), "R2", "0.00",
         paste("Out-of-sample R² (1 − SSE/SST), 10-fold cross-validation repeated 20 times;", sub("^Adjusted R²", "outcome:", defs_r2[[s]])),
         FILTRO_1M_2023, "T8.2", c("slide3.build1", "fig07"), method = "cv_r2", seed = SEMILLA,
         sens_low = cv10[[s]][["min"]], sens_high = cv10[[s]][["max"]],
         sens_note = sprintf("range over the 20 repetitions; leave-one-subregion-out CV = %.3f", cvloso[s]),
         status = "pre-specified", hypothesis_id = "H6", n = N_PAISES_1M, universe = UNIVERSO_1M)
  anotar(paste0(claves_r2[[s]], "_cv_loso"), unname(cvloso[s]), "R2", "0.00",
         paste("Out-of-sample R² when each of the 20 UN subregions is left out in turn (block cross-validation);",
               sub("^Adjusted R²", "outcome:", defs_r2[[s]])),
         FILTRO_1M_2023, "T8.2", USO_NB, method = "cv_r2", status = "exploratory", hypothesis_id = "H6",
         n = N_PAISES_1M, universe = UNIVERSO_1M)
}

# 2.7 Figura de revisión: scorecard.
fig_sc <- tabla_scorecard |>
  mutate(salida_en = factor(salida_en, levels = rev(SALIDAS_H6_EN)),
         historia = ifelse(salida %in% c("medage", "chg2050"), "Slow story", "Fast levers"))
p_sc <- ggplot(fig_sc, aes(y = salida_en)) +
  geom_col(aes(x = pmax(r2_adj, 0), fill = historia), width = 0.62) +
  geom_errorbar(aes(xmin = pmax(ci_low, 0), xmax = ci_high), orientation = "y", width = 0.18,
                colour = "black", linewidth = 0.5) +
  geom_point(aes(x = pmax(r2_cv10, 0)), shape = 23, size = 3.2, fill = "white", colour = "black") +
  geom_text(aes(x = pmax(ci_high, 0) + 0.02,
                label = sprintf("%s  [%s; %s]", formatear_cifra(r2_adj, "0.00"), formatear_cifra(ci_low, "0.00"),
                                formatear_cifra(ci_high, "0.00"))),
            hjust = 0, size = 4.6) +
  scale_fill_manual(values = c("Slow story" = COLOR_NACIMIENTOS, "Fast levers" = COLOR_GRIS_OSCURO), name = NULL) +
  scale_x_continuous(limits = c(0, 1.18), breaks = seq(0, 1, 0.25), expand = expansion(mult = c(0, 0.01))) +
  labs(title = "What fertility alone can explain (2023, 161 countries ≥ 1 M)",
       subtitle = paste0("Adjusted R² of one regression on the total fertility rate; whisker = 95 % block bootstrap by UN subregion; ",
                         "diamond = 10-fold cross-validated R²"),
       x = "Share of country-to-country differences explained (adjusted R²)", y = NULL,
       caption = pie_q2("2050 change is a UN medium projection and partly built from fertility (by construction).",
                        FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_sc, "q2_01_scorecard")

# 2.8 Estabilidad en el tiempo (exploratorio): el mismo R² en cada año 1950–2023
#     y el análogo OBSERVADO del cambio a 27 años (origen 1950–1996 → +27 años).
#     Qué: ¿el 0,77 / 0,59 de 2023 es típico o es la foto de un año?
#     Por qué: "historia lenta" debe ser estable; "palancas rápidas", no. Y el 0,88
#     del cambio 2023→2050 se compara con lo que la TFR explicó de verdad en el pasado.
panel_est_q2 <- paises_1m(periodo = "estimacion") |>
  select(ISO3_code, Time, TFR, MedianAgePop, PopGrowthRate, CNMR, TPopulation1July)
r2_anual <- panel_est_q2 |> group_by(Time) |>
  group_modify(\(x, k) tibble(salida = c("medage", "growth", "cnmr"),
                              r2_adj = c(r2_lm(x, "MedianAgePop"), r2_lm(x, "PopGrowthRate"), r2_lm(x, "CNMR")))) |>
  ungroup()
H_CAMBIO <- 2050 - 2023
r2_chg_obs <- map_dfr(ANIO_INICIO_DATOS:(ANIO_FIN_ESTIMACION - H_CAMBIO), function(t0) {
  verificar_ventana(c(t0, t0 + H_CAMBIO))
  a <- panel_est_q2 |> filter(Time == t0) |> select(ISO3_code, TFR, p0 = TPopulation1July)
  b <- panel_est_q2 |> filter(Time == t0 + H_CAMBIO) |> select(ISO3_code, p1 = TPopulation1July)
  x <- inner_join(a, b, by = "ISO3_code") |> mutate(chg = 100 * (p1 / p0 - 1))
  tibble(Time = t0, salida = "chg27_observed", r2_adj = r2_lm(x, "chg"))
})
tabla_r2_anual <- bind_rows(r2_anual, r2_chg_obs) |> mutate(periodo = ETIQUETA_ESTIMACION) |>
  bind_rows(tibble(Time = 2023, salida = "chg2050_projected", r2_adj = unname(r2_adj["chg2050"]),
                   periodo = ETIQUETA_PROYECCION))
write_parquet(tabla_r2_anual, ruta_parquet_q2("r2_por_anio"))
resumen_anual <- function(sal) {
  x <- tabla_r2_anual |> filter(salida == sal)
  list(v = c(min = min(x$r2_adj), median = stats::median(x$r2_adj), max = max(x$r2_adj)),
       nota = sprintf("min %.3f (%d) · median %.3f · max %.3f (%d) · %d years", min(x$r2_adj),
                      as.integer(x$Time[which.min(x$r2_adj)]), stats::median(x$r2_adj), max(x$r2_adj),
                      as.integer(x$Time[which.max(x$r2_adj)]), nrow(x)))
}
for (cl in list(c("r2_tfr_medage_by_year", "medage", "median age"), c("r2_tfr_growth_by_year", "growth", "population growth rate"),
                c("r2_tfr_cnmr_by_year", "cnmr", "net migration rate"))) {
  ra <- resumen_anual(cl[2])
  anotar(cl[1], round(ra$v, 4), "R2", "0.00",
         sprintf("Adjusted R² of %s on TFR, computed separately in each year 1950–2023 (min / median / max across years)", cl[3]),
         "161 countries ≥ 1 M; UN estimates 1950–2023", "T8.1b", USO_NB, method = "sensitivity",
         sens_low = ra$v[["min"]], sens_high = ra$v[["max"]], sens_note = ra$nota,
         status = "exploratory", hypothesis_id = "H6", n = N_PAISES_1M, universe = UNIVERSO_1M)
}
ra_chg <- resumen_anual("chg27_observed")
anotar("r2_tfr_chg27_observed", round(ra_chg$v, 4), "R2", "0.00",
       # QA-stats (docs/QA_stats.md): se declara qué población entra en el cambio (1 de julio).
       sprintf(paste0("Adjusted R² of the OBSERVED %% population change over %d years (origin 1950–1996) on TFR at the origin ",
                      "(OLS, one regression per origin year; min / median / max across origins); change = 100 × (population on 1 July ",
                      "of year t + %d / population on 1 July of year t − 1), the same 1 July convention as the UN-projected 2023→2050 ",
                      "change (adjusted R² %.2f)"),
               H_CAMBIO, H_CAMBIO, r2_adj[["chg2050"]]),
       "161 countries ≥ 1 M; UN estimates 1950–2023", "T8.1b", c("slide3.build1.footnote", "notebook.q2"),
       method = "sensitivity", sens_low = ra_chg$v[["min"]], sens_high = ra_chg$v[["max"]], sens_note = ra_chg$nota,
       status = "exploratory", hypothesis_id = "H6", n = N_PAISES_1M, universe = UNIVERSO_1M)

ETIQ_R2_ANUAL <- c(medage = "Median age (same year)", growth = "Growth rate (same year)",
                   cnmr = "Net migration rate (same year)", chg27_observed = "Observed change over the next 27 years (by origin year)")
p_r2a <- tabla_r2_anual |> filter(salida != "chg2050_projected") |>
  mutate(salida = factor(ETIQ_R2_ANUAL[salida], levels = ETIQ_R2_ANUAL)) |>
  ggplot(aes(Time, r2_adj, colour = salida, linetype = salida)) +
  geom_hline(yintercept = 0, colour = COLOR_GRIS_CLARO) +
  geom_line(linewidth = 1.05) +
  annotate("point", x = 2023, y = r2_adj[["chg2050"]], size = 3.4, colour = COLOR_PROYECCION) +
  annotate("text", x = 2022, y = r2_adj[["chg2050"]] + 0.06, hjust = 1, size = 4.2, colour = "#666666",
           label = sprintf("2023→2050 change, UN projection: %.2f", r2_adj[["chg2050"]])) +
  scale_colour_manual(values = c(COLOR_NACIMIENTOS, COLOR_GRIS_OSCURO, COLOR_GRIS_CLARO, COLOR_NACIMIENTOS), name = NULL) +
  scale_linetype_manual(values = c("solid", "solid", "solid", "22"), name = NULL) +
  scale_y_continuous(limits = c(-0.05, 1), breaks = seq(0, 1, 0.25)) +
  guides(colour = guide_legend(nrow = 2), linetype = guide_legend(nrow = 2)) +
  labs(title = "Fertility's grip on age structure is stable; on growth it comes and goes",
       subtitle = sprintf("Adjusted R² on the total fertility rate, each year 1950–2023 · median age %.2f–%.2f · growth %.2f–%.2f · observed 27-year change %.2f–%.2f",
                          resumen_anual("medage")$v[["min"]], resumen_anual("medage")$v[["max"]],
                          resumen_anual("growth")$v[["min"]], resumen_anual("growth")$v[["max"]], ra_chg$v[["min"]], ra_chg$v[["max"]]),
       x = "Year (for the 27-year change: origin year)", y = "Adjusted R² on TFR",
       caption = pie_q2("Grey point: UN medium projection (scenario), partly built from fertility.", FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_r2a, "q2_13_r2_by_year")

# =============================================================================
# 3. Escalera de R²: identidad contable (nota) vs prueba "fuera de tiempo"
#    Qué: crecimiento ~ TFR → +CDR → +CNMR el mismo año (0,59 → 0,70 → 0,99) y,
#    como comparación honesta, el mismo modelo prediciendo el crecimiento 10 años
#    después en otros años (entrenar 2003→2011–13, probar 2013→2021–23).
#    Por qué: el 0,99 es por construcción (crecimiento = natalidad − mortalidad +
#    migración); solo la prueba fuera de tiempo dice algo sobre información útil.
# =============================================================================

escalera_mismo_anio <- tibble(
  modelo = c("TFR", "TFR + CDR", "TFR + CDR + CNMR", "CBR + CDR + CNMR"),
  r2 = c(r2_lm(d23, "PopGrowthRate", "TFR"),
         r2_lm(d23, "PopGrowthRate", c("TFR", "CDR")),
         r2_lm(d23, "PopGrowthRate", c("TFR", "CDR", "CNMR_raw")),
         r2_lm(d23, "PopGrowthRate", c("CBR", "CDR", "CNMR_raw")))
) |> mutate(tipo = "same year (identity)", origen_entrenamiento = 2023L, origen_prueba = 2023L)

# Fuera de tiempo (memo de series de tiempo §3.5): predictores en t0, salida =
# crecimiento medio de t0+8 a t0+10; entrenar con t0 y evaluar con t0+10.
par_fuera_tiempo <- function(t0, h = 10) {
  verificar_ventana(c(t0, t0 + h))
  x <- paises_1m(anios = t0) |> select(ISO3_code, TFR, CDR, CNMR, g0 = PopGrowthRate, MedianAgePop)
  y <- paises_1m(anios = (t0 + h - 2):(t0 + h)) |> group_by(ISO3_code) |>
    summarise(gh = mean(PopGrowthRate), .groups = "drop")
  inner_join(x, y, by = "ISO3_code")
}
MODELOS_FT <- list(`TFR` = "TFR", `TFR + CDR` = c("TFR", "CDR"), `TFR + CDR + CNMR` = c("TFR", "CDR", "CNMR"),
                   `Median age only` = "MedianAgePop", `Today's growth only` = "g0")
escalera_fuera <- map_dfr(c(1980L, 1990L, 2003L), function(t0) {
  tr <- par_fuera_tiempo(t0); te <- par_fuera_tiempo(t0 + 10L)
  imap_dfr(MODELOS_FT, function(x, nm) {
    m <- stats::lm(stats::reformulate(x, "gh"), data = tr)
    tibble(modelo = nm, r2 = r2_fuera(te$gh, stats::predict(m, newdata = te)),
           origen_entrenamiento = t0, origen_prueba = t0 + 10L)
  })
}) |> mutate(tipo = "10 years later (out of time)")
tabla_escalera <- bind_rows(escalera_mismo_anio, escalera_fuera) |>
  select(tipo, origen_entrenamiento, origen_prueba, modelo, r2)
print(tabla_escalera |> mutate(r2 = round(r2, 3)), n = 30)
write_parquet(tabla_escalera, ruta_parquet_q2("escalera"))

anotar("r2_ladder_tfr_cdr", escalera_mismo_anio$r2[2], "R2", "0.00",
       "Adjusted R² of growth rate 2023 on TFR + CDR (same year); step of the accounting ladder, not a finding",
       FILTRO_1M_2023, "T8.3", c("slide3.build1.footnote"), method = "descriptive", status = "descriptive",
       n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("r2_all", escalera_mismo_anio$r2[3], "R2", "0.00",
       "Adjusted R² of growth rate 2023 on TFR + CDR + net migration rate: births − deaths + migration = growth (accounting identity, by construction)",
       FILTRO_1M_2023, "T8.3", c("slide3.build1.footnote", "fig07"), method = "descriptive", status = "descriptive",
       sens_note = sprintf("with CBR instead of TFR: %.4f; max |growth − (CBR − CDR + CNMR)/10| = %.4f pp",
                           escalera_mismo_anio$r2[4], resid_identidad),
       n = N_PAISES_1M, universe = UNIVERSO_1M)
ft <- escalera_fuera |> group_by(modelo) |>
  summarise(v = r2[origen_entrenamiento == 2003], lo = min(r2), hi = max(r2), .groups = "drop")
claves_ft <- c(`TFR` = "r2_oot_tfr", `TFR + CDR` = "r2_oot_tfr_cdr", `TFR + CDR + CNMR` = "r2_oot_tfr_cdr_cnmr",
               `Median age only` = "r2_oot_medage", `Today's growth only` = "r2_oot_growth_today")
for (i in seq_len(nrow(ft))) {
  anotar(claves_ft[[ft$modelo[i]]], ft$v[i], "R2", "0.00",
         sprintf(paste0("Out-of-time R² for mean growth 8–10 years later: model '%s' trained on 2003 indicators ",
                        "→ growth 2011–13, tested on 2013 indicators → growth 2021–23 (estimates only)"), ft$modelo[i]),
         "161 countries ≥ 1 M; UN estimates 1980–2023", "T8.4", USO_NB, method = "cv_r2",
         sens_low = ft$lo[i], sens_high = ft$hi[i],
         sens_note = "range over training origins 1980, 1990 and 2003 (test 10 years later)",
         status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)
}

p_esc <- tabla_escalera |>
  filter(modelo %in% c("TFR", "TFR + CDR", "TFR + CDR + CNMR"),
         tipo == "same year (identity)" | origen_entrenamiento == 2003) |>
  mutate(tipo = factor(tipo, levels = c("same year (identity)", "10 years later (out of time)"),
                       labels = c("Same year (2023): an accounting identity",
                                  "Growth 10 years later (train 2003, test 2013→2021–23)")),
         modelo = factor(modelo, levels = c("TFR", "TFR + CDR", "TFR + CDR + CNMR"))) |>
  ggplot(aes(modelo, r2, fill = tipo)) +
  geom_col(position = position_dodge(width = 0.75), width = 0.7) +
  geom_text(aes(label = sprintf("%.2f", r2)), position = position_dodge(width = 0.75), vjust = -0.4, size = 4.8) +
  scale_fill_manual(values = c(COLOR_GRIS_CLARO, COLOR_NACIMIENTOS), name = NULL) +
  scale_y_continuous(limits = c(0, 1.08), breaks = seq(0, 1, 0.25)) +
  labs(title = "Adding the other components reaches 0.99 only by construction",
       subtitle = "Growth = births − deaths + net migration. Predicting growth a decade later, today's migration adds nothing.",
       x = "Predictors of the population growth rate", y = "R² (adjusted / out of time)",
       caption = pie_q2(FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_esc, "q2_02_identity_vs_out_of_time")

# =============================================================================
# 4. La tasa bruta de mortalidad cambió de significado (H13, pre-specified)
#    Qué: ρ de Spearman entre países de CDR y LEx en cada año 1950–2023 con banda
#    por bloques de subregión; par "misma CDR, máxima diferencia de LEx" por regla.
#    Por qué: un mismo indicador puede medir cosas distintas según la etapa; en
#    poblaciones envejecidas la CDR mide edad, no salud.
# =============================================================================

ANIOS_EST <- ANIO_INICIO_DATOS:ANIO_FIN_ESTIMACION
panel_cdr <- paises_1m(periodo = "estimacion") |> select(ISO3_code, subregion, Time, CDR, LEx, MedianAgePop)
ancho_cdr <- panel_cdr |>
  pivot_wider(id_cols = c(ISO3_code, subregion), names_from = Time, values_from = c(CDR, LEx, MedianAgePop))
stat_rho_anual <- function(d) {
  setNames(vapply(ANIOS_EST, function(a) stats::cor(d[[paste0("CDR_", a)]], d[[paste0("LEx_", a)]],
                                                     method = "spearman"), numeric(1)), ANIOS_EST)
}
set.seed(SEMILLA)
bs_rho <- bootstrap_bloques(ancho_cdr, stat_rho_anual, B = B_Q2, semilla = SEMILLA)

rho_proy <- paises_1m(periodo = "proyeccion") |> group_by(Time) |>
  summarise(rho_cdr_lex = stats::cor(CDR, LEx, method = "spearman"),
            r_pearson_cdr_lex = stats::cor(CDR, LEx),
            rho_cdr_medage = stats::cor(CDR, MedianAgePop, method = "spearman"), n = n(), .groups = "drop")
tabla_rho <- panel_cdr |> group_by(Time) |>
  summarise(r_pearson_cdr_lex = stats::cor(CDR, LEx),
            rho_cdr_medage = stats::cor(CDR, MedianAgePop, method = "spearman"), n = n(), .groups = "drop") |>
  mutate(rho_cdr_lex = unname(bs_rho$valor), ci_low = unname(bs_rho$ci_low), ci_high = unname(bs_rho$ci_high)) |>
  bind_rows(rho_proy |> mutate(ci_low = NA_real_, ci_high = NA_real_)) |>
  mutate(periodo_en = etiqueta_periodo(Time)) |>
  select(Time, rho_cdr_lex, ci_low, ci_high, r_pearson_cdr_lex, rho_cdr_medage, n, periodo_en)
write_parquet(tabla_rho, ruta_parquet_q2("rho_cdr_lex"))

rho_iid <- lapply(c(`1950` = 1950, `2023` = 2023), function(a) {
  d <- corte_anio(a, "1m")
  set.seed(SEMILLA)
  bootstrap_bca(d, function(x) stats::cor(x$CDR, x$LEx, method = "spearman"), B = B_Q2, semilla = SEMILLA)
})
r_1950 <- extraer_ic(bs_rho, "1950"); r_2023 <- extraer_ic(bs_rho, "2023")
h13_ok <- r_1950$valor < -0.9 && r_2023$ci_low <= 0 && r_2023$ci_high >= 0
anio_cruce0 <- min(tabla_rho$Time[tabla_rho$Time <= ANIO_FIN_ESTIMACION & tabla_rho$rho_cdr_lex >= 0])
message(sprintf("ρ(CDR, LEx): 1950 = %.3f [%.3f; %.3f]; 2023 = %.3f [%.3f; %.3f]; primer año >= 0: %d",
                r_1950$valor, r_1950$ci_low, r_1950$ci_high, r_2023$valor, r_2023$ci_low, r_2023$ci_high, anio_cruce0))

for (a in c("1950", "2023")) {
  r <- extraer_ic(bs_rho, a)
  anotar(paste0("rho_cdr_lex_", a), r$valor, "rho", "0.00",
         sprintf("Spearman correlation across countries between crude death rate and life expectancy at birth, %s", a),
         sprintf("161 countries ≥ 1 M (2023 population); UN estimates for %s", a), "T8.5",
         c("slide3.build1.footnote", "narration.s3"), ic = r, ic_iid = rho_iid[[a]],
         sens_low = if (a == "2023") tabla_rho$r_pearson_cdr_lex[tabla_rho$Time == 2023] else NA,
         sens_high = if (a == "2023") r$valor else NA,
         sens_note = sprintf("Pearson r = %.3f", tabla_rho$r_pearson_cdr_lex[tabla_rho$Time == as.integer(a)]),
         status = "pre-specified", hypothesis_id = "H13", n = N_PAISES_1M, universe = UNIVERSO_1M,
         say = if (r$ci_low <= 0 && r$ci_high >= 0) "about zero" else
           if (r$valor < -0.9) "almost perfectly negative" else sprintf("%.1f", r$valor))
}
set.seed(SEMILLA)
bs_rho_med <- bootstrap_bloques(corte_anio(2023, "1m"), function(d) stats::cor(d$CDR, d$MedianAgePop, method = "spearman"),
                                B = B_Q2, semilla = SEMILLA)
anotar("rho_cdr_medage_2023", bs_rho_med$valor, "rho", "0.00",
       "Spearman correlation across countries between crude death rate and median age, 2023 (the CDR now tracks age)",
       FILTRO_1M_2023, "T8.5", c("slide3.build1.footnote"), ic = bs_rho_med,
       status = "exploratory", hypothesis_id = "H13", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("yr_rho_cdr_lex_cross0", anio_cruce0, "year", "0",
       "First year 1950–2023 in which the cross-country Spearman correlation of CDR and life expectancy is ≥ 0",
       "161 countries ≥ 1 M; UN estimates 1950–2023", "T8.5", USO_NB, method = "descriptive",
       status = "descriptive", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("rho_cdr_lex_2050", rho_proy$rho_cdr_lex[rho_proy$Time == 2050], "rho", "0.00",
       "Spearman correlation across countries between CDR and life expectancy in 2050 (UN medium projection, a scenario)",
       "161 countries ≥ 1 M; UN medium projection 2050", "T8.5", USO_NB, method = "descriptive",
       status = "descriptive", n = N_PAISES_1M, universe = UNIVERSO_1M,
       sens_note = sprintf("projection, no interval; 2060: %.2f", rho_proy$rho_cdr_lex[rho_proy$Time == 2060]))

p_rho <- ggplot(tabla_rho, aes(Time, rho_cdr_lex)) +
  annotate("rect", xmin = ANIO_INICIO_PROYECCION - 0.5, xmax = ANIO_MAX_VALIDO, ymin = -Inf, ymax = Inf,
           fill = COLOR_PROYECCION_SOMBRA) +
  geom_hline(yintercept = 0, colour = "black", linewidth = 0.4) +
  geom_vline(xintercept = ANIO_FIN_ESTIMACION + 0.5, colour = COLOR_PROYECCION, linetype = "dashed") +
  geom_ribbon(data = \(x) filter(x, Time <= ANIO_FIN_ESTIMACION), aes(ymin = ci_low, ymax = ci_high),
              fill = COLOR_NACIMIENTOS, alpha = 0.22) +
  geom_line(data = \(x) filter(x, Time <= ANIO_FIN_ESTIMACION), colour = COLOR_NACIMIENTOS, linewidth = 1.1) +
  geom_line(data = \(x) filter(x, Time >= ANIO_INICIO_PROYECCION), colour = COLOR_PROYECCION, linewidth = 1,
            linetype = "22") +
  annotate("text", x = 1952, y = r_1950$valor + 0.1, hjust = 0, size = 4.6,
           label = sprintf("1950: %.2f [%.2f; %.2f]", r_1950$valor, r_1950$ci_low, r_1950$ci_high)) +
  annotate("text", x = 2021, y = r_2023$ci_high + 0.12, hjust = 1, size = 4.6,
           label = sprintf("2023: %.2f [%.2f; %.2f]", r_2023$valor, r_2023$ci_low, r_2023$ci_high)) +
  annotate("text", x = 2062, y = -0.9, label = "UN medium projection\n(scenario, no band)", colour = "#777777", size = 4.2) +
  scale_y_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.5)) +
  labs(title = "The crude death rate stopped tracking life expectancy",
       subtitle = "Spearman correlation across countries of CDR and life expectancy at birth, each year; band = 95 % block bootstrap by UN subregion",
       x = NULL, y = "Spearman ρ (CDR, life expectancy)", caption = pie_q2(FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_rho, "q2_03_rho_cdr_lex_by_year")

# =============================================================================
# 5. S2 · Gemelos demográficos por regla (ilustración, familia F3)
#    Qué: búsqueda exhaustiva entre los 12 880 pares de países >= 1 M; regla
#    principal |ΔTFR| <= 0,05 con máxima |Δ crecimiento|; regla 2 |ΔLEx| <= 0,2
#    con máxima |Δ edad mediana|; y otras reglas de los memos (misma CDR, etc.).
#    Por qué: ejemplos elegidos por regla escrita en código, no a mano (ASA A).
# =============================================================================

d_gem <- corte_anio(2023, "1m") |> arrange(ISO3_code) |>
  select(ISO3_code, Location, TFR, PopGrowthRate, LEx, MedianAgePop, CDR, NatChangeRT, CNMR)
v_a <- d_gem |> rename_with(\(x) paste0(x, "_a"))
v_b <- d_gem |> rename_with(\(x) paste0(x, "_b"))
pares <- tidyr::crossing(iso_a = d_gem$ISO3_code, iso_b = d_gem$ISO3_code) |>
  filter(iso_a < iso_b) |>
  left_join(v_a, by = c("iso_a" = "ISO3_code_a")) |>
  left_join(v_b, by = c("iso_b" = "ISO3_code_b"))
N_PARES <- nrow(pares)
stopifnot(N_PARES == choose(N_PAISES_1M, 2))

#' Aplica una regla de gemelos: |Δ var_igual| <= tol y orden por |Δ var_dif|.
gemelos_regla <- function(pares, var_igual, tol, var_dif, regla, regla_en, top = 5, condicion = NULL) {
  ia <- paste0(var_igual, "_a"); ib <- paste0(var_igual, "_b")
  da <- paste0(var_dif, "_a"); db <- paste0(var_dif, "_b")
  x <- pares[abs(pares[[ia]] - pares[[ib]]) <= tol + 1e-9, , drop = FALSE]
  if (!is.null(condicion)) x <- x[condicion(x), , drop = FALSE]
  x$dif_abs <- abs(x[[da]] - x[[db]])
  x <- x[order(-x$dif_abs, x$iso_a, x$iso_b), , drop = FALSE]
  x <- utils::head(x, top)
  tibble(regla = regla, regla_en = regla_en, rank = seq_len(nrow(x)), iso_a = x$iso_a, iso_b = x$iso_b,
         pais_a = x$Location_a, pais_b = x$Location_b, var_igual = var_igual, igual_a = x[[ia]],
         igual_b = x[[ib]], var_dif = var_dif, dif_a = x[[da]], dif_b = x[[db]], dif_abs = x$dif_abs)
}
signo_opuesto_nat <- function(x) sign(x$NatChangeRT_a) != sign(x$NatChangeRT_b)
tabla_gemelos <- bind_rows(
  gemelos_regla(pares, "TFR", 0.05, "PopGrowthRate", "R1",
                "Same fertility (|ΔTFR| ≤ 0.05), largest gap in growth rate"),
  gemelos_regla(pares, "LEx", 0.2, "MedianAgePop", "R2",
                "Same life expectancy (|ΔLEx| ≤ 0.2), largest gap in median age"),
  gemelos_regla(pares, "CDR", 0.1, "LEx", "R3",
                "Same crude death rate (|ΔCDR| ≤ 0.1), largest gap in life expectancy"),
  gemelos_regla(pares, "TFR", 0.03, "NatChangeRT", "R4",
                "Same fertility (|ΔTFR| ≤ 0.03), opposite sign of natural change, the grower has net emigration",
                condicion = function(x) signo_opuesto_nat(x) &
                  ((x$NatChangeRT_a > 0 & x$CNMR_a < 0 & x$PopGrowthRate_a > 0) |
                     (x$NatChangeRT_b > 0 & x$CNMR_b < 0 & x$PopGrowthRate_b > 0))),
  gemelos_regla(pares, "MedianAgePop", 0.3, "TFR", "R5",
                "Same median age (|Δ| ≤ 0.3 years), largest gap in fertility"),
  gemelos_regla(pares, "PopGrowthRate", 0.02, "NatChangeRT", "R6",
                "Same growth rate (|Δ| ≤ 0.02 pp), opposite sign of natural change",
                condicion = signo_opuesto_nat)
)
print(tabla_gemelos |> select(regla, rank, iso_a, iso_b, igual_a, igual_b, dif_a, dif_b) |>
        mutate(across(where(is.numeric), \(x) round(x, 2))), n = 40)
write_parquet(tabla_gemelos, ruta_parquet_q2("gemelos"))

t1 <- tabla_gemelos |> filter(regla == "R1", rank == 1)
if (!setequal(c(t1$iso_a, t1$iso_b), c("ARE", "BLR"))) {
  warning("La regla R1 ya no da Emiratos–Bielorrusia: revisar las claves twin_*_are/blr y el guion.", call. = FALSE)
}
valor_pais <- function(iso, var) d_gem[[var]][d_gem$ISO3_code == iso]
anotar("n_pairs_twins", N_PARES, "pairs", "#,##0",
       "Number of country pairs searched exhaustively for the twin rules", FILTRO_1M_2023, "T8.6",
       c("slide3.build2"), method = "none_census", status = "descriptive", n = N_PAISES_1M, universe = UNIVERSO_1M)
tw_out <- tabla_gemelos |> filter(regla == "R1") |>
  transmute(rank, iso_a, iso_b, country_a = pais_a, country_b = pais_b, tfr_a = igual_a, tfr_b = igual_b,
            growth_a = dif_a, growth_b = dif_b, growth_gap = dif_abs)
anotar("twins", as.data.frame(tw_out), NA, "text",
       "Top-5 twin pairs by rule: |ΔTFR| ≤ 0.05 and largest |Δ population growth rate|, 2023",
       FILTRO_1M_2023, "T8.6", c("slide3.build2", "fig08"), method = "descriptive", status = "exploratory",
       sens_note = sprintf("chosen by rule from %s pairs (≥ 1 M); illustration, no inference (family F3)",
                           format(N_PARES, big.mark = ",")),
       n = N_PAISES_1M, universe = UNIVERSO_1M)
for (cl in list(c("twin_tfr_are", "ARE", "TFR", "Total fertility rate, United Arab Emirates, 2023", "children per woman", "0.00"),
                c("twin_tfr_blr", "BLR", "TFR", "Total fertility rate, Belarus, 2023", "children per woman", "0.00"),
                c("twin_growth_are", "ARE", "PopGrowthRate", "Population growth rate, United Arab Emirates, 2023", "%", "+0.00"),
                c("twin_growth_blr", "BLR", "PopGrowthRate", "Population growth rate, Belarus, 2023", "%", "+0.00"))) {
  v <- valor_pais(cl[2], cl[3])
  anotar(cl[1], v, cl[5], cl[6], paste0(cl[4], " (top pair of the twin rule |ΔTFR| ≤ 0.05)"),
         sprintf("%s; UN estimates 2023", nombre_pais(cl[2])), "T8.6", c("slide3.build2", "narration.s3"),
         method = "descriptive", status = "descriptive", n = 1, universe = UNIVERSO_1M,
         say = if (cl[1] == "twin_growth_are") decir_entero(v) else NA)
}
tw2 <- tabla_gemelos |> filter(regla == "R2") |>
  transmute(rank, iso_a, iso_b, country_a = pais_a, country_b = pais_b, lex_a = igual_a, lex_b = igual_b,
            medage_a = dif_a, medage_b = dif_b, medage_gap = dif_abs)
anotar("twins_lex_medage", as.data.frame(tw2), NA, "text",
       "Top-5 twin pairs by rule: |Δ life expectancy| ≤ 0.2 years and largest |Δ median age|, 2023",
       FILTRO_1M_2023, "T8.6", USO_NB, method = "descriptive", status = "exploratory",
       sens_note = sprintf("chosen by rule from %s pairs (≥ 1 M); illustration (F3)", format(N_PARES, big.mark = ",")),
       n = N_PAISES_1M, universe = UNIVERSO_1M)
otras <- tabla_gemelos |> filter(regla %in% c("R4", "R5", "R6"), rank == 1) |>
  transmute(rule = regla_en, iso_a, iso_b, same_a = igual_a, same_b = igual_b, differ_var = var_dif,
            differ_a = dif_a, differ_b = dif_b)
anotar("twins_other_rules", as.data.frame(otras), NA, "text",
       "Top pair of three further twin rules from the demography memo (same fertility / median age / growth)",
       FILTRO_1M_2023, "T8.6", USO_NB, method = "descriptive", status = "exploratory",
       sens_note = "illustration only (F3); full top-5 in data/processed/resultados_q2_gemelos.parquet",
       n = N_PAISES_1M, universe = UNIVERSO_1M)

# Par de la CDR (pie del scorecard) por regla R3.
t3 <- tabla_gemelos |> filter(regla == "R3", rank == 1)
if (!setequal(c(t3$iso_a, t3$iso_b), c("PRT", "TCD"))) {
  warning("La regla R3 ya no da Portugal–Chad: revisar las claves cdr_prt / cdr_tcd.", call. = FALSE)
}
anotar("cdr_prt", valor_pais("PRT", "CDR"), "per 1,000", "0.0",
       "Crude death rate, Portugal, 2023 (top pair of rule |ΔCDR| ≤ 0.1 with largest |Δ life expectancy|)",
       "Portugal; UN estimates 2023", "T8.5", c("slide3.build1.footnote"), method = "descriptive",
       status = "descriptive", n = 1, universe = UNIVERSO_1M,
       sens_note = sprintf("life expectancy %.1f years; median age %.1f", valor_pais("PRT", "LEx"), valor_pais("PRT", "MedianAgePop")))
anotar("cdr_tcd", valor_pais("TCD", "CDR"), "per 1,000", "0.0",
       "Crude death rate, Chad, 2023 (top pair of rule |ΔCDR| ≤ 0.1 with largest |Δ life expectancy|)",
       "Chad; UN estimates 2023", "T8.5", c("slide3.build1.footnote"), method = "descriptive",
       status = "descriptive", n = 1, universe = UNIVERSO_1M,
       sens_note = sprintf("life expectancy %.1f years; median age %.1f", valor_pais("TCD", "LEx"), valor_pais("TCD", "MedianAgePop")))
anotar("lex_gap_prt_tcd", valor_pais("PRT", "LEx") - valor_pais("TCD", "LEx"), "years", "0",
       "Gap in life expectancy at birth between Portugal and Chad, 2023 (same crude death rate)",
       "Portugal and Chad; UN estimates 2023", "T8.5", c("slide3.build1.footnote"), method = "descriptive",
       status = "descriptive", n = 2, universe = UNIVERSO_1M,
       sens_note = sprintf("chosen by rule from %s pairs", format(N_PARES, big.mark = ",")))

# Figura de revisión: gemelos R1 y R2 (pesas).
p_gem <- function(regla_id, xlab, titulo, fmt_igual) {
  x <- tabla_gemelos |> filter(regla == regla_id) |>
    mutate(par = sprintf("%s – %s\n(%s %s vs %s)", iso_a, iso_b, sub("_.*", "", var_igual),
                         sprintf(fmt_igual, igual_a), sprintf(fmt_igual, igual_b)),
           par = factor(par, levels = rev(par)))
  ggplot(x, aes(y = par)) +
    geom_segment(aes(x = dif_a, xend = dif_b, yend = par), colour = COLOR_GRIS_CLARO, linewidth = 2) +
    geom_point(aes(x = dif_a), colour = COLOR_NACIMIENTOS, size = 4) +
    geom_point(aes(x = dif_b), colour = COLOR_DEFUNCIONES, size = 4) +
    geom_text(aes(x = dif_a, label = iso_a), vjust = -1, size = 3.8) +
    geom_text(aes(x = dif_b, label = iso_b), vjust = -1, size = 3.8) +
    labs(title = titulo, x = xlab, y = NULL) + tema_q2()
}
p_tw <- (p_gem("R1", "Population growth rate 2023 (%)", "Same fertility, opposite growth", "%.2f") +
           geom_vline(xintercept = 0, linewidth = 0.3)) |
  p_gem("R2", "Median age 2023 (years)", "Same life expectancy, different age", "%.1f")
p_tw <- p_tw + plot_annotation(
  title = sprintf("Demographic twins chosen by rule from %s pairs (161 countries ≥ 1 M, 2023)", format(N_PARES, big.mark = ",")),
  subtitle = "Left: |ΔTFR| ≤ 0.05 with the largest gap in growth. Right: |Δ life expectancy| ≤ 0.2 years with the largest gap in median age.",
  caption = pie_q2("Illustration only (no inference).", FUENTE_ESTANDAR), theme = tema_q2())
guardar_q2(p_tw, "q2_04_twins_by_rule")

# =============================================================================
# 6. R1 · Prueba de parecidos (look-alikes) — demostración central de P8 (H20)
#    Qué: para cada país, sus 5 vecinos más cercanos en los 12 indicadores
#    estandarizados ("look-alikes reales") y qué fracción de ellos recupera un
#    resumen (TFR sola, LEx, edad mediana, PC1, PC1+PC2...). Azar = 5/160.
#    Por qué: convierte los gemelos anecdóticos en una métrica para todos los
#    países; el IC por bloques rehace TODO (estandarizar, PCA, vecinos) en cada
#    réplica, sin contar como vecinas las copias del mismo país.
# =============================================================================

#' Vecinos más cercanos (distancia euclídea) de cada fila; excluye las copias del
#' propio país (réplicas bootstrap) y desempata alfabéticamente por ISO3.
vecinos_k <- function(M, iso, k = K_LOOK) {
  D <- as.matrix(stats::dist(M))
  out <- vector("list", nrow(D))
  for (i in seq_len(nrow(D))) {
    cand <- iso[order(D[i, ], iso)]
    cand <- cand[cand != iso[i]]
    out[[i]] <- cand[!duplicated(cand)][seq_len(k)]
  }
  out
}
solap <- function(ref, res, k = K_LOOK) vapply(seq_along(ref), function(i) sum(ref[[i]] %in% res[[i]]) / k, numeric(1))

#' Espacios de resumen (matrices) a partir de Z estandarizada y su PCA.
espacios_resumen <- function(Z, pc, quienes = c("TFR", "LEx", "MedianAgePop", "PC1", "PC12", "PC123", "TFR_CNMR", "TFR_CDR")) {
  todos <- list(TFR = Z[, "TFR", drop = FALSE], LEx = Z[, "LEx", drop = FALSE],
                MedianAgePop = Z[, "MedianAgePop", drop = FALSE],
                PC1 = pc$x[, 1, drop = FALSE], PC12 = pc$x[, 1:2, drop = FALSE], PC123 = pc$x[, 1:3, drop = FALSE],
                TFR_CNMR = Z[, c("TFR", "CNMR"), drop = FALSE], TFR_CDR = Z[, c("TFR", "CDR"), drop = FALSE])
  todos[intersect(quienes, names(todos))]
}
#' Look-alikes para un conjunto de datos ya preparado (CNMR tratada, logDens).
calc_lookalikes <- function(d, vars = VARS_12, k = K_LOOK, quienes = c("TFR", "LEx", "MedianAgePop", "PC1", "PC12", "PC123", "TFR_CNMR", "TFR_CDR"),
                            detalle = FALSE) {
  Z <- scale(as.matrix(d[, vars]))
  pc <- stats::prcomp(Z)
  iso <- d$ISO3_code
  ref <- vecinos_k(Z, iso, k)
  esp <- espacios_resumen(Z, pc, quienes)
  vec <- lapply(esp, vecinos_k, iso = iso, k = k)
  por_pais <- lapply(vec, solap, ref = ref, k = k)
  medias <- vapply(por_pais, mean, numeric(1))
  if (detalle) list(medias = medias, ref = ref, vec = vec, por_pais = por_pais, iso = iso) else medias
}

# 6.1 Versión simple: caso base (2023, 12 variables, k = 5).
la_base <- calc_lookalikes(d23, detalle = TRUE)
azar_pct <- 100 * K_LOOK / (N_PAISES_1M - 1)
print(round(100 * la_base$medias, 1)); message(sprintf("Azar: %.2f %%", azar_pct))

# 6.2 Incertidumbre. DECISIÓN DOCUMENTADA: los vecinos se calculan UNA vez con
#     los 161 países y se remuestrea (por bloques de subregión) el solapamiento
#     de cada país; el IC describe "qué países promediamos". Rehacer los vecinos
#     dentro de cada réplica sesga hacia arriba: el bootstrap por bloques deja ~63 %
#     de países distintos, el azar sube de 3 % a ~5 % y el IC de la TFR quedaba
#     [14; 26], sin contener el valor 13 (prueba de la primera corrida, ver
#     docs/resultados_q2.md). La sensibilidad a la composición del conjunto se
#     mide aparte, rehaciendo todo sin una subregión cada vez (20 corridas).
d_solap <- d23 |> select(ISO3_code, subregion) |>
  mutate(tfr = la_base$por_pais$TFR, pc1 = la_base$por_pais$PC1, pc12 = la_base$por_pais$PC12)
stopifnot(identical(d_solap$ISO3_code, la_base$iso))
stat_knn <- function(d) 100 * c(tfr = mean(d$tfr), pc1 = mean(d$pc1), pc12 = mean(d$pc12), dif = mean(d$pc12 - d$tfr))
set.seed(SEMILLA)
bs_knn <- bootstrap_bloques(d_solap, stat_knn, B = B_Q2, semilla = SEMILLA)
set.seed(SEMILLA)
iid_knn <- bootstrap_bloques(d_solap, stat_knn, bloque = NULL, B = B_Q2, semilla = SEMILLA)
knn_loso <- map_dfr(sort(unique(d23$subregion)), function(s) {
  x <- d23 |> filter(subregion != s)
  x$CNMR <- wins3(x$CNMR_raw)
  m <- calc_lookalikes(x, quienes = c("TFR", "PC1", "PC12"))
  tibble(subregion_fuera = s, n = nrow(x), tfr = 100 * m[["TFR"]], pc1 = 100 * m[["PC1"]], pc12 = 100 * m[["PC12"]])
})
nota_loso <- function(col) sprintf("leaving one UN subregion out (all recomputed): %.1f–%.1f",
                                   min(knn_loso[[col]]), max(knn_loso[[col]]))
write_parquet(knn_loso, ruta_parquet_q2("knn_loso"))

# 6.3 Sensibilidades: k = 10; 1990; 2050 (proyección); 8 variables; 237; sin Golfo; asinh.
casos_knn <- list(
  list(caso = "Base (2023, 12 indicators, k = 5)", anio = 2023, conjunto = "12", k = 5, d = d23, vars = VARS_12),
  list(caso = "k = 10", anio = 2023, conjunto = "12", k = 10, d = d23, vars = VARS_12),
  list(caso = "1990", anio = 1990, conjunto = "12", k = 5, d = preparar_corte(1990), vars = VARS_12),
  list(caso = "2050 (UN projection)", anio = 2050, conjunto = "12", k = 5, d = preparar_corte(2050), vars = VARS_12),
  list(caso = "8 indicators (config)", anio = 2023, conjunto = "8", k = 5, d = d23, vars = VARS_8),
  list(caso = "All 237 countries and areas", anio = 2023, conjunto = "12", k = 5, d = preparar_corte(2023, "completa"), vars = VARS_12),
  list(caso = "Without the 6 Gulf states", anio = 2023, conjunto = "12", k = 5,
       d = { x <- d23 |> filter(!es_golfo(ISO3_code)); x$CNMR <- wins3(x$CNMR_raw); x }, vars = VARS_12),
  list(caso = "asinh(CNMR/5) instead of winsorizing", anio = 2023, conjunto = "12", k = 5,
       d = preparar_corte(2023, tratamiento_cnmr = "asinh"), vars = VARS_12)
)
tabla_knn <- map_dfr(casos_knn, function(cs) {
  quienes <- c("TFR", "LEx", "MedianAgePop", "PC1", "PC12", "PC123", "TFR_CNMR", "TFR_CDR")
  if (!all(c("CNMR", "CDR") %in% cs$vars)) quienes <- setdiff(quienes, c("TFR_CNMR", "TFR_CDR"))
  m <- calc_lookalikes(cs$d, vars = cs$vars, k = cs$k, quienes = quienes)
  tibble(caso = cs$caso, anio = cs$anio, periodo = etiqueta_periodo(cs$anio), conjunto = cs$conjunto, k = cs$k,
         n = nrow(cs$d), resumen = names(m), solapamiento_pct = 100 * unname(m),
         azar_pct = 100 * cs$k / (nrow(cs$d) - 1))
})
ci_base <- tibble(resumen = c("TFR", "PC1", "PC12"),
                  ci_low = unname(bs_knn$ci_low[c("tfr", "pc1", "pc12")]),
                  ci_high = unname(bs_knn$ci_high[c("tfr", "pc1", "pc12")]))
tabla_knn <- tabla_knn |>
  left_join(ci_base |> mutate(caso = casos_knn[[1]]$caso), by = c("caso", "resumen"))
print(tabla_knn |> select(caso, resumen, solapamiento_pct, azar_pct) |>
        pivot_wider(names_from = resumen, values_from = solapamiento_pct) |>
        mutate(across(where(is.numeric), \(x) round(x, 1))), width = 200)
write_parquet(tabla_knn, ruta_parquet_q2("knn_resumen"))

sens_knn <- function(res) {
  x <- tabla_knn |> filter(resumen == res, caso != casos_knn[[1]]$caso)
  list(lo = min(x$solapamiento_pct), hi = max(x$solapamiento_pct),
       nota = paste(sprintf("%s %.1f", x$caso, x$solapamiento_pct), collapse = " · "))
}
knn_tfr_v <- 100 * la_base$medias[["TFR"]]; knn_pc12_v <- 100 * la_base$medias[["PC12"]]
h20_ok <- knn_tfr_v < 25 && knn_pc12_v > 40
for (cl in list(list("knn_tfr", "tfr", "TFR", "fertility alone", c("slide3.build2", "fig08", "narration.s3"), decir_uno_de(knn_tfr_v)),
                list("knn_pc1", "pc1", "PC1", "the first principal component (the best single number)", c("slide3.build2", "fig08"), NA),
                list("knn_pc12", "pc12", "PC12", "the first two principal components", c("slide3.build2", "fig08"), NA))) {
  s <- sens_knn(cl[[3]])
  anotar(cl[[1]], 100 * la_base$medias[[cl[[3]]]], "%", "0",
         sprintf(paste0("Average share of each country's 5 nearest look-alikes in 12 standardized indicators ",
                        "(2023) that are also among its 5 nearest by %s; interval: block bootstrap of the ",
                        "country-level shares (neighbours computed once on all 161)"), cl[[4]]),
         FILTRO_1M_2023, "T9.1", cl[[5]], ic = extraer_ic(bs_knn, cl[[2]]), ic_iid = extraer_ic(iid_knn, cl[[2]]),
         sens_low = min(s$lo, knn_loso[[cl[[2]]]]), sens_high = max(s$hi, knn_loso[[cl[[2]]]]),
         sens_note = paste(s$nota, "·", nota_loso(cl[[2]])),
         status = "exploratory", hypothesis_id = "H20", n = N_PAISES_1M, universe = UNIVERSO_1M, say = cl[[6]])
}
anotar("knn_pc12_minus_tfr", bs_knn$valor[["dif"]], "percentage points", "0",
       "Difference in look-alikes recovered: two principal components minus fertility alone",
       FILTRO_1M_2023, "T9.1", USO_NB, ic = extraer_ic(bs_knn, "dif"), ic_iid = extraer_ic(iid_knn, "dif"),
       status = "exploratory", hypothesis_id = "H20", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("knn_chance", azar_pct, "%", "0",
       "Share of look-alikes expected by chance: k / (n − 1) = 5 / 160",
       FILTRO_1M_2023, "T9.1", c("slide3.build2", "fig08"), method = "descriptive", status = "exploratory",
       hypothesis_id = "H20", n = N_PAISES_1M, universe = UNIVERSO_1M)
for (cl in list(c("knn_lex", "LEx", "life expectancy alone"), c("knn_medage", "MedianAgePop", "median age alone"),
                c("knn_tfr_cnmr", "TFR_CNMR", "fertility + net migration"), c("knn_tfr_cdr", "TFR_CDR", "fertility + crude death rate"),
                c("knn_pc123", "PC123", "the first three principal components"))) {
  s <- sens_knn(cl[2])
  anotar(cl[1], 100 * la_base$medias[[cl[2]]], "%", "0",
         sprintf("Average share of each country's 5 real look-alikes (12 indicators, 2023) also found by %s", cl[3]),
         FILTRO_1M_2023, "T9.1", USO_NB, method = "sensitivity", sens_low = s$lo, sens_high = s$hi,
         sens_note = s$nota, status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)
}

# 6.4 Perfil recuperado: R² medio de los 12 indicadores sobre un resumen
#     (la propia variable cuenta como 1; para PC1 coincide con su % de varianza).
Z23 <- as.data.frame(scale(as.matrix(d23[, VARS_12])))
pc23_tmp <- stats::prcomp(Z23)
Z23$PC1 <- pc23_tmp$x[, 1]; Z23$PC2 <- pc23_tmp$x[, 2]; Z23$PC3 <- pc23_tmp$x[, 3]
recupera <- function(Zdf, pred, vars = VARS_12, spline = FALSE) {
  mean(vapply(vars, function(v) {
    if (v %in% pred) return(1)
    f <- if (spline) stats::reformulate(sprintf("ns(%s, df = 3)", pred), v) else stats::reformulate(pred, v)
    summary(stats::lm(f, data = Zdf))$r.squared
  }, numeric(1)))
}
resumenes_rec <- list(TFR = "TFR", LEx = "LEx", MedianAgePop = "MedianAgePop", PC1 = "PC1",
                      `TFR + CNMR` = c("TFR", "CNMR"), `TFR + CDR` = c("TFR", "CDR"), `PC1 + PC2` = c("PC1", "PC2"),
                      `PC1–PC3` = c("PC1", "PC2", "PC3"))
tabla_rec <- imap_dfr(resumenes_rec, function(p, nm) {
  tibble(resumen = nm, perfil_recuperado = recupera(Z23, p),
         perfil_recuperado_spline = if (length(p) == 1) recupera(Z23, p, spline = TRUE) else NA_real_)
})
print(tabla_rec |> mutate(across(where(is.numeric), \(x) round(x, 3))))
write_parquet(tabla_rec, ruta_parquet_q2("recupera"))
stat_rec <- function(d) {
  d$CNMR <- wins3(d$CNMR_raw)
  Z <- as.data.frame(scale(as.matrix(d[, VARS_12])))
  p <- stats::prcomp(Z); Z$PC1 <- p$x[, 1]; Z$PC2 <- p$x[, 2]
  c(tfr = recupera(Z, "TFR"), pc1 = recupera(Z, "PC1"), pc12 = recupera(Z, c("PC1", "PC2")))
}
set.seed(SEMILLA)
bs_rec <- bootstrap_bloques(d23, stat_rec, B = B_Q2, semilla = SEMILLA)
for (cl in list(c("recov_tfr", "tfr", "TFR", "fertility alone"), c("recov_pc1", "pc1", "PC1", "the first principal component"),
                c("recov_pc12", "pc12", "PC1 + PC2", "the first two principal components"))) {
  rr <- tabla_rec |> filter(resumen == cl[3])
  anotar(cl[1], rr$perfil_recuperado, "share", "0.00",
         sprintf(paste0("Recovered profile: mean R² of the 12 standardized indicators (2023) regressed on %s ",
                        "(the indicator itself counts as 1)"), cl[4]),
         FILTRO_1M_2023, "T9.2", c("slide3.build2.note", "notebook.q2"), ic = extraer_ic(bs_rec, cl[2]),
         sens_note = if (!is.na(rr$perfil_recuperado_spline)) sprintf("natural spline 3 df: %.3f", rr$perfil_recuperado_spline) else NA,
         status = "exploratory", hypothesis_id = "H20", n = N_PAISES_1M, universe = UNIVERSO_1M,
         say = if (cl[1] == "recov_tfr") decir_fraccion(rr$perfil_recuperado) else NA)
}

# 6.5 Tabla completa de look-alikes (todos los países: Colombia es ilustración, no selección).
lista_txt <- function(v) vapply(v, paste, character(1), collapse = ",")
lista_nombres <- function(v) vapply(v, function(x) paste(nombre_pais(x), collapse = "; "), character(1))
tabla_look <- d23 |>
  select(ISO3_code, Location, region_sdg, ingreso) |>
  mutate(vecinos_12 = lista_txt(la_base$ref), vecinos_12_nombres = lista_nombres(la_base$ref),
         vecinos_tfr = lista_txt(la_base$vec$TFR), vecinos_tfr_nombres = lista_nombres(la_base$vec$TFR),
         vecinos_pc12 = lista_txt(la_base$vec$PC12), vecinos_pc1 = lista_txt(la_base$vec$PC1),
         solap_tfr = as.integer(round(K_LOOK * la_base$por_pais$TFR)),
         solap_pc1 = as.integer(round(K_LOOK * la_base$por_pais$PC1)),
         solap_pc12 = as.integer(round(K_LOOK * la_base$por_pais$PC12)),
         ingreso = as.character(ingreso))
write_parquet(tabla_look, ruta_parquet_q2("lookalikes"))
readr::write_csv(tabla_look, RUTA_LOOKALIKES_CSV)

vecinos_de <- function(iso, espacio) {
  i <- which(la_base$iso == iso)
  if (espacio == "12") la_base$ref[[i]] else la_base$vec[[espacio]][[i]]
}
col_tfr <- vecinos_de("COL", "TFR"); col_12 <- vecinos_de("COL", "12"); col_pc12 <- vecinos_de("COL", "PC12")
are_tfr <- vecinos_de("ARE", "TFR"); are_12 <- vecinos_de("ARE", "12")
message("Colombia — por TFR: ", paste(col_tfr, collapse = ", "), " | por 12 indicadores: ", paste(col_12, collapse = ", "),
        " | por PC1+PC2: ", paste(col_pc12, collapse = ", "))
message("EAU — por TFR: ", paste(are_tfr, collapse = ", "), " | por 12 indicadores: ", paste(are_12, collapse = ", "))
NOTA_POSICIONALIDAD <- "Colombia is the team's home country, shown as an illustration; the full table for all 161 countries is in figures/lookalikes_todos.csv"
for (cl in list(list("lookalikes_col_tfr", col_tfr, "Colombia's 5 nearest look-alikes by total fertility rate alone, 2023", c("slide3.build2", "fig08", "narration.s3")),
                list("lookalikes_col_12", col_12, "Colombia's 5 nearest look-alikes in 12 standardized indicators, 2023", c("slide3.build2", "fig08", "narration.s3")),
                list("lookalikes_col_pc12", col_pc12, "Colombia's 5 nearest look-alikes on the first two principal components, 2023", USO_NB),
                list("lookalikes_are_tfr", are_tfr, "United Arab Emirates' 5 nearest look-alikes by total fertility rate alone, 2023", USO_NB),
                list("lookalikes_are_12", are_12, "United Arab Emirates' 5 nearest look-alikes in 12 standardized indicators, 2023", USO_NB))) {
  anotar(cl[[1]], nombre_pais(cl[[2]]), NA, "text", paste(cl[[3]], "(ordered from most to least similar; ties broken by ISO3)"),
         FILTRO_1M_2023, "T9.1", cl[[4]], method = "descriptive", status = "exploratory",
         sens_note = paste("ISO3:", paste(cl[[2]], collapse = ", "), "·", NOTA_POSICIONALIDAD),
         n = N_PAISES_1M, universe = UNIVERSO_1M, say = unir_y(nombre_corto(cl[[2]][1:3])))
  anotar(paste0(cl[[1]], "_iso"), I(cl[[2]]), NA, "text", paste(cl[[3]], "— ISO3 codes (for flags)"),
         FILTRO_1M_2023, "T9.1", cl[[4]], method = "descriptive", status = "exploratory",
         n = N_PAISES_1M, universe = UNIVERSO_1M)
}
n_cero_tfr <- sum(tabla_look$solap_tfr == 0)
anotar("n_knn_tfr_zero", n_cero_tfr, "countries", "0",
       "Countries for which fertility alone finds none of their 5 real look-alikes (12 indicators, 2023)",
       FILTRO_1M_2023, "T9.1", USO_NB, method = "wilson",
       ci_low = ic_wilson(n_cero_tfr, N_PAISES_1M)$conteo_low, ci_high = ic_wilson(n_cero_tfr, N_PAISES_1M)$conteo_high,
       sens_note = sprintf("distribution of look-alikes found by TFR (0–5): %s · by PC1 + PC2, countries with none: %d",
                           paste(sprintf("%s: %d", names(table(tabla_look$solap_tfr)), as.integer(table(tabla_look$solap_tfr))), collapse = ", "),
                           sum(tabla_look$solap_pc12 == 0)),
       status = "exploratory", hypothesis_id = "H20", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("lookalikes_col_overlap", sum(col_tfr %in% col_12), "countries", "0",
       "How many of Colombia's 5 real look-alikes (12 indicators) are also among its 5 nearest by fertility alone",
       FILTRO_1M_2023, "T9.1", USO_NB, method = "descriptive", status = "exploratory",
       n = N_PAISES_1M, universe = UNIVERSO_1M)

# =============================================================================
# 7. R2 · PCA con el conjunto FIJO de 12 variables + análisis paralelo (H7, H7a)
#    Qué: prcomp sobre las 12 variables estandarizadas (161 países, 2023); cuántas
#    direcciones superan al ruido (Horn, 1000 permutaciones por columna); cuánto
#    se parece la TFR a cada eje; sensibilidades.
#    Por qué: P8 se responde con la ESTRUCTURA ("dos dimensiones reales"), no con
#    un porcentaje, porque el % del PC1 depende de qué variables entren.
# =============================================================================

#' PCA orientado: PC1 con carga de LEx > 0; PC2 con carga de CNMR > 0 (si está).
pca_orientado <- function(d, vars) {
  Z <- scale(as.matrix(d[, vars]))
  pc <- stats::prcomp(Z)
  if (pc$rotation["LEx", 1] < 0) { pc$rotation[, 1] <- -pc$rotation[, 1]; pc$x[, 1] <- -pc$x[, 1] }
  if ("CNMR" %in% vars && pc$rotation["CNMR", 2] < 0) { pc$rotation[, 2] <- -pc$rotation[, 2]; pc$x[, 2] <- -pc$x[, 2] }
  pc$Z <- Z
  pc
}
#' Análisis paralelo de Horn: autovalores observados vs percentiles de datos con
#' columnas permutadas (sin estructura). La semilla se fija dentro, justo antes.
analisis_paralelo <- function(Z, B = B_PARALELO, semilla = SEMILLA, q = 0.95) {
  set.seed(semilla)
  nulo <- replicate(B, eigen(stats::cor(apply(Z, 2, sample)), symmetric = TRUE, only.values = TRUE)$values)
  obs <- eigen(stats::cor(Z), symmetric = TRUE, only.values = TRUE)$values
  p95 <- apply(nulo, 1, stats::quantile, q); p50 <- apply(nulo, 1, stats::median)
  list(obs = obs, p95 = p95, p50 = p50, n_dims = sum(cumprod(obs > p95)))
}
resumen_pca <- function(d, vars, caso, tipo, anio = 2023) {
  pc <- pca_orientado(d, vars)
  ap <- analisis_paralelo(pc$Z)
  ve <- pc$sdev^2 / sum(pc$sdev^2)
  r2c <- if ("CNMR" %in% vars) stats::cor(d$TFR, pc$x[, 2]) else NA_real_
  tibble(caso = caso, tipo = tipo, periodo = etiqueta_periodo(anio), n = nrow(d), n_vars = length(vars),
         pc1_pct = 100 * ve[1], pc2_pct = 100 * ve[2], acum2_pct = 100 * sum(ve[1:2]),
         n_dims_paralelo = ap$n_dims, r_tfr_pc1 = stats::cor(d$TFR, pc$x[, 1]), r_tfr_pc2 = r2c)
}

# 7.1 Versión simple: PCA base y análisis paralelo.
pc23 <- pca_orientado(d23, VARS_12)
ve23 <- pc23$sdev^2 / sum(pc23$sdev^2)
ap23 <- analisis_paralelo(pc23$Z)
n_pcs_70 <- which(cumsum(ve23) >= 0.70)[1]
r_tfr_pc1_v <- stats::cor(d23$TFR, pc23$x[, 1]); r_tfr_pc2_v <- stats::cor(d23$TFR, pc23$x[, 2])
message(sprintf("PCA 2023: PC1 %.1f %%, PC2 %.1f %%, 2 PCs %.1f %%; autovalores %s; p95 nulo %s; dimensiones %d; r(TFR,PC1) %.3f; r(TFR,PC2) %.3f",
                100 * ve23[1], 100 * ve23[2], 100 * sum(ve23[1:2]), paste(round(ap23$obs[1:4], 2), collapse = "/"),
                paste(round(ap23$p95[1:4], 2), collapse = "/"), ap23$n_dims, r_tfr_pc1_v, r_tfr_pc2_v))
print(round(pc23$rotation[, 1:4], 2))

# 7.2 IC por bloques (rehace winsorización, z y PCA; alinea ejes con los originales).
rot0 <- pc23$rotation
stat_pca <- function(d) {
  d$CNMR <- wins3(d$CNMR_raw)
  Z <- scale(as.matrix(d[, VARS_12]))
  p <- stats::prcomp(Z)
  ve <- p$sdev^2 / sum(p$sdev^2)
  s1 <- sign(sum(p$rotation[, 1] * rot0[, 1]))
  cong <- abs(crossprod(p$rotation[, 2:3], rot0[, 2]))          # PC2 original ↔ PC2 o PC3 de la réplica
  j <- c(2, 3)[which.max(cong)]
  s2 <- sign(sum(p$rotation[, j] * rot0[, 2]))
  c(pc1 = 100 * ve[1], pc2 = 100 * ve[2], acum2 = 100 * sum(ve[1:2]),
    r_tfr_pc1 = stats::cor(d$TFR, s1 * p$x[, 1]), r_tfr_pc2 = stats::cor(d$TFR, s2 * p$x[, j]),
    n_pcs70 = which(cumsum(ve) >= 0.70)[1])
}
set.seed(SEMILLA)
bs_pca <- bootstrap_bloques(d23, stat_pca, B = B_Q2, semilla = SEMILLA)
set.seed(SEMILLA)
iid_pca <- bootstrap_bloques(d23, stat_pca, bloque = NULL, B = B_IID_PCA, semilla = SEMILLA)
reps_n70 <- table(bs_pca$replicas[, "n_pcs70"])

# 7.3 Sensibilidades: conjuntos de variables, muestras y años.
d23_sin_golfo <- d23 |> filter(!es_golfo(ISO3_code)) |> mutate(CNMR = wins3(CNMR_raw))
tabla_pca_sens <- bind_rows(
  imap_dfr(CONJUNTOS_PCA, function(vs, nm) resumen_pca(d23, vs, nm, "variable set")),
  resumen_pca(d23_sin_golfo, VARS_12, "Without the 6 Gulf states", "sample"),
  resumen_pca(preparar_corte(2023, "completa"), VARS_12, "All 237 countries and areas", "sample"),
  resumen_pca(preparar_corte(2023, tratamiento_cnmr = "asinh"), VARS_12, "asinh(CNMR/5)", "sample"),
  resumen_pca(preparar_corte(1950), VARS_12, "1950", "year", 1950),
  resumen_pca(preparar_corte(1990), VARS_12, "1990", "year", 1990),
  resumen_pca(preparar_corte(2050), VARS_12, "2050 (UN projection)", "year", 2050)
)
print(tabla_pca_sens |> mutate(across(where(is.numeric), \(x) round(x, 3))), width = 200)
write_parquet(tabla_pca_sens, ruta_parquet_q2("pca_sensibilidad"))

# Autovalores vs ruido (base y 8 variables) para la figura "two real dimensions".
pc8 <- pca_orientado(d23, VARS_8); ap8 <- analisis_paralelo(pc8$Z)
tabla_autoval <- bind_rows(
  tibble(caso = "12 fixed indicators", componente = seq_along(ap23$obs), autovalor = ap23$obs,
         p50_nulo = ap23$p50, p95_nulo = ap23$p95, var_pct = 100 * ap23$obs / length(VARS_12)),
  tibble(caso = "8 indicators (sensitivity)", componente = seq_along(ap8$obs), autovalor = ap8$obs,
         p50_nulo = ap8$p50, p95_nulo = ap8$p95, var_pct = 100 * ap8$obs / length(VARS_8))
)
write_parquet(tabla_autoval, ruta_parquet_q2("pca_autovalores"))

tabla_scores <- d23 |>
  transmute(ISO3_code, Location, region_sdg, subregion, ingreso = as.character(ingreso), es_golfo = es_golfo(ISO3_code),
            TFR, CNMR_raw, CNMR_w = CNMR) |>
  mutate(PC1 = pc23$x[, 1], PC2 = pc23$x[, 2], PC3 = pc23$x[, 3], PC4 = pc23$x[, 4])
write_parquet(tabla_scores, ruta_parquet_q2("pca_scores"))
estructura <- stats::cor(pc23$Z, pc23$x[, 1:4])
tabla_cargas <- tibble(variable = VARS_12, variable_en = unname(etiquetas_en(sub("^logDens$", "PopDensity", VARS_12)))) |>
  mutate(variable_en = ifelse(variable == "logDens", "Population density (log)", variable_en),
         carga_PC1 = pc23$rotation[, 1], carga_PC2 = pc23$rotation[, 2], carga_PC3 = pc23$rotation[, 3],
         carga_PC4 = pc23$rotation[, 4], r_PC1 = estructura[, 1], r_PC2 = estructura[, 2],
         r_PC3 = estructura[, 3], r_PC4 = estructura[, 4])
write_parquet(tabla_cargas, ruta_parquet_q2("pca_cargas"))

# 7.4 Decisiones H7 (v1) y H7a.
h7_ok <- 100 * ve23[1] < 50 && n_pcs_70 == 3
h7a_ok <- ap23$n_dims == 2 && abs(r_tfr_pc1_v) > 0.9 && abs(r_tfr_pc2_v) < 0.2

# 7.5 Registro.
sens_sets <- tabla_pca_sens |> filter(tipo == "variable set")
sens_todo <- tabla_pca_sens
anotar("pc1_var", 100 * ve23[1], "%", "0.0",
       "Share of variance on the first principal component, PCA of the 12 fixed standardized indicators (2023)",
       FILTRO_1M_2023, "T9.3", c("slide3.build3", "fig09"), ic = extraer_ic(bs_pca, "pc1"),
       ic_iid = extraer_ic(iid_pca, "pc1"), sens_low = min(sens_sets$pc1_pct), sens_high = max(sens_sets$pc1_pct),
       sens_note = paste("by variable set:", paste(sprintf("%s %.1f", sens_sets$caso, sens_sets$pc1_pct), collapse = " · "),
                         "· other cases:", paste(sprintf("%s %.1f", sens_todo$caso[sens_todo$tipo != "variable set"],
                                                       sens_todo$pc1_pct[sens_todo$tipo != "variable set"]), collapse = " · ")),
       status = "pre-specified", hypothesis_id = "H7", n = N_PAISES_1M, universe = UNIVERSO_1M,
       say = sprintf("more than half (%s to %s percent, depending on which indicators enter)",
                     round(min(sens_sets$pc1_pct)), round(max(sens_sets$pc1_pct))))
anotar("pc2_var", 100 * ve23[2], "%", "0.0",
       "Share of variance on the second principal component, PCA of the 12 fixed indicators (2023)",
       FILTRO_1M_2023, "T9.3", c("fig09", "notebook.q2"), ic = extraer_ic(bs_pca, "pc2"),
       ic_iid = extraer_ic(iid_pca, "pc2"),
       sens_low = min(tabla_pca_sens$pc2_pct), sens_high = max(tabla_pca_sens$pc2_pct),
       sens_note = paste(sprintf("%s %.1f", tabla_pca_sens$caso, tabla_pca_sens$pc2_pct), collapse = " · "),
       status = "exploratory", hypothesis_id = "H7a", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("pc12_var", 100 * sum(ve23[1:2]), "%", "0.0",
       "Cumulative share of variance on the first two principal components (12 fixed indicators, 2023)",
       FILTRO_1M_2023, "T9.3", USO_NB, ic = extraer_ic(bs_pca, "acum2"), ic_iid = extraer_ic(iid_pca, "acum2"),
       status = "pre-specified", hypothesis_id = "H7", n = N_PAISES_1M, universe = UNIVERSO_1M)
pc_sg <- tabla_pca_sens |> filter(caso == "Without the 6 Gulf states")
anotar("pc2_var_no_gulf", pc_sg$pc2_pct, "%", "0.0",
       "Share of variance on PC2 when the 6 Gulf states (ARE, QAT, KWT, BHR, OMN, SAU) are removed (CNMR re-winsorized on 155)",
       "155 countries ≥ 1 M without the Gulf; UN estimates 2023", "T9.3", c("slide3.build3", "notebook.q2"),
       method = "sensitivity", sens_low = pc_sg$pc2_pct, sens_high = 100 * ve23[2],
       sens_note = sprintf("with the Gulf: %.1f", 100 * ve23[2]), status = "exploratory", hypothesis_id = "H7a",
       n = pc_sg$n, universe = UNIVERSO_1M)
anotar("n_pcs_70", n_pcs_70, "components", "0",
       "Number of principal components needed to reach 70 % of the variance (12 fixed indicators, 2023)",
       FILTRO_1M_2023, "T9.3", c("slide3.build3", "notebook.q2"), method = "block bootstrap by subregion",
       B = B_Q2, seed = SEMILLA, resample_unit = "UN subregion",
       sens_note = paste("block-bootstrap replicates by number of PCs:", paste(sprintf("%s: %d", names(reps_n70), as.integer(reps_n70)), collapse = ", ")),
       sens_low = min(as.integer(names(reps_n70))), sens_high = max(as.integer(names(reps_n70))),
       status = "pre-specified", hypothesis_id = "H7", n = N_PAISES_1M, universe = UNIVERSO_1M)
sens_dims <- tabla_pca_sens |> filter(!(tipo == "variable set" & caso == names(CONJUNTOS_PCA)[1]))
anotar("n_dims_parallel", ap23$n_dims, "dimensions", "0",
       sprintf(paste0("Number of leading eigenvalues above the 95th percentile of %d column-permuted data sets ",
                      "(Horn's parallel analysis), 12 fixed indicators, 2023"), B_PARALELO),
       FILTRO_1M_2023, "T9.4", c("slide3.build3", "fig09", "narration.s3"), method = "permutation",
       B = B_PARALELO, seed = SEMILLA, sens_low = min(sens_dims$n_dims_paralelo), sens_high = max(sens_dims$n_dims_paralelo),
       sens_note = paste(sprintf("%s: %d", sens_dims$caso, sens_dims$n_dims_paralelo), collapse = " · "),
       status = "exploratory", hypothesis_id = "H7a", n = N_PAISES_1M, universe = UNIVERSO_1M,
       say = decir_entero(ap23$n_dims))
anotar("eigen_pca_12", round(ap23$obs[1:4], 4), "eigenvalue", "0.00",
       "First 4 eigenvalues of the 12-indicator correlation matrix (2023)", FILTRO_1M_2023, "T9.4", USO_NB,
       method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("eigen_null_p95_12", round(ap23$p95[1:4], 4), "eigenvalue", "0.00",
       sprintf("95th percentile of the first 4 eigenvalues under column permutation (%d permutations)", B_PARALELO),
       FILTRO_1M_2023, "T9.4", USO_NB, method = "permutation", B = B_PARALELO, seed = SEMILLA,
       status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)
for (cl in list(c("r_tfr_pc1", "r_tfr_pc1", "first principal component (oriented so life expectancy loads positively)"),
                c("r_tfr_pc2", "r_tfr_pc2", "second principal component (oriented so net migration loads positively)"))) {
  vv <- if (cl[1] == "r_tfr_pc1") r_tfr_pc1_v else r_tfr_pc2_v
  col_s <- if (cl[1] == "r_tfr_pc1") "r_tfr_pc1" else "r_tfr_pc2"
  anotar(cl[1], vv, "r", "0.00",
         sprintf("Pearson correlation across countries between the total fertility rate and the %s, 2023", cl[3]),
         FILTRO_1M_2023, "T9.3", c("slide3.build3", "fig09"), ic = extraer_ic(bs_pca, cl[2]), ic_iid = extraer_ic(iid_pca, cl[2]),
         sens_low = min(tabla_pca_sens[[col_s]], na.rm = TRUE), sens_high = max(tabla_pca_sens[[col_s]], na.rm = TRUE),
         sens_note = paste(sprintf("%s %.2f", tabla_pca_sens$caso, tabla_pca_sens[[col_s]]), collapse = " · "),
         status = "exploratory", hypothesis_id = "H7a", n = N_PAISES_1M, universe = UNIVERSO_1M)
}

# 7.6 Figuras: análisis paralelo y biplot.
p_par <- tabla_autoval |> filter(componente <= 8) |>
  ggplot(aes(componente)) +
  geom_line(aes(y = p95_nulo, colour = "Noise (95th percentile of permuted data)"), linewidth = 1, linetype = "22") +
  geom_line(aes(y = autovalor, colour = "Observed"), linewidth = 1.1) +
  geom_point(aes(y = autovalor, colour = "Observed"), size = 3) +
  geom_hline(yintercept = 1, colour = COLOR_GRIS_CLARO, linewidth = 0.3) +
  facet_wrap(~caso, scales = "free_y") +
  scale_colour_manual(values = c("Observed" = COLOR_NACIMIENTOS, "Noise (95th percentile of permuted data)" = COLOR_DEFUNCIONES), name = NULL) +
  scale_x_continuous(breaks = 1:8) +
  labs(title = sprintf("Only %d directions beat noise: the data hold two real dimensions", ap23$n_dims),
       subtitle = sprintf("Horn's parallel analysis, %d permutations · 161 countries ≥ 1 M, 2023 · 12 indicators: eigenvalues %s vs noise %s",
                          B_PARALELO, paste(sprintf("%.2f", ap23$obs[1:3]), collapse = " / "), paste(sprintf("%.2f", ap23$p95[1:3]), collapse = " / ")),
       x = "Principal component", y = "Eigenvalue", caption = pie_q2(FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_par, "q2_07_parallel_analysis")

esc_flechas <- 4.2
flechas <- tabla_cargas |> mutate(x = esc_flechas * carga_PC1, y = esc_flechas * carga_PC2,
                                  et = ifelse(variable == "logDens", "log density", variable))
p_bip <- ggplot(tabla_scores, aes(PC1, PC2)) +
  geom_hline(yintercept = 0, colour = COLOR_GRIS_CLARO) + geom_vline(xintercept = 0, colour = COLOR_GRIS_CLARO) +
  geom_point(data = \(x) filter(x, !es_golfo), colour = "#9A9A9A", size = 2.2, alpha = 0.8) +
  geom_point(data = \(x) filter(x, es_golfo), colour = PALETA_GRUPOS_V2[["Migration-led"]], size = 3.6) +
  geom_text_repel(data = \(x) filter(x, es_golfo | ISO3_code %in% c("COL", "JPN", "NGA", "IND", "CHN", "USA", "DEU", "SSD", "SYR")),
                  aes(label = ISO3_code), size = 3.8, seed = SEMILLA, max.overlaps = 30) +
  geom_segment(data = flechas, aes(x = 0, y = 0, xend = x, yend = y), inherit.aes = FALSE,
               arrow = arrow(length = unit(0.18, "cm")), colour = "black", linewidth = 0.5) +
  geom_text(data = flechas, aes(x = x * 1.1, y = y * 1.1, label = et), inherit.aes = FALSE, size = 3.8, colour = "black") +
  labs(title = "Axis 1 is the transition; axis 2 is migration and sex ratio vs ageing",
       subtitle = sprintf("PCA of 12 indicators, 161 countries ≥ 1 M, 2023 · PC1 %.1f %% · PC2 %.1f %% · r(TFR, PC1) = %.2f · r(TFR, PC2) = %.2f · Gulf states in light blue",
                          100 * ve23[1], 100 * ve23[2], r_tfr_pc1_v, r_tfr_pc2_v),
       x = sprintf("PC1 — the demographic transition (%.0f %%)", 100 * ve23[1]),
       y = sprintf("PC2 (%.0f %%)", 100 * ve23[2]), caption = pie_q2("Net migration winsorized at ±3 SD.", FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_bip, "q2_08_pca_biplot")

p_pcs <- tabla_pca_sens |>
  mutate(caso = factor(caso, levels = rev(caso)), base = caso == names(CONJUNTOS_PCA)[1],
         tipo = factor(tipo, levels = c("variable set", "sample", "year"))) |>
  ggplot(aes(pc1_pct, caso)) +
  geom_errorbar(data = \(x) filter(x, base), aes(xmin = bs_pca$ci_low[["pc1"]], xmax = bs_pca$ci_high[["pc1"]]),
                orientation = "y", width = 0.25, colour = COLOR_NACIMIENTOS) +
  geom_point(aes(colour = base), size = 3.5) +
  geom_text(aes(label = sprintf("%.1f %%  (%d dims)", pc1_pct, n_dims_paralelo)), nudge_y = 0.33, size = 3.8) +
  facet_grid(tipo ~ ., scales = "free_y", space = "free_y") +
  scale_colour_manual(values = c(`TRUE` = COLOR_NACIMIENTOS, `FALSE` = COLOR_GRIS_OSCURO), guide = "none") +
  scale_x_continuous(limits = c(35, 85)) +
  labs(title = "The size of axis 1 depends on which indicators enter; the number of real dimensions barely does",
       subtitle = sprintf("Share of variance on PC1 (dims = components above noise). Base: %.1f %% [block bootstrap %.1f–%.1f]",
                          100 * ve23[1], bs_pca$ci_low[["pc1"]], bs_pca$ci_high[["pc1"]]),
       x = "Variance on the first principal component (%)", y = NULL,
       caption = pie_q2("2050 is a UN medium projection (scenario).", FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_pcs, "q2_09_pca_sensitivity")

# Figura de look-alikes: solapamiento por resumen + Colombia en el plano PCA.
et_res <- c(TFR = "Fertility (TFR)", LEx = "Life expectancy", MedianAgePop = "Median age", PC1 = "PC1 (best single number)",
            TFR_CNMR = "TFR + net migration", TFR_CDR = "TFR + crude death rate", PC12 = "PC1 + PC2", PC123 = "PC1 + PC2 + PC3")
p_knn <- tabla_knn |> filter(caso == casos_knn[[1]]$caso) |>
  mutate(resumen_en = factor(et_res[resumen], levels = et_res), un_numero = resumen %in% c("TFR", "LEx", "MedianAgePop", "PC1")) |>
  ggplot(aes(resumen_en, solapamiento_pct)) +
  geom_col(aes(fill = un_numero), width = 0.65) +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high), width = 0.2, na.rm = TRUE) +
  geom_hline(yintercept = azar_pct, linetype = "22", colour = COLOR_DEFUNCIONES) +
  annotate("text", x = 8.4, y = azar_pct + 2.5, label = sprintf("chance %.1f %%", azar_pct), hjust = 1, colour = COLOR_DEFUNCIONES, size = 4.2) +
  geom_text(aes(label = sprintf("%.0f %%", solapamiento_pct), y = pmax(solapamiento_pct, ci_high, na.rm = TRUE) + 2.5), size = 4.4) +
  scale_fill_manual(values = c(`TRUE` = COLOR_GRIS_OSCURO, `FALSE` = COLOR_NACIMIENTOS),
                    labels = c(`TRUE` = "One number", `FALSE` = "Two or three numbers"), name = NULL) +
  scale_y_continuous(limits = c(0, 75), expand = expansion(mult = c(0, 0.02))) +
  labs(title = sprintf("Fertility alone finds only %.0f %% of a country's 5 real look-alikes", knn_tfr_v),
       subtitle = "Real look-alikes = 5 nearest countries in 12 standardized indicators (2023); whiskers = 95 % block bootstrap by UN subregion",
       x = NULL, y = "Real look-alikes recovered (%)", caption = pie_q2(FUENTE_ESTANDAR)) +
  tema_q2() + theme(axis.text.x = element_text(size = rel(0.85)))
guardar_q2(p_knn, "q2_05_lookalikes_overlap")

grupo_col <- tibble(ISO3_code = unique(c("COL", col_12, col_tfr))) |>
  mutate(grupo = case_when(ISO3_code == "COL" ~ "Colombia",
                           ISO3_code %in% col_12 & ISO3_code %in% col_tfr ~ "Look-alike by both",
                           ISO3_code %in% col_12 ~ "Look-alike in 12 indicators",
                           TRUE ~ "Look-alike by fertility alone"))
p_col <- tabla_scores |> left_join(grupo_col, by = "ISO3_code") |>
  ggplot(aes(PC1, PC2)) +
  geom_point(data = \(x) filter(x, is.na(grupo)), colour = "#C8C8C8", size = 2) +
  geom_point(data = \(x) filter(x, !is.na(grupo)), aes(colour = grupo), size = 4) +
  geom_text_repel(data = \(x) filter(x, !is.na(grupo)), aes(label = Location, colour = grupo), size = 4.1,
                  seed = SEMILLA, show.legend = FALSE, max.overlaps = 30) +
  scale_colour_manual(values = c("Colombia" = "black", "Look-alike in 12 indicators" = COLOR_NACIMIENTOS,
                                 "Look-alike by fertility alone" = COLOR_DEFUNCIONES, "Look-alike by both" = COLOR_EMIGRACION), name = NULL) +
  labs(title = "Colombia's look-alikes: by fertility alone vs by 12 indicators",
       subtitle = sprintf("By TFR: %s · By 12 indicators: %s (2023, shown on the PCA plane)",
                          paste(col_tfr, collapse = ", "), paste(col_12, collapse = ", ")),
       x = sprintf("PC1 — the demographic transition (%.0f %%)", 100 * ve23[1]), y = sprintf("PC2 (%.0f %%)", 100 * ve23[2]),
       caption = pie_q2("Colombia is the team's home country, shown as an illustration; the table for all 161 countries is in figures/lookalikes_todos.csv.",
                        FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_col, "q2_06_colombia_lookalikes")

# =============================================================================
# 8. R3 · Índice compuesto (P5) y su fragilidad (H8, H8a)
#    Qué: índice de "avance de la transición" con TFR (−), Q5 (−), LEx (+), edad
#    mediana (+) y crecimiento (−). (a) Las 7 variantes del EDA (v1); (b) Monte
#    Carlo de 2 000 diseños (OCDE/JRC). Se cuenta qué % de países se mueve > 20
#    puestos y qué decisión (pesos o normalización) mueve más el ranking.
#    Por qué: P5 pide combinar indicadores y justificar decisiones; mostramos que
#    el ranking depende sobre todo de los pesos. NO es un índice de desarrollo.
# =============================================================================

DIR_INDICE <- c(TFR = -1, Q5 = -1, LEx = 1, MedianAgePop = 1, PopGrowthRate = -1)   # + = más avanzado
IND <- names(DIR_INDICE)
O <- sweep(as.matrix(d23[, IND]), 2, DIR_INDICE, `*`)
rownames(O) <- d23$ISO3_code
mm01 <- function(M) apply(M, 2, function(x) (x - min(x)) / (max(x) - min(x)))
rk01 <- function(M) apply(M, 2, function(x) rank(x) / length(x))
geo <- function(M01, w, piso = 0.01) exp(as.vector(log(piso + (1 - piso) * M01) %*% w))

# 8.1 Versión simple: las 7 variantes del EDA v1 (definiciones del notebook EDA, celda 87).
Zi <- scale(O); MMi <- mm01(O); RKi <- rk01(O)
w_dim <- c(TFR = 1 / 3, Q5 = 1 / 6, LEx = 1 / 6, MedianAgePop = 1 / 3, PopGrowthRate = 0)
pc_w <- stats::prcomp(Zi)$rotation[, 1]; if (pc_w["LEx"] < 0) pc_w <- -pc_w
variantes <- tibble(
  V1 = rowMeans(Zi),                                       # z · pesos iguales (base)
  V2 = rowMeans(MMi),                                      # min–max · pesos iguales
  V3 = rowMeans(RKi),                                      # rangos · pesos iguales
  V4 = as.vector(Zi %*% w_dim[IND]),                       # z · pesos por dimensión
  V5 = as.vector(Zi %*% pc_w[IND]),                        # z · pesos del PC1
  V6 = rowMeans(cbind(Zi, scale(d23$CNMR_raw))),           # z · + migración neta (signo +)
  V7 = exp(rowMeans(log(0.02 + 0.98 * MMi)))               # min–max · media geométrica
)
ETIQ_VAR <- c(V1 = "V1 z · equal weights", V2 = "V2 min–max · equal", V3 = "V3 ranks · equal",
              V4 = "V4 z · dimension weights", V5 = "V5 z · PC1 weights", V6 = "V6 z · + net migration",
              V7 = "V7 min–max · geometric")
rangos <- as.data.frame(lapply(variantes, function(x) rank(-x, ties.method = "min")))
amp <- function(cols) apply(rangos[, cols, drop = FALSE], 1, function(r) max(r) - min(r))
tabla_var <- d23 |> select(ISO3_code, Location) |>
  bind_cols(rangos |> rename_with(\(x) paste0("rank_", x))) |>
  mutate(amplitud_7 = amp(names(variantes)), amplitud_norm = amp(c("V1", "V2", "V3", "V7")),
         amplitud_pesos = amp(c("V1", "V4", "V5")), salto_mig = abs(rangos$V6 - rangos$V1),
         amplitud_sin_mig = amp(c("V1", "V2", "V3", "V4", "V5", "V7")))
write_parquet(tabla_var, ruta_parquet_q2("indice_variantes"))
rho_var <- stats::cor(rangos, method = "spearman")
share7 <- 100 * mean(tabla_var$amplitud_7 > 20)
share7_norm <- 100 * mean(tabla_var$amplitud_norm > 20)
share7_pesos <- 100 * mean(tabla_var$amplitud_pesos > 20)
share7_mig <- 100 * mean(tabla_var$salto_mig > 20)
share7_sinmig <- 100 * mean(tabla_var$amplitud_sin_mig > 20)
destacado <- tabla_var |> arrange(desc(amplitud_sin_mig), ISO3_code) |> slice(1)
message(sprintf(paste0("7 variantes: ρ mín %.3f; >20 puestos: %.1f %% (solo normalización %.1f %%, solo pesos %.1f %%, ",
                       "migración %.1f %%, sin la de migración %.1f %%); caso destacado (mayor amplitud sin migración): %s (%d)"),
                min(rho_var), share7, share7_norm, share7_pesos, share7_mig, share7_sinmig, destacado$ISO3_code,
                as.integer(destacado$amplitud_sin_mig)))
h8_ok <- abs(share7 - 24) <= 3

# 8.2 Versión rica: Monte Carlo de diseños (pesos Dirichlet, normalización,
#     agregación e inclusión del crecimiento), intervalo 90 % de rango por país.
mc_indice <- function(O, a = 5, varia_inclusion = TRUE, pesos_iguales = FALSE, M = M_INDICE, semilla = SEMILLA) {
  set.seed(semilla)
  ind <- colnames(O)
  sims <- replicate(M, {
    usa <- if (varia_inclusion && stats::runif(1) < 0.5) ind[1:4] else ind
    w <- if (pesos_iguales) rep(1 / length(usa), length(usa)) else { g <- stats::rgamma(length(usa), a); g / sum(g) }
    norm <- sample(c("z", "mm", "rk"), 1); agg <- sample(c("arit", "geom"), 1)
    Mx <- switch(norm, z = scale(O[, usa]), mm = mm01(O[, usa]), rk = rk01(O[, usa]))
    s <- if (agg == "geom") geo(if (norm == "z") mm01(O[, usa]) else Mx, w) else as.vector(Mx %*% w)
    rank(-s)
  })
  q <- apply(sims, 1, stats::quantile, c(0.05, 0.5, 0.95))
  tibble(ISO3_code = rownames(O), r05 = q[1, ], r50 = q[2, ], r95 = q[3, ], ancho90 = q[3, ] - q[1, ])
}
SPECS_MC <- list(
  declared = list(a = 5, inc = TRUE, igual = FALSE,
                  en = "Declared: Dirichlet(5) weights + normalization + aggregation + inclusion of growth"),
  norm_only = list(a = NA, inc = FALSE, igual = TRUE, en = "Equal weights, only normalization and aggregation vary"),
  dir5_fixed5 = list(a = 5, inc = FALSE, igual = FALSE, en = "Dirichlet(5) weights, 5 indicators fixed"),
  dir1 = list(a = 1, inc = TRUE, igual = FALSE, en = "Dirichlet(1) weights (very dispersed) + inclusion of growth")
)
tabla_mc <- imap_dfr(SPECS_MC, function(s, nm) {
  mc_indice(O, a = ifelse(is.na(s$a), 1, s$a), varia_inclusion = s$inc, pesos_iguales = s$igual) |> mutate(spec = nm)
}) |>
  left_join(tabla_var |> select(ISO3_code, Location, rango_base = rank_V1), by = "ISO3_code") |>
  mutate(mas20 = ancho90 > 20) |>
  select(spec, ISO3_code, Location, rango_base, r05, r50, r95, ancho90, mas20)
write_parquet(tabla_mc, ruta_parquet_q2("indice_mc"))
resumen_mc <- tabla_mc |> group_by(spec) |>
  summarise(mediana_ancho = stats::median(ancho90), p90_ancho = unname(stats::quantile(ancho90, 0.9)),
            pct_mas20 = 100 * mean(mas20), n_mas20 = sum(mas20), .groups = "drop") |>
  mutate(descripcion_en = vapply(spec, function(s) SPECS_MC[[s]]$en, character(1))) |>
  arrange(match(spec, names(SPECS_MC)))
print(resumen_mc)
write_parquet(resumen_mc |> select(spec, descripcion_en, mediana_ancho, p90_ancho, pct_mas20), ruta_parquet_q2("mc_resumen"))
pct_mc <- setNames(resumen_mc$pct_mas20, resumen_mc$spec)
n_mc <- setNames(resumen_mc$n_mas20, resumen_mc$spec)
h8a_ok <- pct_mc[["declared"]] >= 10 && pct_mc[["declared"]] > pct_mc[["norm_only"]]
mc_decl <- tabla_mc |> filter(spec == "declared")
ukr <- mc_decl |> filter(ISO3_code == "UKR")
ukr_dir1 <- tabla_mc |> filter(spec == "dir1", ISO3_code == "UKR")
mas_inciertos <- mc_decl |> arrange(desc(ancho90), ISO3_code) |> slice_head(n = 8)
robustos_arriba <- mc_decl |> filter(r95 <= 10) |> arrange(r50)
robustos_abajo <- mc_decl |> filter(r05 >= N_PAISES_1M - 10) |> arrange(r50)

# 8.3 Fiabilidad (solo notebook): α estandarizado, ω de McDonald, pesos efectivos, validez con LE60.
alfa_std <- function(M) { M <- scale(M); k <- ncol(M); k / (k - 1) * (1 - sum(apply(M, 2, stats::var)) / stats::var(rowSums(M))) }
omega_mcd <- function(M) {
  f <- stats::factanal(M, factors = 1)
  l <- f$loadings[, 1]
  sum(l)^2 / (sum(l)^2 + sum(f$uniquenesses))
}
alfa5 <- alfa_std(O); alfa4 <- alfa_std(O[, 1:4]); alfa3 <- alfa_std(O[, c("TFR", "Q5", "LEx")])
omega5 <- tryCatch(omega_mcd(O), error = function(e) NA_real_)
imp <- vapply(IND, function(v) stats::cor(variantes$V1, O[, v])^2, numeric(1)); imp <- imp / sum(imp)
le60 <- readr::read_csv(RUTA_WPP_SUPLEMENTO, show_col_types = FALSE) |>
  filter(Time == ANIO_FIN_ESTIMACION) |> select(ISO3_code, LE60)
d_val <- d23 |> select(ISO3_code, subregion, all_of(IND)) |> left_join(le60, by = "ISO3_code")
stopifnot(!anyNA(d_val$LE60))
stat_validez <- function(d) {
  Oi <- sweep(as.matrix(d[, IND]), 2, DIR_INDICE, `*`)
  stats::cor(rowMeans(scale(Oi)), d$LE60, method = "spearman")
}
set.seed(SEMILLA)
bs_val <- bootstrap_bloques(d_val, stat_validez, B = B_Q2, semilla = SEMILLA)

# 8.4 Registro del índice.
w7 <- ic_wilson(sum(tabla_var$amplitud_7 > 20), N_PAISES_1M, escala = 100)
anotar("share_rank_7var", share7, "%", "0",
       "Share of countries whose rank moves more than 20 places across the 7 hand-picked index variants of the v1 plan (z / min–max / ranks / dimension weights / PC1 weights / + net migration / geometric)",
       FILTRO_1M_2023, "T10.1", USO_NB, ic = w7,
       sens_low = min(share7_norm, share7_pesos, share7_mig), sens_high = share7,
       sens_note = sprintf(paste0("only normalization/aggregation variants (V1, V2, V3, V7) %.1f · only weights (V1, V4, V5) %.1f · ",
                                  "adding net migration (V6 vs V1) %.1f · all except the migration variant %.1f · min Spearman between variants %.3f"),
                           share7_norm, share7_pesos, share7_mig, share7_sinmig, min(rho_var)),
       status = "pre-specified", hypothesis_id = "H8", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("rho_rank_7var_min", min(rho_var), "rho", "0.00",
       "Smallest Spearman correlation between the rankings of the 7 index variants", FILTRO_1M_2023, "T10.1", USO_NB,
       method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M,
       sens_note = sprintf("without the migration variant: %.3f", min(rho_var[-6, -6])))
w_mc <- ic_wilson(n_mc[["declared"]], N_PAISES_1M, escala = 100)
anotar("share_rank_mc20", pct_mc[["declared"]], "%", "0",
       # QA-stats (docs/QA_stats.md): se declaran la probabilidad de incluir el crecimiento y la media geométrica.
       sprintf(paste0("Share of countries whose 90 %% rank interval (5th to 95th percentile of their ranks, R quantile type 7) is wider ",
                      "than 20 places across %s random index designs (seed %d): 5 indicators oriented so that higher = more advanced; ",
                      "Dirichlet(5) weights; normalization z / min–max / percentile rank and aggregation arithmetic / geometric, each drawn ",
                      "with equal probability; population growth included with probability 0.5; the geometric mean is taken on min–max ",
                      "scores (also when z is drawn) or on rank scores, floored at 0.01"),
               format(M_INDICE, big.mark = ","), SEMILLA),
       FILTRO_1M_2023, "T10.2", c("slide3.build4", "narration.s3"), ic = w_mc,
       sens_low = min(pct_mc), sens_high = max(pct_mc),
       sens_note = paste(sprintf("%s %.1f", vapply(names(pct_mc), function(s) SPECS_MC[[s]]$en, character(1)), pct_mc), collapse = " · "),
       status = "pre-specified", hypothesis_id = "H8a", n = N_PAISES_1M, universe = UNIVERSO_1M,
       say = decir_uno_de(pct_mc[["declared"]], "country"))
anotar("share_rank_mc20_sens", round(pct_mc, 2), "%", "0",
       "Share of countries with a 90 % rank interval > 20 places under each Monte Carlo specification",
       FILTRO_1M_2023, "T10.2", USO_NB, method = "sensitivity", sens_low = min(pct_mc), sens_high = max(pct_mc),
       sens_note = paste(sprintf("%s = %s", names(SPECS_MC), vapply(SPECS_MC, `[[`, character(1), "en")), collapse = " · "),
       status = "pre-specified", hypothesis_id = "H8a", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("rank_range_ukr", c(low = ukr$r05, high = ukr$r95), "rank", "0",
       "Ukraine's 90 % rank interval across the declared Monte Carlo of index designs (1 = most advanced in the transition)",
       FILTRO_1M_2023, "T10.2", c("appendix.bump"), method = "sensitivity", sens_low = ukr$r05, sens_high = ukr$r95,
       sens_note = sprintf("median rank %.0f; base rank (z, equal weights) %d; with Dirichlet(1) weights %.0f–%.0f",
                           ukr$r50, as.integer(ukr$rango_base), ukr_dir1$r05, ukr_dir1$r95),
       status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("index_most_uncertain", as.data.frame(mas_inciertos |> transmute(iso3 = ISO3_code, country = Location, r05, r50, r95, width90 = ancho90)),
       NA, "text", "The 8 countries with the widest 90 % rank interval in the declared Monte Carlo",
       FILTRO_1M_2023, "T10.2", USO_NB, method = "sensitivity", status = "exploratory",
       sens_note = sprintf("robust at the top (95th pct rank ≤ 10): %s · robust at the bottom (5th pct ≥ %d): %s",
                           paste(robustos_arriba$ISO3_code, collapse = ", "), N_PAISES_1M - 10, paste(robustos_abajo$ISO3_code, collapse = ", ")),
       n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("index_highlight", destacado$Location, NA, "text",
       "Highlighted country by rule: the largest rank jump across the 6 index variants without net migration",
       FILTRO_1M_2023, "T10.1", c("appendix.bump"), method = "descriptive", status = "exploratory",
       sens_note = sprintf("%s: ranks %d–%d across V1–V5, V7 (jump %d places)", destacado$ISO3_code,
                           as.integer(min(unlist(destacado[, paste0("rank_V", c(1:5, 7))]))),
                           as.integer(max(unlist(destacado[, paste0("rank_V", c(1:5, 7))]))),
                           as.integer(destacado$amplitud_sin_mig)),
       n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("alpha", alfa5, "alpha", "0.00",
       "Standardized Cronbach's alpha of the 5 oriented index indicators (notebook only: a reflective model does not hold; high alpha does not imply a robust ranking)",
       FILTRO_1M_2023, "T10.3", USO_NB, method = "sensitivity", sens_low = min(alfa3, alfa4, alfa5), sens_high = max(alfa3, alfa4, alfa5),
       sens_note = sprintf("4 items (without growth) %.3f · 3 items (TFR, Q5, LEx) %.3f", alfa4, alfa3),
       status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("omega", omega5, "omega", "0.00",
       "McDonald's omega (one-factor ML model) of the 5 oriented index indicators (notebook only)",
       FILTRO_1M_2023, "T10.3", USO_NB, method = "descriptive", status = "exploratory",
       n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("index_eff_weights", round(imp, 4), "share", "0.00",
       "Effective weights: squared correlation of the base index (z, equal weights) with each indicator, normalized to sum 1 (nominal 0.20 each)",
       FILTRO_1M_2023, "T10.3", USO_NB, method = "descriptive", status = "exploratory",
       n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("rho_index_le60", bs_val$valor, "rho", "0.00",
       "Convergent validity: Spearman correlation of the base index with life expectancy at 60 (not in the index; organizers' supplement), 2023",
       FILTRO_1M_2023, "T10.3", USO_NB, ic = bs_val, status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)

# 8.5 Figuras del índice.
top20 <- tabla_var |> arrange(desc(amplitud_7), ISO3_code) |> slice_head(n = 20)
niveles_top20 <- rev(top20$Location[order(top20$rank_V1)])
largo_top20 <- top20 |> select(ISO3_code, Location, rank_V1:rank_V7) |>
  pivot_longer(starts_with("rank_"), names_to = "variante", values_to = "rango") |>
  mutate(variante = ETIQ_VAR[sub("rank_", "", variante)], pais = factor(Location, levels = niveles_top20))
rango_top20 <- largo_top20 |> group_by(pais) |> summarise(rmin = min(rango), rmax = max(rango), .groups = "drop")
p_var <- ggplot(largo_top20, aes(rango, pais)) +
  geom_segment(data = rango_top20, aes(x = rmin, xend = rmax, y = pais, yend = pais), inherit.aes = FALSE,
               colour = COLOR_GRIS_CLARO, linewidth = 1.6) +
  geom_point(aes(shape = variante, colour = variante), size = 2.8) +
  scale_shape_manual(values = c(16, 17, 15, 18, 8, 4, 3), name = NULL) +
  scale_colour_manual(values = c("#000000", "#0072B2", "#56B4E9", "#E69F00", "#CC79A7", "#999999", "#332288"), name = NULL) +
  guides(colour = guide_legend(nrow = 2), shape = guide_legend(nrow = 2)) +
  labs(title = sprintf("Seven index variants: %.0f %% of countries move more than 20 places", share7),
       subtitle = sprintf("The 20 countries with the widest range (1 = most advanced in the transition, of 161). Only normalization varies: %.0f %%; only weights: %.0f %%; adding migration: %.0f %%",
                          share7_norm, share7_pesos, share7_mig),
       x = "Rank", y = NULL,
       caption = pie_q2("A transition-stage index — not a ranking of development or well-being.", FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_var, "q2_10_index_seven_variants")

p_mc <- mc_decl |> arrange(r50, ISO3_code) |> mutate(orden = row_number()) |>
  ggplot(aes(orden)) +
  geom_linerange(aes(ymin = r05, ymax = r95, colour = mas20), linewidth = 0.9) +
  geom_point(aes(y = r50), size = 0.9, colour = "black") +
  geom_text_repel(data = \(x) filter(x, ISO3_code %in% c("UKR", mas_inciertos$ISO3_code[1:4])),
                  aes(y = r95, label = ISO3_code), size = 3.8, nudge_y = 12, seed = SEMILLA) +
  scale_colour_manual(values = c(`TRUE` = COLOR_DEFUNCIONES, `FALSE` = COLOR_GRIS_CLARO),
                      labels = c(`TRUE` = "Interval wider than 20 places", `FALSE` = "20 places or fewer"), name = NULL) +
  scale_y_reverse() +
  labs(title = sprintf("Across %s reasonable index designs, %.0f %% of countries can move more than 20 places",
                       format(M_INDICE, big.mark = ","), pct_mc[["declared"]]),
       subtitle = sprintf("90 %% rank interval per country (dot = median). Weights decide: equal weights with other formulas %.1f %%; Dirichlet(1) weights %.1f %%",
                          pct_mc[["norm_only"]], pct_mc[["dir1"]]),
       x = "Countries ordered by median rank", y = "Rank (1 = most advanced in the transition)",
       caption = pie_q2("A transition-stage index — not a ranking of development or well-being.", FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_mc, "q2_11_index_monte_carlo")

# =============================================================================
# 9. Hallazgo de demografía: misma fecundidad, saldo natural opuesto (dem01)
#    Qué: entre los países con TFR 1,5–1,99, rango del saldo natural y su
#    correlación con la edad mediana; entre los países bajo reemplazo, R² del
#    saldo natural con TFR sola y con TFR + edad mediana.
#    Por qué: la misma fecundidad no fija el signo de nacimientos − defunciones;
#    lo fija la estructura por edades (otra cara de P8).
# =============================================================================

banda <- d23 |> filter(TFR >= 1.5, TFR < 2.0) |>
  transmute(ISO3_code, Location, region_sdg, subregion, TFR, NatChangeRT, CNMR = CNMR_raw, PopGrowthRate, MedianAgePop)
write_parquet(banda |> select(-subregion), ruta_parquet_q2("misma_fecundidad"))
nat_min <- banda |> slice_min(NatChangeRT, n = 1, with_ties = FALSE)
nat_max <- banda |> slice_max(NatChangeRT, n = 1, with_ties = FALSE)
set.seed(SEMILLA)
bs_band <- bootstrap_bloques(banda, function(d) stats::cor(d$NatChangeRT, d$MedianAgePop), B = B_Q2, semilla = SEMILLA)
bajo <- d23 |> filter(TFR < TFR_REEMPLAZO) |> select(ISO3_code, subregion, TFR, NatChangeRT, MedianAgePop)
stat_bajo <- function(d) c(tfr = r2_lm(d, "NatChangeRT", "TFR"), tfr_medage = r2_lm(d, "NatChangeRT", c("TFR", "MedianAgePop")))
set.seed(SEMILLA)
bs_bajo <- bootstrap_bloques(bajo, stat_bajo, B = B_Q2, semilla = SEMILLA)
FILTRO_BANDA <- "Countries ≥ 1 M with total fertility 1.5–1.99 in 2023; UN estimates"
FILTRO_BAJO <- "Countries ≥ 1 M with total fertility below 2.1 in 2023; UN estimates"
anotar("n_band_tfr", nrow(banda), "countries", "0", "Countries ≥ 1 M with total fertility rate between 1.5 and 1.99 in 2023",
       FILTRO_BANDA, "T15.1", c("appendix.same_fertility"), method = "none_census", status = "descriptive",
       n = nrow(banda), universe = UNIVERSO_1M)
anotar("nat_min_band", nat_min$NatChangeRT, "per 1,000", "+0.0",
       sprintf("Lowest rate of natural change (births − deaths per 1,000) among countries with TFR 1.5–1.99, 2023 (%s)", nat_min$Location),
       FILTRO_BANDA, "T15.1", c("appendix.same_fertility"), method = "descriptive", status = "exploratory",
       n = nrow(banda), universe = UNIVERSO_1M)
anotar("nat_max_band", nat_max$NatChangeRT, "per 1,000", "+0.0",
       sprintf("Highest rate of natural change among countries with TFR 1.5–1.99, 2023 (%s)", nat_max$Location),
       FILTRO_BANDA, "T15.1", c("appendix.same_fertility"), method = "descriptive", status = "exploratory",
       n = nrow(banda), universe = UNIVERSO_1M)
anotar("r_nat_medage_band", bs_band$valor, "r", "0.00",
       "Pearson correlation of natural change rate and median age among countries with TFR 1.5–1.99, 2023",
       FILTRO_BANDA, "T15.1", c("appendix.same_fertility"), ic = bs_band, status = "exploratory",
       n = nrow(banda), universe = UNIVERSO_1M)
anotar("r2_nat_tfr_belowrepl", bs_bajo$valor[["tfr"]], "R2", "0.00",
       "Adjusted R² of natural change rate on TFR alone, countries below replacement (TFR < 2.1), 2023",
       FILTRO_BAJO, "T15.1", USO_NB, ic = extraer_ic(bs_bajo, "tfr"), status = "exploratory",
       n = nrow(bajo), universe = UNIVERSO_1M, say = decir_fraccion(bs_bajo$valor[["tfr"]]),
       sens_note = sprintf("unadjusted R² %.3f", r2_lm(bajo, "NatChangeRT", "TFR", ajustado = FALSE)))
anotar("r2_nat_tfr_medage_belowrepl", bs_bajo$valor[["tfr_medage"]], "R2", "0.00",
       "Adjusted R² of natural change rate on TFR + median age, countries below replacement (TFR < 2.1), 2023",
       FILTRO_BAJO, "T15.1", USO_NB, ic = extraer_ic(bs_bajo, "tfr_medage"), status = "exploratory",
       n = nrow(bajo), universe = UNIVERSO_1M, say = decir_fraccion(bs_bajo$valor[["tfr_medage"]]),
       sens_note = sprintf("unadjusted R² %.3f", r2_lm(bajo, "NatChangeRT", c("TFR", "MedianAgePop"), ajustado = FALSE)))

p_band <- ggplot(banda, aes(MedianAgePop, NatChangeRT)) +
  geom_hline(yintercept = 0, colour = "black", linewidth = 0.4) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = COLOR_GRIS_CLARO, linewidth = 0.8) +
  geom_point(aes(colour = NatChangeRT > 0), size = 3.4) +
  geom_text_repel(aes(label = ISO3_code), size = 3.6, seed = SEMILLA, max.overlaps = 40) +
  scale_colour_manual(values = c(`TRUE` = COLOR_NACIMIENTOS, `FALSE` = COLOR_DEFUNCIONES),
                      labels = c(`TRUE` = "More births than deaths", `FALSE` = "More deaths than births"), name = NULL) +
  labs(title = "Same fertility, opposite natural change: age structure sets the sign",
       subtitle = sprintf("%d countries ≥ 1 M with 1.5–1.99 children per woman (2023): births − deaths from %+.1f to %+.1f per 1,000; r with median age = %.2f [%.2f; %.2f]",
                          nrow(banda), nat_min$NatChangeRT, nat_max$NatChangeRT, bs_band$valor, bs_band$ci_low, bs_band$ci_high),
       x = "Median age 2023 (years)", y = "Natural change 2023 (per 1,000)",
       caption = pie_q2(FUENTE_ESTANDAR)) +
  tema_q2()
guardar_q2(p_band, "q2_12_same_fertility_natural_change")

# =============================================================================
# 10. Redundancia (solo notebook): VIF y correlaciones parciales
#     Qué: VIF de las 12 variables y correlaciones parciales de las 8 no
#     redundantes. Por qué: muestra que varias variables son casi duplicados
#     mecánicos (no se deben regresar unas sobre otras como independientes).
# =============================================================================

vif12 <- vapply(VARS_12, function(v) 1 / (1 - summary(stats::lm(stats::reformulate(setdiff(VARS_12, v), v), data = d23))$r.squared), numeric(1))
vars_nr <- CONJUNTOS_PCA[["8 non-redundant (MV)"]]
Rm <- stats::cor(d23[, vars_nr]); Pm <- -stats::cov2cor(solve(Rm)); diag(Pm) <- 1
pares_parc <- list(c("TFR", "LEx"), c("TFR", "CNMR"), c("LEx", "CDR"), c("MedianAgePop", "CDR"), c("TFR", "MedianAgePop"))
tabla_red <- bind_rows(
  tibble(tipo = "VIF 12", par = VARS_12, valor = unname(vif12)),
  map_dfr(pares_parc, \(p) tibble(tipo = "simple r (8 non-redundant)", par = paste(p, collapse = "–"), valor = Rm[p[1], p[2]])),
  map_dfr(pares_parc, \(p) tibble(tipo = "partial r (8 non-redundant)", par = paste(p, collapse = "–"), valor = Pm[p[1], p[2]]))
)
write_parquet(tabla_red, ruta_parquet_q2("redundancia"))
anotar("vif_max_12", max(vif12), "VIF", "0", sprintf("Largest variance inflation factor among the 12 PCA indicators (%s), 2023", names(which.max(vif12))),
       FILTRO_1M_2023, "T9.6", USO_NB, method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M,
       sens_note = paste(sprintf("%s %.0f", names(sort(vif12, decreasing = TRUE))[1:4], sort(vif12, decreasing = TRUE)[1:4]), collapse = " · "))
anotar("partial_r_tfr_lex", Pm["TFR", "LEx"], "r", "0.00",
       "Partial correlation of TFR and life expectancy given the other 6 non-redundant indicators, 2023",
       FILTRO_1M_2023, "T9.6", USO_NB, method = "descriptive", status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M,
       sens_note = sprintf("simple correlation %.2f", Rm["TFR", "LEx"]))

# =============================================================================
# 11. Hipótesis de Q2, guardado del registro y comprobaciones finales
#     Qué: estado de H6, H7, H7a, H8, H8a, H13 y H20 según las reglas fijadas en
#     docs/hipotesis_preinscritas.md; se publica el resultado sea cual sea.
# =============================================================================

estado_txt <- function(ok, parcial = FALSE) if (isTRUE(ok)) "confirmed" else if (parcial) "partly" else "rejected"
tabla_hip <- tibble(
  id = c("H6", "H7", "H7a", "H8", "H8a", "H13", "H20"),
  enunciado_en = c("Fertility alone explains ≥ 70 % of median age and of 2023→2050 change, ≤ 60 % of growth, ≤ 10 % of migration",
                   "PC1 of the 12-indicator PCA < 50 % and 3 components needed for 70 %",
                   "Exactly 2 components beat parallel analysis; |r(TFR, PC1)| > 0.9 and |r(TFR, PC2)| < 0.2",
                   "Index design moves 1 in 4 countries (24 %) more than 20 places (7 variants)",
                   "≥ 10 % of countries have a 90 % rank interval > 20 places, more than with only normalization/aggregation",
                   "ρ(CDR, LEx) < −0.9 in 1950 and its 2023 interval contains 0",
                   "Fertility alone recovers < 25 % of the 5 real look-alikes; PC1 + PC2 > 40 %"),
  estatus = c("pre-specified", "pre-specified", "exploratory", "pre-specified", "pre-specified", "pre-specified", "exploratory"),
  resultado = c(estado_txt(h6_ok_punto && h6_ok_cv), estado_txt(h7_ok), estado_txt(h7a_ok), estado_txt(h8_ok),
                estado_txt(h8a_ok), estado_txt(h13_ok), estado_txt(h20_ok)),
  evidencia = c(
    sprintf("adj R² %.3f / %.3f / %.3f / %.3f; 10-fold CV %.3f / %.3f / %.3f / %.3f", r2_adj[1], r2_adj[2], r2_adj[3], r2_adj[4],
            cv_media[1], cv_media[2], cv_media[3], cv_media[4]),
    sprintf("PC1 %.1f %% [%.1f; %.1f]; %d components for 70 %% (2 PCs = %.1f %%)", 100 * ve23[1], bs_pca$ci_low[["pc1"]],
            bs_pca$ci_high[["pc1"]], n_pcs_70, 100 * sum(ve23[1:2])),
    sprintf("%d dimensions (eigenvalues %s vs noise %s); r(TFR, PC1) = %.3f, r(TFR, PC2) = %.3f", ap23$n_dims,
            paste(sprintf("%.2f", ap23$obs[1:3]), collapse = "/"), paste(sprintf("%.2f", ap23$p95[1:3]), collapse = "/"),
            r_tfr_pc1_v, r_tfr_pc2_v),
    sprintf("7 variants: %.1f %% move > 20 places (normalization only %.1f %%, weights only %.1f %%, migration %.1f %%)",
            share7, share7_norm, share7_pesos, share7_mig),
    sprintf("declared MC %.1f %% vs normalization/aggregation only %.1f %% (Dirichlet(5) fixed %.1f %%, Dirichlet(1) %.1f %%)",
            pct_mc[["declared"]], pct_mc[["norm_only"]], pct_mc[["dir5_fixed5"]], pct_mc[["dir1"]]),
    sprintf("1950 %.3f [%.3f; %.3f]; 2023 %.3f [%.3f; %.3f] (block bootstrap)", r_1950$valor, r_1950$ci_low, r_1950$ci_high,
            r_2023$valor, r_2023$ci_low, r_2023$ci_high),
    sprintf("TFR %.1f %% [%.1f; %.1f]; PC1+PC2 %.1f %% [%.1f; %.1f]; chance %.1f %%", knn_tfr_v, bs_knn$ci_low[["tfr"]],
            bs_knn$ci_high[["tfr"]], knn_pc12_v, bs_knn$ci_low[["pc12"]], bs_knn$ci_high[["pc12"]], azar_pct)
  )
)
print(tabla_hip, width = 250)
write_parquet(tabla_hip, ruta_parquet_q2("hipotesis"))
anotar("hyp_q2_status", as.data.frame(tabla_hip |> select(id, status = estatus, result = resultado, evidence = evidencia)),
       NA, "text", "Result of each Q2 hypothesis under the decision rules of docs/hipotesis_preinscritas.md",
       "See each hypothesis", "T17.q2", USO_NB, method = "descriptive", status = "descriptive",
       n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("n_tests_q2", nrow(tabla_hip), "hypotheses", "0",
       "Number of pre-specified or exploratory hypotheses evaluated in Q2 (family F1; no p-values reported)",
       "Q2 hypotheses", "T17.q2", USO_NB, method = "descriptive", status = "descriptive",
       n = nrow(tabla_hip), universe = UNIVERSO_1M,
       sens_note = "illustrations (twins, Colombia, highlighted countries) are family F3 and not tested")

# Guardado y validación del registro.
guardar_numbers(reg, RUTA_NUMBERS_Q2, ordenar = TRUE)
problemas_reg <- validar_registro(reg)
ic_pantalla_mal <- problemas_reg[grepl("no puede salir en pantalla", problemas_reg$problema), , drop = FALSE]
if (nrow(problemas_reg) > 0) {
  message("validar_registro(): ", nrow(problemas_reg), " observaciones:")
  print(problemas_reg)
}
faltan_slide3 <- claves_faltantes(reg, "slide3")
if (length(faltan_slide3) > 0) warning("Faltan claves obligatorias de la Slide 3: ", paste(faltan_slide3, collapse = ", "), call. = FALSE)
reg_leido <- leer_numbers(RUTA_NUMBERS_Q2)
stopifnot(identical(sort(names(reg_leido)), sort(names(reg))))

t_total <- as.numeric(difftime(Sys.time(), t_inicio, units = "secs"))
message(sprintf("== Q2 terminado: %d claves en %s; %d figuras en %s; tiempo total %.1f s ==",
                length(reg), RUTA_NUMBERS_Q2, length(list.files(RUTA_FIG_Q2, pattern = "\\.png$")), RUTA_FIG_Q2, t_total))
writeLines(capture.output(sessionInfo()), file.path(RUTA_FIG_Q2, "sessionInfo_q2.txt"))
invisible(TRUE)
