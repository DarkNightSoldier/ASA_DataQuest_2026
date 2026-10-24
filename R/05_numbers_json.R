#!/usr/bin/env Rscript
# =============================================================================
# 05_numbers_json.R — Ensamblaje de figures/numbers.json (fuente única de cifras)
#
# Ejecutar desde la raíz del repo, DESPUÉS de R/02, R/03 y R/04:
#   Rscript R/05_numbers_json.R
#
# Qué hace, en orden (cada sección explica QUÉ se hace y POR QUÉ):
#   1. Lee los tres registros parciales que escriben los scripts de análisis
#      (figures/numbers_q1.json, numbers_q2.json, numbers_q3.json).
#   2. Detecta claves duplicadas: si una clave aparece en dos archivos con
#      contenido DISTINTO, para con error (dos análisis calcularon la misma
#      cifra de forma diferente y hay que decidir cuál vale); si el contenido es
#      idéntico, la conserva una sola vez.
#   3. Comprueba las claves globales contra los datos (n_countries,
#      n_countries_1m, world_pop_2023_bn) y añade las que falten.
#   4. Añade los metadatos de la corrida: fecha de las cifras, versión WPP,
#      clasificación de ingreso, semilla y generador, SHA-256 de los archivos
#      crudos y del archivo de hipótesis preinscritas (con su fecha y commit) y
#      el nombre del equipo (docs/equipo.json).
#   4.5 Aplica la verificación independiente de QA-stats
#      (docs/qa/verificacion_consolidada.csv vía R/qa_verificacion.R): verified,
#      verified_by, verified_on y nota_qa, solo si la cifra no cambió.
#   5. Escribe figures/numbers.json (claves en orden alfabético, esquema v2).
#   6. Comprueba que existan las claves obligatorias de
#      docs/00_plan_implementacion.md §4 y todas las {clave} del storyboard
#      (docs/00_storyboard_diapositivas.md): las que faltan se REPORTAN, nunca
#      se inventan.
#   7. Imprime la tabla de verificación (claves usadas en pantalla o en la voz)
#      para QA-stats.
#
# Decisiones (ASA 2022, B.4, C.2, F.4; plan de implementación §4):
#   * Ninguna cifra de análisis se escribe aquí: todo valor viene de los
#     registros parciales. Lo único nuevo son conteos que se recalculan con los
#     datos (para comprobar) y metadatos de reproducibilidad.
#   * Los alias que usan las diapositivas (n_ge1m, n_twin_pairs, *_sens_range)
#     se leen de la tabla KEY_ALIASES de slides/js/numbers.js (la misma que lee
#     slides/script/fill_numbers.py): no se crean claves duplicadas.
#   * Salida determinista: dos corridas con los mismos datos dan el mismo
#     archivo byte a byte (sin marcas de tiempo; orden de claves "radix", que
#     no depende del idioma del sistema).
#
# Convención: código y comentarios en español; textos de numbers.json en inglés.
# =============================================================================

t_inicio_05 <- Sys.time()

# =============================================================================
# 0. Preparación: infraestructura común, rutas y constantes
# =============================================================================
suppressPackageStartupMessages(library(here))
source(here::here("R", "comun_analisis.R"))   # config, utilidades, incertidumbre y datos
suppressPackageStartupMessages({
  library(dplyr)
  library(jsonlite)
})

# Fecha de congelación de las cifras v1 (plan de implementación §9: numbers.json
# v1). Es una constante, no Sys.Date(), para que el archivo sea reproducible.
FECHA_CIFRAS <- "2026-10-23"
VERSION_WPP <- paste(
  "UN DESA, World Population Prospects 2024 (July 2024 release): Demographic Indicators,",
  "Medium variant (estimates 1950-2023, medium projection 2024-2100), OtherVariants",
  "(UN 80 % / 95 % prediction intervals and scenarios) and the DataQuest supplement (LE60, births by sex)"
)
CLASIFICACION_INGRESO <- paste(
  "World Bank FY2027 country income groups (effective 1 July 2026; 2025 GNI per capita, Atlas method),",
  "API download 2026-10-22, applied to all years (today's income groups)"
)

RUTAS_PARCIALES <- c(
  Q1 = file.path(RUTA_FIGURAS, "numbers_q1.json"),
  Q2 = file.path(RUTA_FIGURAS, "numbers_q2.json"),
  Q3 = file.path(RUTA_FIGURAS, "numbers_q3.json")
)
RUTA_HIPOTESIS  <- file.path(RUTA_DOCS, "hipotesis_preinscritas.md")
RUTA_PLAN_IMPL  <- file.path(RUTA_DOCS, "00_plan_implementacion.md")
RUTA_STORYBOARD <- file.path(RUTA_DOCS, "00_storyboard_diapositivas.md")
RUTA_EQUIPO     <- file.path(RUTA_DOCS, "equipo.json")
RUTA_NUMBERS_JS <- file.path(RUTA_RAIZ, "slides", "js", "numbers.js")
RUTA_INDEX_HTML <- file.path(RUTA_RAIZ, "slides", "index.html")

# Marcadores del storyboard que NO son claves de numbers.json (texto de las
# notas o etiquetas genéricas que el propio storyboard traduce a otra clave).
MARCADORES_GENERICOS <- c(
  clave = "texto de las notas (\"pasan a `{clave}`\"), no es un marcador",
  n     = "etiqueta por panel de fig10; el storyboard la define como `cluster_sizes`",
  pop   = "etiqueta por panel de fig10; el storyboard la define como `cluster_pop_bn`"
)
EQUIVALENCIA_GENERICOS <- c(n = "cluster_sizes", pop = "cluster_pop_bn")

