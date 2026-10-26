import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/study_calculator.dart';
import '../../widgets/primary_button.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final timerState = ref.watch(focusTimerProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);

    final modulesAsync = ref.watch(modulesProvider);
    final sessionsAsync = ref.watch(studySessionsProvider);

    final sessions = sessionsAsync.value ?? [];
    final streak = StudyCalculator.calculateStreak(sessions, DateTime.now());

    final minutes = timerState.remainingSeconds ~/ 60;
    final seconds = timerState.remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    final isBreak = timerState.status == FocusTimerStatus.breakTime;
    final isRunning = timerState.status == FocusTimerStatus.running;
    final isPaused = timerState.status == FocusTimerStatus.paused;
    final isIdle = timerState.status == FocusTimerStatus.idle;

    final progress = timerState.totalSessionSeconds > 0
        ? (timerState.totalSessionSeconds - timerState.remainingSeconds) / timerState.totalSessionSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isSi ? 'අවධානය සහ පාඩම්' : 'Focus session',
                  style: TextStyle(
                    fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isSi
                      ? 'අවධානය යොමු කර විවේක ගන්න. ඔබේ පාඩම් කාලය වාර්තා කරන්න.'
                      : 'Stay undistracted with Pomodoro cycles',
                  style: TextStyle(
                    fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                    fontSize: 13,
                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Streak Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDarkElevated : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.campusOrange, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      streak > 0
                          ? (isSi ? '$streak දිනක අඛණ්ඩ පාඩම් වාර්තාවක්!' : '$streak-day study streak! Keep going!')
                          : (isSi ? 'අද දින පාඩම් කර ඔබේ වාර්තාව අරඹන්න!' : 'Start your study streak today!'),
                      style: TextStyle(
                        fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Module Selector Chip
              modulesAsync.when(
                data: (modules) {
                  if (modules.isEmpty) {
                    return Text(
                      isSi ? 'පළමුව විෂයයක් එක් කරන්න' : 'Add modules in settings to link sessions',
                      style: const TextStyle(fontSize: 12),
                    );
                  }

                  final selectedModule = modules.firstWhere(
                    (m) => m.id == timerState.activeModuleId,
                    orElse: () => modules.first,
                  );

                  if (timerState.activeModuleId == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      timerNotifier.selectModule(selectedModule.id);
                    });
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDarkElevated : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: timerState.activeModuleId ?? selectedModule.id,
                        icon: const Icon(Icons.arrow_drop_down_rounded),
                        onChanged: isIdle
                            ? (val) {
                                if (val != null) timerNotifier.selectModule(val);
                              }
                            : null, // Lock while running
                        items: modules.map((m) {
                          return DropdownMenuItem(
                            value: m.id,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse((m.colorHex ?? '#FCA311').replaceFirst('#', '0xFF'))),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${m.code} - ${m.name}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Huge Circular Timer
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: isDark ? AppColors.borderDark : const Color(0xFFE5E9F2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isBreak ? AppColors.mintSuccess : AppColors.campusOrange,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontFamily: AppTypography.poppinsFont,
                            fontWeight: FontWeight.w700,
                            fontSize: 48,
                            color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          isBreak
                              ? (isSi ? 'විවේක කාලය' : 'Break Time')
                              : (isRunning
                                  ? (isSi ? 'අවධානයෙන් ඉන්න' : 'Focusing...')
                                  : (isPaused ? (isSi ? 'විරාම ගන්වා ඇත' : 'Paused') : (isSi ? 'සූදානම්' : 'Ready'))),
                          style: TextStyle(
                            fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isBreak ? AppColors.mintSuccess : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (isIdle) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label: isSi ? 'අවධානය අරඹන්න (25m)' : 'Start focus (25m)',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => timerNotifier.startFocus(minutes: 25),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () => timerNotifier.startBreak(minutes: 5),
                          child: Text(
                            isSi ? 'විවේකය (5m)' : 'Break (5m)',
                            style: TextStyle(
                              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          icon: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 24),
                          label: Text(
                            isRunning ? (isSi ? 'විරාමය' : 'Pause') : (isSi ? 'නැවත අරඹන්න' : 'Resume'),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.campusOrange,
                            foregroundColor: AppColors.deepNavy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          onPressed: isRunning ? timerNotifier.pause : timerNotifier.resume,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: Text(
                            isSi ? 'සුරකින්න' : 'Save & end',
                            style: TextStyle(
                              color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            await timerNotifier.endAndSaveSession();
                            ref.invalidate(studySessionsProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(isSi ? 'පාඩම් කාලය සුරකින ලදී!' : 'Session elapsed time saved!')),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => timerNotifier.cancelSession(),
                  child: Text(
                    isSi ? 'අවලංගු කරන්න' : 'Cancel session',
                    style: const TextStyle(color: AppColors.alertRed, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // AI Smart Study Schedule Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.white),
                  label: Text(
                    isSi ? 'AI අධ්‍යයන කාලසටහන සකසන්න' : 'AI Adaptive Study Schedule',
                    style: TextStyle(
                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => context.push('/study/ai-schedule'),
                ),
              ),
              const SizedBox(height: 12),

              // Stats Shortcut Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.campusOrange),
                  label: Text(
                    isSi ? 'ඔබේ පාඩම් සංඛ්‍යාලේඛන බලන්න' : 'See your study stats',
                    style: TextStyle(
                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => context.push('/study/stats'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
