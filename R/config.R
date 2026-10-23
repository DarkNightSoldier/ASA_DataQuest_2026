#!/usr/bin/env Rscript
# =============================================================================
# config.R
# Configuración compartida del proyecto ASA DataQuest 2026 (UN WPP2024):
# rutas, semilla, paletas accesibles, tema gráfico y constantes de análisis.
# Todos los scripts de R/ deben empezar con `source(here::here("R", "config.R"))`.
#
# Convención del proyecto: código y comentarios en español; nombres de
# archivos de figuras, texto de gráficas y diapositivas en inglés.
# =============================================================================

suppressPackageStartupMessages({
  library(here)
})

# --- 1. Rutas ----------------------------------------------------------------
# Los CSV oficiales de la ONU son demasiado grandes para versionar (16-230 MB)
# y viven en la carpeta PADRE del repo (ver data/raw/README.md). Se pueden
# sobreescribir con variables de entorno si alguien los guarda en otro sitio.
RUTA_RAIZ      <- here::here()
RUTA_DATA      <- file.path(RUTA_RAIZ, "data")
RUTA_RAW       <- file.path(RUTA_DATA, "raw")
RUTA_PROCESSED <- file.path(RUTA_DATA, "processed")
RUTA_FIGURAS   <- file.path(RUTA_RAIZ, "figures")
RUTA_DOCS      <- file.path(RUTA_RAIZ, "docs")

dir.create(RUTA_PROCESSED, recursive = TRUE, showWarnings = FALSE)

# --- 1b. Librerías del sistema extraídas sin sudo (sf/units/terra/magick) ---
# HALLAZGO (verificado, ver docs/instalacion_log.txt y SETUP.md): `units` y
# `magick` quedaban instalados pero no CARGABAN en una sesión nueva de R
# ("libudunits2.so.0: cannot open shared object file") porque esas librerías
# del sistema (extraídas sin sudo en ~/.local/opt/sysdeps-r) no están
# registradas en el cache de `ldconfig`. `Sys.setenv(LD_LIBRARY_PATH=...)`
# DESDE DENTRO de una sesión de R ya iniciada no sirve para esto (el enlazador
# dinámico de Linux fija LD_LIBRARY_PATH una sola vez, al arrancar el
# proceso) -- la solución real fue incrustar el rpath correcto en cada .so
# con `patchelf` (lo hace, de una vez, `R/00_instalar_paquetes.R`). Esta línea
# solo deja LD_LIBRARY_PATH disponible para procesos HIJOS que R pueda lanzar
# (p. ej. `system()`, `parallel::makeCluster()`), no para esta misma sesión.
.prefijo_sysdeps <- path.expand(Sys.getenv("SYSDEPS_R", "~/.local/opt/sysdeps-r"))
if (dir.exists(file.path(.prefijo_sysdeps, "usr"))) {
  .libdir_sysdeps <- file.path(.prefijo_sysdeps, "usr/lib/x86_64-linux-gnu")
  Sys.setenv(LD_LIBRARY_PATH = paste(.libdir_sysdeps, Sys.getenv("LD_LIBRARY_PATH"), sep = ":"))
}

# Archivos crudos grandes (fuera del repo, carpeta padre de RepoGithub/)
RUTA_WPP_MEDIUM <- Sys.getenv(
  "WPP_MEDIUM",
  file.path(dirname(RUTA_RAIZ), "WPP2024_Demographic_Indicators_Medium_csv.gz")
)
RUTA_WPP_SUPLEMENTO <- Sys.getenv(
  "WPP_SUPLEMENTO",
  file.path(dirname(RUTA_RAIZ), "WPP2024_Supplement_Births_and_LE60.csv")
)

# Archivos pequeños que sí se versionan (dentro del repo)
RUTA_WB_INCOME_API <- file.path(RUTA_RAW, "wb_api_income_2026-10-22.csv")
RUTA_WB_INCOME_CSV <- file.path(RUTA_RAW, "WB_income_groups.csv")
RUTA_WPP_NOTES     <- file.path(RUTA_RAW, "WPP2024_Demographic_Indicators_notes.csv")

# --- 2. Semilla y reproducibilidad -------------------------------------------
SEMILLA <- 2026
set.seed(SEMILLA)
NSTART_KMEANS <- 50

