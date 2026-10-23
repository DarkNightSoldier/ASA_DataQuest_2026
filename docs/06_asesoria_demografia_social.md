# 06 — Asesoría de DEMOGRAFÍA y ESTADÍSTICA SOCIAL para el plan y el storyboard

> Asesor: demografía / estadística social · Fecha: 2026-10-22 · Alcance: medición, P7, P8 (+ P1, P4, P5, P6), selección de países, recomendaciones ONU y lenguaje.
> Datos: `WPP2024_Demographic_Indicators_Medium_csv.gz` (países = `ISO3_code` no vacío, 237; ≥ 1 M en 2023 = 161) + `data/raw/wb_api_income_2026-10-22.csv` (Banco Mundial **FY2027**). Solo estimaciones ≤ 2023 salvo que diga "proyección Medium".
> Scripts (R 4.6.1, sin aleatoriedad): `scratchpad/demografia/00_prep.R … 08_extra.R` (`/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/demografia/`). Figuras: `docs/asesoria_figs/demografia/dem01…dem06.png`.
> Todas las cifras son **prototipos**: el agente `notebook-R` las recalcula y las lleva a `figures/numbers.json`. Ya leí `04_etica_ASA_aplicada.md` y `06_asesoria_series_tiempo.md`: no repito lo que dicen; cuando discrepo, lo digo con datos.

---

## 0. Resumen (1 minuto)

1. **El gancho de la portada mezcla dos conteos.** De los 130 países bajo reemplazo (2023), **84 crecen** (no 79); **79** tienen más nacimientos que defunciones. Los 84 = **66 por saldo natural + 18 solo por inmigración**.
2. **Hallazgo más útil para la ONU (P7, inercia):** **22 países y áreas con 2 200 millones de personas** (India, Brasil, México, Filipinas, Viet Nam, Türkiye…) tienen fecundidad bajo reemplazo, **pierden gente por emigración y aun así crecen**: solo por su estructura por edades joven. Pasarían de 2,20 a 2,51 mil M en 2050 (proyección Medium) mientras su edad mediana sube de 29 a 39. Su reto no son los nacimientos: es preparar el envejecimiento mientras todavía crecen.
3. **P8, en una cifra demográfica:** entre los países bajo reemplazo (≥ 1 M), la fecundidad explica el **37 %** de las diferencias de saldo natural; fecundidad + edad mediana, el **83 %**. Con la misma fecundidad (1,5–1,99), el saldo natural va de **−5,9 a +12,4 por 1 000** (fig. `dem01`).
4. **Tres contraejemplos nuevos para P8** (además de EAU/Bielorrusia): Portugal–Chad (misma tasa bruta de mortalidad, 27 años de esperanza de vida de diferencia); El Salvador–Bulgaria (misma fecundidad, saldo natural de signo opuesto); El Salvador–Uzbekistán (misma edad mediana, futuro opuesto). Bonus: Argelia–Lituania (misma esperanza de vida; en una mueren niños, en la otra adultos).
5. **"Migration has no memory" es falso tal como está.** Entre décadas consecutivas la migración neta correlaciona 0,32–0,68 (fecundidad y mortalidad ≥ 0,95) y el 76 % de los países mantiene el signo de los 2000 a los 2010. Es **memoria corta**, no ausencia de memoria (fig. `dem06`).
6. **La ventana 2021–2023 no "suaviza" los choques: los contiene.** Mete el exceso de muertes por COVID-19 (2021: 58 países con más muertes que nacimientos; 2019: 40) y el desplazamiento desde Ucrania en 2022 (Polonia, Chequia, Portugal, Austria y Moldova pasan a "crece solo por migración"). Recomiendo 2023 como base y 2017–2019 como sensibilidad.
7. **China e India dominan los agregados:** China = 46 % de la población de ingreso medio-alto y 30 % de su saldo natural 2000–23; India = 50 % del medio-bajo y 40 % de su saldo natural. La afirmación S11 ("ingreso medio-alto más viejo que el alto en 2050") **es China** y se invierte con la clasificación FY2027.
8. **Las cifras por ingreso dependen de la clasificación:** la ONU agrega con la del Banco Mundial de **mayo de 2024**; nuestro archivo es **FY2027**. Ingreso alto: 1 261 M (ONU) frente a 1 393 M (FY2027). H1 = 71 % (FY2027) pero **64 %** con los agregados ONU o sin Rusia (alto ingreso desde FY2025).
9. **Mortalidad bien medida:** en 2023 r(CDR, LEx) = **0,03**; r(Q1560, LEx) = −0,96. La tasa bruta de mortalidad ya no compara salud entre países (fig. `dem03`).
10. **ODS 3.2 (Q5 ≤ 25 ‰ en 2030):** de 70 países por encima en 2023, **solo 8 bajan al ritmo necesario** (mediana observada 3,2 %/año; necesaria 8,2 %/año); 58 seguirían por encima en 2030 incluso en la proyección Medium (44 en África subsahariana), con el 43 % de los nacimientos de 2030 y el 71 % de las muertes de menores de 5 de 2023 (fig. `dem05`).
11. **Línea de tiempo de las "palancas":** países con más defunciones que nacimientos: 8 (1990) → **53 (2023)** → 106 (2050, proyección). Población que vive en ellos: 2 % → **28 %** → 32 % (fig. `dem02`).

