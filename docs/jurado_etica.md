# Jurado simulado · *Best Consideration of Ethics* (ASA International DataQuest 2026)

> Agente **jurado-etica** (IA, Claude Code) · 2026-10-27 (reanudado tras la pausa) · solo lectura del repositorio. Solo escribí este archivo; los temporales están en el scratchpad `jurado_etica/`. Es la versión revisada del informe de esta mañana y sustituye al anterior.
>
> **Estado revisado:** `HEAD` = `5ec1bd6` ("docs: verificación humana, URL del repositorio y deck autosuficiente", 2026-10-26 19:03).
> - El encargo citaba `c367937`, pero la etiqueta `submission-2026-10-30-rc1` se quedó en `c367937` y `HEAD` va un commit por delante.
> - Ese commit cambia la declaración de IA, añade la URL y la verificación humana, y marca P-05 como **hecho**.
> - Desde entonces no ha cambiado ningún archivo versionado. Hay cuatro archivos sin versionar: `docs/jurado_*.md` (incluido este), `docs/01c_otros_videos_2025.md` y `output/`.
>
> **Material leído:**
> - la vara de medir: *ASA Ethical Guidelines* (2022), a través de `docs/04_etica_ASA_aplicada.md` (principios A–H, §2 y §4);
> - el guion `slides/script/narration_en.md` (v4: 596 palabras, 292,2 s, 21 claves en voz);
> - las **6 páginas** de `slides/export/slides.pdf`, renderizadas a 110 ppp y miradas una a una;
> - dos capturas del vídeo: `slides/dev/screenshots/steps/cover.b2.png` (primera frase) y `s4.b4.png` (panel de ética completo);
> - `slides/index.html`, `README.md` (EN/ES), `CITATION.cff` y `docs/equipo.json`;
> - `docs/registro_ia.md`, `docs/correcciones.md` (C, H, I y P-01…P-06), `docs/QA_stats.md` §10, `docs/QA_ethics.md` y `docs/verificacion_numeros.csv` (107 filas);
> - las celdas 0, §9 (limitaciones), §10 y §11 del notebook;
> - `docs/00_storyboard_diapositivas.md` §10.1, `docs/00_plan_analitico.md`, `docs/01b_otros_equipos_2025_2026.md` y `docs/referencia_ganadores/`.
>
> **Comprobaciones propias:**
> 1. El SHA-256 de `docs/hipotesis_preinscritas.md` es `83f98f6e1a3d…`, el que se publica, y el archivo no cambió desde `2a0ab7b` (2026-10-23 17:29).
> 2. 105 de las 107 claves de pantalla tienen **el mismo valor** desde `e14bf8c` (24-oct); las otras dos, `n_twin_pairs` y `pc1_var_sens_range`, se añadieron después. Las 107 son idénticas entre `c367937` y `HEAD`. Por eso es verosímil una comprobación humana que terminara a las 11:23 del 26-oct.
> 3. El texto del PDF de `c367937` y el de `HEAD` solo difieren en Referencias. La declaración pasó de *"wrote most of…"* y *"Every number **shown or said**"* a *"assisted… drafts"* y *"Every number"*, sin el alcance.
> 4. *Grep* de palabras con juicio o causalidad en el PDF y en la voz.
> 5. Busqué rutas absolutas en los archivos versionados, archivos `LICENSE` (no hay) y el correo personal (aparece en `docs/equipo.json` y `docs/equipo.md`, y es el correo de autor de los 9 commits).

---

## 1. Veredicto

**Puntuación: 8,0 / 10** tal como está `HEAD`. Con los ocho imprescindibles de la §4 resueltos sube a **≈ 9,5**, nivel de ganador internacional en ética.

En el vídeo y el PDF, la ética es lo más trabajado que he visto en este concurso:

- la incertidumbre oficial se ve y se oye;
- las proyecciones aparecen siempre como escenarios;
- cada país se cuenta una vez;
- los ejemplos salen de una regla;
- se publican las hipótesis que fallaron;
- la paleta y los nombres de grupo no juzgan;
- no hay logos de la ONU;
- la IA está declarada.

