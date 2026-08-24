# Lot 16 — Bascule contrôlée vers la RC2 release

## Résultat

Le Samsung `SM-S921B` utilise désormais l’APK **release**
`fr.checklistvoyage.app` en version `1.0.0-rc.2+16`. L’application a été
désinstallée puis réinstallée avec la clé release définitive, et la sauvegarde
V1 vérifiée a été restaurée sans perte fonctionnelle observée.

La PWA 2.63, PocketBase, Fly et le backend historique n’ont pas été modifiés.
RC2 reste une release candidate et n’est pas transformée en version finale.

## Version visible

La version affichée dans les en-têtes provient des métadonnées réellement
installées sur Android :

- un canal Android léger lit `versionName` et `longVersionCode` depuis
  `PackageInfo` ;
- Flutter expose la valeur par `AppVersionScope` ;
- les trois destinations affichent discrètement `1.0.0-rc.2 · 16`, sans ligne
  d’en-tête supplémentaire ;
- aucune version n’est écrite en dur dans les widgets et aucune dépendance
  Flutter supplémentaire n’a été ajoutée.

L’affichage a été contrôlé sur le téléphone dans Voyages, Bibliothèque et
Listes rapides, en thème clair et sombre.

## Clé et APK release

La clé release est conservée hors Git dans la configuration locale prévue au
lot 15. L’alias, l’intégration Gradle et le certificat ont été contrôlés sans
afficher ni enregistrer de mot de passe.

