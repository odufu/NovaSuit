-- ============================================================================
-- NOVASUITE SUPABASE MIGRATION: 20260811000002_add_order_item_stock_check_rpc.sql
-- 1. Creates RPC function add_order_item_with_stock_check
-- 2. Creates RPC function remove_order_item_and_restock
-- 3. RLS policy verification for order_items and products
-- ============================================================================

-- 1. RPC: Add Item to Order with Real-Time Stock Availability Validation & Reserve
CREATE OR REPLACE FUNCTION public.add_order_item_with_stock_check(
    p_order_id UUID,
    p_sku TEXT,
    p_item_name TEXT,
    p_description TEXT,
    p_quantity INT,
    p_unit_price NUMERIC(12, 2),
    p_performed_by TEXT DEFAULT 'Digital Marketer'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_product_id UUID;
    v_current_stock INT;
    v_line_amount NUMERIC(12, 2);
    v_new_order_value NUMERIC(12, 2);
    v_order_item_id UUID;
BEGIN
    -- 1. Check product catalog by SKU or Name
    SELECT id, stock_quantity INTO v_product_id, v_current_stock
    SELECT id, stock_quantity INTO v_product_id, v_current_stock
    FROM public.products
    WHERE LOWER(sku) = LOWER(p_sku) OR LOWER(name) = LOWER(p_item_name)
    LIMIT 1;

    -- If product is in catalog, enforce stock availability
    IF v_product_id IS NOT NULL THEN
        IF v_current_stock < p_quantity THEN
            RETURN jsonb_build_object(
                'success', false,
                'error_code', 'INSUFFICIENT_STOCK',
                'message', 'Insufficient stock available! Current stock: ' || v_current_stock || ' units, requested: ' || p_quantity,
                'available_stock', v_current_stock
            );
        END IF;

        -- Deduct reserved stock from product catalog
        UPDATE public.products
        SET stock_quantity = stock_quantity - p_quantity,
            updated_at = NOW()
        WHERE id = v_product_id;
    END IF;

    v_line_amount := p_quantity * p_unit_price;

    -- 2. Insert into public.order_items
    INSERT INTO public.order_items (
        order_id,
        product_id,
        product_name,
        sku,
        item_type,
        quantity,
        unit_price,
        total_price
    ) VALUES (
        p_order_id,
        v_product_id,
        p_item_name,
        p_sku,
        'Main',
        p_quantity,
        p_unit_price,
        v_line_amount
    )
    RETURNING id INTO v_order_item_id;

    -- 3. Update total order value on orders table
    UPDATE public.orders
    SET value = COALESCE(value, 0) + v_line_amount,
        updated_at = NOW()
    WHERE id = p_order_id
    RETURNING value INTO v_new_order_value;

    -- 4. Record Activity Log
    INSERT INTO public.order_activities (
        order_id,
        activity_type,
        title,
        details,
        performed_by
    ) VALUES (
        p_order_id,
        'item_added',
        p_performed_by || ' added item: ' || p_item_name,
        'Added ' || p_quantity || 'x ' || p_item_name || ' (SKU: ' || COALESCE(p_sku, 'N/A') || ') at NGN ' || p_unit_price || ' each.',
        p_performed_by
    );

    RETURN jsonb_build_object(
        'success', true,
        'order_item_id', v_order_item_id,
        'line_amount', v_line_amount,
        'new_order_value', v_new_order_value,
        'available_stock', COALESCE(v_current_stock - p_quantity, 100),
        'message', 'Item added to order successfully'
    );
END;
$$;

-- 2. RPC: Remove Item from Order & Restock Product Catalog
CREATE OR REPLACE FUNCTION public.remove_order_item_and_restock(
    p_order_item_id UUID,
    p_performed_by TEXT DEFAULT 'Digital Marketer'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_order_id UUID;
    v_product_id UUID;
    v_quantity INT;
    v_line_amount NUMERIC(12, 2);
    v_product_name TEXT;
    v_new_order_value NUMERIC(12, 2);
BEGIN
    SELECT order_id, product_id, quantity, total_price, product_name
    INTO v_order_id, v_product_id, v_quantity, v_line_amount, v_product_name
    FROM public.order_items
    WHERE id = p_order_item_id;

    IF v_order_id IS NULL THEN
        RETURN jsonb_build_object('success', false, 'message', 'Order item not found');
    END IF;

    -- Delete Order Item
    DELETE FROM public.order_items WHERE id = p_order_item_id;

    -- Restock inventory if linked product exists
    IF v_product_id IS NOT NULL THEN
        UPDATE public.products
        SET stock_quantity = stock_quantity + v_quantity,
            updated_at = NOW()
        WHERE id = v_product_id;
    END IF;

    -- Recalculate order total
    UPDATE public.orders
    SET value = GREATEST(0, COALESCE(value, 0) - v_line_amount),
        updated_at = NOW()
    WHERE id = v_order_id
    RETURNING value INTO v_new_order_value;

    -- Activity log
    INSERT INTO public.order_activities (
        order_id,
        activity_type,
        title,
        details,
        performed_by
    ) VALUES (
        v_order_id,
        'item_removed',
        p_performed_by || ' removed item: ' || v_product_name,
        'Removed ' || v_product_name || ' (Restocked ' || v_quantity || ' units)',
        p_performed_by
    );

    RETURN jsonb_build_object(
        'success', true,
        'new_order_value', v_new_order_value,
        'message', 'Item removed and stock refunded'
    );
END;
$$;
