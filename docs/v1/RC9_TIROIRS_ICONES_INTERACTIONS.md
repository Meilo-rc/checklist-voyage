# Checklist Voyage — RC9 tiroirs, icônes et interactions

Version Android : `1.0.0-rc.9+23`.

## Changements livrés

- administration des Groupes, Membres et Catégories par appui long dans un
  tiroir commun ;
- retrait du swipe Modifier/Supprimer sur les Groupes et les Catégories ;
- maintien du swipe Modifier/Supprimer sur les Items ;
- maintien de l’appui long Contextes sur les Items ;
- tiroir protégé de la barre système Android et du clavier, avec contenu
  défilable ;
- fermeture immédiate du tiroir après un renommage ou un changement d’icône
  réussi ; en cas d’échec, il reste ouvert et affiche l’erreur ;
- icône `categorie` attribuée par défaut aux nouvelles Catégories de la
  Bibliothèque ;
- état `Prêt` des items de Voyage affiché en gris et italique, sans texte barré ;
  l’état `Rangé` reste plus discret et barré ;
- icône configurable pour les Listes rapides, affichée dans leur liste et
  administrable par appui long ;
- actions Renommer, Icône, Archiver/Restaurer, Dupliquer, Supprimer et Partager
  regroupées dans le même tiroir de Liste rapide ;
- migration Drift additive v7 vers v8 : ajout de `quick_lists.icon`, valeur par
  défaut `liste` ;
- une duplication conserve l’icône et reste locale par défaut ;
- l’icône d’une Liste rapide partagée est transportée par le document de
  synchronisation existant et converge entre les appareils ;
- les sauvegardes de schéma v7 restent restaurables dans la base v8.

Aucun nouveau mécanisme de synchronisation, aucune collection PocketBase et
aucun changement de backend ou de PWA ne sont introduits.

## Validation technique

- `flutter analyze --no-pub` : aucune anomalie ;
- suite Flutter complète : 115 tests réussis ;
- 5 contrôles réels conditionnels ignorés faute de variables externes ;
- migration v7 vers v8 sans perte et valeur par défaut testées ;
- sauvegarde v7 vers base v8 testée ;
- persistance et duplication de l’icône testées ;
- synchronisation A/B de l’icône testée hors ligne puis en convergence ;
- interactions, tiroir, erreurs, largeur 360 px, clair et sombre couverts ;
- APK release : 63 943 489 octets ;
- SHA-256 :
  `1CD62C0E0F779065B0568A3969159DC49F54A722C55B5C4673516E92CBAAE456` ;
- signature APK v2 valide ;
- certificat SHA-256 :
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48` ;
- package : `fr.checklistvoyage.app` ;
- installation en mise à jour réussie sur le Samsung `SM-S921B` ;
- `firstInstallTime` inchangé (`2026-08-24 15:49:40`), donc aucune
  désinstallation et conservation de la base locale ;
- démarrage réussi, sans erreur fatale détectée dans les journaux du processus.

## Protocole de validation sur téléphone

La RC9 ne devient pas la version validée sur téléphone avant confirmation de
l’utilisateur. La RC7 reste la sauvegarde validée.

1. Installer `1.0.0-rc.9+23` comme mise à jour, sans désinstaller
   `fr.checklistvoyage.app`.
2. Vérifier que les voyages, la Bibliothèque et les Listes rapides existants
   sont toujours présents.
3. Vérifier la version affichée : `1.0.0-rc.9 · 23`.
4. Dans Bibliothèque, faire un appui long sur un Groupe ou un Membre : le tiroir
   d’administration doit s’ouvrir ; un swipe ne doit plus déclencher d’action.
5. Renommer ce Groupe ou Membre : après validation, le tiroir doit se fermer et
   le nouveau nom doit apparaître.
6. Faire un appui long sur une Catégorie, changer son icône et vérifier la
   fermeture immédiate du tiroir ; un swipe sur la Catégorie ne doit rien
   modifier ni supprimer.
7. Créer une Catégorie : elle doit recevoir une icône générique par défaut.
8. Vérifier qu’un Item conserve le swipe vers Modifier/Supprimer et l’appui long
   vers Contextes.
9. Dans un Voyage, passer un Item à `Prêt` : son texte doit être gris et
   italique, sans être barré. Le passer à `Rangé` : il doit devenir plus discret
   et barré.
10. Dans Listes rapides, faire un appui long sur une liste : le tiroir doit
    proposer le nom, l’icône et les actions existantes.
11. Choisir une icône, fermer puis rouvrir l’application : l’icône doit être
    conservée et visible dans la liste.
12. Dupliquer cette liste : la copie doit conserver l’icône, être décochée et
    rester locale, sans code de partage.
13. Pour une liste partagée, changer l’icône sur un appareil puis synchroniser
    un second appareil : les deux doivent afficher la même icône.
14. Couper le réseau et vérifier qu’une liste locale peut encore changer
    d’icône, être dupliquée et être rouverte sans perte.
15. Refaire les contrôles de tiroir en mode clair puis sombre, clavier ouvert,
    sur une largeur de 360 px : la dernière action doit rester accessible
    au-dessus de la barre Android.
16. Fermer complètement puis relancer l’application et vérifier une dernière
    fois toutes les données et icônes.

En cas d’échec, noter le numéro de l’étape, le résultat observé et joindre une
capture si possible.
