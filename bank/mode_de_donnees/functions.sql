-- ============================================
-- FONCTIONS ET TRIGGERS SUPABASE
-- ============================================

-- ============================================
-- FONCTIONS UTILITAIRES
-- ============================================

-- Fonction pour générer un numéro de commande unique
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TEXT AS $$
DECLARE
    v_date TEXT;
    v_random TEXT;
    v_order_number TEXT;
BEGIN
    v_date := TO_CHAR(NOW(), 'YYMMDD');
    v_random := LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
    v_order_number := 'ORD-' || v_date || '-' || v_random;

    -- Vérifier l'unicité
    WHILE EXISTS(SELECT 1 FROM orders WHERE order_number = v_order_number) LOOP
        v_random := LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
        v_order_number := 'ORD-' || v_date || '-' || v_random;
    END LOOP;

    RETURN v_order_number;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer un code de confirmation (2 lettres majuscules)
CREATE OR REPLACE FUNCTION generate_confirmation_code()
RETURNS TEXT AS $$
DECLARE
    v_code TEXT;
    v_chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
BEGIN
    v_code := SUBSTR(v_chars, FLOOR(RANDOM() * 26)::INT + 1, 1) ||
              SUBSTR(v_chars, FLOOR(RANDOM() * 26)::INT + 1, 1);

    -- Vérifier l'unicité pour les commandes récentes (dernières 24h)
    WHILE EXISTS(
        SELECT 1 FROM orders
        WHERE confirmation_code = v_code
        AND created_at > NOW() - INTERVAL '24 hours'
        AND status NOT IN ('delivered', 'cancelled')
    ) LOOP
        v_code := SUBSTR(v_chars, FLOOR(RANDOM() * 26)::INT + 1, 1) ||
                  SUBSTR(v_chars, FLOOR(RANDOM() * 26)::INT + 1, 1);
    END LOOP;

    RETURN v_code;
END;
$$ LANGUAGE plpgsql;

-- Fonction pour générer un numéro de ticket
CREATE OR REPLACE FUNCTION generate_ticket_number()
RETURNS TEXT AS $$
DECLARE
    v_ticket_number TEXT;
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) + 1 INTO v_count FROM support_tickets;
    v_ticket_number := 'TKT-' || LPAD(v_count::TEXT, 6, '0');

    WHILE EXISTS(SELECT 1 FROM support_tickets WHERE ticket_number = v_ticket_number) LOOP
        v_count := v_count + 1;
        v_ticket_number := 'TKT-' || LPAD(v_count::TEXT, 6, '0');
    END LOOP;

    RETURN v_ticket_number;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FONCTIONS DE CALCUL
-- ============================================

-- Calculer la distance entre deux points (en km)
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 FLOAT,
    lon1 FLOAT,
    lat2 FLOAT,
    lon2 FLOAT
) RETURNS FLOAT AS $$
BEGIN
    RETURN ST_DistanceSphere(
        ST_MakePoint(lon1, lat1)::geography,
        ST_MakePoint(lon2, lat2)::geography
    ) / 1000; -- Convertir en km
END;
$$ LANGUAGE plpgsql;

-- Calculer les frais de livraison basés sur la distance
CREATE OR REPLACE FUNCTION calculate_delivery_fee(
    p_distance FLOAT,
    p_vehicle_type vehicle_type DEFAULT 'moto'
) RETURNS DECIMAL AS $$
DECLARE
    v_base_fee DECIMAL := 500; -- Frais de base en FCFA
    v_per_km_fee DECIMAL;
    v_total_fee DECIMAL;
BEGIN
    -- Tarifs par km selon le type de véhicule
    CASE p_vehicle_type
        WHEN 'pieton' THEN v_per_km_fee := 300;
        WHEN 'velo' THEN v_per_km_fee := 350;
        WHEN 'moto' THEN v_per_km_fee := 400;
        WHEN 'tricycle' THEN v_per_km_fee := 500;
        WHEN 'voiture' THEN v_per_km_fee := 600;
        WHEN 'camion' THEN v_per_km_fee := 800;
        ELSE v_per_km_fee := 400;
    END CASE;

    v_total_fee := v_base_fee + (p_distance * v_per_km_fee);

    -- Arrondir au 100 FCFA le plus proche
    RETURN ROUND(v_total_fee / 100) * 100;
