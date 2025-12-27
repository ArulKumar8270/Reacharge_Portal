import 'package:flutter/foundation.dart';
import '../../features/wallet/data/models/wallet_model.dart';
import '../../features/wallet/data/models/transaction_model.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository _walletRepository = WalletRepository();
  
  Wallet? _wallet;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  
  Wallet? get wallet => _wallet;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> getWalletBalance() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _walletRepository.getWalletBalance();
      if (response['success'] == true) {
        _wallet = Wallet.fromJson(response['data']);
      } else {
        _error = response['message'] ?? 'Failed to fetch wallet balance';
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<bool> addMoney(double amount, String paymentMethod) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _walletRepository.addMoney(amount, paymentMethod);
      if (response['success'] == true) {
        await getWalletBalance();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to add money';
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
  
  Future<void> getTransactions({int page = 1, int limit = 20}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _walletRepository.getTransactions(page: page, limit: limit);
      if (response['success'] == true) {
        _transactions = (response['data']['transactions'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
      } else {
        _error = response['message'] ?? 'Failed to fetch transactions';
      }
    } catch (e) {
      _error = e.toString();
    }
    
    _isLoading = false;
    notifyListeners();
  }
}

