// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:car_rental_app/main.dart';
import 'package:car_rental_app/providers/rental_provider.dart';

void main() {
  testWidgets('App loads and shows home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RentalProvider(),
        child: const CarRentalApp(),
      ),
    );

    // Wait for the app to build
    await tester.pumpAndSettle();

    // Verify that the home screen is displayed
    expect(find.text('Find Your Perfect Car'), findsOneWidget);
  });
}
