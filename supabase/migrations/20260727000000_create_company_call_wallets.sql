-- Migration: Create Company Call Wallets, Transactions, and Call Logs
-- Date: 2026-07-27

CREATE TABLE IF NOT EXISTS public.company_call_wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  balance NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
  rate_per_minute NUMERIC(6, 2) NOT NULL DEFAULT 14.75,
  wholesale_rate_per_minute NUMERIC(6, 2) NOT NULL DEFAULT 13.75,
  low_balance_threshold NUMERIC(12, 2) NOT NULL DEFAULT 5000.00,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT unique_company_wallet UNIQUE(company_id)
);

CREATE TABLE IF NOT EXISTS public.company_call_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  amount NUMERIC(12, 2) NOT NULL,
  transaction_type VARCHAR(50) NOT NULL DEFAULT 'RECHARGE', -- RECHARGE, DEBIT, REFUND
  payment_reference VARCHAR(100),
  description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.call_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  agent_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
  customer_phone VARCHAR(50) NOT NULL,
  duration_seconds INT NOT NULL DEFAULT 0,
  billed_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  cost_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  profit_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
  sip_provider VARCHAR(100) NOT NULL DEFAULT 'IT Sky Solutions',
  call_status VARCHAR(50) NOT NULL DEFAULT 'ANSWERED', -- ANSWERED, NO_ANSWER, BUSY, FAILED
  recording_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.company_call_wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_call_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.call_logs ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view company call wallets
CREATE POLICY "Users can view their company call wallet" ON public.company_call_wallets
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can view their company call transactions" ON public.company_call_transactions
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Users can view call logs" ON public.call_logs
  FOR SELECT USING (auth.role() = 'authenticated');
