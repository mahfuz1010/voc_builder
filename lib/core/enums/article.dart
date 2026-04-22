enum Article {
  der,
  die,
  das,
  none;

  String get label {
    if (this == Article.none) return '';
    return name;
  }

  String get displayLabel {
    switch (this) {
      case Article.der:
        return 'der';
      case Article.die:
        return 'die';
      case Article.das:
        return 'das';
      case Article.none:
        return '—';
    }
  }
}
