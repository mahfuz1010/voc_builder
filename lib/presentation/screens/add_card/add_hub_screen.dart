import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/supported_languages.dart';
import '../../providers/settings_provider.dart';

/// Hub screen reached via the "Add" bottom nav tab.
/// Offers quick navigation to manual card creation or text-to-card flow.
class AddHubScreen extends ConsumerWidget {
  const AddHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final targetLang = SupportedLanguage.fromCode(settings?.targetLanguage ?? 'de');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Cards'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OptionCard(
              icon: Icons.add_card_outlined,
              title: 'Add Card Manually',
              subtitle: 'Fill in all fields for a single card',
              color: AppColors.primary,
              onTap: () => context.go('/add'),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.text_snippet_outlined,
              title: 'Text to Cards',
              subtitle: 'Paste ${targetLang.name} text, select words, create stubs',
              color: AppColors.secondary,
              onTap: () => context.go('/text-to-card'),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.document_scanner_outlined,
              title: 'Image to Cards',
              subtitle: 'Scan or pick a photo, extract ${targetLang.name} words',
              color: const Color(0xFF26C6DA),
              onTap: () => context.go('/image-to-card'),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.file_download_outlined,
              title: 'Import File',
              subtitle: 'CSV, JSON or TXT vocabulary file',
              color: AppColors.shortTermStageColor,
              onTap: () => context.go('/import'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
