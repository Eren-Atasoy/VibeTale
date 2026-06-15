import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_tale/features/auth/data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(Supabase.instance.client),
);

/// Emits the current [Session] (null when logged out).
final authSessionProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Convenience: returns the current session synchronously (may be null).
final currentSessionProvider = Provider<Session?>((ref) {
  return Supabase.instance.client.auth.currentSession;
});

// ── Auth actions notifier ─────────────────────────────────────────────────────

sealed class AuthActionState {}

final class AuthIdle extends AuthActionState {}

final class AuthLoading extends AuthActionState {}

final class AuthSuccess extends AuthActionState {}

final class AuthError extends AuthActionState {
  AuthError(this.message);
  final String message;
}

class AuthNotifier extends Notifier<AuthActionState> {
  @override
  AuthActionState build() => AuthIdle();

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signIn({required String email, required String password}) async {
    state = AuthLoading();
    try {
      await _repo.signIn(email: email, password: password);
      state = AuthSuccess();
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    state = AuthLoading();
    try {
      await _repo.signUp(email: email, password: password, username: username);
      state = AuthSuccess();
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<bool> resetPassword({required String email}) async {
    state = AuthLoading();
    try {
      await _repo.resetPasswordForEmail(email);
      state = AuthSuccess();
      return true;
    } catch (e) {
      state = AuthError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = AuthIdle();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthActionState>(
  AuthNotifier.new,
);
