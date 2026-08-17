import assert from "node:assert/strict";
import test from "node:test";
import { loadLegacyEngine, seedReferenceLibrary } from "./load-legacy-engine.mjs";

async function engineWithLibrary() {
  const engine = await loadLegacyEngine();
  seedReferenceLibrary(engine);
  return engine;
}

test("génère un voyage depuis Essentiel, participants, multi-transport et multi-logement", async () => {
  const engine = await engineWithLibrary();
  engine.execute(`
    globalThis.generatedTrip = makeVoyage("Paris", "01/09/2026 - 05/09/2026", {
      startDate: "2026-09-01",
      endDate: "2026-09-05",
      participants: ["Richard"],
      transport: ["avion", "train"],
      lodging: ["hotel", "camping"]
    });
  `);
  const trip = engine.json("generatedTrip");
  const names = trip.members.map(member => member.name);
  assert.deepEqual(names.sort(), [
    "Essentiel", "Logement - Camping", "Logement - Hôtel",
    "Richard", "Trajet - Avion", "Trajet - Train"
  ].sort());
  assert.equal(trip.members.find(member => member.name === "Richard").categories[0].sourceTemplateId, "tpl-richard");
  assert.equal(trip.members.find(member => member.name === "Essentiel").categories[0].items[0].sourceTemplateItemId, "tpl-item-passport");
  assert.notEqual(trip.members.find(member => member.name === "Essentiel").categories[0].items[0].id, "tpl-item-passport");
});

test("la quantité reste bornée à 1 minimum et le premier + produit 2", async () => {
  const engine = await engineWithLibrary();
  engine.execute(`
    const trip = makeVoyage("Paris", "", { participants: ["Richard"], transport: [], lodging: [] });
    state.voyages = [trip];
    state.currentVoyageId = trip.id;
    const category = trip.members.find(member => member.name === "Essentiel").categories[0];
    globalThis.qtyCategoryId = category.id;
    globalThis.qtyItemId = category.items[0].id;
  `);
  engine.execute("changeQty(qtyCategoryId, qtyItemId, 1)");
  assert.equal(engine.evaluate("findCategoryInVoyage(currentVoyage(), qtyCategoryId).category.items[0].qty"), 2);
  engine.execute("changeQty(qtyCategoryId, qtyItemId, -50)");
  assert.equal(engine.evaluate("findCategoryInVoyage(currentVoyage(), qtyCategoryId).category.items[0].qty"), 1);
});

test("le cycle d'un item de voyage est todo puis checked puis done puis todo", async () => {
  const engine = await engineWithLibrary();
  engine.execute(`
    const trip = makeVoyage("Paris", "", { participants: ["Richard"], transport: [], lodging: [] });
    state.voyages = [trip];
    state.currentVoyageId = trip.id;
    const category = trip.members.find(member => member.name === "Essentiel").categories[0];
    globalThis.statusCategoryId = category.id;
    globalThis.statusItemId = category.items[0].id;
  `);
  assert.equal(engine.evaluate("findCategoryInVoyage(currentVoyage(), statusCategoryId).category.items[0].status"), "todo");
  engine.execute("toggleItem(statusCategoryId, statusItemId)");
  assert.equal(engine.evaluate("findCategoryInVoyage(currentVoyage(), statusCategoryId).category.items[0].status"), "checked");
  engine.execute("toggleItem(statusCategoryId, statusItemId)");
  assert.equal(engine.evaluate("findCategoryInVoyage(currentVoyage(), statusCategoryId).category.items[0].status"), "done");
  engine.execute("toggleItem(statusCategoryId, statusItemId)");
  assert.equal(engine.evaluate("findCategoryInVoyage(currentVoyage(), statusCategoryId).category.items[0].status"), "todo");
});

test("supprimer un item du voyage ne supprime pas l'item source de la bibliothèque", async () => {
  const engine = await engineWithLibrary();
  engine.execute(`
    const trip = makeVoyage("Paris", "", { participants: ["Richard"], transport: [], lodging: [] });
    state.voyages = [trip];
    state.currentVoyageId = trip.id;
    const category = trip.members.find(member => member.name === "Essentiel").categories[0];
    globalThis.deleteCategoryId = category.id;
    globalThis.deleteItemId = category.items[0].id;
    deleteItem(deleteCategoryId, deleteItemId);
  `);
  assert.ok(engine.evaluate("findCategoryInVoyage(currentVoyage(), deleteCategoryId).category.items[0].deletedAt"));
  assert.equal(engine.evaluate("state.customCategories.find(category => category.id === 'tpl-essential').items[0].deletedAt"), "");
});

test("Général et Famille sont synchronisables, Personnel reste local", async () => {
  const engine = await engineWithLibrary();
  const synced = engine.json("syncedSettingsState()");
  const personal = engine.json("personalSettingsSnapshot()");
  assert.ok(synced.customCategories.some(category => category.member === "Essentiel"));
  assert.ok(synced.customCategories.some(category => category.member === "Richard"));
  assert.ok(!synced.customCategories.some(category => category.member === "Privé"));
  assert.deepEqual(personal.customCategories.map(category => category.member), ["Privé"]);
  assert.equal(personal.customMemberGroups["Privé"], "personal");
});

