import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class GameOverScreen extends StatefulWidget {
  final String timeString;
  final String bestTimeString;
  final bool isNewRecord;
  final int level;
  final double timeSeconds;
  final VoidCallback onRestart;
  final VoidCallback onHome;
  final VoidCallback onShare;
  final double wallClockSeconds;
  final VoidCallback? onWatchAd;

  const GameOverScreen({
    super.key,
    required this.timeString,
    required this.bestTimeString,
    required this.isNewRecord,
    required this.level,
    required this.timeSeconds,
    required this.wallClockSeconds,
    required this.onRestart,
    required this.onHome,
    required this.onShare,
    this.onWatchAd,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _nicknameController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  int? _myRank;
  int? _myWeeklyRank;

  static const _keyNickname = 'user_nickname';

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyNickname);
    if (saved != null && saved.isNotEmpty) {
      setState(() => _nicknameController.text = saved);
    }
  }

  Future<void> _submitScore() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해 주세요.'),
          backgroundColor: Color(0xFF222222),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (nickname.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임은 12자 이하로 입력해 주세요.'),
          backgroundColor: Color(0xFF222222),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyNickname, nickname);

      await FirebaseService.submitScore(
        nickname: nickname,
        timeSeconds: widget.timeSeconds,
        wallClockSeconds: widget.wallClockSeconds,
      );

      if (!mounted) return;
      // 역대 + 주간 순위 동시 조회
      final ranks = await Future.wait([
        FirebaseService.fetchMyRank(nickname: nickname, isWeekly: false),
        FirebaseService.fetchMyRank(nickname: nickname, isWeekly: true),
      ]);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
        _myRank = ranks[0];
        _myWeeklyRank = ranks[1];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$nickname 님의 기록이 등록됐어요! 🎉'),
          backgroundColor: const Color(0xFF1A2A1A),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      final msg = e.toString();
      final String snackText;
      if (msg.contains('invalid_score_too_low')) {
        snackText = '기록이 너무 짧아요.';
      } else if (msg.contains('invalid_score_too_high')) {
        snackText = '비정상적인 기록은 등록할 수 없어요.';
      } else if (msg.contains('invalid_score_time_mismatch')) {
        snackText = '비정상적인 기록은 등록할 수 없어요.';
      } else {
        snackText = '기록 등록에 실패했어요. 다시 시도해 주세요.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackText),
          backgroundColor: const Color(0xFF2A1A1A),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        color: const Color(0x55E63946),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('게임 오버',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text('생존 시간',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    widget.timeString,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text('Lv.${widget.level}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 12),
                  if (widget.isNewRecord)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2A1A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF44FF44)),
                      ),
                      child: const Text(
                        'NEW RECORD',
                        style: TextStyle(
                          color: Color(0xFF44FF44),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('최고기록  ',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(widget.bestTimeString,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),

                  // ── 리더보드 등록 ──
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF222222)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '리더보드 등록',
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nicknameController,
                                enabled: !_isSubmitted,
                                maxLength: 12,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: '닉네임 입력 (최대 12자)',
                                  hintStyle: const TextStyle(
                                      color: Colors.white24, fontSize: 13),
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFF1A1A1A),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isSubmitting || _isSubmitted
                                    ? null
                                    : _submitScore,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isSubmitted
                                      ? const Color(0xFF1A2A1A)
                                      : const Color(0xFF7B9CFF),
                                  foregroundColor: _isSubmitted
                                      ? const Color(0xFF44FF44)
                                      : Colors.black,
                                  disabledBackgroundColor: _isSubmitted
                                      ? const Color(0xFF1A2A1A)
                                      : null,
                                  disabledForegroundColor: _isSubmitted
                                      ? const Color(0xFF44FF44)
                                      : null,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _isSubmitted ? '등록됨 ✓' : '등록',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
if (_isSubmitted)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_myRank != null) ...[
          const Text('역대  ', style: TextStyle(color: Colors.white38, fontSize: 12)),
          Text(
            '$_myRank위',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
        if (_myRank != null && _myWeeklyRank != null)
          const Text('   ·   ', style: TextStyle(color: Colors.white24, fontSize: 12)),
        if (_myWeeklyRank != null) ...[
          const Text('주간  ', style: TextStyle(color: Colors.white38, fontSize: 12)),
          Text(
            '$_myWeeklyRank위',
            style: const TextStyle(color: Color(0xFF7B9CFF), fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    ),
  ),
if (AppConstants.isContestActive)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D00),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: const Text(
        '🏆 런칭 대회 중  ·  TOP 3  ₩100,000  ·  5/24까지',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFFFFD700),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
                  const SizedBox(height: 16),

                  // 공유 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: widget.onShare,
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('기록 공유하기'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Color(0xFF444444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 광고 보고 +1회 버튼
                  if (widget.onWatchAd != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: widget.onWatchAd,
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: const Text(
                          '광고 보고 1회 더 하기',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A2E),
                          foregroundColor: const Color(0xFF7B9CFF),
                          side: const BorderSide(color: Color(0xFF7B9CFF)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // 다시 하기
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: widget.onRestart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('다시 하기',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 홈으로
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: widget.onHome,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF333333)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('홈으로'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
