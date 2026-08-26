# Checklist Voyage — RC10 météo du voyage

Version Android : `1.0.0-rc.10+24`.

## Fonction livrée

- résumé météo compact sur la fiche Voyage, sans modification de la checklist ;
- page `Météo — destination` avec les vues `Carte` et `Prévisions` ;
- données journalières : condition, minimum, maximum, pluie et vent ;
- libellé explicite `Prévision` ou `Tendance habituelle` pour chaque jour ;
- séjour mixte géré jour par jour : les journées couvertes passent en prévision
  sans attendre que tout le séjour soit couvert ;
- carte régionale OpenStreetMap déplaçable et zoomable, recentrage inclus ;
- grille fixe 3 × 3, soit neuf points météo dont la destination ;
- changement de jour limité aux marqueurs et aux valeurs : le fond et le
  contrôleur de carte sont conservés ;
- attribution visible d’Open-Meteo et d’OpenStreetMap.

## Sources et calculs

RC10 interroge directement les API officielles Open-Meteo :

- Geocoding API pour une destination sans coordonnées ;
- Forecast API pour les prévisions journalières ;
- Historical Weather API pour les tendances habituelles.

La frontière Forecast est inclusive : aujourd’hui à J+16 utilise
`Prévision`. Un jour passé ou au-delà de J+16 utilise `Tendance habituelle`.
L’horloge est injectée et testable.

La tendance historique utilise les cinq années complètes précédentes et
uniquement la même période calendaire que le séjour. Les neuf coordonnées sont
groupées dans chaque requête. Températures et vent sont moyennés, la condition
est le code météo modal et la probabilité de pluie habituelle correspond à la
fréquence des journées ayant au moins 0,1 mm.

Une première approche téléchargeant dix années complètes pour les neuf points
a été rejetée après échec du contrôle de charge. La méthode ciblée finale a été
mesurée sur un séjour de 20 jours : cinq requêtes groupées, 53 639 octets au
total et 1,39 seconde dans l’environnement de développement.

## Carte et cache

- librairie : `flutter_map 8.3.1` ;
- fond : tuiles OpenStreetMap avec attribution et identifiant d’application ;
- zoom régional initial : `4.6` ;
- grille : trois latitudes × trois longitudes, avec largeur corrigée selon la
  latitude et neuf points maximum ;
- cache de tuiles natif de `flutter_map` ;
- cache météo JSON local dans le répertoire de support de l’application,
  versionné indépendamment de la base métier ;
- prévisions considérées fraîches pendant 6 heures ;
- tendances historiques considérées fraîches pendant 90 jours ;
- géocodage, journées de la destination, grille, sources et timestamps
  conservés ;
- clé de cache calculée à partir de la destination, des coordonnées et des
  dates : une modification ne peut pas afficher l’ancienne météo ;
- hors ligne avec cache : dernière donnée affichée avec indicateur discret ;
- hors ligne sans cache : `Météo indisponible hors ligne`.

Le schéma Drift reste en v8. Aucune migration, aucune table météo, aucun champ
de synchronisation, aucune collection PocketBase et aucune modification de la
PWA ou du backend n’ont été ajoutés. Le cache météo est facultatif et ne fait
pas partie de la sauvegarde métier V1.

Open-Meteo ne reçoit que destination pendant le géocodage, puis coordonnées,
dates et variables météo. Aucun UUID, code de partage, capacité ou donnée de
bibliothèque n’est transmis.

## Validation technique

- `flutter analyze --no-pub` : aucune anomalie ;
- suite Flutter : 131 tests réussis ;
- 5 contrôles réels conditionnels ignorés faute de variables externes ;
- J-30, J-17, J-16, J-10, voyage passé, séjour mixte et séjour entièrement
  couvert testés avec horloge injectée ;
- grille, coordonnées, cache, persistance, expiration et hors ligne testés ;
- changement de jour avec fond `FlutterMap` inchangé et marqueurs remplacés
  testé sans tuile réseau ;
- 10 et 20 jours à 360 px en clair et sombre sans overflow ;
- formats réels Open-Meteo contrôlés pour géocodage, prévision multi-points et
  historique multi-points ;
- APK release : 66 221 264 octets ;
- SHA-256 APK :
  `4082C21B16AAA801946636605E298E8D85023A03C36F0E4949F221CFBE700F7A` ;
