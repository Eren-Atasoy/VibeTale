/// Maps `GET /me/stats` and `GET /me/achievements`.

class DayActivity {
  const DayActivity({required this.day, required this.minutes});

  final String day;
  final int minutes;

  factory DayActivity.fromJson(Map<String, dynamic> json) => DayActivity(
        day: json['day'] as String? ?? '',
        minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      );
}

class UserStats {
  const UserStats({
    required this.booksRead,
    required this.booksCompleted,
    required this.totalReadingMinutes,
    required this.pagesRead,
    required this.readingStreakDays,
    required this.weeklyActivity,
  });

  final int booksRead;
  final int booksCompleted;
  final int totalReadingMinutes;
  final int pagesRead;
  final int readingStreakDays;
  final List<DayActivity> weeklyActivity;

  int get totalReadingHours => (totalReadingMinutes / 60).floor();
  int get weekTotalMinutes =>
      weeklyActivity.fold(0, (sum, d) => sum + d.minutes);

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        booksRead: (json['books_read'] as num?)?.toInt() ?? 0,
        booksCompleted: (json['books_completed'] as num?)?.toInt() ?? 0,
        totalReadingMinutes:
            (json['total_reading_minutes'] as num?)?.toInt() ?? 0,
        pagesRead: (json['pages_read'] as num?)?.toInt() ?? 0,
        readingStreakDays: (json['reading_streak_days'] as num?)?.toInt() ?? 0,
        weeklyActivity: ((json['weekly_activity'] as List<dynamic>?) ?? [])
            .cast<Map<String, dynamic>>()
            .map(DayActivity.fromJson)
            .toList(),
      );
}

class Achievement {
  const Achievement({
    required this.key,
    required this.earned,
    required this.progress,
  });

  final String key;
  final bool earned;
  final double progress;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        key: json['key'] as String? ?? '',
        earned: json['earned'] as bool? ?? false,
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
      );
}
