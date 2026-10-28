#!/usr/bin/env Rscript
# =============================================================================
# fig_q1_slide2.R
# Figuras FINALES de la Slide 2 — Question 1 (cont.) · P7 · P1 (storyboard v2.1 §3)
# "Same road, different speed: child mortality fell first, fertility followed"
#
# Ejecutar desde la raíz del repo:
#   Rscript R/fig_q1_slide2.R                 # todo: PNG, _print.png y MP4
#   Rscript R/fig_q1_slide2.R fig04           # solo una figura (fig04 | fig05 | fig06)
#   FIG_SIN_MP4=1 Rscript R/fig_q1_slide2.R   # solo PNG (prueba rápida, sin MP4)
#   FIG05_SIN_NOTA=1 Rscript R/fig_q1_slide2.R fig05   # fig05 sin la nota "flecha en 0" (si slides
#                                                       # prefiere su recuadro HTML .callout)
# Revisión (no son figuras del vídeo): figures/review/slide2/ (fotogramas clave de fig04 y
# simulaciones de daltonismo deutan/protan/tritan de cada PNG).
#
# Qué produce (nombres exactos que esperan slides/index.html y slides/js/figs.js):
#   fig04_same_road_registration      (build 1, MP4 + póster; la única animación larga de datos)
#     figures/animated/fig04_same_road_registration.mp4      3520×832, H.264 yuv420p 30 fps
#     figures/static/fig04_same_road_registration.png        póster = último fotograma
#     figures/static/fig04_same_road_registration_print.png  1548×486 (ranura PDF 774×243)
#     figures/static/fig04_same_road_registration_small.png  1548×366 (ranura final 774×183 de
#       los builds 2–4: slides debe fundir el <video> a este PNG en la transición de s2.b2)
#   fig05_mortality_first_event_time  (build 2)
#     figures/static/fig05_mortality_first_event_time.png        1972×422 (ranura 986×211)
#     figures/static/fig05_mortality_first_event_time_print.png  1972×542 (ranura PDF 986×271)
#   fig06_within_vs_across_forest     (build 3)
#     figures/static/fig06_within_vs_across_forest.png        2042×270 (ranura 1021×135)
#     figures/static/fig06_within_vs_across_forest_print.png  2042×366 (ranura PDF 1021×183)
#   El chip de migración (build 4) y el recuadro "Question 1 answered" son HTML: sin figura.
#
# Contrato con las diapositivas (slides/README.md §3):
#   * Sin título ni subtítulo dentro de la imagen (el titular-mensaje y las cifras de las
#     frases van en HTML desde numbers.json); sí ejes, unidades, etiquetas directas,
#     leyenda propia en lenguaje llano y fondo blanco.
#   * Tamaño = ranura medida (slides/dev/figure_slots.json) × 2. Con res = 144 y la imagen
#     al doble de la ranura, 1 pt = 1 px de la diapositiva 1920×1080: TODOS los tamaños de
#     este script (TAM*, márgenes, grosores) están en px de diapositiva.
#   * fig04 se ve en dos ranuras: héroe 1760×496 (build 1, mientras habla la voz) y final
#     774×183 (builds 2–4). El MP4 se dibuja con la proporción de la ranura final (4,23 →
#     lienzo 1760×416; en la héroe ocupa 1760×416 con object-fit: contain): texto de 22–28 px
#     (28 px las etiquetas que nombra la voz). Reducido a 774×183 ese texto bajaría a ~10 px,
#     así que la ranura final usa _small.png (774×183, diseñada a 18 px). En el PDF se usa
#     _print.png (774×243, texto ≥ 18 px).
#   * fig05 y fig06 tienen ranuras muy bajas (211 y 135 px): texto de 18 px (mínimo del
#     README y del storyboard §9), no 28 px; ver PROBLEMAS al final de la corrida.
#
# Animación de fig04 (fotogramas ragg + tweenr → ffmpeg del venv, H.264 yuv420p 30 fps).
#   SEÑALA lo que dice la voz en cada bloque de subtítulo del paso s2.b1 (4 bloques):
#     b1 "Set each country's clock to when its fertility fell below four children,"
#         → año calendario; se marca la línea de 4 y el punto donde cada curva la cruza;
#           aparece la banda P10–P90 (ancha, en calendario).
#     b2 "and the curves line up." → las curvas se deslizan hasta alinearse en el cruce de 4;
#           los puntos convergen en 0; la banda se estrecha; el eje pasa de "calendar year"
#           a "years since fertility fell below 4 children per woman" (ejes fijos).
#           Las etiquetas ISO3 del calendario se apagan 0,25 s ANTES de deslizar (no viajan).
#     b3 "The road is shared; the speed is not." → aparece la mediana (línea azul); el fondo
#           se atenúa; nota gris "all curves meet here by design" junto a (0, 4).
#     b4 "China went from five to three children in {dur53_chn} years; Egypt took {dur53_egy}."
#           → se resalta China (tramo 5 → 3 grueso, puntos en 5 y 3, y en el carril de abajo
#           su barra de tau(5) a tau(3) se dibuja a 20 años/s con "CHN · 5 years (fastest to
#           reach 3)"; el resto de resaltes se atenúa); al decir "Egypt", Egipto (su barra
#           tarda más en dibujarse porque es más larga); al final, el mediano (Colombia).
#   Países resaltados POR REGLA (fig04_highlight_iso3 en numbers_q1.json: el más rápido, el
#   mediano y el más lento de 5 → 3 entre los ≥ 10 M que llegaron a 3); se comprueba la regla
#   contra resultados_q1.parquet y el script se detiene si no coincide.
#   Instantes: de slides/script/video_timings.json si ya existe con `captions` para s2.b1;
#   si no, estimación por palabras del guion v2.1 (150 ppm + 1,5 s de aire tras cada cifra
#   hablada) escalada a la duración de la plantilla (s2.b1 = 16,4 s). Volver a correr el
#   script tras grabar la voz re-sincroniza. El MP4 dura lo que el paso (no invade s2.b2).
#
# Datos (NO se recalcula ningún estadístico; solo se leen resultados ya calculados):
#   figures/numbers_q1.json                              cifras finales (valor, IC, fmt)
#   data/processed/resultados_q1_registro.parquet        TFR suavizada por país y año, c4, tau
#   data/processed/resultados_q1_registro_dispersion.parquet  P10/P50/P90 calendario y alineado
#   data/processed/resultados_q1.parquet                 c5, c4, c3, dur_5a3 por país (regla)
#   data/processed/resultados_q1_event_time.parquet      medianas y RIC de Q5 y TFR (% del máximo)
#   data/processed/resultados_q1_panel.parquet           dentro vs entre (comprobación cruzada)
#   data/processed/resultados_q1_placebo.parquet         placebo (comprobación cruzada)
#
# Convención: código y comentarios en español; todo texto visible en inglés llano.
# =============================================================================

t_inicio <- Sys.time()

suppressPackageStartupMessages({
  library(here)
})
source(here::here("R", "config.R"))
source(here::here("R", "utilidades.R"))
source(here::here("R", "comun_analisis.R"))   # paletas v2, formatear_cifra(), rutas

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(arrow)
  library(jsonlite)
  library(ragg)
  library(tweenr)
  library(systemfonts)
})
for (.p in c("png")) {
  if (!requireNamespace(.p, quietly = TRUE)) stop("Falta el paquete ", .p, call. = FALSE)
}
rm(.p)

ARGS <- commandArgs(trailingOnly = TRUE)
SOLO <- if (length(ARGS) > 0) ARGS else c("fig04", "fig05", "fig06")

# =============================================================================
# 0. Constantes de salida, tamaños y colores
# =============================================================================

ESCALA <- 2                       # imagen = 2 × ranura (README §3: "exportar a 2×")
RES <- 72 * ESCALA                # 144 ppp → 1 pt = 1 px de diapositiva
FPS <- 30
NUCLEOS <- max(1L, min(8L, parallel::detectCores() - 4L))
SIN_MP4 <- nzchar(Sys.getenv("FIG_SIN_MP4"))
FUENTE <- "Lato"

# Ranuras en px de diapositiva (slides/README.md §3 y slides/dev/figure_slots.json).
RANURAS <- list(
  fig04 = c(w = 1760, h = 416),  fig04_print = c(w = 774, h = 243), fig04_small = c(w = 774, h = 183),
  fig05 = c(w = 986,  h = 211),  fig05_print = c(w = 986, h = 271),
  fig06 = c(w = 1021, h = 135),  fig06_print = c(w = 1021, h = 183)
)
NOMBRES <- c(fig04 = "fig04_same_road_registration",
             fig05 = "fig05_mortality_first_event_time",
             fig06 = "fig06_within_vs_across_forest")

COL_TEXTO   <- "#1A1A1A"
COL_TEXTO_2 <- "#555555"          # texto secundario (contraste 7,5:1 sobre blanco)
COL_TINTA   <- "#15233B"          # --ink de slides/css/theme.css
COL_REJILLA <- "#E9E9E9"
COL_EJE     <- "#9A9A9A"
COL_NAC     <- COLOR_NACIMIENTOS  # "#0072B2": nacimientos / fecundidad (mismo significado que la Slide 1)
COL_NAC_TXT <- "#005A8C"          # azul más oscuro para texto pequeño (contraste 7:1)
COL_Q5      <- COLOR_DEFUNCIONES  # "#E69F00": defunciones / mortalidad infantil
COL_Q5_TXT  <- "#8A5A00"          # naranja oscuro legible sobre blanco
COL_FONDO_LINEAS   <- "#C4C4C4"   # curvas de contexto (gris = fondo, storyboard §8)
COL_FONDO_ATENUADO <- "#DEDEDE"
COL_PLACEBO <- "#E4E4E4"          # banda del placebo (gris claro, sin semántica de proyección)
COL_RESALTE_FILA <- "#EDF1F7"     # fondo de la fila resaltada en fig06

# Grosor de línea: ggplot pasa lwd = linewidth × .pt (unidades de 1/96 in). Con 144 ppp y la
# imagen a 2×, 1/96 in = 0,75 px de ranura → linewidth = px / (.pt × 0,75).
lw <- function(px) px / (.pt * (RES / 96) / ESCALA)
# Diámetro de un punto (shape 16/21): ≈ 0,75 × fontsize, fontsize = size × .pt (pt = px).
tam_punto <- function(diam_px) diam_px / (0.75 * .pt)

PROBLEMAS <- character(0)
anotar_problema <- function(txt) {
  if (!txt %in% PROBLEMAS) { PROBLEMAS <<- c(PROBLEMAS, txt); message("  PROBLEMA: ", txt) }
}

RUTA_TIMINGS <- file.path(RUTA_RAIZ, "slides", "script", "video_timings.json")
RUTA_VENV <- Sys.getenv("VENV")   # venv del proyecto con imageio-ffmpeg (ver SETUP.md); vacío = FFMPEG o ffmpeg del sistema
RUTA_REVISION <- file.path(RUTA_FIG_REVIEW, "slide2")

