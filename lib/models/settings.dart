import 'package:shared_preferences/shared_preferences.dart';

import '../utils/shared_preferences.dart';

class Settings {
  const Settings({
    required this.server,
    required this.username,
    required this.password,
  });

  final String server;
  final String username;
  final String password;

  factory Settings.getFromPrefs(SharedPreferences prefs) {
    return Settings(
      server: UserSettings.prefs().getString("server") ??
          "https://demo.navidrome.org",
      username: UserSettings.prefs().getString("username") ?? "demo",
      password: UserSettings.prefs().getString("password") ?? "demo",
    );
  }
}
