#!/usr/bin/env Rscript
# =============================================================================
# verificacion_lote_3.R  (agente "verificador-3", QA independiente)
#
# Recalcula DESDE LOS DATOS CRUDOS cada cifra del lote 3 de figures/numbers.json
# sin usar los scripts del repositorio (no hace source de R/0*.R ni lee
# data/processed/*.parquet). Solo usa:
#   - ../WPP2024_Demographic_Indicators_Medium_csv.gz        (crudo ONU)
#   - ../WPP2024_Demographic_Indicators_OtherVariants_csv.gz (crudo ONU, IP)
#   - data/processed/lookup_regiones.csv  (solo región SDG y subregión)
#   - data/raw/wb_api_income_2026-10-22.csv (ingreso Banco Mundial FY2027)
#   - rnaturalearth (puntos de etiqueta de Natural Earth para la matriz W)
#
# Reglas: países = ISO3_code no vacío; estimaciones <= 2023, proyección
# Medium >= 2024 separadas; semilla 2026 antes de cada bloque aleatorio;
# lenguaje descriptivo (sin causalidad).
#
# Uso: Rscript docs/qa/verificacion_lote_3.R   (desde la raíz del repositorio)
# Salida: docs/qa/verificacion_lote_3_resultados.csv (clave, valor notebook,
#         valor independiente, coincide, nota)
# =============================================================================

suppressPackageStartupMessages({
  library(data.table)
  library(cluster)
  library(fda)
  library(fixest)
  library(survival)
  library(mclust)
})

RAIZ <- "/home/darkns/Documents/ASA_Dataquest/RepoGithub"
RUTA_MEDIUM <- file.path(dirname(RAIZ), "WPP2024_Demographic_Indicators_Medium_csv.gz")
RUTA_OTRAS  <- file.path(dirname(RAIZ), "WPP2024_Demographic_Indicators_OtherVariants_csv.gz")
RUTA_LOOKUP <- file.path(RAIZ, "data/processed/lookup_regiones.csv")
RUTA_WB     <- file.path(RAIZ, "data/raw/wb_api_income_2026-10-22.csv")
SALIDA      <- file.path(RAIZ, "docs/qa/verificacion_lote_3_resultados.csv")
SEMILLA <- 2026
B_BOOT  <- 2000
RNGkind("Mersenne-Twister", "Inversion", "Rejection")

# Acumulador de resultados ----------------------------------------------------
res <- list()
anotar <- function(clave, notebook, indep, coincide, nota = "", def_clara = TRUE) {
  res[[clave]] <<- data.table(clave = clave, valor_notebook = notebook,
                              valor_independiente = indep, coincide = coincide,
                              definicion_clara = def_clara, nota = nota)
  cat(sprintf("[%s] %s | nb: %s | indep: %s | %s\n", if (coincide) "OK" else "XX",
              clave, notebook, indep, nota))
}
f2 <- function(x, d = 2) formatC(x, format = "f", digits = d)

# =============================================================================
# 1. Datos crudos
# =============================================================================
cat("Leyendo crudo Medium...\n")
med <- fread(RUTA_MEDIUM, encoding = "UTF-8", showProgress = FALSE)
setnames(med, 1, "SortOrder")                       # quita el BOM del primer nombre
med <- med[Time <= 2100]                             # 2101 se descarta
mundo <- med[Location == "World" & Time == 2023]
pais  <- med[!is.na(ISO3_code) & ISO3_code != ""]   # países y áreas (237)
stopifnot(uniqueN(pais$ISO3_code) == 237)

lk <- fread(RUTA_LOOKUP)[, .(ISO3, region_sdg, subregion)]
wb <- fread(RUTA_WB)[, .(ISO3, ingreso = ingreso_api)]
pais <- merge(pais, lk, by.x = "ISO3_code", by.y = "ISO3", all.x = TRUE)
pais <- merge(pais, wb, by.x = "ISO3_code", by.y = "ISO3", all.x = TRUE)
pais[is.na(ingreso) | ingreso == "Aggregates", ingreso := "Not classified"]
stopifnot(!anyNA(pais$region_sdg))
setkey(pais, ISO3_code, Time)

p23 <- pais[Time == 2023]
grandes <- p23[TPopulation1July >= 1000, ISO3_code]  # >= 1 M (miles de personas)
stopifnot(length(grandes) == 161)
g23 <- p23[ISO3_code %in% grandes]
setkey(g23, ISO3_code)
est <- pais[Time <= 2023]                            # solo estimaciones
est_g <- est[ISO3_code %in% grandes]

# =============================================================================
# 2. Conteos 2023/2050 y tipos de palanca (237 países y áreas; censo, sin IC)
# =============================================================================
# Tipos (definición del plan v2 §3): A Nat>0 Mig>0 Pop>0 · B Nat>0 Mig<=0 Pop>0 ·
# C Nat<0 Pop>0 · D Nat<0 Pop<0 · E Nat>0 Pop<0
p23[, tipo := fcase(NatChange > 0 & PopChange > 0 & NetMigrations > 0, "A",
                    NatChange > 0 & PopChange > 0 & NetMigrations <= 0, "B",
                    NatChange < 0 & PopChange > 0, "C",
                    NatChange < 0 & PopChange < 0, "D",
                    NatChange > 0 & PopChange < 0, "E", default = NA_character_)]
cat("Tipos 2023 (237):\n"); print(table(p23$tipo, useNA = "ifany"))
cat("Tipos 2023 (>= 1 M):\n"); print(table(p23[ISO3_code %in% grandes]$tipo, useNA = "ifany"))
g23 <- merge(g23, p23[, .(ISO3_code, tipo)], by = "ISO3_code")

n_ab <- p23[tipo %in% c("A", "B"), .N]
anotar("n_type_AB", "165", n_ab, n_ab == 165, "NatChange > 0 & PopChange > 0, 2023, 237")
n_e <- p23[tipo == "E", .N]
anotar("n_type_E", "19", n_e, n_e == 19, "NatChange > 0 & PopChange < 0, 2023, 237")
n_c <- p23[NatChange < 0 & PopChange > 0, .N]
anotar("n_grow_only_migration_2023", "18", n_c, n_c == 18, "NatChange < 0 & PopChange > 0, 2023, 237")
n_shr <- p23[PopChange < 0, .N]
anotar("n_shrinking_2023", "54", n_shr, n_shr == 54,
       sprintf("PopChange < 0, 2023, 237 (>= 1 M: %d)", p23[PopChange < 0 & ISO3_code %in% grandes, .N]))
n_brng <- p23[TFR < 2.1 & NatChange > 0 & PopChange > 0, .N]
anotar("n_below_repl_natural_growth_2023", "66", n_brng, n_brng == 66,
       sprintf("TFR < 2.1 & NatChange > 0 & PopChange > 0; bajo reemplazo = %d, de ellos crecen = %d",
               p23[TFR < 2.1, .N], p23[TFR < 2.1 & PopChange > 0, .N]))
