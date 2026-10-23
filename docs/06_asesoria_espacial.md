# 06 — Asesoría de estadística espacial (P7, P6, P8; mapas de las Slides 1 y 4)

> Asesor: estadística espacial. Fecha: 2026-10-22. Datos: `WPP2024_Demographic_Indicators_Medium_csv.gz` (países = `ISO3_code` no vacío, 237), ingreso `wb_api_income_2026-10-22.csv`, región SDG por `ParentID` (panel `panel.rds` del asesor multivariado). Muestra principal: **161 países ≥ 1 M en 2023**; sensibilidad con los 237.
> Geometría **sin `sf`**: Natural Earth 1:50m (`rnaturalearthdata::countries50`) → WKT → paquete `s2` (ya instalado; geodesia esférica) para centroides, contigüidad y distancias; proyección **Robinson implementada a mano** (tabla de Robinson + spline) y `geom_polygon(subgroup=)` para los huecos. Vecindad principal: **5 vecinos más cercanos** (distancia haversine entre puntos representativos), fila-estandarizada. Moran global/local y *join counts* programados a mano con permutaciones (B = 999, `set.seed(2026)`).
> Scripts: `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/espacial/00_funciones.R … 08_bootstrap_bloques.R` (el scratchpad es temporal: `notebook-R` debe copiar los bloques). Figuras: `docs/asesoria_figs/espacial/`. Todo es **exploratorio**; las cifras finales salen de `figures/numbers.json`.

---

## 0. Resumen en 9 líneas

1. **Sí hay un insight espacial real, pero es de apoyo, no una sección nueva.** Fecundidad, esperanza de vida y edad mediana están muy agrupadas en el mapa: Moran's I (2023) = **0,74 / 0,69 / 0,77** (p = 0,001; banda nula ±0,09). La migración neta **no**: I = **0,12** (p = 0,007), y **−0,03 (p = 0,65) sin los seis Estados del Golfo**.
2. **Hoy la geografía pesa más que en 1950**, sobre todo en el crecimiento: el I por rangos del crecimiento pasa de **0,34 a 0,69** (diferencia +0,35; IC jackknife 95 % 0,18–0,53). La edad mediana sube +0,26 (0,11–0,41) y la esperanza de vida +0,13 (0,01–0,26). En la fecundidad el aumento (+0,16; −0,02 a 0,33) no es concluyente.
3. **Fecundidad, supervivencia y edad se parecen hasta ~3 000 km; la migración, solo en el vecino de al lado** (correlograma: I = 0,44 a < 1 000 km; ≈ 0 más allá; 0,17 sin el Golfo).
4. **Corredores de vecindario:** solo aparecen en crisis. En 3 de 74 años (1994, 1996 y 2018) el I de la migración es significativamente negativo, y lo producen ≤ 6 países. Ejemplos: Siria 2012–16 (−52 ‰) frente a Jordania (+37 ‰) y Líbano (+25 ‰); Ucrania 2022 frente a Moldova, Polonia y Lituania (+25 a +29 ‰). El gran corredor de largo plazo (Asia del Sur → Golfo) está a **2 500–4 500 km**: fuera de cualquier "vecindario".
5. **LISA (migración 2010–23):** el único conglomerado robusto es el **Golfo** (7 de 7 países sobreviven a FDR). Hay 13 países "bajo-bajo" de salida neta (7 en el sudeste de Europa) con p < 0,05, pero solo 2 sobreviven a FDR (Albania y Serbia).
6. **Clústeres de trayectoria (P6):** son geográficamente contiguos. **El 67 % de los pares de vecinos comparte el mismo camino**, frente a un 30 % al azar (banda 26–34 %; p = 0,001). El voto de los 5 vecinos acierta el camino del **75 %** de los países (azar 31 %). Pero la región SDG sola acierta el 78 %: **"dónde vives" ya está en el plan a través de la región.**
7. **Modelo espacial:** sumar la media de los vecinos a región + ingreso añade **≤ 4 puntos de R² fuera de muestra** (TFR 0,75 → 0,79; el resto < 1 punto). En el panel 1955–2023, la fecundidad de los vecinos de hace 5 años **no aporta nada más allá de la tendencia región × año** (coef. 0,035; placebo p = 0,17). Al notebook; GWR descartada.
8. **Aviso para todo el equipo:** como los vecinos se parecen, los países no son observaciones independientes. Con bootstrap por bloques (20 subregiones de la ONU), los IC de correlaciones y R² del plan son **1,4–2,2 veces más anchos** que con el bootstrap iid.
9. **Mapa:** se entrega una plantilla probada sin `sf` (Robinson, franja de 76 pequeños Estados, Crimea reasignada a Ucrania, nota de no-aval de la ONU) para la Slide 1 y otra para la Slide 4.

