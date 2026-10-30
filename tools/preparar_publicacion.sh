#!/usr/bin/env bash
# =============================================================================
# tools/preparar_publicacion.sh — rama huérfana "public" con el contenido entregable
#
# Por qué (docs/correcciones.md §J y P-02; jurado_etica I-3): la historia interna de `main` guarda
# material que NO debe publicarse — capturas de vídeos y repositorios de otros equipos (con caras de
# estudiantes), análisis críticos con nombre de otros equipos y las evaluaciones internas del jurado —
# y rutas absolutas de la máquina de desarrollo. En vez de reescribir `main`, este script crea una rama
# SIN HISTORIA (`public`, un solo commit) con la instantánea del commit pedido, sin esas rutas.
#
# Uso (desde cualquier carpeta del repositorio; el árbol de trabajo debe estar limpio):
#   bash tools/preparar_publicacion.sh                  # rama `public` desde HEAD
#   bash tools/preparar_publicacion.sh --tag            # además, etiqueta anotada v1.0-submission
#   bash tools/preparar_publicacion.sh --desde <commit> --rama <nombre>
#
# NO hace `git push`. Después (el equipo, el 29-oct-2026):
#   git push -u origin public:main --follow-tags         # o: git push origin public:main && git push origin v1.0-submission
# y abrir https://github.com/DarkNightSoldier/ASA_DataQuest_2026 en una ventana privada.
#
# Autor del commit público: el Team Leader con su correo institucional (docs/equipo.json → team_leader),
# para que el correo personal de los commits internos no quede publicado.
# =============================================================================
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO"

RAMA="public"
DESDE="HEAD"
TAG=0
ETIQUETA="v1.0-submission"
while [ $# -gt 0 ]; do
  case "$1" in
    --tag) TAG=1 ;;
    --rama) RAMA="$2"; shift ;;
    --desde) DESDE="$2"; shift ;;
    --etiqueta) ETIQUETA="$2"; shift ;;
    -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
    *) echo "argumento desconocido: $1" >&2; exit 2 ;;
  esac
  shift
done

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "ERROR: hay cambios sin commit; haga commit (o stash) antes de preparar la publicación." >&2
  exit 1
fi

SRC_FULL="$(git rev-parse --verify "$DESDE^{commit}")"
SRC="$(git rev-parse --short "$SRC_FULL")"
FECHA="$(date '+%Y-%m-%dT%H:%M:%S%z')"

# Identidad pública (docs/equipo.json → team_leader)
NOMBRE_PUB="$(python3 -c 'import json;d=json.load(open("docs/equipo.json"));print(d["team_leader"]["name"])')"
CORREO_PUB="$(python3 -c 'import json;d=json.load(open("docs/equipo.json"));print(d["team_leader"]["email"])')"
EQUIPO="$(python3 -c 'import json;print(json.load(open("docs/equipo.json"))["team_name"])')"

# Rutas que no se publican (material de terceros y evaluaciones internas)
EXCLUIR_DIRS=(docs/referencia_ganadores)
EXCLUIR_ARCH=(docs/01_analisis_ganadores_2025.md docs/01b_otros_equipos_2025_2026.md docs/01c_otros_videos_2025.md)
EXCLUIR_GLOB='docs/jurado_*.md'
PATRON_EXCLUIDOS='referencia_ganadores/|01_analisis_ganadores_2025\.md|01b_otros_equipos_2025_2026\.md|01c_otros_videos_2025\.md|jurado_[a-z]+\.md'

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
ARBOL="$TMP/arbol"
mkdir -p "$ARBOL"
git archive "$SRC_FULL" | tar -x -C "$ARBOL"

for d in "${EXCLUIR_DIRS[@]}"; do rm -rf "${ARBOL:?}/$d"; done
for f in "${EXCLUIR_ARCH[@]}"; do rm -f "${ARBOL:?}/$f"; done
# shellcheck disable=SC2086
rm -f "$ARBOL"/$EXCLUIR_GLOB
# filas del índice que apuntan a lo excluido
if [ -f "$ARBOL/docs/INDICE.md" ]; then
  grep -Ev "$PATRON_EXCLUIDOS" "$ARBOL/docs/INDICE.md" > "$TMP/indice" || true
  cat "$TMP/indice" > "$ARBOL/docs/INDICE.md"
fi

# Rutas absolutas de la máquina de desarrollo → marcadores neutros (solo archivos de texto).
# Los prefijos se arman por partes para que este script no los contenga literalmente (si no, se
# sustituiría a sí mismo y la comprobación final lo marcaría). También se cubren $HOME y $REPO de quien
# lo ejecute, por si no es la misma máquina.
DEV_HOME="/home/""darkns"
DEV_REPO="$DEV_HOME/Documents/ASA_Dataquest/RepoGithub"
TMP_PREF="/tmp/""claude-"
PAT_RUTAS="${TMP_PREF}|${DEV_HOME}/"
if [ "$HOME" != "$DEV_HOME" ] && [ "${#HOME}" -gt 1 ]; then PAT_RUTAS="$PAT_RUTAS|$HOME/"; fi
n_rutas=0
while IFS= read -r -d '' f; do
  sed -i -E \
    -e "s#${TMP_PREF}[0-9]+/[^/[:space:]\"]+/[0-9a-f-]+/scratchpad#<scratchpad>#g" \
    -e "s#${TMP_PREF}[0-9]+/[^[:space:]\"'\`)]*#<scratchpad>#g" \
    -e "s#${REPO}#<repo>#g" \
    -e "s#${DEV_REPO}#<repo>#g" \
    -e "s#$(dirname "$REPO")#<repo>/..#g" \
    -e "s#$(dirname "$DEV_REPO")#<repo>/..#g" \
    -e "s#${DEV_HOME}/#~/#g" \
    -e "s#${HOME}/#~/#g" \
    "$f"
  n_rutas=$((n_rutas + 1))
