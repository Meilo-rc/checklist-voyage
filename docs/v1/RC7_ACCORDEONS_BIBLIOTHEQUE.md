# Checklist Voyage — RC7 accordéons de Bibliothèque

Version Android : `1.0.0-rc.7+21`.

## Changements livrés

- ajout direct d’une catégorie dans le bloc Général de la Bibliothèque ;
- ajout direct d’une catégorie dans Personnel lorsqu’un espace personnel existe ;
- catégories de Bibliothèque ouvertes en accordéon, sans nouvelle page ;
- remplacement des cases des items de Bibliothèque par des puces non
  interactives ;
- regroupement visuel d’une catégorie et de ses items dans la Bibliothèque et
  dans le détail d’un membre de voyage ;
- en-tête de catégorie sur un neutre plus marqué et zone d’items sur un neutre
  plus clair, avec équivalents automatiques en mode sombre ;
- champs d’ajout inline transparents afin d’hériter de la couleur du bloc ;
- alignement du texte des ajouts inline sur le texte des lignes ;
- protection de la fin des listes contre la barre système Android.

Aucune règle métier, donnée, synchronisation, règle de partage ou collection
PocketBase n’est modifiée.

## Validation technique réalisée

- `flutter analyze --no-pub` : aucune erreur ;
- tests Flutter : 106 réussis, 5 contrôles réels ignorés faute de variables
  externes ;
- tests spécifiques à 360 px réussis en clair et en sombre, dont une catégorie
  de 120 items ;
- APK release : 63 746 510 octets ;
- SHA-256 :
  `544A5873755D98F7DB9AB860BFB3C17151A1B436FA88367CA8A49C11C284240E` ;
- signature APK v2 valide, un signataire ;
- installation en mise à jour réussie sur le Samsung `SM-S921B` ;
- `firstInstallTime` inchangé (`2026-08-24 15:49:40`), donc aucune
  désinstallation pendant la bascule RC6 vers RC7 ;
- copie candidate Drive vérifiée à 63 746 510 octets ;
- sauvegarde RC2 validée conservée séparément et inchangée.

## Protocole téléphone

La RC7 ne devient pas une version validée sur téléphone avant confirmation de
l’utilisateur. La RC2 reste donc la sauvegarde validée.

1. Installer `1.0.0-rc.7+21` **sans désinstaller** la version présente.
2. Vérifier dans l’application que les voyages, la bibliothèque et les listes
   rapides existants sont toujours présents.
3. Dans Bibliothèque > Général, vérifier que `Ajouter une catégorie` est visible,
   créer une catégorie et contrôler qu’elle apparaît sans dialogue.
4. Ouvrir Général puis toucher une catégorie : elle doit se déplier sur place,
   sans nouvelle page.
5. Vérifier que ses items ont de petites puces rondes, sans cases à cocher.
6. En bas de cette catégorie, ajouter un item avec `Ajouter un item` et `+` ; le
   champ et son texte doivent être alignés avec les noms des items et reprendre
   le fond du bloc.
7. Ouvrir un voyage, puis le détail d’un membre : chaque catégorie doit avoir un
   en-tête légèrement plus foncé que sa zone d’items.
8. Tester une catégorie et une liste très longues : le dernier ajout inline doit
   rester accessible au-dessus de la barre Android.
9. Refaire les contrôles 3 à 8 en mode sombre et vérifier contraste, fonds et
   lisibilité.
10. Fermer complètement puis rouvrir l’application ; vérifier la persistance de
    la catégorie et de l’item ajoutés.
11. Couper le réseau et vérifier que l’ouverture des accordéons et l’ajout local
    d’un item fonctionnent toujours.

En cas d’échec, noter l’étape, le résultat observé et joindre une capture si
possible.
