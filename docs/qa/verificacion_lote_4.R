#!/usr/bin/env Rscript
# =============================================================================
# verificacion_lote_4.R  (agente "verificador-4", QA independiente)
# Recalcula DESDE LOS DATOS CRUDOS las cifras del lote 4 de figures/numbers.json
# SIN usar los scripts del repositorio (no hace source de R/0*.R ni lee
# data/processed/*.parquet). Solo usa:
#   - ../WPP2024_Demographic_Indicators_Medium_csv.gz        (crudo ONU)
#   - ../WPP2024_Demographic_Indicators_OtherVariants_csv.gz (crudo ONU)
#   - ../WPP2024_Supplement_Births_and_LE60.csv               (suplemento)
#   - data/processed/lookup_regiones.csv  (solo la columna region_sdg)
#   - data/raw/wb_api_income_2026-10-22.csv (ingreso World Bank FY2027)
#   - rnaturalearthdata::countries50 (puntos de etiqueta para kNN5 espacial)
# Uso: Rscript docs/qa/verificacion_lote_4.R   (desde cualquier carpeta)
# Salida: docs/qa/verificacion_lote_4_resultados.csv + impresión en consola.
# Semilla: set.seed(2026) justo antes de cada bloque aleatorio.
# =============================================================================

suppressPackageStartupMessages({
  library(data.table); library(survival); library(fixest); library(fda)
  library(clue); library(jsonlite)
})

RAIZ <- "/home/darkns/Documents/ASA_Dataquest/RepoGithub"
PADRE <- dirname(RAIZ)
SEMILLA <- 2026
t0 <- Sys.time()
msg <- function(...) cat(sprintf(...), "\n")

# --- 0. Lectura de crudos --------------------------------------------------
med <- fread(file.path(PADRE, "WPP2024_Demographic_Indicators_Medium_csv.gz"))
ov  <- fread(file.path(PADRE, "WPP2024_Demographic_Indicators_OtherVariants_csv.gz"),
             select = c("LocID", "ISO3_code", "Location", "Variant", "Time",
                        "TPopulation1July", "CNMR", "NetMigrations"))
sup <- fread(file.path(PADRE, "WPP2024_Supplement_Births_and_LE60.csv"))
lk  <- fread(file.path(RAIZ, "data/processed/lookup_regiones.csv"))
wb  <- fread(file.path(RAIZ, "data/raw/wb_api_income_2026-10-22.csv"))

# Países = ISO3_code no vacío (nunca agregados); se descarta 2101
pa <- med[ISO3_code != "" & Time <= 2100]
stopifnot(uniqueN(pa$ISO3_code) == 237)

# Subregión ONU desde ParentID (Northern America = 918 no trae fila propia)
nombres_loc <- unique(med[, .(LocID, Location)])
sub <- unique(pa[, .(ISO3_code, ParentID)])
sub[, subregion := nombres_loc$Location[match(ParentID, nombres_loc$LocID)]]
sub[ParentID == 918, subregion := "Northern America"]
stopifnot(!anyNA(sub$subregion))

# Región SDG (permitida desde lookup) e ingreso FY2027 (archivo WB)
reg <- lk[, .(ISO3_code = ISO3, region_sdg)]
ing <- wb[, .(ISO3_code = ISO3, ingreso = trimws(ingreso_api))]
info <- unique(pa[, .(ISO3_code, Location)])
info <- merge(info, sub[, .(ISO3_code, subregion)], by = "ISO3_code")
info <- merge(info, reg, by = "ISO3_code", all.x = TRUE)
info <- merge(info, ing, by = "ISO3_code", all.x = TRUE)
info[is.na(ingreso) | ingreso == "" | !ingreso %in% c("Low income", "Lower middle income",
     "Upper middle income", "High income"), ingreso := "Not classified"]
p23 <- pa[Time == 2023, .(ISO3_code, pop23 = TPopulation1July)]
info <- merge(info, p23, by = "ISO3_code")
info[, pob_1m := pop23 >= 1000]          # miles de personas: >= 1 M
msg("Países: %d; >= 1 M: %d; subregiones entre >= 1 M: %d",
    nrow(info), sum(info$pob_1m), uniqueN(info[pob_1m == TRUE]$subregion))
stopifnot(sum(info$pob_1m) == 161, !anyNA(info$region_sdg))
pa <- merge(pa, info[, .(ISO3_code, subregion, region_sdg, ingreso, pob_1m, pop23)],
            by = "ISO3_code")
setkey(pa, ISO3_code, Time)
est <- pa[Time <= 2023]                  # estimaciones
G   <- info[pob_1m == TRUE, sort(ISO3_code)]   # 161 países >= 1 M
GOLFO <- c("ARE", "QAT", "KWT", "BHR", "OMN", "SAU")
mundo <- med[LocID == 900 & Time <= 2100]

# --- utilidades -----------------------------------------------------------
res <- list()
anota <- function(clave, nb, ind, coincide, clara = TRUE, nota = "") {
  res[[clave]] <<- data.table(clave = clave, valor_notebook = as.character(nb),
                              valor_independiente = as.character(ind),
                              coincide = coincide, definicion_clara = clara, nota = nota)
  msg("[%s] notebook=%s | independiente=%s | coincide=%s", clave, nb, ind, coincide)
}
# Bootstrap por bloques de subregión ONU: remuestrea subregiones con reemplazo
# (percentil, B = 2000). f recibe un vector de ISO3 (con repetidos) y devuelve un número.
boot_bloques <- function(paises, f, B = 2000, semilla = SEMILLA) {
  sr <- info$subregion[match(paises, info$ISO3_code)]
  bloques <- split(paises, sr)
  set.seed(semilla)
  v <- replicate(B, { b <- sample(names(bloques), length(bloques), replace = TRUE)
                      f(unlist(bloques[b], use.names = FALSE)) })
  quantile(v, c(0.025, 0.975), na.rm = TRUE)
}
wilson <- function(x, n, z = qnorm(0.975)) {
  ph <- x / n; den <- 1 + z^2 / n
  c((ph + z^2 / (2 * n) - z * sqrt(ph * (1 - ph) / n + z^2 / (4 * n^2))) / den,
    (ph + z^2 / (2 * n) + z * sqrt(ph * (1 - ph) / n + z^2 / (4 * n^2))) / den)
}

# =============================================================================
# 1. Conteos y tipos de palanca 2023 (237 países y áreas)
# =============================================================================
d23 <- pa[Time == 2023]
# Tipos (plan §3): A Nat>0, NetMig>0, Pop>0 · B Nat>0, NetMig<=0, Pop>0 ·
# C Nat<0, Pop>0 · D Nat<0, Pop<0 · E Nat>0, Pop<0
d23[, tipo := fcase(NatChange > 0 & NetMigrations > 0 & PopChange > 0, "A",
                    NatChange > 0 & NetMigrations <= 0 & PopChange > 0, "B",
                    NatChange < 0 & PopChange > 0, "C",
                    NatChange < 0 & PopChange < 0, "D",
                    NatChange > 0 & PopChange < 0, "E", default = NA_character_)]
msg("Tipos 2023: %s", paste(names(table(d23$tipo, useNA = "ifany")), table(d23$tipo, useNA = "ifany"), collapse = " "))

v <- d23[TFR < 2.1, .N]
anota("n_below_replacement_2023", 130, v, v == 130)

v <- d23[tipo == "B", .N]
anota("n_type_B", 94, v, v == 94)

v <- d23[pob_1m == TRUE & NatChange < 0 & PopChange > 0, .N]
anota("n_grow_only_migration_2023_1m", 11, v, v == 11)

top3 <- function(dt) dt[pob_1m == TRUE][order(-pop23)][1:3, ISO3_code]
v <- top3(d23[tipo == "C"])
anota("examples_type_C_iso3", "DEU, ESP, BEL", paste(v, collapse = ", "),
      identical(v, c("DEU", "ESP", "BEL")))
