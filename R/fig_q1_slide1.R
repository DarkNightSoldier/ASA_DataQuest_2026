#!/usr/bin/env Rscript
# =============================================================================
# fig_q1_slide1.R
# Figuras FINALES de la portada y de la Slide 1 — Question 1 · P7 · P4
# (storyboard v2.1 §1 "Cover" y §2 "Slide 1"; contrato de slides/README.md §3)
#
# Ejecutar desde la raíz del repo:
#   Rscript R/fig_q1_slide1.R                  # todo: PNG, _print.png, capas y MP4
#   Rscript R/fig_q1_slide1.R fig01 fig03      # solo esas figuras (fig00 | fig01 | fig02 | fig02b | fig03)
#   FIG_SIN_MP4=1 Rscript R/fig_q1_slide1.R    # solo PNG (prueba rápida, sin animaciones)
#
# Qué produce (nombres exactos que esperan slides/index.html y slides/js/figs.js):
#   fig00_world_dots (portada, fondo 1920×1080; "un punto por país")
#     figures/static/fig00_world_dots.png                      b1: 237 puntos tenues sobre el mundo de puntos
#     figures/static/fig00_world_dots_below_replacement.png    b2: capa transparente, se tiñen los 130 bajo reemplazo
#     figures/static/fig00_world_dots_growing.png              b3: capa transparente, 66 azules + 18 celestes
#     figures/static/fig00_world_dots_print.png                PDF: estado final (las tres capas juntas)
#   fig01_growth_components_by_income (S1 b2; ranura 721×390, PDF 721×225)
#     figures/animated/fig01_growth_components_by_income.mp4   H.264 yuv420p 30 fps
#     figures/static/fig01_growth_components_by_income.png     póster = último fotograma
#     figures/static/fig01_growth_components_by_income_print.png
#   fig02_lever_map_2023 (S1 b3–b4; ranura 1037×365, PDF 1037×290)
#     figures/static/fig02_lever_map_2023.png  (+ _print.png)
#     figures/static/fig02_lever_map_2023_momentum.png  (+ _print.png)  capa transparente de S1 b3b:
#                                                contorno de los países de inercia + IND, BRA, MEX
#     figures/static/fig02_lever_map_2023_ex_c.png | _ex_d.png | _ex_e.png   capas transparentes
#                                                OPCIONALES de S1 b4a–b4c (ejemplos por regla con ISO3);
#                                                index.html todavía no las enlaza (ver PROBLEMAS al final)
#   fig02b_lever_map_zoom (S1 b5a; ranura 1037×365; el Golfo queda en los 140 px superiores porque
#                          la tarjeta de EAU de 226 px tapa la parte de abajo)
#     figures/animated/fig02b_lever_map_zoom.mp4  y  figures/static/fig02b_lever_map_zoom.png (póster)
#   fig03_uae_fan_2050 (S1 b5b, inset de la tarjeta EAU; ranura 441×204, PDF 560×150)
#     figures/static/fig03_uae_fan_2050.png  (+ _print.png)
#
# Contrato con las diapositivas (slides/README.md §3):
#   * Sin título ni subtítulo dentro de la imagen (el titular, las leyendas con conteos y las
#     cifras de texto van en HTML desde numbers.json); sí ejes, unidades, etiquetas directas,
#     anotaciones y un pie corto (badge PIE-x abreviado); fondo blanco (capas: transparente).
#   * Tamaño = ranura medida × 2 (dev/figure_slots.json). Con res = 144 y la imagen al doble de
#     la ranura, 1 pt = 1 px de la diapositiva 1920×1080: todos los tamaños de letra de este
#     script (TAM$...) están en px de diapositiva y ninguno baja de 18 px.
#   * Lienzo en píxeles: cada figura se dibuja en coordenadas 0..ancho × 0..alto (px de la
#     ranura) con ggplot2 + coord_cartesian(expand = FALSE). Los mapas se proyectan a Robinson
#     (sf) y se llevan a px con una transformación afín; así el zoom animado es solo cambiar el
#     centro y la escala de esa transformación (interpolados con tweenr) y las etiquetas se
#     colocan a mano sin solapes. El último fotograma de cada MP4 es idéntico al póster PNG.
#
# Animación (fotogramas ragg + tweenr → ffmpeg del venv, H.264 yuv420p 30 fps; respaldo av):
#   La animación SEÑALA lo que dice la voz en cada build. Los instantes salen de los bloques de
#   subtítulo del paso en slides/script/video_timings.json si ya existe; si no, de la estimación
#   por palabras del guion v2.1 (150 ppm + 1,5 s de aire tras cada cifra hablada) ajustada a la
#   duración del paso en slides/dev/video_timings.template.json. Volver a correr este script
#   tras grabar la voz re-sincroniza.
#
# Datos (NO se recalcula ningún estadístico; solo se leen resultados de R/02_q1_palancas.R):
#   figures/numbers_q1.json                           cifras finales (valor, IC, fmt)
#   data/processed/resultados_q1.parquet              tipo de palanca 2023, bajo reemplazo, inercia,
#                                                     ejemplos por regla, ISO2, región, ≥ 1 M
#   data/processed/resultados_q1_descomposicion.parquet  saldo natural y migración neta por grupo de
#                                                     ingreso FY2027 y década (sumas de países) + China/India
#   data/processed/resultados_q1_fan_are.parquet      EAU 1950–2100: estimación, UN medium, PI 80/95 %,
#                                                     escenario ONU de migración cero
#   Natural Earth (rnaturalearth, escala medium, map_units)  polígonos y puntos de etiqueta
#   Cada cifra visible se comprueba contra numbers_q1.json antes de dibujar (si no coinciden, se para).
#
# Convención: código y comentarios en español; todo texto visible en inglés llano.
# =============================================================================

t_inicio <- Sys.time()

suppressPackageStartupMessages({
  library(here)
})
source(here::here("R", "config.R"))
source(here::here("R", "utilidades.R"))
source(here::here("R", "comun_analisis.R"))   # paletas v2, badge(), formatear_cifra(), GOLFO

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(arrow)
  library(jsonlite)
  library(ragg)
  library(tweenr)
  library(systemfonts)
  library(sf)
})
for (.p in c("rnaturalearth", "rnaturalearthdata", "png")) {
  if (!requireNamespace(.p, quietly = TRUE)) stop("Falta el paquete ", .p, call. = FALSE)
}

# =============================================================================
# 0. Constantes de salida, tamaños y colores
# =============================================================================

ESCALA <- 2                       # imagen = 2 × ranura (README §3: "exportar a 2×")
RES <- 72 * ESCALA                # 144 ppp → 1 pt = 1 px de diapositiva
FPS <- 30
NUCLEOS <- max(1L, min(8L, parallel::detectCores() - 4L))
SIN_MP4 <- nzchar(Sys.getenv("FIG_SIN_MP4"))
FUENTE <- "Lato"

# Ranuras medidas en px de diapositiva (slides/README.md §3 y slides/dev/figure_slots.json)
RANURAS <- list(
  fig00 = c(w = 1920, h = 1080),
  fig01 = c(w = 721, h = 390),  fig01_print = c(w = 721, h = 225),
  fig02 = c(w = 1037, h = 365), fig02_print = c(w = 1037, h = 290),
  fig03 = c(w = 441, h = 204),  fig03_print = c(w = 560, h = 150)
)
NOMBRES <- c(fig00 = "fig00_world_dots",
             fig01 = "fig01_growth_components_by_income",
             fig02 = "fig02_lever_map_2023",
             fig02b = "fig02b_lever_map_zoom",
             fig03 = "fig03_uae_fan_2050")
# Alto de la tarjeta de EAU que tapa la parte baja del mapa en S1 b5b (theme.css .uae-card)
ALTO_TARJETA_EAU <- 226

# Tamaños de letra en px de diapositiva (mínimo 18 px a la ranura final, README §3)
TAM <- list(principal = 24, grupo = 22, eje = 19, secundario = 18, pie = 18, iso = 19,
            contador = 30)

# Colores con significado único en todo el vídeo (storyboard §8; comun_analisis.R §1.5)
COL_TEXTO   <- "#15233B"          # tinta de las diapositivas (--ink)
COL_TEXTO_2 <- "#5B6068"          # texto secundario (--muted; 6,3:1 sobre blanco)
COL_NAC     <- COLOR_NACIMIENTOS  # "#0072B2" saldo natural / crece por nacimientos (A+B)
COL_MIG     <- COLOR_MIGRACION    # "#56B4E9" migración neta / crece solo por llegadas (C)
COL_DEF     <- COLOR_DEFUNCIONES  # "#E69F00" decrece: muertes > nacimientos (D) / escenario
COL_EMI     <- COLOR_EMIGRACION   # "#CC79A7" decrece: salen más de los que llegan (E)
COL_PEQ     <- COLOR_SIN_DATOS    # "#999999" pequeños Estados (< 1 M) en el mapa
COL_SIN     <- "#DADADA"          # áreas sin dato WPP (deshabitadas: ATF, SGS, IOT, ...)
COL_OCEANO  <- "#F4F7FA"
COL_MARCO   <- "#C9CED6"
COL_REJILLA <- "#E6E6E6"
COL_EJE     <- "#9A9A9A"
COL_PROY    <- COLOR_PROYECCION   # "#B0B0B0" proyección ONU
COL_BANDA95 <- "#E9E9E9"
COL_BANDA80 <- "#CDCDCD"
COL_MEDIANA <- "#7A7A7A"          # línea de la proyección media (gris, más oscura que las bandas)
COL_ESCENARIO <- "#4D4D4D"        # escenario ONU de migración cero (gris oscuro punteado; QA-viz V7)
COL_RESALTE <- COL_TEXTO          # contorno de resaltes (inercia, ejemplos, EAU)
PALETA_TIPO <- c(AB = COL_NAC, A = COL_NAC, B = COL_NAC, C = COL_MIG, D = COL_DEF, E = COL_EMI)
# Atenuado = gris NEUTRO sin tono (corrección del revisor, ronda 1): un azul "atenuado" hacia
# un gris azulado quedaba en #61a1c7 / #86B4D0, casi el celeste #56B4E9 de "crece solo por
# llegadas", y el Golfo o las barras de nacimientos se leían como migración.
#   COL_ATENUADO     croma LCh 0,0 · ΔE76 = 40,9 con #56B4E9 y 58,9 con #0072B2 (ΔE00 24,1 / 39,9)
#   COL_ATENUADO_NAC croma LCh 0,0 · más oscuro que COL_ATENUADO para que, en fig01, la barra de
#                    nacimientos atenuada siga distinguiéndose de la de migración atenuada
COL_ATENUADO     <- "#DCDCDC"
COL_ATENUADO_NAC <- "#BDBDBD"

RUTA_FFMPEG_VENV <- file.path(
  "/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604",
  "scratchpad/venv-jupyter/lib/python3.14/site-packages/imageio_ffmpeg/binaries/ffmpeg-linux-x86_64-v7.0.2"
)
RUTA_TIMINGS <- file.path(RUTA_RAIZ, "slides", "script", "video_timings.json")
RUTA_TIMINGS_PLANTILLA <- file.path(RUTA_RAIZ, "slides", "dev", "video_timings.template.json")

PROBLEMAS <- character(0)
anotar_problema <- function(txt) {
  if (!txt %in% PROBLEMAS) { PROBLEMAS <<- c(PROBLEMAS, txt); message("  PROBLEMA: ", txt) }
}

# =============================================================================
# 1. Lectura de cifras y tablas (solo resultados ya calculados) + comprobaciones
# =============================================================================

NUM <- jsonlite::read_json(file.path(RUTA_FIGURAS, "numbers_q1.json"), simplifyVector = TRUE)

#' Devuelve un campo de una clave de numbers_q1.json (para avisar si falta).
cifra <- function(clave, campo = "value") {
  if (is.null(NUM[[clave]])) stop("numbers_q1.json no trae la clave '", clave, "'.", call. = FALSE)
  NUM[[clave]][[campo]]
}

#' Formatea con el mismo `fmt` de numbers.json y el signo menos tipográfico de
#' slides/js/numbers.js (U+2212), para que la figura muestre lo mismo que el HTML.
fmt_cifra <- function(valor, fmt) sub("^-", "−", formatear_cifra(valor, fmt))
fmt_clave <- function(clave, fmt = NULL) fmt_cifra(cifra(clave), if (is.null(fmt)) cifra(clave, "fmt") else fmt)

comprobar <- function(cond, msg) if (!isTRUE(cond)) stop("Comprobación contra numbers_q1.json: ", msg, call. = FALSE)

