import { useState } from "react";
import {
  Phone,
  FileText,
  MoreHorizontal,
  ChevronDown,
  MapPin,
  Package,
  RotateCcw,
  CheckCircle,
  PhoneMissed,
  Clock,
} from "lucide-react";
import type { Order } from "./DialerModal";

const STATUS_CONFIG = {
  new_lead: {
    label: "New Lead",
    bg: "bg-emerald-50",
    text: "text-emerald-700",
    border: "border-emerald-200",
    icon: <CheckCircle size={11} />,
  },
  call_back: {
    label: "Call Back",
    bg: "bg-amber-50",
    text: "text-amber-700",
    border: "border-amber-200",
    icon: <RotateCcw size={11} />,
  },
  confirmed: {
    label: "Confirmed",
    bg: "bg-blue-50",
    text: "text-blue-700",
    border: "border-blue-200",
    icon: <CheckCircle size={11} />,
  },
  no_answer: {
    label: "No Answer",
    bg: "bg-red-50",
    text: "text-red-600",
    border: "border-red-200",
    icon: <PhoneMissed size={11} />,
  },
};

export const QUEUE_ORDERS: Order[] = [
  {
    id: "#ORD-2026-8901",
    customer: "Chief Bartholomew Okonkwo",
    initials: "BO",
    phone: "+234 803 123 4567",
    product: "Grazer Herbal Tea",
    location: "Lagos · 14 Isaac John Street",
    cod: 50000,
    status: "new_lead",
  },
  {
    id: "#ORD-2026-8902",
    customer: "Dr. Folake Adeleke",
    initials: "FA",
    phone: "+234 802 987 6543",
    product: "Vitality Booster",
    location: "Abuja · Abu Dhabi Plot 402",
    cod: 28000,
    status: "call_back",
  },
  {
    id: "#ORD-2026-8903",
    customer: "Alhaji Ibrahim Danladi",
    initials: "ID",
    phone: "+234 805 444 3322",
    product: "Grazer Herbal Tea",
    location: "Kano · 7 Lamidu Road",
    cod: 22000,
    status: "new_lead",
  },
  {
    id: "#ORD-2026-8904",
    customer: "Engineer Chidi Nnamdi",
    initials: "CN",
    phone: "+234 806 777 8899",
    product: "Vitality Booster",
    location: "Rivers · 98 Aba Road, Garrison",
    cod: 25000,
    status: "new_lead",
  },
];

const STATES = ["All States", "Lagos", "Abuja", "Kano", "Rivers", "Enugu", "Ogun"];

interface CallQueueTableProps {
  onStartCall: (order: Order) => void;
}

