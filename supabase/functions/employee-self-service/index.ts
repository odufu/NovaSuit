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
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const body = await req.json();
    const { action, employeeId, companyId, payload } = body;

    if (action === "submit_leave") {
      const { leaveType, fromDate, toDate, isHalfDay, reason } = payload;

      const { data, error } = await supabase.rpc("submit_leave_application", {
        p_employee_id: employeeId,
        p_company_id: companyId || "c0000000-0000-0000-0000-000000000001",
        p_leave_type: leaveType,
        p_from_date: fromDate,
        p_to_date: toDate,
        p_is_half_day: isHalfDay ?? false,
        p_reason: reason ?? "",
      });

      if (error) throw error;
      return new Response(JSON.stringify(data), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    if (action === "submit_expense_claim") {
      const { narration, items } = payload;
      let totalClaimed = 0;
      if (Array.isArray(items)) {
        totalClaimed = items.reduce((acc: number, item: any) => acc + (Number(item.amount) || 0), 0);
      }

      // Insert Claim
      const { data: claim, error: claimErr } = await supabase
        .from("expense_claims")
        .insert({
          employee_id: employeeId,
          company_id: companyId || "c0000000-0000-0000-0000-000000000001",
          posting_date: new Date().toISOString().split("T")[0],
          total_claimed: totalClaimed,
          total_sanctioned: 0.0,
          approval_status: "Draft",
          status: "Draft",
          narration: narration || "Expense claim submission",
        })
        .select()
        .single();

      if (claimErr) throw claimErr;

      // Insert Line items
      if (Array.isArray(items) && items.length > 0) {
        const lineItems = items.map((i: any) => ({
          claim_id: claim.id,
          expense_date: i.expenseDate || new Date().toISOString().split("T")[0],
          expense_type: i.expenseType || "General",
          description: i.description || "",
          amount: Number(i.amount) || 0,
        }));

        await supabase.from("expense_claim_items").insert(lineItems);
      }

      return new Response(
        JSON.stringify({
          success: true,
          claimId: claim.id,
          claimCode: claim.claim_code,
          totalClaimed,
          message: "Expense claim created successfully!",
        }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 200,
        }
      );
    }

    return new Response(
      JSON.stringify({ error: "Unsupported action" }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ success: false, error: err.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
