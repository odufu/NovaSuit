-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260809000005_add_cross_product_addons_schema.sql
-- Seed Respira Clear Detox Product & Support Multi-Product Inventory Accounting
-- ============================================================================

-- 1. Seed Respira Clear Detox Product into public.products Catalog
INSERT INTO public.products (id, company_id, name, sku, category, base_price, stock_quantity, description)
VALUES
  (
    'p0000000-0000-0000-0000-000000000005',
    'c0000000-0000-0000-0000-000000000001',
    'Respira Clear Detox',
    'RCD-005',
    'Respiratory Health',
    15000.00,
    400,
    'Herbal lung and respiratory system cleanser capsules.'
  )
ON CONFLICT (sku) DO UPDATE SET
  name = EXCLUDED.name,
  base_price = EXCLUDED.base_price,
  stock_quantity = EXCLUDED.stock_quantity;

-- 2. Create order_items Table for Multi-Product Bundle Packing Slips
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    sku TEXT,
    item_type TEXT NOT NULL DEFAULT 'Main', -- 'Main', 'SameItemFree', 'CrossProductFreeGift', 'Addon'
    quantity INT NOT NULL DEFAULT 1,
    unit_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    total_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON public.order_items(product_id);

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY order_items_tenant_policy ON public.order_items
    FOR ALL USING (true);
