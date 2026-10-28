#!/usr/bin/env Rscript
# =============================================================================
# docs/qa/verificacion_lote_1.R
# Verificación INDEPENDIENTE (agente "verificador-1") del lote 1 de cifras de
# figures/numbers.json (ASA DataQuest 2026, UN WPP 2024).
#
# Regla de independencia: todo se recalcula desde los CSV crudos de la ONU
# (../WPP2024_Demographic_Indicators_Medium_csv.gz y OtherVariants), SIN hacer
# source de R/0*.R y SIN leer data/processed/*.parquet. Únicos insumos
# auxiliares permitidos: data/processed/lookup_regiones.csv (solo la región
# SDG) y data/raw/wb_api_income_2026-10-22.csv (ingreso FY2027).
# La subregión ONU (bloques del bootstrap) se deriva del ParentID del archivo
# crudo (918 = Northern America, a mano, porque no tiene fila propia).
#
# Uso: Rscript docs/qa/verificacion_lote_1.R
# Salida: tabla en consola y docs/qa/verificacion_lote_1_resultados.csv
# Semilla: set.seed(2026) justo antes de cada bloque aleatorio.
# =============================================================================

suppressPackageStartupMessages({
  library(data.table); library(fixest); library(survival)
  library(fda); library(sf); library(rnaturalearth)
})
RAIZ <- here::here()   # raíz del repositorio (archivo .here); antes, ruta fija de una máquina (jurado_etica I-8)
PADRE <- dirname(RAIZ)
SEMILLA <- 2026
t0 <- Sys.time()

res <- list()   # una entrada por clave: valor independiente y nota
guarda <- function(clave, valor, nota = "") {
  res[[clave]] <<- data.table(clave = clave, valor_independiente = valor, nota = nota)
  cat(sprintf("[%s] %s  %s\n", clave, valor, nota))
}
f1 <- function(x, d = 1) formatC(x, format = "f", digits = d)

# --- 0. Datos crudos ----------------------------------------------------------
med <- fread(file.path(PADRE, "WPP2024_Demographic_Indicators_Medium_csv.gz"), encoding = "UTF-8")
setnames(med, 1, "SortOrder")
p <- med[ISO3_code != "" & Time <= 2100]          # 237 países y áreas; 2101 fuera

lk <- fread(file.path(RAIZ, "data/processed/lookup_regiones.csv"))[, .(ISO3_code = ISO3, region_sdg)]
wb <- fread(file.path(RAIZ, "data/raw/wb_api_income_2026-10-22.csv"))[
  ingreso_api != "Aggregates", .(ISO3_code = ISO3, ingreso = ingreso_api)]

# Subregión ONU desde ParentID (las filas de subregión están en el mismo archivo)
nom_loc <- unique(med[, .(ParentID = LocID, subregion = Location)])
pais <- unique(p[, .(ISO3_code, Location, ParentID)])
pais <- merge(pais, nom_loc, by = "ParentID", all.x = TRUE)
pais[ParentID == 918, subregion := "Northern America"]
pais <- merge(pais, lk, by = "ISO3_code", all.x = TRUE)
pais <- merge(pais, wb, by = "ISO3_code", all.x = TRUE)
pais[is.na(ingreso), ingreso := "Not classified"]   # sin fila en el API (TWN, GGY, JEY, ...)
pais <- merge(pais, p[Time == 2023, .(ISO3_code, pob23 = TPopulation1July)], by = "ISO3_code")
pais[, grande := pob23 >= 1000]                     # >= 1 M en 2023 (miles)
stopifnot(nrow(pais) == 237, !anyNA(pais$subregion), !anyNA(pais$region_sdg))
G <- pais[grande == TRUE, ISO3_code]
cat("Países >= 1 M:", length(G), " | subregiones entre ellos:", uniqueN(pais[grande == TRUE, subregion]), "\n")

# Bootstrap por bloques de subregión (percentil, B = 2000): se sortean
# subregiones con reemplazo y entran todos sus países.
boot_bloques <- function(d, f, B = 2000, seed = SEMILLA, bloque = "subregion") {
  idx <- split(seq_len(nrow(d)), d[[bloque]])
  set.seed(seed)
  est <- replicate(B, { s <- sample(names(idx), length(idx), replace = TRUE); f(d[unlist(idx[s])]) })
  quantile(est, c(0.025, 0.975), na.rm = TRUE, names = FALSE)
}

# =============================================================================
# 1. Conteos censales y cifras descriptivas (237 países y áreas)
# =============================================================================
guarda("n_countries", uniqueN(p$ISO3_code), "ISO3_code no vacío, Medium")

# Territorios: lista propia de los no miembros ni observadores de la ONU
TERR <- c("HKG","MAC","TWN",                                  # Asia
          "ESH","MYT","REU","SHN",                            # África
          "FRO","GIB","GGY","JEY","IMN","XKX",                # Europa
          "ABW","AIA","BES","VGB","CYM","CUW","GLP","MTQ","MSR","PRI","BLM","MAF","SXM","TCA","VIR",  # Caribe
          "BMU","GRL","SPM","FLK","GUF",                      # América del Norte y del Sur
          "ASM","COK","PYF","GUM","NCL","NIU","MNP","TKL","WLF")  # Oceanía
