# Lot 3 — Socle Android Flutter hors ligne

Statut : réalisé le 17 août 2026. Le lot 4 n'est pas commencé.

## Architecture créée

Le module `flutter_app` est séparé des fichiers d'exécution de la PWA 2.63.

- `lib/app` : composition des dépendances et racine Material ;
- `lib/features` : écrans, ViewModels et navigation ;
- `lib/domain` : modèles de lecture, contrats de repositories et cas d'usage ;
- `lib/data/local` : schéma Drift et migrations ;
- `lib/data/repositories` : implémentations SQLite ;
- `lib/data/import` : importeur Web/PocketBase transactionnel ;
- `lib/sync` : contrat des collections `cv1_*`, sans client réseau actif.

Les widgets ne lisent ni n'écrivent directement SQLite. Ils utilisent les cas
d'usage et repositories injectés par `AppDependencies`.

## Schéma Drift effectivement utilisé

Version actuelle : 2.

Tables métier :

- `library_owners`, `library_categories`, `library_items` ;
- `contexts`, `library_item_contexts` réservées, sans fonction métier ;
- `trips`, `trip_members`, `trip_categories`, `trip_items`,
  `trip_item_sources` ;
- `quick_lists`, `quick_list_items`.

Tables techniques :

- `installation_settings`, avec UUID d'installation et emplacement nullable
  pour une future identité utilisateur ;
- `sync_documents`, `sync_outbox`, `sync_conflicts` ;
- `sync_tombstones`, avec date de propagation et éligibilité après 90 jours ;
- `legacy_id_maps`, `migration_history`.

La migration 1 → 2 ajoute `installation_settings` et `sync_tombstones`. Une base
vierge reçoit directement le schéma complet. Les clés étrangères SQLite sont
activées à chaque ouverture.

## Importeur Web 2.63

L'import est atomique et identifié par le SHA-256 exact de la source. Une
empreinte déjà présente dans `migration_history` retourne le rapport précédent
sans réinsérer de données.

Règles appliquées :

1. UUID V1 déterministes à partir des identifiants historiques et chemins JSON ;
2. correspondances conservées dans `legacy_id_maps` ;
3. aucune fusion fondée sur le seul nom d'un item ;
4. documents PocketBase et documents locaux munis d'un `remoteRecordId` marqués
   `shared` ;
5. documents uniquement locaux marqués `local`, sans code actif ;
6. Personnel importé avec `personal_local` et aucune opération d'outbox ;
7. quantités bornées entre 1 et 99 et états convertis vers
   `todo/checked/done` ;
8. références `sourceTemplateItemId` conservées via `trip_item_sources` ;
9. tombstones distants conservés et non purgés ;
10. pour PocketBase, records documentaires directs prioritaires puis ajout des
    seuls documents absents du plus récent instantané agrégé. Les instantanés
    agrégés plus anciens ne deviennent pas des entités métier.

L'import de la sauvegarde PocketBase réelle a été exécuté uniquement dans une
base en mémoire et a réussi. Aucun appel réseau ni aucune écriture PocketBase
n'existe dans le module Flutter du lot 3.

## Écarts assumés avec le schéma de référence des lots 0–2

- ajout de `installation_settings`, nécessaire à l'UUID stable validé ;
- ajout de `sync_tombstones`, nécessaire à la rétention de 90 jours et au futur
  contrôle de propagation ;
- version Drift initiale fixée à 2 afin de tester réellement une migration
  depuis le contrat SQL initial ;
- dates stockées par Drift sous forme d'entiers SQLite plutôt qu'en texte ISO ;
- identifiant Android provisoire `fr.checklistvoyage.app` à confirmer avant une
  publication signée définitive.

## Dette technique laissée volontairement

- l'importeur conserve les champs utiles au modèle V1, mais ne fournit pas
  encore un écran de rapport détaillé ni un export V1 ;
- les règles SQL de domaine sont principalement garanties par les types,
  repositories et tests ; des contraintes `CHECK` additionnelles pourront être
  ajoutées lors d'une migration suivante ;
- `trip_item_sources.source_kind` distingue pour l'instant `essential` et
  `participant` ; la qualification transport/logement sera complétée avec le
  moteur de génération ;
- l'APK debug utilise la clé de développement et ne constitue pas une livraison
  Play Store ;
- le script Windows dépend du SDK Flutter partagé du projet voisin ; un SDK ou
  une CI autonome sera nécessaire avant publication.

## Proposition détaillée du lot 4

Objectif recommandé : porter le moteur métier local hors ligne, sans réseau et
sans les fonctions explicitement différées.

1. Introduire les modèles/commandes de domaine pour bibliothèque, voyage et
   liste rapide.
2. Implémenter les transactions locales de création, modification et tombstone.
3. Porter la génération d'un voyage : Essentiels, participants,
   multi-transport et multi-logement, en conservant les références sources.
4. Porter les quantités et le cycle `todo → checked → done`.
5. Recalculer progressions globale et par catégorie en excluant les tombstones.
6. Garantir que la suppression d'un item de voyage ne touche jamais la
   bibliothèque.
7. Rendre les trois écrans minimaux utilisables pour exercer ces fonctions,
   sans commencer la refonte UX détaillée.
8. Transposer les tests de caractérisation 2.63 vers les cas d'usage Dart et
   ajouter les tests transactionnels/redémarrage correspondants.

Critère de sortie proposé : parcours bibliothèque → génération → préparation
d'un voyage et utilisation d'une liste rapide entièrement fonctionnels hors
ligne, avec analyse et tests verts. PocketBase, partage V1, contextes, filtres,
archives, duplication et finition graphique resteraient hors périmètre.
