# Genera slides/js/iso_codes.js: ISO3 -> ISO2 (flag-icons) y nombres (WPP + countrycode)
suppressMessages({library(countrycode); library(jsonlite)})
d <- read.csv("data/processed/lookup_regiones.csv", stringsAsFactors = FALSE)
d$iso2 <- tolower(countrycode(d$ISO3, "iso3c", "iso2c", custom_match = c(XKX = "XK")))
d$cc_name <- countrycode(d$ISO3, "iso3c", "country.name.en", custom_match = c(XKX = "Kosovo"))
flags <- sub("\\.svg$", "", list.files("slides/node_modules/flag-icons/flags/4x3"))
sin_bandera <- d$ISO3[!d$iso2 %in% flags]
if (length(sin_bandera)) message("Sin bandera en flag-icons: ", paste(sin_bandera, collapse = ", "))
codes <- setNames(lapply(seq_len(nrow(d)), function(i) list(iso2 = d$iso2[i], name = d$nombre[i])), d$ISO3)
# Alias de nombres -> ISO3 (minúsculas): nombre WPP, nombre countrycode y alias ONU usados en pantalla
alias <- c(setNames(d$ISO3, tolower(d$nombre)), setNames(d$ISO3, tolower(d$cc_name)),
           c("turkiye" = "TUR", "türkiye" = "TUR", "turkey" = "TUR", "viet nam" = "VNM", "vietnam" = "VNM",
             "republic of korea" = "KOR", "south korea" = "KOR", "korea, republic of" = "KOR",
             "russia" = "RUS", "russian federation" = "RUS", "iran" = "IRN", "iran (islamic republic of)" = "IRN",
             "united states" = "USA", "united states of america" = "USA", "usa" = "USA",
             "united kingdom" = "GBR", "uk" = "GBR", "uae" = "ARE", "united arab emirates" = "ARE",
             "state of palestine" = "PSE", "kosovo" = "XKX", "kosovo (under unsc res. 1244)" = "XKX",
             "bolivia" = "BOL", "venezuela" = "VEN", "tanzania" = "TZA", "syria" = "SYR", "laos" = "LAO",
             "moldova" = "MDA", "dr congo" = "COD", "democratic republic of the congo" = "COD",
             "china, taiwan province of china" = "TWN", "taiwan" = "TWN", "czechia" = "CZE"))
alias <- alias[!duplicated(names(alias))]
out <- paste0(
  "/* Generado por slides/dev/gen_iso_codes.R a partir de data/processed/lookup_regiones.csv + countrycode.\n",
  "   NO editar a mano. ISO3 -> {iso2 (flag-icons), name (WPP Location)}; NAME_TO_ISO3 para resolver nombres. */\n",
  "window.COUNTRY_CODES = ", toJSON(codes, auto_unbox = TRUE), ";\n",
  "window.NAME_TO_ISO3 = ", toJSON(as.list(alias), auto_unbox = TRUE), ";\n")
writeLines(out, "slides/js/iso_codes.js", useBytes = TRUE)
cat("OK", nrow(d), "países;", length(alias), "alias\n")
