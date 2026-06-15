import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibe_tale/core/network/api_client.dart';
import 'package:vibe_tale/features/library/data/book_dto.dart';
import 'package:vibe_tale/features/library/data/book_repository.dart';
import 'package:vibe_tale/features/library/domain/book_model.dart';

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => BookRepository(ref.watch(dioProvider)),
);

final booksProvider = FutureProvider<List<Book>>((ref) {
  return ref.watch(bookRepositoryProvider).getBooks();
});

final bookProvider = FutureProvider.family<Book, String>((ref, bookId) {
  return ref.watch(bookRepositoryProvider).getBook(bookId);
});

final bookStatusProvider =
    FutureProvider.family<BookStatusDto, String>((ref, bookId) {
  return ref.watch(bookRepositoryProvider).getBookStatus(bookId);
});
