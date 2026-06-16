import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/features/profile/data/me_repository.dart';
import 'package:vibe_tale/features/profile/data/stats_dto.dart';

final meRepositoryProvider = Provider<MeRepository>(
  (ref) => MeRepository(ref.watch(dioProvider)),
);

final statsProvider = FutureProvider<UserStats>(
  (ref) => ref.watch(meRepositoryProvider).getStats(),
);

final achievementsProvider = FutureProvider<List<Achievement>>(
  (ref) => ref.watch(meRepositoryProvider).getAchievements(),
);
