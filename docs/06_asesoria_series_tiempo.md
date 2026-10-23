# 06 — Asesoría de SERIES DE TIEMPO para el plan y el storyboard

> Asesor: series de tiempo · Fecha: 2026-10-22 · Alcance: P7, P8, P1, P4 (+ choques y estimación vs proyección).
> Datos: `WPP2024_Demographic_Indicators_Medium_csv.gz` (países = `ISO3_code` no vacío; 237) + ingreso `data/raw/wb_api_income_2026-10-22.csv`.
> Salvo que se diga otra cosa: **161 países ≥ 1 M (2023)**, **solo estimaciones 1950–2023**. Todas las cifras son **prototipos**: el agente `notebook-R` debe re-calcularlas y pasarlas a `figures/numbers.json`.
> Scripts de prueba (R 4.6.1, `set.seed(2026)`): `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/series_tiempo/` (`00_datos.R` … `06_p8_fuera_tiempo.R`). El código clave está en el Anexo.

---

## 0. Resumen (lo que hay que saber en 1 minuto)

1. **El rezago "11 años / 80 % mortalidad primero" (H3) no es robusto**: depende de los umbrales elegidos. Con otros umbrales razonables, la mediana va de **−11 a +39,5 años** y "mortalidad primero" del **11 % al 100 %**. Usarlo así es *cherry-picking* involuntario.
2. **Alternativa robusta (recomendada para el vídeo)**: fechar el **inicio de la caída sostenida** (regla clásica de Princeton: −10 % respecto al máximo, sin volver atrás). Resultado: **la mortalidad infantil empezó a caer antes que la fecundidad en 105 de 108 países (97 %)**, con un rezago mediano de **≥ 22 años** (IQR 13–31); cuando arranca la caída de la fecundidad, la mortalidad < 5 ya había caído un **50 %** (mediana). Robusto a 9 variantes de la regla (19–24 años; 94–97 %).
3. **Gradiente por ingreso (P7)**: rezago (Kaplan–Meier, con censura) **36 años en ingreso bajo, 25 medio-bajo, 14 medio-alto, 16 alto**; por región: África subsahariana 31, N. África y Asia Occ. 23, Asia 15–19, América Latina 13,5.
4. **Correlaciones entre series con tendencia son espurias**: la correlación temporal TFR–LEx dentro de un país es −0,84 (mediana)… **y es exactamente igual (−0,84) si se empareja cada país con otro país al azar**. En cambios anuales: 0,04 vs 0,03. No usar correlaciones de niveles a lo largo del tiempo como evidencia.
5. **H5 ("migración y fecundidad solo se acoplan en ingreso alto, ρ = −0,36") cambia de signo** con el filtro ≥ 1 M: Spearman **+0,10 [IC95 −0,20; 0,41]**. El −0,36 lo generan microestados. Quitarlo del guion.
6. **Hallazgo nuevo para P1 (y el más llamativo)**: la mortalidad infantil **convergió en términos absolutos pero divergió en términos relativos**. La brecha P90–P10 bajó de 311 a 64 muertes por 1 000, pero la **razón P90/P10 subió de 6× (1950) a 20× (2023)** (27× en 2100, proyección). La β "−0,85" del plan solo cuenta la mitad.
7. **β de la migración ≈ −1 es lo que da ruido puro** (placebo barajando países: β = −1,00). No es "convergencia" ni "memoria"; decir "correlación 1950–2023 = 0,14".
8. **Las proyecciones no tienen choques**: volatilidad de cambios anuales 33× (LEx), 13,5× (TFR) y 20× (CNMR) menor que en estimaciones; 0 países pierden esperanza de vida en cualquier año 2025–2100 (vs 19/año típico y 118–119 en 2020–21). Ningún análisis de correlación, rezago, β o σ debe cruzar 2023/2024.
9. **P8 con validación honesta "fuera de tiempo"**: el 0,99 de la escalera de R² es la identidad contable. Para predecir el crecimiento **10 años después**, añadir la migración de hoy **no ayuda** (R² fuera de tiempo 0,57 → 0,47).

---

## 1. Evaluación del plan (`00_plan_analitico.md`) y del storyboard desde series de tiempo

### 1.1 Lo que está bien (mantener)
- **§3 "Estimaciones vs proyecciones"**: separar 1950–2023 de 2024–2100, gris/punteado y línea en 2023/24. Correcto y necesario (ver §2.5).
- **§3 "Migración volátil"**: promedio 2021–2023 para clasificar la palanca. Correcto (suaviza COVID/Ucrania); mantener la sensibilidad "solo 2023".
- **§3 "Identidad contable"** explicada como identidad, no como hallazgo. Correcto; confirmo R² = 0,9999 para `10·PopGrowthRate ~ NatChangeRT + CNMR` (coeficientes 1,00 y 1,01).
- **Q2 Simple 3 (ρ(CDR, LEx) por año)** y la idea del profesor de **correlaciones transversales año a año**: no sufren el problema de tendencia (comparan países en un mismo año). Bien, con bandas bootstrap **remuestreando países** (no años).
- **Q3 Simple 2 (fan chart P10–P90)**: es la forma correcta de mostrar σ-convergencia. Bien.
- **S13 (proyecciones 14–34× más suaves)**: confirmado (13,5×–33×).