n_mom <- p23[TFR < 2.1 & tipo == "B", .N]
anotar("n_momentum_countries", "22", n_mom, n_mom == 22,
       sprintf("TFR < 2.1 & tipo B; con NetMigrations < 0 estricto: %d; pob 2023 = %.2f mil M",
               p23[TFR < 2.1 & NatChange > 0 & PopChange > 0 & NetMigrations < 0, .N],
               p23[TFR < 2.1 & tipo == "B", sum(TPopulation1July)] / 1e6))
n50 <- pais[Time == 2050 & NatChange < 0, .N]
anotar("n_natneg_2050", "106", n50, n50 == 106, "NatChange < 0 en 2050 (proyección Medium, escenario), 237")
n_ssa <- p23[region_sdg == "Sub-Saharan Africa", .N]
# Comprobación cruzada con las subregiones M49 de África subsahariana
n_ssa_m49 <- p23[subregion %in% c("Eastern Africa", "Middle Africa", "Southern Africa",
                                  "Western Africa"), .N]
anotar("n_ssa", "51", n_ssa, n_ssa == 51 && n_ssa_m49 == 51,
       sprintf("región SDG = Sub-Saharan Africa (lookup); por subregiones M49 E/M/S/W Africa = %d; >= 1 M = %d",
               n_ssa_m49, p23[region_sdg == "Sub-Saharan Africa" & ISO3_code %in% grandes, .N]))

# Ejemplos por regla: los 3 más poblados >= 1 M de cada tipo
top3 <- function(dt, n = 3) dt[order(-TPopulation1July)][1:n]
ejC <- top3(g23[tipo == "C"])
anotar("examples_type_C", "Germany, Spain, Belgium", paste(ejC$Location, collapse = ", "),
       identical(ejC$Location, c("Germany", "Spain", "Belgium")),
       sprintf("ISO3 %s; n tipo C >= 1 M = %d", paste(ejC$ISO3_code, collapse = "/"), g23[tipo == "C", .N]))
anotar("cover_flags", "DE, ES, BE", paste(ejC$ISO2_code, collapse = ", "),
       identical(ejC$ISO2_code, c("DE", "ES", "BE")), "ISO2_code del crudo WPP para examples_type_C")
ejE <- top3(g23[tipo == "E"])
anotar("examples_type_E", "Nepal, Azerbaijan, Uruguay", paste(ejE$Location, collapse = ", "),
       identical(ejE$Location, c("Nepal", "Azerbaijan", "Uruguay")),
       sprintf("n tipo E >= 1 M = %d: %s", g23[tipo == "E", .N],
               paste(g23[tipo == "E"][order(-TPopulation1July)]$ISO3_code, collapse = ",")))

# Mundo 2023
wp <- mundo$TPopulation1July / 1e6
wsum <- p23[, sum(TPopulation1July)] / 1e6
anotar("world_pop_2023_bn", "8.1 billion", sprintf("%.4f (suma 237: %.4f)", wp, wsum),
       round(wp, 1) == 8.1 && abs(wp - wsum) / wp < 1e-6, "agregado World, TPopulation1July 2023")

# EAU: crecimiento 2023 y gemelo
are_g <- p23[ISO3_code == "ARE", PopGrowthRate]
anotar("growth_are_2023", "3.70 % per year", f2(are_g, 3), round(are_g, 2) == 3.70, "PopGrowthRate ARE 2023")
anotar("twin_growth_are", "+3.70%", f2(are_g, 3), round(are_g, 2) == 3.70, "PopGrowthRate ARE 2023")

# Portugal vs Chad
lex_gap <- p23[ISO3_code == "PRT", LEx] - p23[ISO3_code == "TCD", LEx]
anotar("lex_gap_prt_tcd", "27 years", f2(lex_gap, 4), round(lex_gap) == 27,
       sprintf("LEx PRT %.2f vs TCD %.2f; CDR %.2f vs %.2f", p23[ISO3_code == "PRT", LEx],
               p23[ISO3_code == "TCD", LEx], p23[ISO3_code == "PRT", CDR], p23[ISO3_code == "TCD", CDR]))

# China: edad mediana 30 -> 40 (primer año >= 30 y primer año >= 40)
chn <- pais[ISO3_code == "CHN"]
a30 <- chn[MedianAgePop >= 30, min(Time)]; a40 <- chn[MedianAgePop >= 40, min(Time)]
anotar("yrs_medage30_40_chn", "23 years", sprintf("%d (%d -> %d)", a40 - a30, a30, a40),
       a40 - a30 == 23, "primer año con MedianAgePop >= 30 y >= 40; 40 cae en proyección Medium")

# =============================================================================
# 3. Bootstrap por bloques de subregión ONU (función propia, percentil)
# =============================================================================
# dt: una fila por país con columna `subregion`; estad: función(dt) -> número.
# Se remuestrean subregiones con reemplazo y se toman todos sus países.
boot_bloques <- function(dt, estad, B = B_BOOT, semilla = SEMILLA) {
  set.seed(semilla)
  sub <- unique(dt$subregion)
  idx <- split(seq_len(nrow(dt)), dt$subregion)
  v <- vapply(seq_len(B), function(b) {
    s <- sample(sub, length(sub), replace = TRUE)
    out <- tryCatch(estad(dt[unlist(idx[s], use.names = FALSE)]), error = function(e) NA_real_)
    if (length(out) != 1) NA_real_ else out
  }, numeric(1))
  c(lo = unname(quantile(v, 0.025, na.rm = TRUE)), hi = unname(quantile(v, 0.975, na.rm = TRUE)),
    n_na = sum(is.na(v)))
}

# =============================================================================
# 4. Participaciones por grupo de ingreso FY2027 (sumas de personas)
# =============================================================================
s0023 <- est[Time %between% c(2000, 2023),
             .(nat = sum(NatChange), mig = sum(NetMigrations), dpop = sum(PopChange)),
             by = .(ISO3_code, ingreso, subregion)]
s1023 <- est[Time %between% c(2010, 2023),
             .(nat = sum(NatChange), mig = sum(NetMigrations), dpop = sum(PopChange)),
             by = .(ISO3_code, ingreso, subregion)]

sh_chn <- 100 * s0023[ISO3_code == "CHN", nat] / s0023[ingreso == "Upper middle income", sum(nat)]
anotar("china_share_natchange_upmid", "30%", f2(sh_chn, 2), round(sh_chn) == 30,
       sprintf("n países medio-alto = %d; China = %.1f %% de la población 2023 del grupo",
               s0023[ingreso == "Upper middle income", .N],
               100 * p23[ISO3_code == "CHN", TPopulation1July] / p23[ingreso == "Upper middle income", sum(TPopulation1July)]))
