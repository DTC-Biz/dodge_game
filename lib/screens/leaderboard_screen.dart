import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../services/firebase_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<LeaderboardEntry> _hallOfFame = [];
  List<LeaderboardEntry> _weeklyBest = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        FirebaseService.fetchHallOfFame(),
        FirebaseService.fetchWeeklyBest(),
      ]);
      setState(() {
        _hallOfFame = results[0];
        _weeklyBest = results[1];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '데이터를 불러오지 못했어요';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'LEADERBOARD',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: _fetchData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 1.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          tabs: const [
            Tab(text: '명예의 전당'),
            Tab(text: '주간 베스트'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white24,
                strokeWidth: 1.5,
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!,
                          style: const TextStyle(color: Colors.white38)),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _fetchData,
                        child: const Text('다시 시도',
                            style: TextStyle(color: Colors.white54)),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _RankList(
                      entries: _hallOfFame,
                      emptyMessage: '아직 기록이 없어요\n첫 번째 주인공이 되어보세요!',
                    ),
                    Column(
                      children: [
                        if (AppConstants.isContestActive)
                          _ContestBanner(),
                        Expanded(
                          child: _RankList(
                            entries: _weeklyBest,
                            emptyMessage: '이번 주 기록이 없어요\n지금 도전해보세요!',
                            showWeekBadge: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}

// ─────────────────────────────────────────
// 대회 배너
// ─────────────────────────────────────────
class _ContestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D00),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Text('🏆', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '런칭 대회 진행 중',
                  style: TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'TOP 3  ₩100,000 상금  ·  5/11 ~ 5/24',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
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

// ─────────────────────────────────────────
// 랭킹 리스트
// ─────────────────────────────────────────
class _RankList extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String emptyMessage;
  final bool showWeekBadge;

  const _RankList({
    required this.entries,
    required this.emptyMessage,
    this.showWeekBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white24, fontSize: 14, height: 1.8),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        return _RankTile(
          rank: i + 1,
          entry: entries[i],
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// 랭킹 타일
// ─────────────────────────────────────────
class _RankTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _RankTile({required this.rank, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isTop3
            ? _top3BgColor(rank)
            : const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTop3 ? _top3BorderColor(rank) : const Color(0xFF1A1A1A),
          width: isTop3 ? 1.0 : 0.5,
        ),
      ),
      child: Row(
        children: [
          // 순위
          SizedBox(
            width: 40,
            child: isTop3
                ? _Top3Badge(rank: rank)
                : Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),

          // 닉네임
          Expanded(
            child: Text(
              entry.nickname,
              style: TextStyle(
                color: isTop3 ? Colors.white : Colors.white70,
                fontSize: isTop3 ? 15 : 14,
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 시간 기록
          Text(
            entry.timeString,
            style: TextStyle(
              color: isTop3 ? _top3TimeColor(rank) : Colors.white54,
              fontSize: isTop3 ? 16 : 14,
              fontWeight: FontWeight.bold,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Color _top3BgColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFF1A1500);
      case 2: return const Color(0xFF111318);
      case 3: return const Color(0xFF150E0A);
      default: return Colors.transparent;
    }
  }

  Color _top3BorderColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // 골드
      case 2: return const Color(0xFFB4B2A9); // 실버
      case 3: return const Color(0xFFCD7F32); // 브론즈
      default: return Colors.transparent;
    }
  }

  Color _top3TimeColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFD3D1C7);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.white;
    }
  }
}

// ─────────────────────────────────────────
// TOP3 뱃지
// ─────────────────────────────────────────
class _Top3Badge extends StatelessWidget {
  final int rank;
  const _Top3Badge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final color = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFB4B2A9)
            : const Color(0xFFCD7F32);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
