import { mkdir, writeFile } from "node:fs/promises";
import { basename, resolve } from "node:path";
import {
  POCKETBASE_BACKUP_SCHEMA,
  fetchAllRecords,
  sha256,
  validatePocketBaseBackup
} from "./backup-lib.mjs";

function argument(name, fallback = "") {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

const baseUrl = argument("--url", "https://psyco.fly.dev");
const collection = argument("--collection", "travel_checklists");
const outputDir = argument("--out-dir");

if (!outputDir) {
  console.error("Usage: node tools/v1/pocketbase-export.mjs --out-dir <dossier> [--url <url>] [--collection <nom>]");
  process.exit(2);
}

const records = await fetchAllRecords({ baseUrl, collection });
const backup = {
  schema: POCKETBASE_BACKUP_SCHEMA,
  generatedAt: new Date().toISOString(),
  source: { baseUrl, collection, mode: "GET only" },
  records
};
const validation = validatePocketBaseBackup(backup);
if (!validation.valid) {
  console.error(JSON.stringify(validation, null, 2));
  process.exit(1);
}

const resolvedDir = resolve(outputDir);
await mkdir(resolvedDir, { recursive: true });
const json = `${JSON.stringify(backup, null, 2)}\n`;
const digest = sha256(Buffer.from(json, "utf8"));
const backupPath = resolve(resolvedDir, "pocketbase-full.json");
const noOverwrite = { encoding: "utf8", flag: "wx" };
await writeFile(backupPath, json, noOverwrite);
await writeFile(resolve(resolvedDir, "pocketbase-full.sha256"), `${digest}  ${basename(backupPath)}\n`, noOverwrite);
await writeFile(resolve(resolvedDir, "pocketbase-full.report.json"), `${JSON.stringify({ ...validation, sha256: digest }, null, 2)}\n`, noOverwrite);

console.log(JSON.stringify({ backupPath, sha256: digest, ...validation.summary }, null, 2));
