#!/usr/bin/env bash
# Prueba de punta a punta del ciclo de trabajo, con los scripts reales:
#   n8n local (en una copia aislada del repo, puerto 5690) -> exportar.ps1 / importar.ps1 (PowerShell real)
#   -> revisar.sh.
# No toca el n8n de trabajo ni la carpeta flujos/ del repositorio. Uso: bash pruebas/flujo-completo.test.sh
set -uo pipefail
cd "$(dirname "$0")/.."
RAIZ="$PWD"
E2E="$RAIZ/.tmp/e2e"
R="$E2E/repo"
fallos=0
falla() { echo "FALLO: $*"; fallos=1; }
ok() { echo "ok: $*"; }

# ---------- preparación ----------
[ -d "$R" ] && (cd "$R" && COMPOSE_PROJECT_NAME=n8n-e2e COMPOSE_FILE=docker-compose.yml:e2e.override.yml docker compose down -v >/dev/null 2>&1)
rm -rf "$E2E" && mkdir -p "$E2E/fx"
git clone -q "$RAIZ" "$R" || { echo "no se pudo copiar el repo"; exit 1; }
# El clon trae lo que tiene commit; se añaden los cambios sin commit para probar lo que hay en disco.
(cd "$RAIZ" && git ls-files -mo --exclude-standard -z | xargs -0 -r cp --parents -t "$R")
git -C "$R" add -A && git -C "$R" -c user.name=e2e -c user.email=e2e@local commit -qm "base e2e" 2>/dev/null
sed "s/^N8N_ENCRYPTION_KEY=.*/N8N_ENCRYPTION_KEY=clave-e2e-$(date +%s)/" "$R/.env.example" > "$R/.env"
cat > "$R/e2e.override.yml" <<'EOF'
services:
  n8n:
    ports: !override
      - "5690:5678"
