-- Contrat de schéma V1, mis à jour avec le schéma Drift utilisé au lot 4.
PRAGMA foreign_keys = ON;

CREATE TABLE library_owners (
  id TEXT PRIMARY KEY,
  kind TEXT NOT NULL CHECK (kind IN ('general', 'family_member', 'personal')),
  sync_scope TEXT NOT NULL CHECK (sync_scope IN ('shared_library', 'personal_local')),
  generation_role TEXT NOT NULL DEFAULT 'general' CHECK (generation_role IN ('general', 'essential', 'participant', 'transport', 'lodging')),
  name TEXT NOT NULL,
  icon TEXT,
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE library_categories (
  id TEXT PRIMARY KEY,
  owner_id TEXT NOT NULL REFERENCES library_owners(id),
  name TEXT NOT NULL,
  icon TEXT,
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE library_items (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL REFERENCES library_categories(id),
  name TEXT NOT NULL,
  default_quantity INTEGER NOT NULL DEFAULT 1 CHECK (default_quantity BETWEEN 1 AND 99),
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE contexts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  sync_scope TEXT NOT NULL CHECK (sync_scope IN ('shared_library', 'personal_local')),
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE library_item_contexts (
  item_id TEXT NOT NULL REFERENCES library_items(id),
  context_id TEXT NOT NULL REFERENCES contexts(id),
  created_at TEXT NOT NULL,
  deleted_at TEXT,
  PRIMARY KEY (item_id, context_id)
);

CREATE TABLE trips (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  destination_json TEXT,
  start_date TEXT,
  end_date TEXT,
  share_state TEXT NOT NULL DEFAULT 'local' CHECK (share_state IN ('local', 'sharing', 'shared', 'sync_error')),
  remote_record_id TEXT,
  share_code TEXT,
  remote_revision INTEGER,
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT,
  CHECK (share_state != 'local' OR (remote_record_id IS NULL AND share_code IS NULL))
);

CREATE TABLE trip_members (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL REFERENCES trips(id),
  source_owner_id TEXT,
  group_kind TEXT NOT NULL CHECK (group_kind IN ('general', 'family')),
  name TEXT NOT NULL,
  icon TEXT,
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE trip_categories (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL REFERENCES trips(id),
  member_id TEXT REFERENCES trip_members(id),
  source_category_id TEXT,
  name TEXT NOT NULL,
  icon TEXT,
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE trip_items (
  id TEXT PRIMARY KEY,
  trip_id TEXT NOT NULL REFERENCES trips(id),
  category_id TEXT NOT NULL REFERENCES trip_categories(id),
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity BETWEEN 1 AND 99),
  status TEXT NOT NULL DEFAULT 'todo' CHECK (status IN ('todo', 'checked', 'done')),
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE trip_item_sources (
  trip_item_id TEXT NOT NULL REFERENCES trip_items(id),
  source_library_item_id TEXT NOT NULL,
  source_kind TEXT NOT NULL CHECK (source_kind IN ('essential', 'participant', 'transport', 'lodging', 'context', 'manual')),
  PRIMARY KEY (trip_item_id, source_library_item_id, source_kind)
);

CREATE TABLE quick_lists (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  share_state TEXT NOT NULL DEFAULT 'local' CHECK (share_state IN ('local', 'sharing', 'shared', 'sync_error')),
  remote_record_id TEXT,
  share_code TEXT,
  remote_revision INTEGER,
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT,
  CHECK (share_state != 'local' OR (remote_record_id IS NULL AND share_code IS NULL))
);

CREATE TABLE quick_list_items (
  id TEXT PRIMARY KEY,
  quick_list_id TEXT NOT NULL REFERENCES quick_lists(id),
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity BETWEEN 1 AND 99),
  is_checked INTEGER NOT NULL DEFAULT 0 CHECK (is_checked IN (0, 1)),
  created_at TEXT NOT NULL,
  updated_at_local TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE sync_documents (
  document_id TEXT PRIMARY KEY,
  document_type TEXT NOT NULL CHECK (document_type IN ('library', 'trip', 'quick_list')),
  remote_record_id TEXT,
  confirmed_revision INTEGER NOT NULL DEFAULT 0,
  last_synced_at TEXT,
  last_error TEXT
);

CREATE TABLE sync_outbox (
  operation_id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation_type TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  base_revision INTEGER,
  attempts INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  next_attempt_at TEXT,
  last_error TEXT
);

CREATE TABLE sync_conflicts (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  local_json TEXT,
  remote_json TEXT,
  detected_at TEXT NOT NULL,
  resolved_at TEXT,
  resolution TEXT
);

CREATE TABLE legacy_id_map (
  source_kind TEXT NOT NULL,
  source_record_id TEXT NOT NULL DEFAULT '',
  entity_type TEXT NOT NULL,
  legacy_id TEXT NOT NULL,
  v1_uuid TEXT NOT NULL UNIQUE,
  json_path TEXT,
  PRIMARY KEY (source_kind, source_record_id, entity_type, legacy_id)
);

CREATE TABLE migration_history (
  id TEXT PRIMARY KEY,
  source_kind TEXT NOT NULL,
  source_sha256 TEXT NOT NULL,
  source_schema TEXT,
  imported_at TEXT NOT NULL,
  report_json TEXT NOT NULL,
  UNIQUE (source_kind, source_sha256)
);

CREATE UNIQUE INDEX idx_trips_remote_record ON trips(remote_record_id) WHERE remote_record_id IS NOT NULL;
CREATE UNIQUE INDEX idx_trips_share_code ON trips(share_code) WHERE share_code IS NOT NULL;
CREATE UNIQUE INDEX idx_quick_remote_record ON quick_lists(remote_record_id) WHERE remote_record_id IS NOT NULL;
CREATE UNIQUE INDEX idx_quick_share_code ON quick_lists(share_code) WHERE share_code IS NOT NULL;
CREATE INDEX idx_library_categories_owner ON library_categories(owner_id);
CREATE INDEX idx_library_items_category ON library_items(category_id);
CREATE INDEX idx_trip_members_trip ON trip_members(trip_id);
CREATE INDEX idx_trip_categories_trip ON trip_categories(trip_id);
CREATE INDEX idx_trip_items_trip ON trip_items(trip_id);
CREATE INDEX idx_outbox_document_created ON sync_outbox(document_id, created_at);
