import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/features/dashboard/dashboard_screen.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/api/api_service.dart';

void main() {
  group('VyapaarPilot Frontend Integration & E2E Tests', () {
    testWidgets(
      'Full Merchant Journey: Dashboard -> Opportunity -> Experiment -> Result -> Dashboard',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1024, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Launch App
        await tester.pumpWidget(
          const VyapaarPilotApp(initialRoute: AppRouter.dashboard),
        );
        await tester.pumpAndSettle();

        // --- 1. DASHBOARD VERIFICATION ---
        expect(find.text('Good morning'), findsOneWidget);
        expect(find.text('Sharma General Store'), findsWidgets);
        expect(find.text('Lucknow • Retail'), findsOneWidget);

        // Primary Metric
        expect(find.text("Today's Sales"), findsOneWidget);
        expect(find.text('₹18,420'), findsOneWidget);
        expect(find.text('12% vs usual'), findsOneWidget);

        // Secondary Metrics
        expect(find.text('73'), findsOneWidget);
        expect(find.text('Transactions'), findsOneWidget);
        expect(find.text('₹252'), findsOneWidget);
        expect(find.text('Avg. transaction'), findsOneWidget);

        // Opportunity Discovery
        expect(find.text('OPPORTUNITY FOR YOU'), findsOneWidget);
        expect(
          find.text('Tuesday evening sales are unusually low'),
          findsOneWidget,
        );
        expect(find.text('Tuesday • 4 PM – 7 PM'), findsOneWidget);
        expect(find.text('24% vs normal'), findsOneWidget);
        expect(find.text('Observed for 4 weeks'), findsOneWidget);

        // Tap "View insight" button with stable test key
        final viewInsightFinder = find.byKey(
          const Key('dashboard_view_insight_button'),
        );
        expect(viewInsightFinder, findsOneWidget);
        await tester.ensureVisible(viewInsightFinder);
        await tester.tap(viewInsightFinder);
        await tester.pumpAndSettle();

        // --- 2. OPPORTUNITY DETAILS VERIFICATION ---
        expect(find.text('Business Opportunity'), findsOneWidget);
        expect(find.text('Tuesday evening slowdown'), findsOneWidget);
        expect(find.text('24%'), findsOneWidget);
        expect(find.text('below normal'), findsOneWidget);

        // Evidence Section
        expect(find.text('Why are we showing this?'), findsOneWidget);
        expect(find.text('4 consecutive Tuesdays'), findsOneWidget);
        expect(find.text('Same 4–7 PM period'), findsOneWidget);
        expect(find.text('Normal baseline: ₹13,800'), findsOneWidget);
        expect(find.text('Recent average: ₹10,488'), findsOneWidget);

        // Performance Comparison
        expect(find.text('Performance Comparison'), findsOneWidget);
        expect(find.text('Normal Tuesday'), findsOneWidget);
        expect(find.text('Recent Tuesday avg.'), findsOneWidget);
        expect(find.text('-₹3,312 (-24%)'), findsOneWidget);

        // AI Explanation & Recommendation
        expect(find.text('VyapaarPilot says'), findsOneWidget);
        expect(find.text('What you can try'), findsOneWidget);

        // Tap "Test this opportunity" button with stable test key
        final testOpportunityFinder = find.byKey(
          const Key('test_opportunity_button'),
        );
        expect(testOpportunityFinder, findsOneWidget);
        await tester.ensureVisible(testOpportunityFinder);
        await tester.tap(testOpportunityFinder);
        await tester.pumpAndSettle();

        // --- 3. EXPERIMENT SCREEN VERIFICATION ---
        expect(find.byKey(const Key('experiment_screen')), findsOneWidget);
        expect(
          find.byKey(const Key('experiment_opportunity_title')),
          findsOneWidget,
        );
        expect(
          find.text('Tuesday evening sales are unusually low'),
          findsOneWidget,
        );
        expect(find.text('Historical baseline'), findsOneWidget);
        expect(find.text('₹13,800'), findsOneWidget);
        expect(find.byKey(const Key('synthetic_demo_badge')), findsOneWidget);
        expect(find.text('Synthetic demo simulation'), findsOneWidget);

        // Tap "Start Experiment" button with stable test key
        final startExperimentFinder = find.byKey(
          const Key('start_experiment_button'),
        );
        expect(startExperimentFinder, findsOneWidget);
        await tester.ensureVisible(startExperimentFinder);
        await tester.tap(startExperimentFinder);
        await tester.pumpAndSettle();

        // --- 4. RESULT SCREEN VERIFICATION ---
        expect(find.byKey(const Key('result_screen')), findsOneWidget);
        expect(find.text('Experiment complete ✓'), findsOneWidget);
        expect(find.text('+25%'), findsOneWidget);
        expect(find.text('₹13,800'), findsOneWidget);
        expect(find.text('₹17,250'), findsOneWidget);
        expect(find.text('₹3,450 above baseline'), findsOneWidget);
        expect(
          find.byKey(const Key('synthetic_result_disclaimer')),
          findsOneWidget,
        );

        // Tap "Back to Dashboard" button with stable test key
        final backToDashboardFinder = find.byKey(
          const Key('back_to_dashboard_button'),
        );
        expect(backToDashboardFinder, findsOneWidget);
        await tester.ensureVisible(backToDashboardFinder);
        await tester.tap(backToDashboardFinder);
        await tester.pumpAndSettle();

        // --- 5. VERIFY RETURNED TO DASHBOARD ---
        expect(find.text("Today's Sales"), findsOneWidget);
        expect(find.text('Sharma General Store'), findsWidgets);
      },
    );

    testWidgets('AI Assistant: Interactive States & Agentic Confirmation', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1024, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const VyapaarPilotApp(initialRoute: AppRouter.dashboard),
      );
      await tester.pumpAndSettle();

      // Open AI Assistant via Floating Action Button
      final openAssistantFinder = find.byKey(
        const Key('open_assistant_button'),
      );
      expect(openAssistantFinder, findsOneWidget);
      await tester.tap(openAssistantFinder);
      await tester.pumpAndSettle();

      // Verify AI Assistant screen loaded
      expect(find.text('VyapaarPilot Assistant'), findsOneWidget);
      expect(find.text('Language:'), findsOneWidget);
      expect(
        find.text(
          'Namaste Sharma ji! Main VyapaarPilot hoon. Aapke store ke sales, trends ya Tuesday drop ke baare mein kuch bhi poochein.',
        ),
        findsOneWidget,
      );

      // Switch language to Hindi
      await tester.tap(find.text('हिंदी'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'नमस्ते शर्मा जी! मैं व्यापारपायलट हूँ। आपकी मंगलवार की बिक्री में 24% की कमी दर्ज हुई है। क्या आप 3 घंटे का प्रोमो चलाना चाहते हैं?',
        ),
        findsOneWidget,
      );

      // Test Mic Listening State toggle
      final micFinder = find.byKey(const Key('assistant_mic_button'));
      expect(micFinder, findsOneWidget);
      await tester.tap(micFinder);
      await tester.pump();
      expect(
        find.text('Listening in Hindi / English... Tap mic to finish'),
        findsOneWidget,
      );

      // Tap mic again to finish listening and submit query
      await tester.tap(micFinder);
      await tester.pumpAndSettle();

      // Trigger Experiment query to test Agentic Confirmation flow
      final textInputFinder = find.byKey(const Key('assistant_text_input'));
      final sendButtonFinder = find.byKey(const Key('assistant_send_button'));

      await tester.enterText(
        textInputFinder,
        'Start Tuesday 4-7 PM experiment',
      );
      await tester.tap(sendButtonFinder);
      await tester.pumpAndSettle();

      // Verify Agentic Action Confirmation Card is rendered
      expect(find.text('Start Tuesday 4–7 PM experiment?'), findsOneWidget);
      expect(
        find.byKey(const Key('assistant_cancel_action_button')),
        findsOneWidget,
      );
      final confirmBtn = find.byKey(
        const Key('assistant_confirm_action_button'),
      );
      expect(confirmBtn, findsOneWidget);

      // Tap Confirm
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle(const Duration(milliseconds: 700));

      // Should transition to Run Experiment screen
      expect(find.byKey(const Key('experiment_screen')), findsOneWidget);
      expect(find.text('Test this opportunity'), findsOneWidget);
    });

    testWidgets('Responsive Layout Multi-Device Check', (
      WidgetTester tester,
    ) async {
      // 1. Mobile width (360x800)
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      await tester.pumpWidget(
        const VyapaarPilotApp(initialRoute: AppRouter.dashboard),
      );
      await tester.pumpAndSettle();
      expect(find.text("Today's Sales"), findsOneWidget);
      expect(tester.takeException(), isNull); // No RenderFlex overflow

      // 2. Tablet width (768x1024)
      tester.view.physicalSize = const Size(768, 1024);
      await tester.pumpWidget(
        const VyapaarPilotApp(initialRoute: AppRouter.dashboard),
      );
      await tester.pumpAndSettle();
      expect(find.text("Today's Sales"), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 3. Desktop / Web width (1280x800)
      tester.view.physicalSize = const Size(1280, 800);
      await tester.pumpWidget(
        const VyapaarPilotApp(initialRoute: AppRouter.dashboard),
      );
      await tester.pumpAndSettle();
      expect(find.text("Today's Sales"), findsOneWidget);
      expect(tester.takeException(), isNull);

      tester.view.resetPhysicalSize();
    });

    testWidgets('Dashboard renders Error State when API fails', (
      WidgetTester tester,
    ) async {
      final errorService = MockApiService(shouldSimulateError: true);

      await tester.pumpWidget(
        MaterialApp(home: DashboardScreen(apiService: errorService)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text("We couldn't load your business insights."),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets(
      'Dashboard renders Empty State when no opportunities detected',
      (WidgetTester tester) async {
        final emptyService = MockApiService(
          shouldReturnEmptyOpportunities: true,
        );

        await tester.pumpWidget(
          MaterialApp(home: DashboardScreen(apiService: emptyService)),
        );
        await tester.pumpAndSettle();

        expect(find.text('No new opportunities found.'), findsOneWidget);
        expect(
          find.text('VyapaarPilot will keep watching your business.'),
          findsOneWidget,
        );
      },
    );
  });
}
