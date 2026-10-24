#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
construir_notebook.py — construye notebook/analisis_wpp2024.ipynb (kernel "ir")
a partir de los scripts R/01–05 y de las lecturas de docs/resultados_q*.md.

Uso (desde cualquier carpeta; python del venv de Jupyter del proyecto):
    <venv-jupyter>/bin/python -I notebook/construir_notebook.py
Después se ejecuta y se exporta:
    jupyter nbconvert --to notebook --execute --inplace \
        --ExecutePreprocessor.timeout=3600 notebook/analisis_wpp2024.ipynb
    python -I notebook/exportar_html.py   # HTML con texto alternativo en cada figura

Decisiones (ASA 2022, B.4 y F.4: reproducibilidad):
  * El código de las celdas es COPIA LITERAL de R/01_preparar_datos.R,
    R/02_q1_palancas.R, R/03_q2_un_numero.R, R/04_q3_caminos.R y
    R/05_numbers_json.R: correr el notebook o correr los scripts con Rscript
    ejecuta exactamente lo mismo. Las celdas se cortan solo en los encabezados
    de sección o subsección y NUNCA dentro de una expresión de R (se comprueba
    con parse() de R, que da la línea de inicio y fin de cada expresión).
  * Cada pregunta empieza con el entorno global vacío (como un Rscript nuevo):
    así las funciones auxiliares de una pregunta no pueden alterar otra.
  * Las "Lecturas de resultados" se copian de docs/resultados_q*.md (escritas
    por los agentes de análisis con las cifras reales de la corrida oficial);
    las cifras de la introducción se leen de figures/numbers.json.
  * Las figuras de revisión se muestran justo después de la sección que las
    regenera, reducidas a 1200 px de ancho para que el notebook no pese
    demasiado (los PNG originales quedan en figures/review/).

Convención: código y comentarios en español; textos de gráficas en inglés.
"""
from __future__ import annotations

import json
import re
import subprocess
import sys
from decimal import Decimal, ROUND_HALF_UP
from pathlib import Path

import nbformat as nbf

REPO = Path(__file__).resolve().parents[1]
SALIDA = REPO / "notebook" / "analisis_wpp2024.ipynb"
NUMBERS = REPO / "figures" / "numbers.json"
EQUIPO = REPO / "docs" / "equipo.json"

# ---------------------------------------------------------------------------
# 0. Ayudas generales
# ---------------------------------------------------------------------------

def md(texto: str):
    return nbf.v4.new_markdown_cell(texto.strip("\n"))


def code(texto: str):
    return nbf.v4.new_code_cell(texto.strip("\n"))


def leer(ruta: Path) -> str:
    return ruta.read_text(encoding="utf-8")


NUM = json.loads(leer(NUMBERS)) if NUMBERS.exists() else {}


def _redondear(x: float, d: int) -> float:
    q = Decimal(1).scaleb(-d)
    return float(Decimal(repr(x)).quantize(q, rounding=ROUND_HALF_UP))


def _decimales(fmt) -> int:
    if not isinstance(fmt, str):
        return 2
    m = re.search(r"\.(0+)", fmt)
    return len(m.group(1)) if m else 0


def fnum(x: float, d: int) -> str:
    """Número con coma decimal y espacio de miles (texto en español)."""
    r = _redondear(x, d)
    s = f"{abs(r):,.{d}f}".replace(",", " ").replace(".", ",")
    return ("−" + s) if (r < 0) else s


def N(clave: str, d: int | None = None, campo: str = "value") -> str:
    """Cifra de figures/numbers.json formateada para el texto (falla si no existe)."""
    if clave not in NUM:
        raise KeyError(f"La clave '{clave}' no está en figures/numbers.json")
    e = NUM[clave]
    v = e.get(campo)
    if v is None:
        raise KeyError(f"La clave '{clave}' no tiene el campo '{campo}'")
    if isinstance(v, bool):
        return str(v)
    if isinstance(v, (int, float)):
        if e.get("unit") == "year" and campo in ("value", "ci_low", "ci_high"):
            # Los años van sin separador de miles (1970, no "1 970").
            return str(int(_redondear(float(v), 0)))
        dd = d if d is not None else _decimales(e.get("fmt"))
        return fnum(float(v), dd)
    if isinstance(v, list):
        return ", ".join(str(z) for z in v)
    return str(v)


# ---------------------------------------------------------------------------
# 1. Corte de los scripts en celdas lógicas
# ---------------------------------------------------------------------------
R_RANGOS = r"""
args <- commandArgs(trailingOnly = TRUE)
ex <- parse(file = args[1], keep.source = TRUE)
sr <- attr(ex, "srcref")
m <- t(vapply(sr, function(s) c(s[1], s[3]), numeric(2)))
cat(jsonlite::toJSON(unname(m)))
"""


def rangos_expresiones(ruta: Path) -> list[tuple[int, int]]:
    """Líneas (1-based) de inicio y fin de cada expresión de primer nivel."""
    res = subprocess.run(["Rscript", "-e", R_RANGOS, str(ruta)], capture_output=True, text=True, check=True)
    return [tuple(int(v) for v in par) for par in json.loads(res.stdout)]


RE_REGLA = re.compile(r"^# [=\-]{10,}\s*$")
RE_MAYOR = re.compile(r"^# (\d+[a-z]?)\. (.+?)\s*$")
RE_MENOR = re.compile(r"^# (\d+)\.(\d+)([a-z]?)\s")
RE_CONT = re.compile(r"^#\s{3,}(\S.*)$")
RE_FIG = re.compile(r'"(q[123]_\d+[a-z]?_[A-Za-z0-9_]+)"')


def _es_codigo(lin: str) -> bool:
    s = lin.strip()
    return bool(s) and not s.startswith("#")


def cortar_script(ruta: Path, titulos_manual: dict | None = None):
    """Devuelve (cabecera, secciones). Cada sección: id, titulo, trozos (texto), figuras."""
    lineas = leer(ruta).split("\n")
    if lineas and lineas[-1] == "":
        lineas = lineas[:-1]
    n = len(lineas)
    dentro = [False] * (n + 2)
    for a, b in rangos_expresiones(ruta):
        for i in range(a, b + 1):
            dentro[i] = True
    # inicios de sección mayor (línea de la regla superior, 1-based)
    mayores = []
    for i in range(2, n + 1):
        if RE_REGLA.match(lineas[i - 2]) and RE_MAYOR.match(lineas[i - 1]) and not dentro[i - 1]:
            m = RE_MAYOR.match(lineas[i - 1])
            titulo = m.group(2)
            # une la línea de continuación si sigue en minúscula ("... o la" + "fecundidad?")
            if i < n:
                c = RE_CONT.match(lineas[i])
                if c and c.group(1)[:1].islower() and not titulo.endswith((".", ":")):
                    titulo = f"{titulo} {c.group(1)}"
            sid = m.group(1)
            if titulos_manual and sid in titulos_manual:
                titulo = titulos_manual[sid]
            mayores.append((i - 1, sid, titulo.rstrip(":")))
    if not mayores:
        raise RuntimeError(f"{ruta}: no encontré secciones")
    cabecera = "\n".join(lineas[: mayores[0][0] - 1]).rstrip()
    secciones = []
    for j, (ini, sid, titulo) in enumerate(mayores):
        fin = (mayores[j + 1][0] - 1) if j + 1 < len(mayores) else n
        # cortes candidatos por subsección (fuera de expresiones, no pegados al encabezado)
        cortes = [ini]
        for k in range(ini + 4, fin + 1):
            if RE_MENOR.match(lineas[k - 1]) and not dentro[k]:
                # el corte va en la primera línea en blanco o comentario contiguo hacia arriba
                cortes.append(k)
        trozos = []
        for a, b in zip(cortes, cortes[1:] + [fin + 1]):
            trozos.append(lineas[a - 1 : b - 1])
        # fusiona trozos con menos de 2 líneas de código con el siguiente
        fusion = []
        acumulado: list[str] = []
        for t in trozos:
            acumulado = acumulado + t
            if sum(_es_codigo(x) for x in acumulado) >= 2:
                fusion.append(acumulado)
                acumulado = []
        if acumulado:
            if fusion:
                fusion[-1] = fusion[-1] + acumulado
            else:
                fusion.append(acumulado)
        textos = ["\n".join(t).strip("\n") for t in fusion if "\n".join(t).strip()]
        figuras = []
        for k in range(ini, fin + 1):
            for f in RE_FIG.findall(lineas[k - 1]):
                if f not in figuras:
                    figuras.append(f)
        secciones.append({"id": sid, "titulo": titulo, "trozos": textos, "figuras": figuras,
                          "lineas": (ini, fin)})
    return cabecera, secciones


# ---------------------------------------------------------------------------
# 2. Lecturas de docs/resultados_q*.md
# ---------------------------------------------------------------------------

def secciones_resultados(ruta: Path) -> dict:
    """{ "2": (titulo, cuerpo), "2.1": (...), "_cabecera": (...)} de un docs/resultados_q*.md."""
    out: dict[str, list] = {"_cabecera": ["", []]}
    actual = "_cabecera"
    for lin in leer(ruta).split("\n"):
        m2 = re.match(r"^## (\d+)\. (.*)$", lin)
        m3 = re.match(r"^### (\d+\.\d+) (.*)$", lin)
        if m2:
            actual = m2.group(1)
            out[actual] = [m2.group(2).strip(), []]
            continue
        if m3:
            actual = m3.group(1)
            out[actual] = [m3.group(2).strip(), []]
            continue
        if lin.strip() == "---":
            continue
        if lin.startswith("# ") and actual == "_cabecera":
            out["_cabecera"][0] = lin[2:].strip()
            continue
        out[actual][1].append(lin)
    return {k: (t, "\n".join(c).strip()) for k, (t, c) in out.items()}


def celda_lectura(res: dict, clave: str, doc: str):
    titulo, cuerpo = res[clave]
    return md(f"#### Lectura de resultados · §{clave} {titulo}\n\n"
              f"*Texto de `{doc}` §{clave} (escrito sobre la corrida oficial de este script; cifras reales).*\n\n{cuerpo}")


def celda_figuras(carpeta: str, figuras: list[str]):
    lista = ", ".join(f'"{f}"' for f in figuras)
    return code(f"# Figuras de revisión que esta sección acaba de regenerar (figures/review/{carpeta}/).\n"
                f"mostrar_figuras(\"{carpeta}\", c({lista}))")


# ---------------------------------------------------------------------------
# 3. Contenido fijo (markdown)
# ---------------------------------------------------------------------------
equipo = json.loads(leer(EQUIPO)) if EQUIPO.exists() else {}
EQUIPO_LINEA = equipo.get("affiliation_line", "UNALSta-R")

PORTADA = f"""
# One Number Can't Tell 8 Billion Stories
## Notebook de análisis reproducible · ASA International DataQuest 2026 · UN World Population Prospects 2024

