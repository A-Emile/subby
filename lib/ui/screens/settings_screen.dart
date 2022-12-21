import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:subby/ui/screens/home_screen.dart';
import 'package:subby/utils/shared_preferences.dart';
import 'package:subby/utils/subsonic.dart';

import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: TextFormField(
              onChanged: (newValue) async {
                UserSettings.prefs().setString("server", newValue);
              },
              initialValue: UserSettings.prefs().getString("server"),
              decoration: const InputDecoration(
                labelText: "Server (example.com)",
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: TextFormField(
              onChanged: (newValue) async {
                UserSettings.prefs().setString("username", newValue);
              },
              initialValue: UserSettings.prefs().getString("username"),
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: TextFormField(
              onChanged: (newValue) async {
                UserSettings.prefs().setString("password", newValue);
              },
              initialValue: UserSettings.prefs().getString("password"),
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),
          ),
          ListTile(
              title: ElevatedButton(
            onPressed: () async {
              final String status = await SubsonicAPI.ping();
              Get.defaultDialog(content: Text(status), title: "Response:");
            },
            child: const Text("Ping server"),
          )),
          ListTile(
            title: ElevatedButton(
              child: const Text("Clear preferences"),
              onPressed: () {
                UserSettings.prefs().clear();
                Get.back();
              },
            ),
          ),
        ],
      ),
    );
  }
}
