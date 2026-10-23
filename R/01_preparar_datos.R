#!/usr/bin/env Rscript
# =============================================================================
# 01_preparar_datos.R
# Limpieza y preparación de datos de UN WPP2024 para el ASA DataQuest 2026.
#
# Entrada (fuera del repo, ver data/raw/README.md):
#   ../WPP2024_Demographic_Indicators_Medium_csv.gz   (indicadores, 1950-2101)
#   ../WPP2024_Supplement_Births_and_LE60.csv         (LE60, nacimientos por sexo)
# Entrada (dentro del repo, pequeña, versionada):
#   data/raw/wb_api_income_2026-10-22.csv  (grupos de ingreso, API del Banco
#                                            Mundial, fuente PRINCIPAL)
#   data/raw/WB_income_groups.csv          (mismos grupos, tabla de contraste)
#
# Salida:
#   data/processed/paises.parquet        (NO versionado; 237 países x 1950-2100)
#   data/processed/agregados.parquet     (NO versionado; regiones SDG + ingreso + mundo)
#   data/processed/lookup_regiones.csv   (versionado; ISO3 -> región/ingreso/continente)
#   data/processed/diccionario_variables.csv (versionado; código -> nombre ES/EN, unidad)
#   data/README.md                       (versionado; fuente, licencia, decisiones)
#
# Uso:  Rscript R/01_preparar_datos.R
# =============================================================================

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(janitor)
  library(countrycode)
  library(here)
})

source(here::here("R", "config.R"))

cat("== 01_preparar_datos.R ==", format(Sys.time()), "\n")

# -----------------------------------------------------------------------------
# 1. Lectura de los archivos crudos
# -----------------------------------------------------------------------------
if (!file.exists(RUTA_WPP_MEDIUM)) {
  stop("No se encuentra ", RUTA_WPP_MEDIUM, ". Ver data/raw/README.md para ",
       "descargarlo, o define la variable de entorno WPP_MEDIUM.")
}
cat("Leyendo indicadores:", RUTA_WPP_MEDIUM, "\n")
# readr detecta y descarta el BOM UTF-8 automáticamente.
indicadores_raw <- readr::read_csv(
  RUTA_WPP_MEDIUM, guess_max = 100000, show_col_types = FALSE,
  progress = FALSE
) |> janitor::clean_names(case = "none")
# clean_names(case="none") solo quita el BOM/espacios del nombre de columna,
# sin tocar las mayúsculas (los nombres oficiales de la ONU se mantienen).

cat("Leyendo suplemento (LE60, nacimientos por sexo):", RUTA_WPP_SUPLEMENTO, "\n")
suplemento <- readr::read_csv(
  RUTA_WPP_SUPLEMENTO, show_col_types = FALSE, progress = FALSE
) |> janitor::clean_names(case = "none")

n_filas_crudas <- nrow(indicadores_raw)
cat("Filas leídas (indicadores):", n_filas_crudas, "\n")

# -----------------------------------------------------------------------------
# 2. Año 2101: se descarta (decisión documentada)
# -----------------------------------------------------------------------------
# 2101 solo trae TPopulation1Jan (todo lo demás es NA); lo dejamos fuera para
# no introducir NA artificiales en correlaciones/regresiones posteriores.
indicadores <- indicadores_raw |> filter(.data$Time <= ANIO_MAX_VALIDO)
cat("Filas tras quitar 2101:", nrow(indicadores),
    "(se quitaron", n_filas_crudas - nrow(indicadores), ")\n")

# -----------------------------------------------------------------------------
# 3. Países vs agregados
# -----------------------------------------------------------------------------
# País <=> ISO3_code no vacío (coincide con LocTypeName == "Country/Area").
es_pais <- !is.na(indicadores$ISO3_code) & indicadores$ISO3_code != ""
# readr convierte "" en NA para columnas de texto (default na = c("","NA")),
# así que LocTypeName de los grupos ad-hoc (ADB, BRIC, ...) llega como NA, no
# como "". Se trata esa NA como "no es Country/Area" para la comparación.
es_country_area <- !is.na(indicadores$LocTypeName) & indicadores$LocTypeName == "Country/Area"
n_tipo_pais_distinto <- sum(es_pais != es_country_area)
if (n_tipo_pais_distinto > 0) {
  cat("AVISO: ", n_tipo_pais_distinto, " filas donde ISO3_code vacío/no-vacío",
      " no coincide con LocTypeName == 'Country/Area'. Se usa ISO3_code.\n")
}

