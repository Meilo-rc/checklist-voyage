# Passation — partage Android 1.1.0

## État technique

La version `1.1.0+29` ajoute la feuille de partage Android et les liens HTTPS
pour les voyages et les listes rapides. Le code, les capabilities, les
collections et la synchronisation existants sont réutilisés sans nouveau
protocole.

Le backend `checklist-voyage-pb` sert désormais :

- `GET /.well-known/assetlinks.json` ;
- `GET /join?type=<trip|quick-list>&code=<code>`.

Image Fly active : `deployment-01M57KB8Z60MHB9MTQ7AF0GCFW`.

Image de rollback : `deployment-01M0GF5MF04BBVKCMV9YWATKZJ`, digest
`sha256:ad9cad7203177edbb86eeef141a01537f965a106e9c7a9291286495f22cda237`.

Le volume `checklist_pb_data` n'a pas changé. Aucun schéma ni donnée métier
n'ont été migrés.

## Contrôles réalisés

- analyse Flutter : aucune erreur ;
- suite Flutter : 144 tests réussis, 5 tests conditionnels ignorés ;
- contrat PocketBase : 6 tests réussis ;
- tests réels PocketBase Bibliothèque et Documents partagés : 2 réussis ;
- routes publiques, santé, contenu et codes HTTP : conformes ;
- APK signé : package `fr.checklistvoyage.app`, version `1.1.0`, code `29` ;
- certificat release identique à `assetlinks.json` ;
- installation `adb install -r` réussie sur SM-S921B, données non effacées ;
- domaine App Links déclaré `verified` par Android.

La validation réelle A ↔ B reste à confirmer avec
`PROTOCOLE_TELEPHONE_1.1.0.md`.

## Problème connu du workflow Flutter

`flutter_app/scripts/build_release.ps1` appelle
`flutter_app/scripts/flutter_windows.ps1`, qui pointe actuellement vers le SDK
`Appli Recettes/.flutter-sdk`. Dans cet environnement, ce SDK contient un
framework Flutter et un moteur Dart incompatibles. Le build échoue sur les
types `ui.HitTestRequest` et `ui.HitTestResponse`.

Ce workflow n'a pas été modifié dans ce chantier. La release a été construite
dans un worktree isolé, sans les changements locaux de l'animation, avec le SDK
global validé :

`C:\Users\psyco\Documents\flutter\bin\flutter.bat`

La variable utilisateur `CHECKLIST_VOYAGE_SIGNING_PROPERTIES` a fourni la même
clé de production que les versions précédentes. Ne jamais consigner son chemin
ou son contenu dans Git.

Avant une prochaine release, réparer séparément le choix du SDK dans le
workflow officiel, puis revalider analyse, tests, signature et App Links.
