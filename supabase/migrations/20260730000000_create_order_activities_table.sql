-- ============================================================================
-- Migration: 20260730000000_create_order_activities_table.sql
-- Description: Table for recording real-time chronological activity logs per order
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.order_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL DEFAULT 'status_update',
    title TEXT NOT NULL,
    details TEXT,
    performed_by TEXT NOT NULL DEFAULT 'System',
    user_role TEXT NOT NULL DEFAULT 'Automated Workflow',
    scheduled_callback_at TIMESTAMPTZ,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for retrieving activity log for a specific order sorted by created_at DESC
CREATE INDEX IF NOT EXISTS idx_order_activities_order_created 
ON public.order_activities(order_id, created_at DESC);
