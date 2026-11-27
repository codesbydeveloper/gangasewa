import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/formatters.dart';

class AmountText extends StatelessWidget {
  final num amount;
  final double fontSize;
  final Color? color;
  final bool decimals;
  final FontWeight weight;
  final bool animate;

  const AmountText({
    super.key,
    required this.amount,
    this.fontSize = 28,
    this.color,
    this.decimals = false,
    this.weight = FontWeight.w800,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.amount(
      fontSize: fontSize,
      weight: weight,
      color: color ??
          (Theme.of(context).brightness == Brightness.dark
              ? AppColors.textOnDark
              : AppColors.textPrimary),
    );

    if (!animate) {
      return Text(Formatters.currency(amount, decimals: decimals), style: style);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, value, _) => Text(
        Formatters.currency(value, decimals: decimals),
        style: style,
      ),
    );
  }
}
