# 05 — Catálogo de visualización: cómo hacer que las gráficas se muevan y señalen

> Documento de investigación para el premio **Best Data Visualization**. No decide el stack final (eso lo
> decide el equipo/otro agente de implementación); reúne evidencia, código de muestra ya **probado con datos
> reales** y recomendaciones razonadas. Títulos y etiquetas de ejemplo en inglés (idioma del vídeo); texto en
> español. Fuente primaria: <https://r-graph-gallery.com/>, complementada con la documentación oficial de
> `gganimate`, `plotly` y Quarto `revealjs`.
>
> **Estado del entorno al escribir esto (2026-10-22):** un agente paralelo está instalando paquetes de R
> (`sf`, `rnaturalearth`, `magick`, `gifski`, `av`, `ggbump`, `ggstream`, `factoextra`, `geofacet`, `ggimage`,
> `gganimate`, `transformr`, `units`, `terra` — ver `docs/paquetes_estado.csv`). Las pruebas de este documento
> usan **solo lo ya instalado** (`tidyverse`, `data.table`, `ggplot2`, `patchwork`, `scales`, `viridis`,
> `ggridges`, `ggrepel`, `ggthemes`, `plotly`, `ggalluvial`, `ggflags`, `maps`/`mapproj`, `countrycode`,
> `cluster`) y herramientas de sistema ya presentes (`convert`/`magick` de ImageMagick 7.1.2, `gifsicle`). Los
> scripts probados están en el scratchpad de este agente
> (`/tmp/.../scratchpad/viz/test_plots.R`, `test_v2.R`, `test_v3.R`) con 12 PNG renderizados a 1920×1080 que
> se pueden reutilizar directamente como punto de partida en `R/figuras_estaticas.R`.

---

## 1. Recorrido por r-graph-gallery.com: familias de gráficas y veredicto de utilidad

### 1.1 Familias principales del sitio

El sitio organiza ~400 ejemplos en familias (mismo esquema que data-to-viz.com). Confirmado navegando el
sitio en vivo:

| Familia | URL de entrada | Qué cubre | Utilidad para nosotros |
|---|---|---|---|
| **Distribution** | `r-graph-gallery.com/violin.html` (+ `ridgeline-plot.html`, `boxplot.html`, `histogram.html`) | Violín, ridgeline, caja, histograma, densidad | **Alta** — ridgeline para P1 (edad mediana se dispersa), violín para comparar TFR por grupo de ingreso |
| **Correlation** | `r-graph-gallery.com/scatterplot.html` (+ `connected-scatterplot.html`, `correlogram.html`, `bubble-chart.html`) | Dispersión, dispersión conectada, correlograma, burbujas | **Alta** — es el corazón de P7 (TFR vs LEx) y P8 (matriz de correlación) |
| **Ranking** | `r-graph-gallery.com/barplot.html` (+ `lollipop-plot.html`, `package/ggbump.html`) | Barras, lollipop, bump chart | **Alta** — bump chart para P5 (fragilidad del índice), barras para conteos de países por tipo |
| **Part of a whole** | `r-graph-gallery.com/stacked-barplot.html` (+ `web-diverging-bar-plot-recreated-from-nytimes.html`, `treemap.html`) | Apiladas, divergentes, treemap, dona | **Alta** — barras apiladas **divergentes** son exactamente "crecimiento = natural + migración" (P4/P7) |
| **Evolution** | `r-graph-gallery.com/line-plot.html` (+ `spaghetti-plot.html`, `area-chart.html`, `time-series.html`) | Líneas, spaghetti, área, series de tiempo | **Alta** — spaghetti con resaltado es la base de casi toda la narrativa temporal |
| **Map** | `r-graph-gallery.com/map.html` (+ `327-chloropleth-map-from-geojson-with-ggplot2.html`, `package/sf.html`) | Coroplético, puntos en mapa, cartograma | **Alta** — mapa de palancas (P4) y de clústeres (P6); pendiente de `sf`/`rnaturalearth` (en instalación) |
| **Flow** | `r-graph-gallery.com/chord-diagram.html` (+ `sankey-diagram.html`, `network.html`) | Chord, Sankey, redes | **Baja** — no tenemos flujos origen-destino de migrantes en WPP2024 (solo saldo neto); útil solo si se añade un dataset de corredores migratorios, fuera de alcance |
| **Animation** (bajo "General Knowledge") | `r-graph-gallery.com/animation.html` + `package/gganimate.html` | `gganimate` (4 ejemplos: dispersión, pequeños múltiplos, barras, líneas) y **método alterno con ImageMagick** (concatenar PNG → GIF por línea de comandos) | **Alta** — confirma que el método "fotogramas PNG + ImageMagick" que ya probamos en el scratchpad es una receta oficial del propio sitio, no un parche nuestro |

**Veredicto general:** el sitio no tiene una categoría "parte de un todo con PCA/biplot" ni "tile grid map" como
familia de primer nivel — esos viven en páginas de paquete (`GGally` para correlogramas tipo `ggcorr`/`ggpairs`,
`geofacet` para tile grid maps) o en tutoriales sueltos fuera del dominio. Los documentamos igual en la
sección 2 porque responden directamente a P1/P6/P8.

### 1.2 Gráficas recomendadas por pregunta (2–3 cada una, con razón para un jurado no técnico)

#### P7 — Fecundidad–mortalidad–migración por región/ingreso

| # | Gráfica | Ejes / color / facetas / anotación | Por qué un jurado no técnico la entiende |
|---|---|---|---|
| 1 | **Connected scatterplot** TFR vs LEx, una línea por región SDG, 1950→2023 | x = esperanza de vida, y = hijos por mujer; color = región SDG (Okabe-Ito); flecha al final = año actual; anotación puntual "1994: Rwanda genocide" en el punto donde la línea retrocede | Es literalmente "el camino que recorre cada región": sube hacia la derecha y baja; el jurado ve una ruta, no una tabla |
| 2 | **Barras apiladas divergentes** del crecimiento (natural vs migratorio) por región, 2023 | x = tasa por 1.000 hab., y = región (ordenada por crecimiento total); verde = cambio natural, naranja = migración neta; ◇ = crecimiento total | Responde en una imagen "¿por qué crece cada región?" sin necesitar leer números — el signo y el tamaño de la barra ya lo dicen |
| 3 | **Pequeños múltiplos** (facetas) de natural/migración/total por grupo de ingreso, 1950–2100 | x = año, y = tasa por 1.000; 3 líneas por panel; sombreado gris = proyección ≥2024 | Compara 4 historias en paralelo sin saturar un solo gráfico; el "cruce a migración" en ingreso alto salta a la vista |

#### P8 — ¿Un indicador cuenta toda la historia?

