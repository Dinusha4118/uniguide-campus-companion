import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class AppScaffoldShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffoldShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : const Color(0xFFE5E9F2),
              width: 1.0,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: AppColors.campusOrange.withOpacity(0.18),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return TextStyle(
                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.campusOrange
                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final isSelected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: isSelected
                    ? AppColors.campusOrange
                    : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                size: 24,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 64,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: isSi ? 'මුල් පිටුව' : 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month_rounded),
                label: isSi ? 'දේශන' : 'Classes',
              ),
              NavigationDestination(
                icon: const Icon(Icons.alarm_outlined),
                selectedIcon: const Icon(Icons.alarm_rounded),
                label: isSi ? 'කාලසීමා' : 'Deadlines',
              ),
              NavigationDestination(
                icon: const Icon(Icons.timer_outlined),
                selectedIcon: const Icon(Icons.timer_rounded),
                label: isSi ? 'පාඩම්' : 'Study',
              ),
              NavigationDestination(
                icon: const Icon(Icons.school_outlined),
                selectedIcon: const Icon(Icons.school_rounded),
                label: isSi ? 'GPA' : 'GPA',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
