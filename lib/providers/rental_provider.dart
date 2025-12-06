import 'package:flutter/foundation.dart';
import '../models/car.dart';
import '../models/rental.dart';
import '../models/payment.dart';
import '../services/car_service.dart';
import '../services/payment_service.dart';

class RentalProvider with ChangeNotifier {
  List<Car> _cars = [];
  List<Rental> _rentals = [];
  Car? _selectedCar;
  Rental? _currentRental;
  bool _isLoading = false;

  List<Car> get cars => _cars;
  List<Rental> get rentals => _rentals;
  Car? get selectedCar => _selectedCar;
  Rental? get currentRental => _currentRental;
  bool get isLoading => _isLoading;

  RentalProvider() {
    loadCars();
  }

  void loadCars() {
    _cars = CarService.getCars();
    notifyListeners();
  }

  void selectCar(Car car) {
    _selectedCar = car;
    notifyListeners();
  }

  void clearSelection() {
    _selectedCar = null;
    notifyListeners();
  }

  Future<Payment> processRentalPayment({
    required Car car,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    required Map<String, dynamic> paymentDetails,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final payment = await PaymentService.processPayment(
        amount: totalPrice,
        method: paymentDetails['method'] ?? 'card',
        paymentDetails: paymentDetails,
      );

      if (payment.status == PaymentStatus.completed) {
        final rental = Rental(
          id: 'rental_${DateTime.now().millisecondsSinceEpoch}',
          car: car,
          startDate: startDate,
          endDate: endDate,
          totalPrice: totalPrice,
          status: RentalStatus.confirmed,
          paymentId: payment.id,
        );

        _rentals.add(rental);
        _currentRental = rental;

        // Mark car as unavailable
        final carIndex = _cars.indexWhere((c) => c.id == car.id);
        if (carIndex != -1) {
          _cars[carIndex] = _cars[carIndex].copyWith(isAvailable: false);
        }
      }

      _isLoading = false;
      notifyListeners();
      return payment;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  List<Car> getAvailableCars() {
    return _cars.where((car) => car.isAvailable).toList();
  }

  List<Car> getElectricCars() {
    return _cars.where((car) => car.isElectric).toList();
  }
}


