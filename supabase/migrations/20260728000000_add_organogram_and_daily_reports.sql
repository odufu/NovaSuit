-- ============================================================================
-- Migration: 20260728000000_add_organogram_and_daily_reports.sql
-- Description: Supports HOD -> AHOD -> Supervisor -> Supervisee Organogram & Daily Reports
-- ============================================================================

-- Create daily_reports table for WhatsApp submission tracking & verification
CREATE TABLE IF NOT EXISTS public.daily_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rep_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  rep_name TEXT NOT NULL,
  supervisor_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  total_calls INT NOT NULL DEFAULT 0,
  confirmed_orders INT NOT NULL DEFAULT 0,
  total_cod NUMERIC(12,2) NOT NULL DEFAULT 0.00,
  upsell_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
  conversion_rate NUMERIC(5,2) NOT NULL DEFAULT 0.00,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_verified_by_supervisor BOOLEAN NOT NULL DEFAULT FALSE,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for supervisor report oversight queries
CREATE INDEX IF NOT EXISTS idx_daily_reports_supervisor_date 
ON public.daily_reports(supervisor_id, date);

-- Index for rep report lookup
CREATE INDEX IF NOT EXISTS idx_daily_reports_rep_date 
ON public.daily_reports(rep_id, date);
