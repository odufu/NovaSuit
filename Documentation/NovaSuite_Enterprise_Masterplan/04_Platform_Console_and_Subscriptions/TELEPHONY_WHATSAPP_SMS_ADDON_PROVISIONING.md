# Telephony, WhatsApp & SMS Add-on Provisioning Specification

This specification details how NovaSuite abstracts complex third-party telecom integrations so tenant companies can configure Telephony, WhatsApp Business API, and SMS Gateways with **simple non-technical inputs**.

---

## 📞 Integration Architecture

```mermaid
sequenceDiagram
    autonumber
    actor Tenant as Tenant Company Admin (NovaCare / Nova Express)
    participant CRMUI as NovaSuite Tenant Settings UI
    participant MasterAdmin as NovaSuite Super Admin
    participant TelecomProvider as Telecom / SMS / WhatsApp Gateway (IT Sky / Termii / Meta)

    rect rgb(235, 248, 240)
        Note over Tenant,TelecomProvider: 1. Telephony (SIP DID) Provisioning
        Tenant->>CRMUI: Applies for Telephony Add-on (Selects Plan)
        CRMUI->>MasterAdmin: Alerts Super Admin of Telephony Application
        MasterAdmin->>TelecomProvider: Requests SIP Trunk DID Allocation (e.g. 07003100077)
        TelecomProvider-->>MasterAdmin: Returns DID Credentials & Host
        MasterAdmin->>CRMUI: Assigns DID & Credentials to Tenant Account
        CRMUI-->>Tenant: Unlocks In-Browser SIP Calling & Dialer
    end

    rect rgb(240, 240, 255)
        Note over Tenant,TelecomProvider: 2. WhatsApp & SMS Simplified Setup
        Tenant->>CRMUI: Inputs Simple Credentials (WhatsApp Phone ID / SMS Sender ID & API Key)
        CRMUI->>CRMUI: Encrypts Keys & Validates Webhook Connection
        CRMUI-->>Tenant: Unlocks Automated WhatsApp Order Alerts & Termii SMS Updates
    end
```

---

## 🛠️ Simplified Tenant Configuration Fields

### 1. Telephony Settings (SIP In-Browser Call Center)
- **Status Badge**: `Active (DID: 07003100077)`
- **Configuration Inputs**: Tenant simply toggles **Enable In-Browser SIP Calling**. All technical SIP hosts, ports, and credentials are automatically provisioned by NovaSuite Master Admins.

### 2. WhatsApp Business API Settings
- **Phone Number ID**: Non-technical ID field copied from Meta Developer Portal.
- **Permanent Access Token**: Secure input field for automated WhatsApp order confirmations.
- **Enabled Automated Templates**: Toggle templates for *Order Confirmed*, *Out for Delivery*, and *Delivered*.

### 3. SMS Gateway Settings (Termii / Africa's Talking)
- **SMS Sender ID**: Registered 11-character Sender Name (e.g. `NOVACARE`).
- **API Key**: API Key string copied from SMS provider.
- **Enabled Alerts**: Toggle automated SMS dispatch alerts to buyers.
