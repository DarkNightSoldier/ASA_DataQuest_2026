#!/usr/bin/env Rscript
# =============================================================================
# fig_q3_slide4.R
# Figuras FINALES de la Slide 4 — Question 3 · P6 · P1 (storyboard v2.1 §5)
#
# Ejecutar desde la raíz del repo:
#   Rscript R/fig_q3_slide4.R              # todo: PNG, _print.png y MP4
#   Rscript R/fig_q3_slide4.R fig10        # solo una figura (fig10 | fig11)
#   FIG_SIN_MP4=1 Rscript R/fig_q3_slide4.R   # solo PNG (prueba rápida)
#
# Qué produce (nombres exactos que esperan slides/index.html y slides/js/figs.js):
#   fig10_trajectory_groups  (build 1: "One road, four groups")
#     figures/animated/fig10_trajectory_groups.mp4        2184×696, H.264 yuv420p 30 fps
#     figures/static/fig10_trajectory_groups.png          póster = último fotograma
#     figures/static/fig10_trajectory_groups_print.png    1938×328 (ranura PDF 969×164)
#     figures/static/fig10_trajectory_groups_small.png    2184×470 (ranura reducida 1092×235,
#       builds 3–5): mapa, píldoras y líneas, sin línea de hechos ni leyendas de lectura
#       (opcional para slides: sustituye al póster reducido, cuyo texto quedaría a ~12 px)
#   fig11_divergence_fan     (build 2: "closer in life expectancy, further apart in age")
#     figures/static/fig11_divergence_fan.png             1340×778 (ranura 670×389)
#     figures/static/fig11_divergence_fan_print.png       1586×320 (ranura PDF 793×160)
#   La tabla "What to watch, where, when" (build 3) y las tarjetas de ética (build 4)
#   son HTML nativo en slides/index.html: no llevan figura.
#
# Contrato con las diapositivas (slides/README.md §3):
#   * Sin título ni subtítulo dentro de la imagen (el titular y las cifras del texto
#     van en HTML desde numbers.json); sí ejes, unidades, etiquetas directas, leyendas
#     propias, línea 2023/24 y un pie corto (badge PIE-3 abreviado); fondo blanco.
#   * En el vídeo la leyenda de grupos (nombre, n, población, banderas) es HTML bajo la
#     figura: fig10.png/.mp4 solo rotula el nombre de cada columna. En el PDF esa leyenda
#     se oculta: fig10_print.png lleva la etiqueta completa por grupo (storyboard §5).
#   * Tamaño = ranura medida (dev/figure_slots.json) × 2. Con res = 144 y la imagen al
#     doble de la ranura, 1 pt de fuente = 1 px de la diapositiva 1920×1080: todos los
#     tamaños de este script (TAM$...) están en px de diapositiva.
#   * Lienzo en píxeles: cada figura se dibuja en un sistema 0..ancho × 0..alto (px de
#     la ranura) con ggplot2 + coord_cartesian(expand = FALSE). El mapa (sf, Robinson)
#     se proyecta y se lleva a ese mismo sistema; así cada etiqueta se coloca a mano,
#     nada cambia de sitio entre fotogramas y el último fotograma es el póster PNG.
#
# Animación de fig10 (fotogramas ragg + tweenr → ffmpeg del venv, H.264 yuv420p 30 fps):
#   SEÑALA lo que dice la voz en cada bloque de subtítulo del paso s4.b1 (7 bloques). Los
#   instantes salen de slides/script/video_timings.json si ya existe con `captions`; si
#   no, de la estimación por palabras del guion v2.1 (150 ppm + 1,5 s de aire tras cada
#   cifra hablada), escalada a la duración de la plantilla (s4.b1 = 26,4 s). Volver a
#   correr este script tras grabar la voz re-sincroniza.
#
# Datos (NO se recalcula ningún estadístico; solo se leen resultados ya calculados):
#   figures/numbers_q3.json                         cifras finales (valor, IC, fmt)
#   data/processed/resultados_q3_paises.parquet     grupo, estabilidad (keep_share), medoide
#   data/processed/resultados_q3_bandas.parquet     mediana y P10–P90 por grupo y año
#   data/processed/resultados_q3_dispersion.parquet P10–P90, DE y razón P90/P10 entre países
#   data/processed/paises.parquet (vía comun_analisis.R)  serie del país medoide y ISO2
#   rnaturalearth (Natural Earth, escala medium)    polígonos del mapa
#
# Convención: código y comentarios en español; todo texto visible en inglés llano.
# =============================================================================

t_inicio <- Sys.time()

suppressPackageStartupMessages({
  library(here)
})
source(here::here("R", "config.R"))
source(here::here("R", "utilidades.R"))
source(here::here("R", "comun_analisis.R"))   # paletas v2, datos_paises, formatear_cifra()

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
for (.p in c("rnaturalearth", "rnaturalearthdata", "ggflags", "png")) {
  if (!requireNamespace(.p, quietly = TRUE)) stop("Falta el paquete ", .p, call. = FALSE)
}
rm(.p)

# =============================================================================
# 0. Constantes de salida, tamaños y colores
# =============================================================================

ESCALA <- 2                       # imagen = 2 × ranura (README §3: "exportar a 2×")
RES <- 72 * ESCALA                # 144 ppp → 1 pt = 1 px de diapositiva
FPS <- 30
NUCLEOS <- max(1L, min(8L, parallel::detectCores() - 4L))
SIN_MP4 <- nzchar(Sys.getenv("FIG_SIN_MP4"))
FUENTE <- "Lato"

# Ranuras medidas en px de diapositiva (slides/README.md §3 y dev/figure_slots.json).
# fig10 y fig11 se reducen desde el build 3 (1092×235 y 670×235): se diseñan para la
# ranura de foco (builds 1–2), que es donde la voz las comenta.
RANURAS <- list(
  fig10 = c(w = 1092, h = 348), fig10_print = c(w = 969, h = 164),
  # corrector-final 2026-10-25 (QA-viz V5): ranura medida desde b3 = 1021×220 (antes 1092×235 →
  # la figura se veía al 0,935); fig11 tiene variante _small 741×150 para b3–b5 (el PDF sigue con _print)
  fig10_small = c(w = 1021, h = 220),     # builds 3–5 (ranura reducida, README §3)
  fig11 = c(w = 670, h = 389),  fig11_print = c(w = 793, h = 160), fig11_small = c(w = 741, h = 150)
)
NOMBRES <- c(fig10 = "fig10_trajectory_groups", fig11 = "fig11_divergence_fan")

# Tamaños de letra (px de diapositiva). Etiquetas principales 20–22 px; mínimo 18 px
# (README §3 y storyboard §9: pies 18 px).
TAM <- list(grupo = 20, fila = 20, eje = 18, hecho = 20, nota = 18, iso = 18,
            panel = 21, valor = 20, pie = 18)

COL_TEXTO   <- "#1A1A1A"
COL_TEXTO_2 <- "#555555"          # texto secundario (contraste 7,5:1 sobre blanco)
COL_TINTA   <- "#15233B"          # --ink de theme.css
COL_REJILLA <- "#E6E6E6"
COL_EJE     <- "#9A9A9A"
COL_BASE_MAPA <- "#E2E2E2"        # < 1 M / sin grupo (y fondo antes de colorear)
COL_RAYA_GRIS <- "#A4A4A4"        # rayado de los < 1 M
COL_PROY_BANDA <- "#E4E4E4"       # proyección: banda gris (sombra visible a este tamaño)
COL_PROY_LINEA <- "#9A9A9A"       # proyección: mediana gris punteada (≈ COLOR_PROYECCION)
COL_Q5      <- COLOR_DEFUNCIONES  # "#E69F00": mortalidad infantil (igual que fig05)
COL_Q5_TXT  <- "#8A5A00"          # texto naranja oscuro legible sobre blanco

GRUPOS <- c("Early movers", "Fast movers", "Recent movers", "Migration-led")
stopifnot(identical(names(PALETA_GRUPOS_V2), GRUPOS))
COL_GRUPO <- PALETA_GRUPOS_V2                                           # Tol (storyboard §8)
COL_GRUPO_LINEA <- setNames(c("#332288", "#117733", "#9E8A2A", "#2F86B8"), GRUPOS)  # mismo tono, más oscuro si el Tol es claro
ALFA_BANDA <- setNames(c(0.24, 0.24, 0.55, 0.55), GRUPOS)
COL_TXT_PILDORA <- setNames(c("white", "white", COL_TINTA, COL_TINTA), GRUPOS)
DIM <- 0.25                        # opacidad relativa de lo que no nombra la voz
# Cuando la voz nombra 3 países, el resto de su grupo se aclara hacia el blanco: poco en
# los grupos oscuros y casi hasta el fondo en los claros (Recent #DDCC77, Migration-led
# #88CCEE). Con 0,42 el resto de Recent quedaba en #EAE0AF (ΔL* ≈ 8 frente a #DDCC77) y
# no se distinguía; con 0,85 queda en #FAF7EB (ΔL* ≈ 16).
ATENUAR_RESTO <- setNames(c(0.42, 0.42, 0.85, 0.85), GRUPOS)
# Rayado de los inestables: blanco sobre los colores oscuros; tono oscuro del grupo sobre
# los claros (el blanco casi no se ve sobre #DDCC77).
COL_RAYA_GRUPO <- setNames(c("white", "white", COL_GRUPO_LINEA[["Recent movers"]],
                             COL_GRUPO_LINEA[["Migration-led"]]), GRUPOS)
# Inestables más pequeños que esto (km²) llevan además un anillo discontinuo alrededor: a
# 456 px de ancho el rayado no se ve en Armenia, Rep. de Corea ni Guatemala (Nepal,
# 147 000 km², sí). Anillo y no punto relleno: un punto taparía a los vecinos (Corea del
# Norte, Kyushu).
AREA_PUNTO_RAYADO <- 120000
RADIO_PUNTO_RAYADO <- 6            # px de ranura (mapa de 456 px; se escala con el ancho)
# fig11: banda entre países en tinta azulada, NO gris (gris = proyección en todo el vídeo;
# #B9C6DE: ΔE ≈ 16 frente al gris de proyección #E4E4E4, saturación HSL ≈ 36 %).
# corrector-final (QA-viz V13): #B9C6DE quedaba a ΔE76 6,5 de la banda de Early movers (#CECAE3)
# que está al lado en fig10 → tinta neutra #D5DAE3 (ΔE 10,3 frente a Early; mediana en tinta #15233B)
COL_BANDA_PAISES <- "#D5DAE3"
# Texto único de la banda P10–P90 de fig10 (vídeo b2, póster y versión impresa; revisión
# r2: había dos formulaciones para la misma banda)
BANDA_TXT <- "band = middle 80 % of the group’s countries (spread, not uncertainty)"

# ffmpeg de imageio-ffmpeg dentro del venv del proyecto: variable de entorno VENV (ver SETUP.md);
# si no está, se usan FFMPEG o el ffmpeg del sistema (ruta_ffmpeg()). Sin rutas de esta máquina.
RUTA_FFMPEG_VENV <- local({
  venv <- Sys.getenv("VENV")
  cand <- if (nzchar(venv)) Sys.glob(file.path(venv, "lib", "python3*", "site-packages", "imageio_ffmpeg",
                                              "binaries", "ffmpeg-*")) else character(0)
  if (length(cand)) cand[length(cand)] else ""
})
RUTA_TIMINGS <- file.path(RUTA_RAIZ, "slides", "script", "video_timings.json")

# =============================================================================
# 1. Lectura de cifras (solo resultados ya calculados)
# =============================================================================

NUM <- jsonlite::read_json(file.path(RUTA_FIGURAS, "numbers_q3.json"), simplifyVector = TRUE)

#' Devuelve un campo de una clave de numbers_q3.json (para avisar si falta).
cifra <- function(clave, campo = "value") {
  if (is.null(NUM[[clave]])) stop("numbers_q3.json no trae la clave '", clave, "'.", call. = FALSE)
  NUM[[clave]][[campo]]
}

#' Formatea con el mismo `fmt` de numbers.json y el signo menos tipográfico de
#' slides/js/numbers.js (U+2212), para que la figura muestre lo mismo que el HTML.
fmt_cifra <- function(valor, fmt) sub("^-", "−", formatear_cifra(valor, fmt))
fmt_clave <- function(clave, fmt = NULL) {
  fmt_cifra(cifra(clave), if (is.null(fmt)) cifra(clave, "fmt") else fmt)
}

#' Intervalo ci_low–ci_high de una clave, con el mismo `fmt` que su valor y sin ceros
#' decimales sobrantes ("29–42.5", no "29.0–42.5"). Si la clave no trae IC, lo anota.
fmt_rango <- function(clave, fmt = NULL) {
  lo <- cifra(clave, "ci_low"); hi <- cifra(clave, "ci_high")
  if (is.null(lo) || is.null(hi) || is.na(lo) || is.na(hi)) {
    anotar_problema(sprintf("%s no trae ci_low/ci_high en numbers_q3.json: no se muestra su intervalo.", clave))
    return(NA_character_)
  }
  s <- fmt_cifra(c(lo, hi), if (is.null(fmt)) cifra(clave, "fmt") else fmt)
  s <- sub("\\.0+$", "", s)
  paste0(s[1], "–", s[2])
}

#' Trazabilidad (revisión r2): toda clave cuya cifra se ve en fig10 debe declarar la
#' diapositiva en `used_in`; si no, QA-stats no la verifica y record_slides no la bloquea.
CLAVES_FIG10 <- c("cluster_sizes", "cluster_pop_bn", "cluster_examples_iso3", "cluster_medoids",
                  "cluster_profile", "growth_2024_2050_by_group",
                  "n_gulf_migration_led", "cluster_examples_migration", "cluster_examples_recent",
                  "yrs_medage30_40_early", "yrs_medage30_40_recent", "share_keep_ge_0.8",
                  "borderline_countries")