# =============================================================================
# 1. Cifras (numbers_q1.json) y formato idéntico al del HTML
# =============================================================================

NUM <- jsonlite::read_json(file.path(RUTA_FIGURAS, "numbers_q1.json"), simplifyVector = TRUE)

#' Devuelve un campo de una clave de numbers_q1.json (se detiene si falta la clave).
cifra <- function(clave, campo = "value") {
  if (is.null(NUM[[clave]])) stop("numbers_q1.json no trae la clave '", clave, "'.", call. = FALSE)
  NUM[[clave]][[campo]]
}
#' Formatea con el `fmt` de numbers.json y el signo menos tipográfico (U+2212) que usa
#' slides/js/numbers.js, para que la figura muestre exactamente lo mismo que el HTML.
fmt_cifra <- function(valor, fmt) gsub("-", "−", formatear_cifra(valor, fmt), fixed = TRUE)
fmt_clave <- function(clave, fmt = NULL) fmt_cifra(cifra(clave), if (is.null(fmt)) cifra(clave, "fmt") else fmt)

# =============================================================================
# 2. Lectura de resultados y comprobaciones cruzadas json ↔ parquet
# =============================================================================

leer_datos <- function() {
  rp <- function(n) arrow::read_parquet(file.path(RUTA_PROCESSED, paste0(n, ".parquet")))
  reg  <- rp("resultados_q1_registro")
  q    <- rp("resultados_q1") |> filter(.data$pob_1m %in% TRUE)
  disp <- rp("resultados_q1_registro_dispersion") |> filter(.data$hito == "c4") |> arrange(.data$tau)
  et   <- rp("resultados_q1_event_time") |> filter(.data$ingreso == "All")
  pan  <- rp("resultados_q1_panel")
  plac <- rp("resultados_q1_placebo")

  chk <- function(cond, msg) if (!isTRUE(cond)) stop("Comprobación json ↔ parquet: ", msg, call. = FALSE)
  # --- registro (fig04) ---
  chk(nrow(q) == 161, "resultados_q1.parquet no tiene 161 países >= 1 M")
  chk(dplyr::n_distinct(reg$ISO3_code) == cifra("n_cruce_tfr4_obs"), "n_cruce_tfr4_obs ≠ países en el registro")
  chk(sum(is.finite(q$c4)) == cifra("n_cruce_tfr4_obs"), "n_cruce_tfr4_obs ≠ c4 finitos")
  chk(sum(q$c4 == -Inf, na.rm = TRUE) == cifra("n_cens_izq"), "n_cens_izq ≠ c4 = -Inf")
  chk(sum(q$c4 == Inf, na.rm = TRUE) == cifra("n_cens_der"), "n_cens_der ≠ c4 = Inf")
  completos <- q$ventana_completa_c4 %in% TRUE
  chk(sum(completos) == cifra("pct_var_fase", "n"), "pct_var_fase n ≠ países con ventana completa")
  chk(nrow(disp) == 41 && identical(as.numeric(disp$tau), as.numeric(-20:20)), "dispersión c4 no es tau -20..20")
  red <- 100 * (1 - mean(disp$var_alineado) / mean(disp$var_calendario))
  chk(abs(red - cifra("pct_var_fase")) < 1e-3,   # el json redondea a 4 decimales
      "pct_var_fase ≠ reducción de varianza del parquet")
  # Año de referencia del calendario: la mediana de c4 de los 57 con ventana completa
  # (la misma que usa 02_q1_palancas.R §6.2 para la banda "calendario").
  cal0 <- stats::median(q$c4[completos])
  # Verificación de esa convención: la mediana calendario del parquet debe coincidir con la
  # mediana de la TFR suavizada (anual, interpolada) de esos 57 países en cal0 + tau.
  iso57 <- q$ISO3_code[completos]
  m_cal <- vapply(disp$tau, function(tt) {
    v <- vapply(iso57, function(i) {
      r <- reg[reg$ISO3_code == i, ]
      stats::approx(r$Time, r$tfr_suav, xout = cal0 + tt, rule = 2)$y
    }, numeric(1))
    stats::median(v)
  }, numeric(1))
  if (max(abs(m_cal - disp$p50_calendario)) > 0.05) {
    anotar_problema(sprintf("fig04: la banda 'calendario' del parquet no cuadra con cal0 = %.2f (dif. máx %.3f).",
                            cal0, max(abs(m_cal - disp$p50_calendario))))
  }

  # Regla de resaltes (5 → 3 entre los >= 10 M que llegaron a 3): rápido, mediano, lento.
  hl <- cifra("fig04_highlight_iso3")
  d53 <- q |> filter(is.finite(.data$c5), .data$evento_3 %in% 1, .data$pop_2023_miles >= 10000) |>
    arrange(.data$dur_5a3)
  regla <- c(d53$ISO3_code[1], d53$ISO3_code[which.min(abs(d53$dur_5a3 - stats::median(d53$dur_5a3)))],
             d53$ISO3_code[nrow(d53)])
  chk(identical(unname(hl), regla), sprintf("fig04_highlight_iso3 (%s) ≠ regla del parquet (%s)",
                                           paste(hl, collapse = ","), paste(regla, collapse = ",")))
  chk(nrow(d53) == cifra("fig04_highlight_iso3", "n"), "fig04_highlight_iso3 n ≠ países >= 10 M que llegaron a 3")
  chk(identical(cifra("dur53_fastest_ge10m"), hl[1]) && identical(cifra("dur53_slowest_ge10m"), hl[3]),
      "dur53_fastest/slowest_ge10m no coinciden con fig04_highlight_iso3")
  resaltes <- q |> filter(.data$ISO3_code %in% hl) |>
    select("ISO3_code", "Location", "c5", "c4", "c3", "dur_5a3")
  resaltes <- resaltes[match(hl, resaltes$ISO3_code), ]
  resaltes$rol <- c("fastest", "median", "slowest")
  # Duración mostrada: la clave dur53_<iso> si existe (cifra final); si no, el parquet.
  resaltes$dur_txt <- vapply(seq_len(nrow(resaltes)), function(k) {
    clave <- paste0("dur53_", tolower(resaltes$ISO3_code[k]))
    if (!is.null(NUM[[clave]])) {
      chk(abs(cifra(clave) - resaltes$dur_5a3[k]) < 1e-3, paste(clave, "≠ dur_5a3 del parquet"))
      fmt_clave(clave)
    } else {
      anotar_problema(sprintf(paste0("fig04: no existe la clave %s en numbers_q1.json; la duración de %s ",
                                     "(%.1f años, %s) sale de resultados_q1.parquet (dur_5a3) con fmt '0' ",
                                     "como dur53_chn/egy (coincide con sens_note de fig04_highlight_iso3)."),
                              clave, resaltes$ISO3_code[k], resaltes$dur_5a3[k], resaltes$rol[k]))
      fmt_cifra(resaltes$dur_5a3[k], cifra("dur53_chn", "fmt"))
    }
  }, character(1))
  resaltes$tau5 <- resaltes$c5 - resaltes$c4
  resaltes$tau3 <- resaltes$c3 - resaltes$c4

  # --- tiempo de evento (fig05) ---
  chk(setequal(unique(et$variable), c("Q5", "TFR")), "event_time sin Q5/TFR")
  chk(all(c(-25, 0, 30) %in% et$tau), "event_time no cubre tau -25..30")

  # --- panel y placebo (fig06) ---
  filas <- tibble::tibble(
    clave = c("panel_within_halfq5", "panel_low_income_halfq5", "panel_lowmid_halfq5",
              "panel_upmid_halfq5", "panel_high_halfq5"),
    grupo_pq = c("All (>= 1 M)", "Low income", "Lower middle income", "Upper middle income", "High income"),
    etiqueta = c("All countries", "Low income", "Lower-middle", "Upper-middle", "High income")
  )
  filas$valor <- vapply(filas$clave, cifra, numeric(1))
  filas$lo <- vapply(filas$clave, cifra, numeric(1), campo = "ci_low")
  filas$hi <- vapply(filas$clave, cifra, numeric(1), campo = "ci_high")
  filas$n  <- vapply(filas$clave, function(k) as.integer(cifra(k, "n")), integer(1))
  for (i in seq_len(nrow(filas))) {
    r <- pan[pan$grupo == filas$grupo_pq[i], ]
    chk(nrow(r) == 1, paste("panel.parquet sin la fila", filas$grupo_pq[i]))
    chk(abs(r$halfq5 - filas$valor[i]) < 5e-4 && abs(r$ci_boot_lo - filas$lo[i]) < 1e-6 &&
          abs(r$ci_boot_hi - filas$hi[i]) < 1e-6 && r$n_paises == filas$n[i],   # valor redondeado a 4 decimales en el json
        paste(filas$clave[i], "≠ panel.parquet (valor, IC por bloques o n)"))
    chk(cifra(filas$clave[i], "method") == "block bootstrap by subregion",
        paste(filas$clave[i], "no trae IC por bloques de subregión"))
  }
  entre <- pan[pan$bloque == "between", ]
  chk(abs(entre$halfq5 - cifra("panel_between_halfq5")) < 5e-4, "panel_between_halfq5 ≠ panel.parquet")
  qq <- stats::quantile(plac$halfq5, c(0.025, 0.975), names = FALSE)
  chk(abs(qq[1] - cifra("panel_placebo_lo")) < 1e-3 && abs(qq[2] - cifra("panel_placebo_hi")) < 1e-3,
      "panel_placebo_lo/hi ≠ cuantiles 2,5/97,5 % del placebo")

  list(reg = reg, q = q, disp = disp, cal0 = cal0, resaltes = resaltes, et = et, filas = filas)
}

# =============================================================================
# 3. Lienzo, texto y tiempo
# =============================================================================

#' Tema común de las figuras del vídeo: lienzo blanco, Lato, sin márgenes extra.
if (!exists("tema_dq")) {
  tema_dq <- function(base_family = FUENTE) {
    theme_void(base_family = base_family) +
      theme(plot.background = element_rect(fill = "white", colour = NA),
            panel.background = element_rect(fill = "white", colour = NA),
            plot.margin = margin(0, 0, 0, 0), legend.position = "none")
  }
}

#' Geometría de un lienzo: ranura w×h (px), márgenes c(t, r, b, l) (px) y límites de datos.
nuevo_lienzo <- function(w, h, mar, xlim, ylim) {
  names(mar) <- c("t", "r", "b", "l")
  pw <- w - mar[["r"]] - mar[["l"]]; ph <- h - mar[["t"]] - mar[["b"]]
  list(w = w, h = h, mar = mar, xlim = xlim, ylim = ylim, pw = pw, ph = ph,
       dx = diff(xlim) / pw, dy = diff(ylim) / ph)
}
px_x <- function(L, px) L$xlim[1] + (px - L$mar[["l"]]) * L$dx      # px desde el borde izquierdo
px_y <- function(L, px) L$ylim[1] + (px - L$mar[["b"]]) * L$dy      # px desde el borde inferior
frac_x <- function(L, x) (L$mar[["l"]] + (x - L$xlim[1]) / L$dx) / L$w

