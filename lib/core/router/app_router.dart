import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

/// Ilova marshrutlari. Login bo'lmagani uchun faqat 2 ta yo'l: parol va bosh ekran.
/// Ichki ekranlar (mahsulot qo'shish, savdo qadamlari va h.k.) Navigator.push orqali ochiladi,
/// chunki ular bosh oqimning bir qismi va alohida deep-link talab qilmaydi.
class AppRouter {
  static GoRouter build(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isCheckingSession) return null;
        final isAuthRoute = state.matchedLocation == '/login';
        if (!authProvider.isAuthenticated && !isAuthRoute) return '/login';
        if (authProvider.isAuthenticated && isAuthRoute) return '/';
        return null;
      },
      routes: [
        GoRoute(path: '/login', builder: (context, state) => const PasswordScreen()),
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      ],
    );
  }
}
