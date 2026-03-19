import 'package:shared_preferences/shared_preferences.dart';

class PlayLimit {
  static const int maxFreePerDay = 3;
  static const String _keyCount = 'play_count';
  static const String _keyDate  = 'play_date';
  static const String _keyUnlimited = 'is_unlimited';

  // 무제한 구매 여부
  static Future<bool> isUnlimited() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUnlimited) ?? false;
  }

  // 무제한 언락 저장
  static Future<void> setUnlimited() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUnlimited, true);
  }

  // 오늘 남은 횟수
  static Future<int> remainingPlays() async {
    if (await isUnlimited()) return 999;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyDate) ?? '';

    if (savedDate != today) {
      // 날짜 바뀌면 횟수 리셋
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 0);
      return maxFreePerDay;
    }
    final used = prefs.getInt(_keyCount) ?? 0;
    return (maxFreePerDay - used).clamp(0, maxFreePerDay);
  }

  // 플레이 1회 차감
  static Future<void> useOnePlay() async {
    if (await isUnlimited()) return;
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_keyCount) ?? 0;
    await prefs.setInt(_keyCount, used + 1);
  }

  // 광고 보상 +1회 지급
  static Future<void> addAdReward() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_keyCount) ?? 0;
    if (used > 0) {
      await prefs.setInt(_keyCount, used - 1);
    }
  }
}