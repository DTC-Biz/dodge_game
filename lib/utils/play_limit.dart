import 'package:shared_preferences/shared_preferences.dart';

class PlayLimit {
  static const int maxFreeFirstDay = 3;
  static const int maxFreeNormal = 2;  // 매일 2회
  static const String _keyCount = 'play_count';
  static const String _keyDate = 'play_date';
  static const String _keyFirstDate = 'first_date';
  static const String _keyUnlimited = 'is_unlimited';

  static Future<bool> isUnlimited() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUnlimited) ?? false;
  }

  static Future<void> setUnlimited() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUnlimited, true);
  }

  static Future<bool> _isFirstDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final firstDate = prefs.getString(_keyFirstDate);
    if (firstDate == null) {
      await prefs.setString(_keyFirstDate, today);
      return true;
    }
    return firstDate == today;
  }

  static Future<int> remainingPlays() async {
    if (await isUnlimited()) return 999;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_keyDate) ?? '';
    final isFirst = await _isFirstDay();
    final maxPlays = isFirst ? maxFreeFirstDay : maxFreeNormal;

    if (savedDate != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 0);
      return maxPlays;
    }
    final used = prefs.getInt(_keyCount) ?? 0;
    return (maxPlays - used).clamp(0, maxPlays);
  }

  static Future<void> useOnePlay() async {
    if (await isUnlimited()) return;
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_keyCount) ?? 0;
    await prefs.setInt(_keyCount, used + 1);
  }

  static Future<void> addAdReward() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_keyCount) ?? 0;
    if (used > 0) await prefs.setInt(_keyCount, used - 1);
  }
}