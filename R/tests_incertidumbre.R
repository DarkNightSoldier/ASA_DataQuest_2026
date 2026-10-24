#!/usr/bin/env Rscript
# =============================================================================
# tests_incertidumbre.R
# Pruebas rápidas de R/incertidumbre.R y R/comun_analisis.R. FALLA (exit
# status 1) si algo no se cumple, para que ningún agente construya cifras
# sobre una infraestructura rota.
#
# Uso (desde la raíz del repo):
#   Rscript R/tests_incertidumbre.R
#   RUTA_PRUEBAS=/ruta/temporal Rscript R/tests_incertidumbre.R   # dónde escribir el JSON de prueba
#
# Qué prueba:
#   P1  bootstrap iid sobre una media conocida (cobertura y ancho teórico).
#   P2  bootstrap por bloques con datos agrupados: IC más ancho que el iid.
#   P3  reproducibilidad (misma semilla = mismas réplicas) y que el estado
#       global del generador NO cambia al llamar a las funciones.
#   P4  panel: el bootstrap iid remuestrea PAÍSES completos, no filas.
#   P5  errores esperados (bloques con NA, columna inexistente) y búsqueda de
#       columna sin distinguir mayúsculas.
#   P6  datos reales: R² edad mediana ~ TFR 2023 (161 países) frente al memo
#       espacial (0,773; bloques [0,67; 0,84]; iid [0,74; 0,81]).
#   P7  datos reales: H1 (Σ NetMigrations / Σ PopChange, ingreso alto
#       2000-2023) con BCa y jackknife frente al memo de inferencia
#       (70,7 %; BCa [55,8; 114,0]; jackknife 64,5-81,6, EE. UU. el máximo).
#   P8  Wilson frente a prop.test(correct = FALSE) y casos extremos.
#   P9  tipos de palanca 2023 frente al integrador (A 71, B 94, C 18, D 35, E 19).
#   P10 formatear_cifra().
#   P11 registro numbers.json: esquema exacto, validaciones, escritura,
#       relectura idéntica, verificación, fusión con candado y combinación.
# =============================================================================

suppressPackageStartupMessages(library(here))
t_inicio <- Sys.time()
source(here::here("R", "comun_analisis.R"))   # trae incertidumbre.R

cat("== tests_incertidumbre.R ==", format(Sys.time()), "\n")

fallos <- character(0)
n_ok <- 0
marcar_fallo <- function(msg) { cat("FALLA:", msg, "\n"); fallos <<- c(fallos, msg) }
marcar_ok <- function(msg) { cat("OK:", msg, "\n"); n_ok <<- n_ok + 1 }
comprobar <- function(cond, msg) if (isTRUE(cond)) marcar_ok(msg) else marcar_fallo(msg)
# Ejecuta un bloque de pruebas; un error inesperado cuenta como fallo.
prueba <- function(nombre, expr) {
  tryCatch(expr, error = function(e) marcar_fallo(paste0(nombre, ": error inesperado: ", conditionMessage(e))))
}
da_error <- function(expr) inherits(tryCatch({ force(expr); NULL }, error = function(e) e), "error")
da_aviso <- function(expr) {
  w <- FALSE
  withCallingHandlers(tryCatch(force(expr), error = function(e) NULL),
                      warning = function(cnd) { w <<- TRUE; invokeRestart("muffleWarning") })
  w
}

RUTA_PRUEBAS <- Sys.getenv("RUTA_PRUEBAS", file.path(tempdir(), "pruebas_incertidumbre"))
dir.create(RUTA_PRUEBAS, recursive = TRUE, showWarnings = FALSE)
cat("Archivos de prueba en:", RUTA_PRUEBAS, "\n")

media <- function(d) mean(d$x)

