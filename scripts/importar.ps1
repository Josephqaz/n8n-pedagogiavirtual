# Carga en n8n local los flujos de la carpeta flujos/. Sirve para un equipo nuevo o tras traer cambios.
# Uso: scripts\importar.ps1  (con n8n en marcha: docker compose up -d)
Set-Location (Join-Path $PSScriptRoot "..")

docker compose exec -T n8n n8n import:workflow --separate --input=/home/node/flujos/
if ($LASTEXITCODE -ne 0) {
    Write-Host "No se pudo importar. ¿Está n8n en marcha? Prueba: docker compose up -d" -ForegroundColor Red
    exit $LASTEXITCODE
}

# n8n deja desactivado todo lo que importa. Se vuelven a publicar los que en su archivo están activos,
# para que una exportación posterior no los guarde como apagados.
$activos = docker compose exec -T n8n node /home/node/scripts/flujos.js activos /home/node/flujos
if ($LASTEXITCODE -ne 0) {
    Write-Host "Se importó, pero no se pudo leer qué flujos están publicados. ¿Hiciste docker compose up -d?" -ForegroundColor Red
    exit $LASTEXITCODE
}
foreach ($id in $activos) {
    docker compose exec -T n8n n8n publish:workflow --id=$id | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "No se pudo publicar el flujo $id" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
docker compose restart n8n | Out-Null

Write-Host "Listo. Los flujos están cargados y n8n se reinició; en unos segundos responde en http://localhost:5678" -ForegroundColor Green
