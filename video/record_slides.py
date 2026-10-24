"""Graba las diapositivas (reveal.js) a WebM 1920×1080 con Playwright + Chromium.

    python video/record_slides.py                       # usa slides/script/video_timings.json si existe
    python video/record_slides.py --default-step 4      # sin timings: 4 s por estado (build)
    python video/record_slides.py --timings slides/dev/video_timings.template.json
    python video/record_slides.py --max-steps 3 --default-step 1 --allow-demo --allow-unverified   # prueba rápida
    python video/record_slides.py --mp4                 # además: MP4 H.264 recortado (ffmpeg de imageio-ffmpeg)

Qué hace
  1. Sirve la raíz del repo con http.server en un puerto libre (../figures resuelve desde /slides/).
  2. Abre slides/index.html?record=1 (sin cursor) en Chromium 1920×1080 y espera a window.deckReady.
  3. Recorre los estados: video_timings.json → {"steps":[{"id":"s1.b2","duration":11.0,
     "captions":[{"t":0,"text":"..."}]}]} (los id son los data-step del HTML; ver
     window.deckSteps()). Sin archivo: todos los estados con --default-step segundos.
  4. Guarda video/raw/slides_<fecha>.webm + slides_<fecha>_steps.json (instante real de cada
     estado, lead-in a recortar antes del primer estado).
Seguridad de cifras: se niega a grabar si numbers.json es DEMO o hay claves sin verificar o
sin valor (QA-stats bloquea la grabación), salvo --allow-demo / --allow-unverified (que
además ocultan los marcadores de QA con ?qa=off).
"""
from __future__ import annotations

import argparse
import datetime as dt
import json
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from deck_browser import REPO, H, W, deck_url, env_report, launch, serve, wait_ready  # noqa: E402

TIMINGS = REPO / "slides" / "script" / "video_timings.json"
RAW = REPO / "video" / "raw"


def load_timings(path: Path | None):
    if path and path.exists():
        t = json.loads(path.read_text(encoding="utf-8"))
        return t.get("steps", []), t
    return None, None


def resolve_steps(deck_steps: list[dict], timed: list[dict] | None, default_s: float) -> list[dict]:
    by_id = {s["id"]: s for s in deck_steps}
    if timed is None:
        return [dict(s, duration=default_s) for s in deck_steps]
    out = []
    for t in timed:
        sid = t.get("id")
        if sid not in by_id:
            raise SystemExit(f"[record] el paso '{sid}' de video_timings.json no existe en el deck "
                             f"(ids válidos: {', '.join(by_id)})")
        out.append(dict(by_id[sid], duration=float(t.get("duration", default_s))))
    return out


def to_mp4(webm: Path, lead_in: float) -> Path | None:
    try:
        import imageio_ffmpeg
        ff = imageio_ffmpeg.get_ffmpeg_exe()
    except Exception:
        ff = shutil.which("ffmpeg")
    if not ff:
        print("[record] sin ffmpeg (imageio-ffmpeg); se omite el MP4", file=sys.stderr)
        return None
    mp4 = webm.with_suffix(".mp4")
    cmd = [ff, "-y", "-loglevel", "error", "-ss", f"{lead_in:.3f}", "-i", str(webm),
           "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18", "-preset", "medium",
           "-r", "30", "-movflags", "+faststart", str(mp4)]
    subprocess.run(cmd, check=True)
    return mp4


