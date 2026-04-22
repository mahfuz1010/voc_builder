import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/services/import_export_service.dart';
import '../../../domain/entities/flashcard.dart';
import '../../providers/deck_provider.dart';
import '../../providers/repository_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final String? deckId;
  const ExportScreen({super.key, this.deckId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String _format = 'csv';
  bool _exporting = false;

  Future<void> _export({required bool allDecks}) async {
    setState(() => _exporting = true);
    try {
      List<Flashcard> cards = [];
      final repo = ref.read(cardRepositoryProvider);

      if (allDecks) {
        final decks = await ref.read(deckRepositoryProvider).getAll();
        for (final d in decks) {
          cards.addAll(await repo.getByDeck(d.id));
        }
      } else if (widget.deckId != null) {
        cards = await repo.getByDeck(widget.deckId!);
      }

      final content = _format == 'json'
          ? ExportService.toJson(cards)
          : ExportService.toCsv(cards);

      final tempDir = await getTemporaryDirectory();
      final fileName = 'vocbuilder_export_${DateTime.now().millisecondsSinceEpoch}.$_format';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'VocBuilder Export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasDeck = widget.deckId != null;
    final decksAsync = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.exportTitle),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Format picker
          const Text('Format',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              _FormatChip(
                label: 'CSV',
                selected: _format == 'csv',
                onTap: () => setState(() => _format = 'csv'),
              ),
              const SizedBox(width: 10),
              _FormatChip(
                label: 'JSON',
                selected: _format == 'json',
                onTap: () => setState(() => _format = 'json'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (hasDeck) ...[
            decksAsync.when(
              data: (decks) {
                final name = decks
                    .where((d) => d.id == widget.deckId)
                    .firstOrNull
                    ?.name;
                return ElevatedButton.icon(
                  onPressed:
                      _exporting ? null : () => _export(allDecks: false),
                  icon: const Icon(Icons.file_upload_outlined),
                  label: Text('Export "$name" deck'),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],

          ElevatedButton.icon(
            onPressed: _exporting ? null : () => _export(allDecks: true),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text(AppStrings.exportAll),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
            ),
          ),

          if (_exporting) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator.adaptive()),
          ],
        ],
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FormatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF7C4DFF) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? const Color(0xFF7C4DFF) : Colors.grey.shade700),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
