# 02 — Contexto histórico de la demografía mundial 1950–2024 (para anotar gráficas y guion)

> **Propósito.** Este documento conecta las series de *World Population Prospects 2024* (WPP2024, variante Medium; estimaciones 1950–2023, proyección desde 2024) con hechos históricos reales (guerras, hambrunas, epidemias, políticas de población, crisis económicas y migraciones), para que las anotaciones de las gráficas y el guion del vídeo sean **creíbles, citadas y comprobables**.
>
> **Cómo leerlo.**
> - Cada evento lleva **fuente con URL y año**. Los nombres de eventos van también **en inglés** (etiquetas cortas listas para diapositivas).
> - **[V]** (verificado WPP) = la cifra se comprobó en el archivo `WPP2024_Demographic_Indicators_Medium_csv.gz` (columnas oficiales: `TFR`, `LEx`, `IMR`, `Q5`, `CNMR`, `NetMigrations`, `PopGrowthRate`, `MedianAgePop`, `CBR`, `CDR`) (22-oct-2026; ver el código reproducible en el Anexo E). **[PV]** (por verificar) = huella esperada según la historia o fuente secundaria aún no comprobada. **≈** = cifra aproximada o rango de estimaciones de la literatura.
> - **Hechos vs. hipótesis.** Una coincidencia temporal entre un evento y un quiebre en la serie **no prueba causalidad**. En pantalla se usarán verbos descriptivos (*coincides with*, *during*, *after*), no causales, salvo cuando la propia fuente (p. ej., la ONU o un estudio demográfico) atribuye el efecto.
> - **Advertencia de datos.** Las cifras de WPP2024 para años de crisis son **estimaciones modeladas** (la ONU incorpora ~7.300 "crisis-years" de exceso de mortalidad 1950–2023 y modela explícitamente el VIH en 23 países; *Methodology Report*, 2024, sec. I.C.2–3). La migración neta es en muchos casos un **residuo** entre censos. Por eso, algunas series pueden mostrar saltos artificiales (ver §0.3).
> - Lineamientos éticos aplicados: ASA *Ethical Guidelines for Statistical Practice* (2022), principios A, B y C (no predeterminar resultados, documentar supuestos y limitaciones, separar lo exploratorio de lo confirmatorio). https://doi.org/10.5281/zenodo.7092386

## 0. Fuentes base y advertencias metodológicas

### 0.1 Fuentes principales
| Clave | Referencia | URL |
|---|---|---|
| WPP-SR | UN DESA Population Division (2024). *World Population Prospects 2024: Summary of Results* (UN DESA/POP/2024/TR/NO. 9). | https://population.un.org/wpp/assets/Files/WPP2024_Summary-of-Results.pdf |
| WPP-M | UN DESA Population Division (2024). *World Population Prospects 2024: Methodology of the United Nations Population Estimates and Projections* (UN DESA/POP/2024/DC/NO.10). | https://population.un.org/wpp/assets/Files/WPP2024_Methodology-Report_Final.pdf |
| WPP-D | UN DESA (2024). *World Population Prospects 2024, Online Edition* (datos, licencia CC BY 3.0 IGO). | https://population.un.org/wpp/ |
| Lee03 | Lee, R. (2003). The Demographic Transition: Three Centuries of Fundamental Change. *Journal of Economic Perspectives* 17(4):167–190. | https://www.aeaweb.org/articles?id=10.1257/089533003772034943 |
| Omr71 | Omran, A. R. (1971/2005). The Epidemiologic Transition: A Theory of the Epidemiology of Population Change. *Milbank Q.* 83(4):731–757 (reimpresión). | https://onlinelibrary.wiley.com/doi/10.1111/j.1468-0009.2005.00398.x |
| Zel71 | Zelinsky, W. (1971). The Hypothesis of the Mobility Transition. *Geographical Review* 61(2):219–249. | https://doi.org/10.2307/213996 |
| Les14 | Lesthaeghe, R. (2014). The second demographic transition: A concise overview of its development. *PNAS* 111(51):18112–18115. | https://www.pnas.org/doi/10.1073/pnas.1420441111 |
| Blo03 | Bloom, D., Canning, D., Sevilla, J. (2003). *The Demographic Dividend*. RAND MR-1274. | https://www.rand.org/pubs/monograph_reports/MR1274.html |
| Cle14 | Clemens, M. (2014). Does Development Reduce Migration? IZA DP 8592. | https://www.econstor.eu/handle/10419/106535 |
| dHa10 | de Haas, H. (2010). Migration transitions. IMI Working Paper 24, Univ. of Oxford. | https://heindehaas.org/wp-content/uploads/2015/05/de-haas-2010-migration-transitions-imi-wp-24.pdf |
| Bon09 | Bongaarts, J. (2009). Human population growth and the demographic transition. *Phil. Trans. R. Soc. B* 364:2985–2990. | https://royalsocietypublishing.org/doi/10.1098/rstb.2009.0137 |

### 0.2 Qué dice la ONU sobre cómo se construyeron las cifras de crisis (útil para la diapositiva de ética)
- **Crisis de mortalidad:** "Altogether the mortality effects of about 7,300 crisis-years were identified and accounted for" (WPP-M, 2024, sec. I.C.3). Tipos: conflictos, asesinatos masivos (incluidos genocidios), inundaciones, ciclones, terremotos, epidemias, COVID-19, olas de calor, hambrunas y sequías.
- **VIH/sida:** modelado explícito en **23 países** con epidemias generalizadas (tabla I.2 de WPP-M), entre ellos Botsuana, Esuatini, Lesoto, Zimbabue, Zambia, Malaui, Mozambique, Namibia, Kenia, Uganda y Ruanda. Sudáfrica y Tailandia usan tablas de vida empíricas del registro civil (nota 21). Prevalencia adulta 15–49 en 2022 (mujeres / hombres): Esuatini 35,2 % / 17,0 %; Lesoto 24,3 % / 14,2 %; Botsuana 21,1 % / 11,8 %; Zimbabue 13,7 % / 8,2 % (UNAIDS 2023, citado en WPP-M).
- **COVID-19:** WPP2024 incorpora estimaciones de exceso de mortalidad hasta 2021 (WPP-M, Introducción); la esperanza de vida mundial cayó de 72,6 (2019) a 70,9 años (2021) (WPP-SR, Key messages).
- **Migración:** "net migration only"; en muchos países se estima "as the residual not accounted for by the natural increase between successive census enumerations" (WPP-M, sec. I.D). Además, la ONU equilibra la suma mundial a cero cada año ajustando países con estimaciones muy inciertas.

### 0.3 Artefactos conocidos o sospechosos en la serie (revisar antes de anotar)
- **China, `NetMigrations` 1964 ≈ −1,25 millones y 1991 ≈ −0,54 millones** [Verificado WPP]: son saltos aislados que coinciden con años de censo (1964, 1990) y probablemente reflejan ajustes de reconciliación censal, no un éxodo real. **No anotarlos como evento migratorio.**
- **República Centroafricana, `LEx` ≈ 14,7 años en 2009** [Verificado WPP; causa por verificar]: valor extremo atribuible al ajuste de mortalidad de crisis; revisar antes de usar.
- Las series anuales WPP para 1950–1990 en países sin registro civil completo son **suavizadas**: los choques cortos (p. ej., una hambruna de un año) pueden aparecer atenuados o repartidos en varios años.

---

## 1. Marco teórico en lenguaje llano (máx. 1 página)

| Concepto | Frase simple para el vídeo (EN) | En español | Patrón que debería verse en WPP2024 | Fuente |
|---|---|---|---|---|
| **Transición demográfica** (4–5 etapas) | *"First people stop dying young; later, they choose to have fewer children."* | Etapa 1: natalidad y mortalidad altas (crecimiento lento). Etapa 2: cae la mortalidad (sobre todo infantil) y la población se dispara. Etapa 3: cae la fecundidad y el crecimiento se frena. Etapa 4: natalidad y mortalidad bajas. Etapa 5 (propuesta): fecundidad bajo reemplazo y decrecimiento. | `CDR`, `IMR` y `Q5` bajan **antes** que `CBR` y `TFR`; entre ambas caídas `PopGrowthRate` alcanza su máximo. Ejemplo [Verificado WPP]: en el mundo la `IMR` bajó de 138 (1950) a 97 por mil (1970) mientras la `TFR` seguía ≈ 5 (4,85 → 4,83); la `TFR` solo cae con fuerza desde ~1970 (3,74 en 1980). El crecimiento mundial tocó techo en 1963 (2,28 %/año). El rezago entre el inicio de la caída de la mortalidad (≈ 1800 en Europa) y el de la fecundidad (≈ 1870–1900) fue de **varias décadas a cerca de un siglo en Europa**, y mucho más corto en los países que iniciaron su transición después de 1950 (≈, Lee03; a cuantificar con los datos). | Lee03; Bon09 |
| **Transición epidemiológica** (Omran) | *"Infections give way to chronic diseases as the main killers."* | Tres eras: pestes y hambrunas → retroceso de pandemias → enfermedades degenerativas y causadas por el ser humano. Más tarde se añadió una 4.ª era (enfermedades degenerativas tardías) y el riesgo de "contratransiciones" (VIH, crisis postsoviética). | `IMR`/`Q5` caen rápido al inicio (las ganancias más baratas son en niños); después la `LEx` sube más despacio y las ganancias se trasladan a `LE65`/`LE80`. Las reversiones (VIH en África austral, Rusia 1990s, COVID-19 2020–21) se ven como "valles" en `LEx`. La propia ONU modela la `LEx` con una curva de doble logística: rápido al principio, más lento después (WPP-M, sec. II.C). | Omr71; WPP-M |
| **Segunda transición demográfica** (SDT) | *"Once survival is secured, people delay marriage and parenthood—and fertility drops below two."* | Tras la primera transición, cambios de valores (autonomía individual, igualdad de género, cohabitación) llevan a posponer la maternidad y a fecundidad bajo reemplazo sostenida. | `TFR` < 2,1 por décadas; `MAC` (edad media a la maternidad) sube; `MedianAgePop` crece. En Asia oriental y el sur de Europa se ve **fecundidad "ultra-baja" (< 1,4)**, más asociada a costos de vivienda/crianza y brechas de género que a la cohabitación (≈ debate abierto). | Les14 |
| **Dividendo demográfico** | *"When fertility falls, a country gets a one-time window: many workers, few dependents."* | Cuando baja la fecundidad, durante unas décadas hay más personas en edad de trabajar por cada dependiente; si hay empleo, educación y salud, se acelera el crecimiento económico. La ventana se cierra cuando la población envejece. | `TFR` en caída + edad mediana entre ~20 y ~35; tasa de dependencia en mínimo. La ONU estima que en **~100 países** la población en edad de trabajar (20–64) crecerá más rápido que la total hasta 2054 (WPP-SR, Key messages). Asia oriental (Corea, China, Tailandia) ya la cerró; África subsahariana la está abriendo. | Blo03; WPP-SR |
| **"Migration hump" / transición de la movilidad** | *"Development first increases emigration—only richer countries see it fall."* | Zelinsky (1971): la movilidad cambia por etapas con el desarrollo. Clemens (2014) y de Haas (2010): la emigración crece con el ingreso hasta niveles de ingreso medio (≈ 7.000–8.000 USD PPA en Clemens) y luego baja; los países ricos pasan de emisores a receptores. | `CNMR` negativa y más grande en países de ingreso **medio**, no en los más pobres; `CNMR` positiva en ingreso alto. Cambios de signo: España, Italia, Irlanda, Corea del Sur (emisores → receptores). Hipótesis a probar en los datos, no un hecho garantizado. | Zel71; Cle14; dHa10 |
| **Momentum poblacional** | *"Even with two children per woman, a young population keeps growing for decades."* | Una población joven sigue creciendo aunque la fecundidad ya esté en reemplazo, porque hay muchas mujeres en edad reproductiva. Al revés, una población vieja sigue cayendo aunque la fecundidad se recupere. | Según la ONU, el momentum explica **79 % del aumento mundial hasta 2054 (≈ 1.400 millones)** y el número de mujeres de 15–49 seguirá creciendo hasta fines de 2050 (pico ≈ 2.200 millones). En los países que ya tocaron techo, las mujeres de 15–49 caerán 33 % entre 2024 y 2054 (WPP-SR). En las series: `PopGrowthRate` > 0 aunque `TFR` < 2,1 (China 1991–2021). | Bon09; WPP-SR |

**Cómo proyecta la ONU en WPP2024 (variante Medium)** — para la diapositiva de "incertidumbre" (fuente: WPP-M 2024, sec. II):
1. **Fecundidad:** modelo bayesiano jerárquico en tres fases (I pretransición, II transición, III post-transición). Los países en fase II siguen una caída en forma de doble logística; en fase III la `TFR` tiende a un nivel propio de cada país, informado por los 39 países que ya mostraron una recuperación tras niveles bajo reemplazo. La media mundial de esos niveles finales está restringida a **≤ 2,1**; la media no ponderada de la distribución mundial basada en esos 39 países es 1,62 hijos por mujer en 2100 (intervalo de predicción 95 %: 1,33–1,85). Para países con baja fecundidad prolongada y sin señales de recuperación se asume que seguirá baja a corto plazo ("low fertility trap hypothesis"). **La fecundidad Medium es la media de 2.000 trayectorias simuladas** (WPP-M, sec. II.B).
2. **Mortalidad:** `LEx` femenina con doble logística + paseo aleatorio con deriva; la brecha hombre-mujer se modela aparte; se usa la mediana de las trayectorias como proyección estándar. "Life expectancy was generally assumed to increase over the projection period".
3. **Migración (por primera vez probabilística en 2024):** modelo AR(1) bayesiano jerárquico sobre la tasa neta (`CNMR`, por mil) estimado con 1950–2023 (Azose & Raftery). Con ajustes expertos: periodos de referencia propios para 42 países, años de "regreso a la normalidad" (p. ej., Ucrania, Rusia, Polonia, Alemania, Sudán: 2026–2027, con **retorno de 2/3 de los refugiados**), tasas fijadas a largo plazo para 32 países (p. ej., EAU, Catar, Arabia Saudí, Kuwait: +0,5 por mil desde 2030; México −0,8 por mil desde 2024) y topes acumulados para los países del Golfo.
4. **Por qué la migración es lo más incierto**, en palabras de la ONU: "International migration is the component of population change that is the most difficult to project… Any long-range assumption regarding future trends in international migration is virtually guaranteed to prove incorrect" (WPP-M, sec. II.E). Frase de vídeo sugerida: *"Births and deaths follow slow, predictable trends; migration can flip in a single year."*

---

## 2. Tabla cronológica mundial 1950–2024 (72 eventos)

Columnas: **Año(s)** | **Lugar** | **Evento (ES) / etiqueta EN para la gráfica** | **Componente** (F = fecundidad, M = mortalidad, Mig = migración) | **Huella esperada en WPP** (con cifras **[V]** = verificadas en WPP2024 Medium; **[PV]** = por verificar) | **Fuente (URL, año)**.

> Lectura rápida de la columna "huella": `LEx` en años, `TFR` en hijos por mujer, `IMR`/`Q5` por 1.000 nacidos vivos, `CNMR` por 1.000 habitantes, `NetMigrations` en miles de personas, `PopGrowthRate` en % anual, `MedianAgePop` en años. Los años de crisis en WPP son estimaciones modeladas (ver §0.2).