Lo que hoy baja la nota está casi todo **en el repositorio que se hará público el 29-oct**. Un jurado de ética lo abrirá, porque Referencias lo enlaza y la voz dice *"every number and our AI use are documented"*. Son cuatro frentes:

1. **Declaración de IA y de la verificación, imprecisa e incoherente (A.5, C.2).**
   - La tarjeta 5 del vídeo dice *"AI agents wrote code and text"*.
   - Referencias, el notebook y `CITATION.cff` dicen *"assisted… (most R code, memos, figures, slide and script drafts)"*.
   - El guion final no es un borrador: lo genera `build_narration.py` desde una plantilla escrita por agentes ("No editar a mano").
   - *"Every number"* perdió su alcance (*shown or said*), así que ahora incluye cifras del notebook que nadie revisó a mano.
2. **Crédito ausente (A.5, G.4).** `00_storyboard_diapositivas.md` §10.1 registra como **"Aplicada"** cuatro prácticas tomadas de `ahzasasa/asa-dataquest`, un competidor de 2026:
   - la estabilidad de grupo por país con rayado en el mapa;
   - la etiqueta explícita de "exploratorio";
   - la coherencia del relato;
   - el deck de 6 páginas.

   También registra varias tomadas de TRITICS y QuantaQuartet. Además, `00_plan_analitico.md` l. 32 cambia palabras para "no parecernos". Ni las diapositivas ni el README dan crédito a nadie.
3. **Material de terceros en el repositorio (D.4, C.7, F.1–F.2, H.3).**
   - Hay 59 capturas (8,4 MB) de vídeos, diapositivas y repositorios de otros equipos, entre ellas caras de estudiantes (`frames_tritics/01_tres_personas_t0m05s.jpg`).
   - Hay evaluaciones con nota de equipos con nombre propio y frases como "rival directo", "diez acciones para superarlos" o "neutraliza por adelantado la cifra del rival más fuerte".
   - Todo eso contradice el *"Privacy [D.4]. No personal data are used"* del README.
4. **Afirmaciones que dependen de tareas abiertas.**
   - *"are in our public repository (code MIT; texts CC BY 4.0)"*, pero no hay archivos `LICENSE`.
   - Firma humana sin rastro: `valor_comprobado_a_mano` y `ok` están vacíos en **107 de 107** filas, y "Revisión humana: pendiente" figura en 13 de 13 filas de `registro_ia.md` §1.
   - El código de verificación "independiente" tiene `RAIZ <- "/home/darkns/…"`.

Quedan además tres restos de lenguaje:

- la **primera frase del vídeo** (0:03), *"had too few children to replace their parents"*, que choca con la tarjeta *"no judgement on fertility"*;
- en el PDF, *"child deaths fall too slowly"* y *"have not crossed 4 yet"*;
- en el README y el notebook, *"66 because births exceed deaths"*, que `correcciones.md` H-06 da por corregido.

### Puntuación por principio ASA

| Principio | Nota | Por qué |
|---|---|---|
| **B** Integridad de datos y métodos | 9,5 | *Fitness for use* honesto: dice lo que **no** calculó (censos, Togo, T14). Países frente a agregados, umbral de 1 M declarado, intervalos por bloques presentados como sensibilidad y no como error muestral, Holm/BH, identidad contable dicha como tal y 46 correcciones registradas con su motivo |
| **C** Partes interesadas | 9 | *"Patterns, not causes"* en voz y pantalla; *"association, not cause"* junto a la gráfica más tentadora; el escenario de migración cero rotulado *"a what-if, not a forecast"*; "(UN medium)" en cada proyección; recomendaciones con *watch / prepare* y mandatos |
| **D** Grupos afectados y privacidad | 8 | Lenguaje y paleta neutrales (Okabe-Ito, "Recent movers" en lugar de "Late"), enfoque CIPD, *"not a ranking of development or well-being"* y posicionalidad de Colombia. Resta por las caras y los nombres de terceros en el repositorio y por *"too few children"* |
| **A** Integridad y responsabilidad | 7 | Responsabilidad igual y consentimiento declarados, y agentes que no se hacen pasar por personas. Resta por la declaración de IA rebajada e incoherente y por las ideas adoptadas sin crédito |
| **F** Profesión y reproducibilidad | 7,5 | Semilla, SHA-256, `numbers.json` como fuente única, `here::here()` en el análisis y notebook de 314 celdas. Resta por: falta `LICENSE`, el repositorio aún no es público, los scripts de verificación llevan rutas absolutas, el notebook no se volvió a ejecutar (está declarado) y hay evaluación pública de otros equipos |

