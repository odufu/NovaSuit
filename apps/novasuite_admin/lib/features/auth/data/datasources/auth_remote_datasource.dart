import 'package:novasuite_core/novasuite_core.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AuthRepository _coreAuthRepo = AuthRepository();

  @override
  Future<UserModel> login({required String email, required String password}) {
    return _coreAuthRepo.signInWithEmail(email: email, password: password);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final authUser = _coreAuthRepo.currentAuthUser;
    if (authUser != null) {
      return await _coreAuthRepo.fetchUserProfile(authUser.id);
    }
    return null;
  }

  @override
  Future<void> logout() {
    return _coreAuthRepo.signOut();
  }
}
