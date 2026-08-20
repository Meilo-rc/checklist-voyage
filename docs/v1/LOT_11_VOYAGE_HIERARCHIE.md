# Lot 11 — Voyage → Membre → Catégorie → Items

## Résultat

L'écran d'un voyage utilise désormais une navigation mobile hiérarchique :

1. synthèse du voyage ;
2. Général ou membre ;
3. catégorie ;
4. items de la catégorie.

Chaque niveau ne construit que la liste qu'il affiche. La liste d'items est rendue paresseusement et reste utilisable avec 120 items sur une largeur de 360 px.

## Synthèse et filtres

- destination dans l'en-tête ;
- dates et durée sur une ligne ;
- progression compacte `rangés/total · pourcentage` ;
- partage signalé discrètement au niveau du voyage ;
- filtres État et Personne combinés avec un ET ;
- filtres conservés pendant la descente et appliqués par UUID via le moteur existant ;
- messages vides adaptés à l'état sélectionné.

## Items

- tap sur l'état : `todo → checked → done → todo` ;
- quantité indépendante avec `− quantité +` ;
- ajout direct en fin de catégorie ;
- swipe droit : renommage inline ;
- swipe gauche : retrait par le tombstone existant ;
- appui long : contextes lorsque l'item de voyage possède une source bibliothèque unique.

Un item compacté provenant de plusieurs sources ne reçoit pas d'association implicite : ses contextes restent à gérer depuis la Bibliothèque. Cette limite évite de choisir arbitrairement une source et ne modifie aucune règle métier.

## Portée technique

- aucun changement de schéma Drift ni de migration ;
- aucun changement de génération, progression, filtre métier, partage, synchronisation, PocketBase, backend ou PWA ;
- ajout d'un adaptateur de renommage d'item voyage qui réutilise les transactions et la préparation de synchronisation déjà existantes ;
- extraction de la feuille de contextes existante en composant partagé, sans refonte de l'écran Bibliothèque.

## Validation

- `flutter analyze --no-pub` : aucune anomalie ;
- suite Flutter : 77 tests passés, 4 tests réels optionnels ignorés faute de variables d'environnement ;
- scénarios dédiés : clair et sombre, 360 px, filtres persistants, gestes, contextes, ajout inline et 120 items ;
- APK debug généré ;
- installation réussie sur Samsung SM-S921B ;
- démarrage à froid, liste des voyages et ouverture d'un voyage vérifiés en mode sombre sur l'appareil.

Les gestes sur des items réels restent à confirmer humainement sur une checklist peuplée ; le voyage présent sur l'appareil au moment du smoke test ne contenait aucun item.