# --- 1.1 Tipología de palancas 2023 (237 países y áreas) ---------------------
leer_tipos <- function() {
  r <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q1.parquet")) |>
    select("ISO3_code", "ISO2_code", "Location", "region_sdg", "pob_1m", "pop_2023_miles",
           tipo = "tipo_palanca_2023", tipo_ab = "tipo_ab_2023", bajo = "bajo_reemplazo_2023",
           inercia = "inercia_bajo_reemplazo", ejemplo = "ejemplo_por_regla") |>
    # Namibia tiene ISO2 "NA", que arrow lee como valor perdido
    mutate(ISO2_code = ifelse(.data$ISO3_code == "NAM" & is.na(.data$ISO2_code), "NA", .data$ISO2_code))
  comprobar(nrow(r) == cifra("n_countries"), "número de países y áreas")
  comprobar(sum(r$tipo_ab == "AB") == cifra("n_type_AB"), "n_type_AB")
  comprobar(sum(r$tipo == "C") == cifra("n_type_C"), "n_type_C")
  comprobar(sum(r$tipo == "D") == cifra("n_type_D"), "n_type_D")
  comprobar(sum(r$tipo == "E") == cifra("n_type_E"), "n_type_E")
  comprobar(sum(r$pob_1m) == cifra("n_ge1m"), "n_ge1m")
  comprobar(sum(r$bajo) == cifra("n_below_replacement_2023"), "n_below_replacement_2023")
  comprobar(sum(r$bajo & r$tipo %in% c("A", "B", "C")) == cifra("n_below_repl_growing_2023"),
            "n_below_repl_growing_2023")
  comprobar(sum(r$bajo & r$tipo %in% c("A", "B")) == cifra("n_below_repl_natural_growth_2023"),
            "n_below_repl_natural_growth_2023")
  comprobar(sum(r$bajo & r$tipo == "C") == cifra("n_grow_only_migration_2023"), "n_grow_only_migration_2023")
  comprobar(sum(r$inercia) == cifra("n_momentum_countries"), "n_momentum_countries")
  comprobar(abs(sum(r$pop_2023_miles[r$inercia]) / 1e6 - cifra("pop_momentum_bn")) < 5e-4, "pop_momentum_bn")
  for (k in c("C", "D", "E")) {
    iso_json <- cifra(paste0("examples_type_", k, "_iso3"))
    iso_pq <- r$ISO3_code[r$ejemplo %in% k]
    comprobar(setequal(iso_json, iso_pq) && all(r$tipo[match(iso_json, r$ISO3_code)] == k),
              paste0("examples_type_", k))
  }
  iso_mom <- r$ISO3_code[match(cifra("examples_momentum"), r$Location)]
  comprobar(!anyNA(iso_mom) && setequal(iso_mom, r$ISO3_code[r$ejemplo %in% "momentum"]) &&
              all(r$inercia[match(iso_mom, r$ISO3_code)]), "examples_momentum")
  cover <- toupper(cifra("cover_flags"))
  comprobar(setequal(cover, r$ISO2_code[match(cifra("examples_type_C_iso3"), r$ISO3_code)]), "cover_flags")
  r |> mutate(iso_mom = .data$ISO3_code %in% iso_mom)
}

# --- 1.2 Descomposición del crecimiento por grupo de ingreso (fig01) ----------
DECADAS <- c("1950-1959", "1960-1969", "1970-1979", "1980-1989", "1990-1999", "2000-2009", "2010-2023")
ETQ_DECADA <- c("1950s", "1960s", "1970s", "1980s", "1990s", "2000s", "2010–23")
ANIOS_DECADA <- c(10, 10, 10, 10, 10, 10, 14)
leer_descomposicion <- function() {
  d <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q1_descomposicion.parquet"))
  alta <- d |> filter(.data$agrupacion == "income", .data$grupo == "High income", .data$periodo == "2000-2023")
  comprobar(nrow(alta) == 1 && abs(alta$share_mig_pct - cifra("share_mig_high_2000_2023")) < 1e-3,
            "share_mig_high_2000_2023 (descomposición)")
  comprobar(abs(alta$mig_miles / alta$pop_change_miles * 100 - cifra("share_mig_high_2000_2023")) < 1e-3,
            "share_mig_high_2000_2023 = migración / cambio total")
  # Prueba de cierre del plan (storyboard §2 notas): suma de grupos + Not classified = las 237
  tot <- d |> filter(.data$agrupacion == "income", .data$periodo %in% DECADAS) |>
    summarise(n = sum(.data$n_paises) / length(DECADAS))
  comprobar(tot$n == cifra("n_countries"), "los grupos de ingreso suman las 237 áreas")
  ing <- d |> filter(.data$agrupacion == "income", .data$grupo %in% NIVELES_INGRESO,
                     .data$periodo %in% DECADAS)
  # (mutate evalúa en orden: `pais` sale del texto original antes de limpiar `grupo`)
  dentro <- d |> filter(.data$agrupacion == "of which", .data$periodo %in% DECADAS) |>
    mutate(pais = sub("^of which (China|India):.*$", "\\1", .data$grupo),
           grupo = sub("^of which (China|India): ", "", .data$grupo)) |>
    select("grupo", "periodo", "pais", nat_pais_miles = "nat_miles")
  comprobar(nrow(dentro) == 2 * length(DECADAS), "filas 'of which' China/India")
  ing |>
    left_join(dentro, by = c("grupo", "periodo")) |>
    mutate(
      grupo = factor(.data$grupo, levels = NIVELES_INGRESO),
      k = match(.data$periodo, DECADAS),
      # Unidad común "por década": la última ventana (2010–2023) tiene 14 años y se lleva a
      # 10 (conversión de unidades, no un estadístico nuevo; el HTML dice "per decade")
      f = 10 / ANIOS_DECADA[.data$k],
      nat = .data$nat_miles / 1000 * .data$f,          # millones de personas por década
      mig = .data$mig_miles / 1000 * .data$f,
      nat_pais = .data$nat_pais_miles / 1000 * .data$f
    ) |>
    arrange(.data$grupo, .data$k)
}

# --- 1.3 Abanico de EAU (fig03) ------------------------------------------------
leer_fan <- function() {
  f <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q1_fan_are.parquet"))
  en <- function(s, anio) f$pop_millones[f$serie == s & f$Time == anio]
  comprobar(abs(en("UN medium projection", 2050) - cifra("pop_are_2050")) < 1e-3, "pop_are_2050")
  comprobar(abs(en("PI l95", 2050) - cifra("pop_are_2050_pi95_low")) < 1e-3, "pop_are_2050_pi95_low")
  comprobar(abs(en("PI u95", 2050) - cifra("pop_are_2050_pi95_high")) < 1e-3, "pop_are_2050_pi95_high")
  comprobar(abs(en("Zero migration scenario", 2050) - cifra("pop_are_2050_zero_mig")) < 1e-3,
            "pop_are_2050_zero_mig")
  comprobar(abs(en("UN medium projection", 2100) - cifra("pop_are_2100")) < 1e-3, "pop_are_2100")
  comprobar(max(f$Time[f$serie == "Estimate"]) == ANIO_FIN_ESTIMACION, "la estimación termina en 2023")
  f
}

TIPOS <- leer_tipos()
DESCOMP <- leer_descomposicion()
FAN <- leer_fan()

# =============================================================================
# 2. Ayudas de lienzo, texto, tiempo y exportación
# =============================================================================

#' Tema común de las figuras del vídeo: lienzo blanco (o transparente), Lato, sin márgenes.
if (!exists("tema_dq")) {
  tema_dq <- function(base_family = FUENTE, fondo = "white") {
    theme_void(base_family = base_family) +
      theme(plot.background = element_rect(fill = fondo, colour = NA),
            panel.background = element_rect(fill = fondo, colour = NA),
            plot.margin = margin(0, 0, 0, 0), legend.position = "none")
  }
}

#' Lienzo en px de la ranura (0..w × 0..h). `transparente` para las capas superpuestas.
lienzo <- function(w, h, transparente = FALSE) {
  fondo <- if (transparente) NA else "white"
  ggplot() +
    coord_cartesian(xlim = c(0, w), ylim = c(0, h), expand = FALSE, clip = "on") +
    tema_dq(fondo = fondo) +
    theme(plot.background = element_rect(fill = fondo, colour = NA),
          panel.background = element_rect(fill = fondo, colour = NA))
}

#' Ancho de un texto en px de diapositiva (Lato, tamaño en px).
ancho_txt <- function(txt, px, negrita = FALSE) {
  as.numeric(systemfonts::string_width(txt, family = FUENTE, size = px, res = 72,
                                       weight = if (negrita) "bold" else "normal"))
}

#' Avisa si un texto no cabe en el ancho disponible (px de ranura).
AVISOS_ANCHO <- character(0)
avisar_ancho <- function(txt, px, disponible, negrita = FALSE, donde = "") {
  w <- ancho_txt(txt, px, negrita)
  for (k in which(w > disponible)) {
    msg <- sprintf("AVISO %s: '%s' mide %.0f px y hay %.0f px", donde, txt[k], w[k], disponible)
    if (!msg %in% AVISOS_ANCHO) { AVISOS_ANCHO <<- c(AVISOS_ANCHO, msg); message("  ", msg) }
  }
  invisible(w)
}

#' Texto en px (tamaño en px de diapositiva → mm de ggplot).
texto <- function(x, y, label, px, colour = COL_TEXTO, hjust = 0, vjust = 0.5,
                  negrita = FALSE, cursiva = FALSE, alpha = 1, angle = 0) {
  if (alpha <= 0.001) return(NULL)
  cara <- if (negrita && cursiva) "bold.italic" else if (negrita) "bold" else if (cursiva) "italic" else "plain"
  annotate("text", x = x, y = y, label = label, size = px / .pt, colour = colour,
           hjust = hjust, vjust = vjust, family = FUENTE, fontface = cara, alpha = alpha,
           angle = angle, lineheight = 0.95)
}

#' Texto con halo blanco (para etiquetas que caen sobre el mapa o las bandas).
#' El alfa del texto va en el color: así se desvanece igual que el resto en la animación.
texto_halo <- function(x, y, label, px, colour = COL_TEXTO, hjust = 0, vjust = 0.5,
                       negrita = FALSE, alpha = 1, fondo = 0.85) {
  if (alpha <= 0.001) return(NULL)
  annotate("label", x = x, y = y, label = label, size = px / .pt,
           colour = scales::alpha(colour, alpha), hjust = hjust, vjust = vjust, family = FUENTE,
           fontface = if (negrita) "bold" else "plain",
           fill = scales::alpha("white", fondo * alpha), border.colour = NA, linewidth = 0,
           label.padding = unit(1.5, "pt"), label.r = unit(2, "pt"))
}

#' Progreso 0→1 de una transición que empieza en t0 y dura `d` segundos (tweenr).
prog <- function(t, t0, d = 0.5, ease = "cubic-in-out") {
  if (!is.finite(t)) return(1)
  p <- min(1, max(0, (t - t0) / d))
  if (p <= 0) return(0)
  if (p >= 1) return(1)
  tweenr::tween_at(0, 1, p, ease)
}

#' Inicios de los bloques de subtítulo de un paso: de slides/script/video_timings.json (si el
#' agente de guion ya lo escribió con `captions[].t`) o los valores estimados por palabras.
inicios_bloques <- function(paso, por_defecto) {
  if (file.exists(RUTA_TIMINGS)) {
    tj <- tryCatch(jsonlite::read_json(RUTA_TIMINGS, simplifyVector = FALSE), error = function(e) NULL)
    st <- Filter(function(s) identical(s$id, paso), tj$steps)
    if (length(st) == 1 && length(st[[1]]$captions) == length(por_defecto)) {
      t <- vapply(st[[1]]$captions, function(c) as.numeric(c$t), numeric(1))
      message(sprintf("  %s: tiempos de video_timings.json (%s s)", paso, paste(round(t, 1), collapse = ", ")))
      return(t)
    }
  }
  message(sprintf("  %s: tiempos estimados por palabras (%s s)", paso, paste(por_defecto, collapse = ", ")))
  por_defecto
}

#' Duración de un paso en la plantilla de tiempos (para no pasarse con el MP4).
duracion_paso <- function(paso, por_defecto) {
  for (ruta in c(RUTA_TIMINGS, RUTA_TIMINGS_PLANTILLA)) {
    if (!file.exists(ruta)) next
    tj <- tryCatch(jsonlite::read_json(ruta, simplifyVector = FALSE), error = function(e) NULL)
    st <- Filter(function(s) identical(s$id, paso), tj$steps)
    if (length(st) == 1 && !is.null(st[[1]]$duration)) return(as.numeric(st[[1]]$duration))
  }
  por_defecto
}

guardar_lienzo <- function(p, ruta, w, h, transparente = FALSE) {
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  ragg::agg_png(ruta, width = w * ESCALA, height = h * ESCALA, res = RES,
                background = if (transparente) "transparent" else "white", units = "px")
  on.exit(grDevices::dev.off())
  print(p)
  invisible(ruta)
}

