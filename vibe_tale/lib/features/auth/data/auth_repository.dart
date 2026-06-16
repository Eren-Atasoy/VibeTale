import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_tale/core/error/auth_error.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = response.session;
      if (session == null) {
        throw const AuthFailure(AuthErrorCode.invalidCredentials);
      }
      return session;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(AuthErrorCode.network);
    }
  }

  Future<Session> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      final session = response.session;
      if (session == null) {
        // Account created but e-mail confirmation is required before login.
        throw const AuthFailure(AuthErrorCode.emailConfirmationRequired);
      }
      return session;
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure(AuthErrorCode.network);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(_mapAuthException(e));
    } catch (_) {
      throw const AuthFailure(AuthErrorCode.network);
    }
  }

  /// Classify a Supabase [AuthException] into a language-agnostic code.
  /// Supabase error messages are always English, so substring matching is
  /// stable regardless of the app's selected locale.
  AuthErrorCode _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
      return AuthErrorCode.invalidCredentials;
    }
    if (msg.contains('not confirmed') || msg.contains('email not confirmed')) {
      return AuthErrorCode.emailNotConfirmed;
    }
    if (msg.contains('already registered') ||
        msg.contains('already been registered') ||
        msg.contains('already exists')) {
      return AuthErrorCode.emailAlreadyInUse;
    }
    if (msg.contains('password') &&
        (msg.contains('weak') ||
            msg.contains('at least') ||
            msg.contains('should be'))) {
      return AuthErrorCode.weakPassword;
    }
    return AuthErrorCode.unknown;
  }
}
