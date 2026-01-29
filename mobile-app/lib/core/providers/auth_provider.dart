import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  
  AuthProvider() {
    _checkAuthStatus();
  }
  
  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        // Verify token by fetching user details
        final response = await _authRepository.getUserDetails();
        if (response['success'] == true) {
          _user = UserModel.fromJson(response['data']);
          _isAuthenticated = true;
        } else {
          // Token is invalid, clear it
          await prefs.remove('auth_token');
          _isAuthenticated = false;
          _user = null;
        }
      } else {
        _isAuthenticated = false;
        _user = null;
      }
    } catch (e) {
      // If there's an error, clear auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _isAuthenticated = false;
      _user = null;
      _error = null; // Don't show error on startup check
    }
    notifyListeners();
  }
  
  Future<bool> login(String phoneNumber, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authRepository.login(phoneNumber, password);
      if (response['success'] == true) {
        _user = UserModel.fromJson(response['data']['user']);
        _isAuthenticated = true;
        
        // Save token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['data']['token']);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authRepository.register(userData);
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authRepository.verifyOtp(phoneNumber, otp);
      if (response['success'] == true) {
        _user = UserModel.fromJson(response['data']['user']);
        _isAuthenticated = true;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['data']['token']);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'OTP verification failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> getUserDetails() async {
    try {
      final response = await _authRepository.getUserDetails();
      if (response['success'] == true) {
        _user = UserModel.fromJson(response['data']);
        _isAuthenticated = true;
        notifyListeners();
      } else {
        // If getting user details fails, user is not authenticated
        _isAuthenticated = false;
        _user = null;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, clear auth state
      _isAuthenticated = false;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update profile (name, email, profileImage). Returns true on success.
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _error = null;
    notifyListeners();
    try {
      final response = await _authRepository.updateProfile(data);
      if (response['success'] == true && response['data'] != null) {
        _user = UserModel.fromJson(response['data']);
        notifyListeners();
        return true;
      }
      _error = response['message'] ?? 'Update failed';
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> forgotPassword(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authRepository.forgotPassword(phoneNumber);
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to send OTP';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<bool> resetPassword(String otp, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authRepository.resetPassword(otp, newPassword);
      if (response['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Password reset failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}

