import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  Map<String, dynamic> toJson() => {'slug': slug, 'name': name, 'url': url};
}

class CategoryPreview {
  final String slug;
  final String name;
  final List<String> imageUrls;

  CategoryPreview({
    required this.slug,
    required this.name,
    required this.imageUrls,
  });

  factory CategoryPreview.fromJson(Map<String, dynamic> j) => CategoryPreview(
    slug: (j['slug'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    imageUrls: List<String>.from(j['imageUrls'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'name': name,
    'imageUrls': imageUrls,
  };
}

class CategoryRepository {
  final ApiClient _client;
  final ProductRepository _products;

  // MEMORY CACHE (Layer 1)
  List<CategoryItem>? _cachedCategories;
  List<CategoryPreview>? _cachedPreviews;
  DateTime? _categoryCacheTimestamp;
  DateTime? _previewCacheTimestamp;
  static const _cacheDuration = Duration(hours: 2);

  // PERSISTENT CACHE (Layer 2)
  static const _categoriesCacheKey = 'categories_cache';
  static const _categoriesTimestampKey = 'categories_timestamp';
  static const _previewsCacheKey = 'category_previews_cache';
  static const _previewsTimestampKey = 'previews_timestamp';

  CategoryRepository(this._client) : _products = ProductRepository(_client);

  bool _isCategoriesCacheValid() {
    if (_cachedCategories == null || _categoryCacheTimestamp == null) {
      return false;
    }
    final age = DateTime.now().difference(_categoryCacheTimestamp!);
    return age < _cacheDuration;
  }

  bool _isPreviewsCacheValid() {
    if (_cachedPreviews == null || _previewCacheTimestamp == null) {
      return false;
    }
    final age = DateTime.now().difference(_previewCacheTimestamp!);
    return age < _cacheDuration;
  }

  Future<List<CategoryItem>?> _loadCategoriesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_categoriesCacheKey);
      final timestampMs = prefs.getInt(_categoriesTimestampKey);

      if (jsonString == null || timestampMs == null) return null;

      final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      final age = DateTime.now().difference(timestamp);
      if (age > _cacheDuration) {
        print('💾 Categories persistent cache expired');
        return null;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final categories = jsonList
          .map((json) => CategoryItem.fromJson(json as Map<String, dynamic>))
          .toList();

      print('💾 Loaded ${categories.length} categories from persistent cache');
      return categories;
    } catch (e) {
      print('❌ Error loading categories from storage: $e');
      return null;
    }
  }

  Future<void> _saveCategoriesToStorage(List<CategoryItem> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = categories.map((c) => c.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await prefs.setString(_categoriesCacheKey, jsonString);
      await prefs.setInt(
        _categoriesTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      print('💾 Saved ${categories.length} categories to persistent cache');
    } catch (e) {
      print('❌ Error saving categories to storage: $e');
    }
  }

  Future<List<CategoryPreview>?> _loadPreviewsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_previewsCacheKey);
      final timestampMs = prefs.getInt(_previewsTimestampKey);

      if (jsonString == null || timestampMs == null) return null;

      final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      final age = DateTime.now().difference(timestamp);
      if (age > _cacheDuration) {
        print('💾 Previews persistent cache expired');
        return null;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      final previews = jsonList
          .map((json) => CategoryPreview.fromJson(json as Map<String, dynamic>))
          .toList();

      print('💾 Loaded ${previews.length} previews from persistent cache');
      return previews;
    } catch (e) {
      print('❌ Error loading previews from storage: $e');
      return null;
    }
  }

  Future<void> _savePreviewsToStorage(List<CategoryPreview> previews) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = previews.map((p) => p.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await prefs.setString(_previewsCacheKey, jsonString);
      await prefs.setInt(
        _previewsTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      print('💾 Saved ${previews.length} previews to persistent cache');
    } catch (e) {
      print('❌ Error saving previews to storage: $e');
    }
  }

  Future<void> clearCache() async {
    _cachedCategories = null;
    _cachedPreviews = null;
    _categoryCacheTimestamp = null;
    _previewCacheTimestamp = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoriesCacheKey);
    await prefs.remove(_categoriesTimestampKey);
    await prefs.remove(_previewsCacheKey);
    await prefs.remove(_previewsTimestampKey);

    print('🗑️ Category caches cleared');
  }

  Map<String, dynamic> getCacheInfo() {
    return {
      'categories': {
        'status': _isCategoriesCacheValid() ? 'valid' : 'empty/expired',
        'count': _cachedCategories?.length ?? 0,
        'age': _categoryCacheTimestamp != null
            ? DateTime.now().difference(_categoryCacheTimestamp!).inMinutes
            : null,
      },
      'previews': {
        'status': _isPreviewsCacheValid() ? 'valid' : 'empty/expired',
        'count': _cachedPreviews?.length ?? 0,
        'age': _previewCacheTimestamp != null
            ? DateTime.now().difference(_previewCacheTimestamp!).inMinutes
            : null,
      },
    };
  }

  Future<List<CategoryItem>> fetchAllCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCategoriesCacheValid()) {
      print('✅ Using memory cache for categories');
      return _cachedCategories!;
    }

    if (!forceRefresh) {
      final storedCategories = await _loadCategoriesFromStorage();
      if (storedCategories != null) {
        _cachedCategories = storedCategories;
        _categoryCacheTimestamp = DateTime.now();
        print('✅ Restored categories from persistent cache');
        return storedCategories;
      }
    }

    print('🌐 Fetching categories from API...');
    final json = await _client.getJson(ApiEndpoints.allCategoriesUrl);
    final data = json['data'];

    if (data is List) {
      final categories = data
          .whereType<Map<String, dynamic>>()
          .map(CategoryItem.fromJson)
          .toList(growable: false);

      _cachedCategories = categories;
      _categoryCacheTimestamp = DateTime.now();
      await _saveCategoriesToStorage(categories);

      print('✅ Cached ${categories.length} categories');
      return categories;
    }

    return const [];
  }

  Future<List<CategoryPreview>> fetchTopCategoriesWithPreviews({
    int categoryLimit = 6,
    int productPerCategory = 4,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isPreviewsCacheValid()) {
      print('✅ Using memory cache for category previews');
      return _cachedPreviews!;
    }

    if (!forceRefresh) {
      final storedPreviews = await _loadPreviewsFromStorage();
      if (storedPreviews != null) {
        _cachedPreviews = storedPreviews;
        _previewCacheTimestamp = DateTime.now();
        print('✅ Restored previews from persistent cache');
        return storedPreviews;
      }
    }

    print('🌐 Generating category previews...');
    final all = await fetchAllCategories(forceRefresh: forceRefresh);
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

    _cachedPreviews = previews;
    _previewCacheTimestamp = DateTime.now();
    await _savePreviewsToStorage(previews);

    print('✅ Cached ${previews.length} category previews');
    return previews;
  }

  Future<List<CategoryItem>> refreshCategories() async {
    print('🔄 Refreshing categories...');
    return await fetchAllCategories(forceRefresh: true);
  }

  Future<List<CategoryPreview>> refreshPreviews({
    int categoryLimit = 6,
    int productPerCategory = 4,
  }) async {
    print('🔄 Refreshing category previews...');
    return await fetchTopCategoriesWithPreviews(
      categoryLimit: categoryLimit,
      productPerCategory: productPerCategory,
      forceRefresh: true,
    );
  }
}
