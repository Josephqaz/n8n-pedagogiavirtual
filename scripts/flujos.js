// Ayudas para la carpeta flujos/. Corre con el Node del contenedor de n8n (lo llaman exportar.ps1 e importar.ps1).
//   node flujos.js normalizar <carpeta>   quita los campos que n8n cambia solo (fechas, versiones, proyecto)
//   node flujos.js activos <carpeta>      imprime el id de cada flujo publicado ("active": true)
const fs = require("fs");
const path = require("path");

// Cambian con cada importación o publicación, o dependen de la instalación, y no describen el flujo.
const VOLATILES = ["updatedAt", "createdAt", "versionId", "activeVersionId", "versionCounter", "triggerCount", "shared"];

const [orden, dir] = process.argv.slice(2);
const archivos = fs.readdirSync(dir).filter((f) => f.endsWith(".json"));

for (const f of archivos) {
  const ruta = path.join(dir, f);
  const flujo = JSON.parse(fs.readFileSync(ruta, "utf8"));
  if (orden === "normalizar") {
    for (const k of VOLATILES) delete flujo[k];
    fs.writeFileSync(ruta, JSON.stringify(flujo, null, 2) + "\n");
  } else if (orden === "activos") {
    if (flujo.active === true) console.log(flujo.id);
  } else {
    console.error(`Orden desconocida: ${orden}`);
    process.exit(2);
  }
}
