import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/card_repository_impl.dart';
import 'import_export_service.dart';

class DefaultSeedService {
  DefaultSeedService._();

  static const String _defaultDeckName = 'German Learning';
  static const String _defaultCsvAsset = 'assets/data/duo_cards_de_export1.csv';

  static Future<void> seedDefaultDeckIfNeeded() async {
    final db = AppDatabase();

    try {
      final existingDecks = await db.deckDao.getAllDecks();
      if (existingDecks.isNotEmpty) return;

      final content = await rootBundle.loadString(_defaultCsvAsset);
      final deckId = const Uuid().v4();

      await db.deckDao.insertDeck(
        DecksCompanion.insert(
          id: deckId,
          name: _defaultDeckName,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final cards = ImportService.parseContent(content, 'csv', deckId);
      if (cards.isNotEmpty) {
        await CardRepositoryImpl(db).addAll(cards);
      }
    } catch (_) {
      // Seeding should never block app startup.
    } finally {
      await db.close();
    }
  }
}
