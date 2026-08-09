-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000003_add_telesales_dialer_schema.sql
-- Database Tables, Multi-Tenant RLS Policies, Indexes, and Round-Robin RPC for
-- Sales Call Reps (Telesales Closers), Floating SIP Telephony & Call Logs
-- ============================================================================

-- 1. Create Telesales Queues Table
CREATE TABLE IF NOT EXISTS public.telesales_queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    product_category TEXT NOT NULL,
    assigned_agents JSONB NOT NULL DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Create Sales Call Logs Table
CREATE TABLE IF NOT EXISTS public.sales_call_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    agent_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    customer_phone TEXT NOT NULL,
    call_type TEXT NOT NULL DEFAULT 'outbound', -- 'outbound', 'inbound'
    call_status TEXT NOT NULL DEFAULT 'completed', -- 'completed', 'busy', 'no_answer', 'failed'
    disposition TEXT NOT NULL DEFAULT 'confirmed', -- 'confirmed', 'callback', 'rejected', 'wrong_number'
    duration_seconds INT NOT NULL DEFAULT 0,
    recording_url TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Create Upsell Offers Table
CREATE TABLE IF NOT EXISTS public.upsell_offers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    main_product_id UUID,
    upsell_product_name TEXT NOT NULL,
    upsell_price NUMERIC(12, 2) NOT NULL,
    discount_percentage NUMERIC(5, 2) DEFAULT 0.00,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Atomic Round-Robin Order Lead Allocation RPC Procedure
CREATE OR REPLACE FUNCTION public.assign_order_round_robin(
    p_order_id UUID,
    p_product_id TEXT DEFAULT 'prod-herbal-tea'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id UUID;
    v_agent_id UUID;
BEGIN
    -- Fetch Company ID from target order
    SELECT company_id INTO v_company_id FROM public.orders WHERE id = p_order_id;
    
    IF v_company_id IS NULL THEN
        RAISE EXCEPTION 'Order not found';
    END IF;

    -- Find active sales_call_rep in the same company with the lowest active assigned leads count
    SELECT u.id INTO v_agent_id
    FROM public.users u
    LEFT JOIN public.orders o ON o.sales_rep_id = u.id AND o.status IN ('new', 'contacting')
    WHERE u.company_id = v_company_id 
      AND u.role IN ('sales_call_rep', 'supervisor')
      AND u.is_active = true
    GROUP BY u.id
    ORDER BY COUNT(o.id) ASC, u.created_at ASC
    LIMIT 1;

    -- If suitable agent found, update order assignment
    IF v_agent_id IS NOT NULL THEN
        UPDATE public.orders 
        SET sales_rep_id = v_agent_id,
            status = 'contacting',
            updated_at = now()
        WHERE id = p_order_id;
    END IF;

    RETURN v_agent_id;
END;
$$;

-- Indexes for Fast Dialer Queries
CREATE INDEX IF NOT EXISTS idx_sales_call_logs_company ON public.sales_call_logs(company_id);
CREATE INDEX IF NOT EXISTS idx_sales_call_logs_agent ON public.sales_call_logs(agent_id);
CREATE INDEX IF NOT EXISTS idx_sales_call_logs_created ON public.sales_call_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_telesales_queues_company ON public.telesales_queues(company_id);

-- Enable Row Level Security (RLS)
ALTER TABLE public.telesales_queues ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sales_call_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upsell_offers ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY telesales_queues_tenant_policy ON public.telesales_queues
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

CREATE POLICY sales_call_logs_tenant_policy ON public.sales_call_logs
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

CREATE POLICY upsell_offers_tenant_policy ON public.upsell_offers
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);
