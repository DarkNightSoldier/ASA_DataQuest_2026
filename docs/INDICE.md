# Índice comentado de `docs/`

Equipo **UNALSta-R** · ASA International DataQuest 2026 · UN World Population Prospects 2024 · versión candidata `submission-2026-10-30-rc2` (2026-10-27; rc1 = 2026-10-26).

**▶ Vídeo de entrega (5 min): <https://www.youtube.com/watch?v=Mh-TSMhnjDs>** (YouTube, publicado el 2026-10-30).

Este índice dice **qué es cada documento, de qué fecha es y si manda o es solo historia**. Los documentos están en español; los textos que salen en pantalla y en el vídeo, en inglés. Casi todos los documentos los escribieron **agentes de IA** (Claude Code, de Anthropic) dirigidos por el equipo: el detalle y lo que falta por revisar está en [`registro_ia.md`](registro_ia.md).

## Qué manda cuando dos documentos se contradicen

1. **`figures/numbers.json`** (fuera de `docs/`): única fuente de cada cifra. Solo se dicen o se muestran las claves con `"verified": true` (recalculadas con código independiente; ver [`QA_stats.md`](QA_stats.md)). Cualquier cifra de un memo o plan que difiera de `numbers.json` está superada.
2. **[`00_storyboard_diapositivas.md`](00_storyboard_diapositivas.md)** (v2.1): textos en pantalla, builds y narración con `{claves}`; y **`slides/script/narration_en.md`** (v4): la voz final, palabra por palabra, generada por `slides/script/build_narration.py`.
3. **[`correcciones.md`](correcciones.md)**: lo que cambió después de los planes y por qué. Si un plan dice "105 de 108" y las correcciones dicen "106 de 109", vale lo segundo.
4. Los planes y los memos `06_*` son **de partida**: contienen cifras de prototipo que luego se recalcularon.

## 1. Empezar por aquí (documentos vivos de la entrega)

| Archivo | Qué es | Fecha |
|---|---|---|
| [`correcciones.md`](correcciones.md) | Registro de correcciones (ASA B.5): 46 correcciones de C-01 a C-46, los 32 cambios H-01 a H-32 que respondieron a los 60 hallazgos de QA, los cambios de seguimiento S-01 a S-08 (§I, 2026-10-26), los del jurado final J-01 a J-23 (§J, rc2, 2026-10-27, con la tabla de cifras que cambian respecto al deck verificado a mano); lista de hallazgos no aplicados con su motivo y los **pendientes para el equipo** (P-01 a P-08; P-01, P-04, P-05, P-06, P-07 y P-08 hechos; P-02 publicado el 2026-10-30 17:05; pendiente final: P-03 lectura cronometrada). Lo citan el notebook y el README | 2026-10-22 a 26 |
| [`registro_ia.md`](registro_ia.md) | Registro de uso de IA (ASA A.5, B.2): qué hizo cada agente, por fase y con su commit; §2 lo que hizo el equipo según informó el usuario (los cuatro revisaron el output del notebook y las cifras y comparten igual responsabilidad; consentimiento escrito; voces de los integrantes, ninguna sintética) | 2026-10-25/26 |
| [`decisiones_de_datos.md`](decisiones_de_datos.md) | Registro vivo de decisiones de datos D-01 a D-21 (archivo base, países vs agregados, ingreso, umbral de 1 M, año base de la palanca…) con alternativas, sensibilidad y punto ASA | 2026-10-26 |
| [`verificacion_numeros.csv`](verificacion_numeros.csv) | Una fila por cifra mostrada o dicha (108): valor, si sale en pantalla o en voz, verificación por IA y **firma humana**: `verificado_por` = "4 integrantes", `verificado_en` = 2026-10-26T11:23-05:00, `ok` = "sí (global, informado)" (P-01; `QA_stats.md` §10); la fila nueva de rc2, `knn_pc1`, firmada por los 4 integrantes el 2026-10-27T23:40-05:00 con `ok` = "sí (informado)" (P-07) | 2026-10-25/26 |
| [`equipo.json`](equipo.json) · [`equipo.md`](equipo.md) | Datos del equipo: nombres, afiliación exacta de la portada, metadatos que leen las diapositivas (`n_states`, hash de las hipótesis…). `repo`/`repo_url` = https://github.com/DarkNightSoldier/ASA_DataQuest_2026 (público desde el 29-oct-2026) y bloques `human_check` (verificación humana de las cifras), `consent`, `authorship` (responsabilidad igual) y `voices` (voces de los integrantes, ninguna sintética). `equipo.md` es la versión legible | 2026-10-22 a 26 |

