# Diapositivas (`slides/`)

Diapositivas en **reveal.js** (HTML directo, sin Quarto) para la presentación del
ASA International DataQuest 2026. Ver `docs/00_plan_implementacion.md` §5 para
la justificación de esta ruta y §6/§7.6 para las convenciones de diseño.

## Instalación (dependencias vendorizadas, no se versionan)

`node_modules/` está en `.gitignore`. Para recrearlo:

```bash
cd slides
npm install        # instala reveal.js y flag-icons según package.json
```

Versiones instaladas y verificadas el 2026-10-22: `reveal.js@6.0.2`,
`flag-icons@7.6.0` (Node v24.19.0, npm 11.19.0).

## Estructura esperada (la rellenan los agentes de diapositivas/guion)

- `index.html` — 6 `<section>`: portada + 4 de contenido + referencias.
- `css/theme_wpp.css` — tema con la tipografía Lato y la paleta de `R/config.R`.
- `js/numbers.js` — inyecta `figures/numbers.json` en `<span data-num="...">`.
- `js/captions.js` — subtítulos sincronizados por fragmento.
- `assets/` — banderas (`flag-icons`), iconos.
- `script/narration_en.md`, `script/captions.srt` — guion y subtítulos.
- `export/` — `slides.pdf` generado con Chromium headless (`npm run pdf`, ver Makefile raíz).

## Exportar a PDF (referencia)

```bash
chromium --headless --no-sandbox --print-to-pdf=slides/export/slides.pdf \
  --no-pdf-header-footer "file://$(pwd)/slides/index.html?print-pdf"
```

## Grabación de vídeo (referencia)

Se usa Playwright (instalado en el venv de Python del scratchpad, no en este
`slides/`) controlando el Chromium del sistema (`/usr/bin/chromium`). Ver
`SETUP.md` para cómo recrear ese entorno.
