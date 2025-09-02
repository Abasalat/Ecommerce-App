class ApiEndpoints {
  // Base URL for DummyJSON
  static const String baseUrl = 'https://dummyjson.com';

  // Product Endpoints
  static const String getAllProducts = '/products';
  static const String getLimitedProducts = '/products?limit='; // + number
  static const String getSingleProduct = '/products/'; // + productId
  static const String getProductsByCategory =
      '/products/category/'; // + categoryName

  // Category Endpoints
  static const String getAllCategories = '/products/categories';

  // Complete URLs for easy access
  static String get allProductsUrl => '$baseUrl$getAllProducts';
  static String get allCategoriesUrl => '$baseUrl$getAllCategories';

  // Dynamic URL builders
  static String limitedProductsUrl(int limit) =>
      '$baseUrl$getLimitedProducts$limit';
  static String singleProductUrl(int productId) =>
      '$baseUrl$getSingleProduct$productId';
  static String categoryProductsUrl(String category) =>
      '$baseUrl$getProductsByCategory$category';

  // Request Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Request Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
