import {
  LayoutDashboard,
  PhoneCall,
  ClipboardList,
  CheckSquare,
  TrendingUp,
  BarChart3,
  BookOpen,
  X,
  ChevronRight,
} from "lucide-react";

interface NavItem {
  icon: React.ReactNode;
  label: string;
  active?: boolean;
  badge?: number;
}

const navItems: NavItem[] = [
  { icon: <LayoutDashboard size={18} />, label: "Dashboard Overview" },
  { icon: <PhoneCall size={18} />, label: "Live Dialer Queue", active: true, badge: 4 },
  { icon: <ClipboardList size={18} />, label: "All Orders Directory" },
  { icon: <CheckSquare size={18} />, label: "Confirmed Orders Log" },
  { icon: <TrendingUp size={18} />, label: "Upsell Approvals Hub" },
  { icon: <BarChart3 size={18} />, label: "Rep Performance" },
  { icon: <BookOpen size={18} />, label: "Call Scripts & Objections" },
];

interface SidebarProps {
  open: boolean;
  onClose: () => void;
}

export function Sidebar({ open, onClose }: SidebarProps) {
  return (
    <>
      {/* Mobile overlay */}
      {open && (
        <div
          className="fixed inset-0 bg-black/40 z-30 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar panel */}
      <aside
        className={[
          "fixed top-0 left-0 h-full z-40 flex flex-col transition-transform duration-300",
          "bg-[var(--sidebar)] w-64",
          open ? "translate-x-0" : "-translate-x-full",
          "lg:translate-x-0 lg:static lg:z-auto",
        ].join(" ")}
      >
        {/* Logo */}
        <div className="flex items-center justify-between px-5 py-5 border-b border-[var(--sidebar-border)]">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-[var(--sidebar-primary)] flex items-center justify-center">
              <PhoneCall size={15} className="text-[var(--sidebar-primary-foreground)]" />
            </div>
            <div>
              <p className="text-white text-sm leading-none">NovaCare</p>
              <p className="text-[var(--sidebar-foreground)] text-xs mt-0.5">CRM Suite</p>
            </div>
          </div>
          <button
            onClick={onClose}
            className="lg:hidden text-[var(--sidebar-foreground)] hover:text-white transition-colors p-1 rounded"
          >
            <X size={18} />
          </button>
        </div>

        {/* Nav */}
        <nav className="flex-1 px-3 py-4 space-y-0.5 overflow-y-auto">
          {navItems.map((item) => (
            <button
              key={item.label}
              className={[
                "w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition-all group",
                item.active
                  ? "bg-[var(--sidebar-accent)] text-white"
                  : "text-[var(--sidebar-foreground)] hover:bg-[var(--sidebar-accent)]/60 hover:text-white",
              ].join(" ")}
            >
              <span className={item.active ? "text-[var(--sidebar-primary)]" : "opacity-70 group-hover:opacity-100"}>
                {item.icon}
              </span>
              <span className="flex-1 text-left truncate">{item.label}</span>
              {item.badge !== undefined && (
                <span className="bg-[var(--sidebar-primary)] text-[var(--sidebar-primary-foreground)] text-xs px-1.5 py-0.5 rounded-full">
                  {item.badge}
                </span>
              )}
              {item.active && <ChevronRight size={14} className="opacity-50" />}
            </button>
          ))}
        </nav>

        {/* User */}
        <div className="px-4 py-4 border-t border-[var(--sidebar-border)]">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-[var(--sidebar-accent)] flex items-center justify-center text-white text-xs shrink-0">
              SR
            </div>
            <div className="min-w-0">
              <p className="text-white text-xs truncate">Sales Call Rep</p>
              <p className="text-[var(--sidebar-foreground)] text-xs truncate">saler_call_rep@novacare</p>
            </div>
          </div>
        </div>
      </aside>
    </>
  );
}