stopifnot(all(TERR %in% pais$ISO3_code))
estados <- setdiff(pais$ISO3_code, TERR)
cat("Estados (deben ser 193 miembros + VAT + PSE):", length(estados), "\n")
cat(paste(sort(estados), collapse = " "), "\n")
guarda("n_territories", length(TERR), sprintf("lista propia; quedan %d estados", length(estados)))

guarda("n_natneg_1990", p[Time == 1990 & NatChange < 0, .N], "NatChange < 0, 1990")
x <- p[Time == 2023]
guarda("share_pop_natneg_2023", f1(100 * x[NatChange < 0, sum(TPopulation1July)] / x[, sum(TPopulation1July)], 2),
       sprintf("%d países con NatChange<0", x[NatChange < 0, .N]))
guarda("n_shrinking_2100", p[Time == 2100 & PopChange < 0, .N], "PopChange < 0, 2100 (proyección)")
w <- med[Location == "World" & Time <= 2100]
guarda("world_peak_year", w[which.max(TPopulation1July), Time],
       sprintf("máx. %.0f miles", max(w$TPopulation1July)))

q5a <- p[Time == 2023 & Q5 > 25, ISO3_code]
guarda("n_sdg32_above_2030", p[Time == 2030 & ISO3_code %in% q5a & Q5 > 25, .N],
       sprintf("de %d con Q5>25 en 2023", length(q5a)))

# --- Tipos de palanca --------------------------------------------------------
tipo <- function(nat, mig, pc) fcase(nat > 0 & mig > 0 & pc > 0, "A",
                                     nat > 0 & mig <= 0 & pc > 0, "B",
                                     nat < 0 & pc > 0, "C",
                                     nat < 0 & pc < 0, "D",
                                     nat > 0 & pc < 0, "E", default = NA_character_)
pal <- function(anios) p[Time %in% anios, .(nat = sum(NatChange), mig = sum(NetMigrations), pc = sum(PopChange)),
                          by = ISO3_code][, tipo := tipo(nat, mig, pc)][]
t23 <- merge(pal(2023), pais[, .(ISO3_code, Location, pob23, grande)], by = "ISO3_code")
print(t23[, .N, by = tipo][order(tipo)])
guarda("n_type_C", t23[tipo == "C", .N], "NatChange<0 & PopChange>0, 2023")
nC <- c(y2021 = pal(2021)[tipo == "C", .N], y2022 = pal(2022)[tipo == "C", .N],
        y2023 = pal(2023)[tipo == "C", .N], y2021_23 = pal(2021:2023)[tipo == "C", .N])
guarda("n_grow_only_migration_sens_range", sprintf("%d–%d", min(nC), max(nC)), paste(names(nC), nC, collapse = "; "))
ejem <- function(tp) t23[tipo == tp & grande == TRUE][order(-pob23)][1:3]
guarda("examples_type_A_iso3", paste(ejem("A")$ISO3_code, collapse = ", "), paste(ejem("A")$Location, collapse = " / "))
guarda("examples_type_D", paste(ejem("D")$Location, collapse = ", "), paste(ejem("D")$ISO3_code, collapse = " "))

# --- Participación de la migración 2000-2023 por ingreso (sumas de personas) -
acc <- p[Time %between% c(2000, 2023), .(nm = sum(NetMigrations), pc = sum(PopChange)), by = ISO3_code]
acc <- merge(acc, pais[, .(ISO3_code, ingreso, subregion)], by = "ISO3_code")
razon <- function(d) 100 * sum(d$nm) / sum(d$pc)
for (g in c("High income", "Low income")) {
  d <- acc[ingreso == g]
  ci <- boot_bloques(d, razon)
  clave <- if (g == "High income") "share_mig_high_2000_2023" else "share_mig_low_2000_2023"
  guarda(clave, sprintf("%s%% · IC [%s; %s]", f1(razon(d)), f1(ci[1]), f1(ci[2])), sprintf("n = %d", nrow(d)))
}

# --- Proyecciones e intervalos de la ONU (OtherVariants) ----------------------
ov <- fread(file.path(PADRE, "WPP2024_Demographic_Indicators_OtherVariants_csv.gz"),
            select = c("ISO3_code", "Variant", "Time", "TPopulation1July"))
ov <- ov[ISO3_code != "" & Time == 2050 & Variant %in% c("Lower 95 PI", "Upper 95 PI")]
ov <- dcast(ov, ISO3_code ~ Variant, value.var = "TPopulation1July")
setnames(ov, c("ISO3_code", "lo95", "hi95"))
m50 <- p[Time == 2050, .(ISO3_code, pop50 = TPopulation1July)]
are <- merge(m50, ov, by = "ISO3_code")[ISO3_code == "ARE"]
guarda("pop_are_2050", sprintf("%s million · UN PI95 %s–%s", f1(are$pop50 / 1e3), f1(are$lo95 / 1e3), f1(are$hi95 / 1e3)))
chn <- merge(m50, ov, by = "ISO3_code")[ISO3_code == "CHN"]
guarda("pop_chn_2050", sprintf("%s billion · UN PI95 %s–%s", f1(chn$pop50 / 1e6, 2), f1(chn$lo95 / 1e6, 2), f1(chn$hi95 / 1e6, 2)))
dir <- merge(pais[grande == TRUE, .(ISO3_code, pob23)], ov, by = "ISO3_code")
guarda("n_dir_uncertain_2050", dir[lo95 <= pob23 & pob23 <= hi95, .N],
       sprintf("de %d; decrecen seguro %d, crecen seguro %d", nrow(dir), dir[hi95 < pob23, .N], dir[lo95 > pob23, .N]))

