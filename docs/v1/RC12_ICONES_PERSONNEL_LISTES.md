# Checklist Voyage — RC12 icônes Personnel et Listes rapides

Version Android : `1.0.0-rc.12+26`.

## Corrections

- les catégories sans icône explicite affichent désormais un dossier neutre et
  cliquable dans les groupes de Bibliothèque, notamment sous `Personnel` ;
- le même comportement est appliqué aux catégories d’un groupe Personnel dans
  un voyage ;
- l’icône réellement enregistrée pour une liste rapide est reprise dans le
  titre de sa page détail, comme pour les pages Voyage et Bibliothèque.

Aucune valeur d’icône n’est écrite artificiellement dans les données : le
dossier est uniquement un visuel de repli. Il reste possible de choisir une
icône depuis l’administration existante. Aucun schéma, document partagé,
protocole de synchronisation ou comportement métier n’a été modifié.

## Validation

- tests ciblés Bibliothèque Personnel, Voyage Personnel et Listes rapides :
  11 réussis ;
- suite Flutter complète : 132 réussis, 5 contrôles réels conditionnels
  ignorés faute de variables externes ;
- `flutter analyze --no-pub` : aucune anomalie en 11,4 s ;
- tests ciblés à 360 px et en thème sombre ;
- APK release : 64 872 837 octets ;
- SHA-256 APK :
  `DD0C9B5D2338272A05F785E8FEFE32EB58BB196C05FF6E1960AF58739CC7028C` ;
- signature APK v2 valide ;
- certificat SHA-256 inchangé :
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48`.

RC12 a été installée sur le Samsung SM-S921B comme mise à jour, sans
désinstallation. La date d’installation initiale est conservée. Le contrôle
réel a confirmé les icônes des catégories `Crampons` et `Sac` dans
`Bibliothèque → Personnel → Football`, puis l’icône de football dans le titre
de la liste rapide `Football`. Aucun plantage Flutter, Android, Drift ou SQLite
n’apparaît dans les journaux immédiats.

## Protocole de validation sur téléphone

1. Vérifier la version `1.0.0-rc.12 · 26` et la présence des données existantes.
2. Ouvrir `Bibliothèque → Personnel`, puis chaque groupe Personnel. Chaque
   catégorie doit avoir soit son icône choisie, soit un dossier neutre.
3. Toucher une icône de catégorie : l’administration doit s’ouvrir sans
   développer ou supprimer la catégorie.
4. Si un voyage contient un groupe Personnel, l’ouvrir et vérifier le même
   comportement sur ses catégories.
5. Ouvrir `Listes rapides`. Noter l’icône d’une liste puis ouvrir son détail :
   la même icône doit apparaître à gauche du titre.
6. Changer l’icône de cette liste depuis son menu, revenir au détail et vérifier
   que le titre utilise la nouvelle icône.
7. Refaire les vérifications en thème clair et sombre. Les titres longs ne
   doivent pas déborder.
8. Fermer complètement puis relancer l’application. Vérifier les icônes, les
   voyages, les items et les quantités.
9. Vérifier que la synchronisation habituelle se termine sans nouvelle erreur
   et que l’outbox reste saine.

Validation téléphone confirmée le 26 août 2026 : l’ensemble du protocole RC12
est validé. RC12 devient la référence fonctionnelle et le dernier backup
validé ; RC11 n’est plus le backup courant.
