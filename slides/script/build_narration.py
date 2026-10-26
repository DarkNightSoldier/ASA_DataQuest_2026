#!/usr/bin/env python3
"""Guion final del vídeo: plantilla con {claves} → narración, subtítulos y tiempos.

    python slides/script/build_narration.py            # escribe los 5 productos
    python slides/script/build_narration.py --check    # solo valida y muestra el resumen

Entrada
  slides/script/narration_en_template.md   (fuente única; "## <diapositiva>", "### <data-step>",
                                            una frase por línea "> …"; " | " parte bloques de subtítulo)
  figures/numbers.json                     (solo claves con "verified": true; ver fill_numbers.py)
  slides/index.html                        (data-step, data-fragment-index, data-build, vídeos)
  figures/animated/*.mp4                   (duración con el ffmpeg de imageio-ffmpeg, si existe)
Salida
  slides/script/narration_en.md            narración palabra por palabra + tabla de tiempos
  slides/script/captions.json              lista de bloques de subtítulo (un objeto por bloque)
  slides/script/video_timings.json         formato de video/record_slides.py y slides/js/captions.js
  slides/script/captions.srt               SRT estándar (≤ 2 líneas por bloque)
  slides/script/data_captions.json         texto para los data-caption de slides/index.html

Modelo de tiempo (encargo script-narration, 2026-10-25)
  voz de un bloque = palabras habladas / 150 ppm + 1,5 s de aire por cifra hablada
  paso = 0,6 s de transición (todos menos el primero) + Σ voz de sus bloques
  paso con MP4 ≥ duración del MP4 + 0,3 s de margen (el vídeo arranca al mostrarse el fragmento)
  pasos sin voz (s2.b0, s3.b0, s4.b0) = 0,6 s; referencias = 3,0 s
  "Palabras" = wc -w del texto ya rellenado (una cifra = una palabra); "habladas" = como se leen
  ("2023" = twenty twenty-three = 2, "106" = one hundred six = 3, "2.2" = two point two = 3).
  Cifra hablada = marcador {clave} cuyo valor es numérico (incluye .say); años, umbrales y
  constantes de diseño (237, 30 → 40, 2050…) no son cifras-resultado y no llevan aire.
"""
from __future__ import annotations

import argparse
import html.parser
import json
import math
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
import fill_numbers as fn  # noqa: E402

REPO = fn.REPO
TEMPLATE = HERE / "narration_en_template.md"
OUT_MD = HERE / "narration_en.md"
OUT_CAPS = HERE / "captions.json"
OUT_TIMINGS = HERE / "video_timings.json"
OUT_SRT = HERE / "captions.srt"
OUT_DATACAPS = HERE / "data_captions.json"
INDEX = REPO / "slides" / "index.html"
ANIM = REPO / "figures" / "animated"

WPM = 150.0
AIR_S = 1.5
TRANS_S = 0.6
MP4_MARGIN_S = 0.3
REFS_S = 3.0
MAX_TOTAL_S = 295.0
MAX_WORDS = 700
MAX_SENTENCE_WORDS = 18
MAX_CAPTION_CHARS = 90
MAX_LINE_CHARS = 52
WEAK_END = {"of", "to", "and", "the", "a", "an", "in", "is", "are", "from", "for", "with", "by", "at",
            "its", "their", "or", "every", "our", "when", "where", "than", "as", "too", "had", "can"}
HOOK_LIMIT_S = 12.0
# Duraciones medidas el 2026-10-25 (ffmpeg 7.0.2 de imageio-ffmpeg); se vuelven a medir si hay ffmpeg
MP4_FALLBACK = {"fig01_growth_components_by_income": 12.6, "fig02b_lever_map_zoom": 4.0,
                "fig04_same_road_registration": 16.4, "fig07_single_indicator_scorecard": 14.9,
                "fig09_pca_two_dimensions": 7.7, "fig10_trajectory_groups": 26.4}
