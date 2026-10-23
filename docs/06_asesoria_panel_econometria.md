# 06 — Asesoría de ECONOMETRÍA DE PANEL para P7 (asociación, no causalidad)

> Asesor: econometría de datos de panel · Fecha: 2026-10-22 · Alcance: **P7** (fecundidad–mortalidad–migración por región, país e ingreso) y la comparación honesta "modelo simple → modelo rico".
> Datos: `WPP2024_Demographic_Indicators_Medium_csv.gz` (países = `ISO3_code` no vacío) + `data/raw/wb_api_income_2026-10-22.csv` (`ingreso_api`, **clasificación FY2027**, la de hoy aplicada a todos los años). Región SDG por `ParentID` (918 a mano; Oceanía unida: 3 países ≥ 1 M).
> Muestra principal: **161 países ≥ 1 M (2023)**, **solo estimaciones 1950–2023**. Sensibilidad: 237 países, sin el Golfo, ponderado por población, sin 2020–23.
> Scripts (R 4.6.1, fixest 0.14.2, `set.seed(2026)`): `/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/scratchpad/panel/` (`00_datos.R` … `05_figuras.R`). Figuras: `docs/asesoria_figs/panel/`. Todas las cifras son **prototipos** que `notebook-R` debe recalcular y volcar a `figures/numbers.json`.
> Construye sobre `06_asesoria_series_tiempo.md` (en adelante "memo ST"): replico su panel al decimal y lo extiendo; donde lo matizo, lo digo (§1.3).

---

## 0. Resumen (1 minuto)

1. **Entre países ≠ dentro de un país.** Entre países, tener la mitad de mortalidad < 5 va con **1,05 hijos menos por mujer**; dentro del mismo país, en los 20 años siguientes, va con **0,41 menos [IC95 0,12; 0,71]**. El gradiente transversal es **≈ 2,5 veces** la asociación dentro del país (Mundlak: diferencia −0,67, EE 0,13).
2. **Modelo rico recomendado:** cambios quinquenales con FE de país (= tendencia propia de cada país) + FE de periodo (= calendario mundial), rezagos distribuidos 0–20 años de Δlog Q5, EE agrupados por país. Placebo (Q5 de otro país): 95 % entre −0,37 y +0,36 frente al real 0,60 → no lo genera la tendencia común.
3. **Heterogeneidad (P7):** la asociación dentro del país es clara en **África subsahariana (−1,20 hijos [−1,65; −0,74])** y en los países **hoy** de ingreso bajo (−0,95 [−1,46; −0,43]); no se detecta en ingreso medio y alto, y en **Europa y N. América el signo se invierte** (+0,39 [0,23; 0,55]). Heterogeneidad: I² = 0,91 (regiones), 0,69 (ingreso).
4. **No es una flecha de un solo sentido:** la fecundidad también "precede" a la mortalidad (0,22 DE frente a 0,28 DE en el sentido contrario) y el coeficiente "del futuro" no es cero (0,28; IC −0,03 a 0,60). Lectura: **dos caras de una misma transición**.
5. **Migración y crecimiento:** las diferencias de crecimiento **entre** países son sobre todo nacimientos − defunciones (migración = 33 % de la varianza; **7 % sin los 6 Estados del Golfo**); los vaivenes **dentro** de un país son sobre todo migración (**85 %**, 70–93 % en todas las variantes).
6. **"La migración compensa el déficit natural" no se sostiene dentro del país.** En 44 países de ingreso alto (sin Golfo) el crecimiento natural cayó de 14,3 a −0,7 ‰ y la migración neta subió de 0,3 a 4,0 ‰ — **en el mismo calendario**. Quitado el calendario, 1 punto menos de crecimiento natural va con **+0,01 ‰ de migración [−0,17; 0,18]**; el país cuyo saldo natural cayó más **no** recibió más migración.
7. **Comparación honesta:** con el mismo denominador y dejando países fuera, el modelo de pendientes por región ("local", análogo al GWPR) **gana en muestra (21,8 %) y pierde fuera de muestra (6,6 %, peor que el calendario solo: 7,2 %)**. Ninguna interacción mejora la predicción de países nuevos de forma distinguible de cero.
8. **Humildad:** incluso el mejor modelo explica ~**8–11 %** de los cambios quinquenales de fecundidad de un país que no vio. La asociación es robusta en signo, pequeña en poder explicativo.

---

## 1. Evaluación del plan y del storyboard desde el panel

