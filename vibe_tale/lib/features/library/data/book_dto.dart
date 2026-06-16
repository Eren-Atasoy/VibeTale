import 'package:vibe_tale/features/library/domain/book_model.dart';

/// Maps the backend `BookResponse` JSON to the Flutter [Book] domain model.
class BookDto {
  const BookDto({
    required this.id,
    required this.title,
    required this.author,
    this.coverUrl,
    this.processingStatus,
    this.auditResult,
    this.format,
    this.uploadDate,
    this.lastReadDate,
    this.genre,
    this.description,
    this.totalPages,
  });

  final String id;
  final String title;
  final String author;
  final String? coverUrl;
  final String? processingStatus;
  final String? auditResult;
  final String? format;
  final String? uploadDate;
  final String? lastReadDate;
  final String? genre;
  final String? description;
  final int? totalPages;

  factory BookDto.fromJson(Map<String, dynamic> json) => BookDto(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Başlıksız',
        author: json['author'] as String? ?? 'Bilinmeyen Yazar',
        coverUrl: json['cover_url'] as String?,
        processingStatus: json['processing_status'] as String?,
        auditResult: json['audit_result'] as String?,
        format: json['format'] as String?,
        uploadDate: json['upload_date'] as String?,
        lastReadDate: json['last_read_date'] as String?,
        genre: json['genre'] as String?,
        description: json['description'] as String?,
        totalPages: json['total_pages'] as int?,
      );

  Book toDomain() => Book(
        id: id,
        title: title,
        author: author,
        genre: genre ?? _deriveGenre(),
        coverUrl: coverUrl ?? 'https://picsum.photos/seed/$id/400/600',
        synopsis: description ?? auditResult ?? '',
        pageCount: totalPages ?? 0,
        isNew: _isRecent(),
      );

  String _deriveGenre() {
    switch (format?.toLowerCase()) {
      case 'pdf':
        return 'PDF';
      case 'epub':
        return 'E-Kitap';
      case 'docx':
      case 'doc':
        return 'Belge';
      default:
        return 'Genel';
    }
  }

  bool _isRecent() {
    if (uploadDate == null) return false;
    try {
      final date = DateTime.parse(uploadDate!);
      return DateTime.now().difference(date).inDays <= 7;
    } catch (_) {
      return false;
    }
  }
}

/// Maps the `GET /books/{id}/status` response.
class BookStatusDto {
  const BookStatusDto({
    required this.bookId,
    required this.processingStatus,
    this.auditResult,
  });

  final String bookId;
  final String processingStatus;
  final String? auditResult;

  factory BookStatusDto.fromJson(Map<String, dynamic> json) => BookStatusDto(
        bookId: json['book_id'] as String,
        processingStatus: json['processing_status'] as String,
        auditResult: json['audit_result'] as String?,
      );

  bool get isCompleted => processingStatus == 'completed';
  bool get isFailed => processingStatus == 'failed';
  bool get isProcessing =>
      processingStatus == 'processing' || processingStatus == 'pending';
}
