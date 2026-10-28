# Jurado de completitud: preguntas P1–P8 y cumplimiento formal

Segunda revisión, de solo lectura, del 2026-10-27. Sustituye a la del 2026-10-26. El revisor es un agente de IA, el crítico de completitud.

**Estado revisado.** HEAD `5ec1bd6`, un commit después de la etiqueta `submission-2026-10-30-rc1` (`c367937`). El árbol no tiene cambios versionados. Desde el 26-oct a las 19:03 no ha cambiado ningún entregable:

- `slides/export/slides.pdf`: 18:51, md5 `95cddebe…`;
- `video/deck_silent.mp4`: 19:01;
- `narration_en.md`, `captions.json` y `video_timings.json`: 10:51;
- `figures/numbers.json`: 18:50, 385 claves, 209 con `verified: true`.

Por eso, esta pasada vuelve a verificarlo todo desde cero y añade hallazgos nuevos (§7).

**Material revisado:**

- `2026DataQuest_WPP2024_Getting_Started.docx` §6, extraído con python-docx;
- `slides/script/narration_en.md` (v4) y `captions.json` (68 bloques, con tiempos);
- `video_timings.json`;
- `video/deck_silent.mp4`, con 11 fotogramas vistos: 0:28.5, 0:35, 2:31, 2:40, 3:15, 3:26, 3:42, 4:05, 4:11, 4:48 y 4:51.5;
- las 6 páginas de `slides.pdf`, renderizadas a 2200 px y vistas una por una, más dos recortes a 200 ppp;
- `slides/index.html`, analizado con BeautifulSoup;
- `figures/numbers.json` y `docs/verificacion_numeros.csv`;
- `notebook/analisis_wpp2024.ipynb`: 314 celdas, 188 de código, todas ejecutadas, 0 errores y 50 PNG.

Scripts y capturas: `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/jurado_completitud/` (`r3/` y `scripts/`).

**Puntuación de completitud, como jurado internacional: 8/10.**

---

## 1. Las ocho preguntas del §6 (texto oficial, resumido)

El §6 (*Suggested starting questions*) es una **lista con viñetas, sin números**. La numeración P1–P8 es del equipo y sigue el orden de la guía.

| P | Pregunta oficial |
|---|---|
| P1 | Cómo diverge la estructura por edades (edad mediana, esperanzas de vida relevantes para la dependencia) entre países o regiones a lo largo del tiempo |
| P2 | *(Opcional, OtherVariants)* Qué países tienen más distancia entre las variantes High y Low, y qué indica eso sobre la incertidumbre |
| P3 | *(Opcional, OtherVariants)* Cuánto depende la población de 2100 del supuesto de fecundidad (Medium frente a Constant fertility y High/Low) |
| P4 | Relación entre los patrones de migración neta y el crecimiento o decrecimiento, **entre regiones** |
| P5 | Cómo combinar varios indicadores en una sola medida del perfil demográfico, y qué decisiones habría que justificar |
| P6 | ¿Forman los países grupos según cómo se movieron juntos sus indicadores, y no según su nivel en un año? |
| P7 | Cómo actúan juntas fecundidad, mortalidad y migración sobre la trayectoria, y si eso **difiere por región o por nivel de ingreso**. El profesor añade «y país» |
| P8 | ¿Hay un indicador que cuente toda la historia, o la historia solo aparece al mirar varios juntos? |

## 2. Dónde se responde cada pregunta y con qué calidad

Abreviaturas:

- **V:** voz (`narration_en.md`; los tiempos salen de `captions.json` y son los mismos que en el vídeo mudo).
- **PDF pN:** página N de `slides.pdf`.
- **NB:** notebook.

### P1 · Edad: explícita, calidad alta

