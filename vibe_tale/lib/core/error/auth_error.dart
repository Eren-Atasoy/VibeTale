/// Semantic authentication error codes.
///
/// The repository layer maps Supabase [AuthException]s to one of these codes,
/// and the UI localizes them via `AppStrings.authErrorMessage` so toast text
/// follows the selected language instead of leaking raw provider strings.
enum AuthErrorCode {
  invalidCredentials,
  emailNotConfirmed,
  emailAlreadyInUse,
  weakPassword,

  /// Sign-up succeeded but the account needs e-mail confirmation before login.
  /// Treated as a (positive) pending state rather than a hard failure.
  emailConfirmationRequired,
  network,
  unknown,
}

/// Exception carrying a semantic [AuthErrorCode] so the presentation layer can
/// render a localized message.
class AuthFailure implements Exception {
  const AuthFailure(this.code);

  final AuthErrorCode code;

  @override
  String toString() => 'AuthFailure($code)';
}
