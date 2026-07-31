// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: submit-order
// High-Scale Webhook Order Ingestion & Atomic Round-Robin Assignment
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
  campaign_id?: string;
  form_id?: string;
  customer_name: string;
  customer_phone: string;
  customer_alt_phone?: string;
  delivery_state: string;
  delivery_city?: string;
  delivery_address: string;
  quantity?: number;
  pixel_id?: string;
  event_source_url?: string;
}

serve(async (req: Request) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const payload: OrderPayload = await req.json();

    // 1. Basic Validation
    if (!payload.company_id || !payload.product_id || !payload.customer_name || !payload.customer_phone || !payload.delivery_address || !payload.delivery_state) {
      return new Response(
        JSON.stringify({ error: "Missing required order fields." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // 2. Fetch Product Base Price
    const { data: product, error: productError } = await supabaseClient
      .from("products")
      .select("base_price, sku")
      .eq("id", payload.product_id)
      .single();

    if (productError || !product) {
      return new Response(
        JSON.stringify({ error: "Invalid product ID or product not found." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 404 }
      );
    }

    const qty = payload.quantity || 1;
    const basePrice = Number(product.base_price);
    const totalAmount = basePrice * qty;
    const orderNumber = `ORD-${Date.now().toString().slice(-6)}-${Math.floor(1000 + Math.random() * 9000)}`;

    // 3. Insert New Order Record
    const { data: newOrder, error: orderError } = await supabaseClient
      .from("orders")
      .insert({
        order_number: orderNumber,
        company_id: payload.company_id,
        product_id: payload.product_id,
        marketer_id: payload.marketer_id || null,
        campaign_id: payload.campaign_id || null,
        form_id: payload.form_id || null,
        customer_name: payload.customer_name,
        customer_phone: payload.customer_phone,
        customer_alt_phone: payload.customer_alt_phone || null,
        delivery_state: payload.delivery_state,
        delivery_city: payload.delivery_city || null,
        delivery_address: payload.delivery_address,
        quantity: qty,
        base_price: basePrice,
        total_amount: totalAmount,
        status: "new",
      })
      .select()
      .single();

    if (orderError || !newOrder) {
      console.error("Order Insert Error:", orderError);
      return new Response(
        JSON.stringify({ error: "Failed to create order record." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
      );
    }

    // 4. Atomic Round-Robin Assignment Call
    const { data: assignedRepId, error: assignError } = await supabaseClient.rpc(
      "assign_order_round_robin",
      {
        p_order_id: newOrder.id,
        p_product_id: payload.product_id,
      }
    );

    if (assignError) {
      console.warn("Round Robin Assignment Warning:", assignError);
    }

    // 5. Asynchronous Facebook Conversions API (CAPI) Trigger
    if (payload.pixel_id) {
      const fbAccessToken = Deno.env.get("FACEBOOK_CAPI_ACCESS_TOKEN");
      if (fbAccessToken) {
        fetch(`https://graph.facebook.com/v18.0/${payload.pixel_id}/events?access_token=${fbAccessToken}`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            data: [
              {
                event_name: "Purchase",
                event_time: Math.floor(Date.now() / 1000),
                action_source: "website",
                event_source_url: payload.event_source_url || "",
                user_data: {
                  ph: [await hashString(payload.customer_phone)],
                  fn: [await hashString(payload.customer_name)],
                },
                custom_data: {
                  currency: "NGN",
                  value: totalAmount,
                  content_name: product.sku,
                },
              },
            ],
          }),
        }).catch((err) => console.error("FB CAPI Error:", err));
      }
    }

    return new Response(
      JSON.stringify({
        message: "Order successfully submitted and queued.",
        order_id: newOrder.id,
        order_number: orderNumber,
        assigned_sales_rep_id: assignedRepId,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );
  } catch (err: any) {
    console.error("Unhandled Webhook Error:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Internal Server Error" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});

// SHA-256 Utility for FB CAPI User Data Hashing
async function hashString(str: string): Promise<string> {
  const msgUint8 = new TextEncoder().encode(str.trim().toLowerCase());
  const hashBuffer = await crypto.subtle.digest("SHA-256", msgUint8);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}
