// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final String id;
  final String name;
  final int createdAt;
  const Deck({required this.id, required this.name, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory Deck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Deck copyWith({String? id, String? name, int? createdAt}) => Deck(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String name,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Deck> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, Card> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id)',
    ),
  );
  static const VerificationMeta _germanMeta = const VerificationMeta('german');
  @override
  late final GeneratedColumn<String> german = GeneratedColumn<String>(
    'german',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishMeta = const VerificationMeta(
    'english',
  );
  @override
  late final GeneratedColumn<String> english = GeneratedColumn<String>(
    'english',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _articleMeta = const VerificationMeta(
    'article',
  );
  @override
  late final GeneratedColumn<int> article = GeneratedColumn<int>(
    'article',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _pluralMeta = const VerificationMeta('plural');
  @override
  late final GeneratedColumn<String> plural = GeneratedColumn<String>(
    'plural',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _wordTypeMeta = const VerificationMeta(
    'wordType',
  );
  @override
  late final GeneratedColumn<int> wordType = GeneratedColumn<int>(
    'word_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _exampleDeMeta = const VerificationMeta(
    'exampleDe',
  );
  @override
  late final GeneratedColumn<String> exampleDe = GeneratedColumn<String>(
    'example_de',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exampleEnMeta = const VerificationMeta(
    'exampleEn',
  );
  @override
  late final GeneratedColumn<String> exampleEn = GeneratedColumn<String>(
    'example_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _verbIchFormMeta = const VerificationMeta(
    'verbIchForm',
  );
  @override
  late final GeneratedColumn<String> verbIchForm = GeneratedColumn<String>(
    'verb_ich_form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _partizipIIMeta = const VerificationMeta(
    'partizipII',
  );
  @override
  late final GeneratedColumn<String> partizipII = GeneratedColumn<String>(
    'partizip_i_i',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _comparativeMeta = const VerificationMeta(
    'comparative',
  );
  @override
  late final GeneratedColumn<String> comparative = GeneratedColumn<String>(
    'comparative',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _superlativeMeta = const VerificationMeta(
    'superlative',
  );
  @override
  late final GeneratedColumn<String> superlative = GeneratedColumn<String>(
    'superlative',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _memoryStageMeta = const VerificationMeta(
    'memoryStage',
  );
  @override
  late final GeneratedColumn<int> memoryStage = GeneratedColumn<int>(
    'memory_stage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intervalDaysMeta = const VerificationMeta(
    'intervalDays',
  );
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
    'interval_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _easeFactorMeta = const VerificationMeta(
    'easeFactor',
  );
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
    'ease_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(2.5),
  );
  static const VerificationMeta _nextReviewMeta = const VerificationMeta(
    'nextReview',
  );
  @override
  late final GeneratedColumn<int> nextReview = GeneratedColumn<int>(
    'next_review',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    german,
    english,
    article,
    plural,
    wordType,
    exampleDe,
    exampleEn,
    verbIchForm,
    partizipII,
    comparative,
    superlative,
    notes,
    tags,
    memoryStage,
    intervalDays,
    easeFactor,
    nextReview,
    repetitions,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Card> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('german')) {
      context.handle(
        _germanMeta,
        german.isAcceptableOrUnknown(data['german']!, _germanMeta),
      );
    } else if (isInserting) {
      context.missing(_germanMeta);
    }
    if (data.containsKey('english')) {
      context.handle(
        _englishMeta,
        english.isAcceptableOrUnknown(data['english']!, _englishMeta),
      );
    } else if (isInserting) {
      context.missing(_englishMeta);
    }
    if (data.containsKey('article')) {
      context.handle(
        _articleMeta,
        article.isAcceptableOrUnknown(data['article']!, _articleMeta),
      );
    }
    if (data.containsKey('plural')) {
      context.handle(
        _pluralMeta,
        plural.isAcceptableOrUnknown(data['plural']!, _pluralMeta),
      );
    }
    if (data.containsKey('word_type')) {
      context.handle(
        _wordTypeMeta,
        wordType.isAcceptableOrUnknown(data['word_type']!, _wordTypeMeta),
      );
    }
    if (data.containsKey('example_de')) {
      context.handle(
        _exampleDeMeta,
        exampleDe.isAcceptableOrUnknown(data['example_de']!, _exampleDeMeta),
      );
    }
    if (data.containsKey('example_en')) {
      context.handle(
        _exampleEnMeta,
        exampleEn.isAcceptableOrUnknown(data['example_en']!, _exampleEnMeta),
      );
    }
    if (data.containsKey('verb_ich_form')) {
      context.handle(
        _verbIchFormMeta,
        verbIchForm.isAcceptableOrUnknown(
          data['verb_ich_form']!,
          _verbIchFormMeta,
        ),
      );
    }
    if (data.containsKey('partizip_i_i')) {
      context.handle(
        _partizipIIMeta,
        partizipII.isAcceptableOrUnknown(
          data['partizip_i_i']!,
          _partizipIIMeta,
        ),
      );
    }
    if (data.containsKey('comparative')) {
      context.handle(
        _comparativeMeta,
        comparative.isAcceptableOrUnknown(
          data['comparative']!,
          _comparativeMeta,
        ),
      );
    }
    if (data.containsKey('superlative')) {
      context.handle(
        _superlativeMeta,
        superlative.isAcceptableOrUnknown(
          data['superlative']!,
          _superlativeMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('memory_stage')) {
      context.handle(
        _memoryStageMeta,
        memoryStage.isAcceptableOrUnknown(
          data['memory_stage']!,
          _memoryStageMeta,
        ),
      );
    }
    if (data.containsKey('interval_days')) {
      context.handle(
        _intervalDaysMeta,
        intervalDays.isAcceptableOrUnknown(
          data['interval_days']!,
          _intervalDaysMeta,
        ),
      );
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
        _easeFactorMeta,
        easeFactor.isAcceptableOrUnknown(data['ease_factor']!, _easeFactorMeta),
      );
    }
    if (data.containsKey('next_review')) {
      context.handle(
        _nextReviewMeta,
        nextReview.isAcceptableOrUnknown(data['next_review']!, _nextReviewMeta),
      );
    } else if (isInserting) {
      context.missing(_nextReviewMeta);
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Card map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Card(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      german: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}german'],
      )!,
      english: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english'],
      )!,
      article: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}article'],
      )!,
      plural: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plural'],
      )!,
      wordType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_type'],
      )!,
      exampleDe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_de'],
      )!,
      exampleEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_en'],
      )!,
      verbIchForm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verb_ich_form'],
      )!,
      partizipII: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partizip_i_i'],
      )!,
      comparative: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comparative'],
      )!,
      superlative: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superlative'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      memoryStage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}memory_stage'],
      )!,
      intervalDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_days'],
      )!,
      easeFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ease_factor'],
      )!,
      nextReview: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_review'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class Card extends DataClass implements Insertable<Card> {
  final String id;
  final String deckId;
  final String german;
  final String english;
  final int article;
  final String plural;
  final int wordType;
  final String exampleDe;
  final String exampleEn;
  final String verbIchForm;
  final String partizipII;
  final String comparative;
  final String superlative;
  final String notes;
  final String tags;
  final int memoryStage;
  final int intervalDays;
  final double easeFactor;
  final int nextReview;
  final int repetitions;
  final int createdAt;
  const Card({
    required this.id,
    required this.deckId,
    required this.german,
    required this.english,
    required this.article,
    required this.plural,
    required this.wordType,
    required this.exampleDe,
    required this.exampleEn,
    required this.verbIchForm,
    required this.partizipII,
    required this.comparative,
    required this.superlative,
    required this.notes,
    required this.tags,
    required this.memoryStage,
    required this.intervalDays,
    required this.easeFactor,
    required this.nextReview,
    required this.repetitions,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['german'] = Variable<String>(german);
    map['english'] = Variable<String>(english);
    map['article'] = Variable<int>(article);
    map['plural'] = Variable<String>(plural);
    map['word_type'] = Variable<int>(wordType);
    map['example_de'] = Variable<String>(exampleDe);
    map['example_en'] = Variable<String>(exampleEn);
    map['verb_ich_form'] = Variable<String>(verbIchForm);
    map['partizip_i_i'] = Variable<String>(partizipII);
    map['comparative'] = Variable<String>(comparative);
    map['superlative'] = Variable<String>(superlative);
    map['notes'] = Variable<String>(notes);
    map['tags'] = Variable<String>(tags);
    map['memory_stage'] = Variable<int>(memoryStage);
    map['interval_days'] = Variable<int>(intervalDays);
    map['ease_factor'] = Variable<double>(easeFactor);
    map['next_review'] = Variable<int>(nextReview);
    map['repetitions'] = Variable<int>(repetitions);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      german: Value(german),
      english: Value(english),
      article: Value(article),
      plural: Value(plural),
      wordType: Value(wordType),
      exampleDe: Value(exampleDe),
      exampleEn: Value(exampleEn),
      verbIchForm: Value(verbIchForm),
      partizipII: Value(partizipII),
      comparative: Value(comparative),
      superlative: Value(superlative),
      notes: Value(notes),
      tags: Value(tags),
      memoryStage: Value(memoryStage),
      intervalDays: Value(intervalDays),
      easeFactor: Value(easeFactor),
      nextReview: Value(nextReview),
      repetitions: Value(repetitions),
      createdAt: Value(createdAt),
    );
  }

  factory Card.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Card(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      german: serializer.fromJson<String>(json['german']),
      english: serializer.fromJson<String>(json['english']),
      article: serializer.fromJson<int>(json['article']),
      plural: serializer.fromJson<String>(json['plural']),
      wordType: serializer.fromJson<int>(json['wordType']),
      exampleDe: serializer.fromJson<String>(json['exampleDe']),
      exampleEn: serializer.fromJson<String>(json['exampleEn']),
      verbIchForm: serializer.fromJson<String>(json['verbIchForm']),
      partizipII: serializer.fromJson<String>(json['partizipII']),
      comparative: serializer.fromJson<String>(json['comparative']),
      superlative: serializer.fromJson<String>(json['superlative']),
      notes: serializer.fromJson<String>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
      memoryStage: serializer.fromJson<int>(json['memoryStage']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
      nextReview: serializer.fromJson<int>(json['nextReview']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'german': serializer.toJson<String>(german),
      'english': serializer.toJson<String>(english),
      'article': serializer.toJson<int>(article),
      'plural': serializer.toJson<String>(plural),
      'wordType': serializer.toJson<int>(wordType),
      'exampleDe': serializer.toJson<String>(exampleDe),
      'exampleEn': serializer.toJson<String>(exampleEn),
      'verbIchForm': serializer.toJson<String>(verbIchForm),
      'partizipII': serializer.toJson<String>(partizipII),
      'comparative': serializer.toJson<String>(comparative),
      'superlative': serializer.toJson<String>(superlative),
      'notes': serializer.toJson<String>(notes),
      'tags': serializer.toJson<String>(tags),
      'memoryStage': serializer.toJson<int>(memoryStage),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'easeFactor': serializer.toJson<double>(easeFactor),
      'nextReview': serializer.toJson<int>(nextReview),
      'repetitions': serializer.toJson<int>(repetitions),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Card copyWith({
    String? id,
    String? deckId,
    String? german,
    String? english,
    int? article,
    String? plural,
    int? wordType,
    String? exampleDe,
    String? exampleEn,
    String? verbIchForm,
    String? partizipII,
    String? comparative,
    String? superlative,
    String? notes,
    String? tags,
    int? memoryStage,
    int? intervalDays,
    double? easeFactor,
    int? nextReview,
    int? repetitions,
    int? createdAt,
  }) => Card(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    german: german ?? this.german,
    english: english ?? this.english,
    article: article ?? this.article,
    plural: plural ?? this.plural,
    wordType: wordType ?? this.wordType,
    exampleDe: exampleDe ?? this.exampleDe,
    exampleEn: exampleEn ?? this.exampleEn,
    verbIchForm: verbIchForm ?? this.verbIchForm,
    partizipII: partizipII ?? this.partizipII,
    comparative: comparative ?? this.comparative,
    superlative: superlative ?? this.superlative,
    notes: notes ?? this.notes,
    tags: tags ?? this.tags,
    memoryStage: memoryStage ?? this.memoryStage,
    intervalDays: intervalDays ?? this.intervalDays,
    easeFactor: easeFactor ?? this.easeFactor,
    nextReview: nextReview ?? this.nextReview,
    repetitions: repetitions ?? this.repetitions,
    createdAt: createdAt ?? this.createdAt,
  );
  Card copyWithCompanion(CardsCompanion data) {
    return Card(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      german: data.german.present ? data.german.value : this.german,
      english: data.english.present ? data.english.value : this.english,
      article: data.article.present ? data.article.value : this.article,
      plural: data.plural.present ? data.plural.value : this.plural,
      wordType: data.wordType.present ? data.wordType.value : this.wordType,
      exampleDe: data.exampleDe.present ? data.exampleDe.value : this.exampleDe,
      exampleEn: data.exampleEn.present ? data.exampleEn.value : this.exampleEn,
      verbIchForm: data.verbIchForm.present
          ? data.verbIchForm.value
          : this.verbIchForm,
      partizipII: data.partizipII.present
          ? data.partizipII.value
          : this.partizipII,
      comparative: data.comparative.present
          ? data.comparative.value
          : this.comparative,
      superlative: data.superlative.present
          ? data.superlative.value
          : this.superlative,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      memoryStage: data.memoryStage.present
          ? data.memoryStage.value
          : this.memoryStage,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      easeFactor: data.easeFactor.present
          ? data.easeFactor.value
          : this.easeFactor,
      nextReview: data.nextReview.present
          ? data.nextReview.value
          : this.nextReview,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Card(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('german: $german, ')
          ..write('english: $english, ')
          ..write('article: $article, ')
          ..write('plural: $plural, ')
          ..write('wordType: $wordType, ')
          ..write('exampleDe: $exampleDe, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('verbIchForm: $verbIchForm, ')
          ..write('partizipII: $partizipII, ')
          ..write('comparative: $comparative, ')
          ..write('superlative: $superlative, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('memoryStage: $memoryStage, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('nextReview: $nextReview, ')
          ..write('repetitions: $repetitions, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    deckId,
    german,
    english,
    article,
    plural,
    wordType,
    exampleDe,
    exampleEn,
    verbIchForm,
    partizipII,
    comparative,
    superlative,
    notes,
    tags,
    memoryStage,
    intervalDays,
    easeFactor,
    nextReview,
    repetitions,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Card &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.german == this.german &&
          other.english == this.english &&
          other.article == this.article &&
          other.plural == this.plural &&
          other.wordType == this.wordType &&
          other.exampleDe == this.exampleDe &&
          other.exampleEn == this.exampleEn &&
          other.verbIchForm == this.verbIchForm &&
          other.partizipII == this.partizipII &&
          other.comparative == this.comparative &&
          other.superlative == this.superlative &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.memoryStage == this.memoryStage &&
          other.intervalDays == this.intervalDays &&
          other.easeFactor == this.easeFactor &&
          other.nextReview == this.nextReview &&
          other.repetitions == this.repetitions &&
          other.createdAt == this.createdAt);
}

class CardsCompanion extends UpdateCompanion<Card> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<String> german;
  final Value<String> english;
  final Value<int> article;
  final Value<String> plural;
  final Value<int> wordType;
  final Value<String> exampleDe;
  final Value<String> exampleEn;
  final Value<String> verbIchForm;
  final Value<String> partizipII;
  final Value<String> comparative;
  final Value<String> superlative;
  final Value<String> notes;
  final Value<String> tags;
  final Value<int> memoryStage;
  final Value<int> intervalDays;
  final Value<double> easeFactor;
  final Value<int> nextReview;
  final Value<int> repetitions;
  final Value<int> createdAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.german = const Value.absent(),
    this.english = const Value.absent(),
    this.article = const Value.absent(),
    this.plural = const Value.absent(),
    this.wordType = const Value.absent(),
    this.exampleDe = const Value.absent(),
    this.exampleEn = const Value.absent(),
    this.verbIchForm = const Value.absent(),
    this.partizipII = const Value.absent(),
    this.comparative = const Value.absent(),
    this.superlative = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.memoryStage = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String deckId,
    required String german,
    required String english,
    this.article = const Value.absent(),
    this.plural = const Value.absent(),
    this.wordType = const Value.absent(),
    this.exampleDe = const Value.absent(),
    this.exampleEn = const Value.absent(),
    this.verbIchForm = const Value.absent(),
    this.partizipII = const Value.absent(),
    this.comparative = const Value.absent(),
    this.superlative = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.memoryStage = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.easeFactor = const Value.absent(),
    required int nextReview,
    this.repetitions = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deckId = Value(deckId),
       german = Value(german),
       english = Value(english),
       nextReview = Value(nextReview),
       createdAt = Value(createdAt);
  static Insertable<Card> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? german,
    Expression<String>? english,
    Expression<int>? article,
    Expression<String>? plural,
    Expression<int>? wordType,
    Expression<String>? exampleDe,
    Expression<String>? exampleEn,
    Expression<String>? verbIchForm,
    Expression<String>? partizipII,
    Expression<String>? comparative,
    Expression<String>? superlative,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<int>? memoryStage,
    Expression<int>? intervalDays,
    Expression<double>? easeFactor,
    Expression<int>? nextReview,
    Expression<int>? repetitions,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (german != null) 'german': german,
      if (english != null) 'english': english,
      if (article != null) 'article': article,
      if (plural != null) 'plural': plural,
      if (wordType != null) 'word_type': wordType,
      if (exampleDe != null) 'example_de': exampleDe,
      if (exampleEn != null) 'example_en': exampleEn,
      if (verbIchForm != null) 'verb_ich_form': verbIchForm,
      if (partizipII != null) 'partizip_i_i': partizipII,
      if (comparative != null) 'comparative': comparative,
      if (superlative != null) 'superlative': superlative,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (memoryStage != null) 'memory_stage': memoryStage,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (easeFactor != null) 'ease_factor': easeFactor,
      if (nextReview != null) 'next_review': nextReview,
      if (repetitions != null) 'repetitions': repetitions,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<String>? german,
    Value<String>? english,
    Value<int>? article,
    Value<String>? plural,
    Value<int>? wordType,
    Value<String>? exampleDe,
    Value<String>? exampleEn,
    Value<String>? verbIchForm,
    Value<String>? partizipII,
    Value<String>? comparative,
    Value<String>? superlative,
    Value<String>? notes,
    Value<String>? tags,
    Value<int>? memoryStage,
    Value<int>? intervalDays,
    Value<double>? easeFactor,
    Value<int>? nextReview,
    Value<int>? repetitions,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      german: german ?? this.german,
      english: english ?? this.english,
      article: article ?? this.article,
      plural: plural ?? this.plural,
      wordType: wordType ?? this.wordType,
      exampleDe: exampleDe ?? this.exampleDe,
      exampleEn: exampleEn ?? this.exampleEn,
      verbIchForm: verbIchForm ?? this.verbIchForm,
      partizipII: partizipII ?? this.partizipII,
      comparative: comparative ?? this.comparative,
      superlative: superlative ?? this.superlative,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      memoryStage: memoryStage ?? this.memoryStage,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReview: nextReview ?? this.nextReview,
      repetitions: repetitions ?? this.repetitions,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (german.present) {
      map['german'] = Variable<String>(german.value);
    }
    if (english.present) {
      map['english'] = Variable<String>(english.value);
    }
    if (article.present) {
      map['article'] = Variable<int>(article.value);
    }
    if (plural.present) {
      map['plural'] = Variable<String>(plural.value);
    }
    if (wordType.present) {
      map['word_type'] = Variable<int>(wordType.value);
    }
    if (exampleDe.present) {
      map['example_de'] = Variable<String>(exampleDe.value);
    }
    if (exampleEn.present) {
      map['example_en'] = Variable<String>(exampleEn.value);
    }
    if (verbIchForm.present) {
      map['verb_ich_form'] = Variable<String>(verbIchForm.value);
    }
    if (partizipII.present) {
      map['partizip_i_i'] = Variable<String>(partizipII.value);
    }
    if (comparative.present) {
      map['comparative'] = Variable<String>(comparative.value);
    }
    if (superlative.present) {
      map['superlative'] = Variable<String>(superlative.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (memoryStage.present) {
      map['memory_stage'] = Variable<int>(memoryStage.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<int>(nextReview.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('german: $german, ')
          ..write('english: $english, ')
          ..write('article: $article, ')
          ..write('plural: $plural, ')
          ..write('wordType: $wordType, ')
          ..write('exampleDe: $exampleDe, ')
          ..write('exampleEn: $exampleEn, ')
          ..write('verbIchForm: $verbIchForm, ')
          ..write('partizipII: $partizipII, ')
          ..write('comparative: $comparative, ')
          ..write('superlative: $superlative, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('memoryStage: $memoryStage, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('easeFactor: $easeFactor, ')
          ..write('nextReview: $nextReview, ')
          ..write('repetitions: $repetitions, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final DeckDao deckDao = DeckDao(this as AppDatabase);
  late final CardDao cardDao = CardDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [decks, cards];
}

typedef $$DecksTableCreateCompanionBuilder =
    DecksCompanion Function({
      required String id,
      required String name,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$DecksTableUpdateCompanionBuilder =
    DecksCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardsTable, List<Card>> _cardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cards,
    aliasName: $_aliasNameGenerator(db.decks.id, db.cards.deckId),
  );

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardsRefs(
    Expression<bool> Function($$CardsTableFilterComposer f) f,
  ) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> cardsRefs<T extends Object>(
    Expression<T> Function($$CardsTableAnnotationComposer a) f,
  ) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          Deck,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (Deck, $$DecksTableReferences),
          Deck,
          PrefetchHooks Function({bool cardsRefs})
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DecksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cardsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardsRefs) db.cards],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedData<Deck, $DecksTable, Card>(
                      currentTable: table,
                      referencedTable: $$DecksTableReferences._cardsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$DecksTableReferences(db, table, p0).cardsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deckId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      Deck,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (Deck, $$DecksTableReferences),
      Deck,
      PrefetchHooks Function({bool cardsRefs})
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      required String id,
      required String deckId,
      required String german,
      required String english,
      Value<int> article,
      Value<String> plural,
      Value<int> wordType,
      Value<String> exampleDe,
      Value<String> exampleEn,
      Value<String> verbIchForm,
      Value<String> partizipII,
      Value<String> comparative,
      Value<String> superlative,
      Value<String> notes,
      Value<String> tags,
      Value<int> memoryStage,
      Value<int> intervalDays,
      Value<double> easeFactor,
      required int nextReview,
      Value<int> repetitions,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<String> id,
      Value<String> deckId,
      Value<String> german,
      Value<String> english,
      Value<int> article,
      Value<String> plural,
      Value<int> wordType,
      Value<String> exampleDe,
      Value<String> exampleEn,
      Value<String> verbIchForm,
      Value<String> partizipII,
      Value<String> comparative,
      Value<String> superlative,
      Value<String> notes,
      Value<String> tags,
      Value<int> memoryStage,
      Value<int> intervalDays,
      Value<double> easeFactor,
      Value<int> nextReview,
      Value<int> repetitions,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, Card> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias($_aliasNameGenerator(db.cards.deckId, db.decks.id));

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get german => $composableBuilder(
    column: $table.german,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get article => $composableBuilder(
    column: $table.article,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plural => $composableBuilder(
    column: $table.plural,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordType => $composableBuilder(
    column: $table.wordType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleDe => $composableBuilder(
    column: $table.exampleDe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verbIchForm => $composableBuilder(
    column: $table.verbIchForm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partizipII => $composableBuilder(
    column: $table.partizipII,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comparative => $composableBuilder(
    column: $table.comparative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get superlative => $composableBuilder(
    column: $table.superlative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get memoryStage => $composableBuilder(
    column: $table.memoryStage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get german => $composableBuilder(
    column: $table.german,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get english => $composableBuilder(
    column: $table.english,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get article => $composableBuilder(
    column: $table.article,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plural => $composableBuilder(
    column: $table.plural,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordType => $composableBuilder(
    column: $table.wordType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleDe => $composableBuilder(
    column: $table.exampleDe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exampleEn => $composableBuilder(
    column: $table.exampleEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verbIchForm => $composableBuilder(
    column: $table.verbIchForm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partizipII => $composableBuilder(
    column: $table.partizipII,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comparative => $composableBuilder(
    column: $table.comparative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get superlative => $composableBuilder(
    column: $table.superlative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get memoryStage => $composableBuilder(
    column: $table.memoryStage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get german =>
      $composableBuilder(column: $table.german, builder: (column) => column);

  GeneratedColumn<String> get english =>
      $composableBuilder(column: $table.english, builder: (column) => column);

  GeneratedColumn<int> get article =>
      $composableBuilder(column: $table.article, builder: (column) => column);

  GeneratedColumn<String> get plural =>
      $composableBuilder(column: $table.plural, builder: (column) => column);

  GeneratedColumn<int> get wordType =>
      $composableBuilder(column: $table.wordType, builder: (column) => column);

  GeneratedColumn<String> get exampleDe =>
      $composableBuilder(column: $table.exampleDe, builder: (column) => column);

  GeneratedColumn<String> get exampleEn =>
      $composableBuilder(column: $table.exampleEn, builder: (column) => column);

  GeneratedColumn<String> get verbIchForm => $composableBuilder(
    column: $table.verbIchForm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get partizipII => $composableBuilder(
    column: $table.partizipII,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comparative => $composableBuilder(
    column: $table.comparative,
    builder: (column) => column,
  );

  GeneratedColumn<String> get superlative => $composableBuilder(
    column: $table.superlative,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get memoryStage => $composableBuilder(
    column: $table.memoryStage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalDays => $composableBuilder(
    column: $table.intervalDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get easeFactor => $composableBuilder(
    column: $table.easeFactor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextReview => $composableBuilder(
    column: $table.nextReview,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          Card,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (Card, $$CardsTableReferences),
          Card,
          PrefetchHooks Function({bool deckId})
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> german = const Value.absent(),
                Value<String> english = const Value.absent(),
                Value<int> article = const Value.absent(),
                Value<String> plural = const Value.absent(),
                Value<int> wordType = const Value.absent(),
                Value<String> exampleDe = const Value.absent(),
                Value<String> exampleEn = const Value.absent(),
                Value<String> verbIchForm = const Value.absent(),
                Value<String> partizipII = const Value.absent(),
                Value<String> comparative = const Value.absent(),
                Value<String> superlative = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> memoryStage = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                Value<int> nextReview = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                deckId: deckId,
                german: german,
                english: english,
                article: article,
                plural: plural,
                wordType: wordType,
                exampleDe: exampleDe,
                exampleEn: exampleEn,
                verbIchForm: verbIchForm,
                partizipII: partizipII,
                comparative: comparative,
                superlative: superlative,
                notes: notes,
                tags: tags,
                memoryStage: memoryStage,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                nextReview: nextReview,
                repetitions: repetitions,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deckId,
                required String german,
                required String english,
                Value<int> article = const Value.absent(),
                Value<String> plural = const Value.absent(),
                Value<int> wordType = const Value.absent(),
                Value<String> exampleDe = const Value.absent(),
                Value<String> exampleEn = const Value.absent(),
                Value<String> verbIchForm = const Value.absent(),
                Value<String> partizipII = const Value.absent(),
                Value<String> comparative = const Value.absent(),
                Value<String> superlative = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<int> memoryStage = const Value.absent(),
                Value<int> intervalDays = const Value.absent(),
                Value<double> easeFactor = const Value.absent(),
                required int nextReview,
                Value<int> repetitions = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                deckId: deckId,
                german: german,
                english: english,
                article: article,
                plural: plural,
                wordType: wordType,
                exampleDe: exampleDe,
                exampleEn: exampleEn,
                verbIchForm: verbIchForm,
                partizipII: partizipII,
                comparative: comparative,
                superlative: superlative,
                notes: notes,
                tags: tags,
                memoryStage: memoryStage,
                intervalDays: intervalDays,
                easeFactor: easeFactor,
                nextReview: nextReview,
                repetitions: repetitions,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable: $$CardsTableReferences
                                    ._deckIdTable(db),
                                referencedColumn: $$CardsTableReferences
                                    ._deckIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      Card,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (Card, $$CardsTableReferences),
      Card,
      PrefetchHooks Function({bool deckId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
}