END;
$$ LANGUAGE plpgsql;

-- Calculer les points de fidélité pour une commande
CREATE OR REPLACE FUNCTION calculate_loyalty_points(
    p_amount DECIMAL,
    p_points_per_amount DECIMAL DEFAULT 100.00
) RETURNS INTEGER AS $$
BEGIN
    RETURN FLOOR(p_amount / p_points_per_amount);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FONCTIONS DE MISE À JOUR
-- ============================================

-- Mettre à jour le timestamp updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Mettre à jour les statistiques du prestataire
CREATE OR REPLACE FUNCTION update_provider_stats()
RETURNS TRIGGER AS $$
DECLARE
    v_rating DECIMAL;
    v_count INTEGER;
BEGIN
    SELECT
        AVG(rating),
        COUNT(*)
    INTO v_rating, v_count
    FROM provider_reviews
    WHERE provider_id = NEW.provider_id;

    UPDATE providers
    SET
        rating = COALESCE(v_rating, 0),
        total_reviews = v_count,
        updated_at = NOW()
    WHERE id = NEW.provider_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Mettre à jour les statistiques du livreur
CREATE OR REPLACE FUNCTION update_driver_stats()
RETURNS TRIGGER AS $$
DECLARE
    v_rating DECIMAL;
    v_deliveries INTEGER;
    v_success_rate DECIMAL;
BEGIN
    SELECT
        AVG(rating)
    INTO v_rating
    FROM driver_reviews
    WHERE driver_id = NEW.driver_id;

    SELECT
        COUNT(*),
        (COUNT(CASE WHEN status = 'delivered' THEN 1 END)::DECIMAL /
         NULLIF(COUNT(*), 0)) * 100
    INTO v_deliveries, v_success_rate
    FROM orders
    WHERE driver_id = NEW.driver_id;

    UPDATE drivers
    SET
        rating = COALESCE(v_rating, 0),
        total_deliveries = v_deliveries,
        success_rate = COALESCE(v_success_rate, 0),
        updated_at = NOW()
    WHERE id = NEW.driver_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FONCTIONS DE SOFT DELETE
-- ============================================

