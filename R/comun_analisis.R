#!/usr/bin/env Rscript
# =============================================================================
# comun_analisis.R
# Punto de entrada COMÚN para los agentes de análisis (Q1, Q2, Q3) y el
# notebook. Un solo `source()` deja listo:
#   * config.R + utilidades.R (rutas, semilla, paletas v1, theme_wpp(),
#     etiquetas_en(), cargar_paises(), ...) — se REUTILIZAN, no se duplican;
#   * incertidumbre.R (bootstrap por bloques, Wilson, registro numbers.json);
#   * las constantes v2 del plan que todavía no estén en config.R (solo se
#     definen si faltan: cuando prepare-data las añada a config.R, mandan esas);
#   * los datos procesados ya cargados (países, agregados, lookup) con tres
#     columnas de conveniencia en minúscula (`subregion`, `region_sdg`,
#     `ingreso`) y la etiqueta de periodo en inglés (`periodo_en`);
#   * la muestra principal (161 países >= 1 M en 2023) y la completa (237);
#   * funciones de conveniencia (cortes por año, ventanas, tipos de palanca,
#     agregados regionales, nombres de países, guardado de figuras).
#
# Uso (desde cualquier carpeta DENTRO del repo, p. ej. notebook/):
#   source(here::here("R", "comun_analisis.R"))
#
# Decisiones documentadas (ASA 2022 B.2, B.4; plan analítico §3):
#   D1. País = fila con ISO3_code no vacío (237). Nunca agregados en análisis
#       entre países; los agregados solo para líneas regionales.
#   D2. Muestra principal = pob_1m (>= 1 000 000 hab. en 2023; 161 países)
#       para correlaciones, modelos, PCA, índice, clustering, panel y Moran;
#       los 237 para mapas y conteos.
#   D3. Estimaciones = Time <= 2023; proyección Medium = Time >= 2024. Siempre
#       separadas y etiquetadas ("Estimate" / "UN medium projection"); ninguna
#       ventana de cálculo cruza 2023/24 (`verificar_ventana()` lo impide).
#   D4. `subregion`: subregión M49 de `Subregion`; los 5 países de Northern
#       America (USA, CAN, BMU, GRL, SPM; ParentID 918) tienen `Subregion` = NA
#       en paises.parquet porque el LocID 918 no aparece en el archivo de
#       indicadores (ver 01_preparar_datos.R §4). Aquí se rellenan como
#       "Northern America" para que sean SU PROPIO bloque en el bootstrap por
#       subregión (así hay 22 bloques con los 237 y 20 con los 161 >= 1 M, como
#       en el memo espacial, que usaba ParentID).
#   D5. `ingreso`: World Bank FY2027 (`Ingreso`), aplicado a todos los años
#       ("today's income groups"); factor ordenado de bajo a alto. "Not
#       classified" (21 áreas; la única >= 1 M es Taiwán) se excluye de las
#       comparaciones por ingreso y se dice en el pie (PIE-4).
#   D6. Semilla 2026 y RNGkind Mersenne-Twister / Inversion / Rejection.
#
# Convención: código y comentarios en español; textos visibles en inglés.
# =============================================================================

suppressPackageStartupMessages({
  library(here)
  library(dplyr)
  library(tidyr)
  library(arrow)
  library(readr)
})

source(here::here("R", "utilidades.R"))      # incluye config.R
source(here::here("R", "incertidumbre.R"))

RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(SEMILLA)

# =============================================================================
# 1. Constantes del plan
# =============================================================================

# --- 1.1 Años y umbrales -----------------------------------------------------
ANIO_BASE <- if (exists("ANIO_BASE_PALANCA")) ANIO_BASE_PALANCA else 2023  # año base de la palanca
ANIO_FIN_ESTIMACION <- ANIO_CORTE_ESTIMACION                               # 2023 (config.R)
ANIO_INICIO_PROYECCION <- ANIO_FIN_ESTIMACION + 1                          # 2024
ANIO_INICIO_DATOS <- 1950
UMBRAL_1M <- UMBRAL_MICROESTADO                                            # 1e6 hab. en 2023 (config.R)
ANIOS_SENS_PRECOVID <- 2017:2019                                           # sensibilidad pre-COVID

