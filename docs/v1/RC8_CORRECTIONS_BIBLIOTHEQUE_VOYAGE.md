# Checklist Voyage — RC8 corrections Bibliothèque et Voyage

Version Android : `1.0.0-rc.8+22`.

## Corrections

- l’ajout d’une catégorie depuis Général utilise le même cas d’usage que les
  autres portées, ouvre immédiatement la liste correspondante et produit
  l’opération de synchronisation normale de la bibliothèque partagée ;
- les icônes de membres déjà stockées sont affichées dans Bibliothèque et dans
  le bloc Membres d’un voyage, avec une icône neutre si aucune n’est définie ;
- les filtres par personne sont retirés de l’interface sans supprimer le moteur
  métier existant ;
- les quatre filtres d’état restent seuls et tiennent sur 360 px ;
- l’en-tête, les items et l’ajout inline d’une catégorie appartiennent au même
  bloc continu ;
- l’en-tête de catégorie utilise un mélange léger de la couleur principale
  `#44C3F8`, adapté automatiquement au mode sombre ;
- une icône de catégorie n’est affichée que lorsqu’elle est configurée ;
- l’ordre visuel est strictement `todo`, puis `checked`, puis `done`, avec tri
  alphabétique dans chaque groupe ;
- après un premier tap `todo → checked`, la position est conservée 450 ms ;
- un second tap pendant cette fenêtre enregistre `checked → done` avant le
  réordonnancement ;
- un item déjà `checked` passe directement à `done` et un item `done` revient
  directement à `todo` ;
- le délai est uniquement visuel : chaque état est enregistré immédiatement et
  les écritures successives sont sérialisées ;
- les temporisateurs sont annulés à la fermeture de la page et aucun délai
  n’est appliqué lorsque le filtre actif impose la disparition immédiate.

Aucun schéma Drift, backend, protocole de synchronisation, partage ou écran de
Liste rapide n’est modifié.

## Validation technique

- `flutter analyze --no-pub` : aucune erreur ;
- tests ciblés RC8 : 20 réussis ;
- suite Flutter complète : 109 réussis, 5 contrôles réels ignorés faute de
  variables externes ;
- tests widget clair/sombre et 360 px réussis ;
- persistance et outbox Général vérifiées après redémarrage d’une base locale ;
- départ de la page pendant les 450 ms vérifié sans erreur.
- APK release : 63 746 598 octets ;
- SHA-256 :
  `A18F41367AD351B320924AD5722FAF286C169C0A477BF5732623336FD8319390` ;
- signature APK v2 valide, certificat identique à la RC7 ;
- installation en mise à jour réussie sur le Samsung `SM-S921B` ;
- `firstInstallTime` inchangé (`2026-08-24 15:49:40`) et démarrage sans
  erreur fatale ;
- candidat RC8 Drive vérifié à 63 746 598 octets ;
- RC7 copiée et vérifiée comme backup validé à 63 746 510 octets ;
- ancien backup RC2 supprimé à la demande du propriétaire.

## Protocole téléphone

1. Installer la RC8 comme mise à jour, sans désinstaller l’application.
2. Vérifier `1.0.0-rc.8 · 22` et la présence des données existantes.
3. Dans Bibliothèque > Général, ajouter une catégorie de test : la liste doit
   s’ouvrir et afficher immédiatement la nouvelle catégorie.
4. Supprimer ensuite proprement cette catégorie de test.
5. Vérifier les icônes sur les lignes Membres de Bibliothèque.
6. Ouvrir un voyage : seules les pastilles `Tout`, `À préparer`, `Prêt` et
   `Rangé` doivent apparaître.
7. Vérifier les icônes dans le bloc Membres, puis ouvrir un membre.
8. Ouvrir une catégorie et vérifier le bloc continu, son en-tête bleu léger,
   ses items et l’ajout inline.
9. Avec le filtre Tout, vérifier l’ordre À préparer, Prêt, Rangé.
10. Faire un tap simple sur un item À préparer : il devient Prêt, reste environ
    une demi-seconde en place, puis rejoint le groupe Prêt.
11. Faire deux taps rapides sur un autre item À préparer : il doit atteindre
    Rangé sans que la ligne se déplace entre les deux taps.
12. Vérifier un tap `Prêt → Rangé` et un tap `Rangé → À préparer`.
13. Refaire les contrôles en mode sombre et vérifier l’absence d’overflow.
14. Fermer complètement puis rouvrir l’application ; contrôler les états et les
    données.
15. Vérifier que la synchronisation se termine sans erreur.

En cas d’échec, noter l’étape, le résultat observé et joindre une capture si
possible.
