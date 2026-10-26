# QA-viz — Revisión de visualización (jurado *Best Data Visualization*)

Agente **QA-viz** · 2026-10-25 · deck `slides/index.html` (32 estados) + `slides/export/slides.pdf` (6 páginas)
+ figuras `figures/static/*.png` y `figures/animated/*.mp4` (fig00–fig11).
No se ha editado `index.html` ni ninguna figura; este documento solo informa. Las correcciones van
a los agentes dueños de cada archivo (figuras: `R/fig_q*_slide*.R`; deck: `slides/`).

---

## 0. Veredicto en una línea

El deck ya está al nivel de los ganadores de 2025: una paleta con un solo significado, animaciones que
siguen a la voz y figuras sin deformar. **Aún no se puede grabar.** Tres figuras animadas o estáticas
muestran **cifras no verificadas**: hay una crítica (la revisión del Golfo en fig10) y tres altas
(fig10 75 %, fig11 311 → 64, fig09 "7 countries"). Además, tres figuras se ven al 93,5 % de su
tamaño de diseño, así que su texto baja de 18 px.
**Nota del deck: 7,4 / 10**. Si se corrigen V1–V9, la estimación sube a ≈ 8,8.

---

## 1. Método (qué se miró y con qué)

| Comprobación | Cómo | Evidencia (scratchpad, temporal) |
|---|---|---|
| Las 32 capturas de `slides/dev/screenshots/steps/` + 7 finales | Cada una vista con Read | — |
| Estado real tras terminar cada MP4 (`screenshots.py` solo espera 1,7 s y captura animaciones a medias) | Playwright: espera a que acabe el vídeo en s1.b2, s1.b5a, s2.b1, s3.b1, s3.b3 y s4.b1 | `…/scratchpad/qaviz_out/*_after_video.png` |
| Caja real de cada `<img>`/`<video>` (con `object-fit: contain`), escala frente al diseño (natural / 2) y deformación | `getBoundingClientRect` + `naturalWidth` en cada build y en `?print-pdf` | `…/scratchpad/qaviz_out/measure.json`, script `…/scratchpad/qaviz_measure.py` |
| Texto HTML visible con `font-size` < 18 px | `getComputedStyle` de cada nodo con texto, visible y con opacidad > 0,05, en los 32 estados y en el PDF | idem |
| 3 fotogramas por MP4 (inicio, mitad, final) + secuencia a 2 fps para la sincronía | ffmpeg del venv (`imageio_ffmpeg`) | `…/scratchpad/qaviz_frames/`, `…/scratchpad/qaviz_seq/sheet_*.png` |
| Narración por fragmento | `slides/script/video_timings.json` (= `captions.json`) | §4 |
| Paleta | Muestreo de píxeles de PNG + `css/theme.css` + ΔE76 CIELAB y contraste WCAG | §5 |
| Cifras impresas dentro de las figuras | Claves de `numbers.json` citadas por `R/fig_q*_slide*.R` contra `verified` | §2, V1–V4 |
| PDF | `pdftoppm -r 96` de las 6 páginas, vistas con Read | `…/scratchpad/qaviz_pdf/p-*.png` |

`…/scratchpad` = `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad`.

---

## 2. Hallazgos (de más a menos grave)

Severidad: **CRÍTICA** = no se puede grabar ni entregar así · **ALTA** = la ve el jurado y rompe una regla
del proyecto · **MEDIA** = resta puntos en *Best Data Visualization* · **BAJA** = pulido · **INFO** = confirmar.

