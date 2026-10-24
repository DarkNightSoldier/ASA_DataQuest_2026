#!/usr/bin/env Rscript
# =============================================================================
# incertidumbre.R
# Infraestructura COMPARTIDA de incertidumbre y de registro de cifras para los
# agentes de análisis (Q1, Q2, Q3) del proyecto ASA DataQuest 2026 (WPP2024).
#
# Qué trae:
#   1. bootstrap_bloques()  — bootstrap por BLOQUES (subregiones ONU) o iid
#                             por país, intervalo percentil.
#   2. bootstrap_bca()      — bootstrap iid de países con IC BCa (respaldo
#                             percentil), para los campos `ci_iid_*` y para
#                             los cocientes de sumas (H1).
#   3. jackknife_unidades() — "quitar un país a la vez" (influencia, sens_*).
#   4. ic_wilson()          — IC de Wilson para proporciones / conteos de países.
#   5. registrar_cifra() y compañía — construyen `figures/numbers.json`
#      siguiendo EXACTAMENTE el esquema v2 de docs/00_plan_implementacion.md §4.
#   6. formatear_cifra() / formatear_rango() — redondeo único para pantalla.
#
# Decisiones documentadas (ASA 2022, B.2 / B.4 / C.4):
#   * Unidad de remuestreo = país (nunca país-año). En el bootstrap por
#     bloques la unidad es la subregión ONU completa (con todos sus países y,
#     si los datos son un panel, con todos sus años).
#   * Los intervalos que salen en pantalla usan
#     `method = "block bootstrap by subregion"` (plan §4, regla espacial): los
#     países vecinos se parecen y los IC iid salen 1,4–2,2 veces más estrechos
#     (docs/06_asesoria_espacial.md §3.6).
#   * Cada función fija la semilla (2026 por defecto) JUSTO antes de remuestrear
#     y DEVUELVE el estado previo del generador al terminar, para que el orden
#     en que se llamen las funciones no cambie los resultados de otros bloques.
#     El generador se declara: Mersenne-Twister / Inversion / Rejection.
#   * Los IC describen "sensitivity to which countries (or regions) are
#     included", no error muestral: los 237 países no son una muestra.
#
# Este archivo NO depende de config.R ni de los datos: solo de R base, `stats`,
# `jsonlite` y (para BCa) `boot`. Así se puede probar en aislado
# (ver R/tests_incertidumbre.R).
#
# Convención: código y comentarios en español; textos visibles en inglés.
# =============================================================================

suppressPackageStartupMessages({
  library(jsonlite)
})

# -----------------------------------------------------------------------------
# 0. Constantes del esquema de numbers.json (plan de implementación §4, v2)
# -----------------------------------------------------------------------------

# Orden EXACTO de los campos de cada clave (planos; NA -> null en el JSON).
CAMPOS_NUMBERS <- c(
  "value", "unit", "fmt", "say",
  "def", "filter", "n", "universe",
  "method", "ci_low", "ci_high", "ci_level",
  "ci_iid_low", "ci_iid_high", "ci_iid_method",
  "B", "seed", "resample_unit",
  "sens_low", "sens_high", "sens_note",
  "pi80_low", "pi80_high", "pi95_low", "pi95_high", "variant_source",
  "status", "hypothesis_id",
  "p_value", "p_adj", "p_adj_method",
  "source_cell", "used_in",
  "verified", "verified_by", "verified_on", "nota_qa"
)
# `nota_qa` (QA-stats, docs/QA_stats.md): motivo por el que una clave sigue sin
# verificar o advertencia para el guion; lo rellena R/qa_verificacion.R desde
# docs/qa/verificacion_consolidada.csv (nunca los scripts de análisis).

# Valores permitidos de `method` (plan §4).
METODOS_VALIDOS <- c(
  "none_census", "wilson", "bootstrap_bca", "bootstrap_perc",
  "block bootstrap by subregion", "jackknife", "km", "turnbull", "logrank",
  "permutation", "cv_r2", "un_pi", "sensitivity", "descriptive"
)

# Métodos con los que un intervalo PUEDE salir en pantalla (07 §4.1 punto 1).
METODOS_IC_PANTALLA <- c("block bootstrap by subregion", "wilson", "km", "un_pi")

# Valores permitidos de `status`.
ESTADOS_VALIDOS <- c("pre-specified", "exploratory", "descriptive")

# Métodos que exigen B y seed para poder reproducirse.
METODOS_CON_REMUESTREO <- c("bootstrap_bca", "bootstrap_perc",
                            "block bootstrap by subregion", "permutation")

# Campos que, si vienen como null en el JSON, se leen como NULL (no como NA).
CAMPOS_NULL_PERMITIDO <- c("verified_by", "verified_on")

# -----------------------------------------------------------------------------
# 1. Utilidades internas
# -----------------------------------------------------------------------------

# Ejecuta `expr` con una semilla fija y restaura después el estado previo del
# generador de números aleatorios (para no "consumir" el flujo global).
.con_semilla <- function(semilla, expr) {
  habia_semilla <- exists(".Random.seed", envir = globalenv(), inherits = FALSE)
  if (habia_semilla) estado_previo <- get(".Random.seed", envir = globalenv())
  tipo_previo <- RNGkind()
  on.exit({
    suppressWarnings(RNGkind(tipo_previo[1], tipo_previo[2], tipo_previo[3]))
    if (habia_semilla) {
      assign(".Random.seed", estado_previo, envir = globalenv())
    } else if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
      rm(".Random.seed", envir = globalenv())
    }
  }, add = TRUE)
  set.seed(semilla, kind = "Mersenne-Twister", normal.kind = "Inversion",
           sample.kind = "Rejection")
  force(expr)
}

# Busca una columna sin distinguir mayúsculas (p. ej. "subregion" encuentra
# "Subregion" si es la única coincidencia). Devuelve el nombre real.
.resolver_columna <- function(datos, nombre, rol = "columna") {
  if (nombre %in% names(datos)) return(nombre)
  cand <- names(datos)[tolower(names(datos)) == tolower(nombre)]
  if (length(cand) == 1) {
    message(sprintf("Nota: se usa la columna '%s' como %s ('%s' no existe).",
                    cand, rol, nombre))
    return(cand)
  }
  stop(sprintf("No existe la %s '%s' en los datos. Columnas disponibles: %s",
               rol, nombre, paste(utils::head(names(datos), 30), collapse = ", ")),
       call. = FALSE)
}

# Cuantiles percentil del bootstrap (tipo 7 de R, el de quantile() por defecto).
.ic_percentil <- function(replicas, nivel) {
  a <- (1 - nivel) / 2
  q <- stats::quantile(replicas, probs = c(a, 1 - a), na.rm = TRUE, names = FALSE, type = 7)
  q
}

# Aplica el estadístico protegiendo de errores (una réplica fallida = NA).
.aplicar_seguro <- function(estadistico, d, ...) {
  tryCatch({
    v <- estadistico(d, ...)
    if (!is.numeric(v) && !is.logical(v)) stop("el estadístico debe devolver un número")
    as.numeric(v)
  }, error = function(e) NA_real_)
}

