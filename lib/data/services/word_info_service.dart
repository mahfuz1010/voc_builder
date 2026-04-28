import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../domain/entities/word_info.dart';

/// Service for fetching word information (synonyms, antonyms, definitions) from German-only APIs
class WordInfoService {
  WordInfoService._();

  static const String _openThesaurusHost = 'www.openthesaurus.de';
  static const String _openThesaurusPath = '/synonyme/search';
  static const String _wiktionaryHost = 'de.wiktionary.org';
  static const String _wiktionaryPath = '/w/api.php';

  static final RegExp _nonLetterOrDigit = RegExp(r'[^a-z0-9äöüß]+');
  static final RegExp _wiktionaryLinkPattern = RegExp(r'\[\[([^\]|]+)(?:\|([^\]]+))?\]\]');
  static final RegExp _leadingGermanArticlePattern = RegExp(
    r'^(der|die|das)\s+',
    caseSensitive: false,
  );
  static final RegExp _lookupSeparatorPattern = RegExp(r'\s*(?:,|/|;)\s*');
  static final RegExp _wiktionarySensePrefixPattern = RegExp(r'^:\[[^\]]+\]\s*');
  static final RegExp _wiktionaryTemplatePattern = RegExp(r'\{\{[^{}]*\}\}');
  static final RegExp _wiktionaryRefPattern = RegExp(r'<ref[^>]*>.*?</ref>|<ref[^/]*/>', dotAll: true);
  static final RegExp _wiktionaryItalicPattern = RegExp(r"'{2,}");

  /// Fetch word information (synonyms, antonyms, definitions) for a German word
  ///
  /// Uses German-only free APIs:
  /// - OpenThesaurus for authentic German synonyms and related terms
  /// - Wiktionary (de) for German definitions
  static Future<WordInfo> fetchWordInfo(String word) async {
    final originalWord = _normalizeLookupInput(word);
    final w = originalWord.toLowerCase();
    if (w.isEmpty) return WordInfo.empty();

    try {
      if (kDebugMode) print('🔍 Fetching word info for: $w');

      final thesaurusData = await _fetchFromOpenThesaurus(w);
      if (kDebugMode) {
        print('📚 OpenThesaurus - synonyms: ${thesaurusData['synonyms']}, antonyms: ${thesaurusData['antonyms']}');
      }

      final wiktionaryContent = await _fetchGermanWiktionaryContent(originalWord);
      final wikiDef = _extractGermanDefinitionFromWiktionaryContent(wiktionaryContent);
      final wikiAntonyms = _extractWiktionarySectionTerms(
        wiktionaryContent,
        sectionName: 'Gegenwörter',
        excludedTerm: originalWord,
      );
      if (kDebugMode) print('📖 Wiktionary definition: $wikiDef');
      if (kDebugMode) print('↔️ Wiktionary antonyms: $wikiAntonyms');

      final synonyms = thesaurusData['synonyms'] ?? const <String>[];
      final antonyms = wikiAntonyms;

      if (kDebugMode) {
        final defPreview = wikiDef.length > 50 ? '${wikiDef.substring(0, 50)}...' : wikiDef;
        print('✅ Final - synonyms: $synonyms, antonyms: $antonyms, def: $defPreview');
      }

      if (synonyms.isEmpty && antonyms.isEmpty && wikiDef.isEmpty) {
        return WordInfo.empty();
      }

      return WordInfo(
        definition: wikiDef,
        details: wikiDef,
        synonyms: synonyms.take(3).toList(),
        antonyms: antonyms.take(2).toList(),
        isFetched: true,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error fetching word info: $e');
      return WordInfo.empty();
    }
  }

  /// Fetch synonyms and antonyms from OpenThesaurus (German)
  /// Returns a map with 'synonyms' and 'antonyms' keys
  static Future<Map<String, List<String>>> _fetchFromOpenThesaurus(String word) async {
    final uri = Uri.https(_openThesaurusHost, _openThesaurusPath, {
      'q': word,
      'format': 'application/json',
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.add('Accept', 'application/json');
      request.headers.add('User-Agent', 'VocBuilderApp/1.0');

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        return {'synonyms': [], 'antonyms': []};
      }

      final payload = await utf8.decodeStream(response);
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) {
        return {'synonyms': [], 'antonyms': []};
      }

      final synsets = decoded['synsets'] as List?;
      if (synsets == null || synsets.isEmpty) {
        return {'synonyms': [], 'antonyms': []};
      }

      final synonyms = <String>[];
      final exactSynset = _pickBestSynsetMatch(synsets, word);

      if (exactSynset != null) {
        final terms = exactSynset['terms'] as List?;
        if (terms != null) {
          for (final termObj in terms) {
            if (termObj is! Map<String, dynamic>) continue;
            final term = (termObj['term'] as String? ?? '').trim();
            if (term.isEmpty) continue;
            if (_normalizeLookupTerm(term) == _normalizeLookupTerm(word)) continue;
            if (!_looksLikeUsefulSynonym(term)) continue;
            if (!synonyms.contains(term) && synonyms.length < 3) {
              synonyms.add(term);
            }
          }
        }
      }

      if (kDebugMode) {
        print('  📊 OpenThesaurus found ${synsets.length} synsets');
        print('  ✓ Extracted ${synonyms.length} synonyms: $synonyms');
      }

      return {
        'synonyms': synonyms,
        'antonyms': const <String>[],
      };
    } catch (e) {
      if (kDebugMode) print('  ❌ OpenThesaurus error: $e');
      return {'synonyms': [], 'antonyms': []};
    } finally {
      client.close(force: true);
    }
  }