v <- top3(d23[tipo == "E"])
anota("examples_type_E_iso3", "NPL, AZE, URY", paste(v, collapse = ", "),
      identical(v, c("NPL", "AZE", "URY")))

# Inercia: tipo B con TFR < 2,1 (22 países y áreas)
mom <- d23[tipo == "B" & TFR < 2.1]
v <- mom[pob_1m == TRUE][order(-pop23)][1:3, Location]
anota("examples_momentum", "India, Brazil, Mexico", paste(v, collapse = ", "),
      identical(v, c("India", "Brazil", "Mexico")),
      nota = sprintf("n_momentum = %d (>= 1 M: %d); estricta NetMig<0: %d", nrow(mom),
                     mom[pob_1m == TRUE, .N], mom[NetMigrations < 0, .N]))
v <- sum(mom$TPopulation1July) / 1e6
anota("pop_momentum_bn", "2.2 (2.201)", sprintf("%.4f", v), abs(v - 2.201) < 0.005,
      nota = sprintf("%d países; suma TPopulation1July 2023", nrow(mom)))

v <- d23[Q5 > 25, .N]
anota("n_sdg32_above", 70, v, v == 70, nota = sprintf(">= 1 M: %d", d23[Q5 > 25 & pob_1m == TRUE, .N]))

v <- pa[Time == 2050 & PopChange < 0, .N]
anota("n_shrinking_2050", 98, v, v == 98,
      nota = sprintf(">= 1 M: %d (proyección Medium)", pa[Time == 2050 & PopChange < 0 & pob_1m == TRUE, .N]))

# Estados soberanos: 237 menos la lista explícita de 42 territorios
terr <- c("ASM","AIA","ABW","BMU","BES","VGB","CYM","HKG","MAC","TWN","COK","CUW","FLK",
          "FRO","GUF","PYF","GIB","GRL","GLP","GUM","GGY","IMN","JEY","XKX","MTQ","MYT",
          "MSR","NCL","NIU","MNP","PRI","REU","BLM","SHN","MAF","SPM","SXM","TKL","TCA",
          "VIR","WLF","ESH")
estados <- setdiff(info$ISO3_code, terr)
anota("n_states", 195, length(estados),
      length(terr) == 42 && all(terr %in% info$ISO3_code) && length(estados) == 195 &&
        all(c("VAT", "PSE") %in% estados),
      nota = "42 territorios todos presentes en WPP; VAT y PSE entre los 195; lista de 193 miembros revisada a mano")

v <- d23[ISO3_code == "BLR", PopGrowthRate]
anota("twin_growth_blr", -0.653, sprintf("%.3f", v), abs(v - (-0.653)) < 0.005,
      nota = sprintf("ARE 2023: %.3f; TFR BLR %.3f / ARE %.3f", d23[ISO3_code == "ARE", PopGrowthRate],
                     d23[ISO3_code == "BLR", TFR], d23[ISO3_code == "ARE", TFR]))

wp <- mundo[Time >= 2024][which.max(TPopulation1July)]
v <- wp$TPopulation1July / 1e6
anota("world_peak_bn", "10.29 (10.289315244)", sprintf("%.6f (año %d)", v, wp$Time), abs(v - 10.289315244) < 0.005,
      nota = sprintf("máximo 1950-2100 en %d", mundo[which.max(TPopulation1July), Time]))

# Agregado ONU 'High-income countries': ΣNetMigrations / ΣPopChange, 2000-2023
hi <- med[Location == "High-income countries" & Time >= 2000 & Time <= 2023]
stopifnot(nrow(hi) == 24)
v <- 100 * sum(hi$NetMigrations) / sum(hi$PopChange)
anota("share_mig_high_un_agg", "64.0 (63.9873)", sprintf("%.4f", v), abs(v - 63.9873) < 0.05,
      nota = "LocID del agregado ONU de ingreso alto, sumas de personas 2000-2023")

# OtherVariants: EAU 2050 'Zero migration'
v <- ov[ISO3_code == "ARE" & Variant == "Zero migration" & Time == 2050, TPopulation1July] / 1e3
anota("pop_are_2050_zero_mig", "12.4 (12.3933)", sprintf("%.4f", v), abs(v - 12.3933) < 0.05,
      nota = sprintf("2100: %.1f M; Medium 2050: %.1f M",
                     ov[ISO3_code == "ARE" & Variant == "Zero migration" & Time == 2100, TPopulation1July] / 1e3,
                     pa[ISO3_code == "ARE" & Time == 2050, TPopulation1July] / 1e3))

# Signo de la CNMR 2050 incierto: el IP 80 % incluye 0 (Lower 80 <= 0 <= Upper 80)
pi50 <- dcast(ov[ISO3_code %in% G & Time == 2050 & Variant %in% c("Lower 80 PI", "Upper 80 PI",
              "Lower 95 PI", "Upper 95 PI")], ISO3_code ~ Variant, value.var = "CNMR")
setnames(pi50, make.names(names(pi50)))
v <- pi50[Lower.80.PI <= 0 & Upper.80.PI >= 0, .N]
anota("n_cnmr_sign_uncertain_2050", 155, v, v == 155 && nrow(pi50) == 161,
      nota = sprintf("IP95 incluye 0 en %d de %d", pi50[Lower.95.PI <= 0 & Upper.95.PI >= 0, .N], nrow(pi50)))

# Metadatos: versión WPP (comprobación de que los archivos son los de WPP 2024)
var_ov <- unique(ov$Variant)
anota("meta_wpp_version", "WPP 2024 (July 2024): Medium 1950-2023 est + 2024-2100; OtherVariants PI 80/95 + scenarios; supplement LE60 + births by sex",
      sprintf("Medium: Time %d-%d, Variant=%s; OtherVariants: %d variantes incl. 80/95 PI=%s, Zero migration=%s; suplemento cols LE60=%s, BirthsMale/Female=%s",
              min(med$Time), max(med$Time), paste(unique(med$Variant), collapse = "/"), length(var_ov),
              all(c("Lower 80 PI", "Upper 95 PI") %in% var_ov), "Zero migration" %in% var_ov,
              "LE60" %in% names(sup), all(c("BirthsMale", "BirthsFemale") %in% names(sup))),
      TRUE, nota = "Descriptivo: estructura de archivos coherente con WPP 2024; la 'release' de julio 2024 no se puede comprobar desde el CSV (no trae fecha)")

# =============================================================================
# 2. Inicio de la caída sostenida (regla de Princeton) — P7
# =============================================================================
# Inicio = primer año con x <= 0,9 · máximo previo (incluido el año) que no
# vuelve a superarse después; NA = no iniciado en 2023 (censura derecha).
inicio <- function(t, x, frac = 0.9) {
  rm <- cummax(x)
  for (i in seq_along(x)) { lim <- frac * rm[i]
    if (x[i] <= lim && all(x[i:length(x)] <= lim)) return(as.numeric(t[i])) }
  NA_real_
}
ini <- est[ISO3_code %in% G, .(tfr1950 = TFR[Time == 1950],
                               ini_tfr = inicio(Time, TFR), ini_q5 = inicio(Time, Q5)),
           by = .(ISO3_code, ingreso, region_sdg)]
eleg <- ini[tfr1950 >= 5 & ingreso != "Not classified" & !is.na(ini_q5)]
msg("TFR1950>=5 y >=1M: %d; con ingreso: %d; con inicio Q5: %d; sin inicio Q5: %s",
    ini[tfr1950 >= 5, .N], ini[tfr1950 >= 5 & ingreso != "Not classified", .N], nrow(eleg),
    paste(ini[tfr1950 >= 5 & ingreso != "Not classified" & is.na(ini_q5), ISO3_code], collapse = ","))
