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
  CallStage _stage = CallStage.connectingProvider;
  int _secondsElapsed = 0;
  Timer? _timer;
  bool _isMuted = false;
  bool _isOnHold = false;
  bool _showDtmfKeypad = false;

  final NovaSipTelephonyService _telephonyService = NovaSipTelephonyService();

  bool _showScript = true;
  bool _showNotes = false;

  String? _selectedCategory;
  Map<String, dynamic>? _selectedSubStatus;

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

  @override
  void initState() {
    super.initState();
    _startCallWorkflow();
  }

  void _startCallWorkflow() {
    _telephonySubscription = _telephonyService.callStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        switch (state) {
          case SipCallSessionState.connectingProvider:
            _stage = CallStage.connectingProvider;
            break;
          case SipCallSessionState.initiatingCall:
            _stage = CallStage.initiatingCall;
            break;
          case SipCallSessionState.callInProgress:
            _stage = CallStage.callInProgress;
            break;
          case SipCallSessionState.callEnded:
            _stage = CallStage.callEnded;
            break;
          case SipCallSessionState.disconnected:
            _stage = CallStage.disconnected;
            break;
          default:
            break;
        }
      });
    });

    _durationSubscription = _telephonyService.durationStream.listen((duration) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed = duration;
      });
    });

    _telephonyService.initiateCall(widget.order);
  }

  void _endCall() {
    _telephonyService.endCall();
    setState(() => _stage = CallStage.disconnected);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _telephonySubscription?.cancel();
    _durationSubscription?.cancel();
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

    final currentCategory = _outcomeCategories.firstWhere(
      (c) => c['id'] == (_selectedCategory ?? 'confirmed'),
      orElse: () => _outcomeCategories.first,
    );

    return Dialog(
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
                            Text(widget.order.customerName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: isDarkMode ? Colors.white : const Color(0xFF0F172A))),
                            Text('${widget.order.customerPhone} • ${widget.order.deliveryState}', style: GoogleFonts.inter(fontSize: 11, color: isDarkMode ? const Color(0xFF94A3B8) : Colors.grey.shade600)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close, color: isDarkMode ? Colors.white60 : Colors.grey),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                if (_stage != CallStage.disconnected && _stage != CallStage.callEnded) ...[
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
                                color: _stage == CallStage.callInProgress ? const Color(0xFF10B981) : Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _stage == CallStage.connectingProvider
                                  ? 'Connecting ITSKY DID Trunk...'
                                  : (_stage == CallStage.initiatingCall ? 'Ringing Customer...' : 'Call Active'),
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: isDarkMode ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                        Text(
                          _formatDuration(_secondsElapsed),
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_telephonyService.lastError != null || _stage == CallStage.disconnected) ...[
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton.filled(
                            onPressed: () => setState(() => _isMuted = !_isMuted),
                            style: IconButton.styleFrom(
                              backgroundColor: _isMuted ? Colors.red : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                              foregroundColor: _isMuted ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                              padding: const EdgeInsets.all(14),
                            ),
                            icon: Icon(_isMuted ? Icons.mic_off : Icons.mic, size: 20),
                          ),
                          const SizedBox(width: 4),
                          Text('Mute', style: GoogleFonts.inter(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton.filled(
                            onPressed: () => setState(() => _isOnHold = !_isOnHold),
                            style: IconButton.styleFrom(
                              backgroundColor: _isOnHold ? Colors.amber.shade700 : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                              foregroundColor: _isOnHold ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                              padding: const EdgeInsets.all(14),
                            ),
                            icon: Icon(_isOnHold ? Icons.pause : Icons.pause_circle_outline, size: 20),
                          ),
                          const SizedBox(width: 4),
                          Text('Hold', style: GoogleFonts.inter(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton.filled(
                            onPressed: () => setState(() => _showDtmfKeypad = !_showDtmfKeypad),
                            style: IconButton.styleFrom(
                              backgroundColor: _showDtmfKeypad ? const Color(0xFF10B981) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                              foregroundColor: _showDtmfKeypad ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                              padding: const EdgeInsets.all(14),
                            ),
                            icon: const Icon(Icons.dialpad_rounded, size: 20),
                          ),
                          const SizedBox(width: 4),
                          Text('Keypad', style: GoogleFonts.inter(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton.filled(
                            onPressed: () => setState(() {
                              _showScript = !_showScript;
                              if (_showScript) {
                                _showNotes = false;
                                _showDtmfKeypad = false;
                              }
                            }),
                            style: IconButton.styleFrom(
                              backgroundColor: _showScript ? (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23)) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                              foregroundColor: _showScript ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                              padding: const EdgeInsets.all(14),
                            ),
                            icon: const Icon(Icons.description_outlined, size: 20),
                          ),
                          const SizedBox(height: 4),
                          Text('Script', style: GoogleFonts.inter(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton.filled(
                            onPressed: () => setState(() {
                              _showNotes = !_showNotes;
                              if (_showNotes) {
                                _showScript = false;
                                _showDtmfKeypad = false;
                              }
                            }),
                            style: IconButton.styleFrom(
                              backgroundColor: _showNotes ? (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23)) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                              foregroundColor: _showNotes ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF0A2E23)),
                              padding: const EdgeInsets.all(14),
                            ),
                            icon: const Icon(Icons.note_alt_outlined, size: 20),
                          ),
                          const SizedBox(height: 4),
                          Text('Notes', style: GoogleFonts.inter(color: isDarkMode ? Colors.white60 : Colors.grey.shade700, fontSize: 10.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_showScript) ...[
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
                  ] else if (_showNotes) ...[
                    TextField(
                      controller: widget.noteController,
                      maxLines: 3,
                      style: GoogleFonts.inter(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Enter call outcome notes or customer feedback...',
                        hintStyle: GoogleFonts.inter(fontSize: 11),
                        filled: true,
                        fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300)),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

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
                      label: Text('End Call & Log Outcome', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ] else ...[
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
                        final isSelected = _selectedCategory == cat['id'];
                        final color = cat['color'] as Color;

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat['title'] as String, style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.black87))),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat['id'] as String;
                                  _selectedSubStatus = null;
                                });
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
                      final isSelected = _selectedSubStatus?['status'] == status;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => setState(() => _selectedSubStatus = item),
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

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _selectedSubStatus != null
                          ? () {
                              final chosenStatus = _selectedSubStatus!['status'] as OrderStatus;
                              final chosenLabel = _selectedSubStatus!['label'] as String;

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
                        backgroundColor: _selectedSubStatus != null ? (currentCategory['color'] as Color) : (isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade300),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(_selectedSubStatus != null ? 'Save Outcome & Complete' : 'Select a status above', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
