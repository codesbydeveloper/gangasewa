import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/profile_setup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/verification_screen.dart';
import '../../features/bookings/screens/booking_detail_screen.dart';
import '../../features/bookings/screens/bookings_screen.dart';
import '../../features/bookings/screens/cancel_booking_screen.dart';
import '../../features/bookings/screens/create_booking_screen.dart';
import '../../features/bookings/screens/edit_booking_screen.dart';
import '../../features/bookings/screens/reschedule_booking_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/payments/screens/add_bank_screen.dart';
import '../../features/payments/screens/add_upi_screen.dart';
import '../../features/payments/screens/payment_methods_screen.dart';
import '../../features/profile/screens/availability_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/service_form_screen.dart';
import '../../features/profile/screens/services_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/recording/screens/record_entry_screen.dart';
import '../../features/recording/screens/recording_camera_screen.dart';
import '../../features/recording/screens/recording_preview_screen.dart';
import '../../features/recording/screens/upload_progress_screen.dart';
import '../../features/recording/screens/upload_success_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/transactions/screens/transaction_detail_screen.dart';
import '../../features/transactions/screens/transactions_screen.dart';
import '../../features/videos/screens/my_videos_screen.dart';
import '../../features/videos/screens/video_detail_screen.dart';
import '../../features/videos/screens/video_player_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/wallet/screens/withdraw_screen.dart';
import '../../features/wallet/screens/withdrawal_success_screen.dart';
import '../../services/auth_repository.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  // Do NOT watch auth state here — that recreates GoRouter on every loading
  // toggle and resets navigation (e.g. Login → OTP never sticks).
  final refresh = _AuthRefresh(ref);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authRepositoryProvider);
      final loc = state.matchedLocation;

      // Ignore loading flags for redirects except splash bootstrap.
      if (auth.isLoading && loc == '/splash') return null;

      final isAuth = auth.isAuthenticated;
      final seenOnboarding = auth.hasSeenOnboarding;
      final isSplash = loc == '/splash';
      final isOnboarding = loc == '/onboarding';
      final isAuthRoute = loc == '/login' ||
          loc == '/otp' ||
          loc == '/profile-setup' ||
          loc == '/verification' ||
          loc == '/verification-approved';

      if (isSplash) {
        if (!seenOnboarding) return '/onboarding';
        if (!isAuth) return '/login';
        final pandit = auth.pandit;
        if (pandit != null &&
            (pandit.name.isEmpty ||
                pandit.verificationStatus.name == 'pending' &&
                    !pandit.isVerified &&
                    auth.isNewUser)) {
          return '/profile-setup';
        }
        return '/home';
      }

      if (!seenOnboarding && !isOnboarding) return '/onboarding';
      if (seenOnboarding && isOnboarding) return isAuth ? '/home' : '/login';

      if (!isAuth && !isAuthRoute && !isOnboarding) return '/login';
      if (isAuth && (loc == '/login' || loc == '/otp')) {
        final p = auth.pandit;
        if (p != null && p.name.isEmpty) return '/profile-setup';
        if (p != null && !p.isVerified && auth.isNewUser) return '/verification';
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(phone: state.extra as String? ?? ''),
      ),
      GoRoute(path: '/profile-setup', builder: (_, _) => const ProfileSetupScreen()),
      GoRoute(path: '/verification', builder: (_, _) => const VerificationScreen()),
      GoRoute(
        path: '/verification-approved',
        builder: (_, _) => const VerificationApprovedScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, _) => const DashboardScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/bookings', builder: (_, _) => const BookingsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/record',
                builder: (_, _) => const RecordEntryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/wallet', builder: (_, _) => const WalletScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: [
              GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/bookings/:id',
        builder: (_, state) => BookingDetailScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/bookings-create', builder: (_, _) => const CreateBookingScreen()),
      GoRoute(
        path: '/bookings/:id/edit',
        builder: (_, state) => EditBookingScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/bookings/:id/cancel',
        builder: (_, state) => CancelBookingScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/bookings/:id/reschedule',
        builder: (_, state) => RescheduleBookingScreen(bookingId: state.pathParameters['id']!),
      ),
      // Full-screen camera — kept OUTSIDE the IndexedStack shell so the
      // camera is not initialized when Home/Wallet/Profile load.
      GoRoute(
        path: '/recording',
        builder: (_, _) => const RecordingCameraScreen(),
      ),
      GoRoute(
        path: '/recording/:bookingId',
        builder: (_, state) => RecordingCameraScreen(
          bookingId: state.pathParameters['bookingId'],
        ),
      ),
      GoRoute(
        path: '/record-preview',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return RecordingPreviewScreen(
            bookingId: extra['bookingId'] as String? ?? '',
            bookingNumber: extra['bookingNumber'] as String? ?? '',
            path: extra['path'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/upload-progress/:videoId',
        builder: (_, state) =>
            UploadProgressScreen(videoId: state.pathParameters['videoId']!),
      ),
      GoRoute(
        path: '/upload-success/:videoId',
        builder: (_, state) =>
            UploadSuccessScreen(videoId: state.pathParameters['videoId']!),
      ),
      GoRoute(path: '/videos', builder: (_, _) => const MyVideosScreen()),
      GoRoute(
        path: '/videos/:id',
        builder: (_, state) => VideoDetailScreen(videoId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/videos/:id/player',
        builder: (_, state) => VideoPlayerScreen(videoId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/transactions', builder: (_, _) => const TransactionsScreen()),
      GoRoute(
        path: '/transactions/:id',
        builder: (_, state) =>
            TransactionDetailScreen(transactionId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/withdraw', builder: (_, _) => const WithdrawScreen()),
      GoRoute(
        path: '/withdraw-success',
        builder: (_, state) => WithdrawalSuccessScreen(
          amount: (state.extra as num?)?.toDouble() ?? 0,
        ),
      ),
      GoRoute(path: '/payment-methods', builder: (_, _) => const PaymentMethodsScreen()),
      GoRoute(path: '/add-bank', builder: (_, _) => const AddBankScreen()),
      GoRoute(path: '/add-upi', builder: (_, _) => const AddUpiScreen()),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: '/edit-profile', builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: '/services', builder: (_, _) => const ServicesScreen()),
      GoRoute(
        path: '/services/form',
        builder: (_, state) => ServiceFormScreen(serviceId: state.extra as String?),
      ),
      GoRoute(path: '/availability', builder: (_, _) => const AvailabilityScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/help', builder: (_, _) => const HelpSupportScreen()),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this.ref) {
    ref.listen(authRepositoryProvider, (_, _) => notifyListeners());
  }
  final Ref ref;
}
