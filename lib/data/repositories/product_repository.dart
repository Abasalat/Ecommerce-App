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

  /// Fetch new products (recently added products - you can modify logic as needed)
  Future<List<Product>> fetchNewProducts({int limit = 10}) async {
    // For demo purposes, we'll get products and sort by ID (assuming higher ID = newer)
    // In a real app, you might have a 'createdAt' field or a separate endpoint
    final url = '${ApiEndpoints.limitedProductsUrl(50)}';

    final json = await _client.getJson(url);
    final list = json['products'];

    if (list is List) {
      final products = list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();

      // Sort by ID descending (assuming higher ID = newer product)
      // You can modify this logic based on your API structure
      products.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

      return products.take(limit).toList(growable: false);
    }
    return const [];
  }

  /// Fetch products that are on sale (discountPercentage > 0)
  Future<List<Product>> fetchSaleProducts({int limit = 6}) async {
    final url =
        '${ApiEndpoints.limitedProductsUrl(100)}'; // Adjust if you have a dedicated sale endpoint

    final json = await _client.getJson(url);
    final list = json['products'];

    if (list is List) {
      final products = list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .where(
            (product) => (product.discountPercentage ?? 0) > 0,
          ) // Filter by discount
          .toList();

      // Optionally sort by highest discount or rating
      products.sort(
        (a, b) => b.discountPercentage!.compareTo(a.discountPercentage!),
      );

      return products.take(limit).toList(growable: false);
    }
    return const [];
  }

  /// Fetch most popular products (based on high ratings and reviews)
  Future<List<Product>> fetchMostPopularProducts({int limit = 10}) async {
    // Get products and sort by a combination of rating and popularity factors
    final url = '${ApiEndpoints.limitedProductsUrl(100)}';

    final json = await _client.getJson(url);
    final list = json['products'];

    if (list is List) {
      final products = list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();

      // Sort by popularity score: rating * stock (popular items have good ratings and availability)
      products.sort((a, b) {
        final scoreA = (a.rating ?? 0) * (a.stock ?? 1);
        final scoreB = (b.rating ?? 0) * (b.stock ?? 1);
        return scoreB.compareTo(scoreA);
      });

      return products.take(limit).toList(growable: false);
    }
    return const [];
  }
}
