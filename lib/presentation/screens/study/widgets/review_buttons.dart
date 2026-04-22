import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/review_rating.dart';

class ReviewButtons extends StatefulWidget {
  final void Function(ReviewRating) onRating;

  const ReviewButtons({super.key, required this.onRating});

  @override
  State<ReviewButtons> createState() => _ReviewButtonsState();
}

class _ReviewButtonsState extends State<ReviewButtons> with SingleTickerProviderStateMixin {
  int? _hoveredIndex;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      child: Column(
        children: [
          // Hint text with animation
          AnimatedOpacity(
            opacity: 0.7,
            duration: const Duration(milliseconds: 300),
            child: Text(
              'Swipe or tap buttons • Drag to edit',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RatingButton(
                label: 'Again',
                sublabel: 'Swipe Left',
                color: AppColors.againColor,
                icon: Icons.refresh_rounded,
                onTap: () => widget.onRating(ReviewRating.again),
                isHovered: _hoveredIndex == 0,
                onHover: (hovered) => setState(() => _hoveredIndex = hovered ? 0 : null),
              ),
              const SizedBox(width: 8),
              _RatingButton(
                label: 'Good',
                sublabel: 'Swipe Right',
                color: AppColors.goodColor,
                icon: Icons.done_all_rounded,
                onTap: () => widget.onRating(ReviewRating.good),
                isHovered: _hoveredIndex == 1,
                onHover: (hovered) => setState(() => _hoveredIndex = hovered ? 1 : null),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final bool isHovered;
  final Function(bool) onHover;

  const _RatingButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.isHovered,
    required this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => onHover(true),
        onExit: (_) => onHover(false),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: isHovered ? 72 : 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: isHovered ? 0.18 : 0.14),
                  color.withValues(alpha: isHovered ? 0.12 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: isHovered ? 0.6 : 0.4),
                width: isHovered ? 2.0 : 1.5,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: color.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isHovered ? 1.15 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(icon, color: color, size: isHovered ? 24 : 22),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                if (isHovered) ...[
                  const SizedBox(height: 2),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
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
