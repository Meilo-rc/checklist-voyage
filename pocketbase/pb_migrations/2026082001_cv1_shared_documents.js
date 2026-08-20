/// <reference path="../pb_data/types.d.ts" />
migrate((db) => {
  const text = (id, name, required = true, max = 36) => ({
    id, name, type: "text", system: false, required, unique: false,
    presentable: false, options: { min: required ? 1 : null, max, pattern: "" },
  });
  const number = (id, name, min = 0) => ({
    id, name, type: "number", system: false, required: true, unique: false,
    presentable: false, options: { min, max: null, noDecimal: true },
  });
  const select = (id, name, values) => ({
    id, name, type: "select", system: false, required: true, unique: false,
    presentable: false, options: { maxSelect: 1, values },
  });
  const json = (id, name) => ({
    id, name, type: "json", system: false, required: false, unique: false,
    presentable: false, options: { maxSize: 131072 },
  });
  const date = (id, name, required = false) => ({
    id, name, type: "date", system: false, required, unique: false,
    presentable: false, options: { min: "", max: "" },
  });
  const boolean = (id, name) => ({
    id, name, type: "bool", system: false, required: true, unique: false,
    presentable: false, options: {},
  });
  const collection = (id, name, schema, indexes) => new Collection({
    id, name, type: "base", system: false, schema, indexes,
    listRule: null, viewRule: null, createRule: null, updateRule: null,
    deleteRule: null, options: {},
  });

  const documentTypes = ["trip", "quick_list"];
  const entityTypes = [
    "trip", "trip_member", "trip_category", "trip_item", "trip_choice",
    "quick_list", "quick_list_item",
  ];
  const documents = collection("cv1documents01", "cv1_documents", [
    text("cv1docuuid00001", "document_uuid"),
    select("cv1doctype00001", "document_type", documentTypes),
    text("cv1doccode00001", "share_code", true, 8),
    number("cv1docrevision1", "revision"),
    text("cv1doccreator01", "created_by_device"),
    text("cv1docfuture001", "future_user_uuid", false),
  ], [
    "CREATE UNIQUE INDEX `idx_cv1_documents_uuid` ON `cv1_documents` (`document_uuid`)",
    "CREATE UNIQUE INDEX `idx_cv1_documents_code` ON `cv1_documents` (`share_code`)",
  ]);
  const access = collection("cv1docaccess01", "cv1_document_access", [
    text("cv1accdocument1", "document_uuid"),
    text("cv1accdevice001", "device_uuid"),
    text("cv1acctoken0001", "capability_token", true, 160),
    number("cv1accrevision1", "last_ack_revision"),
    date("cv1acclastseen1", "last_seen_at", true),
    text("cv1accfuture001", "future_user_uuid", false),
  ], [
    "CREATE UNIQUE INDEX `idx_cv1_access_identity` ON `cv1_document_access` (`document_uuid`, `device_uuid`)",
    "CREATE UNIQUE INDEX `idx_cv1_access_token` ON `cv1_document_access` (`capability_token`)",
  ]);
  const entities = collection("cv1docentity01", "cv1_document_entities", [
    text("cv1dentdocument", "document_uuid"),
    select("cv1denttype001", "entity_type", entityTypes),
    text("cv1dentuuid001", "entity_uuid"),
    json("cv1dentpayload1", "payload"),
    date("cv1dentdeleted1", "deleted_at"),
    number("cv1dentrevision", "server_revision", 1),
    number("cv1dentcounter1", "client_counter", 1),
    text("cv1dentdevice01", "device_uuid"),
    text("cv1dentoperat1", "operation_uuid"),
  ], [
    "CREATE UNIQUE INDEX `idx_cv1_document_entities_identity` ON `cv1_document_entities` (`document_uuid`, `entity_type`, `entity_uuid`)",
    "CREATE INDEX `idx_cv1_document_entities_revision` ON `cv1_document_entities` (`document_uuid`, `server_revision`)",
  ]);
  const operations = collection("cv1docoperat01", "cv1_document_operations", [
    text("cv1dopuuid0001", "operation_uuid"),
    text("cv1dopdocument", "document_uuid"),
    text("cv1dopdevice01", "device_uuid"),
    number("cv1dopsequence", "client_sequence", 1),
    number("cv1dopcounter1", "client_counter", 1),
    number("cv1dopbase0001", "base_revision"),
    number("cv1dopserver01", "server_revision", 1),
    select("cv1doptype0001", "entity_type", entityTypes),
    text("cv1dopentity01", "entity_uuid"),
    select("cv1dopkind0001", "operation_type", ["upsert", "delete"]),
    json("cv1doppayload1", "payload"),
    boolean("cv1dopapplied1", "applied"),
    text("cv1dopconflict", "conflict_reason", false, 80),
    date("cv1dopat000001", "applied_at", true),
  ], [
    "CREATE UNIQUE INDEX `idx_cv1_document_operations_uuid` ON `cv1_document_operations` (`operation_uuid`)",
    "CREATE UNIQUE INDEX `idx_cv1_document_operations_revision` ON `cv1_document_operations` (`document_uuid`, `server_revision`)",
    "CREATE INDEX `idx_cv1_document_operations_device_sequence` ON `cv1_document_operations` (`document_uuid`, `device_uuid`, `client_sequence`)",
  ]);

  const dao = new Dao(db);
  dao.saveCollection(documents);
  dao.saveCollection(access);
  dao.saveCollection(entities);
  return dao.saveCollection(operations);
}, (db) => {
  const dao = new Dao(db);
  for (const id of ["cv1docoperat01", "cv1docentity01", "cv1docaccess01", "cv1documents01"]) {
    try { dao.deleteCollection(dao.findCollectionByNameOrId(id)); } catch (_) {}
  }
});
