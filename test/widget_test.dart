import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app with splash screen route
    await tester.pumpWidget(
      const MyApp(
        initialRoute: AppRoutes.splashScreen, // valid route
      ),
    );
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    // Verify app builds without errors
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}















// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// import 'package:right_routes/main.dart';
//
// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget( MyApp(initialRoute:,));
//
//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);
//
//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();
//
//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }
