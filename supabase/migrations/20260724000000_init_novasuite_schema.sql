-- ============================================================================
-- NOVASUITE CRM & NOVAEXPRESS LOGISTICS SYSTEM SCHEMA
-- Multi-Tenant, White-Label, High-Scale Database Initialization (Idempotent)
-- ============================================================================

-- Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- 1. TENANTS & BRANDING (Companies & Whitelabel Settings)
-- ============================================================================

CREATE TABLE IF NOT EXISTS companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) DEFAULT 'marketing' CHECK (type IN ('marketing', 'logistics', 'hybrid')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tenant_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID UNIQUE NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    app_title VARCHAR(100) DEFAULT 'NovaSuite CRM',
    logo_url TEXT,
    favicon_url TEXT,
    primary_color VARCHAR(10) DEFAULT '#1B4D3E',
    secondary_color VARCHAR(10) DEFAULT '#D4AF37',
    accent_color VARCHAR(10) DEFAULT '#E67E22',
    background_color VARCHAR(10) DEFAULT '#F8F9FA',
    font_family VARCHAR(50) DEFAULT 'Outfit',
    custom_domain VARCHAR(255),
    currency_code VARCHAR(10) DEFAULT 'NGN',
    currency_symbol VARCHAR(5) DEFAULT '₦',
    sms_sender_id VARCHAR(11) DEFAULT 'NOVASUITE',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 2. DEPARTMENTS & USER ROLES
-- ============================================================================

CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    supervisor_id UUID, -- Circular FK added safely below
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_user_id UUID UNIQUE, -- Links to supabase auth.users
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
    supervisor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN (
        'super_admin', 'agm', 'hr_manager', 'inventory_manager', 'supervisor', 'sales_call_rep', 
        'logistics_call_rep', 'digital_marketer', 'delivery_agent', 'finance_manager'
    )),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add circular foreign key for department supervisor safely
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_department_supervisor'
    ) THEN
        ALTER TABLE departments 
        ADD CONSTRAINT fk_department_supervisor 
        FOREIGN KEY (supervisor_id) REFERENCES users(id) ON DELETE SET NULL;
    END IF;
END $$;

-- Call Rep Stats (for atomic round-robin)
CREATE TABLE IF NOT EXISTS call_rep_stats (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    pending_orders_count INT DEFAULT 0 CHECK (pending_orders_count >= 0),
    total_assigned_count INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    last_assigned_at TIMESTAMPTZ
);

-- ============================================================================
-- 3. PRODUCTS & DIGITAL MARKETING
-- ============================================================================

CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    base_price NUMERIC(12, 2) NOT NULL CHECK (base_price >= 0),
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_call_reps (
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (product_id, user_id)
);

CREATE TABLE IF NOT EXISTS marketer_budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    marketer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    funded_by_agm_id UUID NOT NULL REFERENCES users(id),
    amount_funded NUMERIC(12, 2) NOT NULL CHECK (amount_funded >= 0),
    current_balance NUMERIC(12, 2) NOT NULL DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ad_campaigns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    marketer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    campaign_name VARCHAR(255) NOT NULL,
    platform VARCHAR(50) DEFAULT 'facebook',
    ad_spend NUMERIC(12, 2) DEFAULT 0,
    pixel_id VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS campaign_forms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    campaign_id UUID REFERENCES ad_campaigns(id) ON DELETE CASCADE,
    marketer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    form_title VARCHAR(255) NOT NULL,
    redirect_url TEXT NOT NULL,
    success_message TEXT DEFAULT 'Thanks! Our concierge team will confirm shortly.',
    submit_button_text VARCHAR(100) DEFAULT 'Submit request',
    quantity_display_mode VARCHAR(50) DEFAULT 'number',
    preset_country VARCHAR(100) DEFAULT 'Nigeria',
    description TEXT,
    field_options JSONB DEFAULT '{}'::jsonb,
    appearance_options JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 4. LOGISTICS PROVIDERS, WAREHOUSES & INVENTORY
-- ============================================================================

CREATE TABLE IF NOT EXISTS delivery_agencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) CHECK (type IN ('in_house', 'third_party_agency', 'independent')),
    commission_per_delivery NUMERIC(10, 2) DEFAULT 0,
    contact_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS delivery_agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    agency_id UUID REFERENCES delivery_agencies(id) ON DELETE SET NULL,
    agent_type VARCHAR(50) CHECK (agent_type IN ('agency_rider', 'independent_rider')),
    coverage_states TEXT[] DEFAULT '{}',
    current_cod_balance NUMERIC(12, 2) DEFAULT 0 CHECK (current_cod_balance >= 0),
    max_cod_credit_limit NUMERIC(12, 2) DEFAULT 150000.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS warehouses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    agency_id UUID REFERENCES delivery_agencies(id),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) CHECK (type IN ('central_factory', 'agency_regional_hub', 'rider_mini_hub')),
    state VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    address TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS warehouse_inventory (
    warehouse_id UUID REFERENCES warehouses(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    available_stock INT DEFAULT 0 CHECK (available_stock >= 0),
    allocated_stock INT DEFAULT 0 CHECK (allocated_stock >= 0),
    in_transit_stock INT DEFAULT 0 CHECK (in_transit_stock >= 0),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (warehouse_id, product_id)
);

-- ============================================================================
-- 5. ORDERS & SALES DIALER PIPELINE
-- ============================================================================

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    marketer_id UUID REFERENCES users(id),
    campaign_id UUID REFERENCES ad_campaigns(id),
    form_id UUID REFERENCES campaign_forms(id),
    sales_rep_id UUID REFERENCES users(id),
    logistics_rep_id UUID REFERENCES users(id),
    delivery_agent_id UUID REFERENCES delivery_agents(id),
    warehouse_id UUID REFERENCES warehouses(id),
    
    -- Customer Info
    customer_name VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(50) NOT NULL,
    customer_alt_phone VARCHAR(50),
    delivery_state VARCHAR(100) NOT NULL,
    delivery_city VARCHAR(100),
    delivery_address TEXT NOT NULL,
    
    -- Status Pipeline
    status VARCHAR(50) DEFAULT 'new' CHECK (status IN (
        'new', 'assigned_to_rep', 'contacting', 'accepted', 
        'on_hold', 'cancelled', 'upsell_pending', 'logistics_confirmed', 
        'agent_notified', 'in_transit', 'delivered', 'returned', 'failed_delivery'
    )),
    
    -- Pricing & Financials
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    base_price NUMERIC(12, 2) NOT NULL,
    upsell_amount NUMERIC(12, 2) DEFAULT 0,
    downsell_discount NUMERIC(12, 2) DEFAULT 0,
    total_amount NUMERIC(12, 2) NOT NULL,
    
    -- Upsell Approval
    upsell_status VARCHAR(50) DEFAULT 'none' CHECK (upsell_status IN ('none', 'pending', 'approved', 'rejected')),
    upsell_notes TEXT,
    approved_by_supervisor_id UUID REFERENCES users(id),
    
    -- Payment & Delivery Proof
    payment_type VARCHAR(50) DEFAULT 'pay_on_delivery',
    payment_status VARCHAR(50) DEFAULT 'pending' CHECK (payment_status IN ('pending', 'collected', 'remitted')),
    proof_of_delivery_url TEXT,
    delivery_notes TEXT,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 6. STOCK TRANSFERS & COD REMITTANCES
-- ============================================================================

CREATE TABLE IF NOT EXISTS stock_transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    waybill_number VARCHAR(100) UNIQUE NOT NULL,
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    source_warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    destination_warehouse_id UUID NOT NULL REFERENCES warehouses(id),
    initiated_by_user_id UUID NOT NULL REFERENCES users(id),
    received_by_user_id UUID REFERENCES users(id),
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'dispatched', 'partially_received', 'completed', 'cancelled')),
    dispatch_date TIMESTAMPTZ,
    received_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS stock_transfer_items (
    transfer_id UUID REFERENCES stock_transfers(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity_shipped INT NOT NULL CHECK (quantity_shipped > 0),
    quantity_received INT DEFAULT 0 CHECK (quantity_received >= 0),
    PRIMARY KEY (transfer_id, product_id)
);

CREATE TABLE IF NOT EXISTS cash_remittances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    delivery_agent_id UUID NOT NULL REFERENCES delivery_agents(id),
    amount_remitted NUMERIC(12, 2) NOT NULL CHECK (amount_remitted > 0),
    deposit_receipt_url TEXT NOT NULL,
    bank_reference VARCHAR(100),
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'verified', 'rejected')),
    verified_by_user_id UUID REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    verified_at TIMESTAMPTZ
);

