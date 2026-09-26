import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VyapaarPilotApp());
}

class VyapaarPilotApp extends StatelessWidget {
  const VyapaarPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VyapaarPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.dashboard,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
