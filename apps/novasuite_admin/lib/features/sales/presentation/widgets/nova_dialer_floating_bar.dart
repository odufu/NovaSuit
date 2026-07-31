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
        final callState = snapshot.data ?? SipCallSessionState.idle;

        if (callState == SipCallSessionState.idle || callState == SipCallSessionState.disconnected) {
          return const SizedBox.shrink();
        }

        final order = _telephonyService.activeOrder;
        final isDarkMode = widget.isDarkMode;

        return Positioned(
          bottom: 24,
          right: 24,
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(16),
            color: isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFF0F172A),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Pulsing Call Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF34D399), size: 18),
                  ),
                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order?.customerName ?? 'Active Customer',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      StreamBuilder<int>(
                        stream: _telephonyService.durationStream,
                        initialData: _telephonyService.callDurationSeconds,
                        builder: (context, durationSnapshot) {
                          final duration = durationSnapshot.data ?? 0;
                          return Text(
                            '${_telephonyService.formatDuration(duration)} • Live ASTPP SIP Call',
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

                  // Mute Button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _telephonyService.toggleMute();
                      });
                    },
                    icon: Icon(
                      _telephonyService.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                      color: _telephonyService.isMuted ? Colors.redAccent : Colors.white70,
                      size: 18,
                    ),
                    tooltip: _telephonyService.isMuted ? 'Unmute' : 'Mute',
                  ),

                  // Expand to Full Softphone Modal
                  ElevatedButton.icon(
                    onPressed: widget.onOpenCallModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.open_in_full_rounded, size: 14),
                    label: const Text('Expand', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(width: 8),

                  // Hang Up Button
                  IconButton(
                    onPressed: () {
                      _telephonyService.endCall();
                    },
                    icon: const Icon(Icons.call_end_rounded, color: Colors.redAccent, size: 20),
                    tooltip: 'End Call',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
