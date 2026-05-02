# ✈ Checklist Voyage

Application web de checklist de voyage partagée en temps réel avec la famille.

## Fonctionnalités

- 🗺 **Créer des voyages** avec date et types (avion, plage, montagne, train…)
- ☑ **Checklist par catégorie** avec compteur d'items cochés
- ➕ **Ajouter des catégories et des items** personnalisés
- 🔗 **Partage en temps réel** via un code à 6 caractères
- 📱 Fonctionne sur mobile et desktop

## Déploiement GitHub Pages

1. Crée un nouveau repo GitHub nommé `checklist-voyage`
2. Upload le fichier `index.html` à la racine
3. Va dans **Settings → Pages → Source → Deploy from branch → main**
4. L'app sera disponible sur `https://TON-PSEUDO.github.io/checklist-voyage/`

## Stack

- HTML / CSS / JS vanilla (aucune dépendance)
- Stockage persistant via l'API `window.storage` de Claude.ai
- Partage en temps réel par code (polling toutes les 3 secondes)
