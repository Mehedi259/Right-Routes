import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'package:right_routes/views/home/create_new_routes/homescreen.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_document.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadBundleFonts() async {
  final leagueGothic = FontLoader('League Gothic')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/LeagueGothic-Regular.ttf').readAsBytesSync(),
        ),
      ),
    );
  await leagueGothic.load();

  final lato = FontLoader('Lato')
    ..addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/Lato-Regular.ttf').readAsBytesSync(),
        ),
      ),
    );
  await lato.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadBundleFonts();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AuthService.init();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('CreateRouteTutorialBanner displays client colors, text, link, and actions', (
    WidgetTester tester,
  ) async {
    bool toggled = false;
    bool closed = false;
    bool linkTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: CreateRouteTutorialBanner(
              dontShowAgain: false,
              onToggleDontShowAgain: () => toggled = true,
              onClose: () => closed = true,
              onLinkTap: () => linkTapped = true,
            ),
          ),
        ),
      ),
    );

    final bannerContainer = tester.widget<Container>(
      find.descendant(
        of: find.byType(CreateRouteTutorialBanner),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = bannerContainer.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFF12A900));

    expect(find.textContaining('Watch this short video on'), findsOneWidget);
    expect(find.text(createRouteTutorialVideoUrl), findsOneWidget);
    expect(find.text("Don't show again."), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);

    await tester.tap(find.text(createRouteTutorialVideoUrl));
    await tester.pump();
    expect(linkTapped, isTrue);

    await tester.tap(find.text("Don't show again."));
    await tester.pump();
    expect(toggled, isTrue);

    await tester.tap(find.byType(GestureDetector).last);
    await tester.pump();
    expect(closed, isTrue);
  });

  testWidgets('showPermitDialog shows tutorial message only when showTutorialVideo is true', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => showPermitDialog(context, showTutorialVideo: false),
                  child: const Text('Open Permit 2'),
                ),
                ElevatedButton(
                  onPressed: () => showPermitDialog(context, showTutorialVideo: true),
                  child: const Text('Open Permit 1'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Permit 2'));
    await tester.pumpAndSettle();
    expect(find.text(createRouteTutorialVideoUrl), findsNothing);
    expect(find.textContaining('There are two ways to input directions:'), findsOneWidget);

    // Dismiss dialog via barrier tap or navigator
    Navigator.of(tester.element(find.textContaining('There are two ways'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Permit 1'));
    await tester.pumpAndSettle();
    expect(find.text(createRouteTutorialVideoUrl), findsOneWidget);
    expect(find.textContaining('There are two ways to input directions:'), findsOneWidget);

    final linkRect = tester.getRect(find.text(createRouteTutorialVideoUrl));
    final bodyRect = tester.getRect(
      find.textContaining('There are two ways to input directions:'),
    );
    expect(linkRect.top, lessThan(bodyRect.top));
  });

  testWidgets(
    'Homescreen shows green banner only on Permit 1 and persists Don\'t show again across visits',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ctrl = Get.put(HomeController(), permanent: true);
      ctrl.currentPermitIndex.value = 1;
      ctrl.choiceMode.value = '';
      ctrl.showMapSection.value = false;

      // 1. Appears initially on Permit 1
      await tester.pumpWidget(const GetMaterialApp(home: Homescreen(key: ValueKey('visit1'))));
      await tester.pumpAndSettle();
      expect(find.byType(CreateRouteTutorialBanner), findsOneWidget);

      // 2. Dismissing with X hides only for current visit
      final closeGesture = find.descendant(
        of: find.byType(CreateRouteTutorialBanner),
        matching: find.byType(Positioned),
      );
      await tester.ensureVisible(closeGesture);
      await tester.tap(closeGesture);
      await tester.pumpAndSettle();
      expect(find.byType(CreateRouteTutorialBanner), findsNothing);
      expect(AuthService.getHideCreateRouteTutorialBanner(), isFalse);

      // 3. Reopening Permit 1 shows it again if box was not checked
      await tester.pumpWidget(const GetMaterialApp(home: Homescreen(key: ValueKey('visit2'))));
      await tester.pumpAndSettle();
      expect(find.byType(CreateRouteTutorialBanner), findsOneWidget);

      // 4. Hidden on Permit 2
      ctrl.currentPermitIndex.value = 2;
      await tester.pumpAndSettle();
      expect(find.byType(CreateRouteTutorialBanner), findsNothing);

      // Back to Permit 1
      ctrl.currentPermitIndex.value = 1;
      await tester.pumpAndSettle();
      expect(find.byType(CreateRouteTutorialBanner), findsOneWidget);

      // 5. Checking "Don't show again." persists permanently across new opens
      final checkboxText = find.text("Don't show again.");
      await tester.ensureVisible(checkboxText);
      await tester.tap(checkboxText);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(AuthService.getHideCreateRouteTutorialBanner(), isTrue);

      await tester.pumpWidget(const GetMaterialApp(home: Homescreen(key: ValueKey('visit3'))));
      await tester.pumpAndSettle();
      expect(find.byType(CreateRouteTutorialBanner), findsNothing);
    },
  );
}

