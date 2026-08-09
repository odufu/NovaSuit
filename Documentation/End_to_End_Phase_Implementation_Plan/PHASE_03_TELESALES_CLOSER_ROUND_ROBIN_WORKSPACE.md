# Phase 3 Specification: Sales Call Rep (Telesales Closer) Round-Robin Workspace

**Focus Area**: Sales Call Rep Workspace, Automated Round-Robin Lead Distribution, Floating WebRTC/SIP Phone Dialer, Product Scripts, and Upsell Engine.

---

## 🔄 Telesales Closing Workflow

```mermaid
sequenceDiagram
    autonumber
    participant Queue as Round-Robin Lead Queue
    actor SalesRep as Sales Call Rep (Closer)
    participant Dialer as Nova Dialer (SIP WebRTC)
    actor Buyer as Buyer
    participant OrderDB as Supabase Order Store

    Queue->>SalesRep: Auto-allocates New Lead (Customer: Adeyemi Benson)
    SalesRep->>Dialer: Clicks "One-Click Dial Customer"
    Dialer->>Buyer: Initiates Outbound SIP Call (DID: 07003100077)
    
    Note over SalesRep,Buyer: Sales Rep Reads Product Closing Script
    
    SalesRep->>OrderDB: Confirms Order Details, Quantity (2 Packs) & Adds Upsell
    OrderDB-->>SalesRep: Order Status Updated -> CONFIRMED (Ready for Supervisor Approval)
```

---

## 💻 Telesales Closer UI Components

1. **Round-Robin Lead Queue Drawer**:
   - Displays real-time incoming leads assigned to the sales rep.
   - Shows lead age, delivery state, and UTM source.
2. **Integrated SIP Floating Dialer**:
   - WebRTC / UDP SIP softphone bar with Call, Mute, Hold, Transfer, and Call Recording triggers.
3. **Product Script & Objection Drawer**:
   - Interactive objection handling guide (e.g. price concerns, delivery timeframe FAQ).
4. **Order Confirmation & Upsell Calculator**:
   - Package selector (Single Pack vs. Buy 2 Get 1 Free Promo).
   - Real-time commission earnings estimator for the closer.
