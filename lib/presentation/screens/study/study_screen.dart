import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/enums/review_rating.dart';
import '../../../domain/entities/flashcard.dart';
import '../../providers/card_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/settings_provider.dart';
import 'widgets/flashcard_view.dart';
import 'widgets/review_buttons.dart';

class StudyScreen extends ConsumerStatefulWidget {
  final String? deckId;
  const StudyScreen({super.key, this.deckId});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen>
  with SingleTickerProviderStateMixin {
  static const int _maxDuePerSession = 500;
  static const double _swipeThreshold = 80; // pixels

  int _currentIndex = 0;
  bool _isFlipped = false;
  List<Flashcard> _queue = [];
  List<Flashcard> _baseSessionCards = [];
  bool _sessionDone = false;
  bool _bidirectionalEnabled = true;
  bool _reverseDirection = false;
  double _dragX = 0;
  double _dragY = 0;
  late final AnimationController _swipeAwayController;
  double _swipeStartX = 0;
  double _swipeStartY = 0;
  double _swipeTargetX = 0;
  double _swipeTargetY = 0;
  bool _isSwipeAnimating = false;

  @override
  void initState() {
    super.initState();
    _swipeAwayController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _loadQueue();
  }

  @override
  void dispose() {
    _swipeAwayController.dispose();
    super.dispose();
  }

  Future<void> _loadQueue() async {
    final repo = ref.read(cardRepositoryProvider);
    final settings = await ref.read(settingsProvider.future);
    final configuredLimit = settings.dailyNewLimit;
    final sessionLimit = configuredLimit.clamp(1, _maxDuePerSession);
    final due = await repo.getDueCards(deckId: widget.deckId);
    if (mounted) {
      setState(() {
        _bidirectionalEnabled = settings.bidirectionalStudy;
        final shuffled = [...due]..shuffle();
        _baseSessionCards = shuffled.take(sessionLimit).toList();
        _queue = [..._baseSessionCards];
        _currentIndex = 0;
        _isFlipped = false;
        _reverseDirection = false;
        _sessionDone = false;
      });
    }
  }

  void _restartSession() {
    if (_queue.isEmpty) {
      _loadQueue();
      return;
    }
    setState(() {
      _currentIndex = 0;
      _isFlipped = false;
      _reverseDirection = false;
      _sessionDone = false;
      final shuffled = [..._baseSessionCards]..shuffle();
      _baseSessionCards = [...shuffled];
      _queue = [...shuffled];
    });
  }

  Future<void> _submitRating(ReviewRating rating) async {
    if (_queue.isEmpty) return;
    final card = _queue[_currentIndex];
    await ref.read(reviewNotifierProvider.notifier).submitReview(card.id, rating);
    await ref.read(settingsProvider.notifier).recordStudySession();

    setState(() {
      if (rating == ReviewRating.again) {
        // Keep failed cards in-session by re-queuing them at the end.
        _queue.add(card);
      }
      _currentIndex++;
      _isFlipped = false;
      if (_currentIndex >= _queue.length) {
        if (!_reverseDirection && _bidirectionalEnabled) {
          // After finishing German -> English, run English -> German.
          _reverseDirection = true;
          _currentIndex = 0;
          _queue = [..._baseSessionCards]..shuffle();
        } else {
          _sessionDone = true;
        }
      }
    });
  }

  Future<void> _deleteCard() async {
    if (_queue.isEmpty) return;
    final card = _queue[_currentIndex];
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text('"${card.german}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(cardRepositoryProvider).delete(card.id);
      setState(() {
        _baseSessionCards.removeWhere((c) => c.id == card.id);
        _queue.removeAt(_currentIndex);
        _isFlipped = false;
        if (_currentIndex >= _queue.length && _queue.isNotEmpty) {
          _currentIndex = _queue.length - 1;
        }
        if (_queue.isEmpty) {
          _sessionDone = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted')),
        );
      }
    }
  }

  Future<void> _moveCardToDeck() async {
    if (_queue.isEmpty) return;
    final card = _queue[_currentIndex];
    final deckRepo = ref.read(deckRepositoryProvider);
    
    final decks = await deckRepo.getAll();
    final currentDeckId = widget.deckId;
    final otherDecks = decks.where((d) => d.id != currentDeckId).toList();

    if (!mounted) return;
    
    if (otherDecks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No other decks available')),
      );
      return;
    }

    final selectedDeck = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Move to Deck'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: otherDecks.length,
            itemBuilder: (_, idx) => ListTile(
              title: Text(otherDecks[idx].name),
              onTap: () => Navigator.pop(ctx, otherDecks[idx].id),
            ),
          ),
        ),
      ),
    );

    if (selectedDeck != null && mounted) {
      await ref.read(cardRepositoryProvider).moveToDeck(card.id, selectedDeck);
      setState(() {
        _baseSessionCards.removeWhere((c) => c.id == card.id);
        _queue.removeAt(_currentIndex);
        _isFlipped = false;
        if (_currentIndex >= _queue.length && _queue.isNotEmpty) {
          _currentIndex = _queue.length - 1;
        }
        if (_queue.isEmpty) {
          _sessionDone = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Card moved to ${otherDecks.firstWhere((d) => d.id == selectedDeck).name}')),
        );
      }
    }
  }

  void _flip() => setState(() => _isFlipped = !_isFlipped);

  Future<void> _editCard() async {
    if (_queue.isEmpty) return;
    final original = _queue[_currentIndex];
    await context.push('/edit-card', extra: original);
    if (!mounted) return;

    await _refreshEditedCard(original.id);
  }

  Future<void> _refreshEditedCard(String cardId) async {
    final refreshed = await ref.read(cardRepositoryProvider).getById(cardId);
    if (!mounted) return;

    // Card was deleted or moved out of this deck while editing.
    if (refreshed == null ||
        (widget.deckId != null && refreshed.deckId != widget.deckId)) {
      setState(() {
        _baseSessionCards.removeWhere((c) => c.id == cardId);
        _queue.removeWhere((c) => c.id == cardId);
        _isFlipped = false;

        if (_queue.isEmpty) {
          _currentIndex = 0;
          _sessionDone = true;
        } else if (_currentIndex >= _queue.length) {
          _currentIndex = _queue.length - 1;
        }
      });
      return;
    }

    setState(() {
      for (var i = 0; i < _baseSessionCards.length; i++) {
        if (_baseSessionCards[i].id == cardId) {
          _baseSessionCards[i] = refreshed;
        }
      }
      for (var i = 0; i < _queue.length; i++) {
        if (_queue[i].id == cardId) {
          _queue[i] = refreshed;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_sessionDone) return _buildDoneScreen();
    if (_queue.isEmpty) return _buildEmptyScreen();

    final card = _queue[_currentIndex];
    final nextCard = _currentIndex + 1 < _queue.length ? _queue[_currentIndex + 1] : null;
    final thirdCard = _currentIndex + 2 < _queue.length ? _queue[_currentIndex + 2] : null;
    final progress = (_currentIndex + 1) / _queue.length;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.library_books_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Learning Session',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${_currentIndex + 1} / ${_queue.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary.withValues(alpha: 0.8),
              ),
              minHeight: 6,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (_isSwipeAnimating) return;
          setState(() {
            _dragX = details.globalPosition.dx - (MediaQuery.of(context).size.width / 2);
            _dragY = 0; // Reset vertical when horizontal dragging
          });
        },
        onVerticalDragUpdate: (details) {
          if (_isSwipeAnimating) return;
          setState(() {
            _dragY = details.globalPosition.dy - (MediaQuery.of(context).size.height / 2);
            _dragX = 0; // Reset horizontal when vertical dragging
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragX.abs() > _swipeThreshold) {
            if (_dragX < 0) {
              // Swiped left = wrong/again
              _animateAndSubmit(ReviewRating.again);
            } else {
              // Swiped right = correct/good
              _animateAndSubmit(ReviewRating.good);
            }
          } else if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100) {
            if (details.primaryVelocity! < 0) {
              _animateAndSubmit(ReviewRating.again);
            } else {
              _animateAndSubmit(ReviewRating.good);
            }
          }
          setState(() {
            _dragX = 0;
          });
        },
        onVerticalDragEnd: (details) {
          if (_dragY.abs() > _swipeThreshold) {
            if (_dragY < 0) {
              // Swiped up = move to another deck
              _moveCardToDeck();
            } else {
              // Swiped down = delete
              _deleteCard();
            }
          } else if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 100) {
            if (details.primaryVelocity! < 0) {
              _moveCardToDeck();
            } else {
              _deleteCard();
            }
          }
          setState(() {
            _dragY = 0;
          });
        },
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                    // Third card preview (deep stack layer)
                    if (thirdCard != null)
                      Positioned.fill(
                        child: _buildSecondaryPreviewCard(context, thirdCard),
                      ),
                  // Next card preview (scaled and behind)
                  if (nextCard != null)
                    Positioned.fill(
                      child: _buildPreviewCard(context, nextCard),
                    ),
                  // Current card with animation
                  Positioned.fill(
                    child: _buildAnimatedCard(context, card),
                  ),
                ],
              ),
            ),
            if (_isFlipped)
              ReviewButtons(onRating: _animateAndSubmit)
            else
              _buildFlipHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(BuildContext context, Flashcard card) {
    final screenWidth = MediaQuery.of(context).size.width;
    final animatedX = _animatedDragX(context);
    final animatedY = _animatedDragY(context);

    // Calculate rotation based on drag
    final rotation = (animatedX / screenWidth) * 0.3; // Max 0.3 radians

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Transform.translate(
        offset: Offset(animatedX, animatedY),
        child: Transform.rotate(
          angle: rotation,
          alignment: Alignment.center,
          child: Stack(
            children: [
              FlashcardView(
                card: card,
                isFlipped: _isFlipped,
                isReversed: _reverseDirection,
                onTap: _flip,
                onEdit: _editCard,
              ),
              _buildDragWashOverlay(animatedX),
              // Edit button overlay
              if (!_isFlipped)
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _editCard,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit_rounded,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, Flashcard nextCard) {
    final progress = _stackProgress();
    final scale = lerpDouble(0.9, 0.985, progress)!;
    final opacity = lerpDouble(0.5, 0.9, progress)!;
    final offsetY = lerpDouble(26, 6, progress)!;

    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: FlashcardView(
            card: nextCard,
            isFlipped: false,
            isReversed: _reverseDirection,
            isPreview: true,
            onTap: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryPreviewCard(BuildContext context, Flashcard thirdCard) {
    final progress = _stackProgress();
    final scale = lerpDouble(0.84, 0.94, progress)!;
    final opacity = lerpDouble(0.22, 0.45, progress)!;
    final offsetY = lerpDouble(42, 18, progress)!;

    return Transform.translate(
      offset: Offset(0, offsetY),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: FlashcardView(
            card: thirdCard,
            isFlipped: false,
            isReversed: _reverseDirection,
            isPreview: true,
            onTap: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildDragWashOverlay(double animatedX) {
    final washAmount = (animatedX.abs() / 170).clamp(0.0, 1.0);
    if (washAmount < 0.04) return const SizedBox.shrink();

    final base = animatedX < 0
        ? const Color(0xFFE74C3C) // left drag: wrong
        : const Color(0xFF2ECC71); // right drag: correct

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: animatedX < 0
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    base.withValues(alpha: 0.34 * washAmount),
                    base.withValues(alpha: 0.12 * washAmount),
                    Colors.transparent,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.transparent,
                    base.withValues(alpha: 0.12 * washAmount),
                    base.withValues(alpha: 0.34 * washAmount),
                  ],
                ),
        ),
      ),
    );
  }

  double _animatedDragX(BuildContext context) {
    if (!_isSwipeAnimating) return _dragX;
    return lerpDouble(
      _swipeStartX,
      _swipeTargetX,
      Curves.easeOutCubic.transform(_swipeAwayController.value),
    )!;
  }

  double _animatedDragY(BuildContext context) {
    if (!_isSwipeAnimating) return _dragY;
    return lerpDouble(
      _swipeStartY,
      _swipeTargetY,
      Curves.easeOutCubic.transform(_swipeAwayController.value),
    )!;
  }

  double _stackProgress() {
    final distance = _isSwipeAnimating
        ? (_swipeAwayController.value * 180)
        : (_dragX.abs() + _dragY.abs());
    return (distance / 140).clamp(0.0, 1.0);
  }

  void _animateAndSubmit(ReviewRating rating) {
    if (_isSwipeAnimating) return;
    final direction = rating == ReviewRating.again ? -1.0 : 1.0;
    _swipeStartX = _dragX;
    _swipeStartY = _dragY;
    _swipeTargetX = direction * 420;
    _swipeTargetY = _dragY * 0.2;
    _isSwipeAnimating = true;
    _swipeAwayController
      ..reset()
      ..forward().whenComplete(() async {
        await _submitRating(rating);
        if (!mounted) return;
        setState(() {
          _dragX = 0;
          _dragY = 0;
          _swipeStartX = 0;
          _swipeStartY = 0;
          _swipeTargetX = 0;
          _swipeTargetY = 0;
          _isSwipeAnimating = false;
        });
        _swipeAwayController.reset();
      });
  }

  Widget _buildFlipHint() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap to reveal',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _bidirectionalEnabled
                ? (_reverseDirection ? '🔄 English → German' : '🔤 German → English')
                : '🔤 German → English',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navStudy)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.longTermStageColor, size: 72),
              const SizedBox(height: 16),
              const Text(
                AppStrings.noCardsDue,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneScreen() {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navStudy)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration,
                  color: AppColors.primary, size: 72),
              const SizedBox(height: 16),
              const Text(
                AppStrings.studyDone,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Reviewed $_currentIndex cards',
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _restartSession,
                icon: const Icon(Icons.refresh),
                label: const Text('Study Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
