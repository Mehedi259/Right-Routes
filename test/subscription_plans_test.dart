import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/constants/services/subscription_billing_service.dart';
import 'package:right_routes/views/subscription_plans/choose_team_plan/choose_team_plan.dart';
import 'package:right_routes/views/subscription_plans/choose_your_plan/choose_your_plan.dart';
import 'package:right_routes/views/subscription_plans/individual_team.dart';
import 'package:right_routes/views/subscription_plans/subscription_model/subscription_model.dart';

Widget _wrapWithScreenUtil(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(430, 932),
    minTextAdapt: true,
    builder: (_, __) => GetMaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('SubscriptionPlanModel parses Play Console product_id and trial_days', () {
    final model = SubscriptionPlanModel.fromJson({
      'id': 3,
      'name': 'Up to 5 Drivers',
      'product_id': 'rr_team_5_monthly',
      'plan_type': 'TEAM',
      'billing_type': 'MONTHLY',
      'team_limit': 5,
      'price': '69.00',
      'currency': 'USD',
      'trial_days': 7,
      'features_json': {'drivers': 5},
      'is_active': true,
    });

    expect(model.id, 3);
    expect(model.productId, SubscriptionBillingService.productTeam5Monthly);
    expect(model.title, 'Up to 5 Drivers');
    expect(model.price, '69.00');
    expect(model.currency, 'USD');
    expect(model.teamLimit, 5);
    expect(model.trialDays, 7);
    expect(model.isActive, isTrue);
  });

  test('SubscriptionBillingService exposes all 7 Play Console product IDs', () {
    expect(
      SubscriptionBillingService.allKnownProductIds,
      containsAll(<String>[
        'rr_individual_annual',
        'rr_individual_monthly',
        'rr_team_5_monthly',
        'rr_team_10_monthly',
        'rr_team_25_monthly',
        'rr_team_50_monthly',
        'rr_team_100_monthly',
      ]),
    );
  });

  testWidgets('ChooseYourPlan renders Individual plans and 7-day free trial', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    await tester.pumpWidget(_wrapWithScreenUtil(const ChooseYourPlan()));
    await tester.pump();

    expect(find.text('CHOOSE YOUR PLAN'), findsOneWidget);
    expect(find.textContaining('7-day free trial'), findsOneWidget);
    expect(find.text('ANNUAL PLAN'), findsOneWidget);
    expect(find.text('MONTHLY PLAN'), findsOneWidget);
    expect(find.text('RESTORE SUBSCRIPTION'), findsOneWidget);
  });

  testWidgets('ChooseATeamPlan renders Team plans and 7-day free trial', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    await tester.pumpWidget(_wrapWithScreenUtil(const ChooseATeamPlan()));
    await tester.pump();

    expect(find.text('CHOOSE A TEAM PLAN'), findsOneWidget);
    expect(find.textContaining('7-day free trial'), findsOneWidget);
    expect(find.text('UP TO 5 DRIVERS'), findsOneWidget);
    expect(find.text('UP TO 10 DRIVERS'), findsOneWidget);
    expect(find.text('UP TO 25 DRIVERS'), findsOneWidget);
    expect(find.text('UP TO 50 DRIVERS'), findsOneWidget);
    expect(find.text('UP TO 100 DRIVERS'), findsOneWidget);
    expect(find.text('RESTORE SUBSCRIPTION'), findsOneWidget);
  });

  testWidgets('IndividualTeam renders Individual, Team, and Restore buttons', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    await tester.pumpWidget(_wrapWithScreenUtil(const IndividualTeam()));
    await tester.pump();

    expect(find.text('INDIVIDUAL'), findsOneWidget);
    expect(find.text('TEAM'), findsOneWidget);
    expect(find.text('RESTORE SUBSCRIPTION'), findsOneWidget);
  });
}
