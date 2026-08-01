-- Supabase Migration: 20260731000002_seed_novacare_historical_trends.sql
-- Description: Seeds NovaCare CRM company, Products, Users (Supervisor + 5 Call Reps), and 250 orders (50 PER sales rep) spanning May, June, and July 2026 for trend analysis.

-- 0. Update process_order_delivered_commissions trigger function to ensure no text = uuid comparison error
CREATE OR REPLACE FUNCTION process_order_delivered_commissions()
RETURNS TRIGGER AS $BODY$
DECLARE
    v_rep_commission_rate NUMERIC(10, 2);
    v_supervisor_commission_rate NUMERIC(10, 2);
    v_supervisor_id UUID;
    v_rep_id UUID;
    v_company_id UUID;
    v_qty INT;
BEGIN
    -- Only trigger when order status transitions to 'delivered'
    IF NEW.status = 'delivered' AND (OLD.status IS NULL OR OLD.status != 'delivered') THEN
        v_rep_id := NEW.sales_rep_id;
        v_company_id := NEW.company_id;
        v_qty := COALESCE(NEW.quantity, 1);

        -- Fetch product commission settings (clean UUID comparison)
        SELECT rep_commission_per_unit, supervisor_commission_per_unit 
        INTO v_rep_commission_rate, v_supervisor_commission_rate
        FROM products 
        WHERE id = NEW.product_id
        LIMIT 1;

        -- Defaults if product rates not explicitly set
        v_rep_commission_rate := COALESCE(v_rep_commission_rate, 1000.00);
        v_supervisor_commission_rate := COALESCE(v_supervisor_commission_rate, 250.00);

        -- Fetch supervisor_id for the sales rep
        IF v_rep_id IS NOT NULL THEN
            SELECT supervisor_id INTO v_supervisor_id
            FROM user_roles
            WHERE user_id = v_rep_id AND company_id = v_company_id
            LIMIT 1;
        END IF;

        -- 1. Insert Sales Rep Commission Record
        IF v_rep_id IS NOT NULL THEN
            INSERT INTO commissions (
                company_id, user_id, supervisor_id, order_id, recipient_role,
                product_id, quantity, unit_commission_rate, total_commission, status
            ) VALUES (
                v_company_id, v_rep_id, v_supervisor_id, NEW.id, 'sales_call_rep',
                NEW.product_id::text, v_qty, v_rep_commission_rate, (v_qty * v_rep_commission_rate), 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
                quantity = EXCLUDED.quantity,
                total_commission = EXCLUDED.total_commission,
                updated_at = NOW();
        END IF;

        -- 2. Insert Supervisor Cumulative Override Commission Record
        IF v_supervisor_id IS NOT NULL THEN
            INSERT INTO commissions (
                company_id, user_id, supervisor_id, order_id, recipient_role,
                product_id, quantity, unit_commission_rate, total_commission, status
            ) VALUES (
                v_company_id, v_supervisor_id, v_supervisor_id, NEW.id, 'sales_supervisor',
                NEW.product_id::text, v_qty, v_supervisor_commission_rate, (v_qty * v_supervisor_commission_rate), 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
                quantity = EXCLUDED.quantity,
                total_commission = EXCLUDED.total_commission,
                updated_at = NOW();
        END IF;

    END IF;
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;

-- 1. Ensure NovaCare Company Exists
INSERT INTO public.companies (id, name, type, is_active)
VALUES ('11111111-1111-4111-8111-111111111111', 'NovaCare CRM', 'marketing', true)
ON CONFLICT (id) DO UPDATE SET name = 'NovaCare CRM';

-- 2. Ensure Whitelabel Tenant Settings
INSERT INTO public.tenant_settings (company_id, app_title, primary_color, secondary_color, accent_color, currency_code, currency_symbol, sms_sender_id)
VALUES ('11111111-1111-4111-8111-111111111111', 'NovaCare CRM', '#10B981', '#F59E0B', '#6366F1', 'NGN', '₦', 'NOVACARE')
ON CONFLICT (company_id) DO NOTHING;

-- 3. Ensure Products Exist with Valid UUIDs
INSERT INTO public.products (id, company_id, name, sku, description, base_price, is_active) VALUES
('90000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Grazer Herbal Detox Tea', 'SKU-DETOX-01', '100% Organic Herbal Detox & Cleanser', 25000.00, true),
('90000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'Herbal Vitality Booster', 'SKU-BOOST-02', 'Immune System & Energy Enhancement Formula', 35000.00, true),
('90000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'Clear Skin Care Set', 'SKU-SKIN-03', 'Advanced Clear Skin Care Treatment', 18500.00, true)
ON CONFLICT (id) DO NOTHING;

-- 4. Ensure Users & Roles Exist
INSERT INTO public.users (id, company_id, role, first_name, last_name, email, phone, is_active)
VALUES 
('20000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'supervisor', 'Samuel', 'Supervisor', 'supervisor@novacare.com', '+2348032223344', true),
('30000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'sales_call_rep', 'John', 'CallRep', 'salesrep.john@novacare.com', '+2348033334455', true),
('40000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'sales_call_rep', 'Sarah', 'CallRep', 'salesrep.sarah@novacare.com', '+2348034445566', true),
('50000000-0000-4000-8000-000000000006', '11111111-1111-4111-8111-111111111111', 'sales_call_rep', 'Emeka', 'CallRep', 'salesrep.emeka@novacare.com', '+2348035556677', true),
('50000000-0000-4000-8000-000000000007', '11111111-1111-4111-8111-111111111111', 'sales_call_rep', 'Aisha', 'SalesRep', 'salesrep.aisha@novacare.com', '+2348036667788', true),
('50000000-0000-4000-8000-000000000008', '11111111-1111-4111-8111-111111111111', 'sales_call_rep', 'Chidi', 'Rep', 'salesrep.chidi@novacare.com', '+2348037778899', true)
ON CONFLICT (id) DO UPDATE SET is_active = true;

-- 5. Seed 50 Orders for John CallRep ('30000000-0000-4000-8000-000000000003')
INSERT INTO public.orders (
    id, order_number, company_id, sales_rep_id, product_id,
    customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
    quantity, base_price, total_amount, status, payment_status, crm_tagged,
    created_at, updated_at
)
SELECT 
    gen_random_uuid(),
    'ORD-JOHN-' || lpad(i::text, 4, '0'),
    '11111111-1111-4111-8111-111111111111',
    '30000000-0000-4000-8000-000000000003'::uuid,
    CASE (i % 3) WHEN 0 THEN '90000000-0000-4000-8000-000000000001'::uuid WHEN 1 THEN '90000000-0000-4000-8000-000000000002'::uuid ELSE '90000000-0000-4000-8000-000000000003'::uuid END,
    'Customer John ' || i::text,
    '08033334' || lpad(i::text, 3, '0'),
    'Lagos', 'Ikeja', '14 Allen Avenue, Ikeja, Lagos, Nigeria',
    1, 25000.00, 25000.00,
    CASE (i % 5) WHEN 0 THEN 'delivered' WHEN 1 THEN 'accepted' WHEN 2 THEN 'in_transit' WHEN 3 THEN 'contacting' ELSE 'cancelled' END,
    CASE WHEN (i % 5) = 0 THEN 'collected' ELSE 'pending' END,
    TRUE,
    TIMESTAMPTZ '2026-05-01 08:00:00+00' + (i || ' days')::INTERVAL,
    TIMESTAMPTZ '2026-05-01 10:00:00+00' + (i || ' days')::INTERVAL
FROM generate_series(1, 50) AS i
ON CONFLICT (order_number) DO NOTHING;

-- 6. Seed 50 Orders for Sarah CallRep ('40000000-0000-4000-8000-000000000004')
INSERT INTO public.orders (
    id, order_number, company_id, sales_rep_id, product_id,
    customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
    quantity, base_price, total_amount, status, payment_status, crm_tagged,
    created_at, updated_at
)
SELECT 
    gen_random_uuid(),
    'ORD-SARAH-' || lpad(i::text, 4, '0'),
    '11111111-1111-4111-8111-111111111111',
    '40000000-0000-4000-8000-000000000004'::uuid,
    CASE (i % 3) WHEN 0 THEN '90000000-0000-4000-8000-000000000002'::uuid WHEN 1 THEN '90000000-0000-4000-8000-000000000003'::uuid ELSE '90000000-0000-4000-8000-000000000001'::uuid END,
    'Customer Sarah ' || i::text,
    '08034445' || lpad(i::text, 3, '0'),
    'Abuja', 'Maitama', 'Plot 12 Maitama Expressway, Abuja, Nigeria',
    1, 35000.00, 35000.00,
    CASE (i % 5) WHEN 0 THEN 'delivered' WHEN 1 THEN 'accepted' WHEN 2 THEN 'in_transit' WHEN 3 THEN 'call_back' ELSE 'cancelled' END,
    CASE WHEN (i % 5) = 0 THEN 'collected' ELSE 'pending' END,
    TRUE,
    TIMESTAMPTZ '2026-05-01 08:00:00+00' + (i || ' days')::INTERVAL,
    TIMESTAMPTZ '2026-05-01 10:00:00+00' + (i || ' days')::INTERVAL
FROM generate_series(1, 50) AS i
ON CONFLICT (order_number) DO NOTHING;

-- 7. Seed 50 Orders for Emeka CallRep ('50000000-0000-4000-8000-000000000006')
INSERT INTO public.orders (
    id, order_number, company_id, sales_rep_id, product_id,
    customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
    quantity, base_price, total_amount, status, payment_status, crm_tagged,
    created_at, updated_at
)
SELECT 
    gen_random_uuid(),
    'ORD-EMEKA-' || lpad(i::text, 4, '0'),
    '11111111-1111-4111-8111-111111111111',
    '50000000-0000-4000-8000-000000000006'::uuid,
    CASE (i % 3) WHEN 0 THEN '90000000-0000-4000-8000-000000000003'::uuid WHEN 1 THEN '90000000-0000-4000-8000-000000000001'::uuid ELSE '90000000-0000-4000-8000-000000000002'::uuid END,
    'Customer Emeka ' || i::text,
    '08035556' || lpad(i::text, 3, '0'),
    'Rivers', 'Port Harcourt', '5 Aba Road, Port Harcourt, Nigeria',
    1, 18500.00, 18500.00,
    CASE (i % 5) WHEN 0 THEN 'delivered' WHEN 1 THEN 'accepted' WHEN 2 THEN 'upsell_pending' WHEN 3 THEN 'contacting' ELSE 'cancelled' END,
    CASE WHEN (i % 5) = 0 THEN 'collected' ELSE 'pending' END,
    TRUE,
    TIMESTAMPTZ '2026-05-01 08:00:00+00' + (i || ' days')::INTERVAL,
    TIMESTAMPTZ '2026-05-01 10:00:00+00' + (i || ' days')::INTERVAL
FROM generate_series(1, 50) AS i
ON CONFLICT (order_number) DO NOTHING;

-- 8. Seed 50 Orders for Aisha SalesRep ('50000000-0000-4000-8000-000000000007')
INSERT INTO public.orders (
    id, order_number, company_id, sales_rep_id, product_id,
    customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
    quantity, base_price, total_amount, status, payment_status, crm_tagged,
    created_at, updated_at
)
SELECT 
    gen_random_uuid(),
    'ORD-AISHA-' || lpad(i::text, 4, '0'),
    '11111111-1111-4111-8111-111111111111',
    '50000000-0000-4000-8000-000000000007'::uuid,
    CASE (i % 3) WHEN 0 THEN '90000000-0000-4000-8000-000000000001'::uuid WHEN 1 THEN '90000000-0000-4000-8000-000000000002'::uuid ELSE '90000000-0000-4000-8000-000000000003'::uuid END,
    'Customer Aisha ' || i::text,
    '08036667' || lpad(i::text, 3, '0'),
    'Oyo', 'Ibadan', 'Ring Road, Ibadan, Nigeria',
    1, 25000.00, 25000.00,
    CASE (i % 5) WHEN 0 THEN 'delivered' WHEN 1 THEN 'accepted' WHEN 2 THEN 'in_transit' WHEN 3 THEN 'contacting' ELSE 'cancelled' END,
    CASE WHEN (i % 5) = 0 THEN 'collected' ELSE 'pending' END,
    TRUE,
    TIMESTAMPTZ '2026-05-01 08:00:00+00' + (i || ' days')::INTERVAL,
    TIMESTAMPTZ '2026-05-01 10:00:00+00' + (i || ' days')::INTERVAL
FROM generate_series(1, 50) AS i
ON CONFLICT (order_number) DO NOTHING;

-- 9. Seed 50 Orders for Chidi Rep ('50000000-0000-4000-8000-000000000008')
INSERT INTO public.orders (
    id, order_number, company_id, sales_rep_id, product_id,
    customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
    quantity, base_price, total_amount, status, payment_status, crm_tagged,
    created_at, updated_at
)
SELECT 
    gen_random_uuid(),
    'ORD-CHIDI-' || lpad(i::text, 4, '0'),
    '11111111-1111-4111-8111-111111111111',
    '50000000-0000-4000-8000-000000000008'::uuid,
    CASE (i % 3) WHEN 0 THEN '90000000-0000-4000-8000-000000000002'::uuid WHEN 1 THEN '90000000-0000-4000-8000-000000000003'::uuid ELSE '90000000-0000-4000-8000-000000000001'::uuid END,
    'Customer Chidi ' || i::text,
    '08037778' || lpad(i::text, 3, '0'),
    'Kano', 'Kano Central', 'Zaria Road, Kano, Nigeria',
    1, 35000.00, 35000.00,
    CASE (i % 5) WHEN 0 THEN 'delivered' WHEN 1 THEN 'accepted' WHEN 2 THEN 'in_transit' WHEN 3 THEN 'contacting' ELSE 'cancelled' END,
    CASE WHEN (i % 5) = 0 THEN 'collected' ELSE 'pending' END,
    TRUE,
    TIMESTAMPTZ '2026-05-01 08:00:00+00' + (i || ' days')::INTERVAL,
    TIMESTAMPTZ '2026-05-01 10:00:00+00' + (i || ' days')::INTERVAL
FROM generate_series(1, 50) AS i
ON CONFLICT (order_number) DO NOTHING;
