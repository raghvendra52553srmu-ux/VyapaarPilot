import 'package:flutter/material.dart';

import '../../features/assistant/assistant_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/experiment/experiment_screen.dart';
import '../../features/landing/landing_screen.dart';
import '../../features/opportunity/opportunity_screen.dart';
import '../../features/result/result_screen.dart';
import '../../models/experiment.dart';
import '../../models/opportunity.dart';

/// Centralized route definitions for VyapaarPilot.
class AppRouter {
  AppRouter._();

  static const String landing = '/';
  static const String app = '/app';
  static const String dashboard = '/dashboard';
  static const String opportunity = '/opportunity';
  static const String experiment = '/experiment';
  static const String result = '/result';
  static const String assistant = '/assistant';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute(
          builder: (_) => const LandingScreen(),
          settings: settings,
        );
      case app:
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case opportunity:
        final args = settings.arguments;
        if (args is Opportunity) {
          return MaterialPageRoute(
            builder: (_) => OpportunityScreen(opportunity: args),
            settings: settings,
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => OpportunityScreen(opportunityId: args),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const OpportunityScreen(),
          settings: settings,
        );
      case experiment:
        final expArgs = settings.arguments;
        if (expArgs is Opportunity) {
          return MaterialPageRoute(
            builder: (_) => ExperimentScreen(opportunity: expArgs),
            settings: settings,
          );
        } else if (expArgs is String) {
          return MaterialPageRoute(
            builder: (_) => ExperimentScreen(opportunityId: expArgs),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ExperimentScreen(),
          settings: settings,
        );
      case result:
        final resArgs = settings.arguments;
        if (resArgs is ExperimentResult) {
          return MaterialPageRoute(
            builder: (_) => ResultScreen(initialResult: resArgs),
            settings: settings,
          );
        } else if (resArgs is String) {
          return MaterialPageRoute(
            builder: (_) => ResultScreen(experimentId: resArgs),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const ResultScreen(),
          settings: settings,
        );
      case assistant:
        return MaterialPageRoute(
          builder: (_) => const AssistantScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
