# Modèle de données local V1

Statut : modèle cible validable avant création du projet Flutter. Aucune table n'est encore créée sur un appareil ou dans PocketBase.

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

`library_owners` représente un groupe général, un membre familial ou un espace personnel. Une catégorie appartient à un propriétaire, et un item appartient à une catégorie.

Les tables préparées sont :

- `library_owners` ;
- `library_categories` ;
- `library_items` ;
- `contexts` ;
- `library_item_contexts`.

Les contextes et leur table d'association sont réservés dans le modèle, mais leur comportement n'est pas implémenté dans les lots 0 à 2.

### Voyages

- `trips` : identité, destination, dates, état de partage et informations distantes.
- `trip_members` : copie du membre au moment de la génération, avec référence source facultative.
- `trip_categories` : copie de catégorie, rattachée à Général ou à un membre.
- `trip_items` : nom, quantité et état indépendants de la bibliothèque.
- `trip_item_sources` : une ou plusieurs références stables ayant produit l'item.

`trip_item_sources` prépare la compaction future. Le même item source sélectionné par plusieurs chemins ne crée qu'une instance de voyage. Deux items différents portant le même nom restent distincts.

### Listes rapides

- `quick_lists` : identité, nom et état de partage.
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

## 6. Dates et révisions

- Dates stockées en UTC ISO-8601 ou en entier Unix selon l'adaptateur Drift retenu.
- `updated_at_local` sert à l'affichage et à l'ordre local.
- `remote_revision` détermine l'ordre canonique des opérations partagées.
- L'heure du téléphone ne tranche pas seule un conflit distant.
- `deleted_at` représente un tombstone ; aucune disparition physique avant acquittement.

## 7. Schéma SQL de référence

Le fichier `schema_local_v1.sql` décrit les tables, clés étrangères et index proposés. Il sert de contrat pour la future implémentation Drift ; il n'est pas appliqué dans les lots 0 à 2.
