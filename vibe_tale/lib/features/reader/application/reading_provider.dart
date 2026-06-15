import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/features/reader/data/chunk_dto.dart';
import 'package:vibe_tale/features/reader/data/reading_repository.dart';

final readingRepositoryProvider = Provider<ReadingRepository>(
  (ref) => ReadingRepository(ref.watch(dioProvider)),
);

final chunksProvider = FutureProvider.family<List<ChunkDto>, String>(
  (ref, bookId) => ref.watch(readingRepositoryProvider).getChunks(bookId),
);

final ambianceProvider = FutureProvider.family<AmbianceDto, String>(
  (ref, chunkId) => ref.watch(readingRepositoryProvider).getAmbiance(chunkId),
);
