-- ============================================
-- SCHÉMA DE BASE DE DONNÉES SUPABASE - E-SERVICE
-- ============================================
-- Architecture évolutive pour une plateforme multi-services
-- Supporte : Restaurants, Livraison, Gaz, Boutique, Quincaillerie et futurs services

-- ============================================
-- EXTENSIONS
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis"; -- Pour la géolocalisation
CREATE EXTENSION IF NOT EXISTS "pg_cron"; -- Pour les tâches planifiées

-- ============================================
-- TYPES ENUM
-- ============================================

-- Types d'utilisateurs
CREATE TYPE user_role AS ENUM (
    'client',
    'provider',
    'driver',
    'admin',
    'super_admin'
);

-- Types de services
CREATE TYPE service_type AS ENUM (
    'restaurant',
    'delivery',
    'gas',
    'boutique',
    'quincaillerie',
    'other' -- Pour les futurs services
);

-- Types de véhicules
CREATE TYPE vehicle_type AS ENUM (
    'pieton',
    'velo',
    'moto',
    'tricycle',
    'tricycle_cargo',
    'voiture',
    'camion'
);

-- Statuts de commande
CREATE TYPE order_status AS ENUM (
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'in_delivery',
    'delivered',
    'cancelled',
    'refunded'
);

-- Méthodes de paiement
CREATE TYPE payment_method AS ENUM (
    'cash',
    'mobile_money',
    'card',
    'wallet',
    'credit'
);

-- Statuts de paiement
CREATE TYPE payment_status AS ENUM (
    'pending',
    'processing',
    'completed',
    'failed',
    'refunded'
);

-- Types de badges pour les prestataires
CREATE TYPE provider_badge AS ENUM (
    'bronze',
    'silver',
    'gold',
    'platinum'
);

-- ============================================
-- TABLES DE BASE
-- ============================================

-- Table des utilisateurs (authentification Supabase)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    country_code VARCHAR(5) NOT NULL DEFAULT '+225',
    email VARCHAR(255) UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    avatar_url TEXT,
    role user_role DEFAULT 'client',
    language VARCHAR(10) DEFAULT 'fr',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    suspension_count INTEGER DEFAULT 0,
    max_cancellations INTEGER DEFAULT 5,
    cancellation_count INTEGER DEFAULT 0,
    suspension_end_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Table des adresses
CREATE TABLE addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100),
    coordinates GEOGRAPHY(Point, 4326) NOT NULL,
    street_address TEXT,
    neighborhood VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR(100) DEFAULT 'Côte d''Ivoire',
    postal_code VARCHAR(20),
    local_landmarks TEXT[], -- Repères locaux
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ -- Soft delete
);

-- Table des services disponibles
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type service_type NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url TEXT,
    is_active BOOLEAN DEFAULT true,
    min_order_amount DECIMAL(10,2),
    commission_rate DECIMAL(5,2) DEFAULT 0.15, -- 10% par défaut
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ, -- Soft delete
    settings JSONB DEFAULT '{}'::jsonb
);

-- Table des prestataires (restaurants, boutiques, etc.)
CREATE TABLE providers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    service_id UUID REFERENCES services(id),
    business_name VARCHAR(255) NOT NULL,
    logo_url TEXT,
    banner_url TEXT,
    description TEXT,
    coordinates GEOGRAPHY(Point, 4326) NOT NULL,
    address TEXT NOT NULL,
    neighborhood VARCHAR(255),
    local_landmarks TEXT[],
    delivery_radius DECIMAL(5,2), -- en km
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    is_busy BOOLEAN DEFAULT false, -- Indique si le prestataire est trop occupé
    badge provider_badge DEFAULT 'bronze', -- Badge du prestataire
    rating DECIMAL(2,1) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    total_reviews INTEGER DEFAULT 0,
    acceptance_rate DECIMAL(5,2),
    average_response_time INTEGER, -- en secondes
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ, -- Soft delete
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Table des horaires d'ouverture
CREATE TABLE provider_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 7),
    opening_time TIME NOT NULL,
    closing_time TIME NOT NULL,
    is_closed BOOLEAN DEFAULT false,
    break_start TIME,
    break_end TIME,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(provider_id, day_of_week)
);

-- ============================================
-- TABLES SPÉCIFIQUES AUX RESTAURANTS
-- ============================================

