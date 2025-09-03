import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/product.dart';

class ProductRepository {
  final ApiClient _client;
  const ProductRepository(this._client);

  Future<List<Product>> fetchProductsByCategory(
    String categorySlug, {
    int limit = 4,
  }) async {
    final safe = Uri.encodeComponent(categorySlug);
    // Keep it simple: only limit; let API return full product objects with images
    final url = '${ApiEndpoints.categoryProductsUrl(safe)}?limit=$limit';

    final json = await _client.getJson(url);
    final list = json['products'];
    if (list is List) {
      return list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  /// Fetch top products (highly rated products from all categories)
  Future<List<Product>> fetchTopProducts({int limit = 10}) async {
    // Get all products with a reasonable limit to find top-rated ones
    final url = '${ApiEndpoints.limitedProductsUrl(100)}';

    final json = await _client.getJson(url);
    final list = json['products'];

    if (list is List) {
      final products = list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();

      // Sort by rating (descending) to get top-rated products
      products.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

      // Return only the requested limit
      return products.take(limit).toList(growable: false);
    }
    return const [];
  }
}
