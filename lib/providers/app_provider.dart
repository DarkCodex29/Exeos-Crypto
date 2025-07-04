import 'package:flutter/material.dart';
import '../models/cryptocurrency.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  
  List<Cryptocurrency> _cryptocurrencies = [];
  bool _isLoading = false;
  String _error = '';
  bool _isAuthenticated = false;

  List<Cryptocurrency> get cryptocurrencies => _cryptocurrencies;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> loadCryptocurrencies() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 500));
      _cryptocurrencies = await _apiService.getCryptocurrencies();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setPIN(String pin) async {
    return await _authService.setPIN(pin);
  }

  Future<bool> hasPIN() async {
    return await _authService.hasPIN();
  }

  Future<bool> verifyPIN(String pin) async {
    try {
      final isValid = await _authService.verifyPIN(pin);
      if (isValid) {
        _isAuthenticated = true;
        notifyListeners();
      }
      return isValid;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<int> getRemainingAttempts() async {
    return await _authService.getRemainingAttempts();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}