def main() -> int:
    ap = argparse.ArgumentParser(description="Graba slides/index.html a WebM 1920×1080")
    ap.add_argument("--timings", default=None, help="JSON de tiempos (por defecto slides/script/video_timings.json si existe)")
    ap.add_argument("--default-step", type=float, default=4.0, help="segundos por estado si no hay timings")
    ap.add_argument("--max-steps", type=int, default=0, help="grabar solo los N primeros estados (prueba)")
    ap.add_argument("--query", default="", help="parámetros extra de la URL (p. ej. captions=off)")
    ap.add_argument("--allow-demo", action="store_true", help="permitir cifras DEMO (solo pruebas)")
    ap.add_argument("--allow-unverified", action="store_true", help="permitir claves sin verificar / sin valor")
    ap.add_argument("--mp4", action="store_true", help="además, MP4 H.264 sin el lead-in")
    ap.add_argument("--headed", action="store_true", help="ventana visible (depuración)")
    a = ap.parse_args()

    tpath = Path(a.timings) if a.timings else (TIMINGS if TIMINGS.exists() else None)
    timed, tmeta = load_timings(tpath)
    if tpath and timed is None:
        print(f"[record] no existe {tpath}", file=sys.stderr)
        return 2
    RAW.mkdir(parents=True, exist_ok=True)
    stamp = dt.datetime.now().strftime("%Y%m%d_%H%M%S")
    query = "record=1" + ("&qa=off" if (a.allow_unverified or a.allow_demo) else "") + (("&" + a.query) if a.query else "")

    from playwright.sync_api import sync_playwright
    tmp = Path(tempfile.mkdtemp(prefix="rec_", dir=str(RAW)))
    log = []
    with serve() as base, sync_playwright() as pw:
        b = launch(pw, headless=not a.headed)
        ctx = b.new_context(viewport={"width": W, "height": H}, device_scale_factor=1,
                            record_video_dir=str(tmp), record_video_size={"width": W, "height": H})
        t_page = time.monotonic()
        pg = ctx.new_page()
        pg.goto(deck_url(base, query))
        wait_ready(pg)
        rep = env_report(pg)
        nrep = rep["numbers"] or {}
        problems = []
        if "demo" in (rep["source"] or "") and not a.allow_demo:
            problems.append("las cifras vienen de dev/numbers_demo.json (DEMO)")
        if nrep.get("missingKeys") and not a.allow_unverified:
            problems.append(f"{len(nrep['missingKeys'])} claves sin valor: {', '.join(nrep['missingKeys'][:12])}…")
        if nrep.get("unverifiedKeys") and not a.allow_unverified:
            problems.append(f"{len(nrep['unverifiedKeys'])} claves sin verificar (QA-stats)")
        missing_figs = (rep["figs"] or {}).get("missing", [])
        if missing_figs:
            print(f"[record] AVISO: {len(missing_figs)} figuras ausentes (se graban marcadores): {', '.join(missing_figs)}")
        if problems:
            ctx.close(); b.close(); shutil.rmtree(tmp, ignore_errors=True)
            print("[record] NO se graba:\n  - " + "\n  - ".join(problems) +
                  "\n  (use --allow-demo / --allow-unverified solo para pruebas)", file=sys.stderr)
            return 3

        steps = resolve_steps(rep["steps"], timed, a.default_step)
        if a.max_steps:
            steps = steps[: a.max_steps]
        # la página reparte los bloques de subtítulo con las mismas duraciones que se graban
        caps = {t["id"]: t["captions"] for t in (timed or []) if t.get("id") and t.get("captions")}
        page_timings = {"steps": []}
        for s in steps:
            item = {"id": s["id"], "duration": s["duration"]}
            if s["id"] in caps:
                item["captions"] = caps[s["id"]]
            page_timings["steps"].append(item)
        pg.evaluate("""t => { t.byId = {}; t.steps.forEach(s => { t.byId[s.id] = s; }); window.slideTimings = t; }""",
                    page_timings)
        pg.evaluate("Reveal.slide(0, 0, -1)")
        pg.wait_for_timeout(300)
        t0 = time.monotonic()
        cum = 0.0
        for s in steps:
            t_start = time.monotonic() - t_page
            pg.evaluate(f"Reveal.slide({s['h']}, 0, {s['f']})")
            log.append({"id": s["id"], "h": s["h"], "f": s["f"], "t_video_s": round(t_start, 3),
                        "t_deck_s": round(cum, 3), "duration_s": s["duration"]})
            cum += s["duration"]
            # reloj absoluto: sin deriva acumulada por la latencia de cada evaluate()
            remaining = (t0 + cum) - time.monotonic()
            if remaining > 0:
                pg.wait_for_timeout(int(remaining * 1000))
        total = time.monotonic() - t0
        lead_in = log[0]["t_video_s"] if log else 0.0
        pg.wait_for_timeout(400)
        vid = pg.video
        ctx.close()
        src = Path(vid.path())
        b.close()

    out = RAW / f"slides_{stamp}.webm"
    shutil.move(str(src), out)
    shutil.rmtree(tmp, ignore_errors=True)
    meta = {"video": out.name, "timings_file": str(tpath) if tpath else None, "default_step_s": a.default_step,
            "lead_in_s": lead_in, "deck_duration_s": round(total, 3), "steps": log,
            "numbers_source": rep["source"], "missing_figures": missing_figs}
    (RAW / f"slides_{stamp}_steps.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n")
    print(f"[record] {out} · {len(log)} estados · {total:.1f} s de deck (+{lead_in:.1f} s de lead-in)")
    if total > 300:
        print("[record] AVISO: el deck dura más de 5:00", file=sys.stderr)
    if a.mp4:
        mp4 = to_mp4(out, lead_in)
        if mp4:
            print(f"[record] MP4 recortado: {mp4}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
