import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/supported_languages.dart';
import 'settings_provider.dart';

/// The currently active language profile — derived from the user's
/// `targetLanguage` setting (or manually overridden while the app is running).
///
/// A "profile" is simply a [SupportedLanguage].  Decks and cards are filtered
/// to only the active profile's language code, so each profile has its own
/// isolated set of vocabulary.
class ActiveProfileNotifier extends Notifier<String> {
  @override
  String build() {
    // Default to whatever the settings say.
    final settings = ref.watch(settingsProvider).valueOrNull;
    return settings?.targetLanguage ?? 'de';
  }

  /// Temporarily switch to [languageCode] without persisting to settings.
  /// Used by the profile switcher in the UI.
  void setActiveProfile(String languageCode) {
    state = languageCode;
  }

  /// Switch profile AND persist the change to settings.
  Future<void> switchAndPersist(String languageCode) async {
    state = languageCode;
    await ref.read(settingsProvider.notifier).setTargetLanguage(languageCode);
    // Also update TTS / other language-specific state if needed.
  }
}

final activeProfileProvider =
    NotifierProvider<ActiveProfileNotifier, String>(ActiveProfileNotifier.new);

/// Convenience provider: the full [SupportedLanguage] object for the active profile.
final activeLanguageProvider = Provider<SupportedLanguage>((ref) {
  final code = ref.watch(activeProfileProvider);
  return SupportedLanguage.fromCode(code);
});
