#!/usr/bin/env Rscript
# =============================================================================
# verificacion_lote_2.R — Verificación INDEPENDIENTE (agente "verificador-2")
# -----------------------------------------------------------------------------
# Recalcula desde los CSV CRUDOS de WPP2024 cada cifra del lote 2 de
# figures/numbers.json, SIN usar los scripts del repositorio (no hay source de
# R/0*.R ni lectura de data/processed/*.parquet). Solo se usan:
#   - ../WPP2024_Demographic_Indicators_Medium_csv.gz        (estimaciones + Medium)
#   - ../WPP2024_Demographic_Indicators_OtherVariants_csv.gz (IP 95 % de la ONU)
#   - data/processed/lookup_regiones.csv  (solo la columna region_sdg)
#   - data/raw/wb_api_income_2026-10-22.csv (grupo de ingreso World Bank FY2027)
# La subregión ONU (bloques del bootstrap) se deriva de ParentID del crudo
# (ParentID 918 = Northern America, que no aparece como fila en el archivo).
#
# Reglas: países = ISO3_code no vacío; estimaciones <= 2023 y proyección
# Medium >= 2024 nunca se mezclan en un mismo estadístico salvo que la
# definición lo pida (edad mediana 30 -> 40); set.seed(2026) antes de cada
# bloque aleatorio. Resultado: tabla clave / valor independiente / nota en
# docs/qa/verificacion_lote_2_resultados.csv
# Uso: Rscript docs/qa/verificacion_lote_2.R   (≈ 10-15 min)
# =============================================================================

suppressPackageStartupMessages({
  library(data.table); library(fda); library(survival); library(fixest)
  library(mclust); library(jsonlite)
})
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
SEMILLA <- 2026
RAIZ <- here::here()   # raíz del repositorio (archivo .here); antes, ruta fija de una máquina (jurado_etica I-8)
SALIDA <- file.path(RAIZ, "docs/qa/verificacion_lote_2_resultados.csv")
B_BLOQUES <- as.integer(Sys.getenv("B_BLOQUES", "2000"))   # réplicas del bootstrap por bloques
GOLFO <- c("ARE", "QAT", "KWT", "BHR", "OMN", "SAU")

res <- list()   # una fila por clave
anota <- function(clave, valor, nota = "") {
  res[[clave]] <<- data.table(clave = clave, valor_independiente = as.character(valor), nota = nota)
  cat(sprintf("[%s] %s  | %s\n", clave, valor, nota))
}

# --- 0. Datos crudos -----------------------------------------------------------
cat("Leyendo crudos...\n")
med <- fread(file.path(dirname(RAIZ), "WPP2024_Demographic_Indicators_Medium_csv.gz"),
             na.strings = "", encoding = "UTF-8")
locs <- unique(med[, .(LocID, Location)])
mundo <- med[LocID == 900]                                   # agregado "World"
pais <- med[!is.na(ISO3_code) & ISO3_code != "" & Time <= 2100]
stopifnot(uniqueN(pais$ISO3_code) == 237)

# Subregión ONU desde ParentID (918 = Northern America no viene como fila)
sub <- unique(pais[, .(ISO3_code, ParentID)])
sub <- merge(sub, locs, by.x = "ParentID", by.y = "LocID", all.x = TRUE)
sub[ParentID == 918, Location := "Northern America"]
setnames(sub, "Location", "subregion"); sub[, ParentID := NULL]
stopifnot(!anyNA(sub$subregion))

lk <- fread(file.path(RAIZ, "data/processed/lookup_regiones.csv"))[, .(ISO3_code = ISO3, region_sdg)]
wb <- fread(file.path(RAIZ, "data/raw/wb_api_income_2026-10-22.csv"))
NIVELES_ING <- c("Low income", "Lower middle income", "Upper middle income", "High income")
wb <- wb[ingreso_api %in% NIVELES_ING, .(ISO3_code = ISO3, ingreso = ingreso_api)]

meta <- unique(pais[, .(ISO3_code, Location)])
meta <- merge(meta, sub, by = "ISO3_code")
meta <- merge(meta, lk, by = "ISO3_code", all.x = TRUE)
meta <- merge(meta, wb, by = "ISO3_code", all.x = TRUE)
meta[is.na(ingreso), ingreso := "Not classified"]
meta <- merge(meta, pais[Time == 2023, .(ISO3_code, pop23 = TPopulation1July)], by = "ISO3_code")
meta[, g1m := pop23 >= 1000]                                  # TPopulation1July en miles
stopifnot(!anyNA(meta$region_sdg))
pais <- merge(pais, meta[, .(ISO3_code, subregion, region_sdg, ingreso, g1m)], by = "ISO3_code")
est  <- pais[Time <= 2023]                                    # estimaciones ONU
proj <- pais[Time >= 2024]                                    # proyección Medium
G <- meta[g1m == TRUE, ISO3_code]
cat("Países >= 1 M:", length(G), " subregiones con >= 1 M:", uniqueN(meta[g1m == TRUE]$subregion), "\n")

v23 <- est[Time == 2023]
setkey(v23, ISO3_code)
v23g <- v23[ISO3_code %in% G]

# --- utilidades ----------------------------------------------------------------
# Bootstrap por bloques de subregiones: remuestrea subregiones con reemplazo y
# junta todos sus países; devuelve IC percentil 95 %.
boot_bloques <- function(datos, estad, B = B_BLOQUES, seed = SEMILLA, id = "subregion") {
  bloques <- unique(datos[[id]])
  idx <- split(seq_len(nrow(datos)), datos[[id]])
  set.seed(seed)
  t <- vapply(seq_len(B), function(b) {
    s <- sample(bloques, length(bloques), replace = TRUE)
    ii <- unlist(idx[s], use.names = FALSE)
    out <- tryCatch(estad(datos[ii]), error = function(e) NA_real_)
    as.numeric(out)
  }, numeric(1))
  c(lo = unname(quantile(t, 0.025, na.rm = TRUE)), hi = unname(quantile(t, 0.975, na.rm = TRUE)),
    n_na = sum(is.na(t)))
}
fmt_ic <- function(ic, d = 2) sprintf("bloques propios [%s; %s]", round(ic["lo"], d), round(ic["hi"], d))

# =============================================================================
# 1. Cifras descriptivas y conteos (censo, sin aleatoriedad)
# =============================================================================
cat("\n== 1. Descriptivas y conteos ==\n")
anota("n_countries_1m", length(G), "TPopulation1July 2023 >= 1000 (miles), 237 con ISO3")
anota("n_ge1m", length(G), "alias de n_countries_1m")

