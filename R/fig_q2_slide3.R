#!/usr/bin/env Rscript
# =============================================================================
# fig_q2_slide3.R
# Figuras FINALES de la Slide 3 — Question 2 · P8 · P5 (storyboard v2.1 §4)
#
# Ejecutar desde la raíz del repo:
#   Rscript R/fig_q2_slide3.R              # todo: PNG, _print.png y MP4
#   Rscript R/fig_q2_slide3.R fig07        # solo una figura (fig07 | fig08 | fig09)
#   FIG_SIN_MP4=1 Rscript R/fig_q2_slide3.R   # solo PNG (prueba rápida)
#
# Qué produce (nombres exactos que esperan slides/index.html y slides/js/figs.js):
#   fig07_single_indicator_scorecard  (build 1: "What fertility alone captures")
#     figures/animated/fig07_single_indicator_scorecard.mp4       1144×526, H.264 yuv420p 30 fps
#     figures/static/fig07_single_indicator_scorecard.png         póster = último fotograma
#     figures/static/fig07_single_indicator_scorecard_print.png   1144×742 (ranura PDF real 572×371)
#   fig09_pca_two_dimensions          (build 3: "two independent ways")
#     figures/animated/fig09_pca_two_dimensions.mp4               1248×810, H.264 yuv420p 30 fps
#     figures/static/fig09_pca_two_dimensions.png                 póster = último fotograma
#     figures/static/fig09_pca_two_dimensions_print.png           1248×1026 (ranura PDF 624×513)
#   fig08_lookalikes_twins            (builds 2 y 4: métrica de look-alikes + tarjetas B y A)
#     figures/static/fig08_lookalikes_twins.png                   1072×1112 (columna central 536 de ancho;
#                                                   alto 556 para pie PIE-3/PIE-6 y nota completa)
#     En el deck fig08 es HTML con flag-icons (slides/index.html; README §3 "fig08 es
#     HTML"); este PNG es el "póster PNG para el PDF" que pide el storyboard v2.1 §4 b2,
#     con banderas ggflags + ISO3, como respaldo (y para el README/notebook). Estático.
#
# Contrato con las diapositivas (slides/README.md §3):
#   * Sin título ni subtítulo dentro de la imagen (el titular y las cifras de texto
#     van en HTML desde numbers.json); sí ejes, etiquetas directas, leyendas propias y
#     el badge PIE-3; fondo blanco.
#   * Tamaño = ranura medida × 2 (dev/figure_slots.json; fig07 re-medida con las cifras
#     reales, ver RANURAS). Con res = 144 y la imagen al
#     doble de la ranura, 1 pt de fuente = 1 px de la diapositiva 1920×1080: todos los
#     tamaños de este script (TAM$...) están en px de diapositiva.
#   * Lienzo en píxeles: cada figura se dibuja en un sistema de coordenadas
#     0..ancho × 0..alto (px de la ranura), con ggplot2 + coord_cartesian(expand = FALSE).
#     Así cada etiqueta se coloca a mano y sin solapes (no hay ggrepel que cambie
#     entre fotogramas) y el último fotograma del MP4 es idéntico al póster PNG.
#
# Animación (fotogramas ragg + tweenr → ffmpeg del venv, H.264 yuv420p 30 fps):
#   La animación SEÑALA lo que dice la voz en cada build. Los instantes salen de los
#   bloques de subtítulo del paso (s3.b1 y s3.b3) en slides/script/video_timings.json
#   si ya existe; si no, de la estimación por palabras del guion v2.1 (150 ppm + 1,5 s
#   de aire tras cada cifra hablada), ajustada a la plantilla de tiempos
#   (slides/dev/video_timings.template.json: s3.b1 = 15,4 s → MP4 14,9 s; s3.b3 = 7,0 s
#   → MP4 7,7 s). Volver a correr este script tras grabar la voz re-sincroniza.
#
# Datos (NO se recalcula ningún estadístico; solo se leen resultados):
#   figures/numbers_q2.json                         cifras finales (valor, IC, fmt)
#   data/processed/resultados_q2_scorecard.parquet  comprobación cruzada del scorecard
#   data/processed/resultados_q2_pca_scores.parquet puntos del biplot (PC1, PC2, es_golfo)
#   data/processed/resultados_q2_pca_cargas.parquet correlaciones variable–eje (flechas)
#   data/processed/resultados_q2_pca_autovalores.parquet  inset de autovalores vs ruido
#   data/processed/resultados_q2_gemelos.parquet    comprobación de la pareja UAE–Belarus
#   data/processed/resultados_q2_lookalikes.parquet comprobación de los look-alikes de COL
#   data/processed/resultados_q1.parquet            ISO2 (banderas)
#   data/processed/paises.parquet (vía comun_analisis.R: datos_paises)
#                                                   saldo natural y migración neta 2023 de los
#                                                   gemelos (barras apiladas de crecimiento)
#
# Convención: código y comentarios en español; todo texto visible en inglés llano.
# =============================================================================

t_inicio <- Sys.time()

suppressPackageStartupMessages({
  library(here)
})
source(here::here("R", "config.R"))
source(here::here("R", "utilidades.R"))
source(here::here("R", "comun_analisis.R"))   # paletas v2, badge(), formatear_cifra()

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(arrow)
  library(jsonlite)
  library(ragg)
  library(tweenr)
  library(systemfonts)
})

# =============================================================================
# 0. Constantes de salida, tamaños y colores
# =============================================================================

ESCALA <- 2                       # imagen = 2 × ranura (README §3: "exportar a 2×")
RES <- 72 * ESCALA                # 144 ppp → 1 pt = 1 px de diapositiva
FPS <- 30
NUCLEOS <- max(1L, min(6L, parallel::detectCores() - 2L))
SIN_MP4 <- nzchar(Sys.getenv("FIG_SIN_MP4"))
FUENTE <- "Lato"

# Ranuras medidas en px de diapositiva (slides/README.md §3 y dev/figure_slots.json)
RANURAS <- list(
  # fig07: README §3 / dev/figure_slots.json dicen 572×286 (vídeo) y 572×394 (PDF), medidas
  # con cifras DEMO. Con las cifras reales (numbers_q1/q2/q3.json) los pies HTML bajo la
  # figura ocupan una línea más y la ranura medida en Chromium es 572×263 y 572×371
  # (scratchpad measure_s3.py, 2026-10-23). Se usa la medida real: con object-fit:contain,
  # si la ranura vuelve a crecer la figura queda igual (franja blanca), nunca reducida.
  fig07 = c(w = 572, h = 263), fig07_print = c(w = 572, h = 395),   # print +24 px (corrector-final: pies a 20 px; la ranura del PDF mide 572×487)
  # fig08 no tiene ranura medida (en el deck es HTML): columna central .blk08 en el
  # estado final s3.b4 (captura slides/dev/screenshots/slide_3_final.png ≈ 536 × 463)
  fig08 = c(w = 536, h = 556),
  # corrector-final 2026-10-25 (QA-viz V5): ranuras medidas tras acortar la nota HTML a 2 líneas
  fig09 = c(w = 624, h = 402), fig09_print = c(w = 624, h = 510)
)
NOMBRES <- c(fig07 = "fig07_single_indicator_scorecard",
             fig08 = "fig08_lookalikes_twins",
             fig09 = "fig09_pca_two_dimensions")

# Tamaños de letra (px de diapositiva). Principal ≥ 28 px donde cabe (etiquetas y
# valores del scorecard); secundario ≥ 18 px (mínimo del README §3 a la ranura final).
TAM <- list(principal = 28, valor = 32, eje_titulo = 24, flecha = 22, secundario = 20,
            iso = 19, pie = 18)

# Colores con significado único en el vídeo (storyboard §8; comun_analisis.R §1.5)
COL_TEXTO   <- "#1A1A1A"
COL_TEXTO_2 <- "#555555"          # texto secundario (contraste 7,5:1 sobre blanco)
COL_LENTO   <- COLOR_NACIMIENTOS  # "#0072B2": historia lenta / fertilidad (nacimientos)
COL_RAPIDO  <- "#4D4D4D"          # "fast levers": gris oscuro
COL_MIG     <- COLOR_MIGRACION    # "#56B4E9": migración neta (flecha)
COL_GOLFO   <- unname(PALETA_GRUPOS_V2["Migration-led"])   # "#88CCEE" (Tol)
COL_GOLFO_T <- "#1F6E8C"          # texto/contorno del Golfo (legible sobre blanco)
COL_COL     <- "#111111"          # Colombia y sus look-alikes
COL_PUNTO   <- "#B8B8B8"          # resto de países
COL_REJILLA <- "#E6E6E6"
COL_EJE     <- "#9A9A9A"
COL_EJE_PCA <- "#C2C2C2"          # ejes del biplot: más claros que las flechas que caen encima
COL_RUIDO   <- "#D3D3D3"          # zona de ruido del inset (p95 de las permutaciones)

RUTA_FFMPEG_VENV <- file.path(
  "/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604",
  "scratchpad/venv-jupyter/lib/python3.14/site-packages/imageio_ffmpeg/binaries/ffmpeg-linux-x86_64-v7.0.2"
)
RUTA_TIMINGS <- file.path(RUTA_RAIZ, "slides", "script", "video_timings.json")

