-- ============================================
-- POLITIQUES DE SÉCURITÉ ROW LEVEL (RLS) SUPABASE
-- ============================================

-- Activer RLS sur toutes les tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE driver_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLITIQUES POUR LA TABLE USERS
-- ============================================

-- Les utilisateurs peuvent voir leur propre profil
CREATE POLICY "users_select_own" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Les utilisateurs peuvent voir les profils publics des prestataires et livreurs
CREATE POLICY "users_select_public_profiles" ON users
    FOR SELECT
    USING (role IN ('provider', 'driver') AND is_active = true);

-- Les utilisateurs peuvent modifier leur propre profil
CREATE POLICY "users_update_own" ON users
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- ============================================
-- POLITIQUES POUR LA TABLE ADDRESSES
-- ============================================

-- Les utilisateurs peuvent voir leurs propres adresses
CREATE POLICY "addresses_select_own" ON addresses
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les utilisateurs peuvent créer leurs propres adresses
CREATE POLICY "addresses_insert_own" ON addresses
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent modifier leurs propres adresses
CREATE POLICY "addresses_update_own" ON addresses
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs propres adresses
CREATE POLICY "addresses_delete_own" ON addresses
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR LA TABLE PROVIDERS
-- ============================================

-- Tout le monde peut voir les prestataires actifs et vérifiés
CREATE POLICY "providers_select_active" ON providers
    FOR SELECT
    USING (is_active = true AND is_verified = true);

-- Les prestataires peuvent voir leur propre profil complet
CREATE POLICY "providers_select_own" ON providers
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les prestataires peuvent modifier leur propre profil
CREATE POLICY "providers_update_own" ON providers
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR LA TABLE PRODUCTS
-- ============================================

-- Tout le monde peut voir les produits disponibles des prestataires actifs
CREATE POLICY "products_select_available" ON products
    FOR SELECT
    USING (
        is_available = true AND
        EXISTS (
            SELECT 1 FROM providers
            WHERE providers.id = products.provider_id
            AND providers.is_active = true
            AND providers.is_verified = true
        )
    );

-- Les prestataires peuvent voir tous leurs produits
CREATE POLICY "products_select_own_provider" ON products
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM providers
            WHERE providers.id = products.provider_id
            AND providers.user_id = auth.uid()
        )
    );

-- Les prestataires peuvent créer des produits
CREATE POLICY "products_insert_provider" ON products
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM providers
            WHERE providers.id = products.provider_id
            AND providers.user_id = auth.uid()
        )
    );

-- Les prestataires peuvent modifier leurs produits
CREATE POLICY "products_update_provider" ON products
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM providers
            WHERE providers.id = products.provider_id
            AND providers.user_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM providers
            WHERE providers.id = products.provider_id
            AND providers.user_id = auth.uid()
        )
    );

-- ============================================
-- POLITIQUES POUR LA TABLE ORDERS
-- ============================================

-- Les utilisateurs peuvent voir leurs propres commandes
CREATE POLICY "orders_select_own" ON orders
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les prestataires peuvent voir les commandes qui leur sont assignées
CREATE POLICY "orders_select_provider" ON orders
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM providers
            WHERE providers.id = orders.provider_id
            AND providers.user_id = auth.uid()
        )
    );

-- Les livreurs peuvent voir les commandes qui leur sont assignées
CREATE POLICY "orders_select_driver" ON orders
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM drivers
            WHERE drivers.id = orders.driver_id
            AND drivers.user_id = auth.uid()
        )
    );

-- Les utilisateurs peuvent créer des commandes
CREATE POLICY "orders_insert_users" ON orders
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent annuler leurs commandes en attente
CREATE POLICY "orders_update_cancel_own" ON orders
    FOR UPDATE
    USING (
        auth.uid() = user_id AND
        status IN ('pending', 'confirmed')
    )
    WITH CHECK (
        auth.uid() = user_id AND
        status = 'cancelled'
    );

-- Les prestataires peuvent mettre à jour le statut de leurs commandes
CREATE POLICY "orders_update_provider" ON orders
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM providers
            WHERE providers.id = orders.provider_id
            AND providers.user_id = auth.uid()
        )
    );

-- Les livreurs peuvent mettre à jour le statut de livraison
CREATE POLICY "orders_update_driver" ON orders
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM drivers
            WHERE drivers.id = orders.driver_id
            AND drivers.user_id = auth.uid()
        ) AND status IN ('ready', 'in_delivery')
    );

-- ============================================
-- POLITIQUES POUR LA TABLE ORDER_ITEMS
-- ============================================

-- Les utilisateurs peuvent voir les détails de leurs commandes
CREATE POLICY "order_items_select_own" ON order_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = order_items.order_id
            AND orders.user_id = auth.uid()
        )
    );

