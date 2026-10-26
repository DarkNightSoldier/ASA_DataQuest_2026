#!/usr/bin/env python3
"""Sustituye {clave} y {clave.say} de un markdown de narración por las cifras de numbers.json.

Uso típico (agente de guion):
    python slides/script/fill_numbers.py slides/script/narration_en_template.md -o slides/script/narration_en.md
Otros modos:
    python slides/script/fill_numbers.py --check-html slides/index.html     # claves del HTML que faltan / sin verificar
    python slides/script/fill_numbers.py --emit-js slides/js/numbers_data.js # window.NUMBERS para abrir el deck por file://

Marcadores admitidos en el texto:
    {clave}            valor formateado (mismas reglas que slides/js/numbers.js)
    {clave.say}        campo "say" (frase hablada, p. ej. "seven in ten"); error si la clave no lo tiene
    {clave.voice}      forma hablada: "say" si existe; si no, el valor formateado y, en listas de
                       países, el nombre corto admitido en voz (storyboard §8: "Russia", "the United
                       States", "Iran", "the Emirates"…)
    {clave.campo}      cualquier otro campo de la entrada (sens_low, ci_high, pi95_low…)
    {clave:fmt}        decimales forzados, p. ej. {yrs_medage30_40_early:0}
    {^clave…}          igual, con la primera letra en mayúscula (inicio de frase)
Las llaves que no son marcadores (código, JSON) se respetan si no casan con el patrón
[A-Za-z_][A-Za-z0-9_.]* o si van escapadas como {{ }}.

Redondeo: ROUND_HALF_UP sobre la representación decimal del valor (Decimal(repr(v)).quantize),
p. ej. 36.5 → 37 con fmt "0" y 0.735 → 0.74 con fmt "0.00" (el f-string de Python daba 36 y 0.73).

Seguridad de cifras (QA-stats, docs/QA_stats.md §7): una clave que no existe en numbers.json o cuya
entrada no tiene "verified": true es un ERROR (código 2) en todos los modos, salvo --allow-unverified
(solo pruebas). --allow-missing se conserva por compatibilidad y equivale a --allow-unverified.
"""
from __future__ import annotations

import argparse
import json
import math
import re
import sys
from decimal import ROUND_HALF_UP, Decimal
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
DEFAULT_NUMBERS = REPO / "figures" / "numbers.json"
ISO_JS = REPO / "slides" / "js" / "iso_codes.js"
NUMBERS_JS = REPO / "slides" / "js" / "numbers.js"
MINUS = "−"
# claves con punto (share_keep_ge_0.8) admitidas: el último ".campo" solo cuenta como campo si
# la clave completa no existe (ver split_key)
PAT = re.compile(r"(?<!\{)\{(\^)?([A-Za-z_][A-Za-z0-9_.]*?)(?:\.([A-Za-z_][A-Za-z0-9_]*))?(?::([0-9]+))?\}(?!\})")

# Nombres cortos admitidos en voz (storyboard §8 "Nombres ONU"); en pantalla se usa el nombre WPP
VOICE_NAMES = {
    "Russian Federation": "Russia",
    "United States of America": "the United States",
    "Iran (Islamic Republic of)": "Iran",
    "United Arab Emirates": "the Emirates",
    "United Kingdom": "the United Kingdom",
    "Republic of Korea": "the Republic of Korea",
    "Netherlands": "the Netherlands",
    "Philippines": "the Philippines",
    "Democratic Republic of the Congo": "the Democratic Republic of the Congo",
    "Syrian Arab Republic": "Syria",
    "Venezuela (Bolivarian Republic of)": "Venezuela",
    "Bolivia (Plurinational State of)": "Bolivia",
    "United Republic of Tanzania": "Tanzania",
    "Republic of Moldova": "Moldova",
    "Lao People's Democratic Republic": "Laos",
}


