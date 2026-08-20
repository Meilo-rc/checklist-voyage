#!/bin/sh
set -eu

database="${1:-/pb/pb_data/data.db}"
output="${2:-/tmp/cv1-migration}"
tables="cv1_libraries cv1_library_entities cv1_operations cv1_devices cv1_documents cv1_document_access cv1_document_entities cv1_document_operations"

if [ ! -f "$database" ]; then
  echo "Base PocketBase introuvable." >&2
  exit 2
fi
if [ -e "$output" ]; then
  echo "Le répertoire de sortie existe déjà; aucun écrasement." >&2
  exit 2
fi

umask 077
mkdir -p "$output"

for table in $tables; do
  exists="$(sqlite3 -readonly "$database" "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$table';")"
  if [ "$exists" != "1" ]; then
    echo "Table attendue absente: $table" >&2
    exit 1
  fi
  sqlite3 -readonly "$database" ".headers on" ".mode json" "SELECT * FROM \"$table\" ORDER BY id;" > "$output/$table.json"
done

{
  echo "PRAGMA foreign_keys=OFF;"
  echo "PRAGMA busy_timeout=10000;"
  echo "BEGIN IMMEDIATE;"
  for table in $tables; do
    sqlite3 -readonly "$database" ".mode insert $table" "SELECT * FROM \"$table\" ORDER BY id;"
  done
  echo "COMMIT;"
} > "$output/cv1-export.sql"

sql_sha256="$(sha256sum "$output/cv1-export.sql" | awk '{print $1}')"
{
  printf '{\n  "schema": "checklist-v1-targeted-export-1",\n'
  printf '  "sql_sha256": "%s",\n' "$sql_sha256"
  printf '  "counts": {\n'
  first="1"
  for table in $tables; do
    count="$(sqlite3 -readonly "$database" "SELECT count(*) FROM \"$table\";")"
    if [ "$first" = "0" ]; then
      printf ',\n'
    fi
    printf '    "%s": %s' "$table" "$count"
    first="0"
  done
  printf '\n  },\n'
  printf '  "checks": {\n'
  printf '    "library_tombstones": %s,\n' "$(sqlite3 -readonly "$database" "SELECT count(*) FROM cv1_library_entities WHERE deleted_at <> '';" )"
  printf '    "document_tombstones": %s,\n' "$(sqlite3 -readonly "$database" "SELECT count(*) FROM cv1_document_entities WHERE deleted_at <> '';" )"
  printf '    "unapplied_library_operations": %s,\n' "$(sqlite3 -readonly "$database" "SELECT count(*) FROM cv1_operations WHERE applied = 0;" )"
  printf '    "unapplied_document_operations": %s,\n' "$(sqlite3 -readonly "$database" "SELECT count(*) FROM cv1_document_operations WHERE applied = 0;" )"
  printf '    "share_codes": %s,\n' "$(sqlite3 -readonly "$database" "SELECT count(*) FROM cv1_documents WHERE share_code <> '';" )"
  printf '    "capabilities": %s\n' "$(sqlite3 -readonly "$database" "SELECT count(*) FROM cv1_document_access WHERE capability_token <> '';" )"
  printf '  }\n}\n'
} > "$output/manifest.json"

echo "Export ciblé créé: $output"
echo "Empreinte SHA-256: $sql_sha256"
