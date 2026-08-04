import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

enum CallStage {
  connectingProvider,
  initiatingCall,
  callInProgress,
  callEnded,
  disconnected,
}

class CallActionModal extends StatefulWidget {
  final OrderModel order;
  final TenantTheme activeTheme;
  final UserModel currentUser;
  final TextEditingController noteController;
  final Function(OrderModel) onUpdateOrder;
  final Function({
    required OrderModel order,
    required String activityType,
    required String title,
    required String details,
    String? newStatus,
  }) onRecordActivity;
  final Function(OrderModel) onOpenReschedule;
  final Function(OrderModel) onOpenCancellationReason;
  final Function(OrderModel) onShowRequestUpsell;

  const CallActionModal({
    super.key,
    required this.order,
    required this.activeTheme,
    required this.currentUser,
    required this.noteController,
    required this.onUpdateOrder,
    required this.onRecordActivity,
    required this.onOpenReschedule,
    required this.onOpenCancellationReason,
    required this.onShowRequestUpsell,
  });

  @override
  State<CallActionModal> createState() => _CallActionModalState();
}

class _CallActionModalState extends State<CallActionModal> {
  late ValueNotifier<CallStage> _stage;
  late ValueNotifier<int> _secondsElapsed;
  late ValueNotifier<bool> _isMuted;
  late ValueNotifier<bool> _isOnHold;
  late ValueNotifier<bool> _showDtmfKeypad;

  final NovaSipTelephonyService _telephonyService = NovaSipTelephonyService();

  late ValueNotifier<bool> _showScript;
  late ValueNotifier<bool> _showNotes;

  late ValueNotifier<String?> _selectedCategory;
  late ValueNotifier<Map<String, dynamic>?> _selectedSubStatus;

