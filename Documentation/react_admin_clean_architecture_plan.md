# 🏛️ NovaSuite React Web Admin Restructuring & Milestones Plan
> **Architectural Pattern**: Feature-First Clean Architecture (Domain-Driven UI)  
> **Tech Stack**: React 18 + Vite + TypeScript + Tailwind CSS v4 + Radix UI / Shadcn + `next-themes` (Dark/Light Mode) + Supabase JS + `sip.js` (WebRTC Softphone)  
> **Reference Inspiration Source**: `C:\Users\Joel Odufu\Downloads\Redesign Call Queue Screen`

---

## 🎯 Executive Summary & Objectives

This document establishes the official roadmap and architectural design for migrating the **NovaSuite Web CRM Admin** from Flutter Web to a high-performance **React 18 + Tailwind CSS** application. 

### Why Feature-First Clean Architecture?
To maintain modularity, testability, and strict separation of concerns, the frontend is organized by **domain features** rather than generic technical layers (e.g. putting all components in one folder). Each feature contains its own `domain`, `data`, and `presentation` layers.

---

## 📁 1. Target Directory & Feature-First Directory Structure

```
apps/novasuite_web_admin/
├── public/
├── src/
│   ├── app/                                 # Global Router, Context Providers, Store
│   │   ├── router/                          # React Router v7 / TanStack Router definition
│   │   ├── providers/                       # ThemeProvider, AuthProvider, SupabaseProvider
│   │   └── store/                           # Global Zustand / Redux State
│   │
│   ├── core/                                # Universal Cross-Cutting Infrastructure
│   │   ├── config/                          # Supabase Credentials, IT Sky SIP Trunk settings
│   │   ├── theme/                           # Tailwind Tokens, Dark/Light HSL Variables, Typography
│   │   ├── utils/                           # Currency formatters, Phone validators, Date helpers
│   │   └── types/                           # Universal Base Interfaces & Enums
│   │
│   ├── components/                          # Shared Design System Primitives (Shadcn UI + Radix)
│   │   ├── ui/                              # Button, Card, Dialog, Table, Input, Select, Badge, Switch
│   │   └── feedback/                        # Toast Notifications (Sonner), Loading Skeletons
│   │
│   └── features/                            # 🚀 Feature-First Domain Modules
│       │
│       ├── call_center/                     # Live Call Queue & SIP Softphone Module
│       │   ├── domain/                      # Business Entities & Contracts
│       │   │   ├── models/                  # OrderLead.ts, CallLog.ts, TelecomWallet.ts
│       │   │   └── repositories/            # ICallCenterRepository.ts
│       │   ├── data/                        # Supabase Data Sources & IT Sky SIP WebRTC Client
│       │   │   ├── datasources/             # SupabaseCallCenterApi.ts, SipWebRtcClient.ts
│       │   │   └── repositories/            # CallCenterRepositoryImpl.ts
│       │   └── presentation/                # React Components, Hooks & Views
│       │       ├── components/              # CallQueueTable.tsx, SoftphoneModal.tsx, WalletBadge.tsx
│       │       ├── hooks/                   # useSipDialer.ts, useCallQueue.ts, useStickyRouting.ts
│       │       └── pages/                   # SalesCallCenterPage.tsx
│       │
│       ├── orders/                          # Order Processing & Up-Sell Approval Module
│       ├── logistics/                       # Multi-Warehouse & Waybill Management
│       ├── finance/                         # COD Reconciliation & Credit Limits
│       └── settings/                        # Whitelabel Branding & Tenant Admin
│
├── index.html
├── package.json
├── tailwind.config.ts
└── vite.config.ts
```

---

## 🌗 2. Dark & Light Theme System (`next-themes` + Tailwind CSS)

Dark/Light mode is a first-class feature built using CSS variables, Tailwind tokens, and `next-themes`.

