#!/usr/bin/env Rscript
# =============================================================================
# docs/qa/consolidar_verificacion.R — Consolidación de la verificación
# independiente de figures/numbers.json (agente "cierre-qa-stats")
#
# Uso (desde la raíz del repositorio):
#   Rscript docs/qa/consolidar_verificacion.R
# Salida: docs/qa/verificacion_consolidada.csv (una fila por clave recalculada)
#
# Qué hace:
#   1. Lee los resultados de los cuatro lotes del verificador independiente
#      (docs/qa/verificacion_lote_{1..4}_resultados.csv, 210 claves; los
#      scripts que los producen son docs/qa/verificacion_lote_{1..4}.R).
#   2. Lee figures/numbers.json v1 (el archivo que vieron los verificadores,
#      SHA-256 fijado abajo) y guarda, por clave, la HUELLA de la cifra
#      (value, IC, sensibilidad, IP y método; ver R/qa_verificacion.R).
#   3. Anota cada clave con la decisión de QA-stats: si queda verificada, qué
#      acción se tomó (aclaración de `def`, recomendación para el guion) y la
#      nota en inglés que va al campo `nota_qa` de numbers.json.
#   4. Escribe la tabla consolidada que lee R/05_numbers_json.R (§4.5).
#
# Decisiones (ASA 2022, B.4, C.2, C.8):
#   * Los lotes 3 y 4 traen las columnas `coincide` y `definicion_clara`; los
#     lotes 1 y 2 no. Para esos dos lotes `coincide` = TRUE porque el informe
#     consolidado del verificador (relevado por el flujo de trabajo, 210
#     cifras, 0 discrepancias) lo dice clave por clave, y `definicion_clara`
#     = FALSE solo en las 8 claves que ese informe marcó como ambiguas.
#   * `are_revision_pct` NO se marca como verificada aunque el informe diga
#     que coincide: es una cifra externa (WPP2022 frente a WPP2024) y la
#     comprobación usó un valor de WPP2022 "recordado, no verificado". Marcarla
#     sería exagerar la certeza (C.2): queda pendiente de una persona.
#   * La huella sale SIEMPRE del numbers.json v1 verificado. Si el archivo
#     actual ya no es ese (otra corrida), el script NO recalcula las huellas:
#     conserva las de la tabla existente (así un número nuevo nunca hereda un
#     ✔ viejo) y solo actualiza los textos de acción y nota.
#
# Convención: código y comentarios en español; textos de nota_qa en inglés.
# =============================================================================

suppressPackageStartupMessages({
  library(jsonlite)
})
RAIZ <- "/home/darkns/Documents/ASA_Dataquest/RepoGithub"
source(file.path(RAIZ, "R", "incertidumbre.R"))
source(file.path(RAIZ, "R", "qa_verificacion.R"))

RUTA_NUMBERS <- file.path(RAIZ, "figures", "numbers.json")
RUTA_SALIDA  <- file.path(RAIZ, "docs", "qa", "verificacion_consolidada.csv")
SHA_NUMBERS_V1 <- "d8631bf8df9699a75f8efe2499d8d2d7846cc663ec4a08811bfc02e6f58f3cc6"  # commit 87d0608
FECHA_VERIFICACION <- "2026-10-23"

# -----------------------------------------------------------------------------
# 1. Resultados de los lotes
# -----------------------------------------------------------------------------
leer_lote <- function(n) {
  d <- utils::read.csv(file.path(RAIZ, "docs", "qa", sprintf("verificacion_lote_%d_resultados.csv", n)),
                       stringsAsFactors = FALSE, encoding = "UTF-8", colClasses = "character")
  data.frame(clave = d$clave, lote = n,
             script_verificador = sprintf("docs/qa/verificacion_lote_%d.R", n),
             valor_independiente = d$valor_independiente,
             coincide = if ("coincide" %in% names(d)) as.logical(d$coincide) else TRUE,
             definicion_clara = if ("definicion_clara" %in% names(d)) as.logical(d$definicion_clara) else TRUE,
             nota_verificador = d$nota, stringsAsFactors = FALSE)
}
lotes <- do.call(rbind, lapply(1:4, leer_lote))
stopifnot(nrow(lotes) == 210, !anyDuplicated(lotes$clave), !anyNA(lotes$coincide))