anota("n_onset", 109, nrow(eleg), nrow(eleg) == 109,
      nota = sprintf("elegibles TFR1950>=5 con ingreso: %d (sin inicio de Q5 observado: %s)",
                     ini[tfr1950 >= 5 & ingreso != "Not classified", .N],
                     paste(ini[tfr1950 >= 5 & ingreso != "Not classified" & is.na(ini_q5), ISO3_code], collapse = ", ")))
eleg[, mort_primero := is.na(ini_tfr) | ini_q5 < ini_tfr]
nmf <- sum(eleg$mort_primero)
anota("n_mort_first_onset", 106, nmf, nmf == 106,
      nota = sprintf("no-mortalidad-primero: %s; TFR sin iniciar: %d; empates mismo año: %d",
                     paste(eleg[mort_primero == FALSE, sprintf("%s(Q5 %g, TFR %g)", ISO3_code, ini_q5, ini_tfr)], collapse = "; "),
                     eleg[is.na(ini_tfr), .N], eleg[!is.na(ini_tfr) & ini_q5 == ini_tfr, .N]))
w <- 100 * wilson(nmf, nrow(eleg))
v <- 100 * nmf / nrow(eleg)
anota("share_mort_first", "97 [92; 99] (97.2477; 92.22-99.06)", sprintf("%.4f [%.2f; %.2f]", v, w[1], w[2]),
      abs(v - 97.2477) < 0.5 && abs(w[1] - 92.2189) < 0.1 && abs(w[2] - 99.0596) < 0.1)

# KM del año de inicio de la caída de la TFR, ingreso bajo (censura 2023)
lo <- eleg[ingreso == "Low income"]
lo[, `:=`(t = fifelse(is.na(ini_tfr), 2023, ini_tfr), ev = as.integer(!is.na(ini_tfr)))]
km <- survfit(Surv(t, ev) ~ 1, data = lo)
s <- summary(km)
med_s <- min(s$time[s$surv <= 0.5])
qq <- quantile(km, 0.5)
anota("yr_fert_onset_low", "2000 [1995; 2007]",
      sprintf("%d [%g; %g] (survfit median %g); n=%d, eventos=%d", med_s, qq$lower, qq$upper,
              unname(qq$quantile), nrow(lo), sum(lo$ev)),
      med_s == 2000 && qq$lower == 1995 && qq$upper == 2007)

# =============================================================================
# 3. Dispersión entre países (P1), 161 países >= 1 M, estimaciones
# =============================================================================
e50 <- est[ISO3_code %in% G & Time == 1950]
sd_f <- function(var) function(iso) { x <- e50[[var]][match(iso, e50$ISO3_code)]; sd(x) }
cv_f <- function(iso) { x <- e50$LE65[match(iso, e50$ISO3_code)]; 100 * sd(x) / mean(x) }
v <- sd(e50$LE65); ci <- boot_bloques(G, sd_f("LE65"))
anota("sd_le65_1950", "1.47 [1.15; 1.76]", sprintf("%.4f [%.2f; %.2f]", v, ci[1], ci[2]),
      abs(v - 1.4685) < 0.005 && v >= 1.149 && v <= 1.761,
      nota = sprintf("237: %.2f; IC por bloques propio (otra secuencia aleatoria)", sd(pa[Time == 1950]$LE65)))
v <- 100 * sd(e50$LE65) / mean(e50$LE65); ci <- boot_bloques(G, cv_f)
anota("cv_le65_1950", "12.9 [10.1; 15.6]", sprintf("%.4f [%.1f; %.1f]", v, ci[1], ci[2]),
      abs(v - 12.8503) < 0.05 && v >= 10.06 && v <= 15.57,
      nota = sprintf("237: %.2f", 100 * sd(pa[Time == 1950]$LE65) / mean(pa[Time == 1950]$LE65)))
v <- sd(e50$MedianAgePop); ci <- boot_bloques(G, sd_f("MedianAgePop"))
anota("sd_medage_1950", "4.7 [3.1; 5.7]", sprintf("%.4f [%.1f; %.1f]", v, ci[1], ci[2]),
      abs(v - 4.6704) < 0.05 && v >= 3.117 && v <= 5.729,
      nota = sprintf("237: %.2f", sd(pa[Time == 1950]$MedianAgePop)))

# Razón P90/P10 de Q5 por año (quantile tipo 7), máximo 1950-2023
rq <- est[ISO3_code %in% G, .(r = quantile(Q5, 0.9) / quantile(Q5, 0.1)), by = Time]
v <- rq[which.max(r)]
anota("q5_ratio_p90p10_peak", "27 (26.934, 2006)", sprintf("%.3f (%d)", v$r, v$Time),
      round(v$r) == 27 && v$Time == 2006,
      nota = sprintf("1950: %.1f; 2023: %.1f", rq[Time == 1950, r], rq[Time == 2023, r]))

# =============================================================================
# 4. Scorecard y escalera (2023, 161 países >= 1 M)
# =============================================================================
s23 <- d23[ISO3_code %in% G]
r2a <- function(f, dt) summary(lm(f, dt))$adj.r.squared
v <- r2a(PopGrowthRate ~ TFR + CDR, s23)
anota("r2_ladder_tfr_cdr", "0.70 (0.6965)", sprintf("%.4f", v), abs(v - 0.69652) < 0.005)
f_r2 <- function(f) function(iso) r2a(f, s23[match(iso, s23$ISO3_code)])
v <- r2a(CNMR ~ TFR, s23); ci <- boot_bloques(G, f_r2(CNMR ~ TFR))
anota("r2_tfr_cnmr", "0.00 [-0.01; 0.08] (-0.00127)", sprintf("%.5f [%.3f; %.3f]", v, ci[1], ci[2]),
      abs(v - (-0.00127)) < 0.005 && v >= -0.0069 && v <= 0.0841,
      nota = sprintf("sin ajustar %.4f", summary(lm(CNMR ~ TFR, s23))$r.squared))
v <- r2a(MedianAgePop ~ TFR, s23); ci <- boot_bloques(G, f_r2(MedianAgePop ~ TFR))
anota("r2_tfr_medage", "0.77 [0.67; 0.84] (0.7711)", sprintf("%.4f [%.3f; %.3f]", v, ci[1], ci[2]),
      abs(v - 0.77115) < 0.005 && v >= 0.6748 && v <= 0.8350,
      nota = sprintf("sin ajustar %.4f", summary(lm(MedianAgePop ~ TFR, s23))$r.squared))

# =============================================================================
# 5. Memoria de la migración: medias por década de la CNMR
# =============================================================================
dec <- est[ISO3_code %in% G & Time >= 2000, .(c00 = mean(CNMR[Time <= 2009]), c10 = mean(CNMR[Time >= 2010])),
           by = ISO3_code]
v <- cor(dec$c00, dec$c10)
ci <- boot_bloques(G, function(iso) { x <- dec[match(iso, dec$ISO3_code)]; cor(x$c00, x$c10) })
anota("r_cnmr_decades_recent", "0.69 [0.52; 0.73] (0.6916)", sprintf("%.4f [%.3f; %.3f]", v, ci[1], ci[2]),
      abs(v - 0.6916) < 0.005 && v >= 0.523 && v <= 0.7261,
      nota = "2000s = 2000-2009, 2010s = 2010-2023, Pearson; el valor puntual está cerca del borde superior del IC por bloques (asimetría del bootstrap)")

# =============================================================================
# 6. Envejecimiento: años de edad mediana 30 -> 40 (estimación <= 2023 + Medium)
# =============================================================================
ma <- pa[ISO3_code %in% G, .(a30 = suppressWarnings(min(as.numeric(Time)[MedianAgePop >= 30])),
                             a40 = suppressWarnings(min(as.numeric(Time)[MedianAgePop >= 40]))), by = ISO3_code]