| # | Gráfica | Ejes / color / facetas / anotación | Por qué un jurado no técnico la entiende |
|---|---|---|---|
| 1 | **Biplot de PCA** de 8 indicadores, 2023 | x/y = PC1/PC2 con % de varianza en el título; puntos = países coloreados por región; flechas = indicadores originales con etiqueta | Las flechas "apuntando a lo mismo" muestran visualmente que varios indicadores miden una sola cosa — sin explicar álgebra lineal |
| 2 | **Matriz de correlación** (correlograma) de los mismos 8 indicadores | celdas coloreadas rojo↔azul, número dentro de cada celda | El jurado ve de un vistazo qué pares se mueven juntos (rojo/azul intenso) y cuáles no (blanco) |
| 3 | **Escalera de barras R²** (fertilidad → +mortalidad → +migración) | barras horizontales crecientes, última resaltada, nota "= % de las diferencias que el modelo explica" | Convierte un concepto estadístico (R²) en una barra que crece — intuitivo sin fórmula |

#### P1 — Divergencia de la estructura por edad

| # | Gráfica | Ejes / color / facetas / anotación | Por qué un jurado no técnico la entiende |
|---|---|---|---|
| 1 | **Ridgeline** de edad mediana entre países, por año (1950…2100) | x = edad mediana, y = año (una "cresta" por año), color = gradiente temporal | Las crestas que antes eran un solo pico y ahora son anchas/bimodales cuentan "se dispersaron" sin decir la palabra "varianza" |
| 2 | **Fan chart** de percentiles (P10–P90) de edad mediana/LEx en el tiempo | x = año, banda ancha = P10–P90, banda oscura = P25–P75, línea = mediana | El abanico que se abre **es** la divergencia; no requiere explicar desviación estándar |
| 3 | **Dumbbell** del año en que cada país cruza Q5<100‰ vs TFR<4 | y = país (ordenado por región), dos puntos conectados por una línea, llave con la mediana del rezago | Muestra "quién fue primero" (mortalidad) de forma literal: el punto hueco siempre a la izquierda del punto lleno |

#### P4 — Migración vs crecimiento

| # | Gráfica | Ejes / color / facetas / anotación | Por qué un jurado no técnico la entiende |
|---|---|---|---|
| 1 | **Mapa coroplético de "palancas"** 2023 (4–5 categorías: crece por nacimientos / crece solo por migración / decrece por muertes / decrece por emigración) | relleno categórico Okabe-Ito; leyenda en forma de pregunta; franja inferior con micro-estados | Un mapa de colores que el jurado "lee" como un semáforo del mundo sin mirar cifras |
| 2 | **Barras apiladas divergentes** (igual que P7-2) pero ordenadas por `CNMR` en vez de crecimiento total | mismo diseño, distinto orden | Aísla la migración como "la barra naranja que sobresale" en los países/regiones ricas |
| 3 | **Connected scatterplot** `CNMR` vs `PopGrowthRate`, países resaltados (Alemania, EAU, Puerto Rico) | x = migración neta por 1.000, y = crecimiento total; línea diagonal de referencia donde migración = crecimiento | Los países "sobre la diagonal" literalmente viven de la migración; fácil de señalar con una flecha |

#### P5 — Índice compuesto y su fragilidad

| # | Gráfica | Ejes / color / facetas / anotación | Por qué un jurado no técnico la entiende |
|---|---|---|---|
| 1 | **Bump chart** de rango por versión del índice (3–7 variantes) | x = versión del índice, y = rango (invertido, 1 arriba), una línea por país, 8–10 países etiquetados | Un país que "salta" de arriba a abajo entre columnas es una imagen instantánea de "la elección de pesos importa" — probado en el scratchpad (`12_bump_index_variants.png`, ver §2.12) |
| 2 | **Slope chart** de 2 versiones extremas del índice (p. ej. pesos iguales vs sin edad mediana) | dos columnas, líneas que cruzan | Versión simplificada del bump chart para solo 2 variantes, más legible a 5 segundos de pantalla |

#### P6 — Grupos por trayectorias

| # | Gráfica | Ejes / color / facetas / anotación | Por qué un jurado no técnico la entiende |
|---|---|---|---|
| 1 | **Mapa coroplético de clústeres** (4 tipos: Early/Fast/Late movers, Migration-boosted) | relleno categórico; 3 banderas de ejemplo por tipo en la leyenda | Mapa = geografía reconocible; el jurado asocia el color con países que ya conoce |
| 2 | **Pequeños múltiplos de trayectorias** (TFR y edad mediana 1950→2023) por tipo de clúster | x = año, y = indicador, línea mediana en grueso + líneas individuales finas, 4 paneles | Cada panel es "cómo se mueve ese grupo"; comparar 4 paneles es más fácil que leer un dendrograma |
| 3 | **Spaghetti con resaltado** de 1 país representativo por clúster sobre el fondo gris de los 236 | igual diseño que P7-1 pero coloreado por clúster, no por región | Reutiliza el mismo lenguaje visual que la Slide 1, dando coherencia al vídeo completo |

---

## 2. Gráficas "estrella" candidatas (14) con bosquejo de código ggplot2

Convención: **[✓ probado]** = ya renderizado con datos reales de WPP2024 en el scratchpad (archivo PNG citado,
1920×1080, tema `theme_wpp()` común — ver `test_plots.R`/`test_v2.R`/`test_v3.R` en
`/tmp/claude-1000/.../scratchpad/viz/`). **[boceto]** = código de referencia, pendiente del paquete que el
otro agente está instalando. Todos usan el objeto `dc` (datos de país, `LocTypeID==4`) y el tema común:

```r
theme_wpp <- function(base_size = 20, base_family = "Inter") {
  theme_minimal(base_size = base_size, base_family = base_family) +
  theme(plot.title = element_text(face = "bold", size = rel(1.5), hjust = 0),
        plot.subtitle = element_text(colour = "grey30"),
        plot.caption = element_text(size = rel(0.7), colour = "grey45", hjust = 0),
        plot.title.position = "plot", plot.caption.position = "plot",
        panel.grid.minor = element_blank(), legend.position = "top", legend.title = element_blank(),
        plot.background = element_rect(fill = "white", colour = NA))
}
proj_shade <- annotate("rect", xmin = 2023.5, xmax = 2100, ymin = -Inf, ymax = Inf, fill = "grey92", alpha = .6)
proj_line  <- geom_vline(xintercept = 2023.5, linetype = "22", colour = "grey40")
```

### 1. Connected scatterplot TFR vs LEx con flechas de tiempo [✓ probado → `02_connected_scatter.png`]
P7. Eje x = LEx, y = TFR, una línea por país/región, `geom_path()` con flecha al final (2023), punto en 1950,
etiqueta directa en el extremo. Confirmado con datos reales: la caída de Ruanda 1994 (genocidio) se ve como un
retroceso brusco de la línea hacia la izquierda (LEx cae), con anotación por `geom_curve` apuntando al quiebre.
```r
ggplot(cs, aes(LEx, TFR, group = Location, colour = SDG)) +
  geom_path(linewidth = 1.3, arrow = arrow(length = unit(10, "pt"), type = "closed"), lineend = "round") +
  geom_point(data = cs[Time == 1950], size = 3.5) +
  geom_text(data = cs[Time == 2023], aes(label = paste0(Location, " 2023")), hjust = 0, nudge_x = .8) +
  annotate("curve", x = 20, y = 6.5, xend = 13.5, yend = 6.25, curvature = .3,
           arrow = arrow(length = unit(8, "pt"))) +
  annotate("text", x = 12, y = 6.6, label = "Rwanda 1994\ngenocide", hjust = 0) +
  geom_hline(yintercept = 2.1, linetype = "dotted")
```

