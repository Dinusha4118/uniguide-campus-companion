import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/calculations/ai_study_companion_engine.dart';

class AiGpaRoadmapModal extends ConsumerWidget {
  const AiGpaRoadmapModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final isSi = settings.language == 'si';
    final modules = ref.watch(modulesProvider).value ?? [];

    final roadmap = AiStudyCompanionEngine.generateGpaTargetRoadmap(
      modules: modules,
      targetGpa: settings.academicSettings.targetGpa,
      gradeScale: settings.academicSettings.gradeScale,
      isSinhala: isSi,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.night : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.campusOrange.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.campusOrange,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSi ? 'AI ඉලක්ක GPA මාර්ග සිතියම' : 'AI GPA Target Roadmap',
                        style: TextStyle(
                          fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDark ? Colors.white : AppColors.deepNavy,
                        ),
                      ),
                      Text(
                        'Target GPA: ${settings.academicSettings.targetGpa.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.campusOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: roadmap.isEmpty
                ? Center(
                    child: Text(
                      isSi
                          ? 'සියලු විෂයයන් දැනටමත් සම්පූර්ණ කර ඇත!'
                          : 'All registered modules are already marked completed!',
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    itemCount: roadmap.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final item = roadmap[idx];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDarkElevated : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  item.targetGrade,
                                  style: const TextStyle(
                                    color: Color(0xFF6366F1),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${item.moduleCode} (${item.credits} Credits)',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppColors.mintSuccess.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Aim: ${item.requiredGpaForModule.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            color: AppColors.mintSuccess,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.moduleName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '💡 ${item.tacticalAdvice}',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