paises_raw <- indicadores |> filter(es_pais)
agregados_raw <- indicadores |> filter(!es_pais)

n_paises <- length(unique(paises_raw$ISO3_code))
cat("Países distintos (ISO3_code no vacío):", n_paises,
    "(se esperaban ~237, incl. Holy See)\n")

# -----------------------------------------------------------------------------
# 4. Jerarquía de regiones SDG a partir de ParentID
# -----------------------------------------------------------------------------
# IMPORTANTE (hallazgo verificado, no es lo que uno asumiría a primera vista):
# el ParentID de un país NO apunta directo a la región SDG. Apunta a la
# subregión geográfica M49 (p. ej. "South America", "Eastern Asia"), y esas
# subregiones a su vez apuntan a una "Geographic region" (Americas/Asia/...),
# que tampoco es la región SDG. Las filas "SDG region" del archivo son un
# agregado PARALELO (mismo LocID 1828 como padre de las 9), no heredado por
# ParentID desde los países. Por eso la región SDG se reconstruye mapeando el
# NOMBRE de la subregión M49 (tabla fija de la ONU) y no siguiendo ParentID
# varios niveles. Verificado: la suma de población de países por este mapeo
# reproduce el agregado SDG publicado para 2023 (ver sección 4.3 más abajo).
subregion_a_sdg <- c(
  "Eastern Africa"   = "Sub-Saharan Africa",
  "Middle Africa"    = "Sub-Saharan Africa",
  "Southern Africa"  = "Sub-Saharan Africa",
  "Western Africa"   = "Sub-Saharan Africa",
  "Northern Africa"  = "Northern Africa and Western Asia",
  "Western Asia"     = "Northern Africa and Western Asia",
  "Central Asia"     = "Central and Southern Asia",
  "Southern Asia"    = "Central and Southern Asia",
  "Eastern Asia"     = "Eastern and South-Eastern Asia",
  "South-Eastern Asia" = "Eastern and South-Eastern Asia",
  "Eastern Europe"   = "Europe and Northern America",
  "Northern Europe"  = "Europe and Northern America",
  "Southern Europe"  = "Europe and Northern America",
  "Western Europe"   = "Europe and Northern America",
  "Caribbean"        = "Latin America and the Caribbean",
  "Central America"  = "Latin America and the Caribbean",
  "South America"    = "Latin America and the Caribbean",
  "Australia/New Zealand" = "Australia/New Zealand",
  "Melanesia"        = "Oceania (excluding Australia and New Zealand)",
  "Micronesia"       = "Oceania (excluding Australia and New Zealand)",
  "Polynesia"        = "Oceania (excluding Australia and New Zealand)"
)
# Northern America (LocID 918) NO aparece como fila propia en este archivo de
# indicadores (hallazgo verificado: el LocID 918 no existe en ninguna fila).
# Se asigna a mano por composición conocida del M49 (ONU): EE.UU., Canadá,
# Bermudas, Groenlandia y Saint-Pierre-et-Miquelon -> "Europe and Northern America".
iso_norteamerica <- c("USA", "CAN", "BMU", "GRL", "SPM")

# Tabla LocID -> (nombre, tipo) en 2023 para resolver el padre de cada país
# (el ParentID es estable en el tiempo, basta con una foto de 2023).
tabla_2023 <- indicadores |> filter(.data$Time == 2023) |>
  select(LocID, Location, LocTypeName, ParentID) |>
  distinct()
id_a_nombre <- setNames(tabla_2023$Location, tabla_2023$LocID)

resolver_subregion <- function(parent_id) {
  id_a_nombre[as.character(parent_id)]
}

paises <- paises_raw |>
  mutate(
    .subregion_m49 = resolver_subregion(ParentID),
    Subregion = unname(.subregion_m49),
    Region_SDG = dplyr::case_when(
      ISO3_code %in% iso_norteamerica ~ "Europe and Northern America",
      TRUE ~ unname(subregion_a_sdg[.subregion_m49])
    )
  ) |>
  select(-.subregion_m49)

n_sin_region <- sum(is.na(paises$Region_SDG[paises$Time == 2023]))
cat("Países (2023) sin Region_SDG asignada:", n_sin_region, "\n")
if (n_sin_region > 0) {
  cat("  ->", paste(unique(paises$ISO3_code[paises$Time == 2023 &
                                             is.na(paises$Region_SDG)]), collapse = ", "), "\n")
}

