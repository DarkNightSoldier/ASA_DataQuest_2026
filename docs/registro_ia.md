# Registro de uso de IA (ASA A.5, B.2, C.2, E.3)

> Creado el 2026-10-25 por el agente de IA **corrector-final** (Claude Code, de Anthropic) a partir del historial de commits, de los encabezados de cada documento y de `docs/correcciones.md`. Lo citan la diapositiva de referencias ("Log: docs/registro_ia.md"), el README y el notebook §9.6. Actualizado el 2026-10-26 por el mismo agente y, después de las 11:23, por el agente **seguimiento** (IA).
> **Regla de honestidad.** Este registro describe lo que hicieron los agentes de IA. La columna **"Revisión humana"** solo la puede rellenar una persona del equipo, con su nombre y la fecha. Ningún agente la rellena ni la da por hecha. La declaración pública (Referencias; README y notebook con la misma idea) es: *"AI agents, directed by the team, assisted the analysis, the code and the production (most R code, memos, figures, slide and script drafts), not the voices (team members narrate; no synthetic voice). Every number was recomputed by independent code and checked by the four team members (that code is also AI-written). The four of us share equal responsibility."* (2026-10-26: la frase de verificación sustituye a "…the team reviewed the results…", porque el usuario informó que los cuatro integrantes comprobaron a mano las cifras habladas y en pantalla a las 11:23, `docs/QA_stats.md` §10, `docs/correcciones.md` P-01; el alcance "análisis, código y producción, no las voces" y la responsabilidad igual se añadieron con la información del usuario de las 12:10, P-04 y P-05.)
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
| 2026-10-25/26 | Aplicación de los 60 hallazgos de QA (guion v4, deck, figuras, README, notebook, `CITATION.cff`, `docs/decisiones_de_datos.md`) | corrector-final (IA) | `slides/`, `R/fig_*.R`, `figures/`, `notebook/`, `docs/correcciones.md` §H, este archivo | `c367937` | pendiente |
| 2026-10-26 | Registro de la verificación humana de las cifras **informada por el usuario** (P-01), URL del repositorio (P-02 parcial), deck que se abre con doble clic (`numbers_data.js` versionado, `slides/abrir.sh`), procedencia de los datos (P-06), registro del consentimiento, de la responsabilidad igual y de las voces **informados por el usuario** (P-04, P-05), PDF, capturas y vídeo mudo regenerados | seguimiento (IA) | `docs/QA_stats.md` §10, `docs/correcciones.md` §I, `docs/verificacion_numeros.csv`, `docs/equipo.json`, `R/05`, `slides/`, README, `CITATION.cff`, notebook | commit "docs: verificación humana, URL del repositorio y deck autosuficiente" | pendiente |

## 2. Qué hizo el equipo (solo lo rellenan personas)

> Anotado por el agente *seguimiento* (IA) el 2026-10-26 **con lo que informó el usuario en el chat** (12:10, America/Bogota). No se inventan papeles individuales: el equipo no los dio, así que las cuatro filas dicen lo mismo.

**Responsabilidad igual.** Los cuatro integrantes **revisaron el output del notebook y las cifras** y **comparten igual responsabilidad del trabajo**. No hay autor principal: el orden de los nombres (portada, README, `CITATION.cff`) es el de `docs/equipo.json` → `members` y no ordena contribuciones. Los cuatro dieron **consentimiento escrito** para publicar sus nombres. Las **voces del vídeo son de los integrantes**; ninguna es sintética (la IA asistió el análisis, el código y la producción, no las voces).

| Persona (orden de `docs/equipo.json`) | Qué hizo (según informó el usuario) | Fecha |
|---|---|---|
| Daniela C. Kwan | Revisó el output del notebook y las cifras; comprobó a mano las cifras habladas y en pantalla (`docs/QA_stats.md` §10); comparte igual responsabilidad del trabajo; consentimiento escrito para publicar su nombre | 2026-10-26 (11:23 verificación; 12:10 informado) |
| David S. Merchán | Ídem | 2026-10-26 (11:23; 12:10) |
| Jhon A. Mora | Ídem | 2026-10-26 (11:23; 12:10) |
| Alejandro Higuera | Ídem | 2026-10-26 (11:23; 12:10) |

Las voces del vídeo serán de integrantes del equipo (la voz aún no está grabada; quién narra cada parte lo anota el equipo aquí si quiere, no un agente). Si el equipo quiere detallar más tareas de cada persona (eligió las preguntas, dirigió a los agentes, revisó cada diapositiva, grabó o narró el vídeo…), las escribe una persona, **solo si de verdad se hicieron**.

## 3. Pendientes que necesitan a una persona

1. ~~Firmar `docs/verificacion_numeros.csv` (al menos las cifras habladas, marcadas `voz = sí`)~~ → hecho: el usuario informó que los cuatro integrantes comprobaron a mano las cifras habladas y en pantalla el 2026-10-26 a las 11:23 (UTC−5); el agente *seguimiento* lo anotó en su nombre (`verificado_por` = "4 integrantes") y lo detalla en `docs/QA_stats.md` §10. Si una cifra cambia después de esa hora, hay que volver a comprobarla.
2. ~~Confirmar la grafía del nombre de la integrante~~ → resuelto: el usuario confirmó "Daniela C. Kwan" (2026-10-25); corregido en todos los archivos.
3. Publicar el repositorio antes del 2026-10-30: https://github.com/DarkNightSoldier/ASA_DataQuest_2026 ya está en `docs/equipo.json`, Referencias, README y `CITATION.cff`; falta que el equipo suba el código el 2026-10-29 (ningún agente hace `git push`) y añada `LICENSE` y `LICENSE-texts` (`docs/correcciones.md`, P-02).
4. ~~Consentimiento escrito de cada integrante para publicar su nombre; declarar si alguna voz del vídeo es sintética~~ → hecho (informado por el usuario el 2026-10-26 a las 12:10): los cuatro dieron consentimiento escrito para publicar sus nombres y las voces son de los integrantes, ninguna sintética (`docs/correcciones.md` P-05). Queda a criterio del equipo el correo de contacto de `docs/equipo.json` (no se mencionó en el consentimiento): si no se quiere publicar, quitarlo o usar uno institucional / *noreply* antes del `git push` del 29-oct.
5. Cotejar a mano el DOI de la ASA (https://doi.org/10.5281/zenodo.7092386).
