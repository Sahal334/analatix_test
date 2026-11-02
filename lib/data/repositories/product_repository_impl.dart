import 'package:analatix_flutter_test_muhammedsahal/core/constants/app_constants.dart';
import 'package:analatix_flutter_test_muhammedsahal/core/errors/app_exception.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/local/hive_service.dart';
import 'package:analatix_flutter_test_muhammedsahal/data/datasources/remote/api_client.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/entities/product_entity.dart';
import 'package:analatix_flutter_test_muhammedsahal/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ApiClient apiClient,
    required HiveService hiveService,
  }) {
    _apiClient = apiClient;
    _hiveService = hiveService;
  }

  late final ApiClient _apiClient;
  late final HiveService _hiveService;

  @override
  Future<List<ProductEntity>> getProducts({
    int limit = AppConstants.pageSize,
    int skip = 0,
    int page = 0,
  }) async {
    try {
      final actualSkip = skip != 0 ? skip : page * limit;
      final response = await _apiClient.getProducts(
        limit: limit,
        skip: actualSkip,
      );

      if (actualSkip == 0) {
        await _hiveService.cacheProducts(
          response.products.map((p) => p.toJson()).toList(),
        );
      }

      return response.products.map(_toEntity).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    try {
      final response = await _apiClient.searchProducts(query);
      return response.products.map(_toEntity).toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<ProductEntity> getProduct(int id) async {
    try {
      final model = await _apiClient.getProduct(id);
      return _toEntity(model);
    } on AppException {
      rethrow;
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  @override
  Future<List<ProductEntity>> getCachedProducts() async {
    try {
      final cached = _hiveService.getCachedProducts();
      return cached.map((json) {
        return ProductEntity(
          id: json['id'] as int,
          title: json['title'] as String,
          description: json['description'] as String,
          price: (json['price'] as num).toDouble(),
          discountPercentage: (json['discountPercentage'] as num).toDouble(),
          rating: (json['rating'] as num).toDouble(),
          stock: json['stock'] as int,
          brand: json['brand'] as String?,
          category: json['category'] as String,
          thumbnail: json['thumbnail'] as String,
          images: (json['images'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
        );
      }).toList();
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  ProductEntity _toEntity(dynamic model) {
    return ProductEntity(
      id: model.id as int,
      title: model.title as String,
      description: model.description as String,
      price: (model.price as num).toDouble(),
      discountPercentage: (model.discountPercentage as num).toDouble(),
      rating: (model.rating as num).toDouble(),
      stock: model.stock as int,
      brand: model.brand as String?,
      category: model.category as String,
      thumbnail: model.thumbnail as String,
      images: List<String>.from(model.images as List),
    );
  }
}
