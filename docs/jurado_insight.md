# Jurado simulado · *Best Statistical Insight* (ASA International DataQuest 2026)

> Agente **jurado-insight** (IA, Claude Code) · 2026-10-26 · solo lectura del repositorio (único archivo escrito: este).
> Estado revisado: `HEAD` = `5ec1bd6` (posterior a `c367937` / `submission-2026-10-30-rc1`; árbol limpio antes de este archivo).
> Material leído: `slides/export/slides.pdf` (6 páginas, renderizadas a 150 ppp y miradas una a una), capturas finales del vídeo `slides/dev/screenshots/slide_{1..4}_final.png`, `slides/index.html`, `slides/script/narration_en.md` (v4, 292,2 s), `docs/resultados_q1.md`, `resultados_q2.md`, `resultados_q3.md`, `docs/QA_stats.md`, `docs/correcciones.md`, `figures/numbers.json` (385 claves; `def`, `sens_note`, `verified`), texto del notebook `notebook/analisis_wpp2024.html`, `docs/01_analisis_ganadores_2025.md` y `docs/01b_otros_equipos_2025_2026.md`. Comprobación automática: `fill_numbers.py --check-html slides/index.html` → 107 claves, 0 sin valor, 0 sin verificar.
> Criterio del premio (web oficial): *"Most compelling statistical insight"*. Lo leo como: conclusiones correctas, no triviales, útiles para la ONU y defendibles con el análisis; sin lenguaje causal; incertidumbre bien descrita; P7 y P8 contestadas del todo.

---

## 1. Veredicto

**Puntuación: 8,5 / 10** (nivel de ganador internacional, pero no está blindado). Con los tres imprescindibles de la §4 sube a ≈ 9.

Es la entrada estadísticamente más cuidada que he visto en este concurso: cada cifra sale de `numbers.json`, verificada por código independiente y revisada por las cuatro personas del equipo. El análisis corrige sus propias hipótesis cuando no se sostienen, como H2, H3, H4, H5, H7, H8 y H9. Lo que le impide llegar a 10:

1. **Densidad.** Hay unas 100 cifras en 4 diapositivas y 17 cifras habladas en 4:52. Un jurado puede no saber cuál es *el* hallazgo convincente. El hilo ("one number can't tell 8 billion stories") es bueno, pero la respuesta a P8 ("no") era previsible desde la propia pregunta.
2. **Varios titulares son de manual de demografía.** La mortalidad infantil cae antes que la fecundidad, la migración sostiene el crecimiento de los países ricos y la TFR predice la edad mediana. Lo valioso es **cómo** se cuantifican (censura, dentro frente a entre países, placebo, bloques), y eso está bien, pero el jurado lo tiene que notar.
3. **Tres descuidos corregibles** (§4). Una fila de la tabla mal rotulada. Un "80 % of the gaps" que en realidad es varianza. Una comparación de *look-alikes* que deja fuera el mejor número único posible.

## 2. Lo que convence (y por qué es *insight* y no solo descripción)

| Hallazgo | Por qué gana puntos | Evidencia en el repo |
|---|---|---|
| **130 bajo reemplazo, 84 aún crecen (66 por saldo natural + 18 solo por llegadas)** | Gancho contraintuitivo que obliga a mirar los tres componentes. Es robusto a la definición: TFR < 2,0 / 2,2 / NRR < 1 dan 65–66 % que crecen | `resultados_q1.md` §1 |
| **Dentro del mismo país la asociación mortalidad infantil → fecundidad es 2,5 veces menor que entre países (−0,41 vs −1,05), y se invierte en Europa y Norteamérica (+0,39)** | Es el *insight* estadístico más fino del deck: falacia ecológica cuantificada, con placebo (banda [−0,25; 0,26]) y un IC por bloques que se enseña aunque cruce el 0 | `resultados_q1.md` §7; Slide 2 (fig06) |
| **Mortalidad primero en 106 de 109 países, rezago "al menos 22 años" como cota de la mediana** | Trata bien la censura por la izquierda (Q5 ya caía en 1950 en 92 de 109): no inventa un rezago, da una cota. Además desmonta la cifra de "19 años" del rival más fuerte | `resultados_q1.md` §5; `numbers.json` → `lag_onset_lower_bound.def` |
| **P8 triangulada con cuatro métodos**: R² de la TFR sola (0,77 / 0,59 / 0,00), *look-alikes* (13 % vs azar 3 %), PCA con análisis paralelo (2 ejes sobre el ruido) y Monte Carlo de 2 000 índices ("weights, not formulas, decide") | Ningún competidor responde P8 con este nivel de evidencia. Incluye la diferencia "solo fórmulas 2,5 % vs pesos 17–47 %" | `resultados_q2.md` §2, §5–§7 |
| **Convergencia que depende del indicador**: la esperanza de vida converge (DE 12,2 → 7,4), la edad diverge (4,7 → 9,7), LE65 diverge (1,47 → 2,85) y la desigualdad relativa de la mortalidad infantil sube (6× → 20×) mientras la absoluta baja | Es la mejor respuesta a P1 que he visto: relativo frente a absoluto, al nacer frente a la vejez, con IC por bloques que no cruzan 0 | `resultados_q3.md` §6 |
| **Tabla "Countries where… / Watch / For (mandate) / When"** con agencia, ODS y horizonte | Responde al "¿y qué?" para la ONU, que es lo que les faltó a QuantaQuartet (2025) y a `ahzasasa` (2026) | Slide 4 |
| **Incertidumbre de la ONU visible y bien descrita**: EAU 2050 15,4 M, IP 95 % 8,9–33,3 M; en 77 de 161 países el IP 95 % de 2050 incluye crecer y decrecer | Usa OtherVariants (P2/P3) sin mezclar escenario con estimación ("UN zero-migration scenario (a what-if, not a forecast)") | Slide 1 |

