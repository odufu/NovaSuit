-- ============================================================================
-- Migration: 20260729000000_add_upsell_quantity_and_unit_price.sql
-- Description: Adds upsell_quantity and upsell_unit_price columns to orders table
-- ============================================================================

ALTER TABLE public.orders 
ADD COLUMN IF NOT EXISTS upsell_quantity INT NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS upsell_unit_price NUMERIC(12, 2) NOT NULL DEFAULT 0.00;

-- Comment for schema documentation
COMMENT ON COLUMN public.orders.upsell_quantity IS 'Extra units added (positive) or removed (negative) during upsell/downsell request';
COMMENT ON COLUMN public.orders.upsell_unit_price IS 'Price per unit agreed upon for the upsell/downsell combo';
