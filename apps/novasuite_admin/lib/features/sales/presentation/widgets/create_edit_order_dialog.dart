import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';

class CreateEditOrderDialog extends StatefulWidget {
  final OrderModel? existingOrder;
  final UserModel currentUser;
  final Function(OrderModel order) onSaved;

  const CreateEditOrderDialog({
    super.key,
    this.existingOrder,
    required this.currentUser,
    required this.onSaved,
  });

  static void show(
    BuildContext context, {
    OrderModel? existingOrder,
    required UserModel currentUser,
    required Function(OrderModel order) onSaved,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CreateEditOrderDialog(
        existingOrder: existingOrder,
        currentUser: currentUser,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<CreateEditOrderDialog> createState() => _CreateEditOrderDialogState();
}

class _CreateEditOrderDialogState extends State<CreateEditOrderDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _altPhoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;

  String _selectedState = 'Lagos';
  String _selectedProduct = 'Grazer Herbal Detox Tea';
  int _quantity = 1;
  double _baseUnitPrice = 25000;
  String? _selectedSalesRepId;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _products = [
    {'name': 'Grazer Herbal Detox Tea', 'price': 25000.0},
    {'name': 'Herbal Vitality Booster', 'price': 35000.0},
    {'name': 'Clear Skin Care Set', 'price': 18500.0},
  ];

  final List<String> _states = [
    'Lagos', 'Abuja', 'Rivers', 'Oyo', 'Kano', 'Enugu', 'Delta', 'Anambra', 'Ogun', 'Kaduna'
  ];

  final List<Map<String, String>> _teamReps = [
    {'id': 'auto', 'name': '⚡ Auto Load-Balanced Assignment'},
    {'id': '30000000-0000-4000-8000-000000000003', 'name': 'John CallRep (John Doe)'},
    {'id': '40000000-0000-4000-8000-000000000004', 'name': 'Sarah CallRep (Sarah Connor)'},
    {'id': '50000000-0000-4000-8000-000000000006', 'name': 'Emeka CallRep (Emeka Nnamdi)'},
    {'id': '50000000-0000-4000-8000-000000000007', 'name': 'Aisha SalesRep (Aisha Bello)'},
  ];

  @override
  void initState() {
    super.initState();
    final o = widget.existingOrder;
    _nameController = TextEditingController(text: o?.customerName ?? '');
    _phoneController = TextEditingController(text: o?.customerPhone ?? '');
    _altPhoneController = TextEditingController(text: o?.customerAltPhone ?? '');
    _addressController = TextEditingController(text: o?.deliveryAddress ?? '');
    _cityController = TextEditingController(text: o?.deliveryCity ?? 'Ikeja');

    if (o != null) {
      _selectedState = o.deliveryState.isNotEmpty ? o.deliveryState : 'Lagos';
      _selectedProduct = o.productId;
      _quantity = o.quantity;
      _baseUnitPrice = o.basePrice;
      _selectedSalesRepId = o.salesRepId;
    } else {
      _selectedSalesRepId = widget.currentUser.role == UserRole.salesCallRep ? widget.currentUser.id : 'auto';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _onProductChanged(String? val) {
    if (val == null) return;
    setState(() {
      _selectedProduct = val;
      final match = _products.firstWhere((p) => p['name'] == val, orElse: () => _products.first);
      _baseUnitPrice = match['price'];
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      String? assignedRep = _selectedSalesRepId;
      if (assignedRep == 'auto' || assignedRep == null || assignedRep.isEmpty) {
        assignedRep = await OrderRepository().findOptimalSalesRep(
          companyId: widget.currentUser.companyId,
          productId: _selectedProduct,
          supervisorId: widget.currentUser.role == UserRole.supervisor ? widget.currentUser.id : widget.currentUser.supervisorId,
        );
      }

      final total = _baseUnitPrice * _quantity;

      final isEdit = widget.existingOrder != null;
      final orderToSave = widget.existingOrder?.copyWith(
            customerName: _nameController.text.trim(),
            customerPhone: _phoneController.text.trim(),
            customerAltPhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : null,
            productId: _selectedProduct,
            quantity: _quantity,
            basePrice: _baseUnitPrice,
            totalAmount: total,
            deliveryState: _selectedState,
            deliveryCity: _cityController.text.trim(),
            deliveryAddress: _addressController.text.trim(),
            salesRepId: assignedRep,
            marketerId: isEdit ? widget.existingOrder!.marketerId : (widget.currentUser.role == UserRole.digitalMarketer ? widget.currentUser.id : null),
            updatedAt: DateTime.now(),
          ) ??
          OrderModel(
            id: 'ord-${DateTime.now().millisecondsSinceEpoch}',
            orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
            companyId: widget.currentUser.companyId,
            productId: _selectedProduct,
            salesRepId: assignedRep,
            marketerId: widget.currentUser.role == UserRole.digitalMarketer ? widget.currentUser.id : null,
            customerName: _nameController.text.trim(),
            customerPhone: _phoneController.text.trim(),
            customerAltPhone: _altPhoneController.text.trim().isNotEmpty ? _altPhoneController.text.trim() : null,
            deliveryState: _selectedState,
            deliveryCity: _cityController.text.trim(),
            deliveryAddress: _addressController.text.trim(),
            status: OrderStatus.newOrder,
            quantity: _quantity,
            basePrice: _baseUnitPrice,
            upsellAmount: 0.0,
            downsellDiscount: 0.0,
            totalAmount: total,
            upsellStatus: UpsellStatus.none,
            paymentStatus: 'pending',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      if (isEdit) {
        await OrderRepository().updateOrder(orderToSave);
      } else {
        await OrderRepository().createOrder(orderToSave);
      }

      widget.onSaved(orderToSave);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingOrder != null;
    final isSupervisorOrAdmin = widget.currentUser.role == UserRole.supervisor ||
        widget.currentUser.role == UserRole.hod ||
        widget.currentUser.role == UserRole.superAdmin;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 560,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_note_rounded : Icons.add_shopping_cart_rounded,
                    color: const Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Order #${widget.existingOrder!.orderNumber}' : 'Create New Customer Order',
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
                        ),
                        Text(
                          'Created as ${widget.currentUser.role.label} (${widget.currentUser.fullName})',
                          style: TextStyle(fontSize: 11.5, color: isDarkMode ? Colors.white60 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white60 : Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

            // Form Fields
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Selection
                      Text('PRODUCT SELECTION', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, letterSpacing: 0.5)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProduct,
                        dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                        style: GoogleFonts.inter(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 13),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        items: _products.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['name'],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(p['name']),
                                Text(' ₦${(p['price'] as double).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _onProductChanged,
                      ),

                      const SizedBox(height: 16),

                      // Quantity & Pricing Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('QUANTITY', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      ),
                                      Text('$_quantity', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)),
                                      IconButton(
                                        onPressed: () => setState(() => _quantity++),
                                        icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF10B981)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL AMOUNT (COD)', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    '₦${(_baseUnitPrice * _quantity).toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Customer Details
                      Text('CUSTOMER INFORMATION', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, letterSpacing: 0.5)),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _nameController,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Customer Full Name',
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter customer name' : null,
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                filled: true,
                                fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              validator: (val) => val == null || val.length < 10 ? 'Enter valid phone' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _altPhoneController,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Alt Phone (Optional)',
                                prefixIcon: const Icon(Icons.phone_android_outlined, size: 20),
                                filled: true,
                                fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Delivery Address
                      Text('DELIVERY LOCATION', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white60 : Colors.grey.shade600, letterSpacing: 0.5)),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedState,
                              dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'State',
                                filled: true,
                                fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                              items: _states.map((st) => DropdownMenuItem(value: st, child: Text(st))).toList(),
                              onChanged: (v) => setState(() => _selectedState = v ?? 'Lagos'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                              decoration: InputDecoration(
                                labelText: 'City / Area',
                                filled: true,
                                fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          labelText: 'Full Street Delivery Address',
                          prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                          filled: true,
                          fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Enter delivery address' : null,
                      ),

                      if (isSupervisorOrAdmin) ...[
                        const SizedBox(height: 18),
                        Text('SUPERVISOR SALES REP MATCHING & REASSIGNMENT', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.amber, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSalesRepId,
                          dropdownColor: isDarkMode ? const Color(0xFF132A22) : Colors.white,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                          items: _teamReps.map((r) => DropdownMenuItem(value: r['id'], child: Text(r['name']!))).toList(),
                          onChanged: (v) => setState(() => _selectedSalesRepId = v),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Submit Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? 'Save Changes' : 'Create & Assign Order', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