# --- 3. Umbrales y constantes de análisis ------------------------------------
UMBRAL_MICROESTADO <- 1e6     # habitantes en 2023; bajo esto = "small state"
ANIO_CORTE_ESTIMACION <- 2023 # <= es estimación observada; > es proyección Medium
ANIO_MAX_VALIDO <- 2100       # 2101 se descarta (solo trae TPopulation1Jan)

# Conjunto fijo de 12 indicadores para el PCA (Q2, plan analítico §4).
# Fijo a propósito: así el peso del primer eje no depende de qué se eligió.
VARS_PCA <- c("TFR", "CBR", "LEx", "LE65", "Q5", "Q1560", "CDR",
              "MedianAgePop", "PopGrowthRate", "CNMR", "PopSexRatio", "PopDensity")
# Conjunto reducido (8) para la sensibilidad del PCA (catálogo de visualización)
VARS_PCA_SENSIBILIDAD <- c("TFR", "LEx", "Q5", "MedianAgePop", "CNMR",
                           "PopGrowthRate", "CDR", "PopSexRatio")

# --- 4. Paletas accesibles (Okabe-Ito / Paul Tol) ----------------------------
# Todas con nombres, para usar como `scale_colour_manual(values = PALETA_X)`.
# Nunca rojo-verde puro como único contraste (daltonismo); revisar con
# colorspace::simulate_cvd() antes de aprobar una figura.

# 4.1 Regiones SDG (8) — Okabe-Ito
PALETA_REGION_SDG <- c(
  "Sub-Saharan Africa"                           = "#E69F00",
  "Northern Africa and Western Asia"             = "#D55E00",
  "Central and Southern Asia"                    = "#CC79A7",
  "Eastern and South-Eastern Asia"                = "#0072B2",
  "Latin America and the Caribbean"               = "#009E73",
  "Oceania (excluding Australia and New Zealand)" = "#F0E442",
  "Australia/New Zealand"                         = "#56B4E9",
  "Europe and Northern America"                   = "#000000"
)
# Variante para fondos oscuros (el negro puro no se ve bien)
PALETA_REGION_SDG_FONDO_OSCURO <- replace(
  PALETA_REGION_SDG, "Europe and Northern America", "#4D4D4D"
)

# 4.2 Grupos de ingreso del Banco Mundial (ordinal -> viridis discreto,
# perceptualmente ordenado, mejor que una paleta cualitativa para una escala
# de "más pobre a más rico"). "Not classified" en gris neutro.
PALETA_INGRESO <- c(
  "Low income"          = "#440154",
  "Lower middle income" = "#3B528B",
  "Upper middle income" = "#21908C",
  "High income"         = "#5DC863",
  "Not classified"      = "#BBBBBB"
)

# 4.3 Tipo de palanca demográfica 2023 (Q1, Webb simplificado; Okabe-Ito)
PALETA_TIPO_PALANCA <- c(
  "A_creciendo_natural_inflow"  = "#009E73", # A: NatChange>0, NetMig>0
  "B_creciendo_solo_nacimientos" = "#009E73", # B: NatChange>0, NetMig<0, PopChange>0 (mismo verde, se distingue por etiqueta)
  "C_crece_solo_migracion"      = "#0072B2", # C: NatChange<0, PopChange>0
  "D_decrece_mas_muertes"       = "#D55E00", # D: NatChange<0, PopChange<0
  "E_decrece_por_emigracion"    = "#E69F00", # E: NatChange>0, PopChange<0
  "sin_datos_o_microestado"     = "#BBBBBB"
)

# 4.4 Grupos de trayectoria (Q3, clustering) — paleta de Tol, distinta de 4.1/4.3
PALETA_GRUPO_TRAYECTORIA <- c(
  "Early movers" = "#332288",
  "Fast movers"  = "#117733",
  "Late movers"  = "#DDCC77",
  "Grupo 4"      = "#AA4499"
)

# 4.5 Estimación vs proyección (siempre estos dos colores en cualquier figura)
COLOR_PROYECCION <- "#B0B0B0"
COLOR_PROYECCION_SOMBRA <- "#F0F0F0"

