#!/usr/bin/env Rscript
# =============================================================================
# utilidades.R
# Funciones de ayuda reutilizables por los demás scripts/notebook. La
# configuración (rutas, paletas, tema gráfico) vive en R/config.R; este
# archivo solo añade funciones que operan sobre esos datos.
# =============================================================================

suppressPackageStartupMessages(library(here))
source(here::here("R", "config.R"))

#' Carga la tabla de países lista para usar (data/processed/paises.parquet).
#' Si el parquet no existe (p.ej. primera vez, o se limpió por ser muy pesado
#' para versionarse) lo regenera corriendo 01_preparar_datos.R.
#'
#' @param solo_grandes si es TRUE, filtra a países con pob_1m == TRUE
#'   (umbral de >= 1 millón de habitantes en 2023; ver config.R).
#' @return un data.frame/tibble con 237 países x 1950-2100 (o 161 si solo_grandes).
cargar_paises <- function(solo_grandes = FALSE) {
  ruta <- file.path(RUTA_PROCESSED, "paises.parquet")
  if (!file.exists(ruta)) {
    message("paises.parquet no existe todavía; ejecutando R/01_preparar_datos.R ...")
    source(here::here("R", "01_preparar_datos.R"))
  }
  df <- arrow::read_parquet(ruta)
  if (solo_grandes) df <- df[df$pob_1m %in% TRUE, ]
  df
}

#' Carga los agregados ONU (regiones SDG, grupos de ingreso, mundo).
cargar_agregados <- function() {
  ruta <- file.path(RUTA_PROCESSED, "agregados.parquet")
  if (!file.exists(ruta)) {
    message("agregados.parquet no existe todavía; ejecutando R/01_preparar_datos.R ...")
    source(here::here("R", "01_preparar_datos.R"))
  }
  arrow::read_parquet(ruta)
}

#' Carga la tabla liviana país -> región/ingreso/continente (siempre
#' versionada, no requiere los CSV grandes de la ONU).
cargar_lookup_regiones <- function() {
  readr::read_csv(file.path(RUTA_PROCESSED, "lookup_regiones.csv"),
                   show_col_types = FALSE)
}

# Nota: `etiquetas_en()`, `theme_wpp()` y las paletas `PALETA_*` viven en
# config.R (se cargan arriba via source()); se re-exportan implícitamente al
# hacer source("R/utilidades.R") para no romper código que solo cargue este
# archivo.

invisible(TRUE)
