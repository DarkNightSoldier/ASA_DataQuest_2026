# QA-slides · Jurado general y "familiar no estadístico"

Agente **QA-slides** · 2026-10-25 · revisa `slides/export/slides.pdf` (6 páginas, generado 15:33),
las 32 capturas de `slides/dev/screenshots/steps/` + los 7 finales, `slides/script/narration_en.md` (v3) y
`slides/script/video_timings.json` (v3). No se editó `index.html` ni la narración: cada hallazgo trae la
corrección exacta y el agente dueño.

**Cómo se revisó.**
1. PDF → PNG a 96 ppp (1920 px) y a 48 ppp (**50 %**, 960 px); recortes a 2× (192 ppp) de fig04, fig07, fig09, fig10, fig11. Todas las páginas y recortes se miraron uno por uno.
2. Auditoría automática del DOM (Playwright, 1920×1080, `qa=off`): en los **32 estados del vídeo y en las 6 páginas del modo PDF** se midió el `font-size` de cada nodo de texto visible y se buscaron cajas de texto que se cruzan. Script: `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/qa_slides/audit_text.py`.
3. Altura de tinta del texto **dentro de las figuras** (PNG), calibrada con el pie HTML de 18 px.
4. Cruce automático de **todas** las cifras del texto del PDF (`pdftotext`) con las claves `verified: true` de `figures/numbers.json` (ROUND_HALF_UP a 0/1/2 decimales), y revisión del código de las figuras (`R/fig_*.R`) para las cifras que van dentro de los PNG.
5. Tiempos, velocidad de subtítulos (caracteres por segundo) y coherencia voz ↔ pantalla ↔ `numbers.json`.
6. Prueba del familiar (7 preguntas de `00_plan_implementacion.md` v1 §7.10) y comparación con TRITICS (`docs/referencia_ganadores/frames_tritics/`) y `ahzasasa` (`docs/01b` §2.3 y `otros_equipos/2026_ahzasasa_*`).

---

## 1. Veredicto

- **Formato correcto**: 6 páginas (portada + 4 + referencias), 1440×810 pt, fuentes incrustadas, 1,75 MB; rótulo `Question N` y recuadro `Question N answered` en cada diapositiva de contenido; sin logos; afiliación exacta de `docs/equipo.json`; atribución CC BY 3.0 IGO en el pie de cada página y en las referencias.
- **Duración modelada 294,1 s ≤ 300 s**, pero con solo 5,9 s de margen y suponiendo 150 palabras por minuto (ver H3).
- **Texto HTML ≥ 18 px en los 38 estados auditados** (mínimo exacto 18 px); títulos de diapositiva 46 px, portada 104 px; **0 solapes reales**. Las 170 alertas del detector eran falsos positivos (la región `aria-live` de reveal, las dos líneas del título de portada y la tabla que queda debajo del panel de ética o del *callback* en s4.b4–b5).
- **Todas las cifras HTML del PDF coinciden con claves verificadas.** Las excepciones están **dentro de las figuras**: 311 → 64 (fig11) y 7 (fig09) salen de claves con `verified: false`, y 57 (fig04) y 69–107 (fig05) no son claves (H2).
- **P7 y P8 no tienen pérdida**: las preguntas se citan casi al pie de la letra en la portada y en s1.b0, y la respuesta se lee y se oye ("Question one, answered", "Question two, answered: no").
- **Hay una contradicción que cualquier jurado ve**: la portada dice "66 [por debajo del reemplazo] crecen porque los nacimientos superan a las muertes", y la S1 y la S4 dicen "22 countries" con casi las mismas palabras (H1).

## 2. Puntuación por premio (1–10)

