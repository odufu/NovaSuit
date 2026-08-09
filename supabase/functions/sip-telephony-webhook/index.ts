// ============================================================================
// NOVASUITE SUPABASE EDGE FUNCTION: sip-telephony-webhook
// Live Telephony Webhook Processing for Softphone Call Logging & Recording Ingestion
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface CallEventPayload {
  company_id: string;
  agent_id: string;
  order_id?: string;
  customer_phone: string;
  call_type?: "outbound" | "inbound";
  call_status?: "completed" | "busy" | "no_answer" | "failed";
  disposition?: "confirmed" | "callback" | "rejected" | "wrong_number";
  duration_seconds: number;
  recording_url?: string;
  notes?: string;
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

    const payload: CallEventPayload = await req.json();

    if (!payload.company_id || !payload.agent_id || !payload.customer_phone) {
      return new Response(
        JSON.stringify({ error: "Missing required call telemetry fields." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
      );
    }

    // Insert Softphone Call Log Entry
    const { data: callLog, error: logError } = await supabaseClient
      .from("sales_call_logs")
      .insert({
        company_id: payload.company_id,
        agent_id: payload.agent_id,
        order_id: payload.order_id || null,
        customer_phone: payload.customer_phone,
        call_type: payload.call_type || "outbound",
        call_status: payload.call_status || "completed",
        disposition: payload.disposition || "confirmed",
        duration_seconds: payload.duration_seconds || 0,
        recording_url: payload.recording_url || null,
        notes: payload.notes || null,
      })
      .select()
      .single();

    if (logError) {
      console.error("Call Log Insert Error:", logError);
      return new Response(
        JSON.stringify({ error: "Failed to record call log entry." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
      );
    }

    // If disposition is confirmed, update target order status
    if (payload.order_id && payload.disposition === "confirmed") {
      await supabaseClient
        .from("orders")
        .update({
          status: "confirmed",
          updated_at: new Date().toISOString(),
        })
        .eq("id", payload.order_id);
    }

    return new Response(
      JSON.stringify({
        message: "Call telemetry successfully processed.",
        call_log_id: callLog.id,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 201 }
    );
  } catch (err: any) {
    console.error("Unhandled Telephony Webhook Error:", err);
    return new Response(
      JSON.stringify({ error: err.message || "Internal Server Error" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 500 }
    );
  }
});