SLIDE_NAMES = {"cover": "Cover", "s1": "Slide 1", "s2": "Slide 2", "s3": "Slide 3", "s4": "Slide 4",
               "refs": "References"}


# ---------------------------------------------------------------- índice del deck (index.html)
class DeckParser(html.parser.HTMLParser):
    """data-step → sección, data-fragment-index del HTML, data-build y vídeos (data-fig) que contiene."""
    VOID = {"img", "br", "hr", "meta", "link", "input", "source", "col", "wbr"}

    def __init__(self):
        super().__init__()
        self.stack, self.steps, self.sec = [], {}, -1
        self.sec_frag_idx: dict[int, set] = {}

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "section" and self.stack and self.stack[-1][0] == "div" and "slides" in (self.stack[-1][1] or ""):
            self.sec += 1
            self.sec_frag_idx[self.sec] = set()
        cls = a.get("class") or ""
        if "fragment" in cls.split() and a.get("data-fragment-index") is not None and self.sec >= 0:
            self.sec_frag_idx[self.sec].add(int(a["data-fragment-index"]))
        step = a.get("data-step")
        if step:
            fi = a.get("data-fragment-index")
            self.steps[step] = {"id": step, "section": self.sec, "slide_class": cls.split()[0] if tag == "section" else None,
                                "html_fragment_index": int(fi) if fi is not None else None,
                                "build": a.get("data-build") or a.get("data-build-initial"),
                                "videos": [], "caption_html": a.get("data-caption", "")}
        if tag == "video" and a.get("data-fig"):
            owner = next((s[2] for s in reversed(self.stack) if s[2]), None)
            if owner:
                self.steps[owner]["videos"].append(a["data-fig"])
        if tag not in self.VOID:
            self.stack.append((tag, cls, step))

    def handle_endtag(self, tag):
        if tag in self.VOID:
            return
        for i in range(len(self.stack) - 1, -1, -1):
            if self.stack[i][0] == tag:
                del self.stack[i:]
                break


def deck_index() -> dict:
    p = DeckParser()
    p.feed(INDEX.read_text(encoding="utf-8"))
    for s in p.steps.values():
        idx = sorted(p.sec_frag_idx.get(s["section"], set()))
        hf = s["html_fragment_index"]
        s["reveal_f"] = idx.index(hf) if hf is not None and hf in idx else -1  # Reveal renumera 0…n-1
    return p.steps


# ---------------------------------------------------------------- MP4
def ffmpeg_exe():
    try:
        import imageio_ffmpeg  # noqa: F401
        return imageio_ffmpeg.get_ffmpeg_exe()
    except Exception:
        venv = Path("/tmp/claude-1000/-home-darkns-Documents-ASA-Dataquest/18220abc-2d13-436d-8acc-df8f607b6604/"
                    "scratchpad/venv-jupyter/lib")
        cand = sorted(venv.glob("python3*/site-packages/imageio_ffmpeg/binaries/ffmpeg-*")) if venv.exists() else []
        return str(cand[-1]) if cand else None


def mp4_duration(name: str, ff) -> tuple[float | None, str]:
    path = ANIM / f"{name}.mp4"
    if ff and path.exists():
        r = subprocess.run([ff, "-hide_banner", "-i", str(path)], capture_output=True, text=True)
        m = re.search(r"Duration:\s*(\d+):(\d+):([\d.]+)", r.stderr)
        if m:
            return int(m.group(1)) * 3600 + int(m.group(2)) * 60 + float(m.group(3)), "ffmpeg"
    return MP4_FALLBACK.get(name), "tabla"


# ---------------------------------------------------------------- palabras habladas
ONES = "zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen".split()


