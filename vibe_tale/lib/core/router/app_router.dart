import 'package:go_router/go_router.dart';
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

final appRouter = GoRouter(
  initialLocation: AppRoutes.login,
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
