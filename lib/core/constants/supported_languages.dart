/// A language the user can choose as their target (language to learn) or
/// native (interface / translation) language.
class SupportedLanguage {
  final String code;        // BCP-47 code used by Google Translate & TTS
  final String tatoebaCode; // 3-letter ISO 639-3 code for Tatoeba API
  final String name;        // English display name
  final String flag;        // Emoji flag
  final String nativeName;  // Name in that language
  /// Whether this language has a grammatical article selector (der/die/das…).
  /// Currently only German uses the built-in article feature.
  final bool hasArticles;

  const SupportedLanguage({
    required this.code,
    required this.tatoebaCode,
    required this.name,
    required this.flag,
    required this.nativeName,
    this.hasArticles = false,
  });

  /// Full TTS locale string, e.g. 'de-DE'.
  String get ttsLocale {
    const overrides = <String, String>{
      'zh': 'zh-CN',
      'pt': 'pt-BR',
    };
    return overrides[code] ?? '$code-${code.toUpperCase()}';
  }

  static const List<SupportedLanguage> all = [
    SupportedLanguage(
      code: 'de',
      tatoebaCode: 'deu',
      name: 'German',
      flag: '🇩🇪',
      nativeName: 'Deutsch',
      hasArticles: true,
    ),
    SupportedLanguage(
      code: 'fr',
      tatoebaCode: 'fra',
      name: 'French',
      flag: '🇫🇷',
      nativeName: 'Français',
    ),
    SupportedLanguage(
      code: 'es',
      tatoebaCode: 'spa',
      name: 'Spanish',
      flag: '🇪🇸',
      nativeName: 'Español',
    ),
    SupportedLanguage(
      code: 'it',
      tatoebaCode: 'ita',
      name: 'Italian',
      flag: '🇮🇹',
      nativeName: 'Italiano',
    ),
    SupportedLanguage(
      code: 'pt',
      tatoebaCode: 'por',
      name: 'Portuguese',
      flag: '🇧🇷',
      nativeName: 'Português',
    ),
    SupportedLanguage(
      code: 'nl',
      tatoebaCode: 'nld',
      name: 'Dutch',
      flag: '🇳🇱',
      nativeName: 'Nederlands',
    ),
    SupportedLanguage(
      code: 'ru',
      tatoebaCode: 'rus',
      name: 'Russian',
      flag: '🇷🇺',
      nativeName: 'Русский',
    ),
    SupportedLanguage(
      code: 'pl',
      tatoebaCode: 'pol',
      name: 'Polish',
      flag: '🇵🇱',
      nativeName: 'Polski',
    ),
    SupportedLanguage(
      code: 'sv',
      tatoebaCode: 'swe',
      name: 'Swedish',
      flag: '🇸🇪',
      nativeName: 'Svenska',
    ),
    SupportedLanguage(
      code: 'tr',
      tatoebaCode: 'tur',
      name: 'Turkish',
      flag: '🇹🇷',
      nativeName: 'Türkçe',
    ),
    SupportedLanguage(
      code: 'ja',
      tatoebaCode: 'jpn',
      name: 'Japanese',
      flag: '🇯🇵',
      nativeName: '日本語',
    ),
    SupportedLanguage(
      code: 'ko',
      tatoebaCode: 'kor',
      name: 'Korean',
      flag: '🇰🇷',
      nativeName: '한국어',
    ),
    SupportedLanguage(
      code: 'zh',
      tatoebaCode: 'cmn',
      name: 'Chinese',
      flag: '🇨🇳',
      nativeName: '中文',
    ),
    SupportedLanguage(
      code: 'ar',
      tatoebaCode: 'ara',
      name: 'Arabic',
      flag: '🇸🇦',
      nativeName: 'العربية',
    ),
    SupportedLanguage(
      code: 'en',
      tatoebaCode: 'eng',
      name: 'English',
      flag: '🇬🇧',
      nativeName: 'English',
    ),
  ];

  static SupportedLanguage fromCode(String code) {
    return all.firstWhere(
      (l) => l.code == code,
      orElse: () => all.first,
    );
  }
}
