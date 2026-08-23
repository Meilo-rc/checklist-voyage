# Lot 15 — Préparation RC Android

## Décision de signature

Le package définitif reste `fr.checklistvoyage.app`.

- APK actuellement installée : certificat debug
  `C85970E942442A54EE5ABB3157C8E6440E394844AF73569ED33287A194BE1CB5`.
- Clé release créée hors dépôt : certificat
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48`.
- Android n’accepte une mise à jour que si l’ancien et le nouvel APK sont
  signés par la même identité, sauf lignée de rotation préparée à l’avance.
  Aucune lignée n’existe pour la clé debug actuelle.

Conséquence : une RC signée avec la clé debug peut mettre à jour l’application
actuelle sans perte, mais la première APK signée avec la clé release exigera une
réinstallation. Cette APK release ne doit pas être installée sur le Samsung
principal avant sauvegarde contrôlée et procédure de restauration.

La clé release et son fichier de propriétés sont dans
`C:\Users\psyco\.checklist-voyage\signing`. La variable utilisateur
`CHECKLIST_VOYAGE_SIGNING_PROPERTIES` désigne le fichier de propriétés. Ces
deux fichiers sont secrets, ignorés par Git et doivent être sauvegardés ensemble
dans au moins deux emplacements chiffrés, dont un hors de ce PC. Perdre cette
clé empêcherait toutes les futures mises à jour de l’application release.

## Version et builds

RC1 utilise `1.0.0-rc.1+15` : `versionName=1.0.0-rc.1` et
`versionCode=15`, donc supérieur au code 14 installé.

- Debug de continuité : `flutter build apk --debug --no-pub` ; signature debug
  inchangée et mise à jour directe possible.
- Release : `scripts/build_release.ps1` ; le build échoue explicitement si la
  configuration de signature locale est absente.
- Exemple sans secret : `flutter_app/android/key.properties.example`.
- Aucun minify, shrink ou obfuscation n’est activé pour RC1.

La release universelle contient `arm64-v8a`, `armeabi-v7a` et `x86_64`. La
séparation par ABI pourra réduire la taille plus tard sans modifier le métier.

Résultats du lot :

- APK debug : construite puis installée avec `adb install -r`, sans
  désinstallation ;
- APK release : 61 887 298 octets, SHA-256
  `1FFE24549AD8017A7BB0D753FD864EE1F07A1E976D03A1F908118A4DCB29F680` ;
- la release n’a pas été installée sur le Samsung principal ;
- `flutter analyze --no-pub` : aucun problème ;
- suite Flutter : 93 tests réussis et 5 scénarios réels conditionnels ignorés.

## Sauvegarde locale V1

Le format `checklist-voyage-v1-safety-backup` exporte transactionnellement les
21 tables du schéma 7, notamment :

- UUID d’installation et curseurs de synchronisation ;
- Général, Membres, Personnel et contextes ;
- voyages/listes locales et partagées, items, états et quantités ;
- références sources, tombstones et historique de migration ;
- documents, capacités de partage, outbox et états de synchronisation.

Le fichier contient une empreinte SHA-256 interne. Le script Android produit
également une empreinte du fichier et un manifeste de comptages. Comme les
capacités de partage sont des secrets d’accès, l’export doit être protégé comme
un mot de passe et ne doit jamais être commité.

Commande avant toute réinstallation :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File .\scripts\backup_android_v1.ps1 `
  -OutputDirectory "D:\Sauvegardes\Checklist Voyage"
```

L’application est arrêtée brièvement pour obtenir une copie SQLite cohérente,
puis rouverte. Le script ne désinstalle rien et ne modifie aucune table.

L’application possède aussi, dans le menu sécurité de Bibliothèque :

- `Exporter sécurité V1`, via le sélecteur de document Android et sans
  permission générale de stockage ;
- `Restaurer sécurité V1`, avec contrôle de format, schéma, empreinte,
  comptages et confirmation explicite.

La restauration remplace toutes les tables dans une transaction : un échec
annule tout. Elle est idempotente et ferme ensuite l’application pour forcer un
redémarrage propre.

## Procédure humaine pour la première release signée définitivement

1. Sauvegarder le keystore et son fichier de propriétés hors du PC.
2. Mettre le Samsung en mode avion.
3. Depuis l’APK debug, exporter une sauvegarde V1 et copier le fichier sur un
   second support.
4. Vérifier son manifeste, son SHA-256, son UUID, son schéma et ses comptages.
5. Restaurer ce fichier deux fois dans une base de test et comparer les
   comptages, comme le fait `tool/v1_safety_backup.dart`.
6. Seulement après ces contrôles, désinstaller manuellement l’APK debug.
7. Installer l’APK release signée avec le certificat `73ED…5D48`.
8. Conserver le mode avion, ouvrir Bibliothèque → menu sécurité → Restaurer,
   sélectionner l’export et laisser l’application se fermer.
9. Rouvrir hors ligne et vérifier UUID, Personnel, voyages, listes, états,
   quantités, partages et outbox.
10. Réactiver le réseau et vérifier la reprise de synchronisation.

Les étapes 6 à 10 sont volontairement hors lot 15 sur le Samsung principal.

## Backend et données uniquement locales

Le backend peut reconstruire Général, Membres, contextes partagés et les
documents partagés encore accessibles avec leur capacité. Il ne peut pas
reconstruire Personnel, les voyages locaux, les listes rapides locales, leurs
états/quantités ni une capacité perdue. La sauvegarde V1 est donc obligatoire.

L’import PWA existant reste compatible avec un futur export contenant
Personnel : aucun schéma ni importeur Web n’a été supprimé. Le Samsung actuel
ne contient encore aucun propriétaire Personnel ni contexte réel.

## Permissions et secrets

L’APK déclare uniquement `INTERNET` et la permission interne générée par Android
pour les receivers non exportés. Aucune permission générale de stockage n’est
demandée. L’URL publique `https://checklist-voyage-pb.fly.dev` est attendue.
Aucun token admin, secret Fly, mot de passe, keystore ou capacité n’est codé en
dur dans les sources ou la configuration versionnée.

## État Samsung avant RC

- application `0.14.0+14`, schéma 7 ;
- UUID `41459db3-42f6-48cd-83cf-a63aa54aff04` ;
- 12 propriétaires visibles, 37 catégories, 296 items ;
- 3 voyages, dont 2 locaux et 1 partagé, avec 147 items ;
- 1 liste rapide locale avec 1 item ;
- 1 capacité de document présente ;
- 4 opérations `trip_item/upsert` en attente, sans erreur ni tentative échouée,
  le téléphone étant hors réseau au relevé.

L’export réel est conservé hors Git dans
`C:\Users\psyco\Documents\Checklist Voyage - Sauvegardes RC`. Sa restauration
a été exécutée deux fois sur une base isolée avec UUID, relations, capacités et
comptages inchangés.

Après installation de la RC1 debug, la version est `1.0.0-rc.1+15`, le schéma,
l’UUID, les comptages, la capacité et les 4 opérations en attente sont restés
strictement identiques.

Le contrôle manuel du sélecteur Android depuis le menu Bibliothèque n’a pas pu
être mené jusqu’à son affichage, le téléphone s’étant déconnecté pendant le
parcours. Le canal natif est néanmoins compilé dans les APK debug et release ;
l’export, le contrôle d’intégrité et la double restauration ont été validés par
le script et les tests automatisés.
