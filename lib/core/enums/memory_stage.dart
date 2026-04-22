enum MemoryStage {
  newCard,
  shortTerm,
  longTerm;

  String get label {
    switch (this) {
      case MemoryStage.newCard:
        return 'New';
      case MemoryStage.shortTerm:
        return 'Short-term';
      case MemoryStage.longTerm:
        return 'Long-term';
    }
  }

  int get dbValue {
    switch (this) {
      case MemoryStage.newCard:
        return 0;
      case MemoryStage.shortTerm:
        return 1;
      case MemoryStage.longTerm:
        return 2;
    }
  }

  static MemoryStage fromDbValue(int v) {
    switch (v) {
      case 1:
        return MemoryStage.shortTerm;
      case 2:
        return MemoryStage.longTerm;
      default:
        return MemoryStage.newCard;
    }
  }
}
