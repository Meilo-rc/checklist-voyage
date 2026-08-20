/// <reference path="../pb_data/types.d.ts" />

routerAdd("POST", "/api/cv1/documents/share", (context) => {
  const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const requestInfo = $apis.requestInfo(context);
  const body = requestInfo.data;
  if (!UUID.test(body.document_uuid || "") || !UUID.test(body.device_uuid || "")) throw new BadRequestError("UUID V1 invalide");
  if (["trip", "quick_list"].indexOf(body.document_type) < 0) throw new BadRequestError("Type de document V1 invalide");
  const dao = $app.dao();
  let result = null;
  dao.runInTransaction((tx) => {
    let document;
    let found = true;
    try {
      document = tx.findFirstRecordByData("cv1_documents", "document_uuid", body.document_uuid);
    } catch (_) { found = false; }
    if (found) {
      if (document.getString("document_type") !== body.document_type || document.getString("created_by_device") !== body.device_uuid) throw new ForbiddenError("Document déjà réservé");
    } else {
      document = new Record(tx.findCollectionByNameOrId("cv1_documents"));
      let code = "";
      for (let attempt = 0; attempt < 20; attempt++) {
        const candidate = $security.randomStringWithAlphabet(8, "ABCDEFGHJKLMNPQRSTUVWXYZ23456789");
        try { tx.findFirstRecordByData("cv1_documents", "share_code", candidate); }
        catch (_) { code = candidate; break; }
      }
      if (code === "") throw new BadRequestError("Code indisponible");
      document.set("document_uuid", body.document_uuid);
      document.set("document_type", body.document_type);
      document.set("share_code", code);
      document.set("revision", 0);
      document.set("created_by_device", body.device_uuid);
      tx.saveRecord(document);
    }
    let access;
    try {
      access = tx.findFirstRecordByFilter("cv1_document_access", "document_uuid = {:document} && device_uuid = {:device}", { document: body.document_uuid, device: body.device_uuid });
    } catch (_) {
      access = new Record(tx.findCollectionByNameOrId("cv1_document_access"));
      access.set("document_uuid", body.document_uuid);
      access.set("device_uuid", body.device_uuid);
      access.set("capability_token", $security.randomString(64));
      access.set("last_ack_revision", document.getInt("revision"));
    }
    access.set("last_seen_at", new Date().toISOString());
    tx.saveRecord(access);
    result = {
      document_uuid: body.document_uuid,
      document_type: document.getString("document_type"),
      share_code: document.getString("share_code"),
      capability_token: access.getString("capability_token"),
      revision: document.getInt("revision"),
    };
  });
  return context.json(200, result);
});

routerAdd("POST", "/api/cv1/documents/join", (context) => {
  const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const CODE = /^[A-Z2-9]{8}$/;
  const body = $apis.requestInfo(context).data;
  const code = (body.share_code || "").toUpperCase();
  if (!CODE.test(code) || !UUID.test(body.device_uuid || "")) throw new BadRequestError("Code de partage invalide");
  const dao = $app.dao();
  let result = null;
  dao.runInTransaction((tx) => {
    let document;
    try { document = tx.findFirstRecordByData("cv1_documents", "share_code", code); }
    catch (_) { throw new BadRequestError("Code de partage invalide"); }
    let access;
    try {
      access = tx.findFirstRecordByFilter("cv1_document_access", "document_uuid = {:document} && device_uuid = {:device}", { document: document.getString("document_uuid"), device: body.device_uuid });
    } catch (_) {
      access = new Record(tx.findCollectionByNameOrId("cv1_document_access"));
      access.set("document_uuid", document.getString("document_uuid"));
      access.set("device_uuid", body.device_uuid);
      access.set("capability_token", $security.randomString(64));
      access.set("last_ack_revision", 0);
    }
    access.set("last_seen_at", new Date().toISOString());
    tx.saveRecord(access);
    result = {
      document_uuid: document.getString("document_uuid"),
      document_type: document.getString("document_type"),
      share_code: document.getString("share_code"),
      capability_token: access.getString("capability_token"),
      revision: document.getInt("revision"),
    };
  });
  return context.json(200, result);
});

