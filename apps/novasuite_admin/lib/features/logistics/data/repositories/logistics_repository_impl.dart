import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/repositories/logistics_feature_repository.dart';
import '../datasources/logistics_remote_datasource.dart';

class LogisticsRepositoryImpl implements LogisticsFeatureRepository {
  final LogisticsRemoteDataSource remoteDataSource;

  LogisticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<WarehouseModel>> fetchWarehouses({required String companyId}) {
    return remoteDataSource.fetchWarehouses(companyId: companyId);
  }
}