# -----------------------------------------------------------------------------
# 2. Bootstrap por bloques (subregiones ONU) o iid por país
# -----------------------------------------------------------------------------

#' Bootstrap por bloques (subregión ONU) con IC percentil.
#'
#' Remuestrea BLOQUES completos con reemplazo: en cada réplica se sortean
#' tantos bloques como hay en los datos (p. ej. 20 subregiones para los 161
#' países >= 1 M), se juntan TODAS las filas de los bloques sorteados (un
#' bloque sorteado dos veces aparece dos veces) y se aplica
#' `estadistico(datos_remuestreados)`. El IC es el percentil de las réplicas.
#'
#' Con `bloque = NULL` hace el bootstrap iid de PAÍSES (unidad = `unidad`;
#' si los datos son un panel país-año se remuestrean países completos, nunca
#' filas sueltas). Sirve como sensibilidad / comparación (`ci_iid_*`).
#'
#' @param datos data.frame. Típicamente un corte transversal (una fila por
#'   país); también vale un panel (varias filas por país).
#' @param estadistico función `function(d, ...)` que recibe un data.frame con
#'   las mismas columnas que `datos` y devuelve un número (o un vector
#'   numérico corto con nombres; entonces valor/IC salen como vectores).
#'   Las réplicas traen además la columna `.copia` (n.º de sorteo del bloque o
#'   del país): si el estadístico necesita una clave única de país
#'   (p. ej. para `pivot_wider`), usar `interaction(ISO3_code, .copia)`.
#' @param bloque nombre de la columna que define los bloques
#'   (por defecto "subregion": en `comun_analisis.R` es la subregión M49 con
#'   Northern America rellenada). Se busca sin distinguir mayúsculas.
#'   `NULL` = bootstrap iid de países.
#' @param B número de réplicas (500 por defecto; para cifras en pantalla el
#'   plan pide B = 2000, ver `B_BOOT` en comun_analisis.R).
#' @param semilla semilla (2026). Se fija justo antes de remuestrear.
#' @param nivel nivel del intervalo (0.95).
#' @param unidad columna que identifica la unidad (país) para el caso iid.
#' @param ... argumentos extra que se pasan a `estadistico`.
#' @return lista con `valor`, `ci_low`, `ci_high`, `method`, `B`, `seed`,
#'   `ci_level`, `resample_unit`, `n_unidades`, `n_bloques`, `B_validas`,
#'   `n_fallidas`, `se_boot`, `sesgo_boot`, `replicas` (matriz B x k o vector).
#' @examples
#' # r2 <- function(d) summary(lm(MedianAgePop ~ TFR, d))$r.squared
#' # res <- bootstrap_bloques(corte_anio(2023), r2, B = 2000)
#' # res$valor; res$ci_low; res$ci_high; res$method
bootstrap_bloques <- function(datos, estadistico, bloque = "subregion", B = 500,
                              semilla = 2026, nivel = 0.95,
                              unidad = "ISO3_code", ...) {
  stopifnot(is.data.frame(datos), nrow(datos) > 1, is.function(estadistico),
            length(B) == 1, B >= 2, length(nivel) == 1, nivel > 0, nivel < 1)
  datos <- as.data.frame(datos)
  B <- as.integer(B)

  # --- valor puntual con los datos originales ---
  d0 <- datos
  d0$.copia <- 1L
  v0 <- tryCatch(estadistico(d0, ...), error = function(e) {
    stop("El estadístico falla con los datos originales: ", conditionMessage(e), call. = FALSE)
  })
  nombres_valor <- names(v0)
  valor <- as.numeric(v0)
  if (length(valor) == 0 || all(is.na(valor))) {
    stop("El estadístico devuelve NA (o nada) con los datos originales.", call. = FALSE)
  }
  k <- length(valor)

  # --- definir grupos a remuestrear ---
  if (is.null(bloque)) {
    if (unidad %in% names(datos)) {
      ids <- as.character(datos[[unidad]])
      grupos <- split(seq_len(nrow(datos)), ids)
      resample_unit <- "country"
    } else {
      message(sprintf("Nota: no existe la columna '%s'; se remuestrean FILAS (iid).", unidad))
      grupos <- as.list(seq_len(nrow(datos)))
      resample_unit <- "row"
    }
    # bootstrap iid de países (si hay panel: países completos), percentil
    method <- "bootstrap_perc"
  } else {
    col_bloque <- .resolver_columna(datos, bloque, "columna de bloques")
    vb <- datos[[col_bloque]]
    if (anyNA(vb)) {
      falt <- if (unidad %in% names(datos)) unique(datos[[unidad]][is.na(vb)]) else which(is.na(vb))
      stop(sprintf(paste0("La columna de bloques '%s' tiene NA (%s). Usa la columna `subregion` ",
                          "de comun_analisis.R (rellena Northern America) o completa los bloques."),
                   col_bloque, paste(utils::head(falt, 10), collapse = ", ")), call. = FALSE)
    }
    grupos <- split(seq_len(nrow(datos)), as.character(vb))
    if (length(grupos) < 5) {
      warning(sprintf("Solo hay %d bloques: el bootstrap por bloques es poco fiable con tan pocos.",
                      length(grupos)), call. = FALSE)
    }
    es_subregion <- tolower(col_bloque) %in% c("subregion", "parentid")
    method <- if (es_subregion) "block bootstrap by subregion" else paste("block bootstrap by", col_bloque)
    resample_unit <- if (es_subregion) "UN subregion" else col_bloque
    if (!es_subregion) {
      warning(sprintf(paste0("method = '%s' no está en la lista de métodos de numbers.json; ",
                             "úsalo solo como sensibilidad en el notebook."), method), call. = FALSE)
    }
  }
  n_grupos <- length(grupos)

  # --- réplicas ---
  replicas <- .con_semilla(semilla, {
    out <- matrix(NA_real_, nrow = B, ncol = k)
    for (b in seq_len(B)) {
      sorteo <- sample.int(n_grupos, n_grupos, replace = TRUE)
      filas <- unlist(grupos[sorteo], use.names = FALSE)
      copia <- rep(seq_along(sorteo), times = lengths(grupos[sorteo]))
      db <- datos[filas, , drop = FALSE]
      db$.copia <- copia
      rownames(db) <- NULL
      v <- .aplicar_seguro(estadistico, db, ...)
      if (length(v) == k) out[b, ] <- v
    }
    out
  })

  validas <- stats::complete.cases(replicas)
  n_fallidas <- sum(!validas)
  if (n_fallidas > 0) {
    warning(sprintf("%d de %d réplicas fallaron o dieron NA; se excluyen del IC.", n_fallidas, B),
            call. = FALSE)
  }
  if (sum(validas) < 0.9 * B) stop("Más del 10 % de las réplicas fallaron: revisa el estadístico.", call. = FALSE)

  ic <- apply(replicas[validas, , drop = FALSE], 2, .ic_percentil, nivel = nivel)
  se <- apply(replicas[validas, , drop = FALSE], 2, stats::sd)
  sesgo <- colMeans(replicas[validas, , drop = FALSE]) - valor
  if (!is.null(nombres_valor) && length(nombres_valor) == k) {
    names(valor) <- nombres_valor
    colnames(ic) <- nombres_valor
    colnames(replicas) <- nombres_valor
    names(se) <- nombres_valor
    names(sesgo) <- nombres_valor
  }

  list(
    valor = valor,
    ci_low = ic[1, ],
    ci_high = ic[2, ],
    method = method,
    B = B,
    seed = semilla,
    ci_level = nivel,
    resample_unit = resample_unit,
    n_unidades = if (unidad %in% names(datos)) length(unique(datos[[unidad]])) else nrow(datos),
    n_bloques = n_grupos,
    B_validas = sum(validas),
    n_fallidas = n_fallidas,
    se_boot = se,
    sesgo_boot = sesgo,
    replicas = if (k == 1) as.numeric(replicas) else replicas
  )
}