done < <(grep -rlIZ -E "$PAT_RUTAS" "$ARBOL" || true)

cat > "$ARBOL/PUBLIC_SNAPSHOT.md" <<EOF
# Public snapshot · instantánea pública

This repository is a **one-commit snapshot** of the team's internal repository at commit \`$SRC\`
(made on $FECHA with \`tools/preparar_publicacion.sh\`). It is the submitted work of Team $EQUIPO
(ASA International DataQuest 2026).

**Left out on purpose** (they are kept by the team and are not part of the submission):

- \`docs/referencia_ganadores/\` — screenshots of other teams' public videos and repositories (some show faces);
- \`docs/01_analisis_ganadores_2025.md\`, \`docs/01b_otros_equipos_2025_2026.md\`, \`docs/01c_otros_videos_2025.md\` —
  our internal notes on other teams' work (what we adopted from them is credited in \`docs/correcciones.md\`, J-12);
- \`docs/jurado_*.md\` — internal reviews of our own draft.

Absolute paths of the development machine were replaced by \`<repo>\`, \`<scratchpad>\` and \`~\` in $n_rutas text files
(they appear in QA notes and in printed notebook outputs; no result changes). Links to the files left out may be dangling.

**Dates and hashes.** Internal commit hashes cited in the documents (for example \`2a0ab7b\`, the commit that fixed the
hypotheses on 2026-10-23) belong to the internal history, which is not public. What anyone can check here is the
file itself: \`sha256sum docs/hipotesis_preinscritas.md\` must start with the hash printed on the references slide
(full hash in \`docs/equipo.json\`). The team can share the internal history (a \`git bundle\`) on request.

---

Este repositorio es una **instantánea de un solo commit** del repositorio interno del equipo (commit \`$SRC\`), sin el
material de otros equipos ni las revisiones internas, y con las rutas absolutas de la máquina de desarrollo sustituidas.
Ver la lista de arriba.
EOF

# Índice temporal → árbol → commit sin padres
export GIT_INDEX_FILE="$TMP/index"
git --git-dir="$REPO/.git" --work-tree="$ARBOL" -C "$ARBOL" add -A -f .
TREE="$(git --git-dir="$REPO/.git" --work-tree="$ARBOL" -C "$ARBOL" write-tree)"
unset GIT_INDEX_FILE

export GIT_AUTHOR_NAME="$NOMBRE_PUB (Team Leader, $EQUIPO)" GIT_AUTHOR_EMAIL="$CORREO_PUB"
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" GIT_COMMITTER_EMAIL="$CORREO_PUB"
COMMIT="$(printf '%s\n\n%s\n' \
  "$EQUIPO · ASA International DataQuest 2026 — public snapshot" \
  "One-commit snapshot of internal commit $SRC (tools/preparar_publicacion.sh, $FECHA). See PUBLIC_SNAPSHOT.md." \
  | git commit-tree "$TREE")"
git update-ref "refs/heads/$RAMA" "$COMMIT"

# Comprobaciones: nada excluido, ninguna ruta de la máquina, ningún correo personal
fallos=0
if git ls-tree -r --name-only "$RAMA" | grep -Eq "^docs/($PATRON_EXCLUIDOS)"; then
  echo "ERROR: la rama $RAMA contiene rutas excluidas" >&2; fallos=1
fi
if git grep -I -q -E -e "$PAT_RUTAS" "$RAMA" -- . ; then
  echo "ERROR: quedan rutas absolutas de la máquina en $RAMA:" >&2
  git grep -I -l -E -e "$PAT_RUTAS" "$RAMA" -- . >&2 || true; fallos=1
fi
if git grep -I -q -i -E -e '@g''mail[.]com' "$RAMA" -- . ; then
  echo "ERROR: hay un correo personal (dominio de Google) en $RAMA" >&2; fallos=1
fi
grande="$(git ls-tree -r -l "$RAMA" | awk '$4 > 50*1024*1024 {print $5}')"
if [ -n "$grande" ]; then echo "AVISO: archivos > 50 MB (GitHub avisa a partir de 50 MB): $grande" >&2; fi
if [ "$fallos" -ne 0 ]; then
  git update-ref -d "refs/heads/$RAMA"
  echo "Rama $RAMA eliminada por los errores de arriba." >&2
  exit 1
fi

if [ "$TAG" -eq 1 ]; then
  if git rev-parse -q --verify "refs/tags/$ETIQUETA" >/dev/null; then
    actual="$(git rev-parse "$ETIQUETA^{commit}")"
    if [ "$actual" != "$COMMIT" ]; then
      echo "AVISO: la etiqueta $ETIQUETA ya existe y apunta a otro commit ($actual); no se toca." >&2
      echo "       Bórrela a mano (git tag -d $ETIQUETA) y vuelva a correr con --tag si quiere moverla." >&2
    fi
  else
    git tag -a "$ETIQUETA" -m "$EQUIPO · ASA International DataQuest 2026 submission (snapshot of $SRC)" "$COMMIT"
    echo "Etiqueta anotada $ETIQUETA → $(git rev-parse --short "$COMMIT")"
  fi
fi

n_arch="$(git ls-tree -r --name-only "$RAMA" | wc -l)"
echo "Rama $RAMA → $(git rev-parse --short "$COMMIT") (sin historia; instantánea de $SRC; $n_arch archivos; autor $GIT_AUTHOR_NAME <$CORREO_PUB>)"
echo "Rutas de la máquina sustituidas en $n_rutas archivos de texto."
echo "Siguiente paso (equipo, 29-oct): git push -u origin $RAMA:main --follow-tags   ·   ningún agente hace push."