---

## 1. Evaluación del plan (`00_plan_analitico.md`) y del storyboard (`00_storyboard_diapositivas.md`)

### 1.1 Lo que está bien desde la demografía (mantener)
- **Plan §1 (tesis)**: leer las tres componentes juntas es exactamente el marco del *demographic balancing equation* que usa la propia ONU (Methodology, §I.B). Muy defendible.
- **Plan §3 "Identidad contable"**: presentarla como identidad y no como hallazgo. Confirmado: `PopChange = NatChange + NetMigrations` con residuo máximo de 4,9 mil (Ucrania 1989); solo 0,1 % de los país-año ≥ 1 M supera 0,5 %.
- **Plan §3 "Países vs agregados", "Microestados" y "Estimaciones vs proyecciones"**: correctos y necesarios.
- **Plan §4 Q2 "Simple 3" (CDR cambia de significado)**: es un punto que un demógrafo aplaude; ahora vive en la recomendación de la Slide 4 (bien), pero recomiendo devolverlo como frase en la Slide 3 (ver §5, cambio 9).
- **Storyboard §2 notas**: regla "top-3 por población" para los ejemplos narrados de cada tipo. Es la forma correcta de evitar *cherry-picking* (ver §2.5).

### 1.2 Lo que un demógrafo (o un funcionario de UN DESA) objetaría

