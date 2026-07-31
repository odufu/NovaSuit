import 'package:novasuite_core/novasuite_core.dart';
import '../repositories/logistics_feature_repository.dart';

class FetchInventoryUseCase {
  final LogisticsFeatureRepository repository;

  FetchInventoryUseCase(this.repository);

  Future<List<WarehouseModel>> execute({required String companyId}) {
    return repository.fetchWarehouses(companyId: companyId);
  }
}