# Ventanas de sensibilidad del año base (plan §3 y §6). Formato del plan:
# c(a, b) = rango a..b. Solo se define si config.R aún no la trae.
if (!exists("VENTANAS_SENS")) VENTANAS_SENS <- list(c(2017, 2019), 2021, 2022, c(2021, 2023))
# Las mismas ventanas con los años expandidos y nombre legible:
VENTANAS_SENS_ANIOS <- list(`2017-2019` = 2017:2019, `2021` = 2021, `2022` = 2022,
                            `2021-2023` = 2021:2023)

TFR_REEMPLAZO <- 2.1                         # umbral principal de reemplazo
UMBRALES_TFR_SENS <- c(2.0, 2.1, 2.2)        # sensibilidad (y NRR < 1 aparte)

# --- 1.2 Constantes v2 (plan de implementación §6); solo si faltan ----------
if (!exists("GOLFO")) GOLFO <- c("ARE", "QAT", "KWT", "BHR", "OMN", "SAU")
if (!exists("PERIODO_PANEL")) PERIODO_PANEL <- 5
if (!exists("REZAGOS_PANEL")) REZAGOS_PANEL <- 0:4
if (!exists("B_BOOT")) B_BOOT <- 2000                 # BCa y bloques (cifras en pantalla)
if (!exists("B_BOOT_PCA")) B_BOOT_PCA <- 1000         # PCA (percentil)
if (!exists("B_PERM")) B_PERM <- 999                  # permutaciones (Moran)
if (!exists("K_VECINOS")) K_VECINOS <- 5
if (!exists("LAMBDA_FDA")) LAMBDA_FDA <- 10
if (!exists("UMBRAL_INICIO")) UMBRAL_INICIO <- 0.9    # regla de Princeton (x <= 0.9 máx. previo)
if (!exists("TFR_ELEGIBLE_1950")) TFR_ELEGIBLE_1950 <- 5
if (!exists("ANIO_BASE_PALANCA")) ANIO_BASE_PALANCA <- ANIO_BASE
if (!exists("COLUMNAS_PI_VALIDAS")) {
  # Lista blanca de columnas válidas en las filas PI de OtherVariants (T0).
  COLUMNAS_PI_VALIDAS <- c("TPopulation1July", "TFR", "LEx", "LExMale", "LExFemale", "CNMR",
                           "NetMigrations", "CBR", "CDR", "IMR", "Births", "Deaths", "NatChange",
                           "PopGrowthRate")
}
B_BOOT_BLOQUES <- B_BOOT                      # B para "block bootstrap by subregion" en pantalla
ISO_NORTEAMERICA <- c("USA", "CAN", "BMU", "GRL", "SPM")   # ParentID 918 (ver D4)

if (!exists("RUTA_WPP_OTHERVARIANTS")) {
  RUTA_WPP_OTHERVARIANTS <- Sys.getenv(
    "WPP_OTHERVARIANTS",
    file.path(dirname(RUTA_RAIZ), "WPP2024_Demographic_Indicators_OtherVariants_csv.gz")
  )
}

# --- 1.3 Rutas de salida -----------------------------------------------------
RUTA_FIG_REVIEW   <- file.path(RUTA_FIGURAS, "review")
RUTA_FIG_STATIC   <- file.path(RUTA_FIGURAS, "static")
RUTA_FIG_ANIMATED <- file.path(RUTA_FIGURAS, "animated")
RUTA_FIG_APPENDIX <- file.path(RUTA_FIGURAS, "appendix")
RUTA_NOTEBOOK     <- file.path(RUTA_RAIZ, "notebook")
RUTA_NUMBERS      <- file.path(RUTA_FIGURAS, "numbers.json")
# Recomendado: cada agente escribe su parte aquí y luego combinar_numbers().
RUTA_NUMBERS_PARTES <- file.path(RUTA_FIGURAS, "numbers_parts")
for (.d in c(RUTA_FIG_REVIEW, RUTA_FIG_STATIC, RUTA_FIG_ANIMATED, RUTA_FIG_APPENDIX, RUTA_NOTEBOOK)) {
  dir.create(.d, recursive = TRUE, showWarnings = FALSE)
}
rm(.d)

