import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/features/experiment/experiment_screen.dart';
import 'package:frontend/features/result/result_screen.dart';
import 'package:frontend/models/experiment.dart';
import 'package:frontend/models/opportunity.dart';
import 'package:frontend/repositories/experiment_repository.dart';

class TestableTrackingDataSource implements ExperimentDataSource {
  int callCount = 0;
  bool shouldFail;
  Duration delay;

  TestableTrackingDataSource({
    this.shouldFail = false,
    this.delay = const Duration(milliseconds: 100),
  });

  @override
  Future<ExperimentResult> createExperiment(ExperimentRequest request) async {
    callCount++;
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (shouldFail) {
      throw Exception("We couldn't run the experiment.");
    }
    return ExperimentResult(
      experimentId: 'EXP001',
      opportunityId: request.opportunityId,
      merchantId: request.merchantId,
      baseline: 13800.0,
      result: 17250.0,
      upliftPercent: 25.0,
      incrementalAmount: 3450.0,
      status: 'completed',
      isSynthetic: true,
    );
  }

  @override
  Future<ExperimentResult> getExperimentResult(String experimentId) async {
    return const ExperimentResult(
      experimentId: 'EXP001',
      opportunityId: 'OP001',
      merchantId: 'M001',
      baseline: 13800.0,
      result: 17250.0,
      upliftPercent: 25.0,
      incrementalAmount: 3450.0,
      status: 'completed',
      isSynthetic: true,
    );
  }
}