ma[!is.finite(a30), a30 := NA]; ma[!is.finite(a40), a40 := NA]
v <- ma[ISO3_code == "JPN"]
anota("yrs_medage30_40_jpn", "21 (1977 -> 1998)", sprintf("%g (%g -> %g)", v$a40 - v$a30, v$a30, v$a40),
      v$a40 - v$a30 == 21 && v$a30 == 1977 && v$a40 == 1998,
      nota = "primer año con MedianAgePop >= 30 y >= 40 (ambos estimaciones)")
co <- ma[!is.na(a30) & a30 >= 1990 & a30 <= 2023]
co[, dur := a40 - a30]
v <- median(co$dur, na.rm = TRUE)
ci <- boot_bloques(co$ISO3_code, function(iso) median(co$dur[match(iso, co$ISO3_code)], na.rm = TRUE))
anota("yrs_medage30_40_cohort_1990_2023", "24 [21; 30] (35 países; 28 cruzan 40 en proyección)",
      sprintf("%g [%g; %g] (%d países; %d cruzan 40 después de 2023; %d no llegan a 40 antes de 2100)",
              v, ci[1], ci[2], nrow(co), co[!is.na(a40) & a40 > 2023, .N], co[is.na(a40), .N]),
      v == 24 && co[!is.na(a40), .N] == 35 && co[!is.na(a40) & a40 > 2023, .N] == 28 &&
        ci[1] == 21 && ci[2] == 30,
      clara = FALSE,
      nota = sprintf(paste0("Definición imprecisa: %d países cruzan 30 en 1990-2023, pero solo %d llegan a 40 antes de 2100 ",
                            "(no llegan: %s); los 35 del texto son los que llegan; mediana simple sobre ellos. KM con censura 2100: %g"),
                     nrow(co), co[!is.na(a40), .N], paste(co[is.na(a40), ISO3_code], collapse = ", "),
                     unname(quantile(survfit(Surv(fifelse(is.na(dur), 2100 - a30, dur), as.integer(!is.na(dur))) ~ 1, data = co), 0.5)$quantile)))

# =============================================================================
# 7. Clustering de trayectorias (Q3): k-means k = 4 sobre 32 rasgos
# =============================================================================
# Rasgos: medias por década (1950s ... 2020s; 2020s = 2020-2023) de TFR, LEx,
# MedianAgePop y CNMR winsorizada ±3 DE; z con media y DE de TODO el panel
# anual (161 países x 1950-2023). Decisión documentada en los memos FDA y MV.
pan <- est[ISO3_code %in% G, .(ISO3_code, Time, TFR, LEx, MedianAgePop, CNMR)]
lim_w <- mean(pan$CNMR) + c(-3, 3) * sd(pan$CNMR)
msg("Winsorización CNMR panel: [%.1f; %.1f], celdas recortadas %d de %d", lim_w[1], lim_w[2],
    pan[CNMR < lim_w[1] | CNMR > lim_w[2], .N], nrow(pan))
pan[, CNMRw := pmin(pmax(CNMR, lim_w[1]), lim_w[2])]
VARS_TR <- c("TFR", "LEx", "MedianAgePop", "CNMRw")
for (vv in VARS_TR) pan[, (paste0("z_", vv)) := (get(vv) - mean(get(vv))) / sd(get(vv))]
pan[, decada := 10L * (Time %/% 10L)]
rasgos <- pan[, lapply(.SD, mean), by = .(ISO3_code, decada), .SDcols = paste0("z_", VARS_TR)]
Xw <- dcast(rasgos, ISO3_code ~ decada, value.var = paste0("z_", VARS_TR))
X <- as.matrix(Xw[, -1]); rownames(X) <- Xw$ISO3_code
stopifnot(ncol(X) == 32, nrow(X) == 161)
set.seed(SEMILLA)
km <- kmeans(X, 4, nstart = 50)
cl <- km$cluster
# Variante B (sensibilidad del orden z/medias): z sobre las medias por década
rasgosB <- pan[, lapply(.SD, mean), by = .(ISO3_code, decada), .SDcols = VARS_TR]
for (vv in VARS_TR) rasgosB[, (vv) := (get(vv) - mean(get(vv))) / sd(get(vv))]
XB <- as.matrix(dcast(rasgosB, ISO3_code ~ decada, value.var = VARS_TR)[, -1])
set.seed(SEMILLA); clB <- kmeans(XB, 4, nstart = 50)$cluster
ari <- function(a, b) { t <- table(a, b); n <- sum(t); s1 <- sum(choose(t, 2))
  s2 <- sum(choose(rowSums(t), 2)); s3 <- sum(choose(colSums(t), 2)); e <- s2 * s3 / choose(n, 2)
  (s1 - e) / ((s2 + s3) / 2 - e) }
msg("Tamaños k-means: %s; ARI con variante z-después-de-medias: %.3f",
    paste(sort(table(cl)), collapse = "/"), ari(cl, clB))

# Nombre de cada grupo con la regla v2 (plan de implementación §6)
fd_base <- create.bspline.basis(c(1950, 2023), nbasis = 76, norder = 4)
Ytfr <- dcast(est[ISO3_code %in% G], Time ~ ISO3_code, value.var = "TFR")
anios <- Ytfr$Time; Ytfr <- as.matrix(Ytfr[, -1])
fd_tfr <- smooth.basis(anios, Ytfr, fdPar(fd_base, Lfdobj = 2, lambda = 10))$fd
tf <- seq(1950, 2023, 0.1); Tf <- eval.fd(tf, fd_tfr); colnames(Tf) <- colnames(Ytfr)
cruce <- function(y, u) { if (y[1] < u) return(-Inf); if (tail(y, 1) >= u) return(Inf)
  i <- max(which(y >= u)); tf[i] + (y[i] - u) / (y[i] - y[i + 1]) * 0.1 }
cr <- data.table(ISO3_code = colnames(Tf), c5 = apply(Tf, 2, cruce, 5),
                 c4 = apply(Tf, 2, cruce, 4), c3 = apply(Tf, 2, cruce, 3))
cn0023 <- est[ISO3_code %in% G & Time >= 2000, .(cnmr0023 = mean(CNMR)), by = ISO3_code]
gr <- data.table(ISO3_code = names(cl), k = cl)
gr <- merge(merge(gr, cr, by = "ISO3_code"), cn0023, by = "ISO3_code")
reglas <- gr[, .(cnmr_med = median(cnmr0023), c4_med = median(c4), frac_menos4_1950 = mean(c4 == -Inf)), by = k]
nombre_k <- function(r) {
  if (r$cnmr_med > 10) return("Migration-led")
  if (r$c4_med < 1960 || r$frac_menos4_1950 > 0.5) return("Early movers")
  if (r$c4_med > 1995 || is.infinite(r$c4_med)) return("Recent movers")
  "Fast movers" }
reglas[, grupo := sapply(seq_len(.N), function(i) nombre_k(reglas[i]))]
print(reglas)
stopifnot(uniqueN(reglas$grupo) == 4)
gr[, grupo := reglas$grupo[match(k, reglas$k)]]
gr <- merge(gr, info[, .(ISO3_code, Location, pop23, region_sdg, subregion, ingreso)], by = "ISO3_code")
ORD <- c("Early movers", "Fast movers", "Recent movers", "Migration-led")
msg("Tamaños: %s", paste(ORD, gr[, .N, by = grupo][match(ORD, grupo), N], collapse = " · "))

ej <- function(g) gr[grupo == g][order(-pop23)][1:3]
v <- ej("Early movers")
anota("cluster_examples_early", "United States of America, Russian Federation, Japan (USA, RUS, JPN)",
      paste(v$Location, collapse = ", "), identical(v$ISO3_code, c("USA", "RUS", "JPN")),
      nota = sprintf("n Early = %d", gr[grupo == "Early movers", .N]))
