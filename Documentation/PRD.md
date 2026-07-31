# Product Requirements Document (PRD)

## Product Name: NovaSuite CRM & NovaExpress Logistics System
**Version:** 1.0.0  
**Author:** Antigravity AI & Engineering Team  
**Target Platform:** Web, Windows, macOS, iOS, Android  
**Backend Infrastructure:** Supabase (PostgreSQL, Row Level Security, Edge Functions, Realtime, Storage)  

---

## 1. Executive Summary

NovaSuite is a multi-tenant, white-label Enterprise Resource Planning (ERP), Customer Relationship Management (CRM), and Logistics Management Suite. Designed primarily to replace legacy systems like **Pangea Suite**, NovaSuite powers **Nova Care** (and its sub-marketing companies) for herbal direct-to-consumer (D2C) sales, while orchestrating nationwide Cash-on-Delivery (COD) fulfillment via **Nova Express** and external 3rd-party logistics agencies/independent riders.

The platform provides complete dynamic branding, real-time supervisor authorization queues, atomic round-robin call rep order assignment, multi-warehouse stock management with inter-warehouse transfers (IWT), and cash reconciliation pipelines.

---

## 2. Product Objectives & Business Goals

- **High-Throughput Concurrency**: Process bursts of 10,000+ daily orders from digital marketing ad campaigns without race conditions or order assignment duplicates.
- **Dynamic Whitelabling**: Allow independent sub-companies to brand their portal (logos, primary/secondary color schemes, custom domains, currencies) dynamically.
- **Rider Operational Efficiency**: Provide riders with a native Bolt-like mobile application for iOS and Android with real-time GPS routing, offline proof of delivery (POD), and cash holding reconciliation.
- **Automated Financial Reconciliation**: Enforce rider COD credit limits and automate parent agency settlement math.
- **Zero Loss Inventory Management**: Model all stock locations (Central, Hubs, Rider Mini-Hubs) with real-time state tracking (`available`, `allocated`, `in_transit`, `damaged`).

---

## 3. User Roles & Access Hierarchy

| Role Code | Role Name | Scope & Key Capabilities |
| :--- | :--- | :--- |
| `super_admin` | Platform Super Admin | Global SaaS administration, tenant company onboarding, subscription management, global feature toggling. |
| `agm` | Assistant General Manager | Company budget allocation, digital marketer funding approvals, high-level revenue & ROAS reporting. |
| `supervisor` | Department Supervisor | Manages department reps, real-time approval of upsell/downsell requests, rep workload & KPI monitoring. |
| `digital_marketer` | Digital Marketer | Campaign tracking, ad spend logging, embedded form builder, FB Pixel/CAPI conversion attribution. |
| `sales_call_rep` | Sales Call Rep | Receives auto-assigned orders, calls customers, updates status, initiates upsell/downsell requests, selects logistics provider. |
| `logistics_call_rep`| Logistics Call Rep | Confirms customer location/availability, assigns order to specific rider/warehouse, updates to `agent_notified`. |
| `delivery_agent` | Rider / Delivery Agent | Uses mobile app to accept jobs, navigate to customer, collect COD cash, upload proof of delivery, and remit cash. |
| `finance_manager` | Finance Manager | Verifies rider bank transfer receipts, clears COD credit balances, manages agency bulk settlements. |

---

## 4. Functional Requirements

### 4.1 Module A: Whitelabel & Multi-Tenancy Engine
- **FR-A1**: System MUST enforce absolute tenant data isolation across all tables using PostgreSQL Row Level Security (RLS) policies based on `company_id`.
- **FR-A2**: System MUST dynamically apply brand tokens (`primary_color`, `secondary_color`, `logo_url`, `currency_symbol`, `font_family`) stored in `tenant_settings` to the Flutter UI at runtime.
- **FR-A3**: System MUST support custom subdomains (e.g. `companyA.novasuite.com`).

### 4.2 Module B: Product Catalog & Atomic Order Assignment Engine
- **FR-B1**: Products MUST be attached to specific Sales Call Reps (`product_call_reps`). Only attached reps can receive orders for that product.
- **FR-B2**: The `/submit-order` webhook MUST execute `assign_order_round_robin()` atomically using `FOR UPDATE` row locks to assign incoming orders to the rep with the lowest `pending_orders_count`.
- **FR-B3**: Digital Marketers MUST only create ad campaigns for products assigned to their company.

