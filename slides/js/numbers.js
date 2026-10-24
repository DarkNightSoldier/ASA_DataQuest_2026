/* =============================================================================
   numbers.js — rellena las cifras de las diapositivas desde figures/numbers.json
   Orden de carga (la primera que funcione):
     1. fetch('../figures/numbers.json')            ← lo produce R/05_numbers_json.R
     2. window.NUMBERS (js/numbers_data.js)         ← para file://; lo genera
                                                      `python script/fill_numbers.py --emit-js js/numbers_data.js`
     3. fetch('dev/numbers_demo.json')              ← SOLO pruebas de renderizado ("demo": true)
     4. window.NUMBERS_DEMO (dev/numbers_demo.js)   ← ídem para file://
   Marcado que entiende (ver comentario al inicio de index.html y slides/README.md):
     [data-num] [data-say] [data-field] [data-item] [data-fmt] [data-sign]
     [data-flags] [data-iso] [data-list]
   Reglas de formato (idénticas en script/fill_numbers.py):
     - fmt "0" | "1" | "2" | 2 → decimales; "0.0" → 1 decimal; "#,##0" → miles; "+0.0" → signo siempre.
     - sin fmt: entero → 0 decimales; |x| < 1 → 2; resto → 1.
     - separador de miles "," si |x| ≥ 10 000 (o si fmt lleva ",").
     - negativos con signo menos tipográfico U+2212.
     - listas → "A, B and C"; códigos ISO3 en listas de texto → nombre WPP.
   La unidad NO se añade (el texto de la diapositiva ya la lleva), salvo con data-unit.
   Alias: el HTML usa los nombres del storyboard v2.1; si numbers.json usa los del plan §4
   (p. ej. n_countries_1m en vez de n_ge1m) se resuelven con KEY_ALIASES (más abajo; la misma
   tabla la lee script/fill_numbers.py). *_sens_range se deriva de sens_low–sens_high.
   Banderas: [data-flags="clave"] usa clave_iso3 o clave_iso si existen (listas ISO3 del notebook).
   Vista previa con salidas parciales: index.html?numbers=../figures/numbers_q1.json,../figures/numbers_q2.json
   ============================================================================= */