  final List<Map<String, dynamic>> _outcomeCategories = [
    {
      'id': 'confirmed',
      'title': 'CONFIRMED & DISPATCH',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF059669),
      'statuses': [
        {'status': OrderStatus.accepted, 'label': 'Confirmed for Delivery', 'desc': 'Client verified order, address, and readiness for COD.'},
        {'status': OrderStatus.upsellPending, 'label': 'Upsell / Package Change', 'desc': 'Client accepted upsell add-on; pending supervisor approval.'},
      ]
    },
    {
      'id': 'callback',
      'title': 'CALLBACK / RESCHEDULE',
      'icon': Icons.schedule_rounded,
      'color': const Color(0xFFD97706),
      'statuses': [
        {'status': OrderStatus.callBack, 'label': 'Call Back Later', 'desc': 'Client asked to be called back at a specific time.'},
        {'status': OrderStatus.deliveryRescheduled, 'label': 'Reschedule Delivery Date', 'desc': 'Client requested delivery on a future date.'},
      ]
    },
    {
      'id': 'unreachable',
      'title': 'UNREACHABLE / NO ANSWER',
      'icon': Icons.phone_missed_rounded,
      'color': const Color(0xFF0284C7),
      'statuses': [
        {'status': OrderStatus.notPicking, 'label': 'Not Picking Call', 'desc': 'Rung out with no answer from customer.'},
        {'status': OrderStatus.switchedOff, 'label': 'Switched Off / Unreachable', 'desc': 'Phone number reported switched off by network operator.'},
        {'status': OrderStatus.notReachable, 'label': 'Busy / Line Engaged', 'desc': 'Customer line engaged or busy.'},
      ]
    },
    {
      'id': 'cancelled',
      'title': 'CANCELLED / REJECTED',
      'icon': Icons.cancel_rounded,
      'color': const Color(0xFFDC2626),
      'statuses': [
        {'status': OrderStatus.cancelled, 'label': 'Customer Cancelled Order', 'desc': 'Customer declined order (no money, traveling, expensive).'},
        {'status': OrderStatus.duplicate, 'label': 'Duplicate Order', 'desc': 'Identical duplicate order already placed in system.'},
      ]
    },
  ];

  StreamSubscription? _telephonySubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _providerReasonSubscription;
  late ValueNotifier<String?> _providerReasonNotifier;

  @override
  void initState() {
    super.initState();
    _stage = ValueNotifier<CallStage>(CallStage.connectingProvider);
    _secondsElapsed = ValueNotifier<int>(0);
    _isMuted = ValueNotifier<bool>(false);
    _isOnHold = ValueNotifier<bool>(false);
    _showDtmfKeypad = ValueNotifier<bool>(false);
    _showScript = ValueNotifier<bool>(true);
    _showNotes = ValueNotifier<bool>(false);
    _selectedCategory = ValueNotifier<String?>('confirmed');
    _selectedSubStatus = ValueNotifier<Map<String, dynamic>?>(null);
    _providerReasonNotifier = ValueNotifier<String?>(null);

    _startCallWorkflow();
  }

  void _startCallWorkflow() {
    _telephonySubscription = _telephonyService.callStateStream.listen((state) {
      if (!mounted) return;
      switch (state) {
        case SipCallSessionState.connectingProvider:
          _stage.value = CallStage.connectingProvider;
          break;
        case SipCallSessionState.initiatingCall:
          _stage.value = CallStage.initiatingCall;
          break;
        case SipCallSessionState.callInProgress:
          _stage.value = CallStage.callInProgress;
          break;
        case SipCallSessionState.callEnded:
          _stage.value = CallStage.callEnded;
          break;
        case SipCallSessionState.disconnected:
          _stage.value = CallStage.disconnected;
          break;
        default:
          break;
      }
    });

    _durationSubscription = _telephonyService.durationStream.listen((duration) {
      if (!mounted) return;
      _secondsElapsed.value = duration;
    });

    _providerReasonSubscription = _telephonyService.providerReasonStream.listen((reason) {
      if (!mounted) return;
      _providerReasonNotifier.value = reason;

      // Auto-preselect CRM Disposition when provider returns specific telecom reason
      if (reason.contains('486') || reason.contains('Busy')) {
        _selectedCategory.value = 'unreachable';
        _selectedSubStatus.value = _outcomeCategories[2]['statuses'][2]; // Busy / Line Engaged
      } else if (reason.contains('480') || reason.contains('Switched Off')) {
        _selectedCategory.value = 'unreachable';
        _selectedSubStatus.value = _outcomeCategories[2]['statuses'][1]; // Switched Off
      } else if (reason.contains('404') || reason.contains('Invalid')) {
        _selectedCategory.value = 'unreachable';
        _selectedSubStatus.value = _outcomeCategories[2]['statuses'][0]; // Not Picking / Unreachable
      }
    });

    _telephonyService.initiateCall(widget.order);
  }

  void _endCall() {
    _telephonyService.endCall();
    _stage.value = CallStage.disconnected;
  }

  @override
  void dispose() {
    _telephonySubscription?.cancel();
    _durationSubscription?.cancel();
    _providerReasonSubscription?.cancel();
    _stage.dispose();
    _secondsElapsed.dispose();
    _isMuted.dispose();
    _isOnHold.dispose();
    _showDtmfKeypad.dispose();
    _showScript.dispose();
    _showNotes.dispose();
    _selectedCategory.dispose();
    _selectedSubStatus.dispose();
    _providerReasonNotifier.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final productName = widget.order.productId.contains('tea')
        ? 'Grazer Herbal Detox Tea'
        : (widget.order.productId.contains('booster') ? 'Herbal Vitality Booster' : 'Clear Skin Care Set');

    return ValueListenableBuilder<CallStage>(
      valueListenable: _stage,
      builder: (context, stageVal, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _selectedCategory,
          builder: (context, selectedCategoryVal, _) {
            final currentCategory = _outcomeCategories.firstWhere(
              (c) => c['id'] == (selectedCategoryVal ?? 'confirmed'),
              orElse: () => _outcomeCategories.first,
            );

            return PopScope(
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  _endCall();
                }
              },
              child: Dialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                backgroundColor: isDarkMode ? const Color(0xFF0C1F17) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200, width: 1.5),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Bar: Customer & SIP Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF0D382B) : const Color(0xFFE0F2F1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.phone_in_talk_rounded, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF00695C), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.order.customerName, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                                    Text('${widget.order.customerPhone} • ${widget.order.deliveryState}', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600)),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                _endCall();
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : Colors.grey),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        if (stageVal != CallStage.disconnected && stageVal != CallStage.callEnded) ...[
                          // Call Live Progress Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: stageVal == CallStage.callInProgress ? const Color(0xFF10B981) : Colors.amber,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      stageVal == CallStage.connectingProvider
                                          ? 'Connecting ITSKY DID Trunk...'
                                          : (stageVal == CallStage.initiatingCall ? 'Ringing Customer...' : 'Call Active'),
                                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                    ),
                                  ],
                                ),
                                ValueListenableBuilder<int>(
                                  valueListenable: _secondsElapsed,
                                  builder: (context, secondsVal, _) {
                                    return Text(
                                      _formatDuration(secondsVal),
                                      style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Live Telecom Network Provider Feedback Badge
                          ValueListenableBuilder<String?>(
                            valueListenable: _providerReasonNotifier,
                            builder: (context, reasonVal, _) {
                              if (reasonVal == null) return const SizedBox.shrink();
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: reasonVal.contains('486') || reasonVal.contains('Busy')
                                      ? (isDarkMode ? const Color(0xFF3F2010) : const Color(0xFFFEF3C7))
                                      : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: reasonVal.contains('486') ? Colors.amber.shade700 : const Color(0xFF0284C7),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.cell_tower_rounded, size: 16, color: Color(0xFF0284C7)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Telecom Feedback: $reasonVal',
                                        style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Robust Error Notice Banner (Only shown if disconnected due to an error)
                          if (stageVal == CallStage.disconnected && _telephonyService.lastError != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF3F1D1D) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.shade400, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 6),
                                      Text('SIP Trunk Connection Warning', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.redAccent)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _telephonyService.lastError ?? 'Call disconnected or trunk unreachable.',
                                    style: GoogleFonts.inter(fontSize: 11, color: isDarkMode ? Colors.red.shade200 : Colors.red.shade900),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _startCallWorkflow();
                                    },
                                    icon: const Icon(Icons.refresh_rounded, size: 14),
                                    label: const Text('Retry Dialing'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      visualDensity: VisualDensity.compact,
                                      textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Call In-Progress Controls (Mute, Hold, Keypad, Script, Notes)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable: _isMuted,
                                builder: (context, mutedVal, _) {
                                  return Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () => _isMuted.value = !mutedVal,
                                        style: IconButton.styleFrom(
                                          backgroundColor: mutedVal ? Colors.red : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                                          foregroundColor: mutedVal ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                                          padding: const EdgeInsets.all(14),
                                        ),
                                        icon: Icon(mutedVal ? Icons.mic_off : Icons.mic, size: 20),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Mute', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                                    ],
                                  );
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _isOnHold,
                                builder: (context, holdVal, _) {
                                  return Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () => _isOnHold.value = !holdVal,
                                        style: IconButton.styleFrom(
                                          backgroundColor: holdVal ? Colors.amber.shade700 : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                                          foregroundColor: holdVal ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                                          padding: const EdgeInsets.all(14),
                                        ),
                                        icon: Icon(holdVal ? Icons.pause : Icons.pause_circle_outline, size: 20),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Hold', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                                    ],
                                  );
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _showDtmfKeypad,
                                builder: (context, dtmfVal, _) {
                                  return Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () => _showDtmfKeypad.value = !dtmfVal,
                                        style: IconButton.styleFrom(
                                          backgroundColor: dtmfVal ? const Color(0xFF10B981) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                                          foregroundColor: dtmfVal ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                                          padding: const EdgeInsets.all(14),
                                        ),
                                        icon: const Icon(Icons.dialpad_rounded, size: 20),
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Keypad', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                                    ],
                                  );
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _showScript,
                                builder: (context, scriptVal, _) {
                                  return Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () {
                                          _showScript.value = !scriptVal;
                                          if (_showScript.value) {
                                            _showNotes.value = false;
                                            _showDtmfKeypad.value = false;
                                          }
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor: scriptVal ? (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23)) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                                          foregroundColor: scriptVal ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                                          padding: const EdgeInsets.all(14),
                                        ),
                                        icon: const Icon(Icons.description_outlined, size: 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Script', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                                    ],
                                  );
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _showNotes,
                                builder: (context, notesVal, _) {
                                  return Column(
                                    children: [
                                      IconButton.filled(
                                        onPressed: () {
                                          _showNotes.value = !notesVal;
                                          if (_showNotes.value) {
                                            _showScript.value = false;
                                            _showDtmfKeypad.value = false;
                                          }
                                        },
                                        style: IconButton.styleFrom(
                                          backgroundColor: notesVal ? (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23)) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                                          foregroundColor: notesVal ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                                          padding: const EdgeInsets.all(14),
                                        ),
                                        icon: const Icon(Icons.note_alt_outlined, size: 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Notes', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          ValueListenableBuilder<bool>(
                            valueListenable: _showScript,
                            builder: (context, scriptVal, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: _showNotes,
                                builder: (context, notesVal, _) {
                                  if (scriptVal) {
                                    return Column(
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('CALL SCRIPT • $productName', style: GoogleFonts.inter(color: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Hello ${widget.order.customerName}, my name is ${widget.currentUser.fullName} calling from NovaSuite Health. I am following up on your recent order for $productName.',
                                                style: GoogleFonts.inter(color: isDarkMode ? Colors.white : const Color(0xFF1E293B), fontSize: 11.5, height: 1.35, fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                      ],
                                    );
                                  } else if (notesVal) {
                                    return Column(
                                      children: [
                                        TextField(
                                          controller: widget.noteController,
                                          maxLines: 3,
                                          style: const TextStyle(fontSize: 12),
                                          decoration: InputDecoration(
                                            hintText: 'Enter call outcome notes or customer feedback...',
                                            hintStyle: const TextStyle(fontSize: 11),
                                            filled: true,
                                            fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300)),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              );
                            },
                          ),

                          // End Call Red Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: _endCall,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF3B30),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              ),
                              icon: const Icon(Icons.call_end, size: 18),
                              label: const Text('End Call & Log Outcome', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else ...[
                          // DISCONNECTED OUTCOME SELECTOR
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('SELECT CALL OUTCOME CATEGORY', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600, letterSpacing: 0.8)),
                          ),
                          const SizedBox(height: 8),

                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: _outcomeCategories.map((cat) {
                                final isSelected = selectedCategoryVal == cat['id'];
                                final color = cat['color'] as Color;

                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(cat['title'] as String, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87))),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        _selectedCategory.value = cat['id'] as String;
                                        _selectedSubStatus.value = null;
                                      }
                                    },
                                    selectedColor: color,
                                    backgroundColor: isDarkMode ? const Color(0xFF132A22) : Colors.grey.shade100,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Sub-Status Options
                          ValueListenableBuilder<Map<String, dynamic>?>(
                            valueListenable: _selectedSubStatus,
                            builder: (context, selectedSubStatusVal, _) {
                              return Column(
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: (currentCategory['statuses'] as List).length,
                                    itemBuilder: (context, idx) {
                                      final item = (currentCategory['statuses'] as List)[idx] as Map<String, dynamic>;
                                      final status = item['status'] as OrderStatus;
                                      final label = item['label'] as String;
                                      final desc = item['desc'] as String;
                                      final catColor = currentCategory['color'] as Color;
                                      final isSelected = selectedSubStatusVal?['status'] == status;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: InkWell(
                                          onTap: () => _selectedSubStatus.value = item,
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isSelected ? catColor.withValues(alpha: isDarkMode ? 0.25 : 0.12) : (isDarkMode ? const Color(0xFF132A22) : Colors.grey.shade50),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: isSelected ? catColor : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300), width: isSelected ? 2.0 : 1.0),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(currentCategory['icon'] as IconData, size: 16, color: isSelected ? catColor : (isDarkMode ? Colors.white70 : Colors.grey.shade700)),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? catColor : (isDarkMode ? Colors.white : const Color(0xFF0F172A)))),
                                                      Text(desc, style: GoogleFonts.inter(fontSize: 10, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600)),
                                                    ],
                                                  ),
                                                ),
                                                if (isSelected) Icon(Icons.check_circle, color: catColor, size: 16),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Save & Close Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      onPressed: selectedSubStatusVal != null
                                          ? () {
                                              final chosenStatus = selectedSubStatusVal['status'] as OrderStatus;
                                              final chosenLabel = selectedSubStatusVal['label'] as String;

                                              Navigator.pop(context);

                                              if (chosenStatus == OrderStatus.callBack || chosenStatus == OrderStatus.deliveryRescheduled) {
                                                widget.onOpenReschedule(widget.order);
                                              } else if (chosenStatus == OrderStatus.cancelled) {
                                                widget.onOpenCancellationReason(widget.order);
                                              } else if (chosenStatus == OrderStatus.upsellPending) {
                                                widget.onShowRequestUpsell(widget.order);
                                              } else {
                                                final updated = OrderModel(
                                                  id: widget.order.id,
                                                  orderNumber: widget.order.orderNumber,
                                                  companyId: widget.order.companyId,
                                                  productId: widget.order.productId,
                                                  salesRepId: widget.currentUser.id,
                                                  customerName: widget.order.customerName,
                                                  customerPhone: widget.order.customerPhone,
                                                  deliveryState: widget.order.deliveryState,
                                                  deliveryCity: widget.order.deliveryCity,
                                                  deliveryAddress: widget.order.deliveryAddress,
                                                  status: chosenStatus,
                                                  quantity: widget.order.quantity,
                                                  basePrice: widget.order.basePrice,
                                                  upsellAmount: widget.order.upsellAmount,
                                                  downsellDiscount: widget.order.downsellDiscount,
                                                  totalAmount: widget.order.totalAmount,
                                                  upsellStatus: widget.order.upsellStatus,
                                                  upsellNotes: widget.noteController.text.isNotEmpty ? widget.noteController.text : widget.order.upsellNotes,
                                                  paymentStatus: widget.order.paymentStatus,
                                                  createdAt: widget.order.createdAt,
                                                  updatedAt: DateTime.now(),
                                                );

                                                widget.onUpdateOrder(updated);

                                                widget.onRecordActivity(
                                                  order: updated,
                                                  activityType: 'status_update',
                                                  title: 'Status updated to "$chosenLabel"',
                                                  details: widget.noteController.text.isNotEmpty ? widget.noteController.text : 'Pipeline stage updated via call outcome console.',
                                                  newStatus: chosenStatus.dbValue,
                                                );

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: const Color(0xFF059669),
                                                    behavior: SnackBarBehavior.floating,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                    margin: const EdgeInsets.all(16),
                                                    content: Row(
                                                      children: [
                                                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Text(
                                                            '✅ Outcome "$chosenLabel" saved for #${widget.order.orderNumber}!',
                                                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: selectedSubStatusVal != null ? (currentCategory['color'] as Color) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: const Icon(Icons.check_rounded, size: 16),
                                      label: Text(selectedSubStatusVal != null ? 'Save Outcome & Complete' : 'Select a status above', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
  }
}
