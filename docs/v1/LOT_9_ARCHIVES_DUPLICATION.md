# Lot 9 — archives et duplication

Date de validation technique : 20 août 2026.

## Classement des voyages

Le classement est dérivé à l'affichage :

- date de début après aujourd'hui : À venir ;
- voyage non terminé : En cours ;
- date de fin antérieure à aujourd'hui : Archives ;
- `archived_at` non nul : Archives, quelle que soit la date.

La date de fin du jour reste active jusqu'au lendemain. Ce calcul ne modifie
aucune ligne, ne déplace pas le voyage et ne produit aucune opération distante.
Les archives sont triées par `archived_at`, puis date de fin, puis dernière
modification, de la plus récente à la plus ancienne.

## Archivage manuel

La migration Drift v7 ajoute `archived_at` à `trips` et `quick_lists`. Archiver
ou restaurer ne touche ni les enfants, ni les états, ni les quantités, ni les
capacités. Ce n'est pas un tombstone.

Pour un document local, l'opération reste locale. Pour un voyage ou une liste
déjà partagé, le repository ajoute une mise à jour de l'entité racine à
l'outbox existante. Le payload `archived_at` utilise le protocole documentaire
générique du lot 7 ; aucune migration ou route PocketBase supplémentaire n'est
nécessaire. Deux installations convergent sur l'archive et la restauration.

## Duplication d'un voyage

La duplication est une transaction locale qui lit uniquement la structure
active du voyage source. Elle copie : membres, catégories, items conservés,
quantités, ajouts spécifiques, sources légitimes et choix de génération. Elle
ne relance jamais la génération depuis la bibliothèque.

Les tombstones ne sont pas copiés. Le nouveau voyage et toutes ses entités
d'instance reçoivent de nouveaux UUID ; tous les items repartent à `todo`. Le
formulaire préremplit le nom et la destination, conserve la structure et exige
de nouvelles dates avant création.

La copie est toujours `local`, avec `archived_at`, code, capacité, identifiant
distant et document de synchronisation absents. Un item autonome issu de
Personnel reste une copie du voyage ; aucune ligne de bibliothèque ou
association personnelle n'est reconstruite et aucune écriture distante n'est
produite.

## Duplication d'une liste rapide

La copie reçoit le suffixe `— copie`, de nouveaux UUID et conserve les items et
quantités. Tous les items repartent décochés. Comme pour les voyages, la copie
reste locale et n'hérite d'aucun accès distant.

## Interface et validation

- Voyages : onglets Voyages/Archives et sections À venir/En cours ;
- Listes rapides : onglets Mes listes/Archives ;
- actions Dupliquer, Archiver et Restaurer dans les menus existants ;
- archives consultables sans suppression ni reconstruction ;
- persistance validée après fermeture et réouverture hors ligne ;
- duplication de sources partagées validée sans outbox ni opération distante ;
- conservation de la checklist affinée, des choix et des quantités ;
- migrations v6 vers v7 testées sans perte.
