import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";

export const POCKETBASE_BACKUP_SCHEMA = "checklist-voyage-pocketbase-full-v1";
export const WEB_BACKUP_SCHEMA = "checklist-voyage-backup-v1";

export function sha256(buffer) {
  return createHash("sha256").update(buffer).digest("hex");
}

export function recordType(record) {
  if (record?.code === "PARAMS") return "settings";
  const data = record?.data;
  if (data?.type) return data.type;
  if (data?.quickList) return "quickList";
  if (data?.voyage) return "voyage";
  if (Array.isArray(data?.voyages) || data?.currentVoyageId) return "legacyAppState";
  if (Array.isArray(data?.members) || Array.isArray(data?.categories)) return "legacyVoyage";
  if (Array.isArray(data?.items)) return "legacyQuickList";
  return "unknown";
}

export async function fetchAllRecords({ baseUrl, collection, fetchImpl = fetch }) {
  const records = [];
  const perPage = 200;
  let page = 1;

  while (true) {
    const url = new URL(`/api/collections/${collection}/records`, baseUrl);
    url.searchParams.set("page", String(page));
    url.searchParams.set("perPage", String(perPage));
    url.searchParams.set("sort", "created");
    const response = await fetchImpl(url, { method: "GET" });
    if (!response.ok) {
      throw new Error(`PocketBase GET ${response.status}: ${await response.text()}`);
    }
    const payload = await response.json();
    if (!Array.isArray(payload.items)) throw new Error("Réponse PocketBase invalide: items absent.");
    records.push(...payload.items);
    if (page >= Number(payload.totalPages || 1)) break;
    page += 1;
  }

  return records;
}

function bump(target, key, amount = 1) {
  target[key] = (target[key] || 0) + amount;
}

function scanDomain(value, stats, path = "root") {
  if (Array.isArray(value)) {
    const key = path.split(".").at(-1);
    if (["voyages", "quickLists", "customCategories", "members", "categories", "items"].includes(key)) {
      bump(stats.arrays, key, value.length);
    }
    value.forEach((entry, index) => scanDomain(entry, stats, `${path}.${index}`));
    return;
  }
  if (!value || typeof value !== "object") return;
  if (value.deletedAt) stats.tombstones += 1;
  for (const [key, child] of Object.entries(value)) scanDomain(child, stats, `${path}.${key}`);
}

function duplicateValues(values) {
  const counts = new Map();
  values.filter(Boolean).forEach(value => counts.set(value, (counts.get(value) || 0) + 1));
  return [...counts.entries()].filter(([, count]) => count > 1).map(([value, count]) => ({ value, count }));
}

export function summarizePocketBaseBackup(backup) {
  const records = Array.isArray(backup?.records) ? backup.records : [];
  const types = {};
  const nested = { arrays: {}, tombstones: 0 };
  records.forEach(record => {
    bump(types, recordType(record));
    scanDomain(record?.data, nested, "data");
  });
  return {
    records: records.length,
    types,
    settingsRecords: records.filter(record => record?.code === "PARAMS").length,
    duplicateRecordIds: duplicateValues(records.map(record => record?.id)),
    duplicateCodes: duplicateValues(records.map(record => record?.code)),
    nestedArrays: nested.arrays,
    tombstones: nested.tombstones
  };
}

export function validatePocketBaseBackup(backup) {
  const errors = [];
  const warnings = [];
  if (backup?.schema !== POCKETBASE_BACKUP_SCHEMA) errors.push(`Schéma attendu: ${POCKETBASE_BACKUP_SCHEMA}.`);
  if (!Array.isArray(backup?.records)) errors.push("records doit être un tableau.");
  const records = Array.isArray(backup?.records) ? backup.records : [];
  records.forEach((record, index) => {
    if (!record?.id) errors.push(`records[${index}].id absent.`);
    if (!record?.code) errors.push(`records[${index}].code absent.`);
    if (!record?.data || typeof record.data !== "object") errors.push(`records[${index}].data absent ou invalide.`);
  });
  const summary = summarizePocketBaseBackup(backup);
  if (summary.settingsRecords !== 1) errors.push(`Un seul enregistrement PARAMS est attendu; trouvé: ${summary.settingsRecords}.`);
  if (summary.duplicateRecordIds.length) errors.push("Identifiants PocketBase dupliqués dans la sauvegarde.");
  if (summary.duplicateCodes.length) warnings.push("Des codes fonctionnels sont dupliqués; conserver le détail pour la migration.");
  if (summary.types.unknown) warnings.push(`${summary.types.unknown} record(s) ont une forme inconnue et exigent une analyse avant migration.`);
  const legacyCount = (summary.types.legacyAppState || 0) + (summary.types.legacyVoyage || 0) + (summary.types.legacyQuickList || 0);
  if (legacyCount) warnings.push(`${legacyCount} record(s) utilisent une forme legacy reconnue; ils seront convertis par l'adaptateur d'import.`);
  if (!records.length) errors.push("La sauvegarde PocketBase est vide.");
  return { kind: "pocketbase", valid: errors.length === 0, errors, warnings, summary };
}

