#!/usr/bin/env Rscript
# =============================================================================
# 02_q1_palancas.R — Pregunta Q1 (P7 + P4 + calendario de P1)
# "Which lever moves each country's population — births, deaths or migration —
#  and does the answer depend on region and income?"
#
# Ejecutar desde la raíz del repo:   Rscript R/02_q1_palancas.R
# (Solo para desarrollo: Q1_RAPIDO=1 Rscript R/02_q1_palancas.R usa menos
#  réplicas. La corrida oficial NO define esa variable y usa B = 2000.)
#
# Qué hace, en orden (cada sección explica QUÉ se calcula y POR QUÉ):
#   1. Universo y gancho de portada (130 bajo reemplazo -> 84 crecen = 66 + 18;
#      195 Estados + 42 territorios; población 1950 y 2023).
#   2. Identidad de balance y descomposición del crecimiento por grupo de
#      ingreso FY2027 (sumas de países) y por región SDG; sensibilidad con los
#      agregados de ingreso de la ONU (clasificación de mayo de 2024).
#   3. Tipología de palancas A-E (año base 2023; ventanas de sensibilidad),
#      ejemplos elegidos por regla, inercia bajo reemplazo y su "reloj".
#   4. ¿Se parecen los vecinos? Moran's I (5 vecinos más cercanos) y LISA.
#   5. Supervivencia: ¿qué cae primero, la mortalidad infantil o la fecundidad?
#   6. Registro por hitos (datos funcionales): mismo camino, distinta velocidad.
#   7. Panel en cambios quinquenales con efectos fijos país + periodo.
#   8. Migración: memoria corta y paradoja tipo Simpson con el ingreso.
#   9. Incertidumbre oficial de la ONU (OtherVariants): fan chart de EAU.
#  10. Europa y decrecimiento natural (H2, H14, H14a).
#  10b. Apéndice: Shapley por ingreso, misma fecundidad, tipo E histórico, GAM.
#  11. Contrastes formales, familias y estado de las hipótesis preinscritas.
#  12. Salidas: figures/numbers_q1.json, parquet, CSV y figuras de revisión.
#
# Decisiones (ASA 2022, B.2-B.4; plan analítico v2 §3-§4):
#   * País = ISO3_code no vacío (237); modelos, correlaciones, supervivencia,
#     registro, panel y Moran con los 161 países >= 1 M en 2023.
#   * Estimaciones (<= 2023) y proyección Medium (>= 2024) nunca se mezclan en
#     un estadístico; las cifras proyectadas se rotulan "UN medium projection".
#   * Ingreso = World Bank FY2027 aplicado a todos los años ("today's income
#     groups"): todo gradiente por ingreso es descriptivo.
#   * Intervalos que pueden salir en pantalla: bootstrap por bloques de las
#     subregiones ONU (B = 2000, semilla 2026); el iid se guarda en ci_iid_*.
#     Conteos = censo (sin IC; rango entre definiciones). Proporciones de
#     países = Wilson. Tiempos hasta el evento = Kaplan-Meier / Turnbull.
#   * Lenguaje descriptivo: "goes with", "precedes", nunca causal.
#   * set.seed(2026) justo antes de cada remuestreo, permutación o partición.
#
# Tablas que deja en data/processed/ (columnas documentadas):
#   resultados_q1.parquet — una fila por país (237):
#     ISO3_code, ISO2_code, Location, region_sdg, subregion, ingreso, pob_1m,
#     pop_2023_miles, TFR_2023, NRR_2023, NatChange_2023, NetMigrations_2023,
#     PopChange_2023 (miles de personas), tipo_palanca_2023 (A-E),
#     tipo_ab_2023 (A y B fundidos), tipo_2017_2019, tipo_2021, tipo_2022,
#     tipo_2021_2023, bajo_reemplazo_2023 (TFR < 2,1), inercia_bajo_reemplazo
#     (tipo B y TFR < 2,1), inercia_estricta (además NetMigrations < 0),
#     ejemplo_por_regla (texto: "C", "D", "E", "momentum" o NA),
#     tfr_1950, elegible_inicio (>= 1 M, TFR1950 >= 5, ingreso clasificado),
#     inicio_q5, inicio_tfr (año de inicio de la caída sostenida; NA = no
#     iniciado), izq_q5, izq_tfr (máximo en 1950 = censura izquierda),
#     rezago_inicio_lo, rezago_inicio_hi (intervalo del rezago para Turnbull;
#     -Inf/Inf = censura), mort_primero, caida_q5_al_inicio_tfr (%),
#     c5, c4, c3 (año continuo del último cruce de TFR suavizada; -Inf = ya
#     debajo en 1950, Inf = aún no cruza en 2023), dur_5a3, evento_3,
#     cohorte_c5, ventana_completa_c4 (c4 +- 20 dentro de 1950-2023).
#   resultados_q1_descomposicion.parquet — agrupacion (income / of which /
#     sdg_region), grupo, periodo, n_paises, nat_miles, mig_miles,
#     pop_change_miles, share_mig_pct.
#   resultados_q1_cuotas_ic.parquet — grupo, periodo, share_mig_pct, ci_bloques
#     (lo, hi), ci_bca (lo, hi), jk_min, jk_max, pais_jk_min, pais_jk_max.
#   resultados_q1_ventanas.parquet — ventana, tipo, n_237, n_1m.
#   resultados_q1_moran.parquet — indicador, anio, version, W, muestra, n, I,
#     p_perm, nulo_lo, nulo_hi, jk_lo, jk_hi.
#   resultados_q1_lisa.parquet — ISO3_code, Location, subregion, Ii (Moran
#     local), z, lag_z, p (permutación condicional), p_bh (Benjamini-Hochberg),
#     cuadrante (High-High, Low-Low, High-Low, Low-High), ventana (2010-2023 o
#     2023), sig_05, sig_fdr.
#   resultados_q1_km.parquet — curva, grupo, anio_o_t, surv, lower, upper,
#     n_risk, n_event.
#   resultados_q1_event_time.parquet — ingreso, variable, tau, mediana, p25,
#     p75, n.
#   resultados_q1_umbral_grid.parquet — q5_umbral, tfr_umbral, n, mediana_rezago,
#     pct_mort_primero.
#   resultados_q1_reglas_inicio.parquet — frac, tfr_min, n, x_mort_primero,
#     pct_mort_primero, cota_rezago.
#   resultados_q1_registro.parquet — ISO3_code, Time, tfr_suav, c4, tau.
#   resultados_q1_registro_dispersion.parquet — hito, tau, var_calendario,
#     var_alineado, p10/p50/p90 calendario y alineado.
#   resultados_q1_panel.parquet — bloque, grupo, n_paises, n_obs, beta_sum,
#     ee_cluster, halfq5, ci_cluster_lo, ci_cluster_hi, ci_boot_lo,
#     ci_boot_hi, metodo_boot.
#   resultados_q1_placebo.parquet — replica, beta_sum, halfq5.
#   resultados_q1_comparacion_modelos.parquet — modelo, k_pendientes, n,
#     r2_dentro_in, r2_dentro_oos, AIC, BIC.
#   resultados_q1_memoria.parquet — variable, version, decada_a, decada_b,
#     r_pearson, r_spearman, n.
#   resultados_q1_simpson.parquet — par, grupo, rho, ci_lo, ci_hi, n.
#   resultados_q1_fan_are.parquet — Time, serie, pop_millones.
#   resultados_q1_direccion_2050.parquet — ISO3_code, Location, pop2023,
#     l95, l80, mediana, u80, u95, dir95, dir80, cnmr_l80, cnmr_u80,
#     signo_cnmr_incierto.
#   resultados_q1_hipotesis.parquet — id, enunciado, estado, evidencia.
#   resultados_q1_contrastes.parquet — contraste, familia, hipotesis, p,
#     p_holm, p_bh.
#   resultados_q1_inercia.parquet — una fila por país con inercia (22) + China:
#     ISO3_code, Location, pob_1m, cruce_21 (último año en que la TFR bajó de
#     2,1; estimación), pico_obs (año de máxima población <= 2023), pico_futuro
#     (año de máxima población 2023-2100, UN medium projection), pop_2023_miles,
#     pop_pico_miles, edad_mediana_2023, edad_mediana_pico, es_inercia, pico
#     (pico_futuro para la inercia; pico_obs para China), pico_es_proyeccion,
#     anios_reloj (pico - cruce_21), anios_desde_2023, pico_censurado_2100.
#   resultados_q1_gancho.parquet — grupo (tipo de palanca de los países bajo
#     reemplazo en 2023, en inglés), n.
#   resultados_q1_shapley.parquet — grupo (World / ingreso), ventana (2023 o
#     2021-2023), n, componente (CBR, CDR, CNMR), share (Shapley/LMG del R²).
#   resultados_q1_misma_fecundidad.parquet — países >= 1 M con TFR 1,5-1,99 en
#     2023: identificación, TFR, NatChangeRT, MedianAgePop, CNMR, PopGrowthRate.
#   resultados_q1_tipoE_historico.parquet — ISO3_code, Location, racha, desde,
#     hasta, anios, tfr_media (años con NatChange > 0, PopChange < 0, TFR >= 3).
#   resultados_q1_gam.parquet — ingreso, Q5, lq5, q5_min, q5_max, tfr (TFR
#     esperada del GAM sin efecto de país), dentro_rango.
# Además: figures/miembros_tipo_palanca.csv, figures/numbers_q1.json y
# figures/review/q1/*.png (gráficas rápidas de revisión, NO finales).
#
# Convención: código y comentarios en español; textos de gráficas en inglés.
# =============================================================================

t_inicio <- Sys.time()

# =============================================================================
# 0. Preparación: datos comunes, paquetes, registro y ayudas
# =============================================================================
# QUÉ: carga la infraestructura común (datos, constantes, incertidumbre).
# POR QUÉ: todas las preguntas usan las mismas muestras y el mismo registro.
suppressPackageStartupMessages(library(here))
source(here::here("R", "config.R"))
source(here::here("R", "utilidades.R"))
source(here::here("R", "comun_analisis.R"))
source(here::here("R", "incertidumbre.R"))

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(survival)
  library(fixest)
  library(sf)
  library(patchwork)
})
fixest::setFixest_notes(FALSE)
options(dplyr.summarise.inform = FALSE, width = 160)
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(SEMILLA)

RAPIDO <- nzchar(Sys.getenv("Q1_RAPIDO"))
B_Q1 <- if (RAPIDO) 200L else as.integer(B_BOOT_BLOQUES)   # cifras que pueden salir en pantalla
B_NB <- if (RAPIDO) 200L else 1000L                         # cifras solo de notebook (se declara en numbers)
B_PLAC <- if (RAPIDO) 60L else 300L                         # placebo del panel (plan §4)
B_PERM_Q1 <- if (RAPIDO) 199L else as.integer(B_PERM)       # Moran (999)
SEM <- SEMILLA
if (RAPIDO) message("AVISO: modo rápido (Q1_RAPIDO) — réplicas reducidas; NO es la corrida oficial.")

RUTA_FIG_Q1 <- file.path(RUTA_FIG_REVIEW, "q1")
dir.create(RUTA_FIG_Q1, recursive = TRUE, showWarnings = FALSE)
RUTA_NUMBERS_Q1 <- file.path(RUTA_FIGURAS, "numbers_q1.json")

reg <- nuevo_registro()
# Añade una cifra al registro (envoltorio de registrar_cifra).
anotar <- function(clave, ...) {
  reg <<- registrar_cifra(reg, clave, ...)
  invisible(NULL)
}
# Imprime una línea de log con formato.
informar <- function(fmt, ...) cat(sprintf(fmt, ...), "\n", sep = "")
seccion <- function(txt) cat("\n", strrep("=", 78), "\n", txt, "\n", strrep("=", 78), "\n", sep = "")
# Suma de rezagos con su EE (método delta lineal).
suma_rez <- function(m, vars = paste0("L", 0:4)) {
  b <- coef(m)[vars]; V <- vcov(m)[vars, vars]
  s <- sum(b); se <- sqrt(sum(V))
  list(beta_sum = s, ee = se, lo = s - 1.96 * se, hi = s + 1.96 * se, n = nobs(m))
}
# Mitad de Q5 -> hijos por mujer (multiplicar por ln 0,5).
LN05 <- log(0.5)
# Tema y guardado de las gráficas de revisión (1600x900).
tema_q1 <- function(base = 13) {
  theme_wpp(base_size = base) +
    theme(plot.title.position = "plot", plot.caption.position = "plot",
          plot.caption = element_text(size = rel(0.62)))
}
guardar_q1 <- function(p, nombre) guardar_png(p, nombre, carpeta = RUTA_FIG_Q1, ancho = 1600, alto = 900, res = 144)
pie_q1 <- function(...) paste(c("Source: UN DESA, World Population Prospects 2024 (CC BY 3.0 IGO).", ...), collapse = "\n")
COL_GRIS <- "#7F7F7F"
# Pie para figuras de modelos SIN intervalos por bloques (el PIE-3 promete bloques: solo se usa donde es cierto)
PIE_MODELOS <- "UN WPP 2024 · 161 countries ≥ 1 M people · estimates 1950–2023 · exploratory, not causal"
COLORES_RESALTE <- c("#AA4499", "#332288", "#DDAA33")   # resaltes neutros (sin rojo/verde)
PALETA_ING_Q1 <- PALETA_INGRESO[NIVELES_INGRESO]

# Datos de base que se reutilizan
c23 <- corte_anio(2023, "completa")
est1m <- paises_1m(periodo = "estimacion") |> arrange(ISO3_code, Time)
anual_est <- paises_todos(periodo = "estimacion")
pop23 <- c23 |> select(ISO3_code, pop_2023_miles = TPopulation1July)

# =============================================================================
# 1. Universo y gancho de portada
# =============================================================================
# QUÉ: cuántos países están bajo reemplazo en 2023 y cuántos de ellos crecen,
#      separando los que crecen por saldo natural de los que crecen solo por
#      migración neta.
# POR QUÉ: es el gancho del vídeo y la prueba más simple de que una sola cifra
#      (la fecundidad) no basta para saber si un país crece.
seccion("1. Universo y gancho")

pop_mundo_bn <- agregado_mundo(2023)$TPopulation1July / 1e6
suma_paises_bn <- sum(c23$TPopulation1July) / 1e6
informar("Población mundial 2023: %.4f mil M (agregado ONU) vs %.4f (suma de 237 países); dif. %.2e %%",
         pop_mundo_bn, suma_paises_bn, 100 * abs(pop_mundo_bn - suma_paises_bn) / pop_mundo_bn)
stopifnot(abs(pop_mundo_bn - suma_paises_bn) / pop_mundo_bn < 1e-4)

gancho <- function(cond) {
  br <- c23[cond %in% TRUE, ]
  c(n = nrow(br), crecen = sum(br$PopChange > 0),
    nat = sum(br$NatChange > 0 & br$PopChange > 0),
    solo_mig = sum(br$NatChange < 0 & br$PopChange > 0))
}
g_def <- list(`TFR < 2.1` = c23$TFR < 2.1, `TFR < 2.0` = c23$TFR < 2.0,
              `TFR < 2.2` = c23$TFR < 2.2, `NRR < 1` = c23$NRR < 1)
g_tab <- do.call(rbind, lapply(g_def, gancho))
print(g_tab)
g_main <- g_tab["TFR < 2.1", ]
share_crecen <- 100 * g_tab[, "crecen"] / g_tab[, "n"]
informar("Bajo reemplazo (TFR < 2,1): %d; crecen %d (%.0f %%) = %d por saldo natural + %d solo por migración",
         g_main["n"], g_main["crecen"], share_crecen[1], g_main["nat"], g_main["solo_mig"])

anotar("world_pop_2023_bn", value = round(pop_mundo_bn, 4), unit = "billion", fmt = "0.0",
       def = "World population on 1 July 2023 (UN World aggregate; equals the sum of the 237 countries and areas)",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-1.1",
       used_in = c("cover.build1", "narration.cover"), method = "descriptive", status = "descriptive",
       say = "eight billion", n = N_PAISES, universe = UNIVERSO_237)
anotar("n_countries", value = N_PAISES, unit = "countries and areas", fmt = "0",
       def = "Rows with a non-empty ISO3 code in WPP 2024 (countries and areas, each counted once)",
       filter = "WPP 2024 Medium file", source_cell = "Q1-1.1", used_in = c("slide1.build0", "cover"),
       method = "none_census", status = "descriptive", n = N_PAISES, universe = UNIVERSO_237)
