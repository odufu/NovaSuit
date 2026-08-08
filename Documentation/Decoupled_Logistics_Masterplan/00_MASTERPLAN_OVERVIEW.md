# Decoupled Logistics & Open API Platform — Masterplan Overview

This masterplan details the complete architectural evolution to **decouple logistics and warehousing operations from NovaSuite CRM**, transforming NovaSuite into an open e-commerce/sales hub that streams live confirmed orders to independent logistics partners (e.g., **Nova Express**, GIG Logistics, Fez Delivery, Red Star), manages multi-warehouse stock delegation, and exposes a secure Open Logistics Event Gateway.

---

## High-Level System Architecture

```mermaid
graph TD
    subgraph NovaSuiteCore ["NovaSuite Enterprise Hub"]
        SalesEngine["Sales & Telesales Call Center Suite"]
        MerchantStock["Merchant Inventory & Warehouse Manager"]
        PartnerPortal["Logistics Partner Onboarding UI"]
        EventGateway["Open Logistics Event Gateway (Webhooks / Sockets)"]
    end

    subgraph OpenLogisticsAPI ["Logistics & Stock API Gateway"]
        OutboundEvents["Outbound Streams (order.ready_for_fulfillment, stock.transfer_dispatched)"]
        InboundCallbacks["Inbound Callbacks (/status-update, /stock-reconciliation)"]
        AuthSecurity["API Key & HMAC Signature Security Layer"]
    end

    subgraph ExternalLogistics ["Independent Logistics Network"]
        NovaExpressApp["Nova Express (Independent Delivery App & Fleet Manager)"]
        PartnerGIG["3PL Partner (GIG Logistics)"]
        PartnerFez["3PL Partner (Fez Delivery)"]
    end

    SalesEngine --> MerchantStock
    MerchantStock --> PartnerPortal
    PartnerPortal --> EventGateway
    EventGateway --> OutboundEvents
    OutboundEvents --> AuthSecurity
    AuthSecurity --> NovaExpressApp
    AuthSecurity --> PartnerGIG
    AuthSecurity --> PartnerFez
    NovaExpressApp --> InboundCallbacks
    PartnerGIG --> InboundCallbacks
    PartnerFez --> InboundCallbacks
    InboundCallbacks --> MerchantStock
    InboundCallbacks --> SalesEngine
```

---

## Implementation Roadmap & Phases

```mermaid
timeline
    title Decoupled Logistics Masterplan Implementation Phases
    Phase 1 : DB Models & Partner Portal : Database Schema, Core Domain Models, NovaSuite Admin Partner Management UI
    Phase 2 : Open Logistics Event Gateway : Webhook Engine, API Key Auth, HMAC Signatures, Inbound Callback Endpoints
    Phase 3 : Stock Delegation & Fulfillment : Multi-Warehouse Allocation UI, Stock Transfer Requests, Proximity Order Routing
    Phase 4 : Nova Express Integration : Independent NovaExpress App Spec, Waybill Generation, Live Rider Sync, E2E Testing
```

| Phase Document | Focus Area | Deliverables |
| :--- | :--- | :--- |
| **[Phase 1](file:///c:/PROJECT/novasuite/Documentation/Decoupled_Logistics_Masterplan/PHASE_1_DB_MODELS_AND_PARTNER_PORTAL.md)** | DB Schema & Partner Portal | Database tables, Domain Models (`LogisticsPartner`, `StockAllocation`), Admin Onboarding UI |
| **[Phase 2](file:///c:/PROJECT/novasuite/Documentation/Decoupled_Logistics_Masterplan/PHASE_2_OPEN_LOGISTICS_EVENT_GATEWAY.md)** | Open Event Gateway | Outbound Webhooks, HMAC SHA-256 Security, Inbound API Callbacks (`/status-update`, `/stock-reconciliation`) |
| **[Phase 3](file:///c:/PROJECT/novasuite/Documentation/Decoupled_Logistics_Masterplan/PHASE_3_MERCHANT_STOCK_DELEGATION_AND_FULFILLMENT.md)** | Stock Delegation & Fulfillment | Multi-Warehouse Stock Management UI, Stock Transfer Requests, Proximity Routing Engine |
| **[Phase 4](file:///c:/PROJECT/novasuite/Documentation/Decoupled_Logistics_Masterplan/PHASE_4_NOVA_EXPRESS_STANDALONE_INTEGRATION.md)** | Nova Express Integration | Independent Nova Express Fleet App Spec, Waybill Generator, Live Rider GPS Sync, E2E Test Suite |
| **[Nova Express Architecture](file:///c:/PROJECT/novasuite/Documentation/Decoupled_Logistics_Masterplan/NOVA_EXPRESS_CIRCUIT_CENTERS_AND_IDA_ARCHITECTURE.md)** | Circuit Centers & IDAs | Distribution Center Network, Independent Delivery Agent Onboarding & Hybrid Auto/Manual Dispatch |

---

## Core Principles

1. **Domain Isolation**: NovaSuite CRM owns sales, leads, telephony, and customer financial accounts. Nova Express and 3PL partners own fulfillment, warehousing, and rider dispatch.
2. **Standardized Open API**: Any 3PL logistics provider can integrate with NovaSuite using our open Webhook/REST API standard.
3. **Multi-Warehouse Stock Accountability**: Merchants retain inventory ownership while delegating physical stock counts to Nova Express hubs.