# Estados soberanos: 237 menos mi propia lista de 42 territorios/áreas no miembros ni observadores
TERRITORIOS <- c("ASM","AIA","ABW","BMU","BES","VGB","CYM","HKG","MAC","TWN","COK","CUW","FLK","FRO",
                 "GUF","PYF","GIB","GRL","GLP","GUM","GGY","IMN","JEY","XKX","MTQ","MYT","MSR","NCL",
                 "NIU","MNP","PRI","REU","BLM","SHN","MAF","SPM","SXM","TKL","TCA","VIR","WLF","ESH")
stopifnot(length(unique(TERRITORIOS)) == 42, all(TERRITORIOS %in% meta$ISO3_code))
sober <- setdiff(meta$ISO3_code, TERRITORIOS)
anota("n_sovereign", length(sober),
      sprintf("237 - 42 territorios; incluye VAT=%s y PSE=%s (observadores)", "VAT" %in% sober, "PSE" %in% sober))

anota("cdr_tcd", round(v23["TCD"]$CDR, 3), sprintf("LEx TCD %.1f; MedianAge %.1f", v23["TCD"]$LEx, v23["TCD"]$MedianAgePop))
anota("cnmr_are_2023", v23["ARE"]$CNMR, "CNMR ARE 2023 (estimación)")
anota("tfr_are_2023", v23["ARE"]$TFR, "TFR ARE 2023")
anota("twin_tfr_blr", v23["BLR"]$TFR, "TFR BLR 2023")
anota("medage_chn_2050", proj[ISO3_code == "CHN" & Time == 2050]$MedianAgePop, "Medium 2050")
anota("world_pop_1950_bn", round(mundo[Time == 1950]$TPopulation1July / 1e6, 4), "LocID 900 World, 1 jul 1950")

# Regla de gemelos (161 países, 12 880 pares): |ΔTFR| <= 0,05 con máx |Δ crecimiento|; |ΔCDR| <= 0,1 con máx |ΔLEx|
pares <- CJ(a = v23g$ISO3_code, b = v23g$ISO3_code)[a < b]
pares[, `:=`(dTFR = abs(v23[a]$TFR - v23[b]$TFR), dG = abs(v23[a]$PopGrowthRate - v23[b]$PopGrowthRate),
             dCDR = abs(v23[a]$CDR - v23[b]$CDR), dLEx = abs(v23[a]$LEx - v23[b]$LEx))]
cat("Pares:", nrow(pares), "\n")
tw <- pares[dTFR <= 0.05][order(-dG)][1:5]; print(tw)
tc <- pares[dCDR <= 0.1][order(-dLEx)][1:5]; print(tc)
nota_tw <- sprintf("par superior regla TFR: %s-%s", tw$a[1], tw$b[1])
nota_tc <- sprintf("par superior regla CDR: %s-%s", tc$a[1], tc$b[1])
res$twin_tfr_blr$nota <- paste(res$twin_tfr_blr$nota, nota_tw, sep = "; ")
res$cdr_tcd$nota <- paste(res$cdr_tcd$nota, nota_tc, sep = "; ")

# Tipos de palanca 2023 (237)
v23[, tipo := fcase(NatChange > 0 & NetMigrations > 0 & PopChange > 0, "A",
                    NatChange > 0 & NetMigrations <= 0 & PopChange > 0, "B",
                    NatChange < 0 & PopChange > 0, "C",
                    NatChange < 0 & PopChange < 0, "D",
                    NatChange > 0 & PopChange < 0, "E", default = "otro")]
print(table(v23$tipo)); print(table(v23[g1m == TRUE]$tipo))
anota("n_type_A", v23[tipo == "A", .N], "Nat>0, NetMig>0, PopChange>0 (237, 2023)")
anota("n_type_D", v23[tipo == "D", .N], "Nat<0, PopChange<0 (237, 2023)")
ej <- function(t) paste(v23[tipo == t & g1m == TRUE][order(-TPopulation1July)]$ISO3_code[1:3], collapse = ", ")
anota("examples_type_B_iso3", ej("B"), sprintf("3 más poblados >= 1 M; n tipo B >= 1 M = %d", v23[tipo == "B" & g1m == TRUE, .N]))
anota("examples_type_D_iso3", ej("D"), sprintf("n tipo D >= 1 M = %d", v23[tipo == "D" & g1m == TRUE, .N]))
anota("n_below_repl_growing_2023", v23[TFR < 2.1 & PopChange > 0, .N],
      sprintf("de %d con TFR < 2,1; con Nat>0: %d; solo migración: %d", v23[TFR < 2.1, .N],
              v23[TFR < 2.1 & PopChange > 0 & NatChange > 0, .N], v23[TFR < 2.1 & PopChange > 0 & NatChange < 0, .N]))
anota("n_natneg_2023", v23[NatChange < 0, .N], "NatChange < 0, 237, 2023")

# ODS 3.2: ritmo observado 2015-23 vs necesario 2023-30
q5 <- dcast(est[Time %in% c(2015, 2023), .(ISO3_code, Time, Q5)], ISO3_code ~ Time, value.var = "Q5")
setnames(q5, c("ISO3_code", "q15", "q23"))
q5a <- q5[q23 > 25]
q5a[, `:=`(obs = 100 * log(q15 / q23) / 8, nec = 100 * log(q23 / 25) / 7)]
anota("n_sdg32_on_pace", q5a[obs >= nec, .N],
      sprintf("de %d con Q5 > 25 (237); mediana obs %.1f vs nec %.1f %%/año; en ritmo: %s", nrow(q5a),
              median(q5a$obs), median(q5a$nec), paste(q5a[obs >= nec]$ISO3_code, collapse = " ")))

# Participación de la migración en el crecimiento (sumas de personas) + bootstrap por bloques propio
part_mig <- function(grupo, a0, a1) {
  d <- est[ingreso == grupo & Time >= a0 & Time <= a1, .(mig = sum(NetMigrations), pc = sum(PopChange)),
           by = .(ISO3_code, subregion)]
  v <- 100 * sum(d$mig) / sum(d$pc)
  ic <- boot_bloques(d, function(x) 100 * sum(x$mig) / sum(x$pc))
  list(v = v, ic = ic, n = nrow(d))
}
pm <- part_mig("High income", 2010, 2023)
anota("share_mig_high_2010_2023", round(pm$v, 2), sprintf("n = %d; %s", pm$n, fmt_ic(pm$ic, 1)))
pm <- part_mig("Lower middle income", 2000, 2023)
anota("share_mig_lowmid_2000_2023", round(pm$v, 2), sprintf("n = %d; %s", pm$n, fmt_ic(pm$ic, 1)))

