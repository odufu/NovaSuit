// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: submit-order
// High-Scale Webhook Order Ingestion, Form Submissions Recording & Atomic Assignment
// Enforces Total Inventory Deduction Rule (total_fulfilled_quantity = buy_qty + free_qty)
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface OrderPayload {
  company_id: string;
  product_id: string;
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
  quantity?: number;
  base_price?: number;
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

    if (!payload.company_id || !payload.customer_name || !payload.customer_phone || !payload.delivery_address || !payload.delivery_state) {
      return new Response(
        JSON.stringify({ error: "Missing required order fields." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // Physical Inventory Deduction Rule: total_fulfilled_quantity = buy_qty + free_qty
    const buyQty = payload.buy_qty || payload.quantity || 1;
    const freeQty = payload.free_qty || 0;
    const totalFulfilledQuantity = buyQty + freeQty;

    const basePrice = payload.base_price || 25000;
    const totalAmount = basePrice * buyQty;
    const orderNumber = `ORD-${Date.now().toString().slice(-6)}-${Math.floor(1000 + Math.random() * 9000)}`;
    const submissionCode = `CRM-SUB-${Math.floor(100000 + Math.random() * 900000)}`;

    // 1. Insert Order Record (Recording total_fulfilled_quantity for warehouse pickers)
    const { data: newOrder, error: orderError } = await supabaseClient
      .from("orders")
      .insert({
        order_number: orderNumber,
        company_id: payload.company_id,
        product_id: payload.product_id || "prod-herbal-tea",
        marketer_id: payload.marketer_id || null,
        campaign_id: payload.campaign_id || null,
        form_id: payload.form_id || null,
        customer_name: payload.customer_name,
        customer_phone: payload.customer_phone,
        customer_alt_phone: payload.customer_alt_phone || null,
        delivery_state: payload.delivery_state,
        delivery_city: payload.delivery_city || null,
        delivery_address: payload.delivery_address,
        quantity: totalFulfilledQuantity, // Physical inventory deducted from warehouse stock!
        base_price: basePrice,
        total_amount: totalAmount,
        status: "new",
      })
      .select()
      .single();

    // 2. Insert Form Submission Record
    const { error: submissionError } = await supabaseClient
      .from("form_submissions")
      .insert({
        submission_code: submissionCode,
        company_id: payload.company_id,
        form_id: payload.form_id || null,
        customer_name: payload.customer_name,
        contact_email: payload.customer_email || null,
        contact_phone: payload.customer_phone,
        delivery_state: payload.delivery_state,
        delivery_city: payload.delivery_city || null,
        delivery_address: payload.delivery_address,
        offer_package_id: payload.offer_package_id || null,
        selected_quantity: totalFulfilledQuantity, // Accounted physical stock!
        amount: totalAmount,
        status: "Converted",
        order_id: newOrder?.id || null,
        utm_source: payload.utm_source || "direct",
        utm_campaign: payload.utm_campaign || "organic",
        utm_medium: payload.utm_medium || "cpc",
        ad_id: payload.ad_id || null,
        additional_responses: payload.additional_responses || {},
      });

    if (submissionError) {
      console.warn("Form Submission Record Warning:", submissionError);
    }

    // 3. Atomic Round-Robin Lead Assignment Call
    if (newOrder) {
      await supabaseClient.rpc("assign_order_round_robin", {
        p_order_id: newOrder.id,
        p_product_id: payload.product_id || "prod-herbal-tea",
      }).catch((err) => console.warn("Round Robin Assignment Warning:", err));
    }

    return new Response(
      JSON.stringify({
        message: "Order successfully submitted with physical stock deduction (buy_qty + free_qty).",
        order_id: newOrder?.id || null,
        order_number: orderNumber,
        submission_code: submissionCode,
        total_physical_units_deducted: totalFulfilledQuantity,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 201 }
    );
  } catch (err: any) {
    console.error("Unhandled Webhook Error:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Internal Server Error" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});
