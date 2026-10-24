# QA · Ejecución del notebook y ensamblaje de `numbers.json` (v1)

Agente **ensamblaje** · cifras v1 congeladas el 2026-10-23 · informe del 2026-10-24.
Archivos: `R/05_numbers_json.R`, `figures/numbers.json`, `notebook/construir_notebook.py`,
`notebook/analisis_wpp2024.ipynb`, `notebook/analisis_wpp2024.html`, `notebook/exportar_html.py`.

## 1. Resultado en una línea

El notebook corre **de principio a fin sin errores ni avisos** (187 de 187 celdas de código, 13,6 min).
Vuelve a calcular todo desde los CSV de la ONU y da **los mismos archivos, byte a byte**, que las corridas
de los agentes de análisis. `figures/numbers.json` tiene **383 claves**, sin duplicados ni conflictos.
Faltan **8 claves**, que ningún análisis produjo; no se inventaron (sección 6).

## 2. Cómo se ejecutó

```bash
cd /home/darkns/Documents/ASA_Dataquest/RepoGithub
<venv-jupyter>/bin/python -I notebook/construir_notebook.py          # arma el .ipynb desde R/01–05
<venv-jupyter>/bin/jupyter nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.timeout=3600 notebook/analisis_wpp2024.ipynb
<venv-jupyter>/bin/python -I notebook/exportar_html.py               # HTML con texto alternativo
```

| Elemento | Valor |
|---|---|
| Inicio y fin de la ejecución | 2026-10-24 00:05:59 → 00:19:35 (hora de Bogotá) |
| Tiempo total | **816 s de reloj (13,6 min)**; 813 s de ejecución de celdas; el propio notebook mide 13,5 min. El plan §7.2 pide menos de 15 min: se cumple |
| Kernel | `ir` (IRkernel 1.3.2) · R 4.6.1 (2026-06-24) · Kali GNU/Linux Rolling · 14 núcleos · BLAS/LAPACK de referencia |
| Jupyter | Python 3.14.8 · nbconvert 7.17.2 · nbclient 0.11.0 · nbformat 5.11.1 |
| Semilla | `set.seed(2026)` antes de cada remuestreo · RNGkind Mersenne-Twister / Inversion / Rejection |
| Hipótesis | `docs/hipotesis_preinscritas.md` SHA-256 `83f98f6e1a3dbbcfa07b8435db7d11cc3eacc79faee9875591652bcbad3bb4b5`, commit `2a0ab7b` del 2026-10-23, sin cambios desde entonces |

Tiempo por sección (suma de las celdas):

| Sección | Segundos |
|---|---|
| 0–2 Fuentes, decisiones de datos (`R/01`), hipótesis | 11 |
| 3 · Q1 (`R/02_q1_palancas.R`) | 577 |
| 4 · Q2 (`R/03_q2_un_numero.R`) | 108 |
| 5 · Q3 (`R/04_q3_caminos.R`) | 104 |
| 6–7 Hipótesis consolidadas y `numbers.json` (`R/05`) | 3 |
| 10 Reproducibilidad (pruebas de `R/tests_incertidumbre.R` y `sessionInfo`) | 8 |

Las celdas más lentas son todas de Q1 §7 (panel): heterogeneidad por ingreso y región, 227 s;
*bootstrap* por bloques de las tres cifras, 86 s; "¿compensa la migración?", 76 s.

## 3. Celdas, salidas y avisos

- **313 celdas**: 187 de código y 126 de texto. Se ejecutaron las 187 y ninguna dio error.
- **50 figuras** mostradas: todas las de `figures/review/` (Q1 19, Q2 13, Q3 18), cada una con su pie.
  Ninguna falta y ninguna se repite. Revisé a ojo tres de ellas en el notebook (q1_01, q2_08, q3_17):
  se ven completas y legibles a 1 200 px.
