import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../widgets/actor_profile_modal.dart';
import '../widgets/create_edit_order_dialog.dart';

class SingleOrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  final UserModel currentUser;
  final Function(OrderModel updated) onUpdateOrder;

  const SingleOrderDetailScreen({
    super.key,
    required this.order,
    required this.currentUser,
    required this.onUpdateOrder,
  });

  static void show(
    BuildContext context, {
    required OrderModel order,
    required UserModel currentUser,
    required Function(OrderModel updated) onUpdateOrder,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => SingleOrderDetailScreen(
          order: order,
          currentUser: currentUser,
          onUpdateOrder: onUpdateOrder,
        ),
      ),
    );
  }

  @override
  State<SingleOrderDetailScreen> createState() => _SingleOrderDetailScreenState();
}

class _SingleOrderDetailScreenState extends State<SingleOrderDetailScreen> {
  late OrderModel _currentOrder;
  List<OrderActivityModel> _activities = [];
  bool _isLoadingActivities = true;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final list = await OrderRepository().fetchOrderActivities(_currentOrder.id);
    if (mounted) {
      setState(() {
        _activities = list;
        _isLoadingActivities = false;
      });
    }
  }

  void _openEditDialog() {
    CreateEditOrderDialog.show(
      context,
      existingOrder: _currentOrder,
      currentUser: widget.currentUser,
      onSaved: (updated) {
        setState(() {
          _currentOrder = updated;
        });
        widget.onUpdateOrder(updated);
        _loadActivities();
      },
    );
  }

  void _showReassignDialog() {
    final reps = [
      {'id': '30000000-0000-4000-8000-000000000003', 'name': 'John CallRep (John Doe)'},
      {'id': '40000000-0000-4000-8000-000000000004', 'name': 'Sarah CallRep (Sarah Connor)'},
      {'id': '50000000-0000-4000-8000-000000000006', 'name': 'Emeka CallRep (Emeka Nnamdi)'},
      {'id': '50000000-0000-4000-8000-000000000007', 'name': 'Aisha SalesRep (Aisha Bello)'},
    ];

    String selectedId = reps.first['id']!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reassign Order #${_currentOrder.orderNumber}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select target Sales Representative for reassignment:'),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (ctx, setLocalState) {
                return DropdownButtonFormField<String>(
                  initialValue: selectedId,
                  items: reps.map((r) => DropdownMenuItem(value: r['id'], child: Text(r['name']!))).toList(),
                  onChanged: (val) => setLocalState(() => selectedId = val ?? selectedId),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await OrderRepository().reassignOrder(
                orderId: _currentOrder.id,
                newSalesRepId: selectedId,
                reassignedByUserId: widget.currentUser.id,
              );
              setState(() {
                _currentOrder = _currentOrder.copyWith(salesRepId: selectedId, status: OrderStatus.assignedToRep);
              });
              widget.onUpdateOrder(_currentOrder);
              _loadActivities();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            child: const Text('Confirm Reassign'),
          ),
        ],
      ),
    );
  }

  void _openMarketerProfile() {
    ActorProfileModal.show(
      context,
      actorType: ActorType.digitalMarketer,
      name: 'Funke Akindele (Marketer)',
      email: 'marketer.funke@novacare.com',
      phone: '08021112233',
      secondaryInfo: 'Digital Marketing Campaign Lead • Meta Ads',
      tertiaryInfo: 'Pixel ID: FB-PIXEL-984210',
      stats: [
        {'label': 'Total Ad Spend', 'value': '₦450,000'},
        {'label': 'Leads Generated', 'value': '1,280'},
        {'label': 'Cost per Lead', 'value': '₦351.50'},
        {'label': 'ROAS Multiplier', 'value': '4.8x'},
      ],
      assignedProducts: ['Grazer Herbal Detox Tea', 'Herbal Vitality Booster'],
    );
  }

  void _openSalesRepProfile() {
    ActorProfileModal.show(
      context,
      actorType: ActorType.salesRep,
      name: 'John CallRep (John Doe)',
      email: 'salesrep.john@novacare.com',
      phone: '07003100077',
      secondaryInfo: 'Senior Sales Conversion Agent • Lagos Hub',
      tertiaryInfo: 'Supervisor: Dr. Folake Adeleke',
      stats: [
        {'label': 'Active Lead Load', 'value': '14 Orders'},
        {'label': 'Confirmation Rate', 'value': '84.2%'},
        {'label': 'Monthly Revenue', 'value': '₦4.8M'},
        {'label': 'Avg Handle Time', 'value': '03m 42s'},
      ],
      assignedProducts: ['Grazer Herbal Detox Tea', 'Herbal Vitality Booster', 'Clear Skin Care Set'],
    );
  }

  void _openSupervisorProfile() {
    ActorProfileModal.show(
      context,
      actorType: ActorType.supervisor,
      name: 'Dr. Folake Adeleke',
      email: 'supervisor.folake@novacare.com',
      phone: '08165119466',
      secondaryInfo: 'Sales Call Operations Supervisor • West Region',
      stats: [
        {'label': 'Managed Team Size', 'value': '8 Reps'},
        {'label': 'Total Pipeline', 'value': '₦18.4M'},
        {'label': 'Team Confirmation', 'value': '79.5%'},
        {'label': 'Pending Approvals', 'value': '3 Orders'},
      ],
      assignedProducts: ['All Assigned Company Products'],
    );
  }

  void _openCustomerProfile() {
    ActorProfileModal.show(
      context,
      actorType: ActorType.customer,
      name: _currentOrder.customerName,
      email: '${_currentOrder.customerPhone.replaceAll(RegExp(r'\D'), '')}@client.novasuite.com',
      phone: _currentOrder.customerPhone,
      secondaryInfo: '${_currentOrder.deliveryCity ?? 'Ikeja'}, ${_currentOrder.deliveryState}',
      tertiaryInfo: _currentOrder.deliveryAddress,
      stats: [
        {'label': 'Lifetime Orders', 'value': '3 Placed'},
        {'label': 'Payment Preference', 'value': 'Pay-on-Delivery COD'},
        {'label': 'Total Value', 'value': '₦${_currentOrder.totalAmount.toStringAsFixed(0)}'},
        {'label': 'Delivery Status', 'value': _currentOrder.status.label},
      ],
      assignedProducts: [_currentOrder.productId],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSupervisorOrAdmin = widget.currentUser.role == UserRole.supervisor ||
        widget.currentUser.role == UserRole.hod ||
        widget.currentUser.role == UserRole.superAdmin;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF06140F) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order #${_currentOrder.orderNumber}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: isDarkMode ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _currentOrder.status.label.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Text(
              'Created ${DateTime.now().difference(_currentOrder.createdAt).inDays} days ago',
              style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white60 : Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openEditDialog,
            tooltip: 'Edit Order',
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF10B981)),
          ),
          if (isSupervisorOrAdmin)
            IconButton(
              onPressed: _showReassignDialog,
              tooltip: 'Reassign Sales Rep',
              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.amber),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Financial & Order Summary Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_mall_outlined, color: Color(0xFF10B981), size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentOrder.productId,
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
                        ),
                        Text(
                          'Quantity: ${_currentOrder.quantity} Unit(s) • Base Price: ₦${_currentOrder.basePrice.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 12.5, color: isDarkMode ? Colors.white60 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('TOTAL COD VALUE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600)),
                      Text(
                        '₦${_currentOrder.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tappable Actors Grid (Customer, Marketer, Sales Rep, Supervisor)
            Text(
              'ACTORS & ATTRIBUTION PROFILES (TAP TO VIEW)',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: isWide ? 4 : 2,
                  childAspectRatio: isWide ? 1.6 : 1.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildActorCard(
                      context,
                      title: 'Customer',
                      subtitle: _currentOrder.customerName,
                      detail: _currentOrder.customerPhone,
                      icon: Icons.person_rounded,
                      color: const Color(0xFF10B981),
                      onTap: _openCustomerProfile,
                    ),
                    _buildActorCard(
                      context,
                      title: 'Digital Marketer',
                      subtitle: 'Funke Marketer',
                      detail: 'Meta Ads Campaign',
                      icon: Icons.campaign_rounded,
                      color: Colors.purple,
                      onTap: _openMarketerProfile,
                    ),
                    _buildActorCard(
                      context,
                      title: 'Sales Call Rep',
                      subtitle: 'John CallRep',
                      detail: 'Lagos Call Hub',
                      icon: Icons.headset_mic_rounded,
                      color: Colors.blue,
                      onTap: _openSalesRepProfile,
                    ),
                    _buildActorCard(
                      context,
                      title: 'Supervisor',
                      subtitle: 'Dr. Folake Adeleke',
                      detail: 'West Region Lead',
                      icon: Icons.supervisor_account_rounded,
                      color: Colors.amber,
                      onTap: _openSupervisorProfile,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // Linked Omnichannel Conversations & Call Logs Timeline
            Text(
              'LINKED CALL LOGS & TELEPHONY TIMELINE',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildCallLogItem(
                    isDarkMode,
                    icon: Icons.phone_callback_rounded,
                    color: Colors.blue,
                    title: 'Inbound PSTN Call Answered',
                    subtitle: 'Duration: 02m 45s • OpenSIPS SIP Trunk Gateway',
                    time: '10 Mins Ago',
                  ),
                  const Divider(height: 16),
                  _buildCallLogItem(
                    isDarkMode,
                    icon: Icons.phone_missed_rounded,
                    color: Colors.orange,
                    title: 'Missed Call Ringing Alert',
                    subtitle: 'Caller: ${_currentOrder.customerPhone} • Missed by Rep',
                    time: '2 Hours Ago',
                  ),
                  const Divider(height: 16),
                  _buildCallLogItem(
                    isDarkMode,
                    icon: Icons.mic_rounded,
                    color: const Color(0xFF10B981),
                    title: '2-Way Call WAV Recording Saved',
                    subtitle: 'REC_1785855806555.wav • Audio Stream Active',
                    time: '1 Day Ago',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Chronological Order Audit Activity
            Text(
              'ORDER AUDIT & ACTIVITY TIMELINE',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, letterSpacing: 0.5),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
              ),
              child: _isLoadingActivities
                  ? const Center(child: CircularProgressIndicator())
                  : _activities.isEmpty
                      ? Column(
                          children: [
                            _buildAuditItem(isDarkMode, 'Order Created', 'Order created and assigned to sales rep.', DateTime.now().subtract(const Duration(hours: 1))),
                            _buildAuditItem(isDarkMode, 'Status Updated', 'Status set to "${_currentOrder.status.label}"', DateTime.now()),
                          ],
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _activities.length,
                          separatorBuilder: (ctx, i) => const Divider(height: 16),
                          itemBuilder: (ctx, i) {
                            final act = _activities[i];
                            return _buildAuditItem(isDarkMode, act.title, act.details, act.createdAt);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActorCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String detail,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title.toUpperCase(), style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(detail, style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white60 : Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: isDarkMode ? Colors.white38 : Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildCallLogItem(bool isDarkMode, {required IconData icon, required Color color, required String title, required String subtitle, required String time}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white60 : Colors.grey.shade600)),
            ],
          ),
        ),
        Text(time, style: TextStyle(fontSize: 10.5, color: isDarkMode ? Colors.white38 : Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildAuditItem(bool isDarkMode, String title, String details, DateTime time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF10B981)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
              Text(details, style: TextStyle(fontSize: 11, color: isDarkMode ? Colors.white60 : Colors.grey.shade600)),
            ],
          ),
        ),
        Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white38 : Colors.grey.shade500)),
      ],
    );
  }
}
