# Checklist Voyage — RC4 UX ciblée

Version Android : `1.0.0-rc.4+18`.

## Périmètre livré

- palette globale : bleu `#44C3F8`, rose `#E71345`, jaune `#F8AC34` ;
- fonds de page gris clair / neutre sombre et blocs blancs / neutres sombres ;
- contenu courant agrandi de 20 %, sans agrandir les titres principaux ni la navigation basse ;
- accueil Voyages ramené à destination, période/durée et progression ;
- accueil Listes rapides ramené au nom et à la barre de progression ;
- filtres de voyage plus compacts ;
- blocs Général, Membres et Personnel sans pictogrammes décoratifs ;
- 60 pictogrammes SVG disponibles pour les catégories ;
- écran Détails catégorie : renommage, choix d’icône et suppression ;
- ajout de catégorie directement dans un membre de voyage ;
- animation de lancement ajustée : valise plus petite et sac rose animé horizontalement.

La formulation « catégorie / sous-catégorie » conserve le modèle actuel : propriétaire ou membre → catégorie → items. Aucun niveau imbriqué supplémentaire n’a été créé.

## Portée des modifications

- Une catégorie modifiée dans la Bibliothèque modifie le modèle réutilisable correspondant.
- Une catégorie ajoutée ou modifiée dans un voyage reste propre à ce voyage.
- Les catégories Personnel suivent toujours la règle existante : elles ne sont proposées que si le propriétaire local participe au voyage, et leurs sources restent locales.
- Aucun changement de schéma Drift, d’UUID, de protocole de synchronisation, de backend PocketBase ou de PWA.

## Validation technique

- tests spécifiques RC4 : gestion des catégories, portée Bibliothèque/Voyage, thème et largeur 360 px ;
- non-régressions : hiérarchie voyage, Bibliothèque, listes rapides, génération Personnel et moteur métier ;
- modes clair et sombre couverts par les tests d’interface ;
- `flutter analyze --no-pub` : aucun problème ;
- `flutter test --no-pub` : 105 tests réussis, 5 tests réels ignorés faute de variables externes ;
- APK release signé : 63 762 899 octets ;
- SHA-256 APK : `315b1aa241c9b3c3106ab1f3b4d76bbb1b1b8ceeed96a5a1e33f69ebcf31ed21` ;
- SHA-256 du certificat : `73eda51ff7111fbb2dd70ae00db7eb36322480aae1b71a56091da2a81dd85d48` ;
- validation sur Samsung : en attente, appareil absent d’ADB au moment de la livraison.

## Protocole de validation sur téléphone

La RC4 ne devient la dernière version validée sur téléphone qu’après confirmation explicite de ce protocole.

1. Installer la RC4 comme mise à jour, sans désinstaller la version présente.
2. Vérifier que les données locales existantes sont toujours visibles après ouverture puis redémarrage complet.
3. Contrôler l’animation de lancement, l’accueil Voyages compact et le bouton unique créer/rejoindre.
4. Tester les écrans en thème clair puis sombre, notamment à largeur standard du Samsung.
5. Dans la Bibliothèque, ouvrir Général puis un membre ; renommer une catégorie, changer son icône et vérifier que ses items restent présents.
6. Dans un voyage, ajouter une catégorie sous un membre, la renommer, changer son icône puis la supprimer ; vérifier que la Bibliothèque n’est pas modifiée.
7. Créer un voyage avec le propriétaire local participant puis absent ; vérifier que Personnel est proposé uniquement dans le premier cas.
8. Vérifier les filtres compacts, les états et quantités des items, puis les listes rapides.
9. Refaire les parcours principaux en mode avion et après redémarrage.
10. Signaler le résultat sous la forme : appareil, version affichée, étape, résultat attendu, résultat observé, capture si nécessaire.
