-- Migration: 20260730000002_seed_hierarchical_sales_orders.sql
-- Description: Seed orders and activities assigned specifically to Rep, Supervisor, AHOD, and HOD accounts

-- 1. Ensure Sales Call Reps exist in user_roles
INSERT INTO public.user_roles (user_id, role, can_take_calls, is_active_call_rep)
SELECT id, 'sales_call_rep', true, true FROM auth.users WHERE email = 'salesrep.john@novacare.com'
ON CONFLICT (id) DO NOTHING;

-- 2. Seed Orders for Sales Call Rep (John)
INSERT INTO public.orders (
    id,
    order_number,
    company_id,
    product_id,
    sales_rep_id,
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
    scheduled_callback_at,
    created_at,
    updated_at
)
VALUES
    -- Carry-Over Call (Left since yesterday)
    (
        gen_random_uuid(),
        'ORD-2026-9001',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        (SELECT id FROM auth.users WHERE email = 'salesrep.john@novacare.com' LIMIT 1),
        'Alhaji Aminu Kano',
        '08031234567',
        'Kano',
        'Nassarawa GRA',
        'Plot 12 Ahmadu Bello Way',
        'new',
        2,
        25000.00,
        0.00,
        0.00,
        50000.00,
        'none',
        'pending',
        NULL,
        NOW() - INTERVAL '1 day 4 hours',
        NOW() - INTERVAL '1 day 4 hours'
    ),
    -- Carry-Over Call 2 (Yesterday's Uncalled Lead)
    (
        gen_random_uuid(),
        'ORD-2026-9002',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        (SELECT id FROM auth.users WHERE email = 'salesrep.john@novacare.com' LIMIT 1),
        'Mrs. Ngozi Ekwueme',
        '08029876543',
        'Rivers',
        'Port Harcourt',
        '45 Aba Road, Garrison',
        'contacting',
        1,
        25000.00,
        0.00,
        0.00,
        25000.00,
        'none',
        'pending',
        NULL,
        NOW() - INTERVAL '1 day 2 hours',
        NOW() - INTERVAL '1 day 2 hours'
    ),
    -- Scheduled Callback (Due Soon)
    (
        gen_random_uuid(),
        'ORD-2026-9003',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        (SELECT id FROM auth.users WHERE email = 'salesrep.john@novacare.com' LIMIT 1),
        'Engr. Femi Otedola',
        '08051112233',
        'Lagos',
        'Victoria Island',
        '100 Victoria Island Expressway',
        'call_back',
        3,
        25000.00,
        10000.00,
        0.00,
        85000.00,
        'pending',
        'pending',
        NOW() + INTERVAL '30 minutes',
        NOW() - INTERVAL '2 hours',
        NOW() - INTERVAL '10 minutes'
    ),
    -- Pending Upsell Authorization Request
    (
        gen_random_uuid(),
        'ORD-2026-9004',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        (SELECT id FROM auth.users WHERE email = 'salesrep.john@novacare.com' LIMIT 1),
        'Hajia Fatima Balarabe',
        '08184445566',
        'Abuja',
        'Gwarinpa',
        'House 14 3rd Avenue',
        'upsell_pending',
        2,
        25000.00,
        15000.00,
        0.00,
        65000.00,
        'pending',
        'pending',
        NULL,
        NOW() - INTERVAL '1 hour',
        NOW() - INTERVAL '15 minutes'
    ),
    -- Confirmed Order Today
    (
        gen_random_uuid(),
        'ORD-2026-9005',
        '11111111-1111-4111-8111-111111111111',
        'a1b2c3d4-0000-4000-8000-000000000001',
        (SELECT id FROM auth.users WHERE email = 'salesrep.john@novacare.com' LIMIT 1),
        'Chief Emeka Nnamani',
        '07039998877',
        'Oyo',
        'Ibadan',
        '12 Bodija Estate Road',
        'accepted',
        2,
        25000.00,
        5000.00,
        0.00,
        55000.00,
        'approved',
        'pending',
        NULL,
        NOW() - INTERVAL '40 minutes',
        NOW() - INTERVAL '5 minutes'
    )
ON CONFLICT (id) DO NOTHING;
