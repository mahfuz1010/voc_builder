import 'package:equatable/equatable.dart';

/// Contains additional information about a word (synonyms, antonyms, definitions)
class WordInfo extends Equatable {
  /// 2-3 synonyms for the word
  final List<String> synonyms;

  /// 1-2 antonyms for the word
  final List<String> antonyms;

  /// Definition or description of the word
  final String definition;

  /// Additional details or notes about the word
  final String details;

  /// Whether this info was successfully fetched from an API
  final bool isFetched;

  const WordInfo({
    this.synonyms = const [],
    this.antonyms = const [],
    this.definition = '',
    this.details = '',
    this.isFetched = false,
  });

  /// Creates an empty WordInfo
  factory WordInfo.empty() => const WordInfo();

  /// Check if this WordInfo has any actual data
  bool get hasData =>
      synonyms.isNotEmpty || antonyms.isNotEmpty || definition.isNotEmpty;

  WordInfo copyWith({
    List<String>? synonyms,
    List<String>? antonyms,
    String? definition,
    String? details,
    bool? isFetched,
  }) {
    return WordInfo(
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      definition: definition ?? this.definition,
      details: details ?? this.details,
      isFetched: isFetched ?? this.isFetched,
    );
  }

  @override
  List<Object?> get props => [synonyms, antonyms, definition, details, isFetched];
}
