# Checklist Voyage — passation générale

## Référence

- Dépôt : `Meilo-rc/checklist-voyage`, branche `main`.
- Release : `1.1.1+30`, le 20 octobre 2026 ; correctif Destination/Météo basé
  sur `1.1.0+29`, commit `7a67f31`. Référence de finalisation dans l'historique Git.
- APK : `flutter_app/release/Checklist-Voyage-v1.1.1+30-release.apk`,
  64 873 273 octets, package `fr.checklistvoyage.app`.
- SHA-256 : `699B047C21BBA6CB67E05D86F6F0F0F9F0CE8A474FA232266D4486EC5102366A`.
- Signature v2 valide, certificat identique à l'APK `1.1.0+29` :
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48`.
  Mise à jour installée le 20 octobre sur le Samsung principal `SM-S921B` :
  `1.1.0+29` → `1.1.1+30`, avec `adb install -r --user 0`.
  Aucune désinstallation ni suppression de données ; téléphone de Jenna intact.

## Architecture essentielle

- Android : `flutter_app/`, Flutter/Material 3, couches écrans → cas d'usage →
  repositories ; Drift/SQLite local, schéma v8. PWA historique indépendante.
- PocketBase V1 : bibliothèque synchronisée, partage explicite voyages/listes,
  capacités et outbox d'opérations. Nouveau voyage local jusqu'au partage.
- Open-Meteo sans carte ; cache météo JSON facultatif, local et non synchronisé.

## Chantiers terminés et validations restantes

- Socle local, bibliothèque/contextes, génération, listes rapides, partage,
  archives/duplication et météo livrés ; détails dans `docs/v1/`.
- Partage Android/App Links, contrôles techniques et installation Samsung :
  [la passation de release](docs/v1/PASSATION_1.1.0_PARTAGE_ANDROID.md).
- Validation manuelle A ↔ B encore à confirmer selon
  [le protocole téléphone](docs/v1/PROTOCOLE_TELEPHONE_1.1.0.md).
- Destination/Météo : sélecteur de ville commun création/édition/duplication,
  suggestions ville/région/pays, localisation persistée dans le JSON existant,
  partage avec destination actuelle et résumé météo sans ancien résultat au
  chargement. Erreurs réseau et indisponibilité des données distinguées.
- Analyse de la copie de release : aucune anomalie. 72 contrôles ciblés réussis :
  les 67 tests Destination/Météo, plus version, contrat Android et animation de
  référence. Couverture : sélection,
  homonymes, édition, duplication, compatibilité des anciens voyages,
  redémarrage SQLite, conservation des items/états/quantités, sync simulée A ↔ B,
  partage, météo/cache et frontière J+15/J+16.
  Géocodage réel vérifié via `OpenMeteoRemote.searchCities` pour Paris (France,
  Texas et autres homonymes) et Annecy : régions, pays et coordonnées conformes.
- Compilation isolée depuis le commit de référence, avec les seuls fichiers du
  correctif et la version ajoutés. SDK global Flutter `3.47.1` / Dart `3.13.1`,
  dépendances verrouillées inchangées et signature de production existante.
  Preuves dans `flutter_app/build/release_1_1_1_30/` : géocodage, validation APK
  et manifestes des sources. Protocole :
  [validation téléphone 1.1.1](docs/v1/PROTOCOLE_TELEPHONE_1.1.1.md).
- Installation contrôlée : package/version/signature vérifiés avant mise à jour ;
  SHA-256 de l'APK installée identique au livrable. Répertoire, date initiale
  d'installation et identifiants de stockage Android inchangés. Les deux voyages
  visibles gardent exactement leurs dates, totaux d'items et progressions.
  Démarrage à froid réussi, accueil `1.1.1 · 30` affiché, processus stable et
  aucune erreur fatale relevée dans les journaux de ce démarrage.
  Preuves locales ignorées : `flutter_app/build/install_1_1_1_30/`.
- Validation téléphone : essais fonctionnels Destination/Météo réussis sur le
  Samsung principal, confirmés par l'utilisateur le 20 octobre 2026.
  La synchronisation réelle avec le téléphone de Jenna reste à valider.

## Problèmes ouverts et décisions prises

- Destination nouvelle/remplacée : sélection obligatoire ; retaper invalide la
  sélection. Destination inchangée : JSON complet conservé, même sans coordonnées.
- Décision confirmée : pour la météo d'un ancien voyage sans coordonnées,
  demander une sélection dans Modifier, sans invalider l'édition de ses dates.
  Aucun premier résultat géocodé ni ancien cache de géocodage n'est choisi.
- Dupliquer réutilise une localisation existante ; sinon sélection obligatoire.
  Aucun champ Nom indépendant. Source, états et quantités restent intacts ;
  les états de la copie repartent à préparer selon le comportement existant.
- Frontière corrigée : J+15 inclus en prévision, J+16 en tendance habituelle.
  Décalage confirmé dans le [code officiel Open-Meteo](https://github.com/open-meteo/open-meteo/blob/main/Sources/App/Controllers/ForecastapiController.swift)
  (`forecastDaysMax = 16`, borne de fin exclusive).
- Choix de génération figés à l'édition : aucune régénération automatique.
- Le lanceur du dépôt reste inchangé : seul son choix du SDK est redirigé dans
  la copie isolée. Échec initial sur un dossier temporaire existant résolu par
  un TEMP/TMP dédié, sans suppression de ce dossier. Le test de contrat Android,
  initialement privé de son chemin voisin, a réussi avec un lien vers les sources
  PocketBase locales de la copie ; aucun serveur contacté par ce test.
- Flutter a ajouté des exclusions à `analysis_options.yaml` dans la copie de
  compilation seulement. Avertissement SDK XML v4/v3 non bloquant au build.
- Animation préexistante préservée, empreintes des quatre fichiers inchangées ;
  animation du commit de référence dans la release, contrôlée dans l'archive.
- L'accès direct à la base privée est interdit par cette release non débogable :
  conservation vérifiée par les marqueurs Android et l'accueil avant/après,
  sans contrôle exhaustif de chaque donnée interne.
- Géocodage réel, installation, démarrage et essais fonctionnels Destination/Météo
  validés. Convergence réelle A ↔ B non testée avec Jenna. Aucun changement de
  schéma ou backend, aucun déploiement PocketBase ni installation sur son téléphone.

## Prochaine étape

Valider la synchronisation réelle de la destination et de ses coordonnées avec
le téléphone de Jenna selon le protocole 1.1.1. Toute installation sur son
téléphone nécessite une instruction explicite.
Aucune décision fonctionnelle ne reste en attente pour ce correctif.
