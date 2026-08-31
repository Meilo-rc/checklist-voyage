# Protocole téléphone — Checklist Voyage 1.0.1

Ce protocole valide le correctif de voyage partagé sur les deux téléphones
réels. Il ne faut ni désinstaller l'application, ni recréer le voyage, ni
rejoindre de nouveau avec le code.

## 1. Mise à jour et conservation des données

Sur chaque téléphone :

1. installe `Checklist-Voyage-v1.0.1-release.apk` comme mise à jour ;
2. ouvre l'application et vérifie `1.0.1 · 28` ;
3. vérifie que les voyages, la bibliothèque et les listes rapides existants
   sont toujours présents ;
4. ouvre le voyage partagé déjà utilisé pour le test familial.

Résultat attendu : aucune perte de données et aucune nouvelle saisie du code.

## 2. Filtre et cycle des trois états sur B

1. sur B, sélectionne explicitement le filtre `Tout` ;
2. repère une catégorie contenant au moins un item à préparer, un prêt et un
   rangé ;
3. touche un item `À préparer` une fois : il devient `Prêt`, reste visible et se
   replace après les items à préparer ;
4. touche-le une seconde fois : il devient `Rangé` et se replace après les
   items prêts ;
5. touche-le une troisième fois : il redevient `À préparer`.

Résultat attendu : cycle `todo → checked → done → todo`, sans disparition dans
`Tout`.

Contrôle complémentaire : avec le filtre `À préparer`, le passage à `Prêt` doit
faire disparaître l'item de cette vue uniquement. Il doit réapparaître dans
`Tout` et `Prêt`.

## 3. Synchronisation A vers B

1. place le voyage sur le filtre `Tout` sur les deux appareils ;
2. sur A, passe un item identifiable de `À préparer` à `Prêt` ;
3. mets B au premier plan ou rouvre le voyage sur B ;
4. attends quelques secondes sans ressaisir le code.

Résultat attendu : le même item est `Prêt` sur B.

## 4. Synchronisation B vers A

1. sur B, passe le même item de `Prêt` à `Rangé` ;
2. mets A au premier plan ou rouvre le voyage sur A ;
3. attends quelques secondes.

Résultat attendu : le même item est `Rangé` sur A.

## 5. Hors ligne et retour réseau

1. coupe le réseau sur B ;
2. change l'état d'un autre item ;
3. navigue ailleurs puis reviens dans le voyage : l'état local doit être
   conservé ;
4. rétablis le réseau ;
5. mets l'application en arrière-plan puis au premier plan, ou rouvre le voyage ;
6. mets ensuite A au premier plan ou rouvre le voyage sur A.

Résultat attendu : la modification locale reste visible hors ligne, puis les
deux appareils convergent après le retour réseau.

## 6. Confirmation

La validation téléphone est acquise uniquement après confirmation des points
suivants :

- mise à jour sans perte sur A et B ;
- version `1.0.1 · 28` sur A et B ;
- filtre `Tout` correct sur B ;
- cycle à trois états correct sur B ;
- synchronisation A vers B ;
- synchronisation B vers A ;
- conservation hors ligne puis convergence au retour réseau.

En cas d'échec, ne désinstalle rien. Note l'appareil, le filtre affiché,
l'état avant/après, l'heure et l'étape du protocole, puis arrête le test.
