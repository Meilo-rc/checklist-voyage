# Checklist Voyage V1 — application Android locale

Ce dossier contient l'application Flutter Android locale-first construite aux
lots 3 à 10. La PWA 2.63 située à la racine du dépôt reste indépendante et
inchangée.

Le moteur local permet de construire la bibliothèque, générer un voyage avec
Essentiels, participants, transports et logements, gérer les trois états et les
quantités, retirer des items par tombstone et utiliser des listes rapides. Toutes
ces opérations s'exécutent dans Drift/SQLite sans réseau.

Les lots 5 à 7 ajoutent les contextes, la compaction, la synchronisation de la
bibliothèque et le partage explicite des voyages/listes rapides. Le lot 8 ajoute
les filtres locaux de voyage par état et participant, sans écriture distante.
Le lot 9 ajoute les archives réversibles et la duplication locale des voyages
et listes rapides.

Le lot 10 introduit le socle Material 3 V1 (palette, typographie, espacements,
champs, boutons, chips, progression et navigation) et refond la destination
Voyages ainsi que son formulaire. La liste distingue clairement les voyages en
cours, à venir et archivés, avec des cartes compactes testées à 360 px. La
création utilise une seule sélection de période et des chips multisélection sans
coche décorative ni action de création de bibliothèque.

## Commandes Windows

Le chemin du SDK Flutter partagé contient un espace. Le script ci-dessous crée
deux jonctions temporaires sans espaces puis les supprime après exécution :

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "analyze --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "test --no-pub"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\flutter_windows.ps1 -FlutterArgs "build apk --debug --no-pub"
```

## Limites volontaires après le lot 10

- aucun passage `shared → local` ;
- aucune révocation ou rotation de capacité ;
- aucune modification/régénération automatique des choix d'un voyage existant ;
- l'édition permet de modifier la destination et les dates ; les participants,
  transports, logements et activités actuels restent visibles mais non
  modifiables tant que la règle métier de régénération n'est pas arbitrée ;
- l'intérieur d'un voyage, Bibliothèque et Listes rapides conservent encore leur
  interface fonctionnelle antérieure.

L'import se lance depuis l'action en haut de l'écran Bibliothèque. Il accepte un
export Web local `checklist-voyage-backup-v1` ou l'export PocketBase complet
`checklist-voyage-pocketbase-full-v1`.

La couverture UX du lot 10 est dans `test/lot10_ux_test.dart`.
