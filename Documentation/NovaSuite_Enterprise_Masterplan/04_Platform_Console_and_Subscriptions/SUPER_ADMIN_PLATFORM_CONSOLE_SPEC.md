# Super Admin Platform Console & Subscription Management Specification

This specification documents the **Super Admin Master Console** used by NovaSuite platform owners to manage tenant companies, subscription tiers, pricing offers, addon provisioning, and complaints.

---

## 🏛️ Super Admin Console Architecture

```mermaid
graph TD
    subgraph MasterConsole ["NovaSuite Super Admin Master Console"]
        TenantManager["Company Onboarding & Type Assignment Engine"]
        SubscriptionBilling["Subscription Tiers & Billing Manager"]
        AddonProvisioner["SIP Telephony, WhatsApp & SMS Provisioning"]
        ComplaintsSystem["Tenant Complaints & Support System"]
        AuditLedger["Immutable Financial Audit & System Log"]
    end

    subgraph Subscriptions ["Subscription Offers & Tiers"]
        StarterTier["Starter Tier (E-Commerce Only)"]
        GrowthTier["Growth Tier (E-Commerce + Telephony)"]
        EnterpriseTier["Enterprise Tier (E-Commerce + Logistics + Custom Branding)"]
        LogisticsTier["Logistics Standalone Tier (Nova Express Fleet System)"]
    end

    TenantManager --> Subscriptions
    SubscriptionBilling --> Subscriptions
    AddonProvisioner --> AuditLedger
    ComplaintsSystem --> AuditLedger
```

---

## 🖥️ Super Admin UI Components

| Module | Function | Features |
| :--- | :--- | :--- |
| **Company Directory** | Onboard & manage tenant companies | Create Company Modal (Select: E-Commerce vs. Logistics), Custom Domain Setter, Subdomain Manager, Active Status Toggle |
| **Subscriptions & Pricing Tiers** | Define SaaS plans & billing offers | Create Plan Form (Price per Month, Included Orders, Telephony Inclusion Toggle, Logistics Module Access), Discount Codes |
| **Addon Provisioner** | Provision Telephony DIDs & APIs | Assign SIP DIDs, WhatsApp API Credentials, SMS Gateway Keys to specific Tenants |
| **Complaints & Support Center** | Ticket management for tenant issues | Ticket Inbox, Status Assignment (Open, In Progress, Resolved), SLA Countdown Timer |
| **Global Financial Audit Log** | Platform revenue & data integrity audit | System Audit Log Viewer, Immutable Event History, System Health Dashboard |
