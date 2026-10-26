import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CircularGaugeWidget extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final String primaryText;
  final String secondaryText;
  final double size;
  final Color progressColor;
  final Color? trackColor;

  const CircularGaugeWidget({
    super.key,
    required this.value,
    required this.primaryText,
    required this.secondaryText,
    this.size = 200.0,
    this.progressColor = AppColors.campusOrange,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTrack = isDark
        ? AppColors.cardDarkElevated
        : const Color(0xFFE2E8F0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularGaugePainter(
              progress: value.clamp(0.0, 1.0),
              progressColor: progressColor,
              trackColor: trackColor ?? defaultTrack,
              strokeWidth: size * 0.075,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size * 0.1),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    primaryText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.poppinsFont,
                      fontSize: size * 0.22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                    ),
                  ),
                  SizedBox(height: size * 0.02),
                  Text(
                    secondaryText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.interFont,
                      fontSize: size * 0.065,
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color trackColor;
  final double strokeWidth;

  _CircularGaugePainter({
    required this.progress,
    required this.progressColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0.0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start at top (-pi / 2)
      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