function webData(payload) {
  return payload?.schema === WEB_BACKUP_SCHEMA && payload?.data ? payload.data : payload;
}

export function summarizeWebBackup(payload) {
  const data = webData(payload) || {};
  const groups = data.customMemberGroups && typeof data.customMemberGroups === "object"
    ? data.customMemberGroups
    : {};
  const personalMembers = Object.entries(groups).filter(([, group]) => group === "personal").map(([name]) => name);
  const personalNames = new Set(personalMembers);
  const personalCategories = (data.customCategories || []).filter(category => personalNames.has(category?.member));
  const nested = { arrays: {}, tombstones: 0 };
  scanDomain(data, nested, "data");
  return {
    voyages: Array.isArray(data.voyages) ? data.voyages.length : 0,
    quickLists: Array.isArray(data.quickLists) ? data.quickLists.length : 0,
    customCategories: Array.isArray(data.customCategories) ? data.customCategories.length : 0,
    personalMembers: personalMembers.length,
    personalCategories: personalCategories.length,
    personalItems: personalCategories.reduce((count, category) => count + (Array.isArray(category.items) ? category.items.length : 0), 0),
    nestedArrays: nested.arrays,
    tombstones: nested.tombstones,
    settingsRecordIdPresent: Boolean(data.settingsRecordId)
  };
}

export function validateWebBackup(payload) {
  const errors = [];
  const warnings = [];
  const data = webData(payload);
  if (!data || typeof data !== "object") errors.push("Objet data absent ou invalide.");
  for (const key of ["voyages", "quickLists", "customCategories", "customCategoryMembers"]) {
    if (!Array.isArray(data?.[key])) errors.push(`${key} doit être un tableau.`);
  }
  if (!data?.customMemberGroups || typeof data.customMemberGroups !== "object") {
    errors.push("customMemberGroups absent ou invalide; impossible de vérifier Personnel.");
  }
  const summary = summarizeWebBackup(payload);
  if (summary.personalMembers === 0 && summary.personalCategories === 0) {
    warnings.push("Aucune donnée Personnel détectée. Confirmer que cet appareil n'en possède réellement aucune.");
  }
  return { kind: "web-local", valid: errors.length === 0, errors, warnings, summary };
}

export async function verifyBackupFile(path) {
  const raw = await readFile(path);
  let payload;
  try {
    payload = JSON.parse(raw.toString("utf8"));
  } catch (error) {
    return {
      kind: "unknown",
      valid: false,
      errors: [`JSON invalide: ${error.message}`],
      warnings: [],
      summary: {},
      sha256: sha256(raw)
    };
  }
  const report = payload?.schema === POCKETBASE_BACKUP_SCHEMA
    ? validatePocketBaseBackup(payload)
    : validateWebBackup(payload);
  return { ...report, sha256: sha256(raw) };
}

export function isProtectedProductionTarget(value) {
  return new URL(value).hostname.toLowerCase() === "psyco.fly.dev";
}

export function buildRestorePlan(backup, existingRecords = []) {
  const records = Array.isArray(backup?.records) ? backup.records : [];
  const existingIds = new Set(existingRecords.map(record => record?.id).filter(Boolean));
  return {
    sourceRecords: records.length,
    targetRecordsBefore: existingRecords.length,
    creates: records.filter(record => !existingIds.has(record.id)).map(record => record.id),
    updates: records.filter(record => existingIds.has(record.id)).map(record => record.id),
    deletes: []
  };
}
