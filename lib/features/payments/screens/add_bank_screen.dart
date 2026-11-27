import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../models/payment_method.dart';
import '../../../services/wallet_repository.dart';

class AddBankScreen extends ConsumerStatefulWidget {
  const AddBankScreen({super.key});

  @override
  ConsumerState<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends ConsumerState<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _holder = TextEditingController();
  final _account = TextEditingController();
  final _confirm = TextEditingController();
  final _ifsc = TextEditingController();
  final _bank = TextEditingController();
  final _branch = TextEditingController();
  bool _primary = true;
  bool _loading = false;

  @override
  void dispose() {
    _holder.dispose();
    _account.dispose();
    _confirm.dispose();
    _ifsc.dispose();
    _bank.dispose();
    _branch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bank Account')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Your account details are stored securely and shown masked.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _holder,
              decoration: const InputDecoration(labelText: 'Account Holder Name *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _account,
              decoration: const InputDecoration(labelText: 'Account Number *'),
              keyboardType: TextInputType.number,
              obscureText: true,
              validator: (v) => v == null || v.length < 8 ? 'Enter valid account number' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              decoration: const InputDecoration(labelText: 'Confirm Account Number *'),
              keyboardType: TextInputType.number,
              validator: (v) => v != _account.text ? 'Account numbers do not match' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ifsc,
              decoration: const InputDecoration(labelText: 'IFSC *'),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => v == null || v.length < 11 ? 'Enter valid IFSC' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bank,
              decoration: const InputDecoration(labelText: 'Bank Name *'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _branch,
              decoration: const InputDecoration(labelText: 'Branch'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Set as primary payout account'),
              value: _primary,
              onChanged: (v) => setState(() => _primary = v),
            ),
            const SizedBox(height: 24),
            GanagasevaButton(
              label: 'Save Bank Account',
              isLoading: _loading,
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;
                setState(() => _loading = true);
                await ref.read(walletRepositoryProvider.notifier).addPaymentMethod(
                      PaymentMethod(
                        id: const Uuid().v4(),
                        type: PaymentMethodType.bankAccount,
                        displayName: _bank.text.trim(),
                        maskedDetail: Formatters.maskAccount(_account.text.trim()),
                        isPrimary: _primary,
                        accountHolder: _holder.text.trim(),
                        bankName: _bank.text.trim(),
                        ifsc: _ifsc.text.trim().toUpperCase(),
                        branch: _branch.text.trim(),
                      ),
                    );
                setState(() => _loading = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bank account added')),
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
