import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings state
class AppSettings {
  final bool darkMode;
  final int dailyNewLimit;
  final bool bidirectionalStudy;
  final int streakDays;
  final DateTime? lastStudyDate;
  /// BCP-47 code of the language the user is learning (e.g. 'de', 'fr').
  final String targetLanguage;
  /// BCP-47 code of the user's native/interface language (e.g. 'en').
  final String nativeLanguage;
  /// Whether the user has completed language onboarding.
  final bool isOnboarded;
  final bool hasSeenSwipeHint;
  final List<int> shortTermIntervalsMinutes;
  final List<int> longTermIntervalsDays;

  const AppSettings({
    this.darkMode = true,
    this.dailyNewLimit = 20,
    this.bidirectionalStudy = true,
    this.streakDays = 0,
    this.lastStudyDate,
    this.targetLanguage = 'de',
    this.nativeLanguage = 'en',
    this.isOnboarded = false,
    this.hasSeenSwipeHint = false,
    this.shortTermIntervalsMinutes = const [10, 60, 1440],
    this.longTermIntervalsDays = const [3, 7, 14, 30, 90],
  });

  AppSettings copyWith({
    bool? darkMode,
    int? dailyNewLimit,
    bool? bidirectionalStudy,
    int? streakDays,
    DateTime? lastStudyDate,
    String? targetLanguage,
    String? nativeLanguage,
    bool? isOnboarded,
    bool? hasSeenSwipeHint,
    List<int>? shortTermIntervalsMinutes,
    List<int>? longTermIntervalsDays,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      dailyNewLimit: dailyNewLimit ?? this.dailyNewLimit,
      bidirectionalStudy: bidirectionalStudy ?? this.bidirectionalStudy,
      streakDays: streakDays ?? this.streakDays,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      hasSeenSwipeHint: hasSeenSwipeHint ?? this.hasSeenSwipeHint,
      shortTermIntervalsMinutes: shortTermIntervalsMinutes ?? this.shortTermIntervalsMinutes,
      longTermIntervalsDays: longTermIntervalsDays ?? this.longTermIntervalsDays,
    );
  }
}



class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _darkModeKey = 'dark_mode';
  static const _dailyLimitKey = 'daily_limit';
  static const _bidirectionalStudyKey = 'bidirectional_study';
  static const _streakKey = 'streak_days';
  static const _lastStudyKey = 'last_study_date';
  static const _targetLanguageKey = 'target_language';
  static const _nativeLanguageKey = 'native_language';
  static const _isOnboardedKey = 'is_onboarded';
  static const _hasSeenSwipeHintKey = 'has_seen_swipe_hint';
  static const _shortTermKey = 'short_term_intervals';
  static const _longTermKey = 'long_term_intervals';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStudyMs = prefs.getInt(_lastStudyKey);

    List<int> shortTerm = [10, 60, 1440];
    final shortStr = prefs.getString(_shortTermKey);
    if (shortStr != null) {
      try {
        shortTerm = List<int>.from(jsonDecode(shortStr));
      } catch (_) {}
    }

    List<int> longTerm = [3, 7, 14, 30, 90];
    final longStr = prefs.getString(_longTermKey);
    if (longStr != null) {
      try {
        longTerm = List<int>.from(jsonDecode(longStr));
      } catch (_) {}
    }

    return AppSettings(
      darkMode: prefs.getBool(_darkModeKey) ?? true,
      dailyNewLimit: prefs.getInt(_dailyLimitKey) ?? 20,
      bidirectionalStudy: prefs.getBool(_bidirectionalStudyKey) ?? true,
      streakDays: prefs.getInt(_streakKey) ?? 0,
      lastStudyDate: lastStudyMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastStudyMs)
          : null,
      targetLanguage: prefs.getString(_targetLanguageKey) ?? 'de',
      nativeLanguage: prefs.getString(_nativeLanguageKey) ?? 'en',
      isOnboarded: prefs.getBool(_isOnboardedKey) ?? false,
      hasSeenSwipeHint: prefs.getBool(_hasSeenSwipeHintKey) ?? false,
      shortTermIntervalsMinutes: shortTerm,
      longTermIntervalsDays: longTerm,
    );
  }

  Future<void> setHasSeenSwipeHint() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenSwipeHintKey, true);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(hasSeenSwipeHint: true));
  }

  Future<void> setShortTermIntervals(List<int> intervals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_shortTermKey, jsonEncode(intervals));
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(shortTermIntervalsMinutes: intervals));
  }

  Future<void> setLongTermIntervals(List<int> intervals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_longTermKey, jsonEncode(intervals));
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(longTermIntervalsDays: intervals));
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(darkMode: value));
  }

  Future<void> setDailyLimit(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyLimitKey, value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(dailyNewLimit: value));
  }

  Future<void> setBidirectionalStudy(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bidirectionalStudyKey, value);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(bidirectionalStudy: value));
  }

  Future<void> setTargetLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetLanguageKey, code);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(targetLanguage: code));
  }

  Future<void> setNativeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nativeLanguageKey, code);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(nativeLanguage: code));
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isOnboardedKey, true);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(isOnboarded: true));
  }

  Future<void> recordStudySession() async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.valueOrNull ?? const AppSettings();
    final now = DateTime.now();
    final last = current.lastStudyDate;
    int newStreak = current.streakDays;

    if (last == null) {
      newStreak = 1;
    } else {
      final today = DateTime(now.year, now.month, now.day);
      final lastDay = DateTime(last.year, last.month, last.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        newStreak++;
      } else if (diff > 1) {
        newStreak = 1;
      }
      // diff == 0 means same day, no change
    }

    await prefs.setInt(_streakKey, newStreak);
    await prefs.setInt(_lastStudyKey, now.millisecondsSinceEpoch);
    state = AsyncData(current.copyWith(
      streakDays: newStreak,
      lastStudyDate: now,
    ));
  }

  Future<void> resetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_streakKey, 0);
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncData(current.copyWith(streakDays: 0));
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
