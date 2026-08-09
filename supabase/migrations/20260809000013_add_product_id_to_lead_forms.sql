-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000013_add_product_id_to_lead_forms.sql
-- Add product_id Foreign Key Column to public.lead_forms for Attached Product Validation
-- ============================================================================

ALTER TABLE public.lead_forms 
ADD COLUMN IF NOT EXISTS product_id UUID REFERENCES public.products(id) ON DELETE SET NULL;