### 1.2 Lo que es incorrecto o débil

| Dónde | Qué dice | Problema (series de tiempo) | Evidencia en los datos |
|---|---|---|---|
| Plan §3 (variables derivadas) y §4 Q1 **Rico 1**; H3; storyboard Slide 2 build 2 y narración | Rezago = año(TFR < 4) − año(Q5 < 100); "solo países con ambos cruces > 1950"; "mediana 11, 80 % mortalidad primero" | (a) **Dependencia del umbral**: el par (100, 4) es arbitrario. (b) **Sesgo de selección por censura**: excluye a los 23 países que aún no cruzan TFR < 4 (12 de ingreso bajo y 10 medio-bajo: justo los de rezagos más largos). (c) Mezcla dos variables en escalas no comparables. | Rejilla 5×4 de umbrales: medianas −11 … +39,5; "mortalidad primero" 11 % … 100 % (tabla 3.1). Con (100, 4): n = **105** (no 89), mediana ingenua **8** (IQR −2…18), 68 % mortalidad primero; KM con censura: **11 [8; 15]**. |
| Plan §4 Q1 **Rico 2**, H5; storyboard (heatmap "coupling") | "La migración se acopla con la fecundidad solo en ingreso alto (−0,36) y el vínculo se proyecta a fortalecerse" | (a) No es robusto al filtro ≥ 1 M. (b) "Se proyecta a fortalecerse" es una **propiedad del escenario**, no un hallazgo. (c) Años sucesivos no son observaciones independientes. | Ingreso alto 2023: Pearson todos (85) −0,36; **≥ 1 M (50): Pearson +0,23, Spearman +0,10 [−0,20; 0,41]**. Global ≥ 1 M: −0,25 [−0,40; −0,11]. |
| Plan §4 Q1 **Rico 3**, H4, S12; storyboard Slide 2 build 3 ("migration has no memory, β ≈ −1") | β-convergencia con años sueltos 1950/2023; "la mortalidad infantil converge" | **Falacia de Galton**: β < 0 no implica que la dispersión baje. Para CNMR, β ≈ −1 es el valor que da el ruido puro. Para Q5, la conclusión depende de la escala (nivel vs log). | CNMR: β = −0,86 pero DE 7,3 → 7,6 (sin cambio); placebo = −1,00. Q5 nivel β = −0,85; **log Q5 β = +0,22 y DE(log) 0,70 → 1,14**. Edad mediana (≥ 1 M): β = **+0,33** (p ≈ 0,01), no "0,09 n.s." (ese valor es con 237 países). |
| Plan §4 Q3 **Simple 2**, H10–H11; Test.Rmd (σₜ ~ t) | "Regresión σₜ ~ t con p-valor" | Los residuos de σₜ tienen autocorrelación 0,75–0,99: los EE de MCO son falsos. TFR no es monótona (sube a 1990 y baja), así que una recta la describe mal. | t de la pendiente con EE iid vs Newey–West: edad mediana 83 → 36; LEx −24 → −9; **TFR −5,3 → −1,7 (no significativa)**. |
| Plan §4 Q2 **Simple 1** (escalera de R² 0,59 → 0,70 → 0,99) | "Each lever carries information the others don't" | Contemporáneo = identidad. La prueba honesta (receta ganadores ★★★3) es **fuera de muestra / fuera de tiempo**. | Entrenar en 2003 → crecimiento 2011–13; probar en 2013 → 2021–23: TFR 0,48; +CDR **0,57**; +CNMR **0,47**; crecimiento de hoy −0,16. |
| Storyboard Slide 2 build 1, plan Q3 Simple 1 | "Europe took a century, Asia and LAC about fifty years" | Europa está **censurada** (TFR 2,78 ya en 1950): los datos no permiten decir "un siglo". Asia/LAC son ≈ 30 años, no 50. | Años de TFR 5 → 2,5 (agregados SDG): E/SE Asia **32** (1959–1991), C/S Asia **34** (1983–2017), LAC **30** (1972–2002), N. África/Asia Occ. 47 (cruza 2,5 en 2033, proyección), SSA 50 (2015 → 2065, proyección). |
| Plan §10 (P4, EDA c.68) | "Spearman migración–crecimiento 2000–23: Europa 0,94…" | Correlación **temporal** de niveles de un agregado que contiene la identidad (crecimiento = natural + migración): es mecánica y con tendencia. | En cambios anuales dentro de país, ρ(ΔCNMR, Δcrecimiento) tiene mediana 0,97: no discrimina nada. |
| Plan §4 Q1 **Opcional (panel FE)** | `feols(TFR ~ l(Q5,10) + CNMR | pais + anio)` en niveles anuales | En niveles, los residuos siguen con autocorrelación ≈ 0,98 (casi espurio). Mejor cambios quinquenales y rezagos distribuidos en ambas direcciones. | Ver §3.1 (panel): el efecto aparece a 5–10 años; la dirección inversa es débil. |
| Plan §3 (ingreso) vs `data/raw/README.md` | "FY2026" vs "FY2027" | Inconsistencia de la clasificación citada. | Unificar en todo el repo y en Referencias. |
| Plan §6 S14 | "161 países perdieron LEx en 2020 y 168 en 2021" | Correcto con los 237; con ≥ 1 M son 118 y 119. Decir siempre el universo. | Verificado. |

