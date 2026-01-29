import '../../../../core/services/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, dynamic>> login(String phoneNumber, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {
          'phoneNumber': phoneNumber,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      // Return error in consistent format
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.post(
        '/auth/register',
        data: userData,
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
  
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-otp',
        data: {
          'phoneNumber': phoneNumber,
          'otp': otp,
        },
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
  
  Future<Map<String, dynamic>> getUserDetails() async {
    try {
      final response = await _apiService.get('/auth/me');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }

  /// PUT /users/profile - update current user profile (name, email, profileImage)
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/users/profile', data: data);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
  
  Future<Map<String, dynamic>> forgotPassword(String phoneNumber) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password',
        data: {'phoneNumber': phoneNumber},
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
  
  Future<Map<String, dynamic>> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiService.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceFirst('Exception: ', ''),
      };
    }
  }
}