void main() {
  group('Phase 3 Action Loop Mandatory Tests', () {
    const mockOpportunity = Opportunity(
      opportunityId: 'OP001',
      merchantId: 'M001',
      type: 'slow_period',
      title: 'Tuesday evening slowdown',
      day: 'Tuesday',
      period: '4 PM – 7 PM',
      declinePercent: 24.0,
      baseline: 13800.0,
      current: 10488.0,
      weeksObserved: 4,
      evidence: ['4 consecutive Tuesdays'],
      explanation: 'Tuesday sales drop explanation',
      recommendation: 'Test targeted promotion',
    );

    // TEST 1: Experiment screen renders
    testWidgets('TEST 1: Experiment screen renders with all key components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: ExperimentScreen(opportunity: mockOpportunity)),
      );
      await tester.pumpAndSettle();

      // Verify title
      expect(
        find.byKey(const Key('experiment_opportunity_title')),
        findsOneWidget,
      );
      expect(find.text('Tuesday evening slowdown'), findsOneWidget);

      // Verify period
      expect(find.byKey(const Key('experiment_period')), findsOneWidget);
      expect(find.text('Tuesday • 4 PM – 7 PM'), findsOneWidget);

      // Verify baseline
      expect(
        find.byKey(const Key('experiment_baseline_value')),
        findsOneWidget,
      );
      expect(find.text('₹13,800'), findsOneWidget);

      // Verify upfront synthetic badge
      expect(find.byKey(const Key('synthetic_demo_badge')), findsOneWidget);
      expect(find.text('Synthetic demo simulation'), findsOneWidget);

      // Verify Start Experiment button
      expect(find.byKey(const Key('start_experiment_button')), findsOneWidget);
    });

    // TEST 2: Start button enters loading state and disables duplicate tap
    testWidgets(
      'TEST 2: Start button enters loading state and disables duplicate tap',
      (WidgetTester tester) async {
        final dataSource = TestableTrackingDataSource(
          delay: const Duration(milliseconds: 300),
        );
        final repo = DefaultExperimentRepository(dataSource: dataSource);

        await tester.pumpWidget(
          MaterialApp(
            home: ExperimentScreen(
              opportunity: mockOpportunity,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final startBtn = find.byKey(const Key('start_experiment_button'));
        expect(startBtn, findsOneWidget);
        await tester.ensureVisible(startBtn);

        // Tap button once
        await tester.tap(startBtn);
        await tester.pump(); // Advance frame to trigger state change

        // Verify loading state indicator exists
        expect(
          find.byKey(const Key('experiment_loading_state')),
          findsOneWidget,
        );
        expect(find.text('Running synthetic experiment...'), findsOneWidget);

        // Tap button again during execution (disabled button)
        await tester.tap(startBtn, warnIfMissed: false);
        await tester.pump();

        // Complete async operation
        await tester.pumpAndSettle();

        // Verify only 1 call was executed
        expect(dataSource.callCount, 1);
      },
    );

    // TEST 3: Successful experiment navigates to Result
    testWidgets(
      'TEST 3: Successful experiment navigates to Result and displays outcome data',
      (WidgetTester tester) async {
        final dataSource = TestableTrackingDataSource(
          delay: const Duration(milliseconds: 50),
        );
        final repo = DefaultExperimentRepository(dataSource: dataSource);

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: ExperimentScreen(
              opportunity: mockOpportunity,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final startBtn = find.byKey(const Key('start_experiment_button'));
        await tester.ensureVisible(startBtn);
        await tester.tap(startBtn);
        await tester.pumpAndSettle();

        // Verifies Result screen rendered
        expect(find.byKey(const Key('result_screen')), findsOneWidget);
        expect(find.text('Experiment complete ✓'), findsOneWidget);

        // Verify Result data
        expect(find.byKey(const Key('result_baseline_value')), findsOneWidget);
        expect(find.text('₹13,800'), findsOneWidget);

        expect(
          find.byKey(const Key('result_experiment_value')),
          findsOneWidget,
        );
        expect(find.text('₹17,250'), findsOneWidget);

        expect(find.byKey(const Key('result_uplift_value')), findsOneWidget);
        expect(find.text('+25%'), findsOneWidget);

        expect(
          find.byKey(const Key('result_incremental_value')),
          findsOneWidget,
        );
        expect(find.text('₹3,450 above baseline'), findsOneWidget);
      },
    );

    // TEST 4: Experiment failure displays ErrorState and prevents navigation to Result
    testWidgets(
      'TEST 4: Experiment failure displays ErrorState and prevents navigation',
      (WidgetTester tester) async {
        final dataSource = TestableTrackingDataSource(
          shouldFail: true,
          delay: const Duration(milliseconds: 50),
        );
        final repo = DefaultExperimentRepository(dataSource: dataSource);

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: ExperimentScreen(
              opportunity: mockOpportunity,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final startBtn = find.byKey(const Key('start_experiment_button'));
        await tester.ensureVisible(startBtn);
        await tester.tap(startBtn);
        await tester.pumpAndSettle();

        // Verify Error state displayed
        expect(find.byKey(const Key('experiment_error_state')), findsOneWidget);
        expect(find.text("We couldn't run the experiment."), findsOneWidget);
        expect(
          find.text('Your experiment was not started. Please try again.'),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('experiment_retry_button')),
          findsOneWidget,
        );

        // Verify NOT navigated to Result
        expect(find.byKey(const Key('result_screen')), findsNothing);
      },
    );

    // TEST 5: Retry recovers from failure
    testWidgets(
      'TEST 5: Retry recovers and navigates to Result when repository succeeds',
      (WidgetTester tester) async {
        final dataSource = TestableTrackingDataSource(
          shouldFail: true,
          delay: const Duration(milliseconds: 50),
        );
        final repo = DefaultExperimentRepository(dataSource: dataSource);

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: ExperimentScreen(
              opportunity: mockOpportunity,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial failure
        final startBtn = find.byKey(const Key('start_experiment_button'));
        await tester.ensureVisible(startBtn);
        await tester.tap(startBtn);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('experiment_error_state')), findsOneWidget);

        // Recover backend / repository
        dataSource.shouldFail = false;

        // Tap Retry
        final retryBtn = find.byKey(const Key('experiment_retry_button'));
        expect(retryBtn, findsOneWidget);
        await tester.ensureVisible(retryBtn);
        await tester.tap(retryBtn);
        await tester.pumpAndSettle();

        // Verify navigation to Result succeeded
        expect(find.byKey(const Key('result_screen')), findsOneWidget);
        expect(find.text('Experiment complete ✓'), findsOneWidget);
        expect(find.text('+25%'), findsOneWidget);
      },
    );

    // TEST 6: Invalid opportunity shows safe empty/error state
    testWidgets(
      'TEST 6: Invalid opportunity shows safe empty/error state without crashing',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ExperimentScreen(opportunityId: 'invalid')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Opportunity unavailable'), findsOneWidget);
        expect(
          find.text(
            "The opportunity you're trying to test could not be loaded.",
          ),
          findsOneWidget,
        );
        expect(find.text('Back to Opportunities'), findsOneWidget);
      },
    );

    // TEST 7: Result screen displays synthetic disclaimer
    testWidgets(
      'TEST 7: Result screen displays prominent synthetic disclaimer',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ResultScreen(
              initialResult: ExperimentResult(
                experimentId: 'EXP001',
                opportunityId: 'OP001',
                merchantId: 'M001',
                baseline: 13800.0,
                result: 17250.0,
                upliftPercent: 25.0,
                incrementalAmount: 3450.0,
                status: 'completed',
                isSynthetic: true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('synthetic_result_disclaimer')),
          findsOneWidget,
        );
        expect(find.text('Synthetic demo simulation'), findsOneWidget);
        expect(
          find.text(
            'This result uses synthetic hackathon data. It does not represent guaranteed merchant revenue.',
          ),
          findsOneWidget,
        );
      },
    );

    // RAPID TAP TEST
    testWidgets('RAPID TAP TEST: Multiple rapid clicks only fire 1 request', (
      WidgetTester tester,
    ) async {
      final dataSource = TestableTrackingDataSource(
        delay: const Duration(milliseconds: 200),
      );
      final repo = DefaultExperimentRepository(dataSource: dataSource);

      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: AppRouter.generateRoute,
          home: ExperimentScreen(
            opportunity: mockOpportunity,
            repository: repo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final btn = find.byKey(const Key('start_experiment_button'));
      await tester.ensureVisible(btn);

      // Rapidly tap 5 times
      await tester.tap(btn);
      await tester.tap(btn, warnIfMissed: false);
      await tester.tap(btn, warnIfMissed: false);
      await tester.tap(btn, warnIfMissed: false);
      await tester.tap(btn, warnIfMissed: false);

      await tester.pumpAndSettle();

      // Only one call executed
      expect(dataSource.callCount, 1);
      expect(find.byKey(const Key('result_screen')), findsOneWidget);
    });

    // RESPONSIVE TEST AUDIT: 360, 768, 1280
    testWidgets(
      'RESPONSIVE AUDIT: Experiment and Result render without overflow across viewports',
      (WidgetTester tester) async {
        final viewports = [
          const Size(360, 800),
          const Size(393, 852),
          const Size(412, 915),
          const Size(768, 1024),
          const Size(1280, 800),
        ];

        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          // Test Experiment Screen
          await tester.pumpWidget(
            const MaterialApp(
              home: ExperimentScreen(opportunity: mockOpportunity),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          // Test Result Screen
          await tester.pumpWidget(
            const MaterialApp(
              home: ResultScreen(
                initialResult: ExperimentResult(
                  experimentId: 'EXP001',
                  opportunityId: 'OP001',
                  baseline: 13800.0,
                  result: 17250.0,
                  upliftPercent: 25.0,
                  incrementalAmount: 3450.0,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