# IP 95 % de la ONU (OtherVariants)
ov <- fread(file.path(dirname(RAIZ), "WPP2024_Demographic_Indicators_OtherVariants_csv.gz"),
            na.strings = "", encoding = "UTF-8",
            select = c("ISO3_code", "Variant", "Time", "TPopulation1July"))
ov50 <- ov[Time == 2050 & ISO3_code %in% c("ARE", "CHN")]
print(ov50[grepl("PI", Variant)])
anota("pop_are_2050_pi95_high", round(ov50[ISO3_code == "ARE" & Variant == "Upper 95 PI"]$TPopulation1July / 1e3, 3),
      sprintf("millones; Medium %.1f, L95 %.1f", proj[ISO3_code == "ARE" & Time == 2050]$TPopulation1July / 1e3,
              ov50[ISO3_code == "ARE" & Variant == "Lower 95 PI"]$TPopulation1July / 1e3))
anota("pop_chn_2050_pi95_high", round(ov50[ISO3_code == "CHN" & Variant == "Upper 95 PI"]$TPopulation1July / 1e6, 4),
      sprintf("mil millones; Medium %.3f, L95 %.3f", proj[ISO3_code == "CHN" & Time == 2050]$TPopulation1July / 1e6,
              ov50[ISO3_code == "CHN" & Variant == "Lower 95 PI"]$TPopulation1July / 1e6))
rm(ov); invisible(gc())

# =============================================================================
# 2. Dispersión entre países (161, 1950), correlaciones y regresiones 2023
# =============================================================================
cat("\n== 2. Dispersión, correlaciones, regresiones ==\n")
v50g <- est[Time == 1950 & ISO3_code %in% G]
f_sd  <- function(x) sd(x$LEx)
f_cv  <- function(x) 100 * sd(x$LEx) / mean(x$LEx)
f_q5r <- function(x) unname(quantile(x$Q5, 0.9) / quantile(x$Q5, 0.1))
anota("sd_lex_1950", round(f_sd(v50g), 3), fmt_ic(boot_bloques(v50g, f_sd), 1))
anota("cv_lex_1950", round(f_cv(v50g), 3), fmt_ic(boot_bloques(v50g, f_cv), 1))
anota("q5_ratio_p90p10_1950", round(f_q5r(v50g), 3),
      paste("quantile type 7;", fmt_ic(boot_bloques(v50g, f_q5r), 1),
            sprintf("; type 6: %.2f", quantile(v50g$Q5, .9, type = 6) / quantile(v50g$Q5, .1, type = 6))))

# DE de la edad mediana por año dentro de la proyección Medium (separada de estimaciones)
sdp <- proj[ISO3_code %in% G & Time <= 2100, .(sd = sd(MedianAgePop)), by = Time]
sde <- est[ISO3_code %in% G, .(sd = sd(MedianAgePop)), by = Time]
anota("sd_medage_peak_year_proj", sdp[which.max(sd)]$Time,
      sprintf("DE máx proyección %.2f; máx en estimaciones: año %d", max(sdp$sd), sde[which.max(sd)]$Time))

f_rho <- function(x) cor(x$CDR, x$LEx, method = "spearman")
anota("rho_cdr_lex_2023", round(f_rho(v23g), 4), paste(fmt_ic(boot_bloques(v23g, f_rho)),
      sprintf("; Pearson %.3f", cor(v23g$CDR, v23g$LEx))))

r2adj <- function(f, d) summary(lm(f, d))$adj.r.squared
f_r2g <- function(x) r2adj(PopGrowthRate ~ TFR, x)
anota("r2_tfr_growth", round(f_r2g(v23g), 4), fmt_ic(boot_bloques(v23g, f_r2g)))
anota("r2_all", round(r2adj(PopGrowthRate ~ TFR + CDR + CNMR, v23g), 4),
      sprintf("con CBR: %.4f", r2adj(PopGrowthRate ~ CBR + CDR + CNMR, v23g)))

# R² fuera de muestra: % cambio de población 2023 -> 2050 (Medium) sobre TFR 2023, VC 10-fold x 20
p50 <- proj[Time == 2050 & ISO3_code %in% G, .(ISO3_code, pop50 = TPopulation1July)]
dcv <- merge(v23g[, .(ISO3_code, TFR, pop23 = TPopulation1July)], p50, by = "ISO3_code")
dcv[, chg := 100 * (pop50 / pop23 - 1)]
set.seed(SEMILLA)
r2cv <- replicate(20, {
  fold <- sample(rep(1:10, length.out = nrow(dcv)))
  pred <- numeric(nrow(dcv))
  for (k in 1:10) { m <- lm(chg ~ TFR, dcv[fold != k]); pred[fold == k] <- predict(m, dcv[fold == k]) }
  1 - sum((dcv$chg - pred)^2) / sum((dcv$chg - mean(dcv$chg))^2)
})
anota("r2_tfr_chg2050_cv", round(mean(r2cv), 4),
      sprintf("media de 20 repeticiones (rango %.3f-%.3f); R2 aj. en muestra %.3f", min(r2cv), max(r2cv),
              r2adj(chg ~ TFR, dcv)))

# Persistencia de la CNMR entre décadas consecutivas (1950s ... 2010s = 2010-2023)
dec <- est[ISO3_code %in% G][, decada := pmin(10 * (Time %/% 10), 2010)]
dm <- dcast(dec[, .(cnmr = mean(CNMR)), by = .(ISO3_code, decada)], ISO3_code ~ decada, value.var = "cnmr")
rr <- sapply(1:6, function(j) cor(dm[[j + 1]], dm[[j + 2]]))
names(rr) <- paste(names(dm)[2:7], names(dm)[3:8], sep = "-")
anota("r_cnmr_decades_max", round(max(rr), 4), paste(names(rr), round(rr, 2), collapse = "; "))

# =============================================================================
# 3. PCA de 12 indicadores (2023, 161), look-alikes e índice compuesto
# =============================================================================
cat("\n== 3. PCA, look-alikes, índice ==\n")
VARS12 <- c("TFR", "CBR", "LEx", "LE65", "Q5", "Q1560", "CDR", "MedianAgePop", "PopGrowthRate",
            "CNMR", "PopSexRatio", "logDens")