# Revisión de EAU: cifra externa (WPP2022 no está en el repositorio)
# Comprobación externa parcial: WPP2022 daba 9 441 129 hab. en 2022 (fuente secundaria que cita WPP2022)
# y ~9 516 871 en 2023 (valor recordado, NO verificado en archivo). Solo orientativo.
are23 <- p[ISO3_code == "ARE" & Time == 2023, TPopulation1July]
guarda("are_revision_pct", sprintf("~%s%% (externo, no calculable con WPP2024)", f1(100 * (are23 / 9516.871 - 1))),
       sprintf("WPP2024 EAU 2023 = %.1f miles; WPP2022 2023 ~9516.9 miles (no verificado); WPP2024 2022 = %.1f miles vs WPP2022 2022 = 9441.1",
               are23, p[ISO3_code == "ARE" & Time == 2022, TPopulation1July]))

# =============================================================================
# 2. Corte transversal 2023 (161 países >= 1 M)
# =============================================================================
x23 <- merge(p[Time == 2023 & ISO3_code %in% G], pais[, .(ISO3_code, subregion, region_sdg, ingreso)], by = "ISO3_code")
setorder(x23, ISO3_code)
stopifnot(nrow(x23) == 161)

# --- Gemelos (búsqueda exhaustiva) --------------------------------------------
pr <- CJ(i = 1:161, j = 1:161)[i < j]
guarda("n_pairs_twins", nrow(pr), "choose(161, 2)")
pr[, `:=`(a = x23$ISO3_code[i], b = x23$ISO3_code[j],
          dTFR = abs(x23$TFR[i] - x23$TFR[j]), dPGR = abs(x23$PopGrowthRate[i] - x23$PopGrowthRate[j]),
          dCDR = abs(x23$CDR[i] - x23$CDR[j]), dLEx = abs(x23$LEx[i] - x23$LEx[j]))]
tw <- pr[dTFR <= 0.05][order(-dPGR)][1:5]
print(tw[, .(a, b, dTFR, dPGR)])
guarda("twin_tfr_are", f1(x23[ISO3_code == "ARE", TFR], 2), sprintf("par top: %s-%s", tw$a[1], tw$b[1]))
tc <- pr[dCDR <= 0.1][order(-dLEx)][1:5]
print(tc[, .(a, b, dCDR, dLEx)])
guarda("cdr_prt", sprintf("%s per 1,000", f1(x23[ISO3_code == "PRT", CDR])), sprintf("par top: %s-%s (CDR %.3f)", tc$a[1], tc$b[1], x23[ISO3_code == "PRT", CDR]))

# --- Dispersión 2023 -----------------------------------------------------------
sdf <- function(v) function(d) sd(d[[v]])
cvf <- function(v) function(d) 100 * sd(d[[v]]) / mean(d[[v]])
ci <- boot_bloques(x23, sdf("LE65"))
guarda("sd_le65_2023", sprintf("%s years · IC [%s; %s]", f1(sd(x23$LE65), 3), f1(ci[1], 2), f1(ci[2], 2)))
ci <- boot_bloques(x23, cvf("LE65"))
guarda("cv_le65_2023", sprintf("%s%% · IC [%s; %s]", f1(cvf("LE65")(x23), 2), f1(ci[1]), f1(ci[2])))
ci <- boot_bloques(x23, sdf("MedianAgePop"))
guarda("sd_medage_2023", sprintf("%s years · IC [%s; %s]", f1(sd(x23$MedianAgePop), 3), f1(ci[1]), f1(ci[2])))

# --- Spearman CDR-LEx 1950 ------------------------------------------------------
x50 <- merge(p[Time == 1950 & ISO3_code %in% G], pais[, .(ISO3_code, subregion)], by = "ISO3_code")
rhof <- function(d) cor(d$CDR, d$LEx, method = "spearman")
ci <- boot_bloques(x50, rhof)
guarda("rho_cdr_lex_1950", sprintf("%s · IC [%s; %s]", f1(rhof(x50), 3), f1(ci[1], 3), f1(ci[2], 3)))