v <- ej("Recent movers")
anota("cluster_examples_recent", "Pakistan, Nigeria, Ethiopia (PAK, NGA, ETH)",
      paste(v$Location, collapse = ", "), identical(v$ISO3_code, c("PAK", "NGA", "ETH")),
      nota = sprintf("n Recent = %d", gr[grupo == "Recent movers", .N]))
anota("k_clusters", 4, length(unique(cl)), length(unique(cl)) == 4,
      nota = "k fijado a priori en H9a (docs/hipotesis_preinscritas.md); comprobado que el k-means corre con k = 4")

# Medoide = país más cercano (euclídeo, espacio de los 32 rasgos) a la mediana
# coordenada a coordenada del grupo; y medoide PAM (mínima suma de distancias)
medoide <- function(g) { idx <- gr[grupo == g, ISO3_code]; M <- X[idx, , drop = FALSE]
  med <- apply(M, 2, median); idx[which.min(rowSums(sweep(M, 2, med)^2))] }
medoide_pam <- function(g) { idx <- gr[grupo == g, ISO3_code]; D <- as.matrix(dist(X[idx, , drop = FALSE]))
  idx[which.min(rowSums(D))] }
med_tab <- sapply(ORD, medoide); med_pam <- sapply(ORD, medoide_pam)
msg("Medoides (mediana): %s | (PAM): %s", paste(med_tab, collapse = ","), paste(med_pam, collapse = ","))

# Perfil con medianas entre países
pob_mundo23 <- mundo[Time == 2023, TPopulation1July]
ext <- pa[ISO3_code %in% G & Time %in% c(1950, 2023, 2050),
          .(ISO3_code, Time, TFR, Q5, LE65, MedianAgePop, TPopulation1July)]
ext <- merge(ext, sup[, .(ISO3_code, Time, LE60)], by = c("ISO3_code", "Time"), all.x = TRUE)
ancho <- dcast(ext, ISO3_code ~ Time, value.var = c("TFR", "Q5", "LE65", "LE60", "MedianAgePop", "TPopulation1July"))
perf <- merge(gr[, .(ISO3_code, grupo, pop23, cnmr0023)], ancho, by = "ISO3_code")
prof <- perf[, .(n = .N, pop_bn = sum(pop23) / 1e6, pct_pob_mundo = 100 * sum(pop23) / pob_mundo23,
                 q5_2023 = median(Q5_2023), le65_2023 = median(LE65_2023), le60_2023 = median(LE60_2023),
                 cambio_pob_2023_2050_pct = median(100 * (TPopulation1July_2050 / TPopulation1July_2023 - 1)),
                 medage_2023 = median(MedianAgePop_2023), medage_2050 = median(MedianAgePop_2050),
                 le60_2050 = median(LE60_2050), tfr_1950 = median(TFR_1950), tfr_2023 = median(TFR_2023),
                 cnmr_2000_23 = median(cnmr0023)), by = grupo][match(ORD, grupo)]
prof[, ejemplos := sapply(grupo, function(g) paste(ej(g)$ISO3_code, collapse = ", "))]
prof[, medoide := med_tab[grupo]]
print(prof)
nb_prof <- data.table(grupo = ORD, n = c(50, 51, 53, 7), pop_bn = c(1.44, 4.9, 1.67, 0.07),
  pct_pob_mundo = c(17.83, 60.55, 20.59, 0.81), q5_2023 = c(3.84, 16, 50.29, 6.33),
  le65_2023 = c(19.89, 16.38, 13.53, 18.35), le60_2023 = c(23.94, 20.3, 16.99, 22.99),
  cambio_pob_2023_2050_pct = c(-6.93, 15.19, 64.38, 39.79), medage_2023 = c(41.85, 29.27, 18.31, 31.23),
  medage_2050 = c(47.84, 38.16, 24.61, 32.26), le60_2050 = c(27.02, 22.83, 17.7, 26.22),
  tfr_1950 = c(2.99, 6.19, 6.43, 7.12), tfr_2023 = c(1.44, 1.98, 3.99, 1.82),
  cnmr_2000_23 = c(1.83, -0.88, -0.92, 22.62),
  ejemplos = c("USA, RUS, JPN", "IND, CHN, IDN", "PAK, NGA, ETH", "SAU, JOR, ARE"),
  medoide = c("SVN", "ECU", "CMR", "SAU"))
num_cols <- setdiff(names(nb_prof), c("grupo", "ejemplos", "medoide"))
dif <- sapply(num_cols, function(cc) max(abs(round(prof[[cc]], 2) - nb_prof[[cc]])))
ok_prof <- all(prof$n == nb_prof$n) && all(dif <= 0.011) && all(prof$ejemplos == nb_prof$ejemplos) &&
  all(prof$medoide == nb_prof$medoide)
fmt_prof <- function(p) paste(sapply(seq_len(nrow(p)), function(i) paste0(p$grupo[i], ": ",
  paste(sprintf("%s=%s", c(num_cols, "ejemplos", "medoide"),
                c(sapply(num_cols, function(cc) format(round(p[[cc]][i], 2), nsmall = 0)), p$ejemplos[i], p$medoide[i])),
        collapse = ", "))), collapse = " || ")
anota("cluster_profile", "ver valor del lote (Early n=50 ... Migration-led n=7)", fmt_prof(prof), ok_prof,
      nota = sprintf("Máx. |dif| por columna tras redondear a 2 decimales: %s; medoide = país más cercano a la mediana coordenada a coordenada (PAM: %s)",
                     paste(sprintf("%s %.2f", names(dif), dif)[dif > 0], collapse = "; "),
                     paste(med_pam, collapse = ",")))

# --- 7.2 Estabilidad por país (keep_share): 500 submuestras del 80 % ---------
# k-means re-ejecutado en cada submuestra (nstart = 20), etiquetas emparejadas
# con la partición de referencia por el algoritmo húngaro (clue::solve_LSAP).
ref <- setNames(gr$grupo, gr$ISO3_code)[rownames(X)]
set.seed(SEMILLA)
B_keep <- 500; n_sub <- round(0.8 * nrow(X))
cuenta <- setNames(numeric(nrow(X)), rownames(X)); veces <- cuenta
for (b in seq_len(B_keep)) {
  idx <- sample(rownames(X), n_sub)
  cb <- kmeans(X[idx, ], 4, nstart = 20)$cluster
  tab <- table(factor(ref[idx], levels = ORD), factor(cb, levels = 1:4))
  asig <- solve_LSAP(tab, maximum = TRUE)          # fila (grupo ref) -> columna (etiqueta nueva)
  etiqueta <- setNames(ORD, as.character(as.integer(asig)))
  mismo <- etiqueta[as.character(cb)] == ref[idx]
  cuenta[idx] <- cuenta[idx] + mismo; veces[idx] <- veces[idx] + 1
}
keep <- cuenta / veces
v <- 100 * mean(keep >= 0.8)
bord <- names(sort(keep[keep < 0.8]))
nb_bord <- c("KOR", "NPL", "CHL", "BWA", "GTM", "BOL", "ARM")
anota("share_keep_ge_0.8", "96 (95.65 = 154/161)", sprintf("%.2f (%d/161)", v, sum(keep >= 0.8)),
      round(v) %in% c(95, 96, 97), clara = TRUE,
      nota = sprintf("Aleatorio (nstart de las réplicas no documentado; uso 20). keep < 0.8: %s",
                     paste(sprintf("%s %.2f", bord, keep[bord]), collapse = ", ")))
anota("borderline_countries", paste(nb_bord, collapse = ", "), paste(bord, collapse = ", "),
      setequal(bord, nb_bord),
      nota = sprintf("Coinciden %d de 7; solo notebook: %s; solo aquí: %s. Aleatorio: los países cercanos a 0,8 pueden cambiar entre corridas",
                     length(intersect(bord, nb_bord)), paste(setdiff(nb_bord, bord), collapse = ","),
                     paste(setdiff(bord, nb_bord), collapse = ",")))