- **Avisos de R: 0.** Hay 14 salidas por *stderr*, y todas son mensajes informativos (`message()`):
  "comun_analisis.R listo…", el registro de Q2 (winsorización de 7 países, ρ(CDR, LEx), PCA) y el cierre de Q2.
- **Avisos silenciados a propósito** en el código (se anotan para que QA los conozca):
  - Q1 usa `suppressWarnings(bootstrap_bloques(...))` cuatro veces. Son los subgrupos por ingreso o región
    con pocos bloques o réplicas fallidas, y el script imprime o guarda cuántos bloques usa cada uno
    (por ejemplo, en la participación migratoria: ingreso bajo 7, medio-bajo 14, medio-alto 18 y alto 16).
  - Q1 y Q3 silencian avisos de `sf` al proyectar a Robinson y al calcular centroides.
  - Q2 silencia `countrycode` (nombres) y Q3 silencia `chisq.test` (el estadístico se usa como descripción).
- Pruebas automáticas: `R/tests_datos.R` pasa 7 de 7 y `R/tests_incertidumbre.R` pasa 67 de 67, sin fallas.
- `nbconvert --to html` avisaba "Alternative text is missing on 50 image(s)". Para corregirlo,
  `notebook/exportar_html.py` usa el pie de cada figura como texto alternativo (accesibilidad). Ahora hay
  **0 imágenes sin descripción**. El HTML pesa 15 MB porque las figuras van incrustadas.

## 4. Reproducibilidad comprobada

| Comprobación | Resultado |
|---|---|
| `numbers_q1/q2/q3.json` y los tres CSV de `figures/`, antes del notebook frente a después | **idénticos** (SHA-256 `f1e617dd…`, `1532abfe…`, `0246f2da…`) |
| `data/processed/lookup_regiones.csv` y `diccionario_variables.csv`, regenerados por `R/01` | idénticos |
| `figures/numbers.json` · notebook (00:19) frente a una corrida nueva de `Rscript R/05_numbers_json.R` (08:30) | idéntico (SHA-256 `d8631bf8df9699a75f8efe2499d8d2d7846cc663ec4a08811bfc02e6f58f3cc6`) |
| El código del notebook frente a lo que genera hoy `construir_notebook.py` | 313 de 313 celdas iguales: el código es copia literal de `R/01–05` |

Después de ejecutar el notebook cambié solo tres celdas de **texto**. Ese texto no se ejecuta, así que no
toca ninguna cifra, y el generador se corrigió igual:
(1) la portada da el comando de exportación con texto alternativo;
(2) los años de la tabla P1–P8 van sin separador de miles ("1970 / 1984 / 2000", antes "1 970 / 1 984 / 2 000");
(3) se aclara que *China, Taiwan Province of China* es el nombre oficial de la ONU para el área ≥ 1 M sin grupo de ingreso.

## 5. `figures/numbers.json`

- **383 claves**: Q1 165 + Q2 96 + Q3 109 = 370 claves de análisis, más 13 que añade `R/05`
  (`hyp_file_sha256`, `hyp_file_sha256_short`, `hyp_file_commit`, `hyp_file_date`, cuatro `meta_raw_sha256_*`,
  `meta_numbers_date` = 2026-10-23, `meta_wpp_version`, `meta_income_classification` = WB FY2027,
  `meta_seed` = 2026 y `team_name`).
- **Duplicados**: 0 con contenido idéntico y 0 con contenido distinto. Las dos colisiones de la fase de
  análisis ya estaban resueltas en los scripts: `momentum_years_range` es de Q3 y las claves de banda son de Q2.
- **Claves globales**: las trae Q1, y `R/05` las recalcula y comprueba con los datos:
  `n_countries` 237, `n_countries_1m` 161 y `world_pop_2023_bn` 8,0917. El agregado ONU es igual a la suma
  de los 237 (diferencia 1,2 × 10⁻⁸ %).
