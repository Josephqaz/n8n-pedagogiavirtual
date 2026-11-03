---
tags: [entorno]
actualizado: 2026-10-31
---

# Credenciales

Las contraseñas, tokens y claves de las credenciales nunca van al repositorio. Viven solo dentro de cada n8n.

- Se crean a mano en cada n8n donde se use el flujo, con el mismo nombre y el mismo tipo.
- Al importar un flujo, n8n lo enlaza con la credencial que tiene ese nombre y ese tipo. Se comprobó el 2026-10-31 ([[Decisiones]]).
- La lista de credenciales de cada flujo, solo nombre y tipo, está en su nota de [[Flujos]].
`bash scripts/revisar.sh` avisa si un flujo exportado lleva datos de una credencial o un token escrito a mano.
