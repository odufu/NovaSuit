-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000002_add_campaign_forms_and_broadcasts_schema.sql
-- Database Tables, Multi-Tenant RLS Policies, and Indexes for Lead Forms,
-- Submissions, Offer Packages, Custom Questions, and Marketing Broadcasts
-- ============================================================================

-- 1. Create Lead Forms Table
CREATE TABLE IF NOT EXISTS public.lead_forms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    digital_marketer_email TEXT NOT NULL,
    redirect_url TEXT,
    success_message TEXT DEFAULT 'Thanks! Our concierge team will confirm shortly.',
    submit_button_text TEXT DEFAULT 'Get Yours Now',
    quantity_display_mode TEXT DEFAULT 'Radio buttons',
    preset_country TEXT DEFAULT 'Nigeria',
    description TEXT,
    product_category TEXT NOT NULL,
    resolved_brand TEXT DEFAULT 'Novacare',
    resolved_cost_center TEXT DEFAULT 'Novacare - NL',
    core_fields JSONB NOT NULL DEFAULT '[]'::jsonb,
    offer_packages JSONB NOT NULL DEFAULT '[]'::jsonb,
    linked_items JSONB NOT NULL DEFAULT '[]'::jsonb,
    additional_questions JSONB NOT NULL DEFAULT '[]'::jsonb,
    appearance JSONB NOT NULL DEFAULT '{"button_bg": "#568500", "button_text": "#ffffff", "page_bg": "#0f172a", "card_bg": "#fafafc", "border_radius": "10px"}'::jsonb,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Create Form Submissions Table
CREATE TABLE IF NOT EXISTS public.form_submissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_code TEXT UNIQUE NOT NULL,
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    form_id UUID REFERENCES public.lead_forms(id) ON DELETE SET NULL,
    customer_name TEXT NOT NULL,
    contact_email TEXT,
    contact_phone TEXT NOT NULL,
    delivery_state TEXT NOT NULL,
    delivery_city TEXT,
    delivery_address TEXT NOT NULL,
    offer_package_id TEXT,
    selected_quantity INT DEFAULT 1,
    amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    status TEXT NOT NULL DEFAULT 'Converted', -- 'Converted', 'Pending', 'Cancelled'
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    utm_source TEXT,
    utm_campaign TEXT,
    utm_medium TEXT,
    ad_id TEXT,
    additional_responses JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Create Marketing Broadcasts Table
CREATE TABLE IF NOT EXISTS public.marketing_broadcasts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    channel TEXT NOT NULL DEFAULT 'Email & SMS', -- 'Email', 'SMS', 'Email & SMS'
    template_id UUID,
    recipients_count INT DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'Scheduled', -- 'Scheduled', 'Sent', 'Failed'
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Create Email Templates Table
CREATE TABLE IF NOT EXISTS public.email_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    subject TEXT NOT NULL,
    body_html TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Create SMS Templates Table
CREATE TABLE IF NOT EXISTS public.sms_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    sender_id VARCHAR(11) NOT NULL DEFAULT 'NOVACARE',
    message_content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for Query Speed & Multi-Tenant Performance
CREATE INDEX IF NOT EXISTS idx_lead_forms_company ON public.lead_forms(company_id);
CREATE INDEX IF NOT EXISTS idx_form_submissions_company ON public.form_submissions(company_id);
CREATE INDEX IF NOT EXISTS idx_form_submissions_form ON public.form_submissions(form_id);
CREATE INDEX IF NOT EXISTS idx_form_submissions_created ON public.form_submissions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_marketing_broadcasts_company ON public.marketing_broadcasts(company_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.lead_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.form_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.marketing_broadcasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.email_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sms_templates ENABLE ROW LEVEL SECURITY;

-- Multi-Tenant RLS Policies
CREATE POLICY lead_forms_tenant_policy ON public.lead_forms
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

CREATE POLICY form_submissions_tenant_policy ON public.form_submissions
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

CREATE POLICY marketing_broadcasts_tenant_policy ON public.marketing_broadcasts
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

CREATE POLICY email_templates_tenant_policy ON public.email_templates
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

CREATE POLICY sms_templates_tenant_policy ON public.sms_templates
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

-- Public Policy for Inbound Webhook Submissions
CREATE POLICY public_submit_lead_policy ON public.form_submissions
    FOR INSERT WITH CHECK (true);
