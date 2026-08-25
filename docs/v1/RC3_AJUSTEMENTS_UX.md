# RC3 — Ajustements UX et intégration de Personnel

## Version livrée

- application : `Checklist Voyage` ;
- paquet Android : `fr.checklistvoyage.app` ;
- version : `1.0.0-rc.3+17` ;
- APK : `Checklist_Voyage_1.0.0-rc.3+17_release.apk` ;
- signature SHA-256 du certificat : `73eda51ff7111fbb2dd70ae00db7eb36322480aae1b71a56091da2a81dd85d48` ;
- SHA-256 de l'APK : `30591F2644EB235AB4B67659904D5C1EFB471BBEC6340672122CECB66B52A101` ;
- taille : `63 669 950` octets.

## Ajustements visuels

- palette officielle appliquée globalement en clair et en sombre : bleu `#44C3F8`, rose `#E71345`, jaune `#F8AC34` ;
- nouvel écran de lancement et visuel d'accueil `checklist.webp` ;
- page Voyages plus compacte, avec un seul bouton d'action ouvrant les choix Créer/Rejoindre ;
- cartes de voyage condensées : dates, durée et progression sur des lignes compactes ;
- actions secondaires regroupées dans des menus discrets ;
- détail d'un voyage regroupé en vrais blocs accordéon Général, Membres et Personnel ;
- en-têtes Bibliothèque et Listes rapides simplifiés sans retirer les fonctions existantes.

## Personnel dans la création d'un voyage

Personnel n'est pas un bloc d'affichage artificiel. Le flux métier est le suivant :

1. les catégories `personal_local` ne sont proposées que si leur propriétaire local est lié à un participant sélectionné ;
2. elles apparaissent dans une section Personnel avec sélection multiple ;
3. seules les catégories sélectionnées alimentent le voyage ;
4. le voyage conserve un choix `personal_category` et des sources stables de type `personal` ;
5. le groupe généré est un véritable groupe Personnel dans la hiérarchie du voyage ;
6. la bibliothèque Personnel, ses catégories, ses items et leurs UUID restent locaux ;
7. lors du partage, seuls les items autonomes déjà copiés dans le voyage sont synchronisés : aucun choix, UUID de propriétaire, catégorie ou item Personnel n'est envoyé.

Le schéma Drift n'a pas changé : les colonnes génériques de `trip_generation_choices`, des groupes et des sources représentaient déjà ce cas. Aucune migration locale n'a donc été ajoutée.

## Compatibilité

- aucune modification du backend PocketBase ni de ses collections ;
- aucune modification de la PWA 2.63 ;
- aucune réinitialisation ou réimportation imposée aux bases locales existantes ;
- installation Android prévue comme mise à jour en place, avec la même identité d'application et la même signature.

## Validation

- `flutter analyze --no-pub` : aucune anomalie ;
- tests Flutter : `101` réussis, `5` ignorés car ils nécessitent des paramètres réels externes ;
- tests dédiés Personnel : sélection conditionnelle, catégories choisies uniquement, persistance des sources, absence de fuite lors du partage et affichage à 360 px en sombre ;
- APK release signé et métadonnées Android vérifiés.
