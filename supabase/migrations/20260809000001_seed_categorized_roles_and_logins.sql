-- ============================================================================
-- NOVASUITE SEED MIGRATION: 20260809000001_seed_categorized_roles_and_logins.sql
-- Seed Categorized E-Commerce vs. Logistics Role Users & Credentials
-- ============================================================================

-- Ensure Company Records Exist
INSERT INTO public.companies (id, name, company_type, subdomain, branding)
VALUES 
  ('c0000000-0000-0000-0000-000000000001', 'NovaCare Health & Wellness', 'ecommerce', 'novacare', '{"primary_color":"#10B981","secondary_color":"#09140E"}'::jsonb),
  ('c0000000-0000-0000-0000-000000000002', 'Nova Express Logistics Network', 'logistics', 'novaexpress', '{"primary_color":"#3B82F6","secondary_color":"#0F172A"}'::jsonb)
ON CONFLICT (id) DO UPDATE SET 
  company_type = EXCLUDED.company_type,
  subdomain = EXCLUDED.subdomain,
  branding = EXCLUDED.branding;

-- Drop restrictive legacy role check constraint to allow expanded role taxonomy
ALTER TABLE public.users DROP CONSTRAINT IF EXISTS users_role_check;

-- Seed E-Commerce Company Users (NovaCare)
INSERT INTO public.users (id, company_id, email, first_name, last_name, role)
VALUES
  ('10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'superadmin@novacare.com', 'Alexander', 'Pierce', 'super_admin'),
  ('10000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'hodsales@novacare.com', 'Grace', 'Danielle', 'hod'),
  ('10000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'supervisor@novacare.com', 'David', 'Adeleke', 'supervisor'),
  ('10000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000001', 'salesrep@novacare.com', 'Blessing', 'Okoro', 'sales_call_rep'),
  ('10000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000001', 'marketer@novacare.com', 'Tunde', 'Ednut', 'digital_marketer'),
  ('10000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000001', 'finance@novacare.com', 'Chidinma', 'Eze', 'finance_manager')
ON CONFLICT (email) DO UPDATE SET 
  email = EXCLUDED.email,
  role = EXCLUDED.role;

-- Seed Logistics Company Users (Nova Express)
INSERT INTO public.users (id, company_id, email, first_name, last_name, role)
VALUES
  ('10000000-0000-0000-0000-000000000007', 'c0000000-0000-0000-0000-000000000002', 'admin@novaexpress.com', 'Victor', 'Oladipo', 'logistics_super_admin'),
  ('10000000-0000-0000-0000-000000000008', 'c0000000-0000-0000-0000-000000000002', 'cdcmanager@novaexpress.com', 'Emmanuel', 'Okafor', 'circuit_center_manager'),
  ('10000000-0000-0000-0000-000000000009', 'c0000000-0000-0000-0000-000000000002', 'warehouse@novaexpress.com', 'Samuel', 'Inyang', 'inventory_manager'),
  ('10000000-0000-0000-0000-000000000010', 'c0000000-0000-0000-0000-000000000002', 'dispatcher@novaexpress.com', 'Suleiman', 'Bello', 'logistics_call_rep'),
  ('10000000-0000-0000-0000-000000000011', 'c0000000-0000-0000-0000-000000000002', 'rider@novaexpress.com', 'Sunday', 'Bamidele', 'delivery_agent')
ON CONFLICT (email) DO UPDATE SET 
  email = EXCLUDED.email,
  role = EXCLUDED.role;