### 2. Barras apiladas divergentes: crecimiento = natural + migratorio [✓ probado → `03_diverging_growth.png`]
P4/P7. `geom_col()` horizontal con dos series (`NatChangeRT` verde, `CNMR` naranja) sobre eje 0, `geom_point`
con `shape = 23` (diamante) para el total. Con datos reales de 2023: Sub-Saharan Africa ≈ +26‰ (casi todo
natural); Europe & Northern America con natural **negativo** y migración positiva sosteniendo el total.
```r
ggplot(rl, aes(rate, Location, fill = comp)) +
  geom_col(width = .7) +
  geom_point(data = reg, aes(PopGrowthRate, Location), shape = 23, size = 5, fill = "white") +
  geom_vline(xintercept = 0) +
  scale_fill_manual(values = c("#009E73", "#D55E00"))
```

### 3. Spaghetti (236 líneas) con 5 países resaltados y el resto en gris [✓ probado → `01_spaghetti_highlight.png`]
P1/P7/P6. Base `geom_line(colour = GREY, alpha=.6)` para todos los países, encima `geom_line()` con color
solo para los resaltados — patrón equivalente a `gghighlight::gghighlight()` pero sin esa dependencia (no
instalada). Franja gris + línea discontinua marcan la proyección ≥2024.
```r
ggplot(dc, aes(Time, TFR, group = ISO3_code)) +
  proj_shade + proj_line +
  geom_line(colour = "#C8C8C8", linewidth = .4, alpha = .6) +
  geom_line(data = dc[ISO3_code %in% hl], aes(colour = SDG), linewidth = 1.8) +
  geom_text(data = dc[ISO3_code %in% hl & Time == 2100], aes(label = Location, colour = SDG),
            hjust = 0, nudge_x = 1.5, fontface = "bold")
```
*(Si `ggrepel` evita solapes automáticos, ya está instalado — usar `geom_text_repel()` en vez de desplazamientos manuales cuando haya >3 etiquetas cercanas.)*

### 4. Slope chart 1950 → 2023 → 2100 [✓ probado → `04_slope.png`]
P1/P6. Tres columnas discretas (`factor(Time)`), `geom_line` + `geom_point`, etiquetas en los extremos.
Resultado real con agregados regionales: la edad mediana de África en 2100 iguala a la de Europa en 1950.
```r
ggplot(sl, aes(factor(Time), MedianAgePop, group = Location, colour = Location)) +
  geom_line(linewidth = 1.6) + geom_point(size = 4) +
  geom_text(data = sl[Time == 2100], aes(label = paste(Location, round(MedianAgePop))), hjust = 0)
```

### 5. Fan chart de dispersión entre 236 países [✓ probado → `05_fan_chart.png`]
P1/P7. Percentiles por año con `geom_ribbon()` (doble banda P10–P90 y P25–P75) + mediana en `geom_line()`,
y un país ancla (Niger) superpuesto para dar un punto de referencia humano al abanico estadístico.
```r
ggplot(fan, aes(Time)) +
  geom_ribbon(aes(ymin = p10, ymax = p90), fill = "#0072B2", alpha = .25) +
  geom_ribbon(aes(ymin = p25, ymax = p75), fill = "#0072B2", alpha = .45) +
  geom_line(aes(y = p50), colour = "#0072B2", linewidth = 2) +
  geom_line(data = dc[ISO3_code == "NER"], aes(y = TFR), colour = "#E69F00", linewidth = 1.6)
```

### 6. Heatmap país × año [✓ probado → `06_heatmap.png`]
P1/P6. `geom_tile(aes(fill = TFR))` con países en el eje y (ordenados por el valor de 2023) y años cada 5 en
el eje x; `scale_fill_viridis_c(option = "magma", direction = -1)`. Útil para Sub-Saharan Africa (≈46 países)
sin saturar; con 237 países habría que paginar o usar solo un subcontinente por diapositiva.
```r
ggplot(hm, aes(Time, Location, fill = TFR)) + geom_tile() +
  scale_fill_viridis_c(option = "magma", direction = -1)
```

### 7. Biplot de PCA [✓ probado → `07_pca_biplot.png`]
P8. `prcomp(scale.=TRUE)` sobre 8 indicadores (países >90k hab., 2023); puntos = países coloreados por región,
flechas = `geom_segment` con `arrow()`, etiquetas con `geom_label`. **Resultado real de la prueba: PC1 explica
64.3 %, PC2 18.1 %** (con el set TFR/LEx/IMR/MedianAgePop/CNMR/PopGrowthRate/CBR/CDR) — distinto del 46 %
citado en `00_plan_analitico.md` porque ese usa otro conjunto de variables; **el notebook final debe fijar un
único set de variables para el PCA citado en el guion** antes de narrar el número.
```r
pc <- prcomp(X[, .(TFR, LEx, IMR, MedianAgePop, CNMR, PopGrowthRate, CBR, CDR)], scale. = TRUE)
ggplot(sc, aes(PC1, PC2)) +
  geom_point(aes(colour = SDG), size = 3.2) +
  geom_segment(data = ld, aes(x=0,y=0,xend=PC1*k,yend=PC2*k), arrow = arrow(length=unit(8,"pt"))) +
  geom_label(data = ld, aes(PC1*k*1.12, PC2*k*1.12, label = var))
```

### 8. Matriz de correlación [✓ probado → `08_corr_matrix.png`]
P8. `GGally::ggcorr()` (GGally está instalado) sobre los mismos 8 indicadores; alternativa sin GGally:
`corrr::stretch()` + `geom_tile()` manual si se prefiere no depender de GGally.
```r
GGally::ggcorr(X[, .(TFR, LEx, IMR, MedianAgePop, CNMR, PopGrowthRate, CBR, CDR)],
               label = TRUE, label_round = 2, low = "#B2182B", mid = "white", high = "#2166AC")
```

### 9. Pequeños múltiplos por grupo de ingreso (natural vs migración vs total) [✓ probado → `09b_small_multiples_fixed.png`]
P7/P4. `facet_wrap(~Income, nrow=1)` con 3 series por panel; confirma con datos reales que en **High income**
la línea de migración se mantiene positiva mientras la natural cruza a negativo desde los 1990s–2000s.
```r
ggplot(sml, aes(Time, value, colour = variable)) +
  proj_shade + geom_hline(yintercept = 0) + geom_line(linewidth = 1.4) +
  facet_wrap(~Income, nrow = 1) + scale_colour_manual(values = c("black", "#009E73", "#D55E00"))
```

