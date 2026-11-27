import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment_method.dart';
import '../models/wallet.dart';
import 'mock_data.dart';

class WalletState {
  final Wallet wallet;
  final List<WalletTransaction> transactions;
  final List<PaymentMethod> paymentMethods;
  final bool isLoading;

  const WalletState({
    required this.wallet,
    required this.transactions,
    required this.paymentMethods,
    this.isLoading = false,
  });

  WalletState copyWith({
    Wallet? wallet,
    List<WalletTransaction>? transactions,
    List<PaymentMethod>? paymentMethods,
    bool? isLoading,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WalletRepository extends StateNotifier<WalletState> {
  WalletRepository()
      : super(WalletState(
          wallet: MockData.wallet,
          transactions: MockData.transactions,
          paymentMethods: List.from(MockData.paymentMethods),
        ));

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(
      isLoading: false,
      wallet: MockData.wallet,
      transactions: MockData.transactions,
    );
  }

  Future<bool> withdraw(double amount) async {
    if (amount <= 0 || amount > state.wallet.availableBalance) return false;
    await Future.delayed(const Duration(milliseconds: 800));
    final tx = WalletTransaction(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      title: 'Withdrawal',
      description: 'To ${state.paymentMethods.firstWhere((p) => p.isPrimary, orElse: () => state.paymentMethods.first).displayName}',
      date: DateTime.now(),
      amount: amount,
      type: TransactionType.withdrawal,
      status: TransactionStatus.processing,
      paymentMethod: 'Bank Transfer',
      settlementDate: DateTime.now().add(const Duration(days: 2)),
    );
    final w = state.wallet;
    state = state.copyWith(
      wallet: Wallet(
        availableBalance: w.availableBalance - amount,
        pendingBalance: w.pendingBalance,
        totalEarnings: w.totalEarnings,
        thisMonthEarnings: w.thisMonthEarnings,
        monthGrowthPercent: w.monthGrowthPercent,
      ),
      transactions: [tx, ...state.transactions],
    );
    return true;
  }

  Future<void> addPaymentMethod(PaymentMethod method) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var methods = [...state.paymentMethods];
    if (method.isPrimary) {
      methods = methods.map((m) => m.copyWith(isPrimary: false)).toList();
    }
    methods = [...methods, method];
    state = state.copyWith(paymentMethods: methods);
  }

  Future<void> setPrimary(String id) async {
    state = state.copyWith(
      paymentMethods: state.paymentMethods
          .map((m) => m.copyWith(isPrimary: m.id == id))
          .toList(),
    );
  }

  Future<void> deletePaymentMethod(String id) async {
    state = state.copyWith(
      paymentMethods: state.paymentMethods.where((m) => m.id != id).toList(),
    );
  }

  WalletTransaction? transactionById(String id) {
    try {
      return state.transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }
}

final walletRepositoryProvider =
    StateNotifierProvider<WalletRepository, WalletState>((ref) {
  return WalletRepository();
});