routerAdd("POST", "/api/cv1/documents/push", (context) => {
  const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const TYPES = ["trip", "trip_member", "trip_category", "trip_item", "trip_choice", "quick_list", "quick_list_item"];
  const requestInfo = $apis.requestInfo(context);
  const body = requestInfo.data;
  for (const field of ["operation_uuid", "document_uuid", "device_uuid", "entity_uuid"]) {
    if (!UUID.test(body[field] || "")) throw new BadRequestError("UUID V1 invalide: " + field);
  }
  const headerDevice = requestInfo.headers["x_cv1_device"] || "";
  const token = requestInfo.headers["x_cv1_capability"] || "";
  if (headerDevice !== body.device_uuid || token.length < 40) throw new ForbiddenError("Capacité refusée");
  if (TYPES.indexOf(body.entity_type) < 0 || ["upsert", "delete"].indexOf(body.operation_type) < 0) throw new BadRequestError("Opération V1 interdite");
  if (body.client_sequence < 1 || body.client_counter < 1 || body.base_revision < 0) throw new BadRequestError("Compteur V1 invalide");
  const payload = body.payload || {};
  const serialized = JSON.stringify(payload);
  if (serialized.indexOf("personal_local") >= 0 || serialized.indexOf('"kind":"personal"') >= 0 || serialized.indexOf("source_owner_id") >= 0 || serialized.indexOf("source_category_id") >= 0) throw new BadRequestError("Donnée personnelle interdite");
  if (body.operation_type === "upsert") {
    if (typeof payload.name === "string" && (payload.name.trim().length < 1 || payload.name.length > 200)) throw new BadRequestError("Nom V1 invalide");
    if ((body.entity_type === "trip" || body.entity_type === "quick_list") && body.entity_uuid !== body.document_uuid) throw new BadRequestError("Racine V1 invalide");
    if (body.entity_type === "trip_item") {
      if (payload.quantity < 1 || payload.quantity > 99 || ["todo", "checked", "done"].indexOf(payload.status) < 0) throw new BadRequestError("Item de voyage invalide");
      if (!Array.isArray(payload.sources)) throw new BadRequestError("Sources de voyage invalides");
      for (const source of payload.sources) if (source.source_scope !== "shared_library") throw new BadRequestError("Source Personnel interdite");
    }
    if (body.entity_type === "quick_list_item" && (payload.quantity < 1 || payload.quantity > 99 || typeof payload.is_checked !== "boolean")) throw new BadRequestError("Item de liste invalide");
  }
  const resultFor = (record) => ({
    operation_uuid: record.getString("operation_uuid"), document_uuid: record.getString("document_uuid"),
    device_uuid: record.getString("device_uuid"), client_sequence: record.getInt("client_sequence"),
    client_counter: record.getInt("client_counter"), base_revision: record.getInt("base_revision"),
    server_revision: record.getInt("server_revision"), entity_type: record.getString("entity_type"),
    entity_uuid: record.getString("entity_uuid"), operation_type: record.getString("operation_type"),
    payload: record.get("payload") || {}, applied: record.getBool("applied"),
    conflict_reason: record.getString("conflict_reason") || null,
  });
  const rootDao = $app.dao();
  let access;
  try {
    access = rootDao.findFirstRecordByFilter("cv1_document_access", "document_uuid = {:document} && device_uuid = {:device} && capability_token = {:token}", { document: body.document_uuid, device: body.device_uuid, token });
  } catch (_) { throw new ForbiddenError("Capacité refusée"); }
  try { return context.json(200, resultFor(rootDao.findFirstRecordByData("cv1_document_operations", "operation_uuid", body.operation_uuid))); } catch (_) {}
  let response = null;
  rootDao.runInTransaction((dao) => {
    try { response = resultFor(dao.findFirstRecordByData("cv1_document_operations", "operation_uuid", body.operation_uuid)); return; } catch (_) {}
    let document;
    try { document = dao.findFirstRecordByData("cv1_documents", "document_uuid", body.document_uuid); }
    catch (_) { throw new BadRequestError("Document V1 absent"); }
    if ((document.getString("document_type") === "trip") !== (body.entity_type.indexOf("trip") === 0)) throw new BadRequestError("Type incompatible");
    const requireActive = (type, id) => {
      if (!UUID.test(id || "")) throw new BadRequestError("Parent V1 invalide");
      let parent;
      try {
        parent = dao.findFirstRecordByFilter("cv1_document_entities", "document_uuid = {:document} && entity_type = {:type} && entity_uuid = {:entity}", { document: body.document_uuid, type, entity: id });
      } catch (_) { throw new BadRequestError("Parent V1 absent"); }
      if (parent.getString("deleted_at") !== "") throw new BadRequestError("Parent V1 supprimé");
    };
    if (body.operation_type === "upsert") {
      if (body.entity_type === "trip_member") requireActive("trip", payload.trip_id);
      if (body.entity_type === "trip_category") {
        requireActive("trip", payload.trip_id);
        if (payload.member_id) requireActive("trip_member", payload.member_id);
      }
      if (body.entity_type === "trip_item") {
        requireActive("trip", payload.trip_id);
        requireActive("trip_category", payload.category_id);
      }
      if (body.entity_type === "trip_choice") requireActive("trip", payload.trip_id);
      if (body.entity_type === "quick_list_item") requireActive("quick_list", payload.quick_list_id);
    }
    const revision = document.getInt("revision") + 1;
    document.set("revision", revision);
    dao.saveRecord(document);
    let current = null;
    try {
      current = dao.findFirstRecordByFilter("cv1_document_entities", "document_uuid = {:document} && entity_type = {:type} && entity_uuid = {:entity}", { document: body.document_uuid, type: body.entity_type, entity: body.entity_uuid });
    } catch (_) {}
    let applied = current === null;
    let reason = "";
    if (current !== null) {
      const deleted = current.getString("deleted_at") !== "";
      if (deleted && body.operation_type !== "delete") reason = "tombstone_wins";
      else if (body.client_counter > current.getInt("client_counter")) applied = true;
      else if (body.client_counter === current.getInt("client_counter")) {
        const incomingDelete = body.operation_type === "delete";
        if (incomingDelete !== deleted) applied = incomingDelete;
        else applied = body.device_uuid > current.getString("device_uuid");
        if (!applied) reason = "deterministic_clock_lost";
      } else reason = "deterministic_clock_lost";
    }
    if (applied) {
      const entity = current || new Record(dao.findCollectionByNameOrId("cv1_document_entities"));
      entity.set("document_uuid", body.document_uuid); entity.set("entity_type", body.entity_type);
      entity.set("entity_uuid", body.entity_uuid); entity.set("payload", payload);
      entity.set("deleted_at", body.operation_type === "delete" ? new Date().toISOString() : "");
      entity.set("server_revision", revision); entity.set("client_counter", body.client_counter);
      entity.set("device_uuid", body.device_uuid); entity.set("operation_uuid", body.operation_uuid);
      dao.saveRecord(entity);
    }
    const operation = new Record(dao.findCollectionByNameOrId("cv1_document_operations"));
    for (const field of ["operation_uuid", "document_uuid", "device_uuid", "client_sequence", "client_counter", "base_revision", "entity_type", "entity_uuid", "operation_type", "payload"]) operation.set(field, body[field]);
    operation.set("server_revision", revision); operation.set("applied", applied);
    operation.set("conflict_reason", reason); operation.set("applied_at", new Date().toISOString());
    dao.saveRecord(operation);
    access = dao.findFirstRecordByFilter("cv1_document_access", "document_uuid = {:document} && device_uuid = {:device}", { document: body.document_uuid, device: body.device_uuid });
    access.set("last_ack_revision", revision); access.set("last_seen_at", new Date().toISOString()); dao.saveRecord(access);
    response = resultFor(operation);
  });
  return context.json(200, response);
});

