import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/supported_languages.dart';
import '../../../core/utils/text_tokenizer.dart';
import '../../../data/services/image_text_ocr_service.dart';
import '../../../data/services/translation_service.dart';
import '../../../data/services/word_info_service.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/settings_provider.dart';

/// Lets the user capture or pick an image, reads text from it via OCR,
/// then select individual words to save as new flashcards.
class ImageToCardScreen extends ConsumerStatefulWidget {
  final String? preselectedDeckId;
  const ImageToCardScreen({super.key, this.preselectedDeckId});

  @override
  ConsumerState<ImageToCardScreen> createState() => _ImageToCardScreenState();
}

class _ImageToCardScreenState extends ConsumerState<ImageToCardScreen> {
  List<String> _tokens = [];
  final Set<String> _selected = {};
  String? _deckId;
  bool _saving = false;
  bool _extracting = false;
  String _extractedText = '';

  @override
  void initState() {
    super.initState();
    _deckId = widget.preselectedDeckId;
  }

  // ── OCR ────────────────────────────────────────────────────────────────────

  Future<void> _pickAndExtract(ImageSource source) async {
    setState(() {
      _extracting = true;
      _tokens = [];
      _selected.clear();
      _extractedText = '';
    });
    try {
      final raw = await ImageTextOcrService.pickAndExtractText(source);
      if (!mounted) return;

      if (raw.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No readable text found in image.')),
        );
        return;
      }

      final normalized = TextTokenizer.normalizeOcrText(raw);
      final tokens = TextTokenizer.tokenizeForOcrVocabulary(normalized);

      if (tokens.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Text found, but only filtered items (numbers/emails/adjectives/noise) were detected.',
            ),
          ),
        );
        return;
      }

      setState(() {
        _extractedText = normalized;
        _tokens = tokens;
      });
    } finally {
      if (mounted) setState(() => _extracting = false);
    }
  }

  // ── Save ───────────────────────────────────────────────────────────────────

  Future<void> _saveSelected() async {
    if (_selected.isEmpty || _deckId == null) return;
    setState(() => _saving = true);
    try {
      final words = _tokens.where(_selected.contains).toList();
      final settings = ref.read(settingsProvider).valueOrNull;
      final nativeCode = settings?.nativeLanguage ?? 'en';
      
      // Translate words
      final translations = await Future.wait(
        words.map((w) => TranslationService.translate(w, to: nativeCode)),
      );

      // Fetch word info for each word in parallel
      final wordInfos = await Future.wait(
        words.map((w) => WordInfoService.fetchWordInfo(w)),
      );

      final cards = List.generate(words.length, (i) => buildNewCard(
        deckId: _deckId!,
        german: words[i],
        english: translations[i],
        notes: translations[i].isEmpty ? 'Auto-translation failed' : '',
        wordInfo: wordInfos[i],
      ));

      await ref.read(cardNotifierProvider.notifier).addAll(cards);
      final translated = translations.where((t) => t.isNotEmpty).length;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$translated/${cards.length} words translated and saved.')),
      );
      setState(() {
        _tokens = [];
        _selected.clear();
        _extractedText = '';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksStreamProvider);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final targetLang = SupportedLanguage.fromCode(settings?.targetLanguage ?? 'de');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to Cards'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/add-hub'),
        ),
      ),
      body: Column(
        children: [
          // ── Image source buttons ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _extracting ? null : () => _pickAndExtract(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Take Photo'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          backgroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _extracting ? null : () => _pickAndExtract(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_extracting) ...[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 6),
                  Text(
                    'Scanning image for ${targetLang.name} text…',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Empty state ────────────────────────────────────────────────────
          if (_tokens.isEmpty && !_extracting)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.document_scanner_outlined,
                        size: 64,
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Take a photo or pick an image\nof a ${targetLang.name} text or vocabulary list.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Extracted text preview ─────────────────────────────────────────
          if (_tokens.isNotEmpty) ...[
            if (_extractedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: Text(
                    'Extracted text (${_tokens.length} words found)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 120),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _extractedText,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Deck selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: decksAsync.when(
                data: (decks) => DropdownButtonFormField<String>(
                  initialValue: _deckId,
                  decoration: const InputDecoration(labelText: AppStrings.selectDeck),
                  hint: const Text('Select target deck'),
                  items: decks
                      .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                      .toList(),
                  onChanged: (id) => setState(() => _deckId = id),
                ),
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),
            ),

            // Select all / count header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selected.length} selected',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_selected.length == _tokens.length) {
                        _selected.clear();
                      } else {
                        _selected.addAll(_tokens);
                      }
                    }),
                    child: Text(
                      _selected.length == _tokens.length ? 'Deselect all' : 'Select all',
                    ),
                  ),
                ],
              ),
            ),

            // Word chips
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _tokens.map((token) {
                    final selected = _selected.contains(token);
                    return FilterChip(
                      label: Text(token),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _selected.add(token);
                        } else {
                          _selected.remove(token);
                        }
                      }),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Save button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selected.isNotEmpty && _deckId != null && !_saving)
                          ? _saveSelected
                          : null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 52)),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Save ${_selected.length} Words as Cards'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
