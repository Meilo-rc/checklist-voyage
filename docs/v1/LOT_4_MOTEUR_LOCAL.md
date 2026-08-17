# Lot 4 — moteur métier local Flutter

## Périmètre livré

Le lot 4 porte le cœur fonctionnel dans l'application Flutter sans modifier la
PWA 2.63 et sans appeler PocketBase. Drift/SQLite demeure l'unique source de
vérité de l'interface.

- CRUD local des groupes, catégories et items de bibliothèque ;
- portées `shared_library` pour Général/Famille et `personal_local` pour
  Personnel ;
- rôle de génération explicite sur les propriétaires de bibliothèque ;
- génération transactionnelle d'un voyage local à partir des Essentiels, des
  participants et de plusieurs transports et logements ;
- copie indépendante des catégories/items et conservation des UUID sources dans
  `trip_item_sources` ;
- cycle `todo → checked → done → todo`, quantités bornées de 1 à 99 et
  tombstone lors du retrait d'un item ;
- progressions voyage, membre, catégorie et liste rapide centralisées dans le
  domaine ;
- CRUD complet des listes rapides locales, état binaire et réinitialisation ;
- interface minimale de validation sur les trois destinations ;
- persistance après redémarrage et fonctionnement avec tout accès HTTP interdit.

## Architecture obtenue

L'interface appelle des façades de cas d'usage. Celles-ci dépendent uniquement
des contrats de repositories du domaine. Les implémentations Drift encapsulent
les transactions et le mapping entre tables et modèles métier.

```text
features (Flutter UI)
  → domain/usecases
    → domain/repositories (contrats)
      → data/repositories (Drift)
        → data/local/AppDatabase (SQLite)
```

Les calculs de progression sont dans `domain/models/progress.dart` et ne
dépendent ni de Flutter ni de Drift. Les queries de lecture excluent les lignes
ayant `deleted_at`, ce qui garantit que les tombstones ne participent à aucun
total visible.

## Schéma et migration

Le schéma Drift passe en version 3. La migration ajoute
`library_owners.generation_role`, avec `general` comme valeur sûre pour les
bases du lot 3. Les nouvelles valeurs sont `general`, `essential`,
`participant`, `transport` et `lodging`.

Les voyages et listes nouvellement créés ont toujours `share_state = local`,
sans code ni identifiant distant. Les opérations du lot 4 n'écrivent jamais
dans `sync_outbox`. Une suppression Personnel reste entièrement locale. Les
entités synchronisables utilisent `deleted_at`; lorsqu'une entité est déjà
partagée, un enregistrement de rétention à 90 jours est préparé dans
`sync_tombstones`, sans tentative réseau.

## Parité et différences avec la PWA 2.63

- Les comportements Essentiels, participants, multi-transport,
  multi-logement, quantités et cycle des états sont conservés.
- Le nom n'est plus l'identité d'une sélection : les UUID des groupes et items
  sources sont conservés. L'import legacy doit toutefois déduire une seule fois
  les rôles Essentiels/transport/logement depuis les conventions 2.63, car le
  format historique ne possède pas ce champ. Cette compatibilité est isolée dans
  l'importeur ; le moteur V1 ne compare ensuite jamais les noms.
- Contrairement à la PWA, un nouveau voyage ou une nouvelle liste ne reçoit pas
  de code et ne déclenche aucune écriture distante.
- Le bug 2.63 de progression globale est corrigé : un item tombstoné est absent
  du numérateur comme du dénominateur.
- Les fusions réseau et le dédoublonnage historique ne sont pas portés dans le
  moteur local, conformément au hors-périmètre synchronisation/compaction.

## Tests du lot

La suite couvre :

- création et migrations Drift 1 → 3 et 2 → 3 ;
- import Web, idempotence, correspondances historiques et redémarrage ;
- CRUD et portées Général/Famille/Personnel ;
- absence d'outbox et absence de fuite de Personnel ;
- génération Essentiels/participants/multi-transport/multi-logement ;
- références sources, quantités et cycle des états ;
- retrait d'un item sans modification de la bibliothèque ;
- progressions sans tombstones ;
- listes rapides, transactions et réinitialisation ;
- persistance complète sur une base fichier ;
- parcours UI à 360 px de large ;
- exécution avec le client HTTP volontairement interdit.

Le smoke test sur une sauvegarde réelle reste optionnel et ignoré tant que la
variable `CHECKLIST_V1_REAL_BACKUP` n'est pas fournie, afin qu'aucune donnée
réelle n'entre dans le dépôt.

## Dette technique connue

- l'interface est volontairement utilitaire : confirmations de suppression,
  messages d'erreur et accessibilité fine seront consolidés avec la refonte UX ;
- la classification des rôles pendant l'import legacy repose partiellement sur
  les conventions de nommage 2.63, faute de métadonnée historique ;
- `trip_item_sources` accepte plusieurs sources mais le lot 4 en crée une par
  copie, la compaction étant reportée ;
- les flux Drift de détail utilisent des requêtes SQL de signalisation ; des DAO
  typés pourront les remplacer si les agrégats deviennent très volumineux ;
- aucun schéma `cv1_*`, client PocketBase ou protocole de conflit n'est activé.

## Proposition de lot 5

Le lot suivant devrait stabiliser le dernier pan du moteur local avant
d'introduire la synchronisation : contextes/activités et compaction V1.

1. valider les invariants de portée des contextes et ajouter la migration Drift
   nécessaire si leur propriété doit être explicitée ;
2. implémenter le CRUD local des contextes et leurs associations aux items, avec
   Général/Famille synchronisable et Personnel strictement local ;
3. ajouter la sélection de plusieurs contextes lors de la création d'un voyage ;
4. étendre la génération sans changer les comportements du lot 4 ;
5. compacter uniquement les occurrences ayant une relation source explicite et
   enregistrer toutes leurs sources dans `trip_item_sources`, sans fusion par
   nom ;
6. ajouter une UI minimale d'association par appui long et les tests de
   migration, portée, génération, non-fusion des homonymes et persistance ;
7. conserver PocketBase, partage, filtres, archives, duplication et refonte
   graphique hors de ce lot.

Critère de sortie proposé : une checklist locale peut être générée depuis les
choix actuels et plusieurs contextes, sans doublon d'identité, sans perte de
références et sans aucune connexion réseau.
