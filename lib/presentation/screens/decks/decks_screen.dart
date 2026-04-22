import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/deck.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';

class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.watch(decksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.decks)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDeck(context, ref),
        child: const Icon(Icons.add),
      ),
      body: decksAsync.when(
        data: (decks) => decks.isEmpty
            ? const _EmptyView()
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: decks.length,
                itemBuilder: (_, i) => _DeckCard(deck: decks[i]),
              ),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showCreateDeck(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.newDeck),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: AppStrings.deckName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await ref
                    .read(deckNotifierProvider.notifier)
                    .createDeck(ctrl.text.trim());
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text(AppStrings.create),
          ),
        ],
      ),
    );
  }
}

class _DeckCard extends ConsumerWidget {
  final Deck deck;
  const _DeckCard({required this.deck});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(cardsForDeckProvider(deck.id));
    final dueAsync = ref.watch(dueCardsByDeckProvider(deck.id));
    final total = statsAsync.valueOrNull?.length ?? 0;
    final due = dueAsync.valueOrNull?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF3D2B89),
          child: Icon(Icons.layers, color: Colors.white70),
        ),
        title: Text(deck.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(
          '$total ${AppStrings.cards}  •  $due due',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () => _showMenu(context, ref),
            ),
          ],
        ),
        onTap: () => context.go('/decks/${deck.id}'),
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text(AppStrings.renameDeck),
              onTap: () {
                Navigator.pop(context);
                _showRename(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text(AppStrings.exportDeck),
              onTap: () {
                Navigator.pop(context);
                context.go('/export?deckId=${deck.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(AppStrings.deleteDeck,
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRename(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: deck.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.renameDeck),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: AppStrings.deckName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await ref
                    .read(deckNotifierProvider.notifier)
                    .renameDeck(deck.id, ctrl.text.trim());
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              }
            },
            child: const Text(AppStrings.rename),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.deleteDeck),
        content: Text('Delete "${deck.name}"? This will remove all its cards.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await ref
                  .read(deckNotifierProvider.notifier)
                  .deleteDeck(deck.id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No decks yet.\nTap + to create one.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );
  }
}
