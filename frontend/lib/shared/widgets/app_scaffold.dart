import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/responsive/responsive_layout.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
  });

  void _onNavigationTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/opportunity');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/experiment');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/assistant');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.store, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Sharma General Store',
                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: body,
          ),
        ),
      ),
      bottomNavigationBar: ResponsiveLayout.isDesktop(context)
          ? null
          : BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onNavigationTap(context, index),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline), label: 'Opportunity'),
                BottomNavigationBarItem(icon: Icon(Icons.science_outlined), label: 'Experiment'),
                BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Assistant'),
              ],
            ),
    );
  }
}
