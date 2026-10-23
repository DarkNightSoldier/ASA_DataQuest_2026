#!/usr/bin/env Rscript
# =============================================================================
# 00_instalar_paquetes.R
# Instala (solo si faltan) y verifica los paquetes de R del proyecto
# ASA DataQuest 2026 - UN World Population Prospects 2024.
#
# Uso:   Rscript R/00_instalar_paquetes.R
# Salida: docs/paquetes_estado.csv (qué cargó y qué no), mensajes en consola.
#
# Notas:
#  - Instala en la librería de usuario (sin sudo).
#  - Los paquetes que necesitan librerías del sistema (sf, magick, av, gifski...)
#    se intentan al final y, si fallan, el script sigue y lo reporta.
#  - Si existe el prefijo ~/.local/opt/sysdeps-r (cabeceras -dev extraídas sin
#    sudo, ver SETUP.md), se usa para compilar sf, units, terra y magick.
#  - Si existen ~/.local/share/r-build-tools (cmake de PyPI, para s2/nloptr/
#    RcppParallel) y ~/.cargo (rustup, para gifski), se añaden al PATH.
#  - Ncpus=1 A PROPÓSITO para compilar (ver SETUP.md): con Ncpus>1, R arma un
#    Makefile paralelo para instalar varios paquetes a la vez y ese proceso no
#    propaga bien CPATH/PKG_CONFIG_PATH a cada sub-proceso -- eso rompía sf/
#    units/terra aunque las librerías sí estaban. En serie todo instala bien.
# =============================================================================

inicio <- Sys.time()
cat("== Instalación de paquetes R ==", format(inicio), "\n")
cat("R:", R.version.string, "\n")

# --- 1. Librería de usuario ---------------------------------------------------
lib_usuario <- Sys.getenv("R_LIBS_USER")
if (lib_usuario == "") {
  lib_usuario <- file.path("~/R", paste0(R.version$platform, "-library"),
                           paste(R.version$major, sub("\\..*", "", R.version$minor), sep = "."))
}
lib_usuario <- path.expand(lib_usuario)
dir.create(lib_usuario, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(lib_usuario, .libPaths()))
cat("Librería de usuario:", lib_usuario, "\n")

# Ncpus=1: ver nota arriba (evita el bug de env vars en Makefile paralelo).
# Para la DESCARGA (no la compilación) sí se puede paralelizar aparte si se
# quiere, pero no vale la pena la complejidad para una instalación de una vez.
options(repos = c(CRAN = "https://cloud.r-project.org"), Ncpus = 1,
        timeout = 1200, warn = 1)

# --- 2. Prefijo de cabeceras del sistema extraídas sin sudo (opcional) --------
prefijo_sysdeps <- path.expand(Sys.getenv("SYSDEPS_R", "~/.local/opt/sysdeps-r"))
hay_sysdeps <- dir.exists(file.path(prefijo_sysdeps, "usr"))
if (hay_sysdeps) {
  cat("Usando cabeceras del sistema extraídas en:", prefijo_sysdeps, "\n")
  libdir <- file.path(prefijo_sysdeps, "usr/lib/x86_64-linux-gnu")
  Sys.setenv(
    PATH = paste(file.path(prefijo_sysdeps, "usr/bin"), Sys.getenv("PATH"), sep = ":"),
    PKG_CONFIG_PATH = paste(file.path(libdir, "pkgconfig"),
                            file.path(prefijo_sysdeps, "usr/share/pkgconfig"),
                            Sys.getenv("PKG_CONFIG_PATH"), sep = ":"),
    CPATH = paste(file.path(prefijo_sysdeps, "usr/include"), Sys.getenv("CPATH"), sep = ":"),
    LIBRARY_PATH = paste(libdir, Sys.getenv("LIBRARY_PATH"), sep = ":"),
    LD_LIBRARY_PATH = paste(libdir, Sys.getenv("LD_LIBRARY_PATH"), sep = ":")
  )
  # Makevars de usuario: rpath para que los .so compilados encuentren las
  # librerías que solo existen en el prefijo (p. ej. libudunits2, libMagick++).
  makevars <- file.path(prefijo_sysdeps, "Makevars")
  writeLines(c(
    paste0("LDFLAGS = -Wl,-z,relro -Wl,-rpath,", libdir, " -L", libdir),
    paste0("CPPFLAGS = -I", file.path(prefijo_sysdeps, "usr/include"))
  ), makevars)
  Sys.setenv(R_MAKEVARS_USER = makevars)
} else {
  cat("AVISO: no existe", prefijo_sysdeps, "- sf/units/terra/magick probablemente",
      "fallarán. Ver SETUP.md para crearlo (dpkg -x de los .deb -dev, sin sudo)",
      "o instalar con sudo los paquetes del sistema que ahí se listan.\n")
}

