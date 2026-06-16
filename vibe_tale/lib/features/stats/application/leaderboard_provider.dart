import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/features/stats/data/leaderboard_dto.dart';
import 'package:vibe_tale/features/stats/data/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) => LeaderboardRepository(ref.watch(dioProvider)),
);

/// Leaderboard for a period: 'week' | 'month' | 'all'.
final leaderboardProvider =
    FutureProvider.family<LeaderboardData, String>((ref, period) {
  return ref.watch(leaderboardRepositoryProvider).getLeaderboard(period);
});