### 1.3 Lo que falta
- **Censura explícita** (países que aún no cruzan / ya cruzaron antes de 1950) en todo análisis de "años hasta".
- **Una prueba placebo** (países emparejados al azar, o barajar años) que muestre al jurado que las correlaciones no son artefactos.
- **Escala log** al hablar de convergencia de mortalidad (los riesgos se comparan en razones, no en diferencias).
- **Advertencia de datos modelizados**: las series anuales WPP son suaves por construcción (autocorrelación de ΔTFR = 0,80); las correlaciones cruzadas anuales y los rezagos exactos heredan ese suavizado.
- **Verificación de choques extremos**: República Centroafricana tiene LEx 14,7 en 2009 y 18,8 en 2022 (muertes ×5 respecto a años vecinos). No mostrarlos sin revisar las notas de la ONU.
- **El grupo de ingreso es posterior al resultado**: los países que hoy son de ingreso alto/medio-alto son en parte los que hicieron la transición antes. El gradiente del rezago por ingreso es **descriptivo** ("countries that are low-income today"), no un efecto del ingreso.

---

## 2. Método recomendado por pregunta

### 2.1 P7 — ¿La mortalidad cae antes que la fecundidad? ¿Varía por región e ingreso?
- **Método principal (vídeo)**: *inicio de la caída sostenida* de Q5 y de TFR. Inicio = primer año con x ≤ 0,9·máx(x hasta ese año) que no vuelve a superarse. Elegibles: TFR₁₉₅₀ ≥ 5 (fecundidad pre-transicional), ≥ 1 M, solo estimaciones. Para cada país: rezago = inicio TFR − inicio Q5 y % de caída de Q5 al iniciar la fecundidad. Rezago por grupo con **Kaplan–Meier** (los que no han iniciado = censurados en 2023).
- **Por qué**: no depende de umbrales absolutos (cada país se compara con su propio máximo), trata la censura y es la definición estándar de la demografía histórica (European Fertility Project).
- **Supuestos y límites**: si Q5 ya caía en 1950 (45 de 110 países, inicio ≤ 1955), el rezago real es **mayor** que el medido → el 22 es una cota inferior (decirlo). La fecha de inicio de Q5 en los años 50 de muchos países africanos es modelizada.
- **Validación**: rejilla de reglas (−5/−10/−15 % × TFR₁₉₅₀ ≥ 5/5,5/6) → mediana 19–24 años, 94–97 %; rejilla de umbrales absolutos solo en el notebook, como prueba de sensibilidad.
- **Capa rica (notebook, 1 cifra en el vídeo)**: panel de cambios quinquenales con efectos fijos país + periodo, rezagos distribuidos 0–20 años, EE agrupados por país, **en ambas direcciones** (tipo Granger). Resultado: ΔTFR responde a Δlog Q5 con rezago de 5 años (0,17; EE 0,08) y 10 años (0,37; EE 0,10); el sentido inverso es débil.
- **NO usar** como resultado: correlación cruzada (CCF) país por país sobre diferencias anuales — el rezago con máxima correlación va de 0 a 25 años (mediana 5), solo el 48 % supera 2/√n y ese umbral no vale con series autocorrelacionadas; además se eligen 26 rezagos (comparaciones múltiples).
- **Frases para el vídeo (EN)**:
  - *"We dated the year each country's child deaths and births began a lasting fall. In 105 of 108 countries, child deaths fell first — at least 22 years earlier, by the median."*
  - *"By the time fertility started to fall, child mortality had already halved."*
  - *"The wait is longest where incomes are lowest today: about 36 years in low-income countries, 14 in upper-middle-income ones. This is a sequence in time, not proof of cause."*

### 2.2 P7/P8 — Relaciones entre indicadores sin correlaciones espurias
- **Regla**: nunca correlacionar **niveles a lo largo del tiempo**. Tres alternativas válidas, por orden de simplicidad:
  1. **Transversal por año** (países en un mismo año) con IC bootstrap remuestreando países. Ej.: Spearman TFR–log Q5 = 0,68 [0,56; 0,76] en 1950 → 0,88 [0,84; 0,91] en 2023.
  2. **Diferencias largas** (cambios de 10 años no solapados) con efecto fijo de periodo y EE por país: ΔTFR ~ Δlog Q5 = 0,49 (EE 0,09); ΔTFR ~ ΔLEx = −0,018 (EE 0,007). Q5 está mucho más ligado a la fecundidad que LEx.
  3. **Panel de efectos fijos país + año** con EE agrupados por país (y en cambios, no en niveles).