-- Fonction générique pour soft delete
CREATE OR REPLACE FUNCTION soft_delete(
    p_table_name TEXT,
    p_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
    EXECUTE format('
        UPDATE %I
        SET deleted_at = NOW()
        WHERE id = $1 AND deleted_at IS NULL',
        p_table_name
    ) USING p_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Fonction de suppression définitive (super_admin uniquement)
CREATE OR REPLACE FUNCTION hard_delete(
    p_table_name TEXT,
    p_id UUID,
    p_user_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
    v_is_super_admin BOOLEAN;
BEGIN
    -- Vérifier si l'utilisateur est super_admin
    SELECT role = 'super_admin'
    INTO v_is_super_admin
    FROM users
    WHERE id = p_user_id;

    IF NOT v_is_super_admin THEN
        RAISE EXCEPTION 'Seul le super_admin peut effectuer une suppression définitive';
    END IF;

    EXECUTE format('
        DELETE FROM %I
        WHERE id = $1',
        p_table_name
    ) USING p_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fonction pour restaurer un enregistrement soft-deleted
CREATE OR REPLACE FUNCTION restore_deleted(
    p_table_name TEXT,
    p_id UUID
) RETURNS BOOLEAN AS $$
BEGIN
    EXECUTE format('
        UPDATE %I
        SET deleted_at = NULL
        WHERE id = $1 AND deleted_at IS NOT NULL',
        p_table_name
    ) USING p_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FONCTIONS DE GESTION DES UTILISATEURS
-- ============================================

-- Vérifier et gérer les suspensions pour annulations excessives
CREATE OR REPLACE FUNCTION check_cancellation_limit()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        UPDATE users
        SET
            cancellation_count = cancellation_count + 1
        WHERE id = NEW.user_id;

        -- Vérifier si l'utilisateur dépasse la limite
        UPDATE users
        SET
            is_active = false,
            suspension_count = suspension_count + 1,
            suspension_end_date = NOW() + INTERVAL '7 days'
        WHERE id = NEW.user_id
            AND cancellation_count >= max_cancellations;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Réactiver automatiquement les utilisateurs après suspension
CREATE OR REPLACE FUNCTION reactivate_suspended_users()
RETURNS void AS $$
BEGIN
    UPDATE users
    SET
        is_active = true,
        cancellation_count = 0,
        suspension_end_date = NULL
    WHERE suspension_end_date IS NOT NULL
        AND suspension_end_date <= NOW()
        AND is_active = false;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FONCTIONS DE GESTION DU PORTEFEUILLE
-- ============================================

-- Créditer le portefeuille
CREATE OR REPLACE FUNCTION credit_wallet(
    p_user_id UUID,
    p_amount DECIMAL,
    p_type VARCHAR,
    p_reference VARCHAR,
    p_description TEXT
) RETURNS UUID AS $$
DECLARE
    v_wallet_id UUID;
    v_new_balance DECIMAL;
    v_transaction_id UUID;
BEGIN
    -- Obtenir ou créer le portefeuille
    SELECT id, balance INTO v_wallet_id, v_new_balance
    FROM wallets
    WHERE user_id = p_user_id;

    IF v_wallet_id IS NULL THEN
        INSERT INTO wallets (user_id, balance)
        VALUES (p_user_id, 0)
        RETURNING id, balance INTO v_wallet_id, v_new_balance;
    END IF;

    -- Calculer le nouveau solde
    v_new_balance := v_new_balance + p_amount;

    -- Mettre à jour le portefeuille
    UPDATE wallets
    SET
        balance = v_new_balance,
        updated_at = NOW()
    WHERE id = v_wallet_id;

    -- Créer la transaction
    INSERT INTO wallet_transactions (
        wallet_id,
        transaction_type,
        amount,
        balance_after,
        reference,
        description
    ) VALUES (
        v_wallet_id,
        p_type,
        p_amount,
        v_new_balance,
        p_reference,
        p_description
    ) RETURNING id INTO v_transaction_id;

    RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- Débiter le portefeuille
CREATE OR REPLACE FUNCTION debit_wallet(
    p_user_id UUID,
    p_amount DECIMAL,
    p_reference VARCHAR,
    p_description TEXT
) RETURNS UUID AS $$
DECLARE
    v_wallet_id UUID;
    v_current_balance DECIMAL;
    v_new_balance DECIMAL;
    v_transaction_id UUID;
BEGIN
    -- Obtenir le portefeuille
    SELECT id, balance INTO v_wallet_id, v_current_balance
    FROM wallets
    WHERE user_id = p_user_id
        AND is_active = true;

    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION 'Wallet not found for user %', p_user_id;
    END IF;

    IF v_current_balance < p_amount THEN
        RAISE EXCEPTION 'Insufficient balance. Current: %, Required: %',
            v_current_balance, p_amount;
    END IF;

    -- Calculer le nouveau solde
    v_new_balance := v_current_balance - p_amount;

    -- Mettre à jour le portefeuille
    UPDATE wallets
    SET
        balance = v_new_balance,
        updated_at = NOW()
    WHERE id = v_wallet_id;

    -- Créer la transaction
    INSERT INTO wallet_transactions (
        wallet_id,
        transaction_type,
        amount,
        balance_after,
        reference,
        description
    ) VALUES (
        v_wallet_id,
        'debit',
        -p_amount,
        v_new_balance,
        p_reference,
        p_description
    ) RETURNING id INTO v_transaction_id;

    RETURN v_transaction_id;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FONCTIONS DE RECHERCHE
-- ============================================

-- Rechercher les prestataires proches
CREATE OR REPLACE FUNCTION search_nearby_providers(
    p_lat FLOAT,
    p_lon FLOAT,
    p_radius FLOAT DEFAULT 5.0, -- km
    p_service_type service_type DEFAULT NULL,
    p_limit INTEGER DEFAULT 20,
    p_exclude_busy BOOLEAN DEFAULT false -- Option pour exclure les prestataires occupés
) RETURNS TABLE (
    id UUID,
    business_name VARCHAR,
    distance FLOAT,
    rating DECIMAL,
    badge provider_badge,
    is_busy BOOLEAN,
    delivery_fee DECIMAL,
    estimated_time INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.business_name,
        ST_Distance(
            p.coordinates,
            ST_MakePoint(p_lon, p_lat)::geography
        ) / 1000 AS distance,
        p.rating,
        p.badge,
        p.is_busy,
        calculate_delivery_fee(
            ST_Distance(
                p.coordinates,
                ST_MakePoint(p_lon, p_lat)::geography
            ) / 1000,
            'moto'
        ) AS delivery_fee,
        CASE
            WHEN ST_Distance(p.coordinates, ST_MakePoint(p_lon, p_lat)::geography) / 1000 <= 2
                THEN 20
            WHEN ST_Distance(p.coordinates, ST_MakePoint(p_lon, p_lat)::geography) / 1000 <= 5
                THEN 30
            ELSE 45
        END AS estimated_time
    FROM providers p
    JOIN services s ON p.service_id = s.id
    WHERE p.is_active = true
        AND p.is_verified = true
        AND p.deleted_at IS NULL  -- Exclure les prestataires supprimés
        AND s.deleted_at IS NULL  -- Exclure les services supprimés
        AND (NOT p_exclude_busy OR p.is_busy = false)  -- Optionnellement exclure les occupés
        AND (p_service_type IS NULL OR s.type = p_service_type)
        AND ST_DWithin(
            p.coordinates,
            ST_MakePoint(p_lon, p_lat)::geography,
            p_radius * 1000
        )
    ORDER BY
        p.is_busy ASC,  -- Afficher les disponibles en premier
        CASE p.badge  -- Trier par badge
            WHEN 'platinum' THEN 1
            WHEN 'gold' THEN 2
            WHEN 'silver' THEN 3
            WHEN 'bronze' THEN 4
        END,
        distance ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Rechercher les livreurs disponibles
CREATE OR REPLACE FUNCTION find_available_drivers(
    p_lat FLOAT,
    p_lon FLOAT,
    p_vehicle_type vehicle_type DEFAULT NULL,
    p_radius FLOAT DEFAULT 3.0, -- km
    p_limit INTEGER DEFAULT 10
) RETURNS TABLE (
    id UUID,
    user_id UUID,
    vehicle_type vehicle_type,
    distance FLOAT,
    rating DECIMAL,
    total_deliveries INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        d.id,
        d.user_id,
        d.vehicle_type,
        ST_Distance(
            d.current_location,
            ST_MakePoint(p_lon, p_lat)::geography
        ) / 1000 AS distance,
        d.rating,
        d.total_deliveries
    FROM drivers d
    WHERE d.is_active = true
        AND d.is_verified = true
        AND d.is_available = true
        AND d.deleted_at IS NULL  -- Exclure les livreurs supprimés
        AND (p_vehicle_type IS NULL OR d.vehicle_type = p_vehicle_type)
        AND d.current_location IS NOT NULL
        AND ST_DWithin(
            d.current_location,
            ST_MakePoint(p_lon, p_lat)::geography,
            p_radius * 1000
        )
    ORDER BY distance ASC, rating DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Trigger pour updated_at sur toutes les tables principales
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_providers_updated_at BEFORE UPDATE ON providers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_drivers_updated_at BEFORE UPDATE ON drivers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger pour générer automatiquement les numéros
CREATE TRIGGER generate_order_number_trigger BEFORE INSERT ON orders
    FOR EACH ROW
    WHEN (NEW.order_number IS NULL)
    EXECUTE FUNCTION generate_order_number();

CREATE TRIGGER generate_confirmation_code_trigger BEFORE INSERT ON orders
    FOR EACH ROW
    WHEN (NEW.confirmation_code IS NULL)
    EXECUTE FUNCTION generate_confirmation_code();

CREATE TRIGGER generate_ticket_number_trigger BEFORE INSERT ON support_tickets
    FOR EACH ROW
    WHEN (NEW.ticket_number IS NULL)
    EXECUTE FUNCTION generate_ticket_number();

-- Trigger pour mettre à jour les statistiques
CREATE TRIGGER update_provider_stats_trigger AFTER INSERT OR UPDATE ON provider_reviews
    FOR EACH ROW EXECUTE FUNCTION update_provider_stats();

CREATE TRIGGER update_driver_stats_trigger AFTER INSERT OR UPDATE ON driver_reviews
    FOR EACH ROW EXECUTE FUNCTION update_driver_stats();

-- Trigger pour gérer les annulations
CREATE TRIGGER check_cancellation_limit_trigger AFTER UPDATE ON orders
    FOR EACH ROW
    WHEN (NEW.status = 'cancelled' AND OLD.status != 'cancelled')
    EXECUTE FUNCTION check_cancellation_limit();

-- ============================================
-- FONCTIONS DE GESTION DES BADGES
-- ============================================

-- Fonction pour mettre à jour le badge d'un prestataire
CREATE OR REPLACE FUNCTION update_provider_badge(
    p_provider_id UUID
) RETURNS provider_badge AS $$
DECLARE
    v_rating DECIMAL;
    v_total_reviews INTEGER;
    v_total_orders INTEGER;
    v_acceptance_rate DECIMAL;
    v_new_badge provider_badge;
BEGIN
    -- Récupérer les statistiques du prestataire
    SELECT
        rating,
        total_reviews,
        acceptance_rate
    INTO
        v_rating,
        v_total_reviews,
        v_acceptance_rate
    FROM providers
    WHERE id = p_provider_id;

    -- Compter le nombre total de commandes
    SELECT COUNT(*)
    INTO v_total_orders
    FROM orders
    WHERE provider_id = p_provider_id
        AND status = 'delivered'
        AND deleted_at IS NULL;

    -- Déterminer le badge selon les critères
    -- Ces critères peuvent être ajustés ultérieurement
    CASE
        WHEN v_rating >= 4.8 AND v_total_orders >= 1000 AND v_acceptance_rate >= 95 THEN
            v_new_badge := 'platinum';
        WHEN v_rating >= 4.5 AND v_total_orders >= 500 AND v_acceptance_rate >= 90 THEN
            v_new_badge := 'gold';
        WHEN v_rating >= 4.0 AND v_total_orders >= 100 AND v_acceptance_rate >= 85 THEN
            v_new_badge := 'silver';
        ELSE
            v_new_badge := 'bronze';
    END CASE;

    -- Mettre à jour le badge
    UPDATE providers
    SET badge = v_new_badge
    WHERE id = p_provider_id;

    RETURN v_new_badge;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- JOBS CRON (à configurer avec pg_cron)
-- ============================================

-- Job pour réactiver les utilisateurs suspendus (toutes les heures)
SELECT cron.schedule(
    'reactivate-suspended-users',
    '0 * * * *',
    'SELECT reactivate_suspended_users();'
);

-- Job pour nettoyer les vieilles notifications (tous les jours à 2h)
SELECT cron.schedule(
    'clean-old-notifications',
    '0 2 * * *',
    'DELETE FROM notifications WHERE created_at < NOW() - INTERVAL ''30 days'';'
);

-- Job pour expirer les codes promo (tous les jours à minuit)
SELECT cron.schedule(
    'expire-promo-codes',
    '0 0 * * *',
    'UPDATE promo_codes SET is_active = false WHERE valid_until < NOW() AND is_active = true;'
);

-- Job pour mettre à jour les badges des prestataires (tous les jours à 3h)
SELECT cron.schedule(
    'update-provider-badges',
    '0 3 * * *',
    $$
    DO $$
    DECLARE
        v_provider RECORD;
    BEGIN
        FOR v_provider IN
            SELECT id FROM providers
            WHERE deleted_at IS NULL AND is_verified = true
        LOOP
            PERFORM update_provider_badge(v_provider.id);
        END LOOP;
    END $$;
    $$
);