**{EQUIPO_LINEA}** · cifras v1 congeladas el **{N('meta_numbers_date')}** · datos: UN DESA, *World Population Prospects 2024* (CC BY 3.0 IGO).

Este notebook ejecuta, de principio a fin y en este orden, `R/01_preparar_datos.R`, `R/02_q1_palancas.R`, `R/03_q2_un_numero.R`, `R/04_q3_caminos.R` y `R/05_numbers_json.R`. El código de cada celda es **copia literal** de esos scripts (lo genera `notebook/construir_notebook.py`, que corta las celdas solo en los encabezados de sección y nunca dentro de una expresión de R): correr el notebook o correr los scripts con `Rscript` da las mismas cifras. Todas las cifras del vídeo y de las diapositivas salen de `figures/numbers.json`, que se escribe en la sección 7.

**Cómo se ejecuta** (desde la raíz del repositorio; ≈ 20 minutos con 14 núcleos, la mayor parte en Q1):

```bash
jupyter nbconvert --to notebook --execute --inplace --ExecutePreprocessor.timeout=3600 notebook/analisis_wpp2024.ipynb
python -I notebook/exportar_html.py   # HTML (nbconvert + texto alternativo en cada figura)
```

Los archivos crudos de la ONU (`WPP2024_Demographic_Indicators_Medium_csv.gz`, `WPP2024_Demographic_Indicators_OtherVariants_csv.gz` y el suplemento `WPP2024_Supplement_Births_and_LE60.csv`) viven en la carpeta **padre** del repositorio (pesan demasiado para versionarse; ver `data/raw/README.md`).

**Contenido.** 0 Fuentes, licencia y aptitud de los datos · 1 Decisiones de datos (`R/01`) · 2 Hipótesis preinscritas · 3 Q1 — palancas (`R/02`) · 4 Q2 — un solo indicador (`R/03`) · 5 Q3 — caminos y qué vigilar (`R/04`) · 6 Estado de las hipótesis · 7 `numbers.json` (`R/05`) · 8 Lo que probamos y lo que no encontramos · 9 Limitaciones y consideraciones éticas · 10 Reproducibilidad · 11 Referencias.

> **Convenciones que valen para todo el notebook**
> - Código y comentarios en español; títulos, ejes y textos de las gráficas en inglés.
> - **País** = fila con `ISO3_code` no vacío: **{N('n_countries')} países y áreas**, cada uno contado una vez. Los agregados de la ONU (mundo, regiones, grupos de ingreso) **nunca** entran en un análisis entre países; solo se usan para líneas regionales y comprobaciones.
> - Modelos, correlaciones, PCA, clustering, panel y Moran usan los **{N('n_countries_1m')} países con ≥ 1 M de habitantes en 2023**; mapas y conteos usan los {N('n_countries')}.
> - **Estimaciones 1950–2023** ("Estimate") y **proyección Medium 2024–2100** ("UN medium projection") van siempre separadas y rotuladas; ningún estadístico usa una ventana que cruce 2023/2024.
> - **Intervalos:** IC 95 % por *bootstrap* por bloques de las 20 subregiones ONU (B = 2 000, semilla 2026), el único que puede salir en pantalla junto con Wilson (proporciones), Kaplan–Meier (tiempos) y los intervalos de predicción de la ONU. Describen la **sensibilidad a qué países (o regiones) entran**, no un error muestral: los países no son una muestra.
> - **Nada es causal.** Usamos "va con", "precede", "dentro del mismo país", "entre países"; nunca "causa", "impulsa" ni "efecto de".
> - Cada sección lleva su etiqueta: *Pre-specified (H…)* = la afirmación estaba fijada antes de la corrida final; *Exploratory* = sugerida por los propios datos; *Descriptive* = conteo o descripción sin hipótesis.
> - `set.seed(2026)` justo antes de cada remuestreo, permutación o k-means; `RNGkind("Mersenne-Twister", "Inversion", "Rejection")`.
"""

TESIS = f"""
## Tesis, tres preguntas y mapa a las preguntas oficiales (P1–P8)

**Tesis (una frase).** Ningún indicador cuenta por sí solo la historia de la población de un país; la historia útil para la ONU aparece cuando se leen juntos los tres componentes del balance — nacimientos, defunciones y migración — y se mira cómo se movieron durante 70 años, porque el componente que domina cambia con la etapa de la transición, la región y el nivel de ingreso.

**Gancho (2023, {N('n_countries')} países y áreas).** {N('n_below_replacement_2023')} tienen fecundidad bajo el reemplazo; {N('n_below_repl_growing_2023')} de ellos aún crecen: {N('n_below_repl_natural_growth_2023')} porque nacen más personas de las que mueren y {N('n_grow_only_migration_2023')} solo porque llegan más de las que se van.

| # | Pregunta (texto en pantalla) | Preguntas oficiales | Sección |
|---|---|---|---|
| **Q1** | *Which lever moves each country's population — births, deaths or migration — and does the answer depend on region and income?* | **P7** (central) + **P4** + parte de **P1** (calendario) + nota **P2/P3** (incertidumbre de EAU) | 3 |
| **Q2** | *Can a single indicator tell the whole story, or does it only emerge when several are read together?* | **P8** (central) + **P5** | 4 |
| **Q3** | *Do countries travel the same demographic road at different speeds — and what should the UN watch on each?* | **P6** + **P1** + recomendaciones | 5 |

**Respuesta a cada pregunta oficial, con las cifras de esta corrida** (de `figures/numbers.json`):

