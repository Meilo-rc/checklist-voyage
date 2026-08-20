import { readFile } from "node:fs/promises";
import { resolve } from "node:path";

function argument(name, fallback = "") {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : fallback;
}

const exportDir = resolve(argument("--export-dir"));
const baseUrl = argument("--url");
if (!baseUrl || !argument("--export-dir")) {
  throw new Error("Usage: node tools/v1/cv1-migrated-backend-check.mjs --export-dir <dossier> --url <url>");
}
if (new URL(baseUrl).hostname === "psyco.fly.dev") {
  throw new Error("Ce contrôle est interdit sur le backend de production psyco.");
}

const load = async (table) => JSON.parse(await readFile(resolve(exportDir, `${table}.json`), "utf8"));
const libraries = await load("cv1_libraries");
const libraryOperations = await load("cv1_operations");
const documents = await load("cv1_documents");
const access = await load("cv1_document_access");
const documentOperations = await load("cv1_document_operations");

for (const library of libraries) {
  const url = new URL("/api/cv1/sync/pull", baseUrl);
  url.searchParams.set("library_uuid", library.library_uuid);
  url.searchParams.set("after_revision", "0");
  url.searchParams.set("limit", "200");
  const response = await fetch(url);
  if (!response.ok) throw new Error(`Pull bibliothèque refusé: HTTP ${response.status}`);
  const result = await response.json();
  const expected = libraryOperations.filter((row) => row.library_uuid === library.library_uuid);
  if (result.operations.length !== expected.length) throw new Error("Journal bibliothèque migré incomplet.");
}

for (const document of documents) {
  const documentAccess = access.filter((row) => row.document_uuid === document.document_uuid);
  if (documentAccess.length === 0) throw new Error("Document migré sans capacité.");
  const credential = documentAccess[0];
  const url = new URL("/api/cv1/documents/pull", baseUrl);
  url.searchParams.set("document_uuid", document.document_uuid);
  url.searchParams.set("after_revision", "0");
  url.searchParams.set("limit", "200");
  const response = await fetch(url, {
    headers: {
      "x-cv1-device": credential.device_uuid,
      "x-cv1-capability": credential.capability_token,
    },
  });
  if (!response.ok) throw new Error(`Capacité migrée refusée: HTTP ${response.status}`);
  const result = await response.json();
  const expected = documentOperations.filter((row) => row.document_uuid === document.document_uuid);
  if (result.operations.length !== expected.length) throw new Error("Journal document migré incomplet.");

  const join = await fetch(new URL("/api/cv1/documents/join", baseUrl), {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify({ share_code: document.share_code, device_uuid: credential.device_uuid }),
  });
  if (!join.ok) throw new Error(`Code migré refusé: HTTP ${join.status}`);
  const joined = await join.json();
  if (joined.share_code !== document.share_code || joined.capability_token !== credential.capability_token) {
    throw new Error("Le code ou la capacité existante a été régénéré.");
  }
}

const unappliedLibrary = libraryOperations.filter((row) => Number(row.applied) === 0).length;
const unappliedDocuments = documentOperations.filter((row) => Number(row.applied) === 0).length;
console.log(JSON.stringify({
  libraries: libraries.length,
  documents: documents.length,
  migratedCodesAccepted: documents.length,
  migratedCapabilitiesAccepted: documents.length,
  unappliedLibraryOperations: unappliedLibrary,
  unappliedDocumentOperations: unappliedDocuments,
}, null, 2));