- **Para CNMR vs crecimiento**: no correlacionar (es identidad). Usar **descomposición de varianza**: parte de las diferencias de crecimiento entre países que viene de la migración = cov(g, m)/var(g). En 2023: 0,29; en 1950: 0,42; en 2030 (proyección): ≈ 0.
- **Frase (EN)**: *"Any two trends look related, so we compare changes, not levels — and we check that a random pair of countries does not show the same link."*

### 2.3 P1 — Convergencia σ y β sin la falacia de Galton
- **σ (dispersión)**: por año, DE, CV y P10/P25/P50/P75/P90 entre los 161 países → **fan chart**. Para mortalidad, en **log** (o razón P90/P10). Cambio 1950 → 2023 con IC bootstrap por país; si se ajusta σₜ ~ t, solo 1950–2023 y con EE Newey–West (o mejor: no dar p-valor y mostrar la banda).
- **β (recuperación)**: ΔX ~ X₀ con **X₀ = media 1950–54** y **X₁ = media 2019–23** (reduce el error de medición en X₀) y **siempre al lado de σ₀ y σ₁**. Regla de lectura: solo hay convergencia si β < 0 **y** σ baja. Placebo: barajar X₁ entre países (da β ≈ −1 por construcción).
- **Resultados clave**: LEx converge (DE 12,2 → 7,4; Δ IC95 [−5,9; −3,9]); edad mediana diverge (4,7 → 9,7; [4,3; 5,8]); TFR sube a 1,97 en 1990 y baja a 1,30 (2023): primero divergió, luego convergió; Q5 converge en niveles pero **diverge en log** (DE 0,70 → 1,14; razón P90/P10 6× → 20×); CNMR no cambia (7,3 → 7,6; IC incluye 0).
- **Frases (EN)**: *"We measure how far apart countries are each year: if the band narrows, they are converging."* · *"Every country cut child deaths. Yet a child in the riskiest tenth of countries is now 20 times as likely to die before age five as a child in the safest tenth — in 1950 it was 6 times."*

### 2.4 Quiebres y choques (sin `strucchange`)
- **Choques puntuales**: residuo respecto a una **mediana móvil de 9 años** (`runmed`, robusta a caídas de 1–4 años); choque si el residuo ≤ −1 año de LEx **y** ≤ −4 DE robustas (MAD) del propio país (MAD calculada solo con 1950–2023). Para TFR, igual en log (≤ −5 %).
- **Retrocesos sostenidos** (VIH, crisis post-soviética): LEx menor que 10 años antes.
- **Quiebres de pendiente**: tendencia lineal por tramos continua con 2 quiebres, búsqueda en rejilla del mínimo SSE (equivalente sencillo a Bai–Perron, sin p-valor; tramos ≥ 6 años). Ej.: Zimbabue 1987/2002, Botsuana 1984/2001, Sudáfrica 1990/2005, Kenia 1982/1997 (coinciden con la epidemia de VIH).
- **Anotación sin causalidad**: etiqueta = "evento conocido que **coincide** con el pico" (`docs/02_contexto_historico.md`), en el pie: *"association in time, not attribution"*.
- **Frase (EN)**: *"We flag years when life expectancy fell far below its own recent path, then check what happened that year."*

### 2.5 Estimación vs proyección: qué no se mezcla
- La variante Medium es un **escenario suave y convergente por construcción**: sin choques, migración que tiende a cero en dispersión (DE de CNMR entre países 7,6 en 2023 → 2,0 en 2030 → 1,1 en 2100) y fecundidad que converge (DE TFR 1,30 → 0,22 en 2100).
- **Prohibido mezclar**: (a) correlaciones, rezagos, CCF o paneles con ventanas que crucen 2023/24; (b) β con año final en proyección (p. ej. "edad mediana converge 1950–2100, β = −0,57" del profesor) presentado como evidencia; (c) "el vínculo se fortalece" cuando solo ocurre en años proyectados; (d) contar años proyectados como datos (inflan n y bajan EE).
- **Permitido**: mostrar la proyección como continuación gris/punteada y dar cifras "UN medium projection" (año de pico, edad mediana 2050), siempre con la etiqueta.
- **Frase (EN)**: *"Real history is bumpy; the UN projection is smooth by design — a scenario, not a forecast."*

### 2.6 P8 — ¿Un indicador basta? Versión con tiempo honesta
- Mantener la escalera contemporánea (0,59/0,70/0,99) pero añadir **una barra "10 years later"**: modelo entrenado con indicadores de 2003 → crecimiento medio 2011–13, evaluado con indicadores de 2013 → crecimiento 2021–23.
- Mensaje: los tres componentes explican el presente (identidad), pero **la migración de hoy no predice el crecimiento futuro** (no tiene memoria: ρ(CNMR₁₉₅₀, CNMR₂₀₂₃) = 0,14 frente a 0,52 de TFR y 0,64 de la edad mediana).
- **Frase (EN)**: *"Migration explains today's growth gaps, but not tomorrow's: it has almost no memory."*

