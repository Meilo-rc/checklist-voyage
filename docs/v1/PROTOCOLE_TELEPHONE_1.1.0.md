# Protocole téléphone — Checklist Voyage 1.1.0

## Préparation

Version attendue sur les deux téléphones : `1.1.0 · 29`.

Installer l'APK uniquement comme mise à jour. Ne pas désinstaller l'application
et ne pas effacer ses données. Conserver l'APK `1.0.1+28`, dernière version
validée sur téléphone, comme sauvegarde jusqu'à validation complète de 1.1.0.

Sur chaque téléphone, vérifier avant les essais que les voyages, la
bibliothèque et les listes rapides déjà présents sont toujours visibles.

## 1. Liste rapide — application destinataire fermée

1. Sur le téléphone A, ouvrir une liste rapide dédiée au test.
2. Appuyer sur **Partager**.
3. Vérifier que la feuille de partage Android apparaît.
4. Vérifier que le message contient le nom, le code en clair et un lien HTTPS
   avec `type=quick-list`.
5. Envoyer le message au téléphone B par WhatsApp, mail ou Messages.
6. Fermer complètement Checklist Voyage sur B, puis toucher le lien.

Résultat attendu : Checklist Voyage s'ouvre sur **Rejoindre une liste rapide**,
avec le bon code prérempli. La liste ne doit pas être importée avant l'appui sur
**Rejoindre**.

7. Appuyer d'abord sur **Annuler** et vérifier que la liste n'est pas ajoutée.
8. Ouvrir de nouveau le lien, puis appuyer sur **Rejoindre**.

Résultat attendu : la liste apparaît avec son nom, son icône et ses items.

9. Modifier un item sur A, attendre la synchronisation et vérifier B.
10. Modifier un autre item sur B et vérifier A.

## 2. Voyage — application destinataire en arrière-plan

1. Sur A, ouvrir un voyage dédié au test et appuyer sur **Partager**.
2. Vérifier le nom ou la destination, le code et le lien avec `type=trip`.
3. Sur B, laisser Checklist Voyage en arrière-plan puis toucher le lien reçu.

Résultat attendu : l'application revient au premier plan sur **Rejoindre un
voyage**, avec le code prérempli et sans jonction automatique.

4. Valider avec **Rejoindre**.
5. Vérifier le voyage, ses groupes, catégories, items, quantités et états.
6. Modifier un état sur A et une quantité sur B, puis vérifier la convergence
   dans les deux sens.

## 3. Application déjà ouverte et ancien code manuel

1. Laisser Checklist Voyage ouverte sur B et toucher de nouveau un lien de
   partage valide.
2. Vérifier qu'une seule boîte de jonction apparaît, sans empiler plusieurs
   écrans.
3. Annuler.
4. Utiliser ensuite **Rejoindre avec un code** et saisir manuellement le code
   visible dans le message.

Résultat attendu : le parcours manuel continue de fonctionner avec la même
jonction et la même synchronisation.

## 4. Redémarrage, données et hors ligne

1. Fermer complètement puis rouvrir l'application sur les deux téléphones.
2. Vérifier que les données anciennes et les documents rejoints sont toujours
   présents.
3. Passer un téléphone hors ligne.
4. Vérifier que les voyages et listes déjà locaux restent consultables et
   modifiables.

Résultat attendu : le partage ou la jonction signale simplement l'absence de
réseau, tandis que les fonctions locales continuent de fonctionner. Après
retour du réseau, la synchronisation reprend.

## 5. Affichage

Vérifier les deux boîtes de confirmation et le retour à l'application en mode
clair puis sombre, sur la largeur normale du téléphone. Le texte, le code et
les boutons **Annuler** / **Rejoindre** doivent rester lisibles et accessibles.

## Validation

La validation technique est faite, mais la version n'est validée sur téléphone
qu'après confirmation de tous les parcours A ↔ B ci-dessus.

En cas d'échec, noter l'étape, le téléphone, l'état de l'application
(fermée/arrière-plan/ouverte), le résultat observé et joindre une capture si
possible.
