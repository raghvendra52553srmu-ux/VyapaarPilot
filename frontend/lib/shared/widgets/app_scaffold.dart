import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/responsive.dart';
import '../../core/routing/app_router.dart';

/// Reusable application scaffold with responsive constraints and navigation.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final bool showAssistantFab;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
    this.showAssistantFab = true,
  });

  void _onNavigationTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.opportunity);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.experiment);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRouter.result);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            key: const Key('appbar_assistant_button'),
            tooltip: 'Ask AI Assistant',
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, AppRouter.assistant),
          ),
          if (MediaQuery.sizeOf(context).width >= 450)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: AppRadius.roundedLarge,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.store, size: 16.0, color: Colors.white),
                      SizedBox(width: AppSpacing.xs + 2),
                      Text(
                        'Sharma General Store',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: showAssistantFab
          ? FloatingActionButton.extended(
              key: const Key('open_assistant_button'),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.assistant),
              backgroundColor: AppColors.secondaryBlue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                'Ask AI',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            )
          : null,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppBreakpoints.maxContentWidth,
            ),
            child: body,
          ),
        ),
      ),
      bottomNavigationBar: Responsive.isDesktop(context)
          ? null
          : BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onNavigationTap(context, index),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surface,
              elevation: 8.0,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11.0,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 11.0,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_outlined),
                  activeIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.lightbulb_outline),
                  activeIcon: Icon(Icons.lightbulb),
                  label: 'Opportunity',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.science_outlined),
                  activeIcon: Icon(Icons.science),
                  label: 'Experiment',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  activeIcon: Icon(Icons.analytics),
                  label: 'Result',
                ),
              ],
            ),
    );
  }
}
