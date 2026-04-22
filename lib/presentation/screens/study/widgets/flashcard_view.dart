import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/article.dart';
import '../../../../core/enums/word_type.dart';
import '../../../../domain/entities/flashcard.dart';
import '../../../widgets/article_badge.dart';
import '../../../widgets/memory_stage_badge.dart';

class FlashcardView extends StatefulWidget {
  final Flashcard card;
  final bool isFlipped;
  final bool isReversed;
  final bool isPreview;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final String? deckName;

  const FlashcardView({
    super.key,
    required this.card,
    required this.isFlipped,
    this.isReversed = false,
    this.isPreview = false,
    required this.onTap,
    this.onEdit,
    this.deckName,
  });

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FlashcardView old) {
    super.didUpdateWidget(old);
    if (widget.isFlipped != old.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    if (widget.card.id != old.card.id) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * 3.14159;
        final isFront = _animation.value <= 0.5;

        return GestureDetector(
          onTap: widget.onTap,
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFront
                ? _FrontFace(
                    card: widget.card,
                    reverse: widget.isReversed,
                    isPreview: widget.isPreview,
                  )
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: _BackFace(
                      card: widget.card,
                      reverse: widget.isReversed,
                      isPreview: widget.isPreview,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

// ── Front face ────────────────────────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  final Flashcard card;
  final bool reverse;
  final bool isPreview;
  const _FrontFace({
    required this.card,
    required this.reverse,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surfaceContainerHighest;
    final surfaceTop = colorScheme.surface;
    final previewBase = colorScheme.surfaceContainerLow;
    final onSurface = colorScheme.onSurface;
    final articleColor = card.article != Article.none
        ? AppColors.articleColor(card.article)
        : AppColors.primary;
    
    // Enhanced premium gradients
    final leadColor = isPreview
        ? Color.lerp(previewBase, articleColor, 0.12)!
        : Color.lerp(surfaceTop, articleColor, 0.12)!;
    final trailColor = isPreview
        ? Color.lerp(previewBase, colorScheme.secondary, 0.10)!
        : Color.lerp(surface, articleColor, 0.08)!;
    final accentColor = Color.lerp(articleColor, colorScheme.secondary, 0.3)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [leadColor, trailColor, accentColor],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (isPreview ? colorScheme.secondary : articleColor)
              .withValues(alpha: isPreview ? 0.24 : 0.32),
          width: 2.5,
        ),
        boxShadow: [
          if (!isPreview) ...[
            BoxShadow(
              color: articleColor.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!reverse && card.article != Article.none) ...[
                ArticleBadge(article: card.article, fontSize: 18),
                const SizedBox(height: 12),
              ],
              Text(
                reverse ? card.english : card.german,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: articleColor,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (!reverse && card.plural.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: articleColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: articleColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Pl: ${card.plural}',
                    style: TextStyle(
                      color: articleColor.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              MemoryStageBadge(stage: card.memoryStage),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Back face ─────────────────────────────────────────────────────────────────

class _BackFace extends StatelessWidget {
  final Flashcard card;
  final bool reverse;
  final bool isPreview;
  const _BackFace({
    required this.card,
    required this.reverse,
    required this.isPreview,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surfaceContainerHighest;
    final primary = colorScheme.primary;
    final previewBase = colorScheme.surfaceContainerLow;
    
    // Enhanced premium gradients for back
    final leadColor = isPreview
        ? Color.lerp(previewBase, colorScheme.secondary, 0.14)!
        : Color.lerp(surface, primary, 0.14)!;
    final midColor = Color.lerp(surface, primary, 0.08)!;
    final trailColor = isPreview
        ? Color.lerp(previewBase, primary, 0.06)!
        : Color.lerp(surface, primary, 0.04)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [leadColor, midColor, trailColor],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (isPreview ? colorScheme.secondary : primary)
              .withValues(alpha: isPreview ? 0.22 : 0.28),
          width: 2.5,
        ),
        boxShadow: [
          if (!isPreview) ...[
            BoxShadow(
              color: primary.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ] else ...[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: constraints.maxHeight * 0.4,
                  child: Center(
                    child: Text(
                      reverse ? card.german : card.english,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        primary.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!reverse) _GrammarDetails(card: card),
                if ((reverse && card.exampleEn.isNotEmpty) ||
                    (!reverse && card.exampleDe.isNotEmpty)) ...[
                  const SizedBox(height: 16),
                  _ExampleBlock(
                    de: reverse ? card.exampleEn : card.exampleDe,
                    en: reverse ? card.exampleDe : card.exampleEn,
                  ),
                ],
                if (card.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      card.notes,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GrammarDetails extends StatelessWidget {
  final Flashcard card;
  const _GrammarDetails({required this.card});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    switch (card.wordType) {
      case WordType.verb:
        if (card.verbIchForm.isNotEmpty) {
          items.add(_GrammarRow('ich', card.verbIchForm));
        }
        if (card.partizipII.isNotEmpty) {
          items.add(_GrammarRow('Partizip II', card.partizipII));
        }
        break;
      case WordType.adjective:
        if (card.comparative.isNotEmpty) {
          items.add(_GrammarRow('comparative', card.comparative));
        }
        if (card.superlative.isNotEmpty) {
          items.add(_GrammarRow('superlative', card.superlative));
        }
        break;
      case WordType.noun:
        if (card.plural.isNotEmpty) {
          items.add(_GrammarRow('plural', card.plural));
        }
        break;
      default:
        break;
    }

    if (items.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: items);
  }
}

class _GrammarRow extends StatelessWidget {
  final String label;
  final String value;
  const _GrammarRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleBlock extends StatelessWidget {
  final String de;
  final String en;
  const _ExampleBlock({required this.de, required this.en});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            de,
            style: const TextStyle(
                color: AppColors.onSurface,
                fontStyle: FontStyle.italic,
                fontSize: 14),
          ),
          if (en.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              en,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
