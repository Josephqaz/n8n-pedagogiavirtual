---
tags: [estado]
actualizado: 2026-11-03
---

# Decisiones

Lo que está aquí no se vuelve a discutir. Quién: U = usuario, C = Claude.

| Fecha | Quién | Decisión | Por qué |
|---|---|---|---|
| 2026-10-31 | U | Se trabaja en local con Docker y se guarda en GitHub | Es la forma de trabajo que ya usa el equipo |
| 2026-10-31 | U | Claude Code es opcional | La persona decide si lo usa |
| 2026-10-31 | C | n8n 2.45.7 | Es la versión estable |
| 2026-10-31 | C | Los flujos se guardan con el nombre que les da n8n (`<id>.json`) | Así exportar sobrescribe sin duplicar |
| 2026-10-31 | C | Para activar un flujo tras importarlo se usa `n8n publish:workflow --id=<id>` y se reinicia n8n | `import:workflow` siempre los deja desactivados y `--activeState` solo funciona en modo cola |
| 2026-10-31 | C | Las credenciales se crean a mano con el mismo nombre en cada entorno | Probado: al importar, n8n enlaza la credencial por nombre y tipo |
| 2026-10-31 | C | Importar con n8n en marcha | Probado sin errores de bloqueo de la SQLite |
| 2026-10-31 | C | GitHub Desktop y scripts de PowerShell | Para el día a día no hace falta la terminal |
| 2026-10-31 | C | Sin graphify | El repositorio casi no tiene código |
| 2026-10-31 | C | `exportar.ps1` quita del JSON los campos que n8n cambia solo (`updatedAt`, `createdAt`, `versionId`, `activeVersionId`, `versionCounter`, `triggerCount`, `shared`) | Sin eso, cada exportación marcaba como cambiados flujos que nadie tocó. Probado en `pruebas/flujo-completo.test.sh` |
| 2026-10-31 | C | `importar.ps1` publica los flujos que en su archivo están activos | Si los dejaba apagados, la siguiente exportación los guardaba como borrador y la publicación los apagaba en el servidor |
| 2026-11-01 | U | El repositorio es una base de plantillas de flujos para cursos y es público | Los flujos no van a la plataforma ni dan información del sitio |
| 2026-11-01 | U | Historial de git limpio | Antes de hacerlo público |
| 2026-11-01 | C | Los commits usan el correo privado `noreply` de GitHub, configurado solo en este repositorio | Para que el correo personal no quede en un repositorio público |
| 2026-11-03 | U | La base es solo para trabajar en local. Lo de publicar en un servidor vive en un repositorio privado aparte | Es la base del curso: cualquiera la descarga y le funciona en su equipo |
