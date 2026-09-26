import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/features/assistant/assistant_screen.dart';
import 'package:frontend/services/api/api_service.dart';

void main() {
  group('Phase 4 — Multilingual Agent + Voice + Action Confirmation E2E Tests', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    // TEST 1: Assistant opens with UI elements and initial greeting
    testWidgets(
      'TEST 1: Assistant opens with greeting, language chips, input and mic controls',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        // Verify screen rendered
        expect(find.byKey(const Key('assistant_screen')), findsOneWidget);
        expect(find.text('VyapaarPilot Assistant'), findsOneWidget);

        // Verify initial greeting
        expect(
          find.text(
            'Namaste Sharma ji! Main VyapaarPilot hoon. Aapke store ke sales, trends ya Tuesday drop ke baare mein kuch bhi poochein.',
          ),
          findsOneWidget,
        );

        // Verify controls
        expect(find.byKey(const Key('assistant_mic_button')), findsOneWidget);
        expect(find.byKey(const Key('assistant_text_field')), findsOneWidget);
        expect(find.byKey(const Key('assistant_send_button')), findsOneWidget);
        expect(find.text('Language:'), findsOneWidget);
      },
    );

    // TEST 2: Text "Meri sales mein kya opportunity hai?" returns Tuesday, 4–7 PM, 24%
    testWidgets(
      'TEST 2: Text query returns opportunity containing Tuesday, 4–7 PM, and 24%',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const Key('assistant_text_input'));
        await tester.enterText(
          inputFinder,
          'Meri sales mein kya opportunity hai?',
        );
        await tester.tap(find.byKey(const Key('assistant_send_button')));
        await tester.pumpAndSettle();

        // Verify user message displayed
        expect(find.text('Meri sales mein kya opportunity hai?'), findsWidgets);

        // Verify agent answer contains required business facts
        final answerFinder = find.textContaining('Tuesday');
        expect(answerFinder, findsWidgets);

        final periodFinder = find.textContaining('4–7 PM');
        expect(periodFinder, findsWidgets);

        final percentFinder = find.textContaining('24%');
        expect(percentFinder, findsWidgets);
      },
    );

    // TEST 3: Action request "Experiment start karo." shows confirmation UI and does NOT execute yet
    testWidgets(
      'TEST 3: Action request triggers confirmation UI without immediate execution',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const Key('assistant_text_input'));
        await tester.enterText(inputFinder, 'Experiment start karo.');
        await tester.tap(find.byKey(const Key('assistant_send_button')));
        await tester.pumpAndSettle();

        // Verify Confirmation prompt and panel displayed
        expect(
          find.byKey(const Key('assistant_confirmation_panel')),
          findsOneWidget,
        );
        expect(
          find.text('Tuesday 4–7 PM experiment start karun?'),
          findsWidgets,
        );
        expect(
          find.byKey(const Key('assistant_cancel_action_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('assistant_confirm_action_button')),
          findsOneWidget,
        );

        // CRITICAL: createExperiment MUST NOT have executed yet
        expect(mockApiService.createExperimentCallCount, 0);
      },
    );

    // TEST 4: Tap Cancel cancels the proposal and creates no experiment
    testWidgets(
      'TEST 4: Tapping Cancel cancels the proposal without creating an experiment',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const Key('assistant_text_input'));
        await tester.enterText(inputFinder, 'Experiment start karo.');
        await tester.tap(find.byKey(const Key('assistant_send_button')));
        await tester.pumpAndSettle();

        // Tap Cancel
        final cancelBtn = find.byKey(
          const Key('assistant_cancel_action_button'),
        );
        expect(cancelBtn, findsOneWidget);
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();

        // Verify cancellation notice
        expect(find.text('Action cancelled by merchant.'), findsOneWidget);

        // Verify no experiment was created
        expect(mockApiService.createExperimentCallCount, 0);
      },
    );

    // TEST 5: Request again and Confirm executes createExperiment exactly once
    testWidgets(
      'TEST 5: Confirming proposal executes createExperiment exactly once',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: AppRouter.generateRoute,
            home: AssistantScreen(apiService: mockApiService),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Submit action request
        final inputFinder = find.byKey(const Key('assistant_text_input'));
        await tester.enterText(inputFinder, 'Experiment start karo.');
        await tester.tap(find.byKey(const Key('assistant_send_button')));
        await tester.pumpAndSettle();

        // 2. Tap Confirm
        final confirmBtn = find.byKey(
          const Key('assistant_confirm_action_button'),
        );
        expect(confirmBtn, findsOneWidget);
        await tester.tap(confirmBtn);
        await tester.pump();

        // Verify createExperiment executed exactly once
        expect(mockApiService.createExperimentCallCount, 1);

        // Verify success message with outcome
        expect(find.textContaining('Experiment created ✓'), findsOneWidget);
        expect(find.textContaining('₹13,800'), findsWidgets);
        expect(find.textContaining('₹17,250'), findsWidgets);
        expect(find.textContaining('+25% Uplift'), findsWidgets);
      },
    );

    // TEST 6: Mock STT transcript triggers same agent workflow as text
    testWidgets(
      'TEST 6: Voice input STT transcript routes through identical agent brain',
      (WidgetTester tester) async {
        mockApiService.mockSttTranscript =
            'Meri sales mein kya opportunity hai?';

        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        final micBtn = find.byKey(const Key('assistant_mic_button'));
        expect(micBtn, findsOneWidget);

        // Tap 1: Start listening
        await tester.tap(micBtn);
        await tester.pump();
        expect(
          find.byKey(const Key('assistant_listening_indicator')),
          findsOneWidget,
        );

        // Tap 2: Finish and transcribe
        await tester.tap(micBtn);
        await tester.pumpAndSettle();

        // Verify recognized user transcript displayed
        expect(find.text('Meri sales mein kya opportunity hai?'), findsWidgets);

        // Verify agent answered with identical business intelligence
        expect(find.textContaining('Tuesday'), findsWidgets);
        expect(find.textContaining('4–7 PM'), findsWidgets);
        expect(find.textContaining('24%'), findsWidgets);
      },
    );

    // TEST 7: STT failure shows friendly error and preserves text fallback
    testWidgets(
      'TEST 7: STT failure displays friendly error and keeps text input active',
      (WidgetTester tester) async {
        mockApiService.shouldSimulateSttError = true;

        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        final micBtn = find.byKey(const Key('assistant_mic_button'));

        // Tap 1: Start listening
        await tester.tap(micBtn);
        await tester.pump();

        // Tap 2: Attempt transcribe -> triggers simulated STT failure
        await tester.tap(micBtn);
        await tester.pumpAndSettle();

        // Verify suggested error message displayed
        expect(
          find.text(
            "I couldn't hear that clearly. Try again or type your question.",
          ),
          findsOneWidget,
        );

        // Verify text input remains fully available as fallback
        expect(find.byKey(const Key('assistant_text_input')), findsOneWidget);
      },
    );

    // TEST 8: Backend unavailable shows friendly error with NO fake success
    testWidgets(
      'TEST 8: Backend unavailable displays friendly error without fake success',
      (WidgetTester tester) async {
        mockApiService.shouldSimulateError = true;

        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const Key('assistant_text_input'));
        await tester.enterText(inputFinder, 'Check sales');
        await tester.tap(find.byKey(const Key('assistant_send_button')));
        await tester.pumpAndSettle();

        // Verify friendly error banner/message displayed
        expect(
          find.text(
            "We couldn't reach the business assistant. Please check your connection or try again.",
          ),
          findsOneWidget,
        );

        // Verify NO fake success
        expect(find.textContaining('Experiment created ✓'), findsNothing);
        expect(mockApiService.createExperimentCallCount, 0);
      },
    );

    // MULTILINGUAL VERIFICATION: English, Hindi, Hinglish
    testWidgets(
      'MULTILINGUAL: Agent responds consistently in English, Hindi, and Hinglish',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(home: AssistantScreen(apiService: mockApiService)),
        );
        await tester.pumpAndSettle();

        final inputFinder = find.byKey(const Key('assistant_text_input'));
        final sendBtn = find.byKey(const Key('assistant_send_button'));

        // 1. English
        await tester.tap(find.text('English'));
        await tester.pumpAndSettle();
        await tester.enterText(inputFinder, 'What opportunity do I have?');
        await tester.tap(sendBtn);
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            'Tuesday 4–7 PM sales are consistently 24% below',
          ),
          findsOneWidget,
        );

        // 2. Hindi
        await tester.tap(find.text('हिंदी'));
        await tester.pumpAndSettle();
        await tester.enterText(
          inputFinder,
          'मेरे बिज़नेस में अभी क्या अवसर है?',
        );
        await tester.tap(sendBtn);
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            'Tuesday को 4–7 PM के दौरान बिक्री सामान्य से 24% कम रही है',
          ),
          findsOneWidget,
        );

        // 3. Hinglish
        await tester.tap(find.text('Hinglish'));
        await tester.pumpAndSettle();
        await tester.enterText(
          inputFinder,
          'Meri sales mein abhi kya opportunity hai?',
        );
        await tester.tap(sendBtn);
        await tester.pumpAndSettle();
        expect(
          find.textContaining('sales 24% down chal rahi hai'),
          findsOneWidget,
        );
      },
    );

    // RESPONSIVE VIEWPORT TEST FOR ASSISTANT
    testWidgets(
      'RESPONSIVE AUDIT: Assistant renders cleanly across 360, 768, and 1280 viewports',
      (WidgetTester tester) async {
        final viewports = [
          const Size(360, 800),
          const Size(768, 1024),
          const Size(1280, 800),
        ];

        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            MaterialApp(home: AssistantScreen(apiService: mockApiService)),
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