# -----------------------------------------------------------------------------
# P1. Bootstrap iid sobre una media conocida
# -----------------------------------------------------------------------------
prueba("P1", {
  set.seed(2026)
  sim <- data.frame(ISO3_code = sprintf("U%03d", 1:200), x = rnorm(200, mean = 10, sd = 2))
  r <- bootstrap_bloques(sim, media, bloque = NULL, B = 2000)
  ancho_teo <- 2 * qnorm(0.975) * sd(sim$x) / sqrt(nrow(sim))
  comprobar(abs(r$valor - mean(sim$x)) < 1e-12, "P1a: valor = media muestral")
  comprobar(r$ci_low < 10 && r$ci_high > 10, sprintf("P1b: IC iid [%.3f; %.3f] contiene la media verdadera 10", r$ci_low, r$ci_high))
  comprobar(abs((r$ci_high - r$ci_low) / ancho_teo - 1) < 0.15,
            sprintf("P1c: ancho del IC (%.3f) ~ teórico 2·1.96·s/√n (%.3f)", r$ci_high - r$ci_low, ancho_teo))
  comprobar(identical(r$method, "bootstrap_perc") && r$B == 2000 && r$seed == 2026 &&
              r$resample_unit == "country" && length(r$replicas) == 2000,
            "P1d: method/B/seed/resample_unit/replicas correctos en el caso iid")
})

# -----------------------------------------------------------------------------
# P2. Bloques con datos agrupados (20 bloques con efecto de bloque)
# -----------------------------------------------------------------------------
prueba("P2", {
  set.seed(2026)
  efecto <- rnorm(20, 0, 2)
  sim <- data.frame(ISO3_code = sprintf("P%03d", 1:200), subregion = rep(sprintf("S%02d", 1:20), each = 10))
  sim$x <- 10 + efecto[as.integer(factor(sim$subregion))] + rnorm(200, 0, 1)
  rb <- bootstrap_bloques(sim, media, B = 1000)                    # bloque = "subregion" por defecto
  ri <- bootstrap_bloques(sim, media, bloque = NULL, B = 1000)
  ratio <- (rb$ci_high - rb$ci_low) / (ri$ci_high - ri$ci_low)
  comprobar(identical(rb$method, "block bootstrap by subregion") && rb$resample_unit == "UN subregion" &&
              rb$n_bloques == 20 && rb$n_unidades == 200,
            "P2a: method = 'block bootstrap by subregion', 20 bloques, 200 unidades")
  comprobar(ratio > 1.5, sprintf("P2b: con datos agrupados el IC por bloques es más ancho (ratio %.2f > 1.5)", ratio))
  comprobar(rb$ci_low < mean(sim$x) && rb$ci_high > mean(sim$x), "P2c: el IC por bloques contiene el valor puntual")
  # estadístico vectorial con nombres + extraer_ic()
  dos <- function(d) c(media = mean(d$x), mediana = median(d$x))
  rv <- bootstrap_bloques(sim, dos, B = 200)
  e2 <- extraer_ic(rv, "mediana")
  comprobar(length(rv$valor) == 2 && identical(names(rv$valor), c("media", "mediana")) &&
              length(e2$valor) == 1 && abs(e2$valor - median(sim$x)) < 1e-12 && length(e2$replicas) == 200,
            "P2d: estadístico vectorial con nombres y extraer_ic()")
})

# -----------------------------------------------------------------------------
# P3. Reproducibilidad y estado global del generador
# -----------------------------------------------------------------------------
prueba("P3", {
  set.seed(1)
  sim <- data.frame(ISO3_code = sprintf("R%02d", 1:60), subregion = rep(letters[1:12], each = 5), x = runif(60))
  a <- bootstrap_bloques(sim, media, B = 300)
  b <- bootstrap_bloques(sim, media, B = 300)
  c2 <- bootstrap_bloques(sim, media, B = 300, semilla = 7)
  comprobar(identical(a$replicas, b$replicas), "P3a: misma semilla -> réplicas idénticas")
  comprobar(!identical(a$replicas, c2$replicas), "P3b: otra semilla -> réplicas distintas")
  set.seed(123); u1 <- runif(3)
  set.seed(123); invisible(bootstrap_bloques(sim, media, B = 50)); invisible(ic_wilson(5, 20)); u2 <- runif(3)
  comprobar(identical(u1, u2), "P3c: las funciones no alteran el flujo global de números aleatorios")
  comprobar(identical(RNGkind()[1:3], c("Mersenne-Twister", "Inversion", "Rejection")),
            "P3d: RNGkind declarado (Mersenne-Twister / Inversion / Rejection)")
})

