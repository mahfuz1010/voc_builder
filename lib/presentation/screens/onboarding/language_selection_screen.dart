import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/supported_languages.dart';
import '../../providers/settings_provider.dart';

/// Shown on first launch. The user picks the language they want to learn
/// and their native language, then the app is fully configured.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String _targetCode = 'de';
  String _nativeCode = 'en';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final targetLang = SupportedLanguage.fromCode(_targetCode);
    final nativeLang = SupportedLanguage.fromCode(_nativeCode);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Welcome to\nVocBuilder',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your language profile to get started.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // ── Target language ──────────────────────────────────────────
              _SectionLabel(label: 'I want to learn'),
              const SizedBox(height: 8),
              _LanguagePicker(
                selected: _targetCode,
                exclude: _nativeCode,
                onChanged: (code) => setState(() => _targetCode = code),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${targetLang.flag}  ${targetLang.name} — ${targetLang.nativeName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 32),

              // ── Native language ───────────────────────────────────────────
              _SectionLabel(label: 'My native language is'),
              const SizedBox(height: 8),
              _LanguagePicker(
                selected: _nativeCode,
                exclude: _targetCode,
                onChanged: (code) => setState(() => _nativeCode = code),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '${nativeLang.flag}  ${nativeLang.name} — ${nativeLang.nativeName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _confirm,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Let\'s go!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setTargetLanguage(_targetCode);
    await notifier.setNativeLanguage(_nativeCode);
    await notifier.setOnboarded();
    if (mounted) context.go('/home');
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final String selected;
  final String exclude;
  final ValueChanged<String> onChanged;

  const _LanguagePicker({
    required this.selected,
    required this.exclude,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = SupportedLanguage.all
        .where((l) => l.code != exclude)
        .toList();

    return DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: options.map((lang) {
        return DropdownMenuItem(
          value: lang.code,
          child: Text('${lang.flag}  ${lang.name}'),
        );
      }).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