- certificat SHA-256 :
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48` ;
- double sauvegarde chiffrée de la clé : confirmée par le propriétaire, dans
  deux emplacements ;
- APK : `flutter_app/build/app/outputs/flutter-apk/app-release.apk` ;
- taille : 61 887 290 octets ;
- SHA-256 :
  `2B0B793AD0E55B197009988F11745F65AFF00E725DAA61A7C87688C03F52E081` ;
- package : `fr.checklistvoyage.app` ;
- version : `1.0.0-rc.2`, code `16` ;
- API minimale 24, API cible 36 ;
- ABI : `arm64-v8a`, `armeabi-v7a`, `x86_64` ;
- permissions : réseau et permission Android interne générée pour les
  receivers non exportés ; aucune permission générale de stockage ;
- signature APK v2 valide ;
- URL publique attendue présente, sans secret, token administrateur, mot de
  passe ou clé privée détecté dans l’APK.

## Manifeste avant migration

Le relevé de l’installation debug `1.0.0-rc.1+15` a donné :

- schéma Drift 7 ;
- UUID d’installation
  `41459db3-42f6-48cd-83cf-a63aa54aff04` ;
- 18 propriétaires, 47 catégories et 309 items dans les tables, dont 12
  propriétaires, 37 catégories et 296 items actifs visibles ;
- 3 voyages, 7 participants de voyage, 18 catégories de voyage, 147 items et
  147 références sources ;
- 1 liste rapide et 1 item ;
- 0 contexte et 0 association ;
- 1 document partagé avec sa capacité locale ;
- 18 tombstones et 463 états de synchronisation ;
- 0 conflit ;
- l’outbox, qui contenait 4 opérations au lot 15, a été envoyée normalement
  avant l’export final et valait 0. Aucune opération n’a été supprimée
  artificiellement.

## Sauvegardes et restauration isolée

Les sauvegardes réelles restent hors Git dans
`C:\Users\psyco\Documents\Checklist Voyage - Sauvegardes RC\Lot 16` et ne
doivent pas être supprimées.

Sauvegarde finale effectuée juste avant la bascule :

- fichier : `checklist-voyage-v1-20260824-130315.cv1backup.json` ;
- export UTC : `2026-08-24T13:03:22.730705Z` ;
- taille : 371 661 octets ;
- SHA-256 du fichier :
  `351D072A3AFA3F0220AD427C0AA20198CAC0DF412BA1BDDF81F72A562866B95A` ;
- SHA-256 interne :
  `F2D6739FE423AE39841D1634E2BC482E42CF1E205931CF441C85A36F84FB33CC`.

Cette sauvegarde exacte a été restaurée deux fois dans une base isolée. Les
21 tables, leurs relations, l’UUID, la capacité, l’outbox et tous les comptages
sont restés identiques, sans doublon.

Le sélecteur Android a également été testé de bout en bout avant la
désinstallation. Il a créé un second export réel et réutilisable :

- `android-picker-checklist-voyage-v1-20260824.cv1backup.json` ;
- SHA-256 :
  `F4E5A431A6679772A925BB7FA77DE124FF173B4C4E2EB5FC8B4471177CA1091A`.

## Désinstallation, installation et restauration réelles

Après validation de tous les points de contrôle et autorisation explicite :

- début de désinstallation : `2026-08-24T15:49:36.9330494+02:00` ;
- fin de désinstallation : `2026-08-24T15:49:37.4002044+02:00` ;
- fin d’installation de la RC2 release :
  `2026-08-24T15:49:43.9732291+02:00`.

Avant la première ouverture, Android a confirmé le code 16, le nom RC2, le
package attendu, l’absence du drapeau `debuggable` et l’empreinte release
complète. La base vierge initiale n’a pas été alimentée manuellement.

L’export Android vérifié a ensuite été restauré par le sélecteur de document.
Le dialogue annonçait 309 items de bibliothèque, 3 voyages, 1 liste rapide et
l’ancien UUID. La transaction s’est terminée normalement, puis l’application a
été fermée et relancée.

## Comparaison après restauration

Après restauration :

- UUID inchangé : `41459db3-42f6-48cd-83cf-a63aa54aff04` ;
- mêmes comptages sur les 21 tables ;
- 3 voyages et 147 items de voyage ;
- 1 liste rapide et 1 item ;
- 1 document partagé, même identifiant distant et même capacité ;
- outbox 0, conflits 0, statut `synced`, aucune erreur locale ou document ;
- les 19 tables métier autres que `installation_settings` et
  `sync_documents` sont identiques bit à bit au premier contrôle après
  restauration ;
- seules les dates et informations d’état de synchronisation de ces deux
  tables ont été actualisées par la reprise normale du réseau.

La sauvegarde finale après tous les essais est :

- `post-smoke-final-rc2.cv1backup.json` ;
- export UTC : `2026-08-24T14:08:08.994026Z` ;
- taille : 371 618 octets ;
- SHA-256 du fichier :
  `8ACC01B75E8AE6DE9BF2ADA2BEB4EAF90CA2537E7C54E3A33D1065EFC701D9AA` ;
- SHA-256 interne :
  `B34D8D00218290055891EFFAD46B7DB3C84CAE4130B065A61CFE9CBEFBF7AF9C` ;
- schéma 7, mêmes comptages, outbox 0, conflits 0, statut `synced`, aucune
  erreur.

Les valeurs utilisées pour les essais réversibles sont revenues à leur état
initial : `Babyphone` est `todo` en quantité 1 et `crampons` est non coché en
quantité 1.

## Smoke test Samsung

Contrôles réels réussis :

- version RC2 visible dans les trois destinations ;
- liste et ouverture des voyages, voyage partagé existant, Général, membre et
  catégorie ;
- filtres par état et membre, puis retour à `Tout / Tous` ;
- cycle `À préparer → Prêt → Rangé → À préparer` ;
- quantité de voyage `1 → 2 → 1` ;
- Bibliothèque Général, Membres, Personnel, catégorie, ajout inline visible et
  appui long Contextes ;
- liste rapide, coche, quantité `1 → 2 → 1` et `Tout décocher` ;
- thème sombre puis thème clair initial restauré ;
- bouton Retour Android ;
- arrêt forcé, relance complète et persistance des données ;
- synchronisation saine, outbox vide et capacité du voyage partagé utilisable.

Le téléphone ne contient aucun contexte réel ni donnée Personnel : les écrans
vides ont été contrôlés, tandis que les règles de portée restent couvertes par
les tests automatisés. Il ne contient pas de liste rapide partagée ; sa
capacité ne pouvait donc pas être testée en conditions réelles sans créer ou
partager une nouvelle donnée, ce qui était hors de ce contrôle conservateur.

## Validation automatisée

- test ciblé de version : 2 tests réussis ;
- `flutter analyze --no-pub` : aucun problème ;
- suite Flutter : 95 tests réussis ;
- 5 scénarios réels conditionnels ignorés faute de configuration dédiée ;
- build release final réussi avec la clé définitive.

## État de sécurité final

Les sauvegardes pré-migration, les exports Android et les sauvegardes
post-restauration sont conservés. La clé debug et les anciens APK n’ont pas été
supprimés. Aucun keystore, mot de passe, APK, export réel, capacité ou secret
n’est versionné.