### 2.7 Mostrar el tiempo sin engañar
- **Connected scatter** (Q5 log vs TFR) con **flecha** en el último año estimado, puntos 1950/1975/2000/2023, proyección punteada y gris; resaltar 3–4 regiones y el resto en gris (8 colores a la vez es demasiado, ver st06).
- **Event time** (alinear países en su año de inicio) en vez de calendario cuando la pregunta es "qué pasa antes/después".
- **Animación**: el contador de año debe cambiar de estilo (gris, texto "UN projection") al pasar 2023; pausa de 1 s en 2023; nunca interpolar entre 2023 y 2024 como si fuera la misma serie.
- **Ventanas móviles** (p. ej. correlación transversal media de 10 años) solo para suavizar visualmente; la ventana no debe cruzar 2023/24.
- Ejes que no cambian entre fotogramas; escala log declarada en el eje.

---

## 3. Prototipos ejecutados (datos reales) y figuras

### 3.1 Rezago mortalidad → fecundidad

**A. Umbrales absolutos (método del plan), 161 países ≥ 1 M**

| Estado (Q5 < 100, TFR < 4) | n |
|---|---|
| Ambos cruces observados después de 1950 | 105 |
| Q5 cruzó, TFR aún no en 2023 (censura derecha) | 23 |
| Ambos ya por debajo en 1950 (sin información) | 27 |
| Q5 ya < 100 en 1950 (censura izquierda) | 3 |
| Ninguno cruzó | 3 |

Sensibilidad (mediana ingenua del rezago / % mortalidad primero): (200, 5) 23 / 94 % · (150, 4) 20 / 93 % · **(100, 4) 8 / 68 %** · (75, 4) 0 / 49 % · (50, 5) **−11 / 11 %** · (200, 2,5) **39,5 / 100 %**. → El número depende de la elección.

**B. Inicio de la caída sostenida (recomendado), 110 países ≥ 1 M con TFR₁₉₅₀ ≥ 5**

| Grupo | n | Rezago mediano (años) | Caída de Q5 al iniciar la fecundidad | Mortalidad primero |
|---|---|---|---|---|
| Todos | 108 (+2 sin inicio: Rep. Centroafricana, RD Congo) | **22** (IQR 13–31; KM 22 [20; 25]) | **50 %** (IQR 41–64) | **97 %** |
| Ingreso bajo / medio-bajo / medio-alto / alto (KM) | 24 / 40 / 33 / 12 | **36 / 25 / 14 / 16** | 63 / 51 / 46 / 73 % | 95–100 % |
| África subsahariana | 41 | 31 | 57 % | 98 % |
| N. África y Asia Occ. | 20 | 23 | 74 % | 95 % |
| Asia Central y Sur / Este y SE | 10 / 14 | 18,5 / 15,5 | 43 / 56 % | 100 % |
| América Latina y Caribe | 18 | 13,5 | 41 % | 100 % |

Ejemplos (inicio Q5 → inicio TFR): Kenia 1953 → 1984; Nigeria 1964 → 1996; India 1955 → 1974; México 1953 → 1973; Colombia 1954 → 1967; Bangladés 1972 → 1982; China 1961 → 1964.

**C. Panel (cambios quinquenales, FE país + periodo, EE por país, N = 1 610)**: ΔTFR ~ Δlog Q5 con rezago 0 / 5 / 10 / 15 / 20 años = 0,04 (0,12) / **0,17 (0,08)** / **0,37 (0,10)** / −0,01 (0,09) / 0,10 (0,08). Lectura: si Q5 se reduce a la mitad en un quinquenio, la TFR es ≈ 0,25 hijos menor 10 años después. El sentido inverso (ΔTFR → Δlog Q5 posterior) solo es marginal a 20 años (0,03; p = 0,035).

**D. CCF por país sobre diferencias anuales**: rezago de máxima correlación mediana 5 años, IQR 1–12, rango 0–25; correlación contemporánea log Q5–TFR: niveles 0,90 vs diferencias 0,10 (mediana). → No concluyente; no usar.

### 3.2 Correlaciones espurias (TFR vs LEx; CNMR vs crecimiento)

| Prueba (161 países, 1950–2023) | Niveles | Cambios anuales |
|---|---|---|
| ρ(TFR, LEx) dentro del mismo país, mediana | −0,84 (74 % con \|ρ\| > 0,7) | 0,04 |
| **Placebo**: TFR del país A vs LEx de un país B al azar | **−0,84** (75 %) | 0,03 |
| ρ(CNMR, PopGrowthRate) dentro del país | 0,72 | 0,97 (identidad) |

| TFR ~ LEx | β | EE | t |
|---|---|---|---|
| MCO agrupado, EE iid | −0,139 | 0,0008 | **−177** |
| MCO agrupado, EE agrupados por país | −0,139 | 0,0036 | −38 |
| FE país + año, EE agrupados (niveles) | −0,064 | 0,0098 | −6,6 |
| Primeras diferencias + FE año, EE agrupados | **+0,003** | 0,0026 | **1,1** |