ruta_ffmpeg <- function() {
  cand <- c(Sys.getenv("FFMPEG"), RUTA_FFMPEG_VENV, Sys.which("ffmpeg"))
  cand <- cand[nzchar(cand) & file.exists(cand)]
  if (length(cand) == 0) return(NA_character_)
  cand[1]
}

#' Renderiza una animación: dibujar(t) para t = 0, 1/30, …; codifica H.264 yuv420p 30 fps.
#' Devuelve la ruta del MP4 y la del último fotograma (para compararlo con el póster).
renderizar_mp4 <- function(dibujar, duracion, ruta_mp4, w, h) {
  n <- as.integer(round(duracion * FPS))
  tiempos <- (seq_len(n) - 1) / FPS
  tiempos[n] <- Inf                                   # último fotograma = estado final = póster
  dir_tmp <- file.path(tempdir(), paste0("fotogramas_", tools::file_path_sans_ext(basename(ruta_mp4))))
  unlink(dir_tmp, recursive = TRUE)
  dir.create(dir_tmp, recursive = TRUE)
  rutas <- file.path(dir_tmp, sprintf("f%04d.png", seq_len(n)))
  res <- parallel::mclapply(seq_len(n), function(i) {
    guardar_lienzo(dibujar(tiempos[i]), rutas[i], w, h)
    TRUE
  }, mc.cores = NUCLEOS, mc.preschedule = TRUE)
  fallos <- which(!vapply(res, isTRUE, logical(1)))
  if (length(fallos) > 0) stop("Fallaron fotogramas: ", paste(head(fallos), collapse = ", "), call. = FALSE)
  dir.create(dirname(ruta_mp4), recursive = TRUE, showWarnings = FALSE)
  ff <- ruta_ffmpeg()
  if (!is.na(ff)) {
    args <- c("-y", "-loglevel", "error", "-framerate", FPS, "-i", file.path(dir_tmp, "f%04d.png"),
              "-c:v", "libx264", "-pix_fmt", "yuv420p", "-preset", "slow", "-crf", "18",
              "-r", FPS, "-movflags", "+faststart", ruta_mp4)
    st <- system2(ff, args)
    if (st != 0) stop("ffmpeg devolvió ", st, call. = FALSE)
  } else {
    av::av_encode_video(rutas, output = ruta_mp4, framerate = FPS, codec = "libx264",
                        vfilter = "format=yuv420p", verbose = FALSE)
  }
  list(mp4 = ruta_mp4, ultimo = rutas[n], n = n)
}

#' Compara el último fotograma con el póster (deben ser idénticos píxel a píxel).
mismo_png <- function(a, b) {
  ia <- png::readPNG(a); ib <- png::readPNG(b)
  identical(dim(ia), dim(ib)) && max(abs(ia - ib)) < 1e-9
}

ruta_static <- function(nombre) file.path(RUTA_FIG_STATIC, paste0(nombre, ".png"))
ruta_mp4 <- function(nombre) file.path(RUTA_FIG_ANIMATED, paste0(nombre, ".mp4"))

# =============================================================================
# 3. Geografía: Natural Earth (map_units) + ajustes ONU + Robinson → tabla de vértices
# =============================================================================
#
# Natural Earth escala medium en "map_units" (así los departamentos de ultramar de Francia,
# el Caribe neerlandés, Jersey, Guernsey, etc. son polígonos propios, como en WPP). Unión por
# ISO3 con las excepciones del plan de implementación §5: Kosovo = XKX, Somalilandia → SOM,
# Chipre del Norte → CYP, Åland → FIN, Svalbard → NOR, Norfolk/Navidad/Cocos → AUS; Crimea →
# Ucrania (A/RES/68/262). Sin Antártida; marco 58° S–85° N. Gibraltar no tiene polígono a esta
# escala: solo entra como punto (portada) y en la franja de pequeños Estados (mapa).
# Los polígonos se pasan a una tabla de vértices en metros Robinson (x, y, pieza, anillo) para
# dibujarlos con geom_polygon(subgroup = anillo) en el lienzo de px tras una transformación afín.

ROBIN <- "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
LAT_SUR <- -58
LAT_NORTE <- 85
AREA_PUNTO <- 15000          # km²: países >= 1 M más pequeños que esto llevan un punto (plan §5)

proyectar <- function(lon, lat) {
  xy <- sf::st_coordinates(sf::st_transform(
    sf::st_as_sf(data.frame(lon = lon, lat = lat), coords = c("lon", "lat"), crs = 4326), ROBIN))
  data.frame(x = xy[, 1], y = xy[, 2])
}

preparar_geo <- function() {
  ne <- rnaturalearth::ne_countries(scale = "medium", type = "map_units", returnclass = "sf")
  iso <- ifelse(ne$iso_a3_eh != "-99", ne$iso_a3_eh, ne$adm0_a3)
  RECOD <- c(KOS = "XKX", SOL = "SOM", CYN = "CYP", ALA = "FIN", SJM = "NOR",
             NFK = "AUS", CXR = "AUS", CCK = "AUS")
  ne$iso3 <- ifelse(iso %in% names(RECOD), unname(RECOD[iso]), iso)
  ne <- ne[ne$iso3 != "ATA", ]
  ne$area_km2 <- as.numeric(sf::st_area(ne)) / 1e6          # geodésica (s2)
  puntos <- sf::st_drop_geometry(ne) |>
    group_by(.data$iso3) |> slice_max(.data$area_km2, n = 1, with_ties = FALSE) |> ungroup() |>
    select("iso3", lon = "label_x", lat = "label_y")
  puntos <- bind_rows(puntos, tibble(iso3 = "GIB", lon = -5.35, lat = 36.14))   # sin polígono
  area <- sf::st_drop_geometry(ne) |> group_by(.data$iso3) |>
    summarise(area_km2 = sum(.data$area_km2), .groups = "drop")

  s2_antes <- sf::sf_use_s2()
  suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(s2_antes)), add = TRUE)
  g <- ne |> select("iso3")
  g <- suppressMessages(g |> group_by(.data$iso3) |> summarise(.groups = "drop"))
  # Crimea → Ucrania (si Natural Earth la dibuja dentro de Rusia)
  partes_rus <- sf::st_cast(sf::st_geometry(g[g$iso3 == "RUS", ]), "POLYGON")
  cen <- suppressWarnings(sf::st_coordinates(sf::st_centroid(partes_rus)))
  crimea <- cen[, 1] > 32 & cen[, 1] < 37 & cen[, 2] > 44 & cen[, 2] < 46.5
  punto_crimea <- sf::st_sfc(sf::st_point(c(34.1, 45.0)), crs = 4326)
  if (any(crimea)) {
    sf::st_geometry(g)[g$iso3 == "UKR"] <- suppressMessages(
      sf::st_union(c(sf::st_geometry(g[g$iso3 == "UKR", ]), partes_rus[crimea])))
    sf::st_geometry(g)[g$iso3 == "RUS"] <- suppressMessages(sf::st_union(partes_rus[!crimea]))
  } else if (!any(suppressMessages(sf::st_intersects(g[g$iso3 == "UKR", ], punto_crimea, sparse = FALSE)))) {
    anotar_problema("Mapa: Crimea no aparece ni en RUS ni en UKR de Natural Earth (revisar versión).")
  }
  g <- sf::st_make_valid(g)
  g <- suppressWarnings(sf::st_transform(g, ROBIN))
  g <- suppressWarnings(sf::st_simplify(g, preserveTopology = TRUE, dTolerance = 2500))
  g <- sf::st_make_valid(g)
  g <- suppressWarnings(sf::st_cast(sf::st_cast(g, "MULTIPOLYGON"), "POLYGON"))
  g$area_m2 <- as.numeric(sf::st_area(g))
  g <- g[g$area_m2 > 2e6, ]                                  # migajas de < 2 km² fuera
  cc <- sf::st_coordinates(g)
  vert <- tibble(x = cc[, "X"], y = cc[, "Y"], pieza = as.integer(cc[, "L2"]),
                 anillo = as.integer(cc[, "L1"]), iso3 = g$iso3[cc[, "L2"]])
  caja <- vert |> group_by(.data$pieza) |>
    summarise(xmin = min(.data$x), xmax = max(.data$x), ymin = min(.data$y), ymax = max(.data$y),
              .groups = "drop")

  # Marco Robinson 58° S–85° N (océano)
  borde <- bind_rows(tibble(lon = -180, lat = seq(LAT_NORTE, LAT_SUR, by = -1)),
                     tibble(lon = seq(-180, 180, by = 2), lat = LAT_SUR),
                     tibble(lon = 180, lat = seq(LAT_SUR, LAT_NORTE, by = 1)),
                     tibble(lon = seq(180, -180, by = -2), lat = LAT_NORTE))
  marco <- proyectar(borde$lon, borde$lat)
  pts_xy <- proyectar(puntos$lon, puntos$lat)
  list(vert = vert, caja = caja, marco = marco,
       puntos = bind_cols(puntos, pts_xy), area = area,
       bbox = c(xmin = min(marco$x), xmax = max(marco$x), ymin = min(marco$y), ymax = max(marco$y)),
       tierra = sf::st_union(sf::st_geometry(g)))
}

#' Vista = transformación afín metros Robinson → px de la ranura:
#'   x_px = (x − cx)·s + px0 ;  y_px = (y − cy)·s + py0
vista <- function(cx, cy, s, px0, py0) list(cx = cx, cy = cy, s = s, px0 = px0, py0 = py0)
a_px <- function(df, v) {
  df$x <- (df$x - v$cx) * v$s + v$px0
  df$y <- (df$y - v$cy) * v$s + v$py0
  df
}

#' Vista del mundo entero (marco) ajustada a una caja de px (x0, y0, ancho, alto).
vista_mundo <- function(G, x0, y0, ancho, alto) {
  bw <- G$bbox[["xmax"]] - G$bbox[["xmin"]]; bh <- G$bbox[["ymax"]] - G$bbox[["ymin"]]
  s <- min(ancho / bw, alto / bh)
  vista(cx = (G$bbox[["xmin"]] + G$bbox[["xmax"]]) / 2, cy = (G$bbox[["ymin"]] + G$bbox[["ymax"]]) / 2,
        s = s, px0 = x0 + ancho / 2, py0 = y0 + alto / 2)
}

#' Vértices de los polígonos visibles en la ranura (descarta piezas fuera de la vista).
vertices_visibles <- function(G, v, W, H, margen = 20) {
  cj <- G$caja
  vis <- cj$pieza[(cj$xmax - v$cx) * v$s + v$px0 > -margen & (cj$xmin - v$cx) * v$s + v$px0 < W + margen &
                    (cj$ymax - v$cy) * v$s + v$py0 > -margen & (cj$ymin - v$cy) * v$s + v$py0 < H + margen]
  a_px(G$vert[G$vert$pieza %in% vis, ], v)
}

GEO <- NULL
cargar_geo <- function() {
  if (is.null(GEO)) {
    message("Preparando la geografía (Natural Earth + Robinson)...")
    GEO <<- preparar_geo()
    falt <- setdiff(TIPOS$ISO3_code, unique(c(GEO$vert$iso3, GEO$puntos$iso3)))
    if (length(falt) > 0) anotar_problema(paste("Áreas WPP sin polígono ni punto:", paste(falt, collapse = ", ")))
  }
  GEO
}

# =============================================================================
# 4. fig00 — portada: "un punto por país" sobre un mundo de puntos (Cover b1–b3)
# =============================================================================
#
# Qué muestra: el mundo como una trama de puntos muy tenues (tierra firme, Robinson) y encima
# UN punto del mismo tamaño por cada uno de los 237 países y áreas (cada país cuenta una vez,
# PIE-1), en su punto de etiqueta de Natural Earth, separados lo justo para que no se tapen.
#   b1 (fig00_world_dots.png, fondo blanco): los 237 en gris claro ("8 billion people").
#   b2 (…_below_replacement.png, transparente): se tiñen los 130 con fecundidad bajo reemplazo
#      (pizarra neutra: no es un tipo de palanca).
#   b3 (…_growing.png, transparente): de esos, los 84 que aún crecen pasan a azul (66, más
#      nacimientos que defunciones) y celeste (18, solo porque llegan más de los que se van);
#      los 46 restantes (decrecen) quedan en pizarra.
#   PDF (…_print.png): las tres capas juntas (estado final), como fondo de la portada impresa.
# Sin texto dentro de la imagen: las cifras y las banderas (DE, ES, BE) están en el HTML.