### 10. Fotogramas manuales → GIF con ImageMagick [✓ probado → `10_frames_imagemagick.gif`]
Ver sección 3.1 — burbujas LEx vs TFR por año (1960–2023, paso 9 años), tamaño = población, con anotación que
aparece solo desde 1994 ("Rwanda genocide"). Confirma que **no se necesita `gganimate` instalado** para un
primer corte animado: basta `ragg::agg_png()` por fotograma + `convert -delay -loop` (sección 3.1).

### 11. Ridgeline de edad mediana por año [✓ probado → `11_ridgeline_medianage.png`]
P1. `ggridges::geom_density_ridges()` (ya instalado), un año por cresta. Resultado real: en 1950 las 237
distribuciones de edad mediana forman **un solo pico estrecho** (~18–20 años); en 2100 la distribución se
vuelve ancha y con dos protuberancias — evidencia visual directa de "los países se separan", sin calcular
desviación estándar en pantalla.
```r
ggplot(rg, aes(MedianAgePop, Time_f, fill = Time)) +
  geom_density_ridges(scale = 2.2, rel_min_height = .01, colour = "white") +
  scale_fill_viridis_c(option = "mako", guide = "none")
```

### 12. Bump chart de rangos del índice compuesto [✓ probado (versión manual) → `12_bump_index_variants.png`]
P5. Prueba con `geom_line`+`geom_point` sobre rangos calculados a mano (sin `ggbump`, que no está instalado
todavía). **10 países de ejemplo, 3 definiciones de índice (pesos iguales / ponderado a salud / sin edad
mediana):** Bielorrusia y Jordania cambian de orden entre variantes mientras Níger y Japón quedan fijos en los
extremos — ilustra exactamente la tesis de P5 ("la elección de pesos mueve países intermedios, no los
extremos"). Cuando `ggbump` esté instalado, el mismo resultado se logra con `geom_bump()` (curvas suaves en
vez de líneas rectas) y menos código:
```r
ggplot(bl, aes(variant, rank, group = ISO3_code, colour = ISO3_code)) +
  ggbump::geom_bump(linewidth = 1.2, smooth = 6) + geom_point(size = 3) +
  scale_y_reverse()
```

### 13. Mapa coroplético mundial, proyección Robinson [boceto — pendiente `sf`/`rnaturalearth`]
P4/P6. El agente paralelo está instalando `sf`, `rnaturalearth`, `units`, `terra` (dependencias de sistema
`libgdal`/`libgeos`/`libproj`/`libudunits2` ya cacheadas en `.deb` en el scratchpad — ver nota de §introducción).
Con eso disponible:
```r
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
world <- dplyr::left_join(world, lever_map, by = c("iso_a3" = "ISO3_code"))
ggplot(world) +
  geom_sf(aes(fill = lever_type), colour = "white", linewidth = .1) +
  coord_sf(crs = "+proj=robin") +            # Robinson
  scale_fill_manual(values = pal_lever, na.value = "grey85")
```
**Alternativa inmediata sin `sf`** (ya disponible hoy con `maps`+`mapproj`, instalados): `maps::map_data("world")`
+ `countrycode::countrycode()` para unir por ISO3, `coord_map("mollweide")` o `coord_quickmap()` en vez de
Robinson exacto. Es la ruta que ya prevé `00_storyboard_diapositivas.md` ("si falla, `coord_quickmap`") —
razonable para no bloquear el avance mientras `sf` termina de instalarse, pero el biplot/mapa final debería
migrar a `sf`+Robinson en cuanto esté listo porque el resultado visual es notablemente mejor (fronteras
correctas, sin las distorsiones de `maps`).

### 14. Tile grid map tipo geofacet / pequeños múltiplos por región SDG [boceto — pendiente `geofacet`]
P6. `geofacet` no tiene una rejilla oficial "región SDG de la ONU" predefinida — haría falta construir una
rejilla manual con `geofacet::grid_design()` (interfaz Shiny) o reutilizar `facet_wrap()` normal como
alternativa inmediata (ya usado en la gráfica 9). Boceto para cuando esté instalado:
```r
my_grid <- geofacet::grid_design()  # editor interactivo, exporta CSV de posiciones
ggplot(dc_region, aes(Time, TFR)) + geom_line() +
  geofacet::facet_geo(~SDG, grid = my_grid)
```
Dado el esfuerzo de construir la rejilla a mano y que ya cubrimos la misma idea con `facet_wrap` (gráfica 9),
**prioridad baja** frente a las otras 13.

### Banderas e iconos de país

Dos rutas, ambas viables hoy:

1. **`ggflags`** (ya instalado vía GitHub, `TRUE` en `paquetes_estado.csv`): `geom_flag(aes(x, y, country = iso2c))`
   con círculos SVG — ideal para ejes categóricos pequeños (p. ej. eje x de un gráfico de barras con 6–8 países)
   o como "chips" en tarjetas HTML de reveal.js. Requiere código ISO2 en minúsculas.
2. **`ggimage` + flagcdn.com** (`ggimage` aún no instalado): `geom_image(aes(image = paste0("https://flagcdn.com/w80/", iso2c, ".png")))`
   — banderas rectangulares planas, más neutras visualmente que las circulares de `ggflags` y sin límite de
   resolución (flagcdn ofrece w20 a w2560). Mejor para el HTML de reveal.js directamente (`<img src="https://flagcdn.com/...">`,
   sin pasar por R) que para gráficas ggplot2 renderizadas, porque cada `geom_image` dispara una descarga de
   red por punto (lento si no se cachea localmente primero con `curl::curl_download()`).

**Recomendación:** usar `ggflags` para las pocas gráficas estáticas con banderas (ya disponible, cero
fricción) y banderas HTML nativas (`<span class="fi fi-xx">` de la librería `flag-icons`, como ya prevé el
storyboard) para los elementos de interfaz de reveal.js — más nítido a 1920×1080 y no depende de red durante
la grabación.

---

## 3. Animación y "señalar": comparación práctica de las 5 vías

### 3.0 Tabla comparativa