**Lenguaje causal.** No encontré lenguaje causal residual en pantalla ni en la voz. "Lever = a component of the population balance, not a policy switch", "association, not cause", "A sequence in time, not proof of cause", "make it shrink" y "keep it growing" están usados como contabilidad. Está bien.

**Intervalos.** Están bien descritos en general: IP de la ONU ("the UN's band of likely values"), bootstrap por bloques ("95 % range (re-runs by UN sub-region)") y bandas descriptivas ("middle 80 %", "middle half"). El de dentro del país (−0,41 [−0,77; 0,05]) se muestra completo y la voz no dice que "excluye el cero". Solo hay un detalle de vocabulario: en la Slide 3 el mismo tipo de intervalo se llama "plausible range" (ver mejoras).

## 3. Cobertura de las preguntas de la sección 6

| P | Dónde | Estado | Comentario de jurado |
|---|---|---|---|
| **P7** (obligatoria) fecundidad–mortalidad–migración por región, país e ingreso | Slides 1–2 | **Contestada, con una pata más débil** | La relación fecundidad–mortalidad está completa: orden, calendario por ingreso 1970/1984/2000, dentro y entre países, por ingreso y por región (SSA −1,20; Europa +0,39). La de la **migración con los otros dos componentes** se apoya en pruebas indirectas: memoria entre décadas, vecindario (Moran), R² 0,00 de la TFR (Slide 3) y PCA. Las dos pruebas directas del notebook no salen porque no están verificadas: no hay compensación dentro del país (`mig_hi_within_slope` +0,01 [−0,20; 0,17]) y la paradoja tipo Simpson Q5–migración (`rho_q5_cnmr_world` −0,45 → ≈ 0 dentro de cada ingreso). "Migration moves on its own" es vago como respuesta. El recuadro "Question 1 answered" no menciona la región |
| **P8** (obligatoria) ¿un indicador basta? | Slide 3 | **Contestada**; en el PDF falta la segunda mitad | La voz cierra bien: "The story emerges only when transition and migration are read together". El recuadro "Question 2 answered" del PDF solo dice "No" y por qué no basta la fecundidad; no dice qué aparece al juntarlos (43 % con dos ejes). La comparación central no incluye el mejor número único (imprescindible 3) |
| P1 convergencia | Slide 4 | Muy bien | El mejor bloque del deck para *insight* |
| P4 migración | Slide 1 | Muy bien | 71 % en ingreso alto (rango 64–78 %), el tipo "crece solo por llegadas" (18; 15–25 según el año) |
| P5 índice compuesto | Slide 3 | Bien | "Transition-stage index, not a ranking": correcto y ético |
| P6 trayectorias | Slides 2 y 4 | Bien, con matices | Hay registro por hitos y k-means validado (FPCA ARI 0,96; Jaccard ≥ 0,78; 96 % estables). Pero k = 4 se fijó a priori y los datos prefieren 2–3 (silueta k = 2 0,44; gap → 3), y esto no se dice en pantalla |
| P2/P3 (opcionales, OtherVariants) | Slide 1 y Slide 4 | Bien | El fan de los EAU, los 77 de 161 y China 2050 en el notebook |

## 4. Imprescindibles (errores o comparaciones injustas en pantalla)

