import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/errors/app_exception.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/biometric_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/secure_storage_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/entities/auth_entity.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/repositories/auth_repository.dart';
import 'package:analatix_flutter_test_muhammedsahal/features/auth/providers/auth_provider.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockBiometricService extends Mock implements BiometricService {}

void main() {
  late MockAuthRepository mockRepo;
  late MockSecureStorageService mockStorage;

  const testAuth = AuthEntity(
    accessToken: 'test-token-123',
    refreshToken: 'refresh-token-123',
    id: 1,
    username: 'alice',
    email: 'alice@example.com',
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    mockStorage = MockSecureStorageService();
    when(() => mockStorage.getUsername()).thenAnswer((_) async => null);
  });

  test('login success -> isAuthenticated is true and token is set', () async {
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockRepo.login('alice', 'pass123')).thenAnswer((_) async => testAuth);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authStateProvider.notifier);
    await notifier.login('alice', 'pass123');

    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.token, equals('test-token-123'));
    expect(state.username, equals('alice'));
    expect(state.error, isNull);
    expect(state.isLoading, isFalse);
  });

  test('login failure (AuthException) -> isAuthenticated is false and error set', () async {
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockRepo.login('alice', 'wrong'))
        .thenThrow(const AuthException('Invalid credentials'));

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authStateProvider.notifier);
    await notifier.login('alice', 'wrong');

    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.token, isNull);
    expect(state.error, contains('Invalid credentials'));
    expect(state.isLoading, isFalse);
  });

  test('logout -> isAuthenticated is false and token is null', () async {
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockRepo.login('alice', 'pass123')).thenAnswer((_) async => testAuth);
    when(() => mockRepo.logout()).thenAnswer((_) async {});

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authStateProvider.notifier);
    await notifier.login('alice', 'pass123');
    expect(container.read(authStateProvider).isAuthenticated, isTrue);

    await notifier.logout();

    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.token, isNull);
  });

  test('init with existing token -> isAuthenticated is true', () async {
    when(() => mockStorage.getToken()).thenAnswer((_) async => 'persisted-token-xyz');

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        secureStorageProvider.overrideWithValue(mockStorage),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authStateProvider.notifier);
    await notifier.init();

    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.token, equals('persisted-token-xyz'));
  });

  test('loginWithBiometrics success -> logs in with saved credentials', () async {
    final mockBiometric = MockBiometricService();
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getUsername()).thenAnswer((_) async => null);
    when(() => mockStorage.getBiometricCredentials()).thenAnswer(
      (_) async => {'username': 'emilys', 'password': 'emilyspass'},
    );
    when(() => mockBiometric.authenticate()).thenAnswer((_) async => true);
    when(() => mockRepo.login('emilys', 'emilyspass')).thenAnswer((_) async => testAuth);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        secureStorageProvider.overrideWithValue(mockStorage),
        biometricServiceProvider.overrideWithValue(mockBiometric),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authStateProvider.notifier);
    final result = await notifier.loginWithBiometrics();

    expect(result, isTrue);
    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.token, equals('test-token-123'));
    expect(state.username, equals('alice'));
  });

  test('loginWithBiometrics failure -> does not authenticate if scan rejected', () async {
    final mockBiometric = MockBiometricService();
    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockStorage.getUsername()).thenAnswer((_) async => null);
    when(() => mockStorage.getBiometricCredentials()).thenAnswer(
      (_) async => {'username': 'emilys', 'password': 'emilyspass'},
    );
    when(() => mockBiometric.authenticate()).thenAnswer((_) async => false);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
        secureStorageProvider.overrideWithValue(mockStorage),
        biometricServiceProvider.overrideWithValue(mockBiometric),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(authStateProvider.notifier);
    final result = await notifier.loginWithBiometrics();

    expect(result, isFalse);
    final state = container.read(authStateProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.error, contains('Biometric authentication cancelled or failed'));
  });
}
