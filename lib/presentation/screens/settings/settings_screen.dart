import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../providers/card_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionHeader(title: 'Appearance'),
            SwitchListTile(
              title: const Text(AppStrings.darkMode),
              value: settings.darkMode,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setDarkMode(v),
            ),
            const Divider(),
            _SectionHeader(title: 'Study'),
            ListTile(
              title: const Text(AppStrings.dailyLimit),
              subtitle: Text('${settings.dailyNewLimit} new cards per day'),
              trailing: SizedBox(
                width: 80,
                child: DropdownButton<int>(
                  value: settings.dailyNewLimit,
                  items: [5, 10, 20, 30, 50, 100, 200, 500]
                      .map((v) =>
                          DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(settingsProvider.notifier).setDailyLimit(v);
                    }
                  },
                ),
              ),
            ),
            SwitchListTile(
              title: const Text('Bidirectional study mode'),
              subtitle: const Text('After German -> English, repeat as English -> German'),
              value: settings.bidirectionalStudy,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setBidirectionalStudy(v),
            ),
            const Divider(),
            _SectionHeader(title: 'Progress'),
            ListTile(
              title: const Text('Current Streak'),
              subtitle: Text('${settings.streakDays} days 🔥'),
            ),
            ListTile(
              title: const Text(AppStrings.resetStreak,
                  style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.warning_amber, color: Colors.red),
              onTap: () => _confirmResetStreak(context, ref),
            ),
            ListTile(
              title: const Text(AppStrings.resetShortTerm,
                  style: TextStyle(color: Colors.orange)),
              trailing: const Icon(Icons.restore, color: Colors.orange),
              onTap: () => _confirmResetShortTerm(context, ref),
            ),
            const Divider(),
            _SectionHeader(title: 'About'),
            const ListTile(
              title: Text('VocBuilder'),
              subtitle: Text('Version 1.0.0\nOffline-first German vocabulary'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _confirmResetStreak(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset Streak?'),
        content: const Text('This will reset your learning streak to 0.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await ref.read(settingsProvider.notifier).resetStreak();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _confirmResetShortTerm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset short-term cards?'),
        content: const Text(
          'This moves all short-term cards back to New and makes them due now.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            onPressed: () async {
              final updated = await ref
                  .read(cardNotifierProvider.notifier)
                  .resetShortTermCards();
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reset $updated short-term cards.')),
                );
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF7C4DFF),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
