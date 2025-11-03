class ConversationContext {
  final String userId;
  final List<String> recentlyViewedProductIds;
  final List<String> wishlistProductIds;
  final List<String> cartProductIds;
  final List<String> categoryPreferences;
  final double? minPricePreference;
  final double? maxPricePreference;

  ConversationContext({
    required this.userId,
    this.recentlyViewedProductIds = const [],
    this.wishlistProductIds = const [],
    this.cartProductIds = const [],
    this.categoryPreferences = const [],
    this.minPricePreference,
    this.maxPricePreference,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'recentlyViewedProductIds': recentlyViewedProductIds,
      'wishlistProductIds': wishlistProductIds,
      'cartProductIds': cartProductIds,
      'categoryPreferences': categoryPreferences,
      'minPricePreference': minPricePreference,
      'maxPricePreference': maxPricePreference,
    };
  }
}
