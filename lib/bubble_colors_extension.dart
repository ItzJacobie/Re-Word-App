import 'package:flutter/material.dart';

@immutable
class BubbleColors extends ThemeExtension<BubbleColors> {
  final Color bubbleColor;
  final Color selectedBubbleColor;
  final Color textColor;

  const BubbleColors({
    required this.bubbleColor,
    required this.selectedBubbleColor,
    required this.textColor,
  });

  @override
  BubbleColors copyWith({
    Color? bubbleColor,
    Color? selectedBubbleColor,
    Color? textColor,
  }) {
    return BubbleColors(
      bubbleColor: bubbleColor ?? this.bubbleColor,
      selectedBubbleColor: selectedBubbleColor ?? this.selectedBubbleColor,
      textColor: textColor ?? this.textColor,
    );
  }

  @override
  BubbleColors lerp(ThemeExtension<BubbleColors>? other, double t) {
    if (other is! BubbleColors) return this;
    return BubbleColors(
      bubbleColor: Color.lerp(bubbleColor, other.bubbleColor, t)!,
      selectedBubbleColor:
          Color.lerp(selectedBubbleColor, other.selectedBubbleColor, t)!,
      textColor: Color.lerp(textColor, other.textColor, t)!,
    );
  }
}