# corrector-final (QA-viz V1–V2): growth_2000_2023_by_group, are_revision_pct y sau_revision_pct
# no están verificadas (o no existen) → ya no se dibujan en fig10
verificar_used_in <- function(claves, diapo = "slide4.build1") {
  for (cl in claves) {
    if (is.null(NUM[[cl]])) next                 # las que faltan se anotan donde se usan
    u <- unlist(NUM[[cl]][["used_in"]])
    if (!diapo %in% u) {
      anotar_problema(sprintf("%s se ve en fig10 pero su used_in (%s) no incluye '%s' (agente Q3).",
                              cl, paste(u, collapse = ", "), diapo))
    }
  }
}

#' Tabla de un campo `value` que viene como lista de registros (data.frame con `grupo`).
tabla_grupo <- function(clave) {
  v <- cifra(clave)
  if (!is.data.frame(v) || !"grupo" %in% names(v)) stop("La clave ", clave, " no es una tabla por grupo.", call. = FALSE)
  v[match(GRUPOS, v$grupo), ]
}

PROBLEMAS <- character(0)
anotar_problema <- function(txt) {
  if (!txt %in% PROBLEMAS) { PROBLEMAS <<- c(PROBLEMAS, txt); message("  PROBLEMA: ", txt) }
}

# --- 1.1 Q3: grupos, bandas, medoides, ejemplos ---------------------------------
leer_q3 <- function() {
  paises <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q3_paises.parquet"))
  bandas <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q3_bandas.parquet")) |>
    filter(.data$variable %in% c("TFR", "MedianAgePop"), .data$Time <= 2050)
  tam <- unlist(cifra("cluster_sizes"))[GRUPOS]
  pob <- unlist(cifra("cluster_pop_bn"))[GRUPOS]
  ej  <- cifra("cluster_examples_iso3")[GRUPOS]
  med_nombre <- unlist(cifra("cluster_medoids"))[GRUPOS]

  # Comprobaciones cruzadas json ↔ parquet (si no coinciden, alguien re-corrió solo una parte)
  stopifnot(nrow(paises) == 161, setequal(unique(paises$grupo), GRUPOS))
  n_par <- as.integer(table(factor(paises$grupo, levels = GRUPOS)))
  if (!identical(as.integer(tam), n_par)) stop("cluster_sizes no coincide con resultados_q3_paises.parquet.", call. = FALSE)
  med <- paises |> filter(.data$es_medoide) |> select("grupo", "ISO3_code", "Location")
  med <- med[match(GRUPOS, med$grupo), ]
  if (!identical(unname(med$Location), unname(med_nombre))) stop("cluster_medoids no coincide con el parquet.", call. = FALSE)
  if (!setequal(unlist(ej), paises$ISO3_code[paises$es_ejemplo])) stop("cluster_examples_iso3 no coincide con es_ejemplo.", call. = FALSE)
  keep <- 100 * mean(paises$keep_share >= 0.8)
  if (abs(keep - cifra("share_keep_ge_0.8")) > 1e-9) stop("share_keep_ge_0.8 no coincide con keep_share.", call. = FALSE)
  if (sum(paises$keep_share < 0.8) != cifra("borderline_countries", "n")) stop("borderline_countries no coincide.", call. = FALSE)
  nb <- bandas |> filter(.data$Time == 1950, .data$variable == "TFR")
  if (!identical(as.integer(nb$n[match(GRUPOS, nb$grupo)]), n_par)) stop("bandas: n por grupo distinto.", call. = FALSE)

  # Serie del país medoide (dato WPP tal cual; estimación ≤ 2023, proyección Medium ≥ 2024)
  serie_med <- datos_paises |>
    filter(.data$ISO3_code %in% med$ISO3_code, .data$Time <= 2050) |>
    select("ISO3_code", "Time", "TFR", "MedianAgePop") |>
    left_join(med |> select("ISO3_code", "grupo"), by = "ISO3_code") |>
    tidyr::pivot_longer(c("TFR", "MedianAgePop"), names_to = "variable", values_to = "valor")

  iso2 <- datos_paises |> filter(.data$Time == 2023) |> select("ISO3_code", "ISO2_code") |> distinct()

  # Países del Golfo (CCG) dentro de Migration-led: la lista sale del 'def' de la clave
  # (b3 contornea solo estos; Jordania y Yibuti quedan coloreados, sin contorno)
  def_golfo <- cifra("n_gulf_migration_led", "def")
  lista <- regmatches(def_golfo, regexpr("\\(([A-Z]{3}(, )?)+\\)", def_golfo))
  if (length(lista) != 1) stop("n_gulf_migration_led: el 'def' ya no trae la lista ISO3 del CCG.", call. = FALSE)
  ccg <- strsplit(gsub("[()]", "", lista), ", ")[[1]]
  golfo <- intersect(paises$ISO3_code[paises$grupo == "Migration-led"], ccg)
  if (length(golfo) != cifra("n_gulf_migration_led")) stop("n_gulf_migration_led no coincide con los miembros del grupo.", call. = FALSE)
  list(
    paises = paises, bandas = bandas, serie_med = serie_med, medoide = med,
    tam = tam, pob = pob, ejemplos = ej, golfo = golfo,
    inestables = paises$ISO3_code[paises$keep_share < 0.8],
    grupo_de = setNames(paises$grupo, paises$ISO3_code),
    iso2 = setNames(tolower(iso2$ISO2_code), iso2$ISO3_code)
  )
}

# --- 1.2 P1: dispersión entre países (fig11) ------------------------------------
leer_dispersion <- function() {
  d <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q3_dispersion.parquet")) |>
    filter(.data$universo == "161 countries ≥ 1 M", .data$Time <= ANIO_FIN_ESTIMACION)
  ver <- function(var, anio, col, clave) {
    v <- d[[col]][d$variable == var & d$Time == anio]
    if (length(v) != 1 || abs(v - cifra(clave)) > 1e-6) {
      stop(sprintf("%s no coincide con dispersion.parquet (%s %d).", clave, var, anio), call. = FALSE)
    }
  }
  ver("LEx", 1950, "de", "sd_lex_1950"); ver("LEx", 2023, "de", "sd_lex_2023")
  ver("MedianAgePop", 1950, "de", "sd_medage_1950"); ver("MedianAgePop", 2023, "de", "sd_medage_2023")
  ver("Q5", 1950, "razon_p90p10", "q5_ratio_p90p10_1950"); ver("Q5", 2023, "razon_p90p10", "q5_ratio_p90p10_2023")
  q5 <- d |> filter(.data$variable == "Q5")
  pico <- q5[which.max(q5$razon_p90p10), ]
  if (abs(pico$razon_p90p10 - cifra("q5_ratio_p90p10_peak")) > 1e-6 || pico$Time != cifra("q5_ratio_p90p10_peak_year")) {
    stop("q5_ratio_p90p10_peak no coincide con dispersion.parquet.", call. = FALSE)
  }
  if (any(d$n[d$variable %in% c("LEx", "MedianAgePop", "Q5")] != 161)) stop("dispersion: n distinto de 161.", call. = FALSE)
  list(lex = d |> filter(.data$variable == "LEx"), edad = d |> filter(.data$variable == "MedianAgePop"),
       q5 = q5, pico = pico)
}

# =============================================================================
# 2. Ayudas de lienzo, texto y tiempo (mismas convenciones que fig_q2_slide3.R)
# =============================================================================

#' Tema común de las figuras del vídeo: lienzo blanco, Lato, sin márgenes.
if (!exists("tema_dq")) {
  tema_dq <- function(base_family = FUENTE) {
    theme_void(base_family = base_family) +
      theme(plot.background = element_rect(fill = "white", colour = NA),
            panel.background = element_rect(fill = "white", colour = NA),
            plot.margin = margin(0, 0, 0, 0), legend.position = "none")
  }
}

#' Lienzo en px de la ranura (0..w × 0..h).
lienzo <- function(w, h) {
  ggplot() +
    coord_cartesian(xlim = c(0, w), ylim = c(0, h), expand = FALSE, clip = "off") +
    scale_fill_identity() + scale_colour_identity() + scale_alpha_identity() +
    scale_linewidth_identity() + scale_linetype_identity() + scale_size_identity() +
    tema_dq()
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
  if (length(alpha) == 1 && alpha <= 0.001) return(NULL)
  cara <- if (negrita && cursiva) "bold.italic" else if (negrita) "bold" else if (cursiva) "italic" else "plain"
  annotate("text", x = x, y = y, label = label, size = px / .pt, colour = colour,
           hjust = hjust, vjust = vjust, family = FUENTE, fontface = cara, alpha = alpha,
           angle = angle, lineheight = 0.95)
}

#' Texto con halo blanco (para etiquetas que caen sobre el mapa o sobre bandas).
texto_halo <- function(x, y, label, px, colour = COL_TEXTO, hjust = 0, vjust = 0.5,
                       negrita = FALSE, alpha = 1) {
  if (alpha <= 0.001) return(NULL)
  annotate("label", x = x, y = y, label = label, size = px / .pt, colour = colour,
           hjust = hjust, vjust = vjust, family = FUENTE,
           fontface = if (negrita) "bold" else "plain", alpha = alpha,
           fill = scales::alpha("white", 0.85 * alpha), border.colour = NA, linewidth = 0,
           label.padding = unit(1.2, "pt"), label.r = unit(2, "pt"))
}

#' Rectángulo redondeado (píldora) en coordenadas de la ranura.
pildora <- function(xmin, xmax, ymin, ymax, fill, alpha = 1, r = 5) {
  if (alpha <= 0.001) return(NULL)
  annotation_custom(grid::roundrectGrob(r = unit(r, "pt"),
                                        gp = grid::gpar(fill = fill, col = NA, alpha = alpha)),
                    xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax)
}

#' Muestra de leyenda rayada: rectángulo relleno con rayas a 45° (como las del mapa)
#' RECORTADAS al rectángulo, para que no toquen el texto de al lado (revisión r2).
muestra_rayada <- function(g, x0, x1, y0, y1, fill, raya, paso, alpha = 1, lw = 0.42) {
  if (alpha <= 0.001) return(g)
  g <- g + annotate("rect", xmin = x0, xmax = x1, ymin = y0, ymax = y1, fill = fill, colour = NA, alpha = alpha)
  cs <- seq(x0 - y1 + paso / 2, x1 - y0, by = paso)        # rectas y = x − c
  xa <- pmax(x0, y0 + cs); xb <- pmin(x1, y1 + cs)
  ok <- xb - xa > 0.4
  g + annotate("segment", x = xa[ok], xend = xb[ok], y = xa[ok] - cs[ok], yend = xb[ok] - cs[ok],
               colour = raya, linewidth = lw, alpha = alpha, lineend = "butt")
}

#' Mezcla un color con blanco (p = 0: el color; p = 1: blanco). Para atenuar sin
#' transparencia (el mapa no debe mezclarse con el gris de fondo).
hacia_blanco <- function(col, p) {
  m <- grDevices::col2rgb(col) / 255
  p <- pmin(1, pmax(0, p))
  out <- m * rep(1 - p, each = 3) + rep(p, each = 3)
  grDevices::rgb(out[1, ], out[2, ], out[3, ])
}
#' Interpola entre dos colores (p = 0: a; p = 1: b).
mezclar <- function(a, b, p) {
  n <- max(length(a), length(b), length(p))
  ma <- grDevices::col2rgb(rep_len(a, n)) / 255; mb <- grDevices::col2rgb(rep_len(b, n)) / 255
  p <- rep_len(pmin(1, pmax(0, p)), n)
  out <- ma * rep(1 - p, each = 3) + mb * rep(p, each = 3)
  grDevices::rgb(out[1, ], out[2, ], out[3, ])
}

#' Progreso 0→1 de una transición que empieza en t0 y dura `d` segundos (tweenr).
prog <- function(t, t0, d = 0.5, ease = "cubic-in-out") {
  if (!is.finite(t)) return(1)
  p <- min(1, max(0, (t - t0) / d))
  if (p <= 0) return(0)
  if (p >= 1) return(1)
  tweenr::tween_at(0, 1, p, ease)
}

#' Valor por fotogramas clave: en cada instante clave el valor pasa (en `d` s) del
#' vector anterior al nuevo. `valores` = matriz (una fila por instante).
por_claves <- function(t, tiempos, valores, d = 0.5) {
  if (!is.finite(t)) return(valores[nrow(valores), ])
  k <- max(which(tiempos <= t), 1)
  if (k == 1) return(valores[1, ])
  p <- prog(t, tiempos[k], d)
  valores[k - 1, ] + (valores[k, ] - valores[k - 1, ]) * p
}

#' Inicios de los bloques de subtítulo de un paso: de slides/script/video_timings.json
#' (si el agente de guion ya lo escribió con `captions[].t`) o los valores por defecto.
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

#' Duración del paso (s): `duration` de video_timings.json si existe; si no, la plantilla.
#' El MP4 de fig10 termina en ese instante (no se mete en el paso siguiente, s4.b2).
duracion_paso <- function(paso, por_defecto) {
  if (file.exists(RUTA_TIMINGS)) {
    tj <- tryCatch(jsonlite::read_json(RUTA_TIMINGS, simplifyVector = FALSE), error = function(e) NULL)
    st <- Filter(function(s) identical(s$id, paso), tj$steps)
    if (length(st) == 1 && is.numeric(st[[1]]$duration)) return(as.numeric(st[[1]]$duration))
  }
  por_defecto
}

# Estimación por palabras (guion v2.1 con las cifras reales; 150 ppm, 0,3 s entre frases,
# 1,5 s de aire tras cifra hablada) escalada a la duración de la plantilla (26,4 s):
#   b1 "Question three."                                                     0,0
#   b2 "Grouped by seventy-year paths, countries form three stretches…"      1,0
#   b3 "plus a migration-led group, mostly Gulf states."                     4,9
#   b4 "Early movers, the United States, Russia and Japan, now grow…"       7,6
#   b5 "Fast movers, India, China and Indonesia, are projected to age in 32" 13,2
#   b6 "what took Early movers 37." (guion r2 propuesto: "…about as fast as
#      Early movers did, or faster." — la pantalla dice "about as fast or faster")  19,1
#   b7 "Recent movers, Pakistan, Nigeria and Ethiopia, still have high…"     22,5 → fin 26,4
BLOQUES_S4B1 <- c(0, 1.0, 4.9, 7.6, 13.2, 19.1, 22.5)

