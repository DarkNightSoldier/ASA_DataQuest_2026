/* =============================================================================
   init.js — arranque del deck
   1. Modo: ?print-pdf → html.is-print (estado final, sin subtítulos)
            ?qa=off → oculta marcadores "unverified/missing" · ?captions=off · ?record=1 (sin cursor)
   2. Inserta elementos comunes desde una sola fuente: pie fijo (ethics badge PIE-0),
      número de página y navegador Q1–Q3 de la cabecera.
   3. Carga numbers.json → rellena cifras; prepara figuras; inicializa reveal.js.
   4. Estados de build: cada <section> recibe .ge-N (N ≤ build actual) y data-build,
      calculados con data-build de los fragmentos visibles. El CSS usa esas clases
      para las transiciones de rejilla dentro de una diapositiva (el auto-animate de
      reveal solo actúa entre diapositivas; el storyboard no pide ninguna pareja).
   5. window.deckReady = true cuando todo está listo (lo esperan los scripts de
      grabación, capturas y PDF); en impresión además window.pdfReady tras 'pdf-ready'.
   ============================================================================= */
(function () {
  "use strict";

  /* ---------- fuente única de textos comunes ---------- */
  var DECK = {
    // PIE-0 del storyboard §8 + "countries only" (sin agregados regionales; cada país una vez)
    badge: "UN WPP 2024 (CC BY 3.0 IGO) · estimates ≤ 2023 · UN medium projection ≥ 2024 (grey) · countries only, no aggregates",
    questions: [
      { n: 1, short: "Q1 · Levers" },
      { n: 2, short: "Q2 · One number?" },
      { n: 3, short: "Q3 · Roads" }
    ],
    maxBuild: 9
  };
  window.DECK = DECK;

  var params = window.location.search;
  var isPrint = /print-pdf/i.test(params);
  var html = document.documentElement;
  if (isPrint) html.classList.add("is-print");
  if (/[?&]qa=off/i.test(params)) html.classList.add("qa-off");
  if (/[?&]record=1/i.test(params)) document.querySelector(".reveal").classList.add("record-mode");

  function sections() { return Array.prototype.slice.call(document.querySelectorAll(".reveal .slides > section")); }

  /* ---------- 2. elementos comunes ---------- */
  function injectCommon() {
    var content = sections().filter(function (s) { return s.hasAttribute("data-qn"); });
    content.forEach(function (sec, i) {
      var ftr = sec.querySelector("footer[data-badge]");
      if (ftr) {
        ftr.innerHTML = "";
        var b = document.createElement("span"); b.className = "badge"; b.textContent = DECK.badge;
        var p = document.createElement("span"); p.className = "pageno"; p.textContent = (i + 1) + " / " + content.length;
        ftr.appendChild(b); ftr.appendChild(p);
      }
      var hdr = sec.querySelector(".hdr");
      if (hdr && !hdr.querySelector(".qnav")) {
        var qn = parseInt(sec.getAttribute("data-qn"), 10);
        var nav = document.createElement("nav");
        nav.className = "qnav";
        nav.setAttribute("aria-label", "Questions");
        DECK.questions.forEach(function (q) {
          var s = document.createElement("span");
          s.textContent = q.short;
          if (q.n === qn) s.className = "on";
          nav.appendChild(s);
        });
        var fi = sec.getAttribute("data-qnav-fragment");
        if (fi !== null) { nav.classList.add("fragment"); nav.setAttribute("data-fragment-index", fi); }
        var row = hdr.querySelector(".hdr-row");
        if (row && row.nextSibling) hdr.insertBefore(nav, row.nextSibling); else hdr.appendChild(nav);
      }
    });
  }

  /* ---------- 4. estados de build ---------- */
  function updateBuildState(sec) {
    var b = parseFloat(sec.getAttribute("data-build-initial") || "0");
    sec.querySelectorAll(".fragment.visible[data-build]").forEach(function (fr) {
      var v = parseFloat(fr.getAttribute("data-build"));
      if (!isNaN(v)) b = Math.max(b, v);
    });
    if (isPrint) b = DECK.maxBuild;
    for (var n = 0; n <= DECK.maxBuild; n++) sec.classList.toggle("ge-" + n, n <= b);
    sec.setAttribute("data-build", String(b));
  }
  var sizeTimer = null;
  function updateAll() {
    sections().forEach(updateBuildState);
    // los marcadores muestran el tamaño de su ranura cuando terminan las transiciones de rejilla
    clearTimeout(sizeTimer);
    sizeTimer = setTimeout(function () { if (window.DeckFigs) DeckFigs.refreshSizes(); }, 1100);
  }

  /* ---------- contador de la portada (2.5 → 8.1 mil millones, 1950 → 2023) ---------- */
  var counterRaf = null;
  function runCounter() {
    if (isPrint) return;
    var el = document.querySelector(".cover .counter[data-count-to]");
    if (!el) return;
    var from = parseFloat(el.getAttribute("data-count-from"));
    var to = parseFloat(el.getAttribute("data-count-to"));
    if (isNaN(from) || isNaN(to)) return;
    var yr = document.querySelector(".cover .counter-year");
    var y0 = yr ? parseInt(yr.getAttribute("data-year-from"), 10) : 1950;
    var y1 = yr ? parseInt(yr.getAttribute("data-year-to"), 10) : 2023;
    var fmt = el.getAttribute("data-fmt") || "1";
    var dur = 3600, t0 = null;
    if (counterRaf) cancelAnimationFrame(counterRaf);
    function step(ts) {
      if (t0 === null) t0 = ts;
      var k = Math.min(1, (ts - t0) / dur);
      var e = 1 - Math.pow(1 - k, 3);
      el.textContent = DeckNumbers.formatNumber(from + (to - from) * e, fmt);
      if (yr) yr.textContent = String(Math.round(y0 + (y1 - y0) * e));
      if (k < 1) counterRaf = requestAnimationFrame(step);
    }
    counterRaf = requestAnimationFrame(step);
  }
  function maybeCounter() {
    var cur = Reveal.getCurrentSlide();
    if (cur && cur.classList.contains("cover") && !cur.querySelector(".fragment.visible")) runCounter();
  }

  /* ---------- 3. arranque ---------- */
  injectCommon();
  if (isPrint) updateAll();

  DeckNumbers.load().then(function () {
    DeckNumbers.fill(document);
    DeckFigs.init(isPrint);

    var toggleQA = function () { html.classList.toggle("qa-off"); };
    Reveal.on("pdf-ready", function () { window.pdfReady = true; });
    return Reveal.initialize({
      width: 1920, height: 1080, margin: 0, minScale: 0.05, maxScale: 4,
      center: false,
      hash: true, fragmentInURL: true, history: false,
      transition: "fade", transitionSpeed: "default", backgroundTransition: "fade",
      controls: false, progress: false, slideNumber: false,
      autoPlayMedia: false,
      autoAnimate: true, autoAnimateDuration: 0.8, autoAnimateEasing: "ease",
      pdfSeparateFragments: false, pdfMaxPagesPerSlide: 1,
      viewDistance: 6, mobileViewDistance: 6,
      navigationMode: "linear",
      keyboard: {
        67: function () { DeckCaptions.toggle(); },   // c → subtítulos on/off
        81: toggleQA                                  // q → marcadores QA on/off
      }
    });
  }).then(function () {
    updateAll();
    Reveal.on("slidechanged", function () { updateAll(); maybeCounter(); });
    Reveal.on("fragmentshown", updateAll);
    Reveal.on("fragmenthidden", updateAll);
    Reveal.on("resize", function () { DeckFigs.refreshSizes(); });
    if (isPrint) updateAll();
    return DeckCaptions.init();
  }).then(function () {
    maybeCounter();
    setTimeout(DeckFigs.refreshSizes, 300);
    window.deckReady = true;
    document.dispatchEvent(new CustomEvent("deck-ready"));
  }).catch(function (err) {
    console.error("[init] deck failed to start:", err);
    window.deckError = String(err && err.stack || err);
  });
})();
