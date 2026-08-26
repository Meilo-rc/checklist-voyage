# Checklist Voyage — RC8 Groupes, icônes et hiérarchie

Version Android : `1.0.0-rc.8+22`.

## Corrections

- vocabulaire UI : `Section → Groupe/Membre → Catégorie → Item` ;
- Bibliothèque : `Ajouter un groupe` dans Général et Personnel, `Ajouter un
  membre` dans Membres, puis `Ajouter une catégorie` à l’intérieur du Groupe ;
- icône configurable et persistée pour chaque Groupe, Membre et Catégorie à
  partir des assets `category-icons` existants ;
- les Groupes Général/Membres conservent l’outbox de bibliothèque partagée ;
  Personnel reste strictement local ;
- Voyage : ajout, renommage, icône et suppression d’un Groupe autonome, sans
  modification de la Bibliothèque source ;
- le modèle Drift existant suffit : aucune migration ni modification du schéma ;
- administration compacte par appui long, avec sélecteur commun en grille ;
- menu Catégorie protégé par `SafeArea`, entièrement défilable à 360 px ;
- les filtres par personne sont retirés de l’interface sans supprimer le moteur
  métier existant ;
- les quatre filtres d’état restent seuls et tiennent sur 360 px ;
- l’en-tête, les items et l’ajout inline d’une catégorie appartiennent au même
  bloc continu ;
- l’en-tête de catégorie utilise un mélange léger de la couleur principale
  `#44C3F8`, adapté automatiquement au mode sombre ;
- une icône de Catégorie n’est affichée que lorsqu’elle est configurée ;
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

Aucun backend, PocketBase, PWA, protocole de synchronisation, partage ou écran
de Liste rapide n’est modifié.

## Validation technique

- `flutter analyze --no-pub` : aucune anomalie ;
- suite Flutter complète : 112 tests réussis ;
- 5 contrôles réels conditionnels ignorés faute de variables externes ;
- clair/sombre et largeur 360 px couverts ;
- persistance après redémarrage couverte pour Groupe, Membre, Personnel,
  Catégorie, Item et icônes ;
- absence d’écriture distante Personnel et absence d’impact du Voyage sur la
  Bibliothèque couvertes.
- APK release : 63 943 289 octets ;
- SHA-256 :
  `96FAFF1DCC3FD9422461737FEF898CE9BBCF39AA00C5E8937DE5BF7782D15F94` ;
- signature APK v2 valide, certificat identique à la RC7 ;
- installation en mise à jour réussie sur le Samsung `SM-S921B` ;
- `firstInstallTime` inchangé (`2026-08-24 15:49:40`) et démarrage sans erreur
  fatale détectée ; la validation fonctionnelle des données et de l’outbox
  reste à effectuer avec le protocole téléphone ci-dessous.

## Protocole téléphone

1. Installer la RC8 comme mise à jour, sans désinstaller l’application.
2. Vérifier `1.0.0-rc.8 · 22` et la présence des données existantes.
3. Bibliothèque > Général : ajouter un Groupe de test et lui choisir une icône.
4. Ouvrir ce Groupe, ajouter une Catégorie puis un Item.
5. Vérifier la hiérarchie et les icônes Groupe/Membre/Catégorie.
6. Appui long sur la Catégorie : Renommer, Changer l’icône et Supprimer doivent
   rester accessibles au-dessus de la barre Android.
7. Vérifier `Ajouter un membre` dans Membres et `Ajouter un groupe` dans
   Personnel.
8. Ouvrir un voyage : seules les pastilles `Tout`, `À préparer`, `Prêt` et
   `Rangé` doivent apparaître.
9. Ajouter un Groupe de test au Voyage, le renommer et changer son icône.
10. Ajouter une Catégorie et un Item dans ce Groupe.
11. Vérifier que ce Groupe n’est pas apparu dans la Bibliothèque.
12. Vérifier l’ordre À préparer, Prêt, Rangé.
13. Tester un tap simple À préparer → Prêt, avec déplacement après environ
    450 ms.
14. Tester deux taps rapides À préparer → Prêt → Rangé sans mouvement
    intermédiaire.
15. Vérifier Prêt → Rangé puis Rangé → À préparer.
16. Refaire les points visuels en mode sombre et contrôler l’absence d’overflow.
17. Fermer complètement puis rouvrir l’application ; vérifier la persistance.
18. Vérifier que la synchronisation et l’outbox terminent sans erreur.
19. Supprimer proprement les Groupes de test après validation.

En cas d’échec, noter l’étape, le résultat observé et joindre une capture si
possible.