# Alias con el nombre que usa el plan (T7: "función común boot_bloques()").
boot_bloques <- bootstrap_bloques

#' Extrae UN componente de un resultado de bootstrap con estadístico vectorial
#' (p. ej. `estadistico` devolvió c(high = ..., low = ...)), para pasarlo a
#' `registrar_cifra(ic = ...)`.
#' @param res resultado de bootstrap_bloques().
#' @param cual nombre o posición del componente.
extraer_ic <- function(res, cual) {
  out <- res
  for (campo in c("valor", "ci_low", "ci_high", "se_boot", "sesgo_boot")) {
    if (!is.null(res[[campo]])) out[[campo]] <- unname(res[[campo]][cual])
  }
  if (is.matrix(res$replicas)) out$replicas <- as.numeric(res$replicas[, cual])
  out
}

#' Bootstrap iid de PAÍSES con IC BCa (respaldo: percentil).
#'
#' Pensado para los campos `ci_iid_*` (comparación con el IC por bloques) y
#' para los cocientes de sumas con un país dominante (H1: Σ NetMigrations /
#' Σ PopChange), donde el plan pide BCa (B = 2000) + jackknife. Exige una fila
#' por país: si tienes un panel, resume antes por país o usa
#' `bootstrap_bloques(bloque = NULL)`.
#'
#' @param datos data.frame con una fila por unidad.
#' @param estadistico `function(d, ...)` que devuelve UN número.
#' @param B réplicas (2000 por defecto, como pide el plan para BCa).
#' @param semilla semilla (2026).
#' @param nivel nivel (0.95).
#' @param unidad columna de la unidad (para comprobar que no hay duplicados).
#' @return lista con `valor`, `ci_low`, `ci_high`, `method` ("bootstrap_bca"
#'   o "bootstrap_perc" si BCa no se pudo estimar), `B`, `seed`, `ci_level`,
#'   `resample_unit` = "country", `n_unidades`, `replicas`, `nota`.
bootstrap_bca <- function(datos, estadistico, B = 2000, semilla = 2026, nivel = 0.95,
                          unidad = "ISO3_code", ...) {
  if (!requireNamespace("boot", quietly = TRUE)) stop("Falta el paquete 'boot'.", call. = FALSE)
  stopifnot(is.data.frame(datos), nrow(datos) > 2, is.function(estadistico))
  datos <- as.data.frame(datos)
  if (unidad %in% names(datos) && anyDuplicated(datos[[unidad]])) {
    stop(sprintf(paste0("bootstrap_bca() necesita una fila por país y '%s' tiene duplicados. ",
                        "Resume el panel por país o usa bootstrap_bloques(bloque = NULL)."), unidad),
         call. = FALSE)
  }
  extra <- list(...)
  f_boot <- function(d, i) {
    db <- d[i, , drop = FALSE]
    db$.copia <- seq_len(nrow(db))
    do.call(estadistico, c(list(db), extra))
  }
  d0 <- datos
  d0$.copia <- 1L
  valor <- as.numeric(do.call(estadistico, c(list(d0), extra)))
  if (length(valor) != 1 || is.na(valor)) stop("bootstrap_bca() necesita un estadístico escalar y no NA.", call. = FALSE)

  bt <- .con_semilla(semilla, boot::boot(datos, f_boot, R = B))
  nota <- NA_character_
  ci <- tryCatch({
    x <- boot::boot.ci(bt, conf = nivel, type = "bca")$bca[4:5]
    if (any(!is.finite(x))) stop("BCa no finito")
    method <- "bootstrap_bca"
    x
  }, error = function(e) {
    nota <<- paste("BCa no estimable (", conditionMessage(e), "); se usa percentil.")
    NULL
  }, warning = function(w) {
    nota <<- paste("Aviso en BCa (", conditionMessage(w), "); se usa percentil.")
    NULL
  })
  if (is.null(ci)) {
    method <- "bootstrap_perc"
    ci <- .ic_percentil(bt$t[, 1], nivel)
  } else {
    method <- "bootstrap_bca"
  }
  list(valor = valor, ci_low = ci[1], ci_high = ci[2], method = method, B = as.integer(B),
       seed = semilla, ci_level = nivel, resample_unit = "country",
       n_unidades = nrow(datos), replicas = as.numeric(bt$t[, 1]), nota = nota)
}

#' Jackknife por unidad ("quitar un país a la vez").
#'
#' Sirve para `sens_low` / `sens_high` y para nombrar al país más influyente
#' (p. ej. EE. UU. en H1). Si `datos` es un panel, quita TODAS las filas del país.
#'
#' @param datos data.frame.
#' @param estadistico `function(d, ...)` que devuelve UN número.
#' @param unidad columna de la unidad ("ISO3_code").
#' @return lista con `valor`, `min`, `max`, `unidad_min`, `unidad_max`,
#'   `method` = "jackknife", `valores` (vector con nombre = unidad quitada).
jackknife_unidades <- function(datos, estadistico, unidad = "ISO3_code", ...) {
  stopifnot(is.data.frame(datos), is.function(estadistico))
  datos <- as.data.frame(datos)
  col <- .resolver_columna(datos, unidad, "columna de unidad")
  ids <- unique(as.character(datos[[col]]))
  d0 <- datos
  d0$.copia <- 1L
  valor <- as.numeric(estadistico(d0, ...))
  vals <- vapply(ids, function(u) {
    d <- datos[as.character(datos[[col]]) != u, , drop = FALSE]
    d$.copia <- 1L
    .aplicar_seguro(estadistico, d, ...)[1]
  }, numeric(1))
  names(vals) <- ids
  list(valor = valor, min = min(vals, na.rm = TRUE), max = max(vals, na.rm = TRUE),
       unidad_min = names(vals)[which.min(vals)], unidad_max = names(vals)[which.max(vals)],
       method = "jackknife", valores = vals)
}

