import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/ai_study_companion_engine.dart';

class AiStudyScheduleScreen extends ConsumerStatefulWidget {
  const AiStudyScheduleScreen({super.key});

  @override
  ConsumerState<AiStudyScheduleScreen> createState() => _AiStudyScheduleScreenState();
}

class _AiStudyScheduleScreenState extends ConsumerState<AiStudyScheduleScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  int _dailyBudgetMinutes = 60;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);
    final isSi = settings.language == 'si';

    final modulesAsync = ref.watch(modulesProvider);
    final deadlinesAsync = ref.watch(deadlinesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      appBar: AppBar(
        title: Text(
          isSi ? 'AI අධ්‍යයන සැලසුම්කරු' : 'AI Smart Study Schedule',
          style: TextStyle(
            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: modulesAsync.when(
        data: (modules) {
          final deadlines = deadlinesAsync.value ?? [];
          final plan = AiStudyCompanionEngine.generateWeeklyStudyPlan(
            modules: modules,
            deadlines: deadlines,
            dailyBudgetMinutes: _dailyBudgetMinutes,
            isSinhala: isSi,
          );

          if (modules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  isSi
                      ? 'AI සැලැස්ම සෑදීමට පළමුව Settings වලින් විෂයයන් කිහිපයක් එක් කරන්න.'
                      : 'Please add your modules first in Settings to generate an AI study schedule.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isSi ? 'ස්වයංක්‍රීය පාඩම් සැලැස්ම' : 'Adaptive Weekly Workload',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isSi
                                  ? 'නියමිත පැවරුම් සහ ණය ඒකක අනුව සකස් කළ සතිපතා කාලසටහන'
                                  : 'Auto-balanced based on upcoming deadlines and module credit weights.',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Daily Budget Slider
                Container(
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
                          Text(
                            isSi ? 'දිනකට වෙන් කරන කාලය:' : 'Target Daily Study Budget:',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            '$_dailyBudgetMinutes min',
                            style: const TextStyle(
                              color: Color(0xFF6366F1),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _dailyBudgetMinutes.toDouble(),
                        min: 25,
                        max: 180,
                        divisions: 31,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (val) {
                          setState(() {
                            _dailyBudgetMinutes = val.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Days List
                Text(
                  isSi ? 'සතියේ දින සැලැස්ම' : '7-Day Strategic Roadmap',
                  style: TextStyle(
                    fontFamily: AppTypography.poppinsFont,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 12),

                for (int i = 0; i < plan.length; i++)
                  FadeTransition(
                    opacity: _animController,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDarkElevated : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: plan[i].priorityLevel == 'HIGH'
                              ? AppColors.campusOrange.withOpacity(0.5)
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: plan[i].priorityLevel == 'HIGH'
                                  ? AppColors.campusOrange.withOpacity(0.15)
                                  : (isDark ? Colors.white10 : const Color(0xFFEEF2FF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                plan[i].dayName.substring(0, isSi ? 2 : 3),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: plan[i].priorityLevel == 'HIGH'
                                      ? AppColors.campusOrange
                                      : const Color(0xFF6366F1),
                                  fontSize: 12,
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
                                    Expanded(
                                      child: Text(
                                        '${plan[i].moduleCode} · ${plan[i].moduleName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: plan[i].priorityLevel == 'HIGH'
                                            ? AppColors.alertRed.withOpacity(0.15)
                                            : AppColors.mintSuccess.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${plan[i].allocatedMinutes}m',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: plan[i].priorityLevel == 'HIGH'
                                              ? AppColors.alertRed
                                              : AppColors.mintSuccess,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  plan[i].focusTopic,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