| Pregunta oficial | Dónde | Respuesta corta |
|---|---|---|
| **P1** · ¿Divergen las estructuras de edad entre países? | Q3 §7; Q1 §6 | Depende del indicador: más cerca en esperanza de vida al nacer (DE entre países {N('sd_lex_1950')} → {N('sd_lex_2023')} años, 1950 → 2023), más lejos en edad mediana (DE {N('sd_medage_1950')} → {N('sd_medage_2023')}) y en esperanza de vida a los 65 (DE {N('sd_le65_1950')} → {N('sd_le65_2023')}); en mortalidad infantil, el décimo más alto pasó de {N('q5_ratio_p90p10_1950')} a {N('q5_ratio_p90p10_2023')} veces la tasa del décimo más bajo. |
| **P2/P3** (opcionales, OtherVariants) · Incertidumbre de las proyecciones | Q1 §9 | Una sola banda visible: EAU 2050 = {N('pop_are_2050')} M (IP 95 % de la ONU {N('pop_are_2050_pi95_low')}–{N('pop_are_2050_pi95_high')} M); en {N('n_dir_uncertain_2050')} de {N('n_countries_1m')} países el IP 95 % de 2050 incluye crecer y decrecer. Low/High se tratan como escenarios, no como incertidumbre. |
| **P4** · Migración neta frente a crecimiento, por región | Q1 §2–§3 | En los países hoy de ingreso alto la migración neta aporta el {N('share_mig_high_2000_2023')} % del crecimiento 2000–2023 (IC por bloques {N('share_mig_high_2000_2023', campo='ci_low')}–{N('share_mig_high_2000_2023', campo='ci_high')}; {N('share_mig_high_un_agg')} % con los agregados de ingreso de la ONU); en los otros grupos resta. {N('n_grow_only_migration_2023')} países y áreas crecen solo por migración en 2023. |
| **P5** · Un índice que combine indicadores | Q2 §8 | Los pesos deciden: en 2 000 diseños razonables, el {N('share_rank_mc20', d=1)} % de los países puede moverse más de 20 puestos; si solo cambian las fórmulas, el {N('share_rank_mc20', d=1, campo='sens_low')} %. Es un índice de etapa de la transición, no un ranking de desarrollo. |
| **P6** · ¿Forman grupos por cómo se movieron? | Q3 §2–§6 | Sí, con fronteras suaves: k = {N('k_clusters')} (silueta {N('silhouette')}) = tres tramos de un mismo camino (*Early, Fast, Recent movers*) más un grupo *Migration-led*; dos de cada tres enlaces entre vecinos unen países del mismo grupo ({N('join_same_road')} frente a {N('join_same_road_null')} al azar), y el {N('share_between_groups')} % de los países queda entre dos grupos. |
| **P7** · Fecundidad, mortalidad y migración juntas; región e ingreso | Q1 §5–§8 | La mortalidad infantil empezó a caer primero en {N('n_mort_first_onset')} de {N('n_onset')} países de alta fecundidad ({N('share_mort_first')} %), típicamente al menos {N('lag_onset_lower_bound')} años antes; la fecundidad empezó a caer hacia {N('yr_fert_onset_upmid')} / {N('yr_fert_onset_lowmid')} / {N('yr_fert_onset_low')} en los países hoy de ingreso medio-alto / medio-bajo / bajo. Dentro del mismo país, la mitad de mortalidad infantil va con {N('panel_within_halfq5')} hijos por mujer en 20 años, frente a {N('panel_between_halfq5')} entre países. La migración va por su cuenta: memoria corta ({N('r_cnmr_decades_min')}–{N('r_cnmr_decades_max')} entre décadas) y casi sin vecindario (Moran {N('moran_cnmr_2023')}; {N('moran_cnmr_2023_nogulf')} sin el Golfo). |
| **P8** · ¿Un solo indicador cuenta toda la historia? | Q2 §2–§7 | No. La fecundidad sola reproduce el {fnum(100 * NUM['r2_tfr_medage']['value'], 0)} % de las diferencias de edad mediana, el {fnum(100 * NUM['r2_tfr_growth']['value'], 0)} % del crecimiento y nada de la migración; encuentra el {N('knn_tfr')} % de los 5 países más parecidos (dos ejes del PCA: {N('knn_pc12')} %; azar: {N('knn_chance')} %). Hay {N('n_dims_parallel')} dimensiones reales: la transición y la migración. |
"""

FUENTES = f"""
## 0. Fuentes, licencia y aptitud de los datos (*fitness for use*)

| Fuente | Qué usamos | Licencia / atribución |
|---|---|---|
| United Nations, DESA, Population Division (2024). *World Population Prospects 2024*, Online Edition | `WPP2024_Demographic_Indicators_Medium_csv.gz` (estimaciones 1950–2023 y proyección Medium 2024–2100; archivo original de julio de 2024) | CC BY 3.0 IGO. Cambios: agregamos, modelamos y graficamos los datos; la ONU no avala este trabajo. |
| ídem | `WPP2024_Demographic_Indicators_OtherVariants_csv.gz`, **solo** columnas de una lista blanca (`TPopulation1July, TFR, LEx, LExMale, LExFemale, CNMR, NetMigrations, CBR, CDR, IMR, Births, Deaths, NatChange, PopGrowthRate`) con el test de monotonía L95 ≤ L80 ≤ mediana ≤ U80 ≤ U95 | ídem; intervalos de predicción marginales por país, **no sumables** |
| Suplemento del DataQuest 2026 (organizadores, desde el UN Data Portal) | `WPP2024_Supplement_Births_and_LE60.csv` (LE60, nacimientos por sexo): solo robustez de P1 | crédito a los organizadores |
| World Bank (2026). *Country and Lending Groups, FY2027* | `data/raw/wb_api_income_2026-10-22.csv` (API, 2026-10-22): grupos de ingreso de hoy, **aplicados a todos los años** | CC BY 4.0 |
| Natural Earth | puntos y polígonos para Moran, vecinos y mapas de revisión | dominio público |

**Aptitud de los datos para lo que hacemos (ASA B.1, D.10).**
- Las cifras de 1950–2023 son **estimaciones modelizadas** por la ONU, no observaciones directas; desde 2024 todo es proyección Medium (media de trayectorias probabilísticas para fecundidad y esperanza de vida; mediana para migración, que en WPP 2024 es probabilística por primera vez).
- **La migración neta es el componente peor medido**: a menudo se estima como residuo entre censos, no distingue entradas de salidas y la ONU la ajusta para que el total mundial sea cero.
- La revisión de la población de EAU entre WPP 2022 y WPP 2024 (`are_revision_pct` = {N('are_revision_pct')} %) es una **cifra externa** tomada del memo de ética: no se puede calcular con los archivos de WPP 2024 y debe verificarla una persona antes de usarse.
- **No calculado en este notebook:** la cobertura censal (`n_census_pre2009`, `n_census_2019plus`) necesita la tabla de fuentes censales de la ONU, que no está en el repositorio; la sensibilidad con la *Interim Update* de Togo (19-ene-2026) y el calendario de choques de las proyecciones (`n_shock_years_*`, `share_monotone_proj_lex`) tampoco se corrieron. Quedan como claves faltantes de `numbers.json` (sección 7), no como cifras.

La celda siguiente fija la carpeta de trabajo en la raíz del repositorio (como `Rscript` desde la raíz), confirma la corrida oficial (sin el modo rápido de desarrollo de Q1), comprueba que existen los crudos y deja dos ayudas del notebook en un entorno adjunto (`nb_ayudas`) que sobrevive al vaciado del entorno global de cada pregunta.
"""

SETUP = r"""
# Preparación del notebook (no forma parte de los scripts R/0X).
setwd(here::here())                       # raíz del repo, como `Rscript R/0X_*.R`
Sys.unsetenv("Q1_RAPIDO")                 # corrida oficial: B = 2000 (nunca el modo rápido)
options(width = 160, crayon.enabled = FALSE, cli.num_colors = 1)   # salida de consola sin códigos de color

crudos <- c(Medium        = file.path(dirname(getwd()), "WPP2024_Demographic_Indicators_Medium_csv.gz"),
            OtherVariants = file.path(dirname(getwd()), "WPP2024_Demographic_Indicators_OtherVariants_csv.gz"),
            Suplemento    = file.path(dirname(getwd()), "WPP2024_Supplement_Births_and_LE60.csv"))
stopifnot(all(file.exists(crudos)))
print(data.frame(archivo = basename(crudos), MB = round(file.size(crudos) / 2^20, 1),
                 sha256 = vapply(crudos, function(f) digest::digest(file = f, algo = "sha256"), character(1)),
                 row.names = names(crudos)))

# Ayudas del notebook en un entorno adjunto (sobrevive a rm(list = ls()) de cada pregunta).
if ("nb_ayudas" %in% search()) detach("nb_ayudas")
local({
  ayudas <- new.env()
  ayudas$NB_T0 <- Sys.time()
  # Muestra figuras de revisión reducidas a `ancho` px (los PNG originales no se tocan).
  ayudas$mostrar_figuras <- function(carpeta, nombres, ancho = 1200) {
    for (n in nombres) {
      f <- here::here("figures", "review", carpeta, paste0(n, ".png"))
      if (!file.exists(f)) { message("No existe ", f); next }
      img <- magick::image_resize(magick::image_read(f), paste0(ancho, "x"))
      tmp <- tempfile(fileext = ".png")
      magick::image_write(img, tmp, format = "png")
      IRdisplay::display_markdown(sprintf("**`figures/review/%s/%s.png`** (figura de revisión, no final)", carpeta, n))
      IRdisplay::display_png(file = tmp)
      unlink(tmp)
    }
    invisible(NULL)
  }
  # Ejecuta un script de pruebas en un proceso aparte (sale con estado 1 si falla).
  ayudas$correr_pruebas <- function(script) {
    salida <- system2(file.path(R.home("bin"), "Rscript"), shQuote(here::here("R", script)),
                      stdout = TRUE, stderr = TRUE)
    cat(salida, sep = "\n")
    st <- attr(salida, "status")
    if (!is.null(st) && st != 0) stop(script, " falló (estado ", st, ")", call. = FALSE)
    invisible(TRUE)
  }
  # Vacía el entorno global: cada pregunta corre como un Rscript nuevo.
  ayudas$entorno_limpio <- function() {
    rm(list = ls(envir = globalenv(), all.names = TRUE), envir = globalenv())
    invisible(gc())
    setwd(here::here())
    invisible(TRUE)
  }
  attach(ayudas, name = "nb_ayudas")
})
cat("R", R.version.string, "| inicio", format(get("NB_T0", "nb_ayudas")), "| carpeta", getwd(), "\n")
"""

DECISIONES_INTRO = """
## 1. Decisiones de datos (`R/01_preparar_datos.R`)

