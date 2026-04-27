import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/flashcard.dart';
import '../presentation/providers/settings_provider.dart';
import '../presentation/screens/add_card/add_card_screen.dart';
import '../presentation/screens/add_card/add_hub_screen.dart';
import '../presentation/screens/add_card/image_to_card_screen.dart';
import '../presentation/screens/add_card/text_to_card_screen.dart';
import '../presentation/screens/decks/deck_detail_screen.dart';
import '../presentation/screens/decks/decks_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/stage_cards_screen.dart';
import '../presentation/screens/import_export/export_screen.dart';
import '../presentation/screens/import_export/import_screen.dart';
import '../presentation/screens/onboarding/language_selection_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/study/study_screen.dart';

/// Riverpod-aware router that redirects to onboarding when the user has not
/// yet selected a target language.
final routerProvider = Provider<GoRouter>((ref) {
  // Listen to settings so the router is notified when onboarding completes.
  final settingsListenable = ValueNotifier<AppSettings?>(null);

  ref.listen<AsyncValue<AppSettings>>(settingsProvider, (_, next) {
    settingsListenable.value = next.valueOrNull;
  });

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: settingsListenable,
    redirect: (context, state) {
      final settings = settingsListenable.value;
      // While settings are still loading, stay put.
      if (settings == null) return null;

      final onboarding = state.matchedLocation == '/onboarding';
      if (!settings.isOnboarded && !onboarding) return '/onboarding';
      if (settings.isOnboarded && onboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const LanguageSelectionScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/study',
            builder: (_, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return StudyScreen(deckId: extra?['deckId'] as String?);
            },
          ),
          GoRoute(
            path: '/add-hub',
            builder: (context, state) => const AddHubScreen(),
          ),
          GoRoute(
            path: '/add',
            builder: (_, state) {
              final deckId = state.uri.queryParameters['deckId'];
              return AddCardScreen(
                editCard: deckId != null ? null : null,
              );
            },
          ),
          GoRoute(
            path: '/edit-card',
            builder: (_, state) {
              final card = state.extra as Flashcard?;
              return AddCardScreen(editCard: card);
            },
          ),
          GoRoute(
            path: '/text-to-card',
            builder: (_, state) {
              final deckId = state.uri.queryParameters['deckId'];
              return TextToCardScreen(preselectedDeckId: deckId);
            },
          ),
          GoRoute(
            path: '/image-to-card',
            builder: (_, state) {
              final deckId = state.uri.queryParameters['deckId'];
              return ImageToCardScreen(preselectedDeckId: deckId);
            },
          ),
          GoRoute(
            path: '/decks',
            builder: (context, state) => const DecksScreen(),
            routes: [
              GoRoute(
                path: ':deckId',
                builder: (_, state) => DeckDetailScreen(
                  deckId: state.pathParameters['deckId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/import',
            builder: (_, state) {
              final deckId = state.uri.queryParameters['deckId'];
              return ImportScreen(preselectedDeckId: deckId);
            },
          ),
          GoRoute(
            path: '/export',
            builder: (_, state) {
              final deckId = state.uri.queryParameters['deckId'];
              return ExportScreen(deckId: deckId);
            },
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/cards-by-stage',
            builder: (_, state) {
              final stage = state.uri.queryParameters['stage'];
              final stageIndex = switch (stage) {
                'shortTerm' => 1,
                'longTerm' => 2,
                _ => 0,
              };
              return StageCardsScreen(stageIndex: stageIndex);
            },
          ),
        ],
      ),
    ],
  );
});

// ── Main shell with bottom navigation ────────────────────────────────────────

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/study')) return 1;
    if (location.startsWith('/add') ||
        location.startsWith('/text-to-card') ||
        location.startsWith('/image-to-card')) {
      return 2;
    }
    if (location.startsWith('/decks')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0; // /home
  }

  @override
  Widget build(BuildContext context) {
    final index = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/study');
            case 2:
              context.go('/add-hub');
            case 3:
              context.go('/decks');
            case 4:
              context.go('/settings');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers_outlined),
            activeIcon: Icon(Icons.layers),
            label: 'Decks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
