class ScoreManager {
  double _elapsedTime = 0.0;
  int _elapsedSeconds = 0;

  double get elapsedTime => _elapsedTime;
  int get level => (_elapsedSeconds ~/ 5) + 1;

  String get timeString {
    final totalSeconds = _elapsedTime.floor();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final millis = ((_elapsedTime - totalSeconds) * 1000).floor();

    final ms = millis.toString().padLeft(3, '0');
    final s = seconds.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final h = hours.toString();

    if (hours > 0) {
      return '$h:$m:$s.$ms';
    } else if (minutes > 0) {
      return '$m:$s.$ms';
    } else {
      return '$s.$ms';
    }
  }

  void update(double dt) {
    _elapsedTime += dt;
    _elapsedSeconds = _elapsedTime.floor();
  }

  void reset() {
    _elapsedTime = 0.0;
    _elapsedSeconds = 0;
  }
}