# --- 1.4 Niveles y etiquetas en inglés --------------------------------------
NIVELES_INGRESO <- c("Low income", "Lower middle income", "Upper middle income", "High income")
NIVELES_INGRESO_TODOS <- c(NIVELES_INGRESO, "Not classified")
ETIQUETAS_INGRESO_CORTAS_EN <- c(
  "Low income" = "Low", "Lower middle income" = "Lower-middle",
  "Upper middle income" = "Upper-middle", "High income" = "High",
  "Not classified" = "No WB income group"
)
ETIQUETA_INGRESO_FUENTE <- "today's income groups (World Bank FY2027), applied to all years"

REGIONES_SDG <- names(PALETA_REGION_SDG)      # las 8 regiones SDG (orden de config.R)
ETIQUETAS_REGION_CORTAS_EN <- c(
  "Sub-Saharan Africa"                            = "Sub-Saharan Africa",
  "Northern Africa and Western Asia"              = "N. Africa & W. Asia",
  "Central and Southern Asia"                     = "Central & S. Asia",
  "Eastern and South-Eastern Asia"                = "E. & SE Asia",
  "Latin America and the Caribbean"               = "Latin America & Caribbean",
  "Oceania (excluding Australia and New Zealand)" = "Oceania (excl. AUS/NZ)",
  "Australia/New Zealand"                         = "Australia/New Zealand",
  "Europe and Northern America"                   = "Europe & N. America"
)

ETIQUETA_ESTIMACION <- "Estimate"
ETIQUETA_PROYECCION <- "UN medium projection"

# Tipos de palanca 2023 con A y B separados (plan analítico §3):
#   A NatChange > 0, NetMigrations > 0,  PopChange > 0
#   B NatChange > 0, NetMigrations <= 0, PopChange > 0
#   C NatChange < 0, PopChange > 0
#   D NatChange < 0, PopChange < 0
#   E NatChange > 0, PopChange < 0
# En pantalla A y B se funden en "growing from births" (mismo azul).
ETIQUETAS_PALANCA_EN <- c(
  A = "Growing from births (plus net arrivals)",
  B = "Growing from births (no net arrivals)",
  AB = "Growing from births",
  C = "Growing only through net arrivals",
  D = "Shrinking: deaths > births",
  E = "Shrinking: more leave than arrive",
  small = "Small states (< 1 M people)",
  nodata = "No data"
)
DEF_PALANCA_EN <- "Lever type = which term of the balance dominates today — not a stage of development"

# --- 1.5 Paletas v2 (plan de implementación §6; sin verde/rojo) --------------
# Colores con significado fijo en TODO el vídeo:
COLOR_NACIMIENTOS <- "#0072B2"   # natural change / A-B "growing from births"
COLOR_MIGRACION   <- "#56B4E9"   # net migration / C "only through net arrivals"
COLOR_DEFUNCIONES <- "#E69F00"   # D "deaths > births" (y Q5 en fig05)
COLOR_EMIGRACION  <- "#CC79A7"   # E "more leave than arrive"
COLOR_SIN_DATOS   <- "#999999"   # small states / no data
PALETA_PALANCA_V2 <- c(A = COLOR_NACIMIENTOS, B = COLOR_NACIMIENTOS, AB = COLOR_NACIMIENTOS,
                       C = COLOR_MIGRACION, D = COLOR_DEFUNCIONES, E = COLOR_EMIGRACION,
                       small = COLOR_SIN_DATOS, nodata = COLOR_SIN_DATOS)
