import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../data/repositories/deck_repository_impl.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/repositories/deck_repository.dart';

// ── Database singleton ────────────────────────────────────────────────────────

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

// ── Repository providers ──────────────────────────────────────────────────────

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepositoryImpl(ref.watch(appDatabaseProvider));
});

final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return CardRepositoryImpl(ref.watch(appDatabaseProvider));
});
