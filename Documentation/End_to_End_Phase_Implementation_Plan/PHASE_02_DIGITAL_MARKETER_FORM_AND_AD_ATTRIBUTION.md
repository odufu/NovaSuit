# Phase 2 Specification: Digital Marketer Suite & Fail-Safe Lead Protection

**Focus Area**: Digital Marketer Workspace, Drag-and-Drop Landing Page Form Generator, UTM Ad Campaign Attribution, and CPO Analytics.

---

## 🎯 Digital Marketer Lead Protection Lifecycle

```mermaid
sequenceDiagram
    autonumber
    actor Marketer as Digital Marketer
    participant Suite as Digital Marketing Suite
    participant FormBuilder as Form Generator Engine
    actor Buyer as Ad Clicker (TikTok / FB Ad)
    participant FormSDK as FormGuard SDK (form-guard.js)
    participant EdgeFunc as Supabase Edge Function (submit-order)

    Marketer->>FormBuilder: Builds Custom Order Form (Product: Slim Tea Detox)
    FormBuilder-->>Marketer: Generates JS Embed Code (<iframe src=".../form-guard.js">)
    Marketer->>Marketer: Pastes JS Code into WordPress / Elementor Landing Page
    
    Buyer->>FormSDK: Clicks TikTok Ad & Submits Order Form
    FormSDK->>FormSDK: Validates Phone Number & Enqueues in LocalStorage
    FormSDK->>EdgeFunc: POST /api/v1/public/submit-order (Payload + UTM Params)
    EdgeFunc-->>Suite: Updates Real-Time Campaign ROI & Cost-Per-Order (CPO)
```

---

## 💻 Digital Marketer UI Features

1. **Campaign Performance & CPO Metrics**:
   - Visual cards for Total Ad Spend, Leads Generated, Orders Closed, Cost-per-Acquisition (CPA), and Net Return on Ad Spend (ROAS).
2. **Fail-Safe Form Builder**:
   - Customizable form fields (Name, Phone, Delivery State, Address, Product Quantity).
   - Generates embeddable single-line `<script src="form-guard.js"></script>` code.
3. **UTM Attribution Table**:
   - Displays incoming lead breakdown grouped by `utm_source` (TikTok, Facebook, Google Ads), `utm_campaign`, and `ad_id`.
