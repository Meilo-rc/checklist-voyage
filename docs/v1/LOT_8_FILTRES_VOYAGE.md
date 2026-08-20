# Lot 8 — filtres de voyage par état et par membre

Date de validation technique : 20 août 2026.

## Comportement livré

L'écran d'un voyage propose deux lignes de filtres combinables :

- état : Tout, À préparer, Prêt, Rangé ;
- personne : Tous, Général, puis les participants réellement présents.

La combinaison utilise une logique ET. Les options participant s'appuient sur
l'UUID du `trip_member`, jamais sur son nom. Général sélectionne les sections
dont le `group_kind` vaut `general`, ce qui inclut Essentiels, transports,
logements, contextes généraux et ajouts spécifiques généraux.

## Vue dérivée locale

`TripFilterEngine` construit une vue en mémoire depuis le `TripDetailModel`
déjà chargé. Il conserve uniquement les items correspondants, puis retire les
catégories et membres devenus vides. Aucun champ Drift n'est ajouté et aucune
mutation de repository n'est appelée.

Le flux réactif du voyage est créé une seule fois à l'ouverture de l'écran. Un
changement de filtre ne recrée donc pas l'abonnement Drift et ne produit ni
requête réseau, ni opération d'outbox. L'état du filtre vit seulement dans
l'écran courant.

## Navigation et progression

Les `ExpansionTile` de membres et catégories reçoivent des identités stables et
conservent leur état dans la navigation hiérarchique. Les éléments tombstonés,
déjà exclus par le repository, ne peuvent apparaître dans aucun résultat.

La progression globale ainsi que les progressions de membre et de catégorie
restent calculées sur les modèles complets non filtrés. Le filtre ne change que
les lignes visibles.

## Partage et performances

Le même moteur est utilisé pour un voyage local, partagé ou rejoint par code.
Un test à deux installations confirme que filtrer sur l'installation ayant
rejoint le voyage ne crée aucune outbox et n'ajoute aucune opération distante.

Le calcul a été contrôlé sur 140 items et le rendu Flutter sur 120 items avec
une largeur de 360 pixels. Les sections vides sont supprimées et la ligne des
personnes défile horizontalement.

## Validation couverte

- les quatre filtres d'état ;
- Tous, Général et chaque participant par UUID ;
- combinaisons personne + état et résultat vide ;
- tombstones absents ;
- progression globale inchangée ;
- maintien du filtre dans les sections membre/catégorie ;
- voyage rejoint par code sans nouvelle outbox ;
- volumes de 120 et 140 items sur écran étroit.
