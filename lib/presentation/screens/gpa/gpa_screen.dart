import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/gpa_calculator.dart';
import '../../../domain/calculations/attendance_calculator.dart';
import '../../../domain/models/module.dart';
import '../../widgets/circular_gauge_widget.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_card.dart';
import '../../widgets/ai_gpa_roadmap_modal.dart';

class GpaScreen extends ConsumerWidget {
  const GpaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                isSi ? 'GPA සැලසුම්කරු' : 'GPA Planner',
                style: TextStyle(
                  fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isSi
                    ? 'ඔබේ ඉලක්කය පවත්වා ගන්න සහ අනාගත ශ්‍රේණි සැලසුම් කරන්න'
                    : 'Target analysis and what-if grade predictions',
                style: TextStyle(
                  fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                  fontSize: 13,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              const SizedBox(height: 20),

              modulesAsync.when(
                data: (modules) {
                  final completedModules = modules.where((m) => m.isCompleted && m.completedGrade != null).toList();
                  final remainingModules = modules.where((m) => !m.isCompleted).toList();
                  final remainingCredits = remainingModules.fold<int>(0, (sum, m) => sum + m.credits);

                  final gpaResult = GpaCalculator.calculateCurrentGpa(
                    completedModules,
                    settings.academicSettings.gradeScale,
                  );

                  final targetAnalysis = GpaCalculator.calculateRequiredRemainingAverage(
                    completedCredits: gpaResult.completedCredits,
                    completedPoints: gpaResult.totalGradePoints,
                    remainingCredits: remainingCredits,
                    targetGpa: settings.academicSettings.targetGpa,
                    gradeScale: settings.academicSettings.gradeScale,
                  );

                  final isAchievable = targetAnalysis.status == TargetFeasibilityStatus.achievable ||
                      targetAnalysis.status == TargetFeasibilityStatus.alreadyAchieved;

                  return Column(
                    children: [
                      // Circular GPA Hero Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDarkElevated : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            CircularGaugeWidget(
                              value: (gpaResult.currentGpa / 4.0).clamp(0.0, 1.0),
                              primaryText: gpaResult.completedCredits > 0
                                  ? gpaResult.currentGpa.toStringAsFixed(2)
                                  : '-',
                              secondaryText: isSi ? 'GPA ඉලක්කය' : 'out of 4.00',
                              progressColor: AppColors.campusOrange,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildMetricChip(
                                  label: isSi ? 'ඉලක්ක GPA' : 'Target GPA',
                                  value: settings.academicSettings.targetGpa.toStringAsFixed(2),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 12),
                                _buildMetricChip(
                                  label: isSi ? 'සම්පූර්ණ බැර' : 'Completed Cr',
                                  value: '${gpaResult.completedCredits}',
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 12),
                                _buildMetricChip(
                                  label: isSi ? 'ඉතිරි බැර' : 'Remaining Cr',
                                  value: '$remainingCredits',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Target Analysis Status Card
                      StatusCard(
                        status: isAchievable ? AttendanceStatus.safe : AttendanceStatus.impossible,
                        title: isAchievable
                            ? (isSi ? 'ඉලක්කය සාක්ෂාත් කරගත හැක' : 'Target Achievable')
                            : (isSi ? 'ඉලක්කය කළ නොහැක' : 'Target Impossible'),
                        subtitle: targetAnalysis.message,
                        badgeText: targetAnalysis.requiredAverage != null
                            ? 'Need ${targetAnalysis.requiredAverage!.toStringAsFixed(2)}'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // AI Target Roadmap Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.psychology_rounded, size: 20, color: Colors.white),
                          label: Text(
                            isSi ? 'AI ඉලක්ක GPA මාර්ග සිතියම' : 'AI Smart Target Roadmap',
                            style: TextStyle(
                              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const AiGpaRoadmapModal(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // What-if Planner Entry Button
                      PrimaryButton(
                        label: isSi ? 'ශ්‍රේණි අනුකරණය කරන්න (What-If)' : 'Explore what-if grades',
                        icon: Icons.auto_graph_rounded,
                        onPressed: () => context.push('/gpa/what-if'),
                      ),
                      const SizedBox(height: 12),

                      // Edit Target & Grades Secondary Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit_note_rounded, size: 20),
                          label: Text(
                            isSi ? 'ඉලක්කය සහ ශ්‍රේණි සංස්කරණය' : 'Edit target & module grades',
                            style: TextStyle(
                              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => _showEditGradesDialog(context, ref, modules, settings.academicSettings.targetGpa),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Completed Modules Breakdown
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isSi ? 'සම්පූර්ණ කළ විෂයයන්' : 'Completed modules',
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (completedModules.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDarkElevated : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Center(
                            child: Text(
                              isSi
                                  ? 'සම්පූර්ණ කළ විෂයයන් නොමැත. "ඉලක්කය සහ ශ්‍රේණි සංස්කරණය" ඔබන්න.'
                                  : 'No completed modules yet. Tap "Edit target & module grades" to enter your grades.',
                              style: TextStyle(
                                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: completedModules.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, idx) {
                            final m = completedModules[idx];
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.cardDarkElevated : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m.name,
                                          style: TextStyle(
                                            fontFamily: AppTypography.interFont,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                                          ),
                                        ),
                                        Text(
                                          '${m.code} · ${m.credits} Credits',
                                          style: TextStyle(
                                            fontFamily: AppTypography.interFont,
                                            fontSize: 12,
                                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.campusOrange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      m.completedGrade ?? '-',
                                      style: const TextStyle(
                                        fontFamily: AppTypography.interFont,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                        color: AppColors.campusOrange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 32),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip({required String label, required String value, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.softCloud,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: AppTypography.poppinsFont,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.interFont,
              fontSize: 10,
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditGradesDialog(BuildContext context, WidgetRef ref, List<Module> modules, double currentTarget) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final targetController = TextEditingController(text: currentTarget.toStringAsFixed(2));
    final grades = {for (var m in modules) m.id: m.completedGrade ?? ''};
    final completedMap = {for (var m in modules) m.id: m.isCompleted};
    final gradeOptions = ['', 'A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'E'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: isDark ? AppColors.cardDarkElevated : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Target & Grades'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: targetController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Target GPA (0.00 – 4.00)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Module Grades:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...modules.map((m) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${m.code} (${m.credits} cr)',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Checkbox(
                            value: completedMap[m.id],
                            onChanged: (val) {
                              setDialogState(() {
                                completedMap[m.id] = val ?? false;
                              });
                            },
                          ),
                          DropdownButton<String>(
                            value: grades[m.id],
                            items: gradeOptions.map((g) {
                              return DropdownMenuItem(value: g, child: Text(g.isEmpty ? 'None' : g));
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                grades[m.id] = val ?? '';
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.campusOrange, foregroundColor: AppColors.deepNavy),
              onPressed: () async {
                final newTarget = double.tryParse(targetController.text.trim()) ?? currentTarget;
                final academic = ref.read(settingsProvider).academicSettings.copyWith(targetGpa: newTarget);
                await ref.read(settingsProvider.notifier).saveAcademicSettings(academic);

                for (var m in modules) {
                  final isComp = completedMap[m.id] ?? false;
                  final g = grades[m.id];
                  final updated = m.copyWith(
                    isCompleted: isComp,
                    completedGrade: (isComp && g != null && g.isNotEmpty) ? g : null,
                  );
                  await ref.read(modulesProvider.notifier).updateModule(updated);
                }

                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