---

## 2. Los criterios del encargo, uno a uno

| Criterio | Veredicto | Evidencia |
|---|---|---|
| **Honestidad sobre la verificación** (código independiente + los cuatro integrantes a las 11:23) | **Buena en el relato, débil en el rastro** | `QA_stats.md` §10 dice quién verificó, cuándo, el alcance (17 cifras habladas y 107 claves de pantalla), lo que queda **fuera** (README, notebook, memos, 173 claves solo del notebook) y que la anotó un agente con lo que informó el usuario. `verified: true` se distingue de la revisión humana, y Referencias admite que el código "independiente" también lo escribió la IA. Es verosímil, porque los valores no cambiaban desde el 24-oct. Pero el CSV tiene `valor_comprobado_a_mano` y `ok` vacíos en todas las filas, la firma es colectiva ("4 integrantes"), no se dice contra qué fuente se comparó, y §10 fecha el PDF a las 11:13:30, 10 minutos antes de la "hora de la verificación". Hay que decir que 11:23 es la hora en que **terminó** y cómo se hizo (I-5) |
| **Uso de IA declarado con precisión** | **Declarado en 5 sitios, pero impreciso** | Está en Referencias, la tarjeta 5, el README, el notebook (§9.6 y §11) y `CITATION.cff`, más un registro por fase con agentes y commits (`registro_ia.md`), "agentes asesores de IA (no son personas)" y "no synthetic voice". Falla en que "wrote" y "assisted… drafts" conviven en el mismo deck, y en que el alcance de *"Every number"* se perdió entre rc1 y `HEAD` (I-1) |
| **Incertidumbre visible** | **Excelente** | Voz: *"the UN's 95 percent range is nine to thirty-three million"*. PDF p. 2: abanico 80/95 % y *"for 77 of 161 countries it spans both growth and decline by 2050"*. En p. 3–4, intervalos en el panel y en R², rango de PC1 46–77 % e índice compuesto con *"one country in five can move more than 20 places"* |
| **Proyecciones como escenarios** | **Excelente** | *"grey = UN medium projection, a scenario"*, "(UN medium)" en las filas 1–3 de la tabla, *"which assumes the transition continues"*, voz *"are projected to"*, y migración cero rotulada *"a what-if, not a forecast"* |
| **Países frente a agregados** | **Excelente** | El pie de cada página dice *"countries only, no aggregates"*. También: *"Sums of countries"*, *"each country or area counted once"*, 237 frente a 161 (≥ 1 M), y *"a group total: it does not mean migration offsets low births country by country"* (desactiva la lectura de "reemplazo") |
| **Lenguaje no estigmatizante** | **Muy bueno, con 3 restos** | No hay semáforo ni jerarquía, aparece *"Levers, not verdicts"*, *"no alarm about birth rates"* y *"voluntary family planning"*, y se usan los nombres oficiales de la ONU ("other areas" en lugar de "territories"). Restos: *"too few children"* (voz, 0:03), *"fall too slowly"* y *"not crossed 4 yet"* (PDF), y *"because births exceed deaths"* (README y notebook) (I-6, I-7) |
| **Reproducibilidad** | **Buena, con grietas** | Análisis con `here`, variables de entorno, semilla 2026, SHA-256 de los crudos y procedencia P-06 honesta (sin fecha inventada). La versión del notebook (no re-ejecutado) está declarada. Grietas: verificación con rutas absolutas (I-8), sin `renv.lock`, sin `LICENSE` y repositorio aún privado (I-4) |
| **Privacidad y consentimiento de nombres (P-05)** | **Hecho en lo esencial; queda el correo** | El encargo daba P-05 por pendiente, pero en `HEAD` figura **hecho**: el usuario informó el 26-oct a las 12:10 que hay consentimiento escrito de los cuatro, que los documentos se guardan fuera del repositorio (bien hecho) y que las voces son de los integrantes. Las grabaciones de voz están excluidas de git como datos personales (`.gitignore`). Falta: el consentimiento cubre los **nombres**, no el correo personal de `equipo.json` y `equipo.md`, que es también el autor de todos los commits. Y el repositorio contiene caras y nombres de **terceros** (I-3) |
| **Atribución** | **Ejemplar hacia la ONU; ausente hacia los pares** | CC BY 3.0 IGO con *"Changes"* y *"the UN does not endorse this work"*, sin logos, descargo de fronteras, Banco Mundial CC BY 4.0, Natural Earth, software y fuentes. Falta el crédito a otros equipos y a la guía *Getting Started* (origen de P1–P8) (I-2) |

