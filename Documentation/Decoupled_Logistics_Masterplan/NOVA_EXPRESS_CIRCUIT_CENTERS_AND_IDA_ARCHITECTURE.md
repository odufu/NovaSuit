# Nova Express Architecture: Circuit Centers, Distribution Network & Independent Delivery Agents (IDPs)

This specification defines the internal structural architecture for **Nova Express**, detailing the hierarchical relationship between **Nova Express Central**, regional **Circuit Centers (Collation & Distribution Centers - CDCs)**, and **Independent Delivery Agents (IDPs)**.

---

## 1. Nova Express Structural Hierarchy

```mermaid
graph TD
    subgraph HQ ["NovaSuite Core Hub"]
        NovaSuiteCRM["NovaSuite Merchant CRM"]
    end

    subgraph Central ["Nova Express Central HQ"]
        MasterConsole["Nova Express Master Network Console"]
        StockRedistributor["Inter-CDC Stock Redistribution Engine"]
    end

    subgraph CircuitCenters ["Regional Circuit Centers / CDCs (Nigeria Network)"]
        CDC_Ikeja["Ikeja Circuit Center (Lagos West Hub)"]
        CDC_Lekki["Lekki Circuit Center (Lagos East Hub)"]
        CDC_Abuja["Garki Circuit Center (Abuja FCT Hub)"]
        CDC_PH["Port Harcourt Circuit Center (Rivers Hub)"]
    end

    subgraph Agents ["Independent Delivery Agents (IDPs / Riders)"]
        IDA_1["Independent Agent (Ikeja Zone 1)"]
        IDA_2["Independent Agent (Ikeja Zone 2)"]
        IDA_3["Independent Agent (Abuja Central)"]
    end

    NovaSuiteCRM -- Open API Webhook Stream --> MasterConsole
    MasterConsole --> StockRedistributor
    StockRedistributor -- Allocates Stock & Routing --> CDC_Ikeja
    StockRedistributor -- Allocates Stock & Routing --> CDC_Lekki
    StockRedistributor -- Allocates Stock & Routing --> CDC_Abuja
    StockRedistributor -- Allocates Stock & Routing --> CDC_PH

    CDC_Ikeja -- Manual / Auto Dispatch --> IDA_1
    CDC_Ikeja -- Manual / Auto Dispatch --> IDA_2
    CDC_Abuja -- Manual / Auto Dispatch --> IDA_3
```

---

## 2. Operational Roles & Responsibilities

### Tier 1: Nova Express Central (Master Headquarters)
- **Circuit Center Onboarding**: Onboards new regional Circuit Centers / Collation & Distribution Centers (CDCs) across states in Nigeria.
- **Inter-CDC Stock Redistribution**: Orchestrates bulk inventory movements between distribution centers (e.g. moving 200 excess units from Ikeja CDC to Abuja CDC).
- **Master COD & Financial Settlement**: Aggregates Cash-on-Delivery collections from all CDCs and remits net settlements back to NovaSuite merchants.

### Tier 2: Circuit Centers / Collation & Distribution Centers (CDCs)
- **Physical Warehousing & Holding**: Receives merchant stock shipments, stores physical inventory, and manages bin locations.
- **IDA Onboarding & Attachment**: Onboards, verifies, and attaches Independent Delivery Agents (IDPs) to the specific Circuit Center.
- **Hybrid Dispatch Engine (Auto & Manual)**:
  - **Auto-Dispatch**: Automatically assigns orders to available IDPs based on proximity geofencing, rider capacity, and workload.
  - **Manual Override**: Allows the Circuit Center Dispatcher to manually assign or re-assign specific waybills to high-priority IDPs.

### Tier 3: Independent Delivery Agents (IDPs / Riders)
- **Pickup & Verification**: Collects physical packages from their attached Circuit Center hub.
- **Last-Mile Delivery**: Navigates to customer address using the Nova Express Rider App.
- **COD Collection & Deposit**: Collects Cash-on-Delivery (or transfer) from customer and deposits funds back to their assigned Circuit Center at the end of shift.

---

