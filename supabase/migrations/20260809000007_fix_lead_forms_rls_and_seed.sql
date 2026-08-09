-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000007_fix_lead_forms_rls_and_seed.sql
-- Fix Lead Forms RLS Policies (Allow Read/Write for Client Apps) & Seed Initial Lead Forms
-- ============================================================================

-- 1. Ensure RLS Policies for lead_forms Allow Client Access (Read & Write)
DROP POLICY IF EXISTS lead_forms_public_read_policy ON public.lead_forms;
CREATE POLICY lead_forms_public_read_policy ON public.lead_forms
    FOR SELECT USING (true);

DROP POLICY IF EXISTS lead_forms_public_write_policy ON public.lead_forms;
CREATE POLICY lead_forms_public_write_policy ON public.lead_forms
    FOR ALL USING (true) WITH CHECK (true);

-- 2. Seed Default Initial Lead Forms for NovaCare Health & Wellness
INSERT INTO public.lead_forms (
    id,
    company_id,
    title,
    digital_marketer_email,
    redirect_url,
    success_message,
    submit_button_text,
    quantity_display_mode,
    preset_country,
    description,
    product_category,
    status
) VALUES
(
    'f0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'Grazer Tea Joel',
    'joelodufu@gmail.com',
    'https://detoxwithnova.xyz/ura-clear-detox-tea',
    'Thanks! Our concierge team will confirm shortly.',
    'Get Yours Now',
    'Radio buttons',
    'Nigeria',
    'Official high-converting checkout form for Grazer Tea.',
    'Grazer Herbal Tea',
    'published'
),
(
    'f0000000-0000-0000-0000-000000000002',
    'c0000000-0000-0000-0000-000000000001',
    'Vitality Detox Booster Special Promo',
    'joelodufu@gmail.com',
    'https://detoxwithnova.xyz/vitality-thank-you',
    'Thanks! Our concierge team will confirm shortly.',
    'Get Yours Now',
    'Radio buttons',
    'Nigeria',
    'Draft promo offer form for Vitality Booster.',
    'Vitality Booster',
    'draft'
)
ON CONFLICT (id) DO UPDATE SET
    title = EXCLUDED.title,
    digital_marketer_email = EXCLUDED.digital_marketer_email,
    redirect_url = EXCLUDED.redirect_url,
    product_category = EXCLUDED.product_category,
    status = EXCLUDED.status;