---

## 1. Evaluación del plan y del storyboard desde la estadística espacial

| Sección | Qué está bien | Qué falta o hay que cambiar |
|---|---|---|
| Plan §1 (tesis) y receta de ganadores ★★★4 ("mapa en el resultado principal") | El mapa de palancas y el de trayectorias son la columna visual correcta (TRITICS ganó con un mapa interpretado, no decorativo). | Hoy los mapas **describen** pero no **prueban** nada geográfico. Con dos cifras de dependencia espacial (I y *join count*), el mapa pasa a ser evidencia: "neighbours share fertility, not migration". |
| Plan §3 (unidad = país, ≥ 1 M) | El umbral de 1 M y la franja de pequeños Estados son correctos. | Falta declarar la **no independencia espacial**. El TFR conserva I = 0,16 en los residuos tras región + ingreso (p = 0,001), y los IC iid salen optimistas (§3.6). Añadir la decisión "IC por bootstrap de bloques de subregión". |
| Plan §4 Q1 (P7) | La pregunta "¿depende de la región y del ingreso?" es justo la que la estadística espacial responde. | Añadir una fila **"Simple 3: ¿se parecen los vecinos?"**: Moran por indicador (esp01). Responde a P7 con una cifra: la fecundidad y la mortalidad son regionales; la migración no. El ingreso explica más la migración (R² LOO 0,19) que la región (0,04). |
| Plan §4 Q3 Rico 1 (clustering) | Validación con silueta, bootstrap y ARI. | Falta una validación **externa** que no sea circular: la contigüidad (*join count*) usa la geografía, que no entró en el clustering. Es la mejor prueba de que los grupos "significan algo". |
| Plan H5/H4 y storyboard Slide 2 build 3 ("migration has no memory") | La idea es buena. La asesoría de series de tiempo ya la corrige: correlación 1950–2023 = 0,14, no β ≈ −1. | Completar la frase con el espacio: **"no memory and no neighbourhood"** (0,14 en el tiempo y 0,12 en el espacio, frente a 0,52 y 0,74 de la fecundidad). Es una sola línea, sin figura nueva. |
| Storyboard Slide 1 (mapa de palancas) | Paleta Okabe-Ito, conteos en la leyenda, franja de pequeños Estados, zoom a Europa y al Golfo. | (a) El `coord_map("moll")` sobre `maps::map_data` puede ser lento y dejar artefactos en ±180° (Chukotka, Fiyi). Usar la **plantilla esp07** (Robinson con coordenadas ya proyectadas; el zoom es solo `coord_fixed(xlim, ylim)`, que se interpola con `tweenr`). (b) **Los conteos dependen de la ventana:** con el promedio 2021–23 y los 237 países, el tipo "growing only because of net arrivals" tiene **24 países**, no los 18 del pre-chequeo de 2023. QA-stats debe fijar la ventana antes de narrar. |
| Storyboard Slide 4, mensaje: *"Countries cluster by how they moved, not where they are"* | La distinción trayectoria/nivel es correcta (ARI 0,42 vs niveles). | **Es ambiguo y choca con el dato espacial**: un jurado puede leer "where they are" como geografía, y los caminos **sí** son geográficos (67 % vs 30 %). Proponer: *"Countries group by how they moved, not by where they stand today — and neighbours tend to share a road."* |
| Catálogo §13 (mapa pendiente de `sf`) | La alternativa `maps` + `countrycode` es razonable. | Ya no hace falta `sf`: `s2` + `rnaturalearthdata` dan contigüidad, distancias y polígonos válidos (237/237 códigos WPP emparejados; Gibraltar como punto). |
| TRITICS (GWPR, "Where you live matters") | Buen referente narrativo. | **No copiar GWR/GWPR.** Con 161 unidades, coeficientes locales sobreajustan, y su comparación por R² ajustado es la debilidad que señalamos en `01_analisis_ganadores_2025.md` §2.9. Nuestra versión honesta: "where you live predicts your road (75 %)… but the region already knows it (78 %)". |

---

## 2. Análisis recomendados

### 2.1 Tema 1 — Autocorrelación global (¿la demografía está "agrupada"? ¿más que en 1950?)

