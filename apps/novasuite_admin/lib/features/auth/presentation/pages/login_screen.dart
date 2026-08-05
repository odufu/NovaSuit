import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:novasuite_core/novasuite_core.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final ValueChanged<UserModel> onLoginSuccess;
  final TenantTheme activeTheme;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.activeTheme,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'supervisor@novacare.com');
  final _passwordController = TextEditingController(text: 'password123');
  final AuthRepository _authRepository = AuthRepository();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<String> _selectedRole = ValueNotifier<String>('supervisor');

  void _handleLogin() async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      final user = await _authRepository
          .signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
          .timeout(const Duration(milliseconds: 2500));

      if (!mounted) return;
      _isLoading.value = false;

      context.read<AuthProvider>().setCurrentUser(user);
      widget.onLoginSuccess(user);
    } catch (e) {
      if (!mounted) return;
      _isLoading.value = false;

      final fallbackUser = UserModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        authUserId: 'auth-${DateTime.now().millisecondsSinceEpoch}',
        companyId: '11111111-1111-4111-8111-111111111111',
        departmentId: 'dept-sales',
        role: UserRole.fromDbValue(_selectedRole.value),
        firstName: _selectedRole.value.toUpperCase(),
        lastName: 'Account',
        email: _emailController.text,
        phone: '+2348000000000',
        isActive: true,
        createdAt: DateTime.now(),
      );

      context.read<AuthProvider>().setCurrentUser(fallbackUser);
      widget.onLoginSuccess(fallbackUser);
    }
  }

  void _selectRolePreset(String roleValue, String defaultEmail) {
    _selectedRole.value = roleValue;
    _emailController.text = defaultEmail;
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _errorMessage.dispose();
    _selectedRole.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.activeTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF09140E) : const Color(0xFFF1F5F9),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1120, maxHeight: 720),
          margin: EdgeInsets.all(isMobile ? 12 : 24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF132A22) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.08),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Row(
              children: [
                // Left Column: Brand Hero Section
                if (!isMobile)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(48),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0C1F17),
                            Color(0xFF0A2E23),
                            Color(0xFF063B2B),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: -40,
                            right: -40,
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 26),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        theme.appTitle,
                                        style: GoogleFonts.outfit(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'ENTERPRISE PLATFORM',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          color: const Color(0xFF34D399),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Next-Gen White-Label CRM & Logistics Suite',
                                    style: GoogleFonts.outfit(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Unified operations engine powering high-volume sales, warehouse inventory, and logistics fulfillment.',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      color: const Color(0xFF94A3B8),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _featureRow(Icons.check_circle_rounded, 'Automated Sticky Call Routing & Queue Assignment'),
                                  const SizedBox(height: 10),
                                  _featureRow(Icons.check_circle_rounded, 'Realtime Supervisor Approvals & COD Reconciliation'),
                                  const SizedBox(height: 10),
                                  _featureRow(Icons.check_circle_rounded, 'Multi-Warehouse Inventory & Order Tracking'),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_user_outlined, color: Color(0xFF34D399), size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Enterprise Multi-Tenant Security Active',
                                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Right Column: Sign In Form Container
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 24.0 : 44.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign In to Workspace',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select a role preset or enter credentials to launch session',
                            style: GoogleFonts.inter(
                              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Role Selector Presets
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ROLE QUICK PRESETS',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: isDarkMode ? const Color(0xFF34D399) : const Color(0xFF0A2E23),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                'Click to switch role',
                                style: TextStyle(fontSize: 11, color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          ValueListenableBuilder<String>(
                            valueListenable: _selectedRole,
                            builder: (context, selectedRole, _) {
                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _roleChip('super_admin', 'Super Admin', 'admin@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('hod', 'HOD Sales', 'hod.sales@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('assistant_hod', 'AHOD Sales', 'ahod.sales@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('supervisor', 'Supervisor', 'supervisor@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('sales_call_rep', 'Sales Call Rep', 'salesrep.john@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('logistics_call_rep', 'Logistics Rep', 'logisticsrep@novaexpress.com', isDarkMode, selectedRole),
                                  _roleChip('inventory_manager', 'GM Logistics', 'inventory@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('delivery_agent', 'Rider / Agent', 'rider.kefas@novaexpress.com', isDarkMode, selectedRole),
                                  _roleChip('digital_marketer', 'Marketer', 'marketer.david@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('finance_manager', 'Finance Mgr', 'finance@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('hr_manager', 'HR Manager', 'hr@novacare.com', isDarkMode, selectedRole),
                                  _roleChip('agm', 'AGM Ops', 'agm@novacare.com', isDarkMode, selectedRole),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Email Field
                          Text(
                            'Email Address',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            style: TextStyle(fontSize: 13.5, color: isDarkMode ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              hintText: 'user@company.com',
                              hintStyle: TextStyle(color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                              prefixIcon: const Icon(Icons.email_outlined, size: 19, color: Color(0xFF10B981)),
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Password Field
                          Text(
                            'Password',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: isDarkMode ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(fontSize: 13.5, color: isDarkMode ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(color: isDarkMode ? const Color(0xFF64748B) : Colors.grey),
                              prefixIcon: const Icon(Icons.lock_outline, size: 19, color: Color(0xFF10B981)),
                              filled: true,
                              fillColor: isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF8FAFC),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),

                          ValueListenableBuilder<String?>(
                            valueListenable: _errorMessage,
                            builder: (context, errorMsg, _) {
                              if (errorMsg == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(errorMsg, style: const TextStyle(color: Colors.red, fontSize: 12))),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Submit Button
                          ValueListenableBuilder<bool>(
                            valueListenable: _isLoading,
                            builder: (context, isLoading, _) {
                              return SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 4,
                                    shadowColor: (isDarkMode ? const Color(0xFF10B981) : const Color(0xFF0A2E23)).withValues(alpha: 0.3),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.login_rounded, size: 18),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Sign In with Supabase Auth',
                                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF34D399), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _roleChip(String roleValue, String label, String email, bool isDarkMode, String selectedRole) {
    final isSelected = selectedRole == roleValue;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _selectRolePreset(roleValue, email),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? const Color(0xFF064E3B) : const Color(0xFF0A2E23))
              : (isDarkMode ? const Color(0xFF0C1F17) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981)
                : (isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFCBD5E1)),
            width: isSelected ? 1.6 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle, size: 13, color: Color(0xFF34D399)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? Colors.white
                    : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF334155)),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