---

## 3. Lo que ya gana puntos (defenderlo tal cual)

| Práctica | Dónde se ve | Principio |
|---|---|---|
| Intervalo 95 % de la ONU **dicho en voz** y en pantalla, con abanico 80/95 %, más *"77 of 161 countries… both growth and decline"* | voz s1.b5b · PDF p. 2 | B.2, C.4 |
| Escenarios: *"a scenario"*, "(UN medium)" en cada fila de proyección y *"a what-if, not a forecast"* | PDF p. 2, 4, 5 | B.2, C.2 |
| La debilidad de la migración dicha en voz (*"the least certain lever"*) y en pantalla (*"often inferred from census gaps"*) | voz s1.b5a · PDF p. 2–3 | B.1, D.10 |
| *"association, not cause"* junto a la gráfica mortalidad → fecundidad, con la inversión en Europa y N. América (+0,39) y el intervalo que incluye 0 a la vista | PDF p. 3 | C.2, C.3 |
| Ejemplos por regla, a la vista: *"three largest of each type (≥ 1 M)"*, gemelos *"chosen by rule from 12,880 pairs"*, Colombia *"our home country, shown as an illustration"* | PDF p. 2, 4 | A.4 |
| Hipótesis con *hash* y salvedad honesta: *"fixed before the final run, after exploring the same data — not confirmatory"* | voz s4.b4 · PDF p. 6 | B.3, C.3 |
| Lo que no se encontró: H2, H7, H8 y H9 rechazadas o retiradas, y 18 frases caídas con su motivo | notebook §8 · `correcciones.md` C | Apéndice 8 |
| Grupos sin jerarquía, Okabe-Ito, *"Levers, not verdicts"*, *"not a ranking of development or well-being"* | PDF p. 4–5 | A.8, D.6 |
| Atribución a la ONU con cambios y sin respaldo; sin logos; descargo de fronteras en cada mapa | PDF p. 2, 6 y pies | C.7, A.6 |
| Agentes nombrados como agentes, "no synthetic voice", responsabilidad igual sin papeles inventados y procedencia de datos sin fecha inventada | Referencias · `registro_ia.md` · `data/README.md` | A.5, C.2 |
| Sección de limitaciones del notebook (§9.1–9.7): dice lo que no se calculó (censos, Togo, T14), que los *bootstrap* miden sensibilidad y no error muestral, y que el ingreso de hoy se aplica a todos los años | notebook §9 | B.1–B.3, C.2 |

---

## 4. Imprescindibles (ordenados por gravedad; todos caben en ≤ 2 días)

