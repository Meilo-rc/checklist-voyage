# Checklist Voyage — RC6 échelle typographique et Bibliothèque

Version Android : `1.0.0-rc.6+20`.

## Échelle typographique

Toute l’application utilise désormais cinq tailles fixes en pixels logiques
Flutter. Le réglage d’accessibilité de la taille du texte Android continue à
s’appliquer par-dessus cette échelle.

1. **22 px, gras** : titres de page. Aucun style de l’application ne dépasse
   cette taille.
2. **18 px, gras** : Général / Membres / Personnel, catégories dans la page
   d’un membre et titres des listes rapides.
3. **16 px, gras** : lignes hiérarchiques sous Général / Membres / Personnel
   dans un voyage et dans la Bibliothèque.
4. **14 px** : contenu et items ; les pastilles de filtres utilisent cette
   taille en gras.
5. **12 px** : dates, compteurs, pourcentages et métadonnées de Bibliothèque.

La Bibliothèque n’affiche pas de pourcentage de préparation : ses items n’ont
pas d’état `todo / checked / done`. Inventer un pourcentage à cet endroit serait
contraire au modèle métier. Elle affiche donc le nombre de catégories et le
nombre d’items en taille 5.

## Navigation Bibliothèque

- Général, Membres et Personnel sont trois accordéons sur la page principale,
  comme dans un voyage.
- Un accordéon affiche les propriétaires ou membres correspondants.
- Toucher un propriétaire ou un membre ouvre sa page de catégories.
- Toucher une catégorie ouvre une page dédiée contenant ses items.
- Le titre de cette page est le nom de la catégorie, en taille 1 et en gras.
- L’ajout d’une catégorie ou d’un item reste inline.
- Les gestes existants sont conservés : swipe pour modifier/supprimer et appui
  long sur un item pour ses contextes.

## Portée technique

- aucun changement de schéma Drift ni migration de données ;
- aucune modification du moteur métier, de la génération ou des quantités ;
- aucune modification du partage, de la synchronisation ou de PocketBase ;
- aucune modification de la PWA 2.63.

## Validation technique

- `flutter analyze --no-pub` : aucun problème ;
- `flutter test --no-pub` : 105 tests réussis, 5 tests réels ignorés faute de
  variables externes ;
- tailles 22 / 18 / 16 / 14 / 12 vérifiées par tests ;
- parcours à 360 px vérifiés en clair et en sombre ;
- navigation Retour Android, édition inline, contextes et persistance couverts.
- APK release signé : 63 762 896 octets ;
- SHA-256 APK :
  `cdab4d4a82b650f32cf36d7f3ca5069ad5e92412c96bbd864a4eb577af8f599b` ;
- SHA-256 du certificat :
  `73eda51ff7111fbb2dd70ae00db7eb36322480aae1b71a56091da2a81dd85d48` ;
- installation ADB sur Samsung SM-S921B : mise à jour réussie, données non
  effacées d’après la conservation de `firstInstallTime` ;
- copie Drive vérifiée : 63 762 896 octets.

## Protocole téléphone ciblé

La RC6 ne devient pas une version validée sur téléphone avant confirmation de
ce protocole. La dernière sauvegarde validée reste la RC2.

1. Installer `1.0.0-rc.6+20` comme **mise à jour**, sans désinstaller
   `fr.checklistvoyage.app`.
2. Ouvrir l’application et vérifier que les voyages, la Bibliothèque, Personnel
   et les listes rapides existants sont toujours présents.
3. Sur Voyage, vérifier que le titre de page est le plus grand texte et que
   Général / Membres / Personnel sont un cran en dessous.
4. Vérifier ensuite les lignes sous ces accordéons, les filtres, puis la date et
   la progression : chaque niveau doit être visiblement plus petit que le
   précédent, sans texte supérieur au titre de page.
5. Ouvrir un membre : le titre de page doit être en 22 px, les catégories en
   18 px gras et les items en 14 px.
6. Sur Bibliothèque, ouvrir et fermer séparément Général, Membres et Personnel.
   Vérifier que les nombres de catégories et d’items restent lisibles sur une
   seule ligne.
7. Toucher un membre ou propriétaire, puis une catégorie. Vérifier que chaque
   toucher change bien de page et que la page finale porte le nom de la
   catégorie en titre gras.
8. Dans cette page, ajouter un item inline, modifier sa quantité, le renommer
   par swipe et ouvrir ses contextes par appui long.
9. Revenir en arrière et vérifier que l’item et la catégorie sont conservés.
10. Sur Listes rapides, vérifier que chaque titre de liste est en 18 px gras,
    sans dépasser le titre de page.
11. Refaire les étapes 3 à 10 en thème sombre, puis contrôler à nouveau en
    thème clair.
12. Activer le mode avion, fermer complètement l’application, la rouvrir et
    vérifier que les données et les parcours principaux restent disponibles.

En cas d’échec, indiquer le numéro d’étape, le résultat observé, le résultat
attendu et joindre une capture si possible.