| # | Dónde | Qué dice | Problema | Evidencia (2023 salvo indicación) | Arreglo |
|---|---|---|---|---|---|
| O1 | Plan §1; Storyboard §1 narración y §7 | "79 still grow" | 79 = nacimientos > defunciones; los que **crecen** son 84 | TFR < 2,1: A 44 · B 22 · C 18 · D 33 · E 13 | Gancho nuevo (§5, cambio 1) |
| O2 | Storyboard §1 | "fewer than 2.1 children per woman" | El reemplazo depende de la mortalidad: TFR/NRR va de 2,06 a **2,60** (Nigeria) en 2023 (≥ 1 M); mediana 2,77 en 1950 | NRR < 1 también da 130, pero cambian 4 países: entran **Indonesia** (TFR 2,13; NRR 0,993) y Myanmar; salen Guadalupe e I. Vírgenes EE. UU. | Definir con NRR en el notebook; en voz: "about 2.1 children where almost every child survives" |
| O3 | Plan §3 "Migración volátil"; `06_asesoria_series_tiempo` §1.1 | promedio 2021–23 "suaviza COVID-19 y Ucrania" | La ventana **incluye** ambos choques | Tipo C: 18 (2023) · 24 (2021–23) · 14 (2017–19); en 2021–23 Polonia entra en C por las llegadas de 2022 | 2023 como base; 2017–19 y 2021–23 como sensibilidad |
| O4 | Plan §3 "Ingreso"; Storyboard §5 build 4 y §6 | "FY2026" | El archivo es **FY2027** (coincide con `04_etica` #17) | — | Corregir etiqueta |
| O5 | Plan §4 Q1 "Simple 1", columna Validación | "comparar suma de países vs agregado ONU por ingreso" | Falla por construcción: la ONU usa la clasificación de mayo 2024 | Alto 1 393 vs 1 261 M; medio-bajo 2 871 vs 3 253 M | Validar solo contra regiones SDG y "World" |
| O6 | Plan §5 H1; Storyboard Slide 1 | "71 % of growth = migration" | Depende de la clasificación y de Rusia | 70,7 % (FY2027) · 64,5 % sin Rusia · 64,0 % agregados ONU | Narrar "about two-thirds" o fijar FY2027 y dar el rango en el pie |
| O7 | Storyboard Slide 1, mensaje | "Rich countries grow by migration; the rest by births" | Es el agregado: **26 de 50** países de ingreso alto ≥ 1 M aún tienen más nacimientos que defunciones (EE. UU., Francia, Reino Unido…) | — | Frase en §5, tabla de redacción |
| O8 | Storyboard §2 notas (provisionales) | C = DE, ES, FI; D = JP, IT, KR; E = NP, UY, AL | La regla "top-3 por población, ≥ 1 M" da otra cosa | 2023: C = DEU, ESP, BEL · D = **CHN, RUS, JPN** · E = NPL, AZE, URY (2021–23: C = DEU, ESP, **POL**; E = ALB, XKX, MUS) | Dejar que la regla mande; nombrar a China en D es correcto e informativo |
| O9 | Plan §10 P7; §6 S2 | "8 con TFR ≥ 2,1 decrecen por emigración" | Son **6** (Mónaco y Niue decrecen por saldo natural) y todos < 110 mil hab. (Tonga, Tuvalu, Islas Marshall…). Ningún país ≥ 1 M | — | Usar el contraejemplo histórico (§2.2) |
| O10 | Storyboard Slide 2 título y narración; build 3 | "migration has no memory" | Memoria corta, no nula; el 0,14 sale de comparar dos años sueltos con 73 años de distancia | Décadas: 0,68 · 0,66 · 0,60 · 0,32 · 0,47 · 0,67; autocorrelación anual (1990–2023) 0,72 | "Migration has a short memory" (fig. `dem06`) |
| O11 | Storyboard Slide 2 narración | "in rich countries it fills the gap that low fertility leaves" | Demográficamente falso como mecanismo (la "replacement migration" de la ONU, 2000, mostró volúmenes inverosímiles) y evoca el "gran reemplazo" (ver `04_etica` #19) | — | Frase alternativa en §5 |
| O12 | Plan §6 S11; §7 "Fast movers" | "ingreso medio-alto más viejo que el alto en 2050" | Es China: con FY2027 y media ponderada de edades medianas se invierte (44,5 vs 44,8); sin China el medio-alto queda en ≈ 39 | Agregados ONU: 44,8 vs 44,5 | "By 2050 China's median age is projected to pass the high-income average" |
| O13 | Storyboard Slide 4 narración | "will age faster than anyone before" | Falso: Corea tardó 17 años en pasar de edad mediana 30 a 40, Japón 21; China 23 | Mediana: 40,5 años (cruzaron 30 antes de 1990) vs 24 (cruzan 1990–2023); Italia 45, EE. UU. 49 | "will age in about 25 years what Europe took 40 to 50" |
| O14 | Storyboard Slide 2 narración; plan §4 Q3 | "Everyone heads to the bottom-left corner" | Teleología: la convergencia futura es **supuesto** del modelo de la ONU (fase III de fecundidad, doble logística de LEx) | `02_contexto_historico` §1 | "Every region has moved the same way — at very different speeds" |
| O15 | Storyboard Slide 4; plan §7 | "child survival is the lever that unlocks the rest"; "44/58 africanos no llegan a edad mediana 40" | Causal y determinista; además homogeneiza África | Mauricio: TFR 1,24, edad mediana 36,9, decrece | Ver §4 y frases de §5 |
| O16 | Plan §4 Q3 "Simple 2" (P1) | LE60 del suplemento | La guía oficial (§4, nota) dice que LE60 no está en los archivos; el suplemento lo extrajeron los organizadores del portal | LE65 (archivo oficial): DE 1,47 (1950) → 2,85 (2023) → 3,58 (2050) | LE65 como principal, LE60 como robustez (crédito a organizadores) |

---

## 2. Recomendaciones de medición e interpretación por pregunta

### 2.1 Medición correcta (comprobado en el archivo)

| Trampa | Qué verifiqué | Regla para el notebook | Frase simple (EN) |
|---|---|---|---|
| **Ecuación de balance** | Se cumple exactamente (ver O-1.1) | Presentar como contabilidad; el hallazgo es qué término domina | *"Population change is bookkeeping: births minus deaths, plus people arriving minus people leaving."* |
| **1 de enero vs 1 de julio** | `PopChange(t) = P1Jan(t+1) − P1Jan(t)` exacto; `TPopulation1July` = media de dos 1 de enero (error 0,0005 mil). Usar ΔP1July como "cambio" se desvía 1,6 % (mediana) y hasta 2× en años de choque: Siria 2008, ΔP1July = +340 mil frente a PopChange = +174 mil | Cambios siempre con `PopChange` o con 1 de enero; niveles con 1 de julio | — |
| **Crecimiento exponencial vs aritmético** | `PopGrowthRate = 100·ln(P1Jan(t+1)/P1Jan(t))` (error < 0,0005). La versión aritmética (PopChange/P1July) difiere hasta 2,85 pp: Kuwait 1990 −71,1 % vs −68,2 % | Acumular con `exp(Σ r/100)`; para participaciones usar **sumas de personas**, nunca sumas de tasas | *"Growth rates compound — we add people, not percentages."* |
| **‰ vs %** | `NatChangeRT` y `CNMR` van por 1 000; `PopGrowthRate` en %. `NatChangeRT + CNMR ≈ 10 × PopGrowthRate`, con desvíos de 28 ‰ (Kuwait 1990) y 45 ‰ (Santa Sede) por la base y el logaritmo | Nunca sumar % con ‰; ejes con unidad explícita | *"per 1,000 people per year"* |
| **CDR no mide mortalidad en poblaciones envejecidas** | r(CDR, LEx) = −0,96 (1950) → **0,03** (2023, Pearson; Spearman 0,07) → ≈ +0,42 hacia 2060 (proyección). r(Q1560, LEx) entre −0,93 y −0,96 y r(log Q5, LEx) entre −0,89 y −0,96 en todo 1950–2023. Japón CDR 12,3 y LEx 84,7; Nigeria CDR 11,7 y LEx 54,5; Qatar CDR 0,9 | Comparar mortalidad con LEx, Q5, Q1560 y LE65; CDR solo como "carga de defunciones" (demanda de servicios) | *"The crude death rate counts deaths; it no longer compares health."* |
| **TFR vs NRR vs CBR** | Ver O2. CBR depende de la edad: con TFR ≈ 1,75, CBR = 9,2 (Bulgaria) vs 15,8 (El Salvador). TFR es medida de **periodo**: el aplazamiento de la maternidad la deprime (efecto *tempo*; Corea 0,72) | TFR para "comportamiento actual"; NRR para "reemplazo"; CBR nunca para comparar fecundidad | *"Children per woman measures behaviour; the birth rate also measures age."* |
| **Migración neta (CNMR/NetMigrations)** | (i) Solo saldo neto; (ii) a menudo **residuo** entre censos, así que absorbe errores de nacimientos y defunciones (Methodology §I.D); (iii) la suma mundial se fuerza a 0 (verificado: \|Σ\| ≤ 0,003 mil por año, 4,4 mil en 2050); (iv) en proyección hay supuestos de expertos: Golfo fijo ≈ +0,6 ‰ desde 2030 (EAU 28,2 ‰ en 2023 → 0,65 en 2030); **Ucrania +1,15 M (2024) y +1,70 M (2025)** por retorno supuesto de 2/3 de los refugiados; Sudán del Sur 39,6 (2023) → 0,5 ‰ (2025); la volatilidad anual proyectada es **21× menor** (mediana DE de cambios 1,84 vs 0,10) | Nunca leer la migración proyectada como pronóstico; marcar los saltos 2024–25 de Ucrania como supuesto | *"Net migration is arrivals minus departures — the least certain number in the file."* |

### 2.2 P7 — fecundidad, mortalidad y migración por región e ingreso

**Lectura de la tipología A–E (plan §3) con la teoría de la transición.** Es una foto de Webb, no una etapa; pero se mapea así: A/B con saldo natural alto = transición en curso (fases 2–3); **A/B con TFR bajo reemplazo = fase de inercia** (*momentum*: población joven que sigue sumando aunque cada mujer tenga < 2 hijos); C = post-transición con decrecimiento natural compensado por inmigración; D = post-transición sin compensación; **E puede darse en cualquier etapa** (es la palanca migratoria dominando). Recomiendo decirlo en una línea en pantalla: `Lever type = which term of the balance dominates today — not a stage of development.`

**Cómo mostrar que la MISMA fecundidad baja da crecimiento o decrecimiento** (fig. `dem01`): los 39 países ≥ 1 M con TFR 1,5–1,99. Círculo = saldo natural; flecha = migración neta; punta = crecimiento total. El saldo natural va de −5,9 a +12,4 ‰ y sigue a la edad mediana (r = −0,91), no a la fecundidad. La migración desplaza después el resultado (Kosovo cae de +6,2 a −10,7 ‰; Armenia sube de +2,4 a +27,9 ‰). Frase: *"Same fertility, opposite directions: age structure decides the sign of births minus deaths; migration then shifts the total."*

**Comprobaciones pedidas:**
- *Bajo reemplazo que crecen por inercia, no por migración* (tipo B con TFR < 2,1): **22 países/áreas, 2 200 M personas**; ≥ 1 M: India (TFR 1,98; saldo natural +9,5 ‰; migración −0,7 ‰; crece 0,89 %/año), Brasil, México, Filipinas, Viet Nam, Türkiye, Venezuela, Rep. Pop. Dem. de Corea, Sri Lanka, Ecuador, Túnez, El Salvador, Jamaica. Con NRR < 1 en vez de TFR: 24 y 2 540 M (entra Indonesia).
- *El "reloj" de la inercia* (años entre TFR < 2,1 y el pico de población): China 1991 → 2021 (**30 años, observado**); Brasil 2002 → 2042; Viet Nam 1998 → 2049; Türkiye 2010 → 2047; India 2020 → 2061 (proyección Medium). Frase: *"Falling below replacement doesn't stop growth: China kept growing for thirty years after it did."*
- *TFR alta que decrece por emigración*: hoy solo islas pequeñas (Tonga 3,13; Tuvalu 3,21; Islas Marshall 2,92). Con ≥ 1 M y TFR ≥ 3, en 1950–2023 hubo 31 países con años de decrecimiento pese a más nacimientos que defunciones: **Irlanda 1952–60 (TFR 3,5), Portugal 1963–70 (3,1)**, Afganistán 1979–2000, Siria 2012–15, Kuwait 1990–94. Usar Irlanda y Portugal como contraejemplo **no estigmatizante**: *"In the 1950s Ireland had 3.5 children per woman and still shrank — emigration can outweigh births at any stage."*

**Región e ingreso (P7 literal).** Por ingreso, la participación de la migración en el crecimiento 2000–23 (sumas de países FY2027): bajo −3,7 %; medio-bajo −8,6 %; medio-alto −4,6 %; alto +70,7 %. La heterogeneidad **dentro** de los grupos importa tanto como entre grupos: África subsahariana va de TFR 1,24 (Mauricio) a 6,13 (Somalia), LEx 54,5 (Nigeria) a 74,9 (Mauricio), edad mediana 14,3 (Rep. Centroafricana) a 36,9 (Mauricio).

**China e India.** (a) En las líneas por ingreso o región, mostrar el agregado ONU **y** "sin China" / "sin India" (o la mediana de países): TFR medio-bajo 2023 = 2,55 (agregado ONU), 3,15 (mediana de países), 3,39 (ponderado sin India). (b) En las barras de descomposición, separar a China dentro de medio-alto y a India dentro de medio-bajo (segmento con borde), porque aportan 30 % y 40 % del saldo natural 2000–23 de su grupo. (c) Nunca atribuir a "upper-middle-income countries" un resultado que es de China (O12). (d) En mapas y modelos, el país es la unidad: no hace falta corrección.

### 2.3 P8 — ¿un indicador cuenta toda la historia?

**Qué "cuenta más" en demografía.** La **edad mediana** resume la historia pasada (es un *stock*: memoria de 70 años de nacimientos, muertes y migración); la **TFR** resume el comportamiento actual (un *flujo* de periodo, sesgado por el calendario); la **LEx** resume el nivel de mortalidad pero no quién muere; el **crecimiento** es la suma de los tres. Ninguno basta porque cada uno pierde una dimensión que los otros sí tienen; lo prueba que entre los países bajo reemplazo el saldo natural se explica 37 % con la TFR y 83 % con TFR + edad mediana.

**Contraejemplos (2023, ≥ 1 M, elegidos por regla de búsqueda y no a mano: |Δ| mínimo en un indicador, máximo contraste en otro, excluyendo los pares ya usados en el plan):**

| Mismo… | Par | Valores iguales | Lo que diverge | Frase (EN) |
|---|---|---|---|---|
| Tasa bruta de mortalidad (\|Δ\| < 0,1) | **Portugal – Chad** | CDR 11,1 vs 11,0 | LEx 82,4 vs 55,1; edad mediana 46,2 vs 15,4 | *"Same death rate, 27 years apart in life expectancy."* |
| Fecundidad (\|Δ\| < 0,03), signo opuesto del saldo natural | **El Salvador – Bulgaria** | TFR 1,78 vs 1,75 | Saldo natural +8,2 vs −5,9 ‰; crecimiento +0,46 vs −0,52 %/año (¡El Salvador con emigración neta −3,7 ‰!) | *"Same fertility; one grows despite emigration, the other shrinks despite immigration."* |
| Edad mediana (\|Δ\| < 0,3) | **El Salvador – Uzbekistán** | 27,0 vs 26,9 años | TFR 1,78 vs 3,50; crecimiento +0,46 vs +2,01 %/año; población 2100 (2023 = 100): 80 vs 209 (proyección) | *"Same median age, opposite futures."* |
| Esperanza de vida (\|Δ\| < 0,3) | Argelia – Lituania | LEx 76,3 vs 76,0 | Q5 21,2 vs 3,2 (6,5×); Q1560 73 vs 140 (1,9× al revés) | *"Same life expectancy: in one, children die; in the other, working-age adults."* |
| Crecimiento (\|Δ\| < 0,02 pp) | India – Lituania | 0,885 vs 0,891 %/año | Saldo natural +9,5 vs −6,8 ‰; migración −0,7 vs +15,7 ‰ | *"Same growth, opposite engines."* |

Propuesta para la tarjeta de gemelos (Slide 3, build 2): **El Salvador como "personaje"** con sus dos gemelos (fig. `dem04`): *"El Salvador has Bulgaria's fertility and Uzbekistan's median age — and neither's future."* Una sola tarjeta enseña que TFR y edad mediana son complementarias. Respuesta de una frase a P8: *"Median age tells where a country has been, fertility where it is heading, migration how fast it can change course — the story needs all three."*

### 2.4 Notas breves para P1, P4, P5, P6
- **P1**: LE65 del archivo oficial (DE ×2,4 entre 1950 y 2050) como medida "relevante para la dependencia"; frase: *"Countries converged in life at birth but are pulling apart in life after 65."* Toda dispersión después de 2023 es proyección.
- **P4**: la descomposición por sumas de personas es correcta; añadir la sensibilidad de ventanas (tabla 3.2) y el rango 64–71 % (O6).
- **P5**: un índice con "edad mediana +" y "TFR −" ordena por **etapa de la transición**, no por desarrollo ni bienestar: llamarlo *transition-stage index* y no incluir CDR.
- **P6**: nombres por comportamiento, bien; validar los grupos con variables externas que no los definen (p. ej., Q1560, LE65, ingreso), no con TFR/LEx/CNMR.

### 2.5 Países emblemáticos sin *cherry-picking* (regla explícita y reproducible)
**Regla 1 (región):** en cada región SDG (≥ 1 M), el **más poblado** ("el típico") y el **más atípico** = mayor distancia euclídea estandarizada (DE entre países: saldo natural 11,4 ‰; migración 7,9 ‰) al agregado ONU de la región en (tasa de saldo natural, tasa de migración neta), promedios 2021–23. Archivo: `scratchpad/demografia/emblematicos_por_region.csv`.

| Región SDG | Más poblado (nat / mig ‰) | Más atípico (nat / mig ‰) | Región (nat / mig ‰) |
|---|---|---|---|
| África subsahariana | NGA (21,2 / −0,3) | **MUS** (0,2 / −2,6) | 24,9 / 0,1 |
| N. África y Asia occidental | EGY (15,0 / 1,0) | ARE (8,3 / 34,1) | 15,2 / 1,9 |
| Asia central y meridional | IND (8,8 / −0,6) | AFG (29,4 / −10,2) | 11,5 / −1,5 |
| Asia oriental y sudoriental | CHN (−1,1 / −0,3) | SGP (3,3 / 11,6) | 1,2 / −0,2 |
| América Latina y el Caribe | BRA (4,9 / −1,1) | PRI (−5,1 / 3,0) | 7,0 / −0,7 |
| Europa y Norteamérica | USA (1,4 / 3,2) | UKR (−8,8 / −48,8) | −1,6 / 2,3 |
| Australia/Nueva Zelandia | AUS | NZL | — |
| Oceanía (excl. AUS/NZ) | PNG (único ≥ 1 M) | — | — |

**Regla 2 (personajes del vídeo, 5):** el país ≥ 1 M **más poblado de cada tipo de palanca en 2023**: A = **EE. UU.**, B = **India**, C = **Alemania**, D = **China**, E = **Nepal** (con 2021–23: Albania). Ventaja: son reconocibles, cubren cuatro regiones y la regla se escribe en una línea en el notebook. Para la heterogeneidad africana, añadir el par de la Regla 1: **Nigeria (típico) vs Mauricio (atípico)**. Ucrania sale como atípico por desplazamiento forzado: si se muestra, con la denominación de la ONU y sin juicio.

---

## 3. Comprobaciones sobre datos reales (resumen) y figuras

**3.1 Gancho (2023, 237 países).** TFR < 2,1: 130 (67 % de la población mundial); NRR < 1: 130 (71 %). Crecen 84 (A 44 + B 22 + C 18); nacimientos > defunciones 79 (A + B + E 13); decrecen 46 (D 33 + E 13).

**3.2 Tipos de palanca según ventana** (todos / ≥ 1 M):

| Ventana | A | B | C | D | E |
|---|---|---|---|---|---|
| 2023 | 71 / 48 | 94 / 72 | 18 / 11 | 35 / 24 | 19 / 6 |
| 2021–23 | 73 / 51 | 92 / 71 | 24 / 14 | 31 / 22 | 17 / 3 |
| 2017–19 (pre-COVID) | 88 / 61 | 87 / 68 | 14 / 7 | 22 / 16 | 26 / 9 |

Concordancia 2023 vs 2021–23: 88,6 % (27 cambios; la mayoría A↔B por migración cercana a 0, y D→C por las llegadas de 2022).

**3.3 Línea de tiempo de la palanca natural** (países con nacimientos < defunciones / % de la población mundial): 1950: 2 / 1 % · 1960: 2 / **22 %** (hambruna en China, un año) · 1990: 8 / 2 % · 2000: 20 / 7 % · 2019: 40 · 2021: 58 / 28 % (China desde 2021) · **2023: 53 / 28 %** · 2050: 106 / 32 % · 2100: 164 / 52 % (proyección; EE. UU. y Brasil cruzarían en 2042–43, India en 2063).

**3.4 ODS 3.2.** Q5 > 25 ‰ en 2023: 70 países (3 480 M hab.). Ritmo observado 2015–23 ≥ ritmo necesario 2023–30: **8 de 70**. Siguen > 25 ‰ en 2030 (Medium): 58 (44 África subsahariana, 3 Asia central y meridional, 3 Asia oriental y sudoriental, 4 ALC, 2 N. África y Asia occ., 2 Oceanía; 23 de ingreso bajo, 28 medio-bajo, 7 medio-alto). Los más grandes: Nigeria (Q5 104 → 97 en 2030), Pakistán (59 → 51), R. D. del Congo (73 → 67), Etiopía (45 → 35). Coherente con lo que reporta el UN IGME; nuestro aporte es cruzarlo con la palanca: en esos países el crecimiento es casi 100 % natural.

**3.5 Otras cifras de apoyo.** Envejecimiento: años de edad mediana 30 → 40: Corea 17, Cuba 19, Japón 21, China 23 (2002 → 2025, proy.), Brasil 24 (proy.), Italia 45, EE. UU. 49 (proy.). Nacimientos de madres de 15–19 años (% del total, 2023): África subsahariana 15,3; **ALC 14,1** (casi igual, con menos de la mitad de fecundidad); Europa y Norteamérica 3,0.

**Figuras guardadas** (`docs/asesoria_figs/demografia/`, revisadas una a una):
- `dem01_misma_fecundidad_inercia.png` — 39 países con TFR 1,5–1,99: saldo natural (círculo) y migración (flecha) contra edad mediana. Candidata a sustituir o acompañar el mapa como "momento P7".
- `dem02_muertes_superan_nacimientos.png` — número de países con más defunciones que nacimientos y % de la humanidad que vive en ellos, 1950–2100 (estimación sólida, proyección gris).
- `dem03_cdr_no_mide_salud.png` — CDR vs LEx 2023 coloreado por edad mediana (Portugal–Chad marcado) + correlación de LEx con CDR, Q5 y Q1560 por año.
- `dem04_el_salvador_dos_gemelos.png` — TFR, edad mediana y población (2023 = 100) de El Salvador, Bulgaria y Uzbekistán, 1950–2100.
- `dem05_ods32_ritmo.png` — ritmo de reducción de Q5 observado (2015–23) vs necesario (2023–30) para los 70 países > 25 ‰; tamaño = nacimientos.
- `dem06_memoria_migracion.png` — correlación entre décadas consecutivas: fecundidad, mortalidad y esperanza de vida ≥ 0,95; migración 0,32–0,69.

---

## 4. Riesgos interpretativos y éticos (lo que añado a `04_etica_ASA_aplicada.md`)

1. **Determinismo y teleología.** La transición es un patrón histórico, no una ley: hubo reversiones (VIH en África austral, crisis postsoviética, Siria) y la convergencia 2024–2100 está **impuesta por el modelo** de proyección. Nunca "Africa will", siempre "the UN medium projection assumes".
2. **Falacia ecológica.** Correlaciones entre países (r = −0,91 saldo natural–edad mediana) no dicen nada de decisiones de hogares o mujeres. Decir "countries where…", nunca "women who…".
3. **Composición de los agregados.** China e India (§2.2) y Rusia en ingreso alto (O6): todo resultado por grupo debe pasar la prueba "¿se sostiene sin el país más grande?".
4. **Calidad desigual de los datos.** La migración es residuo y hereda los errores de nacimientos y defunciones; Nigeria (personaje propuesto) tiene su último censo en 2006 (`04_etica` #2). Si Nigeria o el Golfo aparecen, nota de calidad en el pie.
5. **Ventanas y choques.** Clasificar la palanca en 2021–23 convierte el desplazamiento forzado de 2022 en "crecimiento por migración" de Polonia: puede leerse como trivializar una crisis humanitaria. 2023 + sensibilidad.
6. **Estigma territorial.** El mapa con África en un solo color de "alta fecundidad" borra a Mauricio, Cabo Verde (TFR 1,52) o Sudáfrica (2,22). Pequeños múltiplos o etiquetas de 2–3 casos contrarios. La emigración no es "de países pobres": Irlanda y Portugal (§2.2).
7. **Pronatalismo y "crisis".** No presentar la fecundidad baja como problema a corregir ni la alta como amenaza; la ONU (WPP2024, *Key messages*) y la CIPD hablan de **que las personas puedan tener los hijos que desean**. Evitar *population explosion, demographic time bomb, overpopulation, ageing crisis, dependency burden*.
8. **Terminología ONU** (complementa la tabla de `04_etica` §2.6): *older persons* (no *the elderly*); *low-income countries* (no *poor*); *people living with HIV*, *the HIV/AIDS epidemic*; *refugees and asylum-seekers*, *forced displacement* (ACNUR); *migrants*, *international migration* (nunca *illegal*, *wave*, *flood*); *the 1994 genocide against the Tutsi in Rwanda*; *sexual and reproductive health and rights*, *voluntary family planning*; *women and adolescent girls*; *State of Palestine*, *Kosovo (under UNSC res. 1244)*, *China, Taiwan Province of China* tal como en `Location`; *demographic dividend = a window of opportunity*, no una garantía.

---

## 5. Cambios concretos al plan y al storyboard (para `integrate-advice`)

1. **Gancho (Plan §1, Storyboard §1 y §7):** `n_below_repl_growing_2023` = **84** (PopChange > 0). Narración: *"In 2023, 130 of 237 countries had fertility below replacement. You would expect them to shrink. Yet 84 are still growing — 66 because births still outnumber deaths, 18 only because more people arrive than leave. One number can't explain that."* Añadir clave `n_below_repl_natural_growth_2023` = 66.
2. **Ventana de la palanca (Plan §3 "Migración volátil" y §4 Q1 "Simple 2"):** base = **2023**; sensibilidad = 2017–19 y 2021–23 (tabla 3.2 en el notebook). Esto también hace coherentes portada (18) y mapa.
3. **Ingreso (Plan §3; Storyboard §5 build 4 y §6):** FY2027; borrar la validación contra agregados ONU por ingreso (O5); `share_mig_high_2000_2023` con nota "64–71 % depending on World Bank classification vintage".
4. **Nueva figura P7 (Plan §4 Q1, capa "Simple 3"; Storyboard Slide 2 build 3):** sustituir `fig05_memory_beta.png` por `dem01` (misma fecundidad, direcciones opuestas). Texto en pantalla: `Same fertility (1.5–2.0): births − deaths from −6 to +12 per 1,000 — set by age structure`. Claves: `n_band_tfr`, `nat_min_band`, `nat_max_band`, `r_nat_medage_band`.
5. **Hallazgo de inercia como frase de la Slide 2:** clave `n_momentum_countries` = 22, `pop_momentum_bn` = 2.2; *"2.2 billion people live in countries with below-replacement fertility that still grow even though more people leave than arrive."*
6. **Migración (Storyboard Slide 2, título y narración):** "has no memory" → *"migration has a short memory"*; cifra `r_cnmr_decades_2000s_2010s` = 0,67 vs `r_tfr_decades` ≥ 0,95. Mantener Siria/Ucrania como ejemplos de cambio brusco.
7. **Ejemplos por tipo (Storyboard §2):** regenerar con la regla; con 2023 la narración queda *"Blue: Germany, Spain, Belgium… Red: China, Russia, Japan… Orange: Nepal, Azerbaijan, Uruguay"*. Mencionar en pie que China está en D desde 2021.
8. **Gemelos (Plan §4 Q2 "Simple 2"; Storyboard Slide 3 build 2):** añadir la regla de búsqueda de §2.3 al notebook y una tarjeta **El Salvador + 2 gemelos** (`dem04`); mantener EAU–Bielorrusia si el tiempo lo permite, quitar Jordania–Bosnia si falta espacio.
9. **CDR (Storyboard Slide 3):** recuperar una línea en el pie del scorecard: *"Even the death rate changed meaning: in 2023 it tracks age, not health (Portugal and Chad: same rate, 27 years apart)."*
10. **S11 (Plan §6; §7 fast movers):** reformular como China; añadir sensibilidad "sin China" en el notebook.
11. **Fast movers (Storyboard Slide 4):** "faster than anyone before" → *"will age in about 25 years what Europe took 40 to 50"* (claves `yrs_medage30_40_early`, `yrs_medage30_40_recent`).
12. **P1 (Plan §4 Q3 "Simple 2"):** LE65 principal, LE60 robustez; frase de §2.4.
13. **S2/§10 (Plan):** corregir a 6 países pequeños; añadir el contraejemplo Irlanda 1950s / Portugal 1960s al notebook (y, si cabe, a la voz de la Slide 1).
14. **Personajes (Storyboard §8 / plan de figuras):** USA, India, Germany, China, Nepal (+ Nigeria–Mauricio para África), regla escrita en `R/config.R`.
15. **Recomendaciones (Plan §7; Storyboard Slide 4 build 3):** sustituir por la tabla de abajo; cada fila apunta a una figura.

**Tabla "Which lever, where, when" revisada** (texto en pantalla en inglés; filas por **estado de la palanca**, que es lo que demuestra Q1; los clusters de Q3 quedan como contexto):

| Countries where… (data) | What to watch / prepare | UN mandate | Agency | Horizon |
|---|---|---|---|---|
| **child deaths are still falling too slowly** — 58 of 70 above 25 per 1,000 stay above it in 2030 even in the UN projection; only 8 on pace (`dem05`) | child survival, antenatal and newborn care; voluntary family planning and births to adolescent girls (also in Latin America: 14 % of births) | SDG 3.2, 3.7; ICPD PoA | UNICEF · WHO · UNFPA | **by 2030** |
| **fertility is below replacement but the population still grows** — 22 countries, 2.2 bn (India, Brazil, Mexico…) (`dem01`) | plan for 30–40 more years of growth in working and older ages; build pension and long-term-care systems now; no pronatalist alarm | Decade of Healthy Ageing; MIPAA; SDG 1.3 | UN DESA · WHO · ILO | **2030–2060** |
| **deaths already outnumber births** — 53 countries, 28 % of humanity; 106 by 2050 (`dem02`) | healthy longevity (old-age gap widening: SD of LE65 1.5 → 2.9 years); measure mortality with life expectancy and adult mortality, not the crude death rate (`dem03`) | Decade of Healthy Ageing; SDG 3.4 | WHO · UN DESA | **now–2040** |
| **net immigration is the only source of growth** — 18 countries (Germany, Spain, Belgium…) | migrant inclusion and better arrival/departure data; read UN migration projections as scenarios | Global Compact for Migration, obj. 1 & 16; SDG 10.7 | IOM · UN DESA | **now** |
| **emigration outweighs births** — Nepal, Albania, Kosovo, Pacific islands (`dem01`) | decent work, safe return and diaspora links (UN: may slow decline more than fertility policy) | GCM obj. 2 & 19; SDG 8.8 | IOM · ILO | **now** |
| **all countries (data)** | census and civil registration; publish lever type with sensitivity windows; never rank health with crude death rates | SDG 17.18–17.19 | UN DESA · UNSD · UNFPA | **2030 census round** |

**Qué añadimos a lo que ya dice WPP2024 (*Key messages*)**: la ONU habla de picos de población, *momentum* hasta 2054 y migración proyectada (52 países con inmigración como motor). Nosotros aportamos (i) el **estado actual** de la palanca con 70 años de historia (8 → 53 países con decrecimiento natural), (ii) la **cuantificación de la inercia hoy** (2 200 M crecen sin migración y bajo reemplazo; el "reloj" de 30–50 años), (iii) una **advertencia de medición** útil para la OMS (CDR, misma LEx con distinta mortalidad por edad) y (iv) el **ritmo** del ODS 3.2 cruzado con la palanca.

**Frases del guion que un demógrafo o un funcionario objetaría → redacción alternativa (EN):**

| Original | Alternativa |
|---|---|
| *"Yet seventy-nine still grow"* | *"Yet 84 are still growing — 66 from births, 18 only from net immigration."* |
| *"fewer than 2.1 children per woman"* | *"below replacement — about 2.1 children per woman where almost every child survives."* |
| *"Rich countries grow by migration; the rest grow by births"* | *"Since 2000, about two-thirds of the growth of high-income countries came from net migration; elsewhere, births did."* |
| *"18 countries would shrink without immigration"* | *"In 18 countries deaths already outnumber births; net immigration is what keeps them growing."* |
| *"it has no memory"* | *"Migration has a short memory: it persists for a decade, then can flip."* |
| *"in rich countries it fills the gap that low fertility leaves"* | *"In high-income countries, net migration now accounts for most population growth."* |
| *"Everyone heads to the bottom-left corner"* | *"Every region has moved the same way — at very different speeds."* |
| *"will age faster than anyone before"* | *"will age in about 25 years what Europe took 40 to 50."* |
| *"child survival is still the lever that unlocks the rest"* | *"child survival is where progress is most urgent — and fertility has tended to fall after it."* |
| *"By 2023 the crude death rate no longer measures mortality"* | *"In 2023 a high crude death rate signals an old population, not poor health."* |
| *"Migration-boosted states — the Gulf — depend on flows that can reverse"* | *"In the Gulf, population size depends on labour migration, which can change quickly."* |
| *"which levers really move a country's population"* | *"how births, deaths and migration add up in each country."* |
