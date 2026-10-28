# Cuatro vídeos más del ASA DataQuest 2025: cómo hacen visible la técnica estadística

**Propósito.** Estudiar cuatro vídeos de participantes de 2025 que aportó el usuario y sacar lecciones para nuestro deck y nuestro vídeo. La prioridad del usuario es que **se note qué técnicas estadísticas usamos** (PCA, k-means, etc., en negrita). Las otras preguntas son: qué hicieron, con qué datos, cómo lo cuentan, qué hicieron con la ética y qué nos llevaríamos.

**Fecha:** 2026-10-27. **Autor:** agente `referencias-2025-extra` (IA, Claude Code), en modo solo lectura. Este archivo es lo único que escribió. **Estado del repositorio revisado:** `HEAD` = `5ec1bd6`, un commit por delante de la etiqueta `submission-2026-10-30-rc1` (`c367937`). El deck es `slides/export/slides.pdf` (6 páginas, miradas una a una), con `slides/index.html` y `slides/script/narration_en.md` (v4).

**Cómo se revisó (sin descargar ningún vídeo):**
- Se buscaron los cuatro títulos en el buscador de YouTube. Para cada uno se leyó la página del vídeo: título, canal, fecha, duración, vistas y descripción.
- La **transcripción** se leyó en el panel *Show transcript* del propio YouTube. Son subtítulos automáticos y tienen errores de reconocimiento, como "PTIB plot" por *PCA biplot* o "laser regression" por *LASSO regression*.
- Se usaron los **storyboards públicos** del reproductor (miniaturas cada 2 s, 320×180) para reconstruir la secuencia de diapositivas con sus tiempos.
- Se tomaron **capturas puntuales del reproductor en pausa** (720p/1080p) para leer los textos pequeños de 2 o 3 diapositivas por vídeo: métodos, resultados y el recuadro de ética.
- Las citas de la voz están parafraseadas. Las etiquetas de las diapositivas se copian tal cual porque son rótulos cortos.
- Las miniaturas y los recortes quedaron en el scratchpad de la sesión (`yt2025/mont/`, `yt2025/crop/`). No se añadieron al repositorio.

