import 'package:get_it/get_it.dart';

// Auth Feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_feature_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Sales Feature
import '../../features/sales/data/datasources/sales_remote_datasource.dart';
import '../../features/sales/data/repositories/sales_repository_impl.dart';
import '../../features/sales/domain/repositories/sales_repository.dart';
import '../../features/sales/domain/usecases/fetch_orders_usecase.dart';
import '../../features/sales/domain/usecases/update_order_status_usecase.dart';
import '../../features/sales/presentation/providers/sales_provider.dart';

// Logistics Feature
import '../../features/logistics/data/datasources/logistics_remote_datasource.dart';
import '../../features/logistics/data/repositories/logistics_repository_impl.dart';
import '../../features/logistics/domain/repositories/logistics_feature_repository.dart';
import '../../features/logistics/domain/usecases/fetch_inventory_usecase.dart';
import '../../features/logistics/presentation/providers/logistics_provider.dart';

// Marketing Feature
import '../../features/marketing/data/datasources/marketing_remote_datasource.dart';
import '../../features/marketing/data/repositories/marketing_repository_impl.dart';
import '../../features/marketing/domain/repositories/marketing_feature_repository.dart';
import '../../features/marketing/domain/usecases/fetch_campaigns_usecase.dart';
import '../../features/marketing/presentation/providers/marketing_provider.dart';

import '../providers/theme_provider.dart';

final sl = GetIt.instance;

Future<void> initDi() async {
  // Core Providers
  sl.registerLazySingleton(() => ThemeProvider());
  // ==========================================
  // AUTH FEATURE DI REGISTRATION
  // ==========================================
  // Providers
  sl.registerFactory(() => AuthProvider(
        loginUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthFeatureRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // ==========================================
  // SALES FEATURE DI REGISTRATION
  // ==========================================
  // Providers
  sl.registerFactory(() => SalesProvider(
        fetchOrdersUseCase: sl(),
        updateOrderStatusUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => FetchOrdersUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<SalesRemoteDataSource>(
    () => SalesRemoteDataSourceImpl(),
  );

  // ==========================================
  // LOGISTICS FEATURE DI REGISTRATION
  // ==========================================
  // Providers
  sl.registerFactory(() => LogisticsProvider(
        fetchInventoryUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => FetchInventoryUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<LogisticsFeatureRepository>(
    () => LogisticsRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<LogisticsRemoteDataSource>(
    () => LogisticsRemoteDataSourceImpl(),
  );

  // ==========================================
  // MARKETING FEATURE DI REGISTRATION
  // ==========================================
  // Providers
  sl.registerFactory(() => MarketingProvider(
        fetchCampaignsUseCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton(() => FetchCampaignsUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<MarketingFeatureRepository>(
    () => MarketingRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<MarketingRemoteDataSource>(
    () => MarketingRemoteDataSourceImpl(),
  );
}