| # | Dónde | Problema | Corrección exacta |
|---|---|---|---|
| **I-1** | Referencias (`slides/index.html` l. 492); README l. 159 (EN) y l. 319 (ES); `notebook/construir_notebook.py` l. 623 (§9.6) y l. 686 (§11); `CITATION.cff` (`abstract`); storyboard l. 256 | **La declaración de IA se contradice en el propio deck (A.5, C.2):** la tarjeta 5 dice *"wrote"* y Referencias *"assisted… drafts"*. Además el texto final del guion y de las diapositivas lo escribieron agentes, y *"Every number"* perdió el alcance *"shown or said"* que tenía en rc1 | **Referencias y notebook §11 (EN):** *"AI assistance: Claude Code (Anthropic) AI agents, directed by the team, wrote most of the R code, the memos, the figures and the slide and script text; team members voice the video (no synthetic voice). Every number shown or said was recomputed from the raw UN files by separate code (also AI-written) and checked by hand by the four team members. The four of us share equal responsibility. Log: docs/registro_ia.md."*<br>**README EN:** cambiar "assisted the analysis, the code and the production: they wrote … drafts of the slides and script" por "wrote most of the R code, the analysis memos, the figures and the slide and script text".<br>**README ES y notebook §9.6:** cambiar "asistieron el análisis, el código y la producción: escribieron … los borradores del guion y de las diapositivas" por "escribieron la mayor parte del código R, los memos, las figuras y el texto de las diapositivas y del guion".<br>**`CITATION.cff`:** "…AI agents (Claude Code, Anthropic), directed by the team, wrote most of the code, figures and texts; team members voice the video…".<br>Escribir "drafts … edited by the team" solo si el equipo de verdad reescribió el texto.<br>Después: `bash video/export_pdf.sh --png`, mirar la p. 6 y comprobar que siguen siendo 6 páginas; `notebook/construir_notebook.py` + `exportar_html.py`; y anotar el cambio en `correcciones.md` |
| **I-2** | Referencias (`slides/index.html`, columna izquierda, después del `</ul>` de *Acronyms* en l. 475; en el PDF p. 6 hay hueco); README §Ethics (EN y ES) | **Falta el crédito a otros equipos (A.5, G.4).** Según el storyboard §10.1 se aplicaron prácticas de `ahzasasa` (2026), TRITICS y QuantaQuartet (2025), y P1–P8 vienen de la guía oficial. Nada lo reconoce. Un jurado que lea `docs/` puede tomarlo por apropiación | **Referencias:** `<h3>Acknowledgements</h3><ul><li>Questions P1–P8: ASA DataQuest 2026 Getting Started guide (section 6). Before designing, we studied public videos and repositories of other DataQuest 2025–2026 teams; what we adopted, with credit: README → Acknowledgements.</li></ul>`<br>**README EN, sección nueva "Acknowledgements":** "We studied public work of other DataQuest teams before designing ours (read 22 Oct 2026): 2025 winners TRITICS and QuantaQuartet; 2026 repositories `ahzasasa/asa-dataquest`, `idiltuzkaya/asa_dataquest` and `yguzmanm-sys/ASA-DataQuest`. From TRITICS we adopted plain-language glosses and a simple → richer model comparison; from QuantaQuartet, showing data quality up front and out-of-sample checks; from `ahzasasa/asa-dataquest`, marking each country's group stability on the map (hatching) and labelling results as exploratory." Añadir la versión ES.<br>Ajustar la lista a lo que el equipo confirme; si se aplican ideas de `01c` (vídeos de 2025), añadir esos equipos. Si el profesor orientó P7/P8 o aportó código, una línea más. Después, volver a exportar el PDF |
| **I-3** | `docs/referencia_ganadores/` (59 imágenes), `docs/01_analisis_ganadores_2025.md` y `docs/01b_otros_equipos_2025_2026.md`, **en todo el historial**; sin versionar: `docs/01c_otros_videos_2025.md` y `docs/jurado_*.md` | **Material de terceros y evaluación pública de otros equipos (D.4, C.7, F.1–F.2, H.3).** Caras de estudiantes, capturas sin licencia, notas a equipos con nombre, "rival directo", "superarlos", y la burla del "Lorem Ipsum" de otro equipo. El propio `INDICE.md` §7 pide "revisar su inclusión antes de hacer público el repositorio". Un `git rm` no basta, porque GitHub mostraría los commits viejos | **Antes del primer push** (aún no se ha subido nada):<br>1. `git bundle create ../respaldo_pre_filtro.bundle --all`<br>2. `mkdir -p ../interno_no_publicar && cp -r docs/referencia_ganadores docs/01_analisis_ganadores_2025.md docs/01b_otros_equipos_2025_2026.md docs/01c_otros_videos_2025.md docs/jurado_*.md ../interno_no_publicar/`<br>3. `pip install git-filter-repo && git filter-repo --force --invert-paths --path docs/referencia_ganadores/ --path docs/01_analisis_ganadores_2025.md --path docs/01b_otros_equipos_2025_2026.md`<br>4. Actualizar los hashes citados (README y notebook citan `2a0ab7b`): `tail -n +2 .git/filter-repo/commit-map \| while read o n; do git grep -l "${o:0:7}" \| xargs -r sed -i "s/${o:0:7}/${n:0:7}/g"; done`; revisar `git diff --stat` y hacer el commit.<br>5. `git remote add origin https://github.com/DarkNightSoldier/ASA_DataQuest_2026.git`<br>6. Quitar esas filas de `docs/INDICE.md` y no versionar `01c` ni `jurado_*.md`.<br>7. Comprobar que `git log --all --oneline -- docs/referencia_ganadores \| wc -l` da 0.<br>Las fechas de commit y el SHA-256 de las hipótesis no cambian. Si el equipo no quiere reescribir el historial, el mínimo es `git rm -r` de las tres rutas, sabiendo que seguirán visibles en los commits viejos |
| **I-4** | Raíz del repositorio; Referencias l. 493; `CITATION.cff` (`version`); `docs/equipo.json` y `equipo.md` (`contact_email`); autor de los commits | **"are in our public repository (code MIT; texts CC BY 4.0)" hoy es falso (C.2, F.4).** No hay `LICENSE` ni `LICENSE-texts`, no existe la etiqueta `v1.0-submission` que cita `CITATION.cff`, y el correo personal no lo cubre el consentimiento (D.4) | 1. Crear `LICENSE` con el texto MIT estándar y la línea "Copyright (c) 2026 Daniela C. Kwan, David S. Merchán, Jhon A. Mora, Alejandro Higuera".<br>2. `curl -L https://creativecommons.org/licenses/by/4.0/legalcode.txt -o LICENSE-texts`<br>3. Correo: o su dueño confirma por escrito que acepta publicarlo, o se cambia por uno institucional (@unal.edu.co) o el *noreply* de GitHub en `equipo.json` y `equipo.md`. Para el autor de los commits, `git config user.email <noreply>` en adelante, o `--mailmap` en el paso 3 de I-3.<br>4. Commit, `git tag -a v1.0-submission -m "DataQuest 2026 submission"` y, el 29-oct, `git push -u origin main --follow-tags`. Abrir la URL en una ventana privada y comprobar que se ven el README, `LICENSE` y `docs/registro_ia.md`.<br>5. Si no se publica antes de enviar: Referencias → *"available from the team on request"*, y volver a exportar el PDF y el vídeo |
| **I-5** | `docs/verificacion_numeros.csv`; `docs/QA_stats.md` §10; `docs/registro_ia.md` §1 (columna "Revisión humana"); cabecera de `docs/correcciones.md` (l. 5) | **La verificación humana no deja rastro (A.1, C.2).** `valor_comprobado_a_mano` y `ok` están vacíos en 107 de 107 filas, no se dice contra qué fuente se comparó, y "pendiente" aparece en 13 de 13 filas del registro de IA y en C-01…C-46. Contradice *"checked by hand by the four team members"*. **Lo hacen personas** (≈ 2 h) | 1. Repartir las filas del CSV, al menos las 21 con `en_voz = sí`; por ejemplo, líneas 2–28, 29–55, 56–82 y 83–108. Cada integrante comprueba sus filas contra la salida de `notebook/analisis_wpp2024.html` (o recalcula) y escribe `verificado_por` (su nombre), `verificado_en` (fecha y hora de **esta** comprobación), `valor_comprobado_a_mano`, `ok` = sí/no y `nota` = fuente (p. ej. "notebook HTML §Q1·3").<br>2. En `QA_stats.md` §10, añadir la fila **"Método"** (qué se comparó y contra qué) y aclarar que 11:23 es la hora en que **terminó** la comprobación del 26-oct.<br>3. En `registro_ia.md` §1, cambiar cada "pendiente" por lo que de verdad se hizo (p. ej. "4 integrantes · 2026-10-26 · cifras y salida del notebook; el texto no se revisó línea a línea") o por "no revisado".<br>4. Cabecera de `correcciones.md`: "Revisión humana: el equipo comprobó las cifras resultantes (P-01); las correcciones no se firmaron una a una".<br>Ninguna cifra cambia |
| **I-6** | Voz `cover.b2`: `slides/script/narration_en_template.md` l. 17 y `data-caption` en `slides/index.html` l. 58. PDF p. 5, fila 1 (`index.html` l. 407). PDF p. 3, nota (`index.html` l. 235) | **Juicio de valor residual (A.8, D.6)** frente a la tarjeta *"no judgement on fertility"*. La **primera frase del vídeo** es *"had too few children to replace their parents"*. Además, *"child deaths fall too slowly"* y *"have not crossed 4 yet"* (teleológico) | **Voz** (15 palabras frente a 14; cabe en los 8,9 s del paso): `> In 2023, {n_below_replacement_2023} countries and areas \| had fertility below the level that replaces each generation.` El mismo texto, con la cifra, en `data-caption`.<br>**Fila 1:** `child deaths off pace for SDG 3.2: …` (el resto igual).<br>**Nota p. 3:** `… countries, mostly in sub-Saharan Africa, had not fallen below 4 by 2023 and are not shown; …`<br>Después: `$VENV/bin/python slides/script/build_narration.py`, `$VENV/bin/python slides/dev/check_sync.py`, `bash video/export_pdf.sh --png` y `video/record_slides.py --mp4`. No cambia ninguna cifra, así que no hace falta volver a verificar a mano; anotarlo en `correcciones.md` |
| **I-7** | README l. 29–30 (EN) y l. 218–219 (ES); `notebook/construir_notebook.py` l. 284 (celda 1) | **Error ya corregido en la voz y el deck que sigue publicado aquí (B.5, C.2).** "66 **because** births exceed deaths" atribuye el crecimiento solo a los nacimientos; es H-06, que `correcciones.md` da por aplicado | **EN:** "In 2023, **130** of the 237 countries and areas had fertility below replacement (about 2.1 children per woman). Yet **84** of them were still growing: **66** have more births than deaths and **18** grow only because more people arrive than leave."<br>**ES:** "…tenían una fecundidad por debajo del reemplazo (≈ 2,1 hijos por mujer), y sin embargo **84** seguían creciendo: **66** tienen más nacimientos que defunciones y **18** crecen solo porque llega más gente de la que se va."<br>**Notebook:** "…{66} tienen más nacimientos que defunciones y {18} crecen solo porque llegan más personas de las que se van."; después, `construir_notebook.py` + `exportar_html.py` |
| **I-8** | `docs/qa/verificacion_lote_1.R` l. 24, `_2` l. 29, `_3` l. 32, `_4` l. 23 y `docs/qa/consolidar_verificacion.R` l. 43 | **La verificación "independiente" no es reproducible (F.4, B.4).** `RAIZ <- "/home/darkns/Documents/ASA_Dataquest/RepoGithub"` hace fallar fuera de esta máquina justo el código que respalda *"recomputed by independent code"* y la tarjeta *"Open & checkable"* | Cambiar esa línea en los 5 archivos por `RAIZ <- here::here()`; el repositorio ya tiene `.here`, y `PADRE <- dirname(RAIZ)` sigue igual. Probar desde la raíz con `Rscript docs/qa/verificacion_lote_1.R`. Añadir al README (paso de reproducción): "Re-run the independent check: `for i in 1 2 3 4; do Rscript docs/qa/verificacion_lote_$i.R; done; Rscript docs/qa/consolidar_verificacion.R`" |