# --- 4.3 Verificación: suma de países == agregado SDG publicado (2023) -----
pub_sdg_2023 <- agregados_raw |>
  filter(Time == 2023, LocTypeName == "SDG region") |>
  select(Location, TPopulation1July)

calc_sdg_2023 <- paises |> filter(Time == 2023) |>
  group_by(Region_SDG) |>
  summarise(pob_calc = sum(TPopulation1July), .groups = "drop")

verificacion_sdg <- pub_sdg_2023 |>
  inner_join(calc_sdg_2023, by = c("Location" = "Region_SDG")) |>
  mutate(diff_abs = pob_calc - TPopulation1July,
         diff_pct = 100 * diff_abs / TPopulation1July)

cat("\n-- Verificación: suma de países por región SDG vs agregado ONU (2023) --\n")
print(verificacion_sdg, n = 20)
max_diff_pct <- max(abs(verificacion_sdg$diff_pct))
cat("Diferencia porcentual máxima:", round(max_diff_pct, 6), "%\n")
if (max_diff_pct > 0.1) {
  warning("La diferencia máxima supera la tolerancia de 0.1% esperada.")
} else {
  cat("OK: dentro de la tolerancia de 0.1%.\n")
}

# -----------------------------------------------------------------------------
# 5. Grupos de ingreso del Banco Mundial
# -----------------------------------------------------------------------------
# Fuente principal: copia del API oficial descargada 2026-10-22 (clasificación
# FY2027, publicada en julio de 2026 con el INB per cápita de 2025 -- ver
# data/raw/README.md). Fuente de contraste: WB_income_groups.csv (entregada
# con el proyecto). Verificado en este script: ambas fuentes coinciden al
# 100% en las 296 economías que cubren (0 discrepancias).
wb_api <- readr::read_csv(RUTA_WB_INCOME_API, show_col_types = FALSE) |>
  select(ISO3_code = ISO3, Ingreso = ingreso_api) |>
  mutate(Ingreso = ifelse(Ingreso == "Aggregates", NA_character_, Ingreso))
wb_contraste <- readr::read_csv(RUTA_WB_INCOME_CSV, show_col_types = FALSE) |>
  mutate(Ingreso = ifelse(Ingreso == "Aggregates", NA_character_, Ingreso))

comparacion_wb <- wb_api |>
  inner_join(wb_contraste, by = "ISO3_code", suffix = c("_api", "_csv")) |>
  filter(!is.na(Ingreso_api), !is.na(Ingreso_csv), Ingreso_api != Ingreso_csv)
cat("\nDiscrepancias entre wb_api_income y WB_income_groups.csv:",
    nrow(comparacion_wb), "\n")

paises <- paises |>
  left_join(wb_api, by = "ISO3_code") |>
  mutate(Ingreso = ifelse(is.na(Ingreso), "Not classified", Ingreso))

paises_sin_ingreso_2023 <- paises |> filter(Time == 2023, Ingreso == "Not classified")
cat("Países (2023) sin grupo de ingreso del Banco Mundial ('Not classified'):",
    nrow(paises_sin_ingreso_2023), "\n")
cat("  ->", paste(paises_sin_ingreso_2023$ISO3_code, collapse = ", "), "\n")
pob_m_sin_ingreso <- paises_sin_ingreso_2023 |>
  filter(TPopulation1July * 1000 >= UMBRAL_MICROESTADO)
cat("  de los cuales con población >= 1 millón (2023):",
    paste(pob_m_sin_ingreso$ISO3_code, collapse = ", "), "\n")

# -----------------------------------------------------------------------------
# 6. Columnas derivadas
# -----------------------------------------------------------------------------
paises <- paises |>
  mutate(
    es_estimacion = Time <= ANIO_CORTE_ESTIMACION,
    es_proyeccion = !es_estimacion,
    periodo = ifelse(es_estimacion, "Estimación", "Proyección"),
    Continente = countrycode::countrycode(ISO3_code, origin = "iso3c",
                                           destination = "continent",
                                           custom_match = c(VAT = "Europe", XKX = "Europe")),
    crec_natural_pct = NatChangeRT / 10,     # tasa (por 1000) -> porcentaje
    crec_migratorio_pct = CNMR / 10,
    # Identidad contable (para Q1 del plan analítico): residuo y su participación
    residuo_identidad = PopChange - (NatChange + NetMigrations),
    pob_1m_2023 = NA  # se completa abajo tras conocer la población 2023
  )

