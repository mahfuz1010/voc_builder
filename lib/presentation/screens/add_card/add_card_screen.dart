import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/article.dart';
import '../../../core/enums/word_type.dart';
import '../../../data/services/translation_service.dart';
import '../../../domain/entities/flashcard.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';
import '../../../domain/entities/deck.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  final Flashcard? editCard; // null = new card
  const AddCardScreen({super.key, this.editCard});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _germanCtrl;
  late TextEditingController _englishCtrl;
  late TextEditingController _pluralCtrl;
  late TextEditingController _exampleDeCtrl;
  late TextEditingController _exampleEnCtrl;
  late TextEditingController _verbIchCtrl;
  late TextEditingController _partizipCtrl;
  late TextEditingController _comparativeCtrl;
  late TextEditingController _superlativeCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  Article _article = Article.none;
  WordType _wordType = WordType.other;
  String? _selectedDeckId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.editCard;
    _germanCtrl      = TextEditingController(text: c?.german ?? '');
    _englishCtrl     = TextEditingController(text: c?.english ?? '');
    _pluralCtrl      = TextEditingController(text: c?.plural ?? '');
    _exampleDeCtrl   = TextEditingController(text: c?.exampleDe ?? '');
    _exampleEnCtrl   = TextEditingController(text: c?.exampleEn ?? '');
    _verbIchCtrl     = TextEditingController(text: c?.verbIchForm ?? '');
    _partizipCtrl    = TextEditingController(text: c?.partizipII ?? '');
    _comparativeCtrl = TextEditingController(text: c?.comparative ?? '');
    _superlativeCtrl = TextEditingController(text: c?.superlative ?? '');
    _notesCtrl       = TextEditingController(text: c?.notes ?? '');
    _tagsCtrl        = TextEditingController(text: c?.tags.join(', ') ?? '');
    _article         = c?.article ?? Article.none;
    _wordType        = c?.wordType ?? WordType.other;
    _selectedDeckId  = c?.deckId;
  }

  @override
  void dispose() {
    for (final c in [
      _germanCtrl, _englishCtrl, _pluralCtrl, _exampleDeCtrl, _exampleEnCtrl,
      _verbIchCtrl, _partizipCtrl, _comparativeCtrl, _superlativeCtrl,
      _notesCtrl, _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksStreamProvider);
    final isEdit = widget.editCard != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? AppStrings.editCard : AppStrings.addCard),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _safeBack(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Core fields ──────────────────────────────────────────────────
            _sectionHeader('Word'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: _ArticleDropdown(
                    value: _article,
                    onChanged: (a) => setState(() => _article = a),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Field(
                    controller: _germanCtrl,
                    label: AppStrings.germanWord,
                    required: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _englishCtrl,
              label: AppStrings.englishWord,
              required: true,
            ),
            const SizedBox(height: 12),

            // ── Type & grammar ───────────────────────────────────────────────
            _sectionHeader('Grammar'),
            _WordTypeDropdown(
              value: _wordType,
              onChanged: (t) => setState(() => _wordType = t),
            ),
            const SizedBox(height: 12),

            if (_wordType == WordType.noun) ...[
              _Field(controller: _pluralCtrl, label: AppStrings.pluralForm),
              const SizedBox(height: 12),
            ],
            if (_wordType == WordType.verb) ...[
              _Field(controller: _verbIchCtrl, label: AppStrings.verbIch),
              const SizedBox(height: 12),
              _Field(controller: _partizipCtrl, label: AppStrings.partizipII),
              const SizedBox(height: 12),
            ],
            if (_wordType == WordType.adjective) ...[
              _Field(controller: _comparativeCtrl, label: AppStrings.comparative),
              const SizedBox(height: 12),
              _Field(controller: _superlativeCtrl, label: AppStrings.superlative),
              const SizedBox(height: 12),
            ],

            // ── Examples ─────────────────────────────────────────────────────
            _sectionHeader('Examples'),
            _Field(controller: _exampleDeCtrl, label: AppStrings.exampleDe, maxLines: 2),
            const SizedBox(height: 12),
            _Field(controller: _exampleEnCtrl, label: AppStrings.exampleEn, maxLines: 2),
            const SizedBox(height: 12),

            // ── Notes & tags ──────────────────────────────────────────────────
            _sectionHeader('Notes'),
            _Field(controller: _notesCtrl, label: AppStrings.notes, maxLines: 3),
            const SizedBox(height: 12),
            _Field(controller: _tagsCtrl, label: AppStrings.tags),
            const SizedBox(height: 20),

            // ── Deck selector ─────────────────────────────────────────────────
            _sectionHeader('Deck'),
            decksAsync.when(
              data: (decks) => _DeckSelector(
                decks: decks,
                selectedId: _selectedDeckId,
                onChanged: (id) => setState(() => _selectedDeckId = id),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading decks'),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppStrings.saveCard),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    try {
      await _autofillMissingTranslation();

      if (!_formKey.currentState!.validate()) return;
      if (_selectedDeckId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a deck')),
        );
        return;
      }

      if (widget.editCard != null) {
        final updated = widget.editCard!.copyWith(
          german: _germanCtrl.text.trim(),
          english: _englishCtrl.text.trim(),
          article: _article,
          plural: _pluralCtrl.text.trim(),
          wordType: _wordType,
          exampleDe: _exampleDeCtrl.text.trim(),
          exampleEn: _exampleEnCtrl.text.trim(),
          verbIchForm: _verbIchCtrl.text.trim(),
          partizipII: _partizipCtrl.text.trim(),
          comparative: _comparativeCtrl.text.trim(),
          superlative: _superlativeCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          tags: tags,
          deckId: _selectedDeckId,
        );
        await ref.read(cardNotifierProvider.notifier).updateCard(updated);
      } else {
        final card = buildNewCard(
          deckId: _selectedDeckId!,
          german: _germanCtrl.text.trim(),
          english: _englishCtrl.text.trim(),
          article: _article,
          plural: _pluralCtrl.text.trim(),
          wordType: _wordType,
          exampleDe: _exampleDeCtrl.text.trim(),
          exampleEn: _exampleEnCtrl.text.trim(),
          verbIchForm: _verbIchCtrl.text.trim(),
          partizipII: _partizipCtrl.text.trim(),
          comparative: _comparativeCtrl.text.trim(),
          superlative: _superlativeCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          tags: tags,
        );
        await ref.read(cardNotifierProvider.notifier).addCard(card);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.editCard != null ? 'Card updated!' : 'Card saved!')),
        );
        _clearForm();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _autofillMissingTranslation() async {
    final german = _germanCtrl.text.trim();
    final english = _englishCtrl.text.trim();

    if (german.isEmpty && english.isNotEmpty) {
      final translated = await TranslationService.translateToGerman(english);
      if (translated.isNotEmpty) {
        _germanCtrl.text = translated;
      }
      return;
    }

    if (english.isEmpty && german.isNotEmpty) {
      final translated = await TranslationService.translateToEnglish(german);
      if (translated.isNotEmpty) {
        _englishCtrl.text = translated;
      }
    }
  }

  void _clearForm() {
    if (widget.editCard != null) {
      _safeBack(context);
      return;
    }
    for (final c in [
      _germanCtrl, _englishCtrl, _pluralCtrl, _exampleDeCtrl, _exampleEnCtrl,
      _verbIchCtrl, _partizipCtrl, _comparativeCtrl, _superlativeCtrl,
      _notesCtrl, _tagsCtrl,
    ]) {
      c.clear();
    }
    setState(() {
      _article = Article.none;
      _wordType = WordType.other;
    });
  }

  void _safeBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;

  const _Field({
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
    );
  }
}

class _ArticleDropdown extends StatelessWidget {
  final Article value;
  final ValueChanged<Article> onChanged;

  const _ArticleDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Article>(
      value: value,
      decoration: const InputDecoration(labelText: 'Article'),
      items: Article.values
          .map((a) => DropdownMenuItem(
                value: a,
                child: Text(
                  a.displayLabel,
                  style: TextStyle(
                    color: AppColors.articleColor(a),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ))
          .toList(),
      onChanged: (a) => onChanged(a ?? Article.none),
    );
  }
}

class _WordTypeDropdown extends StatelessWidget {
  final WordType value;
  final ValueChanged<WordType> onChanged;

  const _WordTypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<WordType>(
      value: value,
      decoration: const InputDecoration(labelText: AppStrings.wordType),
      items: WordType.values
          .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
          .toList(),
      onChanged: (t) => onChanged(t ?? WordType.other),
    );
  }
}

class _DeckSelector extends StatelessWidget {
  final List<Deck> decks;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _DeckSelector({
    required this.decks,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (decks.isEmpty) {
      return const Text(
        'No decks available. Create a deck first.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return DropdownButtonFormField<String>(
      value: selectedId,
      decoration: const InputDecoration(labelText: AppStrings.selectDeck),
      hint: const Text('Select a deck'),
      items: decks
          .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