#' Mezcla un color con blanco (opaco): versión "tenue" del mismo color para el fondo de la
#' portada, donde encima va texto grande en tinta oscura (contraste ≥ 4,5:1 con #15233B).
tenue <- function(col, a) {
  m <- grDevices::col2rgb(col)[, 1] * a + 255 * (1 - a)
  grDevices::rgb(m[1], m[2], m[3], maxColorValue = 255)
}
COL_PUNTO_BASE <- "#D3D8DF"                 # 237 puntos tenues
COL_TRAMA      <- "#DFE3E9"                 # trama de tierra firme
COL_BAJO_REEMP <- tenue("#56657E", 0.62)    # pizarra: bajo reemplazo (sin tipo de palanca)
COL_NAC_TENUE  <- tenue(COL_NAC, 0.80)      # azul: crece por nacimientos
COL_MIG_TENUE  <- tenue(COL_MIG, 0.85)      # celeste: crece solo por llegadas
R_PUNTO_PORTADA <- 8              # radio en px de diapositiva (diámetro 16 px)
SEP_PUNTO_PORTADA <- 3            # separación mínima entre puntos (px)

#' Posiciones de los 237 puntos en px de la portada: punto de etiqueta proyectado y
#' relajación simple (empuje entre pares que se solapan + muelle hacia su sitio).
posiciones_portada <- function(G, v, r = R_PUNTO_PORTADA, sep = SEP_PUNTO_PORTADA, iter = 600) {
  p <- G$puntos |> filter(.data$iso3 %in% TIPOS$ISO3_code)
  comprobar(nrow(p) == nrow(TIPOS), "cada país y área tiene un punto en la portada")
  p <- a_px(p, v)
  x0 <- p$x; y0 <- p$y; x <- x0; y <- y0
  dmin <- 2 * r + sep
  for (it in seq_len(iter)) {
    dx <- outer(x, x, "-"); dy <- outer(y, y, "-")
    d <- sqrt(dx^2 + dy^2); diag(d) <- Inf
    solape <- pmax(0, dmin - d)
    if (max(solape) < 0.05) break
    d[!is.finite(d) | d == 0] <- 1e-6
    fx <- rowSums(solape * dx / d) * 0.5
    fy <- rowSums(solape * dy / d) * 0.5
    x <- x + fx + 0.015 * (x0 - x)
    y <- y + fy + 0.015 * (y0 - y)
  }
  dd <- as.matrix(stats::dist(cbind(x, y))); diag(dd) <- Inf
  if (min(dd) < 2 * r) anotar_problema(sprintf("Portada: quedan puntos solapados (distancia mínima %.1f px).", min(dd)))
  message(sprintf("  portada: relajación en %d iteraciones; desplazamiento máx. %.0f px, mediano %.1f px",
                  it, max(sqrt((x - x0)^2 + (y - y0)^2)), stats::median(sqrt((x - x0)^2 + (y - y0)^2))))
  p$x <- x; p$y <- y
  p |> left_join(TIPOS |> select(iso3 = "ISO3_code", "tipo", "bajo"), by = "iso3")
}

#' Trama de tierra firme: rejilla hexagonal en px cuyos puntos caen sobre tierra.
trama_tierra <- function(G, v, W, H, paso = 9) {
  filas <- seq(paso / 2, H, by = paso * sqrt(3) / 2)
  rej <- do.call(rbind, lapply(seq_along(filas), function(i) {
    data.frame(x = seq(if (i %% 2 == 0) paso / 2 else paso, W, by = paso), y = filas[i])
  }))
  # px → metros Robinson y prueba de punto en tierra
  m <- data.frame(x = (rej$x - v$px0) / v$s + v$cx, y = (rej$y - v$py0) / v$s + v$cy)
  pts <- sf::st_as_sf(m, coords = c("x", "y"), crs = ROBIN)
  tierra <- sf::st_buffer(G$tierra, 8000)        # incluye islas pequeñas que caen entre nodos
  dentro <- lengths(sf::st_intersects(pts, tierra)) > 0
  rej[dentro, ]
}

dibujar_fig00 <- function(capa = c("base", "bajo", "crece", "print"), P, trama) {
  capa <- match.arg(capa)
  W <- RANURAS$fig00[["w"]]; H <- RANURAS$fig00[["h"]]
  transparente <- capa %in% c("bajo", "crece")
  g <- lienzo(W, H, transparente = transparente)
  pt <- function(d, fill, stroke = "white") {
    geom_point(data = d, aes(.data$x, .data$y), shape = 21, size = 2 * R_PUNTO_PORTADA / .pt * 1.0,
               fill = fill, colour = stroke, stroke = 1.2 / .pt * 2)
  }
  # PDF: la portada impresa lleva además las tres preguntas en texto pequeño encima del mapa,
  # así que el fondo impreso es más tenue todavía (mismos tonos, más mezclados con blanco)
  imp <- capa == "print"
  col_trama <- if (imp) "#E8EBEF" else COL_TRAMA
  col_base <- if (imp) "#E0E4E9" else COL_PUNTO_BASE
  col_bajo <- if (imp) tenue("#56657E", 0.42) else COL_BAJO_REEMP
  col_nac <- if (imp) tenue(COL_NAC, 0.55) else COL_NAC_TENUE
  col_mig <- if (imp) tenue(COL_MIG, 0.62) else COL_MIG_TENUE
  if (capa %in% c("base", "print")) {
    g <- g + geom_point(data = trama, aes(.data$x, .data$y), shape = 16, size = 5.2 / .pt,
                        colour = col_trama)
    g <- g + pt(P, col_base)
  }
  if (capa %in% c("bajo", "print")) g <- g + pt(P[P$bajo, ], col_bajo)
  if (capa %in% c("crece", "print")) {
    g <- g + pt(P[P$bajo & P$tipo %in% c("A", "B"), ], col_nac)
    g <- g + pt(P[P$bajo & P$tipo == "C", ], col_mig)
  }
  g
}

fig_00 <- function() {
  message("fig00: portada (mundo de puntos + 237 puntos)")
  G <- cargar_geo()
  W <- RANURAS$fig00[["w"]]; H <- RANURAS$fig00[["h"]]
  # El mundo ocupa casi todo el ancho; centrado un poco por debajo de la mitad (arriba va el rótulo)
  v <- vista_mundo(G, x0 = 24, y0 = 118, ancho = W - 48, alto = H - 118 - 150)
  P <- posiciones_portada(G, v)
  trama <- trama_tierra(G, v, W, H)
  comprobar(sum(P$bajo) == cifra("n_below_replacement_2023"), "puntos bajo reemplazo (portada)")
  comprobar(sum(P$bajo & P$tipo %in% c("A", "B")) == cifra("n_below_repl_natural_growth_2023"),
            "puntos azules (portada)")
  comprobar(sum(P$bajo & P$tipo == "C") == cifra("n_grow_only_migration_2023"), "puntos celestes (portada)")
  nb <- NOMBRES[["fig00"]]
  guardar_lienzo(dibujar_fig00("base", P, trama), ruta_static(nb), W, H)
  guardar_lienzo(dibujar_fig00("bajo", P, trama), ruta_static(paste0(nb, "_below_replacement")), W, H, transparente = TRUE)
  guardar_lienzo(dibujar_fig00("crece", P, trama), ruta_static(paste0(nb, "_growing")), W, H, transparente = TRUE)
  guardar_lienzo(dibujar_fig00("print", P, trama), ruta_static(paste0(nb, "_print")), W, H)
  invisible(P)
}

# =============================================================================
# 5. fig01 — de dónde vino el crecimiento, por grupo de ingreso de hoy (S1 b2)
# =============================================================================
#
# Qué muestra: 4 paneles (Low · Lower-middle · Upper-middle · High, World Bank FY2027 aplicado a
# todos los años; sumas de países, "Not classified" fuera) con una barra por década 1950s →
# 2010–23. Azul = saldo natural (nacimientos − defunciones); celeste = migración neta, encima si
# es positiva y hacia abajo si es negativa. Eje y común y con el cero marcado (sin truncar), en
# millones de personas por década (2010–2023 tiene 14 años: se lleva a 10, como dice el HTML).
# China (Upper-middle) e India (Lower-middle) = parte del saldo natural con borde blanco.
# Corchete "2000–2023" sobre las dos últimas barras de High: ahí apunta la flecha del HTML
# (share_mig_high_2000_2023 ≈ 71 %).
#
# Animación (≈ 12 s, paso s1.b2 de 14 s; tres bloques de subtítulo):
#   b1 "In today's high-income countries, net migration accounted for" → las barras aparecen
#      década a década (contador gris "1950s" … "2010–23"), en los cuatro grupos a la vez
#   b2 "about seven in ten of the growth since 2000." → se atenúan Low / Lower-middle /
#      Upper-middle (a grises neutros: nacimientos #BDBDBD, migración #DCDCDC; nunca a un azul
#      claro que se lea como migración); aparece el corchete "2000–2023" en High
#   b3 "Elsewhere, growth came almost entirely from births exceeding deaths." → vuelven los
#      otros tres grupos, se atenúa High y aparecen las claves de China e India;
#   final (= póster PNG): todo a opacidad completa con el corchete.

#' Atenúa colores hacia un gris NEUTRO (w = 0 nada, 1 = el gris `destino`), en CIE Lab: la
#' luminosidad va en línea recta hacia la del gris y el croma (a*, b*) cae con (1 − w)^3, así un
#' azul pierde el tono antes de aclararse y en ningún instante pasa por el celeste #56B4E9
#' (otro significado en el vídeo). Con w = 0 devuelve el color original tal cual (los fotogramas
#' sin atenuar son idénticos a los pósters). Vectorizado en `col` y `w`.
atenuar <- function(col, w, destino = COL_ATENUADO) {
  n <- length(col)
  w <- pmin(1, pmax(0, rep_len(w, n)))
  out <- col
  k <- which(w > 0)
  if (length(k) == 0) return(out)
  lab <- farver::convert_colour(t(grDevices::col2rgb(col[k])), "rgb", "lab")
  dst <- farver::convert_colour(t(grDevices::col2rgb(rep_len(destino, n)[k])), "rgb", "lab")
  wk <- w[k]; ck <- (1 - wk)^3
  mezcla <- cbind(lab[, 1] + (dst[, 1] - lab[, 1]) * wk,
                  lab[, 2] * ck + dst[, 2] * (1 - ck),
                  lab[, 3] * ck + dst[, 3] * (1 - ck))
  out[k] <- farver::encode_colour(mezcla, from = "lab")
  out
}

# Estimación por palabras (150 ppm + 1,5 s de aire tras "seven in ten"), escalada al paso de 14 s:
#   8 palabras (3,2 s) · 9 palabras + aire (5,1 s) · 9 palabras (3,6 s) → inicios 0 · 3,8 · 9,8 s
BLOQUES_S1B2 <- c(0, 3.8, 9.8)
X0_FIG01 <- 63                     # borde izquierdo del primer panel (deja sitio a "400 M")

estado_fig01 <- function(t, b) {
  p <- function(t0, d = 0.5, ease = "cubic-in-out") prog(t, t0, d, ease)
  t_dec <- 0.35 + (seq_along(DECADAS) - 1) * 0.42          # inicio de cada década
  crece <- vapply(t_dec, function(t0) p(t0, 0.5), numeric(1))
  otros <- 1 - 0.68 * p(b[2], 0.5) + 0.68 * p(b[3], 0.5)
  alto <- 1 - 0.55 * p(b[3] + 0.2, 0.5) + 0.55 * p(b[3] + 2.0, 0.6)
  ultima <- if (is.finite(t)) max(c(1, which(t >= t_dec))) else length(DECADAS)
  list(marco = p(0, 0.4), crece = crece,
       alfa = c(otros, otros, otros, alto),                  # Low, Lower-middle, Upper-middle, High
       contador = p(0.3, 0.3) * (1 - p(b[2] - 0.4, 0.4)), decada = ultima,
       corchete = p(b[2] + 0.4, 0.5), claves = p(b[3] + 0.2, 0.5),
       duracion = b[3] + 2.8)
}

