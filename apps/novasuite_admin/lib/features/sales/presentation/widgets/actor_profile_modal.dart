import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ActorType {
  digitalMarketer('digital_marketer', 'Digital Marketer', Icons.campaign_rounded, Colors.purple),
  salesRep('sales_rep', 'Sales Call Rep', Icons.headset_mic_rounded, Colors.blue),
  supervisor('supervisor', 'Sales Supervisor', Icons.supervisor_account_rounded, Colors.amber),
  customer('customer', 'Customer Profile', Icons.person_rounded, Color(0xFF10B981));

  final String id;
  final String label;
  final IconData icon;
  final Color color;
  const ActorType(this.id, this.label, this.icon, this.color);
}

class ActorProfileModal extends StatelessWidget {
  final ActorType actorType;
  final String name;
  final String email;
  final String phone;
  final String? secondaryInfo;
  final String? tertiaryInfo;
  final List<Map<String, String>> stats;
  final List<String> assignedProducts;

  const ActorProfileModal({
    super.key,
    required this.actorType,
    required this.name,
    required this.email,
    required this.phone,
    this.secondaryInfo,
    this.tertiaryInfo,
    required this.stats,
    this.assignedProducts = const [],
  });

  static void show(
    BuildContext context, {
    required ActorType actorType,
    required String name,
    required String email,
    required String phone,
    String? secondaryInfo,
    String? tertiaryInfo,
    required List<Map<String, String>> stats,
    List<String> assignedProducts = const [],
  }) {
    showDialog(
      context: context,
      builder: (ctx) => ActorProfileModal(
        actorType: actorType,
        name: name,
        email: email,
        phone: phone,
        secondaryInfo: secondaryInfo,
        tertiaryInfo: tertiaryInfo,
        stats: stats,
        assignedProducts: assignedProducts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    actorType.color.withOpacity(0.2),
                    isDarkMode ? const Color(0xFF0A1E17) : Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: actorType.color.withOpacity(0.2),
                    child: Icon(actorType.icon, color: actorType.color, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: actorType.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: actorType.color.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(actorType.icon, color: actorType.color, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                actorType.label.toUpperCase(),
                                style: TextStyle(
                                  color: actorType.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (secondaryInfo != null)
                          Text(
                            secondaryInfo!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                            ),
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

            // Content Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Contact Info Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  email,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF10B981)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  phone,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PSTN Active',
                                  style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          if (tertiaryInfo != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 16, color: Color(0xFF10B981)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tertiaryInfo!,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Metrics & Key Stats Grid
                    Text(
                      'PERFORMANCE & WORKLOAD METRICS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: stats.length,
                      itemBuilder: (context, index) {
                        final st = stats[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF132A22) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDarkMode ? const Color(0xFF1E3E33) : Colors.grey.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                st['label'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                st['value'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    if (assignedProducts.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        'ASSIGNED PRODUCTS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: assignedProducts.map((p) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1E3E33) : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 12, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text(
                                  p,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Close Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
