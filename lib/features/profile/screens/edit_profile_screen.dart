import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../services/auth_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _specialization;
  late final TextEditingController _location;
  late final TextEditingController _temple;
  late final TextEditingController _bio;
  late final TextEditingController _languages;

  @override
  void initState() {
    super.initState();
    final p = ref.read(authRepositoryProvider).pandit;
    _name = TextEditingController(text: p?.name ?? '');
    _email = TextEditingController(text: p?.email ?? '');
    _specialization = TextEditingController(text: p?.specialization ?? '');
    _location = TextEditingController(text: p?.location ?? '');
    _temple = TextEditingController(text: p?.templeAffiliation ?? '');
    _bio = TextEditingController(text: p?.biography ?? '');
    _languages = TextEditingController(text: p?.languages.join(', ') ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _specialization.dispose();
    _location.dispose();
    _temple.dispose();
    _bio.dispose();
    _languages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pandit = ref.watch(authRepositoryProvider).pandit;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: ProfileAvatar(name: pandit?.name ?? 'P', size: 80, showVerified: pandit?.isVerified ?? false)),
          const SizedBox(height: 20),
          Text('Personal Information', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name')),
          const SizedBox(height: 12),
          TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 20),
          Text('Professional Information', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextField(controller: _specialization, decoration: const InputDecoration(labelText: 'Vedic Specialization')),
          const SizedBox(height: 12),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 12),
          TextField(controller: _temple, decoration: const InputDecoration(labelText: 'Temple Affiliation')),
          const SizedBox(height: 12),
          TextField(controller: _languages, decoration: const InputDecoration(labelText: 'Languages')),
          const SizedBox(height: 12),
          TextField(controller: _bio, decoration: const InputDecoration(labelText: 'Biography'), maxLines: 4),
          const SizedBox(height: 28),
          GanagasevaButton(
            label: 'Save Profile',
            onPressed: () async {
              final current = ref.read(authRepositoryProvider).pandit;
              if (current == null) return;
              await ref.read(authRepositoryProvider.notifier).completeProfileSetup(
                    current.copyWith(
                      name: _name.text.trim(),
                      email: _email.text.trim(),
                      specialization: _specialization.text.trim(),
                      location: _location.text.trim(),
                      templeAffiliation: _temple.text.trim(),
                      biography: _bio.text.trim(),
                      languages: _languages.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      isVerified: current.isVerified,
                      verificationStatus: current.verificationStatus,
                    ),
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
