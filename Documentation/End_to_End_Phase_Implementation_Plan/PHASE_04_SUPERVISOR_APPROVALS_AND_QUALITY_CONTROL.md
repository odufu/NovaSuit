# Phase 4 Specification: Supervisor Squad Console & Quality Approvals

**Focus Area**: Supervisor Squad Management, Call Recording Quality Audit, Order Approval Queue, and Merchant Stock Allocation to Logistics.

---

## 🔍 Supervisor Approval & Stock Routing Lifecycle

```mermaid
sequenceDiagram
    autonumber
    actor SalesRep as Telesales Rep
    actor Supervisor as Sales Supervisor
    participant CRM as NovaSuite Orders Engine
    participant StockManager as Merchant Stock Manager
    actor NovaExpress as Nova Express Hub

    SalesRep->>CRM: Submits Confirmed Order (ORD-2026-9912)
    CRM->>Supervisor: Alerts Supervisor Queue ("Needs Approval")
    
    Supervisor->>Supervisor: Listens to Call Recording & Audits Order Details
    
    alt Order Approved
        Supervisor->>CRM: Approves Order (Status: CONFIRMED_APPROVED)
        CRM->>StockManager: Checks Merchant Stock at Target Hub (NX-LAGOS-IKEJA)
        StockManager->>StockManager: Reserves 1 Unit Physical Stock
        StockManager->>NovaExpress: Emits Webhook: order.ready_for_fulfillment
    else Order Flagged / Fake Address
        Supervisor->>CRM: Rejects Order or Re-assigns to Call Rep with Note
    end
```

---

## 💻 Supervisor UI Features

1. **Squad Performance Board**:
   - Live metrics per agent (Calls Made, Total Talk Time, Confirmation Rate %, Upsell Rate %).
2. **Order Approval Queue**:
   - Fast approval modal with integrated audio call player, address verification, and one-click approve/reject actions.
3. **Agent Lead Re-assignment Console**:
   - Re-assign dormant leads from underperforming agents to top closers.
