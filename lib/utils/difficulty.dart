class Difficulty {
  final int level;
  final double obstacleSpeed;
  final int spawnIntervalMs;
  final int maxObstaclesOnScreen;

  const Difficulty({
    required this.level,
    required this.obstacleSpeed,
    required this.spawnIntervalMs,
    required this.maxObstaclesOnScreen,
  });

  // 레벨별 난이도 자동 계산
  factory Difficulty.forLevel(int level) {
    return Difficulty(
      level: level,
      obstacleSpeed: 180.0 + (level - 1) * 30.0,   // 레벨마다 속도 +30
      spawnIntervalMs: (1200 - (level - 1) * 80).clamp(400, 1200), // 최소 0.4초
      maxObstaclesOnScreen: (3 + level).clamp(3, 12),
    );
  }

  // 경과 시간(초)으로 레벨 계산
  static int levelFromSeconds(int seconds) {
    return (seconds ~/ 10) + 1; // 10초마다 레벨업
  }
}