# --- 5. Etiquetas en inglés para ejes y títulos (código en español, texto
#        visible en inglés; ver docs/00_plan_implementacion.md §6) -----------
ETIQUETAS_EN <- c(
  TFR            = "Total fertility rate (children per woman)",
  LEx            = "Life expectancy at birth (years)",
  LE60           = "Life expectancy at age 60 (years)",
  IMR            = "Infant mortality rate (per 1,000 live births)",
  Q5             = "Under-5 mortality rate (per 1,000 live births)",
  MedianAgePop   = "Median age (years)",
  CNMR           = "Net migration rate (per 1,000 population)",
  PopGrowthRate  = "Population growth rate (%)",
  CDR            = "Crude death rate (per 1,000 population)",
  CBR            = "Crude birth rate (per 1,000 population)",
  NetMigrations  = "Net migrations (thousands)",
  NatChange      = "Natural change: births minus deaths (thousands)",
  PopChange      = "Population change (thousands)",
  TPopulation1July = "Total population (thousands, 1 July)",
  PopSexRatio    = "Sex ratio (males per 100 females)",
  PopDensity     = "Population density (persons per km2)",
  Q1560          = "Mortality risk age 15-60 (per 1,000)",
  LE65           = "Life expectancy at age 65 (years)"
)
etiquetas_en <- function(codigo) {
  # Devuelve el rotulo en ingles de una variable (o el codigo si no esta
  # en el diccionario, para no romper una grafica por una variable nueva).
  out <- ETIQUETAS_EN[codigo]
  ifelse(is.na(out), codigo, out)
}

# --- 6. Tema gráfico común (theme_wpp) ---------------------------------------
# Fondo blanco, tipografia Lato (instalada en el equipo), pensado para
# exportar a 1920x1080 (ragg::agg_png(1920,1080,res=144)); tamaño base grande
# para que se lea en una diapositiva proyectada.
theme_wpp <- function(base_size = 22, base_family = "Lato") {
  suppressPackageStartupMessages(library(ggplot2))
  theme_minimal(base_size = base_size, base_family = base_family) +
    theme(
      plot.background   = element_rect(fill = "white", colour = NA),
      panel.background  = element_rect(fill = "white", colour = NA),
      panel.grid.minor  = element_blank(),
      panel.grid.major  = element_line(colour = "#E5E5E5", linewidth = 0.3),
      plot.title        = element_text(face = "bold", size = rel(1.15), margin = margin(b = 6)),
      plot.subtitle     = element_text(colour = "#444444", size = rel(0.85), margin = margin(b = 10)),
      plot.caption      = element_text(colour = "#777777", size = rel(0.55), hjust = 0),
      axis.title        = element_text(size = rel(0.85)),
      legend.position   = "bottom",
      legend.title      = element_text(size = rel(0.8)),
      strip.text        = element_text(face = "bold", size = rel(0.9)),
      plot.margin       = margin(14, 18, 10, 14)
    )
}

# Pie de fuente estándar para toda figura (ASA B.2: fuente y supuestos visibles)
FUENTE_ESTANDAR <- paste0(
  "Source: UN DESA, World Population Prospects 2024 (CC BY 3.0 IGO) . ",
  "Estimates <= 2023, UN medium-variant projection >= 2024 (grey)."
)

# --- 7. Regla de nombres de clúster (Q3; ver plan analitico §4 "Rico 1") ----
# La compone el agente notebook-R con datos reales; aquí solo se fija la
# REGLA para que no se invente a mano. No requiere datos para definirse.
nombrar_grupo <- function(cnmr_mediana_2000_23, es_el_mas_rapido_en_bajar_tfr,
                           anio_mediano_tfr_bajo_4) {
  if (isTRUE(cnmr_mediana_2000_23 > 10)) return("Migration-boosted")
  if (isTRUE(es_el_mas_rapido_en_bajar_tfr)) return("Sprinters")
  if (isTRUE(anio_mediano_tfr_bajo_4 < 1960)) return("Early movers")
  if (isTRUE(anio_mediano_tfr_bajo_4 > 1995) || is.na(anio_mediano_tfr_bajo_4)) return("Late movers")
  "Fast movers"
}

invisible(TRUE)
