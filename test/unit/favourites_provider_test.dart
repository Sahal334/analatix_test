import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/hive_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/entities/product_entity.dart';
import 'package:analatix_flutter_test_muhammedsahal/features/auth/providers/auth_provider.dart';
import 'package:analatix_flutter_test_muhammedsahal/features/favourites/providers/favourites_provider.dart';

class MockHiveService extends Mock implements HiveService {}

ProductEntity _createProduct(int id) => ProductEntity(
      id: id,
      title: 'Product $id',
      description: 'Description',
      price: 19.99,
      discountPercentage: 0,
      rating: 4.5,
      stock: 10,
      category: 'Test',
      thumbnail: 'https://example.com/thumb$id.jpg',
      images: [],
    );

void main() {
  late MockHiveService mockHive;

  setUp(() {
    mockHive = MockHiveService();
    when(() => mockHive.loadFavourites()).thenReturn([]);
    when(() => mockHive.saveFavourites(any())).thenAnswer((_) async {});
  });

  test('toggle add -> product appears in state', () async {
    final container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWithValue(mockHive),
      ],
    );
    addTearDown(container.dispose);

    final p = _createProduct(1);
    final notifier = container.read(favouritesProvider.notifier);
    await notifier.toggle(p);

    final state = container.read(favouritesProvider);
    expect(state, contains(p));
    expect(notifier.isFavourite(1), isTrue);
    verify(() => mockHive.saveFavourites(any())).called(1);
  });

  test('toggle remove -> product removed from state', () async {
    final p = _createProduct(2);
    when(() => mockHive.loadFavourites()).thenReturn([p]);

    final container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWithValue(mockHive),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(favouritesProvider.notifier);
    expect(container.read(favouritesProvider), contains(p));

    await notifier.toggle(p);

    final state = container.read(favouritesProvider);
    expect(state, isNot(contains(p)));
    expect(notifier.isFavourite(2), isFalse);
    verify(() => mockHive.saveFavourites(any())).called(1);
  });

  test('isFavouriteProvider returns true/false correctly', () async {
    final p1 = _createProduct(10);
    when(() => mockHive.loadFavourites()).thenReturn([p1]);

    final container = ProviderContainer(
      overrides: [
        hiveServiceProvider.overrideWithValue(mockHive),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(isFavouriteProvider(10)), isTrue);
    expect(container.read(isFavouriteProvider(20)), isFalse);
  });
}
