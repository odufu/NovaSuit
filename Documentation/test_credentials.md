# Test Accounts & Credentials Reference Sheet

**Project:** NovaSuite White-Label CRM & NovaExpress Logistics Platform  
**Supabase Project ID:** `oygtaeriljuelhshfvkv`  
**Supabase URL:** `https://oygtaeriljuelhshfvkv.supabase.co`  
**SQL Seed File:** [`supabase/migrations/20260724000001_seed_test_data.sql`](file:///c:/PROJECT/novasuite/supabase/migrations/20260724000001_seed_test_data.sql)  

---

## 🔑 Test User Accounts Matrix

Use these credentials to log in and test different role capabilities across **NovaSuite Admin** and **NovaExpress Rider**:

| Role Name | Email Address | Password | Company Tenant | User UUID | Key System Permissions |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Super Admin** | `superadmin@novasuite.com` | `password123` | Nova Care Herbal | `00000000-0000-4000-8000-000000000000` | Global SaaS administration, tenant onboarding, subscription management. |
| **AGM (General Manager)** | `agm@novacare.com` | `password123` | Nova Care Herbal | `10000000-0000-4000-8000-000000000001` | Marketer ad budget allocations, high-level ROAS analytics & executive reports. |
| **Department Supervisor** | `supervisor@novacare.com` | `password123` | Nova Care Herbal | `20000000-0000-4000-8000-000000000002` | Real-time Up-sell & Down-sell Approval Queue, team performance metrics. |
| **Sales Call Rep 1** | `salesrep.john@novacare.com` | `password123` | Nova Care Herbal | `30000000-0000-4000-8000-000000000003` | Round-Robin Call Queue, customer dialing, initiating up-sell/down-sell requests. |
| **Sales Call Rep 2** | `salesrep.sarah@novacare.com` | `password123` | Nova Care Herbal | `40000000-0000-4000-8000-000000000004` | Round-Robin Call Queue, customer dialing, initiating up-sell/down-sell requests. |
| **Digital Marketer** | `marketer.david@novacare.com` | `password123` | Nova Care Herbal | `50000000-0000-4000-8000-000000000005` | Ad campaign logging, Facebook CAPI webhook snippets, ROAS tracking. |
| **Logistics Call Rep** | `logisticsrep@novaexpress.com`| `password123` | Nova Express | `60000000-0000-4000-8000-000000000006` | Customer address verification, rider assignment, `agent_notified` status updates. |
| **Delivery Agent / Rider** | `rider.emeka@novaexpress.com` | `password123` | Nova Express | `70000000-0000-4000-8000-000000000007` | Rider Mobile App, map navigation, POD signature/photo capture, COD remittance. |
| **Finance Manager** | `finance@novacare.com` | `password123` | Nova Care Herbal | `80000000-0000-4000-8000-000000000008` | COD cash deposit receipt verification, rider credit limit clearing, agency settlements. |
| **HR Manager** | `hr@novacare.com` | `password123` | Nova Care Herbal | `90000000-0000-4000-8000-000000000009` | Staff directory management, onboarding employees, role & supervisor assignments. |
| **GM Logistics / Inventory Manager** | `inventory@novacare.com` | `password123` | Nova Care Herbal | `a0000000-0000-4000-8000-00000000000a` | Products catalog creation, SKU pricing, nationwide warehouse matrix, IWT Waybills. |

---

## 🏢 Tenant Companies Reference

| Company Name | Company Type | Company UUID | Primary Whitelabel Color | Currency Symbol |
| :--- | :--- | :--- | :--- | :--- |
| **Nova Care Herbal** | D2C Marketing | `11111111-1111-4111-8111-111111111111` | Emerald Green (`#1B4D3E`) | `₦` (NGN) |
| **Nova Express Logistics** | Logistics Provider | `22222222-2222-4222-8222-222222222222` | Royal Blue (`#0F4C81`) | `₦` (NGN) |
| **Herbal Life Co** | D2C Sub-Company | `33333333-3333-4333-8333-333333333333` | Deep Orange (`#D35400`) | `$` (USD) |

---

## 🏭 Warehouse Reference

| Warehouse Name | Type | Warehouse UUID | Location State |
| :--- | :--- | :--- | :--- |
| **Lagos Central Factory Hub** | Central Factory | `c1111111-1111-4111-8111-111111111111` | Lagos |
| **Abuja Regional Hub (NovaExpress)** | Agency Hub | `c2222222-2222-4222-8222-222222222222` | Abuja |
| **Rider Emeka Mini-Hub** | Rider Mini-Hub | `c3333333-3333-4333-8333-333333333333` | Lagos / Port Harcourt |

---

## 🚀 How to Execute Database Seeding

To load or reset these test accounts in your Supabase backend:
1. Open your [Supabase Dashboard SQL Editor](https://supabase.com/dashboard/project/oygtaeriljuelhshfvkv/sql/new).
2. Copy and execute `supabase/migrations/20260724000000_init_novasuite_schema.sql` (if database is empty).
3. Copy and execute `supabase/migrations/20260724000001_seed_test_data.sql`.