anotar("n_countries_1m", value = N_PAISES_1M, unit = "countries", fmt = "0",
       def = "Countries and areas with at least 1 million people on 1 July 2023",
       filter = "237 countries and areas, 2023", source_cell = "Q1-1.1", used_in = c("slide1.build0"),
       method = "none_census", status = "descriptive", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("n_below_replacement_2023", value = unname(g_main["n"]), unit = "countries and areas", fmt = "0",
       def = "Countries and areas with total fertility below 2.1 children per woman in 2023",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-1.2",
       used_in = c("cover.build2", "narration.cover"), method = "none_census",
       sens_low = min(g_tab[, "n"]), sens_high = max(g_tab[, "n"]),
       sens_note = sprintf("TFR < 2.0: %d · TFR < 2.2: %d · NRR < 1: %d",
                           g_tab["TFR < 2.0", "n"], g_tab["TFR < 2.2", "n"], g_tab["NRR < 1", "n"]),
       status = "pre-specified", hypothesis_id = "H12a", n = N_PAISES, universe = UNIVERSO_237)
anotar("n_below_repl_growing_2023", value = unname(g_main["crecen"]), unit = "countries and areas", fmt = "0",
       def = "Countries and areas with TFR < 2.1 and positive population change (PopChange > 0) in 2023",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-1.2",
       used_in = c("cover.build3", "narration.cover"), method = "none_census",
       sens_low = min(g_tab[, "crecen"]), sens_high = max(g_tab[, "crecen"]),
       sens_note = sprintf("TFR < 2.0: %d of %d · TFR < 2.2: %d of %d · NRR < 1: %d of %d",
                           g_tab[2, 2], g_tab[2, 1], g_tab[3, 2], g_tab[3, 1], g_tab[4, 2], g_tab[4, 1]),
       status = "pre-specified", hypothesis_id = "H12a", n = unname(g_main["n"]), universe = UNIVERSO_237)
anotar("n_below_repl_natural_growth_2023", value = unname(g_main["nat"]), unit = "countries and areas", fmt = "0",
       def = "Countries and areas with TFR < 2.1, births > deaths (NatChange > 0) and PopChange > 0 in 2023",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-1.2",
       used_in = c("cover.build3", "narration.cover"), method = "none_census",
       sens_low = min(g_tab[, "nat"]), sens_high = max(g_tab[, "nat"]),
       sens_note = "range across TFR < 2.0 / 2.1 / 2.2 and NRR < 1",
       status = "pre-specified", hypothesis_id = "H12a", n = unname(g_main["n"]), universe = UNIVERSO_237)

# 1.2 Universo: Estados y territorios, población de 1950 y alias que pide el guion
# QUÉ: separa los 237 en 195 Estados (193 miembros de la ONU + Santa Sede y
#      Palestina) y 42 territorios o áreas con una lista ISO3 explícita.
# POR QUÉ: el jurado puede objetar "237 países"; la tarjeta de datos dice
#      "195 states + 42 territories" y esa cifra no se teclea (plan §3, 01b A9).
TERRITORIOS_42 <- c("ASM", "AIA", "ABW", "BMU", "BES", "VGB", "CYM", "HKG", "MAC", "TWN", "COK", "CUW", "FLK", "FRO",
                    "GUF", "PYF", "GIB", "GRL", "GLP", "GUM", "GGY", "IMN", "JEY", "XKX", "MTQ", "MYT", "MSR", "NCL",
                    "NIU", "MNP", "PRI", "REU", "BLM", "SHN", "MAF", "SPM", "SXM", "TKL", "TCA", "VIR", "WLF", "ESH")
stopifnot(length(unique(TERRITORIOS_42)) == 42, all(TERRITORIOS_42 %in% iso_muestra_completa),
          all(c("VAT", "PSE") %in% iso_muestra_completa))
n_estados <- N_PAISES - length(TERRITORIOS_42)
ter_1m <- intersect(TERRITORIOS_42, iso_muestra_1m)
informar("Universo: %d Estados + %d territorios/áreas = %d; territorios con >= 1 M: %s",
         n_estados, length(TERRITORIOS_42), N_PAISES, paste(ter_1m, collapse = ", "))
pop_1950_bn <- agregado_mundo(1950)$TPopulation1July / 1e6
F_SOB <- "WPP 2024 rows with an ISO3 code; territories = explicit list of 42 ISO3 codes (dependencies, special administrative regions and areas not UN members or observers)"
for (k in c("n_sovereign", "n_states")) {
  anotar(k, value = n_estados, unit = "states", fmt = "0",
         def = "Sovereign states among the 237 countries and areas: 193 UN Member States plus the two observer States (Holy See, State of Palestine)",
         filter = F_SOB, source_cell = "Q1-1.3", used_in = c("slide1.build0", "cover"), method = "none_census",
         status = "descriptive", sens_note = paste("Territories/areas:", paste(TERRITORIOS_42, collapse = ", ")),
         n = N_PAISES, universe = UNIVERSO_237)
}
anotar("n_territories", value = length(TERRITORIOS_42), unit = "territories and areas", fmt = "0",
       def = "Territories and areas among the 237 (not UN Member or observer States), explicit ISO3 list",
       filter = F_SOB, source_cell = "Q1-1.3", used_in = c("slide1.build0", "cover"), method = "none_census",
       status = "descriptive", sens_note = sprintf("%d of them have >= 1 M people: %s", length(ter_1m), paste(ter_1m, collapse = ", ")),
       n = N_PAISES, universe = UNIVERSO_237)
anotar("n_ge1m", value = N_PAISES_1M, unit = "countries", fmt = "0",
       def = "Alias of n_countries_1m used by the storyboard: countries and areas with at least 1 million people on 1 July 2023",
       filter = "237 countries and areas, 2023", source_cell = "Q1-1.3", used_in = c("slide1.build0", "slide1.build5", "slide3", "slide4"),
       method = "none_census", status = "descriptive", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("world_pop_1950_bn", value = round(pop_1950_bn, 4), unit = "billion", fmt = "0.0",
       def = "World population on 1 July 1950 (UN World aggregate, estimate)", filter = "UN World aggregate, 1950 (estimate)",
       source_cell = "Q1-1.3", used_in = c("cover.build1"), method = "descriptive", status = "descriptive",
       say = "two and a half billion", n = N_PAISES, universe = UNIVERSO_237)

# =============================================================================
# 2. Identidad de balance y descomposición del crecimiento
# =============================================================================
# QUÉ: comprueba PopChange = NatChange + NetMigrations y reparte el crecimiento
#      de cada grupo de ingreso (FY2027) y región SDG entre saldo natural y
#      migración neta, sumando personas (nunca tasas).
# POR QUÉ: es la respuesta contable de P4/P7: qué parte del crecimiento viene
#      de cada palanca en cada grupo, con la incertidumbre de "qué países".
seccion("2. Identidad de balance y descomposición")

# 2.1 Identidad contable (una identidad, no un hallazgo)
res_id <- anual_est |> mutate(res = PopChange - NatChange - NetMigrations)
i_max <- which.max(abs(res_id$res))
informar("Residuo máximo |PopChange - NatChange - NetMigrations| = %.2f mil (%s %d)",
         abs(res_id$res[i_max]), res_id$ISO3_code[i_max], res_id$Time[i_max])
chk_mundo <- anual_est |> group_by(Time) |> summarise(pop = sum(PopChange)) |>
  left_join(agregado_mundo(periodo = "estimacion") |> select(Time, pop_w = PopChange), by = "Time")
dif_mundo <- max(abs(chk_mundo$pop - chk_mundo$pop_w))
informar("Suma de grupos de ingreso (incl. Not classified) = World: dif. máx. %.4f mil personas/año", dif_mundo)
stopifnot(dif_mundo < 1)
chk_reg <- anual_est |> filter(Time >= 2000) |> group_by(region_sdg) |> summarise(pop = sum(PopChange)) |>
  left_join(agregados_region(2000:2023) |> mutate(region_sdg = as.character(region_sdg)) |>
              group_by(region_sdg) |> summarise(pop_r = sum(PopChange)), by = "region_sdg")
informar("Suma de países por región SDG = agregado SDG (2000-23): dif. relativa máx. %.2e",
         max(abs(chk_reg$pop - chk_reg$pop_r) / abs(chk_reg$pop_r)))

anotar("identity_residual_max", value = round(abs(res_id$res[i_max]), 4), unit = "thousand people", fmt = "0.0",
       def = "Largest |PopChange - NatChange - NetMigrations| over all country-years 1950-2023 (accounting identity check)",
       filter = "237 countries and areas, 1950-2023 (estimates)", source_cell = "Q1-2.1",
       used_in = c("notebook.T1"), method = "descriptive", status = "descriptive",
       sens_note = sprintf("country-year: %s %d", res_id$ISO3_code[i_max], res_id$Time[i_max]),
       n = N_PAISES, universe = UNIVERSO_237)

# 2.2 Descomposición por periodo (sumas de personas)
PERIODOS_DESC <- list(`1950-1959` = 1950:1959, `1960-1969` = 1960:1969, `1970-1979` = 1970:1979,
                      `1980-1989` = 1980:1989, `1990-1999` = 1990:1999, `2000-2009` = 2000:2009,
                      `2010-2023` = 2010:2023, `2000-2023` = 2000:2023)
grupo_chn <- as.character(c23$ingreso[c23$ISO3_code == "CHN"])
grupo_ind <- as.character(c23$ingreso[c23$ISO3_code == "IND"])
desc <- bind_rows(lapply(names(PERIODOS_DESC), function(pn) {
  d <- anual_est |> filter(Time %in% PERIODOS_DESC[[pn]])
  sumar <- function(x, agrup, col) x |> group_by(grupo = as.character(.data[[col]])) |>
    summarise(n_paises = n_distinct(ISO3_code), nat_miles = sum(NatChange), mig_miles = sum(NetMigrations),
              pop_change_miles = sum(PopChange)) |> mutate(agrupacion = agrup)
  bind_rows(
    sumar(d, "income", "ingreso"),
    sumar(d |> filter(ISO3_code == "CHN") |> mutate(g = paste("of which China:", grupo_chn)), "of which", "g"),
    sumar(d |> filter(ISO3_code == "IND") |> mutate(g = paste("of which India:", grupo_ind)), "of which", "g"),
    sumar(d, "sdg_region", "region_sdg")
  ) |> mutate(periodo = pn)
})) |> mutate(share_mig_pct = 100 * mig_miles / pop_change_miles) |>
  select(agrupacion, grupo, periodo, n_paises, nat_miles, mig_miles, pop_change_miles, share_mig_pct)
print(desc |> filter(periodo == "2000-2023") |> mutate(across(where(is.numeric), \(x) round(x, 1))))

# 2.3 Cuotas 2000-2023 con incertidumbre de "qué países" (bloques + BCa + jackknife)
acumular <- function(anios) {
  paises_todos(anios) |> group_by(ISO3_code, subregion, region_sdg, ingreso, pob_1m) |>
    summarise(mig = sum(NetMigrations), pop = sum(PopChange), nat = sum(NatChange), .groups = "drop")
}
acc <- acumular(2000:2023)
acc1023 <- acumular(2010:2023)
cuota <- function(d) 100 * sum(d$mig) / sum(d$pop)
un_ing <- agregados_ingreso_onu(2000:2023) |> group_by(ingreso) |>
  summarise(share = 100 * sum(NetMigrations) / sum(PopChange))
cuotas <- list()
for (g in NIVELES_INGRESO) {
  d_g <- acc |> filter(ingreso == g)
  bb <- suppressWarnings(bootstrap_bloques(d_g, cuota, B = B_Q1, semilla = SEM))
  bc <- bootstrap_bca(d_g, cuota, B = B_Q1, semilla = SEM)
  jk <- jackknife_unidades(d_g, cuota)
  cuotas[[g]] <- list(bb = bb, bca = bc, jk = jk, n = nrow(d_g),
                      un = un_ing$share[un_ing$ingreso == g],
                      s1023 = cuota(acc1023 |> filter(ingreso == g)),
                      s1m = cuota(d_g |> filter(pob_1m)))
  informar("%-20s n=%2d  cuota %6.1f %%  bloques [%6.1f; %6.1f] (%d bloques)  BCa [%6.1f; %6.1f]  jackknife %.1f (%s) - %.1f (%s)",
           g, nrow(d_g), bb$valor, bb$ci_low, bb$ci_high, bb$n_bloques, bc$ci_low, bc$ci_high,
           jk$min, jk$unidad_min, jk$max, jk$unidad_max)
}
hi_acc <- acc |> filter(ingreso == "High income")
sens_hi <- c(un_agg = cuotas[["High income"]]$un, p2010_23 = cuotas[["High income"]]$s1023,
             ge1m = cuotas[["High income"]]$s1m, sin_usa = cuota(hi_acc |> filter(ISO3_code != "USA")),
             sin_golfo = cuota(hi_acc |> filter(!es_golfo(ISO3_code))),
             sin_rusia = cuota(hi_acc |> filter(ISO3_code != "RUS")))
print(round(sens_hi, 1))
bb_1023 <- suppressWarnings(bootstrap_bloques(acc1023 |> filter(ingreso == "High income"), cuota, B = B_Q1, semilla = SEM))
bc_1023 <- bootstrap_bca(acc1023 |> filter(ingreso == "High income"), cuota, B = B_Q1, semilla = SEM)
cuotas_tab <- bind_rows(lapply(NIVELES_INGRESO, function(g) {
  x <- cuotas[[g]]
  tibble(grupo = g, periodo = "2000-2023", share_mig_pct = x$bb$valor, ci_bloques_lo = x$bb$ci_low,
         ci_bloques_hi = x$bb$ci_high, ci_bca_lo = x$bca$ci_low, ci_bca_hi = x$bca$ci_high,
         jk_min = x$jk$min, jk_max = x$jk$max, pais_jk_min = x$jk$unidad_min, pais_jk_max = x$jk$unidad_max,
         n_paises = x$n, n_bloques = x$bb$n_bloques, un_agregado = x$un)
}), tibble(grupo = "High income", periodo = "2010-2023", share_mig_pct = bb_1023$valor,
           ci_bloques_lo = bb_1023$ci_low, ci_bloques_hi = bb_1023$ci_high, ci_bca_lo = bc_1023$ci_low,
           ci_bca_hi = bc_1023$ci_high, n_paises = bb_1023$n_unidades, n_bloques = bb_1023$n_bloques))

claves_cuota <- c("Low income" = "share_mig_low_2000_2023", "Lower middle income" = "share_mig_lowmid_2000_2023",
                  "Upper middle income" = "share_mig_upmid_2000_2023", "High income" = "share_mig_high_2000_2023")
for (g in NIVELES_INGRESO) {
  x <- cuotas[[g]]
  es_alto <- g == "High income"
  sens <- if (es_alto) sens_hi else c(un_agg = x$un, p2010_23 = x$s1023, ge1m = x$s1m, jk_min = x$jk$min, jk_max = x$jk$max)
  nota <- if (es_alto) {
    sprintf("UN income aggregates (WB May 2024) %.1f; 2010-23 %.1f; >=1M %.1f; without USA %.1f; without Gulf %.1f; without Russia %.1f; jackknife %.1f (%s out) to %.1f (%s out); BCa iid [%.1f; %.1f]",
            sens_hi["un_agg"], sens_hi["p2010_23"], sens_hi["ge1m"], sens_hi["sin_usa"], sens_hi["sin_golfo"],
            sens_hi["sin_rusia"], x$jk$min, x$jk$unidad_min, x$jk$max, x$jk$unidad_max, x$bca$ci_low, x$bca$ci_high)
  } else {
    sprintf("UN income aggregates %.1f; 2010-23 %.1f; >=1M %.1f; jackknife %.1f (%s out) to %.1f (%s out)",
            x$un, x$s1023, x$s1m, x$jk$min, x$jk$unidad_min, x$jk$max, x$jk$unidad_max)
  }
  anotar(claves_cuota[[g]], value = round(x$bb$valor, 4), unit = "%", fmt = "0.0",
         def = sprintf("Sum of NetMigrations / sum of PopChange, 2000-2023, today's World Bank FY2027 %s countries (sums of people)", g),
         filter = sprintf("%s (FY2027), all countries and areas in the group, 2000-2023 (estimates)", g),
         source_cell = "Q1-2.3", used_in = if (es_alto) c("slide1.build2", "slide1.message", "narration.slide1") else c("slide1.build2"),
         ic = x$bb, ic_iid = x$bca, sens_low = min(sens), sens_high = max(sens), sens_note = nota,
         status = if (es_alto) "pre-specified" else "descriptive", hypothesis_id = if (es_alto) "H1" else NA,
         say = if (es_alto) "seven in ten" else NA, n = x$n, universe = UNIVERSO_237)
}
anotar("share_mig_high_2010_2023", value = round(bb_1023$valor, 4), unit = "%", fmt = "0.0",
       def = "Sum of NetMigrations / sum of PopChange, 2010-2023, today's World Bank FY2027 high-income countries",
       filter = "High income (FY2027), 2010-2023 (estimates)", source_cell = "Q1-2.3",
       used_in = c("slide1.build2"), ic = bb_1023, ic_iid = bc_1023, status = "descriptive",
       n = bb_1023$n_unidades, universe = UNIVERSO_237)
anotar("share_mig_high_un_agg", value = round(cuotas[["High income"]]$un, 4), unit = "%", fmt = "0.0",
       def = "Same share with the UN 'High-income countries' aggregate (World Bank classification of May 2024), 2000-2023",
       filter = "UN income aggregate, 2000-2023 (estimates) — sensitivity only", source_cell = "Q1-2.3",
       used_in = c("slide1.build2"), method = "sensitivity", status = "descriptive",
       sens_note = "different classification vintage: never used to validate the FY2027 sums",
       n = 1L, universe = "UN 'High-income countries' aggregate (1 aggregate)")
# Rango "con otras listas de ingreso y otros periodos" que usa la diapositiva:
# rejilla 2 x 2 {FY2027 (sumas de países), agregados ONU de mayo-2024} x {2000-23, 2010-23}.
un_ing_1023 <- agregados_ingreso_onu(2010:2023) |> group_by(ingreso) |>
  summarise(share = 100 * sum(NetMigrations) / sum(PopChange))
rejilla_hi <- c(fy2027_2000_23 = cuotas[["High income"]]$bb$valor, fy2027_2010_23 = cuotas[["High income"]]$s1023,
                un_2000_23 = cuotas[["High income"]]$un, un_2010_23 = un_ing_1023$share[un_ing_1023$ingreso == "High income"])
informar("Rejilla ingreso alto (lista x periodo): %s", paste(sprintf("%s %.1f", names(rejilla_hi), rejilla_hi), collapse = "; "))
anotar("share_mig_high_sens_range", value = formatear_rango(min(rejilla_hi), max(rejilla_hi), "0"), unit = "%", fmt = "text",
       def = "Range of the high-income share of growth from net migration over 2 income lists (World Bank FY2027 sums of countries; UN income aggregates, WB May 2024) x 2 periods (2000-2023; 2010-2023)",
       filter = "High-income countries, estimates 2000-2023 and 2010-2023", source_cell = "Q1-2.3",
       used_in = c("slide1.build2"), method = "sensitivity", status = "descriptive",
       sens_low = round(min(rejilla_hi), 2), sens_high = round(max(rejilla_hi), 2),
       sens_note = paste(sprintf("%s %.1f", names(rejilla_hi), rejilla_hi), collapse = "; "),
       n = cuotas[["High income"]]$n, universe = UNIVERSO_237)

# China e India dentro de su grupo
d_up <- acc |> filter(ingreso == grupo_chn); d_lm <- acc |> filter(ingreso == grupo_ind)
chn_nat <- 100 * d_up$nat[d_up$ISO3_code == "CHN"] / sum(d_up$nat)
ind_nat <- 100 * d_lm$nat[d_lm$ISO3_code == "IND"] / sum(d_lm$nat)
chn_pop <- 100 * pop23$pop_2023_miles[pop23$ISO3_code == "CHN"] / sum(pop23$pop_2023_miles[pop23$ISO3_code %in% d_up$ISO3_code])
ind_pop <- 100 * pop23$pop_2023_miles[pop23$ISO3_code == "IND"] / sum(pop23$pop_2023_miles[pop23$ISO3_code %in% d_lm$ISO3_code])
informar("China: %.1f %% del saldo natural 2000-23 de %s (%.1f %% de su población 2023); India: %.1f %% de %s (%.1f %%)",
         chn_nat, grupo_chn, chn_pop, ind_nat, grupo_ind, ind_pop)
anotar("china_share_natchange_upmid", value = round(chn_nat, 4), unit = "%", fmt = "0",
       def = sprintf("China's share of the natural change (births - deaths) of its FY2027 group (%s), sum 2000-2023", grupo_chn),
       filter = sprintf("%s countries, 2000-2023 (estimates)", grupo_chn), source_cell = "Q1-2.3",
       used_in = c("slide1.build2"), method = "descriptive", status = "descriptive",
       sens_note = sprintf("China = %.1f %% of the group's 2023 population", chn_pop),
       n = nrow(d_up), universe = UNIVERSO_237)
anotar("india_share_natchange_lowmid", value = round(ind_nat, 4), unit = "%", fmt = "0",
       def = sprintf("India's share of the natural change of its FY2027 group (%s), sum 2000-2023", grupo_ind),
       filter = sprintf("%s countries, 2000-2023 (estimates)", grupo_ind), source_cell = "Q1-2.3",
       used_in = c("slide1.build2"), method = "descriptive", status = "descriptive",
       sens_note = sprintf("India = %.1f %% of the group's 2023 population", ind_pop),
       n = nrow(d_lm), universe = UNIVERSO_237)

# 2.4 Regiones SDG (sumas de países) y % de países donde |migración| > |saldo natural|
reg_share <- acc |> group_by(region_sdg) |>
  summarise(n = n(), share = 100 * sum(mig) / sum(pop), pct_mig_domina = 100 * mean(abs(mig) > abs(nat))) |>
  arrange(desc(share))
print(reg_share |> mutate(across(where(is.numeric), \(x) round(x, 1))))
anotar("share_mig_region_2000_2023", value = setNames(round(reg_share$share, 1), ETIQUETAS_REGION_CORTAS_EN[reg_share$region_sdg]),
       unit = "%", fmt = "0.0",
       def = "Sum of NetMigrations / sum of PopChange by UN SDG region (sums of countries), 2000-2023",
       filter = "237 countries and areas, 2000-2023 (estimates)", source_cell = "Q1-2.4",
       used_in = c("notebook.T1"), method = "descriptive", status = "descriptive",
       n = N_PAISES, universe = UNIVERSO_237)
anotar("share_countries_mig_dominant_by_region", value = setNames(round(reg_share$pct_mig_domina, 1), ETIQUETAS_REGION_CORTAS_EN[reg_share$region_sdg]),
       unit = "% of countries", fmt = "0",
       def = "Share of countries in each SDG region whose |sum NetMigrations| > |sum NatChange|, 2000-2023",
       filter = "237 countries and areas, 2000-2023 (estimates)", source_cell = "Q1-2.4",
       used_in = c("notebook.T1"), method = "none_census", status = "descriptive",
       n = N_PAISES, universe = UNIVERSO_237)

# 2.5 Figura de revisión: componentes del crecimiento por ingreso y década
fig_desc <- desc |> filter(agrupacion == "income", grupo %in% NIVELES_INGRESO, periodo != "2000-2023") |>
  mutate(anios = vapply(PERIODOS_DESC[periodo], length, integer(1))) |>
  pivot_longer(c(nat_miles, mig_miles), names_to = "componente", values_to = "miles") |>
  mutate(componente = factor(ifelse(componente == "nat_miles", "Natural change (births minus deaths)", "Net migration"),
                             levels = names(PALETA_COMPONENTES_V2)),
         millones_anio = miles / 1e3 / anios,
         grupo = factor(ETIQUETAS_INGRESO_CORTAS_EN[grupo], levels = ETIQUETAS_INGRESO_CORTAS_EN[NIVELES_INGRESO]))
p1a <- ggplot(fig_desc, aes(periodo, millones_anio, fill = componente)) +
  geom_col(width = 0.8) + geom_hline(yintercept = 0, colour = "black", linewidth = 0.3) +
  facet_wrap(~grupo, nrow = 1) + scale_fill_manual(values = PALETA_COMPONENTES_V2) +
  labs(x = NULL, y = "Million people per year", fill = NULL,
       title = "Growth comes from births everywhere except in today's high-income countries",
       subtitle = "Sum over countries of natural change and net migration, average per year in each period (World Bank FY2027 groups)") +
  tema_q1(11) + theme(axis.text.x = element_text(angle = 60, hjust = 1, size = rel(0.75)))
fig_cuota <- cuotas_tab |> filter(periodo == "2000-2023") |>
  mutate(grupo = factor(ETIQUETAS_INGRESO_CORTAS_EN[grupo], levels = ETIQUETAS_INGRESO_CORTAS_EN[NIVELES_INGRESO]))
p1b <- ggplot(fig_cuota, aes(share_mig_pct, grupo)) +
  geom_vline(xintercept = c(0, 50), linetype = c("solid", "dashed"), colour = COL_GRIS) +
  geom_errorbar(aes(xmin = ci_bloques_lo, xmax = ci_bloques_hi), width = 0.2, orientation = "y", colour = COLOR_MIGRACION, linewidth = 1) +
  geom_point(size = 3, colour = "black") +
  geom_text(aes(label = sprintf("%.1f%%", share_mig_pct)), vjust = -1, size = 3.5) +
  labs(x = "Net migration as % of population change, 2000–2023", y = NULL,
       title = "Share of growth from net migration, 2000–2023",
       subtitle = sprintf("Bars: 95%% block bootstrap by UN subregion (B = %d)", B_Q1)) +
  scale_y_discrete(expand = expansion(add = c(0.6, 1))) + tema_q1(11)
p1 <- (p1a / p1b) + plot_layout(heights = c(1.4, 1)) +
  plot_annotation(caption = pie_q1(badge("PIE-4"), "Bookkeeping, not cause: shared calendar, not country-by-country compensation."))
guardar_q1(p1, "q1_01_descomposicion_ingreso")

# =============================================================================
# 3. Tipología de palancas 2023, ventanas de sensibilidad, ejemplos e inercia
# =============================================================================
# QUÉ: clasifica cada país por qué término del balance domina hoy (A-E),
#      repite la clasificación con otras ventanas y elige ejemplos por regla.
# POR QUÉ: responde "país por país" a P7 y fija una sola definición (2023)
#      para portada, mapa, guion y numbers.json, con su rango de sensibilidad.
seccion("3. Tipología de palancas")

ventanas <- c(list(`2023` = 2023), VENTANAS_SENS_ANIOS)
tv <- lapply(ventanas, function(a) tipo_palanca_ventana(a, "completa"))
t23 <- tv[["2023"]] |>
  left_join(c23 |> select(ISO3_code, TFR, NRR, pop_2023_miles = TPopulation1July), by = "ISO3_code")
stopifnot(!anyNA(t23$tipo))
tab_vent <- bind_rows(lapply(names(tv), function(v) {
  x <- tv[[v]]
  bind_rows(
    tibble(tipo = c("A", "B", "C", "D", "E", "AB", "NA")) |>
      mutate(n_237 = vapply(tipo, function(tp) if (tp == "AB") sum(x$tipo %in% c("A", "B")) else if (tp == "NA") sum(is.na(x$tipo)) else sum(x$tipo %in% tp), integer(1)),
             n_1m = vapply(tipo, function(tp) if (tp == "AB") sum(x$tipo[x$pob_1m] %in% c("A", "B")) else if (tp == "NA") sum(is.na(x$tipo[x$pob_1m])) else sum(x$tipo[x$pob_1m] %in% tp), integer(1)))
  ) |> mutate(ventana = v)
})) |> select(ventana, tipo, n_237, n_1m)
print(tab_vent |> pivot_wider(names_from = ventana, values_from = c(n_237, n_1m)))
VENT_SENS <- c("2021", "2022", "2023", "2021-2023")   # "depending on the year" (plan §3)
for (tp in c("A", "B", "C", "D", "E", "AB")) {
  for (m in c("237", "1m")) {
    col <- paste0("n_", m)
    v23 <- tab_vent[[col]][tab_vent$ventana == "2023" & tab_vent$tipo == tp]
    vs <- tab_vent[[col]][tab_vent$ventana %in% VENT_SENS & tab_vent$tipo == tp]
    v1719 <- tab_vent[[col]][tab_vent$ventana == "2017-2019" & tab_vent$tipo == tp]
    clave <- paste0("n_type_", tp, if (m == "1m") "_1m" else "")
    vals_txt <- paste(sprintf("%s: %d", tab_vent$ventana[tab_vent$tipo == tp], tab_vent[[col]][tab_vent$tipo == tp]), collapse = " · ")
    anotar(clave, value = as.integer(v23), unit = "countries and areas", fmt = "0",
           def = sprintf("Countries with lever type %s in 2023 (%s)", tp, ETIQUETAS_PALANCA_EN[[tp]]),
           filter = if (m == "1m") "161 countries >= 1 M, 2023 (estimate)" else "237 countries and areas, 2023 (estimate)",
           source_cell = "Q1-3.1", used_in = if (m == "237") c("slide1.build3") else c("notebook.T2"),
           method = "none_census", sens_low = min(vs), sens_high = max(vs),
           sens_note = paste0("Windows (sums of people): ", vals_txt, " · on-screen range uses 2021, 2022, 2023 and 2021-23; pre-COVID 2017-19 = ", v1719),
           status = "descriptive", n = if (m == "1m") N_PAISES_1M else N_PAISES,
           universe = if (m == "1m") UNIVERSO_1M else UNIVERSO_237)
  }
}
# El conteo C es también el de "crecen solo por migración" del gancho
for (m in c("237", "1m")) {
  col <- paste0("n_", m)
  v23 <- tab_vent[[col]][tab_vent$ventana == "2023" & tab_vent$tipo == "C"]
  vs <- tab_vent[[col]][tab_vent$ventana %in% VENT_SENS & tab_vent$tipo == "C"]
  vals_txt <- paste(sprintf("%s: %d", tab_vent$ventana[tab_vent$tipo == "C"], tab_vent[[col]][tab_vent$tipo == "C"]), collapse = " · ")
  anotar(if (m == "1m") "n_grow_only_migration_2023_1m" else "n_grow_only_migration_2023",
         value = as.integer(v23), unit = "countries and areas", fmt = "0",
         def = "Deaths exceed births (NatChange < 0) yet population grows (PopChange > 0), 2023 — growing only through net arrivals",
         filter = if (m == "1m") "161 countries >= 1 M, 2023 (estimate)" else "237 countries and areas, 2023 (estimate)",
         source_cell = "Q1-3.1",
         used_in = if (m == "237") c("cover.build3", "slide1.build3", "slide1.message", "narration.cover") else c("slide1.build3"),
         method = "none_census", sens_low = min(vs), sens_high = max(vs),
         sens_note = paste0(vals_txt, " (on screen: 'depending on the year' = 2021, 2022, 2023, 2021-23 avg)"),
         status = "pre-specified", hypothesis_id = "H12a", say = if (m == "237") as.character(v23) else NA,
         n = if (m == "1m") N_PAISES_1M else N_PAISES, universe = if (m == "1m") UNIVERSO_1M else UNIVERSO_237)
}
vs_c <- tab_vent$n_237[tab_vent$ventana %in% VENT_SENS & tab_vent$tipo == "C"]
anotar("n_grow_only_migration_sens_range", value = formatear_rango(min(vs_c), max(vs_c), "0"), unit = "countries and areas", fmt = "text",
       def = "Range of n_grow_only_migration_2023 when the lever type is computed with 2021, 2022, 2023 or the 2021-2023 sums ('depending on the year')",
       filter = "237 countries and areas, estimates 2021-2023", source_cell = "Q1-3.1", used_in = c("slide1.build3"),
       method = "sensitivity", status = "descriptive", sens_low = min(vs_c), sens_high = max(vs_c),
       sens_note = sprintf("pre-COVID 2017-2019: %d (not in the on-screen range)", tab_vent$n_237[tab_vent$ventana == "2017-2019" & tab_vent$tipo == "C"]),
       n = N_PAISES, universe = UNIVERSO_237)

# 3.2 Ejemplos por regla: los 3 países más poblados (>= 1 M) de cada tipo
ejemplos <- lapply(c(A = "A", B = "B", C = "C", D = "D", E = "E"), function(tp) {
  t23 |> filter(pob_1m, tipo == tp) |> arrange(desc(pop_2023_miles)) |> slice_head(n = 3)
})
for (tp in names(ejemplos)) {
  e <- ejemplos[[tp]]
  informar("Ejemplos tipo %s: %s", tp, paste(e$Location, collapse = ", "))
  anotar(paste0("examples_type_", tp), value = I(e$Location), unit = NA, fmt = "text",
         def = sprintf("Rule: the three most populous countries (>= 1 M) of lever type %s in 2023 (WPP names)", tp),
         filter = "161 countries >= 1 M, 2023 (estimate)", source_cell = "Q1-3.2",
         used_in = if (tp %in% c("C", "D", "E")) c("slide1.build4", "narration.slide1") else c("notebook.T2"),
         method = "descriptive", status = "descriptive", sens_note = paste("ISO3:", paste(e$ISO3_code, collapse = ", ")),
         n = sum(t23$pob_1m & t23$tipo == tp), universe = UNIVERSO_1M)
  anotar(paste0("examples_type_", tp, "_iso3"), value = I(e$ISO3_code), unit = NA, fmt = "text",
         def = sprintf("ISO3 codes of examples_type_%s (for flags)", tp),
         filter = "161 countries >= 1 M, 2023 (estimate)", source_cell = "Q1-3.2", used_in = c("slide1.build4"),
         method = "descriptive", status = "descriptive", n = sum(t23$pob_1m & t23$tipo == tp), universe = UNIVERSO_1M)
}
anotar("cover_flags", value = I(ejemplos$C$ISO2_code), unit = NA, fmt = "text",
       def = "ISO2 codes of examples_type_C (three most populous countries >= 1 M growing only through net arrivals, 2023)",
       filter = "161 countries >= 1 M, 2023 (estimate)", source_cell = "Q1-3.2", used_in = c("cover.build3"),
       method = "descriptive", status = "descriptive", n = sum(t23$pob_1m & t23$tipo == "C"), universe = UNIVERSO_1M)

# 3.3 Inercia: bajo reemplazo y aun así crecen por saldo natural (tipo B)
t23 <- t23 |> mutate(bajo_reemplazo_2023 = TFR < TFR_REEMPLAZO,
                     inercia_bajo_reemplazo = tipo == "B" & bajo_reemplazo_2023,
                     inercia_estricta = inercia_bajo_reemplazo & NetMigrations < 0)
inr <- t23 |> filter(inercia_bajo_reemplazo) |> arrange(desc(pop_2023_miles))
inr_nrr <- t23 |> filter(tipo == "B", NRR < 1)
n_inr <- nrow(inr); pop_inr <- sum(inr$pop_2023_miles) / 1e6
n_inr_e <- sum(inr$inercia_estricta); pop_inr_e <- sum(inr$pop_2023_miles[inr$inercia_estricta]) / 1e6
informar("Inercia: %d países, %.3f mil M (estricta: %d, %.3f mil M); con NRR < 1: %d, %.3f mil M; migración neta = 0: %s",
         n_inr, pop_inr, n_inr_e, pop_inr_e, nrow(inr_nrr), sum(inr_nrr$pop_2023_miles) / 1e6,
         paste(inr$ISO3_code[!inr$inercia_estricta], collapse = ", "))
ej_mom <- inr |> filter(pob_1m) |> slice_head(n = 3)
anotar("n_momentum_countries", value = n_inr, unit = "countries and areas", fmt = "0",
       def = "Below replacement (TFR < 2.1) and growing from births with no net immigration (type B: NatChange > 0, NetMigrations <= 0, PopChange > 0), 2023",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-3.3",
       used_in = c("slide1.build3", "narration.slide1", "slide4.table"), method = "none_census",
       sens_low = min(n_inr_e, nrow(inr_nrr)), sens_high = max(n_inr, nrow(inr_nrr)),
       sens_note = sprintf("strict net emigration (NetMigrations < 0): %d · NRR < 1 instead of TFR < 2.1: %d · net migration exactly 0: %s",
                           n_inr_e, nrow(inr_nrr), paste(inr$ISO3_code[!inr$inercia_estricta], collapse = ", ")),
       status = "exploratory", hypothesis_id = "H19", say = as.character(n_inr), n = N_PAISES, universe = UNIVERSO_237)
anotar("n_momentum_emig", value = n_inr_e, unit = "countries and areas", fmt = "0",
       def = "Strict variant of n_momentum_countries: type B, TFR < 2.1 and NetMigrations < 0 (net emigration), 2023",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-3.3", used_in = c("notebook.T2"),
       method = "none_census", status = "exploratory", hypothesis_id = "H19", n = N_PAISES, universe = UNIVERSO_237)
anotar("pop_momentum_bn", value = round(pop_inr, 4), unit = "billion people", fmt = "0.0",
       def = "Population (1 July 2023) of the n_momentum_countries",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-3.3",
       used_in = c("slide1.build3", "narration.slide1", "slide4.table"), method = "none_census",
       sens_low = round(min(pop_inr_e, sum(inr_nrr$pop_2023_miles) / 1e6), 4),
       sens_high = round(max(pop_inr, sum(inr_nrr$pop_2023_miles) / 1e6), 4),
       sens_note = sprintf("strict net emigration: %.2f bn · NRR < 1: %.2f bn", pop_inr_e, sum(inr_nrr$pop_2023_miles) / 1e6),
       status = "exploratory", hypothesis_id = "H19", say = "2.2", n = n_inr, universe = UNIVERSO_237)
anotar("examples_momentum", value = I(ej_mom$Location), unit = NA, fmt = "text",
       def = "Rule: the three most populous countries (>= 1 M) of n_momentum_countries", filter = "237 countries and areas, 2023",
       source_cell = "Q1-3.3", used_in = c("slide1.build3"), method = "descriptive", status = "descriptive",
       sens_note = paste("ISO3:", paste(ej_mom$ISO3_code, collapse = ", ")), n = n_inr, universe = UNIVERSO_237)

# 3.3b "Reloj" de la inercia: años entre bajar de 2,1 hijos y el pico de población
# QUÉ: para cada país con inercia, el año en que su TFR quedó por debajo de 2,1
#      (último cruce, estimación) y el año del máximo de su población desde 2023
#      (UN medium projection); también los años que faltan desde 2023.
# POR QUÉ: la tabla de la Slide 4 dice cuántos años más crecerán; el método lo
#      pidió demografía [DEM] y China da el único caso ya observado (1991 -> 2021).
#      El pico es un escenario de la ONU, no una observación: se rotula así.
reloj <- datos_paises |> filter(ISO3_code %in% c(inr$ISO3_code, "CHN")) |> arrange(ISO3_code, Time) |>
  group_by(ISO3_code, Location, pob_1m) |>
  summarise(cruce_21 = { x <- TFR[Time <= ANIO_BASE]; t <- Time[Time <= ANIO_BASE]
                         if (all(x < TFR_REEMPLAZO)) NA_real_ else if (tail(x, 1) >= TFR_REEMPLAZO) Inf else t[max(which(x >= TFR_REEMPLAZO)) + 1] },
            pico_obs = Time[Time <= ANIO_BASE][which.max(TPopulation1July[Time <= ANIO_BASE])],
            pico_futuro = Time[Time >= ANIO_BASE][which.max(TPopulation1July[Time >= ANIO_BASE])],
            pop_2023_miles = TPopulation1July[Time == ANIO_BASE], pop_pico_miles = max(TPopulation1July[Time >= ANIO_BASE]),
            edad_mediana_2023 = MedianAgePop[Time == ANIO_BASE],
            edad_mediana_pico = MedianAgePop[Time >= ANIO_BASE][which.max(TPopulation1July[Time >= ANIO_BASE])], .groups = "drop") |>
  mutate(es_inercia = ISO3_code %in% inr$ISO3_code,
         pico = ifelse(es_inercia, pico_futuro, pico_obs),
         pico_es_proyeccion = pico >= ANIO_INICIO_PROYECCION,
         anios_reloj = pico - cruce_21, anios_desde_2023 = ifelse(es_inercia, pico - ANIO_BASE, NA_real_),
         pico_censurado_2100 = pico == ANIO_MAX_VALIDO)
stopifnot(all(is.finite(reloj$cruce_21)))
r_mom <- reloj |> filter(es_inercia)
r_mom1m <- r_mom |> filter(pob_1m)
chn_reloj <- reloj |> filter(ISO3_code == "CHN")
q_txt <- function(x) sprintf("P25-P50-P75 %.0f-%.0f-%.0f", quantile(x, 0.25), median(x), quantile(x, 0.75))
informar("Reloj de la inercia (>= 1 M, n = %d): %s años desde bajar de 2,1 al pico proyectado; desde 2023: %s | 22 países: %s | China (observado): %d -> %d = %d años",
         nrow(r_mom1m), q_txt(r_mom1m$anios_reloj), q_txt(r_mom1m$anios_desde_2023), q_txt(r_mom$anios_reloj),
         chn_reloj$cruce_21, chn_reloj$pico, chn_reloj$anios_reloj)
F_MOM <- sprintf("%d momentum countries >= 1 M (type B with TFR < 2.1 in 2023); TFR crossing = estimate; population peak = UN medium projection (2023-2100)", nrow(r_mom1m))
# Nota: la clave `momentum_years_range` de la tabla de la Slide 4 ("X more years
# of growth") la registra Q3 (R/04_q3_caminos.R, años desde 2023 hasta el pico,
# mediana ponderada por población). Q1 NO la registra para no chocar al combinar
# numbers_q*.json; aquí se guarda el "reloj" (desde el cruce de 2,1) con otro nombre.
anotar("momentum_clock_years_range", value = formatear_rango(quantile(r_mom1m$anios_reloj, 0.25), quantile(r_mom1m$anios_reloj, 0.75), "0"),
       unit = "years", fmt = "text",
       def = "Momentum clock: interquartile range of the years between the year fertility fell below 2.1 for the last time (estimate) and the year of maximum population (UN medium projection), momentum countries >= 1 M",
       filter = F_MOM, source_cell = "Q1-3.3b", used_in = c("notebook.T2"), method = "descriptive", status = "exploratory",
       hypothesis_id = "H19", sens_low = round(min(r_mom1m$anios_reloj), 1), sens_high = round(max(r_mom1m$anios_reloj), 1),
       sens_note = sprintf("median %.0f; all 22 momentum countries IQR %s; years still to go from 2023 to the projected peak (>= 1 M): IQR %s, median %.0f; China (observed): %d -> %d = %d years; peak is a UN scenario, not an observation",
                           median(r_mom1m$anios_reloj), formatear_rango(quantile(r_mom$anios_reloj, 0.25), quantile(r_mom$anios_reloj, 0.75), "0"),
                           formatear_rango(quantile(r_mom1m$anios_desde_2023, 0.25), quantile(r_mom1m$anios_desde_2023, 0.75), "0"),
                           median(r_mom1m$anios_desde_2023), chn_reloj$cruce_21, chn_reloj$pico, chn_reloj$anios_reloj),
       n = nrow(r_mom1m), universe = UNIVERSO_1M)
anotar("momentum_years_to_peak_range", value = formatear_rango(quantile(r_mom1m$anios_desde_2023, 0.25), quantile(r_mom1m$anios_desde_2023, 0.75), "0"),
       unit = "years", fmt = "text",
       def = "Years still to go from 2023 to the year of maximum population (UN medium projection), interquartile range across momentum countries >= 1 M (unweighted; the on-screen key momentum_years_range is registered by Q3, population-weighted)",
       filter = F_MOM, source_cell = "Q1-3.3b", used_in = c("notebook.T2"), method = "descriptive", status = "exploratory",
       hypothesis_id = "H19", sens_low = min(r_mom1m$anios_desde_2023), sens_high = max(r_mom1m$anios_desde_2023),
       sens_note = paste("peak year by country:", paste(sprintf("%s %d", r_mom1m$ISO3_code, r_mom1m$pico), collapse = "; ")),
       n = nrow(r_mom1m), universe = UNIVERSO_1M)
anotar("momentum_clock_chn_years", value = chn_reloj$anios_reloj, unit = "years", fmt = "0",
       def = "China: years between the last time its fertility fell below 2.1 and its population peak (both observed, estimates)",
       filter = "China, estimates 1950-2023", source_cell = "Q1-3.3b", used_in = c("notebook.T2"), method = "descriptive",
       status = "descriptive", sens_note = sprintf("TFR below 2.1 from %d; population peak %d (%.0f million)", chn_reloj$cruce_21, chn_reloj$pico, chn_reloj$pop_pico_miles / 1e3),
       say = "thirty", n = 1, universe = "China")

# 3.3c Figura de revisión del gancho (130 -> 84 = 66 + 18) y del reloj de la inercia
gancho_df <- t23 |> filter(bajo_reemplazo_2023) |>
  mutate(grupo = case_when(tipo == "B" ~ "Growing from births, no net arrivals (momentum)",
                           tipo == "A" ~ "Growing from births, plus net arrivals",
                           tipo == "C" ~ "Growing only through net arrivals",
                           tipo == "D" ~ "Shrinking: deaths > births",
                           tipo == "E" ~ "Shrinking: more leave than arrive")) |>
  count(grupo) |>
  mutate(grupo = factor(grupo, levels = rev(c("Growing from births, no net arrivals (momentum)", "Growing from births, plus net arrivals",
                                              "Growing only through net arrivals", "Shrinking: deaths > births", "Shrinking: more leave than arrive"))))
p4a <- ggplot(gancho_df, aes(n, grupo, fill = grupo)) + geom_col(width = 0.7) +
  geom_text(aes(label = n), hjust = -0.3, size = 4) +
  scale_fill_manual(values = setNames(c(COLOR_EMIGRACION, COLOR_DEFUNCIONES, COLOR_MIGRACION, COLOR_NACIMIENTOS, "#004B7A"), levels(gancho_df$grupo)), guide = "none") +
  expand_limits(x = max(gancho_df$n) * 1.15) +
  labs(x = "Countries and areas (2023)", y = NULL,
       title = sprintf("A · %d below replacement: %d still grow (%d from births + %d only through net arrivals)",
                       g_main["n"], g_main["crecen"], g_main["nat"], g_main["solo_mig"])) + tema_q1(11)
fig_reloj <- r_mom1m |> mutate(Location = factor(Location, levels = Location[order(anios_reloj)]))
p4b <- ggplot(fig_reloj) +
  annotate("rect", xmin = ANIO_INICIO_PROYECCION - 0.5, xmax = ANIO_MAX_VALIDO, ymin = -Inf, ymax = Inf, fill = COLOR_PROYECCION_SOMBRA) +
  geom_segment(aes(x = cruce_21, xend = ANIO_BASE, y = Location, yend = Location), colour = "black", linewidth = 1.1) +
  geom_segment(aes(x = ANIO_BASE, xend = pico, y = Location, yend = Location), colour = COL_GRIS, linewidth = 1.1, linetype = "22") +
  geom_point(aes(cruce_21, Location), size = 2.4, colour = COLOR_NACIMIENTOS) +
  geom_point(aes(pico, Location), size = 2.4, shape = 21, fill = "white", colour = "black") +
  geom_text(aes(pico, Location, label = anios_reloj), hjust = -0.6, size = 3.2) +
  geom_vline(xintercept = ANIO_BASE + 0.5, linetype = "dotted") +
  labs(x = NULL, y = NULL,
       title = sprintf("B · Momentum clock: %s years from TFR < 2.1 to the projected population peak (IQR, %d countries >= 1 M)",
                       formatear_rango(quantile(r_mom1m$anios_reloj, 0.25), quantile(r_mom1m$anios_reloj, 0.75), "0"), nrow(r_mom1m)),
       subtitle = sprintf("Blue dot: last year TFR fell below 2.1 (estimate). Open dot: peak year (UN medium projection, shaded). China (observed): %d -> %d, %d years.",
                          chn_reloj$cruce_21, chn_reloj$pico, chn_reloj$anios_reloj)) + tema_q1(11)
p4 <- (p4a / p4b) + plot_layout(heights = c(1, 2)) +
  plot_annotation(caption = pie_q1(badge("PIE-1"), "Projected peaks are UN medium projection scenarios, not forecasts."))
guardar_q1(p4, "q1_04_gancho_inercia")

# 3.4 Bajo reemplazo por tipo, concordancia entre ventanas y tipo E con TFR alta
br_tipo <- table(factor(t23$tipo[t23$bajo_reemplazo_2023], levels = c("A", "B", "C", "D", "E")))
conc <- t23 |> select(ISO3_code, tipo) |> inner_join(tv[["2021-2023"]] |> select(ISO3_code, tipo2123 = tipo), by = "ISO3_code")
pct_conc <- 100 * mean(conc$tipo == conc$tipo2123, na.rm = TRUE)
pct_conc_ab <- 100 * mean(ifelse(conc$tipo %in% c("A", "B"), "AB", conc$tipo) == ifelse(conc$tipo2123 %in% c("A", "B"), "AB", conc$tipo2123), na.rm = TRUE)
e_alto <- t23 |> filter(tipo == "E", TFR >= TFR_REEMPLAZO)
informar("Bajo reemplazo por tipo: %s | concordancia 2023 vs 2021-23: %.1f %% (A/B fundidos %.1f %%) | tipo E con TFR >= 2,1: %d (%s; máx. %.0f mil hab.)",
         paste(names(br_tipo), br_tipo, sep = "=", collapse = " "), pct_conc, pct_conc_ab, nrow(e_alto),
         paste(e_alto$ISO3_code, collapse = ", "), max(e_alto$pop_2023_miles))
anotar("n_below_repl_by_type", value = setNames(as.integer(br_tipo), names(br_tipo)), unit = "countries and areas", fmt = "0",
       def = "Countries with TFR < 2.1 in 2023 by lever type (A-E)", filter = "237 countries and areas, 2023 (estimate)",
       source_cell = "Q1-3.4", used_in = c("notebook.T2"), method = "none_census", status = "descriptive",
       n = unname(g_main["n"]), universe = UNIVERSO_237)
anotar("type_concordance_2023_2021_23", value = round(pct_conc, 4), unit = "%", fmt = "0.0",
       def = "Share of countries with the same lever type (A-E) in 2023 and in the 2021-2023 window",
       filter = "237 countries and areas", source_cell = "Q1-3.4", used_in = c("notebook.T2"), method = "descriptive",
       status = "descriptive", sens_note = sprintf("with A and B merged: %.1f %%", pct_conc_ab), n = nrow(conc), universe = UNIVERSO_237)
anotar("n_type_E_tfr_ge21", value = nrow(e_alto), unit = "countries and areas", fmt = "0",
       def = "Countries shrinking although births exceed deaths (type E) with TFR >= 2.1, 2023",
       filter = "237 countries and areas, 2023 (estimate)", source_cell = "Q1-3.4", used_in = c("notebook.T2"),
       method = "none_census", status = "descriptive",
       sens_note = sprintf("%s; largest population %.0f thousand", paste(e_alto$ISO3_code, collapse = ", "), max(e_alto$pop_2023_miles)),
       n = N_PAISES, universe = UNIVERSO_237)

# 3.5 Lista completa por país (figures/miembros_tipo_palanca.csv)
tipos_por_ventana <- Reduce(function(a, b) left_join(a, b, by = "ISO3_code"),
                            lapply(names(tv), function(v) tv[[v]] |> select(ISO3_code, tipo) |> rename(!!paste0("tipo_", gsub("-", "_", v)) := tipo)))
miembros <- t23 |> select(ISO3_code, ISO2_code, Location, region_sdg, subregion, ingreso, pob_1m, pop_2023_miles, TFR, NRR,
                          NatChange_2023 = NatChange, NetMigrations_2023 = NetMigrations, PopChange_2023 = PopChange,
                          tipo_palanca_2023 = tipo, tipo_ab_2023 = tipo_ab, bajo_reemplazo_2023,
                          inercia_bajo_reemplazo, inercia_estricta) |>
  left_join(tipos_por_ventana |> select(-tipo_2023), by = "ISO3_code") |>
  mutate(ejemplo_por_regla = case_when(ISO3_code %in% ejemplos$C$ISO3_code ~ "C", ISO3_code %in% ejemplos$D$ISO3_code ~ "D",
                                       ISO3_code %in% ejemplos$E$ISO3_code ~ "E", ISO3_code %in% ej_mom$ISO3_code ~ "momentum",
                                       TRUE ~ NA_character_)) |>
  arrange(tipo_palanca_2023, desc(pop_2023_miles))
readr::write_csv(miembros, file.path(RUTA_FIGURAS, "miembros_tipo_palanca.csv"))

# 3.6 Figuras de revisión: mapa 2023 y ventanas
iso_natural_earth <- function(ne) {
  iso <- ifelse(ne$iso_a3_eh != "-99", ne$iso_a3_eh, ne$adm0_a3)
  recod <- c(SOL = "SOM", KOS = "XKX", CYN = "CYP", ALA = "FIN")   # códigos WPP (memo espacial)
  ifelse(iso %in% names(recod), recod[iso], iso)
}
ne <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
ne$iso3 <- iso_natural_earth(ne)
lab_tipo <- c(AB = sprintf("%s · %d", ETIQUETAS_PALANCA_EN[["AB"]], sum(t23$tipo_ab == "AB")),
              C = sprintf("%s · %d", ETIQUETAS_PALANCA_EN[["C"]], sum(t23$tipo == "C")),
              D = sprintf("%s · %d", ETIQUETAS_PALANCA_EN[["D"]], sum(t23$tipo == "D")),
              E = sprintf("%s · %d", ETIQUETAS_PALANCA_EN[["E"]], sum(t23$tipo == "E")))
mapa <- ne |> filter(iso3 != "ATA") |>
  left_join(t23 |> select(ISO3_code, tipo_ab, pob_1m, inercia_bajo_reemplazo), by = c("iso3" = "ISO3_code")) |>
  mutate(clase = factor(ifelse(is.na(tipo_ab), "nodata", tipo_ab), levels = c("AB", "C", "D", "E", "nodata")),
         alfa = ifelse(pob_1m %in% TRUE, 1, 0.45))
mapa <- suppressWarnings(sf::st_transform(mapa, "+proj=robin"))
p2 <- ggplot(mapa) +
  geom_sf(aes(fill = clase, alpha = alfa), colour = "white", linewidth = 0.08) +
  geom_sf(data = mapa |> filter(inercia_bajo_reemplazo %in% TRUE), fill = NA, colour = "black", linewidth = 0.35) +
  scale_fill_manual(values = c(AB = COLOR_NACIMIENTOS, C = COLOR_MIGRACION, D = COLOR_DEFUNCIONES, E = COLOR_EMIGRACION, nodata = COLOR_SIN_DATOS),
                    labels = c(lab_tipo, nodata = "No data / not matched"), name = NULL) +
  scale_alpha_identity() + coord_sf(crs = "+proj=robin", datum = NA) +
  labs(title = "Which lever moves each country's population in 2023",
       subtitle = sprintf("Black outline: below replacement yet growing from births (%d countries, %.2f bn people). Faded: < 1 M people.", n_inr, pop_inr),
       caption = pie_q1(badge("PIE-1"), DEF_PALANCA_EN,
                        "Boundaries and names shown do not imply official endorsement or acceptance by the United Nations. Map: Natural Earth (review map: Crimea not yet reassigned).")) +
  tema_q1(12) + theme(legend.position = "bottom", legend.text = element_text(size = rel(0.75))) +
  guides(fill = guide_legend(nrow = 2))
guardar_q1(p2, "q1_02_mapa_palancas_2023")

fig_vent <- tab_vent |> filter(tipo %in% c("A", "B", "C", "D", "E")) |>
  mutate(ventana = factor(ventana, levels = c("2017-2019", "2021", "2022", "2023", "2021-2023")))
fig_vent <- fig_vent |> mutate(panel = factor(paste0(tipo, ": ", ETIQUETAS_PALANCA_EN[tipo]), levels = paste0(c("A", "B", "C", "D", "E"), ": ", ETIQUETAS_PALANCA_EN[c("A", "B", "C", "D", "E")])),
                                base = ventana == "2023")
p3 <- ggplot(fig_vent, aes(ventana, n_237, fill = tipo, alpha = base)) +
  geom_col(width = 0.7) + geom_text(aes(label = n_237), vjust = -0.4, size = 3.4, alpha = 1) +
  facet_wrap(~panel, nrow = 1, labeller = label_wrap_gen(22)) +
  scale_fill_manual(values = c(A = "#004B7A", B = COLOR_NACIMIENTOS, C = COLOR_MIGRACION, D = COLOR_DEFUNCIONES, E = COLOR_EMIGRACION), guide = "none") +
  scale_alpha_manual(values = c(`TRUE` = 1, `FALSE` = 0.45), guide = "none") +
  labs(x = "Window used to classify (sums of people)", y = "Countries and areas (of 237)",
       title = sprintf("Counts depend on the year: 'growing only through net arrivals' is %s countries (%d before COVID-19)", formatear_rango(min(vs_c), max(vs_c), "0"), tab_vent$n_237[tab_vent$ventana == "2017-2019" & tab_vent$tipo == "C"]),
       subtitle = "2023 (dark bars) is the base year everywhere; 2021–2023 contains COVID-19 excess deaths and 2022 displacement from Ukraine",
       caption = pie_q1(badge("PIE-1"))) +
  tema_q1(11) + theme(axis.text.x = element_text(angle = 60, hjust = 1))
guardar_q1(p3, "q1_03_ventanas_sensibilidad")

# =============================================================================
# 4. ¿Se parecen los vecinos? Moran's I (dependencia espacial)
# =============================================================================
# QUÉ: mide cuánto se parecen los países vecinos (5 más cercanos) en
#      fecundidad, esperanza de vida, edad mediana, crecimiento y migración.
# POR QUÉ: responde la cláusula "region" de P7 con una cifra (los vecinos
#      comparten fecundidad, casi no migración) y justifica los IC por bloques.
seccion("4. Moran's I")

ne_pts <- sf::st_drop_geometry(ne) |>
  transmute(iso3, principal = adm0_a3 == iso3, lon = label_x, lat = label_y) |>
  arrange(iso3, desc(principal)) |> distinct(iso3, .keep_all = TRUE)
haversine <- function(lon, lat) {
  rad <- pi / 180; R <- 6371.0088
  la <- lat * rad; lo <- lon * rad
  a <- sin(outer(la, la, "-") / 2)^2 + outer(cos(la), cos(la)) * sin(outer(lo, lo, "-") / 2)^2
  2 * R * asin(pmin(sqrt(a), 1))
}
dist_iso <- function(iso) {
  p <- ne_pts[match(iso, ne_pts$iso3), ]
  if (anyNA(p$lon)) stop("Países sin punto representativo: ", paste(iso[is.na(p$lon)], collapse = ", "))
  haversine(p$lon, p$lat)
}
W_knn <- function(iso, k = K_VECINOS) {
  D <- dist_iso(iso); diag(D) <- Inf
  t(apply(D, 1, function(r) { w <- numeric(length(r)); w[order(r)[1:k]] <- 1 / k; w }))
}
W_idw <- function(iso, corte = 2000) {
  D <- dist_iso(iso); W <- ifelse(D > 0 & D <= corte, 1 / D, 0)
  sinv <- which(rowSums(W) == 0)
  if (length(sinv)) { Dd <- D; diag(Dd) <- Inf; for (i in sinv) W[i, which.min(Dd[i, ])] <- 1 }
  W / rowSums(W)
}
moran <- function(x, W) { z <- x - mean(x); (length(x) / sum(W)) * sum(z * (W %*% z)) / sum(z^2) }
moran_perm <- function(x, W, B = B_PERM_Q1) {
  I0 <- moran(x, W)
  set.seed(SEM)
  Ip <- replicate(B, moran(sample(x), W))
  c(I = I0, p = (1 + sum(Ip >= I0)) / (B + 1), nulo_lo = unname(quantile(Ip, 0.025)), nulo_hi = unname(quantile(Ip, 0.975)))
}
moran_jack <- function(x, iso, Wfun = W_knn) {
  n <- length(x)
  Ij <- vapply(seq_len(n), function(i) moran(x[-i], Wfun(iso[-i])), numeric(1))
  se <- sqrt((n - 1) / n * sum((Ij - mean(Ij))^2)); I0 <- moran(x, Wfun(iso))
  c(jk_lo = I0 - 1.96 * se, jk_hi = I0 + 1.96 * se)
}
VARS_MORAN <- c(TFR = "Fertility (TFR)", LEx = "Life expectancy", MedianAgePop = "Median age",
                PopGrowthRate = "Growth rate", CNMR = "Net migration rate")
mor <- list()
for (anio in c(1950, 1990, 2023)) {
  d <- corte_anio(anio, "1m") |> arrange(ISO3_code)
  W <- W_knn(d$ISO3_code)
  for (v in names(VARS_MORAN)) {
    pm <- moran_perm(d[[v]], W); jk <- moran_jack(d[[v]], d$ISO3_code)
    pr <- moran_perm(rank(d[[v]]), W)
    mor[[length(mor) + 1]] <- tibble(indicador = v, anio = anio, version = c("classic", "ranks"), W = "kNN5",
                                     muestra = "161 >= 1 M", n = nrow(d), I = c(pm["I"], pr["I"]), p_perm = c(pm["p"], pr["p"]),
                                     nulo_lo = c(pm["nulo_lo"], pr["nulo_lo"]), nulo_hi = c(pm["nulo_hi"], pr["nulo_hi"]),
                                     jk_lo = c(jk["jk_lo"], NA), jk_hi = c(jk["jk_hi"], NA))
  }
}
d23 <- corte_anio(2023, "1m") |> arrange(ISO3_code)
d23_ng <- d23 |> filter(!es_golfo(ISO3_code))
pm_ng <- moran_perm(d23_ng$CNMR, W_knn(d23_ng$ISO3_code)); jk_ng <- moran_jack(d23_ng$CNMR, d23_ng$ISO3_code)
mor[[length(mor) + 1]] <- tibble(indicador = "CNMR", anio = 2023, version = "classic", W = "kNN5", muestra = "155 >= 1 M, no Gulf",
                                 n = nrow(d23_ng), I = pm_ng["I"], p_perm = pm_ng["p"], nulo_lo = pm_ng["nulo_lo"],
                                 nulo_hi = pm_ng["nulo_hi"], jk_lo = jk_ng["jk_lo"], jk_hi = jk_ng["jk_hi"])
# Sensibilidad a W (4 matrices más) y a la muestra (todos los países con punto representativo)
Ws <- list(kNN4 = W_knn(d23$ISO3_code, 4), kNN6 = W_knn(d23$ISO3_code, 6), kNN8 = W_knn(d23$ISO3_code, 8),
           IDW2000 = W_idw(d23$ISO3_code, 2000))
for (wn in names(Ws)) for (v in names(VARS_MORAN)) {
  mor[[length(mor) + 1]] <- tibble(indicador = v, anio = 2023, version = "classic", W = wn, muestra = "161 >= 1 M",
                                   n = nrow(d23), I = moran(d23[[v]], Ws[[wn]]))
}
d23_all <- corte_anio(2023, "completa") |> filter(ISO3_code %in% ne_pts$iso3) |> arrange(ISO3_code)
W_all <- W_knn(d23_all$ISO3_code)
for (v in names(VARS_MORAN)) {
  mor[[length(mor) + 1]] <- tibble(indicador = v, anio = 2023, version = "classic", W = "kNN5",
                                   muestra = sprintf("%d of 237 (with a map point)", nrow(d23_all)), n = nrow(d23_all),
                                   I = moran(d23_all[[v]], W_all))
}
# Residuos tras región SDG + ingreso (160 países con grupo de ingreso)
d23_res <- d23 |> filter(ingreso != "Not classified")
W_res <- W_knn(d23_res$ISO3_code)
for (v in c("TFR", "CNMR")) {
  r <- resid(lm(d23_res[[v]] ~ d23_res$region_sdg + droplevels(d23_res$ingreso)))
  pm <- moran_perm(r, W_res)
  mor[[length(mor) + 1]] <- tibble(indicador = v, anio = 2023, version = "residual (region + income)", W = "kNN5",
                                   muestra = "160 >= 1 M with income group", n = nrow(d23_res), I = pm["I"], p_perm = pm["p"],
                                   nulo_lo = pm["nulo_lo"], nulo_hi = pm["nulo_hi"])
}
mor <- bind_rows(mor)
print(mor |> filter(anio == 2023, W == "kNN5", muestra == "161 >= 1 M") |> mutate(across(where(is.numeric), \(x) round(x, 3))))
print(mor |> filter(muestra != "161 >= 1 M" | W != "kNN5") |> mutate(across(where(is.numeric), \(x) round(x, 3))), n = 40)
m23 <- mor |> filter(anio == 2023, version == "classic", W == "kNN5", muestra == "161 >= 1 M")
sens_W <- mor |> filter(anio == 2023, version == "classic", muestra == "161 >= 1 M") |> group_by(indicador) |>
  summarise(lo = min(I), hi = max(I))
claves_moran <- c(TFR = "moran_tfr_2023", LEx = "moran_lex_2023", MedianAgePop = "moran_medage_2023",
                  CNMR = "moran_cnmr_2023", PopGrowthRate = "moran_growth_2023")
for (v in names(claves_moran)) {
  x <- m23 |> filter(indicador == v); s <- sens_W |> filter(indicador == v)
  anotar(claves_moran[[v]], value = round(x$I, 4), unit = "Moran's I", fmt = "0.00",
         def = sprintf("Global Moran's I of %s across countries, 2023; W = 5 nearest neighbours (haversine between Natural Earth label points), row-standardised", v),
         filter = "161 countries >= 1 M, 2023 (estimate)", source_cell = "Q1-4.1",
         used_in = if (v %in% c("TFR", "CNMR")) c("slide2.build4") else c("notebook.T7"),
         method = "permutation", B = B_PERM_Q1, seed = SEM, sens_low = round(s$lo, 4), sens_high = round(s$hi, 4),
         sens_note = sprintf("W = kNN4/5/6/8 and inverse distance <= 2000 km; jackknife 95%% [%.2f; %.2f]; null 95%% band [%.2f; %.2f]",
                             x$jk_lo, x$jk_hi, x$nulo_lo, x$nulo_hi),
         p_value = x$p_perm, status = "exploratory", hypothesis_id = "H24", n = x$n, universe = UNIVERSO_1M)
}
anotar("moran_cnmr_2023_nogulf", value = round(unname(pm_ng["I"]), 4), unit = "Moran's I", fmt = "0.00",
       def = "Global Moran's I of the net migration rate, 2023, excluding the six Gulf states (W recomputed, kNN5)",
       filter = "155 countries >= 1 M without ARE, QAT, KWT, BHR, OMN, SAU, 2023", source_cell = "Q1-4.1",
       used_in = c("slide2.build4"), method = "permutation", B = B_PERM_Q1, seed = SEM,
       sens_note = sprintf("jackknife 95%% [%.2f; %.2f]; null band [%.2f; %.2f]", jk_ng["jk_lo"], jk_ng["jk_hi"], pm_ng["nulo_lo"], pm_ng["nulo_hi"]),
       p_value = unname(pm_ng["p"]), status = "exploratory", hypothesis_id = "H24", n = nrow(d23_ng), universe = UNIVERSO_1M)
gr_rank <- mor |> filter(indicador == "PopGrowthRate", version == "ranks", W == "kNN5", muestra == "161 >= 1 M")
for (a in c(1950, 2023)) {
  x <- gr_rank |> filter(anio == a)
  anotar(paste0("moran_growth_rank_", a), value = round(x$I, 4), unit = "Moran's I (ranks)", fmt = "0.00",
         def = sprintf("Moran's I of the rank of the population growth rate across countries, %d (kNN5)", a),
         filter = sprintf("161 countries >= 1 M, %d (estimate)", a), source_cell = "Q1-4.1", used_in = c("notebook.T7"),
         method = "permutation", B = B_PERM_Q1, seed = SEM, p_value = x$p_perm, status = "exploratory",
         n = x$n, universe = UNIVERSO_1M)
}
# 4.2 LISA de la migración neta: ¿dónde están los "vecindarios" migratorios?
# QUÉ: Moran local (Anselin 1995) de la CNMR media 2010-2023 y de 2023, con
#      permutación condicional (999) y corrección de Benjamini-Hochberg (FDR 5 %).
# POR QUÉ: la frase "alike among neighbours only in the Gulf" necesita saber qué
#      conglomerados sobreviven a 161 pruebas simultáneas, no solo el I global.
lisa <- function(x, W, B = B_PERM_Q1) {
  n <- length(x); z <- x - mean(x); m2 <- sum(z^2) / n
  k <- rowSums(W > 0)[1]; lag_z <- as.numeric(W %*% z)
  Ii <- z * lag_z / m2
  set.seed(SEM)
  p <- vapply(seq_len(n), function(i) {
    otros <- z[-i]
    Ip <- z[i] * vapply(seq_len(B), function(b) mean(sample(otros, k)), numeric(1)) / m2
    if (Ii[i] >= 0) (1 + sum(Ip >= Ii[i])) / (B + 1) else (1 + sum(Ip <= Ii[i])) / (B + 1)
  }, numeric(1))
  tibble(Ii = Ii, z = z, lag_z = lag_z, p = p, p_bh = p.adjust(p, "BH"),
         cuadrante = case_when(z > 0 & lag_z > 0 ~ "High-High", z < 0 & lag_z < 0 ~ "Low-Low",
                               z > 0 & lag_z < 0 ~ "High-Low", TRUE ~ "Low-High"))
}
v1023 <- resumen_ventana(2010:2023, "CNMR", muestra = "1m") |> arrange(ISO3_code)
stopifnot(identical(v1023$ISO3_code, d23$ISO3_code))
lisa_tab <- bind_rows(
  bind_cols(v1023 |> select(ISO3_code, Location, subregion), lisa(v1023$CNMR, W_knn(v1023$ISO3_code))) |> mutate(ventana = "2010-2023"),
  bind_cols(d23 |> select(ISO3_code, Location, subregion), lisa(d23$CNMR, W_knn(d23$ISO3_code))) |> mutate(ventana = "2023")) |>
  mutate(sig_05 = p < 0.05, sig_fdr = p_bh < 0.05)
lisa_res <- lisa_tab |> group_by(ventana, cuadrante) |> summarise(n_p05 = sum(sig_05), n_fdr = sum(sig_fdr),
                                                                  iso_fdr = paste(sort(ISO3_code[sig_fdr]), collapse = ", "), .groups = "drop")
print(lisa_res, width = 200)
hh_fdr <- lisa_tab |> filter(ventana == "2010-2023", sig_fdr, cuadrante == "High-High")
fdr_todos <- lisa_tab |> filter(ventana == "2010-2023", sig_fdr)
fdr_23 <- lisa_tab |> filter(ventana == "2023", sig_fdr)
informar("LISA CNMR 2010-23: %d países con p < 0,05; %d sobreviven a FDR (%s); alto-alto tras FDR: %s | 2023: %d tras FDR",
         sum(lisa_tab$sig_05[lisa_tab$ventana == "2010-2023"]), nrow(fdr_todos), paste(sprintf("%s %s", fdr_todos$ISO3_code, fdr_todos$cuadrante), collapse = ", "),
         paste(hh_fdr$ISO3_code, collapse = ", "), nrow(fdr_23))
anotar("lisa_cnmr_hh_fdr", value = nrow(hh_fdr), unit = "countries", fmt = "0", method = "permutation", B = B_PERM_Q1, seed = SEM,
       # QA-stats (docs/QA_stats.md): se declara la convención del p-valor (de un lado, "folded").
       def = sprintf(paste("Countries in a High-High local cluster of the mean net migration rate 2010-2023 (local Moran, kNN5 with equal weights,",
                           "conditional permutation with %d draws; one-sided 'folded' pseudo p-value in the direction of the observed local I,",
                           "(1 + number of permuted values at least as extreme) / (%d + 1), as in GeoDa) that survive Benjamini-Hochberg FDR",
                           "at 5%% over the %d local tests"), B_PERM_Q1, B_PERM_Q1, nrow(v1023)),
       filter = "161 countries >= 1 M, mean of annual estimates 2010-2023", source_cell = "Q1-4.2",
       used_in = c("slide2.build4", "notebook.T7"),
       sens_note = sprintf("ISO3: %s; with p < 0.05 (no correction): %d countries in any quadrant; all quadrants after FDR: %s; single year 2023: %d after FDR",
                           paste(hh_fdr$ISO3_code, collapse = ", "), sum(lisa_tab$sig_05[lisa_tab$ventana == "2010-2023"]),
                           paste(sprintf("%s (%s)", fdr_todos$ISO3_code, fdr_todos$cuadrante), collapse = ", "), nrow(fdr_23)),
       p_adj_method = "BH (161 local tests)", status = "exploratory", hypothesis_id = "H24", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("lisa_cnmr_hh_fdr_iso3", value = I(hh_fdr$ISO3_code), unit = NA, fmt = "text", method = "descriptive",
       def = "ISO3 codes of lisa_cnmr_hh_fdr", filter = "161 countries >= 1 M, 2010-2023", source_cell = "Q1-4.2",
       used_in = c("notebook.T7"), status = "exploratory", n = nrow(hh_fdr), universe = UNIVERSO_1M)
fig_lisa <- ne |> filter(iso3 != "ATA") |>
  left_join(lisa_tab |> filter(ventana == "2010-2023") |> select(ISO3_code, cuadrante, sig_05, sig_fdr), by = c("iso3" = "ISO3_code")) |>
  mutate(clase = case_when(is.na(cuadrante) ~ "< 1 M or no data", sig_fdr ~ paste(cuadrante, "(FDR 5%)"),
                           sig_05 ~ paste(cuadrante, "(p < 0.05 only)"), TRUE ~ "No local cluster"))
fig_lisa <- suppressWarnings(sf::st_transform(fig_lisa, "+proj=robin"))
col_lisa <- c("High-High (FDR 5%)" = "#004488", "High-High (p < 0.05 only)" = "#6699CC", "Low-Low (FDR 5%)" = "#994F00",
              "Low-Low (p < 0.05 only)" = "#E69F00", "High-Low (FDR 5%)" = "#882255", "High-Low (p < 0.05 only)" = "#CC79A7",
              "Low-High (FDR 5%)" = "#B8860B", "Low-High (p < 0.05 only)" = "#EECC66", "No local cluster" = "grey85", "< 1 M or no data" = "white")
p5b <- ggplot(fig_lisa) + geom_sf(aes(fill = clase), colour = "grey60", linewidth = 0.08) +
  scale_fill_manual(values = col_lisa[names(col_lisa) %in% unique(fig_lisa$clase)], name = NULL) +
  coord_sf(crs = "+proj=robin", datum = NA) +
  labs(title = if (nrow(hh_fdr) > 0) sprintf("Migration forms few local neighbourhoods: %d of %d countries survive the false-discovery correction (%d High-High)",
                                              nrow(fdr_todos), sum(lisa_tab$sig_05[lisa_tab$ventana == "2010-2023"]), nrow(hh_fdr))
               else sprintf("No local migration neighbourhood survives the false-discovery correction (%d with p < 0.05 before it)",
                            sum(lisa_tab$sig_05[lisa_tab$ventana == "2010-2023"])),
       subtitle = sprintf("Local Moran of mean net migration 2010–2023 (5 nearest neighbours, %d conditional permutations, BH 5%%).\nAfter FDR: %s.",
                          B_PERM_Q1, if (nrow(fdr_todos)) paste(vapply(split(fdr_todos$ISO3_code, fdr_todos$cuadrante), paste, "", collapse = ", ") |>
                                                                  (\(v) paste(names(v), v))(), collapse = " · ") else "none"),
       caption = pie_q1(PIE_MODELOS, "Boundaries and names shown do not imply official endorsement or acceptance by the United Nations. Map: Natural Earth.")) +
  tema_q1(12) + theme(legend.position = "bottom") + guides(fill = guide_legend(nrow = 2))
guardar_q1(p5b, "q1_05b_lisa_migracion")

fig_mor <- mor |> filter(version == "classic", W == "kNN5", muestra == "161 >= 1 M") |>
  mutate(indicador = factor(VARS_MORAN[indicador], levels = rev(VARS_MORAN)), anio = factor(anio))
p5 <- ggplot(fig_mor, aes(I, indicador, colour = anio)) +
  annotate("rect", xmin = min(fig_mor$nulo_lo), xmax = max(fig_mor$nulo_hi), ymin = -Inf, ymax = Inf, fill = "grey90") +
  geom_vline(xintercept = 0, colour = COL_GRIS) +
  geom_errorbar(aes(xmin = jk_lo, xmax = jk_hi), width = 0.25, orientation = "y", position = position_dodge(width = 0.6)) +
  geom_point(size = 3, position = position_dodge(width = 0.6)) +
  geom_text(data = fig_mor |> filter(anio == "2023"), aes(x = jk_hi, label = formatear_cifra(round(I, 4), "0.00")), hjust = -0.25, size = 3.4,
            position = position_nudge(y = 0.2), show.legend = FALSE) +
  scale_colour_manual(values = c(`1950` = "#BBBBBB", `1990` = "#6699CC", `2023` = "#004488"), name = NULL) +
  labs(x = "Moran's I (5 nearest neighbours)", y = NULL,
       title = "Neighbours share their fertility, survival and age — not their migration",
       subtitle = sprintf("Net migration 2023: I = %.2f; without the six Gulf states I = %.2f. Grey band: 95%% of random reshuffles. Bars: jackknife 95%%.",
                          m23$I[m23$indicador == "CNMR"], pm_ng["I"]),
       caption = pie_q1(PIE_MODELOS, "W = 5 nearest neighbours (Natural Earth label points). Neighbours look alike; this is not diffusion or contagion.")) + tema_q1(12)
guardar_q1(p5, "q1_05_moran_vecinos")

# =============================================================================
# 5. Supervivencia: ¿qué empieza a caer primero, la mortalidad infantil o la
#    fecundidad?
# =============================================================================
# QUÉ: fecha el inicio de la caída sostenida (regla de Princeton: primer año
#      con x <= 0,9 x máximo previo que no vuelve a superarse) de Q5 y TFR;
#      cuenta en cuántos países cae primero Q5 (Wilson), acota el rezago,
#      y estima con Kaplan-Meier el año de inicio de la caída de la
#      fecundidad por ingreso y región (log-rank, Cox).
# POR QUÉ: P7 pregunta por el orden; los umbrales absolutos (H3 de v1)
#      cambian la respuesta según el par elegido y descartan censurados.
seccion("5. Supervivencia: orden mortalidad -> fecundidad")

inicio_caida <- function(t, x, frac = UMBRAL_INICIO) {
  rm <- cummax(x); n <- length(x)
  # mínimo de la cola: x[i:n] <= lim  <=>  max(x[i:n]) <= lim
  cola_max <- rev(cummax(rev(x)))
  for (i in seq_len(n)) {
    lim <- frac * rm[i]
    if (x[i] <= lim && cola_max[i] <= lim) return(t[i])
  }
  NA_real_
}
base_ini <- function(frac = UMBRAL_INICIO) {
  est1m |> group_by(ISO3_code, Location, region_sdg, subregion, ingreso) |>
    summarise(tfr_1950 = TFR[Time == 1950], q5_1950 = Q5[Time == 1950],
              inicio_tfr = inicio_caida(Time, TFR, frac), inicio_q5 = inicio_caida(Time, Q5, frac),
              izq_q5 = which.max(Q5) == 1L, izq_tfr = which.max(TFR) == 1L, .groups = "drop")
}
bi <- base_ini()
el_todos <- bi |> filter(tfr_1950 >= TFR_ELEGIBLE_1950)
el <- el_todos |> filter(ingreso != "Not classified") |> mutate(ingreso = orden_ingreso(ingreso))
el <- el |> mutate(q5_observado = !is.na(inicio_q5),
                   mort_primero = q5_observado & (is.na(inicio_tfr) | inicio_q5 < inicio_tfr))
n_eleg <- nrow(el); n_onset <- sum(el$q5_observado); x_mort <- sum(el$mort_primero)
w_mort <- ic_wilson(x_mort, n_onset, escala = 100)
ambos <- el |> filter(q5_observado, !is.na(inicio_tfr))
w_ambos <- ic_wilson(sum(ambos$inicio_q5 < ambos$inicio_tfr), nrow(ambos), escala = 100)
x_twn <- el_todos |> filter(!is.na(inicio_q5), !is.na(inicio_tfr))
informar("Elegibles (>=1M, TFR1950>=5): %d; con ingreso clasificado: %d (fuera: %s); TFR aún sin iniciar: %s",
         nrow(el_todos), n_eleg, paste(setdiff(el_todos$ISO3_code, el$ISO3_code), collapse = ", "),
         paste(el$ISO3_code[is.na(el$inicio_tfr)], collapse = ", "))
informar("Mortalidad primero (definición preinscrita H3a): %d de %d = %.1f %% Wilson [%.1f; %.1f]",
         x_mort, n_onset, w_mort$valor, w_mort$ci_low, w_mort$ci_high)
informar("  solo con ambos inicios observados: %d de %d = %.1f %%; con Taiwán (sin ingreso), ambos observados: %d de %d",
         sum(ambos$inicio_q5 < ambos$inicio_tfr), nrow(ambos), w_ambos$valor,
         sum(x_twn$inicio_q5 < x_twn$inicio_tfr), nrow(x_twn))
informar("  fecundidad primero: %s", paste(sprintf("%s (Q5 %d, TFR %d)", ambos$ISO3_code[ambos$inicio_q5 >= ambos$inicio_tfr],
                                                  ambos$inicio_q5[ambos$inicio_q5 >= ambos$inicio_tfr], ambos$inicio_tfr[ambos$inicio_q5 >= ambos$inicio_tfr]), collapse = "; "))
n_q5_1950 <- sum(el$izq_q5)

# 5.2 Rejilla de reglas (-5/-10/-15 % x TFR1950 >= 5 / 5,5 / 6)
reglas <- expand.grid(frac = c(0.95, 0.90, 0.85), tfr_min = c(5, 5.5, 6))
reglas_res <- bind_rows(lapply(seq_len(nrow(reglas)), function(i) {
  b <- if (reglas$frac[i] == UMBRAL_INICIO) bi else base_ini(reglas$frac[i])
  e <- b |> filter(tfr_1950 >= reglas$tfr_min[i], ingreso != "Not classified", !is.na(inicio_q5))
  mp <- is.na(e$inicio_tfr) | e$inicio_q5 < e$inicio_tfr
  ob <- e |> filter(!is.na(inicio_tfr))
  tibble(frac = reglas$frac[i], tfr_min = reglas$tfr_min[i], n = nrow(e), x_mort_primero = sum(mp),
         pct_mort_primero = 100 * mean(mp), cota_rezago = median(pmax(ob$inicio_tfr - ob$inicio_q5, 0)))
}))
print(reglas_res)

# 5.3 Rezago como intervalo (Turnbull) y cota inferior de la mediana
el <- el |> mutate(
  rezago_inicio_lo = case_when(is.na(inicio_tfr) ~ 2023 - inicio_q5, izq_q5 & !izq_tfr ~ inicio_tfr - inicio_q5,
                               izq_tfr ~ -Inf, TRUE ~ inicio_tfr - inicio_q5),
  rezago_inicio_hi = case_when(is.na(inicio_tfr) ~ Inf, izq_q5 ~ Inf, TRUE ~ inicio_tfr - inicio_q5),
  tipo_censura = case_when(is.finite(rezago_inicio_lo) & is.finite(rezago_inicio_hi) ~ "exact",
                           is.finite(rezago_inicio_lo) ~ "right-censored (>=)", is.finite(rezago_inicio_hi) ~ "left-censored (<=)",
                           TRUE ~ "no information"))
print(table(el$tipo_censura))
tb <- el |> filter(tipo_censura != "no information") |>
  mutate(L2 = ifelse(is.finite(rezago_inicio_lo), rezago_inicio_lo + 100, NA), R2 = ifelse(is.finite(rezago_inicio_hi), rezago_inicio_hi + 100, NA))
ft <- survfit(Surv(L2, R2, type = "interval2") ~ 1, data = tb)
masa_mas_alla <- min(ft$surv)
med_turnbull <- if (masa_mas_alla <= 0.5) ft$time[which(ft$surv <= 0.5)[1]] - 100 else NA_real_
informar("Turnbull: masa de probabilidad más allá del último tiempo finito = %.2f -> mediana %s",
         masa_mas_alla, ifelse(is.na(med_turnbull), "NO identificable", format(med_turnbull)))
lb <- el |> filter(!is.na(inicio_tfr)) |> mutate(rezago_cota = pmax(inicio_tfr - inicio_q5, 0))
f_med_rez <- function(d) median(d$rezago_cota)
bb_lb <- bootstrap_bloques(lb, f_med_rez, B = B_Q1, semilla = SEM)
bi_lb <- bootstrap_bloques(lb, f_med_rez, bloque = NULL, B = B_Q1, semilla = SEM)
informar("Cota inferior de la mediana del rezago: %.1f años [bloques %.1f; %.1f] [iid %.1f; %.1f]; IQR %.0f-%.0f",
         bb_lb$valor, bb_lb$ci_low, bb_lb$ci_high, bi_lb$ci_low, bi_lb$ci_high,
         quantile(lb$rezago_cota, 0.25), quantile(lb$rezago_cota, 0.75))

# 5.4 ¿Cuánto había caído Q5 cuando empezó a caer la fecundidad?
caida <- est1m |> inner_join(el |> filter(!is.na(inicio_tfr)) |> select(ISO3_code, inicio_tfr), by = "ISO3_code") |>
  group_by(ISO3_code) |> summarise(caida_q5_al_inicio_tfr = 100 * (1 - Q5[Time == inicio_tfr[1]] / max(Q5[Time <= inicio_tfr[1]])))
el <- el |> left_join(caida, by = "ISO3_code")
dq <- el |> filter(!is.na(caida_q5_al_inicio_tfr))
f_med_caida <- function(d) median(d$caida_q5_al_inicio_tfr)
bb_caida <- bootstrap_bloques(dq, f_med_caida, B = B_Q1, semilla = SEM)
bi_caida <- bootstrap_bloques(dq, f_med_caida, bloque = NULL, B = B_Q1, semilla = SEM)
caida_ing <- dq |> group_by(ingreso) |> summarise(n = n(), mediana = median(caida_q5_al_inicio_tfr))
informar("Caída de Q5 (desde su máximo) al iniciar la caída de la TFR: mediana %.1f %% [bloques %.1f; %.1f]; IQR %.0f-%.0f; por ingreso: %s",
         bb_caida$valor, bb_caida$ci_low, bb_caida$ci_high, quantile(dq$caida_q5_al_inicio_tfr, 0.25),
         quantile(dq$caida_q5_al_inicio_tfr, 0.75), paste(sprintf("%s %.0f", caida_ing$ingreso, caida_ing$mediana), collapse = "; "))

# 5.5 Kaplan-Meier del año de inicio de la caída de la TFR (censura en 2023)
cal <- el |> mutate(t = ifelse(is.na(inicio_tfr), 2023 - 1950, inicio_tfr - 1950), e = as.integer(!is.na(inicio_tfr)))
# Año mediano = primer año en que al menos la mitad del grupo ya inició (S(t) <= 0,5);
# survfit() da el punto medio cuando S(t) = 0,5 exactamente en un tramo (p. ej. 2000,5).
km_grupo <- function(d) {
  f <- survfit(Surv(t, e) ~ 1, data = d)
  tab <- summary(f)$table
  list(fit = f, n = nrow(d), eventos = sum(d$e),
       mediana = if (any(f$surv <= 0.5)) 1950 + f$time[which(f$surv <= 0.5)[1]] else NA_real_,
       mediana_survfit = 1950 + unname(tab["median"]),
       lo = 1950 + unname(tab["0.95LCL"]), hi = 1950 + unname(tab["0.95UCL"]))
}
km_ing <- lapply(setNames(NIVELES_INGRESO, NIVELES_INGRESO), function(g) km_grupo(cal |> filter(ingreso == g)))
for (g in NIVELES_INGRESO) informar("Inicio TFR %-20s n=%2d eventos=%2d  año mediano %s [%s; %s] (survfit %s)",
                                    g, km_ing[[g]]$n, km_ing[[g]]$eventos, km_ing[[g]]$mediana, km_ing[[g]]$lo, km_ing[[g]]$hi, km_ing[[g]]$mediana_survfit)
lr <- survdiff(Surv(t, e) ~ ingreso, data = cal)
lr_gl <- length(lr$n) - 1; lr_p <- pchisq(lr$chisq, lr_gl, lower.tail = FALSE)
cx <- coxph(Surv(t, e) ~ as.numeric(ingreso), data = cal)
cx_hr <- exp(coef(cx)); cx_ci <- exp(confint(cx)); cx_p <- summary(cx)$coefficients[, "Pr(>|z|)"]
informar("Log-rank 4 grupos: chi2 = %.1f (%d gl), p = %.1e | Cox (ingreso como escalón 1-4): HR = %.2f [%.2f; %.2f]",
         lr$chisq, lr_gl, lr_p, cx_hr, cx_ci[1], cx_ci[2])
regs_km <- sort(unique(as.character(cal$region_sdg)))
km_reg <- lapply(setNames(regs_km, regs_km), function(r) km_grupo(cal |> filter(region_sdg == r)))
km_reg_tab <- tibble(region = regs_km, n = vapply(km_reg, `[[`, numeric(1), "n"),
                     mediana = vapply(km_reg, `[[`, numeric(1), "mediana")) |> arrange(mediana)
print(km_reg_tab)
lr_reg <- survdiff(Surv(t, e) ~ region_sdg, data = cal |> filter(region_sdg %in% km_reg_tab$region[km_reg_tab$n >= 5]))

# Curvas KM para la figura y el parquet
curva_km <- function(fit, curva, grupo) {
  tibble(curva = curva, grupo = grupo, anio_o_t = 1950 + c(0, fit$time), surv = c(1, fit$surv),
         lower = c(1, fit$lower), upper = c(1, fit$upper), n_risk = c(fit$n, fit$n.risk), n_event = c(0, fit$n.event))
}
km_tab <- bind_rows(lapply(NIVELES_INGRESO, function(g) curva_km(km_ing[[g]]$fit, "tfr_onset_by_income", g)),
                    lapply(regs_km, function(r) curva_km(km_reg[[r]]$fit, "tfr_onset_by_region", r)))
# Q5 también (para la figura: casi todos ya caían en 1950)
calq <- el |> mutate(t = inicio_q5 - 1950, e = 1L)
km_q5 <- lapply(setNames(NIVELES_INGRESO, NIVELES_INGRESO), function(g) km_grupo(calq |> filter(ingreso == g)))
km_tab <- bind_rows(km_tab, bind_rows(lapply(NIVELES_INGRESO, function(g) curva_km(km_q5[[g]]$fit, "q5_onset_by_income", g))))

# 5.6 Rejilla de umbrales absolutos (formulación v1, H3) y KM con censura (100 / 4)
cruce_anual <- function(t, x, u) { if (x[1] < u) return(-Inf); i <- which(x < u); if (!length(i)) return(Inf); t[i[1]] }
grid_u <- expand.grid(q5_umbral = c(200, 150, 100, 75, 50), tfr_umbral = c(5, 4, 3, 2.5))
cruces <- est1m |> group_by(ISO3_code, ingreso) |>
  summarise(q200 = cruce_anual(Time, Q5, 200), q150 = cruce_anual(Time, Q5, 150), q100 = cruce_anual(Time, Q5, 100),
            q75 = cruce_anual(Time, Q5, 75), q50 = cruce_anual(Time, Q5, 50),
            f5 = cruce_anual(Time, TFR, 5), f4 = cruce_anual(Time, TFR, 4), f3 = cruce_anual(Time, TFR, 3),
            f2.5 = cruce_anual(Time, TFR, 2.5), .groups = "drop")
grid_res <- bind_rows(lapply(seq_len(nrow(grid_u)), function(i) {
  q <- cruces[[paste0("q", grid_u$q5_umbral[i])]]; f <- cruces[[paste0("f", grid_u$tfr_umbral[i])]]
  ok <- is.finite(q) & is.finite(f); lag <- f[ok] - q[ok]
  tibble(q5_umbral = grid_u$q5_umbral[i], tfr_umbral = grid_u$tfr_umbral[i], n = sum(ok),
         mediana_rezago = median(lag), pct_mort_primero = 100 * mean(lag > 0))
}))
print(grid_res, n = 20)
k100 <- cruces |> filter(is.finite(q100), f4 != -Inf) |>
  mutate(t = ifelse(is.finite(f4), f4, 2023) - q100 + 100, e = as.integer(is.finite(f4)))
f100 <- survfit(Surv(t, e) ~ 1, data = k100); t100 <- summary(f100)$table
km100 <- c(med = unname(t100["median"]) - 100, lo = unname(t100["0.95LCL"]) - 100, hi = unname(t100["0.95UCL"]) - 100)
informar("Umbrales fijos: mediana del rezago %.1f a %.1f; mortalidad primero %.0f-%.0f %% | KM (100/4) con censura: %.1f [%.1f; %.1f] (n=%d, eventos %d)",
         min(grid_res$mediana_rezago), max(grid_res$mediana_rezago), min(grid_res$pct_mort_primero), max(grid_res$pct_mort_primero),
         km100["med"], km100["lo"], km100["hi"], nrow(k100), sum(k100$e))

# 5.7 Event time: Q5 y TFR (% de su máximo) alrededor del inicio de la caída de la TFR
ev <- est1m |> inner_join(el |> filter(!is.na(inicio_tfr)) |> select(ISO3_code, inicio_tfr, ing = ingreso), by = "ISO3_code") |>
  group_by(ISO3_code) |> mutate(tau = Time - inicio_tfr, Q5 = 100 * Q5 / max(Q5), TFR = 100 * TFR / max(TFR)) |> ungroup() |>
  filter(tau >= -25, tau <= 30)
ev_tab <- bind_rows(ev |> mutate(ing = "All"), ev |> mutate(ing = as.character(ing))) |>
  pivot_longer(c(Q5, TFR), names_to = "variable", values_to = "v") |>
  group_by(ingreso = ing, variable, tau) |>
  summarise(mediana = median(v), p25 = quantile(v, 0.25), p75 = quantile(v, 0.75), n = n(), .groups = "drop") |> filter(n >= 5)
informar("Event time (todos): a tau = 0, Q5 = %.0f %% de su máximo y TFR = %.0f %%",
         ev_tab$mediana[ev_tab$ingreso == "All" & ev_tab$variable == "Q5" & ev_tab$tau == 0],
         ev_tab$mediana[ev_tab$ingreso == "All" & ev_tab$variable == "TFR" & ev_tab$tau == 0])

# 5.8 Registro de cifras de supervivencia
F_ONSET <- sprintf("%d countries >= 1 M with TFR >= 5 in 1950 and a World Bank FY2027 income group; estimates 1950-2023", n_eleg)
anotar("n_onset", value = n_onset, unit = "countries", fmt = "0",
       def = "High-fertility countries (TFR >= 5 in 1950) whose child-mortality (Q5) decline onset is observed (Princeton rule: first year <= 90% of the previous maximum, never exceeded again)",
       filter = F_ONSET, source_cell = "Q1-5.1", used_in = c("slide2.build2", "slide2.message", "narration.slide2"),
       method = "none_census", status = "pre-specified", hypothesis_id = "H3a", n = n_eleg, universe = UNIVERSO_1M)
anotar("n_mort_first_onset", value = x_mort, unit = "countries", fmt = "0",
       def = "Countries where the lasting fall of Q5 began before that of TFR (countries whose TFR decline had not started by 2023 count as mortality first)",
       filter = F_ONSET, source_cell = "Q1-5.1", used_in = c("slide2.build2", "slide2.message", "narration.slide2"),
       method = "none_census", sens_low = min(reglas_res$x_mort_primero), sens_high = max(reglas_res$x_mort_primero),
       sens_note = sprintf("9 onset rules (-5/-10/-15%% x TFR1950 >= 5/5.5/6); only both onsets observed: %d of %d; with Taiwan (no income group): %d of %d",
                           sum(ambos$inicio_q5 < ambos$inicio_tfr), nrow(ambos), sum(x_twn$inicio_q5 < x_twn$inicio_tfr), nrow(x_twn)),
       status = "pre-specified", hypothesis_id = "H3a", n = n_onset, universe = UNIVERSO_1M)
anotar("share_mort_first", value = round(w_mort$valor, 4), unit = "%", fmt = "0", ic = w_mort,
       def = "n_mort_first_onset / n_onset x 100", filter = F_ONSET, source_cell = "Q1-5.1",
       used_in = c("slide2.build2", "narration.slide2"),
       sens_low = round(min(reglas_res$pct_mort_primero), 2), sens_high = round(max(reglas_res$pct_mort_primero), 2),
       sens_note = "9 onset rules (-5/-10/-15% x TFR1950 >= 5/5.5/6)", status = "pre-specified", hypothesis_id = "H3a",
       say = "97 in every 100", universe = UNIVERSO_1M)
anotar("share_mort_first_both_observed", value = round(w_ambos$valor, 4), unit = "%", fmt = "0", ic = w_ambos,
       def = "Same share restricted to countries with both onsets observed (TFR decline started by 2023)", filter = F_ONSET,
       source_cell = "Q1-5.1", used_in = c("notebook.T3"), status = "exploratory", hypothesis_id = "H3a", universe = UNIVERSO_1M)
anotar("lag_onset_lower_bound", value = bb_lb$valor, unit = "years", fmt = "0", ic = bb_lb, ic_iid = bi_lb,
       def = "Median of max(TFR onset - Q5 onset, 0) among countries with both onsets observed; a LOWER BOUND of the median lag because Q5 was already falling in 1950 in most countries",
       filter = F_ONSET, source_cell = "Q1-5.3", used_in = c("slide2.build2", "narration.slide2"),
       sens_low = min(reglas_res$cota_rezago), sens_high = max(reglas_res$cota_rezago),
       sens_note = sprintf("9 onset rules; Turnbull with all censoring: median not identified (%.0f%% of probability mass beyond the last finite time); IQR of the bound %.0f-%.0f",
                           100 * masa_mas_alla, quantile(lb$rezago_cota, 0.25), quantile(lb$rezago_cota, 0.75)),
       status = "pre-specified", hypothesis_id = "H3a", say = "at least 22 years", n = nrow(lb), universe = UNIVERSO_1M)
anotar("lag_onset_turnbull_mass_beyond", value = round(masa_mas_alla, 4), unit = "share", fmt = "0.00",
       def = "Turnbull (interval-censored) estimate of the lag Q5 onset -> TFR onset: probability mass beyond the last finite time (> 0.5 means the median is not identified)",
       filter = F_ONSET, source_cell = "Q1-5.3", used_in = c("notebook.T3"), method = "turnbull",
       sens_note = paste(names(table(el$tipo_censura)), table(el$tipo_censura), sep = ": ", collapse = " · "),
       status = "exploratory", hypothesis_id = "H3a", n = nrow(tb), universe = UNIVERSO_1M)
anotar("q5_drop_at_tfr_onset", value = round(bb_caida$valor, 4), unit = "%", fmt = "0", ic = bb_caida, ic_iid = bi_caida,
       def = "Median % fall of Q5 from its 1950-onwards maximum to the year TFR began its lasting fall",
       filter = F_ONSET, source_cell = "Q1-5.4", used_in = c("slide2.build2"),
       sens_note = sprintf("IQR %.0f-%.0f; by income group: %s", quantile(dq$caida_q5_al_inicio_tfr, 0.25), quantile(dq$caida_q5_al_inicio_tfr, 0.75),
                           paste(sprintf("%s %.0f", ETIQUETAS_INGRESO_CORTAS_EN[as.character(caida_ing$ingreso)], caida_ing$mediana), collapse = "; ")),
       status = "exploratory", say = "about half", n = nrow(dq), universe = UNIVERSO_1M)
anotar("n_q5_falling_1950", value = n_q5_1950, unit = "countries", fmt = "0",
       def = "Eligible countries whose Q5 maximum is in 1950 (decline already under way when the data begin: left-censored onset)",
       filter = F_ONSET, source_cell = "Q1-5.3", used_in = c("slide2.build2"), method = "none_census",
       sens_note = sprintf("TFR maximum in 1950: %d countries", sum(el$izq_tfr)), status = "descriptive", n = n_eleg, universe = UNIVERSO_1M)
claves_yr <- c("Low income" = "yr_fert_onset_low", "Lower middle income" = "yr_fert_onset_lowmid",
               "Upper middle income" = "yr_fert_onset_upmid", "High income" = "yr_fert_onset_high")
for (g in NIVELES_INGRESO) {
  k <- km_ing[[g]]
  anotar(claves_yr[[g]], value = k$mediana, unit = "year", fmt = "0", ci_low = k$lo, ci_high = k$hi, method = "km",
         def = sprintf("Kaplan-Meier median year of the onset of the lasting fertility decline (first year with S(t) <= 0.5), today's %s countries; right-censored in 2023", g),
         filter = sprintf("%s within: %s", g, F_ONSET), source_cell = "Q1-5.5",
         used_in = if (g == "High income") c("notebook.T3") else c("slide2.build2", "narration.slide2"),
         sens_note = sprintf("n = %d, events = %d; survfit midpoint convention: %s; 95%% CI Brookmeyer-Crowley", k$n, k$eventos, k$mediana_survfit),
         status = "exploratory", hypothesis_id = "H3b", n = k$n, universe = UNIVERSO_1M)
}
anotar("logrank_income_chisq", value = round(lr$chisq, 4), unit = "chi-squared", fmt = "0.0", method = "logrank",
       def = sprintf("Log-rank test of equal fertility-onset curves across the 4 income groups (%d df)", lr_gl),
       filter = F_ONSET, source_cell = "Q1-5.5", used_in = c("notebook.T3"), p_value = signif(lr_p, 4),
       sens_note = sprintf("Cox with income as a 1-4 step: HR = %.2f [%.2f; %.2f] per step", cx_hr, cx_ci[1], cx_ci[2]),
       status = "exploratory", hypothesis_id = "H3b", n = n_eleg, universe = UNIVERSO_1M)
anotar("cox_hr_income_step", value = round(unname(cx_hr), 4), unit = "hazard ratio", fmt = "0.00", method = "descriptive",
       sens_note = sprintf("Wald 95%% CI [%.2f; %.2f] (notebook only)", cx_ci[1], cx_ci[2]),
       def = "Cox model of the fertility-onset time with income group as a 1-4 step (Wald 95% CI)",
       filter = F_ONSET, source_cell = "Q1-5.5", used_in = c("notebook.T3"), p_value = signif(unname(cx_p), 4),
       status = "exploratory", hypothesis_id = "H3b", n = n_eleg, universe = UNIVERSO_1M)
anotar("yr_fert_onset_by_region", value = setNames(km_reg_tab$mediana, ETIQUETAS_REGION_CORTAS_EN[km_reg_tab$region]),
       unit = "year", fmt = "0", method = "km",
       def = "Kaplan-Meier median year of the fertility-decline onset by SDG region (first year with S(t) <= 0.5)",
       filter = F_ONSET, source_cell = "Q1-5.5", used_in = c("notebook.T3"),
       sens_note = paste(sprintf("%s n=%d", ETIQUETAS_REGION_CORTAS_EN[km_reg_tab$region], km_reg_tab$n), collapse = "; "),
       p_value = signif(pchisq(lr_reg$chisq, length(lr_reg$n) - 1, lower.tail = FALSE), 4),
       status = "exploratory", n = n_eleg, universe = UNIVERSO_1M)
anotar("lag_threshold_100_4_km", value = km100[["med"]], unit = "years", fmt = "0", ci_low = km100[["lo"]], ci_high = km100[["hi"]],
       method = "km", def = "v1 definition: years from Q5 < 100 to TFR < 4 (first year below each threshold), Kaplan-Meier with right censoring for countries still at TFR >= 4 in 2023",
       filter = "161 countries >= 1 M with Q5 >= 100 in 1950 that crossed it and TFR >= 4 in 1950; estimates", source_cell = "Q1-5.6",
       used_in = c("notebook.T3"), sens_note = sprintf("n = %d, events = %d", nrow(k100), sum(k100$e)),
       status = "pre-specified", hypothesis_id = "H3", n = nrow(k100), universe = UNIVERSO_1M)
anotar("share_mort_first_threshold_range", value = I(round(range(grid_res$pct_mort_primero), 1)), unit = "%", fmt = "0",
       def = "Range of the share 'Q5 crossed its threshold before TFR crossed its threshold' over 20 threshold pairs Q5 {200,150,100,75,50} x TFR {5,4,3,2.5} (both crossings observed after 1950)",
       filter = "161 countries >= 1 M, estimates 1950-2023", source_cell = "Q1-5.6", used_in = c("notebook.T3"),
       method = "sensitivity", sens_note = sprintf("median lag from %.1f to %.1f years across the grid", min(grid_res$mediana_rezago), max(grid_res$mediana_rezago)),
       status = "pre-specified", hypothesis_id = "H3", n = N_PAISES_1M, universe = UNIVERSO_1M)

# 5.9 Figuras de revisión: KM por ingreso y event time
fig_km <- km_tab |> filter(curva %in% c("tfr_onset_by_income", "q5_onset_by_income")) |>
  mutate(var = ifelse(curva == "tfr_onset_by_income", "Fertility (TFR)", "Child mortality (Q5)"),
         grupo = factor(ETIQUETAS_INGRESO_CORTAS_EN[grupo], levels = ETIQUETAS_INGRESO_CORTAS_EN[NIVELES_INGRESO]))
lab_km <- tibble(grupo = factor(ETIQUETAS_INGRESO_CORTAS_EN[NIVELES_INGRESO], levels = ETIQUETAS_INGRESO_CORTAS_EN[NIVELES_INGRESO]),
                 med = vapply(km_ing, `[[`, numeric(1), "mediana"))
p6 <- ggplot(fig_km, aes(anio_o_t, 100 * (1 - surv), colour = var)) +
  geom_step(linewidth = 1) +
  geom_hline(yintercept = 50, linetype = "dashed", colour = COL_GRIS) +
  geom_vline(data = lab_km, aes(xintercept = med), colour = COLOR_NACIMIENTOS, linetype = "dotted") +
  geom_text(data = lab_km, aes(x = med, y = 8, label = med), inherit.aes = FALSE, colour = COLOR_NACIMIENTOS, hjust = -0.1, size = 3.6) +
  facet_wrap(~grupo, nrow = 1) +
  scale_colour_manual(values = c("Fertility (TFR)" = COLOR_NACIMIENTOS, "Child mortality (Q5)" = COLOR_DEFUNCIONES), name = NULL) +
  labs(x = "Year", y = "% of countries whose lasting decline has begun",
       title = sprintf("Child mortality began to fall first in %d of %d high-fertility countries", x_mort, n_onset),
       subtitle = sprintf("Kaplan–Meier; onset = first year 10%% below the previous peak, never exceeded again.\nMedian year of fertility onset: %s. Log-rank chi² = %.1f (3 df).",
                          paste(sprintf("%s %s", lab_km$grupo, lab_km$med), collapse = " · "), lr$chisq),
       caption = pie_q1(PIE_MODELOS, badge("PIE-4"), sprintf("n = %d countries >= 1 M with TFR >= 5 in 1950; Q5 already falling in 1950 in %d. A sequence in time, not proof of cause.", n_eleg, n_q5_1950))) +
  tema_q1(11)
guardar_q1(p6, "q1_06_km_inicio_ingreso")
fig_ev <- ev_tab |> filter(ingreso == "All") |> mutate(variable = ifelse(variable == "Q5", "Under-five mortality", "Children per woman"))
p7 <- ggplot(fig_ev, aes(tau, mediana, colour = variable, fill = variable)) +
  geom_ribbon(aes(ymin = p25, ymax = p75), alpha = 0.15, colour = NA) + geom_line(linewidth = 1.2) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_colour_manual(values = c("Under-five mortality" = COLOR_DEFUNCIONES, "Children per woman" = COLOR_NACIMIENTOS), name = NULL) +
  scale_fill_manual(values = c("Under-five mortality" = COLOR_DEFUNCIONES, "Children per woman" = COLOR_NACIMIENTOS), name = NULL) +
  labs(x = "Years since fertility began its lasting fall (year 0)", y = "% of the country's own 1950–2023 peak",
       title = sprintf("When fertility starts to fall, child mortality has already dropped by about half (median %.0f%%)", bb_caida$valor),
       subtitle = "Median across countries (line) and middle 50% (band), each country aligned on its own fertility onset",
       caption = pie_q1(PIE_MODELOS, sprintf("%d countries >= 1 M with TFR >= 5 in 1950 whose fertility decline started by 2023. A sequence in time, not proof of cause.", nrow(dq)))) + tema_q1(12)
guardar_q1(p7, "q1_07_event_time_inicio")
p8 <- ggplot(grid_res, aes(factor(tfr_umbral), factor(q5_umbral), fill = pct_mort_primero)) +
  geom_tile(colour = "white") + geom_text(aes(label = sprintf("%.0f%%\n%+.1f yrs", pct_mort_primero, mediana_rezago)), size = 3.3) +
  scale_fill_gradient(low = "#F7FBFF", high = "#08519C", limits = c(0, 100), name = "% mortality first") +
  labs(x = "Fertility threshold (TFR crosses below)", y = "Under-five mortality threshold (per 1,000)",
       title = "With fixed thresholds the answer depends on the pair chosen (v1 hypothesis H3)",
       subtitle = "Share of countries where Q5 crossed first and median lag (TFR year − Q5 year), both crossings observed after 1950",
       caption = pie_q1(PIE_MODELOS, "Sensitivity only: the onset rule (section 5) is the pre-specified answer.")) + tema_q1(12)
guardar_q1(p8, "q1_08_rejilla_umbrales")

# =============================================================================
# 6. Registro por hitos (datos funcionales): mismo camino, distinta velocidad
# =============================================================================
# QUÉ: suaviza la TFR de cada país (B-splines, lambda = 10), fecha el último
#      cruce de 4 hijos y alinea a todos en ese "reloj propio"; mide cuánta
#      varianza entre países desaparece en +-20 años y cuánto tardan de 5 a 3.
# POR QUÉ: convierte "same road, different speed" en una cifra comprobable
#      (no en un adjetivo) y separa el "cuándo" del "cómo".
seccion("6. Registro por hitos (FDA)")

anios <- 1950:2023
Y <- est1m |> select(ISO3_code, Time, TFR) |> pivot_wider(names_from = ISO3_code, values_from = TFR) |> arrange(Time)
M_TFR <- as.matrix(Y[, -1]); rownames(M_TFR) <- Y$Time
paises_fd <- colnames(M_TFR)
stopifnot(identical(as.integer(rownames(M_TFR)), anios), !anyNA(M_TFR))
base_fd <- fda::create.bspline.basis(c(1950, 2023), nbasis = length(anios) + 2, norder = 4)
fd_tfr <- fda::smooth.basis(anios, M_TFR, fda::fdPar(base_fd, 2, LAMBDA_FDA))$fd
tf <- seq(1950, 2023, by = 0.1)
Tfine <- fda::eval.fd(tf, fd_tfr); colnames(Tfine) <- paises_fd
cruce_suave <- function(y, u) {
  if (y[1] < u) return(-Inf)
  if (tail(y, 1) >= u) return(Inf)
  i <- max(which(y >= u)); tf[i] + (y[i] - u) / (y[i] - y[i + 1]) * 0.1
}
hitos <- tibble(ISO3_code = paises_fd, col = seq_along(paises_fd),
                c5 = apply(Tfine, 2, cruce_suave, 5), c4 = apply(Tfine, 2, cruce_suave, 4),
                c3 = apply(Tfine, 2, cruce_suave, 3)) |>
  left_join(c23 |> select(ISO3_code, Location, region_sdg, subregion, ingreso, pop_2023_miles = TPopulation1July), by = "ISO3_code")
n_c4 <- sum(is.finite(hitos$c4)); n_izq <- sum(hitos$c4 == -Inf); n_der <- sum(hitos$c4 == Inf)
n_der_ssa <- sum(hitos$c4 == Inf & hitos$region_sdg == "Sub-Saharan Africa")
informar("Cruce de TFR = 4: observado %d · ya < 4 en 1950: %d · aún >= 4 en 2023: %d (%d en África subsahariana)", n_c4, n_izq, n_der, n_der_ssa)

# 6.2 Varianza entre países: calendario vs reloj propio (ventana +-20)
reduccion_var <- function(cs, cols, w = 20) {
  tau <- -w:w
  ev_f <- function(j, t) stats::approx(tf, Tfine[, cols[j]], xout = t, rule = 2)$y
  Al <- vapply(seq_along(cs), function(j) ev_f(j, cs[j] + tau), numeric(length(tau)))
  cal0 <- stats::median(cs)
  Ca <- vapply(seq_along(cs), function(j) ev_f(j, cal0 + tau), numeric(length(tau)))
  list(v_cal = apply(Ca, 1, stats::var), v_al = apply(Al, 1, stats::var), Al = Al, Ca = Ca, tau = tau)
}
pct_red <- function(r, sin0 = FALSE) {
  k <- if (sin0) r$tau != 0 else rep(TRUE, length(r$tau))
  100 * (1 - mean(r$v_al[k]) / mean(r$v_cal[k]))
}
regs_hito <- list()
for (h in c("c4", "c5", "c3")) {
  ok <- is.finite(hitos[[h]]) & hitos[[h]] - 20 >= 1950 & hitos[[h]] + 20 <= 2023
  d_h <- hitos[ok, ] |> mutate(cc = .data[[h]])
  r <- reduccion_var(d_h$cc, d_h$col)
  f_stat <- function(d) pct_red(reduccion_var(d$cc, d$col))
  bb <- bootstrap_bloques(d_h, f_stat, B = if (h == "c4") B_Q1 else B_NB, semilla = SEM)
  regs_hito[[h]] <- list(n = nrow(d_h), pct = pct_red(r), pct_sin0 = pct_red(r, TRUE), bb = bb, r = r, d = d_h,
                         v_cal = mean(r$v_cal), v_al = mean(r$v_al))
  informar("Hito %s: %d países con ventana completa; varianza media %.3f (calendario) -> %.3f (alineada): -%.1f %% [bloques %.1f; %.1f] (sin tau = 0: -%.1f %%)",
           h, nrow(d_h), mean(r$v_cal), mean(r$v_al), pct_red(r), bb$ci_low, bb$ci_high, pct_red(r, TRUE))
}
hitos <- hitos |> mutate(ventana_completa_c4 = is.finite(c4) & c4 - 20 >= 1950 & c4 + 20 <= 2023)
disp_reg <- bind_rows(lapply(names(regs_hito), function(h) {
  r <- regs_hito[[h]]$r
  tibble(hito = h, tau = r$tau, var_calendario = r$v_cal, var_alineado = r$v_al,
         p10_calendario = apply(r$Ca, 1, quantile, 0.1), p50_calendario = apply(r$Ca, 1, median), p90_calendario = apply(r$Ca, 1, quantile, 0.9),
         p10_alineado = apply(r$Al, 1, quantile, 0.1), p50_alineado = apply(r$Al, 1, median), p90_alineado = apply(r$Al, 1, quantile, 0.9))
}))

# 6.3 Kneip-Ramsay (amplitud vs fase) con fda::landmarkreg
r2_fase <- tryCatch({
  sel <- hitos$ventana_completa_c4
  x0 <- 0:73; b0 <- fda::create.bspline.basis(c(0, 73), nbasis = 25, norder = 4)
  fdx <- fda::smooth.basis(x0, M_TFR[, hitos$col[sel]], fda::fdPar(b0, 2, 1))$fd
  c4r <- hitos$c4[sel] - 1950
  wb <- fda::create.bspline.basis(c(0, 73), 5, 4); wp <- fda::fdPar(fda::fd(matrix(0, 5, 1), wb), 2, 1e-4)
  invisible(utils::capture.output(regkr <- fda::landmarkreg(fdx, ximarks = matrix(c4r), x0marks = mean(c4r),
                                                            WfdPar = wp, WfdPar0 = wp, ylambda = 1e-2)))
  apd <- fda::AmpPhaseDecomp(fdx, regkr$regfd, regkr$warpfd)
  c(r2 = apd$RSQR, C = apd$C)
}, error = function(e) { message("landmarkreg falló: ", conditionMessage(e)); c(r2 = NA_real_, C = NA_real_) })
informar("Kneip-Ramsay (57 países, 1950-2023): R2 de fase = %.2f, C = %.2f", r2_fase["r2"], r2_fase["C"])

# 6.4 Velocidad 5 -> 3 con Kaplan-Meier (censura en 2023)
d53 <- hitos |> filter(is.finite(c5)) |>
  mutate(fin = ifelse(is.finite(c3), c3, 2023), evento_3 = as.integer(is.finite(c3)), dur_5a3 = fin - c5,
         cohorte_c5 = cut(c5, c(1949, 1975, 1990, 2024), labels = c("crossed 5 by 1975", "1975-1990", "after 1990")),
         cohorte2 = ifelse(c5 <= 1990, "crossed 5 by 1990", "after 1990"))
km_dur <- function(d) {
  f <- survfit(Surv(dur_5a3, evento_3) ~ 1, data = d); tb <- summary(f)$table
  c(n = nrow(d), eventos = sum(d$evento_3), med = unname(tb["median"]), lo = unname(tb["0.95LCL"]), hi = unname(tb["0.95UCL"]))
}
km53 <- rbind(t(sapply(split(d53, d53$cohorte_c5), km_dur)), `crossed 5 by 1990` = km_dur(d53 |> filter(cohorte2 == "crossed 5 by 1990")))
print(round(km53, 1))
dur_pais <- function(iso) d53$dur_5a3[d53$ISO3_code == iso & d53$evento_3 == 1]
d53_10m <- d53 |> filter(evento_3 == 1, pop_2023_miles >= 10000) |> arrange(dur_5a3)
resaltar <- c(rapido = d53_10m$ISO3_code[1],
              mediano = d53_10m$ISO3_code[which.min(abs(d53_10m$dur_5a3 - median(d53_10m$dur_5a3)))],
              lento = d53_10m$ISO3_code[nrow(d53_10m)])
informar("5 -> 3: China %.1f años, Egipto %.1f; más rápidos %s; resaltados por regla (>= 10 M): %s",
         dur_pais("CHN"), dur_pais("EGY"),
         paste(sprintf("%s %.1f", head(d53 |> filter(evento_3 == 1) |> arrange(dur_5a3), 5)$ISO3_code,
                       head(d53 |> filter(evento_3 == 1) |> arrange(dur_5a3), 5)$dur_5a3), collapse = ", "),
         paste(sprintf("%s=%s", names(resaltar), resaltar), collapse = ", "))
hitos <- hitos |> left_join(d53 |> select(ISO3_code, dur_5a3, evento_3, cohorte_c5), by = "ISO3_code")
km53_tab <- bind_rows(lapply(levels(d53$cohorte_c5), function(cc) {
  f <- survfit(Surv(dur_5a3, evento_3) ~ 1, data = d53 |> filter(cohorte_c5 == cc))
  tibble(curva = "dur53_by_cohort", grupo = cc, anio_o_t = c(0, f$time), surv = c(1, f$surv), lower = c(1, f$lower),
         upper = c(1, f$upper), n_risk = c(f$n, f$n.risk), n_event = c(0, f$n.event))
}))
km_tab <- bind_rows(km_tab, km53_tab)

# 6.5 Registro de cifras FDA
F_FDA <- "161 countries >= 1 M, estimates 1950-2023; TFR smoothed with cubic B-splines (2nd-derivative penalty, lambda = 10)"
r4 <- regs_hito$c4
anotar("n_cruce_tfr4_obs", value = n_c4, unit = "countries", fmt = "0",
       def = "Countries whose smoothed TFR last crossed 4 between 1950 and 2023", filter = F_FDA, source_cell = "Q1-6.1",
       used_in = c("slide2.build1"), method = "none_census", status = "descriptive", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("n_cens_izq", value = n_izq, unit = "countries", fmt = "0", def = "Countries already below TFR 4 in 1950 (left-censored, not shown in the registration)",
       filter = F_FDA, source_cell = "Q1-6.1", used_in = c("slide2.build1"), method = "none_census", status = "descriptive",
       n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("n_cens_der", value = n_der, unit = "countries", fmt = "0",
       def = "Countries still at TFR >= 4 in 2023 (right-censored, not shown in the registration: survivorship caveat)",
       filter = F_FDA, source_cell = "Q1-6.1", used_in = c("slide2.build1"), method = "none_census",
       sens_note = sprintf("%d of them in sub-Saharan Africa", n_der_ssa), status = "descriptive", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("n_cens_der_ssa", value = n_der_ssa, unit = "countries", fmt = "0",
       def = "Of n_cens_der, countries in sub-Saharan Africa", filter = F_FDA, source_cell = "Q1-6.1", used_in = c("slide2.build1"),
       method = "none_census", status = "descriptive", n = n_der, universe = UNIVERSO_1M)
anotar("pct_var_fase", value = round(r4$pct, 4), unit = "%", fmt = "0", ic = r4$bb,
       def = "Reduction of the mean cross-country variance of smoothed TFR in a +-20-year window when each country is aligned on the year it last crossed TFR = 4 (own clock) instead of a common calendar window centred on the median crossing year",
       filter = sprintf("%d countries >= 1 M whose crossing +-20 years lies within 1950-2023", r4$n), source_cell = "Q1-6.2",
       used_in = c("slide2.build1", "narration.slide2"),
       sens_low = round(min(r4$pct_sin0, regs_hito$c5$pct, regs_hito$c3$pct), 2), sens_high = round(max(r4$pct, r4$pct_sin0), 2),
       sens_note = sprintf("variance %.3f -> %.3f; without tau = 0: %.1f%%; milestone 5: %.1f%% (n = %d); milestone 3: %.1f%% (n = %d); Kneip-Ramsay phase R2 %.2f",
                           r4$v_cal, r4$v_al, r4$pct_sin0, regs_hito$c5$pct, regs_hito$c5$n, regs_hito$c3$pct, regs_hito$c3$n, r2_fase["r2"]),
       status = "exploratory", hypothesis_id = "H17", say = "four fifths", n = r4$n, universe = UNIVERSO_1M)
for (h in c("c5", "c3")) {
  x <- regs_hito[[h]]
  anotar(paste0("pct_var_fase_", h), value = round(x$pct, 4), unit = "%", fmt = "0", ic = x$bb,
         def = sprintf("Same variance reduction aligning on the last crossing of TFR = %s", substring(h, 2)),
         filter = sprintf("%d countries >= 1 M with a complete +-20 window", x$n), source_cell = "Q1-6.2", used_in = c("notebook.T4"),
         status = "exploratory", hypothesis_id = "H17", n = x$n, universe = UNIVERSO_1M)
}
anotar("r2_fase_kr", value = round(unname(r2_fase["r2"]), 4), unit = "R2", fmt = "0.00",
       def = "Kneip-Ramsay amplitude/phase decomposition (fda::landmarkreg on the TFR = 4 landmark, 1950-2023): share of variation due to phase (timing)",
       filter = sprintf("%d countries >= 1 M with a complete +-20 window", r4$n), source_cell = "Q1-6.3", used_in = c("notebook.T4"),
       method = "descriptive", sens_note = sprintf("C = %.2f", r2_fase["C"]), status = "exploratory", hypothesis_id = "H17",
       n = r4$n, universe = UNIVERSO_1M)
anotar("dur53_chn", value = round(dur_pais("CHN"), 4), unit = "years", fmt = "0", method = "descriptive",
       def = "Years for China's smoothed TFR to go from its last crossing of 5 to its last crossing of 3", filter = F_FDA,
       source_cell = "Q1-6.4", used_in = c("slide2.build1", "narration.slide2"), status = "descriptive", n = 1, universe = UNIVERSO_1M)
anotar("dur53_egy", value = round(dur_pais("EGY"), 4), unit = "years", fmt = "0", method = "descriptive",
       def = "Years for Egypt's smoothed TFR to go from its last crossing of 5 to its last crossing of 3", filter = F_FDA,
       source_cell = "Q1-6.4", used_in = c("slide2.build1", "narration.slide2"), status = "descriptive", n = 1, universe = UNIVERSO_1M)
km_claves <- c("crossed 5 by 1975" = "km_dur53_pre1975", "1975-1990" = "km_dur53_1975_1990", "after 1990" = "km_dur53_post1990",
               "crossed 5 by 1990" = "km_dur53_upto1990")
for (gk in names(km_claves)) {
  x <- km53[gk, ]
  anotar(km_claves[[gk]], value = round(unname(x["med"]), 4), unit = "years", fmt = "0.0", method = "km",
         ci_low = round(unname(x["lo"]), 4), ci_high = if (is.na(x["hi"])) NA else round(unname(x["hi"]), 4),
         def = sprintf("Kaplan-Meier median years from TFR 5 to TFR 3 (smoothed, last crossings), countries that %s; right-censored in 2023", gk),
         filter = F_FDA, source_cell = "Q1-6.4", used_in = c("notebook.T4"),
         sens_note = sprintf("n = %d, reached 3 = %d", x["n"], x["eventos"]), status = "exploratory", hypothesis_id = "H18",
         n = unname(x["n"]), universe = UNIVERSO_1M)
}
# Regla de velocidad (QA-storyboard §6.4): ¿China y Egipto son el más rápido y el más lento entre los >= 10 M?
regla_vel_ok <- resaltar[["rapido"]] == "CHN" && resaltar[["lento"]] == "EGY"
informar("Regla de velocidad (>= 10 M que llegaron a 3, n = %d): más rápido %s (%.1f), más lento %s (%.1f) -> %s",
         nrow(d53_10m), resaltar[["rapido"]], dur_pais(resaltar[["rapido"]]), resaltar[["lento"]], dur_pais(resaltar[["lento"]]),
         ifelse(regla_vel_ok, "China y Egipto se mantienen", "CAMBIAN los países de la voz"))
for (lado in c("rapido", "lento")) {
  anotar(if (lado == "rapido") "dur53_fastest_ge10m" else "dur53_slowest_ge10m", value = resaltar[[lado]], unit = NA, fmt = "text",
         method = "descriptive",
         def = sprintf("Rule: the %s country (>= 10 M people) in going from TFR 5 to 3 (smoothed, last crossings), among those that reached 3 by 2023", ifelse(lado == "rapido", "fastest", "slowest")),
         filter = F_FDA, source_cell = "Q1-6.4", used_in = c("slide2.build1", "narration.slide2"), status = "descriptive",
         sens_note = sprintf("%s: %.1f years; storyboard check (China fastest, Egypt slowest): %s", resaltar[[lado]], dur_pais(resaltar[[lado]]),
                             ifelse(regla_vel_ok, "holds", "FAILS")),
         n = nrow(d53_10m), universe = UNIVERSO_1M)
}
anotar("fig04_highlight_iso3", value = I(unname(resaltar)), unit = NA, fmt = "text", method = "descriptive",
       # QA-stats (docs/QA_stats.md): con n par la mediana cae entre dos países; la regla toma el más cercano.
       def = sprintf(paste("Rule: fastest, median and slowest countries (>= 10 M people) in going from TFR 5 to 3 (smoothed, last crossings),",
                           "among the %d that reached 3 by 2023; 'median' = the country whose duration is closest to the median duration",
                           "(%.2f years%s)"),
                     nrow(d53_10m), median(d53_10m$dur_5a3),
                     if (nrow(d53_10m) %% 2 == 0) "; with an even number of countries the median falls between two of them" else ""),
       filter = F_FDA, source_cell = "Q1-6.4", used_in = c("slide2.build1"), status = "descriptive",
       sens_note = paste(sprintf("%s %.1f yrs", d53_10m$ISO3_code[d53_10m$ISO3_code %in% resaltar], d53_10m$dur_5a3[d53_10m$ISO3_code %in% resaltar]), collapse = "; "),
       n = nrow(d53_10m), universe = UNIVERSO_1M)

# 6.6 Curvas alineadas (parquet) y figuras de revisión
curvas <- bind_rows(lapply(which(is.finite(hitos$c4)), function(j) {
  tibble(ISO3_code = hitos$ISO3_code[j], Time = anios, tfr_suav = as.numeric(fda::eval.fd(anios, fd_tfr[hitos$col[j]])),
         c4 = hitos$c4[j], tau = anios - hitos$c4[j])
}))
p9a <- ggplot(curvas, aes(Time, tfr_suav, group = ISO3_code)) + geom_line(colour = "grey70", linewidth = 0.3) +
  geom_line(data = curvas |> filter(ISO3_code %in% resaltar), aes(colour = ISO3_code), linewidth = 1.1) +
  geom_hline(yintercept = 4, linetype = "dashed") + scale_colour_manual(values = setNames(COLORES_RESALTE, resaltar)) +
  labs(x = "Calendar year", y = "Children per woman (smoothed)", colour = NULL, title = "A · Calendar time") + tema_q1(11)
band <- disp_reg |> filter(hito == "c4")
p9b <- ggplot() +
  geom_line(data = curvas |> filter(tau >= -30, tau <= 30), aes(tau, tfr_suav, group = ISO3_code), colour = "grey80", linewidth = 0.3) +
  geom_ribbon(data = band, aes(tau, ymin = p10_alineado, ymax = p90_alineado), fill = COLOR_NACIMIENTOS, alpha = 0.25) +
  geom_line(data = band, aes(tau, p50_alineado), colour = COLOR_NACIMIENTOS, linewidth = 1.3) +
  geom_line(data = curvas |> filter(ISO3_code %in% resaltar, tau >= -30, tau <= 30), aes(tau, tfr_suav, colour = ISO3_code), linewidth = 1.1) +
  geom_hline(yintercept = 4, linetype = "dashed") + scale_colour_manual(values = setNames(COLORES_RESALTE, resaltar)) +
  labs(x = "Years since fertility last fell below 4", y = NULL, colour = NULL, title = "B · Each country's own clock") + tema_q1(11)
p9 <- (p9a | p9b) + plot_layout(guides = "collect") +
  plot_annotation(title = sprintf("Same road, different clock: aligning on TFR = 4 removes %.0f%% of the gaps between countries", r4$pct),
                  subtitle = sprintf("%d countries crossed 4 in 1950–2023 (band: P10–P90 of the %d with a full ±20-year window).\n%d were already below 4 in 1950; %d have not crossed yet (%d in sub-Saharan Africa) and are not shown.",
                                     n_c4, r4$n, n_izq, n_der, n_der_ssa),
                  caption = pie_q1(PIE_MODELOS, sprintf("TFR smoothed with B-splines (lambda = 10). Highlighted by rule (>= 10 M): fastest, median and slowest from 5 to 3 children: %s.", paste(resaltar, collapse = ", "))),
                  theme = tema_q1(11)) & theme(legend.position = "bottom")
guardar_q1(p9, "q1_09_registro_tfr4")
fig53 <- km53_tab |> mutate(grupo = factor(grupo, levels = levels(d53$cohorte_c5)))
lab53 <- tibble(grupo = factor(rownames(km53)[1:3], levels = levels(d53$cohorte_c5)), med = km53[1:3, "med"], n = km53[1:3, "n"], ev = km53[1:3, "eventos"])
p10 <- ggplot(fig53, aes(anio_o_t, 100 * (1 - surv), colour = grupo)) + geom_step(linewidth = 1.1) +
  geom_hline(yintercept = 50, linetype = "dashed", colour = COL_GRIS) +
  scale_colour_manual(values = c("#BBBBBB", "#6699CC", "#004488"),
                      labels = sprintf("%s (n = %d, reached 3: %d; median %.1f yrs)", lab53$grupo, lab53$n, lab53$ev, lab53$med), name = NULL) +
  labs(x = "Years since TFR crossed 5", y = "% that have reached TFR 3",
       title = "Starting later did not mean moving faster from five to three children",
       subtitle = sprintf("Kaplan–Meier, right-censored in 2023. China %.1f years, Egypt %.1f years.", dur_pais("CHN"), dur_pais("EGY")),
       caption = pie_q1(PIE_MODELOS)) + tema_q1(12) + guides(colour = guide_legend(nrow = 3))
guardar_q1(p10, "q1_10_velocidad_5a3")

# =============================================================================
# 7. Panel en cambios quinquenales con efectos fijos país + periodo
# =============================================================================
# QUÉ: relaciona el cambio de la fecundidad con el cambio del log de la
#      mortalidad infantil en los 0-20 años previos, comparando cada país
#      consigo mismo (FE país) y quitando lo que le pasó a todos a la vez (FE
#      periodo); lo contrasta con la pendiente entre países y con placebos.
# POR QUÉ: separa "entre países" de "dentro del país" (no confundirlos
#      exageraría la relación ~2,5 veces) y prueba que no es tendencia común.
seccion("7. Panel quinquenal")

panel_base <- function(df) {
  df |> mutate(periodo = PERIODO_PANEL * (Time %/% PERIODO_PANEL), lQ5 = log(Q5), nat = NatChangeRT, crec = 10 * PopGrowthRate) |>
    filter(is.finite(lQ5)) |>
    group_by(ISO3_code, subregion, region_sdg, ingreso, periodo) |>
    summarise(across(c(TFR, lQ5, CNMR, nat, crec), mean), .groups = "drop") |>
    group_by(ISO3_code) |> arrange(periodo, .by_group = TRUE) |>
    mutate(dTFR = TFR - lag(TFR), dlQ5 = lQ5 - lag(lQ5), dCNMR = CNMR - lag(CNMR),
           L0 = dlQ5, L1 = lag(dlQ5, 1), L2 = lag(dlQ5, 2), L3 = lag(dlQ5, 3), L4 = lag(dlQ5, 4),
           F1 = lead(dlQ5, 1), T0 = dTFR, T1 = lag(dTFR, 1), T2 = lag(dTFR, 2), T3 = lag(dTFR, 3), T4 = lag(dTFR, 4),
           nat_1 = lag(nat, 1)) |> ungroup()
}
gq <- panel_base(est1m) |> left_join(pop23, by = "ISO3_code")
medias_anuales <- est1m |> group_by(ISO3_code) |> summarise(TFRm = mean(TFR), lQ5m = mean(log(Q5)))
gq_est <- gq |> filter(!is.na(dTFR), !is.na(L4)) |> left_join(medias_anuales, by = "ISO3_code")
f_dl <- dTFR ~ L0 + L1 + L2 + L3 + L4 | ISO3_code + periodo
m1 <- feols(f_dl, gq_est, cluster = ~ISO3_code)
s1 <- suma_rez(m1)
informar("Modelo principal: N = %d, países = %d, periodos %s-%s; suma de rezagos %.3f (EE %.3f); mitad de Q5 -> %.3f hijos [%.3f; %.3f] (cluster)",
         nobs(m1), n_distinct(gq_est$ISO3_code), min(gq_est$periodo), max(gq_est$periodo), s1$beta_sum, s1$ee,
         LN05 * s1$beta_sum, LN05 * s1$hi, LN05 * s1$lo)
print(round(coeftable(m1), 3))
m_entre <- lm(TFRm ~ lQ5m, data = medias_anuales)
entre <- LN05 * unname(coef(m_entre)[2])
informar("Entre países (medias 1950-2023): mitad de Q5 -> %.3f hijos; razón entre/dentro = %.2f", entre, entre / (LN05 * s1$beta_sum))

# 7.2 Bootstrap por bloques (subregión) e iid de las tres cifras
est_dentro_entre <- function(d) {
  idb <- paste(d$ISO3_code, d$.copia)
  d$id_b <- idb
  m <- feols(dTFR ~ L0 + L1 + L2 + L3 + L4 | id_b + periodo, d, vcov = "iid", notes = FALSE, warn = FALSE)
  w <- LN05 * sum(coef(m))
  u <- d[!duplicated(idb), ]
  b <- LN05 * unname(coef(stats::lm.fit(cbind(1, u$lQ5m), u$TFRm))[2])
  c(dentro = w, entre = b, razon = b / w, fraccion = w / b)
}
bb_de <- bootstrap_bloques(gq_est, est_dentro_entre, B = B_Q1, semilla = SEM)
bi_de <- bootstrap_bloques(gq_est, est_dentro_entre, bloque = NULL, B = B_Q1, semilla = SEM)
print(rbind(valor = bb_de$valor, bloques_lo = bb_de$ci_low, bloques_hi = bb_de$ci_high, iid_lo = bi_de$ci_low, iid_hi = bi_de$ci_high))

# 7.3 Heterogeneidad por ingreso (hoy) y región SDG
est_dentro <- function(d) {
  d$id_b <- paste(d$ISO3_code, d$.copia)
  LN05 * sum(coef(feols(dTFR ~ L0 + L1 + L2 + L3 + L4 | id_b + periodo, d, vcov = "iid", notes = FALSE, warn = FALSE)))
}
filas_panel <- list(tibble(bloque = "all", grupo = "All (>= 1 M)", n_paises = n_distinct(gq_est$ISO3_code), n_obs = nobs(m1),
                           beta_sum = s1$beta_sum, ee_cluster = s1$ee, halfq5 = LN05 * s1$beta_sum,
                           ci_cluster_lo = LN05 * s1$hi, ci_cluster_hi = LN05 * s1$lo,
                           ci_boot_lo = bb_de$ci_low[["dentro"]], ci_boot_hi = bb_de$ci_high[["dentro"]], metodo_boot = bb_de$method),
                    tibble(bloque = "between", grupo = "Across countries (1950-2023 means)", n_paises = nrow(medias_anuales), n_obs = nrow(medias_anuales),
                           beta_sum = unname(coef(m_entre)[2]), ee_cluster = NA, halfq5 = entre, ci_cluster_lo = NA, ci_cluster_hi = NA,
                           ci_boot_lo = bb_de$ci_low[["entre"]], ci_boot_hi = bb_de$ci_high[["entre"]], metodo_boot = bb_de$method))
het <- list()
for (g in NIVELES_INGRESO) {
  d_g <- gq_est |> filter(ingreso == g)
  m_g <- feols(f_dl, d_g, cluster = ~ISO3_code); s_g <- suma_rez(m_g)
  bb_g <- suppressWarnings(bootstrap_bloques(d_g, est_dentro, B = B_Q1, semilla = SEM))
  het[[g]] <- list(s = s_g, bb = bb_g, n = n_distinct(d_g$ISO3_code))
  filas_panel[[length(filas_panel) + 1]] <- tibble(bloque = "income", grupo = g, n_paises = n_distinct(d_g$ISO3_code), n_obs = nobs(m_g),
                                                   beta_sum = s_g$beta_sum, ee_cluster = s_g$ee, halfq5 = LN05 * s_g$beta_sum,
                                                   ci_cluster_lo = LN05 * s_g$hi, ci_cluster_hi = LN05 * s_g$lo,
                                                   ci_boot_lo = bb_g$ci_low, ci_boot_hi = bb_g$ci_high,
                                                   metodo_boot = sprintf("%s (%d blocks)", bb_g$method, bb_g$n_bloques))
}
REG_PANEL <- setdiff(REGIONES_SDG, c("Oceania (excluding Australia and New Zealand)", "Australia/New Zealand"))  # Oceanía: 3 países
het_reg <- list()
for (r in REG_PANEL) {
  d_r <- gq_est |> filter(region_sdg == r)
  m_r <- feols(f_dl, d_r, cluster = ~ISO3_code); s_r <- suma_rez(m_r)
  bi_r <- if (r %in% c("Sub-Saharan Africa", "Europe and Northern America")) bootstrap_bloques(d_r, est_dentro, bloque = NULL, B = B_Q1, semilla = SEM) else NULL
  het_reg[[r]] <- list(s = s_r, bi = bi_r, n = n_distinct(d_r$ISO3_code))
  filas_panel[[length(filas_panel) + 1]] <- tibble(bloque = "region", grupo = r, n_paises = n_distinct(d_r$ISO3_code), n_obs = nobs(m_r),
                                                   beta_sum = s_r$beta_sum, ee_cluster = s_r$ee, halfq5 = LN05 * s_r$beta_sum,
                                                   ci_cluster_lo = LN05 * s_r$hi, ci_cluster_hi = LN05 * s_r$lo,
                                                   ci_boot_lo = if (is.null(bi_r)) NA else bi_r$ci_low,
                                                   ci_boot_hi = if (is.null(bi_r)) NA else bi_r$ci_high,
                                                   metodo_boot = if (is.null(bi_r)) NA else bi_r$method)
}
cochran <- function(b, se) {
  w <- 1 / se^2; bb <- sum(w * b) / sum(w); Q <- sum(w * (b - bb)^2); gl <- length(b) - 1
  c(Q = Q, gl = gl, p = pchisq(Q, gl, lower.tail = FALSE), I2 = max(0, (Q - gl) / Q))
}
coch_ing <- cochran(sapply(het, function(x) x$s$beta_sum), sapply(het, function(x) x$s$ee))
coch_reg <- cochran(sapply(het_reg, function(x) x$s$beta_sum), sapply(het_reg, function(x) x$s$ee))
gi <- gq_est |> filter(ingreso != "Not classified") |> mutate(ingreso = droplevels(ingreso))
m_int <- feols(dTFR ~ i(ingreso, L0) + i(ingreso, L1) + i(ingreso, L2) + i(ingreso, L3) + i(ingreso, L4) | ISO3_code + periodo, gi, cluster = ~ISO3_code)
lev_i <- levels(gi$ingreso)
Rm <- matrix(0, 3, length(coef(m_int)), dimnames = list(NULL, names(coef(m_int))))
for (j in 2:4) { Rm[j - 1, paste0("ingreso::", lev_i[1], ":L", 0:4)] <- 1; Rm[j - 1, paste0("ingreso::", lev_i[j], ":L", 0:4)] <- -1 }
rb <- Rm %*% coef(m_int); wald <- as.numeric(t(rb) %*% solve(Rm %*% vcov(m_int) %*% t(Rm)) %*% rb)
wald_p <- pchisq(wald, 3, lower.tail = FALSE)
panel_tab <- bind_rows(filas_panel)
print(panel_tab |> mutate(across(where(is.numeric), \(x) round(x, 3))))
informar("Cochran Q ingreso = %.2f (gl %d, p = %.3f, I2 = %.2f); región = %.2f (gl %d, p = %.1e, I2 = %.2f); Wald (FE comunes) chi2(3) = %.2f, p = %.4f",
         coch_ing["Q"], coch_ing["gl"], coch_ing["p"], coch_ing["I2"], coch_reg["Q"], coch_reg["gl"], coch_reg["p"], coch_reg["I2"], wald, wald_p)

# 7.4 Placebo (Q5 de otro país), adelanto y sentido inverso
ids_p <- unique(gq_est$ISO3_code)
lags_tab <- gq |> select(ISO3_code, periodo, L0, L1, L2, L3, L4)
set.seed(SEM)
plac <- vapply(seq_len(B_PLAC), function(b) {
  perm <- setNames(sample(ids_p), ids_p)
  dd <- gq_est |> select(ISO3_code, periodo, dTFR) |>
    left_join(lags_tab |> filter(ISO3_code %in% ids_p) |> mutate(ISO3_code = unname(perm[ISO3_code])), by = c("ISO3_code", "periodo"))
  sum(coef(feols(f_dl, dd, vcov = "iid", notes = FALSE, warn = FALSE)))
}, numeric(1))
plac_q <- quantile(plac, c(0.025, 0.975))
plac_p <- (1 + sum(abs(plac) >= abs(s1$beta_sum))) / (B_PLAC + 1)
informar("Placebo (%d permutaciones): suma de rezagos media %.3f, 95 %% [%.3f; %.3f] vs real %.3f; p bilateral = %.3f",
         B_PLAC, mean(plac), plac_q[1], plac_q[2], s1$beta_sum, plac_p)
m_lead <- feols(dTFR ~ F1 + L0 + L1 + L2 + L3 + L4 | ISO3_code + periodo, gq_est, cluster = ~ISO3_code)
lead_ct <- coeftable(m_lead)["F1", ]
m_rev <- feols(dlQ5 ~ T0 + T1 + T2 + T3 + T4 | ISO3_code + periodo, gq |> filter(!is.na(dlQ5), !is.na(T4)), cluster = ~ISO3_code)
k_sd <- sd(gq_est$dlQ5) / sd(gq_est$dTFR)
fwd_sd <- sum(coef(m1)[paste0("L", 1:4)]) * k_sd
rev_sum <- suma_rez(m_rev, paste0("T", 1:4)); rev_sd <- rev_sum$beta_sum / k_sd
informar("Adelanto (Δlog Q5 del próximo quinquenio): %.3f (EE %.3f, p = %.3f) | estandarizado: Q5 -> TFR %.2f DE vs TFR -> Q5 %.2f DE (rezagos 5-20)",
         lead_ct[1], lead_ct[2], lead_ct[4], fwd_sd, rev_sd)

# 7.5 Sensibilidades: dejar un país fuera, 237 países, sin 2020-23, diferencia larga, ponderado
loo <- vapply(ids_p, function(i) LN05 * sum(coef(feols(f_dl, gq_est |> filter(ISO3_code != i), vcov = "iid", notes = FALSE))), numeric(1))
gq_all <- panel_base(anual_est) |> filter(!is.na(dTFR), !is.na(L4))
s_237 <- suma_rez(feols(f_dl, gq_all, cluster = ~ISO3_code))
s_sin20 <- suma_rez(feols(f_dl, gq_est |> filter(periodo < 2020), cluster = ~ISO3_code))
s_pond <- suma_rez(feols(f_dl, gq_est, weights = ~pop_2023_miles, cluster = ~ISO3_code))
s_cnmr <- suma_rez(feols(dTFR ~ L0 + L1 + L2 + L3 + L4 + dCNMR | ISO3_code + periodo, gq_est, cluster = ~ISO3_code))
ld <- gq |> group_by(ISO3_code) |> summarise(dT = TFR[periodo == 2020] - TFR[periodo == 1950], dl = lQ5[periodo == 2020] - lQ5[periodo == 1950])
ld_b <- unname(coef(lm(dT ~ dl, ld))[2])
sens_panel <- c(loo_min = min(loo), loo_max = max(loo), p237 = LN05 * s_237$beta_sum, sin2020 = LN05 * s_sin20$beta_sum,
                larga = LN05 * ld_b, ponderado = LN05 * s_pond$beta_sum, con_dCNMR = LN05 * s_cnmr$beta_sum)
print(round(sens_panel, 3))
informar("  LOO más influyentes: %s (min) y %s (max); países en la versión 237: %d",
         names(loo)[which.min(loo)], names(loo)[which.max(loo)], n_distinct(gq_all$ISO3_code))

# 7.6 Descomposición de varianza del crecimiento: ¿cuánto es migración, entre y dentro?
anual1m <- est1m |> mutate(crec = 10 * PopGrowthRate)
cuota_var <- function(d) {
  idb <- paste(d$ISO3_code, d$.copia)
  mc <- tapply(d$crec, idb, mean); mm <- tapply(d$CNMR, idb, mean)
  entre_v <- stats::cov(mc, mm) / stats::var(mc)
  dm <- fixest::demean(as.matrix(d[, c("crec", "CNMR")]), f = data.frame(a = idb, b = d$Time), notes = FALSE)
  dentro_v <- stats::cov(dm[, 1], dm[, 2]) / stats::var(dm[, 1])
  c(entre = entre_v, dentro = dentro_v)
}
dv <- anual1m |> select(ISO3_code, subregion, Time, crec, CNMR)
bb_var <- bootstrap_bloques(dv, cuota_var, B = B_NB, semilla = SEM)
bb_var_ng <- bootstrap_bloques(dv |> filter(!es_golfo(ISO3_code)), cuota_var, B = B_NB, semilla = SEM)
informar("Migración en la varianza del crecimiento: entre %.2f [%.2f; %.2f], dentro %.2f [%.2f; %.2f]; sin Golfo: entre %.2f, dentro %.2f",
         bb_var$valor[1], bb_var$ci_low[1], bb_var$ci_high[1], bb_var$valor[2], bb_var$ci_low[2], bb_var$ci_high[2],
         bb_var_ng$valor[1], bb_var_ng$valor[2])

# 7.7 ¿"Compensa" la migración la caída del saldo natural dentro del país? (ingreso alto sin Golfo)
hi_q <- gq |> filter(ingreso == "High income", !es_golfo(ISO3_code), !is.na(nat_1))
m_hi <- feols(CNMR ~ nat_1 | ISO3_code + periodo, hi_q, cluster = ~ISO3_code)
m_hi_pais <- feols(CNMR ~ nat_1 | ISO3_code, hi_q, cluster = ~ISO3_code)
ct_hi <- coeftable(m_hi)["nat_1", ]; ct_hp <- coeftable(m_hi_pais)["nat_1", ]
est_comp <- function(d) {
  d$id_b <- paste(d$ISO3_code, d$.copia)
  unname(coef(feols(CNMR ~ nat_1 | id_b + periodo, d, vcov = "iid", notes = FALSE, warn = FALSE))["nat_1"])
}
bb_hi <- bootstrap_bloques(hi_q, est_comp, B = B_Q1, semilla = SEM)
bi_hi <- bootstrap_bloques(hi_q, est_comp, bloque = NULL, B = B_Q1, semilla = SEM)
cal_hi <- hi_q |> group_by(periodo) |> summarise(nat = mean(nat), CNMR = mean(CNMR))
informar("Ingreso alto sin Golfo (%d países): CNMR ~ nat(t-1) dentro (país + periodo) = %.3f [cluster %.3f; %.3f] [bloques %.3f; %.3f]; solo FE país = %.3f [%.3f; %.3f]",
         n_distinct(hi_q$ISO3_code), ct_hi[1], ct_hi[1] - 1.96 * ct_hi[2], ct_hi[1] + 1.96 * ct_hi[2], bb_hi$ci_low, bb_hi$ci_high,
         ct_hp[1], ct_hp[1] - 1.96 * ct_hp[2], ct_hp[1] + 1.96 * ct_hp[2])
informar("  calendario del grupo: saldo natural %.1f -> %.1f por mil; migración %.1f -> %.1f por mil (%d-%d)",
         cal_hi$nat[cal_hi$periodo == min(cal_hi$periodo)], cal_hi$nat[cal_hi$periodo == 2020],
         cal_hi$CNMR[cal_hi$periodo == min(cal_hi$periodo)], cal_hi$CNMR[cal_hi$periodo == 2020], min(cal_hi$periodo), 2020)

# 7.8 Comparación honesta: mismo objetivo, mismo denominador, países fuera de muestra
base_cmp <- gq_est |> filter(ingreso != "Not classified", region_sdg %in% REG_PANEL) |> mutate(ingreso = droplevels(ingreso))
LAGS <- paste0("L", 0:4)
for (v in LAGS) {
  for (g in levels(base_cmp$ingreso)) base_cmp[[paste0(v, "_ing_", make.names(g))]] <- base_cmp[[v]] * (base_cmp$ingreso == g)
  for (r in REG_PANEL) base_cmp[[paste0(v, "_reg_", make.names(r))]] <- base_cmp[[v]] * (base_cmp$region_sdg == r)
}
modelos_cmp <- list(M0 = character(0), M1 = "L0", M2 = LAGS,
                    M3 = grep("_ing_", names(base_cmp), value = TRUE), M4 = grep("_reg_", names(base_cmp), value = TRUE))
nombres_cmp <- c(M0 = "M0 Calendar only (country + period FE)", M1 = "M1 Same-period change in child mortality",
                 M2 = "M2 Lags 0-20 years (one slope set)", M3 = "M3 Lags x income group", M4 = "M4 Lags x SDG region ('local')")
ajusta <- function(d, xs) {
  f <- if (length(xs)) paste("dTFR ~", paste(xs, collapse = " + "), "| ISO3_code + periodo") else "dTFR ~ 1 | ISO3_code + periodo"
  feols(as.formula(f), d, vcov = "iid", notes = FALSE, warn = FALSE)
}
predice <- function(m, d, xs) {
  yhat <- unname(fixef(m)$periodo[as.character(d$periodo)])
  if (length(xs)) { b <- coef(m); b[is.na(b)] <- 0; yhat <- yhat + as.matrix(d[, names(b)]) %*% b }
  as.numeric(yhat)
}
r2_dentro <- function(y, yhat, id) { yd <- y - ave(y, id); hd <- yhat - ave(yhat, id); 1 - sum((yd - hd)^2) / sum(yd^2) }
cmp_in <- bind_rows(lapply(names(modelos_cmp), function(k) {
  xs <- modelos_cmp[[k]]; m <- ajusta(base_cmp, xs)
  yh <- fitted(m) - unname(fixef(m)$ISO3_code[base_cmp$ISO3_code[obs(m)]])
  tibble(modelo = nombres_cmp[[k]], clave = k, k_pendientes = length(xs), n = nobs(m),
         r2_dentro_in = r2_dentro(base_cmp$dTFR[obs(m)], yh, base_cmp$ISO3_code[obs(m)]), AIC = AIC(m), BIC = BIC(m))
}))
ids_c <- unique(base_cmp$ISO3_code)
set.seed(SEM)
cv_rep <- bind_rows(lapply(1:5, function(rep) {
  fold <- setNames(sample(rep(1:10, length.out = length(ids_c))), ids_c)
  bind_rows(lapply(names(modelos_cmp), function(k) {
    xs <- modelos_cmp[[k]]; pred <- rep(NA_real_, nrow(base_cmp))
    for (f in 1:10) { te <- fold[base_cmp$ISO3_code] == f; m <- ajusta(base_cmp[!te, ], xs); pred[te] <- predice(m, base_cmp[te, ], xs) }
    ok <- !is.na(pred)
    tibble(rep = rep, clave = k, r2 = r2_dentro(base_cmp$dTFR[ok], pred[ok], base_cmp$ISO3_code[ok]))
  }))
}))
cmp_tab <- cmp_in |> left_join(cv_rep |> group_by(clave) |> summarise(r2_dentro_oos = mean(r2), sd_rep = sd(r2)), by = "clave")
print(cmp_tab |> mutate(across(where(is.numeric), \(x) round(x, 3))))

# 7.9 Registro de cifras del panel
F_PANEL <- sprintf("161 countries >= 1 M; 5-year period means 1950-54 ... 2020-23; changes 1975-2023 (N = %d); country + period fixed effects", nobs(m1))
sens_txt <- sprintf("leave-one-country-out %.2f to %.2f; 237 countries %.2f; without 2020-23 %.2f; long difference 1950-54 -> 2020-23 %.2f; population-weighted %.2f; with change in CNMR %.2f; cluster-robust 95%% [%.2f; %.2f]",
                    sens_panel["loo_min"], sens_panel["loo_max"], sens_panel["p237"], sens_panel["sin2020"], sens_panel["larga"],
                    sens_panel["ponderado"], sens_panel["con_dCNMR"], LN05 * s1$hi, LN05 * s1$lo)
sens_rng <- range(sens_panel[c("loo_min", "loo_max", "p237", "sin2020", "larga")])
anotar("panel_within_halfq5", value = round(LN05 * s1$beta_sum, 4), unit = "children per woman", fmt = "0.00",
       ic = extraer_ic(bb_de, "dentro"), ic_iid = extraer_ic(bi_de, "dentro"),
       def = "Within the same country: change in TFR associated with halving under-five mortality over the current and previous 20 years (sum of 5 distributed-lag coefficients of the change in log Q5 x ln 0.5)",
       filter = F_PANEL, source_cell = "Q1-7.1", used_in = c("slide2.build3", "narration.slide2"),
       sens_low = round(sens_rng[1], 4), sens_high = round(sens_rng[2], 4), sens_note = sens_txt,
       status = "exploratory", hypothesis_id = "H15", say = "0.4", n = n_distinct(gq_est$ISO3_code), universe = UNIVERSO_1M)
anotar("panel_between_halfq5", value = round(entre, 4), unit = "children per woman", fmt = "0.00",
       ic = extraer_ic(bb_de, "entre"), ic_iid = extraer_ic(bi_de, "entre"),
       def = "Across countries: TFR difference associated with half the under-five mortality, regression of 1950-2023 country means of TFR on mean log Q5 (x ln 0.5)",
       filter = "161 countries >= 1 M, annual estimates 1950-2023 (country means)", source_cell = "Q1-7.1",
       used_in = c("slide2.build3", "narration.slide2"), status = "exploratory", hypothesis_id = "H15", say = "about one child",
       n = nrow(medias_anuales), universe = UNIVERSO_1M)
anotar("panel_ratio_between_within", value = round(entre / (LN05 * s1$beta_sum), 4), unit = "ratio", fmt = "0.0",
       ic = extraer_ic(bb_de, "razon"), ic_iid = extraer_ic(bi_de, "razon"),
       def = "panel_between_halfq5 / panel_within_halfq5", filter = F_PANEL, source_cell = "Q1-7.1",
       sens_note = "the block-bootstrap interval of a ratio is unstable (the within-country denominator's own interval reaches 0); say 'less than half' (within / between) rather than an interval for the ratio",
       used_in = c("slide2.build3", "narration.slide2"), status = "exploratory", hypothesis_id = "H15", say = "about two and a half times",
       n = n_distinct(gq_est$ISO3_code), universe = UNIVERSO_1M)
# Fracción dentro / entre: es la cifra que respalda "less than half" en la voz
# (el denominador, entre países, es estable en el bootstrap; el cociente inverso no).
anotar("panel_within_over_between", value = round((LN05 * s1$beta_sum) / entre, 4), unit = "share", fmt = "0.00",
       ic = extraer_ic(bb_de, "fraccion"), ic_iid = extraer_ic(bi_de, "fraccion"),
       def = "panel_within_halfq5 / panel_between_halfq5: the within-country association as a share of the cross-country one",
       filter = F_PANEL, source_cell = "Q1-7.1", used_in = c("narration.slide2"),
       sens_note = "supports 'less than half what comparing countries suggests'; the upper limit of the block interval is what limits that wording",
       status = "exploratory", hypothesis_id = "H15", say = "less than half", n = n_distinct(gq_est$ISO3_code), universe = UNIVERSO_1M)
claves_het <-c("Low income" = "panel_low_income_halfq5", "Lower middle income" = "panel_lowmid_halfq5",
                "Upper middle income" = "panel_upmid_halfq5", "High income" = "panel_high_halfq5")
for (g in NIVELES_INGRESO) {
  x <- het[[g]]
  anotar(claves_het[[g]], value = round(LN05 * x$s$beta_sum, 4), unit = "children per woman", fmt = "0.00", ic = x$bb,
         def = sprintf("Same within-country association estimated only with today's %s countries (own period effects)", g),
         filter = sprintf("%s (FY2027) within: %s", g, F_PANEL), source_cell = "Q1-7.3", used_in = c("slide2.build3"),
         sens_note = sprintf("cluster-robust 95%% [%.2f; %.2f]; %d UN subregions as blocks", LN05 * x$s$hi, LN05 * x$s$lo, x$bb$n_bloques),
         status = "exploratory", hypothesis_id = "H15", n = x$n, universe = UNIVERSO_1M)
}
for (r in c("Sub-Saharan Africa", "Europe and Northern America")) {
  x <- het_reg[[r]]
  anotar(if (r == "Sub-Saharan Africa") "panel_ssa_halfq5" else "panel_eurna_halfq5",
         value = round(LN05 * x$s$beta_sum, 4), unit = "children per woman", fmt = "0.00", ic_iid = x$bi,
         method = "bootstrap_perc", B = x$bi$B, seed = x$bi$seed, resample_unit = "country",
         def = sprintf("Same within-country association estimated only with countries in %s (own period effects)", r),
         filter = sprintf("%s within: %s", r, F_PANEL), source_cell = "Q1-7.3", used_in = c("slide2.build3", "narration.slide2"),
         sens_note = sprintf("value only on screen; country bootstrap stored in ci_iid (too few UN subregions for blocks); cluster-robust 95%% [%.2f; %.2f]", LN05 * x$s$hi, LN05 * x$s$lo),
         status = "exploratory", hypothesis_id = "H15", n = x$n, universe = UNIVERSO_1M)
}
anotar("panel_i2_income", value = round(unname(coch_ing["I2"]), 4), unit = "I2", fmt = "0.00", method = "descriptive",
       def = "Cochran Q heterogeneity (I2) of the within-country sums across the 4 income groups", filter = F_PANEL,
       source_cell = "Q1-7.3", used_in = c("notebook.T5"), p_value = signif(unname(coch_ing["p"]), 4),
       sens_note = sprintf("Q = %.2f (%d df); Wald test with common period effects chi2(3) = %.2f, p = %.4f", coch_ing["Q"], coch_ing["gl"], wald, wald_p),
       status = "exploratory", hypothesis_id = "H15", n = n_distinct(gi$ISO3_code), universe = UNIVERSO_1M)
anotar("panel_i2_region", value = round(unname(coch_reg["I2"]), 4), unit = "I2", fmt = "0.00", method = "descriptive",
       def = "Cochran Q heterogeneity (I2) across 6 SDG regions (Oceania and Australia/New Zealand excluded: 3 countries)", filter = F_PANEL,
       source_cell = "Q1-7.3", used_in = c("notebook.T5"), p_value = signif(unname(coch_reg["p"]), 4),
       sens_note = sprintf("Q = %.2f (%d df)", coch_reg["Q"], coch_reg["gl"]), status = "exploratory", hypothesis_id = "H15",
       n = sum(sapply(het_reg, `[[`, "n")), universe = UNIVERSO_1M)
for (lado in c("lo", "hi")) {
  q <- if (lado == "lo") plac_q[[1]] else plac_q[[2]]
  anotar(paste0("panel_placebo_", lado), value = round(LN05 * (if (lado == "lo") plac_q[[2]] else plac_q[[1]]), 4),
         unit = "children per woman", fmt = "0.00", method = "permutation", B = B_PLAC, seed = SEM,
         def = sprintf("%s limit of the 95%% placebo band in halving-of-Q5 units: the same model with the Q5 series of a randomly permuted other country", if (lado == "lo") "Lower" else "Upper"),
         filter = F_PANEL, source_cell = "Q1-7.4", used_in = c("slide2.build3"),
         sens_note = sprintf("placebo sums of lag coefficients 95%% [%.3f; %.3f] vs real %.3f; two-sided permutation p = %.3f", plac_q[1], plac_q[2], s1$beta_sum, plac_p),
         p_value = plac_p, status = "exploratory", hypothesis_id = "H15", n = n_distinct(gq_est$ISO3_code), universe = UNIVERSO_1M)
}
anotar("panel_lead", value = round(unname(lead_ct[1]), 4), unit = "coefficient", fmt = "0.00", method = "descriptive",
       def = "Falsification: coefficient of NEXT period's change in log Q5 added to the main model (should be ~0 if only past mortality changes went with fertility changes)",
       filter = sprintf("%s; N = %d", F_PANEL, nobs(m_lead)), source_cell = "Q1-7.4", used_in = c("notebook.T5"),
       sens_note = sprintf("cluster-robust SE %.3f, 95%% [%.2f; %.2f]", lead_ct[2], lead_ct[1] - 1.96 * lead_ct[2], lead_ct[1] + 1.96 * lead_ct[2]),
       p_value = signif(unname(lead_ct[4]), 4), status = "exploratory", hypothesis_id = "H15", n = n_distinct(gq_est$ISO3_code), universe = UNIVERSO_1M)
anotar("panel_forward_sd", value = round(fwd_sd, 4), unit = "SD", fmt = "0.00", method = "descriptive",
       def = "Standardised sum of the 5-20-year lags, child mortality -> fertility (SD of change in TFR per SD of change in log Q5)",
       filter = F_PANEL, source_cell = "Q1-7.4", used_in = c("notebook.T5"), status = "exploratory", hypothesis_id = "H15",
       n = n_distinct(gq_est$ISO3_code), universe = UNIVERSO_1M)
anotar("panel_reverse_sd", value = round(rev_sd, 4), unit = "SD", fmt = "0.00", method = "descriptive",
       def = "Standardised sum of the 5-20-year lags in the reverse direction, fertility -> child mortality (change in log Q5 on lagged change in TFR)",
       filter = F_PANEL, source_cell = "Q1-7.4", used_in = c("notebook.T5"),
       sens_note = sprintf("raw sum %.3f (cluster SE %.3f)", rev_sum$beta_sum, rev_sum$ee), status = "exploratory", hypothesis_id = "H15",
       n = n_distinct(gq_est$ISO3_code), universe = UNIVERSO_1M)
anotar("mig_hi_within_slope", value = round(unname(ct_hi[1]), 4), unit = "per 1,000 per 1 point of natural increase", fmt = "0.00",
       ic = bb_hi, ic_iid = bi_hi,
       def = "Within the same high-income country (Gulf excluded): change in the net migration rate associated with 1 more point (per 1,000) of natural increase in the previous 5-year period, country + period fixed effects",
       filter = sprintf("%d high-income (FY2027) countries >= 1 M without the six Gulf states; 5-year means 1955-2023", n_distinct(hi_q$ISO3_code)),
       source_cell = "Q1-7.7", used_in = c("notebook.T5"),
       sens_note = sprintf("cluster-robust 95%% [%.2f; %.2f]; with country FE only (common calendar left in) %.2f [%.2f; %.2f]",
                           ct_hi[1] - 1.96 * ct_hi[2], ct_hi[1] + 1.96 * ct_hi[2], ct_hp[1], ct_hp[1] - 1.96 * ct_hp[2], ct_hp[1] + 1.96 * ct_hp[2]),
       p_value = signif(unname(ct_hi[4]), 4), status = "exploratory", hypothesis_id = "H16", n = n_distinct(hi_q$ISO3_code), universe = UNIVERSO_1M)
anotar("mig_hi_countryfe_slope", value = round(unname(ct_hp[1]), 4), unit = "per 1,000 per 1 point of natural increase", fmt = "0.00",
       method = "descriptive",
       def = "Same slope with country fixed effects only (the common calendar is left in): the apparent 'compensation'",
       filter = sprintf("%d high-income countries >= 1 M without the Gulf", n_distinct(hi_q$ISO3_code)), source_cell = "Q1-7.7",
       used_in = c("notebook.T5"), sens_note = sprintf("cluster-robust 95%% [%.2f; %.2f] (notebook only)", ct_hp[1] - 1.96 * ct_hp[2], ct_hp[1] + 1.96 * ct_hp[2]), status = "exploratory", hypothesis_id = "H16",
       n = n_distinct(hi_q$ISO3_code), universe = UNIVERSO_1M)
for (k in c("entre", "dentro")) for (ng in c(FALSE, TRUE)) {
  x <- if (ng) bb_var_ng else bb_var
  anotar(paste0("mig_share_", ifelse(k == "entre", "between", "within"), ifelse(ng, "_excl_gulf", "")),
         value = round(x$valor[[k]], 4), unit = "share of variance", fmt = "0.00", ic = extraer_ic(x, k),
         def = sprintf("Share of the %s variance of population growth that corresponds to net migration: cov(growth, CNMR) / var(growth) (accounting identity growth = natural + migration)",
                       ifelse(k == "entre", "between-country (1950-2023 country means)", "within-country (net of country and year effects)")),
         filter = sprintf("%s, annual estimates 1950-2023", ifelse(ng, "155 countries >= 1 M without the Gulf", "161 countries >= 1 M")),
         source_cell = "Q1-7.6", used_in = c("notebook.T5"), status = "exploratory", n = x$n_unidades, universe = UNIVERSO_1M)
}
for (k in cmp_tab$clave) {
  x <- cmp_tab |> filter(clave == k)
  anotar(paste0("r2_oos_", tolower(k)), value = round(x$r2_dentro_oos, 4), unit = "R2 within", fmt = "0.000", method = "cv_r2", B = 5, seed = SEM,
         def = sprintf("%s: within-country R2 of 5-year TFR changes in countries left out (10 blocks of countries x 5 repetitions), same denominator as in sample", x$modelo),
         filter = sprintf("%d countries >= 1 M with income group, Oceania excluded; N = %d", length(ids_c), x$n), source_cell = "Q1-7.8",
         used_in = c("notebook.T5"), sens_note = sprintf("in sample %.3f; AIC %.0f; BIC %.0f; SD across repetitions %.3f", x$r2_dentro_in, x$AIC, x$BIC, x$sd_rep),
         status = "exploratory", n = length(ids_c), universe = UNIVERSO_1M)
  anotar(paste0("r2_in_", tolower(k)), value = round(x$r2_dentro_in, 4), unit = "R2 within", fmt = "0.000", method = "descriptive",
         def = sprintf("%s: within-country R2 in sample (same denominator as out of sample)", x$modelo),
         filter = sprintf("%d countries >= 1 M with income group, Oceania excluded", length(ids_c)), source_cell = "Q1-7.8",
         used_in = c("notebook.T5"), status = "exploratory", n = length(ids_c), universe = UNIVERSO_1M)
}

# 7.10 Figuras de revisión: forest y comparación de modelos
fig_for <- panel_tab |> filter(bloque %in% c("all", "income", "region", "between")) |>
  mutate(etq = case_when(bloque == "income" ~ paste("Income:", ETIQUETAS_INGRESO_CORTAS_EN[grupo]),
                         bloque == "region" ~ paste("Region:", ETIQUETAS_REGION_CORTAS_EN[grupo]),
                         bloque == "between" ~ "Across countries (between)", TRUE ~ "All, within the same country"),
         lo = ifelse(is.na(ci_boot_lo), ci_cluster_lo, ci_boot_lo), hi = ifelse(is.na(ci_boot_hi), ci_cluster_hi, ci_boot_hi),
         tipo_ic = ifelse(is.na(ci_boot_lo), "cluster-robust", "bootstrap"))
fig_for$etq <- factor(fig_for$etq, levels = rev(fig_for$etq))
p11 <- ggplot(fig_for, aes(halfq5, etq)) +
  annotate("rect", xmin = LN05 * plac_q[2], xmax = LN05 * plac_q[1], ymin = -Inf, ymax = Inf, fill = "grey88") +
  geom_vline(xintercept = 0, colour = COL_GRIS) +
  geom_vline(xintercept = entre, colour = COLOR_DEFUNCIONES, linetype = "dashed") +
  geom_errorbar(aes(xmin = lo, xmax = hi, linetype = tipo_ic), width = 0.25, orientation = "y") + geom_point(size = 2.6) +
  geom_text(aes(label = sprintf("%.2f", halfq5)), vjust = -0.9, size = 3.2) +
  scale_linetype_manual(values = c(bootstrap = "solid", `cluster-robust` = "dotted"), name = "95% interval") +
  labs(x = "Children per woman associated with halving under-five mortality (over the following 20 years)", y = NULL,
       title = sprintf("Within the same country the link is %.2f children — across countries %.2f", LN05 * s1$beta_sum, entre),
       subtitle = "5-year changes 1975–2023, country and period fixed effects, each country counts once. Grey band: placebo (Q5 of another country), 95%.",
       caption = pie_q1(PIE_MODELOS, badge("PIE-4"), sprintf("Association, not cause. Solid bars: bootstrap (B = %d; All, between and income rows by UN subregion blocks; SSA and Europe/N. America by country). Dotted: cluster-robust.", B_Q1))) + tema_q1(11)
guardar_q1(p11, "q1_11_panel_forest")
fig_cmp <- cmp_tab |> select(modelo, r2_dentro_in, r2_dentro_oos) |> pivot_longer(-modelo) |>
  mutate(name = ifelse(name == "r2_dentro_in", "In sample", "Countries left out"), modelo = factor(modelo, levels = rev(cmp_tab$modelo)))
p12 <- ggplot(fig_cmp, aes(100 * value, modelo, fill = name)) + geom_col(position = position_dodge(width = 0.7), width = 0.65) +
  geom_text(aes(label = sprintf("%.1f%%", 100 * value)), position = position_dodge(width = 0.7), hjust = -0.1, size = 3.3) +
  scale_fill_manual(values = c("In sample" = "#BBBBBB", "Countries left out" = "#004488"), name = NULL) +
  labs(x = "Within-country R² of 5-year fertility changes (%)", y = NULL,
       title = "The most flexible model fits best in sample and does worst on countries left out",
       subtitle = sprintf("Same outcome, same %d countries, same denominator; 10 blocks of countries × 5 repetitions", length(ids_c)),
       caption = pie_q1(PIE_MODELOS)) + tema_q1(12) + expand_limits(x = 26)
guardar_q1(p12, "q1_12_comparacion_modelos")
# Placebo del panel y "compensación" migratoria en ingreso alto (H15, H16)
p13a <- ggplot(tibble(h = LN05 * plac), aes(h)) +
  geom_histogram(bins = 30, fill = "grey75", colour = "white") +
  geom_vline(xintercept = LN05 * s1$beta_sum, colour = COLOR_DEFUNCIONES, linewidth = 1.2) +
  annotate("text", x = LN05 * s1$beta_sum, y = Inf, vjust = 1.5, hjust = -0.08, colour = COLOR_DEFUNCIONES, size = 3.6,
           label = sprintf("real: %.2f", LN05 * s1$beta_sum)) +
  labs(x = "Children per woman per halving of Q5 (placebo = Q5 series of another country)", y = "Permutations",
       title = sprintf("A · Placebo: %d permutations, 95%% within [%.2f; %.2f]", B_PLAC, LN05 * plac_q[2], LN05 * plac_q[1]),
       subtitle = sprintf("Two-sided permutation p = %.3f (notebook only)", plac_p)) + tema_q1(11)
comp_df <- tibble(modelo = factor(c("Country + period effects (within, calendar removed)", "Country effects only (shared calendar left in)"),
                                  levels = rev(c("Country + period effects (within, calendar removed)", "Country effects only (shared calendar left in)"))),
                  b = c(ct_hi[1], ct_hp[1]), lo = c(bb_hi$ci_low, ct_hp[1] - 1.96 * ct_hp[2]), hi = c(bb_hi$ci_high, ct_hp[1] + 1.96 * ct_hp[2]),
                  ic = c("block bootstrap", "cluster-robust"))
p13b <- ggplot(comp_df, aes(b, modelo)) + geom_vline(xintercept = 0, colour = COL_GRIS) +
  geom_errorbar(aes(xmin = lo, xmax = hi, linetype = ic), width = 0.2, orientation = "y") + geom_point(size = 3) +
  geom_text(aes(label = sprintf("%+.2f", b)), vjust = -1, size = 3.6) +
  scale_linetype_manual(values = c(`block bootstrap` = "solid", `cluster-robust` = "dotted"), name = "95% interval") +
  labs(x = "Change in net migration rate (per 1,000) per 1 more point of natural increase in the previous 5 years", y = NULL,
       title = sprintf("B · High income without the Gulf (%d countries): no within-country 'compensation'", n_distinct(hi_q$ISO3_code)),
       subtitle = sprintf("Group calendar: natural increase %.1f -> %.1f per 1,000 and net migration %.1f -> %.1f per 1,000 (%d-%d)",
                          cal_hi$nat[cal_hi$periodo == min(cal_hi$periodo)], cal_hi$nat[cal_hi$periodo == 2020],
                          cal_hi$CNMR[cal_hi$periodo == min(cal_hi$periodo)], cal_hi$CNMR[cal_hi$periodo == 2020], min(cal_hi$periodo), 2020)) +
  tema_q1(11) + theme(legend.position = "bottom")
p13 <- (p13a / p13b) + plot_annotation(caption = pie_q1(PIE_MODELOS, "Association, not cause. 5-year period means; each country counts once."))
guardar_q1(p13, "q1_13_placebo_compensacion")

# =============================================================================
# 8. Migración: memoria corta y paradoja tipo Simpson con el ingreso
# =============================================================================
# QUÉ: compara cuánto se parece la migración de un país en décadas
#      consecutivas frente a fecundidad y vida, y si su correlación mundial
#      con la mortalidad infantil sobrevive dentro de cada grupo de ingreso.
# POR QUÉ: sustituye la frase "no memory" (v1) por una medida que un
#      demógrafo aceptaría y evita leer una diferencia de ingreso como vínculo.
seccion("8. Migración: memoria y Simpson")

decadas <- function(df, tope = 2010) {
  df |> mutate(decada = pmin(10 * (Time %/% 10), tope)) |> group_by(ISO3_code, subregion, decada) |>
    summarise(across(c(CNMR, TFR, LEx), mean), .groups = "drop")
}
memoria <- function(dec, version) {
  ds <- sort(unique(dec$decada))
  bind_rows(lapply(c("CNMR", "TFR", "LEx"), function(v) {
    w <- dec |> select(ISO3_code, decada, all_of(v)) |> pivot_wider(names_from = decada, values_from = all_of(v))
    bind_rows(lapply(seq_len(length(ds) - 1), function(j) {
      a <- w[[as.character(ds[j])]]; b <- w[[as.character(ds[j + 1])]]
      tibble(variable = v, version = version, decada_a = ds[j], decada_b = ds[j + 1],
             r_pearson = cor(a, b), r_spearman = cor(a, b, method = "spearman"), n = sum(complete.cases(a, b)))
    }))
  }))
}
dec_main <- decadas(est1m, 2010)
mem <- bind_rows(memoria(dec_main, "2010s = 2010-2023"), memoria(decadas(est1m, 2020), "2010s = 2010-2019; 2020-2023 separate"))
print(mem |> filter(version == "2010s = 2010-2023") |> select(variable, decada_a, r_pearson) |>
        pivot_wider(names_from = variable, values_from = r_pearson) |> mutate(across(where(is.numeric), \(x) round(x, 2))))
mm <- mem |> filter(version == "2010s = 2010-2023")
r_cn <- mm$r_pearson[mm$variable == "CNMR"]; r_tl <- mm$r_pearson[mm$variable %in% c("TFR", "LEx")]
w_cn <- dec_main |> select(ISO3_code, subregion, decada, CNMR) |> pivot_wider(names_from = decada, values_from = CNMR)
f_r0010 <- function(d) cor(d$`2000`, d$`2010`)
bb_r0010 <- bootstrap_bloques(w_cn, f_r0010, B = B_Q1, semilla = SEM)
bi_r0010 <- bootstrap_bloques(w_cn, f_r0010, bloque = NULL, B = B_Q1, semilla = SEM)
signo <- sign(w_cn$`2000`) == sign(w_cn$`2010`)
w_sig <- ic_wilson(sum(signo), length(signo), escala = 100)
y5023 <- est1m |> filter(Time %in% c(1950, 2023)) |> select(ISO3_code, subregion, Time, CNMR, TFR) |>
  pivot_wider(names_from = Time, values_from = c(CNMR, TFR))
f_r5023 <- function(d) cor(d$CNMR_1950, d$CNMR_2023)
bb_r5023 <- bootstrap_bloques(y5023, f_r5023, B = B_NB, semilla = SEM)
r_tfr5023 <- cor(y5023$TFR_1950, y5023$TFR_2023)
# beta de "convergencia" de la CNMR y su placebo (H4: beta = -1 es lo que da el ruido)
bx <- est1m |> group_by(ISO3_code) |> summarise(x0 = mean(CNMR[Time %in% 1950:1954]), x1 = mean(CNMR[Time %in% 2019:2023]))
beta_cn <- unname(coef(lm(I(x1 - x0) ~ x0, bx))[2])
set.seed(SEM)
beta_plac <- replicate(1000, unname(coef(lm(I(sample(bx$x1) - bx$x0) ~ bx$x0))[2]))
informar("Memoria: CNMR entre décadas %.2f-%.2f (2000s->2010s %.2f [bloques %.2f; %.2f]) vs TFR/LEx mínimo %.2f; mantienen signo 2000s->2010s %.1f %% [%.1f; %.1f]",
         min(r_cn), max(r_cn), bb_r0010$valor, bb_r0010$ci_low, bb_r0010$ci_high, min(r_tl), w_sig$valor, w_sig$ci_low, w_sig$ci_high)
informar("CNMR 1950 vs 2023: r = %.2f (TFR %.2f) | beta CNMR 1950-54 -> 2019-23 = %.2f (placebo media %.2f, 95 %% [%.2f; %.2f]); DE %.1f -> %.1f",
         bb_r5023$valor, r_tfr5023, beta_cn, mean(beta_plac), quantile(beta_plac, 0.025), quantile(beta_plac, 0.975), sd(bx$x0), sd(bx$x1))

# 8.2 Simpson: Q5 y migración, mundo vs dentro de cada grupo de ingreso (2021-2023)
v2123 <- resumen_ventana(2021:2023, c("Q5", "CNMR", "TFR"), muestra = "1m")
rho_s <- function(x, y) cor(x, y, method = "spearman")
simp <- list()
for (par in list(c("Q5", "CNMR"), c("TFR", "CNMR"))) {
  f_rho <- function(d) rho_s(d[[par[1]]], d[[par[2]]])
  for (g in c("World", NIVELES_INGRESO)) {
    d_g <- if (g == "World") v2123 else v2123 |> filter(ingreso == g)
    bb <- suppressWarnings(bootstrap_bloques(d_g, f_rho, B = B_Q1, semilla = SEM))
    simp[[length(simp) + 1]] <- tibble(par = paste(par, collapse = "-"), grupo = g, rho = bb$valor, ci_lo = bb$ci_low, ci_hi = bb$ci_high,
                                       n = nrow(d_g), n_bloques = bb$n_bloques, bb = list(bb))
  }
}
simp <- bind_rows(simp)
vc <- v2123 |> filter(ingreso != "Not classified") |> mutate(ingreso = droplevels(ingreso))
rho_parcial <- cor(resid(lm(rank(Q5) ~ ingreso, vc)), resid(lm(rank(CNMR) ~ ingreso, vc)))
print(simp |> select(-bb) |> mutate(across(where(is.numeric), \(x) round(x, 3))))
informar("Spearman parcial Q5-CNMR dado el ingreso: %.2f", rho_parcial)
# H5 (v1): TFR-CNMR en ingreso alto, 2023 (>= 1 M y los 237)
hi23 <- corte_anio(2023, "1m") |> filter(ingreso == "High income")
hi23_all <- corte_anio(2023, "completa") |> filter(ingreso == "High income")
h5_bca <- bootstrap_bca(hi23, function(d) rho_s(d$TFR, d$CNMR), B = B_Q1, semilla = SEM)
h5_all_p <- cor(hi23_all$TFR, hi23_all$CNMR); h5_all_s <- rho_s(hi23_all$TFR, hi23_all$CNMR)
informar("H5: Spearman TFR-CNMR 2023, ingreso alto >= 1 M (n=%d) = %.2f [BCa %.2f; %.2f]; con los %d de ingreso alto: Pearson %.2f, Spearman %.2f",
         nrow(hi23), h5_bca$valor, h5_bca$ci_low, h5_bca$ci_high, nrow(hi23_all), h5_all_p, h5_all_s)

F_MEM <- "161 countries >= 1 M, decade means of annual estimates (1950s ... 2010s; 2010s = 2010-2023)"
anotar("r_cnmr_decades_recent", value = round(bb_r0010$valor, 4), unit = "Pearson r", fmt = "0.00", ic = bb_r0010, ic_iid = bi_r0010,
       def = "Correlation across countries between mean net migration rate in the 2000s and in the 2010s (2010-2023)", filter = F_MEM,
       source_cell = "Q1-8.1", used_in = c("slide2.build4"), status = "exploratory", hypothesis_id = "H4a",
       n = nrow(w_cn), universe = UNIVERSO_1M)
anotar("r_cnmr_decades_min", value = round(min(r_cn), 4), unit = "Pearson r", fmt = "0.00", method = "descriptive",
       def = "Lowest correlation of the net migration rate between consecutive decades (6 pairs)", filter = F_MEM,
       source_cell = "Q1-8.1", used_in = c("slide2.build4"),
       sens_note = paste(sprintf("%ds->%ds %.2f", mm$decada_a[mm$variable == "CNMR"], mm$decada_b[mm$variable == "CNMR"], r_cn), collapse = "; "),
       status = "exploratory", hypothesis_id = "H4a", n = nrow(w_cn), universe = UNIVERSO_1M)
anotar("r_cnmr_decades_max", value = round(max(r_cn), 4), unit = "Pearson r", fmt = "0.00", method = "descriptive",
       def = "Highest correlation of the net migration rate between consecutive decades (6 pairs)", filter = F_MEM,
       source_cell = "Q1-8.1", used_in = c("slide2.build4"), status = "exploratory", hypothesis_id = "H4a",
       n = nrow(w_cn), universe = UNIVERSO_1M)
anotar("r_tfr_decades_min", value = round(min(r_tl), 4), unit = "Pearson r", fmt = "0.00", method = "descriptive",
       def = "Lowest correlation between consecutive decades for fertility (TFR) and life expectancy (6 pairs each)", filter = F_MEM,
       source_cell = "Q1-8.1", used_in = c("slide2.build4"),
       sens_note = sprintf("TFR min %.2f; LEx min %.2f", min(mm$r_pearson[mm$variable == "TFR"]), min(mm$r_pearson[mm$variable == "LEx"])),
       status = "exploratory", hypothesis_id = "H4a", n = nrow(w_cn), universe = UNIVERSO_1M)
anotar("share_cnmr_sign_kept", value = round(w_sig$valor, 4), unit = "%", fmt = "0", ic = w_sig,
       def = "Share of countries whose mean net migration rate has the same sign in the 2000s and the 2010s (2010-2023)", filter = F_MEM,
       source_cell = "Q1-8.1", used_in = c("notebook.T6"), status = "exploratory", hypothesis_id = "H4a", universe = UNIVERSO_1M)
anotar("r_cnmr_1950_2023", value = round(bb_r5023$valor, 4), unit = "Pearson r", fmt = "0.00", ic = bb_r5023,
       def = "Correlation across countries between the net migration rate in 1950 and in 2023 (single years, 73 years apart)",
       filter = "161 countries >= 1 M, estimates 1950 and 2023", source_cell = "Q1-8.1", used_in = c("notebook.T6"),
       sens_note = sprintf("TFR 1950 vs 2023: %.2f; beta(CNMR 1950-54 -> 2019-23) = %.2f vs placebo %.2f [%.2f; %.2f]", r_tfr5023, beta_cn,
                           mean(beta_plac), quantile(beta_plac, 0.025), quantile(beta_plac, 0.975)),
       status = "exploratory", hypothesis_id = "H4", n = nrow(y5023), universe = UNIVERSO_1M)
claves_simp <- c(World = "rho_q5_cnmr_world", "Low income" = "rho_q5_cnmr_within_low", "Lower middle income" = "rho_q5_cnmr_within_lowmid",
                 "Upper middle income" = "rho_q5_cnmr_within_upmid", "High income" = "rho_q5_cnmr_within_high")
for (g in names(claves_simp)) {
  x <- simp |> filter(par == "Q5-CNMR", grupo == g)
  anotar(claves_simp[[g]], value = round(x$rho, 4), unit = "Spearman rho", fmt = "0.00", ic = x$bb[[1]],
         def = sprintf("Spearman correlation across countries between Q5 and the net migration rate (2021-2023 means), %s", ifelse(g == "World", "all countries", paste("within today's", g))),
         filter = sprintf("%s; 2021-2023 means of annual estimates", ifelse(g == "World", "161 countries >= 1 M", paste(g, "countries >= 1 M"))),
         source_cell = "Q1-8.2", used_in = c("notebook.T6"),
         sens_note = if (g == "World") sprintf("partial Spearman given income group: %.2f", rho_parcial) else sprintf("%d UN subregions as blocks", x$n_bloques),
         status = "exploratory", hypothesis_id = "H21", n = x$n, universe = UNIVERSO_1M)
}
fig_mem <- mem |> mutate(par = paste0(decada_a, "s→", decada_b, "s"),
                         variable = recode(variable, CNMR = "Net migration rate", TFR = "Fertility (TFR)", LEx = "Life expectancy"))
p14 <- ggplot(fig_mem |> filter(version == "2010s = 2010-2023"), aes(par, r_pearson, colour = variable, group = variable)) +
  geom_line(linewidth = 1) + geom_point(size = 2.8) +
  geom_text(data = \(d) d |> filter(variable == "Net migration rate"), aes(label = sprintf("%.2f", r_pearson)), vjust = -0.9, size = 3.2, show.legend = FALSE) +
  scale_colour_manual(values = c("Net migration rate" = COLOR_MIGRACION, "Fertility (TFR)" = COLOR_NACIMIENTOS, "Life expectancy" = COLOR_DEFUNCIONES), name = NULL) +
  scale_y_continuous(limits = c(0, 1.05)) +
  labs(x = "Consecutive decades", y = "Correlation across countries (Pearson)",
       title = "Migration has a short memory: decade-to-decade similarity well below fertility and life expectancy",
       subtitle = sprintf("Fertility and life expectancy: >= %.2f in every pair. Same sign of net migration in the 2000s and 2010s: %.0f%% of countries.\n1950 vs 2023 (single years): migration %.2f, fertility %.2f.",
                          min(r_tl), w_sig$valor, bb_r5023$valor, r_tfr5023),
       caption = pie_q1(PIE_MODELOS, badge("PIE-6"), "2010s = 2010–2023 (sensitivity with 2020–2023 apart in the parquet table).")) + tema_q1(12)
guardar_q1(p14, "q1_14_memoria_migracion")
fig_simp <- simp |> mutate(grupo = factor(ifelse(grupo == "World", "World (all 161)", ETIQUETAS_INGRESO_CORTAS_EN[grupo]),
                                          levels = rev(c("World (all 161)", ETIQUETAS_INGRESO_CORTAS_EN[NIVELES_INGRESO]))),
                           par = recode(par, `Q5-CNMR` = "Child mortality vs net migration", `TFR-CNMR` = "Fertility vs net migration"))
p15 <- ggplot(fig_simp, aes(rho, grupo)) + geom_vline(xintercept = 0, colour = COL_GRIS) +
  geom_errorbar(aes(xmin = ci_lo, xmax = ci_hi), width = 0.25, orientation = "y") + geom_point(size = 2.8) +
  geom_text(aes(label = sprintf("%.2f", rho)), vjust = -0.9, size = 3.2) + facet_wrap(~par) +
  labs(x = "Spearman correlation across countries (2021–2023 means)", y = NULL,
       title = "A worldwide correlation can be an income gap in disguise",
       subtitle = sprintf("Child mortality and net migration: %.2f worldwide, near zero inside each income group (partial, given income: %.2f)",
                          simp$rho[simp$par == "Q5-CNMR" & simp$grupo == "World"], rho_parcial),
       caption = pie_q1(badge("PIE-3", "PIE-4"), "Bars: 95% block bootstrap by UN subregion.")) + tema_q1(12)
guardar_q1(p15, "q1_15_simpson_ingreso")

# =============================================================================
# 9. Incertidumbre oficial de la ONU (OtherVariants): EAU y dirección 2050
# =============================================================================
# QUÉ: lee los intervalos de predicción 80/95 % de la ONU (solo columnas de la
#      lista blanca, con test de monotonía) y arma el fan chart de EAU; cuenta
#      en cuántos países el IP 95 % de 2050 incluye crecer y decrecer y en
#      cuántos el IP 80 % de la migración neta 2050 incluye el cero.
# POR QUÉ: la incertidumbre se ve una vez en el vídeo donde más importa: la
#      migración, la palanca peor medida (P2/P3 como nota).
seccion("9. OtherVariants: EAU y dirección 2050")

ov <- data.table::fread(RUTA_WPP_OTHERVARIANTS, select = c("LocID", "ISO3_code", "Variant", "Time", "TPopulation1July", "CNMR"),
                        na.strings = "", encoding = "UTF-8", showProgress = FALSE) |> as.data.frame()
stopifnot(all(c("TPopulation1July", "CNMR") %in% COLUMNAS_PI_VALIDAS))   # solo columnas de la lista blanca
ov <- ov |> filter(!is.na(ISO3_code), ISO3_code != "", Time <= ANIO_MAX_VALIDO)   # 2101 se descarta (plan §3)
VAR_PI <- c("Lower 95 PI" = "l95", "Lower 80 PI" = "l80", "Median PI" = "mediana", "Upper 80 PI" = "u80", "Upper 95 PI" = "u95")
pi_w <- ov |> filter(Variant %in% names(VAR_PI)) |> mutate(v = VAR_PI[Variant]) |>
  select(ISO3_code, Time, v, TPopulation1July, CNMR) |>
  pivot_wider(names_from = v, values_from = c(TPopulation1July, CNMR))
mono <- function(p) {
  cc <- function(s) pi_w[[paste0(p, "_", s)]]
  cc("l95") <= cc("l80") + 1e-9 & cc("l80") <= cc("mediana") + 1e-9 & cc("mediana") <= cc("u80") + 1e-9 & cc("u80") <= cc("u95") + 1e-9
}
mono_pop <- mono("TPopulation1July"); mono_cn <- mono("CNMR")
informar("Monotonía L95 <= L80 <= Mediana <= U80 <= U95: población %d/%d filas, CNMR %d/%d filas (países, %d-%d)",
         sum(mono_pop, na.rm = TRUE), sum(!is.na(mono_pop)), sum(mono_cn, na.rm = TRUE), sum(!is.na(mono_cn)), min(pi_w$Time), max(pi_w$Time))
stopifnot(all(mono_pop, na.rm = TRUE), all(mono_cn, na.rm = TRUE))
med_are <- datos_paises |> filter(ISO3_code == "ARE") |> select(Time, TPopulation1July, CNMR, TFR, PopGrowthRate)
pi_are <- pi_w |> filter(ISO3_code == "ARE")
zm_are <- ov |> filter(ISO3_code == "ARE", Variant == "Zero migration") |> select(Time, zm = TPopulation1July)
are50 <- pi_are |> filter(Time == 2050); are2100 <- pi_are |> filter(Time == 2100)
m50 <- med_are$TPopulation1July[med_are$Time == 2050] / 1e3; m2100 <- med_are$TPopulation1July[med_are$Time == 2100] / 1e3
dif_med <- max(abs(pi_are$TPopulation1July_mediana - med_are$TPopulation1July[match(pi_are$Time, med_are$Time)]) /
                 med_are$TPopulation1July[match(pi_are$Time, med_are$Time)], na.rm = TRUE)
informar("EAU 2050: Medium %.2f M; IP 80 [%.2f; %.2f]; IP 95 [%.2f; %.2f]; migración cero %.2f M | 2100: %.2f M [IP 95 %.2f; %.2f] | dif. máx. Median PI vs Medium %.2e",
         m50, are50$TPopulation1July_l80 / 1e3, are50$TPopulation1July_u80 / 1e3, are50$TPopulation1July_l95 / 1e3, are50$TPopulation1July_u95 / 1e3,
         zm_are$zm[zm_are$Time == 2050] / 1e3, m2100, are2100$TPopulation1July_l95 / 1e3, are2100$TPopulation1July_u95 / 1e3, dif_med)
are23 <- med_are |> filter(Time == 2023)
# Dirección 2050 en los 161 países >= 1 M
dir50 <- pi_w |> filter(Time == 2050, ISO3_code %in% iso_muestra_1m) |>
  left_join(pop23, by = "ISO3_code") |>
  left_join(c23 |> select(ISO3_code, Location), by = "ISO3_code") |>
  transmute(ISO3_code, Location, pop2023 = pop_2023_miles, l95 = TPopulation1July_l95, l80 = TPopulation1July_l80,
            mediana = TPopulation1July_mediana, u80 = TPopulation1July_u80, u95 = TPopulation1July_u95,
            dir95 = case_when(l95 > pop2023 ~ "surely up", u95 < pop2023 ~ "surely down", TRUE ~ "uncertain"),
            dir80 = case_when(l80 > pop2023 ~ "surely up", u80 < pop2023 ~ "surely down", TRUE ~ "uncertain"),
            cnmr_l80 = CNMR_l80, cnmr_u80 = CNMR_u80, cnmr_l95 = CNMR_l95, cnmr_u95 = CNMR_u95,
            signo_cnmr_incierto = cnmr_l80 < 0 & cnmr_u80 > 0)
stopifnot(nrow(dir50) == N_PAISES_1M)
n_unc95 <- sum(dir50$dir95 == "uncertain"); n_unc80 <- sum(dir50$dir80 == "uncertain")
n_sign80 <- sum(dir50$signo_cnmr_incierto); n_sign95 <- sum(dir50$cnmr_l95 < 0 & dir50$cnmr_u95 > 0)
informar("Dirección 2050 (IP 95): %s | (IP 80): %s | signo de la CNMR 2050 incierto: IP 80 %d, IP 95 %d de %d",
         paste(names(table(dir50$dir95)), table(dir50$dir95), collapse = ", "), paste(names(table(dir50$dir80)), table(dir50$dir80), collapse = ", "),
         n_sign80, n_sign95, nrow(dir50))
F_PI <- "WPP 2024 OtherVariants (Median / Lower / Upper 80 and 95 PI); UN medium projection"
anotar("pop_are_2050", value = round(m50, 4), unit = "million", fmt = "0.0", method = "un_pi",
       def = "United Arab Emirates population on 1 July 2050, UN medium projection", filter = "United Arab Emirates, 2050 (UN medium projection)",
       source_cell = "Q1-9.1", used_in = c("slide1.build5", "narration.slide1"),
       pi80_low = round(are50$TPopulation1July_l80 / 1e3, 3), pi80_high = round(are50$TPopulation1July_u80 / 1e3, 3),
       pi95_low = round(are50$TPopulation1July_l95 / 1e3, 3), pi95_high = round(are50$TPopulation1July_u95 / 1e3, 3),
       variant_source = F_PI, sens_note = sprintf("Zero-migration scenario (not an interval): %.1f M", zm_are$zm[zm_are$Time == 2050] / 1e3),
       status = "descriptive", n = 1, universe = "United Arab Emirates")
anotar("pop_are_2050_pi95_low", value = round(are50$TPopulation1July_l95 / 1e3, 4), unit = "million", fmt = "0.0", method = "un_pi",
       def = "Lower limit of the UN 95% prediction interval of the UAE population in 2050", filter = "United Arab Emirates, 2050",
       source_cell = "Q1-9.1", used_in = c("slide1.build5", "narration.slide1"), variant_source = F_PI, status = "descriptive",
       say = "nine", n = 1, universe = "United Arab Emirates")
anotar("pop_are_2050_pi95_high", value = round(are50$TPopulation1July_u95 / 1e3, 4), unit = "million", fmt = "0.0", method = "un_pi",
       def = "Upper limit of the UN 95% prediction interval of the UAE population in 2050", filter = "United Arab Emirates, 2050",
       source_cell = "Q1-9.1", used_in = c("slide1.build5", "narration.slide1"), variant_source = F_PI, status = "descriptive",
       say = "thirty-three", n = 1, universe = "United Arab Emirates")
# Variante "Zero migration" (QA_storyboard §6.8): escenario de la ONU, no un intervalo
anotar("pop_are_2050_zero_mig", value = round(zm_are$zm[zm_are$Time == 2050] / 1e3, 4), unit = "million", fmt = "0.0",
       method = "descriptive",
       def = "United Arab Emirates population on 1 July 2050 in the UN 'Zero migration' variant (a what-if scenario with net migration set to zero from 2024; not a prediction interval)",
       filter = "United Arab Emirates, 2050 (WPP 2024 OtherVariants, Variant = 'Zero migration', TPopulation1July)", source_cell = "Q1-9.1",
       used_in = c("slide1.build5"), variant_source = "WPP 2024 OtherVariants (Zero migration)", status = "descriptive",
       sens_note = sprintf("2100: %.1f M; UN medium 2050: %.1f M", zm_are$zm[zm_are$Time == 2100] / 1e3, m50),
       n = 1, universe = "United Arab Emirates")
anotar("pop_are_2100", value = round(m2100, 4), unit = "million", fmt = "0.0", method = "un_pi",
       def = "United Arab Emirates population in 2100, UN medium projection", filter = "United Arab Emirates, 2100 (UN medium projection)",
       source_cell = "Q1-9.1", used_in = c("notebook.T13"),
       pi80_low = round(are2100$TPopulation1July_l80 / 1e3, 3), pi80_high = round(are2100$TPopulation1July_u80 / 1e3, 3),
       pi95_low = round(are2100$TPopulation1July_l95 / 1e3, 3), pi95_high = round(are2100$TPopulation1July_u95 / 1e3, 3),
       variant_source = F_PI, sens_note = sprintf("Zero-migration scenario: %.1f M", zm_are$zm[zm_are$Time == 2100] / 1e3),
       status = "descriptive", n = 1, universe = "United Arab Emirates")
anotar("cnmr_are_2023", value = round(are23$CNMR, 4), unit = "per 1,000", fmt = "0.0", method = "descriptive",
       def = "UAE net migration rate, 2023 (estimate)", filter = "United Arab Emirates, 2023", source_cell = "Q1-9.1",
       used_in = c("slide1.build5"), status = "descriptive", n = 1, universe = "United Arab Emirates")
anotar("growth_are_2023", value = round(are23$PopGrowthRate, 4), unit = "% per year", fmt = "0.00", method = "descriptive",
       def = "UAE population growth rate, 2023 (estimate)", filter = "United Arab Emirates, 2023", source_cell = "Q1-9.1",
       used_in = c("slide1.build5"), status = "descriptive", n = 1, universe = "United Arab Emirates")
anotar("tfr_are_2023", value = round(are23$TFR, 4), unit = "children per woman", fmt = "0.00", method = "descriptive",
       def = "UAE total fertility rate, 2023 (estimate)", filter = "United Arab Emirates, 2023", source_cell = "Q1-9.1",
       used_in = c("slide1.build5"), status = "descriptive", n = 1, universe = "United Arab Emirates")
# Revisión WPP2022 -> WPP2024 de la población de EAU: dato EXTERNO (no está en los archivos de 2024)
# QUÉ: deja en el registro la cifra de calidad de datos que usa la tarjeta de ética.
# POR QUÉ: la nota "UN revised the UAE's 2023 population by +12 %" no puede
#      calcularse sin el archivo WPP2022 (no descargado); se marca como externa
#      y pendiente de verificación humana, en lugar de teclearla en la diapositiva.
anotar("are_revision_pct", value = 12, unit = "%", fmt = "0", method = "descriptive",
       def = "Revision of the UAE's 2023 population between the 2022 and 2024 UN WPP editions (EXTERNAL figure: not computable from the WPP 2024 files used here)",
       filter = "United Arab Emirates, 2023; WPP2022 vs WPP2024", source_cell = "Q1-9.1 (external)",
       used_in = c("slide1.build5", "slide4.ethics"), status = "descriptive",
       sens_note = "EXTERNAL: taken from docs/04_etica_ASA_aplicada.md item 3 / 07_integracion V11 (UN DESA WPP2024 methodology: Gulf revisions UAE +12%, Kuwait +12%, Qatar +9.7%, Oman +8.7%, Saudi Arabia -10%); must be checked by a person against the WPP2022 file before use",
       n = 1, universe = "United Arab Emirates")
anotar("n_dir_uncertain_2050", value = n_unc95, unit = "countries", fmt = "0", method = "none_census",
       def = "Countries whose UN 95% prediction interval for the 2050 population includes the 2023 population (both growth and decline possible)",
       filter = "161 countries >= 1 M; 2023 estimate vs 2050 UN PI", source_cell = "Q1-9.2", used_in = c("slide1.build5"),
       sens_low = n_unc80, sens_high = n_unc95,
       sens_note = sprintf("80%% PI: %d; 95%% PI: surely down %d, surely up %d", n_unc80, sum(dir50$dir95 == "surely down"), sum(dir50$dir95 == "surely up")),
       variant_source = F_PI, status = "exploratory", hypothesis_id = "H22", n = N_PAISES_1M, universe = UNIVERSO_1M)
anotar("n_cnmr_sign_uncertain_2050", value = n_sign80, unit = "countries", fmt = "0", method = "none_census",
       def = "Countries whose UN 80% prediction interval for the 2050 net migration rate includes zero (sign unknown)",
       filter = "161 countries >= 1 M; 2050 UN PI", source_cell = "Q1-9.2", used_in = c("slide4.table"),
       sens_note = sprintf("95%% PI includes zero in %d", n_sign95), variant_source = F_PI, status = "descriptive",
       n = N_PAISES_1M, universe = UNIVERSO_1M)
fan <- bind_rows(med_are |> filter(Time <= 2023) |> transmute(Time, serie = "Estimate", pop_millones = TPopulation1July / 1e3),
                 med_are |> filter(Time >= 2023) |> transmute(Time, serie = "UN medium projection", pop_millones = TPopulation1July / 1e3),
                 pi_are |> select(Time, starts_with("TPopulation1July_")) |> pivot_longer(-Time, names_to = "serie", values_to = "pop_millones") |>
                   mutate(serie = sub("TPopulation1July_", "PI ", serie), pop_millones = pop_millones / 1e3),
                 zm_are |> transmute(Time, serie = "Zero migration scenario", pop_millones = zm / 1e3))
fan_w <- pi_are |> mutate(across(starts_with("TPopulation1July_"), \(x) x / 1e3))
p16 <- ggplot() +
  annotate("rect", xmin = 2023.5, xmax = 2100, ymin = -Inf, ymax = Inf, fill = COLOR_PROYECCION_SOMBRA) +
  geom_ribbon(data = fan_w, aes(Time, ymin = TPopulation1July_l95, ymax = TPopulation1July_u95), fill = COLOR_MIGRACION, alpha = 0.25) +
  geom_ribbon(data = fan_w, aes(Time, ymin = TPopulation1July_l80, ymax = TPopulation1July_u80), fill = COLOR_MIGRACION, alpha = 0.45) +
  geom_line(data = fan |> filter(serie == "UN medium projection"), aes(Time, pop_millones), colour = COLOR_NACIMIENTOS, linewidth = 1.1) +
  geom_line(data = fan |> filter(serie == "Zero migration scenario"), aes(Time, pop_millones), colour = COLOR_DEFUNCIONES, linetype = "dashed", linewidth = 0.9) +
  geom_line(data = fan |> filter(serie == "Estimate"), aes(Time, pop_millones), colour = "black", linewidth = 1.1) +
  geom_vline(xintercept = 2023.5, linetype = "dotted") +
  annotate("point", x = 2050, y = m50, size = 3) +
  annotate("text", x = 2050, y = are50$TPopulation1July_u95 / 1e3, label = sprintf("2050: %.1f M\nUN 95%% range %.1f–%.1f M", m50, are50$TPopulation1July_l95 / 1e3, are50$TPopulation1July_u95 / 1e3),
           vjust = -0.3, size = 3.6) +
  annotate("text", x = 2088, y = zm_are$zm[zm_are$Time == 2090] / 1e3, label = "UN zero-migration scenario\n(a what-if, not a forecast)", colour = COLOR_DEFUNCIONES, vjust = -0.5, size = 3.3) +
  labs(x = NULL, y = "Population (million)",
       title = sprintf("Migration is the least certain lever: the UN's 95%% range for the UAE in 2050 runs from %.0f to %.0f million", are50$TPopulation1July_l95 / 1e3, are50$TPopulation1July_u95 / 1e3),
       subtitle = "Black: UN estimates 1950–2023. Blue: UN medium projection with 80% and 95% prediction intervals (shaded: projection, a scenario).",
       caption = pie_q1(badge("PIE-5", "PIE-6"), "Prediction intervals are marginal and not additive across countries.")) + tema_q1(12)
guardar_q1(p16, "q1_16_fan_eau")

# =============================================================================
# 10. Europa y decrecimiento natural (H2, H14, H14a)
# =============================================================================
# QUÉ: fecha el primer año de decrecimiento natural sostenido de Europa
#      (agregado ONU) y cuenta los países con más defunciones que nacimientos.
# POR QUÉ: son hipótesis preinscritas de P7 que se reportan sean cuales sean
#      sus resultados (las fechas futuras son proyección, no hallazgo).
seccion("10. Europa y decrecimiento natural")

agr_geo <- datos_agregados |> filter(LocTypeName == "Geographic region")
primer_sostenido <- function(t, x, hasta = 2023) {
  ok <- t <= hasta; t <- t[ok]; x <- x[ok]
  if (!length(t) || x[length(x)] >= 0) return(NA_real_)
  if (!any(x >= 0)) return(t[1])
  t[max(which(x >= 0)) + 1]
}
eu <- agr_geo |> filter(Location == "Europe") |> arrange(Time)
stopifnot(n_distinct(eu$LocID) == 1)
anio_eu <- primer_sostenido(eu$Time, eu$NatChange)
anio_eu_primero <- min(eu$Time[eu$NatChange < 0 & eu$Time <= 2023])
eu_pos <- eu$Time[eu$Time > anio_eu_primero & eu$Time <= 2023 & eu$NatChange >= 0]
informar("Europa: primer año con NatChange < 0 = %d; años posteriores con NatChange >= 0: %s", anio_eu_primero, paste(eu_pos, collapse = ", "))
eu_0023 <- eu |> filter(Time %in% 2000:2023)
informar("Europa (agregado ONU): NatChange < 0 cada año desde %s hasta 2023; 2000-23: saldo natural %.0f mil, cambio total %.0f mil (migración = %.0f %% del cambio)",
         anio_eu, sum(eu_0023$NatChange), sum(eu_0023$PopChange), 100 * sum(eu_0023$NetMigrations) / sum(eu_0023$PopChange))
h14 <- agr_geo |> filter(Location %in% c("Europe", "Northern America", "Asia", "Latin America and the Caribbean", "Africa", "Oceania")) |>
  group_by(Location) |> arrange(Time) |>
  summarise(primer_anio_natneg = if (any(NatChange < 0)) min(Time[NatChange < 0]) else NA_real_,
            sostenido_hasta_2100 = primer_sostenido(Time, NatChange, 2100)) |>
  mutate(periodo = ifelse(is.na(primer_anio_natneg), "not before 2100 (UN medium projection)", etiqueta_periodo(primer_anio_natneg)))
print(h14)
natneg <- datos_paises |> filter(Time %in% c(1990, 2023, 2050)) |> group_by(Time) |>
  summarise(n = sum(NatChange < 0), pop_share = 100 * sum(TPopulation1July[NatChange < 0]) / sum(TPopulation1July))
print(natneg)
anotar("year_europe_natneg", value = anio_eu, unit = "year", fmt = "0", method = "descriptive",
       def = "First year from which the UN 'Europe' aggregate has had more deaths than births in every year up to 2023",
       filter = "UN geographic aggregate 'Europe', estimates 1950-2023", source_cell = "Q1-10.1", used_in = c("notebook.T15"),
       sens_note = sprintf("first year with NatChange < 0: %d; later years with NatChange >= 0: %s; 2000-2023: natural change %.0f thousand, population change %.0f thousand", anio_eu_primero, paste(eu_pos, collapse = ", "), sum(eu_0023$NatChange), sum(eu_0023$PopChange)),
       status = "pre-specified", hypothesis_id = "H2", n = 1L, universe = "UN 'Europe' aggregate (1 aggregate)")

# =============================================================================
# 10b. Apéndice del notebook: Shapley por ingreso, misma fecundidad, tipo E
#      histórico y GAM por ingreso (plan §4-Q1, fila "Solo notebook")
# =============================================================================
# QUÉ: (a) reparte las diferencias de crecimiento entre países en natalidad,
#      mortalidad y migración (Shapley/LMG, sin depender del orden) por grupo
#      de ingreso; (b) con la MISMA fecundidad (1,5-1,99) mide el rango del
#      saldo natural y su relación con la edad mediana; (c) busca países >= 1 M
#      que decrecieron con más nacimientos que defunciones y TFR >= 3 en
#      1950-2023; (d) GAM de la TFR sobre log Q5 con una curva por ingreso.
# POR QUÉ: son las piezas del apéndice que dan contexto a P7 (palancas por
#      ingreso, edad como palanca oculta, emigración no es "de países pobres")
#      sin entrar en el vídeo. Todo es descriptivo.
seccion("10b. Apéndice: Shapley, misma fecundidad, tipo E histórico, GAM")

# (a) Shapley (LMG) del R² de PopGrowthRate ~ CBR + CDR + CNMR, por grupo de ingreso
shapley3 <- function(d, y = "PopGrowthRate", xs = c("CBR", "CDR", "CNMR")) {
  r2 <- function(v) if (!length(v)) 0 else summary(stats::lm(stats::reformulate(v, y), d))$r.squared
  clave_sub <- function(v) if (!length(v)) "(none)" else paste(sort(v), collapse = "+")
  subs <- c(list(character(0)), unlist(lapply(seq_along(xs), function(k) utils::combn(xs, k, simplify = FALSE)), recursive = FALSE))
  R2 <- setNames(vapply(subs, r2, numeric(1)), vapply(subs, clave_sub, ""))
  p <- length(xs)
  sh <- vapply(xs, function(x) {
    otros <- subs[!vapply(subs, function(s) x %in% s, logical(1))]
    sum(vapply(otros, function(s) {
      w <- factorial(length(s)) * factorial(p - length(s) - 1) / factorial(p)
      w * (R2[[clave_sub(c(s, x))]] - R2[[clave_sub(s)]])
    }, numeric(1)))
  }, numeric(1))
  sh / sum(sh)
}
c23_1m <- corte_anio(2023, "1m", vars = c("PopGrowthRate", "CBR", "CDR", "CNMR"))
v2123_s <- resumen_ventana(2021:2023, c("PopGrowthRate", "CBR", "CDR", "CNMR"), muestra = "1m")
shap <- bind_rows(lapply(c("World", NIVELES_INGRESO), function(g) {
  sel <- function(d) if (g == "World") d else d |> filter(ingreso == g)
  bind_rows(tibble(grupo = g, ventana = "2023", n = nrow(sel(c23_1m)), componente = c("CBR", "CDR", "CNMR"), share = shapley3(sel(c23_1m))),
            tibble(grupo = g, ventana = "2021-2023", n = nrow(sel(v2123_s)), componente = c("CBR", "CDR", "CNMR"), share = shapley3(sel(v2123_s))))
}))
low_sin <- c23_1m |> filter(ingreso == "Low income", !ISO3_code %in% c("SSD", "SYR", "SDN"))
shap <- bind_rows(shap, tibble(grupo = "Low income without SSD, SYR, SDN", ventana = "2023", n = nrow(low_sin),
                               componente = c("CBR", "CDR", "CNMR"), share = shapley3(low_sin)))
print(shap |> select(-n) |> pivot_wider(names_from = componente, values_from = share) |> mutate(across(where(is.numeric), \(x) round(x, 2))))
hi_c23 <- c23_1m |> filter(ingreso == "High income")
bb_shap_hi <- bootstrap_bloques(hi_c23, function(d) shapley3(d)[["CNMR"]], B = B_NB, semilla = SEM)
sh_mig <- shap |> filter(componente == "CNMR", ventana == "2023", grupo %in% NIVELES_INGRESO)
anotar("shapley_mig_high_2023", value = round(bb_shap_hi$valor, 4), unit = "share of R2", fmt = "0.00", ic = bb_shap_hi,
       def = "Shapley (LMG) share of the cross-country variance of the 2023 growth rate attributed to net migration (CNMR), with CBR and CDR as the other components, today's high-income countries",
       filter = "High-income (FY2027) countries >= 1 M, 2023 (estimate)", source_cell = "Q1-10b.1", used_in = c("notebook.T5"),
       sens_note = sprintf("2021-2023 means: %.2f; by income group 2023: %s; low income without SSD, SYR, SDN: %.2f (fragile)",
                           shap$share[shap$grupo == "High income" & shap$ventana == "2021-2023" & shap$componente == "CNMR"],
                           paste(sprintf("%s %.2f", ETIQUETAS_INGRESO_CORTAS_EN[sh_mig$grupo], sh_mig$share), collapse = "; "),
                           shap$share[shap$grupo == "Low income without SSD, SYR, SDN" & shap$componente == "CNMR"]),
       status = "exploratory", n = nrow(hi_c23), universe = UNIVERSO_1M)
anotar("shapley_mig_by_income_2023", value = setNames(round(sh_mig$share, 4), ETIQUETAS_INGRESO_CORTAS_EN[sh_mig$grupo]),
       unit = "share of R2", fmt = "0.00", method = "descriptive",
       def = "Shapley (LMG) share of cross-country growth differences attributed to net migration, by today's income group, 2023",
       filter = "161 countries >= 1 M with an income group, 2023 (estimate)", source_cell = "Q1-10b.1", used_in = c("notebook.T5"),
       sens_note = sprintf("world: %.2f; identity: growth = (CBR - CDR + CNMR)/10, so the three shares add to 1",
                           shap$share[shap$grupo == "World" & shap$ventana == "2023" & shap$componente == "CNMR"]),
       status = "exploratory", n = sum(c23_1m$ingreso != "Not classified"), universe = UNIVERSO_1M)

# (b) Misma fecundidad (TFR 1,5-1,99, >= 1 M, 2023): el saldo natural sigue a la edad mediana
banda <- corte_anio(2023, "1m", vars = c("TFR", "NatChangeRT", "MedianAgePop", "CNMR", "PopGrowthRate")) |>
  filter(TFR >= 1.5, TFR < 2)
r_band <- cor(banda$NatChangeRT, banda$MedianAgePop)
r_band_tfr <- cor(banda$NatChangeRT, banda$TFR)
informar("Misma fecundidad (1,5-1,99): %d países; saldo natural %.1f a %.1f por mil (%s a %s); r con edad mediana %.2f, con TFR %.2f",
         nrow(banda), min(banda$NatChangeRT), max(banda$NatChangeRT), banda$ISO3_code[which.min(banda$NatChangeRT)],
         banda$ISO3_code[which.max(banda$NatChangeRT)], r_band, r_band_tfr)
# Las claves n_band_tfr, nat_min_band, nat_max_band y r_nat_medage_band las
# registra Q2 (R/03_q2_un_numero.R, "misma fecundidad"). Q1 NO las registra para
# no duplicar claves al combinar numbers_q*.json; aquí solo se recalcula como
# comprobación cruzada (la tabla queda en resultados_q1_misma_fecundidad.parquet).
bb_band <- bootstrap_bloques(banda, function(d) cor(d$NatChangeRT, d$MedianAgePop), B = B_NB, semilla = SEM)
informar("  comprobación cruzada con Q2 (claves n_band_tfr, nat_min_band, nat_max_band, r_nat_medage_band): n = %d; %.1f a %.1f por mil; r = %.2f [bloques %.2f; %.2f]",
         nrow(banda), min(banda$NatChangeRT), max(banda$NatChangeRT), r_band, bb_band$ci_low, bb_band$ci_high)

# (c) Tipo E histórico con TFR >= 3 (>= 1 M, 1950-2023): la emigración no es "de países pobres"
e_hist <- est1m |> filter(NatChange > 0, PopChange < 0, TFR >= 3)
rachas <- e_hist |> arrange(ISO3_code, Time) |> group_by(ISO3_code, Location) |>
  mutate(racha = cumsum(c(1, diff(Time) != 1))) |> group_by(ISO3_code, Location, racha) |>
  summarise(desde = min(Time), hasta = max(Time), anios = n(), tfr_media = mean(TFR), .groups = "drop") |>
  arrange(desc(anios))
informar("Tipo E con TFR >= 3 (>= 1 M, 1950-2023): %d países, %d país-años; rachas más largas: %s",
         n_distinct(e_hist$ISO3_code), nrow(e_hist),
         paste(head(sprintf("%s %d-%d (TFR %.1f)", rachas$ISO3_code, rachas$desde, rachas$hasta, rachas$tfr_media), 8), collapse = "; "))
r_ip <- rachas |> filter(ISO3_code %in% c("IRL", "PRT")) |> group_by(ISO3_code) |> slice_max(anios, n = 1, with_ties = FALSE)
anotar("n_hist_typeE_tfr3", value = n_distinct(e_hist$ISO3_code), unit = "countries", fmt = "0", method = "none_census",
       def = "Countries >= 1 M with at least one year 1950-2023 of population decline although births exceeded deaths, while TFR >= 3",
       filter = "161 countries >= 1 M, annual estimates 1950-2023", source_cell = "Q1-10b.3", used_in = c("notebook.T2"),
       sens_note = sprintf("%d country-years; Ireland and Portugal: %s", nrow(e_hist),
                           paste(sprintf("%s %d-%d (TFR %.1f)", r_ip$ISO3_code, r_ip$desde, r_ip$hasta, r_ip$tfr_media), collapse = "; ")),
       status = "exploratory", n = N_PAISES_1M, universe = UNIVERSO_1M)

# (d) GAM: TFR ~ s(log Q5) por ingreso + efecto aleatorio de país, errores AR(1)
gam_d <- est1m |> filter(ingreso != "Not classified") |>
  mutate(ingreso = droplevels(ingreso), pais = factor(ISO3_code), lq5 = log(Q5)) |> arrange(pais, Time) |>
  group_by(pais) |> mutate(inicio = Time == min(Time)) |> ungroup()
g0 <- mgcv::bam(TFR ~ ingreso + s(lq5, by = ingreso, k = 10) + s(pais, bs = "re"), data = gam_d, discrete = TRUE)
rho_ar <- stats::acf(stats::residuals(g0), plot = FALSE, lag.max = 1)$acf[2]
g1 <- mgcv::bam(TFR ~ ingreso + s(lq5, by = ingreso, k = 10) + s(pais, bs = "re"), data = gam_d, discrete = TRUE,
                rho = rho_ar, AR.start = gam_d$inicio)
g_comun <- mgcv::bam(TFR ~ ingreso + s(lq5, k = 10) + s(pais, bs = "re"), data = gam_d, discrete = TRUE,
                     rho = rho_ar, AR.start = gam_d$inicio)
rango_q5 <- gam_d |> group_by(ingreso) |> summarise(q5_min = min(Q5), q5_max = max(Q5))
pred_gam <- expand.grid(ingreso = levels(gam_d$ingreso), Q5 = c(200, 100, 50, 25), stringsAsFactors = FALSE) |>
  mutate(ingreso = factor(ingreso, levels = levels(gam_d$ingreso)), lq5 = log(Q5), pais = gam_d$pais[1]) |>
  left_join(rango_q5, by = "ingreso")
pred_gam$tfr <- as.numeric(predict(g1, newdata = pred_gam, exclude = "s(pais)"))
pred_gam <- pred_gam |> mutate(dentro_rango = Q5 >= q5_min & Q5 <= q5_max) |> select(-pais)
print(pred_gam |> select(ingreso, Q5, tfr, dentro_rango) |> mutate(tfr = round(tfr, 2)))
aic_gam <- c(por_ingreso = AIC(g1), comun = AIC(g_comun))
informar("GAM (rho AR1 = %.3f): a Q5 = 100, TFR esperada bajo %.2f vs alto %.2f; AIC por ingreso %.0f vs curva común %.0f",
         rho_ar, pred_gam$tfr[pred_gam$Q5 == 100 & pred_gam$ingreso == "Low income"],
         pred_gam$tfr[pred_gam$Q5 == 100 & pred_gam$ingreso == "High income"], aic_gam[1], aic_gam[2])
for (g in c("Low income", "High income")) {
  x <- pred_gam |> filter(Q5 == 100, ingreso == g)
  anotar(if (g == "Low income") "gam_tfr_q5_100_low" else "gam_tfr_q5_100_high", value = round(x$tfr, 4),
         unit = "children per woman", fmt = "0.0", method = "descriptive",
         def = sprintf("Expected TFR at under-five mortality 100 per 1,000 for a typical %s country (GAM TFR ~ s(log Q5) by income + country random effect, AR(1) errors; country effect excluded)", g),
         filter = "160 countries >= 1 M with an income group, annual estimates 1950-2023", source_cell = "Q1-10b.4",
         used_in = c("notebook.T5"),
         sens_note = sprintf("AR(1) rho = %.3f; AIC with one curve per income group %.0f vs common curve %.0f; Q5 = 100 inside the observed range of the group: %s; mixes eras (high income at Q5 = 100 in the 1950s, low income in the 2010s)",
                             rho_ar, aic_gam[1], aic_gam[2], ifelse(x$dentro_rango, "yes", "no")),
         status = "exploratory", n = n_distinct(gam_d$ISO3_code), universe = UNIVERSO_1M)
}

# (e) Figuras de revisión del apéndice: Europa y países con más defunciones que
#     nacimientos (H2, H14a); misma fecundidad y Shapley por ingreso.
# QUÉ: muestra en qué años el agregado "Europe" tuvo saldo natural negativo
#      (estimación hasta 2023, proyección después, separadas) y cuántos países
#      tienen NatChange < 0 cada año; y, con la MISMA fecundidad, cómo el saldo
#      natural sigue a la edad mediana.
# POR QUÉ: H2 se rechaza por el detalle de 2008-2014 y eso debe verse; las dos
#      piezas del apéndice necesitan una gráfica rápida para revisión.
eu_fig <- eu |> filter(Time <= ANIO_MAX_VALIDO) |>
  mutate(periodo = ifelse(Time <= ANIO_FIN_ESTIMACION, "Estimate", "UN medium projection"),
         signo = ifelse(NatChange < 0, "Deaths > births", "Births > deaths"))
p17a <- ggplot(eu_fig, aes(Time, NatChange / 1e3)) +
  annotate("rect", xmin = ANIO_INICIO_PROYECCION - 0.5, xmax = ANIO_MAX_VALIDO + 0.5, ymin = -Inf, ymax = Inf, fill = COLOR_PROYECCION_SOMBRA) +
  geom_col(aes(fill = signo, alpha = periodo), width = 0.9) + geom_hline(yintercept = 0) +
  geom_vline(xintercept = c(anio_eu_primero, anio_eu) - 0.5, linetype = "dashed", colour = COL_GRIS) +
  annotate("text", x = anio_eu_primero - 1, y = max(eu_fig$NatChange / 1e3), hjust = 1, vjust = 1, size = 3.3,
           label = sprintf("first natural decrease: %d", anio_eu_primero)) +
  annotate("text", x = anio_eu + 1, y = max(eu_fig$NatChange / 1e3), hjust = 0, vjust = 1, size = 3.3,
           label = sprintf("every year since %d\n(births > deaths again in %d-%d)", anio_eu, min(eu_pos), max(eu_pos))) +
  scale_fill_manual(values = c("Births > deaths" = COLOR_NACIMIENTOS, "Deaths > births" = COLOR_DEFUNCIONES), name = NULL) +
  scale_alpha_manual(values = c(Estimate = 1, `UN medium projection` = 0.4), name = NULL) +
  labs(x = NULL, y = "Natural change (million per year)",
       title = sprintf("A · UN 'Europe' aggregate: more deaths than births every year only since %d, not since %d (H2)", anio_eu, anio_eu_primero),
       subtitle = sprintf("2000–2023: natural change %.1f M, population change %+.1f M — growth only through net migration (estimates)",
                          sum(eu_0023$NatChange) / 1e3, sum(eu_0023$PopChange) / 1e3)) + tema_q1(11)
natneg_serie <- datos_paises |> group_by(Time) |> summarise(n = sum(NatChange < 0), .groups = "drop") |>
  mutate(periodo = ifelse(Time <= ANIO_FIN_ESTIMACION, "Estimate", "UN medium projection"))
p17b <- ggplot(natneg_serie, aes(Time, n)) +
  annotate("rect", xmin = ANIO_INICIO_PROYECCION - 0.5, xmax = ANIO_MAX_VALIDO + 0.5, ymin = -Inf, ymax = Inf, fill = COLOR_PROYECCION_SOMBRA) +
  geom_line(data = natneg_serie |> filter(periodo == "Estimate"), colour = COLOR_DEFUNCIONES, linewidth = 1.1) +
  geom_line(data = natneg_serie |> filter(periodo != "Estimate"), colour = COLOR_PROYECCION, linewidth = 1.1, linetype = "22") +
  geom_point(data = natneg_serie |> filter(Time %in% c(1990, 2023, 2050)), size = 2.6) +
  geom_text(data = natneg_serie |> filter(Time %in% c(1990, 2023, 2050)), aes(label = n), vjust = -0.9, size = 3.6) +
  labs(x = NULL, y = "Countries and areas (of 237)",
       title = sprintf("B · Countries and areas with more deaths than births: %d (1990) -> %d (2023) -> %d (2050, UN medium projection)",
                       natneg$n[natneg$Time == 1990], natneg$n[natneg$Time == 2023], natneg$n[natneg$Time == 2050])) + tema_q1(11)
p17 <- (p17a / p17b) + plot_annotation(caption = pie_q1(badge("PIE-1"), "Shaded: UN medium projection (a scenario), never pooled with the estimates."))
guardar_q1(p17, "q1_17_europa_decrecimiento_natural")

p18a <- ggplot(banda, aes(MedianAgePop, NatChangeRT)) +
  geom_hline(yintercept = 0, colour = COL_GRIS) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE, colour = COL_GRIS, linewidth = 0.6) +
  geom_point(aes(colour = TFR), size = 2.6) + ggrepel::geom_text_repel(aes(label = ISO3_code), size = 2.8, max.overlaps = 30, seed = SEM) +
  scale_colour_viridis_c(option = "cividis", name = "TFR") +
  labs(x = "Median age (years), 2023", y = "Natural change (per 1,000), 2023",
       title = sprintf("A · Same fertility (TFR 1.5–1.99, %d countries):\nnatural change from %.1f to %+.1f per 1,000", nrow(banda), min(banda$NatChangeRT), max(banda$NatChangeRT)),
       subtitle = sprintf("It follows the age structure: r = %.2f with median age,\nr = %.2f with TFR inside the band", r_band, r_band_tfr)) + tema_q1(11)
fig_shap <- shap |> filter(ventana == "2023", grupo %in% c("World", NIVELES_INGRESO)) |>
  mutate(grupo = factor(ifelse(grupo == "World", "World (161)", ETIQUETAS_INGRESO_CORTAS_EN[grupo]),
                        levels = rev(c("World (161)", ETIQUETAS_INGRESO_CORTAS_EN[NIVELES_INGRESO]))),
         componente = factor(recode(componente, CBR = "Births (CBR)", CDR = "Deaths (CDR)", CNMR = "Net migration (CNMR)"),
                             levels = c("Births (CBR)", "Deaths (CDR)", "Net migration (CNMR)")))
p18b <- ggplot(fig_shap, aes(100 * share, grupo, fill = componente)) + geom_col(width = 0.7) +
  geom_text(aes(label = sprintf("%.0f%%", 100 * share)), position = position_stack(vjust = 0.5), size = 3.2, colour = "white") +
  scale_fill_manual(values = c("Births (CBR)" = COLOR_NACIMIENTOS, "Deaths (CDR)" = COLOR_DEFUNCIONES, "Net migration (CNMR)" = COLOR_MIGRACION), name = NULL) +
  labs(x = "Share of cross-country differences in the 2023 growth rate (Shapley / LMG, %)", y = NULL,
       title = sprintf("B · Net migration accounts for %.0f%% of growth differences\namong high-income countries (Shapley)", 100 * bb_shap_hi$valor),
       subtitle = sprintf("High income: block bootstrap 95%% [%.0f; %.0f]%%.\nLow income is fragile: %.0f%% without South Sudan, Syria and Sudan.",
                          100 * bb_shap_hi$ci_low, 100 * bb_shap_hi$ci_high,
                          100 * shap$share[shap$grupo == "Low income without SSD, SYR, SDN" & shap$componente == "CNMR"])) +
  tema_q1(11) + theme(legend.position = "bottom")
p18 <- (p18a | p18b) + plot_annotation(caption = pie_q1(PIE_MODELOS, badge("PIE-4"), "Descriptive: the growth rate is an identity, (CBR − CDR + CNMR) / 10."))
guardar_q1(p18, "q1_18_misma_fecundidad_shapley")

# =============================================================================
# 11. Contrastes formales (familias, Holm/BH) y estado de las hipótesis
# =============================================================================
# QUÉ: junta los p-valores calculados en Q1, los agrupa por familia y los
#      ajusta (Holm para hipótesis; BH para comprobaciones auxiliares), y
#      evalúa cada hipótesis preinscrita con su regla escrita.
# POR QUÉ: ASA A.4/B.3: se reporta todo lo que se contrastó, salga o no.
seccion("11. Contrastes y estado de hipótesis")

contrastes <- tibble(
  contraste = c("H3b log-rank 4 income groups", "H15 placebo permutation", "H16 within slope (cluster)",
                "H24 Moran TFR 2023", "H24 Moran LEx 2023", "H24 Moran median age 2023", "H24 Moran CNMR 2023",
                "H3b Cox income step", "H15 lead falsification", "H15 Wald income heterogeneity", "H15 Cochran Q income",
                "H15 Cochran Q region", "Fertility onset log-rank by region", "Moran CNMR 2023 without Gulf"),
  familia = c(rep("F1 (hypothesis decision)", 7), rep("F2 (supporting checks)", 7)),
  hipotesis = c("H3b", "H15", "H16", "H24", "H24", "H24", "H24", "H3b", "H15", "H15", "H15", "H15", NA, "H24"),
  p = c(lr_p, plac_p, unname(ct_hi[4]), m23$p_perm[m23$indicador == "TFR"], m23$p_perm[m23$indicador == "LEx"],
        m23$p_perm[m23$indicador == "MedianAgePop"], m23$p_perm[m23$indicador == "CNMR"], unname(cx_p), unname(lead_ct[4]), wald_p,
        unname(coch_ing["p"]), unname(coch_reg["p"]), pchisq(lr_reg$chisq, length(lr_reg$n) - 1, lower.tail = FALSE), unname(pm_ng["p"]))) |>
  group_by(familia) |> mutate(p_holm = p.adjust(p, "holm"), p_bh = p.adjust(p, "BH")) |> ungroup()
print(contrastes |> mutate(across(where(is.numeric), \(x) signif(x, 3))))
fijar_padj <- function(clave, p_adj, metodo) {
  reg[[clave]]["p_adj"] <<- list(signif(p_adj, 4)); reg[[clave]]["p_adj_method"] <<- list(metodo)
}
fijar_padj("logrank_income_chisq", contrastes$p_holm[1], "holm (F1, Q1)")
fijar_padj("panel_placebo_lo", contrastes$p_holm[2], "holm (F1, Q1)"); fijar_padj("panel_placebo_hi", contrastes$p_holm[2], "holm (F1, Q1)")
fijar_padj("mig_hi_within_slope", contrastes$p_holm[3], "holm (F1, Q1)")
for (j in 1:4) fijar_padj(claves_moran[c("TFR", "LEx", "MedianAgePop", "CNMR")][j], contrastes$p_holm[3 + j], "holm (F1, Q1)")
n_tests_q1 <- c(F1 = sum(contrastes$familia == "F1 (hypothesis decision)"), F2 = sum(contrastes$familia == "F2 (supporting checks)"),
                F2_grids = nrow(grid_res) + nrow(reglas_res),
                F2_lisa_local = nrow(lisa_tab),                     # 161 x 2 pruebas locales con BH
                F3_illustration = length(ejemplos) + 2L)   # ejemplos A-E, ejemplos de inercia y países resaltados de fig04
anotar("n_tests_q1", value = n_tests_q1, unit = "tests", fmt = "0", method = "descriptive",
       def = "Formal tests computed for Q1 by family: F1 = p-values that decide a hypothesis (Holm), F2 = supporting checks (BH), sensitivity grids (reported in full, unmarked) and local Moran tests (BH within each map), F3 = rule-based illustrations without inference (examples by type, momentum examples, highlighted countries)",
       filter = "Q1 script", source_cell = "Q1-11.1", used_in = c("notebook.T17"), status = "descriptive",
       n = sum(n_tests_q1), universe = "Q1 analyses (number of tests)")

# 11.2 Estado de cada hipótesis de Q1 con su regla escrita (hipotesis_preinscritas.md)
x_hi <- cuotas[["High income"]]
h15_cond <- c(neg = LN05 * s1$beta_sum < 0, ic = LN05 * s1$lo < 0,   # regla preinscrita: IC con EE agrupados por país
              menor = abs(LN05 * s1$beta_sum) < (2 / 3) * abs(entre),
              fuera_placebo = s1$beta_sum > plac_q[2] | s1$beta_sum < plac_q[1])
km_up <- km53["crossed 5 by 1990", "med"]; km_post <- km53["after 1990", "med"]
q5_within <- simp |> filter(par == "Q5-CNMR", grupo != "World")
hip <- tribble(
  ~id, ~enunciado, ~estado, ~evidencia,
  "H1", "High-income (FY2027): net migration > 50% of 2000-23 growth",
  ifelse(x_hi$bb$valor > 50 & x_hi$bca$ci_low > 50, "confirmada", ifelse(x_hi$bb$valor > 50, "matizada (parcial)", "rechazada")),
  sprintf("%.1f%% [BCa %.1f; %.1f] [bloques %.1f; %.1f]; jackknife %.1f-%.1f; sens %.1f-%.1f", x_hi$bb$valor, x_hi$bca$ci_low, x_hi$bca$ci_high,
          x_hi$bb$ci_low, x_hi$bb$ci_high, x_hi$jk$min, x_hi$jk$max, min(sens_hi), max(sens_hi)),
  "H2", "Europe: NatChange < 0 every year since 1993; grows 2000-23 only by migration",
  ifelse(!is.na(anio_eu) && abs(anio_eu - 1993) <= 1 && sum(eu_0023$NatChange) < 0 && sum(eu_0023$PopChange) > 0, "confirmada", "rechazada"),
  sprintf("first natural decrease %d, but NatChange >= 0 again in %s; sustained only since %s; 2000-23 nat %.0f, pop %.0f thousand (growth only through migration holds)", anio_eu_primero, paste(eu_pos, collapse = ", "), anio_eu, sum(eu_0023$NatChange), sum(eu_0023$PopChange)),
  "H3", "v1: median lag 11 yrs (Q5<100 -> TFR<4), mortality first 80%",
  ifelse(min(grid_res$mediana_rezago) < 0 | min(grid_res$pct_mort_primero) <= 50, "rechazada", "confirmada"),
  sprintf("grid medians %.1f to %.1f yrs; mortality first %.0f-%.0f%%; KM 100/4 %.0f [%.0f; %.0f]", min(grid_res$mediana_rezago), max(grid_res$mediana_rezago),
          min(grid_res$pct_mort_primero), max(grid_res$pct_mort_primero), km100["med"], km100["lo"], km100["hi"]),
  "H3a", "Q5 lasting decline starts before TFR in most high-fertility countries",
  ifelse(w_mort$ci_low > 50, "confirmada", ifelse(w_mort$valor > 50, "matizada", "rechazada")),
  sprintf("%d/%d = %.1f%% Wilson [%.1f; %.1f]; 9 rules %.0f-%.0f%%; lower bound of lag %.0f yrs [%.0f; %.0f]; Turnbull median not identified (%.0f%% mass beyond)",
          x_mort, n_onset, w_mort$valor, w_mort$ci_low, w_mort$ci_high, min(reglas_res$pct_mort_primero), max(reglas_res$pct_mort_primero),
          bb_lb$valor, bb_lb$ci_low, bb_lb$ci_high, 100 * masa_mas_alla),
  "H3b", "Fertility onset later in lower income groups (low > lowmid > upmid; log-rank)",
  ifelse(km_ing[["Low income"]]$mediana > km_ing[["Lower middle income"]]$mediana & km_ing[["Lower middle income"]]$mediana > km_ing[["Upper middle income"]]$mediana &
           contrastes$p_holm[1] < 0.05, "confirmada", "rechazada"),
  sprintf("medians %s / %s / %s / high %s; log-rank chi2 %.1f (3 df), Holm p %.1e", km_ing[["Low income"]]$mediana, km_ing[["Lower middle income"]]$mediana,
          km_ing[["Upper middle income"]]$mediana, km_ing[["High income"]]$mediana, lr$chisq, contrastes$p_holm[1]),
  "H4", "v1: CNMR beta ~ -1 = no persistence",
  ifelse(beta_cn >= quantile(beta_plac, 0.025) & beta_cn <= quantile(beta_plac, 0.975), "rechazada (beta indistinguible del placebo)", "matizada"),
  sprintf("beta %.2f vs placebo %.2f [%.2f; %.2f]; SD %.1f -> %.1f", beta_cn, mean(beta_plac), quantile(beta_plac, 0.025), quantile(beta_plac, 0.975), sd(bx$x0), sd(bx$x1)),
  "H4a", "Migration less persistent between decades than TFR and LEx",
  ifelse(all(r_cn < min(r_tl)), "confirmada", "rechazada"),
  sprintf("CNMR %.2f-%.2f vs TFR/LEx min %.2f; same sign %.0f%%", min(r_cn), max(r_cn), min(r_tl), w_sig$valor),
  "H5", "v1: rho(TFR, CNMR) negative only in high income",
  ifelse(h5_bca$ci_low < 0 & h5_bca$ci_high > 0, "rechazada", ifelse(h5_bca$ci_high < 0, "confirmada", "rechazada")),
  sprintf(">= 1 M (n=%d): Spearman %.2f [BCa %.2f; %.2f]; all %d high income: Pearson %.2f", nrow(hi23), h5_bca$valor, h5_bca$ci_low, h5_bca$ci_high, nrow(hi23_all), h5_all_p),
  "H12", "v1: 79 of 130 below-replacement countries still grow",
  ifelse(g_main["crecen"] == 79, "confirmada", "rechazada como cifra"),
  sprintf("growing: %d; births > deaths: %d", g_main["crecen"], sum(c23$TFR < 2.1 & c23$NatChange > 0)),
  "H12a", "Most below-replacement countries still grow (2023)",
  ifelse(all(share_crecen > 50), "confirmada", "rechazada"),
  paste(sprintf("%s: %d of %d (%.0f%%)", rownames(g_tab), g_tab[, "crecen"], g_tab[, "n"], share_crecen), collapse = "; "),
  "H14", "v1: first natural decrease Europe 1993, N. America 2040, Asia/LAC 2055",
  "matizada (descriptiva; años futuros = proyección)",
  paste(sprintf("%s %s (%s)", h14$Location, ifelse(is.na(h14$primer_anio_natneg), "-", h14$primer_anio_natneg), h14$periodo), collapse = "; "),
  "H14a", "Countries with NatChange < 0: <= 10 (1990) -> >= 40 (2023)",
  ifelse(natneg$n[natneg$Time == 1990] <= 10 & natneg$n[natneg$Time == 2023] >= 40, "confirmada", "rechazada"),
  sprintf("1990: %d (%.0f%% of people); 2023: %d (%.0f%%); 2050 projection: %d", natneg$n[1], natneg$pop_share[1], natneg$n[2], natneg$pop_share[2], natneg$n[3]),
  "H15", "Within-country TFR-Q5 association < 2/3 of between, CI excludes 0, beats placebo",
  ifelse(all(h15_cond), ifelse(bb_de$ci_high[["dentro"]] < 0, "confirmada",
                               "confirmada por la regla preinscrita (IC por país), con matiz: el IC por bloques de subregión incluye 0"), "rechazada"),
  sprintf("within %.2f [cluster %.2f; %.2f] [bloques %.2f; %.2f] vs between %.2f; placebo 95%% [%.2f; %.2f] (beta units) vs real %.2f; lead %.2f (p %.2f)",
          LN05 * s1$beta_sum, LN05 * s1$hi, LN05 * s1$lo, bb_de$ci_low[["dentro"]], bb_de$ci_high[["dentro"]], entre, plac_q[1], plac_q[2], s1$beta_sum, lead_ct[1], lead_ct[4]),
  "H16", "High income w/o Gulf: no within-country migration compensation (CI contains 0)",
  ifelse(ct_hi[1] - 1.96 * ct_hi[2] < 0 & ct_hi[1] + 1.96 * ct_hi[2] > 0 & bb_hi$ci_low < 0 & bb_hi$ci_high > 0, "confirmada", "rechazada"),
  sprintf("%.2f [cluster %.2f; %.2f] [bloques %.2f; %.2f]; country FE only %.2f", ct_hi[1], ct_hi[1] - 1.96 * ct_hi[2], ct_hi[1] + 1.96 * ct_hi[2], bb_hi$ci_low, bb_hi$ci_high, ct_hp[1]),
  "H17", "Aligning on TFR = 4 removes >= 50% of variance (>= 30% with 5 and 3)",
  ifelse(r4$pct >= 50 & regs_hito$c5$pct >= 30 & regs_hito$c3$pct >= 30, "confirmada", "rechazada"),
  sprintf("4: %.0f%% [%.0f; %.0f]; 5: %.0f%%; 3: %.0f%%; phase R2 %.2f", r4$pct, r4$bb$ci_low, r4$bb$ci_high, regs_hito$c5$pct, regs_hito$c3$pct, r2_fase["r2"]),
  "H18", "Countries crossing 5 after 1990 are not faster from 5 to 3",
  ifelse(is.na(km_post) || km_post >= km_up, "confirmada", "rechazada"),
  sprintf("KM median after 1990 %.1f vs by 1990 %.1f (by 1975 %.1f; 1975-90 %.1f)", km_post, km_up, km53[1, "med"], km53[2, "med"]),
  "H19", ">= 15 below-replacement countries grow from births without net immigration, >= 2 bn people",
  ifelse(n_inr >= 15 & pop_inr >= 2, "confirmada", "rechazada"),
  sprintf("%d countries, %.2f bn (strict %d, %.2f bn)", n_inr, pop_inr, n_inr_e, pop_inr_e),
  "H21", "rho(Q5, CNMR) < -0.3 worldwide, |rho| < 0.2 within each income group",
  ifelse(simp$rho[simp$par == "Q5-CNMR" & simp$grupo == "World"] < -0.3 & all(abs(q5_within$rho) < 0.2), "confirmada",
         ifelse(simp$rho[simp$par == "Q5-CNMR" & simp$grupo == "World"] < -0.3, "matizada", "rechazada")),
  sprintf("world %.2f; within %s; partial %.2f", simp$rho[simp$par == "Q5-CNMR" & simp$grupo == "World"],
          paste(sprintf("%s %.2f", ETIQUETAS_INGRESO_CORTAS_EN[q5_within$grupo], q5_within$rho), collapse = ", "), rho_parcial),
  "H22", ">= 1/3 of countries: UN 95% PI 2050 includes growth and decline",
  ifelse(n_unc95 >= 54, "confirmada", "rechazada"), sprintf("%d of 161 (80%% PI: %d)", n_unc95, n_unc80),
  "H24", "Moran CNMR < 0.2 while TFR, LEx, median age > 0.6 (2023)",
  ifelse(m23$I[m23$indicador == "CNMR"] < 0.2 & all(m23$I[m23$indicador %in% c("TFR", "LEx", "MedianAgePop")] > 0.6), "confirmada", "rechazada"),
  sprintf("TFR %s, LEx %s, median age %s, CNMR %s (without Gulf %s)",
          formatear_cifra(round(m23$I[m23$indicador == "TFR"], 4), "0.00"), formatear_cifra(round(m23$I[m23$indicador == "LEx"], 4), "0.00"),
          formatear_cifra(round(m23$I[m23$indicador == "MedianAgePop"], 4), "0.00"), formatear_cifra(round(m23$I[m23$indicador == "CNMR"], 4), "0.00"),
          formatear_cifra(round(unname(pm_ng["I"]), 4), "0.00"))
)
print(hip, n = 30, width = 220)

# =============================================================================
# 12. Salidas: numbers_q1.json, parquet, CSV
# =============================================================================
# QUÉ: guarda las cifras con su esquema completo y las tablas que necesitarán
#      las figuras finales.
# POR QUÉ: ninguna cifra del vídeo se escribe a mano (fuente única de verdad).
seccion("12. Salidas")

paises_q1 <- miembros |>
  left_join(bi |> select(ISO3_code, tfr_1950), by = "ISO3_code") |>
  left_join(el |> transmute(ISO3_code, elegible_inicio = TRUE, inicio_q5, inicio_tfr, izq_q5, izq_tfr, rezago_inicio_lo, rezago_inicio_hi,
                            mort_primero, caida_q5_al_inicio_tfr), by = "ISO3_code") |>
  left_join(hitos |> select(ISO3_code, c5, c4, c3, dur_5a3, evento_3, cohorte_c5, ventana_completa_c4), by = "ISO3_code") |>
  mutate(elegible_inicio = elegible_inicio %in% TRUE, cohorte_c5 = as.character(cohorte_c5))
guardar_pq <- function(df, nombre) arrow::write_parquet(as.data.frame(df), file.path(RUTA_PROCESSED, paste0(nombre, ".parquet")))
guardar_pq(paises_q1, "resultados_q1")
guardar_pq(desc, "resultados_q1_descomposicion")
guardar_pq(cuotas_tab, "resultados_q1_cuotas_ic")
guardar_pq(tab_vent, "resultados_q1_ventanas")
guardar_pq(mor, "resultados_q1_moran")
guardar_pq(km_tab, "resultados_q1_km")
guardar_pq(ev_tab, "resultados_q1_event_time")
guardar_pq(grid_res, "resultados_q1_umbral_grid")
guardar_pq(reglas_res, "resultados_q1_reglas_inicio")
guardar_pq(curvas, "resultados_q1_registro")
guardar_pq(disp_reg, "resultados_q1_registro_dispersion")
guardar_pq(panel_tab, "resultados_q1_panel")
guardar_pq(tibble(replica = seq_along(plac), beta_sum = plac, halfq5 = LN05 * plac), "resultados_q1_placebo")
guardar_pq(cmp_tab, "resultados_q1_comparacion_modelos")
guardar_pq(mem, "resultados_q1_memoria")
guardar_pq(simp |> select(-bb), "resultados_q1_simpson")
guardar_pq(fan, "resultados_q1_fan_are")
guardar_pq(dir50, "resultados_q1_direccion_2050")
guardar_pq(hip, "resultados_q1_hipotesis")
guardar_pq(contrastes, "resultados_q1_contrastes")
guardar_pq(reloj, "resultados_q1_inercia")
guardar_pq(lisa_tab, "resultados_q1_lisa")
guardar_pq(shap, "resultados_q1_shapley")
guardar_pq(banda, "resultados_q1_misma_fecundidad")
guardar_pq(rachas, "resultados_q1_tipoE_historico")
guardar_pq(pred_gam |> mutate(ingreso = as.character(ingreso)), "resultados_q1_gam")
guardar_pq(gancho_df |> mutate(grupo = as.character(grupo)), "resultados_q1_gancho")

guardar_numbers(reg, RUTA_NUMBERS_Q1, ordenar = TRUE)
val <- validar_registro(reg)
cat("\nValidación del registro (problemas):\n"); print(val, row.names = FALSE)
falt <- claves_faltantes(reg, c("universo", "slide1", "slide2"))
cat("\nClaves obligatorias de universo/slide1/slide2 que NO registra Q1:", paste(falt, collapse = ", "), "\n")
informar("Claves registradas: %d -> %s", length(reg), RUTA_NUMBERS_Q1)
informar("Tiempo total: %.1f min (B pantalla = %d, B notebook = %d, placebo = %d, permutaciones = %d)",
         as.numeric(difftime(Sys.time(), t_inicio, units = "mins")), B_Q1, B_NB, B_PLAC, B_PERM_Q1)
invisible(TRUE)