# --- Scorecard: R2 ajustado y R2 fuera de muestra ------------------------------
x23 <- merge(x23, p[Time == 2050, .(ISO3_code, pop50 = TPopulation1July)], by = "ISO3_code")
x23[, chg50 := 100 * (pop50 / TPopulation1July - 1)]
r2a <- function(y) function(d) summary(lm(d[[y]] ~ d$TFR))$adj.r.squared
ci <- boot_bloques(x23, r2a("chg50"))
guarda("r2_tfr_chg2050", sprintf("%s · IC [%s; %s]", f1(r2a("chg50")(x23), 3), f1(ci[1], 2), f1(ci[2], 2)))
cv_r2 <- function(y, xx, K = 10, R = 20, seed = SEMILLA) {
  set.seed(seed); n <- length(y)
  sapply(seq_len(R), function(r) {
    f <- sample(rep(seq_len(K), length.out = n)); pred <- numeric(n)
    for (k in seq_len(K)) { tr <- f != k; b <- coef(lm(y[tr] ~ xx[tr])); pred[!tr] <- b[1] + b[2] * xx[!tr] }
    1 - sum((y - pred)^2) / sum((y - mean(y))^2) })
}
cvm <- cv_r2(x23$MedianAgePop, x23$TFR)
guarda("r2_tfr_medage_cv", f1(mean(cvm), 4), sprintf("rango repeticiones %.4f–%.4f", min(cvm), max(cvm)))
cvc <- cv_r2(x23$CNMR, x23$TFR)
guarda("r2_tfr_cnmr_cv", f1(mean(cvc), 4), sprintf("rango repeticiones %.4f–%.4f", min(cvc), max(cvc)))

# --- PCA de 12 indicadores fijos -------------------------------------------------
VARS <- c("TFR", "CBR", "LEx", "LE65", "Q5", "Q1560", "CDR", "MedianAgePop",
          "PopGrowthRate", "CNMR", "PopSexRatio", "PopDensity")
wins <- function(v) { m <- mean(v); s <- sd(v); pmin(pmax(v, m - 3 * s), m + 3 * s) }
X12 <- x23[, c("ISO3_code", "subregion", VARS), with = FALSE]
X12[, PopDensity := log(PopDensity)]
cat("Winsorizados (CNMR ±3 DE, 2023):", X12[CNMR != wins(CNMR), ISO3_code], "\n")
X12[, CNMR := wins(CNMR)]
pcvar <- function(d) { pc <- prcomp(d[, ..VARS], scale. = TRUE); pc$sdev^2 / sum(pc$sdev^2) }
ve <- pcvar(X12)
ci <- boot_bloques(X12, function(d) pcvar(d)[2])
guarda("pc2_var", sprintf("%s%% · IC [%s; %s]", f1(100 * ve[2], 2), f1(100 * ci[1]), f1(100 * ci[2])),
       sprintf("PC1 = %.2f%%", 100 * ve[1]))
Z <- scale(as.matrix(X12[, ..VARS])); rownames(Z) <- X12$ISO3_code
recup <- function(Zm) { s <- prcomp(Zm)$x[, 1]; mean(apply(Zm, 2, function(v) summary(lm(v ~ s))$r.squared)) }
ci <- boot_bloques(X12, function(d) recup(scale(as.matrix(d[, ..VARS]))))
guarda("recov_pc1", sprintf("%s · IC [%s; %s]", f1(recup(Z), 3), f1(ci[1], 2), f1(ci[2], 2)))

# --- Look-alikes de Colombia y azar ---------------------------------------------
D12 <- as.matrix(dist(Z)); diag(D12) <- Inf
vec <- function(D, iso, k = 5) { dd <- D[iso, ]; nm <- names(dd); nm[order(dd, nm)][1:k] }
la <- vec(D12, "COL")
guarda("lookalikes_col_12", paste(pais[match(la, ISO3_code), Location], collapse = ", "), paste(la, collapse = " "))
# sensibilidad: sin winsorizar ni log de la densidad
Zr <- scale(as.matrix(x23[, ..VARS])); rownames(Zr) <- x23$ISO3_code
Dr <- as.matrix(dist(Zr)); diag(Dr) <- Inf
cat("Look-alikes COL sin winsorizar ni log:", vec(Dr, "COL"), "\n")
guarda("knn_chance", f1(100 * 5 / (161 - 1), 3), "k/(n-1)")

# --- Razón P90/P10 de Q5 por año -------------------------------------------------
est <- merge(p[Time <= 2023 & ISO3_code %in% G], pais[, .(ISO3_code, subregion, region_sdg, ingreso)], by = "ISO3_code")
rq <- est[, .(r7 = quantile(Q5, .9) / quantile(Q5, .1),
              r6 = quantile(Q5, .9, type = 6) / quantile(Q5, .1, type = 6)), by = Time]
guarda("q5_ratio_p90p10_peak_year", rq[which.max(r7), Time],
       sprintf("máx. %.1f; con type = 6: %d", max(rq$r7), rq[which.max(r6), Time]))

# --- Correlación entre décadas consecutivas ---------------------------------------
est[, dec := pmin(10 * (Time %/% 10), 2010)]       # 2010s = 2010-2023
dm <- est[, .(TFR = mean(TFR), LEx = mean(LEx)), by = .(ISO3_code, dec)]
rr <- sapply(c("TFR", "LEx"), function(v) {
  W <- dcast(dm, ISO3_code ~ dec, value.var = v)
  sapply(2:7, function(j) cor(W[[j]], W[[j + 1]])) })
print(round(rr, 4))
guarda("r_tfr_decades_min", f1(min(rr), 4), sprintf("min en %s", c("TFR", "LEx")[which(rr == min(rr), arr.ind = TRUE)[2]]))

