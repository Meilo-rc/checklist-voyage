# Backend PocketBase dédié — phase 1

Le backend Checklist V1 est déployé séparément de `psyco` depuis ce dépôt.
La phase 1 ne change pas l’URL utilisée par Flutter en production.

## Déploiement

- application Fly : `checklist-voyage-pb` ;
- région : `cdg` ;
- PocketBase : `0.22.25` ;
- volume chiffré : `checklist_pb_data`, monté sur `/pb/pb_data` ;
- configuration : `fly.checklist.toml` et `pocketbase/Dockerfile`.

L’image contient uniquement les deux hooks et les deux migrations `cv1_*` du
dépôt Checklist. Le client `sqlite3` est présent pour les sauvegardes ciblées et
les restaurations contrôlées ; il n’expose aucune route supplémentaire.

## Superutilisateur

Les identifiants ne résident ni dans Git, ni dans Flutter, ni dans la
configuration Fly. Le compte initial est créé depuis une console Fly, avec un
mot de passe aléatoire généré dans cette console et jamais affiché. Pour rendre
un accès administratif à un opérateur, ouvrir une console interactive Fly et
utiliser `pocketbase admin update` avec un nouveau mot de passe saisi à la
demande. Ne jamais placer ce mot de passe dans une ligne de commande enregistrée,
un fichier du dépôt ou un ticket.

## Copie ciblée

`tools/v1/cv1-db-export.sh` exporte uniquement les huit tables `cv1_*`. Il crée
un SQL exact, un JSON par table et un manifeste de comptages/empreinte avec des
permissions restrictives. L’archive de migration reste temporaire et est
ignorée par Git.

`tools/v1/cv1-db-import.sh` refuse une cible non vide et importe dans une seule
transaction. L’égalité des exports SQL source/cible permet de vérifier tous les
champs, y compris identifiants, révisions, tombstones, codes et capacités, sans
les afficher.

`tools/v1/cv1-migrated-backend-check.mjs` vérifie ensuite les pulls, les journaux,
les codes et les capacités migrés. Ce contrôle actualise les dates d’accès des
documents ; la copie exacte doit donc être réappliquée après son exécution avant
la validation finale.

## Restauration

La restauration de phase 1 consiste à repartir d’un volume Checklist neuf,
laisser les deux migrations recréer le schéma, puis réimporter l’export ciblé.
Elle ne restaure jamais `pb_data` de `psyco`. Avant toute restauration, vérifier
l’empreinte SHA-256 et les comptages du manifeste, puis conserver un snapshot du
volume Checklist en place.

## Garde-fous

- `https://psyco.fly.dev` reste la cible par défaut de Flutter ;
- aucun export, secret, APK ou fichier d’environnement local n’est suivi ;
- le dépôt Recettes n’intervient pas dans le déploiement ;
- aucune collection `travel_checklists`, Recettes ou historique d’une autre
  application n’est créée sur le backend dédié.