# Claves de los lotes 1 y 2 que el informe consolidado marcó con definición ambigua.
AMBIGUAS_L12 <- c("cluster_sizes", "fig04_highlight_iso3", "medage_2050_by_group", "q5_ratio_p90p10_peak_year",
                  "growth_2024_2050_by_group", "momentum_years_range", "share_rank_mc20", "yrs_medage30_40_recent")
stopifnot(all(AMBIGUAS_L12 %in% lotes$clave[lotes$lote %in% 1:2]))
lotes$definicion_clara[lotes$clave %in% AMBIGUAS_L12] <- FALSE

# -----------------------------------------------------------------------------
# 2. Decisiones de QA-stats por clave (acción en español, nota_qa en inglés)
# -----------------------------------------------------------------------------
# verificada = FALSE solo donde la comprobación no basta para afirmar la cifra.
dec <- function(clave, accion, nota_qa = NA_character_, verificada = TRUE) {
  data.frame(clave = clave, verificada = verificada, accion = accion, nota_qa = nota_qa, stringsAsFactors = FALSE)
}
decisiones <- rbind(
  # --- no verificada ---------------------------------------------------------
  dec("are_revision_pct",
      "NO se marca: cifra externa; la comprobación usó un valor de WPP2022 recordado (no verificado). Pendiente: cotejar con el archivo oficial WPP2022 (EAU, 2023)",
      paste("NOT VERIFIED: external figure (revision between WPP2022 and WPP2024). The WPP2022 file is not in the repository",
            "and the independent check (about +11.8 %) relied on a recalled WPP2022 value; a person must check it against",
            "the official WPP2022 file (UAE, 2023) before it is shown or voiced."), verificada = FALSE),
  # --- definiciones aclaradas en los scripts (la cifra no cambia) -----------
  dec("cluster_sizes",
      "def aclarada en R/04: z sobre todas las celdas país-año 1950-2023 y después medias por década; k-means nstart 50, semilla 2026",
      paste("Verified. Reproduced only with z-scores over all annual country-year cells, then decade means (now stated in def);",
            "z on decade means gives 51/52/51/7 and z by column 48/55/51/7 (98 % agreement).")),
  dec("medage_2050_by_group",
      "def aclarada en R/04: grupos = partición principal (misma estandarización que cluster_sizes)",
      paste("Verified. Depends on the feature standardization behind the groups (see cluster_sizes):",
            "with z on decade means, Fast movers 37.1 and Recent movers 24.4.")),
  dec("fig04_highlight_iso3",
      "def aclarada en R/02: 'mediano' = país con la duración más cercana a la mediana (n = 36 es par)",
      paste("Verified. n = 36 is even: COL (18.58 years, 18th) and ZAF (18.75, 19th) straddle the median (18.66);",
            "the rule takes the country closest to the median, COL (now stated in def).")),
  dec("q5_ratio_p90p10_peak_year",
      "def aclarada en R/04 (cuantil type 7). Recomendación al guion: no presentar el año exacto como preciso",
      paste("Verified with R's default quantile (type 7): peak in 2006 (26.9x). With quantile type 6 the peak year is 1999,",
            "so the exact year depends on the estimator: prefer 'in the 2000s' to an exact year on screen or in the narration.")),
  dec("q5_ratio_p90p10_peak",
      "def: se añade 'quantile type 7' por coherencia con q5_ratio_p90p10_peak_year"),
  dec("growth_2024_2050_by_group",
      "def aclarada en R/04: base = población al 1 de julio de 2024; total = Σ PopChange 2024-2050 (27 valores anuales)",
      paste("Verified with base = 1 July 2024 population and total = sum of PopChange over 2024-2050 (27 annual values),",
            "now stated in def; a 1 January 2024 base would give Recent movers 70.9 / 68.1 and Migration-led 37.5 / 41.2.")),
  dec("momentum_years_range",
      "def aclarada en R/04: peso = población al 1 de julio de 2023; cuantil ponderado = primer valor con peso acumulado ≥ p (sin interpolar)",
      paste("Verified: weights = 1 July 2023 population; weighted quantile = first value whose cumulative population",
            "share reaches p, no interpolation (now stated in def); midpoint interpolation gives 34.0-38.5.")),
  dec("share_rank_mc20",
      "def aclarada en R/03: crecimiento incluido con probabilidad 0,5; media geométrica sobre min-max (o rangos) con piso 0,01; con z se pasa a min-max; intervalo P5-P95",
      paste("Verified as a random statistic: an independent implementation gives 21.7-23.6 % across 10 seeds,",
            "inside the Wilson CI (16-29 %); 'one in five' is robust, the exact percentage is not.")),
  dec("yrs_medage30_40_recent",
      "Sin cambio de valor ni de nombre (lo usan storyboard y diapositivas, siempre como Fast movers); nota_qa advierte del nombre",
      paste("Verified. The value is for FAST movers (the key name says 'recent' for historical reasons; the def is explicit):",
            "never present it as Recent movers, whose Kaplan-Meier median would be 47 years.")),
  dec("lisa_cnmr_hh_fdr",
      "def aclarada en R/02: p de permutación condicional de un lado ('folded', estilo GeoDa), 999 permutaciones; BH al 5 % sobre 161 pruebas",
      paste("Verified with the one-sided ('folded', GeoDa-style) conditional-permutation p-value, now stated in def;",
            "a two-sided 2*min p-value would give 6 (KWT drops out).")),
  dec("r2_tfr_chg27_observed",
      "def aclarada en R/03: poblaciones al 1 de julio (la misma convención del comparador 2023→2050)",
      paste("Verified with 1 July populations (now stated in def); with 1 January populations the median would be 0.37",
            "and the maximum 0.51; the 0.88 comparator does not change.")),
  dec("region_vote_accuracy",
      "def y n aclarados en R/04: denominador 160 (Papúa Nueva Guinea es la única de su región SDG y no tiene voto)",
      paste("Verified: denominator 160 (Papua New Guinea is the only country >= 1 M in its SDG region and has no",
            "leave-one-out vote), now stated in def and n; over 161 it would read 0.770.")),
  dec("yrs_medage30_40_cohort_1990_2023",
      "def aclarada en R/04: 39 países cruzan 30 en 1990-2023; la mediana usa los 35 que llegan a 40 antes de 2100",
      paste("Verified: 39 countries first reach 30 in 1990-2023, but the median uses the 35 that also reach 40 by 2100",
            "(ARE, BHR, KWT and QAT do not), now stated in def; Kaplan-Meier with censoring at 2100 gives 25.")),
  dec("borderline_countries",
      "def aclarada en R/04: 500 submuestras del 80 % sin reemplazo, k-means nstart 20, etiquetas emparejadas (húngaro), semilla 2026",
      paste("Verified: same 7 countries (BOL and GTM are tied, so their order can swap). Random: 500 subsamples of 80 %",
            "with k-means nstart 20 (now stated in def).")),
  # --- verificadas con advertencia para el guion ----------------------------
  dec("jaccard_min",
      "Recomendación al guion y a las diapositivas: '≈ 0.8' o 'above 0.75'; el segundo decimal es ruido de Monte Carlo",
      paste("Verified (seed 2026 set just before resampling). The second decimal is Monte Carlo noise (0.77-0.83 across",
            "seeds 2027-2045): show it as about 0.8 or 'above 0.75', not as 0.78.")),
  dec("jaccard_max", "Ninguna (dentro de la tolerancia de Monte Carlo)",
      "Verified within Monte Carlo tolerance (independent 0.942 vs 0.949; tolerance 0.02)."),
  dec("r_tfr_decades_min", "Ninguna; nota_qa sobre el nombre de la clave",
      "Verified. The minimum (0.948) comes from life expectancy (1990s to 2000s), not from TFR (TFR minimum 0.951), despite the key name."),
  dec("recov_pc1", "Ninguna (diferencia solo en el límite inferior del IC por detalles del remuestreo)",
      "Verified point value; the independent block-bootstrap lower bound is 0.52 (re-standardizing in each replicate) vs 0.514."),
  dec("pc1_var", "Ninguna (diferencia mínima del IC por detalles del remuestreo)",
      "Verified point value; independent block-bootstrap CI [51.6; 62.5] vs [51.4; 62.6] (resampling details)."),
  dec("panel_ratio_between_within",
      "Recomendación: nunca mostrar el IC del cociente (inestable); usar la frase 'say'",
      paste("Verified point value (2.54). The block-bootstrap interval of this ratio is unstable (independent [-7.6; 14.3]",
            "vs [-9.2; 18.4]) because the within-country denominator's interval reaches 0: never show this interval.")),
  dec("cluster_medoids", "Ninguna (la def ya dice 'mediana coordenada a coordenada')",
      "Verified. Medoid = country closest to the coordinate-wise median of its group; a PAM-type medoid would give MDG instead of CMR for Recent movers."),
  dec("cluster_profile", "Ninguna",
      "Verified (maximum difference 0.00 after rounding). Medoids as in cluster_medoids; pct of world population uses the UN World aggregate as denominator."),
  dec("yr_fert_onset_lowmid", "Ninguna",
      "Verified: first year with S(t) <= 0.5 is 1984 (S = 0.5 exactly in 1984; survival's quantile() would print 1984.5)."),
  dec("yr_fert_onset_low", "Ninguna", "Verified (survival's quantile() would print 2000.5; first year with S(t) <= 0.5 is 2000)."),
  dec("hyp_file_date", "Pendiente (repo-ops / notebook-R): falta docs/hipotesis_preinscritas.sha256 ('make prereg')",
      "Verified (commit 2a0ab7b; file unchanged since). Pending: docs/hipotesis_preinscritas.sha256 ('make prereg') does not exist yet."),
  dec("meta_income_classification", "Ninguna (la etiqueta FY2027 no se puede comprobar desde el CSV)",
      paste("Verified against data/raw/wb_api_income_2026-10-22.csv (0 differences); the FY2027 vintage label comes",
            "from the file name and data/raw/README.md and cannot be checked from the CSV itself.")),
  dec("meta_wpp_version", "Ninguna (descriptiva)",
      "Verified file structure (Medium 1950-2101, 18 OtherVariants, supplement); the July 2024 release date cannot be checked from the CSV."),
  dec("rec_rows", "Ninguna para los números; los textos (mandatos, agencias) los revisa QA-ethics",
      "Verified numbers; the text cells (mandates, agencies, verbs) are wording, not numbers, and were not checked here."),
  dec("share_mig_high_2000_2023", "Ninguna",
      "Verified. GGY and JEY are 'Not classified' (the World Bank lists Channel Islands as CHI)."),
  dec("twins", "Ninguna (solo cosmético: en la cadena del lote la TFR de Esuatini salía con 4 decimales)", NA_character_),
  dec("lag_onset_lower_bound", "Ninguna; aviso al dueño del plan: §7.7 dice 105/108 y la cifra vigente es 106/109", NA_character_)
)
stopifnot(!anyDuplicated(decisiones$clave), all(decisiones$clave %in% lotes$clave))

