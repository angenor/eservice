# 🤖 Guide d'intégration LLM

> **Note** : Les recommandations de ce guide ont été intégrées directement dans `schema.sql` et `functions.sql`.
> Ce document sert de référence pour l'implémentation côté application.

## 📊 Analyse de votre modèle actuel

### ✅ Points forts
1. **Nomenclature claire** : Vos tables et colonnes ont des noms explicites
2. **ENUMs bien définis** : Les statuts et types sont standardisés
3. **Relations logiques** : Structure relationnelle cohérente
4. **Flexibilité JSONB** : Métadonnées extensibles pour données non-structurées
5. **Géolocalisation** : PostGIS intégré pour les requêtes spatiales

### ⚠️ Points à améliorer pour les LLMs

#### 1. **Manque de contexte conversationnel**
- Pas de tables pour stocker l'historique des conversations
- Absence de mécanisme pour maintenir le contexte entre les interactions
- Pas de système pour tracker les préférences implicites

#### 2. **Complexité des requêtes**
- Relations multiples nécessitant des JOIN complexes
- Pas de vues simplifiées pour les cas d'usage courants
- Nomenclature technique (ex: `provider_id` vs "restaurant")

#### 3. **Absence de couche sémantique**
- Pas de système pour stocker les intentions détectées
- Manque de mapping entre langage naturel et données structurées
- Pas de templates de réponses

## 🎯 Recommandations prioritaires

### 1. **Ajouter les tables LLM essentielles** (voir `llm_optimization.sql`)

```sql
-- Tables minimales à ajouter :
- llm_conversations : Sessions de conversation
- llm_messages : Messages avec analyse NLP
- llm_response_templates : Templates de réponses
- voice_order_shortcuts : Raccourcis vocaux
```

### 2. **Créer des vues simplifiées**

Les LLMs fonctionnent mieux avec des structures plates et des noms intuitifs :

```sql
-- Au lieu de :
SELECT p.name, pr.business_name, o.status
FROM products p
JOIN providers pr ON p.provider_id = pr.id
JOIN orders o ON o.provider_id = pr.id

-- Utiliser :
SELECT product_name, restaurant_name, order_status
FROM llm_products_view
```

### 3. **Enrichir avec du langage naturel**

Ajouter des colonnes ou fonctions qui génèrent du texte naturel :

```sql
-- Exemple de fonction
CREATE FUNCTION describe_order_status(status order_status)
RETURNS TEXT AS $$
  SELECT CASE status
    WHEN 'preparing' THEN 'Votre commande est en cours de préparation'
    WHEN 'in_delivery' THEN 'Votre livreur est en route'
    -- etc.
  END;
$$;
```

### 4. **Implémenter un système de contexte**

```javascript
// Contexte à maintenir côté application
{
  "user_id": "uuid",
  "conversation_id": "uuid",
  "current_order": null,
  "last_provider": "Restaurant X",
  "preferences": {
    "language": "fr",
    "payment_method": "mobile_money",
    "default_address": "uuid"
  },
  "conversation_history": [...]
}
```

## 🔧 Architecture recommandée

### Couches d'abstraction

```
┌─────────────────────────────┐
│     Interface Vocale/Chat    │ ← Utilisateur
├─────────────────────────────┤
│         LLM Engine           │ ← GPT-4, Claude, etc.
├─────────────────────────────┤
│    Couche de traduction     │ ← Intent/Entity extraction
├─────────────────────────────┤
│     Vues simplifiées DB      │ ← llm_*_view
├─────────────────────────────┤
│    Tables principales DB     │ ← Structure existante
└─────────────────────────────┘
```

### Flux de traitement optimal

1. **Entrée vocale/texte** → Transcription
2. **Analyse NLP** → Extraction d'intention et entités
3. **Validation** → Vérification des données extraites
4. **Query Builder** → Construction SQL via vues simplifiées
5. **Exécution** → Transaction dans les tables principales
6. **Réponse** → Template + données = réponse naturelle

## 📝 Exemples de simplification

### Commande vocale typique

**Utilisateur** : "Je veux commander 2 pizzas margherita chez Pizza Palace"