#' Hitos de s4.b1 desde video_timings.json (corrector-final 2026-10-25, QA-viz V10). El guion v4 tiene
#' 8 bloques: Question three · Grouped… · plus a migration-led… · Early movers… · Fast movers, India… ·
#' are projected to age… · About as fast… · Recent movers… → se toman los bloques 1–5, 7 y 8. La fase
#' Fast se adelanta 0,2 s (la voz la nombra al empezar el bloque; antes llegaba 1 s tarde).
tiempos_s4b1 <- function() {
  if (file.exists(RUTA_TIMINGS)) {
    tj <- tryCatch(jsonlite::read_json(RUTA_TIMINGS, simplifyVector = FALSE), error = function(e) NULL)
    st <- Filter(function(s) identical(s$id, "s4.b1"), tj$steps)
    if (length(st) == 1) {
      t <- vapply(st[[1]]$captions, function(c) as.numeric(c$t), numeric(1))
      b <- if (length(t) == 8) t[c(1, 2, 3, 4, 5, 7, 8)] else if (length(t) == 7) t else NULL
      if (!is.null(b)) {
        b[5] <- b[5] - 0.2
        message(sprintf("  s4.b1: hitos de video_timings.json (%s s)", paste(round(b, 1), collapse = ", ")))
        return(b)
      }
    }
  }
  message("  s4.b1: hitos por defecto (", paste(BLOQUES_S4B1, collapse = ", "), " s)")
  BLOQUES_S4B1
}
DURACION_S4B1 <- 26.4              # slides/dev/video_timings.template.json (s4.b1)

# =============================================================================
# 3. Exportación: PNG (ragg) y MP4 (fotogramas → ffmpeg del venv)
# =============================================================================

guardar_lienzo <- function(p, ruta, w, h) {
  dir.create(dirname(ruta), recursive = TRUE, showWarnings = FALSE)
  ragg::agg_png(ruta, width = w * ESCALA, height = h * ESCALA, res = RES,
                background = "white", units = "px")
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
#' El último fotograma se dibuja con t = Inf (estado final = póster PNG).
renderizar_mp4 <- function(dibujar, duracion, ruta_mp4, w, h) {
  n <- as.integer(round(duracion * FPS))
  tiempos <- (seq_len(n) - 1) / FPS
  tiempos[n] <- Inf
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

# =============================================================================
# 4. Mapa (sf + Robinson → coordenadas normalizadas → px de la ranura)
# =============================================================================
#
# Natural Earth (medium), unión por ISO3 con las excepciones del plan (§5): Kosovo = XKX,
# Somalilandia → SOM, Chipre del Norte → CYP, Åland → FIN; Crimea → Ucrania
# (A/RES/68/262); departamentos de ultramar de Francia y Caribe neerlandés separados
# (son áreas propias < 1 M en WPP). Sin Antártida. Robinson. Simplificado a ~8 km (a
# 456 px de ancho un píxel son ~75 km). Coordenadas normalizadas: x en 0..1.
# Los países ≥ 1 M diminutos (< 15 000 km²) llevan además un punto (plan §5).

preparar_mapa <- function() {
  ne <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
  ne$iso3 <- ifelse(ne$iso_a3_eh != "-99", ne$iso_a3_eh, ne$adm0_a3)
  RECOD <- c(KOS = "XKX", SOL = "SOM", CYN = "CYP", ALA = "FIN")
  ne$iso3 <- ifelse(ne$iso3 %in% names(RECOD), unname(RECOD[ne$iso3]), ne$iso3)
  ne$area_km2 <- as.numeric(sf::st_area(ne)) / 1e6                       # geodésica (s2)
  puntos <- ne |> sf::st_drop_geometry() |>
    group_by(.data$iso3) |> slice_max(.data$area_km2, n = 1, with_ties = FALSE) |> ungroup() |>
    select("iso3", lon = "label_x", lat = "label_y")
  area <- ne |> sf::st_drop_geometry() |> group_by(.data$iso3) |>
    summarise(area_km2 = sum(.data$area_km2), .groups = "drop")

  s2_antes <- sf::sf_use_s2()
  suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(s2_antes)), add = TRUE)
  mapa <- ne |> select("iso3")
  partes_rus <- sf::st_cast(sf::st_geometry(mapa[mapa$iso3 == "RUS", ]), "POLYGON")
  cen <- suppressWarnings(sf::st_coordinates(sf::st_centroid(partes_rus)))
  crimea <- cen[, 1] > 32 & cen[, 1] < 37 & cen[, 2] > 44 & cen[, 2] < 46.5
  if (any(crimea)) {
    sf::st_geometry(mapa)[mapa$iso3 == "UKR"] <- suppressMessages(
      sf::st_union(c(sf::st_geometry(mapa[mapa$iso3 == "UKR", ]), partes_rus[crimea])))
    sf::st_geometry(mapa)[mapa$iso3 == "RUS"] <- suppressMessages(sf::st_union(partes_rus[!crimea]))
  } else {
    anotar_problema("Mapa: no se encontró Crimea dentro de RUS en Natural Earth (revisar versión).")
  }
  for (iso in c("FRA", "NLD")) {
    partes <- sf::st_cast(sf::st_geometry(mapa[mapa$iso3 == iso, ]), "POLYGON")
    cc <- suppressWarnings(sf::st_coordinates(sf::st_centroid(partes)))
    eur <- cc[, 1] > -30 & cc[, 2] > 30
    if (any(!eur)) {
      sf::st_geometry(mapa)[mapa$iso3 == iso] <- suppressMessages(sf::st_union(partes[eur]))
      mapa <- rbind(mapa, sf::st_sf(iso3 = paste0(iso, "_ultramar"),
                                    geometry = suppressMessages(sf::st_union(partes[!eur]))))
    }
  }
  mapa <- mapa |> filter(.data$iso3 != "ATA")
  mapa <- suppressMessages(mapa |> group_by(.data$iso3) |> summarise(.groups = "drop"))
  mapa <- suppressWarnings(sf::st_transform(mapa, "+proj=robin"))
  mapa <- suppressWarnings(sf::st_simplify(mapa, preserveTopology = TRUE, dTolerance = 8000))
  mapa <- sf::st_make_valid(mapa)
  bb <- sf::st_bbox(mapa)
  ancho_m <- bb[["xmax"]] - bb[["xmin"]]
  norm <- function(g) (g - c(bb[["xmin"]], bb[["ymin"]])) * (1 / ancho_m)
  geo <- norm(sf::st_geometry(mapa))
  sf::st_crs(geo) <- NA
  pts <- sf::st_as_sf(puntos, coords = c("lon", "lat"), crs = 4326) |> sf::st_transform("+proj=robin")
  pts_xy <- sf::st_coordinates(pts)
  proyectar <- function(lon, lat) {
    xy <- sf::st_coordinates(sf::st_transform(sf::st_as_sf(data.frame(lon = lon, lat = lat),
                                                           coords = c("lon", "lat"), crs = 4326), "+proj=robin"))
    data.frame(u = (xy[, 1] - bb[["xmin"]]) / ancho_m, v = (xy[, 2] - bb[["ymin"]]) / ancho_m)
  }
  list(
    geo = sf::st_sf(iso3 = mapa$iso3, geometry = geo), proyectar = proyectar,
    aspecto = (bb[["ymax"]] - bb[["ymin"]]) / ancho_m,          # alto / ancho
    puntos = tibble(iso3 = puntos$iso3, u = (pts_xy[, 1] - bb[["xmin"]]) / ancho_m,
                    v = (pts_xy[, 2] - bb[["ymin"]]) / ancho_m),
    area = area
  )
}

#' Lleva el mapa normalizado a px (x0, y0 = esquina inferior izquierda; ancho en px) y
#' calcula el rayado (líneas a 45° cada `paso` px) de los países inestables y de los < 1 M.
mapa_a_px <- function(M, x0, y0, ancho, paso, d) {
  s2_antes <- sf::sf_use_s2()
  suppressMessages(sf::sf_use_s2(FALSE))
  on.exit(suppressMessages(sf::sf_use_s2(s2_antes)), add = TRUE)
  g <- sf::st_geometry(M$geo) * ancho + c(x0, y0)
  sf::st_crs(g) <- NA
  geo <- sf::st_sf(iso3 = M$geo$iso3, geometry = g)
  alto <- ancho * M$aspecto
  # polígonos → data.frame para geom_polygon (pieza = polígono, anillo = agujeros)
  # (con tipos mezclados hay que pasar antes por MULTIPOLYGON; si no, st_cast solo
  #  conserva el primer polígono de cada país)
  pol <- suppressWarnings(sf::st_cast(sf::st_cast(geo, "MULTIPOLYGON"), "POLYGON"))
  pol$area_px <- as.numeric(sf::st_area(pol))
  pol <- pol[pol$area_px > 0.15, ]
  cc <- sf::st_coordinates(pol)
  df <- data.frame(x = cc[, "X"], y = cc[, "Y"], anillo = cc[, "L1"], pieza = cc[, "L2"],
                   iso3 = pol$iso3[cc[, "L2"]])
  # clases del mapa
  clase <- ifelse(geo$iso3 %in% names(d$grupo_de), "grupo", "fuera")
  inest <- geo$iso3 %in% d$inestables
  # rayado: líneas a 45° que cubren el rectángulo del mapa, recortadas por cada polígono
  desde <- seq(-alto, ancho, by = paso)
  lineas <- sf::st_sfc(lapply(desde, function(c0) {
    sf::st_linestring(rbind(c(x0 + c0, y0), c(x0 + c0 + alto, y0 + alto)))
  }))
  lineas <- sf::st_sf(id = seq_along(lineas), geometry = lineas)
  # inestables pequeños (ARM, KOR, GTM): anillo discontinuo centrado en su punto de
  # etiqueta, porque a este tamaño su rayado no se ve (la leyenda dice "ringed if small")
  area_de <- setNames(M$area$area_km2, M$area$iso3)
  peq_inest <- d$inestables[!is.na(area_de[d$inestables]) & area_de[d$inestables] < AREA_PUNTO_RAYADO]
  pc <- M$puntos[match(peq_inest, M$puntos$iso3), ]
  radio <- RADIO_PUNTO_RAYADO * ancho / 456
  circ <- sf::st_sf(iso3 = peq_inest, geometry = sf::st_sfc(lapply(seq_along(peq_inest), function(i) {
    sf::st_buffer(sf::st_point(c(x0 + pc$u[i] * ancho, y0 + pc$v[i] * ancho)), radio, nQuadSegs = 12)
  })))
  cc_circ <- sf::st_coordinates(circ)
  df_circ <- data.frame(x = cc_circ[, "X"], y = cc_circ[, "Y"], pieza = cc_circ[, "L2"],
                        iso3 = circ$iso3[cc_circ[, "L2"]])
  raya_de <- geo[clase == "fuera" | inest, ]
  rayas <- suppressWarnings(sf::st_intersection(lineas, raya_de))
  rayas <- rayas[!sf::st_is_empty(rayas), ]
  rayas <- suppressWarnings(sf::st_cast(sf::st_cast(rayas, "MULTILINESTRING"), "LINESTRING"))
  rc <- sf::st_coordinates(rayas)
  df_rayas <- data.frame(x = rc[, "X"], y = rc[, "Y"], tramo = rc[, "L1"],
                         iso3 = rayas$iso3[rc[, "L1"]])
  # países ≥ 1 M diminutos: un punto en su punto de etiqueta
  peq <- M$area |> filter(.data$iso3 %in% names(d$grupo_de), .data$area_km2 < 15000) |> pull("iso3")
  pts <- M$puntos |> mutate(x = x0 + .data$u * ancho, y = y0 + .data$v * ancho)
  # posiciones de las etiquetas ISO3 de los países que nombra la voz (lon/lat elegidos a
  # mano para que no se pisen; ver ETIQUETAS_MAPA)
  et <- do.call(rbind, lapply(names(ETIQUETAS_MAPA), function(s) {
    e <- ETIQUETAS_MAPA[[s]]
    uv <- M$proyectar(e$lon, e$lat)
    # ancla de la línea guía: punto de etiqueta de Natural Earth, salvo que se fije otro
    ax <- pts$x[match(e$iso, pts$iso3)]; ay <- pts$y[match(e$iso, pts$iso3)]
    if (!is.null(e$ancla_lon)) {
      fijo <- !is.na(e$ancla_lon)
      if (any(fijo)) {
        ua <- M$proyectar(e$ancla_lon[fijo], e$ancla_lat[fijo])
        ax[fijo] <- x0 + ua$u * ancho; ay[fijo] <- y0 + ua$v * ancho
      }
    }
    data.frame(set = s, iso3 = e$iso, x = x0 + uv$u * ancho, y = y0 + uv$v * ancho, hj = e$hj, guia = e$guia,
               ax = ax, ay = ay)
  }))
  list(df = df, rayas = df_rayas, puntos = pts |> filter(.data$iso3 %in% peq), circ = df_circ,
       etiquetas = pts, etiquetas_voz = et, x0 = x0, y0 = y0, ancho = ancho, alto = alto,
       geo = geo)
}