| Premio | Hoy | Con las correcciones Alta + Media | Por qué |
|---|---|---|---|
| **Best Statistical Insight** | **8,5** | 9,2 | Responde P1 y P4–P8 con métodos honestos: censura en el rezago, dentro vs entre países con placebo, R² fuera de muestra, análisis paralelo, recuperación de *look-alikes*, Monte Carlo de 2 000 índices, estabilidad de grupos. Le restan la contradicción 22/66, la sobrelectura de "not the fast one" con R² = 0,59 (intervalo 0,31–0,80) y "further apart in child deaths" cuando la brecha absoluta se cerró |
| **Best Data Visualization** | **8,0** | 8,8 | El sistema es coherente: colores con significado fijo, builds que señalan, banderas, recuadros de respuesta, pie fijo. Le restan la densidad de las páginas 4 y 5 al 50 % (notas de 18 px que quedan en 9 px, minigráficas de fig10 diminutas), la tabla de la S4 ilegible en 15,8 s de vídeo y los recuadros de respuesta a 23/21 px |
| **Best Consideration of Ethics** | **8,5** | 9,4 | Franja ASA con códigos, hash de hipótesis, declaración de IA, estimación vs proyección en cada página, ejemplos por regla, rangos de la ONU, posicionalidad (Colombia), sin logos. Le restan dos afirmaciones que hoy no son del todo ciertas: "public repository" (el repositorio no existe aún) y "every number … re-computed by independent code" (fig09 y fig11 llevan cifras sin verificar) |

**Nota global: 8,3 / 10.**

---

## 3. Hallazgos (de más a menos grave)

Severidad: **Alta** = la vería un jurado o rompe una regla del concurso o del equipo; **Media** = baja la nota de un premio; **Baja** = pulido.

