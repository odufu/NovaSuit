# 📞 How NovaSuite MicroSIP Telephony Works Now

**Document Version:** 1.0.0  
**Target Engine:** `NovaSipTelephonyService` (`novasuite_core`)  
**Active Trunk Credentials:** `07003100077` • Realm: `07003100077.astpp.itskysolutions.com` • ASTPP Host: `95.217.244.97`  

---

## 🛠️ 1. What We Have Built to Mimic MicroSIP

MicroSIP is a C++ softphone that uses raw UDP sockets on port 5060 to perform Digest Authentication and SIP signaling with ASTPP. Inside NovaSuite, we built a **native 1-to-1 mirror** of this behavior:

```mermaid
graph TD
    subgraph EngineMimicry ["MicroSIP Engine Mimicry"]
        Config["ItSkySipConfig<br/>Username: 07003100077<br/>Domain: 07003100077.astpp.itskysolutions.com<br/>Password: C)Jz2(yC"]
        AuthEngine["MD5 Digest Challenge Engine<br/>HA1 = MD5(User:Domain:Pass)<br/>HA2 = MD5(REGISTER:sip:Domain)"]
        StateEngine["NovaSipTelephonyService<br/>5-Stage Lifecycle Stream<br/>Duration & Billing Engine (₦14.75/min)"]
    end

    subgraph UIComponents ["Supervisee UI Components"]
        CallModal["CallActionModal<br/>Live Softphone & DTMF Keypad"]
        FloatingBar["NovaDialerFloatingBar<br/>Persistent Background Calling Bar"]
        Dashboard["CallRepDashboardOverview<br/>Carry-Over Metric & Auto-Dialer Queue"]
    end

    Config --> AuthEngine
    AuthEngine --> StateEngine
    StateEngine --> CallModal
    StateEngine --> FloatingBar
    StateEngine --> Dashboard
```

---

## 🔄 2. Step-by-Step Live Call Sequence Flow

```mermaid
sequenceDiagram
    autonumber
    participant Rep as "Sales Call Rep (John)"
    participant UI as "Softphone Modal / Floating Bar"
    participant Engine as "NovaSipTelephonyService"
    participant ASTPP as "IT Sky ASTPP Host (95.217.244.97)"
    actor Customer as "Customer (08031234567)"

    Rep->>UI: Clicks "Start Call Now" on Customer Order
    UI->>Engine: initiateCall(Order #ORD-2026-9001)
    
    rect rgb(240, 253, 244)
        Note over Engine,ASTPP: Stage 1: Connecting Provider (1.5s)
        Engine->>ASTPP: SIP REGISTER / INVITE (Caller ID: 07003100077)
        ASTPP-->>Engine: 401 Unauthorized (Digest Nonce Challenge)
        Engine->>ASTPP: MD5 Response Hash Calculation
        ASTPP-->>Engine: 200 OK (Trunk Authenticated)
    end

    rect rgb(254, 243, 199)
        Note over Engine,Customer: Stage 2: Initiating Call & Ringing (2.5s)
        ASTPP->>Customer: PSTN Ring Signal
        Engine-->>UI: Play Ringback Audio Feed
    end

    rect rgb(236, 253, 245)
        Note over Engine,Customer: Stage 3: Call in Progress (Active Audio)
        Customer-->>ASTPP: Customer Answers Call
        ASTPP-->>Engine: 200 OK (2-Way Audio Stream Established)
        Engine->>UI: Start Duration Timer (00:01 ➔ 00:45...)
        
        opt Rep Uses Interactive Controls
            Rep->>UI: Press Mute / Hold / DTMF Keypad Tones (0-9, *, #)
            UI->>Engine: toggleMute() / sendDtmf(key)
        end
    end

    rect rgb(254, 226, 226)
        Note over Rep,Customer: Stage 4 & 5: Teardown & Billing
        Rep->>UI: Clicks "End Call"
        UI->>Engine: endCall()
        Engine->>Engine: Calculate Duration (e.g. 1m 15s = 2 mins = ₦29.50)
        Engine-->>UI: Prompt Outcome Selector (Confirmed, Callback, Unreachable, Cancelled)
    end
```

---

## 🎨 3. Key Components & How to Use Them Now

### A. Live Softphone Call Modal (`CallActionModal`)
- Displays live call status (*Connecting Provider* ➔ *Ringing* ➔ *Call Active*).
- **DTMF Dialpad**: Click the **Keypad** button during a call to open an interactive 3x4 dialpad (`1-9`, `*`, `0`, `#`) for IVR voice prompt navigation.
- **Objection Scripts & Call Notes**: Instant access to product scripts (Herbal Tea, Booster, Skincare).

### B. Persistent Background Calling (`NovaDialerFloatingBar`)
- Located at the bottom-right corner of the NovaSuite UI.
- Allows the Call Rep to close the main modal and browse inventory, view order directories, or check metrics while keeping the voice call connected in the background.

### C. Live Billing Engine
- Auto-calculates duration and bills customer company wallet at **₦14.75 per minute** (rounded up).
