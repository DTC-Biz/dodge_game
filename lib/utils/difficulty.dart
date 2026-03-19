class Difficulty {
  final int level;
  final double obstacleSpeed;
  final int spawnIntervalMs;
  final int maxObstacles;

  const Difficulty({
    required this.level,
    required this.obstacleSpeed,
    required this.spawnIntervalMs,
    required this.maxObstacles,
  });

  factory Difficulty.forLevel(int level) {
    final speed = (320.0 + (level - 1) * 35.0).clamp(320.0, 600.0);
    final interval = (700 - (level - 1) * 60).clamp(250, 700);
    final maxObs = (6 + (level - 1) * 1).clamp(6, 16);

    return Difficulty(
      level: level,
      obstacleSpeed: speed,
      spawnIntervalMs: interval,
      maxObstacles: maxObs,
    );
  }

  // 5초마다 레벨업
  static int levelFromSeconds(int seconds) {
    return (seconds ~/ 5) + 1;
  }
}