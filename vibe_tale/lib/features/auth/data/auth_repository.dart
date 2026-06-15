import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_tale/core/network/api_exception.dart';

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
      if (session == null) throw const UnauthorizedException('Giriş başarısız');
      return session;
    } on AuthException catch (e) {
      throw ValidationException(e.message);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
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
        // Email confirmation required
        throw const ValidationException(
          'Kayıt başarılı. E-postanızı doğrulayın.',
        );
      }
      return session;
    } on AuthException catch (e) {
      throw ValidationException(e.message);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const NetworkException();
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw ValidationException(e.message);
    } catch (_) {
      throw const NetworkException();
    }
  }
}
