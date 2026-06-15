import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibe_tale/core/network/api_constants.dart';
import 'package:vibe_tale/core/network/api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );

  return dio;
});

/// Maps a [DioException] to a domain [ApiException].
ApiException mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.badResponse:
      final status = e.response?.statusCode ?? 0;
      if (status == 401 || status == 403) return const UnauthorizedException();
      if (status == 404) return const NotFoundException();
      if (status == 422) {
        final detail = e.response?.data?['detail'];
        return ValidationException(detail?.toString() ?? 'Geçersiz veri');
      }
      return ServerException(
        e.response?.data?['detail']?.toString() ?? 'Sunucu hatası',
      );
    default:
      return const NetworkException();
  }
}
