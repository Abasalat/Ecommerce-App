import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class ChatCacheService {
  static const String _cachePrefix = 'chat_response_';
  static const Duration _cacheDuration = Duration(hours: 24);

  // Generate cache key from query + products + context
  String _generateCacheKey(
    String query,
    List<Map<String, dynamic>> products,
    String userId,
  ) {
    final input = '$query|${products.length}|$userId';
    return _cachePrefix + md5.convert(utf8.encode(input)).toString();
  }

  // Save response to cache
  Future<void> cacheResponse(
    String query,
    List<Map<String, dynamic>> products,
    String userId,
    Map<String, dynamic> response,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _generateCacheKey(query, products, userId);

      final cacheData = {
        'response': response,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'query': query,
      };

      await prefs.setString(key, jsonEncode(cacheData));
    } catch (e) {
      print('Cache save error: $e');
    }
  }

  // Get cached response if valid
  Future<Map<String, dynamic>?> getCachedResponse(
    String query,
    List<Map<String, dynamic>> products,
    String userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _generateCacheKey(query, products, userId);

      final cached = prefs.getString(key);
      if (cached == null) return null;

      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

      // Check if cache is still valid
      if (cacheAge > _cacheDuration.inMilliseconds) {
        await prefs.remove(key); // Remove expired cache
        return null;
      }

      return cacheData['response'] as Map<String, dynamic>;
    } catch (e) {
      print('Cache read error: $e');
      return null;
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (var key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  // Check if query is similar to cached queries (fuzzy matching)
  Future<Map<String, dynamic>?> findSimilarCachedResponse(
    String query,
    List<Map<String, dynamic>> products,
    String userId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final lowerQuery = query.toLowerCase().trim();

      for (var key in keys) {
        if (!key.startsWith(_cachePrefix)) continue;

        final cached = prefs.getString(key);
        if (cached == null) continue;

        final cacheData = jsonDecode(cached) as Map<String, dynamic>;
        final cachedQuery = (cacheData['query'] as String).toLowerCase().trim();

        // Simple similarity check
        if (_querySimilarity(lowerQuery, cachedQuery) > 0.8) {
          final timestamp = cacheData['timestamp'] as int;
          final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;

          if (cacheAge <= _cacheDuration.inMilliseconds) {
            return cacheData['response'] as Map<String, dynamic>;
          }
        }
      }

      return null;
    } catch (e) {
      print('Similar cache search error: $e');
      return null;
    }
  }

  // Simple similarity score (Jaccard similarity)
  double _querySimilarity(String q1, String q2) {
    final words1 = q1.split(' ').toSet();
    final words2 = q2.split(' ').toSet();

    final intersection = words1.intersection(words2).length;
    final union = words1.union(words2).length;

    return union > 0 ? intersection / union : 0.0;
  }
}
