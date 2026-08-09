# Phase 5 Specification: Logistics CDC Manager & Hybrid Dispatch Engine

**Focus Area**: Circuit Center (CDC) Management, Inbound Stock Receiving, Barcode Scanner, Hybrid Auto/Manual Order Dispatch Console, and Waybills.

---

## 🚚 CDC Warehouse & Dispatch Flow

```mermaid
sequenceDiagram
    autonumber
    actor Merchant as NovaSuite Merchant
    actor CDCManager as CDC Hub Manager
    participant DispatchConsole as Hybrid Dispatch Console
    actor IDPRider as Independent Delivery Agent (IDP Rider)

    Merchant->>CDCManager: Dispatches 500 Stock Units to Ikeja CDC
    CDCManager->>CDCManager: Scans Shipment Barcodes & Accepts Stock (500 Units Available)
    
    rect rgb(235, 248, 240)
        Note over DispatchConsole,IDPRider: Order Dispatch Cycle
        DispatchConsole->>DispatchConsole: Receives Order Webhook (Destination: Ikeja, Lagos)
        
        alt Auto-Proximity Dispatch Mode
            DispatchConsole->>IDPRider: Auto-assigns waybill to nearest online rider via GPS
        else Manual Dispatcher Override
            DispatchConsole->>IDPRider: Dispatcher manually assigns waybill (#NX-WAYBILL-9912)
        end

        IDPRider->>CDCManager: Scans Waybill Barcode & Picks Up Physical Package
        CDCManager-->>DispatchConsole: Order Status Updated -> IN_TRANSIT
    end
```

---

## 💻 Logistics CDC UI Components

1. **Circuit Centers Directory**:
   - Manage regional distribution hubs across Nigeria (Ikeja CDC, Lekki CDC, Abuja CDC).
2. **Inbound Stock Receiving Console**:
   - Barcode scanner interface for confirming incoming merchant inventory shipments.
3. **Hybrid Dispatch Console**:
   - Split-screen view: Pending Waybills vs Active Online IDP Riders on a live GPS map.
   - Barcoded Waybill PDF generator & thermal print trigger.
