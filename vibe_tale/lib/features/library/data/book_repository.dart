import 'package:dio/dio.dart';
import 'package:vibe_tale/core/network/api_constants.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/features/library/data/book_dto.dart';
import 'package:vibe_tale/features/library/domain/book_model.dart';

class BookRepository {
  const BookRepository(this._dio);

  final Dio _dio;

  Future<List<Book>> getBooks({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.books,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      final items = (response.data?['items'] as List<dynamic>?) ?? [];
      return items
          .cast<Map<String, dynamic>>()
          .map((j) => BookDto.fromJson(j).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Book> getBook(String bookId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.bookById(bookId),
      );
      return BookDto.fromJson(response.data!).toDomain();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<BookStatusDto> getBookStatus(String bookId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.bookStatus(bookId),
      );
      return BookStatusDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Book> uploadBook(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.bookUpload,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return BookDto.fromJson(response.data!).toDomain();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _dio.delete<void>(ApiConstants.deleteBook(bookId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Library (reading status + favorites) ──────────────────────────────────

  /// Books in the user's library, optionally filtered to a tab
  /// (`reading` | `completed` | `saved`).
  Future<List<Book>> getLibrary({String? status}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.library,
        queryParameters: status != null ? {'status': status} : null,
      );
      return (response.data ?? [])
          .cast<Map<String, dynamic>>()
          .map((j) => BookDto.fromJson(j).toDomain())
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Add or update a book in the library (reading status and/or favorite).
  Future<void> setLibraryState(
    String bookId, {
    String? readingStatus,
    bool? isFavorite,
  }) async {
    try {
      await _dio.put<void>(
        ApiConstants.libraryBook(bookId),
        data: {
          if (readingStatus != null) 'reading_status': readingStatus,
          if (isFavorite != null) 'is_favorite': isFavorite,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> removeFromLibrary(String bookId) async {
    try {
      await _dio.delete<void>(ApiConstants.libraryBook(bookId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
