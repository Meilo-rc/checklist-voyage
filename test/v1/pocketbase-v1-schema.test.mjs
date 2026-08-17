import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migrationPath = new URL("../../pocketbase/pb_migrations/2026081701_cv1_library_sync.js", import.meta.url);
const hookPath = new URL("../../pocketbase/pb_hooks/cv1_sync.pb.js", import.meta.url);

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

test("le hook V1 bloque Personnel et ne cible jamais le legacy", async () => {
  const hook = await readFile(hookPath, "utf8");
  assert.match(hook, /payload\.sync_scope === "personal_local"/);
  assert.match(hook, /payload\.kind === "personal"/);
  assert.match(hook, /operation_uuid/);
  assert.match(hook, /runInTransaction/);
  assert.doesNotMatch(hook, /travel_checklists/);
});
