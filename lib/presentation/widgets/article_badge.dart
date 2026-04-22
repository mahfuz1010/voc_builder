import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/article.dart';

class ArticleBadge extends StatelessWidget {
  final Article article;
  final double fontSize;

  const ArticleBadge({super.key, required this.article, this.fontSize = 13});

  @override
  Widget build(BuildContext context) {
    if (article == Article.none) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.articleColor(article).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.articleColor(article), width: 1),
      ),
      child: Text(
        article.displayLabel,
        style: TextStyle(
          color: AppColors.articleColor(article),
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