# -----------------------------------------------------------------------------
# 3. Huellas y valor del notebook (numbers.json v1)
# -----------------------------------------------------------------------------
reg <- leer_numbers(RUTA_NUMBERS)
sha_actual <- digest::digest(file = RUTA_NUMBERS, algo = "sha256")
previa <- if (file.exists(RUTA_SALIDA)) utils::read.csv(RUTA_SALIDA, stringsAsFactors = FALSE, encoding = "UTF-8",
                                                        colClasses = "character") else NULL
es_v1 <- identical(sha_actual, SHA_NUMBERS_V1)
if (!es_v1 && is.null(previa)) {
  stop("figures/numbers.json ya no es la versión v1 verificada (sha256 ", substr(sha_actual, 1, 12),
       ") y no hay tabla previa: las huellas no se pueden fijar sin el archivo verificado.", call. = FALSE)
}
faltan <- setdiff(lotes$clave, names(reg))
if (length(faltan) > 0) stop("Claves verificadas que no están en numbers.json: ", paste(faltan, collapse = ", "), call. = FALSE)

# Valor legible (como en R/05 §7), con el IC si lo hay.
valor_legible <- function(e) {
  v <- e$value
  num <- is.numeric(v) && length(v) == 1 && !is.list(v)
  if (num) {
    txt <- tryCatch(formatear_cifra(v, e$fmt), error = function(err) format(v))
    if (!is.null(e$unit) && !is.na(e$unit) && nzchar(e$unit)) txt <- paste(txt, e$unit)
    if (!is.na(e$ci_low) && !is.na(e$ci_high)) {
      f <- if (is.na(e$fmt) || e$fmt == "text") "0.00" else e$fmt
      txt <- sprintf("%s · CI [%s; %s]", txt, formatear_cifra(e$ci_low, f), formatear_cifra(e$ci_high, f))
    }
    return(txt)
  }
  if (is.list(v) && !is.null(names(v)) && all(vapply(v, function(z) is.atomic(z) && length(z) <= 3, logical(1)))) {
    return(paste(sprintf("%s: %s", names(v), vapply(v, function(z) paste(z, collapse = ", "), character(1))), collapse = "; "))
  }
  if (is.list(v)) return(sprintf("<table, %d rows>", length(v)))
  paste(as.character(unclass(v)), collapse = ", ")
}

