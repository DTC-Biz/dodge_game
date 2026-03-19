class ScoreManager {
  int _score = 0;
  int _elapsedSeconds = 0;
  double _accumulator = 0.0;

  int get score => _score;
  int get level => (_elapsedSeconds ~/ 10) + 1;
  int get elapsedSeconds => _elapsedSeconds;

  void update(double dt) {
    _accumulator += dt;
    if (_accumulator >= 1.0) {
      _accumulator -= 1.0;
      _elapsedSeconds++;
      _score += 10 * level; // 레벨 높을수록 점수 더 빠르게 증가
    }
  }

  void reset() {
    _score = 0;
    _elapsedSeconds = 0;
    _accumulator = 0.0;
  }
}