- `validar_registro()` da 0 observaciones: toda clave tiene `method`, `n`, `universe` y `status`, y todo
  `ci_*` usa un método que puede salir en pantalla.
- Claves obligatorias del plan §4: 183, y coinciden con las de `R/incertidumbre.R`. **Están 176; faltan 7.**
- Marcadores `{clave}` del storyboard: 108 distintos. Se resuelven 103: 101 directos, 1 por alias
  (`n_twin_pairs` → `n_pairs_twins`) y 1 como rango derivado (`pc1_var_sens_range` → `sens_low`–`sens_high`
  de `pc1_var`). Otros 3 no son claves (`clave`, `n`, `pop`). **Faltan 2.**
- `slides/index.html`: 106 claves en `data-num`, `data-say` y `data-flags`. Faltan las mismas 2 del storyboard.
- Claves para verificar (las usadas en la portada, las diapositivas, la voz, las referencias o las figuras
  del vídeo): **210**. Todas tienen `verified: false` hasta que las marque QA-stats.

## 6. Claves faltantes (no se inventan)

| Clave | Dónde se pide | Por qué falta | Quién la produce |
|---|---|---|---|
| `n_census_pre2009` | plan §4 y storyboard (tarjeta de datos, "23") | Hace falta la tabla de fechas de censo de la ONU (WPP *data sources*), que no está en el repo. El 23 es una cifra externa del memo de ética | T0: tarea de *fitness for use* |
| `n_census_2019plus` | plan §4 | La misma tabla de censos ("114") | T0 |
| `n_shock_years_est` | plan §4 | La tarea T14 (choques y suavidad de las proyecciones) no se corrió | T14 (apéndice) |
| `n_shock_years_proj` | plan §4 | T14 | T14 |
| `n_lex_drop_proj` | plan §4 | T14 | T14 |
| `share_monotone_proj_lex` | plan §4 | T14 | T14 |
| `n_tests` | plan §4 | Q1 registra `n_tests_q1` y Q2 `n_tests_q2`, con definiciones distintas, y Q3 no registra ninguna. Sumarlas sería inventar una definición | T17: que alguien fije la definición por familia |
| `repo` | storyboard (tarjeta de ética y referencias) | El repositorio público aún no existe. `docs/equipo.json` tiene `repo: null` | repo-ops: crear el repo y rellenar `docs/equipo.json`. Después hay que volver a correr `R/05` |

## 7. Problemas encontrados en el ensamblaje

1. **`docs/correcciones.md` no existe** y el notebook lo cita dos veces (§8 y §9.6), igual que el plan §12.
   Hay que crearlo (lo hace repo-ops o QA-ethics) o quitar la referencia.
2. **`yrs_medage30_40_fast_started` vale 23,5, pero su `fmt` es `"0"`**: en pantalla saldría "24".
   Las claves vecinas con ,5 (`_early` 36,5 y `_cohort_pre1990` 40,5) usan `"0.0"`. Si script-narration elige
   la alternativa (b) de `docs/resultados_q3.md` §16, Q3 debe cambiar el formato a `"0.0"` (no es archivo mío).
3. **Estados de hipótesis que no coinciden**. En la tabla consolidada (§6 del notebook), H15 (Q1) y H25 (Q3)
   figuran como "confirmada", con el matiz escrito al lado. Los resúmenes de los agentes dicen "matizada".
   La cuenta queda así: 26 confirmadas, 1 matizada (H14) y 8 rechazadas, de 35. QA-stats y script-narration
   deben usar la misma palabra.
4. Las tablas de hipótesis de Q2 usan *confirmed/rejected* y las de Q1 y Q3 *confirmada/rechazada*.
   La consolidación las une, pero el idioma no es uniforme.
5. `are_revision_pct` = 12 % es **externo**: viene del memo de ética porque el archivo WPP 2022 no está en el repo.
   Lo usa el storyboard (zoom del Golfo). Una persona debe verificarlo antes de grabar.
