-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000009_fix_lead_forms_title_unique_constraint.sql
-- Add Unique Constraint on title Column of lead_forms Table for Clean Upserts
-- ============================================================================

-- 1. Add Unique Constraint on title column
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'lead_forms_title_key'
    ) THEN
        ALTER TABLE public.lead_forms ADD CONSTRAINT lead_forms_title_key UNIQUE (title);
    END IF;
END $$;

-- 2. Verify RLS Policies for lead_forms
DROP POLICY IF EXISTS lead_forms_public_read_policy ON public.lead_forms;
CREATE POLICY lead_forms_public_read_policy ON public.lead_forms
    FOR SELECT USING (true);

DROP POLICY IF EXISTS lead_forms_public_write_policy ON public.lead_forms;
CREATE POLICY lead_forms_public_write_policy ON public.lead_forms
    FOR ALL USING (true) WITH CHECK (true);
