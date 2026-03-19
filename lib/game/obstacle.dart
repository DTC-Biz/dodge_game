import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/theme.dart';
import '../utils/constants.dart';

class Obstacle {
  Offset position;
  final double size = AppConstants.obstacleSize;
  final double speed;
  final int level;
  double _currentAngle;
  double _curveAmount = 0.0;
  double _elapsed = 0;
  final double _curveStartAt;
  final double _curveSign;
  bool _hasEnteredScreen = false;

  Obstacle({
    required this.position,
    required this.speed,
    required this.level,
    required double moveAngle,
    required double curveStartAt,
    required double curveSign,
  })  : _currentAngle = moveAngle,
        _curveStartAt = curveStartAt,
        _curveSign = curveSign;

  static int _spawnIndex = 0;

  factory Obstacle.spawn(
    Size screenSize,
    double speed,
    int level, {
    int? forceIndex,
    int? totalCount,
    bool randomDistance = false, // 거리 랜덤화 여부
  }) {
    final rng = Random();
    final cx = screenSize.width / 2;
    final cy = screenSize.height / 2;

    // 기본 반지름 + 랜덤 거리 추가로 도착 시간 분산
    final baseRadius = sqrt(cx * cx + cy * cy) + 50;
    final extraRadius = randomDistance
        ? rng.nextDouble() * 150 // 0~150px 추가 거리 (도착 시간 분산)
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

    final curveStart = level >= 4 ? 1.0 + rng.nextDouble() * 1.0 : 9999.0;
    final curveSign = rng.nextBool() ? 1.0 : -1.0;

    return Obstacle(
      position: Offset(spawnX, spawnY),
      speed: speed,
      level: level,
      moveAngle: moveAngle,
      curveStartAt: curveStart,
      curveSign: curveSign,
    );
  }

  void update(double dt) {
    _elapsed += dt;

    if (_elapsed > _curveStartAt) {
      final progress = ((_elapsed - _curveStartAt) / 2.0).clamp(0.0, 1.0);
      _curveAmount =
          _curveSign * progress * (0.4 + level * 0.04).clamp(0.4, 1.2);
    }

    _currentAngle += _curveAmount * dt;
    final currentSpeed = speed + (_elapsed * level * 4).clamp(0.0, 80.0);

    position = Offset(
      position.dx + cos(_currentAngle) * currentSpeed * dt,
      position.dy + sin(_currentAngle) * currentSpeed * dt,
    );
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
    return position.dx < -60 ||
        position.dx > screenSize.width + 60 ||
        position.dy < -60 ||
        position.dy > screenSize.height + 60;
  }

  void draw(Canvas canvas) {
    final rect = Rect.fromCenter(center: position, width: size, height: size);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = _colorForLevel(),
    );
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(position.dx - 4, position.dy),
        Offset(position.dx + 4, position.dy), paint);
    canvas.drawLine(Offset(position.dx, position.dy - 4),
        Offset(position.dx, position.dy + 4), paint);
  }

  Color _colorForLevel() {
    if (level >= 10) return const Color(0xFFFF00FF);
    if (level >= 7) return const Color(0xFFFF6600);
    if (level >= 4) return const Color(0xFFFF3333);
    return AppTheme.obstacle;
  }

  Rect get bounds =>
      Rect.fromCenter(center: position, width: size - 2, height: size - 2);
}