- **Método.** Moran's I con W de 5 vecinos más cercanos (fila-estandarizada), p por permutación (B = 999) e IC del 95 % por *jackknife*: se quita un país y se recalcula W. Versión **por rangos** (Moran sobre `rank(x)`) como prueba robusta. Hace falta porque en años de crisis (Ruanda 1994: −306 ‰; Kuwait 1990–91: −184 ‰) un solo valor domina el I clásico. Diferencia 2023 − 1950 con *jackknife* pareado (mismos 161 países).
- **Supuestos.** Unidad = país sin ponderar por población; W fija en el tiempo; vecindad por cercanía de puntos representativos (*label points* de Natural Earth, dentro del núcleo poblado).
- **Validación.** Cuatro W (kNN5, kNN8, contigüidad con relleno de islas, distancia inversa ≤ 2 000 km): el I del TFR 2023 varía entre 0,70 y 0,74, y el de la CNMR entre 0,10 y 0,13. Con los 237 países: TFR 0,72, CNMR 0,07, crecimiento 0,42. Residuos tras región SDG y tras región + ingreso (§3.1).
- **Frase (EN):** *"Neighbours look alike in births, deaths and age — and growth has become twice as geographic as in 1950. Migration is the exception: neighbours barely share it."*

### 2.2 Tema 2 — ¿La migración es un fenómeno de vecindario?

- **Método.** (i) Correlación de la CNMR propia con la **media de los 5 vecinos** (rezago espacial; Pearson y Spearman), con y sin Golfo, en cuatro horizontes (2023, 2021–23, 2010–23 y acumulado 1950–2023 sobre la población de 2023). (ii) **Serie anual** del I con prueba bilateral: un I < 0 significa que los vecinos se mueven en direcciones opuestas, es decir, un corredor. (iii) **Correlograma** (I por bandas de 1 000 km). (iv) **LISA** (Anselin 1995) con permutación condicional, 4 cuadrantes, p < 0,05 y control **FDR** (Benjamini–Hochberg), porque son 161 pruebas.
- **Supuestos.** "Alto/bajo" se mide respecto a la media entre países (CNMR media ≈ 0), no por el tamaño del flujo. La CNMR de un año es muy ruidosa, así que el mapa usa la **media 2010–2023**, que cubre las crisis de Siria y Venezuela. Sensibilidad con 2021–23 (misma ventana que el mapa de palancas) y con 2023.
- **Validación.** Cada resultado se recalcula sin el Golfo. En los años negativos se identifica qué países producen el signo (§3.2). Se mide la distancia real de los corredores conocidos.
- **Frase (EN):** *"Displacement from crises spills into next-door countries; the largest long-run corridor, South Asia to the Gulf, spans thousands of kilometres. Outside the Gulf, migration has no neighbourhood."*

### 2.3 Tema 3 — Contigüidad de los clústeres de trayectoria (P6)

- **Método.** Se usan los 4 grupos del asesor multivariado: k-means k = 4 sobre medias por década de TFR, LEx, edad mediana y CNMR; 161 países; `cluster_nombres.rds`. Sensibilidad con un k-means propio de 3 variables, sin CNMR. Medidas: (i) ***join count* "mismo grupo"**, la proporción de enlaces vecino→vecino que comparten grupo, frente a 999 permutaciones de etiquetas; (ii) proporción por grupo frente a lo esperado al azar; (iii) **voto de los 5 vecinos** para "adivinar" el camino de cada país (leave-one-out natural), comparado con la mayoría de su región, de su grupo de ingreso y de región × ingreso.
- **Supuestos.** Los grupos son una tipología, no "grupos naturales" (silueta 0,37; continuo). La contigüidad no es circular, porque la geografía no entró en el clustering.
- **Frase (EN):** *"Two in three neighbouring countries have travelled the same 70-year road — twice what chance would give. Where you live still predicts your demographic path."*

### 2.4 Tema 4 — ¿Vale la pena un modelo espacial?

- **Transversal 2023 (160 países; Taiwán excluido por no tener grupo de ingreso).** Se compara el R² *leave-one-out* (PRESS) de: ingreso; región (6, con Oceanía unida); solo la media de los vecinos (W·y); región + ingreso; y región + ingreso + W·y (rezago espacial usado como predictor). Además, el Moran de los residuos.
- **Panel 1955–2023 (SLX con `fixest`).** `TFR ~ l(TFR,5) + l(Q5,5) + l(W·TFR,5) | país + año` y con `| país + región^año`, EE agrupados por país. **Placebo**: vecinos sorteados dentro de la misma región (B = 100).
- **Veredicto.** El término espacial casi no añade nada frente a región + ingreso (§3.4), y la "difusión entre vecinos" no se distingue de la tendencia regional. **Solo notebook.** No se estima un SAR por máxima verosimilitud: `spatialreg` no está y no cambiaría la conclusión. Hacerlo por 2SLS con W·X como instrumento sería un apéndice, no una prioridad.
- **Frase (EN, notebook):** *"Knowing a country's neighbours adds little once its region and income group are known."*

### 2.5 Tema 5 — Diseño del mapa (1920×1080, sin `sf`)

