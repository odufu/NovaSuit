import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.38.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );

    const { order_id, sku, item_name, description, quantity, unit_price, performed_by } = await req.json();

    if (!order_id || !item_name || !quantity || unit_price == null) {
      return new Response(
        JSON.stringify({ success: false, error: "Missing required fields: order_id, item_name, quantity, unit_price" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Call RPC function add_order_item_with_stock_check
    const { data, error } = await supabaseClient.rpc("add_order_item_with_stock_check", {
      p_order_id: order_id,
      p_sku: sku || "",
      p_item_name: item_name,
      p_description: description || "",
      p_quantity: parseInt(quantity, 10),
      p_unit_price: parseFloat(unit_price),
      p_performed_by: performed_by || "Digital Marketer",
    });

    if (error) {
      return new Response(
        JSON.stringify({ success: false, error: error.message }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify(data),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