dibujar_fig01 <- function(t = Inf, version = c("video", "print"), d = DESCOMP, b = TIEMPOS_FIG01) {
  version <- match.arg(version)
  imp <- version == "print"
  W <- RANURAS[[if (imp) "fig01_print" else "fig01"]][["w"]]
  H <- RANURAS[[if (imp) "fig01_print" else "fig01"]][["h"]]
  e <- estado_fig01(t, b)

  # --- geometría (px de ranura; y crece hacia arriba) ---
  x_eje <- 56                                   # borde derecho de las etiquetas del eje y
  x0 <- X0_FIG01; x1 <- W - 2; hueco <- 12
  fw <- (x1 - x0 - 3 * hueco) / 4               # ancho de cada panel
  paso <- fw / length(DECADAS); bw <- paso * 0.72
  y_tit <- H - 13                               # títulos de panel
  y_sub <- H - 36                               # claves China / India
  y_top <- H - if (imp) 44 else 54              # tope del área de barras (= Y_MAX)
  y_pie <- 9
  y_dec <- if (imp) 28 else 31                  # etiquetas de década
  y_bot <- if (imp) 42 else 48                  # = Y_MIN
  Y_MAX <- 430; Y_MIN <- -45                    # millones por década (cubre todos los datos)
  stopifnot(max(d$nat + pmax(d$mig, 0)) < Y_MAX, min(pmin(d$mig, 0)) > Y_MIN)
  sy <- (y_top - y_bot) / (Y_MAX - Y_MIN)
  yv <- function(v) y_bot + (v - Y_MIN) * sy
  xp <- function(gi) x0 + (gi - 1) * (fw + hueco)          # borde izquierdo del panel gi
  xb <- function(gi, k) xp(gi) + (k - 1) * paso + (paso - bw) / 2

  g <- lienzo(W, H)
  # rejilla y eje y (común a los 4 paneles)
  marcas <- c(0, 100, 200, 300, 400)
  for (gi in 1:4) {
    g <- g + annotate("segment", x = xp(gi), xend = xp(gi) + fw, y = yv(marcas[-1]), yend = yv(marcas[-1]),
                      colour = COL_REJILLA, linewidth = 0.5, alpha = e$marco)
  }
  etq_y <- c("0", "100", "200", "300", "400 M")
  g <- g + texto(x_eje, yv(marcas), etq_y, TAM$secundario, COL_TEXTO_2, hjust = 1, alpha = e$marco)

  grupos <- levels(d$grupo)
  tit <- unname(ETIQUETAS_INGRESO_CORTAS_EN[grupos])
  for (gi in seq_along(grupos)) {
    dg <- d |> filter(.data$grupo == grupos[gi]) |> arrange(.data$k)
    a <- e$alfa[gi]
    avisar_ancho(tit[gi], TAM$grupo, fw, TRUE, "fig01 título")
    g <- g + texto(xp(gi) + 2, y_tit, tit[gi], TAM$grupo, COL_TEXTO, negrita = TRUE,
                   alpha = e$marco * max(a, 0.45))
    for (k in dg$k) {
      fila <- dg[dg$k == k, ]
      cr <- e$crece[k]
      if (cr <= 0.001) next
      xl <- xb(gi, k); xr <- xl + bw
      nat <- fila$nat * cr; mig <- fila$mig * cr
      # 1 − a = cuánto se atenúa el grupo; atenuado del todo = grises neutros (nacimientos más
      # oscuro que migración), nunca un azul claro que se confunda con el celeste de migración
      w_at <- min(1, (1 - a) / 0.55)
      g <- g + annotate("rect", xmin = xl, xmax = xr, ymin = yv(0), ymax = yv(nat),
                        fill = atenuar(COL_NAC, w_at, COL_ATENUADO_NAC), colour = NA)
      if (mig >= 0) {
        g <- g + annotate("rect", xmin = xl, xmax = xr, ymin = yv(nat), ymax = yv(nat + mig),
                          fill = atenuar(COL_MIG, w_at), colour = NA)
      } else {
        g <- g + annotate("rect", xmin = xl, xmax = xr, ymin = yv(mig), ymax = yv(0),
                          fill = atenuar(COL_MIG, w_at), colour = NA)
      }
      if (!is.na(fila$nat_pais)) {          # China / India: borde blanco dentro del azul
        # corrector-final (QA-viz V14): en el vídeo el borde aparece con su clave ("Elsewhere…")
        a_borde <- if (imp) 1 else e$claves
        if (a_borde > 0.001) g <- g + annotate("rect", xmin = xl + 1.6, xmax = xr - 1.6, ymin = yv(0) + 1.2,
                          ymax = yv(fila$nat_pais * cr) - 0.4, fill = NA,
                          colour = scales::alpha("white", a_borde), linewidth = 0.42)
      }
    }
    # línea del cero sobre las barras del panel
    g <- g + annotate("segment", x = xp(gi), xend = xp(gi) + fw, y = yv(0), yend = yv(0),
                      colour = "#6E6E6E", linewidth = 0.55, alpha = e$marco)
    # décadas: primera y última bajo cada panel
    g <- g + texto(xb(gi, 1) - 1, y_dec, ETQ_DECADA[1], TAM$secundario, COL_TEXTO_2, hjust = 0,
                   alpha = e$marco)
    g <- g + texto(xb(gi, length(DECADAS)) + bw + 1, y_dec, ETQ_DECADA[length(DECADAS)],
                   TAM$secundario, COL_TEXTO_2, hjust = 1, alpha = e$marco)
    # clave China / India (aparece con "Elsewhere…"; en print siempre)
    # (vídeo: bajo el título de su panel; PDF: una clave común en el hueco alto del panel Low)
    pais <- unique(stats::na.omit(dg$pais))
    if (!imp && length(pais) == 1 && e$claves > 0.001) {
      g <- clave_pais(g, xp(gi) + 2, y_sub, pais, e$claves)
    }
  }
  if (imp) {
    g <- g + texto(xp(1) + 4, yv(Y_MAX) - 10, "white outline:", TAM$secundario, COL_TEXTO_2)
    g <- clave_pais(g, xp(1) + 4, yv(Y_MAX) - 33, "India", 1)
    g <- clave_pais(g, xp(1) + 4 + 20 + ancho_txt("India", TAM$secundario) + 12, yv(Y_MAX) - 33, "China", 1)
  }

  # contador de década (solo mientras aparecen las barras)
  if (!imp && e$contador > 0.001) {
    g <- g + texto(xp(1) + 6, yv(385), ETQ_DECADA[e$decada], TAM$contador, "#8A8F96", negrita = TRUE,
                   alpha = e$contador)
  }

  # corchete "2000–2023" sobre las dos últimas barras de High
  a_k <- if (imp) 1 else e$corchete
  if (a_k > 0.001) {
    dh <- d |> filter(.data$grupo == "High income", .data$k %in% 6:7)
    top <- yv(max(dh$nat + pmax(dh$mig, 0))) + 8
    xa <- xb(4, 6); xz <- xb(4, 7) + bw
    g <- g + annotate("segment", x = c(xa, xa, xz), xend = c(xz, xa, xz), y = c(top + 6, top + 6, top + 6),
                      yend = c(top + 6, top, top), colour = COL_TEXTO, linewidth = 0.6, alpha = a_k)
    g <- g + texto(xz + 1, top + 19, "2000–2023", TAM$secundario + 1, COL_TEXTO,
                   hjust = 1, negrita = TRUE, alpha = a_k)
  }

  # pie corto (PIE-4 abreviado + unidad de la última barra)
  pie <- "Sums of countries · World Bank FY2027 groups, all years · 2010–23 scaled to 10 years"
  avisar_ancho(pie, TAM$pie, W - 2, donde = "fig01 pie")
  g <- g + texto(0, y_pie, pie, TAM$pie, COL_TEXTO_2, hjust = 0, alpha = e$marco)
  g
}

#' Clave "parte con borde blanco = país" (cuadrado azul con borde blanco interior + nombre).
clave_pais <- function(g, x, y, pais, a) {
  g + annotate("rect", xmin = x, xmax = x + 15, ymin = y - 7.5, ymax = y + 7.5,
               fill = scales::alpha(COL_NAC, a), colour = NA) +
    annotate("rect", xmin = x + 2.2, xmax = x + 12.8, ymin = y - 5.3, ymax = y + 5.3,
             fill = NA, colour = scales::alpha("white", a), linewidth = 0.42) +
    texto(x + 20, y, pais, TAM$secundario, COL_TEXTO, alpha = a)
}

#' Posición del corchete de High (fracción del ancho) para la flecha del HTML (--arrow-x).
centro_corchete_fig01 <- function() {
  W <- RANURAS$fig01[["w"]]; x0 <- X0_FIG01; x1 <- W - 2; hueco <- 12
  fw <- (x1 - x0 - 3 * hueco) / 4; paso <- fw / length(DECADAS); bw <- paso * 0.72
  xb <- function(gi, k) x0 + (gi - 1) * (fw + hueco) + (k - 1) * paso + (paso - bw) / 2
  ((xb(4, 6) + xb(4, 7) + bw) / 2) / W
}

TIEMPOS_FIG01 <- BLOQUES_S1B2

fig_01 <- function() {
  message("fig01: descomposición del crecimiento por ingreso")
  TIEMPOS_FIG01 <<- inicios_bloques("s1.b2", BLOQUES_S1B2)
  nb <- NOMBRES[["fig01"]]
  guardar_lienzo(dibujar_fig01(Inf, "video"), ruta_static(nb), RANURAS$fig01[["w"]], RANURAS$fig01[["h"]])
  guardar_lienzo(dibujar_fig01(Inf, "print"), ruta_static(paste0(nb, "_print")),
                 RANURAS$fig01_print[["w"]], RANURAS$fig01_print[["h"]])
  message(sprintf("  corchete 2000–2023 de High centrado en el %.0f %% del ancho (para --arrow-x del HTML)",
                  100 * centro_corchete_fig01()))
}

anim_01 <- function() {
  b <- TIEMPOS_FIG01
  dur <- estado_fig01(0, b)$duracion
  paso <- duracion_paso("s1.b2", 14)
  if (dur > paso) anotar_problema(sprintf("fig01: la animación (%.1f s) dura más que el paso s1.b2 (%.1f s).", dur, paso))
  message(sprintf("  fig01: MP4 de %.1f s (paso s1.b2 = %.1f s)", dur, paso))
  r <- renderizar_mp4(function(t) dibujar_fig01(t, "video", b = b), dur, ruta_mp4(NOMBRES[["fig01"]]),
                      RANURAS$fig01[["w"]], RANURAS$fig01[["h"]])
  if (!mismo_png(r$ultimo, ruta_static(NOMBRES[["fig01"]]))) anotar_problema("fig01: el último fotograma no coincide con el póster.")
  invisible(r)
}

# =============================================================================
# 6. fig02 — mapa de palancas 2023 (S1 b3–b4) + capas transparentes + zoom al Golfo (b5a)
# =============================================================================
#
# Qué muestra: los 237 países y áreas por tipo de palanca 2023 (Robinson, marco 58° S–85° N):
#   azul = crece por nacimientos (A+B) · celeste = crece solo porque llegan más de los que se
#   van (C) · naranja = decrece, defunciones > nacimientos (D) · púrpura rojizo = decrece porque
#   se van más de los que llegan (E). Los < 1 M van en gris en el mapa (como dice la leyenda HTML)
#   y, con su color, en una franja lateral de puntos agrupada por región (sin ocultarlos; ética
#   §2 fila 4). Los ≥ 1 M diminutos (< 15 000 km²) llevan un punto para que se vean.
#   La leyenda con conteos y banderas está en el HTML (no se repite aquí).
# Capas transparentes del mismo encuadre (overlay-fig, object-fit: contain):
#   _momentum (S1 b3b): contorno grueso de los 22 países bajo reemplazo que aún crecen por
#     nacimientos (13 en el mapa + 9 < 1 M con anillo en la franja) + ISO3 de IND, BRA, MEX.
#   _ex_c / _ex_d / _ex_e (S1 b4a–b4c, opcionales): contorno + ISO3 de los ejemplos por regla.
# Zoom (fig02b, S1 b5a, 4 s): del encuadre del mapa estático al Golfo (centro y escala de la
#   transformación afín interpolados con tweenr; escala en logaritmo), con el EAU en la franja
#   superior que deja libre la tarjeta de EAU; al final, contorno y nombre del EAU y el resto de
#   países en gris neutro #DCDCDC (ronda 1 del revisor: antes quedaban en #61a1c7, casi el
#   celeste de la leyenda, y el Golfo y la India se leían como "crece solo por llegadas").

S_REF_MAPA <- NULL   # escala (px/m) del mapa estático en vídeo; se fija al preparar la geografía
GRUPOS_FRANJA <- list(
  "Latin Am. & Caribbean" = "Latin America and the Caribbean",
  "Oceania" = "Oceania (excluding Australia and New Zealand)",
  "Europe & N. America" = "Europe and Northern America",
  "Africa" = c("Sub-Saharan Africa", "Northern Africa and Western Asia"),
  "Asia" = c("Central and Southern Asia", "Eastern and South-Eastern Asia")
)
ORDEN_TIPO <- c(A = 1, B = 1, C = 2, D = 3, E = 4)

