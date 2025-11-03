import 'package:ecommerce_app/data/models/chat_message_model.dart';
import 'package:ecommerce_app/data/models/conversation_context.dart';
import 'package:ecommerce_app/data/services/chat_storage_service.dart';
import 'package:ecommerce_app/data/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatbotViewModel extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final ChatStorageService _storageService = ChatStorageService();

  List<ChatMessageModel> _messages = [];
  bool _isTyping = false;
  bool _isLoading = true;
  String? _userId;
  ConversationContext? _context;
  List<Map<String, dynamic>> _cachedProducts = [];
  List<String> _availableCategories = [];

  List<ChatMessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;

  // ✅ NEW: Check if chat is empty
  bool get isChatEmpty => _messages.isEmpty;

  // ✅ NEW: API monitoring
  int get apiCallCount => _geminiService.apiCallCount;

  Future<void> initialize(
    String userId,
    List<Map<String, dynamic>> products, {
    List<String> categories = const [],
  }) async {
    _userId = userId;
    _cachedProducts = products;
    _availableCategories = categories;

    // Load chat history first
    _messages = await _storageService.loadChatHistory(userId);
    _context =
        await _storageService.loadConversationContext(userId) ??
        ConversationContext(userId: userId);

    // ✅ REMOVED: No automatic welcome message
    // User will see suggestion chips instead when chat is empty
    // Chat starts naturally when user clicks suggestion or types message

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, String>> _buildChatHistory() {
    // ✅ FIX: Check if messages is empty to avoid RangeError
    if (_messages.isEmpty) {
      return [];
    }

    final recentMessages = _messages.length > 10
        ? _messages.sublist(_messages.length - 10)
        : _messages;

    return recentMessages.map((msg) {
      return {'role': msg.isUser ? 'user' : 'assistant', 'text': msg.text};
    }).toList();
  }

  // ✅ OPTIMIZED: Reduced API calls with caching
  Future<void> sendMessage(String text, {bool forceRefresh = false}) async {
    if (text.trim().isEmpty || _userId == null) return;

    final userMessage = ChatMessageModel(
      id: const Uuid().v4(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    await _storageService.saveMessage(_userId!, userMessage);
    notifyListeners();

    _isTyping = true;
    notifyListeners();

    try {
      final chatHistory = _buildChatHistory();

      // ✅ Use cache by default, bypass only if forceRefresh
      final response = await _geminiService.getProductRecommendations(
        userQuery: text,
        availableProducts: _cachedProducts,
        context: _context!,
        userId: _userId!,
        categories: _availableCategories,
        chatHistory: chatHistory,
        useCache: !forceRefresh, // ✅ Respect force refresh
      );

      await Future.delayed(const Duration(milliseconds: 800));

      _isTyping = false;

      final botMessage = ChatMessageModel(
        id: const Uuid().v4(),
        text: response['message'] as String,
        isUser: false,
        timestamp: DateTime.now(),
        recommendedProductIds: response['productIds'] as List<String>?,
        type: (response['productIds'] as List<String>).isNotEmpty
            ? ChatMessageType.productRecommendation
            : ChatMessageType.text,
      );

      _messages.add(botMessage);
      await _storageService.saveMessage(_userId!, botMessage);

      // ✅ Log cache performance
      debugPrint(
        '📊 Total API calls this session: ${_geminiService.apiCallCount}',
      );

      notifyListeners();
    } catch (e) {
      _isTyping = false;
      _addBotMessage(
        "I apologize, but I'm having trouble connecting right now. Please try again in a moment.",
      );
    }
  }

  void _addBotMessage(String text) {
    if (_userId == null) {
      debugPrint('⚠️ Cannot add message: userId is null');
      return;
    }

    try {
      final message = ChatMessageModel(
        id: const Uuid().v4(),
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(message);
      _storageService.saveMessage(_userId!, message).catchError((e) {
        debugPrint('❌ Error saving message to storage: $e');
      });
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error adding bot message: $e');
    }
  }

  // ✅ UPDATED: Clear chat with optional welcome message
  Future<void> clearChat({bool showWelcome = false}) async {
    if (_userId == null) return;

    try {
      // Clear messages first
      _messages.clear();
      notifyListeners(); // ✅ Notify immediately for UI update

      // Then do async operations
      await _storageService.clearChatHistory(_userId!);
      _geminiService.resetChat();

      if (showWelcome) {
        _addBotMessage(
          "Hello! 👋 I'm your AI shopping assistant. How can I help you today?",
        );
      }
    } catch (e) {
      debugPrint('Error clearing chat: $e');
      notifyListeners();
    }
  }

  // ✅ NEW: Clear cache method
  Future<void> clearCache() async {
    try {
      await _geminiService.clearCache();
      debugPrint('✅ Cache cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  Future<void> updateContext({
    List<String>? recentlyViewed,
    List<String>? wishlist,
    List<String>? cart,
    List<String>? categories,
  }) async {
    if (_userId == null) return;

    _context = ConversationContext(
      userId: _userId!,
      recentlyViewedProductIds:
          recentlyViewed ?? _context!.recentlyViewedProductIds,
      wishlistProductIds: wishlist ?? _context!.wishlistProductIds,
      cartProductIds: cart ?? _context!.cartProductIds,
      categoryPreferences: categories ?? _context!.categoryPreferences,
    );

    await _storageService.saveConversationContext(_context!);
  }

  @override
  void dispose() {
    super.dispose();
  }
}
