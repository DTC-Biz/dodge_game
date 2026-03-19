import 'package:flutter/material.dart';
import 'dart:async';
import '../game/player.dart';
import '../game/obstacle.dart';
import '../game/collision.dart';
import '../game/score_manager.dart';
import '../utils/theme.dart';
import '../utils/difficulty.dart';
import 'gameover_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late Player _player;
  final List<Obstacle> _obstacles = [];
  final ScoreManager _scoreManager = ScoreManager();

  late AnimationController _controller;
  double _lastTime = 0;

  bool _isGameOver = false;
  bool _started = false;

  Timer? _spawnTimer;
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_gameLoop);
  }

  void _initGame(Size size) {
    _player = Player(position: Offset(size.width / 2, size.height / 2));
    _obstacles.clear();
    _scoreManager.reset();
    _isGameOver = false;
    _currentLevel = 1;
    _lastTime = 0;
    _started = true;

    _controller.forward(from: 0);
    _startSpawning(size);
  }

  void _startSpawning(Size size) {
    _spawnTimer?.cancel();
    final diff = Difficulty.forLevel(_currentLevel);
    _spawnTimer = Timer.periodic(
      Duration(milliseconds: diff.spawnIntervalMs),
      (_) {
        if (!_isGameOver && mounted) {
          setState(() {
            _obstacles.add(Obstacle.spawn(size, diff.obstacleSpeed));
          });
        }
      },
    );
  }

  void _gameLoop() {
    if (_isGameOver || !_started) return;

    final now = _controller.lastElapsedDuration?.inMicroseconds.toDouble() ?? 0;
    final dt = (_lastTime == 0) ? 0.016 : ((now - _lastTime) / 1000000).clamp(0.0, 0.05);
    _lastTime = now;

    final size = MediaQuery.of(context).size;

    setState(() {
      _scoreManager.update(dt);

      // 레벨업 체크
      if (_scoreManager.level != _currentLevel) {
        _currentLevel = _scoreManager.level;
        _startSpawning(size);
      }

      // 방해물 이동 + 제거
      for (final obs in _obstacles) {
        obs.update(dt);
      }
      _obstacles.removeWhere((o) => o.isOutOfBounds(size));

      // 충돌 체크
      for (final obs in _obstacles) {
        if (CollisionDetector.check(_player, obs)) {
          _triggerGameOver();
          return;
        }
      }
    });
  }

  void _triggerGameOver() {
    _isGameOver = true;
    _controller.stop();
    _spawnTimer?.cancel();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isGameOver || !_started) return;
    final size = MediaQuery.of(context).size;
    setState(() {
      _player.moveTo(details.globalPosition, size);
    });
  }

  void _restart() {
    final size = MediaQuery.of(context).size;
    _obstacles.clear();
    _initGame(size);
  }

  @override
  void dispose() {
    _controller.dispose();
    _spawnTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 첫 진입 시 게임 초기화
    if (!_started) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initGame(size);
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onTapDown: (d) {
          if (!_started) _initGame(size);
        },
        child: Stack(
          children: [
            // 게임 캔버스
            CustomPaint(
              size: size,
              painter: _GamePainter(
                player: _started ? _player : null,
                obstacles: _obstacles,
                score: _scoreManager.score,
                level: _scoreManager.level,
                screenSize: size,
              ),
            ),

            // HUD — 점수
            if (_started && !_isGameOver)
              Positioned(
                top: 56,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    '${_scoreManager.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

            // HUD — 레벨
            if (_started && !_isGameOver)
              Positioned(
                top: 60,
                right: 24,
                child: Text(
                  'Lv.${_scoreManager.level}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),

            // 게임 오버 오버레이
            if (_isGameOver)
              GameOverScreen(
                score: _scoreManager.score,
                level: _scoreManager.level,
                onRestart: _restart,
                onHome: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final Player? player;
  final List<Obstacle> obstacles;
  final int score;
  final int level;
  final Size screenSize;

  _GamePainter({
    required this.player,
    required this.obstacles,
    required this.score,
    required this.level,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 블랙
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppTheme.background,
    );

    // 격자선 (미니멀)
    final gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 방해물 그리기
    for (final obs in obstacles) {
      obs.draw(canvas);
    }

    // 플레이어 그리기
    player?.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant _GamePainter old) => true;
}