# Checklist Voyage V1 — socle Android

Ce dossier contient l'application Flutter Android locale créée au lot 3. La PWA
2.63 située à la racine du dépôt reste indépendante et inchangée.

## Commandes Windows

Le chemin du SDK Flutter partagé contient un espace. Le script ci-dessous crée
deux jonctions temporaires sans espaces puis les supprime après exécution :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "analyze --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "test --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "build apk --debug --no-pub"
```

## Limites volontaires du lot 3

- aucune synchronisation PocketBase active ;
- aucun partage V1 ;
- aucun comportement de contexte/activité ;
- pas encore de CRUD métier complet ;
- interface limitée aux trois destinations et à l'import JSON.

L'import se lance depuis l'action en haut de l'écran Bibliothèque. Il accepte un
export Web local `checklist-voyage-backup-v1` ou l'export PocketBase complet
`checklist-voyage-pocketbase-full-v1`.