(function () {
  "use strict";

  var MINUS = "−";
  var PRIMARY_URL = "../figures/numbers.json";
  var PRIMARY_JS = "js/numbers_data.js";
  var DEMO_URL = "dev/numbers_demo.json";
  var DEMO_JS = "dev/numbers_demo.js";

  var state = { data: null, source: "none", demo: false, report: null };

  /* Tabla de alias y claves derivadas (fuente única; fill_numbers.py la extrae entre los marcadores). */
  var KEY_ALIASES = /*ALIASES-BEGIN*/{
    "alias": {
      "n_ge1m": ["n_ge1m", "n_countries_1m"],
      "n_countries_1m": ["n_countries_1m", "n_ge1m"],
      "n_states": ["n_states", "n_sovereign"],
      "n_twin_pairs": ["n_twin_pairs", "n_pairs_twins"],
      "n_census_pre2009": ["n_census_pre2009"]
    },
    "range": {
      "share_mig_high_sens_range": "share_mig_high_2000_2023",
      "n_grow_only_migration_sens_range": "n_grow_only_migration_2023",
      "pc1_var_sens_range": "pc1_var"
    },
    "flag_suffixes": ["_iso3", "_iso"]
  }/*ALIASES-END*/;

  function isPrint() { return /print-pdf/i.test(window.location.search); }

  function loadScript(src) {
    return new Promise(function (resolve) {
      var s = document.createElement("script");
      s.src = src; s.async = false;
      s.onload = function () { resolve(true); };
      s.onerror = function () { s.remove(); resolve(false); };
      document.head.appendChild(s);
    });
  }

  function fetchJson(url) {
    if (window.location.protocol === "file:") return Promise.resolve(null);
    return fetch(url, { cache: "no-store" })
      .then(function (r) { return r.ok ? r.json() : null; })
      .catch(function () { return null; });
  }

  function hasDemoFlag(d) {
    if (!d) return false;
    if (d._meta && d._meta.demo === true) return true;
    return Object.keys(d).some(function (k) { return d[k] && d[k].demo === true; });
  }

  /* ---------- carga ---------- */
  function overrideUrls() {
    var m = window.location.search.match(/[?&]numbers=([^&]+)/);
    return m ? decodeURIComponent(m[1]).split(",").filter(Boolean) : null;
  }

  function load() {
    var ov = overrideUrls();
    if (ov) {
      return Promise.all(ov.map(fetchJson)).then(function (parts) {
        var merged = {};
        parts.forEach(function (p) { if (p) Object.keys(p).forEach(function (k) { merged[k] = p[k]; }); });
        state.data = merged; state.source = "override:" + ov.join(",");
        state.demo = hasDemoFlag(merged);
        console.info("[numbers] override", ov, Object.keys(merged).length, "keys");
        return merged;
      });
    }
    return fetchJson(PRIMARY_URL).then(function (d) {
      if (d) return { d: d, src: PRIMARY_URL };
      return loadScript(PRIMARY_JS).then(function () {
        if (window.NUMBERS) return { d: window.NUMBERS, src: PRIMARY_JS };
        return fetchJson(DEMO_URL).then(function (dd) {
          if (dd) return { d: dd, src: DEMO_URL };
          return loadScript(DEMO_JS).then(function () {
            return window.NUMBERS_DEMO ? { d: window.NUMBERS_DEMO, src: DEMO_JS } : { d: {}, src: "none" };
          });
        });
      });
    }).then(function (res) {
      state.data = res.d || {};
      state.source = res.src;
      state.demo = res.src.indexOf("demo") >= 0 || hasDemoFlag(state.data);
      if (res.src === "none") console.warn("[numbers] No numbers source found; all figures stay as '—'.");
      else console.info("[numbers] loaded from", res.src, state.demo ? "(DEMO)" : "");
      return state.data;
    });
  }

  /* ---------- acceso ---------- */
  function rawEntry(key) {
    if (!state.data || !Object.prototype.hasOwnProperty.call(state.data, key)) return null;
    var e = state.data[key];
    if (e === null || typeof e !== "object" || Array.isArray(e)) return { value: e };
    return e;
  }

  function entry(key) {
    var e = rawEntry(key);
    if (e) return e;
    var al = KEY_ALIASES.alias[key];
    if (al) for (var i = 0; i < al.length; i++) { e = rawEntry(al[i]); if (e) return e; }
    var base = KEY_ALIASES.range[key];
    if (base) {
      var b = entry(base);
      if (b && isFinite(b.sens_low) && isFinite(b.sens_high) && b.sens_low !== null && b.sens_high !== null) {
        var f = b.range_fmt !== undefined ? b.range_fmt : "0";
        return { value: formatNumber(b.sens_low, f) + "–" + formatNumber(b.sens_high, f),
                 def: "sensitivity range of " + base + (b.sens_note ? " (" + b.sens_note + ")" : ""),
                 verified: b.verified, method: "sensitivity", derived_from: base };
      }
    }
    return null;
  }

  function flagEntry(key) {
    var suf = KEY_ALIASES.flag_suffixes;
    for (var i = 0; i < suf.length; i++) { var e = rawEntry(key + suf[i]); if (e && e.value) return e; }
    return entry(key);
  }

  function getPath(obj, path) {
    if (path === undefined || path === null || path === "") return obj;
    var parts = String(path).split(".");
    var cur = obj;
    for (var i = 0; i < parts.length; i++) {
      if (cur === null || cur === undefined) return undefined;
      var p = parts[i];
      if (Array.isArray(cur) && /^\d+$/.test(p)) { cur = cur[parseInt(p, 10)]; continue; }
      if (typeof cur === "object") {
        if (Object.prototype.hasOwnProperty.call(cur, p)) { cur = cur[p]; continue; }
        // coincidencia sin mayúsculas / por primera palabra ("early" → "Early movers")
        var lk = p.toLowerCase();
        var hit = Object.keys(cur).filter(function (k) {
          var kl = k.toLowerCase();
          return kl === lk || kl.split(/[\s_-]+/)[0] === lk.split(/[\s_-]+/)[0];
        });
        cur = hit.length === 1 ? cur[hit[0]] : undefined;
        continue;
      }
      return undefined;
    }
    return cur;
  }

  /* ---------- formato ---------- */
  function decimalsFor(fmt, v) {
    if (typeof fmt === "number" && isFinite(fmt)) return Math.max(0, Math.round(fmt));
    if (typeof fmt === "string" && fmt.length) {
      var f = fmt.trim();
      if (/^\d+$/.test(f)) return parseInt(f, 10);
      var m = f.match(/\.([0#]+)/);
      if (m) return m[1].length;
      if (/^[+]?[#0,]+%?$/.test(f) || f === "int" || f === "d") return 0;
    }
    if (Number.isInteger(v)) return 0;
    return Math.abs(v) < 1 ? 2 : 1;
  }

  function groupThousands(s) {
    var parts = s.split(".");
    parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    return parts.join(".");
  }

  function formatNumber(v, fmt, opts) {
    opts = opts || {};
    var d = decimalsFor(fmt, v);
    var s = Math.abs(v).toFixed(d);
    var wantsGroup = (typeof fmt === "string" && fmt.indexOf(",") >= 0) || Math.abs(v) >= 10000;
    if (wantsGroup) s = groupThousands(s);
    var isZero = Number(s.replace(/,/g, "")) === 0;
    if (v < 0 && !isZero) s = MINUS + s;
    else if (!isZero && v > 0 && (opts.sign === "always" || (typeof fmt === "string" && fmt.trim().charAt(0) === "+"))) s = "+" + s;
    return s;
  }

  function iso3Of(item) {
    if (item === null || item === undefined) return null;
    var codes = window.COUNTRY_CODES || {}, names = window.NAME_TO_ISO3 || {};
    if (typeof item === "object") {
      if (item.iso3) return String(item.iso3).toUpperCase();
      if (item.ISO3) return String(item.ISO3).toUpperCase();
      if (item.iso2) return iso3Of(String(item.iso2));
      if (item.name) return iso3Of(String(item.name));
      return null;
    }
    var s = String(item).trim();
    if (/^[A-Za-z]{3}$/.test(s) && codes[s.toUpperCase()]) return s.toUpperCase();
    if (/^[A-Za-z]{2}$/.test(s)) {
      var lo = s.toLowerCase();
      var hit = Object.keys(codes).filter(function (k) { return codes[k].iso2 === lo; });
      if (hit.length) return hit[0];
    }
    var n = names[s.toLowerCase()];
    return n || null;
  }

  function nameOf(item) {
    if (item === null || item === undefined) return "";
    if (typeof item === "object") return item.name || item.label || (iso3Of(item) && (window.COUNTRY_CODES[iso3Of(item)] || {}).name) || "";
    var s = String(item).trim();
    var codes = window.COUNTRY_CODES || {};
    if (/^[A-Z]{3}$/.test(s) && codes[s]) return codes[s].name;
    if (/^[A-Za-z]{2}$/.test(s)) { var i3 = iso3Of(s); if (i3 && codes[i3]) return codes[i3].name; }
    return s;
  }

  function joinList(arr) {
    var a = arr.filter(function (x) { return x !== null && x !== undefined && x !== ""; });
    if (a.length <= 1) return a.join("");
    if (a.length === 2) return a[0] + " and " + a[1];
    return a.slice(0, -1).join(", ") + " and " + a[a.length - 1];
  }

  function splitListValue(v) {
    if (Array.isArray(v)) return v;
    if (typeof v === "string" && /[,;]/.test(v)) return v.split(/\s*[,;]\s*/);
    return [v];
  }

  /* Valor formateado de una clave (lo usan también captions.js y el guion). */
  function formatKey(key, o) {
    o = o || {};
    var e = entry(key);
    if (!e) return null;
    var v;
    if (o.say) {
      if (e.say !== undefined && e.say !== null && e.say !== "") return String(e.say);
      v = e.value;
    } else if (o.field) {
      v = e[o.field];
    } else {
      v = e.value;
    }
    if (o.item !== undefined && o.item !== null && o.item !== "") v = getPath(v, o.item);
    if (v === null || v === undefined || (typeof v === "number" && !isFinite(v))) return null;
    if (typeof v === "number") {
      var s = formatNumber(v, o.fmt !== undefined && o.fmt !== null && o.fmt !== "" ? o.fmt : e.fmt, { sign: o.sign });
      if (o.unit !== undefined) s += unitSuffix(o.unit || e.unit);
      return s;
    }
    if (Array.isArray(v)) return joinList(v.map(nameOf));
    if (typeof v === "object") return null;
    return String(v);
  }

  function unitSuffix(u) {
    if (!u) return "";
    var map = { "%": " %", "percent": " %", "per1000": " ‰", "per 1000": " ‰", "‰": " ‰", "years": " years",
                "bn": " bn", "billion": " bn", "million": " M", "M": " M", "R2": "", "x": "×", "ratio": "×" };
    return Object.prototype.hasOwnProperty.call(map, u) ? map[u] : " " + u;
  }

  /* Resuelve {clave}, {clave.say}, {clave.campo} dentro de un texto. */
  function resolveText(str) {
    if (!str) return "";
    return String(str).replace(/\{([A-Za-z_][A-Za-z0-9_]*)(?:\.([A-Za-z_][A-Za-z0-9_]*))?\}/g, function (m, k, f) {
      var out = f === "say" ? formatKey(k, { say: true }) : (f ? formatKey(k, { field: f }) : formatKey(k));
      return out === null ? "—" : out;
    });
  }

  /* ---------- banderas ---------- */
  function flagChip(iso3) {
    var c = (window.COUNTRY_CODES || {})[iso3];
    var span = document.createElement("span");
    span.className = "flagchip";
    span.title = c ? c.name + " (" + iso3 + ")" : iso3;
    if (c && c.iso2) {
      var f = document.createElement("span");
      f.className = "fi fi-" + c.iso2;
      span.appendChild(f);
    }
    var t = document.createElement("span");
    t.className = "iso"; t.textContent = iso3;
    span.appendChild(t);
    return span;
  }

  /* ---------- relleno del DOM ---------- */
  function annotate(el, key, e) {
    var tip = [];
    if (e.def) tip.push(e.def);
    if (e.method) tip.push("method: " + e.method);
    if (e.ci_low !== undefined && e.ci_low !== null && e.ci_high !== undefined && e.ci_high !== null)
      tip.push("CI " + e.ci_low + "–" + e.ci_high);
    if (e.sens_low !== undefined && e.sens_low !== null && e.sens_high !== undefined && e.sens_high !== null)
      tip.push("sens " + e.sens_low + "–" + e.sens_high);
    tip.push("key: " + key + (e.verified === true ? " · verified" : " · UNVERIFIED"));
    el.title = tip.join(" · ");
    if (e.verified !== true) el.classList.add("unverified");
  }

  function fill(root) {
    root = root || document;
    var rep = { missing: {}, unverified: {}, demo: state.demo, source: state.source, filled: 0 };

    function miss(key, el) { rep.missing[key] = (rep.missing[key] || 0) + 1; el.classList.add("missing"); }

    root.querySelectorAll("[data-num]").forEach(function (el) {
      var key = el.getAttribute("data-num");
      el.classList.add("num");
      var e = entry(key);
      var txt = formatKey(key, {
        say: el.hasAttribute("data-say"),
        field: el.getAttribute("data-field") || undefined,
        item: el.getAttribute("data-item") || undefined,
        fmt: el.getAttribute("data-fmt") || undefined,
        sign: el.getAttribute("data-sign") || undefined,
        unit: el.hasAttribute("data-unit") ? el.getAttribute("data-unit") : undefined
      });
      if (txt !== null && el.hasAttribute("data-cap")) txt = txt.charAt(0).toUpperCase() + txt.slice(1);
      // salvaguarda: "about {x.say}" con say = "about seven in ten" → no duplicar "about"
      if (txt !== null && el.hasAttribute("data-say") && /^(about|≈)\s/i.test(txt)) {
        var prev = el.previousSibling;
        if (prev && prev.nodeType === 3 && /(about|≈)\s*$/i.test(prev.textContent)) {
          console.warn("[numbers] '" + key + ".say' already starts with '" + txt.split(" ")[0] + "'; the duplicate is dropped (storyboard: say without 'about')");
          txt = txt.replace(/^(about|≈)\s+/i, "");
        }
      }
      if (txt === null) { el.textContent = "—"; miss(key + (el.getAttribute("data-field") ? "." + el.getAttribute("data-field") : "") + (el.hasAttribute("data-say") ? ".say" : ""), el); if (e) annotate(el, key, e); return; }
      el.textContent = txt;
      if (el.hasAttribute("data-count-from-key")) {
        var e0 = entry(el.getAttribute("data-count-from-key"));
        if (e0 && typeof e0.value === "number" && typeof e.value === "number") {
          el.setAttribute("data-count-from", String(e0.value));
          el.setAttribute("data-count-to", String(e.value));
        }
      }
      annotate(el, key, e);
      if (e.verified !== true) rep.unverified[key] = true;
      rep.filled++;
    });

    root.querySelectorAll("[data-list]").forEach(function (el) {
      var key = el.getAttribute("data-list");
      el.classList.add("num");
      var e = entry(key);
      if (!e || e.value === null || e.value === undefined) { el.textContent = "—"; miss(key, el); return; }
      var items = splitListValue(getPath(e.value, el.getAttribute("data-item") || ""));
      var max = parseInt(el.getAttribute("data-max") || "0", 10);
      if (max > 0) items = items.slice(0, max);
      var names = items.map(nameOf);
      if (el.tagName === "UL" || el.tagName === "OL") {
        el.innerHTML = "";
        names.forEach(function (n) { var li = document.createElement("li"); li.textContent = n; el.appendChild(li); });
      } else {
        el.textContent = joinList(names);
      }
      annotate(el, key, e);
      if (e.verified !== true) rep.unverified[key] = true;
      rep.filled++;
    });

    root.querySelectorAll("[data-flags]").forEach(function (el) {
      var key = el.getAttribute("data-flags");
      el.classList.add("flags");
      el.innerHTML = "";
      var e = flagEntry(key);
      if (!e || e.value === null || e.value === undefined) {
        miss(key, el);
        var ph = document.createElement("span"); ph.className = "flagchip"; ph.textContent = "— — —"; el.appendChild(ph);
        return;
      }
      var items = splitListValue(getPath(e.value, el.getAttribute("data-item") || ""));
      var max = parseInt(el.getAttribute("data-max") || "3", 10);
      var bad = [];
      items.slice(0, max > 0 ? max : items.length).forEach(function (it) {
        var iso3 = iso3Of(it);
        if (iso3) el.appendChild(flagChip(iso3)); else bad.push(String(it));
      });
      if (bad.length) { console.warn("[numbers] unknown country in", key, bad); miss(key + ":unknown", el); }
      var tip = (e.def ? e.def + " · " : "") + "key: " + key + (e.verified === true ? " · verified" : " · UNVERIFIED");
      el.title = tip;
      if (e.verified !== true) { el.classList.add("unverified"); rep.unverified[key] = true; }
      rep.filled++;
    });

    root.querySelectorAll("[data-iso]").forEach(function (el) {
      var iso3 = iso3Of(el.getAttribute("data-iso"));
      if (!iso3) return;
      var chip = flagChip(iso3);
      el.replaceWith(chip);
    });

    var ribbon = document.getElementById("demo-ribbon");
    if (ribbon) ribbon.hidden = !state.demo;

    rep.missingKeys = Object.keys(rep.missing).sort();
    rep.unverifiedKeys = Object.keys(rep.unverified).sort();
    state.report = rep;
    window.NUMBERS_REPORT = rep;
    if (rep.missingKeys.length) console.warn("[numbers] missing keys (" + rep.missingKeys.length + "):", rep.missingKeys.join(", "));
    if (rep.unverifiedKeys.length) console.info("[numbers] unverified keys (" + rep.unverifiedKeys.length + "):", rep.unverifiedKeys.join(", "));
    return rep;
  }

  /* Lista de claves que usa el HTML (para QA y para el guion). */
  function usedKeys(root) {
    root = root || document;
    var keys = {};
    root.querySelectorAll("[data-num],[data-flags],[data-list]").forEach(function (el) {
      var k = el.getAttribute("data-num") || el.getAttribute("data-flags") || el.getAttribute("data-list");
      keys[k] = true;
    });
    root.querySelectorAll("[data-caption]").forEach(function (el) {
      (el.getAttribute("data-caption").match(/\{([A-Za-z_][A-Za-z0-9_]*)/g) || []).forEach(function (m) { keys[m.slice(1)] = true; });
    });
    return Object.keys(keys).sort();
  }

  window.DeckNumbers = {
    load: load, fill: fill, formatKey: formatKey, formatNumber: formatNumber, resolveText: resolveText,
    entry: entry, usedKeys: usedKeys, iso3Of: iso3Of,
    get source() { return state.source; }, get isDemo() { return state.demo; }, get report() { return state.report; },
    isPrint: isPrint
  };
})();