#' Disposición del mapa y de la franja de pequeños Estados en una ranura W × H.
disposicion_fig02 <- function(W, H) {
  G <- cargar_geo()
  ancho_franja <- if (W / H > 3.2) 345 else 228
  caja <- c(x0 = 0, y0 = 4, w = W - ancho_franja - 14, h = H - 8)
  v <- vista_mundo(G, caja[["x0"]], caja[["y0"]], caja[["w"]], caja[["h"]])
  ancho_mapa <- (G$bbox[["xmax"]] - G$bbox[["xmin"]]) * v$s
  # franja: empieza justo a la derecha del mapa
  xf <- v$px0 + ancho_mapa / 2 + 14
  list(G = G, v = v, xf = xf, wf = W - xf - 2, W = W, H = H)
}

#' Posiciones de los puntos de la franja de pequeños Estados (< 1 M), por región y tipo.
franja_pequenos <- function(D, paso = 16, r = 6) {
  peq <- TIPOS |> filter(!.data$pob_1m) |>
    mutate(grupo = vapply(.data$region_sdg, function(rg) {
      names(GRUPOS_FRANJA)[vapply(GRUPOS_FRANJA, function(x) rg %in% x, logical(1))]
    }, character(1)),
    orden = ORDEN_TIPO[.data$tipo]) |>
    arrange(match(.data$grupo, names(GRUPOS_FRANJA)), .data$orden, desc(.data$pop_2023_miles))
  comprobar(nrow(peq) == cifra("n_countries") - cifra("n_ge1m"), "pequeños Estados en la franja")
  ancha <- D$wf > 300                       # PDF: cabecera en una línea y los dos últimos grupos lado a lado
  por_fila <- floor((D$wf - 2 * r) / paso) + 1
  y <- D$H - 12                             # cabecera
  cab <- list(y1 = y, y2 = if (ancha) y else y - 21, una_linea = ancha)
  y <- cab$y2 - 26
  pts <- list(); etq <- list()
  grupos <- names(GRUPOS_FRANJA)
  for (j in seq_along(grupos)) {
    gr <- grupos[j]
    sub <- peq[peq$grupo == gr, ]
    lado <- ancha && j == length(grupos)    # último grupo a la derecha del penúltimo
    if (lado) y <- y_prev
    xg <- D$xf + if (lado) D$wf / 2 else 0
    pf <- if (ancha && j >= length(grupos) - 1) floor((D$wf / 2 - 2 * r) / paso) + 1 else por_fila
    etq[[gr]] <- data.frame(grupo = gr, n = nrow(sub), x = xg, y = y)
    y_prev <- y
    y <- y - 19
    i <- seq_len(nrow(sub)) - 1
    pts[[gr]] <- sub |> mutate(x = xg + r + (i %% pf) * paso, y = y - (i %/% pf) * paso)
    y <- y - (ceiling(nrow(sub) / pf) - 1) * paso - 25
  }
  list(pts = bind_rows(pts), etq = bind_rows(etq), cab = cab, r = r, y_fin = y + 25)
}

#' Relleno de cada país en el mapa (tipo; < 1 M en gris; sin dato WPP en gris claro).
relleno_paises <- function() {
  TIPOS |> transmute(iso3 = .data$ISO3_code,
                     relleno = ifelse(.data$pob_1m, unname(PALETA_TIPO[.data$tipo]),
                                      scales::alpha(COL_PEQ, 0.55)))
}

#' Capa de polígonos del mapa en la vista v (relleno por país). El alfa se multiplica en el
#' color de relleno (el parámetro `alpha` de geom_polygon sustituiría el alfa propio de los
#' pequeños Estados); `gris_resto` (0–1) atenúa hacia el gris neutro COL_ATENUADO (opaco) todo
#' salvo `iso_destacar`. Con gris_resto = 1 todos los demás países quedan en #DCDCDC, sin tono:
#' ni el Golfo ni la India pueden leerse como "crece solo por llegadas" (celeste).
capa_paises <- function(G, v, W, H, alfa = 1, gris_resto = 0, iso_destacar = NULL) {
  # el color se calcula por país (≈ 240 filas) y luego se une a los vértices
  rel <- relleno_paises() |>
    bind_rows(tibble(iso3 = setdiff(unique(G$vert$iso3), TIPOS$ISO3_code), relleno = COL_SIN))
  rgba <- grDevices::col2rgb(rel$relleno, alpha = TRUE)
  # atenuar = pasar a gris neutro (no bajar el alfa: un azul transparente se parecería al
  # celeste, que significa otra cosa); el alfa de los pequeños Estados sube a opaco a la vez
  w <- ifelse(rel$iso3 %in% iso_destacar, 0, gris_resto)
  rgb_hex <- grDevices::rgb(rgba[1, ], rgba[2, ], rgba[3, ], maxColorValue = 255)
  rgb_at <- grDevices::col2rgb(atenuar(rgb_hex, w))
  a_at <- rgba[4, ] + (255 - rgba[4, ]) * w
  rel$relleno <- grDevices::rgb(rgb_at[1, ], rgb_at[2, ], rgb_at[3, ], alpha = a_at * alfa,
                                maxColorValue = 255)
  pv <- vertices_visibles(G, v, W, H) |> left_join(rel, by = "iso3")
  if (anyNA(pv$relleno)) stop("capa_paises: vértices sin color de relleno.", call. = FALSE)
  geom_polygon(data = pv, aes(.data$x, .data$y, group = .data$pieza, subgroup = .data$anillo,
                              fill = .data$relleno),
               colour = scales::alpha("white", alfa), linewidth = 0.22 / 2.13 * 2)
}
# (los rellenos son colores literales: escala identidad)
ESCALA_RELLENO <- scale_fill_identity()

#' Puntos de los países >= 1 M diminutos (< 15 000 km², plan §5): solo mientras su polígono
#' mida menos de lo que mide uno de 15 000 km² en el mapa estático (~9 px²); en el zoom, al
#' crecer el polígono, el punto deja de dibujarse.
capa_puntos_diminutos <- function(G, v, alfa = 1, gris_resto = 0, iso_destacar = NULL) {
  if (is.null(S_REF_MAPA)) S_REF_MAPA <<- disposicion_fig02(RANURAS$fig02[["w"]], RANURAS$fig02[["h"]])$v$s
  umbral_px2 <- AREA_PUNTO * 1e6 * S_REF_MAPA^2
  dim <- G$area |> filter(.data$iso3 %in% TIPOS$ISO3_code[TIPOS$pob_1m],
                          .data$area_km2 * 1e6 * v$s^2 < umbral_px2)
  p <- a_px(G$puntos |> filter(.data$iso3 %in% dim$iso3), v) |>
    left_join(TIPOS |> select(iso3 = "ISO3_code", "tipo"), by = "iso3")
  if (nrow(p) == 0) return(NULL)
  # mismo atenuado neutro que los polígonos (fig02b): un punto no puede quedar en su color
  relleno <- atenuar(unname(PALETA_TIPO[p$tipo]), ifelse(p$iso3 %in% iso_destacar, 0, gris_resto))
  geom_point(data = p, aes(.data$x, .data$y), shape = 21, size = 6 / .pt,
             fill = relleno, colour = "white", stroke = 0.5, alpha = alfa)
}

#' Contorno grueso de una lista de países (y anillo si son pequeños en la vista).
capa_contorno <- function(G, v, W, H, iso, alfa = 1, grosor = 1.6) {
  pv <- vertices_visibles(G, v, W, H) |> filter(.data$iso3 %in% iso)
  capas <- list(geom_polygon(data = pv, aes(.data$x, .data$y, group = .data$pieza, subgroup = .data$anillo),
                             fill = NA, colour = scales::alpha(COL_RESALTE, alfa), linewidth = grosor / 2.13))
  peq <- G$area |> filter(.data$iso3 %in% iso, .data$area_km2 * 1e6 * v$s^2 < 120)
  if (nrow(peq) > 0) {
    p <- a_px(G$puntos |> filter(.data$iso3 %in% peq$iso3), v)
    capas <- c(capas, list(geom_point(data = p, aes(.data$x, .data$y), shape = 21, size = 15 / .pt,
                                      fill = NA, colour = scales::alpha(COL_RESALTE, alfa), stroke = 1.0)))
  }
  capas
}

#' Etiqueta ISO3 con guía: (lon, lat) de la etiqueta, país al que apunta.
ETIQUETAS_MAPA <- list(
  momentum = list(list(iso = "IND", lon = 89, lat = 10, hj = 0),
                  list(iso = "BRA", lon = -33, lat = -15, hj = 0),
                  list(iso = "MEX", lon = -118, lat = 14, hj = 1)),
  C = list(list(iso = "DEU", lon = -24, lat = 62, hj = 1),
           list(iso = "BEL", lon = -24, lat = 52, hj = 1),
           list(iso = "ESP", lon = -24, lat = 40, hj = 1)),
  D = list(list(iso = "RUS", lon = 100, lat = 63, hj = 0.5, guia = FALSE),   # dentro del país
           list(iso = "CHN", lon = 104, lat = 33, hj = 0.5, guia = FALSE),
           list(iso = "JPN", lon = 150, lat = 40, hj = 0)),
  E = list(list(iso = "AZE", lon = 47, lat = 52, hj = 0.5),
           list(iso = "NPL", lon = 76, lat = 20, hj = 1),
           list(iso = "URY", lon = -45, lat = -38, hj = 0))
)

capa_etiquetas <- function(G, v, conjunto, alfa = 1, px = TAM$iso) {
  et <- ETIQUETAS_MAPA[[conjunto]]
  out <- list()
  for (e in et) {
    xy <- a_px(proyectar(e$lon, e$lat), v)
    pc <- a_px(G$puntos |> filter(.data$iso3 == e$iso), v)
    # guía desde el borde del texto hasta el punto del país (si están lejos)
    w <- ancho_txt(e$iso, px, TRUE)
    x_borde <- xy$x + (0.5 - e$hj) * w + sign(pc$x - xy$x) * w / 2
    if (abs(e$hj - 0.5) > 0.1) x_borde <- if (e$hj == 1) xy$x + 2 else xy$x - 2
    d <- sqrt((pc$x - xy$x)^2 + (pc$y - xy$y)^2)
    if (d > 16 && !isFALSE(e$guia)) {
      out <- c(out, list(annotate("segment", x = x_borde, y = xy$y, xend = pc$x, yend = pc$y,
                                  colour = scales::alpha(COL_RESALTE, alfa), linewidth = 0.9 / 2.13)))
    }
    out <- c(out, list(texto_halo(xy$x, xy$y, e$iso, px, COL_RESALTE, hjust = e$hj, negrita = TRUE, alpha = alfa)))
  }
  out
}

#' Mapa completo en una vista (sin franja). `alfa_mapa` para fundidos.
capa_mapa_base <- function(D, v, alfa = 1) {
  G <- D$G
  marco <- a_px(G$marco, v)
  list(geom_polygon(data = marco, aes(.data$x, .data$y), fill = COL_OCEANO,
                    colour = scales::alpha(COL_MARCO, alfa), linewidth = 0.8 / 2.13),
       capa_paises(G, v, D$W, D$H, alfa),
       capa_puntos_diminutos(G, v, alfa))
}

#' Franja de pequeños Estados (y anillos opcionales en algunos ISO3).
capa_franja <- function(D, F, alfa = 1, anillos = NULL, solo_anillos = FALSE) {
  out <- list()
  if (!solo_anillos) {
    out <- c(out, list(
      texto(D$xf, F$cab$y1, "Under 1 M people", TAM$secundario + 1, COL_TEXTO, negrita = TRUE, alpha = alfa),
      texto(D$xf + if (F$cab$una_linea) ancho_txt("Under 1 M people", TAM$secundario + 1, TRUE) else 0,
            F$cab$y2, sprintf("%s%d countries & areas", if (F$cab$una_linea) " · " else "", nrow(F$pts)),
            TAM$secundario, COL_TEXTO_2, alpha = alfa)))
    for (i in seq_len(nrow(F$etq))) {
      out <- c(out, list(texto(F$etq$x[i], F$etq$y[i], sprintf("%s · %d", F$etq$grupo[i], F$etq$n[i]),
                               TAM$secundario, COL_TEXTO_2, alpha = alfa)))
      avisar_ancho(sprintf("%s · %d", F$etq$grupo[i], F$etq$n[i]), TAM$secundario, D$wf, donde = "fig02 franja")
    }
    out <- c(out, list(geom_point(data = F$pts, aes(.data$x, .data$y), shape = 21, size = 2 * F$r / .pt,
                                  fill = unname(PALETA_TIPO[F$pts$tipo]), colour = "white", stroke = 0.4,
                                  alpha = alfa)))
  }
  if (!is.null(anillos)) {
    pa <- F$pts |> filter(.data$ISO3_code %in% anillos)
    if (nrow(pa) > 0) {
      out <- c(out, list(geom_point(data = pa, aes(.data$x, .data$y), shape = 21, size = (2 * F$r + 7) / .pt,
                                    fill = NA, colour = scales::alpha(COL_RESALTE, alfa), stroke = 1.0)))
    }
  }
  out
}