# Misma paleta con las etiquetas en inglés como nombres (para scale_*_manual):
PALETA_PALANCA_V2_EN <- setNames(PALETA_PALANCA_V2[c("AB", "C", "D", "E", "small")],
                                 ETIQUETAS_PALANCA_EN[c("AB", "C", "D", "E", "small")])
PALETA_COMPONENTES_V2 <- c("Natural change (births minus deaths)" = COLOR_NACIMIENTOS,
                           "Net migration" = COLOR_MIGRACION)

# Grupos de trayectoria v2 (Tol). Si config.R ya trae la versión v2, se usa esa.
if (exists("PALETA_GRUPO_TRAYECTORIA") && "Recent movers" %in% names(PALETA_GRUPO_TRAYECTORIA)) {
  PALETA_GRUPOS_V2 <- PALETA_GRUPO_TRAYECTORIA
} else {
  PALETA_GRUPOS_V2 <- c("Early movers" = "#332288", "Fast movers" = "#117733",
                        "Recent movers" = "#DDCC77", "Migration-led" = "#88CCEE")
}
NOMBRES_GRUPO_PROHIBIDOS <- c("Late movers", "Migration-boosted")   # nunca en pantalla

# Regla de nombres de grupo v2 (plan de implementación §6). config.R todavía
# trae la v1 (`nombrar_grupo()`, con "Late movers"/"Migration-boosted"): esta
# versión v2 es la que debe usarse hasta que prepare-data actualice config.R.
nombrar_grupo_v2 <- function(cnmr_mediana_2000_23, anio_mediano_tfr_bajo_4,
                             mayoria_bajo_4_en_1950 = FALSE) {
  if (isTRUE(cnmr_mediana_2000_23 > 10)) return("Migration-led")
  if (isTRUE(anio_mediano_tfr_bajo_4 < 1960) || isTRUE(mayoria_bajo_4_en_1950)) return("Early movers")
  if (is.na(anio_mediano_tfr_bajo_4) || isTRUE(anio_mediano_tfr_bajo_4 > 1995)) return("Recent movers")
  "Fast movers"
}

# --- 1.6 Badges (pies de figura; plan §6 v2 + 04_etica §3.3) -----------------
if (!exists("BADGES")) {
  BADGES <- c(
    "PIE-0" = "UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey)",
    "PIE-1" = "UN WPP 2024 · estimates, 2023 · all 237 countries & areas, each counted once · descriptive, not causal",
    "PIE-2" = "UN WPP 2024 · UN SDG-region aggregates (population-weighted) · estimates ≤ 2023, UN medium projection ≥ 2024 dashed",
    "PIE-3" = "UN WPP 2024 · 161 countries ≥ 1 M people, 2023 · exploratory, not causal · intervals: block bootstrap by UN subregion",
    "PIE-4" = "UN WPP 2024 + World Bank FY2027 income groups (2025 GNI), applied to all years",
    "PIE-5" = "UN WPP 2024 · medium = mean (fertility, life expectancy) or median (migration) of UN probabilistic trajectories · bands: UN 80 % / 95 % prediction intervals, not additive across countries",
    "PIE-6" = "Net migration = arrivals − departures, often a census residual — the least-measured component"
  )
}
if (!exists("badge")) {
  #' Devuelve el texto de uno o varios badges unidos por salto de línea.
  #' @examples badge("PIE-0", "PIE-3")
  badge <- function(...) {
    ids <- c(...)
    falt <- setdiff(ids, names(BADGES))
    if (length(falt) > 0) stop("Badge desconocido: ", paste(falt, collapse = ", "), call. = FALSE)
    paste(BADGES[ids], collapse = "\n")
  }
}

# =============================================================================
# 2. Datos procesados (se cargan una vez al hacer source)
# =============================================================================

