import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

/// Root application widget configuring Theme, Localization (Arabic & English), and Navigation.
class SmartStorageApp extends StatelessWidget {
  final GoRouter? router;

  const SmartStorageApp({super.key, this.router});

  @override
  Widget build(BuildContext context) {
    final effectiveRouter = router ?? appRouter;

    return MaterialApp.router(
      title: 'Smart Storage & Video Compressor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Dark First policy
      routerConfig: effectiveRouter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
