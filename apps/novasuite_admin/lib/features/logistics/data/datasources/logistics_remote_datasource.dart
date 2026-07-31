import 'package:novasuite_core/novasuite_core.dart';

abstract class LogisticsRemoteDataSource {
  Future<List<WarehouseModel>> fetchWarehouses({required String companyId});
}

class LogisticsRemoteDataSourceImpl implements LogisticsRemoteDataSource {
  final InventoryRepository _inventoryRepo = InventoryRepository();

  @override
  Future<List<WarehouseModel>> fetchWarehouses({required String companyId}) {
    return _inventoryRepo.fetchWarehouses(companyId);
  }
}
