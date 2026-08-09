# Phase 6 Specification: Independent Delivery Agent (IDP) Rider App & COD Financial Settlement

**Focus Area**: White-Labeled IDP Mobile App, GPS Navigation, Camera Barcode Scanner, Offline Proof of Delivery (POD), Daily COD Cash Collection, and Merchant Remittance Payout Ledgers.

---

## 📲 IDP Last-Mile Delivery & COD Settlement Flow

```mermaid
sequenceDiagram
    autonumber
    actor Rider as Independent Delivery Agent (IDP)
    participant RiderApp as White-Labeled Rider App (Nova Express Branded)
    actor Buyer as End Customer
    participant CODLedger as Financial COD Settlement Engine
    actor Merchant as NovaSuite Merchant

    Rider->>RiderApp: Opens App & Scans Package Barcode at CDC Hub
    RiderApp->>RiderApp: Navigates to Customer Address via Integrated GPS Map
    
    Rider->>Buyer: Delivers Package & Collects ₦35,000 Cash (or Transfer)
    Rider->>RiderApp: Snaps Proof of Delivery (POD) Photo & Customer Signature
    RiderApp->>CODLedger: Transmits Delivery Confirmation & ₦35,000 COD Holding
    
    Rider->>CODLedger: Deposits Cash at CDC Hub at End of Shift
    CODLedger->>Merchant: Remits Net Payout (₦35,000 - Delivery Fee = Net Remittance)
```

---

## 💻 IDP Rider App & Finance Features

1. **White-Labeled Rider Mobile UI**:
   - Dynamically loads tenant logo, splash screen, and primary/secondary colors.
2. **Barcode Scanner & POD Photo Capture**:
   - Camera scanner for package pickup and Proof-of-Delivery photo upload.
3. **Daily COD Cash Holding Tracker**:
   - Tracks cash collected per rider during active shift.
4. **Merchant Remittance Bank Ledger**:
   - Automated payout reconciliation ledger for merchant bank transfers.
