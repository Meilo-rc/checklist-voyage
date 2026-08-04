const VERSION = "1.98";
const STORAGE_KEY = "checklist-voyage-state-v2";
const OLD_STORAGE_KEY = "travelChecklistState";
const PB_URL = "https://psyco.fly.dev";
const PB_COLLECTION = "travel_checklists";
const SETTINGS_CODE = "PARAMS";

let pb = null;
let unsubscribeCurrent = null;
let unsubscribeSettings = null;
let unsubscribeQuickList = null;
let settingsRecordId = "";
let syncTimer = null;
let pendingRemoteVoyage = null;
let statusText = "Synchronisé";
let draftDateRange = { start: "", end: "", next: "start" };
let draftCalendarMonth = new Date();
let selectedDestination = null;
let destinationSearchTimer = null;
let toastTimer = null;
let editingVoyageId = null;
let qtyEditorItemId = null;
let swipeStartX = 0;
let swipeStartY = 0;
let activeSwipeItemId = null;
let iconEditTarget = null;
let customCategoryMoveTarget = null;
const weatherFetchIds = new Set();
let draftVoyageParticipants = [];

const categoryIcons = [
  "baby", "beach", "bed", "boat", "bus", "calendar", "camera", "camping", "car", "clothes",
  "cocktail", "document", "first-aid", "gamepad", "hiking", "hotel", "meditation", "money",
  "music", "passport", "pet", "plane", "plug", "restaurant", "shopping", "ski", "snow",
  "sport", "suitcase", "sun", "swimming", "tag", "toiletries", "tools", "train", "video", "water"
];

const iconLabels = {
  baby: "Bébé",
  beach: "Plage",
  bed: "Lit",
  boat: "Bateau",
  bus: "Bus",
  calendar: "Dates",
  camera: "Photo",
  camping: "Camping",
  car: "Voiture",
  clothes: "Vêtements",
  cocktail: "Sorties",
  document: "Documents",
  "first-aid": "Santé",
  gamepad: "Jeux",
  hiking: "Rando",
  hotel: "Hôtel",
  meditation: "Bien-être",
  money: "Budget",
  music: "Musique",
  passport: "Passeport",
  pet: "Animal",
  plane: "Avion",
  plug: "Chargeurs",
  restaurant: "Repas",
  shopping: "Courses",
  ski: "Ski",
  snow: "Neige",
  sport: "Sport",
  suitcase: "Bagage",
  sun: "Soleil",
  swimming: "Piscine",
  tag: "Divers",
  toiletries: "Toilette",
  tools: "Outils",
  train: "Train",
  video: "Vidéo",
  water: "Eau"
};

const iconRules = [
  ["plane", ["avion", "vol", "aéroport", "depart", "départ"]],
  ["train", ["train", "rail"]],
  ["car", ["voiture", "auto", "route"]],
  ["bus", ["bus", "car scolaire"]],
  ["boat", ["bateau", "ferry", "mer"]],
  ["hotel", ["hotel", "hôtel"]],
  ["camping", ["camping", "tente"]],
  ["bed", ["logement", "location", "famille", "nuit"]],
  ["restaurant", ["repas", "restaurant", "alimentation", "nourriture", "cuisine"]],
  ["first-aid", ["santé", "sante", "pharmacie", "médicament", "medicament", "soin"]],
  ["toiletries", ["toilette", "hygiène", "hygiene", "trousse"]],
  ["clothes", ["vêtement", "vetement", "habit", "linge"]],
  ["plug", ["chargeur", "électronique", "electronique", "câble", "cable"]],
  ["hiking", ["randonnée", "randonnee", "marche"]],
  ["swimming", ["piscine", "baignade", "natation"]],
  ["beach", ["plage", "parasol"]],
  ["ski", ["ski"]],
  ["snow", ["neige", "hiver"]],
  ["baby", ["bébé", "bebe", "enfant", "poussette"]],
  ["pet", ["animal", "chien", "chat"]],
  ["passport", ["passeport", "identité", "identite"]],
  ["document", ["document", "papier", "réservation", "reservation"]],
  ["camera", ["photo", "camera", "caméra"]],
  ["money", ["argent", "budget", "monnaie"]],
  ["shopping", ["course", "achat", "shopping"]],
  ["gamepad", ["jeu", "jouet", "console"]],
  ["sun", ["soleil", "été", "ete", "météo", "meteo"]],
  ["sport", ["sport", "activité", "activite"]],
  ["suitcase", ["bagage", "valise", "sac"]]
];

const state = {
  tab: "voyages",
  voyages: [],
  quickLists: [],
  currentVoyageId: null,
  currentQuickListId: null,
  openMembers: {},
  openCats: {},
  customCategories: [],
  customCategoryMembers: [],
  customMemberAliases: {},
  customMemberGroups: {},
  customMemberDeletedAt: {}
};

const legacyMemberNameMap = {
  papa: "Richard",
  maman: "Jenna",
  "enfant 1": "Milo",
  bebe: "Malone",
  bébé: "Malone"
};

const defaultMemberNames = ["Richard", "Jenna", "Milo", "Malone"];
const defaultCustomGroupNames = ["Général", ...defaultMemberNames];

const idealCustomCategories = [
  { member: "Richard", name: "Photo", icon: "camera", items: ["Appareil photo", "Objectifs", "Cartes mémoire", "Batteries chargées", "Chargeur appareil photo", "Trépied compact", "Sangle / dragonne", "Chiffon microfibre"] },
  { member: "Richard", name: "Électronique", icon: "plug", items: ["Chargeurs téléphones", "Batterie externe", "Câbles USB-C / Lightning", "Adaptateur secteur", "Multiprise compacte", "Écouteurs", "Téléchargements hors ligne"] },
  { member: "Jenna", name: "Trousse de toilette", icon: "toiletries", items: ["Brosse à dents", "Dentifrice", "Shampoing / gel douche", "Déodorant", "Crème hydratante", "Brosse / élastiques", "Protections périodiques", "Trousse maquillage"] },
  { member: "Jenna", name: "Santé famille", icon: "first-aid", items: ["Doliprane adultes", "Doliprane enfants", "Thermomètre", "Pansements", "Désinfectant", "Sérum physiologique", "Ordonnances", "Crème solaire famille"] },
  { member: "Jenna", name: "Organisation", icon: "calendar", items: ["Planning du séjour", "Contacts utiles", "Liste courses arrivée", "Sacs linge sale", "Sacs réutilisables", "Petite lessive", "Lingettes multi-usage"] },
  { member: "Milo", name: "Vêtements 4 ans", icon: "clothes", items: ["Culottes / slips", "Chaussettes", "T-shirts", "Pulls", "Pantalons / shorts", "Pyjamas", "Veste", "Chaussures adaptées"] },
  { member: "Milo", name: "Jeux 4 ans", icon: "gamepad", items: ["Doudou", "Livres", "Petites voitures / figurines", "Coloriage", "Crayons", "Jeu de voyage", "Gourde", "Casquette"] },
  { member: "Milo", name: "Sorties enfant", icon: "beach", items: ["Lunettes de soleil", "Crème solaire enfant", "Maillot de bain", "Brassards si besoin", "Sac goûter", "Change complet", "K-way"] },
  { member: "Malone", name: "Change bébé 6 mois", icon: "baby", items: ["Couches", "Lingettes", "Liniment", "Matelas à langer nomade", "Sacs couches", "Bodies", "Pyjamas", "Bavoirs"] },
  { member: "Malone", name: "Repas bébé", icon: "restaurant", items: ["Biberons", "Lait infantile", "Petits pots", "Cuillères bébé", "Bavoirs repas", "Gourde / eau", "Boîte doseuse", "Goupillon"] },
  { member: "Malone", name: "Sommeil bébé", icon: "bed", items: ["Gigoteuse", "Doudou", "Tétines", "Babyphone", "Drap housse lit bébé", "Veilleuse", "Couverture légère", "Poussette / porte-bébé"] }
];

const defaultCategories = [
  {
    name: "Vêtements",
    items: [
      { name: "Sous-vêtements", qty: 1 },
      { name: "T-shirts", qty: 1 },
      { name: "Tenue chaude", qty: 1 }
    ]
  },
  {
    name: "Toilette",
    items: [
      { name: "Brosse à dents", qty: 1 },
      { name: "Dentifrice", qty: 1 },
      { name: "Trousse de toilette", qty: 1 }
    ]
  }
];

const presetItems = {
  transport: {
    avion: ["Billets d'avion", "Passeports / cartes d'identité", "Bagages cabine", "Étiquettes bagages", "Liquides en format cabine", "Arrivée à l'aéroport"],
    train: ["Billets de train", "Carte de réduction", "Collations trajet", "Lecture / écouteurs", "Plan de correspondance"],
    voiture: ["Permis de conduire", "Carte grise / assurance", "Plein de carburant", "Contrôle pneus", "Chargeur voiture", "Snacks trajet"],
    bus: ["Billets de bus", "Oreiller de voyage", "Gourde", "Pull léger", "Écouteurs"],
    bateau: ["Billets bateau", "Documents véhicule", "Médicament mal de mer", "Veste coupe-vent", "Sac de cabine"]
  },
  lodging: {
    hotel: ["Confirmation hôtel", "Moyen de paiement", "Trousse de toilette compacte", "Tenue restaurant", "Chargeur près du lit"],
    camping: ["Tente", "Duvets", "Matelas gonflables", "Lampe frontale", "Réchaud", "Anti-moustiques", "Glacière"],
    famille: ["Cadeau hôtes", "Draps si besoin", "Serviettes si besoin", "Jeux à partager", "Informations d'arrivée"],
    location: ["Contrat de location", "Codes / clés", "Draps", "Serviettes", "Torchons", "Produits vaisselle", "Courses premier soir"]
  },
  activity: {
    ski: ["Vestes de ski", "Pantalons de ski", "Gants", "Bonnets", "Masques / lunettes", "Sous-couches thermiques", "Chaussettes de ski", "Forfaits"],
    plage: ["Maillots de bain", "Serviettes de plage", "Crème solaire", "Casquettes", "Lunettes de soleil", "Gourdes", "Sac étanche"],
    randonnee: ["Chaussures de randonnée", "Sac à dos", "Gourdes", "Carte / itinéraire", "Coupe-vent", "Trousse premiers secours"],
    velo: ["Casques", "Antivols", "Gourdes vélo", "Kit réparation", "Gants vélo", "Charge éclairage"],
    visites: ["Billets visites", "Guide / appli hors-ligne", "Batterie externe", "Chaussures confortables", "Liste restaurants"],
    bebe: ["Couches", "Lingettes", "Doudou", "Poussette / porte-bébé", "Repas bébé", "Trousse médicaments enfant"]
  }
};

function uid(prefix) {
  return `${prefix}-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`;
}

