import assert from "node:assert/strict";
import test from "node:test";
import {
  POCKETBASE_BACKUP_SCHEMA,
  buildRestorePlan,
  fetchAllRecords,
  isProtectedProductionTarget,
  recordType,
  validatePocketBaseBackup,
  validateWebBackup
} from "../../tools/v1/backup-lib.mjs";

test("valide une sauvegarde PocketBase complète minimale", () => {
  const report = validatePocketBaseBackup({
    schema: POCKETBASE_BACKUP_SCHEMA,
    records: [
      { id: "settings-record", code: "PARAMS", data: { type: "settings", customCategories: [] } },
      { id: "voyage-record", code: "ABC123", data: { type: "voyage", id: "legacy-trip" } }
    ]
  });
  assert.equal(report.valid, true);
  assert.equal(report.summary.records, 2);
  assert.equal(report.summary.settingsRecords, 1);
});

test("rejette une sauvegarde PocketBase sans PARAMS", () => {
  const report = validatePocketBaseBackup({
    schema: POCKETBASE_BACKUP_SCHEMA,
    records: [{ id: "voyage-record", code: "ABC123", data: { type: "voyage" } }]
  });
  assert.equal(report.valid, false);
  assert.ok(report.errors.some(error => error.includes("PARAMS")));
});

test("détecte et compte les données Personnel d'un export Web", () => {
  const report = validateWebBackup({
    schema: "checklist-voyage-backup-v1",
    data: {
      voyages: [], quickLists: [], customCategoryMembers: ["Privé"],
      customMemberGroups: { "Privé": "personal" },
      customCategories: [{ id: "private-cat", member: "Privé", name: "Perso", items: [{ id: "private-item", name: "Secret" }] }]
    }
  });
  assert.equal(report.valid, true);
  assert.equal(report.summary.personalMembers, 1);
  assert.equal(report.summary.personalCategories, 1);
  assert.equal(report.summary.personalItems, 1);
});

test("le plan de restauration ne prévoit aucune suppression", () => {
  const plan = buildRestorePlan({ records: [
    { id: "existing" }, { id: "new" }
  ] }, [{ id: "existing" }]);
  assert.deepEqual(plan.creates, ["new"]);
  assert.deepEqual(plan.updates, ["existing"]);
  assert.deepEqual(plan.deletes, []);
});

test("la restauration protège explicitement la production", () => {
  assert.equal(isProtectedProductionTarget("https://psyco.fly.dev"), true);
  assert.equal(isProtectedProductionTarget("http://127.0.0.1:8090"), false);
});

test("l'export PocketBase pagine uniquement avec des requêtes GET", async () => {
  const calls = [];
  const records = await fetchAllRecords({
    baseUrl: "https://example.test",
    collection: "travel_checklists",
    fetchImpl: async (url, options) => {
      calls.push({ url: String(url), method: options.method });
      const page = Number(url.searchParams.get("page"));
      return {
        ok: true,
        async json() {
          return { items: [{ id: `record-${page}` }], totalPages: 2 };
        }
      };
    }
  });
  assert.deepEqual(records.map(record => record.id), ["record-1", "record-2"]);
  assert.deepEqual(calls.map(call => call.method), ["GET", "GET"]);
});

test("reconnaît les principales formes legacy sans utiliser le nom", () => {
  assert.equal(recordType({ data: { currentVoyageId: "x", voyages: [] } }), "legacyAppState");
  assert.equal(recordType({ data: { members: [], categories: [] } }), "legacyVoyage");
  assert.equal(recordType({ data: { items: [] } }), "legacyQuickList");
});
