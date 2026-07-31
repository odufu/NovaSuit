import 'package:novasuite_core/novasuite_core.dart';

abstract class AuthFeatureRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}
