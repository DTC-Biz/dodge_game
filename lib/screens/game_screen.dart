import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import '../game/player.dart';
import '../game/obstacle.dart';
import '../game/collision.dart';
import '../game/score_manager.dart';
import '../utils/theme.dart';
import '../utils/difficulty.dart';
import '../utils/constants.dart';
import '../utils/play_limit.dart';
import '../services/ad_service.dart';
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

  Offset? _lastTouchPosition;

  double _bestTime = 0.0;
  bool _isNewRecord = false;
  DateTime? _gameStartWallTime;
  double _wallClockSeconds = 0.0;

  final GlobalKey _shareCardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadBestTime();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_gameLoop);
  }

  Future<void> _loadBestTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bestTime = prefs.getDouble(AppConstants.keyBestTime) ?? 0.0;
    });
  }

  Future<void> _saveBestTime(double time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyBestTime, time);
  }

  String _formatTime(double t) {
    final totalSeconds = t.floor();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final ms = ((t - totalSeconds) * 1000).floor().toString().padLeft(3, '0');
    final s = seconds.toString().padLeft(2, '0');
    final m = minutes.toString().padLeft(2, '0');
    final h = hours.toString();
    if (hours > 0) return '$h:$m:$s.$ms';
    if (minutes > 0) return '$m:$s.$ms';
    return '$s.$ms';
  }

  void _initGame(Size size) {
    _player = Player(position: Offset(size.width / 2, size.height / 2));
    _obstacles.clear();
    _scoreManager.reset();
    _isGameOver = false;
    _isNewRecord = false;
    _currentLevel = 1;
    _lastTime = 0;
    _started = true;
    _lastTouchPosition = null;
    _gameStartWallTime = DateTime.now();
    _wallClockSeconds = 0.0;
    _controller.forward(from: 0);
    _startSpawning(size);
  }

  void _startSpawning(Size size) {
    _spawnTimer?.cancel();
    final elapsed = _scoreManager.elapsedTime;
    final diff = Difficulty.forSeconds(elapsed);

    if (_currentLevel == 1 && elapsed == 0) {
      const initialCount = 5;
      final startSpeed = diff.obstacleSpeed + 30;
      for (int i = 0; i < initialCount; i++) {
        _obstacles.add(Obstacle.spawn(
          size, startSpeed, _currentLevel,
          forceIndex: i,
          totalCount: initialCount,
          randomDistance: true,
        ));
      }
    }

    _spawnTimer = Timer.periodic(
      Duration(milliseconds: diff.spawnIntervalMs),
      (_) {
        if (!_isGameOver && mounted) {
          final currentElapsed = _scoreManager.elapsedTime;
          final currentDiff = Difficulty.forSeconds(currentElapsed);
          setState(() {
            if (_obstacles.length < currentDiff.maxObstacles) {
              _obstacles.add(Obstacle.spawn(
                size, currentDiff.obstacleSpeed, _currentLevel,
              ));
            }
          });
        }
      },
    );
  }

  void _gameLoop() {
    if (_isGameOver || !_started) return;

    final now = _controller.lastElapsedDuration?.inMicroseconds.toDouble() ?? 0;
    final dt = (_lastTime == 0)
        ? 0.016
        : ((now - _lastTime) / 1000000).clamp(0.0, 0.05);
    _lastTime = now;

    final size = MediaQuery.of(context).size;

    setState(() {
      _scoreManager.update(dt);

      final newLevel = _scoreManager.level;
      if (newLevel != _currentLevel) {
        _currentLevel = newLevel;
        _startSpawning(size);
      }

      for (final obs in _obstacles) {
        obs.update(dt);
        obs.checkEntered(size);
      }
      _obstacles.removeWhere((o) => o.isOutOfBounds(size));

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

    final elapsed = _scoreManager.elapsedTime;
    if (elapsed > _bestTime) {
      _isNewRecord = true;
      _bestTime = elapsed;
      _saveBestTime(elapsed);
    }

    // 실제 경과 시간 기록 (부정행위 감지용)
    if (_gameStartWallTime != null) {
      _wallClockSeconds =
          DateTime.now().difference(_gameStartWallTime!).inMilliseconds / 1000.0;
    }
  }

  void _onPanStart(DragStartDetails details) {
    _lastTouchPosition = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isGameOver || !_started) return;
    if (_lastTouchPosition == null) {
      _lastTouchPosition = details.globalPosition;
      return;
    }
    final delta = details.globalPosition - _lastTouchPosition!;
    _lastTouchPosition = details.globalPosition;
    final size = MediaQuery.of(context).size;
    setState(() {
      _player.moveTo(_player.position + delta, size);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _lastTouchPosition = null;
  }

  void _restart() async {
    final remaining = await PlayLimit.remainingPlays();
    if (remaining <= 0 && !await PlayLimit.isUnlimited()) {
      if (mounted) Navigator.pop(context);
      return;
    }
    await PlayLimit.useOnePlay();
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    _obstacles.clear();
    _initGame(size);
  }

  // 광고 보고 +1회 플레이
  void _watchAdAndPlay() {
    AdService.instance.showRewardedAd(
      onRewarded: () async {
        await PlayLimit.useOnePlay();
        if (!mounted) return;
        final size = MediaQuery.of(context).size;
        _obstacles.clear();
        _initGame(size);
      },
      onAdDismissed: () {
        // 광고 취소 시 아무것도 안 함
      },
    );
  }

  Future<void> _share() async {
    try {
      // RepaintBoundary 렌더링 대기
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = _shareCardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/dodge_score.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            '🎮 DODGE 게임에서 ${_scoreManager.timeString} 버텼어요! (Lv.${_scoreManager.level})\n#닷지게임 #DODGE',
      );
    } catch (_) {
      // 이미지 공유 실패 시 텍스트 fallback
      await Share.share(
        '🎮 DODGE 게임에서 ${_scoreManager.timeString} 버텼어요! (Lv.${_scoreManager.level})\n#닷지게임 #DODGE',
      );
    }
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

    if (!_started) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initGame(size));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onTapDown: (d) {
              if (!_started) _initGame(size);
            },
            child: CustomPaint(
              size: size,
              painter: _GamePainter(
                player: _started ? _player : null,
                obstacles: _obstacles,
                screenSize: size,
              ),
            ),
          ),

          // HUD
          if (_started && !_isGameOver)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      _scoreManager.timeString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (_bestTime > 0)
                      Text(
                        '최고  ${_formatTime(_bestTime)}',
                        style: const TextStyle(
                            color: Color(0xFF555555), fontSize: 11),
                      ),
                  ],
                ),
              ),
            ),

          // 공유 카드 (오프스크린 렌더링)
          if (_isGameOver)
            Offstage(
              child: RepaintBoundary(
                key: _shareCardKey,
                child: _ShareCard(
                  timeString: _scoreManager.timeString,
                  level: _scoreManager.level,
                  isNewRecord: _isNewRecord,
                ),
              ),
            ),

          // 게임오버
          if (_isGameOver)
            GameOverScreen(
              timeString: _scoreManager.timeString,
              bestTimeString: _formatTime(_bestTime),
              isNewRecord: _isNewRecord,
              level: _scoreManager.level,
              timeSeconds: _scoreManager.elapsedTime,
              wallClockSeconds: _wallClockSeconds,
              onRestart: _restart,
              onHome: () => Navigator.pop(context),
              onShare: _share,
              onWatchAd: AdService.instance.isRewardedReady ? _watchAdAndPlay : null,
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// 공유 이미지 카드
// ─────────────────────────────────────────
class _ShareCard extends StatelessWidget {
  final String timeString;
  final int level;
  final bool isNewRecord;

  const _ShareCard({
    required this.timeString,
    required this.level,
    required this.isNewRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 480,
      color: const Color(0xFF090909),
      child: Stack(
        children: [
          // 그리드 배경
          CustomPaint(
            size: const Size(320, 480),
            painter: _GridPainter(),
          ),
          // 컨텐츠
          Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 앱명
                const Text(
                  'DODGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                  ),
                ),
                const Spacer(),
                // 라벨
                const Text(
                  'SURVIVAL TIME',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 11,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                // 시간
                Text(
                  timeString,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                // 레벨
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF333333)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Lv.$level',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (isNewRecord) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'NEW RECORD',
                    style: TextStyle(
                      color: Color(0xFF44FF44),
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const Spacer(),
                // 하단 태그라인
                const Text(
                  'AVOID EVERYTHING',
                  style: TextStyle(
                    color: Color(0xFF2A2A2A),
                    fontSize: 10,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF111111)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GamePainter extends CustomPainter {
  final Player? player;
  final List<Obstacle> obstacles;
  final Size screenSize;

  _GamePainter({
    required this.player,
    required this.obstacles,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppTheme.background,
    );

    final gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final obs in obstacles) {
      obs.draw(canvas);
    }
    player?.draw(canvas);
  }

  @override
  bool shouldRepaint(covariant _GamePainter old) => true;
}
