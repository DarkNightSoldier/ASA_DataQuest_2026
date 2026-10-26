# Datos (`data/`)

> **Nota de alineación (2026-10-22):** la asignación original de esta tarea
> pedía guardar los datos limpios en `data/clean/`. Se cambió a
> `data/processed/` para alinear con `docs/00_plan_implementacion.md` §2
> (estructura de repositorio acordada entre agentes, de la que dependen los
> scripts `R/02_q1_palancas.R` etc. del agente `notebook-R`). Nunca se llegó
> a escribir nada en `data/clean/` (no existe esa carpeta), así que no hubo
> que mover archivos — solo se documenta el cambio de ruta aquí.

## Fuente y licencia

United Nations, Department of Economic and Social Affairs, Population
Division (2024). *World Population Prospects 2024, Online Edition*.
<https://population.un.org/wpp/>

**Licencia: CC BY 3.0 IGO.** Cita sugerida (usar siempre junto a cualquier
cifra derivada de estos datos, en el notebook, las figuras y las
diapositivas):

> United Nations, Department of Economic and Social Affairs, Population
> Division (2024). *World Population Prospects 2024, Online Edition*.

Grupos de ingreso: **World Bank Country and Lending Groups**,
<https://datahelpdesk.worldbank.org/knowledgebase/articles/906519>
(clasificación por año fiscal del Banco Mundial; ver "Decisiones" abajo).

## Cómo descargar los archivos crudos (no se versionan, pesan 16-230 MB)

Ver instrucciones completas en `data/raw/README.md`. En resumen: desde
<https://population.un.org/wpp/downloads> → *CSV format* → *Demographic
Indicators*, descargar la variante **Medium** y guardarla en la carpeta
**padre** del repo (un nivel arriba de `RepoGithub/`) como
`WPP2024_Demographic_Indicators_Medium_csv.gz`. El suplemento
`WPP2024_Supplement_Births_and_LE60.csv` lo entregaron los organizadores del
DataQuest 2026 junto con el archivo Medium.

## sha256 de los archivos usados en esta entrega (verificado 2026-10-22)

Fecha de los archivos WPP 2024 en la carpeta del proyecto: **2026-10-02** (Medium, OtherVariants y notas; suplemento LE60: 2026-10-05), según la fecha de modificación de los archivos. La fecha exacta de descarga la confirma el equipo.

| Archivo | sha256 |
|---|---|
| `../WPP2024_Demographic_Indicators_Medium_csv.gz` | `286ac36bb1415e2e1ade03acfef0a29f0e4c087e2f78e38c48f50c5df89082bc` |
| `../WPP2024_Demographic_Indicators_OtherVariants_csv.gz` | `a860504df54877e4c19788bf6e16920d6017d021b4c149eaf8b5662674180a54` (añadido 2026-10-26, QA-ethics M7; recalculado con `sha256sum`) |
| `../WPP2024_Supplement_Births_and_LE60.csv` | `26d89cf8092b89c6a97a38da0009fcc7454c958b73fe80ed822fd4339ce72510` |
| `data/raw/WB_income_groups.csv` | `1474aa9e0a6282e561c7064b2e169564e73d5bae2917380f8f47613a5108358f` |
| `data/raw/wb_api_income_2026-10-22.csv` | `27e9d2c99c2888d3c7a47a83bfb83bf2d58a193b091d5c2e185d6b0fba57ac25` |
| `data/raw/WPP2024_Demographic_Indicators_notes.csv` | `c6063ba18b23e899c02bb7f9c78b6e410f25b30cb9d40b66eda032e1127bea49` |

## Decisiones de limpieza (resumen; el detalle con cifras verificadas está en
`R/01_preparar_datos.R` y en `docs/03_hechos_clave_datos.md`)

- **País vs agregado:** país ⇔ `ISO3_code` no vacío (237, incluye Holy See y
  Taiwán). Confirmado que coincide con `LocTypeName == "Country/Area"`.
- **Región SDG:** se reconstruye mapeando el *nombre* de la subregión M49
  (`ParentID` del país) a la región SDG con una tabla fija de la ONU — **no**
  siguiendo `ParentID` varios niveles, porque las filas "SDG region" del
  archivo son un agregado paralelo, no heredado de los países por esa
  columna. La subregión "Northern America" (LocID 918) no existe como fila en
  este archivo; sus 5 miembros (USA, CAN, BMU, GRL, SPM) se asignan a mano a
  "Europe and Northern America". Verificado: la suma de población de países
  por región reproduce el agregado SDG publicado en 2023 con una diferencia
  máxima de 7e-06 % (ver salida de `R/tests_datos.R`).
- **Ingreso:** fuente principal `data/raw/wb_api_income_2026-10-22.csv` (copia
  del API del Banco Mundial descargada el 22-oct-2026; es la clasificación
  **FY2027**, publicada en julio de 2026 con el INB per cápita de 2025).
  Fuente de contraste `WB_income_groups.csv`: coincide al 100% en las 296
  economías que ambas cubren (0 discrepancias verificadas). 21 territorios de
  los 237 países WPP no tienen clasificación del Banco Mundial (territorios
  pequeños sin estatus de miembro + Taiwán + la Santa Sede) y se codifican
  como `"Not classified"`; de ellos, solo **Taiwán** supera 1 millón de
  habitantes en 2023.
- **2101:** se descarta (solo trae `TPopulation1Jan`, todo lo demás es NA).
- **Umbral de microestado:** `pob_1m` = población 2023 >= 1,000,000 (161 de
  237 países), fijo en el tiempo (no se recalcula año a año).

## Qué se versiona y qué no

| Ruta | ¿Se versiona? | Por qué |
|---|---|---|
| `data/raw/*.csv` (pequeños, listados en `data/raw/README.md`) | Sí | < 30 KB cada uno. |
| `data/raw/` (los `.csv.gz`/`.csv` grandes de la ONU) | No | 16-230 MB; se descargan con instrucciones de `data/raw/README.md`. |
| `data/processed/*.parquet` | No | Paneles completos (237 países x 151 años); se regeneran en segundos con `Rscript R/01_preparar_datos.R`. |
| `data/processed/lookup_regiones.csv` | Sí | ~24 KB; tabla país -> región/ingreso/continente. |
| `data/processed/diccionario_variables.csv` | Sí | ~8 KB; código -> nombre ES/EN, unidad, tema. |

## Cómo reproducir

```bash
Rscript R/01_preparar_datos.R   # genera data/processed/
Rscript R/tests_datos.R         # verifica la integridad (falla si algo rompe)
```
