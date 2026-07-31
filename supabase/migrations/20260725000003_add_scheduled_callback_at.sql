-- ============================================================================
-- Migration: 20260725000003_add_scheduled_callback_at.sql
-- Description: Add scheduled_callback_at column to orders table for rescheduled calls
-- ============================================================================

ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS scheduled_callback_at TIMESTAMPTZ;

-- Index for fast notification query of upcoming scheduled callbacks
CREATE INDEX IF NOT EXISTS idx_orders_scheduled_callback 
ON public.orders(scheduled_callback_at) 
WHERE status IN ('call_back', 'rescheduled');
