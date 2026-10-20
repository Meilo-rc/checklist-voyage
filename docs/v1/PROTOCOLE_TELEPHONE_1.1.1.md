# Protocole téléphone — Destination/Météo 1.1.1

Version attendue : **1.1.1 · 30**, package `fr.checklistvoyage.app`.

**État au 20 octobre 2026 :** mise à jour du Samsung principal effectuée et
essais fonctionnels Destination/Météo confirmés réussis par l'utilisateur.
La synchronisation réelle avec le téléphone de Jenna reste à valider.
Le protocole reste disponible pour reproduire les contrôles ; toute nouvelle
installation nécessite un accord explicite.
Conserver les APK précédents, notamment `1.1.0+29` et la dernière version
entièrement validée sur téléphone. Utiliser des voyages dédiés au test.

## Installation et conservation

1. Après accord, installer l'APK en mise à jour, sans désinstaller l'application
   ni effacer ses données. Vérifier `1.1.1 · 30` dans l'en-tête.
2. Comparer avec l'état avant mise à jour : voyages, bibliothèque, listes
   rapides, items, états, quantités et codes de partage doivent être conservés.

## Destination et météo

3. Créer un voyage de test. Saisir `Paris` : les suggestions doivent afficher
   ville, région et pays et distinguer France, Texas, etc. Enregistrer sans
   sélection doit être refusé. Sélectionner explicitement la ville française,
   choisir des dates proches puis enregistrer : la météo doit correspondre à
   cette destination, avec des jours libellés Prévision.
4. Modifier ce voyage. Remplacer la destination par `Rome` : une nouvelle
   sélection doit être requise. Après sélection, le titre doit changer et la
   météo se recharger sans conserver les températures de Paris pendant l'attente.
   Retaper du texte après une sélection doit à nouveau imposer une sélection.
5. Modifier seulement les dates : la localisation doit rester conservée, sans
   nouvelle sélection. Vérifier que les items, états et quantités du voyage
   n'ont pas changé.
6. Si un ancien voyage de test sans coordonnées est disponible, modifier
   seulement ses dates : l'enregistrement doit rester possible. Sa météo doit
   demander de sélectionner une ville dans Modifier. Choisir ensuite une
   suggestion pour rendre sa localisation exploitable. Si aucun tel voyage de
   test n'est disponible, noter ce contrôle comme non exécuté ; ne pas altérer
   un voyage familial pour fabriquer ce cas.
7. Dupliquer le voyage géolocalisé : aucun champ Nom indépendant ne doit
   apparaître. La destination inchangée est réutilisable sans nouvelle sélection.
   Changer de ville doit imposer une sélection. La source reste intacte, la
   copie conserve structure et quantités avec ses états remis à préparer.
8. Ouvrir Partager : le message doit utiliser la destination actuelle, avec le
   code et le lien habituels. Pour un voyage déjà partagé, le code reste le même.
   Vérifier la convergence de la destination sur le second téléphone après une
   modification d'un voyage de test partagé ; aucune régénération de checklist.
9. Pour un séjour de test couvrant J+15 et J+16, contrôler le détail quotidien :
   J+15 est une Prévision et J+16 une Tendance habituelle. Une erreur du service
   doit être présentée comme telle, sans être systématiquement dite « hors ligne ».

## Redémarrage, hors ligne et affichage

10. Fermer complètement puis relancer l'application : destination, données de
    checklist, code de partage et météo en cache doivent rester cohérents.
11. Après chargement réussi, couper le réseau et rouvrir la météo inchangée :
    le cache doit rester utilisable. Modifier les dates d'un voyage déjà localisé
    reste possible hors ligne. Pour une période sans cache, la météo doit signaler
    le problème de connexion et ne pas afficher l'ancienne période. Une recherche
    de ville hors ligne ne doit pas produire de fausse sélection.
12. Refaire les suggestions, l'édition, Dupliquer et la météo en clair puis en
    sombre, à la largeur normale du téléphone : libellés, régions/pays, erreurs,
    boutons et défilement doivent rester lisibles et accessibles.

Signaler tout échec avec version, téléphone, numéro d'étape, résultat observé et
capture si possible. Distinguer les contrôles exécutés des contrôles non faits.
La validation technique de l'APK ne devient une validation téléphone qu'après
confirmation de ce protocole.
