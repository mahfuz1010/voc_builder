import 'package:translator/translator.dart';

class TranslationService {
  TranslationService._();

  static final _translator = GoogleTranslator();

  /// Uses Google's default language detection and translates to English.
  static Future<String> translateToEnglish(String text) {
    return translate(text, to: 'en');
  }

  /// Uses Google's default language detection and translates to German.
  static Future<String> translateToGerman(String text) {
    return translate(text, to: 'de');
  }

  static Future<String> translate(
    String text, {
    required String to,
  }) async {
    final input = text.trim();
    if (input.isEmpty) return '';

    try {
      final result = await _translator.translate(input, to: to);
      return result.text.trim();
    } catch (_) {
      return '';
    }
  }
}
