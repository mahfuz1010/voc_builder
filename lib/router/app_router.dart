import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/flashcard.dart';
import '../presentation/screens/add_card/add_card_screen.dart';
import '../presentation/screens/add_card/add_hub_screen.dart';
import '../presentation/screens/add_card/text_to_card_screen.dart';
import '../presentation/screens/decks/deck_detail_screen.dart';
import '../presentation/screens/decks/decks_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/home/stage_cards_screen.dart';
import '../presentation/screens/import_export/export_screen.dart';
import '../presentation/screens/import_export/import_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/study/study_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
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
          builder: (_, __) => const AddHubScreen(),
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
          path: '/decks',
          builder: (_, __) => const DecksScreen(),
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
          builder: (_, __) => const SettingsScreen(),
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

// ── Main shell with bottom navigation ────────────────────────────────────────

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/study')) return 1;
    if (location.startsWith('/add') || location.startsWith('/text-to-card')) {
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
