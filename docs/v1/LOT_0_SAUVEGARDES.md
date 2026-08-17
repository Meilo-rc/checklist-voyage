# Lot 0 - Sauvegardes et restauration contrôlée

Cette procédure protège la Web app 2.63 et ses données avant toute migration. Les commandes d'export sont en lecture seule. Aucune commande de restauration ne doit viser `psyco.fly.dev`.

## 1. Export PocketBase complet

Depuis la racine de `version en cours` :

```powershell
node tools/v1/pocketbase-export.mjs --out-dir "..\sauvegardes\AAAA-MM-JJ_avant_refonte_v1"
node tools/v1/backup-verify.mjs "..\sauvegardes\AAAA-MM-JJ_avant_refonte_v1\pocketbase-full.json"
```

L'export effectue uniquement des requêtes HTTP GET. Il produit :

- `pocketbase-full.json` : tous les enregistrements de `travel_checklists` ;
- `pocketbase-full.sha256` : empreinte d'intégrité ;
- `pocketbase-full.report.json` : comptages, types, tombstones et anomalies détectées.

Contrôles obligatoires :

- JSON lisible et validation `valid: true` ;
- un seul enregistrement `PARAMS` ;
- aucun identifiant PocketBase dupliqué ;
- comptage par type cohérent avec l'application ;
- empreinte SHA-256 conservée avec l'export ;
- dossier copié sur un second support avant une migration réelle.

Un code dupliqué est signalé comme anomalie de migration, mais ne doit jamais être corrigé automatiquement dans la sauvegarde.

## 2. Export local de chaque appareil Web

PocketBase ne contient pas toutes les données. La section Personnel et certains états locaux restent dans `localStorage`.

Sur chaque téléphone, tablette ou navigateur utilisé :

1. ouvrir la Web app 2.63 ;
2. ouvrir Paramètres ;
3. choisir `Exporter une sauvegarde` ;
4. renommer le fichier avec une étiquette d'appareil non sensible, par exemple `web-local-telephone-1-AAAA-MM-JJ.json` ;
5. copier le fichier dans `sauvegardes/AAAA-MM-JJ_avant_refonte_v1/web-local/` ;
6. exécuter `node tools/v1/backup-verify.mjs <fichier>` ;
7. noter les compteurs `personalMembers`, `personalCategories` et `personalItems` ;
8. confirmer manuellement dans la Web app que ces compteurs sont plausibles.

Une sauvegarde sans donnée Personnel peut être correcte, mais le vérificateur exige une confirmation humaine : il ne peut pas savoir si l'absence est volontaire.

## 3. Définition d'une sauvegarde complète

Le point de retour complet est constitué de l'ensemble suivant :

- export PocketBase complet et son empreinte ;
- rapport de validation PocketBase ;
- un export local par appareil contenant des données propres ;
- liste des appareils exportés et date de contrôle ;
- version Web `2.63` et commit Git `9ec9d53` ;
- copie des fichiers de la Web app de référence ;
- résultat d'une restauration sur environnement de test.

## 4. Restauration testable et non destructive

La restauration doit être testée uniquement contre une instance PocketBase isolée et une collection vide de test.

Dry-run :

```powershell
node tools/v1/pocketbase-restore.mjs --backup <pocketbase-full.json> --target-url http://127.0.0.1:8090
```

Exécution sur la cible locale :

```powershell
node tools/v1/pocketbase-restore.mjs --backup <pocketbase-full.json> --target-url http://127.0.0.1:8090 --execute --confirm-target 127.0.0.1
```

Garde-fous intégrés :

- refus absolu de `psyco.fly.dev` ;
- refus d'une collection cible non vide ;
- aucune suppression ;
- validation préalable de la sauvegarde ;
- contrôle du nombre d'enregistrements après restauration.

## 5. Test de restauration d'un export Web local

L'import Web 2.63 relance actuellement la synchronisation globale. Il ne doit donc jamais être testé dans un navigateur connecté à la production.

Procédure sûre :

1. utiliser un profil de navigateur temporaire ;
2. charger une copie locale de la Web app ;
3. forcer le navigateur hors ligne avant l'import ;
4. importer la sauvegarde locale ;
5. contrôler voyages, listes, bibliothèque et Personnel ;
6. fermer et supprimer ce profil sans le reconnecter ;
7. comparer les comptages avec le rapport du vérificateur.

La future application Flutter utilisera un importeur local sans déclencher de synchronisation avant validation de l'utilisateur.
