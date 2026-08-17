# Checklist Voyage V1 — application Android locale

Ce dossier contient l'application Flutter Android locale-first construite aux
lots 3 à 5. La PWA 2.63 située à la racine du dépôt reste indépendante et
inchangée.

Le moteur local permet de construire la bibliothèque, générer un voyage avec
Essentiels, participants, transports et logements, gérer les trois états et les
quantités, retirer des items par tombstone et utiliser des listes rapides. Toutes
ces opérations s'exécutent dans Drift/SQLite sans réseau.

Le lot 5 ajoute les contextes/activités, leur association secondaire aux items
et la compaction des items de voyage par identité source explicite.

## Commandes Windows

Le chemin du SDK Flutter partagé contient un espace. Le script ci-dessous crée
deux jonctions temporaires sans espaces puis les supprime après exécution :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "analyze --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "test --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "build apk --debug --no-pub"
```

## Limites volontaires du lot 5

- aucune synchronisation PocketBase active ;
- aucun partage V1 ;
- aucune modification/régénération automatique des choix d'un voyage existant ;
- interface de validation fonctionnelle, sans refonte UX finale.

L'import se lance depuis l'action en haut de l'écran Bibliothèque. Il accepte un
export Web local `checklist-voyage-backup-v1` ou l'export PocketBase complet
`checklist-voyage-pocketbase-full-v1`.

Le rapport technique du lot courant est dans
`docs/v1/LOT_5_CONTEXTES_COMPACTION.md`.