#' Capas del mapa para un estado: color por grupo (0..1), foco por grupo (0..1),
#' rayado (0..1) y contorno de los países nombrados.
capas_mapa <- function(g, P, d, color, foco, rayado, contorno = character(0), a_contorno = 0,
                       grosor_borde = 0.12, destacar = character(0), a_destacar = 0) {
  # Atenuación hacia blanco (0..1) de cualquier lista de ISO3, con UNA sola regla para
  # polígonos, puntos de los diminutos, rayado y anillos: (1 − foco del grupo) × 0,75 y,
  # cuando la voz nombra países, ATENUAR_RESTO para el resto de su grupo. (Revisión r2:
  # los puntos solo usaban el foco, así que en b4/b5/b7 PRI, SGP, HKG, CYP · MUS, JAM,
  # LBN, TTO · GMB, PSE quedaban a color pleno junto a los países nombrados.)
  blanco_de <- function(iso) {
    k <- match(d$grupo_de[iso], GRUPOS)
    kk <- ifelse(is.na(k), 1L, k)
    pb <- ifelse(is.na(k), 0, (1 - foco[kk]) * 0.75)
    # los países que nombra la voz quedan a color pleno; el resto de su grupo se aclara
    # (poco en los grupos oscuros, casi hasta el fondo en los claros: ATENUAR_RESTO)
    if (a_destacar > 0.001 && length(destacar) > 0) {
      gd <- unique(d$grupo_de[destacar])
      otros <- !is.na(k) & d$grupo_de[iso] %in% gd & !iso %in% destacar
      pb[otros] <- pb[otros] + unname(ATENUAR_RESTO[kk[otros]]) * a_destacar
    }
    unname(pmin(1, pb))
  }
  # relleno por país (no por vértice): mezcla gris → color del grupo y atenuación hacia blanco
  isos <- unique(P$df$iso3)
  k <- match(d$grupo_de[isos], GRUPOS)
  kk <- ifelse(is.na(k), 1L, k)
  col_lleno <- ifelse(is.na(k), COL_BASE_MAPA, unname(COL_GRUPO[kk]))
  p_color <- ifelse(is.na(k), 1, color[kk])
  p_blanco <- blanco_de(isos)
  relleno <- setNames(hacia_blanco(mezclar(COL_BASE_MAPA, col_lleno, p_color), p_blanco), isos)
  P$df$relleno <- relleno[P$df$iso3]
  g <- g + geom_polygon(data = P$df, aes(x = .data$x, y = .data$y, group = .data$pieza,
                                         subgroup = .data$anillo, fill = .data$relleno),
                        colour = "white", linewidth = grosor_borde)
  # puntos de los ≥ 1 M diminutos: misma atenuación que su polígono (blanco_de, no solo
  # el foco del grupo; muchos ni tienen polígono visible a este tamaño)
  if (nrow(P$puntos) > 0) {
    kp <- match(d$grupo_de[P$puntos$iso3], GRUPOS)
    cp <- hacia_blanco(mezclar(COL_BASE_MAPA, unname(COL_GRUPO[kp]), color[kp]),
                       blanco_de(P$puntos$iso3))
    g <- g + annotate("point", x = P$puntos$x, y = P$puntos$y, size = 1.25, shape = 21,
                      fill = cp, colour = "white", stroke = 0.25)
  }
  # rayado: blanco (u oscuro del grupo, si el color es claro) sobre los inestables, que se
  # aclara con su país; gris sobre los < 1 M
  if (rayado > 0.001 && nrow(P$rayas) > 0) {
    kr <- match(d$grupo_de[P$rayas$iso3], GRUPOS)
    krr <- ifelse(is.na(kr), 1L, kr)
    pb_r <- blanco_de(P$rayas$iso3)
    col_r <- ifelse(is.na(kr), COL_RAYA_GRIS, hacia_blanco(unname(COL_RAYA_GRUPO[krr]), pb_r))
    a_r <- rayado * ifelse(is.na(kr), 1, pmin(1, color[krr]))
    P$rayas$col <- col_r
    P$rayas$a <- a_r
    g <- g + geom_path(data = P$rayas, aes(x = .data$x, y = .data$y, group = .data$tramo,
                                          colour = .data$col, alpha = .data$a),
                       linewidth = 0.42, lineend = "butt")
  }
  # anillo discontinuo (≈ 1 px) de los inestables pequeños; aparece con el rayado y se
  # aclara con su país cuando la voz no lo nombra
  if (rayado > 0.001 && nrow(P$circ) > 0) {
    pb_c <- blanco_de(P$circ$iso3)
    P$circ$borde <- hacia_blanco(rep("#3A3A3A", length(pb_c)), 0.8 * pb_c)
    g <- g + geom_polygon(data = P$circ, aes(x = .data$x, y = .data$y, group = .data$pieza,
                                             colour = .data$borde),
                          fill = NA, linewidth = 0.42, linetype = "22", alpha = rayado)
  }
  # contorno de los países que nombra la voz
  if (a_contorno > 0.001 && length(contorno) > 0) {
    dc <- P$df[P$df$iso3 %in% contorno, ]
    g <- g + geom_polygon(data = dc, aes(x = .data$x, y = .data$y, group = .data$pieza,
                                         subgroup = .data$anillo),
                          fill = NA, colour = COL_TINTA, linewidth = 0.55, alpha = a_contorno)
  }
  g
}

# =============================================================================
# 5. fig10 — mapa de grupos + pequeños múltiplos (build 1)
# =============================================================================
#
# Qué muestra: izquierda, mapa Robinson de los 161 países ≥ 1 M coloreados por su camino
# de 1950–2023 (k-means k = 4; Tol: Early #332288 · Fast #117733 · Recent #DDCC77 ·
# Migration-led #88CCEE), con rayado en los 7 países inestables (se quedan en su grupo en
# < 80 % de 500 re-runs) y en los < 1 M (gris, sin grupo). Derecha, 4 columnas (una por
# grupo) × 2 filas (children per woman; median age): mediana del grupo (línea gruesa) +
# banda P10–P90 (BANDA_TXT: "middle 80 % of the group’s countries"), en color hasta 2023 y en gris (UN medium
# projection) de 2024 a 2050, línea fina = país medoide ("most typical country").
# Debajo, una línea de "hechos" que cambia con la voz y termina en la leyenda de lectura.
#
# Animación (≈ 28 s; bloques b1–b7 del paso s4.b1):
#   b1 "Question three."                  → aparecen el mapa gris y los marcos
#   b2 "…three stretches of one road,"    → se tiñen Early, Fast y Recent en el mapa y sus
#      bandas/medianas se dibujan de 1950 a 2050 (gris tras 2023); aparece el rayado
#   b3 "plus a migration-led group, mostly Gulf states." → se tiñe Migration-led, se
#      atenúa el resto, contorno de sus 7 países y rótulo "Gulf"; hecho: 5 of 7
#   b4 Early movers (USA, RUS, JPN)       → foco Early; contorno + ISO3; hecho: llegadas netas
#   b5 Fast movers (IND, CHN, IDN)        → foco Fast; guías de edad mediana 30 y 40; hecho
#   b6 Early movers (comparación)         → foco Fast + Early; hecho con los dos valores y
#      sus intervalos, que se solapan: "about as fast or faster" (no una diferencia)
#   b7 Recent movers (PAK, NGA, ETH)      → foco Recent; hecho: mortalidad infantil 2023
#   final: todo a opacidad completa; la línea de hechos pasa a la leyenda de lectura (= póster).

textos_fig10 <- function(d) {
  g50 <- tabla_grupo("growth_2024_2050_by_group")
  perfil <- tabla_grupo("cluster_profile")
  q5 <- setNames(fmt_cifra(round(perfil$q5_2023), "0"), GRUPOS)
  gulf <- cifra("n_gulf_migration_led"); n_ml <- cifra("n_gulf_migration_led", "n")
  if (n_ml != d$tam[["Migration-led"]]) stop("n_gulf_migration_led: n distinto del tamaño del grupo.", call. = FALSE)
  # corrector-final 2026-10-25 (QA-viz V1, CRÍTICA): la revisión WPP2024 del Golfo (UAE +12 %,
  # Saudi Arabia −10 %) es una cifra externa sin clave verificada (are_revision_pct verified: false;
  # sau_revision_pct no existe) → se omite; nota sin cifras
  nota_golfo <- "Net migration is the least-measured component: read these paths as UN estimates"
  # (QA-viz V21) el año del último censo de Nigeria sale de un sens_note sin verificar → sin año
  nota_nga <- "Nigeria: no recent census"
  # Años de edad mediana 30 → 40 SIEMPRE en años enteros (fmt "0"): con un IC de 29 a 42,5
  # un decimal es precisión falsa, y la voz dice "about 37" (revisión r2). El redondeo es
  # el de formatear_cifra (mitad hacia afuera: 36,5 → 37, 42,5 → 43), igual que numbers.js.
  FMT_ANOS <- "0"
  for (cl in c("yrs_medage30_40_early", "yrs_medage30_40_recent")) {
    if (!identical(cifra(cl, "fmt"), FMT_ANOS)) {
      anotar_problema(sprintf(paste0("%s trae fmt '%s' en numbers_q3.json: el HTML mostraría %s y la figura %s ",
                                     "(fmt '0'). Pedir al agente Q3 fmt '0' y ROUND_HALF_UP en slides/script/fill_numbers.py ",
                                     "(Python redondea 36.5 → '36')."),
                              cl, cifra(cl, "fmt"), fmt_clave(cl), fmt_clave(cl, FMT_ANOS)))
    }
  }
  # años de edad mediana 30 → 40 y su intervalo del 95 % (bootstrap por bloques de
  # subregión): los dos se solapan casi del todo, así que la pantalla no puede presentar
  # 32 frente a 37 como una diferencia establecida ("about as fast or faster")
  a_fast <- fmt_clave("yrs_medage30_40_recent", FMT_ANOS)
  a_early <- fmt_clave("yrs_medage30_40_early", FMT_ANOS)
  r_fast <- fmt_rango("yrs_medage30_40_recent", FMT_ANOS)
  r_early <- fmt_rango("yrs_medage30_40_early", FMT_ANOS)
  if (cifra("yrs_medage30_40_early", "ci_low") <= cifra("yrs_medage30_40_recent", "ci_high")) {
    nota_rangos <- "ranges overlap: about as fast or faster"
  } else {
    nota_rangos <- "ranges do not overlap: faster"
  }
  for (cl in c("yrs_medage30_40_early", "yrs_medage30_40_recent")) {
    say <- cifra(cl, "say"); a <- fmt_clave(cl, FMT_ANOS)
    if (!is.null(say) && !grepl(paste0("\\b", a, "\\b"), say)) {
      anotar_problema(sprintf("%s: la pantalla dice '%s' y la voz '%s'; deben decir lo mismo.", cl, a, say))
    }
  }
  def_fast <- cifra("yrs_medage30_40_recent", "def")
  m <- regmatches(def_fast, regexec("([0-9]+) of ([0-9]+) countries reach 30 only after 2023", def_fast))[[1]]
  nota_proy <- if (length(m) == 3) {
    sprintf("mostly UN medium projection: %s of %s Fast movers reach a median age of 30 only after 2023", m[2], m[3])
  } else {
    anotar_problema("yrs_medage30_40_recent: el texto 'def' ya no trae 'N of M countries reach 30 only after 2023'.")
    "mostly UN medium projection"
  }
  nota_proy_corta <- if (length(m) == 3) {
    sprintf("mostly projected: %s of %s Fast movers reach 30 only after 2023", m[2], m[3])
  } else "mostly UN medium projection"
  medoides <- paste(d$medoide$ISO3_code, collapse = " · ")
  list(
    # b2: la segunda línea explica la banda gris desde que aparece (no solo en el póster);
    # el texto de la banda es el mismo en todos los estados y en la versión impresa
    tramos   = c("Three stretches of one road: Early → Fast → Recent movers",
                 paste(BANDA_TXT, "grey after 2023 = UN medium projection", sep = " · ")),
    golfo    = c(sprintf("Migration-led: %d of %d countries are Gulf states", gulf, n_ml), nota_golfo),
    # (QA-viz V2) la línea del 75 % (growth_2000_2023_by_group, verified: false) sale; titular = la
    # línea ya verificada de growth_2024_2050_by_group
    early    = c("Early movers, UN medium projection 2024–50:",
                 sprintf("births − deaths %s %%, net arrivals %s %% of the population (a scenario)",
                         fmt_cifra(g50$natural_pct[1], "+0.0"), fmt_cifra(g50$migration_pct[1], "+0.0"))),
    fast     = c(sprintf("Median age 30 → 40: Fast movers in %s years (95 %% range %s)", a_fast, r_fast), nota_proy),
    fast_early = c(sprintf("Median age 30 → 40: Fast movers %s years (95 %% range %s) · Early movers %s years (%s)",
                           a_fast, r_fast, a_early, r_early),
                   paste(nota_rangos, nota_proy_corta, sep = " · ")),
    recent   = c(sprintf("Child deaths before age 5, 2023 (median per 1,000 births): Recent movers %s · Fast %s · Early %s",
                         q5[["Recent movers"]], q5[["Fast movers"]], q5[["Early movers"]]),
                 paste0(nota_nga, " — its numbers are UN estimates")),
    lectura  = c(paste(BANDA_TXT, "thick = median", "grey = UN medium projection after 2023", sep = " · "),
                 sprintf("thin = most typical country (%s) · dotted = median age 30 and 40 · %d countries ≥ 1 M · exploratory, not causal",
                         medoides, sum(d$tam)))
  )
}

