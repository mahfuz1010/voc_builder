import 'package:equatable/equatable.dart';
import '../../core/enums/article.dart';
import '../../core/enums/memory_stage.dart';
import '../../core/enums/word_type.dart';

class Flashcard extends Equatable {
  final String id;
  final String deckId;

  // Core fields
  final String german;
  final String english;
  final Article article;
  final String plural;
  final WordType wordType;

  // Examples
  final String exampleDe;
  final String exampleEn;

  // Grammar extras
  final String verbIchForm;      // verb ich-form
  final String partizipII;       // verb Partizip II
  final String comparative;      // adjective comparative
  final String superlative;      // adjective superlative

  // Meta
  final String notes;
  final List<String> tags;

  // SRS
  final MemoryStage memoryStage;
  final int intervalDays;
  final double easeFactor;
  final DateTime nextReview;
  final int repetitions;

  final DateTime createdAt;

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.german,
    required this.english,
    this.article = Article.none,
    this.plural = '',
    this.wordType = WordType.other,
    this.exampleDe = '',
    this.exampleEn = '',
    this.verbIchForm = '',
    this.partizipII = '',
    this.comparative = '',
    this.superlative = '',
    this.notes = '',
    this.tags = const [],
    this.memoryStage = MemoryStage.newCard,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
    required this.nextReview,
    this.repetitions = 0,
    required this.createdAt,
  });

  bool get isDue => nextReview.isBefore(DateTime.now()) ||
      nextReview.isAtSameMomentAs(DateTime.now());

  /// Display label: article + german (e.g. "der Hund")
  String get displayGerman {
    if (article != Article.none) {
      return '${article.label} $german';
    }
    return german;
  }

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? german,
    String? english,
    Article? article,
    String? plural,
    WordType? wordType,
    String? exampleDe,
    String? exampleEn,
    String? verbIchForm,
    String? partizipII,
    String? comparative,
    String? superlative,
    String? notes,
    List<String>? tags,
    MemoryStage? memoryStage,
    int? intervalDays,
    double? easeFactor,
    DateTime? nextReview,
    int? repetitions,
    DateTime? createdAt,
  }) {
    return Flashcard(
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
  }

  @override
  List<Object?> get props => [id, deckId, german, english, article, memoryStage, nextReview];
}
