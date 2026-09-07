import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/screens/permission_screen.dart';
import '../features/onboarding/presentation/screens/quick_scan_screen.dart';
import '../features/onboarding/presentation/screens/scan_result_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/video_compressor/presentation/screens/video_picker_screen.dart';
import '../features/video_compressor/presentation/screens/compression_prepare_screen.dart';
import '../features/video_compressor/domain/models/video_asset.dart';
import '../features/screenshot_cleaner/presentation/screens/swipe_cleaner_screen.dart';
import '../features/paywall/presentation/screens/paywall_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

/// Factory creating the declarative GoRouter with dynamic initialLocation.
GoRouter createAppRouter({String initialLocation = '/onboarding'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const QuickScanScreen(),
      ),
      GoRoute(
        path: '/scan-result',
        builder: (context, state) => const ScanResultScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => const PaywallScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      // Video Compressor (primary & alias)
      GoRoute(
        path: '/video-compressor',
        builder: (context, state) => const VideoPickerScreen(),
      ),
      GoRoute(
        path: '/video-compressor/prepare',
        builder: (context, state) {
          final video = state.extra as VideoAsset?;
          final id = state.uri.queryParameters['id'] ?? video?.id ?? '';
          return CompressionPrepareScreen(assetId: id, initialVideo: video);
        },
      ),
      GoRoute(
        path: '/compressor',
        builder: (context, state) => const VideoPickerScreen(),
      ),
      GoRoute(
        path: '/compressor/prepare',
        builder: (context, state) {
          final video = state.extra as VideoAsset?;
          final id = state.uri.queryParameters['id'] ?? video?.id ?? '';
          return CompressionPrepareScreen(assetId: id, initialVideo: video);
        },
      ),
      // Screenshot Cleaner (primary & alias)
      GoRoute(
        path: '/screenshot-cleaner',
        builder: (context, state) => const SwipeCleanerScreen(),
      ),
      GoRoute(
        path: '/cleaner',
        builder: (context, state) => const SwipeCleanerScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Default global router instance
final GoRouter appRouter = createAppRouter();
