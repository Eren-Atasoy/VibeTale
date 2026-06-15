import 'package:dio/dio.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/core/network/api_constants.dart';
import 'package:vibe_tale/features/reader/data/chunk_dto.dart';

class ReadingRepository {
  const ReadingRepository(this._dio);

  final Dio _dio;

  // ── Chunks ────────────────────────────────────────────────────────────────

  Future<List<ChunkDto>> getChunks(String bookId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        ApiConstants.bookChunks(bookId),
      );
      return (response.data ?? [])
          .cast<Map<String, dynamic>>()
          .map(ChunkDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Ambiance ──────────────────────────────────────────────────────────────

  Future<AmbianceDto> getAmbiance(String chunkId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.ambianceChunk(chunkId),
      );
      return AmbianceDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getProgress(String bookId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.readingProgress(bookId),
      );
      return response.data;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> saveProgress({
    required String bookId,
    required String currentChunkId,
    required int chapterNumber,
    required int offset,
  }) async {
    try {
      await _dio.post<void>(
        ApiConstants.saveProgress,
        queryParameters: {
          'book_id': bookId,
          'current_chunk_id': currentChunkId,
          'chapter_number': chapterNumber,
          'offset': offset,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getBookmarks(String bookId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.listBookmarks(bookId),
      );
      final items = response.data?['items'] as List<dynamic>? ?? [];
      return items.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> createBookmark({
    required String bookId,
    required String chunkId,
    String? note,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.createBookmark,
        data: {
          'book_id': bookId,
          'chunk_id': chunkId,
          if (note != null) 'note': note,
        },
      );
      return response.data!;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteBookmark(String bookmarkId) async {
    try {
      await _dio.delete<void>(ApiConstants.deleteBookmark(bookmarkId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
