import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/deck.dart';
import 'repository_providers.dart';

// ── Watch all decks (stream) ──────────────────────────────────────────────────

final decksStreamProvider = StreamProvider<List<Deck>>((ref) {
  return ref.watch(deckRepositoryProvider).watchAll();
});

// ── Deck notifier (CRUD actions) ──────────────────────────────────────────────

class DeckNotifier extends AsyncNotifier<List<Deck>> {
  @override
  Future<List<Deck>> build() {
    return ref.watch(deckRepositoryProvider).getAll();
  }

  Future<String> createDeck(String name) async {
    final repo = ref.read(deckRepositoryProvider);
    final id = await repo.create(name);
    ref.invalidateSelf();
    return id;
  }

  Future<void> renameDeck(String id, String newName) async {
    await ref.read(deckRepositoryProvider).rename(id, newName);
    ref.invalidateSelf();
  }

  Future<void> deleteDeck(String id) async {
    await ref.read(deckRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }
}

final deckNotifierProvider =
    AsyncNotifierProvider<DeckNotifier, List<Deck>>(DeckNotifier.new);
