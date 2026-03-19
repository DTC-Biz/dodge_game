import 'player.dart';
import 'obstacle.dart';

class CollisionDetector {
  // 원(플레이어) ↔ 사각형(방해물) 충돌 체크
  static bool check(Player player, Obstacle obstacle) {
    final playerR = player.size / 2 - 3; // 약간 여유
    final obs = obstacle.bounds;

    // 플레이어 원 중심에서 사각형까지 가장 가까운 점 계산
    final closestX = player.position.dx.clamp(obs.left, obs.right);
    final closestY = player.position.dy.clamp(obs.top, obs.bottom);

    final dx = player.position.dx - closestX;
    final dy = player.position.dy - closestY;

    return (dx * dx + dy * dy) < (playerR * playerR);
  }
}