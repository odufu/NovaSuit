-- ============================================================================
-- NOVASUITE MIGRATION: 20260809000000_add_multi_tenant_and_logistics_schema.sql
-- Multi-Tenant White-Labeling, Circuit Centers (CDCs) & 3PL Stock Holding Schema
-- ============================================================================

-- 1. Extend Companies Table for Multi-Tenant White-Labeling
ALTER TABLE public.companies 
ADD COLUMN IF NOT EXISTS company_type VARCHAR(50) DEFAULT 'ecommerce',
ADD COLUMN IF NOT EXISTS subdomain VARCHAR(100) UNIQUE,
ADD COLUMN IF NOT EXISTS custom_domain VARCHAR(255),
ADD COLUMN IF NOT EXISTS webhook_url TEXT,
ADD COLUMN IF NOT EXISTS webhook_secret VARCHAR(255),
ADD COLUMN IF NOT EXISTS branding JSONB DEFAULT '{
  "primary_color": "#10B981",
  "secondary_color": "#09140E",
  "accent_color": "#F59E0B",
  "dark_surface": "#0C1F17",
  "light_surface": "#F8FAFC",
  "idp_app_title": "Nova Express Rider App"
}'::jsonb;

-- Seed default subdomains for initial tenant companies
UPDATE public.companies SET subdomain = 'novacare', company_type = 'ecommerce' WHERE id = 'c0000000-0000-0000-0000-000000000001' AND subdomain IS NULL;

-- 2. Create Circuit Centers Table (Collation & Distribution Hubs)
CREATE TABLE IF NOT EXISTS public.circuit_centers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  center_name VARCHAR(255) NOT NULL,
  hub_code VARCHAR(50) NOT NULL UNIQUE,
  state VARCHAR(100) NOT NULL,
  city VARCHAR(100) NOT NULL,
  address TEXT NOT NULL,
  manager_name VARCHAR(255),
  manager_phone VARCHAR(50),
  coverage_zones JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Merchant Stock Allocations Table (3PL Stock Holding)
CREATE TABLE IF NOT EXISTS public.merchant_stock_allocations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  logistics_partner_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
  warehouse_hub_code VARCHAR(50) NOT NULL,
  physical_stock INT DEFAULT 0 CHECK (physical_stock >= 0),
  reserved_stock INT DEFAULT 0 CHECK (reserved_stock >= 0),
  available_stock INT DEFAULT 0 CHECK (available_stock >= 0),
  last_reconciled_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_merchant_hub_product UNIQUE (company_id, product_id, warehouse_hub_code)
);

-- 4. Create Stock Transfer Requests Table
CREATE TABLE IF NOT EXISTS public.stock_transfer_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  target_partner_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
  target_hub_code VARCHAR(50) NOT NULL,
  quantity_sent INT NOT NULL CHECK (quantity_sent > 0),
  quantity_received INT DEFAULT 0 CHECK (quantity_received >= 0),
  status VARCHAR(50) DEFAULT 'pending_dispatch',
  waybill_ref VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Enable Row Level Security (RLS) & Zero Data Leakage Policies
ALTER TABLE public.circuit_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.merchant_stock_allocations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_transfer_requests ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Tenant Isolation for Circuit Centers
CREATE POLICY "Tenant Circuit Centers Isolation" ON public.circuit_centers
  FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

-- RLS Policy: Tenant Isolation for Merchant Stock Allocations
CREATE POLICY "Tenant Stock Allocations Isolation" ON public.merchant_stock_allocations
  FOR ALL USING (
    company_id = (auth.jwt() ->> 'company_id')::uuid 
    OR logistics_partner_id = (auth.jwt() ->> 'company_id')::uuid
  );

-- RLS Policy: Tenant Isolation for Stock Transfer Requests
CREATE POLICY "Tenant Stock Transfer Isolation" ON public.stock_transfer_requests
  FOR ALL USING (
    company_id = (auth.jwt() ->> 'company_id')::uuid 
    OR target_partner_id = (auth.jwt() ->> 'company_id')::uuid
  );
