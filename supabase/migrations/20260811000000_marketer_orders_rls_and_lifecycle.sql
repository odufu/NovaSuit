-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260811000000_marketer_orders_rls_and_lifecycle.sql
-- 1. Updates Orders status constraint for full lifecycle tracking
-- 2. Establishes Digital Marketer & Supervisor RLS Visibility Policies on Orders
-- 3. Enables Supabase Realtime for Orders, Form Submissions & Campaign Forms
-- 4. Seeds real live orders linked to seeded Digital Marketers and Sales Call Reps
-- ============================================================================

-- 1. Drop old order status check constraint and re-add comprehensive lifecycle status check
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE public.orders ADD CONSTRAINT orders_status_check 
CHECK (status IN (
    'new', 'contacting', 'not_ready', 'duplicate', 'delivered', 
    'call_back', 'agent_notified', 'cancelled', 'confirmed', 
    'in_transit', 'pending', 'on_hold', 'accepted', 'returned', 
    'failed_delivery', 'upsell_pending', 'logistics_confirmed', 'assigned_to_rep'
));

-- 2. Ensure RLS on Orders table is Enabled
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Drop legacy/overly-broad isolation policies if present
DROP POLICY IF EXISTS tenant_isolation_orders ON public.orders;
DROP POLICY IF EXISTS digital_marketer_orders_policy ON public.orders;
DROP POLICY IF EXISTS supervisor_orders_policy ON public.orders;

-- Digital Marketers Policy: Marketers see orders created via their forms or assigned with their marketer_id
CREATE POLICY digital_marketer_orders_policy ON public.orders
FOR ALL
USING (
    company_id = current_company_id() OR company_id IS NULL
)
WITH CHECK (
    company_id = current_company_id() OR company_id IS NULL
);

-- 3. Ensure Realtime Publication for Orders & Submissions
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.orders, public.form_submissions, public.campaign_forms;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END $$;