estado_fig10 <- function(t, b, dur = DURACION_FIG10) {
  p <- function(t0, d = 0.5, ease = "cubic-in-out") prog(t, t0, d, ease)
  # vuelta final a opacidad plena (0,6 s) + leyenda de lectura: empieza 0,9 s antes del fin
  # del paso s4.b1, para que el MP4 termine dentro del paso y no compita con fig11 (b2)
  # corrector-final: el MP4 dura exactamente `dur` (= paso − 0,3 s); la fase final empieza 0,9 s antes
  fin <- dur - 0.9
  if (b[7] + 1.2 > fin) anotar_problema(sprintf("fig10: la fase Recent (%.1f s) deja < 1,2 s antes del final (%.1f s).", b[7], fin))
  aparece <- c(b[2] + 0.2, b[2] + 0.9, b[2] + 1.6, b[3] + 0.2)
  dur_barrido <- c(2.4, 2.4, 2.4, 1.8)
  color <- vapply(1:4, function(k) p(aparece[k], 0.6), numeric(1))
  anio <- vapply(1:4, function(k) {
    if (!is.finite(t)) return(2050)
    if (t < aparece[k]) return(NA_real_)
    1950 + 100 * min(1, (t - aparece[k]) / dur_barrido[k])
  }, numeric(1))
  claves_t <- c(0, b[3], b[4], b[5], b[6], b[7], fin)
  claves_v <- rbind(c(1, 1, 1, 1), c(DIM, DIM, DIM, 1), c(1, DIM, DIM, DIM), c(DIM, 1, DIM, DIM),
                    c(1, 1, DIM, DIM), c(DIM, DIM, 1, DIM), c(1, 1, 1, 1))
  foco <- por_claves(t, claves_t, claves_v, 0.6)
  # hechos: (instante, clave del texto); fundido secuencial (sale el viejo, entra el nuevo)
  hechos_t <- c(b[2] + 1.2, b[3] + 0.4, b[4] + 0.4, b[5] + 0.4, b[6] + 0.3, b[7] + 0.25, fin)
  hechos_k <- c("tramos", "golfo", "early", "fast", "fast_early", "recent", "lectura")
  hecho <- list(k_nuevo = NA_character_, a_nuevo = 0, k_viejo = NA_character_, a_viejo = 0)
  if (!is.finite(t)) {
    hecho <- list(k_nuevo = "lectura", a_nuevo = 1, k_viejo = NA_character_, a_viejo = 0)
  } else if (t >= hechos_t[1]) {
    k <- max(which(hechos_t <= t))
    q <- min(1, (t - hechos_t[k]) / 0.6)
    hecho <- list(k_nuevo = hechos_k[k], a_nuevo = max(0, 2 * q - 1),
                  k_viejo = if (k > 1) hechos_k[k - 1] else NA_character_, a_viejo = if (k > 1) max(0, 1 - 2 * q) else 0)
  }
  list(
    marco = p(0, 0.5), color = color, anio = anio, foco = foco,
    rayado = p(b[2] + 2.4, 0.6),
    golfo = p(b[3] + 0.5, 0.4) * (1 - p(b[4], 0.4)),
    # etiqueta ISO3 (con su línea guía) y contorno: al salir, el contorno se va 0,15 s
    # antes que la etiqueta, para que nunca se dibuje sobre una etiqueta a medio fundir
    lab_early = p(b[4] + 0.4, 0.4) * (1 - p(b[5], 0.4)),
    lab_fast = p(b[5] + 0.4, 0.4) * (1 - p(b[6], 0.4)),
    lab_recent = p(b[7] + 0.4, 0.4) * (1 - p(fin, 0.4)),
    cont_early = p(b[4] + 0.4, 0.4) * (1 - p(b[5] - 0.15, 0.35)),
    cont_fast = p(b[5] + 0.4, 0.4) * (1 - p(b[6] - 0.15, 0.35)),
    cont_recent = p(b[7] + 0.4, 0.4) * (1 - p(fin - 0.15, 0.35)),
    guias = p(b[5] + 0.6, 0.5),
    hecho = hecho,
    duracion = fin + 0.9
  )
}

#' Geometría de fig10 por versión (px de ranura; y crece hacia arriba).
geom_fig10 <- function(version, M, d) {
  if (version == "video") {
    W <- RANURAS$fig10[["w"]]; H <- RANURAS$fig10[["h"]]
    ancho_mapa <- 456
    alto_mapa <- ancho_mapa * M$aspecto
    y0_mapa <- 340 - alto_mapa
    list(W = W, H = H, imp = FALSE,
         mapa = mapa_a_px(M, 0, y0_mapa, ancho_mapa, paso = 4.2, d = d),
         y_leyenda_mapa = y0_mapa - c(16, 36, 56),
         gutter_x = 502, col_x0 = 508 + (0:3) * 146, col_w = 138,
         # la fila de edad mediana es más alta (96 px) que la de hijos por mujer (68 px):
         # así sus 5 marcas regulares (10…50) no quedan apiladas
         tira = list(TFR = c(226, 294), MedianAgePop = c(100, 196)),
         y_cab = 332, y_tit = c(TFR = 308, MedianAgePop = 211), y_anio = 87,
         y_hecho = c(44, 18))
  } else if (version == "small") {
    # Variante para los builds 3–5 (ranura 1092×235): mapa, píldoras y líneas, SIN línea
    # de hechos, leyenda del rayado ni nota del mapa (ya narrados en b1–b2). Misma
    # escala de columnas que el póster; la fila de edad mediana pasa a 3 marcas.
    # corrector-final (QA-viz V5–V6): ranura real 1021×220 y leyenda del rayado bajo el mapa
    # (línea 1: inestables y < 1 M; línea 2: nota de Natural Earth) → mapa algo más pequeño
    W <- RANURAS$fig10_small[["w"]]; H <- RANURAS$fig10_small[["h"]]
    alto_mapa <- H - 46
    ancho_mapa <- min(456, alto_mapa / M$aspecto)
    alto_mapa <- ancho_mapa * M$aspecto
    y0_mapa <- H - alto_mapa
    gx <- ancho_mapa + 46
    paso_col <- (W - (gx + 6) - 2) / 4
    list(W = W, H = H, imp = FALSE, solo_grafica = TRUE,
         mapa = mapa_a_px(M, 0, y0_mapa, ancho_mapa, paso = 4.2, d = d),
         y_leyenda_mapa = c(29, 9),
         gutter_x = gx, col_x0 = gx + 6 + (0:3) * paso_col, col_w = paso_col - 4,
         tira = list(TFR = c(124, 172), MedianAgePop = c(22, 94)),
         marcas = list(TFR = c(0, 4, 8), MedianAgePop = c(10, 30, 50)),
         y_cab = 207, y_tit = c(TFR = 184, MedianAgePop = 106), y_anio = 9,
         y_hecho = c(NA, NA))
  } else {
    W <- RANURAS$fig10_print[["w"]]; H <- RANURAS$fig10_print[["h"]]
    alto_mapa <- H - 42                     # deja 2 líneas de 20 px debajo
    ancho_mapa <- min(304, alto_mapa / M$aspecto)
    alto_mapa <- ancho_mapa * M$aspecto
    list(W = W, H = H, imp = TRUE,
         mapa = mapa_a_px(M, 0, H - alto_mapa, ancho_mapa, paso = 3.4, d = d),
         y_leyenda_mapa = c(31, 11))
  }
}

RANGO_Y <- list(TFR = c(0, 8), MedianAgePop = c(10, 55))
MARCAS_Y <- list(TFR = c(0, 4, 8), MedianAgePop = c(10, 20, 30, 40, 50))

# --- Lote de capas -----------------------------------------------------------------
# Acumula segmentos, cintas, trazos y textos en data.frames y los dibuja con 4 capas
# (geom_segment / geom_ribbon / geom_path / geom_text) en vez de cientos de annotate():
# ggplot_build tardaba ~4 s por fotograma con una capa por elemento; así, < 1 s.
lote_nuevo <- function() list(seg = list(), rib = list(), pth = list(), txt = list())
lote_seg <- function(L, x, xend, y, yend, colour, linewidth, linetype = "solid", alpha = 1) {
  if (all(alpha <= 0.001)) return(L)
  L$seg[[length(L$seg) + 1]] <- data.frame(x = x, xend = xend, y = y, yend = yend, colour = colour,
                                           linewidth = linewidth, linetype = linetype, alpha = alpha,
                                           stringsAsFactors = FALSE)
  L
}
lote_rib <- function(L, x, ymin, ymax, fill, alpha) {
  if (alpha <= 0.001 || length(x) < 2) return(L)
  L$rib[[length(L$rib) + 1]] <- data.frame(x = x, ymin = ymin, ymax = ymax, fill = fill, alpha = alpha,
                                           id = length(L$rib) + 1, stringsAsFactors = FALSE)
  L
}
lote_pth <- function(L, x, y, colour, linewidth, alpha, linetype = "solid") {
  if (alpha <= 0.001 || length(x) < 2) return(L)
  L$pth[[length(L$pth) + 1]] <- data.frame(x = x, y = y, colour = colour, linewidth = linewidth,
                                           alpha = alpha, linetype = linetype, id = length(L$pth) + 1,
                                           stringsAsFactors = FALSE)
  L
}
lote_txt <- function(L, x, y, label, px, colour = COL_TEXTO, hjust = 0, negrita = FALSE, alpha = 1) {
  if (all(alpha <= 0.001)) return(L)
  L$txt[[length(L$txt) + 1]] <- data.frame(x = x, y = y, label = label, size = px / .pt, colour = colour,
                                           hjust = hjust, fontface = ifelse(negrita, "bold", "plain"),
                                           alpha = alpha, stringsAsFactors = FALSE)
  L
}
lote_capas <- function(g, L, que = c("seg", "rib", "pth", "txt")) {
  if ("seg" %in% que && length(L$seg) > 0) {
    g <- g + geom_segment(data = do.call(rbind, L$seg),
                          aes(x = .data$x, y = .data$y, xend = .data$xend, yend = .data$yend,
                              colour = .data$colour, linewidth = .data$linewidth,
                              linetype = .data$linetype, alpha = .data$alpha))
  }
  if ("rib" %in% que && length(L$rib) > 0) {
    g <- g + geom_ribbon(data = do.call(rbind, L$rib),
                         aes(x = .data$x, ymin = .data$ymin, ymax = .data$ymax, group = .data$id,
                             fill = .data$fill, alpha = .data$alpha), colour = NA)
  }
  if ("pth" %in% que && length(L$pth) > 0) {
    g <- g + geom_path(data = do.call(rbind, L$pth),
                       aes(x = .data$x, y = .data$y, group = .data$id, colour = .data$colour,
                           linewidth = .data$linewidth, alpha = .data$alpha, linetype = .data$linetype),
                       lineend = "round")
  }
  if ("txt" %in% que && length(L$txt) > 0) {
    g <- g + geom_text(data = do.call(rbind, L$txt),
                       aes(x = .data$x, y = .data$y, label = .data$label, size = .data$size,
                           colour = .data$colour, hjust = .data$hjust, fontface = .data$fontface,
                           alpha = .data$alpha),
                       family = FUENTE, vjust = 0.5, lineheight = 0.95)
  }
  g
}

#' Series ya separadas por grupo y variable (estimación ≤ 2023 / proyección ≥ 2024;
#' mediana, P10, P90 del grupo y serie del medoide), para no filtrar en cada fotograma.
preparar_series <- function(d) {
  out <- list()
  for (gr in GRUPOS) for (v in c("TFR", "MedianAgePop")) {
    bd <- as.data.frame(d$bandas[d$bandas$grupo == gr & d$bandas$variable == v, c("Time", "mediana", "p10", "p90")])
    bd <- bd[order(bd$Time), ]
    sm <- as.data.frame(d$serie_med[d$serie_med$grupo == gr & d$serie_med$variable == v, c("Time", "valor")])
    sm <- sm[order(sm$Time), ]
    out[[gr]][[v]] <- list(est = bd[bd$Time <= ANIO_FIN_ESTIMACION, ], proy = bd[bd$Time >= ANIO_INICIO_PROYECCION, ],
                           med_e = sm[sm$Time <= ANIO_FIN_ESTIMACION, ], med_p = sm[sm$Time >= ANIO_INICIO_PROYECCION, ])
  }
  out
}

#' Recorta una serie hasta `anio_max`, con un punto interpolado al final (trazo continuo
#' mientras se dibuja de 1950 a 2050).
recortar_serie <- function(df, cols, anio_max) {
  dd <- df[df$Time <= anio_max, ]
  if (nrow(dd) == 0) return(dd)
  sig <- df[df$Time > anio_max, ]
  if (nrow(sig) > 0 && max(dd$Time) < anio_max) {
    f <- (anio_max - max(dd$Time)) / (sig$Time[1] - max(dd$Time))
    extra <- dd[nrow(dd), ]
    for (cc in cols) extra[[cc]] <- dd[[cc]][nrow(dd)] + f * (sig[[cc]][1] - dd[[cc]][nrow(dd)])
    extra$Time <- anio_max
    dd <- rbind(dd, extra)
  }
  dd
}

#' Banda + mediana (+ medoide) de un grupo en un rectángulo [x0,x1]×[y0,y1] (al lote).
#' Color hasta 2023; gris (banda) y gris punteado (mediana) para la proyección.
serie_lote <- function(L, S, grupo, variable, x0, x1, y0, y1, anio_max, a, lw_med = 1.35,
                       medoide = TRUE, lw_medoide = 0.5) {
  if (is.na(anio_max) || a <= 0.001) return(L)
  rx <- c(1950, 2050); ry <- RANGO_Y[[variable]]
  sx <- function(v) x0 + (v - rx[1]) / diff(rx) * (x1 - x0)
  sy <- function(v) y0 + (pmin(pmax(v, ry[1]), ry[2]) - ry[1]) / diff(ry) * (y1 - y0)
  s <- S[[grupo]][[variable]]
  est <- recortar_serie(s$est, c("mediana", "p10", "p90"), anio_max)
  proy <- recortar_serie(s$proy, c("mediana", "p10", "p90"), anio_max)
  L <- lote_rib(L, sx(proy$Time), sy(proy$p10), sy(proy$p90), COL_PROY_BANDA, a)
  L <- lote_rib(L, sx(est$Time), sy(est$p10), sy(est$p90), COL_GRUPO[[grupo]], ALFA_BANDA[[grupo]] * a)
  if (medoide) {
    me <- recortar_serie(s$med_e, "valor", anio_max)
    mp <- recortar_serie(s$med_p, "valor", anio_max)
    L <- lote_pth(L, sx(me$Time), sy(me$valor), "#2A2A2A", lw_medoide, 0.85 * a)
    L <- lote_pth(L, sx(mp$Time), sy(mp$valor), "#8A8A8A", lw_medoide, 0.85 * a)
  }
  L <- lote_pth(L, sx(proy$Time), sy(proy$mediana), COL_PROY_LINEA, lw_med * 0.85, a, "22")
  L <- lote_pth(L, sx(est$Time), sy(est$mediana), COL_GRUPO_LINEA[[grupo]], lw_med, a)
  L
}

