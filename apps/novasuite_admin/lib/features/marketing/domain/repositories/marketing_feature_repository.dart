import 'package:novasuite_core/novasuite_core.dart';

abstract class MarketingFeatureRepository {
  Future<List<AdCampaignModel>> fetchCampaigns({required String companyId});
}
