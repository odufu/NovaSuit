import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class OperationsChannelControlCard extends StatefulWidget {
  final UserModel currentUser;
  final bool isDarkMode;
  final Function(String channel, bool enabled)? onChannelToggled;

  const OperationsChannelControlCard({
    super.key,
    required this.currentUser,
    required this.isDarkMode,
    this.onChannelToggled,
  });

  @override
  State<OperationsChannelControlCard> createState() => _OperationsChannelControlCardState();
}

class _OperationsChannelControlCardState extends State<OperationsChannelControlCard> {
  bool _voiceEnabled = true;
  bool _whatsappEnabled = true;
  bool _smsEnabled = true;

  bool get _canToggleChannels {
    return widget.currentUser.role == UserRole.superAdmin ||
        widget.currentUser.role == UserRole.agm ||
        widget.currentUser.role == UserRole.supervisor;
  }

  void _handleToggleAttempt(String channel, bool targetValue) {
    if (!_canToggleChannels) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.amber,
          content: Text('🔒 Access Restricted: Only Operations, Supervisors & Admins can toggle omnichannel channels!'),
        ),
      );
      return;
    }

    setState(() {
      if (channel == 'voice') _voiceEnabled = targetValue;
      if (channel == 'whatsapp') _whatsappEnabled = targetValue;
      if (channel == 'sms') _smsEnabled = targetValue;
    });

    widget.onChannelToggled?.call(channel, targetValue);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: widget.isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OPERATIONS OMNICHANNEL CHANNEL CONTROLS',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _canToggleChannels
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _canToggleChannels ? const Color(0xFF10B981) : Colors.amber,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _canToggleChannels ? 'OPS OVERRIDE' : '🔒 READ ONLY (OPS)',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _canToggleChannels ? const Color(0xFF10B981) : Colors.amber.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                // 1. PSTN Voice Channel Toggle
                _buildChannelToggleTile(
                  title: '📞 PSTN SIP Voice Calls',
                  subtitle: _voiceEnabled ? '🟢 Channel Online (OpenSIPS Port 5060 Active)' : '🔴 Channel Suspended by Ops',
                  isEnabled: _voiceEnabled,
                  canToggle: _canToggleChannels,
                  onChanged: (val) => _handleToggleAttempt('voice', val),
                ),

                // 2. WhatsApp Business Channel Toggle
                _buildChannelToggleTile(
                  title: '💬 WhatsApp Business API',
                  subtitle: _whatsappEnabled ? '🟢 Channel Online (Cloud API Active)' : '🔴 Channel Paused by Ops',
                  isEnabled: _whatsappEnabled,
                  canToggle: _canToggleChannels,
                  onChanged: (val) => _handleToggleAttempt('whatsapp', val),
                ),

                // 3. SMS Trunk Channel Toggle
                _buildChannelToggleTile(
                  title: '📱 SMS Trunk Gateway',
                  subtitle: _smsEnabled ? '🟢 Channel Online (Terminating Gateway)' : '🔴 Channel Disabled',
                  isEnabled: _smsEnabled,
                  canToggle: _canToggleChannels,
                  onChanged: (val) => _handleToggleAttempt('sms', val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelToggleTile({
    required String title,
    required String subtitle,
    required bool isEnabled,
    required bool canToggle,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isEnabled
            ? (widget.isDarkMode ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4))
            : (widget.isDarkMode ? const Color(0xFF380C0C).withValues(alpha: 0.3) : const Color(0xFFFEF2F2)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? (widget.isDarkMode ? const Color(0xFF10B981) : const Color(0xFF86EFAC))
              : (widget.isDarkMode ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: widget.isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            activeTrackColor: const Color(0xFF10B981),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
