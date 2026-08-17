# Bugs et écarts confirmés par les tests de caractérisation

Les tests marqués `todo` décrivent le comportement V1 attendu. Ils s'exécutent, confirment l'écart de la 2.63, mais ne bloquent pas la suite de tests tant que l'implémentation V1 n'a pas commencé.

## BUG-263-001 - Progression globale et tombstones

`progressForVoyage` additionne directement `category.items`, contrairement aux progressions de catégorie et de membre qui utilisent les items visibles.

Conséquence observée : un item supprimé reste dans le total global. Dans le scénario de test, la progression obtenue est `1/2 = 50 %` au lieu de `1/1 = 100 %`.

Ce comportement est un bug 2.63, pas une règle à préserver.

## BUG-V1-002 - Voyage distant dès la création

`makeVoyage` génère immédiatement un code et initialise `shared: true`. `saveVoyageSheet` appelle ensuite la synchronisation distante.

Règle V1 : `shareState = local`, sans code ni identifiant distant, jusqu'à l'action explicite Partager.

## BUG-V1-003 - Liste rapide distante dès la création

`createQuickList` crée bien un objet initialement non partagé, mais appelle immédiatement `saveQuickListRemote`. Le code est également généré pendant la normalisation.

Règle V1 : aucune écriture distante et aucun code avant l'action explicite Partager.

## Dette confirmée, couverte par un test passant

La fusion legacy peut encore fusionner deux objets ayant des identifiants distincts lorsque leurs noms sont identiques. Ce comportement est caractérisé pour garantir la compatibilité de lecture, mais il est interdit comme règle d'identité dans le modèle V1.
