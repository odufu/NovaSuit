-- ============================================================================
-- NOVASUITE SEED DATA MIGRATION (STRICT HEX VALID UUIDs)
-- Populates Test Companies, Whitelabel Themes, Departments, Users for ALL Roles,
-- Products, Warehouses, Inventory, and Test Orders.
-- ============================================================================

-- 1. SEED TENANT COMPANIES
INSERT INTO companies (id, name, type, is_active) VALUES
('11111111-1111-4111-8111-111111111111', 'Nova Care Herbal', 'marketing', true),
('22222222-2222-4222-8222-222222222222', 'Nova Express Logistics', 'logistics', true),
('33333333-3333-4333-8333-333333333333', 'Herbal Life Co', 'marketing', true)
ON CONFLICT (id) DO NOTHING;

-- 2. SEED WHITELABEL TENANT SETTINGS
INSERT INTO tenant_settings (company_id, app_title, primary_color, secondary_color, accent_color, currency_code, currency_symbol, sms_sender_id) VALUES
('11111111-1111-4111-8111-111111111111', 'Nova Care CRM', '#1B4D3E', '#D4AF37', '#E67E22', 'NGN', '₦', 'NOVACARE'),
('22222222-2222-4222-8222-222222222222', 'NovaExpress Logistics', '#0F4C81', '#F5A623', '#2ECC71', 'NGN', '₦', 'NOVAEXP'),
('33333333-3333-4333-8333-333333333333', 'Herbal Life Suite', '#D35400', '#2C3E50', '#27AE60', 'USD', '$', 'HERBALLIFE')
ON CONFLICT (company_id) DO NOTHING;

-- 3. SEED DEPARTMENTS
INSERT INTO departments (id, company_id, name) VALUES
('a1111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', 'Digital Marketing'),
('a2222222-2222-4222-8222-222222222222', '11111111-1111-4111-8111-111111111111', 'Sales Call Center'),
('a3333333-3333-4333-8333-333333333333', '22222222-2222-4222-8222-222222222222', 'Logistics Operations'),
('a4444444-4444-4444-8444-444444444444', '11111111-1111-4111-8111-111111111111', 'Finance & Reconciliation')
ON CONFLICT (id) DO NOTHING;

