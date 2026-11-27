import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../constants/app_constants.dart';

class GanagasevaLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;
  final bool showTagline;
  final Color? textColor;

  const GanagasevaLogo({
    super.key,
    this.size = 72,
    this.showWordmark = true,
    this.showTagline = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? AppColors.textPrimary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.sacredGold.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.brightness_1_outlined,
                size: size * 0.85,
                color: AppColors.white.withValues(alpha: 0.15),
              ),
              Text(
                'ॐ',
                style: TextStyle(
                  fontSize: size * 0.42,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              Positioned(
                bottom: size * 0.16,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: size * 0.18,
                  color: AppColors.warmCream.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 12),
          Text(
            AppConstants.appName,
            style: AppTypography.brand(fontSize: size * 0.36, color: color),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            AppConstants.tagline,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.sacredGold,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

class GanagasevaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final Widget? leading;

  const GanagasevaAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBack = true,
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: showBack,
      leading: leading,
      title: Text(title),
      actions: actions,
    );
  }
}