winsor3 <- function(x) { m <- mean(x); s <- sd(x); pmin(pmax(x, m - 3 * s), m + 3 * s) }
prep12 <- function(d) {
  d <- copy(d); d[, logDens := log(PopDensity)]
  recort <- d$ISO3_code[d$CNMR != winsor3(d$CNMR)]
  d[, CNMR := winsor3(CNMR)]
  Z <- scale(as.matrix(d[, ..VARS12])); rownames(Z) <- d$ISO3_code
  list(Z = Z, recort = recort)
}
p12 <- prep12(v23g); Z <- p12$Z
cat("CNMR winsorizada en:", paste(p12$recort, collapse = " "), "\n")
pc <- prcomp(Z)
ve <- pc$sdev^2 / sum(pc$sdev^2)
cat("Varianza PCs:", round(100 * ve[1:4], 1), "\n")
anota("n_pcs_70", which(cumsum(ve) >= 0.70)[1], sprintf("PC1 %.1f %%, PC1+PC2 %.1f %%", 100 * ve[1], 100 * sum(ve[1:2])))
orienta <- function(p) { s <- p$x[, 1:2]; if (p$rotation["LEx", 1] < 0) s[, 1] <- -s[, 1]; s }
S <- orienta(pc)
anota("r_tfr_pc1", round(cor(v23g$TFR, S[, 1]), 4), "")
recupera <- function(Zm, P) mean(sapply(colnames(Zm), function(v) summary(lm(Zm[, v] ~ P))$r.squared))
anota("recov_pc12", round(recupera(Z, S[, 1:2]), 4), "")

# Bootstrap por bloques: PCA recalculado en cada réplica (winsorización y z incluidas)
d23b <- v23g[, c("ISO3_code", "subregion", setdiff(VARS12, "logDens"), "PopDensity"), with = FALSE]
f_rpc1 <- function(x) { pp <- prep12(x); p <- prcomp(pp$Z); cor(x$TFR, orienta(p)[, 1]) }
f_rec  <- function(x) { pp <- prep12(x); p <- prcomp(pp$Z); recupera(pp$Z, orienta(p)[, 1:2]) }
res$r_tfr_pc1$nota <- fmt_ic(boot_bloques(d23b, f_rpc1), 3)
res$recov_pc12$nota <- fmt_ic(boot_bloques(d23b, f_rec), 3)

# Look-alikes: 5 vecinos en el perfil 12-D vs 5 vecinos por PC1
vecinos <- function(M, k = 5) { D <- as.matrix(dist(M)); diag(D) <- Inf
  t(apply(D, 1, function(r) order(r)[1:k])) }
NN12 <- vecinos(Z); NNp1 <- vecinos(S[, 1, drop = FALSE])
solap <- sapply(seq_len(nrow(Z)), function(i) length(intersect(NN12[i, ], NNp1[i, ])) / 5)
dk <- data.table(ISO3_code = rownames(Z), sh = solap)[v23g[, .(ISO3_code, subregion)], on = "ISO3_code"]
anota("knn_pc1", round(100 * mean(solap), 3), paste(fmt_ic(boot_bloques(dk, function(x) 100 * mean(x$sh)), 1),
      sprintf("; azar %.1f %%", 100 * 5 / 160)))
icol <- which(rownames(Z) == "COL")
anota("lookalikes_col_12_iso", paste(rownames(Z)[NN12[icol, ]], collapse = ", "),
      sprintf("por TFR sola: %s", paste(rownames(Z)[vecinos(Z[, "TFR", drop = FALSE])[icol, ]], collapse = ", ")))

# PC2 sin el Golfo (CNMR re-winsorizada en 155)
p155 <- prep12(v23g[!ISO3_code %in% GOLFO])
ve155 <- prcomp(p155$Z)$sdev^2; ve155 <- ve155 / sum(ve155)
anota("pc2_var_no_gulf", round(100 * ve155[2], 3), sprintf("n = %d; con Golfo PC2 %.1f %%", nrow(p155$Z), 100 * ve[2]))

# Índice compuesto: Monte Carlo de 2 000 diseños (Dirichlet(5), normalización, agregación, inclusión del crecimiento)
O <- as.matrix(v23g[, .(TFR = -TFR, Q5 = -Q5, LEx = LEx, MedAge = MedianAgePop, Growth = -PopGrowthRate)])
mm <- function(M) apply(M, 2, function(x) 0.01 + 0.99 * (x - min(x)) / (max(x) - min(x)))   # (0, 1] para la geométrica
rk <- function(M) apply(M, 2, rank)
geo <- function(M, w) exp(as.vector(log(M) %*% w))
set.seed(SEMILLA)
sims <- replicate(2000, {
  usa <- if (runif(1) < 0.5) 1:5 else 1:4
  w <- rgamma(length(usa), 5); w <- w / sum(w)
  norm <- sample(c("z", "mm", "rk"), 1); agg <- sample(c("arit", "geom"), 1)
  M <- switch(norm, z = scale(O[, usa]), mm = mm(O[, usa, drop = FALSE]), rk = rk(O[, usa, drop = FALSE]))
  s <- if (agg == "geom") geo(if (norm == "z") mm(O[, usa, drop = FALSE]) else M, w) else as.vector(M %*% w)
  rank(-s)
})
ancho90 <- apply(sims, 1, function(r) diff(quantile(r, c(0.05, 0.95))))
x20 <- sum(ancho90 > 20)
wil <- prop.test(x20, nrow(O), correct = FALSE)$conf.int
anota("share_rank_mc20", round(100 * x20 / nrow(O), 2),
      sprintf("%d de %d; Wilson propio [%.1f; %.1f]; más inciertos: %s", x20, nrow(O), 100 * wil[1], 100 * wil[2],
              paste(v23g$ISO3_code[order(-ancho90)][1:5], collapse = " ")))

# =============================================================================
# 4. Grupos de trayectoria (k-means sobre 32 rasgos) y cifras derivadas
# =============================================================================
cat("\n== 4. Clustering de trayectorias ==\n")
eg <- est[ISO3_code %in% G, .(ISO3_code, Time, TFR, LEx, MedianAgePop, CNMR)]
# CNMR winsorizada ±3 DE sobre todo el panel país-año 1950-2023 (161 países)
lim <- mean(eg$CNMR) + c(-3, 3) * sd(eg$CNMR)
cat(sprintf("Límites winsorización panel: [%.1f; %.1f]; celdas recortadas: %d\n", lim[1], lim[2],
            sum(eg$CNMR < lim[1] | eg$CNMR > lim[2])))
