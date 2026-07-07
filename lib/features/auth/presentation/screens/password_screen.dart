import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

/// Ilova ochilganda ko'rsatiladigan yagona statik parol ekrani (login/registratsiya yo'q)
class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final _controller = TextEditingController();
  bool _obscure = true;
  bool _isChecking = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isChecking = true;
      _error = null;
    });
    final success = await context.read<AuthProvider>().login(_controller.text);
    if (!mounted) return;
    setState(() => _isChecking = false);
    if (!success) {
      setState(() => _error = AppStrings.wrongPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.bed_outlined, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text(AppStrings.appName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                obscureText: _obscure,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, letterSpacing: 4),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: AppStrings.enterPassword,
                  errorText: _error,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: AppStrings.login,
                isLoading: _isChecking,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
