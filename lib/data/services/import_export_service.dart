import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../core/enums/article.dart';
import '../../core/enums/memory_stage.dart';
import '../../core/enums/word_type.dart';
import '../../domain/entities/flashcard.dart';

/// Parses CSV / JSON / TXT files into [Flashcard] previews.
class ImportService {
  static const _uuid = Uuid();
  static const _supportedHeaderGerman = ['german', 'front', 'term', 'word'];
  static const _supportedHeaderEnglish = ['english', 'back', 'translation', 'meaning'];
  static const _supportedHeaderHint = ['hint', 'notes', 'example_de', 'examplede'];
  static const _supportedHeaderCreatedAt = ['publishedat', 'createdat', 'date'];

  static List<Flashcard> parseFile(File file, String deckId) {
    final ext = file.path.split('.').last.toLowerCase();
    final content = file.readAsStringSync();

    switch (ext) {
      case 'json':
        return _parseJson(content, deckId);
      case 'csv':
        return _parseCsv(content, deckId);
      default:
        return _parseTxt(content, deckId);
    }
  }

  static List<Flashcard> parseContent(String content, String ext, String deckId) {
    switch (ext.toLowerCase()) {
      case 'json':
        return _parseJson(content, deckId);
      case 'csv':
        return _parseCsv(content, deckId);
      default:
        return _parseTxt(content, deckId);
    }
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  static List<Flashcard> _parseJson(String content, String deckId) {
    try {
      final decoded = jsonDecode(content);
      final list = decoded is List ? decoded : (decoded['cards'] as List? ?? []);
      return list.map<Flashcard>((e) => _fromMap(e as Map, deckId)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── CSV ───────────────────────────────────────────────────────────────────
  // Supported:
  // 1) Delimited rows: German;English[;Article[;Plural]]
  // 2) Header rows with different schemas, e.g. front\tback\thint\tpublishedAt

  static List<Flashcard> _parseCsv(String content, String deckId) {
    final lines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n');
    if (lines.isEmpty) return [];

    final delimiter = _detectDelimiter(lines.first);
    final firstParts = _splitDelimitedLine(lines.first, delimiter)
        .map((p) => p.trim().toLowerCase())
        .toList();
    final hasHeader = _looksLikeHeader(firstParts);

    if (hasHeader) {
      return _parseCsvWithHeader(lines, deckId, delimiter);
    }

    final result = <Flashcard>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final parts = _splitDelimitedLine(trimmed, delimiter);
      if (parts.length < 2) continue;

      final german = parts[0].trim();
      final english = parts[1].trim();
      Article article = Article.none;
      String plural = '';

      if (parts.length > 2) {
        final art = parts[2].trim().toLowerCase();
        article = Article.values.firstWhere(
          (a) => a.name == art,
          orElse: () => Article.none,
        );
      }
      if (parts.length > 3) {
        plural = parts[3].trim();
      }

      if (german.isNotEmpty && english.isNotEmpty) {
        result.add(_makeCard(
          deckId: deckId,
          german: german,
          english: english,
          article: article,
          plural: plural,
        ));
      }
    }
    return result;
  }

  static List<Flashcard> _parseCsvWithHeader(
    List<String> lines,
    String deckId,
    String delimiter,
  ) {
    final result = <Flashcard>[];
    final header = _splitDelimitedLine(lines.first, delimiter)
        .map((h) => h.trim().toLowerCase())
        .toList();

    final germanIndex = _findHeaderIndex(header, _supportedHeaderGerman);
    final englishIndex = _findHeaderIndex(header, _supportedHeaderEnglish);
    if (germanIndex == -1 || englishIndex == -1) return [];

    final hintIndex = _findHeaderIndex(header, _supportedHeaderHint);
    final createdAtIndex = _findHeaderIndex(header, _supportedHeaderCreatedAt);

    for (final line in lines.skip(1)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final parts = _splitDelimitedLine(line, delimiter);
      if (parts.length <= germanIndex || parts.length <= englishIndex) continue;

      final german = parts[germanIndex].trim();
      final english = parts[englishIndex].trim();
      if (german.isEmpty || english.isEmpty) continue;

      final hint = (hintIndex != -1 && parts.length > hintIndex)
          ? parts[hintIndex].trim()
          : '';
      final createdAt = (createdAtIndex != -1 && parts.length > createdAtIndex)
          ? DateTime.tryParse(parts[createdAtIndex].trim())
          : null;

      result.add(
        _makeCard(
          deckId: deckId,
          german: german,
          english: english,
          notes: hint,
          createdAt: createdAt,
        ),
      );
    }

    return result;
  }

  // ── TXT ───────────────────────────────────────────────────────────────────
  // Supported: "German | English", "German - English", "German;English"

  static List<Flashcard> _parseTxt(String content, String deckId) {
    final lines = content.split('\n');
    final result = <Flashcard>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      Map<String, String>? pair;
      for (final sep in [' | ', ' - ', ';']) {
        if (trimmed.contains(sep)) {
          final parts = trimmed.split(sep);
          if (parts.length >= 2) {
            pair = {'german': parts[0].trim(), 'english': parts.sublist(1).join(sep).trim()};
            break;
          }
        }
      }

      if (pair != null &&
          pair['german']!.isNotEmpty &&
          pair['english']!.isNotEmpty) {
        result.add(_makeCard(
          deckId: deckId,
          german: pair['german']!,
          english: pair['english']!,
        ));
      }
    }
    return result;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Flashcard _fromMap(Map map, String deckId) {
    Article art = Article.none;
    final artStr = (map['article'] as String? ?? '').toLowerCase();
    if (artStr.isNotEmpty) {
      art = Article.values.firstWhere(
        (a) => a.name == artStr,
        orElse: () => Article.none,
      );
    }

    WordType wt = WordType.other;
    final wtStr = (map['type'] as String? ?? map['wordType'] as String? ?? '').toLowerCase();
    if (wtStr.isNotEmpty) {
      wt = WordType.values.firstWhere(
        (w) => w.name == wtStr,
        orElse: () => WordType.other,
      );
    }

    return _makeCard(
      deckId: deckId,
      german: (map['german'] as String? ?? '').trim(),
      english: (map['english'] as String? ?? '').trim(),
      article: art,
      plural: (map['plural'] as String? ?? '').trim(),
      wordType: wt,
      exampleDe: (map['example_de'] as String? ?? map['exampleDe'] as String? ?? '').trim(),
      exampleEn: (map['example_en'] as String? ?? map['exampleEn'] as String? ?? '').trim(),
      notes: (map['notes'] as String? ?? '').trim(),
    );
  }

  static Flashcard _makeCard({
    required String deckId,
    required String german,
    required String english,
    Article article = Article.none,
    String plural = '',
    WordType wordType = WordType.other,
    String exampleDe = '',
    String exampleEn = '',
    String notes = '',
    DateTime? createdAt,
  }) {
    final created = createdAt ?? DateTime.now();
    return Flashcard(
      id: _uuid.v4(),
      deckId: deckId,
      german: german,
      english: english,
      article: article,
      plural: plural,
      wordType: wordType,
      exampleDe: exampleDe,
      exampleEn: exampleEn,
      notes: notes,
      memoryStage: MemoryStage.newCard,
      easeFactor: 2.5,
      nextReview: DateTime.now(),
      createdAt: created,
    );
  }

  static String _detectDelimiter(String line) {
    if (line.contains('\t')) return '\t';
    if (line.contains(';')) return ';';
    return ',';
  }

  static bool _looksLikeHeader(List<String> parts) {
    if (parts.isEmpty) return false;
    return parts.any((p) => _supportedHeaderGerman.contains(p)) &&
        parts.any((p) => _supportedHeaderEnglish.contains(p));
  }

  static int _findHeaderIndex(List<String> header, List<String> aliases) {
    for (var i = 0; i < header.length; i++) {
      if (aliases.contains(header[i])) return i;
    }
    return -1;
  }

  // Basic CSV/TSV splitting with support for quoted cells.
  static List<String> _splitDelimitedLine(String line, String delimiter) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        // Handle escaped quote inside quoted field.
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
        continue;
      }

      final matchesDelimiter = delimiter == '\t'
          ? char == '\t'
          : char == delimiter;

      if (!inQuotes && matchesDelimiter) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    result.add(buffer.toString());
    return result;
  }
}

/// Serialises decks/cards to CSV or JSON for export.
class ExportService {
  static String toJson(List<Flashcard> cards) {
    final list = cards.map((c) => {
      'id': c.id,
      'german': c.german,
      'english': c.english,
      'article': c.article.name,
      'plural': c.plural,
      'type': c.wordType.name,
      'example_de': c.exampleDe,
      'example_en': c.exampleEn,
      'notes': c.notes,
      'tags': c.tags.join(','),
      'memory_stage': c.memoryStage.name,
    }).toList();
    return const JsonEncoder.withIndent('  ').convert({'cards': list});
  }

  static String toCsv(List<Flashcard> cards) {
    final buffer = StringBuffer();
    buffer.writeln('german;english;article;plural;type;example_de;example_en;notes');
    for (final c in cards) {
      buffer.writeln(
        '${_escape(c.german)};${_escape(c.english)};${c.article.name};'
        '${_escape(c.plural)};${c.wordType.name};'
        '${_escape(c.exampleDe)};${_escape(c.exampleEn)};${_escape(c.notes)}',
      );
    }
    return buffer.toString();
  }

  static String _escape(String s) => s.replaceAll(';', ',');
}
