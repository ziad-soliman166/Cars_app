import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/rental.dart';
import '../models/car.dart';
import '../models/payment.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection
  static const String _usersCollection = 'users';
  static const String _rentalsCollection = 'rentals';
  static const String _paymentsCollection = 'payments';
  static const String _paymentMethodsCollection = 'payment_methods';

  // ========== User Operations ==========
  
  /// Save user data to Firestore (for signup)
  static Future<void> addUserToFirestore({
    required String userId,
    required String email,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      final CollectionReference collectionReference = 
          _firestore.collection(_usersCollection);
      final DocumentReference documentReference = collectionReference.doc(userId);
      
      await documentReference.set({
        'id': documentReference.id,
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding user to Firestore: $e');
    }
  }

  /// Update user data in Firestore
  static Future<void> updateUserInFirestore({
    required String userId,
    String? email,
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final DocumentReference documentReference = 
          _firestore.collection(_usersCollection).doc(userId);
      
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (email != null) updateData['email'] = email;
      if (name != null) updateData['name'] = name;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      
      await documentReference.update(updateData);
    } catch (e) {
      throw Exception('Error updating user in Firestore: $e');
    }
  }

  /// Get user data from Firestore
  static Future<User?> getUserFromFirestore(String userId) async {
    try {
      final DocumentSnapshot doc = 
          await _firestore.collection(_usersCollection).doc(userId).get();
      
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return User(
          id: data['id'] ?? doc.id,
          email: data['email'] ?? '',
          name: data['name'] ?? '',
          phoneNumber: data['phoneNumber'],
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error getting user from Firestore: $e');
    }
  }

  /// Save login activity to Firestore
  static Future<void> saveLoginActivity({
    required String userId,
    required String email,
  }) async {
    try {
      final CollectionReference collectionReference = 
          _firestore.collection(_usersCollection);
      final DocumentReference documentReference = collectionReference.doc(userId);
      
      // Update last login timestamp
      await documentReference.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Also create a login activity log in a subcollection
      await documentReference
          .collection('login_history')
          .add({
        'email': email,
        'loginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error saving login activity: $e');
    }
  }

  // ========== Rental Operations ==========
  
  /// Save rental data to Firestore
  static Future<void> addRentalToFirestore({
    required String rentalId,
    required String userId,
    required Car car,
    required DateTime startDate,
    required DateTime endDate,
    required double totalPrice,
    required RentalStatus status,
    String? paymentId,
  }) async {
    try {
      final CollectionReference collectionReference = 
          _firestore.collection(_rentalsCollection);
      final DocumentReference documentReference = collectionReference.doc(rentalId);
      
      await documentReference.set({
        'id': documentReference.id,
        'userId': userId,
        'carId': car.id,
        'carName': car.name,
        'carBrand': car.brand,
        'carModel': car.model,
        'carImageUrl': car.imageUrl,
        'carPricePerHour': car.pricePerHour,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'totalPrice': totalPrice,
        'status': status.toString().split('.').last, // Convert enum to string
        'paymentId': paymentId ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding rental to Firestore: $e');
    }
  }

  /// Get user's rentals from Firestore
  static Future<List<Map<String, dynamic>>> getUserRentalsFromFirestore(
    String userId,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_rentalsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error getting user rentals from Firestore: $e');
    }
  }

  /// Update rental status in Firestore
  static Future<void> updateRentalStatusInFirestore({
    required String rentalId,
    required RentalStatus status,
  }) async {
    try {
      final DocumentReference documentReference = 
          _firestore.collection(_rentalsCollection).doc(rentalId);
      
      await documentReference.update({
        'status': status.toString().split('.').last,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating rental status in Firestore: $e');
    }
  }

  // ========== Payment Operations ==========
  
  /// Save payment data to Firestore
  static Future<void> addPaymentToFirestore({
    required String paymentId,
    required String userId,
    required String rentalId,
    required double amount,
    required String method,
    required PaymentStatus status,
    String? transactionId,
  }) async {
    try {
      final CollectionReference collectionReference = 
          _firestore.collection(_paymentsCollection);
      final DocumentReference documentReference = collectionReference.doc(paymentId);
      
      await documentReference.set({
        'id': documentReference.id,
        'userId': userId,
        'rentalId': rentalId,
        'amount': amount,
        'method': method,
        'status': status.toString().split('.').last,
        'transactionId': transactionId ?? '',
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding payment to Firestore: $e');
    }
  }

  // ========== Payment Method Operations ==========
  
  /// Save payment method data to Firestore
  static Future<void> addPaymentMethodToFirestore({
    required String userId,
    required String method,
    String? cardNumber,
    String? cardHolder,
    String? expiry,
    String? cvv,
  }) async {
    try {
      final CollectionReference collectionReference = 
          _firestore.collection(_usersCollection)
              .doc(userId)
              .collection(_paymentMethodsCollection);
      final DocumentReference documentReference = collectionReference.doc();
      
      // Only store last 4 digits for security
      String? lastFourDigits;
      if (cardNumber != null && cardNumber.length >= 4) {
        lastFourDigits = cardNumber.substring(cardNumber.length - 4);
      }
      
      await documentReference.set({
        'id': documentReference.id,
        'userId': userId,
        'method': method,
        'lastFourDigits': lastFourDigits ?? '',
        'cardHolder': cardHolder ?? '',
        'expiry': expiry ?? '',
        // Note: CVV should NEVER be stored in production
        // This is just for demo purposes
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error adding payment method to Firestore: $e');
    }
  }

  /// Get user's payment methods from Firestore
  static Future<List<Map<String, dynamic>>> getUserPaymentMethodsFromFirestore(
    String userId,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_paymentMethodsCollection)
          .orderBy('createdAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Error getting user payment methods from Firestore: $e');
    }
  }
}

