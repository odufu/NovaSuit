import 'package:novasuite_core/novasuite_core.dart';
import '../../domain/repositories/auth_feature_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthFeatureRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserModel> login({required String email, required String password}) {
    return remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserModel?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }
}
