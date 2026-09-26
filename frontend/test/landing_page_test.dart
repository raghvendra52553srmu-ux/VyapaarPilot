import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/features/landing/landing_screen.dart';
import 'package:frontend/main.dart';

void main() {
  group('VyapaarPilot Premium Landing Page Tests', () {
    // TEST 1: Initial Render & Section Content
    testWidgets(
      'TEST 1: Landing page renders all 7 signature sections and key copy',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const VyapaarPilotApp(initialRoute: AppRouter.landing),
        );
        await tester.pumpAndSettle();

        // 1. Navigation
        expect(find.text('VyapaarPilot'), findsWidgets);
        expect(
          find.byKey(const Key('landing_nav_open_app_button')),
          findsOneWidget,
        );

        // 2. Hero Section
        expect(
          find.textContaining(
            'Your payments know what happened.',
            findRichText: true,
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('what to do next.', findRichText: true),
          findsWidgets,
        );
        expect(
          find.byKey(const Key('landing_hero_explore_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('landing_hero_how_it_works_button')),
          findsOneWidget,
        );
        expect(
          find.text(
            'Built on synthetic merchant data • Human-approved actions',
          ),
          findsOneWidget,
        );

        // 3. Problem Section
        expect(
          find.textContaining('Payments tell merchants what happened.'),
          findsOneWidget,
        );
        expect(find.text('WHAT MERCHANTS HAVE TODAY'), findsOneWidget);
        expect(find.text('WHAT MERCHANTS STILL NEED'), findsOneWidget);

        // 4. Growth Loop Section
        expect(
          find.text('From payment signal to business action.'),
          findsOneWidget,
        );
        expect(
          find.text('Not another dashboard. A closed growth loop.'),
          findsOneWidget,
        );
        expect(find.text('01'), findsOneWidget);
        expect(find.text('DETECT'), findsOneWidget);
        expect(find.text('02'), findsOneWidget);
        expect(find.text('EXPLAIN'), findsOneWidget);
        expect(find.text('03'), findsOneWidget);
        expect(find.text('ACT'), findsWidgets);
        expect(find.text('04'), findsOneWidget);
        expect(find.text('MEASURE'), findsOneWidget);
        expect(find.text('Synthetic demo simulation'), findsWidgets);

        // 5. Product Showcase Section
        expect(
          find.text('One opportunity. Clear evidence. One next step.'),
          findsOneWidget,
        );
        expect(find.text('Tuesday evening slowdown'), findsOneWidget);
        expect(find.text('WHY ARE WE SHOWING THIS?'), findsOneWidget);
        expect(
          find.byKey(const Key('landing_showcase_test_button')),
          findsOneWidget,
        );

        // 6. Voice Agent Section
        expect(
          find.text(
            "Business intelligence that speaks the merchant's language.",
          ),
          findsOneWidget,
        );
        expect(find.text('Meri sales mein kya opportunity hai?'), findsWidgets);
        expect(
          find.text('Tuesday 4–7 PM experiment start karun?'),
          findsOneWidget,
        );
        expect(find.text('VOICE'), findsOneWidget);
        expect(find.text('CONFIRM'), findsOneWidget);

        // 7. Differentiation & Final CTA
        expect(
          find.textContaining("Don't give merchants another dashboard."),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('landing_open_app_button')),
          findsOneWidget,
        );

        // Footer
        expect(find.text('Aarambh Coders 2.0'), findsOneWidget);
        expect(
          find.text('Sundram Gupta • Sara Ali Ahmad • Raghvendra Pandey'),
          findsOneWidget,
        );
      },
    );

    // TEST 2: CTA Navigation - Nav Button to Dashboard
    testWidgets(
      'TEST 2: Tapping "Open VyapaarPilot" in Nav navigates to Dashboard',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const VyapaarPilotApp(initialRoute: AppRouter.landing),
        );
        await tester.pumpAndSettle();

        final navBtn = find.byKey(const Key('landing_nav_open_app_button'));
        expect(navBtn, findsOneWidget);
        await tester.tap(navBtn);
        await tester.pumpAndSettle();

        // Should land on Dashboard
        expect(find.text('Sharma General Store'), findsWidgets);
        expect(find.text("Today's Sales"), findsOneWidget);
        expect(find.text('OPPORTUNITY FOR YOU'), findsOneWidget);
      },
    );

    // TEST 3: CTA Navigation - Hero Button to Dashboard
    testWidgets(
      'TEST 3: Tapping "Explore VyapaarPilot" in Hero navigates to Dashboard',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const VyapaarPilotApp(initialRoute: AppRouter.landing),
        );
        await tester.pumpAndSettle();

        final heroExploreBtn = find.byKey(
          const Key('landing_hero_explore_button'),
        );
        expect(heroExploreBtn, findsOneWidget);
        await tester.tap(heroExploreBtn);
        await tester.pumpAndSettle();

        // Should land on Dashboard
        expect(find.text('Sharma General Store'), findsWidgets);
        expect(find.text("Today's Sales"), findsOneWidget);
      },
    );

    // TEST 4: "See how it works" triggers scroll action
    testWidgets(
      'TEST 4: Tapping "See how it works" triggers programmatic scroll',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const VyapaarPilotApp(initialRoute: AppRouter.landing),
        );
        await tester.pumpAndSettle();

        final howItWorksBtn = find.byKey(
          const Key('landing_hero_how_it_works_button'),
        );
        expect(howItWorksBtn, findsOneWidget);
        await tester.tap(howItWorksBtn);
        await tester.pumpAndSettle();

        // Growth loop section is visible
        expect(
          find.text('From payment signal to business action.'),
          findsOneWidget,
        );
      },
    );

    // TEST 5: CTA Navigation - Final Button to Dashboard
    testWidgets(
      'TEST 5: Tapping "Open VyapaarPilot" at the bottom navigates to Dashboard',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 3000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const VyapaarPilotApp(initialRoute: AppRouter.landing),
        );
        await tester.pumpAndSettle();

        final bottomBtn = find.byKey(const Key('landing_open_app_button'));
        expect(bottomBtn, findsOneWidget);
        await tester.ensureVisible(bottomBtn);
        await tester.tap(bottomBtn);
        await tester.pumpAndSettle();

        // Should land on Dashboard
        expect(find.text('Sharma General Store'), findsWidgets);
        expect(find.text("Today's Sales"), findsOneWidget);
      },
    );

    // RESPONSIVE VIEWPORT AUDIT: 360, 390, 768, 1280, 1440
    testWidgets(
      'RESPONSIVE AUDIT: Zero overflow across 360, 390, 768, 1280, and 1440 widths',
      (WidgetTester tester) async {
        final viewports = [
          const Size(360, 800),
          const Size(390, 844),
          const Size(768, 1024),
          const Size(1280, 900),
          const Size(1440, 900),
        ];

        final originalOnError = FlutterError.onError;
        for (final size in viewports) {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          FlutterError.onError = (details) {
            // ignore: avoid_print
            print('ERROR AT SIZE $size:\n${details.toDiagnosticsNode().toStringDeep()}');
            originalOnError?.call(details);
          };

          await tester.pumpWidget(const MaterialApp(home: LandingScreen()));
          await tester.pumpAndSettle();

          final error = tester.takeException();
          expect(
            error,
            isNull,
            reason: 'Overflow detected at ${size.width}x${size.height}',
          );
        }
        FlutterError.onError = originalOnError;

        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      },
    );
  });
}
