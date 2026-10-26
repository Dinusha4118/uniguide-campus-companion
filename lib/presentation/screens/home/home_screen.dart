import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/timetable_calculator.dart';
import '../../../domain/calculations/attendance_calculator.dart';
import '../../../domain/calculations/deadline_calculator.dart';
import '../../widgets/next_class_card.dart';
import '../../widgets/status_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/ai_briefing_card.dart';
import '../../widgets/ai_assistant_modal.dart';
import '../../../domain/calculations/ai_study_companion_engine.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);
    final classesAsync = ref.watch(timetableProvider);
    final deadlinesAsync = ref.watch(deadlinesProvider);
    final attendanceAsync = ref.watch(attendanceProvider);

    final now = DateTime.now();

    // Determine greeting
    final hour = now.hour;
    final String greeting;
    if (hour < 12) {
      greeting = isSi ? 'සුබ උදෑසනක්' : 'Good morning';
    } else if (hour < 17) {
      greeting = isSi ? 'සුබ දහවලක්' : 'Good afternoon';
    } else {
      greeting = isSi ? 'සුබ සන්ධ්‍යාවක්' : 'Good evening';
    }

    final dateStr = DateFormat('EEEE, d MMMM').format(now);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(modulesProvider);
            ref.invalidate(timetableProvider);
            ref.invalidate(deadlinesProvider);
            ref.invalidate(attendanceProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Greeting & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting, ${settings.studentName}',
                            style: TextStyle(
                              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$dateStr · ${isSi ? 'ඔබේ දවස එක බැල්මකින්' : 'Your day at a glance'}',
                            style: TextStyle(
                              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                              fontSize: 13,
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: isDark ? AppColors.campusOrange : AppColors.deepNavy,
                      ),
                      onPressed: () => context.push('/settings'),
                      tooltip: isSi ? 'සැකසුම්' : 'Settings',
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // AI Daily Briefing Card
                Builder(
                  builder: (context) {
                    final modules = modulesAsync.value ?? [];
                    final deadlines = deadlinesAsync.value ?? [];
                    final attendance = attendanceAsync.value ?? [];
                    final sessions = ref.watch(studySessionsProvider).value ?? [];

                    final briefing = AiStudyCompanionEngine.generateDailyBriefing(
                      studentName: settings.studentName,
                      modules: modules,
                      deadlines: deadlines,
                      attendanceRecords: attendance,
                      studySessions: sessions,
                      academicSettings: settings.academicSettings,
                      now: now,
                      isSinhala: isSi,
                    );

                    return AiBriefingCard(
                      briefing: briefing,
                      onOpenAssistant: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AiAssistantModal(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 2. Next Class Card
                classesAsync.when(
                  data: (classes) {
                    final nextClass = TimetableCalculator.findNextClass(classes, now);
                    final module = nextClass != null
                        ? modulesAsync.value?.cast().firstWhere(
                            (m) => m.id == nextClass.classSession.moduleId,
                            orElse: () => null,
                          )
                        : null;

                    return NextClassCard(
                      nextClass: nextClass,
                      module: module,
                      onViewTodayClasses: () => context.go('/classes'),
                    );
                  },
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                  error: (e, _) => Text('Error loading classes: $e'),
                ),
                const SizedBox(height: 16),

                // 3. Upcoming Deadlines Card
                deadlinesAsync.when(
                  data: (deadlines) {
                    final upcoming = DeadlineCalculator.filterUpcoming(deadlines, now);
                    if (upcoming.isEmpty) {
                      return _buildEmptyHomeCard(
                        title: isSi ? 'ළඟදීම නියමිත දින නොමැත' : 'No upcoming deadlines',
                        subtitle: isSi ? 'සියලු පැවරුම් සහ විභාග සම්පූර්ණයි.' : 'Great job! You are all caught up on submissions.',
                        actionText: isSi ? 'නව දිනයක් එක් කරන්න' : '+ Add deadline',
                        onTap: () => context.push('/deadlines/add'),
                        isDark: isDark,
                      );
                    }
                    final topDeadline = upcoming.first;
                    final mod = modulesAsync.value?.cast().firstWhere(
                          (m) => m.id == topDeadline.moduleId,
                          orElse: () => null,
                        );
                    final countdown = DeadlineCalculator.formatCountdown(topDeadline.dueDateTime, now);

                    return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: InkWell(
                        onTap: () => context.go('/deadlines'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.alarm_rounded, size: 16, color: AppColors.campusOrange),
                                const SizedBox(width: 6),
                                Text(
                                  'DUE SOON · ${countdown.toUpperCase()}',
                                  style: AppTypography.overlineBadge(color: AppColors.campusOrange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              topDeadline.title,
                              style: TextStyle(
                                fontFamily: AppTypography.poppinsFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('EEEE, h:mm a').format(topDeadline.dueDateTime)} · ${mod?.name ?? topDeadline.type.toUpperCase()}',
                              style: TextStyle(
                                fontFamily: AppTypography.interFont,
                                fontSize: 13,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // 4. Attendance Warnings
                modulesAsync.when(
                  data: (modules) {
                    final records = attendanceAsync.value ?? [];
                    final warningWidgets = <Widget>[];

                    for (final m in modules) {
                      final mRecords = records.where((r) => r.moduleId == m.id);
                      final attended = mRecords.where((r) => r.isAttended).length;
                      final missed = mRecords.where((r) => !r.isAttended).length;

                      final res = AttendanceCalculator.calculateSafeSkips(
                        attended: attended,
                        missed: missed,
                        plannedLectures: m.plannedLectures,
                        minAttendanceFraction: settings.academicSettings.minAttendancePercent / 100.0,
                      );

                      if (res.status == AttendanceStatus.needsAttention ||
                          res.status == AttendanceStatus.impossible ||
                          res.status == AttendanceStatus.atLimit) {
                        warningWidgets.add(
                          StatusCard(
                            status: res.status,
                            title: '${m.name} needs you',
                            subtitle: res.currentPercentage != null
                                ? '${res.currentPercentage!.toStringAsFixed(0)}% attendance · ${res.descriptionText}'
                                : res.descriptionText,
                            onTap: () => context.go('/classes'),
                          ),
                        );
                        break; // Show top primary warning on Home to prevent visual noise
                      }
                    }

                    if (warningWidgets.isNotEmpty) {
                      return Column(children: warningWidgets);
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),

                // 5. Primary Action Button: AI Camera Question Solver with Voice
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 22),
                    label: Text(
                      isSi ? 'AI කැමරාවෙන් ප්‍රශ්න විසඳා අසන්න 🎙️' : 'AI Question Camera & Voice 🎙️',
                      style: TextStyle(
                        fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => context.push('/boards/ai-solver'),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Board capture button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.camera_alt_outlined, size: 20, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
                    label: Text(
                      isSi ? 'ලෑල්ලේ සටහන් ඡායාරූප ගන්න' : 'Capture board notes',
                      style: TextStyle(
                        fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => context.push('/boards/capture'),
                  ),
                ),
                const SizedBox(height: 16),

                // 6. Quick Access Cards: Board Snap & Settings
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        title: isSi ? 'ලෑල්ලේ ඡායාරූප' : 'Board Snap',
                        icon: Icons.photo_library_outlined,
                        onTap: () => context.push('/boards'),
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildQuickActionCard(
                        title: isSi ? 'සැකසුම්' : 'Settings',
                        icon: Icons.tune_rounded,
                        onTap: () => context.push('/settings'),
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyHomeCard({
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTypography.poppinsFont,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: AppTypography.interFont,
              fontSize: 13,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: isDark ? AppColors.campusOrange : AppColors.deepNavy),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.poppinsFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
