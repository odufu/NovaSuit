-- Supabase Migration: 20260731000000_seed_supervisor_squad_report_data.sql
-- Description: Adds CRM tagging status, rep product licenses, and schema extensions for operational report data.

-- 1. Add crm_tagged column to orders table if not exists
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS crm_tagged BOOLEAN DEFAULT TRUE;

-- 2. Add assigned_products array column to user_roles table for product licensing
ALTER TABLE public.user_roles ADD COLUMN IF NOT EXISTS assigned_products TEXT[] DEFAULT ARRAY['GRAZER HERBAL DETOX TEA', 'HERBAL SHAMPOO & VITALITY BOOSTER', 'CLEAR SKIN CARE SET'];

-- 3. Seed/Update user roles with licensed products
UPDATE public.user_roles 
SET assigned_products = ARRAY['GRAZER HERBAL DETOX TEA', 'HERBAL SHAMPOO & VITALITY BOOSTER']
WHERE role = 'sales_call_rep';
