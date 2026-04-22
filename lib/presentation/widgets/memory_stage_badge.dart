import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/enums/memory_stage.dart';

class MemoryStageBadge extends StatelessWidget {
  final MemoryStage stage;

  const MemoryStageBadge({super.key, required this.stage});

  Color get _color {
    switch (stage) {
      case MemoryStage.newCard:
        return AppColors.newStageColor;
      case MemoryStage.shortTerm:
        return AppColors.shortTermStageColor;
      case MemoryStage.longTerm:
        return AppColors.longTermStageColor;
    }
  }

  Color get _textColor {
    if (stage == MemoryStage.shortTerm) {
      return Colors.grey.shade800;
    }
    return _color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color, width: 1),
      ),
      child: Text(
        stage.label,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
