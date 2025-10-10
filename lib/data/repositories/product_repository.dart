import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../models/product.dart';

class ProductRepository {
  final ApiClient _client;

  // ============================================
  // MEMORY CACHE (Layer 1 - Fastest)
  // ============================================
  List<Product>? _cachedProducts;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(minutes: 30);

  // ============================================
  // PERSISTENT CACHE (Layer 2 - Survives restart)
  // ============================================
  static const _persistentCacheKey = 'products_cache';
  static const _persistentTimestampKey = 'products_cache_timestamp';

  // ============================================
  // SEARCH HISTORY
  // ============================================
  static const _searchHistoryKey = 'search_history';
  static const _maxSearchHistory = 10;

  // ============================================
  // DEBOUNCING
  // ============================================
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);

  // ============================================
  // PAGINATION
  // ============================================
  int _currentPage = 0;
  static const _pageSize = 20;
  bool _hasMoreProducts = true;

  ProductRepository(this._client);

  // ============================================
  // 🆕 CACHE HELPER METHODS
  // ============================================

  /// Check if memory cache is valid
  bool _isCacheValid() {
    if (_cachedProducts == null || _cacheTimestamp == null) {
      return false;
    }
    final age = DateTime.now().difference(_cacheTimestamp!);
    return age < _cacheDuration;
  }

  /// Load from persistent storage (Layer 2)
  Future<List<Product>?> _loadFromPersistentCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_persistentCacheKey);
      final timestampMs = prefs.getInt(_persistentTimestampKey);

      if (jsonString == null || timestampMs == null) {
        return null;
      }

      // Check if persistent cache is expired
      final timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      final age = DateTime.now().difference(timestamp);
      if (age > _cacheDuration) {
        print('💾 Persistent cache expired');
        return null;
      }

      // Deserialize products
      final List<dynamic> jsonList = json.decode(jsonString);
      final products = jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      print('💾 Loaded ${products.length} products from persistent cache');
      return products;
    } catch (e) {
      print('❌ Error loading persistent cache: $e');
      return null;
    }
  }

  /// Save to persistent storage (Layer 2)
  Future<void> _saveToPersistentCache(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Serialize products
      final jsonList = products.map((p) => p.toJson()).toList();
      final jsonString = json.encode(jsonList);

      await prefs.setString(_persistentCacheKey, jsonString);
      await prefs.setInt(
        _persistentTimestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      print('💾 Saved ${products.length} products to persistent cache');
    } catch (e) {
      print('❌ Error saving persistent cache: $e');
    }
  }

  /// Get all products with 2-layer caching
  Future<List<Product>> _getAllProducts({bool forceRefresh = false}) async {
    // Layer 1: Check memory cache
    if (!forceRefresh && _isCacheValid()) {
      print('✅ Using memory cache (${_cachedProducts!.length} items)');
      return _cachedProducts!;
    }

    // Layer 2: Check persistent cache
    if (!forceRefresh) {
      final persistentProducts = await _loadFromPersistentCache();
      if (persistentProducts != null) {
        _cachedProducts = persistentProducts;
        _cacheTimestamp = DateTime.now();
        print('✅ Restored from persistent cache');
        return persistentProducts;
      }
    }

    // Layer 3: Fetch from API
    print('🌐 Fetching fresh products from API...');
    final url = '${ApiEndpoints.limitedProductsUrl(100)}';

    final json = await _client.getJson(url);
    final list = json['products'];

    if (list is List) {
      final products = list
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);

      // Update both caches
      _cachedProducts = products;
      _cacheTimestamp = DateTime.now();
      await _saveToPersistentCache(products);

      print('✅ Cached ${products.length} products in memory + storage');
      return products;
    }

    return const [];
  }

  /// Clear all caches
  Future<void> clearCache() async {
    _cachedProducts = null;
    _cacheTimestamp = null;
    _currentPage = 0;
    _hasMoreProducts = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_persistentCacheKey);
    await prefs.remove(_persistentTimestampKey);

    print('🗑️ All caches cleared');
  }

  /// Get cache info
  Map<String, dynamic> getCacheInfo() {
    if (_cachedProducts == null || _cacheTimestamp == null) {
      return {'status': 'empty', 'count': 0, 'age': null};
    }

    final age = DateTime.now().difference(_cacheTimestamp!);
    return {
      'status': _isCacheValid() ? 'valid' : 'expired',
      'count': _cachedProducts!.length,
      'age': age.inMinutes,
      'expiresIn': _cacheDuration.inMinutes - age.inMinutes,
    };
  }

  // ============================================
  // 🆕 SEARCH HISTORY METHODS
  // ============================================

  /// Save search query to history
  Future<void> saveSearchHistory(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];

    // Remove if already exists (to move to top)
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Keep only last 10
    if (history.length > _maxSearchHistory) {
      history = history.take(_maxSearchHistory).toList();
    }

    await prefs.setStringList(_searchHistoryKey, history);
  }

  /// Get search history
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  // ============================================
  // 🆕 DEBOUNCED SEARCH
  // ============================================

  /// Search with debouncing (waits for user to stop typing)
  Future<List<Product>> debouncedSearch(
    String query,
    Function(List<Product>) onResults,
  ) async {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer
    final completer = Completer<List<Product>>();

    _debounceTimer = Timer(_debounceDuration, () async {
      final results = await searchProducts(query);
      onResults(results);
      completer.complete(results);
    });

    return completer.future;
  }

  // ============================================
  // 🆕 PAGINATION METHODS
  // ============================================

  /// Fetch products with pagination
  Future<List<Product>> fetchProductsPaginated({bool loadMore = false}) async {
    if (loadMore && !_hasMoreProducts) {
      return const [];
    }

    if (!loadMore) {
      _currentPage = 0;
      _hasMoreProducts = true;
    }

    final allProducts = await _getAllProducts();
    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, allProducts.length);

    if (startIndex >= allProducts.length) {
      _hasMoreProducts = false;
      return const [];
    }

    final page = allProducts.sublist(startIndex, endIndex);
    _currentPage++;

    if (endIndex >= allProducts.length) {
      _hasMoreProducts = false;
    }

    print('📄 Loaded page $_currentPage (${page.length} products)');
    return page;
  }

  /// Check if more products available
  bool get hasMoreProducts => _hasMoreProducts;

  /// Reset pagination
  void resetPagination() {
    _currentPage = 0;
    _hasMoreProducts = true;
  }

  // ============================================
  // ✅ UPDATED METHODS
  // ============================================

  Future<List<Product>> fetchProductsByCategory(
    String categorySlug, {
    int limit = 4,
  }) async {
    final allProducts = await _getAllProducts();

    final filtered = allProducts
        .where((p) => p.category?.toLowerCase() == categorySlug.toLowerCase())
        .take(limit)
        .toList(growable: false);

    return filtered;
  }

  Future<List<Product>> fetchTopProducts({int limit = 10}) async {
    final allProducts = await _getAllProducts();
    final products = List<Product>.from(allProducts);

    products.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

    return products.take(limit).toList(growable: false);
  }

  Future<List<Product>> fetchNewProducts({
    int limit = 10,
    required int page,
  }) async {
    final allProducts = await _getAllProducts();
    final products = List<Product>.from(allProducts);

    products.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

    return products.take(limit).toList(growable: false);
  }

  Future<List<Product>> fetchSaleProducts({int limit = 6}) async {
    final allProducts = await _getAllProducts();

    final products = allProducts
        .where((product) => (product.discountPercentage ?? 0) > 0)
        .toList();

    products.sort(
      (a, b) =>
          (b.discountPercentage ?? 0).compareTo(a.discountPercentage ?? 0),
    );

    return products.take(limit).toList(growable: false);
  }

  Future<List<Product>> fetchMostPopularProducts({int limit = 10}) async {
    final allProducts = await _getAllProducts();
    final products = List<Product>.from(allProducts);

    products.sort((a, b) {
      final scoreA = (a.rating ?? 0) * (a.stock ?? 1);
      final scoreB = (b.rating ?? 0) * (b.stock ?? 1);
      return scoreB.compareTo(scoreA);
    });

    return products.take(limit).toList(growable: false);
  }

  Future<List<Product>> fetchJustForYouProducts({int limit = 50}) async {
    final allProducts = await _getAllProducts();
    final products = List<Product>.from(allProducts);

    products.shuffle();

    return products.take(limit).toList(growable: false);
  }

  Future<List<Product>> fetchAllProducts({int limit = 50}) async {
    final allProducts = await _getAllProducts();
    return allProducts.take(limit).toList(growable: false);
  }

  /// Search products (saves to history automatically)
  Future<List<Product>> searchProducts(String query) async {
    final allProducts = await _getAllProducts();

    if (query.trim().isEmpty) {
      return const [];
    }

    final lowerQuery = query.toLowerCase().trim();

    // Save to history
    await saveSearchHistory(query);

    final results = allProducts
        .where((product) {
          final titleMatch = product.title.toLowerCase().contains(lowerQuery);
          final descMatch =
              product.description?.toLowerCase().contains(lowerQuery) ?? false;
          final categoryMatch =
              product.category?.toLowerCase().contains(lowerQuery) ?? false;
          final brandMatch =
              product.brand?.toLowerCase().contains(lowerQuery) ?? false;

          final queryAsNumber = double.tryParse(lowerQuery);
          final priceMatch =
              queryAsNumber != null &&
              product.price! >= queryAsNumber - 10 &&
              product.price! <= queryAsNumber + 10;

          return titleMatch ||
              descMatch ||
              categoryMatch ||
              brandMatch ||
              priceMatch;
        })
        .toList(growable: false);

    print('🔍 Search "$query" found ${results.length} results');
    return results;
  }

  /// Refresh cache (pull-to-refresh)
  Future<List<Product>> refreshProducts() async {
    print('🔄 Refreshing products...');
    return await _getAllProducts(forceRefresh: true);
  }
}