#' ggplot vacío con el panel exactamente dentro de los márgenes (clip off para rotular fuera).
base_lienzo <- function(L) {
  ggplot() +
    coord_cartesian(xlim = L$xlim, ylim = L$ylim, expand = FALSE, clip = "off") +
    scale_fill_identity() + scale_colour_identity() + scale_alpha_identity() +
    scale_linewidth_identity() + scale_linetype_identity() + scale_size_identity() +
    tema_dq() +
    theme(plot.margin = margin(L$mar[["t"]], L$mar[["r"]], L$mar[["b"]], L$mar[["l"]], unit = "pt"))
}

#' Ancho de un texto en px de diapositiva (Lato, tamaño en px).
ancho_txt <- function(txt, px, negrita = FALSE) {
  as.numeric(systemfonts::string_width(txt, family = FUENTE, size = px, res = 72,
                                       weight = if (negrita) "bold" else "normal"))
}
AVISOS_ANCHO <- character(0)
avisar_ancho <- function(txt, px, disponible, negrita = FALSE, donde = "") {
  w <- ancho_txt(txt, px, negrita)
  for (k in which(w > disponible)) {
    msg <- sprintf("%s: '%s' mide %.0f px y hay %.0f px", donde, txt[k], w[k], disponible)
    if (!msg %in% AVISOS_ANCHO) { AVISOS_ANCHO <<- c(AVISOS_ANCHO, msg); anotar_problema(paste("Texto que no cabe —", msg)) }
  }
  invisible(w)
}

#' Texto en px (tamaño en px de diapositiva → mm de ggplot).
texto <- function(x, y, label, px, colour = COL_TEXTO, hjust = 0, vjust = 0.5,
                  negrita = FALSE, alpha = 1) {
  if (length(alpha) == 1 && alpha <= 0.001) return(NULL)
  annotate("text", x = x, y = y, label = label, size = px / .pt, colour = colour,
           hjust = hjust, vjust = vjust, family = FUENTE, fontface = if (negrita) "bold" else "plain",
           alpha = alpha, lineheight = 0.95)
}
#' Texto con halo blanco (etiquetas sobre líneas o bandas).
texto_halo <- function(x, y, label, px, colour = COL_TEXTO, hjust = 0, vjust = 0.5,
                       negrita = FALSE, alpha = 1) {
  if (alpha <= 0.001) return(NULL)
  annotate("label", x = x, y = y, label = label, size = px / .pt, colour = colour,
           hjust = hjust, vjust = vjust, family = FUENTE, fontface = if (negrita) "bold" else "plain",
           alpha = alpha, fill = scales::alpha("white", 0.88 * alpha), border.colour = NA, linewidth = 0,
           label.padding = unit(1.5, "pt"), label.r = unit(2, "pt"))
}

#' Interpola entre dos colores (p = 0: a; p = 1: b).
mezclar <- function(a, b, p) {
  ma <- grDevices::col2rgb(a) / 255; mb <- grDevices::col2rgb(b) / 255
  p <- min(1, max(0, p))
  out <- ma * (1 - p) + mb * p
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
duracion_paso <- function(paso, por_defecto) {
  if (file.exists(RUTA_TIMINGS)) {
    tj <- tryCatch(jsonlite::read_json(RUTA_TIMINGS, simplifyVector = FALSE), error = function(e) NULL)
    st <- Filter(function(s) identical(s$id, paso), tj$steps)
    if (length(st) == 1 && is.numeric(st[[1]]$duration)) return(as.numeric(st[[1]]$duration))
  }
  por_defecto
}

# Estimación por palabras del paso s2.b1 (guion v2.1 con las cifras reales; 150 ppm,
# 0,3 s entre frases, 1,5 s de aire tras cada cifra hablada) = 18,8 s, escalada a los
# 16,4 s de la plantilla (slides/dev/video_timings.template.json):
#   b1 "Set each country's clock to when its fertility fell below four children,"  0,0
#   b2 "and the curves line up."                                                  4,2
#   b3 "The road is shared; the speed is not."                                    6,2
#   b4 "China went from five to three children in 5 years; Egypt took 33."        9,2
#      dentro de b4, "Egypt took 33" empieza al 67 % (5,5 s de 8,2 s)  → 14,0 → fin 16,4
BLOQUES_S2B1 <- c(0, 4.2, 6.2, 9.2)
DURACION_S2B1 <- 16.4
FRAC_EGIPTO <- 0.67

# =============================================================================
# 4. Exportación: PNG (ragg) y MP4 (fotogramas → ffmpeg del venv)
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
  cand <- Sys.getenv("FFMPEG")
  py <- file.path(RUTA_VENV, "bin", "python")
  if (file.exists(py)) {
    r <- tryCatch(suppressWarnings(system2(py, c("-c", shQuote("import imageio_ffmpeg;print(imageio_ffmpeg.get_ffmpeg_exe())")),
                                           stdout = TRUE, stderr = FALSE)), error = function(e) character(0))
    if (length(r) > 0) cand <- c(cand, r[length(r)])
  }
  cand <- c(cand, Sys.which("ffmpeg"))
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
  list(mp4 = ruta_mp4, ultimo = rutas[n], n = n, dir = dir_tmp)
}

#' Compara dos PNG (deben ser idénticos píxel a píxel).
mismo_png <- function(a, b) {
  ia <- png::readPNG(a); ib <- png::readPNG(b)
  identical(dim(ia), dim(ib)) && max(abs(ia - ib)) < 1e-9
}

#' Recorta curvas (id, x, y; x creciente dentro de cada id) a [xmin, xmax] interpolando
#' los extremos: así ninguna curva se sale del panel aunque el lienzo tenga clip = "off".
recortar_x <- function(d, xmin, xmax) {
  partes <- lapply(split(d, d$id), function(g) {
    x <- g$x; y <- g$y; dentro <- x >= xmin & x <= xmax
    if (!any(dentro)) return(NULL)
    i1 <- min(which(dentro)); i2 <- max(which(dentro))
    out <- g[i1:i2, c("id", "x", "y")]
    if (i1 > 1) out <- rbind(data.frame(id = g$id[1], x = xmin,
                                        y = stats::approx(x[(i1 - 1):i1], y[(i1 - 1):i1], xout = xmin)$y), out)
    if (i2 < length(x)) out <- rbind(out, data.frame(id = g$id[1], x = xmax,
                                                     y = stats::approx(x[i2:(i2 + 1)], y[i2:(i2 + 1)], xout = xmax)$y))
    out
  })
  do.call(rbind, partes)
}

# =============================================================================
# 5. fig04 — "Same road, different clock" (registro por hitos, animación A → B)
# =============================================================================
#
# Coordenada horizontal común u (ejes FIJOS entre fotogramas):
#   calendario: u = año − cal0  (cal0 = mediana de c4 de los 57 con ventana completa, ≈ 1990)
#   alineado:   u = año − c4    (= tau, años desde el último cruce de 4)
#   fotograma:  u = año − cal0 − s · (c4 − cal0), con s = 0 → 1 (deslizamiento horizontal)
# La banda P10–P90 y la mediana (57 países, tau −20..20) ocupan las mismas u en las dos
# vistas: solo se interpolan sus valores (calendario → alineado), por eso "se estrecha".
#
# Tres versiones (corrección del revisor, ronda 1):
#   video  1760×416 (MP4 + póster): héroe del paso s2.b1. La VELOCIDAD se ve como LONGITUD:
#          un carril abajo a la izquierda (zona vacía: tau < 0 y TFR < 3,7 por construcción,
#          y bajo la curva más baja para tau > 0) con una barra por país de tau(5) a tau(3),
#          que se dibuja a ritmo constante (20 años/s) cuando la voz nombra al país, y su
#          etiqueta "CHN · 5 years (fastest to reach 3)" a la izquierda de la barra.
#   print  774×243 (PDF): mismo carril, texto de 18 px, clave del 57 en un bloque arriba a
#          la derecha (zona vacía: tau > 0 y TFR > 4, c4 es el ÚLTIMO cruce de 4).
#   small  774×183 (ranura final del vídeo en s2.b2–b4; slides funde el <video> a este PNG):
#          sin carril (no cabe a 18 px); etiquetas de una línea "CHN · 5 yrs" arriba a la
#          derecha con guía desde el cruce de 3; ticks x cada 20 años; clave corta.
# En todas: "thick" significa solo el tramo 5 → 3; la mediana es "blue line"; la banda y la
# mediana dicen que salen de los 57 países con 20 años de datos a cada lado; nota gris "all
# curves meet here by design" junto a (0, 4) en el estado alineado (el pellizco es mecánico).

U_MIN <- -41
U_MAX <- 37

tam_04 <- function(modo) {
  switch(modo,
    video = list(eje = 26, titulo = 26, clave = 24, iso = 28, rol = 26, nota = 22, gap_eje = 8,
                 mar = c(t = 68, r = 16, b = 72, l = 50), ylim = c(0, 8.6), y_ticks = 2:8,
                 y_rejilla = c(2, 3, 5, 6, 7, 8), x_paso = 10, carril = TRUE,
                 filas_cab = c(15, 46),       # centro de cada fila de la cabecera (px desde arriba)
                 lw_fondo = 1.4, lw_res = 3.4, lw_tramo = 8, lw_mediana = 6.5, d_cruce = 7, d_hito = 13,
                 lw_guia = 1.6, lw_barra = 5, alto_remate = 14, sep_carril = 34),
    print = list(eje = 18, titulo = 18, clave = 18, iso = 18, rol = 18, nota = 18, gap_eje = 5,
                 mar = c(t = 28, r = 8, b = 48, l = 26), ylim = c(0, 8.6), y_ticks = 2:8,
                 y_rejilla = c(2, 3, 5, 6, 7, 8), x_paso = 10, carril = TRUE, filas_cab = 14,
                 lw_fondo = 0.9, lw_res = 2.6, lw_tramo = 5.5, lw_mediana = 4.5, d_cruce = 5, d_hito = 9,
                 lw_guia = 1.2, lw_barra = 3.5, alto_remate = 8, sep_carril = 20),
    small = list(eje = 18, titulo = 18, clave = 18, iso = 18, rol = 18, nota = 18, gap_eje = 4,
                 mar = c(t = 28, r = 8, b = 46, l = 26), ylim = c(0.4, 8.6), y_ticks = c(2, 4, 6, 8),
                 y_rejilla = c(2, 6, 8), x_paso = 20, carril = FALSE, filas_cab = 14,
                 lw_fondo = 0.8, lw_res = 2.2, lw_tramo = 4.5, lw_mediana = 3.5, d_cruce = 4, d_hito = 8,
                 lw_guia = 1.1))
}