- **Proyección Robinson propia.** Es una tabla de 19 latitudes con spline natural (`GEO$robinson()`); se aplica a los vértices y se dibuja con `coord_fixed()`. Es rápida, no rompe polígonos en ±180° y el **zoom es un simple cambio de `xlim/ylim`**, interpolable con `tweenr` para el vídeo de la Slide 1. **Marco truncado a 58° S–85° N**: Antártida fuera, Groenlandia dentro. Así se gana ≈ 15 % de altura en 16:9.
- **Ajustes a la ONU.** Departamentos franceses de ultramar (GUF, GLP, MTQ, REU, MYT), BES y Tokelau separados como en el WPP; Somalilandia → SOM; Chipre del Norte → CYP; Åland → FIN; **Crimea reasignada a Ucrania** (Natural Earth la dibuja "de facto" en Rusia; los mapas de la ONU siguen A/RES/68/262); Siachen como polígono neutro "sin datos"; nota al pie *"The boundaries and names shown do not imply official endorsement or acceptance by the United Nations."*
- **Pequeños Estados.** En la plantilla de palancas, los 76 países < 1 M aparecen atenuados (alfa 0,4) en el mapa (Groenlandia deja de dominar visualmente) y con su color en una **franja de puntos con ISO3 agrupada por región** bajo el mapa. En los mapas ≥ 1 M, los países con área < 15 000 km² (Bahréin, Singapur, Hong Kong RAE, Mauricio, Trinidad y Tabago, Líbano, Palestina, Chipre, Gambia, Jamaica…) llevan un **punto** para que se vean.
- **Leyenda.** En una fila sobre el mapa con conteos ("· 24"), o dentro del Pacífico sudoriental si el mapa ocupa todo el ancho. Paleta Okabe-Ito sin semáforo para la migración: azul = entrada neta, naranja = salida neta, nunca rojo.
- **Titulares interpretativos (EN):** LISA: *"Migration forms only one clear neighbourhood: the Gulf"*. Trayectorias: *"Where you live still predicts your demographic road"*. Palancas: *"Four engines: which lever is moving each country's population"*.

---

## 3. Resultados preliminares (reales, R 4.6.1, `set.seed(2026)`)

### 3.1 Moran's I global (161 países ≥ 1 M, kNN5, B = 999; [IC jackknife 95 %]; banda nula ≈ [−0,09; 0,09])

| Indicador | 1950 | 1990 | 2023 | I por rangos 1950 → 2023 | I residual tras región + ingreso (2023) |
|---|---|---|---|---|---|
| TFR | 0,66 [0,54; 0,77] | 0,71 [0,61; 0,80] | **0,74** [0,65; 0,83] | 0,55 → 0,70 | 0,16 (p = 0,001) |
| LEx | 0,55 [0,43; 0,67] | 0,65 [0,53; 0,77] | **0,69** [0,59; 0,79] | 0,55 → 0,68 | 0,15 (p = 0,002) |
| Edad mediana | 0,68 [0,53; 0,82] | 0,75 [0,66; 0,84] | **0,77** [0,69; 0,86] | 0,52 → 0,78 | 0,12 (p = 0,011) |
| Crecimiento (%) | 0,23 [0,07; 0,38] | −0,03 (p = 0,88)* | **0,59** [0,45; 0,74] | **0,34 → 0,69** | 0,08 (p = 0,04) |
| CNMR | −0,01 (p = 0,51) | −0,03 (p = 0,92) | **0,12** [−0,20; 0,44] (p = 0,007) | 0,06 → 0,26 | −0,09 (p = 0,98) |

\* El crecimiento en 1990–94 cae a ≈ 0 por valores extremos (Kuwait, Ruanda); con rangos vale 0,52 en 1990.

- La región SDG explica gran parte del patrón: R² (2023) TFR 0,67, LEx 0,67, edad mediana 0,75, CNMR 0,06. Aun así **queda dependencia entre vecinos dentro de la misma región e ingreso** (columna derecha).
- **Picos:** LEx máximo en 2003–04 (I = 0,79), en la época de la epidemia de VIH/sida en África subsahariana; el LISA de 2003 tiene 42 países en "bajo-bajo", 40 de ellos subsaharianos. CNMR máximo en 2005 (0,47), con la entrada en el Golfo.
- **Proyecciones (no son hallazgos):** el I del TFR baja a 0,65 en 2100 (supuesto de convergencia) y el de la CNMR sube a ≈ 0,30 (migración proyectada suavizada y persistente).

### 3.2 Migración y vecinos