export function CallQueueTable({ onStartCall }: CallQueueTableProps) {
  const [search, setSearch] = useState("");
  const [stateFilter, setStateFilter] = useState("All States");
  const [openMenu, setOpenMenu] = useState<string | null>(null);

  const filtered = QUEUE_ORDERS.filter((o) => {
    const matchSearch =
      !search ||
      o.customer.toLowerCase().includes(search.toLowerCase()) ||
      o.id.toLowerCase().includes(search.toLowerCase()) ||
      o.phone.includes(search);
    const matchState =
      stateFilter === "All States" || o.location.toLowerCase().startsWith(stateFilter.toLowerCase());
    return matchSearch && matchState;
  });

  return (
    <div className="flex flex-col gap-4">
      {/* Filters row */}
      <div className="flex items-center gap-3 flex-wrap">
        {/* Search */}
        <div className="relative flex-1 min-w-48">
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
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search customer, phone, or order #..."
            className="w-full pl-9 pr-4 py-2.5 bg-white border border-[var(--border)] rounded-xl text-sm text-[var(--foreground)] placeholder:text-[var(--muted-foreground)] focus:outline-none focus:ring-2 focus:ring-[var(--ring)]/30 focus:border-[var(--ring)] transition-all"
          />
        </div>

        {/* State filter */}
        <div className="relative">
          <select
            value={stateFilter}
            onChange={(e) => setStateFilter(e.target.value)}
            className="appearance-none pl-3 pr-8 py-2.5 bg-white border border-[var(--border)] rounded-xl text-sm text-[var(--foreground)] focus:outline-none focus:ring-2 focus:ring-[var(--ring)]/30 cursor-pointer"
          >
            {STATES.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
          <ChevronDown size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[var(--muted-foreground)] pointer-events-none" />
        </div>

        {/* Rows per page */}
        <div className="relative">
          <select className="appearance-none pl-3 pr-8 py-2.5 bg-white border border-[var(--border)] rounded-xl text-sm text-[var(--foreground)] focus:outline-none focus:ring-2 focus:ring-[var(--ring)]/30 cursor-pointer">
            <option>10 / page</option>
            <option>25 / page</option>
            <option>50 / page</option>
          </select>
          <ChevronDown size={14} className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[var(--muted-foreground)] pointer-events-none" />
        </div>
      </div>

      {/* Desktop table */}
      <div className="hidden md:block bg-white rounded-2xl border border-[var(--border)] overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-[var(--border)]">
              {["ORDER", "CUSTOMER", "PRODUCT & LOCATION", "COD", "STATUS", "ACTIONS"].map((col) => (
                <th
                  key={col}
                  className="px-5 py-3.5 text-left text-xs text-[var(--muted-foreground)] tracking-wider"
                  style={{ fontFamily: "var(--font-mono)" }}
                >
                  {col}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((order, i) => {
              const status = STATUS_CONFIG[order.status];
              return (
                <tr
                  key={order.id}
                  className={[
                    "group transition-colors",
                    i < filtered.length - 1 ? "border-b border-[var(--border)]" : "",
                    "hover:bg-[var(--muted)]/40",
                  ].join(" ")}
                >
                  {/* Order */}
                  <td className="px-5 py-4">
                    <span
                      className="text-xs text-[var(--primary)] bg-[var(--secondary)] px-2 py-1 rounded-md"
                      style={{ fontFamily: "var(--font-mono)" }}
                    >
                      {order.id}
                    </span>
                  </td>

                  {/* Customer */}
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-[var(--secondary)] flex items-center justify-center text-[var(--primary)] text-xs shrink-0">
                        {order.initials}
                      </div>
                      <div>
                        <p className="text-sm text-[var(--foreground)] whitespace-nowrap">{order.customer}</p>
                        <p
                          className="text-xs text-[var(--muted-foreground)] mt-0.5"
                          style={{ fontFamily: "var(--font-mono)" }}
                        >
                          {order.phone}
                        </p>
                      </div>
                    </div>
                  </td>

                  {/* Product & Location */}
                  <td className="px-5 py-4">
                    <div className="flex flex-col gap-1">
                      <div className="flex items-center gap-1.5 text-xs text-[var(--foreground)]">
                        <Package size={12} className="text-[var(--muted-foreground)]" />
                        {order.product}
                      </div>
                      <div className="flex items-center gap-1.5 text-xs text-[var(--muted-foreground)]">
                        <MapPin size={11} />
                        {order.location}
                      </div>
                    </div>
                  </td>

                  {/* COD */}
                  <td className="px-5 py-4">
                    <span
                      className="text-sm text-[var(--primary)]"
                      style={{ fontFamily: "var(--font-mono)" }}
                    >
                      ₦{order.cod.toLocaleString()}
                    </span>
                  </td>

                  {/* Status */}
                  <td className="px-5 py-4">
                    <span
                      className={`inline-flex items-center gap-1 text-xs px-2.5 py-1 rounded-full border ${status.bg} ${status.text} ${status.border}`}
                    >
                      {status.icon}
                      {status.label}
                    </span>
                  </td>

                  {/* Actions */}
                  <td className="px-5 py-4">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => onStartCall(order)}
                        className="flex items-center gap-2 bg-[var(--primary)] hover:bg-[#1A5C42] text-white text-xs px-3.5 py-2 rounded-lg transition-all active:scale-95 whitespace-nowrap"
                      >
                        <Phone size={13} />
                        Start Call
                      </button>
                      <button className="w-8 h-8 flex items-center justify-center rounded-lg border border-[var(--border)] text-[var(--muted-foreground)] hover:text-[var(--foreground)] hover:bg-[var(--muted)] transition-all">
                        <FileText size={14} />
                      </button>
                      <div className="relative">
                        <button
                          onClick={() => setOpenMenu(openMenu === order.id ? null : order.id)}
                          className="w-8 h-8 flex items-center justify-center rounded-lg border border-[var(--border)] text-[var(--muted-foreground)] hover:text-[var(--foreground)] hover:bg-[var(--muted)] transition-all"
                        >
                          <MoreHorizontal size={14} />
                        </button>
                        {openMenu === order.id && (
                          <>
                            <div className="fixed inset-0 z-10" onClick={() => setOpenMenu(null)} />
                            <div className="absolute right-0 top-full mt-1 w-44 bg-white rounded-xl border border-[var(--border)] shadow-lg z-20 overflow-hidden">
                              {["View Order Details", "Reschedule Call", "Mark No Answer", "Skip Order"].map((action) => (
                                <button
                                  key={action}
                                  className="w-full text-left px-4 py-2.5 text-xs text-[var(--foreground)] hover:bg-[var(--muted)] transition-colors"
                                  onClick={() => setOpenMenu(null)}
                                >
                                  {action}
                                </button>
                              ))}
                            </div>
                          </>
                        )}
                      </div>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {filtered.length === 0 && (
          <div className="py-12 text-center text-[var(--muted-foreground)] text-sm">
            No orders match your search.
          </div>
        )}
      </div>

      {/* Mobile cards */}
      <div className="md:hidden space-y-3">
        {filtered.map((order) => {
          const status = STATUS_CONFIG[order.status];
          return (
            <div key={order.id} className="bg-white rounded-2xl border border-[var(--border)] p-4">
              <div className="flex items-start justify-between mb-3">
                <div>
                  <span
                    className="text-xs text-[var(--primary)] bg-[var(--secondary)] px-2 py-0.5 rounded-md"
                    style={{ fontFamily: "var(--font-mono)" }}
                  >
                    {order.id}
                  </span>
                  <p className="text-sm mt-1.5">{order.customer}</p>
                  <p
                    className="text-xs text-[var(--muted-foreground)] mt-0.5"
                    style={{ fontFamily: "var(--font-mono)" }}
                  >
                    {order.phone}
                  </p>
                </div>
                <span
                  className={`inline-flex items-center gap-1 text-xs px-2 py-1 rounded-full border ${status.bg} ${status.text} ${status.border}`}
                >
                  {status.icon}
                  {status.label}
                </span>
              </div>

              <div className="flex items-center gap-1.5 text-xs text-[var(--muted-foreground)] mb-1">
                <Package size={11} />
                {order.product}
              </div>
              <div className="flex items-center gap-1.5 text-xs text-[var(--muted-foreground)] mb-3">
                <MapPin size={11} />
                {order.location}
              </div>

              <div className="flex items-center justify-between">
                <span
                  className="text-sm text-[var(--primary)]"
                  style={{ fontFamily: "var(--font-mono)" }}
                >
                  ₦{order.cod.toLocaleString()}
                </span>
                <div className="flex gap-2">
                  <button
                    onClick={() => onStartCall(order)}
                    className="flex items-center gap-1.5 bg-[var(--primary)] text-white text-xs px-3 py-2 rounded-lg transition-all active:scale-95"
                  >
                    <Phone size={13} />
                    Call
                  </button>
                  <button className="w-8 h-8 flex items-center justify-center rounded-lg border border-[var(--border)] text-[var(--muted-foreground)]">
                    <FileText size={14} />
                  </button>
                  <button className="w-8 h-8 flex items-center justify-center rounded-lg border border-[var(--border)] text-[var(--muted-foreground)]">
                    <MoreHorizontal size={14} />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Footer */}
      <div className="flex items-center justify-between text-xs text-[var(--muted-foreground)] px-1">
        <span>Showing {filtered.length} of {QUEUE_ORDERS.length} orders</span>
        <div className="flex items-center gap-1">
          <Clock size={11} />
          <span>Last updated: just now</span>
        </div>
      </div>
    </div>
  );
}
