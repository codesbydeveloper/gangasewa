import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../services/service_repository.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(serviceRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Services'),
        actions: [
          IconButton(
            onPressed: () => context.push('/services/form'),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: services.isEmpty
          ? EmptyState(
              icon: Icons.local_fire_department_outlined,
              title: 'No services yet',
              message: 'Add the puja services you offer to devotees.',
              actionLabel: 'Add Service',
              onAction: () => context.push('/services/form'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: services.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final s = services[i];
                return GanagasevaCard(
                  onTap: () => context.push('/services/form', extra: s.id),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.softBeige,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.local_fire_department_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              '${s.duration.inMinutes} mins • ${Formatters.currency(s.price)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.isActive ? 'Active' : 'Inactive',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: s.isActive ? AppColors.success : AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: s.isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (_) =>
                            ref.read(serviceRepositoryProvider.notifier).toggle(s.id),
                      ),
                      IconButton(
                        onPressed: () async {
                          final ok = await ConfirmDialog.show(
                            context,
                            title: 'Delete service?',
                            message: 'Remove ${s.name} from your offerings?',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                          );
                          if (ok == true) {
                            await ref.read(serviceRepositoryProvider.notifier).delete(s.id);
                          }
                        },
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
