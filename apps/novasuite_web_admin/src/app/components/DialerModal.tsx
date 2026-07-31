import { useState, useEffect, useRef } from "react";
import {
  PhoneOff,
  Mic,
  MicOff,
  PauseCircle,
  Hash,
  StickyNote,
  X,
  RotateCcw,
  ChevronDown,
  Check,
} from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

export interface Order {
  id: string;
  customer: string;
  initials: string;
  phone: string;
  product: string;
  location: string;
  cod: number;
  status: "new_lead" | "call_back" | "confirmed" | "no_answer";
}

const DISPOSITIONS = [
  "Order Confirmed",
  "Call Back Later",
  "Customer Unavailable",
  "Wrong Number",
  "Order Cancelled",
  "Rescheduled",
];

interface DialerModalProps {
  order: Order;
  onClose: () => void;
}

export function DialerModal({ order, onClose }: DialerModalProps) {
  const [callStatus, setCallStatus] = useState<"ringing" | "connected" | "ended">("ringing");
  const [elapsed, setElapsed] = useState(0);
  const [muted, setMuted] = useState(false);
  const [onHold, setOnHold] = useState(false);
  const [showDialpad, setShowDialpad] = useState(false);
  const [showNotes, setShowNotes] = useState(false);
  const [notes, setNotes] = useState("");
  const [dialpadInput, setDialpadInput] = useState("");
  const [showDisposition, setShowDisposition] = useState(false);
  const [disposition, setDisposition] = useState("");
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    const connectTimer = setTimeout(() => setCallStatus("connected"), 2800);
    return () => clearTimeout(connectTimer);
  }, []);

  useEffect(() => {
    if (callStatus === "connected") {
      timerRef.current = setInterval(() => setElapsed((s) => s + 1), 1000);
    }
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, [callStatus]);

  const formatTime = (s: number) => {
    const m = Math.floor(s / 60).toString().padStart(2, "0");
    const sec = (s % 60).toString().padStart(2, "0");
    return `${m}:${sec}`;
  };

  const handleEndCall = () => {
    setCallStatus("ended");
    if (timerRef.current) clearInterval(timerRef.current);
    setShowDisposition(true);
  };

  const handleDialpad = (key: string) => {
    setDialpadInput((prev) => prev + key);
  };

  const dialpadKeys = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "#"];

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4">
        {/* Backdrop */}
        <motion.div
          className="absolute inset-0 bg-black/50 backdrop-blur-sm"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={callStatus === "ended" ? onClose : undefined}
        />

        {/* Dialer card */}
        <motion.div
          className="relative w-full sm:w-96 bg-[#0C1F17] rounded-t-3xl sm:rounded-2xl overflow-hidden shadow-2xl"
          initial={{ y: "100%", opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: "100%", opacity: 0 }}
          transition={{ type: "spring", damping: 28, stiffness: 300 }}
        >
          {/* Close button */}
          {callStatus === "ended" && (
            <button
              onClick={onClose}
              className="absolute top-4 right-4 text-white/40 hover:text-white/80 transition-colors z-10"
            >
              <X size={20} />
            </button>
          )}

          {/* Header - contact info */}
          <div className="px-6 pt-8 pb-5 text-center">
            {/* Avatar */}
            <div className="relative inline-block mb-4">
              <div
                className={[
                  "w-20 h-20 rounded-full flex items-center justify-center text-2xl text-white mx-auto",
                  callStatus === "connected" ? "bg-[#1A5C42]" : "bg-[#1A3C2A]",
                ].join(" ")}
              >
                {order.initials}
              </div>
              {callStatus === "connected" && (
                <motion.div
                  className="absolute inset-0 rounded-full border-2 border-[#10B981]"
                  animate={{ scale: [1, 1.2, 1], opacity: [1, 0, 1] }}
                  transition={{ repeat: Infinity, duration: 2 }}
                />
              )}
              {callStatus === "ringing" && (
                <motion.div
                  className="absolute inset-0 rounded-full border-2 border-white/30"
                  animate={{ scale: [1, 1.4], opacity: [0.6, 0] }}
                  transition={{ repeat: Infinity, duration: 1.2 }}
                />
              )}
            </div>

            <p className="text-white/50 text-xs mb-1" style={{ fontFamily: "var(--font-mono)" }}>
              {order.id}
            </p>
            <h2 className="text-white text-xl mb-1">{order.customer}</h2>
            <p className="text-white/50 text-sm" style={{ fontFamily: "var(--font-mono)" }}>
              {order.phone}
            </p>

            {/* Call status */}
            <div className="mt-3 flex items-center justify-center gap-2">
              {callStatus === "ringing" && (
                <>
                  <span className="text-amber-400 text-sm">Ringing</span>
                  <motion.span
                    className="flex gap-0.5"
                    animate={{ opacity: [1, 0.3, 1] }}
                    transition={{ repeat: Infinity, duration: 1.2 }}
                  >
                    <span className="w-1 h-1 rounded-full bg-amber-400 inline-block" />
                    <span className="w-1 h-1 rounded-full bg-amber-400 inline-block" />
                    <span className="w-1 h-1 rounded-full bg-amber-400 inline-block" />
                  </motion.span>
                </>
              )}
              {callStatus === "connected" && (
                <span className="text-[#10B981] text-sm" style={{ fontFamily: "var(--font-mono)" }}>
                  {formatTime(elapsed)}
                </span>
              )}
              {callStatus === "ended" && (
                <span className="text-white/40 text-sm">Call Ended · {formatTime(elapsed)}</span>
              )}
            </div>

            {/* Order info strip */}
            <div className="mt-4 bg-white/5 rounded-xl px-4 py-2.5 flex items-center justify-between text-sm">
              <span className="text-white/40 text-xs">{order.product}</span>
              <span className="text-[#10B981]" style={{ fontFamily: "var(--font-mono)" }}>
                ₦{order.cod.toLocaleString()}
              </span>
            </div>
          </div>

          {/* Dialpad (collapsible) */}
          <AnimatePresence>
            {showDialpad && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                className="overflow-hidden"
              >
                {dialpadInput && (
                  <p
                    className="text-center text-white/70 text-lg mb-2 px-6"
                    style={{ fontFamily: "var(--font-mono)" }}
                  >
                    {dialpadInput}
                  </p>
                )}
                <div className="grid grid-cols-3 gap-2 px-8 pb-4">
                  {dialpadKeys.map((k) => (
                    <button
                      key={k}
                      onClick={() => handleDialpad(k)}
                      className="bg-white/8 hover:bg-white/15 text-white rounded-xl py-3 text-lg transition-all active:scale-95"
                      style={{ fontFamily: "var(--font-mono)" }}
                    >
                      {k}
                    </button>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Notes (collapsible) */}
          <AnimatePresence>
            {showNotes && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                exit={{ height: 0, opacity: 0 }}
                className="overflow-hidden px-6 pb-4"
              >
                <textarea
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Add call notes..."
                  rows={3}
                  className="w-full bg-white/8 border border-white/10 rounded-xl px-4 py-3 text-white/80 placeholder:text-white/25 text-sm resize-none focus:outline-none focus:border-[#10B981]/50"
                />
              </motion.div>
            )}
          </AnimatePresence>

          {/* Disposition selector (after call ends) */}
          <AnimatePresence>
            {showDisposition && (
              <motion.div
                initial={{ height: 0, opacity: 0 }}
                animate={{ height: "auto", opacity: 1 }}
                className="overflow-hidden px-6 pb-4"
              >
                <p className="text-white/50 text-xs mb-2">Call Outcome</p>
                <div className="grid grid-cols-2 gap-2">
                  {DISPOSITIONS.map((d) => (
                    <button
                      key={d}
                      onClick={() => setDisposition(d)}
                      className={[
                        "text-xs px-3 py-2 rounded-lg border transition-all text-left",
                        disposition === d
                          ? "border-[#10B981] bg-[#10B981]/20 text-[#10B981]"
                          : "border-white/10 text-white/50 hover:border-white/30 hover:text-white/70",
                      ].join(" ")}
                    >
                      {disposition === d && <Check size={10} className="inline mr-1" />}
                      {d}
                    </button>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Controls */}
          <div className="px-6 pb-8">
            {callStatus !== "ended" ? (
              <>
                {/* Secondary actions */}
                <div className="flex items-center justify-center gap-6 mb-6">
                  <ActionButton
                    icon={muted ? <MicOff size={18} /> : <Mic size={18} />}
                    label={muted ? "Unmute" : "Mute"}
                    active={muted}
                    onClick={() => setMuted((v) => !v)}
                  />
                  <ActionButton
                    icon={<PauseCircle size={18} />}
                    label={onHold ? "Resume" : "Hold"}
                    active={onHold}
                    onClick={() => setOnHold((v) => !v)}
                  />
                  <ActionButton
                    icon={<Hash size={18} />}
                    label="Dialpad"
                    active={showDialpad}
                    onClick={() => { setShowDialpad((v) => !v); setShowNotes(false); }}
                  />
                  <ActionButton
                    icon={<StickyNote size={18} />}
                    label="Notes"
                    active={showNotes}
                    onClick={() => { setShowNotes((v) => !v); setShowDialpad(false); }}
                  />
                </div>

                {/* End call */}
                <button
                  onClick={handleEndCall}
                  className="w-full bg-red-500 hover:bg-red-600 active:scale-95 text-white rounded-2xl py-4 flex items-center justify-center gap-2 transition-all"
                >
                  <PhoneOff size={20} />
                  <span>End Call</span>
                </button>
              </>
            ) : (
              <div className="space-y-3">
                <button
                  onClick={onClose}
                  disabled={!disposition}
                  className={[
                    "w-full rounded-2xl py-4 flex items-center justify-center gap-2 transition-all text-sm",
                    disposition
                      ? "bg-[#10B981] hover:bg-[#0D9E70] text-white active:scale-95"
                      : "bg-white/10 text-white/30 cursor-not-allowed",
                  ].join(" ")}
                >
                  <Check size={18} />
                  <span>Save & Close{!disposition ? " (select outcome first)" : ""}</span>
                </button>
                <button
                  onClick={onClose}
                  className="w-full text-white/40 hover:text-white/60 py-2 flex items-center justify-center gap-2 text-sm transition-colors"
                >
                  <RotateCcw size={14} />
                  <span>Skip for now</span>
                </button>
              </div>
            )}
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
}

function ActionButton({
  icon,
  label,
  active,
  onClick,
}: {
  icon: React.ReactNode;
  label: string;
  active?: boolean;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className="flex flex-col items-center gap-1.5 group"
    >
      <div
        className={[
          "w-12 h-12 rounded-full flex items-center justify-center transition-all",
          active
            ? "bg-[#10B981]/20 text-[#10B981]"
            : "bg-white/10 text-white/60 group-hover:bg-white/15 group-hover:text-white",
        ].join(" ")}
      >
        {icon}
      </div>
      <span className="text-white/40 text-xs group-hover:text-white/60">{label}</span>
    </button>
  );
}
