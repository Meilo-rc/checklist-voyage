import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import vm from "node:vm";

const testDir = dirname(fileURLToPath(import.meta.url));
const projectRoot = resolve(testDir, "../..");

function createLocalStorage() {
  const values = new Map();
  return {
    getItem: key => values.has(key) ? values.get(key) : null,
    setItem: (key, value) => values.set(key, String(value)),
    removeItem: key => values.delete(key),
    clear: () => values.clear()
  };
}

export async function loadLegacyEngine() {
  const location = new URL("https://example.test/checklist/index.html");
  const sandbox = {
    console,
    Date,
    Math,
    Map,
    Set,
    URL,
    URLSearchParams,
    JSON,
    Promise,
    setTimeout,
    clearTimeout,
    localStorage: createLocalStorage(),
    navigator: {},
    document: {
      activeElement: null,
      getElementById: () => null,
      querySelector: () => null,
      querySelectorAll: () => []
    },
    window: {
      location,
      history: { replaceState() {} },
      confirm: () => true,
      prompt: () => null
    },
    alert() {},
    confirm: () => true,
    prompt: () => null,
    render() {},
    saveAndSync() {},
    saveQuickListAndSync() {},
    saveQuickListRemote() {},
    subscribeToCurrentVoyage() {},
    subscribeToCurrentQuickList() {},
    closeSheet() {},
    showToast() {}
  };
  sandbox.globalThis = sandbox;
  const context = vm.createContext(sandbox);
  for (const filename of ["app-config.js", "app.js", "app-sync.js"]) {
    const source = await readFile(resolve(projectRoot, filename), "utf8");
    vm.runInContext(source, context, { filename });
  }
  vm.runInContext(`
    render = () => {};
    saveAndSync = () => {};
    saveQuickListAndSync = () => {};
    subscribeToCurrentVoyage = () => {};
    subscribeToCurrentQuickList = () => {};
  `, context);

  return {
    context,
    evaluate(expression) {
      return vm.runInContext(expression, context);
    },
    execute(source) {
      return vm.runInContext(source, context);
    },
    json(expression) {
      return JSON.parse(vm.runInContext(`JSON.stringify(${expression})`, context));
    }
  };
}

export function seedReferenceLibrary(engine) {
  engine.execute(`
    state.voyages = [];
    state.quickLists = [];
    state.currentVoyageId = null;
    state.currentQuickListId = null;
    state.openMembers = {};
    state.openCats = {};
    state.customMemberAliases = {};
    state.customMemberIcons = {};
    state.customMemberDeletedAt = {};
    state.customCategoryMembers = [
      "Essentiel", "Richard", "Trajet - Avion", "Trajet - Train",
      "Logement - Hôtel", "Logement - Camping", "Privé"
    ];
    state.customMemberGroups = {
      "Essentiel": "general",
      "Richard": "family",
      "Trajet - Avion": "general",
      "Trajet - Train": "general",
      "Logement - Hôtel": "general",
      "Logement - Camping": "general",
      "Privé": "personal"
    };
    state.customCategories = [
      {
        id: "tpl-essential", member: "Essentiel", name: "Documents", icon: "document",
        updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "",
        items: [{ id: "tpl-item-passport", name: "Passeport", qty: 1, updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "" }]
      },
      {
        id: "tpl-richard", member: "Richard", name: "Vêtements", icon: "clothes",
        updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "",
        items: [{ id: "tpl-item-shirt", name: "T-shirt", qty: 2, updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "" }]
      },
      {
        id: "tpl-plane", member: "Trajet - Avion", name: "Cabine", icon: "plane",
        updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "",
        items: [{ id: "tpl-item-ticket-plane", name: "Billet", qty: 1, updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "" }]
      },
      {
        id: "tpl-train", member: "Trajet - Train", name: "Train", icon: "train",
        updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "",
        items: [{ id: "tpl-item-ticket-train", name: "Billet train", qty: 1, updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "" }]
      },
      {
        id: "tpl-hotel", member: "Logement - Hôtel", name: "Hôtel", icon: "hotel",
        updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "",
        items: [{ id: "tpl-item-hotel", name: "Réservation hôtel", qty: 1, updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "" }]
      },
      {
        id: "tpl-camping", member: "Logement - Camping", name: "Camping", icon: "tent",
        updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "",
        items: [{ id: "tpl-item-tent", name: "Tente", qty: 1, updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "" }]
      },
      {
        id: "tpl-private", member: "Privé", name: "Personnel", icon: "suitcase",
        updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "",
        items: [{ id: "tpl-item-private", name: "Objet privé", qty: 1, updatedAt: "2026-08-01T10:00:00.000Z", deletedAt: "" }]
      }
    ];
  `);
}
