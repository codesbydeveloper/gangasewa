import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_card.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      ('How do I accept a booking?', 'Open Bookings → select a pending request → tap Accept.'),
      ('Can I record without internet?', 'Yes. Recordings save locally and can be uploaded when you are online.'),
      ('When will withdrawals settle?', 'Usually within 1–2 business days to your primary bank account.'),
      ('How do devotees get videos?', 'After upload completes, authorized devotees can view the private recording.'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GanagasevaCard(
            gradient: AppColors.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need assistance, Pandit Ji?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Call +91 1800-000-SEVA or email support@ganagaseva.in',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.warmCream),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('FAQs', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...faqs.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GanagasevaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.$1, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(f.$2, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('Terms & Conditions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          const GanagasevaCard(
            child: Text(
              'By using Ganagaseva, Pandits agree to deliver seva with authenticity, protect devotee privacy, and use recordings only for the associated booking. Full terms are available on ganagaseva.in/terms.',
            ),
          ),
        ],
      ),
    );
  }
}
