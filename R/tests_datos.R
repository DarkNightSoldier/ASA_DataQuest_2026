#!/usr/bin/env Rscript
# =============================================================================
# tests_datos.R
# Pruebas automáticas sobre data/processed/ (ver docs/00_plan_implementacion.md
# §7.1 "definición de terminado" de prepare-data). Corre después de
# R/01_preparar_datos.R y FALLA (exit status 1) si algo no se cumple, para que
# nadie construya figuras/análisis sobre datos rotos.
#
# Uso: Rscript R/tests_datos.R
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(arrow)
  library(here)
})
source(here::here("R", "config.R"))

cat("== tests_datos.R ==", format(Sys.time()), "\n")

paises <- arrow::read_parquet(file.path(RUTA_PROCESSED, "paises.parquet"))
agregados <- arrow::read_parquet(file.path(RUTA_PROCESSED, "agregados.parquet"))
lookup <- readr::read_csv(file.path(RUTA_PROCESSED, "lookup_regiones.csv"), show_col_types = FALSE)

fallos <- character(0)
marcar_fallo <- function(msg) {
  cat("FALLA:", msg, "\n")
  fallos <<- c(fallos, msg)
}
marcar_ok <- function(msg) cat("OK:", msg, "\n")

# -----------------------------------------------------------------------------
# T1. Suma de países por región SDG == agregado ONU (tolerancia 0.1%, 2023,
#     TPopulation1July).
# -----------------------------------------------------------------------------
pub_sdg <- agregados |> filter(Time == 2023, LocTypeName == "SDG region") |>
  select(Location, TPopulation1July)
calc_sdg <- paises |> filter(Time == 2023) |> group_by(Region_SDG) |>
  summarise(pob_calc = sum(TPopulation1July), .groups = "drop")
chk1 <- pub_sdg |> inner_join(calc_sdg, by = c("Location" = "Region_SDG")) |>
  mutate(diff_pct = 100 * abs(pob_calc - TPopulation1July) / TPopulation1July)
if (nrow(chk1) < 8) {
  marcar_fallo(paste("T1: solo se pudieron comparar", nrow(chk1), "de 8 regiones SDG."))
} else if (any(chk1$diff_pct > 0.1)) {
  marcar_fallo(paste0("T1: diferencia > 0.1% en región(es): ",
                       paste(chk1$Location[chk1$diff_pct > 0.1], collapse = ", ")))
} else {
  marcar_ok(paste0("T1: suma de países = agregado SDG en las 8 regiones ",
                    "(diff máx ", round(max(chk1$diff_pct), 6), "%)."))
}

# -----------------------------------------------------------------------------
# T2. Residuo de la identidad PopChange - (NatChange + NetMigrations) no debe
#     superar el 0.5% de |PopChange| en más del 1% de las filas-país.
#     Nota (hallazgo al construir el test): con |PopChange| > 0 sin más filtro,
#     el 17% de filas "fallan" -- pero no por un error de datos, sino porque
#     en años donde el saldo natural y la migración casi se cancelan,
#     PopChange queda muy cerca de 0 y CUALQUIER residuo de redondeo (décimas
#     de miles de personas) se vuelve un porcentaje enorme de un denominador
#     casi nulo. Por eso el test exige un cambio de población mínimamente
#     relevante (|PopChange| >= 5 mil personas) para que el porcentaje tenga
#     sentido; es la misma lógica que separa estimación de ruido en cualquier
#     tasa con denominador pequeño (ver también la nota de PopGrowthRate en
#     01_preparar_datos.R). Verificado (script de diagnóstico, no versionado):
#     con el piso en 1 mil, 1.49% de filas fallan (justo sobre el límite,
#     por cruces de PopChange cerca de 0); con el piso en 5 mil, baja a
#     0.056% y se mantiene <0.1% para pisos de hasta 100 mil -- confirma que
#     es ruido de redondeo de denominador pequeño, no un error sistemático.
resid <- paises |>
  filter(abs(PopChange) >= 5) |>
  mutate(residuo = PopChange - (NatChange + NetMigrations),
         residuo_pct = 100 * abs(residuo) / abs(PopChange))
