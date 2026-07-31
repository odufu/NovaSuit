-- Migration: 20260730000001_add_hr_dialer_toggles_and_hierarchy.sql
-- Description: Add HR controlled dialer toggles (can_take_calls, is_active_call_rep), upsell approval requests table, and sales target quotas table.

-- 1. Extend user_roles with HR Controlled Dialer Toggles & Notes
ALTER TABLE public.user_roles 
ADD COLUMN IF NOT EXISTS can_take_calls BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN IF NOT EXISTS is_active_call_rep BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN IF NOT EXISTS hr_notes TEXT;

-- Index for fast Round-Robin availability queries
CREATE INDEX IF NOT EXISTS idx_user_roles_dialer 
ON public.user_roles(can_take_calls, is_active_call_rep) 
WHERE is_active = true;

-- 2. Create upsell_approval_requests table for Rep -> Supervisor Authorization
CREATE TABLE IF NOT EXISTS public.upsell_approval_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    rep_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    supervisor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    base_price DECIMAL(12, 2) NOT NULL,
    requested_upsell_amount DECIMAL(12, 2) DEFAULT 0.00,
    requested_downsell_discount DECIMAL(12, 2) DEFAULT 0.00,
    new_total_amount DECIMAL(12, 2) NOT NULL,
    upsell_notes TEXT,
    supervisor_notes TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_upsell_requests_status ON public.upsell_approval_requests(status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_upsell_requests_supervisor ON public.upsell_approval_requests(supervisor_id);

-- 3. Create sales_target_quotas table for Rep & Supervisor Quotas
CREATE TABLE IF NOT EXISTS public.sales_target_quotas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    daily_target_orders INT NOT NULL DEFAULT 20,
    monthly_revenue_target DECIMAL(12, 2) NOT NULL DEFAULT 5000000.00,
    base_commission_per_order DECIMAL(10, 2) NOT NULL DEFAULT 500.00,
    tier_bonus_threshold INT DEFAULT 25,
    tier_bonus_commission DECIMAL(10, 2) DEFAULT 750.00,
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sales_quotas_user ON public.sales_target_quotas(user_id, effective_date);
