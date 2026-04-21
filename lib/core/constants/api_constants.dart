class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:8083/v1';

  // Auth endpoints
  static const String verifyToken = '/auth/verify-token';

  // Product endpoints
  static const String products = '/products';
  static const String wishlist = '/wishlist';

  // Timeout
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