| # | Sev. | Dónde | Problema | Corrección exacta | Dueño |
|---|---|---|---|---|---|
| H1 | **Alta** | Portada (PDF p1 y cover.b3) frente a S1 s1.b3b (`index.html` l. 175–176, voz) y S4 tabla fila 2 (l. 408) | La portada dice "130 below replacement · 84 still growing (**66** births > deaths · 18 …)". La S1 dice "Blue: growing from births, **including 22** countries below replacement" y la S4 "fertility is below replacement but the population still grows: **22** countries". Son 22 porque `n_momentum_countries` = tipo B (**sin llegadas netas**) ∩ TFR < 2,1; los otros 44 del tipo A también crecen por nacimientos. El familiar oye 66 y luego 22 para lo mismo | **Voz** (plantilla → `build_narration.py` → `data-caption`): s1.b3b `including 22 countries below replacement.` → `including 22 below replacement that grow with no help from migration.` · **S1** l. 176: `Below replacement, still growing from births:` → `Below replacement and growing from births with no net arrivals:` · **S4** l. 408: `fertility is below replacement but the population still grows:` → `below replacement, growing from births with no net arrivals:` | script-narration · slides-revealjs |
| H2 | **Alta** | Dentro de las figuras: fig11 (S4, vídeo y PDF) `gap: 311 → 64 per 1,000`; fig09 (S3) `net migration capped at ±3 SD for 7 countries`; fig04 (S2) `(57 countries with 20 years of data …)`; fig05 (S2) `(69 to 107 countries per year)` | La regla es que solo se muestran claves `verified: true`. `q5_gap_p90p10_1950/2023` y `n_cnmr_winsorized_2023` están en `false` y su `nota_qa` dice "not used on screen", lo que ya no es cierto: `R/fig_q3_slide4.R` l. 1452–1463 y `R/fig_q2_slide3.R` l. 1078–1079 las dibujan. 57 y 69–107 se calculan dentro de `R/fig_q1_slide2.R` (l. 629 y 1068) y no son claves. Mientras tanto, las referencias y la tarjeta de ética afirman "every number … re-computed by independent code" | **QA-stats**: lote 5 con `q5_gap_p90p10_1950`, `q5_gap_p90p10_2023` y `n_cnmr_winsorized_2023` (más `used_in` = fig11/fig09); registrar `n_fig04_band_57` y `n_fig05_band_range` con `registrar_cifra()` y verificarlas; volver a correr `consolidar_verificacion.R` y `R/05`. **Si no da tiempo antes de grabar**: fig11 sin la etiqueta "gap" (pero entonces aplicar M2 con palabras), fig09 `…capped at ±3 SD for a few countries (incl. UAE and Oman)`, fig04 `(countries with 20 years of data on each side)`, fig05 `band = middle half of countries` | QA-stats · figures-static |
| H3 | **Alta** (riesgo) | `video_timings.json` / `narration_en.md` | 294,1 s es un modelo a **150 ppm**. Con 613 palabras habladas a 140 ppm (ritmo habitual de un hablante no nativo) salen ≈ 308 s, **por encima de 5:00** | Lectura cronometrada por el narrador **antes** de grabar. Recortes ya aprobados, en este orden (≈ 11 s): (1) s1.b0: quitar `After 2023, grey shows the UN medium projection: a scenario, not a forecast.` (13 palabras; ya está en el pie de cada página y en s4.b4); (2) s1.b4a/b/c: quitar las listas habladas `Germany, Spain and Belgium.` · `China, Russia and Japan.` · `Nepal, Azerbaijan and Uruguay.` (las banderas siguen en pantalla); (3) s3.b1: `But only 60 percent of today's growth, and almost none of migration.` → `Only part of today's growth, and almost none of migration.` (ver M1). Comprobar el MP4 final con `ffprobe` ≤ 300,0 s | script-narration · video-record |
| H4 | **Alta** (ética) | Referencias (PDF p6): `…are in our public repository`; tarjeta "Open & checkable … public repository" (s4.b4); voz s4.b4 `documented publicly` | `docs/equipo.json`: `repo = null` ("Pendiente de crear el repositorio público"). Sin URL, el jurado no puede comprobar nada, y si el repositorio no está abierto el día de la entrega la frase es falsa (ASA C.2, F.4). Es justo lo que `ahzasasa` sí tiene | **repo-ops**: crear el repositorio público antes del 30-oct (plan §7.13), poner `repo` en `R/config.R` → `numbers.json` (verificada) y en referencias `…are in our public repository: github.com/<repo> (code MIT; texts CC BY 4.0).` **Si no se publica**: referencias `…are available from the team on request`, tarjeta `…every number re-computed by independent code · notebook available on request` y voz s4.b4 `…every number and our AI use are documented in our notebook.` | repo-ops · slides-revealjs · script-narration |
| M1 | Media | S3: recuadro de respuesta, corchete `fast levers` de fig07, voz s3.b1 | "One indicator tells the slow story …, **not the fast one (growth, migration)**" no se sostiene para el crecimiento. El R² de fertilidad → crecimiento es **0,59** con intervalo por bloques **0,31–0,80**, que se solapa con el de la edad mediana (0,67–0,84). Lo que de verdad separa es la migración (0,00), los *look-alikes* (13 % frente a 43 %) y los gemelos | **Recuadro S3**: `No. Fertility alone tells how old a population is (0.77) and only part of today's growth (0.59), but nothing about migration (0.00) — it finds 13 % of each country's look-alikes. Same fertility: UAE +3.70 % a year vs Belarus −0.65 %.` · **Voz** s3.b1: `But only 60 percent of today's growth,` → `Only part of today's growth,` · fig07: el corchete `fast levers` puede quedarse | slides-revealjs · script-narration |
| M2 | Media | S4, titular de fig11 (PDF p5, l. "Closer in life expectancy …") | "further apart … in child deaths: … 6× … 1950, 20× in 2023" es cierto **solo en términos relativos**. La brecha absoluta P90−P10 cayó de 311 a 64 por 1 000, y la razón tuvo su pico (≈ 27×, `q5_ratio_p90p10_peak`, verificada) en los años 2000 y luego bajó. El vídeo (s4.b2) lo explica ("the ratio grew, but the gap in deaths shrank"); el PDF no | Versión impresa del titular: `…further apart in age (SD 4.7 → 9.7 years) — and, in relative terms only, in child deaths: the highest tenth had 6× the rate of the lowest tenth in 1950 and 20× in 2023 (peak ≈ 27× in the 2000s), while the absolute gap shrank.` (sin año exacto del pico, según QA_stats §3.3) | slides-revealjs (tras H2) |
| M3 | Media | S4, tabla, columna ROAD y fila 3 impresa (l. 405–415) | "mostly Recent movers (50 of 62)" frente a "58 of 70"; "(13 of 13)" frente a "22 countries"; "(33 of 35)" frente a 53; "(11 of 11)" frente a 18; "(4 of 6)" frente a 19. Los denominadores son los países ≥ 1 M agrupados y eso **no se dice**. "mostly … 13 of 13" debería decir "all". En el PDF, "53 countries (**28 %**)" se lee como 28 % de los países, cuando es el **28 % de la población** | Cabecera `Road` → `Road (of the row's countries ≥ 1 M)`. Fila 3 `.print-only`: `(<span data-num="share_pop_natneg_2023">—</span> %)` → `(<span data-num="share_pop_natneg_2023">—</span> % of people)`. `rec_rows[1,3].road`: `mostly` → `all` cuando n = N (en el script R; después QA-stats vuelve a fijar la huella) | slides-revealjs · notebook-R · QA-stats |
| M4 | Media | Portada PDF (`.cover-summary` print-only) y S1/S4 en el PDF | En el PDF **"replacement" nunca lleva glosa**: la nota de cover.b2 tiene `print-hide`, y la línea dice "130 below replacement" sin decir de qué | `130 below replacement` → `130 of 237 below replacement fertility (≈ 2.1 children per woman)` | slides-revealjs |
| M5 | Media | Recuadros `Question N answered` (vídeo 23 px; PDF S4 21 px) | El storyboard pide titular de respuesta a 28 px en 2 líneas; hoy son 3 líneas a 23 px, que al 50 % quedan en 11 px. Es el texto más importante para el jurado | Texto más corto y 28 px (≥ 24 px en el PDF). **Q1**: `Child deaths fell first, fertility followed — at each country's pace, latest in low-income countries. Migration moves on its own and accounts for ≈ seven in ten of high-income growth since 2000.` (los años 1970/1984/2000 ya están en la nota de fig05; no usar *drove*: verbo causal vetado por QA-ethics) · **Q2**: el de M1 sin la frase de los gemelos si no cabe · **Q3**: `Mostly one road at different speeds — Early, Fast and Recent movers, plus a migration-led group — each with something different for the UN to watch.` | slides-revealjs |
| M6 | Media | PDF p4 (S3) y p5 (S4) al 50 % | Al 50 % (960 px), las notas de 18 px quedan en 9 px. Densidad: S3 tiene 5 líneas de notas bajo fig07 + 3 bajo fig09; S4 tiene el *method strip*, notas de fig10 y fig11 y 5 filas de tabla. Texto interno de figura medido en **≈ 17 px** (leyenda R² de fig07, nota de fig09, nota de fig10): justo por debajo de 18 px. Las minigráficas de `fig10_…_print.png` (≈ 180×40 px por panel) no se pueden leer | S3, columna izquierda impresa: dejar solo `R² = share of the differences between countries that fertility alone reproduces (0 = none, 1 = all) · 2050 change is partly built in`; la frase "births − deaths + migration … 0.99 … (bookkeeping)" pasa al notebook. Regenerar `fig07_…_print.png` y `fig09_…_print.png` con notas ≥ 20 px. En `fig10_…_print.png`, quitar las minigráficas y dejar mapa + leyenda (n, bn, banderas), o darles 2× de alto | figures-static · slides-revealjs |
| M7 | Media | S1, fila "165 Growing from births" (PDF p2, s1.b3b) | Las banderas IND·BRA·MEX quedan en la fila de los 165, pero son los tres mayores de los **22**. La nota dice "examples chosen by rule: the three largest countries of each type (≥ 1 M)", y los tres mayores de los 165 serían India, Estados Unidos e Indonesia. Se rompe la regla que la propia nota anuncia | Con H1, la frase queda `Below replacement and growing from births with no net arrivals: 22 countries, 2.2 bn people — largest: IND · BRA · MEX`. Nota: `… the three largest countries of each type (≥ 1 M); for blue, of these 22` | slides-revealjs |
| M8 | Media | Vídeo s4.b3 (15,8 s) | La tabla de 5×5 (≈ 150 palabras) está en pantalla 15,8 s mientras la voz lee 3 frases: el espectador no sabe qué fila mirar | Resaltar la fila que se nombra (clase por estado sobre la fila 1 en t = 4,2 s, la fila 2 en 8,6 s y la fila 4 en 12,6 s, según los `captions[].t` de s4.b3) y atenuar las demás al 40 % | slides-revealjs |
| M9 | Media | S2, chip de migración (PDF p3): `same country, one decade to the next: … migration 0.69` | Solo aparece la correlación más alta (2000s → 2010s); la más baja es 0,32 (`r_cnmr_decades_min`, verificada). Mostrar solo el máximo debilita "a short memory" y es selectivo (ASA C.2) | `migration 0.32–0.69 (0.69 most recent)` | slides-revealjs |
| M10 | Media | Proceso: `slides/dev/screenshots/steps/*.png` | Las capturas se toman a 1,7 s de cada paso, así que los MP4 aparecen a medio animar: fig07 sin barras en s3.b2 y con una sola en s3.b3, fig01 en "1980s", fig04 aún en año calendario. No sirven para certificar el **estado final** de los builds con vídeo | `screenshots.py`: esperar `duration` de `video_timings.json` (o llevar el `<video>` al final con `currentTime = duration`) antes de cada captura; además, revisar 10 fotogramas del MP4 grabado (plan §7.11) | slides-revealjs · video-record |
| B1 | Baja | S2 chip: `births & deaths ≥ 0.95` | El mínimo es 0,948 (esperanza de vida; QA_stats §3.3): "≥ 0.95" es falso por 0,002 | `births & deaths ≥ 0.94` | slides-revealjs |
| B2 | Baja | S2 rótulo `Question 1 · P7 · P1` (l. 218) | La S2 no trata la estructura por edad (P1, que está en la S4) y su propio sello dice `P7 · P4` | `P7 · P1` → `P7 · P4` (y lo mismo en el storyboard §0/§3) | slides-revealjs |
| B3 | Baja | fig06 (S2): `dot = the same country over time (richer view)` · `dashed = comparing countries, −1.05 (simple view)` | "richer/simple view" no le dice nada a un no estadístico | `dot = within the same country, over time` · `dashed = comparing countries' averages, −1.05` | figures-static / slides-revealjs |
| B4 | Baja | S3, cabecera de fig07 `(adjusted R², 161 countries ≥ 1` ⏎ `M, 2023)`; nota de gemelos `(±` ⏎ `0.05)` | Cortes de línea dentro de una unidad | `≥&nbsp;1&nbsp;M`, `±&nbsp;0.05` | slides-revealjs |
| B5 | Baja | S1 `ARE UAE 2023`; S3 `COL COLOMBIA`, `ARE UAE · BLR Belarus` | Código ISO + nombre repetidos | Bandera + nombre (sin ISO3) cuando el nombre ya está | slides-revealjs |
| B6 | Baja | S4, columna FOR (MANDATE) | Siglas sin glosa: ICPD, GCM, MIPAA, UNSD, SDG | Nota de 18 px bajo la tabla (o en las referencias): `SDG = UN Sustainable Development Goal target · ICPD = Cairo Programme of Action (1994) · GCM = Global Compact for Migration` | slides-revealjs |
| B7 | Baja | S4: `96 % of countries keep their group in at least 4 of 5 re-runs` junto a "500 random re-runs" | Parece que hubo 5 re-runs | `… in at least 80 % of 500 re-runs` | slides-revealjs |
| B8 | Baja | S4: `life expectancy at 65: SD 1.47 → 2.85 years · estimates 1950–2023` | Cifra sin glosa ni mensaje (además va en sentido contrario a la esperanza de vida al nacer) | `but at 65 countries drifted apart: years left to live at 65, SD 1.47 → 2.85` | slides-revealjs |
| B9 | Baja | Voz s4.b1: `Early movers now grow mainly through migration, or shrink.` | "now" (2000–2023) se apoya en `growth_2000_2023_by_group`, que está en `verified: false`; 2024–2050 sí está verificada | QA-stats verifica `growth_2000_2023_by_group`, o la voz pasa a `Early movers are projected to grow only through migration, or shrink.` | QA-stats / script-narration |
| B10 | Baja | fig09: `vs ageing ↓` | Rótulo críptico | `lower = older populations` | figures-static |
| B11 | Baja | S3: `TWINS BY RULE · SAME FERTILITY, OPPOSITE` ⏎ `GROWTH` | La última palabra queda sola en otra línea | `SAME FERTILITY, OPPOSITE GROWTH · by rule` | slides-revealjs |
| B12 | Baja | Referencias: `ASA (2022) … https://doi.org/10.5281/zenodo.7092386` | DOI no comprobado por una persona (`04_etica` #22 d) | Abrir el enlace y confirmarlo antes de enviar | equipo |
| B13 | Baja | s4.b5 (*callback*) | El subtítulo repite literalmente la frase de 70 px que ya está en pantalla | Opcional: ocultar la barra en s4.b5 (o dejarla por accesibilidad) | slides-revealjs |

---

## 4. Comprobaciones pedidas

| Comprobación | Resultado |
|---|---|
| **Duración ≤ 300 s** | 294,1 s (modelo 150 ppm + 1,5 s por cifra + 0,6 s por transición). ✔ con margen de 5,9 s; **riesgo H3** |
| **Por sección** | Portada 28,7 s · S1 79,0 · S2 55,8 · S3 56,1 · S4 71,5 · Referencias 3,0. Razonable: Q1 (P7) ocupa 135 s en dos diapositivas, Q2 (P8) 56 s y Q3 72 s. El gancho plantea la paradoja antes de 11,6 s ✔ |
| **Pasos con MP4 cubren su vídeo** | s1.b2 12,9 ≥ 12,6 · s1.b5a 4,3 ≥ 4,0 · s2.b1 18,8 ≥ **16,4** · s3.b1 16,0 ≥ 14,9 · s3.b3 8,6 ≥ 7,7 · s4.b1 27,3 ≥ **26,4** ✔ |
| **Subtítulos** | 70 bloques, todos ≤ 90 caracteres y en una línea; máximo 18,9 caracteres/s (s1.b2). 4 bloques < 1,5 s ("Three questions.", "Question two.", "Question three.", "but misses migration." 1,2 s): aceptables por ser cortos ✔ |
| **"Question N, answered"** | S2 (Q1, P7 · P4), S3 (Q2, P8 · P5: **"No."**), S4 (Q3, P6 · P1): se oye y se lee ✔. S1 lleva `Question 1 · Part 1` ✔ |
| **P7 y P8 inconfundibles** | ✔ Q1 cita P7 casi al pie de la letra ("…differ by region, country and income?") y la respuesta habla de ingreso (1970/1984/2000; 7 de cada 10 en ingreso alto) y de región (Golfo; África subsahariana −1,20; Europa y Norteamérica invertida +0,39). Q2 = P8 literal, con respuesta "No." |
| **Glosa de cada término técnico** | ✔ en el vídeo: replacement, net migration, UN medium projection, 95 % range, median age, child mortality, high-fertility, own clock, band, within the same country, placebo ("shuffled data"), R², r, look-alike, axis, transition, composite index, k-means, re-runs, hatched, SD, spectrum. ✘ en el PDF: "replacement" (M4). Pendientes: "richer/simple view" (B3), siglas de mandatos (B6), LE65 (B8) |
| **≥ 18 px en el estado final; ≥ 28 px en titulares** | HTML: mínimo 18 px en los 38 estados ✔; títulos 46 px ✔, portada 104 px ✔. Recuadros de respuesta 23 px (21 px en PDF S4) y titulares de gráfica 21–24 px: **por debajo de 28 px** (desviación documentada en `slides/README.md` §7; ver M5). Dentro de figuras: ≈ 17–18 px (M6) |
| **Nada se solapa** | DOM: 0 solapes reales en 38 estados. Figuras: sin choques; justos pero legibles en fig07 (rótulo y barra a ≈ 9 px de distancia), fig11 (marca "50" pegada a la banda de LE) y fig09 (tres rótulos apilados junto a las flechas) |
| **Cifras pantalla = voz = `numbers.json`** | 18 cifras habladas, todas con su `say`/valor verificado y todas iguales en pantalla (130/84/66/18; seven in ten ≈ 71 %; 22; nine–thirty-three ≈ 8.9–33.3 M; 5 y 33 años; 106 de 109; at least 22; three quarters ≈ 0.77; 60 % ≈ 0.59; one in eight ≈ 13 %; one in five; almost four ≈ +3.70 %; 32 años). Texto HTML del PDF: todas las cifras casan con claves verificadas. Excepciones dentro de figuras: H2. Única tensión semántica: 66 ↔ 22 (H1) |
| **PDF autosuficiente** | Casi: cada página tiene pregunta, titulares-mensaje, glosas, pie de estimación/proyección y respuesta. Lo que hoy depende de la voz: la definición de los 22 (H1), los denominadores de la tabla y el "28 %" (M3), "replacement" (M4) y la lectura relativa del 6× → 20× (M2) |
| **Portada + 4 + referencias** | ✔ 6 páginas; portada con título, afiliación exacta, miembros, línea de cifras y las tres preguntas con códigos P |

### Cambios obligatorios ya decididos

| Cambio | Estado |
|---|---|
| "106 of 109" (97 %); "typically at least 22 years" | ✔ pantalla (S2) y voz (s2.b2) |
| −0,41 "smaller than what comparing countries suggests", sin afirmar que excluye 0; sin intervalo para 2,5; Europa y N. América "reversed (+0.39)" | ✔ (el 2,5 no aparece en ningún sitio; el bosque muestra el intervalo que cruza 0) |
| s4.b1: "…age from 30 to 40 in about 32 years. About as fast as Early movers did, or faster."; Early movers = 37 | ✔ voz y pantalla (`Fast movers 32 years · Early movers 37 years`) |
| `n_census_pre2009`, `repo`, `are_revision_pct` sin cifra | ✔ (s1.b0: "Some countries and areas have had no census since before 2009" sin número; repositorio sin URL; Golfo sin "+12 %"). Pero ver H4 |
| Portada: afiliación exacta, sin logos, atribución CC BY 3.0 IGO | ✔ |
| Ranuras fig04 1760×416 → `_small` 774×183; fig10 1792×571 → `_small` 1021×220; MP4 16,4/26,4 s cubiertos; capas de fig00 y fig02; fig02b + tarjeta EAU con fig03; "axis 2 = 18 %" | ✔ (`figure_slots.json`, `deck_report.json` sin faltantes, PDF p4) |
| `fill_numbers.py` con ROUND_HALF_UP (`Decimal.quantize`) | ✔ (l. 36 y 91) |

---

## 5. Prueba del familiar no estadístico (7 preguntas, v1 §7.10)

Lectura simulada sin contexto, primero en el vídeo (builds + subtítulos) y después solo con el PDF.

| Pregunta | Portada | S1 | S2 | S3 | S4 |
|---|---|---|---|---|---|
| 1. ¿Dice en una frase qué responde tras 20 s? | Sí: "130 países con pocos hijos y 84 siguen creciendo; un número no lo explica" | Sí: "qué palanca mueve cada país; en los ricos, la migración" | Sí (el título ya es la respuesta) | Sí: "¿basta un indicador? No" | A medias: el título sí; el mapa + 3 paneles + tabla no se abarcan en 20 s (M8) |
| 2. ¿Entiende replacement, net migration, R², principal component, cluster solo con la pantalla? | Vídeo sí; PDF no ("replacement", M4) | net migration sí (ecuación + glosa EAU) | "own clock" sí; "within the same country" sí, salvo "richer view" (B3) | R² sí; "axis = one summary of all 12 indicators" sustituye a "principal component" ✔; look-alike sí | k-means/grupos sí; "spectrum, not boxes" sí |
| 3. ¿Distingue estimación de proyección? | Sí (subtítulo "UN estimates 1950–2023, projections to 2100") | Sí (pie + leyenda del abanico de EAU) | Sí ("estimates 1950–2023") | Sí ("UN medium projection: partly built in") | Sí (gris discontinuo después de 2023; "UN medium projection after 2023") |
| 4. ¿Identifica la respuesta a Question N? | Las 3 preguntas visibles | "Question 1 · Part 1" | **Question 1 answered** | **Question 2 answered: No.** | **Question 3 answered** |
| 5. ¿Algún color o rótulo confunde? | No | IND·BRA·MEX en la fila de 165 (M7); 22 frente a 66 (H1) | "richer/simple view" | Celeste = "Population change to 2050" en fig07, cuando en la S1 el celeste es migración (leve); "ARE UAE" | "mostly … (13 of 13)"; "(28 %)" en el PDF (M3) |
| 6. ¿El subtítulo cabe y se lee al 50 %? | Sí (34 px → 17 px, una línea) | Sí | Sí | Sí | Sí |
| 7. ¿La tabla de recomendaciones se entiende sin voz? | — | — | — | — | Casi: columnas claras (dónde, camino, qué vigilar, quién, cuándo); fallan los denominadores, el "28 %" y las siglas (M3, B6) |

Términos del plan §7.10 v2: **"look-alike"** ✔ (definido en la propia tarjeta), **"own clock"** ✔ ("Same road, different clock: lining countries up on the year fertility fell below 4"), **"within the same country"** ✔ (titular de fig06), **"continuum"** → "a spectrum, not boxes" ✔.

---

## 6. Comparación con los ganadores y el rival fuerte

**¿Superamos a TRITICS (2025) en claridad?** **Sí en el vídeo y en el PDF, con una condición.**
- A favor: cada diapositiva pregunta y responde en pantalla ("Question N answered"); ellos plantean dos preguntas pero la respuesta queda en la voz. Todo término técnico tiene "= …". Los colores tienen significado fijo (azul nacimientos, naranja muertes, celeste migración). Los builds descubren una idea cada vez, con subtítulos. Y nuestro PDF se lee solo, cosa que su formato cinematográfico no buscaba.
- En contra: TRITICS gana en **"una idea por pantalla"** (tipografía enorme, presentador, pocas cifras). Nuestro estado final de la S4 (mapa + 8 minigráficas + 3 paneles + tabla + ética + respuesta) y la página 4 del PDF tienen 3–4 veces más texto. **Condición**: aplicar M5, M6 y M8. Sin eso, el jurado de visualización puede preferir su sencillez.

**¿Superamos a `ahzasasa` (2026) en rigor visible?** **Sí en amplitud; empate en profundidad de robustez de los grupos; hoy perdemos en trazabilidad pública.**
- A favor: la incertidumbre se ve en **las cuatro** diapositivas, no solo en una figura: bandas 80/95 % de la ONU (EAU), IC por bloques de subregión, diamantes fuera de muestra, banda placebo, análisis paralelo frente a ruido, 2 000 diseños de índice, 500 re-runs con rayado de países inestables, rangos de sensibilidad (64–78 %, 15–25, 46–77 %), censura explicada (26 y 45 países fuera, 92 de 109 ya bajando en 1950) y "association, not cause". Además, el contraste dentro/entre países (−0,41 frente a −1,05, invertido en Europa) y P4/P7 con ingreso y migración, que ellos no tratan.
- Empate: su figura de estabilidad (país a país + rejilla de 16 ajustes × 6 métodos) es más contundente a la vista que nuestras dos frases ("96 % keep their group", "re-checked with whole-curve methods").
- En contra hoy: ellos tienen el repositorio público y un *ledger* donde cada cifra es trazable. Nuestros H2 (cifras de figura sin verificar) y H4 (repositorio sin URL) son justo las dos cosas que el jurado de ética puede comprobar. **Corregidos H2 y H4, los superamos también aquí.**

**Regla `01b` §6.4.** (a) ¿Se puede confundir alguna figura nuestra con una suya al 50 %? No. Nuestro mapa de grupos (fig10: índigo/verde/arena/celeste, 4 grupos con "Migration-led", minigráficas) se distingue de su mapa A/B/C naranja/verde/azul. Nuestra fig04 (registro en el cruce de TFR = 4) no es su corredor TFR × LEx. (b) Tres cosas que ninguno de ellos puede decir: **"84 below replacement still grow; 18 only because more arrive than leave"** con 71 % del crecimiento de ingreso alto debido a la migración; **"within the same country the link is smaller, and reversed in Europe & N. America"**; **"fertility alone finds 13 % of a country's look-alikes; UAE and Belarus share fertility but not growth"**, más la tabla de la ONU con mandatos y horizontes.

---

## 7. Orden de trabajo sugerido (antes de grabar)

1. **QA-stats**: H2 (lote 5) y B9 → `R/05` → `numbers.json`.
2. **slides-revealjs**: H1, M1–M5, M7–M9, B1–B7, B11 → `export_pdf.sh --png` → `screenshots.py` (con el arreglo de M10).
3. **script-narration**: H1, M1 y, si hace falta, los recortes de H3 → `build_narration.py` → nuevo `data-caption` y `video_timings.json` → `check_sync.py`.
4. **figures-static**: M6, B3, B10 (y H2 si no se verifica).
5. **repo-ops**: H4 (repositorio público y `repo`).
6. Lectura cronometrada (H3) y una nueva pasada de QA-slides sobre el PDF y 10 fotogramas del MP4.
