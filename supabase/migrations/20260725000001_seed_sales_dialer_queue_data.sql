-- ============================================================================
-- Migration: 20260725000001_seed_sales_dialer_queue_data.sql
-- Description: Seed sample orders & state-hub mappings for Sales Dialer Queue
-- ============================================================================

-- 1. Ensure Default Seed Company Exists
INSERT INTO public.companies (id, name, type)
VALUES (
    '11111111-1111-4111-8111-111111111111',
    'Nova Care Herbal Products',
    'hybrid'
)
ON CONFLICT (id) DO NOTHING;

-- 2. Seed State-to-Hub Logistics Mappings
INSERT INTO public.state_hub_mappings (company_id, state_name)
VALUES
    ('11111111-1111-4111-8111-111111111111', 'Lagos'),
    ('11111111-1111-4111-8111-111111111111', 'Abuja'),
    ('11111111-1111-4111-8111-111111111111', 'Rivers'),
    ('11111111-1111-4111-8111-111111111111', 'Kano'),
    ('11111111-1111-4111-8111-111111111111', 'Oyo')
ON CONFLICT (company_id, state_name) DO NOTHING;

-- 3. Seed Default Herbal Product
INSERT INTO public.products (id, company_id, name, sku, base_price, description)
VALUES (
    'a1b2c3d4-0000-4000-8000-000000000001',
    '11111111-1111-4111-8111-111111111111',
    'Grazer Herbal Detox Tea',
    'SKU-TEA-001',
    25000.00,
    'Natural organic digestive detox tea blend'
)
ON CONFLICT (id) DO NOTHING;

-- 4. Seed Live Sales Dialer Queue Orders
INSERT INTO public.orders (
    id,
    order_number,
    company_id,
    product_id,
    customer_name,
    customer_phone,
    delivery_state,
    delivery_city,
    delivery_address,
    status,
    quantity,
    base_price,
    upsell_amount,
    downsell_discount,
    total_amount,
    upsell_status,
    payment_status,
    created_at
)
VALUES
    (
        gen_random_uuid(),
        'ORD-2026-8901',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        'Chief Bartholomew Okonkwo',
        '08085040146',
        'Lagos',
        'Ikeja GRA',
        '14 Isaac John Street',
        'new',
        2,
        25000.00,
        0.00,
        0.00,
        50000.00,
        'none',
        'pending',
        NOW() - INTERVAL '10 minutes'
    ),
    (
        gen_random_uuid(),
        'ORD-2026-8902',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        'Dr. Folake Adeleke',
        '08165119466',
        'Abuja',
        'Maitama',
        'Aso Drive Plot 402',
        'contacting',
        1,
        25000.00,
        0.00,
        0.00,
        25000.00,
        'none',
        'pending',
        NOW() - INTERVAL '25 minutes'
    ),
    (
        gen_random_uuid(),
        'ORD-2026-8903',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        'Alhaji Ibrahim Danladi',
        '08085040146',
        'Kano',
        'Nassarawa GRA',
        '7 Lamido Road',
        'new',
        1,
        22000.00,
        0.00,
        0.00,
        22000.00,
        'none',
        'pending',
        NOW() - INTERVAL '40 minutes'
    ),
    (
        gen_random_uuid(),
        'ORD-2026-8904',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        'Engineer Chidi Nnamdi',
        '08165119466',
        'Rivers',
        'Port Harcourt',
        '88 Aba Road, Garrison',
        'new',
        1,
        25000.00,
        0.00,
        0.00,
        25000.00,
        'none',
        'pending',
        NOW() - INTERVAL '1 hour'
    ),
    (
        gen_random_uuid(),
        'ORD-2026-8905',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        'Mrs. Blessing Enoh',
        '08085040146',
        'Oyo',
        'Ibadan',
        'Bodija Estate, Ring Road',
        'contacting',
        3,
        20000.00,
        0.00,
        0.00,
        60000.00,
        'none',
        'pending',
        NOW() - INTERVAL '2 hours'
    ),
    (
        gen_random_uuid(),
        'ORD-2026-8906',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        'Captain Tunde Bakare',
        '08165119466',
        'Lagos',
        'Lekki Phase 1',
        'Admiralty Way, Suite 12B',
        'new',
        1,
        25000.00,
        0.00,
        0.00,
        25000.00,
        'none',
        'pending',
        NOW() - INTERVAL '3 hours'
    )
ON CONFLICT DO NOTHING;