function escapeHTML(value) {
  return String(value ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function generateCode() {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  let code = "";
  for (let i = 0; i < 6; i += 1) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
}

function cleanCode(value) {
  return String(value || "").toUpperCase().replace(/[^A-Z0-9]/g, "").slice(0, 8);
}

function normalizeQty(value) {
  const number = Number.parseInt(value, 10);
  if (!Number.isFinite(number) || number < 1) return 1;
  return Math.min(number, 99);
}

function normalizeItemStatus(item) {
  if (item?.status === "checked" || item?.status === "done") return item.status;
  return item?.done ? "done" : "todo";
}

function compareItemNames(a, b) {
  return String(a?.name || a || "").localeCompare(String(b?.name || b || ""), "fr", { sensitivity: "base" });
}

function sortCategoryItems(category) {
  if (!category?.items) return;
  const order = { todo: 0, checked: 1, done: 2 };
  category.items.sort((a, b) => {
    const statusDiff = order[normalizeItemStatus(a)] - order[normalizeItemStatus(b)];
    return statusDiff || compareItemNames(a, b);
  });
}

function sortQuickItems(list) {
  if (!list?.items) return;
  list.items.sort((a, b) => Number(a.done === true) - Number(b.done === true) || compareItemNames(a, b));
}

function sortCustomCategoryItems(category) {
  if (!category?.items) return;
  category.items.sort((a, b) => compareItemNames(a, b));
}

function customItemName(item) {
  return typeof item === "string" ? item : item?.name || "";
}

function isUserEditing() {
  const el = document.activeElement;
  return el && ["INPUT", "TEXTAREA", "SELECT"].includes(el.tagName);
}

function getPB() {
  if (pb || typeof PocketBase === "undefined") return pb;
  pb = new PocketBase(PB_URL);
  pb.autoCancellation(false);
  return pb;
}

function currentVoyage() {
  return state.voyages.find(voyage => voyage.id === state.currentVoyageId) || state.voyages[0] || null;
}

function currentQuickList() {
  return state.quickLists.find(list => list.id === state.currentQuickListId) || state.quickLists[0] || null;
}

function timestampValue(value) {
  const time = Date.parse(value || "");
  return Number.isFinite(time) ? time : 0;
}

function isRemoteNewer(remoteData, localData) {
  return timestampValue(remoteData?.updatedAt) > timestampValue(localData?.updatedAt);
}

function nowISO() {
  return new Date().toISOString();
}

function entityTimestamp(entity) {
  return Math.max(timestampValue(entity?.updatedAt), timestampValue(entity?.deletedAt));
}

function isDeleted(entity) {
  return Boolean(entity?.deletedAt);
}

function visibleItems(items = []) {
  return items.filter(item => !isDeleted(item));
}

function visibleQuickItems(items = []) {
  return items.filter(item => !isDeleted(item));
}

function visibleCustomItems(items = []) {
  return items.filter(item => !isDeleted(item));
}

function visibleCustomCategories(categories = []) {
  return categories.filter(category => !isDeleted(category));
}

function visibleCategories(categories = []) {
  return categories.filter(category => !isDeleted(category));
}

function visibleMembers(members = []) {
  return members.filter(member => !isDeleted(member));
}

function touchEntity(entity, timestamp = nowISO()) {
  if (entity) entity.updatedAt = timestamp;
  return timestamp;
}

function touchVoyage(voyage, timestamp = nowISO()) {
  if (voyage) voyage.updatedAt = timestamp;
  return timestamp;
}

function closeVoyageCategoryPanels(voyage) {
  if (!voyage) return;
  state.openMembers.general = false;
  (voyage.categories || []).forEach(category => {
    state.openCats[category.id] = false;
  });
  voyageMembers(voyage).forEach(member => {
    state.openMembers[member.id] = false;
    (member.categories || []).forEach(category => {
      state.openCats[category.id] = false;
    });
  });
}

function normalizeText(value) {
  return String(value || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase();
}

function categoryIconForName(name) {
  const normalized = normalizeText(name);
  const match = iconRules.find(([, words]) => words.some(word => normalized.includes(normalizeText(word))));
  return match ? match[0] : "tag";
}

function categoryIcon(category) {
  return category?.icon && categoryIcons.includes(category.icon) ? category.icon : categoryIconForName(category?.name);
}

function renderCategoryIcon(category) {
  const icon = categoryIcon(category);
  return `<span class="category-icon" style="--icon-url: url('./category-icons/${icon}.svg')" aria-hidden="true"></span>`;
}

function normalizeMemberName(value) {
  const name = String(value || "").trim();
  if (!name || normalizeText(name) === "autres") return "Général";
  const mapped = legacyMemberNameMap[normalizeText(name)];
  if (mapped) return mapped;
  return name;
}

function defaultMemberForCategory(category) {
  return normalizeMemberName(category?.member || category?.memberName || "");
}

function normalizeMemberGroup(value) {
  return value === "general" ? "general" : "family";
}

function createMember(name, categories = [], options = {}) {
  const timestamp = nowISO();
  return {
    id: uid("member"),
    name: normalizeMemberName(name),
    group: normalizeMemberGroup(options.group),
    updatedAt: options.updatedAt || timestamp,
    deletedAt: options.deletedAt || "",
    categories
  };
}

function createDefaultMembers(options = {}) {
  return defaultMemberNames.map(name => createMember(name, createDefaultCategories({
    ...options,
    transport: [],
    lodging: []
  })));
}

function cloneTemplateCategory(template) {
  const timestamp = nowISO();
  return {
    id: uid("cat"),
    name: template.name,
    icon: categoryIcon(template),
    updatedAt: timestamp,
    deletedAt: "",
    items: visibleCustomItems(template.items || []).map(item => ({
      id: uid("item"),
      name: customItemName(item),
      qty: normalizeQty(item.qty || 1),
      status: "todo",
      done: false,
      updatedAt: timestamp,
      deletedAt: ""
    }))
  };
}

function createMembersFromParticipants(participants = [], options = {}) {
  const names = participants
    .map(normalizeMemberName)
    .filter(name => name && name !== "Général")
    .filter((name, index, list) => list.indexOf(name) === index);
  if (!names.length) return createDefaultMembers(options);
  return names.map(name => {
    const categories = visibleCustomCategories(state.customCategories)
      .filter(category => defaultMemberForCategory(category) === name)
      .map(cloneTemplateCategory);
    enrichCategories(categories, "Activités", options.activity || [], presetItems.activity);
    return createMember(name, categories);
  });
}

function createGeneralCategories(options = {}) {
  const categories = [{
    id: uid("cat"),
    name: "Documents",
    icon: "document",
    items: [
      { id: uid("item"), name: "Passeports / cartes d'identité", qty: 1, status: "todo", done: false },
      { id: uid("item"), name: "Billets et réservations", qty: 1, status: "todo", done: false },
      { id: uid("item"), name: "Permis / assurance", qty: 1, status: "todo", done: false },
      { id: uid("item"), name: "Moyens de paiement", qty: 1, status: "todo", done: false }
    ]
  }];
  enrichCategories(categories, "Transport", options.transport || [], presetItems.transport);
  enrichCategories(categories, "Logement", options.lodging || [], presetItems.lodging);
  return categories;
}

function normalizeMember(raw) {
  const member = raw && typeof raw === "object" ? raw : {};
  return {
    id: member.id || uid("member"),
    name: normalizeMemberName(member.name || "Membre"),
    group: normalizeMemberGroup(member.group),
    updatedAt: member.updatedAt || "",
    deletedAt: member.deletedAt || "",
    categories: Array.isArray(member.categories) ? member.categories.map(normalizeCategory) : []
  };
}

function voyageMembers(voyage) {
  if (Array.isArray(voyage?.members) && voyage.members.length) return visibleMembers(voyage.members);
  return [];
}

function allVoyageCategories(voyage) {
  const members = voyageMembers(voyage);
  if (members.length) return [
    ...(Array.isArray(voyage?.categories) ? visibleCategories(voyage.categories) : []),
    ...members.flatMap(member => visibleCategories(member.categories || []))
  ];
  return Array.isArray(voyage?.categories) ? visibleCategories(voyage.categories) : [];
}

function findCategoryInVoyage(voyage, categoryId) {
  for (const member of voyageMembers(voyage)) {
    const category = visibleCategories(member.categories || []).find(item => item.id === categoryId);
    if (category) return { member, category };
  }
  const category = visibleCategories(voyage?.categories || []).find(item => item.id === categoryId);
  return category ? { member: null, category } : { member: null, category: null };
}

function mergeCategoryItems(target, source) {
  const existing = new Set((target.items || []).map(item => normalizeText(item.name)));
  (source.items || []).forEach(item => {
    if (existing.has(normalizeText(item.name))) return;
    target.items.push(normalizeItem(item));
    existing.add(normalizeText(item.name));
  });
}

function moveMemberDocumentsToGeneral(categories, members) {
  let documents = categories.find(category => normalizeText(category.name) === "documents");
  members.forEach(member => {
    const remaining = [];
    (member.categories || []).forEach(category => {
      if (normalizeText(category.name) !== "documents") {
        remaining.push(category);
        return;
      }
      if (!documents) {
        documents = {
          id: uid("cat"),
          name: "Documents",
          icon: "document",
          items: []
        };
        categories.unshift(documents);
      }
      mergeCategoryItems(documents, category);
    });
    member.categories = remaining;
  });
  return categories;
}

function createDefaultCategories(options = {}) {
  const categories = defaultCategories.map(category => ({
    id: uid("cat"),
    name: category.name,
    icon: categoryIconForName(category.name),
    items: category.items.map(item => ({
      id: uid("item"),
      name: item.name,
      qty: item.qty,
      done: false
    }))
  }));
  enrichCategories(categories, "Transport", options.transport || [], presetItems.transport);
  enrichCategories(categories, "Logement", options.lodging || [], presetItems.lodging);
  enrichCategories(categories, "Activités", options.activity || [], presetItems.activity);
  return categories;
}

function enrichCategories(categories, categoryName, choices, presets) {
  const names = [];
  choices.forEach(choice => {
    (presets[choice] || []).forEach(name => {
      if (!names.includes(name)) names.push(name);
    });
  });
  if (!names.length) return;
  let category = categories.find(item => item.name === categoryName);
  if (!category) {
    category = {
      id: uid("cat"),
      name: categoryName,
      icon: categoryIconForName(categoryName),
      items: []
    };
    categories.push(category);
  }
  const existing = new Set(category.items.map(item => item.name));
  names.forEach(name => {
    if (existing.has(name)) return;
    category.items.push({
      id: uid("item"),
      name,
      qty: 1,
      done: false
    });
  });
}

function makeVoyage(name, date, options = {}) {
  const voyage = {
    id: uid("voyage"),
    code: generateCode(),
    name: name || "Nouveau voyage",
    date: date || "",
    startDate: options.startDate || "",
    endDate: options.endDate || "",
    destination: options.destination || null,
    presetOptions: options.presetOptions || {
      transport: options.transport || [],
      lodging: options.lodging || [],
      activity: options.activity || [],
      participants: options.participants || []
    },
    enrichment: options.enrichment || null,
    shared: true,
    remoteRecordId: "",
    members: createMembersFromParticipants(options.participants || [], options),
    categories: createGeneralCategories(options),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  voyage.members.forEach(member => {
    state.openMembers[member.id] = false;
    member.categories.forEach(category => {
      state.openCats[category.id] = false;
    });
  });
  voyage.categories.forEach(category => {
    state.openCats[category.id] = false;
  });
  return voyage;
}

function normalizeVoyage(raw) {
  const voyage = raw && typeof raw === "object" ? raw : {};
  const legacyCategories = Array.isArray(voyage.categories) ? voyage.categories.map(normalizeCategory) : [];
  const members = Array.isArray(voyage.members) && voyage.members.length
    ? voyage.members.map(normalizeMember)
    : defaultMemberNames.map((name, index) => createMember(name, index === 0 ? legacyCategories : []));
  const generalCategories = moveMemberDocumentsToGeneral(
    Array.isArray(voyage.categories) && (Array.isArray(voyage.members) && voyage.members.length)
      ? voyage.categories.map(normalizeCategory)
      : [],
    members
  );
  const normalized = {
    id: voyage.id || uid("voyage"),
    code: cleanCode(voyage.code) || generateCode(),
    name: voyage.name || "Voyage",
    date: voyage.date || "",
    startDate: voyage.startDate || "",
    endDate: voyage.endDate || "",
    destination: voyage.destination || null,
    presetOptions: voyage.presetOptions || { transport: [], lodging: [], activity: [] },
    enrichment: voyage.enrichment || null,
    shared: Boolean(voyage.shared || voyage.remoteRecordId),
    remoteRecordId: voyage.remoteRecordId || "",
    createdAt: voyage.createdAt || new Date().toISOString(),
    updatedAt: voyage.updatedAt || new Date().toISOString(),
    members,
    categories: generalCategories
  };
  return normalized;
}

function normalizeCategory(raw) {
  const category = raw && typeof raw === "object" ? raw : {};
  return {
    id: category.id || uid("cat"),
    name: category.name || "Catégorie",
    icon: category.icon && categoryIcons.includes(category.icon) ? category.icon : categoryIconForName(category.name || "Catégorie"),
    updatedAt: category.updatedAt || "",
    deletedAt: category.deletedAt || "",
    items: Array.isArray(category.items) ? category.items.map(normalizeItem) : []
  };
}

function normalizeQuickItem(raw) {
  const item = raw && typeof raw === "object" ? raw : { name: raw };
  return {
    id: item.id || uid("quick-item"),
    name: item.name || "",
    done: item.done === true,
    qty: normalizeQty(item.qty || 1),
    updatedAt: item.updatedAt || "",
    deletedAt: item.deletedAt || ""
  };
}

function normalizeQuickList(raw) {
  const list = raw && typeof raw === "object" ? raw : {};
  return {
    id: list.id || uid("quick"),
    code: cleanCode(list.code) || generateCode(),
    name: list.name || "Liste rapide",
    type: "quickList",
    items: Array.isArray(list.items) ? list.items.map(normalizeQuickItem).filter(item => item.name) : [],
    shared: list.shared === true,
    remoteRecordId: list.remoteRecordId || "",
    createdAt: list.createdAt || new Date().toISOString(),
    updatedAt: list.updatedAt || new Date().toISOString()
  };
}

function normalizeItem(raw) {
  const item = raw && typeof raw === "object" ? raw : {};
  const status = normalizeItemStatus(item);
  return {
    id: item.id || uid("item"),
    name: item.name || "Élément",
    qty: normalizeQty(item.qty || 1),
    status,
    done: status === "done",
    updatedAt: item.updatedAt || "",
    deletedAt: item.deletedAt || ""
  };
}

function normalizeCustomCategory(raw) {
  const category = raw && typeof raw === "object" ? raw : {};
  return {
    id: category.id || uid("tpl"),
    name: category.name || "Cat\u00e9gorie personnalis\u00e9e",
    icon: category.icon && categoryIcons.includes(category.icon) ? category.icon : categoryIconForName(category.name || "Cat\u00e9gorie personnalis\u00e9e"),
    member: defaultMemberForCategory(category),
    updatedAt: category.updatedAt || "",
    deletedAt: category.deletedAt || "",
    items: Array.isArray(category.items)
      ? category.items.map(normalizeCustomItem).filter(item => item.name)
      : []
  };
}

function normalizeCustomItem(raw) {
  const item = raw && typeof raw === "object" ? raw : { name: raw };
  return {
    id: item.id || uid("tpl-item"),
    name: item.name || "",
    qty: normalizeQty(item.qty || 1),
    updatedAt: item.updatedAt || "",
    deletedAt: item.deletedAt || ""
  };
}
function newerEntity(a, b) {
  if (!a) return b;
  if (!b) return a;
  return entityTimestamp(b) > entityTimestamp(a) ? b : a;
}

function mergeById(localItems = [], remoteItems = [], mergeEntity = newerEntity) {
  const ids = new Set([
    ...localItems.map(item => item?.id).filter(Boolean),
    ...remoteItems.map(item => item?.id).filter(Boolean)
  ]);
  return [...ids].map(id => {
    const local = localItems.find(item => item?.id === id);
    const remote = remoteItems.find(item => item?.id === id);
    return mergeEntity(local, remote);
  }).filter(Boolean);
}

function mergeByIdOrName(localItems = [], remoteItems = [], mergeEntity = newerEntity) {
  const keyFor = item => normalizeText(item?.name || item) || item?.id;
  const keys = new Set([
    ...localItems.map(keyFor).filter(Boolean),
    ...remoteItems.map(keyFor).filter(Boolean)
  ]);
  return [...keys].map(key => {
    const local = localItems.find(item => keyFor(item) === key);
    const remote = remoteItems.find(item => keyFor(item) === key);
    return mergeEntity(local, remote);
  }).filter(Boolean);
}

function mergeItems(local, remote) {
  return newerEntity(local, remote);
}

function mergeCategories(local, remote) {
  const base = newerEntity(local, remote);
  if (!local || !remote) return base;
  return {
    ...base,
    items: mergeById(local.items || [], remote.items || [], mergeItems)
  };
}

function mergeMembers(local, remote) {
  const base = newerEntity(local, remote);
  if (!local || !remote) return base;
  return {
    ...base,
    categories: mergeById(local.categories || [], remote.categories || [], mergeCategories)
  };
}

function mergeVoyages(localVoyage, remoteVoyage) {
  const local = normalizeVoyage(localVoyage);
  const remote = normalizeVoyage(remoteVoyage);
  const base = timestampValue(remote.updatedAt) > timestampValue(local.updatedAt) ? remote : local;
  return normalizeVoyage({
    ...base,
    id: local.id || remote.id,
    code: local.code || remote.code,
    remoteRecordId: remote.remoteRecordId || local.remoteRecordId,
    shared: true,
    categories: mergeById(local.categories || [], remote.categories || [], mergeCategories),
    members: mergeById(local.members || [], remote.members || [], mergeMembers),
    updatedAt: nowISO()
  });
}

function mergeQuickLists(localList, remoteList) {
  const local = normalizeQuickList(localList);
  const remote = normalizeQuickList(remoteList);
  const base = timestampValue(remote.updatedAt) > timestampValue(local.updatedAt) ? remote : local;
  return normalizeQuickList({
    ...base,
    id: local.id || remote.id,
    code: local.code || remote.code,
    remoteRecordId: remote.remoteRecordId || local.remoteRecordId,
    shared: true,
    items: mergeByIdOrName(local.items || [], remote.items || [], newerEntity),
    updatedAt: nowISO()
  });
}

function quickListKey(list) {
  return normalizeText(list?.name) || cleanCode(list?.code) || list?.id || "";
}

function quickListScore(list) {
  const visibleCount = visibleQuickItems(list?.items || []).length;
  return timestampValue(list?.updatedAt) + visibleCount;
}

function dedupeQuickLists() {
  const before = state.quickLists.length;
  const groups = new Map();
  state.quickLists
    .filter(Boolean)
    .map(normalizeQuickList)
    .forEach(list => {
      const key = quickListKey(list);
      if (!key) return;
      const existing = groups.get(key);
      if (!existing) {
        groups.set(key, list);
        return;
      }
      const base = quickListScore(list) > quickListScore(existing) ? list : existing;
      const other = base === list ? existing : list;
      const merged = mergeQuickLists(base, other);
      merged.id = base.id;
      merged.code = base.code || other.code;
      merged.remoteRecordId = base.remoteRecordId || other.remoteRecordId;
      groups.set(key, merged);
    });
  state.quickLists = [...groups.values()].sort((a, b) => timestampValue(b.updatedAt) - timestampValue(a.updatedAt));
  if (!state.quickLists.some(list => list.id === state.currentQuickListId)) {
    state.currentQuickListId = state.quickLists[0]?.id || null;
  }
  return state.quickLists.length !== before;
}

function mergeCustomCategories(localCategory, remoteCategory) {
  const local = normalizeCustomCategory(localCategory);
  const remote = normalizeCustomCategory(remoteCategory);
  const base = newerEntity(local, remote);
  return normalizeCustomCategory({
    ...base,
    items: mergeByIdOrName(local.items || [], remote.items || [], newerEntity)
  });
}

function mergeCustomCategoryList(localCategories = [], remoteCategories = []) {
  const keyFor = category => `${normalizeText(defaultMemberForCategory(category))}:${normalizeText(category?.name)}` || category?.id;
  const keys = new Set([
    ...localCategories.map(keyFor).filter(Boolean),
    ...remoteCategories.map(keyFor).filter(Boolean)
  ]);
  return [...keys].map(key => {
    const local = localCategories.find(category => keyFor(category) === key);
    const remote = remoteCategories.find(category => keyFor(category) === key);
    return mergeCustomCategories(local, remote);
  }).filter(Boolean);
}

function mergeSettingsData(localData, remoteData) {
  const localSource = localData?.customCategories || localData?.voyage?.categories || [];
  const remoteSource = remoteData?.customCategories || remoteData?.voyage?.categories || [];
  const localMembers = Array.isArray(localData?.customCategoryMembers) ? localData.customCategoryMembers : [];
  const remoteMembers = Array.isArray(remoteData?.customCategoryMembers) ? remoteData.customCategoryMembers : [];
  const members = [...localMembers, ...remoteMembers]
    .map(normalizeMemberName)
    .filter((name, index, list) => list.indexOf(name) === index);
  return {
    type: "settings",
    customCategories: mergeCustomCategoryList(
      localSource.map(normalizeCustomCategory),
      remoteSource.map(normalizeCustomCategory)
    ),
    customCategoryMembers: members,
    customMemberAliases: {
      ...(localData?.customMemberAliases || {}),
      ...(remoteData?.customMemberAliases || {})
    },
    customMemberGroups: {
      ...(localData?.customMemberGroups || {}),
      ...(remoteData?.customMemberGroups || {})
    },
    customMemberDeletedAt: {
      ...(localData?.customMemberDeletedAt || {}),
      ...(remoteData?.customMemberDeletedAt || {})
    },
    updatedAt: nowISO()
  };
}

function customMemberGroupValue(memberName, groups = state.customMemberGroups) {
  const name = normalizeMemberName(memberName);
  if (name === "Général") return "general";
  const group = groups?.[name];
  return group === "general" || group === "personal" ? group : "family";
}

function isPersonalCustomMember(memberName, groups = state.customMemberGroups) {
  return customMemberGroupValue(memberName, groups) === "personal";
}

function isPersonalCustomCategory(category, groups = state.customMemberGroups) {
  return isPersonalCustomMember(defaultMemberForCategory(category), groups);
}

function personalSettingsSnapshot() {
  const groups = state.customMemberGroups || {};
  const categories = state.customCategories.filter(category => isPersonalCustomCategory(category, groups));
  const personalMembers = new Set([
    ...state.customCategoryMembers.filter(name => isPersonalCustomMember(name, groups)),
    ...categories.map(defaultMemberForCategory)
  ].map(normalizeMemberName));
  const memberGroups = Object.fromEntries(
    Object.entries(groups).filter(([name, group]) => group === "personal" || personalMembers.has(normalizeMemberName(name)))
  );
  const memberDeletedAt = Object.fromEntries(
    Object.entries(state.customMemberDeletedAt || {}).filter(([name]) => personalMembers.has(normalizeMemberName(name)))
  );
  return {
    customCategories: categories,
    customCategoryMembers: [...personalMembers],
    customMemberGroups: memberGroups,
    customMemberDeletedAt: memberDeletedAt
  };
}

function syncedSettingsState() {
  const customCategories = state.customCategories.filter(category => !isPersonalCustomCategory(category));
  const customCategoryMembers = state.customCategoryMembers
    .map(normalizeMemberName)
    .filter(name => !isPersonalCustomMember(name))
    .filter((name, index, list) => list.indexOf(name) === index);
  const customMemberGroups = Object.fromEntries(
    Object.entries(state.customMemberGroups || {}).filter(([, group]) => group !== "personal")
  );
  const customMemberDeletedAt = Object.fromEntries(
    Object.entries(state.customMemberDeletedAt || {}).filter(([name]) => !isPersonalCustomMember(name))
  );
  return { customCategories, customCategoryMembers, customMemberGroups, customMemberDeletedAt };
}

function saveLocal() {
  const payload = {
    version: VERSION,
    currentVoyageId: state.currentVoyageId,
    currentQuickListId: state.currentQuickListId,
    voyages: state.voyages,
    quickLists: state.quickLists,
    openMembers: state.openMembers,
    openCats: state.openCats,
    customCategories: state.customCategories,
    customCategoryMembers: state.customCategoryMembers,
    customMemberAliases: state.customMemberAliases,
    customMemberGroups: state.customMemberGroups,
    customMemberDeletedAt: state.customMemberDeletedAt,
    settingsRecordId
  };
  localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
}

function backupPayload() {
  return {
    schema: "checklist-voyage-backup-v1",
    app: "checklist-voyage",
    version: VERSION,
    exportedAt: new Date().toISOString(),
    data: {
      currentVoyageId: state.currentVoyageId,
      currentQuickListId: state.currentQuickListId,
      voyages: state.voyages,
      quickLists: state.quickLists,
      openMembers: state.openMembers,
      openCats: state.openCats,
      customCategories: state.customCategories,
      customCategoryMembers: state.customCategoryMembers,
      customMemberAliases: state.customMemberAliases,
      customMemberGroups: state.customMemberGroups,
      customMemberDeletedAt: state.customMemberDeletedAt,
      settingsRecordId
    }
  };
}

function exportBackup() {
  closeSettingsMenu();
  const stamp = new Date().toISOString().slice(0, 10);
  const blob = new Blob([JSON.stringify(backupPayload(), null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `sauvegarde-checklist-voyage-${stamp}.json`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
  showToast("Sauvegarde export\u00e9e");
}

function openBackupImport() {
  closeSettingsMenu();
  const input = document.getElementById("backupImportInput");
  if (!input) return;
  input.value = "";
  input.click();
}

function readBackupData(payload) {
  const data = payload?.schema === "checklist-voyage-backup-v1" && payload?.data ? payload.data : payload;
  if (!data || typeof data !== "object") throw new Error("Format invalide");
  return data;
}

async function importBackupFile(event) {
  const input = event.currentTarget;
  const file = input.files?.[0];
  if (!file) return;
  try {
    const payload = JSON.parse(await file.text());
    const data = readBackupData(payload);
    const message = "Importer cette sauvegarde va remplacer les voyages, listes rapides et cat\u00e9gories personnalis\u00e9es de cet appareil, puis relancer la synchronisation PocketBase.";
    if (!window.confirm(message)) return;

    state.voyages = Array.isArray(data.voyages) ? data.voyages.map(normalizeVoyage) : [];
    state.quickLists = Array.isArray(data.quickLists) ? data.quickLists.map(normalizeQuickList) : [];
    dedupeQuickLists();
    state.currentVoyageId = data.currentVoyageId && state.voyages.some(voyage => voyage.id === data.currentVoyageId)
      ? data.currentVoyageId
      : state.voyages[0]?.id || null;
    state.currentQuickListId = data.currentQuickListId && state.quickLists.some(list => list.id === data.currentQuickListId)
      ? data.currentQuickListId
      : state.quickLists[0]?.id || null;
    state.openMembers = data.openMembers && typeof data.openMembers === "object" ? data.openMembers : {};
    state.openCats = data.openCats && typeof data.openCats === "object" ? data.openCats : {};
    state.customCategories = Array.isArray(data.customCategories) ? data.customCategories.map(normalizeCustomCategory) : [];
    state.customCategoryMembers = Array.isArray(data.customCategoryMembers) ? data.customCategoryMembers.map(normalizeMemberName) : [];
    state.customMemberAliases = data.customMemberAliases && typeof data.customMemberAliases === "object" ? data.customMemberAliases : {};
    state.customMemberGroups = data.customMemberGroups && typeof data.customMemberGroups === "object" ? data.customMemberGroups : {};
    state.customMemberDeletedAt = data.customMemberDeletedAt && typeof data.customMemberDeletedAt === "object" ? data.customMemberDeletedAt : {};
    settingsRecordId = data.settingsRecordId || settingsRecordId || "";

    saveLocal();
    render();
    showToast("Sauvegarde import\u00e9e");
    setStatus("Synchronisation...");
    await saveSharedSettings();
    syncAllVoyages({ immediate: true });
    syncAllQuickLists({ immediate: true });
    subscribeToCurrentVoyage();
    subscribeToCurrentQuickList();
  } catch (error) {
    console.warn("Import de sauvegarde impossible", error);
    alert("Cette sauvegarde ne peut pas \u00eatre import\u00e9e. V\u00e9rifie que c'est bien un fichier JSON export\u00e9 depuis l'application.");
  } finally {
    input.value = "";
  }
}

function loadLocal() {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (raw) {
    try {
      const parsed = JSON.parse(raw);
      state.voyages = Array.isArray(parsed.voyages) ? parsed.voyages.map(normalizeVoyage) : [];
      state.quickLists = Array.isArray(parsed.quickLists) ? parsed.quickLists.map(normalizeQuickList) : [];
      dedupeQuickLists();
      state.currentVoyageId = parsed.currentVoyageId || state.voyages[0]?.id || null;
      state.currentQuickListId = parsed.currentQuickListId && state.quickLists.some(list => list.id === parsed.currentQuickListId)
        ? parsed.currentQuickListId
        : state.quickLists[0]?.id || null;
      state.openMembers = parsed.openMembers && typeof parsed.openMembers === "object" ? parsed.openMembers : {};
      state.openCats = parsed.openCats && typeof parsed.openCats === "object" ? parsed.openCats : {};
      state.customCategories = Array.isArray(parsed.customCategories) ? parsed.customCategories.map(normalizeCustomCategory) : [];
      state.customCategoryMembers = Array.isArray(parsed.customCategoryMembers) ? parsed.customCategoryMembers.map(normalizeMemberName) : [];
      state.customMemberAliases = parsed.customMemberAliases && typeof parsed.customMemberAliases === "object" ? parsed.customMemberAliases : {};
      state.customMemberGroups = parsed.customMemberGroups && typeof parsed.customMemberGroups === "object" ? parsed.customMemberGroups : {};
      state.customMemberDeletedAt = parsed.customMemberDeletedAt && typeof parsed.customMemberDeletedAt === "object" ? parsed.customMemberDeletedAt : {};
      settingsRecordId = parsed.settingsRecordId || "";
      return;
    } catch (error) {
      console.warn("Impossible de charger le stockage v2", error);
    }
  }
  migrateOldLocalState();
}

function migrateOldLocalState() {
  const oldRaw = localStorage.getItem(OLD_STORAGE_KEY);
  if (!oldRaw) return;
  try {
    const oldState = JSON.parse(oldRaw);
    const oldVoyages = Array.isArray(oldState.voyages) ? oldState.voyages : [];
    state.voyages = oldVoyages.map(voyage => normalizeVoyage({
      ...voyage,
      code: voyage.code || generateCode(),
      shared: true,
      remoteRecordId: ""
    }));
    state.currentVoyageId = state.voyages[0]?.id || null;
    saveLocal();
  } catch (error) {
    console.warn("Migration ancien stockage impossible", error);
  }
}

function progressForVoyage(voyage) {
  const items = allVoyageCategories(voyage).flatMap(category => category.items);
  const total = items.length;
  const done = items.filter(item => normalizeItemStatus(item) === "done").length;
  return {
    total,
    done,
    percent: total ? Math.round((done / total) * 100) : 0
  };
}

function progressForCategory(category) {
  const items = visibleItems(category.items || []);
  const total = items.length;
  const done = items.filter(item => normalizeItemStatus(item) === "done").length;
  return {
    total,
    done,
    percent: total ? Math.round((done / total) * 100) : 0
  };
}

function progressForMember(member) {
  const items = visibleCategories(member.categories || []).flatMap(category => visibleItems(category.items || []));
  const total = items.length;
  const done = items.filter(item => normalizeItemStatus(item) === "done").length;
  return {
    total,
    done,
    percent: total ? Math.round((done / total) * 100) : 0
  };
}

function progressStyle(percent) {
  const value = Math.max(1, Math.min(100, Number(percent) || 0));
  return `width:${percent}%; --progress-value:${value};`;
}

function renderChecklistGroup(title, content, emptyLabel = "") {
  return `
    <section class="checklist-group">
      <h3 class="checklist-group-title">${escapeHTML(title)}</h3>
      <div class="checklist-group-items">
        ${content || (emptyLabel ? `<div class="notice">${escapeHTML(emptyLabel)}</div>` : "")}
      </div>
    </section>
  `;
}

function setStatus(text) {
  statusText = text;
  const status = document.getElementById("headerMeta");
  const voyage = currentVoyage();
  if (status) {
    if (state.tab === "voyages") {
      const count = state.voyages.length;
      status.textContent = count ? `${count} voyage${count > 1 ? "s" : ""} enregistré${count > 1 ? "s" : ""}` : "Ajoutez votre premier voyage";
    } else {
      status.textContent = voyage ? `${voyage.name} · ${text}` : "Préparez vos sacs sans prise de tête";
    }
  }
}

function setTab(tab) {
  state.tab = tab;
  saveLocal();
  render();
  if (tab === "liste") {
    setTimeout(() => document.getElementById("content")?.scrollTo({ top: 0, behavior: "smooth" }), 0);
  }
}

function voyageParticipantNames() {
  return templateMemberNames();
}

function renderVoyageParticipantPicker() {
  const select = document.getElementById("voyageParticipantSelect");
  const target = document.getElementById("voyageParticipantChoices");
  if (!select || !target) return;
  const members = voyageParticipantNames();
  const selected = draftVoyageParticipants.map(normalizeMemberName);
  const available = members.filter(name => !selected.includes(name));
  select.disabled = !available.length;
  select.innerHTML = [
    `<option value="">${available.length ? "Ajouter un participant" : "Tous les participants sont ajoutés"}</option>`,
    ...available.map(name => `<option value="${escapeHTML(name)}">${escapeHTML(name)}</option>`)
  ].join("");
  target.innerHTML = selected.length
    ? selected.map(name => `
      <button class="template-chip" type="button" onclick="removeVoyageParticipant('${escapeHTML(name)}')" title="Retirer ${escapeHTML(name)}">
        ${escapeHTML(name)} ×
      </button>
    `).join("")
    : `<div class="notice">Choisissez les participants du voyage.</div>`;
}

function addVoyageParticipantFromSelect(memberName) {
  const name = normalizeMemberName(memberName);
  if (!name || draftVoyageParticipants.includes(name)) return;
  draftVoyageParticipants.push(name);
  renderVoyageParticipantPicker();
}

function removeVoyageParticipant(memberName) {
  const name = normalizeMemberName(memberName);
  draftVoyageParticipants = draftVoyageParticipants.filter(item => item !== name);
  renderVoyageParticipantPicker();
}

function goHome() {
  state.tab = "voyages";
  saveLocal();
  render();
}

function openVoyageSheet(voyageId = null) {
  editingVoyageId = voyageId;
  const voyage = voyageId ? state.voyages.find(item => item.id === voyageId) : null;
  document.getElementById("voyageSheetTitle").textContent = voyage ? "Modifier le voyage" : "Nouveau voyage";
  document.getElementById("voyageSubmitButton").textContent = voyage ? "Enregistrer" : "Créer";
  document.getElementById("joinDivider").style.display = voyage ? "none" : "";
  document.getElementById("joinForm").style.display = voyage ? "none" : "";
  document.getElementById("voyageParticipantsBlock").style.display = voyage ? "none" : "";
  document.getElementById("voyageName").value = "";
  document.getElementById("voyageLocation").value = "";
  draftVoyageParticipants = [];
  if (!voyage) renderVoyageParticipantPicker();
  selectedDestination = null;
  renderDestinationSuggestions([]);
  resetDraftDateRange();
  document.getElementById("sheetJoinCode").value = "";
  document.querySelectorAll("#voyageSheet input[type='checkbox']").forEach(input => {
    input.checked = false;
  });
  if (voyage) {
    document.getElementById("voyageName").value = voyage.name || "";
    selectedDestination = voyage.destination || voyage.enrichment?.location || null;
    document.getElementById("voyageLocation").value = selectedDestination
      ? [selectedDestination.name, selectedDestination.admin1, selectedDestination.country].filter(Boolean).join(", ")
      : "";
    draftDateRange = {
      start: voyage.startDate || "",
      end: voyage.endDate || "",
      next: voyage.startDate && !voyage.endDate ? "end" : "start"
    };
    if (voyage.startDate) draftCalendarMonth = new Date(`${voyage.startDate}T00:00:00`);
    renderRangeCalendar();
    const status = document.getElementById("voyageRangeStatus");
    if (status) status.textContent = voyage.date || "Choisissez la date de départ, puis la date de retour.";
    const presets = voyage.presetOptions || {};
    ["transport", "lodging", "activity"].forEach(group => {
      (presets[group] || []).forEach(value => {
        const input = document.querySelector(`#voyageSheet input[name='${group}'][value='${value}']`);
        if (input) input.checked = true;
      });
    });
  }
  document.getElementById("voyageSheet").classList.add("open");
  setTimeout(() => document.getElementById("voyageLocation").focus(), 50);
}

function closeSheet(id) {
  document.getElementById(id).classList.remove("open");
  if (id === "voyageSheet") editingVoyageId = null;
  if (id === "iconSheet") iconEditTarget = null;
  if (id === "customCategoryMoveSheet") customCategoryMoveTarget = null;
}

function closeSheetOnBackdrop(event, id) {
  if (event.target.id === id) closeSheet(id);
}

async function saveVoyageSheet(event) {
  event.preventDefault();
  const form = event.currentTarget;
  const submit = form.querySelector("button[type='submit']");
  const existing = editingVoyageId ? state.voyages.find(item => item.id === editingVoyageId) : null;
  const tripName = form.elements.tripName.value.trim();
  const destinationText = form.elements.location.value.trim();
  if (!destinationText) {
    alert("Choisis une destination pour créer le voyage.");
    return;
  }
  const date = formatDateRange(draftDateRange.start, draftDateRange.end);
  const options = {
    ...getVoyagePresetOptions(form),
    startDate: draftDateRange.start,
    endDate: draftDateRange.end,
    destination: selectedDestination,
    participants: existing ? voyageMembers(existing).map(member => member.name) : [...draftVoyageParticipants]
  };
  if (!existing && !options.participants.length) {
    alert("Choisis au moins un participant pour créer le voyage.");
    return;
  }
  if (submit) {
    submit.disabled = true;
    submit.textContent = existing ? "Enregistrement..." : "Création...";
  }
  options.destination = selectedDestination || await resolveDestination(destinationText);
  options.enrichment = null;
  const voyageName = tripName || options.destination?.name || destinationText || "Nouveau voyage";
  let voyage = existing;
  if (voyage) {
    voyage.name = voyageName;
    voyage.date = date;
    voyage.startDate = options.startDate;
    voyage.endDate = options.endDate;
    voyage.destination = options.destination;
    voyage.presetOptions = {
      transport: options.transport,
      lodging: options.lodging,
      activity: options.activity,
      participants: voyageMembers(voyage).map(member => member.name)
    };
    enrichCategories(voyage.categories, "Général", [...options.transport, ...options.lodging], {
      ...presetItems.transport,
      ...presetItems.lodging
    });
    voyageMembers(voyage).forEach(member => {
      enrichCategories(member.categories, "Activités", options.activity, presetItems.activity);
    });
    touchVoyage(voyage);
  } else {
    voyage = makeVoyage(voyageName, date, options);
    state.voyages.unshift(voyage);
  }
  state.currentVoyageId = voyage.id;
  state.tab = "liste";
  editingVoyageId = null;
  closeSheet("voyageSheet");
  saveAndSync(voyage, { immediate: true });
  render();
  refreshTripWeather(voyage.id);
  if (submit) {
    submit.disabled = false;
    submit.textContent = "Créer";
  }
}

function getVoyagePresetOptions(form) {
  return {
    transport: Array.from(form.querySelectorAll("input[name='transport']:checked")).map(input => input.value),
    lodging: Array.from(form.querySelectorAll("input[name='lodging']:checked")).map(input => input.value),
    activity: Array.from(form.querySelectorAll("input[name='activity']:checked")).map(input => input.value)
  };
}

function searchDestination(query) {
  selectedDestination = null;
  if (destinationSearchTimer) clearTimeout(destinationSearchTimer);
  const cleaned = query.trim();
  if (cleaned.length < 2) {
    renderDestinationSuggestions([]);
    return;
  }
  destinationSearchTimer = setTimeout(async () => {
    try {
      const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(cleaned)}&count=5&language=fr&format=json`;
      const response = await fetch(url);
      const data = await response.json();
      renderDestinationSuggestions(data.results || []);
    } catch (error) {
      renderDestinationSuggestions([]);
    }
  }, 280);
}

function showDestinationSuggestions() {
  const box = document.getElementById("destinationSuggestions");
  if (box && box.children.length) box.classList.add("open");
}

function renderDestinationSuggestions(results) {
  const box = document.getElementById("destinationSuggestions");
  if (!box) return;
  if (!results.length) {
    box.classList.remove("open");
    box.innerHTML = "";
    return;
  }
  box.innerHTML = results.map((result, index) => {
    const meta = [result.admin1, result.country].filter(Boolean).join(", ");
    return `
      <button class="suggestion" type="button" onclick="selectDestinationSuggestion(${index})">
        ${escapeHTML(result.name)}
        <span>${escapeHTML(meta)}</span>
      </button>
    `;
  }).join("");
  box._results = results;
  box.classList.add("open");
}

function selectDestinationSuggestion(index) {
  const box = document.getElementById("destinationSuggestions");
  const result = box?._results?.[index];
  if (!result) return;
  selectedDestination = {
    name: result.name,
    admin1: result.admin1 || "",
    country: result.country || "",
    latitude: result.latitude,
    longitude: result.longitude
  };
  const input = document.getElementById("voyageLocation");
  if (input) {
    input.value = [selectedDestination.name, selectedDestination.admin1, selectedDestination.country].filter(Boolean).join(", ");
  }
  renderDestinationSuggestions([]);
}

async function resolveDestination(place) {
  if (!place) return null;
  try {
    const url = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(place)}&count=1&language=fr&format=json`;
    const response = await fetch(url);
    const data = await response.json();
    const result = data.results?.[0];
    if (!result) return null;
    return {
      name: result.name,
      admin1: result.admin1 || "",
      country: result.country || "",
      latitude: result.latitude,
      longitude: result.longitude
    };
  } catch (error) {
    return null;
  }
}

async function fetchTripEnrichment(place, startDate, endDate, destination = null) {
  if (!place && !destination) return null;
  const enrichment = {
    place,
    weather: null,
    fetchedAt: new Date().toISOString()
  };
  try {
    let location = destination;
    if (!location) {
      const geoUrl = `https://geocoding-api.open-meteo.com/v1/search?name=${encodeURIComponent(place)}&count=1&language=fr&format=json`;
      const geoResponse = await fetch(geoUrl);
      const geoData = await geoResponse.json();
      location = geoData.results?.[0];
    }
    if (location) {
      enrichment.location = {
        name: location.name,
        admin1: location.admin1 || "",
        country: location.country,
        latitude: location.latitude,
        longitude: location.longitude
      };
      enrichment.weather = await fetchWeatherSummary(location.latitude, location.longitude, startDate, endDate);
    }
  } catch (error) {
    enrichment.weather = { summary: "Météo indisponible pour le moment." };
  }
  return enrichment;
}

async function fetchWeatherSummary(latitude, longitude, startDate, endDate) {
  if (!startDate) return { summary: "Ajoutez des dates pour obtenir une prévision météo." };
  const safeEndDate = endDate || startDate;
  const forecast = await fetchForecastWeather(latitude, longitude, startDate, safeEndDate);
  if (forecast) return forecast;
  return fetchClimateWeather(latitude, longitude, startDate, safeEndDate);
}

async function fetchForecastWeather(latitude, longitude, startDate, endDate) {
  const weatherUrl = `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&timezone=auto&start_date=${startDate}&end_date=${endDate}`;
  const response = await fetch(weatherUrl);
  if (!response.ok) return null;
  const data = await response.json();
  const days = data.daily?.time || [];
  if (!days.length) return null;
  const mins = data.daily.temperature_2m_min || [];
  const maxs = data.daily.temperature_2m_max || [];
  const rain = data.daily.precipitation_probability_max || [];
  const codes = data.daily.weather_code || [];
  const avgMin = Math.round(average(mins));
  const avgMax = Math.round(average(maxs));
  const maxRain = Math.max(...rain.filter(value => Number.isFinite(value)));
  const weatherLabel = weatherCodeLabel(mostFrequent(codes));
  return {
    type: "forecast",
    label: "Prévision météo",
    summary: `${weatherLabel}. Températures prévues autour de ${avgMin}°C à ${avgMax}°C. Risque de pluie max : ${Number.isFinite(maxRain) ? `${maxRain}%` : "n.c."}.`,
    days: days.length,
    avgMin,
    avgMax,
    rain: Number.isFinite(maxRain) ? maxRain : null
  };
}

async function fetchClimateWeather(latitude, longitude, startDate, endDate) {
  const climateUrl = `https://climate-api.open-meteo.com/v1/climate?latitude=${latitude}&longitude=${longitude}&start_date=${startDate}&end_date=${endDate}&models=EC_Earth3P_HR&daily=temperature_2m_max,temperature_2m_min,temperature_2m_mean,precipitation_sum,cloud_cover_mean,wind_speed_10m_mean&timezone=auto`;
  const response = await fetch(climateUrl);
  if (!response.ok) return { type: "climate", label: "Moyennes climatiques", summary: "Moyennes climatiques indisponibles pour ces dates." };
  const data = await response.json();
  const days = data.daily?.time || [];
  if (!days.length) return { type: "climate", label: "Moyennes climatiques", summary: "Moyennes climatiques indisponibles pour ces dates." };
  const min = Math.round(average(data.daily.temperature_2m_min || []));
  const max = Math.round(average(data.daily.temperature_2m_max || []));
  const mean = Math.round(average(data.daily.temperature_2m_mean || []));
  const rain = sum(data.daily.precipitation_sum || []);
  const clouds = Math.round(average(data.daily.cloud_cover_mean || []));
  const wind = Math.round(average(data.daily.wind_speed_10m_mean || []));
  return {
    type: "climate",
    label: "Moyennes climatiques",
    summary: `Climat attendu autour de ${min}°C à ${max}°C, moyenne ${mean}°C. Cumul de pluie moyen : ${rain.toFixed(1)} mm sur la période. Nuages ${clouds}% et vent ${wind} km/h en moyenne.`,
    days: days.length,
    avgMin: min,
    avgMax: max,
    avgMean: mean,
    rain: Number(rain.toFixed(1)),
    clouds,
    wind
  };
}

async function fetchTourismSummary(place) {
  const searchUrl = `https://fr.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=${encodeURIComponent(`${place} tourisme`)}&gsrlimit=1&prop=extracts&exintro=1&explaintext=1&format=json&origin=*`;
  const response = await fetch(searchUrl);
  const data = await response.json();
  const pages = data.query?.pages ? Object.values(data.query.pages) : [];
  const page = pages[0];
  if (!page) return { title: place, summary: "Aucune fiche touristique trouvée." };
  const extract = (page.extract || "").replace(/\s+/g, " ").trim();
  return {
    title: page.title,
    summary: extract ? truncateText(extract, 260) : "Aucune synthèse touristique disponible."
  };
}

function average(values) {
  const clean = values.filter(value => Number.isFinite(value));
  if (!clean.length) return 0;
  return clean.reduce((sum, value) => sum + value, 0) / clean.length;
}

function sum(values) {
  return values.filter(value => Number.isFinite(value)).reduce((total, value) => total + value, 0);
}

function mostFrequent(values) {
  const counts = new Map();
  values.forEach(value => counts.set(value, (counts.get(value) || 0) + 1));
  return Array.from(counts.entries()).sort((a, b) => b[1] - a[1])[0]?.[0] || 0;
}

function weatherCodeLabel(code) {
  if ([0, 1].includes(code)) return "Temps plutôt dégagé";
  if ([2, 3].includes(code)) return "Temps variable";
  if ([45, 48].includes(code)) return "Brouillard possible";
  if ([51, 53, 55, 56, 57].includes(code)) return "Bruine possible";
  if ([61, 63, 65, 66, 67, 80, 81, 82].includes(code)) return "Pluie possible";
  if ([71, 73, 75, 77, 85, 86].includes(code)) return "Neige possible";
  if ([95, 96, 99].includes(code)) return "Orages possibles";
  return "Météo variable";
}

function truncateText(text, maxLength) {
  if (text.length <= maxLength) return text;
  return `${text.slice(0, maxLength - 1).trim()}…`;
}

function destinationCountry(voyage) {
  return voyage.destination?.country || voyage.enrichment?.location?.country || "";
}

function destinationSearchLabel(voyage) {
  const destination = voyage.destination || voyage.enrichment?.location || null;
  if (!destination) return voyage.name;
  return [destination.name, destination.admin1, destination.country].filter(Boolean).join(" ");
}

function weatherUrl(voyage) {
  const query = ["météo", destinationSearchLabel(voyage), voyage.startDate || "", voyage.endDate || ""]
    .filter(Boolean)
    .join(" ");
  return `https://www.google.com/search?q=${encodeURIComponent(query)}`;
}

function renderDestinationLink(voyage) {
  const country = destinationCountry(voyage);
  if (!country) return "";
  return `<button class="badge blue" type="button" onclick="event.stopPropagation(); refreshTripWeather('${voyage.id}', true)" title="Actualiser la météo">${escapeHTML(country)}</button>`;
}

function weatherCacheKey(voyage) {
  const destination = voyage.destination || voyage.enrichment?.location || {};
  return [destination.latitude, destination.longitude, voyage.startDate || "", voyage.endDate || ""].join("|");
}

function needsWeatherRefresh(voyage) {
  if (!voyage?.destination?.latitude || !voyage?.destination?.longitude || !voyage.startDate) return false;
  return voyage.enrichment?.weatherKey !== weatherCacheKey(voyage);
}

function ensureTripWeather(voyage) {
  if (!needsWeatherRefresh(voyage) || weatherFetchIds.has(voyage.id)) return;
  refreshTripWeather(voyage.id);
}

async function refreshTripWeather(voyageId, notify = false) {
  const voyage = state.voyages.find(item => item.id === voyageId);
  if (!voyage || weatherFetchIds.has(voyage.id)) return;
  const destination = voyage.destination || voyage.enrichment?.location || null;
  if (!destination?.latitude || !destination?.longitude || !voyage.startDate) {
    if (notify) showToast("Destination ou dates manquantes");
    return;
  }
  weatherFetchIds.add(voyage.id);
  try {
    const place = destinationSearchLabel(voyage);
    const enrichment = await fetchTripEnrichment(place, voyage.startDate, voyage.endDate, destination);
    voyage.enrichment = {
      ...(voyage.enrichment || {}),
      ...(enrichment || {}),
      weatherKey: weatherCacheKey(voyage)
    };
    touchVoyage(voyage);
    saveAndSync(voyage);
    if (notify) showToast("Météo actualisée");
    render();
  } catch (error) {
    console.warn("Météo Open-Meteo indisponible", error);
    if (notify) showToast("Météo indisponible");
  } finally {
    weatherFetchIds.delete(voyage.id);
  }
}

function renderWeatherPanel(voyage) {
  const destination = voyage.destination || voyage.enrichment?.location || null;
  if (!destination?.latitude || !destination?.longitude) return "";
  if (!voyage.startDate) return "";
  const weather = voyage.enrichment?.weather;
  if (!weather) {
    return `
      <section class="info-card weather-card section">
        <h3>Météo</h3>
        <p>Chargement des données Open-Meteo...</p>
      </section>
    `;
  }
  return `
    <section class="info-card weather-card section">
      <h3>${escapeHTML(weather.label || "Météo")}</h3>
      <p>${escapeHTML(weather.summary || "Météo indisponible pour le moment.")}</p>
      <p class="muted">${weather.type === "climate" ? "Estimation climatique Open-Meteo, utile quand les prévisions ne couvrent pas encore les dates du voyage." : "Prévision Open-Meteo pour les dates du voyage."}</p>
    </section>
  `;
}

function resetDraftDateRange() {
  draftDateRange = { start: "", end: "", next: "start" };
  const status = document.getElementById("voyageRangeStatus");
  draftCalendarMonth = new Date();
  draftCalendarMonth.setDate(1);
  if (status) status.textContent = "Choisissez la date de départ, puis la date de retour.";
  renderRangeCalendar();
}

function changeCalendarMonth(delta) {
  draftCalendarMonth.setMonth(draftCalendarMonth.getMonth() + delta);
  renderRangeCalendar();
}

function pickCalendarDate(value) {
  if (draftDateRange.next === "start" || (draftDateRange.start && draftDateRange.end)) {
    draftDateRange = { start: value, end: "", next: "end" };
  } else {
    draftDateRange.end = value;
    if (draftDateRange.end < draftDateRange.start) {
      const previousStart = draftDateRange.start;
      draftDateRange.start = draftDateRange.end;
      draftDateRange.end = previousStart;
    }
    draftDateRange.next = "start";
  }
  const status = document.getElementById("voyageRangeStatus");
  if (status) {
    const label = formatDateRange(draftDateRange.start, draftDateRange.end);
    status.textContent = draftDateRange.end ? label : `${label} - choisissez la date de retour`;
  }
  renderRangeCalendar();
}

function renderRangeCalendar() {
  const calendar = document.getElementById("rangeCalendar");
  if (!calendar) return;
  const year = draftCalendarMonth.getFullYear();
  const month = draftCalendarMonth.getMonth();
  const firstDay = new Date(year, month, 1);
  const startOffset = (firstDay.getDay() + 6) % 7;
  const gridStart = new Date(year, month, 1 - startOffset);
  const monthLabel = new Intl.DateTimeFormat("fr-FR", { month: "long", year: "numeric" }).format(firstDay);
  const weekdays = ["L", "M", "M", "J", "V", "S", "D"];
  const days = [];
  for (let index = 0; index < 42; index += 1) {
    const day = new Date(gridStart);
    day.setDate(gridStart.getDate() + index);
    const value = toDateValue(day);
    const inMonth = day.getMonth() === month;
    const selected = value === draftDateRange.start || value === draftDateRange.end;
    const inRange = draftDateRange.start && draftDateRange.end && value > draftDateRange.start && value < draftDateRange.end;
    days.push(`
      <button class="calendar-day ${inMonth ? "" : "muted"} ${inRange ? "in-range" : ""} ${selected ? "selected" : ""}" type="button" onclick="pickCalendarDate('${value}')">
        ${day.getDate()}
      </button>
    `);
  }
  calendar.innerHTML = `
    <div class="calendar-head">
      <button class="mini" type="button" onclick="changeCalendarMonth(-1)" title="Mois précédent">‹</button>
      <div class="calendar-title">${escapeHTML(monthLabel)}</div>
      <button class="mini" type="button" onclick="changeCalendarMonth(1)" title="Mois suivant">›</button>
    </div>
    <div class="calendar-grid">
      ${weekdays.map(day => `<div class="calendar-weekday">${day}</div>`).join("")}
      ${days.join("")}
    </div>
  `;
}

function toDateValue(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function formatDateRange(start, end) {
  const format = value => {
    if (!value) return "";
    const [year, month, day] = value.split("-");
    return `${day}/${month}/${year}`;
  };
  const startLabel = format(start);
  const endLabel = format(end);
  if (startLabel && endLabel) return startLabel === endLabel ? startLabel : `${startLabel} - ${endLabel}`;
  return startLabel || endLabel || "";
}

function formatTripDateLine(voyage) {
  if (!voyage.startDate) return voyage.date || "";
  const start = parseDateParts(voyage.startDate);
  const end = parseDateParts(voyage.endDate || voyage.startDate);
  if (!start || !end) return voyage.date || "";
  if (start.raw === end.raw) return `le ${start.day}/${start.month}/${start.shortYear}`;
  if (start.year === end.year && start.month === end.month) {
    return `du ${start.day} au ${end.day}/${end.month}/${end.shortYear}`;
  }
  return `du ${start.day}/${start.month} au ${end.day}/${end.month}/${end.shortYear}`;
}

function tripDurationLabel(voyage) {
  if (!voyage.startDate) return "";
  const start = new Date(`${voyage.startDate}T00:00:00`);
  const end = new Date(`${voyage.endDate || voyage.startDate}T00:00:00`);
  if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime())) return "";
  const nights = Math.round((end - start) / 86400000);
  if (nights < 0) return "";
  return `${nights + 1}j${nights}n`;
}

function daysUntilTrip(voyage) {
  if (!voyage.startDate) return "";
  const start = new Date(`${voyage.startDate}T00:00:00`);
  if (Number.isNaN(start.getTime())) return "";
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const diff = Math.ceil((start - today) / 86400000);
  if (diff > 1) return `J-${diff}`;
  if (diff === 1) return "Demain";
  if (diff === 0) return "Aujourd'hui";
  return "";
}

function parseDateParts(value) {
  const parts = String(value || "").split("-");
  if (parts.length !== 3) return null;
  const [year, month, day] = parts;
  return {
    raw: value,
    year,
    month,
    day,
    shortYear: year.slice(-2)
  };
}

function selectVoyage(id) {
  state.currentVoyageId = id;
  state.tab = "liste";
  const voyage = currentVoyage();
  closeVoyageCategoryPanels(voyage);
  saveLocal();
  render();
  subscribeToCurrentVoyage();
}

function renameVoyage(id) {
  const voyage = state.voyages.find(item => item.id === id);
  if (!voyage) return;
  const value = prompt("Nouveau nom du voyage", voyage.name);
  if (value === null) return;
  const next = value.trim();
  if (!next) return;
  voyage.name = next;
  touchVoyage(voyage);
  saveAndSync(voyage);
  render();
}

function renameCurrentVoyage() {
  const voyage = currentVoyage();
  if (voyage) renameVoyage(voyage.id);
}

async function deleteVoyage(id) {
  const voyage = state.voyages.find(item => item.id === id);
  if (!voyage) return;
  if (!confirm(`Supprimer le voyage "${voyage.name}" de l'application et de la base de données ?`)) return;
  try {
    const client = getPB();
    if (client && voyage.code) {
      let recordId = voyage.remoteRecordId;
      if (!recordId) {
        const record = await findRecordByCode(voyage.code);
        recordId = record?.id;
      }
      if (recordId) await client.collection(PB_COLLECTION).delete(recordId, { requestKey: null });
    }
  } catch (error) {
    console.warn("Suppression distante impossible", error);
    alert("Impossible de supprimer ce voyage dans la base de données pour le moment. Réessaie quand la connexion est disponible.");
    return;
  }
  state.voyages = state.voyages.filter(item => item.id !== id);
  if (state.currentVoyageId === id) state.currentVoyageId = state.voyages[0]?.id || null;
  saveLocal();
  render();
  subscribeToCurrentVoyage();
}

function resetVoyageLists(id) {
  const voyage = state.voyages.find(item => item.id === id);
  if (!voyage) return;
  if (!confirm(`Tout décocher dans "${voyage.name}" ?`)) return;
  allVoyageCategories(voyage).forEach(category => {
    visibleItems(category.items || []).forEach(item => {
      const timestamp = nowISO();
      item.done = false;
      item.status = "todo";
      touchEntity(item, timestamp);
    });
    touchEntity(category);
    sortCategoryItems(category);
  });
  touchVoyage(voyage);
  saveAndSync(voyage);
  render();
}

function addMember() {
  openMemberSheet();
}

function createMemberFromName(name, selectedTemplates = [], group = "family") {
  const voyage = currentVoyage();
  if (!voyage || !name) return;
  const categories = selectedTemplates
    .map(templateId => visibleCustomCategories(state.customCategories).find(category => category.id === templateId))
    .filter(Boolean)
    .map(cloneTemplateCategory);
  if (normalizeMemberGroup(group) === "general" && normalizeMemberName(name) === "Général") {
    voyage.categories = Array.isArray(voyage.categories) ? voyage.categories : [];
    voyage.categories.push(...categories);
    state.openMembers.general = true;
    categories.forEach(category => {
      state.openCats[category.id] = false;
    });
    touchVoyage(voyage);
    saveAndSync(voyage);
    render();
    return;
  }
  const member = createMember(name, categories, { group });
  voyage.members.push(member);
  state.openMembers[member.id] = false;
  categories.forEach(category => {
    state.openCats[category.id] = false;
  });
  touchVoyage(voyage);
  saveAndSync(voyage);
  render();
}

function addCategoryToMember(memberId, templateId = "") {
  const voyage = currentVoyage();
  const member = voyageMembers(voyage).find(item => item.id === memberId);
  if (!voyage || !member) return;
  let category = null;
  const timestamp = nowISO();
  const template = templateId ? visibleCustomCategories(state.customCategories).find(item => item.id === templateId) : null;
  if (template) {
    category = {
      id: uid("cat"),
      name: template.name,
      icon: categoryIcon(template),
      updatedAt: timestamp,
      deletedAt: "",
      items: visibleCustomItems(template.items || []).map(item => ({ id: uid("item"), name: customItemName(item), qty: normalizeQty(item.qty || 1), status: "todo", done: false, updatedAt: timestamp, deletedAt: "" }))
    };
  } else {
    const value = prompt("Nom de la catégorie");
    if (value === null) return;
    const name = value.trim();
    if (!name) return;
    category = { id: uid("cat"), name, icon: categoryIconForName(name), updatedAt: timestamp, deletedAt: "", items: [] };
  }
  member.categories.push(category);
  state.openMembers[member.id] = true;
  state.openCats[category.id] = false;
  touchEntity(member);
  touchVoyage(voyage);
  saveAndSync(voyage);
  render();
}

function addCategoryToGeneral() {
  const voyage = currentVoyage();
  if (!voyage) return;
  const value = prompt("Nom de la catégorie");
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  const timestamp = nowISO();
  const category = { id: uid("cat"), name, icon: categoryIconForName(name), updatedAt: timestamp, deletedAt: "", items: [] };
  voyage.categories = Array.isArray(voyage.categories) ? voyage.categories : [];
  voyage.categories.push(category);
  state.openMembers.general = true;
  state.openCats[category.id] = false;
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function openMemberSheet() {
  const groupSelect = document.getElementById("memberListGroup");
  if (groupSelect) groupSelect.value = "family";
  renderMemberTemplateGroups();
  document.getElementById("categorySheet").classList.add("open");
  setTimeout(() => groupSelect?.focus(), 50);
}

function saveMemberSheet(event) {
  event.preventDefault();
  const group = normalizeMemberGroup(document.getElementById("memberListGroup")?.value);
  const name = normalizeMemberName(document.getElementById("memberTemplateGroup")?.value);
  if (!name) return;
  const selectedTemplates = [...event.currentTarget.querySelectorAll("input[name='memberTemplate']:checked")]
    .map(item => item.value);
  createMemberFromName(name, selectedTemplates, group);
  closeSheet("categorySheet");
}

function templateMemberNames(group = "family") {
  return customMemberNames()
    .filter(name => name !== "Général")
    .filter(name => visibleCustomCategories(state.customCategories).some(category => defaultMemberForCategory(category) === name));
}

function renderMemberTemplateGroups(selectedMember = "") {
  const select = document.getElementById("memberTemplateGroup");
  const group = normalizeMemberGroup(document.getElementById("memberListGroup")?.value);
  const members = customMemberNames()
    .filter(name => group === "general" || normalizeMemberName(name) !== "Général")
    .filter(name => visibleCustomCategories(state.customCategories).some(category => defaultMemberForCategory(category) === name));
  if (!select) return;
  if (!members.length) {
    select.innerHTML = `<option value="">Aucun membre disponible</option>`;
    select.disabled = true;
    renderCategoryTemplateChoices("");
    return;
  }
  select.disabled = false;
  const active = members.includes(selectedMember) ? selectedMember : members[0];
  select.innerHTML = members.map(member => `<option value="${escapeHTML(member)}" ${member === active ? "selected" : ""}>${escapeHTML(member)}</option>`).join("");
  selectMemberTemplateGroup(active);
}

function selectMemberTemplateGroup(memberName) {
  const name = normalizeMemberName(memberName);
  renderCategoryTemplateChoices(name);
}

function renderCategoryTemplateChoices(memberName = "") {
  const target = document.getElementById("categoryTemplateChoices");
  if (!target) return;
  const availableCategories = visibleCustomCategories(state.customCategories);
  if (!availableCategories.length) {
    target.innerHTML = `<div class="notice">Aucune catégorie personnalisée pour le moment.</div>`;
    return;
  }
  const categories = availableCategories.filter(category => defaultMemberForCategory(category) === memberName);
  if (!memberName || !categories.length) {
    target.innerHTML = `<div class="notice">Aucune catégorie personnalisée pour ce membre.</div>`;
    return;
  }
  target.innerHTML = `
    <div class="muted">Sélectionner les catégories à importer</div>
    <div class="template-picks">
      ${categories.map(category => `
        <label class="template-chip"><input type="checkbox" name="memberTemplate" value="${category.id}"> ${escapeHTML(category.name)}</label>
      `).join("")}
    </div>
  `;
}

function renameCategory(categoryId) {
  const voyage = currentVoyage();
  const { member, category } = findCategoryInVoyage(voyage, categoryId);
  if (!category) return;
  const value = prompt("Nouveau nom de la catégorie", category.name);
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  category.name = name;
  if (!category.icon) category.icon = categoryIconForName(name);
  const timestamp = touchEntity(category);
  if (member) touchEntity(member, timestamp);
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function deleteCategory(categoryId) {
  const voyage = currentVoyage();
  const { member, category } = findCategoryInVoyage(voyage, categoryId);
  if (!voyage || !category) return;
  if (!confirm(`Supprimer la catégorie "${category.name}" ?`)) return;
  const timestamp = nowISO();
  category.deletedAt = timestamp;
  touchEntity(category, timestamp);
  visibleItems(category.items || []).forEach(item => {
    item.deletedAt = timestamp;
    touchEntity(item, timestamp);
  });
  if (member) touchEntity(member, timestamp);
  delete state.openCats[categoryId];
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function toggleMember(memberId) {
  state.openMembers[memberId] = !state.openMembers[memberId];
  saveLocal();
  render();
}

function renameMember(memberId) {
  const voyage = currentVoyage();
  const member = voyageMembers(voyage).find(item => item.id === memberId);
  if (!voyage || !member) return;
  const value = prompt("Nouveau nom du membre", member.name);
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  member.name = name;
  const timestamp = touchEntity(member);
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function deleteMember(memberId) {
  const voyage = currentVoyage();
  const member = voyageMembers(voyage).find(item => item.id === memberId);
  if (!voyage || !member) return;
  if (!confirm(`Supprimer le membre "${member.name}" ?`)) return;
  const timestamp = nowISO();
  member.deletedAt = timestamp;
  touchEntity(member, timestamp);
  delete state.openMembers[memberId];
  visibleCategories(member.categories || []).forEach(category => {
    category.deletedAt = timestamp;
    touchEntity(category, timestamp);
    visibleItems(category.items || []).forEach(item => {
      item.deletedAt = timestamp;
      touchEntity(item, timestamp);
    });
    delete state.openCats[category.id];
  });
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function toggleCategory(categoryId) {
  state.openCats[categoryId] = !state.openCats[categoryId];
  saveLocal();
  render();
}

function addItem(event, categoryId) {
  event.preventDefault();
  const voyage = currentVoyage();
  const { category } = findCategoryInVoyage(voyage, categoryId);
  if (!voyage || !category) return;
  const input = event.currentTarget.querySelector("input");
  const name = input.value.trim();
  if (!name) return;
  const timestamp = nowISO();
  category.items.push({ id: uid("item"), name, qty: 1, status: "todo", done: false, updatedAt: timestamp, deletedAt: "" });
  touchEntity(category, timestamp);
  sortCategoryItems(category);
  input.value = "";
  state.openCats[categoryId] = true;
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function toggleItem(categoryId, itemId) {
  const voyage = currentVoyage();
  const { category } = findCategoryInVoyage(voyage, categoryId);
  const item = category?.items.find(row => row.id === itemId);
  if (!voyage || !category || !item) return;
  item.status = item.status === "todo" ? "checked" : item.status === "checked" ? "done" : "todo";
  item.done = item.status === "done";
  const timestamp = touchEntity(item);
  touchEntity(category, timestamp);
  sortCategoryItems(category);
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function renameItem(categoryId, itemId) {
  const voyage = currentVoyage();
  const { category } = findCategoryInVoyage(voyage, categoryId);
  const item = category?.items
    .find(row => row.id === itemId);
  if (!voyage || !item) return;
  const value = prompt("Renommer l'élément", item.name);
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  item.name = name;
  const timestamp = touchEntity(item);
  touchEntity(category, timestamp);
  sortCategoryItems(category);
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function deleteItem(categoryId, itemId) {
  const voyage = currentVoyage();
  const { category } = findCategoryInVoyage(voyage, categoryId);
  if (!voyage || !category) return;
  const item = category.items.find(row => row.id === itemId);
  if (!item) return;
  const timestamp = nowISO();
  item.deletedAt = timestamp;
  touchEntity(item, timestamp);
  touchEntity(category, timestamp);
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function toggleQtyEditor(itemId) {
  qtyEditorItemId = qtyEditorItemId === itemId ? null : itemId;
  render();
}

function openQtyEditorFromPill(type, categoryId, itemId) {
  const voyage = currentVoyage();
  const voyageItem = type === "voyage"
    ? findCategoryInVoyage(voyage, categoryId)?.category?.items.find(row => row.id === itemId)
    : null;
  const quickItem = type === "quick"
    ? currentQuickList()?.items.find(row => row.id === itemId)
    : null;
  const customItem = type === "custom"
    ? state.customCategories.find(category => category.id === categoryId)?.items.find(row => row.id === itemId)
    : null;
  const item = voyageItem || quickItem || customItem;
  if (!item) return;
  qtyEditorItemId = itemId;
  if (normalizeQty(item.qty || 1) > 1) {
    render();
    return;
  }
  if (type === "voyage") changeQty(categoryId, itemId, 1);
  else if (type === "quick") changeQuickQty(itemId, 1);
  else if (type === "custom") changeCustomQty(categoryId, itemId, 1);
}

function closeQtyEditorFromLabel(itemId) {
  if (qtyEditorItemId !== itemId) return;
  qtyEditorItemId = null;
  render();
}

function changeQty(categoryId, itemId, deltaOrValue) {
  const voyage = currentVoyage();
  const { category } = findCategoryInVoyage(voyage, categoryId);
  const item = category?.items
    .find(row => row.id === itemId);
  if (!voyage || !item) return;
  if (typeof deltaOrValue === "number") {
    item.qty = normalizeQty(item.qty + deltaOrValue);
  } else {
    item.qty = normalizeQty(deltaOrValue);
  }
  const timestamp = touchEntity(item);
  touchEntity(category, timestamp);
  touchVoyage(voyage, timestamp);
  saveAndSync(voyage);
  render();
}

function startItemSwipe(event, itemId) {
  if (event.target.closest("input")) return;
  swipeStartX = event.clientX;
  swipeStartY = event.clientY;
}

function endItemSwipe(event, itemId) {
  const deltaX = event.clientX - swipeStartX;
  const deltaY = Math.abs(event.clientY - swipeStartY);
  if (deltaX < -45 && deltaY < 35) {
    activeSwipeItemId = itemId;
    render();
  } else if (deltaX > 35 && activeSwipeItemId === itemId) {
    activeSwipeItemId = null;
    render();
  }
}

function saveAndSync(voyage, options = {}) {
  saveLocal();
  if (syncTimer) clearTimeout(syncTimer);
  const delay = options.immediate ? 0 : 550;
  syncTimer = setTimeout(() => saveVoyageRemote(voyage), delay);
}

async function findRecordByCode(code) {
  const client = getPB();
  if (!client) throw new Error("PocketBase indisponible");
  return client.collection(PB_COLLECTION).getFirstListItem(`code = "${cleanCode(code)}"`, {
    requestKey: null
  });
}

function settingsPayload() {
  const syncedState = syncedSettingsState();
  const categories = visibleCustomCategories(syncedState.customCategories).map(category => ({
    id: category.id,
    name: category.name,
    icon: categoryIcon(category),
    member: defaultMemberForCategory(category),
    updatedAt: category.updatedAt || "",
    deletedAt: category.deletedAt || "",
    items: visibleCustomItems(category.items || []).map(item => ({
      id: item.id,
      name: customItemName(item),
      qty: normalizeQty(item.qty || 1),
      done: false,
      updatedAt: item.updatedAt || "",
      deletedAt: item.deletedAt || ""
    }))
  }));
  return {
    type: "settings",
    customCategories: syncedState.customCategories,
    customCategoryMembers: syncedState.customCategoryMembers,
    customMemberAliases: state.customMemberAliases,
    customMemberGroups: syncedState.customMemberGroups,
    customMemberDeletedAt: syncedState.customMemberDeletedAt,
    voyage: {
      id: "settings-voyage",
      code: SETTINGS_CODE,
      name: "Paramètres",
      hidden: true,
      categories,
      updatedAt: new Date().toISOString()
    },
    updatedAt: new Date().toISOString()
  };
}

function applySettingsData(data) {
  const personal = personalSettingsSnapshot();
  const merged = mergeSettingsData(settingsPayload(), data);
  const syncedCategories = Array.isArray(merged.customCategories) ? merged.customCategories.map(normalizeCustomCategory) : [];
  const syncedMembers = Array.isArray(merged.customCategoryMembers) ? merged.customCategoryMembers.map(normalizeMemberName) : [];
  state.customCategories = [...personal.customCategories, ...syncedCategories];
  state.customCategoryMembers = [...personal.customCategoryMembers, ...syncedMembers]
    .map(normalizeMemberName)
    .filter((name, index, list) => list.indexOf(name) === index);
  state.customMemberAliases = merged.customMemberAliases && typeof merged.customMemberAliases === "object" ? merged.customMemberAliases : state.customMemberAliases;
  state.customMemberGroups = {
    ...(merged.customMemberGroups && typeof merged.customMemberGroups === "object" ? merged.customMemberGroups : {}),
    ...personal.customMemberGroups
  };
  state.customMemberDeletedAt = {
    ...(merged.customMemberDeletedAt && typeof merged.customMemberDeletedAt === "object" ? merged.customMemberDeletedAt : {}),
    ...personal.customMemberDeletedAt
  };
  saveLocal();
  if (state.tab === "customCategories") render();
  renderMemberTemplateGroups(document.getElementById("memberTemplateGroup")?.value || "");
  renderVoyageParticipantPicker();
}

async function loadSharedSettings() {
  const client = getPB();
  if (!client) return;
  try {
    const record = await findRecordByCode(SETTINGS_CODE);
    settingsRecordId = record.id;
    if (record?.data) applySettingsData(record.data);
    await subscribeToSharedSettings();
  } catch (error) {
    console.warn("Paramètres partagés indisponibles", error);
  }
}

async function saveSharedSettings() {
  saveLocal();
  const client = getPB();
  if (!client) return;
  try {
    let record = null;
    if (settingsRecordId) {
      try {
        record = await client.collection(PB_COLLECTION).getOne(settingsRecordId, { requestKey: null });
      } catch (error) {
        record = null;
      }
    }
    if (!record) {
      try {
        record = await findRecordByCode(SETTINGS_CODE);
      } catch (error) {
        record = null;
      }
    }
    let data = settingsPayload();
    if (record?.data) {
      const personal = personalSettingsSnapshot();
      data = mergeSettingsData(data, record.data);
      state.customCategories = [...personal.customCategories, ...data.customCategories.map(normalizeCustomCategory)];
      state.customCategoryMembers = [...personal.customCategoryMembers, ...data.customCategoryMembers.map(normalizeMemberName)]
        .map(normalizeMemberName)
        .filter((name, index, list) => list.indexOf(name) === index);
      state.customMemberAliases = data.customMemberAliases || {};
      state.customMemberGroups = { ...(data.customMemberGroups || {}), ...personal.customMemberGroups };
      state.customMemberDeletedAt = { ...(data.customMemberDeletedAt || {}), ...personal.customMemberDeletedAt };
    }
    if (record) {
      record = await client.collection(PB_COLLECTION).update(record.id, { code: SETTINGS_CODE, data }, { requestKey: null });
    } else {
      record = await client.collection(PB_COLLECTION).create({ code: SETTINGS_CODE, data }, { requestKey: null });
    }
    settingsRecordId = record.id;
    saveLocal();
    await subscribeToSharedSettings();
  } catch (error) {
    console.warn("Sauvegarde des paramètres impossible", error);
  }
}

async function subscribeToSharedSettings() {
  const client = getPB();
  if (!client) return;
  if (unsubscribeSettings) {
    try {
      unsubscribeSettings();
    } catch (error) {
      console.warn("Désabonnement paramètres impossible", error);
    }
    unsubscribeSettings = null;
  }
  try {
    let record = null;
    if (settingsRecordId) {
      record = await client.collection(PB_COLLECTION).getOne(settingsRecordId, { requestKey: null });
    } else {
      record = await findRecordByCode(SETTINGS_CODE);
    }
    settingsRecordId = record.id;
    saveLocal();
    unsubscribeSettings = await client.collection(PB_COLLECTION).subscribe(record.id, event => {
      if (event.action !== "update" || !event.record?.data) return;
      applySettingsData(event.record.data);
    }, { requestKey: null });
  } catch (error) {
    console.warn("Abonnement paramètres impossible", error);
  }
}

function remotePayload(voyage) {
  return {
    ...voyage,
    shared: true,
    updatedAt: voyage.updatedAt || nowISO()
  };
}

async function saveVoyageRemote(voyage) {
  if (!voyage) return;
  const client = getPB();
  if (!client) {
    setStatus("Hors ligne");
    return;
  }
  try {
    setStatus("Synchronisation...");
    let record = null;
    if (voyage.remoteRecordId) {
      try {
        record = await client.collection(PB_COLLECTION).getOne(voyage.remoteRecordId, { requestKey: null });
      } catch (error) {
        record = null;
      }
    }
    if (!record) {
      try {
        record = await findRecordByCode(voyage.code);
      } catch (error) {
        record = null;
      }
    }

    let data = remotePayload(voyage);
    if (record?.data) {
      const remoteData = normalizeVoyage({
        ...(record.data.voyage || record.data),
        shared: true,
        remoteRecordId: record.id
      });
      data = remotePayload(mergeVoyages(voyage, remoteData));
    }

    if (record) {
      record = await client.collection(PB_COLLECTION).update(record.id, {
        code: data.code,
        data
      }, { requestKey: null });
    } else {
      record = await client.collection(PB_COLLECTION).create({
        code: data.code,
        data
      }, { requestKey: null });
    }

    const synced = normalizeVoyage({ ...data, remoteRecordId: record.id, shared: true });
    Object.assign(voyage, synced, { id: voyage.id });
    saveLocal();
    setStatus("Synchronis\u00e9");
    subscribeToCurrentVoyage();
  } catch (error) {
    console.warn("Synchronisation impossible", error);
    setStatus("Hors ligne");
  }
}
function syncAllVoyages(options = {}) {
  state.voyages
    .filter(voyage => voyage?.code && voyage.code !== SETTINGS_CODE)
    .forEach((voyage, index) => {
      setTimeout(() => saveVoyageRemote(voyage), options.immediate ? 0 : index * 250);
    });
}

function quickListPayload(list) {
  return {
    ...list,
    type: "quickList",
    shared: true,
    items: list.items || [],
    updatedAt: list.updatedAt || new Date().toISOString()
  };
}

async function saveQuickListRemote(list) {
  if (!list) return;
  const client = getPB();
  if (!client) {
    setStatus("Hors ligne");
    return;
  }
  try {
    setStatus("Synchronisation...");
    let record = null;
    if (list.remoteRecordId) {
      try {
        record = await client.collection(PB_COLLECTION).getOne(list.remoteRecordId, { requestKey: null });
      } catch (error) {
        record = null;
      }
    }
    if (!record) {
      try {
        record = await findRecordByCode(list.code);
      } catch (error) {
        record = null;
      }
    }
    let data = quickListPayload(list);
    if (record?.data) {
      const remoteData = record.data.quickList || record.data;
      const remoteList = normalizeQuickList({
        ...remoteData,
        shared: true,
        remoteRecordId: record.id
      });
      data = quickListPayload(mergeQuickLists(list, remoteList));
    }
    if (record) {
      record = await client.collection(PB_COLLECTION).update(record.id, { code: data.code, data }, { requestKey: null });
    } else {
      record = await client.collection(PB_COLLECTION).create({ code: data.code, data }, { requestKey: null });
    }
    const synced = normalizeQuickList({ ...data, remoteRecordId: record.id, shared: true });
    Object.assign(list, synced, { id: list.id });
    saveLocal();
    setStatus("Synchronisé");
    subscribeToCurrentQuickList();
  } catch (error) {
    console.warn("Synchronisation liste rapide impossible", error);
    setStatus("Hors ligne");
  }
}

function saveQuickListAndSync(list, options = {}) {
  saveLocal();
  const delay = options.immediate ? 0 : 550;
  setTimeout(() => saveQuickListRemote(list), delay);
}

function syncAllQuickLists(options = {}) {
  dedupeQuickLists();
  saveLocal();
  state.quickLists
    .filter(list => list?.code)
    .forEach((list, index) => {
      setTimeout(() => saveQuickListRemote(list), options.immediate ? 0 : index * 250);
    });
}

function applyRemoteQuickList(incoming) {
  const incomingKey = quickListKey(incoming);
  const index = state.quickLists.findIndex(item => item.code === incoming.code || item.id === incoming.id || quickListKey(item) === incomingKey);
  if (index >= 0) {
    state.quickLists[index] = mergeQuickLists(state.quickLists[index], incoming);
  } else {
    state.quickLists.unshift(incoming);
  }
  dedupeQuickLists();
  saveLocal();
  if (!isUserEditing()) render();
}

async function subscribeToCurrentQuickList() {
  const list = currentQuickList();
  const client = getPB();
  if (unsubscribeQuickList) {
    try {
      unsubscribeQuickList();
    } catch (error) {
      console.warn("Désabonnement liste rapide impossible", error);
    }
    unsubscribeQuickList = null;
  }
  if (!client || !list?.code || state.tab !== "quickListDetail") return;
  try {
    let record = null;
    if (list.remoteRecordId) {
      try {
        record = await client.collection(PB_COLLECTION).getOne(list.remoteRecordId, { requestKey: null });
      } catch (error) {
        record = null;
      }
    }
    if (!record) record = await findRecordByCode(list.code);
    list.shared = true;
    list.remoteRecordId = record.id;
    saveLocal();
    unsubscribeQuickList = await client.collection(PB_COLLECTION).subscribe(record.id, event => {
      if (event.action !== "update" || !event.record?.data) return;
      const incoming = normalizeQuickList({
        ...(event.record.data.quickList || event.record.data),
        shared: true,
        remoteRecordId: event.record.id
      });
      applyRemoteQuickList(incoming);
    }, { requestKey: null });
  } catch (error) {
    setStatus(list.shared ? "Synchronisé" : "Hors ligne");
  }
}

function createQuickList() {
  const value = prompt("Nom de la liste rapide", "Sac de piscine");
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  const existing = state.quickLists.find(list => quickListKey(list) === normalizeText(name));
  if (existing) {
    state.currentQuickListId = existing.id;
    state.tab = "quickListDetail";
    saveLocal();
    render();
    return;
  }
  const list = normalizeQuickList({ name, items: [] });
  state.quickLists.unshift(list);
  state.currentQuickListId = list.id;
  state.tab = "quickListDetail";
  saveLocal();
  render();
  saveQuickListRemote(list);
}

async function joinQuickList(event) {
  event.preventDefault();
  const input = event.currentTarget.querySelector("input");
  const code = cleanCode(input.value);
  if (!code) return;
  try {
    setStatus("Recherche...");
    const record = await findRecordByCode(code);
    const data = record?.data?.quickList || record?.data;
    if (!data || data.type !== "quickList") throw new Error("Liste rapide introuvable");
    const list = normalizeQuickList({ ...data, code, shared: true, remoteRecordId: record.id });
    const existingIndex = state.quickLists.findIndex(item => item.code === list.code);
    if (existingIndex >= 0) {
      list.id = state.quickLists[existingIndex].id;
      state.quickLists[existingIndex] = mergeQuickLists(state.quickLists[existingIndex], list);
    } else {
      state.quickLists.unshift(list);
    }
    state.currentQuickListId = list.id;
    state.tab = "quickListDetail";
    input.value = "";
    saveLocal();
    render();
    subscribeToCurrentQuickList();
  } catch (error) {
    console.warn("Import liste rapide impossible", error);
    alert("Je n'ai pas trouvé cette liste rapide. Vérifie le code, puis réessaie.");
    setStatus("Hors ligne");
  }
}

function selectQuickList(id) {
  state.currentQuickListId = id;
  state.tab = "quickListDetail";
  saveLocal();
  render();
  subscribeToCurrentQuickList();
}

function addQuickItem(event) {
  event.preventDefault();
  const list = currentQuickList();
  const input = event.currentTarget.querySelector("input");
  const name = input.value.trim();
  if (!list || !name) return;
  const timestamp = nowISO();
  list.items.push({ id: uid("quick-item"), name, done: false, qty: 1, updatedAt: timestamp, deletedAt: "" });
  sortQuickItems(list);
  input.value = "";
  list.updatedAt = timestamp;
  saveQuickListAndSync(list);
  render();
}

function resetQuickList(id) {
  const list = state.quickLists.find(item => item.id === id);
  if (!list) return;
  if (!confirm(`Tout décocher dans "${list.name}" ?`)) return;
  const timestamp = nowISO();
  visibleQuickItems(list.items).forEach(item => {
    item.done = false;
    touchEntity(item, timestamp);
  });
  sortQuickItems(list);
  list.updatedAt = timestamp;
  saveQuickListAndSync(list, { immediate: true });
  render();
}

function renameQuickList(id) {
  const list = state.quickLists.find(item => item.id === id);
  if (!list) return;
  const value = prompt("Nouveau nom de la liste rapide", list.name);
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  const timestamp = nowISO();
  list.name = name;
  list.updatedAt = timestamp;
  saveQuickListAndSync(list, { immediate: true });
  render();
}

function toggleQuickItem(itemId) {
  const list = currentQuickList();
  const item = list?.items.find(row => row.id === itemId);
  if (!list || !item) return;
  const timestamp = nowISO();
  item.done = !item.done;
  touchEntity(item, timestamp);
  sortQuickItems(list);
  list.updatedAt = timestamp;
  saveQuickListAndSync(list);
  render();
}

function renameQuickItem(itemId) {
  const list = currentQuickList();
  const item = list?.items.find(row => row.id === itemId);
  if (!list || !item) return;
  const value = prompt("Renommer l'item", item.name);
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  const timestamp = nowISO();
  item.name = name;
  touchEntity(item, timestamp);
  sortQuickItems(list);
  list.updatedAt = timestamp;
  saveQuickListAndSync(list, { immediate: true });
  render();
}

function changeQuickQty(itemId, deltaOrValue) {
  const list = currentQuickList();
  const item = list?.items.find(row => row.id === itemId);
  if (!list || !item) return;
  if (typeof deltaOrValue === "number") {
    item.qty = normalizeQty(item.qty + deltaOrValue);
  } else {
    item.qty = normalizeQty(deltaOrValue);
  }
  const timestamp = touchEntity(item);
  list.updatedAt = timestamp;
  saveQuickListAndSync(list);
  render();
}

function deleteQuickItem(itemId) {
  const list = currentQuickList();
  if (!list) return;
  const item = list.items.find(row => row.id === itemId);
  if (!item) return;
  const timestamp = nowISO();
  item.deletedAt = timestamp;
  touchEntity(item, timestamp);
  list.updatedAt = timestamp;
  saveQuickListAndSync(list);
  render();
}

async function deleteQuickList(id) {
  const list = state.quickLists.find(item => item.id === id);
  if (!list) return;
  if (!confirm(`Supprimer la liste rapide "${list.name}" ?`)) return;
  try {
    const client = getPB();
    if (client && list.code) {
      let recordId = list.remoteRecordId;
      if (!recordId) {
        const record = await findRecordByCode(list.code);
        recordId = record?.id;
      }
      if (recordId) await client.collection(PB_COLLECTION).delete(recordId, { requestKey: null });
    }
  } catch (error) {
    console.warn("Suppression liste rapide distante impossible", error);
  }
  state.quickLists = state.quickLists.filter(item => item.id !== id);
  state.currentQuickListId = state.quickLists[0]?.id || null;
  state.tab = "quickLists";
  saveLocal();
  render();
}

async function subscribeToCurrentVoyage() {
  const voyage = currentVoyage();
  const client = getPB();
  if (unsubscribeCurrent) {
    try {
      unsubscribeCurrent();
    } catch (error) {
      console.warn("Désabonnement impossible", error);
    }
    unsubscribeCurrent = null;
  }
  if (!client || !voyage?.code) {
    setStatus(voyage?.shared ? "Synchronisé" : "Synchronisation...");
    return;
  }
  try {
    let record = null;
    if (voyage.remoteRecordId) {
      try {
        record = await client.collection(PB_COLLECTION).getOne(voyage.remoteRecordId, { requestKey: null });
      } catch (error) {
        record = null;
      }
    }
    if (!record) record = await findRecordByCode(voyage.code);
    voyage.shared = true;
    voyage.remoteRecordId = record.id;
    saveLocal();
    unsubscribeCurrent = await client.collection(PB_COLLECTION).subscribe(record.id, event => {
      if (event.action !== "update" || !event.record?.data) return;
      receiveRemoteVoyage(event.record.data, event.record.id);
    }, { requestKey: null });
    setStatus("Synchronisé");
  } catch (error) {
    setStatus(voyage.shared ? "Synchronisé" : "Hors ligne");
  }
}

function receiveRemoteVoyage(remoteData, recordId) {
  const incoming = normalizeVoyage({
    ...(remoteData.voyage || remoteData),
    shared: true,
    remoteRecordId: recordId
  });
  if (isUserEditing()) {
    pendingRemoteVoyage = incoming;
    return;
  }
  applyRemoteVoyage(incoming);
}

function applyRemoteVoyage(incoming) {
  const index = state.voyages.findIndex(voyage => voyage.code === incoming.code || voyage.id === incoming.id);
  if (index >= 0) {
    const previousId = state.voyages[index].id;
    state.voyages[index] = { ...mergeVoyages(state.voyages[index], incoming), id: previousId };
    if (state.currentVoyageId === incoming.id) state.currentVoyageId = previousId;
  } else {
    state.voyages.unshift(incoming);
    state.currentVoyageId = incoming.id;
  }
  saveLocal();
  render();
}

function flushPendingRemoteVoyage() {
  if (!pendingRemoteVoyage || isUserEditing()) return;
  const incoming = pendingRemoteVoyage;
  pendingRemoteVoyage = null;
  applyRemoteVoyage(incoming);
}

async function joinVoyage(event) {
  event.preventDefault();
  const input = event.currentTarget.querySelector("input");
  const code = cleanCode(input.value);
  if (!code) return;
  if (code === SETTINGS_CODE) {
    await loadSharedSettings();
    input.value = "";
    closeSheet("voyageSheet");
    openCustomCategories();
    return;
  }
  try {
    setStatus("Recherche...");
    const record = await findRecordByCode(code);
    if (!record?.data) throw new Error("Voyage introuvable");
    const voyage = normalizeVoyage({
      ...(record.data.voyage || record.data),
      code,
      shared: true,
      remoteRecordId: record.id
    });
    const existingIndex = state.voyages.findIndex(item => item.code === voyage.code);
    if (existingIndex >= 0) {
      voyage.id = state.voyages[existingIndex].id;
      state.voyages[existingIndex] = voyage;
    } else {
      state.voyages.unshift(voyage);
    }
    state.currentVoyageId = voyage.id;
    state.tab = "liste";
    saveLocal();
    input.value = "";
    closeSheet("voyageSheet");
    render();
    subscribeToCurrentVoyage();
  } catch (error) {
    console.warn("Import impossible", error);
    alert("Je n'ai pas trouvé ce voyage. Vérifie le code, puis réessaie.");
    setStatus("Hors ligne");
  }
}

function copyCode(code) {
  if (navigator.clipboard) {
    navigator.clipboard.writeText(code).then(() => showToast("Code copié"));
  } else {
    window.prompt("Code à copier", code);
    showToast("Code copié");
  }
}

function showToast(message) {
  const toast = document.getElementById("toast");
  if (!toast) return;
  toast.textContent = message;
  toast.classList.add("show");
  if (toastTimer) clearTimeout(toastTimer);
  toastTimer = setTimeout(() => toast.classList.remove("show"), 1600);
}

function closeSettingsMenu() {
  const menu = document.getElementById("settingsMenu");
  if (menu) menu.open = false;
}

function closeOpenMenus(except = null) {
  document.querySelectorAll(".voyage-menu[open]").forEach(menu => {
    if (menu !== except) menu.open = false;
  });
}

function openCustomCategories() {
  closeSettingsMenu();
  state.tab = "customCategories";
  saveLocal();
  render();
}

function openQuickLists() {
  state.tab = "quickLists";
  saveLocal();
  render();
  subscribeToCurrentQuickList();
}

function openInstallation() {
  closeSettingsMenu();
  state.tab = "installation";
  render();
}

function addCustomCategory(event, group = "family") {
  event.preventDefault();
  const input = event.currentTarget.querySelector("input");
  const name = input.value.trim();
  if (!name) return;
  addCustomMember(name, group);
  input.value = "";
  render();
}

function customMemberNames() {
  const aliasedDefaults = defaultCustomGroupNames.map(name => normalizeMemberName(state.customMemberAliases[name] || name));
  return [
    ...aliasedDefaults,
    ...state.customCategoryMembers,
    ...visibleCustomCategories(state.customCategories).map(defaultMemberForCategory)
  ]
    .map(normalizeMemberName)
    .filter(name => !state.customMemberDeletedAt?.[name])
    .filter(name => !defaultCustomGroupNames.includes(name) || aliasedDefaults.includes(name))
    .filter((name, index, list) => list.indexOf(name) === index);
}

function customMemberGroup(memberName) {
  return customMemberGroupValue(memberName);
}

function renderAddCustomMemberForm(group) {
  return `
    <form class="add-item" onsubmit="addCustomCategory(event, '${group}')">
      <button class="btn blue" type="submit">+</button>
      <input autocomplete="off" placeholder="Ajouter un membre">
    </form>
  `;
}

function buildIdealCustomCategories() {
  state.customCategoryMembers = [];
  state.customCategories = idealCustomCategories.map(template => ({
    id: uid("tpl"),
    name: template.name,
    icon: template.icon,
    member: template.member,
    updatedAt: nowISO(),
    deletedAt: "",
    items: template.items.map(name => ({ id: uid("tpl-item"), name, qty: 1, updatedAt: nowISO(), deletedAt: "" }))
  }));
  defaultMemberNames.forEach(name => {
    state.openMembers[`custom-${name}`] = false;
  });
  state.openMembers["custom-Général"] = false;
  saveLocal();
  saveSharedSettings();
  render();
}

function addCustomMember(name, group = "family") {
  const memberName = normalizeMemberName(name);
  if (!state.customCategoryMembers.includes(memberName) && !defaultCustomGroupNames.includes(memberName)) {
    state.customCategoryMembers.push(memberName);
  }
  delete state.customMemberDeletedAt[memberName];
  if (memberName !== "Général") {
    state.customMemberGroups[memberName] = group === "general" || group === "personal" ? group : "family";
  }
  state.openMembers[`custom-${memberName}`] = true;
  saveLocal();
  saveSharedSettings();
}

function renameCustomMember(memberName) {
  const current = normalizeMemberName(memberName);
  const value = prompt("Nouveau nom du membre", current);
  if (value === null) return;
  const next = normalizeMemberName(value);
  if (!next || next === current) return;
  const aliasEntry = Object.entries(state.customMemberAliases).find(([, alias]) => normalizeMemberName(alias) === current);
  const defaultSource = aliasEntry?.[0] || (defaultCustomGroupNames.includes(current) ? current : "");
  const timestamp = nowISO();
  state.customCategories.forEach(category => {
    if (defaultMemberForCategory(category) === current) {
      category.member = next;
      touchEntity(category, timestamp);
    }
  });
  if (defaultSource) {
    state.customMemberAliases[defaultSource] = next;
    state.customCategoryMembers = state.customCategoryMembers.filter(name => normalizeMemberName(name) !== next);
  } else {
    let replaced = false;
    state.customCategoryMembers = state.customCategoryMembers.map(name => {
      if (normalizeMemberName(name) !== current) return name;
      replaced = true;
      return next;
    });
    if (!replaced) state.customCategoryMembers.push(next);
  }
  const aliasedDefaults = defaultCustomGroupNames.map(name => normalizeMemberName(state.customMemberAliases[name] || name));
  state.customCategoryMembers = state.customCategoryMembers
    .map(normalizeMemberName)
    .filter((name, index, list) => list.indexOf(name) === index && !aliasedDefaults.includes(name) && !defaultCustomGroupNames.includes(name));
  state.openMembers[`custom-${next}`] = state.openMembers[`custom-${current}`] ?? true;
  delete state.openMembers[`custom-${current}`];
  if (state.customMemberGroups[current]) {
    state.customMemberGroups[next] = state.customMemberGroups[current];
    delete state.customMemberGroups[current];
  }
  if (state.customMemberDeletedAt[current]) {
    state.customMemberDeletedAt[next] = state.customMemberDeletedAt[current];
    delete state.customMemberDeletedAt[current];
  }
  saveLocal();
  saveSharedSettings();
  render();
}

function deleteCustomMember(memberName) {
  const current = normalizeMemberName(memberName);
  const categories = state.customCategories.filter(category => defaultMemberForCategory(category) === current);
  const message = categories.length
    ? `Supprimer "${current}" et ses ${categories.length} catégorie(s) personnalisée(s) ?`
    : `Supprimer "${current}" ?`;
  if (!confirm(message)) return;
  const timestamp = nowISO();
  state.customCategories.forEach(category => {
    if (defaultMemberForCategory(category) === current) {
      category.deletedAt = timestamp;
      touchEntity(category, timestamp);
    }
  });
  state.customCategoryMembers = state.customCategoryMembers.filter(name => normalizeMemberName(name) !== current);
  Object.entries(state.customMemberAliases).forEach(([source, alias]) => {
    if (normalizeMemberName(alias) === current) delete state.customMemberAliases[source];
  });
  const wasPersonal = isPersonalCustomMember(current);
  if (wasPersonal) state.customMemberGroups[current] = "personal";
  else delete state.customMemberGroups[current];
  state.customMemberDeletedAt[current] = timestamp;
  delete state.openMembers[`custom-${current}`];
  saveLocal();
  saveSharedSettings();
  render();
}

function addCustomCategoryToMember(memberName) {
  const current = normalizeMemberName(memberName);
  const value = prompt("Nom de la catégorie personnalisée");
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  const timestamp = nowISO();
  const category = { id: uid("tpl"), name, icon: categoryIconForName(name), member: current, updatedAt: timestamp, deletedAt: "", items: [] };
  state.customCategories.push(category);
  state.openCats[category.id] = true;
  state.openMembers[`custom-${current}`] = true;
  saveLocal();
  saveSharedSettings();
  render();
}

function renameCustomCategory(categoryId) {
  const category = state.customCategories.find(item => item.id === categoryId);
  if (!category) return;
  const value = prompt("Nouveau nom du modèle", category.name);
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  category.name = name;
  if (!category.icon) category.icon = categoryIconForName(name);
  touchEntity(category);
  saveLocal();
  saveSharedSettings();
  render();
}

function deleteCustomCategory(categoryId) {
  const category = state.customCategories.find(item => item.id === categoryId);
  if (!category) return;
  if (!confirm(`Supprimer le modèle "${category.name}" ?`)) return;
  const timestamp = nowISO();
  category.deletedAt = timestamp;
  touchEntity(category, timestamp);
  delete state.openCats[categoryId];
  saveLocal();
  saveSharedSettings();
  render();
}

function openCustomCategoryMemberSheet(action, categoryId) {
  const category = state.customCategories.find(item => item.id === categoryId);
  if (!category || !["move", "duplicate"].includes(action)) return;
  const currentMember = defaultMemberForCategory(category);
  const members = customMemberNames().filter(name => normalizeMemberName(name) !== currentMember);
  if (!members.length) {
    alert("Ajoute d'abord un autre membre pour déplacer ou dupliquer cette catégorie.");
    return;
  }
  customCategoryMoveTarget = { action, categoryId };
  document.getElementById("customCategoryMoveTitle").textContent = action === "move" ? "Déplacer une catégorie" : "Dupliquer une catégorie";
  document.getElementById("customCategoryMoveSubmit").textContent = action === "move" ? "Déplacer" : "Dupliquer";
  document.getElementById("customCategoryTargetMember").innerHTML = members
    .map(name => `<option value="${escapeHTML(name)}">${escapeHTML(name)}</option>`)
    .join("");
  closeOpenMenus();
  document.getElementById("customCategoryMoveSheet").classList.add("open");
}

function saveCustomCategoryMemberChange(event) {
  event.preventDefault();
  const target = customCategoryMoveTarget;
  if (!target) return;
  const category = state.customCategories.find(item => item.id === target.categoryId);
  const member = normalizeMemberName(document.getElementById("customCategoryTargetMember").value);
  if (!category || !member) return;
  const timestamp = nowISO();
  if (target.action === "move") {
    category.member = member;
    touchEntity(category, timestamp);
    state.openMembers[`custom-${member}`] = true;
    state.openCats[category.id] = true;
    showToast("Catégorie déplacée");
  } else {
    const copy = {
      ...category,
      id: uid("tpl"),
      member,
      updatedAt: timestamp,
      deletedAt: "",
      items: visibleCustomItems(category.items || []).map(item => ({
        ...item,
        id: uid("tpl-item"),
        qty: normalizeQty(item.qty || 1),
        updatedAt: timestamp,
        deletedAt: ""
      }))
    };
    state.customCategories.push(copy);
    state.openMembers[`custom-${member}`] = true;
    state.openCats[copy.id] = true;
    showToast("Catégorie dupliquée");
  }
  closeSheet("customCategoryMoveSheet");
  saveLocal();
  saveSharedSettings();
  render();
}

function addCustomItem(event, categoryId) {
  event.preventDefault();
  const category = state.customCategories.find(item => item.id === categoryId);
  const input = event.currentTarget.querySelector("input");
  const name = input.value.trim();
  if (!category || !name) return;
  const timestamp = nowISO();
  category.items.push({ id: uid("tpl-item"), name, qty: 1, updatedAt: timestamp, deletedAt: "" });
  touchEntity(category, timestamp);
  sortCustomCategoryItems(category);
  input.value = "";
  saveLocal();
  saveSharedSettings();
  render();
}

function renameCustomItem(categoryId, itemId) {
  const category = state.customCategories.find(item => item.id === categoryId);
  if (!category) return;
  const item = category.items.find(row => row.id === itemId);
  if (!item) return;
  const value = prompt("Renommer l'item", customItemName(item));
  if (value === null) return;
  const name = value.trim();
  if (!name) return;
  const timestamp = nowISO();
  item.name = name;
  touchEntity(item, timestamp);
  touchEntity(category, timestamp);
  sortCustomCategoryItems(category);
  saveLocal();
  saveSharedSettings();
  render();
}

function changeCustomQty(categoryId, itemId, deltaOrValue) {
  const category = state.customCategories.find(item => item.id === categoryId);
  const item = category?.items.find(row => row.id === itemId);
  if (!category || !item) return;
  if (typeof deltaOrValue === "number") {
    item.qty = normalizeQty(item.qty + deltaOrValue);
  } else {
    item.qty = normalizeQty(deltaOrValue);
  }
  const timestamp = touchEntity(item);
  touchEntity(category, timestamp);
  saveLocal();
  saveSharedSettings();
  render();
}

function deleteCustomItem(categoryId, itemId) {
  const category = state.customCategories.find(item => item.id === categoryId);
  if (!category) return;
  const item = category.items.find(row => row.id === itemId);
  if (!item) return;
  const timestamp = nowISO();
  item.deletedAt = timestamp;
  touchEntity(item, timestamp);
  touchEntity(category, timestamp);
  saveLocal();
  saveSharedSettings();
  render();
}

function openIconSheet(type, categoryId) {
  iconEditTarget = { type, categoryId };
  renderIconChoices();
  document.getElementById("iconSheet").classList.add("open");
}

function findIconTarget() {
  if (!iconEditTarget) return null;
  if (iconEditTarget.type === "custom") {
    return {
      category: state.customCategories.find(item => item.id === iconEditTarget.categoryId),
      voyage: null
    };
  }
  const voyage = currentVoyage();
  const { category } = findCategoryInVoyage(voyage, iconEditTarget.categoryId);
  return {
    category,
    voyage
  };
}

function renderIconChoices() {
  const target = document.getElementById("iconChoices");
  if (!target) return;
  const { category } = findIconTarget() || {};
  const active = categoryIcon(category);
  target.innerHTML = categoryIcons.map(icon => `
    <button class="icon-choice ${icon === active ? "active" : ""}" type="button" onclick="selectCategoryIcon('${icon}')">
      <span class="category-icon" style="--icon-url: url('./category-icons/${icon}.svg')" aria-hidden="true"></span>
    </button>
  `).join("");
}

function selectCategoryIcon(icon) {
  if (!categoryIcons.includes(icon)) return;
  const target = findIconTarget();
  if (!target?.category) return;
  target.category.icon = icon;
  if (iconEditTarget.type === "custom") {
    touchEntity(target.category);
    saveLocal();
    saveSharedSettings();
  } else if (target.voyage) {
    const timestamp = touchEntity(target.category);
    touchVoyage(target.voyage, timestamp);
    saveAndSync(target.voyage);
  }
  closeSheet("iconSheet");
  iconEditTarget = null;
  render();
}

function render() {
  const voyage = currentVoyage();
  setStatus(voyage ? (voyage.shared ? "Synchronisé" : "Synchronisation...") : "Synchronisé");

  if (!voyage && state.tab === "liste") state.tab = "voyages";

  if (state.tab === "liste") renderChecklist();
  else if (state.tab === "customCategories") renderCustomCategories();
  else if (state.tab === "installation") renderInstallation();
  else if (state.tab === "quickLists") renderQuickLists();
  else if (state.tab === "quickListDetail") renderQuickListDetail();
  else renderVoyages();
  renderBottomNav();
}

function renderBottomNav() {
  const nav = document.getElementById("bottomNav");
  if (!nav) return;
  const active = state.tab === "customCategories" ? "customCategories" : state.tab === "quickLists" || state.tab === "quickListDetail" ? "quickLists" : "voyages";
  nav.innerHTML = `
    <button class="${active === "voyages" ? "active" : ""}" type="button" onclick="goHome()"><span>⌂</span>Accueil</button>
    <button class="${active === "customCategories" ? "active" : ""}" type="button" onclick="openCustomCategories()"><span>☰</span>Gérer</button>
    <button class="${active === "quickLists" ? "active" : ""}" type="button" onclick="openQuickLists()"><span>✓</span>Liste rapide</button>
  `;
}

function renderInstallation() {
  const content = document.getElementById("content");
  content.innerHTML = `
    <section class="toolbar">
      <div class="toolbar-title">
        <h2>Installer l'application</h2>
        <p>Ouvrez le lien internet de l'application sur votre smartphone, puis suivez les étapes selon votre téléphone.</p>
      </div>
    </section>
    <section class="install-steps">
      <article class="install-card">
        <h3>Sur iPhone avec Safari</h3>
        <ol>
          <li>Ouvrez le lien de l'application dans Safari.</li>
          <li>Appuyez sur le bouton de partage en bas de l'écran.</li>
          <li>Choisissez "Sur l'écran d'accueil".</li>
          <li>Appuyez sur "Ajouter". L'icône apparaît alors avec vos applications.</li>
        </ol>
      </article>
      <article class="install-card">
        <h3>Sur Android avec Chrome</h3>
        <ol>
          <li>Ouvrez le lien de l'application dans Chrome.</li>
          <li>Appuyez sur le menu avec les trois points en haut à droite.</li>
          <li>Choisissez "Ajouter à l'écran d'accueil" ou "Installer l'application".</li>
          <li>Validez. L'icône apparaît alors avec vos applications.</li>
        </ol>
      </article>
      <article class="install-card">
        <h3>Si l'option n'apparaît pas</h3>
        <ol>
          <li>Actualisez la page, puis réessayez depuis le navigateur du téléphone.</li>
          <li>Sur iPhone, utilisez Safari plutôt qu'un navigateur intégré à une messagerie.</li>
          <li>Sur Android, utilisez Chrome et vérifiez que vous êtes bien sur la page de l'application.</li>
        </ol>
      </article>
    </section>
  `;
}

function renderCustomCategories() {
  const content = document.getElementById("content");
  const renderCustomCategoryCard = category => {
    sortCustomCategoryItems(category);
    const open = state.openCats[category.id] === true;
    const visibleItems = visibleCustomItems(category.items || []);
    const items = visibleItems.map(item => `
      <article class="item template-item ${activeSwipeItemId === item.id ? "swiped" : ""}" onpointerdown="startItemSwipe(event, '${item.id}')" onpointerup="endItemSwipe(event, '${item.id}')" onpointercancel="activeSwipeItemId=null">
        <div class="item-content">
          <div class="item-label" onclick="closeQtyEditorFromLabel('${item.id}')">${escapeHTML(customItemName(item))}</div>
          <div class="mini-actions" onclick="event.stopPropagation()">
            ${qtyEditorItemId === item.id ? `
            <div class="qty" onclick="event.stopPropagation()">
              <button type="button" onclick="changeCustomQty('${category.id}', '${item.id}', -1)" title="Diminuer">−</button>
              <input aria-label="Quantité" value="${escapeHTML(item.qty)}" inputmode="numeric" onchange="changeCustomQty('${category.id}', '${item.id}', this.value)" onfocus="this.select()">
              <button type="button" onclick="changeCustomQty('${category.id}', '${item.id}', 1)" title="Augmenter">+</button>
            </div>
            ` : `
            <button class="qty-pill" type="button" onclick="openQtyEditorFromPill('custom', '${category.id}', '${item.id}')" title="Modifier la quantité">${item.qty > 1 ? escapeHTML(item.qty) : "+"}</button>
            `}
          </div>
        </div>
        <div class="item-actions">
          <button class="item-action edit" type="button" onclick="renameCustomItem('${category.id}', '${item.id}')"><span>✎</span>Modifier</button>
          <button class="item-action delete" type="button" onclick="deleteCustomItem('${category.id}', '${item.id}')"><span>🗑</span>Suppr.</button>
        </div>
      </article>
    `).join("");

    return `
      <article class="category ${open ? "open" : ""}">
        <div class="category-head">
          <button class="category-title" type="button" onclick="toggleCategory('${category.id}')">
            ${renderCategoryIcon(category)}
            <span class="category-name">${escapeHTML(category.name)}</span>
          </button>
          <div class="category-actions" onclick="event.stopPropagation()">
            <span class="badge">${visibleItems.length}</span>
            <details class="voyage-menu" onclick="event.stopPropagation()">
              <summary class="mini" title="Options de la catégorie">⋮</summary>
              <div class="voyage-menu-panel">
                <button class="menu-item" type="button" onclick="openIconSheet('custom', '${category.id}')">Modifier l'icône</button>
                <button class="menu-item" type="button" onclick="renameCustomCategory('${category.id}')">Renommer la catégorie</button>
                <button class="menu-item" type="button" onclick="openCustomCategoryMemberSheet('move', '${category.id}')">Déplacer une catégorie</button>
                <button class="menu-item" type="button" onclick="openCustomCategoryMemberSheet('duplicate', '${category.id}')">Dupliquer une catégorie</button>
                <button class="menu-item red" type="button" onclick="deleteCustomCategory('${category.id}')">Supprimer la catégorie</button>
              </div>
            </details>
          </div>
        </div>
        <div class="category-body">
          ${items || `<div class="notice">Aucun item dans ce modèle.</div>`}
          <form class="add-item" onsubmit="addCustomItem(event, '${category.id}')">
            <button class="btn blue" type="submit">+</button>
            <input autocomplete="off" placeholder="Ajouter un item">
          </form>
        </div>
      </article>
    `;
  };

  const memberCards = customMemberNames().sort(compareItemNames).map(groupName => {
    const groupId = `custom-${groupName}`;
    const open = state.openMembers[groupId] === true;
    const categories = visibleCustomCategories(state.customCategories)
      .filter(category => defaultMemberForCategory(category) === groupName)
      .sort(compareItemNames);
    const html = `
      <article class="category ${open ? "open" : ""}">
        <div class="category-head">
          <button class="category-title" type="button" onclick="toggleMember('${groupId}')">
            <span class="category-icon" style="--icon-url: url('./category-icons/suitcase.svg')" aria-hidden="true"></span>
            <span class="category-name member-name">${escapeHTML(groupName)}</span>
          </button>
          <div class="category-actions" onclick="event.stopPropagation()">
            <span class="badge">${categories.length}</span>
            <details class="voyage-menu" onclick="event.stopPropagation()">
              <summary class="mini" title="Options du membre">⋮</summary>
              <div class="voyage-menu-panel">
                <button class="menu-item" type="button" onclick="renameCustomMember('${escapeHTML(groupName)}')">Modifier le nom</button>
                <button class="menu-item" type="button" onclick="addCustomCategoryToMember('${escapeHTML(groupName)}')">Ajouter une catégorie personnalisée</button>
                <button class="menu-item red" type="button" onclick="deleteCustomMember('${escapeHTML(groupName)}')">Supprimer le membre</button>
              </div>
            </details>
          </div>
        </div>
        <div class="category-body">
          ${categories.map(renderCustomCategoryCard).join("") || `<div class="notice">Aucune catégorie dans ce groupe.</div>`}
        </div>
      </article>
    `;
    return { groupName, html };
  });
  const generalCards = memberCards.filter(card => customMemberGroup(card.groupName) === "general").map(card => card.html).join("");
  const familyCards = memberCards.filter(card => customMemberGroup(card.groupName) === "family").map(card => card.html).join("");
  const personalCards = memberCards.filter(card => customMemberGroup(card.groupName) === "personal").map(card => card.html).join("");
  const groups = [
    renderChecklistGroup("G\u00e9n\u00e9ral", `${generalCards || `<div class="notice">Aucune cat\u00e9gorie g\u00e9n\u00e9rale.</div>`}${renderAddCustomMemberForm("general")}`),
    renderChecklistGroup("Famille", `${familyCards || `<div class="notice">Aucun membre dans la famille.</div>`}${renderAddCustomMemberForm("family")}`),
    renderChecklistGroup("Personnel", `${personalCards || `<div class="notice">Aucun membre personnel sur cet appareil.</div>`}${renderAddCustomMemberForm("personal")}`)
  ].join("");

  content.innerHTML = `
    <section class="toolbar">
      <div class="toolbar-title">
        <h2>Catégories personnalisées</h2>
        <p>Général et Famille sont partagés via PocketBase. Personnel reste uniquement sur cet appareil.</p>
      </div>
    </section>
    <section class="grid">
      ${groups || `<div class="panel empty"><h2>Aucun modèle</h2><p>Créez une catégorie personnalisée pour la retrouver lors de l'ajout dans un voyage.</p></div>`}
    </section>
  `;
}

function renderQuickLists() {
  const content = document.getElementById("content");
  if (dedupeQuickLists()) saveLocal();
  const cards = state.quickLists.map(list => {
    const visible = visibleQuickItems(list.items || []);
    const done = visible.filter(item => item.done).length;
    const total = visible.length;
    const percent = total ? Math.round((done / total) * 100) : 0;
    return `
      <article class="voyage-card clickable ${list.id === state.currentQuickListId ? "active" : ""}" onclick="selectQuickList('${list.id}')">
        <div class="voyage-main">
          <div>
            <h2 class="voyage-name">${escapeHTML(list.name)}</h2>
            <div class="voyage-meta">
              <span class="badge">${done}/${total} prêts</span>
              <span class="badge blue">${escapeHTML(list.code)}</span>
            </div>
          </div>
          <div class="status">${percent}%</div>
        </div>
        <div class="progress" aria-hidden="true"><span style="${progressStyle(percent)}"></span></div>
      </article>
    `;
  }).join("");

  content.innerHTML = `
    <section class="toolbar">
      <div class="toolbar-title">
        <h2>Listes rapides</h2>
        <p>Pour les sacs et petites préparations du quotidien.</p>
      </div>
    </section>
    <section class="grid section">
      ${cards || `<div class="panel empty"><h2>Aucune liste rapide</h2><p>Créez une liste pour un sac de piscine, de foot ou de crèche.</p></div>`}
      <button class="voyage-card add-card" type="button" onclick="createQuickList()">
        <span class="plus">+</span>
        <strong>Ajouter une liste rapide</strong>
      </button>
    </section>
    <form class="add-item section" onsubmit="joinQuickList(event)">
      <button class="btn green" type="submit">+</button>
      <input autocomplete="off" inputmode="text" maxlength="8" placeholder="Ajouter via un code">
    </form>
  `;
}

function renderQuickListDetail() {
  const list = currentQuickList();
  const content = document.getElementById("content");
  if (!list) {
    renderQuickLists();
    return;
  }
  sortQuickItems(list);
  const visible = visibleQuickItems(list.items || []);
  const done = visible.filter(item => item.done).length;
  const total = visible.length;
  const percent = total ? Math.round((done / total) * 100) : 0;
  const items = visibleQuickItems(list.items || []).map(item => `
    <article class="item quick-item ${item.done ? "done" : ""} ${activeSwipeItemId === item.id ? "swiped" : ""}" onpointerdown="startItemSwipe(event, '${item.id}')" onpointerup="endItemSwipe(event, '${item.id}')" onpointercancel="activeSwipeItemId=null">
      <div class="item-content">
        <button class="check" type="button" onclick="toggleQuickItem('${item.id}')" title="Valider" aria-label="Valider"></button>
        <div class="item-label" onclick="closeQtyEditorFromLabel('${item.id}')">${escapeHTML(item.name)}</div>
        <div class="mini-actions" onclick="event.stopPropagation()">
          ${qtyEditorItemId === item.id ? `
          <div class="qty" onclick="event.stopPropagation()">
            <button type="button" onclick="changeQuickQty('${item.id}', -1)" title="Diminuer">−</button>
            <input aria-label="Quantité" value="${escapeHTML(item.qty)}" inputmode="numeric" onchange="changeQuickQty('${item.id}', this.value)" onfocus="this.select()">
            <button type="button" onclick="changeQuickQty('${item.id}', 1)" title="Augmenter">+</button>
          </div>
          ` : `
          <button class="qty-pill" type="button" onclick="openQtyEditorFromPill('quick', '', '${item.id}')" title="Modifier la quantité">${item.qty > 1 ? escapeHTML(item.qty) : "+"}</button>
          `}
        </div>
      </div>
      <div class="item-actions">
        <button class="item-action edit" type="button" onclick="renameQuickItem('${item.id}')"><span>✎</span>Modifier</button>
        <button class="item-action delete" type="button" onclick="deleteQuickItem('${item.id}')"><span>🗑</span>Suppr.</button>
      </div>
    </article>
  `).join("");

  content.innerHTML = `
    <section class="section panel panel-pad">
      <div class="toolbar">
        <div class="toolbar-title">
          <div class="title-row">
            <h2>${escapeHTML(list.name)}</h2>
            <button class="code-button" type="button" onclick="copyCode('${list.code}')" title="Copier le code">${escapeHTML(list.code)}</button>
          </div>
          <p>${done}/${total} éléments prêts</p>
        </div>
        <div class="category-actions trip-actions">
          <details class="voyage-menu">
            <summary class="icon-btn" title="Options de la liste rapide">⋮</summary>
            <div class="voyage-menu-panel">
              <button class="menu-item" type="button" onclick="renameQuickList('${list.id}')">Renommer la liste</button>
              <button class="menu-item" type="button" onclick="resetQuickList('${list.id}')">Tout décocher</button>
              <button class="menu-item red" type="button" onclick="deleteQuickList('${list.id}')">Supprimer la liste</button>
            </div>
          </details>
        </div>
      </div>
      <div class="progress" aria-hidden="true"><span style="${progressStyle(percent)}"></span></div>
    </section>
    <section class="panel panel-pad section">
      <div class="grid">
        ${items || `<div class="notice">Aucun item dans cette liste rapide.</div>`}
      </div>
      <form class="add-item" onsubmit="addQuickItem(event)">
        <button class="btn blue" type="submit">+</button>
        <input autocomplete="off" placeholder="Ajouter un item">
      </form>
    </section>
  `;
}

function renderVoyages() {
  const content = document.getElementById("content");
  if (!state.voyages.length) {
    content.innerHTML = `
      <section class="home-hero" aria-label="Vacances en famille">
        <img src="./vacances.avif" alt="Famille en vacances">
      </section>
      <section class="panel empty">
        <h2>Aucun voyage pour le moment</h2>
        <p>Ajoutez un voyage en le créant ou avec un code partagé.</p>
      </section>
      <button class="voyage-card add-card full" type="button" onclick="openVoyageSheet()">
        <span class="plus">+</span>
        <strong>Ajouter un voyage</strong>
      </button>
    `;
    return;
  }

  const cards = state.voyages.map(voyage => {
    const progress = progressForVoyage(voyage);
    const isCurrent = voyage.id === state.currentVoyageId;
    const dateLine = formatTripDateLine(voyage);
    return `
      <article class="voyage-card clickable ${isCurrent ? "active" : ""}" onclick="selectVoyage('${voyage.id}')">
        <div class="voyage-main">
          <div>
            <div class="title-row">
              <h2 class="voyage-name">${escapeHTML(voyage.name)}</h2>
              ${renderDestinationLink(voyage)}
            </div>
            ${dateLine ? `<p class="muted">${escapeHTML(dateLine)}</p>` : ""}
            <div class="voyage-meta">
              <span class="badge">${progress.done}/${progress.total} éléments prêts</span>
              <span class="badge blue">${escapeHTML(voyage.code)}</span>
            </div>
          </div>
          <div class="status">${progress.percent}%</div>
        </div>
        <div class="progress" aria-hidden="true"><span style="${progressStyle(progress.percent)}"></span></div>
      </article>
    `;
  }).join("");

  content.innerHTML = `
    <section class="home-hero" aria-label="Vacances en famille">
      <img src="./vacances.avif" alt="Famille en vacances">
    </section>
    <section class="toolbar">
      <div class="toolbar-title">
        <h2>Listes des voyages</h2>
      </div>
    </section>
    <section class="grid">
      ${cards}
      <button class="voyage-card add-card" type="button" onclick="openVoyageSheet()">
        <span class="plus">+</span>
        <strong>Ajouter un voyage</strong>
      </button>
    </section>
  `;
}

function renderChecklist() {
  const voyage = currentVoyage();
  const content = document.getElementById("content");
  if (!voyage) {
    renderVoyages();
    return;
  }
  const progress = progressForVoyage(voyage);
  const general = renderGeneralSection(voyage);
  const generalMembers = voyageMembers(voyage)
    .filter(member => normalizeMemberGroup(member.group) === "general")
    .map(member => renderMember(voyage, member))
    .join("");
  const familyMembers = voyageMembers(voyage)
    .filter(member => normalizeMemberGroup(member.group) !== "general")
    .map(member => renderMember(voyage, member))
    .join("");
  const groupedLists = [
    renderChecklistGroup("Général", general + generalMembers, "Aucune information générale."),
    renderChecklistGroup("Famille", familyMembers, "Ajoutez un membre pour commencer.")
  ].join("");
  const daysLeft = daysUntilTrip(voyage);
  const dateLine = formatTripDateLine(voyage);
  const durationLabel = tripDurationLabel(voyage);
  const weatherPanel = renderWeatherPanel(voyage);
  ensureTripWeather(voyage);
  content.innerHTML = `
    <section class="section panel panel-pad">
      <div class="toolbar">
        <div class="toolbar-title">
          <div class="title-row">
            <h2>${escapeHTML(voyage.name)}</h2>
            ${renderDestinationLink(voyage)}
            <button class="code-button" type="button" onclick="copyCode('${voyage.code}')" title="Copier le code">${escapeHTML(voyage.code)}</button>
          </div>
          ${dateLine ? `<p>${escapeHTML(dateLine)} ${durationLabel ? `<span class="badge">${escapeHTML(durationLabel)}</span>` : ""}</p>` : ""}
          <p>${progress.done}/${progress.total} éléments prêts</p>
        </div>
        <div class="category-actions trip-actions">
          <details class="voyage-menu">
            <summary class="icon-btn" title="Options du voyage">⋮</summary>
            <div class="voyage-menu-panel">
              <button class="menu-item" type="button" onclick="addMember()">Ajouter un membre</button>
              <button class="menu-item" type="button" onclick="openVoyageSheet('${voyage.id}')">Modifier le voyage</button>
              <button class="menu-item" type="button" onclick="resetVoyageLists('${voyage.id}')">Réinitialiser les listes</button>
              <button class="menu-item red" type="button" onclick="deleteVoyage('${voyage.id}')">Supprimer le voyage</button>
            </div>
          </details>
          ${daysLeft ? `<span class="days-left">${escapeHTML(daysLeft)}</span>` : ""}
        </div>
      </div>
      <div class="progress" aria-hidden="true"><span style="${progressStyle(progress.percent)}"></span></div>
    </section>
    ${weatherPanel}
    <section class="grid">
      ${groupedLists}
    </section>
  `;
}

function renderGeneralSection(voyage) {
  const categories = visibleCategories(voyage.categories || []);
  const progress = progressForMember({ categories });
  const open = state.openMembers.general === true;
  return `
    <article class="category ${open ? "open" : ""}">
      <div class="category-head">
        <button class="category-title" type="button" onclick="toggleMember('general')">
          <span class="category-icon" style="--icon-url: url('./category-icons/document.svg')" aria-hidden="true"></span>
          <span class="category-name member-name">Général</span>
        </button>
        <div class="category-actions" onclick="event.stopPropagation()">
          <span class="badge">${progress.done}/${progress.total}</span>
          <details class="voyage-menu" onclick="event.stopPropagation()">
            <summary class="mini" title="Options de Général">⋮</summary>
            <div class="voyage-menu-panel">
              <button class="menu-item" type="button" onclick="addCategoryToGeneral()">Ajouter une catégorie</button>
            </div>
          </details>
        </div>
      </div>
      <div class="category-body">
        ${categories.map(category => renderCategory(voyage, category)).join("") || `<div class="notice">Aucune catégorie générale.</div>`}
      </div>
    </article>
  `;
}

function renderMember(voyage, member) {
  const progress = progressForMember(member);
  const open = state.openMembers[member.id] === true;
  const categories = visibleCategories(member.categories || []).map(category => renderCategory(voyage, category)).join("");
  return `
    <article class="category ${open ? "open" : ""}">
      <div class="category-head">
        <button class="category-title" type="button" onclick="toggleMember('${member.id}')">
          <span class="category-icon" style="--icon-url: url('./category-icons/suitcase.svg')" aria-hidden="true"></span>
          <span class="category-name member-name">${escapeHTML(member.name)}</span>
        </button>
        <div class="category-actions" onclick="event.stopPropagation()">
          <span class="badge">${progress.done}/${progress.total}</span>
          <details class="voyage-menu" onclick="event.stopPropagation()">
            <summary class="mini" title="Options du membre">⋮</summary>
            <div class="voyage-menu-panel">
              <button class="menu-item" type="button" onclick="addCategoryToMember('${member.id}')">Ajouter une catégorie</button>
              <button class="menu-item" type="button" onclick="renameMember('${member.id}')">Renommer le membre</button>
              <button class="menu-item red" type="button" onclick="deleteMember('${member.id}')">Supprimer le membre</button>
            </div>
          </details>
        </div>
      </div>
      <div class="category-body">
        ${categories || `<div class="notice">Aucune catégorie pour ce membre.</div>`}
      </div>
    </article>
  `;
}

function renderCategory(voyage, category) {
  sortCategoryItems(category);
  const progress = progressForCategory(category);
  const open = state.openCats[category.id] === true;
  const items = visibleItems(category.items || []).map(item => {
    const status = normalizeItemStatus(item);
    return `
    <article class="item ${status === "checked" ? "checked" : ""} ${status === "done" ? "done" : ""} ${activeSwipeItemId === item.id ? "swiped" : ""}" onpointerdown="startItemSwipe(event, '${item.id}')" onpointerup="endItemSwipe(event, '${item.id}')" onpointercancel="activeSwipeItemId=null">
      <div class="item-content">
        <button class="check" type="button" onclick="toggleItem('${category.id}', '${item.id}')" title="Changer l'état" aria-label="Changer l'état"></button>
        <div class="item-label" onclick="closeQtyEditorFromLabel('${item.id}')">${escapeHTML(item.name)}</div>
        <div class="mini-actions" onclick="event.stopPropagation()">
          ${qtyEditorItemId === item.id ? `
          <div class="qty" onclick="event.stopPropagation()">
            <button type="button" onclick="changeQty('${category.id}', '${item.id}', -1)" title="Diminuer">−</button>
            <input aria-label="Quantité" value="${escapeHTML(item.qty)}" inputmode="numeric" onchange="changeQty('${category.id}', '${item.id}', this.value)" onfocus="this.select()">
            <button type="button" onclick="changeQty('${category.id}', '${item.id}', 1)" title="Augmenter">+</button>
          </div>
          ` : `
          <button class="qty-pill" type="button" onclick="openQtyEditorFromPill('voyage', '${category.id}', '${item.id}')" title="Modifier la quantité">${item.qty > 1 ? escapeHTML(item.qty) : "+"}</button>
          `}
        </div>
      </div>
      <div class="item-actions">
        <button class="item-action edit" type="button" onclick="renameItem('${category.id}', '${item.id}')"><span>✎</span>Modifier</button>
        <button class="item-action delete" type="button" onclick="deleteItem('${category.id}', '${item.id}')"><span>🗑</span>Suppr.</button>
      </div>
    </article>
  `;
  }).join("");

  return `
    <article class="category ${open ? "open" : ""}">
      <div class="category-head">
        <button class="category-title" type="button" onclick="toggleCategory('${category.id}')">
          ${renderCategoryIcon(category)}
          <span class="category-name">${escapeHTML(category.name)}</span>
        </button>
        <div class="category-actions" onclick="event.stopPropagation()">
          <span class="badge">${progress.done}/${progress.total}</span>
          <details class="voyage-menu" onclick="event.stopPropagation()">
            <summary class="mini" title="Options de la catégorie">⋮</summary>
            <div class="voyage-menu-panel">
              <button class="menu-item" type="button" onclick="openIconSheet('voyage', '${category.id}')">Modifier l'icône</button>
              <button class="menu-item" type="button" onclick="renameCategory('${category.id}')">Renommer la catégorie</button>
              <button class="menu-item red" type="button" onclick="deleteCategory('${category.id}')">Supprimer la catégorie</button>
            </div>
          </details>
        </div>
      </div>
      <div class="category-body">
        ${items || `<div class="notice">Aucun élément dans cette catégorie.</div>`}
        <form class="add-item" onsubmit="addItem(event, '${category.id}')">
          <button class="btn blue" type="submit">+</button>
          <input autocomplete="off" placeholder="Ajouter un élément">
        </form>
      </div>
    </article>
  `;
}

function renderShare() {
  const voyage = currentVoyage();
  const content = document.getElementById("content");
  if (!voyage) {
    renderVoyages();
    return;
  }
  content.innerHTML = `
    <section class="panel panel-pad section">
      <div class="toolbar">
        <div class="toolbar-title">
          <h2>Partager ce voyage</h2>
          <p>Le code ci-dessous donne accès uniquement à "${escapeHTML(voyage.name)}".</p>
        </div>
      </div>
      <div class="code-box">
        <div>
          <div class="muted" style="color:#cbd5e1;margin:0 0 6px">Code du voyage</div>
          <div class="code">${escapeHTML(voyage.code)}</div>
        </div>
        <button class="btn ghost" type="button" onclick="copyCode('${voyage.code}')">Copier</button>
      </div>
      <div class="button-row" style="margin-top:12px">
        <button class="btn green" type="button" onclick="saveVoyageRemote(currentVoyage())">Synchroniser</button>
        <button class="btn ghost" type="button" onclick="setTab('liste')">Retour liste</button>
      </div>
    </section>

    <section class="panel panel-pad section">
      <form class="grid" onsubmit="joinVoyage(event)">
        <div class="field">
          <label for="joinCode">Ajouter un autre voyage partagé</label>
          <input id="joinCode" autocomplete="off" inputmode="text" maxlength="8" placeholder="Code du voyage">
        </div>
        <button class="btn blue full" type="submit">Ouvrir ce voyage</button>
      </form>
    </section>

    <section class="notice blue">
      Tous les voyages sont synchronisés automatiquement avec PocketBase. Le code permet simplement de retrouver ou ajouter un voyage sur un autre appareil.
    </section>
  `;
}

document.addEventListener("focusout", () => {
  setTimeout(flushPendingRemoteVoyage, 120);
});

document.addEventListener("click", event => {
  const menu = event.target.closest(".voyage-menu");
  if (!menu) {
    closeOpenMenus();
    return;
  }
  closeOpenMenus(menu);
});

window.addEventListener("online", () => {
  syncAllVoyages({ immediate: true });
  syncAllQuickLists({ immediate: true });
});

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./service-worker.js").catch(error => {
      console.warn("Service worker indisponible", error);
    });
  });
}

loadLocal();
render();
loadSharedSettings();
syncAllVoyages();
syncAllQuickLists();
subscribeToCurrentVoyage();



