# Lot 11C — Import réel contrôlé sur Android

## Source retenue

Le backend V1 dédié ne contenait pas la bibliothèque historique complète. La source canonique disponible était le document de paramètres `PARAMS` de la PWA 2.63 sur l'ancien backend. Il a été enveloppé dans le format de sauvegarde Web déjà accepté par `WebV263Importer`, sans voyages ni listes rapides.

L'export réel, les bases copiées depuis le téléphone et les captures de contrôle restent dans un dossier de build ignoré par Git. Aucune donnée réelle n'est versionnée.

## Garde-fous appliqués

- arrêt forcé de l'application avant chaque copie SQLite ;
- copie et empreinte SHA-256 de la base avant import ;
- aucune désinstallation, aucun effacement des données et aucun changement d'identité d'installation ;
- import additif dans une base Drift déjà non vide ;
- deuxième import du même fichier pour vérifier l'idempotence ;
- installation de l'APK par mise à jour (`adb install -r`) ;
- comparaison après import, synchronisation, mise à jour APK et redémarrage complet.

## Résultat mesuré

| Mesure | Avant | Après |
|---|---:|---:|
| Version du schéma Drift | 7 | 7 |
| Propriétaires, total / actifs | 2 / 2 | 18 / 14 |
| Catégories, total / actives | 3 / 3 | 47 / 40 |
| Items, total / actifs | 4 / 3 | 309 / 299 |
| Contextes | 0 | 0 |
| Voyages | 2 | 2 |
| Listes rapides | 1 | 1 |
| Imports enregistrés | 0 | 1 |
| Opérations en attente après synchronisation | 0 | 0 |

Les compteurs « actifs » ci-dessus regardent le tombstone de la ligne elle-même. Après exclusion supplémentaire des descendants d'un parent tombstoné, la bibliothèque réellement visible et synchronisable contient 14 propriétaires, 37 catégories et 240 items. Ces mêmes volumes sont présents sur le backend V1 dédié au curseur 291.

L'UUID d'installation est resté strictement identique. Les entités créées manuellement avant l'import, les deux voyages et la liste rapide sont toujours présentes après la mise à jour et le redémarrage.

Le fichier historique contient plusieurs occurrences d'une même identité legacy. L'importeur conserve la représentation canonique déterministe ; il ne fusionne jamais deux identités uniquement parce que leurs noms sont identiques. Un homonyme préexistant et un homonyme importé restent donc deux entités distinctes.

## Idempotence et synchronisation

Le premier import a créé une seule entrée dans `migration_history`. Le second import du même fichier a affiché « Cette sauvegarde avait déjà été importée » et n'a ajouté ni propriétaire, ni catégorie, ni item, ni seconde entrée d'historique.

La synchronisation normale a ensuite publié uniquement Général/Famille sur `https://checklist-voyage-pb.fly.dev`. Le backend historique et `travel_checklists` n'ont pas été modifiés.

Le test réel a révélé un blocage de reprise : des enfants encore présents historiquement sous un parent tombstoné étaient placés dans l'outbox, puis refusés par le backend avec « Parent V1 absent ». Le bootstrap filtre désormais ces descendants et purge uniquement leurs upserts locaux impossibles avant envoi. Les lignes historiques restent dans SQLite ; elles ne sont ni supprimées ni rendues visibles.

## Personnel

La source `PARAMS` disponible ne contient aucun groupe Personnel. Aucun Personnel n'a donc été importé et aucune donnée fictive n'a été créée.

Lorsqu'un export local PWA contenant Personnel sera disponible sur un appareil, la procédure sera :

1. exporter le stockage local de cet appareil avec la procédure du lot 0 ;
2. conserver le fichier hors Git ;
3. l'importer depuis Bibliothèque sur l'installation V1 cible ;
4. vérifier que les propriétaires concernés ont `sync_scope = personal_local` ;
5. vérifier qu'aucun de leurs identifiants n'apparaît dans `sync_outbox` ni sur le backend.

## Retour arrière

La copie SQLite prise avant l'import est conservée hors Git avec son empreinte SHA-256. Une restauration éventuelle doit se faire application arrêtée, après une nouvelle copie de l'état courant, puis être contrôlée par l'UUID d'installation, la version de schéma et les compteurs de toutes les tables métier. Cette restauration n'a pas été nécessaire pendant le lot 11C.
