import 'package:novasuite_core/novasuite_core.dart';
import '../repositories/auth_feature_repository.dart';

class GetCurrentUserUseCase {
  final AuthFeatureRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserModel?> execute() {
    return repository.getCurrentUser();
  }
}
