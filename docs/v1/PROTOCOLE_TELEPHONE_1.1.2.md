# Candidate 1.1.2+31 — synchronisation automatique

Statut au 22 octobre 2026 : six scénarios réels réussis sur les deux Samsung,
puis confirmés par l’utilisateur. Palma identique à la révision 440, files vides
et aucune erreur. Résultats et conservation documentés dans `PASSATION.md`.

La validation technique sur données synthétiques ne vaut pas validation sur les
deux Samsung. **Aucune installation avant accord explicite.** Garder l'APK +30
et les exports Sécurité V1 avant/après le rattrapage de Palma.

APK : `flutter_app/release/Checklist-Voyage-v1.1.2+31-rc.apk`.
Contrôles techniques : analyse sans anomalie, 49 tests ciblés réussis, signature
de production identique à +30 et version/code vérifiés dans l'APK.
SHA-256 : `3528E44270CE0FEB3291F577A57293A80FB6D630815304CC851191790B21A697`.

## Précautions et référence

- Installer **en mise à jour** de `fr.checklistvoyage.app`, sans désinstallation
  ni effacement. Version à lire dans l'app : `1.1.2 · 31` sur les deux appareils.
- Ne pas restaurer, importer, purger l'outbox, dupliquer Palma ou refaire une
  jointure. Aucun réglage serveur à changer. Ne pas réactiver le réseau d'un
  téléphone resté hors ligne sans accord de son utilisateur.
- Avant les essais, vérifier les données existantes : Palma actif, mêmes items,
  noms, états et quantités. Référence du rattrapage : révision 414, 188 items,
  61 terminés, 17 cochés, 32 %. Si des modifications ont été faites depuis,
  prendre l'état actuel comme référence sans le remplacer par cet ancien état.
- Vérifier visuellement les autres voyages et l'animation d'ouverture. Aucun
  changement attendu. Choisir quelques items existants de Palma pour les essais,
  noter leurs valeurs avant/après et ne pas toucher aux autres voyages.

## Essais A ↔ B

1. **Usage normal et rafale.** Avec les deux appareils connectés et Palma ouvert,
   changer rapidement plusieurs états et quantités sur A. Laisser B ouvert sans
   bouton spécial. Attendu : mêmes valeurs sur B lors de la prochaine réception
   (15 secondes environ, plus le temps réseau), sans redémarrage ni nouvelle
   jointure. Refaire de B vers A. Les filtres peuvent cacher un item dont l'état
   change : sélectionner Tout pour comparer.
2. **Concurrence.** A modifie un item et B un autre, puis les deux modifient le
   même item. Attendu : aucun doublon, convergence des états/quantités ; pour
   l'item édité simultanément, la règle de conflit existante choisit une valeur
   commune. Elle ne promet pas l'addition de deux variations concurrentes.
3. **Perte et retour réseau.** Couper le réseau de A, modifier un état et une
   quantité. Attendu : valeurs conservées immédiatement et message discret
   « Partage en attente » après l'échec, sans détail serveur. Rétablir le réseau
   sans fermer Palma : reprise automatique ; message disparu et B à jour.
   Les reprises d'envoi sont espacées de 2/5/15/30/60 secondes (plafond 60 s),
   et la réception du voyage ouvert vérifie aussi toutes les 15 s.
4. **Veille/reprise.** Mettre B en arrière-plan sur l'accueil, modifier A et
   attendre son envoi. Revenir sur B : réception automatique même avant
   d'ouvrir Palma. Refaire en laissant Palma ouvert avant la veille. Attendu :
   aucune nécessité de forcer l'arrêt de l'app. Les tentatives sont suspendues
   pendant l'arrière-plan, puis reprennent au retour.
5. **Redémarrage complet et hors ligne.** Hors ligne, faire une modification,
   fermer puis relancer l'app. Attendu : données et modification présentes.
   Après retour au réseau, envoi automatique et réception sur l'autre appareil,
   sans doublon ni réinitialisation.
6. **Affichage.** À largeur Samsung, en clair puis sombre, contrôler le message
   hors ligne : texte lisible, bouton Réessayer accessible, liste utilisable.
   Le message disparaît après succès. Aucun changement de l'animation attendu.

La panne serveur temporaire, la réponse perdue après acceptation, une pause en
plein envoi et le rattrapage de 173 opérations avec pagination sont couverts par
les tests synthétiques. **Ne pas provoquer une panne de production ni fabriquer
173 modifications dans Palma pour refaire ces essais.**

## Résultat à transmettre

Indiquer l'étape, le téléphone, la version, l'heure, les valeurs attendues et
observées, le délai et une capture sans code/lien de partage. Si le problème
persiste, conserver un nouvel export Sécurité V1 de chaque appareil sans import
ni réparation supplémentaire. Comparer ces exports en lecture seule : mêmes
items/états/quantités, files Palma vides et curseurs convergents. Un message
disparu seul ne prouve pas une convergence exhaustive.

La version est validée sur téléphone seulement après confirmation de ces essais
et de la conservation des données existantes sur les deux Samsung.
