import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // 컬렉션
  static const _allTime = 'hall_of_fame';   // 명예의 전당 (역대 베스트)
  static const _weekly  = 'weekly_best';    // 주간 베스트

  // ─────────────────────────────────────────
  // 점수 등록
  // ─────────────────────────────────────────
  static Future<void> submitScore({
    required String nickname,
    required double timeSeconds,
  }) async {
    final now = DateTime.now();

    // 주간 키: "2025-W03" 형식
    final weekKey = _weekKey(now);

    // 역대 기록 업데이트 (본인 최고기록만 유지)
    final allRef = _db.collection(_allTime).doc(nickname);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(allRef);
      if (!snap.exists || (snap.data()?['time'] ?? 0.0) < timeSeconds) {
        tx.set(allRef, {
          'nickname': nickname,
          'time': timeSeconds,
          'updatedAt': now.toIso8601String(),
        });
      }
    });

    // 주간 기록 업데이트 (본인 주간 최고기록만 유지)
    final weekRef = _db
        .collection(_weekly)
        .doc(weekKey)
        .collection('scores')
        .doc(nickname);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(weekRef);
      if (!snap.exists || (snap.data()?['time'] ?? 0.0) < timeSeconds) {
        tx.set(weekRef, {
          'nickname': nickname,
          'time': timeSeconds,
          'week': weekKey,
          'updatedAt': now.toIso8601String(),
        });
      }
    });
  }

  // ─────────────────────────────────────────
  // 명예의 전당 - 역대 TOP 100
  // ─────────────────────────────────────────
  static Future<List<LeaderboardEntry>> fetchHallOfFame({int limit = 100}) async {
    final snap = await _db
        .collection(_allTime)
        .orderBy('time', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => LeaderboardEntry.fromMap(d.data()))
        .toList();
  }

  // ─────────────────────────────────────────
  // 주간 베스트 - 이번 주 TOP 100
  // ─────────────────────────────────────────
  static Future<List<LeaderboardEntry>> fetchWeeklyBest({int limit = 100}) async {
    final weekKey = _weekKey(DateTime.now());
    final snap = await _db
        .collection(_weekly)
        .doc(weekKey)
        .collection('scores')
        .orderBy('time', descending: true)
        .limit(limit)
        .get();
    return snap.docs
        .map((d) => LeaderboardEntry.fromMap(d.data()))
        .toList();
  }

  // ─────────────────────────────────────────
  // 내 순위 조회
  // ─────────────────────────────────────────
  static Future<int?> fetchMyRank({
    required String nickname,
    required bool isWeekly,
  }) async {
    final entries = isWeekly
        ? await fetchWeeklyBest()
        : await fetchHallOfFame();
    final idx = entries.indexWhere((e) => e.nickname == nickname);
    return idx == -1 ? null : idx + 1;
  }

  // ─────────────────────────────────────────
  // 헬퍼
  // ─────────────────────────────────────────
  static String _weekKey(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final weekNum = ((date.difference(startOfYear).inDays) / 7).ceil();
    return '${date.year}-W${weekNum.toString().padLeft(2, '0')}';
  }
}

// ─────────────────────────────────────────
// 데이터 모델
// ─────────────────────────────────────────
class LeaderboardEntry {
  final String nickname;
  final double timeSeconds;
  final String updatedAt;

  const LeaderboardEntry({
    required this.nickname,
    required this.timeSeconds,
    required this.updatedAt,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      nickname: map['nickname'] ?? '',
      timeSeconds: (map['time'] ?? 0.0).toDouble(),
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  // 시간 포맷 (ss.ms / mm:ss.ms)
  String get timeString {
    final total = timeSeconds.floor();
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    final ms = ((timeSeconds - total) * 1000).floor().toString().padLeft(3, '0');
    if (h > 0) return '$h:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}.$ms';
    if (m > 0) return '$m:${s.toString().padLeft(2,'0')}.$ms';
    return '${s.toString().padLeft(2,'0')}.$ms';
  }
}
