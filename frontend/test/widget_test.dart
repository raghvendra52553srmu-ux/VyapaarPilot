import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('Phase 1 Dashboard and complete navigation loop test', (
    WidgetTester tester,
  ) async {
    // Set realistic viewport size for test
    tester.view.physicalSize = const Size(1024, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch App
    await tester.pumpWidget(const VyapaarPilotApp());
    await tester.pumpAndSettle();

    // Verify Dashboard screen renders key elements
    expect(find.text('Sharma General Store'), findsWidgets);
    expect(find.text("Today's Sales"), findsOneWidget);
    expect(find.text('₹18,420'), findsOneWidget);
    expect(find.text('View Opportunity'), findsOneWidget);

    // 2. Navigate: Dashboard -> Opportunity
    await tester.ensureVisible(find.text('View Opportunity'));
    await tester.tap(find.text('View Opportunity'));
    await tester.pumpAndSettle();

    expect(find.text('Tuesday evening slowdown'), findsOneWidget);
    expect(find.text('24% below normal'), findsOneWidget);
    expect(find.text('Test this opportunity'), findsOneWidget);

    // 3. Navigate: Opportunity -> Experiment
    await tester.ensureVisible(find.text('Test this opportunity'));
    await tester.tap(find.text('Test this opportunity'));
    await tester.pumpAndSettle();

    expect(find.text('Targeted 3-Hour Promotion'), findsOneWidget);
    expect(find.text('Historical baseline'), findsOneWidget);
    expect(find.text('₹13,800'), findsOneWidget);
    expect(find.text('Start Experiment'), findsOneWidget);

    // 4. Navigate: Experiment -> Result
    await tester.ensureVisible(find.text('Start Experiment'));
    await tester.tap(find.text('Start Experiment'));
    await tester.pumpAndSettle();

    expect(find.text('Experiment Complete'), findsOneWidget);
    expect(find.text('+25% observed uplift'), findsOneWidget);
    expect(find.text('₹17,250'), findsOneWidget);
    expect(find.text('Back to Dashboard'), findsOneWidget);

    // 5. Navigate: Result -> Dashboard
    await tester.ensureVisible(find.text('Back to Dashboard'));
    await tester.tap(find.text('Back to Dashboard'));
    await tester.pumpAndSettle();

    expect(find.text("Today's Sales"), findsOneWidget);
  });
}
