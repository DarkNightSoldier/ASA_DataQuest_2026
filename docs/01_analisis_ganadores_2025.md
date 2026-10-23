# Análisis a fondo de los ganadores del ASA International DataQuest 2025

**Propósito.** Documentar, con números y citas textuales, qué hicieron los equipos premiados en 2025 (TRITICS, QuantaQuartet y, en lo que se pudo verificar, Glorystician) para que nuestro equipo del DataQuest 2026 (UN World Population Prospects 2024, archivo *Medium*) los tome como referencia y los supere.

**Fecha de elaboración:** 2026-10-22. **Autor:** agente `winners-review`.

**Materiales analizados.**
- Vídeo TRITICS (`videosref/Where You Live Matters_ ….mp4`, 1280×720, 30 fps, 8 823 fotogramas, **294,1 s = 4:54**). Se extrajo 1 fotograma por segundo (294 imágenes) con OpenCV; los subtítulos quemados se leyeron de 20 mosaicos de la banda inferior (y≈598–668 px) y el contenido visual de 7 hojas de contacto 3×3 (una cada 5 s). No se analizó la pista de audio (sin ffmpeg); todo lo dicho sobre voz y música es inferido de la imagen.
- QuantaQuartet: `videosref/Quantaquartet/Quantaquartet.pdf` (20 páginas, sin capa de texto; leídas como imagen) y 20 capturas de su vídeo (`01.jpeg … 21.jpeg/png`).
- Web: FAQ oficial, página principal y de ganadores del DataQuest (sitio GitHub Pages de la ASA), página de la comunidad ASA, prensa universitaria (ULM Indonesia, Hacettepe Türkiye, UNM Indonesia), repositorio GitHub de QuantaQuartet, repositorios públicos de participantes 2025 y 2026.
- Fotogramas clave guardados en `RepoGithub/docs/referencia_ganadores/frames_tritics/` (21 fotogramas + 7 hojas de contacto) y `…/frames_quantaquartet/` (15 diapositivas).

---

## 0. Resumen ejecutivo (lo que hay que saber en 2 minutos)

| | **TRITICS** (Indonesia) | **QuantaQuartet** (Türkiye) | **Glorystician** (Indonesia) |
|---|---|---|---|
| Premio internacional 2025 | **Best Data Visualization** | **Best Statistical Insight** | **Best Consideration of Ethics** |
| Universidad | Universitas Lambung Mangkurat (ULM) | Hacettepe University (Estadística) | Universitas Lambung Mangkurat (ULM) |
| Tema | Motores sectoriales y macro del crecimiento de los 10 países ASEAN, 2001–2024 (WDI) | Raíces del trabajo infantil en el mundo (dataset del concurso + ILOSTAT) | No público (no se encontró vídeo ni diapositivas) |
| Pregunta explícita | 2 preguntas literales en pantalla | 1 motivación + hallazgos por bloques | — |
| Método | OLS agrupado y panel (FE/RE) como base → **GWPR** (regresión panel geográficamente ponderada) | ANOVA/post-hoc por grupo de ingreso → Ridge/Lasso/ElasticNet con VIF y CV 5-fold → K-means k=2 + ANOVA | — |
| Cifra estrella | adj. R²: GWPR **91,4 %** vs OLS 75,7 % vs panel 69,9 % | CV R² del mejor modelo (Ridge) = **0,153**; silueta k=2 ≈ 0,45 | — |
| Visual estrella | Mapa ASEAN coloreado por sector significativo + matriz de 6 palancas de política con banderas | Mapa coroplético log(tasa) + violines por ingreso + mapa K-means | — |
| Ética visible | Ninguna diapositiva de limitaciones | Cobertura de datos y datos faltantes al inicio; "invisible children"; repo público tras el plazo | (ganó ética) |
| Duración | 4:54 (guion de 591 palabras ≈ 123 palabras/min) | ~5:00 (vídeo en YouTube `-r9DeI_vplI`, hoy no accesible: 403) | — |

**Las tres lecciones maestras:** (1) una historia con gancho, 2 preguntas literales y callback final; (2) un modelo simple de base y uno "rico" que *muestra* la heterogeneidad por país/tiempo en un mapa; (3) traducir cada resultado en "qué palanca, en qué país, en qué momento". **Lo que ninguno hizo bien y nos da ventaja:** ética explícita y honesta (incertidumbre, proyecciones ≠ predicciones, sin lenguaje causal), un guion que diga "esto es exploratorio", y reproducibilidad abierta desde el día 1.

---

## 1. Reglas y criterios vigentes (verificados en la web el 2026-10-22)

### 1.1 Reglas oficiales (FAQ y página principal)

Fuente primaria: FAQ oficial <https://american-statistical-association.github.io/CIRSDataQuest/faq.html> (también el `faq.qmd` del repositorio `American-Statistical-Association/CIRSDataQuest`) y la página principal <https://american-statistical-association.github.io/CIRSDataQuest/>. Página de la comunidad ASA: <https://community.amstat.org/committeeoninternationalrelationsinstatistics/events2/data-quest>.

| Regla | Texto oficial (inglés) | Implicación para nosotros |
|---|---|---|
| Entregable | "Teams must submit a 5-minute video presentation along with slides by the last Friday of October." | Vídeo ≤ 5:00. TRITICS usó 4:54; apuntar a 4:50–4:58 con margen. |
| Límite de diapositivas | "Other than the cover slide and references, your file should have at most 4 slides." | **Máximo 6 diapositivas en total: portada + 4 de contenido + referencias.** QuantaQuartet cumplió exactamente (y añadió un "apéndice técnico" de 14 páginas tras las referencias; arriesgado, ver §6). |
| Fecha límite | "The dataset is released on the first Monday of October" / "Video submissions are due on the last Friday of October." | 2026: dataset lunes 5 de octubre; **entrega viernes 30 de octubre de 2026** (la hora exacta la fija cada país; QuantaQuartet cita "31/10/2025 23:59 (Türkiye Time)" en 2025). |
| Equipos | "Teams of 2–4 students consisting of either undergraduate OR master's students"; "Teams cannot mix undergraduate and master's students"; "Students from any discipline are welcome". | — |
| País | "Participation is based on your student status. You should participate with peers in country X." | — |
| Premios | "There are three award categories, each given separately for undergraduate and master's levels: Best Data Visualization, Best Consideration of Ethics, and Best Statistical Insight." | Un mismo vídeo compite en las tres; conviene diseñar para ganar **una** con claridad y no desatender las otras dos. |
| Qué evalúa cada premio (página principal) | Best Data Visualization: "Most effective graphics communicating findings". Best Consideration of Ethics: "Best addresses ethics of analysis per ASA Ethical Guidelines". Best Statistical Insight: "Most compelling statistical insight". | Viz = *comunicar hallazgos* (no belleza por sí misma). Ética = **citar y aplicar las ASA Ethical Guidelines** (ver memoria `asa-ethical-guidelines.md`). Insight = *convincente* (claridad + evidencia), no "más complejo". |
| Premio | Cada miembro de un equipo ganador recibe un año de membresía ASA gratis. | — |
| Nivel 2025 | "In 2025, Indonesia was the only country to hold a master's-level competition, so an international competition at this level was not held." (winners.qmd) | Los tres ganadores 2025 son de pregrado. |
| Países 2025 / 2026 | 2025: Brazil, Indonesia, Türkiye. 2026: Brazil, Colombia, Dominican Republic, Indonesia, Mexico, Nepal, Nigeria, Türkiye (Namibia "coming soon"). | En 2026 hay competencia nacional en Colombia; primero hay que ganar la ronda nacional. |
| No regulado en la FAQ | Formato de archivo, datos externos, uso de IA, idioma, código. | TRITICS usó datos externos (WDI, no el dataset del concurso tal cual) y QuantaQuartet fusionó ILOSTAT; ambos ganaron, así que **complementar con datos externos citados es aceptable**. Nosotros priorizamos WPP2024 Medium (instrucción del equipo) y si añadimos ingreso (WB income groups) lo citamos. |

### 1.2 Criterios de la ronda nacional (Indonesia 2025, prensa universitaria)

Según la nota de prensa de ULM/teras7 (traducida): el concurso exigía "compose a maximum five-minute presentation video and four content slides containing **the analysis process, core visualization, statistical insight, and ethics aspect per ASA standards**", y los jurados valoraron "statistical analysis capability, data visualization quality, scientific communication, ethical considerations". Es decir, **las cuatro dimensiones se evalúan juntas en cada vídeo**; los premios se asignan por la dimensión en que más destaca el equipo.

