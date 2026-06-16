import 'package:dio/dio.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/core/network/api_constants.dart';
import 'package:vibe_tale/features/profile/data/stats_dto.dart';

/// Current-user aggregates: reading stats and achievements.
class MeRepository {
  const MeRepository(this._dio);

  final Dio _dio;

  Future<UserStats> getStats() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.myStats,
      );
      return UserStats.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.myAchievements,
      );
      final items = (response.data?['achievements'] as List<dynamic>?) ?? [];
      return items
          .cast<Map<String, dynamic>>()
          .map(Achievement.fromJson)
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
