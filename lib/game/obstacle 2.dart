import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/theme.dart';
import '../utils/constants.dart';

enum ObstacleType { straight, curve, sine, spiral }

class Obstacle {
  Offset position;
  final double size = AppConstants.obstacleSize;
  final double speed;
  final int level;
  final ObstacleType type;

  double _currentAngle;
  double _elapsed = 0;
  bool _hasEnteredScreen = false;

  // curve용
  final double _curveSign;
  final double _curveStrength;

  // sine용
  final double _sineFreq;
  final double _sineAmplitude;
  double _sinePhase = 0;
  final Offset _sinePerp; // 사인 진동 수직 방향

  // spiral용
  double _spiralRadius;
  final double _spiralSpeed;
  double _spiralAngle;

  Obstacle({
    required this.position,
    required this.speed,
    required this.level,
    required this.type,
    required double moveAngle,
    required double curveSign,
    required double curveStrength,
    required double sineFreq,
    required double sineAmplitude,
    required Offset sinePerp,
    required double spiralRadius,
    required double spiralSpeed,
  })  : _currentAngle = moveAngle,
        _curveSign = curveSign,
        _curveStrength = curveStrength,
        _sineFreq = sineFreq,
        _sineAmplitude = sineAmplitude,
        _sinePerp = sinePerp,
        _spiralRadius = spiralRadius,
        _spiralSpeed = spiralSpeed,
        _spiralAngle = moveAngle + pi; // 중심 방향

  static int _spawnIndex = 0;

  factory Obstacle.spawn(
    Size screenSize,
    double speed,
    int level, {
    int? forceIndex,
    int? totalCount,
    bool randomDistance = false,
    ObstacleType? forceType,
  }) {
    final rng = Random();
    final cx = screenSize.width / 2;
    final cy = screenSize.height / 2;

    final baseRadius = sqrt(cx * cx + cy * cy) + 50;
    final extraRadius = randomDistance
        ? rng.nextDouble() * 150
        : rng.nextDouble() * 60;
    final radius = baseRadius + extraRadius;

    final total = totalCount ?? 8;
    final index = forceIndex ?? (_spawnIndex++ % total);

    final baseAngle = (2 * pi / total) * index;
    final jitter = (rng.nextDouble() - 0.5) * (pi / 9);
    final spawnAngle = baseAngle + jitter;

    final spawnX = cx + cos(spawnAngle) * radius;
    final spawnY = cy + sin(spawnAngle) * radius;
    final moveAngle = spawnAngle + pi;

    // 레벨에 따라 타입 비율 조정
    ObstacleType type;
    if (forceType != null) {
      type = forceType;
    } else {
      final roll = rng.nextDouble();
      if (level <= 1) {
        // Lv1: 직선만
        type = ObstacleType.straight;
      } else if (level == 2) {
        // Lv2: 직선 70% / 곡선 30%
        type = roll < 0.7 ? ObstacleType.straight : ObstacleType.curve;
      } else if (level == 3) {
        // Lv3: 직선 40% / 곡선 35% / 사인 25%
        if (roll < 0.4) type = ObstacleType.straight;
        else if (roll < 0.75) type = ObstacleType.curve;
        else type = ObstacleType.sine;
      } else if (level == 4) {
        // Lv4: 직선 20% / 곡선 30% / 사인 30% / 나선 20%
        if (roll < 0.2) type = ObstacleType.straight;
        else if (roll < 0.5) type = ObstacleType.curve;
        else if (roll < 0.8) type = ObstacleType.sine;
        else type = ObstacleType.spiral;
      } else {
        // Lv5+: 직선 10% / 곡선 25% / 사인 35% / 나선 30%
        if (roll < 0.1) type = ObstacleType.straight;
        else if (roll < 0.35) type = ObstacleType.curve;
        else if (roll < 0.70) type = ObstacleType.sine;
        else type = ObstacleType.spiral;
      }
    }

    // curve 파라미터
    final curveSign = rng.nextBool() ? 1.0 : -1.0;
    final curveStrength = (0.5 + level * 0.1).clamp(0.5, 1.5);

    // sine 파라미터 - 이동 방향에 수직인 벡터
    final sinePerpX = -sin(moveAngle);
    final sinePerpY = cos(moveAngle);
    final sineFreq = 2.5 + rng.nextDouble() * 2.0;
    final sineAmplitude = (40.0 + level * 8.0).clamp(40.0, 120.0);

    // spiral 파라미터
    final spiralRadius = radius * 0.8;
    final spiralSpeed = (1.5 + level * 0.3).clamp(1.5, 4.0)
        * (rng.nextBool() ? 1.0 : -1.0);

    return Obstacle(
      position: Offset(spawnX, spawnY),
      speed: speed,
      level: level,
      type: type,
      moveAngle: moveAngle,
      curveSign: curveSign,
      curveStrength: curveStrength,
      sineFreq: sineFreq,
      sineAmplitude: sineAmplitude,
      sinePerp: Offset(sinePerpX, sinePerpY),
      spiralRadius: spiralRadius,
      spiralSpeed: spiralSpeed,
    );
  }