# --- 7.3 Jaccard bootstrap por grupo (B = 200, con reemplazo) ---------------
set.seed(SEMILLA)
B_j <- 200; J <- matrix(NA, B_j, 4, dimnames = list(NULL, ORD))
for (b in seq_len(B_j)) {
  i <- sample(nrow(X), replace = TRUE); iu <- unique(i)
  cb <- kmeans(X[i, ], 4, nstart = 10)$cluster
  cb_u <- cb[match(iu, i)]
  for (g in ORD) { A <- iu[ref[iu] == g]; if (!length(A)) next
    J[b, g] <- max(sapply(unique(cb_u), function(h) { Bh <- iu[cb_u == h]
      length(intersect(A, Bh)) / length(union(A, Bh)) })) }
}
jm <- colMeans(J, na.rm = TRUE)
anota("jaccard_max", "0.95 (0.949, Early movers)", sprintf("%.3f (%s)", max(jm), names(which.max(jm))),
      abs(max(jm) - 0.949) < 0.02 && names(which.max(jm)) == "Early movers",
      nota = sprintf("Medias por grupo: %s (aleatorio; tolerancia 0,02)", paste(sprintf("%s %.3f", ORD, jm), collapse = "; ")))

# --- 7.4 Voto regional (leave-one-out) --------------------------------------
voto <- gr[, { r <- sapply(seq_len(.N), function(i) { otros <- grupo[-i]
  if (!length(otros)) return(NA_character_)
  tb <- table(otros); top <- names(tb)[tb == max(tb)]
  if (length(top) > 1) return(paste0("EMPATE:", paste(top, collapse = "|"))) else top })
  .(ISO3_code, grupo, voto = r) }, by = region_sdg]
voto[, acierto := !is.na(voto) & voto == grupo]
voto[, acierto_emp := !is.na(voto) & (voto == grupo | (grepl("EMPATE", voto) & mapply(grepl, grupo, voto)))]
n_val <- voto[!is.na(voto), .N]
v <- voto[, sum(acierto)] / n_val
anota("region_vote_accuracy", "0.78 (0.775)", sprintf("%.4f (%d/%d)", v, voto[, sum(acierto)], n_val),
      abs(v - 0.775) < 0.005, clara = FALSE,
      nota = sprintf("Región con un solo país (sin voto LOO) excluida: %s; empates: %d (contando empate como acierto: %.3f; sobre 161: %.3f)",
                     paste(voto[is.na(voto), ISO3_code], collapse = ","), voto[grepl("EMPATE", voto), .N],
                     voto[, sum(acierto_emp)] / n_val, voto[, sum(acierto)] / 161))

# --- 7.5 Año del máximo de población (1950-2100) por grupo -------------------
pk <- pa[ISO3_code %in% G, .(pico = Time[which.max(TPopulation1July)]), by = ISO3_code]
pk <- merge(pk, gr[, .(ISO3_code, grupo)], by = "ISO3_code")
pkt <- pk[, .(n = .N, peaked_by_2023 = sum(pico <= 2023), peak_2024_2099 = sum(pico >= 2024 & pico <= 2099),
              no_peak_before_2100 = sum(pico == 2100), median_peak_year = median(as.numeric(pico))), by = grupo][match(ORD, grupo)]
nb_pk <- data.table(grupo = ORD, n = c(50, 51, 53, 7), peaked_by_2023 = c(30, 7, 0, 0),
                    peak_2024_2099 = c(16, 36, 10, 0), no_peak_before_2100 = c(4, 8, 43, 7),
                    median_peak_year = c(2021.5, 2058, 2100, 2100))
anota("peak_year_by_group", paste(apply(nb_pk, 1, paste, collapse = "/"), collapse = " || "),
      paste(apply(pkt, 1, paste, collapse = "/"), collapse = " || "),
      isTRUE(all.equal(as.data.frame(pkt), as.data.frame(nb_pk), check.attributes = FALSE)),
      nota = "Orden: grupo/n/peaked_by_2023/peak_2024_2099/no_peak_before_2100/median_peak_year; which.max (primer máximo)")

# --- 7.6 Velocidad 5 -> 3 (TFR suavizada, lambda = 10) -------------------------
v <- cr[ISO3_code == "CHN", c3 - c5]
anota("dur53_chn", "5 (5.1026)", sprintf("%.4f (c5 %.2f -> c3 %.2f)", v, cr[ISO3_code == "CHN", c5], cr[ISO3_code == "CHN", c3]),
      round(v) == 5 && abs(v - 5.1026) < 0.05)
sp <- gr[is.finite(c5)]
sp[, `:=`(dur = fifelse(is.finite(c3), c3 - c5, 2023 - c5), ev = as.integer(is.finite(c3)))]
kmg <- survfit(Surv(dur, ev) ~ grupo, data = sp)
mq <- quantile(kmg, 0.5)$quantile[, 1]
names(mq) <- sub("grupo=", "", names(mq))
mq <- mq[ORD]
nb_sp <- c(14.9, 19.2, 29.6, 18.0)
anota("speed53_median_by_group", "Early 14.9; Fast 19.2; Recent 29.6; Migration-led 18.0",
      paste(sprintf("%s %.2f (n %d, ev %d)", ORD, mq, sp[, .N, by = grupo][match(ORD, grupo), N],
                    sp[, sum(ev), by = grupo][match(ORD, grupo), V1]), collapse = "; "),
      all(abs(round(mq, 1) - nb_sp) <= 0.051) && nrow(sp) == 102,
      nota = sprintf("n total %d con cruce de 5 observado; mediana KM de survfit", nrow(sp)))

# --- 7.7 Tabla de recomendaciones (rec_rows) ----------------------------------
mayoria <- function(iso) { g <- gr[ISO3_code %in% iso, grupo]; tb <- sort(table(g), decreasing = TRUE)
  sprintf("%s (%d of %d)", names(tb)[1], tb[1], length(g)) }
q5w <- dcast(pa[Time %in% c(2015, 2023, 2030)], ISO3_code ~ Time, value.var = "Q5")
setnames(q5w, c("ISO3_code", "q15", "q23", "q30"))
q5w[, `:=`(obs = (log(q15) - log(q23)) / 8, nec = (log(q23) - log(25)) / 7)]
alto <- q5w[q23 > 25]
r1 <- sprintf("above25=%d; stay above 2030=%d; on pace=%d; road %s", nrow(alto), alto[q30 > 25, .N],
              alto[obs >= nec, .N], mayoria(alto$ISO3_code))
r2 <- sprintf("momentum=%d, %.2f bn, top3 %s; road %s", nrow(mom), sum(mom$TPopulation1July) / 1e6,
              paste(mom[pob_1m == TRUE][order(-pop23)][1:3, Location], collapse = "/"), mayoria(mom$ISO3_code))
nn23 <- d23[NatChange < 0]; nn50 <- pa[Time == 2050 & NatChange < 0]
chn <- ov[ISO3_code == "CHN" & Time == 2050 & Variant %in% c("Lower 95 PI", "Upper 95 PI"), TPopulation1July] / 1e6
r3 <- sprintf("natneg2023=%d, %.1f%% world; natneg2050=%d; CHN2050 %.2f bn [%.2f-%.2f]; road %s", nrow(nn23),
              100 * sum(nn23$TPopulation1July) / pob_mundo23, nrow(nn50),
              pa[ISO3_code == "CHN" & Time == 2050, TPopulation1July] / 1e6, min(chn), max(chn), mayoria(nn23$ISO3_code))
tc <- d23[tipo == "C"]
r4 <- sprintf("typeC=%d, top3 %s; road %s", nrow(tc), paste(tc[pob_1m == TRUE][order(-pop23)][1:3, Location], collapse = "/"),
              mayoria(tc$ISO3_code))
