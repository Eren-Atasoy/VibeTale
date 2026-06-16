import 'package:vibe_tale/features/reader/data/chunk_dto.dart';
import 'package:vibe_tale/features/reader/data/reading_repository.dart';

/// Read-path abstraction for the immersive reader.
///
/// The reader UI depends only on this interface, so the data source can be
/// swapped between the real backend ([ApiReaderContentSource]) and bundled
/// dummy content ([DummyReaderContentSource]) without touching the UI. Both
/// emit the exact same DTOs the backend returns, so flipping
/// `kUseDummyReaderData` is the only change needed once the backend is ready.
abstract interface class ReaderContentSource {
  Future<List<ChunkDto>> getChunks(String bookId);
  Future<AmbianceDto> getAmbiance(String chunkId);
}

/// Backend-backed source — delegates to the existing [ReadingRepository].
class ApiReaderContentSource implements ReaderContentSource {
  const ApiReaderContentSource(this._repo);

  final ReadingRepository _repo;

  @override
  Future<List<ChunkDto>> getChunks(String bookId) => _repo.getChunks(bookId);

  @override
  Future<AmbianceDto> getAmbiance(String chunkId) => _repo.getAmbiance(chunkId);
}