# =============================================================================
# 1. Lectura de cifras (solo resultados ya calculados)
# =============================================================================

NUM <- jsonlite::read_json(file.path(RUTA_FIGURAS, "numbers_q2.json"), simplifyVector = TRUE)

#' Devuelve un campo de una clave de numbers_q2.json (para avisar si falta).
cifra <- function(clave, campo = "value") {
  if (is.null(NUM[[clave]])) stop("numbers_q2.json no trae la clave '", clave, "'.", call. = FALSE)
  NUM[[clave]][[campo]]
}

#' Formatea con el mismo `fmt` de numbers.json y el signo menos tipográfico de
#' slides/js/numbers.js (U+2212), para que la figura muestre lo mismo que el HTML.
fmt_cifra <- function(valor, fmt) {
  out <- formatear_cifra(valor, fmt)
  sub("^-", "−", out)
}
fmt_clave <- function(clave, fmt = NULL) fmt_cifra(cifra(clave), if (is.null(fmt)) cifra(clave, "fmt") else fmt)

# --- 1.1 Scorecard: numbers_q2.json manda; el parquet solo se usa para comprobar ---
leer_scorecard <- function() {
  claves <- c(medage = "r2_tfr_medage", chg2050 = "r2_tfr_chg2050",
              growth = "r2_tfr_growth", cnmr = "r2_tfr_cnmr")
  sc <- tibble(
    salida = names(claves), clave = unname(claves),
    valor   = vapply(claves, cifra, numeric(1)),
    ci_low  = vapply(claves, cifra, numeric(1), campo = "ci_low"),
    ci_high = vapply(claves, cifra, numeric(1), campo = "ci_high"),
    cv      = vapply(paste0(claves, "_cv"), cifra, numeric(1)),
    fmt     = vapply(claves, cifra, character(1), campo = "fmt")
  )
  pq <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q2_scorecard.parquet"))
  cmp <- inner_join(sc, pq, by = "salida")
  if (nrow(cmp) != 4 || any(abs(cmp$valor - cmp$r2_adj) > 1e-9) ||
      any(abs(cmp$ci_low.x - cmp$ci_low.y) > 1e-9) || any(abs(cmp$ci_high.x - cmp$ci_high.y) > 1e-9) ||
      any(abs(cmp$cv - cmp$r2_cv10) > 1e-9)) {
    # (si el json y el parquet no coinciden, alguien re-corrió solo una parte)
    stop("numbers_q2.json y resultados_q2_scorecard.parquet no coinciden.", call. = FALSE)
  }
  sc |>
    mutate(
      etiqueta = c("How old the population is", "Population change to 2050",
                   "Growth rate today", "Net migration today"),
      glosa = c("median age: half are older", "UN medium projection", "% a year",
                "arrivals − departures"),
      glosa_larga = c("median age: half the people are older, half younger",
                      "UN medium projection: partly built in (it starts from fertility)",
                      "population growth, % a year, 2023",
                      "arrivals − departures, per 1,000 people, 2023"),
      grupo = c("slow", "slow", "fast", "fast"),
      proyeccion = c(FALSE, TRUE, FALSE, FALSE),
      etiqueta_valor = fmt_cifra(valor, "0.00")
    )
}

# --- 1.2 Biplot: puntos, flechas e inset ----------------------------------------
leer_pca <- function() {
  sc <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q2_pca_scores.parquet"))
  ca <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q2_pca_cargas.parquet"))
  av <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q2_pca_autovalores.parquet")) |>
    filter(.data$caso == "12 fixed indicators") |>
    arrange(.data$componente)
  # Comprobaciones contra numbers_q2.json (las cifras visibles salen del json)
  r_tfr <- ca |> filter(.data$variable == "TFR")
  stopifnot(nrow(sc) == cifra("knn_tfr", "n"),
            abs(r_tfr$r_PC1 - cifra("r_tfr_pc1")) < 1e-6,
            abs(r_tfr$r_PC2 - cifra("r_tfr_pc2")) < 1e-6,
            max(abs(av$autovalor[1:4] - cifra("eigen_pca_12"))) < 1e-3,
            max(abs(av$p95_nulo[1:4] - cifra("eigen_null_p95_12"))) < 1e-3,
            abs(av$var_pct[1] - cifra("pc1_var")) < 1e-6,
            abs(av$var_pct[2] - cifra("pc2_var")) < 1e-6)
  look <- cifra("lookalikes_col_12_iso")
  list(
    puntos = sc |>
      mutate(rol = case_when(.data$ISO3_code == "COL" ~ "col",
                             .data$ISO3_code %in% look ~ "look",
                             .data$es_golfo ~ "golfo",
                             TRUE ~ "resto")),
    cargas = ca,
    autoval = tibble(eje = 1:4, obs = cifra("eigen_pca_12"), ruido = cifra("eigen_null_p95_12"),
                     var_pct = av$var_pct[1:4]),
    look = look
  )
}

# =============================================================================
# 2. Ayudas de lienzo, texto y tiempo
# =============================================================================

#' Tema común de las figuras del vídeo: lienzo blanco, Lato, sin márgenes.
#' (Las figuras se dibujan en px de la ranura; el tema solo fija fondo y fuente.)
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
    tema_dq()
}

#' Ancho de un texto en px de diapositiva (Lato, tamaño en px).
ancho_txt <- function(txt, px, negrita = FALSE) {
  as.numeric(systemfonts::string_width(txt, family = FUENTE, size = px, res = 72,
                                       weight = if (negrita) "bold" else "normal"))
}