Autocorrelación de los residuos del MCO dentro de país: 0,98. → El "t = −177" es un artefacto; con cambios anuales no hay asociación (y con cambios de 10 años es pequeña: −0,018 hijos por año de LEx).

### 3.3 σ / β (P1)

| Indicador (161 países) | DE 1950 | DE 2023 | Cambio [IC95 bootstrap] | β 1950→2023 | Lectura |
|---|---|---|---|---|---|
| LEx | 12,2 | 7,4 | −4,8 [−5,9; −3,9] | −0,59 | Converge |
| Edad mediana | 4,7 | 9,7 | +5,1 [4,3; 5,8] | **+0,33** | Diverge |
| TFR | 1,68 (1,97 en 1990) | 1,30 | −0,39 [−0,58; −0,19] | −0,60 | Diverge hasta 1990, converge después |
| Q5 (nivel) | 117 | 27 | −90 [−99; −81] | −0,85 | Brecha absoluta se cierra |
| **log Q5** | 0,70 | 1,14 | **+0,44 [0,36; 0,53]** | **+0,22** | **Brecha relativa se abre: P90/P10 6,2× → 19,9×** |
| CNMR | 7,3 | 7,6 | +0,4 [−2,5; 3,4] | −0,86 (placebo −1,00) | Galton: sin convergencia ni memoria |

### 3.4 Choques y proyecciones
- Choques de LEx detectados (≥ 1 M): **350 país-año en 1950–2023 vs 4 en 2024–2100** (Libia y Estado de Palestina 2024–25, crisis que la ONU incorporó; después, cero). TFR: 112 vs 1.
- Picos: 2021 (82 países), 2020 (38), 2022 (24), 1993 (11: crisis post-soviética, Burundi, Bosnia), 1994 (9: Ruanda, ex-URSS). Mayores fuera de COVID: Ruanda 1994 (−31 años respecto a su mediana móvil), Camboya 1975–78 (−26 a −28), Bangladés 1971 (−22), Somalia 1991–92, Bosnia 1992–93, Haití 2010 (−16). TFR: China 1961 (−45 % en log), Japón 1966 (−22 %).
- Volatilidad (mediana entre países, DE de cambios anuales): LEx 0,59 vs 0,017; TFR 0,064 vs 0,005; CNMR 2,75 vs 0,13 → razones 33× / 13,5× / 20×.

### 3.5 P8 fuera de tiempo (crecimiento 10 años después, R²)

| Modelo | 1990 → 2000 | 2003 → 2013 (prueba 2013 → 2021–23) |
|---|---|---|
| Solo TFR | 0,38 | 0,48 |
| TFR + CDR | **0,47** | **0,57** |
| TFR + CDR + CNMR | 0,45 | 0,47 |
| Solo edad mediana | 0,33 | 0,47 |
| Solo crecimiento de hoy | 0,00 | −0,16 |

### 3.6 Figuras guardadas (`docs/asesoria_figs/series_tiempo/`, revisadas una a una)
1. `st01_mortalidad_primero_event_time.png` — **candidata para Slide 2**: 4 paneles regionales; cada país alineado en el inicio de su caída de fecundidad (año 0); medianas de Q5 y TFR como % del propio máximo. Se ve que Q5 ya cae desde −25 años y está en 25–58 % de su máximo en el año 0.
2. `st02_km_rezago_por_ingreso.png` — curvas Kaplan–Meier (método de umbrales 100/4) por ingreso: medio-alto llega al 50 % en 4 años, bajo en 21. Útil para el notebook (P7 por ingreso, con censura).
3. `st03_correlacion_espuria_placebo.png` — histogramas: el mismo país y el placebo dan la misma distribución en niveles (≈ −0,84) y ambas se centran en 0 en cambios. Para notebook/ética.
4. `st04_fan_chart_sigma.png` — **candidata para Slide 4 build 2 (P1)**: LEx se estrecha, edad mediana se abre, Q5 (log) mantiene una banda ancha; proyección en gris.
5. `st05_calendario_choques.png` — barras de países con choque de LEx por año 1950–2100 con eventos que coinciden; la zona proyectada está vacía. Para la franja de ética/limitaciones.
6. `st06_connected_scatter_regiones.png` — trayectoria Q5–TFR de las 8 regiones SDG con flechas; se ve el bucle de Asia Oriental 1959–61. Prototipo: reducir a 4 regiones resaltadas.

---

## 4. Riesgos estadísticos y éticos (ASA 2022)