# ---------------------------------------------------------------- formato (= numbers.js)
def decimals_for(fmt, v: float) -> int:
    if isinstance(fmt, bool):
        fmt = None
    if isinstance(fmt, (int, float)) and not isinstance(fmt, bool):
        return max(0, int(round(fmt)))
    if isinstance(fmt, str) and fmt.strip():
        f = fmt.strip()
        if re.fullmatch(r"\d+", f):
            return int(f)
        m = re.search(r"\.([0#]+)", f)
        if m:
            return len(m.group(1))
        if re.fullmatch(r"[+]?[#0,]+%?", f) or f in ("int", "d"):
            return 0
    if float(v).is_integer():  # como Number.isInteger en JS (66.0 == 66)
        return 0
    return 2 if abs(v) < 1 else 1


def round_half_up(v: float, d: int) -> str:
    """|v| redondeado a d decimales, mitad hacia arriba, sobre la representación decimal (repr)."""
    q = Decimal(1).scaleb(-d)
    r = Decimal(repr(abs(float(v)))).quantize(q, rounding=ROUND_HALF_UP)
    return f"{r:.{d}f}"


def format_number(v: float, fmt=None, sign: str | None = None, ascii_minus: bool = False) -> str:
    d = decimals_for(fmt, v)
    s = round_half_up(v, d)
    if (isinstance(fmt, str) and "," in fmt) or abs(v) >= 10000:
        ip, _, dp = s.partition(".")
        ip = f"{int(ip):,}"
        s = ip + ("." + dp if dp else "")
    is_zero = float(s.replace(",", "")) == 0
    if v < 0 and not is_zero:
        s = ("-" if ascii_minus else MINUS) + s
    elif v > 0 and not is_zero and (sign == "always" or (isinstance(fmt, str) and fmt.strip().startswith("+"))):
        s = "+" + s
    return s


def load_country_names() -> dict:
    """ISO3 -> nombre WPP desde slides/js/iso_codes.js (generado por slides/dev/gen_iso_codes.R)."""
    try:
        txt = ISO_JS.read_text(encoding="utf-8")
        m = re.search(r"window\.COUNTRY_CODES\s*=\s*(\{.*?\});", txt, re.S)
        codes = json.loads(m.group(1)) if m else {}
        names = {k: v.get("name", k) for k, v in codes.items()}
        names.update({v["iso2"].upper(): v.get("name", k) for k, v in codes.items() if v.get("iso2")})
        return names
    except Exception:
        return {}


NAMES = load_country_names()  # ISO3 y ISO2 (mayúsculas) -> nombre WPP


def name_of(item) -> str:
    if isinstance(item, dict):
        return str(item.get("name") or item.get("label") or NAMES.get(str(item.get("iso3", "")).upper(), item.get("iso3", "")))
    s = str(item).strip()
    if re.fullmatch(r"[A-Za-z]{2,3}", s) and s.upper() in NAMES and (len(s) == 3 or s.isupper() or s.islower()):
        return NAMES[s.upper()]
    if re.fullmatch(r"[A-Z]{3}", s) and s in NAMES:
        return NAMES[s]
    return s


def join_list(items) -> str:
    a = [x for x in items if x not in (None, "")]
    if len(a) <= 1:
        return "".join(a)
    if len(a) == 2:
        return f"{a[0]} and {a[1]}"
    return ", ".join(a[:-1]) + " and " + a[-1]


def load_aliases() -> dict:
    """Tabla de alias de slides/js/numbers.js (entre /*ALIASES-BEGIN*/ y /*ALIASES-END*/)."""
    try:
        txt = NUMBERS_JS.read_text(encoding="utf-8")
        m = re.search(r"/\*ALIASES-BEGIN\*/(.*?)/\*ALIASES-END\*/", txt, re.S)
        return json.loads(m.group(1)) if m else {}
    except Exception:
        return {}


ALIASES = load_aliases()


def raw_entry(numbers: dict, key: str):
    if key not in numbers:
        return None
    e = numbers[key]
    return e if isinstance(e, dict) else {"value": e}