# Marca "pob_1m" con la población de 2023 (fija en el tiempo, como pide el
# plan de implementación: el umbral de microestado se decide con una sola foto).
pob_2023 <- paises |> filter(Time == 2023) |>
  transmute(ISO3_code, pob_2023_miles = TPopulation1July)
paises <- paises |> select(-pob_1m_2023) |>
  left_join(pob_2023, by = "ISO3_code") |>
  mutate(pob_1m = (pob_2023_miles * 1000) >= UMBRAL_MICROESTADO)

# --- 6.1 Clasificación simple de "palanca demográfica" (fila a fila) -------
# Webb simplificado: A/B creciendo por saldo natural positivo (se funden en
# una sola etiqueta porque ambas son NatChange>0 & PopChange>0); C crece SOLO
# por migración; D decrece con más muertes que nacimientos; E decrece pese a
# más nacimientos que muertes (emigración). Esta es una clasificación por FILA
# (cualquier año); la figura oficial de Q1 (ONU, "2023") usa el promedio
# 2021-2023 y la calcula el notebook de análisis, no este script de limpieza.
paises <- paises |>
  mutate(tipo_palanca = dplyr::case_when(
    NatChange > 0 & PopChange > 0 ~ "A_B_crece_saldo_natural",
    NatChange < 0 & PopChange > 0 ~ "C_crece_solo_migracion",
    NatChange < 0 & PopChange < 0 ~ "D_decrece_mas_muertes",
    NatChange > 0 & PopChange < 0 ~ "E_decrece_por_emigracion",
    TRUE ~ NA_character_
  ))

# --- 6.2 Verificación: crec_natural_pct + crec_migratorio_pct vs PopGrowthRate
paises <- paises |>
  mutate(crec_aprox_pct = crec_natural_pct + crec_migratorio_pct,
         error_crecimiento = abs(crec_aprox_pct - PopGrowthRate))
err_2023 <- paises |> filter(Time == 2023) |> pull(error_crecimiento)
cat("\n-- Verificación: (NatChangeRT+CNMR)/10 vs PopGrowthRate (2023) --\n")
cat("Error absoluto mediano:", round(median(err_2023, na.rm = TRUE), 5), "pp\n")
cat("Error absoluto máximo :", round(max(err_2023, na.rm = TRUE), 5), "pp (",
    paises$ISO3_code[paises$Time == 2023][which.max(err_2023)], ")\n")
cat("Explicación: PopGrowthRate es la tasa EXPONENCIAL (ln) de crecimiento;",
    "(NatChangeRT+CNMR)/10 es la suma de tasas ARITMÉTICAS (por 1000, sobre",
    "población de mitad de año). Coinciden casi siempre (mediana ~0.0004 pp);",
    "se separan solo en poblaciones muy pequeñas (Santa Elena, Niue, Tokelau,",
    "Holy See) donde un cambio chico es grande en términos relativos.\n")

# -----------------------------------------------------------------------------
# 7. Año 2101 ya se excluyó arriba (sección 2); se documenta aquí también:
#    2101 solo trae TPopulation1Jan (el resto de columnas es NA), así que
#    incluirlo rompería cualquier serie 1950-2100 con un año final a medias.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 8. Agregados (regiones SDG, grupos de ingreso, mundo) para series ya
#    ponderadas por la ONU (nunca se construyen sumando países con pesos
#    propios, para no duplicar lo que la ONU ya ponderó).
# -----------------------------------------------------------------------------
agregados <- agregados_raw |>
  filter(LocTypeName %in% c("World", "SDG region", "Income group",
                             "Development group", "Geographic region", "Subregion")) |>
  mutate(
    es_estimacion = Time <= ANIO_CORTE_ESTIMACION,
    periodo = ifelse(es_estimacion, "Estimación", "Proyección")
  )

regiones_sdg <- agregados |> filter(LocTypeName == "SDG region")
grupos_ingreso_onu <- agregados |> filter(LocTypeName == "Income group")

cat("\nGrupos de ingreso agregados por la ONU disponibles (LocTypeName == 'Income group'):\n")
print(unique(grupos_ingreso_onu$Location))

# -----------------------------------------------------------------------------
# 9. Tabla de mapeo país -> región/ingreso/continente (liviana, versionada)
# -----------------------------------------------------------------------------
lookup_regiones <- paises |> filter(Time == 2023) |>
  transmute(
    ISO3 = ISO3_code,
    nombre = Location,
    region_sdg = Region_SDG,
    subregion = Subregion,
    ingreso_bm = Ingreso,
    continente = Continente,
    pob_2023 = TPopulation1July * 1000,
    pob_1m = pob_1m
  ) |>
  arrange(ISO3)