| Vía | Calidad visual | Facilidad (con lo instalado hoy) | Sincronía con narración al grabar | Peso | Riesgos |
|---|---|---|---|---|---|
| **(a) `gganimate` + `gifski`/`av`** | Alta — transiciones suaves, interpolación real entre fotogramas | **Bloqueada hoy** (`gganimate`, `transformr`, `gifski`, `av` no instalados; en cola del otro agente) | Media: se exporta a GIF/MP4 de duración fija, hay que ajustar `fps`/`duration` para que calce con el guion ya escrito | GIF ligero (cientos de KB–pocos MB); MP4 vía `av` más pesado pero manejable | `av` necesita las librerías de desarrollo de ffmpeg en el sistema para compilarse (no hay `ffmpeg` como binario en esta máquina — ver §intro); si falla, usar `gifski` (no depende de ffmpeg) o el método ImageMagick de abajo |
| **(b) `plotly` con frames y botones** | Media-alta — interactivo, zoom/hover real, pero se ve "de panel web", no cinematográfico | **Disponible hoy** (`plotly`, `htmlwidgets` instalados) | Baja para un vídeo grabado: el usuario tendría que darle *play* manualmente al grabar pantalla, o fijar un `frame` por `Time` y animarlo con JS (`Plotly.animate()`), más trabajo de ingeniería web | Alto si se embebe el widget completo (varios cientos de KB de JS por gráfica) | Pensado para exploración interactiva, no para exportar vídeo limpio; capturarlo con screen-record introduce artefactos (cursor, bordes de navegador) |
| **(c) `reveal.js` (fragments + auto-animate, vía Quarto revealjs)** | Alta para "construir" una diapositiva por capas (textos, tarjetas, tablas) — **no** para animar ejes/datos dentro de una misma gráfica ggplot | Media: `Quarto` **no está instalado** en esta máquina (`quarto --version` → not found); reveal.js puro sin Quarto es viable con HTML/CSS a mano | **Alta** — es la única vía donde el `data-fragment-index` se puede casar 1:1 con cada frase del guion, justo lo que pide el storyboard | Muy ligero (HTML/CSS/JS, sin vídeo embebido salvo los `.mp4` que se insertan) | Auto-animate solo interpola propiedades CSS entre elementos con el mismo `data-id` en dos diapositivas — no re-dibuja una curva de datos; para eso se necesita (a) o (e) y luego insertar el MP4/GIF resultante dentro de la diapositiva reveal.js |
| **(d) D3 / Observable Plot** | Muy alta (control total, transiciones nativas SVG) | **Baja** con lo disponible: hay `node`/`npm` en el sistema pero no hay proyecto D3 montado, hay que construir un pipeline nuevo (bundler, servidor, exportar a vídeo con algo como Puppeteer) — fuera del flujo R ya construido | Alta en teoría, pero el coste de ingeniería para una entrega con fecha fija (30 oct 2026) es el más alto de las 5 vías | Depende del bundle | **No recomendado dado el plazo**: reconstruir en D3 lo que ya funciona en ggplot2 no aporta tiempo de pantalla adicional; resérvese solo si sobra tiempo y se quiere una pieza interactiva de bonus para el repositorio (no para el vídeo) |
| **(e) Exportar MP4 desde R** | Alta si sale de `gganimate`+`av`; aceptable si sale de PNG secuenciales recompuestos en un editor de vídeo externo | **Parcialmente disponible hoy**: no hay `ffmpeg` como binario de sistema, por lo que ni `av::av_encode_video()` ni un `system("ffmpeg ...")` funcionan todavía; **sí** funciona exportar una secuencia de PNG (`ragg::agg_png` por fotograma, ya probado) e importarla como "image sequence" en cualquier editor de vídeo (Premiere, DaVinci, Shotcut) | Alta: el editor de vídeo es exactamente donde se sincroniza con la voz grabada — es el flujo que el propio storyboard ya asume ("vídeo renderizado desde R... se compone en el editor de vídeo") | Una secuencia de 60–150 PNG a 1920×1080 pesa decenas de MB, manejable | Sin `ffmpeg`/`av`/`gifski` instalados, el único camino probado end-to-end hoy es **PNG → GIF con ImageMagick** (abajo) o **PNG → editor de vídeo**; pedir al agente de instalación que priorice `gifski` (no depende de ffmpeg, más simple de compilar) sobre `av` si el tiempo aprieta |

**Opinión razonada:** para una entrega con fecha fija y un vídeo que se graba una sola vez con narración en
vivo, la combinación más segura es **(e) secuencia de PNG renderizados desde R → editor de vídeo** para las
animaciones "de datos" (lo que se mueve dentro de una gráfica: un año que avanza, una línea que se dibuja, un
país que se resalta) combinada con **(c) reveal.js/Quarto** para las animaciones "de interfaz" (tarjetas,
texto, tablas, títulos que aparecen) — exactamente lo que ya propone `00_storyboard_diapositivas.md`. **(a)
`gganimate`** es la mejora natural de (e) en cuanto `gifski` o `av` terminen de instalarse (mismo código R,
mucho menos trabajo manual de fotogramas), así que vale la pena escribir las gráficas ya pensando en
`transition_*()` desde ahora aunque hoy se rendericen "a mano" con el bucle `for` + ImageMagick. **(b)** y
**(d)** quedan como opciones secundarias: (b) para el apéndice interactivo del repositorio (no para el vídeo),
(d) descartado por plazo.

### 3.1 Receta probada hoy: fotogramas R + ImageMagick (sin `gganimate`)

Confirmado en el scratchpad (`10_frames_imagemagick.gif`, 8 fotogramas, 960×540): el propio r-graph-gallery
documenta este método como alternativa oficial a `gganimate` (§1.1). Patrón general:

```r
yrs <- seq(1960, 2023, by = 9)
for (i in seq_along(yrs)) {
  yy <- yrs[i]
  pp <- ggplot(dc[Time == yy], aes(LEx, TFR, size = TPopulation1July, colour = SDG)) +
    geom_point(alpha = .75) + scale_size_area(max_size = 28, guide = "none") +
    scale_x_continuous(limits = c(10, 90)) + scale_y_continuous(limits = c(0, 9)) +   # ejes fijos: sin esto "salta"
    { if (yy >= 1994) annotate("label", x = 15, y = 7.5,
        label = "1994: Rwanda genocide\nlife expectancy fell to 12", fill = "#FFF3CD") } +
    labs(title = paste0("Year: ", yy))
  ragg::agg_png(sprintf("frames/f%02d.png", i), width = 1920, height = 1080, res = 144); print(pp); dev.off()
}
```
```bash
convert -delay 60 -loop 0 frames/f*.png -layers Optimize out.gif   # o -dispose previous si hay fondos opacos
gifsicle -O3 out.gif -o out_optimizado.gif                          # gifsicle ya instalado: reduce peso ~30-60%
```
Puntos clave aprendidos al probarlo: (1) **fijar los límites de los ejes** (`scale_*_continuous(limits=...)`)
en todos los fotogramas, si no "saltan" al cambiar los datos de cada año; (2) la anotación histórica se agrega
con una condición `if (yy >= 1994)` dentro del bucle — así aparece solo desde su año, que es exactamente la
receta pedida más abajo (§3.2); (3) el GIF resultante se puede importar directamente a un editor de vídeo como
clip, o reconvertir a MP4 con cualquier editor (no se necesita `ffmpeg` en esta máquina para ese paso).

### 3.2 Recetas concretas pedidas

