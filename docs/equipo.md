# Equipo UNALSta-R

Datos del equipo para la portada, el README y las referencias de ASA International DataQuest 2026.
La fuente única es `docs/equipo.json`; este archivo es su versión legible.

| Campo | Valor |
|---|---|
| Nombre del equipo (`team_name`) | **UNALSta-R** |
| Integrantes | Daniela C. Kwan · David S. Merchán · Jhon A. Mora · Alejandro Higuera |
| Institución | Universidad Nacional de Colombia |
| Sede (`sede`) | Bogotá |
| Programa (`program`) | Estadística (*Statistics*, `program_en`) |
| Línea de afiliación para la portada (`affiliation_line`) | UNALSta-R · Statistics students · Universidad Nacional de Colombia, Bogotá |
| País | Colombia |
| Contacto | alejoh1029@gmail.com |
| Concurso | ASA International DataQuest 2026 |
| Datos | UN World Population Prospects 2024, Medium variant, CC BY 3.0 IGO |
| Repositorio (`repo`, `repo_url`) | `DarkNightSoldier/ASA_DataQuest_2026` · https://github.com/DarkNightSoldier/ASA_DataQuest_2026 (público desde el 2026-10-29, `repo_public_from`; el equipo sube el código ese día) |
| Verificación humana (`human_check`) | Los cuatro integrantes comprobaron a mano las cifras habladas (guion v4) y en pantalla (deck rc1) el 2026-10-26 a las 11:23 (America/Bogota, UTC−5); `R/05` lo copia a `meta_human_check` en `figures/numbers.json` (`docs/QA_stats.md` §10) |
| Consentimiento (`consent`) | Los cuatro integrantes dieron consentimiento **escrito** para publicar sus nombres (informado por el usuario el 2026-10-26 a las 12:10, America/Bogota; los documentos los guarda el equipo). El correo de contacto no se mencionó (`docs/correcciones.md` P-05) |
| Autoría (`authorship`) | Los cuatro revisaron el output del notebook y las cifras y **comparten igual responsabilidad del trabajo**; el orden de `members` no ordena contribuciones; sin papeles individuales (no se inventan) |
| Voces (`voices`) | Las voces del vídeo son de los integrantes; **ninguna sintética** |
| Fecha límite de entrega | 2026-10-30 (último viernes de octubre) |

## Metadatos que usan las diapositivas

Claves de `docs/equipo.json` que el notebook no produce y que las diapositivas esperan (`data-num="..."`).

| Clave | Valor | Cómo se obtuvo |
|---|---|---|
| `team_name` | UNALSta-R | Dato del equipo |
| `repo` | `DarkNightSoldier/ASA_DataQuest_2026` | Dato del equipo (2026-10-26). Metadato, no cifra: va como texto literal en Referencias (`data-team="repo_url"`), no por `data-num` |
| `hyp_file_date` | 2026-10-23 | Fecha de fijación de `docs/hipotesis_preinscritas.md` |
| `hyp_file_sha256_short` | `83f98f6e1a3d` | Primeros 12 caracteres de `sha256sum docs/hipotesis_preinscritas.md` (completo: `83f98f6e1a3dbbcfa07b8435db7d11cc3eacc79faee9875591652bcbad3bb4b5`). Recalcular si el archivo cambia. |
| `n_states` | 195 | 193 Estados miembros de la ONU + 2 observadores (Santa Sede, Estado de Palestina) |
| `n_territories` | 42 | Ubicaciones con ISO3 que no son miembros ni observadores (lista `TERRITORIOS_42` en `R/02_q1_palancas.R`) |
| `world_pop_1950_bn` | 2.49 | `agregados.parquet`, `Location == "World"`, 1950: 2 493 093 miles / 1e6 |
| `are_revision_pct` | `null` | Pendiente del notebook/ética |
| `momentum_years_range` | `null` | Pendiente del notebook/ética |
| `n_census_pre2009` | `null` | Pendiente del notebook/ética (`docs/04_etica_ASA_aplicada.md`) |

**Criterio de `n_states` y `n_territories`.** Se parte de las 237 ubicaciones con ISO3 de
`data/processed/lookup_regiones.csv` (idénticas a las de `paises.parquet`). Los 42 territorios son las
dependencias, regiones administrativas especiales y áreas que no son miembros ni observadores de la ONU
(p. ej. Puerto Rico, Hong Kong, Taiwán, Kosovo, Sahara Occidental). Verificación cruzada con `countrycode`
(`un.name.en`): reconoce 193 de los 195 Estados y ninguno de los 42 territorios; las dos excepciones son los
observadores (VAT, PSE). 195 + 42 = 237.

## Cómo se usa

- **Afiliación en la portada (inglés):** `affiliation_line` = "UNALSta-R · Statistics students · Universidad Nacional de Colombia, Bogotá" (equipo de estudiantes de Estadística, sede Bogotá).
- **Portada de las diapositivas:** `team_name` aparece en "Team UNALSta-R · ASA International DataQuest 2026" y en el pie de página.
- **README:** sección "Equipo" con `team_name`, integrantes e institución (sin correos).
- **Referencias:** el nombre del equipo y el repositorio (`repo`) se citan en la diapositiva de referencias.
- **Números de las diapositivas:** `team_name`, `repo`, `hyp_file_*`, `n_states`, `n_territories` y `world_pop_1950_bn` se leen de este JSON; las claves en `null` no deben mostrarse hasta que el notebook las produzca.
