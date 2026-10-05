import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    tryAutoLogin();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      if (response != null) {
        _user = response;
        _token = response.token;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', json.encode({
          'token': _token,
          'user': _user!.toJson(),
        }));
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Connexion par code de validation
  Future<bool> loginByCode(String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.loginByCode(code);
      if (response != null) {
        _user = response;
        _token = response.token;
        
        debugPrint("DEBUG PROVIDER: Token set to $_token, User: ${_user?.nom}, Role: ${_user?.role}");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', json.encode({
          'token': _token,
          'user': _user!.toJson(),
        }));

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("LoginByCode error: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<String?> register(User user, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userData = {
        'name': '${user.nom} ${user.prenom}'.trim(),
        'nom': user.nom,
        'prenom': user.prenom,
        'email': user.email,
        'password': password,
        'password_confirmation': password,
        ...user.toJson(),
      };

      await _apiService.register(userData);
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint("Erreur Inscription Provider: $e");
      _isLoading = false;
      notifyListeners();
      return e.toString().replaceAll("Exception: ", "");
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _apiService.logout();
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    }

    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return;

    final extractedData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = extractedData['token'];
    _user = User.fromJson(extractedData['user']);
    notifyListeners();
  }

  void updateUser(User updatedUser) async {
    _user = updatedUser;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final currentData = json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      currentData['user'] = updatedUser.toJson();
      await prefs.setString('userData', json.encode(currentData));
    }
    notifyListeners();
  }
}
