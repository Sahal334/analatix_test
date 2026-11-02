import 'package:analatix_flutter_test_muhammedsahal/data/models/product_model.dart';

class ProductListResponse {
  const ProductListResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;

  final int total;

  final int skip;

  final int limit;

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      products: (json['products'] as List<dynamic>)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      skip: json['skip'] as int,
      limit: json['limit'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((p) => p.toJson()).toList(),
      'total': total,
      'skip': skip,
      'limit': limit,
    };
  }

  @override
  String toString() =>
      'ProductListResponse(total: $total, skip: $skip, limit: $limit, '
      'count: ${products.length})';
}
