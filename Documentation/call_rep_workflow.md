# NovaSuite Sales Call Rep Operational Workflow & Call Center Guide

This document outlines the complete operational workflow for **Sales Call Reps (Supervisees)** within NovaSuite’s Call Center & CRM Suite. It details the step-by-step lifecycle of lead processing, live call handling, 4-tab macro status tagging, automated callback timers, real-time organogram reporting, and marketing lead recycling hand-off.

---

## 1. End-to-End Call Rep Workflow Architecture

```mermaid
flowchart TD
    Start(["📥 Lead Inflow / Assigned Queue"]) --> Filter["🔍 Live Dialer Queue Filter<br/>(All Statuses, New Leads, Call Backs, etc.)"]
    Filter --> SelectOrder["👤 Select Customer Order & Initiate Dialing"]
    SelectOrder --> Dialer["📞 NovaDialer Active Call Screen"]
    
    Dialer --> Script["📜 Review Product-Attached Script<br/>(Grazer Herbal, Vitality Booster, Clear Skin)"]
    Dialer --> CallAction{"📞 End Call Action"}
    
    CallAction --> Modal["📋 4-Tab Call Outcome Modal"]
    
    Modal --> Tab1["🟢 Confirm & Upsell"]
    Modal --> Tab2["⏰ Reschedule Call"]
    Modal --> Tab3["📵 Unreachable"]
    Modal --> Tab4["❌ Closed / Recycle"]
    
    Tab1 --> Confirmed["✅ Order Confirmed / Upsell Pending"]
    Confirmed --> Logistics["🚚 Auto-Dispatched to Logistics App"]
    
    Tab2 --> Picker["📅 Set Date & Time Callback Picker"]
    Picker --> Countdown["⏰ Scheduled Callback Queue<br/>(Live T-Minus Countdown & Overdue Alerts)"]
    
    Tab3 --> UnreachableTag["📵 Tagged: Not Picking / Switched Off / Not Reachable"]
    UnreachableTag --> MktConsole["📢 Automated Marketing Retargeting Queue<br/>(SMS, WhatsApp, Email Campaigns)"]
    
    Tab4 --> ClosedTag["❌ Tagged: Cancelled / Rejected / Duplicate / No Stock"]
    ClosedTag --> CancelModal["📝 Log Cancellation Reason"]
    CancelModal --> MktConsole
    
    Confirmed --> Organogram["📊 Auto-Sync to Supervisor, AHOD & HOD Consoles<br/>(Supervisees Real-Time Performance Table)"]
    UnreachableTag --> Organogram
    ClosedTag --> Organogram
    
    style Start fill:#0A2E23,stroke:#10B981,color:#fff
    style Dialer fill:#1E3E33,stroke:#34D399,color:#fff
    style Modal fill:#0F172A,stroke:#3B82F6,color:#fff
    style Confirmed fill:#064E3B,stroke:#10B981,color:#fff
    style Countdown fill:#2E1065,stroke:#8B5CF6,color:#fff
    style MktConsole fill:#1E3A8A,stroke:#3B82F6,color:#fff
    style Organogram fill:#0F172A,stroke:#10B981,color:#fff
```

---

## 2. Core Call Console Components

### A. Live Call Queue & Status Filters
- Reps access their personal call queue featuring full search across Customer Name, Phone Number, State, and City.
- **Status Filter Bar**: Allows reps to filter their active leads by 28 precise status categories (e.g., `New Lead`, `Confirmed`, `Call Back`, `Not Picking`, `Switched Off`, `Delivery Rescheduled`, `Cancelled`, etc.).
- **Page Truncation Removed**: Displays all matching orders directly in a smooth scrollable list for instant access.

### B. Product-Attached Call Scripts
- Every assigned lead displays its specific product bundle value proposition:
  - **Grazer Herbal Detox**: Organic toxin flush, digestion aid, and daily vitality.
  - **Vitality Booster**: Maca Root & Ginseng stamina enhancer.
  - **Clear Skin Care**: Hydration, blemish clearing, and glowing skin.
- **Script Bar**: Floating interactive widget providing verified greetings, objection handling, and COD closing templates.

---

## 3. The 4-Tab Call Outcome Modal

When a call ends, reps use the **4-Tab Outcome Modal** to tag the lead in under 5 seconds:

| Category Tab | Icon & Color | Included CRM Statuses | Operational Action |
| :--- | :--- | :--- | :--- |
| **1. Confirm & Upsell** | 🟢 Emerald | `Confirmed`, `Upsell Requested`, `Dispatch Assigned` | Locks order details, queues upsell for Supervisor approval, and routes to Logistics. |
| **2. Reschedule Call** | ⏰ Purple | `Call Back Later`, `Delivery Rescheduled`, `Not Ready Today` | Automatically opens the **Date & Time Reschedule Modal** to lock callback time. |
| **3. Unreachable** | 📵 Blue | `Not Picking`, `Switched Off`, `Not Reachable`, `Agent Notified` | Tags lead for **Marketing Retargeting Queue** (SMS/WhatsApp campaigns). |
| **4. Closed / Recycle** | ❌ Red | `Cancelled`, `Rejected`, `No Product Stock`, `Duplicate`, `Returned`, `On Hold` | Opens cancellation logger, removes from active queue, and routes to Lead Recycling. |

---

## 4. Callback & Reschedule Management

```mermaid
sequenceDiagram
    autonumber
    actor Rep as Sales Call Rep
    participant CRM as NovaSuite CRM
    participant Timer as Live T-Minus Timer
    actor Customer as Customer

    Rep->>CRM: Selects "Call Back Later" or "Delivery Rescheduled"
    CRM-->>Rep: Opens Date & Time Picker Modal
    Rep->>CRM: Selects Date, Time & Reschedule Note
    CRM->>Timer: Saves scheduledCallbackAt & rescheduleNote
    
    loop Every 1 Second
        Timer-->>Rep: Updates T-Minus Countdown Card (e.g. 02h 15m 30s)
    end

    Note over Timer,Rep: When Timer Expires (T-Minus <= 0)
    Timer-->>Rep: Displays Glowing Red Alert (🚨 OVERDUE BY 15m)
    Rep->>Customer: Initiates Priority Re-dial
```

---

## 5. Automated Supervisor Console & Organogram Reporting

- **Zero Manual WhatsApp Submission**: Sales reps no longer manually format or copy text daily reports over WhatsApp.
- **Real-Time Organogram Auto-Sync**:
  - As reps log call outcomes, metrics instantly aggregate upward across the 4-tier organogram:
    - **Supervisee Level**: Displays personal daily CRM breakdown table (Products assigned, total assigned, confirmed, delivered, rescheduled, switched off, not picking, etc.).
    - **Supervisor Level**: Displays squad supervisees table with live call breakdown & verification badges.
    - **AHOD Level**: Aggregates division totals across all supervisor squads.
    - **HOD Level**: Full department pipeline COD volume, conversion rates, and total orders.

---

## 6. Marketing Console Hand-off Matrix (Lead Recycling)

Leads tagged with non-converting statuses are automatically categorized in the database for the **Marketing Console Lead Recycling Engine**:

```mermaid
graph LR
    RepOutcome["Sales Rep Call Tag"] --> DB[("CRM Database")]
    
    DB -->|"Not Picking / Switched Off"| SMS["📱 Evening SMS Retargeting Campaign"]
    DB -->|"Not Ready Today"| Redial3["⏰ 3-Day Hot Re-dial Queue"]
    DB -->|"Cancelled / Rejected"| Email["📧 Win-Back Email & Discount Offer"]
    DB -->|"Duplicate / Wrong Number"| Purge["🗑️ Lead Database Hygiene & Archival"]
```

---

## 7. Standard Operating Procedure (SOP) Summary Checklist

- [x] **Step 1**: Log in to NovaSuite Admin & navigate to **Sales Call Center Suite**.
- [x] **Step 2**: Filter queue by `New Lead` or `Call Back`.
- [x] **Step 3**: Tap customer card to expand order details & read product call script.
- [x] **Step 4**: Tap **Start Call** on NovaDialer bar.
- [x] **Step 5**: Tap **End Call & Log Outcome** upon call completion.
- [x] **Step 6**: Select one of the 4 Macro Category Tabs (`Confirm`, `Reschedule`, `Unreachable`, `Closed`).
- [x] **Step 7**: Select specific sub-chip status and tap **Save Outcome & Complete**.
- [x] **Step 8**: System auto-updates database, updates Supervisor Organogram, and queues marketing retargeting.