  void update(double dt) {
    _elapsed += dt;
    final currentSpeed = speed + (_elapsed * level * 3).clamp(0.0, 60.0);

    switch (type) {
      case ObstacleType.straight:
        // 직선 이동
        position = Offset(
          position.dx + cos(_currentAngle) * currentSpeed * dt,
          position.dy + sin(_currentAngle) * currentSpeed * dt,
        );
        break;

      case ObstacleType.curve:
        // 시간이 지날수록 점점 휘어짐
        final curveRate = _curveSign * _curveStrength
            * (_elapsed / 2.0).clamp(0.0, 1.0);
        _currentAngle += curveRate * dt;
        position = Offset(
          position.dx + cos(_currentAngle) * currentSpeed * dt,
          position.dy + sin(_currentAngle) * currentSpeed * dt,
        );
        break;

      case ObstacleType.sine:
        // 직선 이동 + 수직 방향 사인파 진동
        _sinePhase += _sineFreq * dt;
        final sineOffset = sin(_sinePhase) * _sineAmplitude * dt;
        position = Offset(
          position.dx + cos(_currentAngle) * currentSpeed * dt
              + _sinePerp.dx * sineOffset,
          position.dy + sin(_currentAngle) * currentSpeed * dt
              + _sinePerp.dy * sineOffset,
        );
        break;

      case ObstacleType.spiral:
        // 중심을 향해 나선형으로 파고듦
        _spiralAngle += _spiralSpeed * dt;
        _spiralRadius = (_spiralRadius - currentSpeed * dt * 0.7)
            .clamp(0.0, 2000.0);
        final cx = 0.0; // 화면 중심은 spawn시 기준으로
        final cy = 0.0;
        position = Offset(
          position.dx + cos(_currentAngle) * currentSpeed * dt * 0.5
              + cos(_spiralAngle) * _spiralRadius * 0.015,
          position.dy + sin(_currentAngle) * currentSpeed * dt * 0.5
              + sin(_spiralAngle) * _spiralRadius * 0.015,
        );
        break;
    }
  }

  void checkEntered(Size screenSize) {
    if (!_hasEnteredScreen &&
        position.dx > -20 &&
        position.dx < screenSize.width + 20 &&
        position.dy > -20 &&
        position.dy < screenSize.height + 20) {
      _hasEnteredScreen = true;
    }
  }

  bool isOutOfBounds(Size screenSize) {
    if (!_hasEnteredScreen) return false;
    return position.dx < -80 ||
        position.dx > screenSize.width + 80 ||
        position.dy < -80 ||
        position.dy > screenSize.height + 80;
  }

  void draw(Canvas canvas) {
    final paint = Paint()..color = _colorForType();

    switch (type) {
      case ObstacleType.straight:
        // 기본 사각형
        final rect = Rect.fromCenter(
            center: position, width: size, height: size);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
        break;

      case ObstacleType.curve:
        // 회전된 마름모 (다이아몬드)
        final path = Path();
        final s = size * 0.6;
        path.moveTo(position.dx, position.dy - s);
        path.lineTo(position.dx + s, position.dy);
        path.lineTo(position.dx, position.dy + s);
        path.lineTo(position.dx - s, position.dy);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case ObstacleType.sine:
        // 원형
        canvas.drawCircle(position, size * 0.5, paint);
        // 중심 십자선
        final linePaint = Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 1.5;
        canvas.drawLine(
          Offset(position.dx - 5, position.dy),
          Offset(position.dx + 5, position.dy),
          linePaint,
        );
        canvas.drawLine(
          Offset(position.dx, position.dy - 5),
          Offset(position.dx, position.dy + 5),
          linePaint,
        );
        break;

      case ObstacleType.spiral:
        // 삼각형
        final path = Path();
        final s = size * 0.65;
        path.moveTo(position.dx, position.dy - s);
        path.lineTo(position.dx + s * 0.87, position.dy + s * 0.5);
        path.lineTo(position.dx - s * 0.87, position.dy + s * 0.5);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  Color _colorForType() {
    switch (type) {
      case ObstacleType.straight:
        return AppTheme.obstacle; // 흰색
      case ObstacleType.curve:
        return const Color(0xFF00CFFF); // 하늘색
      case ObstacleType.sine:
        return const Color(0xFFFFD700); // 골드
      case ObstacleType.spiral:
        return const Color(0xFFFF4466); // 핑크레드
    }
  }

  Rect get bounds =>
      Rect.fromCenter(center: position, width: size - 2, height: size - 2);
}