### 1.3 Ganadores 2025 verificados (winners.html)

- **Best Data Visualization — Tritics ("Trilogy of Tidal Curves")**, Indonesia, Lambung Mangkurat University: Erpan Maulana, Muhammad Fauzan Adzim, Muhammad Azkaa Al Atqiaa (asesor: Ardiansyah Abubakar).
- **Best Consideration of Ethics — Glorystician**, Indonesia, ULM: Muhammad Radityo Denishworo Marsudi, Dwi Annisa Febriyanti (asesor: Samsul Arifin).
- **Best Statistical Insight — QuantaQuartet**, Türkiye, Hacettepe University: Atasagun Yılmaz, Önder Akkaya, Tuana Çerçive, Taner Yeşilay.

Nota importante: nuestra memoria previa decía que TRITICS ganó por "insight"; **la web oficial confirma que TRITICS ganó Best Data Visualization y QuantaQuartet Best Statistical Insight**. A nivel nacional (Türkiye), QuantaQuartet fue 1.º en Statistical Insight, 2.º en Data Visualization y 3.º en Ethics (README de su repo). En Indonesia, además de Tritics (Best 1 Viz) y Glorystician (Best 1 Ethics), ULM obtuvo Best 2 y Best 3 en Ética (equipos Vizchiefs y Chartosaur Inferna). El equipo "SSO" (Indonesia, repo `StyNW7/ASA-International-Data-Quest-2025`, "The Paradox of Progress: Why Human Development Doesn't Always Guarantee Well-Being", con app Streamlit) participó pero no figura entre los premiados internacionales.

### 1.4 Dataset 2025 vs 2026

