import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:right_routes/views/home/create_new_routes/homescreen.dart';

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

  final cases = <({Size viewport, double containerWidth, String label})>[
    (viewport: const Size(320, 700), containerWidth: 280, label: 'small portrait 320w'),
    (viewport: const Size(360, 800), containerWidth: 320, label: 'portrait 360w'),
    (viewport: const Size(375, 812), containerWidth: 335, label: 'portrait 375w'),
    (viewport: const Size(412, 915), containerWidth: 372, label: 'portrait 412w'),
    (viewport: const Size(800, 360), containerWidth: 296, label: 'landscape 800w left-col'),
  ];

  for (final c in cases) {
    testWidgets(
      'HomeChoiceButtonsRow renders matching font size and height at ${c.label}',
      (WidgetTester tester) async {
        tester.view.physicalSize = c.viewport;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        for (final mode in const ['', 'import', 'build']) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: c.containerWidth,
                    child: HomeChoiceButtonsRow(
                      selectedMode: mode,
                      onImportTap: () {},
                      onBuildTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          final importFinder = find.text('IMPORT PERMIT');
          final buildFinder = find.text('BUILD YOUR ROUTE');

          expect(importFinder, findsOneWidget);
          expect(buildFinder, findsOneWidget);

          final Text importText = tester.widget<Text>(importFinder);
          final Text buildText = tester.widget<Text>(buildFinder);
          expect(importText.style?.fontSize, equals(buildText.style?.fontSize));

          final Size importTextSize = tester.getSize(importFinder);
          final Size buildTextSize = tester.getSize(buildFinder);
          expect(
            importTextSize.height,
            closeTo(buildTextSize.height, 0.5),
            reason:
                'Mode "$mode" at ${c.label}: import height=${importTextSize.height}, build height=${buildTextSize.height}',
          );

          final RenderBox importFittedBox = tester.renderObject<RenderBox>(
            find.ancestor(of: importFinder, matching: find.byType(FittedBox)).first,
          );
          final RenderBox buildFittedBox = tester.renderObject<RenderBox>(
            find.ancestor(of: buildFinder, matching: find.byType(FittedBox)).first,
          );

          // Both FittedBoxes must render at 1:1 (neither independently shrunk).
          expect(
            importFittedBox.size.width / importTextSize.width,
            closeTo(buildFittedBox.size.width / buildTextSize.width, 0.02),
          );
          expect(
            buildFittedBox.size.width / buildTextSize.width,
            moreOrLessEquals(1.0, epsilon: 0.02),
          );

          if (mode == '') {
            // Print verified size once per viewport for visual inspection in logs.
            debugPrint(
              '[${c.label}] sharedFontSize=${importText.style?.fontSize?.toStringAsFixed(2)}, '
              'importH=${importTextSize.height.toStringAsFixed(2)}, '
              'buildH=${buildTextSize.height.toStringAsFixed(2)}',
            );
          }
        }
      },
    );
  }
}
