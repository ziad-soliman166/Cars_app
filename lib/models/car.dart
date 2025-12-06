class Car {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String imageUrl;
  final double pricePerHour;
  final double batteryLevel; // 0.0 to 100.0 for electric cars
  final bool isElectric;
  final bool isAvailable;
  final String location;
  final String description;
  final int seats;
  final String transmission; // "Automatic" or "Manual"
  final double rating;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.imageUrl,
    required this.pricePerHour,
    required this.batteryLevel,
    required this.isElectric,
    required this.isAvailable,
    required this.location,
    required this.description,
    required this.seats,
    required this.transmission,
    required this.rating,
  });

  Car copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    String? imageUrl,
    double? pricePerHour,
    double? batteryLevel,
    bool? isElectric,
    bool? isAvailable,
    String? location,
    String? description,
    int? seats,
    String? transmission,
    double? rating,
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      isElectric: isElectric ?? this.isElectric,
      isAvailable: isAvailable ?? this.isAvailable,
      location: location ?? this.location,
      description: description ?? this.description,
      seats: seats ?? this.seats,
      transmission: transmission ?? this.transmission,
      rating: rating ?? this.rating,
    );
  }
}


