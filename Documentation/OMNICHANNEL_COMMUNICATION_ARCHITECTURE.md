# NovaSuite Omnichannel Sales Communication Hub Architecture & Feasibility Guide

## Executive Summary & Feasibility Assessment

To maximize sales conversion, minimize Cash-on-Delivery (COD) rejection rates, and streamline customer follow-ups, **NovaSuite** is expanding its sales rep communication channels from single-channel VoIP calling (IT Sky SIP Interconnect) into an **Integrated Omnichannel Communication Hub**.

This architecture unifies **VoIP Calls (ITSky)**, **WhatsApp Business Cloud API**, and **SMS Text Messaging** directly inside the Sales Call Rep & Supervisor Console.

---

### Feasibility Matrix

| Communication Channel | Technical Stack / Vendor | Primary Use Cases | Delivery Guarantee & Latency | Cost Impact | Feasibility Rating |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Voice Calls** | **IT Sky SIP Trunk** (`95.217.244.97:5060`) | Initial order confirmation, high-touch sales negotiation, upsell pitching | Sub-second latency, 99.9% uptime via dedicated E1/SIP trunk | Flat per-minute VoIP trunk rates | **High (Already Integrated)** |
| **WhatsApp Business** | **Meta WhatsApp Business Cloud API / Termii BSP** | Sending waybill tracking, product usage guides, payment receipts, interactive order confirmations | Real-time (<500ms webhook delivery), 98%+ open rate | ~$0.015 - $0.035 / conversation (Meta 24-hr window) | **Very High (Recommended Next Step)** |
| **SMS Messaging** | **Termii / Twilio / Africa's Talking** | Delivery alerts, fallback notifications when customer is offline or internet is disconnected | High delivery rate via direct carrier routes (MTN, Airtel, Glo, 9mobile) | ~$0.005 / SMS | **High (Easy Integration)** |

---

## 📊 Competitor Landscape & Benchmarking

| Feature / Capability | HubSpot Sales Hub | Salesforce Digital Engagement | respond.io / Trengo | Freshsales Omnichannel | **NovaCare CRM (NovaSuite)** |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **VoIP / Telephony** | Integrated (Twilio/Aircall) | Service Cloud Voice | ❌ Third-party plugin | Freshcaller | **Native IT Sky Direct SIP Interconnect** |
| **WhatsApp Business API** | Twilio integration | Native / Meta Cloud API | Native WhatsApp Cloud API | Native | **Native Meta Cloud API & Local BSP (Termii)** |
| **SMS Gateway** | App Marketplace Add-on | MobileConnect SMS | Native SMS | Native | **Integrated West Africa Carrier Route (Termii/Twilio)** |
| **COD E-Commerce Integration** | Generic Custom Fields | Custom Objects | Basic Webhooks | Basic Custom Fields | **Deep Integration (COD Holding, Rider Dispatches, Multi-Tier Commissions)** |
| **Interactive Order Buttons** | ❌ Manual Link | Complex Flow Builder | Basic Quick Replies | ❌ Manual Link | **Native Interactive WhatsApp Buttons (`[Confirm]`, `[Reschedule]`)** |
| **Unified Timeline** | Yes | Yes | Yes | Yes | **Yes (Calls + Recordings + WhatsApp Chat + SMS in 1 View)** |

---

## 🏗️ High-Level System Architecture

The following diagram illustrates how incoming and outgoing voice, WhatsApp, and SMS communications are orchestrated across NovaSuite Deno Edge Functions, Supabase Realtime DB, and External Telecom Gateways:

```mermaid
graph TD
    subgraph SG1["Frontend Layer"]
        App["📱 NovaSuite Call Rep / Supervisor Web Console"]
        DialerWidget["📞 Integrated Dialer & Chat Widget"]
    end

    subgraph SG2["Deno Edge Gateway & Realtime Engine"]
        EdgeGateway["⚡ Supabase Deno Edge Functions (/api/v1/omnichannel)"]
        RealtimeEngine["🔄 Supabase Realtime Engine (WebSocket Channels)"]
        Db[("🗄️ Supabase PostgreSQL DB")]
    end

    subgraph SG3["Telemetry & External Gateways"]
        ITSky["🇳🇬 IT Sky SIP Telecom Gateway (95.217.244.97:5060)"]
        MetaWA["💬 Meta WhatsApp Business Cloud API / Webhook Engine"]
        SMSGateway["📱 Termii / Twilio Direct SMS Gateway"]
    end

    App --> DialerWidget
    DialerWidget <-->|WebSockets| RealtimeEngine
    DialerWidget -->|HTTP REST| EdgeGateway

    EdgeGateway -->|SIP Protocol| ITSky
    EdgeGateway -->|Graph API v19.0| MetaWA
    EdgeGateway -->|REST API| SMSGateway

    MetaWA -->|Inbound Webhooks| EdgeGateway
    ITSky -->|Call Event Webhooks| EdgeGateway
    SMSGateway -->|Delivery Status Webhooks| EdgeGateway

    EdgeGateway --> Db
    RealtimeEngine <--> Db
```

