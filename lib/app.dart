import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/widgets/loading_widget.dart';
import 'core/widgets/connectivity_wrapper.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/customers/presentation/providers/customer_provider.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'features/sales/presentation/providers/sale_provider.dart';

class MatrasApp extends StatelessWidget {
  const MatrasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkSession()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isCheckingSession) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              home: const Scaffold(body: LoadingWidget()),
              builder: (context, child) => ConnectivityWrapper(child: child ?? const SizedBox.shrink()),
            );
          }
          final router = AppRouter.build(authProvider);
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
            builder: (context, child) => ConnectivityWrapper(child: child ?? const SizedBox.shrink()),
          );
        },
      ),
    );
  }
}