# --- 2b. Herramientas de compilación extra (cmake, cargo), sin sudo -----------
# cmake (PyPI wheel en un venv dedicado): lo necesitan s2 (dependencia de sf)
# y RcppParallel/nloptr (dependencias de lme4).
ruta_cmake <- path.expand(Sys.getenv("CMAKE_BIN_DIR", "~/.local/share/r-build-tools/bin"))
if (dir.exists(ruta_cmake) && file.exists(file.path(ruta_cmake, "cmake"))) {
  Sys.setenv(PATH = paste(ruta_cmake, Sys.getenv("PATH"), sep = ":"))
  cat("cmake disponible en:", ruta_cmake, "\n")
} else if (Sys.which("cmake") == "") {
  cat("AVISO: no hay cmake en PATH. Si falta, crear un venv e instalar el",
      "wheel de PyPI: python3 -m venv ~/.local/share/r-build-tools && ",
      "~/.local/share/r-build-tools/bin/pip install cmake (ver SETUP.md).\n")
}
# cargo/rustc (rustup, instalado en espacio de usuario): lo necesita gifski.
ruta_cargo <- path.expand(Sys.getenv("CARGO_BIN_DIR", "~/.cargo/bin"))
if (dir.exists(ruta_cargo) && file.exists(file.path(ruta_cargo, "cargo"))) {
  Sys.setenv(PATH = paste(ruta_cargo, Sys.getenv("PATH"), sep = ":"))
  cat("cargo disponible en:", ruta_cargo, "\n")
} else if (Sys.which("cargo") == "") {
  cat("AVISO: no hay cargo en PATH. Si falta, instalar rustup sin sudo:",
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |",
      "sh -s -- -y --default-toolchain stable --profile minimal",
      "(ver SETUP.md).\n")
}

# --- 3. Listas de paquetes ----------------------------------------------------
# a) CRAN sin dependencias del sistema complicadas
paquetes_cran <- c(
  # manejo de datos
  "tidyverse", "data.table", "janitor", "jsonlite", "here", "renv", "remotes",
  "nanoparquet",            # lectura/escritura parquet ligera (respaldo de arrow)
  # gráficas
  "patchwork", "ggrepel", "scales", "viridis", "RColorBrewer", "ggthemes",
  "gganimate", "plotly", "htmlwidgets", "ggridges",
  "ggalluvial", "treemapify", "maps", "mapproj",   # maps: mapas sin sf (respaldo)
  "countrycode",
  # análisis
  "factoextra", "FactoMineR", "cluster", "dtwclust", "fda", "fda.usc",
  "forecast", "tseries", "plm", "lme4", "fixest", "mgcv", "broom",
  # reportes
  "kableExtra", "gt", "knitr", "rmarkdown", "IRkernel"
)
# b) requieren librerías del sistema (se intentan aparte, uno a uno)
# "av" casi seguro falla aquí: el -dev de ffmpeg disponible en el repo de Kali
# (9.0.2) no coincide con el runtime instalado (8.1.2); se deja en la lista
# para que, si algún día coinciden, se instale solo -- y si no, el mensaje de
# error exacto queda documentado en docs/instalacion_log.txt (ver SETUP.md §3).
paquetes_sistema <- c("units", "sf", "terra", "rnaturalearth", "rnaturalearthdata",
                      "transformr", "geofacet", "magick", "ggimage", "gifski", "av")
# c) arrow: compila libarrow (muy lento, necesita cmake o lo descarga)
paquetes_arrow <- c("arrow")
# d) GitHub (paquetes que no están en CRAN: ggflags nunca estuvo; ggbump y
#    ggstream fueron archivados de CRAN en nov/dic-2025 por falta de
#    mantenimiento -- siguen activos en GitHub, se instalan desde ahí).
paquetes_github <- c(ggflags = "jimjam-slam/ggflags",
                     ggbump = "davidsjoberg/ggbump",
                     ggstream = "davidsjoberg/ggstream")

faltan <- function(p) p[!vapply(p, requireNamespace, logical(1), quietly = TRUE)]

# --- 4. Instalación -----------------------------------------------------------
f <- faltan(paquetes_cran)
if (length(f)) {
  cat("\n-- Instalando CRAN (", length(f), "):", paste(f, collapse = ", "), "\n")
  install.packages(f, lib = lib_usuario, dependencies = NA)
} else cat("\n-- Todos los paquetes CRAN base ya estaban instalados.\n")

if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes", lib = lib_usuario)

for (p in faltan(paquetes_sistema)) {
  cat("\n-- Intentando", p, "(requiere librerías del sistema)\n")
  tryCatch(install.packages(p, lib = lib_usuario),
           error = function(e) cat("   ERROR en", p, ":", conditionMessage(e), "\n"))
}

