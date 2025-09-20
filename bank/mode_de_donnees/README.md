# 📊 Modèle de Données Supabase - E-Service Platform

## 🎯 Vue d'ensemble

Ce modèle de données a été conçu pour supporter une plateforme multi-services évolutive incluant :
- 🍽️ Service de restauration
- 🚴 Service de livraison/coursier
- ⛽ Service de recharge de gaz
- 🛒 Boutique/Supermarché en ligne
- 🔧 Quincaillerie
- 🔮 Futurs services à venir

## 🏗️ Architecture

### Principes de conception

1. **Évolutivité** : Structure modulaire permettant l'ajout facile de nouveaux services
2. **Performance** : Index optimisés pour les requêtes géospatiales et temporelles
3. **Sécurité** : Row Level Security (RLS) pour protéger les données
4. **Flexibilité** : Utilisation de JSONB pour les métadonnées extensibles

## 📁 Structure des fichiers

- `schema.sql` : Définition complète des tables, types et index
- `functions.sql` : Fonctions utilitaires, triggers et jobs CRON
- `policies.sql` : Politiques de sécurité Row Level (RLS)
- `README.md` : Documentation du modèle (ce fichier)

## 🗄️ Tables principales

### Tables de base

| Table | Description | Clés principales |
|-------|-------------|------------------|
| `users` | Utilisateurs de la plateforme | Authentification, rôles, suspensions |
| `addresses` | Adresses des utilisateurs | Géolocalisation, repères locaux |
| `services` | Types de services disponibles | Configuration par service |
| `providers` | Prestataires de services | Restaurants, boutiques, etc. |

### Tables de commande

| Table | Description | Relations |
|-------|-------------|-----------|
| `orders` | Commandes principales | User, Provider, Driver |
| `order_items` | Détails des commandes | Products, customizations |
| `order_tracking` | Suivi temps réel | Statuts, localisation |

### Tables de paiement

| Table | Description | Sécurité |
|-------|-------------|----------|
| `payments` | Transactions | Mobile Money, Cash, Card |
| `wallets` | Portefeuille électronique | Solde, bonus |
| `wallet_transactions` | Historique portefeuille | Audit trail |

### Tables spécifiques aux services

| Service | Tables dédiées | Description |
|---------|----------------|-------------|
| Restaurant | `products`, `dish_categories`, `product_variants` | Menu, plats, personnalisation |
| Livraison | `drivers`, `driver_service_zones` | Livreurs, zones de service |
| Gaz | `gas_bottle_types`, `gas_provider_stock` | Types de bouteilles, stock |

## 🔒 Sécurité

### Row Level Security (RLS)

- ✅ Activé sur toutes les tables sensibles
- 👤 Les utilisateurs ne voient que leurs propres données
- 🏪 Les prestataires gèrent leurs propres produits/services
- 🚴 Les livreurs accèdent uniquement à leurs livraisons

### Rôles utilisateur

```sql
CREATE TYPE user_role AS ENUM (
    'client',      -- Utilisateur final
    'provider',    -- Prestataire de service
    'driver',      -- Livreur
    'admin',       -- Administrateur
    'super_admin'  -- Super administrateur
);
```

## 🚀 Fonctionnalités clés

### 1. Géolocalisation

- Utilisation de PostGIS pour les requêtes spatiales
- Calcul automatique des distances et frais de livraison
- Recherche de prestataires/livreurs proches

```sql
-- Exemple : Trouver les restaurants dans un rayon de 5km
SELECT * FROM search_nearby_providers(
    p_lat := 5.316667,
    p_lon := -4.033333,
    p_radius := 5.0,
    p_service_type := 'restaurant'
);
```

### 2. Gestion des suspensions

- Suspension automatique après trop d'annulations
- Réactivation automatique après la période de suspension
- Système de comptage et de limites configurables

### 3. Programme de fidélité

- Points automatiques sur chaque commande
- Niveaux : Bronze → Argent → Or → Platine
- Cashback et bonus configurables

### 4. Support multi-langue

- Interface disponible en plusieurs langues
- Stockage de la préférence linguistique par utilisateur

## 📈 Optimisations

### Index créés

- **Géospatiaux** : Pour les recherches par proximité
- **Temporels** : Pour les requêtes par date
- **Recherche** : Sur les noms et identifiants
- **Performance** : Sur les clés étrangères fréquentes

### Vues matérialisées

- `active_providers` : Prestataires actifs et vérifiés
- `user_statistics` : Statistiques agrégées des utilisateurs
- `driver_dashboard` : Tableau de bord temps réel des livreurs

## 🔄 Migrations

### Ordre d'exécution

1. `schema.sql` - Créer la structure de base
2. `functions.sql` - Ajouter les fonctions et triggers
3. `policies.sql` - Appliquer les politiques de sécurité

### Commande Supabase

```bash
# Via l'interface Supabase
supabase db reset

# Ou manuellement
psql -h <host> -U postgres -d <database> -f schema.sql
psql -h <host> -U postgres -d <database> -f functions.sql
psql -h <host> -U postgres -d <database> -f policies.sql
```

## 🔧 Configuration requise

### Extensions PostgreSQL

- `uuid-ossp` : Génération d'UUID
- `postgis` : Fonctionnalités géospatiales
- `pg_cron` : Tâches planifiées

### Variables d'environnement

```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_KEY=your_service_key

# Database
DATABASE_URL=postgresql://user:password@host:port/database
```

## 📊 Métriques et monitoring

### KPIs trackés

- Taux d'activation (première commande sous 7 jours)
- Rétention (J30/J60/J90)
- Fréquence de commande
- Panier moyen
- NPS (Net Promoter Score)

### Tables de métriques

- `usage_metrics` : Métriques d'utilisation par service
- `provider_reviews` : Évaluations et commentaires
- `driver_reviews` : Performance des livreurs

## 🔮 Évolutions futures

### Phase 1 (3 mois)
- [ ] Commande vocale en langues locales
- [ ] Paiement par QR code
- [ ] Mode famille (comptes liés)

### Phase 2 (6 mois)
- [ ] Abonnements mensuels
- [ ] Recommandations IA
- [ ] Gamification avancée

### Phase 3 (12 mois)
- [ ] Social shopping (commandes groupées)
- [ ] Marketplace C2C
- [ ] Crédit intégré

## 📝 Notes importantes

1. **Edge Functions** : Utiliser pour les opérations sensibles (paiements, validations)
2. **Suspensions** : Configuration du nombre max d'annulations par le super admin
3. **Blocages** : Les utilisateurs peuvent bloquer des prestataires/livreurs
4. **Confirmation** : Code à 2 lettres majuscules (ex: A9, B2)
5. **Offline First** : Prévoir la synchronisation pour le mode hors ligne

## 🤝 Support

Pour toute question sur le modèle de données :
- Consulter la documentation Supabase
- Vérifier les logs des fonctions
- Tester avec les requêtes SQL fournies