**Resaltar un país mientras los demás se atenúan** (sin `gghighlight`, no instalado):
```r
ggplot(dc, aes(Time, TFR, group = ISO3_code)) +
  geom_line(colour = "grey80", linewidth = .4, alpha = .5) +                       # todos, atenuados
  geom_line(data = dc[ISO3_code == "NER"], colour = "#E69F00", linewidth = 2)      # uno, resaltado
# Animado (cuando gganimate esté listo): variante con transition_states + enter_fade/exit_fade
# para que el resaltado "entre" un país a la vez, sincronizado con el guion.
```

**Anotación histórica que aparece en el año exacto** ("1994 genocide"):
- *Fotograma a fotograma (hoy):* condicional `if (yy >= 1994) annotate(...)` dentro del bucle (ya en §3.1).
- *Con `gganimate` (cuando esté instalado):* una capa `geom_text`/`geom_label` con una columna `show_time`
  y `transition_time(Time) + shadow_mark(past = TRUE, future = FALSE)` para que el texto aparezca y se quede
  fijo desde su año — más simple que el condicional manual.

**Zoom a una región del scatter:**
```r
# Estático (hoy): segunda gráfica con los mismos datos y coord_cartesian() acotado
p_zoom <- p_full + coord_cartesian(xlim = c(60, 85), ylim = c(0, 3)) +
  labs(subtitle = "Zoom: countries converging below replacement fertility")
# Animado (con gganimate + view_follow o con tweenr/transformr interpolando los límites):
# secuencia de 15-20 fotogramas con xlim/ylim interpolados linealmente entre el encuadre completo y el zoom.
```

**Línea que se "dibuja" (una ruta que avanza con el tiempo):**
```r
# Con gganimate (pendiente instalación):
ggplot(cs, aes(LEx, TFR, group = Location, colour = SDG)) +
  geom_path(linewidth = 1.3) + geom_point(size = 3) +
  transition_reveal(Time) + shadow_wake(wake_length = .15, alpha = FALSE)
# Hoy (fotogramas manuales): en cada iteración del bucle, filtrar `Time <= yy` y volver a dibujar
# la geom_path completa hasta ese año — exactamente lo que transition_reveal hace internamente.
```

**Mapa animado en el tiempo** (boceto, pendiente `sf`): mismo patrón de fotogramas por década + `transition_time`
o bucle manual, recoloreando `fill` por década; con `sf` instalado, `transition_states(Time, ...)` sobre el
objeto `sf` funciona igual que sobre cualquier `data.frame`.

**Flecha que apunta a un punto:**
```r
annotate("curve", x = 20, y = 6.5, xend = 13.5, yend = 6.25, curvature = .3,
         arrow = arrow(length = unit(8, "pt")), colour = "grey20")     # ya usado en §2.1, probado
```

**"Build" de una gráfica por capas sincronizable con el guion:** generar **N versiones de la misma gráfica**,
cada una con una capa adicional (ejes → puntos → línea de referencia → anotación → titular), exportarlas como
PNG numerados y dejar que el editor de vídeo las encadene con cortes/disolves cronometrados exactamente con
`data-fragment-index` del guion en `00_storyboard_diapositivas.md`. Es la técnica más barata de las siete y la
que mejor casa con la narración palabra por palabra, porque el tiempo de cada "build" lo controla el editor de
vídeo, no una duración de animación fija como en `gganimate`.

---

## 4. Diseño para vídeo 1920×1080

### 4.1 Tamaños y grosores mínimos (a 1920×1080, visto en pantalla de portátil o proyector)

| Elemento | Mínimo recomendado | Nota |
|---|---|---|
| Titular (mensaje, `plot.title`) | 44–56 px (`rel(1.5)` sobre `base_size = 28–32`) | Debe leerse en 1–2 segundos; es la frase, no el nombre de la variable |
| Subtítulo | 28–32 px | Unidades + periodo + corte metodológico (p. ej. "≥ 1 M habitantes") |
| Texto de ejes / leyenda | ≥ 24 px (`rel(0.85–0.9)` sobre `base_size = 28`) | Por debajo de ~20 px a 1920×1080 se pixela al comprimir a vídeo H.264 |
| Etiquetas directas sobre líneas | ≥ 22 px, `fontface = "bold"` para el país resaltado | Sustituyen leyenda cuando hay ≤ 8 series (regla ya fijada en el storyboard) |
| Pie de página / fuente | 16–18 px | Una sola línea, esquina inferior izquierda, gris `#6E6E6E` |
| Grosor de línea — fondo (países no resaltados) | 0.3–0.5 pt, `alpha` 0.5–0.6 | Debe seguir siendo visible como "textura" pero no competir |
| Grosor de línea — resaltado | 1.6–2.2 pt | Diferencia de ≥ 4× respecto al fondo para que el ojo lo encuentre al instante |
| Grosor de línea de referencia (p. ej. reemplazo = 2.1) | 0.6–0.8 pt, discontinua | No debe competir con las series de datos |
| Puntos / marcadores | 3–5 pt (`size`), hasta 28 en `scale_size_area(max_size=28)` para burbujas de población | Los `size` de ggplot2 son mm de diámetro, no px — en 1920×1080 a 144 dpi, `size = 4` ≈ 20 px |
| Márgenes seguros | 64 px en los 4 bordes | Coincide con la regla ya fijada en el storyboard (§8) |

Patrón de exportación usado en todas las pruebas: `ragg::agg_png(width = 1920, height = 1080, units = "px", res = 144, background = "white")` — `ragg` renderiza fuentes de sistema (`Inter`/`Lato`, ambas instaladas y detectadas por `fc-list` en esta máquina) con mejor antialiasing que el dispositivo PNG por defecto.

### 4.2 Paletas accesibles con HEX fijos

**Por región SDG (8 colores, Okabe-Ito extendido — ya usado y probado en `test_plots.R`):**

| Región SDG | HEX |
|---|---|
| Sub-Saharan Africa | `#E69F00` |
| N. Africa & W. Asia | `#D55E00` |
| Central & S. Asia | `#CC79A7` |
| E. & SE. Asia | `#0072B2` |
| Latin America & Carib. | `#009E73` |
| Oceania (excl. AUS/NZ) | `#F0E442` |
| Australia & NZ | `#56B4E9` |
| Europe & N. America | `#000000` |

**Por grupo de ingreso del Banco Mundial (4 + "sin dato", secuencial divergente rojo→azul, distinguible de la paleta de regiones para no confundir ambas clasificaciones en una misma diapositiva):**

| Grupo de ingreso | HEX |
|---|---|
| Low income | `#B2182B` |
| Lower middle income | `#EF8A62` |
| Upper middle income | `#67A9CF` |
| High income | `#2166AC` |
| No data / aggregates | `#BDBDBD` |

**Semántica fija en todo el vídeo (no reutilizar estos 3 colores para otra cosa):**
`#009E73` verde = cambio natural / "nace", `#D55E00` bermellón = migración, `#000000`/gris = fondo no resaltado.

