# Circuit Centers & Independent Delivery Agent (IDP) Rider App Specification

This specification documents the operational workflow of **Circuit Centers (Collation & Distribution Centers - CDCs)** and the personalized **White-Labeled IDP Rider Mobile App**.

---

## 📲 IDP Rider App Lifecycle & Handshake

```mermaid
sequenceDiagram
    autonumber
    actor Rider as Independent Delivery Agent (IDP)
    participant App as Personalized Rider App (Nova Express Branded)
    participant CDC as Circuit Center Hub (Ikeja CDC)
    actor Customer as End Customer

    Rider->>App: Logs in to Rider App (Tenant: Nova Express)
    App->>App: Loads Tenant Brand Theme (#10B981, Logo, App Title)
    App->>CDC: Toggles "Online" Status & Streams Live GPS Location
    
    CDC->>App: Pushes New Delivery Assignment (Waybill #NX-8812)
    Rider->>CDC: Scans Package Barcode & Accepts Assignment
    
    Rider->>Customer: Navigates via Integrated GPS Map to Customer Address
    Customer->>Rider: Pays ₦35,000 Cash on Delivery (COD)
    Rider->>App: Snaps Proof of Delivery (POD) Photo & Confirms Collection
    App->>CDC: Transmits Delivery Confirmation & COD Receipt
    Rider->>CDC: Deposits COD Cash at End of Shift & Reconciles Ledger
```

---

## 🎨 IDP Rider Mobile App Personalization Features

When a logistics company (e.g. Nova Express) registers on NovaSuite, their riders download the **NovaSuite Rider App**, which dynamically customizes itself:
1. **Dynamic App Branding**: Displays the logistics company's logo, splash screen, and brand primary/secondary colors.
2. **Custom Support Helpline**: Displays the specific logistics company's support number.
3. **Barcode & QR Scanner**: Built-in camera scanner for rapid package pickup at Circuit Centers.
4. **Offline POD Capture**: Allows riders to capture photos and signatures even in low-signal areas, auto-syncing when internet returns.