Los tres son **solo texto**, se arreglan en menos de 2 horas y después se vuelve a exportar el PDF (`video/export_pdf.sh`) y a grabar el vídeo mudo. Ninguno toca la voz, así que el tiempo (P-03) no cambia.

### I-1 · Fila 5 de la tabla de la Slide 4 mal rotulada
- **Dónde:** `slides/index.html` l. 415 (Slide 4, tabla *Countries where…*, fila 5); `docs/00_storyboard_diapositivas.md` l. 198; PDF p. 5.
- **Problema:** "more people leave than arrive: Nepal, Azerbaijan and Uruguay" describe a **todos** los países con migración neta negativa. Eso incluye a los de tipo B que crecen, como India y Pakistán. Pero la columna *Road* ("mostly Fast movers (4 of 6)") y los ejemplos son solo del **tipo E**: 19 países que **decrecen aunque nacen más de los que mueren**. Además contradice `rec_rows` fila 5 de `numbers.json` ("emigration outweighs births — shrinking although births exceed deaths") y `docs/QA_notebook_ejecucion.md` punto 23, que da la fila por corregida.
- **Corrección (en pantalla, inglés):** cambiar `more people leave than arrive: ` por `shrinking as more leave than arrive (births &gt; deaths): `. Debe leerse: *"shrinking as more leave than arrive (births > deaths): Nepal, Azerbaijan and Uruguay … · and everywhere: censuses and civil registration"*. Hay que hacer el mismo cambio en el storyboard, comprobar que la celda sigue en 2 líneas y volver a exportar. No cambia ninguna cifra, así que no hace falta otra verificación humana.

### I-2 · "removes 80 % of the gaps" es una reducción de varianza, no de brechas
- **Dónde:** `slides/index.html` l. 226 (Slide 2, titular de fig04); PDF p. 3; la misma frase del storyboard (Slide 2, b1).
- **Problema:** `pct_var_fase` es la reducción de la **varianza** media entre países: 0,920 → 0,186, en 57 países con ±20 años de datos (`def` y `sens_note`). La brecha típica (DE) baja un ≈ 55 % (√(0,186/0,920) = 0,45). Decir "80 % of the gaps" exagera la superposición. Es el tipo de confusión varianza/DE que un jurado estadístico detecta.
- **Corrección (en pantalla, inglés):** cambiar *"…removes 80 % of the gaps between them"* por ***"…removes 80 % of the variation between them"***. La cifra no cambia.

### I-3 · *Look-alikes*: falta el mejor número único (PC1 = 20 %)
- **Dónde:** `slides/index.html` l. 308 (Slide 3, línea `metric` de los *look-alikes*); PDF p. 4.
- **Problema:** la comparación central de P8 enfrenta **un indicador crudo** (TFR, 13 %) con **dos ejes optimizados sobre los mismos 12 indicadores que definen los *look-alikes*** (43 %). Así mezcla "uno frente a varios" con "crudo frente a optimizado en la muestra". Un jurado puede decir que la prueba está inclinada hacia "varios". La comparación justa para "un solo indicador" es el **mejor resumen único posible**, el eje 1: **20 %** [17; 24] (`knn_pc1`, `verified: true`). Ese dato hace la respuesta "No" mucho más fuerte: ni el mejor número único posible encuentra más de 1 de cada 5.
- **Corrección (en pantalla, inglés):** sustituir `· the two summary axes: <span class="big" data-num="knn_pc12">—</span> %` por `· the best single summary (axis 1): <span data-num="knn_pc1">—</span> % · both axes: <span class="big" data-num="knn_pc12">—</span> %`. Debe leerse: *"Fertility alone finds 13 % of them · the best single summary (axis 1): 20 % · both axes: 43 % · picking at random: 3 %"*. Es una cifra nueva en pantalla, así que hay que añadir su fila a `docs/verificacion_numeros.csv` y que los cuatro integrantes la comprueben a mano (regla de P-01, `QA_stats.md` §10). Después, revisar el corte de línea con QA-viz y volver a exportar.

## 5. Mejoras (deseables, por prioridad)