def int_words(n: int) -> list[str]:
    """Palabras al leer un entero (inglés de EE. UU., sin 'and'; decenas con guion = 1 palabra)."""
    if n < 20:
        return [ONES[n]]
    if n < 100:
        return ["tens-unit"]
    if n < 1000:
        return [ONES[n // 100], "hundred"] + (int_words(n % 100) if n % 100 else [])
    if n < 1_000_000:
        return int_words(n // 1000) + ["thousand"] + (int_words(n % 1000) if n % 1000 else [])
    return int_words(n // 1_000_000) + ["million"] + (int_words(n % 1_000_000) if n % 1_000_000 else [])


def spoken_len(token: str) -> int:
    t = token.strip(",.;:!?()\"'“”’").replace("−", "-")
    if not t:
        return 0
    m = re.fullmatch(r"[+-]?(\d[\d,]*)(?:\.(\d+))?%?", t)
    if not m:
        return 1
    ip = int(m.group(1).replace(",", ""))
    if m.group(2) is None and 1900 <= ip <= 2099 and "," not in m.group(1):
        return 2  # año: nineteen fifty, twenty twenty-three, two thousand
    n = len(int_words(ip))
    if m.group(2):
        n += 1 + len(m.group(2))  # "point" + dígitos
    if t.startswith("-"):
        n += 1
    return n


def spoken_words(text: str) -> int:
    return sum(spoken_len(w) for w in text.split())


# ---------------------------------------------------------------- plantilla
def is_numeric_key(numbers, key, field):
    key, field = fn.split_key(numbers, key, field)
    e = fn.entry(numbers, key)
    if e is None:
        return False
    v = e.get("value")
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def parse_template(numbers):
    slides, cur_slide, cur_step = [], None, None
    lines = TEMPLATE.read_text(encoding="utf-8").splitlines()
    text = "\n".join(lines)
    text = re.sub(r"<!--.*?-->", "", text, flags=re.S)
    for raw in text.splitlines():
        line = raw.rstrip()
        m = re.match(r"^##\s+(\S+)\s*(?:·\s*(.*))?$", line)
        if m and not line.startswith("###"):
            cur_slide = {"id": m.group(1), "title": (m.group(2) or "").strip(), "steps": []}
            slides.append(cur_slide)
            continue
        m = re.match(r"^###\s+(\S+)", line)
        if m:
            cur_step = {"id": m.group(1), "sentences": []}
            cur_slide["steps"].append(cur_step)
            continue
        if line.startswith(">"):
            body = line[1:].strip()
            if not body or body.startswith("[OPTIONAL]"):
                continue
            cur_step["sentences"].append(body)
    return slides


GROUP_SEP = re.compile(r"^\s+(?:of|to)\s+$")  # "106 of 109", "nine to thirty-three": una sola cifra (un aire)


def fill_block(tpl: str, numbers):
    out, missing, used = fn.fill_text(tpl, numbers)
    figs, last_end = [], None
    for m in fn.PAT.finditer(tpl):
        key, field = fn.split_key(numbers, m.group(2), m.group(3))
        if not is_numeric_key(numbers, key, field):
            last_end = None
            continue
        if figs and last_end is not None and GROUP_SEP.match(tpl[last_end:m.start()]):
            figs[-1] = f"{figs[-1]}+{key}"  # proporción o rango: se lee como una cifra
        else:
            figs.append(key)
        last_end = m.end()
    return out, missing, used, figs


def wrap2(text: str, width: int = MAX_LINE_CHARS) -> list[str]:
    """Una línea si cabe; si no, dos líneas equilibradas partiendo en un espacio."""
    if len(text) <= width:
        return [text]
    best = None
    for i, ch in enumerate(text):
        if ch == " ":
            a, b = text[:i], text[i + 1:]
            score = max(len(a), len(b))
            if a[-1] in ";:,":
                score -= 10  # mejor cortar tras la puntuación (frase de lectura natural)
            if re.search(r"\d$", a) or re.match(r"^(of|to|and)\b", b):
                score += 6   # no dejar una cifra colgando al final de la línea
            if a.split()[-1].lower() in WEAK_END:
                score += 8   # ni una palabra funcional ("of", "and", "the"…) al final de la línea
            if max(len(a), len(b)) > width:
                score += 100
            if best is None or score < best[0]:
                best = (score, [a, b])
    return best[1] if best else [text]


def fmt_ts(t: float) -> str:
    ms = int(round(t * 1000))
    h, ms = divmod(ms, 3_600_000)
    m, ms = divmod(ms, 60_000)
    s, ms = divmod(ms, 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def mmss(t: float) -> str:
    return f"{int(t // 60)}:{t % 60:04.1f}"


# ---------------------------------------------------------------- construcción
def build(numbers):
    deck = deck_index()
    ff = ffmpeg_exe()
    slides = parse_template(numbers)
    problems, errors = [], []
    all_used, figs_all = set(), []
    t = 0.0
    steps_out, cues, first = [], [], True
    tpl_ids = [st["id"] for sl in slides for st in sl["steps"]]
    deck_order = sorted(deck.values(), key=lambda s: (s["section"], s["reveal_f"]))
    deck_ids = [s["id"] for s in deck_order]
    if tpl_ids != deck_ids:
        errors.append(f"los pasos de la plantilla no coinciden con slides/index.html:\n  plantilla: {tpl_ids}\n  deck:      {deck_ids}")
    for sl in slides:
        for st in sl["steps"]:
            d = deck.get(st["id"], {})
            blocks = []
            for si, sent in enumerate(st["sentences"]):
                parts = [p.strip() for p in sent.split(" | ")]
                filled_parts, part_blocks = [], []
                for pi, ptxt in enumerate(parts):
                    out, missing, used, figs = fill_block(ptxt, numbers)
                    if missing:
                        errors.append(f"{st['id']}: sin resolver {missing}")
                    miss, unver = fn.audit(numbers, used)
                    if miss or unver:
                        errors.append(f"{st['id']}: claves inexistentes {miss} o sin verificar {unver}")
                    all_used |= used
                    figs_all += figs
                    filled_parts.append(out)
                    part_blocks.append({"text": out, "sentence": si, "figs": figs})
                sentence = " ".join(filled_parts)
                # " | " = punto de corte preferido; solo se usa si la frase no cabe en un bloque (≤ 90)
                if len(sentence) <= MAX_CAPTION_CHARS:
                    part_blocks = [{"text": sentence, "sentence": si,
                                    "figs": [f for b in part_blocks for f in b["figs"]]}]
                for b in part_blocks:
                    b["words"] = len(b["text"].split())
                    b["spoken"] = spoken_words(b["text"])
                    blocks.append(b)
                n = len(sentence.split())
                # frase = línea; además cada oración interna (". ") ≤ 18
                for piece in re.split(r"(?<=[.!?])\s+", sentence):
                    if len(piece.split()) > MAX_SENTENCE_WORDS:
                        errors.append(f"{st['id']}: frase de {len(piece.split())} palabras (> {MAX_SENTENCE_WORDS}): {piece}")
                st.setdefault("filled", []).append(sentence)
                st.setdefault("sentence_words", []).append(n)
            voice = sum(b["spoken"] / WPM * 60 + AIR_S * len(b["figs"]) for b in blocks)
            trans = 0.0 if first else TRANS_S
            dur = trans + voice
            mp4s = []
            for v in d.get("videos", []):
                ds, src = mp4_duration(v, ff)
                mp4s.append({"name": v, "duration_s": ds, "source": src})
                if ds:
                    dur = max(dur, ds + MP4_MARGIN_S)
            if st["id"] == "refs":
                dur = max(dur, REFS_S)
            if not blocks and st["id"] != "refs":
                dur = max(dur, TRANS_S)
            dur = math.ceil(dur * 10 - 1e-9) / 10
            # bloques de subtítulo: el primero aparece con el paso (captions.js lo muestra al instante)
            off = trans
            cap_items = []
            for bi, b in enumerate(blocks):
                bt = b["spoken"] / WPM * 60 + AIR_S * len(b["figs"])
                start = 0.0 if bi == 0 else round(off, 2)
                off += bt
                end = round(off, 2) if bi < len(blocks) - 1 else dur
                cap_items.append((start, end, b))
                if len(b["text"]) > MAX_CAPTION_CHARS:
                    errors.append(f"{st['id']}: bloque de {len(b['text'])} caracteres (> {MAX_CAPTION_CHARS}): {b['text']}")
                if len(wrap2(b["text"])) > 2 or any(len(x) > MAX_LINE_CHARS + 8 for x in wrap2(b["text"])):
                    errors.append(f"{st['id']}: bloque que no cabe en 2 líneas: {b['text']}")
            slide_key = sl["id"]
            for ci, (cs, ce, b) in enumerate(cap_items):
                cues.append({
                    "slide": slide_key, "slide_name": SLIDE_NAMES.get(slide_key, slide_key),
                    "slide_index": d.get("section"), "step": st["id"],
                    "fragment_index": d.get("html_fragment_index"), "reveal_fragment": d.get("reveal_f"),
                    "build": d.get("build"), "cue": ci + 1,
                    "caption": b["text"], "lines": wrap2(b["text"]), "chars": len(b["text"]),
                    "narration": b["text"], "words": b["words"], "spoken_words": b["spoken"],
                    "spoken_figures": b["figs"],
                    "t_start": round(t + cs, 2), "t_end": round(t + ce, 2),
                    "step_narration": " ".join(st.get("filled", [])), "step_words": sum(x["words"] for x in blocks),
                    "step_t_start": round(t, 2), "step_t_end": round(t + dur, 2),
                    "step_mp4": [{"name": m["name"], "duration_s": m["duration_s"]} for m in mp4s],
                })
            steps_out.append({
                "id": st["id"], "slide": slide_key, "section": d.get("section"),
                "html_fragment_index": d.get("html_fragment_index"), "reveal_f": d.get("reveal_f"),
                "build": d.get("build"), "t_start": round(t, 2), "t_end": round(t + dur, 2), "duration": dur,
                "transition_s": trans, "voice_s": round(voice, 2), "words": sum(b["words"] for b in blocks),
                "spoken_words": sum(b["spoken"] for b in blocks), "figures": [f for b in blocks for f in b["figs"]],
                "mp4": mp4s, "narration": " ".join(st.get("filled", [])), "sentences": st.get("filled", []),
                "captions": [{"t": cs, "text": b["text"]} for cs, ce, b in cap_items],
            })
            t += dur
            first = False
    total = round(t, 2)
    words = sum(s["words"] for s in steps_out)
    if words > MAX_WORDS:
        errors.append(f"{words} palabras (> {MAX_WORDS})")
    if total > MAX_TOTAL_S:
        errors.append(f"duración {total:.1f} s (> {MAX_TOTAL_S})")
    hook = next((c for c in cues if c["caption"].startswith("Yet ")), None)
    if hook and hook["t_start"] > HOOK_LIMIT_S:
        problems.append(f"el giro '{hook['caption']}' empieza en {hook['t_start']} s (> {HOOK_LIMIT_S})")
    for need in ("Question one, answered", "Question two, answered", "Question three, answered"):
        if not any(c["caption"].startswith(need) for c in cues):
            errors.append(f"falta '{need}'")
    for s in steps_out:
        for m in s["mp4"]:
            if m["duration_s"] and s["duration"] < m["duration_s"]:
                errors.append(f"{s['id']}: dura {s['duration']} s < MP4 {m['name']} {m['duration_s']} s")
    return {"steps": steps_out, "cues": cues, "total_s": total, "words": words,
            "spoken_words": sum(s["spoken_words"] for s in steps_out), "figures": figs_all,
            "used_keys": sorted(all_used), "errors": errors, "problems": problems, "hook": hook,
            "slides": slides}


# ---------------------------------------------------------------- escritura
def write_outputs(r, numbers):
    steps, cues = r["steps"], r["cues"]
    # ---- captions.json (lista de bloques)
    OUT_CAPS.write_text(json.dumps(cues, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    # ---- video_timings.json
    vt = {
        "_comment": ("Generado por slides/script/build_narration.py desde slides/script/narration_en_template.md "
                     "(guion final 2026-10-25). Modelo: 150 ppm + 1,5 s de aire por cifra hablada + 0,6 s de "
                     "transición por paso (salvo el primero); pasos con MP4 ≥ MP4 + 0,3 s. 'captions[].t' = s desde "
                     "el inicio del paso; el primer bloque se muestra al entrar en el paso. Los id son los data-step "
                     "de slides/index.html. Se regenera: no editar a mano."),
        "version": 4, "storyboard": "v4 (guion final 2026-10-25 + corrector-final 2026-10-26)", "default_step_s": 4,
        "total_s": r["total_s"], "words": r["words"], "wpm": WPM, "air_per_figure_s": AIR_S,
        "transition_s": TRANS_S,
        "steps": [{"id": s["id"], "duration": s["duration"],
                   **({"captions": s["captions"]} if s["captions"] else {})} for s in steps],
    }
    OUT_TIMINGS.write_text(json.dumps(vt, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    # ---- data_captions.json: texto para los data-caption de slides/index.html (" | " = bloque)
    dc = {"_comment": ("data-caption literal a la voz final para cada data-step de slides/index.html "
                       "(lo aplica el dueño del HTML; video_timings.json ya los impone al grabar)."),
          "captions": {s["id"]: " | ".join(c["text"] for c in s["captions"]) for s in steps}}
    OUT_DATACAPS.write_text(json.dumps(dc, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    # ---- SRT
    srt = []
    for i, c in enumerate(cues, 1):
        srt.append(f"{i}\n{fmt_ts(c['t_start'])} --> {fmt_ts(c['t_end'])}\n" + "\n".join(c["lines"]) + "\n")
    OUT_SRT.write_text("\n".join(srt), encoding="utf-8")
    # ---- narration_en.md
    md = []
    md.append("# Narration — final video script (EN) · v4 · 2026-10-26 (corrector-final, hallazgos QA)\n")
    md.append("> Generado por `slides/script/build_narration.py` desde `slides/script/narration_en_template.md` "
              "con `figures/numbers.json` (solo claves `verified: true`). **No editar a mano**: se cambia la plantilla "
              "y se regenera. Fuente única de la voz: `docs/00_storyboard_diapositivas.md` la copia palabra por palabra.\n")
    md.append(f"> **{r['words']} palabras** (`wc -w`, cifra = 1) · {r['spoken_words']} habladas · "
              f"**{len(r['figures'])} cifras habladas** · **{r['total_s']:.1f} s = {mmss(r['total_s'])}** "
              f"(150 ppm + 1,5 s de aire por cifra + 0,6 s por transición; pasos con MP4 ≥ MP4 + 0,3 s) · "
              f"{len(steps)} pasos · {len(cues)} bloques de subtítulo.\n")
    if r["hook"]:
        md.append(f"> Gancho: la paradoja se plantea antes de {r['hook']['t_start']:.1f} s y el giro "
                  f"\"{r['hook']['caption']}\" empieza en {r['hook']['t_start']:.1f} s.\n")
    md.append("Lectura: una frase por línea `>`; leer sin prisa, ≈ 1,5 s de silencio después de cada cifra "
              "(marcadas en la tabla). Nombres: \"UNALSta-R\" = *u-nal-sta-ar*. Lo que no lleva cifra en voz queda en pantalla.\n")
    md.append("## Tiempos por paso\n")
    md.append("| Paso | Diapositiva | `data-fragment-index` (HTML → reveal) | Inicio–fin | Dur. (s) | Palabras | Cifras habladas | MP4 |")
    md.append("|---|---|---|---|---|---|---|---|")
    for s in steps:
        fi = "sección" if s["html_fragment_index"] is None else f"{s['html_fragment_index']} → {s['reveal_f']}"
        mp4 = ", ".join(f"{m['name']} ({m['duration_s']:.1f} s)" for m in s["mp4"]) or "—"
        figs = len(s["figures"])
        md.append(f"| `{s['id']}` | {SLIDE_NAMES.get(s['slide'], s['slide'])} | {fi} | {mmss(s['t_start'])}–{mmss(s['t_end'])} "
                  f"| {s['duration']:.1f} | {s['words']} | {figs} | {mp4} |")
    md.append(f"| **Total** | | | 0:00.0–{mmss(r['total_s'])} | **{r['total_s']:.1f}** | **{r['words']}** | **{len(r['figures'])}** | |\n")
    by_slide = {}
    for s in steps:
        by_slide.setdefault(s["slide"], []).append(s)
    for sl in r["slides"]:
        ss = by_slide.get(sl["id"], [])
        if not ss:
            continue
        w = sum(s["words"] for s in ss)
        md.append(f"## {SLIDE_NAMES.get(sl['id'], sl['id'])}{' — ' + sl['title'] if sl['title'] else ''} "
                  f"({mmss(ss[0]['t_start'])}–{mmss(ss[-1]['t_end'])} · {w} palabras)\n")
        for s in ss:
            fi = "inicio de sección" if s["html_fragment_index"] is None else f"fragmento {s['html_fragment_index']}"
            md.append(f"**`{s['id']}`** · {fi} · {mmss(s['t_start'])}–{mmss(s['t_end'])}"
                      + (" · " + ", ".join(f"MP4 {m['name']} {m['duration_s']:.1f} s" for m in s["mp4"]) if s["mp4"] else ""))
            md.append("")
            if s["sentences"]:
                for sent in s["sentences"]:
                    md.append(f"> {sent}")
            else:
                md.append("*(sin voz: transición)*" if s["id"] != "refs" else "*(sin voz: referencias en pantalla 3 s)*")
            md.append("")
    md.append("## Claves usadas en la voz\n")
    rows = []
    for k in r["used_keys"]:
        e = fn.entry(numbers, k) or {}
        rows.append(f"| `{k}` | {fn.format_key(numbers, k)} | {e.get('say') or '—'} | {'✔' if e.get('verified') is True else '✘'} |")
    md.append("| Clave | Valor formateado | `say` | verified |\n|---|---|---|---|")
    md += rows
    md.append("")
    OUT_MD.write_text("\n".join(md) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--check", action="store_true", help="solo validar y mostrar el resumen")
    a = ap.parse_args()
    numbers = fn.load_numbers(fn.DEFAULT_NUMBERS)
    r = build(numbers)
    for s in r["steps"]:
        print(f"{s['id']:9s} f={str(s['html_fragment_index']):4s}→{s['reveal_f']:2d} {s['t_start']:6.1f}–{s['t_end']:6.1f} "
              f"dur={s['duration']:5.1f} voice={s['voice_s']:5.1f} w={s['words']:3d} figs={len(s['figures'])}"
              + (f" mp4={[m['duration_s'] for m in s['mp4']]}" if s["mp4"] else ""))
    print(f"TOTAL {r['total_s']:.1f} s · {r['words']} palabras ({r['spoken_words']} habladas) · "
          f"{len(r['figures'])} cifras · {len(r['cues'])} bloques")
    for p in r["problems"]:
        print("AVISO:", p)
    for e in r["errors"]:
        print("ERROR:", e, file=sys.stderr)
    if r["errors"]:
        return 2
    if not a.check:
        write_outputs(r, numbers)
        print(f"escritos: {OUT_MD.name}, {OUT_CAPS.name}, {OUT_TIMINGS.name}, {OUT_SRT.name}, {OUT_DATACAPS.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
