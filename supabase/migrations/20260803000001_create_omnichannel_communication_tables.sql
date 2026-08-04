-- ============================================================================
-- Migration: 20260803000001_create_omnichannel_communication_tables.sql
-- Description: Creates Conversations, Messages, Call Logs & WhatsApp Templates
--              tables with Supabase Realtime publication and RLS security policies.
-- ============================================================================

-- 1. Create ENUM Types for Channels and Statuses
DO $$ BEGIN
    CREATE TYPE public.comm_channel_type AS ENUM ('voice_call', 'whatsapp', 'sms', 'in_app');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE public.message_direction_type AS ENUM ('inbound', 'outbound');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE public.message_delivery_status AS ENUM ('sending', 'sent', 'delivered', 'read', 'failed');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Conversations Table (Grouped Thread per Customer / Order)
CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    customer_name VARCHAR(255),
    customer_phone VARCHAR(50),
    assigned_rep_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    primary_channel public.comm_channel_type NOT NULL DEFAULT 'whatsapp',
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    last_message_summary TEXT,
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Messages Table (Individual Text, Voice Notes, Payment Receipts, Interactive Templates)
CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    sender_type VARCHAR(50) NOT NULL DEFAULT 'sales_rep', -- 'sales_rep', 'customer', 'system', 'ai_bot'
    channel public.comm_channel_type NOT NULL DEFAULT 'whatsapp',
    direction public.message_direction_type NOT NULL DEFAULT 'outbound',
    content TEXT NOT NULL,
    media_url TEXT,
    media_type VARCHAR(50), -- 'image', 'audio_voicenote', 'pdf_receipt', 'location'
    interactive_buttons JSONB DEFAULT '[]'::jsonb,
    message_status public.message_delivery_status NOT NULL DEFAULT 'sent',
    external_msg_id VARCHAR(255),
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Call Logs Table (Voice Call Telemetry linked to IT Sky & Internal Dialer)
CREATE TABLE IF NOT EXISTS public.call_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    sales_rep_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    caller_id VARCHAR(50) NOT NULL DEFAULT '07003100077',
    destination_number VARCHAR(50) NOT NULL,
    duration_seconds INT NOT NULL DEFAULT 0,
    recording_url TEXT,
    disposition VARCHAR(100) NOT NULL DEFAULT 'answered', -- 'answered', 'busy', 'no_answer', 'failed'
    notes TEXT,
    started_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. WhatsApp Templates Table
CREATE TABLE IF NOT EXISTS public.whatsapp_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_id UUID NOT NULL REFERENCES public.companies(id) ON DELETE CASCADE,
    template_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL DEFAULT 'UTILITY',
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    header_text TEXT,
    body_text TEXT NOT NULL,
    interactive_buttons JSONB DEFAULT '[]'::jsonb,
    approval_status VARCHAR(50) NOT NULL DEFAULT 'APPROVED',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for Speed
CREATE INDEX IF NOT EXISTS idx_conversations_company ON public.conversations(company_id);
CREATE INDEX IF NOT EXISTS idx_conversations_rep ON public.conversations(assigned_rep_id);
CREATE INDEX IF NOT EXISTS idx_conversations_order ON public.conversations(order_id);
CREATE INDEX IF NOT EXISTS idx_messages_conversation ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON public.messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_call_logs_rep ON public.call_logs(sales_rep_id);
CREATE INDEX IF NOT EXISTS idx_call_logs_order ON public.call_logs(order_id);

-- Enable RLS
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.call_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whatsapp_templates ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Conversations access by company" ON public.conversations
    FOR ALL USING (company_id IN (SELECT company_id FROM public.users WHERE id = auth.uid()));

CREATE POLICY "Messages access by conversation" ON public.messages
    FOR ALL USING (conversation_id IN (SELECT id FROM public.conversations));

CREATE POLICY "Call logs access by company rep" ON public.call_logs
    FOR ALL USING (sales_rep_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.users WHERE id = auth.uid() AND role IN ('admin', 'general_manager', 'sales_supervisor', 'ahod', 'hod')
    ));

CREATE POLICY "WhatsApp templates access by company" ON public.whatsapp_templates
    FOR ALL USING (company_id IN (SELECT company_id FROM public.users WHERE id = auth.uid()));

-- Enable Supabase Realtime Publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
