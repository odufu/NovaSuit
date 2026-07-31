import 'package:novasuite_core/novasuite_core.dart';

abstract class LogisticsFeatureRepository {
  Future<List<WarehouseModel>> fetchWarehouses({required String companyId});
}