#' ISO3 de los países nombrados, con posición de etiqueta ajustada a mano (lon/lat del
#' ancla de la caja; hjust 0 = la caja empieza en el ancla). Los países medianos (IND, PAK,
#' NGA, ETH) llevan la caja fuera de su territorio, en el mar o sobre un vecino de otro
#' grupo, con una línea guía desde su punto de etiqueta: si la caja va encima, los tapa
#' (revisión: b5 "IND," y b7 sin ningún píxel #DDCC77 visible). USA, RUS y CHN son tan
#' grandes que la caja centrada deja ver el país alrededor.
ETIQUETAS_MAPA <- list(
  early  = list(iso = c("USA", "RUS", "JPN"), lon = c(-100, 98, 147), lat = c(40, 62, 37), hj = c(0.5, 0.5, 0),
                guia = c(FALSE, FALSE, TRUE)),
  # IDN: la caja va al este, sobre el mar al norte de Nueva Guinea (revisión r2: en
  # lon 118, lat −13 su halo tapaba la costa norte de Australia), con la guía desde
  # Sulawesi (el punto de etiqueta de Natural Earth está en Sumatra, demasiado lejos)
  fast   = list(iso = c("IND", "CHN", "IDN"), lon = c(77, 107, 130), lat = c(-7, 37, 8.5), hj = c(0.5, 0.5, 0),
                guia = c(TRUE, FALSE, TRUE), ancla_lon = c(NA, NA, 120.4), ancla_lat = c(NA, NA, -1.9)),
  recent = list(iso = c("PAK", "NGA", "ETH"), lon = c(66, 6, 50.5), lat = c(47, -5, -1), hj = c(0.5, 1, 0),
                guia = c(TRUE, TRUE, TRUE))
)

#' Etiquetas ISO3 de un bloque, con línea guía (0,5 px, COL_TINTA) desde el punto de
#' etiqueta del país hasta el borde de la caja cuando la caja no está sobre el país.
capas_etiquetas_mapa <- function(g, P, set, a) {
  if (a <= 0.001) return(g)
  et <- P$etiquetas_voz[P$etiquetas_voz$set == set, ]
  esc <- P$ancho / 456
  for (i in seq_len(nrow(et))) {
    w <- ancho_txt(et$iso3[i], TAM$iso, TRUE) + 2.4
    h <- TAM$iso * 0.95 + 2.4
    caja <- c(et$x[i] - et$hj[i] * w, et$x[i] + (1 - et$hj[i]) * w, et$y[i] - h / 2, et$y[i] + h / 2)
    cen <- list(x = et$ax[i], y = et$ay[i])
    fx <- min(max(cen$x, caja[1]), caja[2]); fy <- min(max(cen$y, caja[3]), caja[4])
    if (et$guia[i] && sqrt((fx - cen$x)^2 + (fy - cen$y)^2) > 4 * esc) {
      g <- g + annotate("segment", x = cen$x, y = cen$y, xend = fx, yend = fy,
                        colour = COL_TINTA, linewidth = 0.24, alpha = a)
      g <- g + annotate("point", x = cen$x, y = cen$y, colour = COL_TINTA, size = 0.9, alpha = a)
    }
  }
  for (i in seq_len(nrow(et))) {
    g <- g + texto_halo(et$x[i], et$y[i], et$iso3[i], TAM$iso, COL_TINTA, hjust = et$hj[i],
                        negrita = TRUE, alpha = a)
  }
  g
}

dibujar_fig10 <- function(t = Inf, version = c("video", "print", "small"), d = Q3, M = MAPA, G = NULL,
                          b = TIEMPOS_FIG10, tx = TEXTOS_FIG10) {
  version <- match.arg(version)
  if (is.null(G)) G <- switch(version, video = GEOM_FIG10_VIDEO, print = GEOM_FIG10_PRINT,
                              small = GEOM_FIG10_SMALL)
  if (version == "print") return(dibujar_fig10_print(d, G, tx))
  if (version == "small") t <- Inf               # estado final, sin textos de lectura
  solo <- isTRUE(G$solo_grafica)
  e <- estado_fig10(t, b)
  P <- G$mapa
  g <- lienzo(G$W, G$H)

  # --- mapa ---
  contorno <- character(0); a_cont <- 0
  # b3: contorno solo de los 5 del Golfo (CCG); Jordania y Yibuti, coloreados sin contorno
  if (e$golfo > 0.001) { contorno <- d$golfo; a_cont <- e$golfo }
  for (s in c("early", "fast", "recent")) {
    a_s <- e[[paste0("cont_", s)]]
    if (a_s > a_cont) { contorno <- ETIQUETAS_MAPA[[s]]$iso; a_cont <- a_s }
  }
  if (e$marco > 0.001) {
    dest <- if (a_cont > 0.001 && e$golfo < a_cont) contorno else character(0)
    g <- capas_mapa(g, P, d, color = e$color, foco = e$foco, rayado = e$rayado,
                    contorno = contorno, a_contorno = a_cont, destacar = dest, a_destacar = a_cont)
  }
  for (s in c("early", "fast", "recent")) g <- capas_etiquetas_mapa(g, P, s, e[[paste0("lab_", s)]])
  if (e$golfo > 0.001) {
    sau <- P$etiquetas[P$etiquetas$iso3 == "ARE", ]
    xg <- sau$x + 30; yg <- sau$y - 22
    g <- g + annotate("segment", x = sau$x + 3, y = sau$y - 3, xend = xg - 2, yend = yg + 7,
                      colour = COL_TINTA, linewidth = 0.5, alpha = e$golfo)
    g <- g + texto_halo(xg, yg, "Gulf", TAM$iso, COL_TINTA, hjust = 0, negrita = TRUE, alpha = e$golfo)
  }
  # leyenda del rayado y nota del mapa (bajo el mapa). Dos muestras con 8 px hasta el
  # texto (revisión r2): color del grupo con rayas blancas (inestables; casi todos son
  # Fast movers) y gris con rayas grises (< 1 M, sin grupo), como se ven en el mapa
  L <- lote_nuevo()
  if (solo) {
    # variante small (corrector-final, QA-viz V6): leyenda del rayado (inestables y < 1 M) y,
    # en la segunda línea, la nota obligatoria del mapa (ética: límites sin aval de la ONU)
    yl <- G$y_leyenda_mapa
    ley_s <- c("changes group in > 1 in 5 re-runs", "< 1 M")
    x_m2s <- 28 + ancho_txt(ley_s[1], TAM$nota) + 14
    g <- muestra_rayada(g, 2, 20, yl[1] - 7, yl[1] + 7, COL_GRUPO[["Fast movers"]], COL_RAYA_GRUPO[["Fast movers"]], 4.2)
    g <- muestra_rayada(g, x_m2s, x_m2s + 18, yl[1] - 7, yl[1] + 7, COL_BASE_MAPA, COL_RAYA_GRIS, 4.2)
    L <- lote_txt(L, c(26, x_m2s + 24), yl[c(1, 1)], ley_s, TAM$nota, COL_TEXTO_2)
    avisar_ancho(paste(ley_s, collapse = "      "), TAM$nota, G$gutter_x - 30, donde = "fig10s leyenda")
    nota_s <- "Map: Natural Earth; borders not UN-endorsed"
    avisar_ancho(nota_s, TAM$nota, G$gutter_x - 30, donde = "fig10s nota mapa")
    L <- lote_txt(L, 2, yl[2], nota_s, TAM$nota, COL_TEXTO_2)
  } else {
    # línea 1: muestra de inestables + texto; línea 2: "(ringed if small)" bajo ese texto y
    # después la muestra gris de los < 1 M (mismo orden que la versión impresa)
    ley <- c("changes group in more than 1 in 5 re-runs", "(ringed if small)", "< 1 M people (not grouped)")
    x_m2 <- 30 + ancho_txt(ley[2], TAM$nota) + 12
    avisar_ancho(c(ley[1], paste(ley[2], ley[3])), TAM$nota, 478 - 30 - 28, donde = "fig10 leyenda mapa")
    if (e$rayado > 0.001) {
      yl <- G$y_leyenda_mapa
      g <- muestra_rayada(g, 2, 22, yl[1] - 7, yl[1] + 7, COL_GRUPO[["Fast movers"]], COL_RAYA_GRUPO[["Fast movers"]],
                          4.2, e$rayado)
      g <- muestra_rayada(g, x_m2, x_m2 + 20, yl[2] - 7, yl[2] + 7, COL_BASE_MAPA, COL_RAYA_GRIS, 4.2, e$rayado)
      L <- lote_txt(L, c(30, 30, x_m2 + 28), yl[c(1, 2, 2)], ley, TAM$nota, COL_TEXTO_2, alpha = e$rayado)
    }
    nota_ne <- "Map: Natural Earth · boundaries imply no UN endorsement"
    avisar_ancho(nota_ne, TAM$nota, G$gutter_x - 30, donde = "fig10 nota mapa")
    L <- lote_txt(L, 2, G$y_leyenda_mapa[3], nota_ne, TAM$nota, COL_TEXTO_2, alpha = e$marco)
  }

  # --- pequeños múltiplos: 4 columnas (grupos) × 2 filas (TFR, edad mediana) ---
  titulos <- c(TFR = "children per woman", MedianAgePop = "median age (half the people are older)")
  for (v in names(G$tira)) {
    yy <- G$tira[[v]]
    L <- lote_txt(L, G$col_x0[1], G$y_tit[[v]], titulos[[v]], TAM$fila, COL_TEXTO, alpha = e$marco)
    ry <- RANGO_Y[[v]]
    sy <- function(val) yy[1] + (val - ry[1]) / diff(ry) * diff(yy)
    marcas <- if (!is.null(G$marcas)) G$marcas[[v]] else MARCAS_Y[[v]]
    L <- lote_txt(L, G$gutter_x, sy(marcas), as.character(marcas), TAM$eje, COL_TEXTO_2, hjust = 1, alpha = e$marco)
    for (k in 1:4) {
      x0 <- G$col_x0[k]; x1 <- x0 + G$col_w
      sx <- function(a) x0 + (a - 1950) / 100 * G$col_w
      # rejilla, guías de edad mediana 30 y 40, línea 2023/24 y base
      L <- lote_seg(L, x0, x1, sy(marcas), sy(marcas), COL_REJILLA, 0.35, alpha = e$marco)
      if (v == "MedianAgePop") L <- lote_seg(L, x0, x1, sy(c(30, 40)), sy(c(30, 40)), "#5A5A5A", 0.45, "12", e$guias)
      L <- lote_seg(L, sx(2023.5), sx(2023.5), yy[1], yy[2], COL_EJE, 0.4, "22", e$marco)
      L <- lote_seg(L, x0, x1, yy[1], yy[1], COL_EJE, 0.4, alpha = e$marco)
      a_k <- e$color[k] * (0.12 + 0.88 * e$foco[k])
      L <- serie_lote(L, SERIES, GRUPOS[k], v, x0, x1, yy[1], yy[2], e$anio[k], a_k)
    }
  }
  # años solo bajo el primer panel (en fila, "2050 1950 2050 1950" chocaban entre paneles)
  # y "2023" junto a la línea punteada del primer panel, arriba, donde la fila está libre
  x0 <- G$col_x0[1]
  L <- lote_txt(L, c(x0, x0 + G$col_w), G$y_anio, c("1950", "2050"), TAM$eje, COL_TEXTO_2,
                hjust = c(0, 1), alpha = e$marco)
  L <- lote_txt(L, x0 + 73.5 / 100 * G$col_w - 3, G$tira$TFR[2] - 9, "2023", TAM$eje, COL_TEXTO_2,
                hjust = 1, alpha = e$marco)
  g <- lote_capas(g, L, c("seg", "rib", "pth"))
  # cabeceras: píldora del color del grupo con su nombre (la leyenda completa es HTML)
  for (k in 1:4) {
    a_c <- max(0.18, e$color[k]) * (0.30 + 0.70 * e$foco[k]) * e$marco
    x0 <- G$col_x0[k]
    avisar_ancho(GRUPOS[k], TAM$grupo, G$col_w - 2, negrita = TRUE, donde = "fig10 cabecera")
    g <- g + pildora(x0, x0 + G$col_w, G$y_cab - 13, G$y_cab + 13, COL_GRUPO[[k]], alpha = a_c)
    L <- lote_txt(L, x0 + G$col_w / 2, G$y_cab, GRUPOS[k], TAM$grupo, COL_TXT_PILDORA[[k]], hjust = 0.5,
                  negrita = TRUE, alpha = min(1, a_c * 1.3))
  }

  # --- línea de hechos (ancho completo; no va en la variante small) ---
  for (lado in if (solo) character(0) else c("viejo", "nuevo")) {
    kk <- e$hecho[[paste0("k_", lado)]]; aa <- e$hecho[[paste0("a_", lado)]]
    if (is.na(kk) || aa <= 0.001) next
    lineas <- tx[[kk]]
    avisar_ancho(lineas[1], if (kk == "lectura") TAM$nota else TAM$hecho, G$W - 4, negrita = kk != "lectura",
                 donde = paste("fig10 hecho", kk))
    avisar_ancho(lineas[2], TAM$nota, G$W - 4, donde = paste("fig10 hecho 2", kk))
    L <- lote_txt(L, 2, G$y_hecho[1], lineas[1], if (kk == "lectura") TAM$nota else TAM$hecho,
                  if (kk == "lectura") COL_TEXTO_2 else COL_TINTA, negrita = kk != "lectura", alpha = aa)
    if (nzchar(lineas[2])) L <- lote_txt(L, 2, G$y_hecho[2], lineas[2], TAM$nota, COL_TEXTO_2, alpha = aa)
  }
  lote_capas(g, L, "txt")
}