| Riesgo | Dónde aparece | Mitigación |
|---|---|---|
| **Lenguaje causal** ("mortality decline drives/causes fertility decline", "income speeds up the transition") | Slide 2, recomendaciones | Usar *precedes, follows, goes with*. El panel tipo Granger es **precedencia temporal**, no causalidad (ASA C: separar exploratorio de confirmatorio). |
| **Cherry-picking de umbrales** | H3 (11 años) | Fijar la regla **antes** (inicio −10 %), reportar la rejilla completa en el notebook (ASA A: no interpretar selectivamente). |
| **Selección por censura** | Rezago "solo ambos cruces" | Kaplan–Meier; decir cuántos países faltan y por qué. |
| **Proyecciones como hechos** | "link projected to strengthen", "Europe … 2100", convergencias 1950–2100 | Etiqueta "UN medium projection — a scenario"; ningún estadístico inferencial con años proyectados (ASA B: supuestos y limitaciones). |
| **Series modelizadas y suavizadas** | Rezagos exactos, CCF, choques | Decir que WPP estima/interpola; la autocorrelación de ΔTFR (0,80) infla correlaciones de cambios anuales; preferir cambios de 5–10 años. |
| **Microestados dominando correlaciones** | H5 (−0,36 → +0,10) | Filtro ≥ 1 M para cualquier correlación/regresión y reportar ambas versiones (ASA B: efecto de la variación entre grupos). |
| **Grupo de ingreso actual aplicado al pasado** | Rezago por ingreso | Decir "countries that are low-income today"; no inferir que el ingreso acorta el rezago. |
| **Choques de datos dudosos** | Rep. Centroafricana LEx 14,7 (2009), 18,8 (2022) | Verificar en notas UN; no destacarlos en el vídeo (ASA D: conocer procedencia y revisiones). |
| **Eventos trágicos como "anotaciones"** | Ruanda, Camboya, Bosnia | Nombrar con respeto, sin adjetivos; "coincides with"; no usar como gancho (ASA D: impacto en grupos afectados). |
| **EE ingenuos y múltiples comparaciones** | σₜ ~ t, CCF con 26 rezagos, correlaciones por 8 regiones × 4 ingresos | Newey–West o bootstrap por país; IC en vez de p-valores; declarar cuántas comparaciones se hicieron. |

---

## 5. Cambios concretos propuestos (numerados, en orden de prioridad)

1. **Reemplazar H3 y la variable `rezago = anio_tfr_4 − anio_q5_100`** (plan §3 y §4 Q1 Rico 1) por `inicio_q5`, `inicio_tfr` (regla −10 % sostenido, TFR₁₉₅₀ ≥ 5) y `rezago_inicio`, con KM por ingreso/región. Mantener el método de umbrales solo como sensibilidad (rejilla) en el notebook.
2. **Storyboard Slide 2, build 2**: cambiar el dumbbell `fig04_mortality_first_lag.png` por el **event-time** (st01) y la narración "a median of eleven years before fertility fell below four" por *"In 105 of 108 countries child deaths began to fall first — at least 22 years earlier; by then child mortality had already halved."* Claves nuevas en `numbers.json`: `n_mort_first_onset`, `n_onset`, `lag_onset_median`, `q5_drop_at_tfr_onset`, `lag_onset_low_income`, `lag_onset_uppermid`.
3. **Responder la parte "por ingreso/región" de P7 con el gradiente del rezago** (36 → 25 → 14 años por ingreso; 31 SSA vs 13,5 LAC) — una línea en Slide 2 build 4 o en el mensaje de una línea.
4. **Eliminar H5 del guion y del heatmap "coupling"** (o mostrar ambas versiones); sustituir por Spearman TFR–CNMR global ≥ 1 M con IC (−0,25 [−0,40; −0,11]) en el notebook.
5. **Slide 2 build 3 ("migration has no memory, β ≈ −1")**: sustituir β por la **correlación 1950–2023 entre países (0,14 vs 0,52 TFR)** y por la frase de P8 fuera de tiempo; explicar en el notebook que β ≈ −1 es el placebo.
6. **Añadir a P1 (Slide 4 build 2) la cifra de mortalidad relativa**: razón P90/P10 de Q5 6× → 20×; título del fan chart: *"Closer in life expectancy, further apart in age — and in relative child survival."* (claves `q5_ratio_p90p10_1950`, `_2023`).
7. **β-convergencia (plan Q1 Rico 3)**: usar medias 1950–54 / 2019–23, reportar σ₀ y σ₁ en la misma tabla, Q5 en log y en nivel, placebo para CNMR; quitar la versión 1950–2100 como evidencia.
8. **σₜ ~ t (plan Q3 Simple 2)**: solo 1950–2023, EE Newey–West o banda bootstrap; describir TFR como "rose until 1990, then fell" (no lineal).
9. **Corregir la narración de velocidad (Slide 2 build 1)**: *"East Asia went from five to 2.5 children in 32 years, Latin America in 30; Europe was already below 3 in 1950; sub-Saharan Africa started in 2015 and, on UN projections, gets there around 2065."*
10. **Escalera de R² (Slide 3 build 1)**: añadir la barra "predicting growth 10 years later" (0,48 / 0,57 / 0,47) o, como mínimo, la frase de la identidad en pantalla. Cumple la receta ganadora ★★★3 (comparación honesta fuera de muestra).
11. **Prohibir en el notebook cualquier correlación temporal de niveles** (incluida la de EDA c.68 "Europa 0,94") y añadir la figura placebo (st03) a la sección de métodos/ética.
12. **Panel opcional (plan §4)**: implementarlo con cambios quinquenales, rezagos 0–20 años en ambas direcciones (figura `st03_panel_lag_profile.png` del scratchpad) y reportar solo "fertility responds 5–10 years after child mortality".
13. **Calendario de choques (st05)** en la franja de ética/limitaciones: prueba visual de "projections ≠ forecasts". Revisar antes el caso de la Rep. Centroafricana.
14. **Connected scatter (Slide 2 build 1)**: 4 regiones resaltadas (SSA, E/SE Asia, LAC, Europa & N. América), resto en gris, flecha en 2023, contador de año que cambia a "UN projection" después de 2023.
15. **Unificar FY2026 vs FY2027** de la clasificación del Banco Mundial en plan, README y Referencias; y declarar siempre el universo (237 vs 161) en cada cifra (p. ej. COVID 161/168 vs 118/119).

