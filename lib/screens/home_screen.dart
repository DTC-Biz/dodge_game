import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/play_limit.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _remaining = 0;
  bool _isUnlimited = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
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
        title: const Text('오늘 횟수 소진',
            style: TextStyle(color: Colors.white)),
        content: const Text('광고를 보거나 무제한을 구매하세요.',
            style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PlayLimit.addAdReward();
              _loadStatus();
            },
            child: const Text('광고 보기 (+1회)'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PaywallScreen()))
                  .then((_) => _loadStatus());
            },
            child: const Text('무제한 구매'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircleAvatar(radius: 12, backgroundColor: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'DODGE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isUnlimited ? '∞  무제한' : '오늘 남은 횟수  $_remaining 회',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                height: 52,
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: const Text('게임 시작',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen())),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF333333)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('순위 보기'),
                ),
              ),
              const SizedBox(height: 12),
              if (!_isUnlimited)
                SizedBox(
                  width: 200,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PaywallScreen()))
                        .then((_) => _loadStatus()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9F99F0),
                      side: const BorderSide(color: Color(0xFF333355)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('무제한  ₩1,000'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}