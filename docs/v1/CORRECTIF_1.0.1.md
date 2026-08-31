# Checklist Voyage 1.0.1

Version Android : `1.0.1+28`.

## Périmètre

Ce correctif rétablit la propagation des états d'items d'un voyage partagé,
sans modifier le backend, le schéma Drift, les listes rapides ni les règles
métier.

## Avant

- une modification `todo / checked / done` était bien écrite dans Drift ;
- l'opération correspondante était bien créée dans l'outbox ;
- aucun envoi n'était déclenché après cette mutation ;
- la synchronisation des documents partagés n'était lancée qu'au démarrage,
  au partage, à la jointure ou par un appel global explicite ;
- le filtre par défaut d'un voyage, y compris rejoint, était déjà `Tout` et
  les trois états utilisaient déjà le même composant et le même cas d'usage.

## Après

- une opération de voyage partagée mise en attente déclenche une tentative de
  synchronisation non bloquante après la transaction locale ;
- les synchronisations concurrentes d'un même document sont sérialisées ;
- l'ouverture du voyage et la reprise de l'application déclenchent un push/pull
  ciblé sur ce document ;
- une erreur réseau reste enregistrée par le store sans bloquer l'interface ni
  supprimer l'outbox ;
- l'ouverture d'un voyage local ne déclenche aucune opération distante ;
- aucun polling permanent n'a été ajouté.

## Disparition observée sur le second appareil

Le moteur et l'interface ne contiennent pas de variante binaire pour un voyage
rejoint. Le filtre `Tout` est la valeur initiale et conserve les items
`todo`, `checked` et `done`, triés dans cet ordre. Un item peut disparaître
normalement après un tap uniquement si le filtre actif est `À préparer`.

Le filtre étant un état d'interface non persistant et non synchronisé, sa valeur
exacte au moment de l'observation ne peut pas être reconstruite depuis la base.
Le protocole téléphone vérifie donc explicitement ce point sur l'appareil réel.

## Validation technique

- `flutter analyze --no-pub` : aucune anomalie ;
- tests ciblés A/B et interface : réussis ;
- suite Flutter : 135 tests réussis, 5 tests d'intégration conditionnels ignorés ;
- package : `fr.checklistvoyage.app` ;
- signature : certificat identique à la version `1.0.0+27` ;
- schéma Drift : inchangé ;
- backend PocketBase : inchangé.

## APK

- fichier : `Checklist-Voyage-v1.0.1-release.apk` ;
- taille : `64 872 828` octets ;
- SHA-256 :
  `6A26077BB6CBDF21BF0C57D546786D4D2D2F1E7247774ACD91657399087F3343`.

La validation technique ne remplace pas la validation sur les deux téléphones.
Le protocole associé doit être confirmé par l'utilisateur avant de considérer
la version comme validée sur appareils réels.