-- Les prestataires peuvent voir les détails des commandes
CREATE POLICY "order_items_select_provider" ON order_items
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM orders o
            JOIN providers p ON p.id = o.provider_id
            WHERE o.id = order_items.order_id
            AND p.user_id = auth.uid()
        )
    );

-- ============================================
-- POLITIQUES POUR LA TABLE PAYMENTS
-- ============================================

-- Les utilisateurs peuvent voir leurs propres paiements
CREATE POLICY "payments_select_own" ON payments
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les utilisateurs peuvent créer des paiements
CREATE POLICY "payments_insert_own" ON payments
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR LA TABLE WALLETS
-- ============================================

-- Les utilisateurs peuvent voir leur propre portefeuille
CREATE POLICY "wallets_select_own" ON wallets
    FOR SELECT
    USING (auth.uid() = user_id);

-- Système uniquement pour créer/modifier les portefeuilles (via fonctions)
-- Pas de politique INSERT/UPDATE directe pour les utilisateurs

-- ============================================
-- POLITIQUES POUR LA TABLE WALLET_TRANSACTIONS
-- ============================================

-- Les utilisateurs peuvent voir leurs transactions
CREATE POLICY "wallet_transactions_select_own" ON wallet_transactions
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM wallets
            WHERE wallets.id = wallet_transactions.wallet_id
            AND wallets.user_id = auth.uid()
        )
    );

-- ============================================
-- POLITIQUES POUR LA TABLE NOTIFICATIONS
-- ============================================

-- Les utilisateurs peuvent voir leurs notifications
CREATE POLICY "notifications_select_own" ON notifications
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les utilisateurs peuvent marquer leurs notifications comme lues
CREATE POLICY "notifications_update_own" ON notifications
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id AND is_read = true);

-- ============================================
-- POLITIQUES POUR LA TABLE SUPPORT_TICKETS
-- ============================================

-- Les utilisateurs peuvent voir leurs propres tickets
CREATE POLICY "support_tickets_select_own" ON support_tickets
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les utilisateurs peuvent créer des tickets
CREATE POLICY "support_tickets_insert_own" ON support_tickets
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Les agents de support peuvent voir tous les tickets
CREATE POLICY "support_tickets_select_support" ON support_tickets
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.role IN ('admin', 'super_admin')
        )
    );

-- ============================================
-- POLITIQUES POUR LA TABLE REVIEWS
-- ============================================

-- Tout le monde peut voir les avis vérifiés
CREATE POLICY "reviews_select_verified" ON provider_reviews
    FOR SELECT
    USING (is_verified = true);

-- Les utilisateurs peuvent créer des avis pour leurs commandes
CREATE POLICY "reviews_insert_own_order" ON provider_reviews
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM orders
            WHERE orders.id = provider_reviews.order_id
            AND orders.user_id = auth.uid()
            AND orders.status = 'delivered'
        )
    );

-- Les utilisateurs peuvent modifier leurs propres avis récents
CREATE POLICY "reviews_update_own_recent" ON provider_reviews
    FOR UPDATE
    USING (
        auth.uid() = user_id AND
        created_at > NOW() - INTERVAL '24 hours'
    )
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR LA TABLE DRIVERS
-- ============================================

-- Tout le monde peut voir les livreurs actifs et vérifiés
CREATE POLICY "drivers_select_active" ON drivers
    FOR SELECT
    USING (is_active = true AND is_verified = true);

-- Les livreurs peuvent voir leur propre profil complet
CREATE POLICY "drivers_select_own" ON drivers
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les livreurs peuvent modifier leur propre profil
CREATE POLICY "drivers_update_own" ON drivers
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- POLITIQUES POUR LA TABLE USER_BLOCKS
-- ============================================

-- Les utilisateurs peuvent voir leurs propres blocages
CREATE POLICY "user_blocks_select_own" ON user_blocks
    FOR SELECT
    USING (auth.uid() = user_id);

-- Les utilisateurs peuvent créer des blocages
CREATE POLICY "user_blocks_insert_own" ON user_blocks
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Les utilisateurs peuvent supprimer leurs blocages
CREATE POLICY "user_blocks_delete_own" ON user_blocks
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- FONCTIONS HELPER POUR LES EDGE FUNCTIONS
-- ============================================

-- Fonction pour vérifier si un utilisateur est admin
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM users
        WHERE id = user_id
        AND role IN ('admin', 'super_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour vérifier si un utilisateur est prestataire
CREATE OR REPLACE FUNCTION is_provider(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM providers
        WHERE user_id = user_id
        AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour vérifier si un utilisateur est livreur
CREATE OR REPLACE FUNCTION is_driver(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM drivers
        WHERE user_id = user_id
        AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- GRANT PERMISSIONS FOR AUTHENTICATED USERS
-- ============================================

-- Donner les permissions aux utilisateurs authentifiés
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO authenticated;