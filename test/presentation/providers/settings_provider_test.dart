import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocbuilder/presentation/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsNotifier', () {
    test('loads defaults when SharedPreferences is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = await container.read(settingsProvider.future);
      expect(settings.darkMode, isTrue);
      expect(settings.dailyNewLimit, 20);
      expect(settings.targetLanguage, 'de');
      expect(settings.isOnboarded, isFalse);
    });

    test('persists dark mode and daily limit updates', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(settingsProvider.future);

      await container.read(settingsProvider.notifier).setDarkMode(false);
      await container.read(settingsProvider.notifier).setDailyLimit(40);

      final updated = container.read(settingsProvider).value;
      expect(updated?.darkMode, isFalse);
      expect(updated?.dailyNewLimit, 40);
    });

    test('recordStudySession increments streak for consecutive day', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'streak_days': 5,
        'last_study_date': yesterday.millisecondsSinceEpoch,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(settingsProvider.future);

      await container.read(settingsProvider.notifier).recordStudySession();

      final updated = container.read(settingsProvider).value;
      expect(updated?.streakDays, 6);
    });

    test('recordStudySession resets streak when last session was stale', () async {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      SharedPreferences.setMockInitialValues({
        'streak_days': 5,
        'last_study_date': threeDaysAgo.millisecondsSinceEpoch,
      });
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(settingsProvider.future);

      await container.read(settingsProvider.notifier).recordStudySession();

      final updated = container.read(settingsProvider).value;
      expect(updated?.streakDays, 1);
    });
  });
}
