import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/text_tokenizer.dart';
import '../../../data/services/translation_service.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';

/// Allows pasting a block of text, selecting individual words, then
/// saving each selected word to a chosen deck as a card stub for later editing.
class TextToCardScreen extends ConsumerStatefulWidget {
  final String? preselectedDeckId;
  const TextToCardScreen({super.key, this.preselectedDeckId});

  @override
  ConsumerState<TextToCardScreen> createState() => _TextToCardScreenState();
}

class _TextToCardScreenState extends ConsumerState<TextToCardScreen> {
  final _textCtrl = TextEditingController();
  List<String> _tokens = [];
  final Set<String> _selected = {};
  String? _deckId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _deckId = widget.preselectedDeckId;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _tokenize() {
    setState(() {
      _tokens = TextTokenizer.tokenize(_textCtrl.text);
      _selected.clear();
    });
  }

  Future<void> _saveSelected() async {
    if (_selected.isEmpty || _deckId == null) return;
    setState(() => _saving = true);
    try {
      final selectedWords = _tokens.where(_selected.contains).toList();
      final translatedWords = await Future.wait(
        selectedWords.map(TranslationService.translateToEnglish),
      );

      final cards = List.generate(selectedWords.length, (i) {
        final word = selectedWords[i];
        final translated = translatedWords[i];
        return buildNewCard(
          deckId: _deckId!,
          german: word,
          english: translated,
          notes: translated.isEmpty ? 'Auto-translation failed' : '',
        );
      });

      await ref.read(cardNotifierProvider.notifier).addAll(cards);

      final translatedCount =
          translatedWords.where((t) => t.trim().isNotEmpty).length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$translatedCount/${cards.length} words translated and saved.',
            ),
          ),
        );
        setState(() {
          _selected.clear();
          _tokens.clear();
          _textCtrl.clear();
        });
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Text to Cards'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/add-hub');
            }
          },
        ),
      ),
      body: Column(
        children: [
          // ── Text input area ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _textCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Paste German text',
                    hintText: 'Paste German text only…',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textCtrl.clear();
                        setState(() {
                          _tokens.clear();
                          _selected.clear();
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _tokenize,
                        icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                        label: const Text('Tokenize Words'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Deck selector ──────────────────────────────────────────────────
          if (_tokens.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: decksAsync.when(
                data: (decks) => DropdownButtonFormField<String>(
                  value: _deckId,
                  decoration:
                      const InputDecoration(labelText: AppStrings.selectDeck),
                  hint: const Text('Select target deck'),
                  items: decks
                      .map((d) =>
                          DropdownMenuItem(value: d.id, child: Text(d.name)))
                      .toList(),
                  onChanged: (id) => setState(() => _deckId = id),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          // ── Word chips ─────────────────────────────────────────────────────
          if (_tokens.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_selected.length} selected',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_selected.length == _tokens.length) {
                        _selected.clear();
                      } else {
                        _selected.addAll(_tokens);
                      }
                    }),
                    child: Text(_selected.length == _tokens.length
                        ? 'Deselect all'
                        : 'Select all'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
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
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: (_selected.isNotEmpty && _deckId != null && !_saving)
                    ? _saveSelected
                    : null,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        'Save ${_selected.length} Words as Cards',
                      ),
              ),
            ),
          ] else
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.text_fields,
                        size: 48, color: Colors.grey.shade600),
                    const SizedBox(height: 12),
                    Text(
                      'Paste German text above and tap\n"Tokenize Words" to begin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
