# Checklist Voyage — passation générale

## Validation complète 1.1.2+31 — deux Samsung, 22 octobre 2026

- Installation par `adb install -r --user 0`, principal puis Jenna. Package, version et signature vérifiés ; dates initiales d’installation et identités locales conservées. Exports avant/après installation : aucune table métier modifiée.
- Six scénarios réels réussis sur Palma : principal → Jenna ; Jenna → principal ; rafale (5 variations en 0,64 s, plus états) ; coupure/retour des données mobiles avec 3 opérations conservées hors ligne ; arrière-plan/reprise sans changement de processus ; réception avec Palma laissé ouvert sur les deux appareils. Aucun redémarrage forcé, nouvelle jointure ou synchronisation manuelle pendant ces essais.
- Final : révision **440** sur les deux Samsung, **188 items identiques**, **61 terminés**, **17 cochés**, **32 %**, noms/états/quantités identiques. Items d’essai revenus à leurs valeurs de départ par les commandes normales. Files d’envoi totalement vides, erreurs Palma nulles, aucun nouveau conflit Palma.
- Autres données métier conservées, hors archivage Djerba préexistant chez Jenna, transmis après accord explicite de l’utilisateur. Djerba archivé sur les deux appareils ; nom, destination et dates conservés. Aucun accès direct en écriture à PocketBase, aucun import, restauration, purge ou effacement.
- Exports originaux conservés. Preuves locales : `flutter_app/build/install_1_1_2_31/` (exports, captures, journaux, scénarios, `final-concordance.json`). Réglages temporaires de maintien de l’écran rétablis ; appareils connectés aux données mobiles comme avant les essais.
- Essais réels effectués par Codex via ADB, puis **confirmés par l’utilisateur le
  22 octobre 2026**. Clôture Git du correctif, des tests et de la documentation
  autorisée sur `main`. Animation préexistante strictement exclue du commit ;
  référence du commit de clôture dans l’historique Git. Aucune nouvelle
  installation, intervention backend ou modification des données pour la clôture.

## Synchronisation automatique — version validée 1.1.2+31 (22 octobre 2026)

- Périmètre : déclenchement, sérialisation, reprises et réception des voyages
  partagés. Aucun changement de schéma (v8), de protocole, de partage ou de
  PocketBase. Aucun accès aux téléphones ou au serveur pendant la préparation du code.
- Incident Palma : les deux Samsung en `1.1.1+30` ont été récupérés avant ce
  chantier ; convergence réelle à la révision 414, files Palma vides, voyage
  actif, 188 items identiques (61 terminés, 17 cochés). Exports avant/après
  conservés hors dépôt. Ce rattrapage ne validait pas l'automatisme de +30.
- Cause reproduite : `onTripOperationQueued` est appelé dans la transaction
  métier ; `Timer.run` héritait de sa Zone Drift. Une transaction tenue ouverte
  puis committée laisse une opération non envoyée, sans `last_error`, avec le
  coordinateur de référence. La capture de la Zone à la création du coordinateur
  fait passer le même test : pas de réseau avant commit, puis acquittement.
  Les lectures initiales hors `try` et l'absence de retry aggravaient le défaut.
  Le journal de l'incident historique ne prouve pas sa cause exclusive ; la
  reproduction établit le défaut du code livré, cohérent avec le rattrapage
  réussi après redémarrage hors ligne et ouverture ciblée avec Wi-Fi.
- Correctif : déclenchement hors Zone transactionnelle, regroupement des taps
  sur 100 ms, une exécution par document avec redemande coalescée, reprise des
  opérations existantes dans leur ordre et avec leurs UUID inchangés.
  En cas d'échec : erreur persistée et délais 2/5/15/30/60 secondes, puis 60 s ;
  suspension en arrière-plan et reprise de lecture/envoi au retour dans l'app.
  Pendant l'ouverture du voyage, réception toutes les 15 s (également suspendue
  par le coordinateur en arrière-plan ; ces lectures peuvent avancer un retry).
  Aucun service Android ni nouvelle dépendance de réseau.