| Horizonte CNMR | ρ Spearman propia vs vecinos (con / sin Golfo) | Pearson (con / sin) | Moran I (con / sin) |
|---|---|---|---|
| 2023 | 0,32 / 0,23 | 0,21 / −0,05 | 0,12 / −0,03 (p = 0,65) |
| 2021–23 | 0,39 / 0,33 | 0,47 / 0,24 | 0,30 / 0,13 (p = 0,003) |
| 2010–23 | 0,47 / 0,43 | 0,62 / 0,41 | 0,44 / 0,22 |
| Acumulado 1950–2023 | 0,51 / 0,44 | 0,62 / 0,47 | 0,45 / 0,29 |

- **El signo es positivo, no de corredor.** Los vecinos tienden a compartir el signo de su migración, y más cuanto más largo es el periodo. En la serie anual, el I es positivo y significativo en 55 de 74 años (mediana 0,15) y negativo solo en **1994, 1996 y 2018**. Si se quitan los ≤ 6 países responsables (1994–96: Ruanda, Burundi, R. D. del Congo, Tanzania, Malawi, Mozambique; 2018: Líbano, Siria, Venezuela, Trinidad y Tabago, Kuwait, Arabia Saudita), el I vuelve a 0,08–0,16.
- **Episodios (CNMR media, ‰):** Siria 2012–16 −52,2 → Jordania +36,8, Líbano +24,5, Türkiye +8,0, Iraq +6,4 (todos contiguos; en el LISA 2012–16 Siria sale como "bajo-alto" con p < 0,05, aunque no sobrevive a FDR). Ucrania 2022 −138,8 → Moldova +29,3, Lituania +25,6, Polonia +25,2. Ruanda 1994 −306 → Burundi +90, R. D. del Congo +29, Tanzania +12. Venezuela 2015–19 −23,5 → Colombia +5,7 (contigua), Perú +4,0 (2 400 km), Chile +8,9 (5 100 km). Asia del Sur → Golfo: India–EAU 2 500 km, Nepal–Qatar 3 200 km, Bangladés–Arabia Saudita 4 500 km.
- **Correlograma (2023; CNMR 2010–23):**

| Banda (miles de km) | < 1 | 1–2 | 2–3 | 3–4 | 4–6 | 6–9 | > 9 |
|---|---|---|---|---|---|---|---|
| TFR | 0,77 | 0,70 | 0,48 | 0,13 | −0,22 | −0,13 | −0,13 |
| Edad mediana | 0,83 | 0,69 | 0,39 | −0,02 | −0,33 | −0,09 | −0,10 |
| CNMR | 0,44 | 0,00 | −0,06 | −0,11 | 0,03 | −0,01 | 0,00 |
| CNMR sin Golfo | 0,17 | −0,03 | −0,01 | 0,05 | 0,00 | −0,04 | 0,01 |

- **LISA CNMR 2010–23 (p < 0,05; FDR entre paréntesis):** alto-alto 7 (7): ARE, BHR, IRN, KWT, OMN, QAT, SAU. Bajo-bajo 13 (2: ALB, SRB): ALB, BGR, GRC, IND, MDG, MKD, MUS, PRI, ROU, SDN, SRB, SSD, XKX. Alto-bajo 4 (0): COD, TCD, TTO, ZAF. Bajo-alto 0.
  - Con 2021–23: alto-alto 14, que suma a DEU, FIN, GBR, LVA, NOR, POL y SWE por la entrada de 2022; solo 6 sobreviven a FDR, todos del Golfo + IRN.
  - Con 2023: **ninguno sobrevive a FDR**.

### 3.3 Contigüidad de los clústeres de trayectoria

| Etiqueta (161 países) | % enlaces de vecinos en el mismo grupo (kNN5 / contigüidad) | Azar (banda 95 %) | Acierto del voto de 5 vecinos (clase mayoritaria) |
|---|---|---|---|
| Trayectoria k = 4 (4 variables) | **66,8 % / 70,6 %** | 30,3 % (26,5–34,4) | **75,2 %** (32,9 %; permutación ≤ 39,8 %) |
| Trayectoria k = 4 (3 variables, sin CNMR) | 57,1 % / 63,4 % | 24,9 % | 62,7 % (28,0 %) |
| Región SDG (8) | 90,2 % | 18,5 % | 92,5 % |
| Grupo de ingreso BM | 47,5 % | 25,6 % | 50,3 % (31,1 %) |
| Tipo de palanca 2021–23 | 50,7 % | 31,7 % | 58,4 % (44,1 %) |

