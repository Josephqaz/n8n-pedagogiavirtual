#!/usr/bin/env bash
# Prueba de scripts/revisar-enlaces.sh. Uso: bash pruebas/revisar-enlaces.test.sh
set -uo pipefail
cd "$(dirname "$0")/.."
fallos=0
d=.tmp/prueba-enlaces
rm -rf "$d" && mkdir -p "$d/sub"
printf 'Ver [[No existe]] y [[Nota B|alias]] y [[Nota B#Sección]].\n' > "$d/Nota A.md"
printf 'Vuelve a [[Nota A]].\n' > "$d/sub/Nota B.md"

salida=$(DOCS_DIR="$d" bash scripts/revisar-enlaces.sh 2>&1); codigo=$?
[ "$codigo" -eq 1 ] || { echo "FALLO: con enlace roto debía salir 1 y salió $codigo"; fallos=1; }
grep -q "No existe" <<<"$salida" || { echo "FALLO: no nombra 'No existe'"; fallos=1; }
grep -q "Nota B" <<<"$salida" && { echo "FALLO: marca como roto 'Nota B', que existe"; fallos=1; }

rm "$d/Nota A.md"; printf 'Solo [[Nota B]].\n' > "$d/Nota A.md"
DOCS_DIR="$d" bash scripts/revisar-enlaces.sh >/dev/null 2>&1; codigo=$?
[ "$codigo" -eq 0 ] || { echo "FALLO: sin enlaces rotos debía salir 0 y salió $codigo"; fallos=1; }

[ "$fallos" -eq 0 ] && echo "revisar-enlaces.test.sh: todo bien"
exit "$fallos"