# =============================================================================
# 3. Inicio de la caída sostenida (regla de Princeton) y Kaplan-Meier
# =============================================================================
inicio <- function(t, x, frac = 0.9) {        # primer año con x <= 90 % del máximo previo, sin volver a subir
  rm <- cummax(x)
  for (i in seq_along(x)) { lim <- frac * rm[i]
    if (x[i] <= lim && all(x[i:length(x)] <= lim)) return(as.numeric(t[i])) }
  NA_real_
}
setorder(est, ISO3_code, Time)
el <- est[, .(tfr50 = TFR[Time == 1950], ini_tfr = inicio(Time, TFR), ini_q5 = inicio(Time, Q5),
              ingreso = ingreso[1], subregion = subregion[1]), by = ISO3_code]
el <- el[tfr50 >= 5 & ingreso != "Not classified"]
cat("Elegibles (TFR1950>=5, ingreso clasificado):", nrow(el), "| inicio TFR observado:", el[!is.na(ini_tfr), .N],
    "| inicio Q5 observado:", el[!is.na(ini_q5), .N], "\n")
caida <- est[el[!is.na(ini_tfr), .(ISO3_code, ini_tfr)], on = "ISO3_code"][Time <= ini_tfr,
          .(caida = 100 * (max(Q5) - Q5[Time == ini_tfr[1]]) / max(Q5)), by = ISO3_code]
caida_glob <- est[el[!is.na(ini_tfr), .(ISO3_code, ini_tfr)], on = "ISO3_code"][,
          .(caida = 100 * (max(Q5) - Q5[Time == ini_tfr[1]]) / max(Q5)), by = ISO3_code]
caida <- merge(caida, pais[, .(ISO3_code, subregion)], by = "ISO3_code")
ci <- boot_bloques(caida, function(d) median(d$caida))
guarda("q5_drop_at_tfr_onset", sprintf("%s%% · IC [%s; %s]", f1(median(caida$caida), 2), f1(ci[1]), f1(ci[2])),
       sprintf("n = %d; con máximo de toda la serie: %.2f", nrow(caida), median(caida_glob$caida)))
lm_ <- el[ingreso == "Lower middle income"]
lm_[, `:=`(t = fifelse(is.na(ini_tfr), 2023, ini_tfr), e = as.integer(!is.na(ini_tfr)))]
km <- survfit(Surv(t, e) ~ 1, data = lm_)
kmq <- quantile(km, 0.5)                          # IC de la mediana (survival, conf.type = "log")
med_km <- min(km$time[km$surv <= 0.5 + 1e-12])     # definición literal: primer año con S(t) <= 0,5
guarda("yr_fert_onset_lowmid", sprintf("%s · IC [%s; %s]", med_km, kmq$lower, kmq$upper),
       sprintf("n = %d, eventos %d; quantile() de survival da %s (punto medio del tramo S = 0,5)",
               nrow(lm_), sum(lm_$e), kmq$quantile))

# =============================================================================
# 4. Registro por hitos: TFR suavizada (B-splines cúbicos, lambda = 10)
# =============================================================================
anios <- 1950:2023
YT <- as.matrix(dcast(est, Time ~ ISO3_code, value.var = "TFR")[, -1])
base <- create.bspline.basis(c(1950, 2023), nbasis = length(anios) + 2, norder = 4)
fdT <- smooth.basis(anios, YT, fdPar(base, Lfdobj = 2, lambda = 10))$fd
tf <- seq(1950, 2023, 0.1); Tf <- eval.fd(tf, fdT)
cruce <- function(y, u) { if (y[1] < u) return(-Inf); if (tail(y, 1) >= u) return(Inf)
  i <- max(which(y >= u)); tf[i] + (y[i] - u) / (y[i] - y[i + 1]) * 0.1 }
hit <- data.table(ISO3_code = colnames(YT), c5 = apply(Tf, 2, cruce, 5), c4 = apply(Tf, 2, cruce, 4), c3 = apply(Tf, 2, cruce, 3))
guarda("n_cens_der", hit[c4 == Inf, .N], sprintf("cruce de 4 observado: %d; censura izq.: %d", hit[is.finite(c4), .N], hit[c4 == -Inf, .N]))
hit[, dur := c3 - c5]
guarda("dur53_egy", sprintf("%s years", f1(hit[ISO3_code == "EGY", dur], 3)), sprintf("CHN %.3f", hit[ISO3_code == "CHN", dur]))
h10 <- merge(hit[is.finite(c5) & is.finite(c3)], pais[, .(ISO3_code, pob23)], by = "ISO3_code")[pob23 >= 10000]
setorder(h10, dur, ISO3_code)
mid <- h10[c(floor((nrow(h10) + 1) / 2), ceiling((nrow(h10) + 1) / 2))]
cat("Velocidad 5->3, >=10 M (n =", nrow(h10), "): posiciones centrales", paste(mid$ISO3_code, round(mid$dur, 2)), "| mediana", median(h10$dur), "\n")
med_iso <- h10[which.min(abs(dur - median(dur))), ISO3_code]
guarda("fig04_highlight_iso3", paste(h10$ISO3_code[1], med_iso, h10$ISO3_code[nrow(h10)], sep = ", "),
       sprintf("n = %d; centrales %s", nrow(h10), paste(mid$ISO3_code, collapse = "/")))

