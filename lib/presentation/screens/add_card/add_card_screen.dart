import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/services/example_sentence_service.dart';
import '../../../data/services/translation_service.dart';
import '../../../domain/entities/deck.dart';
import '../../../domain/entities/flashcard.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/repository_providers.dart';

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
  late TextEditingController _exampleCtrl;

  String? _selectedDeckId;
  bool _saving = false;
  bool _translatingDeToEn = false;
  bool _translatingEnToDe = false;
  bool _loadingExample = false;

  @override
  void initState() {
    super.initState();
    final c = widget.editCard;
    _germanCtrl = TextEditingController(text: c?.german ?? '');
    _englishCtrl = TextEditingController(text: c?.english ?? '');
    _exampleCtrl = TextEditingController(text: c?.notes ?? '');
    _selectedDeckId = c?.deckId;
  }

  @override
  void dispose() {
    _germanCtrl.dispose();
    _englishCtrl.dispose();
    _exampleCtrl.dispose();
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
            _sectionHeader('Word'),
            _Field(
              controller: _germanCtrl,
              label: AppStrings.germanWord,
              required: true,
              suffix: _translatingDeToEn
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Translate to English',
                      icon: const Icon(Icons.translate),
                      onPressed: _translateGermanToEnglish,
                    ),
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _englishCtrl,
              label: AppStrings.englishWord,
              required: true,
              suffix: _translatingEnToDe
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Translate to German',
                      icon: const Icon(Icons.translate),
                      onPressed: _translateEnglishToGerman,
                    ),
            ),
            const SizedBox(height: 16),

            _sectionHeader('Example'),
            _Field(
              controller: _exampleCtrl,
              label: 'Example',
              maxLines: 3,
              suffix: _loadingExample
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      tooltip: 'Generate easy sentence from German word',
                      icon: const Icon(Icons.auto_awesome),
                      onPressed: _generateExampleSentence,
                    ),
            ),
            const SizedBox(height: 20),

            _sectionHeader('Deck'),
            decksAsync.when(
              data: (decks) => _DeckSelector(
                decks: decks,
                selectedId: _selectedDeckId,
                onChanged: (id) => setState(() => _selectedDeckId = id),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, stackTrace) => const Text('Error loading decks'),
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

    try {
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
          notes: _exampleCtrl.text.trim(),
          deckId: _selectedDeckId,
        );
        await ref.read(cardNotifierProvider.notifier).updateCard(updated);
      } else {
        final duplicate = await _findDuplicateInDeck(
          deckId: _selectedDeckId!,
          germanWord: _germanCtrl.text,
        );

        if (duplicate != null && mounted) {
          final action = await _showDuplicateDialog(duplicate);
          if (action == _DuplicateAction.edit) {
            if (mounted) {
              await context.push('/edit-card', extra: duplicate);
            }
            return;
          }
          // Skip adding by default when duplicate exists.
          return;
        }

        final card = buildNewCard(
          deckId: _selectedDeckId!,
          german: _germanCtrl.text.trim(),
          english: _englishCtrl.text.trim(),
          notes: _exampleCtrl.text.trim(),
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

  Future<Flashcard?> _findDuplicateInDeck({
    required String deckId,
    required String germanWord,
  }) async {
    final needle = germanWord.trim().toLowerCase();
    if (needle.isEmpty) return null;

    final cards = await ref.read(cardRepositoryProvider).getByDeck(deckId);
    for (final card in cards) {
      if (card.german.trim().toLowerCase() == needle) {
        return card;
      }
    }
    return null;
  }

  Future<_DuplicateAction> _showDuplicateDialog(Flashcard duplicate) async {
    final action = await showDialog<_DuplicateAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate found'),
        content: Text(
          'The word "${duplicate.german}" already exists in this deck. Do you want to edit the original card?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_DuplicateAction.skip),
            child: const Text('Skip'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_DuplicateAction.edit),
            child: const Text('Edit Original'),
          ),
        ],
      ),
    );

    return action ?? _DuplicateAction.skip;
  }

  Future<void> _translateGermanToEnglish() async {
    final german = _germanCtrl.text.trim();
    if (german.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a German word first')),
      );
      return;
    }

    setState(() => _translatingDeToEn = true);
    try {
      final translated = await TranslationService.translateToEnglish(german);
      if (!mounted) return;

      if (translated.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not translate German to English')),
        );
        return;
      }
      _englishCtrl.text = translated;
    } finally {
      if (mounted) setState(() => _translatingDeToEn = false);
    }
  }

  Future<void> _translateEnglishToGerman() async {
    final english = _englishCtrl.text.trim();
    if (english.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type an English word first')),
      );
      return;
    }

    setState(() => _translatingEnToDe = true);
    try {
      final translated = await TranslationService.translateToGerman(english);
      if (!mounted) return;

      if (translated.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not translate English to German')),
        );
        return;
      }
      _germanCtrl.text = translated;
    } finally {
      if (mounted) setState(() => _translatingEnToDe = false);
    }
  }

  Future<void> _generateExampleSentence() async {
    final german = _germanCtrl.text.trim();
    if (german.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a German word first')),
      );
      return;
    }

    setState(() => _loadingExample = true);
    try {
      final sentence = await ExampleSentenceService.fetchSimpleGermanSentence(german);
      if (!mounted) return;

      if (sentence.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No simple sentence found for this word')),
        );
        return;
      }

      _exampleCtrl.text = sentence;
    } finally {
      if (mounted) setState(() => _loadingExample = false);
    }
  }

  void _clearForm() {
    if (widget.editCard != null) {
      _safeBack(context);
      return;
    }

    _germanCtrl.clear();
    _englishCtrl.clear();
    _exampleCtrl.clear();
  }

  void _safeBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }
}

enum _DuplicateAction { edit, skip }

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final int maxLines;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.label,
    this.required = false,
    this.maxLines = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffix,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
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
      initialValue: selectedId,
      decoration: const InputDecoration(labelText: AppStrings.selectDeck),
      hint: const Text('Select a deck'),
      items: decks
          .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
