import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/deck.dart';
import 'repository_providers.dart';
import 'profile_provider.dart';

// ── Watch all decks (stream) ──────────────────────────────────────────────────

final decksStreamProvider = StreamProvider<List<Deck>>((ref) {
  final langCode = ref.watch(activeProfileProvider);
  return ref.watch(deckRepositoryProvider).watchByLanguage(langCode);
});

// ── Deck notifier (CRUD actions) ──────────────────────────────────────────────

class DeckNotifier extends AsyncNotifier<List<Deck>> {
  @override
  Future<List<Deck>> build() {
    final langCode = ref.watch(activeProfileProvider);
    return ref.watch(deckRepositoryProvider).getByLanguage(langCode);
  }

  Future<String> createDeck(String name) async {
    final repo = ref.read(deckRepositoryProvider);
    final langCode = ref.read(activeProfileProvider);
    final id = await repo.create(name, languageCode: langCode);
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
