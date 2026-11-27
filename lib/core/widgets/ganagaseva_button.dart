import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class GanagasevaButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expanded;
  final IconData? icon;
  final bool useGradient;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const GanagasevaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.expanded = true,
    this.icon,
    this.useGradient = true,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<GanagasevaButton> createState() => _GanagasevaButtonState();
}

class _GanagasevaButtonState extends State<GanagasevaButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;
    final child = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: Container(
        height: AppSpacing.touchTarget + 4,
        decoration: BoxDecoration(
          gradient: enabled && widget.useGradient && widget.backgroundColor == null
              ? AppColors.primaryGradient
              : null,
          color: !enabled
              ? AppColors.borderStrong
              : widget.backgroundColor ??
                  (widget.useGradient ? null : AppColors.primary),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          boxShadow: enabled ? AppShadows.soft : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed?.call();
                  }
                : null,
            onTapDown: enabled ? (_) => setState(() => _scale = 0.97) : null,
            onTapUp: enabled ? (_) => setState(() => _scale = 1) : null,
            onTapCancel: enabled ? () => setState(() => _scale = 1) : null,
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.foregroundColor ?? AppColors.white, size: 22),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: widget.foregroundColor ?? AppColors.white,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return widget.expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class GanagasevaOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final Color? color;

  const GanagasevaOutlinedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final btn = OutlinedButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      style: OutlinedButton.styleFrom(
        foregroundColor: c,
        side: BorderSide(color: c, width: 1.5),
        minimumSize: const Size(48, 52),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
