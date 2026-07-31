import React from 'react';

export const HeaderStatCards: React.FC = () => {
  return (
    <div className="flex items-center gap-3">
      {/* Stat 1: Total Pipeline */}
      <div className="px-4 py-2.5 rounded-xl bg-card border border-border shadow-2xs text-center min-w-[100px]">
        <p className="text-sm font-bold font-mono text-emerald-600 dark:text-emerald-400">₦125k</p>
        <p className="text-[10px] text-muted-foreground font-medium">Total Pipeline</p>
      </div>

      {/* Stat 2: New Leads */}
      <div className="px-5 py-2.5 rounded-xl bg-card border border-border shadow-2xs text-center min-w-[100px]">
        <p className="text-sm font-bold text-foreground">3</p>
        <p className="text-[10px] text-muted-foreground font-medium">New Leads</p>
      </div>

      {/* Stat 3: Call Backs */}
      <div className="px-5 py-2.5 rounded-xl bg-card border border-border shadow-2xs text-center min-w-[100px]">
        <p className="text-sm font-bold text-amber-600 dark:text-amber-400">1</p>
        <p className="text-[10px] text-muted-foreground font-medium">Call Backs</p>
      </div>
    </div>
  );
};
