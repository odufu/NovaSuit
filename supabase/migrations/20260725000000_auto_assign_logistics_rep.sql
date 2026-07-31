-- ============================================================================
-- Migration: 20260725000000_auto_assign_logistics_rep.sql
-- Description: State-Based Auto-Assignment Engine & Reassignment RPC for NovaSuite
-- ============================================================================

-- 1. Create State-to-Hub/Logistics-Rep Mapping Table
CREATE TABLE IF NOT EXISTS public.state_hub_mappings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID REFERENCES public.companies(id) ON DELETE CASCADE,
    state_name TEXT NOT NULL,
    assigned_logistics_rep_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    assigned_hub_id UUID REFERENCES public.warehouses(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(company_id, state_name)
);

-- Index for fast state lookup
CREATE INDEX IF NOT EXISTS idx_state_hub_mappings_state ON public.state_hub_mappings(LOWER(state_name));

-- 2. Create Trigger Function for Automatic Logistics Rep Assignment
CREATE OR REPLACE FUNCTION public.auto_assign_logistics_rep_func()
RETURNS TRIGGER AS $$
DECLARE
    v_target_rep_id UUID;
    v_target_hub_id UUID;
BEGIN
    -- Only trigger when order moves to 'accepted' status and logistics_rep_id is not already manually assigned
    IF NEW.status = 'accepted' AND (NEW.logistics_rep_id IS NULL OR OLD.status != 'accepted') THEN
        
        -- Step A: Search for State-Specific Logistics Rep Mapping
        SELECT assigned_logistics_rep_id, assigned_hub_id 
        INTO v_target_rep_id, v_target_hub_id
        FROM public.state_hub_mappings
        WHERE company_id = NEW.company_id 
          AND LOWER(state_name) = LOWER(NEW.delivery_state)
        LIMIT 1;

        -- Step B: If no specific state mapping found, fallback to Round-Robin assigned Logistics Call Rep
        IF v_target_rep_id IS NULL THEN
            SELECT id INTO v_target_rep_id
            FROM public.users
            WHERE company_id = NEW.company_id 
              AND role = 'logistics_call_rep'
              AND is_active = TRUE
            ORDER BY created_at ASC
            LIMIT 1;
        END IF;

        -- Assign the resolved logistics rep & hub to the order
        IF v_target_rep_id IS NOT NULL THEN
            NEW.logistics_rep_id := v_target_rep_id;
        END IF;

        IF v_target_hub_id IS NOT NULL THEN
            NEW.warehouse_id := v_target_hub_id;
        END IF;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if already exists to ensure clean application
DROP TRIGGER IF EXISTS trigger_auto_assign_logistics_rep ON public.orders;

-- Create Trigger on Orders table
CREATE TRIGGER trigger_auto_assign_logistics_rep
    BEFORE INSERT OR UPDATE OF status ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION public.auto_assign_logistics_rep_func();

-- 3. RPC Function for Manual Logistics Rep Reassignment
CREATE OR REPLACE FUNCTION public.reassign_logistics_rep(
    p_order_id UUID,
    p_new_logistics_rep_id UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_order public.orders%ROWTYPE;
BEGIN
    -- Verify order exists
    SELECT * INTO v_order FROM public.orders WHERE id = p_order_id;
    IF v_order.id IS NULL THEN
        RAISE EXCEPTION 'Order not found with ID %', p_order_id;
    END IF;

    -- Update order with new logistics rep ID
    UPDATE public.orders
    SET logistics_rep_id = p_new_logistics_rep_id,
        delivery_notes = COALESCE(delivery_notes || E'\n', '') || 'Manual Reassignment Reason: ' || COALESCE(p_reason, 'No reason specified'),
        updated_at = NOW()
    WHERE id = p_order_id;

    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'new_logistics_rep_id', p_new_logistics_rep_id,
        'message', 'Logistics Rep successfully reassigned.'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