### 4.3 Module C: Digital Marketing & Conversion Attribution
- **FR-C1**: System MUST record AGM budget top-ups for Marketer Accounts (`marketer_budgets`).
- **FR-C2**: Webhook ingestion MUST fire asynchronous Facebook Conversions API (CAPI) events with SHA-256 hashed customer phone/name data for accurate ad attribution.
- **FR-C3**: System MUST calculate real-time ROAS:
  $$\text{ROAS} = \frac{\text{Delivered Cash Revenue}}{\text{Logged Ad Spend}}$$

### 4.4 Module D: Sales Call Rep Dialer & Supervisor Approval Queue
- **FR-D1**: Sales Reps MUST view orders assigned to them with quick-dial phone links.
- **FR-D2**: Order Statuses MUST follow: `new` $\rightarrow$ `assigned_to_rep` $\rightarrow$ `contacting` $\rightarrow$ `accepted` / `on_hold` / `cancelled`.
- **FR-D3**: When a Sales Rep modifies order pricing/items, status MUST transition to `upsell_pending` and send a real-time push notification to the Department Supervisor.
- **FR-D4**: Supervisors MUST approve or reject upsell requests in one click. Approved upsells update total amount and move to `accepted`.

### 4.5 Module E: Logistics Network & Dual-Call Rep Confirmation
- **FR-E1**: Accepted orders MUST transition to the Logistics Confirmation queue.
- **FR-E2**: Logistics Call Reps MUST call customers to verify delivery address readiness before marking order as `logistics_confirmed` and assigning a rider/agency.
- **FR-E3**: System MUST support 3 logistics provider types:
  1. Nova Express (In-House Agency with internal hubs/riders)
  2. 3rd-Party Logistics Agencies (External agencies with child riders)
  3. Direct Independent Riders (Freelance riders holding personal mini-hub stock)

### 4.6 Module F: Multi-Warehouse Inventory & Inter-Warehouse Transfers (IWT)
- **FR-F1**: System MUST model every stock holding point (Central, Hub, Rider Mini-Hub) as a `warehouse`.
- **FR-F2**: Inventory MUST maintain 4 real-time quantities per product: `quantity_available`, `quantity_allocated`, `quantity_in_transit`, and `quantity_damaged`.
- **FR-F3**: Stock transfers between warehouses MUST generate a unique Waybill Number (`waybill_number`) and track dispatch vs. receipt quantity discrepancies.

### 4.7 Module G: Cash-on-Delivery (COD) Reconciliation Engine
- **FR-G1**: Independent Riders MUST have a configurable `max_cod_credit_limit` (Default: ₦150,000).
- **FR-G2**: When a rider's `current_cod_balance` exceeds their credit limit, the system MUST block new order assignments until cash is remitted.
- **FR-G3**: Riders MUST upload bank deposit receipts via the Rider Mobile App. Finance Managers verify receipts to clear the rider's COD balance.

### 4.8 Module H: Legacy Pangea Suite Migration
- **FR-H1**: System MUST provide an ETL script to import historical CSV data from Pangea Suite (Products, Customers, Reps, Historical Orders).

---

## 5. Non-Functional Requirements (NFRs)

- **NFR-1: Performance**: Webhook `/submit-order` response time MUST be $< 300\text{ms}$ under 500 concurrent requests/sec.
- **NFR-2: Scalability**: Database connection pooler (Supavisor) MUST support up to 5,000 concurrent database connections.
- **NFR-3: Security**: Passwords and JWT tokens handled via Supabase Auth. Sensitive customer phone numbers hashed for ad integrations.
- **NFR-4: Offline Capability**: Flutter Rider Mobile App MUST support offline job status updates and sync queued data when network reconnects.

---

## 6. Project Deliverables

1. **Supabase Backend**: Complete SQL migrations, RLS security policies, and Edge Functions.
2. **Flutter Admin Portal (`novasuite_admin`)**: Web/Desktop app for AGMs, Supervisors, Sales Reps, Logistics Reps, Marketers, Finance Managers.
3. **Flutter Rider Mobile App (`novaexpress_rider`)**: iOS & Android app for NovaExpress and Independent Riders.
4. **Shared Package (`novasuite_core`)**: Dart library with models and dynamic whitelabel theme engine.
5. **Documentation**: PRD and Implementation Architecture Blueprint.