.agregar_columnas_comunes <- function(df) {
  df |>
    mutate(
      subregion = dplyr::coalesce(
        .data$Subregion,
        dplyr::if_else(.data$ISO3_code %in% ISO_NORTEAMERICA, "Northern America", NA_character_)
      ),
      region_sdg = .data$Region_SDG,
      ingreso = factor(.data$Ingreso, levels = NIVELES_INGRESO_TODOS),
      periodo_en = factor(dplyr::if_else(.data$Time <= ANIO_FIN_ESTIMACION,
                                         ETIQUETA_ESTIMACION, ETIQUETA_PROYECCION),
                          levels = c(ETIQUETA_ESTIMACION, ETIQUETA_PROYECCION))
    )
}

# Panel completo de países (237 x 1950-2100), con las columnas de conveniencia.
datos_paises <- cargar_paises() |>
  filter(!is.na(.data$ISO3_code), .data$ISO3_code != "", .data$Time <= ANIO_MAX_VALIDO) |>
  .agregar_columnas_comunes()

# Agregados ONU (mundo, regiones SDG, grupos de ingreso ONU, subregiones...).
datos_agregados <- cargar_agregados() |>
  mutate(periodo_en = factor(dplyr::if_else(.data$Time <= ANIO_FIN_ESTIMACION,
                                            ETIQUETA_ESTIMACION, ETIQUETA_PROYECCION),
                             levels = c(ETIQUETA_ESTIMACION, ETIQUETA_PROYECCION)))
datos_regiones_sdg <- arrow::read_parquet(file.path(RUTA_PROCESSED, "regiones_sdg.parquet"))
datos_ingreso_onu  <- arrow::read_parquet(file.path(RUTA_PROCESSED, "grupos_ingreso_onu.parquet"))
diccionario_variables <- readr::read_csv(file.path(RUTA_PROCESSED, "diccionario_variables.csv"),
                                         show_col_types = FALSE)
lookup_regiones <- cargar_lookup_regiones() |>
  mutate(subregion = dplyr::coalesce(
    .data$subregion,
    dplyr::if_else(.data$ISO3 %in% ISO_NORTEAMERICA, "Northern America", NA_character_)
  ))

# --- 2.1 Muestras ------------------------------------------------------------
.base_2023 <- datos_paises |> filter(.data$Time == ANIO_BASE)
iso_muestra_completa <- sort(unique(.base_2023$ISO3_code))                  # 237
iso_muestra_1m <- sort(unique(.base_2023$ISO3_code[.base_2023$pob_1m %in% TRUE]))  # 161
N_PAISES <- length(iso_muestra_completa)
N_PAISES_1M <- length(iso_muestra_1m)
N_SUBREGIONES <- length(unique(.base_2023$subregion))
N_SUBREGIONES_1M <- length(unique(.base_2023$subregion[.base_2023$pob_1m %in% TRUE]))
UNIVERSO_237 <- sprintf("%d countries and areas", N_PAISES)
UNIVERSO_1M  <- sprintf("%d countries ≥ 1 M", N_PAISES_1M)

# --- 2.2 Comprobaciones de integridad (paran si los datos cambiaron) ---------
.chk <- function(cond, msg) if (!isTRUE(cond)) stop("comun_analisis.R: ", msg, call. = FALSE)
.chk(N_PAISES == 237, sprintf("se esperaban 237 países y áreas en %d, hay %d.", ANIO_BASE, N_PAISES))
.chk(N_PAISES_1M == 161, sprintf("se esperaban 161 países >= 1 M, hay %d.", N_PAISES_1M))
.chk(!anyNA(.base_2023$subregion), "hay países sin subregión (revisar D4).")
.chk(N_SUBREGIONES_1M == 20, sprintf("se esperaban 20 subregiones con países >= 1 M, hay %d.", N_SUBREGIONES_1M))
.chk(all(.base_2023$ParentID[.base_2023$ISO3_code %in% ISO_NORTEAMERICA] == 918),
     "los países de Northern America ya no tienen ParentID 918 (revisar D4).")
