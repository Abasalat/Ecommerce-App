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
}
