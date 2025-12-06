class PaymentMethod {
  final String id;
  final String type; // "card", "paypal", "apple_pay", etc.
  final String lastFourDigits;
  final String cardHolderName;
  final String expiryDate;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.lastFourDigits,
    required this.cardHolderName,
    required this.expiryDate,
  });
}

class Payment {
  final String id;
  final double amount;
  final DateTime timestamp;
  final PaymentStatus status;
  final String method;
  final String? transactionId;

  Payment({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.method,
    this.transactionId,
  });
}

enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}