- **Voz.** s4.b2, 4:02.4–4:07.4: *"Countries grew closer in life expectancy, but further apart in age."* También s4.b1, 3:33.9–4:02.4: *"Fast movers … age from 30 to 40 in about 32 years."*
- **Pantalla.** PDF p5, titular *"Closer in life expectancy (SD 12.2 → 7.4 years), further apart in age (SD 4.7 → 9.7)…"*. Además, la DE de la esperanza de vida a los 65 pasa de 1.47 a 2.85, la mortalidad infantil de 6× a 20×, y hay tres minigráficos. El vídeo muestra lo mismo a las 4:02.
- **Notebook.** Mapa P1–P8 en la celda 1; Q3 §7 «Divergencia entre países (P1)».
- **Valoración.** Usa bootstrap por bloques, toma LE65 como indicador de vejez y distingue lo relativo de lo absoluto.
- **Lagunas.**
  - En el vídeo el titular de P1 solo se ve **5 s**: en s4.b3 lo tapa la tabla.
  - La caja *"QUESTION 3 ANSWERED · P6 · P1"* no dice nada de P1.

### P2 · Variantes High y Low (opcional): parcial

- **Voz.** s1.b5a–b5b, 1:28.5–1:41.3: *"Migration is also the least certain lever. For the Emirates in 2050, the UN's 95 percent range is nine to thirty-three million."*
- **Pantalla.** PDF p2: recuadro de EAU con abanico 80/95 % y la frase *"for 77 of 161 countries it spans both growth and decline by 2050"*.
- **Notebook.** Q1 §9.
- **Valoración.** Calidad media. Usa los intervalos probabilísticos de la ONU, no la distancia High–Low, y no ordena los países por amplitud. Ninguna diapositiva lleva la etiqueta P2.

### P3 · Supuesto de fecundidad (opcional): ausente

- **Voz y pantalla.** Nada. La línea *zero-migration* es un escenario de migración, no de fecundidad.
- **Notebook.** Solo una frase («Low/High se tratan como escenarios»). No compara Constant fertility con Medium.
- **Valoración.** Es opcional, pero el NB no dice expresamente que no se analizó.

### P4 · Migración y crecimiento: explícita por ingreso y por país, solo visual por región

- **Voz.**
  - s1.b1–s1.b4c, 0:47.7–1:28.5: *"In today's high-income countries, net migration accounted for about seven in ten of the growth since 2000. Elsewhere, growth came almost entirely from births exceeding deaths."* y los cuatro tipos.
  - s2.b4, 2:34.7–2:37.1: *"…and weighs most in high-income countries."*
- **Pantalla.** PDF p2:
  - fig01 por ingreso;
  - *"≈ 71 %"* (64–78 % con otras listas y periodos);
  - mapa de tipos 165 · 18 · 35 · 19;
  - franja < 1 M por región;
  - titular.
- **Notebook.** Q1 §2–§3.
- **Valoración.** Calidad media-alta. La guía pregunta **«across regions»**, y aquí la región solo se ve en el mapa y en el Golfo. El NB tiene la cuota regional `share_mig_region_2000_2023` (Europa y Norteamérica 84,4 %; América Latina y el Caribe −13,9 %), pero con `verified: false`, así que no puede mostrarse.

### P5 · Índice compuesto: explícita, calidad media en pantalla y alta en el notebook

- **Voz.** s3.b4, 3:09.3–3:18.6: *"Blend indicators into one score: the weights can shift one country in five by more than twenty places."*
- **Pantalla.** PDF p4, banda *"COMPOSITE INDEX = one score blending 5 indicators (2,000 reasonable ways to build it): weights, not formulas, decide — one country in five can move more than 20 places…"*.
- **Notebook.** Q2 §8: siete variantes y Monte Carlo de 2 000 diseños, con α, ω y validez convergente.
- **Lagunas.**
  - En pantalla no se nombran los 5 indicadores ni se enumeran las decisiones que pide la guía, y no hay gráfico.
  - La caja *"P8 · P5"* no menciona P5.
  - **P-03 propone recortar "Blend indicators into one score:"**, que es la única marca de P5 en la voz.

