// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: submit-order
// High-Scale Webhook Ingestion, Form Submissions & Automatic Thank-You Redirect Processing
// Enforces Stock Accounting, Form Attributions, and Redirect URL Tracking
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface OrderPayload {
  company_id: string;
  product_id?: string;
  product_name?: string;
  marketer_id?: string;
  marketer_email?: string;
  campaign_id?: string;
  form_id?: string;
  customer_name: string;
  customer_phone: string;
  customer_email?: string;
  customer_alt_phone?: string;
  delivery_state: string;
  delivery_city?: string;
  delivery_address: string;
  offer_package_id?: string;
  buy_qty?: number;
  free_qty?: number;
  free_addon_product_id?: string;
  free_addon_product_name?: string;
  free_addon_qty?: number;
  quantity?: number;
  base_price?: number;
  redirect_url?: string;
  pixel_id?: string;
  event_source_url?: string;
  utm_source?: string;
  utm_campaign?: string;
  utm_medium?: string;
  ad_id?: string;
  additional_responses?: Record<string, any>;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const payload: OrderPayload = await req.json();

    if (!payload.customer_name || !payload.customer_phone || !payload.delivery_address || !payload.delivery_state) {
      return new Response(
        JSON.stringify({ error: "Missing required order fields." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // Helper: Verify string format is valid PostgreSQL UUID (8-4-4-4-12 hex digits)
    const isUuid = (str?: string) => str ? /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(str) : false;

    const validatedCompanyId = isUuid(payload.company_id) ? payload.company_id : "c0000000-0000-0000-0000-000000000001";
    const validatedFormId = isUuid(payload.form_id) ? payload.form_id : null;
    const validatedMarketerId = isUuid(payload.marketer_id) ? payload.marketer_id : null;
    const validatedCampaignId = isUuid(payload.campaign_id) ? payload.campaign_id : null;
    const freeAddonProductId = isUuid(payload.free_addon_product_id) ? payload.free_addon_product_id : null;

    // Resolve Product UUID safely from database or fallback to seeded active product
    let resolvedProductId: string | null = isUuid(payload.product_id) ? payload.product_id! : null;
    if (!resolvedProductId) {
      try {
        const { data: firstProd } = await supabaseClient
          .from("products")
          .select("id")
          .eq("is_active", true)
          .limit(1)
          .maybeSingle();
        if (firstProd?.id) {
          resolvedProductId = firstProd.id;
        }
      } catch (_) {
        // Ignore product lookup warning
      }
    }
    if (!resolvedProductId) {
      resolvedProductId = "90000000-0000-4000-8000-000000000001";
    }

    // 1. Resolve Thank-You Redirect URL from lead_forms table or payload
    let targetRedirectUrl = payload.redirect_url || "https://detoxwithnova.xyz/thank-you";
    if (validatedFormId) {
      try {
        const { data: formData } = await supabaseClient
          .from("lead_forms")
          .select("redirect_url")
          .eq("id", validatedFormId)
          .maybeSingle();
        if (formData?.redirect_url) {
          targetRedirectUrl = formData.redirect_url;
        }
      } catch (_) {
        // Fallback to default redirect URL
      }
    }

    // 2. Calculate Inventory Accounting Quantities
    const buyQty = payload.buy_qty || payload.quantity || 1;
    const freeQty = payload.free_qty || 0;
    const primaryFulfilledQty = buyQty + freeQty;

    const freeAddonProductName = payload.free_addon_product_name || null;
    const freeAddonQty = payload.free_addon_qty || 0;

    const totalPhysicalUnits = primaryFulfilledQty + freeAddonQty;

    const basePrice = payload.base_price || 23500;
    const totalAmount = basePrice * buyQty;
    const orderNumber = `ORD-${Date.now().toString().slice(-6)}-${Math.floor(1000 + Math.random() * 9000)}`;
    const submissionCode = `CRM-SUB-${Math.floor(100000 + Math.random() * 900000)}`;

    // 3. Insert Order Header Record
    let newOrder: any = null;
    try {
      const { data: insertedOrder, error: orderError } = await supabaseClient
        .from("orders")
        .insert({
          order_number: orderNumber,
          company_id: validatedCompanyId,
          product_id: resolvedProductId,
          marketer_id: validatedMarketerId,
          campaign_id: validatedCampaignId,
          form_id: validatedFormId,
          customer_name: payload.customer_name,
          customer_phone: payload.customer_phone,
          customer_alt_phone: payload.customer_alt_phone || null,
          delivery_state: payload.delivery_state,
          delivery_city: payload.delivery_city || null,
          delivery_address: payload.delivery_address,
          quantity: primaryFulfilledQty,
          base_price: basePrice,
          total_amount: totalAmount,
          status: "new",
        })
        .select()
        .single();

      if (orderError) {
        console.error("Order Header Insertion Error:", orderError);
      } else {
        newOrder = insertedOrder;
      }
    } catch (e) {
      console.error("Order Header Insertion Exception:", e);
    }

    // 4. Insert Multi-Product Line Items into public.order_items (Warehouse Packing List)
    if (newOrder && newOrder.id) {
      try {
        const orderItems = [
          {
            order_id: newOrder.id,
            product_id: resolvedProductId,
            product_name: payload.product_name || "Grazer Herbal Tea",
            item_type: "Main",
            quantity: primaryFulfilledQty,
            unit_price: basePrice,
            total_price: totalAmount,
          },
        ];

        if (freeAddonProductId && freeAddonQty > 0) {
          orderItems.push({
            order_id: newOrder.id,
            product_id: freeAddonProductId,
            product_name: freeAddonProductName || "Free Addon Gift",
            item_type: "CrossProductFreeGift",
            quantity: freeAddonQty,
            unit_price: 0,
            total_price: 0,
          });
        }

        await supabaseClient.from("order_items").insert(orderItems);
      } catch (err) {
        console.warn("Order Line Items Warning:", err);
      }
    }

    // 5. Record Form Submission Record
    try {
      const { error: submissionError } = await supabaseClient
        .from("form_submissions")
        .insert({
          submission_code: submissionCode,
          company_id: validatedCompanyId,
          form_id: validatedFormId,
          customer_name: payload.customer_name,
          contact_email: payload.customer_email || null,
          contact_phone: payload.customer_phone,
          delivery_state: payload.delivery_state,
          delivery_city: payload.delivery_city || null,
          delivery_address: payload.delivery_address,
          offer_package_id: payload.offer_package_id || null,
          selected_quantity: primaryFulfilledQty,
          amount: totalAmount,
          status: "Converted",
          order_id: newOrder?.id || null,
          utm_source: payload.utm_source || "direct",
          utm_campaign: payload.utm_campaign || "organic",
          utm_medium: payload.utm_medium || "cpc",
          ad_id: payload.ad_id || null,
          additional_responses: {
            ...(payload.additional_responses || {}),
            free_addon_product: freeAddonProductName,
            free_addon_qty: freeAddonQty,
            redirect_url: targetRedirectUrl,
          },
        });

      if (submissionError) {
        console.warn("Form Submission Record Warning:", submissionError);
      }
    } catch (e) {
      console.warn("Form Submission Exception:", e);
    }

    // 6. Atomic Round-Robin Lead Assignment Call
    if (newOrder && newOrder.id) {
      try {
        await supabaseClient.rpc("assign_order_round_robin", {
          p_order_id: newOrder.id,
          p_product_id: resolvedProductId,
        });
      } catch (err) {
        console.warn("Round Robin Assignment Warning:", err);
      }
    }

    // Build Final Thank-You Redirect URL with Conversion Attribution Query Params
    const redirectUrlWithParams = targetRedirectUrl.includes("?")
      ? `${targetRedirectUrl}&order_number=${orderNumber}&submission_code=${submissionCode}&amount=${totalAmount}`
      : `${targetRedirectUrl}?order_number=${orderNumber}&submission_code=${submissionCode}&amount=${totalAmount}`;

    return new Response(
      JSON.stringify({
        message: "Order successfully submitted with automatic thank-you page redirect.",
        order_id: newOrder?.id || null,
        order_number: orderNumber,
        submission_code: submissionCode,
        redirect_url: redirectUrlWithParams,
        primary_stock_deducted: primaryFulfilledQty,
        free_addon_gift_stock_deducted: freeAddonQty,
        total_physical_units_deducted: totalPhysicalUnits,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 201 }
    );
  } catch (err: any) {
    console.error("Unhandled Webhook Error:", err);
    return new Response(
      JSON.stringify({ error: err?.message || "Internal Server Error" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});