# =============================================================================
# 5. Panel en cambios quinquenales con efectos fijos
# =============================================================================
q <- est[, .(ISO3_code, Time, TFR, lQ5 = log(Q5))][, periodo := 5 * (Time %/% 5)]
q <- q[, .(TFR = mean(TFR), lQ5 = mean(lQ5)), by = .(ISO3_code, periodo)]
setorder(q, ISO3_code, periodo)
q[, `:=`(dTFR = TFR - shift(TFR), dlQ5 = lQ5 - shift(lQ5)), by = ISO3_code]
q[, `:=`(L0 = dlQ5, L1 = shift(dlQ5, 1), L2 = shift(dlQ5, 2), L3 = shift(dlQ5, 3), L4 = shift(dlQ5, 4)), by = ISO3_code]
qe <- merge(q[periodo >= 1975], pais[, .(ISO3_code, region_sdg, ingreso, subregion)], by = "ISO3_code")
cat("N panel:", nrow(qe), "\n")
FORM <- dTFR ~ L0 + L1 + L2 + L3 + L4 | ISO3_code + periodo
mitad <- function(m) log(0.5) * sum(coef(m)[paste0("L", 0:4)])
m_all <- feols(FORM, qe, cluster = ~ISO3_code)
cat("Todos: mitad de Q5 ->", round(mitad(m_all), 4), "\n")
d_eu <- qe[region_sdg == "Europe and Northern America"]
guarda("panel_eurna_halfq5", f1(mitad(feols(FORM, d_eu, cluster = ~ISO3_code)), 4), sprintf("n países = %d", uniqueN(d_eu$ISO3_code)))
d_um <- qe[ingreso == "Upper middle income"]
est_um <- mitad(feols(FORM, d_um, cluster = ~ISO3_code))
# bootstrap por bloques de subregión: cada copia de un país recibe su propio identificador
idx <- split(seq_len(nrow(d_um)), d_um$subregion)
set.seed(SEMILLA)
bt <- replicate(2000, {
  s <- sample(names(idx), length(idx), replace = TRUE)
  db <- rbindlist(lapply(seq_along(s), function(k) d_um[idx[[s[k]]]][, ISO3_code := paste0(ISO3_code, "_", k)]))
  tryCatch(mitad(feols(FORM, db, notes = FALSE, warn = FALSE)), error = function(e) NA_real_) })
ci <- quantile(bt, c(0.025, 0.975), na.rm = TRUE)
guarda("panel_upmid_halfq5", sprintf("%s · IC [%s; %s]", f1(est_um, 4), f1(ci[1], 2), f1(ci[2], 2)),
       sprintf("n países = %d; réplicas NA = %d", uniqueN(d_um$ISO3_code), sum(is.na(bt))))
# placebo: la serie de Q5 de otro país (permutación de países), 300 veces
ids <- unique(qe$ISO3_code)
set.seed(SEMILLA)
plac <- replicate(300, {
  perm <- setNames(sample(ids), ids)
  qp <- merge(qe[, .(ISO3_code, periodo, dTFR)],
              qe[, .(ISO3_code = unname(perm[ISO3_code]), periodo, L0, L1, L2, L3, L4)], by = c("ISO3_code", "periodo"))
  mitad(feols(FORM, qp, notes = FALSE, warn = FALSE)) })
qq <- quantile(plac, c(0.025, 0.975))
guarda("panel_placebo_hi", f1(qq[2], 4), sprintf("banda 95%% [%.4f; %.4f]", qq[1], qq[2]))