sh_ind <- 100 * s0023[ISO3_code == "IND", nat] / s0023[ingreso == "Lower middle income", sum(nat)]
anotar("india_share_natchange_lowmid", "40%", f2(sh_ind, 2), round(sh_ind) == 40,
       sprintf("n países medio-bajo = %d; India = %.1f %% de la población 2023 del grupo",
               s0023[ingreso == "Lower middle income", .N],
               100 * p23[ISO3_code == "IND", TPopulation1July] / p23[ingreso == "Lower middle income", sum(TPopulation1July)]))

# Migración / crecimiento en medio-alto 2000-2023 (+ IC por bloques)
cuota <- function(d) 100 * sum(d$mig) / sum(d$dpop)
um <- s0023[ingreso == "Upper middle income"]
sh_um <- cuota(um)
ci_um <- boot_bloques(um, cuota)
anotar("share_mig_upmid_2000_2023", "-4.6% · IC [-14.9; 0.5]",
       sprintf("%.2f%% · IC [%.1f; %.1f] (B=%d, %d subregiones)", sh_um, ci_um["lo"], ci_um["hi"],
               B_BOOT, uniqueN(um$subregion)),
       round(sh_um, 1) == -4.6 && abs(ci_um["lo"] - (-14.9)) < 2 && abs(ci_um["hi"] - 0.5) < 1.5,
       "sum NetMigrations / sum PopChange, 2000-2023, 59 países medio-alto FY2027")

# Ingreso alto: 2 listas x 2 periodos
hi_fy00 <- cuota(s0023[ingreso == "High income"]); hi_fy10 <- cuota(s1023[ingreso == "High income"])
agr <- med[(is.na(ISO3_code) | ISO3_code == "") & Location == "High-income countries"]
stopifnot(nrow(agr) > 0)
hi_un00 <- agr[Time %between% c(2000, 2023), 100 * sum(NetMigrations) / sum(PopChange)]
hi_un10 <- agr[Time %between% c(2010, 2023), 100 * sum(NetMigrations) / sum(PopChange)]
rg <- range(c(hi_fy00, hi_fy10, hi_un00, hi_un10))
anotar("share_mig_high_sens_range", "64–78%",
       sprintf("%.0f–%.0f%% (FY2027 00-23 %.1f; FY2027 10-23 %.1f; ONU 00-23 %.1f; ONU 10-23 %.1f)",
               rg[1], rg[2], hi_fy00, hi_fy10, hi_un00, hi_un10),
       round(rg[1]) == 64 && round(rg[2]) == 78,
       sprintf("FY2027: %d países de ingreso alto en WPP; agregado ONU 'High-income countries' (clasificación BM mayo 2024)",
               s0023[ingreso == "High income", .N]))

# =============================================================================
# 5. Intervalos de predicción de la ONU (OtherVariants, Lower 95 PI)
# =============================================================================
otras <- fread(RUTA_OTRAS, encoding = "UTF-8", showProgress = FALSE,
               select = c("ISO3_code", "Location", "Variant", "Time", "TPopulation1July"))
l95 <- otras[Variant == "Lower 95 PI" & Time == 2050 & ISO3_code %in% c("ARE", "CHN")]
u95 <- otras[Variant == "Upper 95 PI" & Time == 2050 & ISO3_code %in% c("ARE", "CHN")]
are_l <- l95[ISO3_code == "ARE", TPopulation1July] / 1e3
chn_l <- l95[ISO3_code == "CHN", TPopulation1July] / 1e6
anotar("pop_are_2050_pi95_low", "8.9 million", sprintf("%.4f M (U95 %.1f M)", are_l,
       u95[ISO3_code == "ARE", TPopulation1July] / 1e3), round(are_l, 1) == 8.9,
       "OtherVariants, Variant 'Lower 95 PI', TPopulation1July 2050")
anotar("pop_chn_2050_pi95_low", "1.16 billion", sprintf("%.4f bn (U95 %.2f bn)", chn_l,
       u95[ISO3_code == "CHN", TPopulation1July] / 1e6), round(chn_l, 2) == 1.16,
       "OtherVariants, Variant 'Lower 95 PI', TPopulation1July 2050")
rm(otras); invisible(gc())

# =============================================================================
# 6. Dispersión entre países 2023 (161 >= 1 M; IC por bloques de subregión)
# =============================================================================
sd_lex <- sd(g23$LEx)
ci_sd <- boot_bloques(g23, function(d) sd(d$LEx))
anotar("sd_lex_2023", "7.4 years · IC [5.6; 8.3]",
       sprintf("%.3f · IC [%.2f; %.2f]", sd_lex, ci_sd["lo"], ci_sd["hi"]),
       round(sd_lex, 1) == 7.4 && abs(ci_sd["lo"] - 5.6) < 0.4 && abs(ci_sd["hi"] - 8.3) < 0.4,
       sprintf("sd() con n-1; 237 países: %.2f", sd(p23$LEx)))
cv_lex <- 100 * sd(g23$LEx) / mean(g23$LEx)
ci_cv <- boot_bloques(g23, function(d) 100 * sd(d$LEx) / mean(d$LEx))
anotar("cv_lex_2023", "10.2% · IC [7.4; 11.6]",
       sprintf("%.3f%% · IC [%.2f; %.2f]", cv_lex, ci_cv["lo"], ci_cv["hi"]),
       round(cv_lex, 1) == 10.2 && abs(ci_cv["lo"] - 7.4) < 0.5 && abs(ci_cv["hi"] - 11.6) < 0.5,
       sprintf("SD/media x 100; 237 países: %.2f", 100 * sd(p23$LEx) / mean(p23$LEx)))
rq5 <- function(d) unname(quantile(d$Q5, 0.9) / quantile(d$Q5, 0.1))
q5r <- rq5(g23); ci_q5 <- boot_bloques(g23, rq5)
anotar("q5_ratio_p90p10_2023", "20× · IC [11; 28]",
       sprintf("%.3f · IC [%.1f; %.1f]", q5r, ci_q5["lo"], ci_q5["hi"]),
       round(q5r) == 20 && abs(ci_q5["lo"] - 11) < 1.5 && abs(ci_q5["hi"] - 28) < 2,
       sprintf("quantile tipo 7 (por defecto de R); P90 %.1f / P10 %.2f; 237: %.1f",
               quantile(g23$Q5, .9), quantile(g23$Q5, .1), rq5(p23)))

rho_cm <- cor(g23$CDR, g23$MedianAgePop, method = "spearman")
ci_rho <- boot_bloques(g23, function(d) cor(d$CDR, d$MedianAgePop, method = "spearman"))
anotar("rho_cdr_medage_2023", "0.46 rho · IC [0.05; 0.73]",
       sprintf("%.4f · IC [%.2f; %.2f]", rho_cm, ci_rho["lo"], ci_rho["hi"]),
       round(rho_cm, 2) == 0.46 && abs(ci_rho["lo"] - 0.05) < 0.07 && abs(ci_rho["hi"] - 0.73) < 0.05,
       "Spearman CDR vs MedianAgePop, 2023, 161")

