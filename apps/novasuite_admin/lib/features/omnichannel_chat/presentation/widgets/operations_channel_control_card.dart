import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class OperationsChannelControlCard extends StatefulWidget {
  final UserModel currentUser;
  final bool isDarkMode;
  final bool isCompact;
  final Function(String channel, bool enabled)? onChannelToggled;

  const OperationsChannelControlCard({
    super.key,
    required this.currentUser,
    required this.isDarkMode,
    this.isCompact = false,
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
          content: Text('🔒 Access Restricted: Only Operations, Supervisors & Admins can toggle channels!'),
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

  void _openOpsChannelSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: Color(0xFF10B981), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Operations Channel Overrides',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFullToggleTile(
                title: '📞 PSTN SIP Voice Calls',
                subtitle: _voiceEnabled ? '🟢 Channel Online (OpenSIPS Port 5060 Active)' : '🔴 Channel Suspended',
                isEnabled: _voiceEnabled,
                onChanged: (val) {
                  setModalState(() => _voiceEnabled = val);
                  _handleToggleAttempt('voice', val);
                },
              ),
              const SizedBox(height: 10),
              _buildFullToggleTile(
                title: '💬 WhatsApp Business API',
                subtitle: _whatsappEnabled ? '🟢 Channel Online (Cloud API Active)' : '🔴 Channel Suspended',
                isEnabled: _whatsappEnabled,
                onChanged: (val) {
                  setModalState(() => _whatsappEnabled = val);
                  _handleToggleAttempt('whatsapp', val);
                },
              ),
              const SizedBox(height: 10),
              _buildFullToggleTile(
                title: '📱 SMS Trunk Gateway',
                subtitle: _smsEnabled ? '🟢 Channel Online (Terminating Gateway)' : '🔴 Channel Suspended',
                isEnabled: _smsEnabled,
                onChanged: (val) {
                  setModalState(() => _smsEnabled = val);
                  _handleToggleAttempt('sms', val);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ultra-compact status bar for mobile / compact views
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.hub_rounded, size: 14, color: widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
          const SizedBox(width: 6),
          Text(
            'CHANNELS:',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildCompactStatusPill('Voice', _voiceEnabled, '📞'),
                  const SizedBox(width: 6),
                  _buildCompactStatusPill('WhatsApp', _whatsappEnabled, '💬'),
                  const SizedBox(width: 6),
                  _buildCompactStatusPill('SMS', _smsEnabled, '📱'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: _openOpsChannelSettingsModal,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? const Color(0xFF132A22) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: widget.isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    _canToggleChannels ? Icons.tune_rounded : Icons.lock_outline_rounded,
                    size: 12,
                    color: _canToggleChannels ? const Color(0xFF10B981) : Colors.amber.shade700,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    _canToggleChannels ? 'Ops' : 'Locked',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _canToggleChannels ? const Color(0xFF10B981) : Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatusPill(String name, bool isOnline, String icon) {
    return InkWell(
      onTap: _openOpsChannelSettingsModal,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isOnline
              ? (widget.isDarkMode ? const Color(0xFF064E3B).withValues(alpha: 0.4) : const Color(0xFFF0FDF4))
              : (widget.isDarkMode ? const Color(0xFF380C0C).withValues(alpha: 0.4) : const Color(0xFFFEF2F2)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isOnline
                ? (widget.isDarkMode ? const Color(0xFF10B981) : const Color(0xFF86EFAC))
                : (widget.isDarkMode ? const Color(0xFFDC2626) : const Color(0xFFFCA5A5)),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$icon $name',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullToggleTile({
    required String title,
    required String subtitle,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
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
            onChanged: _canToggleChannels ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
