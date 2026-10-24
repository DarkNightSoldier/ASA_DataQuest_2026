# ASA International DataQuest 2026 — UN World Population Prospects 2024

Repositorio del equipo para el **ASA International DataQuest 2026**, basado en
los datos de *World Population Prospects 2024* (UN DESA, Population
Division). Entrega: vídeo de 5 minutos + diapositivas (portada + hasta 4 de
contenido + referencias), antes del último viernes de octubre de 2026.

## Equipo

**UNALSta-R** — Daniel C. Kwan, David S. Merchán, Jhon A. Mora y Alejandro Higuera.
Estudiantes de Estadística, Universidad Nacional de Colombia, sede Bogotá. Detalle y metadatos en `docs/equipo.md`.

## Objetivo

Responder, con datos de 237 países y 1950–2100, tres preguntas centrales (ver
`docs/00_plan_analitico.md`): qué "palanca" demográfica (nacimientos,
muertes o migración) mueve hoy a cada país y cómo varía por región e
ingreso; si un solo indicador puede contar la historia completa o hacen
falta varios leídos juntos; y si distintos países recorren el mismo camino
de la transición demográfica a distinta velocidad — con recomendaciones
concretas de qué vigilar, dónde y cuándo, para la ONU.

## Estructura del repositorio

```
RepoGithub/
├── R/
│   ├── config.R              # rutas, semilla, paletas accesibles, theme_wpp()
│   ├── 00_instalar_paquetes.R# instala (idempotente) los paquetes de R del proyecto
│   ├── 01_preparar_datos.R   # limpieza: países vs agregados, regiones, ingreso, columnas derivadas
│   ├── tests_datos.R         # pruebas automáticas sobre data/processed/
│   └── utilidades.R          # cargar_paises(), cargar_agregados(), etc.
├── data/
│   ├── raw/                  # archivos pequeños versionados + instrucciones de descarga
│   ├── processed/            # paises.parquet, agregados.parquet (no versionados) + lookup/diccionario (sí)
│   └── README.md             # fuente, licencia, decisiones de limpieza, sha256
├── notebook/                 # notebook Jupyter con kernel IRkernel (narrativa en español)
├── figures/                  # static/, animated/, appendix/, review/
├── slides/                   # diapositivas reveal.js (vendorizado con npm)
└── docs/                     # planes, hechos clave verificados, catálogo de referencia
```

## Cómo reproducir

```bash
# 1. Paquetes de R (idempotente: solo instala lo que falte)
Rscript R/00_instalar_paquetes.R

# 2. Datos limpios (lee los CSV crudos de la carpeta padre, ver data/raw/README.md)
Rscript R/01_preparar_datos.R

# 3. Verificación automática de los datos (falla si algo se rompe)
Rscript R/tests_datos.R
```

Ver `SETUP.md` para el detalle de dependencias del sistema, el entorno de
Python (venv) usado para ffmpeg/Playwright, y cómo ejecutar el notebook con
`jupyter nbconvert --execute`.

## Fuente y licencia

- **Datos:** United Nations, Department of Economic and Social Affairs,
  Population Division (2024). *World Population Prospects 2024, Online
  Edition*. <https://population.un.org/wpp/>. Licencia **CC BY 3.0 IGO**.
- **Grupos de ingreso:** World Bank Country and Lending Groups (clasificación
  FY2027, API descargado 2026-10-22).
- **Código de este repositorio:** licencia MIT. **Textos y figuras propias**
  (no los datos crudos de la ONU): CC BY 4.0.

Cita sugerida para cualquier cifra derivada de estos datos:

> United Nations, Department of Economic and Social Affairs, Population
> Division (2024). *World Population Prospects 2024, Online Edition*.

## Ética

Todo el trabajo estadístico de este proyecto sigue los **ASA Ethical
Guidelines for Statistical Practice (2022)**
(<https://www.amstat.org/your-career/ethical-guidelines-for-statistical-practice>):
integridad profesional y de datos, separación explícita entre lo
exploratorio/descriptivo y cualquier afirmación, lenguaje sin causalidad
("goes with", nunca "causes"/"drives"), migración y crisis humanitarias
citadas sin calificarlas de buenas o malas, estimaciones (<=2023) siempre
distinguidas de proyecciones (Medium, >=2024), y reproducibilidad completa
(semilla fija, `sessionInfo()`, este mismo README). Ver el detalle aplicado
en `docs/00_plan_analitico.md` §8 y `docs/04_etica_ASA_aplicada.md`.