# =============================================================================
# 7. Validación cruzada, gemelos y parecidos por TFR (2023, 161)
# =============================================================================
set.seed(SEMILLA)
y <- g23$PopGrowthRate; x <- g23$TFR; n <- length(y)
r2cv <- replicate(20, {
  pl <- sample(rep(1:10, length.out = n)); pr <- numeric(n)
  for (k in 1:10) { tr <- pl != k; b <- coef(lm(y[tr] ~ x[tr])); pr[!tr] <- b[1] + b[2] * x[!tr] }
  1 - sum((y - pr)^2) / sum((y - mean(y))^2)
})
anotar("r2_tfr_growth_cv", "0.58 R2", sprintf("%.4f (rango 20 rep. %.3f-%.3f)", mean(r2cv),
       min(r2cv), max(r2cv)), round(mean(r2cv), 2) == 0.58,
       sprintf("10-fold x 20, R2 = 1 - SSE/SST con predicciones fuera de muestra; R2 ajustado en muestra = %.3f",
               summary(lm(y ~ x))$adj.r.squared))

# Gemelos: todos los pares (12 880), |dTFR| <= 0.05, mayor |d crecimiento|
cmb <- t(combn(nrow(g23), 2))
pares <- data.table(a = g23$ISO3_code[cmb[, 1]], b = g23$ISO3_code[cmb[, 2]],
                    na = g23$Location[cmb[, 1]], nb = g23$Location[cmb[, 2]],
                    ta = g23$TFR[cmb[, 1]], tb = g23$TFR[cmb[, 2]],
                    ga = g23$PopGrowthRate[cmb[, 1]], gb = g23$PopGrowthRate[cmb[, 2]])
pares <- pares[abs(ta - tb) <= 0.05][order(-abs(ga - gb))]
# orientar cada par por orden alfabético de ISO3 (como en numbers.json)
pares[a > b, `:=`(a = b, b = a, na = nb, nb = na, ta = tb, tb = ta, ga = gb, gb = ga)]
tw <- pares[1:5]
tw_txt <- paste(sprintf("%d. %s–%s (TFR %.4g vs %.4g; growth %.3f vs %.3f %%)", 1:5, tw$na, tw$nb,
                        round(tw$ta, 4), round(tw$tb, 4), tw$ga, tw$gb), collapse = " || ")
tw_nb <- c("ARE-BLR", "ARE-JPN", "SWZ-SYR", "ARE-ITA", "ARE-MUS")
anotar("twins", "ARE–BLR, ARE–JPN, SWZ–SYR, ARE–ITA, ARE–MUS (top-5)", tw_txt,
       identical(paste(tw$a, tw$b, sep = "-"), tw_nb),
       sprintf(paste("%d pares en total; %d cumplen |dTFR| <= 0.05. Mismos 5 pares, mismo orden y mismos",
                     "valores; solo la cadena del lote mezcla formatos (SWZ 2.7525 con 4 decimales, el resto con 2)"),
               nrow(cmb), nrow(pares)))

# Colombia: 5 más parecidos por TFR sola (desempate por ISO3)
col_tfr <- g23[ISO3_code == "COL", TFR]
lk_col <- g23[ISO3_code != "COL"][, d := abs(TFR - col_tfr)][order(d, ISO3_code)][1:5]
anotar("lookalikes_col_tfr", "France, Australia, Türkiye, United States of America, New Zealand",
       paste(lk_col$Location, collapse = ", "),
       identical(lk_col$ISO3_code, c("FRA", "AUS", "TUR", "USA", "NZL")),
       sprintf("TFR COL %.4f; vecinos %s", col_tfr,
               paste(sprintf("%s %.4f", lk_col$ISO3_code, lk_col$TFR), collapse = ", ")))

# =============================================================================
# 8. Persistencia de la migración y R2 observado a 27 años
# =============================================================================
est_g[, decada := pmin(10 * (Time %/% 10), 2010)]   # 2010s = 2010-2023
dec <- dcast(est_g[, .(cnmr = mean(CNMR)), by = .(ISO3_code, decada)], ISO3_code ~ decada, value.var = "cnmr")
rdec <- sapply(1:6, function(i) cor(dec[[i + 1]], dec[[i + 2]]))
names(rdec) <- paste0(names(dec)[2:7], "->", names(dec)[3:8])
anotar("r_cnmr_decades_min", "0.32 Pearson r",
       sprintf("%.4f (%s)", min(rdec), paste(sprintf("%s %.2f", names(rdec), rdec), collapse = "; ")),
       round(min(rdec), 2) == 0.32, "Pearson entre medias por década consecutivas de CNMR (crudo), 161")

ancho <- dcast(est_g, ISO3_code ~ Time, value.var = "TPopulation1July")
anchoJ <- dcast(est_g, ISO3_code ~ Time, value.var = "TPopulation1Jan")
tfrw <- dcast(est_g, ISO3_code ~ Time, value.var = "TFR")
r27 <- function(W) sapply(1950:1996, function(t0) {
  yy <- 100 * (W[[as.character(t0 + 27)]] / W[[as.character(t0)]] - 1)
  summary(lm(yy ~ tfrw[[as.character(t0)]]))$adj.r.squared })
r27j <- r27(ancho); r27e <- r27(anchoJ)
anotar("r2_tfr_chg27_observed", "min 0.13; median 0.40; max 0.50",
       sprintf("min %.3f (%d); mediana %.3f; max %.3f (%d) [1 enero: %.3f / %.3f / %.3f]",
               min(r27j), (1950:1996)[which.min(r27j)], median(r27j), max(r27j),
               (1950:1996)[which.max(r27j)], min(r27e), median(r27e), max(r27e)),
       round(min(r27j), 2) == 0.13 && round(median(r27j), 2) == 0.40 && round(max(r27j), 2) == 0.50,
       paste("47 orígenes 1950-1996; % cambio de TPopulation1July en 27 años ~ TFR del origen; R2 ajustado.",
             "AMBIGUO: la definición no dice qué población; con 1 de enero (convención del plan §3 para cambios)",
             "la mediana sería 0.37 y el máximo 0.51; el comparador 2023->2050 da 0.88 con ambas"),
       def_clara = FALSE)

# =============================================================================
# 9. Perfil de 12 indicadores 2023: PCA, parecidos (k = 5) y perfil recuperado
# =============================================================================
VARS12 <- c("TFR", "CBR", "LEx", "LE65", "Q5", "Q1560", "CDR", "MedianAgePop",
            "PopGrowthRate", "CNMR", "PopSexRatio", "PopDensity")