- Une mutation arrivée pendant un pull empêche l'application de sa page dans
  une transaction atomique : envoi des opérations locales, puis relecture sans
  avancer le curseur. Évite un retour temporaire à un ancien état avant le tap
  suivant. Résolution des conflits existante inchangée.
- Retour discret dans le voyage : « Partage en attente », conservation locale,
  nouvelle tentative automatique et bouton Réessayer. Aucun corps d'erreur
  serveur ou secret de partage affiché ; disparition après une réception réussie.
- Sources de preuve : `shared_document_auto_sync_test.dart` (transaction/rollback,
  rafales, concurrence, réseau, panne serveur, réponse perdue, pause en plein
  envoi, deux installations, fichier SQLite rouvert avec 173 opérations et
  réception paginée), `shared_document_auto_sync_ui_test.dart` (reprise depuis
  l'accueil, réception sans navigation exceptionnelle, erreur et clair/sombre).
- Validation technique : analyse Flutter sans anomalie, **49 tests ciblés
  réussis**, dont 15 nouveaux tests de reprise/transaction/erreur et interface.
  Exécution sur la copie isolée, avec l'animation de référence. Journaux dans
  `flutter_app/build/release_1_1_2_31/` : analyse, tests, compilation et rapport
  `apk-validation.json`. Construction par `scripts/build_release.ps1` dans la
  copie isolée ; seule la sélection du SDK de son lanceur est redirigée vers
  Flutter 3.47.1 / Dart 3.13.1, comme pour +30. Lanceurs du dépôt inchangés.
  Avertissement SDK XML v4/v3 non bloquant, compilation réussie.
- APK locale de test :
  `flutter_app/release/Checklist-Voyage-v1.1.2+31-rc.apk`, 64 889 672 octets,
  package `fr.checklistvoyage.app`, version `1.1.2`, code `31`.
  SHA-256 : `3528E44270CE0FEB3291F577A57293A80FB6D630815304CC851191790B21A697`.
  Signature v2 valide, un signataire, certificat de production identique à +30
  (empreinte dans la référence ci-dessous). Release native ARM64/ARMv7/x86_64,
  aucun kernel de débogage. Empreintes de l'animation locale inchangées et
  dépendances verrouillées identiques ; seule `analysis_options.yaml` adaptée
  automatiquement par Flutter dans la copie, sans modification du dépôt.
  APK +30 conservée à empreinte identique. **Aucune installation effectuée pendant la préparation de l’APK**,
  aucun commit/push, aucun accès à PocketBase ni modification des données réelles
  pendant le développement de ce correctif.
- Validation réelle du correctif : **six scénarios réussis sur les deux Samsung**
  (résultats ci-dessus), validation confirmée par l’utilisateur. Protocole :
  [1.1.2+31](docs/v1/PROTOCOLE_TELEPHONE_1.1.2.md). Conserver l'APK +30 et les
  sauvegardes. Ne pas désinstaller, restaurer, purger ou refaire une jointure.
- Animation locale préexistante exclue de la candidate : compilation isolée
  depuis `e445f08` avec uniquement ce correctif. Empreintes du travail local
  contrôlées séparément ; clôture Git autorisée après validation, sans déploiement.

## Référence précédente conservée — 1.1.1+30

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
- Protocole historique A ↔ B :
  [validation 1.1.0](docs/v1/PROTOCOLE_TELEPHONE_1.1.0.md).
  Convergence +30 récupérée à 414 ; validation automatique +31 distincte.
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
  La synchronisation réelle avec Jenna a depuis été récupérée à la révision 414
  (voir l'incident ci-dessus) ; l'automatisme du correctif +31 reste à valider.

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
  validés à la livraison +30. La convergence A ↔ B a ensuite été récupérée à 414
  sur les deux Samsung ; le correctif automatique +31 n'est pas encore installé.
  Aucun changement de schéma ou backend ni déploiement PocketBase pour ce correctif.

## Prochaine étape

Correctif 1.1.2+31 validé techniquement et sur les deux Samsung, confirmé par
l’utilisateur. Aucune validation fonctionnelle restante pour ce chantier.
Conserver les APK et les exports de sécurité existants. Les travaux locaux
d’animation restent séparés du correctif de synchronisation.
