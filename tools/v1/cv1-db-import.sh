#!/bin/sh
set -eu

database="${1:-/pb/pb_data/data.db}"
export_sql="${2:-/tmp/cv1-migration/cv1-export.sql}"
tables="cv1_libraries cv1_library_entities cv1_operations cv1_devices cv1_documents cv1_document_access cv1_document_entities cv1_document_operations"

if [ ! -f "$database" ] || [ ! -f "$export_sql" ]; then
  echo "Base cible ou export SQL introuvable." >&2
  exit 2
fi

for table in $tables; do
  count="$(sqlite3 "$database" "SELECT count(*) FROM \"$table\";")"
  if [ "$count" != "0" ]; then
    echo "Import refusé: $table contient déjà $count enregistrement(s)." >&2
    exit 1
  fi
done

sqlite3 "$database" < "$export_sql"

for table in $tables; do
  count="$(sqlite3 -readonly "$database" "SELECT count(*) FROM \"$table\";")"
  echo "$table=$count"
done