if (!identical(Sys.getenv("OMITIR_ARROW"), "1")) {
  for (p in faltan(paquetes_arrow)) {
    cat("\n-- Intentando", p, "(compila libarrow; puede tardar >15 min)\n")
    Sys.setenv(ARROW_R_DEV = "false", LIBARROW_MINIMAL = "false", NOT_CRAN = "true")
    tryCatch(install.packages(p, lib = lib_usuario),
             error = function(e) cat("   ERROR en", p, ":", conditionMessage(e), "\n"))
  }
}

for (nm in names(paquetes_github)) {
  if (!requireNamespace(nm, quietly = TRUE)) {
    cat("\n-- Instalando desde GitHub:", paquetes_github[[nm]], "\n")
    tryCatch(remotes::install_github(paquetes_github[[nm]], lib = lib_usuario, upgrade = "never"),
             error = function(e) cat("   ERROR en", nm, ":", conditionMessage(e), "\n"))
  }
}

# --- 4b. Kernel de R para Jupyter (IRkernel) ----------------------------------
# Se registra para el usuario (no requiere sudo); usa el R del sistema
# (/usr/lib/R/bin/R) como intérprete, y se invoca con el `jupyter` de un venv
# de Python (ver SETUP.md) -- el registro en sí no depende de ese venv.
if (requireNamespace("IRkernel", quietly = TRUE)) {
  # Chequeo simple por archivo (no depende de que `jupyter` esté en el PATH
  # de esta sesión de R, que vive en un venv de Python aparte -- ver SETUP.md).
  ya_registrado <- file.exists(path.expand("~/.local/share/jupyter/kernels/ir/kernel.json"))
  if (!ya_registrado) {
    cat("\n-- Registrando kernel IRkernel para Jupyter (usuario) --\n")
    tryCatch(IRkernel::installspec(user = TRUE),
             error = function(e) cat("   ERROR registrando IRkernel:", conditionMessage(e), "\n"))
  } else {
    cat("\nKernel 'ir' ya registrado para Jupyter.\n")
  }
}

# --- 4c. Arreglo de carga en tiempo de ejecución (rpath) para sf/units/magick
# HALLAZGO (verificado): `units` y `magick` COMPILAN bien contra las cabeceras
# de ~/.local/opt/sysdeps-r, pero el .so resultante no trae un rpath propio,
# así que una sesión NUEVA de R no encuentra libudunits2.so.0 / libMagick++*.so
# (esas librerías no están en el cache de `ldconfig`, a diferencia de GDAL/
# GEOS/PROJ que sf y terra sí encuentran sin problema). `RcppParallel` (lo usa
# dtwclust) tiene el mismo problema con su propio `libtbbmalloc.so`. Se arregla
# una sola vez incrustando el rpath correcto con `patchelf` (sin sudo: se
# descarga el .deb con `apt-get download`, que no requiere privilegios, y se
# extrae con `dpkg -x`). Idempotente: si el rpath ya es correcto, no hace nada.
arreglar_rpath <- function(so, rpath, patchelf_bin) {
  if (!file.exists(so)) return(invisible())
  actual <- tryCatch(system2(patchelf_bin, c("--print-rpath", so), stdout = TRUE),
                      error = function(e) "")
  if (identical(actual, rpath)) return(invisible())
  cat("  rpath de", basename(so), "->", rpath, "\n")
  # system2() ya encierra cada elemento del vector como un argumento propio;
  # envolverlos de más con shQuote() duplica las comillas y rompe la llamada.
  system2(patchelf_bin, c("--set-rpath", rpath, so))
}

