import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/preferences_service.dart';
import 'core/utils/logger.dart';
import 'core/utils/temp_file_manager.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Initializing Smart Storage & Video Compressor app...');

  // Fulfill PRD Section 5.3 Zero-Temp-Leak policy on App Launch
  try {
    final deletedStaleFiles = await TempFileManager().cleanupAllStaleTempFiles();
    AppLogger.info('Startup stale temp file sweep purged $deletedStaleFiles files.');
  } catch (e, stack) {
    AppLogger.error('Error executing startup temp cache sweep', e, stack);
  }

  // Fulfill Sprint 02 persistence requirement: bypass onboarding for returning users
  var hasCompleted = false;
  try {
    hasCompleted = await SharedPreferencesService().hasCompletedOnboarding();
    AppLogger.info('Onboarding completion status on launch: $hasCompleted');
  } catch (e) {
    AppLogger.warn('Error reading onboarding status on launch: $e');
  }

  final dynamicRouter = createAppRouter(
    initialLocation: hasCompleted ? '/dashboard' : '/onboarding',
  );

  runApp(
    ProviderScope(
      child: SmartStorageApp(router: dynamicRouter),
    ),
  );
}
