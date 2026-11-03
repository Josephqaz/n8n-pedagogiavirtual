#!/usr/bin/env bash
# Revisa los flujos antes de publicar. Sale con 0 si todo está bien y con 1 si hay algún problema.
# Uso: bash scripts/revisar.sh            (revisa flujos/)
#      FLUJOS_DIR=otra/carpeta bash scripts/revisar.sh
# Usa la instancia de prueba (docker-compose.prueba.yml), que se vacía en cada revisión.
set -euo pipefail
cd "$(dirname "$0")/.."
FLUJOS_DIR="${FLUJOS_DIR:-flujos}"
PRUEBA="docker compose -f docker-compose.prueba.yml"
problemas=0

$PRUEBA down -v >/dev/null 2>&1 || true
$PRUEBA up -d >/dev/null 2>&1

# 1 y 2: cada archivo es JSON válido y no lleva datos de credenciales ni tokens.
if ! $PRUEBA exec -T n8n-prueba node -e '
const fs = require("fs"), path = require("path");
const dir = process.argv[1];
const token = /Bearer [A-Za-z0-9._-]{6,}|sk-[A-Za-z0-9]{10,}|ghp_[A-Za-z0-9]{10,}/;
let mal = 0;
for (const f of fs.readdirSync(dir).filter(f => f.endsWith(".json"))) {
  const texto = fs.readFileSync(path.join(dir, f), "utf8");
  let w;
  try { w = JSON.parse(texto); } catch (e) { console.log(`${f}: no es JSON válido`); mal = 1; continue; }
  for (const n of w.nodes || []) {
    for (const c of Object.values(n.credentials || {})) {
      if (c && "data" in c) { console.log(`${f}: el nodo "${n.name}" lleva datos de una credencial`); mal = 1; }
    }
  }
  if (token.test(texto)) { console.log(`${f}: parece contener un token o clave escrita en el flujo`); mal = 1; }
}
process.exit(mal);
' "/repo/$FLUJOS_DIR"; then
  problemas=1
fi

# 3: la clave de cifrado local no está en ningún archivo del repositorio.
if [ -f .env ]; then
  clave=$(sed -n 's/^N8N_ENCRYPTION_KEY=//p' .env | tr -d '\r')
  if [ -n "$clave" ] && git grep -qF --untracked -- "$clave"; then
    echo "La clave N8N_ENCRYPTION_KEY de .env aparece en un archivo del repositorio"
    problemas=1
  fi
fi

# 4: los flujos importan sin error en un n8n vacío (solo si lo anterior está bien).
if [ "$problemas" -eq 0 ]; then
  for i in $(seq 1 40); do
    $PRUEBA exec -T n8n-prueba wget -qO- http://localhost:5678/healthz >/dev/null 2>&1 && break
    sleep 2
  done
  if ! $PRUEBA exec -T n8n-prueba n8n import:workflow --separate --input="/repo/$FLUJOS_DIR" >/dev/null 2>&1; then
    echo "Los flujos de $FLUJOS_DIR no importan en un n8n vacío"
    problemas=1
  fi
fi

$PRUEBA down -v >/dev/null 2>&1 || true
if [ "$problemas" -eq 0 ]; then echo "Revisión correcta: se puede publicar."; fi
exit "$problemas"
