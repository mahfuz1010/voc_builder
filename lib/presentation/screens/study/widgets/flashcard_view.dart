import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  late FlutterTts _tts;

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
    _tts = FlutterTts();
    _configureGermanTts();
  }

  Future<void> _configureGermanTts() async {
    await _tts.setLanguage('de-DE');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.45);
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
    _tts.stop();
    _controller.dispose();
    super.dispose();
  }

  String _germanSpeechText() {
    final base = widget.card.german.trim();
    if (base.isEmpty) return '';
    if (widget.card.article == Article.none) return base;
    return '${widget.card.article.displayLabel} $base';
  }

  Future<void> _speakGerman() async {
    final text = _germanSpeechText();
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * 3.14159;
        final isFront = _animation.value <= 0.5;

        return Stack(
          alignment: Alignment.center,
          children: [
            if (!widget.isPreview)
              const _DeckLayer(offset: Offset(12, 14), rotation: 0.025),
            if (!widget.isPreview)
              const _DeckLayer(offset: Offset(6, 7), rotation: -0.018),
            GestureDetector(
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
                        showSpeakGerman: !widget.isReversed,
                        onSpeakGerman: _speakGerman,
                      )
                    : Transform(
                        transform: Matrix4.identity()..rotateY(3.14159),
                        alignment: Alignment.center,
                        child: _BackFace(
                          card: widget.card,
                          reverse: widget.isReversed,
                          isPreview: widget.isPreview,
                          showSpeakGerman: widget.isReversed,
                          onSpeakGerman: _speakGerman,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeckLayer extends StatelessWidget {
  final Offset offset;
  final double rotation;

  const _DeckLayer({required this.offset, required this.rotation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.2,
            ),
          ),
          height: double.infinity,
        ),
      ),
    );
  }
}

// ── Front face ────────────────────────────────────────────────────────────────

class _FrontFace extends StatelessWidget {
  final Flashcard card;
  final bool reverse;
  final bool isPreview;
  final bool showSpeakGerman;
  final VoidCallback onSpeakGerman;
  const _FrontFace({
    required this.card,
    required this.reverse,
    required this.isPreview,
    required this.showSpeakGerman,
    required this.onSpeakGerman,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = isPreview
        ? colorScheme.surfaceContainerLow
        : colorScheme.surface;
    final articleColor = card.article != Article.none
        ? AppColors.articleColor(card.article)
        : AppColors.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (isPreview ? colorScheme.secondary : articleColor).withValues(
            alpha: isPreview ? 0.2 : 0.28,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPreview ? 0.03 : 0.06),
            blurRadius: isPreview ? 10 : 18,
            offset: const Offset(0, 7),
          ),
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
              SizedBox(
                width: double.infinity,
                child: Text(
                  reverse ? card.english : card.german,
                  style: TextStyle(
                    fontSize: reverse ? 34 : 32,
                    fontWeight: FontWeight.w800,
                    color: articleColor,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
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
              if (showSpeakGerman) ...[
                const SizedBox(height: 12),
                _SpeakGermanButton(onTap: onSpeakGerman),
              ],
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
  final bool showSpeakGerman;
  final VoidCallback onSpeakGerman;
  const _BackFace({
    required this.card,
    required this.reverse,
    required this.isPreview,
    required this.showSpeakGerman,
    required this.onSpeakGerman,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = isPreview
        ? colorScheme.surfaceContainerLow
        : colorScheme.surface;
    final primary = colorScheme.primary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: (isPreview ? colorScheme.secondary : primary).withValues(
            alpha: isPreview ? 0.2 : 0.24,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isPreview ? 0.03 : 0.06),
            blurRadius: isPreview ? 10 : 18,
            offset: const Offset(0, 7),
          ),
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
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        reverse ? card.german : card.english,
                        style: TextStyle(
                          fontSize: reverse ? 30 : 32,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
                if (showSpeakGerman) ...[
                  const SizedBox(height: 16),
                  _SpeakGermanButton(onTap: onSpeakGerman),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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

class _SpeakGermanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SpeakGermanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: const Icon(Icons.volume_up_rounded),
      label: const Text('Listen'),
    );
  }
}