winsor3 <- function(v) { m <- mean(v); s <- sd(v); pmin(pmax(v, m - 3 * s), m + 3 * s) }
X12 <- as.data.frame(g23[, ..VARS12])
X12$PopDensity <- log(X12$PopDensity)                 # densidad en log
cat("CNMR fuera de ±3 DE (corte 2023):", g23$ISO3_code[abs(scale(X12$CNMR)) > 3], "\n")
X12$CNMR <- winsor3(X12$CNMR)                         # winsorizada ±3 DE del corte 2023
Z12 <- scale(X12)
pca12 <- prcomp(Z12)
S12 <- pca12$x
if (pca12$rotation["CNMR", 2] < 0) S12[, 2] <- -S12[, 2]   # PC2 orientado: CNMR carga positivo

# Solapamiento de los 5 vecinos (perfil completo vs PC1+PC2), por país
Df <- as.matrix(dist(Z12)); Ds <- as.matrix(dist(S12[, 1:2]))
diag(Df) <- diag(Ds) <- Inf
ov_i <- sapply(seq_len(nrow(Z12)), function(i)
  length(intersect(order(Df[i, ])[1:5], order(Ds[i, ])[1:5])) / 5)
knn12 <- 100 * mean(ov_i)
g23[, ov_pc12 := ov_i]
ci_knn <- boot_bloques(g23, function(d) 100 * mean(d$ov_pc12))
anotar("knn_pc12", "43% · IC [40; 46]", sprintf("%.3f%% · IC [%.1f; %.1f]", knn12, ci_knn["lo"], ci_knn["hi"]),
       round(knn12) == 43 && abs(ci_knn["lo"] - 40) < 1.5 && abs(ci_knn["hi"] - 46) < 1.5,
       sprintf("PC1 = %.1f %% de la varianza; vecinos calculados una vez con los 161; bootstrap de las cuotas por país",
               100 * pca12$sdev[1]^2 / sum(pca12$sdev^2)))

# Perfil recuperado por la TFR (R2 medio; la propia TFR cuenta 1)
recupera <- function(X) mean(sapply(VARS12, function(v)
  if (v == "TFR") 1 else summary(lm(X[[v]] ~ X[["TFR"]]))$r.squared))
rec <- recupera(X12)
g23x <- cbind(g23[, .(ISO3_code, subregion)], X12)
ci_rec <- boot_bloques(g23x, function(d) recupera(as.data.frame(d)))
anotar("recov_tfr", "0.51 share · IC [0.43; 0.57]", sprintf("%.4f · IC [%.2f; %.2f]", rec, ci_rec["lo"], ci_rec["hi"]),
       round(rec, 2) == 0.51 && abs(ci_rec["lo"] - 0.43) < 0.03 && abs(ci_rec["hi"] - 0.57) < 0.03,
       "media de R2 de lm(v ~ TFR) en los 12 indicadores (CNMR winsorizada, log densidad)")

# Correlación TFR - PC2 (orientado)
r_pc2 <- function(d) {
  X <- as.data.frame(d)[, VARS12]; p <- prcomp(scale(X))
  s2 <- p$x[, 2]; if (p$rotation["CNMR", 2] < 0) s2 <- -s2
  cor(X$TFR, s2) }
rpc2 <- r_pc2(g23x)
ci_pc2 <- boot_bloques(g23x, r_pc2)
anotar("r_tfr_pc2", "0.03 r · IC [-0.08; 0.17]", sprintf("%.4f · IC [%.2f; %.2f]", rpc2, ci_pc2["lo"], ci_pc2["hi"]),
       round(rpc2, 2) == 0.03 && abs(ci_pc2["lo"] - (-0.08)) < 0.05 && abs(ci_pc2["hi"] - 0.17) < 0.05,
       sprintf("Pearson TFR (sin estandarizar) vs PC2; carga de CNMR en PC2 = %.2f; PCA re-estimado en cada réplica",
               abs(pca12$rotation["CNMR", 2])))

# =============================================================================
# 10. Grupos de trayectoria (k-means k = 4 sobre 32 rasgos de 70 años)
# =============================================================================
# 32 rasgos = medias por década (1950s ... 2010s, 2020-23) de TFR, LEx, edad
# mediana y CNMR (winsorizada ±3 DE del panel), z con media y DE de TODO el panel
# anual 161 x 1950-2023.
V4 <- c("TFR", "LEx", "MedianAgePop", "CNMR")
pn <- copy(est_g[, c("ISO3_code", "Time", V4), with = FALSE])
cat("CNMR país-años fuera de ±3 DE del panel:",
    pn[abs(CNMR - mean(CNMR)) > 3 * sd(CNMR), .N], "\n")
pn[, CNMR := winsor3(CNMR)]
for (v in V4) set(pn, j = v, value = (pn[[v]] - mean(pn[[v]])) / sd(pn[[v]]))
pn[, dec := pmin(10 * (Time %/% 10), 2020)]
rasgos <- dcast(pn[, lapply(.SD, mean), by = .(ISO3_code, dec), .SDcols = V4],
                ISO3_code ~ dec, value.var = V4)
X32 <- as.matrix(rasgos[, -1]); rownames(X32) <- rasgos$ISO3_code
stopifnot(identical(dim(X32), c(161L, 32L)))
set.seed(SEMILLA)
km <- kmeans(X32, 4, nstart = 50)
cl <- km$cluster
# Regla de nombres: mayor CNMR media 2000s = Migration-led; menor TFR 1950s = Early;
# de los otros dos, menor TFR 2020-23 = Fast, mayor = Recent
cen <- as.data.frame(km$centers)
g_mig <- which.max(cen$CNMR_2000)
resto <- setdiff(1:4, g_mig)
g_early <- resto[which.min(cen$TFR_1950[resto])]
resto2 <- setdiff(resto, g_early)
g_fast <- resto2[which.min(cen$TFR_2020[resto2])]
g_recent <- setdiff(resto2, g_fast)
nombres <- setNames(c("Early movers", "Fast movers", "Recent movers", "Migration-led"),
                    c(g_early, g_fast, g_recent, g_mig))
grupo <- setNames(nombres[as.character(cl)], names(cl))
g23[, grupo := grupo[ISO3_code]]
cat("Tamaños:\n"); print(table(g23$grupo))
cat("India:", grupo["IND"], "| China:", grupo["CHN"], "\n")

sil <- mean(silhouette(cl, dist(X32))[, 3])
anotar("silhouette", "0.37 silhouette", sprintf("%.4f", sil), round(sil, 2) == 0.37,
       sprintf("k-means k = 4, nstart = 50, semilla 2026; nombres por regla propia sobre centroides (mayor CNMR 2000s = Migration-led; menor TFR 1950s = Early; menor TFR 2020-23 = Fast); tamaños %s",
               paste(sprintf("%s %d", names(table(g23$grupo)), table(g23$grupo)), collapse = ", ")))