  static Map<String, dynamic>? _pickBestSynsetMatch(List synsets, String word) {
    final normalizedWord = _normalizeLookupTerm(word);

    for (final synset in synsets) {
      if (synset is! Map<String, dynamic>) continue;
      final terms = synset['terms'] as List?;
      if (terms == null) continue;

      for (final termObj in terms) {
        if (termObj is! Map<String, dynamic>) continue;
        final term = (termObj['term'] as String? ?? '').trim();
        if (_normalizeLookupTerm(term) == normalizedWord) {
          return synset;
        }
      }
    }

    for (final synset in synsets) {
      if (synset is Map<String, dynamic>) {
        return synset;
      }
    }

    return null;
  }

  static String _normalizeLookupTerm(String value) {
    return value.toLowerCase().replaceAll(_nonLetterOrDigit, '');
  }

  static String _normalizeLookupInput(String value) {
    final trimmed = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    final withoutArticle = trimmed.replaceFirst(_leadingGermanArticlePattern, '').trim();
    final firstSegment = withoutArticle.split(_lookupSeparatorPattern).first.trim();
    return firstSegment;
  }

  static bool _looksLikeUsefulSynonym(String term) {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains('...')) return false;
    if (trimmed.startsWith('(') && trimmed.endsWith(')')) return false;
    return true;
  }

  static Future<String> _fetchGermanWiktionaryContent(String word) async {
    final uri = Uri.https(_wiktionaryHost, _wiktionaryPath, {
      'action': 'query',
      'prop': 'revisions',
      'rvslots': 'main',
      'rvprop': 'content',
      'redirects': '1',
      'titles': word,
      'format': 'json',
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      request.headers.add('Accept', 'application/json');
      request.headers.add('User-Agent', 'VocBuilderApp/1.0');
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return '';

      final payload = await utf8.decodeStream(response);
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return '';

      final query = decoded['query'] as Map<String, dynamic>?;
      final pages = query?['pages'] as Map<String, dynamic>?;
      if (pages == null || pages.isEmpty) return '';

      for (final page in pages.values) {
        if (page is! Map<String, dynamic>) continue;
        final revisions = page['revisions'] as List?;
        if (revisions == null || revisions.isEmpty) continue;

        final revision = revisions.first as Map<String, dynamic>?;
        final slots = revision?['slots'] as Map<String, dynamic>?;
        final main = slots?['main'] as Map<String, dynamic>?;
        final content = (main?['*'] as String? ?? '').trim();
        if (content.isNotEmpty) return content;
      }

      return '';
    } catch (e) {
      if (kDebugMode) print('  ❌ Wiktionary content error: $e');
      return '';
    } finally {
      client.close(force: true);
    }
  }

  static String _extractGermanDefinitionFromWiktionaryContent(String content) {
    if (content.isEmpty) return '';

    final marker = '{{Bedeutungen}}';
    final start = content.indexOf(marker);
    if (start == -1) return '';

    final afterMarker = content.substring(start + marker.length);
    final nextSectionIndex = afterMarker.indexOf('\n\n{{');
    final sectionBody = nextSectionIndex == -1
        ? afterMarker
        : afterMarker.substring(0, nextSectionIndex);

    final lines = sectionBody
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.startsWith(':'));

    for (final line in lines) {
      final cleaned = _cleanWiktionaryText(
        line.replaceFirst(_wiktionarySensePrefixPattern, ''),
      );
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }

    return '';
  }

  static List<String> _extractWiktionarySectionTerms(
    String content, {
    required String sectionName,
    required String excludedTerm,
  }) {
    final marker = '{{$sectionName}}';
    final start = content.indexOf(marker);
    if (start == -1) return const [];

    final afterMarker = content.substring(start + marker.length);
    final nextSectionIndex = afterMarker.indexOf('\n\n{{');
    final sectionBody = nextSectionIndex == -1
        ? afterMarker
        : afterMarker.substring(0, nextSectionIndex);

    final out = <String>[];
    for (final match in _wiktionaryLinkPattern.allMatches(sectionBody)) {
      final rawValue = (match.group(2) ?? match.group(1) ?? '').trim();
      if (rawValue.isEmpty) continue;
      if (_normalizeLookupTerm(rawValue) == _normalizeLookupTerm(excludedTerm)) {
        continue;
      }
      if (!_looksLikeUsefulSynonym(rawValue)) continue;
      if (!out.contains(rawValue)) out.add(rawValue);
      if (out.length >= 3) break;
    }

    return out;
  }

  static String _cleanWiktionaryText(String value) {
    var cleaned = value;
    cleaned = cleaned.replaceAll(_wiktionaryRefPattern, '');
    cleaned = cleaned.replaceAllMapped(_wiktionaryLinkPattern, (match) {
      return (match.group(2) ?? match.group(1) ?? '').trim();
    });
    cleaned = cleaned.replaceAll(_wiktionaryTemplatePattern, '');
    cleaned = cleaned.replaceAll(_wiktionaryItalicPattern, '');
    cleaned = cleaned.replaceAll('&nbsp;', ' ');
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }
}
