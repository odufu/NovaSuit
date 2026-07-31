// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: calculate-commissions
// Computes & Ledger Sync for Sales Rep & Supervisor Cumulative Override Commissions
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface CommissionCalculationRequest {
  company_id: string;
  order_id?: string;
  recalculate_all?: boolean;
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

    const body: CommissionCalculationRequest = await req.json();

    if (!body.company_id) {
      return new Response(
        JSON.stringify({ error: "Missing required company_id field." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // Fetch delivered orders to process commission ledger entries
    let query = supabaseClient
      .from("orders")
      .select("id, company_id, sales_rep_id, product_id, quantity, status")
      .eq("company_id", body.company_id)
      .eq("status", "delivered");

    if (body.order_id) {
      query = query.eq("id", body.order_id);
    }

    const { data: deliveredOrders, error: ordersError } = await query;

    if (ordersError || !deliveredOrders) {
      return new Response(
        JSON.stringify({ error: "Failed to fetch delivered orders for commission calculation." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
      );
    }

    let processedCount = 0;
    let totalRepCommissionEarned = 0;
    let totalSupervisorOverrideEarned = 0;

    for (const order of deliveredOrders) {
      const qty = order.quantity || 1;
      const repId = order.sales_rep_id;

      if (!repId) continue;

      // 1. Fetch Product Commission Rates
      const { data: product } = await supabaseClient
        .from("products")
        .select("rep_commission_per_unit, supervisor_commission_per_unit")
        .or(`id.eq.${order.product_id},name.eq.${order.product_id}`)
        .single();

      const repRate = product?.rep_commission_per_unit ? Number(product.rep_commission_per_unit) : 1000.0;
      const supervisorRate = product?.supervisor_commission_per_unit ? Number(product.supervisor_commission_per_unit) : 250.0;

      // 2. Fetch Rep's Supervisor
      const { data: userRole } = await supabaseClient
        .from("user_roles")
        .select("supervisor_id")
        .eq("user_id", repId)
        .eq("company_id", body.company_id)
        .single();

      const supervisorId = userRole?.supervisor_id || null;

      // 3. Upsert Sales Rep Commission
      const repTotal = qty * repRate;
      await supabaseClient.from("commissions").upsert({
        company_id: body.company_id,
        user_id: repId,
        supervisor_id: supervisorId,
        order_id: order.id,
        recipient_role: "sales_call_rep",
        product_id: order.product_id,
        quantity: qty,
        unit_commission_rate: repRate,
        total_commission: repTotal,
        status: "earned",
      }, { onConflict: "order_id,user_id,recipient_role" });

      totalRepCommissionEarned += repTotal;
      processedCount++;

      // 4. Upsert Supervisor Cumulative Team Override Commission
      if (supervisorId) {
        const supervisorTotal = qty * supervisorRate;
        await supabaseClient.from("commissions").upsert({
          company_id: body.company_id,
          user_id: supervisorId,
          supervisor_id: supervisorId,
          order_id: order.id,
          recipient_role: "sales_supervisor",
          product_id: order.product_id,
          quantity: qty,
          unit_commission_rate: supervisorRate,
          total_commission: supervisorTotal,
          status: "earned",
        }, { onConflict: "order_id,user_id,recipient_role" });

        totalSupervisorOverrideEarned += supervisorTotal;
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        orders_processed: processedCount,
        total_rep_commission_earned: totalRepCommissionEarned,
        total_supervisor_override_earned: totalSupervisorOverrideEarned,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Internal server error" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});
