import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/marketing.dart';

class MarketingRepository {
  final SupabaseClient _client;

  MarketingRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetch active ad campaigns for a company
  Future<List<AdCampaignModel>> fetchCampaigns(String companyId) async {
    final response = await _client
        .from('ad_campaigns')
        .select()
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => AdCampaignModel.fromMap(json)).toList();
  }

  /// AGM Funds Marketer Account
  Future<MarketerBudgetModel> fundMarketerAccount({
    required String companyId,
    required String marketerId,
    required String agmUserId,
    required double amount,
    String? notes,
  }) async {
    final response = await _client
        .from('marketer_budgets')
        .insert({
          'company_id': companyId,
          'marketer_id': marketerId,
          'funded_by_agm_id': agmUserId,
          'amount_funded': amount,
          'current_balance': amount,
          'notes': notes,
        })
        .select()
        .single();

    return MarketerBudgetModel.fromMap(response);
  }

  /// Create Ad Campaign & Log Initial Spend
  Future<AdCampaignModel> createCampaign({
    required String companyId,
    required String marketerId,
    required String productId,
    required String campaignName,
    required String platform,
    required double initialSpend,
    String? pixelId,
  }) async {
    final response = await _client
        .from('ad_campaigns')
        .insert({
          'company_id': companyId,
          'marketer_id': marketerId,
          'product_id': productId,
          'campaign_name': campaignName,
          'platform': platform,
          'ad_spend': initialSpend,
          'pixel_id': pixelId,
        })
        .select()
        .single();

    return AdCampaignModel.fromMap(response);
  }
}
