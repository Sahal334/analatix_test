import 'package:analatix_flutter_test_muhammedsahal/domain/entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String username, String password);

  Future<void> logout();
}