**Orden práctico (≈ 1,5 días):**

1. I-3 y luego I-4, antes de cualquier push y en ese orden, porque I-3 reescribe los hashes.
2. I-1, I-2 e I-6 en `index.html` y en la plantilla, con **una sola** exportación del PDF y del vídeo mudo, mirando las 6 páginas.
3. I-7 e I-8.
4. I-5, que lo hacen las personas.
5. Grabar la voz (P-03) con el guion ya corregido.

---

## 5. Mejoras deseables

1. **Volver a ejecutar el notebook entero** antes de la etiqueta final, para que salidas y texto coincidan (§10 avisa de que la huella impresa es la de 383 claves).
2. **`renv::snapshot()`** para tener un `renv.lock`, o un script de instalación con versiones fijas.
3. **Cerrar la cifra externa de EAU (+12 % entre WPP 2022 y 2024)** en el notebook (§0 y §9.1): que una persona la coteje o se borre. Un notebook final no debería decir "debe verificarla una persona".
4. **Sensibilidad de Togo** (*Interim Update*, C-46): correrla, o listarla en el README entre lo que no se hizo.
5. **Referencias de los mandatos** que cita la tabla de la S4: Programa de Acción de la CIPD (1994), GCM (A/RES/73/195), metadatos ODS 3.2.1, 3.7.2, 10.7.2 y 17.19 y *UN Decade of Healthy Ageing*.
6. **Franja de ética del PDF.** Hoy solo muestra los títulos de las tarjetas; añadir debajo una línea con el contenido de la tarjeta 5.
7. **Mitigar el error de modo común.** El código "independiente" lo escribió la misma familia de modelos. Recalcular a mano en una hoja de cálculo, desde el CSV de la ONU, 3–5 cifras clave (130, 84, 18, 70,7 % y el intervalo 95 % de EAU) y anotarlo en `QA_stats.md` §10.
8. **Sello de tiempo externo.** Publicar la *release* `v1.0-submission` en Zenodo, que da un DOI, para que el *hash* de las hipótesis no dependa solo de las fechas de git.
9. **Pulido de lenguaje:**
   - *"deaths already outnumber births"* (PDF p. 2) → *"deaths outnumber births"*;
   - *"safe return"* (fila 5) → *"safe and dignified return (GCM obj. 21)"*;
   - *"still fall too slowly"* en `R/04_q3_caminos.R` l. 1183 y 1614 y en `numbers.json` (no sale en pantalla).
