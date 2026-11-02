import 'package:analatix_flutter_test_muhammedsahal/domain/entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    int limit = 20,
    int skip = 0,
    int page = 0,
  });

  Future<List<ProductEntity>> searchProducts(String query);

  Future<ProductEntity> getProduct(int id);

  Future<List<ProductEntity>> getCachedProducts();
}
