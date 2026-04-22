import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/memory_stage.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';

class StageCardsScreen extends ConsumerWidget {
  final int stageIndex;
  const StageCardsScreen({super.key, required this.stageIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stage = MemoryStage.fromDbValue(stageIndex);
    final cardsAsync = ref.watch(cardsByStageProvider(stage));
    final decksAsync = ref.watch(decksStreamProvider);

    final title = switch (stage) {
      MemoryStage.shortTerm => 'Short-term Cards',
      MemoryStage.longTerm => 'Long-term Cards',
      MemoryStage.newCard => 'New Cards',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cards) {
          final deckMap = {
            for (final d in decksAsync.valueOrNull ?? const []) d.id: d.name,
          };

          if (cards.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No ${stage.label.toLowerCase()} cards right now.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final deckName = deckMap[card.deckId] ?? 'Unknown deck';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    card.german,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('${card.english} • $deckName'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () => context.go('/decks/${card.deckId}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
