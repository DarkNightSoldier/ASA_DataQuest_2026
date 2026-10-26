/* =============================================================================
   captions.js — subtítulos sincronizados por fragmento + reproducción de vídeos
   · Muestra en #caption-bar el data-caption del estado activo (fragmento actual o,
     si no hay fragmentos visibles, el de la <section>). " | " separa bloques;
     {clave} y {clave.say} se resuelven con DeckNumbers.
   · Reparto temporal de bloques: captions[] de video_timings.json (t en s desde el
     inicio del paso) → si no, duración del paso / n bloques → si no, 3,2 s por bloque.
   · Al mostrarse un fragmento que contiene <video>, lo reproduce desde el inicio (solo el build
     más reciente; los saltados quedan en su último fotograma); al ocultarse lo rebobina.
   · window.slideTimings ← slides/script/video_timings.json (si existe).
   · window.deckSteps() → lista ordenada de estados {id, h, f, build, caption}.
   ============================================================================= */
(function () {
  "use strict";
  var TIMINGS_URL = "script/video_timings.json";
  var DEFAULT_CHUNK_S = 3.2;
  var bar, textEl, timers = [];

  window.slideTimings = null;

  function loadTimings() {
    if (window.location.protocol === "file:") return Promise.resolve(window.VIDEO_TIMINGS || null);
    return fetch(TIMINGS_URL, { cache: "no-store" })
      .then(function (r) { return r.ok ? r.json() : null; })
      .catch(function () { return null; })
      .then(function (t) {
        if (t && Array.isArray(t.steps)) {
          t.byId = {};
          t.steps.forEach(function (s) { if (s.id) t.byId[s.id] = s; });
        }
        window.slideTimings = t;
        if (t) console.info("[captions] video_timings.json loaded:", (t.steps || []).length, "steps");
        return t;
      });
  }

  function sections() { return Array.prototype.slice.call(document.querySelectorAll(".reveal .slides > section")); }

  function fragIndex(el) { var v = el.getAttribute("data-fragment-index"); return v === null ? NaN : parseInt(v, 10); }

  /* Estados del deck en orden (requiere Reveal inicializado: índices ya normalizados). */
  function deckSteps() {
    var out = [];
    sections().forEach(function (sec, h) {
      out.push({ id: sec.getAttribute("data-step") || ("h" + h + ".f-1"), h: h, f: -1,
                 build: sec.getAttribute("data-build-initial") || "0",
                 caption: sec.getAttribute("data-caption") || "" });
      var groups = {};
      sec.querySelectorAll(".fragment").forEach(function (fr) {
        var i = fragIndex(fr); if (isNaN(i)) return;
        (groups[i] = groups[i] || []).push(fr);
      });
      Object.keys(groups).map(Number).sort(function (a, b) { return a - b; }).forEach(function (i) {
        var g = groups[i];
        var lead = g.filter(function (x) { return x.hasAttribute("data-step"); })[0] || g[0];
        var capEl = g.filter(function (x) { return x.hasAttribute("data-caption"); })[0];
        var buildEl = g.filter(function (x) { return x.hasAttribute("data-build"); })[0];
        out.push({ id: lead.getAttribute("data-step") || ("h" + h + ".f" + i), h: h, f: i,
                   build: buildEl ? buildEl.getAttribute("data-build") : null,
                   caption: capEl ? capEl.getAttribute("data-caption") : "" });
      });
    });
    return out;
  }
  window.deckSteps = deckSteps;

  function currentState() {
    var sec = Reveal.getCurrentSlide();
    var h = Reveal.getIndices().h;
    var vis = Array.prototype.slice.call(sec.querySelectorAll(".fragment.visible"))
      .filter(function (fr) { return !isNaN(fragIndex(fr)); });
    var f = -1;
    vis.forEach(function (fr) { f = Math.max(f, fragIndex(fr)); });
    return { sec: sec, h: h, f: f };
  }

  function stepFor(st) {
    var steps = deckSteps();
    for (var i = 0; i < steps.length; i++) if (steps[i].h === st.h && steps[i].f === st.f) return steps[i];
    return null;
  }

  function clearTimers() { timers.forEach(clearTimeout); timers = []; }

  function show(text) {
    if (!bar) return;
    var t = (text || "").trim();
    textEl.textContent = t;
    bar.classList.toggle("empty", t.length === 0);
  }

  function resolve(s) { return window.DeckNumbers ? DeckNumbers.resolveText(s) : s; }

  function update() {
    if (!bar || !window.Reveal || !Reveal.isReady()) return;
    clearTimers();
    var st = currentState();
    var step = stepFor(st);
    if (!step) { show(""); return; }
    var timing = window.slideTimings && window.slideTimings.byId ? window.slideTimings.byId[step.id] : null;
    var chunks;
    /* data-cue = "paso:bloque" en la <section> activa: el CSS resalta lo que nombra cada bloque
       (p. ej. la fila de la tabla de s4.b3 que se está leyendo; corrector-final, QA-slides M8) */
    var cueSec = st.sec;
    var cue = function (i) { if (cueSec) cueSec.setAttribute("data-cue", step.id + ":" + i); };
    sections().forEach(function (x) { if (x !== cueSec) x.removeAttribute("data-cue"); });
    cue(0);
    if (timing && Array.isArray(timing.captions) && timing.captions.length) {
      timing.captions.forEach(function (c, i) {
        var fn = function () { show(resolve(c.text)); cue(i); };
        if (!c.t || i === 0) fn(); else timers.push(setTimeout(fn, c.t * 1000));
      });
      return;
    }
    chunks = (step.caption || "").split(/\s*\|\s*/).filter(function (c) { return c.length; });
    if (!chunks.length) { show(""); return; }
    var dur = timing && timing.duration ? timing.duration : null;
    var each = dur ? dur / chunks.length : DEFAULT_CHUNK_S;
    chunks.forEach(function (c, i) {
      var fn = function () { show(resolve(c)); cue(i); };
      if (i === 0) fn(); else timers.push(setTimeout(fn, i * each * 1000));
    });
  }

  /* ---------- vídeos ----------
     · Al avanzar un build, solo se reproduce (desde 0) el vídeo del fragmento recién mostrado con el
       índice más alto; si se salta varios builds de golpe (navegación directa, capturas, ?#/2/4), los
       vídeos de los builds intermedios se dejan en su ÚLTIMO fotograma (= póster), no en el primero.
     · Un fragmento que se oculta (retroceso) rebobina su vídeo; al salir de la diapositiva se pausa.
     · Al volver a una diapositiva con builds ya visibles, sus vídeos muestran el último fotograma.
     · Los fragmentos fade-out / fade-in-then-out que se disparan no reproducen vídeo (se están ocultando). */
  function videosIn(el) {
    if (!el) return [];
    var list = Array.prototype.slice.call(el.querySelectorAll("video"));
    if (el.tagName === "VIDEO") list.unshift(el);
    return list;
  }
  /* Sin cabeceras Range (python http.server) Chrome no puede buscar dentro del MP4 (seekable = [0, 0]):
     entonces "volver al inicio" = load() y "último fotograma" = load() → se muestra el póster, que es
     justamente el último fotograma (README §3). Con un servidor con Range se usa currentTime. */
  function canSeek(v, t) {
    try { for (var i = 0; i < v.seekable.length; i++) if (v.seekable.start(i) <= t && v.seekable.end(i) >= t) return true; } catch (e) {}
    return false;
  }
  function rewind(v) { if (v.currentTime > 0 || v.ended) { if (canSeek(v, 0)) v.currentTime = 0; else v.load(); } }
  function play(v) { try { v.pause(); rewind(v); var p = v.play(); if (p && p.catch) p.catch(function () {}); } catch (e) {} }
  function stop(v) { try { v.pause(); rewind(v); } catch (e) {} }
  function toEnd(v) {
    try {
      v.pause();
      var d = v.duration;
      if (isFinite(d) && d > 0 && canSeek(v, d - 0.05)) v.currentTime = d - 0.05;
      else if (v.currentTime > 0 || v.ended || v.readyState >= 2) v.load();   // vuelve a mostrar el póster
    } catch (e) {}
  }
  function hiding(fr) { return fr.classList.contains("fade-out") || fr.classList.contains("fade-in-then-out"); }
  function isShownNow(v, sec) {
    var node = v, shown = true;
    while (node && node !== sec) {
      if (node.classList && node.classList.contains("fragment")) {
        var vis = node.classList.contains("visible");
        if (node.classList.contains("fade-out") ? vis : !vis) { shown = false; break; }
      }
      node = node.parentElement;
    }
    return shown;
  }

  function onShown(ev) {
    var frs = ev.fragments || [ev.fragment];
    var maxI = -Infinity;
    frs.forEach(function (fr) { var i = fragIndex(fr); if (!isNaN(i)) maxI = Math.max(maxI, i); });
    frs.forEach(function (fr) {
      // solo los vídeos cuyo fragmento más cercano es este (no los de fragmentos anidados aún ocultos)
      var vids = videosIn(fr).filter(function (v) { return v.closest(".fragment") === fr; });
      if (!vids.length) return;
      if (hiding(fr)) { vids.forEach(function (v) { try { v.pause(); } catch (e) {} }); return; }
      vids.forEach(fragIndex(fr) === maxI ? play : toEnd);
    });
    update();
  }
  function onHidden(ev) { (ev.fragments || [ev.fragment]).forEach(function (fr) { if (!hiding(fr)) videosIn(fr).forEach(stop); }); update(); }
  function onSlide(ev) {
    if (ev.previousSlide) videosIn(ev.previousSlide).forEach(stop);
    if (ev.currentSlide) {
      var sec = ev.currentSlide;
      videosIn(sec).forEach(function (v) {
        if (!v.closest(".fragment")) play(v);          // vídeo fijo de la diapositiva
        else if (isShownNow(v, sec)) toEnd(v);         // build ya visible al entrar: último fotograma
      });
    }
    update();
  }

  function init() {
    bar = document.getElementById("caption-bar");
    textEl = bar ? bar.querySelector(".caption-text") : null;
    if (/[?&]captions=off/i.test(window.location.search)) document.documentElement.classList.add("captions-off");
    Reveal.on("fragmentshown", onShown);
    Reveal.on("fragmenthidden", onHidden);
    Reveal.on("slidechanged", onSlide);
    update();
    return loadTimings().then(function () { update(); });
  }

  function toggle() { document.documentElement.classList.toggle("captions-off"); }

  window.DeckCaptions = { init: init, update: update, toggle: toggle, deckSteps: deckSteps, loadTimings: loadTimings };
})();
