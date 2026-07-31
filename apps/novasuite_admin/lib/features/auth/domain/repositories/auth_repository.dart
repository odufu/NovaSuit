import 'package:novasuite_core/novasuite_core.dart';

abstract class AuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}
