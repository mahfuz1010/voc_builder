import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'daos/deck_dao.dart';
import 'daos/card_dao.dart';

part 'app_database.g.dart';

// ─── Table definitions ────────────────────────────────────────────────────────

class Decks extends Table {
  TextColumn get id         => text()();
  TextColumn get name       => text()();
  IntColumn  get createdAt  => integer()();  // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

class Cards extends Table {
  TextColumn  get id          => text()();
  TextColumn  get deckId      => text().references(Decks, #id)();
  TextColumn  get german      => text()();
  TextColumn  get english     => text()();
  IntColumn   get article     => integer().withDefault(const Constant(3))(); // 0=der,1=die,2=das,3=none
  TextColumn  get plural      => text().withDefault(const Constant(''))();
  IntColumn   get wordType    => integer().withDefault(const Constant(5))(); // enum index
  TextColumn  get exampleDe   => text().withDefault(const Constant(''))();
  TextColumn  get exampleEn   => text().withDefault(const Constant(''))();
  TextColumn  get verbIchForm => text().withDefault(const Constant(''))();
  TextColumn  get partizipII  => text().withDefault(const Constant(''))();
  TextColumn  get comparative => text().withDefault(const Constant(''))();
  TextColumn  get superlative => text().withDefault(const Constant(''))();
  TextColumn  get notes       => text().withDefault(const Constant(''))();
  TextColumn  get tags        => text().withDefault(const Constant(''))(); // comma-separated
  IntColumn   get memoryStage => integer().withDefault(const Constant(0))();
  IntColumn   get intervalDays=> integer().withDefault(const Constant(0))();
  RealColumn  get easeFactor  => real().withDefault(const Constant(2.5))();
  IntColumn   get nextReview  => integer()();  // epoch ms
  IntColumn   get repetitions => integer().withDefault(const Constant(0))();
  IntColumn   get createdAt   => integer()();  // epoch ms

  @override
  Set<Column> get primaryKey => {id};
}

// ─── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Decks, Cards], daos: [DeckDao, CardDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'vocbuilder.db'));
    return NativeDatabase.createInBackground(file);
  });
}