routerAdd("GET", "/api/cv1/documents/pull", (context) => {
  const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const documentId = context.queryParam("document_uuid") || "";
  const requestInfo = $apis.requestInfo(context);
  const deviceId = requestInfo.headers["x_cv1_device"] || "";
  const token = requestInfo.headers["x_cv1_capability"] || "";
  if (!UUID.test(documentId) || !UUID.test(deviceId) || token.length < 40) throw new ForbiddenError("Capacité refusée");
  const dao = $app.dao();
  let access;
  try {
    access = dao.findFirstRecordByFilter("cv1_document_access", "document_uuid = {:document} && device_uuid = {:device} && capability_token = {:token}", { document: documentId, device: deviceId, token });
  } catch (_) { throw new ForbiddenError("Capacité refusée"); }
  const cursor = Math.max(0, parseInt(context.queryParam("after_revision") || "0", 10));
  const limit = Math.min(200, Math.max(1, parseInt(context.queryParam("limit") || "200", 10)));
  const records = dao.findRecordsByFilter("cv1_document_operations", "document_uuid = {:document} && server_revision > {:cursor}", "+server_revision", limit, 0, { document: documentId, cursor });
  const operations = records.map((record) => ({
    operation_uuid: record.getString("operation_uuid"), document_uuid: record.getString("document_uuid"),
    device_uuid: record.getString("device_uuid"), client_sequence: record.getInt("client_sequence"),
    client_counter: record.getInt("client_counter"), base_revision: record.getInt("base_revision"),
    server_revision: record.getInt("server_revision"), entity_type: record.getString("entity_type"),
    entity_uuid: record.getString("entity_uuid"), operation_type: record.getString("operation_type"),
    payload: record.get("payload") || {}, applied: record.getBool("applied"),
    conflict_reason: record.getString("conflict_reason") || null,
  }));
  const nextCursor = operations.length === 0 ? cursor : operations[operations.length - 1].server_revision;
  access.set("last_ack_revision", nextCursor); access.set("last_seen_at", new Date().toISOString()); dao.saveRecord(access);
  return context.json(200, { operations, cursor: nextCursor });
});
