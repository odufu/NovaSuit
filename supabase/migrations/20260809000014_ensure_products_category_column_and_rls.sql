-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000014_ensure_products_category_column_and_rls.sql
-- Ensure category column exists in public.products and set RLS permissions
-- ============================================================================

ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'General';

-- Ensure Unrestricted Policy for public.products
DROP POLICY IF EXISTS products_unrestricted_policy ON public.products;

CREATE POLICY products_unrestricted_policy ON public.products
    FOR ALL USING (true) WITH CHECK (true);
