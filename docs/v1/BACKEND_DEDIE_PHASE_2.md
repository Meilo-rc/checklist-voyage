# Bascule Flutter vers le backend dédié — phase 2

Date : 20 août 2026.

## État de référence

- commit Flutter avant bascule : `b81528bec2557d2739ad4b528366d287dd2eb0c6` ;
- `psyco` avant gel : release Fly `24`, image
  `deployment-01M0G82BS5SWC9F759KJF2D96C` ;
- `psyco` gelé : release Fly `25` ;
- backend Checklist : release Fly `2`, service
  `https://checklist-voyage-pb.fly.dev` ;
- empreinte ciblée commune au moment de la bascule :
  `90c06859044e26caff7647b3132f59fe329ff3a02b933605fae1e2fa6e8d3dc7`.

## Gel de l’ancien backend

Sur `psyco`, les routes `sync/push`, `documents/share`, `documents/join` et
`documents/push` répondent `503` avec un message de migration. Les pulls restent
disponibles. Le pull documentaire ne modifie plus les dates d’accès, afin que
l’ancienne copie reste stable pendant la période de retour arrière.

Les clients anciens conservent leurs opérations dans l’outbox Drift. Après mise
à jour de l’APK, la même base locale et les mêmes UUID/capacités sont utilisés et
l’outbox est envoyée au backend dédié.

## Rollback

Le rollback ne doit être utilisé qu’en cas de défaut critique avant diffusion
large :

1. interrompre la diffusion de l’APK basculé ;
2. vérifier que les deux backends n’ont pas divergé depuis la bascule ;
3. reconstruire temporairement Flutter depuis le commit `b81528b` ;
4. pour réautoriser les anciens clients, redéployer sur `psyco` la release `24`
   ou rétablir les hooks CV1 du commit précédent du dépôt Recettes ;
5. tester Recettes, la PWA 2.63 et les huit collections CV1 avant toute reprise ;
6. ne supprimer aucune donnée ou collection sur l’un des deux backends.

Une fois que de nouvelles opérations ont été acceptées uniquement par le backend
dédié, un retour vers `psyco` exige une nouvelle fenêtre de gel et une copie
ciblée inverse contrôlée. Il ne faut jamais simplement changer l’URL Flutter.

## Situation après phase 2

Flutter utilise le backend dédié par défaut. Les tests peuvent toujours injecter
une autre URL. `psyco` conserve les données CV1 gelées comme rollback temporaire,
ainsi que `travel_checklists` pour la PWA 2.63. Aucun nettoyage Recettes ou CV1
n’est effectué pendant cette phase.