# -----------------------------------------------------------------------------
# 3. Wilson para proporciones y conteos de países
# -----------------------------------------------------------------------------

#' Intervalo de Wilson (sin corrección de continuidad).
#'
#' Equivale a `prop.test(x, n, correct = FALSE)$conf.int`, pero en forma
#' cerrada y vectorizada. Interpretación de "superpoblación" (transiciones
#' posibles), no de muestreo: los países no son una muestra (memo INF §1).
#'
#' @param x número de "éxitos" (p. ej. 105 países con la mortalidad primero).
#' @param n total (p. ej. 108).
#' @param nivel nivel (0.95).
#' @param escala 1 = proporción (0–1); 100 = porcentaje.
#' @return lista con `valor` (x/n * escala), `ci_low`, `ci_high` (en la misma
#'   escala), `conteo_low`, `conteo_high` (IC expresado en número de países),
#'   `method` = "wilson", `x`, `n`, `ci_level`, `B` = NA, `seed` = NA.
#' @examples
#' # w <- ic_wilson(105, 108, escala = 100)   # 97.2 [92.1; 99.1]
ic_wilson <- function(x, n, nivel = 0.95, escala = 1) {
  stopifnot(is.numeric(x), is.numeric(n), all(n > 0), all(x >= 0), all(x <= n),
            nivel > 0, nivel < 1)
  if (any(n < 10)) warning("Wilson con n < 10: el memo de inferencia recomienda no usarlo.", call. = FALSE)
  z <- stats::qnorm(1 - (1 - nivel) / 2)
  p <- x / n
  centro <- (p + z^2 / (2 * n)) / (1 + z^2 / n)
  medio <- (z / (1 + z^2 / n)) * sqrt(p * (1 - p) / n + z^2 / (4 * n^2))
  lo <- pmax(0, centro - medio)
  hi <- pmin(1, centro + medio)
  # En los extremos el límite es exacto (evita 0.999999999 por redondeo).
  lo[x == 0] <- 0
  hi[x == n] <- 1
  list(valor = p * escala, ci_low = lo * escala, ci_high = hi * escala,
       conteo_low = lo * n, conteo_high = hi * n,
       method = "wilson", x = x, n = n, ci_level = nivel, B = NA, seed = NA)
}

# -----------------------------------------------------------------------------
# 4. Formato único de cifras (pantalla y guion)
# -----------------------------------------------------------------------------

# Redondeo "comercial" (mitad hacia afuera del cero), con una tolerancia
# minúscula para que 0.15 -> 0.2 y 70.65 -> 70.7 como esperaría una persona
# (round() de R redondea al valor binario representado: round(0.15, 1) = 0.1).
.redondear <- function(x, d) {
  m <- 10^d
  s <- sign(x)
  s * floor(abs(x) * m + 0.5 + 1e-9) / m
}

#' Formatea una cifra con un código `fmt` (el mismo que se guarda en numbers.json).
#'
#' Códigos válidos:
#'   * `"0"`, `"0.0"`, `"0.00"`, ... — n.º fijo de decimales (el número de
#'     ceros tras el punto).
#'   * `"#,##0"`, `"#,##0.0"`, ... — igual, con separador de miles ",".
#'   * prefijo `"+"` (p. ej. `"+0.00"`) — muestra siempre el signo.
#'   * sufijo `"%"` (p. ej. `"0%"`, `"0.0%"`) — AÑADE el símbolo %; el valor
#'     ya debe estar en porcentaje (NO se multiplica por 100).
#'   * `"sig2"`, `"sig3"` — cifras significativas.
#'   * `"text"` o `NA` — texto tal cual (nombres de países, listas).
#' Redondeo: mitad hacia afuera del cero (ver `.redondear`); nunca "-0".
#'
#' @param value número(s) o texto.
#' @param fmt código de formato (ver arriba).
#' @return vector de caracteres (NA si `value` es NA).
#' @examples
#' # formatear_cifra(70.66, "0")       # "71"
#' # formatear_cifra(70.65, "0.0%")    # "70.7%"
#' # formatear_cifra(2200.4, "#,##0")  # "2,200"
#' # formatear_cifra(-0.4149, "+0.00") # "-0.41"
#' # formatear_cifra(0.7734, "sig2")   # "0.77"
formatear_cifra <- function(value, fmt) {
  if (is.list(value)) value <- unlist(value)
  if (length(fmt) != 1) stop("`fmt` debe ser un solo código.", call. = FALSE)
  if (is.na(fmt) || fmt %in% c("", "text")) {
    return(ifelse(is.na(value), NA_character_, as.character(value)))
  }
  if (!is.numeric(value)) {
    stop(sprintf("formatear_cifra(): fmt = '%s' necesita un valor numérico.", fmt), call. = FALSE)
  }
  if (grepl("^sig[0-9]+$", fmt)) {
    s <- as.integer(sub("^sig", "", fmt))
    out <- vapply(value, function(v) {
      if (is.na(v)) return(NA_character_)
      if (v == 0) return("0")
      d <- s - 1 - floor(log10(abs(v)))          # puede ser negativo (1234 -> 1200)
      r <- .redondear(v, d)
      # el redondeo puede subir un orden de magnitud (0.0999 -> 0.10)
      d <- s - 1 - floor(log10(abs(r)))
      formatC(.redondear(v, d), format = "f", digits = max(0, d), big.mark = ",")
    }, character(1))
    return(unname(out))
  }
  patron <- "^(\\+?)(#,##)?0(\\.(0+))?(%?)$"
  if (!grepl(patron, fmt)) {
    stop(sprintf("Código fmt desconocido: '%s'. Usa '0', '0.0', '#,##0', '+0.00', '0.0%%', 'sig2' o 'text'.", fmt),
         call. = FALSE)
  }
  signo <- sub(patron, "\\1", fmt) == "+"
  miles <- sub(patron, "\\2", fmt) == "#,##"
  dec <- nchar(sub(patron, "\\4", fmt))
  pct <- sub(patron, "\\5", fmt) == "%"
  r <- .redondear(value, dec)
  r[!is.na(r) & r == 0] <- 0                      # elimina "-0"
  out <- formatC(abs(r), format = "f", digits = dec, big.mark = if (miles) "," else "")
  pref <- ifelse(r < 0, "-", if (signo) "+" else "")
  pref[!is.na(r) & r == 0] <- ""
  out <- paste0(pref, out, if (pct) "%" else "")
  out[is.na(value)] <- NA_character_
  out
}

#' Formatea un intervalo "a–b" (guion largo) con el mismo `fmt`.
#' @examples
#' # formatear_rango(55.8, 114.0, "0")  # "56–114"
formatear_rango <- function(low, high, fmt, sep = "\u2013") {
  ifelse(is.na(low) | is.na(high), NA_character_,
         paste0(formatear_cifra(low, fmt), sep, formatear_cifra(high, fmt)))
}

# Comprueba (sin error) si un código fmt es válido.
fmt_valido <- function(fmt) {
  is.na(fmt) || tryCatch({ formatear_cifra(1.5, fmt); TRUE }, error = function(e) FALSE)
}

