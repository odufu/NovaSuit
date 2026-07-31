import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class NovaDialerFloatingBar extends StatefulWidget {
  final TenantTheme activeTheme;
  final UserModel? currentUser;
  final bool isDarkMode;
  final VoidCallback? onOpenCallModal;

  const NovaDialerFloatingBar({
    super.key,
    required this.activeTheme,
    this.currentUser,
    this.isDarkMode = false,
    this.onOpenCallModal,
  });

  @override
  State<NovaDialerFloatingBar> createState() => _NovaDialerFloatingBarState();
}

class _NovaDialerFloatingBarState extends State<NovaDialerFloatingBar> {
  final NovaSipTelephonyService _telephonyService = NovaSipTelephonyService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SipCallSessionState>(
      stream: _telephonyService.callStateStream,
      initialData: _telephonyService.callState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? SipCallSessionState.idle;

        if (state == SipCallSessionState.idle) {
          return const SizedBox.shrink();
        }

        final activeOrder = _telephonyService.activeOrder;
        final isDarkMode = widget.isDarkMode;

        return Material(
          elevation: 12,
          borderRadius: BorderRadius.circular(30),
          color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFF0A2E23),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeOrder?.customerName ?? 'Active SIP Session',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    StreamBuilder<int>(
                      stream: _telephonyService.durationStream,
                      initialData: _telephonyService.callDurationSeconds,
                      builder: (context, durSnapshot) {
                        final dur = durSnapshot.data ?? 0;
                        final min = dur ~/ 60;
                        final sec = dur % 60;
                        final timeStr = '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
                        return Text(
                          'In Call • $timeStr',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                IconButton(
                  onPressed: widget.onOpenCallModal,
                  icon: const Icon(Icons.open_in_full, color: Colors.white, size: 18),
                  tooltip: 'Maximize Call Modal',
                ),

                IconButton(
                  onPressed: () {
                    _telephonyService.endCall();
                  },
                  icon: const Icon(Icons.call_end, color: Colors.redAccent, size: 20),
                  tooltip: 'End Call',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
