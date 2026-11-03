# Base de n8n para cursos

Base de n8n para crear plantillas de flujos para cursos. Se trabaja en tu equipo con Docker y los flujos se guardan en GitHub.

## Primer día (Windows)

1. Instala [Docker Desktop](https://www.docker.com/products/docker-desktop/) (acepta usar WSL2), [GitHub Desktop](https://desktop.github.com/) y [Obsidian](https://obsidian.md/).
2. En GitHub Desktop: File, Clone repository, `Josephqaz/n8n-pedagogiavirtual`.
3. En la carpeta del repositorio, copia `.env.example` como `.env` y cambia `N8N_ENCRYPTION_KEY` por una frase larga que solo uses aquí.
4. Abre PowerShell en esa carpeta (en GitHub Desktop: Repository, Open in Command Prompt, o clic derecho en la carpeta, "Abrir en Terminal") y ejecuta:
   ```powershell
   docker compose up -d
   scripts\importar.ps1
   ```
   Si Windows no deja ejecutar el script, usa `powershell -ExecutionPolicy Bypass -File scripts\importar.ps1`.
5. Abre `http://localhost:5678` y crea tu usuario. Es solo local.
6. En Obsidian: Open folder as vault, la carpeta `docs` del repositorio. Empieza por `00 Inicio`.

## Cada vez que trabajas

1. `docker compose up -d` y abre `http://localhost:5678`.
2. Crea o cambia el flujo y pruébalo.
3. `scripts\exportar.ps1` para guardarlo en `flujos/`.
4. Commit en `main` con GitHub Desktop y Push.

## Reglas

- Las credenciales se crean a mano en cada n8n y nunca van al repositorio (`docs/02 Cómo trabajar/Credenciales.md`).
- Cada cambio lleva su nota en `docs/05 Cambios/`.
