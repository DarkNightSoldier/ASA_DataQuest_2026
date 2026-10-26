"""Comprobación de sincronía subtítulos ↔ fragmentos ↔ MP4 (agente captions-sync, 2026-10-25).

Recorre los 32 estados con las duraciones de slides/script/video_timings.json, igual que
video/record_slides.py (Reveal.slide(h, 0, f) con reloj absoluto), y comprueba:
 (1) ids y orden de window.deckSteps() == video_timings.json == captions.json;
     cada data-caption del HTML == unión " | " de los bloques de video_timings.json;
 (2) el subtítulo visible en cada cue (t + 0,35 s) == texto esperado (solo vale en tiempo real);
 (3) cada MP4 arranca desde ~0 al activarse su paso y ha terminado antes de salir de él,
     y su duración ≤ la del paso.
Uso:  $VENV/bin/python slides/dev/check_sync.py            # tiempo real (~4:55)
      $VENV/bin/python slides/dev/check_sync.py --fast 50  # solo (1) y arranque de vídeos
Resultado 2026-10-25 en tiempo real: 86 comprobaciones, 0 fallos."""
import json, sys, time, argparse
from pathlib import Path
REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "video"))
from deck_browser import H, W, deck_url, env_report, launch, serve, wait_ready
from playwright.sync_api import sync_playwright

ap = argparse.ArgumentParser(); ap.add_argument("--fast", type=float, default=1.0)
a = ap.parse_args()
T = json.loads((REPO / "slides/script/video_timings.json").read_text())
C = json.loads((REPO / "slides/script/captions.json").read_text())
cap_ids = []
for c in C:
    if not cap_ids or cap_ids[-1] != c["step"]: cap_ids.append(c["step"])
VID_JS = """id => { const el = document.querySelector('[data-step="'+id+'"]'); if (!el) return null;
  const vs = el.tagName === 'VIDEO' ? [el] : Array.from(el.querySelectorAll('video'));
  const v = vs.find(x => el.classList.contains('fragment') ? x.closest('.fragment') === el : !x.closest('.fragment')); if (!v) return null;
  return {paused: v.paused, t: v.currentTime, ended: v.ended, dur: v.duration, rs: v.readyState,
          src: (v.currentSrc||'').split('/').pop(), err: v.error ? v.error.code : null}; }"""
fails, log = [], []
with serve() as base, sync_playwright() as pw:
    b = launch(pw)
    print("browser:", b.version)
    pg = b.new_page(viewport={"width": W, "height": H}, device_scale_factor=1)
    cons = []
    pg.on("console", lambda m: cons.append(f"{m.type}: {m.text}"))
    pg.goto(deck_url(base, "record=1"))
    wait_ready(pg)
    rep = env_report(pg)
    ids = [s["id"] for s in rep["steps"]]
    tids = [s["id"] for s in T["steps"]]
    print("deckSteps:", len(ids), "· timings:", len(tids), "· captions.json pasos:", len(cap_ids))
    if ids != tids: fails.append(f"orden deck != timings: {[(i, x, y) for i, (x, y) in enumerate(zip(ids, tids)) if x != y]} len {len(ids)} vs {len(tids)}")
    cap_ids_full = [i for i in tids if i in cap_ids]
    if cap_ids != cap_ids_full: fails.append(f"orden captions.json != timings: {cap_ids} vs {cap_ids_full}")
    by = {s["id"]: s for s in rep["steps"]}
    # data-caption del HTML == unión de bloques de timings
    for s in T["steps"]:
        exp = " | ".join(c["text"] for c in s.get("captions", []))
        if by[s["id"]]["caption"] != exp: fails.append(f"data-caption {s['id']}: {by[s['id']]['caption']!r} != {exp!r}")
    print("slideTimings cargado:", pg.evaluate("!!(window.slideTimings && window.slideTimings.byId)"))
    pg.evaluate("Reveal.slide(0, 0, -1)"); pg.wait_for_timeout(300)
    k = a.fast
    t0 = time.monotonic(); cum = 0.0
    def wait_until(t_abs):
        r = t_abs - time.monotonic()
        if r > 0: pg.wait_for_timeout(int(r * 1000))
    for s in T["steps"]:
        st = by[s["id"]]
        start = t0 + cum / k
        wait_until(start)
        pg.evaluate(f"Reveal.slide({st['h']}, 0, {st['f']})")
        dur = s["duration"]
        checks = [(c["t"] + 0.35, "cap", c["text"]) for c in s.get("captions", [])]
        if not s.get("captions"): checks.append((0.35, "cap", ""))
        has_vid = pg.evaluate(VID_JS, s["id"]) is not None
        if has_vid:
            checks += [(0.6, "vstart", None), (dur - 0.12, "vend", None)]
        for tt, kind, exp in sorted(checks, key=lambda x: x[0]):
            wait_until(start + tt / k)
            if kind == "cap":
                got = pg.evaluate("document.querySelector('#caption-bar .caption-text').textContent")
                ok = got == exp
                log.append((s["id"], round(tt, 2), "cap", ok, got))
                if not ok: fails.append(f"{s['id']} @{tt:.2f}s caption {got!r} != {exp!r}")
            else:
                v = pg.evaluate(VID_JS, s["id"])
                log.append((s["id"], round(tt, 2), kind, v))
                if kind == "vstart" and (v["paused"] or v["t"] > 1.2 or v["err"]):
                    fails.append(f"{s['id']} vídeo no arrancó desde 0: {v}")
                if kind == "vend" and k == 1 and not (v["ended"] or abs(v["t"] - v["dur"]) < 0.1):
                    fails.append(f"{s['id']} vídeo sin terminar al salir del paso: {v} (paso {dur} s)")
                if kind == "vend" and v["dur"] and v["dur"] > dur:
                    fails.append(f"{s['id']} MP4 {v['dur']} s > paso {dur} s")
        cum += dur
    total = time.monotonic() - t0
    b.close()
print(f"recorrido: {total:.1f} s (factor {k}) · checks {len(log)}")
for row in log:
    if row[2] != "cap": print("  ", row)
errs = [c for c in cons if c.startswith(("error", "warning"))]
print("consola (errores/avisos):", errs[:10])
print("FALLOS:", len(fails))
for f in fails:
    print("  -", f)
sys.exit(1 if fails else 0)
