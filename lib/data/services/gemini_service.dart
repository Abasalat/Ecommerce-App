// FILE 2: gemini_service.dart (UPDATED WITH CACHING)
// ============================================
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/chat_message_model.dart';
import '../models/conversation_context.dart';
import 'chat_cache_service.dart';

class GeminiService {
  String get _apiKey {
    return 'AIzaSyAXy6y5E9HkeAcYWIIAfbVaO_9dQUU04_Q';
  }

  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ChatCacheService _cacheService = ChatCacheService();

  // API call counter for monitoring
  int _apiCallCount = 0;
  int get apiCallCount => _apiCallCount;

  GeminiService({String modelName = 'gemini-2.5-flash-lite'}) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.7,
        maxOutputTokens: 600,
      ),
    );

    _initializeChat();
  }

  void _initializeChat() {
    _chat = _model.startChat(history: []);
  }

  /// ✅ OPTIMIZED: With multi-layer caching
  Future<Map<String, dynamic>> getProductRecommendations({
    required String userQuery,
    required List<Map<String, dynamic>> availableProducts,
    required ConversationContext context,
    required String userId,
    List<String> categories = const [],
    List<Map<String, String>> chatHistory = const [],
    bool useCache = true, // ✅ NEW: Option to bypass cache
  }) async {
    // ✅ LAYER 1: Handle simple queries without API
    final simpleResponse = _handleSimpleQuery(userQuery, categories);
    if (simpleResponse != null) {
      debugPrint('✅ Simple query handled without API');
      return simpleResponse;
    }

    // ✅ LAYER 2: Check exact cache match
    if (useCache) {
      final cached = await _cacheService.getCachedResponse(
        userQuery,
        availableProducts,
        userId,
      );

      if (cached != null) {
        debugPrint('✅ Cache hit! No API call needed');
        return cached;
      }

      // ✅ LAYER 3: Check similar queries cache
      final similar = await _cacheService.findSimilarCachedResponse(
        userQuery,
        availableProducts,
        userId,
      );

      if (similar != null) {
        debugPrint('✅ Similar query cache hit! No API call needed');
        return similar;
      }
    }

    // ✅ LAYER 4: Make API call (cache miss)
    try {
      debugPrint('⚠️ Cache miss - Making API call...');
      _apiCallCount++;

      final filteredProducts = _smartFilterProducts(
        userQuery,
        availableProducts,
        chatHistory,
      );

      final prompt = _buildPrompt(
        userQuery,
        filteredProducts,
        context,
        categories,
        chatHistory,
      );

      final response = await _chat.sendMessage(Content.text(prompt));
      final responseText = response.text ?? '';
      final parsedResponse = _parseResponse(responseText);

      // ✅ CRITICAL: Validate product IDs before returning
      final validatedResponse = _validateProductIds(
        parsedResponse,
        filteredProducts,
        userQuery,
      );

      // ✅ Cache the response
      if (useCache && !validatedResponse['isError']) {
        await _cacheService.cacheResponse(
          userQuery,
          availableProducts,
          userId,
          validatedResponse,
        );
      }

      return validatedResponse;
    } on GenerativeAIException catch (e, stack) {
      debugPrint('Gemini GenerativeAIException: ${e.message}\n$stack');

      if (e.message != null && e.message!.toLowerCase().contains('not found')) {
        try {
          final fallback = GenerativeModel(
            model: 'gemini-2.5-flash-lite',
            apiKey: _apiKey,
            generationConfig: GenerationConfig(
              responseMimeType: 'application/json',
              temperature: 0.7,
              maxOutputTokens: 600,
            ),
          ).startChat(history: []);

          final filteredProducts = _smartFilterProducts(
            userQuery,
            availableProducts,
            chatHistory,
          );
          final prompt = _buildPrompt(
            userQuery,
            filteredProducts,
            context,
            categories,
            chatHistory,
          );
          final retry = await fallback.sendMessage(Content.text(prompt));
          return _parseResponse(retry.text ?? '');
        } catch (e2, st2) {
          debugPrint('Fallback failed: $e2\n$st2');
        }
      }

      return {
        'message':
            "I'm having trouble with the AI right now. Could you rephrase or try again?",
        'productIds': <String>[],
        'reasoning': '',
        'isError': true,
      };
    } catch (e, stack) {
      debugPrint('Gemini API Error: $e\n$stack');
      return {
        'message':
            "I'm having trouble processing your request. Please try again.",
        'productIds': <String>[],
        'reasoning': '',
        'isError': true,
      };
    }
  }

  /// ✅ NEW: Handle simple queries without API calls
  Map<String, dynamic>? _handleSimpleQuery(
    String query,
    List<String> categories,
  ) {
    final lowerQuery = query.toLowerCase().trim();

    // Greetings
    final greetings = ['hi', 'hello', 'hey', 'good morning', 'good evening'];
    if (greetings.any((g) => lowerQuery == g || lowerQuery.startsWith('$g '))) {
      return {
        'message':
            'Hello! 👋 How can I help you find the perfect product today?',
        'productIds': <String>[],
        'reasoning': 'Greeting response',
        'isError': false,
      };
    }

    // Category list request
    if (lowerQuery.contains('what categories') ||
        lowerQuery.contains('show categories') ||
        lowerQuery.contains('all categories') ||
        lowerQuery == 'categories') {
      if (categories.isEmpty) {
        return {
          'message':
              'I can help you explore our products! What are you looking for?',
          'productIds': <String>[],
          'reasoning': 'Category list request',
          'isError': false,
        };
      }

      return {
        'message':
            'We have these categories: ${categories.join(", ")}. What would you like to explore?',
        'productIds': <String>[],
        'reasoning': 'Category list from repository',
        'isError': false,
      };
    }

    // Show all products request
    if (lowerQuery.contains('all products') ||
        lowerQuery.contains('show all') ||
        lowerQuery == 'all') {
      return {
        'message':
            'I have access to all our products! To help you better, could you tell me what type of product you\'re interested in? Or would you like to browse by category?',
        'productIds': <String>[],
        'reasoning': 'Show all products request',
        'isError': false,
      };
    }

    return null; // Needs API call
  }

  /// Smart pre-filtering with conversation memory
  List<Map<String, dynamic>> _smartFilterProducts(
    String query,
    List<Map<String, dynamic>> products,
    List<Map<String, String>> chatHistory,
  ) {
    final lowerQuery = query.toLowerCase();

    String? previousContext;
    if (chatHistory.isNotEmpty) {
      final recentMessages = chatHistory.length > 3
          ? chatHistory.sublist(chatHistory.length - 3)
          : chatHistory;

      for (var msg in recentMessages.reversed) {
        final text = msg['text']?.toLowerCase() ?? '';
        if (text.contains('watch')) {
          previousContext = 'watch';
          break;
        } else if (text.contains('phone')) {
          previousContext = 'phone';
          break;
        } else if (text.contains('laptop')) {
          previousContext = 'laptop';
          break;
        } else if (text.contains('shirt')) {
          previousContext = 'shirt';
          break;
        } else if (text.contains('shoe')) {
          previousContext = 'shoe';
          break;
        } else if (text.contains('sunglass')) {
          previousContext = 'sunglass';
          break;
        } else if (text.contains('glass')) {
          previousContext = 'glass';
          break;
        }
      }
    }

    final productKeywords = {
      'watch': ['watch', 'watches', 'timepiece', 'wristwatch', 'smartwatch'],
      'phone': [
        'phone',
        'smartphone',
        'mobile',
        'iphone',
        'samsung',
        'android',
      ],
      'laptop': ['laptop', 'notebook', 'computer', 'macbook', 'chromebook'],
      'shirt': ['shirt', 'tshirt', 't-shirt', 'polo', 'blouse', 'top'],
      'shoes': ['shoe', 'shoes', 'sneaker', 'boot', 'sandal', 'footwear'],
      'bag': ['bag', 'backpack', 'purse', 'handbag', 'suitcase', 'luggage'],
      'kitchen': ['kitchen', 'cook', 'utensil', 'pan', 'pot', 'cookware'],
      'electronic': ['electronic', 'gadget', 'device', 'tech'],
      'fashion': ['fashion', 'clothing', 'apparel', 'wear'],
      'jewelry': ['jewelry', 'jewellery', 'necklace', 'ring', 'bracelet'],
      'sunglass': ['sunglass', 'sunglasses', 'shades', 'eyewear', 'glasses'],
      'glass': ['glass', 'glasses', 'eyewear', 'spectacle'],
    };

    final contextualQueries = [
      'best',
      'better',
      'top',
      'popular',
      'recommend',
      'suggest',
      'cheap',
      'cheaper',
      'expensive',
      'affordable',
      'budget',
      'other',
      'more',
      'different',
      'alternative',
    ];

    bool isContextualQuery = contextualQueries.any(
      (word) => lowerQuery.contains(word),
    );

    if (isContextualQuery && previousContext != null) {
      debugPrint(
        '🔍 Contextual query detected: "$query" → Using previous context: "$previousContext"',
      );

      final keywords = productKeywords[previousContext] ?? [];
      final filtered = products.where((product) {
        final title = (product['title'] ?? '').toString().toLowerCase();
        final category = (product['category'] ?? '').toString().toLowerCase();
        final description = (product['description'] ?? '')
            .toString()
            .toLowerCase();

        for (var keyword in keywords) {
          if (title.contains(keyword) ||
              category.contains(keyword) ||
              description.contains(keyword)) {
            return true;
          }
        }
        return false;
      }).toList();

      if (filtered.isNotEmpty) {
        debugPrint('✅ Context-filtered products: ${filtered.length} matches');
        return filtered;
      }
    }

    String? matchedCategory;
    List<String>? matchedKeywords;

    for (var entry in productKeywords.entries) {
      for (var keyword in entry.value) {
        if (lowerQuery.contains(keyword)) {
          matchedCategory = entry.key;
          matchedKeywords = entry.value;
          break;
        }
      }
      if (matchedCategory != null) break;
    }

    if (matchedCategory != null && matchedKeywords != null) {
      final filtered = products.where((product) {
        final title = (product['title'] ?? '').toString().toLowerCase();
        final category = (product['category'] ?? '').toString().toLowerCase();
        final description = (product['description'] ?? '')
            .toString()
            .toLowerCase();

        for (var keyword in matchedKeywords!) {
          if (title.contains(keyword) ||
              category.contains(keyword) ||
              description.contains(keyword)) {
            return true;
          }
        }
        return false;
      }).toList();

      if (filtered.isNotEmpty) {
        debugPrint(
          '✅ Pre-filtered products: ${filtered.length} matches for "$matchedCategory"',
        );
        return filtered;
      }
    }

    return products;
  }

  String _buildPrompt(
    String userQuery,
    List<Map<String, dynamic>> products,
    ConversationContext context,
    List<String> categories,
    List<Map<String, String>> chatHistory,
  ) {
    final categorySection = categories.isNotEmpty
        ? '''

AVAILABLE CATEGORIES (${categories.length} total):
${categories.join(', ')}
'''
        : '';

    final historySection = chatHistory.isNotEmpty
        ? '''

CONVERSATION HISTORY (Last ${chatHistory.length > 5 ? 5 : chatHistory.length} messages):
${_formatChatHistory(chatHistory)}
'''
        : '';

    return '''
You are a smart AI shopping assistant. Be helpful, conversational, and proactive like ChatGPT.

$categorySection$historySection
AVAILABLE PRODUCTS (${products.length} items):
${_formatProducts(products)}

USER CONTEXT:
- Recently viewed: ${context.categoryPreferences.isNotEmpty ? context.categoryPreferences.join(', ') : 'None'}
- Wishlist: ${context.wishlistProductIds.length} items
- Cart: ${context.cartProductIds.length} items

USER QUERY: "$userQuery"

YOUR JOB:
1. Understand what the user wants (be smart, not literal)
2. Recommend 3-5 products that make sense
3. Be conversational and helpful
4. Don't ask unnecessary clarifying questions - just help!

QUERY INTERPRETATION:
- "best products" → Recommend highest-rated products from various categories
- "gift ideas" → Suggest popular items that make good gifts
- "watches" → Show watches only
- "under \$50" → Filter by price
- "trending" → Show popular/high-rated items
- General queries → Use your best judgment to help

RULES:
✅ Be smart and helpful like ChatGPT
✅ Recommend products that exist in the AVAILABLE PRODUCTS list
✅ For vague queries, pick good products without asking clarification
✅ For specific items (watches, phones), filter strictly
✅ Always return valid JSON

RESPONSE FORMAT:
{
  "message": "Friendly, helpful response",
  "productIds": ["id1", "id2", "id3"],
  "reasoning": "Brief explanation"
}

EXAMPLES:

"find me the best products"
→ {"message": "Here are our top-rated products! These are customer favorites with excellent reviews. 🌟", "productIds": ["prod1", "prod2", "prod3"], "reasoning": "Highest-rated products across categories"}

"gift ideas"
→ {"message": "Perfect gift ideas! These items are popular choices that people love to receive. 🎁", "productIds": ["gift1", "gift2", "gift3"], "reasoning": "Popular gift-worthy products"}

"show me watches"
→ {"message": "Check out these excellent watches! ⌚", "productIds": ["watch1", "watch2"], "reasoning": "Filtered by watches"}

"something under \$30"
→ {"message": "Great affordable picks under \$30! 💰", "productIds": ["cheap1", "cheap2"], "reasoning": "Price < \$30"}

"hello"
→ {"message": "Hi there! 👋 I can help you find products, get recommendations, or browse categories. What are you looking for?", "productIds": [], "reasoning": "Greeting"}

IMPORTANT:
- Be proactive, not passive
- Don't overthink - just recommend good products
- Only return valid JSON
''';
  }

  String _formatChatHistory(List<Map<String, String>> history) {
    final buffer = StringBuffer();
    final recentHistory = history.length > 5
        ? history.sublist(history.length - 5)
        : history;

    for (var i = 0; i < recentHistory.length; i++) {
      final msg = recentHistory[i];
      final role = msg['role'] == 'user' ? 'User' : 'Assistant';
      buffer.writeln('$role: ${msg['text']}');
    }

    return buffer.toString();
  }

  String _formatProducts(List<Map<String, dynamic>> products) {
    final buffer = StringBuffer();
    final limit = products.length > 50 ? 50 : products.length;
    for (var i = 0; i < limit; i++) {
      final p = products[i];
      buffer.writeln(
        '- ID: ${p['id']}, Title: ${p['title']}, Price: \$${p['price']}, Category: ${p['category']}, Rating: ${p['rating']}${p['brand'] != null ? ', Brand: ${p['brand']}' : ''}',
      );
    }
    if (products.length > 50) {
      buffer.writeln('... and ${products.length - 50} more products');
    }
    return buffer.toString();
  }

  Map<String, dynamic> _parseResponse(String responseText) {
    try {
      if (responseText.isEmpty) {
        return {
          'message': "Sorry, I didn't get a response. Please try again.",
          'productIds': <String>[],
          'reasoning': '',
          'isError': true,
        };
      }

      final trimmed = responseText.trim();
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}') + 1;

      if (start == -1 || end <= start) {
        return {
          'message': trimmed.isEmpty
              ? "Sorry, I couldn't understand that. Let's try again."
              : trimmed,
          'productIds': <String>[],
          'reasoning': '',
          'isError': false,
        };
      }

      final jsonString = trimmed.substring(start, end);
      final parsed = jsonDecode(jsonString) as Map<String, dynamic>;

      // ✅ ADDED: Null safety checks
      final message = parsed['message'];
      final productIds = parsed['productIds'];
      final reasoning = parsed['reasoning'];

      return {
        'message': message is String ? message : 'Here are my recommendations!',
        'productIds': productIds is List
            ? productIds
                  .map((e) => e?.toString() ?? '')
                  .where((e) => e.isNotEmpty)
                  .toList()
            : <String>[],
        'reasoning': reasoning is String ? reasoning : '',
        'isError': false,
      };
    } catch (e, stack) {
      debugPrint('❌ Parse error: $e\nRaw response: $responseText\n$stack');
      return {
        'message':
            "Sorry, I had trouble understanding that. Could you rephrase?",
        'productIds': <String>[],
        'reasoning': 'Parse error: $e',
        'isError': true,
      };
    }
  }

  /// ✅ NEW: Validate product IDs and check if they match query
  Map<String, dynamic> _validateProductIds(
    Map<String, dynamic> response,
    List<Map<String, dynamic>> availableProducts,
    String userQuery,
  ) {
    // ✅ ADDED: Safety check for null/invalid response
    if (response['isError'] == true) {
      return response; // Don't validate if already errored
    }

    final productIds = response['productIds'];

    // ✅ ADDED: Type safety check
    if (productIds == null || productIds is! List) {
      debugPrint('⚠️ Invalid productIds type: ${productIds.runtimeType}');
      return {
        'message': response['message'] ?? 'Sorry, something went wrong.',
        'productIds': <String>[],
        'reasoning': 'Invalid product IDs format',
        'isError': false,
      };
    }

    final productIdList = productIds.cast<String>();

    if (productIdList.isEmpty) {
      return response; // No products to validate
    }
    // Create a map of valid product IDs
    final validProductMap = <String, Map<String, dynamic>>{};
    for (var product in availableProducts) {
      validProductMap[product['id'].toString()] = product;
    }

    // Extract query keyword
    final lowerQuery = userQuery.toLowerCase();
    final queryKeywords = <String>[];

    if (lowerQuery.contains('sunglass')) queryKeywords.add('sunglass');
    if (lowerQuery.contains('watch')) queryKeywords.add('watch');
    if (lowerQuery.contains('phone')) queryKeywords.add('phone');
    if (lowerQuery.contains('laptop')) queryKeywords.add('laptop');
    if (lowerQuery.contains('shirt')) queryKeywords.add('shirt');
    if (lowerQuery.contains('shoe')) queryKeywords.add('shoe');
    if (lowerQuery.contains('bag')) queryKeywords.add('bag');
    if (lowerQuery.contains('glass')) queryKeywords.add('glass');

    // Validate each product ID
    final validatedIds = <String>[];
    final invalidIds = <String>[];

    for (var id in productIds) {
      final product = validProductMap[id];

      if (product == null) {
        debugPrint(
          '⚠️ Invalid product ID: $id (not found in available products)',
        );
        invalidIds.add(id);
        continue;
      }

      // Check if product title matches query keywords
      if (queryKeywords.isNotEmpty) {
        final title = (product['title'] ?? '').toString().toLowerCase();
        final category = (product['category'] ?? '').toString().toLowerCase();

        bool matches = false;
        for (var keyword in queryKeywords) {
          if (title.contains(keyword) || category.contains(keyword)) {
            matches = true;
            break;
          }
        }

        if (matches) {
          validatedIds.add(id);
        } else {
          debugPrint(
            '⚠️ Product mismatch: ${product['title']} does not match query "$userQuery"',
          );
          invalidIds.add(id);
        }
      } else {
        validatedIds.add(id); // No specific keywords, accept any valid ID
      }
    }

    // If validation removed products, update the response
    if (invalidIds.isNotEmpty) {
      debugPrint('❌ Removed ${invalidIds.length} invalid/mismatched products');

      if (validatedIds.isEmpty) {
        // All products were invalid
        return {
          'message':
              "I apologize, but I couldn't find any products matching your request for \"$userQuery\". Could you try rephrasing or tell me what you're looking for?",
          'productIds': <String>[],
          'reasoning': 'Validation failed - no matching products found',
          'isError': false,
        };
      }

      // Some products were valid
      return {
        'message': response['message'],
        'productIds': validatedIds,
        'reasoning':
            '${response['reasoning']} (${invalidIds.length} invalid products removed)',
        'isError': false,
      };
    }

    // All products valid
    debugPrint('✅ All ${validatedIds.length} products validated successfully');
    return response;
  }

  /// Reset chat conversation
  void resetChat() {
    try {
      _initializeChat();
      _apiCallCount = 0;
      debugPrint('✅ Chat session reset');
    } catch (e) {
      debugPrint('❌ Error resetting chat: $e');
    }
  }

  /// Clear response cache
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    debugPrint('✅ Cache cleared successfully');
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return {
      'apiCallsThisSession': _apiCallCount,
      'cacheService': 'SharedPreferences',
      'cacheDuration': '24 hours',
    };
  }
}