**Gris de fondo para spaghetti/líneas no resaltadas:** `#C8C8C8` (sobre fondo blanco, cumple contraste mínimo
para "textura", no para lectura de texto). **Gris de franja de proyección:** `grey92` al 60 % alpha.

Para los 4 tipos de "palanca" (P4, mapa de la Slide 1) y los 4 clústeres de trayectoria (P6, Slide 4), el
storyboard ya reserva paletas Okabe-Ito **distintas** entre sí y de las dos tablas de arriba — ver
`00_storyboard_diapositivas.md` §2 y `00_plan_analitico.md`. Confirmar antes de grabar que ningún color se
reutiliza con significado distinto entre diapositivas (regla de consistencia del vídeo completo).

### 4.3 Tema ggplot2 común (el mismo en las 14 gráficas de la sección 2)

```r
theme_wpp <- function(base_size = 20, base_family = "Inter") {
  theme_minimal(base_size = base_size, base_family = base_family) +
  theme(plot.title = element_text(face = "bold", size = rel(1.5), hjust = 0, margin = margin(b = 6)),
        plot.subtitle = element_text(size = rel(1.0), colour = "grey30", margin = margin(b = 14)),
        plot.caption = element_text(size = rel(0.7), colour = "grey45", hjust = 0, margin = margin(t = 10)),
        plot.title.position = "plot", plot.caption.position = "plot",
        panel.grid.minor = element_blank(), panel.grid.major = element_line(colour = "grey88", linewidth = .5),
        axis.title = element_text(size = rel(0.9), colour = "grey30"), axis.text = element_text(size = rel(0.85)),
        legend.position = "top", legend.title = element_blank(), legend.text = element_text(size = rel(0.9)),
        strip.text = element_text(face = "bold", size = rel(0.95), hjust = 0),
        plot.background = element_rect(fill = "white", colour = NA),
        plot.margin = margin(24, 32, 18, 24))
}
```
(Usado literalmente en las 12 pruebas renderizadas del scratchpad — reutilizable tal cual en `R/figuras_estaticas.R`.)

### 4.4 Titulares como mensaje, no como nombre de variable

Cada gráfica lleva un `plot.title` que es la conclusión en una frase, no "TFR by region" — ya aplicado en las
12 pruebas: *"In Europe & N. America, migration (not births) keeps population growing"*,
*"Every country walks the same road: longer lives, fewer births"*,
*"One axis explains 64.3 % of the differences between countries"*,
*"A composite index is coherent — but the design choices move countries"*. El `subtitle` lleva la ficha
técnica (unidades, periodo, corte de muestra) para que el titular quede limpio.

### 4.5 Pie de fuente estándar

```
Source: UN World Population Prospects 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024
```
(ya usado como `CAP` en las 12 pruebas; incluir el nombre completo "United Nations, DESA, Population Division"
en la diapositiva de referencias, no en cada pie — por espacio).

### 4.6 Cómo marcar estimación vs proyección

Patrón ya probado en 5 de las 12 gráficas: franja gris (`annotate("rect", xmin = 2023.5, xmax = Inf, fill =
"grey92", alpha = .6)`) + línea vertical discontinua en 2023.5 (`geom_vline(linetype = "22")`) + etiqueta
"projection →" en gris. Para series por década o por país que no cruzan 2024 en pantalla (p. ej. el slope
chart 1950→2023→2100), basta con que la categoría "2100" vaya en una tipografía o un marcador distinto
(hueco vs relleno) — aplicarlo de forma consistente en toda gráfica que mezcle estimación y proyección.

### 4.7 Buenas prácticas éticas de visualización (ASA Ethical Guidelines 2022)

- **Ejes que empiezan en 0** cuando el área/longitud de la barra representa la magnitud (barras, barras
  apiladas); los ejes pueden recortarse en líneas/dispersión donde la posición, no el área, es lo que se lee —
  pero entonces decirlo en el subtítulo si el recorte es grande.
- **Nunca truncar para exagerar una pendiente**: el crecimiento de High income en el P7-3 de arriba usa el
  mismo rango de eje y en los 4 paneles de ingreso, no un eje por panel — así la comparación entre paneles es
  honesta.
- **Incertidumbre visible**: el fan chart (§2.5) y la franja gris de proyección (§4.6) son las dos formas ya
  adoptadas; evitar presentar 2024–2100 con la misma línea sólida que 1950–2023.
- **País vs agregado**: cuando se muestra un agregado regional (p. ej. "Sub-Saharan Africa" en el biplot o el
  slope chart), decirlo explícitamente en el eje/leyenda — nunca mezclar un punto-país con un punto-agregado
  sin diferenciarlos visualmente (forma o relleno distinto).
- **Mapas que no estigmatizan**: evitar un solo color intenso (p. ej. rojo) cubriendo un continente entero sin
  contexto de incertidumbre — lección explícita de QuantaQuartet 2025 (§5 más abajo); usar paletas categóricas
  con significado ("crece por nacimientos" / "crece solo por migración"), no una escala secuencial roja que
  se lee como "problema".
- **Microestados**: marcarlos aparte (franja separada o símbolo distinto) en vez de dejarlos distorsionar
  rankings o correlaciones — ya decidido en `00_plan_analitico.md` (`umbral ≥ 1 000 000 habitantes`).
- **Lenguaje de la anotación**: verbos descriptivos ("crece", "diverge"), no causales ("reduce", "causa") —
  regla ya fijada en el storyboard para el texto; aplica igual a los titulares de las gráficas.

---

## 5. Lecciones visuales de los ganadores 2025 y 5 ideas para superarlos

### 5.1 Lo que hicieron bien (resumen visual, de `docs/01_analisis_ganadores_2025.md`)

**TRITICS (Indonesia, ganador internacional Best Data Visualization):** banderas circulares como identificador
universal de país (portada, eje x de barras, chips de la matriz de política); un solo mapa coroplético, en el
momento clave, con leyenda formulada como pregunta y titular que interpreta el resultado; cada gráfica tiene
un titular-hallazgo propio; animación de **entradas progresivas** (iconos, filas de tabla, barridos) — pero
**ningún eje que se mueva, ningún dato que se re-dibuje**: la propia síntesis del repo lo dice explícitamente,
*"No hay gráficos animados 'de datos' (ningún eje que se mueve); la animación señala, no analiza."*

**QuantaQuartet (Türkiye, 2.º en Data Visualization, 1.º en Statistical Insight):** mapa coroplético de
cobertura de datos **en la primera diapositiva** (ética visible desde el inicio), violines por grupo de
ingreso con nombres evocadores, mapa de clústeres con cajas de estadísticas embebidas dentro de la propia
figura. Debilidades marcadas en el análisis: mapa rojo intenso (`YlOrRd`) sobre África sin contexto de
incertidumbre (riesgo de estigmatización), heatmap de p-valores post-hoc (estadísticamente cuestionable),
texto denso y capturas de consola en pantalla.

### 5.2 Cinco ideas concretas para superarlos en la categoría de visualización