eg[, CNMRw := pmin(pmax(CNMR, lim[1]), lim[2])]
eg[, decada := 10 * (Time %/% 10)]                             # 1950s ... 2020s (2020-23)
# z con media y DE de TODO el panel anual país-año (no por año ni por columna), luego medias por década.
# Interpretación del plan ("z sobre todo el panel"; memo FDA zs()). Sensibilidad: z sobre las celdas década.
VARS4 <- c("TFR", "LEx", "MedianAgePop", "CNMRw")
ez <- copy(eg); for (v in VARS4) ez[, (v) := (get(v) - mean(get(v))) / sd(get(v))]
dmed <- ez[, lapply(.SD, mean), by = .(ISO3_code, decada), .SDcols = VARS4]
X <- as.matrix(dcast(dmed, ISO3_code ~ decada, value.var = VARS4)[, -1])
rownames(X) <- sort(unique(dmed$ISO3_code))
stopifnot(ncol(X) == 32, nrow(X) == 161)
set.seed(SEMILLA)
km <- kmeans(X, 4, nstart = 50)
cl <- km$cluster
sil <- mean(cluster::silhouette(cl, dist(X))[, 3])
cat("Tamaños:", table(cl), " silueta", round(sil, 3), "\n")

# Regla de nombres v2
yr4 <- est[ISO3_code %in% G, .(y4 = if (any(TFR < 4)) as.numeric(min(Time[TFR < 4])) else NA_real_,
                               bajo1950 = TFR[Time == 1950] < 4), by = ISO3_code]
c0023 <- est[ISO3_code %in% G & Time >= 2000, .(cnmr0023 = mean(CNMR)), by = ISO3_code]
gk <- data.table(ISO3_code = names(cl), k = cl)[yr4, on = "ISO3_code"][c0023, on = "ISO3_code"]
gk <- merge(gk, meta[, .(ISO3_code, pop23, region_sdg)], by = "ISO3_code")
reglas <- gk[, .(n = .N, cnmr_med = median(cnmr0023), y4_med = median(ifelse(is.na(y4), 2024, y4)),
                 n_nocruza = sum(is.na(y4)), may1950 = mean(bajo1950) > 0.5), by = k]
reglas[, nombre := fcase(cnmr_med > 10, "Migration-led",
                         y4_med < 1960 | may1950, "Early movers",
                         y4_med > 1995 | n_nocruza > n / 2, "Recent movers",
                         default = "Fast movers")]
print(reglas)
stopifnot(uniqueN(reglas$nombre) == 4)
gk <- merge(gk, reglas[, .(k, nombre)], by = "k")
anota("cluster_names", paste(reglas[order(match(nombre, c("Early movers", "Fast movers", "Recent movers", "Migration-led")))]$nombre, collapse = ", "),
      paste(sprintf("%s: n=%d, CNMR med %.1f, año med TFR<4 %s", reglas$nombre, reglas$n, reglas$cnmr_med, reglas$y4_med), collapse = "; "))
ejs <- gk[order(-pop23), .(top3 = paste(ISO3_code[1:3], collapse = ", ")), by = nombre]
ejs <- ejs[order(match(nombre, c("Early movers", "Fast movers", "Recent movers", "Migration-led")))]
anota("cluster_examples_iso3", paste(sprintf("%s: %s", ejs$nombre, ejs$top3), collapse = "; "),
      sprintf("silueta %.3f; tamaños %s", sil, paste(sprintf("%s %d", reglas$nombre, reglas$n), collapse = ", ")))
anota("india_group", gk[ISO3_code == "IND"]$nombre, "")
ml <- gk[nombre == "Migration-led"]$ISO3_code
anota("n_gulf_migration_led", sum(ml %in% GOLFO), sprintf("grupo Migration-led (%d): %s", length(ml), paste(ml, collapse = " ")))

# Sensibilidad: z por columna y z sobre las celdas década (en vez del panel anual)
set.seed(SEMILLA); cl_col <- kmeans(scale(X), 4, nstart = 50)$cluster
dcel <- eg[, lapply(.SD, mean), by = .(ISO3_code, decada), .SDcols = VARS4]
for (v in VARS4) dcel[, (v) := (get(v) - mean(get(v))) / sd(get(v))]
Xcel <- as.matrix(dcast(dcel, ISO3_code ~ decada, value.var = VARS4)[, -1])
set.seed(SEMILLA); cl_cel <- kmeans(Xcel, 4, nstart = 50)$cluster
ari_sens <- c(columna = adjustedRandIndex(cl, cl_col), celdas = adjustedRandIndex(cl, cl_cel))
cat("ARI principal vs z por columna / z en celdas década:", round(ari_sens, 3), "\n")

# --- FPCA multivariada (B-splines cúbicos, nodos anuales, penalización 2.ª derivada, λ = 10) ---
anios <- 1950:2023
mat_var <- function(v) { w <- dcast(eg, Time ~ ISO3_code, value.var = v); m <- as.matrix(w[, -1]); m[, rownames(X)] }
zs <- function(Y) (Y - mean(Y)) / sd(Y)                       # z con media y DE de todo el panel anual
Ymv <- array(NA_real_, c(length(anios), nrow(X), 4))
Ymv[, , 1] <- zs(mat_var("TFR")); Ymv[, , 2] <- zs(mat_var("LEx"))
Ymv[, , 3] <- zs(mat_var("MedianAgePop")); Ymv[, , 4] <- zs(mat_var("CNMRw"))
ari_fpca <- function(lambda) {
  base <- create.bspline.basis(c(1950, 2023), nbasis = length(anios) + 2, norder = 4)
  fdmv <- smooth.basis(anios, Ymv, fdPar(base, Lfdobj = 2, lambda = lambda))$fd
  p <- pca.fd(fdmv, nharm = 8)
  SC <- apply(p$scores, c(1, 2), sum)
  K <- which(cumsum(p$varprop) >= 0.90)[1]
  set.seed(SEMILLA); clf <- kmeans(SC[, 1:K], 4, nstart = 50)$cluster
  c(ari = adjustedRandIndex(clf, cl), K = K, var = sum(p$varprop[1:K]))
}
a10 <- ari_fpca(10); a1 <- ari_fpca(1); a100 <- ari_fpca(100)
anota("ari_fpca_decadas", round(a10["ari"], 4),
      sprintf("K = %d scores (%.1f %% var.); lambda 1: %.3f; lambda 100: %.3f", a10["K"], 100 * a10["var"], a1["ari"], a100["ari"]))

