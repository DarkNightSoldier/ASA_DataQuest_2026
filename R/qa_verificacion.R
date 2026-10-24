#!/usr/bin/env Rscript
# =============================================================================
# qa_verificacion.R — Marcas de verificación independiente en numbers.json
# (agente QA-stats, ASA DataQuest 2026, UN WPP 2024)
#
# Qué trae:
#   1. huella_cifra()            — huella corta (SHA-256, 16 caracteres) de la
#                                  parte NUMÉRICA de una clave: value, IC,
#                                  sensibilidad, IP de la ONU y método.
#   2. es_clave_pantalla()       — TRUE si la clave sale en la portada, en una
#                                  diapositiva, en la voz, en las referencias o
#                                  en una figura del vídeo (misma regla que
#                                  R/05_numbers_json.R §6.6).
#   3. aplicar_verificacion_qa() — lee docs/qa/verificacion_consolidada.csv y
#                                  rellena verified, verified_by, verified_on y
#                                  nota_qa de cada clave del registro.
#
# Decisiones (ASA 2022, B.4 reproducibilidad, C.2 no exagerar la certeza):
#   * La verificación es de la CIFRA, no del texto: una clave queda con
#     verified = true solo si su huella actual es IGUAL a la huella que tenía
#     cuando el verificador independiente la recalculó. Si la cifra cambia en
#     una corrida posterior, vuelve a verified = false y nota_qa dice por qué
#     (nunca se arrastra un ✔ viejo a un número nuevo).
#   * Las aclaraciones de `def`, `filter`, `n` o `say` no cambian la huella:
#     documentan el método sin cambiar el número verificado.
#   * Las claves que el verificador no recalculó quedan verified = false con el
#     motivo en nota_qa ("solo notebook" o, si salen en pantalla o en la voz,
#     "falta verificar antes de grabar").
#   * La huella pasa antes por una ida y vuelta JSON (jsonlite, digits = NA):
#     así da lo mismo si la entrada viene de leer_numbers() o está en memoria.
#
# Depende de: jsonlite, digest y de R/incertidumbre.R (CAMPOS_NUMBERS y
# marcar_verificada()). No lee datos.
#
# Convención: código y comentarios en español; textos de numbers.json en inglés.
# =============================================================================

suppressPackageStartupMessages({
  library(jsonlite)
})

# Campos que definen "la cifra" (lo que el verificador recalcula).
QA_CAMPOS_HUELLA <- c("value", "ci_low", "ci_high", "sens_low", "sens_high",
                      "pi80_low", "pi80_high", "pi95_low", "pi95_high", "method")

#' Huella corta de la parte numérica de una entrada de numbers.json.
#' @param e entrada (lista con los campos del esquema).
#' @return texto de 16 caracteres hexadecimales.
huella_cifra <- function(e) {
  sub <- lapply(QA_CAMPOS_HUELLA, function(k) if (is.null(e[[k]])) NA else e[[k]])
  names(sub) <- QA_CAMPOS_HUELLA
  a_json <- function(x) jsonlite::toJSON(x, auto_unbox = TRUE, digits = NA, na = "null", null = "null")
  # ida y vuelta: misma representación para entradas leídas del JSON o en memoria
  txt <- as.character(a_json(jsonlite::fromJSON(as.character(a_json(sub)), simplifyVector = FALSE)))
  substr(digest::digest(txt, algo = "sha256", serialize = FALSE), 1, 16)
}

#' ¿La clave sale en pantalla, en la voz, en las referencias o en el vídeo?
es_clave_pantalla <- function(e) {
  u <- as.character(unlist(e$used_in))
  length(u) > 0 && any(grepl("^(cover|slide|narration|references|fig[0-9])", u))
}

# Textos fijos de nota_qa (inglés, como el resto de numbers.json).
QA_NOTA_SOLO_NOTEBOOK <- paste("Not independently re-computed: notebook-only key",
                               "(not used on screen, in the narration or in the references)")
QA_NOTA_PANTALLA_SIN <- paste("NOT VERIFIED: used on screen, in the narration or in the references",
                              "but not independently re-computed yet; verify before recording")

