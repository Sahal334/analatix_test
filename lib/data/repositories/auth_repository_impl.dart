import 'package:analatix_flutter_test_muhammedsahal/core/errors/app_exception.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/secure_storage_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/remote/api_client.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/entities/auth_entity.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  }) {
    _apiClient = apiClient;
    _secureStorage = secureStorage;
  }

  late final ApiClient _apiClient;
  late final SecureStorageService _secureStorage;

  @override
  Future<AuthEntity> login(String username, String password) async {
    try {
      final authModel = await _apiClient.login(username, password);

      await Future.wait([
        _secureStorage.saveToken(authModel.accessToken),
        _secureStorage.saveRefreshToken(authModel.refreshToken),
      ]);

      _apiClient.updateToken(authModel.accessToken);

      return AuthEntity(
        accessToken: authModel.accessToken,
        refreshToken: authModel.refreshToken,
        id: authModel.id,
        username: authModel.username,
        email: authModel.email,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _secureStorage.clearAll();
      _apiClient.updateToken(null);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }
}