### P6 · Grupos por trayectoria: explícita, calidad alta

- **Voz.** s4.b1, 3:33.9–4:02.4: *"Grouped by seventy-year paths, countries form three stretches of one road, plus a migration-led group…"*. Y s4.b3, 4:07.4–4:11.6: *"Question three, answered: mostly one road, at different speeds."*
- **Pantalla.** PDF p5:
  - el método;
  - el mapa;
  - los tamaños, 50 · 51 · 53 · 7;
  - el 96 % de estabilidad;
  - *"Two in three pairs of neighbouring countries share a group"*;
  - la caja de respuesta.
- **Notebook.** Q3 §1–§6.
- **Valoración.** Agrupa por trayectorias y no por niveles, que es justo lo que pide la guía.
- **Laguna.** *"Four in ten countries sit between two groups"* depende del umbral: pertenencia máxima < 0,6. Con 0,5 sale el 24 %; con 0,7, el 60 %. No se dice.

### P7 · Fecundidad, mortalidad y migración juntas: EXPLÍCITA en voz y pantalla (cumple)

- **Voz.**
  - s1.b0, 0:30.9–0:36.9, plantea la pregunta.
  - s1.b2, 0:53.5–1:06.4.
  - s2.b1–b3, 1:41.9–2:22.1: *"Child deaths started falling first in 106 of 109 high-fertility countries. The gap was typically at least 22 years."* y *"A sequence in time, not proof of cause."*
  - **s2.b4, 2:22.1–2:37.1: *"Question one, answered: child deaths fell first and births followed, at each country's pace; latest in low-income countries. Migration moves on its own, alike among neighbours only in the Gulf, and weighs most in high-income countries."***
  - Cierre s4.b5, 4:42.0–4:49.2: *"…read together region by region…"*.
- **Pantalla.**
  - Portada: Q1 con la etiqueta P7.
  - PDF p2–p3: caja **"QUESTION 1 ANSWERED · P7 · P4"**; inicio de la caída de la fecundidad por ingreso (≈ 1970, 1984 y 2000); forest plot por ingreso; nota al pie *"clearest in sub-Saharan Africa (−1.20); in Europe & N. America it goes the other way (+0.39)"*.
- **Notebook.** Mapa P7 → Q1 §5–§8: KM/Turnbull, registro por hitos, panel FE y Moran.
- **Valoración.** Calidad alta en el mecanismo y en el ingreso. **La región es lo más débil:**
  - En voz solo sale «the Gulf», y P-03 propone cortarlo.
  - En pantalla, solo una nota al pie.
  - La caja no nombra ninguna región, aunque Q1 promete *"region, country and income"* y el cierre dice *"region by region"*.

### P8 · ¿Un solo indicador? EXPLÍCITA en voz y pantalla (cumple)

- **Voz.**
  - s1.b0, 0:36.9–0:41.7.
  - cover.b4, 0:24.7: *"One number can't explain that."*
  - s3.b1–b4, 2:37.7–3:33.3, con **"Question two, answered: no."** (3:18.6) y ***"The story emerges only when transition and migration are read together."*** (3:28.9–3:33.3).
- **Pantalla.** PDF p4:
  - el título es la pregunta;
  - *scorecard* de R² (0.77 · 0.88 · 0.59 · 0.00);
  - *look-alikes*: 13 % frente a 43 % y 3 %;
  - PCA con 2 ejes;
  - gemelos;
  - caja **"QUESTION 2 ANSWERED · P8 · P5 — No."**
- **Notebook.** Q2 §2–§7.
- **Valoración.** Calidad muy alta: es la tesis del trabajo.
- **Lagunas.**
  - La caja de pantalla no da la mitad positiva («varios juntos») ni menciona P5.
  - Solo se pone a prueba la fecundidad como candidata a indicador único. Hay alternativas: `knn_pc1` = 20 %, verificada (ver `jurado_insight.md` I-3); `knn_lex` = 17 % y `knn_medage` = 15 %, sin verificar.