te <- d23[tipo == "E"]
r5 <- sprintf("typeE=%d, top3 %s; road %s", nrow(te), paste(te[pob_1m == TRUE][order(-pop23)][1:3, Location], collapse = "/"),
              mayoria(te$ISO3_code))
ok_rec <- nrow(alto) == 70 && alto[q30 > 25, .N] == 58 && alto[obs >= nec, .N] == 8 &&
  mayoria(alto$ISO3_code) == "Recent movers (50 of 62)" && nrow(mom) == 22 &&
  mayoria(mom$ISO3_code) == "Fast movers (13 of 13)" && nrow(nn23) == 53 &&
  round(100 * sum(nn23$TPopulation1July) / pob_mundo23) == 28 && nrow(nn50) == 106 &&
  round(pa[ISO3_code == "CHN" & Time == 2050, TPopulation1July] / 1e6, 2) == 1.26 &&
  round(min(chn), 2) == 1.16 && round(max(chn), 2) == 1.35 && mayoria(nn23$ISO3_code) == "Early movers (33 of 35)" &&
  nrow(tc) == 18 && mayoria(tc$ISO3_code) == "Early movers (11 of 11)" && nrow(te) == 19 &&
  mayoria(te$ISO3_code) == "Fast movers (4 of 6)"
anota("rec_rows", "58/70, 8 on pace, Recent 50/62 | 22, 2.2 bn, Fast 13/13 | 53, 28 %, 106, CHN 1.26 [1.16-1.35], Early 33/35 | 18, Early 11/11 | 19, Fast 4/6",
      paste(r1, r2, r3, r4, r5, sep = " | "), ok_rec,
      nota = "Ritmo observado = ln(Q5_2015/Q5_2023)/8; necesario = ln(Q5_2023/25)/7 (tasa anual de reducción); texto (verbos, mandatos, agencias) no verificable numéricamente")

# =============================================================================
# 8. P8: PCA, análisis paralelo y look-alikes (2023, 161 países >= 1 M)
# =============================================================================
VARS12 <- c("TFR", "CBR", "LEx", "LE65", "Q5", "Q1560", "CDR", "MedianAgePop",
            "PopGrowthRate", "CNMR", "PopSexRatio", "PopDensity")
P <- s23[, c("ISO3_code", VARS12), with = FALSE]
lw <- mean(P$CNMR) + c(-3, 3) * sd(P$CNMR)
msg("Winsorización CNMR 2023: [%.1f; %.1f], países recortados: %s", lw[1], lw[2],
    paste(P[CNMR < lw[1] | CNMR > lw[2], ISO3_code], collapse = ","))
P[, CNMR := pmin(pmax(CNMR, lw[1]), lw[2])]
P[, PopDensity := log(PopDensity)]                # densidad en log (plan §4-Q2)
M12 <- as.matrix(P[, ..VARS12]); rownames(M12) <- P$ISO3_code
Z <- scale(M12)
pc <- prcomp(Z)
ve <- pc$sdev^2 / sum(pc$sdev^2)
pc1_f <- function(iso) { p <- prcomp(scale(M12[iso, ])); p$sdev[1]^2 / sum(p$sdev^2) }
ci <- 100 * boot_bloques(rownames(M12), pc1_f)
anota("pc1_var", "56.7 [51.4; 62.6] (56.6735)", sprintf("%.4f [%.1f; %.1f]", 100 * ve[1], ci[1], ci[2]),
      abs(100 * ve[1] - 56.6735) < 0.05 && 100 * ve[1] >= 51.45 && 100 * ve[1] <= 62.56,
      nota = sprintf("PC2 %.1f %%; autovalores %s", 100 * ve[2], paste(round(pc$sdev[1:4]^2, 2), collapse = "/")))

set.seed(SEMILLA)
nulo <- replicate(1000, eigen(cor(apply(Z, 2, sample)), only.values = TRUE)$values)
u95 <- apply(nulo, 1, quantile, 0.95)
nd <- sum(cumprod(pc$sdev^2 > u95))
anota("n_dims_parallel", 2, nd, nd == 2,
      nota = sprintf("p95 nulo %s vs autovalores %s", paste(round(u95[1:3], 2), collapse = "/"),
                     paste(round(pc$sdev[1:3]^2, 2), collapse = "/")))

# Look-alikes: 5 vecinos más cercanos en los 12 indicadores z vs por TFR sola
Df <- as.matrix(dist(Z)); Ds <- as.matrix(dist(Z[, "TFR", drop = FALSE]))
diag(Df) <- Inf; diag(Ds) <- Inf
vec <- function(D, i, k = 5) colnames(D)[order(D[i, ])[1:k]]
comp <- sapply(seq_len(nrow(Z)), function(i) length(intersect(vec(Df, i), vec(Ds, i))) / 5)
names(comp) <- rownames(Z)
v <- 100 * mean(comp)
ci <- 100 * boot_bloques(names(comp), function(iso) mean(comp[iso]))
anota("knn_tfr", "13 [9; 18] (13.1677)", sprintf("%.4f [%.1f; %.1f]", v, ci[1], ci[2]),
      abs(v - 13.1677) < 0.05 && v >= 8.61 && v <= 17.69,
      nota = sprintf("azar k/(n-1) = %.1f %%", 100 * 5 / 160))
icol <- which(rownames(Z) == "COL")
v <- vec(Ds, icol)
anota("lookalikes_col_tfr_iso", "FRA, AUS, TUR, USA, NZL", paste(v, collapse = ", "),
      identical(v, c("FRA", "AUS", "TUR", "USA", "NZL")),
      nota = sprintf("12 indicadores: %s; |dTFR|: %s", paste(vec(Df, icol), collapse = ", "),
                     paste(round(Ds[icol, v] * attr(Z, "scaled:scale")["TFR"], 3), collapse = "/")))

# =============================================================================
# 9. Dependencia espacial: W = 5 vecinos más cercanos (haversine entre puntos
#    de etiqueta de Natural Earth 1:50m), fila-estandarizada
# =============================================================================
ne <- as.data.table(sf::st_drop_geometry(sf::st_as_sf(rnaturalearthdata::countries50)))
ne[, iso := fifelse(iso_a3_eh != "-99", iso_a3_eh, fifelse(iso_a3 != "-99", iso_a3, adm0_a3))]
ne[adm0_a3 == "KOS", iso := "XKX"]
ne <- ne[order(-(adm0_a3 == iso))][!duplicated(iso)]   # fila principal (p. ej. AUS sin territorios)
coord <- ne[match(G, iso), .(ISO3_code = G, lon = label_x, lat = label_y)]
stopifnot(!anyNA(coord$lon))
haversine <- function(lon, lat) { r <- pi / 180; la <- lat * r; lo <- lon * r
  dla <- outer(la, la, "-"); dlo <- outer(lo, lo, "-")
  a <- sin(dla / 2)^2 + outer(cos(la), cos(la)) * sin(dlo / 2)^2
  2 * 6371 * asin(pmin(sqrt(a), 1)) }   # pmin conserva dim del 1.er argumento
W_knn <- function(D, k = 5) { diag(D) <- Inf
  t(apply(D, 1, function(r) { w <- numeric(length(r)); w[order(r)[1:k]] <- 1 / k; w })) }
moran <- function(x, W) { z <- x - mean(x); (length(x) / sum(W)) * sum(z * (W %*% z)) / sum(z^2) }

sin_golfo <- coord[!ISO3_code %in% GOLFO]
Dng <- haversine(sin_golfo$lon, sin_golfo$lat); Wng <- W_knn(Dng)
x <- d23$CNMR[match(sin_golfo$ISO3_code, d23$ISO3_code)]
v <- moran(x, Wng)
Dall <- haversine(coord$lon, coord$lat); Wall <- W_knn(Dall)
anota("moran_cnmr_2023_nogulf", "-0.03 (-0.0283)", sprintf("%.4f (n=%d)", v, length(x)),
      abs(v - (-0.0283)) < 0.005 && length(x) == 155,
      nota = sprintf("con Golfo (161): %.4f; TFR 2023: %.3f", moran(d23$CNMR[match(G, d23$ISO3_code)], Wall),
                     moran(d23$TFR[match(G, d23$ISO3_code)], Wall)))

