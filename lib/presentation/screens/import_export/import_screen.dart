import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/services/import_export_service.dart';
import '../../../domain/entities/flashcard.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/article_badge.dart';

class ImportScreen extends ConsumerStatefulWidget {
  final String? preselectedDeckId;
  const ImportScreen({super.key, this.preselectedDeckId});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  List<Flashcard>? _preview;
  String? _deckId;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _deckId = widget.preselectedDeckId;
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'json', 'txt'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final ext = path.split('.').last;

    if (_deckId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a target deck first.')));
      return;
    }

    final content = File(path).readAsStringSync();
    final cards = ImportService.parseContent(content, ext, _deckId!);

    setState(() => _preview = cards);
  }

  Future<void> _confirmImport() async {
    if (_preview == null || _preview!.isEmpty) return;
    setState(() => _importing = true);
    try {
      await ref.read(cardNotifierProvider.notifier).addAll(_preview!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_preview!.length} cards imported!')),
        );
        setState(() => _preview = null);
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.importTitle),
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
          // ── Deck selector ──────────────────────────────────────────────────
          decksAsync.when(
            data: (decks) => DropdownButtonFormField<String>(
              value: _deckId,
              decoration: const InputDecoration(labelText: AppStrings.selectDeck),
              hint: const Text('Select target deck'),
              items: decks
                  .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                  .toList(),
              onChanged: (id) => setState(() => _deckId = id),
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),

          // ── Pick file ──────────────────────────────────────────────────────
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Pick File (CSV / JSON / TXT)'),
          ),

          const SizedBox(height: 8),
          const Text(
            'Supported formats:\n'
            '  CSV/TSV: german;english;article;plural\n'
            '  CSV/TSV headers: front\\tback\\thint\\tpublishedAt\n'
            '  TXT: german | english\n'
            '  JSON: [{"german":"...","english":"..."}]',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),

          if (_preview != null) ...[
            const SizedBox(height: 20),
            Text(
              '${AppStrings.previewCards}: ${_preview!.length} cards',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ..._preview!.take(20).map(
                  (c) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: ArticleBadge(article: c.article),
                      title: Text(c.german,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(c.english,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  ),
                ),
            if (_preview!.length > 20)
              Text(
                '… and ${_preview!.length - 20} more',
                style: const TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importing ? null : _confirmImport,
              child: _importing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('${AppStrings.confirmImport} (${_preview!.length})'),
            ),
          ],
        ],
      ),
    );
  }
}
