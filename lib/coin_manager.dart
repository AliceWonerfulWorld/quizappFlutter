import 'package:shared_preferences/shared_preferences.dart';

class CoinManager {
  static const String _coinKey = 'user_coins';

  // コインを取得
  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinKey) ?? 0; // 保存されているコインがなければ0を返す
  }

  // コインを設定（上書き）
  static Future<void> setCoins(int coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinKey, coins);
  }

  // コインを追加
  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentCoins = await getCoins();
    await prefs.setInt(_coinKey, currentCoins + amount);
  }

  // コインを消費
  static Future<bool> spendCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    int currentCoins = await getCoins();
    if (currentCoins >= amount) {
      await prefs.setInt(_coinKey, currentCoins - amount);
      return true; // 消費成功
    }
    return false; // コイン不足
  }
}
