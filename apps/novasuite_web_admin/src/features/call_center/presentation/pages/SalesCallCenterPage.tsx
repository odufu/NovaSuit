import React, { useState } from 'react';
import { MOCK_ORDER_LEADS } from '../../domain/models/OrderLead';
import type { OrderLead } from '../../domain/models/OrderLead';
import { CallQueueTable } from '../components/CallQueueTable';
import { SoftphoneModal } from '../components/SoftphoneModal';
import { HeaderStatCards } from '../components/HeaderStatCards';
import { ThemeToggle } from '@/core/theme/theme-toggle';
import { Search, Wallet } from 'lucide-react';

export const SalesCallCenterPage: React.FC = () => {
  const [orders] = useState<OrderLead[]>(MOCK_ORDER_LEADS);
  const [searchQuery, setSearchQuery] = useState('');
  const [stateFilter, setStateFilter] = useState('All');
  const [selectedOrder, setSelectedOrder] = useState<OrderLead | null>(null);

  const filteredOrders = orders.filter((o) => {
    const q = searchQuery.toLowerCase();
    const matchesSearch =
      q === '' ||
      o.orderNumber.toLowerCase().includes(q) ||
      o.customerName.toLowerCase().includes(q) ||
      o.customerPhone.toLowerCase().includes(q) ||
      o.deliveryState.toLowerCase().includes(q);

    const matchesState = stateFilter === 'All' || o.deliveryState.toLowerCase() === stateFilter.toLowerCase();
    return matchesSearch && matchesState;
  });

  return (
    <div className="min-h-screen bg-background text-foreground transition-colors duration-200">
      {/* Top Navbar */}
      <header className="sticky top-0 z-30 bg-card border-b border-border px-6 py-3.5 flex items-center justify-between shadow-2xs">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-xl bg-primary text-primary-foreground flex items-center justify-center font-bold text-sm shadow-md">
            NS
          </div>
          <div>
            <h1 className="text-base font-bold leading-tight">NovaSuite CRM Admin</h1>
            <p className="text-[11px] text-muted-foreground font-medium">Telecom & Call Center Operations</p>
          </div>
        </div>

        <div className="flex items-center gap-3">
          {/* Call Wallet Pill */}
          <div className="hidden sm:flex items-center gap-2 px-3 py-1.5 rounded-xl bg-accent border border-emerald-300 dark:border-emerald-800 text-xs font-mono font-bold text-accent-foreground">
            <Wallet className="w-3.5 h-3.5" />
            <span>₦85,400 Call Balance</span>
          </div>

          <ThemeToggle />
        </div>
      </header>

      {/* Main Content Container */}
      <main className="max-w-7xl mx-auto p-6 space-y-6">
        {/* Header Bar with Title & Stat Cards */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2.5">
              <h2 className="text-2xl font-bold tracking-tight">Live Call Queue</h2>
              <span className="text-lg text-muted-foreground font-medium">({filteredOrders.length} Pending)</span>
            </div>
            <p className="text-xs text-muted-foreground mt-0.5">
              Confirm orders · Verify delivery address · Pitch upsell bundles
            </p>
          </div>

          <HeaderStatCards />
        </div>

        {/* Filter & Search Bar */}
        <div className="p-3 bg-card rounded-2xl border border-border flex flex-col sm:flex-row items-center gap-3 shadow-2xs">
          <div className="relative flex-1 w-full">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search customer, phone, or order #..."
              className="w-full pl-9 pr-4 py-2 text-xs bg-muted/50 border border-border rounded-xl focus:outline-hidden focus:ring-2 focus:ring-ring text-foreground placeholder:text-muted-foreground"
            />
          </div>

          <div className="flex items-center gap-2.5 w-full sm:w-auto">
            <select
              value={stateFilter}
              onChange={(e) => setStateFilter(e.target.value)}
              aria-label="Filter by state"
              className="px-3 py-2 text-xs font-medium bg-muted/50 border border-border rounded-xl focus:outline-hidden focus:ring-2 focus:ring-ring text-foreground cursor-pointer"
            >
              <option value="All">All States</option>
              <option value="Lagos">Lagos</option>
              <option value="Abuja">Abuja</option>
              <option value="Rivers">Rivers</option>
              <option value="Kano">Kano</option>
            </select>

            <select
              aria-label="Rows per page"
              className="px-3 py-2 text-xs font-medium bg-muted/50 border border-border rounded-xl focus:outline-hidden focus:ring-2 focus:ring-ring text-foreground cursor-pointer"
            >
              <option value="10">10 / page</option>
              <option value="25">25 / page</option>
              <option value="50">50 / page</option>
            </select>
          </div>
        </div>

        {/* Live Call Queue Table */}
        <CallQueueTable
          orders={filteredOrders}
          onStartCall={(order) => setSelectedOrder(order)}
          onViewDoc={(order) => alert(`Viewing document details for #${order.orderNumber}`)}
        />
      </main>

      {/* SIP WebRTC Softphone Modal */}
      <SoftphoneModal
        order={selectedOrder}
        isOpen={!!selectedOrder}
        onClose={() => setSelectedOrder(null)}
      />
    </div>
  );
};
