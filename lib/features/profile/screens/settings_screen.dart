import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_card.dart';

final languageProvider = StateProvider<String>((ref) => 'English');
final offlineBannerProvider = StateProvider<bool>((ref) => false);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final offline = ref.watch(offlineBannerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          const GanagasevaCard(
            child: Row(
              children: [
                Icon(Icons.light_mode_outlined, color: AppColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Light theme is used across the app for clarity and readability.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GanagasevaCard(
            child: Column(
              children: [
                for (final lang in ['English', 'Hindi', 'Gujarati'])
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      language == lang
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: language == lang ? AppColors.primary : AppColors.textMuted,
                    ),
                    title: Text(lang),
                    onTap: () => ref.read(languageProvider.notifier).state = lang,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Connectivity (Demo)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('Simulate offline mode'),
            subtitle: const Text('Shows offline banner across the app'),
            value: offline,
            activeThumbColor: AppColors.primary,
            onChanged: (v) => ref.read(offlineBannerProvider.notifier).state = v,
          ),
          const SizedBox(height: 20),
          Text('Privacy & Security', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          const GanagasevaCard(
            child: Text(
              'Banking details are masked. Session tokens are stored using secure storage. Video recordings remain private to authorized users.',
            ),
          ),
        ],
      ),
    );
  }
}
