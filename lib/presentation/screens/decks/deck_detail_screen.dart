import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/flashcard.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';
import '../../widgets/article_badge.dart';
import '../../widgets/memory_stage_badge.dart';

class DeckDetailScreen extends ConsumerWidget {
  final String deckId;
  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(decksStreamProvider);
    final cardsAsync = ref.watch(cardsForDeckProvider(deckId));
    final dueAsync = ref.watch(dueCardsByDeckProvider(deckId));

    final deckName = deckAsync.valueOrNull
            ?.where((d) => d.id == deckId)
            .firstOrNull
            ?.name ??
        '...';

    return Scaffold(
      appBar: AppBar(
        title: Text(deckName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: AppStrings.importDeck,
            onPressed: () => context.go('/import?deckId=$deckId'),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: AppStrings.exportDeck,
            onPressed: () => context.go('/export?deckId=$deckId'),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primary),
            tooltip: 'Study this deck',
            onPressed: () =>
                context.go('/study', extra: {'deckId': deckId}),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add?deckId=$deckId'),
        child: const Icon(Icons.add),
      ),
      body: cardsAsync.when(
        data: (cards) {
          final dueCount = dueAsync.valueOrNull?.length ?? 0;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: dueCount > 0
                        ? () => context.go('/study', extra: {'deckId': deckId})
                        : null,
                    icon: const Icon(Icons.school_rounded),
                    label: Text(
                      dueCount > 0
                          ? 'Learn This Deck ($dueCount due)'
                          : 'No cards due in this deck',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: cards.isEmpty
                    ? const _EmptyDeck()
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cards.length,
                        itemBuilder: (_, i) => _CardTile(
                          card: cards[i],
                          deckId: deckId,
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CardTile extends ConsumerWidget {
  final Flashcard card;
  final String deckId;
  const _CardTile({required this.card, required this.deckId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: ArticleBadge(article: card.article),
        title: Text(
          card.german,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.articleColor(card.article),
          ),
        ),
        subtitle: Text(
          card.english,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MemoryStageBadge(stage: card.memoryStage),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
        onTap: () => _showCardActions(context, ref),
      ),
    );
  }

  void _showCardActions(BuildContext context, WidgetRef ref) {
    final decksAsync = ref.read(decksStreamProvider);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Card'),
              onTap: () {
                Navigator.pop(context);
                context.go('/edit-card', extra: card);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outline),
              title: const Text(AppStrings.moveTo),
              onTap: () {
                Navigator.pop(context);
                _showMoveTo(context, ref, decksAsync.valueOrNull ?? []);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Card',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                ref.read(cardNotifierProvider.notifier).deleteCard(card.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveTo(BuildContext context, WidgetRef ref, List decks) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.moveTo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: decks
              .where((d) => d.id != deckId)
              .map<Widget>((d) => ListTile(
                    title: Text(d.name),
                    onTap: () async {
                      await ref
                          .read(cardNotifierProvider.notifier)
                          .moveCard(card.id, d.id);
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _EmptyDeck extends StatelessWidget {
  const _EmptyDeck();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No cards in this deck.\nTap + to add cards.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );
  }
}
