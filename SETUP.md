# SETUP — entorno del proyecto (R, Python/venv, Node, sin sudo)

Máquina: Kali GNU/Linux Rolling (Debian testing), sin privilegios de `sudo`.
Todo lo de abajo se instaló en espacio de usuario. Ver también
`docs/instalacion_log.txt` (log completo) y `docs/sessionInfo.txt`.

## 1. R

- **R 4.6.1**, librería de usuario: `~/R/x86_64-pc-linux-gnu-library/4.6`.
- Paquetes: `Rscript R/00_instalar_paquetes.R` (idempotente — solo instala lo
  que falte). Estado detallado en `docs/paquetes_estado.csv`.
- **Dependencias del sistema que los paquetes geoespaciales/multimedia
  necesitan (GDAL, GEOS, PROJ, ImageMagick, udunits2) ya estaban instaladas
  como paquetes *runtime* en el sistema (`libgdal39`, `libgeos3.15.0`,
  `libmagickcore-7.q16-10`, etc.) pero NO las cabeceras `-dev` (no se pueden
  instalar sin sudo).** Se resolvió extrayendo los `.deb` `-dev`
  correspondientes (descargados con `apt-get download`, que no requiere
  sudo) con `dpkg -x` a un prefijo de usuario:
  **`~/.local/opt/sysdeps-r/usr/`** (contiene `include/`, `lib/x86_64-linux-gnu/`,
  `lib/x86_64-linux-gnu/pkgconfig/`, `bin/` con `gdal-config`/`geos-config`).
  `R/00_instalar_paquetes.R` detecta ese prefijo automáticamente (variable
  `SYSDEPS_R`, por defecto `~/.local/opt/sysdeps-r`) y añade sus rutas a
  `PATH`, `PKG_CONFIG_PATH`, `CPATH`, `LIBRARY_PATH`, `LD_LIBRARY_PATH` antes
  de instalar `sf`/`units`/`terra`/`magick`. Si ese prefijo no existe en otra
  máquina, los paquetes de ese grupo fallan con un mensaje claro indicando
  qué paquete Debian falta (ver sección 3 más abajo con los nombres exactos).
- **cmake** (lo necesitan `s2` —dependencia de `sf`— y `RcppParallel`/`nloptr`
  —dependencias de `lme4`): no hay paquete de sistema sin sudo, así que se
  instaló el *wheel* de PyPI `cmake` en un venv de Python dedicado,
  **`~/.local/share/r-build-tools`** (persistente, fuera del repo y fuera del
  scratchpad de la sesión):
  ```bash
  python3 -m venv ~/.local/share/r-build-tools
  ~/.local/share/r-build-tools/bin/pip install cmake
  ```
  `R/00_instalar_paquetes.R` añade `~/.local/share/r-build-tools/bin` al
  `PATH` si existe.
