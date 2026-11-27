enum PaymentMethodType { bankAccount, upi, card, netBanking }

class PaymentMethod {
  final String id;
  final PaymentMethodType type;
  final String displayName;
  final String maskedDetail;
  final bool isPrimary;
  final String? accountHolder;
  final String? bankName;
  final String? ifsc;
  final String? branch;
  final String? upiId;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.displayName,
    required this.maskedDetail,
    this.isPrimary = false,
    this.accountHolder,
    this.bankName,
    this.ifsc,
    this.branch,
    this.upiId,
  });

  PaymentMethod copyWith({
    String? id,
    PaymentMethodType? type,
    String? displayName,
    String? maskedDetail,
    bool? isPrimary,
    String? accountHolder,
    String? bankName,
    String? ifsc,
    String? branch,
    String? upiId,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      maskedDetail: maskedDetail ?? this.maskedDetail,
      isPrimary: isPrimary ?? this.isPrimary,
      accountHolder: accountHolder ?? this.accountHolder,
      bankName: bankName ?? this.bankName,
      ifsc: ifsc ?? this.ifsc,
      branch: branch ?? this.branch,
      upiId: upiId ?? this.upiId,
    );
  }
}
