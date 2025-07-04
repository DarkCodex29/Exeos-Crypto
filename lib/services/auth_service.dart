import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _pinKey = 'user_pin';
  static const String _attemptsKey = 'failed_attempts';
  static const String _lockoutKey = 'lockout_time';
  static const int maxAttempts = 3;
  static const int lockoutMinutes = 15;

  Future<bool> setPIN(String pin) async {
    if (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      return false;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
    await prefs.setInt(_attemptsKey, 0);
    return true;
  }

  Future<bool> hasPIN() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinKey);
  }

  Future<bool> verifyPIN(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString(_pinKey);
    
    if (storedPin == null) return false;
    
    if (await _isLockedOut()) {
      throw Exception('Account locked. Try again later.');
    }
    
    if (storedPin == pin) {
      await prefs.setInt(_attemptsKey, 0);
      return true;
    } else {
      await _incrementFailedAttempts();
      return false;
    }
  }

  Future<void> _incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_attemptsKey) ?? 0;
    final newAttempts = attempts + 1;
    
    await prefs.setInt(_attemptsKey, newAttempts);
    
    if (newAttempts >= maxAttempts) {
      final lockoutTime = DateTime.now().add(Duration(minutes: lockoutMinutes));
      await prefs.setString(_lockoutKey, lockoutTime.toIso8601String());
    }
  }

  Future<bool> _isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockoutTimeString = prefs.getString(_lockoutKey);
    
    if (lockoutTimeString == null) return false;
    
    final lockoutTime = DateTime.parse(lockoutTimeString);
    final now = DateTime.now();
    
    if (now.isBefore(lockoutTime)) {
      return true;
    } else {
      await prefs.remove(_lockoutKey);
      await prefs.setInt(_attemptsKey, 0);
      return false;
    }
  }

  Future<int> getRemainingAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_attemptsKey) ?? 0;
    return maxAttempts - attempts;
  }

  Future<void> clearPIN() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.remove(_attemptsKey);
    await prefs.remove(_lockoutKey);
  }
}