- **Por grupo, vecinos del mismo grupo frente al azar:** Early 72 % (31 %), Fast 55 % (31 %), Late 75 % (32 %), Migration-boosted 54 % (4 %).
- **Referencias para "adivinar" el camino:** la mayoría de la región acierta el 77,5 %, la del grupo de ingreso el 74,4 % y la de región × ingreso el 84,7 %. Ponderado por población, el voto de los vecinos acierta el 85,4 %.
- **Excepciones.** 40 países (25 %) tienen un camino distinto al de la mayoría de sus vecinos. Están casi todos en fronteras entre grupos: Oriente Medio, el Caribe, el sudeste asiático, y Botsuana, Sudáfrica y Mauricio (Fast movers entre Late movers). AUS y NZL aparecen como excepciones **por un artefacto de W**: sus 5 vecinos más cercanos incluyen Papúa Nueva Guinea, Timor-Leste, Malasia y Filipinas.

### 3.4 Modelo espacial (R² leave-one-out, 160 países, 2023)

| Resultado | Ingreso | Región | Solo vecinos (W·y) | Región + ingreso | + W·y | I residuos (reg + ing → + W·y) |
|---|---|---|---|---|---|---|
| TFR | 0,64 | 0,63 | **0,73** | 0,75 | 0,79 | 0,16 → −0,04 |
| LEx | 0,70 | 0,60 | 0,65 | 0,79 | 0,80 | 0,14 → 0,04 |
| Edad mediana | 0,71 | 0,70 | 0,73 | 0,83 | 0,83 | 0,11 → 0,03 |
| Crecimiento | 0,36 | 0,51 | 0,53 | 0,55 | 0,56 | 0,08 → −0,06 |
| CNMR 2021–23 | **0,19** | **0,04** | 0,19 | 0,25 | 0,26 | −0,01 → −0,11 |

- **Lectura para P7:** la media de 5 vecinos predice la fecundidad mejor que la región o el ingreso por separado (0,73 frente a 0,63–0,64). En la migración, **el ingreso cuenta y la región no** (0,19 frente a 0,04).
- **Panel SLX (11 040 país-años).** Coeficiente de W·TFR(t−5): 0,053 (EE 0,022) con FE de año, pero **0,035 (EE 0,024, n.s.)** con FE de región × año. Placebo con vecinos sorteados dentro de la región: media −0,001, p95 0,065, **p = 0,17**.

### 3.5 Figuras (todas revisadas a 1920×1080)

| Archivo (`docs/asesoria_figs/espacial/`) | Qué muestra |
|---|---|
| `esp01_vecinos_se_parecen.png` | Moran I 1950 (círculo vacío) → 2023 (lleno) por indicador, con IC *jackknife* y banda de azar. Cuatro indicadores entre 0,59 y 0,77; la migración (naranja) en 0,12, con un IC que toca el azar. **La figura núcleo.** |
| `esp02_correlograma_distancia.png` | I por banda de distancia. Fecundidad, edad y LEx bajan de ≈ 0,8 (< 1 000 km) a ≈ 0,4 (2 000–3 000 km) y se vuelven negativos a 4 000–6 000 km. La migración solo es positiva a < 1 000 km (0,44; 0,17 sin el Golfo). |
| `esp03_lisa_migracion_mapa.png` | Mapa LISA de la CNMR 2010–23 (Robinson; 4 categorías). Bloque azul en el Golfo; naranja en el sudeste de Europa, India, Sudán/Sudán del Sur y Madagascar; azul claro en Chad, R. D. del Congo, Sudáfrica y Trinidad y Tabago; 137 países grises. |
| `esp04_grupos_trayectoria_contiguidad.png` | Mapa de los 4 caminos con recuadro "Neighbours on the same road": barras por grupo frente a la marca del azar. Bloques continentales nítidos: Europa/Norteamérica/Australia (más Argentina y Uruguay), América Latina/Norte de África/gran parte de Asia, África subsahariana y el Golfo. |
| `esp05_moran_anual.png` | I por rangos de cada año, 1950–2100, con la proyección sombreada. El crecimiento sube de 0,34 a 0,69; la migración se queda en 0,06–0,26 (pico de 0,39 en 2022). |
| `esp07_plantilla_mapa_palancas.png` | **Plantilla para la Slide 1:** 237 países por tipo de palanca 2021–23 (165 / 24 / 31 / 17), leyenda en fila, < 1 M atenuados y franja de 76 pequeños Estados por región con ISO3, nota de no-aval. |
| (solo scratchpad) `esp06_modelo_espacial_r2.png` | Barras de R² LOO de §3.4, para el notebook. |

### 3.6 Consecuencia para las demás asesorías: IC con dependencia espacial

Bootstrap iid de países frente a bootstrap por bloques de las **20 subregiones de la ONU** (`ParentID`), B = 2 000, 161 países, 2023:

