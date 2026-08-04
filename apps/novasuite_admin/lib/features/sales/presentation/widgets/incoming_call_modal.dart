import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class IncomingCallModal extends StatefulWidget {
  final String callerNumber;
  final OrderModel? order;
  final VoidCallback onAnswered;
  final VoidCallback onDeclined;

  const IncomingCallModal({
    super.key,
    required this.callerNumber,
    this.order,
    required this.onAnswered,
    required this.onDeclined,
  });

  @override
  State<IncomingCallModal> createState() => _IncomingCallModalState();
}

class _IncomingCallModalState extends State<IncomingCallModal> {
  final NovaSipTelephonyService _telephonyService = NovaSipTelephonyService();

  void _answerCall() {
    _telephonyService.answerIncomingCall();
    widget.onAnswered();
  }

  void _declineCall() {
    _telephonyService.rejectIncomingCall();
    widget.onDeclined();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final displayName = widget.order?.customerName ?? 'Customer (${widget.callerNumber})';
    final location = widget.order?.deliveryState ?? 'Incoming PSTN Call';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _declineCall();
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669),
            width: 2,
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Ringing Header Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_callback_rounded, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'INCOMING CALL RINGING...',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Caller Avatar / Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFE0F2F1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? const Color(0xFF1E3E33) : Colors.teal.shade200,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF00695C),
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),

                // Customer Name & Caller ID
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.callerNumber} • $location',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 28),

                // Answer / Decline Action Buttons
                Row(
                  children: [
                    // Decline Red Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _declineCall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEF4444),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.call_end_rounded, size: 20),
                          label: Text(
                            'Decline',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Answer Green Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _answerCall,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                          label: Text(
                            'Answer',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