#' Instantes de la animación de fig04 (s), sincronizados con los bloques de la voz.
tiempos_04 <- function() {
  b <- inicios_bloques("s2.b1", BLOQUES_S2B1)
  # corrector-final 2026-10-25: el MP4 termina 0,3 s antes del fin del paso (build_narration.py exige
  # paso ≥ MP4 + 0,3 s; con MP4 = paso, cada regeneración alargaría el paso 0,3 s)
  dur <- duracion_paso("s2.b1", DURACION_S2B1) - 0.3
  d_desl <- min(2.4, max(1.2, b[3] - b[2] + 0.4))
  egy <- b[4] + FRAC_EGIPTO * (dur - b[4])
  list(dur = dur, b = b,
       cruce = b[1] + 2.6,          # "...fell below four children": línea de 4 y puntos de cruce
       banda = b[1] + 3.4,          # banda P10–P90 (calendario, ancha)
       # las etiquetas ISO3 del calendario se apagan ANTES de deslizar (no viajan con las curvas)
       etq_out = b[2] - 0.25, d_etq_out = 0.22,
       desliza = b[2], d_desliza = d_desl,   # "and the curves line up"
       # eje x: las etiquetas de calendario se apagan al empezar a deslizar y las de "years
       # since" se encienden al final (sin fundido cruzado: dos juegos superpuestos no se leen)
       ejes_out = b[2], d_ejes_out = 0.35 * d_desl, ejes_in = b[2] + 0.6 * d_desl, d_ejes_in = 0.4 * d_desl,
       mediana = b[2] + d_desl,     # "The road is shared"
       atenua = b[3] + 1.6,         # "the speed is not"
       chn = b[4] + 0.3,            # "China went from five to three children in N years"
       egy = egy,                   # "Egypt took N"
       col = min(dur - 1.1, egy + 1.2),   # el mediano (regla), sin voz: al final
       ritmo_barra = 20)            # años de barra por segundo (mismo ritmo para los tres)
}

#' Prepara lo que no cambia entre fotogramas (curvas, carril, etiquetas, textos).
preparar_04 <- function(D, modo) {
  TM <- tam_04(modo)
  W <- RANURAS[[c(video = "fig04", print = "fig04_print", small = "fig04_small")[[modo]]]]
  L <- nuevo_lienzo(W[["w"]], W[["h"]], TM$mar, c(U_MIN, U_MAX), TM$ylim)
  dx <- L$dx; dy <- L$dy
  cal0 <- D$cal0
  curvas <- D$reg |> transmute(id = .data$ISO3_code, Time = .data$Time, y = .data$tfr_suav, c4 = .data$c4) |>
    arrange(.data$id, .data$Time)
  cruces <- curvas |> distinct(.data$id, .data$c4)
  R <- D$resaltes
  hl <- R$ISO3_code
  rol_txt <- c(fastest = "fastest to reach 3", median = "median", slowest = "slowest to reach 3")[R$rol]

  # Tramo 5 → 3 de cada resaltado (en años calendario; se mueve con su curva)
  tramos <- bind_rows(lapply(seq_len(nrow(R)), function(k) {
    cu <- curvas[curvas$id == R$ISO3_code[k], ]
    dentro <- cu[cu$Time > R$c5[k] & cu$Time < R$c3[k], c("Time", "y")]
    tibble(id = R$ISO3_code[k], Time = c(R$c5[k], dentro$Time, R$c3[k]), y = c(5, dentro$y, 3), c4 = R$c4[k])
  }))

  # Envolvente de las curvas alineadas (interpolada cada 0,1 años) para comprobar zonas vacías.
  al <- split(curvas |> mutate(tau = .data$Time - .data$c4), curvas$id)
  extremo_en <- function(a, b, f = min) {
    xs <- seq(a, b, length.out = max(2, ceiling((b - a) * 10) + 1))
    v <- unlist(lapply(al, function(g) stats::approx(g$tau, g$y, xout = xs, rule = 1)$y))
    v <- v[is.finite(v)]
    if (length(v) == 0) return(if (identical(f, min)) Inf else -Inf)
    f(v)
  }

  n90 <- fmt_clave("n_cruce_tfr4_obs")
  # corrector-final (QA-slides H2): el n de pct_var_fase (57) no es una cifra verificada en pantalla → sin número
  v20 <- as.character(max(abs(D$disp$tau)))        # ventana ±20 años de la banda (parquet)

  # --- Cabecera: filas con título del eje y (izquierda) y clave por partes (derecha) ---
  # Cada parte: texto, color y "cuándo aparece" (uno = siempre; banda; mediana; tramo = al
  # nombrar China). Posiciones FIJAS: la fila se alinea a la derecha con todas sus partes.
  cab <- switch(modo,
    video = list(
      list(izq = NULL,
           txt = c(paste0("grey = the ", n90, " countries ≥ 1 M whose fertility fell below 4 in 1950–2023"),
                   "  ·  thick stretch and bar = from 5 down to 3 children per woman"),
           col = c(COL_TEXTO_2, COL_TINTA), cuando = c("uno", "tramo")),
      list(izq = "children per woman (smoothed)",
           # el calificativo va delante: así, mientras falta la mediana, no queda un hueco en medio
           txt = c(paste0("countries with ", v20, " years of data on each side:  "),
                   "band = middle 80 %", "  ·  blue line = median"),
           col = c(COL_TEXTO_2, COL_NAC_TXT, COL_NAC_TXT), cuando = c("banda", "banda", "mediana"))),
    print = list(
      list(izq = "children per woman",
           txt = c(paste0("grey = ", n90, " countries ≥ 1 M"), "  ·  thick stretch and bar = 5 → 3 children"),
           col = c(COL_TEXTO_2, COL_TINTA), cuando = c("uno", "tramo"))),
    small = list(
      list(izq = "children per woman",
           txt = c(paste0("grey = ", n90, " countries"),
                   "  ·  blue = median and middle 80 %"),
           col = c(COL_TEXTO_2, COL_NAC_TXT), cuando = c("uno", "uno"))))
  for (j in seq_along(cab)) {
    w <- ancho_txt(cab[[j]]$txt, TM$clave)
    w_izq <- if (is.null(cab[[j]]$izq)) 0 else ancho_txt(cab[[j]]$izq, TM$titulo, TRUE)
    avisar_ancho(paste(cab[[j]]$txt, collapse = ""), TM$clave, L$w - w_izq - 24, donde = sprintf("fig04 %s cabecera %d", modo, j))
    cab[[j]]$x <- px_x(L, L$w - L$mar[["r"]] - sum(w)) + c(0, cumsum(w)[-length(w)]) * dx
    cab[[j]]$y <- TM$ylim[2] + (TM$mar[["t"]] - TM$filas_cab[j]) * dy
  }

  # --- Bloque de clave arriba a la derecha (solo print: la cabecera no admite más texto) ---
  bloque <- NULL
  if (modo == "print") {
    bt <- c("band = middle 80 % · blue line = median",
            paste0("(countries with ", v20, " years of data"), "on each side of the crossing)")
    paso_b <- (TM$clave + 1) * dy
    yb <- TM$ylim[2] - (6 + TM$clave / 2) * dy - (seq_along(bt) - 1) * paso_b
    xb <- px_x(L, L$w - L$mar[["r"]] - 2)
    x_izq_b <- xb - max(ancho_txt(bt, TM$clave)) * dx
    if (x_izq_b < 0.3) anotar_problema(sprintf("fig04 print: el bloque de clave invade tau < 0 (%.1f).", x_izq_b))
    bloque <- list(txt = bt, col = c(COL_NAC_TXT, COL_TEXTO_2, COL_TEXTO_2), x = xb, y = yb,
                   abajo = min(yb) - TM$clave / 2 * dy)
  }

  # --- Nota "all curves meet here by design" junto a (0, 4) ---
  nota_txt <- "all curves meet here by design"
  w_nota <- ancho_txt(nota_txt, TM$nota)
  if (modo == "small") {
    # abajo a la izquierda de (0, 4): zona vacía (tau < 0 y TFR < 3,7)
    nota <- list(x = -8 * dx, hjust = 1)
    techo <- extremo_en(nota$x - w_nota * dx, nota$x, min)
    nota$y <- techo - (TM$nota / 2 + 3) * dy
    if (nota$y - TM$nota / 2 * dy < TM$ylim[1]) anotar_problema("fig04 small: la nota de (0, 4) no cabe bajo las curvas.")
  } else {
    # arriba a la derecha de (0, 4): zona vacía por construcción (tau > 0 y TFR > 4)
    nota <- list(x = 10 * dx, hjust = 0, y = 4 + (TM$nota / 2 + if (modo == "print") 4 else 7) * dy)
    if (!is.null(bloque) && nota$y + (TM$nota / 2 + 2) * dy > bloque$abajo)
      anotar_problema("fig04 print: la nota de (0, 4) toca el bloque de clave.")
  }

  # --- Carril de velocidad (video, print): barra de tau(5) a tau(3) y etiqueta a la izquierda ---
  car <- NULL
  if (TM$carril) {
    principal <- paste0(R$ISO3_code, " · ", R$dur_txt, " years")
    papel <- paste0("(", rol_txt, ")")
    w_pri <- ancho_txt(principal, TM$iso, TRUE)
    w_pap <- ancho_txt(papel, TM$rol)
    x_der <- R$tau5 - (10 + TM$alto_remate / 4) * dx           # borde derecho del texto
    x_pap <- x_der                                              # "(papel)" termina aquí
    x_pri <- x_der - (w_pap + 7) * dx                           # "ISO · N years" termina aquí
    x_izq <- x_pri - w_pri * dx
    medio <- max(TM$iso, TM$rol) / 2
    y_car <- rep(NA_real_, nrow(R))
    previo <- Inf
    # De arriba abajo en orden de tau(3): la curva más baja baja con tau, así cada barra queda
    # justo bajo la nube y la siguiente (más larga) debajo, separadas sep_carril px.
    for (k in order(R$tau3)) {
      tope_barra <- extremo_en(R$tau5[k], R$tau3[k] + TM$alto_remate / 2 * dx, min) - (TM$alto_remate / 2 + 4) * dy
      tope_texto <- extremo_en(x_izq[k], x_der[k], min) - (medio + 3) * dy
      y_car[k] <- min(tope_barra, tope_texto, previo - TM$sep_carril * dy)
      previo <- y_car[k]
    }
    if (min(y_car) - medio * dy < TM$ylim[1] - 4 * dy)
      anotar_problema(sprintf("fig04 %s: el carril baja %.0f px por debajo del panel.", modo, (TM$ylim[1] - min(y_car) + medio * dy) / dy))
    if (min(x_izq) < U_MIN) anotar_problema(sprintf("fig04 %s: etiqueta del carril fuera del panel por la izquierda.", modo))
    car <- list(y = y_car, principal = principal, papel = papel, x_pri = x_pri, x_pap = x_pap)
    message(sprintf("  fig04 %s: carril en TFR %s (%s)", modo, paste(sprintf("%.2f", y_car), collapse = " / "),
                    paste(R$ISO3_code, collapse = " / ")))
  }

  # --- Etiquetas de una línea arriba a la derecha con guía al cruce de 3 (solo small) ---
  etq <- NULL
  if (modo == "small") {
    txt <- paste0(R$ISO3_code, " · ", R$dur_txt, " yrs")
    w_e <- ancho_txt(txt, TM$iso, TRUE)
    x_al <- R$tau3 + 6 * dx
    desborda <- x_al + w_e * dx > U_MAX
    x_al[desborda] <- U_MAX - w_e[desborda] * dx
    x_fin <- x_al + w_e * dx
    holgura <- 10 * dx
    paso <- (TM$iso + 5) * dy
    y_top <- TM$ylim[2] - (4 + TM$iso / 2) * dy
    fila <- rep(NA_integer_, nrow(R))
    for (k in order(R$tau3)) {
      for (r in seq_len(nrow(R))) {
        otros <- which(!is.na(fila))
        misma <- otros[fila[otros] == r]
        choca <- any(x_al[k] < x_fin[misma] + holgura & x_fin[k] + holgura > x_al[misma])
        abajo <- otros[fila[otros] > r]
        guia_k <- any(R$tau3[k] > x_al[abajo] - holgura & R$tau3[k] < x_fin[abajo] + holgura)
        arriba <- otros[fila[otros] < r]
        guia_o <- any(R$tau3[arriba] > x_al[k] - holgura & R$tau3[arriba] < x_fin[k] + holgura)
        if (!choca && !guia_k && !guia_o) { fila[k] <- r; break }
      }
      if (is.na(fila[k])) { fila[k] <- nrow(R); anotar_problema(paste("fig04 small: etiqueta sin fila libre:", R$ISO3_code[k])) }
    }
    y_al <- y_top - (fila - 1) * paso
    if (min(y_al) - TM$iso / 2 * dy < 4.05) anotar_problema(sprintf("fig04 small: etiquetas bajan a TFR %.2f (< 4).", min(y_al) - TM$iso / 2 * dy))
    etq <- list(txt = txt, x = x_al, y = y_al)
  }

  # Etiquetas ISO3 en la vista de calendario (solo video): al final de la curva (2023)
  cal <- NULL
  if (modo == "video") {
    fin <- curvas |> filter(.data$id %in% hl) |> group_by(.data$id) |> slice_max(.data$Time, n = 1) |> ungroup()
    fin <- fin[match(hl, fin$id), ]
    sep <- (TM$iso + 4) * dy
    orden <- order(fin$y, decreasing = TRUE)
    y_cal <- fin$y
    for (j in seq_along(orden)[-1]) y_cal[orden[j]] <- min(y_cal[orden[j]], y_cal[orden[j - 1]] - sep)
    cal <- list(x = (fin$Time - cal0) + 10 * dx, y = y_cal)
  }

  # Comprobación de la zona vacía de la derecha (nada se pinta encima de curvas por accidente)
  max_tfr_derecha <- max(curvas$y[(curvas$Time - curvas$c4) > 0])
  if (max_tfr_derecha >= 4) anotar_problema("fig04: hay curvas con TFR >= 4 después del cruce (zona de la nota no vacía).")

  eje_al <- "years since fertility fell below 4 children per woman"
  avisar_ancho(eje_al, TM$titulo, L$pw, TRUE, donde = paste0("fig04 ", modo, " eje"))

  list(TM = TM, L = L, W = W, cal0 = cal0, curvas = curvas, cruces = cruces, tramos = tramos, R = R,
       hl = hl, cab = cab, bloque = bloque, nota = c(nota, txt = nota_txt), car = car, etq = etq, cal = cal,
       eje_al = eje_al, disp = D$disp, modo = modo)
}

