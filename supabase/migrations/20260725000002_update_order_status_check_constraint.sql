-- ============================================================================
-- Migration: 20260725000002_update_order_status_check_constraint.sql
-- Description: Update orders status check constraint to include CRM360 statuses
-- ============================================================================

ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE public.orders ADD CONSTRAINT orders_status_check CHECK (
    status IN (
        'new',
        'qualified',
        'assigned_to_rep',
        'contacting',
        'call_back',
        'not_reachable',
        'accepted',
        'upsell_pending',
        'processing',
        'logistics_confirmed',
        'agent_notified',
        'in_transit',
        'rescheduled',
        'delivered',
        'returned',
        'failed_delivery',
        'cancelled',
        'on_hold'
    )
);