#' Pie corto PIE-1 al pie de la franja (el Pacífico sur no tiene sitio a 18 px).
capa_pie_mapa <- function(D, F, alfa = 1) {
  txt <- if (D$wf > 300) c("2023 estimates · each country or", "area counted once")
         else c("2023 estimates · each", "counted once")
  avisar_ancho(txt, TAM$pie, D$wf, donde = "fig02 pie")
  list(texto(D$xf, c(31, 10), txt, TAM$pie, COL_TEXTO_2, hjust = 0, alpha = alfa))
}

dibujar_fig02 <- function(capa = c("mapa", "momentum", "C", "D", "E"), version = c("video", "print")) {
  capa <- match.arg(capa); version <- match.arg(version)
  r <- RANURAS[[if (version == "print") "fig02_print" else "fig02"]]
  D <- disposicion_fig02(r[["w"]], r[["h"]])
  F <- franja_pequenos(D)
  v <- D$v
  if (capa == "mapa") {
    g <- lienzo(D$W, D$H)
    for (l in capa_mapa_base(D, v)) g <- g + l
    for (l in capa_franja(D, F)) g <- g + l
    for (l in capa_pie_mapa(D, F)) g <- g + l
    g <- g + ESCALA_RELLENO
    if (F$y_fin < 48) anotar_problema(sprintf("fig02 (%s): la franja de pequeños Estados no cabe (y = %.0f).", version, F$y_fin))
    return(g)
  }
  g <- lienzo(D$W, D$H, transparente = TRUE)
  iso <- if (capa == "momentum") TIPOS$ISO3_code[TIPOS$inercia] else cifra(paste0("examples_type_", capa, "_iso3"))
  for (l in capa_contorno(D$G, v, D$W, D$H, iso[iso %in% TIPOS$ISO3_code[TIPOS$pob_1m]])) g <- g + l
  for (l in capa_franja(D, F, anillos = iso, solo_anillos = TRUE)) g <- g + l
  for (l in capa_etiquetas(D$G, v, capa)) g <- g + l
  g
}

fig_02 <- function() {
  message("fig02: mapa de palancas 2023 + capas")
  nb <- NOMBRES[["fig02"]]
  for (ver in c("video", "print")) {
    r <- RANURAS[[if (ver == "print") "fig02_print" else "fig02"]]
    suf <- if (ver == "print") "_print" else ""
    guardar_lienzo(dibujar_fig02("mapa", ver), ruta_static(paste0(nb, suf)), r[["w"]], r[["h"]])
    guardar_lienzo(dibujar_fig02("momentum", ver), ruta_static(paste0(nb, "_momentum", suf)), r[["w"]], r[["h"]],
                   transparente = TRUE)
  }
  r <- RANURAS$fig02
  for (k in c("C", "D", "E")) {
    guardar_lienzo(dibujar_fig02(k, "video"), ruta_static(paste0(nb, "_ex_", tolower(k))), r[["w"]], r[["h"]],
                   transparente = TRUE)
  }
}

# --- 6.2 fig02b: zoom animado al Golfo (S1 b5a, 4 s) -----------------------------
# Paso s1.b5a (plantilla 4 s, subtítulo "Migration is also the least certain lever."):
#   0,0–0,5 s se desvanecen la franja de pequeños Estados, el pie y los contornos de inercia
#             (la capa _momentum seguía visible bajo el vídeo) y, a la vez, el fondo blanco fuera
#             del óvalo Robinson y su borde pasan al color del océano (así, al moverse la cámara,
#             no queda un hueco blanco donde estaba la franja ni se ve el borde del óvalo);
#             0,35–3,15 s zoom (escala en logaritmo, ancla = EAU, que viaja a su sitio final);
#             3,1–3,6 s aparece el contorno y el nombre del EAU, el resto pasa a gris NEUTRO
#             (#DCDCDC, sin tono: ningún vecino puede leerse como celeste = "crece solo por
#             llegadas") y salen los ISO3 de los vecinos del Golfo.
#   Encuadre final: 7 km por px, EAU a 72 px del borde superior (la tarjeta tapa los 226 px
#   de abajo; quedan visibles los 139 px superiores). Todas las etiquetas caen dentro de esa
#   franja visible y a ≥ 10 px del borde superior (se comprueba al dibujar el póster).
ZOOM <- list(lon = 54.3, lat = 24.2, km_px = 7, y_desde_arriba = 72, duracion = 4)
TAM_GOLFO <- list(iso = 20, eae = 24)      # px: ISO3 de los vecinos · "United Arab Emirates" (lo lee la voz)
ETIQUETAS_GOLFO <- list(
  list(iso = "SAU", lon = 45.2, lat = 22.8, hj = 0.5, guia = FALSE),
  list(iso = "IRN", lon = 57.9, lat = 27.3, hj = 0.5, guia = FALSE),   # sobre Irán, junto a Ormuz
  list(iso = "OMN", lon = 57.2, lat = 21.4, hj = 0.5, guia = FALSE),
  list(iso = "BHR", lon = 49.0, lat = 27.0, hj = 1, guia = TRUE),
  list(iso = "QAT", lon = 49.6, lat = 25.1, hj = 1, guia = TRUE)
)
MARGEN_SUP_GOLFO <- 10                     # px mínimos entre una etiqueta y el borde superior

estado_fig02b <- function(t) {
  p <- function(t0, d = 0.5, ease = "cubic-in-out") prog(t, t0, d, ease)
  # corrector-final (QA-viz V9): sin capa de inercia en el fotograma 0 (en s1.b4c se veía _ex_e, no
  # _momentum → destello); las etiquetas del Golfo entran al terminar el zoom (3,15 → 3,5 s)
  list(franja = 1 - p(0, 0.45), mom = 0, zoom = p(0.35, 2.8, "cubic-in-out"),
       final = p(3.2, 0.3))
}

#' Caja aproximada (px) de una etiqueta texto_halo: alto = 1,2 × tamaño + relleno.
caja_etiqueta <- function(x, y, txt, px, hj, negrita = FALSE) {
  w <- ancho_txt(txt, px, negrita) + 3; h <- 1.2 * px + 3
  c(x0 = x - hj * w, x1 = x + (1 - hj) * w, y0 = y - h / 2, y1 = y + h / 2)
}

dibujar_fig02b <- function(t = Inf) {
  r <- RANURAS$fig02
  D <- disposicion_fig02(r[["w"]], r[["h"]])
  F <- franja_pequenos(D)
  G <- D$G
  e <- estado_fig02b(t)
  # vista interpolada: escala geométrica; el EAU (ancla) viaja en línea recta en pantalla
  ancla <- proyectar(ZOOM$lon, ZOOM$lat)
  s0 <- D$v$s; s1 <- 1 / (ZOOM$km_px * 1000)
  p0 <- a_px(ancla, D$v); p1 <- c(D$W / 2, D$H - ZOOM$y_desde_arriba)
  s <- exp(log(s0) + (log(s1) - log(s0)) * e$zoom)
  v <- vista(ancla$x, ancla$y, s, p0$x + (p1[1] - p0$x) * e$zoom, p0$y + (p1[2] - p0$y) * e$zoom)

  g <- lienzo(D$W, D$H)
  # fondo: blanco fuera del óvalo en t = 0 (= mapa estático) → color del océano en 0,45 s
  if (e$franja < 0.999) {
    g <- g + annotate("rect", xmin = -2, xmax = D$W + 2, ymin = -2, ymax = D$H + 2,
                      fill = scales::alpha(COL_OCEANO, 1 - e$franja), colour = NA)
  }
  marco <- a_px(G$marco, v)
  g <- g + geom_polygon(data = marco, aes(.data$x, .data$y), fill = COL_OCEANO,
                        colour = if (e$franja > 0.001) scales::alpha(COL_MARCO, e$franja) else NA,
                        linewidth = 0.8 / 2.13)
  g <- g + capa_paises(G, v, D$W, D$H, gris_resto = e$final, iso_destacar = "ARE")
  g <- g + capa_puntos_diminutos(G, v, gris_resto = e$final, iso_destacar = "ARE")
  if (e$franja > 0.001) {
    for (l in capa_franja(D, F, alfa = e$franja)) g <- g + l
    for (l in capa_pie_mapa(D, F, alfa = e$franja)) g <- g + l
  }
  if (e$mom > 0.001) {      # continuidad con la capa _momentum que había debajo
    iso <- TIPOS$ISO3_code[TIPOS$inercia]
    for (l in capa_contorno(G, v, D$W, D$H, iso[iso %in% TIPOS$ISO3_code[TIPOS$pob_1m]], alfa = e$mom)) g <- g + l
    for (l in capa_franja(D, F, alfa = e$mom * e$franja, anillos = iso, solo_anillos = TRUE)) g <- g + l
    for (l in capa_etiquetas(G, v, "momentum", alfa = e$mom)) g <- g + l
  }
  if (e$final > 0.001) {
    # caja blanca de las etiquetas solo con la opacidad completa (sin cajas "fantasma" en el fundido)
    fz <- if (e$final >= 0.999) 0.85 else 0
    for (l in capa_contorno(G, v, D$W, D$H, "ARE", alfa = e$final, grosor = 2.4)) g <- g + l
    cajas <- list()
    for (et in ETIQUETAS_GOLFO) {
      xy <- a_px(proyectar(et$lon, et$lat), v)
      if (et$guia) {
        pc <- a_px(G$puntos |> filter(.data$iso3 == et$iso), v)
        g <- g + annotate("segment", x = xy$x + 3, y = xy$y, xend = pc$x, yend = pc$y,
                          colour = scales::alpha(COL_TEXTO_2, e$final), linewidth = 0.8 / 2.13)
      }
      g <- g + texto_halo(xy$x, xy$y, et$iso, TAM_GOLFO$iso, COL_TEXTO_2, hjust = et$hj, alpha = e$final, fondo = fz)
      cajas[[et$iso]] <- caja_etiqueta(xy$x, xy$y, et$iso, TAM_GOLFO$iso, et$hj)
    }
    pu <- a_px(G$puntos |> filter(.data$iso3 == "ARE"), v)
    xe <- pu$x + 78; ye <- pu$y + 26
    g <- g + annotate("segment", x = xe - 4, y = ye, xend = pu$x + 14, yend = pu$y + 4,
                      colour = scales::alpha(COL_RESALTE, e$final), linewidth = 1.1 / 2.13)
    g <- g + texto_halo(xe, ye, "United Arab Emirates", TAM_GOLFO$eae, COL_RESALTE, hjust = 0,
                        negrita = TRUE, alpha = e$final, fondo = fz)
    cajas[["ARE"]] <- caja_etiqueta(xe, ye, "United Arab Emirates", TAM_GOLFO$eae, 0, TRUE)
    # póster: cada etiqueta dentro de la franja que deja ver la tarjeta de EAU (y ≥ 226 px), a
    # ≥ 10 px del borde superior y sin solaparse con otra
    if (!is.finite(t)) {
      cj <- do.call(rbind, cajas)
      fuera <- rownames(cj)[cj[, "y1"] > D$H - MARGEN_SUP_GOLFO | cj[, "y0"] < ALTO_TARJETA_EAU |
                              cj[, "x0"] < 4 | cj[, "x1"] > D$W - 4]
      if (length(fuera) > 0) anotar_problema(paste("fig02b: etiquetas fuera de la franja visible o a < 10 px del borde:",
                                                   paste(fuera, collapse = ", ")))
      for (i in seq_len(nrow(cj) - 1)) for (j in (i + 1):nrow(cj)) {
        if (cj[i, "x0"] < cj[j, "x1"] && cj[j, "x0"] < cj[i, "x1"] && cj[i, "y0"] < cj[j, "y1"] && cj[j, "y0"] < cj[i, "y1"]) {
          anotar_problema(sprintf("fig02b: se solapan las etiquetas %s y %s.", rownames(cj)[i], rownames(cj)[j]))
        }
      }
      message(sprintf("  fig02b: margen superior mínimo de las etiquetas = %.1f px (IRN: %.1f px)",
                      D$H - max(cj[, "y1"]), D$H - cj["IRN", "y1"]))
    }
  }
  g + ESCALA_RELLENO
}