1. **Recuadro P8 completo** (l. 343). La segunda mitad de P8 tiene que estar en el PDF. Propuesta: *"No. Fertility alone tells how old a population is (0.77), part of today's growth (0.59) and almost nothing of migration (0.00). Read together, transition and migration find 43 % of each country's look-alikes; fertility alone, 13 %."* Todas las cifras ya están en pantalla y verificadas. Esto también arregla la frase actual "almost nothing about migration — it finds 13 %…", que mezcla dos ideas.
2. **Recuadro P7 con región** (l. 276). Propuesta: *"Child deaths fell first, fertility followed — at each country's pace, latest in low-income countries; within countries the link is clearest in sub-Saharan Africa and reversed in Europe & N. America. Migration moves on its own and accounts for ≈ seven in ten of high-income growth since 2000."* Todas las cifras están verificadas.
3. **La pata migratoria de P7.** Pasar por un lote de verificación independiente `mig_hi_within_slope` (no hay "compensación" dentro del país: +0,01) y `rho_q5_cnmr_world` / `_within_*` (−0,45 en el mundo → ≈ 0 dentro de cada ingreso). Después, mostrarlas en una línea de la Slide 2. Es el *insight* P7 más original que tiene el notebook y hoy no sale.
4. **El eje 2 depende del Golfo.** En la Slide 3 (l. 328 o pie del PCA) añadir *"axis 2 = 18 % (13 % without the six Gulf states)"* (`pc2_var_no_gulf` ✔). Sin el Golfo el análisis paralelo da 3 dimensiones y la carga mayor del eje 2 es la razón de sexos (0,56), no la CNMR (0,45). La conclusión de P8 sobrevive (R² de la migración 0,00 también sin el Golfo), pero conviene decirlo.
5. **"blind to axis 2 (r = 0.03)" se cumple en parte por construcción.** Con r(TFR, eje 1) = −0,94, por ortogonalidad |r(TFR, eje 2)| ≤ 0,33. La prueba directa de que la fecundidad no ve la migración es el R² de 0,00 del *scorecard*. Propuesta: *"fertility ≈ axis 1 (r = −0.94); migration sits on axis 2"*.
6. **El 0,88 del cambio a 2050 está dentro del corchete "slow story"** y es una salida de la proyección construida con la fecundidad (está rotulado *partly built in*). Lo más defendible es añadir el análogo observado: *"in the past, fertility explained at most half of the next 27 years' change"* (`r2_tfr_chg27_observed` ✔, máximo 0,50, mediana 0,40). Otra opción es sacar esa barra del corchete.
7. **Envejecimiento 30 → 40.** La voz s4.b1 dice "about 32 years. About as fast as Early movers did, or faster". Pero 48 de 51 Fast movers llegan a 40 solo en la proyección, y 12 de 40 Early movers también. Los IC se solapan ([27; 37] vs [29; 42,5]) y China, nombrada en la misma frase, tardó 23. Propuesta de pantalla (l. 384): *"Fast movers 32 years · Early movers 37 years (both mostly or partly UN medium projection)"*. Propuesta de voz con la misma duración: *"About as fast as Early movers; both partly projected."* Ojo: s4.b1 mueve la animación de fig10 (P-03).
8. **Inercia "34–38 more years … for most of their 2.2 bn people".** El rango está ponderado por población y lo domina India (38 años, 65 % del peso). Brasil son 19 años y la mediana simple de los 22 países, 25 (`momentum_years_range.sens_note`). Propuesta: *"…for most of their 2.2 bn people (mostly India)"*, sin cifras nuevas.
9. **"One road" con su prueba.** Mostrar *"groups line up along one axis (R² 0.90)"* (`r2_groups_axis1` ✔) y decir *"k = 4 fixed in advance; the data alone favour three stretches"*. Así se anticipa la pregunta "¿por qué 4?" (silueta k = 2 0,44 > k = 4 0,37; gap → 3, `gap_k` sin verificar: no teclear la cifra).
10. **El 80 % del registro por hitos es en parte por diseño.** Todas las curvas pasan por 4 en τ = 0 y el comparador es una sola ventana de calendario. En el notebook, añadir un punto de referencia (reloj barajado o curvas con pendientes aleatorias) y citar la descomposición formal de Kneip–Ramsay (fase = 0,56, `r2_fase_kr`, hoy sin verificar).
11. **"Migration is also the least certain lever"** (voz s1.b5a) no tiene cifra al lado. Se puede respaldar en pantalla con *"for 155 of 161 countries the UN 80 % range for 2050 net migration includes zero"* (`n_cnmr_sign_uncertain_2050` ✔).
12. **Vocabulario uniforme de intervalos:** "95 % range (re-runs by UN sub-region)" en todas partes, en vez de "plausible range" en la Slide 3. En la caja de migración de la Slide 2, *"0 = no link, 1 = identical"* no es correcto para r ni para el I de Moran: mejor *"1 = move in lockstep"*. *"births & deaths ≥ 0.948"* son TFR y esperanza de vida: mejor *"fertility & life expectancy ≥ 0.95"* (además unifica la precisión).
13. **Sensibilidad del rezago a los umbrales.** La hipótesis H3 se rechazó: con umbrales fijos el rezago va de −11,5 a +39,5 años. Una línea *"the order is robust; the size of the gap depends on where you draw the line"* neutraliza la cifra de 19 años de `ahzasasa` (requiere verificar la rejilla si se dan números).
14. **"What we did not find"** en una línea de Referencias. H2 (Europa no lleva 30 años de decrecimiento natural: volvió a tener más nacimientos que defunciones en 2008–2014), H5 (el −0,36 lo generaban los microestados) y H4 (el β ≈ −1 era ruido). Los jurados de *insight* premian reportar lo que no se sostuvo.
15. **El PDF no incluye "Even the death rate changed meaning: Portugal and Chad…"** (l. 301 es `print-hide`). Es la prueba de la recomendación "measure mortality with life expectancy, not the crude death rate" de la Slide 4. Conviene que salga también en el PDF.
16. **Lista de los 12 indicadores** de los *look-alikes* y del PCA (en el pie de la Slide 3 o en Referencias). Hoy el jurado no sabe cuáles son.
17. **"Four in ten countries sit between two groups"** depende del umbral de pertenencia difusa (0,5 → 24 %; 0,7 → 60 %). Basta con decir *"(fuzzy membership < 0.6)"* en el notebook o en el pie.
18. **Notebook en español.** Un jurado internacional que abra `notebook/analisis_wpp2024.html` necesitará un resumen ejecutivo en inglés al principio (el README ya es bilingüe).