# LISA (Anselin 1995) de la CNMR media 2010-2023, permutación condicional
# (B = 999), p bilateral por pliegue (folded), FDR Benjamini-Hochberg al 5 %
cm <- est[ISO3_code %in% G & Time >= 2010, .(x = mean(CNMR)), by = ISO3_code][match(G, ISO3_code)]
z <- (cm$x - mean(cm$x)) / sd(cm$x)
lag_z <- as.vector(Wall %*% z)
Ii <- z * lag_z
set.seed(SEMILLA)
n <- length(z); B_l <- 999
p_l <- sapply(seq_len(n), function(i) {
  otros <- z[-i]
  sim <- z[i] * replicate(B_l, mean(sample(otros, 5)))        # 5 vecinos con peso 1/5
  (1 + sum(if (Ii[i] >= 0) sim >= Ii[i] else sim <= Ii[i])) / (B_l + 1) })
p_adj <- p.adjust(p_l, "BH")
quad <- fifelse(z > 0 & lag_z > 0, "HH", fifelse(z < 0 & lag_z < 0, "LL", fifelse(z > 0, "HL", "LH")))
hh <- G[quad == "HH" & p_adj < 0.05]
# Variante: p bilateral 2·min (más conservadora)
p2 <- pmin(1, 2 * p_l); hh2 <- G[quad == "HH" & p.adjust(p2, "BH") < 0.05]
anota("lisa_cnmr_hh_fdr", "7 (ARE, BHR, IRN, KWT, OMN, QAT, SAU)", sprintf("%d (%s)", length(hh), paste(sort(hh), collapse = ", ")),
      length(hh) == 7 && setequal(hh, c("ARE", "BHR", "IRN", "KWT", "OMN", "QAT", "SAU")), clara = FALSE,
      nota = sprintf("p 'folded' de un lado (GeoDa); con p bilateral 2·min: %d (%s). Todos los cuadrantes tras FDR: %s; sin corregir p<0.05: %d",
                     length(hh2), paste(sort(hh2), collapse = ","),
                     paste(sprintf("%s(%s)", G[p_adj < 0.05], quad[p_adj < 0.05]), collapse = " "), sum(p_l < 0.05)))

# =============================================================================
# 10. Panel fecundidad - mortalidad infantil (P7)
# =============================================================================
an <- est[ISO3_code %in% G, .(ISO3_code, Time, TFR, lQ5 = log(Q5), ingreso, region_sdg, subregion)]
# 10.1 Entre países: medias 1950-2023 por país; pendiente x ln 0,5
bt <- an[, .(TFR = mean(TFR), lQ5 = mean(lQ5)), by = ISO3_code]
f_bt <- function(iso) { x <- bt[match(iso, bt$ISO3_code)]; coef(lm(TFR ~ lQ5, x))[2] * log(0.5) }
v <- f_bt(bt$ISO3_code); ci <- boot_bloques(bt$ISO3_code, f_bt)
anota("panel_between_halfq5", "-1.05 [-1.17; -0.92] (-1.0523)", sprintf("%.4f [%.2f; %.2f]", v, ci[1], ci[2]),
      abs(v - (-1.0523)) < 0.005 && v >= -1.1698 && v <= -0.9153,
      nota = "media de log Q5 anual por país; lm entre países")

# 10.2 Dentro del país: medias quinquenales, cambios, rezagos 0-4 (0-20 años),
#      FE país + periodo, EE agrupados por país; cambios 1975-2023
q <- an[, .(TFR = mean(TFR), lQ5 = mean(lQ5)), by = .(ISO3_code, ingreso, region_sdg, subregion, periodo = 5L * (Time %/% 5L))]
setorder(q, ISO3_code, periodo)
q[, `:=`(dTFR = TFR - shift(TFR), dlQ5 = lQ5 - shift(lQ5)), by = ISO3_code]
q[, `:=`(L0 = dlQ5, L1 = shift(dlQ5, 1), L2 = shift(dlQ5, 2), L3 = shift(dlQ5, 3), L4 = shift(dlQ5, 4)), by = ISO3_code]
qe <- q[periodo >= 1975]
stopifnot(uniqueN(q$periodo) == 15, nrow(qe) == 1610, !anyNA(qe[, .(dTFR, L0, L1, L2, L3, L4)]))
fml <- dTFR ~ L0 + L1 + L2 + L3 + L4 | ISO3_code + periodo
suma_half <- function(dt) { m <- feols(fml, dt, cluster = ~ISO3_code, notes = FALSE, warn = FALSE)
  sum(coef(m)[paste0("L", 0:4)]) * log(0.5) }
v_all <- suma_half(qe)
v_lm <- suma_half(qe[ingreso == "Lower middle income"])
iso_lm <- unique(qe[ingreso == "Lower middle income", ISO3_code])
ci_lm <- boot_bloques(iso_lm, function(iso) {
  dd <- rbindlist(lapply(seq_along(iso), function(j) qe[ISO3_code == iso[j]][, ISO3_code := paste0(ISO3_code, "_", j)]))
  suma_half(dd) })
anota("panel_lowmid_halfq5", "0.07 [-0.56; 0.65] (0.0695)", sprintf("%.4f [%.2f; %.2f] (n países %d, N %d)", v_lm, ci_lm[1], ci_lm[2],
      length(iso_lm), qe[ingreso == "Lower middle income", .N]),
      abs(v_lm - 0.0695) < 0.005 && v_lm >= -0.5599 && v_lm <= 0.6488,
      nota = sprintf("Todos los 161: %.4f; bloques = %d subregiones; país repetido en bootstrap = nuevo efecto fijo",
                     v_all, uniqueN(info[ISO3_code %in% iso_lm, subregion])))
v_ssa <- suma_half(qe[region_sdg == "Sub-Saharan Africa"])
anota("panel_ssa_halfq5", "-1.20 (-1.1974)", sprintf("%.4f (n países %d)", v_ssa, uniqueN(qe[region_sdg == "Sub-Saharan Africa", ISO3_code])),
      abs(v_ssa - (-1.1974)) < 0.005)

# =============================================================================
# 11. Fecha del archivo de hipótesis (solo lectura de git, filtro literal de la clave)
# =============================================================================
fh <- tryCatch(system2("git", c("-C", RAIZ, "log", "-1", "--date=short", "--format=%ad", "--",
                                "docs/hipotesis_preinscritas.md"), stdout = TRUE), error = function(e) NA_character_)
limpio <- tryCatch(length(system2("git", c("-C", RAIZ, "status", "--porcelain", "--",
                                           "docs/hipotesis_preinscritas.md"), stdout = TRUE)) == 0, error = function(e) NA)
anota("hyp_file_date", "2026-10-23", fh, identical(fh, "2026-10-23"),
      nota = sprintf("Árbol sin cambios en el archivo desde ese commit: %s; el archivo dice 'redacción 2026-10-22'; no existe docs/hipotesis_preinscritas.sha256 (make prereg pendiente)",
                     limpio))

# =============================================================================
# 12. Salida
# =============================================================================
tab <- rbindlist(res)
fwrite(tab, file.path(RAIZ, "docs/qa/verificacion_lote_4_resultados.csv"))
msg("\n==== RESUMEN: %d claves, %d coinciden, %d no coinciden ====", nrow(tab), sum(tab$coincide), sum(!tab$coincide))
print(tab[coincide == FALSE])
msg("Tiempo total: %.1f s", as.numeric(difftime(Sys.time(), t0, units = "secs")))
sessionInfo()