# --- Join count: kNN5 por distancia de gran círculo entre label points de Natural Earth ---
ne <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
ne <- data.table(sf::st_drop_geometry(ne))[, .(iso_a3, iso_a3_eh, adm0_a3, label_x, label_y, admin)]
cod <- data.table(ISO3_code = rownames(X))
busca <- function(iso) {
  alias <- c(XKX = "KOS", SSD = "SDS", PSE = "PSX")
  r <- ne[iso_a3 == iso]; if (!nrow(r)) r <- ne[iso_a3_eh == iso]; if (!nrow(r)) r <- ne[adm0_a3 == iso]
  if (!nrow(r) && iso %in% names(alias)) r <- ne[adm0_a3 == alias[iso]]
  if (nrow(r) > 1) r <- r[adm0_a3 == iso][1]
  r[1, .(label_x, label_y, admin)]
}
cod <- cbind(cod, rbindlist(lapply(cod$ISO3_code, busca)))
if (anyNA(cod$label_x)) print(cod[is.na(label_x)])
stopifnot(!anyNA(cod$label_x))
hav <- function(lon, lat) { R <- 6371; p <- pi / 180
  la <- lat * p; lo <- lon * p
  outer(seq_along(la), seq_along(la), function(i, j) {
    a <- sin((la[j] - la[i]) / 2)^2 + cos(la[i]) * cos(la[j]) * sin((lo[j] - lo[i]) / 2)^2
    2 * R * asin(pmin(1, sqrt(a))) }) }
Dk <- hav(cod$label_x, cod$label_y); diag(Dk) <- Inf
NNg <- t(apply(Dk, 1, function(r) order(r)[1:5]))
igual <- sapply(seq_len(nrow(NNg)), function(i) mean(cl[NNg[i, ]] == cl[i]))
set.seed(SEMILLA)
nulo <- replicate(999, { p <- sample(cl); mean(sapply(seq_len(nrow(NNg)), function(i) mean(p[NNg[i, ]] == p[i]))) })
anota("join_same_road", round(mean(igual), 4),
      sprintf("805 enlaces dirigidos; azar media %.3f (banda 95 %% %.3f-%.3f)", mean(nulo),
              quantile(nulo, .025), quantile(nulo, .975)))

# --- Crecimiento 2024-2050 por grupo: Σ NatChange y Σ NetMigrations (personas) como % de la población 2024 ---
pg <- merge(proj[ISO3_code %in% G & Time <= 2050, .(ISO3_code, Time, NatChange, NetMigrations, PopChange,
                                                     TPopulation1Jan, TPopulation1July)],
            gk[, .(ISO3_code, nombre)], by = "ISO3_code")
crec <- function(a1) pg[Time <= a1, .(nat = sum(NatChange), mig = sum(NetMigrations), tot = sum(PopChange)), by = nombre][
  pg[Time == 2024, .(p24jan = sum(TPopulation1Jan), p24jul = sum(TPopulation1July)), by = nombre], on = "nombre"]
for (a1 in c(2050, 2049)) {
  cc <- crec(a1)
  cat(sprintf("Años 2024-%d:\n", a1))
  print(cc[, .(nombre, nat_pct_jan = round(100 * nat / p24jan, 1), mig_pct_jan = round(100 * mig / p24jan, 1),
               tot_pct_jan = round(100 * tot / p24jan, 1), nat_pct_jul = round(100 * nat / p24jul, 1),
               nat_bn = round(nat / 1e6, 3), mig_bn = round(mig / 1e6, 3))])
}
cc <- crec(2050)[order(match(nombre, c("Early movers", "Fast movers", "Recent movers", "Migration-led")))]
anota("growth_2024_2050_by_group",
      paste(sprintf("%s: natural_pct=%.1f, migration_pct=%.1f, total_pct=%.1f, natural_bn=%.3f, migration_bn=%.3f",
                    cc$nombre, 100 * cc$nat / cc$p24jul, 100 * cc$mig / cc$p24jul, 100 * cc$tot / cc$p24jul,
                    cc$nat / 1e6, cc$mig / 1e6), collapse = " || "),
      paste("Σ 2024-2050 (27 años) de NatChange y NetMigrations (Medium); base = TPopulation1July 2024; total = Σ PopChange.",
            "Con base 1 de enero 2024: Recent natural 70.9 / total 68.1; Migration-led 37.5 / 41.2"))

# --- Edad mediana de 30 a 40 (estimaciones <= 2023 + Medium >= 2024), KM con censura en 2100 ---
ma <- pais[ISO3_code %in% G & Time <= 2100, .(y30 = if (any(MedianAgePop >= 30)) as.numeric(min(Time[MedianAgePop >= 30])) else NA_real_,
                                               y40 = if (any(MedianAgePop >= 40)) as.numeric(min(Time[MedianAgePop >= 40])) else NA_real_),
           by = ISO3_code]
ma <- merge(ma, gk[, .(ISO3_code, nombre)], by = "ISO3_code")
ma <- merge(ma, meta[, .(ISO3_code, subregion)], by = "ISO3_code")
ma[, `:=`(dur = ifelse(is.na(y40), 2100, y40) - y30, ev = as.integer(!is.na(y40)))]
km_med <- function(x) { f <- survfit(Surv(dur, ev) ~ 1, data = x); unname(summary(f)$table["median"]) }
ee <- ma[nombre == "Early movers" & !is.na(y30) & y30 > 1950]
anota("yrs_medage30_40_early", km_med(ee),
      sprintf("n = %d (excluidos %d ya >= 30 en 1950); eventos %d; %s", nrow(ee),
              ma[nombre == "Early movers" & y30 == 1950, .N], sum(ee$ev), fmt_ic(boot_bloques(ee, km_med), 1)))
ff <- ma[nombre == "Fast movers" & !is.na(y30)]
anota("yrs_medage30_40_recent", km_med(ff),
      sprintf("Fast movers: n = %d; llegan a 30 después de 2023: %d; llegan a 40 en proyección: %d; censurados 2100: %d; %s",
              nrow(ff), ff[y30 > 2023, .N], ff[y40 > 2023, .N], ff[ev == 0, .N], fmt_ic(boot_bloques(ff, km_med), 1)))