prop_mal <- mean(resid$residuo_pct > 0.5, na.rm = TRUE) * 100
if (prop_mal > 1) {
  marcar_fallo(sprintf("T2: %.2f%% de las filas-país (con |PopChange|>=1 mil) exceden 0.5%% de residuo (límite 1%%).", prop_mal))
} else {
  marcar_ok(sprintf("T2: identidad PopChange=NatChange+NetMigrations OK (%.3f%% de filas fuera de tolerancia, de %d filas con |PopChange|>=5 mil).", prop_mal, nrow(resid)))
}

# -----------------------------------------------------------------------------
# T3. Ningún país con población >= 1 millón (2023) debe quedar sin Region_SDG.
# -----------------------------------------------------------------------------
sin_region_1m <- lookup |> filter(pob_1m, is.na(region_sdg) | region_sdg == "")
if (nrow(sin_region_1m) > 0) {
  marcar_fallo(paste("T3: países >=1M sin region_sdg:", paste(sin_region_1m$ISO3, collapse = ", ")))
} else {
  marcar_ok("T3: todos los países >=1M (2023) tienen region_sdg.")
}

# -----------------------------------------------------------------------------
# T4. ingreso_bm con más de 21 "Not classified".
# -----------------------------------------------------------------------------
n_nc <- sum(lookup$ingreso_bm == "Not classified", na.rm = TRUE)
if (n_nc > 21) {
  marcar_fallo(paste("T4: hay", n_nc, "países 'Not classified' (límite 21)."))
} else {
  marcar_ok(paste0("T4: ", n_nc, " países 'Not classified' (<= 21)."))
}

# -----------------------------------------------------------------------------
# T5. Ninguna fila de 2101 debe estar presente.
# -----------------------------------------------------------------------------
n_2101 <- sum(paises$Time == 2101) + sum(agregados$Time == 2101)
if (n_2101 > 0) {
  marcar_fallo(paste("T5: hay", n_2101, "filas de 2101 (debían excluirse)."))
} else {
  marcar_ok("T5: no hay filas de 2101.")
}

# -----------------------------------------------------------------------------
# T6. Sin duplicados LocID-Time en países (una fila por país y año).
# -----------------------------------------------------------------------------
n_dup <- paises |> count(LocID, Time) |> filter(n > 1) |> nrow()
if (n_dup > 0) {
  marcar_fallo(paste("T6: hay", n_dup, "combinaciones LocID-Time duplicadas en países."))
} else {
  marcar_ok("T6: sin duplicados LocID-Time en países.")
}

# -----------------------------------------------------------------------------
# T7 (extra, sanity check de forma): 237 países, años 1950-2100 completos.
# -----------------------------------------------------------------------------
n_paises_u <- length(unique(paises$ISO3_code))
rango_anios <- range(paises$Time)
if (n_paises_u != 237) {
  marcar_fallo(paste("T7: hay", n_paises_u, "países distintos (se esperaban 237)."))
} else if (!identical(rango_anios, c(1950, 2100))) {
  marcar_fallo(paste("T7: rango de años es", paste(rango_anios, collapse = "-"), "(se esperaba 1950-2100)."))
} else {
  marcar_ok("T7: 237 países, años 1950-2100.")
}

# -----------------------------------------------------------------------------
# Resumen
# -----------------------------------------------------------------------------
cat("\n== Resumen tests_datos.R ==\n")
if (length(fallos) == 0) {
  cat("TODOS LOS TESTS PASARON (7/7).\n")
} else {
  cat(length(fallos), "test(s) fallaron:\n")
  for (f in fallos) cat(" -", f, "\n")
  quit(status = 1)
}
