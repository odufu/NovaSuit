import 'package:novasuite_core/novasuite_core.dart';
import '../repositories/auth_feature_repository.dart';

class LoginUseCase {
  final AuthFeatureRepository repository;

  LoginUseCase(this.repository);

  Future<UserModel> execute({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
