import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

import 'package:analatix_flutter_test_muhammedsahal/domain/entities/auth_entity.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/repositories/auth_repository.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/repositories/product_repository.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/secure_storage_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/hive_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/features/auth/providers/auth_provider.dart';
import 'package:analatix_flutter_test_muhammedsahal/main.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockProductRepository extends Mock implements ProductRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockHiveService extends Mock implements HiveService {}

void main() {
  testWidgets('App launches on login screen and logs in without errors', (tester) async {
    final mockAuth = MockAuthRepository();
    final mockStorage = MockSecureStorageService();
    final mockProduct = MockProductRepository();
    final mockHive = MockHiveService();

    when(() => mockStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockHive.loadLocale()).thenReturn('en');
    when(() => mockProduct.getProducts(limit: any(named: 'limit'), skip: any(named: 'skip')))
        .thenAnswer((_) async => []);

    when(() => mockAuth.login('emilys', 'emilyspass')).thenAnswer(
      (_) async => const AuthEntity(
        accessToken: 'mock-token',
        refreshToken: 'mock-refresh',
        id: 1,
        username: 'emilys',
        email: 'emily@example.com',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuth),
          productRepositoryProvider.overrideWithValue(mockProduct),
          secureStorageProvider.overrideWithValue(mockStorage),
          hiveServiceProvider.overrideWithValue(mockHive),
        ],
        child: const AnalytixApp(),
      ),
    );

    await tester.pumpAndSettle();

    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'emilys');
    await tester.enterText(textFields.at(1), 'emilyspass');

    final submitButton = find.byType(FilledButton);
    await tester.tap(submitButton);

    await tester.pump();
    await tester.pumpAndSettle();
  });
}

