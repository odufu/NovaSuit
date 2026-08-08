# Phase 1: Database Schema, Core Models & Partner Management Portal

**Focus Area**: Data Architecture, Supabase Migrations, Core Models, and NovaSuite Admin Onboarding Interface.

---

## Architecture & Entity Relationships

```mermaid
erDiagram
    LOGISTICS_PARTNER ||--o{ LOGISTICS_API_KEY : issues
    LOGISTICS_PARTNER ||--o{ MERCHANT_STOCK_ALLOCATION : stores
    MERCHANT_STOCK_ALLOCATION ||--o{ STOCK_TRANSFER_REQUEST : moves
    ORDER ||--o| ORDER_FULFILLMENT_ASSIGNMENT : fulfills
    LOGISTICS_PARTNER ||--o{ ORDER_FULFILLMENT_ASSIGNMENT : executes

    LOGISTICS_PARTNER {
        uuid id PK
        string company_name
        string code
        string webhook_url
        string webhook_secret
        boolean operates_warehouse
        jsonb warehouse_locations
        boolean is_active
        datetime created_at
    }

    LOGISTICS_API_KEY {
        uuid id PK
        uuid partner_id FK
        string api_key_hash
        string key_prefix
        string permissions
        boolean is_revoked
        datetime created_at
    }

    MERCHANT_STOCK_ALLOCATION {
        uuid id PK
        uuid company_id FK
        uuid product_id FK
        uuid logistics_partner_id FK
        string warehouse_hub_code
        integer total_physical_stock
        integer reserved_stock
        integer available_stock
        datetime last_reconciled_at
    }

    STOCK_TRANSFER_REQUEST {
        uuid id PK
        uuid company_id FK
        uuid product_id FK
        uuid target_partner_id FK
        integer quantity_sent
        integer quantity_received
        string status
        string waybill_ref
        datetime created_at
    }

    ORDER_FULFILLMENT_ASSIGNMENT {
        uuid id PK
        uuid order_id FK
        uuid partner_id FK
        uuid stock_allocation_id FK
        string waybill_number
        string tracking_url
        string delivery_status
        decimal cod_collected
        datetime dispatched_at
    }
```

---

## Deliverables & Tasks

### 1. Database Migrations (`supabase/migrations/`)
- Create `logistics_partners` table for onboarding 3PL companies (Nova Express, GIG, Fez).
- Create `logistics_api_keys` table for authentication (`nv_live_...`).
- Create `merchant_stock_allocations` table for multi-hub stock management.
- Create `stock_transfer_requests` table for tracking physical inventory shipments.
- Create `order_fulfillment_assignments` table for tracking 3PL waybills and delivery status.

### 2. Core Domain Models (`packages/novasuite_core/lib/src/models/`)
- `LogisticsPartner`: Partner entity with webhook URL, secret, and coverage rules.
- `LogisticsApiKey`: Secret key manager with prefixing and hashing.
- `MerchantStockAllocation`: Physical inventory counts allocated to partner hubs.
- `StockTransferRequest`: Shipment requests sent from merchants to Nova Express.

### 3. Core Repositories (`packages/novasuite_core/lib/src/repositories/`)
- `LogisticsPartnerRepository`: CRUD operations for onboarding partners, issuing API keys, and defining state coverage.

### 4. Admin Partner Portal (`apps/novasuite_admin/lib/features/logistics/`)
- `LogisticsPartnersManagementPage`: UI for SuperAdmins to:
  - Onboard new logistics companies (Nova Express, 3PLs).
  - Issue API Keys (`nv_live_...`) and HMAC Webhook Signing Secrets.
  - Map regional coverage (e.g. Nova Express covers Lagos & Abuja).
  - View real-time API logs, delivery success rates, and partner latency.

```mermaid
sequenceDiagram
    autonumber
    actor Admin as NovaSuite SuperAdmin
    participant UI as Logistics Partner Management UI
    participant Repo as LogisticsPartnerRepository
    participant DB as Supabase DB

    Admin->>UI: Enters Partner Info (Nova Express, Webhook URL, Covered States)
    UI->>Repo: onboardPartner(partnerData)
    Repo->>DB: INSERT INTO logistics_partners
    Repo->>DB: INSERT INTO logistics_api_keys (generates nv_live_...)
    DB-->>Repo: Returns Created Partner & Raw API Key
    Repo-->>UI: Displays Secret Key & Signing Secret
    UI-->>Admin: Displays Credentials (One-Time View Modal)
```

---

## Verification Criteria

- Static analysis (`flutter analyze`): **0 Errors, 0 Warnings**.
- Successful creation of a test partner ("Nova Express") in the Admin Portal.
- Secure API key generation verified with SHA-256 hash checks.