seccion_05 <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
informar_05 <- function(fmt, ...) cat(sprintf(fmt, ...), "\n", sep = "")

# =============================================================================
# 1. Lectura de los registros parciales
# =============================================================================
# QUÉ: cada script de análisis guarda sus cifras con el esquema v2 completo.
# POR QUÉ: aquí solo se ensamblan; si falta un parcial, la corrida no sirve.
seccion_05("1. Registros parciales")
faltan_parciales <- RUTAS_PARCIALES[!file.exists(RUTAS_PARCIALES)]
if (length(faltan_parciales) > 0) {
  stop("Faltan registros parciales (corre antes R/02, R/03 y R/04): ",
       paste(faltan_parciales, collapse = ", "), call. = FALSE)
}
parciales <- lapply(RUTAS_PARCIALES, leer_numbers)
for (p in names(parciales)) {
  informar_05("%s: %d claves (%s)", p, length(parciales[[p]]), basename(RUTAS_PARCIALES[[p]]))
}

# =============================================================================
# 2. Claves duplicadas entre parciales
# =============================================================================
# QUÉ: una clave en dos archivos con contenido distinto = error; idéntica = una vez.
# POR QUÉ: la misma cifra no puede tener dos valores (ASA B.2: una sola versión).
seccion_05("2. Claves duplicadas")

# Resumen corto de un valor (para mensajes y tablas).
resumir_valor <- function(v, max_car = 60) {
  if (is.null(v)) return("NULL")
  if (is.data.frame(v)) return(sprintf("<tabla %d x %d>", nrow(v), ncol(v)))
  if (is.list(v)) {
    if (!is.null(names(v)) && all(vapply(v, function(z) is.atomic(z) && length(z) <= 1, logical(1)))) {
      txt <- paste(sprintf("%s: %s", names(v), vapply(v, function(z) paste(z, collapse = ""), character(1))), collapse = "; ")
    } else {
      txt <- sprintf("<lista de %d elementos>", length(v))
    }
  } else {
    txt <- paste(as.character(unclass(v)), collapse = ", ")
  }
  if (nchar(txt) > max_car) txt <- paste0(substr(txt, 1, max_car - 1), "…")
  txt
}
entradas_iguales <- function(a, b) {
  isTRUE(all.equal(lapply(a, unclass), lapply(b, unclass), check.attributes = FALSE))
}

total <- nuevo_registro()
origen <- list()
conflictos <- data.frame(clave = character(0), partes = character(0), valor_a = character(0),
                         valor_b = character(0), stringsAsFactors = FALSE)
duplicadas_iguales <- character(0)
for (p in names(parciales)) {
  for (k in names(parciales[[p]])) {
    e <- parciales[[p]][[k]]
    if (!is.null(total[[k]])) {
      if (entradas_iguales(total[[k]], e)) {
        duplicadas_iguales <- c(duplicadas_iguales, k)
      } else {
        conflictos <- rbind(conflictos, data.frame(
          clave = k, partes = paste(c(origen[[k]], p), collapse = " vs "),
          valor_a = resumir_valor(total[[k]]$value), valor_b = resumir_valor(e$value),
          stringsAsFactors = FALSE))
      }
      origen[[k]] <- c(origen[[k]], p)
      next
    }
    total[[k]] <- e
    origen[[k]] <- p
  }
}
if (nrow(conflictos) > 0) {
  print(conflictos, row.names = FALSE)
  stop(sprintf("%d clave(s) aparecen en dos registros parciales con valores distintos: %s. ",
               nrow(conflictos), paste(conflictos$clave, collapse = ", ")),
       "Hay que decidir cuál vale (y renombrar la otra) antes de ensamblar.", call. = FALSE)
}
informar_05("Claves únicas tras combinar: %d (suma de parciales: %d).", length(total),
            sum(vapply(parciales, length, integer(1))))
informar_05("Duplicadas con contenido idéntico (se conservan una vez): %s",
            if (length(duplicadas_iguales) == 0) "ninguna" else paste(duplicadas_iguales, collapse = ", "))
informar_05("Duplicadas con contenido distinto (error): ninguna")
claves_analisis <- names(total)

# Registro de lo que añade este script (para el informe final).
claves_nuevas <- character(0)
anotar_05 <- function(clave, ...) {
  if (!is.null(total[[clave]])) stop(sprintf("La clave '%s' ya existe: 05 no la sobrescribe.", clave), call. = FALSE)
  total <<- registrar_cifra(total, clave, ...)
  claves_nuevas <<- c(claves_nuevas, clave)
  invisible(NULL)
}

# =============================================================================
# 3. Claves globales: comprobar contra los datos y añadir las que falten
# =============================================================================
# QUÉ: recalcula el universo (237 / 161) y la población mundial de 2023.
# POR QUÉ: son las cifras de la portada y de todos los pies; si un parcial las
#          trae, deben coincidir con los datos; si no, se añaden aquí.
seccion_05("3. Claves globales")
pob_mundo_2023_bn <- agregado_mundo(anios = ANIO_BASE)$TPopulation1July / 1e6
suma_paises_2023_bn <- sum(corte_anio(ANIO_BASE, "completa")$TPopulation1July) / 1e6
stopifnot(length(pob_mundo_2023_bn) == 1)
informar_05("Población mundial 2023: agregado ONU %.4f mil M; suma de los %d países %.4f mil M (dif. %.2e %%).",
            pob_mundo_2023_bn, N_PAISES, suma_paises_2023_bn,
            100 * abs(pob_mundo_2023_bn - suma_paises_2023_bn) / pob_mundo_2023_bn)