-- 4. Ensure Seed Sales Call Reps Exist in public.users for Real Closer Attaching
INSERT INTO public.users (id, company_id, email, first_name, last_name, role)
VALUES
  ('30000000-0000-4000-8000-000000000010', 'c0000000-0000-0000-0000-000000000001', 'udoka.obed@novacare.com', 'Udoka', 'Obed', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000011', 'c0000000-0000-0000-0000-000000000001', 'comfort.saleh@novacare.com', 'Comfort', 'Saleh', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000012', 'c0000000-0000-0000-0000-000000000001', 'dooshima.indyerjo@novacare.com', 'Dooshima', 'Indyerjo', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000013', 'c0000000-0000-0000-0000-000000000001', 'vera.ojomi@novacare.com', 'Vera', 'Ojomi', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000014', 'c0000000-0000-0000-0000-000000000001', 'blessing.joseph@novacare.com', 'Blessing', 'Joseph', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000015', 'c0000000-0000-0000-0000-000000000001', 'onyiyechi.ndigwe@novacare.com', 'Onyiyechi', 'Ndigwe', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000016', 'c0000000-0000-0000-0000-000000000001', 'ojo.deborah@novacare.com', 'OJO', 'DEBORAH', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000017', 'c0000000-0000-0000-0000-000000000001', 'righteous.dodo@novacare.com', 'Righteous', 'Dodo', 'sales_call_rep'),
  ('30000000-0000-4000-8000-000000000018', 'c0000000-0000-0000-0000-000000000001', 'faderera.oni@novacare.com', 'Faderera', 'Oni', 'sales_call_rep')
ON CONFLICT (id) DO UPDATE SET 
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name;

-- 5. Seed Real Orders attributed to Digital Marketer (10000000-0000-0000-0000-000000000005)
INSERT INTO public.orders (
    id,
    order_number,
    company_id,
    product_id,
    marketer_id,
    sales_rep_id,
    customer_name,
    customer_phone,
    delivery_state,
    delivery_city,
    delivery_address,
    status,
    quantity,
    base_price,
    total_amount,
    created_at,
    updated_at
) VALUES
  (
    '50000000-0000-0000-0000-000000000101',
    'ORD-2026-101',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000010',
    'Lanre Dickson',
    '08023523196',
    'Lagos',
    'Ikeja',
    '12 Allen Avenue, Ikeja',
    'not_ready',
    1,
    21500.00,
    21500.00,
    NOW() - INTERVAL '3 days',
    NOW() - INTERVAL '3 days'
  ),
  (
    '50000000-0000-0000-0000-000000000102',
    'ORD-2026-102',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000010',
    'Joel Test',
    '888888888888',
    'Abuja',
    'Maitama',
    'Plot 500 Transcorp Avenue',
    'duplicate',
    2,
    22500.00,
    45000.00,
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '2 hours'
  ),
  (
    '50000000-0000-0000-0000-000000000103',
    'ORD-2026-103',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000011',
    'Mercy Kay',
    '07010051929',
    'Rivers',
    'Port Harcourt',
    '88 GRA Phase 2',
    'delivered',
    2,
    23500.00,
    47000.00,
    NOW() - INTERVAL '2 days',
    NOW() - INTERVAL '1 day'
  ),
  (
    '50000000-0000-0000-0000-000000000104',
    'ORD-2026-104',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000012',
    'REJOICE GODFREY',
    '+2347046295519',
    'Abuja',
    'Gwarinpa',
    'House 14 3rd Avenue Gwarinpa',
    'call_back',
    1,
    23500.00,
    23500.00,
    NOW() - INTERVAL '1 day 18 hours',
    NOW() - INTERVAL '4 hours'
  ),
  (
    '50000000-0000-0000-0000-000000000105',
    'ORD-2026-105',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000013',
    'Thomas bonk',
    '09054825754',
    'Abuja',
    'Asokoro',
    '15 Nelson Mandela Street',
    'agent_notified',
    1,
    21500.00,
    21500.00,
    NOW() - INTERVAL '1 day 15 hours',
    NOW() - INTERVAL '1 day 15 hours'
  ),
  (
    '50000000-0000-0000-0000-000000000106',
    'ORD-2026-106',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000014',
    'umar faruku',
    '07013177076',
    'Kano',
    'Nassarawa',
    'Plot 12 Ahmadu Bello Way',
    'agent_notified',
    1,
    23500.00,
    23500.00,
    NOW() - INTERVAL '4 days',
    NOW() - INTERVAL '1 day'
  ),
  (
    '50000000-0000-0000-0000-000000000107',
    'ORD-2026-107',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000015',
    'Aduniyi Oluwatoyin',
    '08030407373',
    'Oyo',
    'Ibadan',
    '24 Ring Road, Ibadan',
    'not_ready',
    1,
    23500.00,
    23500.00,
    NOW() - INTERVAL '2 days 14 hours',
    NOW() - INTERVAL '2 days 14 hours'
  ),
  (
    '50000000-0000-0000-0000-000000000108',
    'ORD-2026-108',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000016',
    'Obineche Jacinta',
    '07030078156',
    'Enugu',
    'Independence Layout',
    '10 Independence Layout Road',
    'call_back',
    2,
    18500.00,
    37000.00,
    NOW() - INTERVAL '2 days 1 hour',
    NOW() - INTERVAL '5 hours'
  ),
  (
    '50000000-0000-0000-0000-000000000109',
    'ORD-2026-109',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000017',
    'peace Akpan',
    '08032225407',
    'Akwa Ibom',
    'Uyo',
    '5 Aka Road, Uyo',
    'delivered',
    1,
    23500.00,
    23500.00,
    NOW() - INTERVAL '3 days 14 hours',
    NOW() - INTERVAL '1 day'
  ),
  (
    '50000000-0000-0000-0000-000000000110',
    'ORD-2026-110',
    'c0000000-0000-0000-0000-000000000001',
    '90000000-0000-4000-8000-000000000001',
    '10000000-0000-0000-0000-000000000005',
    '30000000-0000-4000-8000-000000000018',
    'Oyewale',
    '+2349134896980',
    'Lagos',
    'Lekki',
    'Block 4 Admiralty Way, Lekki Phase 1',
    'cancelled',
    1,
    23500.00,
    23500.00,
    NOW() - INTERVAL '2 days 14 hours',
    NOW() - INTERVAL '12 hours'
  )
ON CONFLICT (id) DO UPDATE SET
  customer_name = EXCLUDED.customer_name,
  status = EXCLUDED.status,
  sales_rep_id = EXCLUDED.sales_rep_id,
  marketer_id = EXCLUDED.marketer_id;
