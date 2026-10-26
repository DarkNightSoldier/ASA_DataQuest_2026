"""Prueba visual del deck: capturas 1920×1080 de cada diapositiva y de cada paso + ranuras de figura.

Uso (venv con Playwright):
    python slides/dev/screenshots.py            # finales + todos los pasos
    python slides/dev/screenshots.py --finals   # solo el estado final de cada diapositiva

Salidas:
    slides/dev/screenshots/slide_<h>_final.png   estado final de cada diapositiva (S4: build 4; el
                                                 callback va aparte en slide_4_callback.png)
    slides/dev/screenshots/steps/<id>.png        cada estado (build) del vídeo
    slides/dev/figure_slots.json                 tamaño (px) de la ranura de cada figura:
                                                 intro (paso en que aparece), final (último paso del
                                                 vídeo) y print (página del PDF) → contrato con figures-static
    slides/dev/deck_report.json                  claves sin valor, figuras ausentes, pasos, consola
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "video"))
from deck_browser import REPO, H, W, deck_url, env_report, launch, serve, wait_ready  # noqa: E402

from playwright.sync_api import sync_playwright  # noqa: E402

OUT = REPO / "slides" / "dev" / "screenshots"
FINAL_STATE = {4: "s4.b4"}  # en la S4 el último paso es el callback (se fotografía aparte)


def goto(page, h: int, f: int, settle_ms: int = 1500):
    page.evaluate(f"Reveal.slide({h}, 0, {f})")
    page.wait_for_timeout(settle_ms)


# QA-slides M10 / QA-viz V22: en los pasos con MP4, la captura se toma cuando el vídeo ha terminado
# (estado final del build), no a 1,7 s con la animación a medias.
VID_LEFT_JS = """id => { const el = document.querySelector('[data-step="' + id + '"]'); if (!el) return 0;
  const vs = (el.tagName === 'VIDEO' ? [el] : Array.from(el.querySelectorAll('video')))
    .filter(v => !v.paused && !v.ended);
  let r = 0; vs.forEach(v => { if (isFinite(v.duration)) r = Math.max(r, v.duration - v.currentTime); });
  return r; }"""


def wait_video_end(page, step_id: str, extra_ms: int = 450) -> float:
    left = page.evaluate(VID_LEFT_JS, step_id) or 0
    if left > 0:
        page.wait_for_timeout(int(left * 1000) + extra_ms)
    return left


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--finals", action="store_true", help="no guardar la captura de cada paso")
    ap.add_argument("--query", default="", help="query extra, p. ej. qa=off")
    a = ap.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "steps").mkdir(exist_ok=True)
    console = []
    slots: dict[str, dict] = {}
    with serve() as base, sync_playwright() as pw:
        b = launch(pw)
        pg = b.new_page(viewport={"width": W, "height": H}, device_scale_factor=1)
        pg.on("console", lambda m: console.append(f"{m.type}: {m.text}")
              if m.type in ("error", "warning") and "Failed to load resource" not in m.text else None)
        pg.on("pageerror", lambda e: console.append(f"pageerror: {e}"))
        pg.goto(deck_url(base, a.query))
        wait_ready(pg)
        rep = env_report(pg)
        steps = rep["steps"]

        # 1) todos los pasos: ranuras (intro/final) y capturas
        for s in steps:
            goto(pg, s["h"], s["f"], 1700)
            wait_video_end(pg, s["id"])
            for name, v in pg.evaluate("DeckFigs.slots()").items():
                if v["slide"] != s["h"] or not v["visible"] or v["w"] <= 0 or v["h"] <= 0:
                    continue
                rec = slots.setdefault(name, {"slide": s["h"]})
                cur = {"step": s["id"], "w": v["w"], "h": v["h"], "aspect": v["aspect"]}
                rec.setdefault("intro", cur)
                rec["final"] = cur
            if not a.finals:
                pg.screenshot(path=str(OUT / "steps" / f"{s['id']}.png"))

        # 2) estado final de cada diapositiva
        by_slide: dict[int, list] = {}
        for s in steps:
            by_slide.setdefault(s["h"], []).append(s)
        for h, st in sorted(by_slide.items()):
            last = max(s["f"] for s in st)
            fin_id = FINAL_STATE.get(h)
            f_fin = next((s["f"] for s in st if s["id"] == fin_id), last) if fin_id else last
            goto(pg, h, f_fin, 2600)
            pg.screenshot(path=str(OUT / f"slide_{h}_final.png"))
            if f_fin != last:
                goto(pg, h, last, 1800)
                pg.screenshot(path=str(OUT / f"slide_{h}_callback.png"))
        rep = env_report(pg)

        # 3) ranuras en la versión PDF
        pp = b.new_page(viewport={"width": W, "height": H}, device_scale_factor=1)
        pp.goto(deck_url(base, "print-pdf" + ("&" + a.query if a.query else "")))
        wait_ready(pp, print_mode=True)
        pp.wait_for_timeout(1200)
        for name, v in pp.evaluate("DeckFigs.slots()").items():
            if v["w"] > 0 and v["h"] > 0 and v["visible"]:
                slots.setdefault(name, {"slide": v["slide"]})["print"] = {"w": v["w"], "h": v["h"], "aspect": v["aspect"]}
        b.close()

    (REPO / "slides" / "dev" / "figure_slots.json").write_text(json.dumps(slots, indent=2, ensure_ascii=False) + "\n")
    report = {"numbers_source": rep["source"],
              "missing_keys": (rep["numbers"] or {}).get("missingKeys", []),
              "unverified_keys": (rep["numbers"] or {}).get("unverifiedKeys", []),
              "figures": rep["figs"], "n_steps": len(rep["steps"]),
              "steps": [{k: s[k] for k in ("id", "h", "f", "build")} for s in rep["steps"]],
              "console": console}
    (REPO / "slides" / "dev" / "deck_report.json").write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n")
    print(f"capturas en {OUT} · {len(rep['steps'])} pasos · fuente de cifras: {rep['source']}")
    print("claves sin valor:", len(report["missing_keys"]), "· figuras ausentes:", len((rep["figs"] or {}).get("missing", [])))
    for name, v in slots.items():
        fmt = lambda d: f"{d['w']}×{d['h']}" if d else "—"  # noqa: E731
        print(f"  {name:36s} intro {fmt(v.get('intro')):>10s} ({(v.get('intro') or {}).get('step', '')})"
              f"  final {fmt(v.get('final')):>10s}  print {fmt(v.get('print')):>10s}")
    if console:
        print("consola:", *console[:15], sep="\n  ")


if __name__ == "__main__":
    main()