Esta tabla es la §3 del plan analítico (`docs/00_plan_analitico.md`, versión 2), que manda sobre cualquier otra fuente. Cada decisión se implementa en `R/01_preparar_datos.R`, en `R/comun_analisis.R` (muestras, ventanas, tipos de palanca) o en el script de la pregunta que la usa.
"""

POST_DATOS = """
#### Lectura de resultados · preparación de datos

- `paises.parquet` queda con **35 787 filas país-año** = 237 países y áreas × 151 años (1950–2100; 2101 se descarta porque solo trae `TPopulation1Jan`). `agregados.parquet` guarda aparte las 52 ubicaciones agregadas de la ONU (mundo, regiones SDG, subregiones y grupos de ingreso), que nunca entran en un análisis entre países.
- Grupos de ingreso FY2027 entre los 237: bajo 25 · medio-bajo 47 · medio-alto 59 · alto 85 · **sin grupo 21** (entre los 161 ≥ 1 M: 25 · 41 · 44 · 50 y Taiwán, la única área ≥ 1 M sin grupo, que se excluye de las comparaciones por ingreso).
- Subregiones: 22 con los 237 y **20 con los 161** (los 5 países de Northern America tienen `ParentID` 918, que no está en el archivo de indicadores; `R/comun_analisis.R` los rellena como su propio bloque). Son los 20 bloques del *bootstrap* por subregión.
- Las 7 pruebas de `R/tests_datos.R` pasan: la suma de países por región SDG reproduce el agregado ONU (diferencia máxima 7 × 10⁻⁶ %); la identidad `PopChange = NatChange + NetMigrations` se cumple salvo en el 0,056 % de las filas con |cambio| ≥ 5 mil personas (residuo máximo 4,9 mil, Ucrania 1989); 21 áreas sin grupo de ingreso; sin filas de 2101 ni duplicados.
"""

HIPOTESIS_INTRO = """
## 2. Hipótesis preinscritas (`docs/hipotesis_preinscritas.md`)

**Honestidad sobre el estatus (ASA B.3, C.3).** Todas las hipótesis se formularon **después** de análisis exploratorios de los mismos datos (EDA previo del equipo y prototipos de siete asesores, 22-oct-2026). *Pre-specified* significa que el enunciado, el filtro, el estadístico y la regla de decisión quedaron fijados **antes de la corrida final**; no son confirmaciones independientes ni un pre-registro externo. Cada hipótesis se reporta con su resultado, sea cual sea (tabla consolidada en la sección 6). En pantalla se usa "pre-specified", nunca "pre-registered" ni "confirmatory".

Familias de contraste: **F1** = H1–H25 (si hay p-valor, Holm); **F2** = rejillas de sensibilidad (Benjamini–Hochberg o distribución completa sin marcar); **F3** = ilustraciones por regla sin inferencia (gemelos, look-alikes de Colombia, países resaltados, nombres de grupos). Ningún p-valor sale en el vídeo ni en las diapositivas.

La celda siguiente comprueba que el archivo no cambió desde el commit que lo fijó y calcula su huella SHA-256 (la misma que publica `numbers.json`).
"""

HIPOTESIS_CODE = r"""
# Huella del archivo de hipótesis y commit que lo fijó (se publican en numbers.json y en la tarjeta de ética).
ruta_hip <- here::here("docs", "hipotesis_preinscritas.md")
sha_hip <- digest::digest(file = ruta_hip, algo = "sha256")
git <- function(...) suppressWarnings(system2("git", c("-C", shQuote(here::here()), ...), stdout = TRUE, stderr = FALSE))
commit_hip <- git("log", "-1", shQuote("--format=%H (%cd)"), "--date=short", "--", "docs/hipotesis_preinscritas.md")
cambios_hip <- git("status", "--porcelain", "--", "docs/hipotesis_preinscritas.md")
cat("sha256:", sha_hip, "\nprimeros 12:", substr(sha_hip, 1, 12),
    "\ncommit y fecha:", commit_hip,
    "\n¿cambios sin commit?:", if (length(cambios_hip) == 0) "no (el hash corresponde al commit)" else "SÍ: lo nuevo sería post hoc", "\n")
"""

HIPOTESIS_TABLA = """
**Etiquetas de cada hipótesis** (resumen de `docs/hipotesis_preinscritas.md`; ✔/✘ = lo que dio el prototipo de los asesores, antes de esta corrida):

| ID | Estado inferencial | Prototipo | ID | Estado inferencial | Prototipo |
|---|---|---|---|---|---|
| H1 | pre-specified | ✔ | H11 | pre-specified | ⏳ → H11a |
| H2 | pre-specified | ⏳ | H11a | pre-specified | ✔ / ⏳ (CV) |
| H3 | pre-specified | ✘ | H12 | pre-specified | ✘ → H12a |
| H3a | pre-specified | ✔ | H12a | pre-specified | ✔ |
| H3b | exploratory | ✔ | H13 | pre-specified | ✔ |
| H4 | pre-specified | ✘ | H14 | pre-specified | ⏳ |
| H4a | exploratory | ✔ | H14a | pre-specified | ✔ |
| H5 | pre-specified | ✘ | H15 | exploratory | ✔ |
| H6 | pre-specified | ✔ | H16 | exploratory | ✔ |
| H7 | pre-specified | ✘ | H17 | exploratory | ✔ |
| H7a | exploratory | ✔ | H18 | exploratory | ✔ |
| H8 | pre-specified | ✘ → H8a | H19 | exploratory | ✔ |
| H8a | pre-specified | ✔ | H20 | exploratory | ✔ |
| H9 | pre-specified | ✘ → H9a | H21 | exploratory | ✔ |
| H9a | pre-specified | ✔ | H22–H25 | exploratory | ✔ |
| H10 | pre-specified | ✔ | | | |
"""

# Etiqueta de cada sección de análisis (plan de implementación §3.1).
ETIQUETAS = {
    "Q1": {"1": "Pre-specified (H12, H12a)", "2": "Pre-specified (H1)", "3": "Exploratory (H19) · conteos descriptivos",
           "4": "Exploratory (H24)", "5": "Pre-specified (H3, H3a) · Exploratory (H3b)", "6": "Exploratory (H17, H18)",
           "7": "Exploratory (H15, H16)", "8": "Pre-specified (H4, H5) · Exploratory (H4a, H21)",
           "9": "Exploratory (H22) · UN medium projection = escenario", "10": "Pre-specified (H2, H14, H14a)",
           "10b": "Exploratory (apéndice del notebook, sin hipótesis)", "11": "Familias F1–F3, Holm / BH (solo notebook)"},
    "Q2": {"1": "Descriptive", "2": "Pre-specified (H6)", "3": "Descriptive (identidad contable; nota al pie)",
           "4": "Pre-specified (H13)", "5": "Exploratory, familia F3 (ilustración por regla, sin inferencia)",
           "6": "Exploratory (H20)", "7": "Pre-specified (H7) · Exploratory (H7a)", "8": "Pre-specified (H8, H8a)",
           "9": "Exploratory (sin hipótesis)", "10": "Exploratory (solo notebook)", "11": "Estado de H6, H7, H7a, H8, H8a, H13, H20"},
    "Q3": {"1": "Descriptive", "2": "Pre-specified (H9, H9a)", "3": "Pre-specified (H9a)",
           "4": "Exploratory (descripción con variables externas, sin p-valores)", "5": "Pre-specified (H9a)",
           "6": "Exploratory (H25)", "7": "Pre-specified (H10, H11, H11a)", "8": "Exploratory",
           "9": "Exploratory", "10": "Exploratory · UN medium projection = escenario, no pronóstico",
           "11": "Descriptive (agregado ONU; proyección Medium)", "12": "Pre-specified (H14a) · Exploratory (H23)",
           "13": "Exploratory (recomendaciones: qué vigilar, dónde, cuándo)", "17": "Estado de H9, H9a, H10, H11, H11a, H14a, H23, H25"},
}

# Lecturas que van al final de cada sección del script (clave = sección del script).
LECTURAS = {
    "Q1": {"1": ["1"], "2": ["2"], "3": ["3"], "4": ["4"], "5": ["5"], "6": ["6"], "7": ["7"], "8": ["8"],
           "9": ["9"], "10b": ["10"], "11": ["11"], "12": ["12", "14"]},
    "Q2": {"1": ["1"], "2": ["2"], "3": ["2.1"], "4": ["3"], "5": ["4"], "6": ["5"], "7": ["6"], "8": ["7"],
           "9": ["8"], "10": ["9"], "11": ["10", "11", "12"]},
    "Q3": {"1": ["1"], "2": ["2"], "4": ["3"], "5": ["4"], "6": ["5"], "7": ["6"], "8": ["7"], "9": ["8"],
           "10": ["9"], "11": ["10"], "12": ["11"], "13": ["12"], "17": ["13"], "18": ["14", "15", "17"]},
}

PREGUNTAS = [
    {"id": "Q1", "num": 3, "script": "R/02_q1_palancas.R", "doc": "docs/resultados_q1.md", "fig": "q1",
     "titulo": "Q1 — Which lever moves each country's population: births, deaths or migration? (P7 + P4 + P1 calendario)"},
    {"id": "Q2", "num": 4, "script": "R/03_q2_un_numero.R", "doc": "docs/resultados_q2.md", "fig": "q2",
     "titulo": "Q2 — Can a single indicator tell the whole story? (P8 + P5)"},
    {"id": "Q3", "num": 5, "script": "R/04_q3_caminos.R", "doc": "docs/resultados_q3.md", "fig": "q3",
     "titulo": "Q3 — Same road, different speed: four groups and what the UN should watch (P6 + P1 + recomendaciones)"},
]

ESTADO_HIP_INTRO = """
## 6. Estado de las hipótesis (tabla consolidada)

