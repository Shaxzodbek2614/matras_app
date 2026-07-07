import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ilovada login/registratsiya yo'q — faqat bitta statik parol tekshiriladi.
/// Parol to'g'ri kiritilgach, "eslab qolish" holati SharedPreferences'da saqlanadi,
/// shunda foydalanuvchi ilovani qayta ochganda parolni qayta kiritmaydi.
class AuthProvider extends ChangeNotifier {
  // TODO: O'zingiz xohlagan parolni shu yerga kiriting.
  static const String _correctPassword = '1234';
  static const String _prefsKey = 'is_logged_in';

  bool _isAuthenticated = false;
  bool _isCheckingSession = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingSession => _isCheckingSession;

  Future<void> checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_prefsKey) ?? false;
    _isCheckingSession = false;
    notifyListeners();
  }

  Future<bool> login(String password) async {
    if (password == _correctPassword) {
      _isAuthenticated = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, false);
    notifyListeners();
  }
}