#' Dibuja el estado de fig04 en el instante t (s; Inf = estado final = póster).
dibujar_04 <- function(t, P, TT) {
  TM <- P$TM; L <- P$L; cal0 <- P$cal0
  p_cruce <- prog(t, TT$cruce, 0.6)
  p_banda <- prog(t, TT$banda, 0.6)
  p_etq_cal <- 1 - prog(t, TT$etq_out, TT$d_etq_out)    # ISO3 del calendario (se apagan antes de deslizar)
  s       <- prog(t, TT$desliza, TT$d_desliza)
  p_cal   <- 1 - prog(t, TT$ejes_out, TT$d_ejes_out)   # opacidad del eje de calendario
  p_ejes  <- prog(t, TT$ejes_in, TT$d_ejes_in)          # opacidad del eje "years since"
  p_med   <- prog(t, TT$mediana, 0.6)
  p_cero  <- prog(t, TT$desliza + TT$d_desliza - 0.3, 0.5)
  p_aten  <- prog(t, TT$atenua, 0.6)
  t_k <- c(TT$chn, TT$col, TT$egy)                      # orden de R: rápido, mediano, lento
  p_k <- vapply(t_k, function(tk) prog(t, tk, 0.5), numeric(1))
  # Barra de velocidad: crece de tau(5) a tau(3) a ritmo constante (años/s), lineal.
  p_bar <- vapply(seq_along(t_k), function(k) {
    d <- max(0.25, abs(P$R$tau3[k] - P$R$tau5[k]) / TT$ritmo_barra)
    prog(t, t_k[k], d, ease = "linear")
  }, numeric(1))
  # Énfasis por país: al nombrar China se atenúan los otros dos; vuelven al nombrarlos.
  p_chn <- p_k[1]
  alfa_k <- c(1, 1 - 0.68 * p_chn + 0.68 * p_k[2], 1 - 0.68 * p_chn + 0.68 * p_k[3])
  alfa_k[1] <- 1
  a_cuando <- c(uno = 1, banda = p_banda, mediana = p_med, tramo = p_chn)

  desplaza <- function(Time, c4) Time - cal0 - s * (c4 - cal0)
  dy <- L$dy; dx <- L$dx
  g <- base_lienzo(L)

  # --- rejilla horizontal regular (2…8), referencias en 3 y 5 (resaltes) y en 4 ---
  g <- g + annotate("segment", x = U_MIN, xend = U_MAX, y = TM$y_rejilla, yend = TM$y_rejilla,
                    colour = COL_REJILLA, linewidth = lw(1.2))
  p_35 <- max(p_k)
  if (p_35 > 0.001) g <- g + annotate("segment", x = U_MIN, xend = U_MAX, y = c(3, 5), yend = c(3, 5),
                                      colour = COL_EJE, linewidth = lw(1.1), linetype = "13", alpha = p_35)
  col_4 <- mezclar("#B5B5B5", COL_TINTA, p_cruce)
  g <- g + annotate("segment", x = U_MIN, xend = U_MAX, y = 4, yend = 4, colour = col_4,
                    linewidth = lw(1.2 + 0.8 * p_cruce), linetype = "42")

  # --- curvas de contexto ---
  cu <- P$curvas |> mutate(x = desplaza(.data$Time, .data$c4))
  cu_c <- recortar_x(cu |> filter(!.data$id %in% P$hl) |> select("id", "x", "y"), U_MIN, U_MAX)
  col_fondo <- mezclar(COL_FONDO_LINEAS, COL_FONDO_ATENUADO, p_aten)
  g <- g + geom_line(data = cu_c, aes(x = .data$x, y = .data$y, group = .data$id),
                     colour = col_fondo, linewidth = lw(TM$lw_fondo), lineend = "round")

  # --- banda P10–P90 (calendario → alineado) y mediana (57 países con ventana completa) ---
  if (p_banda > 0.001) {
    bd <- P$disp |> transmute(x = .data$tau,
                              lo = (1 - s) * .data$p10_calendario + s * .data$p10_alineado,
                              hi = (1 - s) * .data$p90_calendario + s * .data$p90_alineado)
    g <- g + geom_ribbon(data = bd, aes(x = .data$x, ymin = .data$lo, ymax = .data$hi),
                         fill = COL_NAC, alpha = 0.20 * p_banda, colour = NA)
  }
  if (p_med > 0.001) {
    g <- g + geom_line(data = P$disp, aes(x = .data$tau, y = .data$p50_alineado), colour = COL_NAC,
                       linewidth = lw(TM$lw_mediana), alpha = p_med, lineend = "round")
  }
  # --- línea vertical en 0 (vista alineada) ---
  if (p_cero > 0.001) g <- g + annotate("segment", x = 0, xend = 0, y = TM$ylim[1], yend = TM$ylim[2],
                                        colour = COL_TINTA, linewidth = lw(1.4), linetype = "22", alpha = 0.7 * p_cero)

  # --- puntos de cruce de 4 (convergen en 0) ---
  if (p_cruce > 0.001) {
    cr <- P$cruces |> mutate(x = (.data$c4 - cal0) * (1 - s))
    cr <- cr[cr$x >= U_MIN & cr$x <= U_MAX, ]
    g <- g + geom_point(data = cr, aes(x = .data$x, y = 4), colour = COL_TINTA, alpha = 0.55 * p_cruce,
                        size = tam_punto(TM$d_cruce), shape = 16)
  }

  # --- curvas resaltadas (regla: rápido, mediano, lento) ---
  for (k in seq_along(P$hl)) {
    ck <- recortar_x(cu |> filter(.data$id == P$hl[k]) |> select("id", "x", "y"), U_MIN, U_MAX)
    g <- g + geom_line(data = ck, aes(x = .data$x, y = .data$y), colour = COL_TINTA,
                       linewidth = lw(TM$lw_res), alpha = alfa_k[k], lineend = "round")
  }
  # Tramo 5 → 3 (grueso) + puntos en 5 y 3: aparecen cuando la voz nombra al país.
  # Orden de dibujo: el lento primero, así el punto en 5 del mediano (casi en el mismo
  # tau que el del lento) queda encima y se ven los dos anillos.
  for (k in rev(seq_along(P$hl))) {
    a <- p_k[k] * alfa_k[k]
    if (a <= 0.001) next
    tr <- P$tramos |> filter(.data$id == P$hl[k]) |> mutate(x = desplaza(.data$Time, .data$c4))
    g <- g + geom_line(data = tr, aes(x = .data$x, y = .data$y), colour = COL_TINTA,
                       linewidth = lw(TM$lw_tramo), alpha = a, lineend = "round") +
      annotate("point", x = tr$x[c(1, nrow(tr))], y = c(5, 3), shape = 21, fill = "white", colour = COL_TINTA,
               stroke = lw(2.4), size = tam_punto(TM$d_hito), alpha = a)
  }

  # --- carril de velocidad: barra tau(5) → tau(3) y etiqueta "ISO · N years (papel)" ---
  if (!is.null(P$car)) {
    medio_rem <- TM$alto_remate / 2 * dy
    for (k in seq_along(P$hl)) {
      a <- p_k[k] * alfa_k[k]
      if (a <= 0.001) next
      yk <- P$car$y[k]
      x5 <- P$R$tau5[k]; x3 <- P$R$tau3[k]
      xe <- x5 + p_bar[k] * (x3 - x5)
      g <- g + annotate("segment", x = x5, xend = x5, y = yk - medio_rem, yend = yk + medio_rem,
                        colour = COL_TINTA, linewidth = lw(TM$lw_barra * 0.55), alpha = a)
      if (p_bar[k] > 0.001) g <- g + annotate("segment", x = x5, xend = xe, y = yk, yend = yk, colour = COL_TINTA,
                                              linewidth = lw(TM$lw_barra), alpha = a, lineend = "butt")
      if (p_bar[k] >= 0.999) g <- g + annotate("segment", x = x3, xend = x3, y = yk - medio_rem, yend = yk + medio_rem,
                                               colour = COL_TINTA, linewidth = lw(TM$lw_barra * 0.55), alpha = a)
      g <- g + texto_halo(P$car$x_pri[k], yk, P$car$principal[k], TM$iso, colour = COL_TINTA, hjust = 1,
                          negrita = TRUE, alpha = a) +
        texto_halo(P$car$x_pap[k], yk, P$car$papel[k], TM$rol, colour = COL_TEXTO_2, hjust = 1, alpha = a)
    }
  }

  # --- etiquetas de una línea con guía al cruce de 3 (small) ---
  if (!is.null(P$etq)) {
    for (k in seq_along(P$hl)) {
      a <- p_k[k] * alfa_k[k]
      if (a <= 0.001) next
      g <- g + annotate("segment", x = P$R$tau3[k], xend = P$R$tau3[k], y = 3 + (TM$d_hito / 2 + 2) * dy,
                        yend = P$etq$y[k] - (TM$iso / 2 + 3) * dy, colour = COL_TINTA, linewidth = lw(TM$lw_guia),
                        alpha = 0.75 * a) +
        texto(P$etq$x[k], P$etq$y[k], P$etq$txt[k], TM$iso, colour = COL_TINTA, negrita = TRUE, alpha = a)
    }
  }

  # --- ISO3 en la vista de calendario (fijas al final de su curva; se apagan antes de deslizar) ---
  if (!is.null(P$cal) && p_etq_cal > 0.001) {
    for (k in seq_along(P$hl)) g <- g + texto(P$cal$x[k], P$cal$y[k], P$hl[k], TM$iso, colour = COL_TINTA,
                                              negrita = TRUE, alpha = p_etq_cal)
  }

  # --- nota del pellizco en (0, 4): mecánico, no un hallazgo ---
  if (p_cero > 0.001) g <- g + texto_halo(P$nota$x, P$nota$y, P$nota$txt, TM$nota, colour = COL_TEXTO_2,
                                          hjust = P$nota$hjust, alpha = p_cero)

  # --- bloque de clave arriba a la derecha (print) ---
  if (!is.null(P$bloque)) {
    for (j in seq_along(P$bloque$txt)) g <- g + texto_halo(P$bloque$x, P$bloque$y[j], P$bloque$txt[j], TM$clave,
                                                          colour = P$bloque$col[j], hjust = 1)
  }

  # --- eje y (izquierda): 2…8 regulares; 3/4/5 resaltados ---
  x_ty <- px_x(L, L$mar[["l"]] - 10)
  ty <- setdiff(TM$y_ticks, c(3, 4, 5))
  g <- g + texto(x_ty, ty, as.character(ty), TM$eje, colour = COL_TEXTO_2, hjust = 1)
  g <- g + texto(x_ty, 4, "4", TM$eje, colour = mezclar(COL_TEXTO_2, COL_TINTA, p_cruce), hjust = 1, negrita = p_cruce > 0.5)
  t35 <- intersect(c(3, 5), TM$y_ticks)
  if (length(t35) > 0) g <- g + texto(x_ty, t35, as.character(t35), TM$eje,
                                      colour = mezclar(COL_TEXTO_2, COL_TINTA, p_35), hjust = 1)

  # --- cabecera: título del eje y + clave por partes ---
  for (fila in P$cab) {
    if (!is.null(fila$izq)) g <- g + texto(px_x(L, 0), fila$y, fila$izq, TM$titulo, colour = COL_TINTA, negrita = TRUE)
    for (j in seq_along(fila$txt)) {
      a <- a_cuando[[fila$cuando[j]]]
      g <- g + texto(fila$x[j], fila$y, fila$txt[j], TM$clave, colour = fila$col[j], alpha = a)
    }
  }

  # --- eje x (abajo): calendario ↔ años desde el cruce ---
  y_tick <- px_y(L, L$mar[["b"]] - TM$gap_eje - TM$eje / 2)
  y_tit  <- px_y(L, L$mar[["b"]] - TM$gap_eje - TM$eje - TM$gap_eje - TM$titulo / 2)
  u_al <- seq(-40, 30, by = TM$x_paso)
  et_al <- ifelse(u_al > 0, paste0("+", u_al), ifelse(u_al < 0, paste0("−", abs(u_al)), "0"))
  if (P$modo == "video" && p_cal > 0.001) {
    anios <- seq(1950, 2020, by = 10)
    g <- g + texto(anios - cal0, y_tick, as.character(anios), TM$eje, colour = COL_TEXTO_2, hjust = 0.5, alpha = p_cal) +
      texto(mean(L$xlim), y_tit, "calendar year", TM$titulo, colour = COL_TINTA, hjust = 0.5, negrita = TRUE, alpha = p_cal)
  }
  if (p_ejes > 0.001) {
    g <- g + texto(u_al[u_al != 0], y_tick, et_al[u_al != 0], TM$eje, colour = COL_TEXTO_2, hjust = 0.5, alpha = p_ejes) +
      texto(0, y_tick, "0", TM$eje, colour = COL_TINTA, hjust = 0.5, negrita = TRUE, alpha = p_ejes) +
      texto(mean(L$xlim), y_tit, P$eje_al, TM$titulo, colour = COL_TINTA, hjust = 0.5, negrita = TRUE, alpha = p_ejes)
  }
  g
}

