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
    presentable: false, options: { maxSize: 65536 },
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

  const types = ["library_owner", "library_category", "library_item", "context", "context_association"];
  const libraries = collection("cv1libraries01", "cv1_libraries", [
    text("cv1libuuid00001", "library_uuid"),
    number("cv1libschema001", "schema_version", 1),
    number("cv1librevision1", "revision"),
    text("cv1libdevice001", "updated_by_device", false),
    text("cv1libfuture001", "future_user_uuid", false),
  ], ["CREATE UNIQUE INDEX `idx_cv1_libraries_uuid` ON `cv1_libraries` (`library_uuid`)"]);
  const entities = collection("cv1entities001", "cv1_library_entities", [
    text("cv1entlibrary01", "library_uuid"), select("cv1enttype0001", "entity_type", types),
    text("cv1entuuid0001", "entity_uuid"), json("cv1entpayload01", "payload"),
    date("cv1entdeleted01", "deleted_at"), number("cv1entrevision", "server_revision", 1),
    number("cv1entcounter01", "client_counter", 1), text("cv1entdevice01", "device_uuid"),
    text("cv1entoperatio", "operation_uuid"),
  ], [
    "CREATE UNIQUE INDEX `idx_cv1_entities_identity` ON `cv1_library_entities` (`library_uuid`, `entity_type`, `entity_uuid`)",
    "CREATE INDEX `idx_cv1_entities_revision` ON `cv1_library_entities` (`library_uuid`, `server_revision`)",
  ]);
  const operations = collection("cv1operations1", "cv1_operations", [
    text("cv1opuuid000001", "operation_uuid"), text("cv1oplibrary001", "library_uuid"),
    text("cv1opdevice0001", "device_uuid"), number("cv1opsequence01", "client_sequence", 1),
    number("cv1opcounter001", "client_counter", 1), number("cv1opbase000001", "base_revision"),
    number("cv1opserver0001", "server_revision", 1), select("cv1optype000001", "entity_type", types),
    text("cv1opentity0001", "entity_uuid"), select("cv1opkind000001", "operation_type", ["upsert", "delete"]),
    json("cv1oppayload001", "payload"), boolean("cv1opapplied001", "applied"),
    text("cv1opconflict01", "conflict_reason", false, 80), date("cv1opat0000001", "applied_at", true),
  ], [
    "CREATE UNIQUE INDEX `idx_cv1_operations_uuid` ON `cv1_operations` (`operation_uuid`)",
    "CREATE UNIQUE INDEX `idx_cv1_operations_revision` ON `cv1_operations` (`library_uuid`, `server_revision`)",
    "CREATE INDEX `idx_cv1_operations_device_sequence` ON `cv1_operations` (`library_uuid`, `device_uuid`, `client_sequence`)",
  ]);
  const devices = collection("cv1devices0001", "cv1_devices", [
    text("cv1devlibrary01", "library_uuid"), text("cv1devuuid00001", "device_uuid"),
    number("cv1devrevision", "last_ack_revision"), date("cv1devlastseen1", "last_seen_at", true),
    text("cv1devfuture001", "future_user_uuid", false),
  ], ["CREATE UNIQUE INDEX `idx_cv1_devices_identity` ON `cv1_devices` (`library_uuid`, `device_uuid`)"]);

  const dao = new Dao(db);
  dao.saveCollection(libraries);
  dao.saveCollection(entities);
  dao.saveCollection(operations);
  return dao.saveCollection(devices);
}, (db) => {
  const dao = new Dao(db);
  for (const id of ["cv1devices0001", "cv1operations1", "cv1entities001", "cv1libraries01"]) {
    try { dao.deleteCollection(dao.findCollectionByNameOrId(id)); } catch (_) {}
  }
});
