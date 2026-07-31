-- Supabase Migration: 20260731000000_seed_supervisor_squad_report_data.sql
-- Description: Adds CRM tagging status, rep product licenses, and seeds test data for Monday 27th July 2026 operational report.

-- 1. Add crm_tagged column to orders table if not exists
ALTER TABLE orders ADD COLUMN IF NOT EXISTS crm_tagged BOOLEAN DEFAULT TRUE;

-- 2. Add assigned_products array column to user_roles table for product licensing
ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS assigned_products TEXT[] DEFAULT ARRAY['GRAZER HERBAL DETOX TEA', 'HERBAL SHAMPOO & VITALITY BOOSTER', 'CLEAR SKIN CARE SET'];

-- 3. Seed/Update user roles with licensed products
UPDATE user_roles 
SET assigned_products = ARRAY['GRAZER HERBAL DETOX TEA', 'HERBAL SHAMPOO & VITALITY BOOSTER']
WHERE role = 'sales_call_rep';

-- 4. Create function to seed July 27th 2026 Operational Report Data
CREATE OR REPLACE FUNCTION seed_july_27_supervisor_report_data()
RETURNS VOID AS $$
DECLARE
    v_company_id UUID;
    v_rep1_id UUID;
    v_rep2_id UUID;
    v_rep3_id UUID;
    i INT;