#' fig04 en PNG estático: el póster lo deja anim_04(); aquí, la versión del PDF (_print) y la
#' de la ranura final del vídeo (_small, 774×183: slides funde el <video> a ella en s2.b2).
fig_04 <- function(D) {
  rutas <- character(0)
  for (modo in c("print", "small")) {
    message("fig04 — versión ", modo)
    P <- preparar_04(D, modo)
    ruta <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig04"]], "_", modo, ".png"))
    guardar_lienzo(dibujar_04(Inf, P, tiempos_04()), ruta, P$W[["w"]], P$W[["h"]])
    message("  ", ruta)
    rutas <- c(rutas, ruta)
  }
  # Si no se renderiza el MP4, el póster se dibuja aquí con el mismo estado final.
  if (SIN_MP4) {
    Pv <- preparar_04(D, "video")
    ruta_p <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig04"]], ".png"))
    guardar_lienzo(dibujar_04(Inf, Pv, tiempos_04()), ruta_p, Pv$W[["w"]], Pv$W[["h"]])
    message("  ", ruta_p, " (póster sin MP4)")
  }
  invisible(rutas)
}

#' fig04 animada: MP4 sincronizado con la voz + póster PNG = último fotograma.
anim_04 <- function(D) {
  message("fig04 — animación (MP4) y póster")
  P <- preparar_04(D, "video")
  TT <- tiempos_04()
  message(sprintf("  instantes: cruce %.1f · banda %.1f · ISO3 fuera %.1f–%.2f · desliza %.1f–%.1f · mediana %.1f · China %.1f · Egipto %.1f · mediano %.1f · fin %.1f s",
                  TT$cruce, TT$banda, TT$etq_out, TT$etq_out + TT$d_etq_out, TT$desliza, TT$desliza + TT$d_desliza,
                  TT$mediana, TT$chn, TT$egy, TT$col, TT$dur))
  fin_barras <- c(TT$chn, TT$col, TT$egy) + pmax(0.25, abs(P$R$tau3 - P$R$tau5) / TT$ritmo_barra)
  if (max(fin_barras) > TT$dur - 1 / FPS) anotar_problema(sprintf("fig04: una barra de velocidad termina después del MP4 (%.2f s > %.2f s).",
                                                                  max(fin_barras), TT$dur))
  ruta_mp4 <- file.path(RUTA_FIG_ANIMATED, paste0(NOMBRES[["fig04"]], ".mp4"))
  ruta_png <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig04"]], ".png"))
  r <- renderizar_mp4(function(t) dibujar_04(t, P, TT), TT$dur, ruta_mp4, P$W[["w"]], P$W[["h"]])
  file.copy(r$ultimo, ruta_png, overwrite = TRUE)
  guardar_lienzo(dibujar_04(Inf, P, TT), file.path(tempdir(), "poster_04.png"), P$W[["w"]], P$W[["h"]])
  if (!mismo_png(ruta_png, file.path(tempdir(), "poster_04.png"))) anotar_problema("fig04: el póster no coincide con el estado final.")
  # fotogramas de revisión (cruce, antes y durante el deslizamiento, China, Egipto, mediano)
  dir.create(RUTA_REVISION, recursive = TRUE, showWarnings = FALSE)
  unlink(list.files(RUTA_REVISION, pattern = "^fig04_t.*\\.png$", full.names = TRUE))
  for (tt in c(0.5, TT$banda + 0.7, TT$etq_out + TT$d_etq_out, TT$desliza + TT$d_desliza / 2,
               TT$chn + 1.5, TT$egy + 0.8, TT$col + 0.6)) {
    guardar_lienzo(dibujar_04(tt, P, TT), file.path(RUTA_REVISION, sprintf("fig04_t%05.2f.png", tt)), P$W[["w"]], P$W[["h"]])
  }
  unlink(r$dir, recursive = TRUE)
  message(sprintf("  %s (%d fotogramas, %.1f s, %.1f MB)", ruta_mp4, r$n, r$n / FPS, file.size(ruta_mp4) / 1e6))
  message("  ", ruta_png)
  invisible(list(mp4 = ruta_mp4, png = ruta_png, tiempos = TT))
}

# =============================================================================
# 6. fig05 — mortalidad infantil primero (tiempo de evento)
# =============================================================================
#
# Mismo reloj que fig04 pero con el INICIO de la caída duradera de la fecundidad (regla de
# Princeton) como año 0. Medianas y RIC de Q5 (naranja = defunciones) y TFR (azul =
# nacimientos), cada uno como % de su propio máximo 1950–2023. La flecha/recuadro "child
# mortality had already fallen by about half (q5_drop_at_tfr_onset %)" es HTML (.callout):
# la figura deja vacía la zona de abajo a la izquierda del año 0 para ese recuadro y marca
# con un punto la mediana de Q5 en 0.