EOF
export COMPOSE_PROJECT_NAME=n8n-e2e COMPOSE_FILE=docker-compose.yml:e2e.override.yml
dc() { (cd "$R" && docker compose "$@"); }
n8nl() { dc exec -T n8n n8n "$@"; }
GID=$(stat -c %g /var/run/docker.sock)
ps1() {  # ejecuta scripts/<nombre>.ps1 de la copia con PowerShell real
  docker run --rm --user "$(id -u):$(id -g)" --group-add "$GID" -e HOME=/tmp \
    -e COMPOSE_PROJECT_NAME -e COMPOSE_FILE \
    -v /var/run/docker.sock:/var/run/docker.sock -v /usr/bin/docker:/usr/bin/docker:ro \
    -v /usr/libexec/docker/cli-plugins:/usr/libexec/docker/cli-plugins:ro \
    -v "$E2E:$E2E" -w "$R" mcr.microsoft.com/powershell pwsh -NoProfile -File "scripts/$1.ps1"
}
esperar_url() {  # $1 url, $2 respuesta esperada (vacío = solo código 200). Hasta 60 s.
  for i in $(seq 1 30); do
    if [ -z "${2:-}" ]; then [ "$(curl -s -o /dev/null -w '%{http_code}' "$1")" = 200 ] && return 0
    else [ "$(curl -s "$1")" = "$2" ] && return 0; fi
    sleep 2
  done; return 1
}
reiniciar_local() { dc restart n8n >/dev/null 2>&1; esperar_url http://localhost:5690/healthz; }
contar_local() { n8nl list:workflow 2>/dev/null | grep -c '|'; }

# Flujos que "crea la persona" en el editor (aquí entran por la CLI, que guarda lo mismo en la base).
cat > "$E2E/fx/saludo.json" <<'EOF'
{"id":"PruebaSaludo0001","name":"Prueba - saludo","active":false,"nodes":[
 {"id":"a1000000-0000-4000-8000-000000000001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[0,0],"webhookId":"a1000000-0000-4000-8000-0000000000aa","parameters":{"httpMethod":"GET","path":"prueba-saludo","responseMode":"responseNode","options":{}}},
 {"id":"a1000000-0000-4000-8000-000000000002","name":"Responder","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[240,0],"parameters":{"respondWith":"json","responseBody":"{\"saludo\":\"hola\"}","options":{}}}],
 "connections":{"Webhook":{"main":[[{"node":"Responder","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"}}
EOF
cat > "$E2E/fx/eco.json" <<'EOF'
{"id":"PruebaEco0000001","name":"Prueba - eco de cabecera","active":false,"nodes":[
 {"id":"b1000000-0000-4000-8000-000000000001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[0,0],"webhookId":"b1000000-0000-4000-8000-0000000000aa","parameters":{"httpMethod":"GET","path":"eco-cabecera","responseMode":"responseNode","options":{}}},
 {"id":"b1000000-0000-4000-8000-000000000002","name":"Responder","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[240,0],"parameters":{"respondWith":"json","responseBody":"={{ JSON.stringify({ x: $json.headers['x-prueba'] }) }}","options":{}}}],
 "connections":{"Webhook":{"main":[[{"node":"Responder","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"}}
EOF
cat > "$E2E/fx/credencial.json" <<'EOF'
{"id":"PruebaCred000001","name":"Prueba - credencial","active":false,"nodes":[
 {"id":"c1000000-0000-4000-8000-000000000001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[0,0],"webhookId":"c1000000-0000-4000-8000-0000000000aa","parameters":{"httpMethod":"GET","path":"prueba-credencial","responseMode":"responseNode","options":{}}},
 {"id":"c1000000-0000-4000-8000-000000000002","name":"HTTP","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[240,0],"parameters":{"url":"http://localhost:5678/webhook/eco-cabecera","authentication":"genericCredentialType","genericAuthType":"httpHeaderAuth","options":{}},"credentials":{"httpHeaderAuth":{"id":"CredLocalE2E0001","name":"Cabecera prueba"}}},
 {"id":"c1000000-0000-4000-8000-000000000003","name":"Responder","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.1,"position":[480,0],"parameters":{"respondWith":"json","responseBody":"={{ JSON.stringify($json) }}","options":{}}}],
 "connections":{"Webhook":{"main":[[{"node":"HTTP","type":"main","index":0}]]},"HTTP":{"main":[[{"node":"Responder","type":"main","index":0}]]}},"settings":{"executionOrder":"v1"}}
EOF
cat > "$E2E/fx/borrador.json" <<'EOF'
{"id":"PruebaBorrador01","name":"Prueba - borrador","active":false,"nodes":[
 {"id":"d1000000-0000-4000-8000-000000000001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[0,0],"webhookId":"d1000000-0000-4000-8000-0000000000aa","parameters":{"httpMethod":"GET","path":"prueba-borrador","responseMode":"onReceived","options":{}}}],
 "connections":{},"settings":{"executionOrder":"v1"}}
EOF
echo '[{"id":"CredLocalE2E0001","name":"Cabecera prueba","type":"httpHeaderAuth","data":{"name":"X-Prueba","value":"valor-local"}}]' > "$E2E/fx/cred-local.json"

dc up -d >/dev/null 2>&1
esperar_url http://localhost:5690/healthz || { echo "n8n local no arrancó"; exit 1; }

# ---------- 1. equipo nuevo: exportar sin haber importado no borra nada ----------
ps1 exportar >"$E2E/salida.txt" 2>&1; c=$?
[ "$c" -ne 0 ] && [ -f "$R/flujos/EjemploLatido001.json" ] && grep -q importar.ps1 "$E2E/salida.txt" \
  && ok "1. exportar con n8n vacío se detiene y conserva flujos/" || { falla "1. exportar con n8n vacío (código $c)"; cat "$E2E/salida.txt"; }

# ---------- 2. importar.ps1 carga los flujos del repo ----------
ps1 importar >"$E2E/salida.txt" 2>&1; c=$?
[ "$c" -eq 0 ] && [ "$(contar_local)" -eq 1 ] && ok "2. importar.ps1 carga 1 flujo" || { falla "2. importar.ps1 (código $c, $(contar_local) flujos)"; cat "$E2E/salida.txt"; }

# ---------- 3. la persona crea tres flujos y una credencial, publica dos y deja uno en borrador ----------
for f in saludo eco credencial borrador cred-local; do docker cp "$E2E/fx/$f.json" "$(dc ps -q n8n):/tmp/$f.json" >/dev/null; done
n8nl import:credentials --input=/tmp/cred-local.json >/dev/null 2>&1
for f in saludo eco credencial borrador; do n8nl import:workflow --input=/tmp/$f.json >/dev/null 2>&1; done
for id in EjemploLatido001 PruebaSaludo0001 PruebaEco0000001 PruebaCred000001; do n8nl publish:workflow --id=$id >/dev/null 2>&1; done
reiniciar_local
esperar_url http://localhost:5690/webhook/prueba-saludo '{"saludo":"hola"}' && ok "3. local: prueba-saludo responde" || falla "3. local: prueba-saludo no responde"
esperar_url http://localhost:5690/webhook/prueba-credencial '{"x":"valor-local"}' && ok "3. local: la credencial local se usa" || falla "3. local: prueba-credencial no da valor-local ($(curl -s http://localhost:5690/webhook/prueba-credencial))"

# ---------- 4. exportar.ps1 guarda los cinco, con su estado y sin secretos ----------
ps1 exportar >"$E2E/salida.txt" 2>&1; c=$?
n=$(ls "$R"/flujos/*.json 2>/dev/null | wc -l)
[ "$c" -eq 0 ] && [ "$n" -eq 5 ] && ok "4. exportar.ps1 deja 5 archivos" || { falla "4. exportar.ps1 (código $c, $n archivos)"; cat "$E2E/salida.txt"; }
grep -q '"active": true' "$R/flujos/PruebaSaludo0001.json" && grep -q '"active": false' "$R/flujos/PruebaBorrador01.json" \
  && ok "4. el JSON guarda publicado y borrador" || falla "4. el campo active no refleja lo publicado"
grep -rq 'valor-local' "$R/flujos" && falla "4. el valor de la credencial quedó en flujos/" || ok "4. ningún valor de credencial en flujos/"
[ "$(git -C "$R" status --porcelain flujos | wc -l)" -eq 4 ] && ok "4. git ve 4 flujos nuevos" || falla "4. git status: $(git -C "$R" status --porcelain flujos | tr '\n' ' ')"

# ---------- 5. revisar.sh da el visto bueno ----------
(cd "$R" && env -u COMPOSE_FILE -u COMPOSE_PROJECT_NAME bash scripts/revisar.sh) >"$E2E/salida.txt" 2>&1 \
  && ok "5. revisar.sh aprueba los flujos" || { falla "5. revisar.sh"; cat "$E2E/salida.txt"; }

# ---------- 6. la persona cambia un flujo y lo vuelve a exportar ----------
n8nl export:workflow --id=PruebaSaludo0001 --output=/tmp/s.json >/dev/null 2>&1
dc exec -T n8n sed -i 's/\\"saludo\\":\\"hola\\"/\\"saludo\\":\\"hola de nuevo\\"/' /tmp/s.json
n8nl import:workflow --input=/tmp/s.json >/dev/null 2>&1
n8nl publish:workflow --id=PruebaSaludo0001 >/dev/null 2>&1
reiniciar_local
esperar_url http://localhost:5690/webhook/prueba-saludo '{"saludo":"hola de nuevo"}' && ok "6. local: el cambio se ve" || falla "6. local: el cambio no se ve ($(curl -s http://localhost:5690/webhook/prueba-saludo))"
ps1 exportar >/dev/null 2>&1
git -C "$R" diff --quiet -- flujos/EjemploLatido001.json && ok "6. exportar no altera un flujo que no cambió" || falla "6. EjemploLatido001.json cambió sin tocarlo"
grep -q 'hola de nuevo' "$R/flujos/PruebaSaludo0001.json" && ok "6. el cambio queda en el JSON" || falla "6. el cambio no llegó al JSON"

# ---------- 7. equipo nuevo: importar.ps1 recupera todo, también lo publicado ----------
git -C "$R" add flujos && git -C "$R" -c user.name=e2e -c user.email=e2e@local commit -qm "flujos e2e"
dc down -v >/dev/null 2>&1 && dc up -d >/dev/null 2>&1 && esperar_url http://localhost:5690/healthz
ps1 importar >"$E2E/salida.txt" 2>&1; c=$?
[ "$c" -eq 0 ] && [ "$(contar_local)" -eq 5 ] && ok "7. importar.ps1 en un n8n vacío recupera los 5" || { falla "7. importar.ps1 (código $c, $(contar_local) flujos)"; cat "$E2E/salida.txt"; }
esperar_url http://localhost:5690/webhook/prueba-saludo '{"saludo":"hola de nuevo"}' && ok "7. lo publicado queda publicado tras importar" || falla "7. tras importar, prueba-saludo no responde"
ps1 exportar >/dev/null 2>&1
git -C "$R" diff --quiet -- flujos && ok "7. exportar justo después de importar no cambia ningún archivo" \
  || falla "7. exportar tras importar cambia: $(git -C "$R" diff --stat -- flujos | tail -1)"

# ---------- limpieza ----------
dc down -v >/dev/null 2>&1
[ "$fallos" -eq 0 ] && { rm -rf "$E2E"; echo "flujo-completo.test.sh: todo bien"; }
exit "$fallos"