### A. Theme Variables Specification (`src/core/theme/theme.css`)
```css
@import "tailwindcss";

@layer base {
  :root {
    --font-sans: 'Inter', system-ui, sans-serif;
    --font-mono: 'JetBrains Mono', monospace;

    /* Light Theme Palette */
    --background: 210 40% 98%;          /* #F8FAFC */
    --card: 0 0% 100%;                  /* #FFFFFF */
    --card-foreground: 222.2 84% 4.9%;
    --primary: 161 64% 11%;             /* Deep Forest Green #0A2E23 */
    --primary-foreground: 210 40% 98%;
    --accent: 152 76% 80%;              /* Light Sage #E8F5E9 */
    --accent-foreground: 152 76% 25%;
    --border: 214.3 31.8% 91.4%;
  }

  .dark {
    /* Dark Theme Palette */
    --background: 224 71% 4%;           /* OLED OLED Dark Slate #020617 */
    --card: 222 47% 7%;                 /* #0F172A */
    --card-foreground: 210 40% 98%;
    --primary: 158 64% 52%;             /* Emerald Accent #10B981 */
    --primary-foreground: 224 71% 4%;
    --accent: 161 64% 15%;              /* Dark OLED Green #091A14 */
    --accent-foreground: 152 76% 80%;
    --border: 217.2 32.6% 17.5%;
  }
}
```

### B. React Theme Toggle Hook
```tsx
import { useTheme } from "next-themes";
import { Moon, Sun } from "lucide-react";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  return (
    <button
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
      className="p-2 rounded-lg bg-card border border-border hover:bg-accent transition-all"
    >
      {theme === "dark" ? <Sun className="w-4 h-4 text-amber-400" /> : <Moon className="w-4 h-4 text-slate-700" />}
    </button>
  );
}
```

---

## 🚩 3. Restructuring Milestones Roadmap

| Milestone | Stage & Target Deliverables | Estimated Completion |
| :--- | :--- | :--- |
| **Milestone 1** | **Project Scaffold & Clean Architecture Setup**: <br>• Initialize Vite + React + TypeScript + Tailwind v4 in `apps/novasuite_web_admin`. <br>• Setup directory folders (`app`, `core`, `components`, `features`). <br>• Implement `ThemeProvider` with Dark/Light mode toggle. | **Day 1** |
| **Milestone 2** | **Supabase Data Layer & Core Shared UI Components**: <br>• Port Supabase JS Client & TypeScript DB Interfaces (`orders`, `company_call_wallets`, `call_logs`). <br>• Build Radix/Shadcn primitives (`Button`, `Table`, `Badge`, `Dialog`, `Input`, `Select`). | **Day 2** |
| **Milestone 3** | **Live Call Queue & Table Redesign**: <br>• Build `CallQueueTable.tsx` with full-width dynamic layout, column sorting, search/state filters, and smooth hover effects. <br>• Incorporate pixel-perfect design elements from `Redesign Call Queue Screen`. | **Day 3** |
| **Milestone 4** | **IT Sky SIP WebRTC Softphone & Dialer Modal**: <br>• Integrate `sip.js` to connect to IT Sky Trunk (`196.13.112.196:5060`). <br>• Build 2-phase `SoftphoneModal.tsx` (Live In-Call OLED screen + Post-Call Outcome pills). <br>• Floating touch keypad bar with live wallet balance (`₦85.4k`). | **Day 4** |
| **Milestone 5** | **Inbound Callback Sticky Routing & Fallback**: <br>• Implement `_useStickyRouting` hook connecting assigned rep extensions to `call_logs`. <br>• Implement central line ring group fallback simulator. | **Day 5** |
| **Milestone 6** | **Full Admin Dashboard Features Migration**: <br>• Port Logistics / Waybill Module, Up-sell Request Dialogs, COD Reconciliation, and Whitelabel Brand Settings. | **Day 6-7** |

---

## 🎨 4. Design Inspiration Elements Adopted

From reference inspiration project `C:\Users\Joel Odufu\Downloads\Redesign Call Queue Screen`:
1. **Radix UI Dialog & Popover Primitives** for seamless modals without z-index flickering.
2. **Sonner Toast Notifications** for real-time order confirmation alerts & incoming call banners.
3. **Framer Motion Micro-Animations** for smooth tab switches, status badge pulses, and softphone slide-ups.
4. **Tailwind CSS Utility Classes** matching exact HSL color spaces for emerald green status pills, gold call-back pills, and dark OLED forest green keypads.

---

## 🛠️ 5. Next Execution Steps

To launch **Milestone 1** immediately:
```powershell
cd c:\PROJECT\novasuite\apps
npx -y create-vite@latest novasuite_web_admin --template react-ts
cd novasuite_web_admin
npm install -D tailwindcss @tailwindcss/vite
npm install @supabase/supabase-js sip.js next-themes lucide-react clsx tailwind-merge framer-motion sonner
```
