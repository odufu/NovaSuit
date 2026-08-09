-- NOVASUITE SUPABASE MIGRATION: 20260809000015_fix_lead_forms_null_constraints.sql
-- Relaxes NOT NULL constraints on lead_forms columns to prevent silent form creation persistence failures

ALTER TABLE public.lead_forms ALTER COLUMN product_category SET DEFAULT 'Grazer Herbal Tea';
ALTER TABLE public.lead_forms ALTER COLUMN digital_marketer_email SET DEFAULT 'marketer@novacare.com';
ALTER TABLE public.lead_forms ALTER COLUMN product_category DROP NOT NULL;
ALTER TABLE public.lead_forms ALTER COLUMN digital_marketer_email DROP NOT NULL;
