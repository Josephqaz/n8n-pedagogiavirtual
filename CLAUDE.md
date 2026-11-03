# Base de n8n para cursos

n8n 2.45.7 como base de plantillas de flujos para cursos. Se trabaja en local con Docker (Windows o Linux) y el repositorio público es `Josephqaz/n8n-pedagogiavirtual`. La documentación es una bóveda de Obsidian en `docs/`.

## Al empezar, lee en este orden

1. `docs/01 Estado/Pendientes.md`
2. La nota más reciente de `docs/05 Cambios/`
3. `docs/00 Inicio.md`
4. `docs/01 Estado/Decisiones.md` (lo decidido ahí no se vuelve a discutir)

## Para X, lee Y

| Para | Lee |
|---|---|
| Trabajar en local | `docs/02 Cómo trabajar/Entorno local.md` |
| Credenciales | `docs/02 Cómo trabajar/Credenciales.md` |
| Probar flujos | `docs/02 Cómo trabajar/Probar con Claude Code.md` |
| Qué hace cada flujo | `docs/03 Flujos/` |

## Comandos

```bash
docker compose up -d                                          # n8n en http://localhost:5678
docker compose exec n8n n8n export:workflow --backup --output=/home/node/flujos/   # exportar.ps1 hace esto y luego: node /home/node/scripts/flujos.js normalizar /home/node/flujos
docker compose exec n8n n8n import:workflow --separate --input=/home/node/flujos/  # importar.ps1 hace esto, publica los que están activos (flujos.js activos) y reinicia
docker compose exec n8n n8n publish:workflow --id=<id>        # activar tras importar; luego reiniciar n8n
docker compose exec n8n n8n execute --id=<id>                 # ejecutar un flujo
bash scripts/revisar.sh                                       # antes de subir flujos: JSON, secretos, importa en n8n vacío
bash pruebas/revisar.test.sh && bash pruebas/revisar-enlaces.test.sh && bash pruebas/ps1-bom.test.sh && bash pruebas/exportar.test.sh && bash pruebas/flujo-completo.test.sh   # la última es la de punta a punta, unos 5 min
bash scripts/revisar-enlaces.sh                               # enlaces de docs/
```

La API local está en `http://localhost:5678/api/v1` con la cabecera `X-N8N-API-KEY` (clave en `.env`, variable `N8N_API_KEY`).

## Reglas

- Ningún secreto en git: `.env`, claves, tokens y datos de credenciales quedan fuera. `scripts/revisar.sh` lo comprueba.
- La versión de n8n se cambia solo en la línea `image:` de `docker-compose.yml`.
- Se trabaja en `main`. No hagas `git push` sin preguntar antes al usuario.
- El repositorio es público: nada de datos de una plataforma ni de un servidor (dominios, usuarios, rutas de una cuenta, flujos reales).
- Antes de escribir una nota de `docs/` o el README, invoca `/humanizer:humanizer`: frases cortas, sin guiones largos, sin etiquetas en negrita, títulos en minúscula y solo hechos comprobados. Cada `[[enlace]]` lleva a una nota que existe.
- Al cerrar un cambio: nota nueva en `docs/05 Cambios/` desde `docs/Plantillas/Cambio.md`, y `Estado actual` y `Pendientes` al día. Un flujo nuevo lleva su nota desde `docs/Plantillas/Flujo.md`.
