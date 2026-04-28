import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../core/enums/article.dart';
import '../../../../core/enums/word_type.dart';
import '../../../../domain/entities/flashcard.dart';
import '../../../../domain/entities/word_info.dart';
import '../../../providers/settings_provider.dart';
import '../../../widgets/article_badge.dart';
import '../../../widgets/memory_stage_badge.dart';

class FlashcardView extends ConsumerStatefulWidget {
  final Flashcard card;
  final bool isFlipped;
  final bool isReversed;
  final bool isPreview;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onInfoTap;
  final bool infoLoading;
  final String? deckName;

  const FlashcardView({
    super.key,
    required this.card,
    required this.isFlipped,
    this.isReversed = false,
    this.isPreview = false,
    required this.onTap,
    this.onEdit,
    this.onInfoTap,
    this.infoLoading = false,
    this.deckName,
  });

  @override
  ConsumerState<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends ConsumerState<FlashcardView>
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
    _configureTts();
  }

  Future<void> _configureTts() async {
    final settings = ref.read(settingsProvider).valueOrNull;
    final langCode = settings?.targetLanguage ?? 'de';
    final locale = SupportedLanguage.fromCode(langCode).ttsLocale;
    await _tts.setLanguage(locale);
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

  String _targetSpeechText() {
    final base = widget.card.german.trim();
    if (base.isEmpty) return '';
    if (widget.card.article == Article.none) return base;
    return '${widget.card.article.displayLabel} $base';
  }

  Future<void> _speakTarget() async {
    final text = _targetSpeechText();
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    final useArabicTargetStyle = (settings?.targetLanguage ?? 'de') == 'ar';

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
                        showSpeakTarget: !widget.isReversed,
                        onSpeakTarget: _speakTarget,
                        onInfoTap: widget.onInfoTap,
                        infoLoading: widget.infoLoading,
                        deckName: widget.deckName,
                        useArabicTargetStyle: useArabicTargetStyle,
                      )
                    : Transform(
                        transform: Matrix4.identity()..rotateY(3.14159),
                        alignment: Alignment.center,
                        child: _BackFace(
                          card: widget.card,
                          reverse: widget.isReversed,
                          isPreview: widget.isPreview,
                          showSpeakTarget: widget.isReversed,
                          onSpeakTarget: _speakTarget,
                          onInfoTap: widget.onInfoTap,
                          infoLoading: widget.infoLoading,
                          deckName: widget.deckName,
                          useArabicTargetStyle: useArabicTargetStyle,
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
  final bool showSpeakTarget;
  final VoidCallback onSpeakTarget;
  final VoidCallback? onInfoTap;
  final bool infoLoading;
  final String? deckName;
  final bool useArabicTargetStyle;
  const _FrontFace({
    required this.card,
    required this.reverse,
    required this.isPreview,
    required this.showSpeakTarget,
    required this.onSpeakTarget,
    this.onInfoTap,
    required this.infoLoading,
    this.deckName,
    required this.useArabicTargetStyle,
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
    final showingTargetSide = !reverse;

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: Text(
                        reverse ? card.english : card.german,
                        textDirection: showingTargetSide && useArabicTargetStyle
                            ? TextDirection.rtl
                            : null,
                        style: _withArabicTargetFallback(
                          TextStyle(
                            fontSize: reverse ? 34 : 32,
                            fontWeight: FontWeight.w800,
                            color: articleColor,
                            letterSpacing: -0.2,
                          ),
                          enable: showingTargetSide && useArabicTargetStyle,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: _InfoIconButton(
                        hasData: card.wordInfo.hasData,
                        loading: infoLoading,
                        onTap: onInfoTap,
                      ),
                    ),
                  ],
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
              if (showSpeakTarget) ...[
                const SizedBox(height: 12),
                _SpeakTargetButton(onTap: onSpeakTarget),
              ],
            ],
          ),
          if ((deckName ?? '').trim().isNotEmpty && !reverse)
            Positioned(
              right: 0,
              bottom: 0,
              child: _DeckNameBadge(deckName: deckName!.trim()),
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
  final bool showSpeakTarget;
  final VoidCallback onSpeakTarget;
  final VoidCallback? onInfoTap;
  final bool infoLoading;
  final String? deckName;
  final bool useArabicTargetStyle;
  const _BackFace({
    required this.card,
    required this.reverse,
    required this.isPreview,
    required this.showSpeakTarget,
    required this.onSpeakTarget,
    this.onInfoTap,
    required this.infoLoading,
    this.deckName,
    required this.useArabicTargetStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = isPreview
        ? colorScheme.surfaceContainerLow
        : colorScheme.surface;
    final primary = colorScheme.primary;
    final showingTargetSide = reverse;

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
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: constraints.maxHeight * 0.25,
                      child: Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 40),
                                child: Text(
                                  reverse ? card.german : card.english,
                                  textDirection: showingTargetSide && useArabicTargetStyle
                                      ? TextDirection.rtl
                                      : null,
                                  style: _withArabicTargetFallback(
                                    TextStyle(
                                      fontSize: reverse ? 30 : 32,
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                      letterSpacing: -0.3,
                                    ),
                                    enable: showingTargetSide && useArabicTargetStyle,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                child: _InfoIconButton(
                                  hasData: card.wordInfo.hasData,
                                  loading: infoLoading,
                                  onTap: onInfoTap,
                                ),
                              ),
                            ],
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
                    // Word Info Display
                    if (card.wordInfo.hasData ||
                        (reverse && card.exampleEn.isNotEmpty) ||
                        (!reverse && card.exampleDe.isNotEmpty) ||
                        card.notes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _WordInfoBlock(
                        wordInfo: card.wordInfo,
                        de: reverse ? card.exampleEn : card.exampleDe,
                        en: reverse ? card.exampleDe : card.exampleEn,
                        notes: card.notes,
                      ),
                    ],
                    if (showSpeakTarget) ...[
                      const SizedBox(height: 16),
                      _SpeakTargetButton(onTap: onSpeakTarget),
                    ],
                  ],
                ),
                if ((deckName ?? '').trim().isNotEmpty && reverse)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _DeckNameBadge(deckName: deckName!.trim()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

TextStyle _withArabicTargetFallback(TextStyle base, {required bool enable}) {
  if (!enable) return base;
  return base.copyWith(
    fontFamilyFallback: const [
      'Noto Naskh Arabic',
      'Noto Sans Arabic',
      'Droid Arabic Naskh',
      'Geeza Pro',
      'Tahoma',
      'Arial',
    ],
    height: (base.height ?? 1.2) * 1.15,
  );
}

class _DeckNameBadge extends StatelessWidget {
  final String deckName;
  const _DeckNameBadge({required this.deckName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Text(
        deckName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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

class _SpeakTargetButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SpeakTargetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: const Icon(Icons.volume_up_rounded),
      label: const Text('Listen'),
    );
  }
}

class _InfoIconButton extends StatelessWidget {
  final bool hasData;
  final bool loading;
  final VoidCallback? onTap;

  const _InfoIconButton({
    required this.hasData,
    required this.loading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: hasData ? 'Refresh word info' : 'Fetch word info',
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasData
                ? colorScheme.primary.withValues(alpha: 0.16)
                : colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    hasData ? Icons.info : Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}

class _WordInfoBlock extends StatelessWidget {
  final WordInfo wordInfo;
  final String de;
  final String en;
  final String notes;

  const _WordInfoBlock({
    required this.wordInfo,
    this.de = '',
    this.en = '',
    this.notes = '',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Definition
          if (wordInfo.definition.isNotEmpty) ...[
            Text(
              'Definition',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              wordInfo.definition,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ],
          
          // Synonyms
          if (wordInfo.synonyms.isNotEmpty) ...[
            if (wordInfo.definition.isNotEmpty) const SizedBox(height: 12),
            Text(
              'Synonyms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: wordInfo.synonyms.map((syn) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    syn,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Antonyms
          if (wordInfo.antonyms.isNotEmpty) ...[
            if (wordInfo.definition.isNotEmpty || wordInfo.synonyms.isNotEmpty)
              const SizedBox(height: 12),
            Text(
              'Antonyms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: wordInfo.antonyms.map((ant) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    ant,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Examples
          if (de.isNotEmpty) ...[
            if (wordInfo.definition.isNotEmpty ||
                wordInfo.synonyms.isNotEmpty ||
                wordInfo.antonyms.isNotEmpty)
              const SizedBox(height: 12),
            Text(
              'Example',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              de,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontStyle: FontStyle.italic,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            if (en.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                en,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ],

          // Notes (legacy examples may be stored here)
          if (notes.isNotEmpty) ...[
            if (wordInfo.definition.isNotEmpty ||
                wordInfo.synonyms.isNotEmpty ||
                wordInfo.antonyms.isNotEmpty ||
                de.isNotEmpty)
              const SizedBox(height: 12),
            Text(
              'Example',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notes,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
