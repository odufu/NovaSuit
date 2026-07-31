import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/repositories/marketing_feature_repository.dart';
import '../datasources/marketing_remote_datasource.dart';

class MarketingRepositoryImpl implements MarketingFeatureRepository {
  final MarketingRemoteDataSource remoteDataSource;

  MarketingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AdCampaignModel>> fetchCampaigns({required String companyId}) {
    return remoteDataSource.fetchCampaigns(companyId: companyId);
  }
}
