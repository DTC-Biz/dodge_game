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

    double speed;
    int interval;
    int maxObs;

    if (lv <= 5) {
      // 초반 진입 구간: 확실한 체감 점프
      switch (lv) {
        case 1: speed = 300; interval = 600; maxObs = 10; break;
        case 2: speed = 390; interval = 480; maxObs = 16; break;
        case 3: speed = 470; interval = 360; maxObs = 22; break;
        case 4: speed = 550; interval = 270; maxObs = 28; break;
        default: speed = 620; interval = 200; maxObs = 34; break;
      }
    } else {
      // 레벨 6부터 무한 스케일링 (10초마다 계속 강해짐)
      final extra = lv - 6;
      speed    = 680 + extra * 45.0;
      interval = (150 - extra * 8).clamp(70, 150);
      maxObs   = 40 + extra * 4;
    }

    // 레벨 내에서도 시간에 따라 조금씩 올라감 (구간 내 점진)
    final secInLevel = seconds % 10;
    speed    += secInLevel * 3.0;
    interval  = (interval - (secInLevel * 3).toInt()).clamp(70, 650);
    maxObs   += (secInLevel / 3).toInt();

    return Difficulty(
      level: lv,
      obstacleSpeed: speed.clamp(300.0, 1200.0),
      spawnIntervalMs: interval,
      maxObstacles: maxObs.clamp(8, 80),
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