fig_05 <- function(D, ranura = "fig05") {
  message("fig05 — ", ranura)
  W <- RANURAS[[ranura]]
  imprimir <- grepl("print", ranura)
  TAM <- list(eje = 18, titulo = 18, clave = 18, etq = 18)
  mar <- c(t = 30, r = 196, b = 48, l = 46)
  L <- nuevo_lienzo(W[["w"]], W[["h"]], mar, xlim = c(-25.6, 30.6), ylim = c(0, 104))
  et <- D$et
  q5 <- et |> filter(.data$variable == "Q5") |> arrange(.data$tau)
  tf <- et |> filter(.data$variable == "TFR") |> arrange(.data$tau)
  dy <- L$dy; dx <- L$dx

  g <- base_lienzo(L) +
    annotate("segment", x = L$xlim[1], xend = L$xlim[2], y = c(50, 100), yend = c(50, 100),
             colour = COL_REJILLA, linewidth = lw(1.2)) +
    annotate("segment", x = L$xlim[1], xend = L$xlim[2], y = 0, yend = 0, colour = "#BDBDBD", linewidth = lw(1.2)) +
    geom_ribbon(data = q5, aes(x = .data$tau, ymin = .data$p25, ymax = .data$p75), fill = COL_Q5, alpha = 0.26) +
    geom_ribbon(data = tf, aes(x = .data$tau, ymin = .data$p25, ymax = .data$p75), fill = COL_NAC, alpha = 0.17) +
    annotate("segment", x = 0, xend = 0, y = 0, yend = 104, colour = COL_TINTA, linewidth = lw(1.6), linetype = "22") +
    geom_line(data = q5, aes(x = .data$tau, y = .data$mediana), colour = COL_Q5, linewidth = lw(4), lineend = "round") +
    geom_line(data = tf, aes(x = .data$tau, y = .data$mediana), colour = COL_NAC, linewidth = lw(4), lineend = "round")
  # Puntos en el año 0 (la mortalidad ya está a la mitad; la fecundidad apenas empieza)
  y0q <- q5$mediana[q5$tau == 0]; y0t <- tf$mediana[tf$tau == 0]
  g <- g + annotate("point", x = 0, y = y0q, shape = 21, fill = "white", colour = COL_Q5_TXT, stroke = lw(3),
                    size = tam_punto(13)) +
    annotate("point", x = 0, y = y0t, shape = 21, fill = "white", colour = COL_NAC_TXT, stroke = lw(2.4),
             size = tam_punto(10))

  # "Flecha en 0" (storyboard §3, build 2): la mortalidad infantil ya cayó a la mitad cuando
  # empieza a caer la fecundidad. Texto en la zona vacía de abajo a la izquierda del año 0
  # (bajo la banda de Q5) y flecha al punto. Cifra = q5_drop_at_tfr_onset (fmt de numbers).
  # El recuadro HTML .callout de slides/index.html dice lo mismo y no cabe en ninguna zona
  # libre de una ranura de 211 px: ver PROBLEMAS (con FIG05_SIN_NOTA=1 se omite esta nota).
  # La cifra solo se imprime si es la MISMA cantidad que marca el punto (caída = 100 − mediana
  # de Q5 en el año 0, % del pico 1950–2023 del parquet de event time), con |dif.| < 0,5. Si
  # q5_drop_at_tfr_onset usa otro denominador (R/02 §5: pico hasta el inicio), la flecha dice
  # solo "about half" (cierto para las dos) y se anota en PROBLEMAS para que Q1 lo unifique.
  caida_punto <- 100 - y0q
  dif_caida <- caida_punto - cifra("q5_drop_at_tfr_onset")
  cifra_ok <- abs(dif_caida) < 0.5
  if (!cifra_ok) anotar_problema(sprintf(paste0(
    "fig05: q5_drop_at_tfr_onset = %.2f %% (caída mediana desde el máximo de Q5 HASTA el inicio, R/02_q1_palancas.R ",
    "§5 l.1119) no es la caída que marca el punto de la flecha: 100 − mediana de Q5 en tau = 0 = %.2f %% (event time ",
    "normalizado por el máximo 1950–2023, R/02 §5.7), dif. %.2f puntos, misma muestra n = %d. La flecha de la figura ",
    "dice solo 'fallen by about half' (sin cifra) hasta que Q1 unifique el denominador; al regenerar, la cifra vuelve ",
    "sola si |dif.| < 0,5. El recuadro HTML .callout (que slides debe ocultar) sigue mostrando %s %%."),
    cifra("q5_drop_at_tfr_onset"), caida_punto, dif_caida, q5$n[q5$tau == 0], fmt_clave("q5_drop_at_tfr_onset")))
  if (!nzchar(Sys.getenv("FIG05_SIN_NOTA"))) {
    nota <- c("child mortality had already",
              if (cifra_ok) paste0("fallen by about half (", fmt_clave("q5_drop_at_tfr_onset"), " %)") else "fallen by about half")
    w_nota <- max(ancho_txt(nota, TAM$etq, TRUE))
    y_lin <- c(10 + TAM$etq * 1.5 + 2, 10 + TAM$etq / 2) * dy   # dos líneas sobre el eje
    tope_txt <- max(y_lin) + (TAM$etq / 2 + 4) * dy
    # borde derecho del texto (años): lo más cerca posible del año 0 sin tocar la banda de Q5
    suelo <- function(xd) min(q5$p25[q5$tau >= floor(xd - w_nota * dx) & q5$tau <= ceiling(xd)])
    cand <- seq(-1.2, -12, by = -0.2)
    ok <- vapply(cand, function(xd) suelo(xd) > tope_txt, logical(1))
    x_der <- if (any(ok)) cand[which(ok)[1]] else -1.2
    techo_banda <- suelo(x_der)
    if (tope_txt > techo_banda) {
      anotar_problema(sprintf("fig05 (%s): la nota del año 0 toca la banda de Q5 (%.0f %% vs %.0f %%).",
                              ranura, tope_txt, techo_banda))
    }
    g <- g + texto(x_der, y_lin, nota, TAM$etq, colour = COL_Q5_TXT, hjust = 1, negrita = TRUE) +
      annotate("curve", x = x_der + 4 * dx, y = max(y_lin), xend = -9 * dx, yend = y0q - 9 * dy,
               curvature = 0.35, colour = COL_Q5_TXT, linewidth = lw(2),
               arrow = grid::arrow(length = unit(7, "pt"), type = "closed", angle = 25))
  }

  # Etiquetas directas al final de las líneas (tau = 30), separadas si hace falta
  y_fin_t <- tf$mediana[tf$tau == max(tf$tau)]; y_fin_q <- q5$mediana[q5$tau == max(q5$tau)]
  alto_bloque <- (2 * TAM$etq + 4) * dy
  y_t <- y_fin_t; y_q <- y_fin_q
  if (y_t - y_q < alto_bloque + 4 * dy) {
    falta <- alto_bloque + 4 * dy - (y_t - y_q)
    y_t <- y_t + falta * 0.65; y_q <- y_q - falta * 0.35
  }
  x_etq <- L$xlim[2] + 10 * dx
  med_lin <- (TAM$etq / 2 + 1) * dy
  g <- g + texto(x_etq, y_t + med_lin, "fertility", TAM$etq, colour = COL_NAC_TXT, negrita = TRUE) +
    texto(x_etq, y_t - med_lin, "children per woman", TAM$etq, colour = COL_NAC_TXT) +
    texto(x_etq, y_q + med_lin, "child mortality", TAM$etq, colour = COL_Q5_TXT, negrita = TRUE) +
    texto(x_etq, y_q - med_lin, "deaths before age 5", TAM$etq, colour = COL_Q5_TXT)
  avisar_ancho(c("children per woman", "deaths before age 5"), TAM$etq, mar[["r"]] - 12, donde = "fig05 etiquetas")

  # Eje y: % del máximo propio
  g <- g + texto(px_x(L, mar[["l"]] - 8), c(0, 50, 100), c("0", "50", "100"), TAM$eje, colour = COL_TEXTO_2, hjust = 1)
  y_top <- L$ylim[2] + (mar[["t"]] / 2 + 1) * dy
  t_y <- "% of each country's own peak, 1950–2023"
  # El número de países cambia con tau (los extremos tienen menos): se declara en la clave.
  n_rango <- range(et$n[et$variable %in% c("Q5", "TFR")])
  # corrector-final (QA-slides H2): "69 to 107" no es una clave verificada → sin números
  clave <- "line = typical country \u00b7 band = middle half of countries"
  g <- g + texto(px_x(L, 0), y_top, t_y, TAM$titulo, colour = COL_TINTA, negrita = TRUE) +
    texto(px_x(L, L$w), y_top, clave, TAM$clave, colour = COL_TEXTO_2, hjust = 1)
  avisar_ancho(paste(t_y, clave), TAM$clave, L$w - 20, donde = "fig05 cabecera")
  avisar_ancho("years before (\u2212) and after (+) fertility began its lasting fall (first 10 % below its peak)",
               TAM$titulo, L$pw, TRUE, donde = "fig05 eje x")

  # Eje x
  y_tick <- px_y(L, mar[["b"]] - 6 - TAM$eje / 2)
  y_tit  <- px_y(L, mar[["b"]] - 6 - TAM$eje - 4 - TAM$titulo / 2)
  xt <- c(-20, -10, 10, 20, 30)
  g <- g + texto(xt, y_tick, ifelse(xt > 0, paste0("+", xt), paste0("−", abs(xt))), TAM$eje,
                 colour = COL_TEXTO_2, hjust = 0.5) +
    texto(0, y_tick, "0", TAM$eje, colour = COL_TINTA, hjust = 0.5, negrita = TRUE) +
    texto(mean(L$xlim), y_tit, "years before (\u2212) and after (+) fertility began its lasting fall (first 10 % below its peak)",
          TAM$titulo, colour = COL_TINTA, hjust = 0.5, negrita = TRUE)

  ruta <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig05"]], if (imprimir) "_print" else "", ".png"))
  guardar_lienzo(g, ruta, W[["w"]], W[["h"]])
  # Posición del año 0 (para el recuadro HTML .callout): fracción del ancho de la imagen
  f0 <- frac_x(L, 0)
  # zona vacía bajo la banda de Q5 a la izquierda de 0 (para el recuadro HTML)
  techo <- max(q5$p25[q5$tau >= -20 & q5$tau <= 0]) ; suelo_banda <- min(q5$p25[q5$tau >= -20 & q5$tau <= 0])
  y_px_suelo <- mar[["b"]] + suelo_banda / dy      # px desde abajo hasta el borde inferior de la banda en 0
  message(sprintf("  %s · año 0 en x = %.1f %% del ancho; banda de Q5 en el año 0 empieza a %.0f px del borde inferior (%.0f %% de la altura)",
                  ruta, 100 * f0, y_px_suelo, 100 * y_px_suelo / L$h))
  invisible(list(ruta = ruta, f0 = f0, y_px_suelo = y_px_suelo, h = L$h, techo = techo))
}

