import 'package:audio_player/data/model/repeat_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String SHUFFLE_KEY = 'shuffle';
  static const String REPEAT_MODE_KEY = 'repeat_mode';

  static Future<bool> getShuffle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SHUFFLE_KEY) ?? false; // Agar qiymat mavjud bo'lmasa false qaytariladi
  }

  static Future<void> setShuffle(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SHUFFLE_KEY, value);
  }

  static Future<RepeatMode> getRepeatMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return RepeatMode.values[prefs.getInt(REPEAT_MODE_KEY) ?? RepeatMode.none.index];
  }

  static Future<void> setRepeatMode(RepeatMode mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(REPEAT_MODE_KEY, mode.index);
  }
}