globales <- list(
  n_countries = list(valor = N_PAISES, tol = 0, unit = "countries and areas", fmt = "0",
                     def = "Rows with a non-empty ISO3 code in WPP 2024 (countries and areas, each counted once)",
                     filter = "WPP 2024 Medium file", method = "none_census", n = N_PAISES,
                     universe = UNIVERSO_237, used_in = c("slide1.build0", "cover")),
  n_countries_1m = list(valor = N_PAISES_1M, tol = 0, unit = "countries", fmt = "0",
                        def = "Countries and areas with at least 1 million people on 1 July 2023",
                        filter = "237 countries and areas, 2023", method = "none_census", n = N_PAISES_1M,
                        universe = UNIVERSO_1M, used_in = c("slide1.build0")),
  world_pop_2023_bn = list(valor = round(pob_mundo_2023_bn, 4), tol = 5e-4, unit = "billion", fmt = "0.0",
                           def = "World population on 1 July 2023 (UN World aggregate; equals the sum of the 237 countries and areas)",
                           filter = "237 countries and areas, 2023 (estimate)", method = "descriptive", n = N_PAISES,
                           universe = UNIVERSO_237, used_in = c("cover.build1", "narration.cover"))
)
comprobacion_globales <- data.frame(clave = character(0), en_parcial = character(0), valor_parcial = character(0),
                                    valor_datos = character(0), estado = character(0), stringsAsFactors = FALSE)
for (k in names(globales)) {
  g <- globales[[k]]
  if (!is.null(total[[k]])) {
    v <- suppressWarnings(as.numeric(total[[k]]$value))
    ok <- length(v) == 1 && !is.na(v) && abs(v - g$valor) <= g$tol + 1e-12
    comprobacion_globales <- rbind(comprobacion_globales, data.frame(
      clave = k, en_parcial = paste(origen[[k]], collapse = "+"), valor_parcial = format(v),
      valor_datos = format(g$valor), estado = if (ok) "coincide" else "NO COINCIDE", stringsAsFactors = FALSE))
    if (!ok) stop(sprintf("La clave global '%s' vale %s en %s y %s con los datos.", k, format(v),
                          paste(origen[[k]], collapse = "+"), format(g$valor)), call. = FALSE)
  } else {
    anotar_05(k, value = g$valor, unit = g$unit, fmt = g$fmt, def = g$def, filter = g$filter,
              source_cell = "T18 (R/05_numbers_json.R §3)", used_in = g$used_in, method = g$method,
              status = "descriptive", n = g$n, universe = g$universe)
    comprobacion_globales <- rbind(comprobacion_globales, data.frame(
      clave = k, en_parcial = "—", valor_parcial = "—", valor_datos = format(g$valor),
      estado = "añadida por 05", stringsAsFactors = FALSE))
  }
}
print(comprobacion_globales, row.names = FALSE)

# =============================================================================
# 4. Metadatos de la corrida (reproducibilidad, ASA B.4 y F.4)
# =============================================================================
# QUÉ: fecha de las cifras, versión de los datos, clasificación de ingreso,
#      semilla, SHA-256 de los crudos y del archivo de hipótesis (con su commit).
# POR QUÉ: cualquiera debe poder comprobar con qué datos y con qué hipótesis
#          fijadas se calcularon los números; el hash se publica en la tarjeta
#          de ética y en las referencias.
seccion_05("4. Metadatos")

sha256_archivo <- function(ruta) {
  if (!file.exists(ruta)) return(NA_character_)
  digest::digest(file = ruta, algo = "sha256")
}
# Ejecuta git en la raíz del repo; devuelve character(0) si git no está o falla.
git_repo <- function(...) {
  out <- tryCatch(suppressWarnings(system2("git", c("-C", shQuote(RUTA_RAIZ), ...), stdout = TRUE, stderr = FALSE)),
                  error = function(e) character(0))
  st <- attr(out, "status")
  if (!is.null(st) && st != 0) return(character(0))
  out
}

# 4.1 Archivo de hipótesis preinscritas: hash, commit que lo fijó y fecha.
hyp_sha <- sha256_archivo(RUTA_HIPOTESIS)
if (is.na(hyp_sha)) stop("No existe ", RUTA_HIPOTESIS, call. = FALSE)
hyp_rel <- "docs/hipotesis_preinscritas.md"
hyp_commit <- git_repo("log", "-1", "--format=%H", "--", hyp_rel)
hyp_fecha  <- git_repo("log", "-1", "--format=%cd", "--date=short", "--", hyp_rel)
hyp_estado <- git_repo("status", "--porcelain", "--", hyp_rel)
hyp_sin_cambios <- length(hyp_commit) == 1 && length(hyp_estado) == 0
if (length(hyp_commit) != 1) {
  warning("No se pudo leer el commit del archivo de hipótesis (¿git no disponible?): hyp_file_commit = NA.", call. = FALSE)
  hyp_commit <- NA_character_
  hyp_fecha <- NA_character_
} else if (!hyp_sin_cambios) {
  warning("docs/hipotesis_preinscritas.md tiene cambios sin commit: el hash publicado NO corresponde al commit ",
          substr(hyp_commit, 1, 7), ". Todo cambio posterior se etiqueta post hoc (plan §3, tarea 1b).", call. = FALSE)
}
# Contraste con lo que el equipo anotó en docs/equipo.json (solo aviso).
equipo <- if (file.exists(RUTA_EQUIPO)) jsonlite::fromJSON(RUTA_EQUIPO, simplifyVector = TRUE) else list()
if (!is.null(equipo$hyp_file_sha256_short) && !identical(equipo$hyp_file_sha256_short, substr(hyp_sha, 1, 12))) {
  warning(sprintf("docs/equipo.json anota hyp_file_sha256_short = %s, pero el archivo actual da %s.",
                  equipo$hyp_file_sha256_short, substr(hyp_sha, 1, 12)), call. = FALSE)
}
if (!is.null(equipo$hyp_file_date) && !is.na(hyp_fecha) && !identical(equipo$hyp_file_date, hyp_fecha)) {
  warning(sprintf("docs/equipo.json anota hyp_file_date = %s; el commit que fijó el archivo es del %s.",
                  equipo$hyp_file_date, hyp_fecha), call. = FALSE)
}
informar_05("Hipótesis: sha256 %s · commit %s · fecha %s · sin cambios desde el commit: %s",
            hyp_sha, ifelse(is.na(hyp_commit), "NA", substr(hyp_commit, 1, 12)), hyp_fecha, hyp_sin_cambios)