# =============================================================================
# 7. fig06 — dentro del mismo país vs comparando países (mini-forest, 5 filas)
# =============================================================================
#
# Punto negro = asociación dentro del mismo país (cambios de 5 años; efectos fijos de país y
# periodo); línea = IC 95 % por bootstrap por bloques de subregión ONU (el único que puede
# salir en pantalla; el de "All" cruza el 0 y se muestra tal cual). Línea discontinua =
# comparación entre países (panel_between_halfq5). Banda gris clara = placebo (95 % de las
# permutaciones). Se resalta la fila "Low income" (storyboard §3, build 3).

fig_06 <- function(D, ranura = "fig06") {
  message("fig06 — ", ranura)
  W <- RANURAS[[ranura]]
  imprimir <- grepl("print", ranura)
  TAM <- list(fila = 18, eje = 18, valor = 18, ley = 18)
  F <- D$filas
  F$etq <- paste0(F$etiqueta, " (", F$n, ")")
  w_etq <- max(ancho_txt(c(F$etq, "children per woman"), TAM$fila, TRUE))
  entre <- cifra("panel_between_halfq5")
  plo <- cifra("panel_placebo_lo"); phi <- cifra("panel_placebo_hi")
  v_entre <- fmt_clave("panel_between_halfq5")

  # Leyenda (derecha): glifo + texto, en lenguaje llano
  # corrector-final (QA-ethics M · QA-slides B3): la leyenda describe el método, no lo juzga
  ley <- c("dot = within the same country, over time",
           "line = 95 % range (re-runs by UN sub-region)",
           paste0("dashed = comparing countries, ", v_entre),
           "grey band = shuffled data (no link)")
  w_glifo <- 30
  w_ley <- max(ancho_txt(ley, TAM$ley)) + w_glifo
  w_val <- max(ancho_txt(fmt_cifra(F$valor, "+0.00"), TAM$valor, TRUE))
  x_ley <- W[["w"]] - w_ley - 2                       # px desde la izquierda
  mar_r <- W[["w"]] - x_ley + 14 + w_val + 12          # deja la columna de valores entre panel y leyenda
  mar <- if (imprimir) c(t = 8, r = mar_r, b = 52, l = w_etq + 14) else c(t = 5, r = mar_r, b = 26, l = w_etq + 14)
  L <- nuevo_lienzo(W[["w"]], W[["h"]], mar, xlim = c(-2.25, 0.8), ylim = c(0.5, nrow(F) + 0.5))
  if (L$pw < 380) anotar_problema(sprintf("fig06 (%s): el panel solo mide %.0f px de ancho.", ranura, L$pw))
  dy <- L$dy; dx <- L$dx
  F$y <- rev(seq_len(nrow(F)))          # All arriba
  # corrector-final (QA-viz V15): se resalta la fila que narra la voz (todos los países: −0.41 vs −1.05)
  baja <- F$etiqueta == "All countries"

  g <- base_lienzo(L)
  # fila resaltada (Low income): fondo suave desde las etiquetas hasta la columna de valores
  yb <- F$y[baja]
  g <- g + annotate("rect", xmin = px_x(L, 0), xmax = px_x(L, L$w - mar[["r"]] + 14 + w_val + 6),
                    ymin = yb - 0.5, ymax = yb + 0.5, fill = COL_RESALTE_FILA, colour = NA)
  g <- g + annotate("rect", xmin = plo, xmax = phi, ymin = 0.5, ymax = nrow(F) + 0.5, fill = COL_PLACEBO, colour = NA) +
    annotate("segment", x = 0, xend = 0, y = 0.5, yend = nrow(F) + 0.5, colour = "#8C8C8C", linewidth = lw(1.2)) +
    annotate("segment", x = entre, xend = entre, y = 0.5, yend = nrow(F) + 0.5, colour = "#4D4D4D",
             linewidth = lw(2.2), linetype = "22")
  for (i in seq_len(nrow(F))) {
    g <- g + annotate("segment", x = F$lo[i], xend = F$hi[i], y = F$y[i], yend = F$y[i], colour = COL_TEXTO,
                      linewidth = lw(2.8), lineend = "butt") +
      annotate("point", x = F$valor[i], y = F$y[i], shape = 16, colour = COL_TEXTO, size = tam_punto(11))
  }
  # etiquetas de fila y columna de valores
  g <- g + texto(px_x(L, mar[["l"]] - 10), F$y, F$etq, TAM$fila, colour = ifelse(baja, COL_TINTA, COL_TEXTO_2),
                 hjust = 1, negrita = TRUE)
  x_val <- px_x(L, L$w - mar[["r"]] + 14 + w_val)
  g <- g + texto(x_val, F$y, fmt_cifra(F$valor, "+0.00"), TAM$valor, colour = COL_TEXTO, hjust = 1, negrita = TRUE)
  # eje x
  y_tick <- px_y(L, mar[["b"]] - 4 - TAM$eje / 2)
  xt <- c(-2, -1, 0)
  g <- g + texto(xt, y_tick, c("−2", "−1", "0"), TAM$eje, colour = COL_TEXTO_2, hjust = 0.5)
  if (imprimir) {
    y_tit <- px_y(L, mar[["b"]] - 4 - TAM$eje - 6 - TAM$eje / 2)
    g <- g + texto(px_x(L, mar[["l"]] + L$pw / 2), y_tit,
                   "children per woman over the next 20 years, per halving of child mortality",
                   TAM$eje, colour = COL_TINTA, hjust = 0.5, negrita = TRUE)
  } else {
    g <- g + texto(px_x(L, mar[["l"]] - 10), y_tick, "children per woman", TAM$eje, colour = COL_TINTA, hjust = 1, negrita = TRUE)
  }
  avisar_ancho("children per woman", TAM$eje, mar[["l"]] - 12, TRUE, donde = paste("fig06", ranura, "unidad"))

  # leyenda (glifos dibujados en px → datos)
  n_l <- length(ley)
  paso_l <- if (imprimir) 26 else 21
  alto_l <- (n_l - 1) * paso_l
  y0_px <- L$h / 2 + alto_l / 2                       # px desde abajo de la primera línea
  ys <- vapply(seq_len(n_l), function(j) px_y(L, y0_px - (j - 1) * paso_l), numeric(1))
  xg0 <- px_x(L, x_ley); xg1 <- px_x(L, x_ley + 22); xt0 <- px_x(L, x_ley + w_glifo)
  g <- g + annotate("point", x = (xg0 + xg1) / 2, y = ys[1], shape = 16, colour = COL_TEXTO, size = tam_punto(11)) +
    annotate("segment", x = xg0, xend = xg1, y = ys[2], yend = ys[2], colour = COL_TEXTO, linewidth = lw(2.8)) +
    annotate("segment", x = (xg0 + xg1) / 2, xend = (xg0 + xg1) / 2, y = ys[3] - 8 * dy, yend = ys[3] + 8 * dy,
             colour = "#4D4D4D", linewidth = lw(2.2), linetype = "22") +
    annotate("rect", xmin = xg0, xmax = xg1, ymin = ys[4] - 7 * dy, ymax = ys[4] + 7 * dy, fill = COL_PLACEBO, colour = NA)
  g <- g + texto(xt0, ys, ley, TAM$ley, colour = COL_TEXTO_2)

  ruta <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig06"]], if (imprimir) "_print" else "", ".png"))
  guardar_lienzo(g, ruta, W[["w"]], W[["h"]])
  message("  ", ruta)
  invisible(ruta)
}

# =============================================================================
# 8. Simulación de daltonismo (revisión; no son figuras del vídeo)
# =============================================================================

revisar_cvd <- function(rutas) {
  if (!requireNamespace("colorspace", quietly = TRUE)) return(invisible(NULL))
  dir.create(RUTA_REVISION, recursive = TRUE, showWarnings = FALSE)
  for (r in rutas) {
    img <- png::readPNG(r)
    for (tipo in c("deutan", "protan", "tritan")) {
      m <- img
      rgb <- grDevices::rgb(m[, , 1], m[, , 2], m[, , 3])
      sim <- switch(tipo, deutan = colorspace::deutan(rgb), protan = colorspace::protan(rgb), tritan = colorspace::tritan(rgb))
      cc <- grDevices::col2rgb(sim) / 255
      for (k in 1:3) m[, , k] <- matrix(cc[k, ], nrow = dim(img)[1])
      png::writePNG(m[, , 1:3], file.path(RUTA_REVISION, sub("\\.png$", paste0("_cvd_", tipo, ".png"), basename(r))))
    }
  }
  invisible(TRUE)
}

# =============================================================================
# 9. Ejecución
# =============================================================================

D <- leer_datos()
message(sprintf("Datos: %d curvas (cruce de 4 observado), cal0 = %.2f; resaltes %s",
                dplyr::n_distinct(D$reg$ISO3_code), D$cal0,
                paste(sprintf("%s (%s, %s años)", D$resaltes$ISO3_code, D$resaltes$rol, D$resaltes$dur_txt), collapse = " · ")))

salidas <- list()
if ("fig04" %in% SOLO) {
  if (!SIN_MP4) salidas$anim04 <- anim_04(D)
  salidas$fig04 <- fig_04(D)
}
if ("fig05" %in% SOLO) {
  salidas$fig05 <- fig_05(D, "fig05")
  salidas$fig05p <- fig_05(D, "fig05_print")
  if (!nzchar(Sys.getenv("FIG05_SIN_NOTA"))) anotar_problema(sprintf(paste0(
    "fig05 ↔ slides: la figura YA lleva la 'flecha en 0' del storyboard ('child mortality had already fallen ",
    "by about half', con la cifra (%s %%) solo si coincide con el punto; ver el problema del denominador), abajo a la izquierda del año 0, que cae en x = %.1f %% ",
    "del ancho). El recuadro HTML .callout de slides/index.html (blk05) dice lo mismo y, en su sitio por defecto ",
    "(left: var(--tau0-x, 52%%); top: 6%%; slides/css/theme.css:363), tapa la línea azul de fecundidad (89 %% de su ",
    "máximo en el año 0) y no cabe sin tapar datos en ninguna zona libre de la ranura de 211 px (mide ~330×64 px). ",
    "Hace falta ocultarlo: `.s2 .blk05 .callout { display: none; }` (no se tocó slides/: no es de este agente). ",
    "Si slides prefiere el recuadro HTML, regenerar con FIG05_SIN_NOTA=1."),
    fmt_clave("q5_drop_at_tfr_onset"), 100 * salidas$fig05$f0))
}
if ("fig06" %in% SOLO) {
  salidas$fig06 <- fig_06(D, "fig06")
  salidas$fig06p <- fig_06(D, "fig06_print")
}
rutas_png <- list.files(RUTA_FIG_STATIC, pattern = "^fig0[4-6].*\\.png$", full.names = TRUE)
revisar_cvd(rutas_png[!grepl("_print", rutas_png)])

message("\nPROBLEMAS (", length(PROBLEMAS), "):")
for (p in PROBLEMAS) message(" - ", p)
message(sprintf("Listo en %.1f min.", as.numeric(difftime(Sys.time(), t_inicio, units = "mins"))))
