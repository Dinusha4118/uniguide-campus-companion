import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../application/providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../../domain/calculations/deadline_calculator.dart';
import '../../widgets/deadline_card.dart';
import '../../widgets/primary_button.dart';

class DeadlinesScreen extends ConsumerStatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  ConsumerState<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends ConsumerState<DeadlinesScreen> {
  int _selectedFilter = 0; // 0 = Upcoming, 1 = Overdue, 2 = Completed

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSi = settings.language == 'si';

    final deadlinesAsync = ref.watch(deadlinesProvider);
    final modulesAsync = ref.watch(modulesProvider);

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: isDark ? AppColors.night : AppColors.softCloud,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSi ? 'නියමිත කාලසීමා' : 'Deadlines',
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
                        ? 'පැවරුම්, ප්‍රශ්නාවලි සහ විභාග නියමිත වේලාවට අවසන් කරන්න'
                        : 'Assignments, quizzes, and exams sorted by urgency',
                    style: TextStyle(
                      fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                      fontSize: 13,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Chips: [ Upcoming | Overdue | Completed ]
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: isSi ? 'ඉදිරියට ඇති' : 'Upcoming',
                          index: 0,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: isSi ? 'කල් ඉකුත් වූ' : 'Overdue',
                          index: 1,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: isSi ? 'සම්පූර්ණ කළ' : 'Completed',
                          index: 2,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // AI Sprint Recommendation Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                            : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isSi
                                ? 'AI ස්මාර්ට් උපදෙස: දින 3 කට අඩු පැවරුම් ප්‍රමුඛත්වය ලබාගෙන පළමුව අවසන් කරන්න.'
                                : 'AI Insight: Prioritize tasks due under 72h first to avoid rush.',
                            style: TextStyle(
                              fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF312E81),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Deadline List
            Expanded(
              child: deadlinesAsync.when(
                data: (deadlines) {
                  final modules = modulesAsync.value ?? [];
                  final moduleMap = {for (var m in modules) m.id: m};

                  List<dynamic> filtered;
                  if (_selectedFilter == 0) {
                    filtered = DeadlineCalculator.filterUpcoming(deadlines, now);
                  } else if (_selectedFilter == 1) {
                    filtered = DeadlineCalculator.filterOverdue(deadlines, now);
                  } else {
                    filtered = DeadlineCalculator.filterCompleted(deadlines);
                  }

                  if (filtered.isEmpty) {
                    return _buildEmptyState(isDark, isSi);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final deadline = filtered[idx];
                      final mod = moduleMap[deadline.moduleId];

                      return DeadlineCard(
                        deadline: deadline,
                        module: mod,
                        onToggleComplete: (completed) async {
                          await ref.read(deadlinesProvider.notifier).toggleCompleted(deadline.id, completed);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  completed
                                      ? (isSi ? 'නියමිත කාර්යය සම්පූර්ණ කරන ලදී! 🎉' : 'Deadline marked complete! 🎉')
                                      : (isSi ? 'නියමිත කාර්යය නැවත විවෘත කරන ලදී' : 'Deadline restored to upcoming'),
                                ),
                                action: SnackBarAction(
                                  label: isSi ? 'අස් කරන්න' : 'Undo',
                                  onPressed: () {
                                    ref.read(deadlinesProvider.notifier).toggleCompleted(deadline.id, !completed);
                                  },
                                ),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        },
                        onTap: () => context.push('/deadlines/edit/${deadline.id}'),
                        onDelete: () async {
                          await ref.read(deadlinesProvider.notifier).deleteDeadline(deadline.id);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),

            // Bottom Add Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: PrimaryButton(
                label: isSi ? '+ නව නියමිත කාර්යයක්' : '+ Add deadline',
                onPressed: () => context.push('/deadlines/add'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({required String label, required int index, required bool isDark}) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.campusOrange
              : (isDark ? AppColors.cardDarkElevated : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.campusOrange
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.interFont,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? AppColors.deepNavy
                : (isDark ? AppColors.textDarkHigh : AppColors.ink),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, bool isSi) {
    String title;
    String subtitle;
    IconData icon;

    if (_selectedFilter == 0) {
      title = isSi ? 'ඉදිරියට නියමිත කාර්යයන් නොමැත!' : 'All caught up!';
      subtitle = isSi
          ? 'ඔබට ඉදිරියට නියමිත කිසිදු පැවරුමක් නොමැත. විවේකය භුක්ති විඳින්න!'
          : 'You have no upcoming deadlines. Relax or study ahead!';
      icon = Icons.celebration_rounded;
    } else if (_selectedFilter == 1) {
      title = isSi ? 'කල් ඉකුත් වූ කාර්යයන් නොමැත' : 'No overdue deadlines';
      subtitle = isSi
          ? 'විශිෂ්ටයි! ඔබ සියල්ල නියමිත වේලාවට භාර දී ඇත.'
          : 'Great job staying ahead of schedule!';
      icon = Icons.verified_rounded;
    } else {
      title = isSi ? 'සම්පූර්ණ කළ කාර්යයන් නොමැත' : 'No completed deadlines';
      subtitle = isSi
          ? 'ඔබ අවසන් කරන කාර්යයන් මෙහි දිස්වනු ඇත.'
          : 'Finished deadlines will be archived here.';
      icon = Icons.task_alt_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDarkElevated : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.campusOrange),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.poppinsFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkHigh : AppColors.deepNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: isSi ? AppTypography.sinhalaFont : AppTypography.interFont,
                fontSize: 14,
                color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
