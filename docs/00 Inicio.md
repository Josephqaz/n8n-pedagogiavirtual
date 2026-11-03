---
tags: [moc]
actualizado: 2026-11-03
---

# Base de n8n para cursos

Base de n8n para crear plantillas de flujos para cursos. Se trabaja en local con Docker y los flujos se guardan en GitHub.

> [!important] Empieza aquí
> [[Estado actual]] dice en qué punto está el proyecto y [[Pendientes]] qué falta.

| Sección | Notas |
|---|---|
| 01 Estado | [[Estado actual]], [[Pendientes]], [[Decisiones]] |
| 02 Cómo trabajar | [[Entorno local]], [[Credenciales]], [[Probar con Claude Code]] |
| 03 Flujos | [[Flujos]] (una nota por flujo) |
| 05 Cambios | [[Cambios]] (una nota fechada por cambio) |

Plantillas para notas nuevas: `Plantillas/Flujo.md` y `Plantillas/Cambio.md`.

## El ciclo de trabajo

1. Crear o cambiar el flujo en `localhost:5678`.
2. Exportarlo con `scripts\exportar.ps1`.
3. Commit en `main` y Push.