| Estadístico | Valor | IC iid | IC por bloques | Ancho bloques / iid |
|---|---|---|---|---|
| R² edad mediana ~ TFR | 0,773 | 0,74–0,81 | 0,67–0,84 | **2,2×** |
| R² crecimiento ~ TFR | 0,592 | 0,46–0,73 | 0,32–0,81 | 1,8× |
| ρ Spearman TFR–CNMR | −0,248 | −0,39 a −0,10 | −0,44 a −0,05 | 1,4× |
| ρ Spearman LEx–TFR | −0,840 | −0,88 a −0,78 | −0,90 a −0,67 | 2,2× |

Los valores puntuales no cambian. Lo que cambia es la **precisión**: 161 países "valen" bastante menos que 161 observaciones independientes. Recomendación para QA-stats: toda banda o IC que aparezca en pantalla debe ser por bloques de subregión, o llevar al menos la nota "iid; spatial dependence would widen it".

---

## 4. Riesgos estadísticos y éticos

1. **MAUP y definición de vecindad.** Los resultados dependen de la unidad (país) y de W. Mitigación: 4 W y 2 muestras (§2.1). La conclusión cualitativa no cambia: los I del TFR van de 0,68 a 0,74 y los de la CNMR de 0,03 a 0,13. Para países aislados (AUS, NZL, islas), los kNN crean "vecinos" lejanos, así que hay que declararlo.
2. **Países, no personas.** El I trata igual a China y a Mauricio. No se calcularon variantes ponderadas por población. Decir "countries", nunca "people", en las frases.
3. **Valores extremos.** El I clásico es una correlación y un solo país en crisis puede invertir su signo (1990–94). Usar el I por rangos para las tendencias y el clásico solo con la nota.
4. **Comparaciones múltiples en LISA.** Son 161 pruebas por mapa: de los 24 países marcados en 2010–23, solo 9 sobreviven a FDR, y ninguno en 2023. **No narrar países individuales del LISA**, salvo el bloque del Golfo, que es robusto.
5. **Estimaciones y proyecciones.** La estructura espacial de 2024–2100 es un producto de los supuestos de la ONU (la migración proyectada tiene I ≈ 0,3 porque se suaviza). Va en gris y no se presenta como hallazgo.
6. **Causalidad.** "Neighbours look alike" no implica contagio ni difusión: el test de panel no encuentra efecto de vecinos más allá de la tendencia regional. Prohibido *spread, contagion, spillover effect*. Permitido: *neighbours look alike, share, cluster*.
7. **Señalar países (ASA A.8, D.6).**
   - En el vídeo, los conglomerados se nombran por región ("the Gulf", "south-eastern Europe"), nunca con una lista de países ni con juicios (*exodus, brain drain, magnet, hot spot of emigration*).
   - "Alto/bajo" es una posición relativa a la media, no éxito o fracaso.
   - Las entradas positivas tras un conflicto (Sudán del Sur, Siria 2018) son **retornos**.
   - En el texto se usan los nombres de la columna `Location` del WPP: *Kosovo (under UNSC res. 1244)*, *China, Taiwan Province of China*, *State of Palestine*, *Türkiye*. En el mapa, ISO3.
   - Los nombres de los grupos de trayectoria son provisionales y describen un comportamiento, no un ranking.
8. **Fronteras.** Natural Earth es una vista "de facto": Crimea ya está corregida; Cachemira sigue con línea de facto y Siachen va neutro; Kosovo y Sáhara Occidental aparecen como en el WPP. Siempre hay que poner la nota de no-aval de la ONU y citar Natural Earth (dominio público).
9. **Sesgo visual por área.** Rusia, Canadá, Groenlandia y Australia dominan la vista. Atenuar los < 1 M y poner un punto a los ≥ 1 M diminutos ya lo corrige en parte. No hacen falta cartogramas (no hay `sf`/`cartogram`).
10. **Dependencia de otros memos.** Los clústeres vienen del asesor multivariado. Si el notebook cambia k o las variables, hay que recalcular el *join count* (script `04_clusters.R`, 17 s).

---

## 5. Cambios concretos al plan y al storyboard

**Recomendación global: ENTRA EN EL VÍDEO COMO APOYO, no como sección.** Son dos frases y dos cifras (≈ 15 s) sobre visuales que ya existen, sin figura nueva en pantalla. Los mapas LISA, el correlograma, la serie anual y el modelo van **solo al notebook**/apéndice. **GWR/SAR: descartar.**

