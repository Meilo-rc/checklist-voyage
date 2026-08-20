# Stratégie de migration Web 2.63 vers V1

Cette stratégie ne modifie ni `travel_checklists` ni le `localStorage` actuel. Elle décrit le futur importeur Flutter et ses contrôles.

## 1. Sources d'autorité

- Export PocketBase frais : Général, Famille et documents partagés historiques.
- Export Web local de chaque appareil : Personnel et éventuelles données locales non présentes à distance.
- Web app 2.63 : référence fonctionnelle et outil de contrôle visuel.
- `legacy_id_map` et manifeste d'import : autorité de correspondance des identifiants.

## 2. Préparation

1. Vérifier toutes les sauvegardes avec `backup-verify.mjs`.
2. Conserver leurs empreintes SHA-256.
3. Créer une copie anonymisée pour les tests automatisés.
4. Produire un inventaire avant migration : records, voyages, listes, membres, catégories, items et tombstones.
5. Ne jamais travailler directement depuis l'API de production pendant le développement de l'importeur.

## 3. Conversion de la bibliothèque

### Général et Famille

- Source principale : record `PARAMS` de l'export PocketBase.
- Convertir membres, catégories et items vers les tables `library_*`.
- Attribuer `sync_scope = shared_library`.
- Conserver `updatedAt`, `deletedAt`, quantités, icônes et alias utiles.
- Créer les correspondances d'identifiants dans `legacy_id_map`.

### Personnel

- Source : export local de l'appareil concerné.
- Attribuer `sync_scope = personal_local`.
- Ne créer aucune opération d'outbox.
- Ne jamais inclure ces lignes dans un payload PocketBase.
- Si plusieurs appareils possèdent des espaces Personnel différents, les importer séparément sur chaque appareil ; aucune fusion automatique inter-appareils.

## 4. Conversion des voyages et listes rapides

### Documents présents dans PocketBase

- Ils sont considérés comme historiquement partagés.
- `share_state = shared`.
- Conserver `remote_record_id` et le code existant.
- Conserver une référence vers le record legacy pour audit et rollback.
- Ne pas considérer le code 2.63 comme une capacité V1 active. La première
  action Partager copie le document vers `cv1_documents`, conserve son UUID V1
  stable et reçoit un nouveau code/capacité sans écrire dans le legacy.

### Documents uniquement locaux

- `share_state = local`.
- `remote_record_id = null` et `share_code = null` dans le modèle V1.
- Le code legacy éventuellement généré mais jamais publié est conservé uniquement dans le rapport d'import, pas comme code actif V1.

### Rapprochement entre export local et PocketBase

Ordre autorisé :

1. `remoteRecordId` exact ;
2. record PocketBase associé au code, seulement si ce code est unique ;
3. identifiant métier legacy exact dans le même record ;
4. sinon conserver les deux versions et produire un conflit d'import.

Le nom n'est jamais utilisé seul pour décider que deux entités sont identiques.

## 5. Items et références sources

- Chaque item de voyage devient un `trip_item` indépendant.
- `sourceTemplateItemId` devient une entrée `trip_item_sources` après résolution par `legacy_id_map`.
- Un item ajouté manuellement garde une source de type `manual` sans référence de bibliothèque.
- Les tombstones sont importés et restent exclus des calculs visibles.
- Les états sont convertis sans ambiguïté : `todo`, `checked`, `done`; l'ancien booléen `done` ne sert qu'en fallback.

## 6. Conflits et données récupérables

Si une version locale et la version PocketBase diffèrent :

- fusionner par identifiant stable au niveau membre/catégorie/item ;
- utiliser les dates legacy seulement pour choisir une valeur initiale, jamais pour fabriquer une identité ;
- enregistrer toute valeur perdante dans le rapport ou `sync_conflicts` ;
- ne supprimer automatiquement aucune entité en cas d'ambiguïté ;
- permettre un export du résultat avant toute synchronisation V1.

## 7. Contrôles après import

- nombres avant/après par type d'entité ;
- tous les identifiants V1 uniques ;
- aucune relation orpheline ;
- toutes les quantités entre 1 et 99 ;
- tous les états valides ;
- Personnel absent de l'outbox ;
- tous les records PocketBase historiques marqués partagés ;
- tous les documents uniquement locaux sans code actif ni identifiant distant ;
- progression recalculée uniquement sur les items non tombstonés ;
- export V1 possible avant la première synchronisation.

## 8. Ordre de basculement futur

1. Import à blanc sur fixtures.
2. Import d'une copie réelle dans un émulateur hors ligne.
3. Comparaison manuelle avec la Web app.
4. Connexion à un PocketBase V1 de test.
5. Test multi-appareils.
6. Nouvelle sauvegarde fraîche de production.
7. Import final avec rapport.
8. Synchronisation V1 seulement après confirmation.

La Web app 2.63 continue à utiliser exclusivement `travel_checklists`. Elle reste utilisable pendant toute cette séquence.