Resultado de cada hipótesis con la regla de decisión escrita en `docs/hipotesis_preinscritas.md`, tal como lo dejan los tres scripts en `data/processed/resultados_q*_hipotesis.parquet` (se publica sea cual sea el resultado; ASA A.2, C.3).
"""

ESTADO_HIP_CODE = r"""
# Une las tres tablas de hipótesis que acaban de escribir R/02, R/03 y R/04.
leer_pq <- function(n) as.data.frame(arrow::read_parquet(here::here("data", "processed", n)))
`%|%` <- function(a, b) ifelse(is.na(a), b, a)
h1 <- leer_pq("resultados_q1_hipotesis.parquet")
h2 <- leer_pq("resultados_q2_hipotesis.parquet")
h3 <- leer_pq("resultados_q3_hipotesis.parquet")
col <- function(d, opciones) { x <- intersect(opciones, names(d)); if (length(x)) as.character(d[[x[1]]]) else NA_character_ }
hip_todas <- rbind(
  data.frame(pregunta = "Q1", id = col(h1, "id"), resultado = col(h1, c("estado", "resultado")), evidencia = col(h1, c("evidencia", "resultado"))),
  data.frame(pregunta = "Q2", id = col(h2, "id"), resultado = col(h2, "resultado"), evidencia = col(h2, "evidencia")),
  data.frame(pregunta = "Q3", id = col(h3, "id"), resultado = col(h3, "estado"), evidencia = col(h3, "resultado"))
)
cat("Hipótesis evaluadas:", nrow(hip_todas), "| Q1", nrow(h1), "· Q2", nrow(h2), "· Q3", nrow(h3), "\n")
# Q2 escribe el resultado en inglés (confirmed / rejected / partly): se normaliza solo para el conteo.
norm <- tolower(sub(" .*$", "", hip_todas$resultado))
norm <- unname(c(confirmed = "confirmada", rejected = "rechazada", partly = "matizada")[norm] %|% norm)
print(table(resultado = norm))
hip_todas
"""

NUMBERS_INTRO = """
## 7. `figures/numbers.json` — fuente única de cifras (`R/05_numbers_json.R`)

`R/05_numbers_json.R` lee los tres registros parciales que acaban de escribir Q1, Q2 y Q3, para con error si una clave aparece en dos con valores distintos, comprueba las claves globales contra los datos, añade los metadatos de la corrida (fecha, versión WPP, clasificación FY2027, semilla, SHA-256 de los crudos y del archivo de hipótesis con su commit) y escribe `figures/numbers.json`. Después lista las claves obligatorias del plan de implementación (§4) y todas las `{clave}` del storyboard, y **reporta** las que faltan: si una clave falta porque el análisis no la produjo, no se inventa.
"""

def _es_pantalla(e: dict) -> bool:
    """Misma regla que R/05 §6.6 y R/qa_verificacion.R: portada, diapositivas, voz, referencias o figuras del vídeo."""
    return any(re.match(r"^(cover|slide|narration|references|fig[0-9])", u) for u in (e.get("used_in") or []))


def numbers_lectura() -> str:
    faltan = ["n_census_pre2009", "n_census_2019plus", "n_shock_years_est", "n_shock_years_proj",
              "n_lex_drop_proj", "share_monotone_proj_lex", "n_tests", "repo"]
    # Verificación independiente (QA-stats): se cuenta desde numbers.json, no se teclea.
    n_ver = sum(1 for e in NUM.values() if e.get("verified") is True)
    pant = [k for k, e in NUM.items() if _es_pantalla(e)]
    pant_sin = sorted(k for k in pant if NUM[k].get("verified") is not True)
    lista_sin = ", ".join(f"`{k}`" for k in pant_sin) if pant_sin else "ninguna"
    return f"""
#### Lectura de resultados · `numbers.json`

- `figures/numbers.json` reúne **{len(NUM)} claves**: 165 de Q1, 96 de Q2 y 109 de Q3, sin ninguna clave repetida entre los tres registros (las dos colisiones de la fase de análisis — `momentum_years_range` y las claves de la banda de misma fecundidad — se resolvieron antes, en los scripts), más 13 de metadatos que añade `R/05`. Las claves globales coinciden con los datos: {N('n_countries')} países y áreas, {N('n_countries_1m')} ≥ 1 M y {N('world_pop_2023_bn', d=4)} mil millones de personas en 2023 (agregado ONU = suma de los 237; diferencia 1,2 × 10⁻⁸ %).
- Archivo de hipótesis: SHA-256 `{N('hyp_file_sha256_short')}…`, fijado en el commit `{N('hyp_file_commit')[:7]}` del {N('hyp_file_date')} y sin cambios desde entonces.
- `validar_registro()` no encuentra problemas de esquema: toda clave tiene `method`, `n`, `universe` y `status`, y todo intervalo guardado en `ci_*` usa un método que puede salir en pantalla (bloques de subregión, Wilson, Kaplan–Meier o intervalos de la ONU).
- **Faltan {len(faltan)} claves**, todas porque ningún análisis las produjo (no se inventan): `n_census_pre2009` y `n_census_2019plus` (necesitan la tabla de fuentes censales de la ONU), `n_shock_years_est`, `n_shock_years_proj`, `n_lex_drop_proj` y `share_monotone_proj_lex` (la tarea T14 de choques de las proyecciones no se corrió), `n_tests` (Q1 y Q2 registran `n_tests_q1` y `n_tests_q2` con definiciones distintas y Q3 no registra conteo: sumarlas sería inventar una definición) y `repo` (el repositorio público aún no existe; `docs/equipo.json` lo deja vacío). Del storyboard faltan solo `n_census_pre2009` y `repo`; `n_twin_pairs` se resuelve con el alias `n_pairs_twins` y `pc1_var_sens_range` con `sens_low`–`sens_high` de `pc1_var`, igual que en `slides/js/numbers.js`.
- **Verificación independiente** (QA-stats, `docs/QA_stats.md`): {n_ver} de {len(NUM)} claves tienen `verified: true`. Son {len(pant) - len(pant_sin)} de las {len(pant)} que salen en pantalla, en la voz o en las referencias, recalculadas desde los CSV crudos de la ONU con código independiente (`docs/qa/verificacion_lote_1.R` a `_4.R`, sin usar estos scripts). Entre ellas siguen sin verificar: {lista_sin} (el motivo está en `nota_qa`). Las {len(NUM) - len(pant)} claves que solo usa el notebook no se recalcularon y quedan en `false`. `R/05` solo pone `verified: true` si la cifra tiene la misma huella (valor, IC, sensibilidad, IP y método) que la que se verificó.
"""

NO_ENCONTRADO = f"""
## 8. Lo que probamos, cuán inciertos son los números y lo que no encontramos

**Lo que probamos (ASA B.3: comparaciones múltiples).** Q1 calculó {NUM['n_tests_q1']['value']['F1']} contrastes que deciden hipótesis (familia F1, Holm), {NUM['n_tests_q1']['value']['F2']} comprobaciones auxiliares (F2, Benjamini–Hochberg), {NUM['n_tests_q1']['value']['F2_grids']} celdas de rejillas de sensibilidad (reportadas completas, sin marcar), {NUM['n_tests_q1']['value']['F2_lisa_local']} pruebas locales de LISA (BH dentro de cada mapa) y {NUM['n_tests_q1']['value']['F3_illustration']} ilustraciones por regla sin inferencia (`n_tests_q1`). Q2 evaluó {N('n_tests_q2')} hipótesis con reglas de decisión, sin p-valores (`n_tests_q2`); Q3 evaluó 8 (tabla de la sección 6). Ningún p-valor sale del notebook.

**Cuán inciertos son.** Los intervalos por bloques de subregión son bastante más anchos que los iid de países: por ejemplo, la participación de la migración en ingreso alto va de {N('share_mig_high_2000_2023', campo='ci_low')} a {N('share_mig_high_2000_2023', campo='ci_high')} % por bloques frente a {N('share_mig_high_2000_2023', campo='ci_iid_low')}–{N('share_mig_high_2000_2023', campo='ci_iid_high')} % iid (BCa); el % de varianza del primer eje del PCA, {N('pc1_var', campo='ci_low')}–{N('pc1_var', campo='ci_high')} % frente a {N('pc1_var', campo='ci_iid_low')}–{N('pc1_var', campo='ci_iid_high')} %. Y a menudo las **decisiones razonables** mueven más que el remuestreo: el % del primer eje va de {N('pc1_var', campo='sens_low')} a {N('pc1_var', campo='sens_high')} % según qué indicadores entren; los países que pueden moverse más de 20 puestos en el índice, de {N('share_rank_mc20', d=1, campo='sens_low')} a {N('share_rank_mc20', d=1, campo='sens_high')} % según qué incertidumbre de diseño se admita; los que crecen solo por migración, de {N('n_grow_only_migration_2023', campo='sens_low')} a {N('n_grow_only_migration_2023', campo='sens_high')} según el año base.