nota_hyp <- paste("Hypotheses were written after exploratory analyses of the same data:",
                  "'pre-specified' = fixed before the final run, not confirmatory.")
anotar_05("hyp_file_sha256", value = hyp_sha, unit = NA, fmt = "text",
          def = "SHA-256 of docs/hipotesis_preinscritas.md (pre-specified hypotheses), as used in the final run",
          filter = "docs/hipotesis_preinscritas.md", source_cell = "T18 (R/05_numbers_json.R §4.1)",
          used_in = c("readme", "notebook.reproducibilidad"), method = "descriptive", status = "descriptive",
          n = 1, universe = "project files", sens_note = nota_hyp)
anotar_05("hyp_file_sha256_short", value = substr(hyp_sha, 1, 12), unit = NA, fmt = "text",
          def = "First 12 characters of the SHA-256 of docs/hipotesis_preinscritas.md",
          filter = "docs/hipotesis_preinscritas.md", source_cell = "T18 (R/05_numbers_json.R §4.1)",
          used_in = c("slide4.ethics", "references"), method = "descriptive", status = "descriptive",
          n = 1, universe = "project files", sens_note = nota_hyp)
anotar_05("hyp_file_commit", value = hyp_commit, unit = NA, fmt = "text",
          def = "Git commit that fixed docs/hipotesis_preinscritas.md (last commit touching the file)",
          filter = "git log -1 -- docs/hipotesis_preinscritas.md", source_cell = "T18 (R/05_numbers_json.R §4.1)",
          used_in = c("readme", "notebook.reproducibilidad"), method = "descriptive", status = "descriptive",
          say = if (is.na(hyp_commit)) NA else substr(hyp_commit, 1, 7),
          n = 1, universe = "project files",
          sens_note = if (hyp_sin_cambios) "File unchanged since this commit at assembly time" else
            "WARNING: file has uncommitted changes at assembly time")
anotar_05("hyp_file_date", value = hyp_fecha, unit = NA, fmt = "text",
          def = "Date of the git commit that fixed docs/hipotesis_preinscritas.md (written 2026-10-22, committed and frozen this day)",
          filter = "git log -1 --date=short -- docs/hipotesis_preinscritas.md", source_cell = "T18 (R/05_numbers_json.R §4.1)",
          used_in = c("slide4.ethics", "references"), method = "descriptive", status = "descriptive",
          n = 1, universe = "project files", sens_note = nota_hyp)

# 4.2 Archivos crudos: SHA-256 (los CSV de la ONU viven fuera del repo).
crudos <- c(
  meta_raw_sha256_medium        = RUTA_WPP_MEDIUM,
  meta_raw_sha256_othervariants = RUTA_WPP_OTHERVARIANTS,
  meta_raw_sha256_supplement    = RUTA_WPP_SUPLEMENTO,
  meta_raw_sha256_wb_income     = RUTA_WB_INCOME_API
)
for (k in names(crudos)) {
  h <- sha256_archivo(crudos[[k]])
  if (is.na(h)) warning("No se encontró ", crudos[[k]], ": ", k, " = NA.", call. = FALSE)
  informar_05("%-32s %s  %s", k, ifelse(is.na(h), "NA", h), basename(crudos[[k]]))
  anotar_05(k, value = h, unit = NA, fmt = "text",
            def = sprintf("SHA-256 of the raw input file %s (read as published, not modified)", basename(crudos[[k]])),
            filter = basename(crudos[[k]]), source_cell = "T18 (R/05_numbers_json.R §4.2)",
            used_in = c("notebook.reproducibilidad"), method = "descriptive", status = "descriptive",
            n = 1, universe = "raw input files")
}

# 4.3 Fecha, versión de datos, clasificación de ingreso y semilla.
anotar_05("meta_numbers_date", value = FECHA_CIFRAS, unit = NA, fmt = "text",
          def = "Date the v1 numbers were assembled and frozen in figures/numbers.json",
          filter = "figures/numbers.json", source_cell = "T18 (R/05_numbers_json.R §4.3)",
          used_in = c("notebook.reproducibilidad"), method = "descriptive", status = "descriptive",
          n = 1, universe = "project metadata")