#' Versión impresa (PDF, ranura 969×164): mapa a la izquierda y una fila por grupo con
#' la etiqueta completa del storyboard §5 (nombre, n países, población, 3 banderas + ISO3)
#' y dos mini-series (children per woman; median age), misma escala en todas las filas.
dibujar_fig10_print <- function(d, G, tx) {
  # Tamaños del PDF (storyboard §9: mínimo 20 px, pies 18 px). Revisión r2: números,
  # ISO3 y leyenda del mapa pasan de 18 a 20 px; se añade el universo y sale la nota de
  # Natural Earth (ya está en el pie de ética de la página).
  TP <- list(nombre = 20, meta = 20, iso = 20, ley = 20, col = 20, pie = 18)
  P <- G$mapa
  g <- lienzo(G$W, G$H)
  g <- capas_mapa(g, P, d, color = rep(1, 4), foco = rep(1, 4), rayado = 1, grosor_borde = 0.08)
  # leyenda del rayado: dos muestras (color del grupo + rayas blancas; gris + rayas grises)
  yl <- G$y_leyenda_mapa
  x_txt <- 22                                       # muestra 1–14 + 8 px de aire
  ley1 <- "changes group in > 1 in 5 re-runs"
  ley2 <- c("(ringed if small)", "< 1 M people")
  g <- muestra_rayada(g, 1, 14, yl[1] - 6, yl[1] + 6, COL_GRUPO[["Fast movers"]], COL_RAYA_GRUPO[["Fast movers"]], 3.4)
  g <- g + texto(x_txt, yl[1], ley1, TP$ley, COL_TEXTO_2)
  w2 <- ancho_txt(ley2[1], TP$ley)
  x_m2 <- x_txt + w2 + 10
  g <- g + texto(x_txt, yl[2], ley2[1], TP$ley, COL_TEXTO_2)
  g <- muestra_rayada(g, x_m2, x_m2 + 13, yl[2] - 6, yl[2] + 6, COL_BASE_MAPA, COL_RAYA_GRIS, 3.4)
  g <- g + texto(x_m2 + 13 + 8, yl[2], ley2[2], TP$ley, COL_TEXTO_2)
  X <- list(sw = 320, nombre = 342, meta = 482, flags = 584, paso_flag = 66,
            s1 = c(784, 872), s2 = c(882, 966))
  # corrector-final (QA-slides M6): a 26 px de alto las mini-series no se leen en el PDF → fuera;
  # la tabla de grupos (nombre, n, población, 3 mayores por regla) usa todo el ancho
  MINI <- FALSE
  if (!MINI) X <- modifyList(X, list(meta = 500, flags = 640, paso_flag = 100))
  fin_ley <- max(x_txt + ancho_txt(ley1, TP$ley), x_m2 + 21 + ancho_txt(ley2[2], TP$ley))
  if (fin_ley > X$sw - 2) anotar_problema(sprintf("fig10p: la leyenda del mapa llega a x = %.0f (tabla en %d).", fin_ley, X$sw))

  # --- tabla de grupos ---
  alto_fila <- 26
  filas_y <- alto_fila * (3:0) + alto_fila / 2   # centro de cada fila (de arriba abajo)
  medio <- alto_fila / 2
  cab <- c(153, 134, 115)                         # 3 líneas de cabecera
  # izquierda: pies de lectura (18 px): la banda (mismo texto que el vídeo), años y universo
  banda <- strsplit(BANDA_TXT, " (?=\\()", perl = TRUE)[[1]]    # "band = …countries" / "(spread, …)"
  cab_izq <- c(banda[1], paste(banda[2], "line = median", "1950–2050", sep = " · "),
               sprintf("%d countries ≥ 1 M · grey = UN medium projection", sum(d$tam)))
  if (!MINI) {
    cab_izq <- c("Four groups of 70-year paths (k-means), countries ≥ 1 M",
                 "group · countries · people · three largest (by rule)")
    g <- g + texto(X$sw, cab[1:2], cab_izq, TP$pie, COL_TEXTO_2)
  } else {
  avisar_ancho(cab_izq, TP$pie, X$s1[1] - X$sw - 8, donde = "fig10p cabecera")
  g <- g + texto(X$sw, cab, cab_izq, TP$pie, COL_TEXTO_2)
  # cabeceras de columna a 20 px (mínimo del PDF, §9) y su escala debajo (18 px)
  g <- g + texto(mean(X$s1), cab[1:2], c("children", "per woman"), TP$col, COL_TEXTO, hjust = 0.5, negrita = TRUE)
  g <- g + texto(mean(X$s2), cab[1:2], c("median", "age"), TP$col, COL_TEXTO, hjust = 0.5, negrita = TRUE)
  escala <- c(sprintf("%s–%s", RANGO_Y$TFR[1], RANGO_Y$TFR[2]),
              sprintf("%s–%s years", RANGO_Y$MedianAgePop[1], RANGO_Y$MedianAgePop[2]))
  x_esc <- c(mean(X$s1), min(mean(X$s2), G$W - 1 - ancho_txt(escala[2], TP$pie) / 2))
  g <- g + texto(x_esc, cab[3], escala, TP$pie, COL_TEXTO_2, hjust = 0.5)
  }
  for (k in 1:4) {
    yc <- filas_y[k]
    if (k > 1) g <- g + annotate("segment", x = X$sw, xend = G$W, y = yc + medio, yend = yc + medio,
                                 colour = COL_REJILLA, linewidth = 0.4)
    g <- g + pildora(X$sw, X$sw + 16, yc - 8, yc + 8, COL_GRUPO[[k]], r = 3)  # muestra de color
    avisar_ancho(GRUPOS[k], TP$nombre, X$meta - X$nombre - 4, negrita = TRUE, donde = "fig10p nombre")
    g <- g + texto(X$nombre, yc, GRUPOS[k], TP$nombre, COL_TEXTO, negrita = TRUE)
    meta <- sprintf("%s · %s bn", fmt_cifra(d$tam[[k]], "0"), fmt_cifra(d$pob[[k]], cifra("cluster_pop_bn", "fmt")))
    avisar_ancho(meta, TP$meta, X$flags - X$meta - 2, donde = "fig10p meta")
    g <- g + texto(X$meta, yc, meta, TP$meta, COL_TEXTO_2)
    # 3 banderas (ggflags, ISO2 en minúsculas) + ISO3
    iso3 <- d$ejemplos[[k]]
    xs <- X$flags + (0:2) * X$paso_flag
    g <- g + ggflags::geom_flag(data = data.frame(x = xs + 7, y = yc, country = unname(d$iso2[iso3])),
                                aes(x = .data$x, y = .data$y, country = .data$country), size = 4.8)
    g <- g + annotate("point", x = xs + 7, y = yc, shape = 21, size = 5.1, fill = NA,
                      colour = "#9A9A9A", stroke = 0.35)
    avisar_ancho(iso3, TP$iso, X$paso_flag - 19, negrita = TRUE, donde = "fig10p ISO3")
    g <- g + texto(xs + 17, yc, iso3, TP$iso, COL_TEXTO, negrita = TRUE)
    # mini-series (solo si MINI)
    for (v in if (MINI) c("TFR", "MedianAgePop") else character(0)) {
      xx <- if (v == "TFR") X$s1 else X$s2
      y0 <- yc - medio + 2; y1 <- yc + medio - 2
      sx <- function(a) xx[1] + (a - 1950) / 100 * diff(xx)
      g <- g + annotate("segment", x = sx(2023.5), xend = sx(2023.5), y = y0, yend = y1,
                        colour = COL_EJE, linewidth = 0.35, linetype = "22")
      Ls <- serie_lote(lote_nuevo(), SERIES, GRUPOS[k], v, xx[1], xx[2], y0, y1, 2050, 1, lw_med = 1.15, medoide = FALSE)
      g <- lote_capas(g, Ls, c("rib", "pth"))
    }
  }
  g
}