## 3. Circuit Center Order Dispatch & Stock Allocation Lifecycle

```mermaid
sequenceDiagram
    autonumber
    actor Merchant as NovaSuite Merchant
    participant Central as Nova Express Central
    participant CDC as Ikeja Circuit Center (CDC)
    actor IDA as Independent Delivery Agent (IDP)
    actor Customer as End Customer

    Merchant->>Central: Dispatches Bulk Stock Batch (1,000 Units)
    Central->>CDC: Allocates 600 Units to Ikeja CDC & 400 Units to Abuja CDC
    Note over CDC: Physical Stock Received, Scanned & Held at Ikeja CDC Bin #B-14
    
    rect rgb(235, 248, 240)
        Note over Merchant,Customer: Live Order Dispatch & Fulfillment
        Merchant->>Central: Live Order Webhook (Customer Address: Ikeja, Lagos)
        Central->>CDC: Routes Order to Ikeja CDC (Deducts 1 Unit Reserved)
        
        alt Automated Dispatch Mode
            CDC->>IDA: Auto-assigns waybill based on GPS Proximity & Active Capacity
        else Manual Dispatcher Override Mode
            CDC->>IDA: Hub Dispatcher manually assigns waybill to IDA
        end

        IDA->>CDC: Collects Package from Ikeja CDC Hub
        IDA->>Customer: Delivers Order & Collects ₦35,000 COD
        IDA->>CDC: Deposits COD Cash & Scans Proof of Delivery (POD)
        CDC->>Central: Reconciles Delivery & Remits Net Funds to NovaSuite CRM
    end
```

---

## 4. Entity Relationship Diagram: Circuit Centers & IDPs

```mermaid
erDiagram
    NOVA_EXPRESS_CENTRAL ||--o{ CIRCUIT_CENTER : manages
    CIRCUIT_CENTER ||--o{ INDEPENDENT_DELIVERY_AGENT : onboards
    CIRCUIT_CENTER ||--o{ CDC_STOCK_INVENTORY : holds
    CIRCUIT_CENTER ||--o{ WAYBILL_DISPATCH : processes
    INDEPENDENT_DELIVERY_AGENT ||--o{ WAYBILL_DISPATCH : executes

    CIRCUIT_CENTER {
        uuid id PK
        string center_name "e.g. Ikeja CDC"
        string hub_code "e.g. NX-LAGOS-IKEJA"
        string state "Lagos"
        string city "Ikeja"
        string address
        string manager_name
        string manager_phone
        jsonb covered_coverage_zones
        boolean is_active
    }

    INDEPENDENT_DELIVERY_AGENT {
        uuid id PK
        uuid circuit_center_id FK
        string full_name
        string phone_number
        string vehicle_type "BIKE | VAN | CAR"
        string verification_status "VERIFIED | PENDING"
        boolean is_online
        point current_gps_location
    }

    CDC_STOCK_INVENTORY {
        uuid id PK
        uuid circuit_center_id FK
        uuid product_id FK
        integer physical_quantity
        integer reserved_quantity
        integer available_quantity
    }

    WAYBILL_DISPATCH {
        uuid id PK
        uuid circuit_center_id FK
        uuid agent_id FK
        string waybill_number
        string dispatch_mode "AUTO_PROXIMITY | MANUAL_OVERRIDE"
        string status "ASSIGNED | PICKED_UP | DELIVERED | RETURNED"
        decimal cod_collected
        datetime dispatched_at
    }
```

---

## 5. Summary of Integration Points with NovaSuite

1. **NovaSuite Master Stock Allocation**: Merchants allocate stock to Circuit Center hub codes (`hub_code`).
2. **Nova Express Central Routing**: Orders are streamed to Nova Express Central, which routes them to the correct regional Circuit Center.
3. **Circuit Center Hybrid Dispatch**: Circuit Center dispatchers or auto-algorithms assign waybills to Independent Delivery Agents (IDPs).
4. **Callback Loop**: Delivery resolutions and COD collections are reported back through Circuit Center $\rightarrow$ Central $\rightarrow$ NovaSuite CRM.
