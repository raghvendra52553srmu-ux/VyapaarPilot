import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/opportunities/opportunity_detail_screen.dart';
import '../../features/experiments/experiment_screen.dart';
import '../../features/assistant/assistant_screen.dart';

class AppRouter {
  AppRouter._();

  static const String dashboard = '/';
  static const String opportunityDetail = '/opportunity';
  static const String experiment = '/experiment';
  static const String assistant = '/assistant';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case opportunityDetail:
        final opportunityId = settings.arguments as String? ?? 'OP001';
        return MaterialPageRoute(
          builder: (_) => OpportunityDetailScreen(opportunityId: opportunityId),
        );
      case experiment:
        final opportunityId = settings.arguments as String? ?? 'OP001';
        return MaterialPageRoute(
          builder: (_) => ExperimentScreen(opportunityId: opportunityId),
        );
      case assistant:
        return MaterialPageRoute(builder: (_) => const AssistantScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