# -----------------------------------------------------------------------------
# P4. Panel país-año: se remuestrean países completos
# -----------------------------------------------------------------------------
prueba("P4", {
  panel <- expand.grid(ISO3_code = sprintf("C%02d", 1:30), Time = 2000:2004, stringsAsFactors = FALSE)
  panel$subregion <- paste0("S", (as.integer(factor(panel$ISO3_code)) - 1) %/% 3)
  panel$x <- rnorm(nrow(panel))
  completo <- function(d) {
    # cada pseudo-país (ISO3 x copia) debe tener sus 5 años
    tab <- table(interaction(d$ISO3_code, d$.copia, drop = TRUE))
    as.numeric(all(tab == 5))
  }
  ri <- bootstrap_bloques(panel, completo, bloque = NULL, B = 100)
  rb <- bootstrap_bloques(panel, completo, B = 100)
  comprobar(all(ri$replicas == 1) && all(rb$replicas == 1),
            "P4: iid y bloques conservan los 5 años de cada país (unidad = país, no país-año)")
})

# -----------------------------------------------------------------------------
# P5. Errores esperados y columnas sin distinguir mayúsculas
# -----------------------------------------------------------------------------
prueba("P5", {
  sim <- data.frame(ISO3_code = sprintf("E%02d", 1:40), Subregion = rep(c("a", "b", "c", "d", "e", NA), length.out = 40),
                    x = 1:40)
  comprobar(da_error(bootstrap_bloques(sim, media, bloque = "Subregion", B = 50)),
            "P5a: bloques con NA -> error explicativo")
  sim$Subregion[is.na(sim$Subregion)] <- "f"
  r <- suppressMessages(bootstrap_bloques(sim, media, bloque = "subregion", B = 50))
  comprobar(r$n_bloques == 6 && r$method == "block bootstrap by subregion",
            "P5b: 'subregion' encuentra la columna 'Subregion'")
  comprobar(da_error(bootstrap_bloques(sim, media, bloque = "no_existe", B = 50)), "P5c: columna inexistente -> error")
  comprobar(da_error(bootstrap_bca(rbind(sim, sim), media, B = 50)), "P5d: bootstrap_bca() rechaza países duplicados")
})

# -----------------------------------------------------------------------------
# P6. Datos reales: R² edad mediana ~ TFR (2023, 161 países >= 1 M)
# -----------------------------------------------------------------------------
prueba("P6", {
  c23 <- corte_anio(2023, "1m")
  r2 <- function(d) summary(lm(MedianAgePop ~ TFR, data = d))$r.squared
  rb <- bootstrap_bloques(c23, r2, B = B_BOOT_BLOQUES)
  ri <- bootstrap_bloques(c23, r2, bloque = NULL, B = B_BOOT_BLOQUES)
  ratio <- (rb$ci_high - rb$ci_low) / (ri$ci_high - ri$ci_low)
  cat(sprintf("   R2 = %.3f · bloques [%.3f; %.3f] · iid [%.3f; %.3f] · ratio %.2f\n",
              rb$valor, rb$ci_low, rb$ci_high, ri$ci_low, ri$ci_high, ratio))
  comprobar(nrow(c23) == 161 && rb$n_bloques == 20, "P6a: 161 países y 20 subregiones")
  comprobar(abs(rb$valor - 0.773) < 0.0015, sprintf("P6b: R2 = %.4f reproduce el 0,773 del memo espacial", rb$valor))
  comprobar(abs(rb$ci_low - 0.67) < 0.03 && abs(rb$ci_high - 0.84) < 0.03,
            sprintf("P6c: IC por bloques [%.3f; %.3f] ~ memo [0,67; 0,84] (±0,03)", rb$ci_low, rb$ci_high))
  comprobar(abs(ri$ci_low - 0.74) < 0.02 && abs(ri$ci_high - 0.81) < 0.02,
            sprintf("P6d: IC iid [%.3f; %.3f] ~ memo [0,74; 0,81] (±0,02)", ri$ci_low, ri$ci_high))
  comprobar(ratio > 1.4, sprintf("P6e: IC por bloques %.1f veces más ancho que el iid (memo: 2,2)", ratio))
})

