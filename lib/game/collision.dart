import 'player.dart';
import 'obstacle.dart';

class CollisionDetector {
  static bool check(Player player, Obstacle obstacle) {
    final playerR = player.size / 2 - 3;
    final obs = obstacle.bounds;
    final closestX = player.position.dx.clamp(obs.left, obs.right);
    final closestY = player.position.dy.clamp(obs.top, obs.bottom);
    final dx = player.position.dx - closestX;
    final dy = player.position.dy - closestY;
    return (dx * dx + dy * dy) < (playerR * playerR);
  }
}