**Resumen.** Las seis obligatorias (P1, P4, P5, P6, P7 y P8) se responden de forma explícita en voz, pantalla y notebook, y el notebook trae además una tabla de mapeo P1–P8 con respuesta corta. P7 y P8 cumplen el requisito del profesor, con pregunta y respuesta en los dos canales. Las debilidades son tres:

- la **región** en P4 y P7;
- las **cajas "ANSWERED"**, que no cubren todas las P de su etiqueta (P1, P5 y la mitad positiva de P8);
- las opcionales: **P2 parcial y P3 ausente**.

## 3. Cumplimiento formal

| Requisito | Evidencia | Estado |
|---|---|---|
| Vídeo ≤ 5:00 | `video_timings.json`: `total_s` = 292.2, 32 pasos (la suma de duraciones da 292.2). `deck_silent.mp4`: `Duration 00:04:52.20`, H.264 1920×1080 a 30 fps, sin audio. El último subtítulo termina a las 4:49.2 y Referencias va de 4:49.2 a 4:52.2 | Cumple, con 7.8 s de margen, **pero el vídeo con voz no existe** (no hay `video/final/`, P-03 pendiente). Simulación con `build_narration.build()`: el mismo guion da **301.0 s a 145 ppm y 308.9 s a 140 ppm**; con `WPM = 145` y `AIR_S = 1.0`, 293.4 s |
| PDF = portada + 4 + referencias | 6 páginas de 1440×810 pt, fuentes incrustadas (Lato, Arimo), 1.7 MB. Las cuatro de contenido van numeradas 1/4–4/4 | Cumple |
| Nombres e institución en la portada | PDF y vídeo (0:28.5): *"UNALSta-R · Statistics students · Universidad Nacional de Colombia, Bogotá"* y *"Daniela C. Kwan · David S. Merchán · Jhon A. Mora · Alejandro Higuera"*. Coincide con `docs/equipo.json` | Cumple. La portada no indica el nivel (pregrado o máster), y los premios se juzgan por nivel: ver mejoras |
| Sin "Daniel C. Kwan" | `grep` en todo el repositorio, sin `node_modules` ni `.git`: 0 apariciones que no sean "Daniela". En el texto del PDF, 0 | Cumple |
| Sin cifras sin verificar en el texto | 138 `data-num` (96 claves únicas), 1 `data-list`, 11 `data-flags` y 1 `data-count-from-key`: **todas con `verified: true`**. Hay dos alias, resueltos en `slides/js/numbers.js`: `n_twin_pairs` → `n_pairs_twins` y `pc1_var_sens_range` → `pc1_var`. 90 de las 96 aparecen literalmente en el texto del PDF con su formato. Las otras 6 se ven en otra forma (8.1 bn, *"Four in ten"*, diccionarios y la tabla `rec_rows`) y las comprobé a ojo. Los dígitos escritos a mano son años, umbrales, parámetros (k = 4, 500 re-corridas, 2 000 diseños, ± 0.05), referencias y "237" (= `n_countries`, verificada) | Cumple |
| Cifras **dentro de las figuras** | Verificadas por código pero **sin fila de verificación humana** en el CSV de 107: <br>· fig07: 0.88 y 0.00 (`r2_tfr_chg2050`, `r2_tfr_cnmr`) <br>· fig06: −0.95, +0.07, +0.11 y −0.28 (`panel_*_halfq5` por ingreso) <br>· fig04: "grey = 90 countries" (`n_cruce_tfr4_obs`) <br>· fig10: "5 of 7 … Gulf states" (`n_gulf_migration_led`) <br>**Sin clave propia:** "COL · 19 years" de fig04 (el 18.58 solo figura en la `nota_qa` de `fig04_highlight_iso3`; la clave `speed53_rule_10m` tiene `verified: false`); los conteos de la franja < 1 M (76 · 27 · 20 · 17 · 8 · 4); los n por ingreso de fig06 (25 + 41 + 44 + 50 = 160 de 161; falta Taiwán, "Not classified") | No cumple del todo: contradice la frase pública *"Every number was recomputed by independent code and checked by the four team members"* |
| Repositorio "public" con licencias | API de GitHub, solo lectura: `private: false`, `size: 0`, `/contents` → 404, es decir, **vacío**. En local **no hay `LICENSE` ni `LICENSE-texts`**, aunque Referencias anuncia *"code MIT; texts CC BY 4.0"* | Pendiente: P-02, y `jurado_etica.md` I-4 |
| Hash de las hipótesis | Referencias `83f98f6e1a3d` = `hyp_file_sha256_short` | Cumple |

