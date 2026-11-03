#!/usr/bin/env bash
# Comprueba que cada [[enlace]] de docs/ lleva a una nota que existe. Sale con 1 si hay alguno roto.
# Uso: bash scripts/revisar-enlaces.sh      (o DOCS_DIR=otra/carpeta)
set -euo pipefail
cd "$(dirname "$0")/.."
DOCS_DIR="${DOCS_DIR:-docs}"

notas=$(find "$DOCS_DIR" -name '*.md' -not -path '*/superpowers/*' -printf '%f\n' | sed 's/\.md$//' | sort -u)
rotos=0
while IFS= read -r -d '' f; do
  # Saca el destino de cada [[destino|alias]] o [[destino#sección]].
  while IFS= read -r destino; do
    [ -z "$destino" ] && continue
    if ! grep -qxF -- "$destino" <<<"$notas"; then
      echo "$f: [[${destino}]] no lleva a ninguna nota"
      rotos=1
    fi
  done < <(grep -oE '\[\[[^]]+\]\]' "$f" | sed -E 's/^\[\[//; s/\]\]$//; s/[|#].*$//' || true)
done < <(find "$DOCS_DIR" -name '*.md' -not -path '*/superpowers/*' -print0)

[ "$rotos" -eq 0 ] && echo "Enlaces correctos."
exit "$rotos"
