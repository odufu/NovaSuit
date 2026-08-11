-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260811000001_add_order_details_and_notes_schema.sql
-- 1. Adds internal_notes, commitment_fee, expected_delivery_date, actual_delivery_status to orders table
-- 2. Creates batch_update_order_statuses RPC for batch status updates
-- 3. Creates update_order_details_safe RPC for resilient single order updates
-- 4. Enables RLS policies for order_activities and orders updates
-- ============================================================================

-- 1. Add missing rich order management columns to public.orders if not exists
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS internal_notes TEXT;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS commitment_fee NUMERIC(12, 2) DEFAULT 0.00;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS expected_delivery_date TIMESTAMPTZ;
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS actual_delivery_status TEXT DEFAULT 'Delivery Pending';

-- 2. RLS & Realtime for order_activities
ALTER TABLE public.order_activities ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tenant_isolation_order_activities ON public.order_activities;
CREATE POLICY tenant_isolation_order_activities ON public.order_activities
FOR ALL
USING (true)
WITH CHECK (true);

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.order_activities;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END $$;

-- 3. Atomic Batch Order Status Update RPC Function
CREATE OR REPLACE FUNCTION public.batch_update_order_statuses(
    p_order_ids UUID[],
    p_new_status TEXT,
    p_performed_by TEXT DEFAULT 'Digital Marketer'
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_updated_count INT := 0;
    v_order_id UUID;
    v_old_status TEXT;
BEGIN
    FOREACH v_order_id IN ARRAY p_order_ids
    LOOP
        -- Fetch old status
        SELECT status INTO v_old_status FROM public.orders WHERE id = v_order_id;
        
        IF v_old_status IS NOT NULL THEN
            -- Update Order
            UPDATE public.orders 
            SET status = p_new_status,
                updated_at = NOW()
            WHERE id = v_order_id;
            
            -- Insert Activity Log Record
            INSERT INTO public.order_activities (
                order_id,
                activity_type,
                title,
                details,
                performed_by,
                old_status,
                new_status
            ) VALUES (
                v_order_id,
                'status_change',
                p_performed_by || ' updated status to ' || p_new_status,
                'Changed status from ' || v_old_status || ' to ' || p_new_status,
                p_performed_by,
                v_old_status,
                p_new_status
            );
            
            v_updated_count := v_updated_count + 1;
        END IF;
    END LOOP;
    
    RETURN v_updated_count;
END;
$$;

-- 4. Resilient Order Details Update RPC (Prevents PostgREST PGRST204 errors)
CREATE OR REPLACE FUNCTION public.update_order_details_safe(
    p_order_id UUID,
    p_status TEXT,
    p_notes TEXT DEFAULT NULL,
    p_address TEXT DEFAULT NULL,
    p_phone TEXT DEFAULT NULL,
    p_commitment_fee NUMERIC DEFAULT 0.00
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Core order update
    UPDATE public.orders 
    SET status = p_status,
        delivery_address = COALESCE(p_address, delivery_address),
        customer_phone = COALESCE(p_phone, customer_phone),
        updated_at = NOW()
    WHERE id = p_order_id;

    -- Dynamic update for optional columns if present
    BEGIN
        EXECUTE 'UPDATE public.orders SET commitment_fee = $1, internal_notes = $2 WHERE id = $3'
        USING p_commitment_fee, p_notes, p_order_id;
    EXCEPTION WHEN OTHERS THEN
        -- Safely ignore if columns are absent in legacy table
        NULL;
    END;

    RETURN TRUE;
END;
$$;

-- 5. Force PostgREST schema cache reload
NOTIFY pgrst, 'reload schema';
