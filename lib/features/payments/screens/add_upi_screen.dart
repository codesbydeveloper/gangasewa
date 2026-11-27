import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../models/payment_method.dart';
import '../../../services/wallet_repository.dart';

class AddUpiScreen extends ConsumerStatefulWidget {
  const AddUpiScreen({super.key});

  @override
  ConsumerState<AddUpiScreen> createState() => _AddUpiScreenState();
}

class _AddUpiScreenState extends ConsumerState<AddUpiScreen> {
  final _upi = TextEditingController();
  bool _verified = false;
  bool _loading = false;

  @override
  void dispose() {
    _upi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add UPI')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a UPI ID for faster payouts. It will be shown masked.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _upi,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                hintText: 'name@upi',
              ),
              onChanged: (_) => setState(() => _verified = false),
            ),
            const SizedBox(height: 12),
            GanagasevaOutlinedButton(
              label: _verified ? 'Verified' : 'Verify UPI',
              icon: _verified ? Icons.verified : Icons.fact_check_outlined,
              color: _verified ? AppColors.success : null,
              onPressed: () async {
                if (!_upi.text.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid UPI ID')),
                  );
                  return;
                }
                setState(() => _loading = true);
                await Future.delayed(const Duration(milliseconds: 700));
                setState(() {
                  _loading = false;
                  _verified = true;
                });
              },
            ),
            const Spacer(),
            GanagasevaButton(
              label: 'Save UPI',
              isLoading: _loading,
              onPressed: !_verified
                  ? null
                  : () async {
                      await ref.read(walletRepositoryProvider.notifier).addPaymentMethod(
                            PaymentMethod(
                              id: const Uuid().v4(),
                              type: PaymentMethodType.upi,
                              displayName: 'UPI',
                              maskedDetail: Formatters.maskUpi(_upi.text.trim()),
                              upiId: _upi.text.trim(),
                            ),
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('UPI added')),
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
