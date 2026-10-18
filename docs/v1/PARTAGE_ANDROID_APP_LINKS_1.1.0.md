# Checklist Voyage 1.1.0 — partage Android et liens d'ouverture

## Périmètre

Les deux seuls documents partageables par l'interface V1 restent :

- les voyages (`trip`) ;
- les listes rapides (`quick-list` dans l'URL, `quick_list` dans le protocole
  PocketBase existant).

Aucun nouveau type de document, aucune collection et aucun second chemin de
synchronisation ne sont ajoutés.

## Partage sortant

Le bouton **Partager** crée le partage distant seulement si nécessaire, puis
réutilise le code existant lors des partages suivants. Flutter transmet le
texte à Android par le canal
`fr.checklistvoyage.app/share_invitation`. Android ouvre ensuite un
`ACTION_SEND` de type `text/plain` avec le sélecteur système.

Le message contient uniquement le nom affiché, le code de huit caractères et
un lien de la forme :

`https://checklist-voyage-pb.fly.dev/join?type=<type>&code=<code>`

Il ne contient ni capability, ni UUID d'installation, ni identifiant interne.

## Réception

Le manifeste Android déclare :

- un App Link HTTPS vérifié pour `checklist-voyage-pb.fly.dev/join` ;
- `checklistvoyage://join` comme secours depuis la page Web.

L'activité reste en `singleTop`. Un démarrage à froid lit l'URL initiale ; une
application ouverte ou en arrière-plan reçoit l'URL par `onNewIntent`. Dans les
deux cas, Flutter valide le domaine, le chemin, le type et le format du code,
puis ouvre l'écran correspondant avec le code prérempli. La jonction n'est
effectuée qu'après un appui explicite sur **Rejoindre** et réutilise le cas
d'usage `SharedDocumentUseCases.join` existant.

La saisie manuelle **Rejoindre avec un code** reste disponible.

## Configuration serveur

Le hook `pocketbase/pb_hooks/cv1_links.pb.js` ajoute uniquement :

- `GET /.well-known/assetlinks.json`, associé au package
  `fr.checklistvoyage.app` et au certificat release existant ;
- `GET /join`, page HTML minimale affichant le code et un bouton d'ouverture de
  l'application.

Le Dockerfile inclut ce hook. Le schéma PocketBase, les données, les volumes,
les endpoints de synchronisation et la génération des codes ne changent pas.

Les deux routes sont déployées sur `checklist-voyage-pb` :

- `/.well-known/assetlinks.json` répond en JSON avec le package
  `fr.checklistvoyage.app` et l'empreinte du certificat release ;
- `/join` répond en HTML pour `trip` et `quick-list`, affiche le code et fournit
  le lien de secours vers l'application ;
- un type ou un code invalide renvoie HTTP 400.

## Déploiement et retour arrière

Service concerné : `checklist-voyage-pb` uniquement.

Image déployée : `deployment-01M57KB8Z60MHB9MTQ7AF0GCFW`.

Le déploiement a conservé le volume chiffré `checklist_pb_data` attaché à
`/pb/pb_data`. La santé PocketBase et les synchronisations réelles Bibliothèque
et Documents partagés ont été vérifiées après le déploiement.

Retour arrière : redéployer l'image
`deployment-01M0GF5MF04BBVKCMV9YWATKZJ`, digest
`sha256:ad9cad7203177edbb86eeef141a01537f965a106e9c7a9291286495f22cda237`.
Le hook ne crée aucune table et ne modifie aucune donnée ; aucun rollback de
base n'est nécessaire.

## Release Android

- version : `1.1.0+29` ;
- fichier : `Checklist-Voyage-v1.1.0+29-release.apk` ;
- taille : `64 889 671` octets ;
- SHA-256 :
  `F581E99A7DF39164204C3BC0716E9299EAEE83712C8D1829BE9D961930DE2268` ;
- certificat SHA-256 :
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48`.

L'APK a été installé avec `adb install -r` sur le Samsung SM-S921B. La date de
première installation et le dossier de données sont restés inchangés. Android
indique le domaine `checklist-voyage-pb.fly.dev` comme `verified`.

La validation fonctionnelle sur deux téléphones reste à effectuer selon
`PROTOCOLE_TELEPHONE_1.1.0.md`.
