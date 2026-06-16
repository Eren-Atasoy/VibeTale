import 'package:dio/dio.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/core/network/api_constants.dart';
import 'package:vibe_tale/features/stats/data/leaderboard_dto.dart';

class LeaderboardRepository {
  const LeaderboardRepository(this._dio);

  final Dio _dio;

  /// [period] is 'week' | 'month' | 'all'.
  Future<LeaderboardData> getLeaderboard(String period) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.leaderboard,
        queryParameters: {'period': period},
      );
      return LeaderboardData.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
