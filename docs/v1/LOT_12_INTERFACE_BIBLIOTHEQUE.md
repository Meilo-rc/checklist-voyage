# Lot 12 — Interface Bibliothèque

## Navigation et densité

La racine Bibliothèque expose trois lignes compactes : Général, Membres et
Personnel. Général et Personnel ouvrent directement leurs catégories. Membres
ouvre une liste compacte, puis la page du membre affiche ses catégories. Une
seule catégorie est ouverte à la fois et les lignes sont construites
paresseusement pour conserver un défilement fluide avec une bibliothèque dense.

Les groupes métier historiques de Général (Essentiels, transports, logements)
restent des sections discrètes dans la même page. Le modèle et les identités ne
sont pas modifiés.

## Interactions

- catégorie : toucher pour déplier, swipe ou appui long pour renommer,
  swipe inverse pour supprimer ;
- item : quantité 1 implicite avec seulement `+`, puis `− quantité +` ;
- ajout d'item et de catégorie : ligne compacte transformée en saisie inline ;
- item : swipe pour renommer/supprimer et appui long pour la bottom sheet
  Contextes existante ;
- membre : ajout inline, renommage/suppression par swipe.

Les tombstones et les descendants de parents tombstonés restent invisibles et
ne sont pas comptés. Personnel continue à n'émettre aucune opération de
synchronisation.

## Validation

- `flutter analyze --no-pub` : aucun problème ;
- suite pertinente : 15 tests réussis ;
- contrôles widgets à 360 px en clair et sombre, noms longs, 20+ items,
  quantité 10, ajout inline, swipes et Contextes ;
- APK debug : `flutter_app/build/app/outputs/flutter-apk/app-debug.apk`, version
  `0.12.0+12`.

Aucun schéma Drift, import legacy, moteur métier, backend, PocketBase ou PWA n'a
été modifié.
