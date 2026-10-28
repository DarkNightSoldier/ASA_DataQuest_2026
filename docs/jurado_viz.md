# Jurado simulado · *Best Data Visualization* (ASA International DataQuest 2026)

> Agente **jurado-viz** (IA, Claude Code) · 2026-10-27 · solo lectura del repositorio (único archivo escrito: este).
> Estado revisado: `HEAD` = `5ec1bd6` (posterior a `c367937` / `submission-2026-10-30-rc1`). Criterio oficial del premio: *"Most effective graphics communicating findings"*.
> Texto de pantalla y voz citado en inglés; el resto en español.

## 0. Qué miré (todo con Read, imagen por imagen)

| Material | Cómo | Evidencia temporal (scratchpad `…/scratchpad/jurado_viz/`) |
|---|---|---|
| `slides/export/slides.pdf` (6 páginas) | `pdftoppm` a 96 ppp (1920×1080) y a 48 ppp (**50 %**, 960×540); recortes a 192 ppp de fig01, fig03, fig04, fig07, fig09, fig10_print y fig11_print | `pdf/p-*.png`, `pdf/half-*.png`, `crop3/*.png` |
| `video/deck_silent.mp4` (4:52,2 · 1920×1080 · 30 fps) | **12 fotogramas repartidos** en t = (i + 0,5)·24,35 s con el ffmpeg del venv; además 1 fotograma 0,6 s después de cada bloque de subtítulo de los pasos animados (35) y una secuencia a 2 fps del zoom al Golfo | `f12/f00…f11_*.png`, `f12/sheet12_*.png`, `cues/*.png`, `zoom/sheet.png` |
| `slides/dev/screenshots/steps/` (32 estados) | hojas 2×2 a 50 % | `stepsheets/sheet_00…07.png` |
| Sincronía | `slides/script/captions.json` (68 bloques) frente a los fotogramas anteriores | `cues/sheet_*.png` |
| TRITICS (ganador 2025 de este premio) | `docs/referencia_ganadores/frames_tritics/` (21 fotogramas) en hojas 3×2 | `tritics_sheet_*.png` |
| Medidas | caja de contenido no blanco por fotograma (umbral gris < 235); palabras por página del PDF (`pdftotext -layout` + `wc -w`); palabras HTML visibles por paso (Playwright, sin texto recortado por `overflow`); colores de fig07 (`PIL`) | `scripts/count_words.py` |

## 1. Veredicto

**8,4 / 10** como lo puntuaría un jurado internacional de visualización. Tras los 4 imprescindibles (§4), ≈ 8,9–9,1.

Es una entrada de nivel ganador. Tiene un **sistema visual** y no solo gráficos sueltos:

