/// <reference path="../pb_data/types.d.ts" />
const CV1_TYPES = ["library_owner", "library_category", "library_item", "context", "context_association"];
const CV1_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function cv1Validate(body) {
  for (const field of ["operation_uuid", "library_uuid", "device_uuid", "entity_uuid"]) {
    if (!CV1_UUID.test(body[field] || "")) throw new BadRequestError("UUID V1 invalide: " + field);
  }
  if (CV1_TYPES.indexOf(body.entity_type) < 0) throw new BadRequestError("Type V1 interdit");
  if (["upsert", "delete"].indexOf(body.operation_type) < 0) throw new BadRequestError("Opération V1 interdite");
  if (body.client_sequence < 1 || body.client_counter < 1 || body.base_revision < 0) throw new BadRequestError("Compteur V1 invalide");
  const payload = body.payload || {};
  if (payload.sync_scope === "personal_local" || payload.kind === "personal") throw new BadRequestError("Personnel ne peut pas être synchronisé");
  if ((body.entity_type === "context" || body.entity_type === "context_association") && payload.sync_scope !== "shared_library" && body.operation_type !== "delete") {
    throw new BadRequestError("Portée de contexte interdite");
  }
}

function cv1Result(record) {
  return {
    operation_uuid: record.getString("operation_uuid"), library_uuid: record.getString("library_uuid"),
    device_uuid: record.getString("device_uuid"), client_sequence: record.getInt("client_sequence"),
    client_counter: record.getInt("client_counter"), base_revision: record.getInt("base_revision"),
    server_revision: record.getInt("server_revision"), entity_type: record.getString("entity_type"),
    entity_uuid: record.getString("entity_uuid"), operation_type: record.getString("operation_type"),
    payload: record.get("payload") || {}, applied: record.getBool("applied"),
    conflict_reason: record.getString("conflict_reason") || null,
  };
}

