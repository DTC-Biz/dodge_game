import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';
import '../utils/play_limit.dart';
import '../utils/constants.dart';
import '../services/ad_service.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'paywall_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _remaining = 0;
  bool _isUnlimited = false;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final remaining = await PlayLimit.remainingPlays();
    final unlimited = await PlayLimit.isUnlimited();
    setState(() {
      _remaining = remaining;
      _isUnlimited = unlimited;
    });
  }

  Future<void> _startGame() async {
    if (_remaining <= 0 && !_isUnlimited) {
      _showNoPlaysDialog();
      return;
    }
    await PlayLimit.useOnePlay();
    if (!mounted) return;
    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
    if (!mounted) return;
    _loadStatus();
  }

  void _showNoPlaysDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111111),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('오늘 횟수 소진',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text('광고를 보거나 무제한을 구매하세요.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!AdService.instance.isRewardedReady) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('광고를 불러오는 중이에요. 잠시 후 다시 시도해 주세요.'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF222222),
                  ),
                );
                return;
              }
              AdService.instance.showRewardedAd(
                onRewarded: () async {
                  await PlayLimit.addAdReward();
                  if (!mounted) return;
                  _loadStatus();
                },
              );
            },
            child: const Text('광고 보기 (+1회)',
                style: TextStyle(color: Color(0xFF7B9CFF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()))
                  .then((_) => _loadStatus());
            },
            child: const Text('무제한 구매',
                style: TextStyle(color: Color(0xFF9F99F0))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // 배경 애니메이션
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _HomeBgPainter(_bgController.value),
            ),
          ),

          // 설정 버튼
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.tune, color: Color(0xFF444444), size: 22),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ),
          ),

          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // 로고 영역
                _buildLogo(),

                const Spacer(flex: 2),

                // 플레이 횟수 표시
                _buildPlayCount(),

                // 대회 배너 (기간 중만 표시)
                if (AppConstants.isContestActive) ...[
                  const SizedBox(height: 20),
                  _buildContestBanner(),
                ],

                const SizedBox(height: 32),

                // 버튼 영역
                _buildButtons(),

                const Spacer(flex: 2),

                // 하단 태그라인
                const Text(
                  'AVOID EVERYTHING',
                  style: TextStyle(
                    color: Color(0xFF2A2A2A),
                    fontSize: 11,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // 아이콘
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              // 작은 장애물 힌트
              Positioned(
                top: 14,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE63946).withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 14,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B9CFF).withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'DODGE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            letterSpacing: 10,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '얼마나 오래 버틸 수 있어?',
          style: TextStyle(
            color: Color(0xFF444444),
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildContestBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                '런칭 대회 진행 중  ·  TOP 3  ₩100,000',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: Color(0xFFFFD700), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF222222)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isUnlimited ? Icons.all_inclusive : Icons.play_circle_outline,
            color: _isUnlimited
                ? const Color(0xFF9F99F0)
                : const Color(0xFF555555),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _isUnlimited ? '무제한 플레이' : '오늘 남은 횟수  $_remaining 회',
            style: TextStyle(
              color: _isUnlimited
                  ? const Color(0xFF9F99F0)
                  : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // 게임 시작 (메인 버튼)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(27)),
              ),
              child: const Text(
                '게임 시작',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 순위 + 무제한 (보조 버튼)
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen())),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF252525)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('순위 보기',
                        style: TextStyle(fontSize: 14)),
                  ),
                ),
              ),
              if (!_isUnlimited) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const PaywallScreen()))
                          .then((_) => _loadStatus()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9F99F0),
                        side: const BorderSide(color: Color(0xFF252535)),
                        backgroundColor: const Color(0xFF0D0D1A),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('무제한  ₩1,000',
                          style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// 배경 파티클 애니메이션
class _HomeBgPainter extends CustomPainter {
  final double t;
  _HomeBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final particles = [
      _Particle(0.15, 0.2, 3, const Color(0xFF1A1A2E)),
      _Particle(0.8, 0.15, 4, const Color(0xFF1A1A1A)),
      _Particle(0.6, 0.7, 2.5, const Color(0xFF1E1A2E)),
      _Particle(0.25, 0.75, 3.5, const Color(0xFF1A1A1A)),
      _Particle(0.9, 0.5, 2, const Color(0xFF1A1A2E)),
      _Particle(0.05, 0.55, 5, const Color(0xFF111111)),
      _Particle(0.5, 0.3, 2, const Color(0xFF1A1A2E)),
      _Particle(0.7, 0.9, 4, const Color(0xFF111111)),
    ];

    for (final p in particles) {
      final x = p.x * size.width +
          math.sin((t * math.pi * 2) + p.phase) * 20;
      final y = p.y * size.height +
          math.cos((t * math.pi * 2) + p.phase) * 15;

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HomeBgPainter old) => old.t != t;
}

class _Particle {
  final double x, y, radius, phase;
  final Color color;
  _Particle(this.x, this.y, this.radius, this.color)
      : phase = x * 3.14 + y * 2.71;
}
