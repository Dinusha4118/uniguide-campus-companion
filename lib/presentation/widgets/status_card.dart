import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/calculations/attendance_calculator.dart';

class StatusCard extends StatelessWidget {
  final AttendanceStatus status;
  final String title;
  final String subtitle;
  final String? badgeText;
  final Widget? trailing;
  final VoidCallback? onTap;

  const StatusCard({
    super.key,
    required this.status,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color border;
    Color textColor;
    IconData icon;
    String defaultBadge;

    switch (status) {
      case AttendanceStatus.safe:
        bg = isDark ? AppColors.safeGreenDarkTint : AppColors.safeGreenTint;
        border = AppColors.mintSuccess.withOpacity(0.35);
        textColor = isDark ? AppColors.mintSuccess : AppColors.safeGreenText;
        icon = Icons.check_circle_outline_rounded;
        defaultBadge = 'SAFE';
        break;
      case AttendanceStatus.atLimit:
        bg = isDark ? AppColors.warnAmberDarkTint : AppColors.warnAmberTint;
        border = AppColors.amberWarn.withOpacity(0.35);
        textColor = isDark ? AppColors.amberWarn : AppColors.warnAmberText;
        icon = Icons.warning_amber_rounded;
        defaultBadge = '! AT THE LIMIT';
        break;
      case AttendanceStatus.needsAttention:
      case AttendanceStatus.impossible:
        bg = isDark ? AppColors.alertRedDarkTint : AppColors.alertRedTint;
        border = AppColors.alertRed.withOpacity(0.35);
        textColor = isDark ? const Color(0xFFFF6B6B) : AppColors.alertRedText;
        icon = Icons.error_outline_rounded;
        defaultBadge = '! ATTENDANCE ALERT';
        break;
      case AttendanceStatus.noRecords:
        bg = isDark ? AppColors.cardDark : AppColors.cardLight;
        border = isDark ? AppColors.borderDark : AppColors.borderLight;
        textColor = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
        icon = Icons.info_outline_rounded;
        defaultBadge = 'NO RECORDS';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: border, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: textColor),
                    const SizedBox(width: 6),
                    Text(
                      badgeText ?? defaultBadge,
                      style: AppTypography.overlineBadge(color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.poppinsFont,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textDarkHigh : AppColors.ink,
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
                if (trailing != null) ...[
                  const SizedBox(height: 12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
