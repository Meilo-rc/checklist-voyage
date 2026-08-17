# Stratégie PocketBase V1 séparée

> Mise à jour lot 6 : la bibliothèque partagée est désormais implémentée avec
> `cv1_libraries`, `cv1_library_entities`, `cv1_operations` et `cv1_devices`.
> Le protocole réellement déployé est décrit dans `LOT_6_SYNC_BIBLIOTHEQUE.md`.
> Les sections relatives aux futurs documents voyage/liste restent prospectives.

Statut : arbitrages validés, sans création ni modification distante pendant le lot 3.

## 1. Isolation

La collection `travel_checklists` reste inchangée et constitue la source legacy/rollback.

Les noms V1 sont préfixés pour empêcher la Web app 2.63 de les lire ou de les modifier :

- `cv1_libraries` ;
- `cv1_documents` ;
- `cv1_operations` ;
- `cv1_devices`, fondée sur un UUID d'installation stable.

Ces collections utiliseront l'instance PocketBase actuelle. La séparation repose sur le préfixe `cv1_` et sur l'absence totale d'accès V1 à `travel_checklists`, hors lecture contrôlée d'une sauvegarde pendant l'import.

## 2. `cv1_libraries`

Un record représente la partie partagée Général + Famille d'une bibliothèque.

Champs proposés :

- `library_uuid` : texte UUID, index unique ;
- `schema_version` : entier ;
- `revision` : entier attribué côté serveur ;
- `data` : JSON canonique sans contenu Personnel ;
- `deleted_at` : date facultative ;
- champs PocketBase `created` et `updated`.

Personnel n'a aucun record distant.

## 3. `cv1_documents`

Un record par voyage partagé ou liste rapide partagée.

Champs proposés :

- `document_uuid` : texte UUID, index unique ;
- `type` : `trip` ou `quick_list` ;
- `share_code` : texte unique, créé uniquement lors du partage ;
- `schema_version` : entier ;
- `revision` : entier ;
- `data` : JSON canonique de l'agrégat ;
- `deleted_at` : date/tombstone facultatif ;
- champs PocketBase `created` et `updated`.

Un document local n'existe pas dans cette collection.

## 4. `cv1_operations`

Journal idempotent destiné à éviter la double application après timeout ou reconnexion.

Champs proposés :

- `operation_uuid` : unique ;
- relation vers bibliothèque ou document ;
- `device_uuid` ;
- `base_revision` ;
- `result_revision` ;
- `entity_type` et `entity_uuid` ;
- `operation_type` ;
- `payload` JSON ;
- `applied_at` serveur.

La route de synchronisation devra appliquer l'opération et l'incrément de révision dans une transaction PocketBase.

## 5. Migration des données historiques

- `PARAMS` alimente `cv1_libraries` après validation.
- Chaque voyage et liste rapide legacy devient un `cv1_document` avec état local `shared` dans Flutter.
- Les identifiants et codes historiques sont conservés quand ils sont uniques.
- Les records ambigus sont signalés, jamais fusionnés par nom.
- Aucun record legacy n'est supprimé après import.

## 6. Compatibilité

- PWA 2.63 : lecture/écriture de `travel_checklists` uniquement.
- Flutter V1 : lecture du legacy uniquement pendant l'import, puis utilisation des collections `cv1_*`.
- Aucun aller-retour automatique V1 vers le schéma legacy.
- Un export et un rollback restent possibles jusqu'à validation du basculement.

## 7. Arbitrages validés pour la V1

- identité : UUID d'installation stable, sans comptes utilisateurs V1 ;
- compatibilité future : emplacement nullable pour lier ultérieurement une identité utilisateur ;
- tombstones : conservation minimale de 90 jours et purge seulement après garantie de propagation ;
- partage : transition irréversible `local → shared` dans le périmètre V1 ;
- contextes Général et Membres : synchronisés avec la bibliothèque familiale ;
- contextes et associations Personnel : locaux uniquement.
