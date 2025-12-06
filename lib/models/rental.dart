import 'car.dart';

class Rental {
  final String id;
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final RentalStatus status;
  final String? paymentId;

  Rental({
    required this.id,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
    this.paymentId,
  });

  int get durationInHours {
    return endDate.difference(startDate).inHours;
  }
}

enum RentalStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
}


