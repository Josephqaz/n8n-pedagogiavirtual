---
tags: [cambio]
actualizado: 2026-11-01
---

# 2026-11-01 Base pública limpia

## Qué se hizo

- El repositorio pasa a ser una base de plantillas de flujos para cursos, y público ([[Decisiones]]).
- Se quitaron de los scripts, las pruebas y `docs/` los datos de la cuenta donde se probó.
- El diseño y el plan del arranque salieron del repositorio. Tenían rutas de la máquina de trabajo.
- El historial empieza de nuevo en un solo commit, con el correo `noreply` de GitHub.

## Por qué

Nada de lo publicado debe dar información de un sitio o un servidor.

## Cómo se comprobó

- `git grep` no encuentra los datos de la cuenta.
- Pasan las pruebas de `pruebas/`, incluida la de punta a punta.

## Cómo se deshace

El historial anterior queda solo en una copia privada.