## 6. Comparación con los ganadores 2025 y el rival más fuerte 2026

| Criterio de *insight* | **QuantaQuartet** (Best Statistical Insight 2025) | **`ahzasasa`** (Indonesia 2026, el más fuerte según `01b` §2.3) | **UNALSta-R (esta entrega)** |
|---|---|---|---|
| Pregunta y respuesta explícitas | Motivación + hallazgos por bloques | Q1–Q4 de trayectorias; no plantea P7 ni P8 | P1–P8 con códigos y una respuesta de una frase por pregunta |
| Hallazgo principal | Caída no lineal del trabajo infantil con el ingreso; bimodalidad en países ricos | k = 2/3 etapas de la transición (casi tautológico) + robustez | 84 de 130 bajo reemplazo crecen; dentro < entre países (−0,41 vs −1,05) e inversión en Europa; "un número no basta" con cuatro métodos; converge la esperanza de vida pero divergen la edad y LE65 |
| Rigor | CV R² 0,15, VIF; **ANOVA circular** sobre clústeres; lenguaje causal | Plan con hash, *ledger*, robustez, OtherVariants | Bootstrap por bloques de subregión, Wilson, KM/Turnbull con censura, FE con placebo, análisis paralelo, Monte Carlo OCDE/JRC, estabilidad de clústeres, 210 cifras recalculadas por código independiente |
| Migración e ingreso (P4/P7) | — | **No** (sin migración ni ingreso) | Sí: tipología de palancas, 71 % en ingreso alto, Golfo |
| Utilidad para la ONU | Recomendaciones genéricas | Ninguna | Tabla por agencia, ODS y horizonte |
| Riesgo | Estética pobre | Mismo eje narrativo que nuestra Q3 ("one transition, different timings") | Densidad; titulares conocidos; los tres descuidos de la §4 |

**Lectura:** esta entrega supera claramente a QuantaQuartet en corrección y alcance. Frente a `ahzasasa` empata en robustez y gana en cobertura (P4, P7 y P8), en ingreso y en el "¿y qué?" para la ONU. El riesgo frente a `ahzasasa` es que nuestra Q3 cuenta casi su misma historia. Por eso la diferencia hay que marcarla en Q1 y Q2 (migración, dentro frente a entre países, P8), que es exactamente lo que el deck pone delante.

## 7. Lo que no cubre este informe

- No escuché una lectura cronometrada (no hay voz grabada). El riesgo de pasar de 5:00 a 140 ppm (P-03) sigue abierto y ninguna corrección de la §4 añade voz.
- No recalculé cifras desde los CSV crudos. Me apoyo en la verificación independiente de `QA_stats.md` (210 cifras, 0 discrepancias). La única cuenta propia es √(0,186/0,920) de la I-2.
- Los juicios de visualización y ética corresponden a sus jurados (`QA_viz.md`, `QA_ethics.md`).
