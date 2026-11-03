#!/usr/bin/env bash
# Prueba de scripts/revisar.sh. Uso: bash pruebas/revisar.test.sh
set -uo pipefail
cd "$(dirname "$0")/.."
fallos=0
d=.tmp/prueba-revisar
rm -rf "$d" && mkdir -p "$d/malos" "$d/token"

printf '{"id":"Roto","nodes": [' > "$d/malos/Roto.json"
printf '{"id":"ConDatos","name":"x","nodes":[{"credentials":{"httpHeaderAuth":{"id":"1","name":"x","data":"abc"}}}],"connections":{}}' > "$d/malos/ConDatos.json"
printf '{"id":"ConToken","name":"x","nodes":[{"parameters":{"value":"Bearer abcdef123456"}}],"connections":{}}' > "$d/token/ConToken.json"

salida=$(FLUJOS_DIR="$d/malos" bash scripts/revisar.sh 2>&1); codigo=$?
[ "$codigo" -eq 1 ] || { echo "FALLO: malos debía salir 1 y salió $codigo"; fallos=1; }
grep -q "Roto.json" <<<"$salida" || { echo "FALLO: no nombra Roto.json"; fallos=1; }
grep -q "ConDatos.json" <<<"$salida" || { echo "FALLO: no nombra ConDatos.json"; fallos=1; }

salida=$(FLUJOS_DIR="$d/token" bash scripts/revisar.sh 2>&1); codigo=$?
[ "$codigo" -eq 1 ] || { echo "FALLO: token debía salir 1 y salió $codigo"; fallos=1; }
grep -q "ConToken.json" <<<"$salida" || { echo "FALLO: no nombra ConToken.json"; fallos=1; }

salida=$(bash scripts/revisar.sh 2>&1); codigo=$?
[ "$codigo" -eq 0 ] || { echo "FALLO: flujos/ debía salir 0 y salió $codigo"; echo "$salida" | tail -5; fallos=1; }

[ "$fallos" -eq 0 ] && echo "revisar.test.sh: todo bien"
exit "$fallos"
