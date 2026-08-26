# Checklist Voyage — RC11 météo sans carte

Version Android : `1.0.0-rc.11+25`.

## Correction livrée

- le résumé météo compact de la fiche Voyage est conservé ;
- son ouverture affiche directement la liste quotidienne du séjour ;
- l’onglet et tous les widgets de carte, la grille régionale, les marqueurs,
  le zoom et le recentrage sont supprimés ;
- `flutter_map`, `latlong2` et leurs dépendances transitives sont retirés ;
- aucune requête OpenStreetMap, de tuile ou de fournisseur cartographique ne
  subsiste ;
- chaque ligne compacte affiche date, condition, minimum/maximum, pluie, vent
  et le libellé `Prévision` ou `Tendance habituelle` ;
- la destination longue est tronquée proprement dans l’en-tête.

La logique temporelle ne change pas : aujourd’hui à J+16 inclus utilise les
prévisions Open-Meteo ; les autres jours utilisent une tendance historique.
Un séjour mixte conserve la source correcte jour par jour.

## Cache, stockage et hors ligne

Le cache JSON conserve uniquement le géocodage, les journées de la destination
et les horodatages. Une ancienne entrée RC10 contenant encore `map_points`
reste lisible : ce champ supplémentaire est ignoré, sans suppression ni
migration destructive.

Les durées restent de 6 heures pour les prévisions et 90 jours pour les
tendances. Une donnée périmée peut toujours être affichée hors ligne avec
l’indication `Dernières données en cache`. Sans cache, l’erreur hors ligne
reste explicite.

Le schéma Drift reste en v8. Aucun voyage, item, choix de génération, document
partagé, capacité ou élément d’outbox n’est modifié.

## Validation technique

- `flutter analyze --no-pub` : aucune anomalie en 14,9 s ;
- tests météo ciblés : 17 réussis ;
- suite Flutter complète : 132 réussis, 5 contrôles réels conditionnels
  ignorés faute de variables externes ;
- J-30, J-17, J-16, J-10, voyage passé, séjour mixte, cache, hors ligne,
  changement de destination/dates et erreur Open-Meteo couverts ;
- affichages 3, 10 et 20 jours contrôlés à 360 px, avec destination longue,
  thème clair, thème sombre et séjour mixte ;
- package : `fr.checklistvoyage.app` ;
- version Android : code `25`, nom `1.0.0-rc.11` ;
- APK release : 64 872 836 octets ;
- SHA-256 APK :
  `0C17526F94ECCCBC194DA6A545177F9BD9518F69911BDA93F966A9F0FB6FC378` ;
- signature APK v2 valide ;
- certificat SHA-256 :
  `73EDA51FF7111FBB2DD70AE00DB7EB36322480AAE1B71A56091DA2A81DD85D48`.

Le Samsung n’était pas connecté à la fin de la construction. L’installation
et la validation réelle n’ont donc pas été revendiquées.

## Protocole de validation sur téléphone

1. Installer `Checklist-Voyage-1.0.0-rc.11+25.apk` comme mise à jour, sans
   désinstaller `fr.checklistvoyage.app`. Android doit proposer une mise à
   jour et conserver les données.
2. Ouvrir l’application et vérifier la version `1.0.0-rc.11 · 25`, puis la
   présence des voyages, de la bibliothèque et des listes rapides existants.
3. Ouvrir un voyage daté avec destination. Le résumé Météo doit être compact
   et ne doit modifier aucun item.
4. Toucher le résumé. La page doit ouvrir directement la liste quotidienne :
   aucun onglet, bouton ou libellé `Carte` ne doit apparaître.
5. Sur chaque jour visible, contrôler date, icône/condition, températures,
   pluie, vent et source.
6. Contrôler un voyage à J+16 maximum : les journées couvertes indiquent
   `Prévision`.
7. Contrôler un voyage plus lointain : ses journées indiquent
   `Tendance habituelle`, jamais `Prévision`.
8. Sur un séjour traversant J+16, vérifier que les deux libellés coexistent
   aux bonnes dates.
9. Tester un séjour de 3 jours, puis un séjour long proche de 20 jours. La
   liste doit défiler sans lenteur ni débordement.
10. Tester une destination longue : le titre doit rester sur une ligne sans
    recouvrir les actions Android.
11. Refaire la page en thème sombre puis clair. Les textes et séparateurs
    doivent rester lisibles.
12. Après un chargement réussi, couper le réseau et rouvrir la météo. Le cache
    doit s’afficher ; s’il est ancien, l’indication doit rester discrète.
13. Hors ligne, ouvrir une météo jamais chargée. L’erreur doit être claire et
    toute la checklist doit rester utilisable.
14. Fermer complètement et relancer l’application. Vérifier à nouveau les
    données Checklist, les états, les quantités et la météo en cache.
15. Vérifier enfin que la synchronisation habituelle se termine sans nouvelle
    erreur et que l’outbox reste saine.

En cas d’échec, noter le numéro de l’étape, le résultat observé et joindre une
capture. RC11 ne devient validée sur téléphone qu’après confirmation explicite
de ce protocole.