# -----------------------------------------------------------------------------
# 5. Registro de cifras -> figures/numbers.json (esquema v2, plan §4)
# -----------------------------------------------------------------------------

#' Crea un registro vacío (lista con nombres; se escribe como `{}`).
nuevo_registro <- function() structure(list(), names = character(0))

# Normaliza el campo `value` para que el JSON salga como se espera:
#   * vector atómico con nombres (p. ej. tamaños de grupos) -> objeto JSON;
#   * vector atómico sin nombres de longitud > 1 -> arreglo JSON;
#   * longitud 1 -> escalar (para forzar arreglo de un elemento usa I(x));
#   * data.frame -> arreglo de objetos (una fila = un objeto).
.normalizar_value <- function(value) {
  if (is.factor(value)) value <- as.character(value)
  if (is.atomic(value) && !is.null(names(value)) && length(value) > 1 && !inherits(value, "AsIs")) {
    return(as.list(value))
  }
  value
}

#' Añade o actualiza una cifra en el registro (una clave de numbers.json).
#'
#' Construye una entrada con TODOS los campos del esquema v2 (plan §4), en el
#' orden de `CAMPOS_NUMBERS`; lo que no se da queda NA (-> `null` en el JSON).
#' `verified` siempre arranca en FALSE, `verified_by` / `verified_on` en NULL
#' (los rellena QA-stats con `marcar_verificada()`). Si la clave ya existía y
#' la cifra NO cambió (value, IC, sensibilidad y método idénticos) se conserva
#' la verificación; si cambió, se reinicia.
#'
#' @param registro lista creada con `nuevo_registro()` o `leer_numbers()`.
#' @param clave nombre de la clave (letras, números, "_" y ".").
#' @param value valor (número, texto, vector, lista con nombres o data.frame).
#' @param unit unidad ("%", "countries", "years", "R2", "million", ... o NA).
#' @param fmt código de formato de pantalla (ver `formatear_cifra()`).
#' @param def definición en inglés (qué se calculó, con fórmula y ventana).
#' @param filter filtro aplicado (p. ej. "161 countries >= 1 M, 2023").
#' @param source_cell celda / sección del notebook (p. ej. "T3.2").
#' @param used_in vector de builds/frases que la usan (puede ser character(0)).
#' @param ci_low,ci_high límites del IC del método declarado.
#' @param method uno de `METODOS_VALIDOS`.
#' @param B,seed réplicas y semilla (obligatorios si hay remuestreo).
#' @param sens_low,sens_high rango entre decisiones razonables.
#' @param status "pre-specified", "exploratory" o "descriptive".
#' @param ic (opcional) resultado de `bootstrap_bloques()`, `bootstrap_bca()`
#'   o `ic_wilson()`: rellena ci_low, ci_high, method, B, seed, ci_level y
#'   resample_unit (y n para Wilson) si no se dieron a mano.
#' @param ic_iid (opcional) resultado iid para `ci_iid_low/high/method`.
#' @param ... otros campos del esquema: `say`, `n`, `universe`, `ci_level`,
#'   `ci_iid_low`, `ci_iid_high`, `ci_iid_method`, `resample_unit`,
#'   `sens_note`, `pi80_low`, `pi80_high`, `pi95_low`, `pi95_high`,
#'   `variant_source`, `hypothesis_id`, `p_value`, `p_adj`, `p_adj_method`.
#'   Un nombre fuera del esquema produce error.
#' @return el registro actualizado (lista).
registrar_cifra <- function(registro, clave, value, unit, fmt, def, filter,
                            source_cell, used_in,
                            ci_low = NA, ci_high = NA, method = NA, B = NA, seed = NA,
                            sens_low = NA, sens_high = NA, status = "pre-specified",
                            ic = NULL, ic_iid = NULL, ...) {
  extra <- list(...)
  # --- validaciones básicas ---
  if (!is.list(registro)) stop("`registro` debe ser una lista (usa nuevo_registro()).", call. = FALSE)
  if (!is.character(clave) || length(clave) != 1 || !grepl("^[A-Za-z0-9_.]+$", clave)) {
    stop("`clave` debe ser un texto con letras, números, '_' o '.'.", call. = FALSE)
  }
  permitidos_extra <- setdiff(CAMPOS_NUMBERS,
                              c("value", "unit", "fmt", "def", "filter", "source_cell", "used_in",
                                "ci_low", "ci_high", "method", "B", "seed", "sens_low", "sens_high",
                                "status", "verified", "verified_by", "verified_on", "nota_qa"))
  malos <- setdiff(names(extra), permitidos_extra)
  if (length(extra) > 0 && (is.null(names(extra)) || any(names(extra) == ""))) {
    stop("Todos los campos extra deben ir con nombre (p. ej. n = 161).", call. = FALSE)
  }
  if (length(malos) > 0) {
    stop(sprintf("Campo(s) fuera del esquema de numbers.json: %s. Permitidos: %s",
                 paste(malos, collapse = ", "), paste(permitidos_extra, collapse = ", ")), call. = FALSE)
  }

  # --- rellenar desde un resultado de IC (sin pisar lo dado a mano) ---
  vacio <- function(x) is.null(x) || length(x) == 0 || all(is.na(x))
  if (!is.null(ic)) {
    if (vacio(ci_low)) ci_low <- ic$ci_low
    if (vacio(ci_high)) ci_high <- ic$ci_high
    if (vacio(method)) method <- ic$method
    if (vacio(B) && !is.null(ic$B)) B <- ic$B
    if (vacio(seed) && !is.null(ic$seed)) seed <- ic$seed
    if (vacio(extra[["ci_level"]]) && !is.null(ic$ci_level)) extra$ci_level <- ic$ci_level
    if (vacio(extra[["resample_unit"]]) && !is.null(ic$resample_unit)) extra$resample_unit <- ic$resample_unit
    if (vacio(extra[["n"]]) && identical(ic$method, "wilson")) extra$n <- ic$n
  }
  if (!is.null(ic_iid)) {
    if (vacio(extra[["ci_iid_low"]])) extra$ci_iid_low <- ic_iid$ci_low
    if (vacio(extra[["ci_iid_high"]])) extra$ci_iid_high <- ic_iid$ci_high
    if (vacio(extra[["ci_iid_method"]])) extra$ci_iid_method <- ic_iid$method
  }
  escalar <- function(x, nombre) {
    if (is.null(x)) return(NA)
    if (length(x) != 1) stop(sprintf("El campo `%s` debe ser un solo valor (recibió %d).", nombre, length(x)), call. = FALSE)
    unname(x)
  }
  ci_low <- escalar(ci_low, "ci_low"); ci_high <- escalar(ci_high, "ci_high")
  method <- escalar(method, "method"); B <- escalar(B, "B"); seed <- escalar(seed, "seed")
  sens_low <- escalar(sens_low, "sens_low"); sens_high <- escalar(sens_high, "sens_high")
  status <- escalar(status, "status")

  if (!is.na(method) && !(method %in% METODOS_VALIDOS)) {
    stop(sprintf("method = '%s' no es válido. Usa uno de: %s", method,
                 paste(METODOS_VALIDOS, collapse = " | ")), call. = FALSE)
  }
  if (is.na(method)) {
    warning(sprintf("[%s] sin `method`: QA-stats falla si una clave narrada no tiene método.", clave), call. = FALSE)
  }
  if (is.na(status) || !(status %in% ESTADOS_VALIDOS)) {
    stop(sprintf("status = '%s' no es válido. Usa: %s", status, paste(ESTADOS_VALIDOS, collapse = ", ")),
         call. = FALSE)
  }
  if (!is.null(extra[["ci_iid_method"]]) && !is.na(extra[["ci_iid_method"]]) &&
      !(extra[["ci_iid_method"]] %in% METODOS_VALIDOS)) {
    stop(sprintf("ci_iid_method = '%s' no es válido.", extra[["ci_iid_method"]]), call. = FALSE)
  }
  hid <- if (is.null(extra[["hypothesis_id"]])) NA else extra[["hypothesis_id"]]
  if (status == "pre-specified" && is.na(hid)) {
    warning(sprintf("[%s] status 'pre-specified' sin hypothesis_id (ver docs/hipotesis_preinscritas.md).", clave),
            call. = FALSE)
  }
  if (!is.na(hid) && !grepl("^H[0-9]+[a-z]?$", hid)) {
    warning(sprintf("[%s] hypothesis_id '%s' no sigue el formato H1, H3a, ...", clave, hid), call. = FALSE)
  }
  if (!is.na(method) && method %in% METODOS_CON_REMUESTREO && (is.na(B) || is.na(seed))) {
    warning(sprintf("[%s] método '%s' sin B o seed: no se podrá reproducir.", clave, method), call. = FALSE)
  }
  if (!is.na(ci_low) && !is.na(ci_high) && ci_low > ci_high) {
    stop(sprintf("[%s] ci_low (%s) > ci_high (%s).", clave, ci_low, ci_high), call. = FALSE)
  }
  if (!is.na(sens_low) && !is.na(sens_high) && sens_low > sens_high) {
    stop(sprintf("[%s] sens_low (%s) > sens_high (%s).", clave, sens_low, sens_high), call. = FALSE)
  }
  if (is.numeric(value) && length(value) == 1 && !is.na(value) && !is.na(ci_low) && !is.na(ci_high) &&
      (value < ci_low || value > ci_high)) {
    warning(sprintf("[%s] value = %s queda fuera de su IC [%s; %s] (¿escalas distintas?).",
                    clave, value, ci_low, ci_high), call. = FALSE)
  }
  if (!fmt_valido(fmt)) {
    stop(sprintf("[%s] fmt = '%s' no es un código válido de formatear_cifra().", clave, fmt), call. = FALSE)
  }
  if (!is.na(method) && method == "block bootstrap by subregion" && vacio(extra[["resample_unit"]])) {
    extra$resample_unit <- "UN subregion"
  }
  if (!is.na(method) && method %in% c("bootstrap_bca", "bootstrap_perc") && vacio(extra[["resample_unit"]])) {
    extra$resample_unit <- "country"
  }
  if ((!is.na(ci_low) || !is.na(ci_high)) && vacio(extra[["ci_level"]])) extra$ci_level <- 0.95

  if (is.null(used_in) || (length(used_in) == 1 && is.na(used_in))) used_in <- character(0)

  # --- construir la entrada con todos los campos, en orden ---
  entrada <- setNames(vector("list", length(CAMPOS_NUMBERS)), CAMPOS_NUMBERS)
  for (campo in CAMPOS_NUMBERS) entrada[campo] <- list(NA)
  entrada["value"] <- list(.normalizar_value(value))
  entrada["unit"] <- list(escalar(unit, "unit"))
  entrada["fmt"] <- list(escalar(fmt, "fmt"))
  entrada["def"] <- list(escalar(def, "def"))
  entrada["filter"] <- list(escalar(filter, "filter"))
  entrada["method"] <- list(method)
  entrada["ci_low"] <- list(ci_low)
  entrada["ci_high"] <- list(ci_high)
  entrada["B"] <- list(B)
  entrada["seed"] <- list(seed)
  entrada["sens_low"] <- list(sens_low)
  entrada["sens_high"] <- list(sens_high)
  entrada["status"] <- list(status)
  entrada["source_cell"] <- list(escalar(source_cell, "source_cell"))
  entrada["used_in"] <- list(I(as.character(used_in)))
  for (campo in names(extra)) entrada[campo] <- list(escalar(extra[[campo]], campo))
  entrada["verified"] <- list(FALSE)
  entrada["verified_by"] <- list(NULL)
  entrada["verified_on"] <- list(NULL)

  # --- conservar la verificación si la cifra no cambió ---
  previa <- registro[[clave]]
  if (!is.null(previa)) {
    claves_cifra <- c("value", "ci_low", "ci_high", "sens_low", "sens_high", "method")
    igual <- all(vapply(claves_cifra, function(k) {
      isTRUE(all.equal(unclass(previa[[k]]), unclass(entrada[[k]]), check.attributes = FALSE))
    }, logical(1)))
    if (igual && isTRUE(previa$verified)) {
      entrada["verified"] <- list(TRUE)
      entrada["verified_by"] <- list(previa$verified_by)
      entrada["verified_on"] <- list(previa$verified_on)
    } else if (isTRUE(previa$verified)) {
      message(sprintf("[%s] la cifra cambió: se reinicia verified = FALSE.", clave))
    }
  }
  registro[[clave]] <- entrada
  registro
}

