-- Supabase Migration: 20260801000000_add_multi_tier_commission_settings.sql
-- Description: Supports Operations/GM commission settings for Sales Reps, Supervisors, AHODs, and HODs (Fixed Value or Percentage), with global incentive ON/OFF master toggle.

-- 1. Create company commission settings table for Operations/GM configuration
CREATE TABLE IF NOT EXISTS company_commission_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE UNIQUE,
    incentives_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Sales Rep Settings
    rep_commission_type TEXT NOT NULL DEFAULT 'fixed_per_unit' CHECK (rep_commission_type IN ('fixed_per_unit', 'percentage')),
    rep_commission_value NUMERIC(10, 2) NOT NULL DEFAULT 1000.00,
    
    -- Team Leader (Supervisor) Settings
    supervisor_commission_type TEXT NOT NULL DEFAULT 'fixed_per_unit' CHECK (supervisor_commission_type IN ('fixed_per_unit', 'percentage')),
    supervisor_commission_value NUMERIC(10, 2) NOT NULL DEFAULT 250.00,
    
    -- Assistant Head of Department (AHOD) Settings
    ahod_commission_type TEXT NOT NULL DEFAULT 'fixed_per_unit' CHECK (ahod_commission_type IN ('fixed_per_unit', 'percentage')),
    ahod_commission_value NUMERIC(10, 2) NOT NULL DEFAULT 150.00,
    
    -- Head of Department (HOD) Settings
    hod_commission_type TEXT NOT NULL DEFAULT 'fixed_per_unit' CHECK (hod_commission_type IN ('fixed_per_unit', 'percentage')),
    hod_commission_value NUMERIC(10, 2) NOT NULL DEFAULT 100.00,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Add AHOD and HOD mapping columns to user_roles
ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS ahod_id UUID REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE user_roles ADD COLUMN IF NOT EXISTS hod_id UUID REFERENCES users(id) ON DELETE SET NULL;

-- 3. Extend commissions table check constraints for recipient roles
ALTER TABLE commissions DROP CONSTRAINT IF EXISTS commissions_recipient_role_check;
ALTER TABLE commissions ADD CONSTRAINT commissions_recipient_role_check 
    CHECK (recipient_role IN ('sales_call_rep', 'sales_supervisor', 'ahod', 'hod'));

-- 4. Function & Trigger for Multi-Tier Automated Commissions
CREATE OR REPLACE FUNCTION process_order_delivered_commissions()
RETURNS TRIGGER AS $$
DECLARE
    v_setting RECORD;
    v_rep_id UUID;
    v_supervisor_id UUID;
    v_ahod_id UUID;
    v_hod_id UUID;
    v_company_id UUID;
    v_qty INT;
    v_total_amount NUMERIC(10, 2);
    
    v_rep_comm NUMERIC(10, 2);
    v_sup_comm NUMERIC(10, 2);
    v_ahod_comm NUMERIC(10, 2);
    v_hod_comm NUMERIC(10, 2);
BEGIN
    IF NEW.status = 'delivered' AND (OLD.status IS NULL OR OLD.status != 'delivered') THEN
        v_rep_id := NEW.sales_rep_id;
        v_company_id := NEW.company_id;
        v_qty := COALESCE(NEW.quantity, 1);
        v_total_amount := COALESCE(NEW.total_amount, 0.0);

        -- Fetch Operations / GM Commission Settings
        SELECT * INTO v_setting
        FROM company_commission_settings
        WHERE company_id = v_company_id
        LIMIT 1;

        -- If incentives are disabled by Operations, skip commission generation
        IF v_setting.id IS NOT NULL AND v_setting.incentives_enabled = FALSE THEN
            RETURN NEW;
        END IF;

        -- Fetch hierarchy mappings (Supervisor, AHOD, HOD) for the sales rep
        IF v_rep_id IS NOT NULL THEN
            SELECT supervisor_id, ahod_id, hod_id 
            INTO v_supervisor_id, v_ahod_id, v_hod_id
            FROM user_roles
            WHERE user_id = v_rep_id AND company_id = v_company_id
            LIMIT 1;
        END IF;

        -- Calculate Sales Rep Commission
        IF v_setting.rep_commission_type = 'percentage' THEN
            v_rep_comm := (v_total_amount * COALESCE(v_setting.rep_commission_value, 5.0)) / 100.0;
        ELSE
            v_rep_comm := v_qty * COALESCE(v_setting.rep_commission_value, 1000.00);
        END IF;

        -- Calculate Supervisor Commission
        IF v_setting.supervisor_commission_type = 'percentage' THEN
            v_sup_comm := (v_total_amount * COALESCE(v_setting.supervisor_commission_value, 1.5)) / 100.0;
        ELSE
            v_sup_comm := v_qty * COALESCE(v_setting.supervisor_commission_value, 250.00);
        END IF;

        -- Calculate AHOD Commission
        IF v_setting.ahod_commission_type = 'percentage' THEN
            v_ahod_comm := (v_total_amount * COALESCE(v_setting.ahod_commission_value, 0.8)) / 100.0;
        ELSE
            v_ahod_comm := v_qty * COALESCE(v_setting.ahod_commission_value, 150.00);
        END IF;

        -- Calculate HOD Commission
        IF v_setting.hod_commission_type = 'percentage' THEN
            v_hod_comm := (v_total_amount * COALESCE(v_setting.hod_commission_value, 0.5)) / 100.0;
        ELSE
            v_hod_comm := v_qty * COALESCE(v_setting.hod_commission_value, 100.00);
        END IF;

        -- 1. Insert Sales Rep Commission Record
        IF v_rep_id IS NOT NULL THEN
            INSERT INTO commissions (
                company_id, user_id, supervisor_id, order_id, recipient_role,
                product_id, quantity, unit_commission_rate, total_commission, status
            ) VALUES (
                v_company_id, v_rep_id, v_supervisor_id, NEW.id, 'sales_call_rep',
                NEW.product_id, v_qty, COALESCE(v_setting.rep_commission_value, 1000.00), v_rep_comm, 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
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
                NEW.product_id, v_qty, COALESCE(v_setting.supervisor_commission_value, 250.00), v_sup_comm, 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
                total_commission = EXCLUDED.total_commission,
                updated_at = NOW();
        END IF;

        -- 3. Insert AHOD Commission Record
        IF v_ahod_id IS NOT NULL THEN
            INSERT INTO commissions (
                company_id, user_id, supervisor_id, order_id, recipient_role,
                product_id, quantity, unit_commission_rate, total_commission, status
            ) VALUES (
                v_company_id, v_ahod_id, v_supervisor_id, NEW.id, 'ahod',
                NEW.product_id, v_qty, COALESCE(v_setting.ahod_commission_value, 150.00), v_ahod_comm, 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
                total_commission = EXCLUDED.total_commission,
                updated_at = NOW();
        END IF;

        -- 4. Insert HOD Commission Record
        IF v_hod_id IS NOT NULL THEN
            INSERT INTO commissions (
                company_id, user_id, supervisor_id, order_id, recipient_role,
                product_id, quantity, unit_commission_rate, total_commission, status
            ) VALUES (
                v_company_id, v_hod_id, v_supervisor_id, NEW.id, 'hod',
                NEW.product_id, v_qty, COALESCE(v_setting.hod_commission_value, 100.00), v_hod_comm, 'earned'
            )
            ON CONFLICT (order_id, user_id, recipient_role) DO UPDATE SET
                total_commission = EXCLUDED.total_commission,
                updated_at = NOW();
        END IF;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