-- ============================================================================
-- 7. PL/PGSQL ATOMIC ROUND-ROBIN ASSIGNMENT ALGORITHM
-- ============================================================================

CREATE OR REPLACE FUNCTION assign_order_round_robin(
    p_order_id UUID,
    p_product_id UUID
) RETURNS UUID AS $$
DECLARE
    v_sales_rep_id UUID;
BEGIN
    SELECT pcr.user_id INTO v_sales_rep_id
    FROM product_call_reps pcr
    JOIN call_rep_stats crs ON crs.user_id = pcr.user_id
    JOIN users u ON u.id = pcr.user_id
    WHERE pcr.product_id = p_product_id 
      AND crs.is_active = TRUE 
      AND u.is_active = TRUE
    ORDER BY crs.pending_orders_count ASC, crs.last_assigned_at ASC NULLS FIRST
    LIMIT 1
    FOR UPDATE OF crs;

    IF v_sales_rep_id IS NOT NULL THEN
        UPDATE orders 
        SET sales_rep_id = v_sales_rep_id, 
            status = 'assigned_to_rep',
            updated_at = NOW()
        WHERE id = p_order_id;

        UPDATE call_rep_stats 
        SET pending_orders_count = pending_orders_count + 1,
            total_assigned_count = total_assigned_count + 1,
            last_assigned_at = NOW()
        WHERE user_id = v_sales_rep_id;
    END IF;

    RETURN v_sales_rep_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE warehouse_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_transfers ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_remittances ENABLE ROW LEVEL SECURITY;
ALTER TABLE campaign_forms ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION current_company_id() RETURNS UUID AS $$
    SELECT NULLIF(current_setting('request.jwt.claims', true)::json->>'company_id', '')::uuid;
$$ LANGUAGE sql STABLE;

DROP POLICY IF EXISTS tenant_isolation_orders ON orders;
CREATE POLICY tenant_isolation_orders ON orders FOR ALL
    USING (company_id = current_company_id())
    WITH CHECK (company_id = current_company_id());

DROP POLICY IF EXISTS tenant_isolation_products ON products;
CREATE POLICY tenant_isolation_products ON products FOR ALL
    USING (company_id = current_company_id())
    WITH CHECK (company_id = current_company_id());

DROP POLICY IF EXISTS tenant_isolation_users ON users;
CREATE POLICY tenant_isolation_users ON users FOR ALL
    USING (company_id = current_company_id())
    WITH CHECK (company_id = current_company_id());

DROP POLICY IF EXISTS tenant_isolation_warehouses ON warehouses;
CREATE POLICY tenant_isolation_warehouses ON warehouses FOR ALL
    USING (company_id = current_company_id())
    WITH CHECK (company_id = current_company_id());

DROP POLICY IF EXISTS tenant_isolation_transfers ON stock_transfers;
CREATE POLICY tenant_isolation_transfers ON stock_transfers FOR ALL
    USING (company_id = current_company_id())
    WITH CHECK (company_id = current_company_id());

DROP POLICY IF EXISTS tenant_isolation_remittances ON cash_remittances;
CREATE POLICY tenant_isolation_remittances ON cash_remittances FOR ALL
    USING (company_id = current_company_id())
    WITH CHECK (company_id = current_company_id());

DROP POLICY IF EXISTS tenant_isolation_forms ON campaign_forms;
CREATE POLICY tenant_isolation_forms ON campaign_forms FOR ALL
    USING (company_id = current_company_id())
    WITH CHECK (company_id = current_company_id());

-- ============================================================================
-- 9. SUPABASE REALTIME PUBLICATION SETUP
-- ============================================================================

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE orders, cash_remittances, stock_transfers;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END $$;