1. **Slide 2, build 3 (narración y chip de texto).** Sustituir *"Migration is different: it has no memory — where a country stood in 1950 says nothing about today. It reacts to shocks, like Syria or Ukraine, and in rich countries it fills the gap that low fertility leaves."* (37 palabras; además, el memo de ética marca "fills the gap") por:
   > *"Migration is different: it has almost no memory and almost no neighbourhood. Neighbours share their fertility, but not their migration — except in the Gulf."* (25 palabras, ahorra 12)

   Chip en pantalla: `Similarity over time · across neighbours — fertility 0.52 · 0.74 | migration 0.14 · 0.12`. Claves nuevas en `numbers.json`: `moran_tfr_2023`, `moran_cnmr_2023`, `moran_cnmr_2023_nogulf`. Las de memoria vienen de la asesoría de series.
2. **Slide 4, build 1.** Añadir en el mapa de trayectorias la línea `Two in three neighbouring countries share the same road (chance: one in three)`, con las claves `join_same_road` = 0,67 y `join_same_road_null` = 0,30. Cambiar el mensaje de una línea por *"Countries group by how they moved, not by where they stand today — and neighbours tend to share a road."*
3. **Slide 1, build 4 (opcional, zoom al Golfo).** Añadir un chip `The Gulf: the only clear migration neighbourhood (7 of 7 significant after FDR)`. Si no cabe, se omite sin perder nada.
4. **Plan §4 Q1:** nueva fila "Simple 3: ¿se parecen los vecinos?" (§2.1, figura esp01), como evidencia de P7, junto con la tabla de R² LOO región/ingreso/vecinos (§3.4). Hipótesis nueva H15, **post hoc** (se formuló al ver este prototipo; registrarla como exploratoria, ASA B.6): "la CNMR tiene I < 0,2 mientras TFR/LEx/edad > 0,6 (2023, ≥ 1 M)". En el prototipo se cumple; el notebook la repite sin cambiar el umbral.
5. **Plan §4 Q3 Rico 1 — validación:** añadir el *join count* y el voto de vecinos como validación externa no circular (§2.3), reportando también la referencia regional (78 %) para no exagerar.
6. **Plan §3 — nueva decisión:** "Dependencia espacial: los IC de las cifras en pantalla se calculan por bootstrap de bloques de subregión ONU (20 bloques)" (§3.6). Avisar a los agentes de multivariado, inferencia y panel.
7. **Mapas (catálogo §13 y plan de implementación):** adoptar la ruta `rnaturalearthdata::countries50` + `s2` + Robinson propio (`01_geo.R`, 20 s), el marco 58° S–85° N, Crimea → UKR, la nota de no-aval y la franja de pequeños Estados de `07_plantilla_mapa.R`. El zoom animado se hace interpolando `xlim/ylim`.
8. **QA-stats:** fijar la ventana del mapa de palancas. Con 2021–23 y 237 países, el tipo C son **24** países, no 18. Lo que se narre y lo que diga la leyenda deben salir de la misma ventana.
9. **Notebook (sección "Dependencia espacial", exploratoria):** esp01–esp06, con las tablas §3.1–3.4, el LISA con FDR, la serie por rangos, el panel SLX con placebo y la nota de proyecciones. Citar a Moran (1950), Anselin (1995) y Benjamini y Hochberg (1995), y Natural Earth como fuente de las fronteras.
10. **Lenguaje:** añadir a la lista de verbos prohibidos del memo de ética *contagion, spread to, spillover* (en sentido causal), y a la de permitidos *neighbours look alike / share / cluster*.

---

## 6. Reproducibilidad (para `notebook-R`)

- **Orden de ejecución:** `01_geo.R` (geometría, contigüidad y distancias entre fronteras: ≈ 20 s) → `02_moran_global.R` → `02b_robustez.R` → `03_migracion.R` → `04_clusters.R` → `05_modelo.R` → `06_figuras.R` / `07_plantilla_mapa.R` → `08_bootstrap_bloques.R`. Total < 3 min.
- **Dependencias:** `panel.rds` y `cluster_nombres.rds` (scratchpad `multivariado/`). En el notebook deben salir de la preparación oficial.
- **Paquetes:** tidyverse, rnaturalearthdata (1.0.0), s2, fixest, patchwork, ggrepel, ragg. Ninguno necesita GDAL ni GEOS.
- **Núcleo del método** (todo lo demás son variantes):

```r
W_knn <- function(D, k = 5) { diag(D) <- Inf                       # D = matriz haversine (km)
  t(apply(D, 1, function(r) { w <- numeric(length(r)); w[order(r)[1:k]] <- 1 / k; w })) }
moran <- function(x, W) { z <- x - mean(x); (length(x) / sum(W)) * sum(z * (W %*% z)) / sum(z^2) }
p_perm <- function(x, W, B = 999) { I0 <- moran(x, W); (1 + sum(replicate(B, moran(sample(x), W)) >= I0)) / (B + 1) }
```