BEGIN
    -- Get default company ID or create fallback
    SELECT id INTO v_company_id FROM companies LIMIT 1;
    IF v_company_id IS NULL THEN
        INSERT INTO companies (id, name, slug) VALUES (gen_random_uuid(), 'NovaCare Health Suite', 'novacare') RETURNING id INTO v_company_id;
    END IF;

    -- Get sales reps
    SELECT user_id INTO v_rep1_id FROM user_roles WHERE role = 'sales_call_rep' LIMIT 1;
    SELECT user_id INTO v_rep2_id FROM user_roles WHERE role = 'sales_call_rep' OFFSET 1 LIMIT 1;
    SELECT user_id INTO v_rep3_id FROM user_roles WHERE role = 'sales_call_rep' OFFSET 2 LIMIT 1;

    IF v_rep1_id IS NULL THEN
        v_rep1_id := gen_random_uuid();
    END IF;

    -- Seed 15 Delivered Today (July 27, 2026)
    FOR i IN 1..15 LOOP
        INSERT INTO orders (
            id, order_number, company_id, sales_rep_id, product_id,
            customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
            quantity, base_price, total_amount, status, payment_status, crm_tagged,
            created_at, updated_at
        ) VALUES (
            gen_random_uuid(), 'ORD-20260727-DEL-' || lpad(i::text, 3, '0'), v_company_id, v_rep1_id,
            CASE WHEN i % 2 = 0 THEN 'GRAZER HERBAL DETOX TEA' ELSE 'HERBAL SHAMPOO & VITALITY BOOSTER' END,
            'Delivered Customer ' || i, '080311100' || lpad(i::text, 2, '0'), 'Lagos', 'Ikeja', 'Lagos, Nigeria',
            1, 25000.0, 25000.0, 'delivered', 'paid', CASE WHEN i <= 9 THEN TRUE ELSE FALSE END,
            TIMESTAMPTZ '2026-07-27 09:30:00+00', TIMESTAMPTZ '2026-07-27 14:00:00+00'
        ) ON CONFLICT (order_number) DO NOTHING;
    END FOR;

    -- Seed 2 Delivered from Previous Days (July 25 & 26, 2026)
    INSERT INTO orders (
        id, order_number, company_id, sales_rep_id, product_id,
        customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
        quantity, base_price, total_amount, status, payment_status, crm_tagged,
        created_at, updated_at
    ) VALUES 
    (
        gen_random_uuid(), 'ORD-20260725-PREV-001', v_company_id, v_rep1_id, 'GRAZER HERBAL DETOX TEA',
        'Previous Day Customer A', '0803222001', 'Lagos', 'Victoria Island', 'Lagos, Nigeria',
        1, 30000.0, 30000.0, 'delivered', 'paid', TRUE,
        TIMESTAMPTZ '2026-07-25 14:00:00+00', TIMESTAMPTZ '2026-07-27 10:00:00+00'
    ),
    (
        gen_random_uuid(), 'ORD-20260726-PREV-002', v_company_id, v_rep1_id, 'HERBAL SHAMPOO & VITALITY BOOSTER',
        'Previous Day Customer B', '0803222002', 'Lagos', 'Lekki', 'Lagos, Nigeria',
        1, 28000.0, 28000.0, 'delivered', 'paid', TRUE,
        TIMESTAMPTZ '2026-07-26 11:30:00+00', TIMESTAMPTZ '2026-07-27 11:00:00+00'
    ) ON CONFLICT (order_number) DO NOTHING;

    -- Seed 6 Confirmed Orders Sitting in Accepted
    FOR i IN 1..6 LOOP
        INSERT INTO orders (
            id, order_number, company_id, sales_rep_id, product_id,
            customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
            quantity, base_price, total_amount, status, payment_status, crm_tagged,
            created_at, updated_at
        ) VALUES (
            gen_random_uuid(), 'ORD-20260727-CONF-' || lpad(i::text, 3, '0'), v_company_id, v_rep1_id,
            'GRAZER HERBAL DETOX TEA', 'Confirmed Customer ' || i, '080333300' || i, 'Lagos', 'Yaba', 'Lagos',
            1, 25000.0, 25000.0, 'accepted', 'pending', TRUE,
            TIMESTAMPTZ '2026-07-27 10:00:00+00', TIMESTAMPTZ '2026-07-27 12:00:00+00'
        ) ON CONFLICT (order_number) DO NOTHING;
    END FOR;

    -- Seed 7 Rescheduled Callbacks
    FOR i IN 1..7 LOOP
        INSERT INTO orders (
            id, order_number, company_id, sales_rep_id, product_id,
            customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
            quantity, base_price, total_amount, status, payment_status, crm_tagged,
            created_at, updated_at
        ) VALUES (
            gen_random_uuid(), 'ORD-20260727-RESCHED-' || lpad(i::text, 3, '0'), v_company_id, v_rep1_id,
            'HERBAL SHAMPOO & VITALITY BOOSTER', 'Rescheduled Customer ' || i, '080344400' || i, 'Abuja', 'Maitama', 'FCT Abuja',
            1, 20000.0, 20000.0, 'call_back', 'pending', TRUE,
            TIMESTAMPTZ '2026-07-27 09:00:00+00', TIMESTAMPTZ '2026-07-27 13:00:00+00'
        ) ON CONFLICT (order_number) DO NOTHING;
    END FOR;

    -- Seed 2 Switched Off Callbacks
    FOR i IN 1..2 LOOP
        INSERT INTO orders (
            id, order_number, company_id, sales_rep_id, product_id,
            customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
            quantity, base_price, total_amount, status, payment_status, crm_tagged,
            created_at, updated_at
        ) VALUES (
            gen_random_uuid(), 'ORD-20260727-OFF-' || lpad(i::text, 3, '0'), v_company_id, v_rep1_id,
            'GRAZER HERBAL DETOX TEA', 'Switched Off Customer ' || i, '080355500' || i, 'Port Harcourt', 'GRA', 'Rivers State',
            1, 25000.0, 25000.0, 'call_back', 'pending', TRUE,
            TIMESTAMPTZ '2026-07-27 09:15:00+00', TIMESTAMPTZ '2026-07-27 13:30:00+00'
        ) ON CONFLICT (order_number) DO NOTHING;
    END FOR;

    -- Seed 4 Not Picking
    FOR i IN 1..4 LOOP
        INSERT INTO orders (
            id, order_number, company_id, sales_rep_id, product_id,
            customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
            quantity, base_price, total_amount, status, payment_status, crm_tagged,
            created_at, updated_at
        ) VALUES (
            gen_random_uuid(), 'ORD-20260727-NOPICK-' || lpad(i::text, 3, '0'), v_company_id, v_rep1_id,
            'HERBAL SHAMPOO & VITALITY BOOSTER', 'Not Picking Customer ' || i, '080366600' || i, 'Kano', 'Nassarawa', 'Kano State',
            1, 22000.0, 22000.0, 'not_picking', 'pending', TRUE,
            TIMESTAMPTZ '2026-07-27 09:45:00+00', TIMESTAMPTZ '2026-07-27 14:15:00+00'
        ) ON CONFLICT (order_number) DO NOTHING;
    END FOR;

    -- Seed 1 Not Ready
    INSERT INTO orders (
        id, order_number, company_id, sales_rep_id, product_id,
        customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
        quantity, base_price, total_amount, status, payment_status, crm_tagged,
        created_at, updated_at
    ) VALUES (
        gen_random_uuid(), 'ORD-20260727-NOTREADY-001', v_company_id, v_rep1_id,
        'GRAZER HERBAL DETOX TEA', 'Not Ready Customer', '0803777001', 'Oyo', 'Ibadan', 'Oyo State',
        1, 25000.0, 25000.0, 'new', 'pending', TRUE,
        TIMESTAMPTZ '2026-07-27 10:30:00+00', TIMESTAMPTZ '2026-07-27 10:30:00+00'
    ) ON CONFLICT (order_number) DO NOTHING;

END;
$$ LANGUAGE plpgsql;

-- Execute the seeder function
SELECT seed_july_27_supervisor_report_data();
