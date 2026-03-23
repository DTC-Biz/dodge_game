class AppConstants {
  static const double playerSize = 32.0;
  static const double obstacleSize = 18.0;
  static const int freePlaysPerDay = 3;
  static const String productId = 'dodge_unlimited';
  static const String leaderboardCollection = 'leaderboard';
  static const String keyBestTime = 'best_time'; // 최고기록 저장 키

  // 런칭 대회
  static final DateTime contestStart = DateTime(2026, 5, 11);
  static final DateTime contestEnd = DateTime(2026, 5, 24, 23, 59, 59);

  static bool get isContestActive {
    final now = DateTime.now();
    return now.isAfter(contestStart) &&
        now.isBefore(contestEnd.add(const Duration(days: 1)));
  }
}