import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class Player {
  Offset position;
  final double size = AppConstants.playerSize;

  Player({required this.position});

  void moveTo(Offset target, Size screenSize) {
    final half = size / 2;
    position = Offset(
      target.dx.clamp(half, screenSize.width - half),
      target.dy.clamp(half, screenSize.height - half),
    );
  }

  void draw(Canvas canvas) {
    // 외곽 글로우 링
    canvas.drawCircle(
      position,
      size / 2 + 3,
      Paint()
        ..color = AppTheme.playerRing.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // 흰색 원
    canvas.drawCircle(position, size / 2, Paint()..color = AppTheme.player);
    // 중앙 검정 점
    canvas.drawCircle(position, size / 5, Paint()..color = AppTheme.playerCenter);
  }

  // 충돌 판정을 실제보다 작게 → 아슬아슬 쾌감
  Rect get bounds => Rect.fromCircle(center: position, radius: size / 2 - 6);
}