-- Catégories de cuisine
CREATE TABLE cuisine_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    icon_url TEXT,
    sort_order INTEGER DEFAULT 0
);

-- Relation prestataire-catégories cuisine
CREATE TABLE provider_cuisines (
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    cuisine_id UUID REFERENCES cuisine_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (provider_id, cuisine_id)
);

-- Catégories de plats
CREATE TABLE dish_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    icon_url TEXT,
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table des plats/produits
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    category_id UUID REFERENCES dish_categories(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    images_url TEXT[],
    base_price DECIMAL(10,2) NOT NULL,
    discount_price DECIMAL(10,2),
    preparation_time INTEGER, -- en minutes
    is_available BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    stock_quantity INTEGER,
    max_quantity_per_order INTEGER DEFAULT 99,
    tags TEXT[],
    allergens TEXT[],
    nutritional_info JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ, -- Soft delete
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Options et variantes de produits
CREATE TABLE product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price_modifier DECIMAL(10,2) DEFAULT 0,
    is_required BOOLEAN DEFAULT false,
    min_selections INTEGER DEFAULT 0,
    max_selections INTEGER DEFAULT 1,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Valeurs des options
CREATE TABLE variant_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES product_variants(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0
);

-- ============================================
-- TABLES POUR LA LIVRAISON
-- ============================================

-- Table des livreurs
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    vehicle_type vehicle_type NOT NULL,
    vehicle_brand VARCHAR(100),
    vehicle_model VARCHAR(100),
    vehicle_color VARCHAR(50),
    vehicle_plate VARCHAR(50),
    vehicle_photos TEXT[],
    insurance_document TEXT,
    insurance_valid_until DATE,
    carrying_capacity DECIMAL(10,2), -- en kg
    is_verified BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    is_available BOOLEAN DEFAULT false,
    current_location GEOGRAPHY(Point, 4326),
    rating DECIMAL(2,1) DEFAULT 0.0,
    total_deliveries INTEGER DEFAULT 0,
    success_rate DECIMAL(5,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    deleted_at TIMESTAMPTZ, -- Soft delete
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Zones de service des livreurs
CREATE TABLE driver_service_zones (
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    zone_name VARCHAR(100),
    zone_polygon GEOGRAPHY(Polygon, 4326),
    max_distance DECIMAL(5,2), -- en km
    PRIMARY KEY (driver_id, zone_name)
);

-- ============================================
-- TABLES POUR LES COMMANDES
-- ============================================

-- Table principale des commandes
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id),
    provider_id UUID REFERENCES providers(id),
    driver_id UUID REFERENCES drivers(id),
    service_type service_type NOT NULL,
    status order_status DEFAULT 'pending',
    subtotal DECIMAL(10,2) NOT NULL,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    service_fee DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method payment_method,
    payment_status payment_status DEFAULT 'pending',
    delivery_address_id UUID REFERENCES addresses(id),
    delivery_coordinates GEOGRAPHY(Point, 4326),
    delivery_address TEXT,
    delivery_instructions TEXT,
    confirmation_code VARCHAR(2), -- Code A9, B2, etc.
    scheduled_for TIMESTAMPTZ,
    estimated_delivery_time TIMESTAMPTZ,
    actual_delivery_time TIMESTAMPTZ,
    preparation_time INTEGER, -- en minutes
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    cancelled_at TIMESTAMPTZ,
    cancellation_reason TEXT,
    deleted_at TIMESTAMPTZ, -- Soft delete
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Détails des commandes
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL, -- Copie pour historique
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    notes TEXT,
    customizations JSONB DEFAULT '{}'::jsonb, -- Options sélectionnées
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tracking des commandes
CREATE TABLE order_tracking (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    status order_status NOT NULL,
    location GEOGRAPHY(Point, 4326),
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES users(id)
);

-- ============================================
-- TABLES POUR LES PAIEMENTS
-- ============================================

-- Transactions de paiement
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id VARCHAR(100) UNIQUE,
    order_id UUID REFERENCES orders(id),
    user_id UUID REFERENCES users(id),
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'XOF',
    method payment_method NOT NULL,
    status payment_status DEFAULT 'pending',
    provider_reference VARCHAR(255), -- Référence Orange/MTN/etc.
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    failed_at TIMESTAMPTZ,
    refunded_at TIMESTAMPTZ
);

