/* =============================================================================
   captions.js — subtítulos sincronizados por fragmento + reproducción de vídeos
   · Muestra en #caption-bar el data-caption del estado activo (fragmento actual o,
     si no hay fragmentos visibles, el de la <section>). " | " separa bloques;
     {clave} y {clave.say} se resuelven con DeckNumbers.
   · Reparto temporal de bloques: captions[] de video_timings.json (t en s desde el
     inicio del paso) → si no, duración del paso / n bloques → si no, 3,2 s por bloque.
   · Al mostrarse un fragmento que contiene <video>, lo reproduce desde el inicio;
     al ocultarse (o al salir de la diapositiva) lo pausa y lo rebobina.
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
    if (timing && Array.isArray(timing.captions) && timing.captions.length) {
      timing.captions.forEach(function (c, i) {
        var fn = function () { show(resolve(c.text)); };
        if (!c.t || i === 0) fn(); else timers.push(setTimeout(fn, c.t * 1000));
      });
      return;
    }
    chunks = (step.caption || "").split(/\s*\|\s*/).filter(function (c) { return c.length; });
    if (!chunks.length) { show(""); return; }
    var dur = timing && timing.duration ? timing.duration : null;
    var each = dur ? dur / chunks.length : DEFAULT_CHUNK_S;
    chunks.forEach(function (c, i) {
      var fn = function () { show(resolve(c)); };
      if (i === 0) fn(); else timers.push(setTimeout(fn, i * each * 1000));
    });
  }

  /* ---------- vídeos ---------- */
  function videosIn(el) {
    if (!el) return [];
    var list = Array.prototype.slice.call(el.querySelectorAll("video"));
    if (el.tagName === "VIDEO") list.unshift(el);
    return list;
  }
  function play(v) { try { v.pause(); v.currentTime = 0; var p = v.play(); if (p && p.catch) p.catch(function () {}); } catch (e) {} }
  function stop(v) { try { v.pause(); v.currentTime = 0; } catch (e) {} }

  function onShown(ev) { (ev.fragments || [ev.fragment]).forEach(function (fr) { videosIn(fr).forEach(play); }); update(); }
  function onHidden(ev) { (ev.fragments || [ev.fragment]).forEach(function (fr) { videosIn(fr).forEach(stop); }); update(); }
  function onSlide(ev) {
    if (ev.previousSlide) videosIn(ev.previousSlide).forEach(stop);
    // vídeos que no están dentro de un fragmento: se reproducen al entrar en la diapositiva
    if (ev.currentSlide) videosIn(ev.currentSlide).forEach(function (v) { if (!v.closest(".fragment")) play(v); });
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
