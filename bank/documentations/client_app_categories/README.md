# 📱 Documentation Application Cliente - Catégories

Cette documentation est organisée par catégories pour faciliter la navigation et la consultation.

## 🗂️ Fichiers disponibles

- **[01-vision-et-caracteristiques.md](./01-vision-et-caracteristiques.md)** - Vision globale et caractéristiques principales de l'application cliente
- **[02-module-repas-restaurants.md](./02-module-repas-restaurants.md)** - Module de commande de repas avec entités restaurant/plat et parcours utilisateur complet
- **[03-module-livraison-coursier.md](./03-module-livraison-coursier.md)** - Service de livraison et coursier avec gestion des colis et tracking temps réel
- **[04-module-recharge-gaz.md](./04-module-recharge-gaz.md)** - Service de recharge de bouteilles de gaz avec planification et livraison
- **[05-module-boutique-supermarche.md](./05-module-boutique-supermarche.md)** - Module de courses en ligne avec navigation par rayons et livraison programmée
- **[06-module-quincaillerie.md](./06-module-quincaillerie.md)** - Service quincaillerie avec conseil expert et devis pour projets bricolage
- **[07-fonctionnalites-transverses.md](./07-fonctionnalites-transverses.md)** - Fonctionnalités communes : authentification, paiements, support client et fidélité
- **[08-metriques-succes-utilisateur.md](./08-metriques-succes-utilisateur.md)** - KPIs et objectifs de performance par service pour mesurer le succès utilisateur
- **[09-evolutions-futures.md](./09-evolutions-futures.md)** - Roadmap des évolutions prévues sur 3 phases de développement

## Notes
- Utiliser des Edge function pour les fonctionnalités sensibles
- Un utilisateur peu etre suspendu momentatément s'il annulle trop de commande(le nombre max d'annulation sera défini par le super admin)
- Un utilisateur peu bloquer un prestataire donné(livreur), celui-ci n'apparaitra pas dans ses prochaines recherches