# Población 2023 por grupo
popg <- g23[, .(pob = sum(TPopulation1July) / 1e6, n = .N), by = grupo][order(grupo)]
pg <- setNames(popg$pob, popg$grupo)
anotar("cluster_pop_bn", "Early 1.4; Fast 4.9; Recent 1.7; Migration-led 0.1",
       paste(sprintf("%s %.3f", names(pg), pg), collapse = "; "),
       round(pg["Early movers"], 1) == 1.4 && round(pg["Fast movers"], 1) == 4.9 &&
         round(pg["Recent movers"], 1) == 1.7 && round(pg["Migration-led"], 1) == 0.1,
       "suma de TPopulation1July 2023 (miles de millones)")

ejM <- g23[grupo == "Migration-led"][order(-TPopulation1July)]
anotar("cluster_examples_migration", "Saudi Arabia, Jordan, United Arab Emirates",
       paste(ejM$Location[1:3], collapse = ", "),
       identical(ejM$ISO3_code[1:3], c("SAU", "JOR", "ARE")),
       sprintf("miembros (%d): %s", nrow(ejM), paste(ejM$ISO3_code, collapse = ",")))

# ARI trayectoria vs niveles 2023 (z transversal, CNMR winsorizada en el corte)
N23 <- as.data.frame(g23[match(rownames(X32), ISO3_code), ..V4])
N23$CNMR <- winsor3(N23$CNMR)
set.seed(SEMILLA)
km23 <- kmeans(scale(N23), 4, nstart = 50)
ari <- adjustedRandIndex(cl, km23$cluster)
anotar("ari_tray_niveles", "0.59 ARI", sprintf("%.4f", ari), round(ari, 2) == 0.59,
       "mclust::adjustedRandIndex; niveles 2023 de TFR, LEx, edad mediana, CNMR (z del corte)")

# Pertenencia difusa (fanny, k = 4, exponente 1.5)
fz <- fanny(X32, k = 4, memb.exp = 1.5)
sh_bt <- 100 * mean(apply(fz$membership, 1, max) < 0.6)
anotar("share_between_groups", "42%", sprintf("%.2f%% (%d de 161)", sh_bt,
       sum(apply(fz$membership, 1, max) < 0.6)), round(sh_bt) == 42,
       sprintf("cluster::fanny, métrica euclídea; umbral 0.5: %.0f%%, 0.7: %.0f%%",
               100 * mean(apply(fz$membership, 1, max) < 0.5), 100 * mean(apply(fz$membership, 1, max) < 0.7)))

# R2 del eje 1 de los 32 rasgos sobre el grupo
p32 <- prcomp(X32)
ve1 <- p32$sdev[1]^2 / sum(p32$sdev^2)
r2ax <- summary(lm(p32$x[, 1] ~ factor(cl)))$r.squared
anotar("r2_groups_axis1", "0.90 R2", sprintf("%.4f (eje 1 = %.1f%% de la varianza)", r2ax, 100 * ve1),
       round(r2ax, 2) == 0.90 && round(100 * ve1) == 67, "prcomp sin re-escalar (rasgos ya en z del panel)")

# =============================================================================
# 11. Vecinos geográficos: kNN5 haversine entre label points de Natural Earth
# =============================================================================
suppressPackageStartupMessages({ library(rnaturalearth); library(sf) })
ne <- as.data.table(st_drop_geometry(ne_countries(scale = "medium", returnclass = "sf")))
ne[adm0_a3 == "KOS", iso_a3_eh := "XKX"]
ne <- ne[iso_a3_eh %in% g23$ISO3_code]
ne <- ne[, .SD[if (.N > 1) which(adm0_a3 == iso_a3_eh) else 1], by = iso_a3_eh]  # AUS duplicado
stopifnot(nrow(ne) == 161)
ne <- ne[match(g23$ISO3_code, iso_a3_eh)]
haversine <- function(lon, lat) {
  rad <- pi / 180; la <- lat * rad; lo <- lon * rad
  dla <- outer(la, la, "-"); dlo <- outer(lo, lo, "-")
  a <- sin(dla / 2)^2 + outer(cos(la), cos(la)) * sin(dlo / 2)^2
  a[] <- pmin(1, sqrt(a))                       # pmin pierde dimensiones: se reasigna
  2 * 6371 * asin(a) }
Dh <- haversine(ne$label_x, ne$label_y); diag(Dh) <- Inf
nn5 <- t(apply(Dh, 1, function(r) order(r)[1:5]))
W5 <- matrix(0, 161, 161); for (i in 1:161) W5[i, nn5[i, ]] <- 1 / 5   # fila-estandarizada
moran <- function(x, W) { z <- x - mean(x); (length(x) / sum(W)) * sum(z * (W %*% z)) / sum(z^2) }
mi <- moran(g23$CNMR, W5)
set.seed(SEMILLA); mi_null <- replicate(999, moran(sample(g23$CNMR), W5))
anotar("moran_cnmr_2023", "0.11 Moran's I", sprintf("%.4f (p perm = %.3f; nulo 95%% [%.2f; %.2f])", mi,
       (1 + sum(mi_null >= mi)) / 1000, quantile(mi_null, .025), quantile(mi_null, .975)),
       round(mi, 2) == 0.11, "CNMR cruda 2023; W kNN5 fila-estandarizada")

# Join count "mismo camino": proporción de enlaces vecino -> vecino del mismo grupo
gr <- g23$grupo
same <- function(g) mean(sapply(1:161, function(i) mean(g[nn5[i, ]] == g[i])))
jc <- same(gr)
set.seed(SEMILLA); jc_null <- replicate(999, same(sample(gr)))
anotar("join_same_road_null", "0.30 share", sprintf("%.4f (observado %.4f; banda 95%% %.3f-%.3f)",
       mean(jc_null), jc, quantile(jc_null, .025), quantile(jc_null, .975)),
       round(mean(jc_null), 2) == 0.30, "media de 999 permutaciones de las etiquetas de grupo")

# =============================================================================
# 12. Envejecimiento: edad mediana 30 -> 40 en Fast movers que ya llegaron a 30
# =============================================================================
fast <- g23[grupo == "Fast movers", ISO3_code]
primer <- function(t, cond) if (any(cond)) as.numeric(min(t[cond])) else Inf
ma <- pais[ISO3_code %in% fast, .(a30 = primer(Time, MedianAgePop >= 30),
                                    a40 = primer(Time, MedianAgePop >= 40)), by = ISO3_code]
