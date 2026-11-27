import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkCard
                  : AppColors.white,
            ),
          ),
        ),
        if (onFilter != null) ...[
          const SizedBox(width: 10),
          Material(
            color: AppColors.softBeige,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onFilter,
              borderRadius: BorderRadius.circular(14),
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Icon(Icons.tune_rounded, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onSelected;

  const AppFilterChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected?.call(),
      showCheckmark: false,
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

class DateChip extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback? onTap;

  const DateChip({
    super.key,
    required this.date,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7],
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? AppColors.white : AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              '${date.day}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? AppColors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
