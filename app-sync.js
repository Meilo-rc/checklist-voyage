function saveAndSync(voyage, options = {}) {
  saveLocal();
  scheduleRemoteSync(voyageSyncTimers, "voyage", voyage, options, () => saveVoyageRemote(voyage));
}

async function findRecordByCode(code) {
  const client = getPB();
  if (!client) throw new Error("PocketBase indisponible");
  return client.collection(PB_COLLECTION).getFirstListItem(`code = "${cleanCode(code)}"`, {
    requestKey: null
  });
}

function remoteSyncKey(type, entity) {
  return `${type}:${entity?.remoteRecordId || cleanCode(entity?.code) || entity?.id || "unknown"}`;
}

function enqueueRemoteSync(key, task) {
  const previous = remoteSyncQueues.get(key) || Promise.resolve();
  const next = previous
    .catch(() => {})
    .then(task)
    .finally(() => {
      if (remoteSyncQueues.get(key) === next) remoteSyncQueues.delete(key);
    });
  remoteSyncQueues.set(key, next);
  return next;
}

function scheduleRemoteSync(timerMap, type, entity, options, task) {
  if (!entity) return;
  const key = remoteSyncKey(type, entity);
  const existing = timerMap.get(key);
  if (existing) clearTimeout(existing);
  const delay = options?.immediate ? 0 : 550;
  const timer = setTimeout(() => {
    timerMap.delete(key);
    enqueueRemoteSync(key, task);
  }, delay);
  timerMap.set(key, timer);
}

function settingsPayload() {
  repairCustomMemberState();
  const syncedState = syncedSettingsState();
  const syncedCategories = mergeCustomCategoryList(syncedState.customCategories, []);
  const categories = visibleCustomCategories(syncedCategories).map(category => ({
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
    schemaVersion: REMOTE_SCHEMA_VERSION,
    appVersion: VERSION,
    customCategories: syncedCategories,
    customCategoryMembers: syncedState.customCategoryMembers,
    customMemberAliases: state.customMemberAliases,
    customMemberIcons: syncedState.customMemberIcons,
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
  state.customMemberIcons = {
    ...(merged.customMemberIcons && typeof merged.customMemberIcons === "object" ? merged.customMemberIcons : {}),
    ...personal.customMemberIcons
  };
  state.customMemberGroups = {
    ...(merged.customMemberGroups && typeof merged.customMemberGroups === "object" ? merged.customMemberGroups : {}),
    ...personal.customMemberGroups
  };
  state.customMemberDeletedAt = {
    ...(merged.customMemberDeletedAt && typeof merged.customMemberDeletedAt === "object" ? merged.customMemberDeletedAt : {}),
    ...personal.customMemberDeletedAt
  };
  repairCustomMemberState();
  saveLocal();
  if (state.tab === "customCategories") render();
  renderMemberTemplateGroups(memberSheetMember);
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
  return enqueueRemoteSync(`settings:${SETTINGS_CODE}`, saveSharedSettingsNow);
}

async function saveSharedSettingsNow() {
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
      state.customMemberIcons = { ...(data.customMemberIcons || {}), ...personal.customMemberIcons };
      state.customMemberGroups = { ...(data.customMemberGroups || {}), ...personal.customMemberGroups };
      state.customMemberDeletedAt = { ...(data.customMemberDeletedAt || {}), ...personal.customMemberDeletedAt };
      repairCustomMemberState();
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
      if (event.action === "delete") {
        settingsRecordId = "";
        saveLocal();
        return;
      }
      if (event.action !== "update" || !event.record?.data) return;
      applySettingsData(event.record.data);
    }, { requestKey: null });
  } catch (error) {
    console.warn("Abonnement paramètres impossible", error);
  }
}

function remotePayload(voyage) {
  const normalized = normalizeVoyage(voyage);
  return {
    ...normalized,
    type: "voyage",
    schemaVersion: REMOTE_SCHEMA_VERSION,
    appVersion: VERSION,
    shared: true,
    updatedAt: normalized.updatedAt || nowISO()
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
    const hadRemoteRecord = Boolean(voyage.remoteRecordId);
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
    if (!record && hadRemoteRecord) {
      setStatus("Supprimé de PocketBase");
      return;
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
  const normalized = normalizeQuickList(list);
  return {
    ...normalized,
    type: "quickList",
    schemaVersion: REMOTE_SCHEMA_VERSION,
    appVersion: VERSION,
    shared: true,
    items: normalized.items || [],
    updatedAt: normalized.updatedAt || nowISO()
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
    const hadRemoteRecord = Boolean(list.remoteRecordId);
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
    if (!record && hadRemoteRecord) {
      setStatus("Supprimé de PocketBase");
      return;
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
  scheduleRemoteSync(quickListSyncTimers, "quickList", list, options, () => saveQuickListRemote(list));
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

function removeRemoteQuickList(recordId, code) {
  const normalizedCode = cleanCode(code);
  const before = state.quickLists.length;
  state.quickLists = state.quickLists.filter(list => {
    if (recordId && list.remoteRecordId === recordId) return false;
    return !(normalizedCode && cleanCode(list.code) === normalizedCode);
  });
  if (state.quickLists.length === before) return;
  if (!state.quickLists.some(list => list.id === state.currentQuickListId)) {
    state.currentQuickListId = state.quickLists[0]?.id || null;
    if (state.tab === "quickListDetail") state.tab = "quickLists";
  }
  saveLocal();
  render();
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
      if (event.action === "delete") {
        removeRemoteQuickList(event.record?.id || record.id, list.code);
        return;
      }
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
      if (event.action === "delete") {
        removeRemoteVoyage(event.record?.id || record.id, voyage.code);
        return;
      }
      if (event.action !== "update" || !event.record?.data) return;
      receiveRemoteVoyage(event.record.data, event.record.id);
    }, { requestKey: null });
    setStatus("Synchronisé");
  } catch (error) {
    setStatus(voyage.shared ? "Synchronisé" : "Hors ligne");
  }
}

function removeRemoteVoyage(recordId, code) {
  const normalizedCode = cleanCode(code);
  const before = state.voyages.length;
  state.voyages = state.voyages.filter(voyage => {
    if (recordId && voyage.remoteRecordId === recordId) return false;
    return !(normalizedCode && cleanCode(voyage.code) === normalizedCode);
  });
  if (state.voyages.length === before) return;
  if (!state.voyages.some(voyage => voyage.id === state.currentVoyageId)) {
    state.currentVoyageId = state.voyages[0]?.id || null;
    if (state.tab === "liste") state.tab = "home";
  }
  saveLocal();
  render();
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