ma <- ma[is.finite(a30) & a30 <= 2023]
ma[, `:=`(evento = is.finite(a40), dur = ifelse(is.finite(a40), a40, 2100) - a30)]
ma <- merge(ma, unique(g23[, .(ISO3_code, subregion)]), by = "ISO3_code")
km_med <- function(d) unname(summary(survfit(Surv(dur, evento) ~ 1, data = d))$table["median"])
med3040 <- km_med(ma)
ci_ma <- boot_bloques(ma, km_med)
anotar("yrs_medage30_40_fast_started", "24 years · IC [21; 26] (bruto 23.5)",
       sprintf("%.1f · IC [%.1f; %.1f] (n = %d, eventos = %d)", med3040, ci_ma["lo"], ci_ma["hi"],
               nrow(ma), sum(ma$evento)),
       med3040 == 23.5 && nrow(ma) == 20 && abs(ci_ma["lo"] - 21) <= 1 && abs(ci_ma["hi"] - 26) <= 1,
       sprintf("KM (survival), censura en 2100; años enteros (primer año >= 30 / >= 40); %s",
               paste(sprintf("%s %d", ma$ISO3_code, ma$dur), collapse = ", ")))

# =============================================================================
# 13. TFR suavizada (B-splines cúbicos, penalización 2.ª derivada, lambda = 10)
#     y registro por hitos (último cruce de 4, 5 y 3)
# =============================================================================
anios <- 1950:2023
Ytfr <- as.matrix(dcast(est_g, Time ~ ISO3_code, value.var = "TFR")[, -1])
stopifnot(nrow(Ytfr) == 74, ncol(Ytfr) == 161)
base <- create.bspline.basis(c(1950, 2023), nbasis = length(anios) + 2, norder = 4)
fdTFR <- smooth.basis(anios, Ytfr, fdPar(base, Lfdobj = 2, lambda = 10))$fd
tf <- seq(1950, 2023, 0.1)
Tf <- eval.fd(tf, fdTFR)
cruce <- function(y, u) {                 # año continuo del ÚLTIMO cruce hacia abajo
  if (y[1] < u) return(-Inf)              # ya por debajo en 1950: censura izquierda
  if (tail(y, 1) >= u) return(Inf)        # aún no cruza en 2023: censura derecha
  i <- max(which(y >= u)); tf[i] + (y[i] - u) / (y[i] - y[i + 1]) * 0.1 }
c4 <- apply(Tf, 2, cruce, 4); c5 <- apply(Tf, 2, cruce, 5); c3 <- apply(Tf, 2, cruce, 3)
names(c4) <- names(c5) <- names(c3) <- colnames(Ytfr)

n_izq <- sum(c4 == -Inf); n_obs <- sum(is.finite(c4)); n_der <- sum(c4 == Inf)
anotar("n_cens_izq", "45 countries", n_izq, n_izq == 45,
       sprintf("TFR suavizada < 4 en 1950 (de 161); observados %d, censura derecha %d; con la TFR cruda de 1950 serían %d",
               n_obs, n_der, sum(Ytfr[1, ] < 4)))
anotar("n_cruce_tfr4_obs", "90 countries", n_obs, n_obs == 90,
       sprintf("último cruce de 4 dentro de 1950-2023 (rango %.0f-%.0f)", min(c4[is.finite(c4)]),
               max(c4[is.finite(c4)])))

# Varianza entre países: calendario vs reloj propio (ventana ±20)
tau <- -20:20
ok <- names(c4)[is.finite(c4) & c4 - 20 >= 1950 & c4 + 20 <= 2023]
# Curvas alineadas (reloj propio): no dependen de la muestra -> se evalúan una vez
AL <- sapply(ok, function(iso) eval.fd(c4[iso] + tau, fdTFR[match(iso, colnames(Ytfr))]))
var_fase <- function(iso) {
  cc <- c4[iso]
  Al <- AL[, iso, drop = FALSE]
  Ca <- eval.fd(median(cc) + tau, fdTFR)[, match(iso, colnames(Ytfr)), drop = FALSE]  # calendario común
  c(red = 100 * (1 - mean(apply(Al, 1, var)) / mean(apply(Ca, 1, var))),
    v_cal = mean(apply(Ca, 1, var)), v_al = mean(apply(Al, 1, var))) }
vf <- var_fase(ok)
dvf <- data.table(ISO3_code = ok, subregion = g23[match(ok, ISO3_code), subregion])
ci_vf <- boot_bloques(dvf, function(d) var_fase(d$ISO3_code)["red"])
anotar("pct_var_fase", "80% · IC [69; 85]",
       sprintf("%.3f%% (varianza %.3f -> %.3f; n = %d) · IC [%.1f; %.1f]", vf["red"], vf["v_cal"],
               vf["v_al"], length(ok), ci_vf["lo"], ci_vf["hi"]),
       round(vf["red"]) == 80 && length(ok) == 57 && abs(ci_vf["lo"] - 69) < 3 && abs(ci_vf["hi"] - 85) < 2,
       "calendario centrado en la mediana de los cruces de la muestra (también en cada réplica)")

# Velocidad 5 -> 3: el más lento entre países >= 10 M que llegaron a 3 en 2023
dur53 <- data.table(ISO3_code = names(c5), c5 = c5, c3 = c3)[is.finite(c5) & is.finite(c3)]
dur53[, dur := c3 - c5]
dur53 <- merge(dur53, g23[, .(ISO3_code, TPopulation1July)], by = "ISO3_code")
d10 <- dur53[TPopulation1July >= 10000][order(-dur)]
anotar("dur53_slowest_ge10m", "EGY", d10$ISO3_code[1], d10$ISO3_code[1] == "EGY",
       sprintf("n >= 10 M con ambos cruces = %d; más lentos: %s; más rápido: %s %.1f", nrow(d10),
               paste(sprintf("%s %.1f", d10$ISO3_code[1:3], d10$dur[1:3]), collapse = ", "),
               d10[.N, ISO3_code], d10[.N, dur]))

# =============================================================================
# 14. Q5: máximo en 1950 (inicio de la caída censurado a la izquierda)
# =============================================================================
eleg <- est_g[Time == 1950 & TFR >= 5, ISO3_code]
eleg <- intersect(eleg, g23[ingreso != "Not classified", ISO3_code])
q5max <- est_g[ISO3_code %in% eleg, .(anio_max = Time[which.max(Q5)],
                                       max_1950_corr = Q5[Time == 1950] >= max(Q5)), by = ISO3_code]
n_q5 <- q5max[anio_max == 1950, .N]
anotar("n_q5_falling_1950", "92 countries", sprintf("%d de %d", n_q5, length(eleg)),
       n_q5 == 92 && length(eleg) == 109,
       sprintf("Q5 máxima de 1950-2023 en 1950; elegibles: >= 1 M, TFR 1950 >= 5, ingreso FY2027 clasificado; no en 1950: %s",
               paste(q5max[anio_max != 1950, sprintf("%s(%d)", ISO3_code, anio_max)], collapse = " ")))

# =============================================================================
# 15. Panel quinquenal: dentro del país (FE país + periodo) vs entre países
# =============================================================================
an <- est_g[, .(ISO3_code, Time, TFR, lQ5 = log(Q5), ingreso, subregion)]
q <- an[, periodo := 5 * (Time %/% 5)][, .(TFR = mean(TFR), lQ5 = mean(lQ5)),
                                       by = .(ISO3_code, ingreso, subregion, periodo)]