rm_ <- ma[nombre == "Recent movers" & !is.na(y30)]
res$yrs_medage30_40_recent$nota <- paste0(res$yrs_medage30_40_recent$nota,
  sprintf("; OJO: la clave dice 'recent' pero la definición es Fast movers. Recent movers: KM %s (n = %d, eventos %d)",
          km_med(rm_), nrow(rm_), sum(rm_$ev)))

# =============================================================================
# 5. TFR suavizada (cruces), inicios de la caída sostenida e inercia
# =============================================================================
cat("\n== 5. Cruces suavizados, inicios, inercia ==\n")
Ytfr <- mat_var("TFR")                                         # 74 años x 161 países (estimaciones)
base <- create.bspline.basis(c(1950, 2023), nbasis = length(anios) + 2, norder = 4)
fdTFR <- smooth.basis(anios, Ytfr, fdPar(base, Lfdobj = 2, lambda = 10))$fd
tf <- seq(1950, 2023, 0.1); Tf <- eval.fd(tf, fdTFR); colnames(Tf) <- colnames(Ytfr)
cruce <- function(y, u) { if (y[1] < u) return(-Inf); if (tail(y, 1) >= u) return(Inf)   # censura izq./der.
  i <- max(which(y >= u)); tf[i] + (y[i] - u) / (y[i] - y[i + 1]) * 0.1 }                # último cruce
cz <- data.table(ISO3_code = colnames(Tf), c5 = apply(Tf, 2, cruce, 5), c4 = apply(Tf, 2, cruce, 4),
                 c3 = apply(Tf, 2, cruce, 3))
cz <- merge(cz, meta[, .(ISO3_code, pop23, region_sdg)], by = "ISO3_code")
cz[, dur53 := c3 - c5]
d10 <- cz[pop23 >= 10000 & is.finite(c5) & is.finite(c3)][order(dur53)]
anota("dur53_fastest_ge10m", d10$ISO3_code[1],
      sprintf("n = %d (>= 10 M con 5 y 3 observados); %s; más lento: %s %.1f", nrow(d10),
              paste(sprintf("%s %.1f", d10$ISO3_code[1:3], d10$dur53[1:3]), collapse = ", "),
              tail(d10$ISO3_code, 1), tail(d10$dur53, 1)))
cens_der <- cz[c4 == Inf]
anota("n_cens_der_ssa", cens_der[region_sdg == "Sub-Saharan Africa", .N],
      sprintf("de %d con TFR suavizada >= 4 en 2023 (c4 = +Inf); observados %d, izq. %d; fuera de SSA: %s",
              nrow(cens_der), cz[is.finite(c4), .N], cz[c4 == -Inf, .N],
              paste(cens_der[region_sdg != "Sub-Saharan Africa"]$ISO3_code, collapse = " ")))

# Inicio de la caída sostenida (regla de Princeton): primer año con x <= 0,9 · máx previo que no vuelve a superarse
inicio <- function(t, x, frac = 0.9) { rmax <- cummax(x)
  for (i in seq_along(x)) { lim <- frac * rmax[i]; if (x[i] <= lim && all(x[i:length(x)] <= lim)) return(as.numeric(t[i])) }
  NA_real_ }
el <- est[ISO3_code %in% G & ingreso %in% NIVELES_ING][order(Time)][, .(
  tfr50 = TFR[Time == 1950], ini_tfr = inicio(Time, TFR), ini_q5 = inicio(Time, Q5),
  izq_q5 = which.max(Q5) == 1), by = .(ISO3_code, ingreso, subregion)][tfr50 >= 5]
cat(sprintf("Elegibles: %d; Q5 iniciado: %d; TFR iniciada: %d; Q5 con máximo en 1950: %d\n", nrow(el),
            el[!is.na(ini_q5), .N], el[!is.na(ini_tfr), .N], el[izq_q5 == TRUE, .N]))
mf <- el[!is.na(ini_q5)][, .(n = .N, primero = sum(is.na(ini_tfr) | ini_q5 < ini_tfr))]
f_lag <- function(x) median(pmax(x$ini_tfr - x$ini_q5, 0), na.rm = TRUE)
both <- el[!is.na(ini_tfr) & !is.na(ini_q5)]
anota("lag_onset_lower_bound", f_lag(both),
      sprintf("n = %d con ambos inicios (de %d elegibles); mortalidad primero %d/%d; %s", nrow(both), nrow(el),
              mf$primero, mf$n, fmt_ic(boot_bloques(both, f_lag), 1)))
cal <- copy(el)[, `:=`(t = ifelse(is.na(ini_tfr), 2023 - 1950, ini_tfr - 1950), e = as.integer(!is.na(ini_tfr)))]
cal[, ingreso := factor(ingreso, NIVELES_ING)]
fk <- survfit(Surv(t, e) ~ ingreso, data = cal)
tb <- summary(fk)$table
tbp <- tb[, c("records", "events", "median", "0.95LCL", "0.95UCL")]; tbp[, 3:5] <- tbp[, 3:5] + 1950; print(tbp)
um <- tb["ingreso=Upper middle income", ]
anota("yr_fert_onset_upmid", 1950 + um["median"],
      sprintf("n = %d, eventos %d; IC Brookmeyer-Crowley [%s; %s]; log-rank chi2 = %.1f", um["records"], um["events"],
              1950 + um["0.95LCL"], 1950 + um["0.95UCL"], survdiff(Surv(t, e) ~ ingreso, data = cal)$chisq))

# Inercia: tipo B & TFR < 2,1 (237, 2023) -> años desde 2023 hasta el pico de población (máx 2023-2100)
mom <- v23[tipo == "B" & TFR < 2.1, .(ISO3_code, pop23 = TPopulation1July)]
pico <- pais[ISO3_code %in% mom$ISO3_code & Time >= 2023 & Time <= 2100, .(pico = as.numeric(Time[which.max(TPopulation1July)])), by = ISO3_code]
mom <- merge(mom, pico, by = "ISO3_code")[, anios := pico - 2023][order(anios)]
wq <- function(x, w, p) { o <- order(x); x <- x[o]; cw <- cumsum(w[o]) / sum(w); x[which(cw >= p)[1]] }
wq_int <- function(x, w, p) { o <- order(x); x <- x[o]; w <- w[o]; cw <- (cumsum(w) - w / 2) / sum(w); approx(cw, x, p, rule = 2)$y }
q25 <- wq(mom$anios, mom$pop23, 0.25); q75 <- wq(mom$anios, mom$pop23, 0.75)
anota("momentum_years_range", sprintf("%d–%d", q25, q75),
      sprintf("n = %d; cuantil ponderado (1.er x con peso acumulado >= p); interpolado (punto medio): %.1f–%.1f; mediana ponderada %d; IND %d, BRA %d, MEX %d",
              nrow(mom), wq_int(mom$anios, mom$pop23, .25), wq_int(mom$anios, mom$pop23, .75), wq(mom$anios, mom$pop23, .5),
              mom[ISO3_code == "IND"]$anios, mom[ISO3_code == "BRA"]$anios, mom[ISO3_code == "MEX"]$anios))
