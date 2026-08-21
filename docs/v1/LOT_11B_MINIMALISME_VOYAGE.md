# Lot 11B — Minimalisme de l'interface Voyage

## Navigation

La navigation conserve deux changements de page : Voyage → Général et Voyage → Membre. Les catégories s'ouvrent désormais directement dans la page du propriétaire ; aucune page Catégorie supplémentaire n'est créée.

Une seule catégorie peut être ouverte à la fois. Ce choix garde un comportement simple et prévisible, sans état de navigation supplémentaire. La liste utilise toujours un rendu paresseux : seuls les éléments visibles sont construits, y compris avec 120 items.

## Représentation

- catégorie : ligne compacte avec nom, progression et chevron ;
- `todo` : carré vide ;
- `checked` : trait horizontal dans le carré et texte grisé ;
- `done` : croix `+` dans le carré et texte barré ;
- quantité 1 : seul le bouton `+` est visible ;
- quantité supérieure à 1 : affichage `− quantité +` ;
- ajout : ligne « Ajouter un item » qui devient un champ de saisie inline après un tap ;
- swipe Modifier/Supprimer et appui long Contextes conservés.

Les filtres, l'ordre métier des items et les progressions restent fournis par les composants de domaine existants.

## Validation

- largeur 360 px en clair et sombre ;
- plusieurs catégories, 120 items, nom long et quantités 1, 2 et 12 ;
- dépliage/repliage, une catégorie ouverte à la fois, ordre par état et ajout inline ;
- `flutter analyze --no-pub` : aucune anomalie ;
- suite Flutter : 77 tests passés, 4 tests réels optionnels ignorés ;
- APK debug généré.

Aucun schéma Drift, moteur métier, filtre, progression, contexte, partage, synchronisation, backend, PocketBase ou élément de la PWA n'a été modifié.

Le Samsung n'était plus visible par ADB lors de la livraison. L'installation et le smoke test réel de cette version restent donc à effectuer sans effacer les données lorsque l'appareil sera de nouveau connecté.
