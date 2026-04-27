import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/supported_languages.dart';
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
          data: (settings) {
              final targetLang = SupportedLanguage.fromCode(settings.targetLanguage);
              final nativeLang = SupportedLanguage.fromCode(settings.nativeLanguage);
              return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionHeader(title: 'Language'),
                ListTile(
                  leading: Text(
                    targetLang.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: const Text('Learning language'),
                  subtitle: Text('${targetLang.name} (${targetLang.nativeName})'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickLanguage(
                    context,
                    ref,
                    title: 'Learning language',
                    current: settings.targetLanguage,
                    exclude: settings.nativeLanguage,
                    onSelected: (code) =>
                        ref.read(settingsProvider.notifier).setTargetLanguage(code),
                  ),
                ),
                ListTile(
                  leading: Text(
                    nativeLang.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: const Text('Native / interface language'),
                  subtitle: Text('${nativeLang.name} (${nativeLang.nativeName})'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pickLanguage(
                    context,
                    ref,
                    title: 'Native language',
                    current: settings.nativeLanguage,
                    exclude: settings.targetLanguage,
                    onSelected: (code) =>
                        ref.read(settingsProvider.notifier).setNativeLanguage(code),
                  ),
                ),
                const Divider(),
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
              subtitle: Text(
                'After ${targetLang.name} \u2192 ${nativeLang.name}, repeat as ${nativeLang.name} \u2192 ${targetLang.name}',
              ),
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
              subtitle: Text('Version 1.0.0\nOffline-first vocabulary builder'),
            ),
          ],
        );
          },
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
  void _pickLanguage(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String current,
    required String exclude,
    required ValueChanged<String> onSelected,
  }) {
    final options =
        SupportedLanguage.all.where((l) => l.code != exclude).toList();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          for (final lang in options)
            ListTile(
              leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
              title: Text(lang.name),
              subtitle: Text(lang.nativeName),
              trailing: lang.code == current
                  ? const Icon(Icons.check, color: Color(0xFF7C4DFF))
                  : null,
              onTap: () {
                onSelected(lang.code);
                Navigator.pop(ctx);
              },
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
