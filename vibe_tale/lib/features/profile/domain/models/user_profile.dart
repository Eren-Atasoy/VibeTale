/// VibeTale user profile data model.
/// Follows the same pattern as [Book] + [DummyBooks].
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.avatarUrl,
    this.booksRead = 0,
    this.booksCompleted = 0,
    this.totalReadingHours = 0.0,
    this.memberSince = '',
  });

  final String name;
  final String email;
  final String? avatarUrl;
  final int booksRead;
  final int booksCompleted;
  final double totalReadingHours;
  final String memberSince;
}

abstract final class DummyProfile {
  static const current = UserProfile(
    name: 'Eren Atasoy',
    email: 'eren@vibetale.com',
    booksRead: 12,
    booksCompleted: 4,
    totalReadingHours: 47.5,
    memberSince: 'Ocak 2025',
  );
}