1. **Animar los datos de verdad, no solo la interfaz.** Es la brecha más clara que dejan ambos ganadores: su
   movimiento es de maquetación (iconos, barridos, filas que entran), nunca un eje o una curva que cambian con
   el tiempo. Un `transition_reveal()` que dibuja la trayectoria TFR↔LEx de un país en vivo (§2.1, §3.2) —o su
   equivalente manual por fotogramas, ya probado hoy— es, por sí solo, una pieza que ningún finalista 2025
   mostró. Úsese **una sola vez**, en el momento más memorable del vídeo (ya señalado como tal en el
   storyboard), para que no compita con el resto de la narración.
2. **Mapa sin estigmatizar: categorías con significado, no intensidad roja.** El mapa de "palancas" (P4, §1.2)
   y el de clústeres (P6, §1.2) usan 4–5 categorías Okabe-Ito con leyenda-pregunta — corrige directamente la
   debilidad marcada de QuantaQuartet (mapa rojo sin incertidumbre) y mantiene la fuerza de TRITICS (leyenda
   como pregunta, titular interpretativo), evitando el mismo error.
3. **Banderas siempre con código ISO3 o nombre corto al lado.** TRITICS asume que el jurado reconoce las
   banderas asiáticas sin texto — riesgo señalado explícitamente para un jurado internacional no asiático.
   Con `ggflags`/`flag-icons` ya disponibles (§2, "Banderas e iconos"), añadir `geom_text(label = ISO3_code)`
   junto a cada bandera cuesta una línea de código y elimina el riesgo por completo.
4. **La divergencia como forma, no como número.** Ni TRITICS ni QuantaQuartet usan un ridgeline o un fan chart
   para mostrar que una distribución se ensancha o se separa con el tiempo — ambos se quedan en mapas estáticos
   y violines de un solo corte temporal. El ridgeline de edad mediana (§2.11, ya probado con datos reales: de
   un pico estrecho en 1950 a una distribución ancha y bimodal en 2100) comunica "divergencia" — el hallazgo
   central de P1— sin que el jurado necesite entender qué es una desviación estándar.
5. **Mostrar la fragilidad metodológica como gráfica, no como nota al pie.** El bump chart de variantes del
   índice (§2.12, ya probado: Bielorrusia y Jordania cambian de posición entre las 3 definiciones mientras
   Níger y Japón quedan fijos) convierte un argumento típicamente textual ("los resultados dependen de los
   pesos elegidos") en una imagen de 3 segundos — ningún finalista 2025 visualizó la sensibilidad de su propio
   método; nosotros sí, y es coherente con el énfasis de las ASA Ethical Guidelines en declarar las decisiones
   de análisis.

---

## 6. Tabla resumen: pregunta → gráfica → animación → paquetes → dificultad → tiempo estimado

*Dificultad: Baja = reutiliza patrón ya probado con datos reales; Media = patrón nuevo con paquetes ya
instalados; Alta = requiere un paquete aún en instalación o ingeniería adicional (mapas, D3). Tiempo estimado
= trabajo de una persona familiarizada con el código ya escrito en el scratchpad, por gráfica individual
(no incluye iterar el guion ni grabar).*

| Pregunta | Gráfica | Animación sugerida | Paquetes | Dificultad | Tiempo est. |
|---|---|---|---|---|---|
| P7 | Connected scatterplot TFR↔LEx (§2.1) | `transition_reveal` + `shadow_wake` / fotogramas manuales (§3.2) | ggplot2, (gganimate) | Baja (estático) / Media (animado) | 1–2 h / +2 h anim. |
| P7, P4 | Barras apiladas divergentes (§2.2) | Entrada por región (fragmento reveal.js) | ggplot2, scales | Baja | 1 h |
| P7, P8, P1, P6 | Spaghetti con resaltado (§2.3) | `transition_states` por país resaltado | ggplot2, (ggrepel ya instalado) | Baja | 1 h |
| P1, P6 | Slope chart 1950→2023→2100 (§2.4) | Fragmentos: cada columna aparece por separado | ggplot2 | Baja | 1 h |
| P1, P7 | Fan chart de dispersión (§2.5) | Banda que se abre con `transition_reveal` sobre `Time` | ggplot2 | Baja | 1 h |
| P1, P6 | Heatmap país × año (§2.6) | Barrido de columna (año) resaltada | ggplot2, viridis | Baja | 1 h |
| P8 | Biplot de PCA (§2.7) | Aparición secuencial de ejes PC1 → PC2 (fragmentos) | stats (base), ggplot2 | Media (fijar set de variables) | 2 h |
| P8 | Matriz de correlación (§2.8) | Ninguna (estática, una sola vez en pantalla) | GGally | Baja | 0.5 h |
| P7, P4 | Pequeños múltiplos por ingreso (§2.9) | Línea que se dibuja por panel (`transition_reveal` + `facet_wrap`) | ggplot2 | Baja | 1 h |
| P7 (demo) | Burbujas animadas por año, fotogramas→GIF (§2.10) | Ya animado (ImageMagick), listo para re-renderizar con `gganimate` | ggplot2, ragg + ImageMagick CLI | Baja (ya probado) | 1 h |
| P1 | Ridgeline por año (§2.11) | Crestas que aparecen una a una (fragmentos o `transition_states`) | ggridges | Baja (ya probado) | 1 h |
| P5 | Bump chart de variantes del índice (§2.12) | Línea que se traza de izquierda a derecha | ggplot2 (o ggbump cuando esté listo) | Baja (ya probado) | 1–1.5 h |
| P4, P6 | Mapa coroplético mundial, Robinson (§2.13) | Zoom animado a Europa/Golfo (secuencia de `coord_sf`/`coord_map` interpolada) | maps+mapproj (hoy) → sf+rnaturalearth (pendiente) | Media hoy / Alta con zoom animado | 2–3 h (+2 h zoom) |
| P6 | Tile grid map por región SDG (§2.14) | Ninguna prioritaria | geofacet (pendiente) | Alta (prioridad baja) | 2 h si se usa |
| Todas | Tema y paletas comunes (§4) | — | ggplot2, ragg, sysfonts (Inter/Lato ya instalados) | Baja (ya escrito) | 0.5 h (una vez) |
| Interfaz/diapositivas | Fragmentos + auto-animate | `data-fragment-index` sincronizado con el guion | reveal.js (Quarto no instalado; HTML/CSS a mano viable) | Media | 3–4 h (una vez, para las 6 diapositivas) |

**Total aproximado de las 14 gráficas + tema + interfaz, en paralelo a lo que decida el equipo de
implementación:** del orden de 18–24 horas-persona si se construyen todas; priorizar según la tabla de
dificultad y lo que el guion final (`00_storyboard_diapositivas.md`) realmente necesite en pantalla — no las
14 tienen que usarse, el propio storyboard ya limita a "máximo 5–6 gráficas en todo el vídeo" (lección de
ganadores, §5.1 de `01_analisis_ganadores_2025.md`).