#' Avisa si un texto no cabe en el ancho disponible (px de ranura). Se usa en cada
#' texto largo para que ninguna etiqueta se salga de la imagen sin que se note.
AVISOS_ANCHO <- character(0)
avisar_ancho <- function(txt, px, disponible, negrita = FALSE, donde = "") {
  w <- ancho_txt(txt, px, negrita)
  malos <- which(w > disponible)
  for (k in malos) {
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

#' Texto con halo blanco (para etiquetas que caen sobre puntos).
#' (En ggplot2 ≥ 3.5 el `alpha` de geom_label solo afecta al relleno: la transparencia
#' del texto se aplica en el color, para que las etiquetas se desvanezcan igual que el
#' resto del texto en la animación en vez de aparecer de golpe.)
texto_halo <- function(x, y, label, px, colour = COL_TEXTO, hjust = 0, vjust = 0.5,
                       negrita = FALSE, alpha = 1, fondo = 0.82) {
  if (alpha <= 0.001) return(NULL)
  annotate("label", x = x, y = y, label = label, size = px / .pt,
           colour = scales::alpha(colour, alpha),
           hjust = hjust, vjust = vjust, family = FUENTE,
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

# Estimación por palabras (guion v2.1, 150 ppm, 1,5 s de aire tras cifra hablada):
#   s3.b1: "Question two." | "Fertility alone captures the slow story:" |
#          "about three quarters of the differences in how old populations are." (+1,5 s) |
#          "But only 60 percent of today's growth, and almost none of migration."  → 15,4 s
#   s3.b3: "Countries differ in two independent ways." (6 palabras) |
#          "Fertility tracks the first, the transition to fewer births and deaths," (11) |
#          "but misses migration." (3)
#          La plantilla de tiempos da 7,0 s a este paso (storyboard 3:09–3:16; MP4 ≤ 8 s):
#          inicios proporcionales a las palabras dentro de esos 7 s → 0 · 2,1 · 5,9 s.
BLOQUES_S3B1 <- c(0, 1.2, 3.6, 9.5)
BLOQUES_S3B3 <- c(0, 2.1, 5.9)

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
#' Devuelve la ruta del MP4 y la del último fotograma (para compararlo con el póster).
renderizar_mp4 <- function(dibujar, duracion, ruta_mp4, w, h) {
  n <- as.integer(round(duracion * FPS))
  tiempos <- (seq_len(n) - 1) / FPS
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
    # Respaldo: av (libav) con el mismo códec y formato de píxel
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
# 4. fig07 — scorecard "What fertility alone captures" (build 1)
# =============================================================================
#
# Qué muestra: 4 barras horizontales = R² ajustado de una regresión simple sobre la
# fecundidad (161 países ≥ 1 M, 2023), declaradas a priori (H6). Azul = "slow story"
# (edad mediana; cambio a 2050, este con relleno claro y contorno punteado porque es
# proyección Medium de la ONU); gris oscuro = "fast levers" (crecimiento y migración
# neta de hoy). Bigote fino = IC 95 % por bloques de subregión ("plausible range").
# Eje 0–1 completo (sin truncar). Versión _print: + glosas largas, rombo = R² del
# mismo modelo probado en países dejados fuera (VC 10-fold × 20) y pie más completo.
#
# Animación (≈ 15 s, paso s3.b1; bloques de subtítulo b1–b4):
#   b2 "Fertility alone captures the slow story"  → se encienden las filas azules
#   b3 "about three quarters of the differences…" → crece la barra de edad mediana y
#      aparece 0.77; luego la de 2050 (0.88, proyección)
#   b4 "But only 60 percent of today's growth"    → se atenúan las azules, crece la de
#      crecimiento y aparece 0.59; "…almost none of migration" → 0.00 · almost none
#   final: todo vuelve a opacidad completa (= póster PNG).

estado_fig07 <- function(t, b) {
  p <- function(t0, d = 0.5, ease = "cubic-in-out") prog(t, t0, d, ease)
  atenua12 <- 1 - 0.62 * p(b[4], 0.5) + 0.62 * p(b[4] + 4.4, 0.6)
  base <- 0.28 + 0.72 * c(p(b[2]), p(b[2]), p(b[4]), p(b[4] + 3.0))
  list(
    marco    = p(0, 0.4),
    etiqueta = base * c(atenua12, atenua12, 1, 1),
    barra    = c(p(b[3], 1.2), p(b[3] + 2.0, 1.2), p(b[4] + 0.3, 1.2), p(b[4] + 3.0, 0.6)),
    valor    = c(p(b[3] + 1.2, 0.4), p(b[3] + 3.2, 0.4), p(b[4] + 1.5, 0.4), p(b[4] + 3.4, 0.5)) *
               c(atenua12, atenua12, 1, 1),
    tag      = c(slow = p(b[2]) * atenua12, fast = p(b[4])),
    duracion = min(b[4] + 5.4, 14.9)   # ≤ 14,9 s: el paso s3.b1 no se alarga (corrector-final)
  )
}

dibujar_fig07 <- function(t = Inf, version = c("video", "print"), sc = SCORECARD, b = TIEMPOS_FIG07) {
  version <- match.arg(version)
  imp <- version == "print"
  W <- RANURAS[[if (imp) "fig07_print" else "fig07"]][["w"]]
  H <- RANURAS[[if (imp) "fig07_print" else "fig07"]][["h"]]
  # corrector-final 2026-10-26 (QA-slides M10): en el PDF las notas de la figura a ≥ 20 px (copia local de TAM)
  if (imp) TAM$pie <- 20
  e <- estado_fig07(t, b)

  # --- geometría (px de ranura; y crece hacia arriba) ---
  XL <- 6                                              # inicio de las etiquetas
  X0 <- if (imp) 20 else 8; X1 <- 436                  # posición de R² = 0 y R² = 1
  sx <- function(v) X0 + v * (X1 - X0)                 # (X0 > 0: valores < 0 visibles)
  # (filas compactas: la ranura real con cifras finales mide 263 / 371 px de alto)
  paso <- if (imp) 74 else 54
  y_etq <- (H - if (imp) 18 else 16) - (0:3) * paso   # línea de la etiqueta de cada fila
  y_glosa <- y_etq - 24                                # (solo print) glosa larga
  y_bar <- y_etq - if (imp) 49 else 28                 # centro de la barra
  alto_bar <- 20
  y_eje <- y_bar[4] - alto_bar / 2 - 19                # etiquetas de las marcas del eje
  col_g <- ifelse(sc$grupo == "slow", COL_LENTO, COL_RAPIDO)

  g <- lienzo(W, H)

  # rejilla tenue solo a la altura de las barras (no cruza el texto) y línea del 0
  marcas <- c(0.25, 0.5, 0.75, 1)
  for (i in 1:4) {
    g <- g + annotate("segment", x = sx(marcas), xend = sx(marcas), y = y_bar[i] - 14,
                      yend = y_bar[i] + 14, colour = COL_REJILLA, linewidth = 0.6, alpha = e$marco)
  }
  g <- g + annotate("segment", x = sx(c(0, marcas)), xend = sx(c(0, marcas)), y = y_eje + 11,
                    yend = y_eje + 16, colour = COL_EJE, linewidth = 0.6, alpha = e$marco)
  # línea del 0 solo a la altura de cada barra (no atraviesa las etiquetas de fila)
  g <- g + annotate("segment", x = sx(0), xend = sx(0), y = y_bar - alto_bar / 2 - 4,
                    yend = y_bar + alto_bar / 2 + 4, colour = COL_EJE, linewidth = 0.7,
                    alpha = e$marco)
  g <- g + annotate("segment", x = sx(0), xend = sx(0), y = y_eje + 11,
                    yend = y_bar[4] - alto_bar / 2 - 4, colour = COL_EJE, linewidth = 0.7,
                    alpha = e$marco)
  g <- g + texto(sx(c(0, 0.5, 1)), y_eje, c("0 = none", "0.5", "1 = all"), TAM$secundario,
                 COL_TEXTO_2, hjust = c(0, 0.5, 0.5), alpha = e$marco)

  for (i in 1:4) {
    a_e <- e$etiqueta[i]
    # etiqueta principal (28 px) + glosa (20 px en la misma línea; 18 px debajo en print)
    w_etq <- avisar_ancho(sc$etiqueta[i], TAM$principal, W - XL - 4, donde = "fig07 etiqueta")
    g <- g + texto(XL, y_etq[i], sc$etiqueta[i], TAM$principal, COL_TEXTO, alpha = a_e)
    if (!imp) {
      avisar_ancho(sc$glosa[i], TAM$secundario, W - XL - w_etq - 12, donde = "fig07 glosa")
      g <- g + texto(XL + w_etq + 8, y_etq[i] - 1, sc$glosa[i], TAM$secundario, COL_TEXTO_2, alpha = a_e)
    } else {
      avisar_ancho(sc$glosa_larga[i], TAM$pie, W - XL - 4, donde = "fig07 glosa larga")
      g <- g + texto(XL, y_glosa[i], sc$glosa_larga[i], TAM$pie, COL_TEXTO_2, alpha = a_e)
    }

    # barra que crece desde 0 (se atenúa con su fila cuando la voz pasa a otra)
    v <- sc$valor[i] * e$barra[i]
    a_b <- max(e$etiqueta[i], 0.35)
    if (e$barra[i] > 0 && abs(v) > 0.0005) {
      if (sc$proyeccion[i]) {
        # proyección Medium de la ONU: relleno claro + contorno punteado (regla del vídeo)
        g <- g + annotate("rect", xmin = sx(0), xmax = sx(v), ymin = y_bar[i] - alto_bar / 2,
                          ymax = y_bar[i] + alto_bar / 2, fill = scales::alpha(col_g[i], 0.30 * a_b),
                          # corrector-final (QA-viz V11): borde gris discontinuo = convención de proyección
                          colour = scales::alpha("#9A9A9A", a_b), linewidth = 1.2, linetype = "22")
      } else {
        g <- g + annotate("rect", xmin = sx(0), xmax = sx(v), ymin = y_bar[i] - alto_bar / 2,
                          ymax = y_bar[i] + alto_bar / 2, fill = scales::alpha(col_g[i], a_b), colour = NA)
      }
    }

    # bigote fino = IC 95 % por bloques de subregión ("plausible range") + valor
    a_v <- e$valor[i]
    if (a_v > 0.001) {
      g <- g + annotate("segment", x = sx(sc$ci_low[i]), xend = sx(sc$ci_high[i]),
                        y = y_bar[i], yend = y_bar[i], colour = COL_TEXTO, linewidth = 1.2, alpha = a_v)
      g <- g + annotate("segment", x = sx(c(sc$ci_low[i], sc$ci_high[i])),
                        xend = sx(c(sc$ci_low[i], sc$ci_high[i])),
                        y = y_bar[i] - 7, yend = y_bar[i] + 7, colour = COL_TEXTO, linewidth = 1.2,
                        alpha = a_v)
      if (imp) {   # rombo = mismo modelo probado en países dejados fuera (VC 10-fold × 20)
        g <- g + annotate("point", x = sx(sc$cv[i]), y = y_bar[i], shape = 23, size = 4.2,
                          fill = "white", colour = COL_TEXTO, stroke = 1.1, alpha = a_v)
      }
      x_val <- max(sx(sc$valor[i]), sx(sc$ci_high[i])) + 9
      g <- g + texto(x_val, y_bar[i], sc$etiqueta_valor[i], TAM$valor, col_g[i], negrita = TRUE, alpha = a_v)
      if (sc$salida[i] == "cnmr") {
        g <- g + texto(x_val + ancho_txt(sc$etiqueta_valor[i], TAM$valor, TRUE) + 8, y_bar[i] - 1,
                       "almost none", TAM$secundario, COL_TEXTO_2, cursiva = TRUE, alpha = a_v)
      }
    }
  }

  # corchetes de grupo a la derecha: "slow story" (filas 1–2) y "fast levers" (3–4)
  xb <- W - 5
  for (gr in c("slow", "fast")) {
    filas <- if (gr == "slow") 1:2 else 3:4
    a_t <- e$tag[[gr]]
    if (a_t <= 0.001) next
    col_t <- if (gr == "slow") COL_LENTO else COL_RAPIDO
    y_sup <- y_bar[filas[1]] + alto_bar / 2; y_inf <- y_bar[filas[2]] - alto_bar / 2
    g <- g + annotate("segment", x = c(xb, xb - 6, xb - 6), xend = c(xb, xb, xb),
                      y = c(y_inf, y_sup, y_inf), yend = c(y_sup, y_sup, y_inf),
                      colour = col_t, linewidth = 1.2, alpha = a_t)
    g <- g + texto(xb - 10, y_bar[filas[1]], if (gr == "slow") "slow story" else "fast levers",
                   TAM$secundario, col_t, hjust = 1, negrita = TRUE, alpha = a_t)
  }

  # pie: título del eje (R²), leyenda del bigote y badge PIE-3 abreviado
  if (!imp) {
    pie <- "R² · thin line = plausible range · exploratory, not causal"
    avisar_ancho(pie, TAM$pie, W - XL - 4, donde = "fig07 pie")
    g <- g + texto(XL, 9, pie, TAM$pie, COL_TEXTO_2, alpha = e$marco)
  } else {
    pie1 <- "R² · thin line = plausible range (re-runs by UN subregion)"
    pie2 <- "= same model on countries left out · exploratory, not causal"
    avisar_ancho(pie1, TAM$pie, W - XL - 4, donde = "fig07 pie 1")
    avisar_ancho(pie2, TAM$pie, W - XL - 22, donde = "fig07 pie 2")
    g <- g + texto(XL, 37, pie1, TAM$pie, COL_TEXTO_2, alpha = e$marco)
    g <- g + annotate("point", x = XL + 7, y = 12, shape = 23, size = 3.6, fill = "white",
                      colour = COL_TEXTO, stroke = 1, alpha = e$marco)
    g <- g + texto(XL + 18, 12, pie2, TAM$pie, COL_TEXTO_2, alpha = e$marco)
  }
  g
}

fig_07 <- function() {
  rutas <- c(png = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig07"]], ".png")),
             print = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig07"]], "_print.png")))
  guardar_lienzo(dibujar_fig07(Inf, "video"), rutas[["png"]], RANURAS$fig07[["w"]], RANURAS$fig07[["h"]])
  guardar_lienzo(dibujar_fig07(Inf, "print"), rutas[["print"]], RANURAS$fig07_print[["w"]], RANURAS$fig07_print[["h"]])
  message("  fig07 PNG: ", paste(basename(rutas), collapse = ", "))
  rutas
}

anim_07 <- function() {
  dur <- estado_fig07(0, TIEMPOS_FIG07)$duracion
  ruta <- file.path(RUTA_FIG_ANIMATED, paste0(NOMBRES[["fig07"]], ".mp4"))
  r <- renderizar_mp4(function(t) dibujar_fig07(t, "video"), dur, ruta,
                      RANURAS$fig07[["w"]], RANURAS$fig07[["h"]])
  poster <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig07"]], ".png"))
  message(sprintf("  fig07 MP4: %d fotogramas (%.1f s); último fotograma = póster: %s",
                  r$n, r$n / FPS, mismo_png(r$ultimo, poster)))
  r$mp4
}

# =============================================================================
# 4b. fig08 — look-alikes y gemelos (póster estático; en el deck son tarjetas HTML)
# =============================================================================
#
# Qué muestra (mismo contenido y mismas cifras que las tarjetas HTML de s3.b2 y s3.b4):
#   (1) Métrica: de los 5 look-alikes reales de cada país (los 5 más parecidos en 12
#       indicadores estandarizados, 2023), qué parte encuentra cada atajo: la fecundidad
#       sola (knn_tfr, IC 95 % por bloques de subregión), los dos ejes resumen del
#       biplot (knn_pc12, IC) y elegir al azar (knn_chance, exacto: 5 de 160). Eje
#       0–100 % completo (sin truncar).
#   (2) Tarjeta B: Colombia (país del equipo, solo ilustración) — sus 5 parecidos por
#       fecundidad frente a los 5 por 12 indicadores; cuántos tienen en común.
#   (3) Tarjeta A: gemelos por regla (|ΔTFR| ≤ 0,05 con máxima |Δ crecimiento|, ≥ 1 M):
#       misma fecundidad → crecimiento opuesto. Barra de crecimiento APILADA (revisión Q2
#       r1): saldo natural "births − deaths" (#0072B2) + migración neta "arrivals −
#       departures" (#56B4E9), desde paises.parquet 2023. UAE +0,88 + 2,82 = +3,70 (76 %
#       llegadas: la barra ya no sugiere "growing from births"); Belarus −0,62 − 0,03.
#       ISO3 junto a cada bandera ("ARE · UAE", "BLR · Belarus"); flechas ▲ ▼ de 18 px.
#   Pie: PIE-3 abreviado + PIE-6 (el póster puede usarse fuera del deck).
#   Banderas: ggflags (ISO2 en minúsculas) siempre acompañadas del ISO3 (storyboard §8).

leer_fig08 <- function() {
  q1 <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q1.parquet"),
                            col_select = c("ISO3_code", "ISO2_code", "tipo_ab_2023"))
  gem <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q2_gemelos.parquet")) |>
    filter(.data$regla == "R1", .data$rank == 1)
  lk <- arrow::read_parquet(file.path(RUTA_PROCESSED, "resultados_q2_lookalikes.parquet")) |>
    filter(.data$ISO3_code == "COL")
  # Comprobaciones cruzadas: lo visible sale de numbers_q2.json; los parquet deben coincidir
  stopifnot(nrow(gem) == 1, gem$iso_a == "ARE", gem$iso_b == "BLR",
            abs(gem$igual_a - cifra("twin_tfr_are")) < 1e-9,
            abs(gem$igual_b - cifra("twin_tfr_blr")) < 1e-9,
            abs(gem$dif_a - cifra("twin_growth_are")) < 1e-9,
            abs(gem$dif_b - cifra("twin_growth_blr")) < 1e-9,
            nrow(lk) == 1,
            identical(strsplit(lk$vecinos_12, ",")[[1]], cifra("lookalikes_col_12_iso")),
            identical(strsplit(lk$vecinos_tfr, ",")[[1]], cifra("lookalikes_col_tfr_iso")),
            lk$solap_tfr == cifra("lookalikes_col_overlap"))
  ci <- function(clave, campo) { v <- NUM[[clave]][[campo]]; if (is.null(v)) NA_real_ else v }
  iso2 <- function(iso3) {
    out <- tolower(q1$ISO2_code[match(iso3, q1$ISO3_code)])
    if (anyNA(out)) stop("Sin ISO2 para: ", paste(iso3[is.na(out)], collapse = ", "), call. = FALSE)
    out
  }
  tipo <- q1$tipo_ab_2023[match(c("ARE", "BLR"), q1$ISO3_code)]

  # Componentes del crecimiento 2023 (revisión Q2 r1): saldo natural y migración neta
  # en % de la población a 1 de julio, desde paises.parquet (NatChange, NetMigrations,
  # TPopulation1July, miles). La suma no es idéntica a PopGrowthRate de la ONU (que se
  # calcula con las poblaciones a 1 de enero): se comprueba que difiera < 0,01 puntos y
  # se reparte twin_growth_* en proporción a cada componente, para que la barra apilada
  # mida EXACTAMENTE la cifra de numbers_q2.json (ARE +3,704 = 0,88 + 2,82; BLR −0,653
  # = −0,62 − 0,03). Así la barra no atribuye a los nacimientos un crecimiento que en la
  # EAU viene en un 76 % de llegadas.
  comp <- datos_paises |>
    filter(.data$Time == 2023, .data$ISO3_code %in% c("ARE", "BLR")) |>
    transmute(iso3 = .data$ISO3_code,
              nat_bruto = .data$NatChange / .data$TPopulation1July * 100,
              mig_bruto = .data$NetMigrations / .data$TPopulation1July * 100)
  comp <- comp[match(c("ARE", "BLR"), comp$iso3), ]
  crec_json <- c(cifra("twin_growth_are"), cifra("twin_growth_blr"))
  stopifnot(nrow(comp) == 2, !anyNA(comp$nat_bruto), !anyNA(comp$mig_bruto),
            all(abs(comp$nat_bruto + comp$mig_bruto - crec_json) < 0.01),
            all(sign(comp$nat_bruto) == sign(crec_json)), all(sign(comp$mig_bruto) == sign(crec_json)))
  factor_c <- crec_json / (comp$nat_bruto + comp$mig_bruto)
  comp <- comp |> mutate(nat = .data$nat_bruto * factor_c, mig = .data$mig_bruto * factor_c)
  message(sprintf("  fig08 componentes 2023: ARE natural %+.3f + migración %+.3f = %+.3f (%.0f %% llegadas); BLR %+.3f %+.3f = %+.3f",
                  comp$nat[1], comp$mig[1], comp$nat[1] + comp$mig[1], 100 * comp$mig[1] / crec_json[1],
                  comp$nat[2], comp$mig[2], comp$nat[2] + comp$mig[2]))

  list(
    metrica = tibble(
      etiqueta = c("fertility alone", "the two summary axes (biplot)", "picking at random"),
      clave = c("knn_tfr", "knn_pc12", "knn_chance"),
      valor = vapply(c("knn_tfr", "knn_pc12", "knn_chance"), cifra, numeric(1)),
      ci_low = vapply(c("knn_tfr", "knn_pc12", "knn_chance"), ci, numeric(1), campo = "ci_low"),
      ci_high = vapply(c("knn_tfr", "knn_pc12", "knn_chance"), ci, numeric(1), campo = "ci_high"),
      col = c(COL_LENTO, "#3A3A3A", "#9A9A9A")
    ),
    col_tfr = cifra("lookalikes_col_tfr_iso"), col_12 = cifra("lookalikes_col_12_iso"),
    solape = cifra("lookalikes_col_overlap"), iso2 = iso2,
    gemelos = tibble(
      iso3 = c("ARE", "BLR"), nombre = c("UAE", "Belarus"),
      tfr = c(cifra("twin_tfr_are"), cifra("twin_tfr_blr")),
      tfr_txt = c(fmt_clave("twin_tfr_are"), fmt_clave("twin_tfr_blr")),
      crec = crec_json,
      crec_txt = paste0(c(fmt_clave("twin_growth_are"), fmt_clave("twin_growth_blr")), " %"),
      nat = comp$nat, mig = comp$mig,
      tipo = tipo
    ),
    n_pares = fmt_clave("n_pairs_twins")
  )
}

#' Bandera redonda (ggflags) con anillo gris fino, para que el blanco de la bandera
#' no se pierda sobre el fondo blanco. `diam` en px de diapositiva.
bandera <- function(x, y, iso2, diam = 22) {
  list(
    annotate("point", x = x, y = y, shape = 16, size = (diam + 2.4) / .pt, colour = "#B5B5B5"),
    ggflags::geom_flag(data = tibble(x = x, y = y, pais = iso2),
                       aes(x = .data$x, y = .data$y, country = .data$pais),
                       size = diam / 2.42, inherit.aes = FALSE)
  )
}

#' Marco de tarjeta (borde fino como .card del HTML).
marco_tarjeta <- function(y0, y1, W) {
  annotate("rect", xmin = 1, xmax = W - 1, ymin = y0, ymax = y1, fill = "white",
           colour = "#D6D8DC", linewidth = 0.7)
}

dibujar_fig08 <- function(d = FIG08) {
  W <- RANURAS$fig08[["w"]]; H <- RANURAS$fig08[["h"]]
  g <- lienzo(W, H)

  # --- (1) métrica: parte de los 5 look-alikes reales que encuentra cada atajo ---
  m <- d$metrica
  t1 <- "Share of each country's 5 real look-alikes found by"
  t2 <- "real look-alikes = the 5 most similar on 12 indicators, 2023"
  avisar_ancho(t1, TAM$secundario, W - 4, TRUE, donde = "fig08 métrica t1")
  avisar_ancho(t2, TAM$pie, W - 4, donde = "fig08 métrica t2")
  g <- g + texto(2, H - 13, t1, TAM$secundario, COL_TEXTO, negrita = TRUE)
  g <- g + texto(2, H - 37, t2, TAM$pie, COL_TEXTO_2)
  # columna de etiquetas más ancha: "the two summary axes (biplot)" (enlace con fig09)
  X0 <- 276; X1 <- 496; sx <- function(v) X0 + v / 100 * (X1 - X0)
  y_r <- H - 67 - (0:2) * 28; alto <- 16
  avisar_ancho(m$etiqueta, TAM$secundario, X0 - 10, donde = "fig08 métrica etiqueta")
  g <- g + annotate("segment", x = sx(c(50, 100)), xend = sx(c(50, 100)), y = y_r[3] - 14,
                    yend = y_r[1] + 14, colour = COL_REJILLA, linewidth = 0.6)
  g <- g + annotate("segment", x = sx(0), xend = sx(0), y = y_r[3] - 16, yend = y_r[1] + 13,
                    colour = COL_EJE, linewidth = 0.7)
  g <- g + texto(sx(c(0, 50, 100)), y_r[3] - 27, c("0", "50", "100 %"), TAM$pie, COL_TEXTO_2,
                 hjust = c(0.5, 0.5, 0.5))
  for (i in seq_len(nrow(m))) {
    g <- g + texto(2, y_r[i], m$etiqueta[i], TAM$secundario, COL_TEXTO)
    g <- g + annotate("rect", xmin = sx(0), xmax = sx(m$valor[i]), ymin = y_r[i] - alto / 2,
                      ymax = y_r[i] + alto / 2, fill = m$col[i], colour = NA)
    x_val <- sx(m$valor[i]) + 7
    if (is.finite(m$ci_low[i])) {   # bigote = IC 95 % por bloques de subregión
      g <- g + annotate("segment", x = sx(m$ci_low[i]), xend = sx(m$ci_high[i]), y = y_r[i],
                        yend = y_r[i], colour = COL_TEXTO, linewidth = 1.2)
      g <- g + annotate("segment", x = sx(c(m$ci_low[i], m$ci_high[i])),
                        xend = sx(c(m$ci_low[i], m$ci_high[i])), y = y_r[i] - 6, yend = y_r[i] + 6,
                        colour = COL_TEXTO, linewidth = 1.2)
      x_val <- sx(m$ci_high[i]) + 7
    }
    col_txt <- if (m$clave[i] == "knn_chance") COL_TEXTO_2 else m$col[i]
    g <- g + texto(x_val, y_r[i], paste0(fmt_clave(m$clave[i]), " %"), TAM$flecha, col_txt, negrita = TRUE)
  }

  # --- (2) tarjeta B: Colombia ---
  yb1 <- H - 167; yb0 <- yb1 - 146
  g <- g + marco_tarjeta(yb0, yb1, W)
  g <- g + bandera(20, yb1 - 18, d$iso2("COL"), 24)
  g <- g + texto(38, yb1 - 18, "Colombia", TAM$secundario + 2, COL_TEXTO, negrita = TRUE)
  w_col <- ancho_txt("Colombia", TAM$secundario + 2, TRUE)
  g <- g + texto(38 + w_col + 6, yb1 - 18, "COL · its 5 look-alikes", TAM$pie, COL_TEXTO_2)
  filas_b <- list(list(txt = "by fertility alone", iso = d$col_tfr, y = yb1 - 49),
                  list(txt = "by 12 indicators", iso = d$col_12, y = yb1 - 80))
  xf0 <- 168; paso_f <- 73
  for (fb in filas_b) {
    g <- g + texto(12, fb$y, fb$txt, TAM$pie, COL_TEXTO_2)
    xs <- xf0 + (seq_along(fb$iso) - 1) * paso_f
    g <- g + bandera(xs + 11, fb$y, d$iso2(fb$iso), 22)
    g <- g + texto(xs + 26, fb$y, fb$iso, TAM$pie, COL_TEXTO, negrita = TRUE)
  }
  avisar_ancho(d$col_12[5], TAM$pie, W - (xf0 + 4 * paso_f + 26) - 4, TRUE, donde = "fig08 ISO3")
  # nota completa del storyboard v2.1 §4 b2 (posicionalidad + transparencia), en 2 líneas
  nota_b <- c(sprintf("%s in common · Colombia: our home country,",
                      if (d$solape == 0) "none" else paste(d$solape, "of 5")),
              "shown as an illustration; all countries in the repository")
  avisar_ancho(nota_b, TAM$pie, W - 16, donde = "fig08 nota B")
  g <- g + texto(12, yb0 + 40, nota_b[1], TAM$pie, COL_TEXTO_2, cursiva = TRUE)
  g <- g + texto(12, yb0 + 19, nota_b[2], TAM$pie, COL_TEXTO_2, cursiva = TRUE)

  # --- (3) tarjeta A: gemelos por regla ---
  ya0 <- 46; ya1 <- yb0 - 8
  g <- g + marco_tarjeta(ya0, ya1, W)
  ta <- "Twins by rule · same fertility, opposite growth"
  avisar_ancho(ta, TAM$pie, W - 16, TRUE, donde = "fig08 título A")
  g <- g + texto(12, ya1 - 16, ta, TAM$pie, COL_TEXTO, negrita = TRUE)
  gm <- d$gemelos
  y_g <- ya1 - c(90, 120)                               # filas UAE y Belarus
  y_comp <- ya1 - 64                                    # rótulos de los componentes
  # columna 1: hijos por mujer (barras desde 0; 48 px por hijo)
  c1 <- 172; s1 <- 48
  # columna 2: crecimiento % al año = barra apilada saldo natural + migración neta
  # (desde 0, con signo; 27 px por punto). Colores de componente de la Slide 1:
  # azul = births − deaths, celeste = arrivals − departures (PALETA_COMPONENTES_V2).
  c2 <- 326; s2 <- 27
  COL_NAT <- COLOR_NACIMIENTOS; COL_MIG_C <- COLOR_MIGRACION
  COL_MIG_TXT <- "#1C78AD"                              # celeste oscurecido para texto (contraste)
  g <- g + texto(c1 + 52, ya1 - 40, "children per woman", TAM$pie, COL_TEXTO_2, hjust = 0.5)
  g <- g + texto(c2 + 90, ya1 - 40, "growth, % a year", TAM$pie, COL_TEXTO_2, hjust = 0.5)
  g <- g + annotate("segment", x = c(c1, c2), xend = c(c1, c2), y = y_g[2] - 14, yend = y_g[1] + 14,
                    colour = COL_EJE, linewidth = 0.7)
  for (i in 1:2) {
    # bandera + ISO3 + nombre (storyboard §8: banderas siempre con ISO3)
    g <- g + bandera(22, y_g[i], d$iso2(gm$iso3[i]), 24)
    etq <- paste(gm$iso3[i], "·", gm$nombre[i])
    avisar_ancho(etq, TAM$secundario, c1 - 40 - 6, TRUE, donde = "fig08 gemelo")
    g <- g + texto(40, y_g[i], etq, TAM$secundario, COL_TEXTO, negrita = TRUE)
    g <- g + annotate("rect", xmin = c1, xmax = c1 + gm$tfr[i] * s1, ymin = y_g[i] - 9,
                      ymax = y_g[i] + 9, fill = "#3A3A3A", colour = NA)
    g <- g + texto(c1 + gm$tfr[i] * s1 + 6, y_g[i], gm$tfr_txt[i], TAM$secundario, COL_TEXTO, negrita = TRUE)
    # barra apilada: primero el saldo natural (desde 0), luego la migración neta
    x_nat <- c2 + gm$nat[i] * s2; xe <- x_nat + gm$mig[i] * s2
    g <- g + annotate("rect", xmin = min(c2, x_nat), xmax = max(c2, x_nat), ymin = y_g[i] - 9,
                      ymax = y_g[i] + 9, fill = COL_NAT, colour = NA)
    g <- g + annotate("rect", xmin = min(x_nat, xe), xmax = max(x_nat, xe), ymin = y_g[i] - 9,
                      ymax = y_g[i] + 9, fill = COL_MIG_C, colour = NA)
    # flecha ▲/▼ (≥ 18 px) + valor con signo; negativo: rótulo a la derecha del 0
    flecha <- if (gm$crec[i] >= 0) "▲" else "▼"
    x_t <- if (gm$crec[i] >= 0) max(c2, xe) + 6 else c2 + 6
    # (el glifo sale de una fuente de respaldo: systemfonts mide Lato y lo subestima,
    # así que el hueco se fija en 0,85 em + 5 px)
    g <- g + texto(x_t, y_g[i] + 1, flecha, TAM$pie, "#3A3A3A")
    w_f <- 0.85 * TAM$pie + 5
    avisar_ancho(gm$crec_txt[i], TAM$secundario, W - 6 - x_t - w_f, TRUE, donde = "fig08 crecimiento")
    g <- g + texto(x_t + w_f, y_g[i], gm$crec_txt[i], TAM$secundario, COL_TEXTO, negrita = TRUE)
  }
  # rótulos directos de los dos componentes sobre la barra de la EAU (la de Belarus es
  # casi toda saldo natural: −0,62 de −0,65), con una marca fina hasta cada tramo
  x_nat1 <- c2 + gm$nat[1] * s2; xe1 <- x_nat1 + gm$mig[1] * s2
  xm_nat <- (c2 + x_nat1) / 2; xm_mig <- (x_nat1 + xe1) / 2
  g <- g + texto(xm_nat + 6, y_comp, "births − deaths", TAM$pie, COL_NAT, hjust = 1)
  g <- g + texto(x_nat1 + 10, y_comp, "arrivals − departures", TAM$pie, COL_MIG_TXT, hjust = 0)
  avisar_ancho("arrivals − departures", TAM$pie, W - 6 - x_nat1 - 10, donde = "fig08 componente")
  g <- g + annotate("segment", x = c(xm_nat, xm_mig), xend = c(xm_nat, xm_mig), y = y_comp - 9,
                    yend = y_g[1] + 10, colour = c(COL_NAT, COL_MIG_TXT), linewidth = 0.8)
  n1 <- sprintf("chosen by rule from %s pairs (≥ 1 M people): same fertility", d$n_pares)
  n2 <- "(± 0.05), most different growth · UN estimates, 2023"
  avisar_ancho(c(n1, n2), TAM$pie, W - 16, donde = "fig08 nota A")
  g <- g + texto(12, ya0 + 39, n1, TAM$pie, COL_TEXTO_2)
  g <- g + texto(12, ya0 + 17, n2, TAM$pie, COL_TEXTO_2)

  # --- pie: PIE-3 abreviado + PIE-6 (el póster puede usarse fuera del deck) ---
  pie <- c(sprintf("UN WPP 2024 · %s countries ≥ 1 M people, 2023 · exploratory", cifra("knn_tfr", "n")),
           "net migration = arrivals − departures, the least-measured part")
  avisar_ancho(pie, TAM$pie, W - 4, donde = "fig08 pie")
  g <- g + texto(2, 30, pie[1], TAM$pie, COL_TEXTO_2)
  g <- g + texto(2, 10, pie[2], TAM$pie, COL_TEXTO_2)
  g
}

fig_08 <- function() {
  ruta <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig08"]], ".png"))
  guardar_lienzo(dibujar_fig08(FIG08), ruta, RANURAS$fig08[["w"]], RANURAS$fig08[["h"]])
  message("  fig08 PNG: ", basename(ruta))
  ruta
}

# =============================================================================
# 5. fig09 — dos dimensiones (biplot, build 3)
# =============================================================================
#
# Qué muestra: los 161 países ≥ 1 M (2023) en los dos primeros ejes del análisis de
# componentes principales de 12 indicadores (puntos grises; los ejes se cruzan en el
# país medio). Flechas = correlación r de cada indicador con los ejes (una flecha de
# radio R px = r de 1): eje 1 = fertility (azul de nacimientos, r = −0.94), life
# expectancy, median age; eje 2 = net migration (celeste de migración), more men than
# women (razón de sexos) y death rate (hacia abajo; glosa "higher where people are
# older": la tasa bruta sube con el envejecimiento, por eso apunta a la derecha aunque el
# eje 1 sea "fewer … deaths"); y "growth today" (gris oscuro, r = −0.77 / +0.56: el
# único indicador que necesita los dos ejes). 7 de las 12 flechas (dicho en el pie
# print). Resaltes: los 6 Estados del Golfo (color Migration-led) y Colombia con sus 5
# look-alikes de 12 indicadores, encima de las flechas, con línea guía que termina en
# COL. Escalas: x e y en unidades de puntuación, NO iguales (declarado en el pie); las
# flechas sí van a escala 1:1. Pie (vídeo y print): migración neta acotada a ±3 DE en
# 7 países (incl. EAU y Omán, PIE-3). Inset de autovalores frente al p95 de 1 000
# permutaciones solo en la versión print (en el vídeo era ilegible a su tamaño).
#
# Animación (≈ 7,7 s, paso s3.b3 de 7 s; bloques b1–b3):
#   b1 "Countries differ in two independent ways." → aparecen los puntos, Colombia y
#      sus look-alikes (el "solo 2 ejes" lo dice la cabecera HTML)
#   b2 "Fertility tracks the first, the transition…" → se marca el eje 1 y crecen sus
#      3 flechas (fertility primero) y el título del eje 1
#   b3 "but misses migration." → eje 2, sus flechas, el título y los Estados del Golfo
#      se tiñen y se rotulan; al final crece la flecha "growth today" (entre fertility y
#      net migration: el crecimiento necesita las dos dimensiones).

estado_fig09 <- function(t, b) {
  p <- function(t0, d = 0.5, ease = "cubic-in-out") prog(t, t0, d, ease)
  list(
    puntos   = p(0, 0.6),
    colombia = p(0.3, 0.6),
    eje1     = p(b[2], 0.4),
    flecha1  = p(b[2] + 0.2, 1.0),
    etq_tfr  = p(b[2] + 0.8, 0.4),
    etq_1    = p(b[2] + 1.4, 0.4),
    titulo1  = p(b[2] + 1.8, 0.5),
    eje2     = p(b[3], 0.4),
    flecha2  = p(b[3] + 0.1, 0.8),
    etq_2    = p(b[3] + 0.6, 0.4),
    golfo    = p(b[3] + 0.3, 0.6),
    titulo2  = p(b[3] + 0.6, 0.5),
    # "growth today" (r = −0.77 con el eje 1 y +0.56 con el eje 2) al final de "but
    # misses migration": el crecimiento necesita las dos dimensiones (puente con P8)
    flecha_g = p(b[3] + 0.8, 0.6),
    etq_g    = p(b[3] + 1.1, 0.4),
    duracion = b[3] + 1.8
  )
}

#' Geometría del biplot por versión (px de ranura).
#' Abajo, de abajo arriba: pie (2 líneas en vídeo, 3 en print), título del eje 1 y la
#' glosa de "death rate"; por eso el área de puntos empieza en py[1] = 86 / 106.
geom_fig09 <- function(version) {
  imp <- version == "print"
  W <- RANURAS[[if (imp) "fig09_print" else "fig09"]][["w"]]
  H <- RANURAS[[if (imp) "fig09_print" else "fig09"]][["h"]]
  rx <- c(-7.0, 4.7); ry <- c(-3.4, 8.4)               # cubre PC1 −6.5…4.4 y PC2 −3.0…7.9
  # corrector-final 2026-10-26: en print los pies van a 20 px (3 líneas a 22 px); el área de puntos no se mueve
  # (subirla 8 px hacía chocar las etiquetas "net migration" y "growth today")
  px <- c(8, W - 8); py <- c(if (imp) 106 else 86, H - 4)
  list(W = W, H = H, imp = imp, px = px, py = py, R = if (imp) 138 else 112,
       y_pie = if (imp) c(54, 32, 10) else c(32, 12), y_tit1 = if (imp) 77 else 54,
       sx = function(x) px[1] + (x - rx[1]) / diff(rx) * diff(px),
       sy = function(y) py[1] + (y - ry[1]) / diff(ry) * diff(py))
}

# Desplazamiento SOLO de dibujo (px de ranura, ≤ 3 px ≈ 0,06 unidades del eje 1) para que
# Irán y Panamá, casi superpuestos (ΔPC1 = 0,03, ΔPC2 = 0,03), se vean como 2 puntos:
# así se cuentan COL + 5 parecidos. No cambia ningún dato ni el resto de posiciones.
EMPUJE_PCA <- c(IRN = -1, PAN = -3)

dibujar_fig09 <- function(t = Inf, version = c("video", "print"), d = PCA, b = TIEMPOS_FIG09) {
  version <- match.arg(version)
  G <- geom_fig09(version)
  # corrector-final 2026-10-26 (QA-slides M10): en el PDF el pie de la figura va a 20 px (ver el texto del pie)
  e <- estado_fig09(t, b)
  sx <- G$sx; sy <- G$sy
  ox <- sx(0); oy <- sy(0)                             # origen = país medio
  g <- lienzo(G$W, G$H)

  # --- ejes finos que se cruzan en el origen (punta de flecha = dirección) ---
  a1 <- (0.45 + 0.55 * e$eje1) * e$puntos; a2 <- (0.45 + 0.55 * e$eje2) * e$puntos
  g <- g + annotate("segment", x = G$px[1], xend = G$px[2], y = oy, yend = oy,
                    colour = COL_EJE_PCA, linewidth = 0.7 + 0.3 * e$eje1, alpha = a1,
                    arrow = arrow(length = unit(7, "pt"), type = "closed"))
  # (el eje vertical empieza sobre el bloque "death rate / (higher where…)" para no
  # asomar entre sus dos líneas; ningún país queda por debajo de ese punto en x = 0)
  y0_eje2 <- max(G$py[1], oy + d$cargas$r_PC2[d$cargas$variable == "CDR"] * G$R + 13)
  g <- g + annotate("segment", x = ox, xend = ox, y = y0_eje2, yend = G$py[2],
                    colour = COL_EJE_PCA, linewidth = 0.7 + 0.3 * e$eje2, alpha = a2,
                    arrow = arrow(length = unit(7, "pt"), type = "closed"))

  # --- puntos: resto en gris y Golfo (Colombia y sus parecidos van encima de las flechas) ---
  pts <- d$puntos |>
    mutate(X = sx(.data$PC1) + dplyr::coalesce(unname(EMPUJE_PCA[.data$ISO3_code]), 0),
           Y = sy(.data$PC2))
  tam_p <- if (G$imp) 2.6 else 2.3
  lk <- pts |> filter(.data$rol %in% c("look", "col")) |> arrange(.data$rol == "col")
  if (e$puntos > 0) {
    res <- pts |> filter(.data$rol == "resto")
    g <- g + annotate("point", x = res$X, y = res$Y, size = tam_p, colour = COL_PUNTO, alpha = 0.95 * e$puntos)
    gol <- pts |> filter(.data$rol == "golfo")
    g <- g + annotate("point", x = gol$X, y = gol$Y, size = tam_p, colour = COL_PUNTO,
                      alpha = 0.95 * e$puntos * (1 - e$golfo))
    if (e$golfo > 0.001) {
      g <- g + annotate("point", x = gol$X, y = gol$Y, size = tam_p + 1.0 * e$golfo, shape = 21,
                        stroke = 0.9, fill = COL_GOLFO, colour = COL_GOLFO_T, alpha = e$golfo)
    }
    g <- g + annotate("point", x = lk$X, y = lk$Y, size = tam_p, colour = COL_PUNTO,
                      alpha = 0.95 * e$puntos * (1 - e$colombia))
  }

  # --- flechas (r de cada indicador con los ejes; radio R px = r de 1, igual en x e y) ---
  fl <- tibble(
    variable = c("TFR", "LEx", "MedianAgePop", "CNMR", "PopSexRatio", "CDR", "PopGrowthRate"),
    etiqueta = c("fertility", "life expectancy", "median age", "net migration",
                 "more men than women", "death rate", "growth today"),
    eje = c(1, 1, 1, 2, 2, 2, 3)                       # 3 = crecimiento (al final)
  ) |>
    left_join(d$cargas |> select("variable", "r_PC1", "r_PC2"), by = "variable") |>
    mutate(xe = ox + .data$r_PC1 * G$R, ye = oy + .data$r_PC2 * G$R,
           col = case_when(.data$variable == "TFR" ~ COL_LENTO,
                           .data$variable == "CNMR" ~ COL_MIG,
                           .data$variable == "PopGrowthRate" ~ COL_RAPIDO,
                           TRUE ~ "#3A3A3A"),
           col_txt = case_when(.data$variable == "TFR" ~ COL_LENTO,
                               .data$variable == "CNMR" ~ "#1C78AD",
                               .data$variable == "PopGrowthRate" ~ COL_RAPIDO,
                               TRUE ~ "#333333"),
           lw = case_when(.data$variable %in% c("TFR", "CNMR") ~ 2.0,
                          .data$variable == "PopGrowthRate" ~ 1.7, TRUE ~ 1.3),
           clave = .data$variable %in% c("TFR", "CNMR"))
  stopifnot(!anyNA(fl$r_PC1), !anyNA(fl$r_PC2))
  pr_fl <- function(k) switch(as.character(fl$eje[k]), "1" = e$flecha1, "2" = e$flecha2, "3" = e$flecha_g)
  for (k in seq_len(nrow(fl))) {
    pr <- pr_fl(k)
    if (pr <= 0.001) next
    g <- g + annotate("segment", x = ox, y = oy,
                      xend = ox + (fl$xe[k] - ox) * pr, yend = oy + (fl$ye[k] - oy) * pr,
                      colour = fl$col[k], linewidth = fl$lw[k],
                      arrow = arrow(length = unit(if (fl$clave[k]) 9 else 7, "pt"), type = "closed"))
  }
  # etiquetas de flecha junto a la punta (posición fija; halo blanco sobre los puntos).
  # Posiciones elegidas sobre el mapa de puntos para no tapar a Colombia, al Golfo ni a
  # Siria/Ucrania cuando se puede; "life expectancy" y "median age" caen sobre la nube
  # densa de la derecha y llevan halo translúcido.
  for (k in seq_len(nrow(fl))) {
    a <- switch(as.character(fl$eje[k]), "1" = if (fl$variable[k] == "TFR") e$etq_tfr else e$etq_1,
                "2" = e$etq_2, "3" = e$etq_g)
    if (a <= 0.001) next
    px_t <- if (fl$clave[k]) TAM$flecha else TAM$secundario
    w <- ancho_txt(fl$etiqueta[k], px_t, fl$clave[k])
    xe <- fl$xe[k]; ye <- fl$ye[k]
    pos <- switch(fl$variable[k],
      TFR           = c(xe, ye + 18, 0.5),
      # vídeo: a la altura de la punta (no justo debajo del rótulo de COL, para no
      # leerse como uno); print (flecha más larga, la punta cae bajo el rótulo): encima
      # de la punta, con el rótulo de COL más arriba (≥ 20 px de separación)
      LEx           = c(G$W - 8, ye + if (G$imp) 17 else 3, 1),
      MedianAgePop  = c(min(xe + 50, G$W - 8 - w / 2), ye - 17, 0.5),
      CNMR          = c(ox - 8, if (G$imp) 313 else ye + 6, 1),
      PopSexRatio   = c(xe - 9, ye + 12, 1),
      CDR           = c(xe - 9, ye + 3, 1),
      PopGrowthRate = c(xe - 8, ye - 7, 1))
    if (fl$variable[k] == "PopSexRatio" && G$imp) {
      # print: dos líneas para dejar sitio al recuadro de autovalores (arriba a la izquierda)
      g <- g + texto_halo(pos[1], ye + 30, "more men", px_t, fl$col_txt[k], hjust = 1, alpha = a)
      g <- g + texto_halo(pos[1], ye + 10, "than women", px_t, fl$col_txt[k], hjust = 1, alpha = a)
      next
    }
    # sobre la nube densa de la derecha (y sobre Siria, bajo "net migration") el halo es
    # más translúcido: los puntos se siguen viendo
    fondo <- if (fl$variable[k] %in% c("LEx", "MedianAgePop", "CNMR")) 0.6 else 0.82
    g <- g + texto_halo(pos[1], pos[2], fl$etiqueta[k], px_t, fl$col_txt[k], hjust = pos[3],
                        negrita = fl$clave[k], alpha = a, fondo = fondo)
    if (fl$variable[k] == "CDR") {
      # la tasa bruta de mortalidad SUBE con el envejecimiento aunque cada edad muera
      # menos: sin esta glosa, la flecha hacia la derecha contradice "fewer … deaths →"
      glosa <- "(higher where people are older)"
      avisar_ancho(glosa, TAM$pie, pos[1] - 8, donde = "fig09 glosa CDR")
      g <- g + texto(pos[1], ye - 18, glosa, TAM$pie, COL_TEXTO_2, hjust = 1, alpha = a)
    }
  }

  # --- Colombia y sus 5 parecidos: encima de las flechas, con anillo blanco de 1 px ---
  if (e$colombia > 0.001) {
    g <- g + annotate("point", x = lk$X, y = lk$Y, shape = 21, stroke = 0.6,
                      size = ifelse(lk$rol == "col", tam_p + 1.6, tam_p + 0.3),
                      fill = COL_COL, colour = "white", alpha = e$colombia)
    # línea guía que TERMINA en COL: sale hacia arriba a la derecha (≈ 62°), entre Irán/
    # Panamá (encima de COL) e Israel (a la derecha), sin pasar por ningún parecido
    colp <- pts |> filter(.data$rol == "col")
    fin <- c(colp$X, colp$Y) + if (G$imp) c(32, 59) else c(24, 45)
    u <- (fin - c(colp$X, colp$Y)) / sqrt(sum((fin - c(colp$X, colp$Y))^2))
    ini <- c(colp$X, colp$Y) + u * 7
    g <- g + annotate("segment", x = ini[1], y = ini[2], xend = fin[1], yend = fin[2],
                      colour = COL_COL, linewidth = 1.0, alpha = e$colombia)
    g <- g + texto_halo(fin[1] + 4, fin[2] + 3, "+ its 5 look-alikes", TAM$pie, COL_COL, alpha = e$colombia)
    g <- g + texto_halo(fin[1] + 4, fin[2] + 23, "COL", TAM$secundario, COL_COL, negrita = TRUE,
                        alpha = e$colombia)
    avisar_ancho("+ its 5 look-alikes", TAM$pie, G$W - fin[1] - 8, donde = "fig09 COL")
  }
  if (e$golfo > 0.001) {
    gol <- pts |> filter(.data$rol == "golfo")
    dy_iso <- c(QAT = 0, ARE = 0, OMN = 0, BHR = 4, KWT = -1, SAU = -2)
    g <- g + texto(gol$X + 9, gol$Y + dy_iso[gol$ISO3_code], gol$ISO3_code, TAM$iso, COL_GOLFO_T,
                   negrita = TRUE, alpha = e$golfo)
    g <- g + texto(G$W - 8, sy(5.75), "Gulf states", TAM$iso, COL_GOLFO_T, hjust = 1,
                   negrita = TRUE, alpha = e$golfo)
  }

  # --- títulos de los ejes (texto del storyboard) ---
  if (e$titulo1 > 0.001) {
    t1 <- "Axis 1 — the transition (fewer births and deaths) →"
    avisar_ancho(t1, TAM$eje_titulo, diff(G$px), TRUE, donde = "fig09 eje 1")
    g <- g + texto(G$px[1], G$y_tit1, t1, TAM$eje_titulo, COL_TEXTO, negrita = TRUE, alpha = e$titulo1)
  }
  if (e$titulo2 > 0.001) {
    g <- g + texto(ox - 10, G$H - 14, "Axis 2 — migration ↑", TAM$eje_titulo, COL_TEXTO,
                   hjust = 1, negrita = TRUE, alpha = e$titulo2)
    g <- g + texto(ox - 10, G$H - 38, "(and more men than women)", TAM$secundario, COL_TEXTO_2,
                   hjust = 1, alpha = e$titulo2)
    # extremo negativo del eje 2, encima de "death rate" (bloque bajo el eje vertical)
    cdr <- fl |> filter(.data$variable == "CDR")
    g <- g + texto(ox - 10, cdr$ye + 22, "vs ageing ↓", TAM$secundario, COL_TEXTO_2,
                   hjust = 1, cursiva = TRUE, alpha = e$titulo2)
  }

  # --- inset (solo print): autovalor de los ejes 1–4 frente al ruido ---------------
  # En el vídeo se quitó (revisión Q2 r1: a 145 px era ilegible y no hay sitio para
  # 190 × 150 sin tapar etiquetas): el mensaje "Only 2 axes stand out from random noise"
  # ya está en la cabecera HTML de fig09. En print, recuadro de 190 × 154 px: barra =
  # autovalor de cada eje; raya discontinua = p95 de 1 000 permutaciones (lo que alcanza
  # un eje con datos al azar); solo las barras 1–2 la pasan. % de la variación en 1–2.
  if (G$imp) {
    ix0 <- 8; ix1 <- 198; itop <- G$H - 57; ibot <- 304
    g <- g + annotate("rect", xmin = ix0, xmax = ix1, ymin = ibot, ymax = itop,
                      fill = "white", colour = "#C8C8C8", linewidth = 0.6)
    g <- g + texto(ix0 + 8, itop - 14, "Axes vs random noise", TAM$pie, COL_TEXTO, negrita = TRUE)
    av <- d$autoval
    yk <- itop - 40 - (0:3) * 24
    bx0 <- ix0 + 26; lmax <- 112
    sl <- function(v) bx0 + v / max(av$obs) * lmax
    g <- g + texto(ix0 + 12, yk, as.character(1:4), TAM$pie, COL_TEXTO_2, hjust = 0.5)
    for (k in 1:4) {
      sobre <- av$obs[k] > av$ruido[k]
      g <- g + annotate("rect", xmin = bx0, xmax = sl(av$obs[k]), ymin = yk[k] - 7, ymax = yk[k] + 7,
                        fill = if (sobre) "#3A3A3A" else "#A6A6A6", colour = NA)
    }
    g <- g + annotate("segment", x = sl(av$ruido), xend = sl(av$ruido), y = yk - 11, yend = yk + 11,
                      colour = "#1A1A1A", linewidth = 0.9, linetype = "22")
    g <- g + texto(sl(av$obs[1:2]) + 5, yk[1:2], paste0(fmt_cifra(av$var_pct[1:2], "0"), " %"),
                   TAM$pie, COL_TEXTO, negrita = TRUE)
    avisar_ancho(paste0(fmt_cifra(av$var_pct[1], "0"), " %"), TAM$pie, ix1 - sl(av$obs[1]) - 7,
                 TRUE, donde = "fig09 inset")
    # leyenda de la raya: una sola etiqueta
    yl <- yk[4] - 24
    g <- g + annotate("segment", x = ix0 + 12, xend = ix0 + 12, y = yl - 9, yend = yl + 9,
                      colour = "#1A1A1A", linewidth = 0.9, linetype = "22")
    g <- g + texto(ix0 + 20, yl, "random noise (95 %)", TAM$pie, COL_TEXTO_2)
    avisar_ancho("random noise (95 %)", TAM$pie, ix1 - ix0 - 24, donde = "fig09 inset ruido")
  }

  # --- pie: PIE-3 abreviado + winsorización (la que mueve a ARE y OMN) + escalas ---
  capados <- d$puntos |> filter(abs(.data$CNMR_raw - .data$CNMR_w) > 1e-9)
  stopifnot(all(c("ARE", "OMN") %in% capados$ISO3_code))
  # corrector-final (QA-viz V4): n_cnmr_winsorized_2023 tiene verified: false → sin el número
  pie_w <- "migration capped at ±3 SD for a few countries (incl. UAE, Oman)"
  if (!G$imp) {
    pie <- c(sprintf("%d countries ≥ 1 M, 2023 · exploratory, not causal · unequal axis scales",
                     nrow(d$puntos)), pie_w)
  } else {
    pie <- c(sprintf("%d countries ≥ 1 M, 2023 · 12 indicators · exploratory, not causal", nrow(d$puntos)),
             pie_w,
             sprintf("arrows: %d of the 12 indicators · axes not to the same scale", nrow(fl)))
  }
  avisar_ancho(pie, if (G$imp) 20 else TAM$pie, diff(G$px), donde = "fig09 pie")
  g <- g + texto(G$px[1], G$y_pie, pie, if (G$imp) 20 else TAM$pie, COL_TEXTO_2, alpha = e$puntos)
  g
}

fig_09 <- function() {
  rutas <- c(png = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig09"]], ".png")),
             print = file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig09"]], "_print.png")))
  guardar_lienzo(dibujar_fig09(Inf, "video"), rutas[["png"]], RANURAS$fig09[["w"]], RANURAS$fig09[["h"]])
  guardar_lienzo(dibujar_fig09(Inf, "print"), rutas[["print"]], RANURAS$fig09_print[["w"]], RANURAS$fig09_print[["h"]])
  message("  fig09 PNG: ", paste(basename(rutas), collapse = ", "))
  rutas
}

anim_09 <- function() {
  dur <- estado_fig09(0, TIEMPOS_FIG09)$duracion
  ruta <- file.path(RUTA_FIG_ANIMATED, paste0(NOMBRES[["fig09"]], ".mp4"))
  r <- renderizar_mp4(function(t) dibujar_fig09(t, "video"), dur, ruta,
                      RANURAS$fig09[["w"]], RANURAS$fig09[["h"]])
  poster <- file.path(RUTA_FIG_STATIC, paste0(NOMBRES[["fig09"]], ".png"))
  message(sprintf("  fig09 MP4: %d fotogramas (%.1f s); último fotograma = póster: %s",
                  r$n, r$n / FPS, mismo_png(r$ultimo, poster)))
  r$mp4
}

# =============================================================================
# 6. Ejecución
# =============================================================================

SCORECARD <- leer_scorecard()
FIG08 <- leer_fig08()
PCA <- leer_pca()
TIEMPOS_FIG07 <- inicios_bloques("s3.b1", BLOQUES_S3B1)
TIEMPOS_FIG09 <- inicios_bloques("s3.b3", BLOQUES_S3B3)

if (sys.nframe() == 0L) {
  cuales <- commandArgs(trailingOnly = TRUE)
  if (length(cuales) == 0) cuales <- c("fig07", "fig08", "fig09")
  if ("fig07" %in% cuales) { fig_07(); if (!SIN_MP4) anim_07() }
  if ("fig08" %in% cuales) fig_08()
  if ("fig09" %in% cuales) { fig_09(); if (!SIN_MP4) anim_09() }
  message(sprintf("fig_q2_slide3.R listo en %.1f s.", as.numeric(difftime(Sys.time(), t_inicio, units = "secs"))))
}
