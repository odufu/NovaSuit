// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: resolve-upsell
// Supervisor Authorization for Up-Sell & Down-Sell Requests
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ResolveUpsellPayload {
  order_id: string;
  supervisor_id: string;
  approve: boolean;
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

    const payload: ResolveUpsellPayload = await req.json();

    if (!payload.order_id || !payload.supervisor_id || payload.approve === undefined) {
      return new Response(
        JSON.stringify({ error: "order_id, supervisor_id, and approve flag are required." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // Fetch existing order to check base_price
    const { data: existingOrder, error: fetchErr } = await supabaseClient
      .from("orders")
      .select("base_price, quantity")
      .eq("id", payload.order_id)
      .single();

    if (fetchErr || !existingOrder) {
      return new Response(
        JSON.stringify({ error: "Order not found." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 404 }
      );
    }

    const updatePayload = payload.approve
      ? {
          status: "accepted",
          upsell_status: "approved",
          approved_by_supervisor_id: payload.supervisor_id,
          updated_at: new Date().toISOString(),
        }
      : {
          status: "accepted",
          upsell_status: "rejected",
          upsell_amount: 0,
          downsell_discount: 0,
          total_amount: Number(existingOrder.base_price) * (existingOrder.quantity || 1),
          approved_by_supervisor_id: payload.supervisor_id,
          updated_at: new Date().toISOString(),
        };

    const { data: updatedOrder, error: updateErr } = await supabaseClient
      .from("orders")
      .update(updatePayload)
      .eq("id", payload.order_id)
      .select()
      .single();

    if (updateErr) {
      return new Response(
        JSON.stringify({ error: updateErr.message }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
      );
    }

    // Log Activity
    await supabaseClient.from("order_activities").insert({
      order_id: payload.order_id,
      user_id: payload.supervisor_id,
      action: payload.approve ? "upsell_approved" : "upsell_rejected",
      description: payload.approve
        ? `Supervisor approved upsell request.`
        : `Supervisor rejected upsell request. Reverted to base price.`,
      created_at: new Date().toISOString(),
    });

    return new Response(
      JSON.stringify({
        message: payload.approve ? "Upsell approved successfully." : "Upsell rejected successfully.",
        order: updatedOrder,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Internal Server Error" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});
