import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_logo.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.warmCream,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.85,
                    colors: [
                      AppColors.sacredGold.withValues(alpha: 0.22),
                      AppColors.warmCream.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GanagasevaLogo(size: 96, showTagline: true)
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
                  const SizedBox(height: 28),
                  Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.primary.withValues(alpha: 0.85),
                    size: 28,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.15, 1.15),
                        duration: 900.ms,
                      )
                      .fade(begin: 0.7, end: 1),
                  const SizedBox(height: 40),
                  Text(
                    AppConstants.tagline,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.darkBrown,
                          letterSpacing: 1.5,
                        ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