## 2. Plan, hipótesis y guion

| Archivo | Qué es | Estado |
|---|---|---|
| [`00_plan_analitico.md`](00_plan_analitico.md) | Plan maestro (v2): tesis, preguntas P1 a P8, análisis por pregunta Q1 a Q3, cifras de partida, ética (§8) y "lo que no encontramos" (§12) | Vigente en estructura; cifras superadas por `numbers.json` |
| [`00_plan_implementacion.md`](00_plan_implementacion.md) | Plan de implementación (v2): división del trabajo por agente, estructura del repositorio, esquema de `numbers.json` (§4), convenciones, definición de "terminado" y calendario | Histórico; el esquema de §4 sigue vigente |
| [`00_storyboard_diapositivas.md`](00_storyboard_diapositivas.md) | Storyboard v2.1 de las 4 diapositivas y el vídeo de 5 min: builds, texto en pantalla, narración con `{claves}`, ranuras de figuras, tarjetas de ética | **Vigente** (fuente de verdad del deck) |
| [`hipotesis_preinscritas.md`](hipotesis_preinscritas.md) | Hipótesis H1 a H25 fijadas el 2026-10-23 (sha256 `83f98f6e1a3d…`) **después** de explorar los datos: son "fijadas antes de la corrida final", no un prerregistro confirmatorio | Congelado; no editar (cambiaría el hash) |
| [`07_integracion_asesorias.md`](07_integracion_asesorias.md) | Cómo se integraron los siete memos `06_*` en el plan: cada decisión aceptada, modificada o rechazada, con su razón | Histórico (2026-10-22/23) |

## 3. Resultados del análisis (uno por pregunta)

Los escribieron los agentes de análisis con las cifras reales de la corrida oficial; el notebook copia sus "lecturas".

| Archivo | Qué es |
|---|---|
| [`resultados_q1.md`](resultados_q1.md) | Q1, qué palanca mueve cada país (P7 + P4): descomposición del crecimiento, tipos de palanca, registro por hitos, mortalidad primero, panel dentro/entre países. Script `R/02_q1_palancas.R` |
| [`resultados_q2.md`](resultados_q2.md) | Q2, ¿basta un solo indicador? (P8 + P5): R² de la fecundidad sola, look-alikes, PCA, índice compuesto. Script `R/03_q2_un_numero.R` |
| [`resultados_q3.md`](resultados_q3.md) | Q3, un camino a distinta velocidad (P6 + P1 + recomendaciones): grupos de trayectoria, divergencia, qué vigilar. Script `R/04_q3_caminos.R` |
| [`03_hechos_clave_datos.md`](03_hechos_clave_datos.md) | Hechos básicos de los datos (2026-10-22), calculados sobre los parquet limpios: totales, agregados, casos de referencia |
| [`sessionInfo.txt`](sessionInfo.txt) · [`paquetes_estado.csv`](paquetes_estado.csv) · [`instalacion_log.txt`](instalacion_log.txt) | Versiones de R y de los paquetes (no hay `renv.lock`), estado de los 56 paquetes y log de la instalación sin `sudo` (ver también `SETUP.md`) |

## 4. Control de calidad (QA)

