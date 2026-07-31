import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/remittance.dart';

class RemittanceRepository {
  final SupabaseClient _client;

  RemittanceRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Upload Bank Deposit Receipt for Rider COD Remittance
  Future<CashRemittanceModel> submitRemittanceReceipt({
    required String companyId,
    required String deliveryAgentId,
    required double amount,
    required String depositReceiptUrl,
    String? notes,
  }) async {
    final response = await _client
        .from('cash_remittances')
        .insert({
          'company_id': companyId,
          'delivery_agent_id': deliveryAgentId,
          'amount': amount,
          'deposit_receipt_url': depositReceiptUrl,
          'status': 'pending',
          'notes': notes,
        })
        .select()
        .single();

    return CashRemittanceModel.fromMap(response);
  }

  /// Fetch pending COD remittances for Finance Manager review
  Future<List<CashRemittanceModel>> fetchPendingRemittances(String companyId) async {
    final response = await _client
        .from('cash_remittances')
        .select()
        .eq('company_id', companyId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (response as List).map((json) => CashRemittanceModel.fromMap(json)).toList();
  }

  /// Finance Manager verifies remittance & decrements rider's COD balance
  Future<CashRemittanceModel> verifyRemittance({
    required String remittanceId,
    required String financeUserId,
    required String deliveryAgentId,
    required double remittedAmount,
  }) async {
    // 1. Mark Remittance Verified
    final response = await _client
        .from('cash_remittances')
        .update({
          'status': 'verified',
          'verified_by_finance_user_id': financeUserId,
          'verified_at': DateTime.now().toIso8601String(),
        })
        .eq('id', remittanceId)
        .select()
        .single();

    // 2. Decrement Rider COD Balance
    final agentResponse = await _client
        .from('delivery_agents')
        .select('current_cod_balance')
        .eq('id', deliveryAgentId)
        .single();

    final currentBalance = (agentResponse['current_cod_balance'] as num?)?.toDouble() ?? 0.0;
    final newBalance = (currentBalance - remittedAmount).clamp(0.0, double.infinity);

    await _client.from('delivery_agents').update({
      'current_cod_balance': newBalance,
    }).eq('id', deliveryAgentId);

    return CashRemittanceModel.fromMap(response);
  }
}