# =============================================================================
# 6. Clustering de trayectorias (k-means k = 4, 32 rasgos)
# =============================================================================
cn <- est[, .(ISO3_code, Time, TFR, LEx, MedianAgePop, CNMR)]
lim <- mean(cn$CNMR) + c(-3, 3) * sd(cn$CNMR)
cn[, CNMRw := pmin(pmax(CNMR, lim[1]), lim[2])]
cat(sprintf("Winsorización panel: [%.1f; %.1f], celdas recortadas %d de %d\n", lim[1], lim[2], cn[CNMR != CNMRw, .N], nrow(cn)))
cn[, dec := 10 * (Time %/% 10)]                     # 1950s ... 2020s (2020-2023)
V4 <- c("TFR", "LEx", "MedianAgePop", "CNMRw")
rasgos <- function(variante) {
  d <- copy(cn)
  if (variante == "z_anual") for (v in V4) set(d, j = v, value = (d[[v]] - mean(d[[v]])) / sd(d[[v]]))
  dm <- d[, lapply(.SD, mean), by = .(ISO3_code, dec), .SDcols = V4]
  if (variante == "z_decadas") for (v in V4) set(dm, j = v, value = (dm[[v]] - mean(dm[[v]])) / sd(dm[[v]]))
  W <- dcast(dm, ISO3_code ~ dec, value.var = V4)
  M <- as.matrix(W[, -1]); rownames(M) <- W$ISO3_code
  if (variante == "z_columna") M <- scale(M)
  M
}
nombra <- function(cl) {
  aux <- est[, .(cnmr = mean(CNMR[Time >= 2000]), tfr50 = TFR[Time == 1950],
                 a4 = if (any(TFR < 4)) as.numeric(min(Time[TFR < 4])) else NA_real_), by = ISO3_code]
  aux[, g := cl[ISO3_code]]
  aux[, .(cnmr_med = median(cnmr), a4_med = median(a4, na.rm = FALSE), ya4 = mean(tfr50 < 4),
          n = .N), by = g][, nombre := fcase(cnmr_med > 10, "Migration-led",
                                             (!is.na(a4_med) & a4_med < 1960) | ya4 > 0.5, "Early movers",
                                             is.na(a4_med) | a4_med > 1995, "Recent movers",
                                             default = "Fast movers")][]
}
km_var <- list()
for (vv in c("z_decadas", "z_anual", "z_columna")) {
  M <- rasgos(vv); set.seed(SEMILLA); k4 <- kmeans(M, 4, nstart = 50)
  nm <- nombra(setNames(k4$cluster, rownames(M)))
  km_var[[vv]] <- list(M = M, km = k4, nom = nm)
  cat("Variante", vv, ":", paste(nm$nombre, nm$n, collapse = " | "), "\n")
}
VAR_PRINC <- "z_anual"   # "z sobre todo el panel": media y DE de TODAS las celdas país-año 1950-2023 (memo FDA §4, zs()); luego medias por década
M <- km_var[[VAR_PRINC]]$M; k4 <- km_var[[VAR_PRINC]]$km; nm <- km_var[[VAR_PRINC]]$nom
grp <- setNames(nm$nombre[match(k4$cluster, nm$g)], rownames(M))
for (vv in names(km_var)) { g2 <- km_var[[vv]]$nom$nombre[match(km_var[[vv]]$km$cluster, km_var[[vv]]$nom$g)]
  cat("Concordancia", VAR_PRINC, "vs", vv, ":", mean(g2 == grp), "\n") }
ORD <- c("Early movers", "Fast movers", "Recent movers", "Migration-led")
tam <- table(factor(grp, ORD))
guarda("cluster_sizes", paste(paste0(ORD, ": ", tam), collapse = "; "), sprintf("variante %s", VAR_PRINC))
gp <- merge(data.table(ISO3_code = names(grp), grupo = grp), pais[, .(ISO3_code, Location, pob23)], by = "ISO3_code")
fast <- gp[grupo == "Fast movers"][order(-pob23)][1:3]
guarda("cluster_examples_fast", paste(fast$Location, collapse = ", "), paste(fast$ISO3_code, collapse = " "))
medoide <- sapply(ORD, function(g) { S <- M[grp == g, , drop = FALSE]; cen <- apply(S, 2, median)
  rownames(S)[which.min(sqrt(rowSums(sweep(S, 2, cen)^2)))] })
guarda("cluster_medoids", paste(paste0(ORD, ": ", pais[match(medoide, ISO3_code), Location]), collapse = "; "),
       paste(medoide, collapse = " "))
ml <- gp[grupo == "Migration-led"][order(-pob23)]
guarda("migration_led_members", paste(ml$Location, collapse = ", "), paste(ml$ISO3_code, collapse = " "))
ma50 <- merge(gp, p[Time == 2050, .(ISO3_code, ma = MedianAgePop)], by = "ISO3_code")[, .(m = median(ma)), by = grupo]
ma50 <- ma50[match(ORD, grupo)]
guarda("medage_2050_by_group", paste(paste0(ma50$grupo, ": ", f1(ma50$m)), collapse = "; "))

# Jaccard bootstrap por grupo (B = 200, nstart 20), función del memo FDA §4
# (la semilla se fija de nuevo justo antes del remuestreo, tras la partición de referencia)
jacc <- function(X, k, B = 200, seed = SEMILLA) { set.seed(SEMILLA); cl0 <- kmeans(X, k, nstart = 50)$cluster; J <- matrix(NA, B, k)
  set.seed(seed)
  for (b in 1:B) { idx <- sample(nrow(X), replace = TRUE); u <- unique(idx)
    clb <- kmeans(X[idx, ], k, nstart = 20)$cluster[match(u, idx)]
    for (g in 1:k) { A <- u[cl0[u] == g]; if (!length(A)) next
      J[b, g] <- max(sapply(1:k, function(h) { Bh <- u[clb == h]; length(intersect(A, Bh)) / length(union(A, Bh)) })) } }
  list(J = colMeans(J, na.rm = TRUE), cl0 = cl0) }
jj <- jacc(M, 4)
nom0 <- sapply(1:4, function(g) names(sort(table(grp[jj$cl0 == g]), decreasing = TRUE))[1])
# error de Monte Carlo: misma función con otras 19 semillas
jm <- sapply(2027:2045, function(sd_) min(jacc(M, 4, seed = sd_)$J))
guarda("jaccard_min", f1(min(jj$J), 4), paste0(paste(paste0(nom0, " ", round(jj$J, 3)), collapse = "; "),
       sprintf(" | mínimo con semillas 2027-2045: %.3f–%.3f (media %.3f)", min(jm), max(jm), mean(jm))))

