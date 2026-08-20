# Lot 10 — interface V1 Voyages

Le lot finalise le socle Material 3 déjà engagé et les écrans Voyages ainsi que
Créer/Modifier un voyage. L’intérieur d’un voyage, Bibliothèque et Listes
rapides conservent leur interface antérieure.

## Interface livrée

- navigation principale Voyages, Bibliothèque et Listes rapides ;
- liste séparant les voyages en cours, à venir et les archives ;
- cartes compactes centrées sur la destination, avec dates françaises,
  participants, trajet/logement synthétique, progression, temporalité et badge
  Partagé ;
- menu discret réutilisant Modifier, Dupliquer, Archiver et Restaurer ;
- formulaire commun de création/édition avec une plage de dates et des
  multisélections sans coche décorative ;
- chips contraintes à la largeur disponible, y compris pour les libellés longs.

## Validation

- `flutter analyze --no-pub` : aucun problème ;
- `flutter test --no-pub` : 73 tests réussis, 4 tests réels ignorés faute de
  variables externes ;
- rendu widget validé à 360 × 800 px avec quatre participants, plusieurs
  transports, logements et activités, ainsi que des libellés longs ;
- APK debug installé sur le Samsung SM-S921B et écran Voyages contrôlé en 360 px
  logiques.

Aucun modèle métier, backend, mécanisme de synchronisation, partage ou fichier
de la PWA n’a été modifié.
