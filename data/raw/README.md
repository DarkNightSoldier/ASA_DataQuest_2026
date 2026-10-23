# Datos crudos (`data/raw/`)

Los archivos grandes de la ONU **no se versionan** en este repositorio (pesan
entre 16 MB y 230 MB). Los scripts los leen desde la **carpeta padre** del repo
con rutas relativas, por ejemplo `../WPP2024_Demographic_Indicators_Medium_csv.gz`.

## Cómo obtener los datos

1. Entra a <https://population.un.org/wpp/downloads> (UN DESA, World Population
   Prospects 2024) → sección *CSV format* → **Demographic Indicators**.
2. Descarga:
   - `WPP2024_Demographic_Indicators_Medium.csv.gz` (variante Medium, 1950–2100).
     Guárdalo en la carpeta padre con el nombre
     `WPP2024_Demographic_Indicators_Medium_csv.gz`.
   - `WPP2024_Demographic_Indicators_OtherVariants.csv.gz` (opcional, otras variantes).
   - `WPP2024_Demographic_Indicators_notes.csv` (diccionario oficial; copia pequeña
     incluida aquí).
3. El suplemento `WPP2024_Supplement_Births_and_LE60.csv` (nacimientos por sexo y
   esperanza de vida a los 60) fue entregado por los organizadores del DataQuest
   2026 junto con `WPP2024_Supplement_Description.docx`. Guárdalo también en la
   carpeta padre.

Si prefieres otra ubicación, define las variables de entorno `WPP_MEDIUM` y
`WPP_SUPLEMENTO` con las rutas completas antes de correr `R/01_preparar_datos.R`.

## Archivos pequeños que sí se versionan

| Archivo | Contenido | Fuente |
|---|---|---|
| `WB_income_groups.csv` | ISO3 → grupo de ingreso del Banco Mundial (296 economías, FY2027) | Entregado con el proyecto; coincide 100 % con el API del BM |
| `wb_api_income_2026-10-22.csv` | Copia del API `api.worldbank.org/v2/country` descargada el 22-oct-2026 (clasificación FY2027, publicada el 1-jul-2026 con el INB per cápita de 2025) | Banco Mundial |
| `WPP2024_Demographic_Indicators_notes.csv` | Nombre y unidad oficial de cada indicador | UN DESA |

## Licencia

Datos de UN DESA, Population Division, *World Population Prospects 2024*,
licencia **CC BY 3.0 IGO**. Cita sugerida: United Nations, Department of
Economic and Social Affairs, Population Division (2024). *World Population
Prospects 2024, Online Edition*.