#' Marca una clave como verificada (uso de QA-stats).
marcar_verificada <- function(registro, clave, por, fecha = Sys.Date()) {
  if (is.null(registro[[clave]])) stop(sprintf("No existe la clave '%s'.", clave), call. = FALSE)
  registro[[clave]]["verified"] <- list(TRUE)
  registro[[clave]]["verified_by"] <- list(as.character(por))
  registro[[clave]]["verified_on"] <- list(as.character(fecha))
  registro
}

#' Revisa el registro y devuelve una tabla de problemas (sin parar).
#'
#' Comprueba: campos del esquema completos y en orden, `method` presente y
#' válido, `status` válido, `n` / `universe` presentes, IC en pantalla con
#' método admitido (07 §4.1), B/seed con remuestreo, IC ordenados.
#' @return data.frame con columnas `clave`, `problema` (0 filas = todo bien).
validar_registro <- function(registro) {
  prob <- list()
  add <- function(k, p) prob[[length(prob) + 1]] <<- data.frame(clave = k, problema = p)
  for (k in names(registro)) {
    e <- registro[[k]]
    if (!identical(names(e), CAMPOS_NUMBERS)) add(k, "campos distintos del esquema o en otro orden")
    m <- e$method
    if (is.null(m) || is.na(m)) add(k, "sin method")
    else if (!(m %in% METODOS_VALIDOS)) add(k, paste("method no válido:", m))
    if (is.null(e$status) || !(e$status %in% ESTADOS_VALIDOS)) add(k, "status no válido")
    if (is.null(e$n) || all(is.na(e$n))) add(k, "sin n")
    if (is.null(e$universe) || all(is.na(e$universe))) add(k, "sin universe")
    hay_ic <- !is.null(e$ci_low) && !is.na(e$ci_low)
    if (hay_ic && !is.null(m) && !is.na(m) && !(m %in% METODOS_IC_PANTALLA)) {
      add(k, sprintf("IC con method '%s': no puede salir en pantalla (usar bloques/wilson/km/un_pi)", m))
    }
    if (!is.null(m) && !is.na(m) && m %in% METODOS_CON_REMUESTREO && (is.na(e$B) || is.na(e$seed))) {
      add(k, "remuestreo sin B o seed")
    }
    if (hay_ic && !is.na(e$ci_high) && e$ci_low > e$ci_high) add(k, "ci_low > ci_high")
  }
  if (length(prob) == 0) return(data.frame(clave = character(0), problema = character(0)))
  do.call(rbind, prob)
}

