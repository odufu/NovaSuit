// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: reassign-leads
// Batch Lead Reassignment with Realtime Notifications & Audit Logging
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ReassignPayload {
  order_ids: string[];
  target_sales_rep_id: string;
  supervisor_id: string;
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

    const payload: ReassignPayload = await req.json();

    if (!payload.order_ids || payload.order_ids.length === 0 || !payload.target_sales_rep_id) {
      return new Response(
        JSON.stringify({ error: "order_ids and target_sales_rep_id are required." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // 1. Batch update orders
    const { data: updatedOrders, error: updateError } = await supabaseClient
      .from("orders")
      .update({
        sales_rep_id: payload.target_sales_rep_id,
        updated_at: new Date().toISOString(),
      })
      .in("id", payload.order_ids)
      .select();

    if (updateError) {
      return new Response(
        JSON.stringify({ error: updateError.message }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
      );
    }

    // 2. Log Order Activity for each order
    const activities = payload.order_ids.map((id) => ({
      order_id: id,
      user_id: payload.supervisor_id,
      action: "reassigned",
      description: `Order reassigned to sales rep ID: ${payload.target_sales_rep_id}`,
      created_at: new Date().toISOString(),
    }));

    await supabaseClient.from("order_activities").insert(activities);

    return new Response(
      JSON.stringify({
        message: "Orders reassigned successfully.",
        reassigned_count: updatedOrders?.length || 0,
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
