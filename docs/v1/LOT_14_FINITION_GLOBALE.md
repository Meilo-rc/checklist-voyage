# Lot 14 — Finition globale Android

## Corrections

- Retour Android cohérent dans les voyages, la bibliothèque, les listes
  rapides et leurs archives ; un renommage inline est annulé avant de quitter
  la page.
- Ajouts inline successifs sans fermeture systématique du clavier, avec noms
  nettoyés des espaces de début et de fin.
- Quantités alignées sur la même largeur pour `− n +` dans les trois espaces.
- Feuille Contextes limitée en hauteur, défilable, lisible en clair/sombre et
  dotée d’une annulation explicite.
- Messages utilisateur courts : les exceptions techniques inconnues ne sont
  plus affichées telles quelles.
- Avertissement Drift du test d’archivage supprimé localement : les deux bases
  de ce scénario représentent volontairement deux installations isolées.

## Périmètre

Aucun schéma Drift, moteur métier, backend, protocole de synchronisation,
PocketBase, PWA ou migration n’a été modifié.

## Validation

- tests ciblés à 360 px, clair/sombre, texte agrandi et rotation temporaire ;
- navigation Retour Android, ajouts successifs, Contextes et erreurs couvertes ;
- `flutter analyze --no-pub` : aucun problème ;
- suite Flutter : 91 tests réussis, 5 scénarios réels conditionnels ignorés ;
- aucun avertissement Drift après la correction ciblée du test concerné ;
- APK debug `0.14.0+14` généré et installé comme mise à jour sur le Samsung ;
- smoke test réel sur le Samsung : voyages, filtres, hiérarchie membre/catégorie,
  cycle des trois états, quantité augmentée puis restaurée, bibliothèque,
  appui long Contextes, listes rapides, archives et Retour Android validés ;
- mode sombre et paysage vérifiés sur l'appareil, puis réglages restaurés ;
- fermeture forcée et redémarrage à froid validés, avec données persistantes ;
- avant et après installation : schéma 7, UUID d’installation inchangé, 12
  propriétaires, 37 catégories, 296 items de bibliothèque, 3 voyages, 147
  items de voyage, 1 liste rapide avec 1 item non coché et outbox vide.
