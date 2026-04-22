import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../providers/card_provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/settings_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final decksAsync = ref.watch(decksStreamProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
            shadows: [
              Shadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(decksStreamProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Streak
            settingsAsync.whenOrNull(
                  data: (s) => s.streakDays > 0
                      ? _StreakCard(days: s.streakDays)
                      : const SizedBox.shrink(),
                ) ??
                const SizedBox.shrink(),

            const SizedBox(height: 16),

            // Stats grid
            statsAsync.when(
              data: (stats) => _StatsGrid(stats: stats),
              loading: () => const _StatsGridSkeleton(),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // Study today button
            statsAsync.whenOrNull(
                  data: (stats) => (stats['due'] ?? 0) > 0
                      ? _StudyNowButton(dueCount: stats['due']!)
                      : null,
                ) ??
                const SizedBox.shrink(),

            const SizedBox(height: 24),

            // Decks header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.decks,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/decks'),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Deck list preview
            decksAsync.when(
              data: (decks) => decks.isEmpty
                  ? const _EmptyDecksHint()
                  : Column(
                      children: decks
                          .take(4)
                          .map((d) => _DeckTile(
                                deckId: d.id,
                                deckName: d.name,
                              ))
                          .toList(),
                    ),
              loading: () => const CircularProgressIndicator.adaptive(),
                    error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Streak card ───────────────────────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final int days;
  const _StreakCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$days ${AppStrings.streak}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              const Text(
                'Keep it up!',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final Map<String, int> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: AppStrings.dueToday,
          value: stats['due'] ?? 0,
          color: AppColors.primary,
          icon: Icons.calendar_today,
          surfaceColor: colorScheme.surfaceContainerHighest,
        ),
        _StatCard(
          label: AppStrings.newCards,
          value: stats['new'] ?? 0,
          color: AppColors.newStageColor,
          icon: Icons.fiber_new_outlined,
          surfaceColor: colorScheme.surfaceContainerHighest,
        ),
        _StatCard(
          label: AppStrings.shortTerm,
          value: stats['shortTerm'] ?? 0,
          color: AppColors.shortTermStageColor,
          icon: Icons.timelapse,
          surfaceColor: colorScheme.surfaceContainerHighest,
          onTap: () => context.go('/cards-by-stage?stage=shortTerm'),
        ),
        _StatCard(
          label: AppStrings.longTerm,
          value: stats['longTerm'] ?? 0,
          color: AppColors.longTermStageColor,
          icon: Icons.check_circle_outline,
          surfaceColor: colorScheme.surfaceContainerHighest,
          onTap: () => context.go('/cards-by-stage?stage=longTerm'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final Color surfaceColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.surfaceColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Text(
              '$value',
              style: TextStyle(
                  color: color, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGridSkeleton extends StatelessWidget {
  const _StatsGridSkeleton();

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: List.generate(
          4,
          (_) => Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                ),
              )),
    );
  }
}

// ── Study now button ──────────────────────────────────────────────────────────

class _StudyNowButton extends StatelessWidget {
  final int dueCount;
  const _StudyNowButton({required this.dueCount});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.go('/study'),
      icon: const Icon(Icons.play_arrow_rounded, size: 24),
      label: Text('Study Now  •  $dueCount due'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

// ── Deck tile ─────────────────────────────────────────────────────────────────

class _DeckTile extends ConsumerWidget {
  final String deckId;
  final String deckName;
  const _DeckTile({required this.deckId, required this.deckName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsForDeckProvider(deckId));
    final dueAsync = ref.watch(dueCardsByDeckProvider(deckId));

    final total = cardsAsync.valueOrNull?.length ?? 0;
    final due = dueAsync.valueOrNull?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.layers_outlined, color: AppColors.primary),
        ),
        title: Text(deckName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$total cards • $due due',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () => context.go('/decks/$deckId'),
      ),
    );
  }
}

// ── Empty hint ────────────────────────────────────────────────────────────────

class _EmptyDecksHint extends StatelessWidget {
  const _EmptyDecksHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.layers_outlined, color: Colors.grey.shade600, size: 48),
            const SizedBox(height: 12),
            Text(
              'No decks yet.\nTap + to create your first deck.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