6. El notebook no tiene las secciones separadas que pide el plan §7.2: "6 Incertidumbre P2/P3",
   "7 Dependencia espacial" y "8 Recomendaciones". Su contenido está en Q1 §9 (EAU, dirección 2050),
   Q1 §4 (Moran, LISA) y Q3 §13 (tabla "What to watch"), porque el notebook sigue el orden de los scripts.
   La sensibilidad de Togo (*Interim Update*) y T14 no se corrieron; el notebook lo dice en §9.1 y §9.2.
7. Sobre el commit: **dejé fuera `R/fig_q1_slide1.R`, `R/fig_q2_slide3.R` y `R/fig_q3_slide4.R`**, aunque
   están en `R/`. Son de los agentes de figuras, que los estaban editando mientras se hacía el commit:
   `fig_q1_slide1.R` cambió a las 08:40 y `fig_q3_slide4.R` a las 08:32 del 2026-10-24. No entran tampoco
   `figures/static/` ni `figures/animated/`: quedan para repo-ops, junto con sus scripts. En cambio, añadí
   `figures/*.csv` (`miembros_tipo_palanca.csv`, `miembros_grupos.csv`, `lookalikes_todos.csv`), porque el
   plan §7.2 y la tarjeta de ética las dan por publicadas.

## 8. Problemas heredados de los agentes de análisis

**Q1 — Which lever moves each country's population: births, deaths or migration? (P7 + P4)**

1. Colisión de clave resuelta: `momentum_years_range` era de Q1 (32–40, años desde TFR < 2,1 hasta el máximo
   proyectado) y de Q3 (34–38, años ponderados por población desde 2023 hasta el máximo; es la que pide el
   storyboard: "X more years of growth"). Q1 la renombró `momentum_clock_years_range` y la de Q3 se queda con el nombre.
2. Colisión resuelta: `n_band_tfr`, `nat_min_band`, `nat_max_band` y `r_nat_medage_band` estaban en Q1 y Q2
   con distinto `def` o `filter`. Q1 las quitó y solo deja una comprobación cruzada en el registro (los valores son idénticos).
3. **En el storyboard, "105 of 108" debe pasar a "106 of 109"**. La regla preinscrita H3a deja fuera a Taiwán
   (no tiene grupo de ingreso) y cuenta como "mortalidad primero" a RCA y RD del Congo, donde la caída de la
   fecundidad no ha empezado. La proporción sigue en 97 %.
4. `panel_within_halfq5` = −0,41: el IC por bloques [−0,77; 0,05] **incluye el 0**. El plan citaba el IC por
   *cluster* [−0,71; −0,12]. Si fig06 muestra un rango de 95 %, debe ser el de bloques, y nunca se puede decir
   que excluye el cero. "Less than half" depende de la estimación puntual (dentro/entre 0,39, IC por bloques
   [−0,05; 0,73]). Una frase más segura: "smaller than what comparing countries suggests".
5. La nota de fig06 en el storyboard, "not detected in Europe & N. America", es incorrecta: la estimación va
   **al revés**, +0,39 [*bootstrap* por país 0,23; 0,56]. `panel_ssa_halfq5` y `panel_eurna_halfq5` solo tienen
   *bootstrap* por país, porque tienen muy pocas subregiones para hacer bloques: hay que mostrar solo el valor.
6. El IC por bloques de `panel_ratio_between_within` (2,5) es inestable, [−9,2; 18,4]. No hay que mostrar
   intervalo para esa razón.
7. Diferencias frente a los valores provisionales de los memos: `moran_cnmr_2023` 0,114 sale como "0,11"
   (el plan decía 0,12). `share_mig_high` tiene IC por bloques [55,5; 133,3] y BCa [56,0; 111,9] (el plan decía
   BCa 55,8; 114,0). `lag_onset_lower_bound` tiene IC por bloques [16; 28]; el plan daba 20–25 iid, y ese
   intervalo iid se reproduce. El rezago KM 100/4 es 14 [11; 18] (plan: 11 [8; 15]). El inicio de la caída de
   la fecundidad es 1956 en Europa y Norteamérica y 1974 en Asia central y meridional (plan: 1959 y 1977).
