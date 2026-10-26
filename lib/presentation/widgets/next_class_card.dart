import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/calculations/timetable_calculator.dart';
import '../../domain/models/module.dart';

class NextClassCard extends StatelessWidget {
  final NextClassResult? nextClass;
  final Module? module;
  final VoidCallback onViewTodayClasses;

  const NextClassCard({
    super.key,
    required this.nextClass,
    required this.module,
    required this.onViewTodayClasses,
  });

  @override
  Widget build(BuildContext context) {
    if (nextClass == null) {
      return Container(
        padding: const EdgeInsets.all(22.0),
        decoration: BoxDecoration(
          color: AppColors.deepNavy,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 16, color: AppColors.campusOrange),
                const SizedBox(width: 6),
                Text(
                  'NO MORE CLASSES TODAY',
                  style: AppTypography.overlineBadge(color: AppColors.campusOrange),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'You are all caught up!',
              style: TextStyle(
                fontFamily: AppTypography.poppinsFont,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review notes, study for upcoming deadlines, or recharge.',
              style: TextStyle(
                fontFamily: AppTypography.interFont,
                fontSize: 13,
                color: Color(0xFFC5CEE0),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onViewTodayClasses,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.campusOrange,
                  foregroundColor: AppColors.deepNavy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: const Text(
                  'View timetable',
                  style: TextStyle(
                    fontFamily: AppTypography.poppinsFont,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final session = nextClass!.classSession;
    final moduleName = module?.name ?? session.type;
    final countdownStr = nextClass!.isInProgress
        ? 'IN PROGRESS · ${nextClass!.remainingDuration.inMinutes} MIN LEFT'
        : 'NEXT CLASS · IN ${_formatCountdown(nextClass!.timeUntilStart)}';

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                nextClass!.isInProgress ? Icons.play_circle_fill_rounded : Icons.schedule_rounded,
                size: 16,
                color: AppColors.campusOrange,
              ),
              const SizedBox(width: 6),
              Text(
                countdownStr,
                style: AppTypography.overlineBadge(color: AppColors.campusOrange),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            moduleName,
            style: const TextStyle(
              fontFamily: AppTypography.poppinsFont,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${session.startTime}–${session.endTime} · ${session.room}',
            style: const TextStyle(
              fontFamily: AppTypography.interFont,
              fontSize: 14,
              color: Color(0xFFC5CEE0),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onViewTodayClasses,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.campusOrange,
                foregroundColor: AppColors.deepNavy,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text(
                'View today\'s classes',
                style: TextStyle(
                  fontFamily: AppTypography.poppinsFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCountdown(Duration diff) {
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} MIN';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      final m = diff.inMinutes % 60;
      return m > 0 ? '$h HR $m MIN' : '$h HR';
    }
    final days = diff.inDays;
    return '$days ${days == 1 ? 'DAY' : 'DAYS'}';
  }
}