10. **Cabecera "agente de IA" en cada memo** `docs/06_asesoria_*.md`. Hoy dicen "Asesor: demografía…" sin aclarar que no es una persona; solo lo aclara `registro_ia.md`.
11. **Neutralizar el tono competitivo** en los documentos que queden (`00_plan_analitico.md` l. 32 y 253, `QA_slides.md`, `07_integracion_asesorias.md`): dejar hechos y créditos.
12. **Rutas absolutas restantes** (`R/fig_q1_slide1.R` l. 152 y siguientes, `slides/script/build_narration.py` l. 135, `video/*.sh`, `SETUP.md`): leer `FFMPEG` y `VENV` del entorno, con un *fallback* que no sea el scratchpad de una sesión.
13. **Texto alternativo de las figuras en el README**, y anotar en `registro_ia.md` §2 quién narra cada parte cuando se grabe.

---

## 6. Resumen para el orquestador

8,0/10 hoy y ≈ 9,5 con los ocho imprescindibles. La ética que se ve en el vídeo y en el PDF es de nivel ganador. Lo que puede costar el premio:

- una declaración de IA que dice "wrote" en la tarjeta y "assisted… drafts" en Referencias, y que perdió el alcance *"shown or said"*;
- prácticas adoptadas de otros equipos sin crédito;
- capturas, caras y evaluaciones de otros equipos en el historial;
- licencias anunciadas que no existen;
- una firma humana sin rastro (107 filas con `ok` vacío);
- la primera frase, *"too few children"*.

Todo se corrige en ≤ 2 días sin cambiar ninguna cifra.

*Nota: este informe nombra a otros equipos. Es de uso interno y no debe versionarse en el repositorio público (I-3).*