- **Rust (cargo/rustc)**, lo necesita `gifski`: se instaló con `rustup` en
  espacio de usuario (sin sudo, instala en `~/.cargo` y `~/.rustup`):
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
  ```
  `R/00_instalar_paquetes.R` añade `~/.cargo/bin` al `PATH` si existe.
- **patchelf (arreglo de carga en tiempo de ejecución):** varios paquetes
  (`units`, `magick`, `av`, y `RcppParallel` -dependencia de `dtwclust`-)
  **compilan bien pero no cargan** en una sesión nueva de R
  (`libudunits2.so.0: cannot open shared object file`, etc.), porque sus
  librerías (extraídas en `~/.local/opt/sysdeps-r`) no están en el cache de
  `ldconfig` y el `.so` resultante no trae un rpath propio. `Sys.setenv(
  LD_LIBRARY_PATH=...)` **no sirve** para esto (el enlazador dinámico de
  Linux fija esa variable una sola vez, al arrancar el proceso, no cuando
  `Sys.setenv()` la cambia después). La solución real es incrustar el rpath
  correcto en cada `.so` con `patchelf --set-rpath` -- lo hace, una sola vez
  y de forma idempotente, `R/00_instalar_paquetes.R` (sección "4c"), que
  también descarga `patchelf` sin sudo (`apt-get download patchelf`) si no
  lo encuentra. Verificado con una sesión de R nueva: `library(units)`,
  `library(sf)`, `library(magick)`, `library(av)`, `library(dtwclust)`
  cargan todos sin pasos manuales.
- **Enlaces simbólicos rotos tras extraer solo el paquete `-dev` (sin el
  runtime a juego):** un paquete `-dev` de Debian suele traer `libfoo.so`
  como un symlink a `libfoo.so.N` **asumiendo** que el paquete runtime (que
  trae el `.so.N` real) está instalado en la MISMA carpeta -- cosa que no
  pasa en `~/.local/opt/sysdeps-r` cuando solo se extrajo el `-dev` (p. ej.
  `libcairo2-dev` sin `libcairo2`). Eso rompía el *enlazado* (no la carga)
  de `ggimage`→`gdtools` con `cannot find -lcairo` aunque el `-L` sí
  apuntaba al lugar correcto. Se arregló re-apuntando cada symlink roto al
  `.so.N` real que YA estaba instalado como paquete runtime del sistema
  (`/usr/lib/x86_64-linux-gnu/libcairo.so.2`, etc. -- 11 symlinks: cairo,
  cairo-gobject, cairo-script-interpreter, fontconfig, freetype, pixman-1,
  X11, xcb-render, xcb-shm, Xext, Xrender). Si se reconstruye el prefijo en
  otra máquina, revisar con `for f in ~/.local/opt/sysdeps-r/usr/lib/x86_64-linux-gnu/*.so; do [ -L "$f" ] && [ ! -e "$f" ] && echo "$f"; done`
  y apuntar cada uno a `/usr/lib/x86_64-linux-gnu/<mismo nombre>` si ya
  existe ahí (ver también la nota de `av`/ffmpeg más abajo).
- **Archivos `.pc` de `pkg-config` con `prefix=/usr` o `libdir=/usr/...`
  escritos a fuego** (no relativos a `${prefix}`): algunos paquetes Debian
  (cairo, fontconfig, freetype2, x11/xcb/xext/xrender, y **todos** los de
  ffmpeg: libavcodec/avformat/avutil/avfilter/swscale/swresample) generan su
  `.pc` con la ruta de instalación de Debian grabada literalmente, así que
  aunque el archivo viva en `~/.local/opt/sysdeps-r/usr/lib/.../pkgconfig/`,
  `pkg-config` seguía devolviendo `-I/usr/include/...` (rutas del sistema,
  donde ese contenido NO existe). Se arregló con `sed` sobre cada `.pc`
  afectado, reemplazando `prefix=/usr` (o `libdir=`/`includedir=` literales)
  por la ruta real del prefijo. Ver el bloque de ffmpeg/cairo más abajo para
  la receta exacta si hay que reconstruir el prefijo.
- **Importante sobre la instalación en paralelo:** el script fija
  `options(Ncpus = 1)` para la *compilación* de paquetes (no para la
  descarga). Se comprobó (ver `docs/instalacion_log.txt`) que con
  `Ncpus > 1`, R arma un Makefile paralelo para instalar varios paquetes con
  dependencias a la vez, y ese proceso paralelo **no propaga** las variables
  de entorno (`CPATH`, `PKG_CONFIG_PATH`, etc.) de la misma manera a cada
  sub-proceso — eso fue la causa real de que `units`/`sf`/`terra` fallaran en
  el primer intento, no una ausencia real de las librerías. Instalando en
  serie (`Ncpus = 1` para compilar) todo funciona con las mismas rutas.
- **IRkernel para Jupyter:** ya registrado (`IRkernel::installspec(user =
  TRUE)`) usando el Jupyter del venv de Python (sección 2). Verificado:
  ```bash
  PATH=/ruta/al/venv-jupyter/bin:$PATH jupyter kernelspec list
  # Available kernels: ir -> ~/.local/share/jupyter/kernels/ir
  ```
  El `kernel.json` registrado apunta a `/usr/lib/R/bin/R` (el R del sistema,
  correcto). El registro del kernel es independiente del venv: usa el R del
  sistema; el venv solo aporta el *launcher* `jupyter`.

## 2. Python (venv para Jupyter/notebook, ffmpeg portable y Playwright)

Venv de referencia (recreable, no se versiona):
```bash
python3 -m venv venv-jupyter   # o el nombre/ruta que se prefiera
venv-jupyter/bin/pip install jupyter nbconvert nbclient imageio-ffmpeg playwright
```
- **`imageio-ffmpeg`** trae un binario `ffmpeg` portable (no depende de que
  el sistema tenga `ffmpeg` instalado, que no lo tiene). Para usarlo desde R
  o shell:
  ```r
  ffmpeg_bin <- system2(
    file.path(venv, "bin", "python"),
    c("-c", "'import imageio_ffmpeg,sys;sys.stdout.write(imageio_ffmpeg.get_ffmpeg_exe())'"),
    stdout = TRUE)
  ```
  Verificado: `ffmpeg version 7.0.2-static` (johnvansickle.com build), con
  libx264/libx265/libvpx/libass, etc. — suficiente para `MP4 H.264`.
- **`playwright`** (el paquete de Python) está instalado en el venv, pero
  **sin** descargar sus propios navegadores: el plan es usar el Chromium **del
  sistema** (`/usr/bin/chromium`, ya instalado) pasándolo como
  `executable_path` al lanzar el browser, para no duplicar un Chromium de
  ~300 MB. Si algún agente necesita el Chromium propio de Playwright,
  `playwright install chromium` funciona igual dentro del venv (no se
  ejecutó, para no gastar espacio/tiempo innecesariamente).
- **Ejecutar un notebook `.ipynb` de R de principio a fin** (lo usa `make
  notebook` en `docs/00_plan_implementacion.md` §8):
  ```bash
  PATH=/ruta/al/venv-jupyter/bin:$PATH \
    jupyter nbconvert --to notebook --execute --inplace notebook/analisis_wpp2024.ipynb
  PATH=/ruta/al/venv-jupyter/bin:$PATH \
    jupyter nbconvert --to html notebook/analisis_wpp2024.ipynb
  ```
  Verificado end-to-end en esta sesión con un notebook mínimo de prueba
  (celda de R con `cat()`/`print()`): se ejecuta y el output queda embebido
  en el `.ipynb` de salida.

## 3. Si en otra máquina NO se puede evitar `sudo` (receta exacta)

Para no depender del truco de `~/.local/opt/sysdeps-r`, en Debian/Ubuntu con
sudo bastaría:
```bash
sudo apt install libgdal-dev libgeos-dev libproj-dev libudunits2-dev \
                  libmagick++-dev libsqlite3-dev cmake \
                  libavcodec-dev libavformat-dev libavutil-dev \
                  libswscale-dev libswresample-dev libavfilter-dev \
                  libcairo2-dev libxcb-render0-dev libxcb-shm0-dev \
                  gifsicle ffmpeg cargo rustc
```
Con `sudo apt install` normal, apt instala runtime y `-dev` de la MISMA
versión a la vez y ningún problema de los de abajo existe.

### 3.1 Receta completa sin sudo usada en esta máquina (para reconstruir
`~/.local/opt/sysdeps-r` desde cero en otra sesión/máquina Kali similar)

**`av` (paquete de R, lee/escribe audio y vídeo con ffmpeg):** el runtime de
ffmpeg ya instalado en el sistema es la versión **8.1.2** (`libavcodec62`,
etc.) pero el único `-dev` disponible en el repo de Kali es de la versión
**9.0.2** -- son ABIs distintas. La solución (ya aplicada, no mezcla
versiones del sistema) fue descargar TAMBIÉN el runtime 9.0.2 bajo otro
nombre de paquete (`libavcodec63`, no `libavcodec62`) y extraer ambos
-dev y runtime-9.0.2 al prefijo de usuario, dejando el sistema intacto:
```bash
cd /tmp
apt-get download libavcodec-dev libavformat-dev libavutil-dev \
  libavfilter-dev libswscale-dev libswresample-dev \
  libavcodec63 libavformat63 libavutil61 libavfilter12 \
  libswscale10 libswresample7
for f in libav*.deb libsw*.deb; do dpkg -x "$f" ~/.local/opt/sysdeps-r; done

# Los .pc de ffmpeg traen libdir/includedir grabados a fuego en /usr/... :
PCDIR=~/.local/opt/sysdeps-r/usr/lib/x86_64-linux-gnu/pkgconfig
SYSDEPS=~/.local/opt/sysdeps-r
for f in libavcodec libavfilter libavformat libavutil libswscale libswresample; do
  sed -i "s|^libdir=/usr/|libdir=$SYSDEPS/usr/|; s|^includedir=/usr/|includedir=$SYSDEPS/usr/|" "$PCDIR/$f.pc"
done
```
`R/00_instalar_paquetes.R` luego incrusta el rpath en `av.so` **y** en los 6
`.so` de ffmpeg que acaban de extraerse (se buscan unos a otros entre sí),
con `patchelf`. Verificado: `library(av)` carga limpio en una sesión nueva.

**`ggimage` (paquete de R, incrusta imágenes/banderas en ggplot, vía
`gdtools`→cairo):**
```bash
cd /tmp
apt-get download libcairo2-dev libfontconfig-dev libfreetype-dev \
  libpixman-1-dev libx11-dev libxext-dev libxrender-dev \
  libxcb-render0-dev libxcb-shm0-dev
for f in lib*-dev_*.deb; do dpkg -x "$f" ~/.local/opt/sysdeps-r; done

# Arreglar prefix=/usr en los .pc de cairo/fontconfig/x11/etc (usan ${prefix}
# correctamente, así que solo hay que corregir esa primera línea):
PCDIR=~/.local/opt/sysdeps-r/usr/lib/x86_64-linux-gnu/pkgconfig
SYSDEPS=~/.local/opt/sysdeps-r
grep -l '^prefix=/usr$' "$PCDIR"/*.pc | xargs sed -i "s|^prefix=/usr\$|prefix=$SYSDEPS/usr|"
# freetype2.pc es la excepción con libdir/includedir literales:
sed -i "s|^libdir=/usr/|libdir=$SYSDEPS/usr/|; s|^includedir=/usr/|includedir=$SYSDEPS/usr/|" "$PCDIR/freetype2.pc"

# Los -dev de cairo/fontconfig/freetype/pixman/x11/xext/xrender/xcb solo
# traen el symlink SIN VERSIÓN (libfoo.so -> libfoo.so.N), apuntando a un
# libfoo.so.N que no se extrajo (solo el -dev, no el runtime, al prefijo) --
# se re-apunta cada symlink roto al runtime REAL que ya está instalado en
# el sistema (fuera del prefijo):
SYS=/usr/lib/x86_64-linux-gnu
for f in "$SYSDEPS/usr/lib/x86_64-linux-gnu"/*.so; do
  if [ -L "$f" ] && [ ! -e "$f" ]; then
    t=$(readlink "$f"); [ -e "$SYS/$t" ] && ln -sf "$SYS/$t" "$f"
  fi
done
```
Verificado: `install.packages("ggimage")` compila, enlaza y carga limpio.

**`patchelf` (necesario para los dos arreglos de arriba, y para `units`/
`magick`/`RcppParallel`):**
```bash
cd /tmp && apt-get download patchelf
dpkg -x patchelf_*.deb ~/.local/share/r-build-tools
cp ~/.local/share/r-build-tools/usr/bin/patchelf ~/.local/share/r-build-tools/bin/
```
`R/00_instalar_paquetes.R` hace esto automáticamente si no encuentra
`patchelf` en el `PATH`.

## 4. Node / npm (diapositivas reveal.js)

Node v24.19.0, npm 11.19.0 (ya instalados). Dependencias de `slides/`
vendorizadas con `npm install` (ver `slides/README.md`); `node_modules/` no
se versiona.