---

## Anexo — Código R clave (comentarios en español)

```r
# --- Inicio de la caída sostenida (regla de Princeton) y rezago con censura ---
inicio <- function(t, x, frac = 0.9) {        # primer año con x <= 90 % del máximo previo, sin volver a subir
  rm <- cummax(x)
  for (i in seq_along(x)) { lim <- frac * rm[i]
    if (x[i] <= lim && all(x[i:length(x)] <= lim)) return(t[i]) }
  NA_real_                                    # aún no inicia en 2023 -> censurado
}
eleg <- est %>% group_by(ISO3_code, ingreso, region_sdg) %>%           # est = >=1M, Time <= 2023
  summarise(tfr_1950 = TFR[Time == 1950], ini_tfr = inicio(Time, TFR), ini_q5 = inicio(Time, Q5), .groups = "drop") %>%
  filter(tfr_1950 >= 5, !is.na(ini_q5)) %>%
  mutate(tiempo = ifelse(is.na(ini_tfr), 2023 - ini_q5, pmax(ini_tfr - ini_q5, 0)),
         evento = as.integer(!is.na(ini_tfr)))
survival::survfit(Surv(tiempo, evento) ~ ingreso, data = eleg)          # mediana del rezago por ingreso
```

```r
# --- Panel de rezagos distribuidos en cambios quinquenales (ambas direcciones) ---
q <- est %>% filter(Time %% 5 == 0) %>% group_by(ISO3_code) %>% arrange(Time) %>%
  mutate(dTFR = TFR - lag(TFR), dlQ5 = log(Q5) - log(lag(Q5))) %>% ungroup()
pan <- fixest::panel(q, ~ ISO3_code + Time)                             # paso de tiempo = 5 años
feols(dTFR ~ l(dlQ5, 0:4) | ISO3_code + Time, pan, cluster = ~ISO3_code) # mortalidad -> fecundidad
feols(dlQ5 ~ l(dTFR, 0:4) | ISO3_code + Time, pan, cluster = ~ISO3_code) # fecundidad -> mortalidad
```

```r
# --- Placebo de correlación espuria y comparación de especificaciones ---
r_mismo   <- est %>% group_by(ISO3_code) %>% summarise(r = cor(TFR, LEx))  # niveles: ~ -0.84
r_dif     <- est %>% group_by(ISO3_code) %>% summarise(r = cor(diff(TFR), diff(LEx)))  # ~ 0
# placebo: TFR de un país contra LEx de otro país elegido al azar (debe dar ~ lo mismo en niveles)
feols(TFR ~ LEx, est, vcov = "iid")                                      # t ingenuo enorme
feols(TFR ~ LEx | ISO3_code + Time, est, cluster = ~ISO3_code)          # FE dos vías
feols(d(TFR) ~ d(LEx) | Time, panel(est, ~ISO3_code + Time), cluster = ~ISO3_code)  # en cambios
```

```r
# --- σ con banda bootstrap por país y β con chequeo de Galton ---
sig <- g %>% group_by(Time) %>% summarise(sd = sd(log(Q5)), p10 = quantile(Q5, .1), p90 = quantile(Q5, .9))
m <- lm(sd ~ Time, filter(sig, Time <= 2023))
lmtest::coeftest(m, vcov = sandwich::NeweyWest(m, lag = 10, prewhite = FALSE))   # EE con autocorrelación
d <- g %>% group_by(ISO3_code) %>% summarise(x0 = mean(CNMR[Time %in% 1950:1954]), x1 = mean(CNMR[Time %in% 2019:2023]))
coef(lm(I(x1 - x0) ~ x0, d))[2]; c(sd(d$x0), sd(d$x1))                  # β junto a σ0 y σ1
mean(replicate(1000, coef(lm(I(sample(d$x1) - d$x0) ~ d$x0))[2]))       # placebo: ~ -1 sin persistencia
```

```r
# --- Detector de choques: residuo frente a mediana móvil de 9 años ---
choq <- paises %>% group_by(ISO3_code) %>% arrange(Time) %>%
  mutate(res = LEx - as.numeric(runmed(LEx, k = 9, endrule = "median")),
         escala = mad(res[Time <= 2023]),                                 # escala robusta solo con estimaciones
         choque = res <= -1 & res <= -4 * escala) %>% ungroup()
count(filter(choq, choque, grande), Time)                                 # calendario de choques por año
```
