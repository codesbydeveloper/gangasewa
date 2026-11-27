import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';

class UploadSuccessScreen extends StatelessWidget {
  final String videoId;
  const UploadSuccessScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
              ).animate().scale(curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text('Upload Complete', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 10),
              Text(
                'Your private puja recording is ready for the devotee.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              GanagasevaButton(
                label: 'View Video',
                onPressed: () => context.go('/videos/$videoId'),
              ),
              const SizedBox(height: 12),
              GanagasevaOutlinedButton(
                label: 'Back to Home',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