# Prepara el registro para escribirlo (used_in siempre arreglo).
.preparar_para_json <- function(registro) {
  for (k in names(registro)) {
    if (!is.null(registro[[k]]$used_in)) {
      registro[[k]]["used_in"] <- list(I(as.character(unlist(registro[[k]]$used_in))))
    }
  }
  registro
}

#' Escribe el registro como JSON legible (UTF-8, escritura atómica).
#'
#' Usa jsonlite con `auto_unbox = TRUE`, `pretty = TRUE`, `digits = NA`
#' (precisión máxima), `na = "null"`, `null = "null"`.
#'
#' @param registro lista de entradas.
#' @param ruta archivo de salida (p. ej. figures/numbers.json).
#' @param ordenar si TRUE, ordena las claves alfabéticamente (diffs estables).
#' @param fusionar si TRUE, lee el archivo existente BAJO UN CANDADO, le
#'   superpone las claves de `registro` y escribe el resultado. Así varios
#'   agentes pueden escribir en el mismo archivo sin pisarse las claves.
#' @return (invisible) la ruta.
guardar_numbers <- function(registro, ruta, ordenar = FALSE, fusionar = FALSE) {
  if (!is.list(registro)) stop("`registro` debe ser una lista.", call. = FALSE)
  if (length(registro) > 0 && (is.null(names(registro)) || any(names(registro) == ""))) {
    stop("Todas las entradas del registro deben tener clave.", call. = FALSE)
  }
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  candado <- paste0(ruta, ".lock")
  if (fusionar) {
    t0 <- Sys.time()
    # dir.create() es atómico: solo un proceso logra crear el candado.
    while (!suppressWarnings(dir.create(candado, showWarnings = FALSE))) {
      if (as.numeric(difftime(Sys.time(), t0, units = "secs")) > 120) {
        stop(sprintf("No se pudo tomar el candado %s en 120 s (¿quedó huérfano? bórralo a mano).", candado),
             call. = FALSE)
      }
      Sys.sleep(0.2)
    }
    on.exit(unlink(candado, recursive = TRUE), add = TRUE)
    if (file.exists(ruta)) {
      existente <- leer_numbers(ruta)
      for (k in names(registro)) existente[[k]] <- registro[[k]]
      registro <- existente
    }
  }
  if (length(registro) == 0) registro <- nuevo_registro()
  if (ordenar && length(registro) > 0) registro <- registro[order(names(registro))]
  txt <- jsonlite::toJSON(.preparar_para_json(registro), auto_unbox = TRUE, pretty = TRUE,
                          digits = NA, na = "null", null = "null")
  tmp <- paste0(ruta, ".tmp", Sys.getpid())
  # escritura en bytes UTF-8 (no depende del locale) y luego rename atómico
  writeLines(enc2utf8(as.character(txt)), con = tmp, useBytes = TRUE)
  ok <- file.rename(tmp, ruta)
  if (!ok) stop(sprintf("No se pudo escribir %s.", ruta), call. = FALSE)
  invisible(ruta)
}

# Convierte lo leído del JSON a estructuras R cómodas sin perder la forma:
#   * arreglo de escalares -> vector atómico con clase AsIs (sigue saliendo
#     como arreglo al reescribir, aunque tenga un elemento);
#   * null escalar -> NA (salvo verified_by / verified_on, que quedan NULL);
#   * objetos y arreglos de objetos -> listas (se reescriben igual).
.desde_json <- function(x) {
  if (is.list(x) && is.null(names(x))) {
    es_escalar <- vapply(x, function(v) is.null(v) || (is.atomic(v) && length(v) == 1), logical(1))
    if (length(x) == 0) return(I(character(0)))
    if (all(es_escalar)) {
      v <- lapply(x, function(z) if (is.null(z)) NA else z)
      return(I(unlist(v)))
    }
    return(lapply(x, .desde_json))
  }
  if (is.list(x)) {
    nm <- names(x)
    out <- lapply(x, .desde_json)
    names(out) <- nm
    return(out)
  }
  x
}

#' Lee un numbers.json y devuelve el registro (lista de entradas).
#' Las entradas conservan todos los campos; los `null` escalares pasan a NA
#' (salvo `verified_by` / `verified_on`, que quedan NULL), y `used_in` queda
#' como vector de texto. Leer y volver a guardar produce el mismo archivo.
leer_numbers <- function(ruta) {
  if (!file.exists(ruta)) stop(sprintf("No existe %s.", ruta), call. = FALSE)
  crudo <- jsonlite::fromJSON(ruta, simplifyVector = FALSE)
  if (length(crudo) == 0) return(nuevo_registro())
  reg <- lapply(names(crudo), function(k) {
    e <- crudo[[k]]
    campos <- names(e)
    out <- setNames(vector("list", length(campos)), campos)
    for (cp in campos) {
      v <- e[[cp]]
      if (is.null(v)) {
        out[cp] <- if (cp %in% CAMPOS_NULL_PERMITIDO) list(NULL) else list(NA)
      } else if (cp == "used_in") {
        out[cp] <- list(I(as.character(unlist(v))))
      } else {
        out[cp] <- list(.desde_json(v))
      }
    }
    out
  })
  names(reg) <- names(crudo)
  reg
}