| Archivo | Quién lo revisó | Qué contiene |
|---|---|---|
| [`QA_storyboard.md`](QA_storyboard.md) | QA-storyboard (2026-10-23) | Paso del storyboard v2 a v2.1: lenguaje llano, tiempos y frases con cifras |
| [`QA_stats.md`](QA_stats.md) | cierre-qa-stats (2026-10-24) | **Verificación independiente de `numbers.json`**: 210 cifras recalculadas desde los CSV crudos con código separado, 0 discrepancias; definiciones ambiguas; claves que faltan (§6) y qué no puede decirse (§7); **§10: verificación humana** de las cifras habladas y en pantalla (2026-10-26, 11:23, los cuatro integrantes). Código en [`qa/`](qa/) |
| [`QA_notebook_ejecucion.md`](QA_notebook_ejecucion.md) | ensamblaje (2026-10-24) | Ejecución del notebook de principio a fin (187 celdas, 13,6 min) y ensamblaje de `numbers.json` |
| [`QA_ethics.md`](QA_ethics.md) · [`qa_etica.csv`](qa_etica.csv) | QA-ethics (2026-10-25) | Revisión como jurado de *Best Consideration of Ethics*: hallazgos H1 a H4 (altos), M1 a M9, L1 a L9; el CSV responde Sí/No/Parcial a cada ítem de la lista de `04_etica_ASA_aplicada.md` §4 |
| [`QA_slides.md`](QA_slides.md) | QA-slides (2026-10-25) | Revisión del PDF y de los 32 estados del vídeo como jurado general y "familiar no estadístico" |
| [`QA_viz.md`](QA_viz.md) | QA-viz (2026-10-25) | Revisión de visualización: figuras fig00 a fig11, colores, tamaños, cifras sin verificar dentro de las figuras |

Los 60 hallazgos de `QA_ethics`, `QA_slides` y `QA_viz` se aplicaron en la sección H de [`correcciones.md`](correcciones.md) (agente corrector-final, 2026-10-25/26).

- **Jurado final** (2026-10-27): cuatro jueces de IA sobre el commit `5ec1bd6`, aplicados en la sección J de [`correcciones.md`](correcciones.md) (agente cierre-rc2); son revisiones internas y no se publican (`tools/preparar_publicacion.sh` quita estas líneas): [`jurado_insight.md`](jurado_insight.md) · [`jurado_viz.md`](jurado_viz.md) · [`jurado_etica.md`](jurado_etica.md) · [`jurado_completitud.md`](jurado_completitud.md).
  - [`jurado_insight.md`](jurado_insight.md) — *Best Statistical Insight* (8,5/10): cobertura de P1–P8, 3 imprescindibles (fila 5 de la tabla, "variation" en vez de "gaps", mejor número único `knn_pc1`) y mejoras.
  - [`jurado_viz.md`](jurado_viz.md) — *Best Data Visualization* (8,4/10): 4 imprescindibles (rótulos de fig11, fig07 héroe, estados finales de S3/S4, códigos P1–P8) y comparación con TRITICS.
  - [`jurado_etica.md`](jurado_etica.md) — *Best Consideration of Ethics* (8,0/10): 8 imprescindibles (declaración de IA, crédito a otros equipos, material de terceros, licencias y correo, rastro de la verificación humana, lenguaje, reproducibilidad de la verificación).
  - [`jurado_completitud.md`](jurado_completitud.md) — completitud (8,0/10): pregunta por pregunta (P1–P8), 7 imprescindibles (voz y tiempo, región en P4/P7, cajas "answered", P1–P8, cifras de figuras, repositorio, "165").

### `qa/` — código y tablas de la verificación independiente

`verificacion_lote_1.R` a `_4.R` (cuatro verificadores que recalculan las cifras desde los CSV crudos sin usar `R/0*.R`), sus `_resultados.csv`, `consolidar_verificacion.R` → `verificacion_consolidada.csv` (la tabla que lee `R/qa_verificacion.R` para marcar `verified`) y `tabla_qa_stats.py` (tabla de `QA_stats.md` §5).

## 5. Ética

| Archivo | Qué es |
|---|---|
| [`04_etica_ASA_aplicada.md`](04_etica_ASA_aplicada.md) | Las *Ethical Guidelines for Statistical Practice* (ASA, 2022) convertidas en acciones: checklist G/S/N/R (§4), verbos prohibidos, frases listas para pantalla y voz (§6) y anexo de cifras |
| [`QA_ethics.md`](QA_ethics.md) · [`qa_etica.csv`](qa_etica.csv) | Ver §4. La lista contestada ítem por ítem |
| [`correcciones.md`](correcciones.md) · [`registro_ia.md`](registro_ia.md) · [`decisiones_de_datos.md`](decisiones_de_datos.md) | Ver §1: corregir (B.5), declarar el uso de IA (A.5) y registrar decisiones (B.7) |