.chk(!anyNA(.base_2023$region_sdg), "hay países sin región SDG.")
.chk(!anyNA(.base_2023$ingreso), "hay países con un grupo de ingreso fuera de NIVELES_INGRESO_TODOS.")
.chk(all(datos_paises$es_estimacion == (datos_paises$Time <= ANIO_FIN_ESTIMACION)),
     "es_estimacion no coincide con Time <= 2023.")
.chk(!any(duplicated(datos_paises[, c("ISO3_code", "Time")])), "hay país-años duplicados.")
rm(.base_2023, .chk)

# =============================================================================
# 3. Funciones de conveniencia
# =============================================================================

# Columnas de identificación que acompañan a todo corte por país.
COLUMNAS_ID <- c("ISO3_code", "ISO2_code", "LocID", "Location", "subregion", "region_sdg",
                 "ingreso", "Continente", "pob_1m", "pob_2023_miles")

# Filtra por periodo (todo / estimacion <= 2023 / proyeccion >= 2024).
.filtrar_periodo <- function(df, periodo) {
  periodo <- match.arg(periodo, c("todo", "estimacion", "proyeccion"))
  switch(periodo,
         todo = df,
         estimacion = df |> filter(.data$Time <= ANIO_FIN_ESTIMACION),
         proyeccion = df |> filter(.data$Time >= ANIO_INICIO_PROYECCION))
}

#' Panel de los 161 países >= 1 M (muestra principal de modelos).
#' @param anios años a conservar (NULL = todos).
#' @param periodo "todo", "estimacion" (<= 2023) o "proyeccion" (>= 2024).
paises_1m <- function(anios = NULL, periodo = "todo", datos = datos_paises) {
  out <- datos |> filter(.data$ISO3_code %in% iso_muestra_1m)
  if (!is.null(anios)) out <- out |> filter(.data$Time %in% anios)
  .filtrar_periodo(out, periodo)
}

#' Panel de los 237 países y áreas (mapas, conteos y sensibilidad).
paises_todos <- function(anios = NULL, periodo = "todo", datos = datos_paises) {
  out <- datos
  if (!is.null(anios)) out <- out |> filter(.data$Time %in% anios)
  .filtrar_periodo(out, periodo)
}

#' Corte transversal: una fila por país en un año.
#' @param anio año (2023 por defecto).
#' @param muestra "1m" (161) o "completa" (237).
#' @param vars variables a conservar además de las de identificación (NULL = todas).
corte_anio <- function(anio = ANIO_BASE, muestra = c("1m", "completa"), vars = NULL) {
  muestra <- match.arg(muestra)
  if (!(anio %in% datos_paises$Time)) stop("Año fuera de 1950-2100: ", anio, call. = FALSE)
  df <- if (muestra == "1m") paises_1m(anios = anio) else paises_todos(anios = anio)
  if (!is.null(vars)) {
    falt <- setdiff(vars, names(df))
    if (length(falt) > 0) stop("Variables inexistentes: ", paste(falt, collapse = ", "), call. = FALSE)
    df <- df |> select(any_of(c(COLUMNAS_ID, "Time", "es_estimacion", "periodo_en")), all_of(vars))
  }
  df
}

#' Para con error si una ventana de años mezcla estimaciones y proyecciones
#' (regla ASA del plan §3: ningún estadístico cruza 2023/24).
verificar_ventana <- function(anios) {
  if (min(anios) <= ANIO_FIN_ESTIMACION && max(anios) >= ANIO_INICIO_PROYECCION) {
    stop(sprintf("La ventana %d-%d cruza 2023/2024 (estimación vs proyección): sepárala.",
                 min(anios), max(anios)), call. = FALSE)
  }
  invisible(TRUE)
}

