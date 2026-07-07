import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Butun ilovani o'rab turadigan widget. Internet aloqasi yo'qolganda
/// ekranni to'liq qoplaydigan (dialog kabi) ogohlantirish ko'rsatadi va
/// foydalanuvchi boshqa hech narsa bosa olmaydi, toki aloqa tiklanmaguncha.
///
/// Ikki bosqichda tekshiradi:
/// 1) Qurilma tarmoqqa ulanganmi (Wi-Fi/mobil) — connectivity_plus orqali
/// 2) Ulangan bo'lsa ham, haqiqatan internetga chiqa oladimi — DNS so'rovi orqali
///    (chunki Wi-Fi'ga ulangan bo'lsa-yu, internet bo'lmasligi mumkin)
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _hasInternet = true;
  bool _isChecking = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _checkNow();
    _subscription = Connectivity().onConnectivityChanged.listen((_) => _checkNow());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkNow() async {
    if (_isChecking) return;
    _isChecking = true;

    final connectivityResults = await Connectivity().checkConnectivity();
    final hasNetworkInterface = !connectivityResults.contains(ConnectivityResult.none) &&
        connectivityResults.isNotEmpty;

    bool reallyOnline = false;
    if (hasNetworkInterface) {
      reallyOnline = await _hasRealInternetAccess();
    }

    if (mounted) {
      setState(() => _hasInternet = reallyOnline);
    }
    _isChecking = false;

    // Agar hali ham oflayn bo'lsa, bir necha soniyadan keyin qayta tekshiramiz —
    // shunda foydalanuvchi qo'lda "Qayta urinish" bosmasa ham, aloqa tiklanishi
    // bilan ogohlantirish avtomatik yopiladi.
    _retryTimer?.cancel();
    if (!reallyOnline) {
      _retryTimer = Timer(const Duration(seconds: 4), _checkNow);
    }
  }

  Future<bool> _hasRealInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('supabase.co').timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet)
          Positioned.fill(
            child: Material(
              color: Colors.black.withOpacity(0.6),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(28),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 32),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "Internet aloqasi yo'q",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Ilova ishlashi uchun internetga ulaning va qayta urinib ko'ring.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _checkNow,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text("Qayta urinish"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
