---
tags: [cambio]
actualizado: 2026-10-31
---

# 2026-10-31 Arranque limpio

## Qué se hizo

Repositorio nuevo con n8n 2.45.7 en Docker, el flujo [[Ejemplo - latido]], scripts para exportar, importar y revisar, y esta bóveda. Los scripts de publicación en un servidor salieron de este repositorio el 2026-11-03 ([[2026-11-03 Base del curso]]).

## Por qué

Hacía falta un arranque limpio para construir flujos ([[Decisiones]]).

## Cómo se comprobó

- `curl http://localhost:5678/healthz` da 200 y `n8n --version` da 2.45.7.
- Pasan las pruebas de `pruebas/` (la línea completa está en `CLAUDE.md`). La de exportar comprueba que `exportar.ps1` no vacía `flujos/` cuando n8n local no tiene flujos.
- Los `.ps1` llevan BOM, porque sin él Windows PowerShell 5.1 rompe las tildes de los mensajes.
- `pruebas/flujo-completo.test.sh` recorre el ciclo entero con los scripts reales: crea flujos con y sin credencial en un n8n local aislado, exporta e importa con PowerShell, revisa y vuelve a importar en un equipo vacío.

## Cómo se deshace

Es el primer trabajo del repositorio.
