"""Graba las diapositivas (reveal.js) a WebM 1920×1080 con Playwright + Chromium.

    python video/record_slides.py                       # usa slides/script/video_timings.json si existe
    python video/record_slides.py --default-step 4      # sin timings: 4 s por estado (build)
    python video/record_slides.py --timings slides/dev/video_timings.template.json
    python video/record_slides.py --max-steps 3 --default-step 1 --allow-demo --allow-unverified   # prueba rápida
    python video/record_slides.py --mp4                 # además: video/deck_silent.mp4 (H.264 30 fps, recortado)
    python video/record_slides.py --convert video/raw/slides_<fecha>.webm   # solo convertir una grabación

Qué hace
  1. Sirve la raíz del repo con http.server en un puerto libre (../figures resuelve desde /slides/).
  2. Abre slides/index.html?record=1 (sin cursor) en Chromium 1920×1080 y espera a window.deckReady.
  3. Recorre los estados: video_timings.json → {"steps":[{"id":"s1.b2","duration":11.0,
     "captions":[{"t":0,"text":"..."}]}]} (los id son los data-step del HTML; ver
     window.deckSteps()). Sin archivo: todos los estados con --default-step segundos.
  4. Antes del primer estado: congela el contador de la portada en 2.5 / 1950 y pinta un destello
     magenta de sincronía; en el primer estado relanza el contador (2.5 → 8.1, como en el storyboard).
  5. Guarda video/raw/slides_<fecha>.webm + slides_<fecha>_steps.json (instante real de cada
     estado y lead-in a recortar, calibrado con el destello: error ≤ 1 fotograma = 40 ms).
  6. Con --mp4 (o luego con --convert): video/deck_silent.mp4, H.264 1920×1080 30 fps sin audio,
     recortado al lead-in y a la duración del deck (las grabaciones de prueba —otros timings,
     --max-steps, --allow-*— van a video/raw/slides_<fecha>.mp4 y no pisan deck_silent.mp4).
     Siguiente paso (voz + ensamblaje): video/README.md y video/assemble.sh.
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


DECK_SILENT = REPO / "video" / "deck_silent.mp4"

# --- sincronía: destello magenta a pantalla completa antes del primer estado -------------------
# El vídeo de Playwright no empieza exactamente al crear la página (≈ 0,3 s de retraso medido el
# 2026-10-26), así que el lead-in "nominal" (reloj de Python) adelanta todos los cambios. Se pinta
# un recuadro magenta, se quita en t_off (reloj de Python) y se busca en el WebM el primer
# fotograma sin magenta (v_off). Cada estado aparece en el vídeo en v_off + (t_estado − t_off).
SYNC_ON_JS = """() => { const d = document.createElement('div'); d.id = 'rec-sync';
  d.style.cssText = 'position:fixed;left:0;top:0;width:100vw;height:100vh;z-index:2147483647;background:#ff00ff';
  document.body.appendChild(d); }"""
SYNC_OFF_JS = """() => { const d = document.getElementById('rec-sync'); if (d) d.remove(); }"""

# Contador de la portada (init.js: 2.5 → 8.1 mil millones, 1950 → 2023, 3,6 s). Arranca con
# deckReady, varios segundos antes del primer estado, así que el vídeo empezaba a mitad de cuenta
# (6.9 · 2007). Se congela en su valor inicial durante el lead-in y se relanza en el primer estado
# con un 'slidechanged' sintético (init.js → maybeCounter(); captions.js → update()).
COUNTER_FREEZE_JS = """() => {
  const el = document.querySelector('.cover .counter[data-count-to]');
  const yr = document.querySelector('.cover .counter-year');
  if (!el || !window.DeckNumbers) return false;
  const from = parseFloat(el.getAttribute('data-count-from'));
  if (isNaN(from)) return false;
  el.textContent = DeckNumbers.formatNumber(from, el.getAttribute('data-fmt') || '1');
  if (yr) yr.textContent = yr.getAttribute('data-year-from') || '1950';
  return true; }"""
COUNTER_RESTART_JS = """() => {
  const cur = Reveal.getCurrentSlide();
  if (!cur || !cur.classList.contains('cover')) return false;
  const ev = new Event('slidechanged', { bubbles: true });
  Object.assign(ev, { previousSlide: null, currentSlide: cur, indexh: 0, indexv: 0 });
  Reveal.getRevealElement().dispatchEvent(ev);
  return true; }"""


def find_sync_off(webm: Path, search_s: float) -> float | None:
    """Instante (s, reloj del WebM) del primer fotograma sin el destello magenta, o None."""
    ff = ffmpeg_exe()
    if not ff:
        return None
    r = subprocess.run([ff, "-hide_banner", "-nostats", "-t", f"{search_s:.3f}", "-i", str(webm),
                        "-vf", "scale=64:36,format=yuv420p,showinfo", "-f", "null", "-"],
                       capture_output=True, text=True)
    seen = False
    for line in r.stderr.splitlines():
        if "pts_time:" not in line or "mean:[" not in line:
            continue
        try:
            t = float(line.split("pts_time:")[1].split()[0])
            y, u, v = (float(x) for x in line.split("mean:[")[1].split("]")[0].split()[:3])
        except (ValueError, IndexError):
            continue
        magenta = u > 170 and v > 170          # magenta en YUV ≈ (105, 212, 234); fondo blanco ≈ (235, 128, 128)
        if magenta:
            seen = True
        elif seen:
            return t
    return None


def ffmpeg_exe() -> str | None:
    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except Exception:
        return shutil.which("ffmpeg")


def to_mp4(webm: Path, lead_in: float, duration: float | None = None, out: Path | None = None) -> Path | None:
    """WebM → MP4 H.264 1920×1080 a 30 fps constantes, sin audio, sin el lead-in y recortado a la
    duración del deck (video/deck_silent.mp4 por defecto). ffmpeg de imageio-ffmpeg (venv)."""
    ff = ffmpeg_exe()
    if not ff:
        print("[record] sin ffmpeg (imageio-ffmpeg); se omite el MP4", file=sys.stderr)
        return None
    mp4 = out or DECK_SILENT
    mp4.parent.mkdir(parents=True, exist_ok=True)
    cmd = [ff, "-hide_banner", "-y", "-loglevel", "error", "-ss", f"{lead_in:.3f}", "-i", str(webm)]
    if duration:
        cmd += ["-t", f"{duration:.3f}"]
    cmd += ["-an", "-vf", f"fps=30,scale={W}:{H}:flags=lanczos,setsar=1",
            "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "16", "-preset", "slow",
            "-profile:v", "high", "-g", "60",
            "-movflags", "+faststart", str(mp4)]
    subprocess.run(cmd, check=True)
    return mp4


def convert_existing(webm: Path, out: Path | None = None) -> int:
    """Convierte una grabación ya hecha usando su _steps.json (lead-in y duración del deck)."""
    meta_p = webm.with_name(webm.stem + "_steps.json")
    if not meta_p.exists():
        print(f"[record] falta {meta_p}", file=sys.stderr)
        return 2
    meta = json.loads(meta_p.read_text(encoding="utf-8"))
    mp4 = to_mp4(webm, meta["lead_in_s"], meta.get("deck_duration_s"), out)
    if mp4:
        print(f"[record] MP4: {mp4}  (lead-in {meta['lead_in_s']:.3f} s recortado; {meta.get('deck_duration_s')} s)")
    return 0 if mp4 else 2


def main() -> int:
    ap = argparse.ArgumentParser(description="Graba slides/index.html a WebM 1920×1080")
    ap.add_argument("--timings", default=None, help="JSON de tiempos (por defecto slides/script/video_timings.json si existe)")
    ap.add_argument("--default-step", type=float, default=4.0, help="segundos por estado si no hay timings")
    ap.add_argument("--max-steps", type=int, default=0, help="grabar solo los N primeros estados (prueba)")
    ap.add_argument("--query", default="", help="parámetros extra de la URL (p. ej. captions=off)")
    ap.add_argument("--allow-demo", action="store_true", help="permitir cifras DEMO (solo pruebas)")
    ap.add_argument("--allow-unverified", action="store_true", help="permitir claves sin verificar / sin valor")
    ap.add_argument("--mp4", action="store_true", help="además, MP4 H.264 30 fps sin el lead-in: video/deck_silent.mp4 si es una "
                    "grabación oficial completa; si es una prueba, video/raw/slides_<fecha>.mp4")
    ap.add_argument("--mp4-out", default=None, help="ruta del MP4 (por defecto video/deck_silent.mp4)")
    ap.add_argument("--convert", default=None, metavar="WEBM", help="no graba: convierte a MP4 una grabación de video/raw/ ya hecha")
    ap.add_argument("--headed", action="store_true", help="ventana visible (depuración)")
    a = ap.parse_args()
    if a.convert:
        return convert_existing(Path(a.convert), Path(a.mp4_out) if a.mp4_out else None)

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
        pg.wait_for_timeout(3200)                    # deja terminar el contador lanzado con deckReady (3,6 s)
        froze = pg.evaluate(COUNTER_FREEZE_JS)
        pg.wait_for_timeout(300)
        # destello de sincronía (queda dentro del lead-in, que se recorta)
        pg.evaluate(SYNC_ON_JS)
        pg.wait_for_timeout(600)
        t_sync_off = time.monotonic() - t_page
        pg.evaluate(SYNC_OFF_JS)
        pg.wait_for_timeout(800)
        t0 = time.monotonic()
        cum = 0.0
        for i, s in enumerate(steps):
            t_start = time.monotonic() - t_page
            pg.evaluate(f"Reveal.slide({s['h']}, 0, {s['f']})")
            if i == 0 and froze and s["h"] == 0 and s["f"] == -1:
                pg.evaluate(COUNTER_RESTART_JS)      # el contador 2.5 → 8.1 empieza con el vídeo
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
    # lead-in calibrado con el destello: v_off (vídeo) ↔ t_sync_off (reloj de Python)
    lead_nominal = lead_in
    v_off = find_sync_off(out, t_sync_off + 5.0)
    if v_off is not None:
        lead_in = round(v_off + (lead_nominal - t_sync_off), 3)
        print(f"[record] sincronía: destello fuera en {v_off:.3f} s del WebM (reloj {t_sync_off:.3f} s) → "
              f"lead-in {lead_in:.3f} s (nominal {lead_nominal:.3f} s; corrección {lead_in - lead_nominal:+.3f} s)")
    else:
        print("[record] AVISO: no se encontró el destello de sincronía; se usa el lead-in nominal", file=sys.stderr)
    meta = {"video": out.name, "timings_file": str(tpath) if tpath else None, "default_step_s": a.default_step,
            "lead_in_s": lead_in, "lead_in_nominal_s": lead_nominal,
            "sync": {"t_clock_off_s": round(t_sync_off, 3), "t_video_off_s": v_off},
            "deck_duration_s": round(total, 3), "steps": log,
            "numbers_source": rep["source"], "missing_figures": missing_figs}
    (RAW / f"slides_{stamp}_steps.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False) + "\n")
    print(f"[record] {out} · {len(log)} estados · {total:.1f} s de deck (+{lead_in:.1f} s de lead-in)")
    if total > 300:
        print("[record] AVISO: el deck dura más de 5:00", file=sys.stderr)
    if a.mp4:
        # solo una grabación completa, con los tiempos oficiales y cifras verificadas, pisa
        # video/deck_silent.mp4; las pruebas (--timings otro, --max-steps, --allow-*) van a video/raw/
        official = (tpath is not None and tpath.resolve() == TIMINGS.resolve() and not a.max_steps
                    and not a.allow_demo and not a.allow_unverified and not a.query)
        target = Path(a.mp4_out) if a.mp4_out else (DECK_SILENT if official else out.with_suffix(".mp4"))
        mp4 = to_mp4(out, lead_in, round(total, 3), target)
        if mp4:
            print(f"[record] MP4 recortado: {mp4}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
