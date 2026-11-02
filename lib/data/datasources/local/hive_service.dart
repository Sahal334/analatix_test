import 'package:hive_flutter/hive_flutter.dart';

import 'package:analatix_flutter_test_muhammedsahal/core/constants/app_constants.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/entities/product_entity.dart';

class HiveService {

  Future<void> init() async {
    await Future.wait([
      Hive.openBox<dynamic>(AppConstants.productsBox),
      Hive.openBox<dynamic>(AppConstants.favouritesBox),
      Hive.openBox<dynamic>(AppConstants.settingsBox),
    ]);
  }

  Box<dynamic> get _productsBox => Hive.box<dynamic>(AppConstants.productsBox);
  Box<dynamic> get _favouritesBox =>
      Hive.box<dynamic>(AppConstants.favouritesBox);
  Box<dynamic> get _settingsBox =>
      Hive.box<dynamic>(AppConstants.settingsBox);

  Future<void> cacheProducts(List<Map<String, dynamic>> products) async {
    await _productsBox.put(AppConstants.productsCacheKey, products);
  }

  List<Map<String, dynamic>> getCachedProducts() {
    final raw = _productsBox.get(AppConstants.productsCacheKey);
    if (raw == null) return [];

    return (raw as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> saveFavourites(List<ProductEntity> favourites) async {
    final maps = favourites.map((p) => {
      'id': p.id,
      'title': p.title,
      'description': p.description,
      'price': p.price,
      'discountPercentage': p.discountPercentage,
      'rating': p.rating,
      'stock': p.stock,
      'brand': p.brand,
      'category': p.category,
      'thumbnail': p.thumbnail,
      'images': p.images,
    }).toList();
    await _favouritesBox.put('saved_favourites', maps);
  }

  List<ProductEntity> loadFavourites() {
    final raw = _favouritesBox.get('saved_favourites');
    if (raw == null) return [];

    return (raw as List<dynamic>).map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return ProductEntity(
        id: map['id'] as int,
        title: map['title'] as String,
        description: map['description'] as String,
        price: (map['price'] as num).toDouble(),
        discountPercentage: (map['discountPercentage'] as num).toDouble(),
        rating: (map['rating'] as num).toDouble(),
        stock: map['stock'] as int,
        brand: map['brand'] as String?,
        category: map['category'] as String,
        thumbnail: map['thumbnail'] as String,
        images: (map['images'] as List<dynamic>)
            .map((item) => item.toString())
            .toList(),
      );
    }).toList();
  }

  String? loadLocale() {
    return _settingsBox.get(AppConstants.localeCacheKey) as String?;
  }

  Future<void> saveLocale(String code) async {
    await _settingsBox.put(AppConstants.localeCacheKey, code);
  }
}
