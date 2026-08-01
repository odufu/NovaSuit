// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: calculate-commissions
// Multi-Tier Commission Ledger Engine (Sales Rep, Supervisor, AHOD, HOD)
// Supports Direct Fixed Value per Unit or Percentage of Product Total Value
// Controlled by Operations/GM Master Incentive Toggle
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

    // 1. Fetch Company Commission Settings (Operations / GM)
    const { data: setting } = await supabaseClient
      .from("company_commission_settings")
      .select("*")
      .eq("company_id", body.company_id)
      .single();

    const incentivesEnabled = setting ? setting.incentives_enabled : true;

    if (!incentivesEnabled) {
      return new Response(
        JSON.stringify({
          success: true,
          incentives_enabled: false,
          message: "Commission incentives are currently turned OFF by Operations / GM Department.",
        }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      );
    }

    // 2. Fetch Delivered Orders
    let query = supabaseClient
      .from("orders")
      .select("id, company_id, sales_rep_id, product_id, quantity, total_amount, status")
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

    let processedOrders = 0;
    let totalCommissionsDistributed = 0;

    for (const order of deliveredOrders) {
      const qty = order.quantity || 1;
      const totalAmount = Number(order.total_amount || 0);
      const repId = order.sales_rep_id;

      if (!repId) continue;

      // Fetch hierarchy mappings (Supervisor, AHOD, HOD)
      const { data: userRole } = await supabaseClient
        .from("user_roles")
        .select("supervisor_id, ahod_id, hod_id")
        .eq("user_id", repId)
        .eq("company_id", body.company_id)
        .single();

      const supervisorId = userRole?.supervisor_id || null;
      const ahodId = userRole?.ahod_id || null;
      const hodId = userRole?.hod_id || null;

      // Helper function to compute commission based on type
      const computeComm = (type: string, value: number) => {
        return type === "percentage" ? (totalAmount * value) / 100.0 : qty * value;
      };

      // 1. Sales Rep Commission
      const repVal = setting?.rep_commission_value ? Number(setting.rep_commission_value) : 1000.0;
      const repType = setting?.rep_commission_type || "fixed_per_unit";
      const repComm = computeComm(repType, repVal);

      await supabaseClient.from("commissions").upsert({
        company_id: body.company_id,
        user_id: repId,
        supervisor_id: supervisorId,
        order_id: order.id,
        recipient_role: "sales_call_rep",
        product_id: order.product_id,
        quantity: qty,
        unit_commission_rate: repVal,
        total_commission: repComm,
        status: "earned",
      }, { onConflict: "order_id,user_id,recipient_role" });

      totalCommissionsDistributed += repComm;

      // 2. Supervisor Commission
      if (supervisorId) {
        const supVal = setting?.supervisor_commission_value ? Number(setting.supervisor_commission_value) : 250.0;
        const supType = setting?.supervisor_commission_type || "fixed_per_unit";
        const supComm = computeComm(supType, supVal);

        await supabaseClient.from("commissions").upsert({
          company_id: body.company_id,
          user_id: supervisorId,
          supervisor_id: supervisorId,
          order_id: order.id,
          recipient_role: "sales_supervisor",
          product_id: order.product_id,
          quantity: qty,
          unit_commission_rate: supVal,
          total_commission: supComm,
          status: "earned",
        }, { onConflict: "order_id,user_id,recipient_role" });

        totalCommissionsDistributed += supComm;
      }

      // 3. AHOD Commission
      if (ahodId) {
        const ahodVal = setting?.ahod_commission_value ? Number(setting.ahod_commission_value) : 150.0;
        const ahodType = setting?.ahod_commission_type || "fixed_per_unit";
        const ahodComm = computeComm(ahodType, ahodVal);

        await supabaseClient.from("commissions").upsert({
          company_id: body.company_id,
          user_id: ahodId,
          supervisor_id: supervisorId,
          order_id: order.id,
          recipient_role: "ahod",
          product_id: order.product_id,
          quantity: qty,
          unit_commission_rate: ahodVal,
          total_commission: ahodComm,
          status: "earned",
        }, { onConflict: "order_id,user_id,recipient_role" });

        totalCommissionsDistributed += ahodComm;
      }

      // 4. HOD Commission
      if (hodId) {
        const hodVal = setting?.hod_commission_value ? Number(setting.hod_commission_value) : 100.0;
        const hodType = setting?.hod_commission_type || "fixed_per_unit";
        const hodComm = computeComm(hodType, hodVal);

        await supabaseClient.from("commissions").upsert({
          company_id: body.company_id,
          user_id: hodId,
          supervisor_id: supervisorId,
          order_id: order.id,
          recipient_role: "hod",
          product_id: order.product_id,
          quantity: qty,
          unit_commission_rate: hodVal,
          total_commission: hodComm,
          status: "earned",
        }, { onConflict: "order_id,user_id,recipient_role" });

        totalCommissionsDistributed += hodComm;
      }

      processedOrders++;
    }

    return new Response(
      JSON.stringify({
        success: true,
        incentives_enabled: true,
        orders_processed: processedOrders,
        total_commissions_distributed: totalCommissionsDistributed,
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