anotar_05("meta_wpp_version", value = VERSION_WPP, unit = NA, fmt = "text",
          def = "Data source and version used for every number",
          filter = "WPP 2024 files read by R/01_preparar_datos.R and the analysis scripts",
          source_cell = "T18 (R/05_numbers_json.R §4.3)", used_in = c("notebook.fuentes", "references"),
          method = "descriptive", status = "descriptive", say = "UN World Population Prospects 2024",
          n = 1, universe = "project metadata")
anotar_05("meta_income_classification", value = CLASIFICACION_INGRESO, unit = NA, fmt = "text",
          def = "Income classification used for every income comparison",
          filter = "data/raw/wb_api_income_2026-10-22.csv", source_cell = "T18 (R/05_numbers_json.R §4.3)",
          used_in = c("notebook.decisiones", "references"), method = "descriptive", status = "descriptive",
          say = "today's income groups (World Bank FY2027)", n = 1, universe = "project metadata",
          sens_note = "UN income aggregates (World Bank classification of May 2024) used only as a sensitivity check")
anotar_05("meta_seed", value = SEMILLA, unit = NA, fmt = "0",
          def = sprintf("Random seed set just before every resampling, permutation and k-means; RNGkind: %s",
                        paste(RNGkind(), collapse = " / ")),
          filter = "all scripts in R/", source_cell = "T18 (R/05_numbers_json.R §4.3)",
          used_in = c("notebook.reproducibilidad"), method = "descriptive", status = "descriptive",
          n = 1, universe = "project metadata")

# 4.4 Nombre del equipo (portada). El repositorio público aún no existe: si
# docs/equipo.json no trae `repo`, la clave queda como faltante (no se inventa).
if (!is.null(equipo$team_name) && nzchar(equipo$team_name)) {
  anotar_05("team_name", value = equipo$team_name, unit = NA, fmt = "text",
            def = "Team name as confirmed by the team (docs/equipo.json)", filter = "docs/equipo.json",
            source_cell = "T18 (R/05_numbers_json.R §4.4)", used_in = c("cover", "narration.cover"),
            method = "descriptive", status = "descriptive", n = 1, universe = "project metadata")
}
if (!is.null(equipo$repo) && length(equipo$repo) == 1 && !is.na(equipo$repo) && nzchar(equipo$repo)) {
  anotar_05("repo", value = equipo$repo, unit = NA, fmt = "text",
            def = "Public GitHub repository (user/repository), from docs/equipo.json", filter = "docs/equipo.json",
            source_cell = "T18 (R/05_numbers_json.R §4.4)", used_in = c("slide4.ethics", "references"),
            method = "descriptive", status = "descriptive", n = 1, universe = "project metadata")
}
informar_05("Claves añadidas por 05: %d (%s)", length(claves_nuevas), paste(claves_nuevas, collapse = ", "))

# 4.5 Verificación independiente (QA-stats): verified, verified_by, verified_on, nota_qa.
# QUÉ: aplica docs/qa/verificacion_consolidada.csv (210 cifras recalculadas desde
#      los CSV crudos por los lotes 1-4 de docs/qa/verificacion_lote_*.R).
# POR QUÉ: QA-stats marca cada cifra de pantalla y voz (plan §7.7). Una clave solo
#      queda en verified = true si su cifra actual (value, IC, sensibilidad, IP y
#      método) tiene la MISMA huella que la que se verificó; si cambió, queda en
#      false y nota_qa lo dice (ASA B.4 y C.2: un ✔ viejo nunca pasa a un número
#      nuevo). Las demás claves llevan en nota_qa por qué no se verificaron.
source(here::here("R", "qa_verificacion.R"))
RUTA_QA_CONSOLIDADA <- file.path(RUTA_DOCS, "qa", "verificacion_consolidada.csv")
qa_05 <- aplicar_verificacion_qa(total, RUTA_QA_CONSOLIDADA)
total <- qa_05$registro
tabla_qa_05 <- as.data.frame(table(estado = qa_05$resumen$estado, pantalla = ifelse(qa_05$resumen$pantalla, "pantalla/voz", "solo notebook")),
                             responseName = "claves")
print(tabla_qa_05[tabla_qa_05$claves > 0, ], row.names = FALSE)
qa_pant_sin <- qa_05$resumen$clave[qa_05$resumen$pantalla & qa_05$resumen$estado != "verificada"]
informar_05("Verificadas: %d de %d claves; de pantalla o voz sin verificar: %d (%s).",
            sum(qa_05$resumen$estado == "verificada"), nrow(qa_05$resumen), length(qa_pant_sin),
            if (length(qa_pant_sin)) paste(qa_pant_sin, collapse = ", ") else "ninguna")

# =============================================================================
# 5. Escritura de figures/numbers.json
# =============================================================================
# QUÉ: escribe el registro combinado con claves en orden alfabético (radix).
# POR QUÉ: un solo archivo alimenta diapositivas (numbers.js) y guion
#          (fill_numbers.py); el orden fijo hace los diffs legibles.
seccion_05("5. Escritura")
total <- total[order(names(total), method = "radix")]
guardar_numbers(total, RUTA_NUMBERS, ordenar = FALSE)
releido <- leer_numbers(RUTA_NUMBERS)
stopifnot(identical(names(releido), names(total)))
informar_05("Escrito %s: %d claves (%d de análisis + %d de 05); sha256 %s", RUTA_NUMBERS, length(total),
            length(claves_analisis), length(claves_nuevas), sha256_archivo(RUTA_NUMBERS))

