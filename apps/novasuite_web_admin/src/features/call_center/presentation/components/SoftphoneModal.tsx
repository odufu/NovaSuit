import React, { useState, useEffect } from 'react';
import type { OrderLead } from '../../domain/models/OrderLead';
import { PhoneOff, Mic, MicOff, Pause, Play, CheckCircle2, RotateCw, XCircle, UserX, AlertTriangle, X } from 'lucide-react';

interface SoftphoneModalProps {
  order: OrderLead | null;
  isOpen: boolean;
  onClose: () => void;
}

export const SoftphoneModal: React.FC<SoftphoneModalProps> = ({ order, isOpen, onClose }) => {
  const [phase, setPhase] = useState<'in_call' | 'post_call'>('in_call');
  const [seconds, setSeconds] = useState(0);
  const [isMuted, setIsMuted] = useState(false);
  const [isOnHold, setIsOnHold] = useState(false);
  const [selectedOutcome, setSelectedOutcome] = useState<string | null>(null);

  useEffect(() => {
    let timer: any;
    if (isOpen && phase === 'in_call') {
      timer = setInterval(() => setSeconds((s) => s + 1), 1000);
    }
    return () => clearInterval(timer);
  }, [isOpen, phase]);

  if (!isOpen || !order) return null;

  const formatTimer = (s: number) => {
    const mins = Math.floor(s / 60).toString().padStart(2, '0');
    const secs = (s % 60).toString().padStart(2, '0');
    return `${mins}:${secs}`;
  };

  const handleEndCall = () => {
    setPhase('post_call');
  };

  const nameParts = order.customerName.trim().split(' ');
  const initials = nameParts.length >= 2
    ? `${nameParts[0][0]}${nameParts[1][0]}`.toUpperCase()
    : order.customerName.substring(0, 2).toUpperCase();

  const outcomes = [
    { id: 'confirmed', label: 'Order Confirmed', icon: CheckCircle2, color: 'text-emerald-500 bg-emerald-500/10 border-emerald-500/30' },
    { id: 'call_back', label: 'Call Back Later', icon: RotateCw, color: 'text-amber-500 bg-amber-500/10 border-amber-500/30' },
    { id: 'unavailable', label: 'Customer Unavailable', icon: UserX, color: 'text-blue-500 bg-blue-500/10 border-blue-500/30' },
    { id: 'wrong_num', label: 'Wrong Number', icon: AlertTriangle, color: 'text-rose-500 bg-rose-500/10 border-rose-500/30' },
    { id: 'cancelled', label: 'Order Cancelled', icon: XCircle, color: 'text-red-500 bg-red-500/10 border-red-500/30' },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-xs animate-in fade-in duration-200">
      <div className="w-full max-w-md bg-[#091A14] text-white rounded-3xl border border-emerald-900/40 shadow-2xl overflow-hidden p-6 relative">
        <button
          onClick={onClose}
          className="absolute top-4 right-4 text-emerald-400/60 hover:text-emerald-300 p-1.5 rounded-full hover:bg-emerald-950/60 transition-colors"
        >
          <X className="w-5 h-5" />
        </button>

        {phase === 'in_call' ? (
          <div className="flex flex-col items-center text-center space-y-5 py-4">
            {/* Softphone OLED Header */}
            <div className="flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-950/80 border border-emerald-800/40 text-[11px] font-mono text-emerald-400">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span>LIVE CALL • IT SKY TRUNK (196.13.112.196)</span>
            </div>

            {/* Avatar Circle */}
            <div className="w-20 h-20 rounded-full bg-[#1B4D3E] text-emerald-100 font-bold text-2xl flex items-center justify-center border-2 border-emerald-500/30 shadow-lg">
              {initials}
            </div>

            {/* Customer Details */}
            <div>
              <span className="text-xs font-mono text-emerald-400/70 font-semibold">#{order.orderNumber}</span>
              <h3 className="text-xl font-bold text-white mt-1">{order.customerName}</h3>
              <p className="text-sm font-mono text-emerald-200/80">{order.customerPhone}</p>
            </div>

            {/* Glowing Live Timer */}
            <div className="text-3xl font-mono font-bold tracking-wider text-emerald-400 py-1">
              {formatTimer(seconds)}
            </div>

            {/* In-Call Controls */}
            <div className="flex items-center gap-4 pt-2">
              <button
                onClick={() => setIsMuted(!isMuted)}
                className={`p-3.5 rounded-2xl border transition-all cursor-pointer ${
                  isMuted ? 'bg-amber-500/20 border-amber-500 text-amber-400' : 'bg-emerald-950/60 border-emerald-800/40 text-emerald-200 hover:bg-emerald-900/60'
                }`}
                title={isMuted ? 'Unmute' : 'Mute'}
              >
                {isMuted ? <MicOff className="w-5 h-5" /> : <Mic className="w-5 h-5" />}
              </button>

              <button
                onClick={() => setIsOnHold(!isOnHold)}
                className={`p-3.5 rounded-2xl border transition-all cursor-pointer ${
                  isOnHold ? 'bg-amber-500/20 border-amber-500 text-amber-400' : 'bg-emerald-950/60 border-emerald-800/40 text-emerald-200 hover:bg-emerald-900/60'
                }`}
                title={isOnHold ? 'Resume Call' : 'Hold Call'}
              >
                {isOnHold ? <Play className="w-5 h-5" /> : <Pause className="w-5 h-5" />}
              </button>

              <button
                onClick={handleEndCall}
                className="flex-1 inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-bold text-sm cursor-pointer shadow-lg shadow-rose-950/50 transition-all"
              >
                <PhoneOff className="w-5 h-5" />
                <span>End Call</span>
              </button>
            </div>
          </div>
        ) : (
          /* Post-Call Outcome Selection */
          <div className="space-y-5 py-2">
            <div className="text-center">
              <span className="inline-block px-3 py-1 rounded-full bg-rose-950/60 text-rose-400 text-xs font-mono font-bold border border-rose-800/40">
                Call Ended • {formatTimer(seconds)}
              </span>
              <h3 className="text-lg font-bold text-white mt-2">Log Call Outcome</h3>
              <p className="text-xs text-emerald-200/70">Select final disposition for #{order.orderNumber}</p>
            </div>

            <div className="grid grid-cols-1 gap-2.5">
              {outcomes.map((o) => {
                const Icon = o.icon;
                const isSelected = selectedOutcome === o.id;
                return (
                  <button
                    key={o.id}
                    onClick={() => setSelectedOutcome(o.id)}
                    className={`flex items-center gap-3 p-3 rounded-xl border text-xs font-bold transition-all cursor-pointer ${
                      isSelected
                        ? 'bg-emerald-500/20 border-emerald-400 text-emerald-300 ring-2 ring-emerald-400/40'
                        : `${o.color} hover:bg-white/5`
                    }`}
                  >
                    <Icon className="w-4 h-4 shrink-0" />
                    <span>{o.label}</span>
                  </button>
                );
              })}
            </div>

            <div className="pt-2">
              <button
                onClick={onClose}
                disabled={!selectedOutcome}
                className="w-full py-3 rounded-xl bg-emerald-500 hover:bg-emerald-400 disabled:opacity-40 disabled:cursor-not-allowed text-emerald-950 font-bold text-sm transition-all cursor-pointer"
              >
                Save Disposition & Close
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
