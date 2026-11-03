# Guarda todos los flujos de n8n local en la carpeta flujos/, un archivo por flujo.
# Uso: scripts\exportar.ps1  (con n8n en marcha: docker compose up -d)
Set-Location (Join-Path $PSScriptRoot "..")

# Si n8n no tiene ningún flujo (por ejemplo, un equipo nuevo), exportar vaciaría la carpeta. Se para antes.
$lista = docker compose exec -T n8n n8n list:workflow
if ($LASTEXITCODE -ne 0) {
    Write-Host "No se pudo hablar con n8n. ¿Está en marcha? Prueba: docker compose up -d" -ForegroundColor Red
    exit 1
}
if (-not ($lista | Select-String -SimpleMatch "|")) {
    Write-Host "Tu n8n local no tiene flujos, así que no se tocó la carpeta flujos." -ForegroundColor Yellow
    Write-Host "Si es un equipo nuevo, ejecuta primero scripts\importar.ps1" -ForegroundColor Yellow
    exit 1
}

# Se vacía flujos/ antes de exportar para que un flujo borrado en n8n también desaparezca de aquí.
Remove-Item -Path "flujos/*.json" -ErrorAction SilentlyContinue

docker compose exec -T n8n n8n export:workflow --backup --output=/home/node/flujos/
if ($LASTEXITCODE -ne 0) {
    Write-Host "No se pudo exportar. ¿Está n8n en marcha? Prueba: docker compose up -d" -ForegroundColor Red
    Write-Host "Para recuperar los archivos de antes: git restore flujos" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Quita fechas, versiones y datos de esta instalación, para que solo cambien los archivos de los flujos que tocaste.
docker compose exec -T n8n node /home/node/scripts/flujos.js normalizar /home/node/flujos
if ($LASTEXITCODE -ne 0) {
    Write-Host "Se exportó, pero no se pudo limpiar flujos/. ¿Hiciste docker compose up -d después de actualizar el repositorio?" -ForegroundColor Red
    exit $LASTEXITCODE
}

$total = (Get-ChildItem -Path "flujos/*.json").Count
Write-Host "Listo: $total flujos en la carpeta flujos. Revisa los cambios en GitHub Desktop." -ForegroundColor Green
