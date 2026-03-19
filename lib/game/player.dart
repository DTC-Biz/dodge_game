import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class Player {
  Offset position;
  final double size = AppConstants.playerSize;

  Player({required this.position});

  // 터치 드래그로 위치 업데이트
  void moveTo(Offset target, Size screenSize) {
    final half = size / 2;
    position = Offset(
      target.dx.clamp(half, screenSize.width - half),
      target.dy.clamp(half, screenSize.height - half),
    );
  }

  void draw(Canvas canvas) {
    // 외부 검정 원
    canvas.drawCircle(
      position,
      size / 2,
      Paint()..color = AppTheme.player,
    );
    // 내부 흰점
    canvas.drawCircle(
      position,
      size / 5,
      Paint()..color = AppTheme.playerCenter,
    );
  }

  Rect get bounds => Rect.fromCircle(center: position, radius: size / 2);
}