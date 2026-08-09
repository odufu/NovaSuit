-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000011_fix_lead_forms_rls_drop_tenant_policy.sql
-- Drop Restrictive Legacy Tenant Policies on lead_forms, form_submissions & products
-- Enables Unrestricted DB Access for Unauthenticated & Authenticated Client Apps
-- ============================================================================

-- 1. Drop ALL legacy restrictive policies on public.lead_forms
DROP POLICY IF EXISTS lead_forms_tenant_policy ON public.lead_forms;
DROP POLICY IF EXISTS lead_forms_public_read_policy ON public.lead_forms;
DROP POLICY IF EXISTS lead_forms_public_write_policy ON public.lead_forms;
DROP POLICY IF EXISTS lead_forms_unrestricted_policy ON public.lead_forms;

-- Create Single Clean Unrestricted RLS Policy for lead_forms
CREATE POLICY lead_forms_unrestricted_policy ON public.lead_forms
    FOR ALL USING (true) WITH CHECK (true);

-- 2. Drop ALL legacy restrictive policies on public.form_submissions
DROP POLICY IF EXISTS form_submissions_tenant_policy ON public.form_submissions;
DROP POLICY IF EXISTS form_submissions_public_read_policy ON public.form_submissions;
DROP POLICY IF EXISTS form_submissions_public_write_policy ON public.form_submissions;
DROP POLICY IF EXISTS form_submissions_unrestricted_policy ON public.form_submissions;

-- Create Single Clean Unrestricted RLS Policy for form_submissions
CREATE POLICY form_submissions_unrestricted_policy ON public.form_submissions
    FOR ALL USING (true) WITH CHECK (true);

-- 3. Drop ALL legacy restrictive policies on public.products
DROP POLICY IF EXISTS products_tenant_policy ON public.products;
DROP POLICY IF EXISTS public_read_products ON public.products;
DROP POLICY IF EXISTS products_unrestricted_policy ON public.products;

-- Create Single Clean Unrestricted RLS Policy for products
CREATE POLICY products_unrestricted_policy ON public.products
    FOR ALL USING (true) WITH CHECK (true);
