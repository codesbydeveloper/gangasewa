class Wallet {
  final double availableBalance;
  final double pendingBalance;
  final double totalEarnings;
  final double thisMonthEarnings;
  final double monthGrowthPercent;

  const Wallet({
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarnings,
    required this.thisMonthEarnings,
    this.monthGrowthPercent = 0,
  });

  double get walletBalance => availableBalance + pendingBalance;
}

enum TransactionType { credit, debit, withdrawal, refund }

enum TransactionStatus { pending, completed, failed, processing }

class WalletTransaction {
  final String id;
  final String title;
  final String? description;
  final String? bookingId;
  final DateTime date;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String? paymentMethod;
  final DateTime? settlementDate;

  const WalletTransaction({
    required this.id,
    required this.title,
    this.description,
    this.bookingId,
    required this.date,
    required this.amount,
    required this.type,
    required this.status,
    this.paymentMethod,
    this.settlementDate,
  });

  bool get isCredit =>
      type == TransactionType.credit || type == TransactionType.refund;
}
