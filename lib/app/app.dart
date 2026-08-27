import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/routes/app_router.dart';
import '../config/theme/app_theme.dart';
import '../config/constants/app_constants.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/profile/presentation/providers/profile_provider.dart';
import '../features/portfolio/presentation/providers/portfolio_provider.dart';

class SkilloraApp extends StatelessWidget {
  const SkilloraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
