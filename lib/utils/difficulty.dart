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

  // 레벨업은 10초마다, 난이도는 시간 기반으로 점진적으로 계산
  factory Difficulty.forSeconds(double seconds) {
    final lv = levelFromSeconds(seconds.toInt());

    // 레벨별 확실한 체감 차이 (레벨업 순간 속도·개수 확 점프)
    double speed;
    int interval;
    int maxObs;

    switch (lv) {
      case 1: speed = 300; interval = 600; maxObs = 10; break;
      case 2: speed = 390; interval = 480; maxObs = 16; break;
      case 3: speed = 470; interval = 360; maxObs = 22; break;
      case 4: speed = 550; interval = 270; maxObs = 28; break;
      case 5: speed = 620; interval = 200; maxObs = 34; break;
      default: speed = 680; interval = 150; maxObs = 40; break;
    }

    // 레벨 내에서도 시간에 따라 조금씩 올라감 (구간 내 점진)
    final secInLevel = seconds % 10;
    speed    += secInLevel * 3.0;
    interval  = (interval - (secInLevel * 4).toInt()).clamp(170, 650);
    maxObs   += (secInLevel / 3).toInt();

    return Difficulty(
      level: lv,
      obstacleSpeed: speed.clamp(300.0, 700.0),
      spawnIntervalMs: interval,
      maxObstacles: maxObs.clamp(8, 32),
    );
  }

  // 기존 호환성 유지
  factory Difficulty.forLevel(int level) {
    return Difficulty.forSeconds(((level - 1) * 10).toDouble());
  }

  // 10초마다 레벨업
  static int levelFromSeconds(int seconds) {
    return (seconds ~/ 10) + 1;
  }
}
