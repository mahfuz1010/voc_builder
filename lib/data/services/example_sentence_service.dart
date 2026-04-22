import 'dart:convert';
import 'dart:io';

class ExampleSentenceService {
  ExampleSentenceService._();

  static const String _apiHost = 'api.tatoeba.org';
  static const String _apiPath = '/unstable/sentences';

  /// Fetches a random German sentence that includes the provided word.
  static Future<String> fetchSimpleGermanSentence(String germanWord) async {
    final word = germanWord.trim();
    if (word.isEmpty) return '';

    final uri = Uri.https(_apiHost, _apiPath, {
      'sort': 'random',
      'lang': 'deu',
      'q': word,
    });

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return '';

      final payload = await utf8.decodeStream(response);
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return '';

      final data = decoded['data'];
      if (data is! List) return '';

      final candidates = <String>[];
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final text = (item['text'] as String? ?? '').trim();
        if (text.isEmpty) continue;
        if (!_containsWord(text, word)) continue;
        candidates.add(text);
      }

      if (candidates.isEmpty) return '';

      // API results are requested in random order, so pick the first match.
      return candidates.first;
    } catch (_) {
      return '';
    } finally {
      client.close(force: true);
    }
  }

  static bool _containsWord(String sentence, String word) {
    final normalizedSentence = sentence.toLowerCase();
    final normalizedWord = word.toLowerCase();
    final tokens = normalizedSentence
        .split(RegExp(r'[^a-zA-Z\u00C0-\u017F]+'))
        .where((t) => t.isNotEmpty);
    return tokens.contains(normalizedWord);
  }

}