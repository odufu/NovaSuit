# Android Telephony Readiness & Architecture Specification

**Document Title**: Android Mobile App SIP & WebRTC Telephony Readiness Report  
**Prepared By**: NovaSuite Engineering Team  
**Target Platform**: Android OS (ARM64 / ARMv7 / x86_64)  
**Connected Test Device**: Samsung Galaxy (Device ID: `32009eb14e09160d` / `SM A750F`)  

---

## 📱 1. Android Telephony Architecture

Unlike web browsers (Chrome/Edge) which are strictly sandboxed to WebSockets (`wss://`), **Android Native OS provides direct access to raw OS UDP sockets (Port 5060)** and native OpenSL ES / AAudio microphone recording!

```mermaid
graph TD
    subgraph Android Native App (NovaSuite Mobile)
        App["📱 Android App UI (NovaSuite Admin)"]
        Permissions["🔒 Manifest Permissions<br/>• RECORD_AUDIO<br/>• MODIFY_AUDIO_SETTINGS<br/>• INTERNET<br/>• ACCESS_NETWORK_STATE<br/>• usesCleartextTraffic=true"]
        
        Facade["📞 NovaSipTelephonyService"]
        
        UDPEngine["⚡ NovaUdpSipEngine<br/>• Direct OS Raw UDP Socket (Port 5060)<br/>• IT Sky Direct IP: 95.217.244.97:5060<br/>• 100% Parity with MicroSIP"]
        
        WSSFallback["🌐 NovaWebRtcSipEngine<br/>• Fallback WSS Transport (Port 7443)<br/>• sip_ua + WebRTC Audio Stream"]
        
        App --> Permissions
        Permissions --> Facade
        Facade -->|Primary Native Route| UDPEngine
        Facade -->|Fallback WSS Route| WSSFallback
        
        UDPEngine -->|Raw UDP 5060| TrunkUDP["🇳🇬 IT Sky SIP Server (95.217.244.97:5060)"]
        WSSFallback -->|WSS Port 7443| TrunkWSS["⚡ IT Sky WSS Gateway (astpp.itskysolutions.com:7443)"]
    end
```

---

## 🛠️ 2. Android Manifest Audit & Permissions Configured

| Android Permission | Granted Status | Technical Purpose |
| :--- | :--- | :--- |
| `android.permission.INTERNET` | ✅ Configured | Required for SIP signaling & WebSockets traffic |
| `android.permission.RECORD_AUDIO` | ✅ Configured | Required for live 2-way microphone voice audio capture |
| `android.permission.MODIFY_AUDIO_SETTINGS` | ✅ Configured | Switches Android audio mode to `MODE_IN_COMMUNICATION` (Earpiece / Speaker / Bluetooth Headset) |
| `android.permission.ACCESS_NETWORK_STATE` | ✅ Configured | Detects Wi-Fi to Mobile Data switching without dropping calls |
| `android.permission.ACCESS_WIFI_STATE` | ✅ Configured | Enables High-Performance Wi-Fi Lock during active calls |
| `android:usesCleartextTraffic="true"` | ✅ Configured | Allows direct UDP/SIP transport fallback to `95.217.244.97:5060` |

---

## 🧪 3. Summary of Android Readiness

1. **Direct UDP 5060 Parity**: On Android devices, NovaSuite can connect directly to IT Sky's main trunk (`95.217.244.97:5060` / `07003100077.astpp.itskysolutions.com:5060`) over standard OS UDP, exactly like MicroSIP!
2. **Audio Hardware Access**: Native microphone permission prompts (`RECORD_AUDIO`) are configured for seamless hardware access.
3. **Multi-Transport Fallback**: If Wi-Fi firewalls block UDP 5060, Android seamlessly falls back to WSS `wss://astpp.itskysolutions.com:7443`.