-- Portefeuille utilisateur
CREATE TABLE wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    balance DECIMAL(10,2) DEFAULT 0.00,
    bonus_balance DECIMAL(10,2) DEFAULT 0.00,
    currency VARCHAR(3) DEFAULT 'XOF',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Historique des transactions du portefeuille
CREATE TABLE wallet_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID REFERENCES wallets(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- 'credit', 'debit', 'bonus', 'cashback'
    amount DECIMAL(10,2) NOT NULL,
    balance_after DECIMAL(10,2) NOT NULL,
    reference VARCHAR(255),
    description TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TABLES POUR LA FIDÉLITÉ
-- ============================================

-- Programme de fidélité
CREATE TABLE loyalty_programs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    points_per_amount DECIMAL(10,2) DEFAULT 100.00, -- Points par 100 FCFA
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Points de fidélité des utilisateurs
CREATE TABLE user_loyalty_points (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    program_id UUID REFERENCES loyalty_programs(id),
    total_points INTEGER DEFAULT 0,
    available_points INTEGER DEFAULT 0,
    tier VARCHAR(20) DEFAULT 'bronze', -- bronze, silver, gold, platinum
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, program_id)
);

-- Historique des points
CREATE TABLE loyalty_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    points INTEGER NOT NULL,
    transaction_type VARCHAR(20), -- 'earned', 'redeemed', 'expired'
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TABLES POUR LES AVIS ET ÉVALUATIONS
-- ============================================

-- Avis sur les prestataires
CREATE TABLE provider_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    tags TEXT[],
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(order_id, provider_id, user_id)
);

-- Avis sur les livreurs
CREATE TABLE driver_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    tip_amount DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(order_id, driver_id, user_id)
);

-- ============================================
-- TABLES POUR LE SUPPORT CLIENT
-- ============================================

-- Tickets de support
CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_number VARCHAR(20) UNIQUE NOT NULL,
    user_id UUID REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    category VARCHAR(50) NOT NULL,
    priority VARCHAR(20) DEFAULT 'normal', -- low, normal, high, urgent
    status VARCHAR(20) DEFAULT 'open', -- open, in_progress, resolved, closed
    subject TEXT NOT NULL,
    description TEXT,
    assigned_to UUID REFERENCES users(id),
    resolution TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    closed_at TIMESTAMPTZ
);

-- Messages des tickets
CREATE TABLE ticket_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ticket_id UUID REFERENCES support_tickets(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id),
    message TEXT NOT NULL,
    attachments TEXT[],
    is_internal BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TABLES POUR LES BLOCAGES UTILISATEURS
-- ============================================

-- Utilisateurs bloqués
CREATE TABLE user_blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    blocked_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    blocked_type VARCHAR(20), -- 'driver', 'provider'
    reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, blocked_user_id)
);

-- ============================================
-- TABLES POUR LES NOTIFICATIONS
-- ============================================

-- Notifications push
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    data JSONB DEFAULT '{}'::jsonb,
    is_read BOOLEAN DEFAULT false,
    sent_at TIMESTAMPTZ DEFAULT NOW(),
    read_at TIMESTAMPTZ
);

-- Tokens de notification
CREATE TABLE notification_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token TEXT NOT NULL UNIQUE,
    platform VARCHAR(20), -- 'ios', 'android', 'web'
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TABLES POUR LES PROMOTIONS
-- ============================================

-- Codes promo
CREATE TABLE promo_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type VARCHAR(20) NOT NULL, -- 'percentage', 'fixed'
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_amount DECIMAL(10,2),
    max_discount_amount DECIMAL(10,2),
    service_type service_type,
    provider_id UUID REFERENCES providers(id),
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0,
    valid_from TIMESTAMPTZ DEFAULT NOW(),
    valid_until TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Utilisation des codes promo
CREATE TABLE promo_code_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    promo_code_id UUID REFERENCES promo_codes(id),
    user_id UUID REFERENCES users(id),
    order_id UUID REFERENCES orders(id),
    discount_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(promo_code_id, user_id, order_id)
);

-- ============================================
-- TABLES SPÉCIFIQUES AU SERVICE GAZ
-- ============================================