### Lo que no encontramos (plan analítico §12)

Hipótesis y frases que cayeron. Se publican aquí, en el README y en `docs/correcciones.md`.

| Lo que esperábamos (v1) | Lo que encontramos | Evidencia [origen] | Qué lo sustituye |
|---|---|---|---|
| "Child mortality falls **~11 years** before fertility; mortality first in 80 %" (H3) | La magnitud depende del par de umbrales: medianas de −11,5 a +39,5 años y "mortalidad primero" del 16 % al 100 %; la definición de v1 descartaba en silencio a 72 países (censura). Con inicios, la mediana del rezago **no está identificada** (Q5 ya caía en 1950 en 92 de 109) | [ST][FDA][INF] | Orden (97 %), "at least 22 years", año de inicio de la caída de la TFR por ingreso |
| "Fertility and migration couple **only in high-income** countries (ρ = −0,36)" (H5) | Con ≥ 1 M el signo cambia: +0,10 [−0,20; 0,41]; el −0,36 lo generan microestados | [ST][MV] | Forest por ingreso y paradoja tipo Simpson (S15) |
| "Migration has **no memory** (β ≈ −1)" (H4) | β ≈ −1 es exactamente lo que da el ruido puro (placebo −1,00); entre décadas consecutivas la migración correlaciona 0,32–0,68 y el 76 % mantiene el signo | [ST][DEM] | "Short memory and almost no neighbourhood" (S16) |
| "In rich countries migration **fills the gap** that low fertility leaves" | Dentro del país, 1 punto menos de saldo natural va con +0,01 ‰ de migración [−0,17; 0,18]; la "compensación" es contabilidad del agregado y calendario compartido; además evoca el marco del "gran reemplazo" | [PN][DEM][ET] | "Net migration accounted for about seven in ten of the growth" |
| "Fast movers will age **faster than anyone before**" | Corea tardó 17 años en pasar de edad mediana 30 a 40, Japón 21, China 23 | [DEM] | "Projected to age in about 25 years what Europe took 40 to 50" |
| "**Europe took a century**, Asia and Latin America about fifty years" | Europa ya estaba en TFR 2,78 en 1950 (censurada); de 5 a 2,5: E/SE Asia 32 años, LAC 30 | [ST] | Registro por hitos + velocidad 5 → 3 (China 5, Egipto 33) |
| "**Everyone heads** to the bottom-left corner" | La convergencia futura es un supuesto del modelo de proyección (teleología) | [DEM][ET] | "The road is shared; the speed is not" (observado ≤ 2023) |
| "The transition axis captures **only 46 %**; 3 axes for 70 %" (H7) | Con el conjunto fijo de 12: PC1 56,7 %, 2 ejes = 74,6 %; el % va de 46 a 77 según las variables | [MV][INF] | "Two real dimensions" (análisis paralelo) |
| "Silhouette **≤ 0,23**: four types" (H9) | Silueta 0,37; k = 3 es la partición natural y k = 4 añade un grupo migratorio pequeño | [MV][FDA] | "Three stretches of one road plus a migration group" |
| "**24 %** of countries move > 20 ranks" (H8) | Entre 2,5 % y 47 % según qué incertidumbre de diseño se admita; con 11 variantes 19,9 % | [MV] | Monte Carlo declarado: 21 %, "weights, not formulas, decide" |
| "**79** of 130 below-replacement countries still grow" (H12) | 79 tienen más nacimientos que defunciones; los que crecen son 84 | [DEM][ET] | 84 = 66 + 18 |
| "India is a **Late mover**" | Con las trayectorias de 70 años India cae en *Fast movers* | [MV][FDA][SP] | Ejemplos por regla de `numbers.json` |
| "**18 countries would shrink without immigration**" | Contrafactual no identificable con saldos netos (sin inmigrantes cambiarían también los nacimientos) | [ET][PN] | "Deaths exceed births, yet arrivals keep the population growing" (contable) |
| "Projections are **14–34×** smoother" | No se replica con una medida única (CNMR 20–25×, LEx 24–33×, TFR 5–13,5× según la medida) | [ST][ET][DEM] | Medida declarada + "0 countries lose life expectancy in any projected year" |
| Panel en niveles `feols(TFR ~ l(Q5,10) + CNMR | pais + anio)` | Residuos con autocorrelación 0,98–0,99; el coeficiente con Q5 **adelantado** supera al rezagado (placebo falla) | [ST][FDA][PN] | Panel en cambios quinquenales (pasa el placebo de permutación) |
| Fechar caídas por la **derivada mínima** (FDA) | Q5 cae a ritmo casi constante: no tiene "momento" identificable (−2,5 años, 47 %) | [FDA] | Inicio de la caída sostenida |
| Modelo espacial / "difusión entre vecinos" | La fecundidad de los vecinos no aporta nada más allá de la tendencia región × año (placebo p = 0,17); + W·y añade ≤ 4 puntos de R² | [SP] | Moran como descripción; sin SAR ni GWR |
| "S11: upper-middle-income older than high-income in 2050" | Es China; con FY2027 y media ponderada se invierte (44,5 vs 44,8) | [DEM] | "China's median age is projected to pass the high-income average" |

*La tabla es la del plan (cifras de los prototipos de los asesores, entre corchetes su origen). Lo que la corrida final de este notebook cambió o añadió:*

- **H2 se rechaza:** Europa tuvo su primer año con más defunciones que nacimientos en 1993, pero volvió a tener saldo natural ≥ 0 en 2008–2014; el decrecimiento natural es continuo solo desde 2015 (Q1 §10).
- **H15 queda matizada:** dentro del mismo país, −0,41 hijos por mujer por cada mitad de mortalidad infantil (frente a −1,05 entre países), pero el IC por bloques de subregión **incluye el cero** [{N('panel_within_halfq5', campo='ci_low')}; {N('panel_within_halfq5', campo='ci_high')}]; en Europa y Norteamérica la asociación va **al revés** (+0,39) y ponderar por población le cambia el signo (+0,08) (Q1 §7).
- **"Mortalidad primero" es 106 de 109, no 105 de 108** (Taiwán fuera por no tener grupo de ingreso; RCA y RD del Congo, cuya caída de la fecundidad no ha empezado, cuentan como "mortalidad primero"); la proporción sigue en 97 % (Q1 §5).
- **El LISA del Golfo depende de la resolución de la permutación:** con 999 permutaciones sobreviven 7 países alto-alto tras la FDR; con 199, ninguno; con el año 2023 solo, ninguno (Q1 §4).
- **H7 y H8 se rechazan** como cifras (PC1 56,7 %, no < 50 %; las 7 variantes del índice mueven al 9,3 %, no al 24 %) (Q2 §6–§7).
- **H9 se rechaza** (silueta 0,37 > 0,23) y **agrupar por velocidades encuentra choques, no caminos**: tamaños 139 / 9 / 7 / 6 y ARI 0,07 con la partición principal; se descarta (Q3 §4).
- **Envejecer de 30 a 40 años de edad mediana casi no distingue a los caminos:** Fast movers {N('yrs_medage30_40_recent')} años [IC {N('yrs_medage30_40_recent', campo='ci_low')}; {N('yrs_medage30_40_recent', campo='ci_high')}] frente a Early movers {N('yrs_medage30_40_early')} [{N('yrs_medage30_40_early', d=1, campo='ci_low')}; {N('yrs_medage30_40_early', d=1, campo='ci_high')}], intervalos solapados; lo que sí separa es la fecha de llegada a 30 (1990–2023: {N('yrs_medage30_40_cohort_1990_2023')} años; antes de 1990: {N('yrs_medage30_40_cohort_pre1990', d=1)}) (Q3 §9).
"""

LIMITACIONES = f"""
## 9. Limitaciones y consideraciones éticas

