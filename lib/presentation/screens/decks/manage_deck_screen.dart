import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/flashcard.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/article_badge.dart';
import '../../widgets/memory_stage_badge.dart';

class ManageDeckScreen extends ConsumerStatefulWidget {
  final String deckId;
  const ManageDeckScreen({super.key, required this.deckId});

  @override
  ConsumerState<ManageDeckScreen> createState() => _ManageDeckScreenState();
}

class _ManageDeckScreenState extends ConsumerState<ManageDeckScreen> {
  final Set<String> _selectedCards = {};

  void _toggleSelection(String cardId) {
    setState(() {
      if (_selectedCards.contains(cardId)) {
        _selectedCards.remove(cardId);
      } else {
        _selectedCards.add(cardId);
      }
    });
  }

  void _selectAll(List<Flashcard> cards) {
    setState(() {
      if (_selectedCards.length == cards.length) {
        _selectedCards.clear();
      } else {
        _selectedCards.addAll(cards.map((c) => c.id));
      }
    });
  }

  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Cards?'),
        content: Text('Are you sure you want to delete ${_selectedCards.length} cards?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final id in _selectedCards) {
        await ref.read(cardNotifierProvider.notifier).deleteCard(id);
      }
      setState(() => _selectedCards.clear());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cards deleted')));
    }
  }

  Future<void> _moveSelected() async {
    final decks = ref.read(decksStreamProvider).valueOrNull ?? [];
    final targetDecks = decks.where((d) => d.id != widget.deckId).toList();
    if (targetDecks.isEmpty) return;

    final targetDeckId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Move to Deck'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: targetDecks.map((d) => ListTile(
            title: Text(d.name),
            onTap: () => Navigator.pop(ctx, d.id),
          )).toList(),
        ),
      ),
    );

    if (targetDeckId != null) {
      for (final id in _selectedCards) {
        await ref.read(cardNotifierProvider.notifier).moveCard(id, targetDeckId);
      }
      setState(() => _selectedCards.clear());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cards moved')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(cardsForDeckProvider(widget.deckId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${_selectedCards.length} selected'),
        actions: [
          if (cardsAsync.valueOrNull != null)
            TextButton(
              onPressed: () => _selectAll(cardsAsync.value!),
              child: Text(_selectedCards.length == cardsAsync.value!.length ? 'Deselect All' : 'Select All'),
            ),
        ],
      ),
      body: cardsAsync.when(
        data: (cards) => ListView.builder(
          itemCount: cards.length,
          itemBuilder: (ctx, i) {
            final card = cards[i];
            final isSelected = _selectedCards.contains(card.id);
            return ListTile(
              leading: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleSelection(card.id),
              ),
              title: Text(card.german, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(card.english),
              trailing: MemoryStageBadge(stage: card.memoryStage),
              onTap: () => _toggleSelection(card.id),
              selected: isSelected,
              selectedTileColor: AppColors.primary.withOpacity(0.1),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: _selectedCards.isEmpty ? null : BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.drive_file_move),
              label: const Text('Move'),
              onPressed: _moveSelected,
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: _deleteSelected,
            ),
          ],
        ),
      ),
    );
  }
}
