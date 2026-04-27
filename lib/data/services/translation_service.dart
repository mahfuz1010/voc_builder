import 'package:translator/translator.dart';

class TranslationService {
  TranslationService._();

  static final _translator = GoogleTranslator();

  /// Translates [text] to [targetLanguageCode] (e.g. 'en', 'de', 'fr').
  /// Uses Google's automatic source-language detection.
  static Future<String> translate(
    String text, {
    required String to,
    String from = 'auto',
  }) async {
    final input = text.trim();
    if (input.isEmpty) return '';

    try {
      final result = await _translator.translate(input, from: from, to: to);
      return result.text.trim();
    } catch (_) {
      return '';
    }
  }

  // ── Convenience helpers (kept for backward compatibility) ─────────────────

  /// Translates [text] to English.
  static Future<String> translateToEnglish(String text) =>
      translate(text, to: 'en');

  /// Translates [text] to the given [targetCode] (e.g. 'de', 'fr').
  static Future<String> translateToTarget(String text, String targetCode) =>
      translate(text, to: targetCode);
}