# -----------------------------------------------------------------------------
# 10. Diccionario de variables (de WPP2024_Demographic_Indicators_notes.csv
#     + las variables derivadas de este script)
# -----------------------------------------------------------------------------
notas_onu <- readr::read_csv(RUTA_WPP_NOTES, show_col_types = FALSE) |>
  transmute(codigo = Indicator, nombre_en = IndicatorName, unidad = Unit, tema = Topic)

derivadas <- tibble::tribble(
  ~codigo, ~nombre_en, ~unidad, ~tema,
  "es_estimacion", "Is an observed estimate (<=2023)?", "boolean (TRUE/FALSE)", "Derivada",
  "es_proyeccion", "Is a UN medium-variant projection (>=2024)?", "boolean", "Derivada",
  "periodo", "Estimate or Projection", "texto", "Derivada",
  "Region_SDG", "UN SDG region (derived from M49 subregion)", "texto", "Derivada",
  "Subregion", "UN M49 geographic subregion", "texto", "Derivada",
  "Ingreso", "World Bank income group (FY2027 classification)", "texto", "Derivada",
  "Continente", "Continent (countrycode package)", "texto", "Derivada",
  "crec_natural_pct", "Natural change rate, as percentage (NatChangeRT/10)", "%", "Derivada",
  "crec_migratorio_pct", "Net migration rate, as percentage (CNMR/10)", "%", "Derivada",
  "tipo_palanca", "Demographic lever type (row-level Webb classification)", "categoría", "Derivada",
  "pob_1m", "Population >= 1 million in 2023?", "boolean", "Derivada",
  "residuo_identidad", "PopChange - (NatChange + NetMigrations)", "thousands", "Derivada"
)
nombre_es <- c(
  TPopulation1July = "Población total", TFR = "Tasa de fecundidad total",
  LEx = "Esperanza de vida al nacer", IMR = "Mortalidad infantil",
  Q5 = "Mortalidad en menores de 5 años", MedianAgePop = "Edad mediana",
  CNMR = "Tasa de migración neta", PopGrowthRate = "Tasa de crecimiento poblacional",
  NetMigrations = "Migración neta", NatChange = "Cambio natural (nacimientos-muertes)",
  PopChange = "Cambio de población", CDR = "Tasa bruta de mortalidad",
  CBR = "Tasa bruta de natalidad"
)
diccionario_variables <- bind_rows(notas_onu, derivadas) |>
  mutate(nombre_es = ifelse(codigo %in% names(nombre_es), nombre_es[codigo], NA_character_))

# -----------------------------------------------------------------------------
# 11. Guardar salidas
# -----------------------------------------------------------------------------
guardar_parquet_csv <- function(df, nombre, csv_gz = FALSE) {
  ruta_parquet <- file.path(RUTA_PROCESSED, paste0(nombre, ".parquet"))
  arrow::write_parquet(df, ruta_parquet)
  cat("Guardado:", ruta_parquet, "(", round(file.size(ruta_parquet)/1024^2, 2), "MB )\n")
  if (csv_gz) {
    ruta_csv <- file.path(RUTA_PROCESSED, paste0(nombre, ".csv.gz"))
    readr::write_csv(df, ruta_csv)
    cat("Guardado:", ruta_csv, "(", round(file.size(ruta_csv)/1024^2, 2), "MB )\n")
  }
}

guardar_parquet_csv(paises, "paises")
guardar_parquet_csv(agregados, "agregados")
guardar_parquet_csv(regiones_sdg, "regiones_sdg")
guardar_parquet_csv(grupos_ingreso_onu, "grupos_ingreso_onu")

readr::write_csv(lookup_regiones, file.path(RUTA_PROCESSED, "lookup_regiones.csv"))
cat("Guardado:", file.path(RUTA_PROCESSED, "lookup_regiones.csv"), "\n")

readr::write_csv(diccionario_variables, file.path(RUTA_PROCESSED, "diccionario_variables.csv"))
cat("Guardado:", file.path(RUTA_PROCESSED, "diccionario_variables.csv"), "\n")

cat("\n== 01_preparar_datos.R terminado ==", format(Sys.time()), "\n")
cat("Países:", n_paises, "| Filas país-año:", nrow(paises),
    "| Años:", min(paises$Time), "-", max(paises$Time), "\n")
