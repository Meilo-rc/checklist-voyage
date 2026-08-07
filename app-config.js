const VERSION = "2.62";
const REMOTE_SCHEMA_VERSION = 3;
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
const voyageSyncTimers = new Map();
const quickListSyncTimers = new Map();
const remoteSyncQueues = new Map();
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
let editEntityTarget = null;
let editEntityIcon = "suitcase";
let customCategoryMoveTarget = null;
const weatherFetchIds = new Set();
let draftVoyageParticipants = [];
let memberSheetGroup = "family";
let memberSheetMember = "";

const categoryIcons = [
  "add",
  "add-invoice-stroke-rounded",
  "airpod",
  "baby",
  "bathtub",
  "beach",
  "bed",
  "boat",
  "boy",
  "bus",
  "calendar",
  "camera",
  "car",
  "categorie",
  "child",
  "clothes",
  "cocktail",
  "diaper",
  "document",
  "dress",
  "eyeglass",
  "female",
  "first-aid",
  "gamepad",
  "games",
  "hiking",
  "home",
  "hotel",
  "key",
  "liste",
  "luggage",
  "male",
  "manager",
  "money",
  "music",
  "passport",
  "plane",
  "plug",
  "restaurant",
  "setting",
  "shopping",
  "ski",
  "snow",
  "sport",
  "stretching",
  "suit",
  "suitcase",
  "sun",
  "swimming",
  "tag",
  "tent",
  "toiletries",
  "tools",
  "train",
  "umbrella",
  "video",
  "walking",
  "water",
  "workout",
  "writing"
];

const iconLabels = {
  baby: "Bébé",
  bathtub: "Salle de bain",
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
  ["plane", ["trajet avion", "trajet - avion", "transport avion", "transport - avion"]],
  ["train", ["trajet train", "trajet - train", "transport train", "transport - train"]],
  ["car", ["trajet voiture", "trajet - voiture", "transport voiture", "transport - voiture"]],
  ["hotel", ["logement hotel", "logement - hotel", "logement hôtel", "logement - hôtel"]],
  ["home", ["logement famille", "logement - famille"]],
  ["key", ["logement location", "logement - location"]],
  ["tent", ["logement camping", "logement - camping"]],
  ["plane", ["avion", "vol", "aéroport", "depart", "départ"]],
  ["train", ["train", "rail"]],
  ["car", ["voiture", "auto", "route"]],
  ["bus", ["bus", "car scolaire"]],
  ["boat", ["bateau", "ferry", "mer"]],
  ["hotel", ["hotel", "hôtel"]],
  ["tent", ["camping", "tente"]],
  ["bed", ["logement", "nuit"]],
  ["restaurant", ["repas", "restaurant", "alimentation", "nourriture", "cuisine"]],
  ["first-aid", ["santé", "sante", "pharmacie", "médicament", "medicament", "soin"]],
  ["bathtub", ["salle de bain", "toilette", "hygiène", "hygiene", "trousse de toilette"]],
  ["toiletries", ["trousse"]],
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

const exactIconRules = {
  "trajet avion": "plane",
  "trajet - avion": "plane",
  "transport avion": "plane",
  "transport - avion": "plane",
  avion: "plane",
  "trajet train": "train",
  "trajet - train": "train",
  "transport train": "train",
  "transport - train": "train",
  train: "train",
  "trajet voiture": "car",
  "trajet - voiture": "car",
  "transport voiture": "car",
  "transport - voiture": "car",
  voiture: "car",
  "logement hotel": "hotel",
  "logement - hotel": "hotel",
  "logement hotel": "hotel",
  "logement - hotel": "hotel",
  hotel: "hotel",
  "logement famille": "home",
  "logement - famille": "home",
  famille: "home",
  "logement location": "key",
  "logement - location": "key",
  location: "key",
  "logement camping": "tent",
  "logement - camping": "tent",
  camping: "tent"
};

const memberIconRules = {
  richard: "suit",
  jenna: "dress",
  milo: "boy",
  malone: "baby",
  bebe: "baby",
  baby: "baby"
};

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
  customMemberIcons: {},
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

const presetChoiceLabels = {
  transport: {
    avion: "Avion",
    train: "Train",
    voiture: "Voiture",
    bus: "Bus",
    bateau: "Bateau"
  },
  lodging: {
    hotel: "Hôtel",
    camping: "Camping",
    famille: "Famille",
    location: "Location"
  }
};