routerAdd("POST", "/api/cv1/sync/push", (context) => {
  const CV1_TYPES = ["library_owner", "library_category", "library_item", "context", "context_association"];
  const CV1_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const cv1Validate = (body) => {
    for (const field of ["operation_uuid", "library_uuid", "device_uuid", "entity_uuid"]) {
      if (!CV1_UUID.test(body[field] || "")) throw new BadRequestError("UUID V1 invalide: " + field);
    }
    if (CV1_TYPES.indexOf(body.entity_type) < 0) throw new BadRequestError("Type V1 interdit");
    if (["upsert", "delete"].indexOf(body.operation_type) < 0) throw new BadRequestError("Opération V1 interdite");
    if (body.client_sequence < 1 || body.client_counter < 1 || body.base_revision < 0) throw new BadRequestError("Compteur V1 invalide");
    const payload = body.payload || {};
    if (payload.sync_scope === "personal_local" || payload.kind === "personal") throw new BadRequestError("Personnel ne peut pas être synchronisé");
    if ((body.entity_type === "context" || body.entity_type === "context_association") && payload.sync_scope !== "shared_library" && body.operation_type !== "delete") throw new BadRequestError("Portée de contexte interdite");
    if (body.operation_type === "upsert") {
      if (typeof payload.name === "string" && (payload.name.trim().length < 1 || payload.name.length > 200)) throw new BadRequestError("Nom V1 invalide");
      if (body.entity_type === "library_owner" && (["general", "family_member"].indexOf(payload.kind) < 0 || payload.sync_scope !== "shared_library")) throw new BadRequestError("Propriétaire partagé invalide");
      if (body.entity_type === "library_item" && (payload.default_quantity < 1 || payload.default_quantity > 99)) throw new BadRequestError("Quantité V1 invalide");
      if (body.entity_type === "library_category" && !CV1_UUID.test(payload.owner_id || "")) throw new BadRequestError("Parent de catégorie invalide");
      if (body.entity_type === "library_item" && !CV1_UUID.test(payload.category_id || "")) throw new BadRequestError("Parent d'item invalide");
      if (body.entity_type === "context_association" && (!CV1_UUID.test(payload.item_id || "") || !CV1_UUID.test(payload.context_id || ""))) throw new BadRequestError("Association invalide");
    }
  };
  const cv1Result = (record) => ({
    operation_uuid: record.getString("operation_uuid"), library_uuid: record.getString("library_uuid"),
    device_uuid: record.getString("device_uuid"), client_sequence: record.getInt("client_sequence"),
    client_counter: record.getInt("client_counter"), base_revision: record.getInt("base_revision"),
    server_revision: record.getInt("server_revision"), entity_type: record.getString("entity_type"),
    entity_uuid: record.getString("entity_uuid"), operation_type: record.getString("operation_type"),
    payload: record.get("payload") || {}, applied: record.getBool("applied"),
    conflict_reason: record.getString("conflict_reason") || null,
  });
  const body = $apis.requestInfo(context).data;
  cv1Validate(body);
  const rootDao = $app.dao();
  try { return context.json(200, cv1Result(rootDao.findFirstRecordByData("cv1_operations", "operation_uuid", body.operation_uuid))); } catch (_) {}
  let response = null;
  rootDao.runInTransaction((dao) => {
    try { response = cv1Result(dao.findFirstRecordByData("cv1_operations", "operation_uuid", body.operation_uuid)); return; } catch (_) {}
    const requireActive = (type, id) => {
      let parent;
      try {
        parent = dao.findFirstRecordByFilter("cv1_library_entities", "library_uuid = {:library} && entity_type = {:type} && entity_uuid = {:entity}", {
          library: body.library_uuid, type, entity: id,
        });
      } catch (_) { throw new BadRequestError("Parent V1 absent"); }
      if (parent.getString("deleted_at") !== "") throw new BadRequestError("Parent V1 supprimé");
      return parent;
    };
    if (body.operation_type === "upsert") {
      if (body.entity_type === "library_category") requireActive("library_owner", body.payload.owner_id);
      if (body.entity_type === "library_item") requireActive("library_category", body.payload.category_id);
      if (body.entity_type === "context_association") {
        requireActive("library_item", body.payload.item_id);
        requireActive("context", body.payload.context_id);
      }
    }
    let library;
    try { library = dao.findFirstRecordByData("cv1_libraries", "library_uuid", body.library_uuid); }
    catch (_) {
      library = new Record(dao.findCollectionByNameOrId("cv1_libraries"));
      library.set("library_uuid", body.library_uuid); library.set("schema_version", 1); library.set("revision", 0);
    }
    const revision = library.getInt("revision") + 1;
    library.set("revision", revision); library.set("updated_by_device", body.device_uuid); dao.saveRecord(library);

    let current = null;
    try {
      current = dao.findFirstRecordByFilter("cv1_library_entities", "library_uuid = {:library} && entity_type = {:type} && entity_uuid = {:entity}", {
        library: body.library_uuid, type: body.entity_type, entity: body.entity_uuid,
      });
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
      const entity = current || new Record(dao.findCollectionByNameOrId("cv1_library_entities"));
      entity.set("library_uuid", body.library_uuid); entity.set("entity_type", body.entity_type);
      entity.set("entity_uuid", body.entity_uuid); entity.set("payload", body.payload || {});
      entity.set("deleted_at", body.operation_type === "delete" ? new Date().toISOString() : "");
      entity.set("server_revision", revision); entity.set("client_counter", body.client_counter);
      entity.set("device_uuid", body.device_uuid); entity.set("operation_uuid", body.operation_uuid);
      dao.saveRecord(entity);
    }
    const operation = new Record(dao.findCollectionByNameOrId("cv1_operations"));
    for (const field of ["operation_uuid", "library_uuid", "device_uuid", "client_sequence", "client_counter", "base_revision", "entity_type", "entity_uuid", "operation_type", "payload"]) operation.set(field, body[field]);
    operation.set("server_revision", revision); operation.set("applied", applied);
    operation.set("conflict_reason", reason); operation.set("applied_at", new Date().toISOString()); dao.saveRecord(operation);
    let device;
    try { device = dao.findFirstRecordByFilter("cv1_devices", "library_uuid = {:library} && device_uuid = {:device}", { library: body.library_uuid, device: body.device_uuid }); }
    catch (_) {
      device = new Record(dao.findCollectionByNameOrId("cv1_devices"));
      device.set("library_uuid", body.library_uuid); device.set("device_uuid", body.device_uuid);
    }
    device.set("last_ack_revision", revision); device.set("last_seen_at", new Date().toISOString()); dao.saveRecord(device);
    response = cv1Result(operation);
  });
  return context.json(200, response);
});

routerAdd("GET", "/api/cv1/sync/pull", (context) => {
  const CV1_UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
  const cv1Result = (record) => ({
    operation_uuid: record.getString("operation_uuid"), library_uuid: record.getString("library_uuid"),
    device_uuid: record.getString("device_uuid"), client_sequence: record.getInt("client_sequence"),
    client_counter: record.getInt("client_counter"), base_revision: record.getInt("base_revision"),
    server_revision: record.getInt("server_revision"), entity_type: record.getString("entity_type"),
    entity_uuid: record.getString("entity_uuid"), operation_type: record.getString("operation_type"),
    payload: record.get("payload") || {}, applied: record.getBool("applied"),
    conflict_reason: record.getString("conflict_reason") || null,
  });
  const library = context.queryParam("library_uuid") || "";
  if (!CV1_UUID.test(library)) throw new BadRequestError("Bibliothèque V1 invalide");
  const cursor = Math.max(0, parseInt(context.queryParam("after_revision") || "0", 10));
  const limit = Math.min(200, Math.max(1, parseInt(context.queryParam("limit") || "200", 10)));
  const records = $app.dao().findRecordsByFilter("cv1_operations", "library_uuid = {:library} && server_revision > {:cursor}", "+server_revision", limit, 0, { library, cursor });
  const operations = records.map(cv1Result);
  return context.json(200, { operations, cursor: operations.length === 0 ? cursor : operations[operations.length - 1].server_revision });
});
