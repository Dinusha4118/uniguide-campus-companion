import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/gpa_calculator.dart';
import '../../../domain/models/module.dart';
import '../../widgets/circular_gauge_widget.dart';
import '../../widgets/primary_button.dart';

class WhatIfPlannerScreen extends ConsumerStatefulWidget {
  const WhatIfPlannerScreen({super.key});

  @override
  ConsumerState<WhatIfPlannerScreen> createState() => _WhatIfPlannerScreenState();
}

class _WhatIfPlannerScreenState extends ConsumerState<WhatIfPlannerScreen> {
  final Map<String, String?> _simulatedGrades = {};
  bool _initialized = false;

  final List<String> _gradeOptions = [
    'A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'E'
  ];

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(isSi ? 'ශ්‍රේණි අනුකරණය (What-If)' : 'What-if grade planner'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _simulatedGrades.clear();
              });
            },
            child: Text(
              isSi ? 'නැවත සකසන්න' : 'Reset',
              style: const TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: modulesAsync.when(
          data: (modules) {
            final completedModules = modules.where((m) => m.isCompleted && m.completedGrade != null).toList();
            final remainingModules = modules.where((m) => !m.isCompleted).toList();

            if (!_initialized) {
              for (var m in remainingModules) {
                _simulatedGrades[m.id] = m.plannedGrade;
              }
              _initialized = true;
            }

            final nonNullPlanned = <String, String>{};
            _simulatedGrades.forEach((k, v) {
              if (v != null) nonNullPlanned[k] = v;
            });

            final projectedGpa = GpaCalculator.calculateProjectedGpa(
              completedModules: completedModules,
              plannedGrades: nonNullPlanned,
              remainingModules: remainingModules,
              gradeScale: settings.academicSettings.gradeScale,
            );

            final targetGpa = settings.academicSettings.targetGpa;
            final isTargetReached = projectedGpa >= targetGpa;

            return Column(
              children: [
                // Top Live Projected GPA Banner
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDarkElevated : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isTargetReached ? AppColors.mintSuccess : AppColors.campusOrange,
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircularGaugeWidget(
                        value: (projectedGpa / 4.0).clamp(0.0, 1.0),
                        primaryText: projectedGpa.toStringAsFixed(2),
                        secondaryText: isSi ? 'අපේක්ෂිත' : 'Projected',
                        size: 96,
                        progressColor: isTargetReached ? AppColors.mintSuccess : AppColors.campusOrange,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSi ? 'අනාගත අපේක්ෂිත GPA' : 'Projected GPA',
                              style: TextStyle(
                                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              projectedGpa != null ? projectedGpa.toStringAsFixed(2) : '--',
                              style: TextStyle(
                                fontFamily: AppTypography.poppinsFont,
                                fontWeight: FontWeight.w700,
                                fontSize: 26,
                                color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              projectedGpa == null
                                  ? (isSi ? 'පහත විෂයයන් සඳහා අපේක්ෂිත ශ්‍රේණි තෝරන්න' : 'Select planned grades below')
                                  : (isTargetReached
                                      ? (isSi ? 'ඉලක්කය සාක්ෂාත් වේ! (${targetGpa.toStringAsFixed(2)})' : 'Target reached! (${targetGpa.toStringAsFixed(2)}) 🎉')
                                      : (isSi ? 'ඉලක්කයට වඩා අඩුයි (${targetGpa.toStringAsFixed(2)})' : 'Below target (${targetGpa.toStringAsFixed(2)})')),
                              style: TextStyle(
                                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isTargetReached ? AppColors.mintSuccess : AppColors.alertRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Remaining Modules List with Grade Choice Chips
                Expanded(
                  child: remainingModules.isEmpty
                      ? Center(
                          child: Text(
                            isSi
                                ? 'සියලුම විෂයයන් දැනටමත් සම්පූර්ණ කර ඇත.'
                                : 'All modules are already completed! Nothing to simulate.',
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: remainingModules.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, idx) {
                            final m = remainingModules[idx];
                            final currentPlanned = _simulatedGrades[m.id];

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
                                          '${m.name} (${m.code})',
                                          style: TextStyle(
                                            fontFamily: AppTypography.interFont,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${m.credits} Credits',
                                        style: TextStyle(
                                          fontFamily: AppTypography.interFont,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isSi ? 'අපේක්ෂිත ශ්‍රේණිය තෝරන්න:' : 'Select predicted grade:',
                                    style: TextStyle(
                                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                                      fontSize: 12,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Horizontal Chips
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: _gradeOptions.map((g) {
                                        final isSel = currentPlanned == g;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 6.0),
                                          child: ChoiceChip(
                                            label: Text(g),
                                            selected: isSel,
                                            selectedColor: AppColors.campusOrange,
                                            labelStyle: TextStyle(
                                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                              color: isSel ? AppColors.deepNavy : (isDark ? AppColors.textDarkHigh : AppColors.ink),
                                            ),
                                            onSelected: (selected) {
                                              setState(() {
                                                _simulatedGrades[m.id] = selected ? g : null;
                                              });
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),

                // Bottom Save Plan Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: PrimaryButton(
                    label: isSi ? 'මෙම සැලැස්ම සුරකින්න' : 'Save what-if plan',
                    icon: Icons.save_rounded,
                    onPressed: () async {
                      for (var entry in _simulatedGrades.entries) {
                        final mod = remainingModules.firstWhere((m) => m.id == entry.key);
                        final updated = mod.copyWith(plannedGrade: entry.value);
                        await ref.read(modulesProvider.notifier).updateModule(updated);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isSi ? 'සැලැස්ම සාර්ථකව සුරකින ලදී!' : 'What-if plan saved successfully!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        context.pop();
                      }
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