#' Combina varios numbers parciales (uno por agente) en un solo archivo.
#'
#' Falla si una misma clave aparece en dos archivos con contenido distinto
#' (dos agentes calcularon la misma cifra de forma diferente: hay que decidir).
#' @param rutas vector de archivos JSON parciales.
#' @param ruta_salida archivo combinado (p. ej. figures/numbers.json).
#' @return (invisible) el registro combinado.
combinar_numbers <- function(rutas, ruta_salida, ordenar = TRUE) {
  total <- nuevo_registro()
  origen <- character(0)
  for (r in rutas) {
    parcial <- leer_numbers(r)
    for (k in names(parcial)) {
      if (!is.null(total[[k]])) {
        a <- total[[k]]; b <- parcial[[k]]
        if (!isTRUE(all.equal(lapply(a, unclass), lapply(b, unclass), check.attributes = FALSE))) {
          stop(sprintf("La clave '%s' está en %s y en %s con valores distintos.", k, origen[[k]], r),
               call. = FALSE)
        }
      }
      total[[k]] <- parcial[[k]]
      origen[[k]] <- r
    }
  }
  if (ordenar && length(total) > 0) total <- total[order(names(total))]
  guardar_numbers(total, ruta_salida, ordenar = FALSE)
  invisible(total)
}

#' Claves obligatorias v2 (transcritas de docs/00_plan_implementacion.md §4).
#' "(+ _1m)" de los tipos y "(+ _cv)" de los R² se expanden a todas las claves
#' de esa lista. Útil para saber qué falta: `claves_faltantes(reg)`.
CLAVES_OBLIGATORIAS_V2 <- list(
  universo = c("world_pop_2023_bn", "n_countries", "n_countries_1m", "n_sovereign", "n_territories",
               "n_below_replacement_2023", "n_below_repl_growing_2023",
               "n_below_repl_natural_growth_2023", "n_grow_only_migration_2023",
               "n_grow_only_migration_2023_1m", "cover_flags"),
  slide1 = c("n_type_AB", "n_type_A", "n_type_B", "n_type_C", "n_type_D", "n_type_E",
             "n_type_AB_1m", "n_type_A_1m", "n_type_B_1m", "n_type_C_1m", "n_type_D_1m", "n_type_E_1m",
             "examples_type_C", "examples_type_D", "examples_type_E",
             "n_momentum_countries", "n_momentum_emig", "pop_momentum_bn", "examples_momentum",
             "share_mig_high_2000_2023", "share_mig_high_2010_2023", "share_mig_low_2000_2023",
             "share_mig_lowmid_2000_2023", "share_mig_upmid_2000_2023", "share_mig_high_un_agg",
             "china_share_natchange_upmid", "india_share_natchange_lowmid", "cnmr_are_2023",
             "growth_are_2023", "tfr_are_2023", "are_revision_pct", "pop_are_2050",
             "pop_are_2050_pi95_low", "pop_are_2050_pi95_high", "n_dir_uncertain_2050",
             "n_cnmr_sign_uncertain_2050"),
  slide2 = c("n_cruce_tfr4_obs", "n_cens_izq", "n_cens_der", "pct_var_fase", "dur53_chn", "dur53_egy",
             "n_onset", "n_mort_first_onset", "share_mort_first", "lag_onset_lower_bound",
             "q5_drop_at_tfr_onset", "n_q5_falling_1950", "yr_fert_onset_low", "yr_fert_onset_lowmid",
             "yr_fert_onset_upmid", "yr_fert_onset_high", "logrank_income_chisq", "panel_within_halfq5",
             "panel_between_halfq5", "panel_ratio_between_within", "panel_low_income_halfq5",
             "panel_ssa_halfq5", "panel_eurna_halfq5", "panel_placebo_lo", "panel_placebo_hi",
             "panel_lead", "panel_reverse_sd", "panel_forward_sd", "r_tfr_decades_min",
             "r_cnmr_decades_recent", "r_cnmr_decades_min", "r_cnmr_decades_max", "r_cnmr_1950_2023",
             "moran_tfr_2023", "moran_lex_2023", "moran_medage_2023", "moran_cnmr_2023",
             "moran_cnmr_2023_nogulf", "mig_hi_within_slope"),
  slide3 = c("r2_tfr_medage", "r2_tfr_chg2050", "r2_tfr_growth", "r2_tfr_cnmr",
             "r2_tfr_medage_cv", "r2_tfr_chg2050_cv", "r2_tfr_growth_cv", "r2_tfr_cnmr_cv",
             "r2_all", "cdr_prt", "cdr_tcd", "lex_gap_prt_tcd", "rho_cdr_lex_1950", "rho_cdr_lex_2023",
             "rho_cdr_medage_2023", "twins", "twin_tfr_are", "twin_tfr_blr", "twin_growth_are",
             "twin_growth_blr", "knn_tfr", "knn_pc1", "knn_pc12", "knn_chance", "recov_tfr", "recov_pc1",
             "lookalikes_col_tfr", "lookalikes_col_12", "n_dims_parallel", "r_tfr_pc1", "r_tfr_pc2",
             "pc1_var", "pc2_var", "pc2_var_no_gulf", "n_pcs_70", "share_rank_mc20", "rank_range_ukr",
             "alpha"),
  slide4 = c("k_clusters", "silhouette", "cluster_names", "cluster_sizes", "cluster_pop_bn",
             "cluster_examples_early", "cluster_examples_fast", "cluster_examples_recent",
             "cluster_examples_migration", "cluster_medoids", "jaccard_min", "jaccard_max",
             "ari_fpca_decadas", "ari_tray_niveles", "ari_sin_cnmr", "share_between_groups",
             "share_keep_ge_0.8", "borderline_countries", "join_same_road", "join_same_road_null",
             "sd_lex_1950", "sd_lex_2023", "sd_medage_1950", "sd_medage_2023", "sd_le65_1950",
             "sd_le65_2023", "cv_lex_1950", "cv_lex_2023", "cv_le65_1950", "cv_le65_2023",
             "q5_ratio_p90p10_1950", "q5_ratio_p90p10_2023", "yrs_medage30_40_recent",
             "yrs_medage30_40_early", "n_sdg32_above", "n_sdg32_on_pace", "n_sdg32_above_2030",
             "n_natneg_1990", "n_natneg_2023", "n_natneg_2050", "share_pop_natneg_2023", "pop_chn_2050",
             "pop_chn_2050_pi95_low", "pop_chn_2050_pi95_high", "rec_rows", "n_ssa"),
  etica = c("n_census_pre2009", "n_census_2019plus", "n_shock_years_est", "n_shock_years_proj",
            "n_lex_drop_proj", "share_monotone_proj_lex", "n_tests", "hyp_file_date", "hyp_file_sha256",
            "hyp_file_sha256_short", "hyp_file_commit", "world_peak_year", "world_peak_bn")
)

# Claves retiradas: no deben aparecer en el guion (plan §4).
CLAVES_RETIRADAS_V2 <- c("lag_median", "beta_cnmr", "share_rank_shift_20", "yrs_eu", "yrs_asia",
                         "yrs_lac", "rho_tfr_cnmr_high")

#' Devuelve las claves obligatorias que aún no están en el registro.
#' @param secciones subconjunto de names(CLAVES_OBLIGATORIAS_V2).
claves_faltantes <- function(registro, secciones = names(CLAVES_OBLIGATORIAS_V2)) {
  req <- unlist(CLAVES_OBLIGATORIAS_V2[secciones], use.names = FALSE)
  setdiff(req, names(registro))
}

invisible(TRUE)
