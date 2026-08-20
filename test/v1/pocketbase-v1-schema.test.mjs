import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migrationPath = new URL("../../pocketbase/pb_migrations/2026081701_cv1_library_sync.js", import.meta.url);
const hookPath = new URL("../../pocketbase/pb_hooks/cv1_sync.pb.js", import.meta.url);
const documentsMigrationPath = new URL("../../pocketbase/pb_migrations/2026082001_cv1_shared_documents.js", import.meta.url);
const documentsHookPath = new URL("../../pocketbase/pb_hooks/cv1_documents.pb.js", import.meta.url);

test("le schéma PocketBase V1 est versionné, isolé et verrouillé", async () => {
  const migration = await readFile(migrationPath, "utf8");
  for (const collection of [
    "cv1_libraries",
    "cv1_library_entities",
    "cv1_operations",
    "cv1_devices",
  ]) {
    assert.match(migration, new RegExp(`\\b${collection}\\b`));
  }
  assert.match(migration, /listRule:\s*null/);
  assert.match(migration, /createRule:\s*null/);
  assert.doesNotMatch(migration, /travel_checklists/);
});

test("les documents partagés V1 sont isolés et leurs CRUD verrouillés", async () => {
  const migration = await readFile(documentsMigrationPath, "utf8");
  for (const collection of [
    "cv1_documents",
    "cv1_document_access",
    "cv1_document_entities",
    "cv1_document_operations",
  ]) {
    assert.match(migration, new RegExp(`\\b${collection}\\b`));
  }
  assert.match(migration, /capability_token/);
  assert.match(migration, /share_code/);
  assert.match(migration, /listRule:\s*null/);
  assert.match(migration, /createRule:\s*null/);
  assert.doesNotMatch(migration, /travel_checklists/);
});

test("le hook document exige une capacité et filtre Personnel", async () => {
  const hook = await readFile(documentsHookPath, "utf8");
  assert.match(hook, /x_cv1_capability/);
  assert.match(hook, /randomStringWithAlphabet/);
  assert.match(hook, /source\.source_scope !== "shared_library"/);
  assert.match(hook, /personal_local/);
  assert.match(hook, /runInTransaction/);
  assert.doesNotMatch(hook, /travel_checklists/);
});

test("le hook V1 bloque Personnel et ne cible jamais le legacy", async () => {
  const hook = await readFile(hookPath, "utf8");
  assert.match(hook, /payload\.sync_scope === "personal_local"/);
  assert.match(hook, /payload\.kind === "personal"/);
  assert.match(hook, /operation_uuid/);
  assert.match(hook, /runInTransaction/);
  assert.doesNotMatch(hook, /travel_checklists/);
});