# -----------------------------------------------------------------------------
# P7. Datos reales: H1 con BCa + jackknife
# -----------------------------------------------------------------------------
prueba("P7", {
  acc <- paises_todos(anios = 2000:2023) |>
    filter(ingreso == "High income") |>
    group_by(ISO3_code) |>
    summarise(mig = sum(NetMigrations), pop = sum(PopChange), .groups = "drop")
  razon <- function(d) 100 * sum(d$mig) / sum(d$pop)
  rb <- bootstrap_bca(acc, razon, B = B_BOOT)
  jk <- jackknife_unidades(acc, razon)
  cat(sprintf("   H1 = %.2f %% · %s [%.1f; %.1f] · jackknife %.1f (%s) – %.1f (%s)\n", rb$valor, rb$method,
              rb$ci_low, rb$ci_high, jk$min, jk$unidad_min, jk$max, jk$unidad_max))
  comprobar(nrow(acc) == 85, "P7a: 85 países de ingreso alto (FY2027)")
  comprobar(abs(rb$valor - 70.7) < 0.05, sprintf("P7b: H1 = %.2f %% reproduce el 70,7 %% del memo", rb$valor))
  comprobar(rb$method == "bootstrap_bca" && rb$ci_low > 54 && rb$ci_low < 58 && rb$ci_high > 106 && rb$ci_high < 122,
            sprintf("P7c: BCa [%.1f; %.1f] ~ memo [55,8; 114,0] (variación por semilla: 55,8-56,4 / 112-117)",
                    rb$ci_low, rb$ci_high))
  comprobar(abs(jk$max - 81.6) < 0.1 && jk$unidad_max == "USA" && abs(jk$min - 64.5) < 0.1,
            sprintf("P7d: jackknife %.1f-%.1f, máximo al quitar %s (memo: 64,5-81,6, EE. UU.)", jk$min, jk$max, jk$unidad_max))
})

# -----------------------------------------------------------------------------
# P8. Wilson
# -----------------------------------------------------------------------------
prueba("P8", {
  w <- ic_wilson(105, 108, escala = 100)
  pt <- 100 * prop.test(105, 108, correct = FALSE)$conf.int
  comprobar(abs(w$ci_low - pt[1]) < 1e-8 && abs(w$ci_high - pt[2]) < 1e-8,
            sprintf("P8a: Wilson 105/108 = %.1f [%.1f; %.1f] = prop.test(correct = FALSE)", w$valor, w$ci_low, w$ci_high))
  xs <- c(0, 3, 50, 71, 89); ns <- c(20, 40, 100, 89, 89)
  wv <- ic_wilson(xs, ns)
  ptv <- t(mapply(function(x, n) prop.test(x, n, correct = FALSE)$conf.int, xs, ns))
  comprobar(max(abs(cbind(wv$ci_low, wv$ci_high) - ptv)) < 1e-8, "P8b: vectorizado y casos extremos (0 y n) = prop.test")
  comprobar(wv$ci_low[1] == 0 && wv$ci_high[5] == 1, "P8c: límites exactos 0 y 1 en los extremos")
  comprobar(abs(w$conteo_low - 108 * pt[1] / 100) < 1e-8 && w$method == "wilson", "P8d: IC en número de países y method = 'wilson'")
  comprobar(da_aviso(ic_wilson(3, 8)), "P8e: aviso si n < 10")
})

