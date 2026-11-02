import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/datasources/local/hive_service.dart';
import '../../../domain/entities/product_entity.dart';
import '../../auth/providers/auth_provider.dart';

class FavouritesNotifier extends StateNotifier<List<ProductEntity>> {
  FavouritesNotifier(this._hive) : super(const []);

  final HiveService _hive;

  void loadFavourites() {
    try {
      final stored = _hive.loadFavourites();
      state = stored;
    } catch (_) {
      state = [];
    }
  }

  Future<void> toggle(ProductEntity product) async {
    final isFav = isFavourite(product.id);
    if (isFav) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
    await _persist();
  }

  bool isFavourite(int id) => state.any((p) => p.id == id);

  Future<void> _persist() async {
    try {
      await _hive.saveFavourites(state);
    } catch (_) {
    }
  }
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, List<ProductEntity>>((ref) {
  final hive = ref.read(hiveServiceProvider);
  final notifier = FavouritesNotifier(hive);
  notifier.loadFavourites();
  return notifier;
});

final isFavouriteProvider = Provider.family<bool, int>((ref, id) {
  return ref.watch(favouritesProvider).any((p) => p.id == id);
});