- La ecuación en pastillas (`births` #0072B2 · `deaths` #E69F00 · `net migration` #56B4E9) es la leyenda de todo el vídeo. Se repite con el mismo significado en fig00, fig01, fig02, fig05, fig09 y fig11.
- Los grupos de la P3 llevan una paleta Tol propia (Early #332288, Fast #117733, Recent #DDCC77, Migration-led #88CCEE). Es la misma en los chips, el mapa, las bandas y la leyenda.
- La estructura se lee sola: pregunta → titular-mensaje → figura → nota → recuadro "Question N answered".

Las dos animaciones héroe (**fig04**, el registro de calendarios, y **fig10**, el mapa más los pequeños múltiplos) son lo mejor del concurso que conozco. Ahí la animación *es* el argumento.

Lo que impide el 9:

1. La **P8** (obligatoria) se ve pequeña. Durante los 15,2 s de s3.b1, el bloque de fig07 (titular + gráfico + notas) ocupa x = 64–632 px e y ≤ 684 px, ≈ **21 % del área útil**. El resto de la diapositiva está en blanco.
2. Los **estados finales de S3 y S4 están sobrecargados**. El PDF tiene 360 y 571 palabras en esas páginas, frente a 341–353 en S1–S2.
3. En **fig11** (versiones `_print` y `_small`) hay **rótulos que chocan o se cortan**. Se ven en el PDF y durante ≈ 31 s del vídeo.
4. Los **códigos "P7 · P4"** aparecen en todas las diapositivas y no se explican en ninguna parte.

## 2. Evaluación por criterio

| Criterio | Nota | Evidencia (lo que se ve) |
|---|---|---|
| **Claridad** | 9 | Cada figura responde una frase. Ejes en lenguaje llano ("median age (half the people are older)", "0 = none · 1 = all"). Cada definición aparece donde se usa (R², *look-alikes*, "Lever = a component of the population balance, not a policy switch"). fig04 rotula su propio artificio: "all curves meet here by design". |
| **Jerarquía** | 8,5 | Las cabeceras son iguales en las 4 diapositivas: chip "Question N", título-pregunta, navegación Q1/Q2/Q3 y pie de fuente. Los titulares de figura son mensajes ("High-income growth since 2000: mostly net migration"). El recuadro de respuesta cierra cada pregunta. Resta: en S3 los tres bloques tienen el mismo peso y nada guía la vista en el estado final. |
| **Densidad de texto** | 6,5 | Palabras por página del PDF: portada 218 · S1 341 · S2 353 · S3 360 · **S4 571** · Referencias 517. En el vídeo, la construcción por pasos lo alivia. Aun así, al final de cada diapositiva quedan en pantalla estas palabras HTML (contadas con Playwright; no incluyen el texto dentro de las figuras ni el subtítulo): s1.b5b 304 · s2.b4 320 · **s3.b4 348** · s4.b3 273 · s4.b4 258. En s3.b4 la voz dice 51 palabras en 24 s. En S3 hay una nota que **nunca se narra** y solo sale en el vídeo: "Even the death rate changed meaning: Portugal and Chad…". |
| **Legibilidad** | 7,5 | A tamaño completo, ningún texto HTML baja de 18 px (QA-viz). **Al 50 %** se leen los titulares, los rótulos grandes y las cifras clave; las notas (16–18 px → 8–9 px) no se leen. En el PDF al 50 %, la página 5 queda en una tabla de 8 px, un mapa de ≈ 275 px (a tamaño completo) y tres mini paneles. Falla de oficio: los choques de fig11 (§4, I-1). |
| **Consistencia de color** | 8,5 | Hay un solo significado por color en palancas y grupos. La proyección es gris discontinuo con línea en 2023 (fig03, fig07, fig10). La banda entre países de fig11 va en tinta #D5DAE3 para no confundirse con Early. Excepciones: (a) en **fig07** las barras estimadas "fast levers" son gris oscuro **#4D4D4D** (`COL_RAPIDO`, `R/fig_q2_slide3.R` l. 121), el mismo gris del escenario de migración cero en fig03; la barra proyectada, en cambio, va en azul pálido. Es la inversa de "grey = UN medium projection", que anuncia el pie de cada diapositiva. (b) En el zoom al Golfo (s1.b5a–b) el resto de países pasa a gris claro de atenuación, justo encima de la leyenda que dice "grey: small states (< 1 M)". |
| **Animación ↔ voz** | 9 | Ver §3. s2.b1, s4.b1 y s4.b3 señalan cada frase en el momento en que se dice. Las fallas son menores: fig01 llega ≈ 4 s tarde al foco "High" y s3.b4 y s4.b4 no señalan lo que nombra la voz. |
| **Frente a TRITICS** | superior en gráficos, inferior en impacto inmediato | §5 |

## 3. Sincronía voz ↔ animación (fotograma 0,6 s después de cada bloque)

| Paso | Bloque de voz (t, s) | Lo que se ve | Veredicto |
|---|---|---|---|
| cover.b1–b3 | "Eight billion people." 0,0 · "Yet 84 are still growing." 11,6 · "66 … 18 …" 15,7 | El contador 1950 → 2023 llega a "8.1 billion 2023". Los puntos pasan a gris oscuro (130) y luego a azul y celeste. Las pastillas 66 y 18 llevan los colores de las palancas | ✔ |
| s1.b2 (fig01) | "In today's high-income countries…" 53,5 · "about seven in ten…" 57,3 · "Elsewhere…" 62,8 | A 54,1 s solo hay barras de los 1950s (construcción por décadas). El foco "High" llega a 57,9 s y el resto se colorea a 63,4 s | ✔ con ≈ 4 s de retraso en el foco |
| s1.b3–b4c (fig02 + capas) | "Blue…", "including 22…", "Light blue…", "Orange…", "Purple…" | Una capa por bloque, con ISO3 y banderas en la leyenda en el mismo instante | ✔ |
| s1.b5a (fig02b) | "Migration is also the least certain lever." 88,5 | Zoom de 0 a 2,5 s; desde ≈ 3 s, el Golfo en gris con los EAU resaltados. Ya no hay cajas fantasma (corregido por H-26) | ✔. Duda de lectura: los EAU van en **azul = births > deaths** mientras la voz habla de migración |
| s2.b1 (fig04) | "Set each country's clock…" 101,9 · "and the curves line up." 107,3 · "The road is shared…" 109,3 · "China … 5 years; Egypt took 33." 112,5 | Calendario con EGY/COL/CHN → deslizamiento → "all curves meet here by design" → barra "CHN · 5 years" a 113,1 s | ✔ la mejor animación del deck |
| s3.b1 (fig07) | "…three quarters…" 161,5 · "Only part of today's growth…" 167,4 | La barra 0,77 crece en ese bloque; la de crecimiento arranca a 168 s | ✔ (en tiempo, pero el gráfico es pequeño: I-2) |
| s3.b3 (fig09) | "two separate ways" 179,8 · "Fertility tracks the first…" 182,8 · "but misses migration" 187,2 | COL y sus *look-alikes* → flechas, con fertilidad en azul → "Axis 2 — migration" y los estados del Golfo | ✔ |
| s3.b4 | "Blend indicators…" 189,3 · "The Emirates and Belarus…" 200,2 · "The story emerges only when transition and migration are read together." 208,9 | Entra la franja del índice compuesto. **La tarjeta EAU–Bielorrusia y la PCA no se resaltan cuando se nombran**; todo sigue al 100 % | ✘ menor (I-3) |
| s4.b1 (fig10) | "three stretches" 215,3 · "migration-led group" 219,7 · "Early movers…" 222,5 · "Fast movers, India, China and Indonesia," 226,9 · "30 to 40 in about 32 years" 229,3 · "About as fast as Early movers…" 235,6 · "Recent movers…" 239,2 | Golfo resaltado a 220,3 · foco Early (USA/RUS/JPN) a 223,1 · foco Fast + CHN/IND/IDN a 227,5 (V10 corregido) · línea "Median age 30 → 40: Fast movers in 32 years (95 % range 27–37)" a 229,9 · Early + Fast a 236,2 · Recent + PAK/NGA/ETH a 239,8 | ✔ |
| s4.b3 (tabla) | filas 1, 2 y 4 a 251,6 / 258,0 / 262,0 | Fila nombrada sobre fondo #EAF1F8 y las demás al 40 % | ✔ |
| s4.b4 (ética) | "Projections are labelled as scenarios; examples follow a rule…" | Las 5 tarjetas aparecen juntas, sin resalte por bloque; la fila superior (ya narrada) sigue al 100 % | ✘ menor (mejora) |

## 4. Imprescindibles (máximo 8; ejecutables en ≤ 2 días)

**I-1 · fig11 `_print` (PDF p. 5) y `_small` (s4.b3–s4.b5, ≈ 31 s): rótulos que chocan o se cortan.**
En `crop3/p5_fig11.png` y `crop3/s4b3_top_right.png` se ve lo siguiente:

- La leyenda compartida "161 countries ≥ 1 M · (UN) estimates 1950–2023 · same scale" (y = 133 / 124) cruza bajo el título del panel de edad mediana y toca "SD 4.7 → 9.7".
- "SD 4.7 → 9.7" queda pegado a la marca "50" del eje y se lee "50 SD 4.7 → 9.7".
- El halo de "20×" tapa la parte baja de "bars = 95 % ranges".

**Corrección** en `R/fig_q3_slide4.R`, `dibujar_fig11()`:

- (a) En la rama `else` (impreso/small) del bloque "leyenda de lectura", borrar las cuatro líneas `ley <- …`, `avisar_ancho(ley, …)`, `g <- g + texto(paneles$lex[1], y_leyenda, ley, …)` y `g <- g + texto(tira_x[2], y_leyenda, "bars = 95 % ranges", …)`.
- (b) En la rama `else` del panel de edad (impreso/small), cambiar `texto_halo(xx[1] + 4, sy(56.5), rotulo_sd[[pn]], TAM$valor, COL_TINTA, hjust = 0, negrita = TRUE)` por `texto_halo(xx[2] - 2, sy(56.5), rotulo_sd[[pn]], TAM$valor, COL_TINTA, hjust = 1, negrita = TRUE)`.
- (c) En `slides/index.html`, `.blk11 > p.fn`, cambiar `<span class="print-only">SD = typical gap between countries · </span>` por `<span class="print-only">SD = typical gap between countries (161 countries ≥&nbsp;1&nbsp;M) · bars = 95 % ranges · </span>`. Cabe en las 2 líneas actuales.

Después: `Rscript R/fig_q3_slide4.R fig11` → `video/export_pdf.sh --png` → `slides/dev/screenshots.py` → `slides/dev/check_sync.py` → `video/record_slides.py --mp4`. Para comprobarlo, mirar la p. 5 del PDF y s4.b3 recortando el bloque de fig11.

**I-2 · S3 (P8, obligatoria): fig07 pequeña con 2/3 de la diapositiva en blanco durante s3.b1 (15,2 s).**
fig04 y fig10 ya aplican el patrón "héroe → se encoge"; fig07 no, y es el gráfico que contesta P8. El MP4 mide 1144×526, así que puede verse ≈ 1,5× más grande sin perder nitidez.

**Corrección** (solo CSS, no toca el PDF). Añadir en `slides/css/theme.css`, después de la regla `.s3 .row-main { … }`:

```css
/* s3.b1: fig07 héroe a todo el ancho (como fig04/fig10); en b2 se reparte en las 3 columnas */
.s3 .row-main { transition: grid-template-columns .9s ease, column-gap .9s ease; }
html:not(.is-print) .s3:not(.ge-2) .row-main { grid-template-columns: minmax(0, 1fr) minmax(0, 0fr) minmax(0, 0fr); column-gap: 0px; }
```

**Probado sin tocar el repositorio:** inyecté el CSS con Playwright (`…/jurado_viz/scripts/test_css.py`). En s3.b1, fig07 pasa de ≈ 572 × 263 a **879 × 404 px (1,54×)**, centrada y nítida. A los 2,5 s de s3.b2 vuelven las 3 columnas sin solaparse (`…/jurado_viz/test_css/sheet.png`).

Después: `slides/dev/screenshots.py`, `check_sync.py` y volver a grabar.

**I-3 · Estados finales sobrecargados de S3 y S4 en el vídeo; s3.b4 no señala lo que nombra la voz.**
**Corrección:**

- (a) En `slides/index.html` (S3, `.blk07 .txtgroup`), borrar el párrafo `<p class="fn print-hide">Even the death rate changed meaning: Portugal and Chad, … years apart in life expectancy</p>`. No se narra y no está en el PDF.
- (b) Añadir en `slides/css/theme.css`:

```css
/* s3.b4: lo ya narrado baja al 40 %; la PCA vuelve al 100 % cuando la voz dice "transition and migration" */
html:not(.is-print) .s3.ge-4 .blk07 > *,
html:not(.is-print) .s3.ge-4 .blk08 > .fragment:not(.twins) > *,
html:not(.is-print) .s3.ge-4 .blk09 > * { opacity: .4; transition: opacity .6s ease; }
html:not(.is-print) .s3[data-cue="s3.b4:5"] .blk09 > * { opacity: 1; }
/* s4.b4: la fila superior (ya narrada) se atenúa mientras habla la ética */
html:not(.is-print) .s4.ge-4 .row-top { opacity: .45; transition: opacity .6s ease; }
```

Así quedan al 100 % la franja del índice compuesto, la tarjeta EAU–Bielorrusia (que se nombra en los bloques 3 y 4) y el recuadro de respuesta. Lo probé igual que I-2: s3.b4 y s4.b4 en `…/jurado_viz/test_css/sheet.png`; lo nuevo destaca y lo narrado sigue legible. El índice de bloque de `data-cue` empieza en 0, como en las reglas de s4.b3. Volver a correr las capturas, `check_sync.py` y la grabación.

**I-4 · Códigos "P7 · P4", "P8 · P5" y "P6 · P1" sin explicar** (chip de cada cabecera, tarjetas de s1.b0, sellos "Question N answered" y línea de preguntas de la portada del PDF). Un jurado no sabe que son las preguntas sugeridas del *Getting Started* (§6), que allí van sin numerar, y "P6 · P1" se puede leer como "página 6 · 1". TRITICS sí definió sus códigos (fotograma `10_tabla_variables_codigos_lenguaje_llano`).

**Corrección** en `slides/index.html`:

- (a) En `.datacard` de S1, añadir como última línea `<span>P1–P8 = the eight suggested questions of the DataQuest Getting Started guide (§6), numbered in their order</span>`.
- (b) En `<p class="cover-questions print-only">`, añadir antes de `</p>`: ` · <span class="pc">P1–P8 = suggested questions of the Getting Started guide (§6), in order</span>`.

Después: `video/export_pdf.sh --png` y volver a grabar. La voz no cambia.

> Los cuatro cambian píxeles del vídeo, pero **ninguno cambia una cifra** (P-01 no se reabre) ni la voz, ni los tiempos de `video_timings.json`.

## 5. ¿Superamos visualmente a TRITICS?

**Sí en lo que premia el jurado (gráficos que comunican hallazgos), no todavía en impacto inmediato.**

| | TRITICS 2025 (ganador Best Data Visualization) | UNALSta-R 2026 |
|---|---|---|
| Gráficos de evidencia | Barras industria/agricultura con banderas por eje, sin unidades en el eje y; mapa por sector significativo; tabla de variables con banderas; matriz de "palancas" con iconos | 12 figuras con ejes rotulados, bandas de dispersión, intervalos al 95 %, pequeños múltiplos, registro animado y PCA con su prueba de ruido |
| Color | Tema naranja/negro de marca; el naranja no codifica un dato fijo | Una paleta con significado único (palancas) más otra (grupos), aptas para daltonismo (Okabe-Ito, Tol) |
| Animación | Cortes de diapositiva y presentador | Construcción sincronizada con la voz: cada frase enciende lo que nombra (§3) |
| Densidad | Pocas palabras por lámina, letra grande | 341–571 palabras por página (PDF): más rigor y menos lectura de un vistazo |
| Presencia humana | Tres presentadores sobre la lámina, que **tapan partes de los gráficos** (fotogramas 11–16: mapa y lista de variables ocultos) | Solo voz y subtítulos; nada tapa los datos |
| Incertidumbre / honestidad | No aparece | Visible en todas las diapositivas |

Riesgo: un jurado que premie "impacto" puede leer nuestro deck como un póster académico. I-2 e I-3 reducen ese riesgo justo donde más pesa: la P8.

## 6. Mejoras (deseables, por prioridad)

1. **PDF p. 5 (S4) sin la figura héroe.** `fig10_print` sustituye los pequeños múltiplos por una tabla de grupos, de modo que la evidencia de "one road, four groups" solo existe en el vídeo. Propuesta: en impreso usar `fig10_trajectory_groups_small.png` (1021×220: mapa + múltiplos) con la `.glegend` en una sola línea. Para ganar el alto (≈ 110 px), quitar del PDF la nota `.nb .fn` y acortar la línea "How we grouped". Una alternativa es fusionar las columnas "For (mandate)" y "When" de la tabla. Objetivo: ≤ 420 palabras en la página.
2. **fig07: barras "fast levers" en tinta.** En `R/fig_q2_slide3.R` l. 121, `COL_RAPIDO <- "#15233B"` (y la etiqueta "fast levers" en tinta), para que el gris quede solo para proyección y escenarios.
3. **fig01 (s1.b2): foco "High" al empezar.** La voz dice "high-income" en t = 0 y el foco llega ≈ 4 s después. Comprimir la construcción por décadas a 0–1,5 s en `R/fig_q1_slide1.R`, o leer el hito de `video_timings.json` como ya hace fig10. Otra opción es aplicar a s1.b2 el mismo patrón héroe de I-2, porque la mitad derecha está vacía 12,9 s.
4. **s4.b4: resaltar cada tarjeta de ética cuando la voz la nombra**, con `data-cue`, igual que la tabla de s4.b3. Bloque 0 → "Scenarios, not forecasts"; 1 → "Open & checkable"; 2 → "Patterns, not causes"; 3 → "Open & checkable".
5. **Zoom al Golfo (s1.b5a–b).** Atenuar el resto de países con blanco y contorno en lugar de gris claro, para no contradecir "grey: small states (< 1 M)". Añadir a los EAU un contorno celeste o el rótulo "+28 net arrivals per 1,000": el país va en azul (births > deaths) mientras la voz habla de migración.
6. **Portada del PDF.** Desglose "84 still growing (66 births > deaths · 18 only because…)": la línea se parte dejando "(" al final y la pastilla de 18 en la línea siguiente. Usar `white-space: nowrap` en el paréntesis completo o pasarlo a su propia línea.
7. **Clave del mapa de puntos de la portada.** En cover.b2–b3, una línea de 18 px: "each dot = land of one country · colour = its 2023 type".
8. **P2/P3 visibles.** La tarjeta de los EAU ya usa los intervalos 80/95 % de OtherVariants ("for 77 of 161 countries it spans both growth and decline"). Añadir el código "P2 · P3" (con la clave de I-4) para que el jurado vea cubiertas también las preguntas opcionales.
9. **Tabla de S4, primera fila.** "child deaths fall too slowly" → "child deaths off pace for SDG 3.2", como ya dice la voz (H-10).
10. **S2 y S3: blanco reservado.** En s2.b1–b3 y s3.b1–b3 queda vacía una franja inferior de ≈ 250 px, reservada para el recuadro de respuesta. Puede plegarse como en S4 (`:not(.ge-N) > .frame > .msgrow.answer { display: none }`) para dar ese alto a las figuras.
11. **Nota de rigor, no de visualización (para QA-stats).** "the ratio grew, but the gap in deaths shrank" y "the absolute gap shrank" se apoyan en `q5_gap_p90p10_1950/2023`, que siguen con `verified: false`. No se muestra la cifra, pero la afirmación se deduce de ella.

## 7. Lo que no hay que tocar

- **fig04** (s2.b1): calendario → registro → mediana → CHN, COL y EGY, en 18,5 s y siguiendo la voz frase a frase.
- **fig10** (s4.b1): mapa + pequeños múltiplos con foco por grupo; la proyección en gris discontinuo con la línea de 2023.
- **fig02** con capas por tipo y leyenda con conteos que suman 237 (165 + 18 + 35 + 19), con la franja de < 1 M por región.
- La **ecuación en pastillas** como clave de color de todo el vídeo.
- La tabla de s4.b3 con resalte por fila al ritmo de la voz.
- El *callback* oscuro de s4.b5 y los subtítulos incrustados en un solo estilo.