fig_10 <- function() {
  rutas <- c(png = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig10"]], ".png")),
             print = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig10"]], "_print.png")))
  guardar_lienzo(dibujar_fig10(Inf, "video"), rutas[["png"]], RANURAS$fig10[["w"]], RANURAS$fig10[["h"]])
  guardar_lienzo(dibujar_fig10(Inf, "print"), rutas[["print"]], RANURAS$fig10_print[["w"]], RANURAS$fig10_print[["h"]])
  # variante sin textos de lectura para los builds 3–5 (ranura reducida 1092×235)
  rutas[["small"]] <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig10"]], "_small.png"))
  guardar_lienzo(dibujar_fig10(Inf, "small"), rutas[["small"]], RANURAS$fig10_small[["w"]], RANURAS$fig10_small[["h"]])
  message("  fig10 PNG: ", paste(basename(rutas), collapse = ", "))
  rutas
}

anim_10 <- function() {
  dur <- estado_fig10(0, TIEMPOS_FIG10)$duracion
  ruta <- file.path(RUTA_FIG_ANIMATED, paste0(NOMBRES[["fig10"]], ".mp4"))
  r <- renderizar_mp4(function(t) dibujar_fig10(t, "video"), dur, ruta,
                      RANURAS$fig10[["w"]], RANURAS$fig10[["h"]])
  poster <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig10"]], ".png"))
  message(sprintf("  fig10 MP4: %d fotogramas (%.1f s); último fotograma = póster: %s",
                  r$n, r$n / FPS, mismo_png(r$ultimo, poster)))
  r$mp4
}

# =============================================================================
# 6. fig11 — divergencia entre países (P1, build 2)
# =============================================================================
#
# Qué muestra: 161 países ≥ 1 M, estimaciones 1950–2023. Arriba, dos paneles con la
# banda P10–P90 entre países ("middle 80 % of countries") y la mediana: esperanza de vida
# al nacer (la banda se estrecha: "closer") y edad mediana (se abre: "further apart"). Los
# dos paneles usan la MISMA escala en años (55 años de alto), para que el ancho de las
# bandas se compare de forma honesta. La banda va en tinta azulada (#B9C6DE) con bordes
# P10 y P90 en tinta, NO en gris: en todo el vídeo el gris es la proyección, y estas son
# solo estimaciones (lo dice la leyenda). Rótulo en cada panel con la DE 1950 → 2023 (las
# mismas cifras del titular HTML) y su intervalo del 95 % (bootstrap por bloques de
# subregión; los de 1950 y 2023 no se solapan). Debajo, una tira: razón P90/P10 de la
# mortalidad de menores de 5 (la décima parte de países con más muertes ÷ la de menos),
# eje desde 0, con bigotes del 95 % en 1950 y 2023, y al lado la brecha absoluta P90 − P10
# (q5_gap_p90p10_*), que se CERRÓ: la razón sola haría pensar que la mortalidad infantil
# divergió. Sin rótulo del máximo: es una meseta (1998–2010, 25–27×) y el IC de 2023
# llega a 28, así que un "año del máximo" sería precisión falsa. Naranja = mortalidad
# infantil (como en fig05), con un halo fino #8A5A00 para llegar a ≥ 3:1 sobre blanco.

dibujar_fig11 <- function(version = c("video", "print", "small"), dd = DISP) {
  version <- match.arg(version)
  # "small" (corrector-final, QA-viz V5) = composición apaisada de la versión impresa a 741×150
  # (ranura del vídeo desde s4.b3); mismos tamaños de letra, coordenadas reescaladas
  imp <- version %in% c("print", "small")
  clave_r <- switch(version, video = "fig11", print = "fig11_print", small = "fig11_small")
  W <- RANURAS[[clave_r]][["w"]]
  H <- RANURAS[[clave_r]][["h"]]
  g <- lienzo(W, H)
  if (version == "small") {
    kx <- W / 793; ky <- H / 160
    paneles <- list(lex = round(c(28, 240) * kx), edad = round(c(272, 484) * kx))
    py <- round(c(26, 120) * ky); y_tit <- 141; y_leyenda <- 124; y_anio <- 11
    tira_x <- round(c(548, 790) * kx); tira_y <- round(c(26, 120) * ky); y_tit_tira <- 141; y_anio_tira <- 11
  } else if (!imp) {
    paneles <- list(lex = c(36, 320), edad = c(374, 658))
    py <- c(190, 334); y_tit <- 373; y_leyenda <- 351; y_anio <- 176
    tira_x <- c(36, 658); tira_y <- c(50, 136); y_tit_tira <- 157; y_anio_tira <- 34
    y_pie <- 11
  } else {
    paneles <- list(lex = c(28, 240), edad = c(272, 484))
    py <- c(26, 120); y_tit <- 151; y_leyenda <- 133; y_anio <- 12
    tira_x <- c(548, 790); tira_y <- c(26, 120); y_tit_tira <- 151; y_anio_tira <- 12
  }
  rx <- c(1950, 2023)
  rangos <- list(lex = c(27, 82), edad = c(5, 60))     # mismo alto: 55 años (P90 LEx máx. 81,9)
  marcas <- list(lex = c(30, 50, 70), edad = c(10, 30, 50))
  titulos <- if (version == "small") c(lex = "Life expectancy: closer", edad = "Median age: apart") else
    if (imp) c(lex = "Life expectancy: closer", edad = "Median age: further apart") else
    c(lex = "Life expectancy at birth, years", edad = "Median age, years")
  sd <- list(lex = c(fmt_clave("sd_lex_1950"), fmt_clave("sd_lex_2023")),
             edad = c(fmt_clave("sd_medage_1950"), fmt_clave("sd_medage_2023")))
  rg <- list(lex = c(fmt_rango("sd_lex_1950"), fmt_rango("sd_lex_2023")),
             edad = c(fmt_rango("sd_medage_1950"), fmt_rango("sd_medage_2023")))
  for (v in c("lex", "medage")) {             # el texto dice que el cambio es claro: comprobarlo
    a <- paste0("sd_", v, "_1950"); b <- paste0("sd_", v, "_2023")
    solapan <- cifra(a, "ci_low") <= cifra(b, "ci_high") && cifra(b, "ci_low") <= cifra(a, "ci_high")
    if (solapan) anotar_problema(sprintf("fig11: los IC de %s y %s se solapan; revisar 'closer/further apart'.", a, b))
  }
  rotulo_sd <- c(lex = sprintf("%sSD %s → %s", if (imp) "" else "closer: ", sd$lex[1], sd$lex[2]),
                 edad = sprintf("%sSD %s → %s", if (imp) "" else "further apart: ", sd$edad[1], sd$edad[2]))
  rotulo_rg <- c(lex = sprintf("range %s → %s", rg$lex[1], rg$lex[2]),
                 edad = sprintf("range %s → %s", rg$edad[1], rg$edad[2]))
  for (pn in names(paneles)) {
    xx <- paneles[[pn]]; ry <- rangos[[pn]]
    sx <- function(a) xx[1] + (a - rx[1]) / diff(rx) * diff(xx)
    sy <- function(v) py[1] + (v - ry[1]) / diff(ry) * diff(py)
    dat <- if (pn == "lex") dd$lex else dd$edad
    dat <- dat |> arrange(.data$Time)
    g <- g + annotate("segment", x = xx[1], xend = xx[2], y = sy(marcas[[pn]]), yend = sy(marcas[[pn]]),
                      colour = COL_REJILLA, linewidth = 0.4)
    g <- g + texto(xx[1] - 5, sy(marcas[[pn]]), as.character(marcas[[pn]]), TAM$eje, COL_TEXTO_2, hjust = 1)
    # banda P10–P90: tinta azulada + bordes finos en tinta (no gris = proyección)
    g <- g + annotate("ribbon", x = sx(dat$Time), ymin = sy(dat$p10), ymax = sy(dat$p90),
                      fill = COL_BANDA_PAISES)
    g <- g + annotate("path", x = sx(dat$Time), y = sy(dat$p10), colour = COL_TINTA, linewidth = 0.28)
    g <- g + annotate("path", x = sx(dat$Time), y = sy(dat$p90), colour = COL_TINTA, linewidth = 0.28)
    g <- g + annotate("path", x = sx(dat$Time), y = sy(dat$p50), colour = COL_TINTA, linewidth = 1.35,
                      lineend = "round")
    # extremos de la banda marcados (P10 y P90 en 1950 y 2023): corchete fino
    for (a in c(1950, 2023)) {
      fila <- dat[dat$Time == a, ]
      xa <- sx(a) + if (a == 1950) -1 else 1
      g <- g + annotate("segment", x = xa, xend = xa, y = sy(fila$p10), yend = sy(fila$p90),
                        colour = COL_TINTA, linewidth = 0.8)
    }
    tam_tp <- if (imp) TAM$nota else TAM$panel
    g <- g + texto(xx[1], y_tit, titulos[[pn]], tam_tp, COL_TEXTO, negrita = TRUE)
    avisar_ancho(titulos[[pn]], tam_tp, diff(xx) + 10, TRUE, donde = "fig11 título panel")
    g <- g + texto(c(xx[1], xx[2]), y_anio, c("1950", "2023"), TAM$eje, COL_TEXTO_2, hjust = c(0, 1))
    # rótulo de la DE (y su intervalo del 95 %) en una esquina libre: abajo a la derecha en
    # LEx (bajo el borde P10), arriba a la izquierda en edad mediana (sobre el P90)
    if (pn == "lex") {
      if (!imp) {
        # (el rango se apoya en la rejilla de 30, tapada por el halo; más arriba choca con P10)
        g <- g + texto_halo(xx[2], sy(36.2), rotulo_sd[[pn]], TAM$valor, COL_TINTA, hjust = 1, negrita = TRUE)
        g <- g + texto_halo(xx[2], sy(30.2), rotulo_rg[[pn]], TAM$nota, COL_TEXTO_2, hjust = 1)
        avisar_ancho(rotulo_rg[[pn]], TAM$nota, diff(xx) - 6, donde = "fig11 rango DE")
      } else {
        g <- g + texto_halo(xx[2], sy(37), rotulo_sd[[pn]], TAM$valor, COL_TINTA, hjust = 1, negrita = TRUE)
      }
    } else if (!imp) {
      g <- g + texto_halo(xx[1] + 4, sy(56), rotulo_sd[[pn]], TAM$valor, COL_TINTA, hjust = 0, negrita = TRUE)
      # bajo la rejilla de 50 (la línea queda entre el rótulo y su rango, sin cruzar texto)
      g <- g + texto_halo(xx[1] + 4, sy(45.3), rotulo_rg[[pn]], TAM$nota, COL_TEXTO_2, hjust = 0)
      avisar_ancho(rotulo_rg[[pn]], TAM$nota, diff(xx) - 6, donde = "fig11 rango DE")
    } else {
      g <- g + texto_halo(xx[2] - 2, sy(56.5), rotulo_sd[[pn]], TAM$valor, COL_TINTA, hjust = 1, negrita = TRUE)
      g <- g + texto_halo(xx[1] + 4, sy(44), "band = middle 80 %", TAM$nota, COL_TEXTO_2)
      g <- g + texto_halo(xx[2] - 2, sy(9.6), "line = median", TAM$nota, COL_TEXTO_2, hjust = 1)
    }
    avisar_ancho(rotulo_sd[[pn]], TAM$valor, diff(xx) - 6, TRUE, donde = "fig11 rótulo DE")
  }
  # leyenda de lectura (vídeo) o universo (impreso), bajo los títulos de los paneles
  if (!imp) {
    ley <- "band = middle 80 % of countries · line = median · UN estimates, no projection"
    avisar_ancho(ley, TAM$nota, W - paneles$lex[1] - 2, donde = "fig11 leyenda")
    g <- g + texto(paneles$lex[1], y_leyenda, ley, TAM$nota, COL_TEXTO_2)
  }
  # impreso / small (jurado viz I-1, 2026-10-27): sin leyenda de universo bajo los paneles (cruzaba
  # el panel de edad y tocaba "SD 4.7 → 9.7"); "161 countries ≥ 1 M" y "bars = 95 % ranges" van en
  # la nota HTML (.blk11 > p.fn) y en la franja de método de la S4.

  # --- tira: razón P90/P10 de la mortalidad de menores de 5 + brecha absoluta ---
  q5 <- dd$q5 |> arrange(.data$Time)
  ry <- c(0, 32)                                       # eje desde 0 (razón); máx. 26,9 e IC 2023 hasta 28,4
  marcas_q5 <- c(0, 10, 20, 30)
  sx <- function(a) tira_x[1] + (a - rx[1]) / diff(rx) * diff(tira_x)
  sy <- function(v) tira_y[1] + (v - ry[1]) / diff(ry) * diff(tira_y)
  g <- g + annotate("segment", x = tira_x[1], xend = tira_x[2], y = sy(marcas_q5),
                    yend = sy(marcas_q5), colour = c(COL_EJE, rep(COL_REJILLA, length(marcas_q5) - 1)),
                    linewidth = 0.4)
  g <- g + texto(tira_x[1] - 5, sy(marcas_q5), as.character(marcas_q5), TAM$eje, COL_TEXTO_2, hjust = 1)
  # línea naranja con halo oscuro fino (#E69F00 solo sobre blanco no llega a 3:1)
  lw_q5 <- if (imp) 1.6 else 2.0
  g <- g + annotate("path", x = sx(q5$Time), y = sy(q5$razon_p90p10), colour = COL_Q5_TXT,
                    linewidth = lw_q5 + 0.28, lineend = "round")
  g <- g + annotate("path", x = sx(q5$Time), y = sy(q5$razon_p90p10), colour = COL_Q5, linewidth = lw_q5,
                    lineend = "round")
  q_ini <- q5$razon_p90p10[q5$Time == 1950]; q_fin <- q5$razon_p90p10[q5$Time == 2023]
  # bigotes del intervalo del 95 % (bootstrap por bloques de subregión) en 1950 y 2023
  ic_lo <- c(cifra("q5_ratio_p90p10_1950", "ci_low"), cifra("q5_ratio_p90p10_2023", "ci_low"))
  ic_hi <- c(cifra("q5_ratio_p90p10_1950", "ci_high"), cifra("q5_ratio_p90p10_2023", "ci_high"))
  xb <- sx(c(1950, 2023))
  g <- g + annotate("segment", x = xb, xend = xb, y = sy(ic_lo), yend = sy(ic_hi), colour = COL_Q5_TXT,
                    linewidth = 0.45)
  g <- g + annotate("segment", x = rep(xb, 2) - 3, xend = rep(xb, 2) + 3, y = sy(c(ic_lo, ic_hi)),
                    yend = sy(c(ic_lo, ic_hi)), colour = COL_Q5_TXT, linewidth = 0.45)
  g <- g + annotate("point", x = xb, y = sy(c(q_ini, q_fin)), colour = COL_Q5_TXT, size = 2.3)
  r50 <- fmt_clave("q5_ratio_p90p10_1950"); r23 <- fmt_clave("q5_ratio_p90p10_2023")
  e50 <- if (imp) paste0(r50, "×") else sprintf("%s× (%s)", r50, fmt_rango("q5_ratio_p90p10_1950"))
  e23 <- if (imp) paste0(r23, "×") else sprintf("%s× (%s)", r23, fmt_rango("q5_ratio_p90p10_2023"))
  g <- g + texto_halo(xb[1] + 8, sy(if (imp) 16 else 15.5), e50, TAM$valor, COL_Q5_TXT, negrita = TRUE)
  g <- g + texto_halo(xb[2] - (if (imp) 6 else 8), sy(30.6), e23, TAM$valor, COL_Q5_TXT, hjust = 1, negrita = TRUE)
  # brecha absoluta P90 − P10 (muertes por 1.000 nacidos): se cerró
  if (cifra("q5_gap_p90p10_2023") >= cifra("q5_gap_p90p10_1950")) {
    anotar_problema("fig11: la brecha absoluta de Q5 ya no se cierra; revisar el texto 'gap shrank'.")
  }
  # corrector-final (QA-viz V3): q5_gap_p90p10_1950/2023 tienen verified: false → sin cifras; queda
  # la lectura en palabras (el titular HTML del PDF dice "while the absolute gap shrank")
  if (!imp) {
    g <- g + texto(xb[2] - 8, sy(7.4), "the ratio grew, but the gap in deaths shrank", TAM$nota, COL_Q5_TXT,
                   hjust = 1, negrita = TRUE)
  }
  tit_tira <- if (imp) "Child deaths: highest ÷ lowest tenth" else
    "Child deaths before age 5: highest tenth of countries ÷ lowest tenth"
  tam_tt <- if (imp) TAM$nota else TAM$fila
  x_tt <- if (imp) tira_x[2] else tira_x[1] - 30
  avisar_ancho(tit_tira, tam_tt, if (imp) tira_x[2] - paneles$edad[2] - 10 else W - x_tt, TRUE, donde = "fig11 título tira")
  g <- g + texto(x_tt, y_tit_tira, tit_tira, tam_tt, COL_Q5_TXT, negrita = TRUE, hjust = if (imp) 1 else 0)
  g <- g + texto(c(tira_x[1], tira_x[2]), y_anio_tira, c("1950", "2023"), TAM$eje, COL_TEXTO_2, hjust = c(0, 1))
  if (!imp) {
    pie <- "161 countries ≥ 1 M · same year scale · ranges, bars = 95 % (re-runs by sub-region)"
    avisar_ancho(pie, TAM$pie, W - 4, donde = "fig11 pie")
    g <- g + texto(2, y_pie, pie, TAM$pie, COL_TEXTO_2)
  }
  g
}

fig_11 <- function() {
  rutas <- c(png = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig11"]], ".png")),
             print = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig11"]], "_print.png")))
  guardar_lienzo(dibujar_fig11("video"), rutas[["png"]], RANURAS$fig11[["w"]], RANURAS$fig11[["h"]])
  guardar_lienzo(dibujar_fig11("print"), rutas[["print"]], RANURAS$fig11_print[["w"]], RANURAS$fig11_print[["h"]])
  rutas[["small"]] <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig11"]], "_small.png"))
  guardar_lienzo(dibujar_fig11("small"), rutas[["small"]], RANURAS$fig11_small[["w"]], RANURAS$fig11_small[["h"]])
  message("  fig11 PNG: ", paste(basename(rutas), collapse = ", "))
  rutas
}

# =============================================================================
# 7. Ejecución
# =============================================================================

Q3 <- leer_q3()
SERIES <- preparar_series(Q3)
DISP <- leer_dispersion()
MAPA <- preparar_mapa()
TEXTOS_FIG10 <- textos_fig10(Q3)
verificar_used_in(CLAVES_FIG10)
TIEMPOS_FIG10 <- tiempos_s4b1()
# el MP4 termina 0,3 s antes del fin del paso (build_narration.py exige paso ≥ MP4 + 0,3 s;
# si el MP4 durara lo mismo que el paso, cada regeneración alargaría el paso 0,3 s)
DURACION_FIG10 <- duracion_paso("s4.b1", DURACION_S4B1) - 0.3
GEOM_FIG10_VIDEO <- geom_fig10("video", MAPA, Q3)
GEOM_FIG10_PRINT <- geom_fig10("print", MAPA, Q3)
GEOM_FIG10_SMALL <- geom_fig10("small", MAPA, Q3)

if (sys.nframe() == 0L) {
  cuales <- commandArgs(trailingOnly = TRUE)
  if (length(cuales) == 0) cuales <- c("fig10", "fig11")
  if ("fig10" %in% cuales) { fig_10(); if (!SIN_MP4) anim_10() }
  if ("fig11" %in% cuales) fig_11()
  if (length(PROBLEMAS) > 0) message("Problemas anotados:\n  - ", paste(PROBLEMAS, collapse = "\n  - "))
  if (length(AVISOS_ANCHO) > 0) message(length(AVISOS_ANCHO), " avisos de ancho de texto (ver arriba).")
  message(sprintf("fig_q3_slide4.R listo en %.1f s.", as.numeric(difftime(Sys.time(), t_inicio, units = "secs"))))
}
