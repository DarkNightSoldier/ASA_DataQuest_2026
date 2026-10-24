/* =============================================================================
   figs.js — figuras con marcador de posición
   · <img data-fig="nombre">    → src = ../figures/static/nombre.png (si no trae src)
   · <video data-fig="nombre">  → src = ../figures/animated/nombre.mp4, poster = ../figures/static/nombre.png
   Si el archivo no existe:
     - video → se muestra el póster (PNG estático); si tampoco existe → marcador gris
     - img   → marcador gris con el nombre, la ruta esperada y el tamaño de la ranura
     - data-optional → se oculta sin marcador
   En modo PDF (?print-pdf) todo <video> se sustituye por su póster (<img>), y para cada figura se
   prueba primero ../figures/static/nombre_print.png (versión opcional con otra proporción para la
   página impresa) y después nombre.png.
   window.FIG_REPORT = {ok:[], poster:[], missing:[], optional_missing:[]}
   DeckFigs.slots() → tamaño en px de diapositiva de cada ranura (para figures-static).
   ============================================================================= */
(function () {
  "use strict";
  var STATIC = "../figures/static/";
  var ANIM = "../figures/animated/";
  var report = { ok: [], poster: [], missing: [], optional_missing: [] };

  function push(list, name) { if (report[list].indexOf(name) < 0) report[list].push(name); }

  function placeholder(name, expected, el) {
    var ph = document.createElement("div");
    ph.className = "fig-ph" + (el && el.classList.contains("bg-dots") ? " bg-dots" : "");
    ph.setAttribute("data-fig", name);
    ph.setAttribute("data-ph", "1");
    ph.innerHTML = '<div class="ph-name"></div><div class="ph-path"></div><div class="ph-size"></div>';
    ph.querySelector(".ph-name").textContent = name;
    ph.querySelector(".ph-path").textContent = expected.join("  ·  ");
    // conserva clases de fragmento/estado del original
    if (el) {
      ["fragment", "fade-out", "print-hide", "visible", "overlay-fig"].forEach(function (c) { if (el.classList.contains(c)) ph.classList.add(c); });
      if (el.hasAttribute("data-fragment-index")) ph.setAttribute("data-fragment-index", el.getAttribute("data-fragment-index"));
    }
    return ph;
  }

  function sizeLabel(el) {
    var scale = (window.Reveal && Reveal.getScale && Reveal.isReady && Reveal.isReady()) ? Reveal.getScale() : 1;
    var r = el.getBoundingClientRect();
    if (!r.width || !r.height) return "";
    var w = Math.round(r.width / scale), h = Math.round(r.height / scale);
    return "slot " + w + " × " + h + " px";
  }

  function refreshSizes() {
    document.querySelectorAll(".fig-ph[data-ph]").forEach(function (ph) {
      var s = ph.querySelector(".ph-size");
      if (s) s.textContent = sizeLabel(ph);
    });
  }

  var PRINT = false;

  function handleImg(img) {
    var name = img.getAttribute("data-fig");
    var optional = img.hasAttribute("data-optional");
    var candidates = img.getAttribute("src") ? [img.getAttribute("src")]
      : (PRINT ? [STATIC + name + "_print.png", STATIC + name + ".png"] : [STATIC + name + ".png"]);
    var i = 0;
    function fail() {
      i++;
      if (i < candidates.length) { img.setAttribute("src", candidates[i]); return; }
      img.removeEventListener("error", fail);
      if (optional) { img.style.display = "none"; img.classList.add("print-hide"); push("optional_missing", name); return; }
      push("missing", name);
      img.replaceWith(placeholder(name, ["figures/static/" + name + ".png"], img));
      refreshSizes();
    }
    img.addEventListener("error", fail);
    img.addEventListener("load", function () { push("ok", name); }, { once: true });
    if (!img.getAttribute("src")) img.setAttribute("src", candidates[0]);
    else if (img.complete && img.naturalWidth === 0) fail();
  }

  function posterImg(video, name, posterSrc) {
    var img = document.createElement("img");
    img.setAttribute("data-fig", name);
    img.setAttribute("alt", video.getAttribute("aria-label") || name);
    img.className = video.className;
    var candidates = PRINT ? [STATIC + name + "_print.png", posterSrc] : [posterSrc];
    var i = 0;
    return new Promise(function (resolve) {
      img.onload = function () { push("poster", name); resolve(img); };
      img.onerror = function () { i++; if (i < candidates.length) img.src = candidates[i]; else resolve(null); };
      img.src = candidates[0];
    });
  }

  function handleVideo(video, printMode) {
    var name = video.getAttribute("data-fig");
    var src = video.getAttribute("src") || (ANIM + name + ".mp4");
    var poster = video.getAttribute("poster") || (STATIC + name + ".png");
    var expected = ["figures/animated/" + name + ".mp4", "figures/static/" + name + ".png"];

    function fallback() {
      return posterImg(video, name, poster).then(function (img) {
        if (img) { video.replaceWith(img); }
        else { push("missing", name); video.replaceWith(placeholder(name, expected, video)); refreshSizes(); }
      });
    }

    if (printMode) { fallback(); return; }
    video.muted = true;
    video.setAttribute("muted", "");
    video.setAttribute("playsinline", "");
    video.setAttribute("preload", video.getAttribute("preload") || "auto");
    video.setAttribute("poster", poster);
    video.addEventListener("error", function () { fallback(); }, { once: true });
    video.addEventListener("loadedmetadata", function () { push("ok", name); }, { once: true });
    video.setAttribute("src", src);
  }

  function init(printMode) {
    PRINT = !!printMode;
    document.querySelectorAll("img[data-fig]").forEach(handleImg);
    document.querySelectorAll("video[data-fig]").forEach(function (v) { handleVideo(v, printMode); });
    window.addEventListener("resize", function () { setTimeout(refreshSizes, 50); });
  }

  /* Tamaño de cada ranura en px de diapositiva (estado actual del DOM). */
  function slots() {
    var scale = (window.Reveal && Reveal.getScale) ? Reveal.getScale() : 1;
    var out = {};
    document.querySelectorAll("[data-fig]").forEach(function (el) {
      var name = el.getAttribute("data-fig");
      var box = el.closest(".slot") || el;
      var r = box.getBoundingClientRect();
      if (!r.width || !r.height) return;
      var sec = el.closest("section");
      var idx = sec ? Array.prototype.indexOf.call(document.querySelectorAll(".reveal .slides section"), sec) : -1;
      // visible = ningún fragmento ancestro oculto (ni fade-out ya disparado)
      var visible = true, node = el;
      while (node && node !== sec) {
        if (node.classList && node.classList.contains("fragment")) {
          var shown = node.classList.contains("visible");
          if (node.classList.contains("fade-out") ? shown : !shown) { visible = false; break; }
        }
        node = node.parentElement;
      }
      if (!el.hasAttribute("data-optional") && el.style.display === "none") visible = false;
      out[name] = { w: Math.round(r.width / scale), h: Math.round(r.height / scale), visible: visible,
                    aspect: Math.round((r.width / r.height) * 100) / 100, slide: idx,
                    kind: el.tagName.toLowerCase() === "video" ? "mp4" : (el.classList.contains("fig-ph") ? "placeholder" : "png") };
    });
    return out;
  }

  window.FIG_REPORT = report;
  window.DeckFigs = { init: init, slots: slots, refreshSizes: refreshSizes, report: report };
})();
