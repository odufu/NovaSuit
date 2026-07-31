import 'package:novasuite_core/novasuite_core.dart';
import '../repositories/marketing_feature_repository.dart';

class FetchCampaignsUseCase {
  final MarketingFeatureRepository repository;

  FetchCampaignsUseCase(this.repository);

  Future<List<AdCampaignModel>> execute({required String companyId}) {
    return repository.fetchCampaigns(companyId: companyId);
  }
}