setorder(q, ISO3_code, periodo)
q[, `:=`(dTFR = TFR - shift(TFR), dlQ5 = lQ5 - shift(lQ5)), by = ISO3_code]
q[, `:=`(L0 = dlQ5, L1 = shift(dlQ5, 1), L2 = shift(dlQ5, 2), L3 = shift(dlQ5, 3),
         L4 = shift(dlQ5, 4)), by = ISO3_code]
qe <- q[complete.cases(q[, .(dTFR, L0, L1, L2, L3, L4)])]
stopifnot(nrow(qe) == 1610, min(qe$periodo) == 1975)
LAGS <- paste0("L", 0:4)
fml <- dTFR ~ L0 + L1 + L2 + L3 + L4 | id + periodo
dentro <- function(d) {                   # hijos por mujer asociados a la mitad de Q5 (20 años)
  m <- feols(fml, d, cluster = ~id, notes = FALSE, warn = FALSE)
  log(0.5) * sum(coef(m)[LAGS]) }
entre <- function(d) {                    # medias por país 1950-2023 (anuales), una fila por país
  log(0.5) * unname(coef(lm(TFR ~ lQ5, d))[2]) }
qe[, id := ISO3_code]
mb <- an[, .(TFR = mean(TFR), lQ5 = mean(lQ5)), by = .(ISO3_code, ingreso, subregion)]
w_hat <- dentro(qe); b_hat <- entre(mb)
cat(sprintf("Dentro = %.4f ; entre = %.4f\n", w_hat, b_hat))

# Bootstrap por bloques conjunto: mismas subregiones para numerador y denominador
boot_panel <- function(qd, mbd, B = B_BOOT, semilla = SEMILLA, solo_dentro = FALSE) {
  set.seed(semilla)
  sub <- unique(mbd$subregion)
  out <- t(vapply(seq_len(B), function(b) {
    s <- sample(sub, length(sub), replace = TRUE)
    # cada copia de una subregión es un bloque distinto (FE de país propios)
    qq <- rbindlist(lapply(seq_along(s), function(k) qd[subregion == s[k]][, id := paste(ISO3_code, k)]))
    w <- tryCatch(dentro(qq), error = function(e) NA_real_)
    bb <- if (solo_dentro) NA_real_ else
      tryCatch(entre(rbindlist(lapply(s, function(k) mbd[subregion == k]))), error = function(e) NA_real_)
    c(w = w, b = bb) }, numeric(2)))
  out }
bp <- boot_panel(qe, mb)
ratio_bw <- bp[, "b"] / bp[, "w"]; ratio_wb <- bp[, "w"] / bp[, "b"]
qq <- function(v) quantile(v, c(.025, .975), na.rm = TRUE)
r1 <- b_hat / w_hat; r2 <- w_hat / b_hat
anotar("panel_ratio_between_within", "2.5× · IC [-9.2; 18.4]",
       sprintf("%.4f · IC [%.1f; %.1f] (dentro %.3f IC [%.2f; %.2f]; entre %.3f IC [%.2f; %.2f])", r1,
               qq(ratio_bw)[1], qq(ratio_bw)[2], w_hat, qq(bp[, "w"])[1], qq(bp[, "w"])[2],
               b_hat, qq(bp[, "b"])[1], qq(bp[, "b"])[2]),
       round(r1, 1) == 2.5 && r1 >= -9.2 && r1 <= 18.4,
       "cociente inestable: el IC por bloques del denominador (dentro) llega a 0; percentiles muy sensibles a la semilla")
anotar("panel_within_over_between", "0.39 share · IC [-0.05; 0.73]",
       sprintf("%.4f · IC [%.2f; %.2f]", r2, qq(ratio_wb)[1], qq(ratio_wb)[2]),
       round(r2, 2) == 0.39 && abs(qq(ratio_wb)[1] - (-0.05)) < 0.08 && abs(qq(ratio_wb)[2] - 0.73) < 0.08,
       "dentro (suma de 5 rezagos x ln 0.5, FE país + periodo) / entre (lm de medias por país)")

# Ingreso bajo (FY2027), con FE de periodo propios
ql <- qe[ingreso == "Low income"]
low_hat <- dentro(ql)
bl <- boot_panel(ql, mb[ingreso == "Low income"], solo_dentro = TRUE)
anotar("panel_low_income_halfq5", "-0.95 · IC [-2.14; -0.07]",
       sprintf("%.4f · IC [%.2f; %.2f] (n países %d, N = %d, %d subregiones)", low_hat,
               qq(bl[, "w"])[1], qq(bl[, "w"])[2], uniqueN(ql$ISO3_code), nrow(ql), uniqueN(ql$subregion)),
       round(low_hat, 2) == -0.95 && abs(qq(bl[, "w"])[1] - (-2.14)) < 0.3 && abs(qq(bl[, "w"])[2] - (-0.07)) < 0.15,
       "feols en el subconjunto de ingreso bajo; EE agrupados por país (no afectan el punto)")

# =============================================================================
# 16. Metadato de la clasificación de ingreso
# =============================================================================
wbraw <- fread(RUTA_WB)
n_clas <- wbraw[ingreso_api != "Aggregates", .N]
lk_full <- fread(RUTA_LOOKUP)
dif <- merge(lk_full[, .(ISO3, ingreso_bm)], wb, by = "ISO3", all.x = TRUE)[
  , ingreso := fifelse(is.na(ingreso), "Not classified", ingreso)][ingreso_bm != ingreso, .N]
anotar("meta_income_classification", "World Bank FY2027 (API 2026-10-22), applied to all years",
       sprintf("archivo %s: %d economías clasificadas (%s); lookup vs archivo: %d diferencias; 237 WPP -> %s",
               basename(RUTA_WB), n_clas,
               paste(sprintf("%s %d", names(table(wbraw[ingreso_api != "Aggregates"]$ingreso_api)),
                             table(wbraw[ingreso_api != "Aggregates"]$ingreso_api)), collapse = ", "),
               dif, paste(sprintf("%s %d", names(table(p23$ingreso)), table(p23$ingreso)), collapse = ", ")),
       dif == 0,
       paste("La etiqueta FY2027 / julio 2026 / INB 2025 Atlas viene del nombre del archivo y de data/raw/README.md;",
             "el CSV no trae campo de vintage, así que esa parte no es verificable desde el dato"),
       def_clara = TRUE)

# =============================================================================
# 17. Salida
# =============================================================================
tab <- rbindlist(res)
fwrite(tab, SALIDA)
cat(sprintf("\n%d claves verificadas; coinciden %d; no coinciden: %s\n", nrow(tab), sum(tab$coincide),
            paste(tab[coincide == FALSE, clave], collapse = ", ")))