- signature APK v2 valide ;
- certificat SHA-256 :
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48` ;
- package : `fr.checklistvoyage.app` ; code Android `24`.

Le téléphone étant débranché à la fin du chantier, RC10 n’a pas été installée
ni validée sur le Samsung. RC9 reste la dernière version validée sur téléphone
et doit rester disponible comme sauvegarde jusqu’à confirmation de RC10.

Les deux APK ont été publiées et relues dans le dossier Drive `Appli` :

- RC10 à tester :
  `Checklist_Voyage_1.0.0-rc.10+24_release.apk`, 66 221 264 octets ;
- sauvegarde validée :
  `BACKUP_VALIDEE_Checklist_Voyage_1.0.0-rc.9+23_release.apk`,
  63 943 489 octets.

Les anciennes RC7 et RC8 déjà présentes sur Drive n’ont pas été supprimées :
le contrôle de sécurité du connecteur a refusé leur remplacement destructif.
Aucun fichier d’une autre application n’a été modifié.

## Protocole de validation sur téléphone

1. Installer `Checklist-Voyage-1.0.0-rc.10+24.apk` depuis Drive comme mise à
   jour, sans désinstaller `fr.checklistvoyage.app`.
   Résultat attendu : Android propose `Mettre à jour`, pas une nouvelle
   installation.
2. Ouvrir l’application et vérifier `1.0.0-rc.10 · 24` ainsi que la présence
   des Voyages, de la Bibliothèque et des Listes rapides existants.
3. Ouvrir un voyage ayant une destination et des dates. Vérifier le petit bloc
   `Météo`, sa température et son libellé `Prévision` ou
   `Tendance habituelle`. Aucun item ne doit changer.
4. Toucher le bloc. Vérifier le titre `Météo — destination`, les onglets
   `Carte` et `Prévisions` et l’attribution Open-Meteo.
5. Dans `Prévisions`, contrôler plusieurs journées : date, icône, condition,
   minimum/maximum, pluie, vent et source doivent rester lisibles.
6. Contrôler si possible un voyage à moins de 16 jours : les jours couverts
   doivent indiquer `Prévision`.
7. Contrôler un voyage lointain : les jours doivent indiquer
   `Tendance habituelle`, jamais `Prévision`.
8. Pour un séjour dépassant la fenêtre des 16 jours, vérifier la présence des
   deux libellés dans la liste.
9. Dans `Carte`, vérifier une vue régionale avec neuf icônes maximum et la
   destination au centre.
10. Changer plusieurs fois de jour. Le fond ne doit ni clignoter ni se
    recentrer ; seules les icônes et le résumé doivent changer rapidement.
11. Tester déplacement, zoom +/− et recentrage. Le bouton de recentrage doit
    revenir sur la destination avec la vue régionale.
12. Fermer la page météo, la rouvrir et vérifier que les données apparaissent
    rapidement depuis le cache, sans rafale visible de chargements.
13. Après un premier chargement réussi, couper complètement le réseau et
    rouvrir la météo. Les dernières données et les tuiles déjà consultées
    doivent rester disponibles autant que le cache de carte le permet, avec un
    indicateur discret si les données ont vieilli.
14. Hors ligne, ouvrir un voyage dont la météo n’a jamais été chargée. Vérifier
    `Météo indisponible hors ligne` et confirmer que la checklist reste
    entièrement utilisable.
15. Modifier temporairement la destination ou les dates d’un voyage de test.
    Vérifier qu’aucune météo de l’ancienne destination n’est affichée.
16. Refaire Carte et Prévisions en thème sombre puis clair, en portrait à la
    largeur habituelle du Samsung. Aucun texte, onglet, jour ou contrôle ne doit
    déborder.
17. Fermer complètement puis relancer l’application. Vérifier les données
    Checklist, le cache météo, les états d’items et les quantités.
18. Vérifier enfin que la synchronisation habituelle se termine sans erreur et
    que l’outbox ne contient pas d’anomalie nouvelle.

En cas d’échec, noter le numéro de l’étape, le résultat observé et joindre une
capture si possible. RC10 ne devient la version validée sur téléphone qu’après
confirmation explicite de ce protocole.
