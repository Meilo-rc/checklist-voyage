# Lot 5 — contextes, activités et compaction locale

## Résultat

Le moteur Flutter permet désormais de créer des contextes libres, de les
associer à des items existants et de les sélectionner lors de la création d'un
voyage. Les items restent dans leur propriétaire et leur catégorie naturels.
La génération compacte plusieurs contributions seulement lorsqu'elles portent
la même identité logique explicite.

PocketBase, le partage et la synchronisation restent totalement inactifs.

## Modèle Drift v4

La migration 3 → 4 est additive et conserve toutes les données du lot 4.

### Bibliothèque

- `library_owners.linked_participant_owner_id` relie facultativement un espace
  Personnel à un membre par UUID. Aucun nom n'est comparé.
- `library_items.logical_source_id` porte l'identité utilisée pour la
  compaction. Un nouvel item reçoit son propre UUID comme identité logique.
- `library_item_contexts.association_id` donne un UUID stable à l'association.
- `library_item_contexts.sync_scope` vaut `shared_library` pour un item
  Général/Famille et `personal_local` pour Personnel.
- `library_item_contexts.updated_at_local` prépare les futures mutations
  synchronisables.

Les tables `contexts` et `library_item_contexts` sont maintenant utilisées par
le domaine. Un contexte est global dans la bibliothèque : le même UUID Plage
peut être associé aux trois portées. C'est l'association, et non le contexte
dupliqué, qui devient locale pour Personnel.

### Voyages

- `trip_generation_choices` conserve chaque participant, transport, logement
  et contexte explicitement choisi, même s'il ne produit aucun item.
- `trip_item_sources.reason_kind` indique `essential`, `participant`,
  `transport`, `lodging` ou `context`.
- `trip_item_sources.reason_id` conserve l'UUID du propriétaire ou du contexte
  ayant justifié l'item.
- `trip_item_sources.contributing_library_item_id` conserve la représentation
  de bibliothèque effectivement rencontrée.

La colonne historique `source_kind` sert encore dans la clé primaire physique.
Pour rester compatible avec une migration strictement additive, les nouvelles
lignes y stockent une clé de raison déterministe `type:UUID`. Les champs
`reason_kind` et `reason_id` sont la représentation métier à utiliser.

## Comportement exact des contextes

1. La création d'un item ne demande jamais de contexte.
2. Un appui long sur un item ouvre une bottom sheet de sélection multiple.
3. La validation remplace transactionnellement l'ensemble des associations de
   cet item.
4. Un item Général ou Famille produit une association `shared_library`.
5. Un item Personnel produit une association `personal_local`, sans outbox ni
   tombstone de synchronisation lors de son retrait.
6. Supprimer un contexte tombstone le contexte et toutes ses associations, sans
   modifier les items.
7. Les associations partagées supprimées préparent un tombstone à 90 jours ;
   les associations Personnel n'en préparent aucun.
8. Un item de membre n'est apporté par un contexte que si ce membre participe.
9. Un item Personnel n'est apporté que si son espace est relié par UUID à un
   participant sélectionné. Il est alors affiché sous ce participant et dans sa
   catégorie Personnel d'origine.
10. Un item Général associé est ajouté sans créer de catégorie artificielle au
    nom du contexte.

Les espaces Personnel historiques importés restent non liés par défaut. L'UI
permet de les associer explicitement à un membre. Cette décision empêche toute
déduction fragile par nom.

## Comportement exact de la compaction

La génération construit d'abord des contributions : Essentiels, participants,
transports, logements, puis contextes. Chaque contribution possède :

- un `logical_source_id` ;
- un item contributeur ;
- un propriétaire et une catégorie de placement ;
- une raison typée et son UUID.

Les contributions sont ensuite regroupées uniquement par
`logical_source_id` :

- même identité via deux transports : un TripItem, deux raisons ;
- même identité via transport + logement : un TripItem, deux raisons ;
- même identité via contexte + transport : un TripItem, deux raisons ;
- même identité via plusieurs contextes : un TripItem, une raison par
  contexte ;
- noms identiques avec identités différentes : deux TripItems.

La quantité est celle de la première contribution déterministe et n'est jamais
additionnée. L'ordre est Essentiels, participants, transports, logements, puis
contextes ; au sein d'un rôle, les propriétaires sont triés par nom. Si des
alias explicitement reliés portent des quantités différentes, cette règle
simple s'applique en attendant un arbitrage produit plus riche.

Pour un item apporté uniquement par un contexte, le propriétaire et la
catégorie naturels sont conservés. Pour plusieurs représentations historiques
reliées au même `logical_source_id` mais rangées dans des catégories
différentes, le premier placement déterministe est conservé.

## Retrait et modification future des choix

Retirer manuellement un TripItem pose un tombstone sur cette copie uniquement.
Les lignes `trip_item_sources` restent historiques ; la bibliothèque et les
associations de contexte ne changent pas.

Le lot 5 n'ajoute volontairement aucune commande de régénération d'un voyage
existant. Un item retiré ne peut donc pas être réintroduit silencieusement. Pour
le futur moteur de modification, les données permettent de :

- retirer une raison sans retirer l'item si d'autres raisons subsistent ;
- identifier un item sans raison restante ;
- reconnaître une exclusion explicite grâce au TripItem tombstoné et à ses
  sources historiques.

La décision automatique à prendre pour un item sans raison restante (conserver,
demander confirmation ou tombstoner) reste volontairement non arbitrée.

## Tests

La suite Flutter couvre :

- migrations 1 → 4 et 3 → 4 ;
- CRUD, renommage, suppression et associations multiples ;
- portées Général/Famille/Personnel et absence d'outbox ;
- persistance des contextes et associations après redémarrage ;
- un et plusieurs contextes, Général, membres sélectionnés et Personnel lié ;
- combinaison avec Essentiels, transports et logements ;
- tous les cas de compaction demandés et quantité non multipliée ;
- plusieurs sources conservées ;
- deux homonymes non fusionnés ;
- retrait d'un TripItem sans effet sur source ou association ;
- parcours UI d'appui long et choix de contexte au voyage ;
- exécution avec tout client HTTP interdit.

## Dette technique

- l'UI reste une interface de validation sans confirmations de suppression ;
- le lien logique entre alias de bibliothèque est supporté par le domaine mais
  n'a pas d'éditeur utilisateur, car ce n'est pas une action courante ;
- `source_kind` contient encore la clé physique de raison pour éviter une
  reconstruction destructive de table ;
- aucune modification des choix d'un voyage existant n'est exposée ;
- aucun client PocketBase ni collection `cv1_*` n'existe dans l'application.

## Proposition de lot 6

Le prochain lot peut introduire le socle de synchronisation de la bibliothèque
V1, sans encore partager les voyages ou listes rapides :

1. créer exclusivement les collections PocketBase `cv1_*` de bibliothèque,
   contextes, associations, appareils et tombstones ;
2. conserver `travel_checklists` strictement hors d'atteinte du client V1 ;
3. ajouter un client distant derrière les repositories et l'UUID
   d'installation ;
4. produire une outbox uniquement pour Général/Famille et les associations
   `shared_library` ;
5. prouver par tests qu'aucune donnée ou association Personnel ne quitte
   l'appareil ;
6. implémenter push/pull idempotents, révisions, reprise hors ligne et
   tombstones conservés 90 jours jusqu'à propagation garantie ;
7. tester deux installations, conflits simples, interruptions réseau et
   coexistence avec la PWA 2.63.

Le partage des voyages/listes par code, les filtres, archives, duplication et
la refonte UX resteraient hors de ce lot 6.
