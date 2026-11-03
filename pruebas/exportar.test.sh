#!/usr/bin/env bash
# Prueba de scripts/exportar.ps1 con un docker falso dentro de un contenedor de PowerShell.
# Uso: bash pruebas/exportar.test.sh
set -uo pipefail
cd "$(dirname "$0")/.."
fallos=0
d="$PWD/.tmp/prueba-exportar"
rm -rf "$d" && mkdir -p "$d/repo/scripts" "$d/repo/flujos" "$d/bin"
cp scripts/exportar.ps1 "$d/repo/scripts/"
cat > "$d/bin/docker" <<'FALSO'
#!/bin/sh
# docker falso: list:workflow imprime lo que diga FAKE_LIST; export escribe Nuevo.json.
case "$*" in
  *list:workflow*) [ -n "$FAKE_LIST" ] && echo "$FAKE_LIST"; exit 0 ;;
  *export:workflow*) echo '{}' > /repo/flujos/Nuevo.json; exit 0 ;;
esac
exit 0
FALSO
chmod +x "$d/bin/docker"

correr() {  # $1 = salida simulada de list:workflow
  echo '{}' > "$d/repo/flujos/Viejo.json"; rm -f "$d/repo/flujos/Nuevo.json"
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -e FAKE_LIST="$1" -v "$d/repo:/repo" -v "$d/bin/docker:/usr/local/bin/docker" \
    mcr.microsoft.com/powershell pwsh -NoProfile -File /repo/scripts/exportar.ps1 >"$d/salida.txt" 2>&1
}

# Caso 1: n8n sin flujos. No toca flujos/ y sale con error.
correr ""; codigo=$?
[ "$codigo" -ne 0 ] || { echo "FALLO: con n8n vacío debía fallar y salió 0"; fallos=1; }
[ -f "$d/repo/flujos/Viejo.json" ] || { echo "FALLO: con n8n vacío borró flujos/"; fallos=1; }
grep -q "importar.ps1" "$d/salida.txt" || { echo "FALLO: el mensaje no dice que se ejecute importar.ps1"; cat "$d/salida.txt"; fallos=1; }

# Caso 2: n8n con flujos. Rehace flujos/.
correr "Abc123|Un flujo"; codigo=$?
[ "$codigo" -eq 0 ] || { echo "FALLO: con flujos debía salir 0 y salió $codigo"; cat "$d/salida.txt"; fallos=1; }
[ -f "$d/repo/flujos/Nuevo.json" ] || { echo "FALLO: no exportó"; fallos=1; }
[ -f "$d/repo/flujos/Viejo.json" ] && { echo "FALLO: no vació flujos/ antes de exportar"; fallos=1; }

[ "$fallos" -eq 0 ] && echo "exportar.test.sh: todo bien"
exit "$fallos"