-- 4. SEED USERS FOR ALL ROLES (VALID HEX UUIDs)
INSERT INTO users (id, company_id, department_id, role, first_name, last_name, email, phone, is_active) VALUES
-- Super Admin
('00000000-0000-4000-8000-000000000000', '11111111-1111-4111-8111-111111111111', null, 'super_admin', 'Global', 'Admin', 'superadmin@novasuite.com', '+2348000000000', true),
-- AGM / Executive
('10000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'a2222222-2222-4222-8222-222222222222', 'agm', 'Alex', 'General Manager', 'agm@novacare.com', '+2348031112233', true),
-- Supervisor
('20000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'a2222222-2222-4222-8222-222222222222', 'supervisor', 'Samuel', 'Supervisor', 'supervisor@novacare.com', '+2348032223344', true),
-- Sales Call Rep 1
('30000000-0000-4000-8000-000000000003', '11111111-1111-4111-8111-111111111111', 'a2222222-2222-4222-8222-222222222222', 'sales_call_rep', 'John', 'SalesRep', 'salesrep.john@novacare.com', '+2348033334455', true),
-- Sales Call Rep 2
('40000000-0000-4000-8000-000000000004', '11111111-1111-4111-8111-111111111111', 'a2222222-2222-4222-8222-222222222222', 'sales_call_rep', 'Sarah', 'SalesRep', 'salesrep.sarah@novacare.com', '+2348034445566', true),
-- Digital Marketer
('50000000-0000-4000-8000-000000000005', '11111111-1111-4111-8111-111111111111', 'a1111111-1111-4111-8111-111111111111', 'digital_marketer', 'David', 'Marketer', 'marketer.david@novacare.com', '+2348035556677', true),
-- Logistics Call Rep
('60000000-0000-4000-8000-000000000006', '22222222-2222-4222-8222-222222222222', 'a3333333-3333-4333-8333-333333333333', 'logistics_call_rep', 'Leonard', 'LogisticsRep', 'logisticsrep@novaexpress.com', '+2348036667788', true),
-- Delivery Agent / Rider
('70000000-0000-4000-8000-000000000007', '22222222-2222-4222-8222-222222222222', 'a3333333-3333-4333-8333-333333333333', 'delivery_agent', 'Emeka', 'Rider', 'rider.emeka@novaexpress.com', '+2348037778899', true),
-- Finance Manager
('80000000-0000-4000-8000-000000000008', '11111111-1111-4111-8111-111111111111', 'a4444444-4444-4444-8444-444444444444', 'finance_manager', 'Fiona', 'FinanceManager', 'finance@novacare.com', '+2348038889900', true)
ON CONFLICT (id) DO NOTHING;

-- Link Supervisor to Sales Department
UPDATE departments SET supervisor_id = '20000000-0000-4000-8000-000000000002' WHERE id = 'a2222222-2222-4222-8222-222222222222';

-- 5. SEED CALL REP STATS (FOR ATOMIC ROUND-ROBIN)
INSERT INTO call_rep_stats (user_id, pending_orders_count, total_assigned_count, is_active) VALUES
('30000000-0000-4000-8000-000000000003', 2, 45, true),
('40000000-0000-4000-8000-000000000004', 1, 38, true)
ON CONFLICT (user_id) DO NOTHING;

-- 6. SEED PRODUCTS & ATTACHED CALL REPS
INSERT INTO products (id, company_id, name, sku, description, base_price, is_active) VALUES
('90000000-0000-4000-8000-000000000001', '11111111-1111-4111-8111-111111111111', 'Herbal Care Detox Tea', 'SKU-DETOX-01', '100% Organic Herbal Detox & Cleanser', 25000.00, true),
('90000000-0000-4000-8000-000000000002', '11111111-1111-4111-8111-111111111111', 'Herbal Vitality Booster', 'SKU-BOOST-02', 'Immune System & Energy Enhancement Formula', 18000.00, true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO product_call_reps (product_id, user_id) VALUES
('90000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000003'),
('90000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000004'),
('90000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000003')
ON CONFLICT (product_id, user_id) DO NOTHING;

-- 7. SEED LOGISTICS AGENCIES, RIDERS & WAREHOUSES
INSERT INTO delivery_agencies (id, name, type, commission_per_delivery, contact_phone) VALUES
('ab111111-1111-4111-8111-111111111111', 'Nova Express Direct Network', 'in_house', 1500.00, '+2348009990000')
ON CONFLICT (id) DO NOTHING;

INSERT INTO delivery_agents (id, user_id, agency_id, agent_type, coverage_states, current_cod_balance, max_cod_credit_limit) VALUES
('b1111111-1111-4111-8111-111111111111', '70000000-0000-4000-8000-000000000007', 'ab111111-1111-4111-8111-111111111111', 'agency_rider', ARRAY['Lagos', 'Ogun'], 85000.00, 150000.00)
ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouses (id, company_id, agency_id, rider_id, name, type, location_state, address) VALUES
('c1111111-1111-4111-8111-111111111111', '11111111-1111-4111-8111-111111111111', null, null, 'Lagos Central Factory Hub', 'central', 'Lagos', '14 Allen Avenue, Ikeja, Lagos'),
('c2222222-2222-4222-8222-222222222222', '22222222-2222-4222-8222-222222222222', 'ab111111-1111-4111-8111-111111111111', null, 'Abuja Regional Hub (NovaExpress)', 'agency_hub', 'Abuja', 'Plot 10, Central Business District, Abuja'),
('c3333333-3333-4333-8333-333333333333', '22222222-2222-4222-8222-222222222222', null, 'b1111111-1111-4111-8111-111111111111', 'Rider Emeka Mini-Hub', 'rider_mini_hub', 'Lagos', 'Ikeja Dispatch Stand, Lagos')
ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse_inventory (warehouse_id, product_id, quantity_available, quantity_allocated, quantity_in_transit) VALUES
('c1111111-1111-4111-8111-111111111111', '90000000-0000-4000-8000-000000000001', 4500, 320, 500),
('c2222222-2222-4222-8222-222222222222', '90000000-0000-4000-8000-000000000001', 1800, 110, 200),
('c3333333-3333-4333-8333-333333333333', '90000000-0000-4000-8000-000000000001', 18, 2, 0)
ON CONFLICT (warehouse_id, product_id) DO NOTHING;

-- 8. SEED TEST ORDERS
INSERT INTO orders (
    id, order_number, company_id, product_id, sales_rep_id, logistics_rep_id, delivery_agent_id, warehouse_id,
    customer_name, customer_phone, delivery_state, delivery_city, delivery_address,
    status, quantity, base_price, upsell_amount, downsell_discount, total_amount, upsell_status, upsell_notes, payment_status
) VALUES
('d1111111-1111-4111-8111-111111111111', 'ORD-849201', '11111111-1111-4111-8111-111111111111', '90000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-000000000003', null, null, 'c1111111-1111-4111-8111-111111111111', 'Amina Bello', '+2348031234567', 'Lagos', 'Ikeja', '14 Allen Avenue, Ikeja, Lagos', 'upsell_pending', 2, 25000.00, 12000.00, 0.00, 62000.00, 'pending', 'Client added 1 Extra Herbal Detox Bottle', 'pending'),

('d2222222-2222-4222-8222-222222222222', 'ORD-849202', '11111111-1111-4111-8111-111111111111', '90000000-0000-4000-8000-000000000001', '40000000-0000-4000-8000-000000000004', null, null, 'c2222222-2222-4222-8222-222222222222', 'Chidi Okeke', '+2348129876543', 'Abuja', 'Maitama', '8 Gana Street, Maitama, Abuja', 'accepted', 1, 25000.00, 0.00, 0.00, 25000.00, 'none', null, 'pending'),

('d3333333-3333-4333-8333-333333333333', 'ORD-849203', '11111111-1111-4111-8111-111111111111', '90000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-000000000003', '60000000-0000-4000-8000-000000000006', 'b1111111-1111-4111-8111-111111111111', 'c3333333-3333-4333-8333-333333333333', 'Emeka Nwosu', '+2347015558899', 'Lagos', 'Lekki', 'Block 4, Admiralty Way, Lekki Phase 1, Lagos', 'in_transit', 3, 18000.00, 0.00, 2000.00, 52000.00, 'approved', null, 'pending')
ON CONFLICT (id) DO NOTHING;