Este análisis sigue los *Ethical Guidelines for Statistical Practice* de la American Statistical Association (ASA, 2022; https://doi.org/10.5281/zenodo.7092386). Entre paréntesis, el punto de las guías que motiva cada decisión. (Plantilla de `docs/04_etica_ASA_aplicada.md` §5.1, rellenada con las decisiones v2 del plan y las cifras de esta corrida; lo que no se pudo calcular se dice.)

### 9.1 Procedencia y calidad de los datos (B.1, D.10)
- Fuente: United Nations, DESA, Population Division (2024). *World Population Prospects 2024*, archivo `WPP2024_Demographic_Indicators_Medium` (CC BY 3.0 IGO), SHA-256 `{N('meta_raw_sha256_medium')}`; `OtherVariants` SHA-256 `{N('meta_raw_sha256_othervariants')}`. Suplemento LE60 entregado por los organizadores del DataQuest 2026 (SHA-256 `{N('meta_raw_sha256_supplement')}`).
- Las cifras de 1950–2023 son **estimaciones modelizadas** por la ONU, no observaciones directas. La cobertura censal (cuántos países tienen un censo reciente) **no se calculó** en este notebook: el memo de ética cita 114 de 237 con censo o registro de 2019 o posterior y 23 con el último censo antes de 2009, pero esas cifras vienen de una fuente que no está en el repositorio y quedan pendientes (`n_census_pre2009`, `n_census_2019plus`).
- **La migración neta es el componente peor medido**: muchas veces se estima como residuo entre censos, no distingue entradas de salidas y la ONU la ajusta para que el total mundial sea cero. Las revisiones más grandes entre ediciones tocan a países del Golfo; la de EAU (+{N('are_revision_pct')} % entre WPP 2022 y WPP 2024) es una cifra externa que debe verificar una persona.
- El 19 de enero de 2026 la ONU publicó una actualización para Togo. Usamos el archivo original; **la sensibilidad con la actualización no se corrió** (pendiente).

### 9.2 Estimaciones, proyecciones e incertidumbre (B.2, C.4)
- Desde 2024 todo es **proyección (variante Medium)**: la media de miles de trayectorias probabilísticas de la ONU (mediana para la migración), con supuestos de convergencia, retorno de refugiados y tasas de migración fijadas por expertos. No es un dato observado; Low/High/Constant son escenarios, no intervalos de incertidumbre.
- Mostramos los intervalos de predicción del 80 % y 95 % de la ONU para EAU (2050: {N('pop_are_2050')} M, IP 95 % {N('pop_are_2050_pi95_low')}–{N('pop_are_2050_pi95_high')} M) y para China (2050: {N('pop_chn_2050', d=2)} mil M, IP 95 % {N('pop_chn_2050_pi95_low', d=2)}–{N('pop_chn_2050_pi95_high', d=2)}). Son marginales por país e indicador y **no pueden sumarse** para grupos. En {N('n_dir_uncertain_2050')} de {N('n_countries_1m')} países el IP 95 % de 2050 incluye crecer y decrecer.
- Las proyecciones no contienen crisis; la comparación de volatilidad estimada frente a proyectada (T14) **no se corrió** en esta versión, así que no damos ninguna razón "×" de suavidad.

### 9.3 Decisiones analíticas y su sensibilidad (A.2, B.2, B.7)
- Excluimos los agregados del análisis por país para evitar el doble conteo (la suma de países reproduce los agregados SDG; pruebas de `R/tests_datos.R` 7/7).
- Los modelos usan los {N('n_countries_1m')} países con ≥ 1 M de habitantes; los mapas y conteos usan los {N('n_countries')}. Cada sección reporta la sensibilidad con los 237 (por ejemplo, el panel dentro del país pasa de −0,41 a −0,37; la partición de caminos da ARI 0,81).
- Grupos de ingreso: World Bank FY2027 (INB per cápita 2025), **aplicados a todos los años**: todo gradiente por ingreso es descriptivo (el ingreso de hoy es en parte resultado de la transición). Con los agregados de ingreso de la ONU (clasificación de mayo de 2024), la participación migratoria del crecimiento de ingreso alto 2000–2023 pasa de {N('share_mig_high_2000_2023')} % a {N('share_mig_high_un_agg')} %. Hay 21 áreas sin grupo (entre ellas *China, Taiwan Province of China*, nombre oficial de la ONU, la única ≥ 1 M).
- Tipo de "palanca": **año base 2023** (una sola definición en portada, mapa y voz); con 2017–19, 2021, 2022 y 2021–23 el tipo "crece solo por migración" va de {N('n_grow_only_migration_2023', campo='sens_low')} a {N('n_grow_only_migration_2023', campo='sens_high')} países y áreas (18 en 2023); la ventana 2021–23 no suaviza porque contiene el exceso de muertes por COVID-19 y el desplazamiento desde Ucrania.
- La tasa de migración se recorta a ±3 DE solo en PCA, look-alikes y clustering (sensibilidad con `asinh`: ARI 0,93).
- Los ejemplos y "gemelos" se eligen por una regla en código (los 3 más poblados ≥ 1 M de cada tipo o grupo; gemelos = |ΔTFR| ≤ 0,05 con máxima diferencia de crecimiento entre {N('n_pairs_twins', d=0)} pares); las listas completas están en `figures/miembros_tipo_palanca.csv`, `figures/miembros_grupos.csv` y `figures/lookalikes_todos.csv`.

### 9.4 Lo que no afirmamos (C.2, C.3, B.3)
- Todos los resultados son **descriptivos y exploratorios**: no hay inferencia causal. "La mortalidad infantil cae antes que la fecundidad" describe un orden temporal en {N('n_mort_first_onset')} de {N('n_onset')} países de alta fecundidad, no una causa; dentro del país, la asociación va en los dos sentidos (sentido directo 0,28 frente a inverso 0,22 DE) y el adelanto casi iguala a los rezagos.
- Las hipótesis se fijaron el {N('hyp_file_date')} (commit `{N('hyp_file_commit')[:7]}`, SHA-256 `{N('hyp_file_sha256_short')}`) antes de la corrida final, pero se formularon tras un EDA previo **con los mismos datos**: no son confirmaciones independientes.
- Las comparaciones y su corrección están en la sección 8 (Holm en F1, BH en F2). Como los datos cubren a todos los países (no son una muestra), los intervalos *bootstrap* describen la sensibilidad al conjunto de países, no un error muestral.
- El R² cercano a 1 al combinar nacimientos, muertes y migración ({N('r2_all')}) refleja una **identidad contable**.
- Los grupos de trayectoria tienen una separación moderada (silueta {N('silhouette')}) y el {N('share_between_groups')} % de los países queda entre dos grupos: son un continuo, no categorías naturales.

### 9.5 Personas y grupos afectados (A.8, D.6, D.11)
- Los grupos describen trayectorias demográficas, **no** niveles de desarrollo ni de bienestar; el índice compuesto no es un ranking de países.
- No emitimos juicios de valor sobre la fecundidad, el envejecimiento ni la migración ("positive migration is not success"). Las recomendaciones indican **dónde mirar**, con enfoque de derechos (Programa de Acción de la CIPD), y nunca proponen metas de fecundidad.
- Usamos los nombres oficiales de la ONU (*countries and areas*, Türkiye, Viet Nam, Republic of Korea, State of Palestine, Kosovo (under UNSC res. 1244), China, Taiwan Province of China) y su terminología para crisis, conflictos y epidemias. Colombia aparece como ilustración por ser nuestro país (posicionalidad declarada); la tabla de look-alikes de todos los países está publicada.

### 9.6 Privacidad, reproducibilidad, IA y correcciones (D.4, B.4, B.5, F.4, A.5)
- No se usan datos personales: todo son agregados nacionales publicados.
- Reproducibilidad: R y paquetes en la sección 10 (`sessionInfo()`), `set.seed(2026)` antes de cada remuestreo, SHA-256 de los crudos y del archivo de hipótesis en `numbers.json`; ejecutar este notebook regenera `figures/numbers.json`, las tablas `data/processed/resultados_q*.parquet` y las figuras de revisión.
- **Uso de IA:** usamos asistentes de IA (Claude Code, de Anthropic) para redactar código, documentación y el guion. Cada cifra procede de este notebook, y el equipo revisa cada número (`verified` en `numbers.json`, que marca QA-stats) y cada figura.
- Los errores detectados y corregidos se registran en `docs/correcciones.md`.

### 9.7 Conflictos de interés y límites de competencia (A.1, A.7)
- Sin financiación ni conflictos de interés; sin afiliación con la ONU ni con el Banco Mundial.
- Somos estudiantes de Estadística de la Universidad Nacional de Colombia (sede Bogotá); no re-estimamos las cifras de la ONU ni hacemos proyecciones propias.
"""

REPRO_INTRO = """
## 10. Reproducibilidad

Semilla, generador, huellas SHA-256 de las salidas, pruebas de la infraestructura de incertidumbre (`R/tests_incertidumbre.R`, en un proceso aparte) y la sesión de R completa.
"""

REPRO_CODE = r"""
# Semilla y generador declarados (R/config.R y R/comun_analisis.R).
cat("Semilla:", SEMILLA, "| RNGkind:", paste(RNGkind(), collapse = " / "), "\n")
# Huellas de las salidas que alimentan diapositivas y guion.
salidas <- here::here("figures", c("numbers.json", "numbers_q1.json", "numbers_q2.json", "numbers_q3.json",
                                    "miembros_tipo_palanca.csv", "miembros_grupos.csv", "lookalikes_todos.csv"))
print(data.frame(archivo = sub(paste0(here::here(), "/"), "", salidas),
                 sha256 = vapply(salidas, function(f) digest::digest(file = f, algo = "sha256"), character(1)),
                 row.names = NULL))
cat("Hipótesis: sha256", digest::digest(file = here::here("docs", "hipotesis_preinscritas.md"), algo = "sha256"), "\n")
"""

REPRO_TESTS = r"""
# Pruebas de la infraestructura compartida (bootstrap por bloques, BCa, Wilson, registro de numbers.json).
correr_pruebas("tests_incertidumbre.R")
"""

REPRO_SESION = r"""
cat(sprintf("Tiempo total del notebook: %.1f min\n", as.numeric(difftime(Sys.time(), get("NB_T0", "nb_ayudas"), units = "mins"))))
sessionInfo()
"""

REFERENCIAS = f"""
## 11. Referencias

**Datos**
- United Nations, Department of Economic and Social Affairs, Population Division (2024). *World Population Prospects 2024*, Online Edition. https://population.un.org/wpp/ — licensed under CC BY 3.0 IGO (https://creativecommons.org/licenses/by/3.0/igo/). Changes: we aggregated, modelled and charted the data; the UN does not endorse this work.
- UN DESA (2024). *World Population Prospects 2024: Methodology of the United Nations population estimates and projections* (UN DESA/POP/2024/DC/NO.10) · *World Population Prospects 2024: Summary of Results* (UN DESA/POP/2024/TR/NO.9) · release note on 2022 vs 2024 revisions (11 Jul 2024) · WPP 2024 *Interim Update* (Togo), 19 Jan 2026.
- WPP2024 Supplement (births by sex, LE60) — prepared by the DataQuest organisers from the UN Data Portal.
- World Bank (2026). *Country and Lending Groups, FY2027* (effective 1 July 2026; 2025 GNI per capita, Atlas method). API download 2026-10-22.
- Natural Earth (public domain) map data. *Boundaries and names shown do not imply official endorsement or acceptance by the United Nations.*

**Métodos y ética**
- American Statistical Association (2022). *Ethical Guidelines for Statistical Practice*. https://doi.org/10.5281/zenodo.7092386
- Webb, J. W. (1963). The natural and migrational components of population changes in England and Wales. *Economic Geography* 39(2).
- Coale, A. J. & Watkins, S. C. (eds.) (1986). *The Decline of Fertility in Europe* (Princeton European Fertility Project: onset of decline).
- Kaplan, E. L. & Meier, P. (1958). *JASA* 53 · Turnbull, B. W. (1976). *JRSS-B* 38.
- Ramsay, J. O. & Silverman, B. W. (2005). *Functional Data Analysis*, 2nd ed. Springer · Kneip, A. & Ramsay, J. O. (2008). *JASA* 103.
- Mundlak, Y. (1978). *Econometrica* 46 · Horn, J. L. (1965). *Psychometrika* 30 (parallel analysis) · Hennig, C. (2007). *CSDA* 52 (cluster stability).
- Moran, P. A. P. (1950). *Biometrika* 37 · Efron, B. & Tibshirani, R. (1993). *An Introduction to the Bootstrap*.
- OECD/JRC (2008). *Handbook on Constructing Composite Indicators*.
- Okabe, M. & Ito, K. (2008). *Color Universal Design* · Tol, P. (2021). *Colour schemes*, SRON.

**Software**
- R (versión en la sección 10); tidyverse, data.table, arrow, sf, rnaturalearth, fixest, survival, fda, fda.usc, cluster, mclust, clue, boot, mgcv, patchwork, ggrepel, magick, IRkernel; Jupyter / nbconvert.

**Asistencia de IA y reproducibilidad**
- AI assistance: Claude Code (Anthropic) helped draft code and text; every number was regenerated by this notebook and is checked by the team.
- Code, notebook, figures and pre-specified hypotheses (SHA-256 `{N('hyp_file_sha256_short')}`): repositorio público pendiente de crear (`repo` aún vacío en `docs/equipo.json`). Código MIT; textos CC BY 4.0.
"""


# ---------------------------------------------------------------------------
# 4. Ensamblaje
# ---------------------------------------------------------------------------

def celdas_script(ruta_rel: str, pregunta: str | None, doc: str | None, carpeta_fig: str | None,
                  titulos_manual: dict | None = None, nivel: str = "###"):
    ruta = REPO / ruta_rel
    cabecera, secciones = cortar_script(ruta, titulos_manual)
    res = secciones_resultados(REPO / doc) if doc else {}
    etiquetas = ETIQUETAS.get(pregunta, {}) if pregunta else {}
    lecturas = LECTURAS.get(pregunta, {}) if pregunta else {}
    celdas = []
    if cabecera.strip():
        celdas.append(code(cabecera))
    for s in secciones:
        etiqueta = etiquetas.get(s["id"])
        enc = f"{nivel} {pregunta + ' · ' if pregunta else ''}§{s['id']} {s['titulo']}"
        if etiqueta:
            enc += f"\n\n*{etiqueta}* · `{ruta_rel}` líneas {s['lineas'][0]}–{s['lineas'][1]}"
        else:
            enc += f"\n\n`{ruta_rel}` líneas {s['lineas'][0]}–{s['lineas'][1]}"
        celdas.append(md(enc))
        for t in s["trozos"]:
            celdas.append(code(t))
        if s["figuras"] and carpeta_fig:
            celdas.append(celda_figuras(carpeta_fig, s["figuras"]))
        for clave in lecturas.get(s["id"], []):
            celdas.append(celda_lectura(res, clave, doc))
    return celdas, secciones


def construir():
    nb = nbf.v4.new_notebook()
    nb.metadata["kernelspec"] = {"name": "ir", "display_name": "R", "language": "R"}
    nb.metadata["language_info"] = {"name": "R"}
    celdas = [md(PORTADA), md(TESIS), md(FUENTES), code(SETUP), md(DECISIONES_INTRO)]

    # §1 Decisiones de datos: tabla del plan §3 + R/01 + pruebas
    plan = leer(REPO / "docs" / "00_plan_analitico.md")
    m = re.search(r"## 3\. Datos y decisiones a justificar.*?\n(\| Decisión.*?)\n\n(\*\*Variables derivadas.*?)\n\n---", plan, re.S)
    if not m:
        raise RuntimeError("No encuentro la tabla §3 del plan analítico")
    celdas.append(md(m.group(1) + "\n\n" + m.group(2)))
    celdas.append(code("# Cada paso de datos corre en un entorno global vacío, como `Rscript R/01_preparar_datos.R`.\nentorno_limpio()"))
    c01, _ = celdas_script("R/01_preparar_datos.R", None, None, None, nivel="####",
                           titulos_manual={"7": "Año 2101 (documentación)",
                                           "8": "Agregados de la ONU para las líneas regionales",
                                           "10": "Diccionario de variables (notas de la ONU + variables derivadas)"})
    celdas.extend(c01)
    celdas.append(md("#### Pruebas automáticas de los datos (`R/tests_datos.R`)\n\nSe corren en un proceso aparte: si alguna falla, el script sale con estado 1 y esta celda para el notebook con error."))
    celdas.append(code('correr_pruebas("tests_datos.R")'))
    celdas.append(md(POST_DATOS))

    # §2 Hipótesis
    celdas += [md(HIPOTESIS_INTRO), code(HIPOTESIS_CODE), md(HIPOTESIS_TABLA)]

    # §3–§5 Preguntas
    for p in PREGUNTAS:
        res = secciones_resultados(REPO / p["doc"])
        cab_t, cab_c = res["_cabecera"]
        resumen_t, resumen_c = res["0"]
        celdas.append(md(f"## {p['num']}. {p['titulo']}\n\n"
                         f"Script: `{p['script']}` · lecturas: `{p['doc']}` · figuras de revisión: `figures/review/{p['fig']}/`.\n\n"
                         f"{cab_c}\n\n#### {resumen_t} (de `{p['doc']}`)\n\n{resumen_c}"))
        celdas.append(code(f"# Aislamiento: {p['id']} corre como `Rscript {p['script']}` (entorno global vacío, carpeta = raíz del repo).\nentorno_limpio()"))
        cq, _ = celdas_script(p["script"], p["id"], p["doc"], p["fig"])
        celdas.extend(cq)

    # §6 Estado de las hipótesis
    celdas += [md(ESTADO_HIP_INTRO), code(ESTADO_HIP_CODE)]

    # §7 numbers.json
    celdas.append(md(NUMBERS_INTRO))
    celdas.append(code("# Ensamblaje como `Rscript R/05_numbers_json.R` (entorno global vacío).\nentorno_limpio()"))
    c05, _ = celdas_script("R/05_numbers_json.R", None, None, None, nivel="####")
    celdas.extend(c05)
    celdas.append(md(numbers_lectura()))

    # §8–§11
    celdas += [md(NO_ENCONTRADO), md(LIMITACIONES), md(REPRO_INTRO), code(REPRO_CODE), code(REPRO_TESTS),
               code(REPRO_SESION), md(REFERENCIAS)]

    nb.cells = celdas
    nbf.validate(nb)
    nbf.write(nb, str(SALIDA))
    n_code = sum(c.cell_type == "code" for c in celdas)
    print(f"Escrito {SALIDA}: {len(celdas)} celdas ({n_code} de código, {len(celdas) - n_code} de texto).")


if __name__ == "__main__":
    construir()
