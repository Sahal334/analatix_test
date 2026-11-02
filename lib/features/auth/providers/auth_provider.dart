import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../data/datasources/local/hive_service.dart';
import '../../../data/datasources/local/secure_storage_service.dart';
import '../../../data/datasources/remote/api_client.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/repositories/product_repository_impl.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/product_repository.dart';

class AuthState {
  const AuthState({
    this.isAuthenticated = false,
    this.token,
    this.username,
    this.isLoading = false,
    this.error,
  });

  final bool isAuthenticated;
  final String? token;
  final String? username;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    bool? isAuthenticated,
    Object? token = _sentinel,
    Object? username = _sentinel,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      token: token == _sentinel ? this.token : token as String?,
      username: username == _sentinel ? this.username : username as String?,
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  @override
  String toString() =>
      'AuthState(isAuthenticated: $isAuthenticated, isLoading: $isLoading, '
      'username: $username, error: $error)';
}

const Object _sentinel = Object();

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  Future<void> init() async {
    final storage = _ref.read(secureStorageProvider);
    try {
      final token = await storage.getToken();
      if (token != null && token.isNotEmpty) {
        _ref.read(apiClientProvider).updateToken(token);
        state = state.copyWith(
          isAuthenticated: true,
          token: token,
          error: null,
        );
      }
    } catch (_) {
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(authRepositoryProvider);
      final auth = await repo.login(username, password);

      state = state.copyWith(
        isAuthenticated: true,
        token: auth.accessToken,
        username: auth.username,
        isLoading: false,
        error: null,
      );
    } on AuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
        isAuthenticated: false,
        token: null,
      );
    } on NetworkException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repo = _ref.read(authRepositoryProvider);
      await repo.logout();
    } catch (_) {
    } finally {
      state = const AuthState();
    }
  }
}

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => SecureStorageService(),
);

final hiveServiceProvider = Provider<HiveService>(
  (ref) => HiveService(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    hiveService: ref.watch(hiveServiceProvider),
  );
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(ref);
  notifier.init();
  return notifier;
});

final isAuthenticatedProvider = Provider<bool>(
  (ref) => ref.watch(authStateProvider).isAuthenticated,
);
