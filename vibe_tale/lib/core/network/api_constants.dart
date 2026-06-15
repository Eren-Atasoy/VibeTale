abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // Books
  static const String books = '/books';
  static String bookById(String id) => '/books/$id';
  static String bookStatus(String id) => '/books/$id/status';
  static String bookChunks(String id) => '/books/$id/chunks';
  static const String bookUpload = '/books/upload';
  static String deleteBook(String id) => '/books/$id';

  // Ambiance
  static String ambianceChunk(String chunkId) => '/ambiance/chunk/$chunkId';

  // Reading
  static String readingProgress(String bookId) => '/reading/progress/$bookId';
  static const String saveProgress = '/reading/progress';
  static const String createBookmark = '/reading/bookmarks';
  static String listBookmarks(String bookId) => '/reading/bookmarks/$bookId';
  static String deleteBookmark(String id) => '/reading/bookmarks/$id';
}