print(mom)

# =============================================================================
# 6. Panel en cambios quinquenales con FE de país y periodo (161, 1975-2023)
# =============================================================================
cat("\n== 6. Panel quinquenal ==\n")
q <- est[ISO3_code %in% G, .(ISO3_code, subregion, ingreso, Time, TFR, lQ5 = log(Q5))]
q[, periodo := 5 * (Time %/% 5)]                               # 1950-54 ... 2020-23 (15 periodos)
q <- q[, .(TFR = mean(TFR), lQ5 = mean(lQ5)), by = .(ISO3_code, subregion, ingreso, periodo)]
setorder(q, ISO3_code, periodo)
q[, `:=`(dTFR = TFR - shift(TFR), dlQ5 = lQ5 - shift(lQ5)), by = ISO3_code]
q[, `:=`(L0 = dlQ5, L1 = shift(dlQ5, 1), L2 = shift(dlQ5, 2), L3 = shift(dlQ5, 3), L4 = shift(dlQ5, 4)), by = ISO3_code]
FORM <- dTFR ~ L0 + L1 + L2 + L3 + L4 | id + periodo
LAGS <- paste0("L", 0:4)
q[, id := ISO3_code]
suma_mitad <- function(d) { m <- feols(FORM, d, cluster = ~id, notes = FALSE, warn = FALSE)
  log(0.5) * sum(coef(m)[LAGS]) }
qe <- q[complete.cases(q[, c("dTFR", LAGS), with = FALSE])]
cat(sprintf("N = %d obs, %d países, periodos %d-%d\n", nrow(qe), uniqueN(qe$ISO3_code), min(qe$periodo), max(qe$periodo)))
m0 <- feols(FORM, qe, cluster = ~id)
se_sum <- sqrt(sum(vcov(m0)[LAGS, LAGS]))
v_within <- log(0.5) * sum(coef(m0)[LAGS])
# Bootstrap por bloques de subregión: cada copia de un país es una unidad distinta (FE y clúster propios)
boot_panel <- function(d, B = B_BLOQUES, seed = SEMILLA) {
  bl <- unique(d$subregion); idx <- split(seq_len(nrow(d)), d$subregion)
  set.seed(seed)
  vapply(seq_len(B), function(b) {
    s <- sample(bl, length(bl), replace = TRUE)
    dd <- rbindlist(lapply(seq_along(s), function(j) { x <- d[idx[[s[j]]]]; x[, id := paste(ISO3_code, j)]; x }))
    tryCatch(suma_mitad(dd), error = function(e) NA_real_) }, numeric(1))
}
bw <- boot_panel(qe)
anota("panel_within_halfq5", round(v_within, 4),
      sprintf("N = %d; suma de rezagos %.3f; IC clúster [%.2f; %.2f]; bloques propios [%.2f; %.2f] (%d subregiones)",
              nrow(qe), sum(coef(m0)[LAGS]), log(0.5) * (sum(coef(m0)[LAGS]) + 1.96 * se_sum),
              log(0.5) * (sum(coef(m0)[LAGS]) - 1.96 * se_sum), quantile(bw, .025, na.rm = TRUE),
              quantile(bw, .975, na.rm = TRUE), uniqueN(qe$subregion)))
qh <- qe[ingreso == "High income"]
v_high <- suma_mitad(qh)
bh <- boot_panel(qh)
anota("panel_high_halfq5", round(v_high, 4),
      sprintf("%d países de ingreso alto, %d subregiones; bloques propios [%.2f; %.2f]", uniqueN(qh$ISO3_code),
              uniqueN(qh$subregion), quantile(bh, .025, na.rm = TRUE), quantile(bh, .975, na.rm = TRUE)))
# Placebo: la serie de Q5 (rezagos) de otro país al azar, 300 permutaciones
paises_q <- unique(q$ISO3_code)
set.seed(SEMILLA)
plac <- replicate(300, {
  perm <- setNames(sample(paises_q), paises_q)
  xq <- q[, c("ISO3_code", "periodo", LAGS), with = FALSE][, ISO3_code := unname(perm[ISO3_code])]
  dp <- merge(q[, .(ISO3_code, periodo, dTFR)], xq, by = c("ISO3_code", "periodo"))
  dp <- dp[complete.cases(dp)][, id := ISO3_code]
  sum(coef(feols(dTFR ~ L0 + L1 + L2 + L3 + L4 | id + periodo, dp, notes = FALSE, warn = FALSE))[LAGS])
})
qp <- quantile(plac, c(0.025, 0.975))
anota("panel_placebo_lo", round(log(0.5) * qp[2], 4),
      sprintf("banda placebo de la suma [%.3f; %.3f] vs real %.3f; en mitades de Q5: [%.3f; %.3f]; p bilateral %.3f",
              qp[1], qp[2], sum(coef(m0)[LAGS]), log(0.5) * qp[2], log(0.5) * qp[1],
              (1 + sum(abs(plac) >= abs(sum(coef(m0)[LAGS])))) / 301))

# =============================================================================
# 7. Tabla final: valor independiente junto al valor de figures/numbers.json
# =============================================================================
tab <- rbindlist(res)
nj <- fromJSON(file.path(RAIZ, "figures/numbers.json"), simplifyVector = FALSE)
val_nb <- function(k) { v <- nj[[k]]$value
  if (is.null(v)) return(NA_character_)
  if (is.list(v)) return(as.character(toJSON(v, auto_unbox = TRUE)))
  paste(unlist(v), collapse = ", ") }
tab[, valor_notebook := vapply(clave, val_nb, character(1))]
setcolorder(tab, c("clave", "valor_notebook", "valor_independiente", "nota"))
fwrite(tab, SALIDA)
cat("\nResultados guardados en", SALIDA, "\n")
print(tab[, .(clave, valor_notebook = substr(valor_notebook, 1, 40), valor_independiente = substr(valor_independiente, 1, 40))])