## 4. Hallazgos de esta pasada que no estaban en la del 26-oct

1. **Lectura errónea de una cifra en la S1** (PDF p2 y vídeo). El salto de línea deja *"…no net arrivals: 22"* al final de una línea, y la siguiente empieza *"countries, 2.2 bn people — largest: IND BRA MEX"* justo al lado del **165**. Se lee «165 countries, 2.2 bn people», cuando los 165 países que crecen suman mucho más. Lo confirmé con un recorte a 200 ppp.
2. **La región de P7 puede entrar en la voz sin coste de tiempo.** Simulé con `build()` sobre una copia de la plantilla, sin tocar el repositorio: el total sigue en 596 palabras y 292.2 s a 150 ppm. s2.b4 pasa de 15.0 a 17.8 s, y s2.b1 y s4.b1 no cambian, así que **no hay que volver a renderizar fig04 ni fig10**.
3. **El orden de recortes de P-03 va contra P7 y P5.** Sus dos primeros cortes eliminan la única región que se dice en la voz (*"alike among neighbours only in the Gulf,"*) y la única marca de P5 (*"Blend indicators into one score:"*).
4. **"Four in ten between two groups"** sale de la pertenencia máxima < 0,6 (24–60 % según el umbral), no de < 0,5 como decía la versión anterior.
5. **COL 19 años.** El valor (18.58) está comprobado en la `nota_qa` de una clave verificada. Es menos grave de lo que se dijo, pero sigue sin clave propia ni verificación humana.
6. **P1 en el vídeo.** Lo hablado (5 s) y el titular de fig11 solo se ven en s4.b2; en s4.b3 la tabla los sustituye.

## 5. Imprescindibles

Son siete, ordenados por impacto. Los textos de pantalla y de voz van en inglés. Todos caben en ≤ 2 días.

### I-1 · Vídeo final con voz y lectura cronometrada (P-03), con un orden de recortes que proteja P7 y P5

- **Dónde.** `video/final/` (no existe), `slides/script/build_narration.py` (l. 57–58), `docs/correcciones.md` P-03 (l. 173) y `video/README.md` §2.
- **Problema.**
  - Sin vídeo con voz no hay entrega.
  - El guion solo cabe a 150 ppm o más, con 1.5 s de aire por cifra: a 145 ppm da 301.0 s.
  - P-03 recorta primero la región de P7 y la marca de P5.
- **Corrección.**
  1. Ensayo cronometrado: el narrador lee `narration_en.md` sobre `deck_silent.mp4` y apunta, paso a paso, si termina antes del siguiente subtítulo.
  2. Si va a unos 145 ppm, poner `WPM = 145.0` y `AIR_S = 1.0` (simulado: 293.4 s). Regenerar con `$VENV/bin/python slides/script/build_narration.py`. Como s4.b1 pasa de 28.5 a 29.0 s, volver a renderizar fig10, y después `record_slides.py --mp4`.
  3. Si va más lento, recortar solo en pasos sin MP4 (s1.b0, s2.b2–b4, s3.b2, s3.b4, s4.b2–b5) y **nunca** *"alike among neighbours only in the Gulf,"* ni *"Blend indicators into one score:"*. Reescribir P-03 con este orden: (i) s1.b0 *"and differ by region, country and income"* → *"by region, country and income"*; (ii) los dos cortes de I-2, si todavía no se aplicaron; (iii) en s3.b4, *"one grows almost four percent a year, the other shrinks."* → *"one grows fast, the other shrinks."* (el +3.70 % ya está en pantalla y se ahorran una cifra hablada y su pausa). Simulado con I-2, (i) y (iii): **288.3 s a 150 ppm, 289.8 s a 145 ppm con `AIR_S = 1.0` y 297.2 s a 140 ppm con `AIR_S = 1.0`**
  4. Grabar `video/voz.wav` (48 kHz) y ejecutar `bash video/assemble.sh video/voz.wav`, que falla si pasa de 300 s. Mirar los fotogramas de 2:25, 3:19 y 4:08 con la voz.

