/// Maps `GET /leaderboard?period=`.

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.booksRead,
    required this.pagesRead,
    required this.readingStreak,
    required this.badge,
    this.avatarUrl,
  });

  final int rank;
  final String userId;
  final String displayName;
  final int booksRead;
  final int pagesRead;
  final int readingStreak;
  final String badge;
  final String? avatarUrl;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        userId: json['user_id'] as String? ?? '',
        displayName: json['display_name'] as String? ?? 'Okuyucu',
        booksRead: (json['books_read'] as num?)?.toInt() ?? 0,
        pagesRead: (json['pages_read'] as num?)?.toInt() ?? 0,
        readingStreak: (json['reading_streak'] as num?)?.toInt() ?? 0,
        badge: json['badge'] as String? ?? '🔥',
        avatarUrl: json['avatar_url'] as String?,
      );
}

class LeaderboardData {
  const LeaderboardData({
    required this.period,
    required this.ranking,
    this.me,
  });

  final String period;
  final LeaderboardEntry? me;
  final List<LeaderboardEntry> ranking;

  factory LeaderboardData.fromJson(Map<String, dynamic> json) =>
      LeaderboardData(
        period: json['period'] as String? ?? 'all',
        me: json['me'] != null
            ? LeaderboardEntry.fromJson(json['me'] as Map<String, dynamic>)
            : null,
        ranking: ((json['ranking'] as List<dynamic>?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(LeaderboardEntry.fromJson)
            .toList(),
      );
}
