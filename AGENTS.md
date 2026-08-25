# Consignes du projet Checklist Voyage

## Validation des versions Android

Après chaque nouvelle version Android (debug, RC ou release), fournir systématiquement à l'utilisateur un protocole de test sur téléphone adapté aux modifications réellement livrées.

Le protocole doit contenir au minimum :

- la version et le numéro de build à vérifier ;
- les précautions d'installation, notamment l'absence de désinstallation lorsqu'il faut conserver les données locales ;
- le contrôle de conservation des données existantes ;
- un test précis pour chaque modification fonctionnelle ou visuelle de la version ;
- les tests de non-régression pertinents ;
- un redémarrage complet de l'application ;
- un contrôle hors ligne lorsque la fonction peut fonctionner localement ;
- les contrôles clair/sombre et à largeur de téléphone lorsque l'interface a changé ;
- le résultat attendu pour chaque étape ;
- la manière de signaler un échec : étape, résultat observé et capture si possible.

Distinguer explicitement :

- **validation technique** : analyse, tests automatisés, signature et vérification de l'APK ;
- **validation téléphone** : protocole exécuté et confirmé par l'utilisateur sur un appareil réel.

Ne jamais présenter une version comme validée sur téléphone avant la confirmation de l'utilisateur. Conserver la dernière version validée sur téléphone comme sauvegarde jusqu'à validation de la nouvelle version.
