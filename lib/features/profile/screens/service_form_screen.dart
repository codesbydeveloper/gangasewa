import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../models/puja_service.dart';
import '../../../services/service_repository.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final String? serviceId;
  const ServiceFormScreen({super.key, this.serviceId});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _category;
  late final TextEditingController _duration;
  late final TextEditingController _price;
  late final TextEditingController _samagri;
  late final TextEditingController _instructions;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    final existing = widget.serviceId == null
        ? null
        : ref.read(serviceRepositoryProvider.notifier).byId(widget.serviceId!);
    _name = TextEditingController(text: existing?.name ?? '');
    _description = TextEditingController(text: existing?.description ?? '');
    _category = TextEditingController(text: existing?.category ?? 'Puja');
    _duration = TextEditingController(text: existing?.duration.inMinutes.toString() ?? '60');
    _price = TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '');
    _samagri = TextEditingController(text: existing?.requiredSamagri.join(', ') ?? '');
    _instructions = TextEditingController(text: existing?.instructions ?? '');
    _active = existing?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _category.dispose();
    _duration.dispose();
    _price.dispose();
    _samagri.dispose();
    _instructions.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.serviceId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Service' : 'Add Service')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name *'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description *'),
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _duration,
              decoration: const InputDecoration(labelText: 'Duration (minutes) *'),
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(labelText: 'Price (₹) *', prefixText: '₹ '),
              keyboardType: TextInputType.number,
              validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter price' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _samagri,
              decoration: const InputDecoration(labelText: 'Required Samagri', hintText: 'Comma separated'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _instructions,
              decoration: const InputDecoration(labelText: 'Instructions'),
              maxLines: 3,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 20),
            GanagasevaButton(
              label: isEdit ? 'Save Changes' : 'Add Service',
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                final service = PujaService(
                  id: widget.serviceId ?? const Uuid().v4(),
                  name: _name.text.trim(),
                  description: _description.text.trim(),
                  category: _category.text.trim(),
                  duration: Duration(minutes: int.tryParse(_duration.text) ?? 60),
                  price: double.tryParse(_price.text) ?? 0,
                  requiredSamagri: _samagri.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  instructions: _instructions.text.trim().isEmpty ? null : _instructions.text.trim(),
                  isActive: _active,
                );
                await ref.read(serviceRepositoryProvider.notifier).upsert(service);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Service updated' : 'Service added')),
                  );
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
