sealed class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends ApiException {
  const NetworkException([super.message = 'İnternet bağlantınızı kontrol edin']);
}

final class UnauthorizedException extends ApiException {
  const UnauthorizedException([super.message = 'Oturum süresi dolmuş, lütfen tekrar giriş yapın']);
}

final class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Kaynak bulunamadı']);
}

final class ServerException extends ApiException {
  const ServerException([super.message = 'Sunucu hatası, lütfen daha sonra tekrar deneyin']);
}

final class ValidationException extends ApiException {
  const ValidationException(super.message);
}
