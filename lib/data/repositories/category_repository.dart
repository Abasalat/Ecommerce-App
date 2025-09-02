import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import 'product_repository.dart';

class CategoryItem {
  final String slug;
  final String name;
  final String url;
  CategoryItem({required this.slug, required this.name, required this.url});

  factory CategoryItem.fromJson(Map<String, dynamic> j) => CategoryItem(
    slug: (j['slug'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    url: (j['url'] ?? '').toString(),
  );
}

class CategoryPreview {
  final String slug;
  final String name;
  final List<String> imageUrls; // up to 4
  CategoryPreview({
    required this.slug,
    required this.name,
    required this.imageUrls,
  });
}

class CategoryRepository {
  final ApiClient _client;
  final ProductRepository _products;

  CategoryRepository(this._client) : _products = ProductRepository(_client);

  Future<List<CategoryItem>> fetchAllCategories() async {
    final json = await _client.getJson(ApiEndpoints.allCategoriesUrl);
    final data = json['data'];
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(CategoryItem.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Future<List<CategoryPreview>> fetchTopCategoriesWithPreviews({
    int categoryLimit = 6,
    int productPerCategory = 4,
  }) async {
    final all = await fetchAllCategories();
    final top = all.take(categoryLimit).toList();

    final previews = <CategoryPreview>[];
    for (final c in top) {
      final prods = await _products.fetchProductsByCategory(
        c.slug,
        limit: productPerCategory,
      );
      final images = <String>[];
      for (final p in prods) {
        if (p.images.isNotEmpty) {
          images.add(p.images.first);
        } else if ((p.thumbnail ?? '').isNotEmpty) {
          images.add(p.thumbnail!);
        }
        if (images.length >= productPerCategory) break;
      }
      previews.add(
        CategoryPreview(slug: c.slug, name: c.name, imageUrls: images),
      );
    }
    return previews;
  }
}
