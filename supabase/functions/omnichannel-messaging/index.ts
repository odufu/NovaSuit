// ============================================================================
// Deno Edge Function: omnichannel-messaging
// Description: Outbound WhatsApp & SMS message dispatcher and Meta Webhook endpoint.
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.21.0";

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

    const url = new URL(req.url);

    // 1. Meta Webhook Verification Endpoint (GET)
    if (req.method === "GET" && url.pathname.endsWith("/webhook")) {
      const mode = url.searchParams.get("hub.mode");
      const token = url.searchParams.get("hub.verify_token");
      const challenge = url.searchParams.get("hub.challenge");

      if (mode === "subscribe" && token === "novacare_whatsapp_verify_token") {
        return new Response(challenge, { status: 200, headers: corsHeaders });
      }
      return new Response("Forbidden", { status: 403, headers: corsHeaders });
    }

    // 2. Outbound Message Dispatcher (POST /dispatch)
    const payload = await req.json();
    const { conversationId, channel, content, senderId, mediaUrl, interactiveButtons } = payload;

    if (!conversationId || !content) {
      return new Response(
        JSON.stringify({ error: "Missing required conversationId or content" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Insert Message into Database
    const { data: message, error: msgErr } = await supabase
      .from("messages")
      .insert({
        conversation_id: conversationId,
        sender_id: senderId,
        sender_type: "sales_rep",
        channel: channel || "whatsapp",
        direction: "outbound",
        content: content,
        media_url: mediaUrl,
        interactive_buttons: interactiveButtons || [],
        message_status: "sent",
      })
      .select()
      .single();

    if (msgErr) {
      throw msgErr;
    }

    // Update Conversation Last Summary & Timestamp
    await supabase
      .from("conversations")
      .update({
        last_message_summary: content,
        last_message_at: new Date().toISOString(),
      })
      .eq("id", conversationId);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Message dispatched and logged successfully",
        data: message,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
