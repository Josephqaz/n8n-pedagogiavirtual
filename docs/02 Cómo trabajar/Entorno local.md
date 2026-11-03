---
tags: [entorno]
actualizado: 2026-10-31
---

# Entorno local

n8n corre en Docker en tu equipo, en `http://localhost:5678`. Los pasos del primer día están en el `README.md` del repositorio.

## Del día a día

| Para | Haz |
|---|---|
| Encender n8n | `docker compose up -d` en la carpeta del repositorio |
| Apagarlo | `docker compose down` (los flujos y credenciales se conservan) |
| Guardar los flujos en la carpeta `flujos/` | `scripts\exportar.ps1` |
| Cargar los flujos de la carpeta en n8n | `scripts\importar.ps1` |
| Empezar de cero en local | `docker compose down -v` (borra todo lo local) y luego `scripts\importar.ps1` |

Exportar deja tus flujos en n8n tal como están y rehace la carpeta `flujos/` con ellos. Quita las fechas y versiones que n8n cambia solo, así que en GitHub Desktop solo aparecen los flujos que tocaste. Si tu n8n no tiene ningún flujo, `exportar.ps1` se detiene sin tocar la carpeta y te pide ejecutar antes `importar.ps1`.

Importar publica los flujos que en su archivo están activos y reinicia n8n. Tarda unos segundos en volver a responder.

## Publicado o borrador

Un flujo queda activo al importarlo en otro equipo solo si lo publicaste en tu n8n (botón Publish) antes de exportar. Los que dejes sin publicar se importan como borrador y no se ejecutan. Se comprobó en la prueba `pruebas/flujo-completo.test.sh`.

Después de cambiar el repositorio con `git pull` o GitHub Desktop, ejecuta `docker compose up -d` por si cambió la configuración de Docker.

## Antes de cada commit

1. Exporta con `scripts\exportar.ps1`.
2. En GitHub Desktop revisa que solo cambian los archivos de los flujos que tocaste.
3. Si un flujo nuevo usa credenciales, apunta sus nombres en su nota de [[Flujos]].

Luego haz commit en `main` y Push con GitHub Desktop.