En 2025 el dataset del concurso era de desarrollo humano / indicadores país (los equipos lo combinaron con WDI e ILOSTAT). En 2026 el dataset es **UN WPP 2024** (Medium: 1950–2100, 236 países + agregados). Ya hay competidores 2026 con repos públicos: *Team Ipanema* (Brasil) publicó un globo 3D interactivo (globe.gl) con 9 capas, línea de tiempo 1950–2100 y abanicos de incertidumbre 80/95 % (<https://carvguilherme8.github.io/demographic-globe/>); un repo turco (`busahinku/asa_dataquest`, fork de `idiltuzkaya`) hace EDA con 10 preguntas y señala que mezclar agregados con países infla los totales ≈44,8×. **Conclusión:** el nivel visual de 2026 subirá (globos 3D, intervalos); la ventaja debe venir de la narrativa, la estadística bien explicada y la ética.

---

## 2. TRITICS — "Where You Live Matters: Revealing Sector–Macro Drivers of ASEAN Countries' Economic Growth with Geographically Weighted Panel Regression"

### 2.1 Ficha

- YouTube: <https://www.youtube.com/watch?v=0Cr-FDzE3U4> (canal "Kayno Mint"). Duración 4:54 (último fotograma con contenido a 4:48; 4:49–4:54 en negro).
- Datos: World Bank *World Development Indicators*, 10 países ASEAN, 2001–2024 (panel 10 × 24 = 240 observaciones país-año como máximo).
- Variable dependiente: crecimiento del PIB real (%). 10 variables explicativas en 4 familias (ver §2.5).
- Modelos: OLS agrupado; panel convencional (efectos fijos/aleatorios); **GWPR**. Comparación por adj. R².
- Equipo: 3 presentadores que se turnan por sección, de pie, camisa negra, compuestos (chroma) sobre las diapositivas.

### 2.2 Transcripción completa del guion (subtítulos quemados, tiempos aproximados ±1 s)

| t | Texto |
|---|---|
| 0:00 | "Money cannot buy everything, … |
| 0:02 | … but everything needs money." |
| 0:04 | We are (the team of) Trilogy of Tidal Curves (TRITICS). |
| 0:05 | Three people. |
| 0:06 | One purpose. |
| 0:08 | Today, we invite you to follow the story on screen. |
| 0:12 | Take the title as a hint. |
| 0:13 | Where you live matters. |
| 0:15 | Why this matters now. When growth is well guided, |
| 0:19 | people feel it in daily life: |
| 0:20 | less poverty and inequality, |
| 0:23 | stronger health and public services, |
| 0:26 | better governance, |
| 0:27 | more and better jobs with higher real incomes, |
| 0:30 | stronger infrastructure and connectivity, |
| 0:33 | higher productivity and innovation, |
| 0:35 | and wider access to learning. |
| 0:38 | The clock is ticking toward the 2030 |
| 0:40 | Sustainable Development Goals (SDGs) |
| 0:42 | and ASEAN Community Vision 2045. |
| 0:46 | Since the early 2000s, agriculture's |
| 0:47 | share of the economy has generally shrunk |
| 0:51 | across the region, while industry has moved unevenly, |
| 0:55 | with some places deepening and others softening. |
| 0:58 | So we ask two simple questions. |
| 1:01 | "Which parts of the economy matter most for growth, |
| 1:04 | and how do broader conditions like prices, |
| 1:07 | trade, and the labor force shape the result?" |
| 1:10 | "Do these relationships differ by country and by year?" |
| 1:14 | If we can answer with solid evidence, |
| 1:16 | we can choose the right levers with confidence. |
| 1:21 | We use World Bank indicators for all ASEAN countries |
| 1:24 | from 2001 to 2024 to study what drives |
| 1:29 | year-to-year growth across four input groups: |
| 1:32 | agriculture, industry, |
| 1:34 | prices/trade, and workforce/demographics. |
| 1:37 | As baselines, we estimate pooled linear regression |
| 1:40 | and conventional panel regression, |
| 1:43 | and random effect, to obtain region-wide average effects. |
| 1:47 | In comparison with these, we then fit a geographically |
| 1:51 | weighted panel regression (GWPR), |
| 1:52 | which lets each coefficient vary by country and year |
| 1:56 | to capture spatial–temporal heterogeneity. |
| 1:59 | That flexibility is essential |
| 2:01 | because the same factor rarely |
| 2:03 | has the same impact everywhere |
| 2:05 | or at all times. |
| 2:07 | Our results show that the GWPR |
| 2:11 | outperforms the pooled |
| 2:13 | linear and standard panel models, |
| 2:16 | fitting the data much better. |
| 2:18 | This indicates that growth doesn't follow a single rule |
| 2:21 | across ASEAN: the strength |
| 2:23 | and even the sign of key drivers shift by country and by year, |
| 2:28 | and only the flexible model captures those place- |
| 2:31 | and time-specific differences. |
| 2:33 | Across the years, |
| 2:34 | the most persistent driver is industrial momentum: |
| 2:38 | economies grow faster when industry |
| 2:40 | expands and deepens. |
| 2:42 | Price stability |
| 2:43 | and openness to trade repeatedly support growth, |
| 2:46 | as do higher labor-force participation rates, |
| 2:49 | while unemployment drags it down. |
| 2:52 | Larger agricultural shares |
| 2:53 | tend to coincide with slower growth, |
| 2:56 | even when the farm sector posts short spurts. |
| 3:00 | Higher income levels bring natural convergence |
| 3:03 | and slower expansion, |
| 3:05 | and favorable age structures |
| 3:07 | can add a demographic tailwind |
| 3:09 | when jobs absorb new workers. |
| 3:12 | We translate the evidence into country-specific action |
| 3:15 | guided by the statistical analysis before. |
| 3:18 | Upgrade industry and value chains at a feasible pace |
| 3:21 | so downstreaming can progress toward |
| 3:24 | advanced manufacturing where viable. |
| 3:27 | Cut trade costs by fixing logistics, |
| 3:30 | ports, corridors, and customs. |
| 3:33 | Secure reliable energy |
| 3:35 | and macroeconomic stability through credible inflation, |
| 3:39 | stable foreign exchange, and predictable input policies. |
| 3:43 | Modernize agriculture and expand agro-processing |
| 3:47 | with better irrigation, quality seeds, |
| 3:50 | sound post-harvest handling, |
| 3:53 | cold chains, and strategic reserves. |
| 3:56 | Align skills with demand |
| 3:58 | via technical and vocational education, |
| 4:01 | reskilling, |
| 4:02 | higher participation, and targeted talent development. |
| 4:05 | Lock in confidence |
| 4:07 | by improving the investment climate |
| 4:09 | with simpler permits, |
| 4:11 | focused promotion, and clear, stable rules. |
| 4:14–4:17 | (sin subtítulo; transición de salida de la matriz de palancas) |
| 4:18 | Let us close where we began. |
| 4:20 | Money cannot buy everything, |
| 4:21 | yet progress still needs investable clarity. |
| 4:24 | The same lever will not move every economy. |
| 4:27 | With this analysis, |
| 4:29 | we can see which lever to pull, in which country, |
| 4:32 | and at which time. |
| 4:33 | On behalf (the team) of TRITICS, |
| 4:35 | we encourage ASEAN to turn evidence into action, |
| 4:40 | move with focus, |
| 4:41 | learn fast, and build a resilient, innovative, |
| 4:45 | dynamic, people centered region by 2045. |
| 4:49–4:54 | Pantalla en negro (fin). |

**Métricas del guion:** 591 palabras en ≈288 s de habla → **≈123 palabras/min**; 34 oraciones, **media 17,4 palabras/oración** (máx. 48, la pregunta 1). Densidad baja a propósito: cada idea tiene 2–3 s de aire para que el espectador mire la gráfica.

### 2.3 Estructura narrativa minuto a minuto

| Bloque | Tiempo | Dur. (s) | Función narrativa | Qué se ve |
|---|---|---|---|---|
| A. Gancho | 0:00–0:07 | 8 | Cita memorable ("Money cannot buy everything, but everything needs money"), presentación del equipo en 3 frases de 2 palabras ("Three people. One purpose.") | Presentador solo sobre fondo urbano/puerto al atardecer; a 0:05 los tres juntos; efecto "glitch" a 0:03 y flash blanco a 0:07 como transiciones |
| B. Título como pista | 0:08–0:14 | 7 | Invita a "seguir la historia en pantalla"; convierte el título en tesis: "Where you live matters" | Portada: logo ASA, título en caja roja, subtítulo, 10 banderas circulares ASEAN, rótulo "Erpan Maulana – The Leader of TRITICS", "Presented by TRITICS" |
| C. Por qué importa | 0:15–0:36 | 22 | Beneficios del crecimiento en la vida diaria (lista de 8 ítems) | Diapositiva "What improves with economic growth?" con 8 iconos blancos; a la derecha empieza a asomar "The DEADLINES" |
| D. Urgencia | 0:37–0:44 | 8 | Plazos: SDG 2030 y ASEAN Vision 2045 → "Growth must be accelerated, but how?" | Caja con logo SDG + logo ASEAN, línea de tiempo 2030 ····▶ 2045, icono de reloj de arena y triángulo de advertencia |
| E. Dato descriptivo | 0:45–0:57 | 13 | Hecho observable en los datos: agricultura se encoge, industria desigual | Gráfico de barras agrupadas (industria/agricultura, 2001 vs 2024, 10 países con bandera en el eje) |
| F. Preguntas | 0:58–1:13 | 16 | **Dos preguntas literales**, numeradas por la voz ("two simple questions") y escritas en cursiva en pantalla | Texto en cursiva con palabras clave en azul/amarillo: "How do sector shares, sector dynamics, and macro-structural factors relate to economic growth in ASEAN countries?" / "How do these relationships vary across countries and over time?" |
| G. Promesa | 1:14–1:20 | 7 | "If we can answer with solid evidence, we can choose the right levers" | Banner naranja deslizante: "If **the evidence is solid** → The **right policy levers** can be picked." |
| H. Datos y variables | 1:21–1:36 | 16 | Fuente, cobertura y 4 familias de insumos | Logos World Bank Group / WDI / ASEAN "Countries' Data 2001–2024"; tabla de variables con códigos y lenguaje llano (ver §2.5) |
| I. Métodos | 1:37–2:06 | 30 | Modelos base (OLS, panel FE/RE) → GWPR; por qué la flexibilidad es esencial | Caja dorada "Geographically Weighted Panel Regression (GWPR)" + "in comparison with" + dos botones "OLS Regression" / "Panel Regression" |
| J. Resultado global | 2:07–2:32 | 26 | GWPR ajusta mucho mejor; el crecimiento "no sigue una sola regla" | "Models comparison by adj. R²" con medallas 1-2-3; mapa ASEAN verde/azul; "Industry significantly drives growth everywhere. Agriculture does so in only half of countries." |
| K. Resultados por variable | 2:33–3:11 | 39 | Industria (persistente), precios, comercio, participación laboral (+), desempleo (−), agricultura (−), ingreso (convergencia), estructura de edades (viento de cola) | Misma diapositiva; lista "Variables frequently* significant by country (*≥50 % of periods)" con banderas y códigos; zoom de cámara al presentador en 2:35–2:41 |
| L. Política por país | 3:12–4:17 | 66 | Seis palancas, cada una con países y acciones concretas | Matriz "Which growth levers should be pulled?": 6 franjas naranjas con icono + banderas con micro-etiquetas |
| M. Callback y cierre | 4:18–4:48 | 31 | Vuelve a la cita inicial; tesis en una frase ("The same lever will not move every economy"); "which lever to pull, in which country, and at which time"; llamada a la acción a ASEAN 2045 | Diapositiva de referencias (5 fuentes) con cielo azul y banderas reales; luego solo banderas al viento |
| N. Negro | 4:49–4:54 | 6 | — | — |

### 2.4 Reparto del tiempo por sección

| Sección | Segundos | % de 294 s |
|---|---|---|
| Apertura (gancho + equipo + título) | 15 | 5 % |
| Contexto, urgencia, dato descriptivo y preguntas (C–G) | 66 | 22 % |
| Datos y métodos (H–I) | 46 | 16 % |
| Resultados (J–K) | 65 | 22 % |
| Política pública (L) | 66 | 22 % |
| Cierre + callback + referencias (M) | 31 | 11 % |
| Negro final | 6 | 2 % |

Lectura: **≈44 % del vídeo es "qué significa y qué hacer" (resultados + política)** y solo 16 % es método. El método se explica en 30 s con una sola idea ("deja que cada coeficiente varíe por país y por año").

### 2.5 Inventario de gráficas y elementos visuales

| # | Tiempo | Elemento | Descripción detallada |
|---|---|---|---|
| V1 | 0:00–0:07 | Plano de presentadores | Fondo fotográfico (puerto/ciudad al atardecer, grúas, avión); 1 presentador y luego 3; transición con ruido ("glitch") a 0:03 y flash blanco a 0:07. |
| V2 | 0:08–0:14 | Portada | Caja degradada rojo-naranja con "WHERE YOU LIVE MATTERS" en blanco sobre tarjeta clara; subtítulo en mayúsculas cursivas; **10 banderas circulares** (Brunéi, Indonesia, Camboya, Laos, Myanmar, Malasia, Filipinas, Singapur, Tailandia, Vietnam); logo ASA arriba; motivo decorativo "/////". Rótulo de nombre y rol del presentador. |
| V3 | 0:15–0:36 | Lista de iconos | "What improves with economic growth?" + 8 iconos blancos (personas, cruz médica, grupo, balanza, maletín, infraestructura, cerebro, birrete) con texto en 2 líneas cada uno. Aparece progresivamente mientras se nombran. |
| V4 | 0:37–0:44 | Caja de plazos | "The DEADLINES ⌛" con logos SDG y ASEAN Community Vision 2045, línea punteada 2030 → 2045 y "⚠ Growth must be **accelerated**, but *how?*". |
| V5 | 0:45–0:57 | **Barras agrupadas** | Eje x: 10 banderas (SG, LA, PH, TH, VN, KH, MY, MM, BN, ID); eje y 0–60 (% del PIB). Por país 4 barras: industria 2001 (naranja), 2024 (naranja oscuro), agricultura 2001 (blanco), 2024 (gris). Leyenda con chips "2001 / 2024 – Industrial / Agriculture". Lecturas visibles: Brunéi industria ≈62 % y agricultura ≈1 %; Myanmar agricultura ≈57 % (2001) → ≈21 % (2024); Camboya ≈33 % → ≈16 %; Singapur agricultura ≈0. Texto superpuesto: "Let's pause and reflect on *the drivers of their growth* since *the early part of this century*." |
| V6 | 0:58–1:20 | Preguntas | Dos preguntas en cursiva grande con términos clave en azul claro ("sector shares", "sector dynamics", "macro-structural factors") y amarillo ("across countries and over time"). |
| V7 | 1:14–1:20 | Banner-promesa | Píldora naranja que entra deslizándose: "If **the evidence is solid** → The **right policy levers** can be picked." |
| V8 | 1:21–2:06 | Fuentes | Tres tarjetas: globo azul "WORLD BANK GROUP", tarjeta azul "World Development Indicators" (icono base de datos + bombilla), emblema ASEAN "ASEAN Countries' Data 2001–2024". |
| V9 | 1:21–2:06 | **Tabla de variables** | Fila dorada "DEPENDENT VARIABLES: Y – Gross domestic bruto (GDP) growth (%) – *How fast a country's real economy grows*" (sic, "bruto": indonesio). "INDEPENDENT VARIABLES" en 4 bloques rojo oscuro con icono: **P1** Agricultural Share (% GDP) *How large agriculture is*; **P2** Agricultural Output Growth (%) *How fast agriculture grows*; **I1** Industry Share (% GDP) *How large industry is*; **I2** Industrial Output Growth (%) *How fast industry grows*; **T1** Labor Force Participation Rate *How active the labor supply is*; **T2** Unemployment Rate *How much joblessness there is*; **K1** Inflation (GDP Deflator Growth) *How stable prices are*; **K2** Trade (% GDP) *How open the economy is*; **K3** GDP per Capita (Level of Development) *How developed the economy is*; **D1** Dependency Ratio *How heavy the non-working-age burden is*. **Cada variable lleva una glosa en lenguaje llano en cursiva**; los códigos se reutilizan después en el mapa. |
| V10 | 1:37–2:06 | Caja de modelos | "Geographically Weighted Panel Regression (GWPR)" en caja dorada; "in comparison with" en espaciado amplio; botones "OLS Regression" y "Panel Regression". |
| V11 | 2:07–3:11 | **Ranking de modelos** | "Models comparison by **adj. R²**": 🥇 GWPR **91.4 %** (píldora naranja grande), 🥈 OLS Regression 75.7 %, 🥉 Panel Regression 69.9 %. Jerarquía visual con medallas y tamaño. |
| V12 | 2:07–3:11 | **Mapa coroplético ASEAN** | Siluetas de los 10 países: verde = "Both (agri. & ind.)" significativos (Myanmar, Laos, Tailandia, Camboya, Singapur), azul = "Industry only" (Vietnam, Malasia, Indonesia, Filipinas, Brunéi). Pregunta-leyenda: "Which sector has a **significant effect** on economic growth?". Titular en dos colores: "Industry significantly drives growth everywhere." (azul) / "Agriculture does so in only half of countries." (verde). |
| V13 | 2:07–3:11 | **Lista bandera → códigos** | "Variables *frequently** significant by country" con chip "*≥50 % of periods": Myanmar P2, I2 · Vietnam I2, K1, D1 · Laos P1, I1, I2, K2, K3 · Brunéi+Indonesia I2 · Malasia+Filipinas I2, T1, T2 · Camboya+Singapur+Tailandia P2, I2, K1. Agrupan países con el mismo patrón para ahorrar espacio. |
| V14 | 3:12–4:17 | **Matriz de palancas** | "Which **growth levers** should be pulled?" 6 franjas naranjas con icono (fábrica, barco portacontenedores, engranaje/rayo, irrigación/cultivo, trabajadores, documentos/balanza/dinero): Productive industrialization & value-chain upgrading · Trade, logistics & connectivity · Reliable energy & price stability · Agriculture modernization & agro-processing (irrigation, seeds, post-harvest, cold chain, reserves) · Skills & labor-market alignment · Investment climate & regulatory certainty. Cada franja lleva banderas con micro-etiquetas de acción ("labor-intensive", "basic to simple manufacturing", "input-import frictions, customs", "inter-island ports", "land/rail corridors", "export certification fast-track", "energy/port reliability", "core inflation", "supply-side tools", "foreign exchange & imported inputs", "basic electricity", "food inflation", "electrical & electronics reskilling", "women/youth: demand-led TVET", "mid-career conversion", "upskilling for industrialization", "demographic bonus to factory productivity", "retooling", "export-import certainty", "labor-intensive FDI", "high-tech FDI"). Marca de agua tenue "26 OCTOBER 2025". Es la diapositiva más densa; la voz la recorre franja por franja (≈10 s por palanca). |
| V15 | 4:18–4:48 | Referencias | Fondo: cielo azul con banderas reales de ASEAN ondeando (foto/vídeo); 5 referencias (ASEAN 2025 Vision 2045; UN DESA 2015 The 17 Goals; Djuraidah 2020 monografía de regresión espacial, IPB Press; DFID 2008 *Growth: Building Jobs and Prosperity in Developing Countries*; World Bank 2025 WDI, 30 Oct). La referencia a la monografía es el único "respaldo" metodológico de GWPR. |

### 2.6 Iconos, banderas y mapas: cómo los usan

- **Banderas circulares** como identificador universal del país: en la portada (los 10), como etiquetas del eje x del gráfico de barras (sustituyen nombres), como viñetas en la lista de variables significativas y como "chips" en la matriz de palancas (agrupadas cuando varios países comparten acción). Nunca escriben el nombre del país junto a la bandera; asumen que el jurado las reconoce (riesgo para públicos no asiáticos; nosotros deberíamos añadir código ISO3 o nombre corto).
- **Mapa**: una sola vez, pero en el momento clave (resultado principal). Dos colores categóricos, leyenda formulada como pregunta, titular que interpreta el mapa. El mapa está detrás del presentador, que se desplaza para no taparlo.
- **Iconos de línea blancos** para beneficios y para variables; iconos ilustrados 3D/flat para palancas de política. Coherencia: un icono por concepto, repetido cuando el concepto vuelve.
- **Logos institucionales** (ASA, World Bank, WDI, ASEAN, SDG) para credibilidad.
- **Medallas 🥇🥈🥉** para el ranking de modelos: lectura instantánea sin saber qué es adj. R².

### 2.7 Estilo de lenguaje

- Frases cortas, verbo activo, segunda persona plural implícita ("we ask", "we use", "we fit").
- Técnica traducida al instante: "geographically weighted panel regression (GWPR), **which lets each coefficient vary by country and year**"; "pooled linear regression … **to obtain region-wide average effects**"; "adj. R²" solo aparece escrito, en voz dicen "fitting the data much better".
- Cada variable con una glosa de 5–7 palabras ("How open the economy is").
- Verbos de resultado prudentes en parte ("tend to coincide with", "can add") mezclados con lenguaje causal fuerte ("drives growth", "drags it down", "the right lever to pull") — ver debilidades.
- Estructura retórica clásica: gancho → por qué ahora → dato → 2 preguntas → promesa → método en 1 idea → resultado global → detalles → acción → callback.
- Muletillas memorables: "Where you live matters", "which lever to pull, in which country, and at which time", "turn evidence into action".

### 2.8 Producción

- **Subtítulos quemados**: fuente sans geométrica (tipo Poppins) en negrita blanca con contorno oscuro, centrados abajo (y≈630), 1–2 líneas, bloques de 4–9 palabras sincronizados con la voz. Muy legibles en móvil.
- **Tipografía de diapositivas**: misma familia; títulos en cursiva con palabras clave en color (naranja/amarillo/azul); mayúsculas solo en portada.
- **Paleta**: fondo negro/gris oscuro con degradados naranja-rojo; acentos dorado, azul claro y verde; blanco para texto. El cierre cambia a cielo azul (sensación de apertura/esperanza).
- **Composición**: presentador recortado (chroma) sobre la diapositiva, alternando lado izquierdo/derecho según dónde esté el contenido; la diapositiva "se corre" para dejarle sitio. Zoom-in de cámara en momentos de énfasis (2:35–2:41).
- **Animación**: entradas progresivas (iconos, barras, filas de la tabla de variables, banner-promesa deslizante), desplazamiento vertical de la tabla de variables, transiciones de barrido entre bloques (4:14–4:17), efecto glitch/flash al inicio. No hay gráficos animados "de datos" (ningún eje que se mueva); la animación señala, no analiza.
- **Narración**: tres presentadores rotando (rótulo con nombre y rol al aparecer), voz en inglés con subtítulos exactos; gestos con las manos hacia el contenido.
- **Referencias** en pantalla 30 s mientras se cierra: cumplen la regla sin "gastar" tiempo.

### 2.9 Fortalezas y debilidades (visión de jurado)

**Fortalezas**
1. Una tesis en 4 palabras ("Where you live matters") sostenida por el método (coeficientes que varían por lugar) y por el mapa.
2. Dos preguntas explícitas que se responden en el mismo orden.
3. Modelo simple → modelo rico, con una sola métrica comparativa (adj. R²) y medallas.
4. Resultado → acción país por país; el jurado de "viz" premió que *cada gráfica comunica un hallazgo*.
5. Vocabulario de códigos (P1, I2, K1…) definido una vez y reutilizado: economía de espacio.
6. Ritmo y producción de nivel profesional; subtítulos que hacen el vídeo accesible.

**Debilidades (oportunidades para nosotros)**
1. **Ninguna diapositiva de limitaciones ni de ética**: no hay incertidumbre, no hay intervalos, no se dice que n=10 países × 24 años, no se discute endogeneidad ni causalidad inversa (el crecimiento también mueve la industria). Un jurado de "Ethics" no tendría nada que premiar.
2. **Lenguaje causal** ("drives", "drags it down", "lever to pull") sobre un modelo correlacional.
3. **Comparación por adj. R²** entre un modelo con coeficientes locales (GWPR, muchos más parámetros efectivos) y OLS/panel es sesgada a favor del modelo flexible; no hay validación cruzada ni AIC/BIC ni test de no-estacionariedad espacial.
4. "Significativo en ≥50 % de los periodos" es un criterio ad hoc; no se muestran coeficientes ni signos (dicen que "el signo cambia" pero nunca lo enseñan).
5. Las recomendaciones de política son muy específicas (cold chains, permits) y **no se derivan visiblemente de los datos**: salto de "I2 significativo" a "arancel de exportación fast-track".
6. Densidad excesiva de la matriz de palancas (≈60 micro-etiquetas) — ilegible a resolución de vídeo; funciona como "textura", no como información.
7. Banderas sin nombre; errata "Gross domestic bruto".
8. Solo una referencia metodológica (monografía indonesia) para un método poco estándar.

---

## 3. QuantaQuartet — "Reclaiming Childhood: Unearthing the Roots of Child Labor"

### 3.1 Ficha

- Hacettepe University (Türkiye), Departamento de Estadística. Miembros y roles (README): Ahmed Önder Akkaya (diseño y presentación), Atasagun Yılmaz (gestión), Taner Yeşilay (análisis, modelado y pipeline), Tuana Çerçive (análisis y visualización de apoyo).
- Vídeo: <https://www.youtube.com/watch?v=-r9DeI_vplI> (hoy devuelve 403 en oEmbed/noembed: privado o no listado). Repositorio: <https://github.com/TanerYSLY/ASA-child-labor-data-analysis> (Python; notebooks `01_04_combined_analysis`, `02_regression`, `03_reg2`, `03_reg3`, `04_Clustering`; tres CSV: `analyze data.csv`, `asa_under14_dataset.csv`, `clustering_data.csv`; 8 figuras incl. mapas HTML interactivos; `requirements.txt`).
- Datos: "Competition Dataset" + ILOSTAT *Children in Employment by Sex and Age (by thousands)*; se restringen a países con encuestas y a datos **posteriores a 2010** ("our baseline year").
- Premios: internacional **Best Statistical Insight**; nacional 1.º Insight, 2.º Viz, 3.º Ética.

### 3.2 Estructura del archivo de diapositivas (20 páginas)

| Pág. | Contenido | Observaciones |
|---|---|---|
| 1 | **Portada**: "RECLAIMING CHILDHOOD – Unearthing the Roots of Child Labor"; 4 nombres con correos institucionales; dibujo de cometa y de niños armando un rompecabezas; logo "QuantaQuartet". | Tipografía display condensada en negro sobre blanco; estética "cuaderno infantil". |
| 2 | **Diapositiva 1 – Motivación y mapa**: "Figure 6: Global log(Child Employment Rate) – Latest Available Data by Country" (coroplético YlOrRd, escala log 1–3, África central/occidental en rojo oscuro). Texto: por qué el trabajo infantil "has not received the attention it deserves"; **aviso de cobertura**: "our dataset only includes countries where surveys were conducted and covers data collected *after* 2010"; "child labor remains a persistent and unresolved problem, particularly concentrated in the African region". | Layout 50/50 figura-texto con línea vertical negra. Caveat de datos en la primera diapositiva (ética). |
| 3 | **Diapositiva 2 – Calidad y disponibilidad de datos**: "Figure 1B: Variable-Wise Missing Data Overview" (barras horizontales: Primary School Enrollment 15,5 %, Private Consumption per Capita 13,1 %, Rural Electricity Access 6,0 %, Government Effectiveness 4,8 %, Control of Corruption 4,6 %, Rule of Law 4,6 %, Mobile Subscriptions 3,3 %, Child Mortality 2,6 %, Life Expectancy 2,6 %, Income Group 2,4 %, …; las de ILO en 0 %). Abajo: serie temporal de la tasa de empleo infantil 2010–2024 con fases sombreadas y barras de cambio anual; "Figure 1A: Yearly Data Availability Overview" (área: observaciones por año 1990–2025, línea "Baseline Year: 2010" y "Drop in Number of Observations (2022)"). Texto: las encuestas crecen tras 2010, pico ≈2020 y caída; "not because the problem was solved, but because global priorities have shifted to economic crises, the COVID-19 pandemic…". | Dedican una diapositiva entera (25 % del contenido) a *qué datos faltan y por qué*. Es la base del premio de "insight" y del 3.º en ética. |
| 4 | **Diapositiva 3 – Ingreso y distribución**: matriz 4×4 "Post-hoc p-values" (High/Low/Lower-middle/Upper-middle; rojo = p≈0,000–0,001; azul = **0,253** entre High y Upper-middle); "Figure 4B: Distribution by Income Groups" (violines: Low hasta ≈35 %, Lower-middle cola larga hasta ≈50 %, Upper-middle hasta ≈30 % pero masa <10 %, High ≈<12 %). Texto: "This pattern implies a **nonlinear decline**: most of the reduction in child labor happens as countries move from low to middle income, with diminishing returns afterward." Cuatro etiquetas evocadoras: *Low Income \| Broken Symmetry*, *Lower Middle Income \| The Transition Zone*, *Upper Middle Income \| Fading Echoes*, *High Income \| The Bimodal Paradox* ("a small second peak reveals *invisible* children — migrants and refugee children are still working"). | Insight principal: la relación ingreso–trabajo infantil no es lineal. Nombres narrativos para los grupos = memorabilidad. |
| 5 | **Diapositiva 4 – Clústeres**: mapa mundial "COUNTRY CLUSTERS: CHILD EMPLOYMENT AND DEVELOPMENT INDICATORS – K-Means Clustering (k=2) – 78 Countries". Cluster 0 "Developing" (35 países; rojo): esperanza de vida ≈61,2 años, 35,1 % urbano, agricultura 23,4 %, electricidad 32,0 %, empleo infantil 2,51 (log). Cluster 1 "Developed" (43; verde): 72,3 años, 58,9 % urbano, 9,9 % agricultura, 92,2 % electricidad, 1,60 (log). Frase final: "Where electricity, education, and urban life expand, child labor fades. **The divide on this map is not geographic — it's developmental.**" | Mapa con cajas de estadísticas por clúster dentro del propio gráfico. |
| 6 | **References & Closure**: datasets (concurso + ILOSTAT, URL); enlace al repo; "Due to Competition Rules, the link provided above will be available after the deadline… The repo will be turned from private to public after 31/10/2025 23:59 (Türkiye Time)". | Reproducibilidad declarada y respeto a las reglas. |
| 7–20 | **"Technical Presentation"** (apéndice): Fig-1 mediana por país + términos de interacción (gobernanza×PIB, urbano×agricultura, educación×gobernanza); Fig-2 n=58, p=13, n/p=4,46 ("ideal >10"), VIF catastróficos (governance_index 209, governance_x_gdp 138, education_x_governance 119, log_gdp_pc 17, private_consumption 12,6, …); Ridge/Lasso/ElasticNet/Polynomial Ridge "instead of classical regression (OLS)"; Fig-3 Lasso selecciona 4 variables (agriculture_value_added_pct, life_expectancy, urban_population_pct, rural_electricity_access), CV R² reducido 0,2886; Fig-4 re-filtrado; Fig-5 n=78, p=4, n/p=19,5, VIF 3,64/2,99/2,51/1,80; Fig-6 CV 5-fold: Ridge train R² 0,394 / **CV R² 0,153** / RMSE 0,740; ElasticNet 0,399/0,146; Lasso 0,405/0,119; OLS 0,405/0,116; Poly Ridge 0,417/0,053 — todos marcados "Overfitting: High"; Fig-7 α óptimo 40,37; Fig-8 coeficientes estandarizados: life_expectancy ≈−0,17, rural_electricity_access ≈−0,16, agriculture_value_added_pct ≈+0,14, urban_population_pct ≈−0,08; "Suggestions for Sustainable Development": "child labour is mainly driven by low health, weak infrastructure, agricultural dependence… rooted in governance and development inequality"; Clustering: codo + silueta (k=2 silueta ≈0,45, cae a ≈0,25 en k=8); K-means k=2 `random_state=42`, 35/43; ANOVA de una vía por variable entre clústeres (F=86,2 agricultura; 117,1 esperanza de vida; 42,7 urbano; 141,3 electricidad; p=0,0000). | Capturas de código y consola sobre fondo blanco: funcionan como "prueba de trabajo" pero no son material de vídeo. |

### 3.3 Gráficas (inventario)

| # | Tipo | Variables | Paleta/anotación |
|---|---|---|---|
| Q1 | Coroplético mundial | log(tasa de empleo infantil), último dato por país | YlOrRd secuencial, barra de color horizontal 1–3; proyección Robinson; sin etiquetas de país |
| Q2 | Barras horizontales | % de datos faltantes por variable (22 variables) | Verde; las 2 peores en naranja con valor; ordenado desc. |
| Q3 | Línea + área | Observaciones por año 1990–2025 | Línea de referencia 2010 (baseline) y 2022 (caída) |
| Q4 | Línea y barras pequeñas | Tasa de empleo infantil 2010–2024 y cambio anual | Fases sombreadas (rojo/verde/amarillo) |
| Q5 | Matriz de p-valores | 4 grupos de ingreso (post-hoc) | Rojo significativo / azul no significativo, valores impresos |
| Q6 | Violines | Tasa por grupo de ingreso | Rojo, naranja, amarillo, verde (semáforo invertido) |
| Q7 | Mapa de clústeres | K-means k=2 | Rojo/verde con cajas de estadísticas de cada clúster |
| Q8 | Barras divergentes | Coeficientes Ridge estandarizados | Rojo (negativo) / verde (positivo) |
| Q9 | Línea doble eje | Codo (SSE) y silueta vs k | Azul/rojo |

### 3.4 Métodos y cómo los cuentan

- Secuencia: mediana por país (para "reduce outlier effects") → VIF → regularización → Lasso para selección → re-ajuste con 4 variables → comparación CV → Ridge → coeficientes → K-means → ANOVA.
- Cada paso lleva **una frase de propósito en lenguaje llano** ("Here, we used the median value per country to capture each nation's typical situation") y la salida de consola como evidencia.
- Reportan honestamente que el CV R² es 0,153 y que todos los modelos muestran "Overfitting: High" — no lo esconden, aunque tampoco lo discuten.

### 3.5 Ética y datos faltantes (por qué fueron 3.º en ética y 1.º en insight)

- Caveat de cobertura en la **primera** diapositiva (países con encuestas, después de 2010).
- Una diapositiva completa de datos faltantes y disponibilidad temporal, con interpretación social (la caída de observaciones "no es porque el problema se resolvió").
- Atención a grupos invisibles ("migrants and refugee children") y a lo que las medias ocultan ("rural or informal sectors hide residual exploitation").
- README: "child labor is a sensitive topic. Results and visualizations should be interpreted responsibly and in context."
- Repo público tras el plazo "Due to Competition Rules".
- Lo que **no** hicieron: citar las ASA Ethical Guidelines, separar exploratorio/confirmatorio, discutir el riesgo de estigmatizar países/regiones con el mapa rojo, o advertir sobre la circularidad del ANOVA.

### 3.6 Fortalezas y debilidades

**Fortalezas**
1. Pregunta social relevante y un *insight* no trivial y bien formulado (descenso no lineal con rendimientos decrecientes; bimodalidad en países ricos).
2. Honestidad numérica: VIF, n/p, CV R², overfitting, todo a la vista.
3. Nombres narrativos de grupos ("Broken Symmetry", "Fading Echoes") que los jurados recuerdan.
4. Cumplen exactamente 4 diapositivas de contenido y aportan reproducibilidad (GitHub).

**Debilidades**
1. **ANOVA sobre clústeres K-means usando las mismas variables que formaron los clústeres** (circular: siempre sale significativo).
2. **Lenguaje causal** ("child labour is mainly driven by…") con un modelo cuyo CV R² es 0,15 y n=78.
3. Inconsistencias de muestra entre figuras (n=58 → n=78; CV R² 0,289 en Fig-3 vs 0,153 en Fig-6) sin explicación.
4. Diapositivas de texto denso en tipografía pequeña; capturas de consola como "figuras"; estética poco cuidada frente a TRITICS (de ahí 2.º en viz).
5. El mapa rojo sobre África sin contexto de incertidumbre puede leerse como estigmatizante.
6. Vídeo hoy inaccesible (privado): pierde valor de referencia.

---

## 4. Glorystician (Best Consideration of Ethics) — lo que se sabe

No se encontró vídeo, diapositivas ni repositorio públicos (búsquedas en YouTube, GitHub, LinkedIn y prensa). Datos verificados: equipo de 2 estudiantes de ULM (Muhammad Radityo Denishworo Marsudi, Dwi Annisa Febriyanti), asesor Samsul Arifin; ganó "Best 1 – Consideration of Ethics" nacional (Indonesia) e internacional. ULM también fue 2.º y 3.º nacional en ética con el mismo asesor, lo que sugiere un enfoque sistemático de la universidad en "ethics aspect per ASA standards". **Implicación:** el premio de ética se gana con una sección explícita y estructurada que cite las *ASA Ethical Guidelines* (integridad de datos y métodos, transparencia, limitaciones, impacto en grupos, confidencialidad, reproducibilidad), no con menciones de pasada.

---

## 5. Comparación: qué premió el jurado y por qué

| Criterio | TRITICS (ganó Viz) | QuantaQuartet (ganó Insight) |
|---|---|---|
| Lo que el jurado vio primero | Producción cinematográfica, mapa, banderas, matriz de política: "most effective graphics communicating findings" | Caveats de datos + hallazgo no lineal + modelo validado: "most compelling statistical insight" |
| Preguntas | 2 literales | Motivación general; hallazgos por bloque |
| Modelo base vs rico | Sí (OLS/panel → GWPR) | Sí (OLS → Ridge/Lasso; k según silueta) |
| Validación | adj. R² (sesgada) | CV 5-fold, VIF, n/p (honesta pero resultado pobre) |
| Heterogeneidad | Por país y año (mapa + lista) | Por grupo de ingreso (violines) y clúster (mapa) |
| Política pública | 6 palancas × país | 3 "drivers" + frase de cierre |
| Ética | Ausente | Implícita (datos faltantes, invisibles) |
| Reproducibilidad | No mencionada | GitHub público tras el plazo |
| Fallos estadísticos | Causalidad, comparación de ajuste sesgada, sin incertidumbre | ANOVA circular, causalidad con CV R² 0,15, inconsistencias n |
| Diseño | Paleta y tipografía coherentes, animación que señala | Texto denso, capturas de consola |

**Lectura del jurado:** premian (a) una historia clara con preguntas explícitas; (b) que el método se *entienda* en una frase; (c) que la gráfica central interprete (titular + leyenda-pregunta); (d) una conclusión accionable. Toleran fallos estadísticos si la narrativa es sólida — **pero un vídeo que además evite esos fallos y haga la ética visible puede competir en las tres categorías a la vez**, cosa que ninguno de los dos logró.

---

## 6. Receta para superarlos en 2026 (lista priorizada y accionable)

Prioridad ★★★ = imprescindible; ★★ = alto impacto; ★ = diferenciador.

1. ★★★ **Una tesis de ≤5 palabras** que el método demuestre y el mapa muestre (equivalente de "Where you live matters"). Para P7/P8, candidatos: "No single number tells the story" / "Three forces, one trajectory" / "Where you are born still decides". Debe aparecer en el título, a los 0:12 y en el callback final.
2. ★★★ **Dos preguntas literales en pantalla** (P7 y P8 reformuladas en lenguaje llano), numeradas, y responderlas en el mismo orden con una diapositiva/gráfica cada una. Añadir P1/P4/P5/P6 solo como "evidencia de apoyo" dentro de esas dos respuestas.
3. ★★★ **Modelo simple → modelo rico, con una comparación justa**: p. ej. correlaciones fecundidad–mortalidad–migración globales (simple) → mismas relaciones por región/ingreso y por década (rico: slopes por grupo, o clústeres de *trayectorias* 1950–2023). Comparar con una métrica honesta (R² *fuera de muestra*, AIC o IC bootstrap), nunca solo adj. R² entre modelos de distinta complejidad.
4. ★★★ **Mapa coroplético mundial en el resultado principal**, dos a cuatro categorías, leyenda en forma de pregunta y titular que interpreta ("Fertility fell everywhere; migration decides who still grows"). Añadir nombre o ISO3 a las banderas/países citados.
5. ★★★ **Gráfica = hallazgo**: cada gráfica con un titular de una línea en lenguaje llano, ≤3 colores con significado, anotaciones directas sobre los datos (no leyendas lejanas). Máximo 5–6 gráficas en todo el vídeo.
6. ★★★ **Ética explícita y citada** (20–30 s + un recuadro en una diapositiva): "Following the ASA Ethical Guidelines (2022) we…": (i) proveniencia y licencia UN WPP 2024; (ii) **estimaciones 1950–2023 vs proyecciones 2024–2100 (proyecciones ≠ predicciones; variante Medium)**; (iii) agregados excluidos del análisis país (evita doble conteo); (iv) migración neta = dato más incierto y políticamente sensible, evitar señalar países; (v) sin afirmaciones causales: "associated with", "co-moves with"; (vi) resultados exploratorios etiquetados; (vii) código y datos reproducibles desde el día 1 (no "after the deadline").
7. ★★★ **Lenguaje llano con glosa**: cada indicador con su "qué significa" de 5–7 palabras (TFR = "children per woman", life expectancy = "years a newborn can expect", net migration rate = "people arriving minus leaving per 1 000"). Definir códigos una sola vez si se usan.
8. ★★ **Incertidumbre visible al menos una vez**: bandas (p. ej. rango entre variantes Low/High para 2–3 países emblemáticos, o IC bootstrap de la pendiente por región). Ningún ganador 2025 lo hizo; es un diferenciador para Insight y Ética.
9. ★★ **Traducir en "qué palanca, en qué región, en qué momento"** para la ONU/gobiernos (matriz 3×3: región × fuerza dominante × horizonte 2030/2050/2100), pero con ≤12 celdas legibles y derivadas visiblemente de la gráfica anterior (evitar el salto de TRITICS a recomendaciones no sustentadas).
10. ★★ **Animación que señala, no que decora**: construir la gráfica por capas sincronizadas con la voz (aparece la región que se menciona, se atenúa el resto); un solo gráfico "en movimiento" de datos (p. ej. trayectoria TFR vs e0 1950→2100 por región con rastro) usado una vez como momento memorable. Herramientas R: `gganimate`, `plotly`, `echarts4r`; exportar MP4/GIF y componer en el editor de vídeo.
11. ★★ **Ritmo**: ≈120 palabras/min, oraciones de ≤18 palabras, 2–3 s de "aire" tras cada cifra; guion de ≈580–600 palabras para 4:50.
12. ★★ **Subtítulos quemados** (fuente sans bold con contorno, bloques de 4–9 palabras) y rótulos de nombre al aparecer cada presentador.
13. ★★ **Portada con banderas/iconos de los casos de estudio y logos de fuentes** (UN DESA, WPP 2024, ASA); referencias en la última diapositiva *mientras* se cierra con el callback (como TRITICS) para no gastar tiempo.
14. ★★ **Una diapositiva entera de datos**: cobertura (236 países, 1950–2101, 65 indicadores), qué se excluye (agregados, variantes), qué falta y por qué (como QuantaQuartet) — pero en formato visual (mini-mapa de cobertura o barras), no texto.
15. ★ **Casos-país como "personajes"**: 3–4 países con bandera e ISO3 que ilustran cada combinación (p. ej. Níger: alta fecundidad; Japón: envejecimiento sin migración; Emiratos/Qatar: migración domina; Colombia: transición con emigración/inmigración venezolana). Volver a ellos en cada gráfica.
16. ★ **Nombres narrativos para los grupos/clústeres** ("Fading Echoes" funcionó): p. ej. "Young & growing", "Ageing by choice", "Migration-dependent", "Shrinking fast", definidos por reglas visibles.
17. ★ **Separar exploratorio de confirmatorio**: una frase ("these patterns are descriptive; we do not claim causes") protege ante el jurado estadístico.
18. ★ **Evitar análisis circulares**: no testar diferencias entre clústeres con las variables que los definieron; si se hace clustering, validar con variables *externas* (p. ej. ingreso del Banco Mundial) o con estabilidad bootstrap.
19. ★ **Entregar exactamente 6 diapositivas** (portada + 4 + referencias); nada de apéndices técnicos en el PDF enviado (riesgo de incumplir "at most 4 slides"); el detalle va al repo con un README en inglés y notebook reproducible.
20. ★ **Cierre con callback + llamada a la acción a la ONU/ODS** en 15–20 s y terminar a 4:50–4:58, sin negro largo.

### 6.1 Plantilla de guion de 5 minutos (tiempos basados en lo que funcionó)

| Tiempo | Dur. | Sección | Contenido del guion (inglés) | Pantalla |
|---|---|---|---|---|
| 0:00–0:12 | 12 s | Gancho | Cita o cifra impactante de WPP 2024 (p. ej. "In 1950 a woman had five children on average; today 2.2; by 2100, 1.8." o "Half of all population growth to 2050 will happen in just eight countries"). "We are [team]. Three people, one question." | Presentador sobre fondo; dato en grande |
| 0:12–0:25 | 13 s | Título-tesis | "Take the title as a hint: *No single number tells the story*." | Portada: título, banderas de 4 países-personaje, logos UN DESA/ASA |
| 0:25–0:55 | 30 s | Por qué importa + urgencia | Qué cambia con fecundidad, mortalidad y migración (pensiones, escuelas, salud, ciudades); plazos ODS 2030 y "2050: 1 de cada 6 personas >65" (verificar cifra en el notebook) | Iconos + línea de tiempo 2030→2050→2100 |
| 0:55–1:20 | 25 s | Dato descriptivo + 2 preguntas | Una gráfica que muestre el hecho (p. ej. TFR cae en todas las regiones pero a ritmos distintos). "So we ask two simple questions: (1) How do fertility, mortality and migration move together — and does that change by region, country and income? (2) Is there one indicator that tells the whole story, or do we only see it when we look at all three?" | Gráfica descriptiva animada por regiones; luego las 2 preguntas en texto |
| 1:20–1:50 | 30 s | Datos + ética de datos | "UN WPP 2024, Medium variant, 236 countries, 1950–2023 estimates and 2024–2100 projections — projections are scenarios, not predictions. We drop aggregates to avoid double counting and treat net migration as the most uncertain input." | Diapositiva de datos: cobertura, exclusiones, glosa de 3 indicadores con iconos |
| 1:50–2:20 | 30 s | Método en una idea | "First a simple view: one correlation for the world. Then a richer one: we let the relationship differ by region, income level and decade, and we group countries by how their whole 1950–2023 path moved, not by one year." | Esquema simple → rico; 2 botones; métrica de comparación honesta |
| 2:20–3:10 | 50 s | Resultado P7 | Mapa mundial + 3–4 países-personaje; titular interpretativo; "the sign of the migration–growth link flips between high- and low-income countries" (si los datos lo respaldan) | Mapa coroplético + mini-trayectorias; capas que aparecen al nombrarlas |
| 3:10–3:50 | 40 s | Resultado P8 | "One indicator explains X % of the variation in 2050 growth; the three together explain Y %; and in these N countries the single indicator gets the direction wrong." | Gráfica de comparación (barras con IC) + ejemplos con bandera |
| 3:50–4:20 | 30 s | Qué hacer (ONU/gobiernos) | Matriz región × fuerza dominante × horizonte, 9 celdas, derivada del mapa | Matriz con iconos; una franja se ilumina por vez |
| 4:20–4:40 | 20 s | Ética y límites | "Following the ASA Ethical Guidelines: our findings are descriptive, not causal; projections carry uncertainty (show band); migration data are revised often; code and data are public today at [repo]." | Recuadro de ética + banda de incertidumbre + QR/URL del repo |
| 4:40–4:55 | 15 s | Callback y cierre | Volver a la cita inicial; "No single number tells the story — but together they tell the UN where to look first." Llamada a la acción. | Referencias en pantalla con fondo abierto; banderas |

Total 4:55. Guion objetivo: 580–600 palabras.

---

## 7. Riesgos y errores a evitar (vistos en los ganadores o penalizables)

1. **Afirmaciones causales** con datos observacionales ("drives", "mainly driven by", "lever to pull"). Usar "is associated with", "co-moves", "countries with X tend to…".
2. **Comparar modelos con adj. R²** cuando uno tiene muchos más parámetros efectivos (GWPR vs OLS); usar validación fuera de muestra o criterios de información, y decirlo.
3. **Análisis circulares**: ANOVA/tests sobre clústeres con las variables que los definieron; "significativo en ≥50 % de periodos" sin corrección por comparaciones múltiples.
4. **Modelos con R² de validación ínfimo presentados como "drivers"** (CV R² 0,15). Si el ajuste es bajo, decirlo y reencuadrar como exploratorio.
5. **Inconsistencias numéricas entre diapositivas** (n=58 vs 78; CV R² 0,289 vs 0,153). Revisar cada cifra contra el notebook (regla de memoria "review-every-output").
6. **Sin limitaciones, sin incertidumbre, sin ética**: descarta de entrada el premio de ética y resta credibilidad en insight.
7. **Superar las 4 diapositivas de contenido** (apéndices técnicos dentro del PDF) o pasar de 5:00.
8. **Densidad ilegible** (≈60 micro-etiquetas en una matriz; texto de 10 pt; capturas de consola como figuras).
9. **Banderas sin nombre** y jerga local/erratas ("Gross domestic bruto") en un jurado internacional.
10. **Mapas que estigmatizan** (África en rojo intenso) sin contexto ni incertidumbre; cuidado especial con migración neta y con países pequeños/territorios (D. ASA: impacto en grupos).
11. **Mezclar agregados con países** en el análisis (infla totales; repo turco 2026 lo cuantifica en ≈44,8×).
12. **Tratar proyecciones 2024–2100 como datos observados**; siempre marcar la frontera 2023/2024 en los ejes.
13. **Repo "privado hasta después del plazo"**: pierde el valor de reproducibilidad ante el jurado; publicar antes de enviar.
14. **Recomendaciones de política no derivadas de los resultados** (salto de "I2 significativo" a "cold chains"); cada recomendación debe señalar la gráfica que la sustenta.
15. **Depender de un único trabajo metodológico oscuro** para justificar el método; citar 2–3 referencias estándar (p. ej. manuales de demografía de la ONU, Lee–Carter, documentación WPP).
16. **Guion de más de 130 palabras/min** o frases de >20 palabras: los subtítulos no caben y el jurado no procesa la gráfica.
17. **Animación decorativa** (glitches, barridos) sin función; reservar el movimiento para señalar datos.
18. **No ensayar la ronda nacional**: en 2026 Colombia compite primero a nivel nacional; adaptar el vídeo a un jurado local sin perder el estándar internacional.

---

## 8. Anexos

### 8.1 Archivos generados

- `RepoGithub/docs/01_analisis_ganadores_2025.md` (este documento).
- `RepoGithub/docs/referencia_ganadores/frames_tritics/`: 21 fotogramas clave nombrados por contenido y tiempo (`00_gancho_money_cannot_buy_t0m00s.jpg` … `20_cierre_banderas_2045_t4m45s.jpg`) y 7 hojas de contacto 3×3 (`hoja_contacto_s00_000s.jpg` … `s06_270s.jpg`, una cada 45 s). Todos ≤ 300 KB.
- `RepoGithub/docs/referencia_ganadores/frames_quantaquartet/`: 15 diapositivas (6 del cuerpo + 9 del apéndice técnico), nombradas por contenido.
- Material intermedio en el scratchpad de la sesión (294 fotogramas, 20 mosaicos de subtítulos, 7 hojas de contacto, `tritics_script.txt`).

### 8.2 Fuentes consultadas

- FAQ oficial: <https://american-statistical-association.github.io/CIRSDataQuest/faq.html>
- Página principal y ganadores: <https://american-statistical-association.github.io/CIRSDataQuest/> · <https://american-statistical-association.github.io/CIRSDataQuest/winners.html> · repo <https://github.com/American-Statistical-Association/CIRSDataQuest>
- Comunidad ASA: <https://community.amstat.org/committeeoninternationalrelationsinstatistics/events2/data-quest>
- ASA Ethical Guidelines (2022): <https://www.amstat.org/your-career/ethical-guidelines-for-statistical-practice>
- Vídeo TRITICS: <https://www.youtube.com/watch?v=0Cr-FDzE3U4>
- Prensa ULM (Indonesia): <https://ulm.ac.id/id/2025/11/20/mahasiswa-ulm-raih-prestasi-di-asa-data-quest-competition-2025-dan-melaju-ke-tingkat-internasional/> · <https://teras7.com/raih-penghargaan-asa-international-data-quest-competition-2025-mahasiswa-ulm-melaju-ke-tingkat-internasional/>
- Prensa UNM (Indonesia, top 3 nacional): <https://statistika.fmipa.unm.ac.id/2025/11/15/international-data-quest-competition-2025-mahasiswa-statistika-fmipa-unm-masuk-tiga-terbaik-nasional/> (no accesible por TLS en esta sesión)
- Hacettepe (Türkiye): <https://stat.hacettepe.edu.tr/tr/asa_data_quest_2025te_ogrencil-1212>
- Repo QuantaQuartet: <https://github.com/TanerYSLY/ASA-child-labor-data-analysis> · vídeo <https://www.youtube.com/watch?v=-r9DeI_vplI> (403 hoy)
- Otros participantes: SSO 2025 <https://github.com/StyNW7/ASA-International-Data-Quest-2025>; Team Ipanema 2026 <https://github.com/carvguilherme8/demographic-globe>; <https://github.com/busahinku/asa_dataquest>

### 6.2 Ajustes a la receta tras ver a otros equipos (2026-10-22; detalle en `01b_otros_equipos_2025_2026.md`)

Revisados seis repositorios más (tres participantes de 2025 y tres competidores de 2026 con WPP2024: `yguzmanm-sys` Colombia, `idiltuzkaya` Türkiye, `ahzasasa` Indonesia). El más fuerte, `ahzasasa` (Universitas Diponegoro), tiene un plan de análisis bloqueado con hash, clustering de trayectorias con bootstrap y rejilla de 16 sensibilidades, fan charts 80/95 % y un deck de 6 páginas con ética en cada pie — pero **no trata la migración ni el ingreso** (P4/P7) ni da recomendaciones. Ajustes a la receta de §6:

1. **Añadir (prioridad ★★★):** plan de análisis bloqueado con fecha y sha256 + addendum fechado + etiqueta "post hoc" visible (ASA B.3); estabilidad por país (bootstrap) con rayado en el mapa de grupos y lista de países frontera; una sola figura de sensibilidad (métodos × muestras × variables) con un número en la franja de ética.
2. **Subir de apéndice a pantalla (★★):** fan charts 80/95 % de OtherVariants para dos países-personaje ("ranges, not points"); frontera 2023/24 cuantificada (100 % de proyecciones monótonas vs 0,4 % observadas).
3. **Fortalecer P7 (★★):** correlaciones *within* (dentro del país) además de *between*, por grupo de ingreso; gráfica "% de países donde la migración pesa más que el saldo natural" por región (Europa 70 % en 2023).
4. **Blindar el rezago mortalidad → fecundidad (★★):** mostrar tres pares de umbrales (11, 2 y ~19 años); la frase es sobre el orden, no sobre la magnitud.
5. **Franja de ética como tarjeta de 5 ítems (★★):** *Scenarios, not forecasts · Modelled, uneven data · Patterns, not causes · Groups describe behaviour, not merit · Levers, not verdicts* (migración positiva no es "éxito"; mortalidad alta no es etiqueta; "África" son 48 caminos) + "237 countries and areas (195 states + 42 territories)" + CV además de DE para la divergencia de LE60.
6. **Mantener como territorio exclusivo (★★★):** migración como tercera palanca con grupos de ingreso del Banco Mundial, respuesta literal a P7 y P8 (escalera de R², gemelos, CDR que cambia de significado, fragilidad del índice), nombres de grupo por comportamiento incl. "Migration-boosted", matriz "which lever, where, when", gancho + callback + animación que señala.
7. **Evitar parecidos (★):** no usar "converge", "pathways" ni "corridor" en títulos; eje x = child deaths (no LEx) en la dispersión conectada; el primer mapa del vídeo es el de palancas, no el de clústeres; el gancho "130 países bajo reemplazo" lo dirán todos — nuestro giro es "79 siguen creciendo, 18 solo por inmigración".
8. **Repositorio:** privado hasta la mañana del 30-oct (rival colombiano en la misma ronda), público antes de enviar; portada sin marcadores (`{clave}`, "[Team]") — lección del "Lorem Ipsum" de `ahzasasa`.
9. **Nota sobre criterios:** el roadmap interno de `ahzasasa` afirma pesos Viz 35 / Ética 30 / Insight 35 con sub-criterios y "tres jueces externos, hasta ocho equipos por juez". **No está en la web de la ASA; tratar como no verificado**, pero refuerza: gancho en ≤ 12 s, un mensaje por gráfica, ética ≥ 20 s.
