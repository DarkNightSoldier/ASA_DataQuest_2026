# Registro de uso de IA (ASA A.5, B.2, C.2, E.3)

> Creado el 2026-10-25 por el agente de IA **corrector-final** (Claude Code, de Anthropic) a partir del historial de commits, de los encabezados de cada documento y de `docs/correcciones.md`. Lo citan la diapositiva de referencias ("Log: docs/registro_ia.md"), el README y el notebook §9.6. Actualizado el 2026-10-26 por el mismo agente.
> **Regla de honestidad.** Este registro describe lo que hicieron los agentes de IA. La columna **"Revisión humana"** solo la puede rellenar una persona del equipo, con su nombre y la fecha. Ningún agente la rellena ni la da por hecha. La declaración pública (Referencias, README) es: *"AI agents, directed by the team, wrote most of the R code, the analysis memos, the figures and drafts of the slides and script. Every number shown or said was independently recomputed from the raw UN files with separate code (also AI-written); the team reviewed the results and is responsible for the work."* La parte "the team reviewed the results" solo es cierta cuando el equipo firme la revisión de las cifras habladas (`docs/correcciones.md`, P-01).
> `verified: true` en `figures/numbers.json` significa que un **agente de IA** (QA-stats) recalculó la cifra con código independiente desde los archivos crudos de la ONU (`docs/qa/verificacion_lote_*.R`). **No es una revisión humana.** La revisión humana de las cifras se firma en `docs/verificacion_numeros.csv`.

## 1. Qué hizo la IA (por fase)

| Fecha | Tarea | Agente(s) de IA | Producto | Commit | Revisión humana (nombre · fecha · qué se comprobó) |
|---|---|---|---|---|---|
| 2026-10-22 | Estructura del repositorio, instalación de paquetes, limpieza de datos WPP 2024 | setup / datos (IA) | `R/00–01`, `data/README.md`, `docs/03_hechos_clave_datos.md` | `b45ecce` | pendiente |
| 2026-10-22 | Análisis de los ganadores 2025 y de otros equipos | investigación (IA) | `docs/01_*`, `docs/referencia_ganadores/` | `b45ecce` | pendiente |
| 2026-10-22 | Siete memos de "asesoría" (series de tiempo, multivariado, datos funcionales, demografía, panel, inferencia, espacial) | siete agentes asesores de IA (no son personas) | `docs/06_asesoria_*.md` | `2a0ab7b`, `8bba999` | pendiente |
| 2026-10-22/23 | Contexto histórico, catálogo de visualización, ética ASA aplicada | investigación / ethics-advisor (IA) | `docs/02_*`, `docs/04_*`, `docs/05_*` | `2a0ab7b` | pendiente |
| 2026-10-23 | Integración de asesorías, plan v2, hipótesis fijadas antes de la corrida final (escritas después de explorar los datos) | integrate-advice (IA) | `docs/00_plan_*`, `docs/07_*`, `docs/hipotesis_preinscritas.md` | `2a0ab7b` | pendiente |
| 2026-10-23 | Storyboard v2.1 y revisión de lenguaje llano | QA-storyboard (IA) | `docs/00_storyboard_diapositivas.md`, `docs/QA_storyboard.md` | `8264ef7` | pendiente |
| 2026-10-23/24 | Código R del análisis (Q1–Q3), notebook, `numbers.json` v1, resultados | notebook-R / ensamblaje (IA) | `R/02–05`, `notebook/`, `figures/numbers*.json`, `docs/resultados_q*.md` | `87d0608` | pendiente |
| 2026-10-24 | Verificación independiente de cifras (lotes 1–4) | QA-stats / cierre-qa-stats (IA) | `docs/qa/`, `docs/QA_stats.md`, campos `verified` | `e14bf8c` | pendiente |
| 2026-10-24/25 | Figuras finales fig00–fig11 (PNG, MP4), esqueleto reveal.js | figures-static / slides-revealjs (IA) | `R/fig_*.R`, `figures/static/`, `figures/animated/`, `slides/` | `abd0d83` | pendiente |
| 2026-10-25 | Guion final v3, subtítulos, tiempos | script-narration / captions-sync (IA) | `slides/script/`, `slides/dev/check_sync.py` | sin commit | pendiente |
| 2026-10-25 | QA de jurado: ética, diapositivas, visualización | QA-ethics, QA-slides, QA-viz (IA) | `docs/QA_ethics.md`, `docs/QA_slides.md`, `docs/QA_viz.md`, `docs/qa_etica.csv` | sin commit | pendiente |
| 2026-10-25/26 | Aplicación de los 60 hallazgos de QA (guion v4, deck, figuras, README, notebook, `CITATION.cff`, `docs/decisiones_de_datos.md`) | corrector-final (IA) | `slides/`, `R/fig_*.R`, `figures/`, `notebook/`, `docs/correcciones.md` §H, este archivo | sin commit | pendiente |

## 2. Qué hizo el equipo (solo lo rellenan personas)

| Persona | Qué hizo (en sus palabras) | Fecha |
|---|---|---|
| | | |
| | | |
| | | |
| | | |

Ejemplos de lo que va aquí, **solo si de verdad se hizo**: eligió las preguntas, dirigió a los agentes, revisó cada diapositiva, comprobó a mano cifras clave (con la fila de `docs/verificacion_numeros.csv`), grabó o narró el vídeo, confirmó la grafía de los nombres y el consentimiento para publicar correos.

## 3. Pendientes que necesitan a una persona

1. Firmar `docs/verificacion_numeros.csv` (al menos las cifras habladas, marcadas `voz = sí`).
2. ~~Confirmar la grafía del nombre de la integrante~~ → resuelto: el usuario confirmó "Daniela C. Kwan" (2026-10-25); corregido en todos los archivos.
3. Publicar el repositorio antes del 2026-10-30: las Referencias dicen "are in our public repository (code MIT; texts CC BY 4.0)" (decisión del orquestador). Añadir `LICENSE` y `LICENSE-texts`, rellenar `repo`/`repo_url` en `docs/equipo.json` (`docs/correcciones.md`, P-02).
4. Consentimiento escrito de cada integrante para publicar su nombre y, si se publica, el correo de contacto (o usar un correo institucional / *noreply*); declarar si alguna voz del vídeo es sintética.
5. Cotejar a mano el DOI de la ASA (https://doi.org/10.5281/zenodo.7092386).
