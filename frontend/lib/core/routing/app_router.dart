import 'package:flutter/material.dart';

import '../../features/dashboard/dashboard_screen.dart';
import '../../features/opportunity/opportunity_screen.dart';
import '../../features/experiment/experiment_screen.dart';
import '../../features/result/result_screen.dart';

/// Centralized route definitions for VyapaarPilot Phase 1.
class AppRouter {
  AppRouter._();

  static const String dashboard = '/dashboard';
  static const String opportunity = '/opportunity';
  static const String experiment = '/experiment';
  static const String result = '/result';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
          settings: settings,
        );
      case opportunity:
        return MaterialPageRoute(
          builder: (_) => const OpportunityScreen(),
          settings: settings,
        );
      case experiment:
        return MaterialPageRoute(
          builder: (_) => const ExperimentScreen(),
          settings: settings,
        );
      case result:
        return MaterialPageRoute(
          builder: (_) => const ResultScreen(),
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
