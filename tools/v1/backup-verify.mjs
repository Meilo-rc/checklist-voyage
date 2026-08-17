import { resolve } from "node:path";
import { writeFile } from "node:fs/promises";
import { verifyBackupFile } from "./backup-lib.mjs";

const input = process.argv[2];
if (!input) {
  console.error("Usage: node tools/v1/backup-verify.mjs <sauvegarde.json>");
  process.exit(2);
}

const report = await verifyBackupFile(resolve(input));
console.log(JSON.stringify(report, null, 2));
const outputIndex = process.argv.indexOf("--out");
if (outputIndex >= 0) {
  const output = process.argv[outputIndex + 1];
  if (!output) throw new Error("Valeur absente après --out.");
  await writeFile(resolve(output), `${JSON.stringify(report, null, 2)}\n`, { encoding: "utf8", flag: "wx" });
}
if (!report.valid) process.exit(1);
