import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/errors/app_exception.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/entities/product_entity.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/repositories/product_repository.dart';
import 'package:analatix_flutter_test_muhammedsahal/features/auth/providers/auth_provider.dart';
import 'package:analatix_flutter_test_muhammedsahal/features/products/providers/products_provider.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepo;

  final sampleProducts = List.generate(
    20,
    (i) => ProductEntity(
      id: i + 1,
      title: 'Product ${i + 1}',
      description: 'Description for product ${i + 1}',
      price: (i + 1) * 10.0,
      discountPercentage: 5.0,
      rating: 4.5,
      stock: 50,
      brand: 'Test Brand',
      category: 'Electronics',
      thumbnail: 'https://example.com/thumb$i.jpg',
      images: ['https://example.com/img$i.jpg'],
    ),
  );

  setUp(() {
    mockRepo = MockProductRepository();
  });

  test('loadProducts success -> state has products and isLoading is false', () async {
    when(() => mockRepo.getProducts(limit: 20, skip: 0))
        .thenAnswer((_) async => sampleProducts);

    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(productsProvider.notifier);
    await notifier.loadProducts();

    final state = container.read(productsProvider);
    expect(state.isLoading, isFalse);
    expect(state.products.length, equals(20));
    expect(state.isOffline, isFalse);
    expect(state.error, isNull);
  });

  test('loadProducts network error with cache -> state falls back to cached products', () async {
    final cached = sampleProducts.sublist(0, 5);
    when(() => mockRepo.getProducts(limit: 20, skip: 0))
        .thenThrow(const NetworkException('No internet'));
    when(() => mockRepo.getCachedProducts()).thenAnswer((_) async => cached);

    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(productsProvider.notifier);
    await notifier.loadProducts();

    final state = container.read(productsProvider);
    expect(state.isLoading, isFalse);
    expect(state.isOffline, isTrue);
    expect(state.products.length, equals(5));
  });

  test('loadMore -> appends new products and increments page', () async {
    final page1 = sampleProducts;
    final page2 = List.generate(
      10,
      (i) => ProductEntity(
        id: 100 + i,
        title: 'More Product $i',
        description: 'More description',
        price: 99.0,
        discountPercentage: 0.0,
        rating: 4.0,
        stock: 10,
        brand: null,
        category: 'Accessories',
        thumbnail: 'https://example.com/thumb.jpg',
        images: [],
      ),
    );

    when(() => mockRepo.getProducts(limit: 20, skip: 0))
        .thenAnswer((_) async => page1);
    when(() => mockRepo.getProducts(limit: 20, skip: 20))
        .thenAnswer((_) async => page2);

    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(productsProvider.notifier);
    await notifier.loadProducts();

    expect(container.read(productsProvider).products.length, equals(20));

    await notifier.loadMore();

    final state = container.read(productsProvider);
    expect(state.products.length, equals(30));
    expect(state.currentPage, equals(2));
  });

  test('refresh -> reloads from scratch', () async {
    when(() => mockRepo.getProducts(limit: 20, skip: 0))
        .thenAnswer((_) async => sampleProducts);

    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(productsProvider.notifier);
    await notifier.refresh();

    final state = container.read(productsProvider);
    expect(state.products.length, equals(20));
  });
}
