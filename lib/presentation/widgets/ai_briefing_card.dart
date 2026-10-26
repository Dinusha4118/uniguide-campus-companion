import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../domain/calculations/ai_study_companion_engine.dart';

class AiBriefingCard extends StatefulWidget {
  final DailyBriefingResult briefing;
  final VoidCallback onOpenAssistant;

  const AiBriefingCard({
    super.key,
    required this.briefing,
    required this.onOpenAssistant,
  });

  @override
  State<AiBriefingCard> createState() => _AiBriefingCardState();
}

class _AiBriefingCardState extends State<AiBriefingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final b = widget.briefing;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B), // Deep indigo
                  const Color(0xFF0F172A),
                ]
              : [
                  const Color(0xFFEEF2FF),
                  const Color(0xFFE0E7FF),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI DAILY BRIEFING',
                        style: TextStyle(
                          fontFamily: AppTypography.poppinsFont,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.1,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.campusOrange.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Score: ${b.academicHealthScore}%',
                      style: const TextStyle(
                        fontFamily: AppTypography.poppinsFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.campusOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status Summary
              Text(
                b.statusSummary,
                style: TextStyle(
                  fontFamily: AppTypography.poppinsFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: isDark ? Colors.white : AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 6),

              // Quote
              Text(
                '“${b.motivationalQuote}”',
                style: TextStyle(
                  fontFamily: AppTypography.interFont,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                ),
              ),
              const SizedBox(height: 14),

              // Priority Actions
              if (b.topPriorityActions.isNotEmpty) ...[
                for (final action in b.topPriorityActions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: AppColors.mintSuccess,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            action,
                            style: TextStyle(
                              fontFamily: AppTypography.interFont,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textDarkHigh : AppColors.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 8),
              ],

              // Interactive Button to open AI Assistant
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: widget.onOpenAssistant,
                  icon: const Icon(Icons.forum_outlined, size: 16),
                  label: const Text(
                    'Chat with AI Academic Assistant',
                    style: TextStyle(
                      fontFamily: AppTypography.poppinsFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
