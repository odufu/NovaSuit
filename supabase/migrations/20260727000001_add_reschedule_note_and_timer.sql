-- ============================================================================
-- Migration: 20260727000001_add_reschedule_note_and_timer.sql
-- Description: Add reschedule_note column and optimize scheduled_callback_at index for live countdowns
-- ============================================================================

ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS scheduled_callback_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS reschedule_note TEXT;

-- Index for fast querying of rescheduled orders & live countdowns
CREATE INDEX IF NOT EXISTS idx_orders_scheduled_callback_note 
ON public.orders(scheduled_callback_at, reschedule_note) 
WHERE status IN ('call_back', 'rescheduled');
