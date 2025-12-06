import 'dart:math';
import '../models/payment.dart';

class PaymentService {
  // Mock payment processing
  static Future<Payment> processPayment({
    required double amount,
    required String method,
    required Map<String, dynamic> paymentDetails,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate payment success (90% success rate)
    final random = Random();
    final isSuccess = random.nextDouble() > 0.1;

    return Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      timestamp: DateTime.now(),
      status: isSuccess ? PaymentStatus.completed : PaymentStatus.failed,
      method: method,
      transactionId: isSuccess ? 'txn_${random.nextInt(1000000)}' : null,
    );
  }

  static List<PaymentMethod> getSavedPaymentMethods() {
    return [
      PaymentMethod(
        id: '1',
        type: 'card',
        lastFourDigits: '4242',
        cardHolderName: 'John Doe',
        expiryDate: '12/25',
      ),
      PaymentMethod(
        id: '2',
        type: 'card',
        lastFourDigits: '8888',
        cardHolderName: 'John Doe',
        expiryDate: '06/26',
      ),
    ];
  }
}


