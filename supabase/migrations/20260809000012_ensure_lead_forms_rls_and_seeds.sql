-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000012_ensure_lead_forms_rls_and_seeds.sql
-- Ensure Unrestricted RLS Policies and Seed Initial Lead Forms into Database
-- ============================================================================

-- 1. Ensure Unrestricted RLS Policies on public.lead_forms
DROP POLICY IF EXISTS lead_forms_tenant_policy ON public.lead_forms;
DROP POLICY IF EXISTS lead_forms_public_read_policy ON public.lead_forms;
DROP POLICY IF EXISTS lead_forms_public_write_policy ON public.lead_forms;
DROP POLICY IF EXISTS lead_forms_unrestricted_policy ON public.lead_forms;

CREATE POLICY lead_forms_unrestricted_policy ON public.lead_forms
    FOR ALL USING (true) WITH CHECK (true);

-- 2. Seed Default Forms into public.lead_forms
INSERT INTO public.lead_forms (
    id,
    company_id,
    title,
    digital_marketer_email,
    product_category,
    redirect_url,
    success_message,
    submit_button_text,
    status
) VALUES 
(
    'f0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'Grazer Tea Joel',
    'joelodufu@gmail.com',
    'Grazer Herbal Tea',
    'https://detoxwithnova.xyz/ura-clear-detox-tea',
    'Order Placed Successfully! Your items will be dispatched within 24 hours.',
    'Buy Grazer',
    'published'
),
(
    'f0000000-0000-0000-0000-000000000002',
    'c0000000-0000-0000-0000-000000000001',
    'Vitality Detox Booster Special Promo',
    'joelodufu@gmail.com',
    'Vitality Booster',
    'https://detoxwithnova.xyz/vitality-thank-you',
    'Order Received! A representative will call to confirm delivery.',
    'Claim Booster Promo',
    'draft'
),
(
    'f0000000-0000-0000-0000-000000000003',
    'c0000000-0000-0000-0000-000000000001',
    'Alpha Man',
    'joelodufu@gmail.com',
    'Grazer Herbal Tea',
    'https://detoxwithnova.xyz/thank-you-alpha-man/',
    'Order Placed Successfully!',
    'Get Yours Now',
    'published'
)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    status = EXCLUDED.status,
    redirect_url = EXCLUDED.redirect_url;
