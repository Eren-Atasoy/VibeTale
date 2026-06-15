import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_tale/features/auth/application/auth_provider.dart';
import 'package:vibe_tale/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:vibe_tale/features/auth/presentation/screens/login_screen.dart';
import 'package:vibe_tale/features/auth/presentation/screens/signup_screen.dart';
import 'package:vibe_tale/features/book_details/presentation/screens/book_details_screen.dart';
import 'package:vibe_tale/features/file_upload/presentation/screens/file_upload_screen.dart';
import 'package:vibe_tale/features/home/presentation/screens/home_screen.dart';
import 'package:vibe_tale/features/library/presentation/screens/library_screen.dart';
import 'package:vibe_tale/features/profile/presentation/screens/profile_screen.dart';
import 'package:vibe_tale/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:vibe_tale/features/reader/presentation/screens/immersive_read_screen.dart';
import 'package:vibe_tale/features/stats/presentation/screens/reading_stats_screen.dart';
import 'package:vibe_tale/features/vibe_engine/presentation/screens/vibe_analysis_screen.dart';

abstract final class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String library = '/library';
  static const String bookDetails = '/book/:bookId';
  static const String fileUpload = '/upload';
  static const String vibeAnalysis = '/vibe-analysis/:bookId';
  static const String immersiveRead = '/read/:bookId';
  static const String stats = '/stats';
  static const String profile = '/profile';
  static const String profileSettings = '/profile/settings';
}

// Bridges Supabase auth stream → GoRouter's refreshListenable
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Stream<AuthState> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.read(authRepositoryProvider);
  final notifier = _AuthChangeNotifier(authRepo.authStateChanges);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isLoggedIn =
          Supabase.instance.client.auth.currentSession != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == AppRoutes.login ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.library,
        name: 'library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookDetails,
        name: 'book-details',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return BookDetailsScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: AppRoutes.fileUpload,
        name: 'file-upload',
        builder: (context, state) => const FileUploadScreen(),
      ),
      GoRoute(
        path: AppRoutes.vibeAnalysis,
        name: 'vibe-analysis',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return VibeAnalysisScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: AppRoutes.immersiveRead,
        name: 'immersive-read',
        builder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return ImmersiveReadScreen(bookId: bookId);
        },
      ),
      GoRoute(
        path: AppRoutes.stats,
        name: 'stats',
        builder: (context, state) => const ReadingStatsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSettings,
        name: 'profile-settings',
        builder: (context, state) => const ProfileSettingsScreen(),
      ),
    ],
  );
});