**Extraction LLM** :
```json
{
  "intent": "order_create",
  "entities": {
    "quantity": 2,
    "product": "pizza margherita",
    "provider": "Pizza Palace"
  }
}
```

**Requête simplifiée** :
```sql
-- Via la vue llm_products_view
SELECT product_id, price, restaurant_name
FROM llm_products_view
WHERE product_name ILIKE '%pizza margherita%'
  AND restaurant_name ILIKE '%Pizza Palace%'
  AND is_available = true;
```

### Support client

**Utilisateur** : "Où est ma commande ?"

**Contexte nécessaire** :
```sql
-- Via get_user_context() et llm_orders_view
SELECT
  order_number,
  status_text_fr,
  delivery_estimate_text,
  confirmation_code
FROM llm_orders_view
WHERE user_id = :user_id
  AND status NOT IN ('delivered', 'cancelled')
ORDER BY created_at DESC
LIMIT 1;
```

## 🚀 Plan de migration

### Phase 1 : Fondations (Semaine 1-2)
- [ ] Installer pgvector pour embeddings (optionnel mais recommandé)
- [ ] Créer les tables LLM de base
- [ ] Implémenter les vues simplifiées
- [ ] Ajouter les fonctions de formatage

### Phase 2 : Intégration (Semaine 3-4)
- [ ] Connecter le LLM aux vues
- [ ] Implémenter le système de templates
- [ ] Créer les premiers raccourcis vocaux
- [ ] Logger les conversations

### Phase 3 : Optimisation (Semaine 5-6)
- [ ] Analyser les logs pour identifier les patterns
- [ ] Créer des index spécifiques
- [ ] Optimiser les requêtes fréquentes
- [ ] Enrichir les templates

## 💡 Conseils pratiques

### 1. **Prompts système efficaces**

```python
system_prompt = """
Tu es l'assistant vocal de E-Service Platform.
Base de données disponible:
- Produits : via llm_products_view (colonnes: product_name, price, restaurant_name)
- Commandes : via llm_orders_view (colonnes: order_number, status_text_fr)
- Restaurants : via llm_providers_view (colonnes: business_name, neighborhood, status_text)

Utilise TOUJOURS ces vues pour les requêtes.
Réponds en français de manière concise et amicale.
"""
```

### 2. **Gestion des erreurs**

```sql
-- Table pour logger les échecs d'interprétation
CREATE TABLE llm_errors (
  id UUID PRIMARY KEY,
  conversation_id UUID,
  user_input TEXT,
  error_type VARCHAR(50),
  attempted_query TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 3. **Métriques de performance**

```sql
-- Vue pour analyser l'efficacité du LLM
CREATE VIEW llm_performance_metrics AS
SELECT
  DATE(started_at) as date,
  interaction_type,
  AVG(CASE WHEN resolved THEN 1 ELSE 0 END) as resolution_rate,
  AVG(message_count) as avg_messages,
  AVG(session_duration) as avg_duration_seconds
FROM llm_conversations
GROUP BY DATE(started_at), interaction_type;
```

## 🔐 Sécurité et confidentialité

### Recommandations critiques

1. **Ne jamais exposer** :
   - Les IDs internes (UUID)
   - Les données sensibles (paiement)
   - Les informations d'autres utilisateurs

2. **Toujours valider** :
   - Les entités extraites avant exécution
   - Les permissions utilisateur
   - Les limites de commande

3. **Anonymiser** :
   - Les logs de conversation après 30 jours
   - Les données d'entraînement
   - Les métriques agrégées

## 📈 Indicateurs de succès

- **Taux de résolution** : >80% sans intervention humaine
- **Temps moyen de commande** : <2 minutes en vocal
- **Précision d'extraction** : >95% sur les entités critiques
- **Satisfaction utilisateur** : NPS >70

## 🔮 Évolutions futures

1. **Recherche sémantique** avec pgvector
2. **Recommandations personnalisées** via ML
3. **Détection d'anomalies** dans les commandes
4. **Support multimodal** (images de produits)
5. **Traduction automatique** pour support multilingue