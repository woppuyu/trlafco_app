import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile(
              title: const Text('Dark Theme'),
              subtitle: const Text('Persisted across app restarts'),
              value: appState.themeMode == ThemeMode.dark,
              onChanged: (_) => appState.toggleTheme(),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Info'),
              subtitle: const Text('TRLAFCO Supply Mobile v0.1\nAcademic Flutter Project'),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async => appState.logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
