-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000008_add_realtime_to_lead_forms_and_submissions.sql
-- Enable Supabase Realtime Replication & RLS Policies for Lead Forms and Form Submissions
-- ============================================================================

-- 1. Enable Realtime Publication for lead_forms and form_submissions
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'lead_forms'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.lead_forms;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'form_submissions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.form_submissions;
    END IF;
END $$;

-- 2. Ensure RLS Policy for form_submissions Allows Public Read & Realtime Listening
DROP POLICY IF EXISTS form_submissions_public_read_policy ON public.form_submissions;
CREATE POLICY form_submissions_public_read_policy ON public.form_submissions
    FOR SELECT USING (true);

DROP POLICY IF EXISTS form_submissions_public_insert_policy ON public.form_submissions;
CREATE POLICY form_submissions_public_insert_policy ON public.form_submissions
    FOR INSERT WITH CHECK (true);

-- 3. Seed Initial Sample Submissions for NovaCare Health & Wellness (if empty)
INSERT INTO public.form_submissions (
    id,
    submission_code,
    company_id,
    form_id,
    customer_name,
    contact_email,
    contact_phone,
    delivery_state,
    delivery_city,
    delivery_address,
    offer_package_id,
    selected_quantity,
    amount,
    status
) VALUES
(
    's0000000-0000-0000-0000-000000000001',
    'CRM-SUB-224496',
    'c0000000-0000-0000-0000-000000000001',
    'f0000000-0000-0000-0000-000000000001',
    'Aduniyi Oluwatoyin',
    'ftomtoyin@gmail.com',
    '08030407373',
    'Lagos',
    'Ikeja',
    '14 Allen Avenue',
    'pkg-1',
    1,
    23500.00,
    'Converted'
),
(
    's0000000-0000-0000-0000-000000000002',
    'CRM-SUB-224489',
    'c0000000-0000-0000-0000-000000000001',
    'f0000000-0000-0000-0000-000000000001',
    'Oyewale Phebe',
    'oyewalephebe996@gmail.com',
    '+2349134898980',
    'Benue',
    'Otukpo',
    '5 Enugu Road',
    'pkg-2',
    2,
    37000.00,
    'Converted'
),
(
    's0000000-0000-0000-0000-000000000003',
    'CRM-SUB-223609',
    'c0000000-0000-0000-0000-000000000001',
    'f0000000-0000-0000-0000-000000000002',
    'Halifa Aliko',
    'halifamohdaliko@gmail.com',
    '08035954478',
    'Abuja (FCT)',
    'Garki',
    '22 Garki Area 11',
    'pkg-3',
    3,
    47000.00,
    'Converted'
)
ON CONFLICT (id) DO NOTHING;
