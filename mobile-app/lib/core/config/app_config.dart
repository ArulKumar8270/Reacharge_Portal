class AppConfig {
  static const String appName = 'Nexus MI';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://nicknameinfo.net/Reacharge_Portal/api';
  // static const String baseUrl = 'http://localhost:10001/api';
  static const String apiVersion = 'v1';
  
  // Payment Gateway Keys (Replace with actual keys)
  static const String razorpayKeyId = 'YOUR_RAZORPAY_KEY_ID';
  
  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Pagination
  static const int defaultPageSize = 20;
  
  // Currency
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
}

