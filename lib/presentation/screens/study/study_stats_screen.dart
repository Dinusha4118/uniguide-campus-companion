import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/study_calculator.dart';

class StudyStatsScreen extends ConsumerWidget {
  const StudyStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);
    final sessionsAsync = ref.watch(studySessionsProvider);

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(isSi ? 'පාඩම් සංඛ්‍යාලේඛන' : 'Study statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: sessionsAsync.when(
          data: (sessions) {
            final modules = modulesAsync.value ?? [];

            final summary = StudyCalculator.calculateWeeklySummary(
              sessions: sessions,
              modules: modules,
              currentLocalTime: now,
            );

            final totalHoursThisWeek = summary.totalMinutesWeek / 60.0;
            final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
            final maxDailyMins = max(1, summary.weeklyDailyTotals.fold<int>(0, (maxVal, item) => max(maxVal, item.totalMinutes)));

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metric Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: isSi ? 'මෙම සතියේ එකතුව' : 'This week',
                          value: '${totalHoursThisWeek.toStringAsFixed(1)} hrs',
                          subtitle: '${summary.completedSessionsCount} ${isSi ? "වාර්තා" : "sessions"}',
                          icon: Icons.timer_outlined,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          title: isSi ? 'අඛණ්ඩ දින' : 'Study streak',
                          value: '${summary.streakDays} ${isSi ? "දින" : "days"}',
                          subtitle: summary.streakDays > 0 ? (isSi ? 'විශිෂ්ටයි!' : 'On fire! 🔥') : (isSi ? 'අද අරඹන්න' : 'Start today'),
                          icon: Icons.local_fire_department_rounded,
                          iconColor: AppColors.campusOrange,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekly Bar Chart Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSi ? 'සතිපතා දෛනික පාඩම් කාලය' : 'Weekly study activity',
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSi ? 'සඳුදා සිට ඉරිදා දක්වා වැය කළ කාලය' : 'Hours spent studying each day',
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                            fontSize: 12,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bar Chart Row
                        SizedBox(
                          height: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(7, (idx) {
                              final dayTotal = summary.weeklyDailyTotals[idx];
                              final mins = dayTotal.totalMinutes;
                              final fraction = (mins / maxDailyMins).clamp(0.05, 1.0);
                              final isToday = now.weekday == (idx + 1);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    mins > 0 ? '${(mins / 60).toStringAsFixed(1)}h' : '',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    width: 24,
                                    height: 90 * fraction,
                                    decoration: BoxDecoration(
                                      color: isToday
                                          ? AppColors.campusOrange
                                          : (mins > 0
                                              ? (isDark ? AppColors.campusOrange.withValues(alpha: 0.5) : const Color(0xFFFED89B))
                                              : (isDark ? AppColors.borderDark : const Color(0xFFE5E9F2))),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    days[idx],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                                      color: isToday
                                          ? AppColors.campusOrange
                                          : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Module Breakdown
                  Text(
                    isSi ? 'විෂයය අනුව පාඩම් කාලය' : 'Study time by module',
                    style: TextStyle(
                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (summary.moduleStats.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        isSi ? 'තවමත් පාඩම් සැසි වාර්තා කර නොමැත' : 'No recorded focus time yet',
                        style: TextStyle(color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: summary.moduleStats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final stat = summary.moduleStats[idx];
                        final m = stat.module;
                        final color = Color(int.parse((m.colorHex ?? '#FCA311').replaceFirst('#', '0xFF')));

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDarkElevated : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${m.code} - ${m.name}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                                  ),
                                ),
                              ),
                              Text(
                                stat.formattedTime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.campusOrange,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 20),

                  // Zero Study Time Reminder Card
                  if (summary.unstudiedModules.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.warnAmberDarkTint : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.amberWarn.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.amberWarn, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isSi
                                  ? 'අවධානයට: ${summary.unstudiedModules.map((m) => m.code).join(", ")} සඳහා තවමත් පාඩම් කාලයක් වාර්තා කර නොමැත.'
                                  : 'Heads up: You haven\'t logged any focus time for ${summary.unstudiedModules.map((m) => m.code).join(", ")} yet.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textDarkHigh : const Color(0xFF78350F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDarkElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.interFont,
                    fontSize: 12,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 18, color: iconColor ?? (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.poppinsFont,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: AppTypography.interFont,
              fontSize: 11,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
        ],
      ),
    );
  }
}