| # | Año(s) | Lugar | Evento / *EN label* | Comp. | Huella esperada en WPP2024 | Fuente |
|---|---|---|---|---|---|---|
| 1 | 1946–1964 | EE. UU., Canadá, Australia, Europa occ. | Baby boom de posguerra / *Post-war baby boom* | F | `TFR` EE. UU. 3,09 (1950) → 3,73 (1960) → 1,79 (1976); Canadá 3,86 (1959) [V]. En EE. UU. nacieron 76 millones entre 1946 y 1964, pico de 4,3 millones en 1957. Hoy se ve como envejecimiento (`MedianAgePop` EE. UU. 26,7 en 1970 → 38,0 en 2023) [V]. | PRB (2014) https://www.prb.org/news/just-how-many-baby-boomers-are-there/ ; US Census P25-1141 (2014) https://www.census.gov/content/dam/Census/library/publications/2014/demo/p25-1141.pdf |
| 2 | 1950–1953 | Corea del Sur | Guerra de Corea / *Korean War* | M, Mig | `LEx` 22,2 (1950) → 40,5 (1953); `CDR` 47 por mil en 1950 [V]. | Britannica, "Korean War" https://www.britannica.com/event/Korean-War |
| 3 | 1959–1961 | China | Gran Hambruna china (Gran Salto Adelante) / *Great Chinese Famine* | M, F | `LEx` China 48,8 (1958) → **33,4 (1960)**; `TFR` 5,70 → 3,86 (1961) y rebote a 7,51 (1963); `PopGrowthRate` −0,03 % (1960) [V]. **Se ve incluso en el mundo**: `LEx` mundial 51,6 (1958) → 47,8 (1960) [V]. ≈ 30 millones de muertes en exceso (Ashton et al.). | Ashton, Hill, Piazza, Zeitz (1984) *PDR* 10(4) https://doi.org/10.2307/1973284 |
| 4 | 1961–1973 | Alemania occ. ← Turquía, sur de Europa | Acuerdos de trabajadores invitados (Turquía 30-oct-1961) y freno al reclutamiento (1973) / *Guest-worker agreements* | Mig | Turquía `CNMR` negativa en los 60–70 (−4,1 por mil en 1970) [V]; Alemania `NetMigrations` +584 mil (1969) y negativa en 1974–75 tras el freno [V]. ≈ 867.000 turcos fueron a Alemania entre 1961 y 1973. Ojo: Alemania 1970 (−274 mil) parece artefacto [PV]. | Deutschland Museum (s. f.) https://www.deutschlandmuseum.de/en/history/calendar/1961-10-30-guest-workers/ |
| 5 | 1962–1964 | Corea del Sur, Taiwán | Programas nacionales de planificación familiar (Corea 1962; experimento de Taichung 1963) / *National family planning programmes* | F | `TFR` Corea 5,99 (1960) → 2,10 (1983); Taiwán 5,79 (1960) → 2,05 (1984) [V]. | PRB, "Did South Korea's Population Policy Work Too Well?" https://www.prb.org/news/did-south-koreas-population-policy-work-too-well/ ; Kim (2008) https://link.springer.com/article/10.1007/s12280-008-9054-5 |
| 6 | 1956 / 1964–1966 | Túnez | Código del Estatuto Personal (1956) y programa nacional de PF (1966) / *Personal Status Code & family planning* | F | `TFR` 7,17 (1963) → 2,03 (2000) [V]; primer programa de PF de África. | HHR Journal (2016) https://www.hhrjournal.org/2016/09/12/reproductive-health-policy-in-tunisia-womens-right-to-reproductive-health-and-gender-empowerment/ |
| 7 | 1966 | Japón | Año del "caballo de fuego" (*hinoeuma*) / *Fire Horse year* | F | `TFR` 2,09 (1965) → **1,63 (1966)** → 2,16 (1967) [V] (cifra oficial japonesa: 1,58; WPP suaviza un poco). | Our World in Data (2024) https://ourworldindata.org/data-insights/japans-birth-rate-dropped-sharply-in-1966-influenced-by-cultural-beliefs |
| 8 | 1966–1989 | Rumanía | Decreto 770: prohibición del aborto / *Decree 770 abortion ban* | F, M | `TFR` 1,87 (1966) → **3,59 (1967)** [V]; luego cae poco a poco; `TFR` 2,20 (1989) → 1,60 (1991) tras derogarse [V]. Alta mortalidad materna (no está en WPP). | Pop-Eleches (2006) *J. Political Economy* 114(4) https://doi.org/10.1086/506336 ; Decreto 770 (resumen) https://en.wikipedia.org/wiki/Decree_770 |
| 9 | 1969–1970 | Indonesia | Creación de BKKBN (1970), PF bajo Suharto / *BKKBN family planning* | F | `TFR` 5,59 (1966) → 3,11 (1990) → 2,50 (2000) [V]. | Banyan Global/USAID (2006) https://banyanglobal.com/wp-content/uploads/2017/05/Unraveling-the-Factors-Behind-the-Growth-of-the-Indonesian-Family-Planning-Private-Sector.pdf |
| 10 | 1970 | Tailandia | Política nacional de población (17-mar-1970); Mechai Viravaidya / *National population policy* | F | `TFR` 6,26 (1965) → 2,06 (1990) → 1,21 (2023) [V]. | The Overpopulation Project (2020) https://overpopulation-project.com/thailand-success-story-family-planning-with-creativity-and-humor/ |
| 11 | 1970–1971 | Bangladés (Pakistán Oriental) | Ciclón Bhola (nov-1970) y guerra de liberación (1971) / *Bhola cyclone & 1971 Liberation War* | M, Mig | `LEx` 48,7 (1969) → 42,7 (1970) → **26,5 (1971)** → 49,7 (1972) [V]. Ciclón: 300.000–500.000 muertes (≈); ~10 millones de refugiados en India (≈). | WMO (2020) https://wmo.int/media/news/worlds-deadliest-tropical-cyclone-was-50-years-ago ; Britannica https://www.britannica.com/event/Bangladesh-Liberation-War |
| 12 | 1971–1979 | China | Campaña "más tarde, más espaciado, menos" / *"Later, longer, fewer" campaign* | F | `TFR` 6,08 (1970) → 2,74 (1979) [V]: **la mayor parte de la caída ocurrió antes del hijo único** (Whyte et al.: hasta ~¾ de la caída desde 1970). | Whyte, Feng, Cai (2015) *The China Journal* 74 https://www.journals.uchicago.edu/doi/abs/10.1086/681664 |
| 13 | 1973–1985 | Estados del Golfo (EAU, Catar, Kuwait, Arabia Saudí, Omán, Baréin) | Primer auge petrolero y migración laboral; sustitución de árabes por asiáticos / *Oil boom labour migration* | Mig | EAU: 287 mil (1970) → 1,02 M (1980); `CNMR` EAU +142 por mil (1970) [V]. Árabes = 72 % de los inmigrantes del CCG en 1975 y 32 % en 2004 (≈). | Kapiszewski (2006), UN EGM https://www.un.org/en/development/desa/population/events/pdf/expert/11/P02_Kapiszewski.pdf |
| 14 | 1975–1979 | Camboya | Régimen de los Jemeres Rojos / *Khmer Rouge regime* | M, F | `LEx` 39,3 (1974) → **11,3 (1977)**; población 6,78 M (1974) → 5,09 M (1979); `TFR` 4,80 → 2,72 (1977) y rebote a 6,31 (1985) [V]. Exceso de muertes ≈ 1,2–2,8 M (IC 95 %, Heuveline). | UCLA Newsroom (Heuveline, 2015) https://newsroom.ucla.edu/releases/ucla-demographer-produces-best-estimate-yet-of-cambodias-death-toll-under-pol-pot |
| 15 | 1975–1990 | Líbano | Guerra civil libanesa / *Lebanese Civil War* | M, Mig | `LEx` 57,7 (1975) → **36,4 (1976)** [V]. ≈ 120.000–150.000 muertes; emigración estimada hasta ≈ 1 millón (rango amplio). | Britannica https://www.britannica.com/event/Lebanese-Civil-War |
| 16 | 1975–1995 | Vietnam | "Balseros" vietnamitas / *Vietnamese boat people* | Mig | `CNMR` Vietnam −6,6 por mil (1979) [V]. ≈ 800.000 llegaron a otros países 1975–1995. | UNHCR (2000), *State of the World's Refugees*, cap. 4 https://www.unhcr.org/sites/default/files/legacy-pdf/3ebf9bad0.pdf |
| 17 | 1975–1977 | India | "Emergencia": esterilizaciones forzadas (6,2 M en 1976–77) / *Emergency-era forced sterilisations* | F | **No se ve un quiebre**: `TFR` 5,19 (1975) → 4,78 (1980), caída gradual [V]. Útil para mostrar que la coerción no explica la tendencia de largo plazo (hipótesis, no prueba). | Ideas for India (2021) https://www.ideasforindia.in/topics/social-identity/forced-male-sterilisation-and-violence-against-women-evidence-from-emergency-india |
| 18 | 1977 | Bangladés (Matlab) | Experimento de salud materno-infantil y PF puerta a puerta / *Matlab family planning experiment* | F, M | `TFR` nacional 6,84 (1970) → 4,51 (1990) → 2,16 (2023) [V]; en Matlab la zona intervenida bajó de 4,8 a 2,9 (1979–2000) frente a 6,3 → 3,5 en la de control. | Phillips et al. (1982), PubMed https://pubmed.ncbi.nlm.nih.gov/7101359/ ; Schultz (UN EGM 2010) https://www.un.org/development/desa/pd/sites/www.un.org.development.desa.pd/files/unpd_egm_201012_schultz-long_term_effects_of_a_social_experiment_in_matlab_bangladesh_1974_-1996.pdf |
| 19 | 1979–1988 | Irán | Revolución islámica, guerra Irán–Irak (1980–88) y pronatalismo / *Revolution, Iran–Iraq War & pronatalism* | F, M | `TFR` se mantiene 6,2–6,6 (1979–1985); `PopGrowthRate` ≈ 3,7 % (1980–86); `LEx` 58,4 (1980) → 56,6 (1981) [V]. Muertes de guerra muy inciertas (≈ 200.000–500.000 iraníes). | Hakimian (2006) https://www.ceris.be/wp-content/uploads/2021/04/Hassan-Hakimian-Demographic-Transition-1980s-1990s.pdf ; PubMed 23981159 https://pubmed.ncbi.nlm.nih.gov/23981159/ |
| 20 | 1979–1989 | Afganistán → Pakistán, Irán | Guerra soviética; 6,2 M de refugiados (1989) / *Soviet–Afghan War exodus* | Mig, M | Población 13,66 M (1979) → 11,43 M (1985); `CNMR` −89 por mil y `NetMigrations` −1,17 M (1980); `LEx` 39,3 (1980) → 32,1 (1985) [V]. | UNHCR (1999) https://www.unhcr.org/news/briefing-notes/afghanistan-10-years-after-soviet-pull-out |
| 21 | 1980–2015 | China | Política del hijo único (carta abierta 25-sep-1980; fin anunciado 2015) / *One-child policy (1980–2015)* | F | `TFR` 2,74 (1980) → 1,59 (1995) [V]; repunte con la política de dos hijos: 1,67 (2015) → 1,80 (2017) [V]. | Britannica https://www.britannica.com/topic/one-child-policy |
| 22 | 1980 | Cuba → EE. UU. | Éxodo del Mariel (≈ 125.000) / *Mariel boatlift* | Mig | WPP lo **suaviza**: `NetMigrations` Cuba solo −37 mil en 1980 [V]. No usar WPP para "ver" el Mariel. | MPI (2017) https://www.migrationpolicy.org/article/cuban-migration-postrevolution-exodus-ebbs-and-flows |
| 23 | 1974–1990 | Mundo | Programa Ampliado de Inmunización (1974), erradicación de la viruela (1980), rehidratación oral / *Child-survival revolution* | M | `Q5` mundial 146 (1970) → 93 (1990); `IMR` 97 → 65 [V]. | WHO, "Smallpox" https://www.who.int/health-topics/smallpox |
| 24 | 1983–1985 | Etiopía | Hambruna de 1983–85 / *1984 Ethiopian famine* | M | `LEx` 43,4 (1982) → **36,3 (1983)**; `Q5` 236 → 312 por mil [V]. Muertes ≈ 400.000–500.000 (de Waal) hasta ≈ 1 M (ONU/gobierno). | House of Lords Library (2024) https://lordslibrary.parliament.uk/ethiopia-conflict-and-food-insecurity-40-years-on-from-the-1984-famine/ ; de Waal/HRW (1991) *Evil Days* |
| 25 | ~1985–2005 | África austral (Botsuana, Esuatini, Lesoto, Zimbabue, Sudáfrica, Zambia, Namibia) | Epidemia de VIH/sida / *HIV/AIDS epidemic* | M (y F) | Caídas de `LEx` del pico al valle [V]: **Esuatini 61,9 (1988) → 43,9 (2004)**; Lesoto 59,6 (1988) → 43,2 (2006); Zimbabue 61,0 (1986) → 44,5 (2001); Botsuana 63,7 (1984) → 52,2 (2001); Sudáfrica 63,0 (1989) → 53,9 (2005); `IMR` Botsuana sube 37,8 (1988) → 53,7 (2000). | WPP-M (2024) tabla I.2 https://population.un.org/wpp/assets/Files/WPP2024_Methodology-Report_Final.pdf ; UNAIDS https://www.unaids.org/en/regionscountries/countries |
| 26 | 2002–2004 | Botsuana (2002), Sudáfrica (1-abr-2004), PEPFAR (2003) | Tratamiento antirretroviral público / *ART rollout* | M | Recuperación de `LEx` [V]: Botsuana 52,2 (2001) → 69,2 (2023); Esuatini 43,9 → 64,1; Zimbabue 44,5 → 62,8; Sudáfrica 53,9 → 66,1. En Sudáfrica, pacientes en TAR: 47.500 (2004) → 1,79 M (2011). | Botsuana: Wester et al. (2010) https://pmc.ncbi.nlm.nih.gov/articles/PMC2853026/ ; Sudáfrica: Health-e News (2014) https://health-e.org.za/2014/04/04/south-africa-celebrates-ten-years-free-hiv-treatment/ ; SAJHIVMED https://sajhivmed.org.za/index.php/hivmed/article/view/156/261 |
| 27 | 1985–1987 | URSS (Rusia) | Campaña antialcohol de Gorbachov / *Anti-alcohol campaign* | M | `LEx` Rusia 68,3 (1985) → 70,1 (1987) [V]: subida breve antes de la crisis. | Brainerd & Cutler (2005) *JEP* 19(1) https://www.aeaweb.org/articles?id=10.1257/0895330053147921 |
| 28 | 1988 | Armenia | Terremoto de Spitak (7-dic-1988) / *Spitak earthquake* | M | `LEx` 67,6 (1987) → **52,7 (1988)** [V]. Muertes oficiales 24.944 (≈ 25.000–60.000 según fuente). | EARTH Magazine (2018) https://www.earthmagazine.org/article/benchmarks-december-7-1988-massive-earthquake-devastates-armenia |
| 29 | 1989 | Irán | Reactivación del programa nacional de PF / *1989 family planning programme* | F | `TFR` 5,17 (1989) → 2,85 (1995) → **2,00 (2000)** [V]: una de las caídas más rápidas registradas. La caída empezó a mediados de los 80, antes del programa. | Abbasi-Shavazi, McDonald, Hosseini-Chavoshi (2009) Springer https://link.springer.com/book/10.1007/978-90-481-3198-3 |
| 30 | 1989 | Bulgaria → Turquía | Expulsión de ≈ 360.000 turcos ("Gran Excursión") / *1989 expulsion of Turks* | Mig | `NetMigrations` Bulgaria −115 mil (1989) y −117 mil (1990) [V]; casi la mitad regresó después. | Univ. of St Andrews (Kamusella, 2018) https://research-portal.st-andrews.ac.uk/en/publications/ethnic-cleansing-during-the-cold-war-the-forgotten-1989-expulsion/ |
| 31 | 1989 | Japón | "Choque del 1,57": la fecundidad cae por debajo del mínimo de 1966 / *"1.57 shock"* | F | `TFR` 1,55 (1989) [V]; desde entonces nunca vuelve a 2. | Metropolis Japan (s. f.) https://metropolisjapan.com/year-of-fire-horse-myth-in-japan/ [PV: buscar fuente oficial MHLW] |
| 32 | 1990–1994 | Alemania (este) | Reunificación (3-oct-1990) y colapso de la fecundidad en el Este (TFR 0,77 en 1993–94) / *German reunification* | F, Mig | `TFR` Alemania 1,46 (1990) → **1,25 (1994)** [V] (WPP no separa Este/Oeste); `NetMigrations` +812 mil (1992, incl. *Spätaussiedler* y asilo) [V]. | Conrad, Lechner, Werner (1996) *PDR* https://www.semanticscholar.org/paper/East-German-Fertility-After-Unification:-Crisis-or-Conrad-Lechner/ac4122ff36be9a3ef7248c5c11f879868c6c1ad9 |
| 33 | 1990–1991 | Kuwait, Jordania | Invasión iraquí de Kuwait y guerra del Golfo / *Iraqi invasion of Kuwait* | Mig | Kuwait: 2,22 M (1989) → 1,35 M (1991); `NetMigrations` −1,20 M (1990) y +461 mil (1991) [V]. Jordania `CNMR` +73 por mil (1990) por retornados [V]. ≈ 1,6 M huyeron; la población palestina pasó de ≈ 400.000 a < 30.000. | MERIP (1991) https://www.merip.org/1991/07/the-other-face-of-war/ ; Country Studies https://countrystudies.us/persian-gulf-states/33.htm |
| 34 | 1991–1995 | Rusia, Ucrania, Bálticos, Kazajistán | Crisis de mortalidad postsoviética / *Post-Soviet mortality crisis* | M, F | `LEx` [V]: Rusia 70,1 (1987) → **63,8 (1994)**; Letonia 71,0 → 65,2 (1994); Estonia 71,0 → 66,7; Ucrania 71,2 → 67,1 (1995). `TFR` Rusia 2,25 (1987) → 1,19 (2000). Hombres rusos: 64,2 (1989) → 57,6 (1994) (fuente externa). | Brainerd & Cutler (2005) https://www.aeaweb.org/articles?id=10.1257/0895330053147921 ; Shkolnikov et al., *Lancet* (2001) https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(01)05802-0/fulltext |
| 35 | 1991–1999 | Kazajistán | Emigración de rusos y alemanes étnicos / *Ethnic out-migration after USSR* | Mig | `CNMR` −30,5 por mil (1994) y −31,2 (1998); `PopGrowthRate` −2,6 % (1998) [V]. ≈ 1,85 M emigraron 1989–1999 (alemanes: 957 mil → 353 mil). | Sitio resumen (Wikipedia, Demographics of Kazakhstan, con censos 1989/1999) https://en.wikipedia.org/wiki/Demographics_of_Kazakhstan [PV: sustituir por censo oficial] |
| 36 | 1991–2000 | Cuba | "Periodo especial" tras la caída de la URSS / *Special Period* | F, M, Mig | PIB −35 % (1989–92); epidemia de neuropatía óptica (> 50.000 casos, 1991–93). `TFR` 1,81 (1990) → 1,47 (1994) [V]; `LEx` sin caída visible [V]. Crisis de los balseros 1994 (≈ 35.000). | NEJM (1995) https://www.nejm.org/doi/full/10.1056/NEJM199511023331803 ; MPI https://www.migrationpolicy.org/article/cuban-migration-postrevolution-exodus-ebbs-and-flows |
| 37 | 1991–1992 | Somalia | Guerra civil y hambruna / *Somali civil war & famine* | M, Mig | `LEx` 46,9 (1990) → **25,4 (1991)**; `CNMR` −83 por mil (1991) [V]. | HRW World Report 1993 (Somalia) https://www.refworld.org/reference/annualreport/hrw/1993/en/92972 (≈ 300.000 muertes por hambre 1991–92) |
| 38 | 1992–1995 | Bosnia y Herzegovina | Guerra de Bosnia (Srebrenica 1995) / *Bosnian War* | M, Mig | `LEx` 71,8 (1991) → **52,0 (1992)**; `CNMR` −103 por mil (1992); población 4,46 M (1991) → 3,72 M (1995) [V]. 97.207 víctimas con nombre (RDC, 2013). | RFE/RL (2007) https://www.rferl.org/a/1077262.html |
| 39 | 1994 | Ruanda | Genocidio contra los tutsis (abr–jul 1994) / *1994 genocide* | M, Mig | `LEx` 42,9 (1993) → **12,2 (1994)**; población 7,98 M (1993) → 5,67 M (1995); `CNMR` −306 por mil (1994, éxodo a Zaire) y +204 (1996, retorno) [V]. > 800.000 muertos en ~100 días. | OHCHR (2014) https://www.ohchr.org/en/stories/2014/04/rwanda-genocide-20-years-later |
| 40 | 1994–1998 | Corea del Norte | Hambruna (*Arduous March*) / *North Korean famine* | M | `LEx` 70,5 (1994) → **60,8 (1995)**, meseta hasta 2000 y 69,2 en 2005 [V] (la meseta plana sugiere un supuesto de modelo). ≈ 600.000–1 M de muertes en exceso (Goodkind & West). | Goodkind & West (2001) *PDR* https://ghdx.healthdata.org/record/north-korean-famine-and-its-demographic-impact |
| 41 | 1998–1999 | Kosovo | Guerra y expulsión de ≈ 850.000 albanokosovares / *Kosovo War exodus* | Mig, M | `CNMR` −142 por mil (1998) y −90 (1999); `LEx` 58,3 (1999) [V]; ~90 % regresó. | HRW (2001) https://www.hrw.org/reports/2001/kosovo/undword-03.htm |
| 42 | 1998–2003 | Kenia | Estancamiento de la caída de la fecundidad / *Fertility stall* | F | DHS: 4,7 (1998) → 4,9 (2003). WPP lo suaviza: `TFR` 5,14 (2000) → 4,94 (2003) [V]. `LEx` también cae por VIH: 60,9 (1985) → 55,5 (1997) [V]. | DHS Program (Westoff & Cross 2006) https://dhsprogram.com/publications/publication-as9-analytical-studies.cfm |
| 43 | 2000–2009 | Zimbabue | Colapso económico, hiperinflación (2008), cólera y emigración / *Economic collapse & exodus* | Mig, M | `CNMR` −13,9 por mil (2000), −10,8 (2005), −11,3 (2015) [V]. Emigración estimada en millones (≈, cifras muy discutidas). | IOM (2009) *Migration in Zimbabwe* https://publications.iom.int/system/files/pdf/mp_zimbabwe.pdf |
| 44 | 2003–2008 | Sudán (Darfur) | Conflicto de Darfur / *Darfur conflict* | M, Mig | `CNMR` −9,4 por mil (2003); `LEx` 58,95 (2000) → 57,2 (2005) [V]. ≈ 300.000 muertes civiles y 2,7 M desplazados. | USHMM https://encyclopedia.ushmm.org/content/en/article/darfur |
| 45 | 2004 / 2007 | Polonia, Bálticos (2004); Rumanía, Bulgaria (2007) | Ampliaciones de la UE y libre movilidad / *EU enlargement & free movement* | Mig | `CNMR` Lituania −15,5 (2005) y **−25,5 (2010)**; Letonia −17,2 (2010); Rumanía −7,0 (2008) [V]. Polonia: WPP solo muestra −42 mil (2005) aunque había ≈ 2,27 M de polacos en el exterior en 2007 → **posible subregistro en WPP [PV]**. | MPI (Polonia) https://www.migrationpolicy.org/journal/country-profile/eu-membership-highlights-polands-migration-challenges ; OSW (Lituania, 2024) https://www.osw.waw.pl/en/publikacje/osw-commentary/2024-12-03/lithuania-losing-people-without-a-fight |
| 46 | 2004 | Indonesia (Aceh), Sri Lanka | Tsunami del océano Índico (26-dic-2004) / *Indian Ocean tsunami* | M | `LEx` Sri Lanka 72,4 (2003) → 68,0 (2004); Indonesia 67,1 → 65,5 [V]. ≈ 227.000 muertos y desaparecidos. | Geoscience Australia (2014) https://www.ga.gov.au/news/ten-years-on-2004-indian-ocean-tsunami/10-years-after-the-indian-ocean-tsunami-what-have-we-learned |
| 47 | 2000–2008 | España | Auge inmigratorio / *Spain's immigration boom* | Mig | `NetMigrations` +738 mil (2002) y +772 mil (2007); luego −251 mil (2013) [V]. Nacidos en el extranjero: 1,5 M → 6 M (2000–2008). | MPI (Arango) https://www.migrationpolicy.org/sites/default/files/publications/TCM-Spaincasestudy.pdf |
| 48 | 1995–2012 | Irlanda | De emisor a receptor (*Celtic Tiger*) y vuelta a emigrar tras 2008 / *Celtic Tiger migration reversal* | Mig | `CNMR` −14,6 (1955) → +17,4 (2007) → −5,9 (2010) [V]: ejemplo de cambio de signo. | MPI (Glynn et al.) https://www.migrationpolicy.org/sites/default/files/publications/TCM-Emigration-Ireland-FINAL.pdf ; CSO (2010) https://cso.ie/en/media/csoie/releasespublications/documents/population/2010/popmig_2010.pdf |
| 49 | 2005–2008 | Catar, EAU, Baréin | Auge de la construcción en el Golfo / *Gulf construction boom* | Mig | `PopGrowthRate` Catar **22,1 % (2006)**; EAU 13,8 % (2007) [V]. Razón de sexos Catar 320 hombres por 100 mujeres (2008) [V]. | GLMM (UAE, 2018) https://gulfmigration.grc.net/media/pubs/exno/GLMM_EN_2018_01.pdf |
| 50 | 2008 | Myanmar | Ciclón Nargis / *Cyclone Nargis* | M | `LEx` 62,4 (2007) → 56,4 (2008) [V]. ≈ 84.537 muertos + 53.836 desaparecidos (≈ 138.000). | GFDRR (2008) https://www.gfdrr.org/en/myanmar-2008-pdna-undertaken-after-cyclone-nargis-killed-84537-people |
| 51 | 2007–2012 | México → EE. UU. | Gran Recesión: la migración neta México–EE. UU. llega a cero / *Net migration falls to zero* | Mig | `NetMigrations` México −356 mil (2000) → −41 mil (2010) [V]. | Pew Research (2012) https://www.pewresearch.org/short-reads/2012/08/06/net-migration-from-mexico-falls-to-zero-and-perhaps-less/ |
| 52 | 2008–2014 | Egipto | Repunte de la fecundidad (DHS 3,0 → 3,5) / *Fertility rebound* | F | `TFR` 3,24 (2008) → 3,50 (2015) [V]: excepción a la idea de que la fecundidad "solo baja". | Radovich et al. (2018) *PLoS ONE* https://journals.plos.org/plosone/article?id=10.1371%2Fjournal.pone.0190148 |
| 53 | 2010 | Haití | Terremoto (12-ene-2010) / *2010 Haiti earthquake* | M | `LEx` 61,7 (2009) → **45,6 (2010)** → 61,6 (2011); `IMR` 61 → 82 [V]. Muertes ≈ 100.000–316.000 según fuente (ONU ≈ 220.000). | Britannica https://www.britannica.com/event/2010-Haiti-earthquake |
| 54 | 2011 | Somalia | Hambruna 2010–2012 (≈ 258.000 muertes, la mitad < 5 años) / *2011 Somalia famine* | M | `LEx` 48,9 (2010) → **32,5 (2011)** [V]. | FSNAU/FAO (2013) https://www.fao.org/somalia/news/detail-events/en/c/247642/ |
| 55 | 2011– | Siria → Turquía, Líbano, Jordania, Europa | Guerra civil siria / *Syrian civil war* | Mig, M | Siria: `CNMR` **−96 por mil (2013)**; población 22,9 M (2011) → 19,2 M (2016); `LEx` 73,5 (2010) → 63,3 (2015) [V]. Receptores [V]: Líbano `CNMR` +128 por mil (2013); Jordania +76 (2013); Turquía `NetMigrations` +1,06 M (2015). UNHCR (registrados): Turquía 2,91 M, Líbano 0,77 M, Jordania 0,61 M. | UNHCR Data Portal https://data.unhcr.org/en/situations/syria |
| 56 | 2014–2016 | Guinea, Liberia, Sierra Leona | Ébola en África occidental (28.600 casos, 11.300 muertes) / *West Africa Ebola* | M | **Casi invisible en `LEx` nacional**: Sierra Leona 54,1 (2013) → 54,3 (2014) [V]. Lección: no toda crisis famosa cambia los promedios nacionales. | WHO https://www.who.int/emergencies/situations/ebola-outbreak-2014-2016-West-Africa |
| 57 | 2015 | Alemania (y UE) | "Verano de los refugiados": ≈ 890.000 llegadas / *2015 refugee arrivals* | Mig | `NetMigrations` Alemania **+1,18 M (2015)**; `PopGrowthRate` 1,19 % [V]. | BAMF (2016) Migration Report 2015 https://www.bamf.de/SharedDocs/Anlagen/EN/Forschung/Migrationsberichte/migrationsbericht-2015-zentrale-ergebnisse.pdf?__blob=publicationFile&v=13 |
| 58 | 2015– | Venezuela → Colombia, Perú, Chile, Ecuador, Brasil | Éxodo venezolano (≈ 7,9 M en dic-2024) / *Venezuelan exodus* | Mig | Venezuela `NetMigrations` **−1,36 M (2018)**, `CNMR` −45 por mil; población 30,8 M (2016) → 28,2 M (2022) [V]. Receptores 2018 [V]: Colombia +496 mil; Perú +339 mil; Chile +238 mil; Ecuador +95 mil. | MPI (2024) https://www.migrationpolicy.org/article/venezuelan-immigrants-united-states ; R4V https://www.r4v.info/ |
| 59 | 2016 / 2021 | China | Política de dos hijos (2016) y de tres hijos (2021) / *Two-child (2016), three-child (2021)* | F | `TFR` 1,77 (2016) → 1,24 (2020) → **1,00 (2023)** [V]; la población empieza a caer en 2022 (`PopGrowthRate` −0,13 %) [V]. NBS: 9,02 M nacimientos y 11,10 M muertes en 2023. | Britannica https://www.britannica.com/topic/one-child-policy ; NBS (2024) https://www.stats.gov.cn/english/PressRelease/202402/t20240228_1947918.html |
| 60 | 2017 | Puerto Rico → EE. UU. continental | Huracán María (20-sep-2017) / *Hurricane Maria* | Mig, M | `NetMigrations` −150 mil (2017), `CNMR` −44,5 por mil; `LEx` 80,4 → 79,1 [V]. 2.975 muertes en exceso (GWU). Censo: −11,8 % entre 2010 y 2020. | GWU (2018) https://research.gwu.edu/gw-researchers-2975-excess-deaths-linked-hurricane-maria ; PRB https://www.prb.org/news/puerto-ricos-population-declined-by-12-percent-between-2010-and-2020-where-did-they-go/ |
| 61 | 2017–2018 | Arabia Saudí | Tasa a dependientes de expatriados (jul-2017) / *Expat dependants levy* | Mig | `NetMigrations` −921 mil (2017) y −989 mil (2018); `PopGrowthRate` −1,5 % (2018) [V]. | Middle East Eye (2018) https://www.middleeasteye.net/news/saudi-levy-foreign-workers-pushes-thousands-leave-country |
| 62 | 2020–2021 | Mundo (máximo en América Latina) | Pandemia de COVID-19 / *COVID-19 pandemic* | M, Mig | `LEx` mundial 72,6 (2019) → **70,9 (2021)** → 73,2 (2023) [V]. Mayores caídas (países > 1 M hab.) [V]: Bolivia −6,4; Armenia −6,3 (también guerra 2020); Paraguay −5,6; Ecuador −5,3; México −4,8; Perú −4,7; Líbano −4,6; Cuba −4,2; Colombia −4,1; Sudáfrica −4,1. 147 de 161 países ya superaron su `LEx` de 2019 en 2023 [V]. OMS: 14,9 M muertes en exceso 2020–21. Salida de migrantes del Golfo en 2020 (Omán −172 mil; Kuwait −168 mil) [V]. | WHO (2022) https://www.who.int/news/item/05-05-2022-14.9-million-excess-deaths-were-associated-with-the-covid-19-pandemic-in-2020-and-2021 ; WPP-SR (2024) |
| 63 | 2021 | Afganistán | Toma del poder por los talibanes (ago-2021) / *Taliban takeover* | Mig | `NetMigrations` −549 mil (2021) y −647 mil (2022) [V]. | UNHCR, Afghanistan situation https://data.unhcr.org/en/situations/afghanistan |
| 64 | 2022 | Ucrania → Polonia, Alemania, UE, Rusia | Invasión rusa a gran escala (24-feb-2022) / *Russian full-scale invasion* | Mig, M, F | `NetMigrations` Ucrania **−5,70 M (2022)**, `PopGrowthRate` −14,8 %; población 44,3 M (2021) → 37,7 M (2023); `TFR` 0,90 (2022) [V]. Receptores 2022 [V]: Polonia +968 mil; Alemania +982 mil. **Supuesto ONU**: retorno de 2/3 de los refugiados → +1,15 M (2024) y +1,70 M (2025) [V] (hipótesis, no hecho). | UNRIC (2023) https://unric.org/en/ukraine-over-6-million-refugees-spread-across-europe/ ; WPP-M tabla II.3.B |
| 65 | 2022–2023 | Cuba | Mayor ola emigratoria de su historia / *Largest Cuban exodus* | Mig | ONEI: 11,18 M (dic-2021) → 10,06 M (dic-2023) (−10 %). **WPP2024 no lo capta**: `NetMigrations` ≈ −23 mil/año; población 11,02 M en 2023 [V]. Discrepancia a citar en ética. | CEDA (2024) https://www.weareceda.org/en/us-cuba-news-brief/cubas-largest-emigration-in-history-july-25-2024 |
| 66 | 2022 | Mundo | "Día de los 8.000 millones" (15-nov-2022) / *Day of 8 Billion* | — | Población mundial 7,95 MM (2021) → 8,09 MM (2023) [V]. | UN DESA https://www.un.org/en/dayof8billion |
| 67 | 2023 | Sudán → Chad, Egipto, Sudán del Sur | Guerra SAF–RSF (15-abr-2023), mayor crisis de desplazamiento del mundo / *Sudan war* | Mig, M | `NetMigrations` Sudán **−1,35 M (2023)**; `PopGrowthRate` 0,02 % [V]; Egipto `NetMigrations` +305 mil (2023) [V]. | UNHCR, Sudan emergency https://www.unhcr.org/us/emergencies/sudan-emergency |
| 68 | 2023 | Canadá | Récord de crecimiento (+3,2 %, el mayor desde 1957), 97,6 % por migración / *Record immigration-driven growth* | Mig | **WPP2024 subestima**: `PopGrowthRate` 1,22 % y `NetMigrations` +434 mil (2023) [V] frente a +1,27 M de StatCan. Usar para la diapositiva de incertidumbre. | Statistics Canada (2024) https://www150.statcan.gc.ca/n1/daily-quotidien/240327/dq240327c-eng.pdf |
| 69 | 2022–2024 | EE. UU. | Pico de inmigración neta (CBO: 3,3 M en 2023) / *Immigration surge* | Mig | **WPP2024 subestima**: `NetMigrations` +1,32 M (2023) [V] frente a 3,3 M de la CBO. | CBO (2024) https://www.cbo.gov/publication/59697 |
| 70 | 2023 | Corea del Sur | Fecundidad más baja de un país soberano (0,72) / *Lowest fertility of any country* | F | `TFR` 0,72 (2023) = dato oficial; 6,06 en 1950 [V]. (Macao 0,66 y Hong Kong 0,72 son RAE de China.) Población proyectada 51,7 M (2023) → 21,8 M (2100) [V]. | France 24 / Statistics Korea (2024) https://www.france24.com/en/live-news/20240228-south-korea-birth-rate-falls-to-all-time-low |
| 71 | 2023 | Italia, España, Japón | Mínimos históricos de nacimientos / *Record-low births* | F | `TFR` 2023 [V]: Italia 1,20 (= ISTAT); España 1,21 (INE: 1,12 → diferencia a explicar); Japón 1,21. Italia perdió solo 7.000 hab. en 2023 gracias a la inmigración (ISTAT). | ISTAT vía Il Sole 24 Ore (2024) https://en.ilsole24ore.com/art/istat-still-record-low-births-in-italy-AGHH21f ; INE (2024) https://ine.es/dyngs/Prensa/en/MNP2023.htm |
| 72 | 1950–2024 | Níger, Nigeria, Sahel | Fecundidad alta persistente / *Persistently high fertility* | F | Níger `TFR` ≥ 7,5 hasta 2012 (7,53 en 2012; DHS 2012: 7,6) y 6,06 en 2023; Nigeria 6,85 (1980) → 4,48 (2023) [V]; Níger población 26,2 M (2023) → 52,5 M (2050) [V]. 79 % de las mujeres de 20–24 en Níger se casaron antes de los 18 (DHS 2012). | Banco Mundial (Onagoruwa & Wodon, 2017) https://documents.worldbank.org/curated/en/134071511425023648/Child-marriage-and-fertility-in-Niger |