# =============================================================================
# 6. Comprobaciones: claves obligatorias del plan §4 y {clave} del storyboard
# =============================================================================
# QUÉ: lista lo que pide el plan y lo que nombra el storyboard y dice qué falta.
# POR QUÉ: QA-stats falla si una clave narrada no existe o no tiene método; lo
#          que falta se reporta para que lo calcule su análisis (no se inventa).
seccion_05("6. Comprobaciones")

# 6.1 Tabla de alias de las diapositivas (fuente única en slides/js/numbers.js).
leer_alias <- function(ruta) {
  if (!file.exists(ruta)) return(list(alias = list(), range = list()))
  txt <- paste(readLines(ruta, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  m <- regmatches(txt, regexpr("/\\*ALIASES-BEGIN\\*/[\\s\\S]*?/\\*ALIASES-END\\*/", txt, perl = TRUE))
  if (length(m) == 0) return(list(alias = list(), range = list()))
  js <- sub("^/\\*ALIASES-BEGIN\\*/", "", sub("/\\*ALIASES-END\\*/$", "", m))
  jsonlite::fromJSON(js, simplifyVector = FALSE)
}
ALIAS <- leer_alias(RUTA_NUMBERS_JS)

# Resuelve una clave como lo hacen las diapositivas: directa, alias o rango
# derivado de sens_low–sens_high de otra clave.
resolver_clave <- function(k, reg = total) {
  if (!is.null(reg[[k]])) return(list(estado = "presente", via = k))
  cand <- unlist(ALIAS$alias[[k]])
  hit <- cand[vapply(cand, function(z) !is.null(reg[[z]]), logical(1))]
  if (length(hit) > 0) return(list(estado = "alias", via = hit[1]))
  base <- ALIAS$range[[k]]
  if (!is.null(base) && !is.null(reg[[base]]) && !is.na(reg[[base]]$sens_low) && !is.na(reg[[base]]$sens_high)) {
    return(list(estado = "rango derivado", via = base))
  }
  list(estado = "FALTA", via = NA_character_)
}

# 6.2 Claves obligatorias leídas del propio plan (§4, "Claves obligatorias (v2)").
claves_del_plan <- function(ruta) {
  txt <- readLines(ruta, encoding = "UTF-8", warn = FALSE)
  ini <- grep("^\\*\\*Claves obligatorias \\(v2\\)\\*\\*", txt)
  fin <- grep("^- \\*\\*Retiradas\\*\\*", txt)
  if (length(ini) != 1 || length(fin) != 1 || fin <= ini) stop("No encuentro la lista de claves obligatorias en ", ruta, call. = FALSE)
  lineas <- txt[(ini + 1):(fin - 1)]
  lineas <- lineas[grepl("^- \\*", lineas)]
  out <- list()
  for (lin in lineas) {
    sec <- trimws(sub("^- \\*([^*]+?):?\\*.*$", "\\1", lin))
    toks <- gsub("`", "", regmatches(lin, gregexpr("`[^`]+`", lin))[[1]])
    claves <- character(0)
    for (t in toks) {
      if (startsWith(t, "_")) {
        # "(+ `_1m`)": el sufijo se aplica a las claves de la línea que comparten
        # el prefijo de la clave anterior (n_type_* -> n_type_*_1m; r2_tfr_* -> *_cv).
        prev <- tail(claves, 1)
        pref <- sub("_[^_]+$", "_", prev)
        base <- claves[startsWith(claves, pref) & !grepl("_(1m|cv)$", claves)]
        claves <- c(claves, paste0(base, t))
      } else if (grepl("/", t)) {
        # "examples_type_C/D/E" -> examples_type_C, _D, _E
        partes <- strsplit(t, "/", fixed = TRUE)[[1]]
        raiz <- sub("[^_]+$", "", partes[1])
        claves <- c(claves, partes[1], paste0(raiz, partes[-1]))
      } else {
        claves <- c(claves, t)
      }
    }
    out[[sec]] <- unique(claves)
  }
  out
}
OBLIG_PLAN <- claves_del_plan(RUTA_PLAN_IMPL)
oblig_plan <- unique(unlist(OBLIG_PLAN, use.names = FALSE))
oblig_codigo <- unique(unlist(CLAVES_OBLIGATORIAS_V2, use.names = FALSE))
dif_plan_codigo <- list(solo_plan = setdiff(oblig_plan, oblig_codigo), solo_codigo = setdiff(oblig_codigo, oblig_plan))
informar_05("Claves obligatorias del plan §4: %d (lista transcrita en R/incertidumbre.R: %d; solo en el plan: %s; solo en el código: %s)",
            length(oblig_plan), length(oblig_codigo),
            if (length(dif_plan_codigo$solo_plan)) paste(dif_plan_codigo$solo_plan, collapse = ", ") else "ninguna",
            if (length(dif_plan_codigo$solo_codigo)) paste(dif_plan_codigo$solo_codigo, collapse = ", ") else "ninguna")
seccion_de <- function(k) {
  s <- names(OBLIG_PLAN)[vapply(OBLIG_PLAN, function(v) k %in% v, logical(1))]
  if (length(s) == 0) NA_character_ else s[1]
}
estado_oblig <- do.call(rbind, lapply(union(oblig_plan, oblig_codigo), function(k) {
  r <- resolver_clave(k)
  data.frame(clave = k, seccion = seccion_de(k), estado = r$estado, via = r$via, stringsAsFactors = FALSE)
}))
faltan_oblig <- estado_oblig[estado_oblig$estado == "FALTA", , drop = FALSE]
informar_05("Obligatorias presentes: %d de %d; faltan %d.", sum(estado_oblig$estado != "FALTA"),
            nrow(estado_oblig), nrow(faltan_oblig))
if (nrow(faltan_oblig) > 0) print(faltan_oblig[, c("clave", "seccion")], row.names = FALSE)

# 6.3 Marcadores {clave} y {clave.campo} del storyboard (mismo patrón que
# slides/script/fill_numbers.py, pero admitiendo claves con ".8" como share_keep_ge_0.8).
marcadores_md <- function(ruta) {
  txt <- paste(readLines(ruta, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  pat <- "(?<!\\{)\\{([A-Za-z_][A-Za-z0-9_]*(?:\\.[0-9]+)?)(?:\\.([A-Za-z_][A-Za-z0-9_]*))?(?::[0-9]+)?\\}(?!\\})"
  m <- regmatches(txt, gregexpr(pat, txt, perl = TRUE))[[1]]
  if (length(m) == 0) return(data.frame(clave = character(0), campo = character(0)))
  cl <- sub(pat, "\\1", m, perl = TRUE)
  ca <- sub(pat, "\\2", m, perl = TRUE)
  unique(data.frame(clave = cl, campo = ca, stringsAsFactors = FALSE))
}
mk <- marcadores_md(RUTA_STORYBOARD)
claves_sb <- sort(unique(mk$clave))
estado_sb <- do.call(rbind, lapply(claves_sb, function(k) {
  if (k %in% names(MARCADORES_GENERICOS)) {
    via <- if (k %in% names(EQUIVALENCIA_GENERICOS)) EQUIVALENCIA_GENERICOS[[k]] else NA_character_
    est <- if (!is.na(via) && !is.null(total[[via]])) "genérico (equivale a otra clave)" else "no es clave"
    return(data.frame(clave = k, estado = est, via = via, nota = MARCADORES_GENERICOS[[k]], stringsAsFactors = FALSE))
  }
  r <- resolver_clave(k)
  campos <- setdiff(mk$campo[mk$clave == k], "")
  nota <- ""
  if (r$estado != "FALTA" && length(campos) > 0) {
    e <- total[[r$via]]
    sin_campo <- campos[vapply(campos, function(cp) is.null(e[[cp]]) || all(is.na(e[[cp]])), logical(1))]
    if (length(sin_campo) > 0) nota <- paste0("sin campo: ", paste(sin_campo, collapse = ", "))
  }
  data.frame(clave = k, estado = r$estado, via = r$via, nota = nota, stringsAsFactors = FALSE)
}))
faltan_sb <- estado_sb[estado_sb$estado == "FALTA", , drop = FALSE]
campos_sb_faltantes <- estado_sb[nzchar(estado_sb$nota) & grepl("^sin campo", estado_sb$nota), , drop = FALSE]
informar_05("Storyboard: %d marcadores distintos; resueltos %d (directos %d, alias %d, rango derivado %d); no son clave %d; faltan %d.",
            nrow(estado_sb), sum(estado_sb$estado %in% c("presente", "alias", "rango derivado")),
            sum(estado_sb$estado == "presente"), sum(estado_sb$estado == "alias"),
            sum(estado_sb$estado == "rango derivado"), sum(!estado_sb$estado %in% c("presente", "alias", "rango derivado", "FALTA")),
            nrow(faltan_sb))
print(estado_sb[estado_sb$estado != "presente", , drop = FALSE], row.names = FALSE)
if (nrow(campos_sb_faltantes) > 0) {
  cat("\nMarcadores {clave.campo} cuyo campo está vacío:\n"); print(campos_sb_faltantes, row.names = FALSE)
}

# 6.4 Claves de las diapositivas (data-num de slides/index.html), solo informativo.
claves_html <- character(0)
if (file.exists(RUTA_INDEX_HTML)) {
  html <- paste(readLines(RUTA_INDEX_HTML, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  claves_html <- sort(unique(sub('^data-(num|say|flags)="([^"]+)"$', "\\2",
                                 regmatches(html, gregexpr('data-(num|say|flags)="[^"]+"', html))[[1]])))
}
estado_html <- do.call(rbind, lapply(claves_html, function(k) {
  if (k %in% names(MARCADORES_GENERICOS)) return(data.frame(clave = k, estado = "no es clave", via = NA_character_))
  r <- resolver_clave(k)
  data.frame(clave = k, estado = r$estado, via = r$via, stringsAsFactors = FALSE)
}))
faltan_html <- if (is.null(estado_html)) estado_html else estado_html[estado_html$estado == "FALTA", , drop = FALSE]
informar_05("slides/index.html: %d claves distintas en data-num/data-say/data-flags; faltan %d (%s).",
            length(claves_html), if (is.null(faltan_html)) 0L else nrow(faltan_html),
            if (is.null(faltan_html) || nrow(faltan_html) == 0) "ninguna" else paste(faltan_html$clave, collapse = ", "))

# 6.5 Claves retiradas (plan §4): no deben usarse en pantalla ni en la voz.
retiradas_usadas <- intersect(CLAVES_RETIRADAS_V2, c(claves_sb, claves_html))
retiradas_en_json <- intersect(CLAVES_RETIRADAS_V2, names(total))
informar_05("Claves retiradas usadas en storyboard o diapositivas: %s; presentes en numbers.json: %s",
            if (length(retiradas_usadas)) paste(retiradas_usadas, collapse = ", ") else "ninguna",
            if (length(retiradas_en_json)) paste(retiradas_en_json, collapse = ", ") else "ninguna")

# 6.6 Validación del esquema (validar_registro) con foco en lo que sale en pantalla.
es_pantalla <- function(u) any(grepl("^(cover|slide|narration|references|fig[0-9])", u))
claves_pantalla <- names(total)[vapply(total, function(e) es_pantalla(unlist(e$used_in)), logical(1))]
val <- validar_registro(total)
informar_05("validar_registro(): %d observaciones en %d claves.", nrow(val), length(unique(val$clave)))
if (nrow(val) > 0) {
  tipo <- sub(":.*$", "", sub("^IC con method '[^']+'.*$", "IC con un método que no puede salir en pantalla", val$problema))
  print(as.data.frame(table(observacion = tipo), responseName = "n"), row.names = FALSE)
  val_pant <- val[val$clave %in% claves_pantalla, , drop = FALSE]
  cat(sprintf("\nDe ellas, en claves usadas en pantalla o en la voz (%d):\n", nrow(val_pant)))
  if (nrow(val_pant) > 0) print(val_pant, row.names = FALSE)
}

# =============================================================================
# 7. Tabla de verificación para QA-stats (claves de pantalla y voz)
# =============================================================================
# QUÉ: una fila por clave usada en la portada, las diapositivas, la voz, las
#      referencias o las figuras del vídeo, con su valor formateado.
# POR QUÉ: QA-stats marca ✔ clave por clave (plan §7.7); nada se teclea a mano.
seccion_05("7. Tabla de verificación")
valor_formateado <- function(e) {
  v <- e$value
  u <- e$unit
  if (is.data.frame(v) || (is.list(v) && is.null(names(v)))) return(resumir_valor(v, 90))
  if (is.list(v)) return(resumir_valor(v, 90))
  if (length(v) > 1) return(paste(as.character(unclass(v)), collapse = ", "))
  txt <- if (is.numeric(v)) tryCatch(formatear_cifra(v, e$fmt), error = function(err) format(v)) else as.character(v)
  # La unidad solo acompaña a números (los textos ya son la cifra completa).
  if (is.numeric(v) && !is.null(u) && length(u) == 1 && !is.na(u) && nzchar(u) && !(u %in% c("text"))) txt <- paste(txt, u)
  txt
}
claves_verif <- sort(union(claves_pantalla, intersect(c(estado_sb$via[!is.na(estado_sb$via)], claves_sb), names(total))),
                     method = "radix")
tabla_verif <- data.frame(
  clave = claves_verif,
  valor = vapply(claves_verif, function(k) valor_formateado(total[[k]]), character(1)),
  method = vapply(claves_verif, function(k) as.character(total[[k]]$method), character(1)),
  ic = vapply(claves_verif, function(k) {
    e <- total[[k]]
    if (!is.na(e$ci_low) && !is.na(e$ci_high)) sprintf("[%s; %s]", format(signif(e$ci_low, 4)), format(signif(e$ci_high, 4))) else ""
  }, character(1)),
  used_in = vapply(claves_verif, function(k) paste(unlist(total[[k]]$used_in), collapse = " "), character(1)),
  stringsAsFactors = FALSE, row.names = NULL
)
informar_05("Claves para verificar (pantalla, voz, referencias o figuras del vídeo): %d", nrow(tabla_verif))
# Una línea por clave (ancho fijo) para que se lea en la consola y en el notebook.
recortar <- function(x, n) ifelse(nchar(x) > n, paste0(substr(x, 1, n - 1), "…"), x)
cat(sprintf("%-34s %-46s %-29s %-20s %s", "clave", "valor", "method", "ic", "used_in"), sep = "\n")
cat(sprintf("%-34s %-46s %-29s %-20s %s", tabla_verif$clave, recortar(tabla_verif$valor, 46),
            tabla_verif$method, tabla_verif$ic, recortar(tabla_verif$used_in, 60)), sep = "\n")

# =============================================================================
# 8. Resumen
# =============================================================================
seccion_05("8. Resumen")
faltantes_todas <- sort(unique(c(faltan_oblig$clave, faltan_sb$clave)))
resumen_05 <- list(
  claves_total = length(total),
  claves_por_parcial = vapply(parciales, length, integer(1)),
  claves_nuevas = claves_nuevas,
  duplicadas_iguales = duplicadas_iguales,
  conflictos = nrow(conflictos),
  faltan_obligatorias = faltan_oblig$clave,
  faltan_storyboard = faltan_sb$clave,
  faltantes = faltantes_todas,
  verificadas = qa_05$resumen$clave[qa_05$resumen$estado == "verificada"],
  pantalla_sin_verificar = qa_pant_sin,
  sha256_numbers = sha256_archivo(RUTA_NUMBERS)
)
informar_05("numbers.json: %d claves · conflictos 0 · faltan %d (obligatorias: %s | storyboard: %s)",
            resumen_05$claves_total, length(faltantes_todas),
            if (length(resumen_05$faltan_obligatorias)) paste(resumen_05$faltan_obligatorias, collapse = ", ") else "ninguna",
            if (length(resumen_05$faltan_storyboard)) paste(resumen_05$faltan_storyboard, collapse = ", ") else "ninguna")
informar_05("Verificación independiente: %d claves con verified = true; de pantalla o voz sin verificar: %s",
            length(resumen_05$verificadas),
            if (length(qa_pant_sin)) paste(qa_pant_sin, collapse = ", ") else "ninguna")
informar_05("05_numbers_json.R terminó en %.1f s.", as.numeric(difftime(Sys.time(), t_inicio_05, units = "secs")))
invisible(resumen_05)
