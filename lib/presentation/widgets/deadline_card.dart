import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/models/deadline.dart';
import '../../domain/models/module.dart';
import '../../domain/calculations/deadline_calculator.dart';

class DeadlineCard extends StatelessWidget {
  final Deadline deadline;
  final Module? module;
  final ValueChanged<bool> onToggleComplete;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const DeadlineCard({
    super.key,
    required this.deadline,
    required this.module,
    required this.onToggleComplete,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final urgency = DeadlineCalculator.getUrgency(deadline.dueDateTime, now);
    final countdownStr = DeadlineCalculator.formatCountdown(deadline.dueDateTime, now);

    Color badgeColor;
    Color cardBg;
    switch (urgency) {
      case DeadlineUrgency.overdue:
      case DeadlineUrgency.urgentUnder2Days:
        badgeColor = AppColors.alertRed;
        cardBg = isDark ? AppColors.alertRedDarkTint : const Color(0xFFFDF2F2);
        break;
      case DeadlineUrgency.warningUnder7Days:
        badgeColor = AppColors.amberWarn;
        cardBg = isDark ? AppColors.warnAmberDarkTint : const Color(0xFFFFFBEB);
        break;
      case DeadlineUrgency.calmLater:
        badgeColor = AppColors.mintSuccess;
        cardBg = isDark ? AppColors.cardDark : Colors.white;
        break;
    }

    if (deadline.isCompleted) {
      badgeColor = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
      cardBg = isDark ? AppColors.cardDarkElevated : const Color(0xFFF1F5F9);
    }

    return Dismissible(
      key: Key('deadline_${deadline.id}'),
      direction: DismissDirection.startToEnd,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.mintSuccess,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              'Mark as completed',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        onToggleComplete(!deadline.isCompleted);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      deadline.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      color: deadline.isCompleted ? AppColors.mintSuccess : badgeColor,
                      size: 24,
                    ),
                    onPressed: () => onToggleComplete(!deadline.isCompleted),
                    tooltip: deadline.isCompleted ? 'Mark uncompleted' : 'Mark completed',
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!deadline.isCompleted)
                          Row(
                            children: [
                              Text(
                                countdownStr.toUpperCase(),
                                style: AppTypography.overlineBadge(color: badgeColor),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(
                          deadline.title,
                          style: TextStyle(
                            fontFamily: AppTypography.poppinsFont,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: deadline.isCompleted ? TextDecoration.lineThrough : null,
                            color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${module?.name ?? deadline.type.toUpperCase()} · ${_formatDue(deadline.dueDateTime)}',
                          style: TextStyle(
                            fontFamily: AppTypography.interFont,
                            fontSize: 13,
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Delete deadline',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDue(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day} ${months[dt.month - 1]}, $timeStr';
  }
}