8. `are_revision_pct` = 12 es una cifra **EXTERNA** tomada del memo de ética, porque no está el archivo WPP 2022.
   Una persona debe verificarla antes de usarla.
9. El resultado LISA del Golfo depende de la resolución de la permutación: los 7 países alto-alto sobreviven a
   la FDR con 999 permutaciones y ninguno con 199.
10. El mapa de revisión todavía no asigna Crimea a Ucrania. El mapa final debe usar los ajustes de `R/utils_mapas.R`.
11. Tiempo de Q1: 8,9–11,6 min según la carga de la máquina. Hubo tres corridas oficiales con `numbers_q1.json`
    idéntico byte a byte; en este notebook, 9,6 min.

**Q2 — Can a single indicator tell the whole story? (P8 + P5)**

12. Se registra el R² **ajustado**, como dice H6: 0,771 / 0,881 / 0,590 / −0,001. El plan y el storyboard citan
    0,773 / 0,882 / 0,592 / 0,005, que son los valores sin ajustar (van en `sens_note`). Redondeados a dos
    decimales dan lo mismo en pantalla (0,77 / 0,88 / 0,59 / 0,00). El "≈ 0,06" de migración del encargo es el
    error que ya corrigió el memo de inferencia: el valor real sin ajustar es 0,005.
13. IC del PC1: el encargo esperaba [55; 59], que es el *bootstrap* iid (aquí da [54,9; 59,2] y queda en
    `ci_iid`). El IC registrado para pantalla es el de bloques de subregión, [51,4; 62,6], unas 2,8 veces más
    ancho. Pasa lo mismo con ρ(CDR, LEx) en 2023: por bloques [−0,31; 0,32] frente al iid del memo [−0,08; 0,20].
14. ρ(CDR, LEx) es −0,974 en 1950 (el encargo decía −0,96) y 0,067 en 2023 (≈ +0,06): diferencias menores.
15. El escalón intermedio de la escalera es 0,697 (≈ 0,70) y el superior 0,986 (≈ 0,99), como se esperaba.
    Con la CBR en lugar de la TFR, la identidad da 1,000.
16. El IC de los look-alikes no recoge cómo cambia el propio conjunto de vecinos. Se decidió así porque el
    *bootstrap* ingenuo salía sesgado (está documentado en el doc §5). La sensibilidad a la composición se mide
    aparte, quitando una subregión cada vez: la TFR va de 12,9 a 15,5 %.
17. El storyboard dice que el % del PC1 va de 46 a 66 % según las variables. Con el conjunto "núcleo de la
    transición" del memo de inferencia, el máximo es 76,6 %. Hay que corregir el texto gris del storyboard a 46–77 %.
18. El caso destacado del índice, elegido por la regla escrita en el código, es EAU: sube 30 puestos sin la
    variante de migración. Ucrania, el caso del plan, sigue entre los más inciertos (8–54 con Monte Carlo) y
    queda en `rank_range_ukr`.
19. Las claves de universo y ética que faltan (n_sovereign, n_territories, n_tests, hyp_file_*, n_census_*,
    etc.) no son de Q2. Las 38 claves obligatorias de slide3 están todas.
    *(Nota del ensamblaje: `n_sovereign`, `n_territories` y `hyp_file_*` ya están, porque las ponen Q1 y R/05.
    Siguen faltando `n_census_*` y `n_tests`; ver la sección 6.)*
20. Tiempo de Q2: 112,8–191,8 s según la carga de la máquina. Tres corridas dan el mismo `numbers_q2.json`
    (SHA-256 `1532abfe…d829`) y el mismo registro; en este notebook, 108 s.

