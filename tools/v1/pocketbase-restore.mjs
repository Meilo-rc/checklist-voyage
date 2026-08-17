import { readFile } from "node:fs/promises";
import {
  buildRestorePlan,
  fetchAllRecords,
  isProtectedProductionTarget,
  validatePocketBaseBackup
} from "./backup-lib.mjs";

function argument(name, fallback = "") {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

const backupPath = argument("--backup");
const targetUrl = argument("--target-url");
const collection = argument("--collection", "travel_checklists_restore_test");
const execute = process.argv.includes("--execute");
const confirmTarget = argument("--confirm-target");

if (!backupPath || !targetUrl) {
  console.error("Usage: node tools/v1/pocketbase-restore.mjs --backup <json> --target-url <url> [--collection <nom>] [--execute --confirm-target <hôte>]");
  process.exit(2);
}

const backup = JSON.parse(await readFile(backupPath, "utf8"));
const validation = validatePocketBaseBackup(backup);
if (!validation.valid) throw new Error(`Sauvegarde invalide: ${validation.errors.join(" ")}`);
if (isProtectedProductionTarget(targetUrl)) {
  throw new Error("Restauration refusée sur psyco.fly.dev. Utiliser une instance PocketBase de test dédiée.");
}

const existing = await fetchAllRecords({ baseUrl: targetUrl, collection });
const plan = buildRestorePlan(backup, existing);
console.log(JSON.stringify({ mode: execute ? "execute" : "dry-run", targetUrl, collection, plan }, null, 2));

if (!execute) process.exit(0);
const hostname = new URL(targetUrl).hostname;
if (confirmTarget !== hostname) throw new Error(`Confirmation requise: --confirm-target ${hostname}`);
if (existing.length) throw new Error("La collection cible de test doit être vide; aucune suppression automatique n'est autorisée.");

for (const record of backup.records) {
  const response = await fetch(new URL(`/api/collections/${collection}/records`, targetUrl), {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ id: record.id, code: record.code, data: record.data })
  });
  if (!response.ok) throw new Error(`Restauration ${record.id}: HTTP ${response.status} ${await response.text()}`);
}

const restored = await fetchAllRecords({ baseUrl: targetUrl, collection });
if (restored.length !== backup.records.length) {
  throw new Error(`Contrôle final invalide: ${restored.length}/${backup.records.length} enregistrements.`);
}
console.log(`Restauration de test vérifiée: ${restored.length} enregistrements, aucune suppression.`);
