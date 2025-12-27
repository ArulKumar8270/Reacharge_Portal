import '../../../../core/services/api_service.dart';

class WalletRepository {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, dynamic>> getWalletBalance() async {
    try {
      final response = await _apiService.get('/wallet/balance');
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> addMoney(double amount, String paymentMethod) async {
    try {
      final response = await _apiService.post(
        '/wallet/add-money',
        data: {
          'amount': amount,
          'paymentMethod': paymentMethod,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getTransactions({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiService.get(
        '/wallet/transactions',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> transferMoney(String toUserId, double amount) async {
    try {
      final response = await _apiService.post(
        '/wallet/transfer',
        data: {
          'toUserId': toUserId,
          'amount': amount,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