| ID | Sev. | Dónde | Problema | Corrección exacta |
|---|---|---|---|---|
| **V1** | **CRÍTICA** | `fig10_trajectory_groups.mp4`, s4.b1, t ≈ 5,8–8,6 s (franja inferior del vídeo); lo genera `R/fig_q3_slide4.R` `textos_fig10()` l. 759–770 | En pantalla dice **"Gulf populations were revised in WPP2024 (UAE +12 %, Saudi Arabia −10 %)"**. `are_revision_pct` tiene `verified: false` (cifra EXTERNA) y `sau_revision_pct` no existe. Al no encontrar las claves, el script copia el texto del `sens_note` de `cluster_examples_migration`. QA_stats §7.1 y el encargo dicen que hay que omitirlo | Hay que quitar la rama `else` y el `sprintf` y poner `nota_golfo <- "Net migration is the least-measured component: read these paths as UN estimates"` (sin cifras). Después, volver a renderizar `fig10_trajectory_groups.mp4`, `.png`, `_small.png` y `_print.png`, y correr `slides/dev/screenshots.py` y `slides/dev/check_sync.py` |
| **V2** | **ALTA** | `fig10…mp4`, s4.b1, t ≈ 8,6–13,5 s | "**Early movers: net arrivals account for 75 % of their growth, 2000–23**". Sale de `growth_2000_2023_by_group` (`verified: false`). La voz de 8,6 s ("Early movers now grow mainly through migration, or shrink") se apoya en la misma clave | Opción A: QA-stats verifica la clave (son sumas: va a un lote nuevo de `docs/qa/verificacion_consolidada.csv`) y la marca `true`. Opción B: usar como titular la segunda línea, que ya está verificada (`growth_2024_2050_by_group`): **"Early movers, UN medium projection 2024–50: births − deaths −7.0 %, net arrivals +5.6 % of the population"**, y borrar la línea del 75 % |
| **V3** | **ALTA** | `fig11_divergence_fan.png` (s4.b2) y `fig11_divergence_fan_print.png` (s4.b3–b5 y PDF p. 5); `R/fig_q3_slide4.R` l. 1452 | "**gap: 311 → 64 deaths per 1,000 births**" sale de `q5_gap_p90p10_1950` y `_2023`, las dos con `verified: false`. Las razones 6× y 20× sí están verificadas | Opción A: verificar las dos claves. Opción B: dejar solo **"the ratio grew, but the gap in deaths shrank"**, sin cifras (ya figura en fig11), y quitar la línea con 311 → 64 de las dos versiones |
| **V4** | **ALTA** | `fig09_pca_two_dimensions` (MP4, PNG y `_print`): s3.b3–b4 y PDF p. 4; `R/fig_q2_slide3.R` l. 1078 | Pie "**net migration capped at ±3 SD for 7 countries (incl. UAE and Oman)**": `n_cnmr_winsorized_2023` tiene `verified: false` | Opción A: verificar la clave (es un conteo trivial). Opción B: escribir **"net migration capped at ±3 SD for a few countries (incl. UAE and Oman)"** |
| **V5** | **MEDIA** | s3.b3–b4 fig09 · s4.b3–b5 fig10_small y fig11_print · PDF p. 4 fig09_print · s3 fig07 | Las ranuras medidas no coinciden con las `RANURAS` de los scripts y `contain` reduce la figura. Escala medida: **fig09 583×379 = 0,935** (texto de 18 px → 16,8 px) · **fig10_small 1021×220 = 0,935** · **fig11_print en vídeo 741×150 = 0,935** · fig09_print 592×487 = 0,948 (17,1 px) · fig07 564×259 = 0,986 (17,7 px). En el caso de fig09, la nota HTML obligatoria "axis 2 = 18 %" añadió una tercera línea y la ranura bajó de 405 a 379 px | `R/fig_q2_slide3.R`: `fig07 = c(w = 572, h = 259)`, `fig07_print = c(w = 572, h = 367)`, `fig09 = c(w = 624, h = 379)`, `fig09_print = c(w = 624, h = 487)`. `R/fig_q3_slide4.R`: `fig10_small = c(w = 1021, h = 220)` y una figura nueva `fig11_small = c(w = 741, h = 150)` → `figures/static/fig11_divergence_fan_small.png`, que el agente de slides debe usar desde s4.b3 en lugar de `_print` (el PDF sigue con `_print` a 793×160). Alternativa para fig09: acortar la nota a 2 líneas ("axis 1 = 57 % of the variation (46–77 %) · axis 2 = 18 %") y así se recuperan 26 px |
| **V6** | **MEDIA** | `fig10_trajectory_groups_small.png`, s4.b3–b5 | En el mapa se ve el rayado (países inestables, en verde y morado; < 1 M, en gris: Groenlandia) pero **no tiene leyenda**. La leyenda solo está en el MP4, en el póster y en `_print` | En `_small`, debajo del mapa y en 18 px de diseño: `▨ changes group in > 1 in 5 re-runs · ▨ < 1 M people`. El pie "Map: Natural Earth · boundaries imply no UN endorsement" pasa a una segunda línea |
| **V7** | **MEDIA** | `fig03_uae_fan_2050.png` y `_print` (s1.b5b, PDF p. 2); `R/fig_q1_slide1.R` (`COL_DEF` como "escenario") | La línea "UN zero-migration scenario" va en **naranja #E69F00**, que es el color de "Shrinking: deaths > births" en la leyenda que tiene justo debajo. Eso choca con la regla del storyboard §8 ("colores con significado único"). Además fig01 dibuja *births − deaths* en azul | Usar gris oscuro punteado, de la familia de la proyección: `colour = "#4D4D4D", linetype = "13"`, con la leyenda **"UN zero-migration scenario (births − deaths only; a what-if, not a forecast)"**. Actualizar también el storyboard §2 b5 ("línea punteada naranja") |
| **V8** | **MEDIA** | Ecuación de S1 (s1.b1–b5b, PDF p. 2) y línea resumen de la portada en el PDF; `css/theme.css` l. 174–176 y 279 | La ecuación es la clave de colores de todo el vídeo, pero "births" (#0072B2) y "net migration" (`.k-mig` #1F86C2) apenas se distinguen: **ΔE76 = 8,6**. #56B4E9 frente a #0072B2 da 26,4 | Pasar los términos a "pastillas" con el mismo código de colores que los chips de la portada: `.k-births,.k-deaths,.k-mig{padding:0 10px;border-radius:6px}` · `.k-births{background:var(--c-births);color:#fff}` (contraste 5,2) · `.k-deaths{background:var(--c-deaths);color:var(--ink)}` (7,0) · `.k-mig{background:var(--c-migration);color:var(--ink)}` (6,8). Lo mismo en `.cover-summary .t-ab-txt/.t-c-txt` |
| **V9** | **MEDIA** | `fig02b_lever_map_zoom.mp4`, s1.b5a | (a) El **fotograma 0 lleva la capa de inercia** (MEX, BRA, IND y anillos). En s1.b4c lo que se veía era `_ex_e` (NPL, AZE, URY), así que al empezar s1.b5a esas etiquetas cambian durante 0,3–0,5 s. (b) En t ≈ 3,0 s aparecen **cajas de etiqueta semitransparentes** (rectángulos fantasma de BHR, QAT, SAU, OMN, IRN y "United Arab Emirates") mientras se funde la imagen | En `R/fig_q1_slide1.R`: arrancar el zoom desde `fig02_lever_map_2023` sin capas, y hacer aparecer las etiquetas del Golfo, con su caja, solo cuando el zoom termine (t ≥ 3,5 s), con alfa de 0 a 1 y sin caja durante el fundido |
| **V10** | **MEDIA-BAJA** | `fig10…mp4`, s4.b1 | Hay desfase. La voz dice "Fast movers, India, China and Indonesia," en **12,2 s**, pero el foco Fast y CHN, IND e IDN aparecen entre **13,0 y 13,5 s**, y la línea de Early movers sigue en pantalla hasta 13,5 s. Esto incumple la regla del §8 ("se resalta en el mismo instante"). Las demás fases van bien: Migration-led 5,5–6,0 s frente a la voz en 5,8 s; Early 9 s frente a 8,6 s; Recent 23 s frente a 24,5 s (se adelanta, es aceptable) | Adelantar en `R/fig_q3_slide4.R` el inicio de la fase b5 (Fast) a **12,0 s**; lo ideal es leerlo de `video_timings.json` (t del bloque − 0,2 s), como ya se hace con los demás hitos |
| **V11** | **MEDIA-BAJA** | fig03 (s1.b5b), fig07 (s3.b1–b4) | La convención "proyección = gris y punteado + línea 2023/24" no se aplica igual en todas las figuras. fig10 la cumple (es la referencia: mediana gris discontinua, banda gris y línea punteada en 2023). **fig03** dibuja la mediana proyectada en gris pero **continua** (#7A7A7A). **fig07** pinta la barra "Population change to 2050 (UN medium projection)" en **azul pálido #B3D5E8 (#0072B2 al 30 %) con borde azul discontinuo** | fig03: `linetype = "22"` en la mediana proyectada y muestra discontinua en la leyenda. fig07: mantener el relleno azul pálido (es parte de la "slow story") pero con borde **gris #9A9A9A discontinuo**, como las proyecciones de fig10 |
| **V12** | **BAJA** | Titulares HTML de fig01, fig02 y fig07 | El storyboard §8 pide "título = mensaje en frase". fig01 ("Where growth came from, by today's income group") y fig07 ("What fertility alone captures …") **describen**, no dicen el mensaje. **fig02 no tiene titular** (solo la pregunta de la diapositiva y la leyenda) | Cambios para el agente de slides, solo con claves verificadas. fig01: `Since 2000, today's high-income countries grew mostly through net migration ({share_mig_high_2000_2023.say}); the rest, through births`. fig02, encima del mapa: `2023: {n_type_AB} countries and areas grow from births, {n_type_C} only through arrivals; {n_type_D} shrink as deaths exceed births, {n_type_E} as more leave`. fig07: `Fertility alone captures the slow story (how old: {r2_tfr_medage}), not the fast one (growth {r2_tfr_growth}, migration ≈ 0)` |
| **V13** | **BAJA** | fig11 (s4.b2) junto a fig10 | La banda "middle 80 % of countries" de fig11 (#B9C6DE) y la banda de Early movers en fig10 (#CECAE3) están a **ΔE76 = 6,5** y aparecen lado a lado: la banda de los 161 países se puede leer como "Early movers" | Usar una tinta neutra **#D5DAE3** (ΔE 10,3 frente a Early y 6,2 frente al gris de proyección #E4E4E4) con la mediana en tinta #15233B |
| **V14** | **BAJA** | `fig01…mp4`, s1.b2 | Los segmentos de India y China con borde blanco se ven desde t = 0, pero su leyenda ("India", "China") no aparece hasta t ≈ 10 s y la voz no los nombra | Dibujar el borde blanco solo desde la fase "Elsewhere" (t ≈ 9,5 s), a la vez que la leyenda |
| **V15** | **BAJA** | fig06, s2.b3 | La fila resaltada es "Low income (25)" (así lo pide el storyboard), pero la voz habla del conjunto ("Within one country, this link is smaller than what comparing countries suggests"). Se señala algo que no se narra | Resaltar la fila "All countries (161)" (−0,41 frente a la línea discontinua −1,05). Si se mantiene Low income, la voz tiene que mencionarlo |
| **V16** | **BAJA** | fig09 en el vídeo (s3.b3–b4) | El titular HTML dice "Only 2 axes stand out from random noise", pero el recuadro que lo demuestra ("Axes vs random noise": 57 %, 18 %) solo está en `fig09_print`. En el vídeo esa afirmación no tiene apoyo visual. Además, las barras de ruido salen de `eigen_null_p95_12` (`verified: false`; no se imprime ningún número) | Añadir el recuadro al último segundo del MP4 (esquina superior izquierda, que está libre) después de que QA-stats verifique `eigen_null_p95_12` y `eigen_pca_12`. Otra opción es cambiar el titular del vídeo a "Countries differ in two separate ways · fertility ≈ axis 1 (r = −0.94) · blind to axis 2 (r = 0.03)" |
| **V17** | **BAJA** | Portada, cover.b2–b4 | Las líneas grandes ("130 of 237 countries and areas: fertility below replacement", "84 still growing") y el subtítulo gris de 20 px quedan encima del mapa de puntos, y en Europa y Oriente Medio los puntos se ven entre las letras | `.cover p.line, .cover p.sub { text-shadow: 0 0 4px #fff, 0 0 10px #fff, 0 0 18px #fff; }`, o un panel `background: rgba(255,255,255,.78)` detrás del bloque de texto |
| **V18** | **BAJA** | S3 titular de fig07, S4 titular de fig11, chip de migración de S2 | Hay cortes de línea feos: "≥ 1⏎M, 2023)", "SD: 12.2⏎→ 7.4 years", "migration⏎0.69", "least-⏎measured" | Espacio duro entre número y unidad o flecha: `1&nbsp;M`, `12.2&nbsp;→&nbsp;7.4`; `white-space: nowrap` en `.chipbox .cv .big` (y envolver "migration&nbsp;<span class=big>" en un `<span class="nowrap">`); `hyphens: manual` |
| **V19** | **BAJA** | Tarjeta fig08, s3.b2 | "the two summary axes **(right)**: 43 %" remite a fig09, que no aparece hasta s3.b3 | Quitar "(right)" o mostrar esa frase en s3.b3 |
| **V20** | **BAJA** | `fig04_same_road_registration_small.png`, s2.b2–b4 | La zona de trazado mide ≈ 100 px de alto. La mediana y la banda azul, que son la prueba de "removes 80 % of the gaps", apenas se leen, y CHN, COL y EGY se amontonan sobre las curvas | Aceptable para el vídeo: la versión grande se vio durante 18,8 s. Si se gana alto (ver V5), dar a fig04_small 774×215 |
| **V21** | **INFO** | `fig10…mp4`, t ≈ 23–26 s | "Nigeria: last census 2006" sale del `sens_note` de `cluster_examples_recent`. El valor de la clave está verificado; no consta que se verificara el texto del `sens_note` | QA-stats debe confirmar el año. Si no, escribir "Nigeria: no recent census — its numbers are UN estimates" |
| **V22** | **INFO** | `slides/dev/screenshots.py` | Captura cada estado a 1,7 s, cuando los MP4 todavía están a medias: s1.b2 se ve en "1980s", s3.b1 sin barras y s3.b4 con flechas a medio fundir. Las capturas no reflejan lo que verá el jurado | En los pasos con `<video>`, esperar a `video.ended` (o a la duración del MP4 + 0,3 s) antes de `screenshot`, como hace `…/scratchpad/qaviz_measure.py` |

---

## 3. Lo que sí cumple (verificado)

- **Ninguna figura se deforma.** Todas usan `object-fit: contain` (cover en fig00). La deformación medida está
  entre 0,98 y 1,07 solo en la caja de la ranura; el contenido conserva siempre su proporción.
- **Ranuras héroe y fundidos correctos.** fig04 llena 1760×416 en s2.b1 (escala 1,000) y en s2.b2 se funde
  a `_small` 774×183 (escala 1,000). fig10 llena 1792×571 en s4.b1 (escala 1,64 respecto al diseño;
  el texto es más grande), pasa a 1092×348 en s4.b2 (escala 1,000) y a `_small` desde s4.b3.
- **Cada paso dura más que su MP4:** s1.b2 12,9 ≥ 12,6 · s1.b5a 4,3 ≥ 4,0 · s2.b1 18,8 ≥ 16,4 ·
  s3.b1 16,0 ≥ 14,9 · s3.b3 8,6 ≥ 7,7 · s4.b1 27,3 ≥ 26,4 s. El vídeo dura 294,1 s, menos de 5:00.
- **Variantes en su sitio.** El PDF usa `_print` en fig00, 01, 02 (+ `_momentum_print`), 03, 04, 05, 06, 07, 09, 10 y 11,
  todas a escala 1,00 salvo fig07 (0,99) y fig09 (0,948). En el vídeo, `_small` para fig04 y fig10. Las capas
  `_momentum`, `_ex_c`, `_ex_d` y `_ex_e` entran y salen en s1.b3b, s1.b4a, s1.b4b y s1.b4c, alineadas al píxel
  con fig02. Las capas transparentes de fig00 se apilan en cover.b2–b3.
- **Texto HTML:** en los 32 estados y en el PDF **no hay ningún nodo visible por debajo de 18 px**.
- **Paleta de palancas (Okabe-Ito):** muestreada en PNG y CSS. Nacimientos #0072B2, migración #56B4E9,
  defunciones #E69F00 (texto #8A5A00 / #B87A00), emigración #CC79A7 (púrpura rojizo) y pequeños Estados #999999.
  La usan igual fig00 b3, fig01, fig02, fig05 (fertilidad azul y mortalidad naranja), fig09 (flecha de migración
  #56B4E9) y fig11 (mortalidad naranja). Las excepciones son V7, V8 y V11.
- **Grupos (Tol):** Early #332288, Fast #117733, Recent #DDCC77 y Migration-led #88CCEE, iguales en los chips
  HTML, el mapa, las bandas y la leyenda. Las líneas oscurecidas (#9E8A2A, #2F86B8) son solo para contraste.
- **Estimación frente a proyección:** la portada, la tarjeta de datos de s1.b0, el pie PIE-0 y la voz explican el
  gris. Hay línea punteada 2023/24 en fig03 y fig10. fig01, 04, 05, 06, 09 y 11 solo muestran estimaciones y
  lo dicen ("UN estimates 1950–2023", "no projection"). Las excepciones son V11.
- **Titular-mensaje HTML presente** en fig04, fig05, fig06, fig08, fig09, fig10 (franja de vecinos y
  "Three stretches…") y fig11. Faltan los de V12.
- **Cambios obligatorios presentes en pantalla:** "106 of 109 … 97 %" y "typically at least 22 years"
  (fig05) · "smaller than what comparing countries suggests" sin intervalo que excluya el 0, y "reversed in
  Europe & N. America (+0.39)" (fig06) · "axis 2 = 18 %" (nota de fig09) · Early movers "37 years" en
  fmt 0 · afiliación de `equipo.json` en la portada, sin logos · atribución CC BY 3.0 IGO en las referencias.

---

## 4. Sincronía voz ↔ animación (MP4)

Tiempos de la voz según `slides/script/video_timings.json`; fases medidas en fotogramas a 2 fps.

| MP4 (paso) | Voz (t, s) | Lo que señala la animación (t, s) | Veredicto |
|---|---|---|---|
| fig01 (s1.b2) | 0,0 "In today's high-income countries, net migration accounted for" · 3,8 "about seven in ten…" · 9,3 "Elsewhere…births" | 0–3,5 décadas · 4,0–9,5 foco High + "2000–2023" (resto en gris) · 10–11 resto en color + India/China · 12 final | ✔ (la voz nombra "high-income" unos 4 s antes del foco: aceptable porque el foco llega con la cifra). V14 |
| fig02 + capas (s1.b3–b4c) | "Blue", "including 22…", "Light blue…Germany, Spain and Belgium", "Orange…China, Russia and Japan", "Purple…Nepal, Azerbaijan and Uruguay" | Capa por fragmento, con etiquetas ISO3 y banderas en la leyenda en el mismo instante | ✔ |
| fig02b (s1.b5a) | 0,0 "Migration is also the least certain lever." | 0 destello de la capa de inercia · 0,5–2,5 zoom · 3,0 cajas fantasma · 3,5 Golfo con EAU resaltado | ✔ en tiempo · ✘ V9 |
| fig04 (s2.b1) | 0,0 "Set each country's clock…" · 5,4 "and the curves line up" · 7,4 "The road is shared…" · 10,6 "China … 5 years; Egypt took 33" | 0–3 calendario · 3 puntos en el cruce de 4 · 4–6 deslizamiento · 6 alineadas · 7 mediana · 10 CHN · 14 EGY · 16 COL (mediana, sin voz) | ✔ (la mejor animación del deck) |
| fig07 (s3.b1) | 1,4 "slow story" · 3,8 "three quarters…" · 9,7 "only 60 percent … almost none of migration" | 2 corchete "slow story" · 4–5 barra 0,77 · 6–7 barra 0,88 (sin voz) · 10–11 barra 0,59 · 13 0,00 | ✔ |
| fig09 (s3.b3) | 0,0 "two separate ways" · 3,0 "Fertility tracks the first…" · 7,4 "but misses migration" | 0,5 COL + look-alikes · 2,5–3,5 flechas · 4 rótulo "Axis 1 — the transition" · 6,5–7 "Axis 2 — migration" + Golfo | ✔ (lo visual se adelanta 0,5–1 s) |
| fig10 (s4.b1) | 1,4 "three stretches" · 5,8 "migration-led group" · 8,6 "Early movers…" · 12,2 "Fast movers, India, China and Indonesia," · 14,6 "30 to 40 in about 32 years" · 20,9 "About as fast as Early movers…" · 24,5 "Recent movers…" | 1,5 Early · 3 Fast y Recent · 6 Migration-led · 9 Early · **13,0–13,5 Fast** · 15 "Median age 30 → 40" · 19,5 Early + Fast · 23 Recent · 25,5 final | ✔ salvo **V10** (Fast llega 1 s tarde) · ✘ contenido V1 y V2 |

---

## 5. Paleta y contraste (cifras de apoyo)

| Par | Medida | Lectura |
|---|---|---|
| births #0072B2 frente a net migration en texto #1F86C2 | ΔE76 8,6 | casi iguales → V8 |
| #0072B2 frente a #56B4E9 | ΔE76 26,4 | se distinguen bien |
| banda fig11 #B9C6DE frente a banda Early en fig10 #CECAE3 | ΔE76 6,5 | se confunden → V13 |
| barra proyectada fig07 #B3D5E8 frente a #56B4E9 al 45 % (#B3DDF5) | ΔE76 4,2 | parece "migración pálida" → V11 |
| #88CCEE (Migration-led) frente a #56B4E9 (migración) | ΔE76 14,4 | distintos pero de la misma familia (bien: los dos significan migración) |
| tinta #15233B sobre #56B4E9 · sobre #E69F00 · blanco sobre #0072B2 | 6,8 · 7,0 · 5,2 : 1 | pastillas V8 legibles (AA) |
| #E69F00 sobre blanco | 2,25 : 1 | correcto usarlo solo en líneas y rellenos con texto oscurecido, como ya se hace |

---

## 6. Puntuaciones (1–10, criterio del jurado de visualización)

| Figura | Nota | Por qué (fortaleza · lo que resta) |
|---|---|---|
| fig00 portada (puntos + capas) | **8,0** | Apertura con datos y capas sincronizadas con la voz · texto sobre puntos (V17); gris oscuro para "below replacement" |
| fig01 componentes por ingreso | **8,0** | Décadas animadas y foco High con la cifra dicha · titular descriptivo (V12); borde de India/China sin explicar al principio (V14) |
| fig02 mapa de palancas (+ capas) | **8,5** | 4 tipos y conteos que suman 237, ejemplos por regla y franja < 1 M · sin titular-mensaje (V12) |
| fig02b zoom al Golfo | **6,5** | Zoom útil · destello de capa (V9a), cajas fantasma (V9b) |
| fig03 abanico EAU | **7,0** | Rango del 95 % rotulado y escenario explicado · naranja del escenario (V7), mediana continua (V11) |
| fig04 mismo camino (héroe + small + print) | **8,5** | Héroe de 9: registro animado, la prueba en pantalla · small apretada (V20) |
| fig05 mortalidad primero | **9,0** | Una idea, dos colores con significado, anotación en el 0, n y bandas explicadas |
| fig06 dentro frente a entre | **8,0** | Comparación honesta simple frente a rica, placebo visible · fila resaltada sin voz (V15) |
| fig07 tarjeta de un indicador | **7,0** | Barras que se construyen al ritmo de la voz · titular no-mensaje (V12), proyección en azul (V11), escala 0,986 (V5) |
| fig08 look-alikes / gemelos (HTML) | **7,5** | Banderas e ISO3, ejemplo por regla · "(right)" prematuro (V19) |
| fig09 dos dimensiones | **6,5** | Ejes nombrados en llano, Golfo destacado · escala 0,935 (V5), cifra sin verificar (V4), afirmación sin apoyo en el vídeo (V16), etiquetas apretadas |
| fig10 grupos de trayectoria | **6,5** (≈ 9 tras V1, V2, V6 y V10) | La mejor composición del deck (mapa + múltiplos + proyección en gris) · cifras no verificadas (V1, V2), small sin leyenda y al 0,935 (V5, V6), Fast tarde (V10) |
| fig11 divergencia | **7,0** | Tres paneles con mensaje propio y la sutileza "ratio up, gap down" · cifra no verificada (V3), banda parecida a Early (V13), escala 0,935 en vídeo (V5) |
| **Deck en conjunto** | **7,4** | Sistema visual coherente, sincronía casi perfecta, PDF de 6 páginas legible · no se puede grabar mientras V1–V4 sigan abiertos |

---

## 7. Orden de trabajo recomendado

1. **QA-stats** decide sobre V2, V3, V4 y V21: verificar las claves o quitar las cifras. Sin espera, V1 se quita.
2. **Figuras Q3** (`R/fig_q3_slide4.R`): V1, V2, V3, V6, V10, V13, `fig10_small` 1021×220 y nueva `fig11_small` 741×150 (V5).
3. **Figuras Q2** (`R/fig_q2_slide3.R`): V4, V5 (fig07 572×259 / 367 y fig09 624×379 / 487), V11 (fig07), V16.
4. **Figuras Q1** (`R/fig_q1_slide1.R`): V7, V9, V11 (fig03), V14. `R/fig_q1_slide2.R`: V15 si se decide.
5. **Slides** (`index.html` y `theme.css`): V8, V12, V17, V18, V19 y el uso de `fig11_small` desde s4.b3. **Tooling**: V22.
6. Volver a correr `slides/dev/screenshots.py` (con V22), `slides/dev/check_sync.py` y `video/export_pdf.sh --png`.
   QA-viz revisa de nuevo s1.b5a, s3.b3, s4.b1 (t = 5–14 s), s4.b3 y las páginas 2, 4 y 5 del PDF.
