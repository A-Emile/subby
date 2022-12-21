import 'package:shared_preferences/shared_preferences.dart';

List<String> defaultHomeItems = const [
  "random",
  "newest",
  "frequent",
  "recent",
  "starred"
];

class UserSettings {
  static late SharedPreferences _preferences;

  static SharedPreferences prefs() => _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();

    // Set default values
    if (_preferences.getStringList("homeItems") == null) {
      _preferences.setStringList('homeItems', defaultHomeItems);
    }
  }

  static int getMaxBitrateMobile() =>
      _preferences.getInt("maxBitrateMobile") ?? 160;
}