### I-2 · Decir la región de P7 en la voz, sin cambiar la duración

- **Dónde.** `slides/script/narration_en_template.md` (s1.b1 l. 38, s2.b4 l. 83–84, s4.b4 l. 130) y los `data-caption` de `slides/index.html` (l. 140, 263 y 422).
- **Problema.** La voz nunca dice en qué región la relación es más clara; solo nombra «the Gulf». La pregunta Q1 y el cierre (*"region by region"*) prometen más.
- **Corrección.**
  - **s2.b4:** añadir después de la primera línea la frase *"The link is clearest in sub-Saharan Africa."* Se apoya en `panel_ssa_halfq5` = −1.20, con verificación humana e IC cluster-robusto [−1.65; −0.74], frente a −0.41 en el total; no se dice ninguna cifra.
  - **s1.b1:** *"births minus deaths, plus net migration, arrivals minus departures."* → *"births minus deaths, plus net migration."* (la definición ya está en pantalla).
  - **s4.b4:** *"Projections are labelled as scenarios; examples follow a rule; \| hypotheses were fixed before the final run."* → *"Projections are labelled as scenarios; \| hypotheses were fixed before the final run."* (*"examples chosen by rule"* ya está en pantalla).
  - Hacer los mismos cambios en los tres `data-caption`.
  - Ejecutar `build_narration.py`, `slides/dev/check_sync.py` y `record_slides.py --mp4`. Simulado: 292.2 s, sin tocar fig04 ni fig10.

### I-3 · Las cajas "ANSWERED" deben responder todas las P de su etiqueta

- **Dónde.** `slides/index.html`, l. 276, 343 y 440.
- **Problema.** Q1 no nombra ninguna región (P7). Q2 no da la mitad positiva de P8 ni menciona P5. Q3 no dice nada de P1.
- **Corrección.** Sin cifras nuevas: todas las claves ya están en el CSV de verificación humana. Texto alineado con `jurado_insight.md`, mejoras 1–2.
  - **Q1 (P7 · P4):** *"Child deaths fell first, fertility followed — at each country's pace, latest in low-income countries; within countries the link is clearest in sub-Saharan Africa and reversed in Europe & N. America. Migration moves on its own and accounts for ≈ {share_mig_high_2000_2023 say} of high-income growth since 2000."*
  - **Q2 (P8 · P5):** *"No. Fertility alone tells how old a population is ({r2_tfr_medage}) and part of today's growth ({r2_tfr_growth}), but almost nothing about migration. Read together, transition and migration find {knn_pc12} % of each country's look-alikes; fertility alone, {knn_tfr} %. One blended score hides this: weights move {share_rank_mc20 say} by more than 20 places."*
  - **Q3 (P6 · P1):** *"Mostly one road at different speeds: three stretches (Early · Fast · Recent movers) plus a migration-led group. Countries grew closer in life expectancy but further apart in age — and each group has something different to watch."*
  - Después: `bash video/export_pdf.sh --png` y `record_slides.py --mp4` desde el mismo estado del deck. Mirar las páginas 3–5 (que cada caja quepa sin tapar el pie) y los fotogramas de cada caja.

