---
tags: [cambio]
actualizado: 2026-11-03
---

# 2026-11-03 Base del curso

## Qué se hizo

- El repositorio queda solo para trabajar en local. Salieron los scripts, las pruebas y las notas de publicar en un servidor, que siguen en un repositorio privado aparte ([[Decisiones]]).
- `pruebas/flujo-completo.test.sh` recorre ahora solo el ciclo local: crear, exportar, revisar e importar en un equipo vacío.
- El `.gitignore` deja fuera cualquier PDF suelto en la raíz.

## Por qué

Es la base del curso. Cualquiera la descarga y le funciona en su equipo.

## Cómo se comprobó

- Pasan las cinco pruebas de `pruebas/`. La de punta a punta hace 15 comprobaciones.
- `gitleaks` no encuentra secretos en el historial.
- `git grep` no encuentra dominios, rutas de una cuenta ni nombres del servidor.

## Cómo se deshace

Revertir el commit de este cambio.