ruta_patchelf_local <- path.expand("~/.local/share/r-build-tools/bin/patchelf")
patchelf_bin <- if (file.exists(ruta_patchelf_local)) ruta_patchelf_local else Sys.which("patchelf")
if (identical(patchelf_bin, "") && hay_sysdeps) {
  cat("\n-- patchelf no encontrado; descargando sin sudo (apt-get download) --\n")
  tmp_dir <- tempfile(pattern = "patchelf_dl")
  dir.create(tmp_dir)
  destino <- path.expand("~/.local/share/r-build-tools")
  dir.create(file.path(destino, "bin"), recursive = TRUE, showWarnings = FALSE)
  # apt-get download escribe en el directorio de trabajo actual del proceso:
  # se cambia a un directorio temporal para no ensuciar el repo, y se
  # restaura el directorio original aunque algo falle (on.exit).
  dir_original <- getwd()
  setwd(tmp_dir)
  on.exit(setwd(dir_original), add = TRUE)
  salida <- tryCatch(
    system2("apt-get", c("download", "patchelf"), stdout = TRUE, stderr = TRUE),
    error = function(e) character(0))
  deb_descargado <- list.files(tmp_dir, pattern = "^patchelf.*\\.deb$", full.names = TRUE)
  if (length(deb_descargado) == 0) {
    cat("  (no se pudo descargar patchelf; salida:", paste(salida, collapse = " | "), ")\n")
  } else {
    system2("dpkg", c("-x", deb_descargado[1], destino))
    unlink(deb_descargado)
    if (file.exists(file.path(destino, "usr/bin/patchelf"))) {
      ok_copia <- file.copy(file.path(destino, "usr/bin/patchelf"), ruta_patchelf_local, overwrite = TRUE)
      if (isTRUE(ok_copia)) {
        Sys.chmod(ruta_patchelf_local, "0755")
        patchelf_bin <- ruta_patchelf_local
        cat("  patchelf instalado en", ruta_patchelf_local, "\n")
      }
    }
  }
}
if (!identical(patchelf_bin, "") && hay_sysdeps) {
  cat("\n-- Arreglando rpath de carga en tiempo de ejecución (patchelf) --\n")
  libdir_sysdeps <- file.path(prefijo_sysdeps, "usr/lib/x86_64-linux-gnu")
  arreglar_rpath(file.path(lib_usuario, "units/libs/units.so"), libdir_sysdeps, patchelf_bin)
  arreglar_rpath(file.path(lib_usuario, "magick/libs/magick.so"), libdir_sysdeps, patchelf_bin)
  arreglar_rpath(file.path(lib_usuario, "av/libs/av.so"), libdir_sysdeps, patchelf_bin)
  arreglar_rpath(file.path(lib_usuario, "RcppParallel/lib/libtbbmalloc_proxy.so"), "$ORIGIN", patchelf_bin)
  # Los .so de ffmpeg (si se extrajeron, ver SETUP.md §3.1) se buscan entre sí
  # -- cada uno también necesita el rpath apuntando al mismo directorio.
  for (so_ffmpeg in c("libavfilter.so.12", "libavformat.so.63", "libavcodec.so.63",
                       "libavutil.so.61", "libswresample.so.7", "libswscale.so.10")) {
    arreglar_rpath(file.path(libdir_sysdeps, so_ffmpeg), libdir_sysdeps, patchelf_bin)
  }
} else if (!hay_sysdeps) {
  cat("\n(se omite el arreglo de rpath: no hay prefijo sysdeps-r)\n")
} else {
  cat("\nAVISO: no se pudo obtener patchelf; `units`/`magick` pueden quedar",
      "instalados pero sin cargar en sesiones nuevas de R. Arreglo manual:",
      "apt-get download patchelf && dpkg -x patchelf*.deb /tmp/pe && ",
      "/tmp/pe/usr/bin/patchelf --set-rpath <sysdeps>/usr/lib/x86_64-linux-gnu <paquete>.so\n")
}

# --- 5. Verificación: cargar cada paquete -------------------------------------
todos <- c(paquetes_cran, paquetes_sistema, paquetes_arrow, names(paquetes_github))
estado <- data.frame(
  paquete = todos,
  instalado = vapply(todos, function(p) {
    r <- tryCatch(suppressPackageStartupMessages(requireNamespace(p, quietly = TRUE)),
                  error = function(e) FALSE)
    isTRUE(r)
  }, logical(1)),
  stringsAsFactors = FALSE
)
estado$version <- vapply(estado$paquete, function(p)
  tryCatch(as.character(packageVersion(p)), error = function(e) NA_character_), character(1))
estado$grupo <- ifelse(estado$paquete %in% paquetes_cran, "CRAN",
                ifelse(estado$paquete %in% paquetes_sistema, "CRAN (libs sistema)",
                ifelse(estado$paquete %in% paquetes_arrow, "CRAN (arrow)", "GitHub")))
estado$grupo[estado$paquete %in% c("ggbump", "ggstream")] <- "GitHub (archivado de CRAN)"

dir.create("docs", showWarnings = FALSE)
write.csv(estado, "docs/paquetes_estado.csv", row.names = FALSE)

cat("\n== Resumen ==\n")
print(estado[, c("paquete", "instalado", "version")], row.names = FALSE)
cat("\nInstalados:", sum(estado$instalado), "de", nrow(estado), "\n")
if (any(!estado$instalado))
  cat("NO disponibles:", paste(estado$paquete[!estado$instalado], collapse = ", "),
      "\n(ver SETUP.md para las dependencias del sistema que faltan)\n")
cat("Duración:", round(as.numeric(difftime(Sys.time(), inicio, units = "mins")), 1), "min\n")