test("une liste rapide conserve quantité, état simple et réinitialisation", async () => {
  const engine = await engineWithLibrary();
  engine.execute(`
    const list = normalizeQuickList({ name: "Piscine", items: [{ id: "q1", name: "Maillot", qty: 2, done: false }] });
    state.quickLists = [list];
    state.currentQuickListId = list.id;
    toggleQuickItem("q1");
  `);
  assert.equal(engine.evaluate("currentQuickList().items[0].done"), true);
  assert.equal(engine.evaluate("currentQuickList().items[0].qty"), 2);
  engine.execute("resetQuickList(state.currentQuickListId)");
  assert.equal(engine.evaluate("currentQuickList().items[0].done"), false);
});

test("les payloads de partage existants conservent type, code et schéma", async () => {
  const engine = await engineWithLibrary();
  const voyagePayload = engine.json(`remotePayload(makeVoyage("Paris", "", { participants: ["Richard"], transport: [], lodging: [] }))`);
  const quickPayload = engine.json(`quickListPayload(normalizeQuickList({ name: "Piscine", items: [] }))`);
  assert.equal(voyagePayload.type, "voyage");
  assert.equal(quickPayload.type, "quickList");
  assert.equal(voyagePayload.schemaVersion, 3);
  assert.match(voyagePayload.code, /^[A-Z0-9]{6}$/);
  assert.match(quickPayload.code, /^[A-Z0-9]{6}$/);
});

test("la fusion par identifiant conserve la version d'item la plus récente", async () => {
  const engine = await engineWithLibrary();
  const result = engine.json(`mergeQuickLists(
    { id: "list-local", code: "ABC123", name: "Piscine", updatedAt: "2026-08-01T10:00:00.000Z", items: [{ id: "item-1", name: "Maillot", qty: 1, done: false, updatedAt: "2026-08-01T10:00:00.000Z" }] },
    { id: "list-remote", code: "ABC123", name: "Piscine", updatedAt: "2026-08-01T10:01:00.000Z", items: [{ id: "item-1", name: "Maillot", qty: 2, done: true, updatedAt: "2026-08-01T10:01:00.000Z" }] }
  )`);
  assert.equal(result.items.length, 1);
  assert.equal(result.items[0].qty, 2);
  assert.equal(result.items[0].done, true);
});

test("le dédoublonnage legacy par nom fusionne encore deux identités distinctes", async () => {
  const engine = await engineWithLibrary();
  const result = engine.json(`mergeByIdOrName(
    [{ id: "local-id", name: "Passeport", updatedAt: "2026-08-01T10:00:00.000Z" }],
    [{ id: "remote-id", name: "Passeport", updatedAt: "2026-08-01T10:01:00.000Z" }],
    newerEntity
  )`);
  assert.equal(result.length, 1);
  assert.equal(result[0].id, "remote-id");
});

test("la progression de catégorie exclut les items tombstonés", async () => {
  const engine = await engineWithLibrary();
  const progress = engine.json(`progressForCategory({ items: [
    { id: "visible", name: "Visible", status: "done", done: true, deletedAt: "" },
    { id: "deleted", name: "Supprimé", status: "todo", done: false, deletedAt: "2026-08-01T11:00:00.000Z" }
  ] })`);
  assert.deepEqual(progress, { total: 1, done: 1, percent: 100 });
});

test("BUG-263-001: la progression globale doit exclure les items tombstonés", { todo: "Bug 2.63 confirmé: progressForVoyage compte category.items sans visibleItems()." }, async () => {
  const engine = await engineWithLibrary();
  engine.execute(`
    globalThis.progressTrip = {
      id: "trip-progress", code: "ABC123", name: "Test", categories: [],
      members: [{ id: "member", name: "Test", group: "family", deletedAt: "", categories: [
        { id: "cat", name: "Test", deletedAt: "", items: [
          { id: "visible", name: "Visible", status: "done", done: true, deletedAt: "" },
          { id: "deleted", name: "Supprimé", status: "todo", done: false, deletedAt: "2026-08-01T11:00:00.000Z" }
        ] }
      ] }]
    };
  `);
  assert.deepEqual(engine.json("progressForVoyage(progressTrip)"), { total: 1, done: 1, percent: 100 });
});

test("BUG-V1-002: un nouveau voyage doit rester local jusqu'au partage", { todo: "Écart V1 confirmé: makeVoyage génère un code et marque shared=true." }, async () => {
  const engine = await engineWithLibrary();
  const trip = engine.json(`makeVoyage("Paris", "", { participants: ["Richard"], transport: [], lodging: [] })`);
  assert.equal(trip.shared, false);
  assert.equal(trip.code, "");
});

test("BUG-V1-003: une nouvelle liste rapide ne doit pas déclencher d'écriture distante", { todo: "Écart V1 confirmé: createQuickList appelle saveQuickListRemote immédiatement." }, async () => {
  const engine = await engineWithLibrary();
  engine.execute(`
    globalThis.remoteWriteCount = 0;
    globalThis.prompt = () => "Piscine locale";
    saveQuickListRemote = () => { globalThis.remoteWriteCount += 1; };
    createQuickList();
  `);
  assert.equal(engine.evaluate("remoteWriteCount"), 0);
  assert.equal(engine.evaluate("state.quickLists[0].shared"), false);
});