#' Aplica la verificación independiente consolidada a un registro.
#'
#' @param registro lista de entradas (esquema v2 con `nota_qa`).
#' @param ruta_csv docs/qa/verificacion_consolidada.csv (una fila por clave
#'   recalculada: clave, lote, verificada, huella, fecha_verificacion, nota_qa).
#' @return lista con `registro` (actualizado) y `resumen` (data.frame: clave,
#'   estado, lote, pantalla).
aplicar_verificacion_qa <- function(registro, ruta_csv) {
  if (!file.exists(ruta_csv)) {
    warning("No existe ", ruta_csv, ": ninguna clave queda verificada.", call. = FALSE)
    qa <- data.frame(clave = character(0), lote = integer(0), verificada = logical(0), huella = character(0),
                     fecha_verificacion = character(0), nota_qa = character(0), stringsAsFactors = FALSE)
  } else {
    qa <- utils::read.csv(ruta_csv, stringsAsFactors = FALSE, encoding = "UTF-8", na.strings = "",
                          colClasses = c(clave = "character", huella = "character", nota_qa = "character",
                                         fecha_verificacion = "character"))
  }
  if (anyDuplicated(qa$clave)) stop("Claves repetidas en ", ruta_csv, call. = FALSE)
  vacio <- function(x) is.null(x) || length(x) == 0 || all(is.na(x)) || !nzchar(x)
  filas <- vector("list", length(registro))
  for (j in seq_along(registro)) {
    k <- names(registro)[j]
    e <- registro[[k]]
    # punto de partida: sin verificar (lo que escribe registrar_cifra)
    e["verified"] <- list(FALSE); e["verified_by"] <- list(NULL); e["verified_on"] <- list(NULL)
    e["nota_qa"] <- list(NA_character_)
    pant <- es_clave_pantalla(e)
    i <- match(k, qa$clave)
    lote <- NA_integer_
    if (!is.na(i)) {
      lote <- as.integer(qa$lote[i])
      nota <- if (vacio(qa$nota_qa[i])) NA_character_ else qa$nota_qa[i]
      if (isTRUE(as.logical(qa$verificada[i])) && identical(huella_cifra(e), qa$huella[i])) {
        registro[[k]] <- e
        registro <- marcar_verificada(registro, k, por = sprintf("verificación independiente lote %d", lote),
                                      fecha = qa$fecha_verificacion[i])
        e <- registro[[k]]
        e["nota_qa"] <- list(nota)
        estado <- "verificada"
      } else if (isTRUE(as.logical(qa$verificada[i]))) {
        e["nota_qa"] <- list(sprintf(paste("NOT VERIFIED: the figure changed after the independent check",
                                           "(batch %d, %s); re-verify before use"), lote, qa$fecha_verificacion[i]))
        estado <- "cambió tras verificar"
      } else {
        e["nota_qa"] <- list(if (is.na(nota)) "NOT VERIFIED (see docs/QA_stats.md)" else nota)
        estado <- "no verificada"
      }
    } else {
      e["nota_qa"] <- list(if (pant) QA_NOTA_PANTALLA_SIN else QA_NOTA_SOLO_NOTEBOOK)
      estado <- if (pant) "pantalla sin verificar" else "solo notebook"
    }
    # orden exacto del esquema (los campos que falten se completan con NA)
    for (cp in setdiff(CAMPOS_NUMBERS, names(e))) e[cp] <- list(NA)
    registro[[k]] <- e[CAMPOS_NUMBERS]
    filas[[j]] <- data.frame(clave = k, estado = estado, lote = lote, pantalla = pant, stringsAsFactors = FALSE)
  }
  resumen <- do.call(rbind, filas)
  huerfanas <- setdiff(qa$clave, names(registro))
  if (length(huerfanas) > 0) {
    warning("Claves verificadas que ya no existen en el registro: ", paste(huerfanas, collapse = ", "), call. = FALSE)
  }
  list(registro = registro, resumen = resumen, huerfanas = huerfanas)
}
