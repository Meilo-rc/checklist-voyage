# Modèle de données local V1

Statut : modèle local implémenté dans Flutter/Drift. Les collections PocketBase V1 restent à créer dans un lot ultérieur.

## 1. Règles invariantes

- SQLite/Drift est la source de vérité de l'interface Flutter.
- Toutes les nouvelles identités métier sont des UUID.
- Un nom n'est jamais une identité ni une clé de fusion.
- Général et Famille ont une portée `shared_library` et sont synchronisés automatiquement.
- Personnel a une portée `personal_local` et ne produit jamais d'opération distante.
- Un voyage ou une liste rapide commence avec `share_state = local`.
- Le code et l'identifiant PocketBase restent nuls tant que l'utilisateur n'a pas choisi Partager.
- Une entité historique provenant de PocketBase est importée avec `share_state = shared`.
- Un item de voyage est une copie indépendante de la bibliothèque.
- La suppression de cette copie ne modifie jamais son item source.
- Les tombstones sont conservés jusqu'à acquittement et politique de rétention validée.

## 2. Valeurs contrôlées

### Portée de bibliothèque

- `shared_library` : Général ou Famille, synchronisation automatique.
- `personal_local` : Personnel, stockage local uniquement.

### État de partage d'un document

- `local` : aucune existence distante.
- `sharing` : création distante en cours, opération rejouable.
- `shared` : identifiant distant et code confirmés.
- `sync_error` : reste localement utilisable, action distante à reprendre.

### État d'un item de voyage

- `todo` : À préparer.
- `checked` : Prêt.
- `done` : Rangé.

## 3. Agrégats métier

### Bibliothèque

`library_owners` représente un groupe général, un membre familial ou un espace personnel. Une catégorie appartient à un propriétaire, et un item appartient à une catégorie. `generation_role` qualifie explicitement les groupes utilisés comme Essentiels, participant, transport ou logement ; l'identité et la sélection V1 reposent ensuite sur les UUID, jamais sur le libellé. Un propriétaire Personnel peut référencer explicitement son membre participant par `linked_participant_owner_id`.

Les tables préparées sont :

- `library_owners` ;
- `library_categories` ;
- `library_items` ;
- `contexts` ;
- `library_item_contexts`.

Un contexte est un critère transversal et non une catégorie. La même identité de contexte peut être associée à des items Général, Famille et Personnel. Chaque ligne `library_item_contexts` possède son propre UUID et sa propre portée : partagée pour Général/Famille, locale pour Personnel.

### Voyages

- `trips` : identité, destination, dates, archivage manuel, état de partage et informations distantes.
- `trip_members` : copie du membre au moment de la génération, avec référence source facultative.
- `trip_categories` : copie de catégorie, rattachée à Général ou à un membre.
- `trip_items` : nom, quantité et état indépendants de la bibliothèque.
- `trip_item_sources` : une ou plusieurs références stables ayant produit l'item.
- `trip_generation_choices` : participants, transports, logements et contextes explicitement sélectionnés, y compris lorsqu'un choix ne produit aucun item.

`library_items.logical_source_id` vaut l'UUID de l'item lui-même par défaut et peut relier explicitement des représentations historiques d'une même source. La compaction utilise uniquement cette identité. Chaque ligne `trip_item_sources` conserve en plus le type de raison, l'UUID du choix déclencheur et l'item contributeur. Deux items portant le même nom restent distincts si leurs identités logiques diffèrent.

### Listes rapides

- `quick_lists` : identité, nom, archivage manuel et état de partage.
- `quick_list_items` : quantité et état binaire.

### Synchronisation et migration

- `sync_documents` : révision distante confirmée par agrégat.
- `sync_outbox` : opérations locales idempotentes en attente.
- `sync_conflicts` : versions récupérables nécessitant une décision.
- `legacy_id_map` : correspondance entre source Web/PocketBase et UUID V1.
- `migration_history` : source, empreinte, version et résultat de chaque import.

## 4. Identifiants et références legacy

Pour une nouvelle entité V1, l'application génère un UUID v4 une seule fois.

Pour un import PocketBase/Web :

1. utiliser l'identifiant legacy s'il existe comme clé de correspondance, jamais comme nouvel UUID ;
2. rechercher d'abord une entrée dans `legacy_id_map` ;
3. pour l'export PocketBase central, générer un UUID v5 à partir d'un namespace V1 fixe, de l'identifiant du record PocketBase, du type d'entité et de l'identifiant legacy ;
4. si l'identifiant legacy manque, générer une fois un UUID v4 dans le manifeste d'import et conserver le chemin JSON source ;
5. ne jamais produire un UUID depuis le seul libellé ;
6. conserver deux entités différentes si elles ont des identifiants différents, même si leur nom est identique.

## 5. Partage et contraintes locales

Pour `trips` et `quick_lists` :

- `remote_record_id`, `share_code` et `remote_revision` sont nuls avec `share_state = local` ;
- le passage à `sharing` et l'ajout de l'opération de création distante sont atomiques ;
- seul l'acquittement serveur permet le passage à `shared` ;
- une erreur ne détruit jamais le document local ;
- les mutations d'un document local ne sont pas ajoutées à l'outbox distante ;
- après partage, toutes les mutations de cet agrégat sont ajoutées à l'outbox.

Pour la bibliothèque :

- les mutations `shared_library` entrent automatiquement dans l'outbox ;
- les mutations `personal_local` n'y entrent jamais ;
- une contrainte applicative et des tests doivent empêcher toute fuite de Personnel.

Depuis le lot 7, les documents explicitement partagés utilisent ce protocole. Le lot 9 transporte également `archived_at` dans la mutation racine sans modifier les routes PocketBase.

## 6. Dates et révisions

- Dates stockées en UTC ISO-8601 ou en entier Unix selon l'adaptateur Drift retenu.
- `updated_at_local` sert à l'affichage et à l'ordre local.
- `remote_revision` détermine l'ordre canonique des opérations partagées.
- L'heure du téléphone ne tranche pas seule un conflit distant.
- `deleted_at` représente un tombstone ; aucune disparition physique avant acquittement.
- `archived_at` est réversible et ne représente jamais une suppression.

## 7. Schéma SQL de référence

Le fichier `schema_local_v1.sql` décrit les tables, clés étrangères et index de référence. L'implémentation exécutée est déclarée dans `flutter_app/lib/data/local/app_database.dart` et versionnée par les migrations Drift.
