import 'package:novasuite_core/novasuite_core.dart';

abstract class MarketingRemoteDataSource {
  Future<List<AdCampaignModel>> fetchCampaigns({required String companyId});
}

class MarketingRemoteDataSourceImpl implements MarketingRemoteDataSource {
  final MarketingRepository _coreRepo = MarketingRepository();

  @override
  Future<List<AdCampaignModel>> fetchCampaigns({required String companyId}) {
    return _coreRepo.fetchCampaigns(companyId);
  }
}