### I-4 · Explicar las etiquetas P1–P8

- **Dónde.** `slides/index.html`: portada, l. 86–88 (`cover-questions`); tarjeta de datos de s1.b0; Referencias, después de *Acronyms* (l. 472).
- **Problema.** En la guía las preguntas son viñetas sin número. Un jurado no sabe qué significa "P7 · P4", y la etiqueta es justo el recurso que demuestra que se contestó todo.
- **Corrección.**
  - **Portada:** añadir al final de la línea *"· P1–P8 = the eight suggested starting questions of the DataQuest Getting Started guide (§6), in order; P2 partly, P3 not addressed (both optional)"*.
  - **Tarjeta de datos** de la S1 (vídeo): *"P1–P8 = suggested questions of the Getting Started guide (§6), in order"*.
  - **Referencias:** *"Questions P1–P8: ASA DataQuest 2026 Getting Started guide (UN WPP 2024), section 6 'Suggested starting questions', numbered in order."* Es la misma línea que `jurado_etica.md` I-2 pide en *Acknowledgements*: hacerla una sola vez.
  - Volver a exportar (junto con I-3).

### I-5 · Verificación humana de las cifras dentro de las figuras, o acotar la frase pública

- **Dónde.** `docs/verificacion_numeros.csv`, `docs/QA_stats.md` §10, `R/fig_q1_slide2.R` (etiqueta COL) y Referencias (l. 492).
- **Problema.** *"Every number … checked by the four team members"*, pero las cifras de las figuras de §3 no tienen fila de verificación humana, y COL 19 años no tiene clave propia.
- **Corrección.**
  - Los cuatro comprueban a mano, contra `notebook/analisis_wpp2024.html`, las cifras de las figuras: `r2_tfr_chg2050`, `r2_tfr_cnmr`, los cuatro `panel_*_halfq5` por ingreso, `n_cruce_tfr4_obs`, `n_gulf_migration_led`, `n_countries`, la franja < 1 M y los n por ingreso de fig06. Se añaden esas filas, rellenando `valor_comprobado_a_mano` y `ok`, como pide `jurado_etica.md` I-5.
  - **COL:** crear la clave `dur53_col` (18.58) en `R/05_numbers_json.R` con verificación independiente, o quitar *"· 19 years"* de la etiqueta y volver a renderizar fig04.
  - Si no da tiempo: *"Every number in the text and narration was recomputed by independent code and checked by the four team members; numbers inside figures were recomputed by code."*

### I-6 · Repositorio público y licencias antes de entregar (P-02)

- **Dónde.** Raíz del repositorio y Referencias (l. 493).
- **Problema.** *"are in our public repository (code MIT; texts CC BY 4.0)"* hoy es falso: el repositorio está vacío y no hay archivos de licencia.
- **Corrección.**
  - Seguir los pasos de `jurado_etica.md` I-4: `LICENSE` (MIT, *"Copyright (c) 2026 Daniela C. Kwan, David S. Merchán, Jhon A. Mora, Alejandro Higuera"*) y `LICENSE-texts` (CC BY 4.0).
  - El equipo hace el `git push` el 29 de octubre (ningún agente lo hace) y abre la URL en una ventana privada.
  - Si no se publica, la viñeta de Referencias pasa a *"available from the team on request"* y se vuelven a exportar el PDF y el vídeo.

### I-7 · Evitar que "165" se lea como "165 countries, 2.2 bn people"

- **Dónde.** `slides/index.html`, l. 176 (S1, fila azul de la leyenda de tipos); PDF p2 y vídeo, desde 1:10.
- **Problema.** Por el salto de línea, la cifra 22 queda separada de *"countries, 2.2 bn people"*, que se lee junto al 165.
- **Corrección.** Sustituir `<b data-num="n_momentum_countries">—</b> countries, <b data-num="pop_momentum_bn">—</b> bn people` por `<span style="white-space:nowrap"><b data-num="n_momentum_countries">—</b>&nbsp;countries</span>, <b data-num="pop_momentum_bn">—</b>&nbsp;bn people`. Volver a exportar con I-3 y comprobar en un recorte que *"22 countries"* queda junto en la segunda línea.

