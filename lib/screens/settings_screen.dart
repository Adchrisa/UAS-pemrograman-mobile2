import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: SettingsService.notifier,
            builder: (context, isDark, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (v) => SettingsService.setDark(v),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Tentang EcoHelper'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
        ],
      ),
    );
  }
}