**Q3 — Same road, different speed: four roads and what the UN should watch (P6 + P1 + recomendaciones)**

21. Envejecimiento por grupo (QA_storyboard §6.3): `yrs_medage30_40_recent` y `_early` se redefinieron como
    medianas Kaplan-Meier de Fast y Early movers. Dan 32 [27; 37] y 36,5 [29; 42,5]: el contraste es débil y
    los IC se solapan. El prototipo (24 / 40,5) era por cohorte y ahora está en
    `yrs_medage30_40_cohort_1990_2023` y `_pre1990`. La frase del storyboard ("Fast movers … in 32 years what
    took Early movers 37") pierde fuerza. `docs/resultados_q3.md` §16 propone dos alternativas: (a) por
    cohorte, 24 frente a 41; (b) `yrs_medage30_40_fast_started`, 23,5 frente a 36,5. Lo decide script-narration
    (ver además el punto 2 de la sección 7 sobre el formato de 23,5).
22. `momentum_years_range` (QA §6.1) se calcula en Q3 como "34–38": P25–P75, ponderado por población, de los
    años desde 2023 hasta el máximo proyectado en los 22 países de inercia. Sin India da 19–34.
    *(Nota del ensamblaje: ya no hay colisión con Q1; ver el punto 1.)*
23. Se corrigió la fila 5 de `rec_rows`. El texto "more people leave than arrive" no describe el tipo E; ahora
    dice "emigration outweighs births — shrinking although births exceed deaths".
24. El plan cita el máximo de la DE de la TFR en 1990 (1,97). Los datos lo dan en 1981 (2,10).
25. Las cifras P1 del encargo (edad mediana 5,0 → 9,8; LEx 11,7 → 7,0) son de los 237. Las claves usan los
    161 (4,67 → 9,74; 12,24 → 7,42), como el plan §4; los 237 van en `sens_note`.
26. La DE de LE65 en 2023 es 2,846, que redondea a 2,8 (con dos decimales, 2,85). El plan §7 decía
    "1.5 → 2.9" por doble redondeo.
27. Clustering por velocidades: la silueta es 0,456, no 0,20 como en el memo FDA (que usaba otro espacio).
    La partición es degenerada (139 / 9 / 7 / 6; ARI 0,07) y se reporta como resultado negativo, solo en el notebook.
28. Los IC por bloques son anchos: razón P90/P10 de Q5 en 2023 [11,2; 28,4]; Δ DE de la edad mediana
    [3,05; 6,51], frente a [4,3; 5,8] en el plan, que era iid. Las medianas KM de 5 → 3 tienen el límite
    superior abierto en Early, Recent y Migration-led.
29. Las figuras de revisión usan los pies PIE-3 o PIE-5 aunque algunas no muestran intervalos ni bandas.
    Hay que corregirlo en las figuras finales.
30. Comprobaciones de QA §6: se cumple la regla de velocidad (China 5,1 y Egipto 32,7 años son el más rápido y
    el más lento de los 36 países ≥ 10 M; la mediana es Colombia, 18,6). "Mostly Gulf" también se cumple (5 de 7).

## 9. Pendientes para otros agentes

- **script-narration / slides**: los puntos 3, 4, 5, 6, 17 y 21 cambian texto del storyboard. Las 210 claves
  para verificar están listas para QA-stats.
- **QA-stats**: verificar a mano `are_revision_pct` y marcar `verified` clave por clave (plan §7.7).
- **repo-ops**: crear el repositorio público, rellenar `repo` en `docs/equipo.json` y volver a correr
  `Rscript R/05_numbers_json.R` (3 s). Crear `docs/correcciones.md` y hacer commit de `figures/static/` y `figures/animated/`.
- **T0 / T14 / T17**: producir `n_census_pre2009`, `n_census_2019plus`, las cuatro claves de choques y `n_tests`.
