# Lot 13 — Interface Listes rapides

## Interface

La racine affiche les listes actives sous forme de lignes compactes avec nom,
progression et indication `Partagé` uniquement lorsque nécessaire. Les archives
restent accessibles par le sélecteur `Mes listes | Archives`. `Nouvelle liste`
est l'unique création et devient un champ inline après un toucher ; rejoindre
avec un code reste une action secondaire de l'en-tête.

Une liste ouverte affiche immédiatement sa progression et ses items. L'état
reste strictement binaire, avec carré vide ou coché et texte barré. La quantité
1 est implicite (`+`) ; au-delà, la ligne affiche `− quantité +`. L'ajout est
inline, la modification/suppression passe par swipe et `Tout décocher` apparaît
seulement lorsqu'au moins un item est coché.

Le partage, l'affichage du code, le renommage, la duplication, l'archivage, la
restauration et la suppression continuent d'utiliser les cas d'usage existants.
La duplication reste locale, sans capacité ni code hérité.

## Validation

- rendu widget à 360 px en clair et sombre ;
- plusieurs listes, nom long, liste partagée, archives et 20 items ;
- quantité 1, 2 et 12, ajout et renommage inline, swipe, état binaire et reset ;
- `flutter analyze --no-pub` : aucun problème ;
- 18 tests ciblés réussis (lots 4, 7, 9 et 13, navigation, moteur,
  archivage/duplication et persistance hors ligne) ;
- APK debug `0.13.0+13` généré puis installé comme mise à jour sur le Samsung ;
- smoke test réel : ouverture, coche, remise à zéro, quantité `1 → 2 → 1`,
  thème clair/sombre et redémarrage complet ;
- données du téléphone inchangées après le smoke test : UUID d'installation
  conservé, 1 liste/1 item non coché, 3 voyages, 235 items de bibliothèque et
  aucune opération de synchronisation en attente ;
- aucun changement Drift, synchronisation, PocketBase, backend, capacités, PWA
  ou moteur métier.