# =============================================================================
# 7. Vecinos geográficos (label points de Natural Earth, haversine, kNN5)
# =============================================================================
ne <- st_drop_geometry(ne_countries(scale = "medium", returnclass = "sf"))
ne <- as.data.table(ne)[, .(code = fifelse(adm0_a3 == "KOS", "XKX", iso_a3_eh), lon = label_x, lat = label_y)]
ne <- ne[code %in% G][!duplicated(code)]
stopifnot(nrow(ne) == 161)
setkey(ne, code); ne <- ne[x23$ISO3_code]
hav <- function(lat1, lon1, lat2, lon2) { r <- pi / 180; a <- sin((lat2 - lat1) * r / 2)^2 +
  cos(lat1 * r) * cos(lat2 * r) * sin((lon2 - lon1) * r / 2)^2; 2 * 6371 * asin(pmin(1, sqrt(a))) }
DG <- outer(seq_len(161), seq_len(161), function(i, j) hav(ne$lat[i], ne$lon[i], ne$lat[j], ne$lon[j]))
dimnames(DG) <- list(ne$code, ne$code); diag(DG) <- Inf
vecinos <- t(apply(DG, 1, function(r) order(r)[1:5]))
W5 <- matrix(0, 161, 161); for (i in 1:161) W5[i, vecinos[i, ]] <- 1 / 5
moran <- function(v, W) { z <- v - mean(v); (length(v) / sum(W)) * sum(z * (W %*% z)) / sum(z^2) }
guarda("moran_tfr_2023", f1(moran(x23$TFR, W5), 4))
# voto de los 5 vecinos: mayoría; empate -> grupo del vecino empatado más cercano
gv <- grp[ne$code]
voto <- sapply(1:161, function(i) { vg <- gv[vecinos[i, ]]; tb <- table(vg); top <- names(tb)[tb == max(tb)]
  vg[vg %in% top][1] })
guarda("knn_vote_accuracy", f1(mean(voto == gv), 4), sprintf("%d de 161", sum(voto == gv)))
# Sensibilidad a la estandarización de los rasgos (no cambia las claves; solo documenta)
for (vv in names(km_var)) {
  g2 <- setNames(km_var[[vv]]$nom$nombre[match(km_var[[vv]]$km$cluster, km_var[[vv]]$nom$g)], rownames(km_var[[vv]]$M))
  gv2 <- g2[ne$code]
  v2 <- sapply(1:161, function(i) { vg <- gv2[vecinos[i, ]]; tb <- table(vg); top <- names(tb)[tb == max(tb)]; vg[vg %in% top][1] })
  m2 <- merge(data.table(ISO3_code = names(g2), grupo = g2), p[Time == 2050, .(ISO3_code, ma = MedianAgePop)],
              by = "ISO3_code")[, .(m = round(median(ma), 1)), by = grupo]
  cat(sprintf("Sensibilidad %s: tamaños %s | edad mediana 2050 %s | voto vecinos %.4f\n", vv,
              paste(names(table(g2)), table(g2), collapse = ", "), paste(m2$grupo, m2$m, collapse = ", "), mean(v2 == gv2)))
}

# =============================================================================
# 8. Edad mediana 30 -> 40 (estimaciones <= 2023 + proyección media >= 2024)
# =============================================================================
ma <- p[ISO3_code %in% G, .(ISO3_code, Time, MedianAgePop)]
setorder(ma, ISO3_code, Time)
ma <- merge(ma[, .(m50 = MedianAgePop[Time == 1950],
                   y30 = if (any(MedianAgePop >= 30)) as.numeric(min(Time[MedianAgePop >= 30])) else NA_real_,
                   y40 = if (any(MedianAgePop >= 40)) as.numeric(min(Time[MedianAgePop >= 40])) else NA_real_), by = ISO3_code],
            pais[, .(ISO3_code, subregion)], by = "ISO3_code")
ma[, anos := y40 - y30]
guarda("yrs_medage30_40_kor", sprintf("%.0f years", ma[ISO3_code == "KOR", anos]),
       sprintf("%.0f -> %.0f", ma[ISO3_code == "KOR", y30], ma[ISO3_code == "KOR", y40]))
coh <- ma[m50 < 30 & !is.na(y30) & y30 < 1990]
ci <- boot_bloques(coh, function(d) median(d$anos, na.rm = TRUE))
guarda("yrs_medage30_40_cohort_pre1990", sprintf("%s years · IC [%s; %s]", f1(median(coh$anos, na.rm = TRUE)), f1(ci[1]), f1(ci[2])),
       sprintf("n = %d; sin llegar a 40 en 2100: %d", nrow(coh), coh[is.na(y40), .N]))

# =============================================================================
# 9. Archivos del repositorio
# =============================================================================
h <- system2("sha256sum", file.path(RAIZ, "docs/hipotesis_preinscritas.md"), stdout = TRUE)
guarda("hyp_file_sha256_short", substr(h, 1, 12))
guarda("team_name", jsonlite::fromJSON(file.path(RAIZ, "docs/equipo.json"))$team_name)

out <- rbindlist(res)
fwrite(out, file.path(RAIZ, "docs/qa/verificacion_lote_1_resultados.csv"))
print(out)
cat("Tiempo:", round(difftime(Sys.time(), t0, units = "secs")), "s\n")
writeLines(capture.output(sessionInfo()), con = stdout())
