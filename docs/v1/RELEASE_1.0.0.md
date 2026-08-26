# Checklist Voyage 1.0.0

## Release

- version Android : `1.0.0+27` ;
- applicationId : `fr.checklistvoyage.app` ;
- schéma local Drift : `8` ;
- APK : `Checklist-Voyage-v1.0.0-release.apk` ;
- SHA-256 APK : `01CFD75E12A8CD9A61D44909C6F6CB747829556A5D62F1FA89CDB03CD6EFD5C2` ;
- certificat SHA-256 : `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48` ;
- signature Android APK v2 : valide ;
- baseline de repli : `1.0.0-rc.12+26`.

La release a été installée par mise à jour sur le Samsung de référence, sans
désinstallation. Le `firstInstallTime` Android est resté inchangé. Le protocole
téléphone a été validé par l'utilisateur le 26 août 2026. Le tag Git `v1.0.0`
est créé uniquement après cette validation.

## Contrôles finaux

- `flutter analyze --no-pub` : aucune erreur ;
- suite complète : 132 tests réussis ;
- 5 tests d'intégration ponctuels ignorés faute de variables réelles, comme
  prévu par leurs conditions d'exécution ;
- base réelle du téléphone : sauvegarde schéma 8 inspectée, restaurée deux fois
  dans une base temporaire et réexportée avec les mêmes volumes ;
- sauvegarde réelle : 312 items, 5 voyages, 1 liste rapide, 3 documents
  partagés, aucune opération en attente et aucun conflit ;
- Personnel : aucune entité Personnel dans les états de synchronisation ;
- tombstones : aucun tombstone en attente de propagation ;
- backend V1 dédié, PWA historique et backend historique : réponses HTTP 200 ;
- permissions applicatives : accès réseau uniquement ;
- aucun secret, keystore, fichier d'environnement, sauvegarde réelle ou APK
  suivi dans Git.

La sauvegarde réelle récente est conservée hors du dépôt. L'APK stable et le
backup RC12 validé sont également conservés dans le dossier Drive `Appli`, sans
suppression des anciens fichiers.

## Compatibilité et sécurité

La PWA 2.63 continue d'utiliser son backend historique et reste disponible. La
V1 utilise exclusivement le backend Checklist dédié et les routes `cv1_*`.

La V1 repose volontairement sur un UUID d'installation et des capacités de
partage, sans compte utilisateur. Cela convient à la V1 mais ne constitue pas
une authentification forte d'un foyer.

## Dette non bloquante pour V1.1

- introduire une identité utilisateur/foyer avant d'exiger une isolation forte ;
- planifier séparément les mises à jour de `flutter_svg`, `build_runner` et des
  dépendances transitives, sans les mélanger à cette release ;
- remplacer le wrapper Windows historique fondé sur une jonction vers le SDK
  d'un autre projet par le SDK Flutter global déjà validé ;
- retirer le commentaire Android de modèle `TODO` devenu obsolète ;
- automatiser périodiquement les cinq tests réels conditionnels avec des
  environnements isolés.