def entry(numbers: dict, key: str):
    e = raw_entry(numbers, key)
    if e is not None:
        return e
    for k in ALIASES.get("alias", {}).get(key, []):
        e = raw_entry(numbers, k)
        if e is not None:
            return e
    base = ALIASES.get("range", {}).get(key)
    if base:
        b = entry(numbers, base)
        if b and isinstance(b.get("sens_low"), (int, float)) and isinstance(b.get("sens_high"), (int, float)):
            f = b.get("range_fmt", "0")
            return {"value": f"{format_number(b['sens_low'], f)}–{format_number(b['sens_high'], f)}",
                    "verified": b.get("verified"), "nota_qa": b.get("nota_qa"), "derived_from": base}
    return None


def split_key(numbers: dict, key: str, field: str | None):
    """PAT es perezoso con el punto: 'share_keep_ge_0' + '.8' no es campo. Reconstruye la clave."""
    if field and entry(numbers, key) is None and entry(numbers, f"{key}.{field}") is not None:
        return f"{key}.{field}", None
    if field is None and "." in key and entry(numbers, key) is None:
        k, _, f = key.rpartition(".")
        if entry(numbers, k) is not None:
            return k, f
    return key, field


def format_key(numbers: dict, key: str, field: str | None = None, fmt=None, ascii_minus=False):
    e = entry(numbers, key)
    if e is None:
        return None
    if field == "say":
        if e.get("say") not in (None, ""):
            return str(e["say"])
        return None  # en la voz, sin "say" es un error: la frase hablada debe existir
    if field == "voice":
        if e.get("say") not in (None, ""):
            return str(e["say"])
        v = e.get("value")
        if isinstance(v, list):
            return join_list([VOICE_NAMES.get(name_of(x), name_of(x)) for x in v])
        field = None  # cifra sin "say": se lee el valor formateado
    v = e.get(field) if field else e.get("value")
    if v is None or (isinstance(v, float) and not math.isfinite(v)):
        return None
    if isinstance(v, bool):
        return str(v).lower()
    if isinstance(v, (int, float)):
        return format_number(v, fmt if fmt is not None else e.get("fmt"), ascii_minus=ascii_minus)
    if isinstance(v, list):
        return join_list([name_of(x) for x in v])
    if isinstance(v, dict):
        return None
    return str(v)


def fill_text(text: str, numbers: dict, ascii_minus=False):
    missing, used = [], set()

    def rep(m):
        cap, key, field, fmt = m.group(1), m.group(2), m.group(3), m.group(4)
        key, field = split_key(numbers, key, field)
        used.add(key)
        out = format_key(numbers, key, field, fmt, ascii_minus)
        if out is None:
            missing.append(m.group(0))
            return m.group(0)
        if cap and out:
            out = out[0].upper() + out[1:]
        return out

    out = PAT.sub(rep, text)
    # salvaguarda: "about about seven in ten" (say que ya trae "about") → un solo "about"
    out = re.sub(r"\b(about|≈)\s+(?:about|≈)\s+", r"\1 ", out, flags=re.I)
    out = out.replace("{{", "{").replace("}}", "}")
    return out, missing, used


