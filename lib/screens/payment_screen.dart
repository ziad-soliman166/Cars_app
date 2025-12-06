import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/car.dart';
import '../models/payment.dart';
import '../providers/rental_provider.dart';
import '../providers/auth_provider.dart';
import 'rental_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Car car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final int hours;

  const PaymentScreen({
    super.key,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.hours,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final rentalProvider = Provider.of<RentalProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Get userId from auth provider
      final userId = authProvider.user?.id ?? 'unknown_user';
      
      final payment = await rentalProvider.processRentalPayment(
        userId: userId,
        car: widget.car,
        startDate: widget.startDate,
        endDate: widget.endDate,
        totalPrice: widget.totalPrice,
        paymentDetails: {
          'method': _selectedPaymentMethod,
          'cardNumber': _cardNumberController.text,
          'cardHolder': _cardHolderController.text,
          'expiry': _expiryController.text,
          'cvv': _cvvController.text,
        },
      );

      if (mounted) {
        if (payment.status == PaymentStatus.completed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RentalSuccessScreen(
                car: widget.car,
                rental: rentalProvider.currentRental!,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  bool _validateForm() {
    if (_selectedPaymentMethod == 'card') {
      if (_cardNumberController.text.length < 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid card number')),
        );
        return false;
      }
      if (_cardHolderController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter card holder name')),
        );
        return false;
      }
      if (_expiryController.text.length < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter expiry date (MM/YY)')),
        );
        return false;
      }
      if (_cvvController.text.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter CVV')),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[900],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  _SummaryRow(label: 'Car', value: widget.car.name),
                  _SummaryRow(label: 'Duration', value: '${widget.hours} hour${widget.hours != 1 ? 's' : ''}'),
                  _SummaryRow(label: 'Start Date', value: '${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year}'),
                  _SummaryRow(label: 'End Date', value: '${widget.endDate.day}/${widget.endDate.month}/${widget.endDate.year}'),
                  Divider(height: 30.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${widget.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),

            // Payment Method Selection
            Text(
              'Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15.h),
            _PaymentMethodOption(
              icon: Icons.credit_card,
              title: 'Credit/Debit Card',
              value: 'card',
              selected: _selectedPaymentMethod == 'card',
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'card';
                });
              },
            ),
            SizedBox(height: 10.h),
            _PaymentMethodOption(
              icon: Icons.account_balance_wallet,
              title: 'PayPal',
              value: 'paypal',
              selected: _selectedPaymentMethod == 'paypal',
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'paypal';
                });
              },
            ),
            SizedBox(height: 10.h),
            _PaymentMethodOption(
              icon: Icons.apple,
              title: 'Apple Pay',
              value: 'apple_pay',
              selected: _selectedPaymentMethod == 'apple_pay',
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = 'apple_pay';
                });
              },
            ),
            SizedBox(height: 30.h),

            // Card Details Form
            if (_selectedPaymentMethod == 'card') ...[
              Text(
                'Card Details',
                style: GoogleFonts.poppins(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Card Holder Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
            ],

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Pay \$${widget.totalPrice.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: selected ? Colors.blue[600]! : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? Colors.blue[600] : Colors.grey[600]),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.blue[900] : Colors.grey[900],
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: Colors.blue[600]),
          ],
        ),
      ),
    );
  }
}