**Corrección a un documento anterior.** `docs/01_analisis_ganadores_2025.md` §0 y §4 dicen que de **Glorystician** (*Best Consideration of Ethics* 2025, ganador internacional) "no se encontró vídeo". **Ya está encontrado:** es el vídeo 4 de esta lista (<https://www.youtube.com/watch?v=pf8xyBvEc1Q>). Lo que dice §4 sobre cómo ganó la ética hay que leerlo junto con la §4.5 de este documento.

---

## 0. Resumen

| # | Vídeo (YouTube) | Equipo · país · universidad | Resultado conocido 2025 | Tema y datos | Técnica | Cómo la hacen visible | Ética visible | Duración |
|---|---|---|---|---|---|---|---|---|
| 1 | [4m-rB3pg7p4](https://www.youtube.com/watch?v=4m-rB3pg7p4) "Socioeconomic Drivers of Fertility Transitions in Indonesia and South Korea" | **Chartosaur Inferna** · Indonesia · ULM (Najla Khalisa, Fatma Rohilda, Aulia Naylan Muna, Nabila Soleha Friliyati) | Podio nacional de Ética, Indonesia (Best 2 o Best 3, según la prensa de ULM citada en `01` §1.3; no se verificó cuál) | Fecundidad de Indonesia frente a Corea del Sur. WDI 2014–2023, 10 predictores, **10 años por país** | **LASSO** + post-LASSO OLS; R², RMSE, VIF | Subtítulo de la portada: "…With **LASSO Regression**". Diapositiva *Methods & Variables* con una franja **Data · Method · Purpose**, un "**Why LASSO?**" y un **diagrama de 4 pasos**. Trayectorias de coeficientes en pantalla. La voz dice "LASSO" 3 veces | Recuadro "**Ethical Reminder (ASA Guidelines)**" de 3 viñetas en la diapositiva de resultados. Nada en la voz | 4:59 |
| 2 | [S5Cqm2RYwCo](https://www.youtube.com/watch?v=S5Cqm2RYwCo) "ASA International Data Quest 2025 (Team INFINITA)" | **INFINITA** · probablemente Indonesia (los nombres lo sugieren, no está verificado) (Natasya Azizah Ramadani, Intan Amalia, Maylafaiza Rahya Islami, Michealla Nasya Gloria R.) | Ninguno conocido | "Revealing the World's Worst SDGs Performer through Global Comparative Mapping". WDI, un indicador por ODS (17), regiones del Banco Mundial y países de África | **PCA** (3D), **heatmap** de valores estandarizados, **k-means** sobre 2 componentes, gráfico radar | **Una etiqueta enmarcada por diapositiva con el nombre de la técnica**: "PCA BIPLOT", "HEATMAP", "K-MEANS". Ejes con "PC1 (44.63% Var)". Recuadros de color por clúster. La descripción de YouTube enumera las 5 técnicas | Ninguna | 4:10 |
| 3 | [mv17jKc2yhg](https://www.youtube.com/watch?v=mv17jKc2yhg) "Socioeconomic and Health Determinants of Childhood Stunting in Southeast Asia" | **VizChiefs** · Indonesia · ULM (Muhammad Agha Putra Al-Fajrin, Yahya Kamil F., Dwi Cahyaning Putri; el apellido no se lee bien en la portada) | Podio nacional de Ética, Indonesia (Best 2 o Best 3, ídem) | Retraso del crecimiento infantil (*stunting*) en la ASEAN. WDI 2011–2020, 8 predictores, ~10 países | **OLS** (base) → **GTWR** (regresión geográfica y temporalmente ponderada, núcleo tricúbico adaptativo); MAPE, R², **I de Moran** | **Píldora verde en la portada**: "SPATIO-TEMPORAL MODELLING". La diapositiva de métodos **se titula con el nombre del método**. Comparación base frente a modelo con una cifra (MAPE 11,78 % → 2,78 %). La voz dice el nombre completo 3 veces | Mismo recuadro "**Ethical Reminder (ASA Guidelines)**". Nada en la voz | 4:44 |
| 4 | [pf8xyBvEc1Q](https://www.youtube.com/watch?v=pf8xyBvEc1Q) "Impact of Income, Fertility, and Unemployment on Poverty in Southeast Asia" | **Glorystician** · Indonesia · ULM (Muhammad Radityo Denishworo Marsudi, Dwi Annisa Febriyanti) | **Best Consideration of Ethics 2025, internacional** (y Best 1 Ética nacional) | Pobreza en Indonesia según ingreso, fecundidad y desempleo. WDI 2000–2024: **25 años, un solo país** (el título dice "Southeast Asia") | **Regresión no paramétrica con núcleo gaussiano**; ancho de banda por **GCV**; MAPE, R² | **El nombre del método es la primera línea del título de la portada**: "A GAUSSIAN KARNEL [sic] NONPARAMETRIC REGRESSION". En la diapositiva de métodos, un rótulo negro "METHOD" junto a "TOOLS: R Studio". La voz dice el nombre 3 veces | Mismo recuadro de 3 viñetas. Nada en la voz | 4:58 |

**Lo que comparten los cuatro (y nosotros no hacemos):** todos **nombran su técnica en la portada o en una etiqueta en cada diapositiva**, y la **dicen en voz** (de 1 a 3 veces cada técnica). Ninguno esconde el método detrás de una paráfrasis.

**Nuestro deck (rc1/`5ec1bd6`) hace lo contrario:**
- **La voz no nombra ninguna técnica.** En `narration_en.md` no aparecen "PCA", "k-means", "survival", "panel", "bootstrap", "regression" ni "Moran".
- **En las 4 diapositivas de contenido, la única técnica con nombre es "k-means".** Sale en la línea `.method` de la Slide 4 (`slides/index.html` l. 358), con letra de nota al pie gris (`slides/css/theme.css` l. 143). Además, esa línea **se oculta a partir del build 3** en el vídeo (`theme.css` l. 579–580).
- El PCA aparece como "Axis 1 / Axis 2" y "the two summary axes".
- Kaplan–Meier, Turnbull, Mundlak, Horn (análisis paralelo), Moran y el bootstrap **solo aparecen en las Referencias** (l. 483–486).

`docs/jurado_insight.md` §1 dice lo mismo desde otro ángulo: lo valioso es *cómo* se cuantifica (censura, dentro frente a entre países, placebo, bloques), "pero el jurado lo tiene que notar".

---

## 1. Chartosaur Inferna: "From Boom to Bust" (LASSO, Indonesia frente a Corea)

### 1.1 Ficha
- **URL:** <https://www.youtube.com/watch?v=4m-rB3pg7p4> (canal Chartosaur Inferna). Subido el 2025-10-30. 308 vistas a 2026-10-27. **4:59** (299 s).
- **Descripción:** título completo, equipo y país, miembros, "Data Source: World Development Indicators (World Bank)", "Analysis Tools: R & Python" y **"Method: LASSO Regression"**, más un resumen de 3 párrafos.
- **Producción:** grabación de Zoom. Arriba, una tira con los 4 integrantes (avatares de dinosaurio cuando la cámara está apagada). Fondo azul oscuro y la diapositiva en el centro. Subtítulos quemados en Title Case con tipografía serif blanca.

### 1.2 Preguntas y datos
- **Tres preguntas literales en pantalla** (diapositiva *Introduction & Research Questions*): qué factores socioeconómicos y demográficos se asocian con el cambio de la fecundidad en Indonesia y Corea (2014–2023), en qué se diferencian un país en desarrollo y uno desarrollado, y qué lecciones de política sirven para el equilibrio demográfico.
- **Datos:** WDI 2014–2023 (10 observaciones anuales por país). La variable dependiente es la TFR. Hay 10 predictores: población urbana, desempleo, población en edad de trabajar, mortalidad infantil, esperanza de vida, participación laboral femenina, uso de internet, PIB per cápita, dependencia de la vejez y acceso a electricidad.

### 1.3 Técnicas y **cómo las hacen visibles**
| Dónde | Qué se ve |
|---|---|
| **Portada** (0:00–0:27) | Debajo del título: "Analyzing Demographic Divergence Using World Bank WDI Data **With LASSO Regression**". La voz lo lee hacia los 0:19–0:26 |
| **Diapositiva de métodos** (1:38–2:55), ~77 s, la cuarta parte del vídeo | (a) Arriba, una franja amarilla de tres filas: **Data**: World Development Indicators (2014–2023) Indonesia & South Korea · **Method**: LASSO Regression Modeling (R & Python) · **Purpose**: identify the key socioeconomic factors influencing fertility rate. (b) "**Why LASSO?** Handles multicollinearity & performs variable selection". (c) Un **diagrama de 4 cajas**: [Data Preparation] → [Modeling Stage: LASSO Regression + Post-LASSO OLS + Model Evaluation (R², RMSE, VIF)] → [Comparative Insight] → [Interpretation: Policy Implications]. (d) Matrices de correlación de cada país y **trayectorias de los coeficientes LASSO** al aumentar la penalización. La voz las explica: los coeficientes débiles se van a cero y los fuertes siguen visibles |
| **Resultados** (2:56–4:07) | "Diverging Coefficients by Signs": barras horizontales por país (amarillo = efecto negativo, azul = positivo). Tabla "Key Factors" con el signo de cada variable. Barras "Performance Comparison" (R² ≈ 0,99 en los dos países, RMSE, VIF) |
| **Voz** | Dice "LASSO" 3 veces (portada, la pregunta "why use LASSO regression?" y "the LASSO result…"), además de "post-LASSO estimation" y "R squared, RMSE and VIF". Cita literatura para cada signo encontrado (Kim & Yi 2024, Rathore & Shaikh 2023…) |

### 1.4 Gráficas
Serie de la TFR de Corea con un marcador del último año. Matrices de correlación triangulares (azul–naranja). Trayectorias de coeficientes. Barras de coeficientes con signo. Barras de rendimiento. **Radar** que compara los "drivers" de los dos países en la conclusión. Fotos de stock en la portada: niños con la bandera indonesia y una mujer con hanbok y un bebé.

### 1.5 Narrativa y tiempos
| Tramo | Tiempo | Contenido |
|---|---|---|
| Portada | 0:00–0:27 | Título y método |
| Introducción + 3 preguntas | 0:28–1:37 | Indonesia (la población más grande de la región, la TFR más alta en los 60) frente a Corea (fecundidad ultrabaja); "dos extremos de la transición" |
| Métodos | 1:38–2:55 | Variables, por qué LASSO, diagrama, trayectorias de coeficientes |
| Resultados | 2:56–4:07 | Signos opuestos, literatura que los "confirma", R² ≈ 0,993 |
| Conclusión | 4:08–4:55 | Radar y "Policy Insights" por país (planificación familiar y transferencias condicionadas en Indonesia; licencias parentales y lugares de trabajo amigables con la familia en Corea). El cierre opone números a personas |
| Referencias | 4:56–5:00 | "Key references" |

### 1.6 Ética
Un recuadro "**Ethical Reminder (ASA Guidelines)**" en la diapositiva de resultados, con tres viñetas: datos del WDI abiertos y agregados; ningún dato personal o identificable; interpretación contextual y sin juicios. La voz no dice nada de ética.

### 1.7 Vista de jurado
- **Insight:** LASSO con **n = 10 años y 10 predictores por país** (p ≈ n). El R² ≈ 0,993 es dentro de muestra, sobre series con tendencia, así que está sobreajustado y es casi espurio. Los signos se interpretan como causas ("raise fertility", "reduce fertility"). Que la mortalidad infantil "suba" la fecundidad en los dos países, en 10 años, es colinealidad con la tendencia.
- **Viz:** la franja Data/Method/Purpose y el diagrama de 4 pasos son claros. Las diapositivas están muy cargadas y el radar de coeficientes no se lee bien.
- **Ética:** el recuadro es genérico. Hay un riesgo de estereotipo en las fotos de stock.

### 1.8 Qué tomaríamos
1. El **método en el subtítulo de la portada**.
2. Un "**Why <método>?**" de una línea, que justifique la técnica por el problema que resuelve.
3. La **franja Data · Method · Purpose** como cabecera de la diapositiva de métodos. En nuestro caso, como una línea de método en cada diapositiva.
4. Mostrar **cómo funciona el modelo** (las trayectorias LASSO). Nuestro equivalente ya existe: el recuadro "Axes vs random noise" de la Slide 3. Solo le falta el nombre: **parallel analysis**.

---

## 2. INFINITA: "Revealing the World's Worst SDGs Performer" (PCA, heatmap, k-means)

### 2.1 Ficha
- **URL:** <https://www.youtube.com/watch?v=S5Cqm2RYwCo> (canal Natasya AR). Subido el 2025-10-30. 98 vistas. **4:10** (250 s): **le sobran 50 s**.
- **Descripción:** "Using World Development Indicators (WDI) data, we applied **Principal Component Analysis (PCA), PCA Biplot, Heatmap, K-Means Clustering, and Radar Chart**". Es la descripción que más técnicas enumera de las cuatro.
- **Producción:** la diapositiva a pantalla completa con la cámara de quien habla a la derecha. Subtítulos quemados en blanco y negrita, en trozos cortos. Varias integrantes hablan por turnos.

### 2.2 Preguntas y datos
La meta es "revelar al peor de los ODS" comparando continentes. Usan **un indicador por ODS** (17) para que la comparación sea "consistente". Las unidades son agregados del Banco Mundial (regiones, "Small states", "Euro area"…) que tratan como "continentes", y después los países de África del Este y del Oeste.

### 2.3 Técnicas y **cómo las hacen visibles**
| Tramo | Etiqueta en pantalla | Qué se ve |
|---|---|---|
| 0:22–1:25 | **"PCA BIPLOT"** (rótulo enmarcado arriba a la derecha) | "3D PCA Biplot of SDGs Indicators by Continent". Ejes con **"PC1 (44.63% Var)", "PC2 (19.88% Var)", "PC3 (11.33% Var)"**. Puntos coloreados por "nivel de desempeño ODS normalizado" (rojo–verde). A la izquierda, los 17 iconos de los ODS con el indicador elegido para cada uno |
| 1:26–2:19 | **"HEATMAP"** (rótulo arriba a la izquierda) | "Heatmap of Standardized Average SDGs Values by Continent" (rojo–amarillo–verde). Luego se resalta la fila de África occidental y central y aparece un panel lateral, "Africa Western and Central Lowest SDGs Performance" |
| 2:20–3:27 | **"K-MEANS"** (rótulo arriba a la izquierda) | "K-Means of Eastern and Western Africa Countries (PCA 2 Components)". Dos **envolventes convexas** (verde y rojo), cada una con **un recuadro del mismo color que explica el clúster** ("Cluster 1": arriba a la derecha, mejor desempeño, p. ej. Seychelles, Mauricio, Gabón; "Cluster 2": abajo a la izquierda, p. ej. Chad, Sudán del Sur, Somalia) |
| 3:28–4:05 | sin etiqueta | Radar de Chad, Somalia y Sudán del Sur |
| Voz | — | Nombra "PCA biplot", "PCA", "heat map" y "K-means clustering" una vez cada uno, en la frase que abre cada bloque |

**Esta es la lección más directa para la prioridad del usuario:** un **rótulo fijo con el nombre de la técnica** en una esquina de cada diapositiva. Se lee en medio segundo y queda en pantalla todo el bloque.

### 2.4 Narrativa
Un embudo: el mundo → los continentes (PCA) → las regiones de África (heatmap) → los países (k-means) → tres países (radar) → "the country with the worst SDG performance is clearly Chad". Es simple y fácil de seguir. No hay hallazgo cuantitativo más allá del ranking.

### 2.5 Ética
Ninguna en pantalla ni en voz.

### 2.6 Vista de jurado
- **Errores:**
  - Mezclan unidades que no son comparables (agregados que se solapan y "Small states" junto a continentes).
  - El PCA 3D no se puede leer en un vídeo.
  - Lo llaman "biplot" pero no tiene vectores de carga.
  - Usan paletas rojo–verde, inaccesibles para personas con daltonismo.
  - No justifican k = 2.
  - No dan incertidumbre ni dimensión temporal.
- **Ética, en contra:** señalar a "el peor del mundo" estigmatiza a un país (ASA, principio D: impacto sobre grupos).

### 2.7 Qué tomaríamos
1. La **etiqueta de técnica por diapositiva**, con el mismo estilo siempre.
2. El **% de varianza en los ejes del PCA** ("PC1 · 57 %"). Nosotros lo tenemos en una nota al pie.
3. Un **recuadro por clúster en el color del clúster**, con una frase que diga qué lo define.
4. **Nombrar la técnica en la frase que abre cada bloque de voz.**

---

## 3. VizChiefs: "Spatio-Temporal Modelling" de la desnutrición crónica infantil (OLS → GTWR)

### 3.1 Ficha
- **URL:** <https://www.youtube.com/watch?v=mv17jKc2yhg> (canal VizChiefs). Subido el 2025-10-30. 120 vistas. **4:44** (284 s). La descripción está vacía.
- **Producción:** la diapositiva a la izquierda y una columna derecha con las 3 cámaras y rótulos de nombre (Agha, Cahya, Yahya). Se resalta a quien habla. Los **subtítulos quemados son los mejores de los cuatro**: frase completa, sans blanca sobre una banda gris y nombre técnico bien escrito, "Geographically and Temporally Weighted Regression (GTWR)". Hay una pestaña de sección arriba a la derecha de cada diapositiva: INTRODUCTION · DATA & METHODS · RESULTS & DISCUSSION · CONCLUSION · REFERENCE.

### 3.2 Preguntas y datos
Cómo influyen los factores económicos, de salud y sociales en el *stunting* de los países de la ASEAN, en el espacio y en el tiempo, entre 2011 y 2020. La variable dependiente es la prevalencia de *stunting* en menores de 5 años. Hay 8 predictores: PIB per cápita, bajo peso al nacer, gasto en salud, subnutrición, anemia en mujeres, fecundidad adolescente, desempleo y saneamiento. **Cada predictor lleva un icono y una cita bibliográfica** que justifica su inclusión.

### 3.3 Técnicas y **cómo las hacen visibles**
| Dónde | Qué se ve |
|---|---|
| **Portada** | Una **píldora verde "SPATIO-TEMPORAL MODELLING"** encima del título |
| **Diapositiva de métodos** (1:08–1:37) | **Su título es el nombre del método**, centrado: "GEOGRAPHICALLY AND TEMPORALLY WEIGHTED REGRESSION" + "2011–2020" + las variables X1–X8 + una gráfica de líneas de la prevalencia por país con banderas |
| **Resultados** (1:38–3:33) | "Model Fit Indicators using Mean Absolute Percentage Error (MAPE)": **OLS 11,78 % frente a GTWR (Adaptive) 2,78 %** en dos barras, más "R² (OLS) → 0,95 · R² (GTWR-Adaptive) → 0,99". "**Spatial autocorrelation test (Moran's I = 0.19, p = 0.03)** confirms spatial clustering in model residuals". Una tabla año × países (banderas) × variables significativas. Una matriz de correlación. La leyenda de umbrales de la OMS. El recuadro de ética |
| **Conclusión** (3:34–4:39) | Un coroplético "PREDICTED FOR STUNTING IN SOUTHEAST ASIA IN 2030" (paleta secuencial) y tres columnas, Insight · Contribution · Recommendation, con **las palabras clave en negrita** |
| **Voz** | Dice "Geographically and Temporally Weighted Regression" 3 veces, más "ordinary least squares", "adaptive tricube kernel", "heteroscedasticity and positive autocorrelation". Pierde ~20 s explicando qué es una correlación positiva o negativa |

### 3.4 Ética
El recuadro "**Ethical Reminder (ASA Guidelines)**" tiene tres viñetas: datos abiertos y agregados del WDI; macrodatos anónimos sin identificadores personales; análisis contextual y objetivo sin juicios subjetivos. **El texto es idéntico al de Glorystician**: es una plantilla de ULM. La voz no dice nada de ética.

### 3.5 Vista de jurado
- **Insight:**
  - Unas 100 observaciones país-año, 8 predictores y una regresión local: el **gw R² = 0,996** está muy cerca de interpolar.
  - La "predicción 2030" se presenta en un mapa **sin intervalos**, como si fuera un hecho ("will likely stay in the high-risk group").
  - Usan lenguaje causal ("influence", "help reduce stunting").
- **Viz:** es el deck más ordenado de los cuatro (pestañas de sección, iconos, banderas, umbrales de la OMS).
- **Ética:** solo el recuadro genérico. La predicción sin incertidumbre sería un punto en contra con las guías de la ASA.

### 3.6 Qué tomaríamos
1. **Titular la diapositiva o el panel con el nombre del método** cuando el panel es el método.
2. Una **comparación base frente a modelo en una sola cifra**, con las dos palabras escritas: "baseline" y "model". Nuestro equivalente ya existe: fecundidad sola 13 % frente a dos ejes 43 % frente a azar 3 %. Solo falta rotularlo así.
3. Escribir la **prueba de diagnóstico con su nombre** ("Moran's I = …"). Nosotros tenemos el I de Moran (`moran_cnmr_2023`, `moran_tfr_2023`) pero lo rotulamos "How alike?".
4. **Negrita en las palabras clave** de los textos de conclusión.

---

## 4. Glorystician: "A Gaussian Kernel Nonparametric Regression" (pobreza en Indonesia) — **ganador internacional de Ética 2025**

### 4.1 Ficha
- **URL:** <https://www.youtube.com/watch?v=pf8xyBvEc1Q> (canal Glorystician Team). Subido el 2025-10-30. 161 vistas. **4:58** (298 s). La descripción está vacía.
- **Miembros:** Muhammad Radityo Denishworo Marsudi y Dwi Annisa Febriyanti (ULM; tutor Samsul Arifin, según `01` §1.3). En la página oficial de ganadores figura como **Best Consideration of Ethics** 2025 (comprobado hoy en `winners.html`).
- **Producción:** **grabación de Google Meet** con la barra de la reunión visible. La diapositiva a la izquierda y las dos cámaras a la derecha. No hay subtítulos quemados. Usan ilustraciones de dibujos animados: un mendigo con un cartel de "HELP" y una familia.

### 4.2 Preguntas y datos
El efecto del ingreso per cápita, la fecundidad y el desempleo en la pobreza. Dicen que Indonesia representa al sudeste asiático, pero los **datos son solo de Indonesia**, del WDI 2000–2024: **25 observaciones anuales**. La dependiente es la tasa de pobreza en las líneas nacionales. Las independientes son el ingreso nacional neto ajustado per cápita, la TFR y el desempleo.

### 4.3 Técnicas y **cómo las hacen visibles**
| Dónde | Qué se ve |
|---|---|
| **Portada** | **El método es la primera línea del título**: "A GAUSSIAN KARNEL [sic] NONPARAMETRIC REGRESSION". Debajo: "Impact of Income, Fertility, and Unemployment on Poverty in Southeast Asia" |
| **Variable & Method** (1:10–2:01) | Una ficha con 4 rótulos negros de pincel: **PERIODS** 2000–2024 · **REGION** Indonesia · **METHOD** Gaussian Kernel Nonparametric Regression (con icono) · **TOOLS** R Studio. Variables con iconos y "Source: World Bank WDI" |
| **Results & Discussion** (2:02–3:53) | "TOP 5 Most optimal bandwidth (h)": tabla con **GCV** y una marca de verificación en "the most optimal bandwidth value with the minimum CGV [sic]". Una gráfica de valores ajustados frente a reales. **MAPE 2,06 %** y **R² 0,990292**, con su definición ("Mean Absolute Percentage Error", "Coefficient of Determination"). Una tabla "Parameter Estimation" (estimación, t, p, "Significant"). El recuadro de ética |
| **Conclusion** (3:54–4:51) | Tres columnas: Insight · Contribution · Recommendation |
| **Voz** | Dice el nombre del método 3 veces y "generalized cross validation". **No dice nada de ética** |

### 4.4 Ética
El mismo recuadro amarillo de 3 viñetas que VizChiefs, en la diapositiva de resultados. **No hay más.** La recomendación de "controlling fertility rates" es delicada (connotación coercitiva). La ilustración del mendigo es un estereotipo de la pobreza.

### 4.5 Qué nos dice sobre el premio de Ética
- En Indonesia, **los tres puestos nacionales de Ética** (Glorystician, VizChiefs, Chartosaur Inferna) usaron **el mismo recuadro de 3 viñetas** titulado "Ethical Reminder (ASA Guidelines)". Glorystician ganó además **el premio internacional**.
- En 2025 bastó con que **la ética fuera visible y estuviera rotulada con el nombre de las guías de la ASA**, aunque fuera genérica y no estuviera en la voz.
- Nuestra franja "How we kept it honest · ASA Ethical Guidelines (2022)" (Slide 4) ya es más específica: 5 tarjetas con los códigos de las guías (B.2, C.4, C.2, C.3, A.8, D.6, B.3, F.4…). **No hay que recortarla por densidad.** Es la pieza que en 2025 decidió el premio.

### 4.6 Vista de jurado
- **Insight:** 25 puntos de una serie temporal con tendencia y R² = 0,99. Los p-valores tratan los años como independientes. Usan lenguaje causal ("leads to", "impact"). El título no coincide con los datos.
- **Viz:** la ficha PERIODS/REGION/METHOD/TOOLS es muy legible. Las tablas de resultados son capturas densas.
- **Producción:** la más pobre de las cuatro. Aun así ganaron Ética: **el jurado de ética no penalizó la producción.**

### 4.7 Qué tomaríamos
1. El **método en la portada**.
2. Una **ficha de método de 4 rótulos**: para qué periodo, qué unidad, qué método y con qué herramienta.
3. Decir **cómo se eligió el parámetro** ("ancho de banda por GCV"). Nuestro equivalente es "k = 4 fijado antes; los datos prefieren 2–3; se comprobó con FPCA y 500 re-runs". `jurado_insight.md` §3 pide decirlo en pantalla.

---

## 5. Patrón transversal: dónde aparece la técnica

| Recurso | Chartosaur | INFINITA | VizChiefs | Glorystician | **Nosotros (rc1)** |
|---|---|---|---|---|---|
| Técnica en la **portada** | subtítulo | no (en la descripción de YouTube) | píldora encima del título | **primera línea del título** | **no** |
| **Etiqueta de técnica** en cada diapositiva o panel | franja "Method:" | **"PCA BIPLOT" / "HEATMAP" / "K-MEANS"** | la diapositiva de métodos se titula con el método | rótulo "METHOD" | **no**: chip "Question N" y códigos P |
| "**Why <método>?**" | sí | no | no (se justifica comparándolo con OLS) | no | no |
| **Diagrama** del proceso | 4 cajas | no | no | ficha de 4 rótulos | solo una frase con flechas en la Slide 4 (gris, se oculta en el build 3) |
| **Base frente a modelo** con una cifra | R²/RMSE/VIF de los dos países | no | **MAPE OLS 11,78 % → GTWR 2,78 %** | 5 anchos de banda + GCV | sí (13 % / 43 % / 3 %), pero sin rotularlo así |
| Diagnóstico **con nombre** | VIF | % de varianza en los ejes | **Moran's I** | GCV, MAPE | R², r y SD con glosa. Moran y el análisis paralelo **sin nombre** |
| Técnica **en voz** | 3× LASSO | 1× cada técnica | 3× GTWR | 3× kernel | **0** |
| Ética visible | recuadro de 3 viñetas | no | recuadro de 3 viñetas | recuadro de 3 viñetas | **franja de 5 tarjetas con códigos ASA + voz** |
| Incertidumbre | no | no | no (predice 2030 sin intervalos) | no | **sí** (IP 95 % de la ONU, bootstrap por bloques) |
| Subtítulos quemados | sí | sí | sí (los mejores) | no | sí |

**Conclusión:** en estadística, incertidumbre y ética estamos por encima de los cuatro. En **legibilidad del método** estamos por debajo de todos. Arreglarlo cuesta poco: casi todo es texto en `slides/index.html` y unas pocas palabras en el guion.

---

## 6. Aplicación a nuestro deck (para hacer en ≤ 2 días)

Todos los textos en pantalla, en inglés. Las cifras solo pueden salir de claves `verified: true` de `figures/numbers.json`. Las de abajo ya están verificadas: `pc1_var` 56,7; `pc2_var` 17,9; `n_dims_parallel` 2; `moran_cnmr_2023` 0,11; `moran_tfr_2023` 0,74; `knn_tfr` 13,2; `knn_pc12` 43,2; `knn_chance` 3,1; `ari_fpca_decadas` 0,96; `jaccard_min` 0,78.

### 6.1 Una línea de método con negrita en la cabecera de cada diapositiva (modelo INFINITA/VizChiefs)
**Dónde:** `.hdr-row` de `slides/index.html`, l. 103, 218, 289 y 356. Va después de `.pcodes`, como `<span class="mchip">Methods: <b>…</b> · <b>…</b></span>`, con estilo de píldora con borde (no gris), `font-weight` de 600 en los nombres y siempre visible.

**Texto propuesto:**
- **Slide 1 (Q1 · palancas):** `Methods: **demographic balance decomposition** · **UN probabilistic projections (95 % range)**`
- **Slide 2 (Q1 · orden):** `Methods: **survival analysis** (Kaplan–Meier, censored onsets) · **curve registration** · **within–between panel** (fixed effects) · **Moran's I**`
- **Slide 3 (Q2):** `Methods: **adjusted R²** · **nearest-neighbour look-alikes** · **PCA** + **parallel analysis** · **Monte Carlo** index weights`
- **Slide 4 (Q3):** `Methods: **k-means clustering** of 70-year paths · checked with **functional PCA** and **bootstrap** re-runs · **σ-convergence** (SD)`

Se mantienen las glosas llanas que ya existen: "axis = one summary of all 12 indicators", "R² = share of the differences…". El nombre técnico va **delante** de la glosa, no en su lugar.

### 6.2 El método en la portada (modelo Glorystician/Chartosaur/VizChiefs)
La portada no cuenta para el límite de 4 diapositivas. Va una línea en negrita debajo del subtítulo o junto a Q1–Q3:

`Methods: survival analysis · within–between panel · PCA · k-means clustering · block bootstrap (UN sub-regions)`

### 6.3 Nombrar las técnicas en voz sin alargar el vídeo
Se cambia en `slides/script/narration_en_template.md` y se regenera con `build_narration.py` (captions y `data_captions.json`). Después hay que comprobar que los `data-caption` de `index.html` coinciden con la voz nueva y repetir la lectura cronometrada (P-03).

| Paso | Ahora | Propuesta | Δ palabras |
|---|---|---|---|
| `s2.b2` (l. 132) | "Child deaths started falling first in 106 of 109 high-fertility countries." | "**Survival analysis:** child deaths started falling first in 106 of 109 high-fertility countries." | +2 |
| `s2.b3` (l. 137) | "Within one country, this link is smaller than what comparing countries suggests." | "A **within-country panel** finds this link smaller than comparing countries suggests." | −1 |
| `s3.b3` (l. 163) | "Countries differ in two separate ways." | "**PCA** shows countries differ in two separate ways." | +2; cabe dentro del MP4 de 9,2 s (22 palabras ≈ 8,8 s a 150 ppm; 9,4 s a 140) |
| `s4.b1` (l. 182) | "Grouped by seventy-year paths, countries form three stretches…" | "**K-means** groups seventy-year paths into three stretches…" | −1 |
| `s4.b4` (l. 201) | "Projections are labelled as scenarios; examples follow a rule; …" | "Following **ASA guidelines**: projections are scenarios; examples follow a rule; …" | +1 |

El saldo es de unas +3 palabras, pero las de `s3.b3` quedan absorbidas por el MP4. El efecto real es de ≈ +0,4 s sobre 4:52,2.

### 6.4 Que no se oculte la única línea de método que ya existe
`slides/css/theme.css` l. 579–580 esconde `.s4 .method` desde el build 3. Hay que quitar esa regla, o sustituir la línea por la píldora de §6.1. Además, `.method` (l. 143) usa `--muted` y la letra de nota al pie: los nombres de técnica deberían ir en negrita y con el color de texto normal.

### 6.5 La Slide 3 con los nombres que ya calculamos
- "Only 2 axes stand out from random noise" → "**Parallel analysis:** only 2 axes stand out from random noise".
- En el recuadro "Axes vs random noise", el título pasa a "Parallel analysis (Horn)".
- "Axis 1 / Axis 2" → "**PC1** (57 %) / **PC2** (18 %)", en el texto. En `fig09`, solo si da tiempo a volver a renderizarla.
- El trío de *look-alikes* se rotula "fertility alone (baseline) 13 % · PCA, 2 axes 43 % · chance 3 %".

### 6.6 Ética: no recortar y nombrar la ASA también en voz
Ver §4.5 y el cambio de `s4.b4` en §6.3.

---

## 7. Lo que no hay que copiar (errores vistos en los cuatro)
- **R² ≈ 0,99 con 10–25 puntos temporales** (Chartosaur, Glorystician) o con una regresión local (VizChiefs). Es sobreajuste o tendencia compartida. Nosotros damos el R² ajustado y lo comprobamos con regiones excluidas y bootstrap por bloques. Conviene decirlo, sin nombrar a nadie.
- **Predicciones sin intervalo** ("predicted stunting 2030"). Nosotros: "UN medium projection", con el IP 95 %.
- **Rankings estigmatizantes** ("the world's worst performer: Chad") y **fotos o dibujos estereotipados** (niños pobres, un mendigo, ropa tradicional).
- **Rojo–verde**, **PCA en 3D** y un "**biplot**" sin vectores de carga.
- **El título no coincide con los datos** ("Southeast Asia" con un solo país) y **se mezclan unidades** (agregados del Banco Mundial que se solapan, tratados como continentes).
- **Cámaras y barras de Meet o Zoom** en pantalla: restan espacio a las gráficas. Nosotros usamos voz sobre el deck, y está bien.
- Gastar tiempo explicando qué es una correlación positiva (VizChiefs, ~20 s) en lugar de decir qué significa la cifra.

---

## 8. Fuentes
- Vídeos: <https://www.youtube.com/watch?v=4m-rB3pg7p4> · <https://www.youtube.com/watch?v=S5Cqm2RYwCo> · <https://www.youtube.com/watch?v=mv17jKc2yhg> · <https://www.youtube.com/watch?v=pf8xyBvEc1Q> (páginas, descripciones, transcripciones automáticas de YouTube y storyboards; consultados el 2026-10-27).
- Ganadores 2025: <https://american-statistical-association.github.io/CIRSDataQuest/winners.html> (Glorystician = Best Consideration of Ethics; VizChiefs, Chartosaur Inferna e INFINITA no figuran).
- Puestos nacionales en Indonesia: `docs/01_analisis_ganadores_2025.md` §1.3 (prensa de ULM). La página de ULM devolvió 403 hoy, así que no se volvió a verificar.
- Otro vídeo encontrado en la búsqueda y **no estudiado** (fuera del encargo): StatWaves, "ASEAN's Economic Openness and Uneven Growth" (<https://www.youtube.com/watch?v=UVHia6-T7Ww>).