---

## 🔄 Multi-Channel Communication Handshake Sequence

This sequence diagram depicts how a Sales Call Rep initiates a multi-channel interaction (Call ➔ WhatsApp Confirmation ➔ SMS Fallback) for an assigned order:

```mermaid
sequenceDiagram
    autonumber
    actor Rep as 🎧 Sales Call Rep
    participant App as 📱 NovaSuite Console
    participant Edge as ⚡ Supabase Edge Function
    participant DB as 🗄️ Supabase DB
    participant ITSky as 📞 IT Sky SIP Trunk
    participant Meta as 💬 Meta WhatsApp API
    participant SMS as 📱 Termii SMS Gateway
    actor Customer as 👤 Customer

    %% Step 1: Voice Call
    Rep->>App: 1. Click "Call Customer"
    App->>Edge: 2. POST /api/v1/calls/initiate {orderId, customerPhone}
    Edge->>ITSky: 3. SIP INVITE (Caller ID: 07003100077)
    ITSky->>Customer: 4. Ring Customer Phone
    Customer-->>ITSky: 5. Call Connected & Recorded
    ITSky-->>Edge: 6. Webhook: Call Ended (Duration: 180s, Audio URL)
    Edge->>DB: 7. Insert into call_logs & Update order_activity

    %% Step 2: WhatsApp Interactive Order Confirmation
    Rep->>App: 8. Select "Send WhatsApp Order Confirmation"
    App->>Edge: 9. POST /api/v1/whatsapp/send-template {templateName: 'order_confirm_v1'}
    Edge->>Meta: 10. Send Interactive Template Message
    Meta->>Customer: 11. WhatsApp Message Delivered (With [Confirm Order] button)
    Customer->>Meta: 12. Customer Clicks [Confirm Order] Button
    Meta->>Edge: 13. Webhook: Interactive Button Clicked
    Edge->>DB: 14. Update order status to 'accepted' & log activity
    Edge-->>App: 15. Realtime Notification: "Order Confirmed by Customer on WhatsApp!"

    %% Step 3: SMS Delivery Fallback
    Note over Customer,SMS: If WhatsApp message is unread after 15 mins
    Edge->>SMS: 16. Trigger SMS Fallback
    SMS->>Customer: 17. Send SMS: "Your NovaCare order #ORD-101 is confirmed!"
    SMS-->>Edge: 18. Webhook: SMS Delivered
```

---

## 🗄️ Omnichannel Database Schema & Entity Relationships

```mermaid
erDiagram
    COMPANIES ||--o{ CONVERSATIONS : owns
    CUSTOMERS ||--o{ CONVERSATIONS : engages
    CONVERSATIONS ||--o{ MESSAGES : contains
    CONVERSATIONS ||--o{ CALL_LOGS : contains
    USERS ||--o{ MESSAGES : sends
    ORDERS ||--o{ CONVERSATIONS : references

    CONVERSATIONS {
        uuid id PK
        uuid company_id FK
        uuid customer_id FK
        uuid order_id FK
        uuid assigned_rep_id FK
        string primary_channel
        string status
        timestamp last_message_at
        timestamp created_at
    }

    MESSAGES {
        uuid id PK
        uuid conversation_id FK
        uuid sender_id FK
        string sender_type
        string channel
        string direction
        text content
        jsonb media_attachments
        string message_status
        string external_msg_id
        timestamp created_at
    }

    CALL_LOGS {
        uuid id PK
        uuid conversation_id FK
        uuid sales_rep_id FK
        string caller_id
        string destination_number
        integer duration_seconds
        string recording_url
        string disposition
        timestamp started_at
        timestamp ended_at
    }

    WHATSAPP_TEMPLATES {
        uuid id PK
        uuid company_id FK
        string template_name
        string category
        string language
        text header_text
        text body_text
        jsonb interactive_buttons
        string approval_status
    }
```

---

## 💡 Recommended Implementation Roadmap

### Phase 1: Meta WhatsApp Business Cloud API & Webhooks Setup
- Register NovaCare Meta Developer App & WhatsApp Business Account (WABA).
- Configure Webhook Endpoint in Supabase Edge Functions (`/supabase/functions/whatsapp-webhook/index.ts`).
- Define initial approved WhatsApp Templates (`order_confirmation`, `delivery_tracking`, `payment_reminder`).

### Phase 2: Database Migration & Supabase Realtime Engine
- Create database migration `add_omnichannel_messaging_tables.sql` (`conversations`, `messages`, `call_logs`, `whatsapp_templates`).
- Enable Supabase Realtime publication on `messages` table for instant sub-second chat updates in the Flutter UI.

### Phase 3: Integrated Omnichannel Flutter Suite
- Build `OmnichannelChatWidget` inside `SalesCallCenterSuitePage`.
- Unify Voice Calls, WhatsApp Chat, Voice Notes, Image Attachments, and SMS into a single conversation timeline tab.
