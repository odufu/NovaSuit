-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000004_seed_onboarded_products_and_linked_items.sql
-- Onboarded Product Catalog Table, Indexes, RLS, and Seed Data for NovaCare
-- ============================================================================

-- 1. Create Products Table (if not existing)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    sku TEXT UNIQUE NOT NULL,
    category TEXT NOT NULL DEFAULT 'Herbal Wellness',
    base_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    cost_price NUMERIC(12, 2) DEFAULT 0.00,
    stock_quantity INT NOT NULL DEFAULT 100,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Index for Fast Product Search
CREATE INDEX IF NOT EXISTS idx_products_company ON public.products(company_id);
CREATE INDEX IF NOT EXISTS idx_products_sku ON public.products(sku);
CREATE INDEX IF NOT EXISTS idx_products_name ON public.products(name);

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Multi-Tenancy
CREATE POLICY products_tenant_policy ON public.products
    FOR ALL USING (company_id = (auth.jwt() ->> 'company_id')::uuid);

CREATE POLICY public_read_products ON public.products
    FOR SELECT USING (is_active = true);

-- 2. Seed Onboarded Products for NovaCare Health & Wellness
INSERT INTO public.products (id, company_id, name, sku, category, base_price, stock_quantity, description)
VALUES
  (
    'p0000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'Grazer Herbal Tea',
    'GHT-001',
    'Grazer Herbal Tea',
    23500.00,
    500,
    'Organic herbal detox tea for colon cleansing and digestive health.'
  ),
  (
    'p0000000-0000-0000-0000-000000000002',
    'c0000000-0000-0000-0000-000000000001',
    'Vitality Detox Booster',
    'VDB-002',
    'Vitality Booster',
    35000.00,
    350,
    'High-potency herbal extract liquid booster for instant stamina.'
  ),
  (
    'p0000000-0000-0000-0000-000000000003',
    'c0000000-0000-0000-0000-000000000001',
    'SkinCare Glow Capsule',
    'SGC-003',
    'SkinCare Glow',
    18000.00,
    420,
    'Natural anti-oxidant capsules for radiant skin tone.'
  ),
  (
    'p0000000-0000-0000-0000-000000000004',
    'c0000000-0000-0000-0000-000000000001',
    'Flat Belly Tea Cleanse',
    'FBT-004',
    'Grazer Herbal Tea',
    28000.00,
    300,
    'Targeted 14-day flat belly slimming tea.'
  )
ON CONFLICT (sku) DO UPDATE SET
  name = EXCLUDED.name,
  base_price = EXCLUDED.base_price,
  stock_quantity = EXCLUDED.stock_quantity;