## 6. Asesorías especializadas (memos de partida, 2026-10-22)

Siete agentes asesores de IA (no son personas) prototiparon análisis para el plan. **Sus cifras son de prototipo**: el notebook las recalculó y `numbers.json` manda. Cada memo tiene sus figuras en `asesoria_figs/<tema>/`.

| Archivo | Tema | Figuras |
|---|---|---|
| [`06_asesoria_series_tiempo.md`](06_asesoria_series_tiempo.md) | Series de tiempo: memoria de la migración, choques, estimación vs proyección | `asesoria_figs/series_tiempo/` |
| [`06_asesoria_multivariado.md`](06_asesoria_multivariado.md) | PCA, look-alikes, índices compuestos (P8, P5) | `asesoria_figs/multivariado/` |
| [`06_asesoria_datos_funcionales.md`](06_asesoria_datos_funcionales.md) | Datos funcionales y longitudinales, agrupación por trayectoria (P6) | `asesoria_figs/fda/` |
| [`06_asesoria_demografia_social.md`](06_asesoria_demografia_social.md) | Demografía y estadística social: medición, inercia, selección de países, lenguaje | `asesoria_figs/demografia/` |
| [`06_asesoria_panel_econometria.md`](06_asesoria_panel_econometria.md) | Panel con efectos fijos para P7: asociación dentro y entre países | `asesoria_figs/panel/` |
| [`06_asesoria_inferencia_incertidumbre.md`](06_asesoria_inferencia_incertidumbre.md) | Inferencia, incertidumbre y supervivencia (tiempo hasta el evento) | `asesoria_figs/incertidumbre/` |
| [`06_asesoria_espacial.md`](06_asesoria_espacial.md) | Estadística espacial: mapas, contigüidad, Moran | `asesoria_figs/espacial/` |

## 7. Contexto y referencias de apoyo

| Archivo | Qué es |
|---|---|
| [`02_contexto_historico.md`](02_contexto_historico.md) | Hechos históricos 1950–2024 (guerras, hambrunas, epidemias, políticas) con fuente, para anotar gráficas y guion |
| [`05_catalogo_visualizacion.md`](05_catalogo_visualizacion.md) | Catálogo de técnicas de visualización con código probado (premio *Best Data Visualization*) |
| [`01_analisis_ganadores_2025.md`](01_analisis_ganadores_2025.md) | Análisis a fondo de los equipos premiados en 2025 (TRITICS, QuantaQuartet…): qué hicieron y cómo superarlo |
| [`01b_otros_equipos_2025_2026.md`](01b_otros_equipos_2025_2026.md) | Seis repositorios públicos de otros equipos (2025 y 2026) revisados el 2026-10-22 |
| [`01c_otros_videos_2025.md`](01c_otros_videos_2025.md) | Cuatro vídeos más de 2025 (Chartosaur Inferna, INFINITA, VizChiefs, Glorystician) revisados el 2026-10-27: cómo hacen visible la técnica estadística; origen de las etiquetas **Methods** (crédito en README → Acknowledgements). Interno: no se publica |
| `referencia_ganadores/` | Capturas de los vídeos y repositorios de los equipos de 2025 y 2026 usadas en los dos documentos anteriores. **Imágenes de terceros, solo para estudio interno:** revisar su inclusión antes de hacer público el repositorio  **rc2:** `tools/preparar_publicacion.sh` deja fuera esta carpeta y `01_*`, `01b_*`, `01c_*` y `jurado_*.md` en la rama pública (`docs/correcciones.md` J-18) |

## 8. Archivos auxiliares

`.Rhistory` (vacío; se ignora en git) y las carpetas `qa/`, `asesoria_figs/` y `referencia_ganadores/` descritas arriba.