def load_numbers(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def keys_in_html(html: str) -> set[str]:
    html = re.sub(r"<!--.*?-->", "", html, flags=re.S)  # el comentario de convenciones no cuenta
    keys = set(re.findall(r'data-(?:num|flags|list)="([^"]+)"', html))
    for cap in re.findall(r'data-caption="([^"]*)"', html):
        keys |= {m.group(2) for m in PAT.finditer(cap)}
    return keys


def audit(numbers: dict, keys) -> tuple[list[str], list[str]]:
    """(inexistentes, sin verificar) — sin verificar = entrada con verified distinto de True."""
    miss = sorted(k for k in keys if entry(numbers, k) is None)
    unver = sorted(k for k in keys if entry(numbers, k) is not None and entry(numbers, k).get("verified") is not True)
    return miss, unver


def report_rejected(numbers: dict, miss: list[str], unver: list[str], where: str) -> None:
    print(f"[fill_numbers] ERROR en {where}: hay cifras que no se pueden decir ni mostrar "
          "(docs/QA_stats.md §7). Reformule la frase sin la cifra o verifique la clave; "
          "--allow-unverified solo para pruebas.", file=sys.stderr)
    for k in miss:
        print(f"  ✘ {k}: no existe en numbers.json", file=sys.stderr)
    for k in unver:
        nota = (entry(numbers, k) or {}).get("nota_qa") or "verified != true"
        print(f"  ✘ {k}: sin verificar · {nota}", file=sys.stderr)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", nargs="?", help="markdown con marcadores {clave}")
    ap.add_argument("-o", "--output", help="salida (por defecto: <input>_filled.md)")
    ap.add_argument("--numbers", default=str(DEFAULT_NUMBERS), help="ruta a numbers.json")
    ap.add_argument("--allow-unverified", action="store_true",
                    help="no fallar con claves inexistentes, sin valor o sin verificar (solo pruebas)")
    ap.add_argument("--allow-missing", action="store_true", help="alias antiguo de --allow-unverified")
    ap.add_argument("--ascii-minus", action="store_true", help="usar '-' en lugar de U+2212")
    ap.add_argument("--check-html", metavar="HTML", help="lista claves usadas en el HTML que faltan o no están verificadas")
    ap.add_argument("--emit-js", metavar="JS", help="escribe window.NUMBERS = {...} (para abrir el deck por file://)")
    a = ap.parse_args()
    allow = a.allow_unverified or a.allow_missing

    npath = Path(a.numbers)
    if not npath.exists():
        print(f"[fill_numbers] no existe {npath} (lo produce R/05_numbers_json.R)", file=sys.stderr)
        return 3
    numbers = load_numbers(npath)
    if numbers.get("_meta", {}).get("demo"):
        print("[fill_numbers] AVISO: numbers.json marcado como DEMO", file=sys.stderr)

    rc = 0
    if a.emit_js:
        Path(a.emit_js).write_text("/* Generado por slides/script/fill_numbers.py --emit-js a partir de "
                                   f"{npath.name}. NO editar a mano. */\nwindow.NUMBERS = "
                                   + json.dumps(numbers, ensure_ascii=False) + ";\n", encoding="utf-8")
        print(f"[fill_numbers] escrito {a.emit_js}")

    if a.check_html:
        keys = keys_in_html(Path(a.check_html).read_text(encoding="utf-8"))
        miss, unver = audit(numbers, keys)
        print(f"[fill_numbers] {a.check_html}: {len(keys)} claves · {len(miss)} sin valor · {len(unver)} sin verificar")
        if miss:
            print("  sin valor:", ", ".join(miss))
        if unver:
            print("  sin verificar:", ", ".join(unver))
        if (miss or unver) and not allow:
            report_rejected(numbers, miss, unver, a.check_html)
            rc = 2

    if a.input:
        src = Path(a.input)
        out_path = Path(a.output) if a.output else src.with_name(src.stem + "_filled" + src.suffix)
        text, missing, used = fill_text(src.read_text(encoding="utf-8"), numbers, a.ascii_minus)
        miss, unver = audit(numbers, used)
        print(f"[fill_numbers] {src} → {out_path} · {len(used)} claves · {len(missing)} sin resolver · "
              f"{len(unver)} sin verificar")
        if missing:
            print("  sin resolver:", ", ".join(sorted(set(missing))), file=sys.stderr)
        if (missing or miss or unver) and not allow:
            report_rejected(numbers, miss, unver, str(src))
            print(f"[fill_numbers] no se escribe {out_path}", file=sys.stderr)
            return 2
        out_path.write_text(text, encoding="utf-8")
        if unver:
            print("  AVISO (--allow-unverified): sin verificar:", ", ".join(unver), file=sys.stderr)
    if not (a.input or a.check_html or a.emit_js):
        ap.print_help()
    return rc


if __name__ == "__main__":
    sys.exit(main())
