import React from "react";
import { useTheme } from "next-themes";
import { Moon, Sun } from "lucide-react";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
      className="p-2 rounded-xl bg-secondary text-secondary-foreground border border-border hover:bg-accent transition-all cursor-pointer flex items-center justify-center gap-2 text-xs font-semibold"
      title="Toggle Dark / Light Mode"
    >
      {theme === "dark" ? (
        <>
          <Sun className="w-4 h-4 text-amber-400" />
          <span>Light Mode</span>
        </>
      ) : (
        <>
          <Moon className="w-4 h-4 text-slate-700 dark:text-slate-200" />
          <span>Dark Mode</span>
        </>
      )}
    </button>
  );
}
