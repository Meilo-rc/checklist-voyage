# Protocole téléphone — Checklist Voyage 1.0.0

Ce protocole distingue le contrôle technique déjà réussi de la validation sur
le téléphone réel. Ne désinstalle pas l'application : la release doit mettre à
jour la RC12 et conserver sa base.

## Samsung principal

1. Ouvre Checklist Voyage et vérifie `1.0.0 · 27` dans l'en-tête.
2. Vérifie que les voyages Paris et Djerba, la bibliothèque et la liste rapide
   Football sont toujours présents.
3. Ouvre un voyage, puis un membre et une catégorie. Vérifie les filtres, les
   trois états et la quantité. Si tu modifies un item, remets-le ensuite dans
   son état initial.
4. Ouvre la météo d'un voyage. Vérifie l'affichage des prévisions et l'absence
   de carte météo.
5. Dans Bibliothèque, ouvre Général, Membres et Personnel. Vérifie les
   accordéons, les icônes de catégories et notamment les icônes de secours de
   Personnel.
6. Ouvre la liste rapide Football. Vérifie que son icône Football est conservée
   dans le titre de la page détail. Coche puis décoche un item.
7. Vérifie que la synchronisation n'affiche pas d'erreur et qu'aucune donnée
   Personnel n'apparaît sur un autre appareil.
8. Ferme complètement l'application, rouvre-la et vérifie que les données et
   les états sont toujours présents.
9. Contrôle rapidement le thème clair puis le thème sombre, sans débordement à
   la largeur du téléphone.

Réponds avec les points éventuellement en échec ou simplement `tout est validé`.
Le tag Git `v1.0.0` ne sera créé qu'après cette confirmation.

## Second téléphone

1. Effectue d'abord un export de sécurité depuis Bibliothèque > menu >
   `Exporter sécurité V1`.
2. Installe `Checklist-Voyage-v1.0.0-release.apk` sans désinstaller la version
   existante.
3. Vérifie la version `1.0.0 · 27` et la conservation de l'UUID d'installation
   propre à ce téléphone.
4. Rejoins un voyage partagé et une liste rapide partagée avec leurs codes.
5. Sur le téléphone A, change un état, une quantité et l'icône d'une liste
   rapide ; vérifie leur arrivée sur le téléphone B.
6. Sur le téléphone B, effectue une autre modification ; vérifie la convergence
   sur le téléphone A après synchronisation.
7. Coupe le réseau, réalise une modification, redémarre l'application, puis
   réactive le réseau et vérifie que l'opération est transmise une seule fois.
8. Vérifie que Personnel reste strictement local sur chaque téléphone.
9. Vérifie qu'un item Personnel copié dans un voyage partagé reste une copie
   autonome du voyage et ne crée pas d'entité Personnel distante.
