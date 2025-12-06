import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication - In a real app, this would call an API
    if (email.isNotEmpty && password.isNotEmpty) {
      _user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0],
      );
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Please enter email and password';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name, String? phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock authentication - In a real app, this would call an API
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      _user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
        phoneNumber: phoneNumber,
      );
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Please fill all required fields';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


