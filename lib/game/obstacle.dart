import 'package:flutter/material.dart';
import 'dart:math';
import '../utils/theme.dart';
import '../utils/constants.dart';

enum ObstacleDirection { top, bottom, left, right }

class Obstacle {
  Offset position;
  final ObstacleDirection direction;
  final double speed;
  final double size = AppConstants.obstacleSize;
  bool active = true;

  Obstacle({
    required this.position,
    required this.direction,
    required this.speed,
  });

  // 랜덤 방향으로 화면 밖에서 생성
  factory Obstacle.spawn(Size screenSize, double speed) {
    final rng = Random();
    final dir = ObstacleDirection.values[rng.nextInt(4)];
    Offset pos;

    switch (dir) {
      case ObstacleDirection.top:
        pos = Offset(rng.nextDouble() * screenSize.width, -20);
        break;
      case ObstacleDirection.bottom:
        pos = Offset(rng.nextDouble() * screenSize.width, screenSize.height + 20);
        break;
      case ObstacleDirection.left:
        pos = Offset(-20, rng.nextDouble() * screenSize.height);
        break;
      case ObstacleDirection.right:
        pos = Offset(screenSize.width + 20, rng.nextDouble() * screenSize.height);
        break;
    }
    return Obstacle(position: pos, direction: dir, speed: speed);
  }

  // 매 프레임 이동
  void update(double dt) {
    switch (direction) {
      case ObstacleDirection.top:    position += Offset(0, speed * dt); break;
      case ObstacleDirection.bottom: position += Offset(0, -speed * dt); break;
      case ObstacleDirection.left:   position += Offset(speed * dt, 0); break;
      case ObstacleDirection.right:  position += Offset(-speed * dt, 0); break;
    }
  }

  // 화면 밖으로 완전히 나가면 비활성화
  bool isOutOfBounds(Size screenSize) {
    return position.dx < -40 || position.dx > screenSize.width + 40 ||
           position.dy < -40 || position.dy > screenSize.height + 40;
  }

  void draw(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: position,
      width: size,
      height: size,
    );
    // 사각형 방해물
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = AppTheme.obstacle,
    );
    // 중앙 십자 흰 선 (미니멀 디테일)
    final paint = Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1.5;
    canvas.drawLine(Offset(position.dx - 4, position.dy), Offset(position.dx + 4, position.dy), paint);
    canvas.drawLine(Offset(position.dx, position.dy - 4), Offset(position.dx, position.dy + 4), paint);
  }

  Rect get bounds => Rect.fromCenter(center: position, width: size - 2, height: size - 2);
}