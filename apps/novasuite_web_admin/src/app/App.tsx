import { useState } from "react";
import { Sidebar } from "./components/Sidebar";
import { CallQueueTable, QUEUE_ORDERS } from "./components/CallQueueTable";
import { DialerModal } from "./components/DialerModal";
import type { Order } from "./components/DialerModal";
import {
  Menu,
  Bell,
  Phone,
  AlarmClock,
  PhoneCall,
  TrendingUp,
  Zap,
  X,
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

const totalCOD = QUEUE_ORDERS.reduce((sum, o) => sum + o.cod, 0);

export default function App() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [activeCall, setActiveCall] = useState<Order | null>(null);
  const [reminderDismissed, setReminderDismissed] = useState(false);

  const callbackOrder = QUEUE_ORDERS.find((o) => o.status === "call_back");

  return (
    <div className="flex h-screen bg-[var(--background)] overflow-hidden" style={{ fontFamily: "var(--font-sans)" }}>
      {/* Sidebar */}
      <Sidebar open={sidebarOpen} onClose={() => setSidebarOpen(false)} />

      {/* Main */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Top bar */}
        <header className="flex items-center gap-3 px-5 py-3.5 bg-white border-b border-[var(--border)] shrink-0 z-20">
          <button
            onClick={() => setSidebarOpen(true)}
            className="lg:hidden w-9 h-9 flex items-center justify-center rounded-lg hover:bg-[var(--muted)] text-[var(--muted-foreground)] transition-colors"
          >
            <Menu size={20} />
          </button>

          {/* Brand (mobile) */}
          <div className="lg:hidden flex items-center gap-2">
            <div className="w-7 h-7 rounded-lg bg-[var(--primary)] flex items-center justify-center">
              <PhoneCall size={13} className="text-white" />
            </div>
            <span className="text-sm text-[var(--foreground)]">Nova Care Suite</span>
          </div>

          {/* Search */}
          <div className="hidden sm:flex flex-1 max-w-md relative">
            <svg
              className="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--muted-foreground)]"
              width="15"
              height="15"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
            >
              <circle cx="11" cy="11" r="8" />
              <path d="m21 21-4.35-4.35" />
            </svg>
            <input
              placeholder="Search orders, leads, reps..."
              className="w-full pl-9 pr-4 py-2 bg-[var(--muted)] border border-transparent rounded-xl text-sm placeholder:text-[var(--muted-foreground)] focus:outline-none focus:ring-2 focus:ring-[var(--ring)]/30 focus:bg-white transition-all"
            />
          </div>

          <div className="ml-auto flex items-center gap-2">
            {/* Stats strip */}
            <div className="hidden lg:flex items-center gap-4 mr-2">
              <div className="flex items-center gap-1.5 text-xs text-[var(--muted-foreground)]">
                <TrendingUp size={13} className="text-[var(--accent)]" />
                <span style={{ fontFamily: "var(--font-mono)" }}>₦{(totalCOD / 1000).toFixed(1)}k pipeline</span>
              </div>
              <div className="flex items-center gap-1.5 text-xs text-[var(--muted-foreground)]">
                <Zap size={13} className="text-amber-500" />
                <span>4 pending</span>
              </div>
            </div>

            {/* Notification */}
            <button className="relative w-9 h-9 flex items-center justify-center rounded-lg hover:bg-[var(--muted)] text-[var(--muted-foreground)] transition-colors">
              <Bell size={18} />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-red-500" />
            </button>
          </div>
        </header>

        {/* Scrollable content */}
        <main className="flex-1 overflow-y-auto px-4 sm:px-6 py-5 space-y-5">

          {/* Callback reminder banner */}
          <AnimatePresence>
            {!reminderDismissed && callbackOrder && (
              <motion.div
                initial={{ opacity: 0, y: -8 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -8, height: 0, marginBottom: 0 }}
                className="bg-amber-50 border border-amber-200 rounded-2xl px-4 py-3.5 flex items-center gap-4"
              >
                <div className="w-9 h-9 rounded-xl bg-amber-100 flex items-center justify-center shrink-0">
                  <AlarmClock size={18} className="text-amber-600" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-amber-800 text-sm">
                    <span className="font-medium">Callback Reminder:</span> 1 Rescheduled Call Due
                  </p>
                  <p className="text-amber-600 text-xs mt-0.5 truncate">
                    {callbackOrder.customer} · {callbackOrder.phone} · {callbackOrder.location.split("·")[0].trim()}
                  </p>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <button
                    onClick={() => setActiveCall(callbackOrder)}
                    className="flex items-center gap-1.5 bg-amber-600 hover:bg-amber-700 text-white text-xs px-3.5 py-2 rounded-lg transition-all active:scale-95 whitespace-nowrap"
                  >
                    <Phone size={13} />
                    Call Now
                  </button>
                  <button
                    onClick={() => setReminderDismissed(true)}
                    className="w-7 h-7 flex items-center justify-center rounded-lg text-amber-400 hover:text-amber-600 hover:bg-amber-100 transition-colors"
                  >
                    <X size={14} />
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Queue header */}
          <div className="flex items-start justify-between gap-4 flex-wrap">
            <div>
              <h1 className="text-[var(--foreground)]">
                Live Call Queue
                <span className="ml-2 text-base text-[var(--muted-foreground)] font-normal">(4 Pending)</span>
              </h1>
              <p className="text-[var(--muted-foreground)] text-sm mt-0.5">
                Confirm orders · Verify delivery address · Pitch upsell bundles
              </p>
            </div>

            {/* Quick stats */}
            <div className="hidden sm:flex items-center gap-3">
              <StatChip label="Total Pipeline" value={`₦${(totalCOD / 1000).toFixed(0)}k`} accent />
              <StatChip label="New Leads" value="3" />
              <StatChip label="Call Backs" value="1" warning />
            </div>
          </div>

          {/* Table */}
          <CallQueueTable onStartCall={setActiveCall} />
        </main>

        {/* Bottom NovaDialer bar */}
        <div className="bg-[var(--primary)] px-5 py-3 flex items-center justify-between shrink-0">
          <button
            className="flex items-center gap-2.5 text-white group"
            onClick={() => {}}
          >
            <div className="relative">
              <div className="w-8 h-8 rounded-full bg-white/15 flex items-center justify-center">
                <Phone size={15} className="text-white" />
              </div>
              <span className="absolute -top-1 -right-1 w-2.5 h-2.5 rounded-full bg-[var(--accent)] border-2 border-[var(--primary)]" />
            </div>
            <div>
              <p className="text-white text-xs">NovaDialer</p>
              <p className="text-white/50 text-xs" style={{ fontFamily: "var(--font-mono)" }}>
                101 · Ready
              </p>
            </div>
          </button>

          <div className="flex items-center gap-4">
            <div className="text-right">
              <p className="text-white/50 text-xs">Queue Value</p>
              <p className="text-[var(--accent)] text-sm" style={{ fontFamily: "var(--font-mono)" }}>
                ₦{(totalCOD / 1000).toFixed(1)}k
              </p>
            </div>
            <button className="hidden sm:flex items-center gap-2 bg-white/10 hover:bg-white/20 text-white text-xs px-3 py-1.5 rounded-lg transition-all">
              <PhoneCall size={13} />
              Auto-Dial
            </button>
          </div>
        </div>
      </div>

      {/* Dialer modal */}
      {activeCall && (
        <DialerModal
          order={activeCall}
          onClose={() => setActiveCall(null)}
        />
      )}
    </div>
  );
}

function StatChip({
  label,
  value,
  accent,
  warning,
}: {
  label: string;
  value: string;
  accent?: boolean;
  warning?: boolean;
}) {
  return (
    <div className="bg-white border border-[var(--border)] rounded-xl px-3.5 py-2 text-center">
      <p
        className={[
          "text-sm",
          accent ? "text-[var(--accent)]" : warning ? "text-amber-600" : "text-[var(--foreground)]",
        ].join(" ")}
        style={{ fontFamily: "var(--font-mono)" }}
      >
        {value}
      </p>
      <p className="text-xs text-[var(--muted-foreground)] mt-0.5 whitespace-nowrap">{label}</p>
    </div>
  );
}
