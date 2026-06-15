/// Represents a single text chunk from `GET /books/{id}/chunks`.
class ChunkDto {
  const ChunkDto({
    required this.chunkId,
    required this.sequence,
    required this.content,
    this.chapterId,
    this.chapterNumber,
    this.hasAudio = false,
    this.hasImage = false,
  });

  final String chunkId;
  final int sequence;
  final String content;
  final String? chapterId;
  final int? chapterNumber;
  final bool hasAudio;
  final bool hasImage;

  factory ChunkDto.fromJson(Map<String, dynamic> json) => ChunkDto(
        chunkId: json['chunk_id'] as String,
        sequence: json['sequence'] as int? ?? 0,
        content: json['content'] as String? ?? '',
        chapterId: json['chapter_id'] as String?,
        chapterNumber: json['chapter_number'] as int?,
        hasAudio: json['has_audio'] as bool? ?? false,
        hasImage: json['has_image'] as bool? ?? false,
      );
}

/// Represents a single ambiance response from `GET /ambiance/chunk/{id}`.
class AmbianceDto {
  const AmbianceDto({
    required this.chunkId,
    this.scene,
    this.emotion,
    this.audioUrl,
    this.imageUrl,
  });

  final String chunkId;
  final String? scene;
  final String? emotion;
  final String? audioUrl;
  final String? imageUrl;

  factory AmbianceDto.fromJson(Map<String, dynamic> json) => AmbianceDto(
        chunkId: json['chunk_id'] as String,
        scene: json['scene'] as String?,
        emotion: json['emotion'] as String?,
        audioUrl: json['audio_url'] as String?,
        imageUrl: json['image_url'] as String?,
      );
}
