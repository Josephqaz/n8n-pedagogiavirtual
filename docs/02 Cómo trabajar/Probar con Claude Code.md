---
tags: [entorno]
actualizado: 2026-10-31
---

# Probar con Claude Code

Es opcional. Si lo usas, abre Claude Code en la carpeta del repositorio. El `CLAUDE.md` le dice qué leer y qué reglas seguir.

## Qué puede hacer

| Para | Cómo |
|---|---|
| Disparar un flujo con webhook | La URL de prueba `http://localhost:5678/webhook-test/<ruta>` mientras el editor escucha, o la de producción `/webhook/<ruta>` si el flujo está publicado |
| Ejecutar un flujo sin disparador | `docker compose exec n8n n8n execute --id=<id>` |
| Ver cómo terminó una ejecución | La API de n8n en `http://localhost:5678/api/v1/executions`, con la clave de `N8N_API_KEY` del `.env` |
| Revisar antes de publicar | `bash scripts/revisar.sh` |
| Escribir la nota del flujo | A partir de `Plantillas/Flujo.md` |

La clave de la API se crea en n8n, en Settings, n8n API. Se guarda en `.env`, que no se sube a git.

## Más adelante

Hay servidores MCP para n8n que dejan a Claude ver y editar flujos directamente. No están instalados ([[Pendientes]]).
