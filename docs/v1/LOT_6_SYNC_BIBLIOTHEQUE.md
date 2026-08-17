# Lot 6 — synchronisation V1 de la bibliothèque partagée

Date de validation technique : 17 août 2026.

## Périmètre réellement livré

La synchronisation couvre uniquement les propriétaires Général et Famille, leurs catégories et items, les contextes partagés et les associations `shared_library`. Personnel, les associations `personal_local`, les voyages et les listes rapides restent strictement locaux.

La base Drift reste la source de vérité de l’UI. Chaque mutation partagée est écrite localement et ajoute, dans la même transaction, une opération persistante à `sync_outbox`. Une erreur réseau ne bloque donc jamais le parcours local.

## Schéma Drift v5

La migration v4 vers v5 ajoute :

- à `installation_settings` : `library_id`, compteur d’opérations, curseur de pull, statut, erreur et date de dernière synchronisation ;
- à `sync_outbox` : UUID de bibliothèque, UUID d’installation, séquence d’installation et compteur logique de l’entité ;
- `sync_entity_states` : compteur logique, dernière révision serveur, appareil gagnant et état supprimé ;
- aucune colonne métier n’est retirée et les bases antérieures restent ouvrables.

Le contrat SQL documentaire est dans `docs/v1/schema_local_v1.sql`. Le schéma exécuté reste celui généré par Drift depuis `flutter_app/lib/data/local/app_database.dart`.

## Collections PocketBase réellement créées

Migration : `pocketbase/pb_migrations/2026081701_cv1_library_sync.js`.

- `cv1_libraries` : UUID logique, version de schéma, révision globale, dernier appareil, future identité utilisateur nullable ;
- `cv1_library_entities` : état canonique d’une entité, payload, tombstone, horloge logique et révision ;
- `cv1_operations` : journal append-only idempotent et ordonné par révision serveur ;
- `cv1_devices` : dernière révision acquittée et dernière activité par installation.

Les API CRUD standard des quatre collections ont leurs cinq règles à `null` : elles sont réservées aux administrateurs. L’application utilise exclusivement les routes versionnées du hook `pocketbase/pb_hooks/cv1_sync.pb.js` :

- `POST /api/cv1/sync/push` ;
- `GET /api/cv1/sync/pull`.

La collection `travel_checklists` n’apparaît dans aucun fichier V1.

## Protocole final

Une opération porte `operation_uuid`, `library_uuid`, `device_uuid`, `client_sequence`, `client_counter`, `base_revision`, l’identité stable de l’entité, son type, l’action et son payload.

Le push est appliqué dans une transaction PocketBase :

1. retour immédiat du résultat déjà enregistré si `operation_uuid` existe ;
2. incrément de la révision globale de bibliothèque ;
3. arbitrage déterministe ;
4. mise à jour éventuelle de l’entité canonique ;
5. ajout du résultat dans le journal ;
6. mise à jour de l’installation.

Le pull demande uniquement les opérations dont `server_revision > pull_cursor`, dans l’ordre croissant. Une page complète est appliquée dans une transaction Drift, puis seulement le curseur est avancé. Le cycle local est toujours push puis pull.

## Conflits

L’arbitrage ne dépend ni de l’heure du téléphone, ni du nom, ni uniquement de l’ordre réseau. Il compare :

1. le compteur logique de l’entité ;
2. à compteur égal, une suppression gagne sur une modification ;
3. à action égale, l’UUID d’installation départage de façon stable.

Une entité distante tombstonée refuse tout upsert du lot 6. Une restauration explicite n’existe pas encore. Toute opération perdante est conservée dans `cv1_operations` avec son motif et enregistrée localement dans `sync_conflicts` lors du pull.

## Tombstones

Une suppression partagée :

- masque localement l’entité et crée un tombstone ;
- ajoute une opération `delete` à l’outbox ;
- renseigne `propagated_at` seulement après confirmation serveur ;
- fixe `purge_eligible_at` à 90 jours après la suppression.

Aucune purge automatique n’est exécutée au lot 6. Cette absence est intentionnelle tant que tous les appareils concernés n’ont pas une garantie d’acquittement suffisante.

## Barrière Personnel

La protection est appliquée à deux niveaux :

- `LibrarySyncStore` vérifie par jointures SQL la portée réelle du propriétaire avant de créer une opération ;
- le hook PocketBase rejette `sync_scope = personal_local` et `kind = personal`.

Les payloads synchronisés n’incluent jamais `linked_participant_owner_id`, qui concerne uniquement le rattachement local de Personnel.

## Validation locale et réelle

PocketBase 0.22.25 local : migration appliquée sur une base vide, push répété avec révision stable `1 → 1`, pull d’une opération, CRUD direct `403`, tentative Personnel `400` et rejet d’une catégorie dont le parent partagé est absent `400`.

PocketBase Fly.io réel :

- snapshot du volume planifié avant déploiement ;
- image renforcée déployée `deployment-01M06WD48M7PPGES0VQ2189TP6` (release Fly.io 22) ;
- test Flutter réel avec deux bases Drift et une bibliothèque UUID isolée : réussi ;
- création, contexte, association, convergence, coupure logique du réseau, modifications concurrentes, reconnexion, suppression et contrôle négatif Personnel : réussis ;
- santé API `200`, `travel_checklists` listable `200`, pull V1 `200`, CRUD V1 direct `403` et parent V1 absent rejeté `400` ;
- catalogue de l’autre application partageant l’instance `200` ;
- PWA GitHub Pages historique `200`.

La configuration serveur durable est aussi présente dans le dépôt backend partagé, commit `74fbebc`, afin qu’un déploiement ultérieur de ce backend conserve les routes V1.

## Limites de sécurité

La V1 ne possède volontairement ni compte utilisateur ni identité de foyer authentifiée. Les collections sont administrativement verrouillées et le hook valide strictement le contrat, mais une personne connaissant l’URL et un UUID de bibliothèque peut appeler les routes V1. L’UUID de bibliothèque n’est donc pas un secret et ne constitue pas une isolation forte.

Ne pas ajouter de secret partagé dans l’APK pour masquer cette limite : il serait extractible. L’isolation forte nécessitera au lot ultérieur une identité utilisateur/foyer ou un mécanisme d’autorisation serveur validé.

## Dette et lot suivant proposé

- ajouter une authentification de foyer avant une diffusion publique large ;
- définir l’acquittement de tous les appareils avant toute purge physique ;
- ajouter une résolution utilisateur uniquement pour les conflits qui ne peuvent pas être résolus automatiquement ;
- surveiller la croissance de `cv1_operations` avant d’introduire une compaction serveur ;
- le lot 7 peut porter le partage V1 explicite des voyages et listes rapides, en réutilisant le même transport, sans les synchroniser par défaut.
