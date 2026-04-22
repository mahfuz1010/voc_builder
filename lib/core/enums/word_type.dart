enum WordType {
  noun,
  verb,
  adjective,
  adverb,
  phrase,
  other;

  String get label {
    switch (this) {
      case WordType.noun:
        return 'Noun';
      case WordType.verb:
        return 'Verb';
      case WordType.adjective:
        return 'Adjective';
      case WordType.adverb:
        return 'Adverb';
      case WordType.phrase:
        return 'Phrase';
      case WordType.other:
        return 'Other';
    }
  }
}
