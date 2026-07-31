import React from 'react';
import type { OrderLead } from '../../domain/models/OrderLead';
import { Phone, FileText, MoreHorizontal, CheckCircle2, RotateCw, Package, MapPin } from 'lucide-react';

interface CallQueueTableProps {
  orders: OrderLead[];
  onStartCall: (order: OrderLead) => void;
  onViewDoc: (order: OrderLead) => void;
}

export const CallQueueTable: React.FC<CallQueueTableProps> = ({ orders, onStartCall, onViewDoc }) => {
  return (
    <div className="w-full bg-card rounded-2xl border border-border overflow-hidden shadow-2xs transition-colors duration-200">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse min-w-[800px]">
          <thead>
            <tr className="border-b border-border bg-muted/40">
              <th className="py-3 px-4 text-[11px] font-bold tracking-wider text-muted-foreground uppercase">ORDER</th>
              <th className="py-3 px-4 text-[11px] font-bold tracking-wider text-muted-foreground uppercase">CUSTOMER</th>
              <th className="py-3 px-4 text-[11px] font-bold tracking-wider text-muted-foreground uppercase">PRODUCT & LOCATION</th>
              <th className="py-3 px-4 text-[11px] font-bold tracking-wider text-muted-foreground uppercase">COD</th>
              <th className="py-3 px-4 text-[11px] font-bold tracking-wider text-muted-foreground uppercase">STATUS</th>
              <th className="py-3 px-4 text-[11px] font-bold tracking-wider text-muted-foreground uppercase">ACTIONS</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-border">
            {orders.map((o) => {
              const nameParts = o.customerName.trim().split(' ');
              const initials = nameParts.length >= 2
                ? `${nameParts[0][0]}${nameParts[1][0]}`.toUpperCase()
                : o.customerName.substring(0, 2).toUpperCase();

              const isCallBack = o.status === 'call_back';

              return (
                <tr key={o.id} className="hover:bg-muted/60 transition-colors duration-150 group">
                  {/* 1. Order # Monospace Pill */}
                  <td className="py-4 px-4 whitespace-nowrap">
                    <span className="inline-flex items-center px-2.5 py-1 rounded-md text-xs font-mono font-bold bg-emerald-50 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800/50">
                      #{o.orderNumber}
                    </span>
                  </td>

                  {/* 2. Customer Avatar + Name & Phone */}
                  <td className="py-4 px-4">
                    <div className="flex items-center gap-3 max-w-[200px]">
                      <div className="w-8 h-8 rounded-full bg-emerald-100 dark:bg-emerald-900/50 text-emerald-800 dark:text-emerald-300 flex items-center justify-center font-bold text-xs shrink-0">
                        {initials}
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="text-xs font-bold text-foreground truncate">{o.customerName}</p>
                        <p className="text-[11px] font-mono text-muted-foreground truncate">{o.customerPhone}</p>
                      </div>
                    </div>
                  </td>

                  {/* 3. Product & Location */}
                  <td className="py-4 px-4">
                    <div className="max-w-[230px] space-y-1">
                      <div className="flex items-center gap-1.5 text-xs font-medium text-foreground truncate">
                        <Package className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
                        <span className="truncate">{o.productName}</span>
                      </div>
                      <div className="flex items-center gap-1.5 text-[11px] text-muted-foreground truncate">
                        <MapPin className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
                        <span className="truncate">{o.deliveryState} - {o.deliveryAddress}</span>
                      </div>
                    </div>
                  </td>

                  {/* 4. Total COD Amount */}
                  <td className="py-4 px-4 whitespace-nowrap">
                    <span className="text-xs font-mono font-bold text-foreground">
                      {o.currency} {o.totalAmount.toLocaleString()}
                    </span>
                  </td>

                  {/* 5. Queue Status Pill (Thin 1px Outline) */}
                  <td className="py-4 px-4 whitespace-nowrap">
                    {isCallBack ? (
                      <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-50 dark:bg-amber-950/40 text-amber-600 dark:text-amber-400 border border-amber-300 dark:border-amber-700/60">
                        <RotateCw className="w-3 h-3" />
                        <span>Call Back</span>
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 dark:text-emerald-400 border border-emerald-300 dark:border-emerald-700/60">
                        <CheckCircle2 className="w-3 h-3" />
                        <span>New Lead</span>
                      </span>
                    )}
                  </td>

                  {/* 6. Actions */}
                  <td className="py-4 px-4 whitespace-nowrap">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => onStartCall(o)}
                        className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold bg-[#0A2E23] dark:bg-emerald-600 text-white hover:opacity-90 transition-opacity cursor-pointer shadow-2xs"
                      >
                        <Phone className="w-3 h-3" />
                        <span>Start Call</span>
                      </button>

                      <button
                        onClick={() => onViewDoc(o)}
                        className="p-1.5 rounded-lg border border-border text-muted-foreground hover:bg-muted hover:text-foreground transition-colors cursor-pointer"
                        title="View Document"
                      >
                        <FileText className="w-4 h-4" />
                      </button>

                      <button
                        className="p-1.5 rounded-lg border border-border text-muted-foreground hover:bg-muted hover:text-foreground transition-colors cursor-pointer"
                        title="More Options"
                      >
                        <MoreHorizontal className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* Table Footer */}
      <div className="py-3 px-4 border-t border-border flex items-center justify-between text-xs text-muted-foreground bg-muted/20">
        <span>Showing {orders.length} of {orders.length} orders</span>
        <span>🕒 Last updated: just now</span>
      </div>
    </div>
  );
};