# -----------------------------------------------------------------------------
# P9. Tipos de palanca 2023 (comprobación del integrador, 07 §5)
# -----------------------------------------------------------------------------
prueba("P9", {
  t23 <- tipo_palanca_ventana(2023)
  tab <- table(factor(t23$tipo, levels = c("A", "B", "C", "D", "E")))
  tab1m <- table(factor(t23$tipo[t23$pob_1m], levels = c("A", "B", "C", "D", "E")))
  comprobar(identical(as.integer(tab), c(71L, 94L, 18L, 35L, 19L)) && sum(is.na(t23$tipo)) == 0,
            paste("P9a: tipos 2023 (237) =", paste(names(tab), tab, collapse = " · ")))
  comprobar(identical(as.integer(tab1m), c(48L, 72L, 11L, 24L, 6L)),
            paste("P9b: tipos 2023 (>= 1 M) =", paste(names(tab1m), tab1m, collapse = " · ")))
  t1719 <- tipo_palanca_ventana(2017:2019)
  comprobar(sum(t1719$tipo == "C") == 14, "P9c: tipo C en 2017-2019 = 14 (plan §3)")
  comprobar(da_error(tipo_palanca_ventana(2022:2025)), "P9d: una ventana que cruza 2023/24 da error")
})

# -----------------------------------------------------------------------------
# P10. formatear_cifra()
# -----------------------------------------------------------------------------
prueba("P10", {
  casos <- list(
    list(70.65, "0.0", "70.7"), list(0.15, "0.0", "0.2"), list(70.66, "0", "71"),
    list(2200.4, "#,##0", "2,200"), list(1234567.25, "#,##0.0", "1,234,567.3"),
    list(-0.4149, "+0.00", "-0.41"), list(3.2, "+0.0", "+3.2"), list(-0.004, "0.0", "0.0"),
    list(70.7, "0%", "71%"), list(0.7734, "sig2", "0.77"), list(0.0999, "sig2", "0.10"),
    list(1234, "sig2", "1,200"), list("Germany", "text", "Germany"), list(NA_real_, "0", NA_character_)
  )
  res <- vapply(casos, function(cs) identical(formatear_cifra(cs[[1]], cs[[2]]), cs[[3]]), logical(1))
  if (!all(res)) {
    for (i in which(!res)) cat("   caso", i, ":", casos[[i]][[1]], casos[[i]][[2]], "->",
                               formatear_cifra(casos[[i]][[1]], casos[[i]][[2]]), "(esperado", casos[[i]][[3]], ")\n")
  }
  comprobar(all(res), sprintf("P10a: %d/%d casos de formatear_cifra()", sum(res), length(res)))
  comprobar(identical(formatear_rango(55.8, 114, "0"), "56–114"), "P10b: formatear_rango()")
  comprobar(da_error(formatear_cifra(1, "0,0")), "P10c: código fmt desconocido -> error")
})