tabla <- merge(lotes, decisiones, by = "clave", all.x = TRUE, sort = FALSE)
tabla$verificada[is.na(tabla$verificada)] <- TRUE
tabla$accion[is.na(tabla$accion)] <- "Ninguna"
tabla$valor_notebook <- vapply(tabla$clave, function(k) valor_legible(reg[[k]]), character(1))
if (es_v1) {
  tabla$huella <- vapply(tabla$clave, function(k) huella_cifra(reg[[k]]), character(1))
  tabla$fecha_verificacion <- FECHA_VERIFICACION
  tabla$sha256_numbers_verificado <- SHA_NUMBERS_V1
} else {
  # archivo ya regenerado: se conservan huella, valor y fecha de la tabla previa
  i <- match(tabla$clave, previa$clave)
  if (anyNA(i)) stop("Claves nuevas sin huella previa: ", paste(tabla$clave[is.na(i)], collapse = ", "), call. = FALSE)
  tabla$huella <- previa$huella[i]
  tabla$valor_notebook <- previa$valor_notebook[i]
  tabla$fecha_verificacion <- previa$fecha_verificacion[i]
  tabla$sha256_numbers_verificado <- previa$sha256_numbers_verificado[i]
  message("numbers.json ya no es v1: se conservan las huellas de la tabla previa (", RUTA_SALIDA, ").")
}
tabla$pantalla <- vapply(tabla$clave, function(k) es_clave_pantalla(reg[[k]]), logical(1))
tabla <- tabla[order(tabla$lote, match(tabla$clave, lotes$clave)), c(
  "clave", "lote", "script_verificador", "valor_notebook", "valor_independiente", "coincide", "definicion_clara",
  "verificada", "accion", "nota_verificador", "nota_qa", "pantalla", "huella", "fecha_verificacion",
  "sha256_numbers_verificado")]

utils::write.csv(tabla, RUTA_SALIDA, row.names = FALSE, fileEncoding = "UTF-8", na = "")
cat(sprintf("Escrito %s: %d claves (lote 1 %d, lote 2 %d, lote 3 %d, lote 4 %d)\n", RUTA_SALIDA, nrow(tabla),
            sum(tabla$lote == 1), sum(tabla$lote == 2), sum(tabla$lote == 3), sum(tabla$lote == 4)))
cat(sprintf("Coinciden: %d · definición ambigua: %d · verificadas: %d · no verificadas: %s\n",
            sum(tabla$coincide), sum(!tabla$definicion_clara), sum(tabla$verificada),
            paste(tabla$clave[!tabla$verificada], collapse = ", ")))
cat(sprintf("Claves de pantalla/voz en la tabla: %d de %d\n", sum(tabla$pantalla), nrow(tabla)))