-- Types de bouteilles de gaz
CREATE TABLE gas_bottle_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    size VARCHAR(20) NOT NULL, -- '6kg', '12kg', '25kg', '50kg'
    brand VARCHAR(50), -- La marque
    deposit_price DECIMAL(10,2), -- Prix de la consigne
    refill_price DECIMAL(10,2),
    purchase_price DECIMAL(10,2),
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Stock de gaz par prestataire
CREATE TABLE gas_provider_stock (
    provider_id UUID REFERENCES providers(id) ON DELETE CASCADE,
    bottle_type_id UUID REFERENCES gas_bottle_types(id),
    stock_quantity INTEGER DEFAULT 0,
    last_refill_date TIMESTAMPTZ,
    PRIMARY KEY (provider_id, bottle_type_id)
);

-- ============================================
-- TABLES POUR LES MÉTRIQUES
-- ============================================

-- Métriques d'utilisation
CREATE TABLE usage_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    service_type service_type,
    metric_type VARCHAR(50), -- 'first_order', 'retention', 'frequency'
    metric_value DECIMAL(10,2),
    date DATE NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- INDEX POUR OPTIMISATION
-- ============================================

-- Index géospatiaux
CREATE INDEX idx_users_location ON addresses USING GIST(coordinates);
CREATE INDEX idx_providers_location ON providers USING GIST(coordinates);
CREATE INDEX idx_drivers_location ON drivers USING GIST(current_location);
CREATE INDEX idx_orders_delivery_location ON orders USING GIST(delivery_coordinates);

-- Index de recherche
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_providers_name ON providers(business_name);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_provider ON products(provider_id);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_provider ON orders(provider_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created ON orders(created_at);

-- Index pour les performances
CREATE INDEX idx_provider_schedules_provider ON provider_schedules(provider_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_wallet_transactions_wallet ON wallet_transactions(wallet_id);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);

-- ============================================
-- VUES UTILES
-- ============================================

-- Vue des prestataires actifs avec leurs services
CREATE VIEW active_providers AS
SELECT
    p.*,
    s.type as service_type,
    s.name as service_name
FROM providers p
JOIN services s ON p.service_id = s.id
WHERE p.is_active = true
    AND p.is_verified = true
    AND p.deleted_at IS NULL  -- Exclure les prestataires supprimés
    AND s.is_active = true
    AND s.deleted_at IS NULL;  -- Exclure les services supprimés

-- Vue des statistiques utilisateurs
CREATE VIEW user_statistics AS
SELECT
    u.id,
    u.full_name,
    COUNT(DISTINCT o.id) as total_orders,
    SUM(o.total_amount) as total_spent,
    AVG(o.total_amount) as average_order_value,
    MAX(o.created_at) as last_order_date
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.full_name;

-- Vue du dashboard livreur
CREATE VIEW driver_dashboard AS
SELECT
    d.*,
    COUNT(DISTINCT o.id) as today_deliveries,
    SUM(CASE WHEN o.status = 'delivered' THEN 1 ELSE 0 END) as completed_deliveries,
    AVG(dr.rating) as average_rating
FROM drivers d
LEFT JOIN orders o ON d.id = o.driver_id
    AND DATE(o.created_at) = CURRENT_DATE
LEFT JOIN driver_reviews dr ON d.id = dr.driver_id
GROUP BY d.id;

-- ============================================
-- COMMENTAIRES SUR LES TABLES
-- ============================================

COMMENT ON TABLE users IS 'Table principale des utilisateurs de la plateforme';
COMMENT ON TABLE providers IS 'Prestataires de services (restaurants, boutiques, etc.)';
COMMENT ON TABLE orders IS 'Commandes passées sur la plateforme';
COMMENT ON TABLE products IS 'Produits et plats disponibles';
COMMENT ON TABLE drivers IS 'Livreurs de la plateforme';
COMMENT ON TABLE wallets IS 'Portefeuille électronique des utilisateurs';
COMMENT ON TABLE support_tickets IS 'Système de support client intégré';
COMMENT ON COLUMN orders.confirmation_code IS 'Code de confirmation à 2 caractères (ex: A9, B2)';
COMMENT ON COLUMN users.suspension_count IS 'Nombre de suspensions temporaires';
COMMENT ON COLUMN users.max_cancellations IS 'Nombre maximum d''annulations autorisées';