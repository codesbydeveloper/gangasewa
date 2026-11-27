import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../models/pandit.dart';
import '../../../services/auth_repository.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _experience = TextEditingController();
  final _specialization = TextEditingController();
  final _location = TextEditingController();
  final _languages = TextEditingController(text: 'Hindi, Sanskrit');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _experience.dispose();
    _specialization.dispose();
    _location.dispose();
    _languages.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final current = ref.read(authRepositoryProvider).pandit;
    final pandit = Pandit(
      id: current?.id ?? 'p_new',
      name: _name.text.trim(),
      phone: current?.phone ?? '',
      email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      experienceYears: int.tryParse(_experience.text.trim()) ?? 0,
      specialization: _specialization.text.trim(),
      location: _location.text.trim(),
      languages: _languages.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      verificationStatus: VerificationStatus.pending,
      isVerified: false,
    );
    await ref.read(authRepositoryProvider.notifier).completeProfileSetup(pandit);
    if (mounted) context.go('/verification');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pandit Profile Setup')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Tell devotees about your seva',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Complete your profile for verification. This builds trust with devotees.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.softBeige,
                      child: Icon(Icons.person, size: 48, color: AppColors.primary.withValues(alpha: 0.7)),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().length < 3) ? 'Enter your full name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _experience,
                decoration: const InputDecoration(labelText: 'Years of Experience *'),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _specialization,
                decoration: const InputDecoration(labelText: 'Vedic Specialization *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location *'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _languages,
                decoration: const InputDecoration(
                  labelText: 'Languages',
                  hintText: 'Hindi, Sanskrit, English',
                ),
              ),
              const SizedBox(height: 32),
              GanagasevaButton(
                label: 'Submit for Verification',
                isLoading: auth.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
