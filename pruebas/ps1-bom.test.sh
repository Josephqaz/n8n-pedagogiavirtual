#!/usr/bin/env bash
# Windows PowerShell 5.1 lee como ANSI los .ps1 sin BOM y rompe las tildes. Uso: bash pruebas/ps1-bom.test.sh
set -uo pipefail
cd "$(dirname "$0")/.."
fallos=0
for f in scripts/*.ps1; do
  [ "$(head -c 3 "$f" | od -An -tx1 | tr -d ' ')" = "efbbbf" ] || { echo "FALLO: $f no empieza con BOM UTF-8"; fallos=1; }
done
[ "$fallos" -eq 0 ] && echo "ps1-bom.test.sh: todo bien"
exit "$fallos"