# -----------------------------------------------------------------------------
# P11. Registro numbers.json
# -----------------------------------------------------------------------------
prueba("P11", {
  reg <- nuevo_registro()
  c23 <- corte_anio(2023, "1m")
  r2 <- function(d) summary(lm(MedianAgePop ~ TFR, data = d))$r.squared
  rb <- bootstrap_bloques(c23, r2, B = 200)
  ri <- bootstrap_bloques(c23, r2, bloque = NULL, B = 200)
  reg <- registrar_cifra(reg, "r2_tfr_medage", value = rb$valor, unit = "R2", fmt = "0.00",
                         def = "R2 of median age on TFR across countries, 2023", filter = "161 countries >= 1 M, 2023",
                         source_cell = "T8.1", used_in = "slide3.build1", status = "pre-specified",
                         ic = rb, ic_iid = ri, n = 161, universe = UNIVERSO_1M, hypothesis_id = "H6",
                         say = "about three quarters")
  w <- ic_wilson(105, 108, escala = 100)
  reg <- registrar_cifra(reg, "share_mort_first", w$valor, "%", "0", "Share of high-fertility countries whose child mortality decline began before fertility decline",
                         "161 countries >= 1 M, TFR1950 >= 5", "T3.2", c("slide2.build2", "narration.s2a"),
                         ic = w, sens_low = 94, sens_high = 97, status = "pre-specified", hypothesis_id = "H3a",
                         universe = UNIVERSO_1M, sens_note = "9 onset rules")
  reg <- registrar_cifra(reg, "examples_type_C", c("Germany", "Spain", "Belgium"), NA, "text",
                         "3 most populous >= 1 M countries of type C in 2023", "237 countries and areas", "T2.3",
                         character(0), method = "descriptive", status = "descriptive", n = 3, universe = UNIVERSO_237)
  reg <- registrar_cifra(reg, "cover_flags", I("DE"), NA, "text", "ISO2 of examples_type_C (test of 1-element array)",
                         "237 countries and areas", "T2.3", "cover", method = "descriptive", status = "descriptive")
  reg <- registrar_cifra(reg, "cluster_sizes", c("Early movers" = 40, "Fast movers" = 61), "countries", "0",
                         "Countries per trajectory group", "161 countries >= 1 M", "T11.4", "slide4.build1",
                         method = "descriptive", status = "exploratory", n = 161, universe = UNIVERSO_1M)
  reg <- registrar_cifra(reg, "twins", data.frame(iso_a = c("ARE", "BLR"), tfr = c(1.2, 1.2), growth = c(3.7, NA)),
                         NA, "text", "Twin pairs (test of a table value with NA)", "161 countries >= 1 M", "T8.4",
                         "slide3.build2", method = "descriptive", status = "exploratory")
  reg <- registrar_cifra(reg, "pop_are_2050", 15.4, "million", "0.0", "UAE population 2050 (UN medium)",
                         "UAE", "T13.1", "slide1.build6", method = "un_pi", status = "descriptive",
                         pi80_low = 10.1, pi80_high = 26.1, pi95_low = 8.9, pi95_high = 33.3,
                         variant_source = "WPP2024 OtherVariants (Median/Lower/Upper PI)", n = 1, universe = "UAE")
  reg <- registrar_cifra(reg, "n_grow_only_migration_2023", 18L, "countries", "0",
                         "NatChange < 0 and PopChange > 0 in 2023", "237 countries and areas", "T2.1", "cover",
                         method = "none_census", sens_low = 14, sens_high = 25,
                         status = "descriptive", n = 237, universe = UNIVERSO_237,
                         sens_note = "2021: 15 · 2022: 25 · 2021–23 avg: 24 · 2017–19: 14")

  e <- reg$r2_tfr_medage
  comprobar(identical(names(e), CAMPOS_NUMBERS), "P11a: la entrada tiene todos los campos del esquema y en orden")
  comprobar(identical(e$method, "block bootstrap by subregion") && e$resample_unit == "UN subregion" &&
              e$B == 200 && e$seed == 2026 && e$ci_level == 0.95 && identical(e$ci_iid_method, "bootstrap_perc") &&
              isFALSE(e$verified) && is.null(e$verified_by) && is.null(e$verified_on),
            "P11b: `ic` / `ic_iid` rellenan method, B, seed, resample_unit, ci_iid_*; verified = FALSE, verified_by/on = NULL")
  comprobar(reg$share_mort_first$n == 108 && reg$share_mort_first$method == "wilson" && is.na(reg$share_mort_first$B),
            "P11c: Wilson rellena n = 108 y method = 'wilson' (B = NA)")

  # validaciones que deben fallar / avisar
  base_args <- list(registro = reg, clave = "x", value = 1, unit = "u", fmt = "0", def = "d", filter = "f",
                    source_cell = "s", used_in = "u", status = "descriptive", method = "descriptive")
  llamar <- function(...) { a <- base_args; m <- list(...); a[names(m)] <- m; do.call(registrar_cifra, a) }
  comprobar(da_error(llamar(method = "bootstrap")), "P11d: method fuera de la lista -> error")
  comprobar(da_error(llamar(status = "confirmatory")), "P11e: status 'confirmatory' -> error")
  comprobar(da_error(llamar(campo_raro = 1)), "P11f: campo fuera del esquema -> error")
  comprobar(da_error(llamar(ci_low = 2, ci_high = 1)), "P11g: ci_low > ci_high -> error")
  comprobar(da_error(llamar(fmt = "0,0")), "P11h: fmt inválido -> error")
  comprobar(da_aviso(llamar(status = "pre-specified")), "P11i: pre-specified sin hypothesis_id -> aviso")
  comprobar(da_aviso(llamar(method = "block bootstrap by subregion", ci_low = 0, ci_high = 2)),
            "P11j: método con remuestreo sin B/seed -> aviso")
  comprobar(da_aviso(llamar(ci_low = 2, ci_high = 3)), "P11k: value fuera de su IC -> aviso")

  # escritura y relectura idéntica
  ruta <- file.path(RUTA_PRUEBAS, "numbers_ejemplo.json")
  guardar_numbers(reg, ruta)
  txt1 <- readLines(ruta, encoding = "UTF-8")
  comprobar(jsonlite::validate(paste(txt1, collapse = "\n")), "P11l: el archivo es JSON válido")
  crudo <- jsonlite::fromJSON(ruta, simplifyVector = FALSE)
  comprobar(all(vapply(crudo, function(x) identical(names(x), CAMPOS_NUMBERS), logical(1))),
            sprintf("P11m: en el JSON cada clave trae los %d campos en orden", length(CAMPOS_NUMBERS)))
  comprobar(is.null(crudo$r2_tfr_medage$pi80_low) && is.null(crudo$r2_tfr_medage$verified_by) &&
              identical(crudo$r2_tfr_medage$verified, FALSE),
            "P11n: NA -> null, verified_by -> null, verified -> false")
  comprobar(is.list(crudo$cover_flags$value) && length(crudo$cover_flags$value) == 1 &&
              is.list(crudo$examples_type_C$used_in) && length(crudo$examples_type_C$used_in) == 0 &&
              is.list(crudo$r2_tfr_medage$used_in) && length(crudo$r2_tfr_medage$used_in) == 1,
            "P11o: arreglos de 1 elemento y vacíos se conservan como arreglos (value I(), used_in)")
  comprobar(identical(names(crudo$cluster_sizes$value), c("Early movers", "Fast movers")) &&
              length(crudo$twins$value) == 2 && is.null(crudo$twins$value[[2]]$growth),
            "P11p: vector con nombres -> objeto; data.frame -> arreglo de filas (NA -> null)")
  comprobar(any(grepl("·", txt1)) && any(grepl("≥", txt1)), "P11q: UTF-8 conservado (·, ≥)")
  reg2 <- leer_numbers(ruta)
  ruta2 <- file.path(RUTA_PRUEBAS, "numbers_ejemplo_releido.json")
  guardar_numbers(reg2, ruta2)
  comprobar(identical(txt1, readLines(ruta2, encoding = "UTF-8")), "P11r: leer + guardar reproduce el archivo byte a byte")
  comprobar(is.na(reg2$r2_tfr_medage$pi80_low) && is.null(reg2$r2_tfr_medage$verified_by) &&
              identical(as.character(reg2$share_mort_first$used_in), c("slide2.build2", "narration.s2a")),
            "P11s: al leer, null -> NA (salvo verified_by/on) y used_in es texto")
  comprobar(abs(reg2$r2_tfr_medage$value - rb$valor) < 1e-12, "P11t: el valor se conserva con precisión completa (digits = NA)")

  # verificación: se conserva si la cifra no cambia; se reinicia si cambia
  reg3 <- marcar_verificada(reg2, "pop_are_2050", por = "QA-stats", fecha = as.Date("2026-10-28"))
  reg3 <- registrar_cifra(reg3, "pop_are_2050", 15.4, "million", "0.0", "UAE population 2050 (UN medium)",
                          "UAE", "T13.1", "slide1.build6", method = "un_pi", status = "descriptive",
                          pi80_low = 10.1, pi80_high = 26.1, pi95_low = 8.9, pi95_high = 33.3,
                          variant_source = "WPP2024 OtherVariants (Median/Lower/Upper PI)", n = 1, universe = "UAE")
  comprobar(isTRUE(reg3$pop_are_2050$verified) && reg3$pop_are_2050$verified_by == "QA-stats" &&
              reg3$pop_are_2050$verified_on == "2026-10-28",
            "P11u: re-registrar la misma cifra conserva la verificación")
  reg3 <- suppressMessages(registrar_cifra(reg3, "pop_are_2050", 15.5, "million", "0.0", "UAE population 2050 (UN medium)",
                                           "UAE", "T13.1", "slide1.build6", method = "un_pi", status = "descriptive"))
  comprobar(isFALSE(reg3$pop_are_2050$verified) && is.null(reg3$pop_are_2050$verified_by),
            "P11v: si la cifra cambia, verified vuelve a FALSE")

  # validar_registro y claves obligatorias
  v <- validar_registro(reg)
  comprobar(is.data.frame(v) && "twins" %in% v$clave && !("r2_tfr_medage" %in% v$clave[v$problema == "sin method"]),
            sprintf("P11w: validar_registro() devuelve %d avisos (p. ej. claves sin n/universe)", nrow(v)))
  ic_iid_pantalla <- registrar_cifra(nuevo_registro(), "z", ri$valor, "R2", "0.00", "d", "f", "s", "u",
                                     ic = ri, status = "exploratory")
  comprobar(any(grepl("no puede salir en pantalla", validar_registro(ic_iid_pantalla)$problema)),
            "P11x: validar_registro() marca un IC iid como no apto para pantalla")
  n_oblig <- length(unlist(CLAVES_OBLIGATORIAS_V2))
  comprobar(length(claves_faltantes(reg)) == n_oblig - sum(names(reg) %in% unlist(CLAVES_OBLIGATORIAS_V2)) &&
              !anyDuplicated(unlist(CLAVES_OBLIGATORIAS_V2)),
            sprintf("P11y: claves_faltantes() (%d obligatorias v2, sin duplicados)", n_oblig))

  # fusión con candado y combinación de parciales
  ruta_f <- file.path(RUTA_PRUEBAS, "numbers_fusion.json")
  unlink(ruta_f)
  guardar_numbers(reg["r2_tfr_medage"], ruta_f, fusionar = TRUE)
  guardar_numbers(reg["share_mort_first"], ruta_f, fusionar = TRUE)
  comprobar(identical(sort(names(leer_numbers(ruta_f))), c("r2_tfr_medage", "share_mort_first")) &&
              !dir.exists(paste0(ruta_f, ".lock")),
            "P11z: guardar_numbers(fusionar = TRUE) suma claves y libera el candado")
  pa <- file.path(RUTA_PRUEBAS, "parte_a.json"); pb <- file.path(RUTA_PRUEBAS, "parte_b.json")
  guardar_numbers(reg[c("r2_tfr_medage", "twins")], pa)
  guardar_numbers(reg[c("pop_are_2050", "twins")], pb)
  comb <- combinar_numbers(c(pa, pb), file.path(RUTA_PRUEBAS, "numbers_combinado.json"))
  comprobar(identical(names(comb), sort(c("pop_are_2050", "r2_tfr_medage", "twins"))),
            "P11aa: combinar_numbers() une parciales (clave repetida idéntica = OK)")
  guardar_numbers(reg3["pop_are_2050"], pb)   # mismo nombre, valor distinto (15.5)
  guardar_numbers(reg["pop_are_2050"], pa)
  comprobar(da_error(combinar_numbers(c(pa, pb), file.path(RUTA_PRUEBAS, "numbers_conflicto.json"))),
            "P11ab: combinar_numbers() falla si dos parciales difieren en la misma clave")
  vacio <- file.path(RUTA_PRUEBAS, "numbers_vacio.json")
  guardar_numbers(nuevo_registro(), vacio)
  comprobar(identical(readLines(vacio), "{}") && length(leer_numbers(vacio)) == 0, "P11ac: registro vacío -> {}")
})

# -----------------------------------------------------------------------------
# Resumen
# -----------------------------------------------------------------------------
dur <- as.numeric(difftime(Sys.time(), t_inicio, units = "secs"))
cat(sprintf("\n== %d pruebas OK, %d fallas (%.1f s) ==\n", n_ok, length(fallos), dur))
if (length(fallos) > 0) {
  cat("Fallas:\n", paste0(" - ", fallos, collapse = "\n"), "\n")
  quit(status = 1)
}
cat("TODAS LAS PRUEBAS PASARON.\n")
