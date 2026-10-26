import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'presentation/widgets/app_scaffold_shell.dart';
import 'presentation/screens/onboarding/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_flow_screen.dart';
import 'presentation/screens/onboarding/setup_wizard_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/classes/classes_screen.dart';
import 'presentation/screens/classes/add_class_screen.dart';
import 'presentation/screens/classes/attendance_detail_screen.dart';
import 'presentation/screens/deadlines/deadlines_screen.dart';
import 'presentation/screens/deadlines/add_deadline_screen.dart';
import 'presentation/screens/study/study_screen.dart';
import 'presentation/screens/study/study_stats_screen.dart';
import 'presentation/screens/study/ai_study_schedule_screen.dart';
import 'presentation/screens/gpa/gpa_screen.dart';
import 'presentation/screens/gpa/what_if_planner_screen.dart';
import 'presentation/screens/boards/board_gallery_screen.dart';
import 'presentation/screens/boards/board_capture_screen.dart';
import 'presentation/screens/boards/ai_camera_question_solver_screen.dart';
import 'presentation/screens/boards/board_viewer_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/settings/academic_rules_screen.dart';
import 'presentation/screens/settings/manage_modules_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // 1. Splash & Onboarding
    GoRoute(
      path: '/',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OnboardingFlowScreen(),
    ),
    GoRoute(
      path: '/setup-wizard',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SetupWizardScreen(),
    ),

    // 2. Main 5-Tab Shell Route
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffoldShell(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Classes
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/classes',
              builder: (context, state) => const ClassesScreen(),
            ),
          ],
        ),
        // Tab 2: Deadlines
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/deadlines',
              builder: (context, state) => const DeadlinesScreen(),
            ),
          ],
        ),
        // Tab 3: Study
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/study',
              builder: (context, state) => const StudyScreen(),
            ),
          ],
        ),
        // Tab 4: GPA
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/gpa',
              builder: (context, state) => const GpaScreen(),
            ),
          ],
        ),
      ],
    ),

    // 3. Sub-screens and Details (Pushed above bottom bar)
    GoRoute(
      path: '/classes/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddClassScreen(),
    ),
    GoRoute(
      path: '/classes/attendance/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AttendanceDetailScreen(moduleId: id);
      },
    ),
    GoRoute(
      path: '/deadlines/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddDeadlineScreen(),
    ),
    GoRoute(
      path: '/deadlines/edit/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddDeadlineScreen(editDeadlineId: id);
      },
    ),
    GoRoute(
      path: '/gpa/what-if',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WhatIfPlannerScreen(),
    ),
    GoRoute(
      path: '/study/stats',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StudyStatsScreen(),
    ),
    GoRoute(
      path: '/study/ai-schedule',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AiStudyScheduleScreen(),
    ),
    GoRoute(
      path: '/boards',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BoardGalleryScreen(),
    ),
    GoRoute(
      path: '/boards/capture',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BoardCaptureScreen(),
    ),
    GoRoute(
      path: '/boards/ai-solver',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AiCameraQuestionSolverScreen(),
    ),
    GoRoute(
      path: '/boards/viewer/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BoardViewerScreen(photoId: id);
      },
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/settings/academic-rules',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AcademicRulesScreen(),
    ),
    GoRoute(
      path: '/settings/modules',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ManageModulesScreen(),
    ),
  ],
);
