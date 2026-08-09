# E-Commerce Suite: End-to-End Workflow & Component Specification

This specification documents the complete lifecycle for **E-Commerce Merchant Tenants** (e.g. NovaCare, Leafora) operating on NovaSuite, spanning Marketing Lead Generation, Telesales Closing, Order Tracking, and Logistics Stock Attachment.

---

## 🔄 End-to-End E-Commerce Workflow

```mermaid
sequenceDiagram
    autonumber
    actor Marketer as Digital Marketer
    actor Customer as Buyer
    actor SalesRep as Telesales Closer Agent
    participant NovaSuite as NovaSuite E-Commerce Suite
    actor Logistics as Partner Logistics (Nova Express)

    Marketer->>NovaSuite: Generates Form Script for Landing Page (TikTok / FB Ad)
    Customer->>NovaSuite: Submits Form (Order Status: NEW_ORDER)
    NovaSuite->>SalesRep: Auto-allocates Lead to Sales Rep (Round-Robin)
    
    SalesRep->>Customer: Calls Customer via Integrated Telephony (SIP / Mobile)
    
    alt Order Confirmed by Closer
        SalesRep->>NovaSuite: Confirms Order, Quantity, Base Price & Upsells
        NovaSuite->>Logistics: Streams Order to Nova Express Hub (Status: CONFIRMED)
        Logistics-->>NovaSuite: Assigns Waybill & IDP Rider (#NX-8812)
        Logistics->>Customer: Rider Delivers Package & Collects COD (₦35,000)
        Logistics->>NovaSuite: Reports DELIVERED Status & Remits COD Cash
    else Customer Cancels / Switched Off
        SalesRep->>NovaSuite: Updates Status (CANCELLED / SWITCHED_OFF)
        NovaSuite->>Marketer: Analytics: Flags Ad Campaign Quality
    end
```

---

## 💻 UI Component Specifications (E-Commerce Suite)

| Screen / Tab | Purpose | UI Components |
| :--- | :--- | :--- |
| **Marketing Dashboard** | Campaign ROI & Ad Spend Tracking | Ad Spend Input, Cost-per-Order Metric Cards, Campaign Comparison Bar Chart, Form Generator Modal |
| **Sales Call Center Suite** | Telesales Closing Workspace | Round-Robin Lead Queue, Integrated SIP Floating Dialer, Product Script Drawer, Upsell/Downsell Calculator, Order Activity Timeline |
| **Order Directory** | Full Order Lifecycle Operations | Multi-Filter Data Table (New, Confirmed, In Transit, Delivered, Cancelled), Waybill PDF Generator, Bulk Re-assignment Modal |
| **Stock Allocation Tab** | Multi-Warehouse Stock Management | Physical Stock Allocation Table, Stock Transfer Request Form, Hub Balance Badges (Ikeja, Abuja, PH) |
