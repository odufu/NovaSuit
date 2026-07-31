-- ============================================================================
-- Migration: 20260726000000_add_user_sip_credentials.sql
-- Description: Add sip_extension and sip_password columns to public.users for WebRTC & Mobile Softphone
-- ============================================================================

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS sip_extension VARCHAR(50),
ADD COLUMN IF NOT EXISTS sip_password VARCHAR(255);