#' Resume variables por país en una ventana de años (p. ej. 2017-2019).
#' @param anios vector de años (no puede cruzar 2023/24).
#' @param vars variables numéricas.
#' @param fun función de resumen (mean por defecto; usar sum para personas).
#' @param muestra "completa" (237) o "1m" (161).
#' @return una fila por país con COLUMNAS_ID, `ventana` y las variables.
resumen_ventana <- function(anios, vars, fun = mean, muestra = c("completa", "1m")) {
  muestra <- match.arg(muestra)
  verificar_ventana(anios)
  base <- if (muestra == "1m") paises_1m(anios = anios) else paises_todos(anios = anios)
  base |>
    group_by(across(any_of(COLUMNAS_ID))) |>
    summarise(n_anios = dplyr::n(), across(all_of(vars), \(x) fun(x, na.rm = TRUE)), .groups = "drop") |>
    mutate(ventana = if (length(anios) == 1) as.character(anios) else paste0(min(anios), "-", max(anios)),
           .after = "pob_2023_miles")
}

#' Clasifica el tipo de palanca (A-E, con A y B separados).
#' Ceros exactos (sin crecimiento natural o sin cambio) quedan NA y se cuentan aparte.
#' @return vector de "A", "B", "C", "D", "E" o NA.
clasificar_palanca <- function(nat, mig, pop) {
  dplyr::case_when(
    nat > 0 & mig > 0 & pop > 0  ~ "A",
    nat > 0 & mig <= 0 & pop > 0 ~ "B",
    nat < 0 & pop > 0            ~ "C",
    nat < 0 & pop < 0            ~ "D",
    nat > 0 & pop < 0            ~ "E",
    TRUE                         ~ NA_character_
  )
}

#' Tipo de palanca por país en un año o ventana (sumas de personas).
#' @param anios ANIO_BASE (2023) o una ventana de VENTANAS_SENS_ANIOS.
#' @param muestra "completa" (237, mapas y conteos) o "1m".
#' @return una fila por país con NatChange, NetMigrations, PopChange (sumas en
#'   miles en la ventana), `tipo` (A-E) y `tipo_ab` (A y B fundidos en "AB").
tipo_palanca_ventana <- function(anios = ANIO_BASE, muestra = c("completa", "1m")) {
  muestra <- match.arg(muestra)
  resumen_ventana(anios, c("NatChange", "NetMigrations", "PopChange"), fun = sum, muestra = muestra) |>
    mutate(tipo = clasificar_palanca(.data$NatChange, .data$NetMigrations, .data$PopChange),
           tipo_ab = dplyr::if_else(.data$tipo %in% c("A", "B"), "AB", .data$tipo))
}

#' Agregados ONU de las 8 regiones SDG (para líneas regionales; nunca para
#' análisis entre países). Excluye el agregado combinado 5502.
agregados_region <- function(anios = NULL, periodo = "todo") {
  out <- datos_agregados |>
    filter(.data$LocTypeName == "SDG region", .data$Location %in% REGIONES_SDG) |>
    mutate(region_sdg = factor(.data$Location, levels = REGIONES_SDG))
  if (!is.null(anios)) out <- out |> filter(.data$Time %in% anios)
  .filtrar_periodo(out, periodo)
}

#' Agregado mundial ONU.
agregado_mundo <- function(anios = NULL, periodo = "todo") {
  out <- datos_agregados |> filter(.data$Location == "World")
  if (!is.null(anios)) out <- out |> filter(.data$Time %in% anios)
  .filtrar_periodo(out, periodo)
}

#' Agregados ONU por grupo de ingreso. OJO: usan la clasificación del Banco
#' Mundial de MAYO 2024, no la FY2027 del proyecto: solo como SENSIBILIDAD
#' (H1: 64,0 %), nunca para validar las sumas FY2027 (plan §3, V14).
agregados_ingreso_onu <- function(anios = NULL, periodo = "todo") {
  equiv <- c("Low-income countries" = "Low income", "Lower-middle-income countries" = "Lower middle income",
             "Upper-middle-income countries" = "Upper middle income", "High-income countries" = "High income")
  out <- datos_agregados |>
    filter(.data$Location %in% names(equiv)) |>
    mutate(ingreso = factor(unname(equiv[.data$Location]), levels = NIVELES_INGRESO),
           nota = "UN income aggregates (World Bank classification of May 2024) - sensitivity only")
  if (!is.null(anios)) out <- out |> filter(.data$Time %in% anios)
  .filtrar_periodo(out, periodo)
}

