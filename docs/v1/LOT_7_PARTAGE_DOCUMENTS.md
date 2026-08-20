# Lot 7 — partage explicite des voyages et listes rapides

Date de validation technique : 20 août 2026.

## Comportement livré

Un voyage ou une liste rapide reste local, sans outbox documentaire, jusqu'à
l'action Partager. Le serveur crée alors un document V1, un code humain de huit
caractères et une capacité aléatoire de 64 caractères limitée au document et à
l'UUID d'installation. Rejoindre échange le code contre une capacité propre à
l'installation, récupère le journal, reconstruit Drift et fonctionne ensuite
hors ligne.

Le code n'est affiché que dans le dialogue Partager. Les cartes et en-têtes
affichent seulement l'indicateur Partagé. La transition inverse reste absente.

## Drift v6 et moteur local-first

La migration additive v6 complète `sync_documents` avec `share_code`,
`capability_token` et `pull_cursor`. L'outbox, les compteurs logiques,
`sync_entity_states`, `sync_conflicts` et `sync_tombstones` du lot 6 sont
réutilisés. Les repositories voyage/liste écrivent la mutation locale et
l'opération documentaire dans la même transaction lorsque le parent est
partagé.

Le push est idempotent par `operation_uuid`. Le pull est incrémental par
révision de document et appliqué transactionnellement. L'arbitrage reste :
compteur logique, suppression prioritaire à égalité, puis UUID d'installation.
Une opération perdante est conservée dans le journal et dans `sync_conflicts`.

## Structures PocketBase

Migration `2026082001_cv1_shared_documents.js` :

- `cv1_documents` : type, code unique, révision et installation créatrice ;
- `cv1_document_access` : capacité par document et installation ;
- `cv1_document_entities` : état canonique et tombstones ;
- `cv1_document_operations` : journal idempotent ordonné.

Les CRUD standards sont verrouillés. Les seules routes clientes sont
`share`, `join`, `push` et `pull` sous `/api/cv1/documents/`. La release Fly.io
déployée est `deployment-01M0F4WCM76YT2AY7A18Q4Y9VV`.

## Voyage autonome et Personnel

Le document transporte destination, dates, membres du voyage, catégories,
items, quantités, états, choix de génération et seulement les références de
sources prouvées `shared_library`.

Pour un item issu de Personnel : le nom, la quantité et l'état de la copie du
voyage sont partagés ; l'UUID source, le propriétaire, la catégorie source,
l'icône et les associations/contexte personnels sont exclus. Une catégorie
issue de Personnel est publiée sous le libellé neutre `Divers`. Le serveur
rejette aussi tout payload `personal_local` ou source sans portée partagée.

## Historique 2.63

L'import conserve `share_state = shared`, l'identifiant distant et le code
legacy pour audit. Il n'écrit rien à distance. Lors de la première action
Partager, le document est copié vers V1 avec le même UUID V1 stable et reçoit
un code/capacité V1. `travel_checklists` reste intacte.

## Tombstones et sécurité

Les suppressions partagées utilisent des tombstones éligibles après 90 jours ;
aucune purge physique automatique n'est exécutée. Une capacité est contrôlée
côté serveur et ne fonctionne pas sur un autre document.

Sans compte utilisateur, une personne possédant encore le code humain peut
rejoindre le document. Le code ne peut pas être révoqué au périmètre V1 et les
capacités sont stockées dans la base privée de l'application Android ainsi que
dans une collection serveur verrouillée. Une protection forte contre un
appareil compromis nécessitera une identité et un stockage matériel dédiés.

## Validation

- simulation à deux bases Drift : local par défaut, partage/jointure, voyage,
  liste, hors-ligne, redémarrage, conflits, idempotence, codes et isolation ;
- contrôle négatif Personnel sur les payloads et la copie reçue ;
- PocketBase 0.22.25 local : migration, code/capacité, replay de push,
  CRUD direct `403`, code inconnu `400`, Personnel `400` ;
- PocketBase Fly.io réel : voyage et liste à deux installations réussis ;
- coexistence : santé, legacy, recettes et PWA `200`, CRUD V1 `403`.
