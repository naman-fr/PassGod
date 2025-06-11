import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    _token = response['access_token'];
    notifyListeners();
    await loadUserProfile();
  }

  Future<void> register(String email, String password, String fullName) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.register(email, password, fullName);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    if (_token != null) {
      final userData = await _apiService.getUserProfile(_token!);
      print('User profile data: $userData');
      _user = User.fromJson(userData);
      notifyListeners();
    }
  }
} 