## 6. Mejoras deseables, por prioridad

1. **P4 por región.** Verificar de forma independiente `share_mig_region_2000_2023` (hoy `false`) y hacer la verificación humana. Después, añadir a la S1 *"By region, 2000–2023: net migration ≈ 84 % of growth in Europe & N. America; net departures in Latin America & Caribbean and Central & S. Asia"*.
2. **P7 por región, calendario.** Verificar `yr_fert_onset_by_region` (Europa y Norteamérica 1956 … África subsahariana 1995) y mostrarlo junto a la línea por ingreso de la S2, solo para regiones con n ≥ 10: Europa y Norteamérica tiene n = 4 y Oceanía n = 1.
3. **P8.** Mostrar el mejor resumen único (`knn_pc1` = 20 %, ya verificado; `jurado_insight.md` I-3). Verificar además `knn_lex` (17 %) y `knn_medage` (15 %) para poder decir *"no single indicator finds more than one in five look-alikes"*.
4. **P5.** Nombrar en la banda los indicadores y las decisiones: *"= one score blending fertility, child mortality, life expectancy, median age and growth; choices to justify: direction, scaling, weights, aggregation (2,000 reasonable designs) — weights, not formulas, decide — …"*.
5. **P2 y P3 (opcionales) en el notebook.** Dos tablas con OtherVariants: los 10 países con mayor (High − Low) / Medium en 2100, y Medium frente a Constant fertility en 2100. Marcar «P2 (parcial: IP 95 %)» y «P3: no analizada» en el mapa de la celda 1 si no se hacen. El tip del profesor premia contestarlo todo.
6. **P6.** *"Four in ten countries (highest group membership < 0.6) sit between two groups"*, para que no parezca contradecir el 96 % de estabilidad.
7. **PDF p5.** Escribir *"8 on pace at their 2015–23 rate"*, como en el vídeo; sin eso, que 58 + 8 ≠ 70 confunde.
8. **P1 en el vídeo.** Mantener el titular de fig11 visible durante s4.b3, o mover la tabla a s4.b4: hoy solo se ve 5 s.
9. **fig06.** Nota al pie: *"income groups: 160 of 161 (Taiwan has no World Bank group)"*.
10. **Tarjeta de cierre (s4.b5).** Añadir el pie *"4 / 4"*, para que no parezca una quinta diapositiva de contenido.
11. **Portada.** Indicar el nivel (*undergraduate* o *master's*), si el equipo lo confirma.
12. **Privacidad.** Quitar o sustituir el `contact_email` personal de `docs/equipo.json` y `docs/equipo.md` antes del `push` (`jurado_etica.md` I-4).
13. **Voz s3.b2.** *"only one in eight"* → *"only about one in eight"* (13.2 %), sin coste de tiempo.

## 7. Justificación de la nota (8/10)

A favor:

- Las seis preguntas obligatorias tienen respuesta explícita en voz, pantalla y notebook. P7 y P8 llevan pregunta y caja "ANSWERED", y la tesis (P8) recorre todo el vídeo.
- Las cifras salen de una sola fuente: todas las del texto tienen `verified: true` y, salvo las de dentro de las figuras, verificación humana.
- El formato cumple: 4:52.2, 1 + 4 + 1 páginas, nombres bien escritos.

En contra:

- La región de P4 y P7 es débil, aunque las dos preguntas la piden.
- Las cajas de respuesta no cubren todas sus etiquetas.
- Las etiquetas P1–P8 no se explican.
- P2 es parcial y P3 falta.
- Hay cifras de figuras fuera de la verificación humana.
- Faltan el vídeo con voz y el repositorio publicado.

Con I-1 a I-5 hechos, la nota subiría a unos 9.
