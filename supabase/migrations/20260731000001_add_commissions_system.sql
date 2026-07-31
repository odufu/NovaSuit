-- Supabase Migration: 20260731000001_add_commissions_system.sql
-- Description: Adds product commission rates, supervisor hierarchy mapping, commissions ledger table, and automated commission calculation trigger on order delivery.

-- 1. Add commission rates to products table
ALTER TABLE products ADD COLUMN IF NOT EXISTS rep_commission_per_unit NUMERIC(10, 2) DEFAULT 1000.00;
ALTER TABLE products ADD COLUMN IF NOT EXISTS supervisor_commission_per_unit NUMERIC(10, 2) DEFAULT 250.00;

-- Update existing product rows with default commission rates
UPDATE products 
SET rep_commission_per_unit = 1000.00, 
    supervisor_commission_per_unit = 250.00
WHERE rep_commission_per_unit IS NULL;

-- 2. Add supervisor_id column to user_roles table to link Sales Reps to their Team Leaders
ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS supervisor_id UUID REFERENCES users(id) ON DELETE SET NULL;

-- 3. Create commissions table for ledger tracking
CREATE TABLE IF NOT EXISTS commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    supervisor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    recipient_role TEXT NOT NULL CHECK (recipient_role IN ('sales_call_rep', 'sales_supervisor')),
    product_id TEXT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_commission_rate NUMERIC(10, 2) NOT NULL,
    total_commission NUMERIC(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'earned' CHECK (status IN ('earned', 'paid', 'clawback')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(order_id, user_id, recipient_role)
);

-- Index for fast user/supervisor commission lookups
CREATE INDEX IF NOT EXISTS idx_commissions_user_id ON commissions(user_id);
CREATE INDEX IF NOT EXISTS idx_commissions_supervisor_id ON commissions(supervisor_id);
CREATE INDEX IF NOT EXISTS idx_commissions_company_id ON commissions(company_id);

-- 4. PostgreSQL Trigger Function to auto-calculate Commissions when an Order is Delivered
CREATE OR REPLACE FUNCTION process_order_delivered_commissions()
RETURNS TRIGGER AS $$
DECLARE
    v_rep_commission_rate NUMERIC(10, 2);
    v_supervisor_commission_rate NUMERIC(10, 2);
    v_supervisor_id UUID;
    v_rep_id UUID;
    v_company_id UUID;
    v_qty INT;
BEGIN
    -- Only trigger when order status transitions to 'delivered'
    IF NEW.status = 'delivered' AND (OLD.status IS NULL OR OLD.status != 'delivered') THEN
        v_rep_id := NEW.sales_rep_id;
        v_company_id := NEW.company_id;
        v_qty := COALESCE(NEW.quantity, 1);

        -- Fetch product commission settings
        SELECT rep_commission_per_unit, supervisor_commission_per_unit 
        INTO v_rep_commission_rate, v_supervisor_commission_rate
        FROM products 
        WHERE id::text = NEW.product_id OR name = NEW.product_id
        LIMIT 1;

        -- Defaults if product rates not explicitly set
        v_rep_commission_rate := COALESCE(v_rep_commission_rate, 1000.00);
        v_supervisor_commission_rate := COALESCE(v_supervisor_commission_rate, 250.00);

        -- Fetch supervisor_id for the sales rep
        IF v_rep_id IS NOT NULL THEN
            SELECT supervisor_id INTO v_supervisor_id
            FROM user_roles
            WHERE user_id = v_rep_id AND company_id = v_company_id
            LIMIT 1;
        END IF;

        -- 1. Insert Sales Rep Commission Record
        IF v_rep_id IS NOT NULL THEN
            INSERT INTO commissions (
                company_id, user_id, supervisor_id, order_id, recipient_role,
                product_id, quantity, unit_commission_rate, total_commission, status
            ) VALUES (
                v_company_id, v_rep_id, v_supervisor_id, NEW.id, 'sales_call_rep',
                NEW.product_id, v_qty, v_rep_commission_rate, (v_qty * v_rep_commission_rate), 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
                quantity = EXCLUDED.quantity,
                total_commission = EXCLUDED.total_commission,
                updated_at = NOW();
        END IF;

        -- 2. Insert Supervisor Cumulative Override Commission Record
        IF v_supervisor_id IS NOT NULL THEN
            INSERT INTO commissions (
                company_id, user_id, supervisor_id, order_id, recipient_role,
                product_id, quantity, unit_commission_rate, total_commission, status
            ) VALUES (
                v_company_id, v_supervisor_id, v_supervisor_id, NEW.id, 'sales_supervisor',
                NEW.product_id, v_qty, v_supervisor_commission_rate, (v_qty * v_supervisor_commission_rate), 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
                quantity = EXCLUDED.quantity,
                total_commission = EXCLUDED.total_commission,
                updated_at = NOW();
        END IF;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Bind Trigger to Orders table
DROP TRIGGER IF EXISTS trg_order_delivered_commissions ON orders;
CREATE TRIGGER trg_order_delivered_commissions
    AFTER INSERT OR UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION process_order_delivered_commissions();
