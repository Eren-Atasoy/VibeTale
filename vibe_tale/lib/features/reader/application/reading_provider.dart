import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/features/reader/data/chunk_dto.dart';
import 'package:vibe_tale/features/reader/data/dummy_reader_content_source.dart';
import 'package:vibe_tale/features/reader/data/reader_content_source.dart';
import 'package:vibe_tale/features/reader/data/reading_repository.dart';

/// Set to `false` once the backend serves real reader content + ambiance media.
/// Flipping this is the only change required to go from dummy to backend — the
/// reader UI and DTOs stay identical.
const bool kUseDummyReaderData = true;

final readingRepositoryProvider = Provider<ReadingRepository>(
  (ref) => ReadingRepository(ref.watch(dioProvider)),
);

/// The active read-path source (dummy or backend) behind [kUseDummyReaderData].
final readerContentSourceProvider = Provider<ReaderContentSource>((ref) {
  if (kUseDummyReaderData) return const DummyReaderContentSource();
  return ApiReaderContentSource(ref.watch(readingRepositoryProvider));
});

final chunksProvider = FutureProvider.family<List<ChunkDto>, String>(
  (ref, bookId) => ref.watch(readerContentSourceProvider).getChunks(bookId),
);

final ambianceProvider = FutureProvider.family<AmbianceDto, String>(
  (ref, chunkId) => ref.watch(readerContentSourceProvider).getAmbiance(chunkId),
);
