# Checklist Voyage — RC5 hiérarchie typographique

Version Android : `1.0.0-rc.5+19`.

## Correction

L’agrandissement global de 20 % introduit dans la RC4 est retiré. Le contenu courant revient aux tailles Material Android normales.

Trois styles métier sont centralisés dans le thème :

- nom d’un membre dans un voyage : 20 pixels logiques, semi-gras ;
- titre de la page d’un membre : 24 pixels logiques, gras ;
- nom d’une catégorie du voyage : 19 pixels logiques, semi-gras.

Les noms d’items reviennent à 14 pixels logiques. Le réglage d’accessibilité de la taille du texte Android reste appliqué par Flutter.

## Portée

- aucune modification du modèle Drift ;
- aucune migration de données ;
- aucune modification du moteur métier, du partage ou de la synchronisation ;
- aucun changement de PocketBase ou de la PWA ;
- modes clair et sombre inchangés.

## Validation technique

- `flutter analyze --no-pub` : aucun problème ;
- `flutter test --no-pub` : 105 tests réussis, 5 tests réels ignorés faute de variables externes ;
- tests directs à 360 px : membre 20, titre de membre 24, catégorie 19 et item 14 ;
- APK release signé : 63 762 905 octets ;
- SHA-256 APK : `cc90d6db6a624cdc208ba70eed3c703181b57b5140120c7af82e2736084e015c` ;
- SHA-256 du certificat : `73eda51ff7111fbb2dd70ae00db7eb36322480aae1b71a56091da2a81dd85d48`.

## Protocole téléphone ciblé

1. Installer la RC5 comme mise à jour, sans désinstaller l’application.
2. Vérifier que les données existantes sont présentes après ouverture et redémarrage.
3. Ouvrir un voyage et comparer les noms de membres aux textes secondaires.
4. Ouvrir un membre : son titre doit être plus visible que le titre standard d’une page.
5. Vérifier que les catégories sont nettement distinctes des items sans augmenter excessivement la hauteur des lignes.
6. Contrôler les mêmes écrans en clair et en sombre.
7. Vérifier à nouveau l’accueil, la Bibliothèque, les listes rapides et les dialogues : leurs textes doivent être revenus à une taille normale.
8. Refaire le parcours principal en mode avion puis après redémarrage.