### 1.1 Lo que está bien
- **Plan §3 "Identidad contable"** y §4-Q1 Simple 1: correcto presentarla como identidad (residuo mediano |crec − nat − CNMR| = 0,004 ‰). Mi descomposición de varianza (§3.2) es la forma "estadística" de la misma identidad y no la contradice.
- **Plan §3 umbral ≥ 1 M** y sensibilidad con 237: imprescindible también en panel (237 países: 0,53 [0,23; 0,84] frente a 0,60).
- **Plan §4 regla "el rico se resume en una cifra"**: coincide con mi recomendación (§6).
- **Plan §4-Q1 fila "Opcional: panel FE"**: la intuición (rezago de Q5, EE por país, `split = ingreso`) es la correcta; la especificación no (§1.2).

### 1.2 Lo que es incorrecto o débil

| Dónde | Qué dice | Problema (panel) | Evidencia |
|---|---|---|---|
| Plan §4-Q1 "Opcional" | `feols(TFR ~ l(Q5,10) + CNMR \| pais + anio, split = ingreso)` en **niveles anuales** | Niveles con tendencia: residuos con autocorrelación 0,99 → EE y pendiente engañosos; `l(Q5,10)` en datos anuales es un solo rezago elegido a mano; Q5 en nivel (no log). | FE dos vías en niveles: 0,85 (resid. ρ = 0,99); en cambios: 0,22 contemporáneo, 0,60 sumando rezagos (§3.1). |
| Plan §4-Q1 Rico 2, H5; storyboard Slide 2 narración | Correlaciones por ingreso año a año como "acoplamiento"; "in rich countries it fills the gap…" | Correlación transversal = mezcla de diferencias permanentes entre países; no dice qué pasa dentro de un país. La "compensación" migratoria dentro del país es ≈ 0. | §3.4: +0,01 ‰ [−0,17; 0,18] sin calendario; ver también ética E26. |
| Storyboard Slide 1 mensaje | "18 countries would shrink without immigration" | Contrafactual no identificado (ya señalado por ética #11); el panel tampoco lo identifica. | — |
| Storyboard Slide 2 título/mensaje | "mortality falls first, fertility follows" como resultado del modelo | El panel muestra co-movimiento en **ambos** sentidos; la precedencia de *inicio* (memo ST) es otra pregunta. | §3.3 B: 0,28 DE vs 0,22 DE; adelanto 0,28. |
| Plan §2 Q1 "does the answer depend on region and income?" | Se responde con tipología y barras apiladas | Falta separar **entre** y **dentro**: la respuesta cambia según el lente (§3.1–3.2). | Gradiente transversal 2,5× el de dentro. |
| Plan §3 Ingreso / §8 limitaciones | Grupo de ingreso actual "aplicado a todos los años" | En panel es peor: el grupo FY2027 es **resultado** de la transición (selección por el resultado). Interacciones con ingreso = "countries that are low-income today". | Ya en memo ST; aquí afecta a toda la heterogeneidad (§4). |
| Receta ganadores §6 ★★★3 | "Comparar con una métrica honesta" | El plan no especifica cuál para el panel. | §3.5 la implementa. |

### 1.3 Coordinación con el memo de series de tiempo
- **Confirmo** su panel al decimal: con años sueltos múltiplos de 5, rezagos 0/5/10/15/20 = 0,04 / 0,17 / 0,37 / −0,01 / 0,10 (suma 0,66). Con **medias quinquenales** (mi especificación, usa 2021–23 y suaviza la migración): −0,09 / 0,37 / 0,22 / 0,03 / 0,07 (suma 0,60). Misma conclusión: el grueso está a 5–10 años.
- **Confirmo** su regla "nunca niveles a lo largo del tiempo" y su placebo; añado el placebo **dentro del modelo de panel** (§3.3).
- **Matizo** "el sentido inverso es débil": lo es coeficiente a coeficiente (solo el rezago 20 tiene p = 0,035), pero la **suma** de rezagos 5–20 es 0,084 (EE 0,031) con su misma especificación = 0,20 DE frente a 0,27 DE. No cambia su resultado de *inicio* (97 % mortalidad primero): ese es el **orden de arranque**; el panel mide el **co-movimiento posterior**, que es bidireccional. Ambas frases pueden convivir (§5).
- **No contradigo** el gradiente por ingreso del rezago (36 → 14 años); lo complemento: el grupo con rezago más largo (ingreso bajo) es también donde la asociación dentro del país es más fuerte.

---

## 2. Especificación recomendada

### 2.1 Modelo principal (notebook, sección "P7 — panel")
ΔTFR<sub>i,p</sub> = Σ<sub>k=0..4</sub> β<sub>k</sub> · Δlog Q5<sub>i,p−k</sub> + α<sub>i</sub> + δ<sub>p</sub> + ε<sub>i,p</sub>  — `feols(..., cluster = ~ISO3_code)`

| Pieza | Elección | Por qué |
|---|---|---|
| Unidad temporal | **Medias quinquenales** 1950–54 … 2020–23 (15 periodos) | WPP anual está interpolado/suavizado (autocorr. ΔTFR 0,80); medias de 5 años reducen ruido de migración y usan 2021–23. |
| Variables | **Cambios** entre quinquenios; Q5 en **log** | Evita regresión espuria de niveles con tendencia; log = riesgos comparados en razones (coherente con memo ST). |
| α<sub>i</sub> (FE país) en un modelo en cambios | Tendencia lineal propia de cada país en niveles | Quita lo que cada país "ya venía haciendo". |
| δ<sub>p</sub> (FE periodo) | Choques comunes (COVID, calendario global) | Lo que mueve a todos a la vez no se atribuye a Q5. |
| Rezagos 0–20 años | 5 coeficientes, se reporta la **suma** (asociación acumulada) | No elegir un rezago "ganador" a mano (comparaciones múltiples). |
| Rezago de la dependiente | **No** en el principal; sí como sensibilidad | Sesgo de Nickell con T ≈ 10: ≈ −(1+ρ)/(T−1) = −0,17 en ρ. |
| EE | Agrupados por país (161 clústeres) | Autocorrelación residual 0,45 dentro del país. |
| Heterogeneidad | `split = ~ingreso` y `split = ~region` (FE de periodo propios) + interacción con FE comunes y prueba de Wald | Forest plot por grupo; Cochran Q / I² para "¿varía?". |
| Muestra de estimación | Cambios 1975–2023 (los rezagos llegan a 1955) | **Ojo:** las transiciones de Asia Oriental y América Latina empezaron antes de la ventana. |

**Migración (§3.4):** CNMR<sub>i,p</sub> = γ · nat<sub>i,p−1</sub> + α<sub>i</sub> + δ<sub>p</sub> (crecimiento natural del quinquenio **anterior**, para reducir la simultaneidad mecánica: los inmigrantes jóvenes elevan los nacimientos), en cuatro lentes: entre países, agrupado, dentro (país + periodo), dentro en cambios; por ingreso y sin Golfo.

### 2.2 Supuestos (escritos en el notebook)
(1) Linealidad en log Q5 (halving 200 → 100 ‰ = 10 → 5 ‰; falso al final de la transición, ver Europa). (2) Pendientes comunes dentro de cada grupo. (3) Exogeneidad estricta **no** se asume ni se prueba: la prueba de adelanto la rechaza parcialmente → todo es **asociación**. (4) Grupo de ingreso fijo (FY2027). (5) Datos modelizados por la ONU (Q5 y TFR de muchos países africanos en los años 50 son estimaciones de modelo). (6) Cada país pesa 1 (ponderado por población el resultado desaparece: −0,12 [−0,88; 0,64], China e India dominan).

### 2.3 No estacionariedad, espurias y por qué **no** cointegración
- **No** se hacen pruebas de raíz unitaria ni de cointegración de panel (Pedroni/Westerlund): con 15 puntos quinquenales no tienen potencia, en datos anuales reflejan el suavizado de WPP y no caben en 5 minutos.
- En su lugar, cuatro salvaguardas explicables: (a) modelo **en cambios con tendencia propia** (válido si los niveles son I(1) o estacionarios en tendencia); (b) **diferencia larga** 1950–54 → 2020–23 (una observación por país; recupera la relación de largo plazo sin suponer cointegración): 0,66 [0,36; 0,95], casi igual a la suma de rezagos (0,60); (c) **placebo** de permutación de países; (d) autocorrelación residual reportada por especificación (0,99 en niveles → 0,45 en cambios).

### 2.4 Validación
Placebo (300 permutaciones) · adelanto (falsificación) · sentido inverso · sin FE de país (0,46 [0,16; 0,75]) · con ΔTFR rezagada (cotas de Bond: ρ ∈ [0,49; 0,59]) · dejar fuera un país a la vez (0,54–0,68; en SSA 1,59–1,92) · 237 países · sin 2020–23 (0,64) · con ΔCNMR (0,60; coef. ΔCNMR 0,0008, EE 0,0005) · validación fuera de muestra por bloques de países (§3.5).

### 2.5 Frase simple (inglés)
*"We compare each country with itself over time, after removing its own trend and what happened to every country at once."*

---

## 3. Resultados preliminares (161 países ≥ 1 M, estimaciones)

### 3.1 Fecundidad–mortalidad: ¿entre o dentro?
**Descomposición de varianza (anual 1950–2023):**

| Variable | Entre países | Calendario común | Dentro, propio del país |
|---|---|---|---|
| TFR | 64 % | 24 % | 12 % |
| log Q5 | 60 % | 34 % | 6 % |
| LEx | 60 % | 30 % | 10 % |
| Edad mediana | 74 % | 14 % | 11 % |
| Crecimiento natural | 68 % | 10 % | 22 % |
| Crecimiento total | 33 % | 4 % | 64 % |
| **CNMR (migración)** | **17 %** | **1 %** | **82 %** |

**Misma relación, siete lentes** (TFR ~ log Q5; "efecto" = hijos por mujer asociados a la **mitad** de Q5 = β × ln 0,5):

| Lente | β [IC95] | Mitad de Q5 → hijos | Autocorr. residual |
|---|---|---|---|
| Entre países (medias 1950–2023) | 1,52 [1,43; 1,61] | **−1,05** | — |
| Agrupado, niveles | 1,42 [1,36; 1,48] | −0,98 | 0,99 |
| FE país, niveles | 1,26 [1,15; 1,37] | −0,87 | 0,98 |
| FE país + año, niveles | 0,85 [0,61; 1,09] | −0,59 | 0,99 |
| Diferencia larga 1950–54 → 2020–23 | 0,66 [0,36; 0,95] | −0,45 | — |
| **Cambios 5 años, rezagos 0–20 sumados (rico)** | **0,60 [0,18; 1,02]** | **−0,41 [−0,71; −0,12]** | 0,45 |
| Cambios 5 años, mismo periodo | 0,22 [−0,05; 0,49] | −0,15 | 0,50 |

Mundlak (FE año): pendiente dentro 0,85 vs entre 1,52 (diferencia −0,67, EE 0,13). **Por qué importa para la ONU (una frase):** *el gradiente entre países mezcla diferencias permanentes (historia, instituciones, ingreso); si se usara para anticipar cuánto bajará la fecundidad de un país cuando baje su mortalidad infantil, se exageraría ≈ 2,5 veces.* Alternativa a declarar: el error de medida en cambios atenúa "dentro"; la diferencia larga (menos ruidosa) da casi lo mismo, así que la atenuación no lo explica todo.

### 3.2 Migración–crecimiento: participación de la migración en la varianza del crecimiento
cov(crec, CNMR)/var(crec) (identidad: crec = nat + CNMR). IC = bootstrap de países (B = 300).

| Grupo (n) | Entre países | Dentro (anual, neto de país y año) |
|---|---|---|
| Todos (161) | 33 % [9; 52] | **85 % [75; 90]** |
| Ingreso bajo (25) | 22 % [6; 47] | 84 % [76; 92] |
| Medio-bajo (41) | 40 % [7; 67] | 76 % [52; 89] |
| Medio-alto (44) | 29 % [14; 43] | 80 % [68; 90] |
| Alto (50) | 58 % [30; 68] | 95 % [83; 97] |

Sensibilidad: **sin Golfo, entre = 7 % (todos) y 26 % (alto)**; dentro 79 % y 93 %. Quinquenal: 32 % / 70 %. 237 países: 45 % / 89 %. 1950–2019: 34 % / 86 %. → Lo robusto es "dentro"; "entre" depende de seis países.

### 3.3 Modelo rico: resultados
**A. Principal:** rezagos 0/5/10/15/20 = −0,09 (0,20) / 0,37 (0,17) / 0,22 (0,08) / 0,03 (0,07) / 0,07 (0,07); suma 0,60 (0,22); N = 1 610 (161 países × 10 periodos); R² dentro = 0,04.
**B. Falsificación y dinámica:** adelanto (Δlog Q5 del próximo quinquenio) 0,28 (0,16), p = 0,08 · inverso Δlog Q5 ~ ΔTFR rezagada 5–20: suma 0,087 [0,033; 0,141] → **0,22 DE vs 0,28 DE** · con ΔTFR rezagada: ρ<sub>FE</sub> = 0,49, ρ<sub>agrupado</sub> = 0,59; suma β = 0,20 [−0,07; 0,46], largo plazo 0,38 [−0,16; 0,93]; con ΔTFR rezagada y sin FE de país, largo plazo 0,04 [−0,35; 0,43]. → **Parte de la asociación es compartida con la inercia de la propia fecundidad**; el modelo no separa "efecto" de "momento".
**C. Placebo:** media 0,001; 95 % [−0,37; 0,36]; ninguna de las 300 permutaciones alcanza 0,60.
**D. Heterogeneidad** (split; mitad de Q5 → hijos por mujer en 20 años):

| Grupo (n) | Suma β [IC95] | Mitad de Q5 → hijos |
|---|---|---|
| Ingreso bajo (25) | 1,37 [0,62; 2,11] | **−0,95** |
| Medio-bajo (41) | −0,10 [−1,13; 0,93] | +0,07 |
| Medio-alto (44) | −0,16 [−0,87; 0,55] | +0,11 |
| Alto (50) | 0,40 [−0,33; 1,13] | −0,28 |
| África subsahariana (44) | 1,73 [1,07; 2,38] | **−1,20** |
| N. África y Asia Occ. (24) | 0,74 [0,04; 1,44] | −0,51 |
| América Latina y Caribe (23) | 0,45 [−0,23; 1,14] | −0,31 |
| Asia Central y Sur (12) | −0,03 [−3,19; 3,14] | (no informativo) |
| Asia Oriental y SE (17) | −0,05 [−1,43; 1,34] | (no informativo) |
| Europa y N. América (38) | −0,56 [−0,80; −0,33] | **+0,39** |

Cochran Q: ingreso 9,75 (gl 3, p = 0,02, I² = 0,69); región 53,0 (gl 5, p < 10⁻⁹, I² = 0,91). Con FE de periodo comunes: ingreso bajo 2,59 (0,53); Wald χ²(3) = 21,1, p < 0,001. SSA sin África austral (VIH): 1,22 (0,40). Europa: antes de 1990, 1,14 (0,78); Europa del Este sola +0,48 (0,28). Una partición simple por "etapa" (Q5 20 años antes ≥ 100 ‰) **no** reproduce el patrón (0,35 vs −0,09, IC amplios) → el patrón regional también refleja **la ventana 1975–2023** (SSA hace su transición dentro; Asia/LAC ya iban avanzadas).

### 3.4 Migración y estructura demográfica
CNMR (‰) ~ crecimiento natural del quinquenio anterior (‰):

| Grupo | Entre países | Dentro (país + periodo) |
|---|---|---|
| Todos | −0,02 [−0,09; 0,05] | 0,06 [−0,06; 0,17] |
| Ingreso alto (50) | +0,66 [0,21; 1,11] | +0,32 [0,04; 0,59] |
| **Ingreso alto sin Golfo (44)** | +0,05 [−0,14; 0,23] | **+0,01 [−0,17; 0,18]** |

El signo positivo con Golfo es mecánico (población inmigrante joven → más nacimientos). Ingreso alto sin Golfo: solo FE de país (el calendario **incluido**) −0,16 [−0,25; −0,06] = la "compensación" aparente; FE de periodo la elimina (0,01). Entre países, cambio 1980–84 → 2020–23: pendiente +0,10 (EE 0,13), Spearman +0,21 (signo contrario a la compensación). Edad mediana (ingreso alto, con Golfo): entre −0,77 [−1,39; −0,15] (lo arrastran poblaciones inmigrantes jóvenes); dentro +0,39 [−0,14; 0,91]. **Conclusión:** la frase "la migración rellena el déficit natural en ingreso alto" es verdadera como **contabilidad del agregado** (plan H1: 71 % del crecimiento) y como **calendario compartido**, pero **no** como relación país a país.

### 3.5 Comparación honesta simple vs rico
Mismo objetivo (ΔTFR quinquenal), misma muestra (157 países, sin Oceanía y Taiwán; 1 570 obs.), **mismo denominador** (varianza dentro del país, des-mediada por país) en muestra y fuera de muestra (10 bloques de países × 5 repeticiones).

| Modelo | Pendientes | R² dentro, en muestra | R² dentro, países fuera | AIC | BIC |
|---|---|---|---|---|---|
| M0 Solo calendario | 0 | 8,5 % | 7,2 % | 522 | 1 412 |
| M1 Simple: Δlog Q5 del mismo periodo | 1 | 8,6 % | 6,2 % | 524 | 1 418 |
| M2 Rezagos 0–20 (comunes) | 5 | 12,3 % | 8,4 % | 465 | 1 382 |
| M3 Rezagos × ingreso | 20 | 20,8 % | **11,0 %** | 335 | **1 332** |
| M4 Rezagos × región ("local") | 30 | **21,8 %** | 6,6 % | 335 | 1 386 |

Ganancia fuera de muestra frente a M2 (bootstrap de países): M3 +2,9 pts [−3,0; +8,0]; M4 +0,3 pts [−10,7; +8,0]. **En niveles** (la comparación tipo ganador 2025): MCO agrupado adj. R² 0,76 → países nuevos 0,76; MCO con pendientes por región 0,83 → 0,82; **FE dos vías 0,89 → 0,66** (232 parámetros; R² "within" 0,12).
**Crítica a TRITICS (interna; no va al vídeo, ética #29):** rankearon OLS 75,7 %, panel 69,9 % y GWPR 91,4 % por adj. R² en muestra; que el panel quede *por debajo* del OLS delata que comparaban un R² "within" (otro denominador) con un R² total, y un modelo con coeficientes locales siempre ajusta mejor su propia muestra. **Nosotros, en una frase:** *comparamos modelos sobre el mismo objetivo y el mismo denominador, en países que el modelo nunca vio, y reportamos por separado el ajuste dentro y entre países.*

### 3.6 Figuras (revisadas una a una; `docs/asesoria_figs/panel/`)
1. `pn01_seis_lentes_fecundidad_mortalidad.png` — siete estimaciones de la misma relación; naranja = entre países (−1,05), gris = niveles con autocorrelación 0,98–0,99, azul = dentro en cambios (−0,15 a −0,45). **Notebook / apéndice.**
2. `pn02_crecimiento_migracion_entre_dentro.png` — participación de la migración en la varianza del crecimiento, entre (naranja, IC anchos, 22–58 %) vs dentro (azul, 76–95 %), por ingreso; subtítulo con la sensibilidad sin Golfo. **Notebook; posible apoyo a Slide 1.**
3. `pn03_forest_ingreso_region.png` — forest del modelo rico: todos −0,41; ingreso bajo −0,95; SSA −1,20; NAWA −0,51; Europa +0,39 (bermellón); banda gris = placebo; línea naranja = gradiente entre países. **Candidata (versión reducida) para Slide 2.**
4. `pn04_perfil_rezagos_dos_sentidos.png` — perfil de rezagos con adelanto (A) y sentido inverso (B); muestra que el pico está a 5–10 años y que la relación es bidireccional. **Notebook (métodos).**
5. `pn05_migracion_ingreso_alto_calendario.png` — A: medias de 44 países de ingreso alto (nat 14 → −0,7; CNMR 0,3 → 4,0); B: compensación +0,16 con calendario, ≈ 0 sin él, −0,10 entre países. **Notebook; una frase en el vídeo.**
6. `pn06_comparacion_honesta_modelos.png` — A: en muestra vs fuera de muestra (M4 cae de 21,8 % a 6,6 %); B: en niveles, FE dos vías primero en adj. R² y último en países nuevos. **Notebook / README (sección métodos).**

---

## 4. Riesgos estadísticos y éticos (ASA 2022)

| Riesgo | Dónde | Mitigación |
|---|---|---|
| **Lenguaje causal** ("efecto de", "si Q5 baja a la mitad la TFR bajará") | Slide 2, guion | Verbos de §5; el adelanto ≠ 0 y el inverso ≈ igual de fuerte impiden leerlo como efecto (A.2, C.2). |
| **Falacia ecológica / mezclar entre y dentro** | P7, heatmap de acoplamiento | Decir siempre qué lente: *across countries* vs *within the same country* (B.2). |
| **Ingreso de hoy aplicado al pasado = selección por el resultado** | Toda interacción con ingreso | Etiqueta *today's low-income countries (FY2027)*; nunca "low income slows/speeds" (B.1, D.6). |
| **Ventana 1975–2023** | Forest por región | Nota: Asia/LAC transitaron antes; "not detected" ≠ "no link" (C.4). |
| **Comparaciones múltiples** | 10 grupos × 5 rezagos | Se reporta la **suma** por grupo (no rezagos sueltos), I² y una sola prueba de Wald; `n_tests` en `numbers.json` (B.3). |
| **Población completa, no muestra** | IC y p | IC = "sensibilidad a qué países entran" (bootstrap/cluster), sin p en el vídeo (ética #12). |
| **Ponderación** | Promedio de países vs de personas | Decir *each country counts once*; ponderado por población el resultado desaparece (B.2, B.7). |
| **Datos modelizados y Golfo** | Migración, Q5 antiguos | Migración como residuo entre censos (ética #3); resultados "entre" dependen de 6 países: reportar con y sin (D.10). |
| **Marco del "gran reemplazo"** | Migración en ingreso alto | Nuestro resultado **refuta** la compensación país a país; aun así, nunca *fill/replace* (ética #19). |
| **Overfitting / R² inflado** | Comparación de modelos | Mismo denominador, bloques de países, BIC (A.2, B.6). |
| **Microestados** | Todo | ≥ 1 M principal; 237 como sensibilidad (0,53). |
| **Proyecciones** | Ninguna | Ningún modelo usa años ≥ 2024 (memo ST §2.5). |

---

## 5. Lenguaje para el vídeo (inglés)

**Frases propuestas (3–4, elegir según tiempo):**
1. *"Across countries, half the child mortality goes with about one child fewer per woman. Within the same country, over the following twenty years, the link is less than half as strong — about 0.4 children."*
2. *"That within-country link is clear in sub-Saharan Africa and in today's low-income countries; we do not detect it in Europe and North America."*
3. *"Fertility and child mortality also move together in the other direction, so we read this as one transition with two faces, not as one causing the other."*
4. *"In high-income countries, net migration rose while natural increase fell — on a shared calendar. A country whose births fell faster did not see more migration."*
(Para la parte de métodos, si hay 6 s: *"A model with different slopes for every region fit our data best — and predicted new countries worst, so we kept the simpler one."*)

**Permitidas:** *is associated with · goes with · moves together with · within the same country · across countries · over the following 20 years · we do not detect · on a shared calendar · accounts for (solo contable).*
**Prohibidas:** *causes / drives / leads to / the effect of child mortality on fertility · if child mortality halves, fertility will fall · reduces / lowers (como acción) · Granger-causes · proves · significant · migration fills / compensates / replaces the missing births · income speeds up / slows the transition · rich / poor countries · predicts (sin "out of sample").*

---

## 6. Qué va a la diapositiva y qué al notebook

- **Diapositiva (una sola figura, una sola cifra):** Slide 2, build 3 → **mini-forest** derivado de `pn03` con **5 filas** (All + 4 grupos de ingreso), línea naranja "across countries: −1.05", punto azul "within the same country: −0.41". Cifra narrada: **"0.4 within the same country vs 1.0 across countries"** (`panel_within_halfq5`, `panel_between_halfq5`). Pie: *"5-year changes 1975–2023, country & period fixed effects, each country counts once; association, not cause."* SSA (−1,20) se dice en voz, no como fila extra.
- **Solo voz, sin figura:** frase 4 (migración en ingreso alto, calendario compartido) en Slide 1 build 4 o Slide 2 build 4, sustituyendo "fills the gap".
- **Notebook (sección "P7 — panel", etiquetada *Exploratory*):** §3.1–3.5 completos, `pn01`–`pn06`, placebo, adelanto, inverso, LDV/Nickell, LOO, sensibilidades, tabla de comparación de modelos.
- **Apéndice del repo / README métodos:** `pn06` + la frase de comparación honesta.
- **Claves nuevas para `numbers.json`:** `panel_within_halfq5` (−0,41), `panel_within_halfq5_lo/hi`, `panel_between_halfq5` (−1,05), `panel_ratio_between_within` (2,5), `panel_low_income_halfq5` (−0,95), `panel_ssa_halfq5` (−1,20), `panel_eurna_halfq5` (+0,39), `panel_placebo_lo/hi`, `panel_reverse_sd` (0,22) vs `panel_forward_sd` (0,28), `mig_share_within` (0,85), `mig_share_between` (0,33) y `_excl_gulf` (0,07), `mig_hi_within_slope` (0,01 [−0,17; 0,18]), `r2_oos_m2/m3/m4` (0,084 / 0,110 / 0,066).

---

## 7. Cambios concretos al plan y al storyboard (por prioridad)

1. **Plan §4-Q1, fila "Opcional: panel FE"** → sustituir por la especificación de §2.1 (cambios quinquenales, rezagos 0–20 sumados, FE país + periodo, EE por país, `split` por ingreso y región) y pasarla de "opcional" a **"Rico 4"**, con validación = placebo + adelanto + inverso + LOO.
2. **Añadir al plan §5 la hipótesis H15** (declarada antes del cálculo final): *"La asociación fecundidad–mortalidad dentro del país es menor que entre países"* (ancla −0,41 vs −1,05) y **H16**: *"En ingreso alto, la migración no compensa el déficit natural dentro del país"* (ancla 0,01 [−0,17; 0,18]).
3. **Storyboard Slide 2, build 3**: el panel de β-"memoria" (ya cuestionado por memo ST #5) se reemplaza por el **mini-forest** de §6; la cifra de memoria de la migración (0,14 vs 0,52, memo ST) queda como línea de texto bajo el mini-forest. Máximo 3 visuales por diapositiva se respeta.
4. **Storyboard Slide 2, narración**: cambiar *"in rich countries it fills the gap that low fertility leaves"* por la frase 4 de §5 (resuelve también ética E26 con evidencia).
5. **Storyboard Slide 2, título/mensaje**: no decir "fertility follows" como resultado del modelo; usar *"child mortality began to fall first (onset); afterwards both moved together"* (combina memo ST y §3.3B).
6. **Plan §4-Q1 Rico 2 (heatmap de acoplamiento)**: rotular cada correlación como **"across countries in year t"** y añadir en el notebook la descomposición de varianza (§3.1) para que nadie la lea como "dentro del país".
7. **Plan §4-Q1 Simple 1 (71 % de ingreso alto)**: mantener como contabilidad, añadir la nota *"shared calendar, not country-by-country compensation"* y la cifra sin Golfo de la descomposición (7 %).
8. **Plan §8 limitaciones**: añadir (8) *ventana del panel 1975–2023* y (9) *resultados por ingreso = países clasificados hoy*; y (10) *el panel describe co-movimiento, no efectos (adelanto ≠ 0, relación bidireccional)*.
9. **Plan §4 (regla de oro) / receta ★★★3**: adoptar la comparación de §3.5 como **la** métrica simple vs rico del proyecto (misma muestra, mismo denominador, países fuera, BIC). Se cita en el README, no se compara con otros equipos en el vídeo.
10. **`R/config.R`**: añadir `PERIODO_PANEL <- 5`, `REZAGOS_PANEL <- 0:4`, `GOLFO <- c("ARE","QAT","KWT","BHR","OMN","SAU")` y la regla "Oceanía unida en panel".
11. **Plan §2 Q1 (P7 "por país")**: declarar que la dimensión **país** se responde con el mapa/tipología, no con pendientes por país (T ≈ 10 periodos: serían ruido); el panel aporta un **LOO** (0,54–0,68) para mostrar que ningún país mueve el resultado.
12. **Unificar FY2027** en plan §3, storyboard y referencias (coincide con memo ST #15 y ética #17).

---

## Anexo — Código R clave (comentarios en español)

```r
library(tidyverse); library(fixest); set.seed(2026)
# Panel quinquenal: medias de periodo (1950–54, …, 2020–23) para >= 1 M, solo estimaciones
q <- anual %>% filter(grande, Time <= 2023) %>% mutate(periodo = 5 * (Time %/% 5)) %>%
  group_by(ISO3_code, region, ingreso, periodo) %>%
  summarise(across(c(TFR, lQ5, CNMR, nat, crec, MedianAgePop), mean), .groups = "drop") %>%
  group_by(ISO3_code) %>% arrange(periodo) %>%
  mutate(dTFR = TFR - lag(TFR), dlQ5 = lQ5 - lag(lQ5),                        # cambios entre quinquenios
         L0 = dlQ5, L1 = lag(dlQ5), L2 = lag(dlQ5, 2), L3 = lag(dlQ5, 3), L4 = lag(dlQ5, 4),
         F1 = lead(dlQ5), nat_1 = lag(nat)) %>% ungroup()
f <- dTFR ~ L0 + L1 + L2 + L3 + L4 | ISO3_code + periodo                     # FE país = tendencia propia; FE periodo = calendario
m <- feols(f, q, cluster = ~ISO3_code)                                        # EE agrupados por país
suma <- function(m, v = paste0("L", 0:4)) {                                   # asociación acumulada 0–20 años (método delta)
  b <- coef(m)[v]; V <- vcov(m)[v, v]; c(est = sum(b), ee = sqrt(sum(V))) }
log(0.5) * suma(m)["est"]                                                     # hijos por mujer con la mitad de Q5 (≈ −0,41)
# Heterogeneidad: un modelo por grupo (FE de periodo propios) + Cochran Q
ms <- feols(f, filter(q, ingreso != "Not classified"), split = ~ingreso, cluster = ~ISO3_code)
# Falsificación: adelanto (no debería importar) y sentido inverso
feols(dTFR ~ F1 + L0 + L1 + L2 + L3 + L4 | ISO3_code + periodo, q, cluster = ~ISO3_code)
# Placebo: la serie de Q5 de OTRO país (si sale parecido, era tendencia común)
perm <- setNames(sample(unique(q$ISO3_code)), unique(q$ISO3_code))
qp <- q %>% select(ISO3_code, periodo, dTFR) %>%
  left_join(q %>% transmute(ISO3_code = unname(perm[ISO3_code]), periodo, L0, L1, L2, L3, L4), by = c("ISO3_code", "periodo"))
suma(feols(f, qp, cluster = ~ISO3_code))
# Entre vs dentro en un solo modelo (Mundlak)
g <- anual %>% filter(grande) %>% group_by(ISO3_code) %>% mutate(x_media = mean(lQ5), x_desv = lQ5 - x_media) %>% ungroup()
feols(TFR ~ x_desv + x_media | Time, g, cluster = ~ISO3_code)                 # pendiente dentro (0,85) vs entre (1,52)
# Migración: compensación con y sin calendario (ingreso alto sin Golfo)
hi <- filter(q, ingreso == "High income", !ISO3_code %in% GOLFO)
feols(CNMR ~ nat_1 | ISO3_code, hi, cluster = ~ISO3_code)                     # calendario incluido (−0,16)
feols(CNMR ~ nat_1 | ISO3_code + periodo, hi, cluster = ~ISO3_code)           # calendario quitado (≈ 0)
# Comparación honesta: R² dentro con el MISMO denominador, dejando países fuera
r2_dentro <- function(y, yhat, id) { yd <- y - ave(y, id); hd <- yhat - ave(yhat, id); 1 - sum((yd - hd)^2) / sum(yd^2) }
# en cada bloque: ajustar sin esos países; predecir Xβ + FE de periodo; evaluar con r2_dentro (ver 04_comparacion.R)
```