fig_02b <- function() {
  message("fig02b: póster del zoom al Golfo")
  r <- RANURAS$fig02
  ruta <- ruta_static(NOMBRES[["fig02b"]])
  guardar_lienzo(dibujar_fig02b(Inf), ruta, r[["w"]], r[["h"]])
  # Comprobación de color (corrección del revisor, ronda 1): el gris de atenuado no tiene tono
  # y está lejos de los dos azules; y en el póster no queda ningún píxel que parezca celeste
  lab <- function(x) farver::convert_colour(t(grDevices::col2rgb(x)), "rgb", "lab")
  d76 <- function(a, b) sqrt(sum((lab(a) - lab(b))^2))
  croma <- farver::convert_colour(t(grDevices::col2rgb(COL_ATENUADO)), "rgb", "lch")[, 2]
  comprobar(croma < 6 && d76(COL_ATENUADO, COL_MIG) > 25 && d76(COL_ATENUADO, COL_NAC) > 25,
            "gris de atenuado de fig02b (croma < 6 y ΔE76 > 25 con los dos azules)")
  # colores finales de todos los rellenos posibles atenuados del todo (tipos, < 1 M, sin dato)
  finales <- unique(atenuar(c(unname(PALETA_TIPO), COL_PEQ, COL_SIN), 1))
  comprobar(all(vapply(finales, d76, numeric(1), COL_ATENUADO) < 1), "todo lo atenuado acaba en COL_ATENUADO")
  im <- png::readPNG(ruta)[, , 1:3]
  px <- matrix(im, ncol = 3) * 255
  pl <- farver::convert_colour(px, "rgb", "lab")
  dmig <- sqrt(rowSums(sweep(pl, 2, lab(COL_MIG)[1, ])^2))
  n_celeste <- sum(dmig < 25)
  message(sprintf("  fig02b: gris atenuado %s (croma %.1f; ΔE76 %.1f con celeste, %.1f con azul); píxeles del póster a ΔE76 < 25 del celeste: %d de %d",
                  COL_ATENUADO, croma, d76(COL_ATENUADO, COL_MIG), d76(COL_ATENUADO, COL_NAC), n_celeste, nrow(px)))
  if (n_celeste > 0.0005 * nrow(px)) anotar_problema(sprintf("fig02b: %d píxeles del póster parecen celeste.", n_celeste))
}

anim_02b <- function() {
  dur <- ZOOM$duracion
  paso <- duracion_paso("s1.b5a", 4)
  if (dur > paso + 0.01) anotar_problema(sprintf("fig02b: el zoom (%.1f s) dura más que el paso s1.b5a (%.1f s).", dur, paso))
  # El primer fotograma debe ser el mapa estático + la capa _momentum (continuidad en pantalla)
  r <- RANURAS$fig02
  ruta0 <- file.path(tempdir(), "fig02b_t0.png")
  guardar_lienzo(dibujar_fig02b(0), ruta0, r[["w"]], r[["h"]])
  base <- magick::image_read(ruta_static(NOMBRES[["fig02"]]))
  # corrector-final: el fotograma 0 = mapa estático SIN capas (QA-viz V9)
  comp <- as.integer(magick::image_data(base, "rgb"))
  f0 <- as.integer(magick::image_data(magick::image_read(ruta0), "rgb"))
  dif <- mean(abs(comp - f0)) / 255
  message(sprintf("  fig02b: diferencia media fotograma 0 vs mapa estático = %.4f", dif))
  if (dif > 0.01) anotar_problema(sprintf("fig02b: el primer fotograma no coincide con el mapa estático (dif. %.3f).", dif))
  res <- renderizar_mp4(dibujar_fig02b, dur, ruta_mp4(NOMBRES[["fig02b"]]), r[["w"]], r[["h"]])
  if (!mismo_png(res$ultimo, ruta_static(NOMBRES[["fig02b"]]))) anotar_problema("fig02b: el último fotograma no coincide con el póster.")
  invisible(res)
}

# =============================================================================
# 7. fig03 — EAU: población 1950–2100 con la incertidumbre de la ONU (inset de S1 b5b)
# =============================================================================
#
# Qué muestra (la incertidumbre, visible una sola vez en el vídeo): población del EAU en
# millones; estimación ONU 1950–2023 en negro; línea vertical 2023/24; UN medium projection
# 2024–2100 en gris con sus intervalos de predicción probabilísticos del 80 % y 95 % (bandas
# gris oscuro / claro); escenario ONU de migración cero en naranja punteado, rotulado como
# escenario (no pronóstico). Corchete en 2050 con el intervalo del 95 % (8.9–33.3 M, mismas
# cifras y formato que numbers_q1.json). Eje y desde 0, sin truncar.

dibujar_fig03 <- function(version = c("video", "print"), f = FAN) {
  version <- match.arg(version)
  imp <- version == "print"
  r <- RANURAS[[if (imp) "fig03_print" else "fig03"]]
  W <- r[["w"]]; H <- r[["h"]]
  x0 <- 48; x1 <- W - 8; y0 <- 27; y1 <- H - 13
  Y_MAX <- 80
  stopifnot(max(f$pop_millones) < Y_MAX)
  sx <- function(a) x0 + (a - 1950) / 150 * (x1 - x0)
  sy <- function(v) y0 + v / Y_MAX * (y1 - y0)
  serie <- function(s) f |> filter(.data$serie == s) |> arrange(.data$Time)
  est <- serie("Estimate")
  med <- serie("UN medium projection") |> filter(.data$Time >= ANIO_INICIO_PROYECCION)
  zm <- serie("Zero migration scenario")
  banda <- function(lo, hi) {
    a <- serie(lo); b <- serie(hi)
    data.frame(x = sx(c(a$Time, rev(b$Time))), y = sy(c(a$pop_millones, rev(b$pop_millones))))
  }
  g <- lienzo(W, H)
  # rejilla y ejes
  marcas_y <- c(0, 20, 40, 60, 80)
  g <- g + annotate("segment", x = x0, xend = x1, y = sy(marcas_y[-1]), yend = sy(marcas_y[-1]),
                    colour = COL_REJILLA, linewidth = 0.5)
  g <- g + texto(x0 - 6, sy(marcas_y), c("0", "20", "40", "60", "80 M"), TAM$secundario, COL_TEXTO_2, hjust = 1)
  marcas_x <- c(1950, 2000, 2050, 2100)
  g <- g + texto(sx(marcas_x), 11, as.character(marcas_x), TAM$secundario, COL_TEXTO_2,
                 hjust = c(0, 0.5, 0.5, 1))
  g <- g + annotate("segment", x = sx(marcas_x), xend = sx(marcas_x), y = y0 - 5, yend = y0,
                    colour = COL_EJE, linewidth = 0.5)
  # bandas 95 % y 80 % (UN probabilistic projections)
  g <- g + annotate("polygon", x = banda("PI l95", "PI u95")$x, y = banda("PI l95", "PI u95")$y,
                    fill = COL_BANDA95, colour = NA)
  g <- g + annotate("polygon", x = banda("PI l80", "PI u80")$x, y = banda("PI l80", "PI u80")$y,
                    fill = COL_BANDA80, colour = NA)
  # 2023/24 (se corta bajo la clave para no cruzar el texto)
  paso <- if (imp) 18 else 19
  yl <- H - 13 - (0:4) * paso
  g <- g + annotate("segment", x = sx(2023.5), xend = sx(2023.5), y = y0, yend = yl[5] - 13,
                    colour = "#8E8E8E", linewidth = 0.55, linetype = "22")
  g <- g + annotate("segment", x = x0, xend = x1, y = y0, yend = y0, colour = "#6E6E6E", linewidth = 0.55)
  # líneas
  # corrector-final (QA-viz V7, V11): mediana proyectada gris DISCONTINUA (convención de proyección) y
  # escenario de migración cero en gris oscuro punteado (el naranja = "deaths > births" en la leyenda)
  g <- g + annotate("path", x = sx(med$Time), y = sy(med$pop_millones), colour = COL_MEDIANA, linewidth = 1.2,
                    linetype = "22")
  g <- g + annotate("path", x = sx(zm$Time), y = sy(zm$pop_millones), colour = COL_ESCENARIO, linewidth = 1.3,
                    linetype = "13", lineend = "round")
  g <- g + annotate("path", x = sx(est$Time), y = sy(est$pop_millones), colour = "#111111", linewidth = 1.3)
  # corchete 2050: intervalo del 95 %
  lo <- cifra("pop_are_2050_pi95_low"); hi <- cifra("pop_are_2050_pi95_high")
  comprobar(abs(lo - f$pop_millones[f$serie == "PI l95" & f$Time == 2050]) < 1e-3, "PI l95 2050")
  xb <- sx(2050)
  g <- g + annotate("segment", x = c(xb, xb - 4, xb - 4), xend = c(xb, xb + 4, xb + 4),
                    y = c(sy(lo), sy(lo), sy(hi)), yend = c(sy(hi), sy(lo), sy(hi)),
                    colour = COL_TEXTO, linewidth = 0.9 / 2.13 * 2)
  g <- g + texto_halo(xb + 7, sy(hi) + 2, fmt_clave("pop_are_2050_pi95_high"), TAM$secundario, COL_TEXTO,
                      hjust = 0, vjust = 0.2, negrita = TRUE)
  g <- g + texto_halo(xb - 7, sy(lo) - 3, fmt_clave("pop_are_2050_pi95_low"), TAM$secundario, COL_TEXTO,
                      hjust = 1, vjust = 0.8, negrita = TRUE)
  # clave arriba a la izquierda (zona vacía 1950–2040, 30–80 M)
  xs <- x0 + 6; xt <- xs + 30
  g <- g + annotate("segment", x = xs, xend = xs + 22, y = yl[1], yend = yl[1], colour = "#111111", linewidth = 1.3)
  g <- g + annotate("segment", x = xs, xend = xs + 22, y = yl[2], yend = yl[2], colour = COL_MEDIANA, linewidth = 1.2,
                    linetype = "22")
  g <- g + annotate("rect", xmin = xs, xmax = xs + 10, ymin = yl[3] - 7, ymax = yl[3] + 7, fill = COL_BANDA80)
  g <- g + annotate("rect", xmin = xs + 12, xmax = xs + 22, ymin = yl[3] - 7, ymax = yl[3] + 7, fill = COL_BANDA95,
                    colour = "#D0D0D0", linewidth = 0.3)
  g <- g + annotate("segment", x = xs, xend = xs + 22, y = yl[4], yend = yl[4], colour = COL_ESCENARIO, linewidth = 1.3,
                    linetype = "13", lineend = "round")
  clave <- c("UN estimate, 1950–2023", "UN medium projection", "80 % · 95 % range",
             "UN zero-migration scenario", "(a what-if, not a forecast)")
  avisar_ancho(clave, TAM$secundario, x1 - xt, donde = "fig03 clave")
  g <- g + texto(xt, yl, clave, TAM$secundario, c(rep(COL_TEXTO, 4), COL_TEXTO_2))
  # comprobación: la clave no pisa la banda del 95 % (borde inferior de la clave vs banda)
  fin_clave <- xt + max(ancho_txt(clave[1:4], TAM$secundario))
  anio_fin <- 1950 + (fin_clave - x0) / (x1 - x0) * 150
  u95 <- stats::approx(serie("PI u95")$Time, serie("PI u95")$pop_millones, xout = min(max(anio_fin, 2024), 2100))$y
  if (anio_fin > 2024 && sy(u95) > yl[4] - 10) anotar_problema(sprintf("fig03 (%s): la clave toca la banda del 95 %%.", version))
  g
}

fig_03 <- function() {
  message("fig03: abanico de EAU (inset)")
  nb <- NOMBRES[["fig03"]]
  guardar_lienzo(dibujar_fig03("video"), ruta_static(nb), RANURAS$fig03[["w"]], RANURAS$fig03[["h"]])
  guardar_lienzo(dibujar_fig03("print"), ruta_static(paste0(nb, "_print")),
                 RANURAS$fig03_print[["w"]], RANURAS$fig03_print[["h"]])
}

# =============================================================================
# 8. Ejecución
# =============================================================================

if (sys.nframe() == 0L) {
  cuales <- commandArgs(trailingOnly = TRUE)
  if (length(cuales) == 0) cuales <- c("fig00", "fig01", "fig02", "fig02b", "fig03")
  if ("fig00" %in% cuales) fig_00()
  if ("fig01" %in% cuales) { fig_01(); if (!SIN_MP4) anim_01() }
  if ("fig02" %in% cuales) fig_02()
  if ("fig02b" %in% cuales) { if (!"fig02" %in% cuales && !file.exists(ruta_static(NOMBRES[["fig02"]]))) fig_02()
                              fig_02b(); if (!SIN_MP4) anim_02b() }
  if ("fig03" %in% cuales) fig_03()
  if (length(AVISOS_ANCHO) > 0) message("Avisos de ancho:\n  - ", paste(AVISOS_ANCHO, collapse = "\n  - "))
  if (length(PROBLEMAS) > 0) message("Problemas anotados:\n  - ", paste(PROBLEMAS, collapse = "\n  - "))
  message(sprintf("fig_q1_slide1.R listo en %.1f s.", as.numeric(difftime(Sys.time(), t_inicio, units = "secs"))))
}