#' Nombre WPP (columna Location) de uno o varios ISO3: "Türkiye", "Viet Nam",
#' "Republic of Korea", "Kosovo (under UNSC res. 1244)", ...
nombre_pais <- function(iso3) {
  tabla <- unique(datos_paises[, c("ISO3_code", "Location")])
  out <- tabla$Location[match(iso3, tabla$ISO3_code)]
  if (anyNA(out)) warning("ISO3 sin nombre: ", paste(iso3[is.na(out)], collapse = ", "), call. = FALSE)
  out
}

#' "Estimate" (<= 2023) o "UN medium projection" (>= 2024).
etiqueta_periodo <- function(anio) {
  ifelse(anio <= ANIO_FIN_ESTIMACION, ETIQUETA_ESTIMACION, ETIQUETA_PROYECCION)
}

#' TRUE si el país es del Golfo (sensibilidades "sin Golfo").
es_golfo <- function(iso3) iso3 %in% GOLFO

#' Factor de ingreso ordenado; por defecto sin "Not classified" (-> NA).
orden_ingreso <- function(x, incluir_sin_grupo = FALSE) {
  factor(as.character(x), levels = if (incluir_sin_grupo) NIVELES_INGRESO_TODOS else NIVELES_INGRESO)
}

#' Guarda una figura ggplot con el estándar del proyecto (ragg, 1920x1080,
#' res 144) y, opcionalmente, una copia 960x540 ("_960" en el nombre).
#' Por defecto en figures/review/. Antes de describirla: mirarla.
guardar_png <- function(plot, nombre, carpeta = RUTA_FIG_REVIEW, ancho = 1920, alto = 1080,
                        res = 144, copia_960 = FALSE) {
  if (!grepl("\\.png$", nombre)) nombre <- paste0(nombre, ".png")
  ruta <- if (dirname(nombre) == ".") file.path(carpeta, nombre) else nombre
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  ragg::agg_png(ruta, width = ancho, height = alto, res = res)
  print(plot)
  grDevices::dev.off()
  if (copia_960) {
    ruta2 <- sub("\\.png$", "_960.png", ruta)
    ragg::agg_png(ruta2, width = 960, height = 540, res = res / 2)
    print(plot)
    grDevices::dev.off()
  }
  invisible(ruta)
}

#' Resumen corto de las muestras (para la sección "Decisiones de datos").
resumen_muestras <- function() {
  data.frame(
    muestra = c("all countries and areas", "countries >= 1 M (2023)"),
    n_paises = c(N_PAISES, N_PAISES_1M),
    n_subregiones = c(N_SUBREGIONES, N_SUBREGIONES_1M),
    anios_estimacion = sprintf("%d-%d", ANIO_INICIO_DATOS, ANIO_FIN_ESTIMACION),
    anios_proyeccion = sprintf("%d-%d", ANIO_INICIO_PROYECCION, ANIO_MAX_VALIDO)
  )
}

message(sprintf(paste0("comun_analisis.R listo: %d países y áreas (%d >= 1 M; %d/%d subregiones), ",
                       "estimaciones %d-%d, proyección Medium %d-%d, semilla %d."),
                N_PAISES, N_PAISES_1M, N_SUBREGIONES, N_SUBREGIONES_1M, ANIO_INICIO_DATOS,
                ANIO_FIN_ESTIMACION, ANIO_INICIO_PROYECCION, ANIO_MAX_VALIDO, SEMILLA))

invisible(TRUE)
