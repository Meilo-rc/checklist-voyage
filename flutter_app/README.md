# Checklist Voyage V1 — application Android locale

Ce dossier contient l'application Flutter Android locale-first construite aux
lots 3 et 4. La PWA 2.63 située à la racine du dépôt reste indépendante et
inchangée.

Le moteur local permet de construire la bibliothèque, générer un voyage avec
Essentiels, participants, transports et logements, gérer les trois états et les
quantités, retirer des items par tombstone et utiliser des listes rapides. Toutes
ces opérations s'exécutent dans Drift/SQLite sans réseau.

## Commandes Windows

Le chemin du SDK Flutter partagé contient un espace. Le script ci-dessous crée
deux jonctions temporaires sans espaces puis les supprime après exécution :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "analyze --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "test --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "build apk --debug --no-pub"
```

## Limites volontaires du lot 4

- aucune synchronisation PocketBase active ;
- aucun partage V1 ;
- aucun comportement de contexte/activité ;
- aucune compaction V1 ;
- interface de validation fonctionnelle, sans refonte UX finale.

L'import se lance depuis l'action en haut de l'écran Bibliothèque. Il accepte un
export Web local `checklist-voyage-backup-v1` ou l'export PocketBase complet
`checklist-voyage-pocketbase-full-v1`.

Le rapport technique complet est dans `docs/v1/LOT_4_MOTEUR_LOCAL.md`.