**Notas de uso de la tabla**
- **Eventos que NO deben anotarse con WPP sin advertencia** (porque WPP los suaviza o no los capta): Mariel 1980 (#22), emigración polaca tras 2004 (#45), Kenia 1998–2003 (#42), Cuba 2022–23 (#65), Canadá y EE. UU. 2023 (#68–69). Son, en cambio, **excelentes ejemplos para la diapositiva de ética/incertidumbre**: "la migración es el componente más difícil de medir y proyectar" (WPP-M).
- **Eventos con huella espectacular y bien verificada** (candidatos a anotación en el vídeo): #3 China 1960, #14 Camboya 1977, #25–26 VIH/TAR, #34 Rusia 1994, #39 Ruanda 1994, #49 Golfo, #55 Siria 2013, #58 Venezuela 2018, #62 COVID, #64 Ucrania 2022, #70 Corea 0,72.

---

## 3. Fichas regionales (regiones ODS) y por grupo de ingreso

**Tabla resumen [V]** (WPP2024 Medium; agregados oficiales de WPP). `CNMR` media = promedio simple anual 1990–2023 (por mil). "Año TFR<2,1" = primer año en que la serie del agregado baja de 2,1 (puede estar en la proyección).

| Agregado | TFR 1950 | TFR 1990 | TFR 2023 | TFR 2050 | Año TFR<2,1 | LEx 1950 | LEx 1990 | LEx 2023 | Q5 1990 | Q5 2023 | CNMR 1990–2023 | Crec. 2023 % | Edad mediana 2023 | Pob. 2023 (M) | Pob. 2054 (M) | Pob. 2100 (M) | Año pico |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| África subsahariana | 6,42 | 6,30 | 4,32 | 2,87 | 2092 | 37,2 | 49,1 | 62,1 | 182 | 69 | −0,37 | 2,56 | 18,1 | 1.212 | 2.225 | 3.351 | ≥2100 |
| Norte de África y Asia occidental | 6,52 | 4,43 | 2,73 | 2,23 | 2062 | 40,6 | 64,3 | 73,8 | 78 | 24 | +0,58 | 1,56 | 25,9 | 573 | 819 | 987 | ≥2100 |
| Asia central y meridional | 5,89 | 4,33 | 2,25 | 1,97 | 2033 | 40,3 | 58,8 | 71,7 | 125 | 33 | −1,13 | 1,04 | 26,8 | 2.124 | 2.664 | 2.639 | 2074 |
| Asia oriental y sudoriental | 5,54 | 2,62 | 1,33 | 1,47 | 1993 | 43,1 | 68,1 | 76,8 | 56 | 15 | −0,10 | 0,05 | 37,0 | 2.350 | 2.191 | 1.449 | 2028 |
| América Latina y el Caribe | 5,79 | 3,24 | 1,81 | 1,68 | 2014 | 48,7 | 67,4 | 75,7 | 55 | 16 | −1,51 | 0,70 | 30,9 | 659 | 731 | 613 | 2053 |
| Oceanía (excl. Australia/NZ) | 5,96 | 4,71 | 3,02 | 2,36 | 2071 | 42,6 | 62,4 | 67,7 | 67 | 35 | +1,14 | 1,60 | 23,0 | 14 | 20 | 24 | ≥2100 |
| Australia/Nueva Zelanda | 3,15 | 1,95 | 1,64 | 1,64 | 1977 | 69,0 | 76,8 | 83,6 | 10 | 4 | +6,54 | 0,96 | 37,7 | 32 | 39 | 49 | ≥2100 |
| Europa y América del Norte | 2,78 | 1,81 | 1,47 | 1,55 | 1973 | 63,4 | 73,7 | 79,2 | 14 | 5 | +2,65 | 0,18 | 40,9 | 1.129 | 1.124 | 1.067 | 2036 |
| Ingreso alto | 3,04 | 1,82 | 1,47 | 1,55 | 1976 | 61,8 | 75,3 | 81,4 | 13 | 5 | +3,37 | 0,39 | 40,9 | 1.261 | 1.287 | 1.252 | 2045 |
| Ingreso medio alto | 5,32 | 2,70 | 1,48 | 1,58 | 1995 | 45,4 | 67,4 | 75,9 | 55 | 14 | −0,28 | 0,19 | 35,5 | 2.811 | 2.756 | 2.026 | 2036 |
| Ingreso medio bajo | 5,80 | 4,46 | 2,55 | 2,17 | 2058 | 40,8 | 58,5 | 69,6 | 124 | 42 | −1,00 | 1,23 | 25,5 | 3.253 | 4.332 | 4.720 | 2089 |
| Ingreso bajo | 6,48 | 6,48 | 4,53 | 2,95 | 2093 | 31,2 | 49,2 | 64,9 | 186 | 62 | −0,87 | 2,73 | 17,9 | 736 | 1.406 | 2.152 | ≥2100 |
| **Mundo** | 4,85 | 3,31 | 2,25 | 2,10 | 2050 | 46,4 | 64,0 | 73,2 | 93 | 36 | 0,00 | 0,87 | 30,4 | 8.092 | 9.813 | 10.180 | 2084 |

> Advertencia: los agregados por ingreso de WPP2024 usan la clasificación del Banco Mundial vigente cuando se preparó WPP (no la FY2027 que usa nuestro repositorio en `data/raw/WB_income_groups.csv`). Si el análisis recalcula grupos con la clasificación FY2027, las cifras cambiarán ligeramente. Además, un país puede cambiar de grupo con el tiempo; los agregados de WPP asignan el grupo actual a toda la serie 1950–2100 (sesgo de "supervivencia" a explicar).

### 3.1 África subsahariana — *"Youngest region, slowest fertility decline"*
- **Mortalidad infantil en caída rápida y sostenida**: `Q5` 182 (1990) → 69 por mil (2023) [V]; la `LEx` subió 25 años desde 1950 (37,2 → 62,1) [V], pese al VIH.
- **VIH/sida (≈1985–2005)**: la única gran reversión regional de `LEx` fuera de guerras; peor en África austral (Esuatini, Lesoto, Botsuana, Zimbabue, Sudáfrica). Recuperación desde el TAR público (Botsuana 2002, Sudáfrica 2004, PEPFAR 2003) (§2 #25–26).
- **Fecundidad alta y caída lenta**: `TFR` 6,30 (1990) → 4,32 (2023) [V]; estancamientos documentados en Kenia, Ghana, Nigeria y otros (Schoumaker 2019, *Stud. Fam. Plann.* https://onlinelibrary.wiley.com/doi/10.1111/sifp.12098), asociados en parte a interrupciones en la escolarización femenina (Kebede, Goujon, Lutz 2019, *PNAS* https://www.pnas.org/doi/10.1073/pnas.1717288116).
- **Conflictos y desplazamientos**: Ruanda 1994, RD Congo 1996–2003, Somalia 1991–92 y 2011, Darfur 2003, Sudán del Sur 2013, Sudán 2023 (§2). La mayoría de los desplazados se quedan **dentro de la región** (Chad `CNMR` +25,7 por mil en 2023; Sudán del Sur +39,6) [V].
- **Momentum y crecimiento**: se proyecta que pase de 1.212 M (2023) a 2.225 M (2054) y 3.351 M (2100) [V]; en nueve países (incl. Angola, RCA, RD Congo, Níger, Somalia) la población se duplicaría entre 2024 y 2054 (WPP-SR, Key messages).
- **Dividendo demográfico pendiente**: la Unión Africana dedicó 2017 a "Harnessing the Demographic Dividend through Investments in Youth" (AU Roadmap, 2017: https://library.au.int/au-roadmap-harnessing-demographic-dividend-through-investments-youth); la edad mediana es 18,1 años [V].
- **Relación F–M–Mig esperada**: mortalidad baja primero y mucho, fecundidad baja después y lento (el mayor rezago del mundo) → crecimiento alto (2,56 %) [V]. La migración neta regional es pequeña (−0,37 por mil en promedio) [V]: **la emigración no es la palanca demográfica principal** de la región, aunque sea muy visible en el debate europeo.

### 3.2 Norte de África y Asia occidental — *"Oil, wars and the fastest fertility falls"*
- **Golfo**: desde el auge petrolero de 1973 la población de EAU, Catar, Kuwait, Baréin, Omán y Arabia Saudí creció sobre todo por migración laboral temporal, mayoritariamente masculina y asiática (razón de sexos Catar 251 y EAU 178 hombres por 100 mujeres en 2023) [V] (Kapiszewski 2006; GLMM).
- **Guerras y choques**: Líbano 1975–90, Irán–Irak 1980–88, invasión de Kuwait 1990, Irak 2003–07 (`CNMR` Irak −42 por mil en 2006 [V]), Siria 2011+, Yemen 2015+.
- **Transiciones de fecundidad muy rápidas**: Túnez (1966), Turquía, Irán (Irán está en la región ODS Asia central y meridional, pero suele compararse aquí), Líbano; **excepción**: Egipto, con repunte 3,0 → 3,5 entre 2008 y 2014 (DHS).
- **Yemen** tuvo la `TFR` más alta del mundo entre 1968 y 1994 (8,61 en 1990) y hoy 4,59 (2023) [V]; antes que Yemen el récord era de Ruanda (1950–67), después de Níger (1995–2018) y de Somalia (2019–23) [V].
- **Primavera Árabe 2011** y sus efectos: desplazamiento sirio masivo hacia Turquía, Líbano y Jordania (Líbano `CNMR` +128 por mil en 2013) [V].
- **Migración neta positiva promedio (+0,58 por mil, 1990–2023)** [V] por el Golfo y Turquía, pese a emigración desde Siria, Yemen, Irak.
- **Relación esperada**: mortalidad baja (`LEx` 73,8) [V] con fecundidad intermedia (2,73) [V]; el componente migratorio domina en el Golfo (≥ 70 % de residentes no nacionales en EAU/Catar/Kuwait según GLMM) y en los países receptores de refugiados; ojo con las series muy volátiles de `CNMR`.

### 3.3 Asia central y meridional — *"India, momentum and labour emigration"*
- **India**: programa nacional de planificación familiar desde 1952; Emergencia y esterilizaciones forzadas 1975–77; `TFR` 5,92 (1960) → 1,98 (2023) [V]. Supera a China en población en 2022 según WPP2024 (1.425,4 M vs 1.425,2 M) [V] y alcanzaría su pico en 2061 (≈ 1.701 M) [V].
- **Bangladés**: ciclón Bhola 1970, guerra 1971 (`LEx` 26,5) [V], hambruna 1974; luego una transición de la fecundidad modelo con PF comunitaria (Matlab 1977): `TFR` 6,84 (1970) → 2,16 (2023) [V].
- **Pakistán y Afganistán**: fecundidad aún alta (Pakistán 3,61; Afganistán 4,84 en 2023) [V]; Afganistán acumula 45 años de guerra y emigración (1979–89, 2001, 2021).
- **Irán**: pronatalismo de guerra (1980–88) y luego la caída más rápida: 6,24 (1985) → 2,00 (2000) [V].
- **Asia central postsoviética**: emigración de rusos y alemanes étnicos en los 90 (Kazajistán `CNMR` −31 por mil en 1998) [V]; emigración laboral a Rusia (Tayikistán, Kirguistán) con remesas muy altas (≈, Banco Mundial/KNOMAD https://www.knomad.org/data/remittances [PV cifra]); **repunte de fecundidad** reciente: Uzbekistán 2,44 (2010) → 3,50 (2023); Kazajistán 1,90 (2000) → 3,32 (2021) [V].
- **Emigración laboral al Golfo**: Nepal `CNMR` −13,8 por mil y crecimiento −0,14 % en 2023 [V]; India, Pakistán y Bangladés están entre los mayores emisores de trabajadores al CCG (Kapiszewski 2006; GLMM).
- **Relación esperada**: transición "a mitad de camino" — mortalidad ya baja (`LEx` 71,7), fecundidad en 2,25 [V] → **crecimiento sostenido por momentum** (pico regional 2074) [V]; migración neta negativa moderada (−1,13 por mil) [V] por emigración laboral.

### 3.4 Asia oriental y sudoriental — *"From baby booms to the lowest fertility on Earth"*
- **Gran Hambruna china (1959–61)** visible incluso en el promedio mundial (§2 #3).
- **Programas de PF tempranos y "milagro asiático"**: Taiwán y Corea (1962–64), Tailandia (1970), Indonesia (1970), China ("más tarde, más espaciado, menos", 1971; hijo único, 1980). La región cruzó el reemplazo en 1993 [V]. El dividendo demográfico explica una parte del crecimiento de los "tigres" (≈ un tercio del aumento del ingreso per cápita según Bloom & Williamson 1998, *World Bank Econ. Rev.* 12(3):419–455 https://ideas.repec.org/p/nbr/nberwo/6268.html).
- **Guerras y genocidios**: Corea 1950–53, Vietnam (hasta 1975), Camboya 1975–79 (`LEx` 11,3 en 1977) [V], Timor-Leste 1975–79 (`LEx` ≈ 23–26) [V].
- **Fecundidad ultra-baja**: Corea 0,72, Taiwán 0,87, China 1,00, Japón 1,21, Tailandia 1,21 (2023) [V]; la región tendría 1.449 M en 2100 frente a 2.350 M en 2023 (−38 %) [V].
- **Envejecimiento más rápido de la historia**: edad mediana 37,0 (2023) [V]; Japón 49,0 [V].
- **Migración**: emigración neta pequeña a nivel regional (−0,10 por mil) [V] pero con emisores importantes (Filipinas, Vietnam, Indonesia, Myanmar) y nuevos receptores (Corea, Japón, Singapur, Malasia, Tailandia).
- **Relación esperada**: el caso de manual de la transición completa: `IMR` y `TFR` bajan casi en paralelo y muy rápido; hoy **el motor de cambio es la baja fecundidad + el momentum negativo**, y la migración apenas compensa.

### 3.5 América Latina y el Caribe — *"Fast transitions, big diasporas, hardest hit by COVID"*
- **Caída de fecundidad rápida desde ~1965**: `TFR` 5,79 (1950) → 1,81 (2023) [V]; la región cruzó el reemplazo en 2014 [V]. Cuba y Barbados fueron los primeros países independientes de la región en bajar de 2,1 (1978; Cuba 1,88); solo el territorio de Bermudas lo hizo antes (1974) [V]. En Brasil, la llegada de las telenovelas de Globo se asocia con menor fecundidad (La Ferrara, Chong, Duryea 2012, *AEJ: Applied* https://www.aeaweb.org/articles?id=10.1257/app.4.4.1).
- **Grandes diásporas**: México–EE. UU. (hasta la "migración neta cero" de 2007–2012, Pew 2012), Triángulo Norte (El Salvador `CNMR` −9,0 por mil en 2010) [V], Caribe (Puerto Rico, Haití, Cuba).
- **Éxodo venezolano** desde 2015 (≈ 7,9 M en dic-2024): convierte a Colombia, Perú, Chile y Ecuador en receptores (§2 #58).
- **Desastres**: terremoto de Haití 2010 (`LEx` 45,6) [V]; huracán María 2017 (Puerto Rico).
- **COVID-19**: la región con mayor caída de `LEx`: 75,3 (2019) → 71,8 (2021) [V]; Bolivia, Paraguay, Ecuador, México, Perú y Colombia están entre las mayores caídas del mundo [V].
- **Envejecimiento acelerado**: edad mediana 30,9 (2023) [V]; Puerto Rico 45,3 y Cuba 41,7 [V]. Pico regional en 2053 [V].
- **Relación esperada**: transición de mortalidad y fecundidad casi completa; **la migración neta negativa (−1,51 por mil, la más negativa de todas las regiones)** [V] es el tercer motor y en el Caribe (Puerto Rico, Cuba, Jamaica) puede ser el principal.

### 3.6 Oceanía (excl. Australia/NZ) y Australia/Nueva Zelanda — *"Small islands, big diasporas"*
- **Melanesia** (Papúa Nueva Guinea, Islas Salomón, Vanuatu): fecundidad aún ≈ 3 (PNG 3,10 en 2023) [V] y crecimiento rápido.
- **Polinesia** (Samoa, Tonga): emigración estructural a Nueva Zelanda, Australia y EE. UU.: `CNMR` Tonga −20,8 y Samoa −13,0 por mil en 2023 [V]; en Tonga la población decrece (−0,42 %) [V].
- **Riesgo climático y movilidad**: tratado de la Unión Falepili Australia–Tuvalu (2023) que abre una vía migratoria anual (firmado 9-nov-2023, en vigor 28-ago-2024; hasta 280 tuvaluanos por año; DFAT https://www.dfat.gov.au/geo/tuvalu/australia-tuvalu-falepili-union-treaty); Tuvalu `CNMR` −32,9 por mil en 2023 [V] (ojo: población muy pequeña, tasas volátiles).
- **Australia/NZ**: crecimiento impulsado por inmigración (`CNMR` media +6,5 por mil 1990–2023) [V]; WPP-SR cita a Australia entre los países donde la inmigración será el principal motor de crecimiento hasta 2054.
- **Relación esperada**: en las islas, fecundidad media-alta compensada por emigración (crecimiento bajo pese a `TFR` ≈ 3); en Australia/NZ, baja fecundidad compensada por inmigración. Advertencia: los países pequeños generan tasas extremas por ruido (ASA: no sobreinterpretar).

### 3.7 Europa y América del Norte — *"Baby boom, ageing, and immigration as the growth engine"*
- **Baby boom** 1946–1964 (más largo en EE. UU., Canadá y Australia) y "baby bust" desde ~1965–1975; la región está bajo reemplazo desde 1973 [V].
- **Segunda transición demográfica** (Lesthaeghe): postergación de la maternidad (`MAC` Italia 28,3 en 1970 → 32,3 en 2023; España 32,5) [V]; fecundidad "lowest-low" en el sur y el este de Europa desde los 90.
- **Shock postsoviético 1990s**: crisis de mortalidad (Rusia −6,2 años de `LEx` entre 1987 y 1994) [V], colapso de la fecundidad y emigración masiva (Bálticos, Bulgaria, Rumanía, Moldavia, Bosnia).
- **Guerras de los Balcanes** (1991–99) y refugiados.
- **Ampliaciones de la UE (2004, 2007)**: emigración Este → Oeste (Lituania `CNMR` −25,5 por mil en 2010) [V].
- **Oleadas de refugiados**: 2015 (Siria/Afganistán/Irak, Alemania +1,18 M) y 2022 (Ucrania: Polonia +968 mil, Alemania +982 mil) [V].
- **Inmigración como motor**: `CNMR` media +2,65 por mil [V]; según WPP-SR, sin inmigración Italia, Alemania y Rusia habrían tocado techo antes, y EE. UU. y Canadá crecerán sobre todo por inmigración. Pico regional proyectado: 2036 [V].
- **Relación esperada**: crecimiento natural ≈ 0 o negativo; **la migración neta decide si la población crece o decrece**; la `LEx` ya alta sigue subiendo lentamente (79,2 en 2023) [V].

### 3.8 Por grupo de ingreso (Banco Mundial; agregados WPP)
**Ingreso alto** — *"Migration keeps them growing"*
- `TFR` 1,47 y edad mediana 40,9 (2023) [V]; bajo reemplazo desde 1976 [V].
- Principal destino de migrantes: `CNMR` media +3,37 por mil (1990–2023) y +3,85 (2010–2023) [V].
- Incluye a los países del Golfo (crecimiento casi solo migratorio), a Europa occidental, Norteamérica, Japón, Corea, Australia.
- Pico de población proyectado: 2045 [V]; con inmigración constante, la población sería ≈ estable hasta 2100 (1.252 M) [V].
- Relación esperada: F baja, M muy baja, **Mig positiva = motor**.

**Ingreso medio alto** — *"Already past the peak (China effect)"*
- Dominado por China (≈ la mitad del grupo): `TFR` 1,48 (2023), la misma que el ingreso alto [V].
- Mayor caída de fecundidad de todos los grupos: 5,32 (1950) → 1,48 (2023) [V].
- Pico de población en 2036 y −28 % hacia 2100 (2.811 M → 2.026 M) [V].
- Incluye a América Latina (México, Brasil, Colombia), Turquía, Tailandia, Sudáfrica, Irán (según año de clasificación).
- Relación esperada: F baja, M baja, Mig ≈ 0 → **envejecimiento rápido sin la "válvula" migratoria**.

**Ingreso medio bajo** — *"Where most future growth happens"*
- India, Nigeria, Pakistán, Bangladés, Egipto, Filipinas, Kenia, etc.; 3.253 M en 2023 → 4.332 M en 2054 [V].
- `TFR` 2,55 (2023), bajaría de 2,1 recién en 2058 [V]; pico ≈ 2089 [V].
- Emigración neta (−1,0 por mil promedio) [V]: coherente con el "migration hump" (los países de ingreso medio emigran más que los de ingreso bajo — hipótesis a contrastar con `CNMR`).
- Relación esperada: M ya baja (`LEx` 69,6), F en descenso, **momentum = motor**.

**Ingreso bajo** — *"High fertility, fastest growth, highest child mortality"*
- `TFR` 4,53, `Q5` 62 por mil, edad mediana 17,9 (2023) [V]; crecimiento 2,73 % [V].
- Muchos países frágiles o en conflicto (Afganistán, Sudán, Sudán del Sur, Somalia, RD Congo, Yemen, Chad, Níger, Malí, Burkina Faso…).
- Población 736 M (2023) → 1.406 M (2054) → 2.152 M (2100) [V].
- Emigración neta **menor** que la del grupo medio bajo en 1990–2023 (−0,87 vs −1,00 por mil) [V]: la pobreza limita la emigración (coherente con Clemens 2014), pero los desplazamientos forzados generan picos.
- Relación esperada: la `LEx` ya subió mucho (31,2 → 64,9 desde 1950) [V], la fecundidad baja despacio → **la etapa 2–3 de la transición clásica**.

---

## 4. Fichas de 41 países emblemáticos

Formato: titular en inglés · hitos con años (quiebres esperables) · cifras WPP **[V]** · **etiquetas cortas EN** listas para anotar gráficas (`año + evento`, ≤ 30 caracteres) · fuentes (si no se repiten de §2).
Cifras clave por país tomadas de WPP2024 Medium (pico = año de máxima población 1950–2100).

### Asia oriental y sudoriental

**4.1 China — *"The famine, the campaigns, the peak"***
- 1959–61 Gran Hambruna: `LEx` 48,8 → 33,4 (1960) y rebote de `TFR` a 7,51 (1963), el máximo de la serie [V].
- 1971–79 "más tarde, más espaciado, menos": `TFR` 6,08 → 2,74 **antes** del hijo único [V] (Whyte et al. 2015).
- 1980–2015 hijo único; 2016 dos hijos (`TFR` 1,77); 2021 tres hijos [V].
- Pico de población en **2021 (1.426 M)**; 1.215 M en 2054 y 633 M en 2100 (−56 %) [V]; `TFR` 1,00 y edad mediana 39,1 en 2023 [V]. India la supera en 2022 según WPP2024 [V].
- Etiquetas: `1960 Great Famine` · `1971 "Later, longer, fewer"` · `One-child policy (1980–2015)` · `2016 Two-child policy` · `2021 Population peak`.

**4.2 Japón — *"The first super-aged society"***
- 1966 *hinoeuma*: `TFR` 2,09 → 1,63 → 2,16 [V]. 1989 "choque del 1,57" (`TFR` 1,55) [V].
- 2009 pico de población (128,2 M) [V]; 2011 terremoto y tsunami de Tōhoku: `LEx` 82,9 → 82,7 (pequeña muesca) [V].
- `LEx` 59,3 (1950) → 84,7 (2023); edad mediana 49,0, la más alta entre los países grandes [V]; 76,8 M en 2100 [V].
- Inmigración pequeña pero creciente (`CNMR` +1,4 por mil en 2023) [V].
- Etiquetas: `1966 Fire Horse year` · `1989 "1.57 shock"` · `2009 Population peak` · `2011 Tōhoku tsunami`.

**4.3 Corea del Sur — *"From 6 children to 0.7 in 60 years"***
- 1950–53 guerra: `LEx` 22,2 (1950) [V]. 1962 programa nacional de PF.
- `TFR` 6,18 (1957, máximo) → 2,10 (1983) → 1,12 (2005) → **0,72 (2023)** [V]; por debajo de 1 desde 2018 (0,95) [V].
- Pico de población 2020 (51,9 M); 21,8 M en 2100 (−58 %) [V]; edad mediana 17,7 (1970) → 44,5 (2023) → 59,9 (2100) [V].
- Pasó de emisor (`CNMR` −3,9 por mil en 1980) a receptor (+5,4 en 2015) [V].
- Etiquetas: `1953 Korean War ends` · `1962 Family planning` · `1983 Below replacement` · `2018 TFR below 1` · `2023 TFR 0.72`.

**4.4 Vietnam — *"War, boat people, Đổi Mới"***
- Guerra: muescas de `LEx` en 1968 (ofensiva del Tet, 52,7) y 1972 (51,9) [V].
- 1975–95 balseros (≈ 800.000 llegaron a otros países): `CNMR` −6,6 por mil (1979) [V].
- 1986 reformas Đổi Mới; política de "uno o dos hijos" (1988) [PV fuente]; `TFR` 3,96 (1986) → 2,03 (2000) [V].
- Pico en 2049 (110,0 M) [V].
- Etiquetas: `1968 Tet Offensive` · `1975 Fall of Saigon` · `1979 Boat-people peak` · `1986 Đổi Mới`.
- Fuente adicional: UNHCR (2000) https://www.unhcr.org/sites/default/files/legacy-pdf/3ebf9bad0.pdf

**4.5 Tailandia — *"Condoms, monks and humour"***
- 1970 política de población; Mechai Viravaidya y PF comunitaria (1974).
- `TFR` 6,42 (1953) → 2,06 (1990) → 1,21 (2023) [V].
- 1991 programa "100 % condón": nuevas infecciones por VIH 5 veces menores entre 1991 y 1995 (WHO/CGD) — `LEx` sin colapso tipo África austral [V: 68,9 en 1990 → 71,2 en 2000].
- Pico de población en **2022 (71,7 M)** [V]; 45,6 M en 2100 [V].
- Etiquetas: `1970 Population policy` · `1991 100% Condom Programme` · `2022 Population peak`.
- Fuente adicional: CGD *Millions Saved* https://www.cgdev.org/sites/default/files/archive/doc/millions/CGD-MillionsSaved_Case2.pdf

**4.6 Indonesia — *"Two children are enough"***
- 1965–66 matanzas anticomunistas (≈ 500.000, rango 200.000–1 M; Cribb, *J. Asian Studies*): `LEx` 49,5 (1964) → 42,8 (1965) [V: caída de 6,7 años en 1965].
- 1970 BKKBN (*Dua Anak Cukup*): `TFR` 5,59 (1966) → 2,50 (2000) → 2,13 (2023) [V].
- 2004 tsunami (Aceh): `LEx` 67,1 → 65,5 [V].
- Pico en 2058 (322,6 M) [V].
- Etiquetas: `1970 BKKBN family planning` · `2004 Aceh tsunami`.

**4.7 Camboya — *"Year Zero"***
- 1975–79 Jemeres Rojos: `LEx` **11,3 (1977)**; población 6,78 M (1974) → 5,09 M (1979) [V].
- Baby boom de recuperación: `TFR` 2,72 (1977) → 6,31 (1985) [V]; `PopGrowthRate` 4,2 % (1990) [V].
- `TFR` 2,58 y `LEx` 70,7 (2023) [V]; WPP fija `CNMR` −1,5 por mil desde 2030 (WPP-M tabla II.3.C).
- Etiquetas: `1975 Khmer Rouge take power` · `1979 Regime falls` · `1980s Recovery baby boom`.

### Asia central y meridional

**4.8 India — *"The world's most populous country"***
- 1952 primer programa nacional de PF del mundo; 1975–77 esterilizaciones forzadas de la Emergencia (sin quiebre visible en `TFR`) [V].
- `TFR` 5,98 (1964, máximo) → **1,98 (2023)**, ya bajo reemplazo [V]; `IMR` 176 (1950) → 22,6 (2023) [V].
- COVID-19: `LEx` 70,8 (2019) → 67,3 (2021) [V].
- Supera a China en **2022** (WPP2024) [V]; pico en 2061 (1.701 M) [V].
- Etiquetas: `1952 Family planning launch` · `1976 Emergency sterilisations` · `2021 COVID-19 Delta wave` · `2022 Overtakes China`.

**4.9 Bangladés — *"A poor country that halved its fertility"***
- 1970 ciclón Bhola; 1971 guerra de liberación (`LEx` 26,5) [V]; 1974 hambruna (`LEx` sin muesca clara) [V].
- 1977 experimento de Matlab; PF comunitaria con trabajadoras de salud a domicilio.
- `TFR` 6,84 (1970) → 4,51 (1990) → 2,16 (2023) [V].
- Emigración laboral al Golfo y Malasia: `CNMR` −7,3 por mil (2010) [V]. Pico en 2071 (226 M) [V].
- Etiquetas: `1970 Bhola cyclone` · `1971 Liberation War` · `1977 Matlab programme`.

**4.10 Irán — *"The fastest fertility fall ever recorded"***
- 1979 revolución; 1980–88 guerra con Irak y pronatalismo (crecimiento ≈ 3,7 %/año) [V].
- 1989 reactivación del programa de PF: `TFR` 6,24 (1985) → **2,00 (2000)** [V].
- 2012+ giro pronatalista y ley de 2021 "Población joven y protección de la familia" (restringe anticonceptivos); `TFR` 1,70 (2023) [V].
- Pico en 2053 (102 M) [V]; WPP-SR lo cita entre los que más crecerán relativamente hasta 2054 por momentum.
- Etiquetas: `1979 Islamic Revolution` · `1980–88 Iran–Iraq War` · `1989 Family planning revived` · `2021 Pronatalist law`.
- Fuentes adicionales: HRW (2021) https://www.hrw.org/news/2021/11/10/iran-population-law-violates-womens-rights ; PMC (2023) https://pmc.ncbi.nlm.nih.gov/articles/PMC10578100/

**4.11 Afganistán — *"Forty years of war and exile"***
- 1979–89 guerra soviética: población 13,7 M → 11,4 M (1985), `NetMigrations` −1,17 M (1980) [V].
- 1992–96 guerra civil; 2001 intervención de EE. UU.; retornos masivos 2002–05 (`CNMR` +10,9 por mil en 2003) [V].
- Ago-2021 talibanes: `NetMigrations` −549 mil (2021), −647 mil (2022) [V].
- `Q5` 414 (1950) → 56 (2023); `TFR` 7,77 (1995) → 4,84 (2023) [V]; edad mediana 16,9 [V].
- Etiquetas: `1979 Soviet invasion` · `1989 Soviet withdrawal` · `2002 Refugee returns` · `2021 Taliban takeover`.

### Norte de África y Asia occidental

**4.12 Emiratos Árabes Unidos — *"Built by migrants"***
- Población 74.500 (1950) → 10,64 M (2023): ×143 [V]. `CNMR` máx. +166 por mil (1969) [V].
- Auges: 1970s (petróleo), 2006–08 (Dubái; `NetMigrations` +722 mil en 2007), 2021–23 (pos-COVID, +422 mil en 2021) [V]. Caída en 2019 (−125 mil) [V].
- ≈ 88 % de residentes no nacionales (GLMM); razón de sexos 231 (1970) → 178 (2023) hombres por 100 mujeres [V].
- `TFR` 6,53 (1968) → 1,20 (2023) [V].
- Etiquetas: `1971 Federation` · `1973 Oil boom` · `2007 Dubai boom` · `2021 Post-COVID rebound`.

**4.13 Catar — *"Three men for every woman"***
- Población 24.000 (1950) → 2,98 M (2023) [V]. Crecimiento **22,1 % en 2006** [V] (construcción; Mundial 2022 adjudicado en 2010).
- Razón de sexos 320 hombres por 100 mujeres (2008) [V].
- 2020 COVID: `NetMigrations` −50 mil [V].
- WPP-M impone a Catar un tope de migración acumulada (70 por mil) y +0,5 por mil desde 2030.
- Etiquetas: `2006 Construction boom` · `2010 World Cup awarded` · `2022 FIFA World Cup`.

**4.14 Arabia Saudí — *"Oil boom and the 2017 expat levy"***
- `TFR` 7,67 (1964) → 2,28 (2023) [V]; población 1,7 M (1950) → 33,3 M (2023) [V].
- Inmigración sostenida 1975–2015 (`NetMigrations` ≈ +500 mil/año en 2000–2010) [V].
- Jul-2017 tasa a dependientes: `NetMigrations` −921 mil (2017) y −989 mil (2018) [V].
- Etiquetas: `1973 Oil boom` · `1990 Gulf War` · `2017 Expat levy` · `2016 Vision 2030`.

**4.15 Kuwait (complemento útil)** — `1990 Iraqi invasion`: población −71 % en tasa anual (2,22 M → 1,35 M) [V]; `2020 COVID expat exodus` (−168 mil) [V].

**4.16 Siria — *"Half the country displaced"***
- `TFR` 7,63 (1955) → 2,71 (2023) [V].
- 2011 inicio de la guerra; **2013 `CNMR` −96 por mil** (`NetMigrations` −2,08 M) [V]; población 22,9 M (2011) → 19,2 M (2016) [V]; `LEx` 73,5 (2010) → 63,3 (2015) [V].
- 2018–23 WPP registra retornos (`NetMigrations` +500 mil/año; +757 mil en 2023) [V] — **verificar contra UNHCR** (el retorno masivo documentado es posterior a dic-2024) [PV].
- Etiquetas: `2011 Civil war begins` · `2013 Refugee exodus peak` · `2015 Exodus to Europe`.

**4.17 Líbano — *"Refugees per capita world record"***
- 1975–90 guerra civil: `LEx` 36,4 (1976); 1982 invasión israelí: `LEx` 47,2 [V]. WPP pone `CNMR` = 0 en 1975–78 (sin datos; artefacto) [V].
- 2012–14 llegada de sirios: `CNMR` +128 por mil (2013); población 5,0 M (2010) → 6,3 M (2014) [V]; luego salidas 2015–19 (≈ −40 por mil/año) [V].
- 2019 colapso financiero; 2020 explosión del puerto de Beirut; COVID (`LEx` 78,2 → 73,7 en 2021) [V].
- Etiquetas: `1975 Civil war` · `1982 Israeli invasion` · `2013 Syrian refugee influx` · `2020 Beirut port blast`.

**4.18 Turquía — *"From emigrant to the world's largest refugee host"***
- 1961 acuerdo de trabajadores con Alemania: `CNMR` negativa en los 60–2000s (−4,1 por mil en 1970) [V].
- `TFR` 6,48 (1953) → 2,08 (2010) → 1,62 (2023) [V].
- 2014–15 llegada de sirios: `NetMigrations` +1,03 M (2014) y +1,06 M (2015) [V]; ≈ 2,9 M de sirios registrados (UNHCR).
- 6-feb-2023 terremoto de Kahramanmaraş (≈ 50.000 muertes en Türkiye): `LEx` 77,6 (2022) → 77,2 (2023) [V].
- Pico en 2047 (91,4 M) [V].
- Etiquetas: `1961 Guest-worker deal` · `2015 Syrian refugees` · `2023 Kahramanmaraş quake`.
- Fuente adicional: Britannica https://www.britannica.com/event/2023-Turkey-Syria-earthquake

**4.19 Egipto — *"The fertility decline that reversed"***
- 1970s–80s emigración al Golfo y retorno en 1990 (`NetMigrations` +407 mil en 1990, guerra del Golfo) [V].
- `TFR` 7,09 (1953) → 3,24 (2008) → **3,50 (2015)** → 2,75 (2023) [V].
- 2011 revolución (asociada al repunte de fecundidad, Radovich et al. 2018).
- 2023: llegada de sudaneses (`NetMigrations` +305 mil) [V].
- Etiquetas: `1990 Gulf War returnees` · `2011 Revolution` · `2014 Fertility rebound` · `2023 Sudanese refugees`.

### África subsahariana

**4.20 Nigeria — *"Africa's giant"***
- 1967–70 guerra de Biafra (muesca pequeña de `LEx` en 1967: 37,5) [V; WPP probablemente la subestima, PV].
- `TFR` 6,92 (1978) → 4,48 (2023) [V] — **verificar**: la DHS 2018 dio 5,3; WPP2024 incorpora encuestas más recientes [PV].
- `LEx` 54,5 (2023): **la más baja del mundo según WPP2024** (por debajo de Chad 55,1 y Lesoto 57,4); `IMR` 69,5 [V].
- 227,9 M (2023) → 376 M (2054) → 477 M (2100) [V].
- Etiquetas: `1967–70 Biafra War` · `High fertility persists`.

**4.21 Níger — *"World's highest fertility, 1995–2018"***
- `TFR` ≥ 7,5 durante 60 años (máx. 7,93 en 1985; 7,53 en 2012) [V]; fue la más alta del mundo de 1995 a 2018; desde 2019 la supera Somalia (6,13 en 2023, seguida de Chad 6,12 y Níger 6,06) [V]. DHS 2012: 7,6; 79 % de mujeres casadas antes de los 18.
- `Q5` 343 (1975) → 116 (2023) [V]: la mortalidad bajó, la fecundidad casi no.
- 2,6 M (1950) → 26,2 M (2023) → 52,5 M (2050) → 90,8 M (2100) [V]; edad mediana 15,2 [V].
- Etiquetas: `TFR ≈ 7.5 for 60 years` · `Highest TFR 1995–2018` · `Child marriage 79% (DHS 2012)`.

**4.22 Etiopía — *"Famine to health-extension success"***
- 1983–85 hambruna: `LEx` 43,4 → 36,3 (1983); `Q5` 312 [V].
- 2003 Programa de Extensión Sanitaria (> 30.000 trabajadoras): `Q5` 141 (2000) → 45 (2023) [V].
- `TFR` 7,36 (1984) → 3,99 (2023) [V]; 2020–22 guerra de Tigray: `LEx` 66,0 → 65,3 (2021) [V].
- 128,7 M (2023) → 240 M (2054) [V].
- Etiquetas: `1984 Famine` · `2003 Health Extension Programme` · `2020–22 Tigray war`.
- Fuente adicional: Assefa et al. (2019) *Globalization and Health* https://link.springer.com/article/10.1186/s12992-019-0470-1

**4.23 Kenia — *"Early decline, then a stall"***
- `TFR` 7,96 (1966, de las más altas jamás medidas) → 5,14 (2000) → 3,21 (2023) [V]; estancamiento DHS 1998–2003 (4,7 → 4,9).
- VIH: `LEx` 60,9 (1985) → 55,5 (1997) y recuperación a 63,6 (2023) [V].
- Etiquetas: `1967 First African FP policy` [PV] · `1998–2003 Fertility stall` · `2003 Free ART` [PV].

**4.24 Ruanda — *"Genocide, then one of the fastest fertility declines"***
- 1994 genocidio: `LEx` 12,2; `CNMR` −306 por mil (1994) y +204 (1996) [V].
- 2005–2010: DHS `TFR` 6,1 → 4,6, una de las caídas más rápidas de la historia DHS; prevalencia anticonceptiva 17 % → 52 % [WPP suaviza: 5,50 → 4,52] [V].
- `LEx` 42,9 (1993) → 67,8 (2023) [V].
- Etiquetas: `1994 Genocide` · `1996 Refugee return` · `2005–10 Fertility plunge`.
- Fuente adicional: Rutayisire et al. (2014) https://onlinelibrary.wiley.com/doi/10.1155/2014/486210

**4.25 Sudáfrica — *"Denial, then the world's largest ART programme"***
- 1994 fin del apartheid; inmigración regional (Zimbabue, Mozambique): `CNMR` +11,3 por mil (2015) [V].
- VIH: `LEx` 63,0 (1989) → 53,9 (2005) [V]. Negacionismo de 2000–2005: > 330.000 vidas perdidas por no implementar TAR a tiempo (Chigwedere et al. 2008).
- 1-abr-2004 inicio del TAR público: `LEx` 66,1 (2023) [V].
- COVID: `LEx` 66,1 (2019) → 62,0 (2021) [V].
- Etiquetas: `1994 End of apartheid` · `2000–05 AIDS denialism` · `2004 Public ART rollout`.
- Fuente adicional: Chigwedere et al. (2008) *JAIDS* https://pubmed.ncbi.nlm.nih.gov/19186354/

**4.26 Botsuana — *"Lost a decade of life expectancy—and won it back"***
- `LEx` 63,7 (1984) → 52,2 (2001) → 69,2 (2023) [V] (**caída ≈ 11,5 años, no 20**; para "−18 años" usar Esuatini).
- Ene-2002 programa *Masa* (primer TAR público a gran escala en África).
- `IMR` 37,8 (1988) → 53,7 (2000) → 28,4 (2023) [V]; `TFR` 6,62 (1958) → 2,73 (2023) [V].
- Etiquetas: `1985 HIV spreads` · `2002 Masa ART programme` · `2023 Above pre-AIDS peak`.

**4.27 Zimbabue — *"HIV and economic collapse"***
- `LEx` 61,0 (1986) → 44,5 (2001) [V]; recuperación a 62,8 (2023) [V].
- 2000+ reforma agraria y colapso; 2008 hiperinflación y cólera (98.569 casos, 4.369 muertes); `CNMR` −13,9 por mil (2000) [V].
- `TFR` 7,23 (1962) → 3,72 (2023) [V].
- Etiquetas: `1990s HIV crisis` · `2000 Economic collapse` · `2008 Hyperinflation & cholera`.

**4.28 Esuatini y Lesoto (complemento)** — la mayor caída de `LEx` por VIH: Esuatini **61,9 (1988) → 43,9 (2004)**, Lesoto 59,6 (1988) → 43,2 (2006) [V]; prevalencia adulta femenina 35,2 % (Esuatini) y 24,3 % (Lesoto) en 2022 (WPP-M tabla I.2). Etiqueta: `−18 years of life expectancy`.

### Europa y América del Norte

**4.29 Rusia — *"A peacetime mortality crisis"***
- 1985–87 campaña antialcohol (`LEx` 68,3 → 70,1) [V]; 1991 fin de la URSS y pico de población (149,4 M) [V].
- 1992–94 crisis: `LEx` 63,8 (1994); 1998 crisis financiera; `TFR` 1,19 (2000) [V].
- 2007 "capital maternal" (pronatalismo): `TFR` 1,30 (2005) → 1,59 (2010) [V] [PV fuente].
- COVID: `LEx` 73,1 (2019) → 69,8 (2021) [V]; 2022 guerra y emigración (`CNMR` en WPP +5,3 por mil en 2022, incluye llegadas desde Ucrania) [V, a interpretar con cautela].
- Etiquetas: `1985 Anti-alcohol campaign` · `1991 USSR collapse` · `1994 Mortality crisis` · `2007 Maternity capital` · `2021 COVID-19`.

**4.30 Ucrania — *"The steepest decline in Europe"***
- Pico de población en 1993 (52,4 M) [V]; `TFR` 1,11 (2000) y 0,90 (2022) [V].
- 2014 anexión de Crimea y guerra en el Donbás [PV huella].
- 24-feb-2022: `NetMigrations` −5,70 M y crecimiento −14,8 % [V]; WPP asume retorno de 2/3 (+1,15 M en 2024, +1,70 M en 2025) [V].
- 15,2 M en 2100 (−71 % desde el pico) [V].
- Etiquetas: `1991 Independence` · `1993 Population peak` · `2014 Crimea & Donbas` · `2022 Full-scale invasion`.

**4.31 Alemania — *"Immigration country despite itself"***
- 1961–73 *Gastarbeiter*; 1964 máximo de `TFR` (2,53) [V]; `TFR` entre 1,25 y 1,59 desde 1975 [V].
- 1990 reunificación: `TFR` 1,25 (1994) por el colapso en el Este (0,77) [V].
- 2015: `NetMigrations` +1,18 M; 2022: +0,98 M (Ucrania) [V].
- Edad mediana 45,1 (2023) [V]; WPP-SR: el pico habría llegado antes sin inmigración.
- Etiquetas: `1961 Turkish guest workers` · `1990 Reunification` · `2015 Refugee arrivals` · `2022 Ukrainian refugees`.

**4.32 Italia — *"Fewer births than ever, saved by migrants"***
- Emigración hasta los 60 (`CNMR` −2,8 por mil en 1960) [V]; receptor desde los 80 y sobre todo 2000s (+495 mil en 2007) [V].
- `TFR` 2,66 (1964) → 1,19 (1995) → 1,20 (2023) [V].
- Pico 2014 (60,7 M) → 35,4 M en 2100 [V]; edad mediana 47,5 [V].
- COVID 2020: `LEx` 83,3 → 82,2 [V] (Lombardía, primera ola europea).
- Etiquetas: `1964 Baby-boom peak` · `1995 Lowest-low fertility` · `2014 Population peak` · `2020 COVID first wave`.

**4.33 España — *"From emigrants to Europe's immigration boom"***
- 1960s emigración a Europa (`CNMR` −5,1 por mil en 1960) [V].
- `TFR` 3,00 (1964) → 1,13 (1998) [V]; 2023 INE: 1,12 (WPP: 1,21) [diferencia a explicar].
- 2000–08 auge inmigratorio (+772 mil en 2007); 2012–13 crisis y emigración (−251 mil en 2013) [V].
- Pico en 2023 (47,9 M) [V].
- Etiquetas: `1960s Emigration to Europe` · `2000–08 Immigration boom` · `2013 Crisis emigration`.

**4.34 Bulgaria — *"The fastest-shrinking nation"***
- 1988 pico de población (9,0 M) [V]; 1989 expulsión de ≈ 360.000 turcos (`NetMigrations` −115 mil) [V].
- 1990s transición: `TFR` 1,14 (1998) [V]; emigración tras 2007 (UE).
- 6,8 M (2023) → 5,2 M (2054) → 3,5 M (2100) [V].
- COVID: `LEx` 75,1 (2019) → 71,4 (2021) [V].
- Etiquetas: `1988 Population peak` · `1989 Expulsion of Turks` · `2007 EU accession` · `2021 COVID-19`.

**4.35 Estados Unidos — *"Growth by immigration"***
- 1946–64 baby boom (`TFR` 3,75 en 1958) [V]; 1965 Ley de Inmigración (Hart-Celler) [PV fuente].
- 2014–17 estancamiento de `LEx` (78,9 → 78,7) asociado a "muertes por desesperación" (Case & Deaton 2015, *PNAS* https://www.pnas.org/doi/10.1073/pnas.1518393112) [V].
- COVID: `LEx` 78,9 (2019) → 76,4 (2021) [V].
- `NetMigrations` ≈ +1,3 M/año en WPP, pero la CBO estima 3,3 M en 2023 (§2 #69). WPP-SR: inmigración = motor principal de crecimiento hasta 2054.
- Etiquetas: `1957 Baby-boom peak` · `1965 Immigration Act` · `2015 Deaths of despair` · `2021 COVID-19`.

**4.36 Canadá — *"Fastest-growing G7 country"***
- Baby boom (`TFR` 3,86 en 1959) [V]; 1967 sistema de puntos [PV fuente].
- `TFR` 1,35 (2023) [V]; crecimiento casi solo migratorio.
- 2023: StatCan +3,2 % (máximo desde 1957) vs WPP +1,22 % [V] (discrepancia).
- 53,6 M en 2100 (sigue creciendo) [V].
- Etiquetas: `1959 Baby-boom peak` · `1967 Points system` · `2023 Record growth (+3.2%)`.

### América Latina y el Caribe

**4.37 México — *"The great migration that stopped"***
- `TFR` 6,83 (1964) → 1,91 (2023) [V]; 1974 Ley General de Población (PF) [PV fuente].
- Emigración neta a EE. UU.: −356 mil (2000) → −41 mil (2010) [V]; IRCA 1986, TLCAN 1994, Gran Recesión 2008 (Pew 2012).
- COVID: `LEx` 74,5 (2019) → 69,8 (2021) [V].
- Pico en 2058 (149,9 M) [V]; WPP fija `CNMR` −0,8 por mil desde 2024 (WPP-M tabla II.3.C).
- Etiquetas: `1974 Population law` · `1986 IRCA` · `2008 Net migration ≈ 0` · `2021 COVID-19`.

**4.38 Brasil — *"Telenovelas and a fast fertility fall"***
- `TFR` 6,12 (1950) → 2,25 (2000) → 1,62 (2023) [V]; Globo y las telenovelas (La Ferrara et al. 2012).
- 2015–16 Zika: leve caída de nacimientos (`CBR` 14,7 → 14,1) [V; causalidad no establecida].
- COVID: `LEx` 75,8 (2019) → 73,0 (2021) [V].
- Pico en 2042 (219,3 M) [V].
- Etiquetas: `1965 Globo TV network` · `2016 Zika` · `2021 COVID-19` · `2042 Population peak`.

**4.39 Colombia — *"From conflict to host country"***
- Conflicto armado y desplazamiento interno (máximo hacia 2002) [PV fuente]; `TFR` 6,74 (1959) → 1,65 (2023) [V].
- 24-nov-2016 acuerdo de paz.
- 2016–19 llegada de venezolanos: `NetMigrations` +496 mil (2018) [V]; ≈ 2,8 M venezolanos (R4V, dic-2024).
- COVID: `LEx` 76,8 (2019) → 72,7 (2021) [V]; pico en 2050 (59,4 M) [V]; WPP-SR la cita entre los de mayor aumento relativo hasta 2054.
- Etiquetas: `2016 Peace agreement` · `2018 Venezuelan arrivals peak` · `2021 COVID-19`.

**4.40 Venezuela — *"The largest exodus in Latin American history"***
- Petroestado con inmigración en los 50 (`CNMR` +11,4 por mil en 1950) [V].
- 2014 caída del petróleo, hiperinflación 2017–19.
- Éxodo: `NetMigrations` −817 mil (2017), **−1,36 M (2018)**, −976 mil (2019) [V]; población 30,8 M (2016) → 28,2 M (2022) [V]; ≈ 7,9 M venezolanos fuera (R4V, dic-2024).
- Etiquetas: `2014 Oil price collapse` · `2018 Exodus peak` · `7.9M abroad (2024)`.

**4.41 Cuba — *"First below replacement, now emptying out"***
- 1959 revolución; 1965 Camarioca, 1980 Mariel (≈ 125.000), 1994 balseros (≈ 35.000).
- `TFR` < 2,1 desde 1978 (1,88): con Barbados, el primer país independiente de América Latina y el Caribe bajo reemplazo (antes solo el territorio de Bermudas, 1974) [V].
- 1991–2000 Periodo especial (PIB −35 %; neuropatía epidémica).
- Pico en 2012 (11,3 M) [V]; 2022–23 éxodo (ONEI: −10 %) **no captado por WPP2024** [V].
- Etiquetas: `1959 Revolution` · `1980 Mariel boatlift` · `1994 Rafter crisis` · `2022 Record exodus`.

**4.42 Puerto Rico — *"An island that lost a fifth of its people"***
- 1950s "Gran Migración" a EE. UU. (Operación Manos a la Obra): `CNMR` −21,9 por mil (1955) [V].
- Pico en 2001 (3,8 M) [V]; crisis fiscal (PROMESA 2016) [PV fuente].
- 2017 huracán María: `NetMigrations` −150 mil [V]; 2.975 muertes en exceso (GWU).
- `TFR` **0,93–0,94 (2020–2023)**, de las más bajas del mundo; edad mediana 17,1 (1950) → 45,3 (2023) → 56,4 (2054) [V]; 2,36 M en 2054 [V].
- Etiquetas: `1950s Great Migration` · `2006 Recession` · `2017 Hurricane Maria` · `TFR 0.9`.

**4.43 Haití — *"Earthquake, cholera, emigration"***
- `LEx` 61,7 (2009) → **45,6 (2010)** [V]; oct-2010 epidemia de cólera.
- Emigración estructural (`CNMR` ≈ −3 a −4 por mil desde 1950) [V] a EE. UU., República Dominicana, Chile y Brasil.
- `TFR` 6,25 (1950) → 2,66 (2023); `IMR` 43,4 (2023), la más alta de América [V].
- Etiquetas: `2010 Earthquake` · `2010 Cholera outbreak` · `2021 President assassinated`.

---

## 5. Qué le interesa a la ONU hoy

### 5.1 Los 10 mensajes clave de *WPP2024: Summary of Results* (títulos textuales + cifra ancla)
Fuente: UN DESA (2024), *World Population Prospects 2024: Summary of Results*, "Key messages", pp. VII–XI (extraído de `scratchpad/WPP2024_Summary.txt`). https://population.un.org/wpp/assets/Files/WPP2024_Summary-of-Results.pdf

| # | Mensaje (inglés, textual) | Cifras ancla del propio informe | Indicadores WPP para mostrarlo |
|---|---|---|---|
| 1 | *"The world's population is likely to peak within the current century."* | Pico ≈ **10.300 M a mediados de la década de 2080** (8.200 M en 2024); 10.200 M en 2100; probabilidad de pico en el siglo 80 % (≈ 30 % en las proyecciones de 2013); 700 M menos en 2100 que lo previsto hace una década. | `TPopulation1July` (mundo: 10.289 M en 2084 [V]) |
| 2 | *"One in four people globally live in a country whose population has already peaked in size."* | 63 países (28 % de la población) ya tocaron techo (China, Alemania, Japón, Rusia); caerán 14 % en 30 años; 48 países tocarán techo en 2025–2054 (Brasil, Irán, Türkiye, Vietnam); 126 seguirán creciendo hasta 2054 (India, Indonesia, Nigeria, Pakistán, EE. UU.). | Año del máximo de `TPopulation1July` |
| 3 | *"Women today bear one child fewer, on average, than they did around 1990."* | `TFR` mundial 2,25 (vs 3,31 en 1990); más de la mitad de los países bajo 2,1; casi 1/5 con fecundidad "ultra-baja" < 1,4 (China, Italia, Corea, España). | `TFR` (en 2023: 130 de 237 países < 2,1 y 43 < 1,4 [V]) |
| 4 | *"Early childbearing has harmful effects on young mothers and their children."* | 4,7 M de bebés (3,5 %) de madres < 18 años en 2024; 340.000 de niñas < 15; sin nacimientos de madres < 18, África subsahariana sería 3,8 % menor en 2054. | `Births1519`, `TFR` |
| 5 | *"Following the COVID-19 pandemic, global life expectancy is rising once again."* | `LEx` mundial 73,3 (2024), +8,4 años desde 1995; cayó a 70,9 en 2021 (72,6 en 2019); 77,4 en 2054; en 2023 las muertes < 5 años cayeron por debajo de 5 M por primera vez. | `LEx`, `Q5`, `Under5Deaths` |
| 6 | *"The main driver of global population increase through mid-century will be the momentum created by growth in the past."* | El momentum aporta **79 %** del aumento hasta 2054 (≈ 1.400 M); mujeres 15–49: ≈ 2.000 M (2024) → pico ≈ 2.200 M a fines de 2050. | `MedianAgePop`, estructura por edad, `PopGrowthRate` vs `TFR` |
| 7 | *"Countries with youthful populations and declining fertility have a limited time to benefit economically from an increasing concentration of population in the working ages."* | ≈ 100 países con "ventana" de dividendo demográfico hasta 2054. | `TFR`, `MedianAgePop` (20–35) |
| 8 | *"By 2080, persons aged 65 or older will outnumber children under 18."* | 2.200 M de personas ≥ 65 a fines de 2070; a mediados de 2030 habrá 265 M de ≥ 80, más que bebés < 1 año. | `MedianAgePop`, `LE65`, `LE80` |
| 9 | *"For some populations, immigration will be the main driver of future growth."* | En 50 países la inmigración atenúa el declive; motor principal del crecimiento en 52 países hasta 2054 y 62 hasta 2100 (Australia, Canadá, EE. UU.); en 14 países con fecundidad ultra-baja la emigración será un motor importante de pérdida de población. | `CNMR`, `NetMigrations`, `NatChange` |
| 10 | *"Gender equality and women's empowerment help to counter rapid population growth or decline."* | Barreras legales y de acceso a PF frenan la caída de fecundidad donde es alta; brechas de género en trabajo doméstico y poco apoyo a familias deprimen la fecundidad donde es baja. | `TFR` por región; contexto de políticas |

### 5.2 Objetivos de Desarrollo Sostenible relacionados (Agenda 2030, A/RES/70/1, 2015)
Texto oficial de metas: UN Statistics Division, *SDG indicators list* https://unstats.un.org/sdgs/indicators/indicators-list/

| Meta ODS | Qué dice (resumen fiel) | Indicador WPP que la ilumina | Dato para el guion |
|---|---|---|---|
| **3.1** | Reducir la razón mundial de mortalidad materna a < 70 por 100.000 nacidos vivos para 2030. | No está en WPP (usar contexto: `Births1519`, `TFR`); la ONU la mide con MMEIG. | Rumanía 1966–89 como ejemplo histórico de política que elevó la mortalidad materna (Pop-Eleches 2006). |
| **3.2** | Para 2030, poner fin a las muertes evitables de recién nacidos y menores de 5 años: neonatal ≤ 12 y `Q5` ≤ 25 por 1.000. | `Q5`, `IMR` | Países con `Q5` > 25: **138 (1990) → 70 (2023) → 58 (2030, Medium)**; población que vive en ellos: 76 % → 43 % → 23 % [V; 237 países/áreas]. |
| **3.7** | Para 2030, acceso universal a servicios de salud sexual y reproductiva, incluida la planificación familiar (ind. 3.7.2: tasa de fecundidad adolescente). | `Births1519`, `TFR` | Programas de PF de §2 (#5, #6, #9, #10, #18, #29). |
| **5.6** | Acceso universal a la salud sexual y reproductiva y a los derechos reproductivos según la CIPD y Beijing. | `TFR` (contexto) | Irán 2021 y Rumanía 1966 como contraejemplos de restricciones (HRW 2021; Pop-Eleches 2006). |
| **10.7** | Facilitar la migración y movilidad ordenadas, seguras, regulares y responsables mediante políticas migratorias planificadas y bien gestionadas. | `NetMigrations`, `CNMR` | Golfo, Venezuela, Siria, Ucrania (§2). |
| **17.18** | Aumentar la disponibilidad de datos oportunos, fiables y desglosados (ingreso, sexo, edad, raza, etnia, estatus migratorio, discapacidad, ubicación). | Calidad de todas las series | Discrepancias WPP vs. fuentes nacionales en migración (Cuba, Canadá, EE. UU., Polonia) → argumento ético y recomendación. |

### 5.3 Marcos internacionales que la ONU usa como referencia
- **CIPD, El Cairo 1994**: 179 gobiernos adoptaron el Programa de Acción que pasó de "metas demográficas" a **derechos y salud reproductiva**; "population was not about numbers, but about people" (UNFPA). **CIPD+30 (2024)**: revisión mundial en la 57.ª Comisión de Población y Desarrollo (29-abr a 3-may-2024) con declaración política por consenso. https://www.unfpa.org/icpd ; https://www.unfpa.org/publications/international-conference-population-and-development-programme-action
- **Pacto Mundial para una Migración Segura, Ordenada y Regular (GCM)**: adoptado en Marrakech el 10-dic-2018 y respaldado por la Asamblea General (res. 73/195, 19-dic-2018); 23 objetivos; el **objetivo 1** pide "recopilar y utilizar datos exactos y desglosados". https://www.iom.int/resources/global-compact-safe-orderly-and-regular-migration-res-73-195
- **IOM, World Migration Report 2024**: 281 M de migrantes internacionales en 2020 (3,6 % de la población mundial); remesas: 128.000 M USD (2000) → 831.000 M USD (2022). https://worldmigrationreport.iom.int/news/world-migration-report-2024-reveals-latest-global-trends-and-challenges-human-mobility
- **Día de los 8.000 millones** (15-nov-2022): 12 años para pasar de 7.000 a 8.000 M; ≈ 15 años para llegar a 9.000 M (2037). https://www.un.org/en/dayof8billion
- **Dividendo demográfico en África**: tema de la Unión Africana 2017 y hoja de ruta con cuatro pilares (empleo, educación, salud, derechos/gobernanza) (https://library.au.int/au-roadmap-harnessing-demographic-dividend-through-investments-youth).

### 5.4 Debates actuales (cómo los enmarca la ONU) — para la diapositiva de recomendaciones
1. **Envejecimiento y "ultra-baja" fecundidad**: la ONU advierte que en 24 países con fecundidad ultra-baja y población ya en declive, volver a 2,1 en 30 años es "highly unlikely" (probabilidad 0,1 %) y que las políticas pronatalistas pierden efecto porque se reduce el número de mujeres en edad fértil (WPP-SR). Recomienda conciliación trabajo-familia, cuidado infantil, vivienda y reparto igualitario del cuidado, **no** coerción.
2. **Pico poblacional (~2084)**: el pico mundial llega antes y más bajo que lo previsto, sobre todo por la caída de la fecundidad en China (WPP-SR).
3. **Migración como motor del crecimiento en países de ingreso alto** y como factor de pérdida en países de emigración con fecundidad ultra-baja (Bálticos, Balcanes, Caribe). La ONU sugiere que en esos países **crear trabajo decente y promover el retorno** podría frenar más el declive a corto plazo que las políticas pronatalistas (WPP-SR, mensaje 9).
4. **Dividendo demográfico en África y Asia meridional**: la ventana es temporal; requiere inversiones en educación (sobre todo de niñas), salud, empleo e instituciones (WPP-SR, mensaje 7).
5. **Fecundidad adolescente y matrimonio infantil** (Níger, Chad, RCA): retrasar la edad al primer hijo mejora la salud y la educación y frena el crecimiento (WPP-SR, mensaje 4).
6. **Calidad y oportunidad de los datos** (ODS 17.18; GCM objetivo 1): la propia ONU reconoce que la migración neta se estima a menudo como residuo censal y que las cifras de refugiados de UNHCR llegaban solo hasta mediados de 2023 cuando se preparó WPP2024 (WPP-M, notas 46–47).

---

## 6. Doce historias visuales candidatas (datos + historia)

Cada historia indica: **indicador(es)** · **qué anotar** · **por qué sorprendería al jurado** · **riesgo/advertencia ética**. Todas las cifras están **[V]** en WPP2024 Medium salvo indicación.

**H1. "Southern Africa lost up to 18 years of life expectancy to HIV—and won them back with ART."**
- Indicador: `LEx` 1980–2023 para Esuatini, Lesoto, Zimbabue, Botsuana, Sudáfrica (línea; resaltar Esuatini).
- Anotar: `1988 peak 61.9` · `2004 trough 43.9 (−18 y)` · `2002 Botswana Masa ART` · `2004 South Africa public ART` · `2023: 64.1`. Dato de apoyo: `IMR` de Esuatini 55,9 (1988) → 81,7 (2004) → 37,6 (2023) [V].
- Sorpresa: es la mayor reversión de `LEx` en tiempos de paz y la recuperación es casi igual de rápida.
- Ética: Botsuana cayó ≈ 11,5 años, **no 20**; no atribuir toda la recuperación al TAR (también PTMI, prevención, mejoras de datos). La serie WPP para estos 23 países es modelada (WPP-M tabla I.2).

**H2. "Gulf states: migration, not births, built the population."**
- Indicadores: `TPopulation1July` (índice 1950 = 1, escala log) y `CNMR`; `PopSexRatio` como dato de apoyo.
- Anotar: `1973 Oil boom` · `2006 Qatar +22% in one year` · `2008 Qatar: 320 men per 100 women` · `2017–18 Saudi expat levy (−0.9M/yr)` · `2020 COVID exodus`.
- Sorpresa: EAU ×143 y Catar ×123 desde 1950; la `TFR` de EAU (1,20) es hoy menor que la de Italia o Japón.
- Ética: población "de facto" incluye trabajadores temporales sin derechos de residencia; no confundir crecimiento poblacional con crecimiento de la población nacional.

**H3. "South Korea: from 6 children to 0.7 in 60 years."**
- Indicador: `TFR` 1950–2023 + proyección a 2100 con banda (usar OtherVariants o PIs si están disponibles); `MedianAgePop`.
- Anotar: `1953 Korean War ends` · `1962 Family planning` · `1983 Below 2.1` · `2018 Below 1` · `2023 0.72` · `2100 pop 21.8M (−58%)`.
- Sorpresa: el programa que buscaba bajar la fecundidad "funcionó demasiado" (PRB); el país pierde más de la mitad de su población en la proyección.
- Ética: la proyección Medium asume recuperación a 1,30 en 2100; mostrar incertidumbre.

**H4. "History's deadliest events are visible from space—in the world's life-expectancy curve."**
- Indicador: `LEx` mundial 1950–2023 (una sola línea) + pequeñas múltiplos de China 1960, Camboya 1977, Ruanda 1994, Haití 2010, COVID 2021.
- Anotar: `1960 Great Chinese Famine (world −3.8 y)` · `2021 COVID-19 (−1.7 y)`.
- Sorpresa: una hambruna en un solo país mueve el promedio mundial más que la COVID-19.
- Ética: `LEx` de periodo en años de crisis no es "la edad a la que muere la gente"; explicarlo en una frase.

**H5. "China's fertility fell before the one-child policy."**
- Indicador: `TFR` China 1950–2023 con sombreado 1980–2015.
- Anotar: `1963 rebound 7.5` · `1971 "Later, longer, fewer"` · `1979: 2.74` · `One-child policy (1980–2015)` · `2023: 1.00`.
- Sorpresa: ≈ ¾ de la caída desde 1970 ocurrió antes de 1980 (Whyte et al. 2015) — rompe un mito muy extendido.
- Ética: no afirmar que la política "no tuvo efecto"; afirmar solo lo que muestra la serie y la literatura.

**H6. "Peacetime collapse: Russia's men lost six years in five."**
- Indicador: `LEx` Rusia, Ucrania, Letonia, Estonia 1980–2023 (+ `LExMale` si se usa).
- Anotar: `1985–87 Anti-alcohol campaign` · `1991 USSR collapse` · `1994 trough` · `2021 COVID-19`.
- Sorpresa: la mayor caída de `LEx` registrada sin guerra, hambruna ni epidemia (Brainerd & Cutler 2005).
- Ética: causas múltiples (alcohol, estrés, sistema de salud); no simplificar a una sola.

**H7. "Venezuela: a quarter-century of growth erased in five years of exodus."**
- Indicadores: `NetMigrations` Venezuela (barras negativas) y receptores (Colombia, Perú, Chile, Ecuador; barras positivas) 2010–2023.
- Anotar: `2014 Oil price collapse` · `2018 −1.36M` · `Colombia +496k` · `7.9M abroad (R4V 2024)`.
- Sorpresa: espejo perfecto emisor/receptores; Colombia pasa de emisor a receptor.
- Ética: WPP es residual y suavizado; citar R4V como fuente de stocks; evitar lenguaje de "invasión".

**H8. "Ukraine 2022: the UN projects that two-thirds of refugees return."**
- Indicadores: `TPopulation1July` y `NetMigrations` Ucrania 2015–2030 con la proyección resaltada.
- Anotar: `2022 −5.7M` · `UN assumption: +1.15M (2024), +1.70M (2025)` · `2100: 15.2M`.
- Sorpresa: muestra que la proyección "Medium" contiene **supuestos políticos explícitos** (WPP-M tabla II.3.B), ideal para la diapositiva de ética/incertidumbre.
- Ética: presentarlo como supuesto, no como predicción; la guerra seguía en 2024.

**H9. "Iran: the fastest fertility decline ever recorded."**
- Indicador: `TFR` Irán vs. Corea, China, Bangladés (alineadas por año en que `TFR` = 6).
- Anotar: `1979 Revolution` · `1980–88 War pronatalism` · `1989 Family planning revived` · `2000: 2.0` · `2021 Pronatalist law`.
- Sorpresa: de 6,2 a 2,0 en 15 años, en una república islámica y con programa voluntario.
- Ética: la caída empezó antes del programa (Abbasi-Shavazi et al. 2009); no atribuir causalidad única.

**H10. "COVID-19 hit Latin America hardest."**
- Indicador: cambio de `LEx` 2019→2021 por país (dot plot ordenado) y por región.
- Anotar: `Bolivia −6.4` · `Paraguay −5.6` · `Ecuador −5.3` · `Mexico −4.8` · `Peru −4.7`; región ALC −3,4 vs mundo −1,7.
- Sorpresa: 147 de 161 países (> 1 M hab.) ya habían recuperado su nivel de 2019 en 2023, pero ALC perdió más que Europa.
- Ética: los datos de exceso de mortalidad tienen incertidumbre alta en países sin registro civil completo; Armenia combina COVID y guerra de 2020.

**H11. "Puerto Rico & Bulgaria: shrinking without war."**
- Indicadores: `TPopulation1July` índice (pico = 100), `TFR`, `CNMR`, `MedianAgePop`.
- Anotar PR: `2001 peak` · `2017 Hurricane Maria −150k` · `TFR 0.93` · `2054: 2.36M`. Bulgaria: `1988 peak 9.0M` · `1989 Expulsion of Turks` · `2007 EU accession` · `2100: 3.5M`.
- Sorpresa: WPP-SR coloca a Puerto Rico entre los lugares con mayor reducción relativa hacia 2054 (junto con Albania, Bosnia, Lituania, Moldavia); baja fecundidad + emigración.
- Ética: PR es territorio de EE. UU. (no Estado soberano); verificar subconteo del censo 2020.

**H12. "When the data lag reality: migration is the UN's hardest number."**
- Indicadores: WPP vs. fuentes nacionales para 2022–2023: Cuba (`TPopulation1July` 11,02 M vs ONEI 10,06 M), Canadá (crecimiento 1,22 % vs 3,2 % StatCan), EE. UU. (`NetMigrations` 1,32 M vs 3,3 M CBO).
- Anotar: cita textual de WPP-M: "*Any long-range assumption regarding future trends in international migration is virtually guaranteed to prove incorrect.*"
- Sorpresa: el jurado de un premio de ética valora que mostremos los límites de nuestros propios datos.
- Ética: es el núcleo de la diapositiva de ética (ASA principios B y C); no presentarlo como "error de la ONU" sino como incertidumbre declarada.

**Las 5 más potentes para el vídeo** (impacto visual × solidez de la evidencia × conexión con las preguntas P7/P8 del DataQuest): **H1** (VIH/TAR), **H2** (Golfo), **H3** (Corea), **H8 + H12** (incertidumbre migratoria; diapositiva de ética) y **H4** (eventos visibles en la curva mundial). H5 (China antes del hijo único) es la mejor "rompe-mitos" si sobra tiempo.

---

## Anexo A. Prueba inversa: las 45 mayores caídas anuales de `LEx` en WPP2024 (1950–2023) y su explicación histórica

Método (exploratorio): diferencia anual de `LEx` por país/área con población máxima > 500.000; se listan las 45 caídas más grandes. Sirve para **(1)** comprobar que los grandes quiebres de la serie corresponden a hechos reales y **(2)** detectar artefactos. "Coincide" ≠ "causa": se reporta la coincidencia temporal con un evento documentado.

| # | País/área | Año | `LEx` | Δ anual | Evento que coincide | Fuente / estado |
|---|---|---|---|---|---|---|
| 1 | Rep. Centroafricana | 2009 | 14,7 | −35,2 | **Sin evento conocido de esa magnitud** (`CDR` 72 por mil ⇒ ≈ 300.000 muertes) | **Posible artefacto WPP** — no usar sin consultar a UN DESA |
| 2 | Ruanda | 1994 | 12,2 | −30,8 | Genocidio contra los tutsis | §2 #39 |
| 3 | Camboya | 1975 | 12,8 | −26,5 | Jemeres Rojos | §2 #14 |
| 4 | Somalia | 1991 | 25,4 | −21,5 | Guerra civil y hambruna 1991–92 | §2 #37 |
| 5 | Rep. Centroafricana | 2022 | 18,8 | −21,5 | Conflicto armado continuo, pero magnitud implausible | **Posible artefacto** |
| 6 | Líbano | 1976 | 36,4 | −21,3 | Guerra civil (1975–76) | §2 #15 |
| 7 | Rep. Centroafricana | 2019 | 31,5 | −20,8 | Idem | **Posible artefacto** |
| 8 | Bosnia y Herzegovina | 1992 | 52,0 | −19,8 | Guerra de Bosnia | §2 #38 |
| 9 | Burundi | 1972 | 25,8 | −17,4 | *Ikiza*: matanzas de hutus (≈ 100.000–300.000) | EBSCO Research Starters https://www.ebsco.com/research-starters/history/ikiza-or-burundi-killings-1972 |
| 10 | Somalia | 2011 | 32,5 | −16,4 | Hambruna 2010–12 (≈ 258.000) | §2 #54 |
| 11 | Bangladés | 1971 | 26,5 | −16,1 | Guerra de liberación | §2 #11 |
| 12 | Haití | 2010 | 45,6 | −16,1 | Terremoto | §2 #53 |
| 13 | Armenia | 1988 | 52,7 | −14,9 | Terremoto de Spitak | §2 #28 |
| 14 | Chipre | 1974 | 54,6 | −14,5 | Golpe e invasión turca (jul–ago 1974) | [PV fuente] |
| 15 | Sudán del Sur | 1998 | 19,0 | −14,0 | Hambruna de Bahr el Ghazal (> 70.000) en la 2.ª guerra civil sudanesa | HRW (1999) https://www.refworld.org/reference/countryrep/hrw/1999/en/91497 |
| 16 | Guinea Ecuatorial | 1969 | 31,0 | −13,9 | Crisis tras la independencia y dictadura de Macías Nguema | [PV fuente] |
| 17 | Sudán del Sur | 1995 | 31,5 | −13,3 | 2.ª guerra civil sudanesa | [PV fuente] |
| 18 | Líbano | 1982 | 47,2 | −13,1 | Invasión israelí y guerra de 1982 | [PV fuente] |
| 19 | Sudán del Sur | 2014 | 45,6 | −12,7 | Guerra civil de Sudán del Sur (dic-2013) | [PV fuente] |
| 20 | Timor-Leste | 1975 | 24,3 | −12,1 | Invasión indonesia (dic-1975) | [PV fuente] |
| 21 | Sudán del Sur | 1987 | 20,7 | −12,1 | 2.ª guerra civil sudanesa; hambruna de 1988 (≈ 250.000) | Concern (2024) https://concernusa.org/news/hunger-as-weapon-of-war-timeline/ |
| 22 | Estado de Palestina | 2023 | 65,2 | −11,5 | Guerra en Gaza (desde 7-oct-2023) | [PV fuente; cifra muy incierta] |
| 23 | Rep. Centroafricana | 2021 | 40,3 | −10,3 | Conflicto + COVID | Revisar |
| 24 | Kosovo | 1999 | 58,3 | −10,3 | Guerra de Kosovo | §2 #41 |
| 25 | Sudán del Sur | 1988 | 11,0 | −9,7 | Hambruna de Bahr el Ghazal 1988 | Concern (2024) |
| 26 | Corea del Norte | 1995 | 60,8 | −9,7 | Hambruna 1994–98 | §2 #40 |
| 27 | Rep. Centroafricana | 2014 | 40,3 | −9,2 | Guerra civil 2013–14 (Séléka/anti-balaka) | [PV fuente] |
| 28 | Sáhara Occidental | 1975 | 36,0 | −9,0 | Marcha Verde y guerra (1975–76) | [PV fuente] |
| 29 | Líbano | 1975 | 57,7 | −8,7 | Inicio de la guerra civil | §2 #15 |
| 30 | China | 1959 | 40,2 | −8,7 | Gran Hambruna (1.er año) | §2 #3 |
| 31 | Perú | 1970 | 47,7 | −8,1 | Terremoto de Áncash (31-may-1970; ≈ 67.000–70.000 muertes) | USGS https://earthquake.usgs.gov/learn/today/index.php?month=5&day=31 |
| 32 | Eritrea | 1983 | 37,2 | −7,7 | Guerra de independencia y hambruna 1983–85 | §2 #24 (contexto) |
| 33 | Camboya | 1970 | 38,6 | −7,3 | Golpe de Lon Nol y guerra civil (1970) | [PV fuente] |
| 34 | Burundi | 1993 | 37,2 | −7,2 | Asesinato del presidente Ndadaye y masacres (oct-1993) | [PV fuente] |
| 35 | Sudán del Sur | 1992 | 21,9 | −7,2 | 2.ª guerra civil | [PV fuente] |
| 36 | Etiopía | 1983 | 36,3 | −7,1 | Hambruna 1983–85 | §2 #24 |
| 37 | Guinea Ecuatorial | 1976 | 30,5 | −6,8 | Dictadura de Macías Nguema | [PV fuente] |
| 38 | China | 1960 | 33,4 | −6,8 | Gran Hambruna (pico) | §2 #3 |
| 39 | Indonesia | 1965 | 42,8 | −6,7 | Matanzas de 1965–66 | Cribb, *J. Asian Studies* https://www.cambridge.org/core/journals/journal-of-asian-studies/article/abs/new-findings-on-the-indonesian-killings-of-196566/A53ACF4B79AD100D81C0324F0834C7EB |
| 40 | Congo | 1997 | 48,6 | −6,7 | Guerra civil de la República del Congo (1997) | [PV fuente] |
| 41 | Armenia | 2020 | 68,9 | −6,3 | COVID-19 + guerra de Nagorno Karabaj (sep–nov 2020) | §2 #62 |
| 42 | Nicaragua | 1972 | 48,0 | −6,3 | Terremoto de Managua (23-dic-1972) | [PV fuente] |
| 43 | Liberia | 1990 | 37,6 | −6,2 | 1.ª guerra civil liberiana (1989–97) | Advocates for Human Rights (cap. 7) https://www.theadvocatesforhumanrights.org/r/3860/chapter_7-liberia_s_first_civil_war_1989-1997.pdf |
| 44 | Eritrea | 1998 | 50,0 | −6,2 | Guerra Etiopía–Eritrea (1998–2000) | [PV fuente] |
| 45 | Siria | 2012 | 66,2 | −6,1 | Guerra civil | §2 #55 |

**Conclusión del anexo**: 41 de las 45 mayores caídas coinciden con eventos documentados (guerras, genocidios, hambrunas, terremotos, COVID). Las 4 de la República Centroafricana (2009, 2019, 2021, 2022) presentan magnitudes no documentadas → **excluir o señalar** en cualquier gráfico o promedio (ASA B: documentar limitaciones de los datos). También sugerimos excluir **Hong Kong 1961–69** de los análisis de migración: `CNMR` +357 (1964) y −359 por mil (1967) son espejos sospechosos de ajuste.

## Anexo B. Valores extremos de migración neta (`CNMR`, por mil; países con > 500.000 hab.)

| Emisión extrema (más negativa) | Año | `CNMR` | `NetMigrations` (miles) | Evento | | Recepción extrema (más positiva) | Año | `CNMR` | Evento |
|---|---|---|---|---|---|---|---|---|---|
| Kuwait | 1990 | −709,9 | −1.196 | Invasión iraquí | | Kuwait | 1991 | +340,9 | Retorno tras la liberación |
| Liberia | 1990 | −320,4 | −713 | Guerra civil | | Catar | 2006 | +209,9 | Auge de la construcción |
| Timor-Leste | 1999 | −315,0 | −263 | Violencia tras el referéndum y deportaciones a Timor Occidental [PV fuente] | | Ruanda | 1996 | +203,9 | Retorno masivo de refugiados |
| Ruanda | 1994 | −305,9 | −2.078 | Genocidio y éxodo | | Omán | 2011 | +160,1 | Expansión del empleo extranjero [PV] |
| Eritrea | 1991 | −171,2 | −329 | Fin de la guerra de independencia [PV] | | EAU | 2007 | +128,4 | Auge de Dubái |
| Afganistán | 1981 | −167,4 | −1.998 | Guerra soviética | | Líbano | 2013 | +127,7 | Refugiados sirios |
| Kosovo | 1998 | −141,8 | −295 | Guerra de Kosovo | | Liberia | 1997 | +116,7 | Retorno al fin de la guerra |
| **Ucrania** | **2022** | **−138,8** | **−5.699** | **Invasión rusa (mayor salida absoluta de la serie)** | | Somalia | 1978–79 | +83 a +107 | Refugiados de la guerra del Ogadén [PV] |
| Burundi | 1993 | −120,5 | −684 | Masacres de 1993 | | Burundi | 1994 | +90,4 | Retorno [PV] |
| Bután | 1992 | −114,1 | −66 | Expulsión de los *lhotshampa* (> 100.000 a Nepal) | | Afganistán | 1992 | +90,2 | Retorno tras la caída del gobierno comunista |
| Bosnia y Herzegovina | 1992 | −103,2 | −437 | Guerra | | | | | |
| Siria | 2013 | −96,1 | −2.081 | Guerra civil | | | | | |
| Libia | 2011 | −88,7 | −563 | Guerra civil y huida de trabajadores migrantes [PV fuente] | | | | | |
| Sudán del Sur | 2016–17 | −60 a −65 | −650 a −670 | Guerra civil | | | | | |

Fuentes adicionales: Bután — US State Dept. (archivo) https://2009-2017.state.gov/j/prm/policyissues/issues/protracted/countries/157400.htm ; resto en §2.

---

## Anexo C. Qué debemos verificar antes de usar cada dato (checklist para QA-stats)

| Prioridad | Dato / afirmación | Por qué verificar | Cómo |
|---|---|---|---|
| Alta | Botsuana "−20 años" (ejemplo del encargo) | WPP2024 da **−11,5** (63,7 → 52,2). La caída de ~18 años es de **Esuatini** (61,9 → 43,9) y Lesoto/Zimbabue ≈ −16. | Usar Esuatini o Lesoto para la frase de "casi 20 años". |
| Alta | República Centroafricana 2009, 2019, 2021, 2022 | `LEx` 14,7 / 31,5 / 40,3 / 18,8 sin evento que lo explique. | Excluir de gráficos y comprobar si afecta agregados (África Central, ingreso bajo). |
| Alta | Hong Kong 1961–69 y China 1964/1991 (`NetMigrations`) | Saltos espejo o aislados (ajustes censales). | No anotar como migración real. |
| Alta | Cuba 2022–23, Canadá 2023, EE. UU. 2023, Polonia 2004–07 | WPP2024 difiere mucho de fuentes nacionales (ONEI, StatCan, CBO, GUS). | Mostrar como ejemplo de incertidumbre, citando ambas fuentes. |
| Alta | Ucrania y Siria 2023–2026 | Retornos proyectados (2/3 de refugiados) son **supuestos** de la ONU (WPP-M tabla II.3.B). Siria: WPP ya registra retornos 2018–23 que conviene contrastar con UNHCR. | Rotular "UN assumption". |
| Media | Líbano `CNMR` = 0 en 1975–78 | Ausencia de estimación en guerra (artefacto). | No interpretar como "sin emigración". |
| Media | España `TFR` 2023: WPP 1,21 vs INE 1,12; Japón 1966: WPP 1,63 vs oficial 1,58 | WPP suaviza o usa otra base. | Si se cita en pantalla, usar WPP y nota "UN estimate". |
| Media | Nigeria `TFR` 2023 = 4,48 (WPP) vs DHS 2018 = 5,3 | Gran revisión a la baja; confirmar con la DHS 2023–24. | Citar como estimación WPP. |
| Media | India supera a China en **2022** (WPP2024) vs "abril de 2023" (comunicado UNFPA basado en WPP2022) | Diferentes revisiones. | Decir "around 2022–2023". |
| Media | Agregados por ingreso | WPP usa la clasificación BM de su fecha de preparación; nuestro repo usa FY2027. | Declarar cuál se usa en cada gráfico. |
| Media | Cifras de muertes por eventos (Camboya, Etiopía, Haití, Corea del Norte, Darfur, Líbano) | Rangos amplios y disputados. | Presentar siempre como rango "≈". |
| Baja | "1,57 shock" (Japón 1989), Hart-Celler 1965, sistema de puntos de Canadá 1967, Ley de Población de México 1974, PROMESA 2016, política vietnamita de 1988 | Fuentes secundarias o pendientes (marcadas [PV]). | Buscar fuente oficial si van a pantalla. |
| Baja | Remesas en Asia central (Tayikistán) | Cifra no verificada. | Consultar KNOMAD/Banco Mundial. |

## Anexo D. Frases cortas listas para el guion (EN, ≤ 15 palabras) y su respaldo

| Frase para el vídeo | Respaldo (sección) |
|---|---|
| "First children stop dying; a generation later, families get smaller." | §1, §2 #23, tabla §3 |
| "One famine in China dented the whole world's life expectancy." | §2 #3, H4 |
| "Eswatini lost eighteen years of life expectancy to HIV—and regained most of them." | §2 #25–26, H1 |
| "In the Gulf, migrants—not babies—built the population." | §2 #13, #49, H2 |
| "South Korea went from six children per woman to fewer than one." | §2 #70, H3 |
| "China's fertility had already halved before the one-child policy began." | §2 #12, H5 |
| "Russia lost six years of life expectancy in peacetime." | §2 #34, H6 |
| "Venezuela's exodus turned Colombia from a sending to a receiving country." | §2 #58, H7 |
| "COVID-19 erased two years of global gains; Latin America lost more than three." | §2 #62, H10 |
| "In high-income countries, migration now decides whether populations grow or shrink." | §3.7–3.8, §5.1 msg 9 |
| "The UN itself calls migration its hardest number to project." | §1 (WPP-M), H12 |
| "World population is projected to peak around 2084, at about 10.3 billion." | §5.1 msg 1 |

## Anexo E. Cómo reproducir las cifras marcadas [V] (R, mismo archivo del repositorio)

```r
# Requiere el archivo WPP2024 Medium en la carpeta padre del repo (ver data/raw/README.md)
library(dplyr); library(readr)
wpp <- read_csv("../WPP2024_Demographic_Indicators_Medium_csv.gz", show_col_types = FALSE)

# 1) Valores puntuales (ej.: Esuatini, pico y valle de LEx por VIH)
wpp |> filter(Location == "Eswatini", Time %in% c(1988, 2004, 2023)) |>
  select(Location, Time, LEx, TFR, IMR)

# 2) Prueba inversa del Anexo A: mayores caídas anuales de LEx (países > 500 mil hab.)
wpp |> filter(LocTypeName == "Country/Area", Time <= 2023) |>
  group_by(Location) |> arrange(Time, .by_group = TRUE) |>
  mutate(dLEx = LEx - lag(LEx), popmax = max(TPopulation1July)) |>
  ungroup() |> filter(popmax > 500) |>
  slice_min(dLEx, n = 45) |> select(Location, Time, LEx, dLEx)

# 3) Caída de LEx por COVID (2019 -> mínimo de 2020/2021), países > 1 M hab. en 2019
wpp |> filter(LocTypeName == "Country/Area", Time %in% 2019:2021) |>
  group_by(Location) |>
  summarise(pop19 = TPopulation1July[Time == 2019],
            drop  = min(LEx[Time %in% 2020:2021]) - LEx[Time == 2019]) |>
  filter(pop19 > 1000) |> arrange(drop) |> head(10)
```
(Las cifras del documento se calcularon el 22-oct-2026 con un script equivalente en Python sobre el mismo archivo; `TPopulation1July` y `NetMigrations` están en miles.)

## Anexo F. Referencias prioritarias para la diapositiva "References" (formato corto)
1. UN DESA (2024). *World Population Prospects 2024: Summary of Results*. https://population.un.org/wpp/assets/Files/WPP2024_Summary-of-Results.pdf
2. UN DESA (2024). *WPP2024: Methodology Report*. https://population.un.org/wpp/assets/Files/WPP2024_Methodology-Report_Final.pdf
3. Lee, R. (2003). The Demographic Transition. *J. Econ. Perspectives* 17(4). https://www.aeaweb.org/articles?id=10.1257/089533003772034943
4. Omran, A. (1971/2005). The Epidemiologic Transition. *Milbank Q.* https://onlinelibrary.wiley.com/doi/10.1111/j.1468-0009.2005.00398.x
5. Lesthaeghe, R. (2014). The second demographic transition. *PNAS* 111(51). https://www.pnas.org/doi/10.1073/pnas.1420441111
6. Bloom, Canning & Sevilla (2003). *The Demographic Dividend*. RAND. https://www.rand.org/pubs/monograph_reports/MR1274.html
7. Clemens, M. (2014). Does Development Reduce Migration? IZA DP 8592. https://www.econstor.eu/handle/10419/106535
8. Zelinsky, W. (1971). The Hypothesis of the Mobility Transition. *Geogr. Rev.* 61(2). https://doi.org/10.2307/213996
9. Ashton et al. (1984). Famine in China, 1958–61. *PDR* 10(4). https://doi.org/10.2307/1973284
10. Whyte, Feng & Cai (2015). Challenging Myths About China's One-Child Policy. *China J.* 74. https://www.journals.uchicago.edu/doi/abs/10.1086/681664
11. Brainerd & Cutler (2005). Autopsy on an Empire. *J. Econ. Perspectives* 19(1). https://www.aeaweb.org/articles?id=10.1257/0895330053147921
12. Abbasi-Shavazi, McDonald & Hosseini-Chavoshi (2009). *The Fertility Transition in Iran*. Springer. https://link.springer.com/book/10.1007/978-90-481-3198-3
13. Kapiszewski, A. (2006). Arab versus Asian migrant workers in the GCC countries. UN EGM. https://www.un.org/en/development/desa/population/events/pdf/expert/11/P02_Kapiszewski.pdf
14. WHO (2022). 14.9 million excess deaths associated with COVID-19. https://www.who.int/news/item/05-05-2022-14.9-million-excess-deaths-were-associated-with-the-covid-19-pandemic-in-2020-and-2021
15. IOM (2024). *World Migration Report 2024*. https://worldmigrationreport.iom.int/
16. UNHCR Operational Data Portal (Syria, Ukraine, Sudan, Afghanistan). https://data.unhcr.org/
17. R4V (2024). Refugees and migrants from Venezuela. https://www.r4v.info/
18. American Statistical Association (2022). *Ethical Guidelines for Statistical Practice*. https://doi.org/10.5281/zenodo.7092386

---
*Documento preparado el 22-oct-2026 por el agente "history-research". Hechos con fuente citada; cifras [V] comprobadas en WPP2024 Medium; [PV] = pendiente de verificación; ≈ = aproximación o rango. Las coincidencias temporales entre eventos y quiebres de las series son descriptivas y no implican causalidad.*
